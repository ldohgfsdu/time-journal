#!/usr/bin/env bash
# 从 GitHub Actions 拉取 arm64 release artifact → outbox（arm64 proot 主装包路径）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKFLOW_FILE="android-arm64-release.yml"
ARTIFACT_NAME="time-journal-arm64-v8a-release"
WAIT_SHA=""
DISPATCH=0
POLL_SEC=30
TIMEOUT_MIN=50

usage() {
  echo "用法: $0 [--wait-sha SHA] [--dispatch] [--latest]" >&2
  echo "  --wait-sha   等待该 commit 的 workflow 成功（默认 HEAD）" >&2
  echo "  --dispatch   若无进行中的 run，触发 workflow_dispatch 一次" >&2
  echo "  --latest     不等待，用最近一条成功的 run" >&2
  exit 2
}

MODE=wait
while [[ $# -gt 0 ]]; do
  case "$1" in
    --wait-sha) WAIT_SHA="${2:?}"; shift 2 ;;
    --wait-sha=*) WAIT_SHA="${1#*=}"; shift ;;
    --dispatch) DISPATCH=1; shift ;;
    --latest) MODE=latest; shift ;;
    -h|--help) usage ;;
    *) echo "未知参数: $1" >&2; usage ;;
  esac
done

command -v gh >/dev/null 2>&1 || { echo "需要 gh：apt install gh 或见 https://cli.github.com" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || {
  echo "请先登录 GitHub：gh auth login" >&2
  echo "（一次性；选 HTTPS + Paste token 或 device code）" >&2
  exit 1
}

cd "$ROOT"
BRANCH="$(git branch --show-current)"
REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "$WAIT_SHA" && "$MODE" == wait ]]; then
  WAIT_SHA="$(git rev-parse HEAD)"
fi

find_run_for_sha() {
  local sha="$1"
  gh run list \
    --workflow="$WORKFLOW_FILE" \
    --branch="$BRANCH" \
    --limit 30 \
    --json databaseId,headSha,status,conclusion,createdAt \
    --jq ".[] | select(.headSha==\"$sha\") | \"\(.databaseId) \(.status) \(.conclusion // \"\")\"" \
    | head -1
}

find_latest_success() {
  gh run list \
    --workflow="$WORKFLOW_FILE" \
    --branch="$BRANCH" \
    --limit 15 \
    --json databaseId,status,conclusion,headSha \
    --jq '.[] | select(.status=="completed" and .conclusion=="success") | .databaseId' \
    | head -1
}

maybe_dispatch() {
  [[ "$DISPATCH" == 1 ]] || return 0
  echo "== 触发 workflow_dispatch ($WORKFLOW_FILE @ $BRANCH) =="
  gh workflow run "$WORKFLOW_FILE" --ref "$BRANCH"
}

run_id=""
if [[ "$MODE" == latest ]]; then
  run_id="$(find_latest_success)"
  [[ -n "$run_id" ]] || { echo "没有成功的 arm64 release run" >&2; exit 1; }
else
  echo "== 等待 CI：workflow=$WORKFLOW_FILE branch=$BRANCH sha=${WAIT_SHA:0:7}（最多 ${TIMEOUT_MIN}min）=="
  deadline=$(( $(date +%s) + TIMEOUT_MIN * 60 ))
  dispatched=0
  while (( $(date +%s) < deadline )); do
    line="$(find_run_for_sha "$WAIT_SHA" || true)"
    if [[ -z "$line" ]]; then
      if [[ "$dispatched" == 0 && "$DISPATCH" == 1 ]]; then
        maybe_dispatch
        dispatched=1
      fi
      echo "$(date '+%H:%M:%S') 尚无该 sha 的 run，${POLL_SEC}s 后再查…"
      sleep "$POLL_SEC"
      continue
    fi
    read -r rid status conclusion <<<"$line"
    if [[ "$status" == completed && "$conclusion" == success ]]; then
      run_id="$rid"
      break
    fi
    if [[ "$status" == completed && "$conclusion" != success && -n "$conclusion" ]]; then
      echo "CI 失败 run=$rid conclusion=$conclusion" >&2
      gh run view "$rid" --log-failed 2>&1 | tail -40 >&2 || true
      exit 1
    fi
    echo "$(date '+%H:%M:%S') run=$rid status=$status conclusion=${conclusion:-pending}"
    sleep "$POLL_SEC"
  done
  [[ -n "$run_id" ]] || { echo "超时：未等到 sha ${WAIT_SHA:0:7} 的成功 build" >&2; exit 1; }
fi

echo "== 下载 artifact run=$run_id name=$ARTIFACT_NAME =="
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
gh run download "$run_id" -n "$ARTIFACT_NAME" -D "$TMP"
APK="$(find "$TMP" -name '*.apk' -type f | head -1)"
[[ -n "$APK" ]] || { echo "artifact 内无 apk" >&2; exit 1; }
bash "$ROOT/scripts/copy_apk_to_outbox.sh" "$APK"
echo "== 完成：CI → outbox（run $run_id）=="