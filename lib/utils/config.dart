class Config{
  static final String BASEURL="http://192.168.1.7:8000";
  static final String ROOTURL="/api";
  static final String LOGINURL=BASEURL+ROOTURL+"/login";
  static final String PRODUCTURL=BASEURL+ROOTURL+"/products";
  static final String CATURL=BASEURL+ROOTURL+"/categories";
  static final String CARTURL=BASEURL+ROOTURL+"/cart";
  static final String CHECKINCARTURL=PRODUCTURL+"/checkincart";
  static final String SEARCHURL=BASEURL+ROOTURL+"/search";
  static final String GETREVIEWSURL=BASEURL+ROOTURL+"/getreviews";
  static final String REVIEWSSURL=BASEURL+ROOTURL+"/reviews";
  static final String TOKENREG=BASEURL+ROOTURL+"/registertoken";
  static final String ADDRESSURL=BASEURL+ROOTURL+"/addresses";
  static final String ADDORDERURL=BASEURL+ROOTURL+"/orders";
  static final String CHECKCOUPANURL=BASEURL+ROOTURL+"/checkcoupan";
}