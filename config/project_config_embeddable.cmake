#######################################################################
## CMake Macros for an embeddable project
##
## Author: Denis Arnaud
## Date: July 2011
#######################################################################


###################################################################
##                     Project Configuration                     ##
###################################################################
##
# Set the project names
macro (set_project_names _project_name_param)
  # Set the pretty name
  string (TOUPPER ${_project_name_param} _pretty_name_tmp)
  if (${ARGC} GREATER 1)
	set (_pretty_name_tmp ${ARGV1})
  endif (${ARGC} GREATER 1)
  set (PACKAGE_PRETTY_NAME "${_pretty_name_tmp}" CACHE INTERNAL "Description")

  # Set the lowercase project name
  string (TOLOWER "${_project_name_param}" _package_tmp)
  set (PACKAGE "${_package_tmp}" CACHE INTERNAL "Description")

  # Set the uppercase project name
  string (TOUPPER "${_project_name_param}" _package_name_tmp)
  set (PACKAGE_NAME "${_package_name_tmp}" CACHE INTERNAL "Description")

  # Set the project name
  project (${PACKAGE})
endmacro (set_project_names)

##
# Set the project brief
macro (set_project_brief _project_brief)
  set (PACKAGE_BRIEF ${_project_brief})
endmacro (set_project_brief)


##
# Set the project versions
macro (set_project_versions _major _minor _patch)
  set (_full_version ${_major}.${_minor}.${_patch})
  #
  set (${PROJECT_NAME}_VERSION_MAJOR ${_major})
  set (${PROJECT_NAME}_VERSION_MINOR ${_minor})
  set (${PROJECT_NAME}_VERSION_PATCH ${_patch})
  set (${PROJECT_NAME}_VERSION ${_full_version})
  #
  set (PACKAGE_VERSION ${_full_version})
  # Note that the soname can be different from the version. The soname
  # should change only when the ABI compatibility is no longer guaranteed.
  set (GENERIC_LIB_VERSION ${_full_version})
  set (GENERIC_LIB_SOVERSION ${_major}.${_minor})
endmacro (set_project_versions)

##
# Set a few options:
#  * BUILD_SHARED_LIBS    - Whether or not to build shared libraries
#  * CMAKE_BUILD_TYPE     - Debug or release
#  * CMAKE_INSTALL_PREFIX - Where to install the deliverable parts
#  * CMAKE_INSTALL_RPATH  - The list of paths to be used by the linker
#  * CMAKE_INSTALL_RPATH_USE_LINK_PATH
#                         - Whether or not to set the run-path/rpath within
#                           the (executable and library) binaries
#  * ENABLE_TEST         - Whether or not to build and check the unit tests
#  * INSTALL_LIB_DIR     - Installation directory for the libraries
#  * INSTALL_BIN_DIR     - Installation directory for the binaries
#  * INSTALL_DATA_DIR    - Installation directory for the data files
#  * INSTALL_INCLUDE_DIR - Installation directory for the header files
#
macro (set_project_options _build_doc _enable_tests)
  # Shared libraries
  option (BUILD_SHARED_LIBS "Set to OFF to build static libraries" ON)

  # Set default cmake build type to Debug (None Debug Release RelWithDebInfo
  # MinSizeRel)
  if (NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE "Debug")
  endif()

  # Set default install prefix to project root directory
  if (CMAKE_INSTALL_PREFIX STREQUAL "/usr/local")
    set (CMAKE_INSTALL_PREFIX "/usr")
  endif()

  # Unit tests (thanks to CMake/CTest)
  option (ENABLE_TEST "Set to OFF to skip build/check unit tests"
	${_enable_tests})

  # Set the library installation directory (either 32 or 64 bits)
  set (LIBDIR "lib${LIB_SUFFIX}" CACHE PATH
    "Library directory name, either lib or lib64")

  # Offer the user the choice of overriding the installation directories
  set (INSTALL_LIB_DIR ${LIBDIR} CACHE PATH
    "Installation directory for libraries")
  set (INSTALL_BIN_DIR bin CACHE PATH "Installation directory for executables")
  set (INSTALL_INCLUDE_DIR include CACHE PATH
    "Installation directory for header files")
  set (INSTALL_DATA_DIR share CACHE PATH
    "Installation directory for data files")

  # Make relative paths absolute (needed later on)
  foreach (_path_type LIB BIN INCLUDE DATA)
    set (var INSTALL_${_path_type}_DIR)
    if (NOT IS_ABSOLUTE "${${var}}")
      set (${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
    endif ()
  endforeach (_path_type)

  # When the install directory is the canonical one (i.e., /usr), the
  # run-path/rpath must be set in all the (executable and library)
  # binaries, so that the dynamic loader can find the dependencies
  # without the user having to set the LD_LIBRARY_PATH environment
  # variable.
  if (CMAKE_INSTALL_PREFIX STREQUAL "/usr")
    set (CMAKE_INSTALL_RPATH "")
    set (CMAKE_INSTALL_RPATH_USE_LINK_PATH OFF)
  else()
    set (CMAKE_INSTALL_RPATH ${INSTALL_LIB_DIR})
    set (CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
  endif()

endmacro (set_project_options)


#
macro (store_in_cache)
  # Force some variables that could be defined in the command line to be
  # written to cache
  set (PACKAGE_VERSION "${PACKAGE_VERSION}" CACHE STRING
    "Version of the project/package")
  set (BUILD_SHARED_LIBS "${BUILD_SHARED_LIBS}" CACHE BOOL
    "Set to OFF to build static libraries" FORCE)
  set (CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" CACHE PATH
    "Where to install ${PROJECT_NAME}" FORCE)
  set (CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}" CACHE PATH
    "Run-path for the library/executable binaries" FORCE)
  set (CMAKE_INSTALL_RPATH_USE_LINK_PATH "${CMAKE_INSTALL_RPATH_USE_LINK_PATH}"
    CACHE BOOL
    "Whether to set the run-path for the library/executable binaries" FORCE)
  set (CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING
    "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel." FORCE)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" CACHE STRING
    "C++ compilation flags" FORCE)
  set (COMPILE_FLAGS "${COMPILE_FLAGS}" CACHE STRING
    "Supplementary C++ compilation flags" FORCE)
  set (CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" CACHE PATH
    "Path to custom CMake Modules" FORCE)
  set (ENABLE_TEST "${ENABLE_TEST}" CACHE BOOL
    "Set to OFF to skip build/check unit tests" FORCE)
endmacro (store_in_cache)


#####################################
##            Packaging            ##
#####################################
#
macro (packaging_init _project_name)
  set (CPACK_PACKAGE_NAME "${_project_name}")
  set (CPACK_PACKAGE_DESCRIPTION "${PACKAGE_BRIEF}")
endmacro (packaging_init)

#
macro (packaging_set_summary _project_summary)
  set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "${_project_summary}")
