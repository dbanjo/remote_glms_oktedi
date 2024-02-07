CREATE OR REPLACE function STRANG.f_getTimeElapsed( starttime1 in varchar2,starttime2 in varchar2,endtime1 in varchar2,endtime2 in varchar2 )
   return varchar
  as

   oneconvoy	boolean;
   working_time number;

   begin

   if starttime2 is null or endtime2 is null
   then oneconvoy := TRUE;
    else oneconvoy := FALSE;
   end if;

   if starttime1 is null or endtime1 is null
   then
     return( null );
   end if;

   if oneconvoy then
    working_time := (to_number(substr(endtime1,1,regexp_instr(endtime1,':')-1))*60) + (to_number(substr(endtime1,regexp_instr(endtime1,':')+1)))
    - (to_number(substr(starttime1,1,regexp_instr(starttime1,':')-1))*60) - (to_number(substr(starttime1,regexp_instr(starttime1,':')+1)));
   else
    working_time := (to_number(substr(endtime2,1,regexp_instr(endtime2,':')-1))*60) + (to_number(substr(endtime2,regexp_instr(endtime2,':')+1)))
    - (to_number(substr(starttime1,1,regexp_instr(starttime1,':')-1))*60) - (to_number(substr(starttime1,regexp_instr(starttime1,':')+1)));
   end if;
   if nvl(working_time,0) <= 0 then
    return ('-');
   else
    return( to_char(trunc(working_time/60))||'hr/'||to_char(trunc(remainder(working_time,60)))||'min');
   end if;
 end f_getTimeElapsed;
/


GRANT EXECUTE ON STRANG.F_GETTIMEELAPSED TO WEBSYS;
