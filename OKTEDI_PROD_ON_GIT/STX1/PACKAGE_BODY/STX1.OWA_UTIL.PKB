CREATE OR REPLACE package body STX1.OWA_UTIL as

   DB_CHARSET  constant varchar2(30)  :=  substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'), '.') + 1);
   NL_CHAR     constant varchar2(10) := convert(CHR(10),DB_CHARSET,'US7ASCII');

	--
  function GET_CGI_ENV(PARAM in varchar2) return varchar2 is
  begin
    return(OWA.GET_CGI_ENV(PARAM));
  end GET_CGI_ENV;
--
  function GET_OWA_SERVICE_PATH return varchar2 is
    SCRIPT_NAME varchar2(4000);
  begin
    SCRIPT_NAME := OWA.GET_CGI_ENV('SCRIPT_NAME');
    if (SCRIPT_NAME is not null) then
      if (substr(SCRIPT_NAME, length(SCRIPT_NAME) - 1) <> '/') then
        return(SCRIPT_NAME||'/');
      end if;
    end if;
    return(SCRIPT_NAME);
  end GET_OWA_SERVICE_PATH;
--
  function RESOLVE_NAME(PNAME in varchar2) return varchar2 is
    PART1   varchar2(100);
    PART2   varchar2(100);
    OWNER   varchar2(100);
    DBLINK  varchar2(100);
    RNAME   varchar2(100);
    PTYPE   number;
    OBJNUM  number;
  begin
    /*
    ** ### THIS CODE IS WRONG, BUT KEPT FOR REFERENCE.  THE PROBLEM
    ** ### IS THAT THIS RUNS AS THE INSTALLATION USER FOR THE OWA.
    ** ### THUS, IT WILL WORK CORRECTLY ONLY FOR PUBLIC SYNONYMS OR
    ** ### IF THE APPLICATION IS INSTALLED IN THE SAME SCHEMA AS
    ** ### THE OWA.  NEED TO RUN THIS FUNCTION WITH INVOKER'S RIGHTS.
    */
    DBMS_UTILITY.NAME_RESOLVE(PNAME, 1, OWNER, PART1, PART2,
                              DBLINK, PTYPE, OBJNUM);
    if (PART2 is null) then
      RNAME := PART1;
    elsif (PTYPE in (7,8)) then
      RNAME := PART2;
    else
      RNAME := PART1||'.'||PART2;
    end if;
    return(RNAME);
  exception when OTHERS then
    return(upper(PNAME));
  end RESOLVE_NAME;
--
  function GET_PROCEDURE return varchar2 is
    PATH_INFO  varchar2(4000);
  begin
    PATH_INFO := OWA.GET_CGI_ENV('PATH_INFO');
    if (substr(PATH_INFO, 1, 1) = '/') then
      PATH_INFO := substr(PATH_INFO, 2);
    end if;
    -- ### SHOULD USE RESOLVE_NAME() BUT DOESN'T WORK YET
    return(upper(PATH_INFO));
  end GET_PROCEDURE;
--
  procedure MIME_HEADER(ccontent_type  in varchar2 default null,
                        bclose_header in boolean  default true,
                        CCHARSET   in varchar2 default null /* Magic? */) is
    CHARSET  varchar2(4000);
    MIMETYPE varchar2(4000);

  begin
    if (ccontent_type is null) then
      MIMETYPE := 'text/html';
    else
      MIMETYPE := ccontent_type;
    end if;
    if (CCHARSET is null) then
      if (upper(MIMETYPE) like 'TEXT/%') then
        CHARSET := GET_CGI_ENV('REQUEST_IANA_CHARSET');
      else
        CHARSET := CCHARSET;
      end if;
    end if;
    if (CHARSET is null) then
      OWA.PRN('Content-Type: '||MIMETYPE||NL_CHAR);
    else
      OWA.SET_CHARSET(CHARSET);
      OWA.PRN('Content-Type: '||MIMETYPE||'; charset='||CHARSET||NL_CHAR);
    end if;
    if (bclose_header) then
      HTTP_HEADER_CLOSE;
    end if;
  end MIME_HEADER;
--
  procedure REDIRECT_URL(TARGET_URL in varchar2,
                         CLOSE_FLAG in boolean default true) is
  begin
    OWA.PRN('Location: '||TARGET_URL||NL_CHAR);
    if (CLOSE_FLAG) then
      HTTP_HEADER_CLOSE;
    end if;
  end REDIRECT_URL;
--
  procedure STATUS_LINE(STATUS     in integer,
                        REASON     in varchar2 default null,
                        CLOSE_FLAG in boolean default true) is
  begin
    OWA.PRINT('Status: '||STATUS||' '||REASON);
    if (CLOSE_FLAG) then
      HTTP_HEADER_CLOSE;
    end if;
  end STATUS_LINE;
--
  procedure HTTP_HEADER_CLOSE is
  begin
    OWA.PRN(''||NL_CHAR);
  end HTTP_HEADER_CLOSE;
--
   procedure print_cgi_env is
   begin
    owa.print_cgi_env;
   end;

end OWA_UTIL;
/
