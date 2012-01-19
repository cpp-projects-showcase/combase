#
cmake_minimum_required (VERSION 2.6)

##
# CMake macros for the project
include (config/project_config_embeddable.cmake)

##
# Project info
set_project_names (combase ComBase)
set_project_brief ("C++ Common Base")
set_project_versions (99 99 99)

##
# Project options
# The parameters are:
#  * whether or not the documentation must be built and installed
set_project_options (on on)


#####################################
##            Packaging            ##
#####################################
#
packaging_init (${PROJECT_NAME})
packaging_set_summary (
"${PROJECT_NAME} is part of the showcase platform for C++ projects.

The common base (in short, 'combase') project contains a purely virtual
C++ class, which serves as a base class for other C++ projects/components.")
packaging_set_contact ("Denis Arnaud <denis_arnaud - at - users dot sourceforge dot net>")
packaging_set_vendor ("Denis Arnaud")

#
packaging_set_other_options (TBZ2 "TBZ2;TGZ")


########################################
##            Dependencies            ##
########################################
#
get_external_libs (git "python 2.4" "boost 1.33" "mysql 5.4" "soci 3.0"
  "doxygen 1.4")


##############################################
##           Build, Install, Export         ##
##############################################
##
# Initialise the building process
init_build ()

##
# Sub-modules
add_modules (${PROJECT_NAME})

##
# For other projects to use COMBASE, install a few helpers for standard
# build/packaging systems: CMake, GNU Autotools (M4), pkgconfig/pc, combase-config
install_dev_helper_files ()

##
# Basic documentation (i.e., AUTHORS, NEWS, README, INSTALL)
install_basic_documentation ()


##########################################
##            Documentation             ##
##########################################
handle_html_doc ()

##
# Subdirs
add_subdirectory (db)
add_subdirectory (samples)
add_subdirectory (man)


#####################################
##              Tests              ##
#####################################
##
# Initialise the unit test process
init_test ()

##
# Test suites
add_test_suite (${PROJECT_NAME})


#######################################
##          Overall Status           ##
#######################################
display_status ()


#######################################
##         CMake Cache Storage       ##
#######################################
store_in_cache ()
