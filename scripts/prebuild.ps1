git clone https://github.com/microsoft/vcpkg.git

$env:VCPKG_ROOT = "D:\a\vrp_solver_ignore\vrp_solver_ignore\vcpkg"
.\vcpkg\bootstrap-vcpkg.bat



REM Determine the target architecture based on CIBW_ARCHITECTURE
if "%CIBW_ARCHITECTURE%"=="x86" (
    set "TRIPLET=x86-windows-static"
) else if "%CIBW_ARCHITECTURE%"=="x64" (
    set "TRIPLET=x64-windows-static"
) else if "%CIBW_ARCHITECTURE%"=="arm64" (
    set "TRIPLET=arm64-windows-static"
) else (
    echo Unsupported architecture: %CIBW_ARCHITECTURE%
    exit /b 1
)

echo Selected vcpkg triplet: %TRIPLET%


.\vcpkg\vcpkg.exe install boost-python boost-graph %TRIPLET%
echo "Now build cpp proj"
.\scripts\build.bat