CREATE OR REPLACE package body STX1.OWA as
--
  /*
  ** Private package globals
  */
  NUM_CGI     number := 0;
  CGI_NAMES   VCTAB;
  CGI_VALS    VCTAB;
  --
  NUM_COOKIES number := 0;
  COOK_NAMES  VCTAB;
  COOK_VALS   VCTAB;
  COOKIE_FLAG boolean := false;
  --
  HTBUF       VCTAB;
  HTLASTBUF   varchar2(32767);
  LAST_LEN    number := 0;
  RAW_FLAG    boolean := false;
  HTRAWS      RAWTAB;
  HDR_IDX     number := 0;
  LINES_IN    number := 0;
  LINES_OUT   number := 0;
  CLOSE_FLAG  boolean := false;
  RAW_MAX     constant number := 256;
  HDR_BUF     varchar2(32767);
  --
  NLS_FLAG    boolean := false;
  DB_CHARSET  constant varchar2(30) :=
              substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'), '.') + 1);
  HT_CHARSET  varchar2(30) := null;
  /* ### Use TO_CHAR(UNISTR('\0010')) in 9i ### */
  NL_CHAR     constant varchar2(10) := convert(CHR(10),DB_CHARSET,'US7ASCII');
--
  function AUTHORIZE return boolean is
  begin
    return(FALSE); /* Prevent direct calls to the routines in this package */
  end AUTHORIZE;
--
  procedure ADJUST_FOR_MULTIBYTE is
  begin
    /*
    ** ### THIS IS A REAL HACK, BUT UNTIL substrb() IS FIXED, IT'S
    ** ### NECESSARY TO ADJUST "HTBUF_LEN" FOR THE DATABASE CHARACTER
    ** ### SET.  THE MAIN PROBLEM WITH THIS CODE IS THAT IT HAS A
    ** ### HARD-CODED LIST OF CHARACTER SETS, WHICH IS BY NO MEANS
    ** ### COMPLETE.  CUSTOMERS WILL HAVE TO EXTEND THIS FOR ANY
    ** ### MULTIBYTE CHARACTER-SET NOT COVERED.
    */
    if (DB_CHARSET = 'UTF8') then
      HTP.HTBUF_LEN := floor(HTP.HTBUF_LEN/3);
    elsif (DB_CHARSET in ('AL32UTF8','ZHT32EUC')) then
      HTP.HTBUF_LEN := floor(HTP.HTBUF_LEN/4);
    elsif (DB_CHARSET in ('JA16EUCYEN','JA16SJIS','JA16SJISYEN',
                          'KO16KSC5601','ZHS16CGB231280','ZHS16GBK',
                          'ZHT16BIG5','JA16MACSJIS','JA16VMS')) then
      HTP.HTBUF_LEN := floor(HTP.HTBUF_LEN/2);
    end if;
  end ADJUST_FOR_MULTIBYTE;
