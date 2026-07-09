# CURRENT_STATE

## Project

- Name: time-journal
- Type: Flutter 轻量时间管理手账 App
- Main path: ~/code/time-journal
- Main development branch: p0/journal-compare

## Current stage

**功能收口完成 → 核心路径 1–6 签收通过 → v0.1 逻辑门禁满足（可发）。**

产品定位：低压力时间手账；核心是「计划 vs 实际」的温和对照。  
MVP / P0–P2 功能基本完成。v0.1 结论见 `.memory/V0_1_RELEASE.md`。

### UI 工作流（硬规则）

- **UI 先 Web 预览，满意后再打包 APK**（见 RULES / DECISIONS）。
- 命令：`cd app && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081`
- 不要为试 UI 效果每轮等 CI APK。

## Latest known commit

- `e404c61` docs(memory): v0.1 acceptance sign-off for core paths 1-6
- 签收依据代码 HEAD：`835e6bf`（无 app 业务 diff；签收仅 memory）
- 分支：`p0/journal-compare`
- 签收轮（2026-07-09）：**无 app 代码变更**；4 个未提交 UI 审美文件已 revert；工作区干净
- 历史验收 blocker 修复：`40fac38`（时间轮 / 专注记入 / 白噪音 / 去拖拽）等已合入

## Completed（摘要）

### 产品功能（P0–P2）

- P0 全部 done：今日对照、按计划完成/实际有变、专注写 actual、首页减负、`linkedPlanId`（P0-6）
- P1 全部 done：视觉统一、各页收口、睡眠跨午夜（P1-7）
- P2 全部 done：当前时段高亮、补记入口、滚轮选时、空态文案
- 番茄 ↔ 今日对照：PR #7/#8/#9（linkedPlanId 回填、navigate planId、防 detach）
- **待办 UI 拖拽：有意移除**（长按=菜单；repo reorder 保留）

### 签收（2026-07-09）

- 核心路径 **1–6 全绿**（代码路径 + 自动化测试）
- #9 睡眠跨午夜：全量测试旁证通过
- 清单：`.memory/ACCEPTANCE_CHECKLIST.md`
- 发布结论：`.memory/V0_1_RELEASE.md` → **v0.1 可发（逻辑门禁）**

### 交付与工程

- CI：`app/**` push → arm64 Release APK；debug 仅 workflow_dispatch
- Outbox 装包：`fetch_arm64_apk_from_ci` / `post_push_app` / `release_apk_to_outbox`
- 本机 `build_arm64_to_outbox` 为 **fallback**
- agent launcher 已迁出仓库：`~/.ai-tools/agent-launcher/`

## Last known validation

- 2026-07-09 签收轮：`flutter analyze` **No issues found**；`flutter test` **150/150 passed**
- 路径：`/root/dev/flutter/bin/flutter`

## Release blockers

- **无代码 blocker**
- v0.1 逻辑门禁：**已满足**（核心 1–6 + #9 测试旁证）
- 残余非 blocker：实体机覆盖安装冷启动、真实跨夜睡眠人肉（见清单已知限制）

## Feature freeze（相对 P3 / 大改）

- 不做 P3（动效、更多白噪音、大拖拽等）
- 不做大 UI 重构 / 无限视觉微调
- 不改 Drift schema（除非用户明确授权）
- 不新增第三条 APK 构建路径
- 签收通过后：可写 release 边界 / 出 APK；仍避免无关扩 scope

## APK 交付路径（政策）

**主路径：** `push app/**` → GitHub CI arm64 release → `fetch_arm64_apk_from_ci` → outbox  
**Fallback：** `build_arm64_to_outbox.sh`  
Outbox：`/storage/emulated/0/outbox/time-journal`（`.external_outbox/time-journal`）

## UI (Claude 暖色主题)

- theme.dart：Claude 色板（#FAF9F5 / #D97757）、圆角 20、卡片阴影
- paper_background：暖色渐变；main_shell 悬浮圆角底栏
- 2026-07-09：曾有未提交审美微调 → **已 revert**，不纳入 v0.1

## AI agent 分工

- OpenCode：主线开发 / 审计
- Claude Code：付费备用（DeepSeek）
- Grok：第二意见 / 识图（`agent vision`）
- Hermes：对话执行
- 终端：`agent`（全局 `~/.ai-tools/agent-launcher/`，勿写入本仓库 scripts）

## Known notes

- 主开发目录：`~/code/time-journal`（Ubuntu/proot）
- 不默认启动 web-server；不 /login；密钥不进仓库
- Flutter：`/root/dev/flutter/bin/flutter`