endmacro (packaging_set_summary)

#
macro (packaging_set_contact _project_contact)
  set (CPACK_PACKAGE_CONTACT "${_project_contact}")
endmacro (packaging_set_contact)

#
macro (packaging_set_vendor _project_vendor)
  set (CPACK_PACKAGE_VENDOR "${_project_vendor}")
endmacro (packaging_set_vendor)

# Both parameters are semi-colon sepetated lists of the types of
# packages to generate, e.g., "TGZ;TBZ2"
macro (packaging_set_other_options _package_type_list _source_package_type_list)
  #
  set (CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
  set (CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
  #set (CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
  set (CPACK_PACKAGE_VERSION_PATCH ${GIT_REVISION})
  set (CPACK_PACKAGE_VERSION ${${PROJECT_NAME}_VERSION})

  # Basic documentation
  if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/README)
    message (FATAL_ERROR "A README file must be defined and located at the root directory")
  endif (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/README)
  set (CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/README)
  set (CPACK_RESOURCE_FILE_README ${CMAKE_CURRENT_SOURCE_DIR}/README)

  # Licence
  if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/COPYING)
    message (FATAL_ERROR "A licence file, namely COPYING, must be defined and located at the root directory")
  endif (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/COPYING)
  set (CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/COPYING)

  ##
  # Reset the generators for the binary packages
  # Available types of package: DEB, RPM, STGZ, TZ, TGZ, TBZ2
  set (CPACK_GENERATOR "${_package_type_list}")
  #set (CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.3.6), libgcc1 (>= 1:4.1)")

  ##
  # Source packages
  # Available types of package: TZ, TGZ, TBZ2
  set (CPACK_SOURCE_GENERATOR "${_source_package_type_list}")

  set (CPACK_SOURCE_PACKAGE_FILE_NAME 
    "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}"
    CACHE INTERNAL "tarball basename")
  set (AUTOTOOLS_IGNRD "/tmp/;/tmp2/;/autom4te\\\\.cache/;autogen\\\\.sh$")
  set (PACK_IGNRD "${CMAKE_CURRENT_BINARY_DIR};${CPACK_PACKAGE_NAME}\\\\.spec;\\\\.gz$;\\\\.bz2$")
  set (EDIT_IGNRD "\\\\.swp$;\\\\.#;/#;~$")
  set (SCM_IGNRD 
    "/CVS/;/\\\\.svn/;/\\\\.bzr/;/\\\\.hg/;/\\\\.git/;\\\\.gitignore$")
  set (CPACK_SOURCE_IGNORE_FILES
    "${AUTOTOOLS_IGNRD};${SCM_IGNRD};${EDIT_IGNRD};${PACK_IGNRD}"
    CACHE STRING "CPACK will ignore these files")
  #set (CPACK_SOURCE_IGNORE_DIRECTORY ${CPACK_SOURCE_IGNORE_FILES} .git)

  # Initialise the source package generator with the variables above
  include (InstallRequiredSystemLibraries)
  include (CPack)

  # Add a 'dist' target, similar to what is given by GNU Autotools
  add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

  ##
  # Reset the generator types for the binary packages. Indeed, the variable
  # has been reset by "include (CPack)".
  set (CPACK_GENERATOR "${_package_type_list}")

endmacro (packaging_set_other_options)


###################################################################
##                         Dependencies                          ##
###################################################################
# ~~~~~~~~ Wrapper ~~~~~~~~
macro (get_external_libs)
  # CMake scripts, to find some dependencies (e.g., Git, Boost)
  set (CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/config/)

  #
  set (PROJ_DEP_LIBS_FOR_LIB "")
  set (PROJ_DEP_LIBS_FOR_BIN "")
  set (PROJ_DEP_LIBS_FOR_TST "")
  foreach (_arg ${ARGV})
    string (TOLOWER ${_arg} _arg_lower_full)

    # Extract the name of the external dependency
    string (REGEX MATCH "^[a-z]+" _arg_lower ${_arg_lower_full})

    # Extract the required version of the external dependency
    string (REGEX MATCH "[0-9._-]+$" _arg_version ${_arg_lower_full})

    if (${_arg_lower} STREQUAL "git")
      get_git (${_arg_version})
    endif (${_arg_lower} STREQUAL "git")

    if (${_arg_lower} STREQUAL "boost")
      get_boost (${_arg_version})
    endif (${_arg_lower} STREQUAL "boost")

    if (${_arg_lower} STREQUAL "combase")
      get_combase (${_arg_version})
    endif (${_arg_lower} STREQUAL "combase")

    if (${_arg_lower} STREQUAL "randgen")
      get_randgen (${_arg_version})
    endif (${_arg_lower} STREQUAL "randgen")

  endforeach (_arg)
endmacro (get_external_libs)

# ~~~~~~~~~~ Git ~~~~~~~~~~
macro (get_git)
  message (STATUS "Requires Git without specifying any version")

  find_package (Git)
  if (Git_FOUND)
    Git_WC_INFO (${CMAKE_CURRENT_SOURCE_DIR} PROJ)
    set (GIT_REVISION ${PROJ_WC_REVISION_HASH})
    message (STATUS "Current Git revision name: ${PROJ_WC_REVISION_NAME}")
  endif (Git_FOUND)
endmacro (get_git)

