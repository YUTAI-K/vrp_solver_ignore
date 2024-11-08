#!/bin/bash
set -e
set -x  # Enable verbose logging for debugging

# Navigate to the C++ directory
cd cpp

# Create and navigate to the build directory
mkdir -p build
cd build

# Detect architecture and set BOOST_ROOT accordingly
if [[ "$(uname -m)" == "arm64" ]]; then
    export BOOST_ROOT=/opt/homebrew/opt/boost
    export BOOST_LIBRARYDIR=/opt/homebrew/lib
else
    export BOOST_ROOT=/usr/local/opt/boost
    export BOOST_LIBRARYDIR=/usr/local/lib
fi

# Configure CMake with Boost paths
cmake .. -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT=$BOOST_ROOT -DBOOST_LIBRARYDIR=$BOOST_LIBRARYDIR

# Build the shared library
cmake --build . --config Release

# Determine the shared library extension
if [[ "$OSTYPE" == "darwin"* ]]; then
    LIB_EXT=".so"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LIB_EXT=".so"
elif [[ "$OSTYPE" == "msys"* ]]; then
    LIB_EXT=".dll"
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
