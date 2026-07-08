#!/usr/bin/env bash
# Android SDK 的 cmake 在 Linux 上常为 x86_64；arm64 proot 需改用系统 cmake 包装。
set -euo pipefail
SDK_ROOT="${ANDROID_HOME:-/data/data/com.termux/files/home/Android/Sdk}"
CMAKE_BIN="$SDK_ROOT/cmake/3.22.1/bin/cmake"
if [[ ! -f "$CMAKE_BIN" ]]; then
  echo "[fix-cmake] 无 $CMAKE_BIN，请先 sdkmanager 安装 cmake;3.22.1" >&2
  exit 1
fi
if command -v apt-get >/dev/null 2>&1; then
  sudo -n true 2>/dev/null && SUDO=sudo || SUDO=
  $SUDO apt-get update -qq
  $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq cmake
fi
SYS="$(command -v cmake)"
[[ -n "$SYS" ]] || { echo "[fix-cmake] 系统无 cmake" >&2; exit 1; }
if "$CMAKE_BIN" --version >/dev/null 2>&1; then
  echo "[fix-cmake] SDK cmake 已可执行，跳过"
  exit 0
fi
mv -f "$CMAKE_BIN" "${CMAKE_BIN}.x86_64.bak" 2>/dev/null || true
cat >"$CMAKE_BIN" <<EOF
#!/bin/sh
exec "$SYS" "\$@"
EOF
chmod +x "$CMAKE_BIN"
echo "[fix-cmake] wrapper -> $SYS"
"$CMAKE_BIN" --version | head -1