# ~~~~~~~~~~ BOOST ~~~~~~~~~~
macro (get_boost)
  unset (_required_version)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires Boost-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires Boost without specifying any version")
  endif (${ARGC} GREATER 0)

  #
  # Note: ${Boost_DATE_TIME_LIBRARY} and ${Boost_PROGRAM_OPTIONS_LIBRARY}
  # are already set by ${SOCIMYSQL_LIBRARIES} and/or ${SOCI_LIBRARIES}.
  #
  set (Boost_USE_STATIC_LIBS OFF)
  set (Boost_USE_MULTITHREADED ON)
  set (Boost_USE_STATIC_RUNTIME OFF)
  set (BOOST_REQUIRED_COMPONENTS
    regex program_options date_time iostreams serialization filesystem 
    unit_test_framework python)

  # The first check is for the required components.
  find_package (Boost COMPONENTS ${BOOST_REQUIRED_COMPONENTS})

  # The second check is for the required version (FindBoostWrapper.cmake is
  # provided by us). Indeed, the Fedora/RedHat FindBoost.cmake does not seem
  # to provide version enforcement.
  find_package (BoostWrapper ${_required_version} REQUIRED)

  if (Boost_FOUND)
    # Update the list of include directories for the project
    include_directories (${Boost_INCLUDE_DIRS})

    # Update the list of dependencies for the project
    list (APPEND PROJ_DEP_LIBS_FOR_LIB
      ${Boost_REGEX_LIBRARY} ${Boost_IOSTREAMS_LIBRARY} 
	  ${Boost_SERIALIZATION_LIBRARY} ${Boost_FILESYSTEM_LIBRARY}
	  ${Boost_DATE_TIME_LIBRARY} ${Boost_PYTHON_LIBRARY})
    list (APPEND PROJ_DEP_LIBS_FOR_BIN
	  ${Boost_REGEX_LIBRARY} ${Boost_PROGRAM_OPTIONS_LIBRARY})
    list (APPEND PROJ_DEP_LIBS_FOR_TST ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY})

    # For display purposes
    set (BOOST_REQUIRED_LIBS
      ${Boost_REGEX_LIBRARY} ${Boost_IOSTREAMS_LIBRARY} 
	  ${Boost_SERIALIZATION_LIBRARY} ${Boost_FILESYSTEM_LIBRARY}
	  ${Boost_DATE_TIME_LIBRARY} ${Boost_PROGRAM_OPTIONS_LIBRARY}
	  ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY} ${Boost_PYTHON_LIBRARY})
  endif (Boost_FOUND)

endmacro (get_boost)

# ~~~~~~~~~~ ComBase ~~~~~~~~~
macro (get_combase)
  unset (_required_version)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires ComBase-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires ComBase without specifying any version")
  endif (${ARGC} GREATER 0)

  find_package (ComBase ${_required_version} REQUIRED
	HINTS ${WITH_COMBASE_PREFIX})
  if (ComBase_FOUND)
    #
    message (STATUS "Found ComBase version: ${COMBASE_VERSION}")

    # Update the list of include directories for the project
    include_directories (${COMBASE_INCLUDE_DIRS})

    # Update the list of dependencies for the project
    set (PROJ_DEP_LIBS_FOR_LIB ${PROJ_DEP_LIBS_FOR_LIB} ${COMBASE_LIBRARIES})

  else (ComBase_FOUND)
    set (ERROR_MSG "The ComBase library cannot be found. If it is installed in")
    set (ERROR_MSG "${ERROR_MSG} a non standard directory, just invoke")
    set (ERROR_MSG "${ERROR_MSG} 'cmake' specifying the -DWITH_COMBASE_PREFIX=")
    set (ERROR_MSG "${ERROR_MSG}<ComBase install path> variable.")
    message (FATAL_ERROR "${ERROR_MSG}")
  endif (ComBase_FOUND)
endmacro (get_combase)

# ~~~~~~~~~~ RandGen ~~~~~~~~~
macro (get_randgen)
  unset (_required_version)
  if (${ARGC} GREATER 0)
    set (_required_version ${ARGV0})
    message (STATUS "Requires RandGen-${_required_version}")
  else (${ARGC} GREATER 0)
    message (STATUS "Requires RandGen without specifying any version")
  endif (${ARGC} GREATER 0)

  find_package (RandGen ${_required_version} REQUIRED
	HINTS ${WITH_RANDGEN_PREFIX})
  if (RandGen_FOUND)
    #
    message (STATUS "Found RandGen version: ${RANDGEN_VERSION}")

    # Update the list of include directories for the project
    include_directories (${RANDGEN_INCLUDE_DIRS})

    # Update the list of dependencies for the project
    set (PROJ_DEP_LIBS_FOR_LIB ${PROJ_DEP_LIBS_FOR_LIB} ${RANDGEN_LIBRARIES})

  else (RandGen_FOUND)
    set (ERROR_MSG "The RandGen library cannot be found. If it is installed in")
    set (ERROR_MSG "${ERROR_MSG} a non standard directory, just invoke")
    set (ERROR_MSG "${ERROR_MSG} 'cmake' specifying the -DWITH_RANDGEN_PREFIX=")
    set (ERROR_MSG "${ERROR_MSG}<RandGen install path> variable.")
    message (FATAL_ERROR "${ERROR_MSG}")
  endif (RandGen_FOUND)
endmacro (get_randgen)


