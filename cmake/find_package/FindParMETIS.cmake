cmake_minimum_required(VERSION 3.12)

find_path(GKlib_INCLUDE_DIR
  NAMES
    metis.h
  PATHS ENV
    METIS_ROOT PARMETIS_ROOT # note: cmake is only searching ParMETIS_ROOT (case-sensitive)
  PATH_SUFFIXES
    include
  DOC "GKlib include directory")
mark_as_advanced(GKlib_INCLUDE_DIR)

find_path(METIS_INCLUDE_DIR
  NAMES
    metis.h
  PATHS ENV
    METIS_ROOT PARMETIS_ROOT # note: cmake is only searching ParMETIS_ROOT (case-sensitive)
  PATH_SUFFIXES
    include
  DOC "METIS include directory")
mark_as_advanced(METIS_INCLUDE_DIR)

find_path(ParMETIS_INCLUDE_DIR
  NAMES
    parmetis.h
  PATHS ENV
    PARMETIS_ROOT # note: cmake is only searching ParMETIS_ROOT (case-sensitive)
  PATH_SUFFIXES
    include
  DOC "ParMETIS include directory")
mark_as_advanced(ParMETIS_INCLUDE_DIR)


find_library(GKlib_LIBRARY
  NAMES
    GKlib
  PATHS ENV
    METIS_ROOT PARMETIS_ROOT
  PATH_SUFFIXES
    lib
  DOC "GKlib library")
mark_as_advanced(GKlib_LIBRARY)

find_library(METIS_LIBRARY
  NAMES
    metis
  PATHS ENV
    METIS_ROOT PARMETIS_ROOT
  PATH_SUFFIXES
    lib
  DOC "METIS library")
mark_as_advanced(ParMETIS_LIBRARY)

find_library(ParMETIS_LIBRARY
  NAMES
    parmetis
  PATHS ENV
    PARMETIS_ROOT
  PATH_SUFFIXES
    lib
  DOC "ParMETIS library")
mark_as_advanced(ParMETIS_LIBRARY)


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GKlib
  REQUIRED_VARS GKlib_LIBRARY GKlib_INCLUDE_DIR
)
find_package_handle_standard_args(METIS
  REQUIRED_VARS METIS_LIBRARY METIS_INCLUDE_DIR
)
find_package_handle_standard_args(ParMETIS
  REQUIRED_VARS ParMETIS_LIBRARY ParMETIS_INCLUDE_DIR
)

if(GKlib_FOUND AND NOT TARGET GKlib::GKlib)
  add_library(GKlib::GKlib UNKNOWN IMPORTED)
  set_target_properties(GKlib::GKlib PROPERTIES
    IMPORTED_LOCATION "${GKlib_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${GKlib_INCLUDE_DIR}"
  )
endif()
if(METIS_FOUND AND NOT TARGET METIS::METIS)
  add_library(METIS::METIS UNKNOWN IMPORTED)
  target_link_libraries(METIS::METIS
    INTERFACE
      GKlib::GKlib
  )
  set_target_properties(METIS::METIS PROPERTIES
    IMPORTED_LOCATION "${METIS_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${METIS_INCLUDE_DIR}"
  )
endif()
if(ParMETIS_FOUND AND NOT TARGET ParMETIS::ParMETIS)
  add_library(ParMETIS::ParMETIS UNKNOWN IMPORTED)
  target_link_libraries(ParMETIS::ParMETIS
    INTERFACE
      GKlib::GKlib
      METIS::METIS
  )
  set_target_properties(ParMETIS::ParMETIS PROPERTIES
    IMPORTED_LOCATION "${ParMETIS_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${ParMETIS_INCLUDE_DIR}"
  )
endif()
