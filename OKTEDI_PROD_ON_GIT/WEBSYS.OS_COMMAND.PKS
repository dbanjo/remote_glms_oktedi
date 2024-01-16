CREATE OR REPLACE package WEBSYS.os_command
as

function copy( source in varchar2, destination in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function move( source in varchar2, destination in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function rename_file( source in varchar2, destination in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function delete_file( source in varchar2, display_output out GLBX.MYARRAY, just_do_it in boolean default FALSE ) return boolean;
function make_directory( source in varchar2, directory_name in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function make_directory( source in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function remove_directory( source in varchar2, directory_name in varchar2, display_output out GLBX.MYARRAY, remove_all in boolean default false ) return boolean;
function remove_directory( source in varchar2, display_output out GLBX.MYARRAY, remove_all in boolean default false ) return boolean;
function directory_listing( source in varchar2, arrlist in out NOCOPY ump.directory_list_arr ) return boolean;
function stop_oracle_process( pid in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function dosprint( cmd in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function wordprint( cmd in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function ping( site in varchar2, times in integer default 10, display_output out GLBX.MYARRAY ) return boolean;
function performance( time_period in integer default 10, display_output out GLBX.MYARRAY ) return boolean;
-- function zip( string in varchar2, recursive in boolean, include_dir in boolean, files_to_zip in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function zip( string in varchar2, recursive in boolean, include_dir in boolean, files_to_zip in varchar2, display_output out GLBX.MYARRAY, move_files in BOOLEAN default FALSE ) return boolean;
function unzip( unzip_file in varchar2, unzip_directory in varchar2, usepath in varchar2, display_output out GLBX.MYARRAY )  return boolean;
function mime64_encode( file_in in varchar2, file_out in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function mime64_decode( file_in in varchar2, file_out in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function extract_mime64( blb in blob, fl in out utl_file.file_type ) return boolean;
function reassemble_mime64( blb in out blob, fl in out utl_file.file_type, endmarker in varchar2 ) return boolean;
function fileprint( printer_name in varchar2, destination in varchar2, destfilename in varchar2, lptid in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function image_magick( calltype in varchar2, cmd in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function image_magick_trap_output( calltype in varchar2, cmd in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function openwait( dr in varchar2, fn in varchar2, ty in varchar2, len integer, maxwaits integer default 20 ) return utl_file.file_type;
function openwait2( dr in varchar2, fn in varchar2, ty in varchar2, len integer, maxwaits integer default 20, otherext in varchar2, lfile in out varchar2 ) return utl_file.file_type;
function sqlplus_odbc( calltype in varchar2, cmd in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function audcmd( cmd in varchar2, cmd2 in varchar2, display_output out GLBX.MYARRAY ) return boolean;
function audcmd_wait( cmd in varchar2, display_output out GLBX.MYARRAY ) return boolean;

end os_command;
/
