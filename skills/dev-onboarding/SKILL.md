---
name: dev-onboarding
description: AI 開發環境一鍵搭建。訪談了解工作方式 → 建 agents/skills/hooks/wiki。系統自動持續進化。
user_invocable: true
---

# /dev-onboarding — AI 開發環境搭建

使用者只需要跑一次。之後系統自己學習、自己進化。

```
你做的事：跑一次 /dev-onboarding（10-15 分鐘訪談 + 環境建立）
系統做的事：
  持續 → observe 記錄你的操作（你不用管）
  session 開始 → 自動檢查有無新建議（你不用跑指令）
  持續 → catalog 從 GitHub repo 自動同步（你不用手動更新）
```

## Skill 自我進化

這個 skill 不是靜態的。它透過 **GitHub repo** 持續同步更新：

```
GitHub repo（source of truth）
  └── references/
      ├── agent-catalog.md  ← Allen push 更新
      ├── skill-catalog.md  ← Allen push 更新
      └── hook-catalog.md   ← Allen push 更新
           │
           ▼ self-update.sh 每週 git pull
           │
使用者本機 catalog
  ├── 自動同步最新版
  └── 下次 session 提示新項目
```

**任何人都可以 push catalog 更新。使用者的本機自動跟進。**

## 判斷模式

根據 `$ARGUMENTS` 判斷：

| 輸入 | 做什麼 |
|------|--------|
| (空) | 首次 → 訪談 + 建環境 / 已建過 → 顯示環境狀態 + 有無新推薦 |
| `status` | 已裝的 agents/skills/hooks + 使用率 + catalog 新增項 |
| `add {type} {name}` | 從 catalog 加一個 agent/skill/hook |
| `sync` | 手動觸發 catalog 同步（通常自動，不需手動） |
| `remove {type} {name}` | 移除不用的 |
| `reset` | 重跑訪談，整個重來 |

**首次使用自動偵測：** 如果 `~/.claude/dev-onboarding-profile.json` 不存在 → 進入 Phase 1。

---

## Phase 1：訪談（首次）

**一題一題問，不要跳過。用開放式問題。等使用者回答完才問下一題。**

### 核心題（10 題，必問）

1. 「你平常一天的開發流程大概是怎樣？從打開電腦到下班。」
2. 「你最常做的事是什麼？寫哪類 code？」
3. 「你覺得哪些事情最花時間但其實可以自動化的？」
4. 「你最常卡在什麼地方？」（等說完再追問細節）
5. 「卡住的時候你怎麼處理？自己查？問同事？看文件？」
6. 「你寫測試的習慣？TDD？寫完再補？」
7. 「你怎麼管理你的 TODO？有沒有自己的筆記系統？」
8. 「你負責的系統最大的技術挑戰是什麼？」
9. 「如果你有一個 AI 助手 24 小時幫你，你最想讓它做什麼？」
10. 「你覺得你的生產力瓶頸在哪？」

### 追問題（根據角色選 3-5 題）

**如果偵測到 AI/ML 工程師：**
- 「你對 prompt engineering 的迭代流程是什麼？」
- 「你有用過 Claude Code 的 agent teams 嗎？」
- 「環境問題（GPU/Docker/DB/依賴）多嗎？」

**如果偵測到 Backend 工程師：**
- 「你的 IDE 有什麼特別的設定或 extension？」
- 「有沒有覺得 spec 不夠清楚、不知道要做什麼的情況？」
- 「你跟 team lead 的協作上有什麼可以改善的？」

**如果偵測到 Frontend 工程師：**
- 「你怎麼做 component 測試？」
- 「design system 有統一嗎？」
- 「你想學什麼新技術或提升什麼能力？」

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

### 推薦邏輯

根據訪談語義理解推薦，不是 keyword matching。Claude 應該理解使用者的意思：

| 使用者表達的痛點 | 推薦 |
|----------------|------|
| debug 相關（看 log、不知道為什麼壞、常 print） | debugger agent |
| 不喜歡寫文件、文件總是過時 | doc-writer agent |
| prompt 調整、eval、A/B 對比 | prompt-tuner agent + /eval skill |
| 常忘記測試、測試覆蓋率低 | auto-test hook |
| TODO 靠腦子記、沒有任務管理 | /today skill |
| 沒筆記系統、學過的東西記不住 | wiki + /learn skills |
| context overload、資訊太多 | 學習系統（observe + evolve） |

