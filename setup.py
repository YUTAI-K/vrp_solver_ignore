from setuptools import setup, find_packages, Extension
import platform
import os
import sys

# Determine the shared library extension based on the operating system
current_platform = platform.system()
if current_platform == "Windows":
    lib_ext = ".pyd"
elif current_platform == "Darwin":
    lib_ext = ".so"  # Python expects .so on macOS
else:
    lib_ext = ".so"

# Define the path to the shared library
cpp_wrapper_filename = f"cppWrapper{lib_ext}"
cpp_wrapper_path = os.path.join("src", "vrp_solver_ignore", cpp_wrapper_filename)

# Ensure the shared library exists
if not os.path.isfile(cpp_wrapper_path):
    raise FileNotFoundError(f"{cpp_wrapper_path} not found. Please build the C++ extension before packaging.")

# Dynamically resolve include directories and library directories using environment variables
if current_platform == "Darwin":
    boost_include_dir = "/opt/homebrew/Cellar/boost/1.86.0_2/include"
    boost_library_dir = "/opt/homebrew/Cellar/boost/1.86.0_2/lib"
    python_include_dir = "/Library/Frameworks/Python.framework/Versions/3.10/include/python3.10"
    python_library_dir = "/Library/Frameworks/Python.framework/Versions/3.10/lib/"

print(f"boost_include_dir is {boost_include_dir}")
print(f"boost_library_dir is {boost_library_dir}")
print(f"python_include_dir is {python_include_dir}")
print(f"python_library_dir is {python_library_dir}")

# Specify libraries based on platform
if current_platform == "Windows":
    libraries = ["boost_python3", "boost_graph"]  # Adjust based on your Boost Python version
elif current_platform == "Darwin":
    libraries = ["libpython3.10.dylib", "Boost::graph", "Python3::Python", "Python3::Module"]  # Adjust based on your Boost Python version
else:
    libraries = ["boost_python3", "boost_graph"]  # Adjust based on your Boost Python version

# Declare the extension module
cpp_extension = Extension(
    name="vrp_solver_ignore.cppWrapper",
    sources=[],  # Empty since we're providing a pre-built .so/.pyd
    # include_dirs=[boost_include_dir, python_include_dir],
    # library_dirs=[boost_library_dir, python_library_dir],
    # libraries=libraries,
    language="c++",
    extra_compile_args=["-std=c++23"],  # Ensure C++23 standard
)

setup(
    name="vrp_solver_ignore",
    version="0.1.0",
    description="A Vehicle Routing Problem solver with custom strategy, please visit the GitHub page for details.",
    author="Yutai Ke",
    author_email="yutai.ke@bse.eu",
    url="https://github.com/YUTAI-K/vrp_solver_ignore",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    include_package_data=True,
    package_data={
        "vrp_solver_ignore": [cpp_wrapper_filename],
    },
    ext_modules=[cpp_extension],  # Declare the extension
    install_requires=[
        "gurobipy>=9.0",
        "plotly>=5.0.0",
        'numpy>=1.18.0',
        'pandas>=1.0.0',
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: C++",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.10',
    zip_safe=False,
)
