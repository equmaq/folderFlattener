param([string]$WorkingDir)

if (-not (Test-Path -Path $WorkingDir)) {
    Write-Host "Error: The specified working directory '$WorkingDir' does not exist."
    exit 1
}

Set-Location $WorkingDir

Write-Host "Moving files to current directory..."

# Set the path
$folderPath = $WorkingDir

# Get all files recursively (excluding the current directory's files)
$files = Get-ChildItem -Path . -Recurse -File | Where-Object { 
    $_.FullName -ne $folderPath -and (Split-Path -Path $_.DirectoryName -Parent) -ne $null
}

foreach ($file in $files) {
    if ($file.DirectoryName -eq $PWD.Path) {
        continue
    }

    if ($file.Extension -eq ".part") {
        try {
            $stream = [System.IO.File]::Open($file.FullName, 'Open', 'ReadWrite', 'None')
            $stream.Close()
            Remove-Item -LiteralPath $file.FullName -Force
            Write-Host "Deleted unused .part file: $($file.FullName)"
        } catch {
            Write-Host "Could not delete .part file (in use): $($file.FullName)"
        }
        Write-Host "Skipping file: $($file.FullName)"
        continue
    }

    $name = $file.BaseName
    $ext = $file.Extension

    $relativePath = $file.DirectoryName.Replace($PWD.Path, "").Trim("\")
    
    if ($relativePath) {
        $pathForFilename = $relativePath.Replace("\", "_")
        $newBaseName = "${pathForFilename}_${name}"
    } else {
        $newBaseName = $name
    }

    $filename = "${newBaseName}${ext}"
    $count = 1

    # Use -LiteralPath to avoid bracket interpretation
    while (Test-Path -LiteralPath (Join-Path -Path $PWD -ChildPath $filename)) {
        $filename = "${newBaseName}_${count}${ext}"
        $count++
    }

    # Define strings to remove from the filename
    $strings = @(
        "/example", "/other example", 
        "/the slashes are just there so that this won't do anything"
    )

    foreach ($string in $strings) {
        $filename = $filename.Replace("${string}", "")
    }

    $destination = Join-Path -Path $PWD -ChildPath $filename
    Write-Host "Moving: `"$($file.FullName)`" to `"$destination`""
     
    #use -LiteralPath for both source and destination
    Move-Item -LiteralPath $file.FullName -Destination $destination -Force
}

# Delete empty folders (excluding current directory)
Get-ChildItem -Path . -Directory -Recurse |
    Where-Object { $_.FullName -ne $PWD.Path } |
    Sort-Object -Property FullName -Descending |
    ForEach-Object {
        if ((Get-ChildItem -LiteralPath $_.FullName -Recurse -Force).Count -eq 0) {
            Remove-Item -LiteralPath $_.FullName -Force
        }
    }

Write-Host "`nAll files have been moved and renamed as needed."
Write-Host ""
$host.SetShouldExit(0)