--
  procedure SET_CHARSET(IANA_CS in varchar2) is
    LOWER_CS varchar2(256);
  begin
    LOWER_CS := lower(IANA_CS);
    if (LOWER_CS = 'iso-8859-1')      then  HT_CHARSET := 'WE8ISO8859P1';
    elsif (LOWER_CS = 'utf-8')        then  HT_CHARSET := 'UTF8';
    elsif (LOWER_CS = 'windows-1252') then  HT_CHARSET := 'UTF8';
    elsif (LOWER_CS = 'us-ascii')     then  HT_CHARSET := 'US7ASCII';
    elsif (LOWER_CS = 'iso-8859-2')   then  HT_CHARSET := 'EE8ISO8859P2';
    elsif (LOWER_CS = 'iso-8859-3')   then  HT_CHARSET := 'SE8ISO8859P3';
    elsif (LOWER_CS = 'iso-8859-4')   then  HT_CHARSET := 'NEE8ISO8859P4';
    elsif (LOWER_CS = 'iso-8859-5')   then  HT_CHARSET := 'CL8ISO8859P5';
    elsif (LOWER_CS = 'iso-8859-6')   then  HT_CHARSET := 'AR8ISO8859P6';
    elsif (LOWER_CS = 'iso-8859-7')   then  HT_CHARSET := 'EL8ISO8859P7';
    elsif (LOWER_CS = 'iso-8859-8')   then  HT_CHARSET := 'IW8ISO8859P8';
    elsif (LOWER_CS = 'iso-8859-9')   then  HT_CHARSET := 'WE9ISO8859P9';
    elsif (LOWER_CS = 'iso-8859-10')  then  HT_CHARSET := 'NE8ISO8859P10';
    elsif (LOWER_CS = 'shift-jis')    then  HT_CHARSET := 'JA16SJIS';
    elsif (LOWER_CS = 'gb2312')       then  HT_CHARSET := 'ZHS16CGB231280';
    elsif (LOWER_CS = 'gbk')          then  HT_CHARSET := 'ZHS16GBK';
    elsif (LOWER_CS = 'big5')         then  HT_CHARSET := 'ZHT16BIG5';
    elsif (LOWER_CS = 'euc-tw')       then  HT_CHARSET := 'ZHT32EUC';
    elsif (LOWER_CS = 'tis-620')      then  HT_CHARSET := 'TH8TISASCII';
    elsif (LOWER_CS = 'windows-1256') then  HT_CHARSET := 'AR8MSAWIN';
    elsif (LOWER_CS = 'windows-1257') then  HT_CHARSET := 'BLT8MSWIN1257';
    elsif (LOWER_CS = 'windows-1251') then  HT_CHARSET := 'CL8MSWIN1251';
    elsif (LOWER_CS = 'windows-1250') then  HT_CHARSET := 'EE8MSWIN1250';
    elsif (LOWER_CS = 'windows-1253') then  HT_CHARSET := 'EL8MSWIN1253';
    elsif (LOWER_CS = 'windows-1255') then  HT_CHARSET := 'IW8MSWIN1255';
    elsif (LOWER_CS = 'windows-1254') then  HT_CHARSET := 'TR8MSWIN1254';
    elsif (LOWER_CS = 'windows-1258') then  HT_CHARSET := 'VN8MSWIN1258';
    elsif (LOWER_CS = 'windows-921')  then  HT_CHARSET := 'LT8MSWIN921';
    else
      HT_CHARSET := DB_CHARSET;
    end if;
  end SET_CHARSET;
--
  procedure INIT_CGI_ENV(NPARAMS in number,
                         PNAMES  in VCTAB,
                         PVALS   in VCTAB) is
  begin
    NUM_CGI := NPARAMS;
    CGI_VALS := PVALS;
    for I in 1..NUM_CGI loop
      CGI_NAMES(I) := upper(PNAMES(I));
    end loop;
    INIT;
  end INIT_CGI_ENV;
  procedure INIT_CGI_ENV(NPARAMS in number,
                         PNAMES  in VC_ARR ,
                         PVALS   in VC_ARR ) is
  begin
    NUM_CGI := NPARAMS;
    cgi_vals.delete;
    if pvals.count > 0
     then
      for j in 1..NUM_CGI loop
       cgi_vals(j) := pvals(j);
      end loop;
    end if;
    for I in 1..NUM_CGI loop
      CGI_NAMES(I) := upper(PNAMES(I));
    end loop;
    INIT;
  end INIT_CGI_ENV;

 procedure init_cgi_env(param_val  in vc_arr)
 as
     num_params number := param_val.count;
     ix         number;
     nameIx     number;
     var_name   vc_arr;
  begin
     /* Initialize cgi names */
     /* Keep this list in the same order as in ndwoa.h file */
     var_name(1) := 'SERVER_SOFTWARE';
     var_name(2) := 'SERVER_NAME';
     var_name(3) := 'GATEWAY_INTERFACE';
     var_name(4) := 'REMOTE_HOST';
     var_name(5) := 'REMOTE_ADDR';
     var_name(6) := 'AUTH_TYPE';
     var_name(7) := 'REMOTE_USER';
     var_name(8) := 'REMOTE_IDENT';
     var_name(9) := 'HTTP_ACCEPT';
     var_name(10) := 'HTTP_USER_AGENT';
     var_name(11) := 'SERVER_PROTOCOL';
     var_name(12) := 'SERVER_PORT';
     var_name(13) := 'SCRIPT_NAME';
     var_name(14) := 'PATH_INFO';
     var_name(15) := 'PATH_TRANSLATED';
     var_name(16) := 'HTTP_REFERER';
     var_name(17) := 'HTTP_COOKIE';

     nameIx := 0;
     ix := 0;
     for i in 1..num_params
     loop
        nameIx := nameIx + 1;
        if (param_val(i) is NOT NULL)
        then
           ix := ix + 1;
           CGI_NAMES(ix)  := var_name(nameIx);
           cgi_vals(ix)  := param_val(i);
        end if;
     end loop;
     NUM_CGI := ix;
   end init_cgi_env;

--
  procedure SET_USER_ID(USR in varchar2) is
  begin
    USER_ID := USR;
  end SET_USER_ID;
