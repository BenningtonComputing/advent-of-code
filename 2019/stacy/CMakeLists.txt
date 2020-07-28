cmake_minimum_required(VERSION 3.16)
project(stacy)

set(CMAKE_CXX_STANDARD 14)

include_directories(.)
include_directories(day1)

add_executable(stacy
        day1/day1.cpp
        day1/input.txt)
