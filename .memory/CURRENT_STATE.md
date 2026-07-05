# CURRENT_STATE

## Project

- Name: time-journal
- Type: Flutter 轻量时间管理手账 App
- Main path: ~/code/time-journal
- Main development branch: p0/journal-compare

## Current stage

真机验收与发布准备阶段。MVP 功能开发已暂停，P0/P1/UI polish 第一批均已关闭。

## Latest known commit

- 15f1dc8 chore(memory): update state after opencode setup

## Completed

- P0 系列（全部关闭）：
  - P0-1/P0-2 今日对照与按钮防重复
  - P0-3 专注完成写入实际记录，linkedTodoId 贯通
  - P0-4 `addActualFromPomodoro` 幂等性修复
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

## Last known validation

- flutter analyze: No issues found
- flutter test: 105/105 passed

## AI agent 分工

- Claude Code：主线开发 / 提交 / 修复
- OpenCode：只读审计 / 第二意见 / 小范围 patch
- OpenCode TUI 手机键盘输入不稳定，推荐暂时使用 `opencode run`

## Known notes

- 蓝色浏览器加载条是浏览器壳，不要做业务 hack。
- 8081 曾作为临时 Web 预览端口。
- Termux 外部存储运行 SQLite 测试会遇到 mmap/exec 限制。
- 主开发目录必须是 Ubuntu home 下的 ~/code/time-journal。
- /storage/emulated/0/time-journal 不是主开发目录。
- `copyPlannedToActual` 是死代码（零调用方），待后续清理。
- 所有 showTimePicker 调用已统一到 picker_helper.dart。
- OpenCode 配置见 opencode.jsonc；runbook 见 .external_outbox/opencode-runbook.md。
