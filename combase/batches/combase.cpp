/*!
 * \page batch_combase_cpp Command-Line Utility to Demonstrate Typical Combase Usage
 * \code
 */
// STL
#include <cassert>
#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
// Boost (Extended STL)
#include <boost/date_time/posix_time/posix_time.hpp>
#include <boost/date_time/gregorian/gregorian.hpp>
#include <boost/program_options.hpp>
#include <boost/tokenizer.hpp>
#include <boost/lexical_cast.hpp>
// Combase
#include <combase/combase_types.hpp>
#include <combase/service/Logger.hpp>
#include <combase/combase_service.hpp>
#include <combase/config/combase-paths.hpp>

// //////// Constants //////
/**
 * Default name and location for the log file.
 */
const std::string K_COMBASE_DEFAULT_LOG_FILENAME ("combase.log");

/**
 * Default name and location for the (CSV) input file.
 */
const std::string K_COMBASE_DEFAULT_INPUT_FILENAME (COMBASE_SAMPLE_DIR
                                                   "/schedule01.csv");

/**
 * Default for the input type. It can be either built-in or provided by an
 * input file. That latter must then be given with the -i option.
 */
const bool K_COMBASE_DEFAULT_BUILT_IN_INPUT = false;

/**
 * Default for the RMOL sample BOM tree. If that sample BOM tree is
 * chosen to be built, no other BOM tree (either built-in or parsed
 * from an input file) will be built.
 */
const bool K_COMBASE_DEFAULT_BUILT_FOR_RMOL = false;

/**
 * Default for the CRS sample BOM tree. If that sample BOM tree is
 * chosen to be built, no other BOM tree (either built-in or parsed
 * from an input file) will be built.
 */
const bool K_COMBASE_DEFAULT_BUILT_FOR_CRS = false;

/**
 * Early return status (so that it can be differentiated from an
 * error).
 */
const int K_COMBASE_EARLY_RETURN_STATUS = 99;

// ///////// Parsing of Options & Configuration /////////
// A helper function to simplify the main part.
template<class T> std::ostream& operator<< (std::ostream& os,
                                            const std::vector<T>& v) {
  std::copy (v.begin(), v.end(), std::ostream_iterator<T> (std::cout, " ")); 
  return os;
}

/** Read and parse the command line options. */
int readConfiguration (int argc, char* argv[], bool& ioIsBuiltin,
                       bool& ioIsForRMOL, bool& ioIsForCRS,
                       combase::Filename_T& ioInputFilename,
                       std::string& ioLogFilename) {
  // Default for the built-in input
  ioIsBuiltin = K_COMBASE_DEFAULT_BUILT_IN_INPUT;

  // Default for the RMOL input
  ioIsForRMOL = K_COMBASE_DEFAULT_BUILT_FOR_RMOL;
  
  // Default for the CRS input
  ioIsForCRS = K_COMBASE_DEFAULT_BUILT_FOR_CRS;
  
  // Declare a group of options that will be allowed only on command line
  boost::program_options::options_description generic ("Generic options");
  generic.add_options()
    ("prefix", "print installation prefix")
    ("version,v", "print version string")
    ("help,h", "produce help message");
    
  // Declare a group of options that will be allowed both on command
  // line and in config file

  boost::program_options::options_description config ("Configuration");
  config.add_options()
    ("builtin,b",
     "The sample BOM tree can be either built-in or parsed from an input file. That latter must then be given with the -i/--input option")
    ("rmol,r",
     "Build a sample BOM tree for RMOL (i.e., a dummy flight-date with a single leg-cabin)")
    ("crs,c",
     "Build a sample BOM tree for CRS")
    ("input,i",
     boost::program_options::value< std::string >(&ioInputFilename)->default_value(K_COMBASE_DEFAULT_INPUT_FILENAME),
     "(CVS) input file for the demand distributions")
    ("log,l",
     boost::program_options::value< std::string >(&ioLogFilename)->default_value(K_COMBASE_DEFAULT_LOG_FILENAME),
     "Filename for the logs")
    ;

  // Hidden options, will be allowed both on command line and
  // in config file, but will not be shown to the user.
  boost::program_options::options_description hidden ("Hidden options");
  hidden.add_options()
    ("copyright",
     boost::program_options::value< std::vector<std::string> >(),
     "Show the copyright (license)");
        
  boost::program_options::options_description cmdline_options;
  cmdline_options.add(generic).add(config).add(hidden);

  boost::program_options::options_description config_file_options;
  config_file_options.add(config).add(hidden);
  boost::program_options::options_description visible ("Allowed options");
  visible.add(generic).add(config);
        
  boost::program_options::positional_options_description p;
  p.add ("copyright", -1);
        
  boost::program_options::variables_map vm;
  boost::program_options::
    store (boost::program_options::command_line_parser (argc, argv).
           options (cmdline_options).positional(p).run(), vm);

  std::ifstream ifs ("combase.cfg");
  boost::program_options::store (parse_config_file (ifs, config_file_options),
                                 vm);
  boost::program_options::notify (vm);
    
  if (vm.count ("help")) {
    std::cout << visible << std::endl;
    return K_COMBASE_EARLY_RETURN_STATUS;
  }

  if (vm.count ("version")) {
    std::cout << PACKAGE_NAME << ", version " << PACKAGE_VERSION << std::endl;
    return K_COMBASE_EARLY_RETURN_STATUS;
  }

  if (vm.count ("prefix")) {
    std::cout << "Installation prefix: " << PREFIXDIR << std::endl;
    return K_COMBASE_EARLY_RETURN_STATUS;
  }

  if (vm.count ("builtin")) {
    ioIsBuiltin = true;
  }

  if (vm.count ("rmol")) {
    ioIsForRMOL = true;

    // The RMOL sample tree takes precedence over the default built-in BOM tree
    ioIsBuiltin = false;
  }

  if (vm.count ("crs")) {
    ioIsForCRS = true;

    // The RMOL sample tree takes precedence over the default built-in BOM tree
    ioIsBuiltin = false;
  }

  const std::string isBuiltinStr = (ioIsBuiltin == true)?"yes":"no";
  std::cout << "The BOM should be built-in? " << isBuiltinStr << std::endl;

  const std::string isForRMOLStr = (ioIsForRMOL == true)?"yes":"no";
  std::cout << "The BOM should be built-in for RMOL? " << isForRMOLStr
            << std::endl;

  const std::string isForCRSStr = (ioIsForCRS == true)?"yes":"no";
  std::cout << "The BOM should be built-in for CRS? " << isForCRSStr
            << std::endl;

  if (ioIsBuiltin == false && ioIsForRMOL == false && ioIsForCRS == false) {
    if (vm.count ("input")) {
      ioInputFilename = vm["input"].as< std::string >();
      std::cout << "Input filename is: " << ioInputFilename << std::endl;

    } else {
      std::cerr << "Either one among the -b/--builtin, -r/--rmol, -c/--crs "
                << "or -i/--input options must be specified" << std::endl;
    }
  }

  if (vm.count ("log")) {
    ioLogFilename = vm["log"].as< std::string >();
    std::cout << "Log filename is: " << ioLogFilename << std::endl;
  }

  return 0;
}


