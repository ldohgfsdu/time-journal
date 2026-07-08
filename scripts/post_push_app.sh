#!/usr/bin/env bash
# git push 之后调用：若最近一次提交含 app/，后台等待 CI 并尝试安装 arm64 APK。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHA="$(git -C "$ROOT" rev-parse HEAD)"
if ! git -C "$ROOT" diff-tree --no-commit-id --name-only -r "$SHA" | grep -q '^app/'; then
  exit 0
fi
LOG="${TJ_CI_INSTALL_LOG:-$HOME/.cache/time-journal-ci-install.log}"
mkdir -p "$(dirname "$LOG")"
nohup bash "$ROOT/scripts/ci_wait_install_arm64.sh" "$SHA" >>"$LOG" 2>&1 &
echo "已后台等待 CI 并安装（commit ${SHA:0:7}），日志：$LOG"
echo "需已 gh auth login；同机安装会 termux-open 或 pm install。"