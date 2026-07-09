# Claude → time-journal 移动端适配简报

> **范围**：手账 App（Flutter，~390pt 宽手机），**不是** claude.com 营销站拷贝。  
> **源规范**：仓库根 `DESIGN.md`（Claude / Anthropic warm-canvas editorial）。  
> **现状基线**：`app/lib/app/theme.dart` 已对齐大部分 hex；UI 仍混用旧语义（`tomato` / `paper` / `sleepBlue`）与过重字重、阴影、嵌套边框。  
> **本文件只指导实现**；不直接改 Dart。

---

## 1. Claude 风格在「手机手账」上意味着什么

### 气质一句话

**暖奶油纸 + 克制珊瑚点缀 + 编辑式标题（少量衬线）+ 扁平色块分层** —— 像一本安静的纸质手账，不是 AI 营销站，也不是冷灰生产力工具。

### Do（移动端）

| 原则 | 具体做法 |
|------|----------|
| **奶油画布** | 页面底永远是 `canvas` `#faf9f5`；区块可用 `surfaceSoft` `#f5f0e8` 或 `surfaceCard` `#efe9de`，禁止纯白 `#FFFFFF` 大面积铺底。 |
| **衬线极省** | 仅用于「日期头」「分区标题」两处编辑时刻；字重 **400（regular）**，略负字距；**绝不**全屏衬线。 |
| **Inter 做 UI** | 待办正文、按钮、Tab、chip、AppBar、统计数字：全部 **Inter / 系统 humanist sans**，字重以 **400 / 500** 为主。 |
| **Coral 稀缺** | `primary` `#cc785c` 只给：主 CTA（开始专注、就寝打卡等一次一屏主操作）、inline text-link、当前时段的极轻 tint。禁止每张卡一条珊瑚竖条、禁止 Tab 选中满珊瑚、禁止一堆 coral fill chip。 |
| **色块分层，少阴影** | 深度来自 cream ↔ card ↔ dark 对比，**不是** `BoxShadow`。卡片默认：`surfaceCard` 或 lifted cream + 1px `hairline` `#e6dfd8`，shadow alpha ≤ 0.04 且尽量去掉。 |
| **圆角层级** | 按钮/输入 `8`（`radiusMd`）；内容卡 `12`（`radiusLg`）；大 hero/沉浸容器 `16`（`radiusXl`）；badge 才用 pill。 |
| **触控** | 主按钮高度 ≥ 44（可接受 40 对齐 DESIGN）；列表行可点区域 ≥ 44 高；不要 28×28 图标当主操作。 |
| **暗面节制** | `surfaceDark` `#181715` **只**用于专注沉浸态（产品 chrome），以及极少数「强调统计」条；手账/睡眠默认保持 cream。 |
| **节奏** | 屏内区块间距 8–16；卡内 padding 12–16（手机），**不要**搬 96px section / 32px desktop card 间距。 |

### Don't（移动端）

| 禁止 | 原因 |
|------|------|
| 把 `display-xl` 64px 衬线搬到手机 | 手账不是落地页 hero；手机日期用 24–28 足够。 |
| 全站衬线 / 全站 Inter 标题无层次 | 丢「编辑时刻」；或反过来像默认 Material。 |
| Coral 当「第二品牌色」到处铺 | DESIGN：coral 稀缺；到处用会变廉价番茄酱 UI。 |
| Sleep 用 teal 当整页主色 | `accent-teal` `#5db8a6` 只做状态点/次要语义；主 CTA 仍应 coral 或 ink-outline。 |
| 纯黑 `#0A0A0A` / 冷灰 canvas | 沉浸态用暖黑 `surfaceDark` `#181715` + `onDark` `#faf9f5`。 |
| 字重 w600 / w700 当默认强调 | Claude display 是 400；UI 强调最多 500。w700 让小屏吵。 |
| 卡片套卡片 + 双边框 + 阴影 | 嵌套 elevation 是当前「丑」的主因之一。 |
| 营销站 footer / CTA band / 三栏 feature grid | 无产品对应；不要为像 Claude 而加装饰带。 |
| 把 Anthropic spike logo 硬塞进 Tab | 非品牌 App；可用极小装饰于「关于」，不要当导航图标。 |

### 与网站的刻意差异

