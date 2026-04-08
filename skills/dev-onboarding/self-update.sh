#!/bin/bash
# self-update.sh — Skill 自我更新
# 從 Allen 的系統（source of truth）同步最新的 catalog
# 用法：手動跑或 cron 每週跑一次

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
REFS_DIR="$SKILL_DIR/references"
SOURCE_HOOKS="$HOME/.claude/hooks"
SOURCE_COMMANDS="$HOME/.claude/commands"
SOURCE_AGENTS="$HOME/.claude/agents"
SOURCE_SETTINGS="$HOME/.claude/settings.json"
PROFILE="$HOME/.claude/dev-onboarding-profile.json"
LOG="$SKILL_DIR/update-log.md"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

echo "## [$TIMESTAMP] Self-Update" >> "$LOG"

# --- 1. 掃描 Allen 目前的 hooks ---
echo "### Hooks" >> "$LOG"
HOOK_CATALOG="$REFS_DIR/hook-catalog.md"
CURRENT_HOOKS=$(find "$SOURCE_HOOKS" -name "*.sh" -exec basename {} .sh \; 2>/dev/null | sort)
CATALOG_HOOKS=$(grep "^| " "$HOOK_CATALOG" | awk -F'|' '{print $2}' | tr -d ' ' | grep -v "^Hook$" | grep -v "^-" | sort)

NEW_HOOKS=""
for h in $CURRENT_HOOKS; do
  if ! grep -q "$h" "$HOOK_CATALOG" 2>/dev/null; then
    NEW_HOOKS="$NEW_HOOKS $h"
    echo "- 新發現 hook: $h" >> "$LOG"
  fi
done

# --- 2. 掃描 Allen 目前的 skills ---
echo "### Skills" >> "$LOG"
SKILL_CATALOG="$REFS_DIR/skill-catalog.md"
CURRENT_SKILLS=$(find "$SOURCE_COMMANDS" -name "*.md" -exec basename {} .md \; 2>/dev/null | sort)

NEW_SKILLS=""
for s in $CURRENT_SKILLS; do
  if ! grep -q "$s" "$SKILL_CATALOG" 2>/dev/null; then
    NEW_SKILLS="$NEW_SKILLS $s"
    echo "- 新發現 skill: $s" >> "$LOG"
  fi
done

# --- 3. 掃描 Allen 目前的 agents ---
echo "### Agents" >> "$LOG"
AGENT_CATALOG="$REFS_DIR/agent-catalog.md"
CURRENT_AGENTS=$(find "$SOURCE_AGENTS" -name "*.md" -exec basename {} .md \; 2>/dev/null | sort)

NEW_AGENTS=""
for a in $CURRENT_AGENTS; do
  if ! grep -q "$a" "$AGENT_CATALOG" 2>/dev/null; then
    NEW_AGENTS="$NEW_AGENTS $a"
    echo "- 新發現 agent: $a" >> "$LOG"
  fi
done

# --- 4. 統計使用者的 instincts ---
INSTINCT_COUNT=$(find "$HOME/.claude/homunculus/instincts/personal" -name "*.md" 2>/dev/null | wc -l)
echo "### Instincts: $INSTINCT_COUNT" >> "$LOG"

# --- 5. 產出更新摘要 ---
TOTAL_NEW=$(echo $NEW_HOOKS $NEW_SKILLS $NEW_AGENTS | wc -w)

if [ "$TOTAL_NEW" -gt 0 ]; then
  echo "" >> "$LOG"
  echo "**共發現 $TOTAL_NEW 個新項目需要加入 catalog**" >> "$LOG"

  echo ""
  echo "🔄 Skill Self-Update: 發現 $TOTAL_NEW 個新項目"

  if [ -n "$NEW_HOOKS" ]; then
    echo "  Hooks:$NEW_HOOKS"
  fi
  if [ -n "$NEW_SKILLS" ]; then
    echo "  Skills:$NEW_SKILLS"
  fi
  if [ -n "$NEW_AGENTS" ]; then
    echo "  Agents:$NEW_AGENTS"
  fi

  echo ""
  echo "需要跑 /dev-onboarding sync 更新 catalog"
else
  echo "" >> "$LOG"
  echo "**Catalog 已是最新**" >> "$LOG"
  echo "✅ Skill catalog 已是最新（$TIMESTAMP）"
fi

echo "---" >> "$LOG"
