CREATE OR REPLACE function STRANG.f_getDefaultCtrOwner( mv in varchar2, typ in varchar2, vowner in varchar2 )
   return varchar2
  as
   cursor c1(vMv varchar2)  is
    select nvl(m.dispatch_date,'01-JAN-2000'), m.owner, m.movement_no
    from strang.movements m
    where m.movement_no = vMv
    and m.owner is not null
    order by m.dispatch_date desc;

   c1rec  c1%ROWTYPE;

   begin
    if vowner is not null then
      return(vowner);
    end if;
    if typ = 'CARGO'
    then
     open c1(mv);
     fetch c1 into c1rec;
     if c1%FOUND
      then
       close c1;
       return( c1rec.owner );
     else
       close c1;
       return( null );
     end if;
    else
     return( null );
    end if;
 end f_getDefaultCtrOwner;
/


GRANT EXECUTE ON STRANG.F_GETDEFAULTCTROWNER TO STX1;

GRANT EXECUTE ON STRANG.F_GETDEFAULTCTROWNER TO WEBSYS;
