---
name: dev-onboarding
description: AI 開發環境一鍵搭建。深度訪談了解工作方式 → 建 agents/skills/hooks/wiki/學習系統。建完後系統自動持續進化，不需要再手動跑。
user_invocable: true
---

# /dev-onboarding — AI 開發環境搭建

使用者只需要跑一次。之後系統自己學習、自己進化。

```
你做的事：跑一次 /dev-onboarding（20 分鐘訪談 + 環境建立）
系統做的事：
  每天 → observe 記錄你的操作（你不用管）
  每週 → 自動分析 pattern → 新 skill 建議出現在 daily briefing（你不用跑指令）
  每月 → instincts 自動合併 → 提醒你確認（你不用跑指令）
  持續 → 越用越懂你
```

## 判斷模式

根據 `$ARGUMENTS` 判斷：

| 輸入 | 做什麼 |
|------|--------|
| (空) | 首次 → 訪談 + 建環境 / 已建過 → 顯示環境狀態 |
| `status` | 列出已裝的 agents/skills/hooks + 使用率 |
| `add {type} {name}` | 從 catalog 加一個 agent/skill/hook |
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

## Phase 3：建立環境 + 自動排程（首次）

全部確認後依序執行：

### 3.1 建 agents/skills/hooks/wiki

（同前，根據 Phase 2 確認的項目建立）

### 3.2 啟用學習系統

- 啟用 observe hook → 開始記錄操作
- 建立 `~/.claude/homunculus/` 目錄結構（如果不存在）

### 3.3 安裝自動進化排程

建立 `~/.claude/hooks/dev-auto-review.sh`：

```bash
#!/bin/bash
# 每次 session 的 Stop hook — 自動分析本次 session + 累積學習
# 不需要使用者手動跑 review

OBS_FILE="$HOME/.claude/homunculus/observations.jsonl"
PROFILE="$HOME/.claude/dev-onboarding-profile.json"
REVIEW_FILE="$HOME/.claude/dev-review-latest.md"

# 如果 observations 不足 50 筆新增，跳過
OBS_COUNT=$(wc -l < "$OBS_FILE" 2>/dev/null || echo 0)
LAST_COUNT=$(python3 -c "import json; print(json.load(open('$PROFILE')).get('last_obs_count',0))" 2>/dev/null || echo 0)
NEW_OBS=$((OBS_COUNT - LAST_COUNT))

if [ $NEW_OBS -lt 50 ]; then
  exit 0
fi

# 有足夠新 observations → 產出 review 提示
cat << EOF

📊 你累積了 $NEW_OBS 筆新的操作記錄。系統發現了一些 pattern：
   下次 session 開始時會自動顯示建議。

EOF
```

掛到 `~/.claude/settings.json` 的 Stop hook。

### 3.4 建立 session 開始自動建議

在 `~/.claude/CLAUDE.md` 追加：

```markdown
## 每次 Session 開始時

如果 ~/.claude/dev-review-latest.md 存在且 < 7 天，讀取並顯示：
- 發現的新 pattern
- 推薦新增/移除的工具
- 環境健康度

使用者可以說「接受」或「忽略」。接受的立即執行。
```

### 3.5 更新 profile.json

記錄所有安裝的項目 + 啟用排程。

---

## Phase 4：自動週 Review（使用者不用跑，系統自己做）

**由 Stop hook 觸發。累積 50+ 筆新 observations 就分析一次。結果在下次 session 開始時自動顯示。**

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

結果寫入 `~/.claude/dev-review-latest.md`。下次 session 開始自動顯示，問使用者接受或忽略。

---

## Phase 5：自動月進化（使用者不用跑，系統自己做）

**由 dev-auto-review.sh 在 instincts 累積到 3+ 同 domain 時自動觸發建議。**

### 5.1 觸發條件

```
instincts/personal/ 裡同一個 domain 的 instinct >= 3 個
且信心度都 >= 0.85
→ 自動產出合併建議到 dev-review-latest.md
→ 下次 session 開始時顯示：「3 個 {domain} instincts 可以合併成一個 skill，要嗎？」
→ 使用者說「要」→ 自動建 skill
→ 使用者說「不要」→ 不做，下次不再問同一組
```

### 5.2 Profile 自動更新

每次 review 或 evolve 觸發都自動更新 `dev-onboarding-profile.json`：
- `version` +1
- `last_review` 更新
- `review_count` +1
- `installed` 更新
- `identified_patterns` 追加
- `last_obs_count` 更新

### 5.3 環境健康度（session 開始自動顯示）

```
📊 環境健康度：{score}/100
  工具覆蓋率：{已裝 / 推薦}
  使用率：{被用到的 / 已裝的}
  學習進度：{instincts 數}
  wiki 活躍度：{最近 7 天}
```

只在 session 開始顯示一行摘要。不打擾正常工作。

---

## 整體自動化流程（使用者不需要做任何事）

```
使用者正常寫 code
  │ observe hook 靜默記錄每個操作
  │
  ▼
累積 50+ 筆新 observations（Stop hook 檢查）
  │ 自動分析 pattern
  │ 寫入 dev-review-latest.md
  │
  ▼
下次 session 開始
  │ CLAUDE.md 自動讀 dev-review-latest.md
  │ 顯示一行：「發現 2 個新 pattern，要看嗎？」
  │
  ├── 使用者說「看」→ 顯示詳細 + 問接受/忽略
  └── 使用者說「不看」→ 跳過，不打擾
  │
  ▼
instincts 夠多（3+ 同 domain, ≥ 0.85）
  │ 下次 session 自動建議合併成 skill
  │
  ├── 使用者確認 → 建 skill
  └── 使用者拒絕 → 不建，不再問
```

**使用者只需要跑一次 `/dev-onboarding`。之後所有學習和進化都是自動的，只在 session 開頭簡短提示。**

---

## 原則

- **不替使用者決定。** 每個改動都問。
- **不打擾工作。** 學習在背景，建議在 session 開頭。
- **不自動刪東西。** 只建議，確認才動。
- **漸進式。** 首次不用全裝，系統會隨使用自動建議追加。
- **透明。** 使用者隨時 `/dev-onboarding status` 看系統知道什麼。
- **profile 是使用者的。** 不上傳，不分享。
