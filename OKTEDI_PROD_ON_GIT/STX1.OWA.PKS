CREATE OR REPLACE package STX1.OWA as
--
  /*
  ** Global types
  */
  type VCTAB  is table of varchar2(32767) index by binary_integer;
  type NMTAB  is table of number index by binary_integer;
  type RAWTAB is table of raw(256) index by binary_integer;
  type VC_ARR is table of varchar2(32767) index by binary_integer;
--
  /*
  ** Public package globals
  */
  PROTECTION_REALM  varchar2(255);
  USER_ID           varchar2(255);
  PASSWORD          varchar2(255);
  IP_ADDRESS        NMTAB;
  HOSTNAME          varchar2(255);
--
  function AUTHORIZE return boolean;
--
  /*
  ** Initialize CGI variables
  */
  procedure INIT_CGI_ENV(NPARAMS in number,
                         PNAMES  in VCTAB,
                         PVALS   in VCTAB);
--  procedure INIT_CGI_ENV(NPARAMS in number,
--                         PNAMES  in VC_ARR ,
--                         PVALS   in VC_ARR );
  procedure init_cgi_env (param_val  in vc_arr);
--
  /*
  ** Set username and password
  */
  procedure SET_USER_ID(USR in varchar2);
  procedure SET_PASSWORD(PWD in varchar2);
--
  /*
  ** Return content
  */
  function  GET_LINE(NROWS out integer) return varchar2;
  procedure GET_PAGE(PAGEBUF out VCTAB, NROWS in out integer);
  procedure GET_PAGE_RAW(PAGEBUF out RAWTAB, NROWS in out integer);
  procedure ENABLE_RAW_MODE;
--
  /*
  ** Misc. functions
  */
  procedure SET_CHARSET(IANA_CS in varchar2);
  function  PARSE_COOKIES(NAMES out VCTAB, VALS out VCTAB) return number;
  function  GET_CGI_ENV(PARAM in varchar2) return varchar2;
  procedure PUTRAW(RAWBUF in raw, BUFLEN in number default NULL);
  procedure PUTSTR(CBUF in varchar2);
  procedure PRN(CBUF in varchar2 default null);
  procedure PRINT(CBUF in varchar2 default null);
  procedure INIT;
  function INITIALIZE return integer;
  procedure print_cgi_env;
  procedure CLOSE_PAGE;
--
end OWA;
/
