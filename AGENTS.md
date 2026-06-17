## Deck Edit Operating Rules

This repo contains a large single-file HTML investor pitch deck. Treat every deck request as a targeted surgical edit unless the user explicitly asks for a full-deck rewrite.

### Default mode

- Use Targeted Deck Edit Mode for all deck work.
- Make the smallest diff that satisfies the request.
- Do not scan, rewrite, reformat, regenerate, or normalize the whole deck.
- Do not touch unrelated slides, sections, CSS, JS, assets, registries, or copy.
- Do not change deck order, narrative, brand system, or slide architecture unless explicitly requested.
- Do not rename files, move assets, restructure folders, or change build tooling unless explicitly required.
- Do not delete, reset, clean, stash, checkout, or overwrite user work.

### Finding the target

- Start with `git status --short`.
- Locate the target by exact visible text, slide ID, section ID, dot/alt registry entry, nearby heading, unique class name, or screenshot context.
- For visible text edits, locate the exact active selector/DOM line that renders the visible text. Do not accept nearby matches, duplicate variants, top-left eyebrows, comments, hidden blocks, appendix/trash blocks, or inactive alts as the target.
- Use targeted search. Avoid broad repo exploration.
- Ignore large/generated folders unless directly relevant: `node_modules`, `dist`, `build`, exports, screenshots, backups, generated assets, cache folders.
- If multiple matches exist, inspect only enough surrounding context to choose the correct slide.
- If ambiguity remains but a safe minimal interpretation exists, proceed with that interpretation.
- Ask the user only if the edit would risk changing the wrong slide or damaging deck structure.

### Editing

- Make one focused edit at a time.
- Keep CSS/HTML/JS scoped to the requested slide or component.
- Preserve existing IDs, class names, animation hooks, registry relationships, responsive behavior, and asset paths unless the request requires changing them.
- Do not introduce dependencies.
- Do not split the HTML file, create a new deck system, or perform architectural cleanup while there is active deck-edit queue work.
- For exact copy changes, perform direct targeted replacement and source verification. Do not open Chrome unless there is a realistic layout risk.
- For layout/visual changes, use scoped CSS/HTML edits and one focused visual check.
- For deleting a slide, prefer removing it from active deck order / alt registries / navigation first. Delete the HTML block only when clearly safe or explicitly requested.
- For moving or restoring slides with animations, preserve the active slide ID when that avoids risky JS rewiring.
- SLIDE_ORDER is protected inventory. Do not remove any existing active slide ID from `SLIDE_ORDER` unless Dave explicitly requested that exact slide be deleted, trashed, moved to appendix, or moved to an alt rail in the current task.
- Before committing or publishing any change that touches `SLIDE_ORDER`, compare before/after order and report `ADDED_SLIDES`, `REMOVED_SLIDES`, and the reason for every removed slide. If an active slide disappeared without explicit request, restore it before `DONE`.
- For mirror files, identify the canonical deck file first, edit canonical first, then mirror to the existing GitHub Pages files such as `sites/GnR_Deck/GnR_deck.html` and `sites/GnR_Deck/index.html` if that is the repo's established workflow. Do not hand-edit mirrors differently from canonical.

### Archive / rollback

- Git commits are the permanent archive. Every completed edit batch must be committed and pushed.
- Before risky visual, animation, slide-order, asset, or multi-slide edits, create a local snapshot:
  `powershell -ExecutionPolicy Bypass -File tools/archive_deck_snapshot.ps1 -Reason "short reason"`
- Local snapshots live in `deck_archive/snapshots/`, are ignored by Git, and contain `GnR_deck.html`, `index.html`, and `metadata.json`.
- To restore a local snapshot, run:
  `powershell -ExecutionPolicy Bypass -File tools/restore_deck_snapshot.ps1 -Snapshot "deck_archive/snapshots/<snapshot-folder>"`
- After restoring, open Chrome, inspect the deck, then commit and push only if Dave accepts the restored direction.

### Brand rules

- Brand abbreviation is `GnR`.
- Never use `GnT` or `Give 'n Take`.
- Preferred palette: warm cream `#fbf7ef`, ink `#1a1612`, brand gold `#b8954a`, brand blue `#5B8FD4`, brand red `#c8462c`.
- Never introduce green.
- For hero art or deck visuals, default to text-free imagery because text is rendered separately in HTML.

### Image Generation vs Deck Code

DECISION: Default to HTML/CSS/deck-code edits for `GnR_deck.html` because most deck work needs precision, active-slide verification, tiny diffs, and preservation of slide IDs, alts, nav, animation hooks, and brand typography.

Use deck code, not image generation, for:

- copy edits
- layout fixes
- typography, spacing, labels, dots, arrows, icons, charts, diagrams, overlays
- brand-color fixes
- active/inactive alt wiring
- screenshots, logos, video embeds, Drive iframe swaps
- anything where exact readable text is required

