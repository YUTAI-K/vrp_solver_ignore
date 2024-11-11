from setuptools import setup, find_packages
import platform
import os
from setuptools.dist import Distribution

# Determine the shared library extension based on the operating system
current_platform = platform.system()
if current_platform == "Windows":
    lib_ext = ".pyd"
else:
    lib_ext = ".so"

# Define the path to the shared library
cpp_wrapper_filename = f"cppWrapper{lib_ext}"
cpp_wrapper_path = os.path.join("src", "vrp_solver_ignore", cpp_wrapper_filename)

# # Ensure the shared library exists
# if not os.path.isfile(cpp_wrapper_path):
#     raise FileNotFoundError(f"{cpp_wrapper_path} not found. Please build the C++ extension before packaging.")

# Custom distribution class to indicate that the package has ext modules
class BinaryDistribution(Distribution):
    def has_ext_modules(self):
        return True

setup(
    name="vrp_solver_ignore",
    version="0.1.1",
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
    install_requires=[
        "gurobipy>=9.0",
        "plotly>=5.0.0",
        "numpy>=1.18.0",
        "pandas>=1.0.0",
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Programming Language :: C++",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.10",
    zip_safe=False,
    distclass=BinaryDistribution,  # Add this line
)
