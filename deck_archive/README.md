# GnR Deck Archive Workflow

Purpose: keep fast local rollback points for Dave/Codex edit batches while GitHub keeps the permanent commit history.

## Rules

- Before any risky visual, animation, slide-order, or multi-slide edit, run:
  `powershell -ExecutionPolicy Bypass -File tools/archive_deck_snapshot.ps1 -Reason "short reason"`
- Simple copy edits may rely on the Git commit history unless the slide is already unstable.
- Each completed edit batch still gets committed and pushed to GitHub.
- `GnR_deck.html` is canonical and `index.html` must remain mirrored.
- Snapshots are local-only under `deck_archive/snapshots/` and intentionally ignored by Git.

## Restore

To restore a previous local snapshot:

`powershell -ExecutionPolicy Bypass -File tools/restore_deck_snapshot.ps1 -Snapshot "deck_archive/snapshots/<snapshot-folder>"`

Then open the deck in Chrome, inspect the restored slide, and commit/push if the restore is the chosen direction.

## What Gets Saved

- `GnR_deck.html`
- `index.html`
- `metadata.json` with timestamp, commit, branch, reason, and git status

GitHub commit history remains the permanent archive for every pushed edit batch.
