#!/usr/bin/env bash
# 探测 ANDROID_HOME；未配置时打印 Termux/proot 最小安装提示。
set -euo pipefail

if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
  echo "ANDROID_HOME=$ANDROID_HOME"
  exit 0
fi

for d in \
  /root/Android/Sdk \
  "$HOME/Android/Sdk" \
  /data/data/com.termux/files/home/Android/Sdk \
  /data/data/com.termux/files/home/ubuntu/root/Android/Sdk; do
  if [[ -d "$d" ]]; then
    echo "ANDROID_HOME=$d"
    exit 0
  fi
done

echo "MISSING_ANDROID_SDK" >&2
cat >&2 <<'EOF'
本机未找到 Android SDK，无法 flutter build apk。

Termux（在 Ubuntu proot 外或内均可，路径需一致）建议：
  pkg install -y openjdk-17
  mkdir -p ~/Android/Sdk/cmdline-tools
  # 从 https://developer.android.com/studio#command-line-tools-only 下载 commandlinetools-linux-*.zip
  # 解压到 ~/Android/Sdk/cmdline-tools/latest/
  export ANDROID_HOME=$HOME/Android/Sdk
  yes | sdkmanager --licenses
  sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

proot 内构建前：
  export ANDROID_HOME=/data/data/com.termux/files/home/Android/Sdk   # 或你实际路径
  bash scripts/build_arm64_to_outbox.sh

CI 备份：push app/ 后 GitHub Actions 仍会打 arm64 Release artifact。
EOF
exit 1