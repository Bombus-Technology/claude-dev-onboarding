# Sage Agent Platform — Architecture Snapshot

> 這份是 **tech-radar.sh 每天讀取的基準檔**，用來比對今日的 LangGraph / Agentic 技術更新。
> 由 Savelyn 維護，orchestrator 有大改時手動重新產生。
> 可以呼叫 `/graph-viz` skill 或 `graph-architect` agent 重新讀 code 產出最新版。

**最後更新：** 2026-04-15
**完整深度版（給人讀的）：** [`architecture/sage-orchestrator-deep-dive.md`](architecture/sage-orchestrator-deep-dive.md)
**資料來源：** 由 `graph-architect` agent 讀取下列檔案彙整：
  - `agent_service/orchestrator/graph.py` (GRAPH_VERSION = 3.1.0)
  - `agent_service/orchestrator/runner_pkg/_helpers.py` (legacy graph 路徑)
  - `agent_service/orchestrator/task_team/graph.py` + 5 個節點
  - `agent_service/orchestrator/{state,context_assembler,supervisor,response_generator,response_validator,budget_price_appender,post_answer_asset_matcher,output_guard}.py`
  - `agent_service/guards/{input_guard,output_guard}.py`
  - `agent_service/capabilities/{rag,structured_kb}/agent.py`
  - `agent_service/orchestrator/nodes/n0-n10/`（仍在 legacy graph 中使用）
  - `docs/MIGRATION-260415-luvaii-from-core.md`

---

## LangGraph 版本與依賴

- `langgraph>=0.2.0`（⚠️ **可能落後 1.x GA**，需要 `pip show langgraph` 確認實際版本）
- `langgraph-checkpoint-postgres>=2.0.0`（已到 3.x，有 breaking schema change）
- `langchain-core>=0.1.0`
- `langchain-openai>=0.1.0`
- `langchain-chroma>=0.1.0`
- `langchain-experimental>=0.0.50`
- **未使用：** langchain-huggingface（移除以省 torch/nvidia 6.7GB），改用遠端 embedding service

## Checkpointer

- **Production：** `AsyncPostgresSaver`（由 `main.py` 注入，見 ADR-11）
- **Dev / Test：** `MemorySaver` fallback

---

## 主 Graph (orchestrator/graph.py, v3.1.0)

```
START
  ▼
input_guard
  ├─[injection_blocked]─→ context_assembler (fast path)
  └─[normal]──→ supervisor ⟲ {structured_kb_node, rag_agent, skip_rag → context_assembler}
                  ▼ (done)
                context_assembler
                  ├─[fast path: blocked/emergency/fallback/non_skin_photo/error]──→ output_guard
                  └─[normal]──→ response_generator → response_validator
                                  → budget_price_appender (B5)
                                  → post_answer_asset_matcher (B7)
                                  → output_guard
                                  ▼
                                END
```

### 主 Graph 節點清單（11 個 + 動態 capabilities）

| 節點 | 檔案 | 暱稱 | 職責 |
|---|---|---|---|
| `input_guard` | `guards/input_guard.py` | 門口警衛 | Prompt injection 偵測、PII masking、risk gate、emergency 關鍵字 |
| `supervisor` | `orchestrator/supervisor.py` | 純規則路由器（ADR-03） | classify_intent → evaluate_skip_rag → 路由（structured/rag/skip）→ 回流路由 |
| `structured_kb_node` | `capabilities/structured_kb/agent.py` | 結構化 KB | budget 引擎（B4 whitelist）+ routine + booking |
| `rag_agent`（動態註冊） | `capabilities/rag/agent.py` | RAG 子圖 | triage / retrieve / crag / rewrite + B6 非皮膚早退 + B7 預選圖 |
| `context_assembler` | `orchestrator/context_assembler.py` | 場布 | P1 fast path 偵測 + B5 budget 兩段式 + B1/B3 皮膚 concern + domain prompt |
| `response_generator` | `orchestrator/response_generator.py` | VLM 生成器 | 組 messages + 呼 VLM + retry max=3 指數 backoff (1s/2s/4s) + stream |
| `response_validator` | `orchestrator/response_validator.py` | 校對編輯 | parse_compose_json + validate (AUTO_FIX) + 收 policy_notes |
| `budget_price_appender` | `orchestrator/budget_price_appender.py` | **B5 第二段附價目** ✨ | 非 budget pass-through；budget 則 intro + price + 免責 + idempotency guard |
| `post_answer_asset_matcher` | `orchestrator/post_answer_asset_matcher.py` | **B7 回答後對圖** ✨ | 從 **bold** 抽產品名 → fuzzy match → 0 命中啟動二次檢索 → MAX_IMAGES=6 |
| `output_guard` | `guards/output_guard.py` | 最後安檢 | check_terminal_output_guard (CircuitBreaker timeout=3.0s) + 寫 messages 持久化 |

