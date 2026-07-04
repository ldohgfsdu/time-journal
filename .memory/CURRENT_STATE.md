# CURRENT_STATE

## Project

- Name: time-journal
- Type: Flutter 轻量时间管理手账 App
- Main path: ~/code/time-journal
- Main development branch: p0/journal-compare

## Latest known commit

- a23f3bd fix(acceptance): resolve pomodoro and weekly polish issues

## Completed

- P0-1/P0-2 今日对照与按钮防重复
- P0-3 专注完成写入实际记录，linkedTodoId 贯通
- P0-4 `addActualFromPomodoro` 幂等性修复
- 真机验收修复批次 1：
  - Pomodoro 休息流程：专注完成后不强制进入 break，用户选择是否休息
  - Weekly 文案矛盾：专注/睡眠卡不再显示矛盾文案
  - 导出过滤：完全空 sleep record 不导出
  - TimePicker：统一 safeShowTimePicker + input entry mode
- Drift Web 支持
- Web 主题色修复
- UI polish 多批次

## Last known validation

- flutter analyze: passed (no issues found)
- flutter test: 105/105 passed

## Known notes

- 蓝色浏览器加载条是浏览器壳，不要做业务 hack。
- 8081 曾作为临时 Web 预览端口。
- Termux 外部存储运行 SQLite 测试会遇到 mmap/exec 限制。
- 主开发目录必须是 Ubuntu home 下的 ~/code/time-journal。
- /storage/emulated/0/time-journal 不是主开发目录。
- `copyPlannedToActual` 是死代码（零调用方），待后续清理。
- 所有 showTimePicker 调用已统一到 picker_helper.dart。
