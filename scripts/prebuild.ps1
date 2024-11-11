choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'
echo "Now set up vcpkg"
git clone https://github.com/microsoft/vcpkg.git
$env:VCPKG_ROOT = "D:\a\vrp_solver_ignore\vrp_solver_ignore\vcpkg"
.\vcpkg\bootstrap-vcpkg.bat
if ([Environment]::Is64BitOperatingSystem) {
    $triplet = "x64-windows-static"
    Write-Host "Detected 64-bit OS. Using triplet: $triplet"
} else {
    $triplet = "x86-windows-static"
    Write-Host "Detected 32-bit OS. Using triplet: $triplet"
}
.\vcpkg\vcpkg.exe install boost-python boost-graph --triplet $triplet
echo "Now build cpp proj"
.\scripts\build.bat