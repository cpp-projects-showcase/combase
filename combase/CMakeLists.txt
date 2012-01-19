##
# ComBase module
module_set_name (combase)

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
module_library_add_standard (".")

##
# Install the CMake import helper, so that third party projects can refer to it
# (for libraries, header files and binaries)
module_export_install ()
