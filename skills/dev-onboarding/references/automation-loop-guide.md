# Automation Loop Guide (v3.0 — 2026-04-20)

> 不只是 skills + hooks，更是一整套「系統自己運作、自己學習、自己進化」的閉環。
> 這份 guide 從 Bombus 生產 12 天累積實戰提煉出來。

---

## 核心哲學

**「Allen 做判斷，系統做執行」**

- 任務自動派、自動追蹤、自動 review、自動通知
- 人類（Allen）只介入真正需要判斷的決策點
- 系統每天自我檢視（lessons-and-learn）→ 迭代自己

---

## 架構總覽

```
┌──────────────────────────────────────────────┐
│  Layer 1: 事件源 (Event Sources)             │
│  - git commit / file edit / docker event     │
│  - Claude session / Discord / cron           │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Layer 2: Watcher (每 5min 或 on-demand)     │
│  - 掃描 event sources                         │
│  - 呼叫 26+ handlers                         │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Layer 3: Handlers (50 個，分 4 bucket)      │
│  A. Observability — git-watch, gpu-health... │
│  B. Task Pipeline — task-scanner, review...  │
│  C. Learning — learning-review, distill...   │
│  D. Integration — mailbox, digest, sentinel  │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Layer 4: Notification (分 4 級)             │
│  🚨 alert    — realtime Discord push         │
│  🎯 decision — realtime + 結構化選項         │
│  ✅ milestone — mailbox only (daily digest)  │
│  💬 info      — log only                     │
└─────────────────┬────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────────┐
│  Layer 5: Learning Loop (每日)               │
│  - observations → pending learnings          │
│  - drift-sentinel → candidates               │
│  - daily-lessons → digest → Allen decision   │
│  - learnings-promote → rules/wiki backfill   │
└──────────────────────────────────────────────┘
```

---

## 關鍵 Handler (必建)

### 1. Watcher (核心)

```bash
# watcher.sh — 每 5min 呼叫所有 handlers
# 放在 crontab: */5 * * * * /path/to/watcher.sh
```

### 2. Mailbox with Category Filter (降噪 + 分級)

```bash
# mailbox.sh send <to> <from> --category=alert|decision|milestone|info <message>

# category=alert    → realtime push Discord
# category=decision → realtime + 強制結構化選項
# category=milestone → mailbox only (daily digest 聚合)
# category=info     → log only (連 mailbox 都不進)

# 自動 content detection (fallback):
# 🚨/critical → alert
# 🎯/decision/A)B)C)/選項 → decision
# ✅/完成/PASS/gate → milestone
# 其他 → info
```

### 3. Send-Decision Subcommand (結構化決策)

```bash
mailbox.sh send-decision manager auto-loop \
  "Adversarial gate decision" \
  "實測 20/33 < 28/33 gate" \
  "rollback:回舊版|proceed:接受 caveat|retest:補修再跑" \
  "if gate < 28/33" \
  "等 Allen 回覆，不動 live"

# 輸出格式:
# 🎯 **決策點: Adversarial gate decision**
# 📍 **觸發條件:** if gate < 28/33
# 📝 **背景:** 實測 20/33 < 28/33 gate
# **選項:**
# - A) rollback → 回舊版
# - B) proceed → 接受 caveat
# - C) retest → 補修再跑
# ⏳ **等你回覆**（不回則: 等 Allen 回覆，不動 live）
```

### 4. Handler-Sentinel (監控 handler 健康)

```bash
# handler-sentinel.sh — 追蹤每個 handler 最後成功時間
# 超過 threshold hr 沒跑成功 → alert manager

# 範例 threshold:
# - git-watch / task-scanner: >30min → alert
# - daily-briefing: >48hr → alert
# - model-quality-monitor: >24hr → alert

# Dedup: 4hr 內同個 handler 不重複 alert
```

### 5. Dispatch-Integrity-Check (每次 run 抓 drift)

```bash
# 每 5min 驗證:
# - watcher refs = config/dispatch-schedule.json
# - config/dispatch-routing-rules.json classified
# - handlers/README.md documented
# - 跨 source-of-truth 對齊

# 發現新 drift → alert manager (dedup: state file 比對)
```

---

## 每日學習閉環 (v3.0 核心)