Use image generation only when the missing piece is a new text-free bitmap visual:

- hero/background image
- cinematic or editorial community scene
- metaphorical visual for reciprocity, human value, measurable connection, or real-world community
- texture/section-breaker/atmospheric asset that HTML/CSS cannot produce cleanly

Generated images must be:

- text-free
- brand-compatible with warm cream / ink / gold / red
- not generic SaaS/AI stock art
- not blue-purple gradient tech art
- not green
- inserted only after active-slide/source path is identified
- rendered text separately in HTML, never baked into the image

### Automatic Deck Request Routing

Dave does not need to name the lane. Codex must infer the safest lane from the request and state `DECISION: Fast Lane`, `DECISION: Worktree Lane`, or `DECISION: Publish-Control Lane` before acting.

Use Fast Lane for:

- exact copy/text replacements on a proven active slide selector
- tiny CSS/layout/position/color/readability fixes on a known active slide
- small batches of independent text/CSS edits that do not touch slide inventory, alt rails, images/assets, JS navigation, publish queue, or exports

Fast Lane execution:

- batch related tiny edits in one pass
- use targeted source search, selector-exact verification when copy changes, `git diff --check`, one commit/push, and at most one live/cache check when publishing
- skip full branch audit, full visual QA, PDF export, Slack, and repeated Chrome opens unless the request itself requires them

Use Worktree Lane automatically for:

- isolated edit requests that Dave should review before publish
- experimental visual/layout/image variants
- parallel edit sessions that should produce a local `deck/*` branch and commit without pushing

Use Publish-Control Lane automatically for:

- `publish now`, worktree integration, `deck/*` branches, JSON annotation queues, or any missed/unpublished/stale branch concern
- slide deletes, trash, appendix, moves, restores, `SLIDE_ORDER`, `SLIDE_ALTS`, active/alt rail changes, or anything that can lose a slide
- image generation/replacement, new assets, PDF/export, broad visual QA, GitHub Pages mismatch, or "make sure everything is published/live"
- "didn't I ask..." / missed visible result reports that require branch/source audit

If a request mixes lanes, use the highest-risk lane unless the risky work can be cleanly deferred and the remaining edits are independent Fast Lane edits.

### Speed rules

- Assume the main deck HTML file is expensive to process.
- Avoid repeatedly reading the whole file.
- Avoid full-file diffs when targeted diffs are enough.
- Avoid repeated Chrome launches.
- Do not open Chrome at the start of an edit session just to show the current file.
- After a completed Local-mode deck or annotation-tool edit batch, open the updated local annotation deck exactly once in Dave's Chrome: `file:///C:/Users/dave/CLAUDE%20COWORK/sites/GnR_Deck/GnR_deck.html?annotations=1`. This is the preferred handoff point so Dave can continue annotating.
- After a completed publish or Local-mode deck/annotation batch that verifies GitHub Pages, send Dave a private Slack DM as `Proposal Dave` with the cache-busted annotatable GitHub URL: `https://proposaldave.github.io/GnR_Deck/?annotations=1&cb=<timestamp>`. Resolve the Slack user before sending. If Slack tools are unavailable or the user cannot be resolved, do not pretend it was sent; report `SLACK: BLOCKED` with the exact reason and include the URL in the final response.
- In Worktree mode, do not open Chrome at handoff unless visual QA is required or Dave explicitly asked; report the local file URL instead. Publish/Local sessions may open the updated annotation deck once after mirroring and checks.
- Avoid repeated GitHub Pages cache checks.
- Avoid Playwright/runtime debugging unless the user specifically asks for QA automation.
- If headless/browser QA fails because of local Windows/tooling issues, do not spend cycles fixing QA. Fall back to source checks, targeted DOM checks if cheap, or one normal Chrome open.
- Batch validation for a small group of queued edits when safe instead of doing full validation after every tiny text replacement.
- For simple text edits, source check + diff check + commit/push is enough.
- For visual edits, one local Chrome render check is enough unless the slide is obviously broken.
- For live GitHub Pages, check once after push if needed. Do not poll repeatedly for cache propagation.

### Validation

Use the cheapest sufficient checks:

- `git diff --check`
- targeted source search: old text absent, new text present
- verify canonical and mirror hashes match when mirroring is required
- verify slide ID remains in or out of the correct main/alt registry
- one local Chrome open/check for visual edits
- one live-page HTTP/source check after push only when publishing matters

Do not run expensive builds, full previews, screenshot generation, or full-deck audits unless the request requires it.

### Queue handling

- Finish the current visible task before starting the next one.
- If a newer user instruction supersedes an older unfinished one, preserve completed non-conflicting work and continue with the newer instruction.
- Do not revisit already completed commits unless the current request depends on them.
- If a task was interrupted mid-edit, inspect current file state and continue from there instead of starting over.
- If the visible queue is exhausted, report that there is no visible pending deck request.

