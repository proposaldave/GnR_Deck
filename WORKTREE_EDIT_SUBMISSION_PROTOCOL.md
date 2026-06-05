# Worktree Edit Submission Protocol

## Decision

Use one Codex worktree per deck edit request. Publish from one Local `main` Deck Ops session after the worktrees are complete.

This is the only reliable shape:

1. Dave submits one focused edit request in a new worktree.
2. The worktree branch commits the edit with a complete `PUBLISH TRACE`.
3. Deck Ops audits every `deck/*` branch and publishes everything classified as executable.
4. Deck Ops mirrors `GnR_deck.html` to `index.html`, pushes `main`, and verifies raw GitHub plus cache-busted Pages.

## Dave Submits Edits This Way

Use this template for each edit:

```text
SETTINGS:
Project: `GnR_Deck`
Mode: `New worktree`
Branch: `main`
Environment: `No environment`
Model: `5.5 Medium`

PROMPT:
Read and follow exactly:
prompts/CODEX_PARALLEL_DECK_TASK_PROMPT.txt

Dave's edit request:
[PASTE ONE EXACT DECK EDIT REQUEST HERE]
```

One request means one visible deck intent. If there are five unrelated deck changes, create five worktrees.

## What Makes A Worktree Publish-Ready

A completed worktree is publish-ready only when its final response and commit body include:

- `BRANCH: deck/[short-task-name]`
- `COMMIT: [sha]`
- active source: slide ID, `SLIDE_ALTS[slot]`, or `STAFF_ORDER`
- exact visible marker or selector changed
- source verification result
- visual QA result when the change is visual/layout/order/media
- `PUBLISH TRACE`
- `PUBLISH-READY: yes` in the commit body
- `publish bucket hint: publish_now` or `port_if_stale`
- `safe-to-port-if-stale: yes` for small mechanical edits
- `tools/validate_deck_worktree_handoff.ps1` output with `HANDOFF_VALID=yes`
- `ADDED_SLIDES` and `REMOVED_SLIDES` when `SLIDE_ORDER` changes
- exact removal authorization if anything is deleted, trashed, appended, or removed from active inventory

If that evidence is missing, the branch may still be recoverable, but Deck Ops must inspect the diff manually. Missing trace is the failure mode that created missed edits.

## How Deck Ops Publishes

Use Local mode on `main` with:

```text
Read and follow exactly:
prompts/CODEX_DECK_PUBLISH_PROMPT.txt
```

Deck Ops must run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/audit_deck_publish_candidates.ps1 -BaseRef origin/main -CsvPath publish_audit_current_check.csv
```

The audit is the checklist. It must not be replaced by memory, the app status dot, or a hand-picked branch list.

## Execution Rule

- `publish_now`: merge, mirror, verify, commit, push.
- `port_or_conflict_review`: inspect branch intent; if small and clear, port it surgically, verify, then mark source branch integrated with `ours`.
- `EXPLICIT_DELETE_DECISION_REQUIRED`: a branch with `PUBLISH-READY: yes`, `PUBLISH TRACE`, `needs_explicit_review`, and an `explicit authorization evidence` line quoting Dave's delete/move/trash/remove/appendix instruction. This is not a skip bucket. Deck Ops must extract the removed IDs and registry keys, validate the branch when possible, then merge, port, or name the exact blocker.
- `risky_clean_needs_review` / `risky_conflict_blocked`: do not merge unless the branch trace quotes Dave's exact delete/move/trash instruction or no active inventory is removed. If it does quote Dave's instruction, promote it to branch-specific decision review instead of leaving it in a generic risky pile.
- `dirty_worktree_blocked`: preserve and report; do not drop work.
- `broken_ref_or_merge_base`: report exact ref/path; do not delete refs without Dave approval.

## Done Means

Deck Ops may report `DONE` only when:

- `PUBLISH_NOW_CANDIDATES=0`
- `EXPLICIT_DELETE_DECISION_REQUIRED=0` or every explicit delete branch is named in the report with removed IDs, decision, and next action
- every clean checked-out `deck/*` worktree is either contained in `origin/main` or explicitly blocked
- every local `deck/*` branch not contained in `origin/main` is merged, ported, already live, or in the unresolved ledger
- `GnR_deck.html` and `index.html` hashes match
- `git diff --check` passes
- `tools/verify_slide_order_guard.ps1` passes if `SLIDE_ORDER` changed
- pushed `main`
- raw GitHub and cache-busted Pages verify the visible markers

## Non-Negotiable Limit

No process can guarantee execution of a vague branch with no commit, no trace, no active selector, and no verifiable intent. This protocol makes the edit executable because the branch itself carries the evidence Deck Ops needs.
