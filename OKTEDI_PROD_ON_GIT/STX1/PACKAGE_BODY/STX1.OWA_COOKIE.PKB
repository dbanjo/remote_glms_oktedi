CREATE OR REPLACE package body STX1.OWA_COOKIE as
--
  procedure SEND(NAME    in varchar2,
                 VALUE   in varchar2,
                 EXPIRES in date     default null,
                 PATH    in varchar2 default null,
                 DOMAIN  in varchar2 default null,
                 SECURE  in varchar2 default null) is
    COOKIE_LINE varchar2(4000);
    MINUTES     number := 0;
    T           date;
  begin
    COOKIE_LINE := 'Set-Cookie: '||NAME||'='||VALUE||';';
    if (EXPIRES is not null) then
      -- Convert EXPIRES to GMT
      /* ### WORKS ONLY WITH ORACLE 9i ###
      MINUTES := to_number(to_char(SYSTIMESTAMP,'TZH') * 60);
      if (MINUTES < 0) then
        MINUTES := MINUTES - to_number(to_char(SYSTIMESTAMP,'TZM'));
      else
        MINUTES := MINUTES + to_number(to_char(SYSTIMESTAMP,'TZM'));
      end if;
         ### WORKS ONLY WITH ORACLE 9i ### */
      if (MINUTES <> 0) then
        T := EXPIRES - MINUTES/(24*60);
      else
        T := EXPIRES;
      end if;
      COOKIE_LINE := COOKIE_LINE||' expires='||
                     rtrim(to_char(T, 'Day',
                                  'NLS_DATE_LANGUAGE=AMERICAN'), ' ')||
                     ', '||to_char(T, 'DD-Mon-YYYY HH24:MI:SS',
                                   'NLS_DATE_LANGUAGE=AMERICAN')||' GMT;';
    end if;
    if (PATH is not null) then
      COOKIE_LINE := COOKIE_LINE||' path='||PATH||';';
    end if;
    if (DOMAIN is not null) then
      COOKIE_LINE := COOKIE_LINE||' domain='||DOMAIN||';';
    end if;
    if (SECURE is not null) then
      COOKIE_LINE := COOKIE_LINE||' secure';
    end if;
    OWA.PRINT(COOKIE_LINE);
  end SEND;
--
  function GET(NAME in varchar2) return COOKIE is
    ACOOKIE     COOKIE;
    NUM_COOKIES number;
    NAMES       OWA.VCTAB;
    VALS        OWA.VCTAB;
  begin
    NUM_COOKIES := OWA.PARSE_COOKIES(NAMES, VALS);
    ACOOKIE.NUM_VALS := 0;
    ACOOKIE.NAME := NAME;
    for I in 1..NUM_COOKIES loop
      if (NAMES(I) = NAME) then
        ACOOKIE.NUM_VALS := ACOOKIE.NUM_VALS + 1;
        ACOOKIE.VALS(ACOOKIE.NUM_VALS) := VALS(I);
      end if;
    end loop;
    return(ACOOKIE);
  end GET;
--
  procedure REMOVE(NAME in varchar2,
                   VAL  in varchar2,
                   PATH in varchar2 default null) is
  begin
    SEND(NAME, VAL, to_date('YYYY/MM/DD','1970/01/01'));
  end REMOVE;
--
  procedure GET_ALL(NAMES    out OWA.VCTAB,
                    VALS     out OWA.VCTAB,
                    NUM_VALS out integer) is
  begin
    NUM_VALS := OWA.PARSE_COOKIES(NAMES, VALS);
  end GET_ALL;
--
end OWA_COOKIE;
/
