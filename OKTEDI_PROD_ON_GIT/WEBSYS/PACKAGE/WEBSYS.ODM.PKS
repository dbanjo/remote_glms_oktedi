CREATE OR REPLACE package WEBSYS.odm
as

 procedure xml_status( is_soap in boolean default FALSE );
 procedure status;
 function check_sites return boolean;
 function cull_log_file return boolean;

end;

/
