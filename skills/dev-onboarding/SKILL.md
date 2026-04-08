---
name: dev-onboarding
description: AI 工程師開發環境深度訪談 + 一鍵搭建。問 20 題了解工作方式，自動建 agents/skills/hooks/wiki/學習系統。
user_invocable: true
---

# /dev-onboarding — AI 開發環境搭建

透過深度訪談了解使用者的工作方式，然後根據回答自動搭建專屬的 Claude Code 開發環境。

## 流程

```
Phase 1: 深度訪談（20 題）
  → 了解日常流程、卡點、工具偏好、架構理解、協作需求
  
Phase 2: 設計環境
  → 根據回答推薦 agents/skills/hooks
  → 每個都問使用者確認
  
Phase 3: 建立環境
  → 一次建好所有確認的項目
  → 跑驗證確認環境正常
```

## Phase 1：深度訪談

**一題一題問，不要跳過。用開放式問題，不用是非題。等使用者回答完才問下一題。**

### 第一組：日常工作流程

1. 「你平常一天的開發流程大概是怎樣？從打開電腦到下班。」
2. 「你最常做的事是什麼？寫哪類 code？」
3. 「你覺得哪些事情最花時間但其實可以自動化的？」
4. 「你有用過 Claude Code 的 agent teams 嗎？知道可以 spawn sub-agent 並行工作嗎？」

### 第二組：卡點分析

5. 「你最常卡在什麼地方？」（等她說完再追問細節）
6. 「卡住的時候你怎麼處理？自己查？問同事？看文件？」
7. 「有沒有覺得 spec 不夠清楚、不知道要做什麼的情況？」
8. 「環境問題（GPU/Docker/DB/依賴）多嗎？大概多久會遇到一次？」

### 第三組：工具偏好

9. 「你的 IDE 有什麼特別的設定或 extension？」
10. 「你寫測試的習慣？TDD？寫完再補？pytest 跑的頻率？」
11. 「你怎麼管理你的 TODO？腦子記？紙條？app？」
12. 「你有沒有自己的筆記系統？記過的坑、學到的東西存在哪？」

### 第四組：技術深度

13. 「你覺得你目前負責的系統，最大的技術挑戰是什麼？」
14. 「你有沒有想要但目前沒有的工具？」
15. 「你對 prompt engineering 的迭代流程是什麼？改 prompt → 怎麼驗證效果？」
16. 「你覺得你寫的 code 品質怎麼樣？有什麼想改善的？」

### 第五組：協作與成長

17. 「你跟 team lead 的協作上有什麼可以改善的？」
18. 「如果你有一個 AI 助手 24 小時幫你，你最想讓它做什麼？」
19. 「你覺得你的生產力瓶頸在哪？技術能力？時間？context？工具？」
20. 「你想要學什麼新技術或提升什麼能力？」

---

## Phase 2：設計環境

訪談完後，根據回答設計環境。**每個項目都要跟使用者確認才建。**

### 2A. 推薦 Agents

讀取 `references/agent-catalog.md`，根據使用者回答選擇適合的 agents。

每個 agent 問：「根據你剛才說的 [引用她的回答]，我建議建一個 [agent 名] 來幫你 [做什麼]。你覺得需要嗎？」

### 2B. 推薦 Skills

讀取 `references/skill-catalog.md`，根據使用者回答選擇適合的 skills。

同樣每個都問確認。使用者也可以提自己想要的 skill。

### 2C. 推薦 Hooks

讀取 `references/hook-catalog.md`，根據使用者回答選擇適合的 hooks。

### 2D. Wiki 結構

根據使用者的筆記習慣和技術領域，設計 wiki 目錄結構。預載她需要的知識。

### 2E. 學習系統

問使用者要不要啟用 continuous-learning（observe → instincts → evolve）。
解釋：「你寫 code 的每個操作都被記錄，定期自動提取你的 pattern，變成可重用的 skill。完全本地，不上傳。」

---

## Phase 3：建立環境

使用者全部確認後，依序執行：

### 3.1 建 Agents

對每個確認的 agent，讀取 `templates/agents/` 裡的模板，客製化後寫入 `~/.claude/agents/`。

### 3.2 建 Skills

對每個確認的 skill，讀取 `templates/skills/` 裡的模板，客製化後寫入 `~/.claude/commands/`。

### 3.3 建 Hooks

對每個確認的 hook，讀取 `templates/hooks/` 裡的模板，寫入 `~/.claude/hooks/` 並 chmod +x。

### 3.4 更新 settings.json

把所有 hooks 掛到 `~/.claude/settings.json`。如果已存在，合併不覆蓋。

### 3.5 建 Wiki

建立 wiki 目錄結構 + 預載知識。

### 3.6 建 CLAUDE.md

根據訪談結果產出使用者專屬的 `~/.claude/CLAUDE.md`，包含：
- 角色定義
- 領域邊界（從訪談第四組了解）
- 任務排序邏輯
- 完成標準
- 卡住時的 SOP

### 3.7 驗證

跑一次所有建好的 skill，確認正常。

---

## 原則

- **不替使用者決定。** 每個功能都問。
- **不一次全裝。** 猶豫的先不裝，之後再加。
- **不說教。** 直接討論設計決策。
- **用使用者的語言。** 她說中文就中文，說英文就英文。
- **她有完全的決策權。**
