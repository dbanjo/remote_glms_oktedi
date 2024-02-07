CREATE OR REPLACE function WEBSYS.f_getcountrycode( lcd in varchar2 )
   return varchar2
  as
   cursor c1(v_country_txt varchar2)  is
    select c.alpha2
    from websys.temp_country_codes c
    where 
     ( CASE WHEN length(v_country_txt) > 3 then upper(c.name)
            WHEN length(v_country_txt) = 3 then upper(c.alpha3)
            WHEN length(v_country_txt) = 2 then upper(c.alpha2) else null end ) = v_country_txt;
    
   c1rec  c1%ROWTYPE;
   v_country_text varchar2(100);
   v_first_part varchar2(100);
   v_second_part varchar2(100);
   v_filler varchar2(100);

   begin
    open c1(lcd);
    fetch c1 into c1rec;
    if c1%FOUND
     then
      close c1;
      return( c1rec.alpha2 );
     else
       close c1;
       return( null );
    end if;
 end f_getcountrycode;
/