--
  procedure SET_PASSWORD(PWD in varchar2) is
  begin
    PASSWORD := PWD;
  end SET_PASSWORD;
--
  procedure PUT(CBUF in varchar2) is
    LOC pls_integer;
    LEN pls_integer;
  begin
    if (CBUF is not null) then
      LEN := length(CBUF);
      if (HDR_IDX > 0) then
        LOC := HTP.HTBUF_LEN - LAST_LEN;
        if (LOC > LEN) then
          LOC := LEN;
        end if;
        if (LOC > 0) then
          HTLASTBUF := HTLASTBUF||substr(CBUF, 1, LOC);
          LAST_LEN := LAST_LEN + LOC;
        end if;
      else
        LOC := 0;
      end if;
      while (LOC < LEN) loop
        HTBUF(LINES_IN) := HTLASTBUF;
        LINES_IN := LINES_IN + 1;
        HTLASTBUF := substr(CBUF, LOC + 1, HTP.HTBUF_LEN);
        LAST_LEN := LEN - LOC;
        LOC := LOC + HTP.HTBUF_LEN;
      end loop;
    end if;
  end PUT;
--
  procedure MARK_HEADER is
  begin
    if (not RAW_FLAG) then
      HTBUF(LINES_IN) := HTLASTBUF;
      HTLASTBUF := '';
      HDR_IDX := LINES_IN;
      LINES_IN := LINES_IN + 1;
    else
      HDR_IDX := LINES_IN;
    end if;
    LAST_LEN := 0;
  end MARK_HEADER;
--
  procedure CLOSE_PAGE is
    LEN pls_integer;
    LOC pls_integer;
    BUF varchar2(255);
  begin
    if (CLOSE_FLAG) then
      return;
    end if;
    if ((HDR_IDX = 0) and (HDR_BUF is not null)) then
      if (RAW_FLAG) then
        PUTSTR(HDR_BUF);
      else
        PUT(HDR_BUF);
      end if;
    end if;
    if ((HTLASTBUF is not null) or (not HTBUF.exists(LINES_IN))) then
      HTBUF(LINES_IN) := HTLASTBUF;
    end if;
    if (LINES_IN > 1) then
      /*
      ** ### WHY BOTHER COMPUTING THE Content-Length HERE?  IT WILL BE
      ** ### WRONG ANYWAY IF A CHARACTER SET CONVERSION OCCURS BETWEEN
      ** ### PL/SQL AND Apache, AND mod_owa WILL RECOMPUTE IT ANYWAY
      ** ### IF YOUR PAGE IS SMALL ENOUGH (LESS THAN ABOUT 200K).
      */
      BUF := '';
      if (HDR_IDX > 0) then
        LOC := HDR_IDX + 1;
        if (RAW_FLAG) then
          LEN := LAST_LEN;
          if (LINES_IN > LOC) then
            LEN := LEN + ((LINES_IN - LOC) * RAW_MAX);
          end if;
        else
          LEN := 0;
          for I in LOC..LINES_IN loop
            LEN := LEN + lengthb(HTBUF(I));
          end loop;
        end if;
        BUF := 'Content-Length: '||to_char(LEN)||NL_CHAR;
      end if;
      if (not RAW_FLAG) then
        HTBUF(1) := BUF;
      elsif (HT_CHARSET = DB_CHARSET) then
        HTRAWS(1) := UTL_RAW.CAST_TO_RAW(BUF);
      else
        HTRAWS(1) := UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(BUF),
                                     'AMERICAN_AMERICA.'||HT_CHARSET,
                                     'AMERICAN_AMERICA.'||DB_CHARSET);
      end if;
    end if;
    CLOSE_FLAG := true;
  end CLOSE_PAGE;
--
  function GET_LINE(NROWS out integer) return varchar2 is
    NLINES number;
  begin
    CLOSE_PAGE;
    NLINES := LINES_IN - LINES_OUT;
    if (NLINES > 1) then
      NROWS := 1;
    else
      NROWS := 0;
      if (NLINES < 1) then
        return(NULL);
      end if;
    end if;
    LINES_OUT := LINES_OUT + 1;
    return(HTBUF(LINES_OUT));
  end GET_LINE;
--
  procedure GET_PAGE(PAGEBUF out VCTAB, NROWS in out integer) is
  begin
    CLOSE_PAGE;
    NROWS := least(NROWS, LINES_IN - LINES_OUT);
    if (NROWS > 0) then
      for I in 1..NROWS loop
        PAGEBUF(I) := HTBUF(LINES_OUT + I);
      end loop;
      LINES_OUT := LINES_OUT + NROWS;
    end if;
  end GET_PAGE;
