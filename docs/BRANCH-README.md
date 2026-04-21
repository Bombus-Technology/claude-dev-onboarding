# Branch: `savelyn-fork-review-260421`

## 🚫 這是 Savelyn 的個人 review 分支 — 不要 merge 進 master

**狀態：** Review / FYI only

**目的：** Savelyn fork 這個 repo 後，花 12 天客製出自己的 editor-mode workflow。這個分支用來：

1. 讓 Allen 看到 Savelyn 的客製軌跡（她怎麼改、為什麼改、踩了什麼坑）
2. 分享從另一個 persona（editor mode）角度給 claude-dev-onboarding 設計的建議
3. 留作歷史紀錄，供未來對照 workflow 演化

**為什麼不該 merge：**

- `docs/savelyn-references/` 下的檔案都是 Savelyn-specific：
  - `eval-tuning-policy.md` 是 Savelyn 的 prompt tuning policy，裡面有她的 red line category 定義
  - `architecture-snapshot.md` 是 sage-agent-platform 內部 orchestrator 快照
  - `autopilot-SKILL.md` / `eval-fix-SKILL.md` / `help-SKILL.md` 是 Savelyn 機器上的實際 skill 版本
- 直接 merge 會讓 Savelyn 的 personal setup 變成 catalog default，**反而違反 dev-onboarding 的 subscriber-friendly 設計**

**怎麼採用有價值的部分：**

- 讀 `docs/REVIEW-from-savelyn-260421.md` 的「給 Allen 的建議」段落
- 決定哪些 idea 值得進 catalog（例如 notification-taxonomy 標 persona / naming 中性化）
- 在 master 手動寫新版本，不要直接 copy Savelyn 的檔案

**Branch 何時會過時：**

Savelyn 的 workflow 會繼續演化。這份 review 是 `2026-04-21` snapshot。如果你之後想看最新版，Slack 她一下，她可能有新發現。

**建議動作：**

- Allen 讀完 → 留 comment 或直接跟 Savelyn 討論
- 覺得有用 → 手動採用到 catalog / reference
- 之後刪這個 branch 也 OK（沒有保留義務）

---

**檔案清單：**

```
docs/
├── BRANCH-README.md                    ← 本檔
├── REVIEW-from-savelyn-260421.md       ← 主文件（249 行）
└── savelyn-references/
    ├── autopilot-SKILL.md              ← Savelyn 實作的 chained execution skill
    ├── eval-fix-SKILL.md               ← autoresearch 風格的 eval 迭代
    ├── eval-tuning-policy.md           ← Karpathy program.md 實踐
    ├── help-SKILL.md                   ← 動態 cheat sheet skill
    └── architecture-snapshot.md        ← tech-radar 基準檔範例
```
