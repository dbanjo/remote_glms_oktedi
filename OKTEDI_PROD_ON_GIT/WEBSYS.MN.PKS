CREATE OR REPLACE package WEBSYS.mn
as

procedure style_c;
procedure style_s;
function header_style return varchar2;
function tableopen_style return varchar2;

end mn;
/
