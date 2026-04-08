---
name: dev-onboarding
description: AI 開發環境持續進化系統。首次使用做深度訪談建環境，之後根據使用行為自動學習、推薦新 skill、淘汰沒用的、持續優化。
user_invocable: true
---

# /dev-onboarding — AI 開發環境持續進化

不是一次性安裝。是一個**持續學習、持續優化**的系統。

```
首次：深度訪談 → 建環境
每天：observe 記錄操作
每週：review 分析 pattern → 推薦新 skill / 調整 hook / 更新 wiki
每月：evolve 升級 instincts → 產出新 agent
持續：你用越多 → 系統越懂你 → 環境越順手
```

## 判斷模式

根據 `$ARGUMENTS` 和系統狀態判斷執行什麼：

| 輸入 | 模式 | 做什麼 |
|------|------|--------|
| (空) | 自動判斷 | 首次 → Phase 1 訪談 / 非首次 → Phase 4 review |
| `setup` | 首次建置 | Phase 1 → 2 → 3 |
| `review` | 週 review | Phase 4（分析 observations → 推薦改善） |
| `evolve` | 月進化 | Phase 5（instincts → 新 skill/agent） |
| `status` | 環境狀態 | 列出所有已裝的 agents/skills/hooks + 使用率 |
| `add {type} {name}` | 新增 | 從 catalog 加一個 agent/skill/hook |
| `remove {type} {name}` | 移除 | 移除不用的 |
| `reset` | 重建 | 重跑訪談，整個重來 |

**首次使用自動偵測：** 如果 `~/.claude/dev-onboarding-profile.json` 不存在 → 進入 Phase 1。

---

## Phase 1：深度訪談（首次）

**一題一題問，不要跳過。用開放式問題。等使用者回答完才問下一題。**

### 第一組：日常工作流程

1. 「你平常一天的開發流程大概是怎樣？從打開電腦到下班。」
2. 「你最常做的事是什麼？寫哪類 code？」
3. 「你覺得哪些事情最花時間但其實可以自動化的？」
4. 「你有用過 Claude Code 的 agent teams 嗎？知道可以 spawn sub-agent 並行工作嗎？」

### 第二組：卡點分析

5. 「你最常卡在什麼地方？」（等說完再追問細節）
6. 「卡住的時候你怎麼處理？自己查？問同事？看文件？」
7. 「有沒有覺得 spec 不夠清楚、不知道要做什麼的情況？」
8. 「環境問題（GPU/Docker/DB/依賴）多嗎？」

### 第三組：工具偏好

9. 「你的 IDE 有什麼特別的設定或 extension？」
10. 「你寫測試的習慣？TDD？寫完再補？」
11. 「你怎麼管理你的 TODO？」
12. 「你有沒有自己的筆記系統？」

### 第四組：技術深度

13. 「你負責的系統最大的技術挑戰是什麼？」
14. 「你有沒有想要但目前沒有的工具？」
15. 「你對 prompt engineering 的迭代流程是什麼？」
16. 「你覺得你寫的 code 品質怎麼樣？」

### 第五組：協作與成長

17. 「你跟 team lead 的協作上有什麼可以改善的？」
18. 「如果你有一個 AI 助手 24 小時幫你，你最想讓它做什麼？」
19. 「你覺得你的生產力瓶頸在哪？」
20. 「你想學什麼新技術或提升什麼能力？」

### 訪談結束後

把回答存到 `~/.claude/dev-onboarding-profile.json`：

```json
{
  "name": "使用者名字",
  "role": "從回答推斷的角色",
  "created_at": "日期",
  "interview_answers": { "q1": "回答", ... },
  "identified_patterns": ["pattern1", ...],
  "pain_points": ["pain1", ...],
  "preferences": { "testing": "TDD/後補", "notes": "有/沒有", ... },
  "installed": { "agents": [], "skills": [], "hooks": [] },
  "version": 1,
  "last_review": null,
  "review_count": 0
}
```

---

## Phase 2：設計環境（首次）

根據訪談回答，從 catalog 推薦。**每個都問確認。**

讀取：
- `references/agent-catalog.md`
- `references/skill-catalog.md`
- `references/hook-catalog.md`

推薦邏輯：
- 使用者說「常 debug」→ 推薦 debugger agent
- 使用者說「不喜歡寫文件」→ 推薦 doc-writer agent
- 使用者說「常調 prompt」→ 推薦 prompt-tuner agent + /eval skill
- 使用者說「常忘記測試」→ 推薦 auto-test hook
- 使用者說「TODO 靠腦子記」→ 推薦 /today skill
- 使用者沒筆記系統 → 推薦 wiki + /learn + /pit skills
- 使用者提到瓶頸是 context → 推薦學習系統（observe + evolve）

使用者也可以提自己想要的。

---

## Phase 3：建立環境（首次）

全部確認後一次建好。建完更新 profile.json 的 `installed` 欄位。

