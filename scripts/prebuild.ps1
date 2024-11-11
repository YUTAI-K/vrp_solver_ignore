choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'
echo "Now set up vcpkg"
git clone https://github.com/microsoft/vcpkg.git
.\vcpkg\bootstrap-vcpkg.bat
.\vcpkg\vcpkg.exe install boost-python boost-graph
$env:VCPKG_ROOT = "$PSScriptRoot\vcpkg"
echo "Now build cpp proj"
.\scripts\build.bat