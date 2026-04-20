# Notification Taxonomy (v3.0 — 2026-04-20)

> 「我很難看懂 Discord 通知，不知道要下什麼判斷」— Allen 2026-04-20。
> 這份 taxonomy 從痛點提煉，讓通知永遠清楚「要不要我做事」。

---

## 4-級分類 (Allen-tested)

| Category | Icon | Realtime Push? | 目的 | 例子 |
|----------|------|---------------|------|------|
| **alert** | 🚨 | ✅ YES | critical / live fail / security | GPU 85°C, service down, security breach |
| **decision** | 🎯 | ✅ YES | 需要下判斷（強制結構化選項） | Gate fail rollback/proceed, new commit review |
| **milestone** | ✅ | ❌ mailbox only | Task 完成 / deploy done | 部署成功, gate pass |
| **info** | 💬 | ❌ log only | FYI (wiki pushed, auto-sync) | Daily briefing ready |

---

## Decision Message 必備 5 元素

每個 decision-required 訊息都要有：

```
🎯 **決策點: {TITLE}**

📍 **觸發條件:** {何時開始需要這個決策}
📝 **背景:** {1-2 行為何這個決策重要}

**選項:**
- **A)** {label} → {action}
- **B)** {label} → {action}
- **C)** {label} → {action}

⏳ **等你回覆**（不回則: {default action}）
```

---

## Anti-Pattern (以前的錯誤)

### ❌ Raw Status Dump

```
knowledge-loop: Wiki 有新內容 → 已 push master → Vercel auto-deploy 中。
```

**問題：** 不知道要做什麼，每 5min 來一次。→ **應該 info 類，log only**

### ❌ No Decision Marker

```
T42 Senzfor v4 deploy 完成，backend healthy, portal healthy, agent-service 28/33 PASS。
```

**問題：** 訊息長但沒說要做什麼。→ **應該 milestone 類，mailbox only + daily digest**

### ❌ Fake Decision

```
你覺得要 rollback 嗎？
```

**問題：** 沒列 A/B/C + 沒背景 + 沒觸發條件。→ **應該 send-decision subcommand**

---

## 實作 (mailbox.sh category filter)

```bash
# ~/.claude/dispatch/handlers/mailbox.sh send 支援:

# 顯式分類 (推薦)
mailbox.sh send manager foo --category=alert "🚨 service down"
mailbox.sh send manager foo --category=info "wiki synced"

# 自動偵測 (fallback)
# 訊息含 🚨 / critical / alert → alert
# 訊息含 🎯 / decision / A) B) / 選項 → decision
# 訊息含 ✅ / 完成 / PASS / gate → milestone
# 其他 → info
```

**Realtime push 規則：**
```bash
if [ "$CATEGORY" = "alert" ] || [ "$CATEGORY" = "decision" ]; then
  # curl Discord bot endpoint → PM channel (~3s latency)
else
  # 只進 mailbox file，等 daily digest (09:00) 聚合
fi
```

---

## Daily Digest (milestone + info 聚合)

```bash
# mailbox-digest.sh — 每天 09:00 TW 聚合過去 24hr milestone + info
# 直接 post 到 PM channel，讓 Allen 看到累積不錯過，但不被 realtime 打擾
```

---

## 警告機制

```bash
# mailbox.sh send 加 check_decision_markers():
# 如果 TO=manager + msg >300 chars + 無 decision marker
# → stderr warn: "⚠️ manager-bound msg lacks decision markers"
# → 建議用 send-decision subcommand

# 不 block，只提醒（避免 workflow 打斷）
```

---

## 部署到你自己的系統

1. 複製 `sage-dispatch/handlers/mailbox.sh` 改成自己的 bot token + channel ID
2. 改所有 handler 的 `notify_discord` → `mailbox.sh send --category=`
3. 加 `mailbox-digest.sh` cron 每天 09:00
4. 測試: `mailbox.sh send test test --category=info "test"` 看是否只進 mailbox 不 push Discord

---

**References:**
- Bombus: `sage-dispatch/handlers/mailbox.sh`
- 原始 session (Allen 現場糾正): Manager bec0bee8 (2026-04-20 evening)
- 完整 refactor: commit `a7248e3` (`2bfc878`)
