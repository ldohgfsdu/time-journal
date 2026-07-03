# ENVIRONMENT

## Runtime

- Termux native prompt usually: ~ $
- Ubuntu/proot prompt usually: root@localhost
- Main development environment: Ubuntu/proot
- Main project path: ~/code/time-journal
- Non-main old path: /storage/emulated/0/time-journal

## Claude Code

- Claude Code version: 2.1.199
- Preferred mode:
  ```
  claude --permission-mode acceptEdits
  ```
- Do not use auto mode as default.
- Do not /login unless user explicitly wants Anthropic official account.

## DeepSeek

DeepSeek configuration is loaded from:

```
~/.deepseek-claude.env
```

Required env variables:

- ANTHROPIC_BASE_URL
- ANTHROPIC_AUTH_TOKEN
- ANTHROPIC_MODEL
- ANTHROPIC_SMALL_FAST_MODEL
- CLAUDE_CODE_SUBAGENT_MODEL

Do not print or commit the API key.

## Flutter / Web

Web Drift depends on:

- app/web/sqlite3.wasm
- app/web/drift_worker.js

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
