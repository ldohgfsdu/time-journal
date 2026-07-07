# CURRENT_STATE

## Project

- Name: time-journal
- Type: Flutter 轻量时间管理手账 App
- Main path: ~/code/time-journal
- Main development branch: p0/journal-compare

## Current stage

真机验收与发布准备阶段。MVP 缺口修补第一轮、第二轮完成（待办拖拽 + 睡眠跨午夜）。

## Latest known commit

- e07e674 Merge pull request #9 from ldohgfsdu/fix/planned-block-focus-planid

## Completed

- MVP 缺口修补 review follow-up（Grok 2026-07-06）：
  - `reorderTodos(scoped)`：重排后填回 scoped slots，全列表统一写 sortOrder
  - `resolveSleepDisplayRecord`：今天无实际记录时展示 24h 内最近 bedtime 记录
  - `checkInWakeTime`：重复 wake 写回近期 bedtime 记录，避免 wake-only orphan
- MVP 缺口修补第二轮（Grok 2026-07-06）：
  - 睡眠跨午夜：`checkInWakeTime` 优先补全 24h 内最近未闭合 bedtime 记录
  - 新增 `findRecentOpenBedtimeRecord` + `sleepOpenBedtimeMaxAge` 常量
  - 测试：跨午夜闭合、无 open fallback、stale 超窗不误补、同日行为、时长计算
- MVP 缺口修补第一轮（Grok 2026-07-06）：
  - `开发计划.txt` 状态表与 memory 对齐（P0/P1 标 done，新增 P0-5/P0-6/P1-7）
  - 待办拖拽：draft 不参与 ReorderableListView；UI 改调 `reorderTodos` + `scopedTodoIds`
  - `mapVisibleTodoReorder` 折叠列表索引映射；repository scoped reorder 保留 base sortOrder
  - 测试：`todo_reorder_test.dart` + `journal_repository_test` scoped reorder 用例
- P0 系列（全部关闭）：
  - P0-1/P0-2 今日对照与按钮防重复
  - P0-3 专注完成写入实际记录，linkedTodoId 贯通
  - P0-4 `addActualFromPomodoro` 幂等性修复
  - P0-5 待办拖拽 scoped + P0-6 linkedPlanId migration（PR #6 合入 p0/journal-compare）
- P1 系列（全部关闭）
- UI polish 第一批（全部关闭）
- P1 UI 收口最小补丁（Grok 2026-07-06）：
  - TimePicker 风格收口（dial 禁键盘 + 暖白/主色/圆角 theme）
  - 弹层 barrier 统一调轻（不压黑）
  - SnackBar 暖色圆角轻阴影（替代黑底）
  - 卡片/sheet 分割线减淡（仅色）
  - 验证：analyze clean；test 128/128；8 文件少量样式；无结构/无 migration
- 真机验收修复：Pomodoro actual 未挂 planned（Grok 2026-07-06）
  - addActualFromPomodoro 按 linkedTodoId 回填 linkedPlanId（insert/update/dedup）
  - 仅 repository 层；不改匹配逻辑、不 schema、不 UI
  - 新增 3 测试；analyze clean + 131/131 pass
- 真机验收修复批次 1：
  - Pomodoro 休息流程：专注完成后不强制进入 break，用户选择是否休息
  - Weekly 文案矛盾：专注/睡眠卡不再显示矛盾文案
  - 导出过滤：完全空 sleep record 不导出
  - TimePicker：统一 safeShowTimePicker + input entry mode
  - TimePicker 红屏已修
  - TimePicker 标题语义已补
- Drift Web 支持
- Web 主题色修复
- OpenCode 1.17.13 已安装，可通过 `opencode run` 运行
- MVP 审计代码修复批次（OpenCode 2026-07-05）：
  - PomodoroScreen `dynamic` → `PomodoroSession` 类型安全
  - ActualEditSheet 移除 `widget.slot.planned!` 强制解包，改用 nullable 防御
  - SleepProvider API 统一：`checkInWakeTime`/`checkInBedtime` 均接受 `AppDatabase`
  - 通知错误处理 `debugPrint` → `dart:developer` log + stacktrace 捕获
  - JournalScreen 控制器清理：`_clearAllTodoControllers()` 解耦
  - `time_utils.dart` 提取：`parseTime()`、`sumBlockMinutes()` 三处复用
  - SleepNoiseController `stop()` 修复：未清除 `selected` 导致状态残留
  - SleepNoiseController 测试（7 条）：初始/stop/volume/select/toggle/anti-race/dispose
