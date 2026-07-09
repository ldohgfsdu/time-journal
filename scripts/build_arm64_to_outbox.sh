#!/usr/bin/env bash
# 本机打 arm64 Release APK，输出到手机 outbox（日常装包主路径，不依赖 CI）。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/app"

if [[ -f "$ROOT/scripts/android_sdk.env" ]]; then
  # shellcheck source=/dev/null
  source "$ROOT/scripts/android_sdk.env"
fi

if [[ -x /root/dev/flutter/bin/flutter ]]; then
  export PATH="/root/dev/flutter/bin:$PATH"
fi
if [[ -z "${ANDROID_HOME:-}" ]]; then
  if sdk_out="$(bash "$ROOT/scripts/ensure_android_sdk.sh" 2>/dev/null)"; then
    export ANDROID_HOME="${sdk_out#ANDROID_HOME=}"
  fi
fi
if [[ -z "${ANDROID_HOME:-}" ]]; then
  bash "$ROOT/scripts/ensure_android_sdk.sh" >&2 || true
  echo "错误: 未配置 Android SDK" >&2
  exit 1
fi
if [[ -n "${ANDROID_HOME:-}" ]]; then
  export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
fi
bash "$ROOT/scripts/fix_android_sdk_cmake_arm64.sh" 2>/dev/null || true
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
bash "$ROOT/scripts/ensure_ndk_host_runnable.sh"
echo "== flutter build apk (arm64 release) =="
flutter build apk --release --target-platform android-arm64

SRC=""
for candidate in \
  "$APP/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk" \
  "$APP/build/app/outputs/flutter-apk/app-release.apk"; do
  if [[ -f "$candidate" ]]; then
    SRC="$candidate"
    break
  fi
done
[[ -n "$SRC" ]] || { echo "未找到 arm64 release apk under build/app/outputs/flutter-apk/" >&2; exit 1; }
NAME="$(bash "$ROOT/scripts/copy_apk_to_outbox.sh" "$SRC" | tail -1)"
PHONE_OUT="/storage/emulated/0/outbox/time-journal/$NAME"
if command -v termux-open >/dev/null 2>&1 && [[ -f "$PHONE_OUT" ]]; then
  echo "提示: termux-open $PHONE_OUT 可打开安装界面"
fi