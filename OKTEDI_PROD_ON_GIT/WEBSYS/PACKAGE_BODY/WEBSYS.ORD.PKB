CREATE OR REPLACE package body WEBSYS.ord
as


  ENCRYPT_KEY	constant varchar2(30)	:= 'TVBBC';
  NL_CHAR constant char(1) := chr(10);

  function  get_lab_id( owner_id in integer) return manufacturer%ROWTYPE;
  function  check_cntry( phgid in integer, acid in integer, sess_id in integer ) return boolean;
  procedure purchase_audit_trail( vpoid in integer, colname in varchar2, vaction in char, vchange in char, newval in varchar2 );


procedure accept_merchant_safepay(SESSIONID in varchar2, MERCHANTID in varchar2, PURCHASEAMOUNT in varchar2, LOCALE in varchar2, RECEIPTNO in varchar2, TRANSACTIONNO in varchar2, ACQRESPONSECODE in varchar2, QSIRESPONSECODE in varchar2 )
as
begin
 --
 -- Kept for Backwards Compatability Only
 --
 fname.accept_merchant_safepay(SESSIONID,MERCHANTID,PURCHASEAMOUNT,LOCALE,RECEIPTNO,TRANSACTIONNO,ACQRESPONSECODE,QSIRESPONSECODE);

end accept_merchant_safepay;

procedure accept_pay_by_credit( surl varchar2,CreditCardNumber in varchar2 default null, CreditCardType in varchar2 default null, ExpirationYear in varchar2 default null, ExpirationMonth in varchar2 default null, ExpirationDay in varchar2 default null, cc4 in varchar2 default null, HomeURL in varchar2 default null )
as
begin
 --
 -- Kept for Backwards Compatability Only
 --
 fname.accept_pay_by_credit(surl,CreditCardNumber,CreditCardType,ExpirationYear,ExpirationMonth,ExpirationDay,cc4,HomeURL);

end accept_pay_by_credit;

function check_cntry( phgid in integer, acid in integer, sess_id in integer )
 return boolean
is

 cursor c1( sess_id integer ) is select country from login_session where sessid=sess_id;
 c1rec	c1%ROWTYPE;

begin
 open c1( sess_id );
 fetch c1 into c1rec;
 close c1;
 if c1rec.country is null then return( TRUE ); end if;
 if glbx.userpref( phgid, acid, 'HOME_CTRY' ) = c1rec.country then return( TRUE ); end if;
 return( FALSE );
exception
 when others then return( TRUE );
end check_cntry;

