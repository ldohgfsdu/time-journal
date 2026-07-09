# v0.1 发布结论

| 项 | 内容 |
|----|------|
| 结论 | **可发（逻辑门禁 + 装包就绪）** |
| 日期 | 2026-07-09 |
| 分支 | `p0/journal-compare` |
| 代码基线（app） | `d039a23` ≡ `835e6bf` ≡ HEAD（其后仅 `.memory`/docs） |
| 签收提交 | `a8951a6`（清单 1–6） |
| 验收依据 | `.memory/ACCEPTANCE_CHECKLIST.md` 核心 1–6 全绿；#9 自动化测试旁证 |
| 验证 | `flutter analyze` No issues；`flutter test` 150/150；烟测见下 |

## APK 路径（本机 outbox）

| 文件 | 说明 |
|------|------|
| **`/storage/emulated/0/outbox/time-journal/time-journal-arm64-d039a23-20260709-2232-v0.1.apk`** | v0.1 标记副本（推荐装这个） |
| `/storage/emulated/0/outbox/time-journal/time-journal-arm64-d039a23-20260709-1910.apk` | 同源 CI 产物（md5 相同） |
| 仓库内链 | `.external_outbox/time-journal/` → 同上目录 |
| 指针说明 | `.../outbox/time-journal/v0.1-release-apk.txt` |

- **体积：** 27 023 590 bytes  
- **md5：** `c247e9ef1a20a13d4b884eaea66947a7`  
- **applicationId：** `com.timejournal.time_journal`  
- **构建方式：** GitHub CI arm64 release（本机 aarch64 proot NDK 主机 clang 不可执行；`gh` 未登录无法重新 dispatch）  
- **app/** 与 `d039a23` 后无业务 diff（仅 memory/docs）→ 该 APK 即为 v0.1 代码基线二进制

## 产品边界（v0.1）

- **定位：** 低压力时间手账；核心是计划 vs 实际的温和对照。
- **包含：** P0–P2（今日对照、专注写回、`linkedPlanId`、时段高亮/空档、补记入口、滚轮选时、睡眠跨午夜逻辑、周报基础、导出）。
- **不包含（冻结 / 非 v0.1）：** P3 动效、更多白噪音、复杂拖拽安排、大 UI 重构、商店上架物料（若需另开）。

## 变更摘要（相对 MVP 收口）

- 今日对照：按计划完成 / 实际有变 / 空档「当前没有计划」
- 专注完成写回：关联计划时直接「一致」；`linkedPlanId` 匹配与防 detach
- 待办：新建与安排/专注；**不做 UI 拖拽排序**（有意）
- 睡眠：跨午夜记录闭合与展示（逻辑已测）
- 交付：CI→outbox 主路径；UI 迭代 Web 预览优先

## 实体机烟测（2026-07-09）

| 项 | 结果 | 说明 |
|----|------|------|
| APK 落盘 outbox | ✅ | 见上路径 |
| 包已安装 | ✅ | `pm path com.timejournal.time_journal` 有 path |
| 拉起 / 前台 | ✅ | `am start --user 0 …MainActivity`：已运行则 brought to front |
| 冷启动（force-stop 再开） | ⚠️ 受限 | Termux 无 `FORCE_STOP_PACKAGES`；MIUI 下 `pm install` 需 `MANAGE_USERS` |
| 新增待办 / 专注 / 写回 / planned 链路 / 今日对照 | ⚠️ 自动化受限 | 无 `INJECT_EVENTS` / uiautomator / screencap；**路径由单元测试覆盖**（linkedPlanId、completePlanned、manual planId、App smoke） |
| 聚焦测试 | ✅ | 相关用例 **20/20** passed（widget + pomodoro + journal 过滤） |

**结论：** 装包成功、进程可拉起；完整人手 UI 五步需用户在桌面点开应用补做（非逻辑 blocker）。

## 剩余非 blocker

1. 本机 NDK 不可用 → 日常仍走 CI APK（需 `gh auth login` 才能重新拉最新 workflow）
2. MIUI 权限限制：shell 无法 force-stop / inject / 静默覆盖安装
3. 用户建议人手补：冷启动、新建待办、专注完成写回、手动 planned 专注、今日对照一眼确认
4. 真实跨夜睡眠人肉（#9）
5. 正式商店/对外版本号策略未定

## 本轮明确不做

- 不改 schema、不修业务逻辑、不改 UI 审美、不扩 P3  
- 不为 build 去装 qemu/amd64 NDK（超出 build blocker 合理范围）
