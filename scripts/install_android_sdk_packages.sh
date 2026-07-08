#!/usr/bin/env bash
# 仅安装 SDK 包（cmdline-tools 已存在时续跑）
set -euo pipefail
SDK_ROOT="${ANDROID_HOME:-/data/data/com.termux/files/home/Android/Sdk}"
export ANDROID_HOME="$SDK_ROOT"
SDKMAN="$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
[[ -x "$SDKMAN" ]] || { echo "missing $SDKMAN"; exit 1; }
export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$SDK_ROOT/platform-tools:$PATH"
log(){ echo "[sdk-packages] $*"; }
log licenses
( yes || true ) | "$SDKMAN" --sdk_root="$SDK_ROOT" --licenses 2>&1 | tail -5
log install
stdbuf -oL -eL "$SDKMAN" --sdk_root="$SDK_ROOT" \
  "platform-tools" "platforms;android-36" "build-tools;36.0.0" "ndk;28.2.13676358" "cmake;3.22.1"
ROOT=/root/code/time-journal
bash "$ROOT/scripts/fix_android_sdk_cmake_arm64.sh"
cat >"$ROOT/scripts/android_sdk.env" <<EOF
export ANDROID_HOME="$SDK_ROOT"
export PATH="\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH"
EOF
/root/dev/flutter/bin/flutter config --android-sdk "$SDK_ROOT"
bash "$ROOT/scripts/ensure_android_sdk.sh"
log done