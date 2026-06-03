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

### Brand rules

- Brand abbreviation is `GnR`.
- Never use `GnT` or `Give 'n Take`.
- Preferred palette: warm cream `#fbf7ef`, ink `#1a1612`, brand gold `#b8954a`, brand blue `#5B8FD4`, brand red `#c8462c`.
- Never introduce green.
- For hero art or deck visuals, default to text-free imagery because text is rendered separately in HTML.

### Speed rules

- Assume the main deck HTML file is expensive to process.
- Avoid repeatedly reading the whole file.
- Avoid full-file diffs when targeted diffs are enough.
- Avoid repeated Chrome launches.
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
- Push to the existing remote only after checks pass or after noting a non-blocking validation limitation.
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
- Do not push unless Dave explicitly asks.
- Do not open Chrome, Playwright, or screenshot QA unless Dave explicitly asks or the task requires visual QA.
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
- If a branch is technically merged or ancestor-of-main but Dave's visible requested result is absent, treat it as a failed publish and repair/port the intent before reporting `DONE`.
- Edit sessions must leave a publish-readable `PUBLISH TRACE` in both the final response and the commit body: active slide ID, visible text markers, selectors/properties, registry keys, asset paths, source verification, and visual QA result. For multi-element requests, every requested element must be named and verified. If the chat transcript is unavailable later, the commit body must still be enough to publish the branch.
- When Dave names a failed visible phrase or asks "didn't I ask you to change/move/delete this", search all local `deck/*` branch contents and diffs for the exact phrase, likely replacement, nearby slide ID, and screenshot context. A non-checked-out branch containing the requested replacement is a publish candidate and must be ported, merged, or blocked with evidence.
- Publish reports must separate `MERGED AND LIVE`, `SKIPPED / NEEDS REVIEW`, `CONFLICTS`, and `NOT VERIFIED`.
- Dirty unrelated local work must be preserved on a `preserve/[purpose]-local-change` branch before cleaning `main`; never silently drop, stash, reset, or overwrite it.
- Do not use `skip` as a silent final state for completed work. Risky delete/trash, inactive-variant, conflict, broken-ref, and unrelated branches must be listed as `BLOCKED`, `CONFLICTS`, or `NOT VERIFIED` with evidence; if Dave clearly requested the finished branch and the intent is safe to port, apply that intent surgically.
- Publish control must run `tools/audit_deck_publish_candidates.ps1 -BaseRef origin/main -CsvPath "$env:TEMP\gnr_publish_audit_unpublished.csv"` at the start and end of every publish pass. `UNPUBLISHED_LOCAL_DECK_REFS=N` is the required checklist size. If `N` is nonzero at the end, every remaining branch in the CSV must appear in the final report with exact state and next action; omission of a branch is a publish failure.
- Publish control must run a slide-inventory guard before every publish commit when `SLIDE_ORDER` changed. Use `tools/verify_slide_order_guard.ps1` or equivalent before/after parsing. Any unauthorized active slide removal is a publish blocker, not a warning.
- If restoring or inserting a main-flow slide shifts later positions, publish control must update the affected `SLIDE_ALTS` keys so existing visible/alt relationships do not silently move to the wrong active slide.
- If GitHub Pages looks stale, verify local HEAD, `origin/main`, raw GitHub source, and the cache-busted Pages URL before declaring publish failure.
- Verify-live sessions must trace request -> branch -> commit -> active slide source -> index.html -> pushed main -> cache-busted URL -> rendered visible result.
- If `.git/refs/**/desktop.ini` appears, treat it as broken Google Drive ref contamination. Report it and do not delete it unless Dave explicitly approves a ref repair.
