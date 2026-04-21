# Review of claude-dev-onboarding — from Savelyn

> ## 🚫 這個分支不要 merge 進 master
>
> 這是 **Savelyn 個人 review 分支**，不是要合進主線的 feature branch。目的是：
> - 給 Allen 看我 fork 後的客製軌跡
> - 分享我踩的坑 / 做的修改 / 給你的建議
> - 留作歷史紀錄（之後我進化了這套 workflow，Allen 想看演變可以回來看）
>
> **裡面的 reference 檔都是 Savelyn-specific**（eval-tuning-policy.md 是她工作流專用、architecture-snapshot.md 是 sage-agent-platform 內部架構快照等），整個 merge 會污染 master。
>
> **如果有具體內容想採用：** 手動 cherry-pick 到 master 的新 commit，或把 idea 寫進你自己的 SKILL.md / reference，不要整個 merge。

---

> 寫給 Allen。從一個實際 fork 過你設計的使用者角度，回報我怎麼用、改了什麼、踩了什麼坑、有什麼建議。
> 不是批評，是兩個 persona 對照下你設計如何延伸的觀察。

**時間：** 2026-04-21
**分支：** `savelyn-fork-review-260421`（review / FYI only，**不要 merge**）
**Fork baseline：** `8e6eb3c`（2026-04-15 的 master）
**你後續更新的 v3.0（automation-loop-guide / completion-discipline / notification-taxonomy）我都讀了**，部分對照寫在最後一節。

---

## TL;DR

1. 我跑 `/dev-onboarding` 一次，之後的變化全是手動客製 — **我是 editor mode，不是 subscriber mode**
2. 最大發現：你的 dev-onboarding 預設使用者是 subscriber（等推薦、等 catalog sync、等 CLv2 建議）。但我這種 AI 工程師是 editor — 遇到痛點直接講「幫我建 / 改 / 刪」
3. 我完整 archive 了 dev-onboarding skill 本身（editor mode 用不到 installer），但**保留並擴充你 daily-learn-summary / tech-radar / observe.sh 這些背景機制**
4. 對照我 profile.json 的 5 個 pain points，**每個都對應我做的某個修改**（見第 5 節）
5. 你 v3.0 的 `notification-taxonomy` 超讚，我的 Discord 推播應該也改成這個分類

---

## 1. 我是誰 / 怎麼用

- **角色：** AI 工程師，負責 `sage-agent-platform/agent_service/` 核心（orchestrator / capabilities / guards / retriever / evaluation / industry_configs / tests）
- **技術棧：** LangGraph + Python + Qwen（跑在 vLLM + LiteLLM）+ ChromaDB + FlagEmbedding + DeepEval
- **工作風格：** Cursor IDE + Claude Code extension，同時開 2-3 個 session，不同任務平行
- **協作：** 跟 Allen（你）共同開發，我負責 agent 的腦、你負責 backend/portal/gateway

---

## 2. 重大發現：Editor Mode vs Subscriber Mode

跑你的 dev-onboarding 一次後（2026-04-09，interview 20 題），我**被動訂閱模式**（catalog sync / CLv2 instinct → skill 升級 / session start 提示新工具）**完全沒啟動**：

- `crontab` 從沒有 `self-update.sh` entry
- `~/.claude/homunculus/instincts/` 是空的
- `dev-onboarding-profile.json` 從 2026-04-09 起 `review_count: 0`, `last_review: null`
- 我從沒打過第二次 `/dev-onboarding`

**不是 dev-onboarding 壞掉，是我沒在用它設定的迴路。**

原因：當我遇到痛點（例如「tech-radar 每天跟我幻覺式比對 LangGraph」），我的反應是**直接跟 Claude 說「修」**，不是等 catalog 更新、不是等 CLv2 建議。

我把這個模式命名為 **editor mode**：
- subscriber mode = 系統推薦 → 使用者確認 → 安裝
- editor mode = 使用者遇到痛 → 講 → Claude 建/改/刪 → 直接可用

這兩種不分好壞，但**你 dev-onboarding 的「漸進式 + 系統自動建議」** 默認是 subscriber 設計，**對 editor-style 使用者不 fit**。

---

## 3. 我做的重大修改

### 3.1 完全 archive 的東西

