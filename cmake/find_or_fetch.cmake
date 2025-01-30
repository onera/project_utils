include(FetchContent)
include(${PROJECT_UTILS_CMAKE_DIR}/dependency_management.cmake) # project_find_package, project_add_dependency


function(find_or_fetch_pybind11)
  option(${PROJECT_NAME}_ENABLE_FETCH_PYBIND "Fetch Pybind11 sources on-the-fly if not found by find_package()" ON)
  if (NOT TARGET pybind11::pybind11) # optim: do not execute `find_package(doctest)` if it has already been executed by another project
    project_find_package(pybind11 2.8 CONFIG)
  endif()
  if (NOT TARGET pybind11::pybind11)
    if (${PROJECT_NAME}_ENABLE_FETCH_PYBIND)
      message("Pybind11 was not found by find_package(). Fetching sources on-the-fly")
      set(PYBIND11_INSTALL ON CACHE BOOL "${PROJECT_NAME} requires PyBind to export itself" FORCE)
      FetchContent_Declare(
        pybind11
        GIT_REPOSITORY https://github.com/pybind/pybind11.git
        GIT_TAG        v2.13.6
      )
      FetchContent_MakeAvailable(pybind11)
      project_add_dependency(pybind11)
    else()
      message(FATAL_ERROR "Pybind11 was not found by find_package() and ${PROJECT_NAME}_ENABLE_FETCH_PYBIND is OFF")
    endif()
  endif()
endfunction()


function(find_or_fetch_fmt)
  option(${PROJECT_NAME}_ENABLE_FETCH_FMT "Fetch fmt sources on-the-fly if not found by find_package()" ON)
  if (NOT TARGET fmt::fmt) # optim: do not execute `find_package(doctest)` if it has already been executed by another project
    project_find_package(fmt 6.2 CONFIG)
  endif()
  if (NOT TARGET fmt::fmt)
    if (${PROJECT_NAME}_ENABLE_FETCH_FMT)
      message("fmt was not found by find_package(). Fetching sources on-the-fly")
      set(FMT_INSTALL ON CACHE BOOL "${PROJECT_NAME} requires fmt to export itself" FORCE)
      FetchContent_Declare(
        fmt
        GIT_REPOSITORY https://github.com/fmtlib/fmt.git
        GIT_TAG        6.2.0
      )
      FetchContent_MakeAvailable(fmt)
      project_add_dependency(fmt)
    else()
      message(FATAL_ERROR "fmt was not found by find_package() and ${PROJECT_NAME}_ENABLE_FETCH_FMT is OFF")
    endif()
  endif()
endfunction()


function(find_or_fetch_robin_map)
  option(${PROJECT_NAME}_ENABLE_FETCH_ROBIN_MAP "Fetch robin-map sources on-the-fly if not found by find_package()" ON)
  project_find_package(robin-map 1.0.1 CONFIG)
  if (NOT robin-map_FOUND)
    if (${PROJECT_NAME}_ENABLE_FETCH_ROBIN_MAP)
      message("robin-map was not found by find_package(). Fetching sources on-the-fly")
      FetchContent_Declare(
        robin-map
        GIT_REPOSITORY https://github.com/tessil/robin-map.git
        GIT_TAG        v1.0.1 # as of 2023/03, v1.2.1 is not working with CMake+FetchContent
      )
      FetchContent_MakeAvailable(robin-map)
      project_add_dependency(robin-map)
    else()
      message(FATAL_ERROR "robin-map was not found by find_package() and ${PROJECT_NAME}_ENABLE_FETCH_ROBIN_MAP is OFF")
    endif()
  endif()
endfunction()


function(find_or_fetch_doctest)
  option(${PROJECT_NAME}_ENABLE_FETCH_DOCTEST "Fetch doctest sources on-the-fly if not found by find_package()" ON)
  if (NOT TARGET doctest::doctest) # optim: do not execute `find_package(doctest)` if it has already been executed by another project
    find_package(doctest 2.4.11 CONFIG) # NOT `project_find_package`, because it is only a dependency of the test executable
  endif()
  if (NOT TARGET doctest::doctest)
    if (${PROJECT_NAME}_ENABLE_FETCH_DOCTEST)
      message("doctest was not found by find_package(). Fetching sources on-the-fly")
      FetchContent_Declare(
        doctest
        GIT_REPOSITORY https://github.com/doctest/doctest.git
        GIT_TAG        v2.4.11
      )
      FetchContent_MakeAvailable(doctest)
    else()
      message(FATAL_ERROR "doctest was not found by find_package() and ${PROJECT_NAME}_ENABLE_FETCH_DOCTEST is OFF")
    endif()
  endif()
endfunction()
