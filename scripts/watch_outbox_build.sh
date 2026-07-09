#!/usr/bin/env bash
# 盯到 outbox 有 APK 或 Gradle 失败/超时
set -uo pipefail
ROOT=/root/code/time-journal
OUT_DIR="/storage/emulated/0/outbox/time-journal"
LOG=/root/.cache/outbox-watch.log
MAX_ROUNDS=36   # 36 * 5min = 3h
round=0
# 最新带戳 APK（不再使用固定名 release.apk）
latest_apk() {
  ls -1t "$OUT_DIR"/time-journal-arm64-*.apk 2>/dev/null | head -1
}
log(){ echo "$(date '+%H:%M:%S') $*" | tee -a "$LOG"; }
log "=== outbox watch start ==="
while (( round < MAX_ROUNDS )); do
  round=$((round + 1))
  OUT="$(latest_apk || true)"
  if [[ -n "${OUT:-}" && -f "$OUT" ]]; then
    ls -la "$OUT" | tee -a "$LOG"
    log "DONE: outbox APK ready ($OUT)"
    exit 0
  fi
  if ls "$ROOT/app/build/app/outputs/flutter-apk/"*.apk >/dev/null 2>&1; then
    log "APK built, copying via build_arm64_to_outbox…"
    SKIP_CHECK=1 bash "$ROOT/scripts/build_arm64_to_outbox.sh" 2>&1 | tail -20 | tee -a "$LOG"
    OUT="$(latest_apk || true)"
    [[ -n "${OUT:-}" && -f "$OUT" ]] && { log "DONE after copy"; exit 0; }
  fi
  if pgrep -f 'GradleWrapperMain.*assembleRelease' >/dev/null 2>&1; then
    etime=$(ps -o etime= -p "$(pgrep -f 'GradleWrapperMain.*assembleRelease' | head -1)" 2>/dev/null | tr -d ' ')
    du_b=$(du -sm "$ROOT/app/build" 2>/dev/null | cut -f1)
    log "round $round/$MAX_ROUNDS: Gradle running etime=${etime:-?} app/build=${du_b:-?}MB"
  else
    if ! bash "$ROOT/scripts/ensure_ndk_host_runnable.sh" 2>>"$LOG"; then
      log "STOP: NDK 主机不可跑，不再重试 build（见 ENVIRONMENT.md）"
      exit 2
    fi
    du_b=$(du -sm "$ROOT/app/build" 2>/dev/null | cut -f1)
    log "round $round: no Gradle; build=${du_b:-?}MB — trying build_arm64_to_outbox"
    if ! SKIP_CHECK=1 bash "$ROOT/scripts/build_arm64_to_outbox.sh" >>"$LOG" 2>&1; then
      log "FAIL: build_arm64_to_outbox exited non-zero (see $LOG)"
      tail -30 "$LOG"
      exit 1
    fi
    OUT="$(latest_apk || true)"
    [[ -n "${OUT:-}" && -f "$OUT" ]] && { log "DONE"; exit 0; }
  fi
  sleep 300
done
log "TIMEOUT after $MAX_ROUNDS rounds"
exit 2