# claude-code-analyze-review

Claude Code `/analyze-review` plugin — triage code review feedback into a clear verdict (`FIX`, `IGNORE`, or `DISCUSS`) with short reasoning. **No implementation.** It tells you what to do; you decide whether to do it.

Designed for the moment a reviewer leaves a comment and you're not sure if it's a real bug, a style nit, or worth pushing back on. Paste the comment, get a verdict.

---

## Example

```text
> /analyze-review "Why aren't you handling the null case in parseUserId? Callers in auth.ts and session.ts will crash."

Verdict: FIX

Reasoning:
- Reviewer flagged that parseUserId returns null but callers assume string.
- Factually correct — both call sites in auth.ts:88 and session.ts:142 would NPE on a malformed token.
- Low effort (one-line return type change + two `if` guards at call sites).
- Small blast radius, no API change for downstream consumers.

Suggested change: tighten parseUserId's return type and add null guards at the two call sites.
```

---

## What `/analyze-review` accepts

- **Pasted review text** — `/analyze-review "the reviewer said X..."`
- **PR URL or number** — `/analyze-review #482` (pulls comments via `gh pr view`)
- **File path with line** — `/analyze-review src/auth.ts:88` (reads the code under discussion)
- **Free-form description** — `/analyze-review "Alice said our retry logic should be a shared helper"`

The three verdicts:

| Verdict | Meaning |
|---|---|
| `FIX` | Reviewer is right, change is worth the cost. |
| `IGNORE` | Reviewer is wrong, or it's pure bikeshedding with no team rule behind it. |
| `DISCUSS` | Legitimate point but needs a human call — scope, tradeoff, missing context. |

---

## Installation

Three install options. Pick whichever fits your workflow.

### Option 1 — One-line install (fastest)

Installs only the `/analyze-review` command into `~/.claude/commands/`. No plugin, no clone.

```bash
curl -fsSL https://raw.githubusercontent.com/nasrat-v/claude-code-analyze-review/main/setup.sh | bash
```

Project-local install (only available inside one repo):

```bash
curl -fsSL https://raw.githubusercontent.com/nasrat-v/claude-code-analyze-review/main/setup.sh | bash -s -- --project
```

### Option 2 — Plugin via marketplace (recommended for plugin users)

Inside Claude Code:

```text
/plugin marketplace add nasrat-v/claude-code-analyze-review
/plugin install claude-code-analyze-review@claude-code-analyze-review
```

Cleanest path if you already use `/plugin` to manage other extensions — updates, uninstalls, and listing all flow through the same command.

### Option 3 — Manual clone

```bash
git clone https://github.com/nasrat-v/claude-code-analyze-review.git
cd claude-code-analyze-review
./setup.sh             # installs to ~/.claude/commands/
# or
./setup.sh --project   # installs to ./.claude/commands/ in current repo
```

---

## Verifying the install

Open Claude Code and type `/` — you should see `/analyze-review` in the command list. Then try:

```text
/analyze-review "we should rename all our variables to camelCase for consistency"
```

You should get a `FIX | IGNORE | DISCUSS` verdict with 3–6 bullet points of reasoning. If you get a code change instead of a verdict, the command file didn't load — check `~/.claude/commands/analyze-review.md` exists.

---

## Uninstall

**Plugin install:**
```text
/plugin uninstall claude-code-analyze-review
```

**Standalone install:**
```bash
./setup.sh --uninstall
# or just:
rm ~/.claude/commands/analyze-review.md
```

---

## How it works (the rules the command follows)

The command file is a prompt with hard constraints. Every answer must:

- **Pick exactly one verdict** — `FIX`, `IGNORE`, or `DISCUSS`. No hedging between two.
- **Stay read-only** — never implement the fix, only recommend.
- **Ground the verdict in the actual code** when the review references something concrete.
- **Be short** — verdict plus 3–6 bullet points. No essays.
- **Separate fact from opinion** — call out bikeshedding when it's bikeshedding.
- **Default to `DISCUSS`** when torn between `FIX` and `IGNORE` instead of faking confidence.

The value is the constraint. Loosen it and you get the same wishy-washy "well, it could go either way..." responses Claude gives by default.

---

## Pairs well with

- [`/explain`](https://github.com/nasrat-v/claude-code-explain) — plain-English summaries of code or plans. Use `/explain` to understand what a reviewer is pointing at, then `/analyze-review` to decide what to do about it.

---

## Contributing

PRs welcome. The command lives in [`commands/analyze-review.md`](commands/analyze-review.md) — tweak the rules, add example pairs, or refine the output format. If you change behavior, update the example in this README so users see the new shape.

---

## License

MIT — see [LICENSE](LICENSE).
