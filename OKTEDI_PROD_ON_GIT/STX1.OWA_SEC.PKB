CREATE OR REPLACE package body STX1.OWA_SEC as
--
  function GET_USER_ID return varchar2 is
  begin
    return(OWA.USER_ID);
  end GET_USER_ID;
--
  function GET_PASSWORD return varchar2 is
  begin
    return(OWA.PASSWORD);
  end GET_PASSWORD;
--
  procedure SET_PROTECTION_REALM(REALM in varchar2) is
  begin
    OWA.PROTECTION_REALM := REALM;
  end SET_PROTECTION_REALM;
--
end OWA_SEC;
/