**團隊規範類工具（boundary-check、import-guard 等）直接建議安裝，不需要問。** 解釋原因即可。

使用者也可以提自己想要的。

---

## Phase 3：建立環境（首次）

全部確認後依序執行：

### 3.1 建 agents/skills/hooks/wiki

根據 Phase 2 確認的項目建立。

### 3.2 啟用學習系統（如果使用者同意）

- 啟用 observe hook → 開始記錄操作
- 建立 `~/.claude/homunculus/` 目錄結構（如果不存在）

**注意：dev-onboarding 負責初始設定 + 工具推薦。持續學習行為 pattern 由 continuous-learning-v2 負責。兩者職責不重疊：**

```
dev-onboarding = 你需要什麼工具？（訪談 → 推薦 → 安裝）
CLv2           = 你的行為有什麼 pattern？（observe → instincts → evolve）
```

### 3.3 安裝 Catalog 自動同步

```bash
# 安裝 self-update.sh 為每週 cron
SKILL_PATH="$HOME/.claude/skills/dev-onboarding"
chmod +x "$SKILL_PATH/self-update.sh"
CRON_CMD="0 10 * * 6 $SKILL_PATH/self-update.sh >> $SKILL_PATH/update-log.md 2>&1"

# 幂等安裝（移除舊的再加新的）
(crontab -l 2>/dev/null | grep -v "self-update.sh"; echo "$CRON_CMD") | crontab -
```

**時間：每週六 10:00（本地時間）**

機制：
- self-update.sh 從 GitHub repo `git pull` 最新 catalog
- 比對本機 catalog 找出差異
- 自動同步 catalog 檔案
- observations.jsonl 超過 10MB 自動 archive

### 3.4 建立 Session 開始提示

在 `~/.claude/CLAUDE.md` 追加：

```markdown
## Dev Environment 自動建議

Session 開始時檢查（只在有新內容時顯示，不每次都問）：

1. ~/.claude/skills/dev-onboarding/update-log.md 最近 7 天有新項目？
   → 一行摘要：「Catalog 有 N 個新工具，要看嗎？」
   → 使用者說「看」→ 列出 + 問要不要裝
   → 使用者說「跳過」→ 不問，下次也不問同一批

2. continuous-learning-v2 有新的高信心 instincts（≥ 0.85）？
   → 「你有 N 個成熟的 instincts 可以升級成 skill，要看嗎？」

不要每次 session 都顯示。沒有新內容就安靜。
```

### 3.5 更新 profile.json

記錄所有安裝的項目 + cron 狀態。

---

## 持續進化（使用者不需要做任何事）

```
使用者正常寫 code
  │
  ├── observe hook 靜默記錄操作（CLv2 負責）
  │     └── 累積 → instincts → session 開始建議升級
  │
  └── 每週六 self-update.sh
        └── git pull catalog → 有新工具 → session 開始建議安裝

兩條路徑獨立運作，都只在 session 開始、有新內容時才提示。
```

### 路徑 A：個人 Pattern（CLv2 負責）

```
observe hook 記錄操作
  → observations.jsonl（自動 archive > 10MB）
  → CLv2 分析 → instincts
  → 3+ 同 domain + ≥ 0.85 信心度
  → session 開始建議合併成 skill
  → 使用者確認才執行
```

### 路徑 B：Catalog 同步（self-update.sh 負責）

```
Allen 或任何人 push catalog 更新到 GitHub
  → 每週六 self-update.sh git pull
  → 比對本機 catalog → 找到新項目
  → session 開始一行提示
  → 使用者說「裝」→ 安裝 + 更新 profile
  → 使用者說「跳過」→ 不裝，不再問同一批
```

---

## 原則

- **不替使用者決定。** 每個改動都問（團隊規範除外，那些直接建議）。
- **不打擾工作。** 沒有新內容就安靜。有新內容只在 session 開頭一行提示。
- **不自動刪東西。** 只建議，確認才動。
- **漸進式。** 首次不用全裝，系統會隨使用自動建議追加。
- **透明。** 使用者隨時 `/dev-onboarding status` 看系統知道什麼。
- **profile 是使用者的。** 不上傳，不分享。observations 也不分享。
- **職責清楚。** dev-onboarding = 工具推薦。CLv2 = 行為學習。不重疊。