##############################################
##           Build, Install, Export         ##
##############################################
macro (init_build)
  ##
  # Compilation
  # Note:
  #  * The debug flag (-g) is set (or not) by giving the corresponding option
  #    when calling cmake:
  #    cmake -DCMAKE_BUILD_TYPE:STRING={Debug,Release,MinSizeRel,RelWithDebInfo}
  #  * The CMAKE_CXX_FLAGS is set by CMake to be equal to the CXXFLAGS 
  #    environment variable. Hence:
  #    CXXFLAGS="-O2"; export CXXFLAGS; cmake ..
  #    will set CMAKE_CXX_FLAGS as being equal to -O2.
  if (NOT CMAKE_CXX_FLAGS)
	#set (CMAKE_CXX_FLAGS "-Wall -Wextra -pedantic -Werror")
	set (CMAKE_CXX_FLAGS "-Wall -Werror")
  endif (NOT CMAKE_CXX_FLAGS)
  # Tell the source code the version of Boost (only once)
  if (NOT "${CMAKE_CXX_FLAGS}" MATCHES "-DBOOST_VERSION=")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBOOST_VERSION=${Boost_VERSION}")
  endif (NOT "${CMAKE_CXX_FLAGS}" MATCHES "-DBOOST_VERSION=")

  #
  include_directories (BEFORE ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
  
  ##
  # Set all the directory installation paths for the project (e.g., prefix,
  # libdir, bindir).
  # Note that those paths need to be set before the sub-directories are browsed
  # for the building process (see below), because that latter needs those paths
  # to be correctly set.
  set_install_directories ()

  ##
  # Initialise the list of modules to build and test suites to check
  set (PROJ_ALL_MOD_FOR_BLD "")
  set (PROJ_ALL_SUITES_FOR_TST "")

  ##
  # Initialise the list of targets to build: libraries, binaries and tests
  set (PROJ_ALL_LIB_TARGETS "")
  set (PROJ_ALL_BIN_TARGETS "")
  set (PROJ_ALL_TST_TARGETS "")

endmacro (init_build)

# Define the substitutes for the variables present in the development
# support files.
macro (set_install_directories)
  set (prefix        ${CMAKE_INSTALL_PREFIX})
  set (exec_prefix   ${prefix})
  set (bindir        ${exec_prefix}/bin)
  set (libdir        ${exec_prefix}/${LIBDIR})
  set (libexecdir    ${exec_prefix}/libexec)
  set (sbindir       ${exec_prefix}/sbin)
  set (sysconfdir    ${prefix}/etc)
  set (includedir    ${prefix}/include)
  set (datarootdir   ${prefix}/share)
  set (datadir       ${datarootdir})
  set (pkgdatadir    ${datarootdir}/${PACKAGE})
  set (docdir        ${datarootdir}/doc/${PACKAGE}-${PACKAGE_VERSION})
  set (htmldir       ${docdir}/html)
  set (pdfdir        ${htmldir})
  set (mandir        ${datarootdir}/man)
  set (infodir       ${datarootdir}/info)
  set (pkgincludedir ${includedir}/${PACKAGE})
  set (pkglibdir     ${libdir}/${PACKAGE})
  set (pkglibexecdir ${libexecdir}/${PACKAGE})
endmacro (set_install_directories)


####
## Module support
####

##
# Set the name of the module
macro (module_set_name _module_name)
  set (MODULE_NAME ${_module_name})
  set (MODULE_LIB_TARGET ${MODULE_NAME}lib)
endmacro (module_set_name)

##
# For each sub-module:
#  * The libraries and binaries are built (with the regular
#    'make' command) and installed (with the 'make install' command).
#    The header files are installed as well.
#  * The corresponding targets (libraries and binaries) are exported within
#    a CMake import helper file, namely '${PROJECT_NAME}-library-depends.cmake'.
#    That CMake import helper file is installed in the installation directory,
#    within the <install_dir>/share/${PROJECT_NAME}/CMake sub-directory.
#    That CMake import helper file is used by the ${PROJECT_NAME}-config.cmake
#    file, to be installed in the same sub-directory. The
#    ${PROJECT_NAME}-config.cmake file is specified a little bit below.
macro (add_modules)
  set (_embedded_components ${ARGV})
  set (LIB_DEPENDENCY_EXPORT ${PROJECT_NAME}-library-depends)
  set (LIB_DEPENDENCY_EXPORT_PATH "${INSTALL_DATA_DIR}/${PROJECT_NAME}/CMake")
  #
  foreach (_embedded_comp ${_embedded_components})
    #
    add_subdirectory (${_embedded_comp})
  endforeach (_embedded_comp)

  # Register, for book-keeping purpose, the list of modules at the project level
  set (PROJ_ALL_MOD_FOR_BLD ${_embedded_components})

endmacro (add_modules)

##
# Building and installation of the "standard library".
# All the sources within each of the layers/sub-directories are used and
# assembled, in order to form a single library, named here the
# "standard library".
# The three parameters (among which only the first one is mandatory) are:
#  * A semi-colon separated list of all the layers in which header and source
#    files are to be found.
#  * Whether or not all the header files should be published. By default, only
#    the header files of the root directory are to be published.
#  * A list of additional dependency on inter-module library targets.
macro (module_library_add_standard _layer_list)
  # ${ARGV} contains a single semi-colon (';') separated list, which
  # is the aggregation of all the elements of all the list parameters.
  # The list of intermodule dependencies must therefore be calculated.
  set (_intermodule_dependencies ${ARGV})

  # Extract the information whether or not all the header files need
  # to be published. Not that that parameter is optional. Its existence
  # has therefore to be checked.
  set (_publish_all_headers_flag False)
  if (${ARGC} GREATER 1)
    string (TOLOWER ${ARGV1} _flag_lower)
    if ("${_flag_lower}" STREQUAL "all")
      set (_publish_all_headers_flag True)
      list (REMOVE_ITEM _intermodule_dependencies ${ARGV1})
    endif ("${_flag_lower}" STREQUAL "all")
  endif (${ARGC} GREATER 1)

  # Initialise the list of header files with the configuration helper header.
  set (${MODULE_LIB_TARGET}_HEADERS ${PROJ_PATH_CFG})

  # Collect the header and source files for all the layers, as specified 
  # as input paramters of this macro
  set (_all_layers ${_layer_list})
  foreach (_layer ${_all_layers})
    # Remove the layer from the list of intermodule dependencies, so that that
    # latter contains only intermodule dependencies at the end. Note that that
    # latter list may be empty at the end (which then means that there is no
    # dependency among modules).
    list (REMOVE_ITEM _intermodule_dependencies ${_layer})

    # Derive the name of the layer. By default, the layer name corresponds
    # to the layer sub-directory. For the root layer (current source directory),
    # though, the layer name is 'root', rather than '.'
    set (_layer_name ${_layer})
    if ("${_layer_name}" STREQUAL ".")
      set (_layer_name root)
    endif ("${_layer_name}" STREQUAL ".")

    # Derive the name of the layer directory. By default, the layer directory
    # name corresponds to the layer sub-directory. For the root layer (current
    # source directory), though, the layer directory name is empty (""),
    # rather than './'
    set (_layer_dir_name "${_layer}/")
    if ("${_layer_dir_name}" STREQUAL "./")
      set (_layer_dir_name "")
    endif ("${_layer_dir_name}" STREQUAL "./")

    file (GLOB ${MODULE_LIB_TARGET}_${_layer_name}_HEADERS 
      RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${_layer_dir_name}*.hpp)
    list (APPEND ${MODULE_LIB_TARGET}_HEADERS
      ${${MODULE_LIB_TARGET}_${_layer_name}_HEADERS})

    file (GLOB ${MODULE_LIB_TARGET}_${_layer_name}_SOURCES 
      RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${_layer_dir_name}*.cpp)
    list (APPEND ${MODULE_LIB_TARGET}_SOURCES 
      ${${MODULE_LIB_TARGET}_${_layer_name}_SOURCES})
  endforeach (_layer)

  # Register, for book-keeping purpose, the list of layers at the module level
  set (${MODULE_NAME}_ALL_LAYERS ${_all_layers} PARENT_SCOPE)
  set (${MODULE_NAME}_ALL_LAYERS ${_all_layers})

  # Gather both the header and source files into a single list
  set (${MODULE_LIB_TARGET}_SOURCES
    ${${MODULE_LIB_TARGET}_HEADERS} ${${MODULE_LIB_TARGET}_SOURCES})

  ##
  # Building of the library.
  # Delegate the (CMake) target registration to a dedicated macro (below)
  module_library_add_specific (${MODULE_NAME} "."
    "${${MODULE_LIB_TARGET}_root_HEADERS}" "${${MODULE_LIB_TARGET}_SOURCES}" 
    ${_intermodule_dependencies})

  # If so required, installation of all the remaining header files 
  # for the module, i.e., the header files located in all the layers
  # except the root.
  if (_publish_all_headers_flag)
    module_header_install_everything_else()
  endif (_publish_all_headers_flag)

  # Convenient message to the user/developer
  if (NOT CMAKE_INSTALL_RPATH_USE_LINK_PATH)
    install (CODE "message (\"On Unix-based platforms, run export LD_LIBRARY_PATH=${INSTALL_LIB_DIR}:\$LD_LIBRARY_PATH once per session\")")
  endif (NOT CMAKE_INSTALL_RPATH_USE_LINK_PATH)

endmacro (module_library_add_standard)

##
# Building and installation of a specific library.
# The first four parameters are mandatory and correspond to:
#  * The short name of the library to be built.
#    Note that the library (CMake) target is derived directly from the library
#    short name: a 'lib' suffix is just appended to the short name.
#  * The directory where to find the header files.
#  * The header files to be published/installed along with the library.
#    If there are no header to be exported, the 'na' keyword (standing for
#    'non available') must be given.
#  * The source files to build the library.
#    Note that the source files contain at least the header files. Hence,
#    even when there are no .cpp source files, the .hpp files will appear.
#
# Note that the header and source files should be given as single parameters,
# i.e., enclosed by double quotes (").
#
# The additional parameters, if given, correspond to the names of the
# modules this current module depends upon. Dependencies on the
# external libraries (e.g., Boost, ComBase) are automatically
# appended, thanks to the get_external_libs() macro.
macro (module_library_add_specific
    _lib_short_name _lib_dir _lib_headers _lib_sources)
  # Derive the library (CMake) target from its name
  set (_lib_target ${_lib_short_name}lib)

  # Register the (CMake) target for the library
  add_library (${_lib_target} SHARED ${_lib_sources})

  # For each module, given as parameter of that macro, add the corresponding
  # library target to a dedicated list
  set (_intermodule_dependencies "")
  foreach (_arg_module ${ARGV})

    if (NOT "${_lib_dir};${_lib_short_name};${_lib_headers};${_lib_sources}" 
	MATCHES "${_arg_module}")
      list (APPEND _intermodule_dependencies ${_arg_module}lib)
    endif ()
  endforeach (_arg_module)

  # Add the dependencies:
  #  * on external libraries (Boost, ComBase), as calculated by 
  #    the get_external_libs() macro above;
  #  * on the other module libraries, as provided as paramaters to this macro
  #  * on the main/standard library of the module (when, of course, the
  #    current library is not the main/standard library).
  if (NOT "${_lib_short_name}" STREQUAL "${MODULE_NAME}")
	set (_intramodule_dependencies ${MODULE_NAME}lib)
  endif (NOT "${_lib_short_name}" STREQUAL "${MODULE_NAME}")
  target_link_libraries (${_lib_target} ${PROJ_DEP_LIBS_FOR_LIB} 
	${_intermodule_dependencies} ${_intramodule_dependencies})

  # Register the library target in the project (for reporting purpose).
  # Note, the list() commands creates a new variable value in the current scope:
  # the set() must therefore be used to propagate the value upwards. And for
  # those wondering whether we could do that operation with a single set()
  # command, I have already tried... unsucessfully(!)
  list (APPEND PROJ_ALL_LIB_TARGETS ${_lib_target})
  set (PROJ_ALL_LIB_TARGETS ${PROJ_ALL_LIB_TARGETS} PARENT_SCOPE)

  # Register the intermodule dependency targets in the project (for
  # reporting purpose).
  set (${MODULE_NAME}_INTER_TARGETS ${_intermodule_dependencies})
  set (${MODULE_NAME}_INTER_TARGETS ${_intermodule_dependencies} PARENT_SCOPE)

  ##
  # Library name (and soname)
  if (WIN32)
    set_target_properties (${_lib_target} PROPERTIES 
      OUTPUT_NAME ${_lib_short_name} 
      VERSION ${GENERIC_LIB_VERSION})
  else (WIN32)
    set_target_properties (${_lib_target} PROPERTIES 
      OUTPUT_NAME ${_lib_short_name}
      VERSION ${GENERIC_LIB_VERSION} SOVERSION ${GENERIC_LIB_SOVERSION})
  endif (WIN32)

  # If everything else is not enough for CMake to derive the language to
  # be used by the linker, it must be told to fall-back on C++
  get_target_property (_linker_lang ${_lib_target} LINKER_LANGUAGE)
  if ("${_linker_lang}" STREQUAL "_linker_lang-NOTFOUND")
    set_target_properties (${_lib_target} PROPERTIES LINKER_LANGUAGE CXX)
    message(STATUS "Had to set the linker language for '${_lib_target}' to CXX")
  endif ("${_linker_lang}" STREQUAL "_linker_lang-NOTFOUND")

  ##
  # Installation of the library
  install (TARGETS ${_lib_target}
    EXPORT ${LIB_DEPENDENCY_EXPORT}
    LIBRARY DESTINATION "${INSTALL_LIB_DIR}" COMPONENT runtime)

  # Register, for reporting purpose, the list of libraries to be built
  # and installed for that module
  list (APPEND ${MODULE_NAME}_ALL_LIBS ${_lib_target})
  set (${MODULE_NAME}_ALL_LIBS ${${MODULE_NAME}_ALL_LIBS} PARENT_SCOPE)

  # If given/existing, install the header files for the library
  string (TOLOWER "${_lib_headers}" _lib_headers_lower)
  if (NOT "${_lib_headers_lower}" STREQUAL "na")
    module_header_install_specific (${_lib_dir} "${_lib_headers}")
  endif (NOT "${_lib_headers_lower}" STREQUAL "na")

endmacro (module_library_add_specific)

##
# Installation of specific header files
macro (module_header_install_specific _lib_dir _lib_headers)
  #
  set (_relative_destination_lib_dir "/${_lib_dir}")
  if ("${_relative_destination_lib_dir}" STREQUAL "/.")
    set (_relative_destination_lib_dir "")
  endif ("${_relative_destination_lib_dir}" STREQUAL "/.")

  # Install header files
  install (FILES ${_lib_headers}
    DESTINATION 
    "${INSTALL_INCLUDE_DIR}/${MODULE_NAME}${_relative_destination_lib_dir}"
    COMPONENT devel)

  # DEBUG
  #message ("DEBUG -- [${_lib_dir}] _lib_headers = ${_lib_headers}")

endmacro (module_header_install_specific)

##
# Installation of all the remaining header files for the module, i.e.,
# the header files located in all the layers except the root.
macro (module_header_install_everything_else)
  # Add the layer for the generated headers to the list of source layers
  set (_all_layers ${${MODULE_NAME}_ALL_LAYERS} ${PROJ_PATH_CFG_DIR})

  # The header files of the root layer have already been addressed by the
  # module_library_add_standard() macro (which calls, in turn,
  # module_library_add_specific(), which calls, in turn, 
  # module_header_install_specific() on the root header files)

  # It remains to install the header files for all the other layers
  foreach (_layer ${_all_layers})
    # Install header files
    install (FILES ${${MODULE_LIB_TARGET}_${_layer}_HEADERS}
      DESTINATION "${INSTALL_INCLUDE_DIR}/${MODULE_NAME}/${_layer}"
      COMPONENT devel)
  endforeach (_layer ${${MODULE_NAME}_ALL_LAYERS})

endmacro (module_header_install_everything_else)

##
# Building and installation of the executables/binaries.
# The two parameters (among which only the first one is mandatory) are:
#  * The path/directory where the header and source files can be found
#    in order to build the executable.
#  * If specified, the name to be given to the executable. If no such name
#    is given as parameter, the executable is given the name of the current
#    module.
macro (module_binary_add _exec_source_dir)
  # First, derive the name to be given to the executable, defaulting
  # to the name of the module
  set (_exec_name ${MODULE_NAME})
  if (${ARGC} GREATER 1})
    set (_exec_name ${ARGV1})
  endif (${ARGC} GREATER 1})

  # Register the (CMake) target for the executable, and specify the name
  # of that latter
  add_executable (${_exec_name}bin ${_exec_source_dir}/${_exec_name}.cpp)
  set_target_properties (${_exec_name}bin PROPERTIES OUTPUT_NAME ${_exec_name})

  # Register the dependencies on which the binary depends upon
  target_link_libraries (${_exec_name}bin
    ${PROJ_DEP_LIBS_FOR_BIN} ${MODULE_LIB_TARGET} 
    ${${MODULE_NAME}_INTER_TARGETS})

  # Binary installation
  install (TARGETS ${_exec_name}bin
    EXPORT ${LIB_DEPENDENCY_EXPORT}
    RUNTIME DESTINATION "${INSTALL_BIN_DIR}" COMPONENT runtime)

  # Register the binary target in the project (for reporting purpose)
  list (APPEND PROJ_ALL_BIN_TARGETS ${_exec_name})
  set (PROJ_ALL_BIN_TARGETS ${PROJ_ALL_BIN_TARGETS} PARENT_SCOPE)

  # Register, for reporting purpose, the list of executables to be built
  # and installed for that module
  list (APPEND ${MODULE_NAME}_ALL_EXECS ${_exec_name})
  set (${MODULE_NAME}_ALL_EXECS ${${MODULE_NAME}_ALL_EXECS} PARENT_SCOPE)

