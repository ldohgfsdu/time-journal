# DECISIONS

## Long-term decisions

- 使用手机 Termux + Ubuntu/proot 开发。
- Termux 原生环境只做入口。
- Ubuntu/proot 的 root@localhost 是主开发环境。
- Claude Code 接 DeepSeek API。
- 不依赖 Claude 官方 /login。
- 不保存完整历史对话，只保存结构化摘要。
- 项目记忆放在仓库内 .memory/。
- 小步改、小步测、小步提交。
- Web 预览和 APK 打包分开。
- APK 等 MVP 功能闭环后再打。
- 每轮结束更新 CURRENT_STATE 和 SESSION_LOG。
- DeepSeek API Key 只放在 Ubuntu home 的 ~/.deepseek-claude.env，不写进仓库。