✨ = Luvaii 遷移（260415）新增節點

---

## Task Team Subgraph（`orchestrator/task_team/`）

> ⚠️ 這個子圖**目前未被主 graph.py import**，是獨立模組。Savelyn 待評估接入主流程的方式（LangGraph 1.x 的 `interrupt()` API 是好選擇）

```
START → planner ─[requires_approval]→ approval_gate ─[interrupt() 等 {approved: bool}]
           │                                ├─[rejected]→ END
           │                                └─[approved]→ executor_loop
           └─[no approval]──────────────────────────────→ executor_loop
                                                            ▼
                                                          aggregator (純函式)
                                                            ▼
                                                          reviewer (LLM JSON, temp=0.1)
                                                            ├─[passed or retry≥max(=2)]→ END
                                                            └─[retry]→ planner（帶 review_feedback）
```

| 節點 | 暱稱 | 職責 |
|---|---|---|
| `planner` | 規劃師 | LLM JSON mode → `{reasoning, plan: [SubTask]}`，驗證 skill name，標 requires_approval |
| `approval_gate` | 人審關卡 | `interrupt()` 暫停，等使用者 resume |
| `executor_loop` | 執行官 | depends_on topo sort + 注入先前結果 + hard token budget |
| `aggregator` | 彙整員 | 純函式：分 success/failed/skipped → aggregated_result |
| `reviewer` | 品管 | LLM JSON 評分，max_retries=2 |

---

## Legacy Graph（`runner_pkg/_helpers.py` + `orchestrator/nodes/n*.py`）

> 🔴 **修正之前的錯誤判斷**：之前 snapshot 寫「nodes/n*.py 是 dead code」是錯的。實際上 `runner_pkg/_helpers.py` **仍在使用** n0-n10 構建另一條 graph。代表系統有**兩條 graph 路徑共存**。

11 個節點：
- `n0_input_guard` / `n1_preprocess` / `n2_risk_gate` / `n3_vlm_triage` / `n4_intent_router` / `n5_tool_fetch` / `n6_rag_retrieve` / `n7_crag_gate` / `n8_composer` / `n9_asset_selector` / `n10_safety_filter`

**Savelyn 待釐清：** 兩條 graph 是並行運行還是 A/B test？什麼條件路由到哪一條？這個資訊不在 snapshot 裡，需要她驗證。

---

## P1 Fast Paths（不進 LLM 的捷徑）

`_FAST_PATH_SOURCES` = {
- `"blocked"` — injection 被擋
- `"emergency"` — 自殺 / 急症關鍵字
- `"fallback"` — CRAG rewrite 用盡
- `"non_skin_photo"` — B6：VLM 判定非皮膚照
- `"error"` — 通用錯誤
}

⚠️ `"budget"` **不在此集合** — 走完整 pipeline 含 B5 兩段式

---

## Conditional Edges

1. **`_after_input_guard`** — `state.security_result.injection_blocked == True` → 跳到 `context_assembler` fast path
2. **`_after_context_assembler`** — `state.response_source ∈ _FAST_PATH_SOURCES` → 跳過 generator/validator/B5/B7，直達 `output_guard`

---

## Capability 子圖

### RAG (`capabilities/rag/`)
獨立子圖，含 `agent.py` / `graph.py` / `asset_matcher.py` / `image_triage.py` / `prompt_builder.py` / `state.py`。
從主 graph 的 `rag_agent` 節點進入，內部包含 B6 非皮膚 image_triage 早退 + B7 預選 selected_images。

### Structured KB (`capabilities/structured_kb/agent.py`)
查詢結構化資料（療程、產品、價目）。**不走 RAG**，是另一條路。包含 B4 budget whitelist 過濾。

