# prebuild.ps1

# Exit immediately if a command exits with a non-zero status
$ErrorActionPreference = "Stop"

# === Configuration ===

# Define directories and versions
$toolsDir = "$env:USERPROFILE\tools"
$cmakeVersion = "3.26.4" # Specify the desired CMake version
$cmakeZip = "cmake-$cmakeVersion-windows-x86_64.zip"
$cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v$cmakeVersion/$cmakeZip"
$cmakeExtractDir = "$toolsDir\cmake-$cmakeVersion"

$boostVersion = "1.83.0" # Specify the desired Boost version
$boostZip = "boost_$($boostVersion -replace '\.', '_').zip"
$boostUrl = "https://boostorg.jfrog.io/artifactory/main/release/$boostVersion/source/$boostZip"
$boostSourceDir = "$toolsDir\boost_$boostVersion"

# === Helper Function ===

# Function to download a file from a URL to a destination path
function Download-File($url, $destination) {
    Write-Host "Downloading $url..."
    Invoke-WebRequest -Uri $url -OutFile $destination
}

# === Ensure Tools Directory Exists ===

if (-not (Test-Path $toolsDir)) {
    Write-Host "Creating tools directory at $toolsDir..."
    New-Item -ItemType Directory -Path $toolsDir | Out-Null
} else {
    Write-Host "Tools directory already exists: $toolsDir"
}

# === Install CMake ===

if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
    Write-Host "CMake not found. Downloading and installing CMake $cmakeVersion..."

    $cmakeZipPath = "$toolsDir\$cmakeZip"
    Download-File -url $cmakeUrl -destination $cmakeZipPath

    Write-Host "Extracting CMake..."
    Expand-Archive -Path $cmakeZipPath -DestinationPath $toolsDir -Force

    # Define the CMake bin directory
    $cmakeBin = "$cmakeExtractDir\bin"

    # Add CMake to PATH if not already present
    if ($env:PATH -notlike "*$cmakeBin*") {
        Write-Host "Adding CMake to PATH: $cmakeBin"
        $env:PATH = "$cmakeBin;$env:PATH"
    } else {
        Write-Host "CMake bin directory already in PATH."
    }

    # Clean up the downloaded zip file
    Remove-Item $cmakeZipPath -Force
} else {
    Write-Host "CMake is already installed: $(cmake --version)"
}

# === Download Boost ===

if (-not (Test-Path $boostSourceDir)) {
    Write-Host "Downloading Boost $boostVersion..."

    $boostZipPath = "$toolsDir\$boostZip"
    Download-File -url $boostUrl -destination $boostZipPath

    Write-Host "Extracting Boost..."
    Expand-Archive -Path $boostZipPath -DestinationPath $toolsDir -Force

    # Clean up the downloaded zip file
    Remove-Item $boostZipPath -Force
} else {
    Write-Host "Boost source already exists: $boostSourceDir"
}

# === Detect Python Installation ===

Write-Host "Detecting Python installation..."

$pythonExe = (Get-Command python -ErrorAction SilentlyContinue)?.Source
if (-not $pythonExe) {
    throw "Python executable not found in PATH. Please ensure Python is installed and added to PATH."
}

Write-Host "Python executable found at: $pythonExe"

# Retrieve Python version (e.g., 3.11)
$pythonVersion = (& $pythonExe -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
Write-Host "Detected Python version: $pythonVersion"

# Retrieve Python include and library directories
$pythonInclude = (& $pythonExe -c "from sysconfig import get_paths as gp; print(gp()['include'])")
$pythonLib = (& $pythonExe -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")

Write-Host "Python include directory: $pythonInclude"
Write-Host "Python library directory: $pythonLib"

# === Build Boost ===

$boostLibDir = "$boostSourceDir\stage\lib"

if (-not (Test-Path $boostLibDir)) {
    Write-Host "Bootstrapping Boost with specified libraries (python, graph)..."

    Push-Location $boostSourceDir

    # Run bootstrap.bat to prepare Boost.Build (b2)
    & .\bootstrap.bat --with-libraries=python,graph --prefix="$boostSourceDir"

    Write-Host "Building Boost libraries statically..."
    
    # Build Boost using b2 with static linkage and specified parameters
    & .\b2.exe `
        variant=release `
        link=static `
        runtime-link=static `
        threading=multi `
        address-model=64 `
        toolset=msvc `
        python="$pythonExe" `
        python-version="$pythonVersion" `
        python-root="$(Split-Path $pythonExe)" `
        include="$pythonInclude" `
        library-path="$pythonLib" `
        --with-python `
        --with-graph `
        stage `
        install

    Pop-Location
} else {
    Write-Host "Boost libraries already built at: $boostLibDir"
}

# === Set Environment Variables ===

Write-Host "Setting environment variables for Boost..."

$env:BOOST_ROOT = $boostSourceDir
$env:BOOST_INCLUDEDIR = "$boostSourceDir"
$env:BOOST_LIBRARYDIR = "$boostLibDir"

# Update CMAKE_PREFIX_PATH to help CMake find Boost
if ($env:CMAKE_PREFIX_PATH) {
    $env:CMAKE_PREFIX_PATH = "$boostSourceDir;$env:CMAKE_PREFIX_PATH"
} else {
    $env:CMAKE_PREFIX_PATH = "$boostSourceDir"
}

Write-Host "Environment variables set:"
Write-Host "BOOST_ROOT = $env:BOOST_ROOT"
Write-Host "BOOST_INCLUDEDIR = $env:BOOST_INCLUDEDIR"
Write-Host "BOOST_LIBRARYDIR = $env:BOOST_LIBRARYDIR"
Write-Host "CMAKE_PREFIX_PATH = $env:CMAKE_PREFIX_PATH"

# === Completion Message ===

Write-Host "Pre-build setup completed successfully."


cd D:\a\vrp_solver_ignore\vrp_solver_ignore
# Build your C++ project
Write-Host "Building C++ project..."
.\scripts\build.bat