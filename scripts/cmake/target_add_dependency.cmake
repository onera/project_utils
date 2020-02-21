cmake_minimum_required(VERSION 3.12)

macro(target_add_dependency target dependency)
  if(NOT TARGET ${dependency})
    add_subdirectory(${CMAKE_SOURCE_DIR}/external/${dependency} ${CMAKE_BINARY_DIR}/external/${dependency})
  endif()
endmacro()

macro(target_add_thirdparty_dependency target)
  find_package(${ARGN})
endmacro()
