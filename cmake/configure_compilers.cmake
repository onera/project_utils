macro(configure_compilers target compilation_file_pattern)
  ## Compiler flags
  # ----------------------------------------------------------------------
  ### C++ standard
  if(NOT DEFINED CMAKE_CXX_STANDARD)
    set(CMAKE_CXX_STANDARD          17 )
  endif()
  ### Compiler-dependent flags

  # Debug vectorisation gcc : -ftree-vectorizer-verbose=6 -fopt-info -fopt-info-all
  # Utile aussi :  -fopt-info-vec-missed
  # ----------------------------------------------------------------------
  ### Fortran includes
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
endmacro()
