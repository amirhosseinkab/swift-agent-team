#!/bin/bash
# Swift Agent Team Installer
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   bash install.sh                    Interactive mode (prompts for project or global)
#   bash install.sh --global           Install globally to ~/.claude/
#   bash install.sh --project          Install to .claude/ in the current directory
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/taylorarndt/swift-agent-team/main/install.sh | bash

set -e

# Determine source: running from repo clone or piped from curl?
DOWNLOADED=false

# When piped from curl, BASH_SOURCE is empty — always download in that case
if [ -z "${BASH_SOURCE[0]}" ] || [ "${BASH_SOURCE[0]}" = "bash" ] || [ "${BASH_SOURCE[0]}" = "/bin/bash" ]; then
  SCRIPT_DIR=""
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi

if [ -z "$SCRIPT_DIR" ] || [ ! -d "$SCRIPT_DIR/.claude/agents" ] || [ ! -f "$SCRIPT_DIR/.claude/hooks/swift-team-eval.sh" ]; then
  # Running from curl pipe or without full repo — download first
  DOWNLOADED=true
  TMPDIR_DL="$(mktemp -d)"
  echo ""
  echo "  Downloading Swift Agent Team..."

  if ! command -v git &>/dev/null; then
    echo "  Error: git is required. Install git and try again."
    rm -rf "$TMPDIR_DL"
    exit 1
  fi

  git clone --quiet https://github.com/taylorarndt/swift-agent-team.git "$TMPDIR_DL/swift-agent-team" 2>/dev/null
  SCRIPT_DIR="$TMPDIR_DL/swift-agent-team"
  echo "  Downloaded."
fi

AGENTS_SRC="$SCRIPT_DIR/.claude/agents"
HOOK_SH_SRC="$SCRIPT_DIR/.claude/hooks/swift-team-eval.sh"
HOOK_PS1_SRC="$SCRIPT_DIR/.claude/hooks/swift-team-eval.ps1"

