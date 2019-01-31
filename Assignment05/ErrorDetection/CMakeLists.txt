cmake_minimum_required(VERSION 3.13)
project(ErrorDetection)

set(CMAKE_CXX_STANDARD 17)

add_executable(ErrorDetection main.cpp HammingUtils.h CRCUtils.h)