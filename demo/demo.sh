#!/bin/bash
# Plays a scripted walkthrough of the status line using the real statusline.sh
# and made-up session data. Used by demo.tape to record demo.gif.
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
now=$(date +%s)
project="$HOME/projects/my-project"
session="demo-session"
uid=$(id -u)
tmp_root=/tmp; [ -d /private/tmp ] && tmp_root=/private/tmp
scratch="$tmp_root/claude-$uid/$(printf '%s' "$project" | sed 's/[^A-Za-z0-9]/-/g')/$session/scratchpad"

dim=$'\e[90m'; bold=$'\e[1m'; reset=$'\e[0m'

show() { # caption, json
  clear
  printf '\n\n%s%s%s\n\n' "$bold" "$1" "${reset}"
  printf '%s\n' "${dim}──────────────────────────────────────────────────────────────────────────────${reset}"
  printf '%s\n' "$2" | "$here/statusline.sh"
  printf '\n%s\n' "${dim}──────────────────────────────────────────────────────────────────────────────${reset}"
}

json() { # context% cache_min five_hour% seven_day% resets_in_s [worktree]
  local wt=""; [ -n "${6:-}" ] && wt=",\"workspace\":{\"project_dir\":\"$project\",\"current_dir\":\"$project\",\"git_worktree\":\"$6\"}"
  [ -z "$wt" ] && wt=",\"workspace\":{\"project_dir\":\"$project\",\"current_dir\":\"$project\"}"
  cat <<JSON
{"model":{"display_name":"Opus 5.5"},"session_id":"$session","cwd":"$project"$wt,
 "context_window":{"used_percentage":$1},
 "prompt_cache":{"caching_observed":true,"recache_tokens_if_cold":120000,"expires_at":$((now + $2 * 60))},
 "rate_limits":{"five_hour":{"used_percentage":$3,"resets_at":$((now + $5))},
                "seven_day":{"used_percentage":$4,"resets_at":$((now + 345600))}}}
JSON
}

rm -rf "$scratch"
show "1. A fresh session: model, context, folder"  "$(json 4 55 10 20 14400)"; sleep 3
show "2. Context fills up. Green until 50%"        "$(json 42 12 22 20 11000)"; sleep 3
show "3. Past 50% the bar turns yellow"            "$(json 68 7 35 20 9000)"; sleep 3
show "4. Cache nearly expired, context almost full: red" "$(json 91 3 52 20 6000)"; sleep 3
show "5. Using the limit faster than time passes: ↑" "$(json 91 3 73 30 6400)"; sleep 3
mkdir -p "$scratch" && : > "$scratch/notes.md"
show "6. Worktree and scratchpad segments appear when used" "$(json 91 3 73 30 6400 fix-login)"; sleep 3
show "7. Type /sl-legend in Claude Code to see what every part means" "$(json 91 3 73 30 6400 fix-login)"; sleep 4
rm -rf "$scratch"
