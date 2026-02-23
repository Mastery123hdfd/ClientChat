# Auto Git Commit Watcher (Debounced + Fully Safe)
$repo = "C:\Users\mhwen\OneDrive\Documents\GitHub\ClientChat"
$pending = $false
$lastChange = Get-Date

Write-Host "Watching $repo for changes..."

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $repo
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.Filter = "*.*"

$action = {
    # Explicitly capture event args so PowerShell never tries to run them
    $path = $Event.SourceEventArgs.FullPath

    # Ignore OneDrive temp files
    if ($path -match "~\$") { return }

    # Mark pending commit
    $global:pending = $true
    $global:lastChange = Get-Date
}

Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action
Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action
Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action $action
Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action

while ($true) {
    Start-Sleep -Seconds 1

    if ($pending -and ((Get-Date) - $lastChange).TotalSeconds -ge 5) {
        Write-Host "Committing changes..."
        git -C $repo add .
        git -C $repo commit -m "Auto-commit from OneDrive" --allow-empty-message --no-edit
        $pending = $false
    }
}