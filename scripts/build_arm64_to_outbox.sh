#!/usr/bin/env bash
# 本机打 arm64 Release APK，输出到手机 outbox（日常装包主路径，不依赖 CI）。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/app"
APK_NAME="${APK_NAME:-time-journal-arm64-release.apk}"

if [[ -x /root/dev/flutter/bin/flutter ]]; then
  export PATH="/root/dev/flutter/bin:$PATH"
fi
if [[ -z "${ANDROID_HOME:-}" ]]; then
  for d in /root/Android/Sdk "$HOME/Android/Sdk" /data/data/com.termux/files/home/Android/Sdk; do
    if [[ -d "$d" ]]; then
      export ANDROID_HOME="$d"
      break
    fi
  done
fi
if [[ -n "${ANDROID_HOME:-}" ]]; then
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
fi
if ! command -v flutter >/dev/null 2>&1; then
  echo "错误: 未找到 flutter（期望 /root/dev/flutter/bin 或在 PATH）" >&2
  exit 1
fi

bash "$ROOT/scripts/ensure_inbox_links.sh" >/dev/null 2>&1 || true

OUT_DIRS=()
if [[ -d "$ROOT/.external_outbox" ]]; then
  OUT_DIRS+=("$ROOT/.external_outbox")
fi
if [[ -d "/storage/emulated/0/outbox/time-journal" ]]; then
  OUT_DIRS+=("/storage/emulated/0/outbox/time-journal")
fi
if [[ ${#OUT_DIRS[@]} -eq 0 ]]; then
  mkdir -p "$ROOT/.external_outbox" 2>/dev/null || true
  OUT_DIRS+=("$ROOT/.external_outbox")
fi

SHORT="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo local)"
STAMP="$(date +%Y%m%d-%H%M)"

cd "$APP"
echo "== flutter pub get =="
flutter pub get
if [[ "${SKIP_CHECK:-0}" != "1" ]]; then
  echo "== flutter analyze =="
  flutter analyze
  echo "== flutter test =="
  flutter test
fi
echo "== flutter build apk (arm64 release) =="
flutter build apk --release --target-platform android-arm64

SRC="$APP/build/app/outputs/flutter-apk/app-release.apk"
[[ -f "$SRC" ]] || { echo "未找到 $SRC" >&2; exit 1; }

for dir in "${OUT_DIRS[@]}"; do
  cp -f "$SRC" "$dir/$APK_NAME"
  cp -f "$SRC" "$dir/time-journal-arm64-${SHORT}-${STAMP}.apk"
  echo "OK: $dir/$APK_NAME"
  echo "OK: $dir/time-journal-arm64-${SHORT}-${STAMP}.apk"
done

if command -v termux-open >/dev/null 2>&1; then
  echo "提示: termux-open ${OUT_DIRS[0]}/$APK_NAME 可打开安装界面"
fi