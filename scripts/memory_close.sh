#!/usr/bin/env bash
set -euo pipefail

# memory_close.sh — 追加事实快照到 .memory/AUTO_LOG.md，不提交

LOG_FILE=".memory/AUTO_LOG.md"

if [ ! -f "$LOG_FILE" ]; then
  echo "# AUTO_LOG" > "$LOG_FILE"
  echo "" >> "$LOG_FILE"
  echo "This file is appended by scripts/memory_close.sh." >> "$LOG_FILE"
  echo "Only factual status snapshots should be written here." >> "$LOG_FILE"
  echo "Do not store secrets." >> "$LOG_FILE"
  echo "" >> "$LOG_FILE"
fi

{
  echo ""
  echo "## $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo ""
  echo "- pwd: $(pwd)"
  echo "- branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
  echo "- latest commit: $(git log --oneline -1 2>/dev/null || echo 'N/A')"
  echo ""
  echo "\`\`\`"
  echo "git status --short:"
  git status --short
  echo "\`\`\`"
} >> "$LOG_FILE"

echo "memory_close: appended snapshot to $LOG_FILE"
echo "NOTE: 未自动提交。如需提交，请用户明确确认。"
