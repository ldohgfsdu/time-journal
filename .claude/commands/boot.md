# boot

Manual boot command. 执行项目启动检查：

1. 读取 CLAUDE.md
2. 读取 .memory/*
3. 执行 bash scripts/memory_boot.sh
4. 报告 drift
5. 不修改文件
6. 不启动 web-server

This is the explicit manual trigger. Casual messages do not trigger boot automatically — see .memory/BOOT.md for the trigger policy.
