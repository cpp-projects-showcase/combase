/*!
 * \page ComBase_cpp Command-Line Test to Demonstrate How To Extend ComBase BOM
 * \code
 */
// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// STL
#include <sstream>
#include <fstream>
#include <string>
// Boost Unit Test Framework (UTF)
#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MAIN
#define BOOST_TEST_MODULE CombaseTest
#include <boost/test/unit_test.hpp>
// ComBase
#include <combase/combase.hpp>
// ComBase-related Test
#include <test/combase/MPBom.hpp>

namespace boost_utf = boost::unit_test;

// (Boost) Unit Test XML Report
std::ofstream utfReportStream ("ComBase_utfresults.xml");

/**
 * Configuration for the Boost Unit Test Framework (UTF)
 */
struct UnitTestConfig {
  /** Constructor. */
  UnitTestConfig() {
    boost_utf::unit_test_log.set_stream (utfReportStream);
    boost_utf::unit_test_log.set_format (boost_utf::XML);
    boost_utf::unit_test_log.set_threshold_level (boost_utf::log_test_units);
    // boost_utf::unit_test_log.set_threshold_level (boost_utf::log_successful_tests);
  }

  /** Destructor. */
  ~UnitTestConfig() {
  }
};


// /////////////// Main: Unit Test Suite //////////////

// Set the UTF configuration (re-direct the output to a specific file)
BOOST_GLOBAL_FIXTURE (UnitTestConfig);

// Start the test suite
BOOST_AUTO_TEST_SUITE (master_test_suite)

/**
 * Test the comparison of two floating point numbers, first the Boost way,
 * then the Google way.
 */
BOOST_AUTO_TEST_CASE (simple_bom_test) {
  //
  const myprovider::Bom lBom;
  //
  const std::string& lDescription = lBom.describe();

  // Test the Boost way
  BOOST_CHECK_MESSAGE (lDescription == "MyProvider::BOM",
                       "The object description is not as expected");
}

// End the test suite
BOOST_AUTO_TEST_SUITE_END()

/*!
 * \endcode
 */
