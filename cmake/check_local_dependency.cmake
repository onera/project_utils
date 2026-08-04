# TODO rename this file

# --------------------------------------------------------------------------------------------------
# find_dependency_location
# --------------------------------------------------------------------------------------------------
# Tries to find which folder in ${PROJECT_ROOT} that matches ${dependency}
# Criteria:
#   - the folder can be anywhere inside the ${PROJECT_ROOT} tree
#   - it must be called ${dependency} (obviously
#   - it must direcly contain a .git file/dir
#      (Note: having a .git file/dir is considered to prove that a folder is indeed a repository
#             other significant files would be README, CMakeLists.txt... but .git is more ubiquitous)
# If found, the relative path is returned in dependency_path_out
# If not found, an error message is given in error_out
function(find_dependency_location dependency dependency_path_out error_out)
  # Fast path: dependencies usually live in external/${dependency}
  set(_candidate_dir "${PROJECT_ROOT}/external/${dependency}")
  if (EXISTS "${_candidate_dir}/.git")
    file(GLOB _candidate_files "${_candidate_dir}/*")
    list(LENGTH _candidate_files _nf)
    if (_nf GREATER 1) # If ==1, there is only file .git: still count as empty
      set(${dependency_path_out} "external/${dependency}" PARENT_SCOPE)
      set(${error_out} "" PARENT_SCOPE)
      return()
    endif()
  endif()

  # Fallback: search the whole tree, pruning expensive directories
  # (.git, build, install) to avoid traversing thousands of irrelevant files
  execute_process(
    COMMAND find . -path ./.git -prune -o -path ./build -prune -o -path ./install -prune -o -path "*/${dependency}/.git" -print
    OUTPUT_VARIABLE dot_git_files
    WORKING_DIRECTORY ${PROJECT_ROOT}
  )
  string(REPLACE "/.git\n" ";" folder_list "${dot_git_files}")

  # Error if no match
  list(LENGTH folder_list n_folder)
  if (n_folder EQUAL 0)
    set(error_out "  Could not find folder for dependency '${dependency}'\n  (no match for pattern */${dependency}/.git in folder ${PROJECT_ROOT})" PARENT_SCOPE)

  else()
    # Check which folders are non-empty
    foreach(f ${folder_list})
      file(GLOB ff "${PROJECT_ROOT}/${f}/*")
      list(LENGTH ff nf)
      if (nf GREATER 1) # If ==1, there is only file .git: still count as empty
        string(SUBSTRING ${f} 2 -1 f) # remove leading "./"
        list(APPEND non_empty_folder_list ${f})
      endif()
    endforeach()
    list(LENGTH non_empty_folder_list n_non_empty_folder)

    # Error if all are emtpy
    if (n_non_empty_folder EQUAL 0)
      string(REPLACE ";" "\n    " folder_list "${folder_list}")
      set(error_out "  Could not find folder for dependency '${dependency}'.\n  All the following sub-folders of ${PROJECT_ROOT} are empty:\n    ${folder_list}\n  You should use \"git submodule update --init\" on one of them." PARENT_SCOPE)
    # Error if more than one is non-empty
    elseif (n_non_empty_folder GREATER 1)
      string(REPLACE ";" "\n    " non_empty_folder_list "${non_empty_folder_list}")
      set(error_out "  Multiple sub-folders of ${PROJECT_ROOT} match dependency '${dependency}':\n    ${non_empty_folder_list}\n  Only one of them should be non-empty." PARENT_SCOPE)
      # Success if found one folder
    else()
      set(${dependency_path_out} "${non_empty_folder_list}" PARENT_SCOPE)
      set(${error_out} "" PARENT_SCOPE)
    endif()
  endif()

endfunction()

# check_local_dependency(dependency_location [REQUIRED])
#     Check if dependency_location is non-empty at either ${PROJECT_ROOT}/ or ${PROJECT_ROOT}/external/
#     If it is non-empty, ${dependency}_FOUND is set to ON, else it is set to OFF
macro(check_local_dependency sub_repo_name)
  message(INFO "check_local_dependency is deprecated. If you are trying to add a dependency, project_add_dependency already does the check_local_dependency kind of check")
  set(sub_repo_path "${PROJECT_ROOT}/external/${sub_repo_name}")
  file(GLOB sub_repo_files ${sub_repo_path}/*)
  list(LENGTH sub_repo_files sub_repo_nb_files)

  if (${ARGC} GREATER 2)
    message(FATAL_ERROR "Error: incorrect use of check_local_dependency(sub_repo_name [REQUIRED])")
  endif()
  if ((${ARGC} EQUAL 2) AND NOT ("${ARGN}" STREQUAL "REQUIRED"))
    message(FATAL_ERROR "Error: incorrect use of check_local_dependency(sub_repo_name [REQUIRED])")
  endif()

  if (sub_repo_nb_files EQUAL 0)
    if ((${ARGC} EQUAL 2) AND ("${ARGN}" STREQUAL "REQUIRED"))
      message(FATAL_ERROR
        "${PROJECT_ROOT}/external/${sub_repo_name} is empty. Maybe you forgot to initialize it with \"git submodule update --init\""
      )
    else()
      message(WARNING
       "Did not find optional submodule external/${sub_repo_name}."
      )
      set(${sub_repo_name}_FOUND OFF)
    endif()
  else()
    set(${sub_repo_name}_FOUND ON)
  endif()
endmacro()
