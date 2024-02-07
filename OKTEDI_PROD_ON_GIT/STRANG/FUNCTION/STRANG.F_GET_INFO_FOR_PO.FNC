CREATE OR REPLACE function STRANG.f_get_info_for_po(vDelno integer, vItemno number, action varchar2)
   return varchar2
   as

    cursor c1(vDel integer,vItem number) is 
    select dr.deliveryno, dr.itemno, m.*
    from strang.detailrs dr, strang.movements m
    where dr.movement_no = m.movement_no 
    and nvl(camov_seal,'|') = nvl(seal,'|')
    and dr.DELIVERYNO = vDel
    and dr.ITEMNO = vItem
        ;

    cursor c2(vConvoy integer) is 
    select c.estdepart
    from strang.convoy c
    where c.convoy_id = vConvoy;

 c1rec  c1%ROWTYPE; 
 c2rec  c2%ROWTYPE; 
 retvar	varchar2(32767);
 
begin
 retvar := null;
 open c1(vDelno,vItemno);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then retvar := NULL;
   close c1;
   return ( retvar );
 end if; 

 if action = 'MOVEMENT_NO'
  then
  retvar := c1rec.movement_no ;
 elsif action = 'SEAL'
  then
  retvar := c1rec.seal ;
 elsif action = 'WAREHOUSE_DESTINATION'
  then
  retvar := strang.f_getlocdesc(c1rec.warehouse_destination);
 elsif action = 'CURRENT_LOCATION'
  then
  retvar := strang.f_getlocdesc(c1rec.current_location);
 elsif action = 'URGENCY'
  then
  retvar := c1rec.urgency ;
 elsif action = 'INTL SHIP ID'
  then
  if c1rec.movement_type = 'AIRWAY'
  then
   retvar := ' - ';
  else 
   retvar := strang.f_getshipfields_mv(c1rec.movement_no,c1rec.seal,'I','SHIP_ID');
  end if; 
 elsif action = 'INTL SHIPNAME'
  then
  if c1rec.movement_type = 'AIRWAY'
  then
   retvar := c1rec.movement_no;
  else 
   retvar := strang.f_getshipfields_mv(c1rec.movement_no,c1rec.seal,'I','SHIPNAME');
  end if;
 elsif action = 'INTL VOYAGE'
  then
  if c1rec.movement_type = 'AIRWAY'
  then
   retvar := ' - ';
  else 
   retvar := strang.f_getshipfields_mv(c1rec.movement_no,c1rec.seal,'I','VOY');
  end if; 
 elsif action = 'INTL ESTARRIVE'
  then
  if c1rec.movement_type = 'AIRWAY'
  then
   retvar := to_char(c1rec.dispatch_date, 'dd-Mon-yyyy');
  else 
   retvar := strang.f_getshipfields_mv(c1rec.movement_no,c1rec.seal,'I','ESTARRIVE');
  end if; 
 elsif action = 'BOL'
  then
  retvar := c1rec.bol;
 elsif action = 'CUSTOMS_CLEARED_DATE'
  then
  retvar := c1rec.customs_cleared_date;


 elsif action = 'LOCAL SHIP ID'
  then
  if c1rec.movement_type = 'AIRWAY'
  then
   retvar := ' - ';
  else 
   retvar := strang.f_getshipfields_mv(c1rec.movement_no,c1rec.seal,'L','SHIP_ID');
  end if; 
 elsif action = 'LOCAL SHIPNAME'
  then
  if c1rec.movement_type = 'AIRWAY'
  then
   retvar := c1rec.movement_no;
  else 
   retvar := strang.f_getshipfields_mv(c1rec.movement_no,c1rec.seal,'L','SHIPNAME');
  end if;
 elsif action = 'LOCAL VOYAGE'
  then
  if c1rec.movement_type = 'AIRWAY'
  then
   retvar := ' - ';
  else 
   retvar := strang.f_getshipfields_mv(c1rec.movement_no,c1rec.seal,'L','VOY');
  end if; 
 elsif action = 'LOCAL ESTARRIVE'
  then
  if c1rec.movement_type = 'AIRWAY'
  then
   retvar := to_char(c1rec.dispatch_date, 'dd-Mon-yyyy');
  else 
   retvar := strang.f_getshipfields_mv(c1rec.movement_no,c1rec.seal,'L','ESTARRIVE');
  end if; 
 elsif action = 'LOCAL BOL'
  then
  retvar := c1rec.local_bol;
 elsif action = 'SCHEDULED CONVOY'
  then
   retvar := c1rec.convoy_id;
 elsif action = 'SCHEDULED CONVOY DATE'
  then
   if c1rec.convoy_id is null
   then
    retvar := null;
   else 
    open c2(c1rec.convoy_id);
    fetch c2 into c2rec;
    if c2%NOTFOUND
     then retvar := NULL;
     close c2;
    else
      retvar := c2rec.estdepart;
      close c2;
    end if; 
   end if; 

   retvar := c2rec.estdepart;
 else
  retvar := null ;
 end if;
 close c1;
 return ( retvar );
 end f_get_info_for_po;
/


GRANT EXECUTE ON STRANG.F_GET_INFO_FOR_PO TO WEBSYS;
