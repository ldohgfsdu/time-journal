# DECISIONS

## Long-term decisions

- 使用手机 Termux + Ubuntu/proot 开发。
- Termux 原生环境只做入口。
- Ubuntu/proot 的 root@localhost 是主开发环境。
- **`agent` 菜单已迁出仓库**（2026-07-08）：
  - 权威源：`~/.ai-tools/agent-launcher/`（与 deepseek-usage 同级，全局本地）
  - 通识：`AGENT_LAUNCHER.md`；各项目 AI 通过 AGENTS.md / ENVIRONMENT 引用，**勿**在 `~/code/*` 仓库内放 agent 脚本
  - Ubuntu `/root/bin/agent`；Termux `~/bin/agent` 薄包装；`bash ~/.ai-tools/agent-launcher/agent-install.sh` 同步
  - Termux：`~/bin/agent` 仅为薄包装（`~/.ai-tools/agent-launcher/agent-termux.sh` 安装副本），经 `proot-distro` 调用 Ubuntu 同一份逻辑
  - **改菜单只改 `~/.ai-tools/agent-launcher/agent.sh`，然后 `bash ~/.ai-tools/agent-launcher/agent-install.sh` 同步**
- Claude Code 接 DeepSeek API。
- 不依赖 Claude 官方 /login。
- 不保存完整历史对话，只保存结构化摘要。
- 项目记忆放在仓库内 .memory/。
- 小步改、小步测、小步提交。
- Web 预览和 APK 打包分开。
- APK 等 MVP 功能闭环后再打。
- 每轮结束更新 CURRENT_STATE 和 SESSION_LOG。
- DeepSeek API Key 只放在 Ubuntu home 的 ~/.deepseek-claude.env，不写进仓库。
- Cross-model project memory is shared through .memory/ and AGENTS.md.
- CLAUDE.md and .claude/ are Claude Code adapters only.
- Future OpenCode / Hermes / Grok workflows should read AGENTS.md and .memory/ before working.
- Do not rely on any single model's hidden conversation memory.
