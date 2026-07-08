#!/usr/bin/env bash
# NDK 主机 clang 能否在本机执行（aarch64 proot 常为否）
set -euo pipefail
SDK_ROOT="${ANDROID_HOME:-/data/data/com.termux/files/home/Android/Sdk}"
NDK="${NDK_VERSION:-28.2.13676358}"
PREBUILT="$SDK_ROOT/ndk/$NDK/toolchains/llvm/prebuilt"
host=$(ls -1 "$PREBUILT" 2>/dev/null | head -1)
clang="$PREBUILT/$host/bin/clang"
if [[ ! -f "$clang" ]]; then
  echo "NDK clang missing: $clang" >&2
  exit 1
fi
if "$clang" --version >/dev/null 2>&1; then
  exit 0
fi
echo "NDK 主机工具不可执行: $clang (host=$host, machine=$(uname -m))" >&2
echo "本机 arm64 proot 请用 CI APK 或安装 amd64 运行库+qemu；见 .memory/ENVIRONMENT.md" >&2
exit 2