CREATE OR REPLACE function STRANG.f_storage_days( Mv in varchar2, Sl in varchar2 )
  return varchar2
 as
-- DISCHARGE
-- INBOUND SHIPS DISCHARGED AT INTERNATIONAL WHARF - INTERNATIONAL WHARF STORAGE (ONLY INTERNATIONAL CARGO)
  cursor c1( vMv varchar2, vSl varchar2 ) is
  select m.int_ship_discharge_date, m.release_date, m.intl_wharf_transfer_date, m.berth4_transfer_date, m.ship_id, s.portdisc, s1.portload, s1.estdepart localshipdepart
  from strang.movements m, strang.ships_airway s, strang.ships_airway s1
  where
  m.movement_no =vMv
  and nvl(m.seal,'|') = nvl(vSl,'|')
  and m.ship_id = s.ship_id
  and m.ship_id <> 1
  and m.int_ship_discharge_date is not null
  and m.local_ship_id = s1.ship_id
  and s.ship_airway = 'S'
  and s.portdisc in ('INTL WHARF');

-- DISCHARGE
-- INBOUND INTERNATIONAL SHIPS DISCHARGED AT BERTH4 - BERTH4 WHARF STORAGE  (international cargo)
  cursor c2( vMv varchar2, vSl varchar2 ) is
  select m.int_ship_discharge_date, m.release_date, m.intl_wharf_transfer_date, m.berth4_transfer_date, m.ship_id, s.portdisc, s1.estdepart localshipdepart
  from strang.movements m, strang.ships_airway s, strang.ships_airway s1
  where
  m.movement_no =vMv
  and nvl(m.seal,'|') = nvl(vSl,'|')
  and m.ship_id = s.ship_id
  and m.ship_id <> 1
  and m.int_ship_discharge_date is not null
  and m.local_ship_id = s1.ship_id
  and s.ship_airway = 'S'
  and s.portdisc in ('BERTH#4');

-- LOADING
-- INBOUND LOCAL SHIPS LOADED AT BERTH4  - BERTH4 WHARF STORAGE (Local DELIVERIES only)
  cursor c3( vMv varchar2, vSl varchar2 ) is
  select m.int_ship_discharge_date, m.intl_wharf_transfer_date, m.release_date, m.si_date,m.berth4_transfer_date, m.local_ship_id, s1.portload, s1.estdepart localshipdepart
  from strang.movements m, strang.ships_airway s1
  where
  m.movement_no =vMv
  and nvl(m.seal,'|') = nvl(vSl,'|')
  and m.local_ship_id = s1.ship_id
  and m.ship_id = 1
  and m.berth4_transfer_date is not null
  and s1.portload in('BERTH#4')
  ;

-- LOADING
-- INBOUND LOCAL SHIPS LOADED AT INTERNATIONAL  - INTERNATIONAL WHARF STORAGE (LOCAL DELIVERIES ONLY)
  cursor c4( vMv varchar2, vSl varchar2 ) is
  select m.int_ship_discharge_date, m.intl_wharf_transfer_date, m.release_date, m.berth4_transfer_date, m.local_ship_id, s1.portload, m.si_date,s1.estdepart localshipdepart
  from strang.movements m, strang.ships_airway s1
  where
  m.movement_no =vMv
  and nvl(m.seal,'|') = nvl(vSl,'|')
  and m.local_ship_id = s1.ship_id
  and m.ship_id = 1
  and m.si_date is not null
  and s1.portload in('INTL WHARF') ;

-- LOADING
-- INBOUND LOCAL SHIPS LOADED AT BERTH4  - BERTH4 WHARF STORAGE (INTERNATIONAL CARGO only)
  cursor c5( vMv varchar2, vSl varchar2 ) is
  select m.int_ship_discharge_date, m.intl_wharf_transfer_date, m.release_date, m.berth4_transfer_date, m.local_ship_id, s1.portload, s1.estdepart localshipdepart
  from strang.movements m, strang.ships_airway s, strang.ships_airway s1
  where
  m.movement_no =vMv
  and nvl(m.seal,'|') = nvl(vSl,'|')
  and m.local_ship_id = s1.ship_id
  and m.ship_id = s.ship_id
  and m.ship_id <> 1
  and m.berth4_transfer_date is not null
  and s.portdisc in ('INTL WHARF')
  and s1.portload in('BERTH#4')
  ;

