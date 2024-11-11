choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'
echo "Now set up vcpkg"
git clone https://github.com/microsoft/vcpkg.git
.\vcpkg\bootstrap-vcpkg.bat
.\vcpkg\vcpkg.exe install boost-python boost-graph
echo Current directory before setting VCPKG_ROOT: %CD%
set "VCPKG_ROOT=%CD%\vcpkg"
echo VCPKG_ROOT set to %VCPKG_ROOT%
echo "Now build cpp proj"
.\scripts\build.bat