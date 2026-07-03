# Time Journal — Agent Entry Point

Flutter 时间管理手账。Agent 改代码前必须先读本文与任务相关文档；本文只定义工作边界、路径约束和验证协议，不替代 PRD、开发计划或 `pubspec.yaml`。

## Boot（每次会话）

1. 读 `docs/PRD.md` — 产品边界与模块定义。
2. 读 `开发计划.txt` — 当前 UI/交互优化优先级，优先处理 P0。
3. 确认 Flutter 工程根目录是 `app/`，不是仓库根目录。
4. 改 UI 前读：
   - `app/lib/app/theme.dart`
   - `app/lib/app/copy.dart`
5. 改数据前读：
   - `app/lib/data/local/database.dart`
   - `app/lib/data/local/tables.dart`
6. 若上述文件缺失、路径不一致，或文档之间出现冲突，先停止并向用户报告；不要猜测路径、不要自行新建替代文件、不要静默对齐。

## 工程路径

```text
time-journal/
├── AGENTS.md           # 本文件
├── docs/PRD.md         # 产品需求
├── 开发计划.txt         # 优化清单与优先级
├── assets/reference/   # 参考图，只读
└── app/                # Flutter 工程根；pub get / analyze / test / run 在此执行
    ├── lib/
    │   ├── app/        # 主题、文案、通知、导航壳
    │   ├── data/       # Drift DB、repository、models
    │   └── features/   # journal | pomodoro | sleep | weekly | profile | shell
    ├── test/
    ├── assets/audio/   # 白噪音 wav，随 APK 打包
    ├── android/
    └── ios/
```

项目名统一使用 `time-journal`。若本地目录名、仓库名或用户输入出现 `time-jounl` 等拼写漂移，只把它视为本地路径差异；不要把文档、包名或产品名改成错误拼写。

## 技术栈（勿擅自替换）

- Flutter 3.x；Dart SDK 版本以 `app/pubspec.yaml` 与本机 `flutter --version` 为准。
- Riverpod（状态管理）。
- Drift + SQLite（本地 `time_journal.db`，无云端）。
- go_router 已在依赖中；主壳当前用 `MainShell` 底部导航。
- 通知：`flutter_local_notifications`。
- 音频：`just_audio` + `assets/audio/*.wav`。

不得未经用户明确要求替换技术栈，例如把 Riverpod 换成 Bloc、把 Drift 换成 Hive/Isar、把本地数据库改成云端服务。

## 产品约束

- 核心价值：**计划 vs 实际对照复盘**，不是纯待办勾选。
- 语气低压力、暖色手账感；见 `AppTheme`、`AppCopy`。
- 数据仅存本机；不要引入需账号的后端，除非用户明确要求。
- 中文 UI；`locale: zh_CN`。
- UI 改动优先减负、统一节奏、减少重复录入，不追求堆功能。

## 模块职责

| 模块 | 路径 | 职责 |
|------|------|------|
| 手账 | `features/journal/` | 工字四区、今日对照、待办/计划/实际 |
| 番茄钟 | `features/pomodoro/` | 专注计时、与手账任务联动 |
| 睡眠 | `features/sleep/` | 作息、白噪音、睡眠分 |
| 周报 | `features/weekly/` | 周回顾与活动条 |
| 我的 | `features/profile/` | 设置、清数据 |

修改时按模块收口。除非用户明确要求跨模块重构，否则一次任务只改一个主模块，并说明受影响的边界文件。

## 当前 P0（来自开发计划）

1. 合并计划/实际为「今日对照」，减少重复录入。
2. 计划块增加「按计划完成」「实际有变」。
3. 首页减负、统一各页视觉。
4. 周报数据更有解释力。

Agent 任务应标明落在哪条 P0/P1；不要一次改完全部模块。若任务不属于当前 P0/P1，先说明它为什么仍然值得做，或询问用户是否调整优先级。

## 数据与 Drift 约束

- 涉及 Drift table/schema 变更时，必须说明是否需要 migration。
- 不得为了通过编译直接清空数据库、重建库、删除用户数据或绕过 migration。
- 表结构变更后，在 `app/` 目录执行：

```bash
cd app
dart run build_runner build --delete-conflicting-outputs
```

- 只改 repository/model 时，也要确认是否影响已有测试与 mock 数据。

## Mobile / Termux 开发约束

手机端主要用于轻量编辑、结构检查、`flutter analyze`、`flutter test` 和 Web Server 预览；不默认执行 release APK 构建。

Web 预览优先使用：

```bash
cd app
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

浏览器访问：

```text
http://127.0.0.1:8080
```

除非 Android SDK/toolchain 已确认可用，不要默认执行：

```bash
flutter build apk --release
```

不要扫描或修改 `build/`、`.dart_tool/`、`.gradle/`、大体积音频/图片资源，除非任务明确要求。

## 验证

所有 Flutter 命令默认在 `app/` 目录执行：

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run          # 需设备、模拟器或 web-server
```

需要构建 APK 且本机 Android toolchain 可用时：

```bash
cd app
flutter build apk --release
```

如果某条验证命令未执行，必须在回复里说明原因，例如：设备不可用、Android SDK 缺失、耗时过长、任务只涉及文档。

## 不要

- 不要改 `app/android/local.properties`（本机生成）。
- 不要提交 `build/`、`.dart_tool/`、`.gradle/`。
- 不要删除 `app/assets/audio/` 或改包名，除非用户明确要求。
- 不要 push 到远程，除非用户明确要求。
- 不要在没有任务边界的情况下全仓大扫、全模块重构或批量格式化无关文件。
- 不要把参考图 `assets/reference/` 当成可改设计稿；它们只读。

## 任务写法（给用户）

好的 agent 任务示例：

> 在 `features/journal/` 实现开发计划 P0-1：把计划完成和实际完成合并为「今日对照」时间线。只改 journal 模块，保持现有 Drift 表；完成后跑 `flutter test`。

应包含：**目标模块、引用开发计划条目、范围边界、验证命令**。

## 完成回复格式

每次完成任务后，回复必须包含：

1. 对应 P0/P1 条目。
2. 修改文件列表。
3. 已执行的验证命令。
4. 未执行命令及原因。
5. 是否涉及数据结构 / migration。
6. 对产品体验的影响：这次修改减少了什么摩擦、统一了什么规则，或修复了什么风险。
