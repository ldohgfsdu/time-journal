#!/usr/bin/env bash
set -euo pipefail

# memory_snapshot.sh — 只读快照，不修改任何文件

echo "===== memory_snapshot ====="
echo "timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "pwd: $(pwd)"

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
echo "--- project files ---"
[ -f app/pubspec.yaml ] && echo "app/pubspec.yaml: found" || echo "app/pubspec.yaml: MISSING"
[ -d app/lib ] && echo "app/lib: found" || echo "app/lib: MISSING"
[ -d .memory ] && echo ".memory: found" || echo ".memory: MISSING"
[ -f CLAUDE.md ] && echo "CLAUDE.md: found" || echo "CLAUDE.md: MISSING"

echo ""
echo "===== snapshot done ====="
