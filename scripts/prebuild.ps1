git clone https://github.com/microsoft/vcpkg.git

$env:VCPKG_ROOT = "D:\a\vrp_solver_ignore\vrp_solver_ignore\vcpkg"
.\vcpkg\bootstrap-vcpkg.bat



# Determine the target architecture based on CIBW_ARCHITECTURE
switch ($env:CIBW_ARCHITECTURE) {
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
}

Write-Host "Selected vcpkg triplet: $TRIPLET"
Write-Host "CMake platform: $CMAKE_PLATFORM"


.\vcpkg\vcpkg.exe install boost-python boost-graph --triplet $TRIPLET
echo "Now build cpp proj"
.\scripts\build.bat