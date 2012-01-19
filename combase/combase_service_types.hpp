#ifndef __COMBASE_COMBASE_SERVICE_HPP
#define __COMBASE_COMBASE_SERVICE_HPP

// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// Boost (Extended STL)
#include <boost/shared_ptr.hpp>

namespace combase {

  // Forward declarations
  class COMBASE_Service;

  /** Pointer on the COMBASE Service handler. */
  typedef boost::shared_ptr<COMBASE_Service> COMBASE_ServicePtr_T;

}
#endif // __COMBASE_COMBASE_SERVICE_HPP
