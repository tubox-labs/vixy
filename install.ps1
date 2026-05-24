param(
    [Parameter(Position = 0)]
    [string]$Command = "install"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Binary = if ($env:VIXY_BINARY) { $env:VIXY_BINARY } else { "vixy.exe" }
$InstallDir = if ($env:VIXY_INSTALL_DIR) {
    $env:VIXY_INSTALL_DIR
} elseif ($env:LOCALAPPDATA) {
    Join-Path $env:LOCALAPPDATA "Programs\Vixy\bin"
} else {
    Join-Path $HOME ".local\bin"
}
$ReleaseApiBaseUrl = if ($env:VIXY_RELEASE_API_BASE_URL) {
    $env:VIXY_RELEASE_API_BASE_URL
} else {
    "https://veyra.tubox.cloud/vixy"
}
$DownloadBaseUrl = if ($env:VIXY_DOWNLOAD_BASE_URL) {
    $env:VIXY_DOWNLOAD_BASE_URL
} else {
    "https://github.com/tubox-labs/vixy/releases/download"
}
$RequestedVersion = if ($env:VIXY_VERSION) { $env:VIXY_VERSION } else { "" }

function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Yellow
}

function Fail {
    param([string]$Message)
    throw $Message
}

function Show-Usage {
    @"
Usage: .\install.ps1 [install|upgrade|uninstall]

Environment:
  VIXY_VERSION              Version to install. Defaults to latest allowed release.
  VIXY_RELEASE_API_BASE_URL Version metadata host. Defaults to $ReleaseApiBaseUrl
  VIXY_DOWNLOAD_BASE_URL    Release download host. Defaults to $DownloadBaseUrl
  VIXY_INSTALL_DIR          Install directory. Defaults to $InstallDir

Release layout:
  $ReleaseApiBaseUrl/releases/latest/VERSION
  $DownloadBaseUrl/v0.1.0-beta.2/vixy_windows_<arch>.zip
  $DownloadBaseUrl/v0.1.0-beta.2/checksums.txt
"@
}

function Normalize-Version {
    param([string]$Value)

    $normalized = $Value.Trim()
    if ($normalized.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
        $normalized = $normalized.Substring(1)
    }
    if ($normalized -notmatch "^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z][0-9A-Za-z.-]*)?$") {
        Fail "Invalid Vixy version: $Value"
    }
    $normalized
}

function Get-PlatformArch {
    $rawArch = if ($env:PROCESSOR_ARCHITEW6432) {
        $env:PROCESSOR_ARCHITEW6432
    } else {
        $env:PROCESSOR_ARCHITECTURE
    }

    switch ($rawArch.ToLowerInvariant()) {
        { $_ -in @("amd64", "x86_64") } { "amd64"; return }
        { $_ -in @("arm64", "aarch64") } { "arm64"; return }
        default { Fail "Unsupported architecture: $rawArch" }
    }
}

function Invoke-WebRequestCompat {
    param(
        [string]$Uri,
        [string]$OutFile = ""
    )

    $params = @{
        Uri = $Uri
        ErrorAction = "Stop"
    }
    if ($OutFile) {
        $params.OutFile = $OutFile
    }
    if ((Get-Command Invoke-WebRequest).Parameters.ContainsKey("UseBasicParsing")) {
        $params.UseBasicParsing = $true
    }

    Invoke-WebRequest @params
}

function Fetch-LatestVersion {
    $latestUrl = "$($ReleaseApiBaseUrl.TrimEnd([char]'/'))/releases/latest/VERSION"
    $response = Invoke-WebRequestCompat -Uri $latestUrl
    $response.Content.Trim()
}

function Download-Asset {
    param(
        [string]$Version,
        [string]$Asset,
        [string]$Destination
    )

    $url = "$($DownloadBaseUrl.TrimEnd([char]'/'))/v$Version/$Asset"
    try {
        Invoke-WebRequestCompat -Uri $url -OutFile $Destination | Out-Null
    } catch {
        Fail "Download failed: $url"
    }
}

function Verify-ChecksumIfAvailable {
    param(
        [string]$Version,
        [string]$Asset,
        [string]$Archive,
        [string]$Checksums
    )

    $checksumUrl = "$($DownloadBaseUrl.TrimEnd([char]'/'))/v$Version/checksums.txt"
    try {
        Invoke-WebRequestCompat -Uri $checksumUrl -OutFile $Checksums | Out-Null
    } catch {
        Write-Warn "No checksums.txt found; skipping checksum verification"
        return
    }

    $expected = $null
    foreach ($line in Get-Content -LiteralPath $Checksums) {
        $parts = $line -split "\s+", 2
        $checksumAssetName = if ($parts.Count -eq 2) { $parts[1].Trim().TrimStart("*") } else { "" }
        if ($parts.Count -eq 2 -and $checksumAssetName -eq $Asset) {
            $expected = $parts[0].Trim()
            break
        }
    }
    if ([string]::IsNullOrWhiteSpace($expected)) {
        Fail "checksums.txt does not contain $Asset"
    }

    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $Archive).Hash.ToLowerInvariant()
    if ($actual -ne $expected.ToLowerInvariant()) {
        Fail "Checksum mismatch for $Asset"
    }
}

