# Install CMake using chocolatey
# choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'


# Exit immediately if a command exits with a non-zero status.
$ErrorActionPreference = "Stop"

# Define variables
$boostVersion = "1.81.0"  # Specify the desired Boost version
$boostVersionUnderscore = $boostVersion.Replace('.', '_')
$boostZipName = "boost_$boostVersionUnderscore.zip"
$boostDownloadUrl = "https://sourceforge.net/projects/boost/files/boost-binaries/$boostVersion/$boostZipName/download"
$boostInstallDir = "$env:USERPROFILE\boost_$boostVersion"
$boostExtractDir = "$boostInstallDir"

# Function to download Boost
function Download-Boost {
    Write-Host "Downloading Boost $boostVersion from SourceForge..."
    Invoke-WebRequest -Uri $boostDownloadUrl -OutFile "$env:TEMP\$boostZipName"
}

# Function to extract Boost
function Extract-Boost {
    Write-Host "Extracting Boost..."
    Expand-Archive -Path "$env:TEMP\$boostZipName" -DestinationPath $boostInstallDir -Force
    # Remove the zip file after extraction
    Remove-Item "$env:TEMP\$boostZipName"
}

# Check if Boost is already downloaded and extracted
if (-Not (Test-Path $boostInstallDir)) {
    Download-Boost
    Extract-Boost
} else {
    Write-Host "Boost $boostVersion already downloaded and extracted."
}

# Set environment variables for Boost
Write-Host "Setting environment variables for Boost..."
$env:BOOST_ROOT = $boostExtractDir
$env:BOOST_INCLUDEDIR = "$boostExtractDir\include"
$env:BOOST_LIBRARYDIR = "$boostExtractDir\lib"

# Additional CMake settings for Boost
$env:Boost_USE_STATIC_LIBS = "ON"        # Use static libraries
$env:Boost_USE_MULTITHREADED = "ON"      # Enable multithreading
$env:Boost_USE_STATIC_RUNTIME = "ON"     # Use static runtime

# Optionally, specify the architecture (e.g., x64)
# $env:BOOST_ARCHITECTURE = "x64"

# Verify that boost-python and boost-graph libraries exist
Write-Host "Verifying presence of boost-python and boost-graph libraries..."

$boostLibDir = "$boostExtractDir\lib"

# Function to verify library existence
function Verify-Library ($pattern, $libName) {
    $libs = Get-ChildItem -Path $boostLibDir -Filter $pattern
    if ($libs.Count -eq 0) {
        Write-Error "Error: $libName library not found in $boostLibDir. Expected pattern: $pattern"
        exit 1
    } else {
        Write-Host "$libName library found: $($libs.Name)"
    }
}

# Verify boost-python
Verify-Library "libboost_python*.lib" "boost-python"

# Verify boost-graph
Verify-Library "libboost_graph*.lib" "boost-graph"

Write-Host "Boost environment variables set and verified successfully."


cd D:\a\vrp_solver_ignore\vrp_solver_ignore
# Build your C++ project
Write-Host "Building C++ project..."
.\scripts\build.bat