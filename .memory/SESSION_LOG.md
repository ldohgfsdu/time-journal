# SESSION_LOG

## 2026-07-06 (session 3)

- **P1 UI 收口审查最小补丁**（Grok）：
  - 仅 P1 UI 4 项：不切分支、不改数据/GA/业务/新功能
  - 1. TimePicker：禁用 input 键盘模式（dial），theme 化暖白 paper 背景、主色 tomato 按钮/指针、圆角20、ink 文字
  - 2. 弹层遮罩：统一 bottom sheet / dialog barrierColor 调为 0x33000000（~20%），背景退后不压黑
  - 3. SnackBar：通过 snackBarTheme 全局改为暖色 card 背景、圆角12、轻阴影 elevation 2；“这一段守住了，已记入今天”等提示不再黑底
  - 4. 分割线减淡：dividerTheme 改用更淡的 divider 色 (EDE6DB)，仅颜色调整；卡片/sheet 内部 Divider 生效
  - 仅改样式参数 + 8 个 show 调用 barrier；无结构、无 migration、无业务逻辑
  - 验证：flutter analyze 无问题；flutter test 128/128 passed
  - 修改文件 8 个，纯样式收口

- **推送到 GitHub**（供实机测试）：
  - commit b174e67 已 push 到 origin/p0/journal-compare
  - 用户可 git pull 后在真机 flutter run / 安装测试 UI 收口效果
  - 未做 release 构建（按约束）

## 2026-07-06 (session 4)

- **修复 Pomodoro actual 未挂回 planned block**（Grok）：
  - 现象：planned「健身」显示未记录，但实际产生 orphan actual「番茄专注」（短时长无法 legacy time 匹配）
  - 根因：addActualFromPomodoro 只写 linkedTodoId，未写 linkedPlanId
  - 修复（最小，仅 repository 层）：
    - 在 addActualFromPomodoro 中，若 linkedTodoId != null，查询当日同 linkedTodoId 的 planned，取得其 id 作为 linkedPlanId
    - insert 时写入；update content 时 backfill；dedup 命中时也 backfill（若需要）
    - 无匹配 planned 时保持原 orphan 行为
  - 不改 _matchActual (P0-6 逻辑)、不改 schema、不改 UI、不改其他
  - 新增测试 3 条：
    1. 正常 link：create todo+planned → addActual(short time) → snapshot.comparisonSlots 中 planned 带 actual，linkedPlanId 正确，无 orphan
    2. backfill update：先插入 linkedTodoId 但 linkedPlanId=null 的 actual → 再 addActual → linkedPlanId 被更新
    3. 无匹配保持 orphan：linkedTodoId null 或无 planned → linkedPlanId 仍 null，产生 orphan
  - 验证：flutter analyze 无问题；flutter test 131/131 passed（含原测试）
  - 修改文件：仅 journal_repository.dart + journal_repository_test.dart
  - migration：否

