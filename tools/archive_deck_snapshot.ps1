param(
  [string]$Reason = "manual snapshot",
  [string]$Slug = ""
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

if ([string]::IsNullOrWhiteSpace($Slug)) {
  $Slug = $Reason.ToLowerInvariant() -replace '[^a-z0-9]+','-' -replace '(^-|-$)',''
}
if ([string]::IsNullOrWhiteSpace($Slug)) { $Slug = "snapshot" }
if ($Slug.Length -gt 64) { $Slug = $Slug.Substring(0,64).TrimEnd("-") }

$snapshotRoot = Join-Path $root "deck_archive\snapshots"
$snapshotDir = Join-Path $snapshotRoot "$timestamp-$Slug"
New-Item -ItemType Directory -Force $snapshotDir | Out-Null

$deck = Join-Path $root "GnR_deck.html"
$index = Join-Path $root "index.html"
if (!(Test-Path -LiteralPath $deck)) { throw "Missing GnR_deck.html" }
if (!(Test-Path -LiteralPath $index)) { throw "Missing index.html" }

Copy-Item -LiteralPath $deck -Destination (Join-Path $snapshotDir "GnR_deck.html")
Copy-Item -LiteralPath $index -Destination (Join-Path $snapshotDir "index.html")

$branch = git -C $root rev-parse --abbrev-ref HEAD
$commit = git -C $root rev-parse --short HEAD
$status = git -C $root status --short

$metadata = [ordered]@{
  timestamp = (Get-Date).ToString("o")
  reason = $Reason
  branch = $branch
  commit = $commit
  files = @("GnR_deck.html", "index.html")
  gitStatus = @($status)
}

$metadata | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $snapshotDir "metadata.json") -Encoding UTF8

Write-Output "ARCHIVED: $snapshotDir"
