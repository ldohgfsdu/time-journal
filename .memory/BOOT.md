# BOOT

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

## Boot protocol (when triggered)

1. 读取 CLAUDE.md。
2. 读取 .memory/RULES.md。
3. 读取 .memory/CURRENT_STATE.md。
4. 读取 .memory/ACTIVE_OBJECT.md。
5. 读取 .memory/DECISIONS.md。
6. 读取 .memory/ENVIRONMENT.md。
7. 读取 .memory/SESSION_LOG.md。
8. 运行：
   ```bash
   bash scripts/memory_boot.sh
   ```
9. 如果实际 git 状态与 CURRENT_STATE 不一致，报告 drift，不要擅自修复。
10. 不启动 web-server。
11. 等用户下达任务。
