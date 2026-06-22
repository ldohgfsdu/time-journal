# 时间管理手账 (Time Journal)

帮助提升执行力、养成专注、规范作息的移动应用。

## 项目结构

```
time-journal/
├── docs/PRD.md           # 产品需求文档
├── assets/reference/     # 参考图与静态素材
└── app/                  # Flutter 客户端
```

## 技术栈

- Flutter 3.x + Dart
- Riverpod（状态管理）
- go_router（路由）
- drift（SQLite 本地存储）

## 开发

```bash
cd F:\time-journal\app
F:\flutter\bin\flutter.bat pub get
F:\flutter\bin\flutter.bat run
```

## 模块

1. **手账** — 工字四区日程规划（待办 / 计划 / 实际 / 备注）
2. **番茄钟** — 专注计时与锁屏模式
3. **睡眠人生** — 作息养成、白噪音、睡眠分