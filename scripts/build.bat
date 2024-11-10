@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
REM Navigate to the C++ directory
cd cpp

REM Create and navigate to the build directory
mkdir build
cd build

REM Configure CMake
cmake .. -DCMAKE_BUILD_TYPE=Release ^
        -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake ^
        -A x64

REM Build the shared library
cmake --build . --config Release

REM Determine the shared library extension
SET "LIB_EXT=.pyd"

REM Find the built shared library
FOR %%f IN (cppWrapper*!LIB_EXT!) DO (
    SET "SHARED_LIB=%%f"
    GOTO :found
)
echo Shared library not found!
exit /b 1

:found
REM Copy to the Python package directory
copy "!SHARED_LIB!" ..\..\src\vrp_solver_ignore\
ENDLOCAL
