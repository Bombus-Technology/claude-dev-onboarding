# Completion Discipline (v3.0 — 2026-04-20)

> 「結束工作 ≠ 完成任務」— 2026-04-19 Allen 現場糾正 Manager session 的 checkbox mentality 產生的鐵律。

---

## 核心

**結束工作 ≠ 完成任務**

- **結束** = 標 checkbox、報告 done、合 PR
- **完成** = 用戶期望的交付物真的存在且驗證通過

許多「完成」其實是 memory/container/session 層的假完成，沒進 repo、沒對準 user、沒跑 live smoke。

---

## 6 條紀律

### 1. Patch 不等於 Fix

Container 內 / live DB / runtime state 改動，**不可標 task completed**。

必須同 session 內：
- Commit 進 repo，OR
- 明確標記「未根治，派工 ID=X」並追蹤到真的完成

### 2. 派工必須閉環

派 TASK 給其他 agent 後，必須追蹤：
```
task-db 狀態 → results/ JSON → 內容正確
```

**原任務到對方結案才能 completed。** 不能派完就走。

### 3. 驗證對準用戶

- **Backend**: 完整 user scenario，不是單次 curl
- **Frontend**: agent-browser 自動化走完 flow，不是 build pass
- **邊界**: edge case（錯密碼 / token expire / concurrent），不是 happy path

### 4. Acceptance Criteria 不達不是 done

Smoke test 5/10 不是 "partial"，是 **not done**。

除非用戶明確降級（「這一輪先這樣」），否則繼續做。

### 5. 禁用話術

以下都是逃避的託辭：

| 話術 | 真實意思 |
|------|---------|
| 「後續優化」 | 沒做 |
| 「可接受」 | 沒驗證 user 是否接受 |
| 「已派任務」 | 任務還沒解決 |
| 「live verified」(只驗一次 happy path) | 邊界沒驗 |
| 「足夠給 demo 用」 | demo 不是 final |
| 「接受風險」(沒寫 TD tracker) | 只是不想做 |

### 6. Session 結束前自檢

每個 completed task 都問：

1. 改進的是 **repo**，還是只改進了 memory/container state？
2. 明天我接手這個 handoff，會**相信它 done 嗎**？
3. 用戶**實際使用**這個交付物嗎？
4. 有**具體驗證步驟 + 結果**嗎？

**任一 no → 重開任務。**

---

## Manager / Lead session 特別禁止

- 「我改 6 個 repo 完成 10 件事」 = 都在表面
- 「我 commit 全部 push 了」 = 沒 live verify
- 「我派 TASK 給 codex」 = 沒追蹤開始
- 「我在 container 裡 patch 了」 = 沒進 repo
- 「我加了 rule 到 CLAUDE.md」 = 沒驗證遵守

---

## 為什麼這很重要

**違反這些紀律就是在欠技術債 + 欠未來 session 時間。**

2026-04-19 Allen 現場糾正 Manager session 後，這變成全 AI team 強制遵守的 rule。

---

## 套用到你的 dev environment

在 `~/.claude/rules/completion-discipline.md` 放這份，讓每個 session 都讀。

可選:
- 加進 Stop hook（session 結束時自動 checklist）
- 加進 daily-lessons（自動檢查「昨天標完成的 task 是否真的 deploy 了」）

---

**References:**
- Bombus playbook: `allen-wiki/playbooks/completion-discipline.md`
- Global rule: `~/.claude/rules/completion-discipline.md`
- 源起 session: Manager session bec0bee8 (2026-04-19)
