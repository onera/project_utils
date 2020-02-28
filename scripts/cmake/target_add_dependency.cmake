cmake_minimum_required(VERSION 3.12)

# create global variables storing a target dependencies
# these variables are useful later when installing the target
# note: both append_to_target_dependency_list and append_to_target_thirdparty_dependency_list
#       append to the same
#         ${target}_DEPENDENCIES_FIND_PACKAGE_STRING
#       but append_to_target_dependency_list appends to
#         ${target}_DEPENDENCIES_STRING
#       and append_to_target_thirdparty_dependency_list appends to
#         ${target}_THIRDPARTY_DEPENDENCIES_STRING
macro(append_to_target_dependency_list target)
  set(dependency ${ARGN})
  list(APPEND ${target}_DEPENDENCIES_FIND_PACKAGE_STRING "find_package(${dependency})\n")
  list(APPEND ${target}_DEPENDENCIES_STRING "\"${dependency}\",")
endmacro()
macro(append_to_target_thirdparty_dependency_list target)
  set(dependency ${ARGN})
  list(APPEND ${target}_DEPENDENCIES_FIND_PACKAGE_STRING "find_package(${dependency})\n")
  list(APPEND ${target}_THIRDPARTY_DEPENDENCIES_STRING "\"${dependency}\",")
endmacro()

# target_add_dependency
# add the subdirectory ${dependency} located in ${project_root<}/external/
# the string ${target}_DEPENDENCIES_FIND_PACKAGE_STRING is appended the corresponding find_package() command
#   the idea is that we will be able to use this string
#   when adding dependencies to the ${target}Config.cmake file further down the installation process
macro(target_add_dependency target dependency)
  append_to_target_dependency_list(${target} ${dependency})
  if(NOT TARGET ${dependency})
    add_subdirectory(${git_root_dir}/external/${dependency} ${CMAKE_BINARY_DIR}/external/${dependency})
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
  append_to_target_thirdparty_dependency_list(${target} ${ARGN})
  find_package(${ARGN})
endmacro()