endmacro (module_binary_add)

##
# Installation of the CMake import helper, so that third party projects
# can refer to it (for libraries, header files and binaries)
macro (module_export_install)
  install (EXPORT ${LIB_DEPENDENCY_EXPORT}
    DESTINATION "${INSTALL_DATA_DIR}/${PACKAGE}/CMake" COMPONENT devel)
endmacro (module_export_install)


###################################################################
##                            Tests                              ##
###################################################################
##
# Initialise the CTest framework with CMake, if so enabled
macro (init_test)
  # Register the main test target. Every specific test will then be added
  # as a dependency on that target. When the unit tests are disabled
  # (i.e., the ENABLE_TEST variable is set to OFF), that target remains empty.
  add_custom_target (check)
  
  if (Boost_FOUND AND ENABLE_TEST)
	# Tell CMake/CTest that tests will be performed
	enable_testing() 

  endif (Boost_FOUND AND ENABLE_TEST)
endmacro (init_test)

##
# Register a specific test sub-directory/suite to be checked by CMake/CTest.
# That macro must be called once for each test sub-directory/suite.
# The parameter is:
#  * The test directory path, ommitting the 'test/' prefix. Most often, it is
#    the same as the module name. And when there is a single module (which is
#    the most common case), it corresponds to the project name.
macro (add_test_suite _test_suite_dir)
  if (Boost_FOUND AND ENABLE_TEST)
    # Browse all the modules, and register test suites for each of them
    set (_check_target check_${_test_suite_dir}tst)

    # Each individual test suite is specified within the dedicated
    # sub-directory. The CMake file within each of those test sub-directories
    # specifies a target named check_${_module_name}tst.
    add_subdirectory (test/${_test_suite_dir})

    # Register the test suite (i.e., add the test target as a dependency of
	# the 'check' target).
    add_dependencies (check ${_check_target})

	# Register, for book-keeping purpose (a few lines below), 
	# the (CMake/CTest) test target of the current test suite. When the
	# test directory corresponds to any given module, the test targets will
	# be added to that module dependencies.
	set (${_test_suite_dir}_ALL_TST_TARGETS "")

    # Register, for reporting purpose, the list of test suites to be checked
    list (APPEND PROJ_ALL_SUITES_FOR_TST ${_test_suite_dir})

  endif (Boost_FOUND AND ENABLE_TEST)

