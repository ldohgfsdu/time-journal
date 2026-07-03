# time-journal-memory skill

Purpose:
Maintain project memory for time-journal using structured repository-local markdown files.

When to use:
- On session boot
- Before starting a new task
- Before and after commits
- At round close
- When project state appears inconsistent

Protocol:
1. Read CLAUDE.md.
2. Read .memory/BOOT.md.
3. Read .memory/RULES.md.
4. Read .memory/CURRENT_STATE.md.
5. Read .memory/ACTIVE_OBJECT.md.
6. Read .memory/DECISIONS.md.
7. Read .memory/ENVIRONMENT.md.
8. Run scripts/memory_boot.sh.
9. Report drift instead of silently fixing it.
10. At close, update CURRENT_STATE and SESSION_LOG.

Hard limits:
- Never store secrets.
- Never start web-server without confirmation.
- Never reset/checkout/clean without explicit approval.
- Never alter Drift schema without approval.
