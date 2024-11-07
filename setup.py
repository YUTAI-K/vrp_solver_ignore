from setuptools import setup, find_packages
import platform
import os

# Determine the shared library extension based on the operating system
current_platform = platform.system()
if current_platform == "Windows":
    lib_ext = ".dll"
elif current_platform == "Darwin":
    lib_ext = ".so"
else:
    lib_ext = ".so"

# Define the path to the shared library
cpp_wrapper_filename = f"cppWrapper{lib_ext}"
cpp_wrapper_path = os.path.join("src", "vrp_solver_ignore", cpp_wrapper_filename)

# Ensure the shared library exists
if not os.path.isfile(cpp_wrapper_path):
    raise FileNotFoundError(f"{cpp_wrapper_path} not found. Please build the C++ extension before packaging.")

setup(
    name="vrp_solver_ignore",  # Your package name
    version="0.1.0",  # Initial version
    description="A Vehicle Routing Problem solver with custom strategy, please visit the github page for details.",
    author="Yutai Ke",
    author_email="yutai.ke@bse.eu",
    url="https://github.com/YUTAI-K/vrp_solver_ignore",  # Replace with your repository URL
    packages=find_packages(where="src"),  # Find packages in the 'src' directory
    package_dir={"": "src"},  # Root package directory
    include_package_data=True,  # Include package data as specified
    package_data={
        "vrp_solver_ignore": [cpp_wrapper_filename],  # Include the shared library
    },
    install_requires=[
        "gurobipy>=9.0",  # Specify the required version of gurobipy
        "plotly>=5.0.0",
        'numpy>=1.18.0',
        'pandas>=1.0.0',
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: C++",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.10',  # Specify the minimum Python version
    zip_safe=False,  # Typically False for packages with compiled extensions
)
