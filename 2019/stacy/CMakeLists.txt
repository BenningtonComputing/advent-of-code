cmake_minimum_required(VERSION 3.16)
project(stacy)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)
include_directories(day1)

add_executable(day1
        day1/day1.cpp
        day1/input.txt)

add_executable(day2-1
        day2/day2-1.cpp
        day2/input.txt day2/helper.cpp day2/helper.h)

add_executable(day2-2
        day2/day2-2.cpp
        day2/input.txt day2/helper.cpp day2/helper.h)
