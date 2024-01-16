CREATE OR REPLACE package STX1.OWA_UTIL as
--
  type IDENT_ARR is table of varchar2(30) index by binary_integer;
  type IDENT_NARR is table of nvarchar2(30) index by binary_integer;
  type NUM_ARR is table of number index by binary_integer;
  type IP_ADDRESS is table of integer index by binary_integer;
  type VC_ARR is table of varchar2(32000) index by binary_integer;
  type NC_ARR is table of nvarchar2(16000) index by binary_integer;
  type RAW_ARR is table of raw(32000) index by binary_integer;
--
  function GET_CGI_ENV(PARAM in varchar2) return varchar2;
  function GET_OWA_SERVICE_PATH return varchar2;
  function GET_PROCEDURE return varchar2;
  procedure MIME_HEADER(ccontent_type  in varchar2 default null,
                        bclose_header in boolean default true,
                        CCHARSET   in varchar2 default null /* Magic? */);
  procedure REDIRECT_URL(TARGET_URL in varchar2,
                         CLOSE_FLAG in boolean default true);
  procedure STATUS_LINE(STATUS     in integer,
                        REASON     in varchar2 default null,
                        CLOSE_FLAG in boolean default true);
  procedure HTTP_HEADER_CLOSE;
  procedure print_cgi_env;
--
end OWA_UTIL;
/