| DESIGN.md（站） | time-journal（App） |
|-----------------|---------------------|
| 96px section 节奏 | 8–16 列表节奏 |
| Copernicus 全站 h1–h3 | 仅日期 + Section 标题 |
| 全幅 coral callout band | 单行 SnackBar / 轻 tint 横条即可 |
| 多页 cream→dark 交替 | 单页以 cream 为主；dark 仅专注沉浸 |
| 40px 桌面按钮 | 主操作 44–52 高全宽更安心 |

---

## 2. 主屏组件映射

### Token 速查（实现时只用 `AppTheme.*`，弃用语义别名于新代码）

| Token | Hex | 用途 |
|-------|-----|------|
| `canvas` | `#faf9f5` | Scaffold / 页面底 |
| `surfaceSoft` | `#f5f0e8` | 弱分区、chip 默认底 |
| `surfaceCard` | `#efe9de` | feature 级卡片底（统计、次要信息块） |
| `surfaceCreamStrong` | `#e8e0d2` | 选中 tab / 强调 band |
| `hairline` | `#e6dfd8` | 1px 边框 |
| `hairlineSoft` | `#ebe6df` | 卡内 divider |
| `primary` | `#cc785c` | 主 CTA、稀缺强调 |
| `primaryActive` | `#a9583e` | press |
| `primarySoft` | `#f3e6df` | **极少** 选中 chip 底（非满屏） |
| `ink` / `body` / `muted` / `mutedSoft` | `#141413` / `#3d3d3a` / `#6c6a64` / `#8e8b82` | 字色阶 |
| `surfaceDark` / `onDark` / `onDarkSoft` | `#181715` / `#faf9f5` / `#a09d96` | 专注沉浸 |
| `accentTeal` | `#5db8a6` | 睡眠状态点、成功邻域；**非**整页主色 |
| `success` / `warning` / `error` | `#5db872` / `#d4a017` / `#c64545` | 语义 |

---

### 2.1 底栏 · `MainShell` (`main_shell.dart`)

| 元素 | 现况 | Claude 移动映射 |
|------|------|-----------------|
| 容器 | `card` 半透明 + top hairline | `canvas` 不透明 / 0.98，`hairline` 顶线；**无阴影** |
| 选中态 | `primarySoft` 底 + **coral 图标/字** | 对齐 `category-tab-active`：底 `surfaceCard` `#efe9de`，图标/字 **`ink`**；未选 `mutedSoft` |
| 标签字号 | 11 | 11–12，`w500` 选中 / `w400` 未选（`nav-link` 缩小版） |
| 图标 | Material rounded | 保持 outline/filled 切换；**不要**换成 spike logo |
| 沉浸隐藏 | focus/break 隐藏 tab bar | 保持；沉浸 scaffold 用 `surfaceDark` |

---

### 2.2 手账 · `JournalScreen` + 子组件

| 元素 | Widget | 现况 | 目标 |
|------|--------|------|------|
| 页面底 | `Scaffold` + `PaperBackground` | canvas→surfaceSoft 竖向渐变 | **保留**轻渐变 OK；或纯 `canvas`。不要回 lined-paper |
| AppBar | `AppBar` | 居中「手账」sans 17 w500 | 保持 Inter；`ink`；无 elevation；左右 chevron 用 `button-icon-circular` 气质（36 圆、hairline 可选，或纯 IconButton ink） |
| 日期头 | `_DateHeader` | `headlineSmall` 22 **sans w500** | **衬线 display-sm 缩尺**：24–26px / w400 / letterSpacing -0.3；`ink`。星期/摘要：Inter 13 `muted` |
| 待办区 | `SectionCard` + todo rows | 见 SectionCard | 标题衬线或 title-sm；「添加」→ secondary 小按钮（canvas+hairline）或 text-link coral，**非**整颗 coral soft pill 刷存在感 |
| 对照区 | `TodayComparisonSection` | 嵌套 `_SlotCard` 双边框 + tomato tint | 外层 `SectionCard` 一次边框即可；`_SlotCard` **去边框**改 hairlineSoft 分隔或仅 `surfaceSoft` 底；「现在」用 `badge-pill`（`surfaceCard`+ink）而非 coral 小条堆叠 |
| 空状态补记 | `EmptyAddSlot` | 虚线 coral 边 | hairline dashed + `muted` 字；加号可用 coral **单色图标**（唯一电压） |
| 统计 | `TodayStatsCard` | 已用 `surfaceCard`，较好 | 标题改 14–15 w500 Inter；数字 tabular；**不要**再包 SectionCard 样式阴影 |
| 随记 | `SectionCard` + `TextField` | underline focus | 保持 underline 或 none；focus 用 coral 1.5px（已有 theme） |
| 完成区 | `SectionCard` opacity 0.72 | 可保留 dim | 标题 `muted`，正文 `mutedSoft`，去掉额外 opacity 滤镜更干净 |