- **PR #7 follow-up 修复 detach 风险**（Grok）：
  - 问题：在 content update 路径中，无条件 `linkedPlanId: Value(linkedPlanId)`，当本次 linkedPlanId==null 时会清空已有 actual 的 linkedPlanId（detach 风险）
  - 最小修复：仅在 update content 路径中，如果 linkedPlanId != null 才设置，否则使用 Value.absent() 保留原值
  - dedup 路径已有 guard，insert 保持原样
  - 新增测试：'addActualFromPomodoro content update does not clear existing linkedPlanId when no matching planned'
    - 先创建 planned + 带 linkedPlanId 的 actual
    - 删除 planned 模拟本次无匹配
    - 调用 addActual（命中 update 路径，content 变化）→ content 更新，但 linkedPlanId 保留
  - 只改 journal_repository.dart + journal_repository_test.dart + memory
  - 不改 UI/schema/match 逻辑等
  - 验证：flutter analyze: No issues found；flutter test: 132/132 passed
  - migration: no ; UI: no
  - 已 push 到 fix/pomodoro-actual-linked-plan (PR #7)

## 2026-07-06 (session 5) - 合并 PR #7

- **合并 PR #7 到 p0/journal-compare**（Grok）：
  - git checkout p0/journal-compare && git pull
  - git merge --no-ff fix/pomodoro-actual-linked-plan
  - merge commit: 747a59e
  - 包含：
    - 初始 linkedPlanId 回填
    - 内容更新路径 guard (使用 absent() 避免 detach)
    - 4 个测试覆盖 link / backfill / orphan / no-clear 场景
  - 验证命令：
    - cd app && flutter analyze → No issues found
    - cd app && flutter test → 132/132 passed
  - 真机复测模拟（通过 repo 测试复现场景）：
    - create todo + planned（健身 21:20-22:20 linkedTodoId）
    - addActualFromPomodoro（番茄专注 21:20-21:21 linkedTodoId）
    - load snapshot → planned 卡片下显示 actual，无 orphan
  - 符合预期：不再 "健身待补 + orphan actual"
  - 未改 UI / schema / GA
  - 未切 master
  - 已更新 CURRENT_STATE / SESSION_LOG

## 2026-07-06 (session 2)

- **白屏修复**（Claude Code）：
  - 用户反馈 Android 覆盖升级后启动白屏
  - 排查：flutter analyze clean、128/128 test pass、web build 成功
  - 根因分析：`main()` 中 `LocalNotificationService.instance.initialize()` 若抛异常，会阻止 `runApp()` 执行，Android splash screen 显示白色导致"白屏"
  - 修复：`main.dart` 中通知初始化包裹 try-catch，失败时仅 `dev.log` 记录，不阻断 app 启动
  - 验证：analyze clean、128/128 test pass
  - 未做：无法获取 logcat 确认根因；建议用户重新构建 APK 测试

## 2026-07-06 (session 1)

- **Claude 风格 UI 设计落地**（Grok）：
  - 更新 `theme.dart`：Claude 暖色色板、排版 token、输入框/底栏主题
  - `paper_background` 去掉横线纸纹
  - `section_card` / `today_stats_card` 白卡片 + 轻阴影
  - `main_shell` 悬浮圆角底栏
  - `action_pill_button` 胶囊按钮微调
  - `profileThemeCurrent` → Claude 暖色
  - 验证：flutter analyze 0 issues；flutter test 113/113

## 2026-07-05 (session 9)

- **platform-first 菜单实现**（OpenCode）：
  - `agent` 菜单重构为"平台优先"模式：1-4 直接选平台启动（OpenCode/Claude Code/Claude Code Proxy/Grok）
  - 新增 5)切换项目+启动、6)新建项目（自动创建 .memory/ 骨架）
  - 新增 I/O 收件箱/发件箱、M 项目记忆、U AI 用量、P Proxy 管理
  - 修复 `pick_project_interactive` stdout 被 `$()` 捕获的 bug
  - 验证：Syntax OK；菜单显示正确；项目切换/Git 状态/Proxy 管理/新项目创建均测试通过
  - `/root/bin/agent` 同步更新
  - CURRENT_STATE.md 同步更新

## 2026-07-05 (session 8)

- Termux `agent` 菜单重构（session 8）：
  - 第一次迭代：替换旧 `claude` 为 `agent` symlink，合并基础功能
  - 第二次迭代（重新设计）：
    - 菜单为核心，平台优先：1-4 直接选平台启动
    - 设计原则：平台优先 · 项目隔离 · 共享记忆 · I/O 通路
    - 新增 inbox/outbox 查看功能
    - 新增项目切换（会话内切换 DEFAULT_PROJECT）
    - 平台启动函数化，方便扩展
    - 每个平台在项目目录内启动，读取项目 `.memory/`
    - 删除冗余脚本：`claude-check`、`claude-proxy`
    - `claude` 保留为 `agent` symlink
  - 第三次迭代（工作流优化）：
    - 项目切换后直接选平台（`pick_platform`），一步到位
    - 验证完自动显示 git 状态
    - inbox/outbox 可输入文件名查看内容（显示大小 + 前 100 行）
    - 新增 M) 查看项目记忆（CURRENT_STATE + ACTIVE_OBJECT）
    - 新建项目后可直接选择平台启动
    - 菜单简化：项目行合并为 5+6，工具行重新编排
    - 更新 ENVIRONMENT.md

## 2026-07-05 (session 7)

- OpenCode 提权为主力开发工具
- 创建 `agent` 启动菜单脚本 (`scripts/agent.sh`)，注册到 Ubuntu/Termux PATH
  - 支持交互菜单和子命令直接启动（opencode/claude/grok/usage/proxy/validate/git）
  - 更新 COMMANDS.md/ENVIRONMENT.md/CURRENT_STATE.md 反映新入口
