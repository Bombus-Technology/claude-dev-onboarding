# Claude Code Dev Onboarding

AI 工程師開發環境一鍵搭建。透過深度訪談了解你的工作方式，自動建立專屬的 agents、skills、hooks、wiki、學習系統。

## 安裝

```bash
claude skill install /path/to/claude-dev-onboarding
```

或手動：
```bash
git clone <repo-url>
cp -r claude-dev-onboarding/skills/dev-onboarding ~/.claude/skills/
```

## 使用

```
/dev-onboarding
```

AI 會跟你做 20 題深度訪談，然後根據你的回答搭建完整環境。

## 產出

| 產出 | 路徑 | 說明 |
|------|------|------|
| Agents | `~/.claude/agents/` | 你的 AI teammates |
| Skills | `~/.claude/commands/` | 你的指令庫 |
| Hooks | `~/.claude/hooks/` | 自動化守衛 |
| Wiki | `~/dev-wiki/` | 個人知識庫 |
| Settings | `~/.claude/settings.json` | hooks 配置 |

## 適用對象

- AI Engineer
- Backend Engineer
- 任何使用 Claude Code 的開發者

## 授權

MIT
