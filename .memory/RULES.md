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
