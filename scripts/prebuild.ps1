# Install CMake using chocolatey
# choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'


# Configuration
$boostVersion = "1.84.0"  # Update this to your needed version
$vsVersion = "14.3"  # VS2022
# Convert version number format (e.g., 1.84.0 to 1_84_0)
$boostVersionUnderscored = $boostVersion -replace '\.', '_'

# Determine architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "64" } else { "32" }

# Create temporary directory for downloads
$tempDir = Join-Path $env:TEMP "boost_setup"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Define Boost download URL (static libraries)
$boostUrl = "https://sourceforge.net/projects/boost/files/boost-binaries/$boostVersion/boost_$($boostVersionUnderscored)-msvc-14.3-$arch.exe"
Write-Host "$boostUrl"
$installerPath = Join-Path $tempDir "boost_installer.exe"

Write-Host "Downloading Boost $boostVersion..."
# Download using .NET WebClient (more reliable than Invoke-WebRequest for large files)
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($boostUrl, $installerPath)

# Create installation directory
$boostInstallDir = "C:\local\boost_$boostVersionUnderscored"
New-Item -ItemType Directory -Force -Path $boostInstallDir | Out-Null

Write-Host "Extracting Boost libraries..."
# The /SILENT parameter runs the self-extracting exe silently
Start-Process -FilePath $installerPath -ArgumentList "/DIR=`"$boostInstallDir`"", "/SILENT" -Wait

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
if (Test-Path (Join-Path $env:BOOST_LIBRARYDIR "libboost_python*.lib")) {
    Write-Host "Found Boost.Python libraries"
} else {
    Write-Host "Warning: Boost.Python libraries not found!"
}

if (Test-Path (Join-Path $env:BOOST_LIBRARYDIR "libboost_graph*.lib")) {
    Write-Host "Found Boost.Graph libraries"
} else {
    Write-Host "Warning: Boost.Graph libraries not found!"
}

# Clean up
Remove-Item -Path $installerPath -Force
Write-Host "Boost setup completed!"

# Output the environment variables for debugging
Write-Host "Environment Variables set:"
Write-Host "BOOST_ROOT: $env:BOOST_ROOT"
Write-Host "BOOST_LIBRARYDIR: $env:BOOST_LIBRARYDIR"
Write-Host "BOOST_INCLUDEDIR: $env:BOOST_INCLUDEDIR"

cd D:\a\vrp_solver_ignore\vrp_solver_ignore
# Build your C++ project
Write-Host "Building C++ project..."
.\scripts\build.bat