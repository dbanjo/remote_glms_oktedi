CREATE OR REPLACE PROCEDURE WEBSYS."DETAIL_ITEMS_ACCEPT" (surl in varchar2, rid in varchar2, recctr integer, umo in owa.vc_arr, order_by in owa.vc_arr, pktpe_packtype in owa.vc_arr, lngth in owa.vc_arr, width in owa.vc_arr, height in owa.vc_arr, weight in owa.vc_arr, action in varchar2)
 as

 itm_ctr      integer;

 begin
 itm_ctr := 0;
 for j in umo.first..umo.last loop
  itm_ctr := greatest(itm_ctr, umo(j));
  htp.p(umo(j) || ': ' || pktpe_packtype(j)); htp.nl;
 end loop;

 htp.p('Highest number: ' || itm_ctr); htp.nl;

 end detail_items_accept;
/
