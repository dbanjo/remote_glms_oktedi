CREATE OR REPLACE package body STX1.OWA_CUSTOM as
--
  function AUTHORIZE return boolean is
  begin
    return(TRUE);
  end;
--
end OWA_CUSTOM;
/