-- LOADING
-- INBOUND LOCAL SHIPS LOADED AT INTERNATIONAL  - INTERNATIONAL WHARF STORAGE (INTERNATIONAL CARGO ONLY)
  cursor c6( vMv varchar2, vSl varchar2 ) is
  select m.int_ship_discharge_date, m.intl_wharf_transfer_date, m.release_date, m.berth4_transfer_date, m.local_ship_id, s.portdisc, s1.portload, m.si_date,s1.estdepart localshipdepart
  from strang.movements m, strang.ships_airway s, strang.ships_airway s1
  where
  m.movement_no =vMv
  and nvl(m.seal,'|') = nvl(vSl,'|')
  and m.local_ship_id = s1.ship_id
  and m.ship_id = s.ship_id
  and m.ship_id <> 1
  and m.si_date is not null
  and s.portdisc in ('BERTH#4')
  and s1.portload in('INTL WHARF') ;

c1rec	C1%ROWTYPE;
c2rec	C2%ROWTYPE;
c3rec	C3%ROWTYPE;
c4rec	C4%ROWTYPE;
c5rec	C5%ROWTYPE;
c6rec	C6%ROWTYPE;

intl_storage_c1   number;
local_storage_c2  number;
local_storage_c3  number;
intl_storage_c4   number;
local_storage_c5  number;
intl_storage_c6   number;
local_storage	  number;
intl_storage      number;
 begin
 intl_storage_c1  := 0;
 local_storage_c2 := 0;
 local_storage_c3 := 0;
 intl_storage_c4  := 0;
 local_storage_c5 := 0;
 intl_storage_c6  := 0;
 local_storage := 0;
 intl_storage  := 0;

   open c1( Mv, Sl );
   fetch c1 into c1rec;
   if C1%FOUND then
     case
       when c1rec.localshipdepart is not null
            and c1rec.intl_wharf_transfer_date is null and c1rec.berth4_transfer_date is null and c1rec.release_date is null
            then
             if c1rec.localshipdepart > sysdate then
              intl_storage_c1 := (trunc(sysdate) - trunc(c1rec.int_ship_discharge_date)) - 5;
             else
              intl_storage_c1 := (trunc(c1rec.localshipdepart) - trunc(c1rec.int_ship_discharge_date)) - 5;
             end if;
       when c1rec.intl_wharf_transfer_date is not null
            then intl_storage_c1 := trunc(c1rec.intl_wharf_transfer_date) - trunc(c1rec.int_ship_discharge_date) - 5;
       when c1rec.berth4_transfer_date is not null and c1rec.intl_wharf_transfer_date is null
               then intl_storage_c1 := trunc(c1rec.berth4_transfer_date) - trunc(c1rec.int_ship_discharge_date) - 5;
       when c1rec.release_date is not null
               then intl_storage_c1 := trunc(c1rec.release_date) - trunc(c1rec.int_ship_discharge_date) - 5;
       else intl_storage_c1 := 0;
     end case;
   end if;

   open c2( Mv, Sl );
   fetch c2 into c2rec;
   if C2%FOUND then
     case
       when c2rec.localshipdepart is not null
            and c2rec.berth4_transfer_date is null and c2rec.release_date is null
            then
             if c2rec.localshipdepart > sysdate then
              local_storage_c2 := (trunc(sysdate) - trunc(c2rec.int_ship_discharge_date)) - 10;
             else
              local_storage_c2 := (trunc(c2rec.localshipdepart) - trunc(c2rec.int_ship_discharge_date)) - 10;
             end if;
       when c2rec.localshipdepart is not null and c2rec.berth4_transfer_date is not null and c2rec.release_date is null
            then
             if c2rec.localshipdepart > sysdate then
              local_storage_c2 := (trunc(sysdate) - trunc(c2rec.berth4_transfer_date)) - 10;
             else
              local_storage_c2 := (trunc(c2rec.localshipdepart) - trunc(c2rec.berth4_transfer_date)) - 10;
             end if;
       when c2rec.release_date is not null and c2rec.berth4_transfer_date is null
             then local_storage_c2 := trunc(c2rec.release_date) - trunc(c2rec.int_ship_discharge_date) - 10;
       when c2rec.release_date is not null and c2rec.berth4_transfer_date is not null
             then local_storage_c2 := trunc(c2rec.berth4_transfer_date) - trunc(c2rec.int_ship_discharge_date) - 10;
       else local_storage_c2 := 0;
     end case;
    end if;

   open c3( Mv, Sl );
   fetch c3 into c3rec;
   if C3%FOUND then
     case
       when c3rec.localshipdepart is not null and c3rec.berth4_transfer_date is not null and c3rec.release_date is null
       then
         if c3rec.localshipdepart > sysdate then
           local_storage_c3 := (trunc(sysdate) - trunc(c3rec.berth4_transfer_date)) - 10;
         else
           local_storage_c3 := (trunc(c3rec.localshipdepart) - trunc(c3rec.berth4_transfer_date)) - 10;
         end if;
       when c3rec.release_date is not null
       then
           local_storage_c3 := trunc(c3rec.release_date) - trunc(c3rec.berth4_transfer_date) - 10;
       else local_storage_c3 := 0;
     end case;
     end if;

   open c4( Mv, Sl );
   fetch c4 into c4rec;
   if C4%FOUND then
     case
       when c4rec.release_date is null
            and c4rec.localshipdepart is not null
       then
         if trunc(c4rec.localshipdepart) > trunc(sysdate) then
           intl_storage_c4 := (trunc(sysdate) - trunc(c4rec.si_date)) - 5;
         else
           intl_storage_c4 := (trunc(c4rec.localshipdepart) - trunc(c4rec.si_date)) - 5;
         end if;
       when c4rec.si_date is not null
       then
           intl_storage_c4 := trunc(c4rec.release_date) - trunc(c4rec.si_date) - 5;
       else intl_storage_c4 := 0;
     end case;
     end if;

        open c5( Mv, Sl );
        fetch c5 into c5rec;
        if C5%FOUND then
          case
            when c5rec.release_date is null and c5rec.berth4_transfer_date is not null
                 and c5rec.localshipdepart is not null
            then
              if trunc(c5rec.localshipdepart) > trunc(sysdate) then
                local_storage_c5 := trunc(sysdate) - trunc(c5rec.berth4_transfer_date) - 10;
              else
                local_storage_c5 := trunc(c5rec.localshipdepart) - trunc(c5rec.berth4_transfer_date) - 10;
              end if;
            when c5rec.release_date is not null
            then
                local_storage_c5 := trunc(c5rec.berth4_transfer_date) - trunc(c5rec.release_date) - 10;
            else local_storage_c5 := 0;
          end case;
          end if;

        open c6( Mv, Sl );
        fetch c6 into c6rec;
        if C6%FOUND then
          case
            when c6rec.release_date is null
                 and c6rec.localshipdepart is not null
                 and c6rec.si_date is not null
            then
              if trunc(c6rec.localshipdepart) > trunc(sysdate) then
                intl_storage_c6 := (trunc(sysdate) - trunc(c6rec.si_date)) - 5;
              else
                intl_storage_c6 := (trunc(c6rec.localshipdepart) - trunc(c6rec.si_date)) - 5;
              end if;
            when c6rec.si_date is not null
                 and c6rec.release_date is not null
            then
                intl_storage_c6 := trunc(c6rec.release_date) - trunc(c6rec.si_date) - 5;
            else intl_storage_c6 := 0;
          end case;
          end if;

 local_storage := local_storage_c2 + local_storage_c3 + local_storage_c5 ;
 intl_storage :=  intl_storage_c1 + intl_storage_c4 + intl_storage_c6 ;

/*
 return('1 :'|| intl_storage_c1 || ' 2 :'||
 local_storage_c2 ||' 3 :'||
 local_storage_c3 ||' 4 :'||
 intl_storage_c4  ||' 5 :'|| local_storage_c5 ||' 6 :'|| intl_storage_c6 );
*/
if local_storage <= 0 and intl_storage <= 0 then
 return ( ' ' );
else
 return('Storage Charges: Intl Wharf: '||to_char(intl_storage)||' / Berth#4: '||to_char(local_storage)||' Days');
end if;

end f_storage_days;
/


GRANT EXECUTE ON STRANG.F_STORAGE_DAYS TO WEBSYS;
