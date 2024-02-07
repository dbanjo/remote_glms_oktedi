CREATE OR REPLACE package WEBSYS.xml
as

procedure display_download(surl in varchar2);
procedure display_download_main(surl in varchar2, driver in varchar2);
procedure accept_display_download( surl in varchar2, driver in varchar2, p1 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2 default null, p6 in varchar2 default null, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY );
procedure run_upload(surl in varchar2);
procedure accept_run_upload( surl in varchar2, file in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null );

function conv_3bytes( fbytes varchar2 ) return varchar2;
function conv_back_3bytes( fbytes varchar2 ) return raw;

procedure dir_email_receive( surl in varchar2, cusrec in customer_account%ROWTYPE );

end xml;

/
