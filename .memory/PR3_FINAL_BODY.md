## P0-6 linkedPlanId 最小变更（最终复核通过）

**对应条目**：P0-6

**确认**：
- Schema 禁令**仅**对 P0-6 linkedPlanId 最小 Drift migration 解除。
- **未做**任何 UI polish。
- **未改**无关 feature（仅 data/ + journal_repository + tests）。
- **未启动** web-server。
- **未打** release。
- **未碰** P0-5 / P1-7 任何代码。
- 完成后**只开 draft PR**，不合并（当前仍为 draft）。

### 修改文件
- app/lib/data/local/tables.dart （新增 linkedPlanId nullable 列）
- app/lib/data/local/database.dart （schemaVersion 3 + 最小 addColumn migration）
- app/lib/data/local/database.g.dart （build_runner 生成）
- app/lib/data/models/comparison_slot.dart （status 修正支持时间变）
- app/lib/data/repositories/journal_repository.dart （匹配逻辑 + link 设置 + 后续 review 修复）
- app/test/journal_repository_test.dart （共新增 9 条相关测试，最终 44/44）

### 完成内容（含 review follow-ups）
- TimeBlock 增加 `linkedPlanId` 字段，用于 actual 指向 planned 的 id。
- 匹配优先使用 `linkedPlanId`，回退到原有时间匹配（仅 unlinked legacy）。
- 在 completePlannedAsActual、ensureActualSlot、updateBlock、clearActualForPlan 中正确处理 link。
- **Review 修复**：
  - completePlannedAsActual：existing 时同时重置 start/end time（changed → match）。
  - ensureActualSlot：legacy 命中后回填 linkedPlanId。
  - **最终边界**：legacy exact-time fallback 只匹配 `linkedPlanId == null` 的 actual；已链接的 actual 绝不被其他 plan 通过时间复用。
- ComparisonSlot.status：时间或内容不同即 changed。
- 仅最小必要变更，保持所有现有行为 + 旧数据兼容。

### 验证命令（均在 app/ 执行）
- dart run build_runner build --delete-conflicting-outputs
- flutter pub get
- flutter analyze （No issues found）
- flutter test （All 44 tests passed）

### 数据结构 / migration
是。仅新增 nullable 列 + migration（schema 2→3）。旧数据 linkedPlanId=null 时使用 unlinked legacy time fallback。无破坏性变更。

### 产品体验影响
为“今日对照”匹配提供稳定关联（P0-6 release blocker 解除），后续“按计划完成”等可可靠配对计划与实际，不依赖易变的起止时间字符串。已通过所有边界 case 复核。

**最终复核结论**：代码复核通过、schema 通过、matching semantics 通过、legacy fallback 通过、clearActualForPlan 边界通过、tests 通过。PR #3 仍 Draft。

**下一步建议**：Mark ready for review 后可 merge。
