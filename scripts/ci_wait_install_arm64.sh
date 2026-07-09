#!/usr/bin/env bash
# 可选：等 CI 绿后 gh 下载并安装。日常装包请用 build_arm64_to_outbox.sh。
set -euo pipefail

REPO="${REPO:-ldohgfsdu/time-journal}"
WORKFLOW_NAME="${WORKFLOW_NAME:-Android arm64 Release APK}"
ARTIFACT_NAME="${ARTIFACT_NAME:-time-journal-arm64-v8a-release}"
POLL_SEC="${POLL_SEC:-45}"
TIMEOUT_SEC="${TIMEOUT_SEC:-2700}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHA="${1:-$(git -C "$ROOT" rev-parse HEAD)}"

log() { echo "[ci-install $(date +%H:%M:%S)] $*"; }

have_gh_download() {
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    return 0
  fi
  [[ -n "${GH_TOKEN:-}" || -n "${GITHUB_TOKEN:-}" ]] && command -v gh >/dev/null 2>&1
}

wait_for_success() {
  local deadline=$((SECONDS + TIMEOUT_SEC))
  while (( SECONDS < deadline )); do
    local out
    out="$(python3 - "$SHA" "$REPO" "$WORKFLOW_NAME" <<'PY'
import json, sys, urllib.request
sha, repo, wf = sys.argv[1], sys.argv[2], sys.argv[3]
url = f"https://api.github.com/repos/{repo}/actions/runs?per_page=25"
req = urllib.request.Request(url, headers={"Accept":"application/vnd.github+json","User-Agent":"ci-install"})
with urllib.request.urlopen(req, timeout=30) as r:
    runs = json.load(r).get("workflow_runs", [])
for run in runs:
    h = run.get("head_sha") or ""
    if h != sha and not h.startswith(sha):
        continue
    if run.get("name") != wf:
        continue
    print(run["id"], run["status"], run.get("conclusion") or "")
    sys.exit(0)
print("", "pending", "")
PY
)" || true
    local run_id status conclusion
    read -r run_id status conclusion <<<"$out"
    if [[ -z "$run_id" ]]; then
      log "等待 Actions 出现 run（sha ${SHA:0:7}）…"
      sleep "$POLL_SEC"
      continue
    fi
    if [[ "$status" != "completed" ]]; then
      log "CI 进行中 run_id=$run_id …"
      sleep "$POLL_SEC"
      continue
    fi
    if [[ "$conclusion" == "success" ]]; then
      echo "$run_id"
      return 0
    fi
    log "CI 失败 conclusion=$conclusion run_id=$run_id"
    return 1
  done
  log "超时（${TIMEOUT_SEC}s）"
  return 1
}

download_apk() {
  local run_id="$1"
  local work
  work="$(mktemp -d /tmp/tj-apk.XXXXXX)"
  trap 'rm -rf "$work"' RETURN
  log "下载 artifact（run $run_id）…"
  gh run download "$run_id" \
    --repo "$REPO" \
    -n "$ARTIFACT_NAME" \
    -D "$work"
  local apk
  apk="$(find "$work" -name '*.apk' | head -1)"
  [[ -n "$apk" && -f "$apk" ]] || { log "artifact 里未找到 apk"; return 1; }
  # 只写带 commit 戳的文件名
  local name
  name="$(bash "$ROOT/scripts/copy_apk_to_outbox.sh" "$apk" | tail -1)"
  local dest="/storage/emulated/0/outbox/time-journal/$name"
  if [[ -f "$dest" ]]; then
    log "已复制 → $dest"
    echo "$dest"
    return 0
  fi
  dest="$ROOT/.external_outbox/$name"
  log "已复制 → $dest"
  echo "$dest"
}

install_apk() {
  local apk="$1"
  [[ -f "$apk" ]] || return 1
  if command -v adb >/dev/null 2>&1; then
    if adb devices 2>/dev/null | grep -qE 'device$'; then
      log "adb install -r …"
      adb install -r "$apk" && return 0
    fi
  fi
  if command -v pm >/dev/null 2>&1; then
    log "pm install -r（同机 Termux）…"
    if pm install -r "$apk" 2>/dev/null; then
      return 0
    fi
  fi
  if command -v termux-open >/dev/null 2>&1; then
    log "打开系统安装界面（需点一次「安装」）…"
    termux-open "$apk"
    return 0
  fi
  log "无法自动安装；请手动打开：$apk"
  return 0
}

main() {
  log "commit ${SHA:0:7}"
  if ! have_gh_download; then
    log "未配置 gh 登录：请先执行 gh auth login（或设置 GH_TOKEN），才能自动下载 artifact。"
    log "CI 仍可用公开 API 等待；绿了之后请去 Actions 手动下载。"
    wait_for_success >/dev/null || exit 1
    log "CI 已成功，但无法自动下载。请 Actions 下载 $ARTIFACT_NAME"
    exit 2
  fi
  local run_id
  run_id="$(wait_for_success)" || exit 1
  local apk_path
  apk_path="$(download_apk "$run_id")"
  install_apk "$apk_path"
  log "完成"
}

main "$@"