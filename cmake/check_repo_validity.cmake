macro(check_repo_validity ignore_dependencies)
  # Check that git modules are initialised only once
  if (PROJECT_ROOT STREQUAL CMAKE_SOURCE_DIR)
    execute_process(
      COMMAND python3 ${PROJECT_ROOT}/external/project_utils/cmake/check_repo_validity.py --root ${PROJECT_ROOT} --ignore-dependencies=${ignore_dependencies}
      RESULT_VARIABLE result
    )
  endif()

  if (result)
    message(FATAL_ERROR "Repository ${PROJECT_ROOT} seems not to be correctly initialized")
  endif()
endmacro()