# Auto-detect agents from source directory
AGENTS=()
if [ -d "$AGENTS_SRC" ]; then
  for f in "$AGENTS_SRC"/*.md; do
    [ -f "$f" ] && AGENTS+=("$(basename "$f")")
  done
fi

# Validate source files exist
if [ ${#AGENTS[@]} -eq 0 ]; then
  echo "  Error: No agents found in $AGENTS_SRC"
  echo "  Make sure you are running this script from the swift-agent-team directory."
  [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
  exit 1
fi

if [ ! -f "$HOOK_SH_SRC" ]; then
  echo "  Error: Hook script not found at $HOOK_SH_SRC"
  [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
  exit 1
fi

# Parse flags for non-interactive install
choice=""
for arg in "$@"; do
  case "$arg" in
    --global) choice="2" ;;
    --project) choice="1" ;;
  esac
done

if [ -z "$choice" ]; then
  if [ -t 0 ] || [ -c /dev/tty ]; then
    echo ""
    echo "  Swift Agent Team Installer"
    echo "  Built by Taylor Arndt"
    echo "  ========================="
    echo ""
    echo "  Where would you like to install?"
    echo ""
    echo "  1) Project   - Install to .claude/ in the current directory"
    echo "                  (recommended, check into version control)"
    echo ""
    echo "  2) Global    - Install to ~/.claude/"
    echo "                  (available in all your projects)"
    echo ""
    printf "  Choose [1/2]: "
    read -r choice < /dev/tty 2>/dev/null || choice="2"
  else
    echo ""
    echo "  No interactive terminal detected. Defaulting to global install."
    echo "  Use --project or --global to specify."
    choice="2"
  fi
fi

case "$choice" in
  1)
    TARGET_DIR="$(pwd)/.claude"
    SETTINGS_FILE="$TARGET_DIR/settings.json"
    HOOK_CMD=".claude/hooks/swift-team-eval.sh"
    echo ""
    echo "  Installing to project: $(pwd)"
    ;;
  2)
    TARGET_DIR="$HOME/.claude"
    SETTINGS_FILE="$TARGET_DIR/settings.json"
    HOOK_CMD="$HOME/.claude/hooks/swift-team-eval.sh"
    echo ""
    echo "  Installing globally to: $TARGET_DIR"
    ;;
  *)
    echo "  Invalid choice. Exiting."
    [ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"
    exit 1
    ;;
esac

# Create directories
mkdir -p "$TARGET_DIR/agents"
mkdir -p "$TARGET_DIR/hooks"

# Copy agents
echo ""
echo "  Copying agents..."
for agent in "${AGENTS[@]}"; do
  if [ ! -f "$AGENTS_SRC/$agent" ]; then
    echo "    ! Missing: $agent (skipped)"
    continue
  fi
  cp "$AGENTS_SRC/$agent" "$TARGET_DIR/agents/$agent"
  name="${agent%.md}"
  echo "    + $name"
done

# Copy hooks
echo ""
echo "  Copying hooks..."
cp "$HOOK_SH_SRC" "$TARGET_DIR/hooks/swift-team-eval.sh"
chmod +x "$TARGET_DIR/hooks/swift-team-eval.sh"
echo "    + swift-team-eval.sh"

if [ -f "$HOOK_PS1_SRC" ]; then
  cp "$HOOK_PS1_SRC" "$TARGET_DIR/hooks/swift-team-eval.ps1"
  echo "    + swift-team-eval.ps1"
fi

# Handle settings.json
echo ""

HOOK_ENTRY="{\"type\":\"command\",\"command\":\"$HOOK_CMD\"}"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if hook already exists
  if grep -q "swift-team-eval" "$SETTINGS_FILE" 2>/dev/null; then
    echo "  Hook already configured in settings.json. Skipping."
  else
    # Try to auto-merge with python3 (available on macOS and most Linux)
    if command -v python3 &>/dev/null; then
      MERGED=$(python3 -c "
import json, sys
try:
    with open('$SETTINGS_FILE', 'r') as f:
        settings = json.load(f)
    hook_entry = {'type': 'command', 'command': '$HOOK_CMD'}
    new_group = {'hooks': [hook_entry]}
    if 'hooks' not in settings:
        settings['hooks'] = {}
    if 'UserPromptSubmit' not in settings['hooks']:
        settings['hooks']['UserPromptSubmit'] = []
    settings['hooks']['UserPromptSubmit'].append(new_group)
    print(json.dumps(settings, indent=2))
except Exception as e:
    print('MERGE_FAILED', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null) && {
        echo "$MERGED" > "$SETTINGS_FILE"
        echo "  Updated existing settings.json with hook."
      } || {
        echo "  Existing settings.json found but could not auto-merge."
        echo "  Add this hook entry to your settings.json manually:"
        echo ""
        echo "  In the \"hooks\" > \"UserPromptSubmit\" array, add:"
        echo ""
        echo "    {"
        echo "      \"hooks\": ["
        echo "        {"
        echo "          \"type\": \"command\","
        echo "          \"command\": \"$HOOK_CMD\""
        echo "        }"
        echo "      ]"
        echo "    }"
        echo ""
      }
    else
      echo "  Existing settings.json found."
      echo "  python3 not available for auto-merge."
      echo "  Add this hook entry to your settings.json manually:"
      echo ""
      echo "  In the \"hooks\" > \"UserPromptSubmit\" array, add:"
      echo ""
      echo "    {"
      echo "      \"hooks\": ["
      echo "        {"
      echo "          \"type\": \"command\","
      echo "          \"command\": \"$HOOK_CMD\""
      echo "        }"
      echo "      ]"
      echo "    }"
      echo ""
    fi
  fi
else
  # Create settings.json with hook
  cat > "$SETTINGS_FILE" << SETTINGS
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_CMD"
          }
        ]
      }
    ]
  }
}
SETTINGS
  echo "  Created settings.json with hook configured."
fi

# Save current version hash
if command -v git &>/dev/null && [ -d "$SCRIPT_DIR/.git" ]; then
  git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null > "$TARGET_DIR/.swift-agent-team-version"
fi

# Auto-update setup (global install only, interactive only)
if [ "$choice" = "2" ]; then
  echo ""
  echo "  Would you like to enable auto-updates?"
  echo "  This checks GitHub daily for new agents and improvements."
  echo ""
  printf "  Enable auto-updates? [y/N]: "
  read -r auto_update < /dev/tty 2>/dev/null || auto_update="n"

  if [ "$auto_update" = "y" ] || [ "$auto_update" = "Y" ]; then
    UPDATE_SCRIPT="$TARGET_DIR/.swift-agent-team-update.sh"

    # Write a self-contained update script
    cat > "$UPDATE_SCRIPT" << 'UPDATESCRIPT'
#!/bin/bash
set -e
REPO_URL="https://github.com/taylorarndt/swift-agent-team.git"
CACHE_DIR="$HOME/.claude/.swift-agent-team-repo"
INSTALL_DIR="$HOME/.claude"
LOG_FILE="$HOME/.claude/.swift-agent-team-update.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

command -v git &>/dev/null || { log "git not found"; exit 1; }

if [ -d "$CACHE_DIR/.git" ]; then
  cd "$CACHE_DIR"
  git fetch origin main --quiet 2>/dev/null
  LOCAL=$(git rev-parse HEAD 2>/dev/null)
  REMOTE=$(git rev-parse origin/main 2>/dev/null)
  [ "$LOCAL" = "$REMOTE" ] && { log "Already up to date."; exit 0; }
  git reset --hard origin/main --quiet 2>/dev/null
else
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone --quiet "$REPO_URL" "$CACHE_DIR" 2>/dev/null
fi

cd "$CACHE_DIR"
HASH=$(git rev-parse --short HEAD 2>/dev/null)
UPDATED=0

for agent in .claude/agents/*.md; do
  NAME=$(basename "$agent")
  SRC="$CACHE_DIR/$agent"
  DST="$INSTALL_DIR/agents/$NAME"
  [ -f "$SRC" ] || continue
  if ! cmp -s "$SRC" "$DST" 2>/dev/null; then
    cp "$SRC" "$DST"
    log "Updated: ${NAME%.md}"
    UPDATED=$((UPDATED + 1))
  fi
done

# Remove agents no longer in repo
for DST in "$INSTALL_DIR"/agents/*.md; do
  [ -f "$DST" ] || continue
  NAME=$(basename "$DST")
  [ ! -f "$CACHE_DIR/.claude/agents/$NAME" ] && {
    rm "$DST"
    log "Removed: ${NAME%.md}"
    UPDATED=$((UPDATED + 1))
  }
done

SRC="$CACHE_DIR/.claude/hooks/swift-team-eval.sh"
DST="$INSTALL_DIR/hooks/swift-team-eval.sh"
[ -f "$SRC" ] && [ -f "$DST" ] && ! cmp -s "$SRC" "$DST" && {
  cp "$SRC" "$DST"
  chmod +x "$DST"
  log "Updated: hook script"
  UPDATED=$((UPDATED + 1))
}

echo "$HASH" > "$INSTALL_DIR/.swift-agent-team-version"
log "Check complete: $UPDATED files updated (version $HASH)."
UPDATESCRIPT
    chmod +x "$UPDATE_SCRIPT"

    # Detect platform and set up scheduler
    if [ "$(uname)" = "Darwin" ]; then
      # macOS: LaunchAgent
      PLIST_DIR="$HOME/Library/LaunchAgents"
      PLIST_FILE="$PLIST_DIR/com.taylorarndt.swift-agent-team-update.plist"
      mkdir -p "$PLIST_DIR"
      cat > "$PLIST_FILE" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.taylorarndt.swift-agent-team-update</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>${UPDATE_SCRIPT}</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>9</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>${HOME}/.claude/.swift-agent-team-update.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/.claude/.swift-agent-team-update.log</string>
  <key>RunAtLoad</key>
  <false/>
</dict>
</plist>
PLIST
      launchctl bootout "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null || true
      launchctl bootstrap "gui/$(id -u)" "$PLIST_FILE" 2>/dev/null
      echo "  Auto-updates enabled (daily at 9:00 AM via launchd)."
    else
      # Linux: cron job
      CRON_CMD="0 9 * * * /bin/bash $UPDATE_SCRIPT"
      (crontab -l 2>/dev/null | grep -v "swift-agent-team-update"; echo "$CRON_CMD") | crontab -
      echo "  Auto-updates enabled (daily at 9:00 AM via cron)."
    fi
    echo "  Update log: ~/.claude/.swift-agent-team-update.log"
  else
    echo "  Auto-updates skipped. You can run update.sh manually anytime."
  fi
fi

# Verify installation
echo ""
echo "  ========================="
echo "  Installation complete!"
echo ""
echo "  Agents installed:"
for agent in "${AGENTS[@]}"; do
  name="${agent%.md}"
  if [ -f "$TARGET_DIR/agents/$agent" ]; then
    echo "    [x] $name"
  else
    echo "    [ ] $name (missing)"
  fi
done
echo ""
echo "  Hook installed:"
if [ -f "$TARGET_DIR/hooks/swift-team-eval.sh" ]; then
  echo "    [x] swift-team-eval.sh"
else
  echo "    [ ] swift-team-eval.sh (missing)"
fi
echo ""
echo "  Settings:"
if grep -q "swift-team-eval" "$SETTINGS_FILE" 2>/dev/null; then
  echo "    [x] Hook configured in settings.json"
else
  echo "    [ ] Hook NOT configured -- add it manually (see above)"
fi

# Clean up temp download
[ "$DOWNLOADED" = true ] && rm -rf "$TMPDIR_DL"

echo ""
echo "  If agents do not load, increase the character budget:"
echo "    export SLASH_COMMAND_TOOL_CHAR_BUDGET=50000"
echo ""
echo "  Start Claude Code and try: \"Build a settings screen with a toggle\""
echo "  The swift-lead should activate automatically."
echo ""
