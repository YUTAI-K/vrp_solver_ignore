cmake_minimum_required(VERSION 3.21)
project(cppWrapper)
set(CMAKE_CXX_STANDARD 23)

# Add the Python module
add_library(cppWrapper SHARED
        src/library.cpp
        src/ElementaryLabel.cpp
        src/Graph.cpp
        src/Route.cpp
        src/ShortestPath.cpp
)


find_package(Python3 COMPONENTS Interpreter Development REQUIRED )
find_package(Boost REQUIRED COMPONENTS python)
find_package(Boost REQUIRED COMPONENTS graph) # Find Boost graph component


target_link_libraries(cppWrapper
        PRIVATE
        Python3::Python
        Python3::Module
        Boost::python
        Boost::graph
)


target_include_directories(cppWrapper
        PRIVATE
        ${Python3_INCLUDE_DIRS}
        ${Boost_INCLUDE_DIRS}
)


# Determine the shared library extension
if(WIN32)
    set(LIB_EXTENSION ".pyd")
elseif(APPLE)
    set(LIB_EXTENSION ".so")
else()
    set(LIB_EXTENSION ".so")
endif()

# Set the output name with the correct extension
set_target_properties(cppWrapper PROPERTIES
    SUFFIX "${LIB_EXTENSION}"
)

set_target_properties(cppWrapper PROPERTIES PREFIX "") 

# Define the install destination within your package
set(PACKAGE_DIR "vrp_solver_ignore")

# Install the built module into 'vrp_solver_ignore' directory
install(TARGETS cppWrapper
        LIBRARY DESTINATION ${PACKAGE_DIR}
        COMPONENT cppWrapper)

message(STATUS "Python3 Interpreter: ${Python3_EXECUTABLE}")
message(STATUS "Python3 Include Directory: ${Python3_INCLUDE_DIRS}")
message(STATUS "Python3 Libraries: ${Python3_LIBRARIES}")
message(STATUS "Python3 Development Include Directory: ${Python3_DEVELOPMENT_INCLUDE_DIRS}")
message(STATUS "Python3 Development Libraries: ${Python3_DEVELOPMENT_LIBRARIES}")
message(STATUS "Boost Include Directory: ${Boost_INCLUDE_DIRS}")
message(STATUS "Boost Python Library: ${Boost_PYTHON_LIBRARY}")
message(STATUS "PYTHON_LIBRARY_DIR: ${PYTHON_LIBRARY_DIR}")