啟用 observe hook（如果使用者同意）→ 開始記錄操作。

---

## Phase 4：週 Review（`/dev-onboarding review`）

**不依賴 session 結束。使用者任何時候都可以跑。建議每週跑一次。**

### 4.1 分析 Observations

讀取 `~/.claude/homunculus/observations.jsonl`（如果有啟用 observe），分析：

```python
# 分析維度
- 最常用的 tool：Edit > Read > Bash？代表寫 code 為主
- 最常碰的檔案類型：.py > .md > .yaml？
- 錯誤頻率：多少次操作有 error？
- 工作時間分佈：早上集中還是分散？
- 最常卡住的時間段：哪個時段 error 最多？
```

### 4.2 分析已裝工具的使用率

檢查 `installed` 裡的 agents/skills/hooks 哪些有被用：

```
已裝的 skill：/today, /done, /stuck, /eval, /test
  /today: 用了 15 次（高）
  /eval: 用了 2 次（低）
  /stuck: 用了 0 次（從沒用）
  
→ 建議：/stuck 要不要移除或改設計？你是不是卡住時直接問 Allen 而不是用 /stuck？
```

### 4.3 發現新 Pattern

從 observations 找使用者重複做但沒有自動化的操作：

```
發現：你每次改 graph node 都手動跑 python3 -m pytest tests/test_nodes.py
  → 建議：新增 /test-node skill 自動化這個步驟

發現：你每次 commit 前都 grep "console.log\|print(" 
  → 建議：新增 clean-debug hook 自動移除 debug 語句

發現：你反覆讀同一份 spec 文件 3 次以上
  → 建議：把重點摘要存到 wiki，下次不用重讀
```

### 4.4 產出 Review 報告

```markdown
## Dev Environment Weekly Review — {date}

### 使用統計
- 本週 observations：{N} 筆
- 最常用工具：{top 3}
- 錯誤率：{N}%

### 工具使用率
| 工具 | 使用次數 | 建議 |
|------|---------|------|
| /today | 15 | ✅ 保留 |
| /eval | 2 | 🟡 考慮移除或改設計 |
| /stuck | 0 | 🔴 建議移除或了解為什麼不用 |

### 發現的新 Pattern
1. {pattern} → 建議 {action}
2. {pattern} → 建議 {action}

### 推薦新增
- {新 skill/agent/hook}，因為 {理由}

### 推薦移除
- {不用的 skill/hook}，因為 {理由}
```

問使用者：「要接受這些建議嗎？」→ 接受的立即執行（新增/移除）。

---

## Phase 5：月進化（`/dev-onboarding evolve`）

### 5.1 Instincts 分析

讀取 `~/.claude/homunculus/instincts/personal/`，找信心度 ≥ 0.85 的：

```
高信心 instincts：
  - prefer-functional-style (0.9)
  - always-run-pytest-before-commit (0.85)
  - use-structured-output-for-llm (0.88)
  
→ 這三個可以合併成一個 "coding-standards" skill
```

### 5.2 自動升級

信心度 ≥ 0.85 且同 domain 的 instincts 3+ 個 → 建議合併成 skill。

**跟使用者確認後才建。** 不自動。

### 5.3 Profile 更新

更新 `dev-onboarding-profile.json`：
- `version` +1
- `last_review` 更新
- `review_count` +1
- `installed` 更新（新增/移除的）
- `identified_patterns` 追加

### 5.4 環境健康度

```
環境健康度：{score}/100
  - 工具覆蓋率：{installed 數 / 推薦數}
  - 使用率：{被用到的 / 已裝的}
  - 學習進度：{instincts 數 / observations 數 比率}
  - wiki 活躍度：{最近 7 天更新的頁面數}
```

---

## Phase 6：持續被動學習（不需要使用者觸發）

如果使用者啟用了 observe hook，以下自動發生：

### 6.1 Session Debrief（Stop hook）

每次 session 結束：
- 分析本次 session 的 observations
- 如果發現新 pattern → 寫入 instincts/personal/
- 如果有值得記的 → 提醒「要不要 /learn 存到 wiki？」

### 6.2 每日 Pattern 偵測

observe 累積超過 50 筆新 observations 時自動分析：
- 有沒有重複操作可以變成 skill
- 有沒有常見錯誤可以加 hook 預防
- **只提醒，不自動改。** 下次 `/dev-onboarding review` 時一起處理。

---

## 原則

- **不替使用者決定。** 每個改動都問。
- **不自動刪東西。** 只建議，使用者確認才刪。
- **漸進式。** 首次不用全裝，用了再加。
- **透明。** 告訴使用者 observe 記錄了什麼、分析了什麼。
- **可移除。** 任何時候 `/dev-onboarding remove {type} {name}` 就移除。
- **profile 是使用者的。** 不上傳，不分享（除非使用者主動 export）。
