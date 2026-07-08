#!/usr/bin/env bash
# 在 Termux + Ubuntu proot 内安装 Google Android SDK（arm64），供 flutter build apk。
# 用法：在 proot 里 bash scripts/setup_android_sdk_termux.sh
# Termux 侧不要用 root 跑 pkg；本脚本用 apt（proot Ubuntu）。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/scripts/android_sdk.env"

# 与 Termux $HOME 共享，proot 与 Termux 都能用同一路径
SDK_ROOT="${ANDROID_HOME:-/data/data/com.termux/files/home/Android/Sdk}"
export ANDROID_HOME="$SDK_ROOT"

log() { echo "[setup-android-sdk] $*"; }

install_apt_deps() {
  if ! command -v apt-get >/dev/null 2>&1; then
    log "无 apt-get：请在 Ubuntu proot 内运行，或自行安装 openjdk-17、unzip、wget"
    return 1
  fi
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless unzip wget ca-certificates
}

install_cmdline_tools() {
  mkdir -p "$SDK_ROOT/cmdline-tools"
  local zip="/tmp/commandlinetools-linux.zip"
  local url="https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip"
  if [[ ! -x "$SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]]; then
    log "下载 commandlinetools …"
    wget -q -O "$zip" "$url"
    rm -rf "$SDK_ROOT/cmdline-tools/latest"
    unzip -q -o "$zip" -d "$SDK_ROOT/cmdline-tools"
    # zip 解压为 cmdline-tools/，需挪到 latest/
    if [[ -d "$SDK_ROOT/cmdline-tools/cmdline-tools" ]]; then
      mv "$SDK_ROOT/cmdline-tools/cmdline-tools" "$SDK_ROOT/cmdline-tools/latest"
    elif [[ ! -d "$SDK_ROOT/cmdline-tools/latest" ]]; then
      mkdir -p "$SDK_ROOT/cmdline-tools/latest"
      unzip -q -o "$zip" -d "$SDK_ROOT/cmdline-tools/latest"
    fi
    rm -f "$zip"
  fi
  export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$SDK_ROOT/platform-tools:$PATH"
}

sdk_packages() {
  bash "$ROOT/scripts/install_android_sdk_packages.sh"
}

write_env_file() {
  cat >"$ENV_FILE" <<EOF
# 由 setup_android_sdk_termux.sh 生成；build_arm64_to_outbox.sh 会自动 source
export ANDROID_HOME="$SDK_ROOT"
export PATH="\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH"
EOF
  log "已写入 $ENV_FILE"
}

flutter_config() {
  local flutter_bin="/root/dev/flutter/bin/flutter"
  [[ -x "$flutter_bin" ]] || flutter_bin="$(command -v flutter || true)"
  if [[ -x "$flutter_bin" ]]; then
    "$flutter_bin" config --android-sdk "$SDK_ROOT"
    log "flutter config --android-sdk $SDK_ROOT"
  fi
}

main() {
  log "ANDROID_HOME=$SDK_ROOT"
  install_apt_deps
  install_cmdline_tools
  sdk_packages
  write_env_file
  flutter_config
  bash "$ROOT/scripts/ensure_android_sdk.sh"
  log "完成。下一步: bash scripts/build_arm64_to_outbox.sh"
}

main "$@"