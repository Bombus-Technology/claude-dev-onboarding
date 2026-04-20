# Claude Code Dev Onboarding v3.0

> **AI 工程師開發環境一鍵搭建 + 自動化閉環 + 每日學習系統。**
> 從 Bombus 生產環境 12 天累積實戰提煉出來（2026-04-08 → 2026-04-20）。

## v3.0 新增 (2026-04-20)

- 🔄 **自動化閉環** — watcher + 50 handlers + retry queue
- 🎯 **通知分級** — alert/decision/milestone/info 4 層（從 Allen 「看不懂要下什麼判斷」的現場痛點提煉）
- 📏 **Completion Discipline** — 6 條強制紀律（防止假完成）
- 📚 **Catalog 擴充** — 30+ agents, 40+ skills, 20+ hooks
- 🧠 **Daily Lessons-and-Learn** — 每日 09:00 自動 retrospect → Allen decision
- 📝 **Savelyn-Loop Pattern** — 同事 commit 自動進 review flow

## 安裝

```bash
git clone https://github.com/Bombus-Technology/claude-dev-onboarding.git
cp -r claude-dev-onboarding/skills/dev-onboarding ~/.claude/skills/
```

## 使用

```
/dev-onboarding
```

AI 會：
1. 跟你做 10-15 題深度訪談（5 分鐘）
2. 根據回答推薦 agents/skills/hooks
3. 每個建議都問確認（除了團隊規範類）
4. 啟用學習系統 + 自動化閉環（可選）
5. 設定每週自動同步 catalog（從 GitHub）

## 產出

| 產出 | 路徑 | 說明 |
|------|------|------|
| Agents | `~/.claude/agents/` | 你的 AI teammates |
| Skills | `~/.claude/skills/` | 你的指令庫 |
| Hooks | `~/.claude/hooks/` + `settings.json` | 自動化守衛 |
| Wiki | `~/dev-wiki/` | 個人知識庫 |
| Rules | `~/.claude/rules/` | Completion discipline + 個人規範 |
| Dispatch | `~/.claude/dispatch/` | **v3.0 新** — 自動化閉環 (watcher + handlers) |

## Catalog 內容

- [`references/agent-catalog.md`](skills/dev-onboarding/references/agent-catalog.md) — 30+ Claude Code agents
- [`references/skill-catalog.md`](skills/dev-onboarding/references/skill-catalog.md) — 40+ skills
- [`references/hook-catalog.md`](skills/dev-onboarding/references/hook-catalog.md) — 20+ hooks
- [`references/automation-loop-guide.md`](skills/dev-onboarding/references/automation-loop-guide.md) — **v3.0 新** — 自動化閉環 guide
- [`references/notification-taxonomy.md`](skills/dev-onboarding/references/notification-taxonomy.md) — **v3.0 新** — 通知分級
- [`references/completion-discipline.md`](skills/dev-onboarding/references/completion-discipline.md) — **v3.0 新** — 6 條紀律

## 自動化閉環 (v3.0 核心)

```
┌──────────────────────────────────────┐
│ Your IDE / Claude Session            │
└────────────┬─────────────────────────┘
             │ file events / git commits
             ▼
┌──────────────────────────────────────┐
│ Watcher (每 5min)                    │
│ 呼叫 26+ handlers                    │
└────────────┬─────────────────────────┘
             ▼
┌──────────────────────────────────────┐
│ Handlers (分 4 bucket: 50 個)        │
│ A. Observability (git, gpu, health)  │
│ B. Task Pipeline (scan, review)      │
│ C. Learning (distill, promote)       │
│ D. Integration (mailbox, digest)     │
└────────────┬─────────────────────────┘
             ▼
┌──────────────────────────────────────┐
│ Notification Filter (4 級)           │
│ 🚨 alert → realtime Discord          │
│ 🎯 decision → realtime + 結構化選項 │
│ ✅ milestone → daily digest 聚合    │
│ 💬 info → log only                   │
└────────────┬─────────────────────────┘
             ▼
┌──────────────────────────────────────┐
│ Daily Lessons-and-Learn (09:00)      │
│ 聚合 observations + drift + deploy   │
│ → digest → Allen decide → 回饋系統  │
└──────────────────────────────────────┘
```

## 適用對象

- **AI Engineer** — 需要 prompt / eval / graph / RAG 工具鏈
- **Backend Engineer** — 需要 API / DB / security 工具
- **Team Lead** — 需要 plan / review / 自動化協作
- **SRE / DevOps** — 需要監控 / deploy / incident 工具
- 任何使用 Claude Code 的開發者

## 自動同步 (每週六 10:00 本地時間)

```bash
# self-update.sh 自動 git pull catalog
# 有新工具時下次 session 開始一行提示
# 使用者選「看」 → 列出 + 問要不要裝
# 選「跳過」 → 不問同一批
```

## 授權

MIT

## Contributing

改進 catalog 或 guide？歡迎 PR。使用者的本機會自動同步你的更新。

## 參考

- Bombus 生產環境: `Bombus-Technology/sage-dispatch` (50 handlers 實戰)
- 版本演進: v1.0 → v2.0 → v2.1 → v3.0