procedure workflow_order( surl in varchar2, acid in integer, ws in integer default null, wspd in integer default null )
as

 cursor c1(photid integer) is select * from customer_account where aid=acid and pid=photid;
 cursor c2(phgid integer, acid integer ) is
  select /*+ ALL_ROWS */ ws.workflow_name, ws.status_workflow, nvl(sb.priority_of_item,0) status_priority_default, count('x') tot
  from workflow_set ws, shopping_basket sb, purchase_order po, login_session ls
  where sb.poid = po.poid and
        ws.status_workflow = sb.status_workflow and
        po.pid = phgid and
        ls.sessid = po.sessid and
        (
         (ls.aid = acid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = acid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = phgid and ls.login_type = 'PHOTOGRAPHER' )
        )
  group by ws.workflow_name, ws.status_workflow, nvl(sb.priority_of_item,0);

 cursor c3(phgid integer, acid integer, wsn integer, wspd integer ) is
  select /*+ ALL_ROWS */ ws.workflow_name, sb.status_id, sb.priority_of_item status_priority_default, sb.poid, sb.shopping_id, sb.estimated_due_date, sb.qty, sb.photo_size, sb.photo_cost, sb.film_name
  from workflow_set ws, shopping_basket sb, purchase_order po, login_session ls
  where sb.poid = po.poid and
        ws.status_workflow = sb.status_workflow and
        po.pid = phgid and
        ws.status_workflow = wsn and
        nvl(sb.priority_of_item,0) = nvl(wspd,0) and
        ls.sessid = po.sessid and
        (
         (ls.aid = acid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = acid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = phgid and ls.login_type = 'PHOTOGRAPHER' )
        )
  order by estimated_due_date, shopping_id;

 cursor c5(ws integer) is select * from workflow_set where status_workflow = ws;

 c1rec 		c1%ROWTYPE;
 c5rec 		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 ttl		number;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ORD.WORKFLOW_ORDER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id );
 fetch c1 into c1rec;
 close c1;
 theme_rec := glbx.get_theme_types( c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG4.AHC_TXT_813,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'O14',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 if ws is null and wspd is null
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( LNG4.AHC_TXT_612, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG4.AHC_TXT_726, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG.CST_TXT_138, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
   for c2rec in c2(owner_id, acid ) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'ord.workflow_order?surl=' || surl || '&acid=' || acid || '&ws=' || c2rec.status_workflow || '&wspd=' || c2rec.status_priority_default, c2rec.workflow_name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( c2rec.status_priority_default, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( to_char(c2rec.tot), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid, LNG.ORD_ALT_062 );
   htp.nl;

  else

   open c5(ws);
   fetch c5 into c5rec;
   close c5;
   htp.bold( LNG4.AHC_TXT_612 || ':' || c5rec.workflow_name );
   htp.nl;
   htp.bold( LNG4.AHC_TXT_726 || ':' || wspd );
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( LNG.CST_TXT_099, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG4.AHC_TXT_937, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG5.EXT_TXT_098, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG.PHG_TXT_178, cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
   for c3rec in c3(owner_id, acid, ws, wspd ) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'ord.modify_order?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&purchord=' || c3rec.poid || '&typ=' || 'WORKFLOW',c3rec.poid),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( c3rec.shopping_id, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( nvl(to_char(c3rec.estimated_due_date,LNG.MASK),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( c3rec.film_name || '-' || c3rec.photo_size || '-' || to_char(c3rec.photo_cost,LNG.MONEY_FORMAT) || '(' || c3rec.qty || ')', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.anchor( 'ord.workflow_order?surl=' || surl || '&acid=' || acid || '&ws=&wspd=', LNG.ORD_ALT_062 );
   htp.nl;
 end if;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ORD', 'WORKFLOW_ORDER',errmsg=>sqlerrm);
end workflow_order;

procedure phg_acct_orders( surl in varchar2, acid in integer, typ in varchar2, comma_delim in varchar2 default null, tm in char default 'L' )
as

 cursor c1(photid integer) is select * from customer_account where aid=acid and pid=photid;

 cursor c2(phgid integer, acid integer, typ varchar2, tm char) is
  select po.poid,po.status,po.date_purchased,po.sendto_name,po.payment_received,po.is_b2c,po.cheque_receipt_number
  from purchase_order po, login_session ls
  where (( status = decode(typ, 'NEW', 'Ordered', 'PREORDERX', 'PreOrder', 'ARCHIVED', LNG.ORD_TXT_127, 'COMPLETED', LNG.ORD_TXT_199, status )) or
         ( status = decode(typ, 'NEW', 'Order Payment Received', 'PREORDERX', 'PreOrder - Sent to Bank' )) or
         ( status = decode(typ, 'NEW', 'Order Authorised', 'PREORDERX', 'Awaiting Authorisation')) or
         ( status = decode(typ, 'PREORDERX', 'PreOrder - Confirmed without Payment') )
        ) and
        po.date_created > (sysdate - decode(tm,'A',1,'B',7,'C',14,'D',31,'E',60,'F',90,'G',183,'H',366,'I',10000,0)) and
        is_b2c = decode(typ, 'LAB', 'T', 'F' ) and
        (typ <> 'ACTIVE' or (typ = 'ACTIVE' and status in (LNG.ORD_TXT_202,LNG.ORD_TXT_203,LNG.ORD_TXT_204,LNG.ORD_TXT_125,LNG.ORD_TXT_210,LNG.ORD_TXT_211 ))) and
        (typ <> 'CANCELLED' or (typ = 'CANCELLED' and status in (LNG.ORD_TXT_128,LNG.ORD_TXT_129 ))) and
        (typ <> 'PREORDER' or (typ = 'PREORDER' and status in (LNG.ORD_TXT_120,LNG4.AHC_TXT_706,LNG4.AHC_TXT_672,'PreOrder - Confirmed without Payment' ))) and
        po.pid = phgid and
        ((typ = 'PREORDERX' and (nvl(length(sendto_name),0) + nvl(length(contact_email),0)) > 0) or (typ <> 'PREORDERX')) and
        po.sessid = ls.sessid and
        (
         (ls.aid = acid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = acid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = phgid and ls.login_type = 'PHOTOGRAPHER' )
        )
  order by decode(po.status,LNG.ORD_TXT_120,0,LNG4.AHC_TXT_672,0,'PreOrder - Confirmed without Payment',0,LNG4.AHC_TXT_706,0,LNG.ORD_TXT_121,1,2),po.date_purchased desc;

 cursor c3(phgid integer, acid integer, typ varchar2, tm char) is
  select po.poid,po.status,po.date_purchased,po.sendto_name,po.payment_received,po.is_b2c,po.cheque_receipt_number
  from purchase_order po, login_session ls
  where nvl(paid_method,'UND') = typ and
        po.pid = phgid and
        status not in ('PreOrder - No Order Made') and
        po.date_created > (sysdate - decode(tm,'A',1,'B',7,'C',14,'D',31,'E',60,'F',90,'G',183,'H',366,'I',10000,0)) and
        po.sessid = ls.sessid and
        (
         (ls.aid = acid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = acid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = phgid and ls.login_type = 'PHOTOGRAPHER' )
        )
  order by decode(po.status,LNG.ORD_TXT_120,0,LNG4.AHC_TXT_672,0,'PreOrder - Confirmed without Payment',0,LNG4.AHC_TXT_706,0,LNG.ORD_TXT_121,1,2),po.date_purchased desc;

 c1rec 		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 ttl		number;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ORD.PHG_ACCT_ORDERS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id );
 fetch c1 into c1rec;
 close c1;
 theme_rec := glbx.get_theme_types( c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 if comma_delim is null
  then
   glbx.main_title( surl, LNG.PHG_TXT_079,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'O14',stype=>stype+1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   htp.nl;
   htp.bold(typ);
   htp.nl;
   htp.nl;
   htp.bold(htf.italic( LNG.PHG_TXT_080 ));
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_081 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_082 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_083 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_084 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_085 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('<b><font size="+1">' || LNG.ORD_TXT_108 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('<b><font size="+1">' || LNG.ORD_TXT_145 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('<b><font size="+1">' || LNG.ORD_TXT_193 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
 end if;

 if typ in ('MERCHANT','GIFT','PHONE','CHEQUE','BILLING','AUTHORISATION','UND') and comma_delim is null
  then
    for c2rec in c3(owner_id, acid, typ,tm) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'ord.modify_order?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&purchord=' || c2rec.poid || '&typ=' || typ,c2rec.poid),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( nvl(to_char(c2rec.date_purchased,LNG.MASK),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( nvl(c2rec.sendto_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     ttl := glbx.total_payment(c2rec.poid);
      htp.tabledata( nvl(to_char(ttl,LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( nvl(to_char(glbx.grand_total_payment( c2rec.poid, include_gift_certificate=>FALSE ),LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     if nvl(c2rec.payment_received,'F') = 'F'
      then
       htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      else
       htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     if c2rec.is_b2c = 'T'
      then
       htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      else
       htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
    htp.tablerowclose;
   end loop;

 elsif comma_delim is null
  then
    for c2rec in c2(owner_id, acid, typ,tm) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'ord.modify_order?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&purchord=' || c2rec.poid || '&typ=' || typ,c2rec.poid),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( nvl(to_char(c2rec.date_purchased,LNG.MASK),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( nvl(c2rec.sendto_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     ttl := glbx.total_payment(c2rec.poid);
      htp.tabledata( nvl(to_char(ttl,LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata( nvl(to_char(glbx.grand_total_payment( c2rec.poid, include_gift_certificate=>FALSE ),LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     if nvl(c2rec.payment_received,'F') = 'F'
      then
       htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      else
       htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     if c2rec.is_b2c = 'T'
      then
       htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      else
       htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
    htp.tablerowclose;
   end loop;

  else
   -- Download Comma Delimited File
   htp.prn('Content-type: ' || 'bad/type' || chr(10));
   htp.prn('Content-Disposition: attachment; filename=' || 'purchase_orders_' || to_char(sysdate,'dd_mon_yyyy') || '.csv' || chr(10));
   htp.prn('Content-Transfer-Encoding: binary' || chr(10));
   htp.prn(chr(10));
   htp.p( '"Purchase Request Id","Status","Date Purchased","Send To Name","Sub Total","Grand Total","Payment Received","Is Lab Managed","Cheque Number"');
   if typ in ('MERCHANT','GIFT','PHONE','CHEQUE','BILLING','AUTHORISATION','UND')
    then
     for c2rec in c3(owner_id, acid, typ,tm) loop
      ttl := glbx.total_payment(c2rec.poid);
      htp.prn( '"' || c2rec.poid || '",' );
      htp.prn( '"' || c2rec.status || '",' );
      htp.prn( '"' || nvl(to_char(c2rec.date_purchased,LNG.MASK),'') || '",' );
      htp.prn( '"' || nvl(c2rec.sendto_name,'') || '",' );
      htp.prn( '"' || nvl(to_char(ttl,LNG.MONEY_FORMAT),'') || '",' );
      htp.prn( '"' || nvl(to_char(glbx.grand_total_payment( c2rec.poid, include_gift_certificate=>FALSE ),LNG.MONEY_FORMAT),'') || '",' );
       if nvl(c2rec.payment_received,'F') = 'F'
        then
         htp.prn( '"' || LNG.PHG_TXT_046 || '",' );
        else
         htp.prn( '"' || LNG.PHG_TXT_045 || '",' );
       end if;
       if c2rec.is_b2c = 'T'
        then
         htp.prn( '"' || LNG.PHG_TXT_046 || '",' );
        else
         htp.prn( '"' || LNG.PHG_TXT_046 || '",' );
       end if;
       htp.prn( '"' || c2rec.cheque_receipt_number || '"' );
       htp.prn(chr(10));
     end loop;

    else

     for c2rec in c2(owner_id, acid, typ,tm) loop
      ttl := glbx.total_payment(c2rec.poid);
      htp.prn( '"' || c2rec.poid || '",' );
      htp.prn( '"' || c2rec.status || '",' );
      htp.prn( '"' || nvl(to_char(c2rec.date_purchased,LNG.MASK),'') || '",' );
      htp.prn( '"' || nvl(c2rec.sendto_name,'') || '",' );
      htp.prn( '"' || nvl(to_char(ttl,LNG.MONEY_FORMAT),'') || '",' );
      htp.prn( '"' || nvl(to_char(glbx.grand_total_payment( c2rec.poid, include_gift_certificate=>FALSE ),LNG.MONEY_FORMAT),'') || '",' );
       if nvl(c2rec.payment_received,'F') = 'F'
        then
         htp.prn( '"' || LNG.PHG_TXT_046 || '",' );
        else
         htp.prn( '"' || LNG.PHG_TXT_045 || '",' );
       end if;
       if c2rec.is_b2c = 'T'
        then
         htp.prn( '"' || LNG.PHG_TXT_046 || '",' );
        else
         htp.prn( '"' || LNG.PHG_TXT_046 || '",' );
       end if;
       htp.prn( '"' || c2rec.cheque_receipt_number || '"' );
       htp.prn(chr(10));
     end loop;
   end if;
 end if;

 if comma_delim is null
  then
   htp.tableclose;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0');
   htp.tablerowopen;
   htp.p( '<TD>' );
    htp.formopen( 'ord.phg_ord_prefs' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACID', acid );
     htp.formsubmit( null, LNG.PHG_BUT_112 );
    htp.formclose;
   htp.p( '</TD>' );
   htp.p( '<TD>' );
    htp.formopen( 'ord.phg_acct_orders' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACID', acid );
     htp.formhidden( 'TYP', typ );
     htp.formhidden( 'COMMA_DELIM', 'COMMA' );
     htp.formsubmit( null, LNG.PHG_BUT_312 );
    htp.formclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
 end if;
exception when others then
 glbx.error_details( 'ORD', 'PHG_ACCT_PRDERS',owner_id,acid,errmsg=>sqlerrm);
end phg_acct_orders;

procedure modify_order( surl varchar2,acid in integer, purchord in integer, msg in varchar2 default null, prnt_type in varchar2 default 'STANDARD', typ in varchar2 )
as

 cursor c1(photid integer) is select * from customer_account where aid=acid and pid=photid;
 cursor c2(phgid integer, purchord integer) is select * from purchase_order where poid=purchord and pid=phgid;
 cursor c3(purchord integer) is select pnumber,contact_det from order_contact_phone_number where poid=purchord;
 cursor c4(purchord integer) is
  select sb.shopping_id, sb.phid, sb.qty, sb.photo_size, sb.photo_cost, sb.frame_style, sb.frame_cost,sb.alteration,sb.alteration_cost
  from shopping_basket sb
  where sb.poid=purchord
  order by shopping_id;
 cursor c5(wstate integer) is select order_option from workflow_state_options where work_state = wstate order by order_by;
 cursor c6(phgid integer) is select * from photographer where pid = phgid;
 cursor c7(purchord integer) is select count('x') tot from shopping_basket where status_workflow is not null and poid = purchord;
 cursor c8(purchord integer) is select * from audit_failed_merchant where poid = purchord order by date_created desc;

 c1rec 		c1%ROWTYPE;
 c2rec 		c2%ROWTYPE;
 c6rec 		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(2000);
 photodisc	number;
 disc_perc	number;
 disc_if	number;
 ttl		number;
 gst		number;
 fnd		boolean;
 photo_name	varchar2(100);
 pfx		THEME%ROWTYPE;
 prnt		varchar2(20);
 theme_rec	theme_types%ROWTYPE;
 options	GLBX.MYARRAY;

 -- prnt - All, Status, Comment, Print
begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ORD.MODIFY_ORDER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id );
 fetch c1 into c1rec;
 close c1;
 open c2( owner_id, purchord );
 fetch c2 into c2rec;
 close c2;
 theme_rec := glbx.get_theme_types( c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 --htp.p('<CENTER>');
 if prnt_type in (LNG.ORD_TXT_001,LNG.ORD_TXT_002)
  then
   prnt := 'READ';
  else
   if c2rec.is_b2c = 'T'
    then
     prnt := 'COMMENT';
    else
     if c2rec.status in (LNG.ORD_TXT_121,LNG.ORD_TXT_202,LNG.ORD_TXT_203,LNG.ORD_TXT_204,LNG.ORD_TXT_125,LNG.ORD_TXT_210,LNG.ORD_TXT_211 )
      then
       prnt := 'ALL';
      else
       prnt := 'STATUS';
     end if;
   end if;
 end if;

 -- Check if a Workflow is in the Order
 open c7(purchord);
 fetch c7 into c7rec;
 close c7;

 -- Header
 if prnt in ('ALL','STATUS','COMMENT')
  then
   glbx.main_title( surl, LNG.PHG_TXT_086 || purchord,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'O15',stype=>stype+1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.nl;
   htp.bold(htf.italic( LNG.PHG_TXT_087 ));
   htp.nl;
   htp.p( LNG.PHG_TXT_334 ); htp.nl;
   htp.p( LNG.PHG_TXT_335 ); htp.nl;
   if msg is not null then glbx.header_msg( msg );end if;
   htp.nl;
     htp.formopen( 'ord.accept_modify_order' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'PARM1','ACID' );
     htp.formhidden( 'PARM2', acid );
     htp.formhidden( 'PARM1','PURCHORD' );
     htp.formhidden( 'PARM2', purchord );
     htp.formhidden( 'RM', null );
     htp.formhidden( 'TYP', typ );
     htp.formsubmit( 'ACTION', LNG.PHG_BUT_111 );
     if typ <> LNG.GLB_TXT_092 then htp.formsubmit( 'ACTION', LNG.PHG_BUT_112 ); end if;
  else
    glbx.main_title( surl, NULL,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),stype=>stype+1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.p('<form><p><input type="button" value="' || LNG2.FNM_TXT_030 || '" onclick="window.print();"> </p></form>');
    -- GST Details
    htp.p( '<CENTER>' );
    open c6(c1rec.pid);
    fetch c6 into c6rec;
    close c6;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
    htp.p( '<TD ALIGN="CENTER" VALIGN="TOP">' );
     htp.bold( LNG.ORD_TXT_197 );
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
      htp.tablerowopen;
       htp.tabledata( LNG.CST_TXT_004 );
       htp.tabledata( htf.bold(c6rec.business_name) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( c6rec.abn_title );
       htp.tabledata( htf.bold(c6rec.abn_number) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.CST_TXT_113 );
       htp.tabledata( htf.bold(c6rec.contact_street) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.CST_TXT_114 );
       htp.tabledata( htf.bold(c6rec.contact_suburb) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.CST_TXT_115 );
       htp.tabledata( htf.bold(c6rec.contact_city) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.CST_TXT_118 );
       htp.tabledata( htf.bold(c6rec.contact_pcode) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.PHG_TXT_237 );
       htp.tabledata( htf.bold(c6rec.work_phone) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.PHG_TXT_301 );
       htp.tabledata( htf.bold(c6rec.contact_email) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.PHG_TXT_236 );
       htp.tabledata( htf.bold(c6rec.home_site) );
      htp.tablerowclose;
     htp.tableclose;
    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;
    htp.nl;
 end if;

 -- Details
 tmp := htf.formselectopen( 'STS' );
 -- This step is lookng at the purchase order status and not the status of the individual shopping item
 -- This will need to change in later releases
 if prnt in ('ALL','STATUS')
  then
   for c5rec in c5( 0 ) loop
    if c5rec.order_option = c2rec.status
     then
      tmp := tmp || htf.formselectoption( c5rec.order_option, 'SELECTED' );
     else
      tmp := tmp || htf.formselectoption( c5rec.order_option );
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
  else
   tmp := htf.bold( c2rec.status ) || htf.formhidden( 'STS',null);
 end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=0 ' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.GLB_TXT_066 ),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD>' );
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
      htp.tablerowopen;
       htp.p( '<TD>' );
        htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG.PHG_TXT_093 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG.PHG_TXT_094 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          htp.tabledata( htf.bold( to_char(purchord) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG.ORD_TXT_193 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          if (c2rec.is_b2c = 'T')
           then
            htp.tabledata( htf.bold(LNG.PHG_TXT_045),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           else
            htp.tabledata( htf.bold(LNG.PHG_TXT_046),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          end if;
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG.ORD_TXT_179 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          if c2rec.paid_method is null
           then
            htp.tabledata( htf.bold('Not Decided'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          elsif c2rec.paid_method = 'PHONE'
           then
            htp.tabledata( htf.bold(LNG.ORD_TXT_180),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          elsif c2rec.paid_method = 'CHEQUE'
           then
            htp.tabledata( htf.bold('CHEQUE'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          --elsif c2rec.paid_method  in ('MERCHANT','GIFT')
          -- then
          --  htp.tabledata( htf.bold(LNG.ORD_TXT_181),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          elsif c2rec.paid_method = 'AUTHORISATION'
           then
            htp.tabledata( htf.bold(LNG4.AHC_TXT_692),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          elsif c2rec.paid_method = 'BILLING'
           then
            htp.tabledata( htf.bold(LNG4.AHC_TXT_732),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else -- Merchant Facility
            if c2rec.m_rrn is null and c2rec.m_response_code is null and c2rec.m_response_text is null
             then
              htp.tabledata( htf.bold(LNG.ORD_TXT_182),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
             else
              htp.tabledata( htf.bold(LNG.ORD_TXT_182) || htf.nl ||
                             htf.bold(LNG.ORD_TXT_218 || ':') || c2rec.m_rrn || htf.nl ||
                             htf.bold(LNG.ORD_TXT_217 || ':') || c2rec.m_response_text || htf.nl ||
                             htf.bold(LNG.ORD_TXT_216 || ':') || c2rec.m_response_code,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
             end if;
          end if;
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG.ORD_TXT_145 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          if prnt in ('ALL','STATUS','COMMENT')
           then
            if nvl(c2rec.payment_received,'F') = 'F'
             then
              htp.tabledata( htf.formcheckbox( 'PR','T' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
             else
              htp.tabledata( htf.formcheckbox( 'PR','T','CHECKED' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
            end if;
          else
           if nvl(c2rec.payment_received,'F') = 'F'
            then
             htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
            else
             htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           end if;
          end if;
           htp.tablerowopen;
	    htp.tabledata( htf.bold( LNG.ORD_TXT_107 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
	    if prnt = 'ALL'
	     then
	      htp.tabledata( htf.formhidden( 'PARM1','EX1' ) || htf.formtext( 'PARM2', 10, 20, to_char(nvl(c2rec.special_discount,0) ) ) || '%',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
	     else
	      htp.tabledata( nvl(c2rec.special_discount,0) || '%',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
	      if prnt in ('STATUS','COMMENT') then htp.formhidden( 'PARM1','EX1'); htp.formhidden( 'PARM2',null); end if;
	    end if;
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG5.EXT_TXT_164 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
	  htp.tabledata( htf.formhidden( 'PARM1','PAYR' ) || htf.formtext( 'PARM2', 20, 1000, c2rec.cheque_receipt_number),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          htp.tabledata( htf.italic( to_char(c2rec.date_created,LNG.MASK)), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG.PHG_TXT_083 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          htp.tabledata( htf.italic( nvl(to_char(c2rec.date_purchased,LNG.MASK),'&nbsp;')), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold( LNG.PHG_ALT_133 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          htp.tabledata( htf.italic( nvl(to_char(c2rec.date_fulfilled,LNG.MASK),'&nbsp;')), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         htp.tablerowclose;
        htp.tableclose;
       htp.p( '</TD>' );
       htp.p( '<TD VALIGN="TOP">' );
        htp.bold( LNG.ORD_TXT_109 );
        htp.nl;
        if prnt = 'READ'
         then
          if prnt_type = 'STANDARD'
           then
            htp.p(nvl(replace(replace(c2rec.order_comment,chr(10),'<BR>'),chr(13),'<BR>'),'&nbsp;'));
           else
            htp.p(nvl(replace(replace(c2rec.customer_comment,chr(10),'<BR>'),chr(13),'<BR>'),'&nbsp;'));
          end if;
         else
          htp.formhidden( 'PARM1','EX2' );
          if c2rec.order_comment is not null then htp.p(nvl(replace(replace(c2rec.order_comment,chr(10),'<BR>'),chr(13),'<BR>'),'&nbsp;')); end if;
          htp.formtextarea( 'PARM2', 10, 40, cattributes=>'WRAP="VIRTUAL"' );
          htp.nl;
          htp.p( c2rec.customer_comment );
         end if;
       htp.p( '</TD>' );
      htp.tablerowclose;
     htp.tableclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=0 ' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_ALT_399 ),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD>' );
    options(1) := 'BGCOLOUR_HDR:' || pfx.qbground;
    options(2) := 'BGCOLOUR_BDY:' || pfx.qcbground;
    options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
     if prnt_type = LNG.ORD_TXT_002 -- Without Thumbnails
      then
       options(4) := 'NO_THUMBNAIL';
       options(5) := 'NO_LAB';
       options(6) := 'NO_ADMIN';
       options(7) := 'CUSTOMER';
       ord.display_order_subtotal( surl, ltype, c2rec, options );
     elsif prnt_type = LNG.ORD_TXT_001
      then
       options(4) := 'NO_LAB';
       options(5) := 'NO_ADMIN';
       options(6) := 'CUSTOMER';
       ord.display_order_subtotal( surl, ltype, c2rec, options );
      else
       ord.display_order_subtotal( surl, ltype, c2rec, options );
     end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=0 ' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_102 ),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD>' );
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_301 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( htf.formhidden( 'PARM1','CEM' ) || htf.formtext( 'PARM2', 40, 100, c2rec.contact_email),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( c2rec.contact_email,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','CEM'); htp.formhidden( 'PARM2',c2rec.contact_email); end if;
       end if;
      htp.tablerowclose;
      if c2rec.sendto_department is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'Department' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         if prnt = 'ALL'
          then
           htp.tabledata( htf.formhidden( 'PARM1','SHDE' ) || htf.formtext( 'PARM2', 40, 100, c2rec.sendto_department),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata( c2rec.sendto_department,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SHDE'); htp.formhidden( 'PARM2',c2rec.sendto_department); end if;
         end if;
        htp.tablerowclose;
       else
        htp.formhidden('PARM1','SHDE'); htp.formhidden( 'PARM2',c2rec.sendto_department);
      end if;
      if c2rec.sendto_branch is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'Branch' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         if prnt = 'ALL'
          then
           htp.tabledata( htf.formhidden( 'PARM1','SHBR' ) || htf.formtext( 'PARM2', 40, 100, c2rec.sendto_branch),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata( c2rec.sendto_branch,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SHBR'); htp.formhidden( 'PARM2',c2rec.sendto_branch); end if;
         end if;
        htp.tablerowclose;
       else
        htp.formhidden('PARM1','SHBR'); htp.formhidden( 'PARM2',c2rec.sendto_branch);
      end if;
      --xxx
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_084 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( htf.formhidden( 'PARM1','SH1' ) || htf.formtext( 'PARM2', 40, 100, c2rec.sendto_name),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( c2rec.sendto_name,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SH1'); htp.formhidden( 'PARM2',c2rec.sendto_name); end if;
       end if;
      htp.tablerowclose;

      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_100 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( htf.formhidden( 'PARM1','SH2' ) || htf.formtext( 'PARM2', 40, 100, c2rec.sendto_street),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( c2rec.sendto_street,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SH2'); htp.formhidden( 'PARM2',c2rec.sendto_street); end if;
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_101 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( htf.formhidden( 'PARM1','SH3' ) || htf.formtext( 'PARM2', 40, 100, c2rec.sendto_suburb),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( c2rec.sendto_suburb,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SH3'); htp.formhidden( 'PARM2',c2rec.sendto_suburb); end if;
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_102 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( htf.formhidden( 'PARM1','SH4' ) || htf.formtext( 'PARM2', 40, 100, c2rec.sendto_city),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( c2rec.sendto_city,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SH4'); htp.formhidden( 'PARM2',c2rec.sendto_city); end if;
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_103 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( htf.formhidden( 'PARM1','SH5' ) || htf.formtext( 'PARM2', 40, 100, c2rec.sendto_country),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( c2rec.sendto_country,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SH5'); htp.formhidden( 'PARM2',c2rec.sendto_country); end if;
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_104 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( htf.formhidden( 'PARM1','SH6' ) || htf.formtext( 'PARM2', 40, 100, c2rec.sendto_postcode),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( c2rec.sendto_postcode,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SH6'); htp.formhidden( 'PARM2',c2rec.sendto_postcode); end if;
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG2.FNM_TXT_111 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( htf.formhidden( 'PARM1','SH6A' ) || htf.formtext( 'PARM2', 40, 100, c2rec.delivery_time),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( c2rec.delivery_time,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SH6A'); htp.formhidden( 'PARM2',c2rec.delivery_time); end if;
       end if;
      htp.tablerowclose;

      if c2rec.customer_column1 is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'User Defined' || ' ' || '1' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         if prnt = 'ALL'
          then
           htp.tabledata( htf.formhidden( 'PARM1','SHUD1' ) || htf.formtext( 'PARM2', 40, 100, c2rec.customer_column1),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata( c2rec.customer_column1,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SHUD1'); htp.formhidden( 'PARM2',c2rec.customer_column1); end if;
         end if;
        htp.tablerowclose;
       else
           if prnt in ('ALL','STATUS','COMMENT') then htp.formhidden('PARM1','SHUD1'); htp.formhidden( 'PARM2',c2rec.customer_column1); end if;
      end if;
      if c2rec.customer_column2 is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'User Defined' || ' ' || '2' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         if prnt = 'ALL'
          then
           htp.tabledata( htf.formhidden( 'PARM1','SHUD2' ) || htf.formtext( 'PARM2', 40, 100, c2rec.customer_column2),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata( c2rec.customer_column2,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SHUD2'); htp.formhidden( 'PARM2',c2rec.customer_column2); end if;
         end if;
        htp.tablerowclose;
       else
           if prnt in ('ALL','STATUS','COMMENT') then htp.formhidden('PARM1','SHUD2'); htp.formhidden( 'PARM2',c2rec.customer_column2); end if;
      end if;
      if c2rec.customer_column3 is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'User Defined' || ' ' || '3' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         if prnt = 'ALL'
          then
           htp.tabledata( htf.formhidden( 'PARM1','SHUD3' ) || htf.formtext( 'PARM2', 40, 100, c2rec.customer_column3),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata( c2rec.customer_column3,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SHUD3'); htp.formhidden( 'PARM2',c2rec.customer_column3); end if;
         end if;
        htp.tablerowclose;
       else
           if prnt in ('ALL','STATUS','COMMENT') then htp.formhidden('PARM1','SHUD3'); htp.formhidden( 'PARM2',c2rec.customer_column3); end if;
      end if;
      if c2rec.customer_column4 is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'User Defined' || ' ' || '4' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         if prnt = 'ALL'
          then
           htp.tabledata( htf.formhidden( 'PARM1','SHUD4' ) || htf.formtext( 'PARM2', 40, 100, c2rec.customer_column4),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata( c2rec.customer_column4,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SHUD4'); htp.formhidden( 'PARM2',c2rec.customer_column4); end if;
         end if;
        htp.tablerowclose;
       else
           if prnt in ('ALL','STATUS','COMMENT') then htp.formhidden('PARM1','SHUD4'); htp.formhidden( 'PARM2',c2rec.customer_column4); end if;
      end if;
      if c2rec.customer_column5 is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'User Defined' || ' ' || '5' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         if prnt = 'ALL'
          then
           htp.tabledata( htf.formhidden( 'PARM1','SHUD5' ) || htf.formtext( 'PARM2', 40, 100, c2rec.customer_column5),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata( c2rec.customer_column5,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SHUD5'); htp.formhidden( 'PARM2',c2rec.customer_column5); end if;
         end if;
        htp.tablerowclose;
       else
           if prnt in ('ALL','STATUS','COMMENT') then htp.formhidden('PARM1','SHUD5'); htp.formhidden( 'PARM2',c2rec.customer_column5); end if;
      end if;
      if c2rec.customer_column6 is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold( 'User Defined' || ' ' || '6' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         if prnt = 'ALL'
          then
           htp.tabledata( htf.formhidden( 'PARM1','SHUD6' ) || htf.formtext( 'PARM2', 40, 100, c2rec.customer_column6),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata( c2rec.customer_column6,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           if prnt in ('STATUS','COMMENT') then htp.formhidden('PARM1','SHUD6'); htp.formhidden( 'PARM2',c2rec.customer_column6); end if;
         end if;
        htp.tablerowclose;
       else
           if prnt in ('ALL','STATUS','COMMENT') then htp.formhidden('PARM1','SHUD6'); htp.formhidden( 'PARM2',c2rec.customer_column6); end if;
      end if;

      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.ORD_TXT_180 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
       if prnt = 'ALL'
        then
         htp.tabledata( nvl(c2rec.contact_phone,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
        else
         htp.tabledata( nvl(c2rec.contact_phone,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       end if;
      htp.tablerowclose;
      htp.tablerowopen;
          htp.tabledata( htf.bold( LNG4.AHC_TXT_113 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
          htp.tabledata( c2rec.customer_comment,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tablerowclose;
      if prnt <> 'READ' then htp.formhidden( 'P1', null ); htp.formhidden( 'P2', null ); end if;
      for c3rec in c3(purchord) loop
       htp.tablerowopen;
        htp.tabledata( htf.bold(LNG.ORD_TXT_187),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
        if prnt = 'ALL'
         then
          htp.tabledata( htf.formtext( 'P1', 15, 20, c3rec.pnumber ) || htf.formtext( 'P2', 25, 200, c3rec.contact_det),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         else
          htp.tabledata( c3rec.pnumber || ' - ' || c3rec.contact_det,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
          htp.formhidden( 'P1', c3rec.pnumber );
          htp.formhidden( 'P2', c3rec.contact_det );
        end if;
       htp.tablerowclose;
      end loop;
      if prnt = 'ALL'
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.ORD_TXT_187),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
         htp.tabledata( htf.formtext( 'P1', 15, 20, null ) || htf.formtext( 'P2', 25, 200, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      end if;
      htp.tablerowclose;
     htp.tableclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;

  if (c2rec.contact_email is not null) and (c2rec.contact_password is not null)
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=0 ' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.ORD_TXT_122 ),cattributes=>'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.p( '<TD>' );
       htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
        htp.tablerowopen;
        htp.tabledata( htf.bold( LNG.ORD_TXT_031 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
        if c2rec.event_confirmed = 'T'
           then
            htp.tabledata(LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           else
            htp.tabledata(LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         end if;
        htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.bold( LNG.ORD_TXT_183 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
        if c2rec.event_issue = 'T'
           then
            htp.tabledata(LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           else
            htp.tabledata(LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         end if;
       htp.tablerowclose;
       htp.tablerowopen;
        htp.tabledata( htf.bold( LNG.ORD_TXT_184 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
        if c2rec.event_shipped = 'T'
           then
            htp.tabledata(LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
           else
            htp.tabledata(LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         end if;
         htp.tablerowclose;
       htp.tableclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    else
     htp.nl;
     htp.bold( LNG.ORD_TXT_123 );
     htp.nl;
  end if;
  htp.nl;

 if c2rec.paid_method = 'MERCHANT' and prnt = 'ALL'
  then
   fnd := FALSE;
   for c8rec in c8(c2rec.poid) loop
    if c8%ROWCOUNT = 1
     then
      fnd := TRUE;
      htp.nl;
      htp.bold( 'Failed Merchant Transactions' );
      htp.tableopen( cattributes=>'cellspacing=1 cellpadding=1 border=1' );
       htp.tablerowopen;
        htp.tabledata( 'Date', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( 'Response Code', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( 'Response Text', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( 'Settlement Date', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( 'Receipt Number', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tablerowclose;
    end if;
    htp.tablerowopen;
     htp.tabledata( to_char(c1rec.date_created,LNG.TSMASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( nvl(c8rec.m_response_code,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( nvl(c8rec.m_response_text,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( nvl(c8rec.m_settlement_date,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( nvl(c8rec.m_rrn,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
   end loop;
   if fnd then htp.tableclose; htp.nl; end if;
 end if;

 if prnt in ('ALL','STATUS','COMMENT')
  then
   htp.formsubmit( 'ACTION', LNG.PHG_BUT_111 );
   if typ <> LNG.GLB_TXT_092 then htp.formsubmit( 'ACTION', LNG.PHG_BUT_112 ); end if;
   if c2rec.status in ( LNG.ORD_TXT_128, LNG.ORD_TXT_129)
    then
     htp.formsubmit( 'ACTION', LNG.PHG_BUT_119 );
   end if;
   htp.formclose;
   htp.nl;
     htp.anchor2( 'ord.audit_trail?surl=' || surl || '&acid=' || acid || '&purchord=' || purchord, LNG4.AHC_TXT_102, ctarget=>'AUDIT_WINDOW' );
   htp.nl;
   htp.line;
   htp.nl;
   htp.nl;
   htp.bold( LNG2.FNM_TXT_176 );
   htp.nl;
   htp.bold( LNG2.FNM_TXT_169);
   htp.nl;
   htp.nl;
   htp.tableopen;
    htp.tablerowopen;
     htp.tabledata(htf.formopen('ord.modify_order') || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) || htf.formhidden( 'PURCHORD', purchord ) || htf.formhidden( 'TYP', typ ) || htf.formsubmit( 'PRNT_TYPE',LNG.ORD_TXT_001) || htf.formclose );
     htp.tabledata(htf.formopen('ord.modify_order') || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) || htf.formhidden( 'PURCHORD', purchord ) || htf.formhidden( 'TYP', typ ) || htf.formsubmit( 'PRNT_TYPE',LNG.ORD_TXT_002) || htf.formclose );
    htp.tablerowclose;
   htp.tableclose;
 end if;

 --htp.p('</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ORD', 'MODIFY_ORDER',owner_id,acid,errmsg=>sqlerrm,extdet=>'PURCHORD:' || purchord);
end modify_order;

procedure accept_modify_order(surl varchar2, parm1 in MYARRAY, parm2 in MYARRAY, p1 in MYARRAY, p2 in MYARRAY, rm in MYARRAY, action in varchar2, sts in varchar2, pr in varchar2 default 'F', typ in varchar2 )
as

 cursor c2(purchid integer) is select * from purchase_order where poid = purchid;
 cursor c4(phgid integer) is select business_name from photographer where pid = phgid;
 cursor c5(void integer) is select * from order_style where oid = void;
 cursor c10( vshopid integer ) is select poid,photo_size,photo_cost,isgallery,film_name from shopping_basket where shopping_id = vshopid;

 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c10rec		c10%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 stsa		varchar2(100);
 tmp		varchar2(2000);
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 acid 		integer;
 purchord	integer;
 voidrec	order_style%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 profid		integer;
 cem		PURCHASE_ORDER.CONTACT_EMAIL%TYPE;
 sh1		PURCHASE_ORDER.SENDTO_NAME%TYPE;
 xsh1		PURCHASE_ORDER.SENDTO_FIRSTNAME%TYPE;
 xsh2		PURCHASE_ORDER.SENDTO_LASTNAME%TYPE;
 sh2		PURCHASE_ORDER.SENDTO_STREET%TYPE;
 sh3		PURCHASE_ORDER.SENDTO_SUBURB%TYPE;
 sh4		PURCHASE_ORDER.SENDTO_CITY%TYPE;
 sh5		PURCHASE_ORDER.SENDTO_COUNTRY%TYPE;
 sh6		PURCHASE_ORDER.SENDTO_POSTCODE%TYPE;
 sh6a		PURCHASE_ORDER.DELIVERY_TIME%TYPE;
 shde		PURCHASE_ORDER.SENDTO_DEPARTMENT%TYPE;
 shbr		PURCHASE_ORDER.SENDTO_BRANCH%TYPE;
 ex1		PURCHASE_ORDER.SPECIAL_DISCOUNT%TYPE;
 ex2		PURCHASE_ORDER.ORDER_COMMENT%TYPE;
 ud1		PURCHASE_ORDER.CUSTOMER_COLUMN1%TYPE;
 ud2		PURCHASE_ORDER.CUSTOMER_COLUMN2%TYPE;
 ud3		PURCHASE_ORDER.CUSTOMER_COLUMN3%TYPE;
 ud4		PURCHASE_ORDER.CUSTOMER_COLUMN4%TYPE;
 ud5		PURCHASE_ORDER.CUSTOMER_COLUMN5%TYPE;
 ud6		PURCHASE_ORDER.CUSTOMER_COLUMN6%TYPE;
 payr		PURCHASE_ORDER.CHEQUE_RECEIPT_NUMBER%TYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, stsa, 'S', progcalled=>'ORD.ACCEPT_MODIFY_ORDER', iscust=>FALSE );
 if stsa is not null
  then
   htp.bold( 'Login Cookie Error:' || stsa );
   return;
 end if;

acid := parm2(1);
cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
purchord := parm2(2);

open c2(purchord);
fetch c2 into c2rec;
close c2;

if action = LNG.PHG_BUT_112
 then
   if typ = 'WORKFLOW'
    then
     workflow_order(surl,acid,null,null);
    else
     phg_acct_orders( surl,acid, typ );
   end if;
   return;
end if;

begin ex1 := to_number(parm2(3)); exception when others then ex1 := 0; end;
payr := glbx.censor(parm2(4),1000,TRUE);
ex2 := glbx.censor(parm2(5),4000,TRUE);
ex2 := substr(to_char(sysdate,LNG.MASK) || '-' || ex2 || chr(10),1,4000);
if c2rec.is_b2c = 'T'
 then
   update purchase_order
    set
     order_comment = substr(order_comment || ex2,1,4000),
     payment_received = decode(pr,'T','T','t','T','F')
    where poid = purchord;
    purchase_audit_trail( purchord, 'ORDER_COMMENT', 'U', 'P', ex2);
    purchase_audit_trail( purchord, 'PAYMENT_RECEIVED', 'U', 'P', pr);
   commit;
   modify_order( surl,acid, purchord, LNG.PHG_TXT_161,typ=>typ );
   return;
end if;

if c2rec.status = LNG.ORD_TXT_199
 then
   update purchase_order
    set
     order_comment = substr(order_comment || ex2,1,4000),
     payment_received = decode(pr,'T','T','t','T','F')
    where poid = purchord;
    purchase_audit_trail( purchord, 'ORDER_COMMENT', 'U', 'P', ex2);
    purchase_audit_trail( purchord, 'PAYMENT_RECEIVED', 'U', 'P', pr);
   commit;
   modify_order( surl,acid, purchord, LNG.PHG_TXT_161,typ=>typ );
   return;
end if;

if c2rec.status in (LNG.ORD_TXT_128,LNG.ORD_TXT_129 )
 then
  if action = LNG.PHG_BUT_119
   then
    delete from shopping_basket where poid = purchord;
    delete from purchase_order where poid = purchord;
    commit;
    phg_acct_orders(surl,acid,'CANCELLED');
    return;
  end if;
  update purchase_order
    set
     order_comment = substr(order_comment || ex2,1,4000),
     payment_received = decode(pr,'T','T','t','T','F')
   where poid = purchord;
   purchase_audit_trail( purchord, 'ORDER_COMMENT', 'U', 'P', ex2);
   purchase_audit_trail( purchord, 'PAYMENT_RECEIVED', 'U', 'P', pr);
  commit;
  modify_order( surl,acid, purchord, LNG.PHG_TXT_161,typ=>typ );
  return;
end if;

if pr in ('t','T') and sts in ('Ordered','Order Authorised','Order Payment Received','Processing','Sent to Lab','Received by Lab','Processed by Lab','Order Completed','On Hold','Lab Problems' )
 then
  update purchase_order
   set date_purchased = nvl(date_purchased,sysdate)
  where poid = purchord;
end if;

 cem := parm2(6);
 shde := parm2(7);
 shbr := parm2(8);
 sh1 := parm2(9);
 sh2 := parm2(10);
 sh3 := parm2(11);
 sh4 := parm2(12);
 sh5 := parm2(13);
 sh6 := parm2(14);
 sh6a := parm2(15);
 ud1 := parm2(16);
 ud2 := parm2(17);
 ud3 := parm2(18);
 ud4 := parm2(19);
 ud5 := parm2(20);
 ud6 := parm2(21);

 for j in rm.first..rm.last loop
  if nvl(rm(j),'0') <> '0'
   then
    open c10( rm(j));
    fetch c10 into c10rec;
    close c10;
    purchase_audit_trail( c10rec.poid, 'DELETE FROM BASKET', 'D', 'P', c10rec.film_name || '-' || c10rec.photo_cost || '(' || c10rec.isgallery || ')' );
    delete from shopping_basket where poid=c2rec.poid and shopping_id = to_number(rm(j));
  end if;
 end loop;
 delete from order_contact_phone_number where poid=purchord;

 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
   insert into order_contact_phone_number(poid,pnumber,contact_det)
    values (purchord, p1(j), p2(j));
  end if;
 end loop;
 glbx.fixnm(sh1,xsh1,xsh2);

 update purchase_order
  set
   status = sts,
   contact_email = cem,
   sendto_department = shde,
   sendto_branch = shbr,
   sendto_name = sh1,
   sendto_firstname = xsh1,
   sendto_lastname = xsh2,
   sendto_street = sh2,
   sendto_suburb = sh3,
   sendto_city = sh4,
   sendto_country = sh5,
   sendto_postcode = sh6,
   delivery_time = sh6a,
   special_discount = ex1,
   order_comment = substr(order_comment || ex2,1,4000),
   cheque_receipt_number = payr,
   payment_received = decode(pr,'T','T','t','T','F'),
   customer_column1 = ud1,
   customer_column2 = ud2,
   customer_column3 = ud3,
   customer_column4 = ud4,
   customer_column5 = ud5,
   customer_column6 = ud6
  where poid = purchord;

  if c2rec.status = 'PreOrder - Confirmed without Payment' and
     sts = 'Order Authorised'
   then
    update purchase_order set date_purchased = sysdate where poid = purchord;
  end if;

  if sts in ('Customer Cancelled','Photographer Cancelled')
   then
    -- Disable Workflow
    update shopping_basket
     set
      status_id = null,
      status_priority = null,
      status_workflow = null,
      status_mfctr = null
    where poid = purchord;
  end if;

  purchase_audit_trail( purchord, 'CONTACT_EMAIL', 'U', 'P', cem);
  purchase_audit_trail( purchord, 'SENDTO_NAME', 'U', 'P', sh1);
  purchase_audit_trail( purchord, 'SENDTO_STREET', 'U', 'P', sh2);
  purchase_audit_trail( purchord, 'SENDTO_SUBURB', 'U', 'P', sh3);
  purchase_audit_trail( purchord, 'SENDTO_CITY', 'U', 'P', sh4);
  purchase_audit_trail( purchord, 'SENDTO_COUNTRY', 'U', 'P', sh5);
  purchase_audit_trail( purchord, 'SENDTO_POSTCODE', 'U', 'P', sh6);
  purchase_audit_trail( purchord, 'DELIVERY_TIME', 'U', 'P', sh6a);
  purchase_audit_trail( purchord, 'SPECIAL_DISCOUNT', 'U', 'P', ex1);
  purchase_audit_trail( purchord, 'ORDER_COMMENT', 'U', 'P', ex2);
  purchase_audit_trail( purchord, 'PAYMENT_RECEIVED', 'U', 'P', pr);
  purchase_audit_trail( purchord, 'CHEQUE_RECEIPT_NUMBER', 'U', 'P', payr);
  purchase_audit_trail( purchord, 'CUSTOMER_COLUMN1', 'U', 'P', ud1);
  purchase_audit_trail( purchord, 'CUSTOMER_COLUMN2', 'U', 'P', ud2);
  purchase_audit_trail( purchord, 'CUSTOMER_COLUMN3', 'U', 'P', ud3);
  purchase_audit_trail( purchord, 'CUSTOMER_COLUMN4', 'U', 'P', ud4);
  purchase_audit_trail( purchord, 'CUSTOMER_COLUMN5', 'U', 'P', ud5);
  purchase_audit_trail( purchord, 'CUSTOMER_COLUMN6', 'U', 'P', ud6);

  open c5(c2rec.oid);
  fetch c5 into voidrec;
  close c5;
  fname.purchase_audit_trail( surl, purchord, 'STATUS', 'U', 'C', sts, c2rec, voidrec);

  if (sts = LNG.ORD_TXT_199) and (c2rec.status <> sts)
   then
    update purchase_order
     set date_fulfilled = sysdate,
         event_shipped = 'T'
     where poid = purchord;
    purchase_audit_trail( purchord, 'EVENT_SHIPPED', 'U', 'P', 'T');
  end if;

  commit;
  -- Email customer when order has been confirmed. That is, was Ordered and moves to anything but cancelled.
  if (c2rec.event_confirmed = 'T') and (c2rec.status = LNG.ORD_TXT_121) and (c2rec.contact_email is not null) and
     (sts not in (LNG.ORD_TXT_128,LNG.ORD_TXT_129))
    then
       -- open c3;
       -- fetch c3 into c3rec;
       -- close c3;

       gcode(1) := 'PURCHASE_ORDER_ID';
       gparam(1) := c2rec.poid;
       gcode(2) := 'CURRTIME';
       gparam(2) := to_char(sysdate,LNG.TSMASK);
       gcode(3) := 'SIGNATURE';
       gparam(3) := glbx.extract_master_parameter('MAIL SIGNATURE');
       open c4(c2rec.pid);
       fetch c4 into c4rec;
       close c4;
       gcode(4) := 'PHOTOGRAPHER';
       gparam(4) := c4rec.business_name;
       glbx.send( gcode, gparam, 'order_confirmed.tmp', p_to=>c2rec.contact_email, p_subj=>LNG.ORD_TXT_101  || c2rec.poid, p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'OC2', v_pid=>cusrec.pid, v_aid=>cusrec.aid, v_profile_id=>profid);
    end if;

  -- Email customer when order has been shipped
  if (c2rec.event_shipped = 'T') and (sts = LNG.ORD_TXT_199) and (c2rec.contact_email is not null)
   then
     --open c3;
     --fetch c3 into c3rec;
     --close c3;

     gcode(1) := 'PURCHASE_ORDER_ID';
     gparam(1) := c2rec.poid;
     gcode(2) := 'CURRTIME';
     gparam(2) := to_char(sysdate,LNG.TSMASK);
     open c4(c2rec.pid);
     fetch c4 into c4rec;
     close c4;
     gcode(3) := 'PHOTOGRAPHER';
     gparam(3) := c4rec.business_name;
     gcode(4) := 'SIGNATURE';
     gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
     glbx.send( gcode, gparam, 'order_fulfilled.tmp', p_to=>c2rec.contact_email, p_subj=>LNG.ORD_TXT_100  || c2rec.poid, p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'OF1', v_pid=>cusrec.pid, v_aid=>cusrec.aid, v_profile_id=>profid);
  end if;

 modify_order( surl,acid, purchord, LNG.PHG_TXT_161,typ,typ=>typ );

exception when others then
 rollback;
 glbx.error_details( 'ORD', 'ACCEPT_MODIFY_ORDER',owner_id,errmsg=>sqlerrm);
end accept_modify_order;

procedure gallery_order( surl varchar2, v_umo in integer, gc in varchar2, acid in integer )
as
 cursor c2(v_umo integer, gc varchar2) is select charge from gallery_charge where umo_id = v_umo and charge_desc = gc;
 cursor c3(sess_id integer) is select poid from purchase_order where sessid = sess_id;

 c1rec			customer_account%ROWTYPE;
 c2rec 			c2%ROWTYPE;
 ltype			varchar2(100);
 stype			integer;
 sess_id		integer;
 profid			integer;
 sts			varchar2(100);
 v_poid			integer;
 home_ctry		varchar2(100);
begin
 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'ORD.GALLERY_ORDER' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( sess_id, ltype, acid, profid );
 home_ctry := glbx.userpref( c1rec.pid, c1rec.aid, 'HOME_CTRY' );
 open c2(v_umo, gc );
 fetch c2 into c2rec;
 close c2;
 open c3(sess_id);
 fetch c3 into v_poid;
 close c3;
 if v_poid is null
  then
     select s_purchase_order.nextval into v_poid from dual;
     insert into purchase_order(poid,sessid,pid,date_created,home_country) values (v_poid,sess_id,c1rec.pid,sysdate,nvl(home_ctry,'AUSTRALIA'));
 end if;
 insert into shopping_basket(poid,shopping_id,phid,qty,photo_size,photo_cost,film_type,isgallery) values
                            (v_poid,s_shopping_basket.nextval,v_umo,1,gc,c2rec.charge,null,'T');
 commit;
 fname.acct_orders(surl,acid=>acid);
exception when others then
 glbx.error_details( 'ORD', 'GALLERY_ORDER',errmsg=>sqlerrm,extdet=>'V_UMO:' || v_umo);
end gallery_order;

procedure labs(surl varchar2, archived in varchar2 default null, phgid in integer default null, acid in integer default null)
as

 cursor c2(manid integer) is
  select /*+ ALL_ROWS */ distinct ca.aid,ph.pid,ph.business_name,ca.account_name,po.order_comment comments,po.poid,po.date_created,po.status
  from customer_account ca, photographer ph, manufacturer mf, purchase_order po, login_session ls, shopping_basket sb
  where ph.pid = po.pid and
        ca.pid = ph.pid and
        mf.manufacturer_id = manid and
        po.status in ( 'Ordered', 'Order Authorised','Order Payment Received','Processing','Sent to Lab','Received by Lab','Processed by Lab','Order Completed','On Hold','Lab Problems' ) and
        po.is_b2c = 'T' and
        po.poid = sb.poid and
        sb.lab_id = mf.manufacturer_id and
        po.sessid = ls.sessid and
        (
         (ls.aid = ca.aid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = ca.aid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = ca.pid and ls.login_type = 'PHOTOGRAPHER' )
        )
  order by po.date_created desc;

/*
 cursor c2(manid integer) is
  select distinct ca.aid,ph.pid,ph.business_name,ca.account_name,fm.comments,fm.poid,po.date_created,po.status
  from form_made fm, customer_account ca, photographer ph, manufacturer mf, workflow_state_options ws, workflow_state_options ws1, purchase_order po
  where fm.manufacturer_id = manid and
        po.poid = fm.poid and
        ph.pid = po.pid and
        ca.aid = fm.aid and
        nvl(fm.status,'Ordered') = ws.order_option and
        po.status = ws1.order_option and
        ws.status_priority_id >= ws1.status_priority_id and
        ws.work_state = 0 and
        ws1.work_state = 0 and
        archived is null and
        po.poid = fm.poid
  order by po.date_created desc;
*/

 cursor c2a(manid integer, phgid integer) is
  select /*+ ALL_ROWS */ distinct ca.aid,ph.pid,ph.business_name,ca.account_name,po.order_comment comments,po.poid,po.date_created,po.status
  from customer_account ca, photographer ph, manufacturer mf, purchase_order po, login_session ls, shopping_basket sb
  where ph.pid = po.pid and
        ca.pid = ph.pid and
        ph.pid = phgid and
        mf.manufacturer_id = manid and
        po.status in ( 'Ordered', 'Order Authorised','Order Payment Received','Processing','Sent to Lab','Received by Lab','Processed by Lab','Order Completed','On Hold','Lab Problems' ) and
        po.is_b2c = 'T' and
        po.poid = sb.poid and
        sb.lab_id = mf.manufacturer_id and
        po.sessid = ls.sessid and
        (
         (ls.aid = ca.aid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = ca.aid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = ca.pid and ls.login_type = 'PHOTOGRAPHER' )
        )
  order by po.date_created desc;

 cursor c2b(manid integer, phgid integer, acid integer) is
  select /*+ ALL_ROWS */ distinct ca.aid,ph.pid,ph.business_name,ca.account_name,po.order_comment comments,po.poid,po.date_created,po.status
  from customer_account ca, photographer ph, manufacturer mf, purchase_order po, login_session ls, shopping_basket sb
  where ph.pid = po.pid and
        ca.pid = ph.pid and
        ph.pid = phgid and
        ca.aid = acid and
        mf.manufacturer_id = manid and
        po.status in ( 'Ordered', 'Order Authorised','Order Payment Received','Processing','Sent to Lab','Received by Lab','Processed by Lab','Order Completed','On Hold','Lab Problems' ) and
        po.is_b2c = 'T' and
        po.poid = sb.poid and
        sb.lab_id = mf.manufacturer_id and
        po.sessid = ls.sessid and
        (
         (ls.aid = ca.aid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = ca.aid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = ca.pid and ls.login_type = 'PHOTOGRAPHER' )
        )
  order by po.date_created desc;

 cursor c3(manid integer, av varchar2) is
  select /*+ ALL_ROWS */ ph.pid,ph.business_name,ca.aid,ca.account_name, count('x') tot
  from customer_account ca, photographer ph, manufacturer mf, purchase_order po, login_session ls, shopping_basket sb
  where ph.pid = po.pid and
        ca.pid = ph.pid and
        mf.manufacturer_id = manid and
        po.status in ( 'Ordered', 'Order Authorised','Order Payment Received','Processing','Sent to Lab','Received by Lab','Processed by Lab','Order Completed','On Hold','Lab Problems' ) and
        po.is_b2c = 'T' and
        po.poid = sb.poid and
        sb.lab_id = mf.manufacturer_id and
        po.sessid = ls.sessid and
        (
         (ls.aid = ca.aid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = ca.aid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = ca.pid and ls.login_type = 'PHOTOGRAPHER' )
        )
  group by ph.pid,ph.business_name,ca.aid,ca.account_name
  order by ph.pid,ph.business_name,ca.aid,ca.account_name;

 c1rec		manufacturer%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ORD.LABS', iscust=>FALSE);
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := get_lab_id( owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.ORD_TXT_132,glbx.backimg(surl,owner_id,pfx.text_back,null),'L05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );

 if (archived = LNG.ORD_TXT_139) and (phgid is null)
 then
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_006),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.CST_TXT_031),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.ORD_TXT_143),cattributes=>pfx.qbground );
   htp.tablerowclose;
   for c3rec in c3(owner_id,archived) loop
   htp.tablerowopen;
     htp.tabledata( htf.anchor('ord.labs?surl=' || glbx.rndsurl(surl) || '&archived=F&phgid=' || c3rec.pid,c3rec.business_name),cattributes=>pfx.qcbground );
     htp.tabledata( htf.anchor('ord.labs?surl=' || glbx.rndsurl(surl) || '&archived=F&phgid=' || c3rec.pid || '&acid=' || c3rec.aid,c3rec.account_name),cattributes=>pfx.qcbground );
     htp.tabledata( c3rec.tot,cattributes=>pfx.qcbground );
    htp.tablerowclose;
   end loop;
  htp.tableclose;

 else

  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_078),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.ORD_TXT_133),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.PHG_TXT_006),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.CST_TXT_031),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(LNG.PHG_TXT_082),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(replace(LNG2.FNM_TXT_013,'Laboratory',c1rec.manufacturer_title)),cattributes=>pfx.qbground );
   htp.tablerowclose;

   if archived = LNG.ORD_TXT_139 and acid is null and phgid is not null
    then
    for c2rec in c2a(owner_id,phgid) loop
     htp.tablerowopen;
      htp.tabledata( to_char(c2rec.date_created,LNG.TSMASK),cattributes=>pfx.qcbground );
      htp.tabledata( htf.anchor( 'ord.labs_edit?surl=' || glbx.rndsurl(surl) || '&vpoid=' || c2rec.poid, c2rec.poid),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(c2rec.business_name),cattributes=>pfx.qcbground );
      htp.tabledata( c2rec.account_name,cattributes=>pfx.qcbground );
      htp.tabledata( c2rec.status,cattributes=>pfx.qcbground );
      htp.tabledata( nvl(c2rec.comments,'&nbsp;'),cattributes=>pfx.qcbground );
     htp.tablerowclose;
    end loop;

   elsif archived = LNG.ORD_TXT_139 and acid is not null
    then
    for c2rec in c2b(owner_id,phgid,acid) loop
     htp.tablerowopen;
      htp.tabledata( to_char(c2rec.date_created,LNG.TSMASK),cattributes=>pfx.qcbground );
      htp.tabledata( htf.anchor( 'ord.labs_edit?surl=' || glbx.rndsurl(surl) || '&vpoid=' || c2rec.poid, c2rec.poid),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(c2rec.business_name),cattributes=>pfx.qcbground );
      htp.tabledata( c2rec.account_name,cattributes=>pfx.qcbground );
      htp.tabledata( c2rec.status,cattributes=>pfx.qcbground );
      htp.tabledata( nvl(c2rec.comments,'&nbsp;'),cattributes=>pfx.qcbground );
     htp.tablerowclose;
    end loop;

   else
    for c2rec in c2(owner_id) loop
     htp.tablerowopen;
      htp.tabledata( to_char(c2rec.date_created,LNG.TSMASK),cattributes=>pfx.qcbground );
      htp.tabledata( htf.anchor( 'ord.labs_edit?surl=' || glbx.rndsurl(surl) || '&vpoid=' || c2rec.poid, c2rec.poid),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(c2rec.business_name),cattributes=>pfx.qcbground );
      htp.tabledata( c2rec.account_name,cattributes=>pfx.qcbground );
      htp.tabledata( c2rec.status,cattributes=>pfx.qcbground );
      htp.tabledata( nvl(c2rec.comments,'&nbsp;'),cattributes=>pfx.qcbground );
     htp.tablerowclose;
    end loop;
   end if;
  htp.tableclose;
  end if;
  htp.nl;
  htp.formopen( 'ord.labs' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));

  if (archived is null) or (archived in (LNG.ORD_TXT_139,LNG.ORD_TXT_140))
   then
    htp.formsubmit( 'ARCHIVED', LNG.ORD_TXT_141 );
   else
    htp.formsubmit( 'ARCHIVED', LNG.ORD_TXT_142 );
  end if;

  if archived = LNG.ORD_TXT_139
   then
    htp.formsubmit( 'ARCHIVED', LNG.ORD_TXT_140 );
   else
    htp.formsubmit( 'ARCHIVED', LNG.ORD_TXT_139 );
  end if;

  htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ORD', 'LABS',errmsg=>sqlerrm);
end labs;

procedure labs_edit( surl varchar2, vpoid in integer, msg in varchar2 default null )
as

 cursor c2(manid integer, vpoid integer) is
  select distinct ca.aid,ph.pid,ph.business_name,ca.account_name,po.status,po.date_created,po.date_purchased date_updated,po.date_fulfilled date_sent,po.customer_comment comments, 'T' is_b2c, po.poid mfc_purch_id,po.poid, mf.username formname
  from customer_account ca, photographer ph, manufacturer mf, purchase_order po, shopping_basket sb
  where ph.pid = po.pid and
        po.poid = sb.poid and
        sb.lab_id = manid and
        po.poid = vpoid and
        ca.pid = ph.pid and
        po.status in ('Ordered', 'Order Authorised','Order Payment Received','Processing','Sent to Lab','Received by Lab','Processed by Lab','Order Completed','On Hold','Lab Problems');

 cursor c5(vpoid integer) is select * from purchase_order where poid = vpoid;
 cursor c7(wstate integer) is select order_option from workflow_state_options where work_state = wstate order by order_by;

 c1rec		manufacturer%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(1000);
 tot		integer;
 ins_upd	varchar2(10);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ORD.LABS_EDIT', iscust=>FALSE);
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := get_lab_id( owner_id );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.ORD_TXT_134,glbx.backimg(surl,owner_id,pfx.text_back,null),'L06',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg( msg );end if;
 htp.formopen( 'ord.accept_labs_edit', ctarget=>'LAB_BOTTOM' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'VPOID', vpoid );
 htp.p( '<CENTER>' );

 open c2(owner_id,vpoid);
 fetch c2 into c2rec;
 if c2%NOTFOUND then close c2; return; end if; -- Trying to break in
 close c2;

  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_099),cattributes=>pfx.qbground );
     tmp := null;
     htp.tabledata( htf.bold(c2rec.mfc_purch_id),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_006),cattributes=>pfx.qbground );
     htp.tabledata( htf.bold(c2rec.business_name),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_031),cattributes=>pfx.qbground );
     htp.tabledata( c2rec.account_name,cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_078) || htf.nl || htf.bold(LNG2.FNM_TXT_011) ,cattributes=>pfx.qbground );
     htp.tabledata( to_char(c2rec.date_created,LNG.TSMASK) || htf.nl || to_char(c2rec.date_updated,LNG.TSMASK),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG2.FNM_TXT_050),cattributes=>pfx.qbground );
     htp.tabledata( nvl(to_char(c2rec.date_sent,LNG.TSMASK),'&nbsp;'),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   tmp := NULL;
   open c5(vpoid);
   fetch c5 into c5rec;
   close c5;
   tmp := htf.formselectopen( 'P1B' );
   for c7rec in c7( 0 ) loop
    if c7rec.order_option = c5rec.status
     then
      tmp := tmp || htf.formselectoption( c7rec.order_option,'SELECTED' );
     else
      tmp := tmp || htf.formselectoption( c7rec.order_option );
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.ORD_TXT_208),cattributes=>pfx.qbground );
    htp.tabledata( tmp,cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowclose;
    htp.tabledata( htf.bold( LNG.ORD_TXT_031 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    if c5rec.event_confirmed = 'T'
       then
        htp.tabledata(LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata(LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_183 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    if c5rec.event_issue = 'T'
       then
        htp.tabledata(LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata(LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
    htp.tablerowclose;
    htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_184 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    if c5rec.event_shipped = 'T'
       then
        htp.tabledata(LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata(LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG2.FNM_TXT_013),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P2',20,4000,c2rec.comments),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.ORD_TXT_125),cattributes=>pfx.qbground );
     htp.tabledata( nvl(to_char(null,LNG.TSMASK),'&nbsp;'),cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG2.FNM_TXT_170),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P4',20,100,trim(to_char(c5rec.mfctr_stnd_shipping,LNG.MONEY_FORMAT))),cattributes=>pfx.qcbground || ' align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG2.FNM_TXT_171),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P4X',20,100,trim(to_char(c5rec.mfctr_other_cost,LNG.MONEY_FORMAT))),cattributes=>pfx.qcbground || ' align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG2.FNM_TXT_172),cattributes=>pfx.qbground );
     htp.tabledata( htf.formtext( 'P4Y',20,40,c5rec.mfctr_other_cost_desc),cattributes=>pfx.qcbground || ' align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.ORD_TXT_150),cattributes=>pfx.qbground );
     htp.tabledata( to_char(c2rec.date_updated,LNG.MASK),cattributes=>pfx.qcbground );
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( 'ACTION', LNG.ORD_TXT_135 );
  htp.formsubmit( 'ACTION', LNG.ORD_TXT_156 );
  htp.formsubmit( 'ACTION', LNG.ORD_TXT_196 );
  htp.formsubmit( 'ACTION', LNG.ORD_TXT_136 );
  htp.formclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ORD', 'LABS_EDIT',errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid);
end labs_edit;

procedure accept_labs_edit( surl varchar2, vpoid in integer, p1b in varchar2, p2 in varchar2, p4 in varchar2, p4x in varchar2, p4y in varchar2, action in varchar2 )
as

 cursor c1(ownid integer) is select * from manufacturer where manufacturer_id = ownid;
 cursor c3(phgr integer) is select * from photographer where pid = phgr;
 cursor c5(vpoid integer) is select * from purchase_order where poid = vpoid;
 cursor c6(acid integer) is select account_name from customer_account where aid = acid;
 cursor c7(thm varchar2) is select * from theme where theme_name = thm;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		number;
 nmb2		number;
 errm		varchar2(100);
 tmp		varchar2(10000);
 dt		date;
 dt1		date;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;
 pfx		THEME%ROWTYPE;
 options	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ORD.ACCEPT_LABS_EDIT', iscust=>FALSE);
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 errm := NULL;
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;
 open c7(c1rec.theme_name);
 fetch c7 into pfx;
 close c7;
 begin nmb := to_number(p4,LNG.MONEY_FORMAT); exception when others then begin nmb := to_number('$' || p4,LNG.MONEY_FORMAT); exception when others then nmb := null; errm := LNG.ORD_TXT_152; end; end;
 begin nmb2 := to_number(p4x,LNG.MONEY_FORMAT); exception when others then begin nmb2 := to_number('$' || p4x,LNG.MONEY_FORMAT); exception when others then nmb2 := null; errm := LNG.ORD_TXT_152; end; end;
 open c5(vpoid);
 fetch c5 into c5rec;
 close c5;
 tmp := to_char(sysdate,LNG.MASK) || '-' || glbx.censor(p2,4000,TRUE) || chr(10);
 update purchase_order
  set
   mfctr_stnd_shipping = nmb,
   mfctr_other_cost = nmb2,
   mfctr_other_cost_desc = p4y,
   order_comment = substr(order_comment || tmp,1,4000)
 where
  poid = vpoid;

 if p1b <> c5rec.status
  then
   update purchase_order
   set
    status = p1b
   where poid = vpoid;
 end if;

 /*
 update form_made
  set
   comments = p2
 where
  poid = vpoid and
  manufacturer_id = owner_id;
*/

  -- Email customer when order has been confirmed. That is, was Ordered and moves to anything but cancelled.
 if (c5rec.status = LNG.ORD_TXT_121) and (c5rec.contact_email is not null) and
    (p1b not in (LNG.ORD_TXT_128,LNG.ORD_TXT_129)) and (c5rec.event_confirmed = 'T')
    then
       gcode(1) := 'PURCHASE_ORDER_ID';
       gparam(1) := c5rec.poid;
       gcode(2) := 'CURRTIME';
       gparam(2) := to_char(sysdate,LNG.TSMASK);
       open c3(c5rec.pid);
       fetch c3 into c3rec;
       close c3;
       gcode(3) := 'PHOTOGRAPHER';
       gparam(3) := c3rec.business_name;
       gcode(4) := 'SIGNATURE';
       gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
       glbx.send( gcode, gparam, 'order_confirmed.tmp', p_to=>c5rec.contact_email, p_subj=>LNG.ORD_TXT_101  || c5rec.poid, p_from=>nvl(c1rec.contact_email,glbx.extract_master_parameter('MAIL_FROM')), scode=>'OC2');
 end if;

  -- Email customer when order has been shipped
 if (c5rec.event_shipped = 'T') and (p1b = LNG.ORD_TXT_199) and (c5rec.contact_email is not null) and
    (c5rec.status <> LNG.ORD_TXT_199)
   then
     gcode(1) := 'PURCHASE_ORDER_ID';
     gparam(1) := c5rec.poid;
     gcode(2) := 'CURRTIME';
     gparam(2) := to_char(sysdate,LNG.TSMASK);
      open c3(c5rec.pid);
      fetch c3 into c3rec;
      close c3;
     gcode(3) := 'PHOTOGRAPHER';
     gparam(3) := c3rec.business_name;
     gcode(4) := 'SIGNATURE';
     gparam(4) := glbx.extract_master_parameter('MAIL SIGNATURE');
     glbx.send( gcode, gparam, 'order_fulfilled.tmp', p_to=>c5rec.contact_email, p_subj=>LNG.ORD_TXT_100  || c5rec.poid, p_from=>nvl(c1rec.contact_email,glbx.extract_master_parameter('MAIL_FROM')), scode=>'OF1');
 end if;

 /*
 update form_made
    set
     comments = glbx.censor( p2 )
   where poid = vpoid and
         manufacturer_id = owner_id;
 */

 commit;

 if action = LNG.ORD_TXT_135
  then
   labs_edit( surl, vpoid, errm );

  elsif action = LNG.ORD_TXT_156
   then
    -- Display Customer Receipt
    open c3(c5rec.pid);
    fetch c3 into c3rec;
    close c3;
    open c5(vpoid);
    fetch c5 into c5rec;
    close c5;
    htp.htmlopen;
    htp.p( '<CENTER>' );

    options(1) := 'BGCOLOUR_HDR:' || pfx.qbground;
    options(2) := 'BGCOLOUR_BDY:' || pfx.qcbground;
    options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
    options(4) := 'LINEFEED';
    options(5) := 'BUSINESS';
    options(6) := 'PURCHASE';
    ord.display_order_details(surl, ltype, c5rec, options);

    options.delete;
    options(1) := 'BGCOLOUR_HDR:' || pfx.qbground;
    options(2) := 'BGCOLOUR_BDY:' || pfx.qcbground;
    options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
    options(4) := 'NO_ADMIN';
    options(5) := 'NO_LAB';
    options(6) := 'CUSTOMER';
    htp.nl;
    ord.display_order_subtotal( surl, ltype, c5rec, options );

    htp.p('<form><p><input type="button" value="' || LNG2.FNM_TXT_030 || '" onclick="window.print();"> </p></form>');
    htp.p( '</CENTER>' );
    htp.htmlclose;

  elsif action = LNG.ORD_TXT_196
   then
    -- Display Photographer Receipt
    open c1(owner_id);
    fetch c1 into c1rec;
    close c1;
    -- If B2B extract Photographer Details. If B2C then extract client details.
    open c3(c5rec.pid);
    fetch c3 into c3rec;
    close c3;
    open c5(c5rec.poid);
    fetch c5 into c5rec;
    close c5;
    htp.htmlopen;
    htp.p( '<CENTER>' );

    htp.nl;

    options(1) := 'BGCOLOUR_HDR:' || pfx.qbground;
    options(2) := 'BGCOLOUR_BDY:' || pfx.qcbground;
    options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
    options(4) := 'LINEFEED';
    options(5) := 'PURCHASE';
    options(6) := 'PHOTOGRAPHER';
    options(7) := 'MFCTR:' || owner_id;
    ord.display_order_details(surl, ltype, c5rec, options);

    options.delete;
    options(1) := 'BGCOLOUR_HDR:' || pfx.qbground;
    options(2) := 'BGCOLOUR_BDY:' || pfx.qcbground;
    options(3) := 'TABLE:' || 'cellpading=2 cellspacing=2 border=1';
    htp.nl;
    ord.display_order_subtotal( surl, ltype, c5rec, options );

    htp.p('<form><p><input type="button" value="' || LNG2.FNM_TXT_030 || '" onclick="window.print();"> </p></form>');
    htp.p( '</CENTER>' );
    htp.htmlclose;

  else
   labs(surl);
 end if;
exception when others then
 glbx.error_details( 'ORD', 'ACCEPT_LABS_EDIT',errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid );
end accept_labs_edit;

function get_lab_id( owner_id in integer)
 return manufacturer%ROWTYPE
as
 cursor c1 is
  select * from manufacturer where manufacturer_id = owner_id;
 c1rec	c1%ROWTYPE;
begin
 open c1;
 fetch c1 into c1rec;
 close c1;
 return( c1rec );
exception when others then
 glbx.error_details( 'ORD', 'GET_LAB_ID',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end get_lab_id;

procedure phg_ord_prefs( surl varchar2, acid in integer, msg in varchar2 default null, tm in char default 'D' )
as

 cursor c1(phgid integer, acid integer, tm char) is
 select /*+ ALL_ROWS */
        nvl(sum(tot),0) tot,
        nvl(sum(tot_order_completed),0) tot_order_completed,
        nvl(sum(tot_ordered),0) tot_ordered,
        nvl(sum(tot_order_auth),0) tot_order_auth,
        nvl(sum(tot_order_pay_rec),0) tot_order_pay_rec,
        nvl(sum(tot_preorder_nom),0) tot_preorder_nom,
        nvl(sum(tot_preorder),0) tot_preorder,
        nvl(sum(tot_aa),0) tot_aa,
        nvl(sum(tot_preconf),0) tot_preconf,
        nvl(sum(tot_bank),0) tot_bank,
        nvl(sum(tot_cc),0) tot_cc,
        nvl(sum(tot_pc),0) tot_pc,
        nvl(sum(tot_processing),0) tot_processing,
        nvl(sum(tot_sent_lab),0) tot_sent_lab,
        nvl(sum(tot_rec_lab),0) tot_rec_lab,
        nvl(sum(tot_proc_lab),0) tot_proc_lab,
        nvl(sum(tot_oh),0) tot_oh,
        nvl(sum(tot_lab_prob),0) tot_lab_prob,
        nvl(sum(tot_archived),0) tot_archived,
        nvl(sum(paid_merchant),0) paid_merchant,
        nvl(sum(paid_phone),0) paid_phone,
        nvl(sum(paid_cheque),0) paid_cheque,
        nvl(sum(paid_authorise),0) paid_authorise,
        nvl(sum(paid_billing),0) paid_billing,
        nvl(sum(paid_gift),0) paid_gift,
        nvl(sum(paid_und),0) paid_und,
        nvl(sum(is_b2c_t),0) is_b2c_t,
        nvl(sum(is_b2c_f),0) is_b2c_f,
        nvl(sum(ltot_preorder),0) ltot_preorder,
        nvl(sum(ltot_bank),0) ltot_bank,
        nvl(sum(ltot_aa),0) ltot_aa,
        nvl(sum(ltot_preconf),0) ltot_preconf
from
 (
  select
         count('x') tot,
         sum(decode(is_b2c, 'F', decode(status,'Order Completed',1,0), 0 )) tot_order_completed,
         sum(decode(is_b2c, 'F', decode(status,'Ordered',1,0), 0 )) tot_ordered,
         sum(decode(is_b2c, 'F', decode(status,'Order Authorised',1,0), 0 )) tot_order_auth,
         sum(decode(is_b2c, 'F', decode(status,'Order Payment Received',1,0), 0 )) tot_order_pay_rec,
         sum(decode(status,'PreOrder - No Order Made',1,0)) tot_preorder_nom,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Sent to Bank',1,0), 0 )) tot_bank,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Confirmed without Payment',1,0), 0 )) tot_preconf,
         sum(decode(is_b2c, 'F', decode(status,'Awaiting Authorisation',1,0), 0 )) tot_aa,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder',1,0), 0 )) tot_preorder,
         sum(decode(is_b2c, 'F', decode(status,'Processing',1,0), 0 )) tot_processing,
         sum(decode(is_b2c, 'F', decode(status,'Sent to Lab',1,0), 0 )) tot_sent_lab,
         sum(decode(is_b2c, 'F', decode(status,'Received by Lab',1,0), 0 )) tot_rec_lab,
         sum(decode(is_b2c, 'F', decode(status,'Processed by Lab',1,0), 0 )) tot_proc_lab,
         sum(decode(is_b2c, 'F', decode(status,'On Hold',1,0), 0 )) tot_oh,
         sum(decode(is_b2c, 'F', decode(status,'Lab Problems',1,0), 0 )) tot_lab_prob,
         sum(decode(is_b2c, 'F', decode(status,'Archived',1,0), 0 )) tot_archived,
         sum(decode(status,'Customer Cancelled',1,0)) tot_cc,
         sum(decode(status,'Photographer Cancelled',1,0)) tot_pc,
         sum(decode(paid_method,'MERCHANT',1,0)) paid_merchant,
         sum(decode(paid_method,'PHONE',1,0)) paid_phone,
         sum(decode(paid_method,'CHEQUE',1,0)) paid_cheque,
         sum(decode(paid_method,'AUTHORISE',1,0)) paid_authorise,
         sum(decode(paid_method,'BILLING',1,0)) paid_billing,
         sum(decode(paid_method,'GIFT',1,0)) paid_gift,
         sum(decode(nvl(paid_method,'UND'),'UND',decode(status,'PreOrder - No Order Made',0,1),0)) paid_und,
         sum(decode(is_b2c,'T',1,0)) is_b2c_t,
         sum(decode(is_b2c,'F',1,0)) is_b2c_f,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_preorder,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Sent to Bank',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_bank,
         sum(decode(is_b2c, 'F', decode(status,'Awaiting Authorisation',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_aa,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Confirmed without Payment',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_preconf
  from login_session ls, purchase_order po
  where po.pid = phgid and
        po.sessid = ls.sessid and
        po.date_created > (sysdate - decode(tm,'A',1,'B',7,'C',14,'D',31,'E',60,'F',90,'G',183,'H',366,'I',10000,0)) and
        ls.login_type in ('CUSTOMER','OWNER') and
        ls.aid = acid
union all
  select count('x') tot,
         sum(decode(is_b2c, 'F', decode(status,'Order Completed',1,0), 0 )) tot_order_completed,
         sum(decode(is_b2c, 'F', decode(status,'Ordered',1,0), 0 )) tot_ordered,
         sum(decode(is_b2c, 'F', decode(status,'Order Authorised',1,0), 0 )) tot_order_auth,
         sum(decode(is_b2c, 'F', decode(status,'Order Payment Received',1,0), 0 )) tot_order_pay_rec,
         sum(decode(status,'PreOrder - No Order Made',1,0)) tot_preorder_nom,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Sent to Bank',1,0), 0 )) tot_bank,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Confirmed without Payment',1,0), 0 )) tot_preconf,
         sum(decode(is_b2c, 'F', decode(status,'Awaiting Authorisation',1,0), 0 )) tot_aa,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder',1,0), 0 )) tot_preorder,
         sum(decode(is_b2c, 'F', decode(status,'Processing',1,0), 0 )) tot_processing,
         sum(decode(is_b2c, 'F', decode(status,'Sent to Lab',1,0), 0 )) tot_sent_lab,
         sum(decode(is_b2c, 'F', decode(status,'Received by Lab',1,0), 0 )) tot_rec_lab,
         sum(decode(is_b2c, 'F', decode(status,'Processed by Lab',1,0), 0 )) tot_proc_lab,
         sum(decode(is_b2c, 'F', decode(status,'On Hold',1,0), 0 )) tot_oh,
         sum(decode(is_b2c, 'F', decode(status,'Lab Problems',1,0), 0 )) tot_lab_prob,
         sum(decode(is_b2c, 'F', decode(status,'Archived',1,0), 0 )) tot_archived,
         sum(decode(status,'Customer Cancelled',1,0)) tot_cc,
         sum(decode(status,'Photographer Cancelled',1,0)) tot_pc,
         sum(decode(paid_method,'MERCHANT',1,0)) paid_merchant,
         sum(decode(paid_method,'PHONE',1,0)) paid_phone,
         sum(decode(paid_method,'CHEQUE',1,0)) paid_cheque,
         sum(decode(paid_method,'AUTHORISE',1,0)) paid_authorise,
         sum(decode(paid_method,'BILLING',1,0)) paid_billing,
         sum(decode(paid_method,'GIFT',1,0)) paid_gift,
         sum(decode(nvl(paid_method,'UND'),'UND',decode(status,'PreOrder - No Order Made',0,1),0)) paid_und,
         sum(decode(is_b2c,'T',1,0)) is_b2c_t,
         sum(decode(is_b2c,'F',1,0)) is_b2c_f,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_preorder,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Sent to Bank',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_bank,
         sum(decode(is_b2c, 'F', decode(status,'Awaiting Authorisation',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_aa,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Confirmed without Payment',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_preconf
  from login_session ls, purchase_order po, customer_profile cp
  where po.pid = phgid and
        po.sessid = ls.sessid and
        po.date_created > (sysdate - decode(tm,'A',1,'B',7,'C',14,'D',31,'E',60,'F',90,'G',183,'H',366,'I',10000,0)) and
        ls.login_type in ('PROFILE','PROFILEG') and
        ls.aid = cp.profile_id and
        cp.aid = acid
union all
  select count('x') tot,
         sum(decode(is_b2c, 'F', decode(status,'Order Completed',1,0), 0 )) tot_order_completed,
         sum(decode(is_b2c, 'F', decode(status,'Ordered',1,0), 0 )) tot_ordered,
         sum(decode(is_b2c, 'F', decode(status,'Order Authorised',1,0), 0 )) tot_order_auth,
         sum(decode(is_b2c, 'F', decode(status,'Order Payment Received',1,0), 0 )) tot_order_pay_rec,
         sum(decode(status,'PreOrder - No Order Made',1,0)) tot_preorder_nom,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Sent to Bank',1,0), 0 )) tot_bank,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Confirmed without Payment',1,0), 0 )) tot_preconf,
         sum(decode(is_b2c, 'F', decode(status,'Awaiting Authorisation',1,0), 0 )) tot_aa,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder',1,0), 0 )) tot_preorder,
         sum(decode(is_b2c, 'F', decode(status,'Processing',1,0), 0 )) tot_processing,
         sum(decode(is_b2c, 'F', decode(status,'Sent to Lab',1,0), 0 )) tot_sent_lab,
         sum(decode(is_b2c, 'F', decode(status,'Received by Lab',1,0), 0 )) tot_rec_lab,
         sum(decode(is_b2c, 'F', decode(status,'Processed by Lab',1,0), 0 )) tot_proc_lab,
         sum(decode(is_b2c, 'F', decode(status,'On Hold',1,0), 0 )) tot_oh,
         sum(decode(is_b2c, 'F', decode(status,'Lab Problems',1,0), 0 )) tot_lab_prob,
         sum(decode(is_b2c, 'F', decode(status,'Archived',1,0), 0 )) tot_archived,
         sum(decode(status,'Customer Cancelled',1,0)) tot_cc,
         sum(decode(status,'Photographer Cancelled',1,0)) tot_pc,
         sum(decode(paid_method,'MERCHANT',1,0)) paid_merchant,
         sum(decode(paid_method,'PHONE',1,0)) paid_phone,
         sum(decode(paid_method,'CHEQUE',1,0)) paid_cheque,
         sum(decode(paid_method,'AUTHORISE',1,0)) paid_authorise,
         sum(decode(paid_method,'BILLING',1,0)) paid_billing,
         sum(decode(paid_method,'GIFT',1,0)) paid_gift,
         sum(decode(nvl(paid_method,'UND'),'UND',decode(status,'PreOrder - No Order Made',0,1),0)) paid_und,
         sum(decode(is_b2c,'T',1,0)) is_b2c_t,
         sum(decode(is_b2c,'F',1,0)) is_b2c_f,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_preorder,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Sent to Bank',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_bank,
         sum(decode(is_b2c, 'F', decode(status,'Awaiting Authorisation',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_aa,
         sum(decode(is_b2c, 'F', decode(status,'PreOrder - Confirmed without Payment',decode(nvl(length(sendto_name),0) + nvl(length(contact_email),0),0,0,1),0), 0 )) ltot_preconf
  from login_session ls, purchase_order po
  where po.pid = phgid and
        po.sessid = ls.sessid and
        po.date_created > (sysdate - decode(tm,'A',1,'B',7,'C',14,'D',31,'E',60,'F',90,'G',183,'H',366,'I',10000,0)) and
        ls.login_type = 'PHOTOGRAPHER' and
        ls.aid = phgid
  );


 cursor c9(phgid integer, acid integer, tm char) is
 select sum(tot)
 from
 (
  select count('x') tot
  from workflow_set ws, shopping_basket sb, purchase_order po, login_session ls
  where sb.poid = po.poid and
        po.date_created > (sysdate - decode(tm,'A',1,'B',7,'C',14,'D',31,'E',60,'F',90,'G',183,'H',366,'I',10000,0)) and
        ws.status_workflow = sb.status_workflow and
        po.pid = phgid and
        po.sessid = ls.sessid and
        ls.aid = acid and
        ls.login_type in ('CUSTOMER','OWNER')
  union all
  select count('x') tot
  from workflow_set ws, shopping_basket sb, purchase_order po, login_session ls, customer_profile cp
  where sb.poid = po.poid and
        ws.status_workflow = sb.status_workflow and
        po.date_created > (sysdate - decode(tm,'A',1,'B',7,'C',14,'D',31,'E',60,'F',90,'G',183,'H',366,'I',10000,0)) and
        po.pid = phgid and
        po.sessid = ls.sessid and
        ls.aid = cp.profile_id and
        cp.aid = acid and
        ls.login_type in ('PROFILE','PROFILEG')
  union all
  select count('x') tot
  from workflow_set ws, shopping_basket sb, purchase_order po, login_session ls
  where sb.poid = po.poid and
        po.date_created > (sysdate - decode(tm,'A',1,'B',7,'C',14,'D',31,'E',60,'F',90,'G',183,'H',366,'I',10000,0)) and
        ws.status_workflow = sb.status_workflow and
        po.pid = phgid and
        po.sessid = ls.sessid and
        ls.aid = phgid and ls.login_type = 'PHOTOGRAPHER'
 );

 cursor c10(acid integer) is select * from theme_types tt where theme_type = (select theme_type from customer_account where aid=acid);

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tot		integer;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ORD.PHG_ORD_PREFS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_ALT_128,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'O20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 open c10(acid);
 fetch c10 into theme_rec;
 close c10;

 -- Do a very fast quick query to see how many orders (in total across all accounts) the photographer has. Ignore the fact that it is across all accounts.
 -- We are just avoiding doing some totals

 if msg is not null then glbx.header_msg( msg );end if;
 htp.nl;
 htp.p('<CENTER>');
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );

  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || ' ROWSPAN="16" VALIGN="TOP">' );

 htp.p( '<div style="font-size: small;">' );
 htp.bold( 'View by Date<BR>within' || ':' );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'A', '24 hours', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'B', '48 hours', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'C', 'Week', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'D', 'Month', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'E', 'Two Months', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'F', 'Three Months', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'G', 'Six Months', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'H', 'Year', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.phg_ord_prefs?surl=' || surl || '&acid=' || acid || '&tm=' || 'I', 'All Orders', cattributes=>'style="font-size: small;"' ) );
  htp.tablerowclose;
 htp.tableclose;
 htp.p( '</div>' );

   htp.p( '</TD>' );
   htp.tabledata(htf.img( DECS.IMAGE_LOCATION || 'adminc/pref_ord.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_010 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG2.FNM_TXT_010 || '</font></b>',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT" COLSPAN="5"');
   --htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   --htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   --htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   --htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  open c1(owner_id,acid,tm);
  fetch c1 into c1rec;
  close c1;

  -- New
  htp.tablerowopen;
   tot := c1rec.tot_order_pay_rec + c1rec.tot_order_auth + c1rec.tot_ordered;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG.ORD_TXT_200,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=NEW' || '&tm=' || tm,LNG.ORD_TXT_200),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');

   -- Merchant
   tot := c1rec.paid_merchant;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG.ORD_TXT_182,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=MERCHANT' || '&tm=' || tm,LNG.ORD_TXT_182),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  -- Active
  htp.tablerowopen;
   tot := c1rec.tot_processing + c1rec.tot_sent_lab + c1rec.tot_rec_lab + c1rec.tot_proc_lab + c1rec.tot_oh + c1rec.tot_lab_prob;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG.ORD_TXT_201,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=ACTIVE' || '&tm=' || tm,LNG.ORD_TXT_201),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');

   -- Phone
   tot := c1rec.paid_phone;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG.ORD_TXT_175,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=PHONE' || '&tm=' || tm,LNG.ORD_TXT_175),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  -- Order Completed
  htp.tablerowopen;
   tot := c1rec.tot_order_completed;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG.ORD_TXT_199,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=COMPLETED' || '&tm=' || tm,LNG.ORD_TXT_199),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');

   -- Cheque
   tot := c1rec.paid_cheque;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG2.FNM_TXT_124,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=CHEQUE' || '&tm=' || tm,LNG2.FNM_TXT_124),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');

  htp.tablerowclose;


  -- Lab Managed
  htp.tablerowopen;
   tot := c1rec.is_b2c_t;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG.ORD_TXT_205,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=LAB' || '&tm=' || tm,LNG.ORD_TXT_205),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');

   -- Authorise
   tot := c1rec.paid_authorise;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG4.AHC_TXT_692,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=AUTHORISE' || '&tm=' || tm,LNG4.AHC_TXT_692),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  -- Only view PreOrders if the business feature allows it
  if substr(theme_rec.theme_data,172,1) = 'T'
   then
    htp.tablerowopen;
     tot := c1rec.tot_preorder + c1rec.tot_bank + c1rec.tot_aa + c1rec.tot_preconf;
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     if tot = 0
      then
        htp.tabledata(LNG.ORD_TXT_206,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      else
        htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=PREORDER' || '&tm=' || tm,LNG.ORD_TXT_206 || ' (ALL)'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
  end if;

  -- PreOrders
  if substr(theme_rec.theme_data,173,1) = 'T'
   then
    htp.tablerowopen;
     tot := c1rec.ltot_preorder + c1rec.ltot_bank + c1rec.ltot_aa + c1rec.ltot_preconf;
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     if tot = 0
      then
        htp.tabledata(LNG.ORD_TXT_206,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      else
        htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=PREORDERX' || '&tm=' || tm,LNG.ORD_TXT_206),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     end if;
     htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
  end if;

  -- Archived
  htp.tablerowopen;
   tot := c1rec.tot_archived;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG.ORD_TXT_127,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=ARCHIVED' || '&tm=' || tm,LNG.ORD_TXT_127),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');

   -- Billing
   tot := c1rec.paid_billing;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG4.AHC_TXT_732,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=BILLING' || '&tm=' || tm,LNG4.AHC_TXT_732),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  -- Cancelled
  htp.tablerowopen;
   tot := c1rec.tot_cc + c1rec.tot_pc;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG.ORD_TXT_207,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=CANCELLED' || '&tm=' || tm,LNG.ORD_TXT_207),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');

   -- Gift
   tot := c1rec.paid_gift;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG4.AHC_TXT_688,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=GIFT' || '&tm=' || tm,LNG4.AHC_TXT_688),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  -- Workflow
  htp.tablerowopen;
   tot := 0;
     open c9(owner_id,acid,tm);
     fetch c9 into tot;
     close c9;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG4.AHC_TXT_304,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.workflow_order?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, LNG4.AHC_TXT_304),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

   -- Undecided
  htp.tablerowopen;
   tot := c1rec.paid_und;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   if tot = 0
    then
     htp.tabledata(LNG4.AHC_TXT_688,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata(htf.anchor('ord.phg_acct_orders?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&TYP=UND' || '&tm=' || tm,'Not Yet Decided'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   htp.tabledata('[' || to_char(tot) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata(htf.img( DECS.IMAGE_LOCATION || 'adminc/pref_sea.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_092 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG.GLB_TXT_092 || '</font></b>',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.formopen( 'ord.phg_search' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
     htp.tablerowclose;
      htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.bold('Search for Value (Purchase #, Name etc)'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.formtext( 'P1', 20, 100 );
      htp.p( '</TD>' );
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowclose;
      htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.bold('From Date'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.formtext( 'P3', 20, 100 );
      htp.p( '</TD>' );
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.italic(LNG.MASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowclose;
      htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.bold('To Date'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.formtext( 'P4', 20, 100 );
      htp.p( '</TD>' );
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.italic(LNG.MASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.formsubmit(null,LNG.GLB_TXT_092),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
  htp.formclose;

 htp.tableclose;
 htp.p('</CENTER>');
 htp.nl;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ORD', 'PHG_ORD_PREFS',owner_id,acid,errmsg=>sqlerrm,extdet=>msg);
end phg_ord_prefs;

procedure phg_search(surl varchar2,acid in integer, p1 in varchar2, p2 in varchar2 default null, p3 in varchar2, p4 in varchar2)
as

 cursor c1(acid integer, phgid integer) is select * from customer_account where aid=acid and pid=phgid;
 cursor c2(phgid integer, acid integer, p1 varchar2, dt1 date, dt2 date) is
  select po.poid,po.status,po.date_purchased,po.sendto_name,po.payment_received,po.is_b2c
  from purchase_order po, login_session ls
  where po.pid = phgid and
	( upper(po.sendto_name) || to_char(po.poid) || upper(po.sendto_street) || upper(po.sendto_suburb) || upper(po.sendto_city) || upper(po.contact_email) || upper(po.sendto_country) ||
	  upper(po.billing_name) || upper(po.billing_street) || upper(po.billing_suburb) || upper(po.billing_city) || upper(po.billing_email) || upper(po.billing_country) like '%' || p1 || '%' ) and
	( trunc(po.date_created) >= dt1 and trunc(po.date_created) <= dt2 ) and
        ls.sessid = po.sessid and
        (
         (ls.aid = acid and ls.login_type in ('CUSTOMER','OWNER')) or
         (ls.aid in (select profile_id from customer_profile where aid = acid) and ls.login_type in ('PROFILE','PROFILEG')) or
         (ls.aid = phgid and ls.login_type = 'PHOTOGRAPHER' )
        )
 order by decode(po.status,LNG.ORD_TXT_120,0,LNG4.AHC_TXT_672,0,'PreOrder - Confirmed without Payment',0,LNG4.AHC_TXT_706,0,LNG.ORD_TXT_121,1,2),po.date_purchased desc;

 c1rec 		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 ttl		number;
 dt1		date;
 dt2		date;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ORD.PHG_SEARCH', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 htp.p( '<CENTER>' );
 open c1( acid, owner_id );
 fetch c1 into c1rec;
 close c1;
 theme_rec := glbx.get_theme_types( c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_TXT_079,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'O14',stype=>stype+1,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( LNG.PHG_TXT_084 );
   htp.tabledata( htf.bold( p1 ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG.CST_TXT_099 );
   htp.tabledata( htf.bold( p2 ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG.PHG_TXT_153 );
   htp.tabledata( htf.bold( p3 ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG.PHG_TXT_083 );
   htp.tabledata( htf.bold( p4 ) );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.bold(htf.italic( LNG.PHG_TXT_080 ));
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'width="600" cellpadding=2 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_081 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_082 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_083 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_084 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG.PHG_TXT_085 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG.ORD_TXT_108 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG.ORD_TXT_145 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata('<b><font size="+1">' || LNG.ORD_TXT_193 || '</font></b>',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;

 begin dt1 := nvl(to_date(p3,LNG.MASK),sysdate-9999); exception when others then dt1 := null; end;
 begin dt2 := nvl(to_date(p4,LNG.MASK),sysdate+9999); exception when others then dt2 := null; end;

 for c2rec in c2(owner_id, acid, upper(p1), dt1, dt2) loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'ord.modify_order?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&purchord=' || c2rec.poid || '&typ=' || LNG.GLB_TXT_092,c2rec.poid),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( nvl(to_char(c2rec.date_purchased,LNG.MASK),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata( nvl(c2rec.sendto_name,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   ttl := glbx.total_payment(c2rec.poid);
   htp.tabledata( nvl(to_char(ttl,LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(to_char(glbx.grand_total_payment( c2rec.poid, include_gift_certificate=>FALSE ),LNG.MONEY_FORMAT),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   if nvl(c2rec.payment_received,'F') = 'F'
    then
     htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
   if c2rec.is_b2c = 'T'
    then
     htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    else
     htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   end if;
  htp.tablerowclose;
 end loop;

 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'ORD', 'PHG_SEARCH',owner_id,acid,errmsg=>sqlerrm,extdet=>'P1:' || p1 || ' P2:' || p2 || ' P3:' || p3 || ' P4:' || p4);
end phg_search;

procedure purchase_audit_trail( vpoid in integer, colname in varchar2, vaction in char, vchange in char, newval in varchar2 )
as
begin
 insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value)
  values
   (vpoid,colname,sysdate,vaction,vchange,newval);
exception when others then
 glbx.error_details( 'ORD', 'PURCHASE_AUDIT_TRAIL',errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid);
end purchase_audit_trail;

procedure audit_trail( surl in varchar2, acid in integer, purchord in integer )
as

 cursor c1( acid integer ) is select * from customer_account where aid = acid;
 cursor c2( acid integer, purchord integer ) is
  select poid,column_name,date_changed,action,changed_by,new_value
  from purchase_audit
  where poid = purchord and
        exists (select 'x' from login_session ls, purchase_order po where ls.aid = acid and ls.sessid = po.sessid and po.poid = purchord
               union all
                select 'x' from login_session ls, purchase_order po, customer_profile cp where ls.aid = cp.profile_id and cp.aid = acid and ls.sessid = po.sessid and po.poid = purchord)
  order by date_changed desc;


 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'ORD.AUDIT_TRAIL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 theme_rec := glbx.get_theme_types( c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG4.AHC_TXT_102 || ':' || to_char(purchord),glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'O24',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' );
    htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.CST_TXT_032), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(LNG4.AHC_TXT_105), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(LNG4.AHC_TXT_103), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(LNG4.AHC_TXT_104), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
  for c2rec in c2(acid,purchord) loop
    htp.tablerowopen;
       htp.tabledata( to_char(c2rec.date_changed,LNG.TSMASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       if c2rec.changed_by = 'C'
        then
         htp.tabledata( LNG.PHG_TXT_199, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       elsif c2rec.changed_by = 'L'
        then
         htp.tabledata( LNG2.PBK_TXT_009, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       elsif c2rec.changed_by = 'A'
        then
         htp.tabledata( LNG4.AHC_TXT_106, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       elsif c2rec.changed_by = 'P'
        then
         htp.tabledata( LNG.PHG_TXT_006, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
         htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       end if;
       htp.tabledata( initcap(replace(c2rec.column_name,'_',' ')), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( nvl(c2rec.new_value,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.nl;
 htp.p( '</CENTER>' );

 htp.htmlclose;
exception when others then
 glbx.error_details( 'ORD', 'AUDIT_TRAIL',null,acid,errmsg=>sqlerrm,extdet=>'PURCHORD:' || purchord);
end audit_trail;

procedure display_order_subtotal( surl in varchar2, ltype in varchar2, purchrec in purchase_order%ROWTYPE, options in GLBX.MYARRAY )
as

 cursor c1(void integer) is select * from order_style where oid = void;
 cursor c2(vpoid integer) is select * from shopping_basket where poid = vpoid order by decode(isgallery,'P',0,1),nvl(packaged_product_id,999999999),shopping_id;
 cursor c3(attrib integer, v_umo integer) is select value from umo_attribute where attribute_id = attrib and umo_id = v_umo;
 cursor c4(v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c6( wsid integer ) is select workflow_name from workflow_set where status_workflow = wsid;
 cursor c7( mfcid integer ) is select name from manufacturer where manufacturer_id = mfcid;
 cursor c8( phgid integer ) is select photographer_title from photographer where pid = phgid;
 cursor c9( vpoid integer ) is select * from purchase_audit where poid = vpoid and column_name = 'Part Payment' order by date_changed;
 cursor c10( vpoid integer ) is select * from purchase_additional_options where poid = vpoid and display_receipt_page <> 'N';

 c3rec			c3%ROWTYPE;
 c4rec			c4%ROWTYPE;
 c6rec			c6%ROWTYPE;
 c7rec			c7%ROWTYPE;
 c8rec			c8%ROWTYPE;
 voidrec		order_style%ROWTYPE;
 show_thumbnail		boolean := TRUE;
 show_workflow		boolean := FALSE;
 show_metadata		boolean := FALSE;
 meta_tags		GLBX.MYARRAY_NMB;
 show_lab		boolean := TRUE;
 show_admin		boolean := TRUE;
 show_running_total	boolean := FALSE;
 show_header		boolean := TRUE;
 not_customer		boolean := TRUE;
 table_defn		varchar2(1000);
 bgcolour_hdr		varchar2(100) := 'BGCOLOR="#FFFFFF"';
 bgcolour_bdy		varchar2(100) := 'BGCOLOR="#FFFFFF"';
 txt			varchar2(100);
 nmb			number;
 gstnmb			number;
 nmb2			number;
 nmb3			number;
 perc1			number;
 perc2			number;
 running_total		number;
 parm1 			GLBX.MYARRAY;
 parm2 			GLBX.MYARRAY_NMB;

procedure show_row_sb(sbrec in shopping_basket%ROWTYPE, running_total in out number )
as

 cursor c1(v_umo integer) is select umo_scene_id from umo where umo_id = v_umo;
 cursor c2(vscene integer) is select * from umo_scene where umo_scene_id = vscene;
 cursor c3p(vpoid integer, vshopid integer) is select * from shopping_basket where poid = vpoid and packaged_product_id = vshopid;
 cursor c3q(vpoid integer, vshopid integer) is select * from shopping_basket where poid = vpoid and shopping_id = vshopid;

 c1rec		c1%ROWTYPE;
 c2arec 	c2%ROWTYPE;
 c2brec  	c2%ROWTYPE;
 c3qrec		c3q%ROWTYPE;
 acid		integer;
 dsp		varchar2(100);

begin
 htp.tablerowopen;

    open c4(sbrec.phid);
    fetch c4 into c4rec;
    close c4;
    acid := c4rec.aid;
    htp.p( '<TD ' || 'VALIGN="TOP" ALIGN="LEFT" ' ||  bgcolour_bdy || '>' );
    if not(ltype = 'ADMINISTRATOR' or not show_thumbnail)
     then
     if sbrec.umo_width > sbrec.umo_height
      then
       dsp := ' WIDTH=' || sbrec.umo_width;
      else
       dsp := ' HEIGHT=' || sbrec.umo_height;
     end if;
     if sbrec.umo_type = 'GALLERY'
      then
       htp.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || sbrec.phid || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=POID&parm2=' || sbrec.poid || '&parm1=LOGIN_TYPE&parm2=GALLERY&parm1=AID&parm2=' || acid,
                                 '<IMG STYLE="display:block;" BORDER=0 ' || dsp || ' SRC="' ||
                                 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || sbrec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=POID&parm2=' || sbrec.poid || '&parm1=LOGIN_TYPE&parm2=GALLERY&parm1=AID&parm2=' || acid || '">', ctarget=>'POPUP');
       htp.nl;
     elsif sbrec.isgallery in ('C','S')
      then
       -- Display Product Image if it exists
       if sbrec.phid is null
        then
         htp.img( DECS.IMAGE_LOCATION || 'admin/mfc.gif',cattributes=>'border=0', calt=>LNG2.FNM_TXT_052 );
	  else
         htp.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || sbrec.phid || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || sbrec.lab_id || '&parm1=LOGIN_TYPE&parm2=MANUFACTURER',
                       '<IMG BORDER=0 ' || dsp || ' SRC="' ||
                       'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || sbrec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=LOGIN_TYPE&parm2=MANUFACTURER&parm1=AID&parm2=' || sbrec.lab_id ||
                       '" ALT="' || LNG2.PBK_TXT_057 || '" STYLE="display:block;">' || htf.nl || sbrec.umo_film_name, ctarget=>'CUSTOMER_CLEARANCE');
        end if;
      else
       htp.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || sbrec.phid || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=POID&parm2=' || sbrec.poid || '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || acid,
                                 '<IMG STYLE="display:block;" BORDER=0 ' || dsp || ' SRC="' ||
                                 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || sbrec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=POID&parm2=' || sbrec.poid || '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || acid || '">', ctarget=>'POPUP');
      end if;
      htp.nl;
     end if;
     htp.p(sbrec.film_name || '(' || sbrec.photo_size || ')' );
     -- Display Image Details
     htp.nl;
     htp.p(sbrec.film_type );
     if sbrec.phg_code is not null then htp.p( '-' || sbrec.phg_code ); end if;
     if sbrec.alteration is not null then htp.nl; htp.p(sbrec.alteration); end if;
     -- Display Category Details
     open c1(sbrec.phid);
     fetch c1 into c1rec;
     close c1;
     open c2(c1rec.umo_scene_id);
     fetch c2 into c2arec;
     close c2;
     htp.nl;
     if c2arec.parent_scene is null
      then
       if c2arec.title is not null
        then
         htp.p( c2arec.title );
       end if;
      else
       open c2(c2arec.parent_scene);
       fetch c2 into c2brec;
       close c2;
       htp.p( c2brec.title || '.' || c2arec.title );
     end if;
     if sbrec.user_fee_code is not null
      then
       htp.nl;
       --htp.p( voidrec.uf_text_header || ':' || sbrec.user_fee_code || ' ' || '(' || trim(to_char(sbrec.original_photo_cost,LNG.MONEY_FORMAT)) || ')' );
       htp.p( 'User Fees' || ':' || sbrec.user_fee_code );
     end if;
     if sbrec.isgallery = 'P'
      then
       for c3prec in c3p(sbrec.poid,sbrec.shopping_id) loop
        htp.nl;
        htp.p( c3p%ROWCOUNT || '.' || ' ' || c3prec.film_name || '(' || c3prec.photo_size || ')' );
       end loop;
     end if;
     if sbrec.packaged_product_id is not null
      then
       open c3q(sbrec.poid,sbrec.packaged_product_id);
       fetch c3q into c3qrec;
       close c3q;
       htp.nl;
       htp.bold( 'Part of Packaged Product' || ':' || c3qrec.film_name || '(' || c3qrec.photo_size || ')'  );
     end if;

     -- Line Item # / Total (Qty)
     htp.nl;
     htp.p( sbitemtotal(sbrec.shopping_id, sbrec.poid) );
    htp.p( '</TD>' );

  if show_workflow
   then
    htp.p( '<TD ' || 'VALIGN="TOP" ALIGN="LEFT" ' ||  bgcolour_bdy || '>' );
     open c6( sbrec.status_workflow );
     fetch c6 into c6rec;
     close c6;
     htp.bold( c6rec.workflow_name );
     htp.nl;
     htp.p( LNG.PHG_TXT_082 || ':' || sbrec.status || ' (' || sbrec.status_id || ')' );
     if sbrec.status_comment is not null then htp.nl; htp.p( sbrec.status_comment ); end if;
     if sbrec.priority_of_item is not null then htp.nl; htp.p( LNG4.AHC_TXT_726 || ':' || sbrec.priority_of_item ); end if;
     if sbrec.status_mfctr is not null
      then
       open c7(sbrec.status_mfctr);
       fetch c7 into c7rec;
       close c7;
       htp.nl;
       htp.p( 'Mfctr: ' || c7rec.name );
     end if;

    htp.p( '</TD>' );
  end if;

  if show_metadata
   then
    htp.p( '<TD ' || 'VALIGN="TOP" ALIGN="LEFT" ' ||  bgcolour_bdy || '>' );
    if meta_tags.count > 0
     then
      for j in meta_tags.first..meta_tags.last loop
       c3rec.value := NULL;
       open c3( meta_tags(j), sbrec.phid );
       fetch c3 into c3rec;
       close c3;
       if j > 1 then htp.nl; end if;
       htp.p( c3rec.value );
      end loop;
    else
     htp.p( '&nbsp;' );
    end if;
    htp.p( '</TD>' );
  end if;

  htp.tabledata( to_char(sbrec.qty), cattributes=>'ALIGN="RIGHT" ' ||  bgcolour_bdy );
  htp.tabledata( to_char(sbrec.photo_cost,LNG.MONEY_FORMAT), cattributes=>'ALIGN="RIGHT" ' ||  bgcolour_bdy );

  if show_lab
   then
    htp.p( '<TD ' || 'ALIGN="RIGHT" ' ||  bgcolour_bdy || '>' );
    htp.p( sbrec.name || ' ' || to_char(nvl(sbrec.price,0),LNG.MONEY_FORMAT) );
    if nvl(sbrec.b2c_lab_discount,0) > 0
     then
      htp.nl;
      htp.italic( 'Disc' || ' ' || sbrec.b2c_lab_discount || '% (' || to_char(nvl(sbrec.price,0) * (1-(sbrec.b2c_lab_discount/100)),LNG.MONEY_FORMAT) || ')');
    end if;
    htp.p( '</TD>' );
  end if;

  if show_admin
   then
    htp.p( '<TD ' || 'ALIGN="RIGHT" ' ||  bgcolour_bdy || '>' );
    if sbrec.royalty_api is null
     then
      htp.p( '&nbsp;' );
     else
      htp.p( to_char( sbrec.royalty_api, LNG.MONEY_FORMAT ));
    end if;
    htp.p( '</TD>' );
  end if;

  if show_running_total then htp.tabledata( to_char(running_total, LNG.MONEY_FORMAT), cattributes=>'ALIGN="RIGHT" ' || bgcolour_bdy ); end if;

 htp.tablerowclose;
end show_row_sb;

procedure show_row(title in varchar2, v1 in varchar2, v2 in varchar2, v3 in varchar2, v4 in number, spantwo in boolean default FALSE )
as
begin
 htp.tablerowopen;
  htp.tabledata( '&nbsp;', cattributes=>bgcolour_hdr );
  if show_workflow then htp.tabledata( '&nbsp;', cattributes=>bgcolour_hdr ); end if;
  if show_metadata then htp.tabledata( '&nbsp;', cattributes=>bgcolour_hdr ); end if;
  if spantwo
   then
    htp.tabledata( title, cattributes=>'COLSPAN="2" ALIGN="LEFT" ' ||  bgcolour_bdy );
   else
    htp.tabledata( title, cattributes=>'ALIGN="LEFT" ' ||  bgcolour_bdy );
    htp.tabledata( v1, cattributes=>'STYLE=" " ALIGN="RIGHT" ' ||  bgcolour_bdy );
  end if;
  if show_lab then htp.tabledata( v2, cattributes=>' STYLE="text-align: right;" ALIGN="RIGHT" ' ||  bgcolour_bdy ); end if;
  if show_admin then htp.tabledata( v3, cattributes=>' STYLE="text-align: right;" ALIGN="RIGHT" ' ||  bgcolour_bdy ); end if;
  if show_running_total then htp.tabledata( to_char(v4, LNG.MONEY_FORMAT), cattributes=>' STYLE="text-align: right;" ALIGN="RIGHT" ' || bgcolour_bdy ); end if;
 htp.tablerowclose;
end show_row;

begin
 -- Set Parameters
 open c1(purchrec.oid);
 fetch c1 into voidrec;
 close c1;
 open c8(purchrec.pid);
 fetch c8 into c8rec;
 close c8;
 glbx.calculate_pricing( purchrec.poid, parm1, parm2 );
 table_defn := 'cellspacing=2 cellpadding=2 border=1';

 if options.count > 0
  then
   for j in options.first..options.last loop
    if options(j) = 'NO_THUMBNAIL' then show_thumbnail := FALSE; end if;
    if options(j) = 'WORKFLOW' then show_workflow := TRUE; end if;
    if options(j) = 'METADATA' then show_metadata := TRUE; end if;
    if options(j) = 'NO_LAB' then show_lab := FALSE; end if;
    if options(j) = 'NO_ADMIN' then show_admin := FALSE; end if;
    if options(j) = 'NO_HEADER' then show_header := FALSE; end if;
    if options(j) = 'RUNNING_TOTAL' then show_running_total := TRUE; end if;
    if options(j) = 'CUSTOMER' then not_customer := FALSE; end if;
    if substr(options(j),1,1) = '[' then meta_tags(meta_tags.count + 1) := substr(options(j),2,instr(options(j),']')-2); end if;
    if substr(options(j),1,6) = 'TABLE:' then table_defn := substr(options(j),7); end if;
    if substr(options(j),1,13) = 'BGCOLOUR_HDR:' then bgcolour_hdr := substr(options(j),14); end if;
    if substr(options(j),1,13) = 'BGCOLOUR_BDY:' then bgcolour_bdy := substr(options(j),14); end if;
   end loop;
 end if;

 htp.tableopen( cattributes=>table_defn );
  -- Display Item Listing
  running_total := 0;
  if show_header
   then
    htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_178 ), cattributes=>bgcolour_hdr || ' ALIGN="CENTER"' );
    if show_workflow then htp.tabledata( htf.bold( LNG5.EXT_TXT_264 ), cattributes=>bgcolour_hdr || ' ALIGN="CENTER"' ); end if;
    if show_metadata then htp.tabledata( htf.bold( LNG.CST_TXT_012 ), cattributes=>bgcolour_hdr || ' ALIGN="CENTER"' ); end if;
    htp.tabledata( htf.bold( LNG.ORD_TXT_185 ), cattributes=>bgcolour_hdr || ' ALIGN="CENTER"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_171 ), cattributes=>bgcolour_hdr || ' ALIGN="CENTER"' );
    if show_lab then htp.tabledata( htf.bold( LNG2.PBK_TXT_009 ), cattributes=>bgcolour_hdr || ' ALIGN="CENTER"' ); end if;
    if show_admin then htp.tabledata( htf.bold( LNG4.AHC_TXT_106 ), cattributes=>bgcolour_hdr || ' ALIGN="CENTER"' ); end if;
    if show_running_total then htp.tabledata( htf.bold( LNG.CST_TXT_138 ), cattributes=>bgcolour_hdr || ' ALIGN="CENTER"' ); end if;
    htp.tablerowclose;
  end if;

  for c2rec in c2(purchrec.poid) loop
   show_row_sb(c2rec,running_total);
  end loop;

  -- Display Final Calculations
  nmb := glbx.retrieve_pricing_value( 'SUB_TOTAL', parm1, parm2 );
  running_total := nmb;
  show_row( htf.bold(voidrec.text_subtotal), htf.bold(to_char(nmb, LNG.MONEY_FORMAT )), '&nbsp;', '&nbsp;', running_total );
  if purchrec.apply_discount_at = 'S'
   then
    txt := 'Discount';
    perc1 := glbx.retrieve_pricing_value( 'PHG_DISCOUNT', parm1, parm2 );
    if perc1 > 0 then txt := txt || ' ' || perc1 || '%'; end if;
    perc2 := glbx.retrieve_pricing_value( 'SPECIAL_DISCOUNT', parm1, parm2 );
    if perc2 > 0 and perc1 > 0 then txt := txt || '/' || perc2 || '%'; end if;
    if perc2 > 0 and perc1 = 0 then txt := txt || ' ' || perc2 || '%'; end if;
    nmb := glbx.retrieve_pricing_value( 'DISCOUNT', parm1, parm2 );
    if nmb > 0
     then
      show_row( txt, to_char(nmb, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total );
    end if;
  end if;

  gstnmb := glbx.retrieve_pricing_value( 'GST', parm1, parm2 );
  nmb3 := 0;
  nmb2 := 0;

  if gstnmb > 0
   then
    -- GST Added
    nmb3 := glbx.retrieve_pricing_value( 'GST_VALUE', parm1, parm2 );
    -- GST Inclusive
    nmb2 := glbx.retrieve_pricing_value( 'GST_INCLUSIVE', parm1, parm2 );
  end if;

  nmb := glbx.retrieve_pricing_value( 'TOTAL_PRODUCT_PRICE', parm1, parm2 );
  if nmb > 0 and show_lab then show_row( LNG5.EXT_TXT_389, '&nbsp;', to_char(nmb, LNG.MONEY_FORMAT ), '&nbsp;', running_total ); end if;
  nmb := glbx.retrieve_pricing_value( 'TOTAL_ROYALTY_API', parm1, parm2 );
  if nmb > 0 and show_admin then show_row( LNG5.EXT_TXT_388, '&nbsp;', '&nbsp;', to_char(nmb, LNG.MONEY_FORMAT ), running_total ); end if;
  nmb := glbx.retrieve_pricing_value( 'COMMISSION', parm1, parm2 );
  if nmb > 0 and show_admin then show_row( LNG.LAB_TXT_017, '&nbsp;', '&nbsp;', to_char(nmb, LNG.MONEY_FORMAT ), running_total ); end if;
  nmb := glbx.retrieve_pricing_value( 'TAX', parm1, parm2 );
  if nmb2 > 0
   then
    if nmb > 0 and show_admin then show_row( LNG5.EXT_TXT_390, '&nbsp;', '&nbsp;', '(Incl)' || to_char(nmb, LNG.MONEY_FORMAT ), running_total ); end if;
   else
    if nmb > 0 and show_admin then show_row( LNG5.EXT_TXT_390, '&nbsp;', '&nbsp;', '(Added)' || to_char(nmb, LNG.MONEY_FORMAT ), running_total ); end if;
  end if;

  if nvl(purchrec.manual_ship,'F') = 'F'
   then
    nmb := glbx.retrieve_pricing_value( 'POSTAGE', parm1, parm2 );
    if nmb > 0 then show_row( voidrec.pricing_postage_text, to_char(nmb, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total ); end if;
   else
    show_row( 'Option Chosen' || ':' || htf.nl || voidrec.text_manual_ship, '&nbsp;', '&nbsp;', '&nbsp;', running_total );
  end if;

  nmb := glbx.retrieve_pricing_value( 'LAB_POSTAGE', parm1, parm2 );
  if nmb > 0 and show_lab then show_row( LNG5.EXT_TXT_391, '&nbsp;', to_char(nmb, LNG.MONEY_FORMAT ), '&nbsp;',  running_total );  end if;
  nmb := glbx.retrieve_pricing_value( 'LAB_EXTRA_COST', parm1, parm2 );
  if nmb > 0 and show_lab then show_row( purchrec.mfctr_other_cost_desc, '&nbsp;', to_char(nmb, LNG.MONEY_FORMAT ),  '&nbsp;', running_total );  end if;

  nmb := glbx.retrieve_pricing_value( 'SURCHARGE', parm1, parm2 );
  if nmb > 0 then show_row( LNG5.EXT_TXT_392, to_char(nmb, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total ); end if;
  -- Additional Options
  -- Need to place outside call if an option is chosen that has no price with it
  for c10rec in c10( purchrec.poid ) loop
   if c10rec.display_receipt_page = 'M'
    then
     if c10rec.display_receipt_custresp = 'T'
      then
       show_row( c10rec.merchant_id_code, nvl(to_char(c10rec.chosen_price, LNG.MONEY_FORMAT ), '&nbsp;'), c10rec.customer_comment, '&nbsp;', running_total );
      else
       show_row( c10rec.merchant_id_code, nvl(to_char(c10rec.chosen_price, LNG.MONEY_FORMAT ), '&nbsp;'), '&nbsp;', '&nbsp;', running_total );
     end if;
   elsif c10rec.display_receipt_page = 'C'
    then
     if c10rec.display_receipt_custresp = 'T'
      then
       show_row( c10rec.display_text, nvl(to_char(c10rec.chosen_price, LNG.MONEY_FORMAT ), '&nbsp;'), c10rec.customer_comment, '&nbsp;', running_total );
      else
       show_row( c10rec.display_text, nvl(to_char(c10rec.chosen_price, LNG.MONEY_FORMAT ), '&nbsp;'), '&nbsp;', '&nbsp;', running_total );
     end if;
   end if;
  end loop;
  nmb := glbx.retrieve_pricing_value( 'ADDITIONAL_OPTIONS', parm1, parm2 );
  if nmb > 0
   then
    show_row( htf.bold(voidrec.disp_gift_wrap_title), htf.bold(to_char(nmb, LNG.MONEY_FORMAT )), '&nbsp;', '&nbsp;', running_total );
  end if;

  if purchrec.apply_discount_at = 'P'
   then
    txt := 'Discount';
    perc1 := glbx.retrieve_pricing_value( 'PHG_DISCOUNT', parm1, parm2 );
    if perc1 > 0 then txt := txt || ' ' || perc1 || '%'; end if;
    perc2 := glbx.retrieve_pricing_value( 'SPECIAL_DISCOUNT', parm1, parm2 );
    if perc2 > 0 and perc1 > 0 then txt := txt || '/' || perc2 || '%'; end if;
    if perc2 > 0 and perc1 = 0 then txt := txt || ' ' || perc2 || '%'; end if;
    nmb := glbx.retrieve_pricing_value( 'DISCOUNT', parm1, parm2 );
    if nmb > 0
     then
      show_row( txt, to_char(nmb, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total );
    end if;
  end if;

  if gstnmb > 0
   then
    txt := ' (' || gstnmb || '%)';
    if nmb2 > 0
     then
      null;
      -- Shown After Total
      --show_row( voidrec.pricing_gst_text || '(Inc)-' || txt, to_char(nmb2, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total );
     elsif nmb3 > 0
      then
       show_row( voidrec.pricing_gst_text || '(Added)-' || txt, to_char(nmb3, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total );
    end if;
  end if;

  if purchrec.apply_discount_at = 'F'
   then
    txt := LNG5.EXT_TXT_382;
    perc1 := glbx.retrieve_pricing_value( 'PHG_DISCOUNT', parm1, parm2 );
    if perc1 > 0 then txt := txt || ' ' || perc1 || '%'; end if;
    perc2 := glbx.retrieve_pricing_value( 'SPECIAL_DISCOUNT', parm1, parm2 );
    if perc2 > 0 and perc1 > 0 then txt := txt || '/' || perc2 || '%'; end if;
    if perc2 > 0 and perc1 = 0 then txt := txt || ' ' || perc2 || '%'; end if;
    nmb := glbx.retrieve_pricing_value( 'DISCOUNT', parm1, parm2 );
    if nmb > 0
     then
      show_row( txt, '-' || to_char(nmb, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total );
    end if;
  end if;

  nmb := glbx.retrieve_pricing_value( 'HANDLING', parm1, parm2 );
  if nmb > 0 and not_customer and show_admin then show_row( LNG5.EXT_TXT_385, '&nbsp;', '&nbsp;', to_char(nmb, LNG.MONEY_FORMAT ), running_total ); end if;

  nmb := glbx.retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 );
  if nmb > 0 then show_row( htf.bold(voidrec.text_grandtotal), htf.bold(to_char(nmb, LNG.MONEY_FORMAT )), '&nbsp;', '&nbsp;', running_total ); end if;

  nmb := glbx.retrieve_pricing_value( 'CERTIFICATE_TOTAL', parm1, parm2 );
  if nmb > 0
   then
    nmb2 := glbx.retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 );
    show_row( LNG5.EXT_TXT_279, to_char(nmb, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total );
    show_row( voidrec.text_grandtotal || ' (- Certificate)', to_char(nmb2, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total );
  end if;

  if gstnmb > 0
   then
    txt := ' (' || gstnmb || '%)';
    nmb2 := glbx.retrieve_pricing_value( 'GST_INCLUSIVE', parm1, parm2 );
    if nmb2 > 0
     then
      show_row( voidrec.pricing_gst_text || '(Inc)-' || txt, to_char(nmb2, LNG.MONEY_FORMAT ), '&nbsp;', '&nbsp;', running_total );
    end if;
  end if;

  if voidrec.text_message_under_total is not null
   then
    show_row( voidrec.text_message_under_total, '&nbsp;', '&nbsp;', '&nbsp;', running_total, TRUE );
  end if;

  nmb := glbx.retrieve_pricing_value( 'PHOTOGRAPHER_GETS', parm1, parm2 );
  if not_customer then show_row( replace(LNG5.EXT_TXT_386,'<PHOTOGRAPHER>',c8rec.photographer_title), htf.bold(to_char(nmb, LNG.MONEY_FORMAT )), '&nbsp;', '&nbsp;', running_total ); end if;
  nmb := glbx.retrieve_pricing_value( 'LAB_GETS', parm1, parm2 );
  if nmb > 0 and show_lab then show_row( LNG5.EXT_TXT_387, '&nbsp;', htf.bold(to_char(nmb, LNG.MONEY_FORMAT )), '&nbsp;', running_total ); end if;
  nmb := glbx.retrieve_pricing_value( 'GETS', parm1, parm2 );
  if nmb > 0 and show_admin then show_row( LNG5.EXT_TXT_384, '&nbsp;', '&nbsp;', htf.bold(to_char(nmb, LNG.MONEY_FORMAT )), running_total ); end if;

  nmb := glbx.retrieve_pricing_value( 'REFUND', parm1, parm2 );
  if nmb > 0 then show_row( LNG5.EXT_TXT_383 || ' ' || to_char(purchrec.refund_date,LNG.TSMASK), htf.bold(to_char(nmb, LNG.MONEY_FORMAT )), '&nbsp;', '&nbsp;', running_total ); end if;

  -- xxx Language File
  for c9rec in c9(purchrec.poid) loop
   if to_number(c9rec.new_value) > 0 then show_row( 'Manual Payment' || ' ' || to_char(c9rec.date_changed,LNG.TSMASK), htf.bold(to_char(to_number(c9rec.new_value), LNG.MONEY_FORMAT )), '&nbsp;', '&nbsp;', running_total ); end if;
  end loop;

 htp.tableclose;

exception when others then
 glbx.error_details( 'ORD', 'DISPLAY_ORDER_SUBTOTAL',null,null,errmsg=>sqlerrm,extdet=>'PURCHORD:' || purchrec.poid);
end display_order_subtotal;

procedure display_order_details(surl in varchar2, ltype in varchar2, purchrec in purchase_order%ROWTYPE, options in GLBX.MYARRAY )
as

 cursor c1(acid integer) is select username,account_name from customer_account where aid = acid;
 cursor c1p(profid integer) is select username,account_name from customer_profile where profile_id = profid;
 cursor c1ph(phgid integer) is select username,business_name account_name from photographer where pid = phgid;
 cursor c1a(vpoid integer) is select aid, login_type from login_session where sessid = (select sessid from purchase_order where poid= vpoid);
 cursor c2(vpoid integer) is select username,business_name from photographer where pid = (select pid from purchase_order where poid = vpoid );
 cursor c4(vpoid integer) is select card_number,card_type,card_expiry,card_name from credit_card where poid = vpoid;
 cursor c6(vpoid integer) is select pnumber,contact_det from order_contact_phone_number where poid = vpoid;
 cursor c7(void integer) is select * from order_style where oid = void;
 cursor c8(profid integer) is select * from customer_profile where profile_id = profid;
 cursor c9(phgid integer) is select * from photographer where pid = phgid;
 cursor c10(ownid integer) is select * from manufacturer where manufacturer_id = ownid;

 c1rec 			c1%ROWTYPE;
 c1arec 		c1a%ROWTYPE;
 c2rec 			c2%ROWTYPE;
 c4rec 			c4%ROWTYPE;
 c8rec 			c8%ROWTYPE;
 c9rec 			c9%ROWTYPE;
 c10rec 		c10%ROWTYPE;
 table_defn		varchar2(1000);
 bgcolour_hdr		varchar2(100) := 'BGCOLOR="#FFFFFF"';
 bgcolour_bdy		varchar2(100) := 'BGCOLOR="#FFFFFF"';
 voidrec		order_style%ROWTYPE;
 show_details		boolean := TRUE;
 show_business		boolean := FALSE;
 show_purchase		boolean := FALSE;
 show_order		boolean := FALSE;
 show_photographer	boolean := FALSE;
 linefeed		boolean := FALSE;
 empty_nodisplay	boolean := FALSE;
 options2 		GLBX.MYARRAY;
 vmfctr			integer;

begin
 -- Set Parameters
 open c7(purchrec.poid);
 fetch c7 into voidrec;
 close c7;
 table_defn := 'cellspacing=2 cellpadding=2 border=1';

 if options.count > 0
  then
   for j in options.first..options.last loop
    if options(j) = 'NO_DETAILS' then show_details := FALSE; end if;
    if options(j) = 'LINEFEED' then linefeed := TRUE; end if;
    if options(j) = 'BUSINESS' then show_business := TRUE; end if;
    if options(j) = 'PURCHASE' then show_purchase := TRUE; end if;
    if options(j) = 'ORDER_SUMMARY' then show_order := TRUE; end if;
    if options(j) = 'PHOTOGRAPHER' then show_photographer := TRUE; end if;
    if options(j) = 'NODISPLAY_IF_EMPTY' then empty_nodisplay := TRUE; end if;
    if substr(options(j),1,6) = 'TABLE:' then table_defn := substr(options(j),7); end if;
    if substr(options(j),1,13) = 'BGCOLOUR_HDR:' then bgcolour_hdr := substr(options(j),14); end if;
    if substr(options(j),1,13) = 'BGCOLOUR_BDY:' then bgcolour_bdy := substr(options(j),14); end if;
    if substr(options(j),1,6) = 'MFCTR:' then vmfctr := to_number(substr(options(j),7)); end if;
   end loop;
 end if;

 if show_business
  then
   open c1a(purchrec.poid);
   fetch c1a into c1arec;
   close c1a;
   if c1arec.login_type in ('OWNER','CUSTOMER','VIRTUAL')
    then
     open c1(c1arec.aid);
     fetch c1 into c1rec;
     close c1;
   elsif c1arec.login_type in ('PROFILE','PROFILEG')
    then
     open c1p(c1arec.aid);
     fetch c1p into c1rec;
     close c1p;
   elsif c1arec.login_type = 'PHOTOGRAPHER'
    then
     open c1ph(c1arec.aid);
     fetch c1ph into c1rec;
     close c1ph;
   end if;
   open c2(purchrec.poid);
   fetch c2 into c2rec;
   close c2;
   if linefeed then htp.nl; end if;
   htp.tableopen( cattributes=>table_defn );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_094),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(purchrec.poid),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_082),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(purchrec.status),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_078),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(to_char(purchrec.date_created,LNG.TSMASK)),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_031),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c1rec.username),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_164),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c1rec.account_name),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG3.ADM_TXT_261 || ' ' || LNG.GLB_TXT_076),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c2rec.username),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_004),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(c2rec.business_name),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tableclose;
 end if;

 if show_photographer
  then
   open c9(purchrec.pid);
   fetch c9 into c9rec;
   close c9;

   open c10(vmfctr);
   fetch c10 into c10rec;
   close c10;
   if linefeed then htp.nl; end if;

   htp.tableopen( cattributes=>table_defn );
     htp.tablerowopen;
      htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
       htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' );
        htp.tablerowopen;

         if glbx.gif_exists('http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || DECS.IMAGE_LOCATION || c10rec.username || '.gif')
          then
           htp.tabledata( htf.img( DECS.IMAGE_LOCATION || c10rec.username || '.gif', cattributes=>'BORDER=0') );
         end if;

         htp.tabledata( upper(LNG.ORD_TXT_156) || htf.nl || htf.bold(c10rec.name) || htf.nl || htf.italic( c10rec.contact ) || htf.nl ||
                        LNG.GLB_TXT_107 || ':' || c10rec.abn_number ,cattributes=>'valign="MIDDLE" align="CENTER"' );
         htp.tabledata( LNG.ORD_TXT_197 || '#' || htf.bold( purchrec.poid ),cattributes=>'valign="MIDDLE" align="CENTER"' );
         htp.tablerowclose;
       htp.tableclose;
      htp.p( '</TD>' );
     htp.tablerowclose;

     htp.tablerowopen;
      -- Name, Company
      htp.p( '<TD>' );
       htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_022 || ':') );
         htp.tabledata( c9rec.business_name );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.ORD_TXT_187 || ':') );
         htp.tabledata( '(w)' || c9rec.work_phone || ' (m)' || c9rec.mobile_phone || ' (f)' || c9rec.contact_fax || ' (e)' || c9rec.contact_email );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.CST_TXT_006 || ':') );
         htp.tabledata( c9rec.contact_street || ' ' || c9rec.contact_suburb );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( '&nbsp;' );
         htp.tabledata( c9rec.contact_city || ' ' || c9rec.contact_pcode );
        htp.tablerowclose;
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.ORD_TXT_188 || ':') );
         htp.tabledata( to_char(sysdate,LNG.MASK));
        htp.tablerowclose;
       htp.tableclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tableclose;
 end if;

 if show_details
  then
   if linefeed then htp.nl; end if;
   htp.tableopen( cattributes=>table_defn );
    htp.tableopen( cattributes=>'cellpading=2 cellspacing=2 border=1' );
    if nvl(substr(voidrec.columns_display,1,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_name is not null) or not empty_nodisplay)
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(nvl(voidrec.columns_name,LNG.PHG_TXT_084)),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
      htp.tabledata( nvl(purchrec.sendto_name,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,20,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_branch is not null) or not empty_nodisplay)
    then
      htp.tablerowopen;
       htp.tabledata( htf.bold(nvl(voidrec.columns_branch,'&nbsp;')),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
       htp.tabledata( nvl(purchrec.sendto_branch,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,21,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_department is not null) or not empty_nodisplay)
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold(nvl(voidrec.columns_department,'&nbsp;')),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
       htp.tabledata( nvl(purchrec.sendto_department,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,2,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_street is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_street,LNG.CST_TXT_113)),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
     htp.tabledata( nvl(purchrec.sendto_street,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,3,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_suburb is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_suburb,LNG.PHG_TXT_101)),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
     htp.tabledata( nvl(purchrec.sendto_suburb,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,4,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_city is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_city,LNG.PHG_TXT_102)),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
     htp.tabledata( nvl(purchrec.sendto_city,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,17,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_state is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_state,LNG.PHG_TXT_103)),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
     htp.tabledata( nvl(purchrec.sendto_state,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,6,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_country is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_country,LNG.PHG_TXT_103)),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
     htp.tabledata( nvl(purchrec.sendto_country,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,5,1),'T') = 'T' and ((empty_nodisplay and purchrec.sendto_postcode is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_postcode,LNG.PHG_TXT_104)),cattributes=>bgcolour_hdr || 'valign="TOP" ALIGN="LEFT"' );
     htp.tabledata( nvl(purchrec.sendto_postcode,'&nbsp;'),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,8,1),'T') = 'T' and ((empty_nodisplay and purchrec.contact_email is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_email,LNG.PHG_TXT_301)),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.contact_email,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,7,1),'T') = 'T' and ((empty_nodisplay and purchrec.contact_phone is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_phone,LNG.CST_TXT_108)),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.contact_phone,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if (empty_nodisplay and purchrec.order_comment is not null) or not empty_nodisplay
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_comment,LNG.CST_TXT_051)),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(replace(replace(purchrec.order_comment || htf.nl || htf.italic(purchrec.customer_comment),chr(13),'<BR>'),chr(10),'<BR>')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,11,1),'T') = 'T' and ((empty_nodisplay and purchrec.customer_column1 is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_cust_col1,'User Defined' || '1')),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.customer_column1,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,12,1),'T') = 'T' and ((empty_nodisplay and purchrec.customer_column2 is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_cust_col2,'User Defined' || '2')),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.customer_column2,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,13,1),'T') = 'T' and ((empty_nodisplay and purchrec.customer_column3 is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_cust_col3,'User Defined' || '3')),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.customer_column3,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,14,1),'T') = 'T' and ((empty_nodisplay and purchrec.customer_column4 is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_cust_col4,'User Defined' || '4')),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.customer_column4,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,15,1),'T') = 'T' and ((empty_nodisplay and purchrec.customer_column5 is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_cust_col5,'User Defined' || '5')),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.customer_column5,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    if nvl(substr(voidrec.columns_display,16,1),'T') = 'T' and ((empty_nodisplay and purchrec.customer_column6 is not null) or not empty_nodisplay)
    then
    htp.tablerowopen;
     htp.tabledata( htf.bold(nvl(voidrec.columns_cust_col6,'User Defined' || '6')),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.customer_column6,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    end if;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_762),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     if purchrec.do_not_split_order = 'T'
      then
       htp.tabledata( htf.bold(LNG.PHG_TXT_045),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
      else
       htp.tabledata( htf.bold(LNG.PHG_TXT_046),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
     end if;
    htp.tablerowclose;
    for c6rec in c6(purchrec.poid) loop
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_096),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.bold(c6rec.pnumber) || '-' || c6rec.contact_det,cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tablerowclose;
    end loop;
    htp.tableclose;
 end if;

 if show_purchase
  then
   open c4(purchrec.poid);
   fetch c4 into c4rec;
   close c4;
   if linefeed then htp.nl; end if;
   htp.tableopen( cattributes=>table_defn );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.ORD_TXT_179),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(purchrec.paid_method),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    /*
    if purchrec.wrap_gift = 'T'
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.ORD_TXT_023),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.tabledata( LNG.CST_TXT_121 || ' ' || purchrec.wrap_gift,cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tablerowclose;
    end if;
    */
    if c4rec.card_number is not null
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.ORD_TXT_177),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.tabledata( htf.bold(c4rec.card_number) || htf.nl || c4rec.card_type || htf.nl || c4rec.card_expiry || htf.nl || c4rec.card_name,cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
    end if;
    if purchrec.paid_method = 'MERCHANT'
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.ORD_TXT_177),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.tabledata( htf.bold(purchrec.merchant_reference) || htf.nl || purchrec.m_rrn || htf.nl || purchrec.m_response_code || htf.nl || purchrec.m_response_text || htf.nl || purchrec.m_settlement_date,cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
    elsif purchrec.paid_method = 'AUTHORISE'
     then
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG4.AHC_TXT_692),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
       open c8(purchrec.authorised_by);
       fetch c8 into c8rec;
       close c8;
       htp.tabledata( htf.bold(purchrec.project_code) || htf.nl || c8rec.username || htf.nl || to_char(purchrec.authorised_date,LNG.MASK),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
    end if;
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG5.EXT_TXT_182),cattributes=>bgcolour_hdr || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(nvl(purchrec.cheque_receipt_number,'&nbsp;')),cattributes=>bgcolour_bdy || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tableclose;
 end if;

 if show_order
  then
   if linefeed then htp.nl; end if;
   options2(1) := 'BGCOLOUR_HDR:' || bgcolour_hdr;
   options2(2) := 'BGCOLOUR_BDY:' || bgcolour_bdy;
   options2(3) := 'TABLE:' || table_defn;
   display_order_subtotal( surl, ltype, purchrec, options2 );
 end if;

exception when others then
 glbx.error_details( 'ORD', 'DISPLAY_ORDER_DETAILS',null,null,errmsg=>sqlerrm,extdet=>'PURCHORD:' || purchrec.poid);
end display_order_details;

function sbitemtotal(shpid in integer , vpoid in integer)
 return varchar2
as
 cursor c1(vpoid integer) is select shopping_id,qty from shopping_basket where poid = vpoid order by decode(isgallery,'P',0,1),nvl(packaged_product_id,999999999),shopping_id;
 ctr1	integer;
 ctr2	integer;
 ctr3	integer;
begin
 ctr1 := 0;
 ctr2 := 0;
 ctr3 := 0;
 for c1rec in c1(vpoid) loop
  ctr2 := ctr2 + 1;
  ctr3 := ctr3 + nvl(c1rec.qty,1);
  if c1rec.shopping_id = shpid then ctr1 := ctr2; end if;
 end loop;
 if shpid is null
  then
   return( 'Itm:' || ctr2 || htf.nl || ' Ttl:' || ctr3 ); -- Purchase Order Summary Line
  else
   return( ctr1 || '/' || ctr2 || '-' || '(' || ctr3 || ')' ); -- Shopping Basket Item Line
 end if;
end sbitemtotal;

end ord;

/
