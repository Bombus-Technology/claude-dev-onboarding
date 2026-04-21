---
name: eval-fix
description: Eval 一鍵迭代 — 跑 eval → 分析失敗 → 建議改 prompt → 確認後改 → 重跑 → 依 policy keep/discard → 記錄到 results.tsv
user_invocable: true
---

# /eval-fix — Eval 一鍵迭代（autoresearch 風格）

原本的 5 步流程，加入 Karpathy autoresearch 的四個好習慣：
- **Context 管理**：eval output redirect 到 log 檔，只 grep 關鍵指標
- **Simplicity Criterion**：不只看 pass rate，也看 prompt 複雜度
- **Keep/Discard via git**：改善保留，沒改善 `git reset --hard` 回 baseline
- **Results TSV**：所有實驗（含 discard / crash）都記錄

**所有輸出一律使用繁體中文。**

---

## 必讀的 Policy

**每次 /eval-fix 開始前，先讀取：**

```
/home/savelyn/sav-agents/savelyn-wiki/playbooks/eval-tuning-policy.md
```

這份是 Savelyn 的研究組織指令，定義：
- 什麼算「改善」（overall pass rate + red line constraints）
- Simplicity Criterion（prompt 複雜度 trade-off）
- Immutable 檔案清單（eval_chat_quality.py / eval_cases.py 絕不能改）
- Keep / Discard 判斷規則
- Stop conditions

**policy 說什麼就照做。不要自己發明標準。**

---

## 使用方式

```
/eval-fix                    # 跑全部，修最差的 category
/eval-fix security           # 只修指定 category
```

---

## Phase 0：Pre-flight Check（必做）

```bash
cd /home/savelyn/sage/sage-agent-platform
git status --short
```

- 如果有 **uncommitted 改動**（Savelyn 在別的 session 正在改）→ **立刻停下問 Savelyn**，不能繼續（因為 discard 時的 `git reset --hard` 會吃掉她的改動）
- 如果 working tree 乾淨 → 記錄當前 HEAD commit 作 baseline 繼續
- 讀取 `eval-tuning-policy.md`

---

## Phase 1：跑 Baseline Eval

```bash
TIMESTAMP=$(date +%s)
BASELINE_LOG=/tmp/eval-baseline-${TIMESTAMP}.log
python agent_service/tests/eval_chat_quality.py --json > "$BASELINE_LOG" 2>&1
```

**Context 管理：只 grep 關鍵指標，不讀整個 log：**

```bash
grep -E "overall_pass_rate|category.*pass_rate|failed" "$BASELINE_LOG" | head -30
```

記錄：
- `overall_baseline` = X.X%
- 各 category baseline（特別是 red line：anti_hallucination / security）

如果 overall 已經 100% → 「🎉 全部通過，不需要修」→ 結束

---

## Phase 2：分析失敗 + 提出 Hypothesis

從 baseline log 找出失敗的 category 和具體 test case，讀取對應的 prompt 檔：

可改檔案（依 policy 第 4 節）：
- `agent_service/orchestrator/prompts.py`
- `agent_service/orchestrator/domain_prompt/`
- `agent_service/orchestrator/security/prompts.py`
- `agent_service/orchestrator/context_assembler.py`（只能動 prompt 相關邏輯）

**絕不能改**（policy 第 4 節 immutable）：
- `agent_service/tests/eval_chat_quality.py`
- `agent_service/tests/eval_cases.py`
- 如果發現「改 eval_cases 才能過」→ **無條件停下報告作弊警報**

產出一個**具體可執行的 hypothesis**：

```
假設：[一句話描述改動]
  - 改哪個檔案：xxx.py 第 N 行
  - 改成什麼：具體 prompt 文字
  - 預期影響 category：[列出]
  - 預期 pass rate 變化：X → Y
  - 風險：[特別標注 anti_hallucination / security]
```

**等 Savelyn 確認。不要自己改。**

---

## Phase 3：Savelyn 確認後改 Prompt

只改 Savelyn 同意的部分。不做 drive-by cleanup。

---

## Phase 4：重跑 Eval

```bash
AFTER_LOG=/tmp/eval-after-${TIMESTAMP}.log
python agent_service/tests/eval_chat_quality.py --json > "$AFTER_LOG" 2>&1
grep -E "overall_pass_rate|category.*pass_rate" "$AFTER_LOG" | head -30
```

---

## Phase 5：依 Policy 做 Keep / Discard 判斷

**對照 policy 第 1+2 節（Optimization Target + Simplicity Criterion）做判斷：**

