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
// Boost MPL
#include <boost/mpl/push_back.hpp>
#include <boost/mpl/vector.hpp>
#include <boost/mpl/at.hpp>
#include <boost/mpl/assert.hpp>
#include <boost/type_traits/is_same.hpp>
// Boost Unit Test Framework (UTF)
#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MAIN
#define BOOST_TEST_MODULE CombaseTest
#include <boost/test/unit_test.hpp>
// Boost Serialisation
#include <boost/archive/text_oarchive.hpp>
#include <boost/archive/text_iarchive.hpp>
// Combase
#include <combase/combase_inventory_types.hpp>
#include <combase/service/Logger.hpp>
#include <combase/COMBASE_Service.hpp>
#include <combase/basic/float_utils.hpp>
#include <combase/bom/BomDisplay.hpp>
#include <combase/bom/BomRoot.hpp>
#include <combase/bom/BomManager.hpp>
#include <combase/factory/FacBom.hpp>
#include <combase/factory/FacBomManager.hpp>
// Combase Test Suite
#include <test/combase/CombaseTestLib.hpp>
#include <test/combase/MPInventory.hpp>

namespace boost_utf = boost::unit_test;

// (Boost) Unit Test XML Report
std::ofstream utfReportStream ("StandardAirlineITTestSuite_utfresults.xml");

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
BOOST_AUTO_TEST_CASE (float_comparison_test) {
  float a = 0.2f;
  a = 5*a;
  const float b = 1.0f;

  // Test the Boost way
  BOOST_CHECK_MESSAGE (a == b, "The two floats (" << a << " and " << b
                       << ") should be equal, but are not");
  BOOST_CHECK_CLOSE (a, b, 0.0001);

  // Test the Google way
  const FloatingPoint<float> lhs (a), rhs (b);
  BOOST_CHECK_MESSAGE (lhs.AlmostEquals (rhs),
                       "The two floats (" << a << " and " << b
                       << ") should be equal, but are not");
}

/**
 * Test MPL-based type handling, just as a proof-of-concept. It does
 * not use Combase BOM.
 */
BOOST_AUTO_TEST_CASE (mpl_structure_test) {
  const combase::ClassCode_T lBookingClassCodeA ("A");
  const combase_test::BookingClass lA (lBookingClassCodeA);
  const combase_test::Cabin lCabin (lA);

  BOOST_CHECK_EQUAL (lCabin.toString(), lBookingClassCodeA);
  BOOST_CHECK_MESSAGE (lCabin.toString() == lBookingClassCodeA,
                       "The cabin key, '" << lCabin.toString()
                       << "' is not equal to '" << lBookingClassCodeA << "'");

  // MPL
  typedef boost::mpl::vector<combase_test::BookingClass> MPL_BookingClass;
  typedef boost::mpl::push_back<MPL_BookingClass,
                                combase_test::Cabin>::type types;
  
  if (boost::is_same<combase_test::BookingClass,
                     combase_test::Cabin::child>::value == false) {
    BOOST_ERROR ("The two types mut be equal, but are not");
  }
  
  if (boost::is_same<boost::mpl::at_c<types, 1>::type,
                     combase_test::Cabin>::value == false) {
    BOOST_ERROR ("The type must be combase_test::Cabin, but is not");
  }
}

/**
 * Test the initialisation of the Standard Airline IT base library.
 */