endmacro (add_test_suite)

##
# Register a test with CMake/CTest.
# The parameters are:
#  * The name of the test, which will serve as the name for the test binary.
#  * The list of sources for the test binary. The list must be
#    semi-colon (';') seperated.
#  * A list of intermodule dependencies. That list is separated by
#    either white space or semi-colons (';').
macro (module_test_add_suite _module_name _test_name _test_sources)
  if (Boost_FOUND AND ENABLE_TEST)

	# If the module is already known, the corresponding library is added to
	# the list of dependencies.
	set (MODULE_NAME ${_module_name})
	set (MODULE_LIB_TARGET "")
	foreach (_module_item ${PROJ_ALL_MOD_FOR_BLD})
	  if ("${_module_name}" STREQUAL "${_module_item}")
		set (MODULE_LIB_TARGET ${MODULE_NAME}lib)
	  endif ("${_module_name}" STREQUAL "${_module_item}")
	endforeach (_module_item ${PROJ_ALL_MOD_FOR_BLD})

    # Register the test binary target
    add_executable (${_test_name}tst ${_test_sources})
    set_target_properties (${_test_name}tst PROPERTIES
      OUTPUT_NAME ${_test_name})

    message (STATUS "Test '${_test_name}' to be built with '${_test_sources}'")

    # Build the list of library targets on which that test depends upon
    set (_library_list "")
    foreach (_arg_lib ${ARGV})
      if (NOT "${_module_name};${_test_name};${_test_sources}"
		  MATCHES "${_arg_lib}")
		list (APPEND _library_list ${_arg_lib}lib)
      endif ()
    endforeach (_arg_lib)

    # Tell the test binary that it depends on all those libraries
    target_link_libraries (${_test_name}tst ${_library_list} 
      ${MODULE_LIB_TARGET} ${PROJ_DEP_LIBS_FOR_TST})

    # Register the binary target in the module
    list (APPEND ${MODULE_NAME}_ALL_TST_TARGETS ${_test_name}tst)

    # Register the test with CMake/CTest
    if (WIN32)
      add_test (${_test_name}tst ${_test_name}.exe)
    else (WIN32)
      add_test (${_test_name}tst ${_test_name})
    endif (WIN32)
  endif (Boost_FOUND AND ENABLE_TEST)

  # Register the binary target in the project (for reporting purpose)
  list (APPEND PROJ_ALL_TST_TARGETS ${${MODULE_NAME}_ALL_TST_TARGETS})
  set (PROJ_ALL_TST_TARGETS ${PROJ_ALL_TST_TARGETS} PARENT_SCOPE)

  # Register, for reporting purpose, the list of tests to be checked
  # for that module
  list (APPEND ${MODULE_NAME}_ALL_TESTS ${${MODULE_NAME}_ALL_TST_TARGETS})
  set (${MODULE_NAME}_ALL_TESTS ${${MODULE_NAME}_ALL_TESTS} PARENT_SCOPE)

