---
name: autopilot
description: 一口氣跑完「實作 → 自我驗證 → LangGraph 最佳實踐檢查 → code review → 總結」整條鏈。Savelyn 倒水 5-10 分鐘回來看結果用的。
user_invocable: true
---

# /autopilot — 一站式任務執行 + 審查鏈

使用方式：

```
/autopilot <任務描述>
```

範例：
- `/autopilot 在 capabilities/rag/agent.py 加一個 retry middleware，timeout 5 秒`
- `/autopilot 把 supervisor 的路由邏輯抽成獨立函式方便測試`
- `/autopilot orchestrator/state.py 加一個 request_id 欄位並傳到 output_guard`

**觸發後 Claude 自動跑以下 6 個 phase，中途不打擾 Savelyn 除非真的需要決定。跑完給 1 份結構化總結。**

---

## Phase 1：實作任務（Do it）

1. 讀取 Savelyn 的任務描述
2. 用 Grep / Read 理解相關 code（不要看全專案，只看任務相關的）
3. 用 Edit / Write 實作
4. **規則：**
   - 盡量少改動，不做 over-engineering
   - 如果任務描述不清楚到要做兩個根本不同方向的決策，**停下來問**（這是中途唯一允許打擾的例外）
   - 如果發現任務會破壞既有功能（例如改了公開 API 介面），**停下來說**，不要強行推進

---

## Phase 2：自我驗證（Did I actually do it?）

1. 跑 `git diff` 看實際改了什麼
2. 對照任務描述逐項檢查「我真的做到了嗎」
3. **寫成一小段文字**（供 Phase 6 使用）：
   ```
   ✅ 做到了：[具體列點]
   ⚠️ 部分做到：[什麼沒做]
   ❌ 沒做到：[為什麼]
   ```

---

## Phase 3：LangGraph 最佳實踐檢查（只在改到 orchestrator 相關才跑）

**觸發條件：** diff 包含下列任何路徑就跑：
- `agent_service/orchestrator/`
- `agent_service/capabilities/`
- `agent_service/guards/`
- `agent_service/core/retriever/`
- `agent_service/industry_configs/`
- `agent_service/tests/`

**動作：** 用 Task tool 呼叫 `graph-architect` subagent，prompt 給它：

```
Savelyn 剛改了以下檔案（git diff 結果貼上來），請從 LangGraph 最佳實踐角度 review：

1. State mutation 有沒有違反 LangGraph 規則（node 要 return partial state，不能直接改）
2. 有沒有破壞 conditional edges / fast path 邏輯
3. 新增 node/edge 的設計是否符合企業級標準
4. 對現有 supervisor / context_assembler 路由有沒有影響

給出：[✅ 通過] 或 [⚠️ 需注意 X] 或 [❌ 有問題 Y]，每個點要引用具體行數。簡短，不要整篇 essay。
```

**輸出：** 存成變數供 Phase 6 使用。

**不觸發時：** 寫「跳過（沒改到 orchestrator 區）」供 Phase 6 使用。

---

## Phase 4：Code Review（always 跑）

用 Task tool 呼叫 `code-reviewer` subagent（或者直接跑 `/review` skill），prompt 給它：

```
Savelyn 剛改了以下檔案（git diff 結果），請做 commit 前 review：

檢查：
- Mutation 安全（state、global、class attr）
- 型別正確性
- 安全性（injection、PII）
- LangGraph state mutation 規則
- 有沒有引入 dead code

輸出：[🔴 必修] / [🟡 建議] / [✅ 沒問題] 三段，每個都要引用具體行數。簡短。
```

**輸出：** 存成變數供 Phase 6 使用。

---

## Phase 5：Eval 建議（只在改到 prompt 相關才提示）

**觸發條件：** diff 包含下列任一：
- `agent_service/orchestrator/prompts.py`
- `agent_service/orchestrator/domain_prompt/`
- `agent_service/orchestrator/security/prompts.py`
- `agent_service/orchestrator/context_assembler.py`
- `agent_service/bid_review/prompts.py`

**動作：不自動跑 eval，只在 Phase 6 提示：**
> 「你改到 prompt 了，建議跑 `/eval-fix` 驗證沒有回歸」

**不觸發時：** 不提這段。

---

## Phase 6：總結輸出（給 Savelyn 倒水回來看的）

**固定格式：**

```markdown
## 🤖 Autopilot 完成：<任務一句話描述>

### ✅ 做了什麼

- [檔案名:行數] 改動摘要 1
- [檔案名:行數] 改動摘要 2
- ...

### 📋 自我驗證（Phase 2）

✅ 做到：...
⚠️ 部分做到：...（如果有）
❌ 沒做到：...（如果有）

### 🧩 LangGraph 最佳實踐檢查（Phase 3）

<graph-architect 的輸出；如果沒觸發就寫「跳過 — 沒改到 orchestrator 區」>

### 🔍 Code Review（Phase 4）

<code-reviewer 的輸出>

### 🎯 下一步建議

1. [具體動作，例如「跑 pytest 看單元測試」或「跑 /eval-fix」]
2. ...

### 📊 改動統計

- X files changed, +Y lines / -Z lines
- 主要影響：[一句話]
```

---

## 原則

1. **不中途打擾** — Phase 1-5 全自動跑，中途唯一可以打擾的情況是任務描述有根本歧義（兩個完全不同方向的選擇）
2. **不做事後 auto-fix** — review 發現問題時**只報告，不自己改**。Savelyn 看完總結再決定要不要修
3. **不自動 commit / push** — 永遠停在「已改好，請你確認」的狀態
4. **不自動跑 eval** — 只 suggest，讓 Savelyn 決定何時跑（eval 要好幾分鐘）
5. **失敗時停下來講** — Phase 1 做到一半如果 stuck，直接報告「我卡在這裡因為 X」，不要硬做下去產生垃圾
6. **用繁體中文**

---

## 適合的任務類型

**✅ 適合 autopilot 的：**
- 加 feature flag
- 抽 helper 函式
- 加 input validation
- 改一個 node 的內部邏輯
- 加單元測試
- 補 type annotation
- 改文件

**❌ 不適合 autopilot 的（該手動做）：**
- 改 graph 結構（加/刪 node、改 edge）— 這種要先討論架構
- 改 database schema
- 跨 repo 的大改動
- 不清楚方向的探索任務（「讓 X 更好」這種）
- 要做 A/B 比較的任務

如果 Savelyn 下的任務屬於「不適合」這類，**先提醒她**：
> 「這個任務風險較高，建議我們先討論一下方向再執行。要我先列出兩種做法讓你選嗎？」
