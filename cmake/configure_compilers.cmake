macro(configure_compilers target compilation_file_pattern)
  ## Compiler flags
  # ----------------------------------------------------------------------
  ### C++ standard
  set(CMAKE_CXX_STANDARD          17 )
  set(CMAKE_CXX_EXTENSIONS        OFF)
  set(CMAKE_CXX_STANDARD_REQUIRED ON )
  ### fPIC
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
  ### Compiler-dependent flags
  include(${PROJECT_UTILS_CMAKE_DIR}/default_flags.cmake)
  ### Additionnal build types
  include(${PROJECT_UTILS_CMAKE_DIR}/additional_build_types.cmake)
  # Debug vectorisation gcc : -ftree-vectorizer-verbose=6 -fopt-info -fopt-info-all
  # Utile aussi :  -fopt-info-vec-missed
  # ----------------------------------------------------------------------
  
  # ----------------------------------------------------------------------
  # Debug vectorisation gcc : -ftree-vectorizer-verbose=6 -fopt-info -fopt-info-all
  # Utile aussi :  -fopt-info-vec-missed
  ### Fortran includes
  set(CMAKE_Fortran_PREPROCESS ON)
  # Fortran mandatory flags
  if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -DE_DOUBLEREAL -ffixed-line-length-none -fno-second-underscore -std=gnu -fdefault-real-8 -fdefault-double-8")
  elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "Intel")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -DE_DOUBLEREAL -r8 -132")
  elseif(CMAKE_Fortran_COMPILER_ID STREQUAL "IntelLLVM")
    set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -DE_DOUBLEREAL -r8 -132")
  endif()
  # Define installation directory form
  set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules)
  # ----------------------------------------------------------------------

  # NB : Newt occurs error while check CUDA is run into configure_compilers

  # # ----------------------------------------------------------------------
  # if (CMAKE_CUDA_COMPILER)
  #   message(STATUS "Found CUDA support")
  #   ## Integrated in cmake 3.20
  #   if(NOT "$ENV{CUDAARCHS}" STREQUAL "")
  #     set(CMAKE_CUDA_ARCHITECTURES "$ENV{CUDAARCHS}" CACHE STRING "CUDA architectures")
  #   endif()
  
  #   enable_language(CUDA)
  #   project_find_package(CUDAToolkit REQUIRED)
  #   project_find_package(Thrust REQUIRED)
  #   add_definitions(-DENABLE_CUDA)
  
  #   if (NOT DEFINED CMAKE_CUDA_STANDARD)
  #     set(CMAKE_CUDA_STANDARD          17)
  #     set(CMAKE_CUDA_STANDARD_REQUIRED ON)
  #   endif()

  #   set(compilation_file_pattern ${compilation_file_pattern} ${src_dir}/*.cu)
  # else()
  #   message(STATUS "No CUDA support")
  # endif()
  # # ----------------------------------------------------------------------

  # # ----------------------------------------------------------------------
  # # Add AURORA (NEC VE)
  # project_find_package(AURORA)
  # if(NOT AURORA_FOUND)
  #   message(STATUS "Aurora compiler/device not found please export NEC_HOME to find it")
  # else()
  #   add_definitions(-DENABLE_NEC_AURORA)
  #   add_definitions(-DENABLE_VEDA)
  # endif()

  # # Add VEDA (NEC VE)
  # set(VEDA_CMAKE_SCRIPTS /usr/local/ve/veda-0.9.4/cmake)
  # # set(VEDA_CMAKE_SCRIPTS /home/bemichel/dev/install/veda/cmake)
  # list(APPEND CMAKE_MODULE_PATH ${VEDA_CMAKE_SCRIPTS})
  # project_find_package(VE QUIET)
  # if (NOT VEDA_FOUND)
  #   message(STATUS "NEC Aurora compiler/device not found please export VEDA_CMAKE_SCRIPTS to find it")
  # else()
  #   enable_language(VEDA_Fortran VEDA_C VEDA_CXX)
  #   add_definitions(-DENABLE_VEDA)
  # endif()
  # # ----------------------------------------------------------------------

endmacro()

# ----------------------------------------------------------------------
macro(configure_nec_compiler target)
  # Reprendre avec VEDA
  if(AURORA_FOUND)
    nec_add_module(${target}_nec)
  endif()

  # ----------------------------------------------------------------------
  if(VEDA_FOUND)
    # Add includes and libraries on host
    target_include_directories(${target} PUBLIC ${VEDA_INCLUDES})
    target_link_libraries     (${target} PUBLIC ${VEDA_LIBRARY})

    # Create library on device
    set(ve_compilation_file_pattern ${src_dir}/*.vcpp)
    set(ve_compilation_file_pattern ${ve_compilation_file_pattern} ${src_dir}/*.vc)
    set(ve_compilation_file_pattern ${ve_compilation_file_pattern} ${src_dir}/*.vf)
    set(ve_compilation_file_pattern ${ve_compilation_file_pattern} ${src_dir}/*.vfor)
    set(ve_compilation_file_pattern ${ve_compilation_file_pattern} ${src_dir}/*.vf90)

    # Create library on device
    file(GLOB_RECURSE veda_device_and_test_files CONFIGURE_DEPENDS ${ve_compilation_file_pattern})

    set(snc_veda_device_files ${veda_device_and_test_files})
    # list(FILTER snc_veda_device_files EXCLUDE REGEX "${target}/test/*.*$")
    # foreach (snc_veda_device_file ${snc_veda_device_files})
    #   message("snc :: snc_veda_device_file = ${snc_veda_device_file}")
    # endforeach()

    list(LENGTH snc_veda_device_files snc_veda_n_device_files)
    if(snc_veda_n_device_files GREATER 0)
      add_library               (veda_${target} SHARED ${snc_veda_device_files})
      target_include_directories(veda_${target} PUBLIC ${VEDA_INCLUDES})
      target_link_libraries     (veda_${target} PUBLIC ${VEDA_DEVICE_LIBRARY})
      target_install(veda_${target})
    endif()
  endif()
  # ----------------------------------------------------------------------
endmacro()