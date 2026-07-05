# ACTIVE_OBJECT

## Current stage

真机验收与发布准备阶段。

## Current objective

MVP 缺口修补：第一、二轮已完成；release blocker 仅剩 P0-6 `linkedPlanId` migration（待解除 schema 禁令）。

## Active object name

`mvp_acceptance_and_release_preparation`

## Recommended next task

用户确认后解除 schema 禁令 → `linkedPlanId` migration（P0-6 release blocker）

## AI agent 分工

- Claude Code：主线开发 / 提交 / 修复
- OpenCode：只读审计 / 第二意见 / 小范围 patch

## Release blockers

- P0-6：今日对照 `planned`/`actual` 需 `linkedPlanId` 稳定关联（当前仅按 start/end 完全相等匹配）

## Explicitly forbidden now

- 不修改 Drift schema（P0-6 除外，需用户明确解除禁令后实施）
- 不修改 GitHub Actions
- 不启动 web-server
- 不大范围重构
- 不继续无限视觉微调
