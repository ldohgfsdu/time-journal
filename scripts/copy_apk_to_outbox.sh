#!/usr/bin/env bash
# 将 APK 复制到 outbox，仅保留带 commit + 时间戳的文件名（不写固定名 release.apk）
set -euo pipefail
SRC="${1:?usage: copy_apk_to_outbox.sh <apk-path>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIRS=(
  "/storage/emulated/0/outbox/time-journal"
  "$ROOT/.external_outbox"
)
SHORT="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo local)"
STAMP="$(date +%Y%m%d-%H%M)"
NAME="time-journal-arm64-${SHORT}-${STAMP}.apk"
[[ -f "$SRC" ]] || { echo "APK 不存在: $SRC" >&2; exit 1; }
for dir in "${OUT_DIRS[@]}"; do
  mkdir -p "$dir"
  cp -f "$SRC" "$dir/$NAME"
  echo "OK: $dir/$NAME"
done
# 供后续脚本/提示使用
echo "$NAME"
