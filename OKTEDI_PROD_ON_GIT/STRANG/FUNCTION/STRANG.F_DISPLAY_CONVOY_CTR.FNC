CREATE OR REPLACE function STRANG.f_display_convoy_ctr( vMv varchar2, vSl varchar2, typ in varchar2 )
   return varchar
  as

    cursor c1(Mv varchar2, Sl varchar2) is
     select distinct dr.hazard
     from strang.detailrs dr
     where dr.movement_no = Mv
     and nvl(dr.camov_seal,'|') = nvl(Sl,'|')
   ;

   c1rec	C1%ROWTYPE;

   retvar varchar2(32767);

   begin
   retvar := null;

   if typ = 'HAZARD' then
    for c1rec in c1( vMv, vSl ) loop
     retvar := retvar||' '|| c1rec.hazard;
    end loop;
    if retvar is not null then
     retvar := ltrim(retvar);
    end if;
   end if;
   return (retvar);
 end f_display_convoy_ctr;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_CONVOY_CTR TO WEBSYS;
