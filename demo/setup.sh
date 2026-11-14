#!/bin/bash
# Staged illustration of the "let Claude Code set it up" flow. Not a live Claude Code session.
# Used by setup.tape to record setup.gif.
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
dim=$'\e[90m'; bold=$'\e[1m'; green=$'\e[32m'; cyan=$'\e[36m'; reset=$'\e[0m'
line() { printf '%s\n' "$1"; sleep "${2:-0.9}"; }

clear
printf '%sIllustration: what happens when you paste the install prompt into Claude Code%s\n\n' "$dim" "$reset"
sleep 1.5
line "${bold}> Set up the Claude Code status line from"
line "  https://github.com/FilipMessa/claude-code-statusline for me.${reset}" 1.5
printf '\n'
line "${cyan}●${reset} Checking that jq is installed"                       1.2
line "  ${green}✓${reset} $(jq --version) found"                                      1
line "${cyan}●${reset} Downloading statusline.sh to ~/.claude/"               1.2
line "${cyan}●${reset} Downloading commands/sl-legend.md to ~/.claude/commands/" 1.2
line "${cyan}●${reset} Making the script executable"                          1
line "${cyan}●${reset} Adding statusLine to ~/.claude/settings.json"          1.2
line "  ${green}✓${reset} existing settings kept"                            1
line "${cyan}●${reset} Testing the script with sample data"                   1.2
printf '  '
printf '%s\n' '{"model":{"display_name":"Opus 5.5"},"session_id":"demo","cwd":"'"$HOME"'/projects/my-project","context_window":{"used_percentage":42}}' | "$here/statusline.sh"
printf '\n'
sleep 2.5
line "${bold}Done. Restart Claude Code, then type /sl-legend to see what each part means.${reset}" 4
