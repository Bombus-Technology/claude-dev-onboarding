# Hook 候選清單

## PreToolUse（操作前）

| Hook | matcher | 做什麼 | 適合誰 |
|------|---------|--------|--------|
| boundary-check | Edit\|Write | 防止改到不該碰的檔案 | 有分工邊界的團隊 |
| task-focus | Edit\|Write | 每天第一次提醒看 /today | 有多個待辦的人 |
| import-guard | Edit\|Write | 檢查 import 不違反架構規則 | 有模組隔離需求的人 |
| state-change-warn | Edit\|Write | 改全域 state 時警告 | 共用 state 的團隊 |

## PostToolUse（操作後）

| Hook | matcher | 做什麼 | 適合誰 |
|------|---------|--------|--------|
| auto-test | Edit\|Write | 語法檢查（Python/TypeScript） | 所有開發者 |
| file-size-guard | Edit\|Write | 檔案超過 400 行警告 | 要求小檔案的團隊 |
| observe | Edit\|Write\|Bash | 記錄操作到 observations.jsonl | 想要學習系統的人 |
| deploy-reminder | Bash (git commit) | commit 後提醒是否需要部署 | 忘記部署的人 |
| commit-msg-format | Bash (git commit) | 確保 commit message 格式 | 要求 conventional commits 的團隊 |

## Stop（session 結束）

| Hook | matcher | 做什麼 | 適合誰 |
|------|---------|--------|--------|
| session-debrief | * | 產出 session 摘要 + 提醒 ingest wiki | 想追蹤進度的人 |
