param(
  [string]$Branch = "",
  [string]$BaseRef = "origin/main"
)

$ErrorActionPreference = "Continue"
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

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

if (-not $Branch) {
  try {
    $Branch = (GitText @("branch", "--show-current")).Trim()
  } catch {
    $errors.Add("could not determine current branch")
  }
}

if ($Branch -and $Branch -notlike "deck/*") {
  $errors.Add("branch must be deck/*, got '$Branch'")
}

try {
  & git rev-parse --verify $Branch *> $null
  if ($LASTEXITCODE -ne 0) {
    $errors.Add("branch '$Branch' does not exist")
  }
} catch {
  $errors.Add("branch '$Branch' does not exist")
}

$head = ""
$subject = ""
$body = ""
if ($errors.Count -eq 0) {
  try {
    $head = (GitText @("rev-parse", "--short", $Branch)).Trim()
    $subject = (GitText @("log", "-1", "--format=%s", $Branch)).Trim()
    $body = GitText @("log", "-1", "--format=%B", $Branch)
  } catch {
    $errors.Add("could not read latest commit for '$Branch'")
  }
}

if ($body) {
  if ($body -notmatch "PUBLISH-READY:\s*yes") {
    $errors.Add("latest commit body is missing PUBLISH-READY: yes")
  }
  if ($body -notmatch "PUBLISH TRACE") {
    $errors.Add("latest commit body is missing PUBLISH TRACE")
  }
  if ($body -notmatch "publish bucket hint:\s*(publish_now|port_if_stale|needs_explicit_review)") {
    $errors.Add("PUBLISH TRACE is missing publish bucket hint")
  }
  if ($body -notmatch "safe-to-port-if-stale:\s*(yes|no)") {
    $errors.Add("PUBLISH TRACE is missing safe-to-port-if-stale: yes/no")
  }
  if ($body -notmatch "(active slide ID|registry slot|active source|SLIDE_ALTS|STAFF_ORDER)") {
    $errors.Add("PUBLISH TRACE is missing active slide or registry target")
  }
  if ($body -notmatch "source verification") {
    $errors.Add("PUBLISH TRACE is missing source verification result")
  }
  if ($body -notmatch "visual QA") {
    $errors.Add("PUBLISH TRACE is missing visual QA result or explicit not-required note")
  }
}

$files = @()
if ($errors.Count -eq 0) {
  try {
    $mergeBase = (GitText @("merge-base", $BaseRef, $Branch)).Trim()
    $files = GitLines @("diff", "--name-only", $mergeBase, $Branch)
  } catch {
    $warnings.Add("could not compare '$Branch' to '$BaseRef'")
  }
}

if ($files -contains "index.html") {
  $errors.Add("parallel worktree branch touched index.html; only publish control should mirror index.html")
}
if ($files -contains "pitch_visuals/GnR_deck.html") {
  $errors.Add("parallel worktree branch touched old pitch_visuals copy")
}

$currentBranch = ""
try {
  $currentBranch = (GitText @("branch", "--show-current")).Trim()
} catch {}

if ($currentBranch -eq $Branch) {
  $status = @(& git status --short)
  if ($LASTEXITCODE -ne 0) {
    $errors.Add("could not read worktree status")
  } elseif ($status.Count -gt 0) {
    $errors.Add("working tree is not clean")
  }
} else {
  $checkedPath = ""
  $currentPath = ""
  try {
    foreach ($line in (GitLines @("worktree", "list", "--porcelain"))) {
      if ($line -like "worktree *") {
        $currentPath = $line.Substring("worktree ".Length)
      } elseif ($line -eq "branch refs/heads/$Branch") {
        $checkedPath = $currentPath
      }
    }
    if ($checkedPath) {
      $status = @(& git -C $checkedPath status --short)
      if ($LASTEXITCODE -ne 0) {
        $errors.Add("could not read checked-out worktree status for '$Branch'")
      } elseif ($status.Count -gt 0) {
        $errors.Add("checked-out worktree for '$Branch' is not clean")
      }
    } else {
      $warnings.Add("branch '$Branch' is not checked out; cleanliness could not be verified")
    }
  } catch {
    $warnings.Add("could not inspect worktree checkout for '$Branch'")
  }
}

if ($errors.Count -eq 0) {
  "HANDOFF_VALID=yes"
} else {
  "HANDOFF_VALID=no"
}
"BRANCH=$Branch"
"HEAD=$head"
"SUBJECT=$subject"
if ($files.Count -gt 0) {
  "FILES_TOUCHED=$($files -join ';')"
}
foreach ($warning in $warnings) {
  "WARNING=$warning"
}
foreach ($err in $errors) {
  "ERROR=$err"
}

if ($errors.Count -gt 0) {
  exit 1
}
