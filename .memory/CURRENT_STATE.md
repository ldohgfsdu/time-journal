# CURRENT_STATE

## Project

- Name: time-journal
- Type: Flutter 轻量时间管理手账 App
- Main path: ~/code/time-journal
- Main development branch: master

## Current stage

P0-5 / P1-7 已 squash 合入 master。P0-6 `linkedPlanId` 完成（最小 migration + 稳定匹配）。

## Latest known commit

- d32443c chore(memory): record PR #2 squash merge
- c120220 fix: P0-5 todo reorder + P1-7 sleep cross-midnight (PR #2 squash merge)

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
  - P0-6 linkedPlanId 最小 Drift migration + 匹配逻辑（actual 改时间仍稳定配对 planned；legacy fallback；5 条测试覆盖）
- P1 系列（全部关闭）
- UI polish 第一批（全部关闭）
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

- flutter analyze: No issues found
- flutter test: 42/42 passed（P0-6 follow-up after review comments）

## Release blockers

- （无，P0-6 linkedPlanId 已解决）

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
