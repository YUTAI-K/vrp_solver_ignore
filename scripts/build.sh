#!/bin/bash
set -e

# Navigate to the C++ directory
cd cpp

# Create and navigate to the build directory
mkdir -p build
cd build

# Configure CMake
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build the shared library
cmake --build . --config Release

# Copy the shared library to the Python package directory
# Adjust the library extension if necessary
if [[ "$OSTYPE" == "darwin"* ]]; then
    LIB_EXT=".dylib"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LIB_EXT=".so"
else
    echo "Unsupported OS"
    exit 1
fi

# Find the built shared library
SHARED_LIB=$(find . -name "cppWrapper*${LIB_EXT}" | head -n 1)

# Ensure the shared library was found
if [ -z "$SHARED_LIB" ]; then
    echo "Shared library not found!"
    exit 1
fi

# Copy to the Python package directory
cp "$SHARED_LIB" ../../src/vrp_solver_ignore/
