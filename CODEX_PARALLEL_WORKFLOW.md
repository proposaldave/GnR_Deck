# Codex Parallel Deck Workflow

## Edit Sessions

1. Use Worktree mode only.
2. Paste `prompts/CODEX_PARALLEL_DECK_TASK_PROMPT.txt`.
3. Dave adds only the desired edit at the bottom.
4. Codex creates an acceptance contract, finds the active live slide/section, edits only that target, and self-corrects once if verification fails.
5. The session creates `deck/[short-task-name]`, commits, and does not push.
6. The session reports `DONE` only after active-source verification and required rendered/visual verification pass.
7. The session leaves a publish-readable `PUBLISH TRACE`: request slug, active slide ID, changed visible text, changed selectors/properties, changed registry keys, asset paths, source verification, and visual QA result.
8. The `PUBLISH TRACE` must include a publish bucket hint (`publish_now`, `port_if_stale`, or `needs_explicit_review`) and `safe-to-port-if-stale: yes/no`.
9. Delete/trash/appendix/move requests must quote Dave's exact removal instruction in the `PUBLISH TRACE`.
10. The commit body must also contain the same `PUBLISH TRACE`. Publish Control cannot rely on the app chat transcript being available later.

## Active Source Contract

- Main-flow slides are active only when present in `SLIDE_ORDER`.
- Dot variants are active only when present in the correct `SLIDE_ALTS[slot]`.
- Staff slides are active only when present in `STAFF_ORDER`.
- If the visible requested target is not active, stop with `BLOCKED` and report the inactive slide ID instead of editing it.
- Red dots are alternate candidates for the same slot, not different slides.
- Codex owns verification. Dave should not have to inspect branches or identify failed edits manually.
- Visual/layout/copy-positioning/image/order edits require rendered evidence unless Dave explicitly approves source-only.
- Copy edits require selector-exact verification: identify the active selector/DOM line that rendered the old visible text, remove the old text from that same selector, and verify the new text appears in that same selector. Finding the replacement in a nearby eyebrow, duplicate, alt, hidden block, comment, or appendix/trash block is a failed edit.
- If verification fails, Codex attempts one targeted correction, verifies again, then reports `BLOCKED` with the root cause.

## Slide Inventory Guard

- `SLIDE_ORDER` is the active-slide inventory, not just implementation detail.
- No edit or publish session may remove an ID from `SLIDE_ORDER` unless Dave explicitly requested that exact slide be deleted, trashed, moved to appendix, or moved to an alt rail.
- Any session that changes `SLIDE_ORDER` must report `ADDED_SLIDES`, `REMOVED_SLIDES`, and the active-slot reason for every removed slide.
- If a slide disappears without explicit request, restore it before committing or publishing.
- Use `tools/verify_slide_order_guard.ps1 -BaseRef <before> -TargetRef WORKTREE` during edit sessions and before publish commits whenever order changes. After commit, `-TargetRef HEAD` is also acceptable.

## Publish Sessions

1. Use Local mode on `main`.
2. Paste `prompts/CODEX_DECK_PUBLISH_PROMPT.txt`.
3. Preserve unrelated dirty work before publishing.
4. Build the publish universe from checked-out worktrees plus every local `refs/heads/deck/*` branch, especially branches not contained in `origin/main`.
5. Run `tools/audit_deck_publish_candidates.ps1 -BaseRef origin/main -CsvPath "$env:TEMP\gnr_publish_audit_unpublished.csv"` before decisions and again before `DONE`.
6. Merge verified safe `deck/*` branches; when a completed branch is stale but the intent is clear, port the intent surgically onto current `main` instead of dropping it.
7. Do not use `skip` as a silent final state for completed work. If a completed branch cannot be merged or ported, report `BLOCKED` with the exact branch, blocker, and next action.
8. If `SLIDE_ORDER` changed, run the slide inventory guard before committing. Unauthorized active-slide removal is a hard blocker, not a warning.
9. If a restored or inserted slide shifts later active slots, update affected `SLIDE_ALTS` keys in the same publish pass.
10. Copy `GnR_deck.html` to `index.html`, verify hash identity, push if requested, then verify raw GitHub and Pages source.
11. Report exactly what is `MERGED AND LIVE`, `SKIPPED / NEEDS REVIEW`, `CONFLICTS`, and `NOT VERIFIED`.

## Dave Workflow