endmacro (module_test_add_suite)

##
# Register all the test binaries for the current module.
# That macro must be called only once per module.
macro (module_test_build_all)
  if (Boost_FOUND)
    # Tell how to test, i.e., how to run the test binaries 
    # and collect the results
    add_custom_target (check_${MODULE_NAME}tst
      COMMAND ${CMAKE_CTEST_COMMAND} DEPENDS ${${MODULE_NAME}_ALL_TST_TARGETS})
  endif (Boost_FOUND)
endmacro (module_test_build_all)


###################################################################
##                    Development Helpers                        ##
###################################################################
# For other projects to use this component (let us name it myproj),
# install a few helpers for standard build/packaging systems: CMake,
# GNU Autotools (M4), pkgconfig/pc, myproj-config
macro (install_dev_helper_files)
  ##
  ## First, build and install CMake development helper files
  ##
  # Create a ${PROJECT_NAME}-config.cmake file for the use from 
  # the install tree and install it
  install (EXPORT ${LIB_DEPENDENCY_EXPORT}
	DESTINATION ${LIB_DEPENDENCY_EXPORT_PATH})
  set (${PACKAGE_NAME}_INCLUDE_DIRS "${INSTALL_INCLUDE_DIR}")
  set (${PACKAGE_NAME}_BIN_DIR "${INSTALL_BIN_DIR}")
  set (${PACKAGE_NAME}_LIB_DIR "${INSTALL_LIB_DIR}")
  set (${PACKAGE_NAME}_DATA_DIR "${INSTALL_DATA_DIR}")
  set (${PACKAGE_NAME}_CMAKE_DIR "${LIB_DEPENDENCY_EXPORT_PATH}")
  configure_file (${PROJECT_NAME}-config.cmake.in
	"${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake" @ONLY)
  configure_file (${PROJECT_NAME}-config-version.cmake.in
	"${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake" @ONLY)
  install (FILES
	"${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
	"${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config-version.cmake"
	DESTINATION "${${PACKAGE_NAME}_CMAKE_DIR}" COMPONENT devel)

  ##
  ## Then, build and install development helper files for other build systems
  ##
  # For the other developers to use that project, a few helper scripts are
  # installed:
  #  * ${PROJECT_NAME}-config (to be used by any other build system)
  #  * GNU Autotools M4 macro
  #  * packaging configuration script (pkgconfig/pc)
  include (config/devhelpers.cmake)

  # Install the development helpers
  install (PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/${CFG_SCRIPT} 
    DESTINATION ${CFG_SCRIPT_PATH})
  install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKGCFG_SCRIPT}
    DESTINATION ${PKGCFG_SCRIPT_PATH})
  install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${M4_MACROFILE}
    DESTINATION ${M4_MACROFILE_PATH})

endmacro (install_dev_helper_files)


#######################################
##          Overall Status           ##
#######################################
# Boost
macro (display_boost)
  if (Boost_FOUND)
    message (STATUS)
    message (STATUS "* Boost:")
    message (STATUS "  - Boost_VERSION ................. : ${Boost_VERSION}")
    message (STATUS "  - Boost_LIB_VERSION ............. : ${Boost_LIB_VERSION}")
    message (STATUS "  - Boost_HUMAN_VERSION ........... : ${Boost_HUMAN_VERSION}")
    message (STATUS "  - Boost_INCLUDE_DIRS ............ : ${Boost_INCLUDE_DIRS}")
    message (STATUS "  - Boost required components ..... : ${BOOST_REQUIRED_COMPONENTS}")
    message (STATUS "  - Boost required libraries ...... : ${BOOST_REQUIRED_LIBS}")
  endif (Boost_FOUND)
endmacro (display_boost)

# ComBase
macro (display_combase)
  if (ComBase_FOUND)
    message (STATUS)
    message (STATUS "* ComBase:")
    message (STATUS "  - COMBASE_VERSION ................ : ${COMBASE_VERSION}")
    message (STATUS "  - COMBASE_BINARY_DIRS ............ : ${COMBASE_BINARY_DIRS}")
    message (STATUS "  - COMBASE_EXECUTABLES ............ : ${COMBASE_EXECUTABLES}")
    message (STATUS "  - COMBASE_LIBRARY_DIRS ........... : ${COMBASE_LIBRARY_DIRS}")
    message (STATUS "  - COMBASE_LIBRARIES .............. : ${COMBASE_LIBRARIES}")
    message (STATUS "  - COMBASE_INCLUDE_DIRS ........... : ${COMBASE_INCLUDE_DIRS}")
  endif (ComBase_FOUND)
endmacro (display_combase)

# RandGen
macro (display_randgen)
  if (RandGen_FOUND)
    message (STATUS)
    message (STATUS "* RandGen:")
    message (STATUS "  - RANDGEN_VERSION ................ : ${RANDGEN_VERSION}")
    message (STATUS "  - RANDGEN_BINARY_DIRS ............ : ${RANDGEN_BINARY_DIRS}")
    message (STATUS "  - RANDGEN_EXECUTABLES ............ : ${RANDGEN_EXECUTABLES}")
    message (STATUS "  - RANDGEN_LIBRARY_DIRS ........... : ${RANDGEN_LIBRARY_DIRS}")
    message (STATUS "  - RANDGEN_LIBRARIES .............. : ${RANDGEN_LIBRARIES}")
    message (STATUS "  - RANDGEN_INCLUDE_DIRS ........... : ${RANDGEN_INCLUDE_DIRS}")
  endif (RandGen_FOUND)
endmacro (display_randgen)

