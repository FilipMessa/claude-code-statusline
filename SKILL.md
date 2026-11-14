---
name: claude-code-statusline
disable-model-invocation: true
description: Install, update, customize, or explain FilipMessa's Claude Code status line and /sl-legend command.
---

# Claude Code status line

Source: https://github.com/FilipMessa/claude-code-statusline

## Install or update

1. Inspect the installed files: `~/.claude/statusline.sh`, `~/.claude/commands/sl-legend.md`, and `~/.claude/settings.json`. Check for Bash and jq; if jq is missing, provide the platform's installation command or install it when authorized.
2. Stage `statusline.sh` and `commands/sl-legend.md` from one source commit. Record the revision and inspect the files before execution. Compare with installed versions, retaining local customizations. Show any conflicting `statusLine` value or customized file alongside the proposed replacement; resolve replacement authorization before writing. Back up existing files that will change.
3. Run the validation below on the staged script. Once it passes, install the script and companion command at the paths above, creating parent directories as needed, and make the script executable.
4. Merge the following `statusLine` value into `~/.claude/settings.json`, preserving unrelated settings. Create a missing file as a JSON object. An unparseable existing file must remain intact until repaired. Write valid merged JSON atomically.

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.claude/statusline.sh",
       "refreshInterval": 30
     }
   }
   ```

5. Test the installed script. Report changed paths, source revision, and observed output. Tell the user to restart Claude Code and try `/sl-legend`; report live integration success only when observed in Claude Code.

## Customize

Use the installed script as the starting point. Apply the requested change, preserve other customizations, and update the installed legend when a segment's meaning changes. Validate the modified behavior before replacing installed files.

For project-path shortening, inspect `STATUSLINE_PROJECTS_DIR` in the script. Set it in the environment inherited by Claude Code; change shell profiles only within the requested scope.

## Explain

Read the installed script and legend, or the source versions if uninstalled. Explain only: this branch requires no installation or settings changes.

When investigating missing segments or version compatibility, consult the current [Claude Code input documentation](https://code.claude.com/docs/en/statusline). Synthetic fixtures demonstrate rendering; verify which fields the user's version actually supplies. Explain the cache countdown as reported expiry data.

## Validate

Require `bash -n` to pass and synthetic input to produce a successful exit with nonempty output containing the supplied model and directory:

```json
{
  "model": {"display_name": "Test model"},
  "cwd": "/tmp/statusline-preview",
  "workspace": {"current_dir": "/tmp/statusline-preview", "project_dir": "/tmp/statusline-preview"},
  "session_id": "skill-preview",
  "context_window": {"used_percentage": 42}
}
```

Confirm absent optional fields omit their segments without breaking the line. For customization, test each affected branch with its expected visible result, such as context thresholds, expired cache, limit selection, or worktree data. Use timestamps relative to test time for countdowns. Preserve ANSI colors and OSC hyperlinks in terminal output; strip escapes only for a plain-text preview.
