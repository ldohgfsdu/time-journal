#!/usr/bin/env bash
# 将 APK 复制到 outbox：
#   - 最新：根目录 time-journal-arm64-{commit}-{YYYYMMDD-HHMM}.apk
#   - 旧包：自动移入 history/
set -euo pipefail
SRC="${1:?usage: copy_apk_to_outbox.sh <apk-path>}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANDIDATES=(
  "/storage/emulated/0/outbox/time-journal"
  "$ROOT/.external_outbox/time-journal"
  "$ROOT/.external_outbox"
)
SHORT="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo local)"
STAMP="$(date +%Y%m%d-%H%M)"
NAME="time-journal-arm64-${SHORT}-${STAMP}.apk"
[[ -f "$SRC" ]] || { echo "APK 不存在: $SRC" >&2; exit 1; }

# 去重：symlink 指向同一目录时只处理一次
declare -A SEEN=()
OUT_DIRS=()
for d in "${CANDIDATES[@]}"; do
  [[ -e "$d" || -L "$d" ]] || { mkdir -p "$d" 2>/dev/null || true; }
  [[ -d "$d" ]] || continue
  real="$(readlink -f "$d" 2>/dev/null || echo "$d")"
  [[ -n "${SEEN[$real]:-}" ]] && continue
  SEEN[$real]=1
  OUT_DIRS+=("$real")
done
[[ ${#OUT_DIRS[@]} -gt 0 ]] || {
  mkdir -p "$ROOT/.external_outbox"
  OUT_DIRS+=("$ROOT/.external_outbox")
}

archive_old_apks() {
  local dir="$1"
  local keep="$2"
  local hist="$dir/history"
  mkdir -p "$hist"
  shopt -s nullglob
  local f base
  for f in "$dir"/time-journal-arm64-*.apk; do
    base="$(basename "$f")"
    [[ "$base" == "$keep" ]] && continue
    mv -f "$f" "$hist/$base"
    echo "archive: $hist/$base"
  done
  shopt -u nullglob
}

for dir in "${OUT_DIRS[@]}"; do
  mkdir -p "$dir/history"
  cp -f "$SRC" "$dir/$NAME"
  archive_old_apks "$dir" "$NAME"
  echo "OK: $dir/$NAME"
done
echo "$NAME"
