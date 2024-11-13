# Install CMake using chocolatey
# choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'
# prebuild.ps1

#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Pre-build script for cibuildwheel to compile C++ code and set up Boost dependencies.

.DESCRIPTION
    This script performs the following actions:
    1. Clones the vcpkg repository if it doesn't exist.
    2. Bootstraps vcpkg.
    3. Installs boost-python3 and boost-graph with static linkage.
    4. Sets environment variables for CMake to locate Boost and its dependencies.

.NOTES
    Ensure that Git is installed and available in the system PATH.
    This script assumes a 64-bit Windows environment.
#>

# Exit immediately if a command exits with a non-zero status
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Define variables
$vcpkgRepoUrl = "https://github.com/microsoft/vcpkg.git"
$vcpkgDir = "$env:LOCALAPPDATA\vcpkg"
$triplet = "x64-windows-static"

# Function to display messages
function Write-Log {
    param (
        [string]$Message
    )
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]: $Message"
}

Write-Log "Starting pre-build steps..."

# Step 1: Clone vcpkg if it doesn't exist
if (-Not (Test-Path $vcpkgDir)) {
    Write-Log "Cloning vcpkg repository..."
    git clone $vcpkgRepoUrl $vcpkgDir
} else {
    Write-Log "vcpkg repository already exists at '$vcpkgDir'."
}

# Navigate to vcpkg directory
Set-Location $vcpkgDir

# Step 2: Bootstrap vcpkg
if (-Not (Test-Path "$vcpkgDir\vcpkg.exe")) {
    Write-Log "Bootstrapping vcpkg..."
    & .\bootstrap-vcpkg.bat
} else {
    Write-Log "vcpkg is already bootstrapped."
}

# Step 3: Install Boost libraries with static linkage
Write-Log "Installing Boost libraries: boost-python3 and boost-graph..."
& .\vcpkg.exe install boost-python3 boost-graph --triplet $triplet --recurse

# Verify installation
if (-Not (Test-Path "$vcpkgDir\installed\$triplet")) {
    throw "Boost libraries installation failed."
} else {
    Write-Log "Boost libraries installed successfully."
}

# Step 4: Set environment variables for CMake
Write-Log "Setting environment variables for CMake..."

$env:CMAKE_TOOLCHAIN_FILE = "$vcpkgDir\scripts\buildsystems\vcpkg.cmake"
$env:BOOST_ROOT = "$vcpkgDir\installed\$triplet"
$env:BOOST_INCLUDEDIR = "$vcpkgDir\installed\$triplet\include"
$env:BOOST_LIBRARYDIR = "$vcpkgDir\installed\$triplet\lib"

# Optionally, add Boost binaries to PATH if needed
$boostBinPath = "$vcpkgDir\installed\$triplet\bin"
if (-Not ($env:PATH -split ';' | Select-String -SimpleMatch $boostBinPath)) {
    $env:PATH = "$boostBinPath;$env:PATH"
    Write-Log "Added Boost binaries to PATH."
}

Write-Log "Environment variables set successfully."

# Final message
Write-Log "Pre-build steps completed successfully."

# Optionally, return to the original directory
# Set-Location $OriginalLocation


cd D:\a\vrp_solver_ignore\vrp_solver_ignore
# Build your C++ project
Write-Host "Building C++ project..."
.\scripts\build.bat