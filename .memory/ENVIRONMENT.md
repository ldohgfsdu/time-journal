# ENVIRONMENT

## Runtime

- Termux native prompt usually: ~ $
- Ubuntu/proot prompt usually: root@localhost
- Main development environment: Ubuntu/proot
- Main project path: ~/code/time-journal
- Non-main old path: /storage/emulated/0/time-journal

## Agent launcher（`agent` 菜单，全局非仓库）

**与本 Flutter 项目隔离**：脚本与安装逻辑在 `~/.ai-tools/agent-launcher/`，勿放入 `~/code/time-journal` 以免弄乱 git 工作区。所有 AI 改菜单/环境前先读 `~/.ai-tools/agent-launcher/AGENT_LAUNCHER.md`。

| 角色 | 路径 | 说明 |
|------|------|------|
| **权威源（改这里）** | `~/.ai-tools/agent-launcher/agent.sh` | 全局本地，不提交到项目仓库 |
| 通识文档 | `~/.ai-tools/agent-launcher/AGENT_LAUNCHER.md` | 跨项目 / 跨模型 |
| 项目内指针 | `.shared_inbox/agent-launcher-pointer.md` | 仅链接，不复制脚本 |
| **Ubuntu 运行副本** | `/root/bin/agent` | `~/.local/bin/agent` → 同上 |
| **Termux 入口** | `~/bin/agent` | wrapper 安装副本；`claude` → `agent` symlink |

- Termux 输入 `agent` → proot → `/root/bin/agent`，与 Ubuntu 内直接跑 **同一套菜单**。
- 改菜单后：

```bash
bash ~/.ai-tools/agent-launcher/agent-install.sh
bash -n ~/.ai-tools/agent-launcher/agent.sh
agent --self-test
```

### 改菜单后的验证

```bash
bash ~/.ai-tools/agent-launcher/agent-install.sh
agent --self-test
```

### 当前平台菜单（platform-first）

主菜单 1–4：OpenCode / Claude Code / Hermes / Grok。

- Proxy 透明模式：保留 `agent proxy` 子命令与 `proxy_menu()`，**不在主菜单显示**。
- 直接启动：`agent <项目> opencode|claude|hermes|grok`。
- **识图**：`agent vision inbox [提示词]`（扫描 `/storage/emulated/0/inbox` 与 `.external_inbox/` 最新图）；项目内 `bash scripts/ensure_inbox_links.sh` 建链。

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

- Flutter（本机）：`/root/dev/flutter/bin/flutter`（proot 内优先加入 PATH）

### APK 交付（政策）

**主路径（推荐、日常）：**

```text
push 含 app/** → GitHub CI arm64 release
  → bash scripts/fetch_arm64_apk_from_ci.sh
  → outbox
```

- 也可：`bash scripts/post_push_app.sh` / `bash scripts/release_apk_to_outbox.sh`
- 说明：`release_apk_to_outbox.sh` 实现上若本机 NDK 可跑会先尝试本地 build，否则走 CI 拉包；**政策上仍以 CI→outbox 为主**，不扩展本机路径
- 需一次：`gh auth login`
- Outbox：`/storage/emulated/0/outbox/time-journal`（仓库内 `.external_outbox/time-journal`）
- 产物名：`time-journal-arm64-{commit短哈希}-{YYYYMMDD-HHMM}.apk`（仅带版本戳）
- Debug APK：仅 `workflow_dispatch`，不随 push

**Fallback（不扩展）：**

```bash
bash scripts/build_arm64_to_outbox.sh
```

- 需 Android SDK；arm64 proot 上 NDK/cmake 常不可用，**不要**把本机 Gradle 当主路径继续加脚本
- 首次 SDK：`bash scripts/setup_android_sdk_termux.sh`；续装：`bash scripts/install_android_sdk_packages.sh`
- arm64 proot：`fix_android_sdk_cmake_arm64.sh` 用系统 cmake/ninja 包装 SDK 路径
- SDK 默认：`/data/data/com.termux/files/home/Android/Sdk`；`scripts/android_sdk.env` 已 gitignore
- **禁止**新增第三条 APK 构建路径

Web Drift depends on:

- app/web/sqlite3.wasm
- app/web/drift_worker.js

## AI usage tools

Global tools:

```
~/.ai-tools/deepseek-usage/    # shared scripts
~/.ai-usage/deepseek/          # usage logs (not committed)
~/.ai-profiles/                # provider env (not committed)
```

Commands:

```
ai-usage             # view usage/balance
ai-proxy-start       # start DeepSeek proxy (port 8787)
ai-proxy-stop        # stop proxy
ai-proxy-status      # proxy + recording status
ai-proxy-enable      # enable token recording
ai-proxy-disable     # pause token recording
```

### Proxy forwarding vs token recording

- Proxy process (`ai-proxy-start`) forwards requests: Claude Code → 127.0.0.1:8787 → DeepSeek.
- Token recording (`ai-proxy-enable/disable`) is controlled by the presence of `~/.ai-usage/deepseek/recording.enabled`.
- Proxy checks this flag file on every request — no restart needed.
- `proxy-disable` pauses recording; proxy continues forwarding normally.
- To use recording controls, launch via **Proxy 透明模式**: `claude proxy <project>`.
- Direct mode (`ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`) bypasses proxy entirely.
- Starting proxy mid-session in direct mode won't affect the current session.
- Neither mode logs prompt or response body text.
- Do not commit `~/.ai-usage/` or API keys.

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
