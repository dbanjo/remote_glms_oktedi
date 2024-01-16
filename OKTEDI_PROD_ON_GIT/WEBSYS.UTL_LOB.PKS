CREATE OR REPLACE package WEBSYS.utl_lob is

 procedure SetLogging(which BOOLEAN, a_log VARCHAR2);
 procedure UnloadToFile(a_lob BLOB, a_file VARCHAR2, status OUT NUMBER);

end utl_lob;

/
