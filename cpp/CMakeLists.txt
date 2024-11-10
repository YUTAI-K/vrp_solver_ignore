cmake_minimum_required(VERSION 3.21)
project(cppWrapper)
set(CMAKE_CXX_STANDARD 23)
cmake_policy(SET CMP0167 OLD)          # Prefer FindBoost over BoostConfig
# Add the Python module
add_library(cppWrapper MODULE
        src/library.cpp
        src/ElementaryLabel.cpp
        src/Graph.cpp
        src/Route.cpp
        src/ShortestPath.cpp
)
if(APPLE)
    set_target_properties(cppWrapper PROPERTIES
        LINK_FLAGS "-undefined dynamic_lookup"
    )
endif()

find_package(Python3 COMPONENTS Interpreter Development.Module REQUIRED )
find_package(Boost REQUIRED COMPONENTS python)
find_package(Boost REQUIRED COMPONENTS graph) # Find Boost graph component


target_link_libraries(cppWrapper
        PRIVATE
        ${Python3_LIBRARIES}
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

message(STATUS "Python3 Interpreter: ${Python3_EXECUTABLE}")
message(STATUS "Python3 Include Directory: ${Python3_INCLUDE_DIRS}")
message(STATUS "Python3 Libraries: ${Python3_LIBRARIES}")
# message(STATUS "Python3 Development Include Directory: ${Python3_DEVELOPMENT_INCLUDE_DIRS}")
# message(STATUS "Python3 Development Libraries: ${Python3_DEVELOPMENT_LIBRARIES}")
message(STATUS "Boost Include Directory: ${Boost_INCLUDE_DIRS}")
message(STATUS "Boost Python Library: ${Boost_PYTHON_LIBRARY}")
message(STATUS "PYTHON_LIBRARY_DIR: ${PYTHON_LIBRARY_DIR}")

