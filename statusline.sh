#!/bin/bash
# Claude Code status line:
# model | context bar | cache countdown | nearest usage limit + reset | folder | worktree | scratchpad | legend
# The legend is the /sl-legend slash command (~/.claude/commands/sl-legend.md). Update it when a segment changes.
# Requires: bash, jq. Optional: set STATUSLINE_PROJECTS_DIR to the folder that holds your projects
# (defaults to ~/projects); folders inside it are shown relative to it.
input=$(cat)

# Claude Code keeps its per-session scratchpad under the system temp dir (/private/tmp on macOS, /tmp on Linux).
tmp_root=/tmp
[ -d /private/tmp ] && tmp_root=/private/tmp

scratch_dir=$(jq -r --arg uid "$(id -u)" --arg tmp "$tmp_root" '
  "\($tmp)/claude-\($uid)/\((.workspace.project_dir // .cwd) | gsub("[^A-Za-z0-9]"; "-"))/\(.session_id)/scratchpad"
' <<<"$input")
scratch_used=false
[ -n "$(find "$scratch_dir" -mindepth 1 -print -quit 2>/dev/null)" ] && scratch_used=true

projects_dir="${STATUSLINE_PROJECTS_DIR:-$HOME/projects}"

jq -rj --arg home "$HOME" --arg projects "$projects_dir" --arg scratch_dir "$scratch_dir" --argjson scratch_used "$scratch_used" '
  # The cache countdown only appears when a cold cache would be expensive.
  def expensive_recache_tokens: 50000;
  def bar_cells: 8;
  def five_hours: 18000;
  def seven_days: 604800;
  def pace_margin: 5;  # percentage points ahead of elapsed time before the arrow shows

  def paint($code): "\u001b[\($code)m\(.)\u001b[0m";
  def repeat_text($n): . as $s | [range($n) | $s] | join("");
  def link($path):
    "\u001b]8;;file://\($path | split("/") | map(@uri) | join("/"))\u001b\\\(.)\u001b]8;;\u001b\\";

  def context_segment:
    .context_window.used_percentage as $p
    | if $p == null then empty else
        ($p | floor) as $pct
        | (if $pct <= 50 then "32" elif $pct <= 80 then "33" else "31" end) as $color
        | (($pct / 100 * bar_cells) | round | if . > bar_cells then bar_cells else . end) as $filled
        | ("█" | repeat_text($filled) | paint($color))
          + ("█" | repeat_text(bar_cells - $filled) | paint("38;5;238"))
          + " \($pct)%"
      end;

  def cache_segment:
    .prompt_cache as $c
    | if ($c == null) or (($c.recache_tokens_if_cold // 0) < expensive_recache_tokens) or ($c.caching_observed | not) then empty
      elif $c.expires_at == null then empty
      else
        (($c.expires_at - now) / 60 | ceil) as $min
        | if $min <= 0 then "⧗ cold" | paint("31")
          else "⧗ \($min) min" | paint(if $min <= 5 then "31" else "33" end)
          end
      end;

  def clock($seconds):
    if $seconds >= 86400 then "\($seconds / 86400 | floor)d \($seconds % 86400 / 3600 | floor)h"
    else
      ($seconds / 60 | floor % 60 | tostring | if length < 2 then "0" + . else . end) as $minutes
      | "\($seconds / 3600 | floor):\($minutes)"
    end;

  def window($limit; $length):
    $limit | select(. != null) | {used: .used_percentage, resets: .resets_at, length: $length};

  def limit_segment:
    [window(.rate_limits.five_hour; five_hours), window(.rate_limits.seven_day; seven_days)]
    | max_by(.used)
    | if . == null then empty else
        ((.resets - now) | if . < 0 then 0 else floor end) as $left
        | (100 * (1 - $left / .length)) as $elapsed
        | (.used > $elapsed + pace_margin) as $ahead
        | (.used | round) as $pct
        | ("\($pct)%" + (if $ahead then "↑" else "" end))
          | (if $pct >= 90 then paint("31") elif $ahead then paint("33") else . end)
          | . + " \(clock($left))"
      end;

  def folder_segment:
    (.worktree.original_cwd // .workspace.current_dir // .cwd) as $dir
    | (if ($dir | startswith($projects + "/")) then $dir[($projects | length + 1):]
       elif ($dir | startswith($home + "/")) then "~/" + $dir[($home | length + 1):]
       elif $dir == $home then "~"
       else ($dir | split("/") | last) end)
    | link($dir);

  def worktree_segment:
    (.workspace.git_worktree // .worktree.name) as $name
    | if $name == null then empty else "🌱 \($name)" end;

  def scratch_segment:
    if $scratch_used then "📁 scratch" | link($scratch_dir) else empty end;

  def legend_segment:
    "ⓘ /sl-legend" | paint("36");

  [.model.display_name, context_segment, cache_segment, limit_segment, folder_segment, worktree_segment, scratch_segment, legend_segment]
  | map(select(. != null and . != ""))
  | join(" \u001b[90m|\u001b[0m ")
' <<<"$input"
