#!/bin/bash
# {{HOOK_NAME}} — {{DESCRIPTION}}
# 觸發時機：{{TRIGGER}}

FILE_PATH="$TOOL_INPUT_file_path"
if [ -z "$FILE_PATH" ]; then
  FILE_PATH="$TOOL_INPUT_FILE_PATH"
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# {{LOGIC}}
