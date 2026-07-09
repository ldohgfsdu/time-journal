# RULES

## Boot trigger policy

Do not automatically run boot for casual messages.

Casual messages include:
- hi / hello / 你好
- ? / 在吗
- 简单询问当前状态
- 问命令怎么用
- 问菜单 / proxy / usage 怎么用

Run boot automatically only before real development tasks, such as:
- 修改代码
- 审计功能
- mvp-audit
- 修 bug
- 写测试
- 提交
- 生成报告
- 读取项目状态后继续开发

Manual boot remains available:
- 用户明确输入 boot 时，执行 boot protocol。

If unsure whether a message is casual or a development task, ask one short clarification instead of running boot.

## 工作方式

- 默认中文。
- 先做可验证结果，不只讲方案。
- 大任务先只读检查。
- 每次只改相关文件。
- 不改 schema，除非用户明确授权。
- 不执行 flutter build apk --release。
- 不使用 auto mode，优先 acceptEdits。
- 不 /login，除非用户明确要求接 Anthropic 官方账号。
- 不 reset、不 checkout、不 clean，除非用户明确授权。
- 不把 API Key 或任何密钥写进仓库。

## UI 设计与预览（2026-07-09 起硬规则）

- **UI / 视觉 / 样式迭代：先 Web 预览，禁止每改一轮就打包 APK。**
- 流程：改 UI → `flutter run -d web-server`（或已有预览）→ 用户看效果 → 继续改 → **用户明确说满意 / 可以打包** 后再 commit+push 触发 CI APK 或走 outbox 脚本。
- 用户本条授权后，**UI 相关任务可主动启动 web-server**（默认端口 8081，启动前仍简短说明 URL；若已有进程在跑则复用）。
- **非 UI** 的功能修复、验收 blocker、用户明确要求装机复测时，才走 APK。
- 不要在 UI 未定稿时 push `app/**` 仅为了等 CI 出包（浪费时间）。

## Cross-model entry

- Any AI coding tool or model should read AGENTS.md first.
- Then read .memory/CURRENT_STATE.md and .memory/ACTIVE_OBJECT.md before making changes.
- Do not rely on hidden chat memory when switching models.
- Report drift if repository state conflicts with .memory/.

## External inbox

- 用户说"上传了文件""看新文件""读取附件"时，先检查 .external_inbox/。
- 跨项目通用资料检查 .shared_inbox/。
- 不提交 .external_inbox、.shared_inbox 或任何外部文件。
- 不要把外部文件复制进仓库，除非用户明确要求。
- 分析大文件前先列出文件名、大小、类型，不盲目全量读取。

## External outbox

- 用户说"输出到 outbox""导出报告""保存一份"时，写入 .external_outbox/。
- 跨项目共享导出使用 .shared_outbox/。
- 不提交 .external_outbox、.shared_outbox 或任何外部文件。

## Global AI usage tools

- usage / proxy 是全局工具（~/.ai-tools/deepseek-usage/）。
- 不要复制 usage 日志进仓库。
- 不要提交 API Key。
- 每轮收口执行 ai-usage --auto || true。
- proxy 进程和 token 记录是两回事：
  - `ai-proxy-start` 启动转发代理，不强制开启记录。
  - `ai-proxy-enable` / `ai-proxy-disable` 控制 token 记录开关。
  - 暂停记录不影响 proxy 转发，Claude Code 照常使用。
- 要用记录开关功能，必须通过 proxy 透明模式启动 Claude Code。
- 直连模式中途启动 proxy 不会接管当前会话。
- 改 `agent` 菜单时**只改 `~/.ai-tools/agent-launcher/agent.sh`，再跑 `bash ~/.ai-tools/agent-launcher/agent-install.sh`**（见 `AGENT_LAUNCHER.md` / `.memory/ENVIRONMENT.md`）。**勿**在 time-journal 仓库 `scripts/` 下放 agent 脚本。
- Proxy 透明模式：`agent proxy <项目>` 或 `agent proxy-start` 等子命令；主菜单平台 3 为 Hermes，不是 Proxy。

## 验证命令

Flutter 验证统一使用：

```bash
cd app && timeout 180 flutter analyze
cd app && timeout 180 flutter test
```

## 提交流程

提交前：
1. git status --short
2. git diff --stat
3. 按文件确认改动范围
4. 确认不含密钥
5. 确认不含非授权文件

提交后：
1. git log --oneline --decorate -10
2. git status --short
3. **默认** `git push origin $(git branch --show-current)`，把提交推到 GitHub（用户明确说「先不 push」「只本地提交」时除外）。

### 推送后的 CI 与装包（GitHub Actions）

- 仅当本次 push 包含 **`app/`** 内改动时，Actions 会自动跑 analyze + test + 上传 **arm64 Release APK**（`android-arm64-release.yml`）。
- **Debug APK** 不随 push 构建（`android-debug-apk.yml` 仅 `workflow_dispatch`），避免大包浪费。
- 只改 `.memory/`、`AGENTS.md`、文档等 **不会** 触发 APK 构建，避免无意义耗时。
- **主路径：** push 含 `app/` → CI arm64 release → `bash scripts/fetch_arm64_apk_from_ci.sh`（或 `post_push_app.sh` / `release_apk_to_outbox.sh`）→ outbox（`/storage/emulated/0/outbox/time-journal`）。
- **Fallback：** `bash scripts/build_arm64_to_outbox.sh`（CI 不可用时）；**不**再扩展本机路径、**不**新增第三条构建流水线。
- 收口：`bash scripts/round_close_app.sh`（有 app 改动时走装包路由）。

## 收口规则

每轮结束要更新：

- .memory/CURRENT_STATE.md
- .memory/SESSION_LOG.md
- 必要时更新 .memory/ACTIVE_OBJECT.md

向用户汇报（三条缺一不可）：

1. **改了什么**（文件、行为、CI 策略等）
2. **发现了什么问题 / 用户诉求**
3. **怎么解决的**
