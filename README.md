# time-journal｜时间管理手账

低压力时间手账 App。核心不是催促用户完成更多任务，而是帮助用户看清：**我原本打算怎么过，最后实际怎么过**。

当前实现方向：移动端优先、中文 UI、本地数据、计划 vs 实际对照复盘。

---

## 项目结构

```text
time-journal/
├── AGENTS.md             # Agent 入口规则：改代码前先读
├── README.md             # 项目说明
├── docs/
│   └── PRD.md            # 产品需求文档
├── 开发计划.txt           # 当前优化清单与执行优先级
├── assets/reference/     # 参考图与静态素材，只读
└── app/                  # Flutter 工程根目录
    ├── lib/
    │   ├── app/          # 主题、文案、通知、导航壳
    │   ├── data/         # Drift DB、repository、models
    │   └── features/     # journal / pomodoro / sleep / weekly / profile / shell
    ├── test/
    ├── assets/audio/     # 白噪音 wav，随 APK 打包
    ├── android/
    └── ios/
```

> 注意：Flutter 工程根目录是 `app/`，不是仓库根目录。所有 `flutter pub get / analyze / test / run` 都应在 `app/` 下执行。

---

## 产品定位

**一个低压力的时间管理手账，用“计划 vs 实际”帮助用户复盘一天。**

不是：

- 纯待办清单
- 打卡 KPI 工具
- 效率惩罚工具
- 复杂任务管理器

而是：

- 计划与现实的对照本
- 手机上的轻量手账
- 专注与作息的低压力辅助工具

核心原则：

1. **少填**：能自动生成的，不让用户重复写。
2. **少看**：一个页面只突出一个核心动作。
3. **对照**：计划和实际必须放在一起看。
4. **克制**：不过度游戏化，不过度统计化。
5. **温和**：不评价用户，只帮助用户看清自己。

---

## 技术栈

- Flutter 3.x + Dart，实际版本以 `app/pubspec.yaml` 与 `flutter --version` 为准
- Riverpod：状态管理
- Drift + SQLite：本地数据库，默认无云端
- go_router：路由能力，主壳当前使用 `MainShell` 底部导航
- flutter_local_notifications：通知
- just_audio：白噪音播放

不要在未评审的情况下替换核心技术栈。

---

## 快速开始

### Termux / ZeroTermux

建议把项目放在 Termux home 目录，避免长期在 `/storage/emulated/0` 下跑 `node_modules`、`.dart_tool`、`build` 等大量文件。

```bash
mkdir -p ~/code
cd ~/code
# 如果项目在 Git 仓库：
# git clone <repo-url> time-journal
cd time-journal/app

flutter pub get
flutter analyze
flutter test
```

Flutter Web Server 预览：

```bash
cd ~/code/time-journal/app
flutter config --enable-web
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

手机浏览器打开：

```text
http://127.0.0.1:8080
```

常用运行按键：

```text
r  Hot reload
R  Hot restart
q  Quit
```

### Windows 桌面

```powershell
cd F:\time-journal\app
flutter pub get
flutter analyze
flutter test
flutter run
```

如本机 Flutter 不在 PATH，可使用完整路径：

```powershell
F:\flutter\bin\flutter.bat pub get
F:\flutter\bin\flutter.bat run
```

---

## 构建说明

### Android Debug / Release

本地打包需要 Android SDK、Gradle toolchain、签名配置等完整环境。

```bash
cd app
flutter build apk --release
```

手机 Termux 侧默认不要求本地 release 构建。若 `flutter doctor` 显示 Android toolchain 不完整，优先用电脑、GitHub Actions、Codemagic 或其他云构建完成 APK/AAB。

### Drift 代码生成

涉及 Drift table / schema 变更后，在 `app/` 下执行：

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

数据库变更必须说明是否需要 migration。不要为了通过编译直接清空数据库、删除用户数据或绕过迁移。

---

## 模块

| 模块 | 路径 | 说明 |
|---|---|---|
| 手账 | `app/lib/features/journal/` | 今日待办、今日对照、统计、今天一句话 |
| 专注 | `app/lib/features/pomodoro/` | 专注计时、任务关联、完成后写入实际记录 |
| 睡眠 | `app/lib/features/sleep/` | 作息目标、睡眠打卡、白噪音、睡眠分 |
| 周报 | `app/lib/features/weekly/` | 周节奏热力图、复盘数据 |
| 我的 | `app/lib/features/profile/` | 设置、数据存储、关于、清数据入口 |
| 壳层 | `app/lib/features/shell/` | 底部导航与页面容器 |

---

## 当前开发优先级

当前版本优先解决体验闭环，不扩张功能面：

1. 首页从“计划完成 / 实际完成”改为“今日对照”。
2. 计划块增加“按计划完成 / 实际有变”。
3. 专注结束后可自动写入今日实际记录。
4. 首页减负，只保留待办、今日对照、今日统计、今天一句话。
5. 统一卡片、标题、颜色、字号和空状态文案。

详细任务见 `开发计划.txt`。

---

## Agent 工作流

改代码前先读：

1. `AGENTS.md`
2. `docs/PRD.md`
3. `开发计划.txt`
4. 与任务相关的 `app/lib/...` 文件

完成回复应包含：

1. 对应 P0/P1 条目
2. 修改文件列表
3. 已执行的验证命令
4. 未执行命令及原因
5. 是否涉及数据结构 / migration

---

## 不要提交 / 不要手改

不要提交：

```text
build/
.dart_tool/
.gradle/
android/.gradle/
android/build/
ios/Pods/
*.apk
*.aab
```

不要手改：

```text
android/local.properties
```

除非用户明确要求，不要删除 `app/assets/audio/`，不要改包名，不要引入账号后端。
