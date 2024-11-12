# Install CMake using chocolatey
choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'

# Define variables
$BOOST_VERSION = "1.84.0"
$BOOST_VERSION_UNDERSCORED = $BOOST_VERSION.Replace(".", "_")
$BOOST_DOWNLOAD_URL = "https://boostorg.jfrog.io/artifactory/main/release/$BOOST_VERSION/source/boost_$BOOST_VERSION_UNDERSCORED.zip"
$BOOST_INSTALL_DIR = "D:\a\vrp_solver_ignore\vrp_solver_ignore\boost_install"
$DOWNLOAD_DIR = "D:\a\vrp_solver_ignore\vrp_solver_ignore\downloads"
$BUILD_TYPE = "Release"

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path $DOWNLOAD_DIR
New-Item -ItemType Directory -Force -Path $BOOST_INSTALL_DIR

# Set architecture
if ([Environment]::Is64BitOperatingSystem) {
    $ARCH = "64"
    Write-Host "Detected 64-bit OS. Using architecture: $ARCH"
} else {
    $ARCH = "32"
    Write-Host "Detected 32-bit OS. Using architecture: $ARCH"
}

# Download Boost
Write-Host "Downloading Boost $BOOST_VERSION..."
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $BOOST_DOWNLOAD_URL -OutFile "$DOWNLOAD_DIR\boost.zip"

# Extract Boost
Write-Host "Extracting Boost..."
Expand-Archive -Path "$DOWNLOAD_DIR\boost.zip" -DestinationPath $DOWNLOAD_DIR -Force
$BOOST_SRC_DIR = "$DOWNLOAD_DIR\boost_$BOOST_VERSION_UNDERSCORED"

# Build Boost
Write-Host "Building Boost..."
Set-Location $BOOST_SRC_DIR

# Bootstrap
Write-Host "Running bootstrap..."
.\bootstrap.bat

# Build specific components with static linking
Write-Host "Building Boost components..."
$B2_ARGS = @(
    "toolset=msvc-14.3"
    "address-model=$ARCH"
    "variant=release"
    "link=static"
    "runtime-link=static"
    "threading=multi"
    "--with-python"
    "--with-graph"
    "--prefix=$BOOST_INSTALL_DIR"
    "install"
)
.\b2.exe $B2_ARGS

# Add environment variables
Write-Host "Setting up environment variables..."
$env:BOOST_ROOT = $BOOST_INSTALL_DIR
$env:BOOST_LIBRARYDIR = "$BOOST_INSTALL_DIR\lib"
$env:BOOST_INCLUDEDIR = "$BOOST_INSTALL_DIR\include\boost-$BOOST_VERSION_MAJOR_$BOOST_VERSION_MINOR"

# Add to system PATH if not already present
$systemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if (-not $systemPath.Contains($BOOST_INSTALL_DIR)) {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$systemPath;$BOOST_INSTALL_DIR\lib",
        "Machine"
    )
}

cd D:\a\vrp_solver_ignore\vrp_solver_ignore
# Build your C++ project
Write-Host "Building C++ project..."
.\scripts\build.bat