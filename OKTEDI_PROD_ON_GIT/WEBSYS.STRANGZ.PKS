CREATE OR REPLACE package WEBSYS.strangz
as

 procedure hot_sync_all(sync_type in varchar2 default 'STANDARD', result out varchar2, pw in varchar2, debug in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2 );

end strangz;
/
