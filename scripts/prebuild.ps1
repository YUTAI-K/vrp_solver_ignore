choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'
echo "Now set up vcpkg"
git clone https://github.com/microsoft/vcpkg.git
$env:VCPKG_ROOT = "D:\a\vrp_solver_ignore\vrp_solver_ignore\vcpkg"
.\vcpkg\bootstrap-vcpkg.bat
.\vcpkg\vcpkg.exe install boost-python boost-graph
echo "Now build cpp proj"
.\scripts\build.bat