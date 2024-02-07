CREATE OR REPLACE PROCEDURE WEBSYS."ACCEPT_SCAN_ITEM" (v_item varchar2, delivery_no number default null, movement_no varchar2 default null, action varchar2 default null)
as
cursor c1(vval number) is select deliveryno from strang.receivals where deliveryno = vval;
cursor c2(vval varchar2) is
 select movement_no, seal
 from   strang.movements
 where  movement_no = vval
 ;

c1rec         c1%ROWTYPE;
TYPE t_mov    is table of c2%ROWTYPE index by binary_integer;
v_mov         t_mov;
v_msg         varchar2(1000);

begin
 case nvl(action, 'Cancel')
 when 'Clear'
  then
   v_msg := 'Values cleared';
   scan_item(msg=>v_msg);
   return;
 when 'Clear Receival'
  then
   v_msg := 'Receival Item cleared';
   scan_item(movement_no=>movement_no, msg=>v_msg);
   return;
 when 'Clear Movement'
  then
   v_msg := 'Container # cleared';
   scan_item(delivery_no=>delivery_no, msg=>v_msg);
   return;
 when 'Unload Item'
  then
    v_msg := 'Receivals item ' || delivery_no || '<br>unloaded from<br>container ' || movement_no;
   scan_item(movement_no=>movement_no, msg=>v_msg);
   return;
 else null;
 end case;

 if v_item is null
  then
   scan_item(movement_no=>movement_no, delivery_no=>delivery_no);
   return;
 end if;

 open c1(glbx.guess_number(trim(v_item)));
 fetch c1 into c1rec;
 close c1;
 if c1rec.deliveryno is not null
  then
   if movement_no is not null
    then
	 v_msg := 'Receivals item ' || c1rec.deliveryno || '<br>added to<br>container ' || movement_no;
   end if;
   scan_item(delivery_no=>c1rec.deliveryno, movement_no=>movement_no, msg=>v_msg);
   return;
 end if;

 open c2(trim(v_item));
 fetch c2 bulk collect into v_mov;
 close c2;

 if v_mov.count > 0
  then
   if delivery_no is not null
    then
	 v_msg := 'Receivals item ' || delivery_no || '<br>added to<br>container ' || v_mov(1).movement_no;
   end if;
   scan_item(delivery_no=>delivery_no, movement_no=>v_mov(1).movement_no, msg=>v_msg);
   return;
 end if;

 v_msg := 'Unknown code: ' || v_item;

 scan_item(delivery_no=>delivery_no, movement_no=>movement_no, msg=>v_msg);
 return;
exception when others then
 scan_item(msg=>'Error: ' || sqlerrm);
end accept_scan_item;
/
