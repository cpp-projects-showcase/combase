#ifndef __MYPROVIDER_BOM_HPP
#define __MYPROVIDER_BOM_HPP
/*!
 * \page test_archi_root_hpp Specific Implementation of a BOM object
 * \code
 */

// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// STL
#include <string>
// ComBase 
#include <combase/combase.hpp>

namespace myprovider {
  
  /**
   * Class representing the actual functional/business content
   * for the Bom root.
   */
  class Bom : public combase::BomAbstract {
  public:
    // /////////// Display support methods /////////
    /**
     * Get a string describing the object.
     */
    const std::string describe() const {
      return std::string ("MyProvider::BOM");
    }
  
  public:
    /**
     * Destructor.
     */
    ~Bom();
  };
  
}  
/*!
 * \endcode
 */
#endif // __MYPROVIDER_BOM_HPP
