---
description: Explain every segment of the status line
---

Print the following text exactly as written, with no additions, no commentary and no tool calls:

**Status line legend**

| Segment | Example | Meaning |
| --- | --- | --- |
| Model | `Opus 5.5` | The model that is currently answering. |
| Context usage | `███░░░░░ 42%` | How much of the conversation memory is used. Green up to 50%, yellow up to 80%, red above. When it runs out, Claude compacts the older part of the conversation and loses detail. |
| Cache countdown | `⧗ 12 min` | Time until the prompt cache expires. After that the next message costs noticeably more, because the whole conversation is reloaded. Red for the last 5 minutes, `⧗ cold` after expiry. Hidden when reloading would cost fewer than 50,000 tokens. |
| Subscription usage | `73%↑` | The 5-hour or 7-day window, whichever is closer to its limit. The arrow means usage is ahead of elapsed time by at least 5 percentage points. Yellow then, red from 90%. |
| Limit reset | `1:47` | Time until that window resets, as hours:minutes (`2d 7h` for longer spans). |
| Folder | `my-project` | The folder the session works in. Cmd+click opens it. |
| Git worktree | `🌱 fix-login` | The session works in a separate copy of the project. Hidden outside a worktree. |
| Scratchpad | `📁 scratch` | Claude's working files for this session. Shown only when it contains something. Cmd+click opens it. |
| Legend | `ⓘ /sl-legend` | A reminder that typing `/sl-legend` shows this table. |

The line refreshes on every change in the session and at least every 30 seconds. Some segments only appear after Claude's first reply.
