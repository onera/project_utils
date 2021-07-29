cmake_minimum_required(VERSION 3.12)

# ----------------------------------------------------------------------------------------------------------------------
# _append_to_target_dependency_list and _append_to_target_thirdparty_dependency_list
# ----------------------------------------------------------------------------------------------------------------------
# create global variables storing a target dependencies
# these variables are useful later when installing the target
# note: both _append_to_target_dependency_list and _append_to_target_thirdparty_dependency_list
#       append to the same
#         ${target}_DEPENDENCIES_FIND_PACKAGE_STRING
#       but _append_to_target_dependency_list appends to
#         ${target}_DEPENDENCIES_STRING
#       and _append_to_target_thirdparty_dependency_list appends to
#         ${target}_THIRDPARTY_DEPENDENCIES_STRING
macro(_append_to_target_dependency_list target)
  set(dependency ${ARGN})
  list(APPEND ${target}_DEPENDENCIES_FIND_PACKAGE_STRING "find_package(${dependency})\n")
  list(APPEND ${target}_DEPENDENCIES_STRING "\"${dependency}\",")
endmacro()
macro(_append_to_target_thirdparty_dependency_list target)
  set(dependency ${ARGN})
  list(APPEND ${target}_DEPENDENCIES_FIND_PACKAGE_STRING "find_package(${dependency})\n")
  list(APPEND ${target}_THIRDPARTY_DEPENDENCIES_STRING "\"${dependency}\",")
endmacro()
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# project_add_subdirectory
# ----------------------------------------------------------------------------------------------------------------------
# add the subdirectory ${dependency} located in ${project_root}/external/
# the string ${target}_DEPENDENCIES_FIND_PACKAGE_STRING is appended the corresponding find_package() command
#   the idea is that we will be able to use this string
#   when adding dependencies to the ${target}Config.cmake file further down the installation process
macro(project_add_subdirectory dependency)
  _append_to_target_dependency_list(${PROJECT_NAME} ${dependency})
  if (NOT TARGET ${dependency}) # if not already included
    add_subdirectory(${PROJECT_ROOT}/external/${dependency} ${CMAKE_BINARY_DIR}/external/${dependency})
  endif()
endmacro()
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# project_find_package
# ----------------------------------------------------------------------------------------------------------------------
# same as project_add_subdirectory except we call find_package instead of add_directory
macro(project_find_package)
  _append_to_target_thirdparty_dependency_list(${PROJECT_NAME} ${ARGV})
  find_package(${ARGV})
endmacro()
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# target_install
# ----------------------------------------------------------------------------------------------------------------------
# Install a target:
#   Boilerplate for installing files of ${target}
#   Create a ${target}Config.cmake that will **automatically** contain dependencies
#     - if project_find_package() was used instead of find_package()
#     - if project_add_subdirectory() was used instead of add_subdirectory()
macro(target_install target)
  if(NOT DEFINED PROJECT_ROOT)
    set(PROJECT_ROOT ${CMAKE_SOURCE_DIR} CACHE PATH "Root directory, where the submodules are populated")
  endif()
  set(PROJECT_UTILS_CMAKE_DIR ${PROJECT_ROOT}/external/project_utils/scripts/cmake)

  install(TARGETS ${target} EXPORT ${target}Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
  )
  install(EXPORT ${target}Targets
    FILE ${target}Targets.cmake
    NAMESPACE ${target}::
    DESTINATION lib/cmake/${target}
  )
  install(DIRECTORY ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}
    DESTINATION include
    FILES_MATCHING
      PATTERN "*.h"
      PATTERN "*.hpp"
      PATTERN "*.hxx"
      PATTERN "*.cxx"
  )

  set(TARGET_NAME ${target}) # WARNING Seems not used but actually used in target_config.cmake.in
  string(REPLACE ";" " " TARGET_DEPENDENCIES_FIND_PACKAGE_STRING "${${target}_DEPENDENCIES_FIND_PACKAGE_STRING}") # Same, used below
  configure_file(
    ${PROJECT_UTILS_CMAKE_DIR}/target_config.cmake.in
    ${target}Config.cmake
    @ONLY
  )
  install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${target}Config.cmake"
    DESTINATION lib/cmake/${target}
  )

  add_library(${target}::${target} ALIAS ${target})
endmacro()
# ----------------------------------------------------------------------------------------------------------------------
