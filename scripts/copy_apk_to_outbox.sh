#!/usr/bin/env bash
# 将 APK 复制到 outbox（与 build_arm64_to_outbox 同名规则）
set -euo pipefail
SRC="${1:?usage: copy_apk_to_outbox.sh <apk-path>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APK_NAME="time-journal-arm64-release.apk"
OUT_DIRS=(
  "/storage/emulated/0/outbox/time-journal"
  "$ROOT/.external_outbox"
)
SHORT="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo local)"
STAMP="$(date +%Y%m%d-%H%M)"
[[ -f "$SRC" ]] || { echo "APK 不存在: $SRC" >&2; exit 1; }
for dir in "${OUT_DIRS[@]}"; do
  mkdir -p "$dir"
  cp -f "$SRC" "$dir/$APK_NAME"
  cp -f "$SRC" "$dir/time-journal-arm64-${SHORT}-${STAMP}.apk"
  echo "OK: $dir/$APK_NAME"
  echo "OK: $dir/time-journal-arm64-${SHORT}-${STAMP}.apk"
done