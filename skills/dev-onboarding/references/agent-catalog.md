# Agent 候選清單

> 根據使用者訪談結果選擇。不是全部都要裝。

## 開發類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| code-reviewer | sonnet | commit 前自動 review：mutation/安全/型別 | 想要 code 品質保證的人 |
| debugger | sonnet | 分析錯誤 → root cause → 建議修復 | 常 debug 的人 |
| test-runner | sonnet | 自動跑 pytest/jest + 產出覆蓋率報告 | 重視測試的人 |
| refactorer | sonnet | 識別重複 code → 建議重構 | 有技術債的人 |

## AI/ML 類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| prompt-tuner | opus | 分析 eval 結果 → 建議 prompt 改進 → A/B 對比 | 常調 prompt 的人 |
| eval-runner | sonnet | 跑 RAGAS/自訂 eval suite → 產出報告 | 需要頻繁評估的人 |
| graph-architect | opus | LangGraph 接線設計 → 畫流程圖 → 檢查依賴 | 設計 graph pipeline 的人 |
| rag-debugger | sonnet | 分析 RAG 回答品質 → 找出是 retrieval 還是 generation 問題 | RAG 開發者 |

## 文件類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| doc-writer | haiku | 自動寫 docstring/README/API 文件 | 不喜歡寫文件的人 |
| arch-recorder | sonnet | 記錄架構決策（ADR 格式） | 做架構設計的人 |

## 安全類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| security-checker | sonnet | 掃描 PII/injection/認證問題 | 碰敏感資料的人 |
| dependency-auditor | haiku | 檢查依賴版本和已知漏洞 | 管依賴的人 |

## 協作類

| Agent | model | 用途 | 適合誰 |
|-------|-------|------|--------|
| standup-writer | haiku | 根據 git log 自動產出 standup 摘要 | 要寫日報的人 |
| pr-drafter | sonnet | 根據 diff 自動寫 PR 描述 | 用 PR workflow 的人 |
