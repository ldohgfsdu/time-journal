# ACTIVE_OBJECT

## Current stage

**功能收口完成 → 交付管道建设中 → 待真机签收 → 再决定 v0.1 发布。**

## Current objective

1. 用 `.memory/ACCEPTANCE_CHECKLIST.md` 完成真机签收（核心路径 1–6、9 全绿）。
2. 签收通过后再定义 / 冻结 v0.1 发布物（APK + 变更摘要 + 已知限制）。
3. 签收前 **功能面冻结**：只修验收 blocker，不开 P3 / 不大改 UI / 不改 schema。

## Active object name

`device_acceptance_then_v0_1_gate`

## Recommended next task

1. **UI 改动：Web 预览迭代**（`flutter run -d web-server`），满意后再打包。
2. 功能/验收：按 ACCEPTANCE_CHECKLIST；需要真机路径时再出 APK。
3. 签收通过后再写 v0.1 发布边界。

## Product reminder

- 定位：低压力时间手账。
- 核心：计划 vs 实际的温和对照。
- MVP / P0–P2 基本完成；主瓶颈是签收与发布定义，不是功能缺口。

## AI agent 分工

- OpenCode（主力）：免费，主线开发 / 审计 / 修复 / 提交
- Claude Code（付费备用）：DeepSeek 余额充足时使用
- Grok：图片审查 / 第二意见 / 识图
- Hermes：经 `agent` 菜单启动
- 终端输入 `agent` 打开启动菜单（全局 launcher，非本仓库）

## Release blockers

- 无 schema / P0-6 代码 blocker
- **门禁：** 真机清单核心项未全绿前，不得称 v0.1 可发

## Explicitly forbidden now（签收前冻结）

- 不做 P3 动效 / 更多白噪音 / 复杂拖拽安排
- 不做大 UI 重构、不继续无限视觉微调
- 不修改 Drift schema，除非用户明确授权
- 不新增第三条 APK 构建路径（主路径 CI→outbox；本机 build 仅 fallback）
- 不修改 GitHub Actions，除非用户明确要求调整 CI/自动打包策略
- 不启动 web-server（除非用户明确要求）
- 不大范围重构
- **只修验收 blocker**
