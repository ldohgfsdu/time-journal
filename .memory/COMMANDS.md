# COMMANDS

## Start

Termux native:

```
claude
```

Ubuntu/proot manual:

```
cd ~/code/time-journal
claude --permission-mode acceptEdits
```

## Check

```
git status --short
git log --oneline --decorate -10
bash scripts/memory_boot.sh
bash scripts/memory_snapshot.sh
```

## Flutter validate

```
cd app && timeout 180 flutter analyze
cd app && timeout 180 flutter test
```

## Web preview

Only after user confirmation:

```
cd app && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
```

## Cross-model memory

For any AI tool:

1. Read AGENTS.md first.
2. Then read .memory/CURRENT_STATE.md and .memory/ACTIVE_OBJECT.md.
3. Then inspect git status before making changes.

## Usage / Proxy

```
ai-usage             # 完整用量报告
ai-usage --auto      # 一行自动尾巴
ai-proxy-start       # 启动 proxy（端口 8787）
ai-proxy-stop        # 停止 proxy
ai-proxy-status      # proxy 进程 + token 记录状态
ai-proxy-enable      # 开启 token 记录（不重启 proxy）
ai-proxy-disable     # 暂停 token 记录（proxy 继续转发）
```

### Proxy vs Recording

- Proxy 进程和 token 记录是独立的两个概念。
- `proxy-start` 启动转发代理，`proxy-enable` 才开启记录。
- `proxy-disable` 暂停记录，proxy 继续转发，不影响 Claude Code。
- proxy 每次请求动态检查 `~/.ai-usage/deepseek/recording.enabled`，不需要重启。
- 直连模式中途启动 proxy 不会接管当前会话。
- 要用记录控制，必须通过 proxy 透明模式启动 Claude Code。

## Inbox / Outbox

```
bash scripts/inbox_list.sh
```

Inbox:

```
.external_inbox/  -> /storage/emulated/0/inbox/time-journal
.shared_inbox/    -> /storage/emulated/0/inbox/_shared
```

Outbox:

```
.external_outbox/ -> /storage/emulated/0/outbox/time-journal
.shared_outbox/   -> /storage/emulated/0/outbox/_shared
```

## Close round

```
bash scripts/memory_close.sh
```
