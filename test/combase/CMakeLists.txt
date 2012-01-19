#
# ComBase Tests
#

##
# Specify each test suite configuration

# * Combase Test Suite
file (GLOB combasetest_SOURCES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.cpp)
module_test_add_suite (combase CombaseTest "${combasetest_SOURCES}")


##
# Register all the test suites to be built and performed
module_test_build_all ()

