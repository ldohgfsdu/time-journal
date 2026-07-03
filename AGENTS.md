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

## External inbox

External inbox root:

```
/storage/emulated/0/inbox
```

Current project inbox:

```
/storage/emulated/0/inbox/time-journal
```

Shared inbox:

```
/storage/emulated/0/inbox/_shared
```

Repository access paths:

```
.external_inbox/
.shared_inbox/
```

Rules:
- When the user says "我上传了文件" / "看新文件" / "读取附件", check .external_inbox/ first.
- For cross-project shared resources, check .shared_inbox/.
- Do not commit .external_inbox or .shared_inbox.
- Do not copy external files into the repository unless the user explicitly requests it.
- Before analyzing large files, list filename, size, and type first — do not blindly read everything.

## External outbox

External outbox root:

```
/storage/emulated/0/outbox
```

Current project outbox:

```
/storage/emulated/0/outbox/time-journal
```

Shared outbox:

```
/storage/emulated/0/outbox/_shared
```

Repository access paths:

```
.external_outbox/
.shared_outbox/
```

Rules:
- When the user says "输出到 outbox" / "导出报告" / "保存一份", write to .external_outbox/.
- For cross-project shared exports, use .shared_outbox/.
- Do not commit .external_outbox or .shared_outbox.

## Model switching rule

When switching between AI tools or models:

1. Run a boot/status check first.
2. Read .memory/CURRENT_STATE.md and .memory/ACTIVE_OBJECT.md.
3. Do not assume previous chat context exists.
4. Continue from repository memory, not from hidden model memory.
5. Close the round by updating .memory/SESSION_LOG.md.