```
~/.claude/skills/dev-onboarding/          → 移到 _archive/dev-onboarding-260409/
~/.claude/dev-onboarding-profile.json     → 移到 _archive/dev-onboarding-profile-260409.json
~/.claude/hooks/boundary-check.sh         → 移到 _archive（發現它是 no-op，空殼 hook）
~/.claude/hooks/session-debrief.sh        → 移到 _archive（Stop hook 從沒被接上）
```

### 3.2 保留並繼續運作的（你設計得對的）

- `~/.claude/hooks/observe.sh` — **每天記 400+ 筆**，真的在運作，非常有用
- `~/.claude/hooks/continuous-learning.sh` — 產 `patterns/detected.json`，每週看一次有洞察
- `~/.claude/hooks/daily-learn-summary.sh` — 每晚 19:00 萃取 6 種知識，這個設計太讚了
- `~/.claude/hooks/tech-radar.sh` / `ai-daily.sh` — 保留，但大改了 prompt（見 3.3）
- `~/.claude/skills/{brief,eval,eval-compare,eval-fix,graph-viz,review}/` — 保留

### 3.3 大改造的 hook（保留但邏輯重寫）

**tech-radar.sh：**
- ❌ 原本 prompt 寫死「我們用 LangGraph + supervisor pattern + RAG subgraph + MCP」當基準 — 幻覺式比對
- ✅ 改成讀 `savelyn-wiki/architecture-snapshot.md` 當真實 baseline，每天 dedup（不重複報昨天同新聞）
- ✅ 加 `export TZ="Asia/Taipei"`（vixie-cron 沒 CRON_TZ 支援，原本檔名日期錯一天）
- ✅ 搜尋方向加 Qwen / vLLM / LLM Security（配對我 stack）

**daily-brief.sh（從 `allen-alert.sh` 改名）：**
- ❌ 原本 hardcoded 單一 repo（sage-agent-platform），author pattern `Allen\|allen\|bombus` 會 match 到 `savelyn@bombus.com.tw` 導致 Savelyn commit 也被抓進 Allen 段
- ✅ 擴成 3 repo（agent-platform + ops + infra）
- ✅ Pattern 改 `[Aa]llen` / `[Ss]avelyn`（不用 `bombus`）
- ✅ 保留 by-author 分段（Allen 段 / Savelyn 段），這是**核心價值，不能拿掉** — 我追蹤 Allen 改動的唯一管道
- ✅ Savelyn protected areas 擴大到 7 個子目錄

**daily-learn-summary.sh：**
- ✅ `PROJECTS_ROOT` 改成 `-home-savelyn-sage-sage-*` glob，只萃取 sage 工作 session，其他 session（allen-wiki / dev-onboarding）不處理避免雜訊
- ✅ 去掉 prompt 裡「跟 Allen 的任務溝通」硬寫，改成通用「協作對象」

### 3.4 新建的 skill（dev-onboarding catalog 裡沒有）

```
~/.claude/skills/autopilot/SKILL.md     ← 我新寫
~/.claude/skills/help/SKILL.md          ← 我新寫
```

- **`/autopilot <task>`** — 一站式執行：實作 → 自我驗證 → graph-architect 檢查（如改到我的區）→ code-reviewer → 總結。解決「倒水前丟任務，回來看結果」場景
- **`/help`** — 動態讀 `my-toolbox.md` 產場景導向 cheat sheet。不是靜態文件，每次呼叫都重讀 source of truth

### 3.5 新建的 cron

```
30 11 * * * ~/.claude/hooks/daily-progress.sh  ← 台灣 19:30
```

- **daily-progress.sh** — 每天整合 3 repo commits + 今日 wiki 新增 + observations 統計 + 7 天 patterns → claude CLI 組日進度報告 → 推新 Discord #progress 頻道
- 用途：晚餐後手機一看「我今天做了什麼」，累積成週報 / 月報 / 季報素材

### 3.6 新建的知識中樞（fork allen-wiki）

