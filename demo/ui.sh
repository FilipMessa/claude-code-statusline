# Shared drawing helpers for the demo scripts (sourced, not run).
bold=$'\e[1m'; dim=$'\e[38;5;243m'; text=$'\e[38;5;252m'; reset=$'\e[0m'
accent=$'\e[38;5;216m'; cyan=$'\e[38;5;117m'; green=$'\e[38;5;114m'
BOX_WIDTH=100

repeat() { local out="" i; for ((i = 0; i < $2; i++)); do out+="$1"; done; printf '%s' "$out"; }

# input_box <text> : a rounded prompt box like the Claude Code input
input_box() {
  local inner=$((BOX_WIDTH - 2))
  printf '%s╭%s╮%s\n' "$dim" "$(repeat '─' "$inner")" "$reset"
  printf '%s│%s %s>%s %-*s%s│%s\n' "$dim" "$reset" "$accent" "$reset" $((inner - 3)) "$1" "$dim" "$reset"
  printf '%s╰%s╯%s\n' "$dim" "$(repeat '─' "$inner")" "$reset"
}

# progress <current> <total>
progress() {
  local i out=""
  for ((i = 1; i <= $2; i++)); do
    if [ "$i" -le "$1" ]; then out+="${accent}●${reset} "; else out+="${dim}○${reset} "; fi
  done
  printf '%s' "$out"
}
