from skbuild import setup
from setuptools import find_packages
import sys

setup(
    name="vrp_solver_ignore",
    version="0.1.0",
    description="A Vehicle Routing Problem solver with custom strategy.",
    author="Yutai Ke",
    author_email="yutai.ke@bse.eu",
    url="https://github.com/YUTAI-K/vrp_solver_ignore",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    include_package_data=True,
    package_data={
        "vrp_solver_ignore": ["data/*.json", "data/*.csv"],  # Adjust if you have data files
    },
    cmake_args=[
        f'-DPYTHON_EXECUTABLE={sys.executable}',
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
