# ACTIVE_OBJECT

## Current stage

真机验收与发布准备阶段。

## Current objective

MVP 缺口修补第一、二轮已完成；P0-6 `linkedPlanId` migration 已合入 `p0/journal-compare`；PR #7/#8/#9 已收口番茄专注与今日对照关联。当前聚焦真机验收与发布准备。

## Active object name

`mvp_acceptance_and_release_preparation`

## Recommended next task

1. 真机复测关键路径（手动 planned「开始专注」、todo 专注、Pomodoro 记入实际与今日对照）。
2. 可选：用户确认后仅提交本仓库 **项目相关** 的 `.memory/` / `AGENTS.md` 记忆更新（不含 agent 脚本；agent 在 `~/.ai-tools/agent-launcher/`）。

## AI agent 分工

- OpenCode（主力）：免费，主线开发 / 审计 / 修复 / 提交
- Claude Code（付费备用）：DeepSeek 余额充足时使用
- Grok：图片审查 / 第二意见
- Hermes：经 `agent` 菜单平台 3 启动
- 终端输入 `agent` 打开启动菜单

## Release blockers

（无）

## Explicitly forbidden now

- 不修改 Drift schema，除非用户明确授权
- 不修改 GitHub Actions（**用户明确要求调整 CI/自动打包策略时除外**）
- 不启动 web-server
- 不大范围重构
- 不继续无限视觉微调