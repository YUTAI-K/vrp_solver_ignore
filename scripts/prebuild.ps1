# Install CMake using chocolatey
# choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'
# prebuild.ps1

# Specify the Boost version
$boostVersion = "1.83.0"
$boostVersionUnderscore = $boostVersion -replace '\.', '_'
$boostZip = "boost_$boostVersionUnderscore.zip"
$boostUrl = "https://boostorg.jfrog.io/artifactory/main/release/$boostVersion/source/$boostZip"

Write-Host "Downloading Boost $boostVersion from $boostUrl..."

# Download Boost
Invoke-WebRequest -Uri $boostUrl -OutFile $boostZip

Write-Host "Extracting Boost..."
# Extract Boost
Expand-Archive -Path $boostZip -DestinationPath .

$boostDir = "boost_$boostVersionUnderscore"

# Change directory to Boost
Set-Location .\$boostDir

Write-Host "Bootstrapping Boost.Build..."
# Bootstrap Boost.Build
.\bootstrap.bat

Write-Host "Retrieving Python information..."
# Get Python information
$pythonExe = & python -c "import sys; print(sys.executable)"
$pythonVersion = & python -c "import sys; print('{}.{}'.format(sys.version_info[0], sys.version_info[1]))"
$pythonRoot = Split-Path -Parent $pythonExe
$pythonArchitecture = & python -c "import sys; print('64' if sys.maxsize > 2**32 else '32')"
$addressModel = $pythonArchitecture

Write-Host "Building Boost libraries..."
# Build Boost libraries statically
.\b2 `
  address-model=$addressModel `
  link=static `
  runtime-link=static `
  threading=multi `
  variant=release `
  --with-python `
  --with-graph `
  python=$pythonVersion `
  python-root="$pythonRoot" `
  stage

Write-Host "Setting environment variables for CMake..."
# Set environment variables for CMake
$boostRoot = (Get-Location).Path
$env:BOOST_ROOT = $boostRoot
$env:BOOST_LIBRARYDIR = (Join-Path $boostRoot "stage\lib")
$env:BOOST_INCLUDEDIR = (Join-Path $boostRoot "")

Write-Host "Boost build complete. BOOST_ROOT set to $env:BOOST_ROOT"

}

cd D:\a\vrp_solver_ignore\vrp_solver_ignore
# Build your C++ project
Write-Host "Building C++ project..."
.\scripts\build.bat