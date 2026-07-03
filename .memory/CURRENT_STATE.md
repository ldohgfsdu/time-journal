# CURRENT_STATE

## Project

- Name: time-journal
- Type: Flutter 轻量时间管理手账 App
- Main path: ~/code/time-journal
- Main development branch: p0/journal-compare

## Latest known commit

- ea5d657 fix(journal): make pomodoro actual recording idempotent

## Completed

- P0-1/P0-2 今日对照与按钮防重复
- P0-3 专注完成写入实际记录，linkedTodoId 贯通
- P0-4 `addActualFromPomodoro` 幂等性修复（按时间段+linkedTodoId+content 去重）
- Drift Web 支持
- Web 主题色修复
- UI polish:
  - 周报导航
  - 首页纸张红线移除
  - 待办空状态压缩
  - 今日对照重复内容修复
  - 专注 2×2 布局
  - 专注自定义时间
  - TimePicker 统一红棕暖色
  - loading 暖色化

## Last known validation

- flutter analyze: passed (no issues found)
- flutter test: 11/11 passed (journal 8 + sleep 3 + widget 1)

## Known notes

- 蓝色浏览器加载条是浏览器壳，不要做业务 hack。
- 8081 曾作为临时 Web 预览端口。
- Termux 外部存储运行 SQLite 测试会遇到 mmap/exec 限制。
- 主开发目录必须是 Ubuntu home 下的 ~/code/time-journal。
- /storage/emulated/0/time-journal 不是主开发目录。
- `copyPlannedToActual` 是死代码（零调用方），待后续清理。