### Commit/push

- Stay on the current branch unless explicitly told otherwise.
- Commit completed deck edits with concise messages.
- For normal Local-mode deck edits, push to the existing remote only after checks pass or after noting a non-blocking validation limitation.
- For parallel Worktree-mode deck edits, do not push; the branch and local commit are the deliverable.
- For Deck Ops / Publish Control sessions on `main`, push after integration, mirror, and verification.
- Do not create a separate commit for AGENTS.md if there is an active deck edit ready to commit; include it in the next sensible deck-work commit unless that would mix unrelated work.

### Response format

Do not use long mission statements.
Do not say "Model check."
Do not provide proposals when the user asked for execution.
Do not ask me to review routine work.

After each completed task, respond briefly:

DONE:
- what changed

TOUCHED:
- file(s) and slide/region

CHECKS:
- what was verified

PUSH:
- commit hash if pushed, or why not

SLACK:
- DM sent to Proposal Dave with the annotatable GitHub URL, or exact blocker if Slack was unavailable

BLOCKED:
- only if truly blocked

NEXT:
- next visible queued task, or "No visible pending deck request."

## Permanent Codex Repo Rules

- This repo is the working source for the Give n Receive deck.
- Use Worktree mode for parallel Codex edits.
- Never run multiple Local sessions editing GnR_deck.html at once.
- New edit sessions must end with a real branch and commit.
- Parallel edit sessions should edit GnR_deck.html only unless the task explicitly requires assets.
- Parallel edit sessions should not edit index.html.
- index.html should be updated only during integration/publish.
- Do not edit the old pitch_visuals copy during parallel tasks.
- Parallel Worktree-mode sessions must not push. Deck Ops / Publish Control sessions may push `main` after verified publish integration.
- Do not open Chrome, Playwright, or screenshot QA during work unless Dave explicitly asks or the task requires visual QA. The normal browser handoff is one final Chrome open of the updated local annotation deck after a completed Local-mode deck/annotation batch.
- Do not regenerate images unless Dave explicitly asks.
- Do not refactor, reformat, lint, prettify, or restructure the deck.
- Keep diffs tiny and localized.
- Preserve slide IDs, animation hooks, navigation, dot view, and presenter behavior.
- Company name is Give n Receive, abbreviated GnR.
- Never use Give n Take, GnT, or Give ’n Take.
- Brand palette: warm cream #fbf7ef, ink #1a1612, gold #b8954a, blue #5B8FD4, red #c8462c. Never use green.

## Deck Ops / Publish Control

