This project also has a tool-agnostic agent entry file:

AGENTS.md

CLAUDE.md is the Claude Code adapter. The shared source of truth is .memory/.

Claude Code should read AGENTS.md first, then CLAUDE.md, then .memory/*.

---

# time-journal Claude Code Entry

这是 time-journal Flutter 轻量时间管理手账 App。

## 启动规则

每次会话开始必须先读取：

1. .memory/BOOT.md
2. .memory/RULES.md
3. .memory/CURRENT_STATE.md
4. .memory/ACTIVE_OBJECT.md
5. .memory/DECISIONS.md
6. .memory/ENVIRONMENT.md
7. .memory/SESSION_LOG.md

然后执行只读启动检查：

```bash
bash scripts/memory_boot.sh
```

## 基本约束

- 默认中文沟通。
- 当前使用 DeepSeek API，不要 /login。
- 不使用 auto mode，优先 acceptEdits。
- 不默认启动 web-server。
- web-server 是常驻任务，启动前必须询问用户。
- 不 reset、不 checkout、不 clean，除非用户明确授权。
- 长命令必须使用 timeout。
- 修改业务代码后必须运行：
  ```
  cd app && timeout 180 flutter analyze
  cd app && timeout 180 flutter test
  ```
- 提交前必须 diff 审计。
- 提交后必须输出 git log 和 git status。
- 每轮结束必须更新 .memory/CURRENT_STATE.md 和 .memory/SESSION_LOG.md。
- API Key 不允许写入仓库。

## 外部收件箱

- 用户说"上传了文件""看新文件""读取附件"时，先检查 .external_inbox/。
- 跨项目通用资料检查 .shared_inbox/。
- 不提交 .external_inbox、.shared_inbox 或任何外部文件。
- 分析大文件前先列出文件名、大小、类型，不盲目全量读取。

## 外部发件箱

- 用户说"输出到 outbox""导出报告""保存一份"时，写入 .external_outbox/。
- 跨项目共享导出使用 .shared_outbox/。
- 不提交 .external_outbox、.shared_outbox 或任何外部文件。