```
/home/savelyn/sav-agents/savelyn-wiki/
├── CLAUDE.md                          ← 改成 Savelyn 視角，拿掉 Manager Session 回報機制
├── index.md                           ← 清掉 Allen 專屬（Manager / 決策 / playbook / 醫美 / SaaS 商業 / 數據分析）
├── log.md                             ← 重新開始
├── architecture-snapshot.md           ← 給 tech-radar 讀的 Sage 真實架構（機器讀）
├── architecture/
│   └── sage-orchestrator-deep-dive.md  ← graph-architect agent 產出的完整架構（人讀）
├── playbooks/
│   ├── my-toolbox.md                  ← 活文件，取代過期的 dev-onboarding-profile.json
│   └── eval-tuning-policy.md          ← 我的「program.md」實踐（見 3.7）
└── domains/
    ├── ai-agents/                      ← 沿用你的，可補充
    └── infrastructure/                 ← 沿用你的，可補充
```

Git init 了，commit history 顯示每個重大客製。

### 3.7 借用 Karpathy autoresearch 概念（Option B — 輕量版）

我讀了 [karpathy/autoresearch](https://github.com/karpathy/autoresearch)。它的三層架構（prepare.py / train.py / program.md）**跟你的 ground-truth + mutable + catalog 概念有呼應**，但它把「什麼算好」獨立成 Markdown 檔（`program.md`），這是 editor mode 的**關鍵設計**。

我在 `savelyn-wiki/playbooks/eval-tuning-policy.md` 實踐這個：

- 我寫規則（red line category / Simplicity Criterion / stop conditions / immutable 檔案清單）
- `/eval-fix` skill 每次執行時**讀這份 policy**，不硬 code 規則
- 我改 policy → 下次 /eval-fix 自動反映，不用動 skill 程式碼

同時把 autoresearch 的 4 個好習慣塞進 `/eval-fix`：
- Context 管理（log 檔 + grep 關鍵指標，不讀整個 eval output）
- Simplicity Criterion（不只看 pass rate，看 prompt 複雜度）
- Keep / Discard via git（成功 commit、失敗 `git reset --hard`）
- Results TSV（每次迭代都記錄，不進 git — 跟 autoresearch 同理）

**沒採用 autoresearch 的 "NEVER STOP"** — 我偏好每輪確認，不是 overnight autonomous。

---

## 4. Allen 地盤 / Savelyn 地盤 的分工保護

從 `sage-agent-platform/docs/WORK_BOUNDARIES.md` 看：

| 你的地盤 | 我的地盤 |
|---|---|
| `backend/` / `unified-portal/` / `external-api-gateway/` / `embedding_service/` / `agent_service/bid_review/` | `agent_service/{orchestrator,capabilities,guards,core/retriever,evaluation,industry_configs,tests}/` |

我的 `/autopilot` skill 有 **Hard Limit**：絕對不動你的地盤（理由是這是**團隊契約**不是技術判斷，AI 沒資格自己判斷要不要跨界）。

`daily-brief.sh` 的 `⚠️ Allen 改到你的區域` 警告範圍對齊這個邊界。

---

## 5. 對照 profile.json 的 pain points

你的 dev-onboarding interview 把我的痛點記下來：

| Pain Point | 我做的解決方案 |
|---|---|
| 「開發中持續的不確定感——每一步都想確認方向對不對」 | **`architecture-snapshot.md` + `graph-architect` agent** — agent 讀真實 code 比對真實架構，給具體引用不是泛泛回答 |
| 「Allen 大改架構後需重新理解系統」 | **daily-brief 3 repo by-author + protected area 警告** — 你改完我第二天早上就知道影響到哪 |
| 「理解 vs 速度 vs 正確性的三方拉扯」 | **`/autopilot` Hard Limit + Principled Reasoning 混合模式** — 3 條硬規則（不可逆、團隊契約、安全）不能繞，其他用引用式 reasoning 判斷 |
| 「跨機器 sync 麻煩」 | savelyn-wiki git init — 未來可以 push GitHub 跨機器 clone |
| 「架構頻繁變動難追蹤」 | **architecture-snapshot.md 進 git** — 每次重產就有 diff，看架構怎麼演化 |

---

## 6. 給 Allen 的建議

### 🟢 建議加進 dev-onboarding catalog 的

1. **`autopilot` skill** — 「倒水前丟任務、回來看結果」的 chained execution（實作 → 自我驗證 → 相關 agent review → 總結）。這個對 editor mode 使用者超實用，對 subscriber 可能用不太到，但 catalog 裡可以列為「task-executor」類
2. **`help` skill（動態 cheat sheet）** — 讀使用者 toolbox 活文件動態產速查表。解決「工具太多忘記用法」問題
3. **`eval-tuning-policy.md` 機制** — 讓 `/eval-fix` 讀外部 policy 而不是硬 code 規則。類比 Karpathy `program.md`。這讓使用者可以調參不用改 skill

### 🟡 建議標注「適合哪種使用者」

Catalog 裡建議標：
- **subscriber-friendly**（例如 catalog self-update, CLv2 instinct upgrade）
- **editor-friendly**（例如 architecture-snapshot 機制、eval-tuning-policy pattern、daily-brief by-author）
- **通用**（observe、auto-test、learning summary）

讓新使用者跑 `/dev-onboarding` 訪談時先釐清自己是哪種 mode，再推薦對應的組合。

### 🟡 Persona 細節

`skill-catalog.md` 裡 `debugger agent` 這類名字太泛。建議改成：
- `prompt-tuner`（RAG / agentic）
- `rag-debugger`（分層診斷 retrieval vs generation vs prompt）
- `graph-architect`（LangGraph 架構 review）

這些我在 `~/.claude/agents/` 實際做出來了，name 和邊界清楚 agent 才好用。

### 🔴 建議修的問題

1. **`allen-alert.sh` naming** — 對你本人沒問題，但 fork 給其他人用時很怪（我改叫 `daily-brief.sh`）。建議 catalog 版用中性 name
2. **`Allen\|allen\|bombus` author pattern** — Bombus 所有人 email 都在 `bombus.com.tw`，這個 pattern 會 match 所有人。catalog 版建議使用者自己填 author pattern 或自動讀 `git config`
3. **cron 時區問題** — `tech-radar.sh` / `ai-daily.sh` 原本沒 `export TZ`，`$(date +%Y-%m-%d)` 產出的 UTC 日期跟 daily-brief 的台灣日期錯開。catalog 版建議一律強制設 TZ
4. **cron 裡 PATH** — vixie-cron 的 PATH 很簡陋，`claude` CLI 不在預設 PATH。catalog 建議 install 時自動加 `PATH=$HOME/.local/bin:...` 進 crontab header

### 🟢 你 v3.0 新文件的對照

我讀了你 4/19-4/20 加的三份：

| Allen v3.0 文件 | 我的對應實踐 |
|---|---|
| `automation-loop-guide.md` 「Allen 做判斷，系統做執行」 | **相反** — 我是 editor mode，「使用者做判斷**和**執行，系統記錄 + 學習 + 提醒」。建議文件開頭標注「適合哪種 persona」 |
| `completion-discipline.md` 「結束工作 ≠ 完成任務」 | **非常認同**。我的 `/eval-fix` keep-via-git 就是這個精神 — commit 只在真正改善才進 |
| `notification-taxonomy.md` 4 級分類（alert / decision / milestone / info） | **超讚，我立刻要用**。我的 Discord 推播目前混在一起沒分類。建議 catalog 裡把這個 taxonomy 內建成推播 metadata |

---

## 7. 附錄：我的檔案實踐範例

在 `docs/savelyn-references/` 底下放了 5 個參考檔，都是我實際在用的版本：

```
docs/savelyn-references/
├── autopilot-SKILL.md              ← 新寫的 chained execution skill
├── eval-fix-SKILL.md               ← 改寫的 autoresearch 風格（讀 policy）
├── eval-tuning-policy.md           ← 我的「program.md」實踐
├── help-SKILL.md                   ← 動態 cheat sheet
└── architecture-snapshot.md        ← 架構比對基準範例（Sage-specific，看 pattern 不是內容）
```

你看 reference 比看我描述更具體。有想合併進 catalog 的就自己拿。

---

## 8. 總結

- **你的 dev-onboarding 架構是對的**（prepare / train / program 三層分離），但**預設 subscriber mode 讓我這種 editor-style 使用者用不太到 installer 層**
- **背景機制超有價值**（observe / learning-summary / tech-radar / patterns） — 這些是核心，建議繼續強化
- **前景機制**（catalog sync / CLv2 instinct）對我沒啟動，但我相信對新手有用
- **editor mode 的支援**（讓使用者直接「講、改、刪」，不用訂閱）可以加進 catalog 當第二條軌道
- **你 v3.0 的 notification-taxonomy 我要偷用**，謝謝

有問題或想討論具體技術細節隨時 Slack 找我。

— Savelyn