- Treat `GnR_deck.html` as canonical source and `index.html` as the GitHub Pages mirror.
- Parallel edit sessions must use Worktree mode, create `deck/[short-task-name]`, commit, and not push.
- Codex owns verification. Dave should not have to identify failed edits manually after the fact.
- Every edit session must create an acceptance contract before patching: requested change, expected active slide/section, expected visible result, likely touched files, and whether visual QA is required.
- Before editing a visible slide, identify the active source path from `SLIDE_ORDER`, `SLIDE_ALTS`, or `STAFF_ORDER`; if the requested element is only in an inactive variant, port the intent to the active slide only when obvious, otherwise report `BLOCKED`.
- Do not patch inactive variants unless Dave explicitly requested variants.
- Do not report `DONE` unless the requested change exists in the active live slide source and required rendered/visual verification passed.
- If verification fails, attempt one targeted correction, verify again, then report `BLOCKED` with root cause and next step.
- Publish sessions run in Local mode on `main`, merge only verified safe `deck/*` branches, mirror `GnR_deck.html` to `index.html`, verify hashes, then push only when Dave explicitly requested publishing.
- A completed Codex worktree session in the app UI, shown by a solid status dot, is a publish candidate. Publish control should locate the matching `deck/*` branch and publish it automatically if it merges cleanly and passes active-source checks.
- Worktree list is not the full publish universe. Publish control must also audit every local `refs/heads/deck/*` branch, especially any local deck branch not contained in `origin/main`, even when it is not currently checked out.
- Before reporting publish `DONE`, publish control must prove `UNPUBLISHED_LOCAL_DECK_REFS=0` or list each remaining local deck branch under `BLOCKED`, `CONFLICTS`, or `NOT VERIFIED` with the exact reason.
- Do not wait for Dave to identify each completed branch manually. If a completed branch is stale but its intent is clear, port the intent surgically onto current `main` instead of leaving it unpublished.
- After every publish, audit remaining checked-out `deck/*` worktrees, non-checked-out local `deck/*` branches, and recent `deck/*` branches for completed-session candidates before reporting done. Each completed candidate must be merged, ported, or blocked with the exact reason and next action.
- Branch status is not enough. For every completed-session branch, diff it against its merge-base and verify the actual visible intent in current `main`: text, slide IDs, selectors, JS hooks, assets, and registry entries. Do not record an `ours` merge or call a branch integrated until that intent is present and verified.
- Selector-exact verification is mandatory for copy edits. The replacement text appearing somewhere in the file is not enough; the old text must be absent from the original active selector/DOM line and the new text must be present in that same active selector/DOM line.
- If a branch is technically merged or ancestor-of-main but Dave's visible requested result is absent, treat it as a failed publish and repair/port the intent before reporting `DONE`.
- Edit sessions must leave a publish-readable `PUBLISH TRACE` in both the final response and the commit body: active slide ID, visible text markers, selectors/properties, registry keys, asset paths, source verification, visual QA result, publish bucket hint (`publish_now`, `port_if_stale`, or `needs_explicit_review`), and `safe-to-port-if-stale: yes/no`. For multi-element requests, every requested element must be named and verified. If the chat transcript is unavailable later, the commit body must still be enough to publish the branch.
- Delete/trash/appendix/move branches must quote Dave's exact removal instruction in the `PUBLISH TRACE`. Without explicit removal evidence, Publish Control blocks the branch instead of deleting active inventory.
- A delete/trash/appendix/move branch with `PUBLISH-READY: yes`, a `PUBLISH TRACE`, and explicit removal authorization is not a generic risky skip. Publish Control must extract the removed IDs and registry keys, validate the branch when possible, then merge, surgically port, or list that exact branch under `BLOCKED / NEEDS REVIEW` with the next action. Do not bury it inside `RISKY_OR_DELETE_BLOCKED`.
- When Dave names a failed visible phrase or asks "didn't I ask you to change/move/delete this", search all local `deck/*` branch contents and diffs for the exact phrase, likely replacement, nearby slide ID, and screenshot context. A non-checked-out branch containing the requested replacement is a publish candidate and must be ported, merged, or blocked with evidence.
- Publish reports must separate `MERGED AND LIVE`, `SKIPPED / NEEDS REVIEW`, `CONFLICTS`, and `NOT VERIFIED`.
- Dirty unrelated local work must be preserved on a `preserve/[purpose]-local-change` branch before cleaning `main`; never silently drop, stash, reset, or overwrite it.
- Do not use `skip` as a silent final state for completed work. Risky delete/trash, inactive-variant, conflict, broken-ref, and unrelated branches must be listed as `BLOCKED`, `CONFLICTS`, or `NOT VERIFIED` with evidence; if Dave clearly requested the finished branch and the intent is safe to port, apply that intent surgically.
- Publish control must run `tools/audit_deck_publish_candidates.ps1 -BaseRef origin/main -CsvPath "$env:TEMP\gnr_publish_audit_unpublished.csv"` at the start and end of every publish pass. `UNPUBLISHED_LOCAL_DECK_REFS=N` is the required checklist size. The audit also reports `PUBLISH_NOW_CANDIDATES`, `PORT_OR_CONFLICT_REVIEW`, `EXPLICIT_DELETE_DECISION_REQUIRED`, `RISKY_OR_DELETE_BLOCKED`, `DIRTY_WORKTREE_BLOCKED`, and `BROKEN_REF_OR_MERGE_BASE`.
- Publish `DONE` requires `PUBLISH_NOW_CANDIDATES=0` and `ZERO_SAFE_OR_PORTABLE_LEFT=True`. Every `PORT_OR_CONFLICT_REVIEW` branch must receive a branch-specific diff/intent extraction attempt; if the intent is tiny and clear, port it, verify it, and only then mark the branch integrated. If it cannot be safely ported, record the exact blocker and next action.
- If `UNPUBLISHED_LOCAL_DECK_REFS` is nonzero at the end, every remaining branch in the CSV must appear in an unresolved ledger with branch, publish bucket, mergeability, worktree status, exact blocker, and exact next action; omission of a branch is a publish failure.
- Publish control must run a slide-inventory guard before every publish commit when `SLIDE_ORDER` changed. Use `tools/verify_slide_order_guard.ps1` or equivalent before/after parsing. Any unauthorized active slide removal is a publish blocker, not a warning.
- If restoring or inserting a main-flow slide shifts later positions, publish control must update the affected `SLIDE_ALTS` keys so existing visible/alt relationships do not silently move to the wrong active slide.
- If GitHub Pages looks stale, verify local HEAD, `origin/main`, raw GitHub source, and the cache-busted Pages URL before declaring publish failure.
- Verify-live sessions must trace request -> branch -> commit -> active slide source -> index.html -> pushed main -> cache-busted URL -> rendered visible result.
- If `.git/refs/**/desktop.ini` appears, treat it as broken Google Drive ref contamination. Report it and do not delete it unless Dave explicitly approves a ref repair.
