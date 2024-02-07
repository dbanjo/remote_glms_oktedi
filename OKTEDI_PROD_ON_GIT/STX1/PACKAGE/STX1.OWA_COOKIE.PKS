CREATE OR REPLACE package STX1.OWA_COOKIE as
  --
  type COOKIE is record
  (
    NAME     varchar2(4096),
    VALS     OWA.VCTAB,
    NUM_VALS integer
  );
  --
  procedure SEND(NAME    in varchar2,
                 VALUE   in varchar2,
                 EXPIRES in date     default null,
                 PATH    in varchar2 default null,
                 DOMAIN  in varchar2 default null,
                 SECURE  in varchar2 default null);
  function GET(NAME in varchar2) return COOKIE;
  procedure REMOVE(NAME in varchar2,
                   VAL  in varchar2,
                   PATH in varchar2 default null);
  procedure GET_ALL(NAMES    out OWA.VCTAB,
                    VALS     out OWA.VCTAB,
                    NUM_VALS out integer);
end OWA_COOKIE;
/
