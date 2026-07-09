# CURRENT_STATE

## Project

- Name: time-journal
- Type: Flutter 轻量时间管理手账 App
- Main path: ~/code/time-journal
- Main development branch: p0/journal-compare

## Current stage

**功能收口完成 → 交付管道建设中 → 待真机签收 → 再决定 v0.1 发布。**

产品定位：低压力时间手账；核心是「计划 vs 实际」的温和对照。  
MVP / P0–P2 功能基本完成。当前主瓶颈不是功能缺口，而是记忆对齐、真机签收与 v0.1 边界定义。

### UI 工作流（硬规则）

- **UI 先 Web 预览，满意后再打包 APK**（见 RULES / DECISIONS）。
- 命令：`cd app && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081`
- 不要为试 UI 效果每轮等 CI APK。

## Latest known commit

- `40fac38` fix(app): acceptance blockers — time wheel, focus journal match, noise, drop todo drag
- CI APK：outbox 仅保留带戳文件 `time-journal-arm64-{sha}-{时间}.apk`（最新见目录 mtime）
- 上一文档同步：`62cb170` docs(memory): sync MVP signoff state and release gates
- P0-6 合入：`linkedPlanId` migration 已在 `p0/journal-compare`（非 blocker）

## Completed（摘要）

### 产品功能（P0–P2）

- P0 全部 done：今日对照、按计划完成/实际有变、专注写 actual、首页减负、待办拖拽 scoped、`linkedPlanId`（P0-6）
- P1 全部 done：视觉统一、各页收口、睡眠跨午夜（P1-7）
- P2 全部 done：当前时段高亮、补记入口、滚轮选时、空态文案
- 番茄 ↔ 今日对照：PR #7/#8/#9（linkedPlanId 回填、navigate planId、防 detach）

### 交付与工程

- CI：`app/**` push → arm64 Release APK（`android-arm64-release.yml`）；debug 仅 workflow_dispatch
- Outbox 装包：`fetch_arm64_apk_from_ci` / `post_push_app` / `release_apk_to_outbox`
- 本机 `build_arm64_to_outbox` 为 **fallback**（arm64 proot NDK 常不可用）
- agent launcher 已迁出仓库：`~/.ai-tools/agent-launcher/`

### 历史批次（不删细节，见 SESSION_LOG）

- MVP 缺口修补、P1 UI 收口、白屏通知 try-catch、Claude 暖色主题等见 SESSION_LOG 2026-07-05～07

## Last known validation

- 记忆峰值：flutter analyze clean；flutter test 约 136/136（PR #8/#9 合并后）
- 2026-07-08 P2 / picker 修复后 CI analyze 曾修 unnecessary_import
- **真机签收：未正式完成**（见 `.memory/ACCEPTANCE_CHECKLIST.md`）

## Release blockers

- **无代码侧 P0-6 blocker**（linkedPlanId 已合入）
- **发布前门禁：** 真机验收清单核心路径 1–6、9 必须全绿（见 ACCEPTANCE_CHECKLIST）
- v0.1 边界尚未签收前，不称「可发」

## Feature freeze（签收前）

- 不做 P3（动效、更多白噪音、大拖拽等）
- 不做大 UI 重构 / 无限视觉微调
- 不改 Drift schema（除非用户明确授权）
- 不新增第三条 APK 构建路径
- 只修验收 blocker

## APK 交付路径（政策）

**主路径：** `push app/**` → GitHub CI arm64 release → `fetch_arm64_apk_from_ci` → outbox  
**Fallback：** `build_arm64_to_outbox.sh`（CI 不可用或本机 NDK 明确可用时）  
Outbox：`/storage/emulated/0/outbox/time-journal`（`.external_outbox/time-journal`）

## UI (Claude 暖色主题)

- theme.dart：Claude 色板（#FAF9F5 / #D97757）、圆角 20、卡片阴影
- paper_background：暖色渐变；main_shell 悬浮圆角底栏

## AI agent 分工

- OpenCode：主线开发 / 审计
- Claude Code：付费备用（DeepSeek）
- Grok：第二意见 / 识图（`agent vision`）
- Hermes：对话执行
- 终端：`agent`（全局 `~/.ai-tools/agent-launcher/`，勿写入本仓库 scripts）

## Known notes

- 主开发目录：`~/code/time-journal`（Ubuntu/proot）
- 不默认启动 web-server；不 /login；密钥不进仓库
- 评估全文（2026-07-09）：`.external_outbox/time-journal/project-assessment-2026-07-09.md`（不提交）
- 控制面同步轮（2026-07-09）：对齐 memory / 开发计划 P0-6 / 验收清单 / 交付主路径政策
