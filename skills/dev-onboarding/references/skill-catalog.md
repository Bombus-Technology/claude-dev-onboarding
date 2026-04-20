# Skill 候選清單 (v3.0 — 2026-04-20)

> 根據訪談結果選擇。v3.0 新增 Bombus 生產環境的 20+ 個實戰 skills。

## 任務管理

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `/today` | 讀 deadline + STATUS → 推薦今天焦點 | 有多個待辦的人 |
| `/done {task}` | 標記完成 → 更新 STATUS → 產出通知 | 需要回報進度的人 |
| `/stuck {問題}` | 記錄問題 → 推薦下一個任務 | 常卡住的人 |
| `/sprint-check` | 週 sprint 進度快速檢查 | Scrum team |
| `/ralph {task}` | 「不做完不要停」模式 — 持續推進直到完成 | 需要 momentum 的人 |

## 開發

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `/test {file}` | 跑特定檔案/模組的測試 | 頻繁跑測試的人 |
| `/test-all` | 跑整個 test suite | commit 前確認的人 |
| `/lint` | 跑 linter + auto fix | 要求 code style 的人 |
| `/bench {scenario}` | 跑效能 benchmark | 在意效能的人 |
| `/simplify` | 實作完 + 驗證通過後、commit 前精簡 code | 追求 clean code 的人 |

## Review / Plan Workflow (v3.0 新增)

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `/plan-ceo-review` | 新 RFC 的商業價值 + 範圍 review | PM 或 Lead |
| `/plan-eng-review` | CEO review PASS 後的架構 + 安全 + 測試 review | Tech Lead |
| `/review-savelyn` | 同事（Savelyn）commit 後的 review 流程 | 有 code review 需求的 Lead |
| `/debate {topic}` | 跨 repo 多觀點辯論（Product / Eng / Security / Ops） | 做重大決策的人 |

## AI/RAG 專用

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `/eval` | 跑 RAGAS evaluation suite | RAG 開發者 |
| `/eval-compare {a} {b}` | 比較兩版 eval 結果 | 常調 prompt 的人 |
| `/prompt-diff {file}` | prompt 修改前後差異 + eval 對比 | prompt engineer |
| `/graph-viz` | 印出當前 graph 接線圖 | LangGraph 開發者 |
| `/node-test {N3}` | 跑特定 node 的 golden test | graph node 開發者 |

## Knowledge / Wiki (v3.0 新增)

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `/wiki ingest {url}` | 把外部資源吃進 wiki + 抽概念 | 想累積知識的人 |
| `/wiki query {問題}` | 查 wiki 回答問題 | 有知識庫的人 |
| `/wiki lint` | Wiki 健康檢查（過時頁、孤立頁、死連結） | Wiki 維護者 |
| `/scout {topic}` | 技術偵察（AI/LLM/RAG 最新發展） | 做技術選型的人 |
| `/learn {topic}` | 學習紀錄 + 建連結 | 持續學習的人 |

## Automation / Operations (v3.0 新增)

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `continuous-learning` | Stop hook 自動從 session 萃取 patterns → instincts | 想累積經驗的人 |
| `continuous-learning-v2` | CLv2 進化版（+ session 開始建議升級 skill） | v1 用戶升級 |
| `handler-caller` | 直接呼叫 dispatch handler 做 ad-hoc 任務 | 有 automation 系統的人 |
| `auto-approve` | 自動批准低風險 tool call（減少 prompt 疲勞） | 信任 Claude 的人 |
| `iterative-retrieval` | 多輪 retrieval 優化（RAG 用戶）| RAG 進階 |

## Coding Standards (v3.0 新增)

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `coding-standards` | Language-agnostic 編碼規範參考 | 所有人 |
| `backend-patterns` | Backend 架構模式（Fastify/Express/Repo 等） | Backend |
| `frontend-patterns` | React/Next.js/Vue 模式 | Frontend |
| `postgres-patterns` | PostgreSQL 最佳實務 + migration | DB-heavy |
| `clickhouse-io` | ClickHouse 查詢 + ingest 模式 | 做分析的人 |
| `design-doc-mermaid` | Mermaid diagram 架構圖 | 做架構的人 |

## Eval / Testing (v3.0 新增)

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `eval-harness` | Eval harness 設計與實作 | AI/RAG 開發 |
| `security-review` | Security checklist 自動走完 | 碰敏感資料的人 |

## 部署 / CI/CD

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `/deploy {env}` | 部署到指定環境 + 健康檢查 | 用 Docker/K8s 的人 |
| `/rollback` | 快速 rollback 上一個 deploy | 生產環境用戶 |
| `/status` | 系統各服務狀態 + uptime | on-call |
| `cip-status` | CIP 部署狀態（Bombus 專用，可當模板）| 有多服務的人 |

## Document / BMAD (v3.0 新增)

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| `document-specialist` | 文件撰寫專業 guideline | 要寫正式文件的人 |
| `bmad` | Business Model / Architecture / Dev framework | 做產品設計的人 |

---

## 安裝方式

```bash
/dev-onboarding add skill eval-harness
# 或手動: cp templates/skills/template.md ~/.claude/skills/{name}/SKILL.md
```

## 建議組合

**首次使用者必裝:**
- `continuous-learning-v2` (行為學習)
- `coding-standards` (編碼規範)
- `/wiki` (知識累積)
- `/today` (任務管理)

**AI/RAG:** 加 `/eval` + `/prompt-diff` + `eval-harness` + `iterative-retrieval`

**Backend:** 加 `backend-patterns` + `postgres-patterns` + `security-review`

**Team Lead:** 加 `/plan-ceo-review` + `/plan-eng-review` + `/debate` + `/review-savelyn`

---

**References:**
- Source of truth: `Bombus-Technology/claude-dev-onboarding`
- Bombus 實測清單: `~/.claude/skills/`
- 更新頻率: 每週六 10:00 self-update.sh 自動 pull
