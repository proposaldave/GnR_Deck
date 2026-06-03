param(
  [string]$BaseRef = "origin/main",
  [string]$CsvPath = ""
)

$ErrorActionPreference = "Continue"

function GitLines {
  param([string[]]$ArgsList)
  $output = & git @ArgsList 2>$null
  if ($LASTEXITCODE -ne 0) {
    throw "git $($ArgsList -join ' ') failed"
  }
  return @($output)
}

function GitText {
  param([string[]]$ArgsList)
  return (GitLines $ArgsList) -join "`n"
}

function Test-Ancestor {
  param([string]$Branch, [string]$Target)
  & git merge-base --is-ancestor $Branch $Target *> $null
  return ($LASTEXITCODE -eq 0)
}

$worktreeByBranch = @{}
$currentWorktree = $null
foreach ($line in (GitLines @("worktree", "list", "--porcelain"))) {
  if ($line -like "worktree *") {
    $currentWorktree = $line.Substring("worktree ".Length)
    continue
  }
  if ($line -like "branch refs/heads/*") {
    $branch = $line.Substring("branch refs/heads/".Length)
    $worktreeByBranch[$branch] = $currentWorktree
  }
}

$rows = @()
$branchLines = GitLines @(
  "for-each-ref",
  "refs/heads/deck",
  "--sort=-committerdate",
  "--format=%(refname:short)|%(objectname:short)|%(committerdate:iso8601)|%(subject)"
)

foreach ($line in $branchLines) {
  if ($line -match "desktop\.ini") { continue }

  $parts = $line -split "\|", 4
  $branch = $parts[0]
  $shortSha = $parts[1]
  $date = $parts[2]
  $subject = $parts[3]
  $isAncestor = Test-Ancestor $branch $BaseRef

  $mergeBase = ""
  $files = @()
  $diff = ""
  if (-not $isAncestor) {
    try {
      $mergeBase = (GitText @("merge-base", $BaseRef, $branch)).Trim()
      $files = GitLines @("diff", "--name-only", $mergeBase, $branch)
      $diff = GitText @("diff", "--unified=0", $mergeBase, $branch, "--", "GnR_deck.html")
    } catch {
      $mergeBase = "BROKEN"
      $files = @()
      $diff = ""
    }
  }

  $worktreePath = ""
  $worktreeStatus = "not_checked_out"
  if ($worktreeByBranch.ContainsKey($branch)) {
    $worktreePath = $worktreeByBranch[$branch]
    $statusLines = @(& git -C $worktreePath status --short)
    if ($LASTEXITCODE -ne 0) {
      $worktreeStatus = "status_failed"
    } elseif ($statusLines.Count -eq 0) {
      $worktreeStatus = "clean"
    } else {
      $worktreeStatus = "dirty"
    }
  }

  $riskFlags = @()
  if ($branch -match "(delete|trash|remove|revert)") { $riskFlags += "name_delete_trash_revert" }
  if ($diff -match "SLIDE_ORDER") { $riskFlags += "changes_SLIDE_ORDER" }
  if ($diff -match "SLIDE_ALTS") { $riskFlags += "changes_SLIDE_ALTS" }
  if ($diff -match "TRASH_ORDER") { $riskFlags += "changes_TRASH_ORDER" }
  if ($diff -match "data-deleted") { $riskFlags += "marks_deleted" }

  $commitBody = ""
  try {
    $commitBody = GitText @("log", "-1", "--format=%B", $branch)
  } catch {
    $commitBody = ""
  }

  $rows += [pscustomobject]@{
    Branch = $branch
    ContainedInBase = $isAncestor
    WorktreeStatus = $worktreeStatus
    WorktreePath = $worktreePath
    Head = $shortSha
    CommitDate = $date
    Subject = $subject
    MergeBase = $mergeBase
    FilesTouched = ($files -join ";")
    HasPublishTrace = ($commitBody -match "PUBLISH TRACE")
    ChangesSlideOrder = ($diff -match "SLIDE_ORDER")
    ChangesSlideAlts = ($diff -match "SLIDE_ALTS")
    ChangesTrashOrder = ($diff -match "TRASH_ORDER")
    RiskFlags = ($riskFlags -join ";")
  }
}

$unpublished = @($rows | Where-Object { -not $_.ContainedInBase })
"UNPUBLISHED_LOCAL_DECK_REFS=$($unpublished.Count)"
$rows | Sort-Object ContainedInBase, CommitDate -Descending | Format-Table Branch, ContainedInBase, WorktreeStatus, Head, Subject, RiskFlags -AutoSize

if ($CsvPath) {
  $rows | Export-Csv -NoTypeInformation -Path $CsvPath
  "CSV=$CsvPath"
}
