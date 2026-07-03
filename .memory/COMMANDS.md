# COMMANDS

## Start

Termux native:

```
claude
```

Ubuntu/proot manual:

```
cd ~/code/time-journal
claude --permission-mode acceptEdits
```

## Check

```
git status --short
git log --oneline --decorate -10
bash scripts/memory_boot.sh
bash scripts/memory_snapshot.sh
```

## Flutter validate

```
cd app && timeout 180 flutter analyze
cd app && timeout 180 flutter test
```

## Web preview

Only after user confirmation:

```
cd app && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8081
```

## Cross-model memory

For any AI tool:

1. Read AGENTS.md first.
2. Then read .memory/CURRENT_STATE.md and .memory/ACTIVE_OBJECT.md.
3. Then inspect git status before making changes.

## Inbox

```
bash scripts/inbox_list.sh
```

## Close round

```
bash scripts/memory_close.sh
```
