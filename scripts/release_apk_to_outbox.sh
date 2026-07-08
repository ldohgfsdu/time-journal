#!/usr/bin/env bash
# 装包路由：本机 NDK 可跑则本地 build，否则 CI artifact → outbox
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHA="${1:-$(git -C "$ROOT" rev-parse HEAD)}"
if bash "$ROOT/scripts/ensure_ndk_host_runnable.sh" 2>/dev/null; then
  echo "== 本机 NDK 可用：本地 build =="
  exec bash "$ROOT/scripts/build_arm64_to_outbox.sh"
fi
echo "== 本机 NDK 不可用：CI 全自动拉包 =="
exec bash "$ROOT/scripts/fetch_arm64_apk_from_ci.sh" --wait-sha "$SHA" --dispatch