---
description: Analyze a code review comment and recommend fix / ignore / discuss — reasoning only, no implementation.
argument-hint: <review comment, PR feedback, or reviewer suggestion — paste text, file path, or PR URL>
---

# /analyze-review

Your job: read the review feedback in `$ARGUMENTS` and recommend whether to act on it. **Do not implement the change.** Output is a verdict plus the reasoning behind it.

## Rules

- **No code changes.** Read-only. If the user wants the fix applied, they will ask in a follow-up.
- **Pick exactly one verdict**: `FIX`, `IGNORE`, or `DISCUSS`. Never hedge between two.
- **Ground the verdict in the actual code** when the review references something concrete. Read the file, grep the symbol, check the surrounding context before deciding.
- **Length**: verdict + 3–6 bullet points of reasoning. No essays.
- **Separate facts from opinion.** If the reviewer is factually wrong, say so directly. If it's a style preference, name it as such.
- **Estimate effort and risk** when recommending `FIX` — a one-line tweak and a three-day refactor deserve different treatment.

## What to resolve `$ARGUMENTS` against

1. **Pasted review text** → analyze directly.
2. **PR URL or PR number** → use `gh pr view <id> --comments` to pull the review body and inline comments, then analyze.
3. **File path with line reference** (`src/foo.ts:42`) → Read the file at that line, then analyze the context the reviewer is pointing at.
4. **Ambiguous reference** ("the review Alice left") → ask one short clarifying question (which PR? which comment?) before answering.

## How to decide the verdict

- **FIX** — the reviewer is correct and the change is worth the cost. Bug, security issue, broken contract, clear readability win, or convention the team already follows.
- **IGNORE** — the reviewer is wrong, the suggestion makes the code worse, the cost outweighs the benefit, or it's bikeshedding on a style point with no team-wide rule.
- **DISCUSS** — legitimate point but needs a human call: scope creep, design tradeoff, conflicts with another decision, or you don't have enough context (e.g., team conventions, product intent) to decide alone.

When uncertain between `FIX` and `IGNORE`, default to `DISCUSS` — don't fake confidence.

## Output format

```
Verdict: <FIX | IGNORE | DISCUSS>

Reasoning:
- <point 1 — what the reviewer is saying, restated in one line>
- <point 2 — is it factually right? cite the code if relevant>
- <point 3 — cost / risk / effort estimate>
- <point 4 — recommendation in one sentence: what to do next, who decides>
```

If `FIX`: add a one-line **Suggested change:** description (still no code — just *what* to change, not *how*).
If `DISCUSS`: add a one-line **Question for the team:** that captures the open call.

## Examples of good output

> **Verdict: FIX**
>
> Reasoning:
> - Reviewer flagged that `parseUserId` returns `null` but callers in `auth.ts:88` and `session.ts:142` assume it returns a string.
> - Factually correct — both call sites would NPE on a malformed token.
> - Low effort (one-line return type change + two `if` guards at call sites).
> - Small blast radius, no API change for downstream consumers.
>
> **Suggested change:** tighten `parseUserId`'s return type and add null guards at the two call sites.

> **Verdict: IGNORE**
>
> Reasoning:
> - Reviewer asked us to switch from `for…of` to `.forEach` for consistency.
> - No existing team rule in `eslint.config.js` or CONTRIBUTING.md mandates either.
> - Both perform identically here; the current loop has an early `break` that's awkward to express with `.forEach`.
> - Pure style preference with a real downside — leave as-is, reply politely on the PR.

> **Verdict: DISCUSS**
>
> Reasoning:
> - Reviewer proposed extracting the retry logic into a shared `withRetry` helper.
> - Idea has merit — same pattern appears in 3 other files.
> - But scope: this PR is a bugfix, and the extraction touches code owned by another team.
> - Worth doing, just not in this PR.
>
> **Question for the team:** split the retry helper into a follow-up PR, or bundle it here and request review from the other team?

## Examples of bad output (do NOT do this)

- Implementing the fix anyway. (You were told not to.)
- "It depends, you could go either way." (No verdict. Pick one or pick `DISCUSS`.)
- A 12-bullet wall of text covering every possible angle. (Too long.)
- Restating the reviewer's comment verbatim without judging it. (No analysis.)
