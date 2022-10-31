## TODO remove Doxygen
# SEE https://devblogs.microsoft.com/cppblog/clear-functional-c-documentation-with-sphinx-breathe-doxygen-cmake/
macro(build_documentation)
# 0. Doxygen
  find_package(Doxygen REQUIRED)

  file(GLOB_RECURSE HEADERS ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}/*.hpp)

  set(DOXYGEN_INPUT_DIR ${PROJECT_SOURCE_DIR}/${PROJECT_NAME})
  set(DOXYGEN_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/doc/doxygen)
  set(DOXYFILE_IN ${CMAKE_CURRENT_SOURCE_DIR}/doc/Doxyfile.in)
  set(DOXYFILE_OUT ${CMAKE_CURRENT_BINARY_DIR}/doc/Doxyfile)
  # replace @DOXYGEN_INPUT_DIR@ and @DOXYGEN_OUTPUT_DIR@ values in DOXYFILE_IN and output it to DOXYFILE_OUT
  configure_file(${DOXYFILE_IN} ${DOXYFILE_OUT} @ONLY)

  set(DOXYGEN_INDEX_FILE ${DOXYGEN_OUTPUT_DIR}/html/index.html)

  file(MAKE_DIRECTORY ${DOXYGEN_OUTPUT_DIR}) # Doxygen won't create this for us
  add_custom_command(OUTPUT ${DOXYGEN_INDEX_FILE}
                     DEPENDS ${HEADERS}
                     COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE_OUT}
                     MAIN_DEPENDENCY ${DOXYFILE_OUT} ${DOXYFILE_IN}
                     COMMENT "Generating Doxygen documentation")

  add_custom_target(${PROJECT_NAME}_doxygen ALL DEPENDS ${DOXYGEN_INDEX_FILE})

# 1. Sphinx
  find_package(Sphinx 3 REQUIRED)
  set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/doc)
  set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/doc/sphinx/html)
  set(SPHINX_INDEX_FILE ${SPHINX_BUILD}/index.html)

  set(SPHINX_CONF_IN ${CMAKE_CURRENT_SOURCE_DIR}/doc/conf.py.in)
  set(SPHINX_CONF_OUT ${CMAKE_CURRENT_BINARY_DIR}/doc/conf.py)
  # replace @PROJECT_NAME@ and @PROJECT_SOURCE_DIR@ values in SPHINX_CONF_IN and output it to SPHINX_CONF_OUT
  configure_file(${SPHINX_CONF_IN} ${SPHINX_CONF_OUT} @ONLY)

  file(GLOB_RECURSE doc_files ${CMAKE_CURRENT_SOURCE_DIR}/doc/*.rst)
  add_custom_command(OUTPUT ${SPHINX_INDEX_FILE}
                     COMMAND ${SPHINX_EXECUTABLE} -b html -c ${CMAKE_CURRENT_BINARY_DIR}/doc
                     -Dbreathe_projects.${PROJECT_NAME}=${DOXYGEN_OUTPUT_DIR}/xml # Tell Breathe where to find the Doxygen output
                     ${SPHINX_SOURCE} ${SPHINX_BUILD}
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS
                       ${doc_files}
                       #${CMAKE_CURRENT_SOURCE_DIR}/index.rst
                       ${DOXYGEN_INDEX_FILE}
                     MAIN_DEPENDENCY ${SPHINX_CONF_OUT}
                     COMMENT "Generating Sphinx documentation, using Breathe to recover xml files from Doxygen")

  add_custom_target(${PROJECT_NAME}_sphinx ALL DEPENDS ${SPHINX_INDEX_FILE})

# 2. Install
  install(DIRECTORY ${SPHINX_BUILD}
          DESTINATION ${CMAKE_INSTALL_PREFIX}/share/doc/${PROJECT_NAME})
endmacro()


macro(build_sphinx_documentation)
# 1. Sphinx
  find_package(Sphinx 3 REQUIRED)
  set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/doc)
  set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/doc/sphinx/html)
  set(SPHINX_INDEX_FILE ${SPHINX_BUILD}/index.html)

  set(SPHINX_CONF_IN ${CMAKE_CURRENT_SOURCE_DIR}/doc/conf.py.in)
  set(SPHINX_CONF_OUT ${CMAKE_CURRENT_BINARY_DIR}/doc/conf.py)
  # replace @PROJECT_NAME@ and @PROJECT_SOURCE_DIR@ values in SPHINX_CONF_IN and output it to SPHINX_CONF_OUT
  configure_file(${SPHINX_CONF_IN} ${SPHINX_CONF_OUT} @ONLY)

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

  set(SPHINX_CONF_IN ${CMAKE_CURRENT_SOURCE_DIR}/doc/conf.py.in)
  set(SPHINX_CONF_OUT ${REPORT_DIR}/conf.py)
  # replace @REPORT_DIR@ values in SPHINX_CONF_IN and output it to SPHINX_CONF_OUT
  configure_file(${SPHINX_CONF_IN} ${SPHINX_CONF_OUT} @ONLY)

  # We don't build directly from ${SPHINX_SOURCE} because of Sphinx limitations
  #   Indeed, Sphinx wants all the documentation to be contained in one folder (e.g. ${SPHINX_SOURCE})
  #   But here, we want to get some .rst files from ${CMAKE_CURRENT_SOURCE_DIR}/cases and artifacts (.png...) from ${REPORT_DIR}
  #   So since this is not possible, we copy everything to ${REPORT_DIR} and build from it
  file(GLOB_RECURSE doc_files ${SPHINX_SOURCE}/*)
  add_custom_command(OUTPUT ${REPORT_DIR}/index.rst
                     COMMAND "${CMAKE_COMMAND}" -E copy_directory ${SPHINX_SOURCE} ${REPORT_DIR}
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS ${doc_files}
                     COMMENT "Copying doc/ files (in particular .rst files) to ${REPORT_DIR}")
  add_custom_target(${PROJECT_NAME}_sphinx_doc ALL DEPENDS ${REPORT_DIR}/index.rst)

  file(GLOB_RECURSE doc_files ${CMAKE_CURRENT_SOURCE_DIR}/cases/*)
  add_custom_command(OUTPUT ${REPORT_DIR}/cases/cases.rst
                     COMMAND "${CMAKE_COMMAND}" -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/cases ${REPORT_DIR}/cases/
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS ${doc_files}
                     COMMENT "Copying cases/ files (in particular .rst files) to ${REPORT_DIR}")
  add_custom_target(${PROJECT_NAME}_sphinx_cases ALL DEPENDS ${REPORT_DIR}/cases/cases.rst)

  file(GLOB_RECURSE doc_files ${REPORT_DIR}/*)
  add_custom_command(OUTPUT ${SPHINX_INDEX_FILE}
                     COMMAND ${SPHINX_EXECUTABLE} -b html ${REPORT_DIR} ${SPHINX_BUILD}
                     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
                     DEPENDS ${doc_files}
                     COMMENT "Generating Sphinx documentation")
  add_custom_target(${PROJECT_NAME}_sphinx ALL DEPENDS ${SPHINX_INDEX_FILE})
  add_dependencies(${PROJECT_NAME}_sphinx ${PROJECT_NAME}_sphinx_doc ${PROJECT_NAME}_sphinx_cases)

# 2. Install
   install(DIRECTORY ${SPHINX_BUILD}
           DESTINATION ${CMAKE_INSTALL_PREFIX}/share/doc/${PROJECT_NAME})
endmacro()
