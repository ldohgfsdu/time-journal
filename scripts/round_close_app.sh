#!/usr/bin/env bash
# 未提交也可装包：有 app/ 改动时 → outbox（未 push 且 NDK 不可用时需先 push 才能走 CI）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIRTY=0
if git -C "$ROOT" status --porcelain -- app | grep -q .; then
  DIRTY=1
  echo "检测到 app/ 有未提交改动。"
elif ! git -C "$ROOT" diff-tree --no-commit-id --name-only -r HEAD | grep -q '^app/'; then
  echo "无 app/ 改动，跳过。"
  exit 0
fi
if [[ "$DIRTY" == 1 ]] && ! bash "$ROOT/scripts/ensure_ndk_host_runnable.sh" 2>/dev/null; then
  echo "未提交 + 本机 NDK 不可用：请先 commit 并 push，再执行 bash scripts/post_push_app.sh" >&2
  exit 1
fi
if [[ "$DIRTY" == 1 ]]; then
  exec bash "$ROOT/scripts/build_arm64_to_outbox.sh"
fi
exec bash "$ROOT/scripts/release_apk_to_outbox.sh" "$(git -C "$ROOT" rev-parse HEAD)"