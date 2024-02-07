CREATE OR REPLACE PROCEDURE WEBSYS."DETAIL_ITEMS" (surl in varchar2, rid in varchar2, recctr integer, msg in varchar2 default null )
as

 cursor c2(vrid rowid) is
  select rowid, d.*
  from   strang.detailrs d
  where  rowid = vrid
  ;
 cursor c3(vrid rowid, vitm integer) is
  select di.*
  from   strang.detailrs_item di, strang.detailrs d
  where  d.rowid = vrid
         and di.deliveryno = d.deliveryno
  order  by di.order_by
  ;

 INVALID_RID exception;
 PRAGMA EXCEPTION_INIT(INVALID_RID, -1410);

 c1rec        customer_account%ROWTYPE;
 c2rec        c2%ROWTYPE;
 pfx          THEME%ROWTYPE;
 ltype        varchar2(100);
 stype        integer;
 owner_id     integer;
 sts          varchar2(100);
 vaccess      varchar2(20);
 vste         varchar2(10);
 seclevel     varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.DETAIL_ITEMS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 -- vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 -- vaccess := data_access( owner_id, 'DETAIL_ITEMS', null );
 seclevel := oltp.security_role( owner_id );

 begin
 open c2(replace(rid, '~', '+'));
 fetch c2 into c2rec;
 close c2;
 exception
  when INVALID_RID then
   htp.htmlopen;
    htp.header(2,'Detail Item not found, ROWID: ' || replace(rid, '~', '+'), 'CENTER' );
    htp.header(3,'Hit the back button and retry', 'CENTER' );
    htp.header(3,'If problem persists, please contact the administrator', 'CENTER' );
   htp.htmlclose;
   return;
 end;

 htp.htmlopen;
 htp.headopen;
 htp.p('<link rel="stylesheet" type="text/css" href="/images/str/style.css" />');
 htp.p('<script type="text/javascript" src="/images/js/js_functions.js"></script>');
 htp.headclose;

 htp.bodyopen;

 htp.header(2,'Detail: ' || c2rec.deliveryno, 'CENTER' );
 htp.header(2,'Item #: ' || c2rec.itemno, 'CENTER' );
 htp.formopen( 'detail_items_accept', cattributes=>'name="item_box"' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'RECCTR', recctr );

 htp.tableopen(cattributes=>'id="DetailItem"');
 htp.tablerowopen;
  htp.p('<TH>Print<br>');
   htp.p('<a href="javascript:;" onclick="insRow_DetailItem(this,''DetailItem'')">[Ins]</a>');
  htp.p('</TH>');
  htp.tableheader('Pack Type');
  htp.tableheader('Length (cm)');
  htp.tableheader('Width (cm)');
  htp.tableheader('Height (cm)');
  htp.tableheader('Weight (kg)');
 htp.tablerowclose;
 for c3rec in c3(rid, recctr) loop
  htp.tablerowopen;
   htp.tabledata(htf.formhidden('order_by', c3rec.order_by) || htf.formcheckbox( 'UMO', 'T', cattributes=>'CHECKED' ) );
   htp.p('<td>');
    htp.formselectopen('PKTPE_PACKTYPE');
     if c3rec.pktpe_packtype = 'BDL' then htp.formselectoption('Bundle', 'SELECTED', cattributes=>'value="BDL"'); else htp.formselectoption( 'Bundle', cattributes=>'value="BDL"'); end if;
     if c3rec.pktpe_packtype = 'CRTE' then htp.formselectoption('Crate', 'SELECTED', cattributes=>'value="CRTE"'); else htp.formselectoption( 'Crate', cattributes=>'value="CRTE"'); end if;
     if c3rec.pktpe_packtype = 'CTN' then htp.formselectoption('Carton', 'SELECTED', cattributes=>'value="CTN"'); else htp.formselectoption( 'Carton', cattributes=>'value="CTN"'); end if;
     if c3rec.pktpe_packtype = 'CTNS' then htp.formselectoption('Cartons', 'SELECTED', cattributes=>'value="CTNS"'); else htp.formselectoption( 'Cartons', cattributes=>'value="CTNS"'); end if;
     if c3rec.pktpe_packtype = 'ITEM' then htp.formselectoption('Item', 'SELECTED', cattributes=>'value="ITEM"'); else htp.formselectoption( 'Item', cattributes=>'value="ITEM"'); end if;
     if c3rec.pktpe_packtype = 'PLT' then htp.formselectoption('Pallet', 'SELECTED', cattributes=>'value="PLT"'); else htp.formselectoption( 'Pallet', cattributes=>'value="PLT"'); end if;
     if c3rec.pktpe_packtype = 'PLTS' then htp.formselectoption('Pallets', 'SELECTED', cattributes=>'value="PLTS"'); else htp.formselectoption( 'Pallets', cattributes=>'value="PLTS"'); end if;
     if c3rec.pktpe_packtype = 'SKID' then htp.formselectoption('Skid', 'SELECTED', cattributes=>'value="SKID"'); else htp.formselectoption( 'Skid', cattributes=>'value="SKID"'); end if;
     if c3rec.pktpe_packtype = 'TOTE' then htp.formselectoption('Tote', 'SELECTED', cattributes=>'value="TOTE"'); else htp.formselectoption( 'Tote', cattributes=>'value="TOTE"'); end if;
     if c3rec.pktpe_packtype = 'TIE' then htp.formselectoption('Tie', 'SELECTED', cattributes=>'value="TIE"'); else htp.formselectoption( 'Tie', cattributes=>'value="TIE"'); end if;
   htp.formselectclose;
   htp.p('</td>');
   htp.tabledata( htf.formtext('LNGTH', 10, 10, c3rec.lngth));
   htp.tabledata( htf.formtext('WIDTH', 10, 10, c3rec.width));
   htp.tabledata( htf.formtext('HEIGHT', 10, 10, c3rec.height));
   htp.tabledata( htf.formtext('WEIGHT', 10, 10, c3rec.weight));
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.p( '<input type="button" onclick="resetvals(this.form);" value="Check all"><input type="button" onclick="resetvalsoff(this.form);" value="Uncheck all">' );
 htp.nl;
 htp.formsubmit('action','Print Tags');
 htp.formsubmit('action','Update');
 htp.formsubmit('action','Cancel');
 htp.formclose;
 htp.bodyclose;
 htp.htmlclose;
 return;

 exception
  when others then
  htp.p('Error: ' || sqlerrm);
 end detail_items;
/
