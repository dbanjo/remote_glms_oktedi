CREATE OR REPLACE function STRANG.f_getlocdesc_whouse( lcd in varchar2 )
   return varchar2
  as
   cursor c1(cd varchar2)  is
    select l.colc
    from strang.lov l
    where l.lov_name='LOCATIONS' and
    l.code =  lcd and 
    l.cole = 'WAREHOUSE';
    
   c1rec  c1%ROWTYPE;

   begin
    open c1(lcd);
    fetch c1 into c1rec;
    if c1%FOUND
     then
      close c1;
      return( c1rec.colc );
     else
       close c1;
       return( lcd );
    end if;
 end f_getlocdesc_whouse;
/


GRANT EXECUTE ON STRANG.F_GETLOCDESC_WHOUSE TO STX1;