--
  procedure GET_PAGE_RAW(PAGEBUF out RAWTAB, NROWS in out integer) is
  begin
    CLOSE_PAGE;
    NROWS := least(NROWS, LINES_IN - LINES_OUT);
    if (NROWS > 0) then
      for I in 1..NROWS loop
        PAGEBUF(I) := HTRAWS(LINES_OUT + I);
      end loop;
      LINES_OUT := LINES_OUT + NROWS;
    end if;
  end GET_PAGE_RAW;
--
  procedure ENABLE_RAW_MODE is
  begin
    RAW_FLAG := true;
  end ENABLE_RAW_MODE;
--
  function GET_CGI_ENV(PARAM in varchar2) return varchar2 is
    UPARAM varchar2(4000);
  begin
    UPARAM := upper(PARAM);
    for I in 1..NUM_CGI loop
      if (CGI_NAMES(I) = UPARAM) then
        return(CGI_VALS(I));
      end if;
    end loop;
    return(null);
  end GET_CGI_ENV;
--
  function PARSE_COOKIES(NAMES out VCTAB, VALS out VCTAB) return number is
    BUFFER    varchar2(32767);
    START_LOC pls_integer;
    END_LOC   pls_integer;
    EQ_LOC    pls_integer;
  begin
    if (COOKIE_FLAG) then
      NAMES := COOK_NAMES;
      VALS := COOK_VALS;
      return(NUM_COOKIES);
    end if;
    COOKIE_FLAG := true;
    BUFFER := GET_CGI_ENV('HTTP_COOKIE');
    NUM_COOKIES := 0;
    if (BUFFER is null) then
      return(NUM_COOKIES);
    end if;
    END_LOC := length(BUFFER);
    if (substr(BUFFER, END_LOC, 1) <> ';') then
      BUFFER := BUFFER||';';
    end if;
    START_LOC := 1;
    while (true) loop
      END_LOC := instr(BUFFER, ';', START_LOC);
      EQ_LOC := instr(BUFFER, '=', START_LOC);
      if (EQ_LOC = 0) then
        exit;
      end if;
      NUM_COOKIES := NUM_COOKIES + 1;
      COOK_NAMES(NUM_COOKIES) :=
        ltrim(substr(BUFFER, START_LOC, EQ_LOC-START_LOC));
      COOK_VALS(NUM_COOKIES) := substr(BUFFER, EQ_LOC+1, END_LOC-EQ_LOC-1);
      START_LOC := END_LOC + 1;
      END_LOC := instr(BUFFER, ';', START_LOC);
    end loop;
    NAMES := COOK_NAMES;
    VALS := COOK_VALS;
    return(NUM_COOKIES);
  end PARSE_COOKIES;
--
  procedure PUTRAW(RAWBUF in raw, BUFLEN in number default NULL) is
    BLEN binary_integer;
    BLOC binary_integer;
    BCPY binary_integer;
  begin
    if (RAWBUF is not null) then
      if (BUFLEN is not null) then
        BLEN := BUFLEN;
      else
        BLEN := UTL_RAW.LENGTH(RAWBUF);
      end if;
      if (BLEN > 0) then
        BLOC := 1;
        if (LAST_LEN = 0) then
           LAST_LEN := RAW_MAX;
        end if;
        while (bloc <= blen) loop
          if (LAST_LEN = RAW_MAX) then
            LINES_IN := LINES_IN + 1;
            BCPY := least((BLEN - BLOC) + 1, RAW_MAX);
            HTRAWS(LINES_IN) := UTL_RAW.SUBSTR(RAWBUF, BLOC, BCPY);
            LAST_LEN := BCPY;
          else
            BCPY := least((BLEN - BLOC) + 1, RAW_MAX - LAST_LEN);
            HTRAWS(LINES_IN) := UTL_RAW.CONCAT(HTRAWS(LINES_IN),
                                             UTL_RAW.SUBSTR(RAWBUF,BLOC,BCPY));
            LAST_LEN := LAST_LEN + BCPY;
          end if;
          BLOC := BLOC + BCPY;
        end loop;
      end if;
    end if;
  end PUTRAW;
--
  procedure PUTSTR(CBUF in varchar2) is
  begin
    if (LINES_IN = 0) then
      LINES_IN := LINES_IN + 1; -- reserve space for Content-Length
      HTBUF(1) := null;
      HTRAWS(1) := null;
    end if;
    if (HT_CHARSET = DB_CHARSET) then
      PUTRAW(UTL_RAW.CAST_TO_RAW(CBUF));
    else
      PUTRAW(UTL_RAW.CONVERT(UTL_RAW.CAST_TO_RAW(CBUF),
                             'AMERICAN_AMERICA.'||HT_CHARSET,
                             'AMERICAN_AMERICA.'||DB_CHARSET));
    end if;
  end PUTSTR;
