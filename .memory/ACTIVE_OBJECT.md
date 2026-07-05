# ACTIVE_OBJECT

## Current stage

真机验收与发布准备阶段。

## Current objective

MVP 功能开发已暂停，进入真机验收、发布准备和阻塞问题修复阶段。

## Active object name

`mvp_acceptance_and_release_preparation`

## Recommended next task

真机验收持续进行，发现阻塞问题及时修复。

## AI agent 分工

- Claude Code：主线开发 / 提交 / 修复
- OpenCode：只读审计 / 第二意见 / 小范围 patch

## Explicitly forbidden now

- 不修改 app/lib（除非修复阻塞问题）
- 不修改测试
- 不修改 Drift schema
- 不修改 GitHub Actions
- 不启动 web-server
- 不大范围重构
- 不继续无限视觉微调
