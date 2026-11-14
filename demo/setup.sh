#!/bin/bash
# Staged illustration of the "let Claude Code set it up" flow. Not a live Claude Code session.
# Used by setup.tape to record setup.gif.
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=demo/ui.sh
source "$here/demo/ui.sh"
step() { printf '  %s●%s %s\n' "$accent" "$reset" "$1"; sleep "${2:-1}"; }
ok() { printf '    %s✓%s %s%s%s\n' "$green" "$reset" "$dim" "$1" "$reset"; sleep "${2:-0.8}"; }

clear
printf '\n  %sIllustration: what happens when you paste the install prompt into Claude Code%s\n\n' "$dim" "$reset"
input_box 'Set up the Claude Code status line from github.com/FilipMessa/claude-code-statusline' | sed 's/^/  /'
printf '\n'
sleep 2
step "Checking that jq is installed" 1.2
ok "$(jq --version) found"
step "Downloading statusline.sh to ~/.claude/"
step "Downloading commands/sl-legend.md to ~/.claude/commands/"
step "Making the script executable" 0.8
step "Adding statusLine to ~/.claude/settings.json" 1.2
ok "existing settings kept"
step "Testing the script with sample data" 1.2
printf '    '
printf '%s\n' '{"model":{"display_name":"Opus 5.5"},"session_id":"demo","cwd":"'"$HOME"'/projects/my-project","context_window":{"used_percentage":42}}' | "$here/statusline.sh"
printf '\n'
sleep 2.5
printf '  %s%sDone.%s Restart Claude Code, then type %s/sl-legend%s to see what each part means.\n' "$green" "$bold" "$reset" "$cyan" "$reset"
sleep 4
