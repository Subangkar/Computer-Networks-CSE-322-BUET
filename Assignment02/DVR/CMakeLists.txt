cmake_minimum_required(VERSION 3.13)
project(DVR)

set(CMAKE_CXX_STANDARD 17)

add_executable(DVR main.cpp Socket.h)

add_executable(Server server.cpp)
add_executable(Client client.cpp)
