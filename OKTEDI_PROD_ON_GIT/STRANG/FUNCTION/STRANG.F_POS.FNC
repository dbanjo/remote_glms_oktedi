CREATE OR REPLACE function STRANG.f_pos( dlr in number, call_type in varchar2, break_on in varchar2 default 'F' )
 return varchar2
as
 cursor c1(dlr number) is
  select supinv, po, grn_status, po_item_no, sap_delno,sap_delno_item
           ,qty,inventoryno
           ,preq_no
           ,preq_item
           , REGEXP_SUBSTR( warehouse_plant ,'(^[DI])?([[:digit:]]{4})(/[A-Z]{1}[[:digit:]]{3})?',1,1,'i',1) order_type
           , REGEXP_SUBSTR( warehouse_plant ,'(^[DI])?([[:digit:]]{4})?(/[A-Z]{1}[[:digit:]]{3})?',1,1,'i',2) plant
           , ltrim(REGEXP_SUBSTR( warehouse_plant ,'(^[DI])?([[:digit:]]{4})?(/[A-Z]{1}[[:digit:]]{3})?',1,1,'i',3),'/') warehouse  
           ,freight_mode,min(recno)
  from  strang.pos p
  where deliveryno = dlr
  group by supinv,po,grn_status,po_item_no,sap_delno,sap_delno_item,qty,inventoryno,preq_no,preq_item
       , REGEXP_SUBSTR( warehouse_plant ,'(^[DI])?([[:digit:]]{4})(/[A-Z]{1}[[:digit:]]{3})?',1,1,'i',1)
       , REGEXP_SUBSTR( warehouse_plant ,'(^[DI])?([[:digit:]]{4})?(/[A-Z]{1}[[:digit:]]{3})?',1,1,'i',2)
       , ltrim(REGEXP_SUBSTR( warehouse_plant ,'(^[DI])?([[:digit:]]{4})?(/[A-Z]{1}[[:digit:]]{3})?',1,1,'i',3),'/')
       , freight_mode
  order by min(recno),supinv,po,po_item_no, preq_no,
     REGEXP_SUBSTR( warehouse_plant ,'(^[DI])?([[:digit:]]{4})(/[A-Z]{1}[[:digit:]]{3})?',1,1,'i',1)
    , REGEXP_SUBSTR( warehouse_plant ,'(^[DI])?([[:digit:]]{4})?(/[A-Z]{1}[[:digit:]]{3})?',1,1,'i',2);
  
 cursor c11(dlr number) is select distinct po from pos p where deliveryno = dlr;
 
 cursor c2(dlr number) is select count(distinct supinv||po||grn_status||po_item_no||sap_delno||sap_delno_item||qty||inventoryno||freight_mode) from pos p where deliveryno = dlr;


 c1rec  c1%ROWTYPE;
 retvar	varchar2(32767);
 lrec   varchar2(100);
 po_cnt integer;


