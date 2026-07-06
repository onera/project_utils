if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.27.0")
  cmake_policy(SET CMP0144 NEW) # force find_package to take <PACKAGENAME>_ROOT variables into account
endif()

include(${PROJECT_UTILS_CMAKE_DIR}/check_local_dependency.cmake)
# --------------------------------------------------------------------------------------------------
# _append_to_target_dependency_list and _append_to_target_thirdparty_dependency_list
# --------------------------------------------------------------------------------------------------
# create global variables storing a target dependencies
# these variables are useful later when installing the target
# note: both _append_to_target_dependency_list and _append_to_target_thirdparty_dependency_list
#       append to the same
#         ${target}_DEPENDENCIES_FIND_PACKAGE_STRING
#       but _append_to_target_dependency_list appends to
#         ${target}_DEPENDENCIES_STRING
#       and _append_to_target_thirdparty_dependency_list appends to
#         ${target}_THIRDPARTY_DEPENDENCIES_STRING
function(_append_to_target_dependency_list target)
  set(dependency ${ARGN})
  list(APPEND ${target}_DEPENDENCIES_FIND_PACKAGE_STRING "find_package(${dependency})\n")
  list(APPEND ${target}_DEPENDENCIES_STRING "\"${dependency}\",")
endfunction()
function(_append_to_target_thirdparty_dependency_list target)
  set(dependency ${ARGN})
  list(APPEND ${target}_DEPENDENCIES_FIND_PACKAGE_STRING "find_package(${dependency})\n")
  list(APPEND ${target}_THIRDPARTY_DEPENDENCIES_STRING "\"${dependency}\",")
endfunction()


# --------------------------------------------------------------------------------------------------
# project_add_subdirectory_priv
# --------------------------------------------------------------------------------------------------
# add the subdirectory ${dependency} located either at ${project_root}/${dependency_location}
# the string ${target}_DEPENDENCIES_FIND_PACKAGE_STRING is appended the corresponding find_package() command
#   the idea is that we will be able to use this string
#   when adding dependencies to the ${target}Config.cmake file further down the installation process
function(project_add_subdirectory_priv)
  list(LENGTH ARGN arg_count)
  if(arg_count LESS 2)
    message(FATAL_ERROR "project_add_dependency_priv: dependency dependency_location args are required")
  endif()
  if(arg_count GREATER 3)
    message(FATAL_ERROR "project_add_dependency_priv: too many args")
  endif()
  list(GET ARGN 0 dependency)
  list(GET ARGN 1 dependency_location)
  if(arg_count EQUAL 2)
    set(subfolder "")
  else()
    list(GET ARGN 2 subfolder)
  endif()

  get_property(dependency_list          GLOBAL PROPERTY global_dependency_list)
  if (NOT "${dependency_list}" MATCHES "${dependency}") # if the dependency has not been added by any CMakeLists.txt
    set_property(GLOBAL PROPERTY global_dependency_list          ${dependency} APPEND)
    set_property(GLOBAL PROPERTY global_dependency_location_list ${dependency_location} APPEND)
    _append_to_target_dependency_list(${PROJECT_NAME} ${dependency})
    if (NOT TARGET ${dependency}) # if not already included
      add_subdirectory(${PROJECT_ROOT}/${dependency_location}/${subfolder} ${CMAKE_BINARY_DIR}/${dependency_location}/${subfolder})
    endif()
  endif()
endfunction()

function(project_add_subdirectory dependency)
  find_dependency_location(${dependency} dependency_location error_msg)
  if (error_msg STREQUAL "")
    project_add_subdirectory_priv(${dependency} ${dependency_location} "")
  else()
    message(FATAL_ERROR "${error_msg}")
  endif()
endfunction()


# --------------------------------------------------------------------------------------------------
# project_find_package
# --------------------------------------------------------------------------------------------------
# same as project_add_subdirectory except we call find_package instead of add_directory
# Note: should stay a macro since we use ARGV
macro(project_find_package)
  _append_to_target_thirdparty_dependency_list(${PROJECT_NAME} ${ARGV})
  find_package(${ARGV})
endmacro()

# --------------------------------------------------------------------------------------------------
# project_register_dependency
# --------------------------------------------------------------------------------------------------
macro(project_register_dependency dependency)
  _append_to_target_dependency_list(${PROJECT_NAME} ${dependency})
endmacro()


# --------------------------------------------------------------------------------------------------
# project_add_dependency
# --------------------------------------------------------------------------------------------------
# try to add a dependency by project_add_subdirectory
# if the dependency is not present as a subdirectory, add it with project_find_package
function(project_add_dependency)
  list(LENGTH ARGN arg_count)

  if(arg_count LESS 1)
    message(FATAL_ERROR "project_add_dependency: dependency name is required")
  endif()

  list(GET ARGN 0 dependency)
  set(required FALSE)
  set(subfolder "")

  if(arg_count GREATER 1)
    list(GET ARGN 1 arg1)
    if(arg1 STREQUAL "REQUIRED")
      set(required TRUE)
      if(arg_count GREATER 2)
        list(GET ARGN 2 arg2)
        if(arg2 STREQUAL "SUBFOLDER")
          list(GET ARGN 3 subfolder)
        endif()
      endif()
    elseif(arg1 STREQUAL "SUBFOLDER")
      if(arg_count GREATER 2)
        list(GET ARGN 2 subfolder)
      endif()
    endif()
  endif()

  find_dependency_location(${dependency} dependency_location error_msg)
  if (error_msg STREQUAL "")
    project_add_subdirectory_priv(${dependency} ${dependency_location} ${subfolder})
  else()
    project_find_package(${dependency} CONFIG)
    if (NOT ${${dependency}_FOUND})
      message(FATAL_ERROR "${error_msg}")
    endif()
  endif()
endfunction()

function(project_add_subdir_or_package dependency_location) # TODO old name: deprecate
  project_add_dependency(${dependency_location})
endfunction()


# --------------------------------------------------------------------------------------------------
# target_install
# --------------------------------------------------------------------------------------------------
# Install a target:
#   Boilerplate for installing files of ${target}
#   Create a ${target}Config.cmake that will **automatically** contain dependencies
#     - if project_find_package() was used instead of find_package()
#     - if project_add_subdirectory() was used instead of add_subdirectory()
macro(target_install target)
  if (NOT DEFINED PROJECT_UTILS_CMAKE_DIR)
    message(FATAL_ERROR "PROJECT_UTILS_CMAKE_DIR is not defined")
  endif()

  # Installation paths
  install(TARGETS ${target} EXPORT ${target}Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
  )

  # Install headers
  install(DIRECTORY ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}
    DESTINATION include
    FILES_MATCHING
      PATTERN "*.h"
      PATTERN "*.hpp"
      PATTERN "*.hxx" # Cassiopee/Nuga
      PATTERN "*.cxx" # Cassiopee/Nuga
      PATTERN "*.f90.in" # SoNICS
  )
  # Install executable scripts
  if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/bin)
    install(DIRECTORY   ${CMAKE_CURRENT_SOURCE_DIR}/bin
            DESTINATION ${CMAKE_INSTALL_PREFIX}
            FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
                             GROUP_READ             GROUP_EXECUTE
                             WORLD_READ             WORLD_EXECUTE)
  endif()


  # Install cmake package files (${target}Targets.cmake and ${target}Config.cmake)
  install(EXPORT ${target}Targets
    FILE ${target}Targets.cmake
    NAMESPACE ${target}::
    DESTINATION lib/cmake/${target}
  )
  set(TARGET_NAME ${target}) # WARNING TARGET_NAME seems not used but is actually used in target_config.cmake.in
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