function Get-InstalledVersion {
    $command = Get-Command $Binary -ErrorAction SilentlyContinue
    if ($null -eq $command -and $Binary.EndsWith(".exe", [System.StringComparison]::OrdinalIgnoreCase)) {
        $command = Get-Command $Binary.Substring(0, $Binary.Length - 4) -ErrorAction SilentlyContinue
    }
    if ($null -eq $command) {
        return $null
    }

    try {
        $line = & $command.Source version 2>$null | Select-Object -First 1
        if ($line -match "v?([0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z][0-9A-Za-z.-]*)?)") {
            return Normalize-Version $Matches[1]
        }
    } catch {
        return ""
    }

    ""
}

function ConvertTo-ComparablePathEntry {
    param([string]$PathEntry)

    if ([string]::IsNullOrWhiteSpace($PathEntry)) {
        return ""
    }

    [Environment]::ExpandEnvironmentVariables($PathEntry).Trim().Trim('"').TrimEnd([char]'\')
}

function Test-PathListContains {
    param(
        [string]$PathList,
        [string]$PathEntry
    )

    $normalizedPathEntry = ConvertTo-ComparablePathEntry $PathEntry
    if ([string]::IsNullOrWhiteSpace($normalizedPathEntry)) {
        return $false
    }
    if ([string]::IsNullOrWhiteSpace($PathList)) {
        return $false
    }

    foreach ($entry in ($PathList -split [regex]::Escape([System.IO.Path]::PathSeparator))) {
        if ((ConvertTo-ComparablePathEntry $entry) -ieq $normalizedPathEntry) {
            return $true
        }
    }
    $false
}

function Add-InstallDirToPath {
    $separator = [System.IO.Path]::PathSeparator
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    if (-not (Test-PathListContains $userPath $InstallDir)) {
        $nextUserPath = if ([string]::IsNullOrWhiteSpace($userPath)) {
            $InstallDir
        } else {
            "$($userPath.TrimEnd($separator))$separator$InstallDir"
        }
        [Environment]::SetEnvironmentVariable("Path", $nextUserPath, "User")
        Write-Info "Added $InstallDir to your user Path"
    }

    if (-not (Test-PathListContains $env:Path $InstallDir)) {
        $env:Path = if ([string]::IsNullOrWhiteSpace($env:Path)) {
            $InstallDir
        } else {
            "$($env:Path.TrimEnd($separator))$separator$InstallDir"
        }
        Write-Info "Added $InstallDir to this PowerShell session Path"
    }
}

function Install-Vixy {
    if ($PSVersionTable.PSEdition -eq "Core" -and -not $IsWindows) {
        Fail "This installer is for Windows PowerShell. Use install.sh on macOS or Linux."
    }

    $arch = Get-PlatformArch
    if ([string]::IsNullOrWhiteSpace($RequestedVersion)) {
        Write-Info "Fetching latest Vixy version..."
        $resolvedVersion = Normalize-Version (Fetch-LatestVersion)
    } else {
        $resolvedVersion = Normalize-Version $RequestedVersion
    }
    if ([string]::IsNullOrWhiteSpace($resolvedVersion)) {
        Fail "Failed to resolve version"
    }

    $current = Get-InstalledVersion
    if ($null -ne $current) {
        if ($current -eq $resolvedVersion) {
            Write-Info "vixy v$resolvedVersion is already installed"
            return
        }
        Write-Info "Upgrading vixy from v$(if ($current) { $current } else { 'unknown' }) to v$resolvedVersion..."
    } else {
        Write-Info "Installing vixy v$resolvedVersion for windows/$arch..."
    }

    $asset = "vixy_windows_$arch.zip"
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "vixy-$([System.Guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    try {
        $archive = Join-Path $tempDir $asset
        Download-Asset $resolvedVersion $asset $archive
        Verify-ChecksumIfAvailable $resolvedVersion $asset $archive (Join-Path $tempDir "checksums.txt")

        Expand-Archive -LiteralPath $archive -DestinationPath $tempDir -Force
        $extractedBinary = Join-Path $tempDir $Binary
        if (-not (Test-Path -LiteralPath $extractedBinary -PathType Leaf)) {
            Fail "Archive did not contain $Binary"
        }

        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Move-Item -LiteralPath $extractedBinary -Destination (Join-Path $InstallDir $Binary) -Force

        Add-InstallDirToPath

        Write-Info "vixy v$resolvedVersion installed to $(Join-Path $InstallDir $Binary)"
    } finally {
        Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Uninstall-Vixy {
    Write-Info "Uninstalling vixy..."

    $binaryPath = Join-Path $InstallDir $Binary
    if (Test-Path -LiteralPath $binaryPath -PathType Leaf) {
        Remove-Item -LiteralPath $binaryPath -Force
        Write-Info "Removed $binaryPath"
    } else {
        Write-Warn "Binary not found at $binaryPath"
    }

    $configDir = Join-Path $HOME ".vixy"
    if (Test-Path -LiteralPath $configDir -PathType Container) {
        $response = Read-Host "Remove config directory $configDir? [y/N]"
        if ($response -match "^[Yy]$") {
            Remove-Item -LiteralPath $configDir -Recurse -Force
            Write-Info "Removed $configDir"
        }
    }

    Write-Info "Uninstall complete"
}

switch ($Command.ToLowerInvariant()) {
    "install" { Install-Vixy }
    "upgrade" { Install-Vixy }
    "uninstall" { Uninstall-Vixy }
    "remove" { Uninstall-Vixy }
    "help" { Show-Usage }
    "-h" { Show-Usage }
    "--help" { Show-Usage }
    default { Fail "Unknown command: $Command" }
}