begin
 lrec := NULL;
 if call_type = 'PORDER_1'
  then
   open c11(dlr);
   fetch c11 into retvar;
   close c11;
   return(retvar);
 end if;
 
 if call_type = 'PORDER_COUNT'
  then
   open c2(dlr);
   fetch c2 into po_cnt;
   close c2;
   return (po_cnt);
 end if;
 
 for c1rec in c1(dlr) loop

  if call_type = 'SUPINV'
   then
    if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.supinv ,'x') = lrec
       then
         retvar := retvar;
       else
         retvar := retvar || htf.nl || c1rec.supinv;
      end if;
      lrec := c1rec.supinv;
     else
      retvar := retvar || htf.nl || c1rec.supinv;
    end if;

   elsif call_type = 'STO'
   then
    if break_on = 'T' and c1rec.preq_no is not null
     then
      if lrec is not null and nvl(c1rec.preq_no,'x') = lrec
       then
         retvar := retvar;
       else
         retvar := retvar || htf.nl || c1rec.preq_no;
      end if;
      lrec := c1rec.preq_no;
     elsif c1rec.preq_no is not null then
      retvar := retvar || htf.nl || c1rec.preq_no;
    end if;

   elsif call_type = 'PORDER'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.po,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.po;
      end if;
      lrec := c1rec.po;
     else
      retvar := retvar || htf.nl || c1rec.po;
     end if;
     
    elsif call_type = 'FMODE'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.po,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.freight_mode;
      end if;
      lrec := c1rec.freight_mode;
     else
      retvar := retvar || htf.nl || c1rec.freight_mode;
     end if;
   else
    if call_type = 'GRNSTATUS'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(to_char(c1rec.grn_status),'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || to_char(c1rec.grn_status);
      end if;
      lrec := to_char(c1rec.grn_status);
     else
      retvar := retvar || htf.nl || to_char(c1rec.grn_status);
     end if;
   end if;

  end if;
 end loop;

 lrec := NULL;
 for c1rec in c1(dlr) loop
    if call_type = 'SAPDELNO'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(to_char(c1rec.sap_delno),'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.sap_delno || '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'|| c1rec.sap_delno_item;
      end if;
      lrec := c1rec.sap_delno;
     else
      retvar := retvar || htf.nl || c1rec.sap_delno || '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' || c1rec.sap_delno_item;
     end if;
    end if;
 end loop;

 lrec := NULL;
 for c1rec in c1(dlr) loop
    if call_type = 'QTY'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.qty,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || to_char(c1rec.qty,'999,999,999.999');
      end if;
      lrec := c1rec.sap_delno;
     else
      retvar := retvar || htf.nl || to_char(c1rec.qty,'999,999,999.999');
     end if;
    end if;
 end loop;

  lrec := NULL;
 for c1rec in c1(dlr) loop
    if call_type = 'INVENTORYNO'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.inventoryno,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.inventoryno;
      end if;
      lrec := c1rec.inventoryno;
     else
      retvar := retvar || htf.nl || c1rec.inventoryno;
     end if;
    end if;
 end loop;
 
 -- Add code to handle Purchase Requisition
  lrec := NULL;
 for c1rec in c1(dlr) loop
    if call_type = 'PREQ_NO'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.preq_no,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.preq_no;
      end if;
      lrec := c1rec.preq_no;
     else
      retvar := retvar || htf.nl || c1rec.preq_no;
     end if;
    end if;
 end loop; 
 
  -- Add code to handle Requisition Item
  lrec := NULL;
 for c1rec in c1(dlr) loop
    if call_type = 'PREQ_ITEM'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.preq_item,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.preq_item;
      end if;
      lrec := c1rec.preq_item;
     else
      retvar := retvar || htf.nl || c1rec.preq_item;
     end if;
    end if;
 end loop; 
 
   -- Add code to handle Order type
 lrec := NULL;
 for c1rec in c1(dlr) loop
    if call_type = 'ORDER_TYPE'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.order_type,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.order_type;
      end if;
      lrec := c1rec.order_type;
     else
      retvar := retvar || htf.nl || c1rec.order_type;
     end if;
    end if;
 end loop; 
 
    -- Add code to handle Plant
 lrec := NULL;
 for c1rec in c1(dlr) loop
    if call_type = 'PLANT'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.plant,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.plant;
      end if;
      lrec := c1rec.plant;
     else
      retvar := retvar || htf.nl || c1rec.plant;
     end if;
    end if;
 end loop; 
 
     -- Add code to handle Warehouse
 lrec := NULL;
 for c1rec in c1(dlr) loop
    if call_type = 'WAREHOUSE'
    then
     if break_on = 'T'
     then
      if lrec is not null and nvl(c1rec.warehouse,'x') = lrec
       then
        retvar := retvar;
       else
        retvar := retvar || htf.nl || c1rec.warehouse;
      end if;
      lrec := c1rec.warehouse;
     elsif break_on = 'G' then
       if c1rec.warehouse is not null then
          retvar := retvar || htf.nl || c1rec.warehouse;  
       end if;
  
     else
      retvar := retvar || htf.nl || c1rec.warehouse;
     end if;
    end if;
 end loop; 
 
if length(retvar) > 4000
 then
  retvar := substr(retvar, 1, 3990); -- Gives a little room for line 93
end if;

 return( substr( retvar,length(htf.nl)+1) );
end f_pos;
/


GRANT EXECUTE ON STRANG.F_POS TO WEBSYS;
