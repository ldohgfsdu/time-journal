#!/usr/bin/env bash
# Push 前本地跑一遍，避免 CI 白等 analyze/test 失败。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/app"
if [[ -x /root/dev/flutter/bin/flutter ]]; then
  export PATH="/root/dev/flutter/bin:$PATH"
elif command -v flutter >/dev/null 2>&1; then
  :
else
  echo "flutter 不在 PATH；跳过本地检查（仍会上 CI）" >&2
  exit 0
fi
cd "$APP"
echo "== flutter pub get =="
flutter pub get
echo "== flutter analyze =="
flutter analyze
echo "== flutter test =="
flutter test
echo "OK: 可 push app/ 改动"