# close

执行本轮收口：

1. 总结本轮改动
2. 更新 .memory/CURRENT_STATE.md
3. 更新 .memory/SESSION_LOG.md
4. 运行 bash scripts/memory_close.sh
5. 输出 git status --short
6. 不提交，除非用户明确要求