---

## CIP Tagging — **不在 graph 裡**

- 在 runner post-processing 以 fire-and-forget 執行
- Rationale：tagging 不影響 response 內容，放進 graph 會破壞 checkpoint semantics
- 參考：https://docs.langchain.com/oss/python/langgraph/thinking-in-langgraph

---

## State 結構

### 持久欄位（跨 turn 由 checkpointer 保留）
- `messages`（add_messages reducer）
- `tenant_id` / `session_id`
- `runtime_config` / `kb_name`

### 暫態欄位（每 turn 重設）
- 輸入：`user_input`, `image_paths`, `chat_history`
- 安全：`security_result`, `intent_result`
- 路由：`skip_rag`, `rag_result`, `structured_kb_result`
- 組裝：`context_prompt`, `user_message_for_vlm`
- B5 新增：`budget_price_section`
- 輸出：`final_response`, `compose_json`, `response_source`, `execution_trace`

---

## 使用的 LangGraph 特性

- ✅ `StateGraph` + `AgentState` TypedDict
- ✅ `add_conditional_edges`（fast path 判斷）
- ✅ Dynamic node registration via `DEFAULT_CAPABILITIES` dict
- ✅ Subgraph via `capabilities/*/graph.py`
- ✅ `AsyncPostgresSaver` production checkpointer
- ✅ `END` explicit terminal
- ✅ `Command(goto=...)` from supervisor
- ✅ `interrupt()` for human-in-the-loop（task_team 內，未接入主 graph）
- ✅ `get_stream_writer()` 邊產生邊送 token

---

## Luvaii 遷移（2026-04-15）新增 / 修改

- **新節點：** `budget_price_appender`（B5 兩段式）/ `post_answer_asset_matcher`（B7 回答後對圖）
- **context_assembler 內：** B1/B3 皮膚 concern 注入、B5 intro-only budget 組裝、B6 非皮膚照 fast path
- **RAG subgraph 內：** B6 image_triage 早退、B7 預選 selected_images
- **structured_kb 內：** B4 whitelist 過濾
- **eval cases：** 65 → 113（新增 D 類）

---

## Savelyn 待驗證 / 技術債

- [ ] **legacy graph 還在用：** `runner_pkg/_helpers.py` 用 n0-n10。是 A/B / 並行 / 還是 fallback？什麼條件路由到哪一條？
- [ ] **task_team 接入主 graph：** 用 LangGraph 1.x 的 `interrupt()` API 接 `approval_gate`
- [ ] **LangGraph 版本：** 跑 `pip show langgraph` 看是否真的落後 1.1.x
- [ ] **`langgraph-checkpoint-postgres` 升級：** 2.x → 3.x 需要 schema migration
- [ ] **supervisor 迴圈防呆：** loop 上限機制？

---

## 最近重大變動

- **2026-04-15** — 由 `graph-architect` agent 重新讀取 code 重寫，修正 nodes/n*.py 不是 dead code、補上 budget_price_appender + post_answer_asset_matcher、補上 task_team 子圖細節、補上 fast path 5 個來源
- **2026-04-14** — 初始建立 snapshot（基於 graph.py GRAPH_VERSION 3.1.0）

---

## tech-radar.sh 使用這份 snapshot 的方式

tech-radar 每天 06:00 台灣 跑時會讀這份檔，然後 WebSearch 今天的 LangGraph / Agentic 更新，產出報告時**針對**：

1. LangGraph 0.2.x → 1.1.x 的 migration 路徑（你 pin 太舊）
2. `interrupt()` API → 接 task_team approval_gate 的具體做法
3. Supervisor pattern 的最佳實踐演進
4. Conditional edges / dynamic routing 的新做法
5. Corrective / Self-Reflective RAG 的新技術
6. `langgraph-checkpoint-postgres` 3.x migration
7. `structured_kb_node` 式的 KB 查詢 vs 純 RAG 的混合策略
8. **legacy n0-n10 graph 是否該整併到主 graph**

**期望比對結論：**
> LangGraph 1.0 GA 的 `interrupt()` API 取代舊 polling 機制 → 你的 `task_team/approval_gate.py`（目前未接入主 graph）可以用這個 API 直接接到 supervisor 的下游，不用自己做暫停輪詢。
