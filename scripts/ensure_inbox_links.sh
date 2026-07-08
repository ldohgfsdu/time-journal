#!/usr/bin/env bash
# ensure_inbox_links.sh — 创建项目内收件箱符号链接（不提交、可重复执行）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INBOX_ROOT="${INBOX_ROOT:-/storage/emulated/0/inbox}"
OUTBOX_ROOT="${OUTBOX_ROOT:-/storage/emulated/0/outbox}"
PROJECT="$(basename "$ROOT")"

mkdir -p "$INBOX_ROOT/$PROJECT" "$INBOX_ROOT/_shared" \
         "$OUTBOX_ROOT/$PROJECT" "$OUTBOX_ROOT/_shared"

ln -sfn "$INBOX_ROOT/$PROJECT" "$ROOT/.external_inbox"

if [ -e "$ROOT/.external_outbox" ] && [ ! -L "$ROOT/.external_outbox" ]; then
  echo "SKIP: .external_outbox 已是目录（保留现有文件）"
else
  ln -sfn "$OUTBOX_ROOT/$PROJECT" "$ROOT/.external_outbox"
  echo "OK: .external_outbox -> $OUTBOX_ROOT/$PROJECT"
fi

# .shared_inbox：若已是目录且非空，只确保 _shared 可写，不强行覆盖目录
if [ ! -e "$ROOT/.shared_inbox" ]; then
  ln -sfn "$INBOX_ROOT/_shared" "$ROOT/.shared_inbox"
fi
if [ ! -e "$ROOT/.shared_outbox" ]; then
  ln -sfn "$OUTBOX_ROOT/_shared" "$ROOT/.shared_outbox"
fi

echo "OK: .external_inbox -> $INBOX_ROOT/$PROJECT"
echo "OK: .external_outbox -> $OUTBOX_ROOT/$PROJECT"
ls -la "$ROOT/.external_inbox" "$ROOT/.external_outbox" 2>/dev/null || true