CREATE OR REPLACE package body STRANG.global_site
as

 procedure set_name( name_in varchar2 DEFAULT global_site.default_site )
 as
 begin
  global_site.site_name := name_in;
 end set_name;

 function get_name
  return varchar2
 as
 begin
  return( global_site.site_name );
 end get_name;

end global_site;

/


GRANT EXECUTE ON STRANG.GLOBAL_SITE TO WEBSYS;