**`SectionCard` 专项（全局影响最大）**

| 现况 | 问题 | 目标 |
|------|------|------|
| `color: card` `#fffcf7` | 接近白，偏「抬起卡片」非 Claude card | 默认 `surfaceCard` `#efe9de` **或** canvas + hairline（二选一统一）；推荐 **canvas 底 + hairline** 做内容卡，`surfaceCard` 留给统计/强调 |
| `boxShadow` alpha 0.03 blur 12 | 系统偏好 color-block | **删除 shadow** |
| 左侧 3×18 **coral 竖条** | coral 滥用 | **删除**；标题靠字重/衬线建立层级 |
| 标题 16 w500 Inter | 可接受 | 可选：衬线 17–18 w400；或 Inter title-sm 16 w500 |
| 内部分割 `hairlineSoft` | OK | 保留 |

---

### 2.3 对照槽 · `_SlotCard` / `_StatusChip` / `ActionPillButton`

| 元素 | 现况 | 目标 |
|------|------|------|
| 当前槽底 | `tomatoSoft` 0.35 + tomato 边 | 极轻 `primarySoft` 0.4 **或** `surfaceCreamStrong`；边用 `hairline`，不要双边强调 |
| 任务名 | 16 **w700** | 16 **w500** `ink` |
| 时间 | 13 w600 muted | 13 w500 muted + tabular |
| 状态 chip | tagBg + 11 w600 | `badge-pill`：`surfaceCard`/`surfaceSoft`，13→11 可，**w500** |
| 「现在」badge | coral soft + 10 w600 | 同上 pill；文案色 `ink` 或 `primary` 二选一（全文件统一） |
| 操作 | `ActionPillButton` coral soft fill | **Secondary**：canvas/透明 + hairline + ink 字；**仅主操作**（如「按计划完成」）可用 coral fill compact |
| 空提示标题 | 15 w600/w700 | 15 w500 |

---

### 2.4 专注 · `PomodoroScreen`

#### Idle（`_buildIdleBody`）

| 元素 | 现况 | 目标 |
|------|------|------|
| 页底 | 默认 scaffold canvas | canvas；可选轻微 `PaperBackground` 与手账一致 |
| AppBar | 「专注」 | 同手账 AppBar 规范 |
| 任务提示 | 15 w600 | 14–15 w500 `body`/`ink` |
| 任务输入容器 | card + radius 12 + rule | `text-input`：canvas、hairline、`radiusMd` 8、高 ≥ 40 |
| 大倒计时 | 72–80，`w300`，**coral** | Idle 用 **ink** 或 `bodyStrong` 大号 tabular（coral 留给「开始」按钮）；字重 300–400；**非衬线** |
| `DurationChip` | 选中 primary 边 + check | 对齐 `category-tab`：未选 surfaceSoft+hairline；选中 `surfaceCard` 或 creamStrong + **ink** 字（不要整颗变珊瑚描边过重） |
| 主按钮 | `FilledButton` coral 全宽 48 | **保留**为屏内唯一 primary；高 48–52，`radiusMd` 8，label 14–16 w500 |
| 历史标题 | 15 w600 | 15 w500；可作 Section 小标题 |

#### Immersive（focus / break）

| 元素 | 现况 | 目标 |
|------|------|------|
| 背景 | `#0A0A0A` 纯黑 | **`surfaceDark` `#181715`**（product-mockup-dark） |
| 标签/任务 | white alpha | `onDark` / `onDarkSoft`（暖奶油白，非纯白） |
| 计时数字 | coral 80 w300 | 可保留 coral 作为暗面唯一电压，**或** `onDark`；二选一全沉浸统一 |
| 次要按钮 | white54 | `onDarkSoft` |
| 下一轮主按钮 | white 0.15 fill | `surfaceDarkElevated` `#252320` + `onDark`（`button-secondary-on-dark`） |
| 弃置长按 | 白边 | 对齐 onDark 边线 |

---

### 2.5 睡眠 · `SleepScreen` header 与主操作

