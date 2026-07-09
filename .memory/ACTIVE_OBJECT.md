# ACTIVE_OBJECT

## Current stage

**v0.1 逻辑门禁已通过 → 可定义/打包发布物；P3 与无关扩 scope 仍冻结。**

## Current objective

1. （可选）用户装机确认冷启动 / 覆盖安装（清单 #1 残余）。
2. 需要装机包时：走 CI→outbox 主路径出带戳 APK（对应 `835e6bf` 或更新 commit）。
3. 对外分发前补完整 release notes / 版本号策略（见 `.memory/V0_1_RELEASE.md`）。

## Active object name

`v0_1_release_packaging`

## Recommended next task

1. 用户若要装机：`push`（若有 app 变更）→ CI arm64 → `fetch_arm64_apk_from_ci` → outbox。
2. 当前 HEAD 无未提交 app 代码时，可直接用已有 CI 产物或对 `835e6bf` 触发/拉取 APK。
3. **不要**重新打开 P3 / 大 UI / schema 变更，除非新开明确目标。

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