- Proxy 系统诊断：
  - 确认 proxy 可正常启动和转发请求
  - 修复 `proxy-start.sh` stale PID 自动清理
- bug 修复：
  - `comparison_slot.dart` `hasPlan` 改用 `?.` 避免 `!` 强制解包
  - `journal_repository.dart:52` 排序逻辑使用 `?.` + `'00:00'` fallback 防空指针
  - `weekly_repository.dart:95` 双层 null 检查（`sleep != null && sleep.actualBedtime != null`）
  - `pomodoro_provider.dart` 7 处 Wakelock/Haptic `catch(_){}` 添加 `dev.log` 错误记录
- 验证：analyze No issues found；test 113/113 passed

## 2026-07-05 (session 6)

- MVP 审计代码修复批次（OpenCode）：
  - Task 1: `pomodoro_screen.dart:526` — `dynamic session` → `PomodoroSession`
  - Task 2: `actual_edit_sheet.dart:51` — 移除 `widget.slot.planned!` 强制解包，nullable 防御
  - Task 3: `sleep_provider.dart` — `checkInWakeTime`/`checkInBedtime` 统一接受 `AppDatabase`，调用方自行 `ref.invalidate`
  - Task 4: `journal_screen.dart` — 提取 `_clearAllTodoControllers()`，`_shiftDate`/`dispose` 共用
  - Task 5: 创建 `app/lib/core/utils/time_utils.dart`，三处复用 `parseTime()`/`sumBlockMinutes()`
  - Task 6: `sleep_noise_provider_test.dart` (7 条测试) + 修复 `stop()` 未清 `selected` 的 bug
  - 通知错误处理：`debugPrint` → `dart:developer` log + stacktrace 捕获
- 关键决策：`checkInWakeTime`/`checkInBedtime` 均接受 `AppDatabase` 而非 `WidgetRef`，避免测试中 mock WidgetRef 的复杂度
- 验证：analyze No issues found；test 113/113 passed（原 105 + 新增 8 条）

## 2026-07-05 (session 5)

- 非阻塞问题修复批次（OpenCode 只读审计后修复）：
  - 通知错误处理：3 处 `debugPrint` 替换为 `catch(_) {}`，与非关键路径代码库一致模式。
  - 清理死代码：删除 `copyPlannedToActual`（零调用方）。
  - 版本号同步：`copy.dart` v1.0.2 → 1.0.2+3。
  - CURRENT_STATE commit hash 同步至 25ad8f7。
  - RULES.md 移除 `timeout 180`（环境不支持）。
  - intl 升级尝试：Flutter SDK 锁定 0.20.2，无法升级，已回退。
- 验证：analyze No issues found; test 105/105 passed。

## 2026-07-05 (session 4)

- Grok Build CLI 安装完成：
  - 安装 Grok Build CLI 0.2.82（linux-aarch64）via `curl -fsSL https://x.ai/cli/install.sh | bash`。
  - 二进制路径：`/root/.local/bin/grok` → `/root/.grok/bin/grok`。
  - 发现设备码登录（`grok login --device-auth`），完美支持 headless/Termux 环境。
  - 在任意浏览器打开 URL + 输入 4 位验证码即可完成 OAuth 登录，不需要本机浏览器。
  - 发现 `--prompt-json` / `--prompt-file` flag，可能支持 headless 图片输入。
  - 更新 `.external_outbox/grok-runbook.md` 反映实际安装状态和设备码登录流程。
  - 不改 app/lib、测试、Drift schema；不走 API key。

## 2026-07-05 (session 3)

- Grok Build 账号登录接入准备：
  - Grok CLI 未安装（需 `curl -fsSL https://x.ai/cli/install.sh | bash`）。
  - 无浏览器环境，登录需跨机器拷贝 `~/.grok/` 或 SSH 转发完成 OAuth。
  - Headless `grok -p` 官方支持；CLI 图片输入仅 TUI 模式（拖拽/粘贴/@-mention），headless 图片支持未文档化。
  - 新增 `.external_outbox/grok-runbook.md`（安装、登录、图片审查流程、提示词模板、Claude Code/OpenCode/Grok 分工）。
  - 不走 API key 方案；不写 XAI_API_KEY；不改 app/lib、测试、Drift schema。
  - 不提交（`.external_outbox` 在 .gitignore）。

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

