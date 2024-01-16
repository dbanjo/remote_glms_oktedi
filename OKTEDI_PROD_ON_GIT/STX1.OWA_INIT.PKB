CREATE OR REPLACE package body STX1.OWA_INIT as
--
  function AUTHORIZE return boolean is
  begin
    return(TRUE);
  end;
--
end OWA_INIT;
/
