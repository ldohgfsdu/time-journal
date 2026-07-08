#!/usr/bin/env bash
# 未提交也可打包：工作区或 HEAD 含 app/ 改动时构建到 outbox。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if git -C "$ROOT" status --porcelain -- app | grep -q .; then
  echo "检测到 app/ 有未提交改动，仍按当前工作区构建。"
elif ! git -C "$ROOT" diff-tree --no-commit-id --name-only -r HEAD | grep -q '^app/'; then
  echo "无 app/ 改动，跳过。"
  exit 0
fi
exec bash "$ROOT/scripts/build_arm64_to_outbox.sh"