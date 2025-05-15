# Try to find HWLOC performance library
# Defines:
#  HWLOC_FOUND - System has HWLOC
#  HWLOC::HWLOC - Imported target

find_path(HWLOC_INCLUDE_DIR
    NAMES hwloc.h
    HINTS ${HWLOC_ROOT} ENV HWLOC_ROOT
    PATH_SUFFIXES include
)

find_library(HWLOC_LIBRARY
    NAMES hwloc
    HINTS ${HWLOC_ROOT} ENV HWLOC_ROOT
    PATH_SUFFIXES lib lib64
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HWLOC
    REQUIRED_VARS HWLOC_LIBRARY HWLOC_INCLUDE_DIR
)

if (HWLOC_FOUND AND NOT TARGET HWLOC::HWLOC)
    add_library(HWLOC::HWLOC UNKNOWN IMPORTED)
    set_target_properties(HWLOC::HWLOC PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${HWLOC_INCLUDE_DIR}"
        IMPORTED_LOCATION "${HWLOC_LIBRARY}"
    )
endif()

mark_as_advanced(HWLOC_INCLUDE_DIR HWLOC_LIBRARY)
