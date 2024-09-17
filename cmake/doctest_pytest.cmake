# ----------------------------------------------------------------------------------------------------------------------
function(create_doctest)
  include(CTest)
  set(options)
  set(one_value_args)
  set(multi_value_args TESTED_TARGET LABEL SOURCES SERIAL_RUN N_PROC DOCTEST_ARGS)
  cmake_parse_arguments(ARGS "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  set(tested_target ${ARGS_TESTED_TARGET})
  set(label ${ARGS_LABEL})
  set(sources ${ARGS_SOURCES})
  set(serial_run ${ARGS_SERIAL_RUN})
  set(n_proc ${ARGS_N_PROC})
  set(doctest_args ${ARGS_DOCTEST_ARGS})

  set(test_name "${tested_target}_doctest_${label}")
  add_executable(${test_name} ${sources})

  target_link_libraries(${test_name}
    PUBLIC
      ${tested_target}::${tested_target}
    PRIVATE
      doctest::doctest
  )

  install(TARGETS ${test_name} RUNTIME DESTINATION bin)

  set(test_cmd ${CMAKE_CURRENT_BINARY_DIR}/${test_name} ${doctest_args})
  if (NOT ${serial_run})
    set(test_cmd mpirun -np ${n_proc} ${test_cmd})
  endif()

  add_test(
    NAME ${test_name}
    COMMAND ${test_cmd}
  )
endfunction()
# ----------------------------------------------------------------------------------------------------------------------


# ----------------------------------------------------------------------------------------------------------------------
function(create_pytest)
  set(options)
  set(one_value_args)
  set(multi_value_args TESTED_FOLDER LABEL SERIAL_RUN N_PROC PYTEST_ARGS)
  cmake_parse_arguments(ARGS "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  set(tested_folder ${ARGS_TESTED_FOLDER})
  set(label ${ARGS_LABEL})
  set(serial_run ${ARGS_SERIAL_RUN})
  set(n_proc ${ARGS_N_PROC})
  set(pytest_args ${ARGS_PYTEST_ARGS})
  set(test_name "${PROJECT_NAME}_pytest_${label}")

  # Don't pollute the source with __pycache__
  set(pycache_env_var "PYTHONPYCACHEPREFIX=${PROJECT_BINARY_DIR}/.python_cache")

  # -s : print() outputs to stdout
  # -v : verbose
  set(test_cmd pytest --rootdir=${PROJECT_BINARY_DIR} ${tested_folder} -vv -s --color=yes)

  # Setup coverage
  if (${${PROJECT_NAME}_ENABLE_COVERAGE})
    configure_file(
      ${PROJECT_UTILS_CMAKE_DIR}/coverage_config.in
      ${PROJECT_BINARY_DIR}/test/.coveragerc_${label}
      @ONLY
    )
    set(test_cmd coverage run --rcfile=.coveragerc_${label} -m ${test_cmd})
  endif()

  if (NOT ${serial_run})
    set(test_cmd mpirun -np ${n_proc} ${test_cmd})
  endif()

  add_test(
    NAME ${test_name}
    COMMAND ${test_cmd}
  )
endfunction()
# ----------------------------------------------------------------------------------------------------------------------
