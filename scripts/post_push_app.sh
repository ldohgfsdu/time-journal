#!/usr/bin/env bash
# 开发一轮收口：commit 含 app/ → 装包到 outbox（本机或 CI 自动）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SHA="$(git -C "$ROOT" rev-parse HEAD)"
if ! git -C "$ROOT" diff-tree --no-commit-id --name-only -r "$SHA" | grep -q '^app/'; then
  echo "本轮 commit 无 app/ 改动，跳过装包。"
  exit 0
fi
exec bash "$ROOT/scripts/release_apk_to_outbox.sh" "$SHA"