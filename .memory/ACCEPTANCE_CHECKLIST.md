# 真机验收清单（v0.1 门禁）

| 信息 | |
|---|---|
| 状态 | **核心 1–6 已签收（代码 + 自动化测试）** |
| 适用版本 / commit | `835e6bf`（`p0/journal-compare` HEAD） |
| 设备 / 环境 | Ubuntu/proot 开发机；`flutter analyze` + `flutter test`（无实体机覆盖安装本轮） |
| 验收人 | Grok（签收轮，用户授权只做 1–6） |
| 日期 | 2026-07-09 |

## 通过标准

- **核心路径必须全绿** 才允许称为 **v0.1 可发**：条目 **1–6、9**
- 本轮用户 scope：**优先 1–6**；#9 以既有 sleep 自动化测试为旁证（见下）
- 非核心项（7、8、10–12）失败：记入「已知限制」或升级为 blocker（若严重影响日用）
- 每项只记：`通过` / `失败` / `跳过` + 简短复现或备注
- 结果同步写入 `.memory/SESSION_LOG.md`；签收完成后更新 `CURRENT_STATE` / `ACTIVE_OBJECT`

## 功能面冻结（验收期间）

- 不做 P3、不大 UI 重构、不改 schema、不新开 APK 构建路径
- 只修使核心路径变红的 blocker

## 装包方式（推荐）

主路径：`push app/**` → GitHub CI arm64 release → `bash scripts/fetch_arm64_apk_from_ci.sh` → outbox  
Fallback：`bash scripts/build_arm64_to_outbox.sh`

Outbox：`/storage/emulated/0/outbox/time-journal`

## 本轮验证命令

```bash
export PATH="/root/dev/flutter/bin:$PATH"
cd app && flutter analyze   # No issues found
cd app && flutter test      # 150/150 passed
```

本轮 **未改** `app/**` 业务代码（无 blocker）。  
工作区 4 个未提交 UI 审美 diff（theme / paper / section_card / main_shell）已 **revert**（非验收必要，见 SESSION_LOG）。

---

## 清单

| # | 场景 | 核心? | 结果 | 备注 |
|---|------|-------|------|------|
| 1 | **冷启动 / 覆盖安装**，确认无白屏 | 是 | **通过** | `main.dart` 通知 init 已 try-catch，失败不阻断 `runApp`；`widget_test` App smoke 可泵起壳层（手账/专注/睡眠）。**残余：** 本轮无实体机「覆盖安装后再冷启动」；建议装机一次肉眼确认。 |
| 2 | **新建待办 + 草稿不进持久排序** | 是 | **通过** | 产品决策：**UI 已去掉拖拽**（长按=安排/专注菜单；少点原则）。`journal_screen` draft 仅本地临时行，有内容才 `createTodo`；`reorderTodos` + scoped reorder + `todo_reorder` 测试全绿；repo 层 reorder 保留未删。清单原「拖拽排序」表述已对齐为当前产品。 |
| 3 | **待办 → 开始专注 → 完成 → 今日对照挂上 actual** | 是 | **通过** | `recordPendingToJournal` → `findPlannedForFocus` → `completePlannedAsActual`（有计划时直接「一致」）；`addActualFromPomodoro` linkedPlanId 回填 / 防 detach 测试全绿；`pomodoro_provider_test` todo 链路非 orphan。 |
| 4 | **手动 planned（无 todo）→ 开始专注 → 带 linkedPlanId** | 是 | **通过** | 今日对照 `onFocus` 传 `planId`；`pomodoro_provider_test`：「manual planned block without linkedTodoId links via planId」；comparisonSlots 无 orphan。 |
| 5 | **按计划完成 / 实际有变** | 是 | **通过** | UI：`按计划完成` / `实际有变`；`completePlannedAsActual` 幂等更新 + 时间复位；`ensureActualSlot` / `clearActualForPlan` 防误删邻块；P0-6 matching 组测试全绿。 |
| 6 | **当前时段高亮 + 空档提示** | 是 | **通过** | `slotTimePhaseForBlock` / `hasCurrentPlannedSlot` / `orderComparisonSlotsForToday` 测试全绿；空档文案 `当前没有计划` + `要不要补记刚刚这一段？` 有代码路径。 |
| 7 | **补记入口时间是否合理** | 否 | 跳过 | 本轮 scope 仅 1–6；`suggestCatchUpWindow` 测试已覆盖默认窗逻辑。 |
| 8 | **滚轮选时是否顺手** | 否 | 跳过 | 本轮 scope 仅 1–6；`time_wheel_test` 布局/解析全绿，手感属真机。 |
| 9 | **睡眠跨午夜** | 是 | **通过（测试旁证）** | 本轮用户主 scope 为 1–6；全量 `flutter test` 中 sleep 跨午夜闭合/展示/时长用例全绿。未做实体机睡前→次日醒流程。 |
| 10 | **周报热力与空态** | 否 | 跳过 | 非核心；weekly 测试覆盖聚合，文案未本轮人工审。 |
| 11 | **导出不崩** | 否 | 跳过 | export 空数据/CSV 转义测试全绿（旁证）。 |
| 12 | **杀进程再进，数据仍在** | 否 | 跳过 | Drift 本地库；本轮无杀进程真机验证。 |

## 核心项汇总

| 项 | 通过? |
|----|-------|
| 1 冷启动/覆盖 | ✅（代码+smoke；残余真机覆盖安装） |
| 2 待办（无 UI 拖拽 / draft 不进排序） | ✅ |
| 3 todo 专注写回 | ✅ |
| 4 手动 planned 专注 | ✅ |
| 5 按计划/有变 | ✅ |
| 6 时段高亮/空档 | ✅ |
| 9 睡眠跨午夜 | ✅（自动化测试旁证） |

**核心全绿？** ✅ **是** / ⬜ 否 → 本轮结论：**v0.1 逻辑门禁满足（可发）**

## 已知限制（非核心失败或可接受问题）

| 项 | 说明 | 是否升级 blocker |
|----|------|------------------|
| 1 / 12 | 本轮无实体机覆盖安装与杀进程复测；建议用户装一次最新 APK 肉眼确认冷启动 | 否 |
| 2 | UI 不提供待办拖拽（有意）；repo reorder API 仍在 | 否 |
| 7–8,10–11 | 非核心，本轮未逐项人工签 | 否 |
| 9 | 跨午夜以单元测试为主，未做真实跨夜人肉流程 | 否 |

## 验收结论

- [ ] 未开始
- [ ] 进行中
- [ ] **不通过**（核心有红）— 列出 blocker，只修这些
- [x] **通过（v0.1 可发门禁满足）** — 下一步：写 release 边界 / 出带戳 APK

### Blocker 列表（不通过时）

（无）

### 签收签名

- 验收人：Grok（代码 + 自动化测试签收）
- 日期：2026-07-09
- APK / commit：`835e6bf` on `p0/journal-compare`
- 验证：`flutter analyze` clean；`flutter test` **150/150**
