function(create_doctest)
  include(CTest)
  set(options)
  set(one_value_args)
  set(multi_value_args TESTED_TARGET LABEL SOURCES SERIAL_RUN N_PROC)
  cmake_parse_arguments(ARGS "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  set(tested_target ${ARGS_TESTED_TARGET})
  set(label ${ARGS_LABEL})
  set(sources ${ARGS_SOURCES})
  set(serial_run ${ARGS_SERIAL_RUN})
  set(n_proc ${ARGS_N_PROC})

  set(test_name "${tested_target}_doctest_${label}")
  add_executable(${test_name} ${sources})

  target_link_libraries(${test_name}
    PUBLIC
      ${tested_target}::${tested_target}
    PRIVATE
      doctest::doctest
  )

  install(TARGETS ${test_name} RUNTIME DESTINATION bin)
  if(${serial_run})
    add_test(
      NAME ${test_name}
      COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${test_name}
    )
  else()
    add_test(
      NAME ${test_name}
      COMMAND ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} ${n_proc}
              ${MPIEXEC_PREFLAGS}
              ${CMAKE_CURRENT_BINARY_DIR}/${test_name}
              ${MPIEXEC_POSTFLAGS}
    )
  endif()

  set_tests_properties(${test_name} PROPERTIES LABELS "${label}")
  set_tests_properties(${test_name} PROPERTIES SERIAL_RUN ${serial_run})
  set_tests_properties(${test_name} PROPERTIES PROCESSORS ${n_proc})

  # Fails in non-slurm
  # set_tests_properties(${target_name} PROPERTIES PROCESSOR_AFFINITY true)
endfunction()


function(create_pytest)
  set(options)
  set(one_value_args)
  set(multi_value_args TESTED_FOLDER LABEL SERIAL_RUN N_PROC)
  cmake_parse_arguments(ARGS "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  set(tested_folder ${ARGS_TESTED_FOLDER})
  set(label ${ARGS_LABEL})
  set(serial_run ${ARGS_SERIAL_RUN})
  set(n_proc ${ARGS_N_PROC})
  set(test_name "${PROJECT_NAME}_pytest_${label}")

  set(complete_test_folder "${PROJECT_SOURCE_DIR}/${tested_folder}")

  # -r : display a short test summary info, with a == all except passed (i.e. report failed, skipped, error)
  # -s : no capture (print statements output to stdout)
  # -v : verbose
  # -Wignore : ignore warnings
  # TODO if pytest>6, add --import-mode importlib (cleaner PYTHONPATH used by pytest)
  set(pytest_command pytest ${complete_test_folder} -Wignore -ra -v -s --with-mpi)
  if(${serial_run})
    add_test(
      NAME ${test_name}
      COMMAND ${pytest_command}
    )
  else()
    add_test(
      NAME ${test_name}
      COMMAND ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} ${n_proc}
              ${MPIEXEC_PREFLAGS}
              ${pytest_command}
              ${MPIEXEC_POSTFLAGS}
    )
  endif()

  # > Set properties for the current test
  set(pythonpath ${PROJECT_BINARY_DIR}:${PROJECT_SOURCE_DIR}:${CMAKE_BINARY_DIR}/external/pytest-mpi-check:$ENV{PYTHONPATH})
  message("pythonpath = ${pythonpath}")
  set_tests_properties(${test_name} PROPERTIES LABELS "${label}")
  set_tests_properties(${test_name} PROPERTIES
                       ENVIRONMENT PYTHONPATH=${pythonpath}
                       DEPENDS t_${test_name})
  #set_tests_properties(${test_name} PROPERTIES
  #                     ENVIRONMENT PYTHONPATH=${PROJECT_BINARY_DIR}:${PROJECT_SOURCE_DIR}:${PROJECT_SOURCE_DIR}/${tested_folder}:${CMAKE_BINARY_DIR}/external/pytest-mpi-check:$ENV{PYTHONPATH}
  #                     DEPENDS t_${test_name})
  set_property(TEST ${test_name} APPEND PROPERTY
                       ENVIRONMENT LD_LIBRARY_PATH=${PROJECT_BINARY_DIR}:$ENV{LD_LIBRARY_PATH})
  set_property(TEST ${test_name} APPEND PROPERTY
                       ENVIRONMENT PYTEST_PLUGINS=pytest_mpi_check)
  set_tests_properties(${test_name} PROPERTIES SERIAL_RUN ${serial_run})
  set_tests_properties(${test_name} PROPERTIES PROCESSORS ${n_proc})
  # > Not working if not launch with srun ...
  # set_tests_properties(${test_name} PROPERTIES PROCESSOR_AFFINITY true)
endfunction()
# --------------------------------------------------------------------------------


## --------------------------------------------------------------------------------
#function(mpi_test_create target_file name tested_target n_proc )
#  set(options)
#  set(one_value_args)
#  set(multi_value_args SOURCES INCLUDES LIBRARIES LABELS SERIAL_RUN)
#  cmake_parse_arguments(ARGS "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
#
#  add_executable(${name} ${target_file} ${ARGS_SOURCES})
#
#  target_include_directories(${name} PRIVATE ${ARGS_INCLUDES})
#  target_link_libraries(${name} ${ARGS_LIBRARIES})
#  target_link_libraries(${name} ${tested_target}::${tested_target})
#
#  install(TARGETS ${name} RUNTIME DESTINATION bin)
#  add_test (NAME ${name}
#            COMMAND ${MPIEXEC} ${MPIEXEC_NUMPROC_FLAG} ${n_proc}
#                    ${MPIEXEC_PREFLAGS}
#                    ${CMAKE_CURRENT_BINARY_DIR}/${name}
#                    ${MPIEXEC_POSTFLAGS})
#  # add_test (NAME ${name}
#  #           COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${name})
#
#  # > Set properties for the current test
#  set_tests_properties(${name} PROPERTIES LABELS "${ARGS_LABELS}")
#  set_tests_properties(${name} PROPERTIES PROCESSORS nproc)
#  if(${ARGS_SERIAL_RUN})
#    set_tests_properties(${name} PROPERTIES RUN_SERIAL true)
#  endif()
#  # > Fail in non slurm
#  # set_tests_properties(${name} PROPERTIES PROCESSOR_AFFINITY true)
#
#  # > Specific environement :
#  # set_tests_properties(${name} PROPERTIES ENVIRONMENT I_MPI_DEBUG=5)
#
#endfunction()
## --------------------------------------------------------------------------------
