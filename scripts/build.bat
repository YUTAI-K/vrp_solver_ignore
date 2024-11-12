@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

cd D:\a\vrp_solver_ignore\vrp_solver_ignore
echo ============================
echo Starting build.bat
echo Current directory: %CD%
echo ============================

REM Navigate to the C++ directory
cd cpp

REM Create and navigate to the build directory
mkdir build
cd build
echo Changed directory to build: %CD%

REM Configure CMake
echo Running CMake 
cmake .. -DCMAKE_BUILD_TYPE=Release 

REM Build the shared library
cmake --build . --config Release

REM Navigate to the Release directory
cd Release

REM Determine the shared library extension
SET "LIB_EXT=.pyd"

REM Find the built shared library
FOR %%f IN (cppWrapper*!LIB_EXT!) DO (
    SET "SHARED_LIB=%%f"
    echo Found shared library: %%f
    GOTO :found
)
echo Shared library not found!
exit /b 1

:found
REM Copy to the Python package directory
echo Copying "!SHARED_LIB!" to src\vrp_solver_ignore\
copy "!SHARED_LIB!" ..\..\..\src\vrp_solver_ignore\


echo Listing src\vrp_solver_ignore\ directory after copy:
dir ..\..\..\src\vrp_solver_ignore\

ENDLOCAL
