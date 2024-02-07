CREATE OR REPLACE package STX1.OWA_SEC as
  function GET_USER_ID return varchar2;
  function GET_PASSWORD return varchar2;
  procedure SET_PROTECTION_REALM(REALM in varchar2);
end OWA_SEC;
/
