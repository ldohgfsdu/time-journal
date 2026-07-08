#!/usr/bin/env bash
# SDK cmake/ninja 在 Linux 常为 x86_64；arm64 proot 用 apt 工具 + bin 目录包装。
set -euo pipefail
SDK_ROOT="${ANDROID_HOME:-/data/data/com.termux/files/home/Android/Sdk}"
BIN_DIR="$SDK_ROOT/cmake/3.22.1/bin"
CMAKE_BIN="$BIN_DIR/cmake"
NINJA_BIN="$BIN_DIR/ninja"
[[ -f "$CMAKE_BIN" ]] || { echo "[fix-sdk-native] 缺 $CMAKE_BIN（sdkmanager cmake;3.22.1）" >&2; exit 1; }

if command -v apt-get >/dev/null 2>&1; then
  sudo -n true 2>/dev/null && SUDO=sudo || SUDO=
  $SUDO apt-get update -qq
  $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq cmake ninja-build
fi

wrap_if_needed() {
  local tool=$1 sys=$2
  local path="$BIN_DIR/$tool"
  [[ -f "$path" ]] || return 0
  if "$path" --version >/dev/null 2>&1; then
    echo "[fix-sdk-native] $tool OK"
    return 0
  fi
  if [[ ! -x "$sys" ]]; then
    echo "[fix-sdk-native] 需要系统 $tool: $sys" >&2
    return 1
  fi
  if [[ ! -f "${path}.x86_64.bak" ]]; then
    [[ -f "$path" ]] && head -1 "$path" | grep -q '^#!/bin/sh' && return 0
    mv -f "$path" "${path}.x86_64.bak" 2>/dev/null || true
  fi
  cat >"$path" <<EOF
#!/bin/sh
exec "$sys" "\$@"
EOF
  chmod +x "$path"
  echo "[fix-sdk-native] $tool wrapper -> $sys"
  "$path" --version | head -1
}

wrap_if_needed cmake "$(command -v cmake)"
wrap_if_needed ninja "$(command -v ninja)"