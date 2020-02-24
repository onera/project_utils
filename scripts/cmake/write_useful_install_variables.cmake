function(write_useful_install_variables target_name)
  # 1. write variables to a file
  get_target_property(compile_defs ${target_name} INTERFACE_COMPILE_DEFINITIONS)
  string(REPLACE ";" " " DEPENDENCIES_STRING "${${target_name}_DEPENDENCIES_STRING}")
  string(REPLACE ";" " " THIRDPARTY_DEPENDENCIES_STRING "${${target_name}_THIRDPARTY_DEPENDENCIES_STRING}")
  string(REPLACE ";" "," COMPILE_DEFS_STRING "${COMPILE_DEFS}")
  set(cmake_vars_string "{\n\
    \"PROJECT_NAME\" : \"${target_name}\",\n\
    \"CMAKE_INSTALL_PREFIX\" : \"${CMAKE_INSTALL_PREFIX}\",\n\
    \"DEPENDENCIES_STRING\" : [${DEPENDENCIES_STRING}],\n\
    \"THIRDPARTY_DEPENDENCIES_STRING\" : [${THIRDPARTY_DEPENDENCIES_STRING}],\n\
    \"CMAKE_CXX_FLAGS_RELEASE\" : \"${CMAKE_CXX_FLAGS_RELEASE}\",\n\
    \"COMPILE_DEFS\" : \"${COMPILE_DEFS_STRING}\",\n\
  }")
  set(config_file_name ${target_name}_cmake_variables.py)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${config_file_name} ${cmake_vars_string})
  
  # 2. let an external python script do the parsing
  #    it writes two files: source_${target_name}.sh and a config_${target_name}.ini
  execute_process(COMMAND python3 ${CMAKE_SOURCE_DIR}/external/project_utils/scripts/cmake/create_env_files.py ${CMAKE_CURRENT_BINARY_DIR}/${config_file_name})
  # 3. install the resulting files
  install(
    FILES
      ${CMAKE_CURRENT_BINARY_DIR}/${config_file_name}
      ${CMAKE_CURRENT_BINARY_DIR}/source_${target_name}.sh
      ${CMAKE_CURRENT_BINARY_DIR}/config_${target_name}.ini
    DESTINATION
      env
  )
endfunction()
