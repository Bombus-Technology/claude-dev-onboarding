---
name: help
description: 快速查詢 Savelyn 的所有工具 — 場景導向「當你想做 X → 用 Y」的 cheat sheet
user_invocable: true
---

# /help — Savelyn 工具速查

**動態讀取**：每次呼叫時讀 `/home/savelyn/sav-agents/savelyn-wiki/playbooks/my-toolbox.md`（唯一的 source of truth），再整理成場景導向輸出。

**所有輸出一律使用繁體中文。**

---

## 使用方式

```
/help              # 預設：場景速查表（最常用）
/help skill        # 只列 slash commands
/help agent        # 只列 subagents
/help cron         # 只列排程 + Discord 頻道
/help 檔案         # 列關鍵檔案位置
/help 全部         # 完整 my-toolbox.md 原文（對齊最完整資訊）
```

---

## 執行流程

### Step 1：先讀 toolbox

```bash
cat /home/savelyn/sav-agents/savelyn-wiki/playbooks/my-toolbox.md
```

把裡面所有資訊吸收。

### Step 2：依據 `$ARGUMENTS` 決定輸出模式

**如果沒參數（最常見）：** 輸出「場景速查表」格式，如下。

**如果參數是 `skill` / `agent` / `cron` / `檔案`：** 只列對應區塊。

**如果參數是 `全部`：** 直接把 my-toolbox.md 完整列出來（適合慢慢讀）。

---

## 場景速查表（`/help` 預設輸出）

**輸出這個格式（依當下 toolbox 實際內容動態填入）：**

```markdown
# 🧰 Savelyn 工具速查

## 🌅 Session 開始

| 想做的 | 用這個 |
|---|---|
| 看 3 repo 最近動態 + 我上次做到哪 | `/brief` |

## 💻 開發中

| 想做的 | 用這個 |
|---|---|
| 做一件明確的 task（加功能 / refactor / 寫測試） | `/autopilot <任務>` |
| 看 LangGraph 架構圖 | `/graph-viz` |
| Commit 前檢查 mutation / 安全 / LangGraph 邏輯 | `/review` |
| 深度診斷 RAG 回答錯了是哪一層 | 講「請用 rag-debugger agent 診斷 case X」 |
| 想設計新 graph node | 講「請用 graph-architect agent 評估這個設計」 |
| 留 ADR 架構決策 | 講「請用 arch-recorder agent 寫 ADR」 |

## 🧪 Eval / Prompt 調整

| 想做的 | 用這個 |
|---|---|
| Eval 數字掉了要修 | `/eval-fix` |
| 單純想跑 eval 看現況 | `/eval` |
| 改完 prompt 想比對兩版 eval | `/eval-compare` |
| 看過去 eval 實驗歷史 | `cat ~/.claude/wiki/eval-history/$(date +%Y-%m-%d).tsv`（或挑其他日期）|
| 深度診斷 prompt 為啥 fail | 講「請用 prompt-tuner agent 看 eval 結果建議怎麼改」 |

## 📡 自動推播（不用做，手機會通知）

| 時間 | 頻道 | 內容 |
|---|---|---|
| 每天 06:00 | #agentic-radar | LangGraph / Qwen / vLLM / 安全新聞 + 對照你架構 |
| 每天 06:10 | #ai-daily | 廣義 AI 新聞 |
| 每天 06:20 | #brief | 3 repo 昨日 commits（Allen 段 / Savelyn 段）+ 你區域警告 |
| 每天 19:30 | #progress | 當日完整進度（commits + learnings + patterns） |
| 每天 19:00 | 本地 `~/.claude/wiki/` | 6 種知識萃取（learnings / decisions / troubleshooting / ADR / system-knowledge / architecture） |

## 📁 關鍵檔案

| 想看 | 位置 |
|---|---|
| 我目前有哪些工具 | `savelyn-wiki/playbooks/my-toolbox.md` |
| Sage 系統真實架構 | `savelyn-wiki/architecture-snapshot.md`（機器讀） |
| 深度架構文件 | `savelyn-wiki/architecture/sage-orchestrator-deep-dive.md`（人讀） |
| Eval 調整規則 | `savelyn-wiki/playbooks/eval-tuning-policy.md` |
| 自動產出的學習筆記 | `~/.claude/wiki/{learnings,decisions,troubleshooting,...}/` |
| 每天的 tech radar 歷史 | `~/.claude/wiki/tech-radar/agentic/{date}.md` + `ai-daily/{date}.md` |

## 🛠️ 改 / 加工具

| 想做的 | 怎麼做 |
|---|---|
| 加新 agent | 在 `~/.claude/agents/{name}.md` 建檔 + 更新 my-toolbox.md |
| 加新 skill | 在 `~/.claude/skills/{name}/SKILL.md` 建檔 + 更新 my-toolbox.md |
| 加新 cron | `crontab -e` + 更新 my-toolbox.md |
| 改 eval 判斷規則 | 改 `savelyn-wiki/playbooks/eval-tuning-policy.md`（eval-fix 每次會重讀） |
| 更新架構 snapshot | 呼叫 `graph-architect` agent 重讀 code，把輸出存回 architecture-snapshot.md |

## 💡 提示

打 `/help 全部` 看完整 toolbox（每個工具的詳細用途說明）
打 `/help cron` 看排程細節（channel ID + 完整時間）
打 `/help skill` 只看 slash commands 清單
```

---

## 關於「動態」的重要規則

**每次呼叫 /help 都要真的去讀 my-toolbox.md**，不能用記憶回答（會過期）。

如果 my-toolbox.md 讀出來跟上面預設模板不一致（例如多了新 skill / 改了 Discord channel），**以 my-toolbox.md 為準**，整理成場景速查表給 Savelyn。

如果發現 my-toolbox.md 過期了（例如 crontab 實際有 5 條但 toolbox 只寫 4 條）→ **提醒 Savelyn「toolbox 好像過期了，要更新嗎？」** 但不自動改。
