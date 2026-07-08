#!/usr/bin/env bash
# 开发一轮收口：若本轮 commit 含 app/，本机打包到 outbox（主流程）。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHA="$(git -C "$ROOT" rev-parse HEAD)"
if ! git -C "$ROOT" diff-tree --no-commit-id --name-only -r "$SHA" | grep -q '^app/'; then
  echo "本轮 commit 无 app/ 改动，跳过本地打包。"
  exit 0
fi
exec bash "$ROOT/scripts/build_arm64_to_outbox.sh"