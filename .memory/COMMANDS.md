# COMMANDS

## Start

Termux native（主入口）:

```
agent
# 或 claude（symlink → agent）
```

Ubuntu/proot:

```
agent
# 或
cd ~/code/time-journal && claude --permission-mode acceptEdits
```

直接启动（跳过菜单）:

```
agent time-journal opencode
agent time-journal claude
agent time-journal hermes
agent time-journal grok
agent time-journal proxy    # Proxy 透明模式，子命令保留
```

### 修改 `agent` 菜单（全局，非本仓库）

权威源：`~/.ai-tools/agent-launcher/agent.sh`。改完后：

```bash
bash ~/.ai-tools/agent-launcher/agent-install.sh
agent --self-test
```

通识：`~/.ai-tools/agent-launcher/AGENT_LAUNCHER.md`。详见 `.memory/ENVIRONMENT.md` → Agent launcher。

## Check

```
git status --short
git log --oneline --decorate -10
bash scripts/memory_boot.sh
bash scripts/memory_snapshot.sh
```

## Flutter validate

```bash
bash scripts/pre_push_app_check.sh
```

或：

```bash
cd app && timeout 180 flutter analyze
cd app && timeout 180 flutter test
```

## Commit / push / CI APK

默认流程（见 `.memory/RULES.md`）：

1. 验证通过后 commit
2. `git push origin p0/journal-compare`（除非用户说不要 push）
3. 若 push 含 **`app/`** 改动 → GitHub Actions 自动 analyze、test、上传 **arm64 release** APK（日常只装这个）
4. 在 GitHub 仓库 **Actions** 页下载 artifact；或手动 `workflow_dispatch` 重跑

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

```text
/storage/emulated/0/inbox/time-journal   # 手机侧项目收件箱（推荐放截图）
.external_inbox/  -> 同上（bash scripts/ensure_inbox_links.sh）
```

识图最新 inbox 截图：

```bash
agent vision inbox "提示词"
```

.shared_inbox/    -> /storage/emulated/0/inbox/_shared

Outbox:

```
.external_outbox/ -> /storage/emulated/0/outbox/time-journal
.shared_outbox/   -> /storage/emulated/0/outbox/_shared
```

## Close round

```
bash scripts/memory_close.sh
```
