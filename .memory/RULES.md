# RULES

## 工作方式

- 默认中文。
- 先做可验证结果，不只讲方案。
- 大任务先只读检查。
- 每次只改相关文件。
- 不改 schema，除非用户明确授权。
- 不执行 flutter build apk --release。
- 不默认启动 web-server。
- web-server 是常驻任务，启动前必须询问。
- 不使用 auto mode，优先 acceptEdits。
- 不 /login，除非用户明确要求接 Anthropic 官方账号。
- 不 reset、不 checkout、不 clean，除非用户明确授权。
- 不把 API Key 或任何密钥写进仓库。

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

## 收口规则

每轮结束要更新：

- .memory/CURRENT_STATE.md
- .memory/SESSION_LOG.md
- 必要时更新 .memory/ACTIVE_OBJECT.md
