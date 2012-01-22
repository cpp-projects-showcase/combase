/**
 * @brief Very basic component
 * @author Denis Arnaud <denis.arnaud_fedora@m4x.org>
 * @date 19-JAN-2012
 * @license GPLv3
 */
#ifndef __COMBASE_COMBASE_HPP
#define __COMBASE_COMBASE_HPP

// //////////////////////////////////////////////////////////////////////
// Import section
// //////////////////////////////////////////////////////////////////////
// STL
#include <iosfwd>
#include <string>

namespace combase {

  /**
   * @brief Base class for the Business Object Model (BOM).
   */
  class BomAbstract {
  public:
    // /////////////// Display Support Methods //////////////
    /**
     * Dump a Business Object into an output stream.
     *
     * @param ostream& the output stream.
     */
    void toStream (std::ostream& ioOut) const {
      ioOut << describe();
    }

    /**
     * Read a Business Object from an input stream.
     *
     * @param istream& the input stream.
     */
    virtual void fromStream (std::istream& ioIn) {}

    /**
     * Display of the structure.
     */
    virtual const std::string describe() const = 0;


  public:
    // ////////////////// Initialisation and Destruction ///////////////////
    /**
     * Default Constructor.
     */
    BomAbstract() {}

    /**
     * Destructor.
     */
    virtual ~BomAbstract() {}
  };
}

/**
 * Piece of code given by Nicolai M. Josuttis, Section 13.12.1 "Implementing
 * Output Operators" (p653) of his book "The C++ Standard Library: A Tutorial
 * and Reference", published by Addison-Wesley.
 */
template <class charT, class traits>
inline
std::basic_ostream<charT, traits>&
operator<< (std::basic_ostream<charT, traits>& ioOut,
            const combase::BomAbstract& iStruct) {
  /**
   * string stream:
   * - with same format
   * - without special field width
   */
  std::basic_ostringstream<charT,traits> ostr;
  ostr.copyfmt (ioOut);
  ostr.width (0);

  // Fill string stream
  iStruct.toStream (ostr);

  // Print string stream
  ioOut << ostr.str();

  return ioOut;
}

/**
 * Piece of code given by Nicolai M. Josuttis, Section 13.12.1 "Implementing
 * Output Operators" (pp655-657) of his book "The C++ Standard Library:
 * A Tutorial and Reference", published by Addison-Wesley.
 */
template <class charT, class traits>
inline
std::basic_istream<charT, traits>&
operator>> (std::basic_istream<charT, traits>& ioIn,
            combase::BomAbstract& ioStruct) {
  // Fill the Structure object with the input stream.
  ioStruct.fromStream (ioIn);
  return ioIn;
}

#endif // __COMBASE_COMBASE_HPP
