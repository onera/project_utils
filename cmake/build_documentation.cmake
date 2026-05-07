## TODO remove Doxygen
# SEE https://devblogs.microsoft.com/cppblog/clear-functional-c-documentation-with-sphinx-breathe-doxygen-cmake/
macro(build_sphinx_documentation)
  set(options)
  set(oneValueArgs)
  set(multiValueArgs DEPENDS) # Allow users to specify a list of additional target dependancies
  cmake_parse_arguments(SPHINX "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
# 1. Sphinx
  find_package(Sphinx 3 REQUIRED)
  set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/doc)
  set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/doc/sphinx/html)
  set(SPHINX_INDEX_FILE ${SPHINX_BUILD}/index.html)

  file(GLOB_RECURSE doc_files ${CMAKE_CURRENT_SOURCE_DIR}/doc/*)
  add_custom_command(OUTPUT ${SPHINX_INDEX_FILE}
                     COMMAND source ${PROJECT_BINARY_DIR}/source.sh && ${SPHINX_EXECUTABLE} -b html ${SPHINX_SOURCE} ${SPHINX_BUILD}
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS ${doc_files} ${SPHINX_DEPENDS}
                     COMMENT "Generating Sphinx documentation")

  add_custom_target(${PROJECT_NAME}_sphinx ALL DEPENDS ${SPHINX_INDEX_FILE})

# 2. Install
  install(DIRECTORY ${SPHINX_BUILD}
          DESTINATION ${CMAKE_INSTALL_PREFIX}/share/doc/${PROJECT_NAME})
endmacro()