BOOST_AUTO_TEST_CASE (combase_service_initialisation_test) {
  // Output log File
  const std::string lLogFilename ("StandardAirlineITTestSuite_init.log");
    
  // Set the log parameters
  std::ofstream logOutputFile;
  
  // Open and clean the log outputfile
  logOutputFile.open (lLogFilename.c_str());
  logOutputFile.clear();
  
  // Initialise the combase BOM
  const combase::BasLogParams lLogParams (combase::LOG::DEBUG, logOutputFile);
  combase::COMBASE_Service combaseService (lLogParams);

  // Retrieve (a reference on) the top of the BOM tree
  combase::BomRoot& lBomRoot = combaseService.getBomRoot();

  // Retrieve the BomRoot key, and compare it to the expected one
  const std::string& lBomRootKeyStr = lBomRoot.describeKey();
  const std::string lBomRootString (" -- ROOT -- ");

  // DEBUG
  COMBASE_LOG_DEBUG ("The BOM root key is '" << lBomRootKeyStr
                    << "'. It should be equal to '" << lBomRootString << "'");
  
  BOOST_CHECK_EQUAL (lBomRootKeyStr, lBomRootString);
  BOOST_CHECK_MESSAGE (lBomRootKeyStr == lBomRootString,
                       "The BOM root key, '" << lBomRootKeyStr
                       << "', should be equal to '" << lBomRootString
                       << "', but is not.");

  // Build a sample BOM tree
  combaseService.buildSampleBom();

  // DEBUG: Display the whole BOM tree
  const std::string& lCSVDump = combaseService.csvDisplay();
  COMBASE_LOG_DEBUG (lCSVDump);

  // Close the Log outputFile
  logOutputFile.close();
}

/**
 * Test the initialisation of Standard Airline IT BOM objects.
 */
BOOST_AUTO_TEST_CASE (bom_structure_instantiation_test) {
  // Step 0.0: initialisation
  // Create the root of the Bom tree (i.e., a BomRoot object)
  combase::BomRoot& lBomRoot =
    combase::FacBom<combase::BomRoot>::instance().create();
        
  // Step 0.1: Inventory level
  // Create an Inventory (BA)
  const combase::AirlineCode_T lBAAirlineCode ("BA");
  const combase::InventoryKey lBAKey (lBAAirlineCode);
  myprovider::Inventory& lBAInv =
    combase::FacBom<myprovider::Inventory>::instance().create (lBAKey);
  combase::FacBomManager::addToList (lBomRoot, lBAInv);

  BOOST_CHECK_EQUAL (lBAInv.describeKey(), lBAAirlineCode);
  BOOST_CHECK_MESSAGE (lBAInv.describeKey() == lBAAirlineCode,
                       "The inventory key, '" << lBAInv.describeKey()
                       << "', should be equal to '" << lBAAirlineCode
                       << "', but is not");

  // Create an Inventory for AF
  const combase::AirlineCode_T lAFAirlineCode ("AF");
  const combase::InventoryKey lAFKey (lAFAirlineCode);
  myprovider::Inventory& lAFInv =
    combase::FacBom<myprovider::Inventory>::instance().create (lAFKey);
  combase::FacBomManager::addToList (lBomRoot, lAFInv);

  BOOST_CHECK_EQUAL (lAFInv.describeKey(), lAFAirlineCode);
  BOOST_CHECK_MESSAGE (lAFInv.describeKey() == lAFAirlineCode,
                       "The inventory key, '" << lAFInv.describeKey()
                       << "', should be equal to '" << lAFAirlineCode
                       << "', but is not");
  
  // Browse the inventories
  const myprovider::InventoryList_T& lInventoryList =
      combase::BomManager::getList<myprovider::Inventory> (lBomRoot);
  const std::string lInventoryKeyArray[2] = {lBAAirlineCode, lAFAirlineCode};
  short idx = 0;
  for (myprovider::InventoryList_T::const_iterator itInv =
         lInventoryList.begin(); itInv != lInventoryList.end();
       ++itInv, ++idx) {
    const myprovider::Inventory* lInv_ptr = *itInv;
    BOOST_REQUIRE (lInv_ptr != NULL);
    
    BOOST_CHECK_EQUAL (lInventoryKeyArray[idx], lInv_ptr->describeKey());
    BOOST_CHECK_MESSAGE (lInventoryKeyArray[idx] == lInv_ptr->describeKey(),
                         "They inventory key, '" << lInventoryKeyArray[idx]
                         << "', does not match that of the Inventory object: '"
                         << lInv_ptr->describeKey() << "'");
  }
}

/**
 * Test the serialisation of Standard Airline IT BOM objects.
 */
