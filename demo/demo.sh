#!/bin/bash
# Plays a scripted walkthrough of the status line using the real statusline.sh
# and made-up session data. Used by demo.tape to record demo.gif.
set -u
here="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=demo/ui.sh
source "$here/demo/ui.sh"
now=$(date +%s)
project="$HOME/projects/my-project"
session="demo-session"
uid=$(id -u)
tmp_root=/tmp; [ -d /private/tmp ] && tmp_root=/private/tmp
scratch="$tmp_root/claude-$uid/$(printf '%s' "$project" | sed 's/[^A-Za-z0-9]/-/g')/$session/scratchpad"
total=7

json() { # context% cache_min five_hour% seven_day% resets_in_s [worktree]
  local wt=""; [ -n "${6:-}" ] && wt=",\"git_worktree\":\"$6\""
  cat <<JSON
{"model":{"display_name":"Opus 5.5"},"session_id":"$session","cwd":"$project",
 "workspace":{"project_dir":"$project","current_dir":"$project"$wt},
 "context_window":{"used_percentage":$1},
 "prompt_cache":{"caching_observed":true,"recache_tokens_if_cold":120000,"expires_at":$((now + $2 * 60))},
 "rate_limits":{"five_hour":{"used_percentage":$3,"resets_at":$((now + $5))},
                "seven_day":{"used_percentage":$4,"resets_at":$((now + 345600))}}}
JSON
}

scene() { # step title detail json hold
  clear
  printf '\n  %s   %s%sStep %s of %s%s\n\n' "$(progress "$1" "$total")" "$dim" "" "$1" "$total" "$reset"
  printf '  %s%s%s%s\n' "$bold" "$text" "$2" "$reset"
  printf '  %s%s%s\n\n' "$dim" "$3" "$reset"
  input_box 'Ask Claude anything...' | sed 's/^/  /'
  printf ' %s ' ' '
  printf '%s\n' "$4" | "$here/statusline.sh"
  printf '\n'
  sleep "$5"
}

rm -rf "$scratch"
scene 1 "A fresh session"                      "Model, context usage and the current folder."                                   "$(json 4 55 10 20 14400)" 3
scene 2 "Context fills up"                      "The bar is green while less than half of the context is used."                  "$(json 42 12 22 20 11000)" 3
scene 3 "Getting fuller"                        "Between 50% and 80% the bar turns yellow."                                      "$(json 68 7 35 20 9000)" 3
scene 4 "Almost full, cache about to expire"    "Above 80% the bar is red. The cache countdown turns red in its last 5 minutes." "$(json 91 3 52 20 6000)" 3
scene 5 "Using the limit faster than time"      "The arrow means your usage is ahead of the clock. Then comes the time to reset." "$(json 91 3 73 30 6400)" 3.5
mkdir -p "$scratch" && : > "$scratch/notes.md"
scene 6 "Worktree and scratchpad"               "These appear only when you use them."                                           "$(json 91 3 73 30 6400 fix-login)" 3
scene 7 "Need a reminder?"                      "Type /sl-legend to print what every part means."                                "$(json 91 3 73 30 6400 fix-login)" 4
rm -rf "$scratch"