## 2026-07-06 Grok — MVP 缺口修补第一轮

- 同步 `开发计划.txt` 状态表：P0-1～P0-4、P1-1～P1-6 标 done；新增 P0-5（done）、P0-6（blocked/release blocker）、P1-7（睡眠跨午夜 todo）
- 待办拖拽修复：
  - draft todo 单独渲染，不进入 `ReorderableListView`
  - UI 改调 `JournalRepository.reorderTodos` + `scopedTodoIds`
  - 新增 `core/utils/todo_reorder.dart` 处理折叠可见列表 → 全量 scope 索引映射
- 验证：`flutter analyze` 无问题；`flutter test` 119/119 通过
- 未做：Drift schema / `linkedPlanId` / 睡眠跨午夜（留第二轮）

## 2026-07-06 Grok — MVP 缺口修补第二轮（P1-7 睡眠跨午夜）

- `checkInWakeTime`：优先补全 `sleepOpenBedtimeMaxAge`（24h）内最近未闭合 bedtime 记录；无匹配则 fallback 当天
- 新增 `findRecentOpenBedtimeRecord`；`checkInBedtime`/`checkInWakeTime` 支持可选 `now` 参数（测试用）
- 测试新增 5 条：跨午夜闭合、fallback、stale 超窗、同日、跨夜时长
- 验证：`flutter analyze` 无问题；`flutter test` 124/124 通过
- 未做：Drift schema / P0-6 `linkedPlanId`

## 2026-07-06 Grok — P0-5/P1-7 review follow-up (9d8299a)

- reorderTodos(scoped)：重排 scoped 后填回原 slots，全列表 0..n-1 写 sortOrder
- resolveSleepDisplayRecord + findRecentBedtimeRecordNear：跨夜 wake 后展示前一晚完整记录
- checkInWakeTime：24h 内近期 bedtime（含已闭合）优先，避免 repeat wake 产生 orphan
- 验证：flutter analyze 无问题；flutter test 127/127 通过；已 push `p0/journal-compare`

## 2026-07-06 Grok — 合并 PR #6 到 p0/journal-compare (P0-6 converge)

- 使用正常 merge 合并 PR #6（chore/converge-p0-master → p0/journal-compare），未改 PR 内容
- 合并后 `git checkout p0/journal-compare && git pull`
- 在 app/ 执行：
  - flutter pub get
  - dart run build_runner build --delete-conflicting-outputs
  - flutter analyze（clean）
  - flutter test（128/128 passed）
- 确认：
  - schemaVersion 3 + linkedPlanId migration 仍在
  - 今日对照匹配逻辑（_matchActual 优先 linkedPlanId，legacy fallback 仅 unlinked）仍在
  - ComparisonSlot.status（content+time）仍在
- 更新 .memory/CURRENT_STATE.md 和 .memory/SESSION_LOG.md：
  - P0-6 linkedPlanId migration 已合入默认分支
  - flutter analyze clean
  - flutter test 128/128 passed
  - master 进入待归档/不再作为开发主线
- 严格遵守：不修改 GitHub Actions，不做 UI，不做 P2/P3
- 验证命令全部在 app/ 下执行；仅数据 + 记忆文件更新
- 当前主线：p0/journal-compare（4ea00a9）

## 2026-07-07