```bash
# daily-lessons.sh — 每日 09:00 TW 自動聚合

# 6 類輸入:
# 1. pending-learnings (from learnings-distill)
# 2. observations (last 24hr, kind 分類)
# 3. drift candidates (from drift-sentinel)
# 4. integrity errors (from integrity-check)
# 5. stale handlers (from handler-sentinel)
# 6. failed deploys (from verify-log)

# 輸出:
# - /tmp/bombus-team/artifacts/daily-lessons-{date}.md
# - Manager mailbox (category=decision 如果有 action items)

# Allen 看 digest → promote 有價值的 learnings 到 wiki/rules
# learnings-promote → commit 進 playbook
```

---

## Savelyn-Loop Pattern (多人協作)

如果你有同事會 push 到同 repo：

```bash
# savelyn-loop.sh — Savelyn commit 完整閉環
# 4 個 link:
# 1. 從 commit message 抓 TASK-ID → task-db 自動 backlog→review
# 2. 自動產 codex-review task + artifact
# 3. 通知 Manager 用 send-decision (3 選項: review-merge / request-changes / obsolete)
# 4. Deadline 守門: 120hr 未動 → poke + dedup 24hr

# 用法: 改成你同事的名字 (如 alice-loop.sh, bob-loop.sh)
```

---

## Codex 4 Specialists 架構

如果用 Codex CLI 做進階任務：

| Specialist | 用途 | Write Scope |
|-----------|------|-------------|
| `codex-integrity` | 系統接縫 / dispatch drift / 自動化對齊 | dispatch/, wiki/ |
| `codex-refactor` | Type safety / dead code / route/api 對齊 | 指定 repo 的指定模組 |
| `codex-review` | Adversarial review / auth / tenant / migration | read-only |
| `codex-doc-sync` | 改完 code 後同步 wiki/playbook/brain | wiki/, .claude/ |

---

## Completion Discipline (強制規則)

**「結束工作 ≠ 完成任務」** — 從 Allen 2026-04-19 的現場糾正提煉：

1. **Patch 不等於 Fix** — container 內 / runtime patch，**不可標 completed**。必須 commit 進 repo
2. **派工必須閉環** — 派任務後追蹤 task-db 到對方真結案
3. **驗證對準用戶** — Backend/frontend smoke 要完整 user scenario 不是單次 curl
4. **Acceptance 不達不是 done** — 5/10 不是 partial，是 **not done**
5. **禁用話術** — 「後續優化」「可接受」「已派任務」「足夠給 demo 用」都是逃避
6. **Session 結束前自檢** — 「改進的是 repo 還是只改進 memory/container？」

---

## 你可以複製的 File 結構

從 Bombus 生產環境抽出的 canonical layout：

```
your-dispatch-repo/
├── watcher.sh                      # 每 5min 呼叫全部 handlers
├── retry-queue.sh                  # retry mechanism
├── config/
│   ├── dispatch-schedule.json      # handler 排程 (machine-readable)
│   └── dispatch-routing-rules.json # handler 分類 + 通知規則
├── handlers/
│   ├── mailbox.sh                  # 統一訊息入口 + category filter
│   ├── mailbox-digest.sh           # 每日 milestone+info 聚合
│   ├── handler-sentinel.sh         # handler 健康監控
│   ├── daily-lessons.sh            # 每日學習閉環
│   ├── dispatch-integrity-check.sh # drift 偵測
│   ├── git-watch.sh                # commit 偵測
│   ├── task-scanner.sh             # TASK-*.md → task-db
│   ├── task-lifecycle.sh           # task 狀態機
│   ├── review-auto-dispatch.sh     # L1/L2/L3 review 自動分派
│   ├── savelyn-loop.sh             # 改名成你同事的 loop
│   └── ... (40+ 個 handler)
└── log/
    └── dispatch.log
```

---

## 建議漸進路徑

**Week 1: 單機最小閉環**
- watcher.sh + 3 handlers: git-watch, mailbox, session-debrief
- `/today`, `/wiki`, `continuous-learning-v2`

**Week 2: 加通知分級**
- mailbox.sh category filter
- Discord integration
- send-decision subcommand

**Week 3: 加健康監控**
- handler-sentinel
- dispatch-integrity-check
- deployment-verifier

**Week 4: 加學習閉環**
- daily-lessons (9am)
- learnings-distill + promote
- drift-sentinel

**之後:** 根據個人痛點慢慢加自己的 handler

---

## 參考 Bombus 實戰 repo

- `Bombus-Technology/sage-dispatch` — 50 handlers 生產版
- `bombusvader/allen-wiki` — wiki 維護 + learnings
- 完整 handler map: `allen-wiki/operations/dispatch-handlers-map.md`

---

**這份 guide 會隨 Bombus 生產環境一起進化。self-update.sh 每週自動 pull 最新版。**
