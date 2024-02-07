CREATE OR REPLACE function STRANG.f_getMvFields( delno in number, item in number, typ in varchar2 )
   return varchar2
  as
   cursor c1(vDelno number, vItem number)  is
    select m.owner, m.current_location,m.movement_no, m.seal,m.urgency,m.consignee
          ,m.consignee_location,m.warehouse_destination, customs_cleared_date , movement_type, dr.hawb_hawbno
          ,dr.movement_no_2, dr.hawb_hawbno_2
    from strang.movements m, strang.detailrs dr
    where m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and vDelno = dr.deliveryno
    and vItem = dr.itemno
    ;
    
   cursor c2(vDelno number, vItem number)  is 
   select m.movement_no, ss.ship_id, ss.li
    from  strang.movements m, strang.detailrs dr, strang.ships_airway ss
    where m.movement_no = dr.movement_no
    and nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    and vDelno = dr.deliveryno
    and vItem = dr.itemno
    and ss.ship_id = m.ship_id
    and typ = 'CARGO';

    

   c1rec  c1%ROWTYPE;
   c2rec  c2%ROWTYPE;

   begin
    if typ = 'CARGO' then 
       open c2(delno,item);
       fetch c2 into c2rec;
       close c2;
    end if;
    
    open c1(delno,item);
    fetch c1 into c1rec;
    if c1%FOUND
     then
      close c1;
       if typ = 'CURRENT_LOCATION' then
         return(nvl(strang.f_getlocdesc(c1rec.current_location),' '));
       elsif typ = 'CARGO' then
         if c1rec.movement_type = 'CARGO' then
           return( 'Container '||nvl(c1rec.movement_no,' ') || htf.nl || nvl(c1rec.seal,' ') );
         elsif c1rec.movement_type = 'CONMOV' then
           return( 'BBulk '||nvl(c1rec.movement_no,' ') );
         elsif c1rec.movement_type = 'AIRWAY' and NVL(c2rec.li,'I') = 'I' and c1rec.movement_no_2 is not null then
          return( 'MAWB (I) '||nvl(to_char(c1rec.movement_no),' ')||case when c1rec.hawb_hawbno is not null then htf.nl||'HAWB (I)'||nvl(to_char(c1rec.hawb_hawbno),'&nbsp;') end||htf.nl||'MAWB (L) '||nvl(to_char(c1rec.movement_no_2),' ')||case when c1rec.hawb_hawbno_2 is not null then htf.nl||'HAWB (L)'||nvl(to_char(c1rec.hawb_hawbno_2),'&nbsp;') end );  
         elsif c1rec.movement_type = 'AIRWAY' and NVL(c2rec.li,'I') = 'I' and c1rec.movement_no_2 is null then
          return( 'MAWB (I) '||nvl(to_char(c1rec.movement_no),' ')||case when c1rec.hawb_hawbno is not null then htf.nl||'HAWB (I)'||nvl(to_char(c1rec.hawb_hawbno),'&nbsp;') end);
         elsif c1rec.movement_type = 'AIRWAY' and NVL(c2rec.li,'I') = 'L'  then
           return( 'MAWB (L) '||nvl(to_char(c1rec.movement_no),' ')||case when c1rec.hawb_hawbno is not null then htf.nl||'HAWB (L)'||nvl(to_char(c1rec.hawb_hawbno),'&nbsp;')end );
         else
           return( ' ' );
         end if;
       elsif typ = 'PRIORITY' then
         return( nvl(to_char(c1rec.urgency),' '));
       elsif typ = 'OWNER' and c1rec.movement_type = 'CARGO' and (c1rec.owner is not null) then
         return( htf.nl||'Container Owner: '||to_char(c1rec.owner));
       elsif typ = 'CONSIGNEE_DESTINATION' then
         return(nvl(to_char(c1rec.consignee||htf.nl||c1rec.consignee_location||htf.nl||strang.f_getlocdesc(c1rec.consignee_location)||htf.nl||c1rec.warehouse_destination||htf.nl||strang.f_getlocdesc(c1rec.warehouse_destination) ),' '));
       elsif typ = 'CUSTOMS' then
         return(nvl(to_char(c1rec.customs_cleared_date),' '));
       else
         return(' ');
       end if;
     else
       close c1;
       return( null );
    end if;
 end f_getMvFields;
/


GRANT EXECUTE ON STRANG.F_GETMVFIELDS TO STX1;

GRANT EXECUTE ON STRANG.F_GETMVFIELDS TO WEBSYS;