| 元素 | 现况 | 目标 |
|------|------|------|
| Hero 容器 | `sleepMist` `#e8f2f0` + 边框 | **不要**冷青绿大色块。改：`surfaceCard` 或 `surfaceSoft` + hairline；周点用 `accentTeal` **仅点** |
|  streak 文案 | `sleepBlue` 15 w600 | `ink` 15 w500；辅助 `muted` 13 |
| 日程大字 | 20 **w700 sleepBlue** | **衬线或 Inter 22 w400/w500** + `ink`；tabular 时间；teal 仅「已打卡」小状态 |
| 主 CTA 就寝 | **满宽 teal** 52 radius 14 | **改 coral primary**（全局唯一主色叙事）；高 48–52，`radiusMd` 8 |
| 次 CTA 醒来 | teal outline radius 14 | ink/hairline `OutlinedButton` 主题默认 |
| 噪音 chip / slider | teal 强调 | 选中态 surfaceCard+ink；播放中可用 teal **小点**；Slider active 可用 teal 或 primary（统一一种） |
| `SleepWeekDots` | （依赖组件） | 点：亮 `accentTeal`/`success`，灭 `hairline`；容器不铺 mist |

睡眠的「安静」来自 cream + 少色，**不是**另立蓝色品牌。

---

### 2.6 我的 · `ProfileScreen` / 周报

| 元素 | 现况 | 目标 |
|------|------|------|
| 列表行 | 默认 List/自定义 tile | canvas 底；行间 hairlineSoft；标题 16 w500 ink；副标 13 muted |
| 关于/弹层标题 | 18 w700 | 18 w500 或衬线 20 w400 |
| 危险操作 | danger 色 | `error` `#c64545` 仅文字/outline，不要大红底大块 |
| `WeeklyScreen` | w700 标题 | 同 Section 标题规范 |

---

## 3. 移动端字号表（落地用）

**字体加载建议**（`pubspec` 已有 `google_fonts`，但代码未用）：

- Display serif：`GoogleFonts.cormorantGaramond` 或 `ebGaramond`（DESIGN 推荐开源近似），**仅**下列「衬线」行。
- UI：`fontFamily: 'Inter'`（theme 已设）或 `GoogleFonts.inter`。

| 角色 | Token 名（App） | 字体 | Size | Weight | Height | Tracking | 使用处 |
|------|-----------------|------|------|--------|--------|----------|--------|
| 日期显示 | `mobile.display-date` | **Serif** | **24–26** | **400** | 1.2 | -0.3 | `_DateHeader` 日期 |
| 分区标题 | `mobile.section-title` | **Serif** 或 Inter | **17–18** | **400** serif / **500** Inter | 1.25 | -0.2 | `SectionCard.title`；可选睡眠日程大时间用 serif |
| AppBar 标题 | `mobile.appbar` | Inter | **17** | 500 | 1.3 | -0.2 | 各页 AppBar（已接近） |
| 卡片内标题 | `mobile.title-sm` | Inter | **16** | 500 | 1.4 | 0 | 槽任务名、设置行标题 |
| 正文 | `mobile.body` | Inter | **15–16** | 400 | 1.5 | 0 | 待办输入、对照说明 |
| 次正文 | `mobile.body-sm` | Inter | **13–14** | 400 | 1.45 | 0 | 副标题、统计行、hint |
| 说明/caption | `mobile.caption` | Inter | **12–13** | 500 | 1.4 | 0 | badge、Tab 标签、出勤 hint |
| 按钮 | `mobile.button` | Inter | **14–15** | 500 | 1.0 | 0 | Filled/Outlined |
| 倒计时 idle | `mobile.timer-idle` | Inter | **64–72** | 300–400 | 1.0 | 1–2 | 专注未开始 |
| 倒计时 immersive | `mobile.timer-live` | Inter | **72–80** | 300–400 | 1.0 | 2 | 沉浸；tabular figures |
| 禁止 | — | — | 64 衬线 hero、11 以下正文、默认 w700 | — | — | — | — |

**中文注意**：Cormorant/EB Garamond 对中文会 fallback 到系统宋/黑。日期若是「2026年7月9日」：

- **方案 A（推荐）**：日期用 Inter 24–26 w400 + 略负字距（中文仍干净）；**仅**拉丁/数字多的「HH:mm」大号可衬线。  
- **方案 B**：衬线只包数字段，中文单位用 Inter。  
- 实现时二选一写进 theme 注释，避免中文衬线丑化。

---

## 4. 必须改动的文件与改动内容

> 按依赖顺序。先 token/字体，再原子组件，再各屏。

