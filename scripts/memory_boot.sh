#!/usr/bin/env bash
set -euo pipefail

# memory_boot.sh — 只读启动检查，不修改任何文件

echo "===== memory_boot ====="
echo "time: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "pwd: $(pwd)"

echo ""
echo "--- project check ---"
if [ -f app/pubspec.yaml ]; then
  echo "app/pubspec.yaml: found"
else
  echo "app/pubspec.yaml: MISSING — 不在 Flutter 工程根目录？"
fi

echo ""
echo "--- git ---"
echo "branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
echo ""
echo "git status --short:"
git status --short
echo ""
echo "git log --oneline --decorate -10:"
git log --oneline --decorate -10

echo ""
echo "--- ACTIVE_OBJECT (first 80 lines) ---"
if [ -f .memory/ACTIVE_OBJECT.md ]; then
  head -n 80 .memory/ACTIVE_OBJECT.md
else
  echo ".memory/ACTIVE_OBJECT.md not found"
fi

echo ""
echo "===== boot done ====="
