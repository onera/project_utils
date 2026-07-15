# ----------------------------------------------------------------------------------------------------------------------
function(populate_build_env_paths ld_library_path_out pythonpath_out path_out dependency_folder_envvars_out)

  # Populate paths for tests and to produce source.sh file
  set(ld_library_path "${PROJECT_BINARY_DIR}")
  set(pythonpath "${PROJECT_BINARY_DIR}:${PROJECT_SOURCE_DIR}") # binary for compiled (wrapping) modules, source for regular .py files
  set(path "${PROJECT_SOURCE_DIR}/bin")
  set(dependency_folder_envvars "")

  get_property(dependency_location_list GLOBAL PROPERTY global_dependency_location_list)
  foreach(dependency_location ${dependency_location_list})
    # LD_LIBRARY_PATH: Always take the dependency, even if only compiled libraries are actually necessary
    set(ld_library_path "${PROJECT_BINARY_DIR}/${dependency_location}:${ld_library_path}") # Compiled modules
    # PYTHONPATH: Filter to put the dependency if it has Python modules
    file(GLOB init_py_files ${PROJECT_ROOT}/${dependency_location}/*/__init__.py)
    if (init_py_files)
      set(pythonpath "${PROJECT_BINARY_DIR}/${dependency_location}:${pythonpath}") # Python compiled modules
      set(pythonpath "${PROJECT_ROOT}/${dependency_location}:${pythonpath}") # .py files from the sources
    endif()
    # PATH: Take what is in bin/
    set(path "${PROJECT_ROOT}/${dependency_location}/bin:${path}")

    # export ${dependency_upper}_SOURCE_DIR
    get_filename_component(dependency ${dependency_location} NAME)
    string(TOUPPER ${dependency} dependency_upper)
    set(dependency_folder_envvars "${dependency_folder_envvars}\nexport ${dependency_upper}_SOURCE_DIR=${PROJECT_ROOT}/${dependency_location}")
  endforeach()

  # Search for pythonpath in other external folders TODO is it really usefull? try to DEL
  file(GLOB submod_dependencies_vt LIST_DIRECTORIES true ABSOLUTE "${PROJECT_SOURCE_DIR}/*/external/" "${PROJECT_SOURCE_DIR}/*/external/*")
  foreach(submod_dep_vt ${submod_dependencies_vt})
    # Filter to put in PYTHONPATH only dependency with Python modules
    #file(GLOB init_py_files ${PROJECT_ROOT}/*/external/${submod_dep_vt}/*/__init__.py)
    file(GLOB init_py_files ${submod_dep_vt}/*/__init__.py)
    if (init_py_files)
      set(pythonpath "${submod_dep_vt}:${pythonpath}") # Python compiled modules
      #set(pythonpath "${PROJECT_ROOT}/*/external/${submod_dep_vt}:${pythonpath}") # .py files from the sources
    endif()
  endforeach()
  ### Special case for ParaDiGM because of the different folder structure
  if (${PROJECT_NAME}_BUILD_EMBEDDED_PDM)
    set(pythonpath "${CMAKE_BINARY_DIR}/external/paradigm/Cython/:${pythonpath}")
    set(pythonpath "${CMAKE_BINARY_DIR}/submodules/paradigm/Cython/:${pythonpath}")
  endif()

  set(${pythonpath_out} "${pythonpath}" PARENT_SCOPE)
  set(${ld_library_path_out} "${ld_library_path}" PARENT_SCOPE)
  set(${path_out} "${path}" PARENT_SCOPE)
  set(${dependency_folder_envvars_out} "${dependency_folder_envvars}" PARENT_SCOPE)
endfunction()

# ----------------------------------------------------------------------------------------------------------------------
function(write_build_env_file)

  # write the source file with all the installation paths
  set(serial_run false)
  # Don't pollute the source with __pycache__
  if (${Python_VERSION} VERSION_GREATER_EQUAL 3.8)
    set(pycache_env_var "PYTHONPYCACHEPREFIX=${PROJECT_BINARY_DIR}/.python_cache")
  else()
    set(pycache_env_var "PYTHONDONTWRITEBYTECODE=1")
  endif()
  if(NOT ${serial_run})
    set(pytest_plugins "pytest_parallel.plugin")
  endif()

  populate_build_env_paths(ld_library_path pythonpath path dependency_folder_envvars)

  # Create source.sh with all needed env var to run pytest outside of CTest
  ## strings inside source.sh.in to be replaced
  message("Creating sourcing file at : ${PROJECT_BINARY_DIR}/source.sh")
  set(PREPEND_LD_LIBRARY_PATH    ${ld_library_path})
  set(PREPEND_PYTHONPATH         ${pythonpath})
  set(PREPEND_PATH               ${path})
  set(DEPENDENCY_FOLDER_ENVVARS  ${dependency_folder_envvars})
  set(PYTEST_ENV_PYCACHE_ENV_VAR ${pycache_env_var})
  set(PYTEST_ROOTDIR             ${PROJECT_BINARY_DIR})
  set(PYTEST_PLUGINS             ${pytest_plugins})
  string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)
  configure_file(
    ${PROJECT_UTILS_CMAKE_DIR}/source.sh.in
    ${PROJECT_BINARY_DIR}/source.sh
    @ONLY
  )

endfunction()
