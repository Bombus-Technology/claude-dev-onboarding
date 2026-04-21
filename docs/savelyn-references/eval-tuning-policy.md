# Eval Tuning Policy — Savelyn 的研究組織指令

> 這份是 Savelyn 寫給 eval-fix skill（以及未來的 /autoresearch）讀的**研究組織指令**。
> 概念來自 [Karpathy 的 autoresearch 設計](https://github.com/karpathy/autoresearch)：人不再寫 Python，改寫 Markdown 告訴 agent「什麼算好」。
>
> **每次 agent 要決定「這個 prompt 改動該保留還是回退」時，必須讀這份檔案當判斷標準。**

**最後更新：** 2026-04-17

---

## 1. Optimization Target（優化目標）

**主指標：overall pass rate**（`eval_chat_quality.py` 輸出的整體通過率）

**次指標（red line，任何改動違反這些就回退）：**

| Category | 規則 | 說明 |
|---|---|---|
| `anti_hallucination` | **絕不可退步超過 1%** | 幻覺回答對醫美行業是合規問題 |
| `security` | **絕不可退步超過 1%** | 含 prompt injection 防禦，不能破 |
| `booking` / `product` | 不可退步超過 3% | 核心業務 category |
| 其他 13 個 category | 不可退步超過 5% | 容許為了優化別處而小退 |

**完整 category 清單（17 個）：** anti_hallucination / product / chitchat / skin / short_message / anti_repeat / image / length / booking / security / line_overuse / edge / course_mapping / course_product_separation / guided_dialogue / budget / chitchat_no_rag

---

## 2. Simplicity Criterion（簡潔性判準）

**核心原則：只改善 eval 還不夠，還要兼顧 prompt 的維護性。**

### 🟢 保留（keep）— 符合任一條件

1. **Pass rate 有意義改善**（≥ 1%）且 prompt 複雜度**沒增加**（行數 / 段數相當或減少）
2. **Pass rate 持平**但 prompt **明顯簡化**（刪字、合併重複、消除矛盾）
3. **Pass rate 大幅改善**（≥ 3%）即使 prompt 稍微變長（≤ 15% 字數增加）
4. 重大安全修補（anti_hallucination / security 修到了邊界問題）

### 🔴 回退（discard）— 符合任一條件

1. **Pass rate 持平或微幅改善**（< 1%）但加了 > 20 行 hacky 文字 / 多層 conditional / 大量 edge case 處理
2. **任一 red line category 退步**（見第 1 節）
3. **Prompt 多了 > 30% 字數**但改善 < 2%（過度防禦）
4. 改動**邏輯複雜到 2 週後自己看不懂**

### 🟡 取決於你（ask Savelyn）— 不自動決定

1. 有 trade-off（A category ↑ 3%, B category ↓ 2%）
2. 改動本身有爭議（例如加了對話風格指示，可能被認為是「作弊」）
3. 改的是 architectural prompt（例如改 supervisor routing 的指令）

---

## 3. Stop Conditions（必停）

遇到任一條件**立刻停下報告**，不繼續迭代：

- **連續 3 次改動 pass rate 都沒改善** — agent 可能在原地打轉
- **Token 成本預估超過單次 session $5** — 提醒 Savelyn 再決定
- **任一 red line 連續 2 次觸發** — 當前方向明顯不對
- **Prompt 檔案大小超過 baseline 1.5 倍** — 過度累加，需要人介入做結構性重寫
- **發現需要動 `eval_chat_quality.py` 或 `eval_cases.py` 才能 pass** — 這是作弊警報，立刻停

---

## 4. Mutable vs Immutable 檔案

### 🟢 可以改（agent 可動）

- `agent_service/orchestrator/prompts.py`
- `agent_service/orchestrator/domain_prompt/`（所有 domain 特定 prompt）
- `agent_service/orchestrator/security/prompts.py`
- `agent_service/orchestrator/context_assembler.py`（只能改 prompt 相關邏輯）

### 🔴 絕不能改（immutable — 這是 ground truth）

- `agent_service/tests/eval_chat_quality.py`
- `agent_service/tests/eval_cases.py`（test cases 是評分標準）
- `agent_service/tests/eval_*.py` 其他檔案
- 任何 `agent_service/industry_configs/` 的結構（只能調值，不能動 schema）

**如果 agent 認為「這個 eval case 寫錯了」而想修 eval_cases.py → 無條件停下報告。** 這是 Savelyn 才能做的決策，agent 不該自己去改評分標準讓自己過。

---

## 5. Context 管理（不讓 output 塞爆 context）

### Eval 跑法

```bash
cd /home/savelyn/sage/sage-agent-platform
python agent_service/tests/eval_chat_quality.py --json > /tmp/eval-$(date +%s).log 2>&1
```

**永遠 redirect 到檔案**，不讓 stdout 直接進 context。

### 只 grep 關鍵指標

```bash
LOG=/tmp/eval-XXX.log
grep -E "overall_pass_rate|^[a-z_]+:\s+[0-9]+\.[0-9]+%|category.*pass" "$LOG"
```

如果需要看具體失敗 case，**只讀失敗 case 的對應段落**，不讀整個 log。

---

## 6. Experiment Log（results.tsv 格式）

每次 iteration **不論 keep / discard / crash 都要記錄**到：

```
~/.claude/wiki/eval-history/2026-04-17.tsv
```

**格式（tab-separated）：**

```
timestamp	commit_or_reset	overall_before	overall_after	changed_file	hypothesis	decision	reason
2026-04-17T22:30:15+08:00	a1b2c3d	87.2	88.5	prompts.py	加入「不確定就說不知道」指令避免幻覺	keep	+1.3% + red lines 持平
2026-04-17T22:45:02+08:00	RESET	88.5	85.1	domain_prompt/skin.md	加強禮貌語 template	discard	整體 -3.4% 過度防禦
2026-04-17T23:01:33+08:00	CRASH	88.5	null	security/prompts.py	加 7 層 injection pattern	crash	eval 跑到 120s 超時
```

**重要：**
- TSV **不 commit 進 git**（跟 Karpathy autoresearch 同理 — TSV 會頻繁增長且有時間資訊，進 git 會亂）
- commit 欄位是 keep 的 git hash；discard 時寫 "RESET"；crash 寫 "CRASH"
- hypothesis 欄位要**具體**（不是「改 prompt」而是「加入不確定就說不知道指令」）

---

## 7. Keep / Discard 執行機制（git 操作）

### Keep

```bash
cd /home/savelyn/sage/sage-agent-platform
git add <only the files agent actually changed>
git commit -m "experiment(eval): <hypothesis> — overall +X.X%"
# commit hash 記錄到 TSV
```

### Discard

```bash
cd /home/savelyn/sage/sage-agent-platform
git reset --hard HEAD   # 或 git checkout -- <files>
# TSV 記錄「RESET」
```

**重要：** 跑 eval-fix 前 **agent 必須先檢查 `git status`**。如果已有 uncommitted 改動（Savelyn 在另一個 session 改了但還沒 commit），**立刻停下問 Savelyn**。這些 uncommitted 改動是寶，不能被 git reset 吃掉。

---

## 8. 特殊情境處理

### 場景：Eval 有 variance（同樣 prompt 跑兩次結果微幅不同）

**目前簡化處理：** 只要**改善 ≥ 1%** 才算有效改善（小於 1% 當作 noise）。

**未來優化方向（open question）：**
- 是否要對每個 hypothesis 跑 2-3 次取平均？成本高但更準
- 是否要加「confidence interval」概念？

### 場景：改一個 prompt 同時影響多個 category

正常情況 — 接受，但要在 hypothesis 欄位**明確寫出預期影響的 category**。結果出來跟預期不符的話，**即使 overall 改善了也值得 Savelyn 看一下**，因為可能是意外的 side effect。

### 場景：Agent 卡在局部最優（連續 3 次都沒改善）

依 **Stop Condition #1** 停下來，並在最後報告列出：
- 已經嘗試過的 hypothesis
- 當前最佳 prompt 的主要弱點
- 建議 Savelyn 考慮哪些「更大改動」方向（例如重寫某段 prompt 而不是微調）

---

## 9. 相關文件

- [`architecture-snapshot.md`](../architecture-snapshot.md) — 系統架構基準
- [`my-toolbox.md`](my-toolbox.md) — 工具現況
- [Karpathy autoresearch](https://github.com/karpathy/autoresearch) — 靈感來源
