#
# FindCCCL
#
# CUDA 13.x moved Thrust (and CUB/libcudacxx) into the CCCL project; the
# toolkit ships them under <toolkit>/include/cccl. Find that include dir and
# expose the CCCL::Thrust interface target consumed by SoNICS CMakeLists.
#

find_path( CCCL_INCLUDE_DIR
  NAMES thrust/version.h
  HINTS
    ${CUDAToolkit_INCLUDE_DIRS}
    ${CUDAToolkit_LIBRARY_ROOT}
    ${CUDA_INCLUDE_DIRS}
    ${CUDA_TOOLKIT_ROOT_DIR}
  PATH_SUFFIXES include/cccl
  DOC "CCCL (Thrust/CUB/libcudacxx) headers"
  )

# Find thrust version (optional: only parsed when the version header is found)
if (CCCL_INCLUDE_DIR AND EXISTS "${CCCL_INCLUDE_DIR}/thrust/version.h")
  file( STRINGS "${CCCL_INCLUDE_DIR}/thrust/version.h" version
    REGEX "#define THRUST_VERSION[ \t]+([0-9x]+)"
    )
  if (version)
    string( REGEX REPLACE
      "#define THRUST_VERSION[ \t]+"
      ""
      version
      "${version}"
      )
    string( REGEX MATCH "^[0-9]" major ${version} )
    string( REGEX REPLACE "^${major}00" "" version "${version}" )
    string( REGEX MATCH "^[0-9]" minor ${version} )
    string( REGEX REPLACE "^${minor}0" "" version "${version}" )
    set( CCCL_VERSION "${major}.${minor}.${version}")
  endif()
endif()

include( FindPackageHandleStandardArgs )
find_package_handle_standard_args( CCCL
  REQUIRED_VARS CCCL_INCLUDE_DIR
  VERSION_VAR CCCL_VERSION
  )

if( CCCL_FOUND )
  # GLOBAL imported targets: subprojects (hws/mdarray/tasky/sonics) link
  # Thrust::Thrust or CCCL::Thrust from their own directory scopes.
  if( NOT TARGET CCCL::Thrust )
    add_library( CCCL::Thrust INTERFACE IMPORTED GLOBAL )
    set_target_properties( CCCL::Thrust PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${CCCL_INCLUDE_DIR}"
      )
  endif()
  if( NOT TARGET Thrust::Thrust )
    add_library( Thrust::Thrust INTERFACE IMPORTED GLOBAL )
    set_target_properties( Thrust::Thrust PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${CCCL_INCLUDE_DIR}"
      )
  endif()
endif()

set(CCCL_INCLUDE_DIRS ${CCCL_INCLUDE_DIR})
mark_as_advanced(CCCL_INCLUDE_DIR)
