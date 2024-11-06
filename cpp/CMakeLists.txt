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

####################################
###################################
# First need to find Python development components
find_package(Python3 COMPONENTS Interpreter Development REQUIRED )

##Now Find Boost python
find_package(Boost REQUIRED COMPONENTS python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR})

## Find Gurobi and boost-graph
#set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}" ${CMAKE_MODULE_PATH}) # So FindGUROBI.cmake is avilable
#set(ENV{GUROBI_HOME} "/opt/gurobi1103/linux64")
#find_package(GUROBI REQUIRED) # Find GUROBI package
find_package(Boost REQUIRED COMPONENTS graph) # Find Boost graph component


# Link Python, Boost, and GUROBI to the target
target_link_libraries(cppWrapper
        PRIVATE
        Python3::Python
        Python3::Module
        Boost::python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}
        Boost::graph
#        ${GUROBI_CXX_LIBRARY}
#        ${GUROBI_LIBRARY}
)


# Include directories for the required libraries
target_include_directories(cppWrapper
        PRIVATE
        ${Python3_INCLUDE_DIRS}
        ${Boost_INCLUDE_DIRS}
#        ${GUROBI_INCLUDE_DIRS}
)

set_target_properties(cppWrapper PROPERTIES PREFIX "" SUFFIX ".so") # Remove the "lib" prefix when building
message(STATUS "Python3 Interpreter: ${Python3_EXECUTABLE}")
message(STATUS "Python3 Include Directory: ${Python3_INCLUDE_DIRS}")
message(STATUS "Python3 Libraries: ${Python3_LIBRARIES}")
message(STATUS "Python3 Development Include Directory: ${Python3_DEVELOPMENT_INCLUDE_DIRS}")
message(STATUS "Python3 Development Libraries: ${Python3_DEVELOPMENT_LIBRARIES}")
message(STATUS "Boost Include Directory: ${Boost_INCLUDE_DIRS}")
message(STATUS "Boost Python Library: ${Boost_PYTHON${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}_LIBRARY}")