### 4.1 必改（P0）

| 文件 | 改什么 |
|------|--------|
| **`app/lib/app/theme.dart`** | ① 增加 serif text styles（或 `AppTypography`）；② `card` 对齐策略：废弃 `#FFFCF7` 抬白，改为 `canvas` 或 `surfaceCard`；③ 去掉业务侧对 `Colors.white` 的依赖，补 `onDark` / `surfaceDarkElevated`；④ `ColorScheme.secondary` 勿把 teal 当第二主色叙事（可保留 token 但文档化）；⑤ `textTheme.headlineSmall` 供日期用时挂 serif；⑥ 统一 button radius/height。 |
| **`app/lib/features/journal/widgets/section_card.dart`** | 删 coral 竖条；删 `boxShadow`；统一底色与 hairline；标题样式接 `mobile.section-title`；padding 保持 12–16。 |
| **`app/lib/features/journal/journal_screen.dart`** | `_DateHeader` 用 display-date；待办行 15/400–500；减少 w600；AppBar/RefreshIndicator 用 `primary` 常量名而非 `tomato` 语义；「安排」TextButton 保持 coral text-link。 |
| **`app/lib/features/journal/widgets/today_comparison_section.dart`** | `_SlotCard` 去重边框/降 tint；任务名 w500；空态/现在条降 w700；`ActionPillButton` 主次分流；状态 chip 去 w600。 |
| **`app/lib/features/journal/widgets/action_pill_button.dart`** | 默认改为 secondary（surface/canvas + hairline + ink）；增加 `emphasis: primary \| secondary`；compact 主操作才 `primary` fill。 |
| **`app/lib/features/shell/main_shell.dart`** | 选中态改为 surfaceCard + ink（category-tab）；未选 mutedSoft；去掉选中 coral 字色。 |
| **`app/lib/features/pomodoro/pomodoro_screen.dart`** | Idle 计时改 ink；沉浸背景 `#181715`；文案 onDark 系；下一轮按钮 secondary-on-dark；标题字重 500。 |
| **`app/lib/features/sleep/sleep_screen.dart`** | Hero 去 `sleepMist` 大面积；主 CTA 改 `primary`；日程大字 ink；弱化 `sleepBlue` 铺色。 |

### 4.2 应改（P1）

| 文件 | 改什么 |
|------|--------|
| **`app/lib/features/journal/widgets/today_stats_card.dart`** | 与 Section 标题体系一致；确认无 shadow。 |
| **`app/lib/features/journal/widgets/empty_add_slot.dart`** | 虚线改 hairline；文案 muted。 |
| **`app/lib/features/pomodoro/widgets/duration_chip.dart`** | 选中态弱化 coral 描边，改 surface 选中。 |
| **`app/lib/features/pomodoro/widgets/long_press_abandon_button.dart`** | white → onDark 透明度阶。 |
| **`app/lib/features/pomodoro/widgets/breathing_timer_text.dart`** | 仅确认不写死错误色。 |
| **`app/lib/features/journal/widgets/paper_background.dart`** | 保持；可选全 App 复用。 |
| **`app/lib/features/profile/profile_screen.dart`** | 去掉 w700；sheet 圆角 radiusXl；危险色 token。 |
| **`app/lib/features/weekly/weekly_screen.dart`** | 标题字重/颜色对齐。 |
| **`app/lib/features/sleep/widgets/sleep_week_dots.dart`** | 点色 semantic；容器不强制 mist。 |
| **`app/lib/features/journal/widgets/todo_pick_chips.dart`** | 选中 w500；底 surfaceSoft / 选中 surfaceCard。 |
| **`app/lib/app/gentle_feedback.dart`** | 完成 sheet 标题 w500；底 card/canvas。 |
| **`app/lib/features/journal/widgets/actual_edit_sheet.dart`** / **`schedule_sheet.dart`** | 标题降 w700；按钮走 theme Filled/Outlined。 |
| **`app/pubspec.yaml`**（若用 GoogleFonts 静态） | 可继续 runtime `google_fonts`；无需强制打包字体文件。 |

### 4.3 别名清理（P2，可渐进）