### 先檢查 red line（policy 第 1 節）

- anti_hallucination 退步 > 1%？→ **DISCARD**
- security 退步 > 1%？→ **DISCARD**
- booking / product 退步 > 3%？→ **DISCARD**
- 其他 category 退步 > 5%？→ **DISCARD**

### 再套 Simplicity Criterion（policy 第 2 節）

- 🟢 Keep：pass rate +≥1% 且 prompt 沒變複雜 / 持平但 prompt 簡化 / 大幅改善（≥3%）即使 prompt 略長 / red line 修補
- 🔴 Discard：微改善但加 >20 行 hacky / prompt +30% 但改善 <2% / 邏輯太複雜
- 🟡 Ask Savelyn：有 trade-off / 爭議 / 改到 architectural prompt

### 執行判斷

**如果 Keep：**

```bash
cd /home/savelyn/sage/sage-agent-platform
git add <agent actually changed files>
git commit -m "experiment(eval): <hypothesis 摘要> — overall +X.X%"
COMMIT_HASH=$(git rev-parse --short HEAD)
```

**如果 Discard：**

```bash
cd /home/savelyn/sage/sage-agent-platform
git reset --hard HEAD  # 回到 Phase 0 記錄的 baseline
COMMIT_HASH="RESET"
```

**如果 Ask Savelyn：** 列出 trade-off 讓她決定，**不自己 commit 或 reset**。

---

## Phase 6：記錄到 Results TSV

**不論 keep / discard / crash / ask，都要記錄**。

```bash
TSV_DIR=~/.claude/wiki/eval-history
mkdir -p "$TSV_DIR"
TSV_FILE="$TSV_DIR/$(date +%Y-%m-%d).tsv"

# 首次建檔寫 header
if [ ! -f "$TSV_FILE" ]; then
    echo -e "timestamp\tcommit_or_reset\toverall_before\toverall_after\tchanged_file\thypothesis\tdecision\treason" > "$TSV_FILE"
fi

# 追加這次實驗
echo -e "$(date -Iseconds)\t${COMMIT_HASH}\t${BEFORE}\t${AFTER}\t${CHANGED_FILES}\t${HYPOTHESIS}\t${DECISION}\t${REASON}" >> "$TSV_FILE"
```

**TSV 絕不進 git**（依 policy 第 6 節，Karpathy autoresearch 同理）。

---

## Phase 7：結論輸出

```markdown
## 🧪 Eval-fix 實驗結果

**Baseline → After：** 87.2% → 88.5% (+1.3%)
**決策：** ✅ KEEP（commit `a1b2c3d`）

### 依 Policy 的判斷

- ✅ Red lines 通過：anti_hallucination 持平、security 持平、booking +0.5%、product 持平
- ✅ Simplicity Criterion 通過：prompt 字數 +3%，改善 +1.3% → 可接受
- ✅ 所有 category 退步都在容許範圍內

### 下一個可能 hypothesis

1. [建議下一個方向]
2. [建議下一個方向]

### 是否繼續迭代？

輸入：
- `next` → 執行下一個 hypothesis（進入新一輪 /eval-fix）
- `stop` → 結束，今天的實驗記錄已存在 `~/.claude/wiki/eval-history/$(date +%Y-%m-%d).tsv`
```

**不自動 loop**。每次只跑一輪，讓 Savelyn 決定要不要繼續。這跟 autoresearch 的 "NEVER STOP" 相反 — Savelyn 目前偏好掌控每一輪。

---

## 原則

1. **Policy 說了算** — `eval-tuning-policy.md` 是研究組織指令，不要自己發明標準
2. **Phase 2 到 Phase 3 之間一定等 Savelyn 確認**
3. **絕不改 immutable 檔案**（eval_chat_quality.py / eval_cases.py）
4. **Keep/Discard 用 git 機制**，不手動復原
5. **全部實驗記錄進 TSV**，包含 discard 和 crash
6. **不 auto loop** — 跑完一輪等 Savelyn 決定繼續 / 停
7. **發現作弊警報**（想動 eval_cases）→ 無條件停下

---

## Stop Conditions（policy 第 3 節，必停不可談）

- 連續 3 次改動沒改善 → 報告 + 建議考慮重寫
- 任一 red line 連續 2 次觸發 → 當前方向不對
- Prompt 檔案大小超過 baseline 1.5x → 需要結構性重寫
- 需要改 eval 才能過 → 作弊警報，立刻停
- Token 預估 > $5 → 提醒 Savelyn