- **Pomodoro 关联问题（真机复测 PR#7 后）**（Grok）：
  - 现象：planned「睡觉」待补 + orphan actual「番茄专注」；sheet 显示默认「番茄专注」
  - 诊断（代码检查）：
    1. PomodoroScreen TodoPickChips 未传 selectedId（仅候选项）
    2. chip onPick 正确 setLinkedTask(..., todoId)
    3. startFocus 写 linkedTodoId 到 session
    4. _completeFocusSession 捕获 linkedTask / linkedTodoId
    5. recordPendingToJournal 传给 addActual
    6. chip 来自 todayTodosProvider（todo）；planned「睡觉」通过 linkedTodoId 关联
  - 根因：navigateToFocusTab（from journal todo action）只传 task name，未带 todoId → linkedTodoId 空 → PR#7 回填未触发；有时 task 也空导致默认「番茄专注」
  - 修复（最小）：
    - navigateToFocusTab 接受/转发 todoId + planId
    - journal _openTodoActions onFocus 传 item.id
    - PomodoroState/PendingFocusCompletion 增加 linkedPlanId（内存，不改 sessions schema）
    - setLinkedTask 支持 planId
    - addActualFromPomodoro 接受 linkedPlanId（优先直传，否则 todo lookup）
    - 补 selectedId 让 chip 显示选中（用已有视觉逻辑）
    - 内容更新/回填/guard 保持 PR#7 逻辑
  - 满足测试要求：
    1. 选中 todo chip → content = todo 内容（非「番茄专注」）
    2. 选中后 actual 挂回同 linkedTodoId planned
    3. planned 来源可直传 linkedPlanId 写入 actual
    4. 未选仍 orphan「番茄专注」
  - 未改：UI风格、schema、GA、大重构；PR#7 测试未破
  - 新分支 fix/pomodoro-linked-todo-plan，PR #8 开立（未合并）

PR #8: https://github.com/ldohgfsdu/time-journal/pull/8

- **合并 PR #8 到 p0/journal-compare**（Grok 2026-07-07）：
  - git checkout p0/journal-compare && git pull
  - git merge --no-ff fix/pomodoro-linked-todo-plan
  - merge commit: ce016aa
  - 包含 PR #8 全部修复 + 4 个真实测试
  - 验证：
    - cd app && flutter analyze → No issues found
    - cd app && flutter test → 136/136 passed
  - 真机复测模拟（运行 linked task and plan 组测试，覆盖“睡觉” todo/计划 → focus → complete → record → 今日对照）：
    - journal todo focus action 保留 task + linkedTodoId
    - record 后 content 非默认“番茄专注”
    - actual 挂回 planned
    - direct planId 优先
    - 无选仍 orphan（符合预期）
  - 符合预期：不再 orphan，planned 下显示 actual，sheet 用正确内容
  - 未改 UI/schema/GA
  - 未切 master
  - memory 更新，当前主线 p0/journal-compare

当前 HEAD: ce016aa + memory 更新

## 2026-07-07 (session 1)

- **真机复测纠正诊断 + PR #9**（Grok）：
  - 纠正：「睡觉」planned 是手账/今日对照手动安排，非睡眠页、非 todo；0 项待办 + 2 时段场景
  - 根因：PR #8 修了 todoId 链路，但手动 planned block 无 todoId，且今日对照 planned 卡片无「开始专注」入口 → Pomodoro 无 planId → orphan「番茄专注」
  - 修复（最小 UI）：
    - `today_comparison_section.dart`：planned 卡片 ⋯ 菜单新增「开始专注」（仅 isToday）
    - 调用 `navigateToFocusTab(ref, task: planned.content, planId: planned.id, todoId: planned.linkedTodoId)`
  - 测试：`pomodoro_provider_test.dart` 新增/强化手动 planned 无 linkedTodoId 场景（pending/actual/comparisonSlots/无 orphan）
  - 验证：flutter analyze clean；flutter test 136/136 passed
  - 分支：fix/planned-block-focus-planid
  - PR #9 OPEN：https://github.com/ldohgfsdu/time-journal/pull/9（base p0/journal-compare，未合并）
  - 未改 schema/GA/master；未自动化冒充真机复测

当前 HEAD: c6c59e7 on fix/planned-block-focus-planid

## 2026-07-07 (session 2)

- **合并 PR #9 到 p0/journal-compare**（Grok）：
  - merge commit: e07e674
  - PR #9 state=MERGED, closed=true, merged_at=2026-07-07T02:31:35Z
  - 合并后 flutter analyze clean；flutter test 136/136 passed
  - origin/p0/journal-compare 已同步；git status clean
  - 未改 UI/schema/GA；未切 master

当前 HEAD: e07e674 on p0/journal-compare

## 2026-07-08 (session 1)