--
  function IS_HTTP_HEADER(STR in varchar2, LEN in number)
    return boolean is
    ALNUM varchar2(250) :=
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789';
    /* These are also allowed: "!#$%&'*+.^_`~" */
    IDX   pls_integer;
    CH    varchar2(30);
  begin
    IDX := 1;
    while (instr(ALNUM, substr(STR, IDX, 1)) > 0) loop
      if (IDX = LEN) then
        return(false);
      end if;
      IDX := IDX + 1;
    end loop;
    while (substr(STR, IDX, 1) = ' ') loop
      if (IDX = LEN) then
        return(false);
      end if;
      IDX := IDX + 1;
    end loop;
    return(substr(STR, IDX, 1) = ':');
  end IS_HTTP_HEADER;
--
  procedure PUT_HEADER(CBUF in varchar2) is
    LOC pls_integer;
  begin
    -- Scan for the newline that separates the header from the content
    HDR_BUF := HDR_BUF||CBUF;
    while ((HDR_BUF is not null) and (HDR_IDX = 0)) loop
      LOC := instr(HDR_BUF, NL_CHAR);
      if (LOC = 0) then
        if (length(HDR_BUF) < 2000) then
          exit;
        else
          LOC := 2000;
        end if;
      elsif ((LOC > 1) and (not IS_HTTP_HEADER(HDR_BUF, LOC))) then
        if (RAW_FLAG) then
          PUTSTR(NL_CHAR); -- ### no Content-Type
        else
          PUT(NL_CHAR); -- ### no Content-Type
        end if;
        MARK_HEADER;
      end if;
      if (RAW_FLAG) then
        PUTSTR(substr(HDR_BUF, 1, LOC));
      else
        PUT(substr(HDR_BUF, 1, LOC));
      end if;
      if (LOC = 1) then
        MARK_HEADER;
      end if;
      HDR_BUF := substr(HDR_BUF, LOC + 1);
    end loop;
    if ((HDR_IDX > 0) and (HDR_BUF is not null)) then
      if (RAW_FLAG) then
        PUTSTR(HDR_BUF);
      else
        PUT(HDR_BUF);
      end if;
    end if;
  end PUT_HEADER;
--
  procedure PRN(CBUF in varchar2 default null) is
    LOC pls_integer;
    LEN pls_integer;
  begin
    if (LINES_IN = 0) then
      LINES_IN := 1; -- reserve space for Content-Length
      HTBUF(1) := null;
      HTRAWS(1) := null;
    end if;
    if (HDR_IDX = 0) then
      PUT_HEADER(CBUF);
    elsif (RAW_FLAG) then
      PUTSTR(CBUF);
    else
      PUT(CBUF);
    end if;
  end PRN;
--
  procedure PRINT(CBUF in varchar2 default null) is
  begin
   if LINES_IN = 0
    then
     --owa_util.mime_header('text/html',CCHARSET=>'UTF-8');
     PRN('Content-Type: '|| 'text/html'||'; charset='||'UTF-8'||NL_CHAR);
     PRN( NL_CHAR);
   end if;
   PRN(CBUF||NL_CHAR);
  end PRINT;
--
  procedure INIT is
  begin
    LINES_IN := 0;
    LINES_OUT := 0;
    COOKIE_FLAG := false;
    NUM_COOKIES := 0;
    if (not NLS_FLAG) then
      ADJUST_FOR_MULTIBYTE;
      NLS_FLAG := true;
    end if;
    RAW_FLAG := false;
    HT_CHARSET := DB_CHARSET;
    HDR_IDX := 0;
    LAST_LEN := 0;
    CLOSE_FLAG := false;
    HDR_BUF := '';
    HTLASTBUF := '';
    if (HTBUF is not null) then
      HTBUF.delete;
    end if;
    if (HTRAWS is not null) then
      HTRAWS.delete;
    end if;
  end INIT;

function INITIALIZE return integer
as
begin
 init;
 return( 0 );
end initialize;

   procedure print_cgi_env is
   begin
      for i in 1..NUM_CGI
      loop
         htp.print(CGI_NAMES(i)||' = '||CGI_VALS(i)||htf.nl);
      end loop;
   end;
--
begin
  INIT;
end OWA;
/