- 系统完善批次（OpenCode 2026-07-05）：
  - `agent` 启动菜单：终端输入 `agent` 打开菜单，支持子命令直接启动
  - `agent` 命令注册到 Ubuntu/Termux PATH
  - Proxy 系统诊断：可正常启动转发，修复 stale PID 清理
  - COMMANDS.md 更新：去除 `timeout 180`，`agent` 替代 `claude` 作为入口
  - bug 修复：
    - `comparison_slot.dart` `hasPlan` 使用 `?.` 避免强制解包
    - `journal_repository.dart`:52 排序逻辑改用 `?.` + fallback `'00:00'`
    - `weekly_repository.dart`:95 双层 null 检查防空指针
    - `pomodoro_provider.dart`: 所有 Wakelock/Haptic 静默 catch 添加 `dev.log`
  - **platform-first 菜单实现**（OpenCode 2026-07-05 session 9）：
    - `agent` 菜单重构为"平台优先"模式：1-4 直接选平台启动（OpenCode/Claude Code/Claude Code Proxy/Grok）
    - 新增 5)切换项目+启动、6)新建项目（自动创建 .memory/ 骨架）
    - 新增 I/O 收件箱/发件箱、M 项目记忆、U AI 用量、P Proxy 管理
    - 修复 `pick_project_interactive` stdout 被 `$()` 捕获的 bug
    - `/root/bin/agent` 同步更新

## Last known validation

- flutter analyze: No issues found (clean)
- flutter test: 136/136 passed
- P0-6 linkedPlanId migration 已合入默认分支 (p0/journal-compare)
- P1 UI 收口 4 项最小补丁：analyze clean + 128/128 pass（Grok）
- Pomodoro actual linkedPlanId 修复：analyze clean + 131/131 pass（Grok）
- PR #7 follow-up: 修复 content-update 清空 linkedPlanId 风险，analyze clean + 132/132 pass（Grok）
- 合并 PR #7 到 p0/journal-compare：analyze clean + 132/132 pass（Grok）
- PR #8 合并到 p0/journal-compare：navigate/setLinkedTask 修复 + 真实测试 + 真机复测场景通过，analyze clean + 136/136 pass（Grok）
- 真机复测纠正诊断 + PR #9（Grok 2026-07-07）：
  - 根因：手动 planned block（无 linkedTodoId）从今日对照开始专注时未传 planId → orphan「番茄专注」
  - 修复：planned 卡片更多菜单新增「开始专注」→ navigateToFocusTab(task, planId, linkedTodoId)
  - PR #9 已合并到 p0/journal-compare（e07e674，2026-07-07）
  - 合并后验证：analyze clean；test 136/136 pass

## Release blockers

（无；P0-6 linkedPlanId 已合入 p0/journal-compare 作为默认主线）

## UI (Claude 暖色主题)

- theme.dart：Claude 色板（#FAF9F5 / #D97757）、圆角 20、卡片阴影
- paper_background：去掉横线纸纹，保留暖色渐变
- section_card / today_stats_card：白卡片 + 轻阴影，去掉左侧色条
- main_shell：悬浮圆角底栏
- profileThemeCurrent：Claude 暖色

## AI agent 分工

- OpenCode（主力）：免费，主线开发 / 审计 / 修复 / 提交
- Claude Code（付费备用）：仅 DeepSeek 余额充足时使用
- Grok：图片审查 / 第二意见
- 终端输入 `agent` 打开启动菜单

## Known notes

- 蓝色浏览器加载条是浏览器壳，不要做业务 hack。
- 8081 曾作为临时 Web 预览端口。
- Termux 外部存储运行 SQLite 测试会遇到 mmap/exec 限制。
- 主开发目录必须是 Ubuntu home 下的 ~/code/time-journal。
- /storage/emulated/0/time-journal 不是主开发目录。
- `copyPlannedToActual` 已清理。
- 所有 showTimePicker 调用已统一到 picker_helper.dart。
- OpenCode 配置见 opencode.jsonc；runbook 见 .external_outbox/opencode-runbook.md。

- Termux `agent` 菜单合并（2026-07-05 session 8）：替换旧 `claude` 入口为 `agent`，整合 OpenCode/Claude Code/Proxy/用量/validate/git/项目管理。`claude` 保留为 symlink。

- **2026-07-06 P0-6 converge**：PR #6 已合并到 p0/journal-compare（默认主线）。master 进入待归档/不再作为开发主线。仅数据层（schema 3 + linkedPlanId + 匹配逻辑），无 UI/GA/P2/P3 改动。
