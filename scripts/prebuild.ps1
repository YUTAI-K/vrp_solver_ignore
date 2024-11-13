# Install CMake using chocolatey
# choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'

# prebuild.ps1
# Script to download and setup Boost libraries for wheel building

# Configuration
$boostVersion = "1.84.0"
$vsVersion = "14.3"  # VS2022
$boostVersionUnderscored = $boostVersion -replace '\.', '_'

# Determine architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "64" } else { "32" }

# Create temporary directory for downloads
$tempDir = Join-Path $env:TEMP "boost_setup"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Define Boost download URL from GitHub release mirrors
# Using boost-binaries GitHub mirror which allows direct downloads
$boostUrl = "https://boostorg.jfrog.io/artifactory/main/release/$boostVersion/binaries/boost_$($boostVersionUnderscored)-msvc-14.3-$arch.exe"
$installerPath = Join-Path $tempDir "boost_installer.exe"

Write-Host "Downloading Boost $boostVersion from $boostUrl"
try {
    # Use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    
    # Download using Invoke-WebRequest with progress
    Write-Host "Starting download..."
    Invoke-WebRequest -Uri $boostUrl -OutFile $installerPath -UseBasicParsing
    
    if (!(Test-Path $installerPath)) {
        throw "Download completed but file not found at $installerPath"
    }
    
    Write-Host "Download completed successfully"
} catch {
    Write-Host "Error downloading Boost: $_"
    Write-Host "Attempting alternative download method..."
    
    try {
        # Alternative download using System.Net.WebClient
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "PowerShell Script")
        $webClient.DownloadFile($boostUrl, $installerPath)
    } catch {
        Write-Host "Both download methods failed. Error: $_"
        exit 1
    }
}

# Create installation directory
$boostInstallDir = "C:\local\boost_$boostVersionUnderscored"
New-Item -ItemType Directory -Force -Path $boostInstallDir | Out-Null

Write-Host "Extracting Boost libraries to $boostInstallDir..."
if (Test-Path $installerPath) {
    try {
        # Run the self-extracting exe
        $process = Start-Process -FilePath $installerPath -ArgumentList "/DIR=`"$boostInstallDir`"", "/SILENT", "/SP-" -Wait -PassThru -NoNewWindow
        if ($process.ExitCode -ne 0) {
            throw "Installer exited with code $($process.ExitCode)"
        }
    } catch {
        Write-Host "Error during extraction: $_"
        exit 1
    }
} else {
    Write-Host "Error: Installer not found at $installerPath"
    exit 1
}

# Set environment variables
$env:BOOST_ROOT = $boostInstallDir
$env:BOOST_LIBRARYDIR = Join-Path $boostInstallDir "lib$arch-msvc-$vsVersion"
$env:BOOST_INCLUDEDIR = Join-Path $boostInstallDir "include/boost-$($boostVersion.Substring(0, 4))"

# Add to system path temporarily for this session
$env:Path = "$env:BOOST_LIBRARYDIR;$env:Path"

# Export variables so CMake can find them
[Environment]::SetEnvironmentVariable('BOOST_ROOT', $env:BOOST_ROOT, 'Machine')
[Environment]::SetEnvironmentVariable('BOOST_LIBRARYDIR', $env:BOOST_LIBRARYDIR, 'Machine')
[Environment]::SetEnvironmentVariable('BOOST_INCLUDEDIR', $env:BOOST_INCLUDEDIR, 'Machine')

# Verify installation
Write-Host "Verifying Boost installation..."
$pythonLib = Get-ChildItem -Path $env:BOOST_LIBRARYDIR -Filter "libboost_python*.lib" -ErrorAction SilentlyContinue
$graphLib = Get-ChildItem -Path $env:BOOST_LIBRARYDIR -Filter "libboost_graph*.lib" -ErrorAction SilentlyContinue

if ($pythonLib) {
    Write-Host "Found Boost.Python libraries: $($pythonLib.Name)"
} else {
    Write-Host "Warning: Boost.Python libraries not found in $env:BOOST_LIBRARYDIR"
    Get-ChildItem -Path $env:BOOST_LIBRARYDIR -Filter "*.lib" | ForEach-Object { Write-Host "Found library: $($_.Name)" }
}

if ($graphLib) {
    Write-Host "Found Boost.Graph libraries: $($graphLib.Name)"
} else {
    Write-Host "Warning: Boost.Graph libraries not found in $env:BOOST_LIBRARYDIR"
}

# Clean up
if (Test-Path $installerPath) {
    Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
}

Write-Host "Boost setup completed!"

# Output the environment variables for debugging
Write-Host "Environment Variables set:"
Write-Host "BOOST_ROOT: $env:BOOST_ROOT"
Write-Host "BOOST_LIBRARYDIR: $env:BOOST_LIBRARYDIR"
Write-Host "BOOST_INCLUDEDIR: $env:BOOST_INCLUDEDIR"

# List all files in the library directory for debugging
Write-Host "`nAvailable libraries in $env:BOOST_LIBRARYDIR:"
Get-ChildItem -Path $env:BOOST_LIBRARYDIR -Filter "*.lib" | Select-Object -ExpandProperty Name

cd D:\a\vrp_solver_ignore\vrp_solver_ignore
# Build your C++ project
Write-Host "Building C++ project..."
.\scripts\build.bat