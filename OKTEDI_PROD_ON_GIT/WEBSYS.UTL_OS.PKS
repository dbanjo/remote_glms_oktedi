CREATE OR REPLACE package WEBSYS.utl_os as
function subjob( cmd in varchar2 ) return integer;
procedure OSCmdNoWait(cmd in varchar2);
procedure OSCmdDirectWait(cmd in varchar2);
function MkDir(filepath in varchar2) return boolean;
function RenameDir(olddirectorypath in varchar2, newdirectory in varchar2) return boolean;
function delete_file(filepath in varchar2) return boolean;
end utl_os;
/


GRANT EXECUTE ON WEBSYS.UTL_OS TO STX1;