- **安装 Hermes Agent CLI（环境工具，非项目改动）**：
  - NousResearch Hermes Agent v0.18.1，官方一键脚本安装
  - 安装路径：/usr/local/lib/hermes-agent；命令链接 /usr/local/bin/hermes
  - 数据/配置：/root/.hermes/（config.yaml、.env、sessions、logs）
  - 跳过交互 setup（--skip-setup）与浏览器下载（--skip-browser），按需 `hermes setup`/`hermes doctor` 补装
  - 用途：独立 AI agent 工具，与本项目 time-journal 无关
  - 后续需 `hermes setup --portal` 或 `hermes model` 配置 provider
  - agent 菜单平台区：原「3) Claude Code (Proxy)」替换为「3) Hermes」；新增 HERMES 变量/has_hermes/launch_hermes；`agent <项目> hermes` 直接启动；帮助文本同步；DeepSeek proxy_menu 保留
  - 未改项目代码/schema/GA；未提交

## 2026-07-08 (session 2)

- **问题**：用户 Termux 输入 `agent` 仍见旧菜单（Claude Code Proxy），因只改了 Ubuntu `/root/bin/agent`，未改 Termux 脚本。
- **根因**：`agent` 有两份独立脚本 — Termux `~/bin/agent`（日常入口）与 Ubuntu `/root/bin/agent`（proot 内直接运行）。
- **修复**：
  - 同步 Termux `/data/data/com.termux/files/home/bin/agent`：主菜单 3 → Hermes；新增 `launch_hermes`；`agent hermes` 子命令；`bash -n` 通过
  - 修复断链：`~/.local/bin/agent` → `/root/bin/agent`
- **记忆写入**（防再犯）：
  - DECISIONS.md：双副本决策
  - ENVIRONMENT.md：路径表、同步检查命令、当前菜单结构
  - COMMANDS.md：Start + 改菜单 checklist
  - RULES.md / CURRENT_STATE.md：同步提醒
- 未改项目代码/schema/GA；仅 `.memory/` 文档更新

## 2026-07-08 (session 3)

- **统一 agent 菜单**：
  - 权威源：`scripts/agent.sh`（合并 proxy 子命令、help、self-test、工具优先 CLI）
  - Termux：`scripts/agent-termux.sh` 薄包装（proot → `/root/bin/agent`），替换原 700+ 行独立脚本
  - 安装：`scripts/agent-install.sh` 同步 Ubuntu + Termux
  - 记忆更新：DECISIONS / ENVIRONMENT / COMMANDS / RULES / AGENTS / CURRENT_STATE
- 未改 Flutter 代码/schema/GA

## 2026-07-08 (OpenCode)

- **agent 菜单改版（scripts/agent.sh）**：
  - 平台启动函数去掉 `exec`，改为前台运行；退出平台/TUI 后回到主菜单循环（Ubuntu Shell 选项改为 `bash --login` 也返回）。
  - 菜单美化：加 ANSI 颜色（无 TTY 自动关闭）、标题框、青色「选择平台」框 + 黄色「操作」框，内宽固定 48、整行 52 对齐。
  - 平台项不可用（如未安装）灰显 + 🔒，但保留编号。
  - 新增 box_top / box_top_y / box_bot_* / box_row2 / plat_item 辅助函数。
  - 已 `bash scripts/agent-install.sh` 同步到 /root/bin/agent 与 Termux 包装。
  - 注：claude 本体已安装（2.1.204），但运行态「用不了」属其自身（登录/API）问题；菜单改为退出后回菜单，不再 exec 逃逸。

## 2026-07-08 (Hermes / Grok session — boot + 记忆对齐)

