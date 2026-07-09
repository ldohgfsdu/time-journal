# CURRENT_STATE

## Project

- Name: time-journal
- Type: Flutter 轻量时间管理手账 App
- Main path: ~/code/time-journal
- Main development branch: p0/journal-compare

## Current stage

**v0.1 可发：逻辑签收通过 + APK 已落 outbox + 实体机可拉起。**

产品定位：低压力时间手账；核心是「计划 vs 实际」的温和对照。  
MVP / P0–P2 功能基本完成。v0.1 结论见 `.memory/V0_1_RELEASE.md`。

### UI 工作流（硬规则）

- **UI 先 Web 预览，满意后再打包 APK**（见 RULES / DECISIONS）。
- 命令：`cd app && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081`
- 不要为试 UI 效果每轮等 CI APK。

## Latest known commit

- 分支：`p0/journal-compare`（与 origin 对齐；工作区应干净）
- 签收：`a8951a6`；代码基线 app：`d039a23`/`835e6bf`（其后仅 docs/memory）
- **v0.1 APK：** `/storage/emulated/0/outbox/time-journal/time-journal-arm64-d039a23-20260709-2232-v0.1.apk`  
  （同源 `…-1910.apk`，md5 `c247e9ef1a20a13d4b884eaea66947a7`）

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

- **无**
- v0.1：**可发**（逻辑门禁 + CI APK outbox）
- 残余非 blocker：人手 UI 五步烟测（MIUI 限制自动化）、跨夜睡眠人肉、`gh auth` 后可再拉 CI

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