Normal edit:
New Codex chat -> GnR_Deck -> New worktree -> main -> No environment -> 5.5 Medium -> paste normal edit request.

Dave only provides the desired edit.
Codex must verify active rendered success or report `BLOCKED`.

Publish:
Deck Ops session -> Work locally -> main -> use publish prompt.
Publish merges only verified safe branches and reports exactly what went live.

Completed-session rule:
A solid status dot in the Codex app means the worktree session is done. Publish control should treat the matching `deck/*` branch as a publish candidate, not wait for Dave to name it again. Merge it if it is clean and active-source verified. If a direct merge would roll back newer live work, port the requested intent surgically. If neither is safe, report `BLOCKED` with the exact blocker.

Before declaring a publish pass done, run a completed-session audit: compare `git worktree list --porcelain`, all local `refs/heads/deck/*` branches, merge status against `origin/main`, branch commit messages, and current `main`. Every completed candidate must be merged, ported, or blocked with evidence. Do not leave completed work behind under a generic skipped label.

Mechanical audit gate:
Publish Control must run `tools/audit_deck_publish_candidates.ps1 -BaseRef origin/main -CsvPath "$env:TEMP\gnr_publish_audit_unpublished.csv"` at the start and end of every publish pass. The output line `UNPUBLISHED_LOCAL_DECK_REFS=N` is not advisory; it is the checklist size. The audit also reports `PUBLISH_NOW_CANDIDATES`, `PORT_OR_CONFLICT_REVIEW`, `RISKY_OR_DELETE_BLOCKED`, `DIRTY_WORKTREE_BLOCKED`, and `BROKEN_REF_OR_MERGE_BASE`.

Zero-safe-left gate:
Before `DONE`, `PUBLISH_NOW_CANDIDATES` must be zero. Publish Control must also prove every `PORT_OR_CONFLICT_REVIEW` branch received a branch-specific intent extraction attempt. If the intent is tiny and clear, port it and mark the source branch integrated only after verification. If it cannot be safely ported, the branch must have a one-line blocker and next action. A final report that merely says many branches were blocked is invalid.

Unresolved ledger:
If `UNPUBLISHED_LOCAL_DECK_REFS` is nonzero at the end, every remaining branch from the CSV must appear in an unresolved ledger with: branch, publish bucket, mergeability, worktree status, exact blocker, and exact next action. A final report that omits any CSV branch is invalid.

Unpublished-local-branch rule:
`git worktree list --porcelain` is not enough. A finished branch can exist without a checked-out worktree. Before `DONE`, prove `UNPUBLISHED_LOCAL_DECK_REFS=0` for local `deck/*` branches not contained in `origin/main`, or list every remaining branch under `BLOCKED`, `CONFLICTS`, or `NOT VERIFIED` with the next action.

Failed-visible-phrase rule:
When Dave reports a missed visible phrase or asks "didn't I ask...", search all local `deck/*` branch contents and diffs for the exact old text, likely replacement, nearby slide ID, and screenshot context. If a branch contains the requested tiny copy/layout/registry intent, port it to current `main`, verify the active source/render result, then mark the source branch integrated. Do not ask Dave to find the branch again.

Branch-intent audit:
For every completed-session branch, diff the branch against its merge-base and extract the actual intent: visible text, active slide IDs, selectors, JavaScript hooks, assets, and registry edits. Verify that intent exists in current `main` before calling it integrated. An `ours` merge is allowed only after the intent has already been ported and verified. If a branch is an ancestor of `main` but the visible result is absent, treat it as a failed publish and repair it before reporting `DONE`.

Wrong-selector guard:
For copy changes, publish control must verify the original active selector/DOM line, not only the phrase. If the new text landed in a nearby eyebrow, duplicate slide, inactive variant, hidden block, comment, appendix/trash block, or another active slide while the original visible selector still has the old text, classify as `wrong selector`, repair the exact selector, and only then mark the branch/request live.

Trace requirement:
New edit branches must put `PUBLISH TRACE` in the commit body. If an older branch lacks that trace, Publish Control must infer the visible intent from the diff and commit message instead of skipping it. `MISSING_PUBLISH_TRACE` is a diagnostic label, not a blocker by itself.

Never run multiple Local edit sessions against `GnR_deck.html`.
Never edit the old `pitch_visuals` copy during parallel work.
Never push from parallel edit sessions.