- 用户执行 **boot**：读取 .memory/*、`memory_boot.sh`；报告 drift，未擅自改代码。
- **记忆对齐**（用户要求）：
  - `ACTIVE_OBJECT.md`：P0-6 / PR #9 状态与 CURRENT_STATE 一致；release blockers 清空；推荐任务改为真机复测 + 可选提交 agent 脚本；AI 分工与 CURRENT_STATE 统一。
  - `CURRENT_STATE.md`：Latest known commit → c04ea86；补充工作区未提交说明。
- 未改 app/lib、schema、GA；未提交 git。

## 2026-07-08 (Hermes — agent 与项目隔离)

- 用户要求：`agent` 存本机、与项目无关，但所有 AI 通识；勿弄乱工作区。
- 已建立全局目录 `~/.ai-tools/agent-launcher/`（`agent.sh`、`agent-termux.sh`、`agent-install.sh`、`AGENT_LAUNCHER.md`）。
- 项目内：`AGENTS.md`、DECISIONS、ENVIRONMENT、RULES、COMMANDS、ACTIVE_OBJECT、CURRENT_STATE 改为指向全局路径；`.gitignore` 忽略 `scripts/agent*.sh`；`.shared_inbox/agent-launcher-pointer.md` 作跨项目指针。
- 待用户本地执行（曾拒批一键命令）：`bash ~/.ai-tools/agent-launcher/agent-install.sh`；可选删除 `time-journal/scripts/agent*.sh` 副本。
- **2026-07-08 续**：用户同意后已跑 `agent-install.sh` + ad-hoc `hermes-verify-agent-isolation.sh` 全部 OK；已删除仓库内 `scripts/agent*.sh` 副本。
- **提交 GitHub**：b1437f9 `chore(memory): align release state and document global agent launcher` → push `origin/p0/journal-compare`。
- 未改 Flutter 代码。

## 2026-07-08 — 清理 Git 分支

- 用户确认删除非主线分支；保留 `p0/journal-compare`（b1437f9）。
- 已删本地 + `origin`：`chore/converge-p0-master`，`fix/*`（pomodoro/planned/p0-5），`ui/claude-warm-polish`，`release/android-arm64-action`，`master`。
- 远程现仅 `origin/p0/journal-compare`（`origin/HEAD` 仍指向该分支）。CI 工作流已在主线上（`android-arm64-release.yml` 等）。

## 2026-07-08 — CI 自动打包 + 默认 push

- 用户要求：以后默认 push；`app/` 改动自动构建 APK。
- `android-arm64-release.yml` / `android-debug-apk.yml`：增加 `push` → `p0/journal-compare`，`paths: app/**`（及对应 workflow 文件）。
- RULES / COMMANDS / AGENTS：提交后默认 `git push`；说明仅 app 改动触发 CI。

## 2026-07-08 — Grok CLI 识图 ↔ Hermes

- 用户：Hermes 无 vision，希望联动 grokcli 识图。
- 全局（非仓库）：`~/.ai-tools/agent-launcher/grok-vision.sh`；`agent vision` / `grok-vision`；`agent-install` 已同步；`AGENT_LAUNCHER.md` 说明。
- 项目文档：`AGENTS.md`（Hermes 应跑 `agent vision`）、`.memory/ENVIRONMENT.md`。
- 全局（非仓库）：`grok-vision.sh` 支持 `inbox`；`agent vision inbox`。
- 项目：`scripts/ensure_inbox_links.sh`、`.external_inbox` → `/storage/emulated/0/inbox/time-journal`；识图扫描 inbox 根目录 + 项目子目录（用户现把图放在 inbox 根也可）。

## 2026-07-08 — P2-1 / P2-2 今日对照交互

- `comparison_time.dart`：当前时段判定、列表置顶、补记时间窗建议。
- `today_comparison_section`：无计划空档「当前没有计划」卡；补记默认上一段结束→现在。
- `schedule_sheet`：catchUp 可传入起止时间。
- 测试：`comparison_time_test.dart`（本机无 flutter CLI，待 CI 跑全量）。
- `开发计划.txt`：P2-1、P2-2 → done。

## 2026-07-08 — P2-3 滚轮选时 + P2-4 文案

- `TimeWheelRow` + `picker_helper` 底部滚轮；`schedule_sheet` 内嵌开始/自定义结束滚轮。
- `weeklySleepEarly(0)` 温和文案；`time_wheel_test.dart`。
- `开发计划.txt`：P2-3、P2-4 → done。

## 2026-07-08 — Android SDK 本机安装

- `setup_android_sdk_termux.sh` + `install_android_sdk_packages.sh`；`android_sdk.env` 本地生成。

- `build_arm64_to_outbox.sh`；`post_push_app` / `round_close_app`；`ci_wait_install_arm64.sh` 保留为可选。

- Gradle cache + concurrency cancel-in-progress；`pre_push_app_check.sh`。

## 2026-07-08 — CI Analyze 修复（422d629）

- 失败：`picker_helper.dart` `unnecessary_import`（cupertino），`flutter analyze` exit 1。
- 修复：删掉多余 import；本地 analyze + time_wheel_test 通过。

## 2026-07-08 — CI 只自动 arm64 Release

- 用户：日常只要 arm64，debug 太大。
- `android-debug-apk.yml`：去掉 `push`，仅 `workflow_dispatch`。
- README / RULES / COMMANDS / CURRENT_STATE 同步说明。
