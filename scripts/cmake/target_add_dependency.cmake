cmake_minimum_required(VERSION 3.12)

macro(append_to_target_dependency_list target)
  set(dependency ${ARGN})
  list(APPEND ${target}_DEPENDENCIES_FIND_PACKAGE_STRING "find_package(${dependency})\n")
endmacro()

# target_add_dependency
# add the subdirectory ${dependency} located in ${project_root<}/external/
# the string ${target}_DEPENDENCIES_FIND_PACKAGE_STRING is appended the corresponding find_package() command
#   the idea is that we will be able to use this string
#   when adding dependencies to the ${target}Config.cmake file further down the installation process
macro(target_add_dependency target dependency)
  append_to_target_dependency_list(${target} ${dependency})
  if(NOT TARGET ${dependency})
    add_subdirectory(${CMAKE_SOURCE_DIR}/external/${dependency} ${CMAKE_BINARY_DIR}/external/${dependency})
  endif()
endmacro()

# target_add_dependencies
# same as target_add_dependency except for several dependencies
macro(target_add_dependencies target)
  set(dependencies ${ARGN})
  foreach(dep IN ITEMS ${dependencies})
    target_add_dependency(${target} ${dep})
  endforeach()
endmacro()

# target_add_thirdparty_dependency
# same as target_add_dependency except we call find_package instead of add_directory
macro(target_add_thirdparty_dependency target)
  append_to_target_dependency_list(${target} ${ARGN})
  find_package(${ARGN})
endmacro()
