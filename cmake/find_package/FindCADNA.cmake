cmake_minimum_required(VERSION 3.12)

find_path(CADNA_INCLUDE_DIR
  NAMES
    cadna.h
  PATHS ENV
    CADNA_ROOT 
  PATH_SUFFIXES
    include
  DOC "CADNA include directory")
mark_as_advanced(CADNA_INCLUDE_DIR)

find_library(CADNA_LIBRARY
  NAMES
    cadnaC
  PATHS ENV
    CADNA_ROOT
  PATH_SUFFIXES
    lib
  DOC "CADNA library")
mark_as_advanced(CADNA_LIBRARY)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CADNA
  REQUIRED_VARS CADNA_LIBRARY CADNA_INCLUDE_DIR
)

if(CADNA_FOUND AND NOT TARGET CADNA::CADNA)
  add_library(CADNA::CADNA UNKNOWN IMPORTED)
  set_target_properties(CADNA::CADNA PROPERTIES
    IMPORTED_LINK_INTERFACE_LANGUAGES "CXX"
    IMPORTED_LOCATION "${CADNA_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${CADNA_INCLUDE_DIR}"
  )
endif()
