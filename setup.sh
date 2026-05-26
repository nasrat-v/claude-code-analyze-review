#!/usr/bin/env bash
# claude-code-analyze-review — installer
# Copies the /analyze-review command into ~/.claude/commands/ for user-wide use.
#
# Usage:
#   ./setup.sh              # install for current user
#   ./setup.sh --project    # install into ./.claude/commands/ (project-local)
#   ./setup.sh --uninstall  # remove the command
#
# Or one-liner (no clone needed):
#   curl -fsSL https://raw.githubusercontent.com/nasrat-v/claude-code-analyze-review/main/setup.sh | bash

set -euo pipefail

REPO_RAW_URL="https://raw.githubusercontent.com/nasrat-v/claude-code-analyze-review/main"
COMMAND_FILE="commands/analyze-review.md"

# ANSI colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { printf "${GREEN}[+]${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}[!]${NC} %s\n" "$*"; }
error() { printf "${RED}[x]${NC} %s\n" "$*" >&2; }

MODE="user"
ACTION="install"

for arg in "$@"; do
  case "$arg" in
    --project)   MODE="project" ;;
    --uninstall) ACTION="uninstall" ;;
    -h|--help)
      grep -E '^# ' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      error "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

# Resolve target directory
if [[ "$MODE" == "user" ]]; then
  TARGET_DIR="$HOME/.claude/commands"
else
  TARGET_DIR="$(pwd)/.claude/commands"
fi
TARGET_FILE="$TARGET_DIR/analyze-review.md"

# Uninstall path
if [[ "$ACTION" == "uninstall" ]]; then
  if [[ -f "$TARGET_FILE" ]]; then
    rm "$TARGET_FILE"
    info "Removed $TARGET_FILE"
  else
    warn "Nothing to remove at $TARGET_FILE"
  fi
  exit 0
fi

# Install path
info "Installing /analyze-review into $TARGET_DIR"
mkdir -p "$TARGET_DIR"

# Prefer local file if running from a clone; otherwise curl from GitHub.
if [[ -f "$COMMAND_FILE" ]]; then
  cp "$COMMAND_FILE" "$TARGET_FILE"
  info "Copied from local clone."
else
  if ! command -v curl >/dev/null 2>&1; then
    error "curl not found. Install curl or clone the repo and re-run."
    exit 1
  fi
  curl -fsSL "$REPO_RAW_URL/$COMMAND_FILE" -o "$TARGET_FILE"
  info "Downloaded from $REPO_RAW_URL."
fi

info "Done. Open Claude Code and run: /analyze-review <review feedback>"