| 别名 | 替换为 |
|------|--------|
| `tomato` / `tomatoSoft` | `primary` / `primarySoft` |
| `paper` / `paperDeep` | `canvas` / `surfaceSoft` |
| `inkMuted` / `inkFaint` | `muted` / `mutedSoft` |
| `rule` / `fold` / `divider` | `hairline` / `surfaceCreamStrong` / `hairlineSoft` |
| `sleepBlue` / `sleepMist` | `accentTeal` + 删除 mist 或改为 `surfaceSoft` |
| `tagBg` | `surfaceSoft` |
| `danger` | `error` |

新代码禁止新增别名调用；旧调用可 batch replace。

---

## 5. 当前「丑」vs Claude 的反模式清单

按伤害排序（实现验收时逐条勾掉）：

1. **嵌套边框卡片**  
   `SectionCard`（白卡+shadow+边）里再塞 `_SlotCard`（又边又 tint）→ 脏、挤、像后台表格。  
   → 一层容器 + 内部分隔。

2. **Coral 竖条 × 每个 Section**  
   每卡一条 `#cc785c` → 电压被用光，主按钮不再「主」。  
   → 删竖条；coral 只留给 CTA / link。

3. **字重通胀（w600/w700 常态）**  
   任务名、空态、睡眠时间、Profile 标题全面加粗 → 小屏噪音，不像 Claude 的 regular display。  
   → 正文 400，强调 500，禁止默认 700。

4. **抬白卡片 `#FFFCF7` + 阴影**  
   偏离 cream 体系，像通用 Material Card。  
   → canvas/surfaceCard + hairline，无影。

5. **Sleep 第二品牌色（teal 铺满）**  
   mist 底 + teal 大字 + teal 主按钮 → 与手账 coral 叙事分裂，像两个 App。  
   → teal 降为状态；主色回 coral/ink。

6. **沉浸纯黑 `#0A0A0A` + 纯白字**  
   冷、数码表；非 `surfaceDark`/`onDark` 暖黑产品面。  

7. **Tab 选中整项变珊瑚**  
   底栏变成「四块番茄」；网站 category-tab 是 cream 底 + ink。  

8. **ActionPill 全局 coral soft fill**  
   「添加」「按计划」「有变更」同一视觉权重 → 无主次。  
   → secondary 默认，primary 唯一。

9. **Idle 专注大数字也是珊瑚**  
   未开始就全屏 tomato → 与「开始」按钮抢电压。  
   → 数字 ink，按钮 coral。

10. **有 google_fonts 却零衬线时刻**  
    theme 自称为 Claude，视觉仍是「Inter 待办 App」。  
    → 至少日期（或分区标题）一处 serif/editorial。

11. **圆角不统一**  
    Sleep 按钮 14、chip 8、card 12/16 混用。  
    → 严格 8 / 12 / 16。

12. **语义别名双轨**  
    `tomato` 与 `primary` 并存，容易改一处漏一处，色漂。  

---

## 6. 实施顺序建议（给实现 Agent）

1. `theme.dart`：补齐 dark/onDark/typography；冻结 hex。  
2. `section_card.dart` + `main_shell.dart`：立刻改善全局「干净度」。  
3. `action_pill_button.dart` + `today_comparison_section.dart`：对照区降噪。  
4. `journal_screen.dart` `_DateHeader`：第一个衬线/编辑时刻。  
5. `pomodoro_screen.dart` idle + immersive 色。  
6. `sleep_screen.dart` 去 mist/teal 主色。  
7. Profile/Weekly/Sheets 扫 w700 与别名。  
8. `flutter analyze` + `flutter test`；对照本文件第 5 节勾验收。

### 验收口令（产品体感）

- 打开手账：先感到**暖纸**，不是白卡堆叠。  
- 一屏内 **coral 可数**（≤2 处强电压：如一个主按钮 + 一个 text-link）。  
- 日期（或区标题）有**一刻**编辑感；其余安静 Inter。  
- 进专注沉浸：暖黑，不是冷黑。  
- 睡眠页：仍像同一手账 App，不是「独立冥想 App」。

---

## 7. 参考路径

| 文档/代码 | 路径 |
|-----------|------|
| Claude 源规范 | `/root/code/time-journal/DESIGN.md` |
| 主题 tokens | `/root/code/time-journal/app/lib/app/theme.dart` |
| 设计选型说明 | `/root/code/time-journal/docs/design-md/README.md` |
| 本简报 | `/root/code/time-journal/docs/design-md/CLAUDE_MOBILE_ADAPTATION.md` |

---

*Generated for mobile adaptation only. Do not paste marketing-site layout tokens (96px section, display-xl, full-bleed coral bands) into Flutter screens without the reductions above.*