// ///////////////// M A I N ////////////////////
int main (int argc, char* argv[]) {

  // State whether the BOM tree should be built-in or parsed from an
  // input file
  bool isBuiltin;

  // State whether a sample BOM tree should be built for RMOL.
  bool isForRMOL;
    
  // State whether a sample BOM tree should be built for the CRS.
  bool isForCRS;
    
  // Input file name
  combase::Filename_T lInputFilename;

  // Output log File
  std::string lLogFilename;
    
  // Call the command-line option parser
  const int lOptionParserStatus =
    readConfiguration (argc, argv, isBuiltin, isForRMOL, isForCRS,
                       lInputFilename, lLogFilename);

  if (lOptionParserStatus == K_COMBASE_EARLY_RETURN_STATUS) {
    return 0;
  }

  // Set the log parameters
  std::ofstream logOutputFile;
  // Open and clean the log outputfile
  logOutputFile.open (lLogFilename.c_str());
  logOutputFile.clear();

  const combase::BasLogParams lLogParams (combase::LOG::DEBUG, logOutputFile);
  combase::COMBASE_Service combaseService (lLogParams);

  // DEBUG
  COMBASE_LOG_DEBUG ("Welcome to combase");

  // Check wether or not a (CSV) input file should be read
  if (isBuiltin == true || isForRMOL == true || isForCRS == true) {

    if (isForRMOL == true) {
      // Build the sample BOM tree for RMOL
      combaseService.buildDummyInventory (300);

    } else if (isForCRS == true) {
      //
      combase::TravelSolutionList_T lTravelSolutionList;
      combaseService.buildSampleTravelSolutions (lTravelSolutionList);

      // Build the sample BOM tree for CRS
      const combase::BookingRequestStruct& lBookingRequest =
        combaseService.buildSampleBookingRequest();

      // DEBUG: Display the travel solution and booking request
      COMBASE_LOG_DEBUG ("Booking request: " << lBookingRequest.display());

      const std::string& lCSVDump =
        combaseService.csvDisplay (lTravelSolutionList);
      COMBASE_LOG_DEBUG (lCSVDump);

    } else {
      assert (isBuiltin == true);

      // Build a sample BOM tree
      combaseService.buildSampleBom();
    }
      
  } else {
    // Read the input file
    //combaseService.readFromInputFile (lInputFilename);

    // DEBUG
    COMBASE_LOG_DEBUG ("Combase will parse " << lInputFilename
                      << " and build the corresponding BOM tree.");
  }

  // DEBUG: Display the whole BOM tree
  const std::string& lCSVDump = combaseService.csvDisplay();
  COMBASE_LOG_DEBUG (lCSVDump);

  // Close the Log outputFile
  logOutputFile.close();

  /*
    Note: as that program is not intended to be run on a server in
    production, it is better not to catch the exceptions. When it
    happens (that an exception is throwned), that way we get the
    call stack.
  */
    
  return 0;	
}

/*!
 * \endcode
 */
