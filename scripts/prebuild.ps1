choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'
cd D:\a\vrp_solver_ignore\vrp_solver_ignore\
$boostVersion = "1.82.0"
$boostZip = "boost_$($boostVersion)_0.zip"
$boostUrl = "https://boostorg.jfrog.io/artifactory/main/release/$boostVersion/source/$boostZip"
$boostZipPath = "D:\a\vrp_solver_ignore\vrp_solver_ignore\$boostZip"

Invoke-WebRequest -Uri $boostUrl -OutFile $boostZipPath
Expand-Archive -Path $boostZipPath -DestinationPath D:\a\vrp_solver_ignore\vrp_solver_ignore\
cd D:\a\vrp_solver_ignore\vrp_solver_ignore\boost_1_82_0
.\bootstrap.bat
.\b2.exe --build-type=complete --prefix=D:\a\vrp_solver_ignore\vrp_solver_ignore\boost_1_82_0\stage --with-python address-model=64 link=static runtime-link=static threading=multi install

cd D:\a\vrp_solver_ignore\vrp_solver_ignore\
.\scripts\build.bat