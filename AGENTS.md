# time-journal Agent Entry

This repository uses a shared, tool-agnostic project memory system.

All coding agents, regardless of model or tool, should read the shared memory files before doing work.

## Shared memory files

Read in this order:

1. .memory/BOOT.md
2. .memory/RULES.md
3. .memory/CURRENT_STATE.md
4. .memory/ACTIVE_OBJECT.md
5. .memory/DECISIONS.md
6. .memory/ENVIRONMENT.md
7. .memory/SESSION_LOG.md
8. .memory/COMMANDS.md

## Universal rules

- 默认中文沟通。
- Do not store secrets in the repository.
- Do not print or commit API keys.
- Do not reset / checkout / clean unless explicitly approved by the user.
- Do not start web-server unless explicitly approved.
- Report drift if actual git/project state conflicts with memory.
- Before changing code, state the scope.
- After code changes, run the validation commands required by .memory/RULES.md.
- At the end of each work round, update .memory/CURRENT_STATE.md and .memory/SESSION_LOG.md.

## Tool-specific adapters

- Claude Code entry: CLAUDE.md
- Claude Code commands: .claude/commands/
- Claude Code skill: .claude/skills/time-journal-memory/
- Other tools should still use .memory/ as the source of truth.

## Model switching rule

When switching between AI tools or models:

1. Run a boot/status check first.
2. Read .memory/CURRENT_STATE.md and .memory/ACTIVE_OBJECT.md.
3. Do not assume previous chat context exists.
4. Continue from repository memory, not from hidden model memory.
5. Close the round by updating .memory/SESSION_LOG.md.
