# time-journal Agent Entry

This repository uses a shared, tool-agnostic project memory system.

All coding agents, regardless of model or tool, should read the shared memory files before doing work.

## Boot trigger policy

Do not automatically run boot for casual messages (hi, hello, 你好, ?, 在吗, simple status questions, command usage questions). Run boot automatically only before real development tasks (code changes, audits, bug fixes, tests, commits, reports). If unsure, ask one short clarification instead of running boot. Manual boot is always available via the `boot` command.

## Shared memory files

Read in this order (only when boot is triggered):

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

## Agent launcher menu（全局，非本仓库）

`agent` 启动菜单是**本机全局工具**，与 time-journal 应用代码无关；**不要**把 `agent.sh` 放进本仓库或提交到 git。

- 通识文档：`~/.ai-tools/agent-launcher/AGENT_LAUNCHER.md`（改菜单、修环境 bug 前先读）
- 权威脚本：`~/.ai-tools/agent-launcher/agent.sh`
- 同步安装：`bash ~/.ai-tools/agent-launcher/agent-install.sh`
- 项目内摘要：`.memory/ENVIRONMENT.md` → Agent launcher

跨项目指针：`.shared_inbox/agent-launcher-pointer.md`

## Global AI usage tools

This project uses global AI usage tracking tools:

- `~/.ai-tools/deepseek-usage/` — shared scripts (proxy, usage, control)
- `~/.ai-usage/deepseek/` — usage logs and balance snapshots (not committed)
- `~/.ai-profiles/` — model provider env files (not committed)

Key commands:
- `ai-usage` — view DeepSeek usage and balance
- `ai-usage --auto` — one-line usage tail (runs after each round)
- `ai-proxy-start` / `ai-proxy-stop` / `ai-proxy-status` — proxy control
- `ai-proxy-enable` / `ai-proxy-disable` — toggle token recording on/off

### Proxy vs recording: two separate concepts

- **Proxy process** (ai-proxy-start/stop): forwards Claude Code → DeepSeek via `127.0.0.1:8787`. Always forwards, never interrupted.
- **Token recording** (ai-proxy-enable/disable): toggled via `~/.ai-usage/deepseek/recording.enabled` flag file. Proxy checks this on every request — no restart needed.
- `proxy-disable` pauses recording; proxy still forwards requests.
- `proxy-enable` resumes recording; token usage starts writing to `proxy_usage.jsonl`.
- If Claude Code was started in direct mode, starting proxy mid-session won't take over the current session.
- To use recording controls, launch via **Proxy 透明模式**: `agent proxy <project>` (subcommand; not on the main platform menu).
- Direct mode only shows balance estimates via `ai-usage`, not per-request token details.
- Neither mode records prompt or response body text.

Important:
- Usage/proxy tools are global, shared across all projects.
- Do not copy usage logs into this repository.
- Do not commit API keys.
- Do not commit `~/.ai-usage/`.
