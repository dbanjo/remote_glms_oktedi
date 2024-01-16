CREATE OR REPLACE function WEBSYS.f_getlocdesc( lcd in varchar2 )
   return varchar2
  as
   cursor c1(cd varchar2)  is
    select l.description
    from strang.lov l
    where l.lov_name='LOCATIONS' and
    code = cd;
   c1rec  c1%ROWTYPE;

   begin
    open c1(lcd);
    fetch c1 into c1rec;
    if c1%FOUND
     then
      close c1;
      return( c1rec.description );
     else
       close c1;
       return( lcd );
    end if;
 end f_getlocdesc;
/
