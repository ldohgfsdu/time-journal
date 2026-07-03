# BOOT

启动流程：

1. 读取 CLAUDE.md。
2. 读取 .memory/RULES.md。
3. 读取 .memory/CURRENT_STATE.md。
4. 读取 .memory/ACTIVE_OBJECT.md。
5. 读取 .memory/DECISIONS.md。
6. 读取 .memory/ENVIRONMENT.md。
7. 运行：
   ```bash
   bash scripts/memory_boot.sh
   ```
8. 如果实际 git 状态与 CURRENT_STATE 不一致，报告 drift，不要擅自修复。
9. 不启动 web-server。
10. 等用户下达任务。
