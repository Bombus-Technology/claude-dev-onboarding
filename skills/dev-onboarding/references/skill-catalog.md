# Skill 候選清單

## 任務管理

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| /today | 讀 deadline + STATUS → 推薦今天的焦點 | 有多個待辦的人 |
| /done {task} | 標記完成 → 更新 STATUS → 產出通知 | 需要回報進度的人 |
| /stuck {問題} | 記錄問題 → 推薦下一個任務 | 常卡住的人 |

## 開發

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| /test {file} | 跑特定檔案/模組的測試 | 頻繁跑測試的人 |
| /test-all | 跑整個 test suite | commit 前確認的人 |
| /lint | 跑 linter + auto fix | 要求 code style 的人 |
| /bench {scenario} | 跑效能 benchmark | 在意效能的人 |

## AI/RAG 專用

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| /eval | 跑 RAGAS evaluation suite | RAG 開發者 |
| /eval-compare {a} {b} | 比較兩版的 eval 結果 | 常調 prompt 的人 |
| /prompt-diff {file} | 顯示 prompt 修改前後的差異 + eval 對比 | prompt engineer |
| /graph-viz | 印出當前 graph 接線圖 | LangGraph 開發者 |
| /node-test {N3} | 跑特定 node 的 golden test | graph node 開發者 |

## 部署

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| /deploy {service} | 部署到指定環境 | 需要自己部署的人 |
| /deploy-check | 檢查部署狀態 + health check | 部署後確認的人 |

## 知識管理

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| /wiki-ingest {內容} | 寫入個人 wiki | 有筆記習慣的人 |
| /wiki-search {關鍵字} | 搜尋個人 wiki | wiki 有內容的人 |
| /learn {內容} | 記錄學到的東西 → wiki/learnings/ | 想建知識庫的人 |
| /pit {描述} | 記錄踩的坑 → wiki/troubleshooting/ | 常踩坑的人 |

## 協作

| Skill | 做什麼 | 適合誰 |
|-------|--------|--------|
| /notify {channel} {message} | 產出 Discord 通知格式 | 需要通知團隊的人 |
| /standup | 根據 git log 產出今日 standup | 要寫日報的人 |
| /review | 自我 code review（spawn code-reviewer agent） | 想要品質保證的人 |
