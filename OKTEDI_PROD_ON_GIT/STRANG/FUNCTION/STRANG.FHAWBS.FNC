CREATE OR REPLACE function STRANG.fhawbs( mwb in varchar2 )
 return varchar2
as
 cursor c1(mwb varchar2) is select hawb from hawbs where mawb = mwb order by hawb;
 tmp varchar2(4000);
begin
 for c1rec in c1(mwb) loop
  tmp := tmp || ', ' || c1rec.hawb;
 end loop;
 return( substr(tmp,3) );
end fhawbs;
/
