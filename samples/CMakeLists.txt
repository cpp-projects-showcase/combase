##
# ComBase (CSV) sample files
#
file (GLOB root_samples RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.csv)

# Installation of the CSV sample files
install (FILES ${root_samples} DESTINATION ${INSTALL_SAMPLE_DIR}
  COMPONENT runtime)