BOOST_AUTO_TEST_CASE (bom_structure_serialisation_test) {

  // Backup (thanks to Boost.Serialisation) file
  const std::string lBackupFilename = "StandardAirlineITTestSuite_serial.txt";

  // Output log File
  const std::string lLogFilename ("StandardAirlineITTestSuite_serial.log");
    
  // Set the log parameters
  std::ofstream logOutputFile;
  
  // Open and clean the log outputfile
  logOutputFile.open (lLogFilename.c_str());
  logOutputFile.clear();
  
  // Initialise the combase BOM
  const combase::BasLogParams lLogParams (combase::LOG::DEBUG, logOutputFile);
  combase::COMBASE_Service combaseService (lLogParams);

  // Build a sample BOM tree
  combaseService.buildSampleBom();

  // DEBUG: Display the whole BOM tree
  const std::string& lCSVDump = combaseService.csvDisplay();
  COMBASE_LOG_DEBUG (lCSVDump);

  // Retrieve (a reference on) the top of the BOM tree
  combase::BomRoot& lBomRoot = combaseService.getBomRoot();

  // Retrieve the BomRoot key, and compare it to the expected one
  const std::string lBAInvKeyStr ("BA");
  combase::Inventory* lBAInv_ptr = lBomRoot.getInventory (lBAInvKeyStr);

  // DEBUG
  COMBASE_LOG_DEBUG ("There should be an Inventory object corresponding to the '"
                    << lBAInvKeyStr << "' key.");

  BOOST_REQUIRE_MESSAGE (lBAInv_ptr != NULL,
                         "An Inventory object should exist with the key, '"
                         << lBAInvKeyStr << "'.");

  // create and open a character archive for output
  std::ofstream ofs (lBackupFilename.c_str());

  // save data to archive
  {
    boost::archive::text_oarchive oa (ofs);
    // write class instance to archive
    oa << lBomRoot;
    // archive and stream closed when destructors are called
  }

  // ... some time later restore the class instance to its orginal state
  combase::BomRoot& lRestoredBomRoot =
    combase::FacBom<combase::BomRoot>::instance().create();
  {
    // create and open an archive for input
    std::ifstream ifs (lBackupFilename.c_str());
    boost::archive::text_iarchive ia(ifs);
    // read class state from archive
    ia >> lRestoredBomRoot;
    // archive and stream closed when destructors are called
  }
  
  // DEBUG: Display the whole BOM tree
  std::ostringstream oRestoredCSVDumpStr;
  combase::BomDisplay::csvDisplay (oRestoredCSVDumpStr, lRestoredBomRoot);
  COMBASE_LOG_DEBUG (oRestoredCSVDumpStr.str());

  // Retrieve the BomRoot key, and compare it to the expected one
  const std::string& lBomRootKeyStr = lRestoredBomRoot.describeKey();
  const std::string lBomRootString (" -- ROOT -- ");

  // DEBUG
  COMBASE_LOG_DEBUG ("The BOM root key is '" << lBomRootKeyStr
                    << "'. It should be equal to '" << lBomRootString << "'");
  
  BOOST_CHECK_EQUAL (lBomRootKeyStr, lBomRootString);
  BOOST_CHECK_MESSAGE (lBomRootKeyStr == lBomRootString,
                       "The BOM root key, '" << lBomRootKeyStr
                       << "', should be equal to '" << lBomRootString
                       << "', but is not.");

  // Retrieve the Inventory
  combase::Inventory* lRestoredBAInv_ptr =
    lRestoredBomRoot.getInventory (lBAInvKeyStr);

  // DEBUG
  COMBASE_LOG_DEBUG ("There should be an Inventory object corresponding to the '"
                    << lBAInvKeyStr << "' key.");

  BOOST_CHECK_MESSAGE (lRestoredBAInv_ptr != NULL,
                       "An Inventory object should exist with the key, '"
                       << lBAInvKeyStr << "'.");

  // Close the Log outputFile
  logOutputFile.close();
}

// End the test suite
BOOST_AUTO_TEST_SUITE_END()

/*!
 * \endcode
 */
