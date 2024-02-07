CREATE OR REPLACE PROCEDURE WEBSYS."SCAN_ITEM" (delivery_no number default null, movement_no varchar2 default null, msg varchar2 default null) as
begin
htp.p('<!DOCTYPE html>');
htp.htmlopen;
htp.headopen;
htp.p('<meta name="viewport" content="width=device-width, initial-scale=1">');
htp.p('<link rel="stylesheet" href="https://www.w3schools.com/w3css/4/w3pro.css">');
htp.headclose;
htp.bodyopen;

htp.tableopen;
  htp.tablerowopen;
  htp.tableheader('Delivery #:');
  htp.tabledata(delivery_no);
  if delivery_no is not null and movement_no is not null
   then
     htp.tabledata('<img src="/images/str/link.png" alt="Clear All" style="width:100px;">', cattributes=>'rowspan="2"');
  end if;
  htp.tablerowclose;

  htp.tablerowopen;
  htp.tableheader('Container:');
  htp.tabledata(movement_no);
  htp.tablerowclose;
htp.tableclose;
htp.formopen('accept_scan_item', cattributes=>'name="inputForm1"');
htp.formhidden('delivery_no', delivery_no);
htp.formhidden('movement_no', movement_no);
htp.p('<div class="w3-cell-row">');
 htp.p('<div class="w3-cell w3-container">');
  htp.formtext('v_item', cattributes=>'id="inputText1" autofocus onfocus="this.value=''''" onblur="inputForm1.submit()"');
 htp.p('</div>');
htp.p('</div>');
htp.formclose;
htp.nl;
htp.p('<a href="accept_scan_item?v_item=&action=Clear Receival&delivery_no=' || delivery_no || '&movement_no=' || movement_no || '">');
  htp.p('<img src="/images/str/clear_receivals.png" alt="Clear Receival" style="width:100px;height:100px;">');
htp.p('</a>');
htp.p('<a href="accept_scan_item?v_item=&action=Clear Movement&delivery_no=' || delivery_no || '&movement_no=' || movement_no || '">');
  htp.p('<img src="/images/str/clear_containers.png" alt="Clear Movement" style="width:100px;height:100px;">');
htp.p('</a>');
htp.p('<a href="accept_scan_item?v_item=&action=Clear">');
  htp.p('<img src="/images/str/clear_all.png" alt="Clear All" style="width:100px;height:100px;">');
htp.p('</a>');
htp.nl;
if delivery_no is not null and movement_no is not null
 then
  htp.p('<a href="accept_scan_item?v_item=&action=Unload Item&delivery_no=' || delivery_no || '&movement_no=' || movement_no || '">');
    htp.p('<img src="/images/str/unload_item.png" alt="Unload Item" style="width:100px;height:100px;">');
  htp.p('</a>');
 else
   htp.p('<img src="/images/str/blank_200_200.png" alt="Unload Item" style="width:100px;height:100px;">');
end if;
htp.formclose;

if msg is not null
 then
  htp.header(3, msg); htp.nl;
end if;

htp.bodyclose;
htp.htmlclose;
end scan_item;
/
