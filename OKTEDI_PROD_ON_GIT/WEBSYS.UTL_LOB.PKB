CREATE OR REPLACE package body WEBSYS.utl_lob is

 logSetting BOOLEAN := FALSE;
 logFileName VARCHAR2(512) := NULL;

procedure SetLogging(which BOOLEAN, a_log VARCHAR2)
is
begin
 logSetting := which;
 if (logSetting = TRUE) then logFileName := a_log; else logFileName := NULL; end if;
end;

function LobToFile(a_lob BLOB, a_file VARCHAR2, a_log VARCHAR2, logging BOOLEAN)
 return BINARY_INTEGER is
external
library utlloblib
name "lob2file"
with context
parameters
( a_lob OCILOBLOCATOR,
  a_lob INDICATOR SHORT,
  a_file STRING,
  a_file INDICATOR SHORT,
  a_file LENGTH INT,
  a_log STRING,
  a_log INDICATOR SHORT,
  a_log LENGTH INT,
  logging INT,
  CONTEXT,
  RETURN
);

procedure UnloadToFile(a_lob BLOB, a_file VARCHAR2, status OUT NUMBER)
is
begin
 status := LobToFile(a_lob, a_file, logFileName, logSetting);
end;

-- utl_lob.unloadtofile(lob_var, 'c:\temp\x' || fname, status);
end utl_lob;

/
