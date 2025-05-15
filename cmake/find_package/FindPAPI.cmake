# Try to find PAPI performance library
# Defines:
#  PAPI_FOUND - System has PAPI
#  PAPI::PAPI - Imported target

find_path(PAPI_INCLUDE_DIR
    NAMES papi.h
    HINTS ${PAPI_ROOT} ENV PAPI_ROOT
    PATH_SUFFIXES include
)

find_library(PAPI_LIBRARY
    NAMES papi
    HINTS ${PAPI_ROOT} ENV PAPI_ROOT
    PATH_SUFFIXES lib lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PAPI
    REQUIRED_VARS PAPI_LIBRARY PAPI_INCLUDE_DIR
)

if (PAPI_FOUND AND NOT TARGET PAPI::PAPI)
    add_library(PAPI::PAPI UNKNOWN IMPORTED)
    set_target_properties(PAPI::PAPI PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${PAPI_INCLUDE_DIR}"
        IMPORTED_LOCATION "${PAPI_LIBRARY}"
    )
endif()

mark_as_advanced(PAPI_INCLUDE_DIR PAPI_LIBRARY)
