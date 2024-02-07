CREATE OR REPLACE function STRANG.f_wordwrap( txt in varchar2, atpos in integer default 25 )
 return varchar2
as

 x 	integer;

begin

 if length( txt ) < atpos then return( txt || htf.nl ); end if;
 x := instr(txt,' ',atpos-1,1);
 if x = 0
  then
   return( substr(txt,1,atpos) || htf.nl || substr(txt,atpos+1,atpos));
 end if;
 return( substr(txt,1,x-1) || htf.nl || substr(substr(txt,x+1),1,atpos));

end f_wordwrap;
/


GRANT EXECUTE ON STRANG.F_WORDWRAP TO WEBSYS;
