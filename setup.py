from skbuild import setup
from setuptools import find_packages
import sys

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
        "vrp_solver_ignore": ["cppWrapper.so", "cppWrapper.pyd"]  # Adjust based on OS
    },
    cmake_args=[
        '-DCMAKE_BUILD_TYPE=Release',
        '-DPYTHON_EXECUTABLE={}'.format(sys.executable),
    ],
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
    python_requires='>=3.10',
    zip_safe=False,
)