##
macro (display_status_all_modules)
  message (STATUS)
  foreach (_module_name ${PROJ_ALL_MOD_FOR_BLD})
    message (STATUS "* Module .......................... : ${_module_name}")
    message (STATUS "  + Layers to build ............... : ${${_module_name}_ALL_LAYERS}")
    message (STATUS "  + Dependencies on other layers .. : ${${_module_name}_INTER_TARGETS}")
    message (STATUS "  + Libraries to build/install .... : ${${_module_name}_ALL_LIBS}")
    message (STATUS "  + Executables to build/install .. : ${${_module_name}_ALL_EXECS}")
    message (STATUS "  + Tests to perform .............. : ${${_module_name}_ALL_TESTS}")
  endforeach (_module_name)
endmacro (display_status_all_modules)

##
macro (display_status_all_test_suites)
  message (STATUS)
  foreach (_test_suite ${PROJ_ALL_SUITES_FOR_TST})
    message (STATUS "* Test Suite ...................... : ${_test_suite}")
    message (STATUS "  + Dependencies on other layers .. : ${${_test_suite}_INTER_TARGETS}")
    message (STATUS "  + Library dependencies .......... : ${${_test_suite}_ALL_LIBS}")
    message (STATUS "  + Tests to perform .............. : ${${_test_suite}_ALL_TESTS}")
  endforeach (_test_suite)
endmacro (display_status_all_test_suites)

##
macro (display_status)
  message (STATUS)
  message (STATUS "=============================================================")
  message (STATUS "-------------------------------------")
  message (STATUS "---      Project Information      ---")
  message (STATUS "-------------------------------------")
  message (STATUS "PROJECT_NAME ...................... : ${PROJECT_NAME}")
  message (STATUS "PACKAGE_PRETTY_NAME ............... : ${PACKAGE_PRETTY_NAME}")
  message (STATUS "PACKAGE ........................... : ${PACKAGE}")
  message (STATUS "PACKAGE_NAME ...................... : ${PACKAGE_NAME}")
  message (STATUS "PACKAGE_BRIEF ..................... : ${PACKAGE_BRIEF}")
  message (STATUS "PACKAGE_VERSION ................... : ${PACKAGE_VERSION}")
  message (STATUS "GENERIC_LIB_VERSION ............... : ${GENERIC_LIB_VERSION}")
  message (STATUS "GENERIC_LIB_SOVERSION ............. : ${GENERIC_LIB_SOVERSION}")
  message (STATUS)
  message (STATUS "-------------------------------------")
  message (STATUS "---       Build Configuration     ---")
  message (STATUS "-------------------------------------")
  message (STATUS "Modules to build .................. : ${PROJ_ALL_MOD_FOR_BLD}")
  message (STATUS "Libraries to build/install ........ : ${PROJ_ALL_LIB_TARGETS}")
  message (STATUS "Binaries to build/install ......... : ${PROJ_ALL_BIN_TARGETS}")
  message (STATUS "Test suites to check .............. : ${PROJ_ALL_SUITES_FOR_TST}")
  message (STATUS "Binaries to test .................. : ${PROJ_ALL_TST_TARGETS}")
  display_status_all_modules ()
  display_status_all_test_suites ()
  message (STATUS)
  message (STATUS "BUILD_SHARED_LIBS ................. : ${BUILD_SHARED_LIBS}")
  message (STATUS "CMAKE_BUILD_TYPE .................. : ${CMAKE_BUILD_TYPE}")
  message (STATUS " * CMAKE_C_FLAGS .................. : ${CMAKE_C_FLAGS}")
  message (STATUS " * CMAKE_CXX_FLAGS ................ : ${CMAKE_CXX_FLAGS}")
  message (STATUS " * BUILD_FLAGS .................... : ${BUILD_FLAGS}")
  message (STATUS " * COMPILE_FLAGS .................. : ${COMPILE_FLAGS}")
  message (STATUS "ENABLE_TEST ....................... : ${ENABLE_TEST}" )
  message (STATUS "CMAKE_MODULE_PATH ................. : ${CMAKE_MODULE_PATH}")
  message (STATUS "CMAKE_INSTALL_PREFIX .............. : ${CMAKE_INSTALL_PREFIX}")
  message (STATUS)
  message (STATUS "-------------------------------------")
  message (STATUS "---  Installation Configuration   ---")
  message (STATUS "-------------------------------------")
  message (STATUS "INSTALL_LIB_DIR ................... : ${INSTALL_LIB_DIR}")
  message (STATUS "INSTALL_BIN_DIR ................... : ${INSTALL_BIN_DIR}")
  message (STATUS "CMAKE_INSTALL_RPATH ............... : ${CMAKE_INSTALL_RPATH}")
  message (STATUS "CMAKE_INSTALL_RPATH_USE_LINK_PATH . : ${CMAKE_INSTALL_RPATH_USE_LINK_PATH}")
  message (STATUS "INSTALL_INCLUDE_DIR ............... : ${INSTALL_INCLUDE_DIR}")
  message (STATUS "INSTALL_DATA_DIR .................. : ${INSTALL_DATA_DIR}")
  message (STATUS)
  message (STATUS "-------------------------------------")
  message (STATUS "---    Packaging Configuration    ---")
  message (STATUS "-------------------------------------")
  message (STATUS "CPACK_PACKAGE_CONTACT ............. : ${CPACK_PACKAGE_CONTACT}")
  message (STATUS "CPACK_PACKAGE_VENDOR .............. : ${CPACK_PACKAGE_VENDOR}")
  message (STATUS "CPACK_PACKAGE_VERSION ............. : ${CPACK_PACKAGE_VERSION}")
  message (STATUS "CPACK_PACKAGE_DESCRIPTION_FILE .... : ${CPACK_PACKAGE_DESCRIPTION_FILE}")
  message (STATUS "CPACK_RESOURCE_FILE_LICENSE ....... : ${CPACK_RESOURCE_FILE_LICENSE}")
  message (STATUS "CPACK_GENERATOR ................... : ${CPACK_GENERATOR}")
  message (STATUS "CPACK_DEBIAN_PACKAGE_DEPENDS ...... : ${CPACK_DEBIAN_PACKAGE_DEPENDS}")
  message (STATUS "CPACK_SOURCE_GENERATOR ............ : ${CPACK_SOURCE_GENERATOR}")
  message (STATUS "CPACK_SOURCE_PACKAGE_FILE_NAME .... : ${CPACK_SOURCE_PACKAGE_FILE_NAME}")
  #
  message (STATUS)
  message (STATUS "------------------------------------")
  message (STATUS "---      External libraries      ---")
  message (STATUS "------------------------------------")
  #
  display_boost ()
  display_combase ()
  display_randgen ()
  #
  message (STATUS)
  message (STATUS "Change a value with: cmake -D<Variable>=<Value>" )
  message (STATUS "=============================================================")
  message (STATUS)

endmacro (display_status)
