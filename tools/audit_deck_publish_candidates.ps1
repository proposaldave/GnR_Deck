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

function Get-Mergeability {
  param(
    [string]$Base,
    [string]$Branch,
    [string]$MergeBase
  )

  if (-not $MergeBase -or $MergeBase -eq "BROKEN") {
    return "broken"
  }

  & git merge-tree --write-tree --merge-base $MergeBase $Base $Branch *> $null
  if ($LASTEXITCODE -eq 0) {
    return "clean"
  }
  return "conflict"
}

function Get-PublishBucket {
  param(
    [bool]$ContainedInBase,
    [string]$WorktreeStatus,
    [string]$Mergeability,
    [string[]]$RiskFlags,
    [bool]$HasPublishTrace,
    [string]$PublishHint,
    [bool]$SafeToPortIfStale
  )

  if ($ContainedInBase) {
    return "already_integrated"
  }
  if ($WorktreeStatus -eq "dirty") {
    return "dirty_worktree_blocked"
  }

  $hasRisk = @($RiskFlags).Count -gt 0
  $traceSaysExecutable = $HasPublishTrace -and $SafeToPortIfStale -and ($PublishHint -in @("publish_now", "port_if_stale"))
  if ($traceSaysExecutable -and $Mergeability -eq "clean" -and $PublishHint -eq "publish_now") {
    return "publish_now"
  }
  if ($traceSaysExecutable -and $Mergeability -in @("clean", "conflict")) {
    return "port_or_conflict_review"
  }

  if ($Mergeability -eq "clean" -and -not $hasRisk) {
    return "publish_now"
  }
  if ($Mergeability -eq "clean" -and $hasRisk) {
    return "risky_clean_needs_review"
  }
  if ($Mergeability -eq "conflict" -and -not $hasRisk) {
    return "port_or_conflict_review"
  }
  if ($Mergeability -eq "conflict" -and $hasRisk) {
    return "risky_conflict_blocked"
  }
  return "broken_ref_or_merge_base"
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

  $commitBody = ""
  try {
    $commitBody = GitText @("log", "-1", "--format=%B", $branch)
  } catch {
    $commitBody = ""
  }
  $hasPublishTrace = ($commitBody -match "PUBLISH TRACE")
  $hasPublishReady = ($commitBody -match "PUBLISH-READY:\s*yes")
  $safeToPortIfStale = ($commitBody -match "safe-to-port-if-stale:\s*yes")
  $publishHint = ""
  if ($commitBody -match "publish bucket hint:\s*([A-Za-z0-9_\-]+)") {
    $publishHint = $Matches[1]
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
  if ($hasPublishTrace -and $safeToPortIfStale) { $riskFlags += "trace_safe_to_port" }
  if ($hasPublishReady) { $riskFlags += "publish_ready_commit" }

  $mergeability = "contained"
  if (-not $isAncestor) {
    $mergeability = Get-Mergeability -Base $BaseRef -Branch $branch -MergeBase $mergeBase
  }
  $publishBucket = Get-PublishBucket `
    -ContainedInBase $isAncestor `
    -WorktreeStatus $worktreeStatus `
    -Mergeability $mergeability `
    -RiskFlags $riskFlags `
    -HasPublishTrace $hasPublishTrace `
    -PublishHint $publishHint `
    -SafeToPortIfStale $safeToPortIfStale

  $rows += [pscustomobject]@{
    Branch = $branch
    ContainedInBase = $isAncestor
    WorktreeStatus = $worktreeStatus
    WorktreePath = $worktreePath
    Head = $shortSha
    CommitDate = $date
    Subject = $subject
    MergeBase = $mergeBase
    Mergeability = $mergeability
    PublishBucket = $publishBucket
    FilesTouched = ($files -join ";")
    HasPublishTrace = $hasPublishTrace
    HasPublishReady = $hasPublishReady
    PublishHint = $publishHint
    SafeToPortIfStale = $safeToPortIfStale
    ChangesSlideOrder = ($diff -match "SLIDE_ORDER")
    ChangesSlideAlts = ($diff -match "SLIDE_ALTS")
    ChangesTrashOrder = ($diff -match "TRASH_ORDER")
    RiskFlags = ($riskFlags -join ";")
  }
}

$unpublished = @($rows | Where-Object { -not $_.ContainedInBase })
$publishNow = @($unpublished | Where-Object { $_.PublishBucket -eq "publish_now" })
$portOrReview = @($unpublished | Where-Object { $_.PublishBucket -eq "port_or_conflict_review" })
$riskyBlocked = @($unpublished | Where-Object { $_.PublishBucket -in @("risky_clean_needs_review", "risky_conflict_blocked") })
$dirtyBlocked = @($unpublished | Where-Object { $_.PublishBucket -eq "dirty_worktree_blocked" })
$broken = @($unpublished | Where-Object { $_.PublishBucket -eq "broken_ref_or_merge_base" })
"UNPUBLISHED_LOCAL_DECK_REFS=$($unpublished.Count)"
"PUBLISH_NOW_CANDIDATES=$($publishNow.Count)"
"PORT_OR_CONFLICT_REVIEW=$($portOrReview.Count)"
"RISKY_OR_DELETE_BLOCKED=$($riskyBlocked.Count)"
"DIRTY_WORKTREE_BLOCKED=$($dirtyBlocked.Count)"
"BROKEN_REF_OR_MERGE_BASE=$($broken.Count)"
$rows | Sort-Object ContainedInBase, CommitDate -Descending | Format-Table Branch, ContainedInBase, WorktreeStatus, Mergeability, PublishBucket, Head, Subject, RiskFlags -AutoSize

if ($CsvPath) {
  $rows | Export-Csv -NoTypeInformation -Path $CsvPath
  "CSV=$CsvPath"
}
