CREATE OR REPLACE function STRANG.f_getLovColumn( lvnm in varchar2, cl in varchar2, lcd in varchar2, vste in varchar2 default null )
   return varchar2
  as
   cursor c1(nm varchar2,cd varchar2)  is
    select *
    from strang.lov l
    where l.lov_name = nm and
    code = cd;
   c1rec  c1%ROWTYPE;

   begin
    open c1(lvnm,lcd);
    fetch c1 into c1rec;
    if c1%NOTFOUND
     then
      close c1;
       return( lcd );
     else
       close c1;
       if cl = 'DESCRIPTION' then
         return( c1rec.description );
       elsif
          cl = 'COLA' then
            return( c1rec.cola );
       elsif
          cl = 'COLB' then
            return( c1rec.colb );
       elsif
          cl = 'COLC' then
            return( c1rec.colc );
       elsif
          cl = 'COLD' then
            return( c1rec.cold );
       elsif
          cl = 'COLE' then
            return( c1rec.cole );
       else
            return( lcd );
       end if;
    end if;
 end f_getLovColumn;
/


GRANT EXECUTE ON STRANG.F_GETLOVCOLUMN TO STX1;

GRANT EXECUTE ON STRANG.F_GETLOVCOLUMN TO WEBSYS;
