CREATE OR REPLACE package STRANG.global_site
as

 default_site constant varchar2(100) := 'PRIMARY';
 disable_trigger boolean := FALSE;
 site_name varchar2(100);

 procedure set_name( name_in varchar2 DEFAULT global_site.default_site );
 function get_name return varchar2;

end global_site;

/


GRANT EXECUTE ON STRANG.GLOBAL_SITE TO WEBSYS;
