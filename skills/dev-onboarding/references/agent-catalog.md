# Agent 候選清單 (v3.0 — 2026-04-20)

> 根據使用者訪談結果選擇。不是全部都要裝。
> v3.0 擴充：新增 Bombus 生產環境 12 天累積的 agents。

## 核心開發類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| `code-reviewer` | sonnet | commit 前自動 review：mutation/安全/型別/OWASP | 想要 code 品質保證的人 |
| `security-reviewer` | sonnet | 掃 PII/injection/認證/secret 外洩 | 碰敏感資料的人 |
| `build-error-resolver` | haiku | TypeScript/build 錯誤最小修正 | build 常壞的人 |
| `refactor-cleaner` | sonnet | 找 dead code + knip/depcheck/ts-prune 清理 | 有技術債的人 |
| `tdd-guide` | sonnet | 寫測試先於寫 code（TDD enforcer）| 重視測試覆蓋率的人 |
| `database-reviewer` | sonnet | PostgreSQL query/schema/migration 審查 | DB-heavy 專案 |
| `e2e-runner` | sonnet | Playwright E2E test 自動跑 + 截圖 | 前端 critical flow 驗證 |
| `doc-updater` | haiku | 更新 codemap / README / guides | 不喜歡寫文件的人 |

## 規劃/架構類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| `planner` | sonnet | 複雜 feature 的多階段 plan + 風險分析 | 做大專案的人 |
| `architect` | opus | 系統設計、scalability、技術決策 | 做架構決策的人 |
| `Plan` | opus | Ad-hoc 的單次 implementation plan | 臨時需要 plan 的人 |
| `Explore` | haiku | 快速 codebase 探索（glob/grep 多輪）| 需要快速搞懂 repo 的人 |

## AI/ML 類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| `prompt-tuner` | opus | 分析 eval 結果 → 建議 prompt 改進 + A/B | 常調 prompt 的人 |
| `eval-runner` | sonnet | 跑 RAGAS/自訂 eval suite → 報告 | RAG 開發者 |
| `graph-architect` | opus | LangGraph 接線設計 + 流程圖 + 依賴檢查 | 設計 graph pipeline 的人 |
| `rag-debugger` | sonnet | 分析 RAG 回答品質（retrieval vs generation）| RAG 開發者 |

## SRE / 維運類 (v3.0 新增)

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| `discord-sre` | sonnet | 伺服器監控 + CI/CD 維護 + docker 狀態 + 告警分級 | SRE / on-call |
| `codex-rescue` | opus | Claude Code 卡住時派 Codex 做深度診斷 | debug > 30min 的人 |
| `statusline-setup` | haiku | Claude Code status line 配置 | 個人化喜好 |

## 專案管理類 (v3.0 新增)

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| `discord-pm` | sonnet | 進度追蹤 + standup + 客戶會議準備 | PM 或自管專案的人 |
| `tech-scout-orchestrator` | sonnet | 追蹤 AI/LLM/RAG 最新發展 + 評估採用 | 需要技術偵察的人 |
| `exec-assistant` | sonnet | 主管執行助理（會議/文件/策略引導）| 管理職 |
| `daily-briefing` | sonnet | 每日簡報自動產出 | 需要 digest 的人 |

## 協作類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| `standup-writer` | haiku | git log → standup 摘要 | 要寫日報的人 |
| `pr-drafter` | sonnet | diff → PR 描述 | 用 PR workflow 的人 |
| `rfc-writer-base` | sonnet | RFC 撰寫基底（繼承 domain-specific）| 寫架構 RFC 的人 |
| `general-purpose` | sonnet | 一般性多步驟任務 | 不知道該派哪個的人 |

## 進階/實驗性 (v3.0 新增)

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| `claude-code-guide` | sonnet | Claude Code 本身 / SDK / API 使用問題 | 剛接觸 Claude Code 的人 |
| `codex:codex-rescue` | opus | Codex 二意見深度診斷 | 遇到棘手 bug 的人 |
| `codex-integrity` | opus | 系統接縫/drift/自動化對齊（Bombus 專用）| 管 automation loop 的人 |
| `codex-refactor` | opus | Type safety/dead code/route/api 對齊（Bombus 專用）| 多 repo 專案 |
| `codex-review` | opus | Adversarial review / auth / tenant / migration 審查 | 高風險變更 |
| `codex-doc-sync` | opus | 改完 code 後自動同步 wiki/playbook/brain | 文件常落後的團隊 |

---

## 安裝方式

每個 agent 對應 `~/.claude/agents/{name}.md`。

```bash
# 從 dev-onboarding catalog 安裝
/dev-onboarding add agent code-reviewer

# 或手動複製 template
cp templates/agents/template.md ~/.claude/agents/{name}.md
```

## 建議組合

**AI/RAG 工程師 (像 Allen):** `code-reviewer` + `security-reviewer` + `codex-rescue` + `rag-debugger` + `eval-runner` + `discord-sre`

**Frontend 工程師:** `code-reviewer` + `e2e-runner` + `build-error-resolver` + `doc-updater`

**Backend 工程師:** `code-reviewer` + `security-reviewer` + `database-reviewer` + `tdd-guide`

**團隊 Lead:** 全部 + `planner` + `architect` + `exec-assistant` + 4 個 codex-* specialists

---

**References:**
- Source of truth: `Bombus-Technology/claude-dev-onboarding`
- 本機安裝: `~/.claude/agents/`
- 更新頻率: 每週六 10:00 self-update.sh 自動 pull
