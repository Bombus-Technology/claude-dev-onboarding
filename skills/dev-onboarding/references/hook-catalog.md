# Hook 候選清單 (v3.0 — 2026-04-20)

> Claude Code hooks 分 3 類：PreToolUse / PostToolUse / Stop。v3.0 新增 Bombus 實戰累積的 hooks。

## PreToolUse（操作前）

| Hook | matcher | 做什麼 | 適合誰 |
|------|---------|--------|--------|
| `boundary-check` | Edit\|Write | 防止改到不該碰的檔案 | 有分工邊界的團隊 |
| `task-focus` | Edit\|Write | 每天第一次提醒看 /today | 有多個待辦的人 |
| `import-guard` | Edit\|Write | 檢查 import 不違反架構規則 | 有模組隔離需求的人 |
| `state-change-warn` | Edit\|Write | 改全域 state 時警告 | 共用 state 的團隊 |
| `session-guard-auto` | Edit\|Write | 偵測多 session 同時改同檔案的衝突 | 多 session 開發的人 |
| `block-direct-deploy` | Bash | 攔截直接 docker compose（強制走 deploy.sh） | 有 deploy 流程的團隊 |
| `strategic-compact/suggest-compact` | Edit\|Write | Context window 接近上限時建議 /compact | 長 session 用戶 |

## PostToolUse（操作後）

| Hook | matcher | 做什麼 | 適合誰 |
|------|---------|--------|--------|
| `auto-test` | Edit\|Write | 語法檢查（Python/TypeScript） | 所有開發者 |
| `file-size-guard` | Edit\|Write | 檔案超過 400 行警告、500 行阻擋 | 要求小檔案的團隊 |
| `empty-catch-guard` | Edit\|Write | 空 catch block 警告 | 重視錯誤處理的人 |
| `permission-check-guard` | Edit\|Write | requireAuth 但無 hasPermission → 警告 | 有 RBAC 的團隊 |
| `doc-drift-tracker` | Edit\|Write | 改 compose/route/Dockerfile 時提醒同步文件 | 多文件環境 |
| `design-pattern-guard` | Edit\|Write | mutation/API格式/bare except/SQL injection 警告 | 有設計規範的團隊 |
| `observe` | Edit\|Write\|Bash | 記錄操作到 observations.jsonl（CLv2 源頭） | 想要學習系統的人 |
| `session-tracker` | Edit\|Write | 追蹤 session 動到的檔案 | 多 session 環境 |
| `deploy-reminder` | Bash (git commit) | commit 後提醒是否需要部署 | 忘記部署的人 |
| `commit-msg-format` | Bash (git commit) | 確保 commit message 格式 | 要求 conventional commits 的團隊 |

## Stop（session 結束）

| Hook | matcher | 做什麼 | 適合誰 |
|------|---------|--------|--------|
| `session-debrief` | * | 產出 session 摘要 + 提醒 ingest wiki | 想追蹤進度的人 |
| `learnings-distill` (via CLv2) | * | 從 session 萃取 learnings → pending-learnings | 持續進化 |
| `continuous-learning Stop` | * | 評估 session messages 是否夠累積 pattern | 用 CL 系統的人 |

---

## v3.0 新增：進階 hook combo (from Bombus 生產)

**完整 safety net (Backend 專案):**
```
PreToolUse:   boundary-check + import-guard + state-change-warn + block-direct-deploy
PostToolUse:  auto-test + file-size-guard + empty-catch-guard + permission-check-guard + design-pattern-guard + observe
Stop:         session-debrief + learnings-distill
```

**最小 footprint (個人開發):**
```
PostToolUse:  auto-test + observe
Stop:         session-debrief
```

**Observability-heavy (SRE/DevOps):**
```
PreToolUse:   block-direct-deploy + session-guard-auto
PostToolUse:  doc-drift-tracker + observe + session-tracker
Stop:         session-debrief
```

---

## Git Pre-commit Hook (Husky, 非 Claude hook)

位於 `.husky/pre-commit`，commit 時執行 5 項檢查：

| 檢查 | 阻擋? | 說明 |
|------|--------|------|
| TypeScript tsc --noEmit | Yes | 型別錯誤不能 commit |
| 檔案大小 >500 行 | Yes | staged .ts/.tsx/.py |
| Schema manifest 驗證 | Warn | 改 .sql 或 route.ts 時 |
| RBAC 一致性 | Warn | 改 permissions.ts 或 middleware-rbac.ts 時 |
| console.log 偵測 | Warn | staged .ts/.tsx 檔案 |

---

## 安裝方式

```bash
# 從 catalog 安裝
/dev-onboarding add hook auto-test

# 或手動
# 1. 寫 hook script 到 ~/.claude/hooks/{name}.sh + chmod +x
# 2. 在 ~/.claude/settings.json 的 hooks 區塊加入 entry
#    {"matcher": "Edit|Write", "hooks": [{"type": "command", "command": "~/.claude/hooks/{name}.sh"}]}
```

---

**References:**
- Source of truth: `Bombus-Technology/claude-dev-onboarding`
- 本機安裝: `~/.claude/hooks/`
- settings: `~/.claude/settings.json`
- 更新頻率: 每週六 10:00 self-update.sh 自動 pull
