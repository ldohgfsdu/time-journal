# ACTIVE_OBJECT

## Current stage

**v0.1 已装包到 outbox；可选人手 UI 五步确认后即日常自用。P3 仍冻结。**

## Current objective

1. （可选）用户打开 APK/应用，人手补：冷启动、待办、专注写回、planned 专注、今日对照。
2. 需要重打 CI 包时：`gh auth login` → `fetch_arm64_apk_from_ci --dispatch`。
3. 对外分发再开版本号/商店物料（非必须）。

## Active object name

`v0_1_shipped_optional_manual_smoke`

## Recommended next task

1. 从 outbox 安装 `time-journal-arm64-d039a23-20260709-2232-v0.1.apk`（若尚未覆盖到该包）。
2. 人手过一遍最小烟测五步（见 `V0_1_RELEASE.md`）。
3. **不要**重新打开 P3 / 大 UI / schema，除非新开目标。

## Product reminder

- 定位：低压力时间手账。
- 核心：计划 vs 实际的温和对照。
- MVP / P0–P2 完成；核心 1–6 签收通过。

## AI agent 分工

- OpenCode（主力）：免费，主线开发 / 审计 / 修复 / 提交
- Claude Code（付费备用）：DeepSeek 余额充足时使用
- Grok：图片审查 / 第二意见 / 识图
- Hermes：经 `agent` 菜单启动
- 终端输入 `agent` 打开启动菜单（全局 launcher，非本仓库）

## Release blockers

- 无

## Explicitly forbidden now

- 不做 P3 动效 / 更多白噪音 / 复杂拖拽安排
- 不做大 UI 重构、不无限视觉微调
- 不修改 Drift schema，除非用户明确授权
- 不新增第三条 APK 构建路径
- 不修改 GitHub Actions，除非用户明确要求
- 不启动 web-server（除非用户明确要求 UI 工作）
