CREATE OR REPLACE package WEBSYS.utl_blob as
procedure blobtofile(src in BLOB, filename in varchar2, append in boolean);
function extract_fname( fname in varchar2, ftype in varchar2 DEFAULT 'NO_EXTENSION', maxlength in integer DEFAULT 100) return varchar2;
end utl_blob;
/


GRANT EXECUTE ON WEBSYS.UTL_BLOB TO STRANG;

GRANT EXECUTE ON WEBSYS.UTL_BLOB TO STX1;
