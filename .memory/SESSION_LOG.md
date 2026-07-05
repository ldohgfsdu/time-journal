# SESSION_LOG

## 2026-07-05 (session 2)

- 记忆同步：修复 CURRENT_STATE / ACTIVE_OBJECT drift。
  - OpenCode 只读审计误判当前阶段为"MVP 功能缺口审计前"，已更正为"真机验收与发布准备阶段"。
  - 实际状态：P0/P1/UI polish 第一批均已关闭；真机验收已开始；analyze clean；105/105 passed。
  - 明确 AI agent 分工：Claude Code 主线开发/提交/修复；OpenCode 只读审计/第二意见/小范围 patch。
  - 未改 app/lib、测试、Drift schema、GitHub Actions。

## 2026-07-05 (session 1)

- OpenCode 接入准备完成：
  - 安装 OpenCode 1.17.13（curl 安装脚本，linux-arm64）。
  - 新增 `opencode.jsonc` 项目配置，instructions 指向 AGENTS.md + .memory/*。
  - 新增 `.external_outbox/opencode-runbook.md`（安装状态、启动方式、安全规则、分工说明）。
  - 未改 app/lib、测试、Drift schema。
  - 提交 2064a40 chore(ai): add opencode project config。

## 2026-07-03

- Claude Code installed and restored in Ubuntu/proot.
- 全局 proxy 修复：`~/.ai-tools/deepseek-usage/deepseek_proxy.py` — 修复 `/anthropic/anthropic` 双重路径前缀 bug，增加 `upstream_url` 日志字段。Proxy 透传模式现已正常转发到 DeepSeek。模型字段和 body 不做修改，无敏感信息泄露。
- Termux one-command `claude` entry created.
- DeepSeek API connected to Claude Code.
- Flutter Web preview ran successfully.
- Drift Web support fixed.
- P0-1/P0-2 completed: journal comparison and action anti-double-tap.
- P0-3 completed: pomodoro completion writes actual TimeBlock with linkedTodoId.
- Web theme color fixed to warm paper color.
- Multiple UI polish batches completed:
  - DEBUG banner hidden
  - weekly navigation refined
  - journal empty states refined
  - paper red line removed
  - TimePicker unified
  - loading indicators warmed
  - pomodoro custom duration added
- Latest known commit:
  2e0655e feat(sleep): record actual wake time
- P0 系列完成情况：
  - 原 P0-1 (幂等性): `addActualFromPomodoro` 已去重 (ea5d657)
  - 原 P0-2 (actualWakeTime): `checkInWakeTime` + 起床按钮 + 睡眠时长 (2e0655e)
  - 待 P0: WeeklyRepository / ComparisonSlot 测试覆盖
- MVP 审计复核完成（.external_outbox/mvp-audit-2026-07-03.md）
- 发现 Drift bug: `insertOnConflictUpdate` 按主键 `id` 做冲突检测，对 `sleep_records`（unique on `date`）无效；改用 `update + where` 模式
- 真机验收修复批次 1 完成 (a23f3bd)。
  1. Pomodoro 休息流程：专注完成后不强制进入 break，用户选择是否休息。
  2. Weekly 文案矛盾：专注/睡眠卡不再显示矛盾文案。
  3. 导出过滤：完全空 sleep record 不导出。
  4. TimePicker：统一 safeShowTimePicker + input entry mode。
- 测试覆盖：105/105 通过。
