#!/bin/bash
# self-update.sh — Skill 自我更新
# 從 Git repo（source of truth）同步最新的 catalog
# 用法：cron 每週跑一次 / 手動 /dev-onboarding sync

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
REFS_DIR="$SKILL_DIR/references"
PROFILE="$HOME/.claude/dev-onboarding-profile.json"
LOG="$SKILL_DIR/update-log.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

# --- 0. Source of truth = Git repo ---
REPO_URL="https://github.com/Bombus-Technology/claude-dev-onboarding.git"
UPSTREAM_DIR="/tmp/dev-onboarding-upstream"

# 拉最新的 upstream catalog
if [ -d "$UPSTREAM_DIR/.git" ]; then
  git -C "$UPSTREAM_DIR" pull --quiet 2>/dev/null || true
else
  git clone --quiet --depth 1 "$REPO_URL" "$UPSTREAM_DIR" 2>/dev/null || {
    echo "[$TIMESTAMP] 無法連線 Git repo，跳過同步" >> "$LOG"
    exit 0
  }
fi

UPSTREAM_REFS="$UPSTREAM_DIR/skills/dev-onboarding/references"

# --- 1. 比對 catalog 差異 ---
echo "## [$TIMESTAMP] Self-Update" >> "$LOG"

diff_catalog() {
  local type="$1"
  local local_file="$REFS_DIR/${type}-catalog.md"
  local upstream_file="$UPSTREAM_REFS/${type}-catalog.md"

  if [ ! -f "$upstream_file" ]; then
    return
  fi

  # 提取表格中的項目名稱（第一欄，精確匹配表格行）
  local local_items=$(grep '^| ' "$local_file" 2>/dev/null | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' | grep -v '^$' | grep -v '^-' | grep -v 'Agent\|Skill\|Hook' | sort -u)
  local upstream_items=$(grep '^| ' "$upstream_file" 2>/dev/null | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' | grep -v '^$' | grep -v '^-' | grep -v 'Agent\|Skill\|Hook' | sort -u)

  local new_items=""
  while IFS= read -r item; do
    [ -z "$item" ] && continue
    # 精確匹配：用 grep -Fx（fixed string, whole line）
    if ! echo "$local_items" | grep -Fxq "$item" 2>/dev/null; then
      new_items="$new_items\n  - $item"
      echo "- 新增 $type: $item" >> "$LOG"
    fi
  done <<< "$upstream_items"

  if [ -n "$new_items" ]; then
    echo "$type:$new_items"
  fi
}

NEW_AGENTS=$(diff_catalog "agent")
NEW_SKILLS=$(diff_catalog "skill")
NEW_HOOKS=$(diff_catalog "hook")

# --- 2. 自動同步 catalog 檔案 ---
UPDATED=0
for type in agent skill hook; do
  local_file="$REFS_DIR/${type}-catalog.md"
  upstream_file="$UPSTREAM_REFS/${type}-catalog.md"
  if [ -f "$upstream_file" ] && ! diff -q "$local_file" "$upstream_file" > /dev/null 2>&1; then
    cp "$upstream_file" "$local_file"
    UPDATED=1
  fi
done

# --- 3. Observations 健康檢查 ---
OBS_FILE="$HOME/.claude/homunculus/observations.jsonl"
OBS_SIZE=0
if [ -f "$OBS_FILE" ]; then
  OBS_SIZE=$(du -m "$OBS_FILE" 2>/dev/null | cut -f1)
  # 超過 10MB → archive + 清空
  if [ "$OBS_SIZE" -gt 10 ]; then
    ARCHIVE_DIR="$HOME/.claude/homunculus/observations.archive"
    mkdir -p "$ARCHIVE_DIR"
    mv "$OBS_FILE" "$ARCHIVE_DIR/observations-$(date +%Y%m%d).jsonl"
    touch "$OBS_FILE"
    echo "- observations.jsonl 超過 10MB，已 archive" >> "$LOG"
  fi
fi

# --- 4. 產出摘要 ---
TOTAL_NEW=""
[ -n "$NEW_AGENTS" ] && TOTAL_NEW="${TOTAL_NEW}${NEW_AGENTS}\n"
[ -n "$NEW_SKILLS" ] && TOTAL_NEW="${TOTAL_NEW}${NEW_SKILLS}\n"
[ -n "$NEW_HOOKS" ] && TOTAL_NEW="${TOTAL_NEW}${NEW_HOOKS}\n"

if [ -n "$TOTAL_NEW" ]; then
  echo "" >> "$LOG"
  echo "**有新項目可安裝：**" >> "$LOG"
  echo ""
  echo "🔄 Catalog 有更新："
  echo -e "$TOTAL_NEW"
  echo ""
  echo "下次 session 開始會自動提示。"
elif [ "$UPDATED" -eq 1 ]; then
  echo "✅ Catalog 已同步最新版本（$TIMESTAMP）"
else
  echo "✅ Catalog 已是最新（$TIMESTAMP）"
fi

echo "---" >> "$LOG"
