# DECISIONS

## Long-term decisions

- 使用手机 Termux + Ubuntu/proot 开发。
- Termux 原生环境只做入口。
- Ubuntu/proot 的 root@localhost 是主开发环境。
- **`agent` 菜单已迁出仓库**（2026-07-08）：
  - 权威源：`~/.ai-tools/agent-launcher/`（与 deepseek-usage 同级，全局本地）
  - 通识：`AGENT_LAUNCHER.md`；各项目 AI 通过 AGENTS.md / ENVIRONMENT 引用，**勿**在 `~/code/*` 仓库内放 agent 脚本
  - Ubuntu `/root/bin/agent`；Termux `~/bin/agent` 薄包装；`bash ~/.ai-tools/agent-launcher/agent-install.sh` 同步
  - Termux：`~/bin/agent` 仅为薄包装（`~/.ai-tools/agent-launcher/agent-termux.sh` 安装副本），经 `proot-distro` 调用 Ubuntu 同一份逻辑
  - **改菜单只改 `~/.ai-tools/agent-launcher/agent.sh`，然后 `bash ~/.ai-tools/agent-launcher/agent-install.sh` 同步**
- Claude Code 接 DeepSeek API。
- 不依赖 Claude 官方 /login。
- 不保存完整历史对话，只保存结构化摘要。
- 项目记忆放在仓库内 .memory/。
- 小步改、小步测、小步提交。
- Web 预览和 APK 打包分开。
- 每轮结束更新 CURRENT_STATE 和 SESSION_LOG。
- DeepSeek API Key 只放在 Ubuntu home 的 ~/.deepseek-claude.env，不写进仓库。
- Cross-model project memory is shared through .memory/ and AGENTS.md.
- CLAUDE.md and .claude/ are Claude Code adapters only.
- Future OpenCode / Hermes / Grok workflows should read AGENTS.md and .memory/ before working.
- Do not rely on any single model's hidden conversation memory.

## 2026-07-09 — v0.1 签收结论（代码 + 自动化测试）

- 用户 scope：只做 v0.1 签收，核心路径 **1–6**；不扩 P3 / 不改 schema / 不改 UI 审美。
- 验证：`flutter analyze` clean；`flutter test` **150/150**；commit **`835e6bf`**。
- 结论：**v0.1 逻辑门禁通过（可发）** — 详见 `.memory/V0_1_RELEASE.md`、`.memory/ACCEPTANCE_CHECKLIST.md`。
- 待办 UI **拖拽有意移除**；清单 #2 对齐为「新建待办 + draft 不进持久排序」。
- 未提交的 4 个 UI 审美文件（theme / paper / section_card / main_shell）**revert**，不纳入 v0.1。
- 残余非 blocker：实体机覆盖安装冷启动、真实跨夜睡眠人肉。
- #9 以 sleep 自动化测试旁证通过（全量 suite 内）。

## 2026-07-09 — 阶段、冻结与交付主路径

### 产品与阶段

- 产品方向：**低压力时间手账**；核心是「计划 vs 实际」温和对照。
- 阶段表述（签收后）：  
  **功能收口完成 → 核心路径签收通过 → v0.1 可发（逻辑门禁）→ 打包/装机确认。**
- MVP / P0–P2 功能基本完成；**P0-6 `linkedPlanId` 已 done**，不再是 release blocker。

### 功能面冻结（相对 P3 / 大改）

- 不做 P3（动效、更多白噪音、复杂拖拽安排等）
- 不做大 UI 重构 / 无限视觉微调
- 不改 Drift schema（除非用户明确授权）
- 不新增第三条 APK 构建路径
- 签收期曾：**只修验收 blocker**（本轮无 blocker）

### v0.1 门禁

- 清单见 `.memory/ACCEPTANCE_CHECKLIST.md`
- **核心路径 1–6、9 全绿** 才允许称为 **v0.1 可发**
- **2026-07-09 已满足**（1–6 正式签收；#9 测试旁证）
- 发布结论与变更摘要：`.memory/V0_1_RELEASE.md`

### APK 交付路径（政策，唯一主路径）

```text
主路径：
  push 含 app/** → GitHub Actions arm64 release
  → bash scripts/fetch_arm64_apk_from_ci.sh（或 post_push / release 路由）
  → outbox（/storage/emulated/0/outbox/time-journal）

Fallback（不扩展、不新开第三条）：
  bash scripts/build_arm64_to_outbox.sh
  （CI 不可用，或本机 NDK 主机工具链明确可用时）
```

- Debug APK 不随日常 push 构建（仅 `workflow_dispatch`）
- 只改 `.memory/` / 文档 **不** 触发 APK CI
- 脚本实现细节可随环境微调，但 **政策上 CI→outbox 为主**；禁止再发明第三套打包流水线

### UI 预览 vs 打包（2026-07-09）

- **UI 设计迭代：Web 预览优先。** 改样式 / 布局 / 主题时，用 `flutter run -d web-server` 看效果；用户满意前 **不要** 每轮打包 APK。
- **打包时机：** 用户明确说「可以打包 / 装机复测 / 满意了」之后，再 push `app/**` 走 CI→outbox。
- 真机仅关键的能力（通知、部分音频、后台）可在定稿后用 APK 验证，不作为 UI 试错手段。
