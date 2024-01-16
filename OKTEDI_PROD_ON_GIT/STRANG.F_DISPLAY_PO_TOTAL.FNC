CREATE OR REPLACE function STRANG.f_display_po_total( iDelNo number )
 return varchar2
as

 cursor c1(iDelNo number) is
  select sum(p.tamount+p.delivery_charge) po_total
  from strang.pos p
  where p.deliveryno = iDelNo;


 c1rec  c1%ROWTYPE;
 retvar	varchar2(32767);


begin
    open c1(iDelNo);
    fetch c1 into c1rec;
    close c1;
   return( to_char(nvl(c1rec.po_total,'0.00')) );
--   return( to_char(nvl(c1rec.po_total,'0.00'),'999,999,990.99') );
end f_display_po_total;
/


GRANT EXECUTE ON STRANG.F_DISPLAY_PO_TOTAL TO WEBSYS;
