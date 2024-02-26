## TODO remove Doxygen
# SEE https://devblogs.microsoft.com/cppblog/clear-functional-c-documentation-with-sphinx-breathe-doxygen-cmake/
macro(build_sphinx_documentation)
# 1. Sphinx
  find_package(Sphinx 3 REQUIRED)
  set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/doc)
  set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/doc/sphinx/html)
  set(SPHINX_INDEX_FILE ${SPHINX_BUILD}/index.html)

  file(GLOB_RECURSE doc_files ${CMAKE_CURRENT_SOURCE_DIR}/doc/*)
  add_custom_command(OUTPUT ${SPHINX_INDEX_FILE}
                     COMMAND ${SPHINX_EXECUTABLE} -b html ${SPHINX_SOURCE} ${SPHINX_BUILD}
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS ${doc_files}
                     COMMENT "Generating Sphinx documentation")

  add_custom_target(${PROJECT_NAME}_sphinx ALL DEPENDS ${SPHINX_INDEX_FILE})

# 2. Install
  install(DIRECTORY ${SPHINX_BUILD}
          DESTINATION ${CMAKE_INSTALL_PREFIX}/share/doc/${PROJECT_NAME})
endmacro()

macro(build_sphinx_report)
# 1. Sphinx
  find_package(Sphinx 3 REQUIRED)
  set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/doc)
  set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/doc/sphinx/html)
  set(SPHINX_INDEX_FILE ${SPHINX_BUILD}/index.html)

  set(REPORT_DIR ${CMAKE_CURRENT_BINARY_DIR}/report)

  # We don't build directly from ${SPHINX_SOURCE} because of Sphinx limitations
  #   Indeed, Sphinx wants all the documentation to be contained in one folder (e.g. ${SPHINX_SOURCE})
  #   But here, we want to get some .rst files from ${CMAKE_CURRENT_SOURCE_DIR}/cases and artifacts (.png...) from ${REPORT_DIR}
  #   So since this is not possible, we copy everything to ${REPORT_DIR} and build from it
  file(GLOB_RECURSE doc_files ${SPHINX_SOURCE}/*)
  add_custom_command(OUTPUT ${REPORT_DIR}/index.rst
                     COMMAND "${CMAKE_COMMAND}" -E copy_directory ${SPHINX_SOURCE} ${REPORT_DIR} # FIXME that we don't delete files here, so the ones deleted in the source still appear here
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS ${doc_files}
                     COMMENT "Copying doc/ files (in particular .rst files) to ${REPORT_DIR}")
  add_custom_target(${PROJECT_NAME}_sphinx_doc ALL DEPENDS ${REPORT_DIR}/index.rst)

  file(GLOB_RECURSE cases_files ${CMAKE_CURRENT_SOURCE_DIR}/sonics_test_suite/cases/*) # TODO not sonics specific
  add_custom_command(OUTPUT ${REPORT_DIR}/cases/cases.rst
                     COMMAND "${CMAKE_COMMAND}" -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/sonics_test_suite/cases ${REPORT_DIR}/cases/ # FIXME same problem
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS ${cases_files}
                     COMMENT "Copying cases/ files (in particular .rst files) to ${REPORT_DIR}")
  add_custom_target(${PROJECT_NAME}_sphinx_cases ALL DEPENDS ${REPORT_DIR}/cases/cases.rst)

  set(all_doc_files ${doc_files} ${cases_files})
  add_custom_command(OUTPUT ${SPHINX_INDEX_FILE}
    COMMAND ${SPHINX_EXECUTABLE} -b html ${REPORT_DIR} ${SPHINX_BUILD}
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS ${all_doc_files}
                     COMMENT "Generating Sphinx documentation")
  add_custom_target(${PROJECT_NAME}_sphinx ALL DEPENDS ${SPHINX_INDEX_FILE})
  add_dependencies(${PROJECT_NAME}_sphinx ${PROJECT_NAME}_sphinx_doc ${PROJECT_NAME}_sphinx_cases)

# 2. Install
   install(DIRECTORY ${SPHINX_BUILD}
           DESTINATION ${CMAKE_INSTALL_PREFIX}/share/doc/${PROJECT_NAME})
endmacro()
