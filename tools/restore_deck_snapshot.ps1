param(
  [Parameter(Mandatory=$true)]
  [string]$Snapshot
)

$ErrorActionPreference = "Stop"

$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$snapshotPath = (Resolve-Path $Snapshot).Path
$allowedRoot = (Resolve-Path (Join-Path $root "deck_archive\snapshots")).Path

if (!$snapshotPath.StartsWith($allowedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Snapshot must be inside deck_archive\snapshots"
}

$deckSnapshot = Join-Path $snapshotPath "GnR_deck.html"
$indexSnapshot = Join-Path $snapshotPath "index.html"
if (!(Test-Path -LiteralPath $deckSnapshot)) { throw "Snapshot missing GnR_deck.html" }
if (!(Test-Path -LiteralPath $indexSnapshot)) { throw "Snapshot missing index.html" }

Copy-Item -LiteralPath $deckSnapshot -Destination (Join-Path $root "GnR_deck.html") -Force
Copy-Item -LiteralPath $indexSnapshot -Destination (Join-Path $root "index.html") -Force

Write-Output "RESTORED: $snapshotPath"
Write-Output "NEXT: open Chrome, inspect, then commit/push if this restore is accepted."
