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
find_package(Boost REQUIRED COMPONENTS python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR})
find_package(Boost REQUIRED COMPONENTS graph) # Find Boost graph component


target_link_libraries(cppWrapper
        PRIVATE
        Python3::Python
        Python3::Module
        Boost::python${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}
        Boost::graph
)


target_include_directories(cppWrapper
        PRIVATE
        ${Python3_INCLUDE_DIRS}
        ${Boost_INCLUDE_DIRS}
)

set_target_properties(cppWrapper PROPERTIES PREFIX "" SUFFIX ".so") 

message(STATUS "Python3 Interpreter: ${Python3_EXECUTABLE}")
message(STATUS "Python3 Include Directory: ${Python3_INCLUDE_DIRS}")
message(STATUS "Python3 Libraries: ${Python3_LIBRARIES}")
message(STATUS "Python3 Development Include Directory: ${Python3_DEVELOPMENT_INCLUDE_DIRS}")
message(STATUS "Python3 Development Libraries: ${Python3_DEVELOPMENT_LIBRARIES}")
message(STATUS "Boost Include Directory: ${Boost_INCLUDE_DIRS}")
message(STATUS "Boost Python Library: ${Boost_PYTHON${Python3_VERSION_MAJOR}${Python3_VERSION_MINOR}_LIBRARY}")
