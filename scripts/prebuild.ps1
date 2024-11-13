# Enable strict mode for better error handling
Set-StrictMode -Version Latest

# Function to display errors and exit
function Throw-ErrorAndExit($message) {
    Write-Error $message
    exit 1
}


git clone https://github.com/microsoft/vcpkg.git

$env:VCPKG_ROOT = "D:\a\vrp_solver_ignore\vrp_solver_ignore\vcpkg"
.\vcpkg\bootstrap-vcpkg.bat

# Debugging: Output all environment variables
Write-Host "----- Environment Variables -----"
Get-ChildItem Env:
Write-Host "---------------------------------"

# Determine the target architecture based on CIBW_ARCHITECTURE
switch ($env:RUNNER_ARCH) {
    "x86"    { 
        $TRIPLET = "x86-windows-static"
        $CMAKE_PLATFORM = "Win32"
    }
    "x64"    { 
        $TRIPLET = "x64-windows-static"
        $CMAKE_PLATFORM = "x64"
    }
    "arm64"  { 
        $TRIPLET = "arm64-windows-static"
        $CMAKE_PLATFORM = "ARM64"
    }
    default  { 
        Throw-ErrorAndExit "Unsupported architecture: $($env:CIBW_ARCHITECTURE)"
    }
}

Write-Host "Selected vcpkg triplet: $TRIPLET"
Write-Host "CMake platform: $CMAKE_PLATFORM"


.\vcpkg\vcpkg.exe install boost-python boost-graph --triplet $TRIPLET 
echo "Now build cpp proj"
.\scripts\build.bat