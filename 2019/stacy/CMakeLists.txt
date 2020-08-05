cmake_minimum_required(VERSION 3.16)
project(stacy)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)
include_directories(day1)

add_executable(day1
        day1/day1.cpp
        day1/input.txt day3/day3-1.cpp)

add_executable(day2-1
        day2/day2-1.cpp
        day2/input.txt day2/helper.cpp day2/helper.h)

add_executable(day2-2
        day2/day2-2.cpp
        day2/input.txt day2/helper.cpp day2/helper.h)

add_executable(day3-1
        day3/day3-1.cpp
        day3/input.txt day3/helper.cpp day3/helper.h day3/inputtest.txt)

add_executable(day3-2
        day3/day3-2.cpp
        day3/input.txt day3/helper.cpp day3/helper.h day3/inputtest.txt day3/day3-2.cpp)

add_executable(day4
        day4/day4.cpp)
