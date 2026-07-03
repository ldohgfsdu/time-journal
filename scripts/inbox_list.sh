#!/usr/bin/env bash
set -euo pipefail

# inbox_list.sh — 只读列出项目收件箱和共享收件箱内容，不修改文件

echo "===== inbox_list ====="
echo "time: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"

echo ""
echo "--- .external_inbox ---"
if [ -L .external_inbox ]; then
  TARGET=$(readlink .external_inbox)
  echo "symlink -> $TARGET"
  if [ -d .external_inbox ]; then
    echo ""
    echo "contents (recent 30 files):"
    find .external_inbox -maxdepth 1 -type f -printf '%s\t%f\n' 2>/dev/null | sort -rn | head -n 30 || echo "(empty)"
  else
    echo "WARNING: symlink target not accessible"
  fi
else
  echo "NOT FOUND: .external_inbox symlink missing"
fi

echo ""
echo "--- .shared_inbox ---"
if [ -L .shared_inbox ]; then
  TARGET=$(readlink .shared_inbox)
  echo "symlink -> $TARGET"
  if [ -d .shared_inbox ]; then
    echo ""
    echo "contents (recent 30 files):"
    find .shared_inbox -maxdepth 1 -type f -printf '%s\t%f\n' 2>/dev/null | sort -rn | head -n 30 || echo "(empty)"
  else
    echo "WARNING: symlink target not accessible"
  fi
else
  echo "NOT FOUND: .shared_inbox symlink missing"
fi

echo ""
echo "===== inbox_list done ====="
