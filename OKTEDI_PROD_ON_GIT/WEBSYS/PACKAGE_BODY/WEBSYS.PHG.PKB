CREATE OR REPLACE package body WEBSYS.phg
as

  function get_theme_types(surl in varchar2, acid in integer, ltype in varchar2 default null) return theme_types%ROWTYPE;
  function check_renewal(surl in varchar2, sesid in integer) return boolean;
  function indnt( pscene integer ) return integer;
  function top_frame_business_feature( phgid in integer, bf_numb in integer ) return boolean;
  function p_title( phgid in integer ) return varchar2;
  function image_exists_in_nested( uscid integer, phgr integer ) return boolean;

  procedure phg_comma_del( surl in varchar2, acid in integer, typ in varchar2 );
  procedure disp_new_photos( surl in varchar2, acid in integer, new_photos in LISTINT );
  procedure completely_delete_account( phgid integer, acid in integer, action in varchar2 DEFAULT 'DISABLE' );
  procedure audit_utility( v_umo in integer, colval in varchar2, oldval in varchar2, newval in varchar2, extdet in varchar2 default null );
  procedure display_thumbnail(surl in varchar2, ltype in varchar2, umrec in UMO%ROWTYPE,theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE,
                              footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, hor_caption in varchar2,
                              document_api in varchar2, video_api in varchar2, audio_api in varchar2, relational_api in varchar2, blueprint_api in varchar2, acid in integer default null );
  procedure change_loc( v_umo in integer, film_name in varchar2, virdir in varchar2, voption in varchar2 );
  procedure delimg(vumo_id integer, utype varchar2);

procedure screen_sze( surl in varchar2, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null)
as

begin

htp.htmlopen;
htp.p( '<HEAD>' );
htp.title( glbx.extract_master_parameter('PAGE_TITLE') );
htp.p( '
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function fillFrame()
{
  var urlsvga = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=1&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";
  var urlxga  = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=2&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";
  var urlsxga = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=3&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";
  var urluga  = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=4&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";
  var urlxuga = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=5&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";

  if (screen.width < 800)
   parent.xtop.location.href= urlsvga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 800) && (screen.width < 1024))
   parent.xtop.location.href= urlsvga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1024) && (screen.width < 1280))
   parent.xtop.location.href= urlxga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1280) && (screen.width < 1400))
   parent.xtop.location.href= urlsxga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1400) && (screen.width < 1600))
   parent.xtop.location.href= urluga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else
   parent.xtop.location.href= urlxuga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
}
//  End -->
</script>
</HEAD>
<FRAMESET ROWS="100" COLS="100%" frameborder="0" framespacing="0" border="0" onLoad="fillFrame();">
  <FRAME NAME="xtop" >
</FRAMESET>
<BODY>
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function fillFrame()
{
  var urlsvga = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=1&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";
  var urlxga  = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=2&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";
  var urlsxga = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=3&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";
  var urluga  = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=4&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";
  var urlxuga = "phg.phg_master?surl=' || glbx.rndsurl(surl) || '&stype=5&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '";

  if (screen.width < 800)
   parent.xtop.location.href= urlsvga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 800) && (screen.width < 1024))
   parent.xtop.location.href= urlsvga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1024) && (screen.width < 1280))
   parent.xtop.location.href= urlxga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1280) && (screen.width < 1400))
   parent.xtop.location.href= urlsxga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1400) && (screen.width < 1600))
   parent.xtop.location.href= urluga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else
   parent.xtop.location.href= urlxuga + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
}
//  End -->
</script>
<NOFRAMES>' );
glbx.noframe(surl,'PHG.SCREEN_SZE');
htp.p( '</NOFRAMES>' );
htp.p( '</BODY>' );
htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'SCREEN_SZE',errmsg=>sqlerrm);
end screen_sze;

procedure phg_master(surl in varchar2, stype in integer default 1, bplatform in varchar2 default null, bvers in varchar2 default NULL, bos in varchar2 default null, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null)
as

 cursor c1(sesid integer) is select aid from login_session where sessid = sesid;
 cursor c2(phgid integer) is select account_enabled from photographer where pid = phgid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 sxtype		integer;
 sesid		integer;
 nmb		number;
 expiry		boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl, sxtype, ltype, sesid, sts, 'S', progcalled=>'PHG.PHG_MASTER', iscust=>FALSE );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if glbx.extract_master_parameter('TEST_BROWSER_VERSION') = 'TRUE'
   then
    if substr(upper(bplatform),1,8) = 'NETSCAPE'
     then
      nmb := glbx.extract_master_parameter('NETSCAPE');
      if to_number(bvers) < nmb
       then
        htp.htmlopen;
         htp.header( 2, LNG2.PFM_TXT_083 || ':' || nmb, 'CENTER' );
        htp.htmlclose;
        return;
      end if;
    elsif substr(upper(bplatform),1,9) = 'MICROSOFT'
     then
      nmb := glbx.extract_master_parameter('MICROSOFT');
      if to_number(bvers) < nmb
       then
        htp.htmlopen;
         htp.header( 2, LNG2.PFM_TXT_083 || ':' || nmb, 'CENTER' );
        htp.htmlclose;
        return;
      end if;
    end if;
  end if;

  update login_session
   set
    screen_type = stype,
    browser_version = bvers,
    browser_type = bplatform,
    os = bos
   where sessid = sesid;
  commit;

  open c1(sesid);
  fetch c1 into c1rec;
  close c1;
  pfx := glbx.photo_lf( c1rec.aid );

  expiry := check_renewal(surl,sesid);
  -- If the account has expired, it might also be disabled. Check if this is so, and if so exit
  if expiry
   then
    open c2(c1rec.aid);
    fetch c2 into c2rec;
    close c2;
     if nvl(c2rec.account_enabled,'T') = 'F'
      then
       glbx.phg_account_disabled;
       return;
     end if;
  end if;

  htp.htmlopen;
  htp.p( '<HEAD>' || pfx.icra_label || htf.title( glbx.extract_master_parameter('BAR_TITLE') ) || '</HEAD>' );
  htp.framesetopen(glbx.sctrl(pfx.theme_name,'CST_OUTER_FRAME_SIZE',stype),'100%',cattributes=>'frameborder="1" framespacing="0" border="1"  ');   --onUnload="history.go(-1);"
   htp.frame( 'phg.phg_header?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS'),'TOP');
   if expiry
    then
     htp.frame( 'phg.phg_renewal?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS'),'PHG_BOTTOM');
    else
     htp.frame( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS'),'PHG_BOTTOM');
   end if;
  htp.framesetclose;
  htp.p( '<BODY  >' ); -- onUnload="history.go(-1);"
  htp.noframesopen;
   glbx.noframe(surl,'PHG.PHG_MASTER');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_MASTER',errmsg=>sqlerrm);
end phg_master;

function  check_renewal(surl in varchar2, sesid in integer)
 return boolean
as

 cursor c2(sesid integer) is select date_expires,disable_acct_expired from login_session ls,photographer ph where ls.aid=ph.pid and ls.sessid = sesid;
 c2rec	c2%ROWTYPE;

begin
 open c2(sesid);
 fetch c2 into c2rec;
 close c2;
 -- Disable the Account Automatically if Request by Administrator
 if (c2rec.date_expires is not null) and
    (sysdate > c2rec.date_expires) and
    (c2rec.disable_acct_expired = 'T')
  then
   update photographer
    set
     account_enabled = 'F'
   where
    pid = (select aid from login_session where sessid = sesid);
   commit;
   return( TRUE );
 end if;

 if (c2rec.date_expires is not null) and
    (sysdate > (c2rec.date_expires - nvl(to_number(glbx.extract_master_parameter('INVOICE_REMINDER')),30)))
 then
   return( TRUE );
  else
   return( FALSE );
 end if;
exception when others then
 glbx.error_details( 'PHG', 'CHECK_RENEWAL',errmsg=>sqlerrm);
 return( FALSE );
end check_renewal;

procedure phg_renewal(surl in varchar2,rnd in integer default 1234)
as
 cursor c1(owner_id integer) is select date_expires from photographer where pid = owner_id;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		varchar2(4);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_RENEWAL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 pfx := glbx.get_hfx( owner_id );
 glbx.main_title( surl, LNG.PHG_ALT_297,'<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || pfx || '/' || 'bac2.gif">',helpid=>'P32',stype=>stype,sstyle=>'Arial',sclr=>'000000',det_sclr=>'000F00',det_sstyle=>'Verdana');
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;
 htp.nl;
 htp.nl;
 htp.nl;
 htp.nl;
 htp.nl;
 htp.nl;
 htp.p( '<CENTER>' );
  htp.header(3,LNG.PHG_ALT_283 || ':' || to_char(c1rec.date_expires,LNG.MASK),'CENTER' );
 htp.nl;
 htp.nl;
 htp.formopen( 'phg.ack_renewal' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formsubmit( null, LNG.PHG_ALT_289 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_RENEWAL',errmsg=>sqlerrm);
end phg_renewal;

procedure ack_renewal(surl in varchar2)
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACK_RENEWAL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 update photographer set renewal_acknowledged = 'T' where pid = owner_id;
 commit;
 phg_accts(surl,to_char(sysdate,'SSSSS'));
exception when others then
 glbx.error_details( 'PHG', 'ACK_RENEWAL',errmsg=>sqlerrm);
end ack_renewal;

procedure phg_header(surl in varchar2, rnd in integer default 1234)
as

 cursor c1(phgid integer) is select pid,business_name,username,home_site,logo_phid,theme_type,forum_enabled,photographer_title from photographer where pid = phgid;

 cursor c2(phgr integer) is
  select um.umo_id
   from umo um, customer_account ca
   where um.aid in (select aid from customer_account where pid = phgr) and
         um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'T' and
         umo_type = 'ICON';

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		theme%ROWTYPE;
 tmp		varchar2(32767);
 tmp2		varchar2(32767);
 theme_rec	theme_types%ROWTYPE;
 width		integer;
 height		integer;
 hsite		varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_HEADER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.photo_lf(owner_id);
 theme_rec := get_theme_types( surl,owner_id, ltype );
 tmp := NULL;

 for c2rec in c2(owner_id) loop
    width := to_number(ump.uma_attribute( surl,c2rec.umo_id, 'ICON', 'DISPLAY_WIDTH' ));
    height := to_number(ump.uma_attribute( surl,c2rec.umo_id, 'ICON', 'DISPLAY_HEIGHT' ));
    hsite := ump.uma_attribute( surl,c2rec.umo_id, 'ICON', 'HTTP_LINK' );
    if hsite is null
     then
        tmp := tmp || htf.tabledata('<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id ||
              '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER' ||
              '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
              '" ALT="' || hsite || '" STYLE="display:block;">');
    else
        tmp := tmp || htf.tabledata(htf.anchor2( glbx.adjust_for_http(hsite),'<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id ||
              '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER' ||
              '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
              '" ALT="' || hsite || '" STYLE="display:block;">',ctarget=>'_top' ));
    end if;
 end loop;

 tmp2 := NULL;
 -- xxx language file
 if substr(theme_rec.theme_data,143,1) = 'T'
  then
   if substr(theme_rec.theme_data,116,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS'),htf.img( DECS.IMAGE_LOCATION || 'admin/acct.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_121 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,117,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('phg.phg_prefs_txt?surl=' || glbx.rndsurl(surl) || '&acid=0',htf.img( DECS.IMAGE_LOCATION || 'admin/global.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_274 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,10,1)  = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('fname.main?surl=' || glbx.rndsurl(surl) || '&msg=',htf.img( DECS.IMAGE_LOCATION || 'admin/ordstyle.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_134 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,78,1)  = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.main?surl=' || glbx.rndsurl(surl) || '&msg=',htf.img( DECS.IMAGE_LOCATION || 'admin/pbook.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_470 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,24,1)  = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pfm.purchrep?surl=' || glbx.rndsurl(surl) || '&msg=',htf.img( DECS.IMAGE_LOCATION || 'admin/advrep.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_547 ),ctarget=>'ADVANCED_REPORT')); end if;
   if substr(theme_rec.theme_data,36,1)  = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pfm.imgrep?surl=' || glbx.rndsurl(surl) || '&msg=',htf.img( DECS.IMAGE_LOCATION || 'admin/imgrep.gif',cattributes=>'border=0',calt=>'Advanced Image Report' ),ctarget=>'ADVANCED_IMAGE')); end if;
   if substr(theme_rec.theme_data,430,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('oltp.view_report?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/reports.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_432),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,118,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('phg.phg_personal?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/pers.gif',cattributes=>'border=0',calt=>replace(LNG2.PBK_TXT_079,'<PHOTOGRAPHER>',c1rec.photographer_title) ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,139,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.mng_warranty?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/warranty.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_058 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,140,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.mng_clearance?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/clearance.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_052 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,169,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.tender_list?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/tender.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_027 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,171,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.reverse_list?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/reverse.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_038 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,48,1)  = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pfm.manage_portlets?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/portlet.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_656 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,387,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.mng_workflow?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/pref_workflow.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_610 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,388,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.mng_simple_rfq?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/srfq.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_628 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,409,1) = 'T' then tmp2 := tmp2 || htf.tableData(htf.anchor2('cal.update_calendar?surl=' || glbx.rndsurl(surl), htf.img(DECS.IMAGE_LOCATION || 'admin/book.gif', cattributes=>'border=0', calt=>LNG5.CAL_TXT_001), ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,77,1)  = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('phg.manage_gallery?surl=' || glbx.rndsurl(surl) || '&acid=&msg=',htf.img( DECS.IMAGE_LOCATION || 'admin/gallery.gif',cattributes=>'border=0',calt=>replace(LNG.CST_TXT_220,'<PHOTOGRAPHER>',c1rec.photographer_title) ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,158,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.addr?surl=' || glbx.rndsurl(surl) || '&msg=',htf.img( DECS.IMAGE_LOCATION || 'admin/abook.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_151 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,177,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('pbk.contactus?surl=' || glbx.rndsurl(surl) || '&msg=',htf.img( DECS.IMAGE_LOCATION || 'adminc/phgcontactus.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_275 ),ctarget=>'PHG_BOTTOM')); end if;
   if (substr(theme_rec.theme_data,120,1)= 'T') and
      (c1rec.forum_enabled = 'T') then tmp2 := tmp2 || htf.tabledata(htf.anchor2('forum.display_forum?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/forum.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_437 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,74,1)  = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('phg.readme?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/readme.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_448 ),ctarget=>'PHG_BOTTOM')); end if;
   if substr(theme_rec.theme_data,121,1) = 'T' then tmp2 := tmp2 || htf.tabledata(htf.anchor2('glbx.acct_logoff?surl=' || glbx.rndsurl(surl) || '&iscust=>F',htf.img( DECS.IMAGE_LOCATION || 'admin/logoff.gif',cattributes=>'border=0',calt=>LNG.CST_ALT_021 ),ctarget=>'_top')); end if;
 end if;

 if substr(theme_rec.theme_data,141,1) = 'T'
  then
   tmp2 := tmp2 || '<TD>';
   tmp2 := tmp2 || htf.formopen( 'form' );
   tmp2 := tmp2 || htf.formselectopen( 'site', cattributes=>'onChange="parent.frames[1].location.href = this.options[this.selectedIndex].value;"' );
   tmp2 := tmp2 || htf.formselectoption( 'Go to....', cattributes=>'Value=""' );
   if substr(theme_rec.theme_data,116,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG.PHG_ALT_121, cattributes=>'VALUE="phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '"'); end if;
   if substr(theme_rec.theme_data,117,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG.PHG_TXT_274, cattributes=>'VALUE="phg.phg_prefs_txt?surl=' || glbx.rndsurl(surl) || '&acid=0' || '"'); end if;
   if substr(theme_rec.theme_data,10,1)  = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG5.EXT_TXT_134, cattributes=>'VALUE="fname.main?surl=' || glbx.rndsurl(surl) || '&msg=' || '"'); end if;
   if substr(theme_rec.theme_data,78,1)  = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG.PHG_TXT_470, cattributes=>'VALUE="pbk.main?surl=' || glbx.rndsurl(surl) || '&msg=' || '"'); end if;
   if substr(theme_rec.theme_data,24,1)  = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG5.EXT_TXT_547, cattributes=>'VALUE="pfm.purchrep?surl=' || glbx.rndsurl(surl) || '&msg=' || '"'); end if;
   if substr(theme_rec.theme_data,36,1)  = 'T' then tmp2 := tmp2 || htf.formselectoption('Advanced Image Report', cattributes=>'VALUE="pfm.imgrep?surl=' || glbx.rndsurl(surl) || '&msg=' || '"'); end if;
   if substr(theme_rec.theme_data,430,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG.PHG_ALT_432, cattributes=>'VALUE="oltp.view_report?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,118,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(replace(LNG2.PBK_TXT_079,'<PHOTOGRAPHER>',c1rec.photographer_title), cattributes=>'VALUE="phg.phg_personal?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,139,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG2.FNM_TXT_058, cattributes=>'VALUE="pbk.mng_warranty?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,140,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG2.FNM_TXT_052, cattributes=>'VALUE="pbk.mng_clearance?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,169,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG4.AHC_TXT_027, cattributes=>'VALUE="pbk.tender_list?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,171,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG4.AHC_TXT_038, cattributes=>'VALUE="pbk.reverse_list?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,48,1)  = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG5.EXT_TXT_656, cattributes=>'VALUE="pfm.manage_portlets?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,387,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG4.AHC_TXT_610, cattributes=>'VALUE="pbk.mng_workflow?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,388,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG4.AHC_TXT_628, cattributes=>'VALUE="pbk.mng_simple_rfq?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,409,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG5.CAL_TXT_001, cattributes=>'VALUE="cal.update_calendar?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,77,1)  = 'T' then tmp2 := tmp2 || htf.formselectoption(replace(LNG.CST_TXT_220,'<PHOTOGRAPHER>',c1rec.photographer_title), cattributes=>'VALUE="phg.manage_gallery?surl=' || glbx.rndsurl(surl) || '&acid=&msg=' || '"'); end if;
   if substr(theme_rec.theme_data,158,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG2.FNM_TXT_151, cattributes=>'VALUE="pbk.addr?surl=' || glbx.rndsurl(surl) || '&msg=' || '"'); end if;
   if substr(theme_rec.theme_data,177,1) = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG4.AHC_TXT_275, cattributes=>'VALUE="pbk.contactus?surl=' || glbx.rndsurl(surl) || '&msg=' || '"'); end if;
   if (substr(theme_rec.theme_data,120,1)= 'T') and (c1rec.forum_enabled = 'T') then tmp2 := tmp2 || htf.formselectoption(LNG.PHG_TXT_437, cattributes=>'VALUE="forum.display_forum?surl=' || glbx.rndsurl(surl) || '"'); end if;
   if substr(theme_rec.theme_data,74,1)  = 'T' then tmp2 := tmp2 || htf.formselectoption(LNG.PHG_TXT_448, cattributes=>'VALUE="phg.readme?surl=' || glbx.rndsurl(surl) || '"'); end if;
   tmp2 := tmp2 || htf.formselectclose;
   tmp2 := tmp2 || htf.formclose;
   tmp2 := tmp2 || '</TD>';
 end if;

  htp.htmlopen;
   if pfx.top_frame_background is null
    then
     htp.p('<BODY BGCOLOR="#' || pfx.text_back ||  '" TOPMARGIN="' || pfx.top_padding || '" LEFTMARGIN="' || pfx.left_padding || '">');
    else
     htp.p('<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || 'skin/' || pfx.top_frame_background ||  '" TOPMARGIN="' || pfx.top_padding || '" LEFTMARGIN="' || pfx.left_padding || '">');
   end if;
  htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0' );
  htp.tablerowopen;
   htp.tabledata('<b><font size="+1" color="#' || pfx.text_colour || '" face="' || pfx.text_font || '">' || c1rec.business_name ||'</font></b>',cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( adv.display_advert(surl,owner_id,c1rec.theme_type,ltype,'TOP' ) ,cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.tableopen( cattributes=> 'cellpadding=0 cellspacing=' || nvl(pfx.SF_BG_CELLSPC,2) || ' border=0' ) || htf.tablerowopen || tmp || tmp2 || htf.tablerowclose || htf.tableclose, cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="RIGHT" ' );
  htp.tablerowclose;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_HEADER',owner_id,errmsg=>sqlerrm);
end phg_header;

procedure phg_accts(surl in varchar2, rnd in integer default 1234, delall in varchar2 default 'F', search_range in varchar2 default '0Z', msg in varchar2 default null)
as
 cursor c1(phgid integer, search_range in varchar2) is
  select aid,account_name,username,date_expires
  from customer_account
  where pid = phgid and
        aid > 0 and
        upper(substr(account_name,1,1)) >= substr(search_range,1,1) and
        upper(substr(account_name,1,1)) <= substr(search_range,2,1)
  order by upper(account_name);

 -- Note: For performance, index deliverately negated to improve query time
 cursor c1a(phgid integer, search_range in varchar2) is
  select ca.aid,ca.account_name,ca.username,ca.date_expires, count('x') tot
  from umo um,customer_account ca
  where ca.pid = phgid and
        nvl(um.aid,0) = ca.aid and
        ca.aid > 0 and
        um.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
        upper(substr(ca.account_name,1,1)) >= substr(search_range,1,1) and
        upper(substr(ca.account_name,1,1)) <= substr(search_range,2,1)
  group by ca.aid,ca.account_name,ca.username,ca.date_expires
 union all
  select ca.aid,ca.account_name,ca.username,ca.date_expires, 0 tot
  from customer_account ca
  where ca.pid = phgid and
        not exists (select 'x' from umo um where um.aid = ca.aid and um.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT')) and
        ca.aid > 0 and
        upper(substr(ca.account_name,1,1)) >= substr(search_range,1,1) and
        upper(substr(ca.account_name,1,1)) <= substr(search_range,2,1)
  order by 2;

 -- Note: For performance, index deliverately negated to improve query time
 cursor c1b(phgid integer, search_range in varchar2) is
  select ca.aid,ca.account_name,ca.username,ca.date_expires
  from customer_account ca
  where ca.pid = phgid and
        ca.aid > 0 and
        upper(substr(ca.account_name,1,1)) >= substr(search_range,1,1) and
        upper(substr(ca.account_name,1,1)) <= substr(search_range,2,1)
  order by ca.account_name;

 cursor c2(phgid integer) is select cp.max_accounts, ph.skill_level, cp.payment_style from charge_plan cp, photographer ph where cp.id = ph.plan_id and ph.pid = phgid;
 cursor c3(phgid integer) is select count('x') from customer_account where pid = phgid;
 cursor c4(phgid integer) is select aid,account_name,date_expires from customer_account where (pid = phgid) and (aid < 0) and (sysdate > nvl(date_to_delete,sysdate+1));
 cursor c6(phgid integer) is select aid,account_name,date_to_delete from customer_account where (pid = phgid) and (aid < 0) and (sysdate <= nvl(date_to_delete,sysdate+1));

 cursor c7(acid integer ) is
  select sum(t1) t1, sum(t2) t2, sum(t3) t3, sum(t4) t4
  from
  (
  select sum(decode(po.status,'Ordered',1,0)) t1, sum(decode(po.status,'Order Authorised',1,0)) t2, sum(decode(po.status,'Order Payment Received',1,0)) t3, sum(decode(po.status,'Processing',1,0)) t4
  from login_session ls, purchase_order po, customer_account ca
  where po.status in ('Ordered','Order Authorised','Order Payment Received','Processing') and
        ca.aid = acid and
        po.sessid = ls.sessid and
        ls.aid = ca.pid and
        ls.login_type = 'PHOTOGRAPHER'
 union all
  select sum(decode(po.status,'Ordered',1,0)) t1, sum(decode(po.status,'Order Authorised',1,0)) t2, sum(decode(po.status,'Order Payment Received',1,0)) t3, sum(decode(po.status,'Processing',1,0)) t4
  from login_session ls, purchase_order po, customer_account ca
  where po.status in ('Ordered','Order Authorised','Order Payment Received','Processing') and
        ca.aid = acid and
        po.sessid = ls.sessid and
        ls.aid = ca.aid and
        ls.login_type in ('CUSTOMER','OWNER')
 union all
  select sum(decode(po.status,'Ordered',1,0)) t1, sum(decode(po.status,'Order Authorised',1,0)) t2, sum(decode(po.status,'Order Payment Received',1,0)) t3, sum(decode(po.status,'Processing',1,0)) t4
  from login_session ls, purchase_order po, customer_account ca, customer_profile cp
  where po.status in ('Ordered','Order Authorised','Order Payment Received','Processing') and
        ca.aid = acid and
        po.sessid = ls.sessid and
        ls.aid = cp.profile_id and
        cp.aid = ca.aid and
        ls.login_type in ('PROFILE','PROFILEG')
 );

 cursor c8(phgid integer) is select * from theme_types where theme_type in (select theme_type from photographer where pid = phgid );
 cursor c9(void integer) is select name,spb from order_style where oid = void;
 cursor c9a(vspb integer) is select name from phg_price_book where spb = vspb;

 c7rec		c7%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c9arec		c9a%ROWTYPE;
 pfx		theme%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 foundrec	boolean;
 owner_id	integer;
 sts		varchar2(100);
 tot		integer;
 totc		integer;
 ctr		integer;
 void		integer;
 dsp 		boolean;
 b2c_value	char(1);
 skill_level	varchar2(30);
 theme_rec	theme_types%ROWTYPE;
 cplan		charge_plan.payment_style%TYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_ACCTS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 ctr := 1;
 pfx := glbx.photo_lf(owner_id);
 open c2(owner_id);
 fetch c2 into tot,skill_level,cplan;
 close c2;
 open c3(owner_id);
 fetch c3 into totc;
 close c3;
 tot := nvl(tot,30);
 skill_level := nvl(skill_level,LNG2.PBK_TXT_080);
 open c8(owner_id);
 fetch c8 into theme_rec;
 close c8;
 totc := nvl(totc,30);
 glbx.main_title( surl, LNG.PHG_ALT_380,glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 if msg is not null then glbx.header_msg( msg ); end if;
 if skill_level in ( LNG2.PBK_TXT_081,LNG2.PBK_TXT_082 )
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=AC','[A-C]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=DF','[D-F]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=GI','[G-I]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=JL','[J-L]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=MO','[M-O]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=PS','[P-S]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=TV','[T-V]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=WZ','[W-Z]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=09','[0-9]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&delall=' || delall || '&search_range=0Z','[ALL]' ),cattributes=>' valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
 end if;
 if skill_level in ( LNG2.PBK_TXT_080 )
  then
   htp.tableopen( cattributes=>'cellpadding=5 cellspacing=5 border=0' );
   htp.tablerowopen;
   if totc < tot
    then
     htp.tabledata( htf.anchor('phg.phg_create_new_acct?surl=' || glbx.rndsurl(surl),htf.img( DECS.IMAGE_LOCATION || 'admin/new_acct.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_074 )) ||
                    htf.nl || htf.anchor('phg.phg_create_new_acct?surl=' || glbx.rndsurl(surl),LNG.GLB_TXT_074),cattributes=>pfx.qcbground || ' align="CENTER" valign="TOP"' );
    else
     htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/new_acct.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_003 || tot || LNG.PHG_ALT_380 ) ||
                    htf.nl || LNG.PHG_TXT_005 || tot,cattributes=>pfx.qcbground || ' align="CENTER" valign="TOP"' );
   end if;
   for c1rec in c1( owner_id, search_range ) loop
    if mod( ctr, glbx.sctrl(pfx.theme_name,'GALLERY_HORIZONTAL',stype) + 4 ) = 0
     then
      htp.tablerowclose;
      htp.tablerowopen;
    end if;
    ctr := ctr + 1;
    htp.tabledata( htf.anchor('phg.phg_acct_master?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid,htf.img( DECS.IMAGE_LOCATION || 'admin/big_acct.gif',cattributes=>'border=0',calt=>c1rec.username )) ||
                   htf.nl || htf.anchor('phg.phg_acct_master?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid,c1rec.account_name) || htf.nl ||
                   to_char(c1rec.date_expires,LNG.MASK),cattributes=>pfx.qcbground || ' align="CENTER" valign="TOP"' );
   end loop;
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   if substr( theme_rec.theme_data,374,1) = 'T' and cplan = 'EVENT'
    then
     htp.nl;
     htp.anchor('pbk.increase_event_plan?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_557);
     htp.nl;
   end if;

 else

   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_164 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG.GLB_TXT_076 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG5.EXT_TXT_145 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG.PHG_TXT_470 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG.CST_TXT_033 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
     if substr( theme_rec.theme_data,47,1) = 'T'
      then
       htp.tabledata( LNG2.PFM_TXT_102,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
       htp.tabledata( LNG.PHG_TXT_079 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
     end if;
    htp.tablerowclose;

    if substr( theme_rec.theme_data,47,1) = 'T'
     then

      for c1arec in c1a( owner_id, search_range ) loop
       htp.tablerowopen;
        htp.tabledata( htf.anchor('phg.phg_acct_master?surl=' || glbx.rndsurl(surl) || '&acid=' || c1arec.aid,c1arec.account_name),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        htp.tabledata( c1arec.username,cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        c9rec.name := NULL;
        void := glbx.get_order_style(c1arec.aid, null, ltype, b2c_value);
        open c9(void);
        fetch c9 into c9rec;
        close c9;
        open c9a(c9rec.spb);
        fetch c9a into c9arec;
        close c9a;
        if c9rec.name is null
         then
          htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.anchor('fname.master?surl=' || surl || '&void=' || void, c9rec.name),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        end if;
        if c9arec.name is null
          then
           htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
          else
           htp.tabledata( htf.anchor('pbk.edit_item?surl=' || surl || '&id=' || c9rec.spb, c9arec.name),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( nvl(to_char(c1arec.date_expires,LNG.MASK),'&nbsp;'),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="CENTER"' );
        htp.tabledata( to_char(nvl(c1arec.tot,0)),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="RIGHT"' );
        c7rec.t1 := 0;
        c7rec.t2 := 0;
        c7rec.t3 := 0;
        c7rec.t4 := 0;
        open c7(c1arec.aid);
        fetch c7 into c7rec;
        close c7;
        dsp := FALSE;
        htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" align="RIGHT" >' );
         if c7rec.t1 > 0
          then
           --htp.anchor( 'ord.phg_acct_orders?surl=' || surl || '&acid=' || c1arec.aid || '&TYP=NEW','[' || 'Ordered' || '-' || c7rec.t1 || ']', cattributes=>'style="font-size: smaller;"' );
           htp.anchor( 'ord.phg_acct_orders?surl=' || surl || '&acid=' || c1arec.aid || '&TYP=NEW&tm=D','[' || 'Ordered' || '-' || c7rec.t1 || ']', cattributes=>'style="font-size: smaller;"' );
           htp.nl;
           dsp := TRUE;
         end if;
         if c7rec.t2 > 0
          then
           htp.anchor( 'ord.phg_acct_orders?surl=' || surl || '&acid=' || c1arec.aid || '&TYP=NEW&tm=D','[' || 'Order Authorised' || '-' || c7rec.t2 || ']', cattributes=>'style="font-size: smaller;"' );
           htp.nl;
           dsp := TRUE;
         end if;
         if c7rec.t3 > 0
          then
           htp.anchor( 'ord.phg_acct_orders?surl=' || surl || '&acid=' || c1arec.aid || '&TYP=NEW&tm=D','[' || 'Order Payment Received' || '-' || c7rec.t3 || ']', cattributes=>'style="font-size: smaller;"' );
           htp.nl;
           dsp := TRUE;
         end if;
         if c7rec.t4 > 0
          then
           htp.anchor( 'ord.phg_acct_orders?surl=' || surl || '&acid=' || c1arec.aid || '&TYP=ACTIVE&tm=D','[' || 'Processing' || '-' || c7rec.t4 || ']', cattributes=>'style="font-size: smaller;"' );
           htp.nl;
           dsp := TRUE;
         end if;
         if not dsp then htp.p( '&nbsp;' ); end if;
        htp.p( '</TD>' );
       htp.tablerowclose;
      end loop;

     else

      for c1brec in c1b( owner_id, search_range ) loop
       htp.tablerowopen;
        htp.tabledata( htf.anchor('phg.phg_acct_master?surl=' || glbx.rndsurl(surl) || '&acid=' || c1brec.aid,c1brec.account_name),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        htp.tabledata( c1brec.username,cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        c9rec.name := NULL;
        void := glbx.get_order_style(c1brec.aid, null, ltype, b2c_value);
        open c9(void);
        fetch c9 into c9rec;
        close c9;
        open c9a(c9rec.spb);
        fetch c9a into c9arec;
        close c9a;
        if c9rec.name is null
         then
          htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
         else
          htp.tabledata( htf.anchor('fname.master?surl=' || surl || '&void=' || void, c9rec.name),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        end if;
        if c9arec.name is null
          then
           htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
          else
           htp.tabledata( htf.anchor('pbk.edit_item?surl=' || surl || '&id=' || c9rec.spb, c9arec.name),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        end if;
        htp.tabledata( nvl(to_char(c1brec.date_expires,LNG.MASK),'&nbsp;'),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="CENTER"' );
       htp.tablerowclose;
      end loop;

     end if;

     htp.tablerowopen;
      htp.tabledata( htf.anchor('phg.phg_statall?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_117),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      if substr( theme_rec.theme_data,47,1) = 'T'
       then
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      end if;
     htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.anchor('phg.phg_create_new_acct?surl=' || glbx.rndsurl(surl),LNG.GLB_TXT_074);
   if substr( theme_rec.theme_data,374,1) = 'T' and cplan = 'EVENT'
    then
     htp.p( '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' );
     htp.anchor('pbk.increase_event_plan?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_557);
   end if;
   htp.nl;
   htp.nl;
 end if;

 if delall = 'T'
  then
   update customer_account
    set date_to_delete = sysdate - 100
     where pid = owner_id and
           aid < 0;
   commit;
 end if;

 for c4rec in c4( owner_id ) loop
   completely_delete_account(owner_id,c4rec.aid,'DELETE');
   htp.bold( LNG2.PBK_TXT_129 || ':' || c4rec.account_name ); htp.nl;
 end loop;

 htp.nl;
 htp.line;
 htp.nl;
 ctr := 0;
  htp.tableopen( cattributes=>'cellpadding=5 cellspacing=5 border=0' );
  htp.tablerowopen;
  foundrec := FALSE;
  for c6rec in c6( owner_id ) loop
   foundrec := TRUE;
   if mod( ctr, glbx.sctrl(pfx.theme_name,'GALLERY_HORIZONTAL',stype) + 4 ) = 0
    then
     htp.tablerowclose;
     htp.tablerowopen;
   end if;
   ctr := ctr + 1;
   htp.tabledata( htf.anchor('phg.phg_restore?surl=' || glbx.rndsurl(surl) || '&acid=' || c6rec.aid,htf.img( DECS.IMAGE_LOCATION || 'admin/big_acct.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_121 )) ||
                   htf.nl || htf.anchor('phg.phg_restore?surl=' || glbx.rndsurl(surl) || '&acid=' || c6rec.aid,c6rec.account_name) || htf.nl ||
                   to_char(c6rec.date_to_delete,LNG.MASK),cattributes=>' align="CENTER" valign="TOP"' );
  end loop;
  htp.tablerowclose;
  htp.tableclose;
  if foundrec
   then
    htp.nl;
    htp.bold( LNG2.PBK_TXT_130 );
    htp.nl;
    htp.nl;
    htp.anchor( 'phg.phg_accts?surl=' || glbx.rndsurl(surl) || '&delall=T', LNG2.PFM_TXT_076 );
    htp.nl;
  end if;

 htp.p( '</CENTER>' );
 glbx.close_page(pfx);

exception when others then
 glbx.error_details( 'PHG', 'PHG_ACCTS',owner_id,errmsg=>sqlerrm);
end phg_accts;

procedure phg_restore( surl in varchar2, acid in integer )
as
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(200);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_RESTORE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 completely_delete_account(owner_id,acid,'ENABLE');
 phg.phg_accts(surl,to_char(sysdate,'SSSSS'));
exception when others then
 glbx.error_details( 'PHG', 'PHG_RESTORE',owner_id,errmsg=>sqlerrm);
end phg_restore;

function p_title( phgid in integer )
 return varchar2
as
 cursor c1(phgid integer) is select photographer_title from photographer where pid = phgid;
 c1rec	c1%ROWTYPE;
begin
 open c1(phgid);
 fetch c1 into c1rec;
 close c1;
 return( c1rec.photographer_title );
end p_title;

procedure phg_acct_master( surl in varchar2, acid in integer, msg in varchar2 default null, profid in integer default null )
as

 cursor c1(acid integer, owner_id integer) is select theme_name from customer_account where aid = acid and pid = owner_id;

 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(200);
 owner_id	integer;
 pfx		THEME%ROWTYPE;
 theme_name	CUSTOMER_ACCOUNT.THEME_NAME%TYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_ACCT_MASTER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 open c1(acid,owner_id);
 fetch c1 into theme_name;
 close c1;
 pfx := glbx.get_thm( theme_name );
  htp.htmlopen;
  htp.p( '<HEAD>' || pfx.icra_label || htf.title( p_title( owner_id ) ) || '</HEAD>' );
  htp.framesetopen('100%',glbx.sctrl(pfx.theme_name,'CST_INNER_FRAME_SIZE',stype),cattributes=>'frameborder="' || pfx.frame_border || '" framespacing="0" border="' || pfx.frame_border || '"');
   htp.frame( 'phg.phg_acct_left?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&expanded_scenes=','PHG_LEFT');
   if msg is null
    then
     if profid is null
      then
       htp.frame( 'phg.phg_home?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'PHG_RIGHT');
      else
       htp.frame( 'phg.phg_acct_details?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&profid=' || profid,'PHG_RIGHT');
     end if;
    else
     if profid is null
      then
       htp.frame( 'phg.phg_acct_msg?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=' || translate(msg,' ','+'),'PHG_RIGHT');
      else
       htp.frame( 'phg.phg_acct_details?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&profid=' || profid,'PHG_RIGHT');
     end if;
   end if;
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'PHG.PHG_ACCT_MASTER');
  htp.noframesclose;
  glbx.close_page(pfx);
exception when others then
 glbx.error_details( 'PHG', 'PHG_ACCT_MASTER',vaid=>acid,errmsg=>sqlerrm);
end phg_acct_master;

procedure disp_err( surl in varchar2, errcode in varchar2, acid in integer, msg in varchar2, profid in integer default null )
as
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(200);
 owner_id	integer;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.DISP_ERR', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 if acid = 0
   then
    phg_create_new_acct(surl,msg);
    return;
  end if;
  if errcode = 'PHGUPD'
   then
    phg_acct_details(surl,acid,msg,profid);
   else
    htp.htmlopen;
    htp.p( '<HEAD>' );
    htp.title( p_title( owner_id ) );
    htp.p( '</HEAD>' );
    htp.framesetopen('100%',glbx.sctrl(glbx.fndtheme( owner_id, acid ),'CST_INNER_FRAME_SIZE',stype),cattributes=>'frameborder="1" framespacing="0" border="1"');
    if errcode = 'PHGUPD'
     then
      htp.frame( 'phg.phg_acct_left?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&expanded_scenes=','PHG_LEFT');
      htp.frame( 'phg.phg_acct_details?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=' || translate(msg,' ','+') || '&profid=' || profid,'PHG_RIGHT');
    end if;
   htp.framesetclose;
    htp.p( '<BODY>' );
   htp.noframesopen;
   glbx.noframe(surl,'PHG.DISP_ERR');
   htp.noframesclose;
  end if;
  htp.p( '</BODY>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'DISP_ERR',vaid=>acid,errmsg=>sqlerrm,extdet=>errcode);
end disp_err;

procedure phg_acct_msg( surl in varchar2,acid in integer, msg in varchar2 )
as
begin
 htp.htmlopen;
  htp.header(3, msg );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_ACCT_MSG',vaid=>acid,errmsg=>sqlerrm,extdet=>msg);
end phg_acct_msg;

procedure phg_accept_preferences( surl in varchar2,acid in integer, p0 in myarray, p1 in myarray )
as
 cursor c1( preference_id integer ) is
  select preference_type, preference_name, default_value
  from all_preferences
  where prefid=preference_id;
 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(4000);
 err		varchar2(4000);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_ACCEPT_PREFERENCES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 err := NULL;
 if not p0.exists(1) then phg_prefs_txt(surl,acid); return; end if;
 for j in p0.first..p0.last loop
  open c1( p0(j) );
  fetch c1 into c1rec;
  close c1;
  if c1rec.preference_type='VARCHAR4000'
   then
    tmp := substr(p1(j),1,4000);
    --tmp := translate(tmp,'<>','[]');
  elsif c1rec.preference_type='INTEGER'
   then
    begin
	 tmp := to_char(trunc(to_number( p1(j) )));
	exception
	 when others then tmp := c1rec.default_value; err := err || LNG.PHG_TXT_007 || p1(j) || LNG.PHG_TXT_008 || htf.nl;
	end;
  elsif c1rec.preference_type='MONEY'
   then
         begin
	 tmp := to_char(glbx.conv_nmb(p1(j)),LNG.MONEY_FORMAT);
	exception
	 when others then tmp := c1rec.default_value; err := err || LNG.PHG_TXT_007 || p1(j) || LNG.PHG_TXT_008 || htf.nl;
	end;
  elsif c1rec.preference_type='PERCENTAGE'
   then
    begin
     tmp := to_char(round(to_number( p1(j)), 2));
    exception
      when others then tmp := c1rec.default_value; err := err || LNG.PHG_TXT_007 || p1(j) || LNG.PHG_TXT_008 || htf.nl;
    end;
    if to_number(tmp) < 0 or to_number(tmp) > 100 then tmp := c1rec.default_value; err := err || LNG.PHG_TXT_007 || p1(j) || ' (0-100) ' || LNG.PHG_TXT_008 || htf.nl; end if;
  elsif p0(j) = 32
   then
    tmp := p1(j);
  else
   tmp := p1(j);
  end if;

  update photographer_preference
   set value = tmp
   where prefid = p0(j) and
         aid = acid and
         pid = owner_id;

 /* Redundant with Order Styles
  if (p0(j) = 32) and (acid > 0)
   then
    update customer_price_book
     set spb = tmp
    where aid = acid and
          pid = owner_id;
   end if;
 */

 end loop;
 commit;
 if err is null then err := LNG.PHG_TXT_009 || htf.nl; end if;
 phg_prefs_txt( surl,acid, err );
exception when others then
 glbx.error_details( 'PHG', 'PHG_ACCEPT_PREFERENCES',owner_id,acid,errmsg=>sqlerrm);
end phg_accept_preferences;

procedure phg_prefs( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c1(owner_id integer) is select skill_level,photographer_title from photographer where pid = owner_id;
 cursor c6( acid integer ) is
  select order_by,display_name,call_type,program_name,first_parameter, nd.novelty_id, display_suffix
  from  novelty_definition nd, novelty_set ns, charge_plan cp, photographer p, customer_account ca
  where substr(where_called,3,1) = 'T' and
        nd.novelty_id = ns.novelty_id and
        ns.novelty_set_id = cp.novelty_set_id and
        cp.id = p.plan_id and
        p.pid = ca.pid and
        ca.aid = acid and
        0 in (select count('x') tot from novelty_customer where aid = acid)
 union
  select order_by,display_name,call_type,program_name,first_parameter, nd.novelty_id, display_suffix
  from  novelty_definition nd, customer_account ca, novelty_customer nc
  where substr(where_called,3,1) = 'T' and
        nd.novelty_id = nc.novelty_id and
        ca.aid = acid and
        nc.aid = ca.aid
  order by 1;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 url		varchar2(1000);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PREFS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_010,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 theme_rec := get_theme_types( surl, acid );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p('<CENTER>');
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
 if substr(theme_rec.theme_data,2,1) = 'T' then
  htp.tablerowopen;
   htp.tabledata(htf.anchor('phg.phg_prefs_txt?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_txt.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_112 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.anchor('phg.phg_prefs_txt?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG2.FNM_TXT_112 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
 end if;
 if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
  then
   if substr(theme_rec.theme_data,174,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('pbk.home_page_option?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/option.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_227 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('pbk.home_page_option?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG4.AHC_TXT_227 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
 end if;

 -- Order Style Mapping
 if substr(theme_rec.theme_data,3,1) = 'T'
  then
  htp.tablerowopen;
   htp.tabledata(htf.anchor('phg.phg_prefs_phz?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_phz.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_145 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
   htp.tabledata(htf.anchor('phg.phg_prefs_phz?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG5.EXT_TXT_145 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
 end if;

 -- Sanity Check
 if substr(theme_rec.theme_data,35,1) = 'T'
  then
  htp.tablerowopen;
   htp.tabledata(htf.anchor('phg.sanity?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/sanity.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_642 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
   htp.tabledata(htf.anchor('phg.sanity?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG5.EXT_TXT_642 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
 end if;

 if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
  then
   if substr(theme_rec.theme_data,6,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.phg_prefs_img_icon?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&IMGTYPE=ICON',htf.img( DECS.IMAGE_LOCATION || 'admin/pref_log.gif',cattributes=>'border=0',calt=>replace(LNG.PHG_TXT_014,'<PHOTOGRAPHER>',c1rec.photographer_title) )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.phg_prefs_img_icon?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&IMGTYPE=ICON','<b><font size="+1">' || replace(LNG.PHG_TXT_014,'<PHOTOGRAPHER>',c1rec.photographer_title) || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,7,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.phg_prefs_img?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&IMGTYPE=BACKGROUND',htf.img( DECS.IMAGE_LOCATION || 'admin/bac2_log.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_015 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.phg_prefs_img?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&IMGTYPE=BACKGROUND','<b><font size="+1">' || LNG.PHG_TXT_015 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,51,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.phg_prefs_img_wm?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&IMGTYPE=WATERMARK',htf.img( DECS.IMAGE_LOCATION || 'admin/watermark.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_363 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.phg_prefs_img_wm?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&IMGTYPE=WATERMARK','<b><font size="+1">' || LNG.PHG_TXT_364 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
 end if;
 if substr(theme_rec.theme_data,128,1) = 'T' then
  htp.tablerowopen;
   htp.tabledata(htf.anchor('cst.acct_details?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || 'admin/pref_acct.gif',cattributes=>'border=0',calt=>LNG.CST_TXT_236 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.anchor('cst.acct_details?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, '<b><font size="+1">' || LNG.CST_TXT_236 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
 end if;
 if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
  then
   if substr(theme_rec.theme_data,137,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('cst.cust_contact?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&profid=',htf.img( DECS.IMAGE_LOCATION || 'admin/contact.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_103 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('cst.cust_contact?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&profid=','<b><font size="+1">' || LNG2.PFM_TXT_103 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
 end if;

 if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
  then
   if substr(theme_rec.theme_data,159,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.cust_roles?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/roles.gif',cattributes=>'border=0',calt=>LNG3.ADM_TXT_913 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.cust_roles?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG3.ADM_TXT_913 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
 end if;

 if substr(theme_rec.theme_data,375,1) = 'T' then
  htp.tablerowopen;
   htp.tabledata(htf.anchor('pbk.mng_usr_event?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_eve.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_580 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.anchor('pbk.mng_usr_event?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG4.AHC_TXT_580 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
 end if;
 if c1rec.skill_level = LNG2.PBK_TXT_082
  then
   if substr(theme_rec.theme_data,397,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('pbk.mng_regsiter?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_register.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_729 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('pbk.mng_register?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG4.AHC_TXT_729|| '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
 end if;
 if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
  then
   if substr(theme_rec.theme_data,410,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('cal.mng_calendar?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&profid=',htf.img( DECS.IMAGE_LOCATION || 'admin/calendar.gif',cattributes=>'border=0',calt=>LNG2.PFM_TXT_103 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('cal.mng_calendar?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&profid=','<b><font size="+1">' || LNG4.AHC_TXT_969 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,80,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('pbk.mng_profiles?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_profile.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_089 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('pbk.mng_profiles?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_089 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,372,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('pbk.gcertificate?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/gift.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_520 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('pbk.gcertificate?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG4.AHC_TXT_520 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,373,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('pbk.meta_screen?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/meta.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_235 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('pbk.meta_screen?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG5.EXT_TXT_235 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   -- xxx for language file
   if substr(theme_rec.theme_data,39,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.toggle_meta?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/toggle.gif',cattributes=>'border=0',calt=>'Configure Metadata Image Toggle' )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.toggle_meta?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || 'Configure Metadata Image Toggle' || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,66,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.eml_temp?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/eml.gif',cattributes=>'border=0',calt=>'Email Template' )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.eml_temp?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || 'Email Template' || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,72,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.gcard_access?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/gcard.gif',cattributes=>'border=0',calt=>'Greeting Card Access' )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.gcard_access?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || 'Greeting Card Access' || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,71,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.novelty_access?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/novelty.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_393 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.novelty_access?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG5.EXT_TXT_393 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end if;
 end if;

 -- Display Novelties
 if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
  then
   for c6rec in c6( acid ) loop
    url := c6rec.program_name || '?surl=' || surl || '&footer_api=' || null || '&left_api_parm=' || null || '&current_page_number=' || '1' || '&display_detail=' || null || '&acid=' || acid || '&called_from=' || 'PREFERENCES' || '&first_parameter=' || replace(c6rec.first_parameter,' ','+') || '&loc_id=' || '&nvid=' || c6rec.novelty_id;
    if pfx.fullimg_jscript_popup = 'T'
     then
       url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_301 || to_char(c6%ROWCOUNT),' ','_') ||
              ''',''height=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + pfx.fullimg_popup_height) ||
              ',width=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + 100 + pfx.fullimg_popup_width) || ',scrollbars=yes,resizable=yes'');void('''');';
    end if;
    htp.tablerowopen;
     --htp.tabledata(htf.anchor(url,htf.img( DECS.IMAGE_LOCATION || 'adminc/' || c6rec.display_suffix,cattributes=>'border=0',calt=>c6rec.display_name )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor(url,'<b><font size="+1">' || c6rec.display_name || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   end loop;
 end if;
 htp.tableclose;
 htp.p('</CENTER>');
 htp.nl;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PREFS',owner_id,acid,errmsg=>sqlerrm,extdet=>msg);
end phg_prefs;

procedure phg_prefs_img( surl in varchar2, acid in integer, imgtype in varchar2, msg in varchar2 default null )
as

 cursor c1(acid integer, phgr integer, imgtype varchar2) is
   select um.photo_master, um.umo_id, um.version
   from umo um, customer_account ca
   where um.aid = acid and
         um.aid = ca.aid and
         ca.pid = phgr and
         umo_type = imgtype;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 foundrec	boolean;
 width		integer;
 height		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PREFS_IMG', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_017,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 open c1( acid, owner_id, imgtype );
 fetch c1 into c1rec;
 foundrec := c1%FOUND;
 close c1;

 if msg is not null then glbx.header_msg( msg ); end if;
 htp.italic( LNG.PHG_TXT_018 ); htp.nl;
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.lload', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'IMGTYPE', imgtype );
 htp.formhidden( 'P4', null );
 htp.formhidden( 'P5', null );
 htp.formhidden( 'P6', null );
 htp.formhidden( 'P7', null );
 htp.formhidden( 'P8', null );

 htp.tableopen;
  htp.tablerowopen;
   if foundrec
    then
	 htp.tabledata( '<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
           '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid) || '" ' ||
           'ALT="' || imgtype || '" STYLE="display:block;">' );
    else
	 htp.tabledata( htf.bold(LNG.PHG_TXT_019),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   end if;
 htp.tablerowclose;
 htp.tablerowopen;
   htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>pfx.qcbground );
 htp.tablerowclose;
 htp.tableclose;

 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );

 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );
 htp.formhidden( 'P3', null );

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_024),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(htf.bold(c1rec.photo_master.mimetype),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_025),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( nvl(htf.bold(c1rec.photo_master.contentlength),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.formhidden( 'V_UMO', c1rec.umo_id ) || htf.formsubmit( null, LNG.PHG_TXT_026 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'phg.phg_prefs' ) || htf.formhidden( 'SURL', surl ) ||htf.formhidden( 'ACID', acid ) || htf.formhidden( 'MSG', LNG.PHG_TXT_027 ) ||
                  htf.formsubmit( null, LNG.PHG_TXT_028 ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 if foundrec
  then
   htp.formopen( 'phg.delete_logo' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'IMGTYPE',imgtype );
   htp.formhidden( 'V_UMO', c1rec.umo_id );
   if imgtype = 'BACKGROUND'
    then
     htp.bold( LNG4.AHC_TXT_956 ); htp.nl;
     htp.formsubmit( null, LNG.PHG_BUT_117 );
    else
     htp.bold( LNG.PHG_TXT_330 ); htp.nl;
     htp.formsubmit( null, LNG.PHG_BUT_339 );
   end if;
   htp.formclose;
 end if;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PREFS_IMG',owner_id,acid,errmsg=>sqlerrm,extdet=>'IMGTYPE:' || imgtype || ' MSG:' || msg);
end phg_prefs_img;

procedure phg_prefs_img_icon( surl in varchar2, acid in integer, imgtype in varchar2, msg in varchar2 default null )
as

 cursor c1(acid integer, phgr integer, imgtype varchar2) is
   select um.photo_master, um.umo_id, um.version, um.is_global, um.extras.orderby_nmb orderby_nmb, um.attribute1 access_stats, um.attribute2 check_basket
   from umo um, customer_account ca
   where um.aid = acid and
         um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'F' and
         umo_type = imgtype
  union all
   select um.photo_master, um.umo_id, um.version,um.is_global, um.extras.orderby_nmb orderby_nmb, um.attribute1 access_stats, um.attribute2 check_basket
   from umo um, customer_account ca
   where um.aid in (select aid from customer_account where pid = phgr) and
         um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'T' and
         umo_type = imgtype
  order by 4,5;

 cursor c2(v_umo integer, phgid integer, acid integer) is select count('x') tot from photographer_icon_stats where umo_id = v_umo and pid = phgid and aid = acid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 http		varchar2(100);
 foundrec	boolean;
 width		integer;
 height		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PREFS_IMG', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, replace(LNG2.FNM_TXT_148,'<PHOTOGRAPHER>', p_title(owner_id)), glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

 if msg is not null then glbx.header_msg( msg ); else glbx.header_msg( LNG.PHG_TXT_018 ); end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( LNG.PHG_TXT_020, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG.PHG_TXT_021, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG.PHG_TXT_236, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG3.ADM_TXT_429, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG.PHG_TXT_024, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG.PHG_TXT_025, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG3.ADM_TXT_173, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG2.PFM_TXT_160, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG5.EXT_TXT_131, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG5.EXT_TXT_132, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( LNG5.EXT_TXT_133, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tableheader( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
  htp.tablerowclose;

  htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.lload', cattributes=>'enctype="multipart/form-data"' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'IMGTYPE', imgtype );

  foundrec := FALSE;
  for c1rec in c1( acid, owner_id, imgtype ) loop
   foundrec := TRUE;
   width := to_number(ump.uma_attribute( surl, c1rec.umo_id, imgtype, 'DISPLAY_WIDTH' ));
   height := to_number(ump.uma_attribute( surl, c1rec.umo_id, imgtype, 'DISPLAY_HEIGHT' ));
   http := ump.uma_attribute( surl, c1rec.umo_id, imgtype, 'HTTP_LINK' );
   htp.tablerowopen;
    htp.tabledata( htf.formtext('P1',10, 20, height),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext('P2',10, 20, width),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext('P3',20, 100, http),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext('P6',4, 10, c1rec.orderby_nmb),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( nvl(htf.bold(c1rec.photo_master.mimetype),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( nvl(htf.bold(c1rec.photo_master.contentlength),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
	 htp.tabledata( '<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
           '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid) || '" ' ||
           'ALT="' || imgtype || '" STYLE="display:block;">' );
    htp.formhidden( 'P4', c1rec.umo_id );
    if c1rec.is_global = 'F'
     then
       htp.tabledata( htf.formselectopen( 'P5' ) || htf.formselectoption( LNG.PHG_TXT_045 ) || htf.formselectoption( LNG.PHG_TXT_046, 'SELECTED' ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
       htp.tabledata( htf.formselectopen( 'P5' ) || htf.formselectoption( LNG.PHG_TXT_045, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_046 ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;
    -- Get Access Stats
    if nvl(c1rec.access_stats,'F') = 'F'
     then
       htp.tabledata( htf.formselectopen( 'P7' ) || htf.formselectoption( LNG.PHG_TXT_045 ) || htf.formselectoption( LNG.PHG_TXT_046, 'SELECTED' ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
       htp.tabledata( htf.formselectopen( 'P7' ) || htf.formselectoption( LNG.PHG_TXT_045, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_046 ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;
    -- Check Shopping Basket
    if nvl(c1rec.check_basket,'F') = 'F'
     then
       htp.tabledata( htf.formselectopen( 'P8' ) || htf.formselectoption( LNG.PHG_TXT_045 ) || htf.formselectoption( LNG.PHG_TXT_046, 'SELECTED' ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
       htp.tabledata( htf.formselectopen( 'P8' ) || htf.formselectoption( LNG.PHG_TXT_045, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_046 ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;
    -- Statistics Gathered
    if nvl(c1rec.access_stats,'F') = 'T'
     then
      c2rec.tot := 0;
      open c2(c1rec.umo_id,owner_id,acid);
      fetch c2 into c2rec;
      close c2;
      htp.tabledata( htf.bold(to_char(nvl(c2rec.tot,0))),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;
    htp.tabledata( htf.anchor( 'phg.delete_logo?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&imgtype=' || imgtype || '&v_umo=' || c1rec.umo_id, LNG.PHG_BUT_339 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.bold( LNG2.FNM_TXT_150 );
 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
   if not foundrec
    then
     htp.tabledata( htf.bold(LNG.PHG_TXT_019),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.formhidden( 'P7','F');
     htp.formhidden( 'P8','F');
   end if;
 htp.tablerowclose;
 htp.tablerowopen;
   htp.tabledata( GLBX.UPLOAD_NAME, cattributes=>pfx.qcbground );
 htp.tablerowclose;
 htp.tableclose;

 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );

   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_020),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext('P1',10, 20, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_021),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext('P2',10, 20, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_236),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formtext('P3',20, 100, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.PFM_TXT_160),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata( htf.formselectopen( 'P5' ) || htf.formselectoption( LNG.PHG_TXT_045, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_046 ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.formhidden( 'P4', null );
   htp.formhidden( 'P6', null );
 htp.tableclose;

 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.formhidden( 'V_UMO', null ) || htf.formsubmit( null, LNG.PHG_TXT_026 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'phg.phg_prefs' ) || htf.formhidden( 'SURL', surl ) ||htf.formhidden( 'ACID', acid ) || htf.formhidden( 'MSG', LNG.PHG_TXT_027 ) ||
                  htf.formsubmit( null, LNG.PHG_TXT_028 ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PREFS_IMG_ICON',owner_id,acid,errmsg=>sqlerrm,extdet=>'IMGTYPE:' || imgtype || ' MSG:' || msg);
end phg_prefs_img_icon;

procedure phg_prefs_img_wm( surl in varchar2,acid in integer, imgtype in varchar2, msg in varchar2 default null )
as
 cursor c1(acid integer, phgr integer, imgtype varchar2) is
   select um.photo_master, um.umo_id, um.version, um.aid, um.extras.photo_name photo_name
   from umo um, customer_account ca
   where um.aid = ca.aid and
         ca.pid = phgr and
         umo_type = imgtype;

 cursor c2(v_umo integer) is
   select um.photo_master, um.umo_id, um.version, um.aid, um.extras.photo_name photo_name
   from umo um
   where um.umo_id = v_umo
   for update nowait;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 lnk		varchar2(1000);
 width		integer;
 height		integer;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PREFS_IMG_WM', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_364,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 if msg is not null then glbx.header_msg( msg ); else htp.nl; end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1');
 for c1rec in c1( acid, owner_id, imgtype ) loop
  if nvl(c1rec.photo_master.contentlength,0) > 0
   then
     width := c1rec.photo_master.width;
     height := c1rec.photo_master.height;
     open c2( c1rec.umo_id );
     fetch c2 into c1rec;
     close c2;
     c1rec.photo_master.setproperties;
     if c1rec.photo_master.mimetype = 'image/x-ora-rpix'
      then
       c1rec.photo_master.process('fileformat=GIFF compressionFormat=GIFLZW');
       update umo set photo_master = c1rec.photo_master where umo_id = c1rec.umo_id;
       commit;
     end if;
  end if;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'phg.delete_logo?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&imgtype=' || imgtype || '&v_umo=' || c1rec.umo_id, LNG.PHG_BUT_339  ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( htf.bold(htf.italic(c1rec.photo_name)) || htf.nl || htf.bold(LNG.PHG_TXT_024) || '-' || nvl(htf.bold(c1rec.photo_master.mimetype),'&nbsp;') || htf.nl || htf.bold(LNG.PHG_TXT_025) || '-' || nvl(htf.bold(c1rec.photo_master.contentlength),'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata( '<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
           '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(c1rec.aid) || '" ' ||
           'ALT="' || imgtype || '" STYLE="display:block;">',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;

 htp.italic( LNG.PHG_TXT_258 ); htp.nl;
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.lload', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'IMGTYPE', imgtype );
 htp.formhidden( 'P4', null );
 htp.formhidden( 'P5', null );
 htp.formhidden( 'P6', null );
 htp.formhidden( 'P7', null );
 htp.formhidden( 'P8', null );
 htp.tableopen;
 htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_022) || ': ' || htf.formtext('P3',30,100),cattributes=>pfx.qcbground );
 htp.tablerowclose;
 htp.tablerowopen;
   htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>pfx.qcbground );
 htp.tablerowclose;
 htp.tableclose;

 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );


 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.formhidden( 'V_UMO', c1rec.umo_id ) || htf.formsubmit( null, LNG.PHG_TXT_278 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'phg.phg_prefs' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) || htf.formhidden( 'MSG', LNG.PHG_TXT_027 ) ||
                  htf.formsubmit( null, LNG.PHG_TXT_028 ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PREFS_IMG_WM',owner_id,acid,errmsg=>sqlerrm,extdet=>'IMGTYPE:' || imgtype || ' MSG:' || msg);
end phg_prefs_img_wm;

procedure delete_logo( surl in varchar2,acid in integer, v_umo in integer, imgtype in varchar2 )
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 parm1		ump.parameters;
 parm2		ump.parameters;
 retlink	varchar2(4000);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.DELETE_LOGO', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 parm1(1) := 'UMO_ID';
 parm2(1) := to_char(v_umo);
 parm1(2) := 'AID';
 parm2(2) := to_char(acid);
 parm1(3) := 'OBJECT_TYPE';
 parm2(3) := imgtype;
 parm1(4) := 'KEEP_STATUS';
 parm2(4) := 'DELETE';
 ump.modify_uma(surl,parm1,parm2,retlink);
 if imgtype = 'BACKGROUND'
  then
   update customer_account set background_img = null where aid = acid;
   commit;
 elsif imgtype = 'ICON'
  then
   update photographer set logo_phid = null where pid = owner_id;
 end if;
 if imgtype = 'WATERMARK'
  then
   phg_prefs_img_wm(surl,acid,imgtype,nvl(retlink,LNG.PHG_ALT_382));
  elsif imgtype = 'ICON'
   then
    phg_prefs_img_icon(surl,acid,imgtype,nvl(retlink,LNG.PHG_ALT_382));
  else
   phg_prefs_img(surl,acid,imgtype,nvl(retlink,LNG.PHG_ALT_382));
 end if;

exception when others then
 glbx.error_details( 'PHG', 'DELETE_LOGO',owner_id,acid,errmsg=>sqlerrm,extdet=>'IMGTYP:' || imgtype);
end delete_logo;

procedure lload(surl in varchar2, acid in integer, file in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, imgtype in varchar2, v_umo in integer default null )
as
 cursor c1(acid integer, phgr integer, imgtype varchar2, v_umo integer) is
   select um.umo_id
   from umo um, customer_account ca
   where um.aid = acid and
         um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'F' and
         umo_type = imgtype and
         umo_id = v_umo
   union
   select um.umo_id
   from umo um, customer_account ca
   where um.aid = ca.aid and
         um.is_global = 'T' and
         ca.pid = phgr and
         umo_type = imgtype and
         umo_id = v_umo;

 cursor c2(v_umo integer) is select um.photo_master from umo um where umo_id = v_umo;

 cursor c3(acid integer, fname varchar2, objtype varchar2 ) is select 'x' exst from umo where aid=acid and umo_type = objtype and glbx.extract_fname(photo_original_loc) = fname;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 last_file	varchar2(1000);
 ctr		integer;
 ltype		varchar2(100);
 stype		integer;
 phgid		integer;
 sts		varchar2(100);
 nmb1		integer;
 nmb2		integer;
 nmb4		integer;
 old_id		integer;
 parm1		ump.parameters;
 parm2		ump.parameters;
 newid_arr	ump.myarray_int;
 retlink	varchar2(4000);
 new_id		integer;
 ord_nmb	integer;

begin
 glbx.cookie_id( surl, stype, ltype, phgid, sts, progcalled=>'PHG.LLOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
  last_file := file;
  retlink := NULL;

  if file is not null
   then
      -- If it exists already then delete it
      if v_umo is not null
       then
         parm1(1) := 'UMO_ID';
         parm2(1) := to_char(v_umo);
         parm1(2) := 'AID';
         parm2(2) := to_char(acid);
         parm1(3) := 'OBJECT_TYPE';
         parm2(3) := imgtype;
         parm1(4) := 'KEEP_STATUS';
         parm2(4) := 'DELETE';
         ump.modify_uma(surl,parm1,parm2,retlink);
         if imgtype = 'BACKGROUND'
          then
           update customer_account set background_img = null where aid = acid;
           commit;
         elsif imgtype = 'ICON'
          then
          update photographer set logo_phid = null where pid = phgid;
         end if;

        else
         -- Test for Accidental Back Button Hit causing it to reload again
         open c3(acid,glbx.extract_fname(file,'FILE'),imgtype);
         fetch c3 into c3rec;
         if c3%FOUND
          then
           close c3;
           -- Image Already Exists. Delete it
           -- xxx for language files
           delete from apache_ows_content where name = file;
           commit;
           if imgtype = 'SLIDE'
            then
              sld.sld_bac( surl, p1(p1.first), 'Image Already Loaded - Prevented from Being Loaded Twice' );
            else
             if imgtype = 'ICON'
              then
               phg_prefs_img_icon( surl,acid, imgtype, 'Image Already Loaded - Prevented from Being Loaded Twice' );
              else
               phg_prefs_img( surl,acid, imgtype, 'Image Already Loaded - Prevented from Being Loaded Twice' );
             end if;
           end if;

          else
           close c3;
         end if;
       end if;

       parm1.delete;
       parm2.delete;
       parm1(1)  := 'AID';
       parm2(1)  := to_char(acid);
       parm1(2)  := 'OBJECT_TYPE';
       parm2(2)  := imgtype;
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'UPLOAD';
       parm1(4)  := 'FILE_NAME';
       parm2(4)  := file;
       parm1(5)  := 'STORE_ORIGINAL';
       parm2(5)  := 'FALSE';
       parm1(6)  := 'CREATE_THUMBNAIL';
       parm2(6)  := 'FALSE';
       parm1(7) := 'KEEP_STATUS';
       parm2(7) := 'KEEP';
       parm1(8) := 'ORIGINAL_LOCATION';
       parm2(8) := file;
       parm1(9) := 'PARENT_UMO_ID';
       parm2(9) := NULL;
       parm1(10) := 'SCENE_ID';
       parm2(10) := NULL;
       parm1(11) := 'UMO_OWNER';
       parm2(11) := 'PHOTOGRAPHER';
       parm1(12) := 'BYPASS_QUOTA_CHECK';
       parm2(12) := 'FALSE';
       parm1(13) := 'PHGR_ID';
       parm2(13) := to_char(phgid);
       parm1(14)  := 'OWS_NAME';
       parm2(14)  := file;
       if imgtype = 'ICON'
        then
         begin nmb1 := to_number(nvl(p1(p1.last),40)); exception when others then nmb1 := 40; end;
         begin nmb2 := to_number(nvl(p2(p1.last),40)); exception when others then nmb2 := 40; end;
         parm1(15) := 'DISPLAY_WIDTH';
         parm2(15) := nmb2;
         parm1(16) := 'DISPLAY_HEIGHT';
         parm2(16) := nmb1;
         parm1(17) := 'HTTP_LINK';
         parm2(17) := p3(p3.last);
       elsif imgtype = 'WATERMARK'
        then
         parm1(15) := 'NAME';
         parm2(15) := nvl(p3(p3.first),LNG.PHG_TXT_364);
       end if;

       ump.load_uma(surl,parm1,parm2,retlink,newid_arr ); new_id := newid_arr(1);

       if imgtype = 'ICON'
        then
         if p5(p5.last) is not null
          then
           if p5(p5.last) = LNG.PHG_TXT_045
            then
            update umo um set is_global = 'T', attribute1 = 'F', attribute2 = 'F' where umo_id = new_id;
           elsif p5(p5.last) = LNG.PHG_TXT_046
            then
            update umo um set is_global = 'F', attribute1 = 'F', attribute2 = 'F' where umo_id = new_id;
           end if;
         end if;
       end if;

    elsif (file is null) and (imgtype = 'ICON')
     then
      for j in p1.first..p1.last loop
       open c1(acid,phgid,imgtype,p4(j));
       fetch c1 into new_id;
       if c1%FOUND
        then
         close c1;
         parm1(1)  := 'AID';
         parm2(1)  := to_char(acid);
         parm1(2)  := 'OBJECT_TYPE';
         parm2(2)  := imgtype;
         parm1(3)  := 'UMO_ID';
         parm2(3)  := p4(j);
         parm1(4)  := 'KEEP_STATUS';
         parm2(4)  := 'KEEP';
         begin nmb1 := to_number(nvl(p1(j),40)); exception when others then nmb1 := 40; end;
         begin nmb2 := to_number(nvl(p2(j),40)); exception when others then nmb2 := 40; end;
         parm1(5) := 'DISPLAY_WIDTH';
         parm2(5) := nmb2;
         parm1(6) := 'DISPLAY_HEIGHT';
         parm2(6) := nmb1;
         parm1(7) := 'HTTP_LINK';
         parm2(7) := p3(j);
         ump.modify_uma(surl,parm1,parm2,retlink);
         begin ord_nmb := to_number( p6(j) ); exception when others then ord_nmb := NULL; end;
         if p5(j) is not null
          then
           if p5(j) = LNG.PHG_TXT_045
            then
             update umo um set is_global = 'T', um.extras.orderby_nmb = ord_nmb where umo_id = p4(j);
           elsif p5(j) = LNG.PHG_TXT_046
            then
             update umo um set is_global = 'F', um.extras.orderby_nmb = ord_nmb where umo_id = p4(j);
           end if;
         end if;
         if p7(j) = LNG.PHG_TXT_045
            then
             update umo um set um.attribute1 = 'T' where umo_id = p4(j);
           else
             update umo um set um.attribute2 = 'F' where umo_id = p4(j);
         end if;
         if p8(j) = LNG.PHG_TXT_045
            then
             update umo um set um.attribute2 = 'T' where umo_id = p4(j);
           else
             update umo um set um.attribute2 = 'F' where umo_id = p4(j);
         end if;
       else
        close c1;
       end if;
      end loop;
  end if;

  if retlink is null
   then
    if imgtype = 'BACKGROUND'
     then
      update customer_account set background_img = new_id where aid = acid;
     elsif imgtype = 'SLIDE'
      then
       nmb4 := p1(p1.first);
       update slide_master set background_gif = new_id where aid = acid and sid = nmb4;
     elsif imgtype = 'ICON'
      then
       update photographer set logo_phid = new_id where pid = phgid;
    end if;
  end if;

  if imgtype = 'WATERMARK'
   then
    open c2( v_umo );
    fetch c2 into c2rec;
    if c2%FOUND
     then
      close c2;
      if nvl(c2rec.photo_master.contentlength,0) > GLBX.C_PROG_MAX_WATERMARK
       then
        delete_logo(surl,acid,v_umo,imgtype);
        commit;
        phg_prefs_img_wm( surl,acid, imgtype, LNG.PHG_TXT_522 );
        return;
      end if;
     else
      close c2;
      phg_prefs_img_wm( surl,acid, imgtype, LNG.PHG_TXT_039 );
      return;
     end if;
  end if;

  if imgtype = 'SLIDE'
   then
    sld.sld_bac( surl, p1(p1.first), nvl(retlink,LNG.PHG_TXT_038) );
   else
    if imgtype = 'ICON'
     then
      phg_prefs_img_icon( surl,acid, imgtype, nvl(retlink,LNG2.FNM_TXT_149) );
     else
      phg_prefs_img( surl,acid, imgtype, nvl(retlink,LNG.PHG_TXT_039) );
    end if;
  end if;
  commit;
exception when others then
 glbx.error_details( 'PHG', 'LLOAD',phgid,acid,errmsg=>sqlerrm,extdet=>file);
 --owa_content.delete_document( last_file );
end lload;

procedure phg_prefs_phz( surl in varchar2, acid in integer, msg in varchar2 default null, profid in integer default null )
as

 cursor c1(owner_id integer) is select * from phg_price_book where pid = owner_id;
 cursor c1a(owner_id integer) is select * from order_style where pid = owner_id order by decode(is_default,'T',0,1),name;
 cursor c2(acid integer, owner_id integer, logintype varchar2) is select * from customer_price_book where aid = acid and pid = owner_id and ltype = logintype;
 cursor c3(vpid integer) is select * from phg_price_item  where spb = vpid order by ppi;
 cursor c4(vpid integer) is select name from phg_price_book where spb = vpid;
 cursor c5(owner_id integer) is select nvl(work_phone,mobile_phone) phone, skill_level,photographer_title from photographer where pid = owner_id;
 cursor c6(vspid integer, acid integer) is
  select distinct um.extra_film_colour
  from umo um
  where upper(um.extra_film_colour) not in (select upper(film_type) from phg_price_item where spb = vspid) and
        aid = acid and
        upper(um.extra_film_colour) <> LNG.ORD_TXT_194;
 cursor c7(vspid integer, acid integer) is
  select 'x' tmp
  from phg_price_item
  where upper(film_type) = LNG.ORD_TXT_194 and
        spb = vspid;
 cursor c8(vpid integer) is select count('x') tot from phg_price_item where manufacturer_id is not null and spb = vpid;
 cursor c9(acid integer) is select accept_pay_by_acct from customer_contact where aid = acid;
 cursor c10(vpid integer) is select count('x') tot from phg_price_item where spb = vpid and shop_style = LNG4.AHC_TXT_077 and shop_item = 'T';
 cursor c11(void integer, phgid integer) is select * from order_style where oid=void and pid=phgid;
 cursor c15(phgid integer, isdef varchar2) is select oid from order_style where is_default = isdef and pid = phgid;

 c2rec		c2%ROWTYPE;
 c2grec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c11grec	c11%ROWTYPE;
 c15rec		c15%ROWTYPE;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(4000);
 foundrec	boolean;
 nmb		integer;
 tot 		integer;
 tmp2		char(1);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PREFS_PHZ', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, LNG.PHG_TXT_040,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.italic( LNG.PHG_TXT_041 ); htp.nl;

 if profid is null
  then
   open c2(acid,owner_id,'OWNER');
  else
   open c2(profid,owner_id,'PROFILE');
 end if;
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
   close c2;
   -- No Price Book attached. Add one.
   open c15(owner_id,'T');
   fetch c15 into c15rec;
   if c15%NOTFOUND
    then
     close c15;
     open c15(owner_id,'F');
     fetch c15 into c15rec;
   end if;
   close c15;
   if profid is null
    then
     insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,ltype) values(owner_id,acid,c15rec.oid,null,null,'OWNER');
    else
     insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,ltype) values(owner_id,profid,c15rec.oid,null,null,'PROFILE');
   end if;
   commit;
   -- Requery and Extract the Record
   if profid is null
    then
     open c2(acid,owner_id,'OWNER');
    else
     open c2(profid,owner_id,'PROFILE');
   end if;
   fetch c2 into c2rec;
 end if;
 close c2;

 open c5(owner_id);
 fetch c5 into c5rec;
 close c5;

 foundrec := FALSE;
 tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( NULL );
 for c1arec in c1a(owner_id) loop
  foundrec := TRUE;
  if c1arec.oid = c2rec.oid
   then
    tmp := tmp || htf.formselectoption( c1arec.name,'SELECTED', cattributes=>'VALUE="' || c1arec.oid || '"' );
   else
    tmp := tmp || htf.formselectoption( c1arec.name, cattributes=>'VALUE="' || c1arec.oid || '"' );
  end if;
 end loop;
 tmp := tmp || htf.formselectclose;

 if not foundrec
  then
   htp.nl;
   htp.p('<CENTER>');
   htp.bold( LNG.PHG_TXT_471 ); htp.nl; htp.nl;
   htp.italic( LNG.PHG_TXT_472 ); htp.nl; htp.nl;
   htp.anchor2( 'fname.main?surl=' || glbx.rndsurl(surl) || '&msg=', LNG.PHG_TXT_473,ctarget=>'PHG_BOTTOM');
   htp.p('</CENTER>');
   htp.htmlclose;
   return;
 end if;

 open c11(c2rec.oid,owner_id);
 fetch c11 into c11rec;
 close c11;
 htp.p( '<CENTER>' );

 if c2rec.oid is null and profid is null
  then
   -- Order Style must be attached for Ordering to Work
   glbx.header_msg( LNG5.EXT_TXT_147 );

 elsif c11rec.spb is null and profid is null
  then
   -- Price Book must be attached for Ordering to Work
   glbx.header_msg( LNG2.PBK_TXT_122 );

 elsif profid is null and c11rec.spb is null
  then
   null; -- For Profiles ignore the fact that they aren't mapped to anything.

  else
   open c7( c11rec.spb, acid );
   fetch c7 into tmp2;
   if c7%NOTFOUND
    then
     close c7;
     -- if bus ftr 47 enabled (for AWM as this runs really slow)
     if substr(theme_rec.theme_data,47,1) = 'T'
      then
       open c6( c11rec.spb, acid );
       fetch c6 into c6rec;
       if c6%FOUND
        then
         close c6;
         -- There are film types that do not match
         glbx.header_msg( LNG2.PBK_TXT_123 );
         -- Problem film types
         htp.bold( LNG2.PBK_TXT_124 ); htp.nl;
         for c6rec in c6(c11rec.spb, acid ) loop
          htp.bold( c6rec.extra_film_colour );
          htp.nl;
         end loop;
         htp.nl;
        else
         close c6;
       end if;
     end if;
    else
     close c7;
   end if;
 end if;

 htp.formopen( 'phg.accept_prefs_phz' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'PROFID', profid );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND);
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG5.EXT_TXT_145),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

  if c5rec.skill_level = LNG2.PBK_TXT_080
   then
    htp.formhidden( 'P2', null );
    htp.formhidden( 'P3', null );
    htp.formhidden( 'P5', null );
    htp.formhidden( 'P6', null );
    htp.formhidden( 'P7', null );
    htp.formhidden( 'P8', null );
   else
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_474) || ' ' || htf.italic(LNG.MASK),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.formtext( 'P2', 20, 40, to_char(c2rec.valid_until,LNG.MASK)),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    tmp := htf.formselectopen( 'P3' ) || htf.formselectoption( NULL );
    for c1arec in c1a(owner_id) loop
    if c1arec.oid = c2rec.oid_when_invalid
     then
      tmp := tmp || htf.formselectoption( c1arec.name,'SELECTED', cattributes=>'VALUE="' || c1arec.oid || '"' );
     else
      tmp := tmp || htf.formselectoption( c1arec.name, cattributes=>'VALUE="' || c1arec.oid || '"' );
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_475),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
    htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
 end if;

  --
  -- Check if there are any Manufacturers with this Price Book. If not then do not display checkbox (set to false)
  --
  open c8(c11rec.spb);
  fetch c8 into tot;
  close c8;
  if tot = 0
   then
    tmp := htf.formhidden( 'P4', 'F' );
   else
    if c2rec.b2c_enabled='T'
     then
      tmp := htf.formcheckbox( 'P4','T','CHECKED');
     else
      tmp := htf.formcheckbox( 'P4','T');
    end if;
  end if;

  if (substr(theme_rec.theme_data,76,1) = 'T' and (tot > 0)) or
     (c2rec.b2c_enabled = 'T') -- Can only Lab Manage if there are Mapped Manufacturer Items. If it has been accidently enabled, then still show it to disable it
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_476),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     if tot = 0
      then
       htp.tabledata( tmp || 'There are no Manufacturers yet mapped for this Price Book', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      else
       htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     end if;
    htp.tablerowclose;
    if c2rec.b2c_enabled = 'T'
     then
      htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
       htp.tabledata( LNG.PHG_TXT_267,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.PHG_TXT_268,cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
       htp.tabledata( c5rec.phone,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
    end if;
  else
   htp.p( htf.formhidden( 'P4', nvl(c2rec.b2c_enabled,'F') ) );
  end if;

 open c10(c11rec.spb);
 fetch c10 into c10rec;
 close c10;
 if c10rec.tot = 0
  then
   null;
  else
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_078),cattributes=>pfx.qbground || 'valign="TOP" ALIGN="LEFT"'  );
     htp.tabledata( htf.anchor2( 'phg.map_store?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, LNG4.AHC_TXT_079,ctarget=>'MAP_WINDOW'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
 end if;

 htp.tableclose;
 htp.nl;

 -- Guest Order Style
 if profid is null
  then
   open c2(acid,owner_id,'CUSTOMER');
  else
   open c2(profid,owner_id,'PROFILEG');
 end if;
 fetch c2 into c2grec;
 close c2;
 open c11(c2grec.oid,owner_id);
 fetch c11 into c11grec;
 close c11;

 htp.nl;
 htp.bold( LNG5.EXT_TXT_149 );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND);
  htp.tablerowopen;
    tmp := htf.formselectopen( 'P5' ) || htf.formselectoption( NULL );
    for c1arec in c1a(owner_id) loop
    if c1arec.oid = c2grec.oid
     then
      tmp := tmp || htf.formselectoption( c1arec.name,'SELECTED', cattributes=>'VALUE="' || c1arec.oid || '"' );
     else
      tmp := tmp || htf.formselectoption( c1arec.name, cattributes=>'VALUE="' || c1arec.oid || '"' );
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_150),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
    htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
     htp.tabledata( htf.bold(LNG.PHG_TXT_474) || ' ' || htf.italic(LNG.MASK),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.formtext( 'P6', 20, 40, to_char(c2grec.valid_until,LNG.MASK)),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    tmp := htf.formselectopen( 'P7' ) || htf.formselectoption( NULL );
    for c1arec in c1a(owner_id) loop
    if c1arec.oid = c2grec.oid_when_invalid
     then
      tmp := tmp || htf.formselectoption( c1arec.name,'SELECTED', cattributes=>'VALUE="' || c1arec.oid || '"' );
     else
      tmp := tmp || htf.formselectoption( c1arec.name, cattributes=>'VALUE="' || c1arec.oid || '"' );
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_475),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
    htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;

  --
  -- Check if there are any Manufacturers with this Price Book. If not then do not display checkbox (set to false)
  --
  open c8(c11grec.spb);
  fetch c8 into tot;
  close c8;
  if tot = 0
   then
    tmp := htf.formhidden( 'P8', 'F' );
   else
    if c2grec.b2c_enabled='T'
     then
      tmp := htf.formcheckbox( 'P8','T','CHECKED');
     else
      tmp := htf.formcheckbox( 'P8','T');
    end if;
  end if;

  if (substr(theme_rec.theme_data,76,1) = 'T' and (tot > 0)) or
     (c2grec.b2c_enabled = 'T') -- Can only Lab Manage if there are Mapped Manufacturer Items. If it has been accidently enabled, then still show it to disable it
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_476),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     if tot = 0
      then
       htp.tabledata( tmp || 'There are no Manufacturers yet mapped for this Price Book', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      else
       htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     end if;
    htp.tablerowclose;
    if c2grec.b2c_enabled = 'T'
     then
      htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
       htp.tabledata( LNG.PHG_TXT_267,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( LNG.PHG_TXT_268,cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
       htp.tabledata( c5rec.phone,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      htp.tablerowclose;
    end if;
  else
   htp.p( htf.formhidden( 'P8', nvl(c2grec.b2c_enabled,'F') ) );
  end if;

  open c10(c11grec.spb);
  fetch c10 into c10rec;
  close c10;
  if c10rec.tot = 0
   then
    null;
   else
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG4.AHC_TXT_078),cattributes=>pfx.qbground || 'valign="TOP" ALIGN="LEFT"'  );
      htp.tabledata( htf.anchor2( 'phg.map_store?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, LNG4.AHC_TXT_079,ctarget=>'MAP_WINDOW'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

 htp.tableclose;
 htp.nl;


 ---
 htp.formsubmit(null,LNG.PHG_TXT_047);
 htp.formclose;
 htp.nl;

 if substr(theme_rec.theme_data,110,1) = 'T'
  then
    htp.anchor('phg.private_scenes?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, htf.bold(LNG.PHG_TXT_333 || '-' || LNG2.PBK_TXT_058));
    htp.nl;
    htp.nl;
 end if;

 if c11rec.spb is not null
  then
   htp.bold( LNG.PHG_TXT_478 ); htp.nl;
   nmb := c11rec.spb;
   if (c2rec.valid_until is not null) and (c2rec.valid_until < sysdate) then nmb := c2rec.oid_when_invalid; end if;
   open c4(nmb);
   fetch c4 into c4rec;
   close c4;
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND);
   htp.tablerowopen;
     htp.tabledata( htf.bold( replace(LNG2.PBK_TXT_001,'<PHOTOGRAPHER>',c5rec.photographer_title) ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.bold(htf.italic( c4rec.name )),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(  LNG2.FNM_TXT_113 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
     if substr(theme_rec.theme_data,68,1) = 'T'
      then
       htp.bold( LNG2.FNM_TXT_114 ); htp.nl;
     end if;
     if substr(theme_rec.theme_data,178,1) = 'T'
      then
       htp.bold( LNG2.FNM_TXT_115 ); htp.nl;
     end if;
     if substr(theme_rec.theme_data,72,1) = 'T'
      then
       htp.bold( LNG2.FNM_TXT_116 ); htp.nl;
     end if;
     if substr(theme_rec.theme_data,70,1) = 'T'
      then
       htp.bold( LNG2.FNM_TXT_117 ); htp.nl;
     end if;
     if substr(theme_rec.theme_data,143,1) = 'T'
      then
       htp.bold( LNG2.FNM_TXT_118 ); htp.nl;
     end if;
     if substr(theme_rec.theme_data,395,1) = 'T'
      then
       htp.bold( LNG4.AHC_TXT_690 ); htp.nl;
     end if;
     if substr(theme_rec.theme_data,373,1) = 'T'
      then
       htp.bold( LNG4.AHC_TXT_689 ); htp.nl;
     end if;
     open c9(acid);
     fetch c9 into c9rec;
     close c9;
     if c9rec.accept_pay_by_acct = 'T'
      then
       htp.bold( LNG2.FNM_TXT_121 ); htp.nl;
     end if;
     htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.nl;
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND);
   htp.tablerowopen;
     htp.tabledata( htf.bold(  LNG.PHG_TXT_479 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.bold(  LNG.PHG_TXT_356 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.bold(  LNG.PHG_TXT_480 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.bold(  LNG.PHG_TXT_481 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.bold(  LNG.CST_TXT_051 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.bold(  LNG.GLB_TXT_055 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
     htp.tabledata( htf.bold(  LNG.PHG_TXT_042 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"'  );
   htp.tablerowclose;
   for c3rec in c3(nmb) loop
    htp.tablerowopen;
     htp.tabledata( nvl(c3rec.phg_code,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( c3rec.film_type,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( c3rec.name,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( to_char(c3rec.charge,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="RIGHT"' );
     htp.tabledata( nvl(c3rec.comments,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     if c3rec.enabled = 'T'
      then
       htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      else
       htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     end if;
     if c3rec.is_default = 'T'
      then
       htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
      else
       htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     end if;
    htp.tablerowclose;
   end loop;
   htp.tableclose;
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PREFS_PHZ',owner_id,acid,errmsg=>sqlerrm,extdet=>msg);
end phg_prefs_phz;

procedure accept_prefs_phz( surl in varchar2,acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F', p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2 default 'F', profid in integer default null)
as

 cursor c1(acid integer, owner_id integer, logintype varchar2) is select rowid from customer_price_book where pid = owner_id and aid = acid and ltype = logintype;
 cursor c2(vpid integer) is select count('x') tot from phg_price_item where spb in (select spb from order_style where oid = vpid) and lab_id is null;
 cursor c3(owner_id integer) is select nvl(work_phone,mobile_phone) phone from photographer where pid = owner_id;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb1		number;
 nmb2		integer;
 theme_rec	theme_types%ROWTYPE;
 dt		date;
 dt2		date;
 msg		varchar2(1000);
 tot		integer;
 logintype	varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_PREFS_PHZ', iscust=>FALSE );
 theme_rec := get_theme_types( surl,acid );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if profid is null
  then
   open c1(acid,owner_id,'OWNER');
   logintype := 'OWNER';
  else
   open c1(profid,owner_id,'PROFILE');
   logintype := 'PROFILE';
 end if;
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   if profid is null
    then
     insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,b2c_enabled,ltype) values (owner_id,acid,null,null,null,'F',logintype);
     commit;
     open c1(acid,owner_id,logintype);
     fetch c1 into c1rec;
    else
     insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,b2c_enabled,ltype) values (owner_id,profid,null,null,null,'F',logintype);
     commit;
     open c1(profid,owner_id,logintype);
     fetch c1 into c1rec;
   end if;
 end if;
 close c1;
 msg := NULL;
 begin nmb1 := to_number(p1); exception when others then nmb1 := NULL; end;
 begin nmb2 := to_number(p3); exception when others then nmb2 := NULL; end;
 begin dt := to_date(p2,LNG.MASK); if dt is not null then dt := dt + ((86399)/(86400)); end if; exception when others then msg := LNG.ORD_TXT_151; dt := NULL; end;
 if ((dt is not null) and (nmb2 is null)) or
    ((dt is null) and (nmb2 is not null))
  then
   msg := LNG.PHG_TXT_499; dt := NULL; nmb2 := NULL;
 end if;
 if substr(theme_rec.theme_data,4,1) = 'T'
  then
   if dt < sysdate then msg := LNG.PHG_TXT_477; end if;
 end if;
 if msg is not null then phg_prefs_phz(surl,acid,msg,profid); return; end if;
 if nvl(p4,'T') = 'T'
  then
   -- Check if the Price Book(s) contain private entries
   tot := 0;
   open c2(nmb1);
   fetch c2 into tot;
   close c2;
   if tot > 0
    then
     msg := LNG.PHG_TXT_261 || '-' || htf.italic(LNG.PHG_TXT_262);
    else
     if nmb2 is not null
      then
       tot := 0;
       open c2(nmb2);
       fetch c2 into tot;
       close c2;
       if tot > 0
        then
         msg := LNG.PHG_TXT_266 || '-' || htf.italic(LNG.PHG_TXT_262);
        else
         open c3(owner_id);
         fetch c3 into c3rec;
         close c3;
         if c3rec.phone is null
          then
           msg := LNG.PHG_TXT_269 || '-' || htf.italic(LNG.PHG_TXT_270);
         end if;
       end if;
     end if;
   end if;
 end if;

 -- Update the Guest Side
 if p5 is null
  then
   if profid is null
    then
     delete from customer_price_book where aid = acid and pid = owner_id and ltype = 'CUSTOMER';
    else
     delete from customer_price_book where aid = profid and pid = owner_id and ltype = 'PROFILEG';
   end if;
  else
    begin dt2 := to_date(p6,LNG.MASK); if dt is not null then dt2 := dt2 + ((86399)/(86400)); end if; exception when others then msg := LNG.ORD_TXT_151; dt2 := NULL; end;
    if profid is null
     then
      update customer_price_book
       set
        oid = p5,
        valid_until = dt2,
        oid_when_invalid = p7,
        b2c_enabled = nvl(p8,'F')
        where aid = acid and
              pid = owner_id and
              ltype = 'CUSTOMER';
      if sql%notfound
       then
       insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,b2c_enabled,ltype) values (owner_id,acid,p5,dt2,p7,nvl(p8,'F'),'CUSTOMER');
      end if;
     else
      update customer_price_book
       set
        oid = p5,
        valid_until = dt2,
        oid_when_invalid = p7,
        b2c_enabled = nvl(p8,'F')
        where aid = profid and
              pid = owner_id and
              ltype = 'PROFILEG';
      if sql%notfound
       then
       insert into customer_price_book(pid,aid,oid,valid_until,oid_when_invalid,b2c_enabled,ltype) values (owner_id,profid,p5,dt2,p7,nvl(p8,'F'),'PROFILEG');
      end if;
    end if;
 end if;

 if msg is not null then phg_prefs_phz(surl,acid,msg,profid); return; end if;
 if substr(theme_rec.theme_data,76,1) = 'T'
  then
    if profid is null
     then
      update customer_price_book
       set
        oid = nmb1,
        valid_until = dt,
        oid_when_invalid = nmb2,
        b2c_enabled = nvl(p4,'F')
       where aid = acid and
             pid = owner_id and
             ltype = 'OWNER';
    else
      update customer_price_book
       set
        oid = nmb1,
        valid_until = dt,
        oid_when_invalid = nmb2,
        b2c_enabled = nvl(p4,'F')
       where aid = profid and
             pid = owner_id and
             ltype = 'PROFILE';
    end if;
  else
    if profid is null
     then
      update customer_price_book
       set
        oid = nmb1,
        valid_until = dt,
        b2c_enabled = nvl(p4,'F'),
        oid_when_invalid = nmb2
       where aid = acid and
             pid = owner_id and
             ltype = 'OWNER';
     else
      update customer_price_book
       set
        oid = nmb1,
        valid_until = dt,
        b2c_enabled = nvl(p4,'F'),
        oid_when_invalid = nmb2
       where aid = profid and
             pid = owner_id and
             ltype = 'PROFILE';
    end if;
  end if;
 commit;
 phg_prefs_phz(surl,acid,LNG.PHG_TXT_009,profid);
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_PREFS_PHZ',owner_id,acid,errmsg=>sqlerrm);
end accept_prefs_phz;

procedure phg_prefs_txt( surl in varchar2, acid in integer, msg in varchar2 default null )
as
 cursor c1(photoid integer, acid integer) is
  select ap.prefgroup, pp.prefid,pp.value,ap.preference_name,ap.preference_type, ap.help_text , ap.global_only
  from photographer_preference pp, all_preferences ap
  where pp.pid = photoid and
  	pp.aid = acid and
        pp.prefid = ap.prefid
  order by ap.prefgroup,pp.prefid;

 cursor c2 is select style_name from gallery_style;
 cursor c3 is select manufacturer_id,name from manufacturer where man_type = 'LAB' order by manufacturer_id;
 cursor c4 is select LNG.PHG_TXT_308 pft from dual union all select LNG.PHG_TXT_309 pft from dual union all select LNG.PHG_TXT_310 pft from dual;
 cursor c5(phgid integer) is select spb,name from phg_price_book where pid = phgid order by spb;
 cursor c6(phgid integer) is select count('x') from phg_price_book where pid = phgid;
 cursor c7(phgid integer) is select * from theme_types where theme_type = (select theme_type from photographer where pid = phgid);
 --cursor c8 is select currency_code,currency_country from currency;
 --cursor c9 is select distinct region from postal_charge;
 cursor c10(owner_id integer) is select skill_level from photographer where pid = owner_id;

 c10rec		c10%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tmp		varchar2(32767);
 lastgrp	varchar2(100);
 ttype		varchar2(100);
 tot		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PREFS_TXT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if acid = 0
  then
   pfx := glbx.photo_lf( owner_id );
   open c7(owner_id);
   fetch c7 into theme_rec;
   close c7;
  else
   pfx := glbx.get_thm( acid );
   theme_rec := get_theme_types( surl,acid );
 end if;

 -- Extract Skill Level of Photographer
 open c10(owner_id);
 fetch c10 into c10rec;
 close c10;

 glbx.main_title( surl, LNG.PHG_TXT_077,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P08',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.formopen( 'phg.phg_accept_preferences' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', ACID );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 width="90%"' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG.GLB_TXT_125),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold(LNG.PHG_TXT_010),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold(LNG.CST_TXT_013),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  if substr(theme_rec.theme_data,67,1) = 'F'
   then
    open c6(owner_id);
    fetch c6 into tot;
    close c6;
    if nvl(tot,0) = 0
     then
      htp.nl;
      htp.header( 3, LNG2.PBK_TXT_120, 'CENTER' );
      htp.nl;
      htp.anchor( 'pbk.main?surl=' || glbx.rndsurl(surl) || '&msg=', LNG2.PBK_TXT_121 );
      htp.htmlclose;
      return;
    end if;
  end if;

  lastgrp := 'X'; -- Set it to a dummy value
  for c1rec in c1( owner_id, acid ) loop
   if c1rec.global_only = 'T' and acid > 0
    then
     -- If global_only = T then only if the acid = 0 can it be edited
     null;
    else
	htp.formhidden( 'P0', c1rec.prefid );
	if lastgrp <> c1rec.prefgroup
	 then
	   if lastgrp is not null
	    then
	     htp.tableclose;
	     htp.nl;
             htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 width="90%"' );
           end if;
           htp.tablerowopen;
           htp.tabledata(htf.bold( c1rec.prefgroup),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
          else
           htp.tablerowopen;
           htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
	end if;

	lastgrp := c1rec.prefgroup;
	if c1rec.preference_type = 'INTEGER'
	  then
        htp.tabledata(htf.italic( c1rec.help_text ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tabledata(htf.formtext('P1',15, 100, c1rec.value ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
	 elsif c1rec.preference_type = 'MONEY'
	  then
           htp.tabledata(htf.italic( c1rec.help_text ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
          begin
           htp.tabledata(htf.formtext('P1',15, 100, to_char(to_number(c1rec.value,LNG.MONEY_FORMAT),LNG.MONEY_FORMAT) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
          exception when others then
           htp.tabledata(htf.formtext('P1',15, 100, NULL ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
          end;
	 elsif c1rec.preference_type = 'PERCENTAGE'
	  then
        htp.tabledata(htf.italic( c1rec.help_text || ' %' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tabledata(htf.formtext('P1',15, 100, c1rec.value ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
	 elsif c1rec.preference_type = 'VARCHAR100'
	  then
        htp.tabledata(htf.italic( c1rec.help_text ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tabledata(htf.formtext('P1',40, 100, replace(replace(replace(c1rec.value,'"','&#34;'),'<','&lt;'),'>','&gt;') ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
	 elsif c1rec.preference_type = 'LOV'
	  then
	   tmp := htf.formselectopen( 'P1' );
	   if c1rec.preference_name = 'GALLERY_STYLE'
	    then
	     for c2rec in c2 loop
	      if c2rec.style_name = c1rec.value
	       then
	        tmp := tmp || htf.formselectoption( c2rec.style_name, 'SELECTED' );
	       else
	        tmp := tmp || htf.formselectoption( c2rec.style_name );
	      end if;
	     end loop;
	   elsif c1rec.preference_name = 'THUMBNAIL_QUALITY'
	    then
	     for c4rec in c4 loop
	      if rtrim(c4rec.pft) = c1rec.value
	       then
	        tmp := tmp || htf.formselectoption( rtrim(c4rec.pft), 'SELECTED' );
	       else
	        tmp := tmp || htf.formselectoption( rtrim(c4rec.pft) );
	      end if;
	     end loop;
	   elsif c1rec.preference_name = 'SUPER_THB'
	    then
	     /*
	     for j in 1..8 loop
	      if to_char(j) = c1rec.value
	       then
	        tmp := tmp || htf.formselectoption( to_char(j), 'SELECTED' );
	       else
	        tmp := tmp || htf.formselectoption( to_char(j) );
	      end if;
	     end loop;
	    */
	    tmp := tmp || glbx.quality_loop( null, c1rec.value, FALSE );

	   elsif c1rec.preference_name in ('GIFT_WRAP','INT_GST','RING','INSTRUCTIONS','DISPLAY_ORIGINAL','FAST_NEW','RET_ORIG')
	    then
	     if c1rec.value = LNG.PHG_TXT_045
	      then
	        tmp := tmp || htf.formselectoption(  LNG.PHG_TXT_045, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_046 );
	       else
	        tmp := tmp || htf.formselectoption(  LNG.PHG_TXT_045 ) || htf.formselectoption(  LNG.PHG_TXT_046, 'SELECTED' );
	     end if;
	   elsif c1rec.preference_name in ('CUST_LOGOFF')
	    then
	     if c1rec.value = LNG.PHG_TXT_045
	      then
	        tmp := tmp || htf.formselectoption(  LNG.PHG_TXT_045, 'SELECTED' );
	      else
	        tmp := tmp || htf.formselectoption(  LNG.PHG_TXT_045 );
	     end if;
	     if c1rec.value = LNG.PHG_TXT_046
	      then
	        tmp := tmp || htf.formselectoption(  LNG.PHG_TXT_046, 'SELECTED' );
	      else
	        tmp := tmp || htf.formselectoption(  LNG.PHG_TXT_046 );
	     end if;
	     if c1rec.value = 'None'
	      then
	        tmp := tmp || htf.formselectoption(  'None', 'SELECTED' );
	      else
	        tmp := tmp || htf.formselectoption(  'None');
	     end if;
	   elsif c1rec.preference_name = 'LINK_STRENGTH'
	    then
	     if c1rec.value = LNG2.PBK_TXT_064
	      then
	        tmp := tmp || htf.formselectoption(  LNG2.PBK_TXT_064, 'SELECTED' ) || htf.formselectoption( LNG2.PBK_TXT_065 ) || htf.formselectoption( LNG2.PBK_TXT_066 ) || htf.formselectoption( LNG2.PBK_TXT_067 );
	     elsif c1rec.value = LNG2.PBK_TXT_065
	      then
	        tmp := tmp || htf.formselectoption(  LNG2.PBK_TXT_064 ) || htf.formselectoption( LNG2.PBK_TXT_065, 'SELECTED' ) || htf.formselectoption( LNG2.PBK_TXT_066 ) || htf.formselectoption( LNG2.PBK_TXT_067 );
	     elsif c1rec.value = LNG2.PBK_TXT_066
	      then
	        tmp := tmp || htf.formselectoption(  LNG2.PBK_TXT_064 ) || htf.formselectoption( LNG2.PBK_TXT_065 ) || htf.formselectoption( LNG2.PBK_TXT_066, 'SELECTED' ) || htf.formselectoption( LNG2.PBK_TXT_067 );
	     elsif c1rec.value = LNG2.PBK_TXT_067
	      then
	        tmp := tmp || htf.formselectoption(  LNG2.PBK_TXT_064 ) || htf.formselectoption( LNG2.PBK_TXT_065 ) || htf.formselectoption( LNG2.PBK_TXT_066 ) || htf.formselectoption( LNG2.PBK_TXT_067, 'SELECTED' );
	     end if;
	   end if;
           htp.tabledata(htf.italic( c1rec.help_text ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
           htp.tabledata(tmp || htf.formselectclose,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
	 elsif c1rec.preference_type = 'VARCHAR4000'
	  then
        htp.tabledata(htf.italic( c1rec.help_text ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tabledata(htf.formtextareaopen('P1',3, 40, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c1rec.value,'"','&#34;'),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
	 end if;
     htp.tablerowclose;
    end if;
  end loop;
  htp.tableclose;
 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, LNG.PHG_TXT_077 ) || htf.formclose );
   if acid <> 0
    then
     htp.tabledata( htf.formopen( 'phg.phg_prefs' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) || htf.formhidden( 'MSG',  NULL ) || htf.formsubmit( null, LNG.PHG_TXT_028 ) || htf.formclose );
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PREFS_TXT',owner_id,acid,errmsg=>sqlerrm,extdet=>msg);
end phg_prefs_txt;

procedure phg_acct_left( surl in varchar2,acid in integer, expanded_scenes in GLBX.MYARRAY, new_nested in varchar2 default null )
as

 cursor c1(photid integer, acid integer) is select * from customer_account where aid=acid and pid=photid;
 cursor c2( snm varchar2 ) is select image_gif,title_gif,scene_descript from scene where scene_name  = snm;
 cursor c4(owner_id integer) is select is_beta_tester from photographer where pid = owner_id;
 cursor c5(ltype varchar2, acid integer, skl varchar2) is
  select *
  from configurable_menu
  where login_type = ltype and
       ((aid is null) or ((aid = acid) and (aid is not null))) and
       decode( skl,LNG2.PBK_TXT_080,0,LNG2.PBK_TXT_081,1,2) >= decode(skill_level,LNG2.PBK_TXT_080,0,LNG2.PBK_TXT_081,1,2)
  order by order_by;
 cursor c6(owner_id integer) is select skill_level from photographer where pid = owner_id;


 c1rec 		c1%ROWTYPE;
 c2rec 		c2%ROWTYPE;
 c4rec 		c4%ROWTYPE;
 c6rec 		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 btxt		varchar2(10);
 theme_rec	THEME_TYPES%ROWTYPE;


 procedure dispbutton(surl in varchar2, stype in integer, skill_level in varchar2)
 as
  trg   varchar2(20);
  ucall varchar2(1000);
 begin

   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' );
    htp.tablerowopen;
     htp.tabledata(glbx.userpref( c1rec.pid, c1rec.aid, 'TITLE_CHOOSER' ),cattributes=>'ALIGN="CENTER" valign="MIDDLE"');
    htp.tablerowclose;
   if pfx.uses_boundary = 'T'
    then
     htp.tabledata(htf.img( curl=>DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'pup.gif',cattributes=>'BORDER=0 ' ));
   end if;

   trg := 'PHG_RIGHT';
   for c5rec in c5(ltype,acid,skill_level) loop
    if (c5rec.theme_id is not null and substr(theme_rec.theme_data,c5rec.theme_id,1) = 'T') or (c5rec.theme_id is null)
     then
      ucall := replace(c5rec.url_call,'~SURL',surl);
      ucall := replace(ucall,'~RND',to_char(sysdate,'SSSSS'));
      ucall := replace(ucall,'~STYPE', to_char(stype) );
      ucall := replace(ucall,'~ACID', to_char(acid) );
      if c5rec.menu_type = 'MOUSE OVER'
       then
        htp.tablerowopen;
         htp.tabledata(htf.anchor2( ucall,htf.img( curl=>DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c5rec.subdirectory || c5rec.img ||'.gif',
                       calt=>c5rec.help_on,cattributes=>'BORDER=0 name="opt' || c5rec.img || '"' ),
                       ctarget=>nvl(c5rec.override_target,trg),
                       cattributes=>'onMouseover="turnoff' || c5rec.img || '(opt' || c5rec.img || '); return true;" onMouseout="turnon' || c5rec.img || '(opt' || c5rec.img || '); return true;"'));
        htp.tablerowclose;
      end if;
    end if;
   end loop;

  if pfx.uses_boundary = 'T'
   then
    htp.tabledata(htf.img( curl=>DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'pdw.gif',cattributes=>'BORDER=0 ' ));
  end if;
  htp.tableclose;
 end dispbutton;


 procedure dispscene(surl in varchar2)
 as
 begin
  -- if pfx.scene_position = 'T' then return; end if; Note: With a photographer, cannot display the top bit, so don't.
  open c2( c1rec.scene_name );
  fetch c2 into c2rec;
  close c2;
  glbx.scene_display( surl,c1rec, pfx, ltype, stype, owner_id, substr(theme_rec.theme_data,92,1), pfx.nested_scene_style, htf.img( DECS.IMAGE_LOCATION || 'category/' || c2rec.image_gif,cattributes=>'border=0',calt=>c2rec.scene_descript ), c2rec.title_gif, 0, expanded_scenes, new_nested=>new_nested );
 end dispscene;


begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_ACCT_LEFT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 open c6( owner_id );
 fetch c6 into c6rec;
 close c6;
 theme_rec := get_theme_types( surl,acid );
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, null,'<BODY BGCOLOR="#' || pfx.lhs_back || '">',stype=>stype,sstyle=>pfx.lhs_text_font,sclr=>pfx.lhs_text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

  htp.print('<SCRIPT LANGUAGE="Javascript">');

   for c5rec in c5(ltype,owner_id,c6rec.skill_level) loop
    if (c5rec.theme_id is not null and substr(theme_rec.theme_data,c5rec.theme_id,1) = 'T') or (c5rec.theme_id is null)
     then
      if c5rec.menu_type = 'MOUSE OVER'
       then
        htp.print( 'function turnon' || c5rec.img || '(img' || c5rec.img || ') {img' || c5rec.img || '.src="' || DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c5rec.img || '.gif' || '"} ');
        htp.print( 'function turnoff' || c5rec.img || '(img' || c5rec.img || '){img' || c5rec.img || '.src="' || DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c5rec.img || 'x.gif' || '"}');
      end if;
    end if;
   end loop;

 htp.print('</SCRIPT>');

 htp.italic( htf.bold(c1rec.account_name) );
 htp.nl;
 htp.p( '<CENTER>' );

 if pfx.phg_but_scene = 'T'
  then
   dispbutton(surl,stype,c6rec.skill_level);
   dispscene(surl);
 elsif pfx.phg_but_scene = 'D'
  then
   dispbutton(surl,stype,c6rec.skill_level);
  else
   dispscene(surl);
   dispbutton(surl,stype,c6rec.skill_level);
 end if;

 if substr(theme_rec.theme_data,53,1) = 'T'
  then
   htp.anchor2('phg.manage_gallery?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=', htf.img( DECS.IMAGE_LOCATION || 'adminc/galleryx.gif', cattributes=>'BORDER=0'), ctarget=>'PHG_RIGHT');
   htp.nl;
 end if;

 open c4(owner_id);
 fetch c4 into c4rec;
 close c4;
 if c4rec.is_beta_tester = 'T'
   then
   htp.anchor2( 'glbx.beta_bug?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/bug.gif', cattributes=>'BORDER=0'), ctarget=>'PHG_RIGHT');
 end if;


 htp.p( '</CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0 ' );
  htp.tablerowopen;
  htp.tabledata(glbx.userpref( c1rec.pid, c1rec.aid, 'HELP_CHOOSER' ),cattributes=>' CLASS="SMALL"');
  htp.tablerowclose;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_ACCT_LEFT',owner_id,acid,errmsg=>sqlerrm);
end phg_acct_left;

procedure phg_create_new_acct(surl in varchar2,msg in varchar2 default null)
as
begin
 phg_acct_details( surl, 0, nvl(msg,LNG.PHG_TXT_162) );
exception when others then
 glbx.error_details( 'PHG', 'PHG_CREATE_NEW_ACCT',errmsg=>sqlerrm);
end phg_create_new_acct;

procedure phg_acct_details( surl in varchar2, acid in integer, msg in varchar2 default null, profid in integer default null )
as
 cursor c1(phid integer, acid integer) is select * from customer_account where aid = acid and pid = phid;
 cursor c1p(phid integer, profid integer) is select * from customer_profile where profile_id = profid and pid = phid;
 cursor c2 is select scene_name from scene order by scene_name;
 cursor c3(phid integer) is select theme_name from theme order by theme_name;
 cursor c3a is select theme_type from theme_types order by theme_type;
 cursor c4(phid integer) is select days_to_expire from charge_plan cp,photographer ph where cp.id=ph.plan_id and pid = phid;
 cursor c5 is select clr_name,clr_hex from colours order by clr_name;
 cursor c6(acid integer) is select * from audit_customer_password where aid = acid and date_changed = (select max(date_changed) from audit_customer_password where aid=acid and pw is not null);
 cursor c6p(profid integer) is select * from audit_profile_password where profile_id = profid and date_changed = (select max(date_changed) from audit_profile_password where profile_id=profid and pw is not null);
 cursor c7(acid integer) is select pwg,date_changed from audit_customer_password where aid = acid and date_changed = (select max(date_changed) from audit_customer_password where aid=acid and pwg is not null);
 cursor c7p(profid integer) is select pwg, date_changed from audit_profile_password where profile_id = profid and date_changed = (select max(date_changed) from audit_profile_password where profile_id=profid and pwg is not null);
 cursor c8(phid integer) is select payment_style, ph.plan_id from photographer ph,charge_plan cp where cp.id = ph.plan_id and ph.pid = phid;
 cursor c9(phid integer) is select scene_name from limit_scenes where pid = phid order by upper(scene_name);
 cursor c10(phid integer) is select theme_name from limit_laf where pid = phid order by upper(theme_name);
 cursor c11(phid integer) is select limit_scene,limit_laf,limit_bf,skill_level,default_category,default_bf,default_lf,top_frame_lf,theme_type from photographer where pid = phid;
 cursor c12(phid integer) is select theme_type from limit_bf where pid = phid order by upper(theme_type);
 cursor c14( plid integer, phgid integer ) is select * from charge_plan_event_phg where plan_id = plid and pid = phgid;
 cursor c15( plid integer, ev varchar2 ) is select * from charge_plan_event where plan_id = plid and plan_event = ev;
 cursor c16( phid integer) is select * from theme_types where theme_type in (select theme_type from photographer where pid = phid );
 cursor c17( phid integer) is select aid,account_name from customer_account where pid = phid and aid > 0 order by account_name;

 c1rec		c1%ROWTYPE;
 c1prec		c1p%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c6prec		c6p%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c15rec		c15%ROWTYPE;
 tmp		varchar2(10000);
 tmp2		varchar2(100);
 ltype		varchar2(100);
 stype		integer;
 dte		date;
 foundrec	boolean;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 theme_rec2	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_ACCT_DETAILS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if profid is null
  then
   open c1( owner_id, acid );
   fetch c1 into c1rec;
   close c1;
   if acid = 0 then c1rec.aid := 0; end if;
  else
   if profid = 0 -- If a new profile, then just take a copy of the existing customer account as a base
    then
     open c1( owner_id, acid );
     fetch c1 into c1rec;
     close c1;
     c1rec.account_name := 'PROFILE_' || c1rec.account_name;
     c1rec.username := 'P_' || c1rec.username;
    else
     open c1p( owner_id, profid );
     fetch c1p into c1prec;
     close c1p;
     open c1(c1prec.pid,c1prec.aid);
     fetch c1 into c1rec;
     close c1;
     c1rec := glbx.conv_account(c1prec,c1rec);
   end if;
 end if;

 if profid is null
  then
   open c6(c1rec.aid);
   fetch c6 into c6rec;
   close c6;
   open c7(c1rec.aid);
   fetch c7 into c6rec.pwg, dte;
   close c7;
   c6rec.date_changed := nvl(c6rec.date_changed,dte);
  else
   open c6p(profid);
   fetch c6p into c6prec;
   close c6p;
   open c7p(profid);
   fetch c7p into c6prec.pwg, dte;
   close c7p;
   c6rec.date_changed := nvl(c6prec.date_changed,dte);
   c6rec.pwg := c6prec.pwg;
   c6rec.date_changed := c6prec.date_changed;
   c6rec.pw := c6prec.pw;
 end if;

 open c11( owner_id );
 fetch c11 into c11rec;
 close c11;
 if acid = 0
  then
   c1rec.scene_name := c11rec.default_category;
   c1rec.theme_name := c11rec.top_frame_lf;
   c1rec.theme_type := c11rec.theme_type;
   pfx := glbx.get_thm( c1rec.theme_name );
   open c16(owner_id);
   fetch c16 into theme_rec;
   close c16;
  else
   pfx := glbx.get_thm( c1rec.theme_name );
   theme_rec := get_theme_types( surl,c1rec.aid );
 end if;

 if profid is null
  then
   if acid = '0'
    then
     glbx.main_title(surl, LNG.PHG_TXT_163,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    else
     glbx.main_title(surl, LNG.PHG_ALT_386,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   end if;
  else
     glbx.main_title(surl, LNG.PHG_TXT_092,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P33',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

 htp.p('<CENTER>' );
  htp.formopen( 'glbx.process_acct_details', ctarget=>'PHG_BOTTOM' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', c1rec.aid );
  if profid is not null
   then
    htp.formhidden( 'PROFID', profid );
  end if;

  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1' );
      -- If New Account Give Option of Creating Based on Existing One
      if acid = 0
       then
        htp.tablerowopen;
        htp.tabledata( htf.bold(LNG4.AHC_TXT_977),cattributes=>pfx.qbground );
        htp.p( '<TD ' || pfx.qcbground || '>' );
        htp.formselectopen( 'P1B' );
        htp.formselectoption( NULL );
        for c17rec in c17( owner_id ) loop
         htp.formselectoption( c17rec.account_name, cattributes=>'VALUE="' || c17rec.aid || '"' );
        end loop;
        htp.formselectclose;
        htp.p( '</TD>' );
        htp.tablerowclose;
      end if;
      if profid is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold('Profile Id'),cattributes=>pfx.qbground );
         htp.tabledata( htf.bold( profid ),cattributes=>pfx.qcbground );
        htp.tablerowclose;
      end if;
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.PHG_TXT_164),cattributes=>pfx.qbground );
       htp.tabledata( htf.formtext( 'P1', 40, 100, c1rec.account_name ),cattributes=>pfx.qcbground );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.PHG_TXT_165),cattributes=>pfx.qbground );
       htp.tabledata( htf.formtext( 'P2', 20, 20, c1rec.date_held ),cattributes=>pfx.qcbground );
      htp.tablerowclose;
      open c8(owner_id);
      fetch c8 into c8rec;
      close c8;
      if c8rec.payment_style in ('YEARLY')
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_174),cattributes=>pfx.qbground );
          tmp := htf.formselectopen( 'P2B' ) || htf.formselectoption(to_char(nvl(c1rec.date_expires,sysdate),LNG.MASK),'SELECTED');
	   tmp := tmp || htf.formselectoption( to_char( sysdate + 1,LNG.MASK) );
	   tmp := tmp || htf.formselectoption( to_char( sysdate + 2,LNG.MASK) );
	   tmp := tmp || htf.formselectoption( to_char( sysdate + 3,LNG.MASK) );
	   tmp := tmp || htf.formselectoption( to_char( sysdate + 4,LNG.MASK) );
	   tmp := tmp || htf.formselectoption( to_char( sysdate + 5,LNG.MASK) );
	   tmp := tmp || htf.formselectoption( to_char( sysdate + 6,LNG.MASK) );
	   tmp := tmp || htf.formselectoption( to_char( sysdate + 30,LNG.MASK) );
	   if c1rec.date_created is not null
	    then
	     tmp := tmp || htf.formselectoption( to_char( c1rec.date_created + 30,LNG.MASK) );
	   end if;
	  for j in 1..52 loop
	   tmp := tmp || htf.formselectoption( to_char( sysdate + (j*7),LNG.MASK) );
	  end loop;
	  tmp := tmp || htf.formselectoption( to_char( add_months(sysdate,18),LNG.MASK) );
	  tmp := tmp || htf.formselectoption( to_char( add_months(sysdate,24),LNG.MASK) );
	  tmp := tmp || htf.formselectoption( to_char( add_months(sysdate,30),LNG.MASK) );
	  tmp := tmp || htf.formselectoption( to_char( add_months(sysdate,36),LNG.MASK) );
	  tmp := tmp || htf.formselectoption( to_char( add_months(sysdate,42),LNG.MASK) );
	  tmp := tmp || htf.formselectoption( to_char( add_months(sysdate,48),LNG.MASK) );
	  tmp := tmp || htf.formselectclose;
         htp.tabledata( tmp,cattributes=>pfx.qcbground );
        htp.tablerowclose;
       else
        htp.formhidden( 'P2B',null);
      end if;
      if profid is null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_436),cattributes=>pfx.qbground );
         htp.tabledata( htf.formtext( 'P2A', 10, 20, c1rec.photographer_account_id ),cattributes=>pfx.qcbground );
        htp.tablerowclose;
       else
        htp.formhidden( 'P2A', c1rec.photographer_account_id );
      end if;

      if substr(theme_rec.theme_data,190,1) = 'T' -- If enabled, the Customer Account also supports Guests
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG2.PFM_TXT_067),cattributes=>pfx.qbground );
         if c1rec.public_account = 'T'
          then
           htp.tabledata(LNG.PHG_TXT_045 || htf.formradio( 'PPUB','T','CHECKED' ) || LNG.PHG_TXT_046 || htf.formradio( 'PPUB','F' ),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata(LNG.PHG_TXT_045 || htf.formradio( 'PPUB','T' ) || LNG.PHG_TXT_046 || htf.formradio( 'PPUB','F','CHECKED' ),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"');
         end if;
        htp.tablerowclose;
       else
        htp.formhidden( 'PPUB', 'F' );
      end if;

      if substr(theme_rec.theme_data,89,1) = 'T' -- Client can edit Meta Data
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG5.EXT_TXT_163),cattributes=>pfx.qbground );
         if c1rec.can_edit_meta_data_values = 'T'
          then
           htp.tabledata(LNG.PHG_TXT_045 || htf.formradio( 'PMET','T','CHECKED' ) || LNG.PHG_TXT_046 || htf.formradio( 'PMET','F' ),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"');
          else
           htp.tabledata(LNG.PHG_TXT_045 || htf.formradio( 'PMET','T' ) || LNG.PHG_TXT_046 || htf.formradio( 'PMET','F','CHECKED' ),cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"');
         end if;
        htp.tablerowclose;
       else
        htp.formhidden( 'PMET', 'F' );
      end if;

      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.PHG_TXT_166),cattributes=>pfx.qbground );
       htp.tabledata( htf.formtext( 'P3', 40, 100, c1rec.username ),cattributes=>pfx.qcbground );
      htp.tablerowclose;

      if substr(theme_rec.theme_data,193,1) = 'T'
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_167),cattributes=>pfx.qbground );
         htp.tabledata( htf.formpassword( 'P4A', 40, 100, NULL ),cattributes=>pfx.qcbground );
        htp.tablerowclose;
       else
        htp.formhidden( 'P4A', NULL );
      end if;

      if substr(theme_rec.theme_data,190,1) = 'T'
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_168),cattributes=>pfx.qbground );
         htp.tabledata( htf.formpassword( 'P4', 40, 100, NULL ),cattributes=>pfx.qcbground );
        htp.tablerowclose;
       else
        htp.formhidden( 'P4', NULL );
      end if;

      if c6rec.date_changed is not null
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_ALT_387),cattributes=>pfx.qbground );
         if substr(theme_rec.theme_data,190,1) = 'T' and substr(theme_rec.theme_data,193,1) = 'T'
          then
           htp.tabledata( to_char(c6rec.date_changed,LNG.MASK) || ' - ' || c6rec.pw || ' / ' || c6rec.pwg,cattributes=>pfx.qcbground );
          elsif substr(theme_rec.theme_data,190,1) = 'T'
           then
            htp.tabledata( to_char(c6rec.date_changed,LNG.MASK) || ' - ' || c6rec.pwg,cattributes=>pfx.qcbground );
          elsif substr(theme_rec.theme_data,193,1) = 'T'
           then
            htp.tabledata( to_char(c6rec.date_changed,LNG.MASK) || ' - ' || c6rec.pw,cattributes=>pfx.qcbground );
         end if;
        htp.tablerowclose;
      end if;

      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.CST_TXT_042),cattributes=>pfx.qbground );

       tmp := htf.formselectopen( 'P5' );
       if c11rec.limit_scene = 'T'
        then
         for c2rec in c2 loop
          if c1rec.scene_name = c2rec.scene_name
           then
            tmp := tmp || htf.formselectoption( c2rec.scene_name, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c2rec.scene_name );
          end if;
         end loop;
         tmp := tmp || htf.formselectclose;
        else
         for c9rec in c9(owner_id) loop
          if c1rec.scene_name = c9rec.scene_name
           then
            tmp := tmp || htf.formselectoption( c9rec.scene_name, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c9rec.scene_name );
          end if;
         end loop;
         tmp := tmp || htf.formselectclose;
       end if;
       if c1rec.aid = 0
        then
         htp.tabledata( tmp,cattributes=>pfx.qcbground );
        else
         htp.tabledata( htf.bold( c1rec.scene_name) || ' ' || htf.anchor( 'phg.phg_rename?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, '[' || LNG.PHG_TXT_514 || ']'),cattributes=>pfx.qcbground );
         htp.formhidden( 'P5', c1rec.scene_name );
       end if;
      htp.tablerowclose;

      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.PHG_TXT_129),cattributes=>pfx.qbground );
       tmp := htf.formselectopen( 'P6F' );
       if c11rec.limit_bf = 'T'
        then
         for c3arec in c3a loop
          if c1rec.theme_type = c3arec.theme_type
           then
            tmp := tmp || htf.formselectoption( c3arec.theme_type, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c3arec.theme_type );
          end if;
         end loop;
        else
         for c12rec in c12(owner_id) loop
          if c1rec.theme_type = c12rec.theme_type
           then
            tmp := tmp || htf.formselectoption( c12rec.theme_type, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c12rec.theme_type );
          end if;
         end loop;
       end if;
       tmp := tmp || htf.formselectclose;
       htp.tabledata( tmp,cattributes=>pfx.qcbground );
      htp.tablerowclose;

      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.CST_TXT_235),cattributes=>pfx.qbground );
       tmp := htf.formselectopen( 'P6' );
       if c11rec.limit_laf = 'T'
        then
         for c3rec in c3(owner_id) loop
          if c1rec.theme_name = c3rec.theme_name
           then
            tmp := tmp || htf.formselectoption( c3rec.theme_name, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c3rec.theme_name );
          end if;
         end loop;
        else
         for c10rec in c10(owner_id) loop
          if c1rec.theme_name = c10rec.theme_name
           then
            tmp := tmp || htf.formselectoption( c10rec.theme_name, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c10rec.theme_name );
          end if;
         end loop;
       end if;
       tmp := tmp || htf.formselectclose;
       htp.tabledata( tmp,cattributes=>pfx.qcbground );
      htp.tablerowclose;
      htp.formhidden( 'P7', NULL );
      htp.formhidden( 'P8', NULL );
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.GLB_TXT_078),cattributes=>pfx.qbground );
       htp.tabledata( htf.italic(to_char( nvl(c1rec.date_created,sysdate),LNG.MASK)),cattributes=>pfx.qcbground );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.PHG_TXT_174),cattributes=>pfx.qbground );
       if c1rec.aid = 0
        then
         open c4( owner_id );
         fetch c4 into c4rec;
         close c4;
         htp.tabledata( htf.italic(to_char( sysdate + c4rec.days_to_expire,LNG.MASK)),cattributes=>pfx.qcbground );
        else
         htp.tabledata( htf.italic(to_char( c1rec.date_expires,LNG.MASK)),cattributes=>pfx.qcbground );
       end if;
      htp.tablerowclose;
htp.tableclose;
htp.nl;

-- If Plan Charge is EVENT then
 if (c8rec.payment_style = 'EVENT') and (acid = '0')
  then

   htp.nl;
   htp.bold( LNG3.ADM_TXT_786 );
   htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground );
     htp.tabledata( LNG3.ADM_TXT_787,cattributes=>pfx.qbground );
     htp.tabledata( LNG.LAB_TXT_039,cattributes=>pfx.qbground );
     htp.tabledata( LNG3.ADM_TXT_788,cattributes=>pfx.qbground );
     htp.tabledata( LNG3.ADM_TXT_111,cattributes=>pfx.qbground );
     htp.tabledata( LNG.PHG_ALT_399,cattributes=>pfx.qbground );
     -- htp.tabledata( LNG3.ADM_TXT_791 );
    htp.tablerowclose;
   foundrec := FALSE;
   for c14rec in c14(c8rec.plan_id,owner_id) loop
    htp.tablerowopen;
     if c14rec.qty > 0
      then
       if not foundrec
        then
         foundrec := TRUE;
         htp.tabledata( htf.formradio( 'EVENT_TO_USE', c14rec.plan_event, 'CHECKED'), cattributes=>pfx.qcbground );
        else
         htp.tabledata( htf.formradio( 'EVENT_TO_USE', c14rec.plan_event), cattributes=>pfx.qcbground );
       end if;
      else
       htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground );
     end if;
     htp.tabledata( c14rec.plan_event,cattributes=>pfx.qcbground );
     htp.tabledata( c14rec.qty,cattributes=>pfx.qcbground );
     open c15(c8rec.plan_id,c14rec.plan_event);
     fetch c15 into c15rec;
     close c15;
     htp.tabledata( c15rec.images_max,cattributes=>pfx.qcbground );
     htp.tabledata( c15rec.days_expires,cattributes=>pfx.qcbground );
     htp.tabledata( to_char(c15rec.standard_charge,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground );
    htp.tablerowclose;
   end loop;
   open c16(owner_id);
   fetch c16 into theme_rec2;
   close c16;
   if not foundrec
    then
     htp.init;
     glbx.main_title(surl, LNG.PHG_TXT_163,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,null,ltype),helpid=>'P01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
     -- glbx.header_msg( LNG4.AHC_TXT_279 );
     htp.header( 2, LNG4.AHC_TXT_279, 'CENTER', cattributes=>'STYLE="font-family: ' || pfx.instruct_text_font || '; color: #FF0000"' );
     if substr( theme_rec2.theme_data,374,1) = 'T'
      then
       htp.anchor('pbk.increase_event_plan?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_557, cattributes=>'STYLE="font-family: ' || pfx.instruct_text_font || '; color: #FF0000"');
     end if;
     htp.htmlclose;
     return;
   end if;
   htp.tableclose;
   htp.nl;
   if substr( theme_rec2.theme_data,374,1) = 'T'
    then
     htp.nl;
     htp.anchor('pbk.increase_event_plan?surl=' || glbx.rndsurl(surl),LNG4.AHC_TXT_557);
     htp.nl;
     htp.nl;
   end if;
end if;

htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
htp.tablerowopen;
if profid is null
 then
  if c1rec.aid = '0'
   then
     htp.tabledata(htf.formsubmit( 'ACTION',LNG.GLB_TXT_074));
    else
     htp.tabledata(htf.formsubmit( 'ACTION',LNG.PHG_BUT_114));
     htp.tabledata(htf.formsubmit( 'ACTION',LNG.GLB_BUT_042));
  end if;
 else
  if profid = '0'
   then
     htp.tabledata(htf.formsubmit( 'ACTION',LNG.PHG_TXT_066));
    else
     htp.tabledata(htf.formsubmit( 'ACTION',LNG.PHG_TXT_090));
     htp.tabledata(htf.formsubmit( 'ACTION',LNG4.AHC_TXT_641));
  end if;
 end if;
 htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 if c11rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
  then
   if substr(theme_rec.theme_data,137,1) = 'T'
    then
     htp.anchor( 'cst.cust_contact?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&profid=' || profid,LNG2.PFM_TXT_103 );
   end if;
 end if;
 if profid <> '0'
  then
   htp.nl;
   htp.nl;
   htp.anchor('pbk.delete_profile?surl=' || glbx.rndsurl(surl) || '&acid=' || c1rec.aid || '&profid=' || profid,'.' || LNG4.AHC_TXT_438);
 end if;
 htp.p('</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_ACCT_DETAILS',owner_id,c1rec.aid,errmsg=>sqlerrm,extdet=>msg);
end phg_acct_details;

procedure customer_logon(surl in varchar2, acid in integer, login_type in varchar2 DEFAULT 'OWNER', profid in integer default NULL)
as

 cursor c1(phgid integer, acid integer) is select 'x' from customer_account where aid=acid and pid=phgid;
 cursor c2(ltype varchar2, acid integer) is select * from customer_contact where login_type = ltype and aid = acid;
 cursor c3(ltype varchar2, acid integer) is
  select sessid
  from login_session
  where login_type = ltype and
        aid = acid
  order by date_created desc;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 newsurl	varchar2(100);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 id		integer;
 lsess		integer;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.CUSTOMER_LOGON', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1(owner_id,acid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( LNG.PHG_TXT_175 || acid );
   return;
 end if;
 close c1;

 -- select s_login_session.nextval into id from dual;
 id := glbx.get_random_sessionid;
 newsurl := rpad(to_char(id),12,'Z') || glbx.randstring;

 -- Get the last login_session
 if profid is null
  then
   open c3( login_type, acid );
   fetch c3 into lsess;
   close c3;
  else
   open c3( login_type, profid );
   fetch c3 into lsess;
   close c3;
 end if;

   if login_type = 'OWNER'
    then
      open c2(login_type,acid);
      fetch c2 into c2rec;
      close c2;
      insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr, browser, ip_address, securl, guest_email,country,previous_sessid, calling_sessid)
      values (stype,'OWNER', id, acid, sysdate, sysdate, 1, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), owa_util.get_cgi_env( 'REMOTE_ADDR'),newsurl, c2rec.contact_email, c2rec.sendto_country,lsess, to_number(replace(substr(surl,1,12),'Z','')) );
    elsif login_type = 'PROFILE'
     then
      open c2(login_type,profid);
      fetch c2 into c2rec;
      close c2;
      insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr, browser, ip_address, securl, guest_email,country,previous_sessid, calling_sessid)
      values (stype,'PROFILE', id, profid, sysdate, sysdate, 1, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), owa_util.get_cgi_env( 'REMOTE_ADDR'),newsurl, c2rec.contact_email, c2rec.sendto_country,lsess, to_number(replace(substr(surl,1,12),'Z','')) );
    elsif login_type = 'VIRTUAL'
     then
      open c2(login_type,acid);
      fetch c2 into c2rec;
      close c2;
      insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr, browser, ip_address, securl, event_id, guest_email,country,previous_sessid, calling_sessid)
      values (stype,'VIRTUAL', id, acid, sysdate, sysdate, 1, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), owa_util.get_cgi_env( 'REMOTE_ADDR'),newsurl,profid, c2rec.contact_email, c2rec.sendto_country,lsess, to_number(replace(substr(surl,1,12),'Z','')) );
    else
      open c2(login_type,acid);
      fetch c2 into c2rec;
      close c2;
      insert into login_session(screen_type,login_type,sessid,aid,date_created,date_updated,call_ctr, browser, ip_address, securl, guest_email,country,previous_sessid, calling_sessid)
      values (stype,'CUSTOMER', id, acid, sysdate, sysdate, 1, substr(owa_util.get_cgi_env( 'HTTP_USER_AGENT'),1,100), owa_util.get_cgi_env( 'REMOTE_ADDR'),newsurl, c2rec.contact_email, c2rec.sendto_country,lsess, to_number(replace(substr(surl,1,12),'Z','')) );
   end if;
   commit;

 -- Merge the Lightbox from the Old Session
 -- Remember if they are logging in, then old session lightbox results might be merged in from the login routine
 if login_type in ('PHOTOGRAPHER','OWNER','PROFILE')
  then
   update lightbox
    set    sessid = id
    where  sessid = lsess;

   -- Change the Shopping Basket
   --update purchase_order
   -- set   sessid = id
   -- where sessid = lsess;

   -- Remove duplicate entries
   delete from lightbox lb
   where lb.rowid > (select min(lbx.rowid)
                     from lightbox lbx
                     where lbx.umo_id = lb.umo_id
                      and  lbx.sessid = lb.sessid ) and
          sessid = id;
 end if;
 commit;

 cst.screen_sze(newsurl);

exception when others then
 glbx.error_details( 'PHG', 'CUSTOMER_LOGON',owner_id,acid,errmsg=>sqlerrm);
end customer_logon;

procedure phg_photo_add( surl in varchar2, acid in integer, a1 in myarray )
as

 cursor c1(phgid integer,acid integer) is select * from customer_account where aid = acid and pid = phgid;
 cursor c2 is select film_size from film_sizes;
 cursor c3(ttype varchar2) is select film_type from film_types where theme_type = ttype;
 cursor c4(vpid integer) is select object_access from photographer where pid = vpid;
 cursor c5(v_category varchar2, v_owner_id integer) is
 select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;
 cursor c6(acid integer, trg char) is select count('x') tot from customer_meta_data_group where aid = acid and target_area = trg;

 c1rec		c1%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 tmp		varchar2(4000);
 ltype		varchar2(100);
 thmb_qual	varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 fnm		varchar2(4000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PHOTO_ADD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 theme_rec := get_theme_types( surl,acid );

 -- Check if any categories exist. If not images cannot be uploaded
 begin tmp := ump.retrieve_scenes(surl,acid, 'OWNER', c1rec.scene_name, owner_id, null, null, display_style=>'LIST' ); exception when others then tmp := 'x'; end; -- in case the return list is greater than 32K
 if tmp is null
  then
   glbx.main_title(surl, null,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P11',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   glbx.header_msg( LNG4.AHC_TXT_274 );
   return;
 end if;
 glbx.main_title(surl, LNG.PHG_TXT_183,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P11',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );

 -- Does a Specialised Meta Data Upload Screen Exist?
 open c6(acid, 'I');
 fetch c6 into c6rec;
 close c6;
 if c6rec.tot > 0
  then
   meta_img_load( surl, acid, stype, ltype, c1rec, pfx, theme_rec, 'I' );
   return;
 end if;

 htp.header(4,LNG.PHG_TXT_372,'CENTER');
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.tload', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_338),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'RID', 10, 20, LNG2.FNM_TXT_004),cattributes=>pfx.qcbground);
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_360),cattributes=>pfx.qcbground );
   tmp := htf.formselectopen( 'FSZ' );
   for c2rec in c2 loop
    tmp := tmp || htf.formselectoption( c2rec.film_size );
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tabledata( tmp,cattributes=>pfx.qcbground);
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_356),cattributes=>pfx.qcbground );
   tmp := NULL;
   for c3rec in c3(c1rec.theme_type) loop
    tmp := tmp || htf.formselectoption( c3rec.film_type );
   end loop;
   if tmp is null then tmp := htf.formselectoption( LNG.ORD_TXT_194 ); end if;
   tmp := htf.formselectopen( 'FTY' ) || tmp || htf.formselectclose;
   htp.tabledata( tmp,cattributes=>pfx.qcbground);
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_217),cattributes=>pfx.qcbground );
   tmp := htf.formselectopen( 'CMP' ) || htf.formselectoption( LNG.PHG_ALT_427 );
   tmp := tmp || htf.formselectoption( LNG.PHG_TXT_308,'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_309 ) || htf.formselectoption( LNG.PHG_TXT_310 );
   tmp := tmp || htf.formselectclose;
   htp.tabledata( tmp,cattributes=>pfx.qcbground);
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_324),cattributes=>pfx.qcbground );
   thmb_qual := glbx.userpref( owner_id, acid, 'SUPER_THB' );
   /*
   tmp := htf.formselectopen( 'THCMP' );
   for j in 1..8 loop
    if to_char(j) = thmb_qual
     then
      tmp := tmp || htf.formselectoption( to_char(j), 'SELECTED' );
     else
      tmp := tmp || htf.formselectoption( to_char(j) );
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   */
   htp.tabledata( glbx.quality_loop( 'THCMP', thmb_qual ), cattributes=>pfx.qcbground);
  htp.tablerowclose;
  if substr(theme_rec.theme_data,65,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG2.PFM_TXT_043),cattributes=>pfx.qcbground );
     htp.tabledata( htf.formcheckbox( 'KMS', 'T' ),cattributes=>pfx.qcbground);
    htp.tablerowclose;
   else
    htp.formhidden( 'KMS', null );
  end if;

  open c4(owner_id);
  fetch c4 into c4rec;
  close c4;
  if length(replace(c4rec.object_access,'F',NULL)) > 1
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_415),cattributes=>pfx.qcbground );
     htp.p( '<TD ' || pfx.qcbground || '>' );
     htp.p( htf.formselectopen( 'KMX' ));
     if substr(c4rec.object_access,1,1) = 'T' or substr(c4rec.object_access,1,5) = 'FFFFF'
      then
       htp.formselectoption( 'PHOTO','SELECTED' );
     end if;
     if substr(c4rec.object_access,2,1) = 'T'
      then
       htp.formselectoption( 'DOCUMENT' );
     end if;
     if substr(c4rec.object_access,3,1) = 'T'
      then
       htp.formselectoption( 'AUDIO' );
     end if;
     if substr(c4rec.object_access,4,1) = 'T'
      then
       htp.formselectoption( 'VIDEO' );
     end if;
     if substr(c4rec.object_access,5,1) = 'T'
      then
       htp.formselectoption( 'RELATIONAL' );
     end if;
     if substr(c4rec.object_access,6,1) = 'T'
      then
       htp.formselectoption( 'BLUEPRINT' );
     end if;
     htp.formselectclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
   else
    if substr(c4rec.object_access,1,1) = 'T' or substr(c4rec.object_access,1,5) = 'FFFFF' then htp.formhidden( 'KMX', 'PHOTO' );
    elsif substr(c4rec.object_access,2,1) = 'T' then htp.formhidden( 'KMX', 'DOCUMENT' );
    elsif substr(c4rec.object_access,3,1) = 'T' then htp.formhidden( 'KMX', 'AUDIO' );
    elsif substr(c4rec.object_access,4,1) = 'T' then htp.formhidden( 'KMX', 'VIDEO' );
    elsif substr(c4rec.object_access,5,1) = 'T' then htp.formhidden( 'KMX', 'RELATIONAL' );
    elsif substr(c4rec.object_access,6,1) = 'T' then htp.formhidden( 'KMX', 'BLUEPRINT' );
    end if;
  end if;
 htp.tableclose;

 -- tmp := htf.formselectopen( 'SCNM' ) || ump.retrieve_scenes(surl,acid, 'OWNER', c1rec.scene_name, owner_id, null, null ) || htf.formselectclose;
 htp.formsubmit( 'ACTION', LNG.PHG_TXT_185 );
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_042),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.PHG_TXT_153),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.PHG_TXT_184),cattributes=>pfx.qbground );
 htp.tablerowclose;
 for j in 1..20 loop
  htp.tablerowopen;
    -- htp.tabledata( tmp,cattributes=>pfx.qcbground );
    htp.p( '<TD ' || pfx.qcbground || '>' );
    htp.formselectopen( 'SCNM' );
   -- tmp := ump.retrieve_scenes(surl,acid, 'OWNER', c1rec.scene_name, owner_id, null, null, display_style=>'LISTALL' );
       for c5rec in c5(c1rec.scene_name,owner_id) loop
        htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c5rec.parent_scene),pfx.nested_scene_delim) || c5rec.title, cattributes=>'VALUE="' || c5rec.umo_scene_id || '"' );
       end loop;
      htp.formselectclose;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'PNAME', 20, 100 ),cattributes=>pfx.qcbground );
    /*
    -- In a future version browsers will/might support this feature.
    if a1.exists(j+1)
     then
      fnm := a1(j+1);
     else
      fnm := NULL;
    end if;
    */
    htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>pfx.qcbground );
   htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.PHG_TXT_185 );
 -- htp.formsubmit( 'ACTION', LNG.PHG_TXT_212 ); -- Not used until there is Browser support for it
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PHOTO_ADD',owner_id,acid,errmsg=>sqlerrm);
end phg_photo_add;

procedure tload(surl in varchar2, acid in integer, file in myarray, pname in myarray, scnm in myarray, rid in varchar2, fsz in varchar2, fty in varchar2, cmp in varchar2, kms in varchar2 default 'F', kmx in varchar2 default 'PHOTO', action in varchar2, thcmp in varchar2 default 'STANDARD')
as

 cursor c1(phgr integer) is
  select max_photo_size * 1024
  from charge_plan cp, photographer ph
  where ph.pid = phgr and
        ph.plan_id = cp.id;

 -- Note: umo_type forces the use of i_umo_5 for scalability
 cursor c2(acid integer) is select nvl(max(um.extras.orderby_nmb),0) + 1 from umo um where um.aid = acid and umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT');

 last_file	varchar2(1000);
 new_photo	integer;
 ctr		integer;
 bad_ctr	integer;
 new_photos	LISTINT;
 bad_photos	MYARRAY;
 ltype		varchar2(100);
 stype		integer;
 pid		integer;
 new_id		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 parm1		ump.parameters;
 parm2		ump.parameters;
 newid_arr	ump.myarray_int;
 retval		varchar2(1000);
 fname		varchar2(100);
 jctr		integer;
 maxphoto	integer;
 maxnmb		integer;

begin
 glbx.cookie_id( surl, stype, ltype, pid, sts, progcalled=>'PHG.TLOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 ctr := 1;
 bad_ctr := 0;
 new_photos(0) := 0;
 open c1(pid);
 fetch c1 into maxphoto;
 close c1;

 for j in file.first..file.last loop
  if file(j) is not null and
     ((instr(file(j),'/') > 0) or
      (instr(file(j),'\') > 0)
      )-- added test for 10g issue
   then
       last_file := file(j);
       parm1(1)  := 'AID';
       parm2(1)  := to_char(acid);
       parm1(2)  := 'OBJECT_TYPE';
       parm2(2)  := kmx;
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'UPLOAD';
       parm1(4)  := 'FILE_NAME';
       parm2(4)  := file(j);
       parm1(5)  := 'STORE_ORIGINAL';
       if kms = 'T'
        then
         parm2(5)  := 'TRUE';
        else
         parm2(5)  := 'FALSE';
       end if;
       parm1(6)  := 'CREATE_THUMBNAIL';
       parm2(6)  := 'TRUE';
       parm1(7) := 'KEEP_STATUS';
       parm2(7) := 'KEEP';
       parm1(8) := 'ORIGINAL_LOCATION';
       parm2(8) := file(j);
       parm1(9) := 'PARENT_UMO_ID';
       parm2(9) := NULL;
       parm1(10) := 'SCENE_ID';
       parm2(10) := scnm(j);
       parm1(11) := 'UMO_OWNER';
       parm2(11) := 'PHOTOGRAPHER';
       parm1(12) := 'BYPASS_QUOTA_CHECK';
       parm2(12) := 'FALSE';
       parm1(13) := 'PHGR_ID';
       parm2(13) := to_char(pid);
       parm1(14) := 'OWS_NAME';
       parm2(14) := file(j);
       parm1(15) := 'ROLL_ID';
       parm2(15) := rid;
       parm1(16) := 'FILM_SIZE';
       parm2(16) := fsz;
       parm1(17) := 'FILM_TYPE';
       parm2(17) := fty;
       parm1(18) := 'FILM_NAME';
       fname := pname(j);
       if fname is null
        then
         fname := glbx.extract_fname(file(j),'NO_EXTENSION',100);
       end if;
       parm2(18) := fname;
       parm1(19) := 'THUMBNAIL_WIDTH';
       parm2(19) := nvl(glbx.photo_pref(pid,acid,'THUMBNAIL_WIDTH'),'100');
       parm1(20) := 'PHOTOGRAPHER';
       parm2(20) := 'TRUE';
       parm1(21) := 'NAME';
       parm2(21) := fname;
       parm1(22) := 'PHOTO ALBUM';
       parm2(22) := 'FALSE';
       parm1(23) := 'BRIDAL';
       parm2(23) := 'TRUE';
       parm1(24) := 'QUALITY';
       parm2(24) := 'STANDARD';
       parm1(25) := 'COMPRESSION';
       parm2(25) := cmp;
       parm1(26) := 'CONVERT_TO';
       parm2(26) := 'JPEG';
       parm1(27) := 'THUMBNAIL_QUALITY';
       parm2(27) := thcmp;
       parm1(28) := 'PHOTOGRAPHER_QUOTA';
       parm2(28) := to_char(maxphoto);
       open c2( acid );
       fetch c2 into maxnmb;
       close c2;
       parm1(29) := 'NEG_NO';
       parm2(29) := to_char( maxnmb );
       retval := NULL;

       ump.load_uma(surl,parm1,parm2,retval,newid_arr );
       -- If an error occurs on load then ignore it,note it and continue on.
       if retval is not null
         then
           bad_ctr := bad_ctr + 1;
           bad_photos( bad_ctr ) := file(j) || '-' || retval;
         else
          if newid_arr.exists(1) then new_id := newid_arr(1); end if;
          if newid_arr.count > 0
           then
            for k in newid_arr.first..newid_arr.last loop
             new_photos( ctr ) := newid_arr(k);
             ctr := ctr + 1;
            end loop;
          end if;
       end if;

   end if;
  end loop;

  -- Display the Newly Loaded Photo's
  pfx := glbx.get_thm( acid );
  glbx.main_title( surl, LNG.PHG_TXT_186,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P28',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

  if bad_ctr > 0
   then
    htp.nl;
    htp.header( 3,LNG.PHG_ALT_429, 'PHG_LEFT' );
    for j in bad_photos.first..bad_photos.last loop
     htp.p( bad_photos(j) ); htp.nl;
    end loop;
    htp.nl;
    htp.htmlclose;
    return;
  end if;
  disp_new_photos( surl, acid, new_photos );
exception when others then
 --owa_content.delete_document( last_file );
 glbx.error_details( 'PHG', 'TLOAD',pid,acid,errmsg=>sqlerrm);
end tload;

procedure disp_new_photos( surl in varchar2, acid in integer, new_photos in LISTINT )
as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;

 c1rec		c1%ROWTYPE;
 result_list	UMP.SEARCH_RESULT_PHG;
 ctr		integer;

begin
 ctr := 1;
 for j in 1..new_photos.last loop
  if new_photos(j) <> 0
   then
    open c1(new_photos(j));
    fetch c1 into c1rec;
    close c1;
    result_list(ctr) := c1rec;
    ctr := ctr + 1;
  end if;
 end loop;
 glbx.extended_search_api( surl=>surl, ltype=>'PHOTOGRAPHER', result_list=>result_list, search_total=>new_photos.count,
                            display_detail=>NULL, title=>LNG4.AHC_TXT_698,
                            left_api=>NULL, left_api_parm=>NULL, footer_api=>'cst.disp_category',
                            current_page_number=>1,no_results_message=>LNG4.AHC_TXT_411,acid=>acid);

exception when others then
 glbx.error_details( 'PHG', 'DISP_NEW_PHOTOS',vaid=>acid,errmsg=>sqlerrm);
end disp_new_photos;

procedure phg_disp_by_scene_fm( surl in varchar2, acid in integer, scnm in varchar2 )
as

 cursor c1(phgid integer, acid integer) is select * from customer_account where aid = acid and pid = phgid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(200);
 owner_id	integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_DISP_BY_SCENE_FM', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 open c1(owner_id,acid);
 fetch c1 into c1rec;
 if c1%NOTFOUND then close c1; return; end if;
 close c1;
 if scnm = 'STORE'
  then
  cst.disp_store( surl=>glbx.rndsurl(surl), left_api_parm=>null, start_from=>1, display_detail=>NULL, acid=>acid );
 elsif scnm = 'LIGHT'
  then
  cst.disp_lightbox( surl=>glbx.rndsurl(surl), left_api_parm=>null, start_from=>1, display_detail=>NULL, acid=>acid );
 else
  cst.disp_category( surl=>glbx.rndsurl(surl), left_api_parm=>scnm, start_from=>1, display_detail=>NULL, acid=>acid );
 end if;

exception when others then
 glbx.error_details( 'PHG', 'PHG_DISP_BY_SCENE_FM',errmsg=>sqlerrm,extdet=>scnm);
end phg_disp_by_scene_fm;

procedure photo_fast_edit_acct_mst(surl in varchar2,acid in integer, mwidth in integer default 0, typ in varchar2 default 'SCENE', typval in varchar2 default null, mctr in integer default null, stype in integer default 1)
as
begin
 htp.htmlopen;
 htp.framesetopen(glbx.sctrl(glbx.fndtheme( null, acid ),'PHOTO_FAST_TOP',stype),'100%',cattributes=>'frameborder="1" framespacing="0" border="1"');
 htp.frame( 'phg.photo_fast_edit_top?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mwidth || '&typ=' || typ,'PHOTO_TOP');
 htp.frame( 'phg.photo_fast_edit_acct_medium?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mwidth || '&typval=' || translate(typval,' ','+') || '&typ=' || typ || '&mctr=' || mctr ||'&stype=' || stype,'PHOTO_MEDIUM');
 htp.framesetclose;
  htp.p( '<BODY>' );
 htp.noframesopen;
   glbx.noframe(surl,'PHG.PHOTO_FAST_EDIT_ACCT_MST');
 htp.noframesclose;
  htp.p( '</BODY>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHOTO_FAST_EDIT_ACCT_MST',vaid=>acid,errmsg=>sqlerrm);
end photo_fast_edit_acct_mst;

procedure photo_fast_edit_acct_medium(surl in varchar2, acid in integer, mwidth in integer default 0, typ in varchar2 default 'SCENE', typval in varchar2 default null, mctr in integer default null, stype in integer default 1)
as

 sts		varchar2(200);
 ltype		varchar2(100);
 xstype		integer;
 owner_id	integer;
 def		varchar2(100);
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, xstype, ltype, owner_id, sts, 'S', progcalled=>'PHG.PHOTO_FAST_EDIT_ACCT_MEDIUM', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 theme_rec := get_theme_types( surl, acid );
 htp.htmlopen;
 htp.framesetopen(glbx.sctrl(glbx.fndtheme( owner_id, acid ),'PHOTO_FAST_MED',stype),'100%',cattributes=>'frameborder="1" framespacing="0" border="1"');
 htp.frame( 'phg.photo_fast_edit_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mwidth || '&typ=' || typ || '&typval=' || translate(typval,' ','+') || '&mctr=' || mctr,'PHOTO_MIDDLE');
 --
 -- Determine Default Scene
 --
 if typ = 'SCENE'
  then
   def := 'SCENE';
   -- Make sure the default is not being overwritten
   -- 61 (Edit Categories) 112 (Film Roll) 113 (Load Id) 114 (Large Rotate) 115 (Linked) 89 (Meta Data)
   if substr(theme_rec.theme_data,61,1) = 'T'
    then
     def := 'SCENE';
   elsif substr(theme_rec.theme_data,112,1) = 'T'
    then
     def := 'ROLL';
   elsif substr(theme_rec.theme_data,113,1) = 'T'
    then
     def := 'PHOTO';
   elsif substr(theme_rec.theme_data,114,1) = 'T'
    then
     def := 'MASS';
   elsif substr(theme_rec.theme_data,115,1) = 'T'
    then
     def := 'LINK';
   elsif substr(theme_rec.theme_data,89,1) = 'T'
    then
     def := 'META';
   end if;
 end if;
 htp.frame( 'phg.photo_fast_edit_bottom?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mwidth || '&typ=' || nvl(def,typ),'PHOTO_BOTTOM');
 htp.framesetclose;
  htp.p( '<BODY>' );
 htp.noframesopen;
   glbx.noframe(surl,'PHG.PHOTO_FAST_EDIT_ACCT_MEDIUM');
 htp.noframesclose;
  htp.p( '</BODY>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHOTO_FAST_EDIT_ACCT_MEDIUM',vaid=>acid,errmsg=>sqlerrm);
end photo_fast_edit_acct_medium;

procedure photo_fast_edit_top(surl in varchar2,acid in integer, mwidth in integer default 0, typ in varchar2 default 'SCENE')
as

 sts		varchar2(200);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 mxwidth	integer;
 tmp		varchar2(2000);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 cprog		boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHOTO_FAST_EDIT_TOP', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if mwidth = 0
  then
   mxwidth := glbx.sctrl(pfx.theme_name,'PROOF_HORIZONTAL',stype);
  else
   mxwidth := mwidth;
 end if;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, null,glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>greatest(stype-1,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 cprog := TRUE;
 htp.p( '<CENTER>' );
 tmp := ' ';
 for j in 1..8 loop
  if j = mxwidth
   then
    tmp := tmp || j || htf.formradio( 'mwidth', j, 'CHECKED' );
   else
    tmp := tmp || j || htf.formradio( 'mwidth', j );
  end if;
 end loop;
 htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 align="LEFT"');
  htp.tablerowopen;
   htp.p( '<TD VALIGN="TOP">' );
    htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=0');
     htp.tablerowopen;
      htp.tabledata( LNG.PHG_ALT_391, cattributes=>'valign="TOP"' );
      if substr(theme_rec.theme_data,61,1) = 'T'
       then
        htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=SCENE&stype=' || stype || '&mwidth=' || mwidth, htf.img( DECS.IMAGE_LOCATION || 'admin/view_scn.gif',cattributes=>'border=0',calt=>LNG.CST_TXT_042) ,ctarget=>'PHG_RIGHT' ),cattributes=>'valign="TOP"');
      end if;
      if substr(theme_rec.theme_data,112,1) = 'T'
       then
         htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=ROLL&stype=' || stype || '&mwidth=' || mwidth, htf.img( DECS.IMAGE_LOCATION || 'admin/view_roll.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_394) ,ctarget=>'PHG_RIGHT' ),cattributes=>'valign="TOP"');
      end if;
      if substr(theme_rec.theme_data,113,1) = 'T'
       then
        htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=PHOTO&stype=' || stype || '&mwidth=' || mwidth, htf.img( DECS.IMAGE_LOCATION || 'admin/view_load.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_395) ,ctarget=>'PHG_RIGHT' ),cattributes=>'valign="TOP"');
      end if;
      if substr(theme_rec.theme_data,114,1) = 'T' and cprog
       then
        htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=MASS&stype=' || stype || '&mwidth=' || mwidth, htf.img( DECS.IMAGE_LOCATION || 'admin/view_rot.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_484) ,ctarget=>'PHG_RIGHT' ),cattributes=>'valign="TOP"');
      end if;
      if substr(theme_rec.theme_data,375,1) = 'T'
       then
        htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=NMB&stype=' || stype || '&mwidth=' || mwidth, htf.img( DECS.IMAGE_LOCATION || 'admin/view_nmb.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_582) ,ctarget=>'PHG_RIGHT' ),cattributes=>'valign="TOP"');
      end if;
      if substr(theme_rec.theme_data,115,1) = 'T'
       then
        htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=LINK&stype=' || stype || '&mwidth=' || mwidth, htf.img( DECS.IMAGE_LOCATION || 'admin/view_link.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_528) ,ctarget=>'PHG_RIGHT' ),cattributes=>'valign="TOP"');
      end if;
      if substr(theme_rec.theme_data,89,1) = 'T'
       then
        htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=META&stype=' || stype || '&mwidth=' || mwidth, htf.img( DECS.IMAGE_LOCATION || 'admin/view_met.gif',cattributes=>'border=0',calt=>LNG5.EXT_TXT_115) ,ctarget=>'PHG_RIGHT' ),cattributes=>'valign="TOP"');
      end if;
     htp.tablerowclose;
    htp.tableclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formopen( 'phg.photo_fast_edit_acct_mst', ctarget=>'PHG_RIGHT' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) || htf.formhidden( 'TYP', typ )  || htf.formhidden( 'STYPE', stype ) ||
   htf.formsubmit(null, LNG.PHG_ALT_392 ) || tmp || htf.formclose, cattributes=>'valign="TOP"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHOTO_FAST_EDIT_TOP',vaid=>acid,errmsg=>sqlerrm);
end photo_fast_edit_top;

procedure photo_fast_edit_bottom(surl in varchar2,acid in integer, mwidth in integer default 0, typ in varchar2 default 'SCENE')
as
 cursor c1a(v_category varchar2, v_owned_by varchar2, v_owner_id integer, v_parent_id integer, v_phgr integer) is
  select distinct usc.order_by,usc.title,usc.umo_scene_id
  from umo um, umo_scene usc
  where um.umo_scene_id = usc.umo_scene_id and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT') and
        um.aid = v_owner_id and
        category = v_category
  order by order_by;

 cursor c1b( acid integer, phgid integer ) is
  select distinct nvl(um.extra_roll_id,LNG2.FNM_TXT_004) roll_id
  from umo um
  where um.aid = acid and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT') and
        aid in (select aid from customer_account where pid = phgid and aid = acid)
  order by roll_id;

 cursor c1c( acid integer, phgid integer ) is
  select nvl(count('x'),0) tot_id
  from umo um
  where aid = acid and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT') and
        aid in (select aid from customer_account where pid = phgid and aid = acid)
  order by umo_id;

 cursor c2(acid integer, phgid integer) is select scene_name,background_img from customer_account where aid=acid and pid = phgid;
 cursor c3(uscid integer) is select parent_scene from umo_scene where umo_scene_id = uscid;

 c3rec		c3%ROWTYPE;
 sts		varchar2(200);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 mxwidth	integer;
 dispwidth	integer;
 c2rec		c2%ROWTYPE;
 c1crec		c1c%ROWTYPE;
 j		integer;
 tmp		varchar2(1000);
 pfx		THEME%ROWTYPE;
 wnd		varchar2(20);
 wnd2		varchar2(20);
 newwin		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHOTO_FAST_EDIT_BOTTOM', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 if mwidth = 0
  then
   mxwidth := glbx.sctrl(pfx.theme_name,'PROOF_HORIZONTAL',stype);
  else
   mxwidth := mwidth;
 end if;
 glbx.main_title( surl, null,glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>greatest(stype-2,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 open c2(acid,owner_id);
 fetch c2 into c2rec;
 close c2;
 tmp := NULL;
 dispwidth := nvl(glbx.userpref(owner_id,acid,'PHOTO_DISPLAY'),GLBX.PHOTO_PROOF_DISPLAY);
 if dispwidth < 1 or dispwidth > 9999 then dispwidth := GLBX.PHOTO_PROOF_DISPLAY; end if;
 newwin := glbx.userpref(owner_id, acid, 'FAST_NEW' );
 if newwin = LNG.PHG_TXT_045
  then
   wnd2 := 'MASS_EDIT';
  else
   wnd2 := 'PHOTO_MIDDLE';
 end if;
 htp.tableopen(cattributes=>'cellpadding="1" cellspacing="1" border="0" width="100%"');
  htp.tablerowopen;
  if typ in ('SCENE','LINK','META')
   then
    for c1arec in c1a(c2rec.scene_name, 'OWNER', acid, null, owner_id ) loop
     open c3(c1arec.umo_scene_id);
     fetch c3 into c3rec;
     close c3;
     if mod(c1a%ROWCOUNT,3) = 1
      then
       tmp := htf.anchor2( 'phg.photo_fast_edit_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mxwidth || '&typ=' || typ || '&typval=' || c1arec.umo_scene_id || '&newwin=' || newwin,
              '<FONT SIZE="-1">' || '[' || lpad(pfx.nested_scene_delim, indnt(c3rec.parent_scene),pfx.nested_scene_delim) || c1arec.title || ']' || '</FONT>',ctarget=>wnd2);
     elsif mod(c1a%ROWCOUNT,3) = 2
      then
       tmp := tmp || htf.nl || htf.anchor2( 'phg.photo_fast_edit_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mxwidth || '&typ=' || typ || '&typval=' || c1arec.umo_scene_id || '&newwin=' || newwin,
              '<FONT SIZE="-1">' || '[' || lpad(pfx.nested_scene_delim, indnt(c3rec.parent_scene),pfx.nested_scene_delim) || c1arec.title || ']' || '</FONT>',ctarget=>wnd2);
      else
       htp.tabledata( tmp || htf.nl || htf.anchor2( 'phg.photo_fast_edit_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mxwidth || '&typ=' || typ || '&typval=' || c1arec.umo_scene_id || '&newwin=' || newwin,
                      '<FONT SIZE="-1">' || '[' || lpad(pfx.nested_scene_delim, indnt(c3rec.parent_scene),pfx.nested_scene_delim) || c1arec.title || ']' || '</FONT>',ctarget=>wnd2 ), cattributes=>'valign="TOP"');
       tmp := NULL;
     end if;
    end loop;
    if tmp is not null then htp.tabledata( tmp, cattributes=>'valign="TOP"' ); end if;
  elsif typ = 'ROLL'
   then
    for c1brec in c1b(acid, owner_id) loop
     htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mxwidth || '&typ=' || typ || '&typval=' || translate(c1brec.roll_id,' ','+') || '&newwin=' || newwin,
                    '<FONT SIZE="-1">' || '[' || c1brec.roll_id || ']' || '</FONT>',ctarget=>wnd2 ),cattributes=>' CLASS="SMALL"');
    end loop;
  elsif typ in ('PHOTO','MASS','MASSA','NMB')
   then
    c1crec.tot_id := 0;
    open c1c(acid,owner_id);
    fetch c1c into c1crec;
    close c1c;
    if typ in ('PHOTO','NMB')
     then
      wnd := 'PHOTO_MIDDLE';
     else
      wnd := 'MASS';
      mxwidth := mxwidth + 3;
    end if;
    for j in 1..trunc(c1crec.tot_id/dispwidth) loop
     htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mxwidth || '&typ=' || typ || '&typval=' || translate(j-1,' ','+') || '&newwin=' || newwin,
                   '<FONT SIZE="-1">' || '[' || to_char((j-1) * dispwidth + 1) || '-' || to_char( j*dispwidth ) || ']' || '</FONT>',ctarget=>wnd ),cattributes=>' CLASS="SMALL"');
    end loop;
    j := trunc(c1crec.tot_id/dispwidth);
    if (j*dispwidth) + mod(c1crec.tot_id,dispwidth) = 0
     then
      htp.tabledata( LNG.PHG_TXT_523 );
     else
      if (j*dispwidth + 1) <= (j*dispwidth) + mod(c1crec.tot_id,dispwidth)
       then
        htp.tabledata( htf.anchor2( 'phg.photo_fast_edit_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mwidth=' || mxwidth || '&typ=' || typ || '&typval=' || translate(j,' ','+') || '&newwin=' || newwin,
                      '<FONT SIZE="-1">' || '[' || to_char(j*dispwidth + 1) || '-' || to_char( (j*dispwidth) + mod(c1crec.tot_id,dispwidth) ) || ']' || '</FONT>',ctarget=>wnd, cattributes=>' CLASS="SMALL"' ));
      end if;
    end if;
  end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHOTO_FAST_EDIT_BOTTOM',vaid=>acid,errmsg=>sqlerrm);
end photo_fast_edit_bottom;

procedure photo_fast_edit_acct(surl in varchar2,acid in integer, mctr in integer default 1, mwidth in integer default 0, typ in varchar2 default 'SCENE', typval in varchar2 default null, newwin in varchar2 default LNG.PHG_TXT_046)
as

 cursor c2(v_category varchar2, v_owner_id integer) is
 select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;

 cursor c4a(acid integer, phgid integer, typval varchar2) is
  select um.umo_id,um.photo_thumbnail,um.extras.title title,um.umo_type, um.extras, um.version, um.photo_thumbnail.width width, um.photo_thumbnail.height height, um.extra_roll_id, um.extra_film_colour
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type = 'PHOTO' and
        um.aid = ca.aid and
	ca.pid = phgid and
	um.umo_scene_id = to_number(typval)
  order by um.umo_id;

 cursor c4b(acid integer, phgid integer, typval varchar2) is
  select um.umo_id,um.photo_thumbnail,um.extras.title title,um.umo_type,um.umo_scene_id, um.extras, um.version, um.photo_thumbnail.width width, um.photo_thumbnail.height height, um.extra_roll_id, um.extra_film_colour
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type = 'PHOTO' and
        um.aid = ca.aid and
	ca.pid = phgid and
	nvl(um.extra_roll_id,LNG2.FNM_TXT_004) = typval
  order by um.extras.orderby_scene, um.umo_id;

 cursor c4c(acid integer, phgid integer) is
  select um.umo_id,um.photo_thumbnail,um.extras.title title,um.umo_type,um.umo_scene_id, um.extras, um.version, um.photo_thumbnail.width width, um.photo_thumbnail.height height, um.extra_roll_id, um.extra_film_colour
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type = 'PHOTO' and
        um.aid = ca.aid and
	ca.pid = phgid
  order by um.umo_id;

 cursor c4at(acid integer, phgid integer, typval varchar2) is
  select count('x') tot
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type = 'PHOTO' and
        um.aid = ca.aid and
	ca.pid = phgid and
	um.umo_scene_id = to_number(typval)
  order by um.umo_id;

 cursor c4bt(acid integer, phgid integer, typval varchar2) is
  select count('x') tot
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type = 'PHOTO' and
        um.aid = ca.aid and
	ca.pid = phgid and
	nvl(um.extra_roll_id,LNG2.FNM_TXT_004) = typval
  order by um.extras.orderby_scene, um.umo_id;

 cursor c4ct(acid integer, phgid integer) is
  select count('x') tot
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type = 'PHOTO' and
        um.aid = ca.aid and
	ca.pid = phgid
  order by um.umo_id;

 cursor c3(acid integer, phgid integer) is select scene_name,background_img,theme_type from customer_account where aid=acid and pid = phgid;

 cursor c4(ttype varchar2) is select film_type from film_types where theme_type = ttype order by film_type;

 cursor c6(phgr integer, acid integer) is
  select umo_id,um.extras.photo_name photo_name
  from umo um
  where umo_type = 'WATERMARK' and
        aid in (select aid from customer_account where pid = phgr);

 cursor c7(v_umo integer) is
  select ul.weighting,ul.to_umo_id, um.extras.film_name film_name
  from umo um,umo_link ul
  where ul.umo_id = v_umo and
        ul.to_umo_id = um.umo_id
  order by weighting desc;

 v_umo		integer;
 tblob		ORDSYS.ORDIMAGE;
 c3rec		c3%ROWTYPE;
 res		boolean;
 roll_id	varchar2(100);
 title		varchar2(100);
 umo_type	varchar2(20);
 vsn		integer;
 scene_id	integer;
 photo_enabled	varchar2(20);
 photo_name	varchar2(100);
 sts		varchar2(200);
 tmp		varchar2(6000);
 tmp2		varchar2(2000);
 tmp3		varchar2(2000);
 tmp4		varchar2(1000);
 tmp5		varchar2(4000);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 fcolour	varchar2(100);
 ctr		integer;
 j		integer;
 tot		integer;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 rep_ext	REPEATED_FIELDS;
 mxwidth	integer;
 totphg		integer;
 dispwidth	integer;
 ck		varchar2(20);
 js		varchar2(1000);
 thewidth	integer;
 v_w		integer;
 v_h		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHOTO_FAST_EDIT_ACCT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if mwidth = 0
  then
   if stype = 1 then mxwidth := 2; elsif stype = 2 then mxwidth :=4; else mxwidth := 7; end if;
  else
   mxwidth := mwidth;
 end if;
 js := '
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
 var checkflag = "false";
 function check(field)
  {
     if (checkflag == "false")
     {
      for (i = 0; i < field.length; i++) {field[i].checked = true;}
       checkflag = "true";
       return "Uncheck All";
     }
  else
     {
      for (i = 0; i < field.length; i++) { field[i].checked = false;}
      checkflag = "false";
      return "Check All";
     }
  }
//  End -->
</script>
';

 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 dispwidth := nvl(glbx.userpref(owner_id,acid,'PHOTO_DISPLAY'),GLBX.PHOTO_PROOF_DISPLAY);
 if dispwidth < 1 or dispwidth > 9999 then dispwidth := GLBX.PHOTO_PROOF_DISPLAY; end if;
 open c3(acid,owner_id);
 fetch c3 into c3rec;
 close c3;
 if typval is null
  then
   glbx.main_title( surl, LNG.PHG_TXT_196,glbx.backimg(surl,acid,pfx.text_back,c3rec.background_img,ltype),helpid=>'P13',stype=>greatest(stype-4,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.nl;
   htp.p( '<CENTER>' );
   glbx.instruction( LNG.PHG_ALT_396, pfx );
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
  else
   glbx.main_title( surl, null,glbx.backimg(surl,acid,pfx.text_back,c3rec.background_img,ltype),stype=>greatest(stype-5,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet,jscript=>js);
 end if;
 htp.htmlopen;
 htp.p( '<CENTER>' );

 if typ in ('MASS','MASSA')
  then
   htp.title( LNG.PHG_TXT_011 );
   htp.formopen( 'phg.accept_fast_edit', ctarget=>'MASS' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');

 elsif typ = 'META'
  then
   if newwin = LNG.PHG_TXT_045
    then
     htp.formopen( 'phg.accept_fast_meta', ctarget=>'MASS_EDIT' );
    else
     htp.formopen( 'phg.accept_fast_meta', ctarget=>'PHG_RIGHT' );
   end if;
   htp.formhidden( 'SURL', glbx.rndsurl(surl));

 else
   if newwin = LNG.PHG_TXT_045
    then
     htp.formopen( 'phg.accept_fast_edit', ctarget=>'MASS_EDIT' );
    else
     htp.formopen( 'phg.accept_fast_edit', ctarget=>'PHG_RIGHT' );
   end if;
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   if typ = 'LINK'
    then
     htp.bold( LNG2.PBK_TXT_086 ); htp.nl; htp.nl;
   end if;
 end if;

 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'MCTR', mctr );
 htp.formhidden( 'A3', '0' );
 if typ = 'META'
  then
   htp.formhidden( 'ROT', '0' );
  else
   htp.formhidden( 'ROTA', '0' );
   htp.formhidden( 'ROTB', '0' );
   htp.formhidden( 'ROTC', '0' );
   htp.formhidden( 'ROTD', '0' );
   htp.formhidden( 'ROTE', '0' );
 end if;
 htp.formhidden( 'MWIDTH', mxwidth );
 htp.formhidden( 'NEWWIN', newwin );

 if typ = 'MASSA'
  then
   htp.formhidden( 'TYP', 'MASS' );
  else
   htp.formhidden( 'TYP', typ );
 end if;

 htp.formhidden( 'TYPVAL', typval );
 htp.formsubmit( null, LNG.PHG_TXT_197 );

 if typ in ('SCENE','LINK','META')
  then
    open c4at(acid,owner_id,typval);
    fetch c4at into totphg;
    close c4at;
  elsif typ = 'ROLL'
   then
    open c4bt(acid,owner_id,typval);
    fetch c4bt into totphg;
    close c4bt;
  elsif typ in ('PHOTO','MASS','MASSA','NMB')
   then
    open c4ct(acid,owner_id);
    fetch c4ct into totphg;
    close c4ct;
 end if;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
 if typ not in ('MASS','MASSA')
  then
   htp.tablerowopen;
     for k in 1..least(nvl(totphg,0),mxwidth) loop
      if typ = 'LINK'
       then
       		htp.tabledata(htf.bold( LNG2.PBK_TXT_068 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
       elsif typ in ('NMB','META')
        then
         null;
       else
	 if mxwidth = 1
	  then
     		htp.tabledata(htf.bold( LNG.PHG_TXT_199 || htf.nl || LNG.PHG_TXT_275 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     		htp.tabledata(htf.bold( LNG.GLB_TXT_064 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       		htp.tabledata(htf.bold( LNG.PHG_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       		htp.tabledata(htf.bold( LNG.PHG_TXT_338 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       		htp.tabledata(htf.bold( LNG.PHG_TXT_200 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       		htp.tabledata(htf.bold( LNG.PHG_TXT_202 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
	  else
       		htp.tabledata(htf.bold( LNG.PHG_TXT_201 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
	 end if;
      end if;
    end loop;
   htp.tablerowclose;
  else
    htp.formhidden( 'A1', '0' );
    htp.formhidden( 'A2', '0' );
    htp.formhidden( 'AR', '0' );
 end if;

 htp.tablerowopen;
 ctr := 0;
 j := 0;

 if typ in ('SCENE','LINK','META')
  then
   open c4a(acid,owner_id,typval);
 elsif typ = 'ROLL'
  then
   open c4b(acid,owner_id,typval);
 elsif typ in ('PHOTO','MASS','MASSA','NMB')
  then
   open c4c(acid,owner_id);
   thewidth := (typval*nvl(glbx.userpref(owner_id,acid,'PHOTO_DISPLAY'),GLBX.PHOTO_PROOF_DISPLAY));
   for j in 1..thewidth loop
    fetch c4c into v_umo, tblob, title, umo_type, scene_id, rep_ext, vsn, v_w, v_h, roll_id, fcolour;
    if c4c%NOTFOUND then close c4c; exit; end if;
   end loop;
 end if;

 loop
  if typ in ('SCENE','LINK','META')
   then
    fetch c4a into v_umo, tblob, title, umo_type, rep_ext, vsn, v_w, v_h, roll_id, fcolour;
    if c4a%NOTFOUND then close c4a; exit; end if;
    -- roll_id := ump.uma_attribute( surl,v_umo, umo_type, 'ROLL_ID' );
    photo_name := rep_ext.film_name;
    photo_enabled := rep_ext.enabled_phg;
    scene_id := to_number(typval);
  elsif typ = 'ROLL'
   then
    fetch c4b into v_umo, tblob, title, umo_type, scene_id, rep_ext, vsn, v_w, v_h, roll_id, fcolour;
    if c4b%NOTFOUND then close c4b; exit; end if;
    -- roll_id := ump.uma_attribute( surl,v_umo, umo_type, 'ROLL_ID' );
    photo_name := rep_ext.film_name;
    photo_enabled := rep_ext.enabled_phg;
  elsif typ in ('PHOTO','MASS','MASSA','NMB')
   then
    fetch c4c into v_umo, tblob, title, umo_type, scene_id, rep_ext, vsn, v_w, v_h, roll_id, fcolour;
    if c4c%NOTFOUND then close c4c; exit; end if;
    -- roll_id := ump.uma_attribute( surl,v_umo, umo_type, 'ROLL_ID' );
    photo_name := rep_ext.film_name;
    photo_enabled := rep_ext.enabled_phg;
    j := j + 1;
    if j > dispwidth then close c4c; exit; end if;
  end if;
  ctr := ctr + 1;
  htp.formhidden( 'A0', v_umo );
  if nvl(photo_enabled,'TRUE') = 'TRUE' then tmp3 := htf.formcheckbox( 'A3', v_umo, 'CHECKED' ); else tmp3 := htf.formcheckbox( 'A3', v_umo ); end if;

  if typ <> 'META'
   then
    --tmp := htf.formselectopen( 'A2' ) || ump.retrieve_scenes(surl,acid, 'OWNER', c3rec.scene_name, owner_id, null, scene_id ) || htf.formselectclose;
    /* tmp := htf.formselectopen( 'A2' );
     for c2rec in c2(c3rec.scene_name,owner_id) loop
      if c2rec.umo_scene_id = scene_id
       then
        tmp := tmp || htf.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title,'SELECTED', cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
       else
        tmp := tmp || htf.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
      end if;
     end loop;
     tmp := tmp || htf.formselectclose;
    */
    tmp4 := photo_name;

    if (rep_ext.photo_name is not null) and (photo_name is not null) and (photo_name <> rep_ext.photo_name)
     then
      tmp4 := tmp4 || '(' || rep_ext.photo_name || ')';
    end if;
  end if;

  tmp2 := htf.anchor2(
            'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || v_umo || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(vsn) ||
            '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid) ||
            '&parm1=RETURN_LINK&parm2=phg.photo_fast_edit_acct~surl=' || glbx.rndsurl(surl) || '!acid=' || acid || '!mctr=' || mctr,
            '<IMG BORDER=0 WIDTH=' || to_char(v_w) || ' HEIGHT=' || to_char(v_h) || ' SRC="' ||
            'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || v_umo || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=VERSION&parm2=' || to_char(vsn) ||
            '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid) ||
            '" ALT="' || tmp4 || '" STYLE="display:block;">',
            ctarget=>'NEW_WINDOW');

  if typ in ('MASS','MASSA')
    then
      htp.formhidden( 'AFC', null );
      ck := null;
      if typ = 'MASSA' then ck := 'CHECKED'; end if;
      if tblob.width < tblob.height
       then
        htp.tabledata( htf.tableopen(cattributes=>'cellpadding=1 cellspacing=1 border=0') || htf.tablerowopen ||
                       htf.tabledata(tmp2 || htf.nl || to_char(j + thewidth) || ':' || photo_name ) ||
                       htf.tabledata( htf.formcheckbox( 'ROTA', 'A' || v_umo ) || LNG.PHG_TXT_466 || htf.nl ||
                                      htf.formcheckbox( 'ROTB', 'B' || v_umo ) || LNG.PHG_TXT_467 || htf.nl ||
                                      htf.formcheckbox( 'ROTC', 'C' || v_umo ) || LNG.PHG_TXT_468 || htf.nl ||
                                      htf.formcheckbox( 'ROTD', 'D' || v_umo ) || LNG.PHG_TXT_486 || htf.nl ||
                                      htf.formcheckbox( 'ROTE', 'E' || v_umo, ck ) || LNG.PHG_TXT_485)|| htf.tablerowclose || htf.tableclose);
       else
        htp.tabledata( htf.tableopen(cattributes=>'cellpadding=1 cellspacing=1 border=0') || htf.tablerowopen ||
                       htf.tabledata( htf.formcheckbox( 'ROTA', 'A' || v_umo ) || ' ' || LNG.PHG_TXT_466 || ' ' ||
                                      htf.formcheckbox( 'ROTB', 'B' || v_umo ) || ' ' || LNG.PHG_TXT_467 || htf.nl ||
                                      htf.formcheckbox( 'ROTC', 'C' || v_umo ) || ' ' || LNG.PHG_TXT_468 || ' ' ||
                                      htf.formcheckbox( 'ROTD', 'D' || v_umo ) || ' ' || LNG.PHG_TXT_469 || htf.nl ||
                                      htf.formcheckbox( 'ROTE', 'E' || v_umo, ck ) || ' ' || LNG.PHG_TXT_365 ) || htf.tablerowclose || htf.tablerowopen ||
                       htf.tabledata(tmp2|| htf.nl || to_char(j + thewidth) || ':' || photo_name) || htf.tablerowclose || htf.tableclose || '</FONT>');
      end if;
    else
    tmp5 := NULL;
    for c_colrec in c4( theme_rec.theme_type ) loop
     if c_colrec.film_type = fcolour
      then
       tmp5 := tmp5 || htf.formselectoption( c_colrec.film_type,'SELECTED');
      else
       tmp5 := tmp5 || htf.formselectoption( c_colrec.film_type);
     end if;
    end loop;
    tmp5 := htf.formselectopen( 'AFC' ) || nvl(tmp5,htf.formselectoption(LNG.ORD_TXT_194)) || htf.formselectclose;
    if mxwidth = 1
     then
      htp.tabledata(tmp3,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
      htp.tabledata(tmp2 || htf.anchor( 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=&footer_api=FAST&left_api_parm=&current_page_number=&display_detail=&phgid=' || v_umo, LNG.GLB_TXT_123),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
      htp.tabledata(htf.formtext( 'A1', 4+(stype*2), 100, photo_name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext( 'AR', 4, 8, roll_id ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
      htp.formselectopen( 'A2' );
      -- tmp := ump.retrieve_scenes(surl,acid, 'OWNER', c3rec.scene_name, owner_id, null, scene_id, display_style=>'LISTALL' );
       for c2rec in c2(c3rec.scene_name,owner_id) loop
        if c2rec.umo_scene_id = scene_id
         then
          htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title,'SELECTED', cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
         else
          htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
        end if;
       end loop;
      htp.formselectclose;
      htp.p( '</TD>' );

     else

      if typ = 'PHOTO'
       then
         htp.p( '<TD ' || pfx.qcbground || 'valign="BOTTOM" ALIGN="CENTER">');
           htp.p( to_char(j + thewidth) || htf.nl || tmp2 || htf.nl ||
                          tmp3 ||
                          htf.formtext( 'A1', 5+(stype*2), 100, photo_name ) || htf.nl ||
                          htf.formtext( 'AR', 5, 8, roll_id ) || ' ' ||
                          htf.anchor( 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=&footer_api=FAST&left_api_parm=&current_page_number=&display_detail=&phgid=' || v_umo, LNG.GLB_TXT_123) || ' ' || tmp5 ||
                          htf.nl);
          htp.formselectopen( 'A2' );
          -- tmp := ump.retrieve_scenes(surl,acid, 'OWNER', c3rec.scene_name, owner_id, null, scene_id, display_style=>'LISTALL' );
          for c2rec in c2(c3rec.scene_name,owner_id) loop
           if c2rec.umo_scene_id = scene_id
            then
             htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title,'SELECTED', cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
            else
             htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
           end if;
          end loop;
          htp.formselectclose;
         htp.p( '</TD>' );

      elsif typ = 'NMB'
        then
         htp.p( '<TD ' || pfx.qcbground || 'valign="BOTTOM" ALIGN="CENTER">');
           htp.formhidden( 'A1', null );
           htp.formhidden( 'A2', null );
           htp.formhidden( 'AFC', null );
           htp.p( to_char(j + thewidth) || htf.nl || tmp2 || htf.nl ||
                          tmp3 || htf.formtext( 'AR', 5, 8, rep_ext.orderby_nmb ) || ' ' ||
                          htf.anchor( 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=&footer_api=FAST&left_api_parm=&current_page_number=&display_detail=&phgid=' || v_umo, LNG.GLB_TXT_123) );
         htp.p( '</TD>' );

       elsif typ = 'META'
        then
         htp.p( '<TD ' || pfx.qcbground || 'valign="BOTTOM" ALIGN="CENTER">');
           htp.p( htf.anchor( 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=&footer_api=FAST&left_api_parm=&current_page_number=&display_detail=&phgid=' || v_umo, LNG.GLB_TXT_123) );
           htp.p( htf.nl || tmp2 || htf.nl || rep_ext.film_name  );
           res := glbx.img_meta_edit( v_umo, umo_type, pfx, FALSE, stype, acid, bftr=>theme_rec.theme_type );
         htp.p( '</TD>' );

       elsif typ = 'LINK'
        then
         htp.p( '<TD ' || pfx.qcbground || 'valign="BOTTOM" ALIGN="CENTER">' );
         htp.p( tmp2 );
         htp.nl;
         htp.p( htf.anchor( 'phg.phg_edit_link?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&v_umo=' || v_umo, photo_name ));
         htp.nl;
         for c7rec in c7( v_umo ) loop
          htp.p(c7rec.film_name || '-' || c7rec.weighting );
          htp.nl;
         end loop;
         htp.p( '</TD>' );

       else
         htp.p( '<TD ' || pfx.qcbground || 'valign="BOTTOM" ALIGN="CENTER">');
         htp.p( tmp2 || htf.nl || tmp3 || htf.formtext( 'A1', 5+(stype*2), 100, photo_name ) || htf.nl ||
                      htf.formtext( 'AR', 5, 8, roll_id ) || ' ' ||
                      htf.anchor( 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=&footer_api=FAST&left_api_parm=&current_page_number=&display_detail=&phgid=' || v_umo, LNG.GLB_TXT_123) || ' ' || tmp5 ||
                      htf.nl );
          htp.formselectopen( 'A2' );
         --  tmp := ump.retrieve_scenes(surl,acid, 'OWNER', c3rec.scene_name, owner_id, null, scene_id, display_style=>'LISTALL' );
          for c2rec in c2(c3rec.scene_name,owner_id) loop
           if c2rec.umo_scene_id = scene_id
            then
             htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title,'SELECTED', cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
            else
             htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
           end if;
          end loop;
          htp.formselectclose;
         htp.p( '</TD>' );
      end if;
   end if;
  end if;

 if mod(ctr,mxwidth) = 0 then htp.tablerowclose; htp.tablerowopen; end if;
 end loop;
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 if ctr = 0
  then
   htp.header(3,LNG.PHG_TXT_019,'CENTER');
   htp.formhidden( 'AR', null );
   htp.formhidden( 'A1', null );
   htp.formhidden( 'A2', null );
   htp.formhidden( 'A3', null );
  else
   htp.formsubmit( null, LNG.PHG_TXT_197 );
   if typ in ('MASS','MASSA')
    then
      htp.p( '<input type=button value="Check All 90C" onClick="this.value=check(this.form.ROTA)">' );
      htp.p( '<input type=button value="Check All 90CC" onClick="this.value=check(this.form.ROTB)">' );
      htp.p( '<input type=button value="Check All 180" onClick="this.value=check(this.form.ROTC)">' );
      htp.p( '<input type=button value="Check All MIRROR" onClick="this.value=check(this.form.ROTD)">' );
      htp.p( '<input type=button value="Check All Watermark" onClick="this.value=check(this.form.ROTE)">' );
   end if;
 end if;

 tmp2 := htf.formselectoption( LNG.PHG_TXT_231, 'SELECTED' );
 for c6rec in c6(owner_id,acid) loop
   tmp2 := tmp2 || htf.formselectoption( c6rec.photo_name, cattributes=>'VALUE="' || c6rec.umo_id || '"'  );
 end loop;
 tmp2 := tmp2 || htf.formselectoption('Text - Arial 10pt Black') ||
  htf.formselectoption('Text - Arial 10pt White') ||
  htf.formselectoption('Text - Arial 10pt Blue') ||
  htf.formselectoption('Text - Arial 12pt Black') ||
  htf.formselectoption('Text - Arial 12pt White') ||
  htf.formselectoption('Text - Arial 12pt Blue') ||
  htf.formselectoption('Text - Arial 14pt Black') ||
  htf.formselectoption('Text - Arial 14pt White') ||
  htf.formselectoption('Text - Arial 14pt Blue');
 if typ in ('MASS','MASSA')
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.PHG_TXT_365) );
     htp.tabledata( htf.formselectopen( 'P11' ) || tmp2 || htf.formselectclose );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.PHG_TXT_366) );
     htp.tabledata( htf.formtext( 'P11A', 5, 5,'45' ) || LNG.PHG_ALT_404);
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Watermark Text') );
     htp.tabledata( htf.formtext('P11B', 20, 100 ) );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.PHG_TXT_378) );
     htp.tabledata( htf.formselectopen('P11C') ||
                    htf.formselectoption( LNG.PHG_TXT_379 ) || htf.formselectoption( LNG.PHG_TXT_381 ) || htf.formselectoption( LNG.PHG_TXT_383 ) ||
                    htf.formselectoption( LNG.PHG_TXT_384 ) || htf.formselectoption( LNG.PHG_TXT_385, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_401 ) ||
                    htf.formselectoption( LNG.PHG_TXT_402 ) || htf.formselectoption( LNG.PHG_TXT_403 ) || htf.formselectoption( LNG.PHG_TXT_415 ) ||
                    htf.formselectclose );
     htp.tablerowclose;
   htp.tableclose;
   htp.nl;
 else
  htp.formhidden( 'P11',null);
  htp.formhidden( 'P11A',null);
  htp.formhidden( 'P11B',null);
 end if;
 htp.formclose;
 htp.nl;
 htp.nl;

 if newwin = LNG.PHG_TXT_045
  then
   htp.nl;
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
   htp.nl;
   if typ in ('MASS','MASSA')
    then
     htp.anchor( 'phg.photo_fast_edit_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&mctr=' || mctr || '&mwidth=' || mwidth || '&typ=MASSA' || '&typval=' || typval, LNG4.AHC_TXT_108);
   end if;
 end if;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHOTO_FAST_EDIT_ACCT',owner_id,acid,errmsg=>sqlerrm,extdet=>'MCTR:' || mctr);
end photo_fast_edit_acct;

procedure accept_fast_edit(surl in varchar2,acid in integer, mctr in integer, mwidth in integer default 1, typ in varchar2, typval in varchar2, p11 in varchar2 default null,
                           p11a in varchar2 default null, p11b in varchar2 default null, p11c in varchar2 default null, newwin in varchar2,
                           a0 in MYARRAY, a1 in MYARRAY, a2 in MYARRAY, a3 in MYARRAY, ar in MYARRAY, rota in MYARRAY, rotb in MYARRAY, rotc in MYARRAY, rotd in MYARRAY, rote in MYARRAY, afc in MYARRAY)
as
 cursor c1(v_umo integer) is select um.extras from umo um where umo_id = v_umo;
 cursor c2(scid integer) is select order_by from umo_scene where umo_scene_id = scid;
 cursor c3(phgr integer, acid integer, v_umo integer) is
   select um.photo_master
   from umo um,customer_account ca
   where umo_id = v_umo and
         um.aid = ca.aid and
         ca.pid = phgr;
 cursor c4(usc integer) is select title from umo_scene where umo_scene_id = usc;

 ph1		ORDSYS.ORDIMAGE;
 ph2		ORDSYS.ORDIMAGE;
 sts		varchar2(200);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 tmwidth	integer;
 nmb		integer;
 v_extras	REPEATED_FIELDS;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 parm1		ump.parameters;
 parm2		ump.parameters;
 retval		varchar2(4000);
 xcoord		integer;
 ycoord		integer;
 wsts		integer;
 errs		MYARRAY;
 err_ctr	integer;
 rot		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_FAST_EDIT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 err_ctr := 0;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 retval := NULL;

 if typ not in ('MASS','NMB')
  then
   for j in a0.first..a0.last loop
    open c1(to_number(a0(j)));
    fetch c1 into v_extras;
    close c1;
    open c4(a2(j));
    fetch c4 into v_extras.title;
    close c4;
    open c2(a2(j));
    fetch c2 into v_extras.orderby_scene;
    close c2;
    update umo um
     set
      umo_scene_id = a2(j),
      extras = v_extras
      where aid=acid and umo_id=a0(j) and
	    aid in (select aid from customer_account where pid = owner_id);
    parm1(1) := 'UMO_ID';
    parm2(1) := a0(j);
    parm1(2) := 'AID';
    parm2(2) := to_char(acid);
    parm1(3) := 'OBJECT_TYPE';
    parm2(3) := 'PHOTO';
    parm1(4) := 'KEEP_STATUS';
    parm2(4) := 'KEEP';
    parm1(5) := 'ROLL_ID';
    parm2(5) := ar(j);
    parm1(6) := 'FILM_NAME';
    parm2(6) := a1(j);
    parm1(7) := 'PHOTOGRAPHER';
    parm2(7) := 'FALSE';
    parm1(8) := 'FILM_TYPE';
    parm2(8) := afc(j);
    ump.modify_uma(surl,parm1,parm2,retval);
    if retval is not null then err_ctr := err_ctr + 1; errs(err_ctr) := a0(j) || ': Extras : ' || retval; retval := NULL; end if;
   end loop;
 end if;

 parm1.delete;
 parm2.delete;

 if typ not in ('MASS')
  then
   for j in a3.first..a3.last loop
    if a3(j) <> '0'
     then
       parm1(1) := 'UMO_ID';
       parm2(1) := a3(j);
       parm1(2) := 'AID';
       parm2(2) := to_char(acid);
       parm1(3) := 'OBJECT_TYPE';
       parm2(3) := 'PHOTO';
       parm1(4) := 'KEEP_STATUS';
       parm2(4) := 'KEEP';
       parm1(5) := 'PHOTOGRAPHER';
       parm2(5) := 'TRUE';
       ump.modify_uma(surl,parm1,parm2,retval);
       if retval is not null then err_ctr := err_ctr + 1; errs(err_ctr) := a3(j) || ': Parameter : ' || retval; retval := NULL; end if;
    end if;
   end loop;
   commit;
 end if;

 parm1.delete;
 parm2.delete;

 if typ = 'NMB'
  then
   for j in a0.first..a0.last loop
    begin nmb := to_number(ar(j)); exception when others then nmb := NULL; end;
    update umo um
     set
      um.extras.orderby_nmb = nvl(nmb,um.extras.orderby_nmb)
      where aid=acid and umo_id=a0(j) and
	    aid in (select aid from customer_account where pid = owner_id);
   end loop;
   commit;
 end if;

 for j in rota.first..rota.last loop rot(rot.count+1) := rota(j); end loop;
 for j in rotb.first..rotb.last loop rot(rot.count+1) := rotb(j); end loop;
 for j in rotc.first..rotc.last loop rot(rot.count+1) := rotc(j); end loop;
 for j in rotd.first..rotd.last loop rot(rot.count+1) := rotd(j); end loop;
 for j in rote.first..rote.last loop rot(rot.count+1) := rote(j); end loop;
 for j in rot.first..rot.last loop
  if rot(j) <> '0'
   then
    if substr(rot(j),1,1) = 'E'
     then
       parm1.delete;
       parm2.delete;
       parm1(1) := 'UMO_ID';
       parm2(1) := substr(rot(j),2);
       parm1(2) := 'AID';
       parm2(2) := to_char(acid);
       parm1(3) := 'OBJECT_TYPE';
       parm2(3) := 'PHOTO';
       parm1(4) := 'KEEP_STATUS';
       parm2(4) := 'KEEP';
       parm1(5) := 'MERGE';
       parm2(5) := 'TRANSPARENT_OFFSET';
       parm1(6) := 'MERGE_LUCENT_OFFSET';
       begin nmb := to_number(p11a); if nmb <0 or nmb >100 then nmb := 45; end if; exception when others then nmb := 45; end;
       parm2(6) := to_number(nmb);
       parm1(7) := 'MERGE_UMO_ID';
       if substr(p11,1,1) = 'T'
        then
         parm2(7) := p11;
         open c3(owner_id,acid,to_number(substr(rot(j),2)));
         fetch c3 into ph1;
         close c3;
         ph2 := ordsys.ordimage.init();
         ph2.width := 1;
         ph2.height := 1;
        else
         nmb := to_number(p11);
         open c3(owner_id,acid,to_number(substr(rot(j),2)));
         fetch c3 into ph1;
         close c3;
         open c3(owner_id,acid,nmb);
         fetch c3 into ph2;
         close c3;
         parm2(7) := to_char(nmb);
       end if;
       glbx.determine_wm( ph1, ph2, p11c, xcoord, ycoord, wsts);
       if wsts = 1
        then
         htp.htmlopen; htp.header(3,LNG.PHG_TXT_457 ); htp.htmlclose; return;
       elsif wsts = 2
        then
         htp.htmlopen; htp.header(3,LNG.PHG_TXT_458 ); htp.htmlclose; return;
       elsif wsts = 3
        then
         htp.htmlopen; htp.header(3,LNG.PHG_TXT_459 ); htp.htmlclose; return;
       end if;
       parm1(8) := 'MERGE_X_COORD';
       parm2(8) := to_char(xcoord);
       parm1(9) := 'MERGE_Y_COORD';
       parm2(9) := to_char(ycoord);
       parm1(10) := 'MERGE_SHAPE';
       parm2(10) := NULL;

       parm1(11) := 'MERGE_TEXT';
       parm2(11) := p11b;
       parm1(12) := 'CREATE_THUMBNAIL';
       parm2(12) := 'TRUE';
       parm1(13) := 'THUMBNAIL_WIDTH';
       parm2(13) := nvl(glbx.photo_pref(owner_id,acid,'THUMBNAIL_WIDTH'),'100');
       parm1(14) := 'MASS_ROTATE';
       parm2(14) := 'TRUE';
       parm1(15) := 'WAIT_SECONDS';
       parm2(15) := '900';
       ump.modify_uma(surl,parm1,parm2,retval);
       if retval is not null then err_ctr := err_ctr + 1; errs(err_ctr) := substr(rot(j),2) || ': Merge :' || retval; retval := NULL; end if;
    elsif substr(rot(j),1,1) in ('A','B','C','D')
     then
       parm1.delete;
       parm2.delete;
       parm1(1) := 'UMO_ID';
       parm2(1) := substr(rot(j),2);
       parm1(2) := 'AID';
       parm2(2) := to_char(acid);
       parm1(3) := 'OBJECT_TYPE';
       parm2(3) := 'PHOTO';
       parm1(4) := 'KEEP_STATUS';
       parm2(4) := 'KEEP';
       parm1(5) := 'ROTATE';
       if substr(rot(j),1,1) = 'A'
        then
         parm2(5) := LNG.PHG_TXT_466;
       elsif substr(rot(j),1,1) = 'B'
        then
         parm2(5) := LNG.PHG_TXT_467;
       elsif substr(rot(j),1,1) = 'C'
        then
         parm2(5) := LNG.PHG_TXT_468;
       elsif substr(rot(j),1,1) = 'D'
        then
         parm2(5) := LNG.PHG_TXT_469;
       end if;
       parm1(6) := 'CREATE_THUMBNAIL';
       parm2(6) := 'TRUE';
       parm1(7) := 'THUMBNAIL_WIDTH';
       parm2(7) := nvl(glbx.photo_pref(owner_id,acid,'THUMBNAIL_WIDTH'),'100');
       parm1(8) := 'MASS_ROTATE';
       parm2(8) := 'TRUE';
       parm1(9) := 'WAIT_SECONDS';
       parm2(9) := '900';
       ump.modify_uma(surl,parm1,parm2,retval);
       if retval is not null then err_ctr := err_ctr + 1; errs(err_ctr) := substr(rot(j),2) || ': Rotate :' || retval; retval := NULL;  end if;
    end if;
  end if;
 end loop;

 if err_ctr > 0
  then
   htp.htmlopen;
   htp.header(3,'The following errors occurred.','CENTER' );
   htp.header(4,'These errors have been logged and will be fixed.', 'CENTER' );
   for j in errs.first..errs.last loop
    htp.bold(errs(j)); htp.nl;
    insert into error_trap(date_created,package_name,procedure_name,pid,aid,error_message,extra_details) values
     (sysdate,'PHG','ACCEPT_FAST_EDIT',owner_id,acid,'Error on Change',errs(j));
   end loop;
   htp.htmlclose;
   commit;
   return;
 end if;

 commit;

 begin
  tmwidth := to_number( to_char(mwidth));
 exception
  when others then tmwidth := 2;
 end;
 if tmwidth < 1 or tmwidth > 20 then tmwidth := 2; end if;
 if typ = 'MASS'
  then
   photo_fast_edit_acct( surl, acid, mctr, mwidth, typ, typval );
  else
   if newwin = LNG.PHG_TXT_045
    then
     photo_fast_edit_acct( surl, acid, mctr, mwidth, typ, typval, newwin );
    else
     photo_fast_edit_acct_mst( surl, acid, mwidth, typ, typval, mctr,stype=>stype );
   end if;
 end if;
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_FAST_EDIT',owner_id,acid,errmsg=>sqlerrm,extdet=>'MCTR:' || mctr);
end accept_fast_edit;

function indnt( pscene integer )
  return integer
 is
  cursor cparent( pscene integer ) is
   select parent_scene
   from umo_scene
   where umo_scene_id = pscene;
  crec   cparent%ROWTYPE;
 begin
  if pscene is null then return( null ); end if;
  open cparent(pscene);
  fetch cparent into crec;
  close cparent;
  return( nvl(indnt( crec.parent_scene ),0) + 1 );
end indnt;

procedure delete_disabled_photos(surl in varchar2,acid in integer, msg in varchar2 default null)
as

 cursor c1(photid integer, acid integer) is
  select * from customer_account where aid=acid and pid=photid;

 cursor c2(phgid integer, scnm varchar2, acid integer) is
 	 select order_by,title,umo_scene_id,parent_scene
	 from umo_scene usc
	 where category = scnm and
	       ((owned_by = 'PUBLIC') or ((owned_by = 'PHOTOGRAPHER') and (owner_id = phgid)))
	 order by order_by;

 c1rec 		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.DELETE_DISABLED_PHOTOS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG2.PBK_TXT_094,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P40',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 glbx.header_msg( nvl(msg,LNG2.PBK_TXT_098) );
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'phg.accept_delete_disabled_photos' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P1', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_095 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P2', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_096 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P5', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_117 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P6', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_118 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P10', 'T' ) );
   htp.tabledata( htf.bold( 'Delete all Directory Images' ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P7', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_119 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P8', 'T' ) );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_102 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'PS', 'T' ) );
   htp.tabledata( htf.bold( LNG4.AHC_TXT_473 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P9', 'T' ) );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_103 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P3', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_097 ) );
   htp.p( '<TD>' );
   htp.formselectopen( 'DELCATEGORY' );
   htp.formselectoption( NULL );
   for c2rec in c2(owner_id,c1rec.scene_name,acid) loop
    htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formcheckbox( 'P3N', 'T' ) || ' Include Nested' );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;' );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_099 ) );
   htp.tabledata( htf.formtext( 'P4',20,20) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;' );
   htp.tabledata( htf.formsubmit( null, LNG2.PBK_TXT_094 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.formclose;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'DELETE_DISABLED_PHOTOS',owner_id,vaid=>acid,errmsg=>sqlerrm);
end delete_disabled_photos;

procedure delimg(vumo_id integer, utype varchar2)
as

 cursor c2(v_umo integer) is
 select u.umo_id,u.umo_type,u.aid,ua.attribute_id,ua.position_id,ua.value
 from umo_attribute ua, umo u
 where ua.umo_id = u.umo_id and
        u.umo_id = v_umo;

 bl		boolean;

begin

  delete from ecard where phid = vumo_id;
   update slide_details
    set phid_1 = null
    where phid_1 = vumo_id;
   update slide_details
    set phid_2 = null
    where phid_2 = vumo_id;
   update slide_details
    set phid_3 = null
    where phid_3 = vumo_id;
   update slide_details
    set phid_4 = null
    where phid_4 = vumo_id;

   delete from umo_index where umo_id = vumo_id;

   if utype = 'AUDIO'
    then
     myaudio.audio_api(v_umo=>vumo_id,new_acid=>NULL,old_acid=>NULL,action=>'DELETE');
   elsif utype = 'VIDEO'
    then
     myvideo.video_api(v_umo=>vumo_id,new_acid=>NULL,old_acid=>NULL,action=>'DELETE');
   elsif utype = 'RELATIONAL'
    then
     myrelational.relational_api(v_umo=>vumo_id,new_acid=>NULL,old_acid=>NULL,action=>'DELETE');
   elsif utype = 'BLUEPRINT'
    then
     myblueprint.blueprint_api(v_umo=>vumo_id,new_acid=>NULL,old_acid=>NULL,action=>'DELETE');
   elsif utype = 'DOCUMENT'
    then
     mydocument.document_api(v_umo=>vumo_id,new_acid=>NULL,old_acid=>NULL,action=>'DELETE');
   end if;

   delete from umo_attribute where umo_id = vumo_id;
   delete from log_photo_mod where phid = vumo_id;
   delete from log_umo_utility_modification where umo_id = vumo_id;
   delete from gallery_charge where umo_id = vumo_id;
   delete from downloaded_photo where umo_id = vumo_id;
   bl := glbx.delete_link(vumo_id);
   if utype = 'AUDIO'
    then
     ump.audio_index(v_umo=>vumo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   elsif utype = 'VIDEO'
    then
     ump.video_index(v_umo=>vumo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   elsif utype = 'RELATIONAL'
    then
     ump.relational_index(v_umo=>vumo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   elsif utype = 'BLUEPRINT'
    then
     ump.blueprint_index(v_umo=>vumo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   elsif utype = 'DOCUMENT'
    then
     ump.document_index(v_umo=>vumo_id,schemaname=>user,howloaded=>NULL,action=>'DELETE');
   end if;
   delete from umo where umo_id = vumo_id;
end delimg;

procedure accept_delete_disabled_photos( surl in varchar2, acid in integer, p1 in varchar2 default 'F', p2 in varchar2 default 'F', p3 in varchar2 default 'F', p4 in varchar2, p5 in varchar2 default 'F', p6 in varchar2 default 'F', p7 in varchar2 default 'F', p8 in varchar2 default 'F', p9 in varchar2 default 'F', p10 in varchar2 default 'F', ps in varchar2 default 'F', delcategory in varchar2, p3n in varchar2 default 'F' )
as

 sts		varchar2(200);
 ltype		varchar2(100);
 msg		varchar2(1000);
 stype		integer;
 owner_id	integer;
 nmb		integer;
 gl		boolean;

 cursor c1(acid integer, phgr integer, ext varchar2) is
  select um.umo_id,um.umo_type
  from  umo um, customer_account ca
  where substr(um.extras.enabled_phg,1,1) = substr(ext,1,1) and
        ca.aid = um.aid and
        ca.aid = acid and
        ca.pid = phgr;

 cursor c2(acid integer, phgr integer, scid integer) is
  select um.umo_id,um.umo_type
  from  umo um, customer_account ca
  where um.umo_scene_id = scid and
        ca.aid = um.aid and
        ca.aid = acid and
        ca.pid = phgr;

 cursor c3(acid integer, phgr integer) is
  select um.umo_id,um.umo_type
  from  umo um, customer_account ca
  where ca.aid = um.aid and
        ca.aid = acid and
        ca.pid = phgr;

 cursor c4(v_umo integer) is
  select ua.attribute_id,ua.value,ua.position_id
  from umo_attribute ua, umo_attributes u
  where sub_category in ('MADE BY','THE COMMENT','EMAIL ADDRESS') and
        u.attribute_id = ua.attribute_id and
        ua.umo_id = v_umo and
        umo_type = 'PHOTO';

 cursor c5(v_umo integer) is
  select ua.attribute_id,ua.value,ua.position_id
  from umo_attribute ua, umo_attributes u
  where sub_category in ('PERSON') and
        u.attribute_id = ua.attribute_id and
        ua.umo_id = v_umo and
        umo_type = 'PHOTO';

 cursor c6(acid integer, phgr integer) is
  select um.umo_id,um.umo_type
  from  umo um, customer_account ca
  where ca.aid = um.aid and
        sessid is not null and
        ca.aid = acid and
        ca.pid = phgr;

 cursor c7(acid integer, phgr integer, scid integer) is
  select umo_scene_id catid
  from  umo_scene
  where parent_scene = scid and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgr ));

 cursor c10(acid integer, phgr integer) is
  select um.umo_id,um.umo_type
  from  umo um, customer_account ca
  where um.object_class = 'DIRECTORY' and
        ca.aid = um.aid and
        ca.aid = acid and
        ca.pid = phgr;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_DELETE_DISABLED_PHOTOS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if nvl(p4,'x') <> 'DELETE'
  then
   delete_disabled_photos(surl,acid,LNG2.PBK_TXT_100);
   return;
 end if;
 nmb := 0;

 -- Delete Disabled
 if p1 = 'T'
  then
   for c1rec in c1(acid,owner_id,'F') loop
    nmb := nmb + 1;
    delimg(c1rec.umo_id,c1rec.umo_type);
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG.PHG_ALT_382;
 end if;

 -- Delete Enabled
 if p2 = 'T'
  then
   for c1rec in c1(acid,owner_id,'T') loop
    nmb := nmb + 1;
    delimg(c1rec.umo_id,c1rec.umo_type);
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG.PHG_ALT_382;
 end if;

 -- Delete Images in a Category
 if (p3 = 'T') and (delcategory is not null)
  then
   -- First Delete from Children Categories
   if p3n = 'T'
    then
     for c7rec in c7(acid, owner_id, to_number(delcategory)) loop
      accept_delete_disabled_photos( surl=>surl, acid=>acid, p1=>p1, p2=>p2, p3=>p3, p4=>p4, p5=>p5, p6=>p6, p7=>p7, p8=>p8, p9=>p9, p10=>p10, ps=>ps, delcategory=>c7rec.catid, p3n=>p3n );
     end loop;
   end if;
   -- Now Delete from the Parent.
   for c2rec in c2(acid,owner_id,to_number(delcategory)) loop
    nmb := nmb + 1;
    delimg(c2rec.umo_id,c2rec.umo_type);
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG.PHG_ALT_382;
 end if;

 -- Delete all Original Content
 if p5 = 'T'
  then
   for c3rec in c3(acid,owner_id) loop
    nmb := nmb + 1;
    update umo um
     set um.photo_original = ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL)
      where umo_id = c3rec.umo_id;
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG2.PFM_TXT_075;
 end if;

 -- Delete Directory Images
 if p10 = 'T'
  then
   for c10rec in c10(acid,owner_id) loop
    nmb := nmb + 1;
    delimg(c10rec.umo_id,c10rec.umo_type);
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG.PHG_ALT_382;
 end if;

 -- Delete Backups
 if p6 = 'T'
  then
   for c3rec in c3(acid,owner_id) loop
    nmb := nmb + 1;
    update umo um
     set um.photo_backup = ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL)
      where umo_id = c3rec.umo_id;
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG2.PFM_TXT_075;
 end if;

 -- Delete Links
 if p7 = 'T'
  then
   for c3rec in c3(acid,owner_id) loop
    nmb := nmb + 1;
    gl := glbx.delete_link(c3rec.umo_id);
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG2.PFM_TXT_075;
 end if;

 -- Delete session specific images
 if ps = 'T'
  then
   for c6rec in c6(acid,owner_id) loop
    nmb := nmb + 1;
    delimg(c6rec.umo_id,c6rec.umo_type);
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG2.PFM_TXT_075;
 end if;

 -- Delete Comments
 if p8 = 'T'
  then
   for c3rec in c3(acid,owner_id) loop
    nmb := nmb + 1;
    delete from umo_index um
     where umo_id = c3rec.umo_id and
           aid = acid and
           attribute_id in
            (select attribute_id from umo_attributes where sub_category in ('MADE BY','THE COMMENT','EMAIL ADDRESS') and umo_type = 'PHOTO');

       for c4rec in c4(c3rec.umo_id) loop
         if c3rec.umo_type = 'AUDIO'
           then
              myaudio.audio_api(v_umo=>c3rec.umo_id,attrib_id=>c4rec.attribute_id,data_value=>c4rec.value,acid=>acid,posid=>nvl(c4rec.position_id,1),action=>'DELETE');
            elsif c3rec.umo_type = 'VIDEO'
             then
              myvideo.video_api(v_umo=>c3rec.umo_id,attrib_id=>c4rec.attribute_id,data_value=>c4rec.value,acid=>acid,posid=>nvl(c4rec.position_id,1),action=>'DELETE');
            elsif c3rec.umo_type = 'RELATIONAL'
             then
              myrelational.relational_api(v_umo=>c3rec.umo_id,attrib_id=>c4rec.attribute_id,data_value=>c4rec.value,acid=>acid,posid=>nvl(c4rec.position_id,1),action=>'DELETE');
            elsif c3rec.umo_type = 'BLUEPRINT'
             then
              myblueprint.blueprint_api(v_umo=>c3rec.umo_id,attrib_id=>c4rec.attribute_id,data_value=>c4rec.value,acid=>acid,posid=>nvl(c4rec.position_id,1),action=>'DELETE');
            elsif c3rec.umo_type = 'DOCUMENT'
             then
              mydocument.document_api(v_umo=>c3rec.umo_id,attrib_id=>c4rec.attribute_id,data_value=>c4rec.value,acid=>acid,posid=>nvl(c4rec.position_id,1),action=>'DELETE');
         end if;
        end loop;

    delete from umo_attribute um where umo_id = c3rec.umo_id and attribute_id in (select attribute_id from umo_attributes where sub_category in ('MADE BY','THE COMMENT','EMAIL ADDRESS') and umo_type = 'PHOTO');
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG2.PFM_TXT_075;
 end if;

 -- Delete all Names Attached to Images
 if p9 = 'T'
  then
   for c3rec in c3(acid,owner_id) loop
    nmb := nmb + 1;
    delete from umo_index um where umo_id = c3rec.umo_id and aid = acid and attribute_id in (select attribute_id from umo_attributes where sub_category in ('PERSON') and umo_type = 'PHOTO');
       for c5rec in c5(c3rec.umo_id) loop
         if c3rec.umo_type = 'AUDIO'
           then
              myaudio.audio_api(v_umo=>c3rec.umo_id,attrib_id=>c5rec.attribute_id,data_value=>c5rec.value,acid=>acid,posid=>nvl(c5rec.position_id,1),action=>'DELETE');
            elsif c3rec.umo_type = 'VIDEO'
             then
              myvideo.video_api(v_umo=>c3rec.umo_id,attrib_id=>c5rec.attribute_id,data_value=>c5rec.value,acid=>acid,posid=>nvl(c5rec.position_id,1),action=>'DELETE');
            elsif c3rec.umo_type = 'RELATIONAL'
             then
              myrelational.relational_api(v_umo=>c3rec.umo_id,attrib_id=>c5rec.attribute_id,data_value=>c5rec.value,acid=>acid,posid=>nvl(c5rec.position_id,1),action=>'DELETE');
            elsif c3rec.umo_type = 'BLUEPRINT'
             then
              myblueprint.blueprint_api(v_umo=>c3rec.umo_id,attrib_id=>c5rec.attribute_id,data_value=>c5rec.value,acid=>acid,posid=>nvl(c5rec.position_id,1),action=>'DELETE');
            elsif c3rec.umo_type = 'DOCUMENT'
             then
              mydocument.document_api(v_umo=>c3rec.umo_id,attrib_id=>c5rec.attribute_id,data_value=>c5rec.value,acid=>acid,posid=>nvl(c5rec.position_id,1),action=>'DELETE');
         end if;
       end loop;
    delete from umo_attribute um where umo_id = c3rec.umo_id and attribute_id in (select attribute_id from umo_attributes where sub_category in ('PERSON') and umo_type = 'PHOTO');
    if mod(nmb,100) = 1 then commit; end if;
   end loop;
   commit;
   msg := '[' || nmb || '] ' || LNG2.PFM_TXT_075;
 end if;

 phg_utlts_prefs(surl,acid,msg);

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_DELETE_DISABLED_PHOTOS',owner_id,acid,errmsg=>sqlerrm);
end accept_delete_disabled_photos;

procedure isglobal_photos(surl in varchar2, acid in integer, msg in varchar2 default null)
as

 cursor c1(photid integer, acid integer) is
  select * from customer_account where aid=acid and pid=photid;

 cursor c2(phgid integer, scnm varchar2, acid integer) is
 	 select order_by,title,umo_scene_id,parent_scene
	 from umo_scene usc
	 where category = scnm and
	       ((owned_by = 'PUBLIC') or ((owned_by = 'PHOTOGRAPHER') and (owner_id = phgid)))
	 order by order_by;

 c1rec 		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ISGLOBAL_PHOTOS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG2.PFM_TXT_069,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P41',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 glbx.header_msg( msg );
 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'phg.accept_isglobal_photos' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P1', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PFM_TXT_070 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P2', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PFM_TXT_071 ) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P3', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PFM_TXT_072 ) );
   htp.p( '<TD>' );
   htp.formselectopen( 'PUB_CATEGORY' );
   htp.formselectoption( NULL );
   for c2rec in c2(owner_id,c1rec.scene_name,acid) loop
    htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowopen;
   htp.tabledata( htf.formcheckbox( 'P4', 'T' ) );
   htp.tabledata( htf.bold( LNG2.PFM_TXT_073 ) );
   htp.p( '<TD>' );
   htp.formselectopen( 'PRIV_CATEGORY' );
   htp.formselectoption( NULL );
   for c2rec in c2(owner_id,c1rec.scene_name,acid) loop
    htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;' );
   htp.tabledata( htf.formsubmit( null, LNG.PHG_BUT_116) );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.formclose;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'ISGLOBAL_PHOTOS',owner_id,vaid=>acid,errmsg=>sqlerrm);
end isglobal_photos;

procedure accept_isglobal_photos( surl in varchar2, acid in integer, p1 in varchar2 default 'F', p2 in varchar2 default 'F', p3 in varchar2 default 'F', p4 in varchar2 default 'F', pub_category in varchar2, priv_category in varchar2 )
as
 sts		varchar2(200);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_ISGLOBAL_PHOTOS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if p1 = 'T'
  then
   update umo
    set
     is_global = 'T'
      where aid = acid;
   commit;
 end if;

 if p2 = 'T'
  then
   update umo
    set
     is_global = 'F'
      where aid = acid;
   commit;
 end if;

 if (p3 = 'T') and (pub_category is not null)
  then
   update umo
    set
     is_global = 'T'
      where aid = acid and
            umo_scene_id = pub_category;
   commit;
 end if;

 if (p4 = 'T') and (priv_category is not null)
  then
   update umo
    set
     is_global = 'F'
      where aid = acid and
            umo_scene_id = pub_category;
   commit;
 end if;

 phg_utlts_prefs(surl, acid, LNG2.PFM_TXT_075);

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_ISGLOBAL_PHOTOS',owner_id,acid,errmsg=>sqlerrm);
end accept_isglobal_photos;

procedure display_thumbnail(surl in varchar2, ltype in varchar2, umrec in UMO%ROWTYPE,theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE,
                            footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, hor_caption in varchar2,
                            document_api in varchar2, video_api in varchar2, audio_api in varchar2, relational_api in varchar2, blueprint_api in varchar2, acid in integer default null )
as

 tmp	varchar2(1000);
 url	varchar2(1000);

begin
   if umrec.umo_type = 'DOCUMENT'
    then
      mydocument.document_api(surl=>glbx.rndsurl(surl),umo_rec=>umrec.umo_id,theme_data=>theme_rec.theme_data,left_api_parm=>left_api_parm,current_page_number=>current_page_number,display_detail=>display_detail,footer_api=>footer_api,ltype=>ltype,acid=>acid);
   elsif umrec.umo_type = 'VIDEO'
    then
      myvideo.video_api(surl=>glbx.rndsurl(surl),umo_rec=>umrec.umo_id,theme_data=>theme_rec.theme_data,left_api_parm=>left_api_parm,current_page_number=>current_page_number,display_detail=>display_detail,footer_api=>footer_api,ltype=>ltype,acid=>acid);
   elsif umrec.umo_type = 'AUDIO'
    then
      myaudio.audio_api(surl=>glbx.rndsurl(surl),umo_rec=>umrec.umo_id,theme_data=>theme_rec.theme_data,left_api_parm=>left_api_parm,current_page_number=>current_page_number,display_detail=>display_detail,footer_api=>footer_api,ltype=>ltype,acid=>acid);
   elsif umrec.umo_type = 'RELATIONAL'
    then
      myrelational.relational_api(surl=>glbx.rndsurl(surl),umo_rec=>umrec.umo_id,theme_data=>theme_rec.theme_data,left_api_parm=>left_api_parm,current_page_number=>current_page_number,display_detail=>display_detail,footer_api=>footer_api,ltype=>ltype,acid=>acid);
   elsif umrec.umo_type = 'BLUEPRINT'
    then
      myblueprint.blueprint_api(surl=>glbx.rndsurl(surl),umo_rec=>umrec.umo_id,theme_data=>theme_rec.theme_data,left_api_parm=>left_api_parm,current_page_number=>current_page_number,display_detail=>display_detail,footer_api=>footer_api,ltype=>ltype,acid=>acid);
   end if;
end display_thumbnail;

procedure phg_modify(surl in varchar2, acid in integer, phgid in integer, msg in GLBX.MYARRAY, footer_api in varchar2, left_api_parm in varchar2, current_page_number in varchar2, display_detail in varchar2 )
as
 cursor c1(v_umo integer, photographer_id integer) is
  select um.photo_original_loc,um.umo_id,um.umo_scene_id,um.photo_thumbnail,um.photo_master, um.photo_backup, um.extras, um.photo_original, um.pricing_structure,
         ca.scene_name, ca.theme_type, um.umo_type, um.version, um.aid, um.extra_film_colour, um.extra_roll_id, um.extra_film_size, um.ftp_location, um.ftp_virtual_dir, um.is_global, um.image_caption, um.sessid, um.sort_priority
  from umo um, customer_account ca
  where um.umo_id = v_umo and
	um.aid = ca.aid and
	umo_type <> 'GALLERY' and
	ca.pid = photographer_id;

 cursor c1g(v_umo integer, photographer_id integer) is
  select um.photo_original_loc,um.umo_id,um.umo_scene_id,um.photo_thumbnail,um.photo_master, um.photo_backup, um.extras, um.photo_original, um.pricing_structure,
         null scene_name, null theme_type, um.umo_type, um.version, um.aid, um.extra_film_colour, um.extra_roll_id, um.extra_film_size, um.ftp_location, um.ftp_virtual_dir, um.is_global, um.image_caption, um.sessid, um.sort_priority
  from umo um
  where um.umo_id = v_umo and
	um.aid = photographer_id and
	umo_type = 'GALLERY';

 cursor c3(acid integer, phgid integer) is
  select scene_name,background_img
  from customer_account
  where aid = acid and pid = phgid;

 cursor c4(ttype varchar2) is select film_type from film_types where theme_type = ttype;
 cursor c5 is select film_size from film_sizes;
 cursor c6(phgr integer,acid integer) is select umo_id,um.extras.photo_name photo_name from umo um, customer_account ca where umo_type = 'WATERMARK' and um.aid = ca.aid and ca.pid = phgr;
 cursor cgall(v_umo integer) is select charge_desc,charge from gallery_charge where umo_id = v_umo;
 cursor c7(acid integer, phgid integer) is select * from log_photo_mod where aid = acid and phid = phgid order by date_modified desc;
 cursor c9(phgid integer) is select virtual_directory from ftp_sites_phg where pid = phgid;
 cursor c10(owner_id integer) is select skill_level from photographer where pid = owner_id;
 cursor c11(attrid integer) is select sub_category from umo_attributes where attribute_id = attrid;
 cursor c12a(v_umo integer) is select count('x') tot from audit_all_activity where umo_id = v_umo and display_what = 'MASTER' and login_type <> 'PHOTOGRAPHER';
 cursor c12b(v_umo integer) is select count('x') tot from audit_all_activity where umo_id = v_umo and display_what = 'THUMBNAIL' and login_type <> 'PHOTOGRAPHER';
 cursor c13(v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c14(v_category varchar2, v_owner_id integer) is
 select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;
 cursor c15( acid integer, ndx integer ) is
  select 'x' ctr
  from  novelty_definition nd, novelty_set ns, charge_plan cp, photographer p, customer_account ca
  where substr(where_called,3,1) = 'T' and
        nd.novelty_id = ns.novelty_id and
        ns.novelty_set_id = cp.novelty_set_id and
        cp.id = p.plan_id and
        p.pid = ca.pid and
        ca.aid = acid and
        nd.novelty_id = ndx and
        0 in (select count('x') tot from novelty_customer where aid = acid)
 union
  select 'x' ctr
  from  novelty_definition nd, customer_account ca, novelty_customer nc
  where substr(where_called,3,1) = 'T' and
        nd.novelty_id = nc.novelty_id and
        ca.aid = acid and
        nd.novelty_id = ndx and
        nc.aid = ca.aid
  order by 1;

 c1rec		c1%ROWTYPE;
 c15rec		c15%ROWTYPE;
 umo_rec	c13%ROWTYPE;
 c10rec		c10%ROWTYPE;
 res		boolean;
 HAW		constant integer := 100;
 sts		varchar2(200);
 tmp1		varchar2(32767);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 ctr_loc	integer;
 lastloc	integer;
 hght		integer;
 dspht		integer;
 oth		integer;
 imgtot		integer;
 adj		integer;
 scn		varchar2(100);
 rdo		varchar2(100);
 thb_qual	varchar2(100);
 bck		integer;
 usemap		varchar2(100);
 photo_name	varchar2(100);
 roll_id	varchar2(100);
 film_type	varchar2(100);
 film_size	varchar2(100);
 neg_no		varchar2(100);
 category	varchar2(100);
 where_taken	varchar2(100);
 photo_enabled	varchar2(100);
 photo_title	varchar2(100);
 photo_type	varchar2(100);
 lnk		varchar2(1000);
 retval		varchar2(1000);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 foundrec	boolean;
 cprog		boolean;
 video_api	varchar2(1000);
 audio_api	varchar2(1000);
 relational_api	varchar2(1000);
 blueprint_api	varchar2(1000);
 document_api	varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_MODIFY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if acid is null
  then
   pfx := glbx.photo_lf(owner_id);
  else
   pfx := glbx.get_thm( acid );
 end if;
 theme_rec := get_theme_types( surl,acid );

 open c1( phgid, owner_id );
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   open c1g( phgid, owner_id );
   fetch c1g into c1rec;
   if c1g%NOTFOUND
    then
     close c1g;
     htp.htmlopen; htp.bold( LNG4.AHC_TXT_255  ); htp.htmlclose;
     return;
   end if;
   close c1g;
  else
   close c1;
 end if;

 if c1rec.umo_type = 'GALLERY'
  then
   photo_type := 'GALLERY';
  else
   if c1rec.aid <> acid then return; end if; -- Someone accessing a photo they are not allowed to
   photo_type := 'PHOTOGRAPHER';
   open c3(acid,owner_id);
   fetch c3 into scn,bck;
   close c3;
 end if;
 roll_id := c1rec.extra_roll_id;
 film_type := c1rec.extra_film_colour;
 film_size := c1rec.extra_film_size;
 neg_no := c1rec.extras.orderby_nmb;
 category := c1rec.extras.quality;
 photo_enabled := c1rec.extras.enabled_phg;
 photo_name := c1rec.extras.film_name;

 if c1rec.umo_type = 'GALLERY'
  then
    where_taken := ump.uma_attribute( surl,c1rec.umo_id, c1rec.umo_type, 'DETAILS' );
    photo_title := c1rec.extras.photo_name;
 end if;

 -- Extract Skill Level of Photographer
 open c10(owner_id);
 fetch c10 into c10rec;
 close c10;

 glbx.main_title( surl, LNG.PHG_TXT_204 || photo_name,glbx.backimg(surl,acid,pfx.text_back,bck,ltype),helpid=>'P14',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg.exists(1)
  then
   for j in msg.first..msg.last loop
    if substr(msg(j),1,1) = '['
     then
      open c11( to_number(substr(msg(j),2,instr(msg(j),']')-2)) );
      fetch c11 into retval;
      close c11;
      glbx.header_msg( retval || ':' || substr(msg(j),instr(msg(j),']')+1) );
     else
      glbx.header_msg( msg(j) );
    end if;
   end loop;
 end if;
 htp.p( '<CENTER>' );
 if footer_api = 'FAST'
  then
   htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.accept_phg_modify', cattributes=>'enctype="multipart/form-data"', ctarget=>'PHG_RIGHT' );
  else
   htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.accept_phg_modify', cattributes=>'enctype="multipart/form-data"' );
 end if;
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'PHGID', phgid );
 htp.formhidden( 'FOOTER_API', footer_api );
 if left_api_parm is null and footer_api = 'cst.disp_category'
  then
   htp.formhidden( 'LEFT_API_PARM', c1rec.umo_scene_id );
  else
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 end if;
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 if glbx.userpref( owner_id, acid, 'DISPLAY_ORIGINAL' ) = LNG.PHG_TXT_045
  then
   dspht := c1rec.photo_master.width;
   oth := c1rec.photo_master.height;
   adj := 1;
  else
   dspht := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) /1.3);
   oth := (trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) /1.3) / c1rec.photo_master.width) * c1rec.photo_master.height;
   adj := trunc((glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) /1.3) / c1rec.photo_master.width);
 end if;

 htp.tableopen;
  htp.tablerowopen;
     htp.p( '<TD ' || pfx.qbground || ' style="text-align: center;" valign="MIDDLE" ALIGN="CENTER">' );
     htp.tableopen( cattributes=>'style="text-align: center;" cellpadding=0 cellspacing=0 bordercolordark="#' || pfx.tnail_border_colour || '" bordercolorlight="#' || pfx.tnail_border_colour_l || '" border=' || to_char(nvl(pfx.tnail_border,0)) );
     htp.tablerowopen;
     lnk := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || phgid || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
            '&parm1=LOGIN_TYPE&parm2=' || photo_type || '&parm1=AID&parm2=' || to_char(acid) || '&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
            '&parm1=RETURN_LINK&parm2=phg.phg_modify~surl=' || glbx.rndsurl(surl) || '!acid=' || acid || '!msg=!phgid=' || phgid || '!footer_api=' || footer_api || '!left_api_parm=' || left_api_parm || '!current_page_number=' || current_page_number || '!display_detail=' || display_detail;
     usemap := glbx.embed_image_map( surl, phgid, adj, acid );
     htp.tabledata( htf.anchor2(
            lnk,
            '<IMG STYLE="display:block;" BORDER=0 WIDTH=' || to_char( dspht )|| ' HEIGHT=' || to_char( oth ) || usemap || ' SRC="' ||
            'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || phgid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c1rec.version) || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO' ||
            '&parm1=LOGIN_TYPE&parm2=' || photo_type || '&parm1=AID&parm2=' || to_char(acid) || '" ALT="' || photo_name || '">',ctarget=>'NEW_WINDOW' ),
            cattributes=>'style="text-align: center;"  align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspht + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' );
     htp.tablerowclose;
     htp.tableclose;
     if c1rec.umo_type in ( 'VIDEO','AUDIO','RELATIONAL','BLUEPRINT','DOCUMENT')
      then
       open c13(c1rec.umo_id);
       fetch c13 into umo_rec;
       close c13;
       -- View thumbnail is if an owner
       display_thumbnail(surl,'PHOTOGRAPHERX',umo_rec,theme_rec,pfx,footer_api,left_api_parm,ctr,null,null,document_api,video_api,audio_api,relational_api,blueprint_api,acid);
     end if;
     htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p( '<TD>' );

     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || pfx.qcbground );
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.CST_TXT_042 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.p( '<TD>' );
       htp.formselectopen( 'P1' );
       /*
       tmp1 := ump.retrieve_scenes( surl,acid, 'OWNER', scn, owner_id, null, c1rec.umo_scene_id, 'LISTALL');
       htp.formselectclose;
       if c1rec.sessid is not null
        then
         htp.nl;
         htp.bold( LNG4.AHC_TXT_474 );
       end if;
       */
       for c14rec in c14(c1rec.scene_name,owner_id) loop
        if c1rec.umo_scene_id = c14rec.umo_scene_id
         then
          htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c14rec.parent_scene),pfx.nested_scene_delim) || c14rec.title, 'SELECTED', cattributes=>'VALUE="' || c14rec.umo_scene_id || '"' );
         else
          htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c14rec.parent_scene),pfx.nested_scene_delim) || c14rec.title, cattributes=>'VALUE="' || c14rec.umo_scene_id || '"' );
        end if;
       end loop;
       htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG2.FNM_TXT_097 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.p( '<TD>' );
         if category = 'DETAIL PHOTO' then rdo := 'CHECKED'; else rdo := NULL; end if;
         htp.formradio( 'P2', 'DETAIL PHOTO', rdo );
         htp.p(LNG.PHG_ALT_397);
         htp.nl;
         if category = 'SPECIAL MOMENT' then rdo := 'CHECKED'; else rdo := NULL; end if;
         htp.formradio( 'P2', 'SPECIAL MOMENT', rdo );
         htp.p(LNG.PHG_ALT_398);
         htp.nl;
         if category not in  ('DETAIL PHOTO','SPECIAL MOMENT') or category is null then rdo := 'CHECKED'; else rdo := NULL; end if;
         htp.formradio( 'P2', 'STANDARD', rdo );
         htp.p(LNG.PHG_TXT_208);
       htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_022 ) || htf.nl || htf.italic( LNG.PHG_ALT_428 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata( htf.formtext( 'P3', 20, 100, photo_name ) || htf.nl || htf.italic(c1rec.extras.photo_name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_207 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.p( '<TD>' );
       if photo_enabled = 'TRUE'
        then
         htp.formcheckbox( 'P4', 'TRUE', 'CHECKED' );
        else
         htp.formcheckbox( 'P4', 'TRUE' );
       end if;
       htp.p( '</TD>' );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.bold( LNG.PHG_TXT_338 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
       htp.tabledata( htf.formtext( 'P3R', 8, 8, roll_id )  );
      htp.tablerowclose;

  if substr(theme_rec.theme_data,134,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG2.PFM_TXT_068 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    if c1rec.is_global = 'T'
     then
      htp.tabledata( htf.formcheckbox( 'ISGLOBAL', 'T', 'CHECKED' )  );
      htp.tablerowclose;
     else
      htp.tabledata( htf.formcheckbox( 'ISGLOBAL', 'T' )  );
      htp.tablerowclose;
    end if;
  end if;

  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_356 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  tmp1 := NULL;
  for c4rec in c4(c1rec.theme_type) loop
   if c4rec.film_type = film_type
    then
     tmp1 := tmp1 || htf.formselectoption( c4rec.film_type, 'SELECTED' );
    else
     tmp1 := tmp1 || htf.formselectoption( c4rec.film_type );
   end if;
  end loop;
  if tmp1 is null
   then
    htp.tabledata( htf.formhidden('P3F',NULL));
    htp.tablerowclose;
   else
    htp.tabledata( htf.formselectopen( 'P3F' ) || tmp1 || htf.formselectclose);
    htp.tablerowclose;
  end if;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_360 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  tmp1 := htf.formselectopen( 'P3Z' );
  for c5rec in c5 loop
   if c5rec.film_size = film_size
    then
     tmp1 := tmp1 || htf.formselectoption( c5rec.film_size, 'SELECTED' );
    else
     tmp1 := tmp1 || htf.formselectoption( c5rec.film_size );
   end if;
  end loop;
  htp.tabledata( tmp1 || htf.formselectclose);
  htp.tablerowclose;
  if substr(theme_rec.theme_data,202,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_381), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formtextareaopen( 'P3I', 4, 30 ) || c1rec.image_caption || htf.formtextareaclose);
    htp.tablerowclose;
   else
    htp.formhidden( 'P3I', c1rec.image_caption );
  end if;
  if substr(theme_rec.theme_data,189,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_357), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formtext( 'P3N', 10, 10, c1rec.extras.orderby_nmb));
    htp.tablerowclose;
   else
    htp.formhidden( 'P3N', c1rec.extras.orderby_nmb );
  end if;
  if substr(theme_rec.theme_data,136,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_868), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formtext( 'P3S', 10, 10, c1rec.sort_priority));
    htp.tablerowclose;
   else
    htp.formhidden( 'P3S', c1rec.sort_priority );
  end if;
    htp.tablerowopen;
     htp.tabledata(  '&nbsp;' , cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     if c1rec.pricing_structure = 'S'
      then
       htp.tabledata( htf.formradio( 'PRICING', 'S', 'CHECKED') || htf.bold(LNG4.AHC_TXT_225) || htf.nl || htf.formradio( 'PRICING', 'I' ) || htf.bold(LNG4.AHC_TXT_226) );
      else
       htp.tabledata( htf.formradio( 'PRICING', 'S') || htf.bold(LNG4.AHC_TXT_225) || htf.nl || htf.formradio( 'PRICING', 'I', 'CHECKED' ) || htf.bold(LNG4.AHC_TXT_226) );
     end if;
    htp.tablerowclose;
  htp.p( '</TD>' );
  if substr(theme_rec.theme_data,408,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG4.AHC_TXT_968), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.anchor2( 'pbk.usemap?surl=' || surl || '&v_umo=' || c1rec.umo_id || '&acid=' || acid, LNG4.AHC_TXT_967, ctarget=>'MAP_AN_IMAGE'  ) || c1rec.image_caption || htf.formtextareaclose);
    htp.tablerowclose;
  end if;
  htp.tableclose;

  -- Meta Data Edit
  if substr(theme_rec.theme_data,89,1) = 'T'
   then
    htp.nl; htp.bold( LNG.PHG_TXT_122 ); htp.nl;
    res := glbx.img_meta_edit( phgid, c1rec.umo_type, pfx, TRUE, stype, acid, bftr=>theme_rec.theme_type );
   else
    htp.formhidden( 'TAG_ID', '0' );
    htp.formhidden( 'TAG_VALUE', null );
    htp.formhidden( 'TAG_NAME', null );
  end if;

  -- Virtual Directory
  if (substr(theme_rec.theme_data,97,1) = 'T')
    then
     htp.nl;
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
     htp.tabledata( htf.bold( LNG3.ADM_TXT_595 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'FTPV' );
     htp.formselectoption( NULL );
     for c9rec in c9(owner_id) loop
      if c9rec.virtual_directory = c1rec.ftp_virtual_dir
       then
        htp.formselectoption( c9rec.virtual_directory, 'SELECTED' );
       else
        htp.formselectoption( c9rec.virtual_directory );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_TXT_533), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
      htp.tabledata( htf.formtext( 'FTP', 15, 1000, c1rec.ftp_location ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tableclose;
  end if;

  if c1rec.umo_type = 'GALLERY' or c1rec.pricing_structure = 'I'
   then

    --htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
    htp.nl;
    if c1rec.umo_type = 'GALLERY'
     then
      htp.bold( LNG2.PBK_TXT_114 );
     else
      htp.bold( LNG4.AHC_TXT_226 );
    end if;
    htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.PHG_ALT_400 ),cattributes=>pfx.qbground || ' ALIGN="CENTER"');
      htp.tabledata( htf.bold( LNG.PHG_ALT_399 ),cattributes=>pfx.qbground || ' ALIGN="CENTER"');
     htp.tablerowclose;
    for cgallrec in cgall(c1rec.umo_id) loop
     htp.tablerowopen;
      htp.tabledata( htf.formtext( 'GCD', 20, 100, cgallrec.charge_desc ),cattributes=>pfx.qcbground || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'GCP', 11, 11, ltrim(to_char(cgallrec.charge,LNG.MONEY_FORMAT)),cattributes=>' ALIGN="LEFT"' ),cattributes=>pfx.qcbground || ' ALIGN="CENTER"');
     htp.tablerowclose;
    end loop;
    for j in 1..3 loop
     htp.tablerowopen;
      htp.tabledata( htf.formtext( 'GCD', 20, 100 ),cattributes=>pfx.qcbground || 'ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'GCP', 11, 11 ),cattributes=>pfx.qcbground || 'ALIGN="CENTER"');
     htp.tablerowclose;
    end loop;
    htp.tableclose;

   else
    htp.formhidden( 'GCD', null );
    htp.formhidden( 'GCP', null );
  end if;

    htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.formsubmit( 'ACTION', LNG.PHG_BUT_116 );
 htp.formsubmit( 'ACTION', LNG.CST_BUT_018 );
 htp.formsubmit( 'ACTION', LNG.PHG_BUT_117 );
 htp.formsubmit( 'ACTION', LNG.PHG_BUT_118 );
 htp.p( '</CENTER>' );

 if c10rec.skill_level <> LNG2.PBK_TXT_080
  then

 htp.nl;
 htp.nl;
 htp.bold( LNG.PHG_TXT_212 );
 htp.nl; htp.italic( LNG.PHG_TXT_213);
 htp.nl; htp.italic( LNG.PHG_TXT_214);
 cprog := TRUE;

 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
 if substr(theme_rec.theme_data,101,1) = 'T' then
  htp.tablerowopen;
   if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_rld.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_136 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
   if substr(theme_rec.theme_data,94,1) = 'T'
    then
     htp.tabledata( htf.bold( LNG.PHG_TXT_341 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( htf.bold( LNG.PHG_TXT_215 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   if substr(theme_rec.theme_data,94,1) = 'T'
    then
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.p( GLBX.UPLOAD_NAME );
     htp.nl;
     htp.formradio( 'C94', 'T', 'CHECKED' );
     if c1rec.umo_type = 'PHOTO' then htp.p( ' ' || LNG.PHG_TXT_215 ); else htp.p( ' ' || LNG5.EXT_TXT_375 ); end if;
     htp.nl;
     htp.formradio( 'C94', 'F' );
     htp.p(' ' || LNG.PHG_TXT_342 );
     htp.p( '<TD>' );
    else
     htp.tabledata( GLBX.UPLOAD_NAME, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
  htp.tablerowclose;
  end if;
  if substr(theme_rec.theme_data,102,1) = 'T' then
  htp.tablerowopen;
   if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_cnv.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_137 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
   htp.tabledata( htf.bold( LNG.PHG_TXT_216), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formselectopen( 'P5' ) || htf.formselectoption( LNG.PHG_TXT_231, 'SELECTED' ) || htf.formselectoption( 'JPEG' ) || htf.formselectoption( 'GIF' ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end if;
 if substr(theme_rec.theme_data,103,1) = 'T' then
  htp.tablerowopen;
   if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_cmp.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_138 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
   htp.tabledata( htf.bold( LNG.PHG_TXT_217), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formselectopen( 'P6' ) || htf.formselectoption( LNG.PHG_TXT_231, 'SELECTED' ) ||
          htf.formselectoption( LNG.PHG_TXT_308 ) || htf.formselectoption( LNG.PHG_TXT_309 ) || htf.formselectoption( LNG.PHG_TXT_310 ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end if;
 if substr(theme_rec.theme_data,104,1) = 'T' then
  htp.tablerowopen;
   if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_baw.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_426 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
   htp.tabledata( htf.bold( LNG.PHG_ALT_426), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formselectopen( 'P12' ) || htf.formselectoption( LNG.PHG_TXT_231, 'SELECTED' ) || htf.formselectoption( LNG.PHG_ALT_426 ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end if;
 if substr(theme_rec.theme_data,105,1) = 'T' then
  if substr(theme_rec.theme_data,114,1) = 'T' and cprog
   then
    htp.tablerowopen;
     if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_rot.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_361 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
     htp.tabledata( htf.bold( LNG.PHG_TXT_362), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formselectopen( 'P10' ) || htf.formselectoption( LNG.PHG_TXT_231, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_466 ) || htf.formselectoption( LNG.PHG_TXT_467 ) || htf.formselectoption( LNG.PHG_TXT_468 ) || htf.formselectoption( LNG.PHG_TXT_469 ) || htf.formselectclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
   else
    htp.formhidden( 'P10',LNG.PHG_TXT_231);
  end if;
 end if;
 if substr(theme_rec.theme_data,106,1) = 'T' and cprog then
  tmp1 := htf.formselectoption( LNG.PHG_TXT_231, 'SELECTED' );
  for c6rec in c6(owner_id,acid) loop
   tmp1 := tmp1 || htf.formselectoption( c6rec.photo_name, cattributes=>'VALUE="' || c6rec.umo_id || '"' );
  end loop;
  if substr(theme_rec.theme_data,51,1) = 'T'
   then
       tmp1 := htf.formselectopen( 'P11' ) || tmp1 ||
                        htf.formselectoption('Text - Arial 10pt Black') ||
                        htf.formselectoption('Text - Arial 10pt White') ||
                        htf.formselectoption('Text - Arial 10pt Blue') ||
                        htf.formselectoption('Text - Arial 12pt Black') ||
                        htf.formselectoption('Text - Arial 12pt White') ||
                        htf.formselectoption('Text - Arial 12pt Blue') ||
                        htf.formselectoption('Text - Arial 14pt Black') ||
                        htf.formselectoption('Text - Arial 14pt White') ||
                        htf.formselectoption('Text - Arial 14pt Blue') || htf.formselectclose;

   htp.tablerowopen;
    if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_wtr.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_363 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
    htp.tabledata( htf.bold( LNG.PHG_TXT_364), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' ) ||
                   htf.tablerowopen || htf.tabledata( htf.bold( LNG.PHG_TXT_365) ) || htf.tabledata( tmp1 ) || htf.tablerowclose ||
                   htf.tablerowopen || htf.tabledata( htf.bold( LNG.PHG_TXT_366) ) || htf.tabledata( htf.formtext( 'P11A', 5, 5,'45' ) || htf.nl || LNG.PHG_ALT_404) || htf.tablerowclose ||
                   htf.tablerowopen ||
                     htf.tabledata( htf.bold( 'Watermark Text') ) || htf.tabledata( htf.formtext('P11B', 20, 100 ) ) ||
                   htf.tablerowclose ||
                   htf.tablerowopen || htf.tabledata( htf.bold( LNG.PHG_TXT_378) ) || htf.tabledata( htf.formselectopen('P11C') ||
                    htf.formselectoption( LNG.PHG_TXT_379 ) || htf.formselectoption( LNG.PHG_TXT_381 ) || htf.formselectoption( LNG.PHG_TXT_383 ) ||
                    htf.formselectoption( LNG.PHG_TXT_384 ) || htf.formselectoption( LNG.PHG_TXT_385, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_401 ) ||
                    htf.formselectoption( LNG.PHG_TXT_402 ) || htf.formselectoption( LNG.PHG_TXT_403 ) || htf.formselectoption( LNG.PHG_TXT_415 ) ||
                    htf.formselectclose ) || htf.tablerowclose ||
                   htf.tableclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
   else
    htp.formhidden( 'P11',LNG.PHG_TXT_231);
    htp.formhidden( 'P11A',null);
    htp.formhidden( 'P11B',null);
    htp.formhidden( 'P11C',null);
   end if;
 end if;
 if substr(theme_rec.theme_data,107,1) = 'T' then
  htp.tablerowopen;
   if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_scl.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_139 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
   htp.tabledata( htf.bold( LNG.PHG_TXT_218), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' ) ||
                  htf.tablerowopen || htf.tabledata( htf.bold( LNG.PHG_TXT_219) ) || htf.tabledata(htf.formtext( 'P7B', 5, 5 ) || ' ' || LNG.PHG_TXT_510 ) || htf.tablerowclose ||
                  htf.tablerowopen || htf.tabledata( htf.bold( LNG.PHG_TXT_220) ) || htf.tabledata(htf.formtext( 'P7A', 5, 5 )) || htf.tablerowclose ||
                  htf.tableclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end if;
 if substr(theme_rec.theme_data,108,1) = 'T' then
  htp.tablerowopen;
   if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_crp.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_405 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
   htp.tabledata( htf.bold( LNG.PHG_ALT_407), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' ) ||
                  htf.tablerowopen || htf.tabledata( htf.bold( LNG.PHG_TXT_219) ) || htf.tabledata(htf.formtext( 'P8A', 5, 5 )) ||
                                      htf.tabledata( htf.bold( LNG.PHG_TXT_020) ) || htf.tabledata(htf.formtext( 'P8B', 5, 5 )) || htf.tablerowclose ||
                  htf.tablerowopen || htf.tabledata( htf.bold( LNG.PHG_TXT_409) ) || htf.tabledata(htf.formtext( 'P8C', 5, 5 )) ||
                                      htf.tabledata( htf.bold( LNG.PHG_TXT_408) ) || htf.tabledata(htf.formtext( 'P8D', 5, 5 )) || htf.tablerowclose ||
                  htf.tableclose, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end if;
 if substr(theme_rec.theme_data,109,1) = 'T' then
  htp.tablerowopen;
   if c10rec.skill_level = LNG2.PBK_TXT_081 then htp.tabledata( htf.img( DECS.IMAGE_LOCATION || 'admin/phgr_rth.gif',cattributes=>'width=' || HAW || ' height=' ||HAW || ' border=0',calt=>LNG.PHG_ALT_406 ), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"'); end if;
   htp.tabledata( htf.bold( LNG.PHG_ALT_410), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' || '>' );
   htp.p( htf.bold( LNG.PHG_ALT_411) || ' ' || htf.formtext( 'P9', 5, 5 ) || htf.nl || htf.bold( LNG.PHG_TXT_324) || ' ');
   thb_qual := nvl(glbx.userpref( owner_id, acid, 'SUPER_THB' ),'1');
   /*
   htp.formselectopen( 'PR9Q' );
   for j in 1..8 loop
    if to_char(j) = thb_qual
     then
      htp.formselectoption( to_char(j), 'SELECTED' );
     else
      htp.formselectoption( to_char(j) );
    end if;
   end loop;
   htp.formselectclose;
   */
   htp.p( glbx.quality_loop( 'PR9Q', thb_qual ) );
   htp.p( '</TD>' );
  htp.tablerowclose;
  end if;
  if (substr(theme_rec.theme_data,64,1) = 'T') and (nvl(c1rec.photo_backup.contentlength,0) > 0)
   then
    htp.tablerowopen;
     htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="CENTER"');
     htp.tabledata( htf.bold( LNG.PHG_TXT_434), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formcheckbox( 'PRST','T'), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
  end if;

 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.PHG_BUT_116 );
 htp.formsubmit( 'ACTION', LNG.CST_BUT_018 );
 htp.formsubmit( 'ACTION', LNG.PHG_BUT_117 );
 htp.formsubmit( 'ACTION', LNG.PHG_BUT_118 );
 htp.formclose;

 end if; -- End Novice Check

 htp.nl;

 htp.bold( LNG.PHG_TXT_461 );
 htp.nl;
 foundrec := FALSE;
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.italic( LNG.PHG_TXT_463), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.italic( LNG.PHG_TXT_464), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.italic( LNG.PHG_TXT_465), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 for c7rec in c7(acid,c1rec.umo_id) loop
  foundrec := TRUE;
  htp.tablerowopen;
   if c7rec.mod_type in ('FILE','UPLOAD')
    then
     htp.tabledata( LNG2.PBK_TXT_115, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( LNG2.PBK_TXT_116, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.tabledata( to_char(c7rec.date_modified,LNG.TSMASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c7rec.mod_type), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( nvl(c7rec.extra_det,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 if not foundrec then htp.italic( LNG.PHG_TXT_462 ); htp.nl; end if;
 htp.nl;
 htp.bold( LNG.PHG_TXT_221 );
 imgtot := 0;
 open c12a(phgid);
 fetch c12a into imgtot;
 close c12a;
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.anchor( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&v_umo=' || c1rec.umo_id || '&mthod=WEB&purchid=&acid=' || acid, LNG2.PBK_TXT_128), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG4.AHC_TXT_300), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( imgtot ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_222), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_master.width), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_223), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_master.height), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_224), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_master.contentlength), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_225), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_master.fileformat), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_226), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_master.contentformat), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_227), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_master.compressionformat), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_228), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_master.mimetype), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_229), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_original_loc), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  c15rec.ctr := null;
  open c15(acid, 330);
  fetch c15 into c15rec;
  close c15;
  if c15rec.ctr = 'x'
   then
   htp.tablerowopen;
    htp.tabledata( htf.italic('View Image Meta Data'), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.anchor('javascript: window.open(''' || 'phg.metatag?surl=' || surl || '&acid=' || acid || '&v_umo=' || c1rec.umo_id || '&metaload=' || replace('IPTC Standard',' ','+') ||
                ''',''' || replace(LNG5.EXT_TXT_301 || 'XXXA',' ','_') ||
                ''',''height=800,width=800,scrollbars=yes,resizable=yes'');void('''');',
                'IPTC Standard' );
     htp.p( ' ' );
     htp.anchor('javascript: window.open(''' || 'phg.metatag?surl=' || surl || '&acid=' || acid || '&v_umo=' || c1rec.umo_id || '&metaload=' || replace('XML Format',' ','+') ||
                ''',''' || replace(LNG5.EXT_TXT_301 || 'XXXB',' ','_') ||
                ''',''height=800,width=800,scrollbars=yes,resizable=yes'');void('''');',
                'XML Format' );
     htp.p( ' ' );
     htp.anchor('javascript: window.open(''' || 'phg.metatag?surl=' || surl || '&acid=' || acid || '&v_umo=' || c1rec.umo_id || '&metaload=' || replace('EXIF',' ','+') ||
                ''',''' || replace(LNG5.EXT_TXT_301 || 'XXXC',' ','_') ||
                ''',''height=800,width=800,scrollbars=yes,resizable=yes'');void('''');',
                'EXIF' );

    htp.p( '</TD>' );
   htp.tablerowclose;
  end if;
  htp.tableclose;
 htp.nl;
 htp.bold( LNG.PHG_TXT_230 );
 imgtot := 0;
 open c12b(phgid);
 fetch c12b into imgtot;
 close c12b;
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.anchor( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&v_umo=' || c1rec.umo_id || '&mthod=TNAIL&purchid=&acid=' || acid, LNG2.PBK_TXT_128), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG4.AHC_TXT_300), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( imgtot ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_222), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_thumbnail.width), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_223), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_thumbnail.height), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_224), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_thumbnail.contentlength), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_225), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_thumbnail.fileformat), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_226), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_thumbnail.contentformat), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_227), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_thumbnail.compressionformat), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.italic( LNG.PHG_TXT_228), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.bold( c1rec.photo_thumbnail.mimetype), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 if nvl(dbms_lob.getlength(c1rec.photo_original.source.localdata),0) > 0
  then
   htp.nl;
   htp.bold( LNG.PHG_TXT_049 );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata( '&nbsp;', cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.anchor( 'fname.download_file?surl=' || glbx.rndsurl(surl) || '&v_umo=' || c1rec.umo_id || '&mthod=ORIGINAL&purchid=&acid=' || acid, LNG2.PBK_TXT_128), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.italic( LNG.PHG_TXT_222), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold( nvl(to_char(c1rec.photo_original.width),LNG.PHG_TXT_247)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.italic( LNG.PHG_TXT_223), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold( nvl(to_char(c1rec.photo_original.height),LNG.PHG_TXT_247)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.italic( LNG.PHG_TXT_224), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold(dbms_lob.getlength(c1rec.photo_original.source.localdata)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.italic( LNG.PHG_TXT_225), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold( nvl(c1rec.photo_original.fileformat,LNG.PHG_TXT_247)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.italic( LNG.PHG_TXT_226), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold( nvl(c1rec.photo_original.contentformat,LNG.PHG_TXT_247)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.italic( LNG.PHG_TXT_227), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold( nvl(c1rec.photo_original.compressionformat,LNG.PHG_TXT_247)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.italic( LNG.PHG_TXT_228), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.bold( nvl(c1rec.photo_original.mimetype,LNG.PHG_TXT_247)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
   htp.tableclose;
 end if;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_MODIFY',owner_id,acid,phgid,errmsg=>sqlerrm);
end phg_modify;

procedure accept_phg_modify( surl in varchar2,file in varchar2 default NULL, acid in integer, phgid in integer, ftp in varchar2 default null, ftpv in varchar2 default null, c94 in varchar2 default 'T',
                             p1 in varchar2, p2 in varchar2, p3 in varchar2, p3i in varchar2, p3r in varchar2, p3f in varchar2, p3z in varchar2, p3n in varchar2, p3s in varchar2, isglobal in varchar2 default 'F', pricing in varchar2 default 'S',
                             p4 in varchar2 default 'FALSE', p5 in varchar2 default LNG.PHG_TXT_231, p6 in varchar2 default LNG.PHG_TXT_231, p7a in varchar2 default null, p7b in varchar2 default null,
                             p8a in varchar2 default null, p8b in varchar2 default null, p8c in varchar2 default null, p8d in varchar2 default null, prst in varchar2 default 'F', pr9q in varchar2 default '1',
                             p9 in varchar2 default null, p10 in varchar2 default LNG.PHG_TXT_231 , p11 in varchar2 default LNG.PHG_TXT_231, p11a in varchar2 default null, p11b in varchar2 default null, p11c in varchar2 default null, p12 in varchar2 default LNG.PHG_TXT_231, action in varchar2,
                             footer_api in varchar2, left_api_parm in varchar2, current_page_number in varchar2, display_detail in varchar2, gcd in glbx.myarray, gcp in glbx.myarray, tag_id in glbx.myarray, tag_name in glbx.myarray, tag_value in glbx.myarray)
as

  cursor c1(phgr integer, acid integer, v_umo integer) is
   select um.photo_master
   from umo um,customer_account ca
   where umo_id = v_umo and
         um.aid = ca.aid and
         ca.pid = phgr;
  cursor c2(phg_id integer) is select umo_type, extras from umo where umo_id = phg_id;

 ph1		ORDSYS.ORDIMAGE;
 ph2		ORDSYS.ORDIMAGE;
 theme_rec	theme_types%ROWTYPE;
 res		boolean;
 sts		varchar2(200);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 retval		varchar2(4000);
 nmb		integer;
 err		varchar2(200);
 utype		varchar2(100);
 old_utype	varchar2(100);
 parm1		ump.parameters;
 parm2		ump.parameters;
 newid_arr	ump.myarray_int;
 reterrors	GLBX.MYARRAY;
 reterrors_ctr	integer;
 parmctr	integer;
 recnail	boolean;
 xcoord		integer;
 ycoord		integer;
 wsts		integer;
 xt		REPEATED_FIELDS;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_PHG_MODIFY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
reterrors_ctr := 0;
open c2(phgid);
fetch c2 into utype, xt;
close c2;
old_utype := utype;

theme_rec := get_theme_types( surl,acid );
 if action = LNG.PHG_BUT_118 and utype in ('PHOTO','VIDEO','AUDIO','BLUEPRINT','RELATIONAL','DOCUMENT')
  then
    if footer_api = 'FAST' then photo_fast_edit_acct_mst(surl=>surl,acid=>acid,stype=>stype); return; end if;
    execute immediate
     'begin ' || footer_api ||
      '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
     'end;'
     using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
   --phg_disp_by_scene(surl,acid,to_number(p1),photo_ctr);
   return;
 end if;

 if action = LNG.PHG_BUT_118 and utype = 'GALLERY' then manage_gallery(surl,acid,null); return; end if;


 if action = LNG.PHG_BUT_117
  then
   parm1(1) := 'UMO_ID';
   parm2(1) := to_char(phgid);
   parm1(2) := 'AID';
   parm2(2) := to_char(acid);
   parm1(3) := 'OBJECT_TYPE';
   parm2(3) := utype;
   parm1(4) := 'KEEP_STATUS';
   parm2(4) := 'DELETE';
   parm1(5) := 'OWS_NAME';
   parm2(5) := file;
   ump.modify_uma(surl,parm1,parm2,retval);
   if utype = 'GALLERY'
    then
     manage_gallery(surl,acid,null);
    else
    if footer_api = 'FAST' then photo_fast_edit_acct_mst(surl=>surl,acid=>acid,stype=>stype); return; end if;
    execute immediate
     'begin ' || footer_api ||
      '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
     'end;'
     using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
     --phg_disp_by_scene(surl,acid,to_number(p1),photo_ctr);
   end if;
   return;
 end if;

 -- Update fixed values
 -- If a photo is classed as DETAIL then it has to be enabled.

if file is not null
 then
  parm1(1) := 'UMO_ID';
  parm2(1) := to_char(phgid);
  parm1(2) := 'AID';
  parm2(2) := to_char(acid);
  parm1(3) := 'OBJECT_TYPE';
  -- Puts some smarts here so you can attach an Image to a non Photo Object
  if (utype in ('AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
      upper(glbx.extract_fname( file, 'SUFFIX' )) in ( 'JPEG','JPG','TIFF','GIF'))
    or
     (utype = 'DOCUMENT')
   then
    old_utype := 'PHOTO';
  end if;
  parm2(3) := old_utype;
  parm1(4) := 'KEEP_STATUS';
  parm2(4) := 'LOAD AGAIN';
  parm1(5) := 'OWS_NAME';
  parm2(5) := file;
  parm1(6) := 'LOAD_FROM_FILE_OR_UPLOAD';
  parm2(6) := 'UPLOAD';
  parm1(7) := 'ORIGINAL_LOCATION';
  parm2(7) := file;
  parm1(8) := 'BYPASS_QUOTA_CHECK';
  parm2(8) := 'FALSE';
  parm1(9) := 'CREATE_THUMBNAIL';
  parm2(9) := 'TRUE';
  parm1(10) := 'THUMBNAIL_WIDTH';
  parm2(10) := nvl(glbx.photo_pref(owner_id,acid,'THUMBNAIL_WIDTH'),'100');
  parm1(11) := 'THUMBNAIL_QUALITY';
  parm2(11) := pr9q;
  parm1(12) := 'PHGR_ID';
  parm2(12) := to_char(owner_id);
  parm1(13) := 'STORE_ORIGINAL';
  parm2(13) := 'FALSE';
  parm1(14) := 'RELOAD_PHOTO';
  parm2(14) := nvl(c94,'T');
  if utype = 'PHOTO'
   then
    parm1(15) := 'SCENE_ID';
    parm2(15) := p1;
  elsif utype = 'DOCUMENT'
   then
    parm1(15) := 'MAGICK_CONVERT_ID';
    parm2(15) := '170';
  end if;
  ump.load_uma(surl,parm1,parm2,retval, newid_arr ); nmb := newid_arr(1);
  if retval is not null
   then
    reterrors_ctr := reterrors_ctr + 1;
    reterrors(reterrors_ctr) := LNG.PHG_ALT_412 || retval;
    phg_modify(surl,acid,phgid,reterrors,footer_api,left_api_parm,current_page_number,display_detail);
    return;
  end if;
end if;

if substr(theme_rec.theme_data,89,1) = 'T'
 then
   res := glbx.update_meta_data( surl, phgid, acid, utype, ltype, tag_id, tag_name, tag_value, reterrors, reterrors_ctr);
   if reterrors_ctr > 0
    then
     phg_modify(surl,acid,phgid,reterrors,footer_api,left_api_parm,current_page_number,display_detail);
     return;
   end if;
end if;

recnail := FALSE;
parm1(1) := 'UMO_ID';
parm2(1) := to_char(phgid);
parm1(2) := 'AID';
parm2(2) := to_char(acid);
parm1(3) := 'OBJECT_TYPE';
parm2(3) := utype;
parm1(4) := 'KEEP_STATUS';
parm2(4) := 'KEEP';
parm1(5) := 'ROLL_ID';
parm2(5) := nvl(p3r,LNG2.FNM_TXT_004);
parm1(6) := 'FILM_SIZE';
parm2(6) := p3z;
parm1(7) := 'FILM_TYPE';
parm2(7) := p3f;
if utype = 'PHOTO'
 then
  parm1(8) := 'FILM_NAME';
 else
  parm1(8) := 'NAME';
end if;
parm2(8) := nvl(p3,'No Name');
parm1(9) := 'PHOTOGRAPHER';
parm2(9) := p4;
if utype <> 'GALLERY'
 then
  parm1(10) := 'SCENE_ID';
  parm2(10) := p1;
 else
  parm1(10) := NULL;
  parm2(10) := NULL;
end if;
begin nmb := to_number(p3n); exception when others then nmb := 1; end;
parm1(11) := 'NEG_NO';
parm2(11) := to_char(nmb);
parm1(12) := 'CREATE_THUMBNAIL';
parm2(12) := 'TRUE';
parm1(13) := 'THUMBNAIL_QUALITY';
parm2(13) := pr9q;
parm1(14) := 'PRICING_STRUCTURE';
parm2(14) := pricing;
parm1(15) := 'BRIDAL';
parm2(15) := xt.enabled_cus;
parm1(16) := 'NAME';
parm2(16) := xt.photo_name;
begin nmb := to_number(p3s); exception when others then nmb := 1; end;
if nmb < 1 then nmb := 1; elsif nmb > 100 then nmb := 100; end if;
parm1(17) := 'SORT_PRIORITY';
parm2(17) := to_char(nmb);

if utype = 'PHOTO'
 then
  parm1(18) := 'QUALITY';
  parm2(18) := p2;
  parmctr := 19;
 else
  parm1(18) := 'DETAILS';
  parm2(18) := p2;
  parm1(19) := 'NAME';
  parm2(19) := p1;
  parmctr := 20;
end if;

if substr(theme_rec.theme_data,202,1) = 'T'
 then
  parm1(parmctr) := 'IMAGE CAPTION';
  parm2(parmctr) := glbx.censor(p3i,1000);
  parmctr := parmctr + 1;
end if;

if substr(theme_rec.theme_data,97,1) = 'T'
 then
  parm1(parmctr) := 'FTP_LOCATION';
  parm2(parmctr) := ftp;
  parmctr := parmctr + 1;
  parm1(parmctr) := 'FTP_LOCATION_DIR';
  parm2(parmctr) := ftpv;
  parmctr := parmctr + 1;
end if;

if substr(theme_rec.theme_data,134,1) = 'T'
 then
   parm1(parmctr) := 'IS_GLOBAL';
   parm2(parmctr) := isglobal;
   parmctr := parmctr + 1;
 end if;

 if p5 <> LNG.PHG_TXT_231
  then
   recnail := TRUE;
   parm1(parmctr) := 'CONVERT_TO';
   parm2(parmctr) := p5;
   parmctr := parmctr + 1;
 end if;

 if substr(theme_rec.theme_data,64,1) = 'T'
  then
   parm1(parmctr) := 'BACKUP_PHOTO';
   parm2(parmctr) := 'TRUE';
   parmctr := parmctr + 1;
   if prst = 'T'
    then
     recnail := TRUE;
     parm1(parmctr) := 'RESTORE_PHOTO';
     parm2(parmctr) := 'TRUE';
     parmctr := parmctr + 1;
   end if;
 end if;

 if p6 <> LNG.PHG_TXT_231
  then
   recnail := TRUE;
   parm1(parmctr) := 'COMPRESSION';
   parm2(parmctr) := p6;
   parmctr := parmctr + 1;
 end if;

 if p12 <> LNG.PHG_TXT_231
  then
   recnail := TRUE;
   parm1(parmctr) := 'GRAYSCALE';
   parm2(parmctr) := 'TRUE';
   parmctr := parmctr + 1;
 end if;

 if (p7a is not null) or (p7b is not null)
  then
   recnail := TRUE;
   parm1(parmctr) := 'RESIZE_WIDTH';
   begin nmb := to_number(p7b); if nmb <0  then nmb := 100; end if; exception when others then nmb := 100; end;
   parm2(parmctr) := to_char(nmb);
   parmctr := parmctr + 1;
   parm1(parmctr) := 'RESIZE_HEIGHT';
   begin nmb := to_number(p7a); if nmb <0  then nmb := 100; end if; exception when others then nmb := 100; end;
   parm2(parmctr) := to_char(nmb);
   parmctr := parmctr + 1;
 end if;

 if (p8a is not null)
  then
   recnail := TRUE;
   parm1(parmctr) := 'CROP_M_COORD';
   begin nmb := to_number(p8a); if nmb <0  then nmb := 100; end if; exception when others then nmb := 100; end;
   parm2(parmctr) := to_char(nmb);
   parmctr := parmctr + 1;
   parm1(parmctr) := 'CROP_N_COORD';
   begin nmb := to_number(p8b); if nmb <0  then nmb := 100; end if; exception when others then nmb := 100; end;
   parm2(parmctr) := to_char(nmb);
   parmctr := parmctr + 1;
   parm1(parmctr) := 'CROP_X_COORD';
   begin nmb := to_number(p8c); if nmb <0  then nmb := 0; end if; exception when others then nmb := 0; end;
   parm2(parmctr) := to_char(nmb);
   parmctr := parmctr + 1;
   parm1(parmctr) := 'CROP_Y_COORD';
   begin nmb := to_number(p8d); if nmb <0  then nmb := 0; end if; exception when others then nmb := 0; end;
   parm2(parmctr) := to_char(nmb);
   parmctr := parmctr + 1;
   parm1(parmctr) := 'CROP';
   parm2(parmctr) := 'TRUE';
   parmctr := parmctr + 1;
 end if;

 if (p9 is not null)
  then
   recnail := TRUE;
   parm1(parmctr) := 'THUMBNAIL_WIDTH';
   begin nmb := to_number(p9); if nmb <0  then nmb := to_number(nvl(glbx.photo_pref(owner_id,acid,'THUMBNAIL_WIDTH'),'100')); end if; exception when others then nmb := to_number(nvl(glbx.photo_pref(owner_id,acid,'THUMBNAIL_WIDTH'),'100')); end;
   parm2(parmctr) := to_char(nmb);
   parmctr := parmctr + 1;
   parm1(parmctr) := 'THUMBNAIL_QUALITY';
   parm2(parmctr) := pr9q;
   parmctr := parmctr + 1;
 end if;

 if p10 <> LNG.PHG_TXT_231
  then
   recnail := TRUE;
   parm1(parmctr) := 'ROTATE';
   parm2(parmctr) := p10;
   parmctr := parmctr + 1;
 end if;

 if p11 <> LNG.PHG_TXT_231
  then
   recnail := TRUE;
   parm1(parmctr) := 'MERGE';
   parm2(parmctr) := 'TRANSPARENT_OFFSET';
   parmctr := parmctr + 1;
   parm1(parmctr) := 'MERGE_LUCENT_OFFSET';
   begin nmb := to_number(p11a); if nmb <0 or nmb >100 then nmb := 45; end if; exception when others then nmb := 45; end;
   parm2(parmctr) := to_number(nmb);
   parmctr := parmctr + 1;
   parm1(parmctr) := 'MERGE_UMO_ID';
   if substr(p11,1,1) = 'T'
    then
     parm2(parmctr) := p11;
     open c1(owner_id,acid,phgid);
     fetch c1 into ph1;
     close c1;
     ph2 := ordsys.ordimage.init();
     ph2.width := 1;
     ph2.height := 1;
    else
     nmb := to_number(p11);
     open c1(owner_id,acid,phgid);
     fetch c1 into ph1;
     close c1;
     open c1(owner_id,acid,nmb);
     fetch c1 into ph2;
     close c1;
     parm2(parmctr) := to_char(nmb);
   end if;
   glbx.determine_wm( ph1, ph2, p11c, xcoord, ycoord, wsts);

   if wsts = 1
    then
     htp.htmlopen; htp.header(3,LNG.PHG_TXT_457 ); htp.htmlclose; return;
   elsif wsts = 2
    then
     htp.htmlopen; htp.header(3,LNG.PHG_TXT_458 ); htp.htmlclose; return;
   elsif wsts = 3
    then
     htp.htmlopen; htp.header(3,LNG.PHG_TXT_459 ); htp.htmlclose; return;
   end if;
   parmctr := parmctr + 1;
   parm1(parmctr) := 'MERGE_X_COORD';
   parm2(parmctr) := to_char(xcoord);
   parmctr := parmctr + 1;
   parm1(parmctr) := 'MERGE_Y_COORD';
   parm2(parmctr) := to_char(ycoord);
   -- Set Transparency
   parmctr := parmctr + 1;
   parm1(parmctr) := 'MERGE_TEXT';
   parm2(parmctr) := p11b;
   parmctr := parmctr + 1;
end if;

 if not recnail
  then
   parm1(12) := 'CREATE_THUMBNAIL';
   parm2(12) := 'FALSE';
 end if;

 delete from gallery_charge where umo_id = phgid; -- Delete in case of Individual Pricing being switched back to standard
 if utype = 'GALLERY' or pricing = 'I'
   then
    for j in gcd.first..gcd.last loop
     if gcp(j) is not null and gcd(j) is not null
      then
       nmb := nvl(glbx.conv_nmb(gcp(j)),0);
       insert into gallery_charge(umo_id,charge_desc,charge) values (phgid,nvl(gcd(j),'Reorder'),nmb);
     end if;
    end loop;
    commit;
 end if;

 /*
 for j in parm1.first..parm1.last loop
  htp.p( parm1(j) || '-' || parm2(j) ); htp.nl;
 end loop;
 */
 ump.modify_uma(surl,parm1,parm2,retval);

 if action = LNG.CST_BUT_018 and utype in ('PHOTO','VIDEO','AUDIO','BLUEPRINT','RELATIONAL','DOCUMENT') and retval is null
  then
    if footer_api = 'FAST' then photo_fast_edit_acct_mst(surl=>surl,acid=>acid,stype=>stype); return; end if;
    execute immediate
     'begin ' || footer_api ||
      '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
     'end;'
     using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
   return;
 end if;
 if action = LNG.CST_BUT_018 and utype = 'GALLERY' then manage_gallery(surl,acid,retval); return; end if;

 reterrors_ctr := reterrors_ctr + 1;
 reterrors(reterrors_ctr) := nvl(retval,LNG.PHG_TXT_232);

 phg_modify( surl,acid, phgid, reterrors, footer_api, left_api_parm, current_page_number, display_detail );

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_PHG_MODIFY',owner_id,acid,errmsg=>sqlerrm,extdet=>'FILE:' || file);
end accept_phg_modify;

procedure phg_personal(surl in varchar2,msg in varchar2 default null)
is

 cursor c1(phgid integer) is select * from photographer where pid=phgid;
 cursor c2 is select scene_name from scene order by scene_name;
 cursor c3(phid integer) is select theme_name from theme order by theme_name;
 cursor c3a is select theme_type from theme_types order by theme_type;
 cursor c9(phid integer) is select scene_name from limit_scenes where pid = phid order by scene_name;
 cursor c10(phid integer) is select theme_name from limit_laf where pid = phid order by theme_name;
 cursor c11(phid integer) is select limit_scene,limit_laf,limit_bf,skill_level from photographer where pid = phid;
 cursor c12(phid integer) is select theme_type from limit_bf where pid = phid order by theme_type;

 c1rec		c1%ROWTYPE;
 c11rec		c11%ROWTYPE;

 sts		varchar2(200);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 pfx		theme%ROWTYPE;
 -- pfx		varchar2(4);
 tmp		varchar2(2000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PERSONAL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 -- pfx := glbx.get_hfx( owner_id );
 pfx := glbx.photo_lf(owner_id);
 open c1( owner_id );
 fetch c1 into c1rec;
 close c1;
 open c11( owner_id );
 fetch c11 into c11rec;
 close c11;
 glbx.main_title( surl, LNG.PHG_TXT_233,null,helpid=>'P15',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.formopen( 'PHG.ACCEPT_PHG_PERSONAL' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.CST_TXT_004),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P1',60, 100, c1rec.business_name),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(c1rec.abn_title),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P11',20, 100, c1rec.abn_number),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   -- xxx language file
   htp.tablerowopen;
    htp.tabledata(htf.bold('Title for ABN Number (Unique Business Identifier)'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P11A',20, 100, c1rec.abn_title),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_235),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P2',60, 1000, c1rec.business_desc),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_236),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P3',60, 2000, c1rec.home_site),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_497),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P16',60, 2000, c1rec.private_gallery),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_022),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P12',60, 100, c1rec.contact_name),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_237),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P4',30, 30, c1rec.work_phone),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_301),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P4B',30, 100, c1rec.contact_email),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_336),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P4A',30, 100, c1rec.contact_fax),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_238),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P5',30, 30, c1rec.mobile_phone),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG2.PFM_TXT_077),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    if c1rec.enable_sms = 'T'
     then
       htp.tabledata(htf.formcheckbox( 'P5A','T', 'CHECKED'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
       htp.tabledata(htf.formcheckbox( 'P5A','T'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG2.PFM_TXT_078),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P5B',30, 30, c1rec.notify_order_min),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_239),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P6',60, 100, c1rec.contact_street),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_240),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P7',60, 100, c1rec.contact_suburb),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_241),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P8',60, 100, c1rec.contact_city),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_242),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P9',10, 10, c1rec.contact_pcode),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if c1rec.skill_control = 'T'
    then
     htp.tablerowopen;
      htp.tabledata(htf.bold(LNG2.PBK_TXT_083),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
       htp.formselectopen( 'P18' );
        if c1rec.skill_level = LNG2.PBK_TXT_080
         then
          htp.formselectoption( LNG2.PBK_TXT_080, 'SELECTED' );
         else
          htp.formselectoption( LNG2.PBK_TXT_080 );
        end if;
        if c1rec.skill_level = LNG2.PBK_TXT_081
         then
          htp.formselectoption( LNG2.PBK_TXT_081, 'SELECTED' );
         else
          htp.formselectoption( LNG2.PBK_TXT_081 );
        end if;
        if c1rec.skill_level = LNG2.PBK_TXT_082
         then
          htp.formselectoption( LNG2.PBK_TXT_082, 'SELECTED' );
         else
          htp.formselectoption( LNG2.PBK_TXT_082 );
        end if;
       htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
    else
     htp.formhidden( 'P18', null );
   end if;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_243),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata(htf.formtext( 'P10',20, 20, c1rec.dob),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   -- xxx for language file
   htp.tablerowopen;
    htp.tabledata(htf.bold('Credit Cards to be used in Cheque/Money Order Display Screen'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT" colspan="2"');
   htp.tablerowclose;
   --if glbx.extract_master_parameter('ENABLE_PHOTOGRAPHER_CC') = 'TRUE'
   -- then
    htp.tablerowopen;
     htp.tabledata(htf.bold(LNG4.AHC_TXT_480),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
     tmp := NULL;
     if c1rec.cc_mastercard = 'T'
      then
       tmp := tmp || htf.formcheckbox( 'P17A','T','CHECKED' );
      else
       tmp := tmp || htf.formcheckbox( 'P17A','T' );
     end if;
     tmp := tmp || ' Mastercard' || htf.nl;
     if c1rec.cc_visa = 'T'
      then
       tmp := tmp || htf.formcheckbox( 'P17B','T','CHECKED' );
      else
       tmp := tmp || htf.formcheckbox( 'P17B','T' );
     end if;
     tmp := tmp || ' Visa' || htf.nl;
     if c1rec.cc_bankcard = 'T'
      then
       tmp := tmp || htf.formcheckbox( 'P17C','T','CHECKED' );
      else
       tmp := tmp || htf.formcheckbox( 'P17C','T' );
     end if;
     tmp := tmp || ' Bankcard' || htf.nl;
     if c1rec.cc_amex = 'T'
      then
       tmp := tmp || htf.formcheckbox( 'P17D','T','CHECKED' );
      else
       tmp := tmp || htf.formcheckbox( 'P17D','T' );
     end if;
     tmp := tmp || ' Amex' || htf.nl;
     if c1rec.cc_diners = 'T'
      then
       tmp := tmp || htf.formcheckbox( 'P17E','T','CHECKED' );
      else
       tmp := tmp || htf.formcheckbox( 'P17E','T' );
     end if;
     tmp := tmp || ' Diners';
     htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
   /*
   else
    htp.formhidden( 'P17A', c1rec.cc_mastercard );
    htp.formhidden( 'P17B', c1rec.cc_visa );
    htp.formhidden( 'P17C', c1rec.cc_bankcard );
    htp.formhidden( 'P17D', c1rec.cc_amex );
    htp.formhidden( 'P17E', c1rec.cc_diners );
  end if;
  */

  if c1rec.credit_card_access = 'T'
   then
    htp.tablerowopen;
    htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="LEFT">' );
     htp.bold( LNG4.AHC_TXT_475 ); htp.nl;
     htp.bold( LNG4.AHC_TXT_476 ); htp.nl;
     htp.bold( LNG4.AHC_TXT_477 ); htp.nl;
     htp.bold( LNG4.AHC_TXT_478 ); htp.nl;
     htp.bold( LNG4.AHC_TXT_479 ); htp.nl;
     htp.bold( LNG5.EXT_TXT_531 ); htp.nl;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'PMCA' );
       htp.formselectoption( NULL );
       if c1rec.merchant_used = 'ANZ' then htp.formselectoption( 'ANZ', 'SELECTED' ); else htp.formselectoption( 'ANZ' ); end if;
       if c1rec.merchant_used = 'ANZ-II' then htp.formselectoption( 'ANZ-II', 'SELECTED' ); else htp.formselectoption( 'ANZ-II' ); end if;
       if c1rec.merchant_used = 'CBANK' then htp.formselectoption( 'CBANK', 'SELECTED' ); else htp.formselectoption( 'CBANK' ); end if;
       if c1rec.merchant_used = 'CYBERONE' then htp.formselectoption( 'CYBERONE', 'SELECTED' ); else htp.formselectoption( 'CYBERONE' ); end if;
       if c1rec.merchant_used = 'ESEC' then htp.formselectoption( 'ESEC', 'SELECTED' ); else htp.formselectoption( 'ESEC' ); end if;
       if c1rec.merchant_used = 'SAFEPAY' then htp.formselectoption( 'SAFEPAY', 'SELECTED' ); else htp.formselectoption( 'SAFEPAY' ); end if;
       if c1rec.merchant_used = 'SECUREPAY' then htp.formselectoption( 'SECUREPAY', 'SELECTED' ); else htp.formselectoption( 'SECUREPAY' ); end if;
       if c1rec.merchant_used = 'SECUREBILL' then htp.formselectoption( 'SECUREBILL', 'SELECTED' ); else htp.formselectoption( 'SECUREBILL' ); end if;
       if c1rec.merchant_used = 'NAB' then htp.formselectoption( 'NAB', 'SELECTED' ); else htp.formselectoption( 'NAB' ); end if;
       if c1rec.merchant_used = 'DIRECT PAYMENT(NZ)' then htp.formselectoption( 'DIRECT PAYMENT(NZ)', 'SELECTED' ); else htp.formselectoption( 'DIRECT PAYMENT(NZ)' ); end if;
    htp.formselectclose;
    htp.nl;
    htp.formtext( 'PMCB', 40, 1000, c1rec.merchant_id );
    htp.nl;
    htp.formtext( 'PMCC', 40, 1000, c1rec.merchant_url_site );
    htp.nl;
    htp.formtext( 'PMCD', 40, 1000, c1rec.merchant_return_url );
    htp.nl;
    if c1rec.merchant_popup_window = 'TRUE'
     then
      htp.formcheckbox( 'PMCE','TRUE','CHECKED');
     else
      htp.formcheckbox( 'PMCE','TRUE');
    end if;
    htp.nl;
    if c1rec.merchant_window_notitle = 'TRUE'
     then
      htp.formcheckbox( 'PMCF','TRUE','CHECKED');
     else
      htp.formcheckbox( 'PMCF','TRUE');
    end if;
    htp.p( '</TD>' );
    htp.tablerowclose;
  else
   htp.formhidden( 'PMCA', null );
   htp.formhidden( 'PMCB', null );
   htp.formhidden( 'PMCC', null );
   htp.formhidden( 'PMCD', null );
   htp.formhidden( 'PMCE', null );
   htp.formhidden( 'PMCF', null );
  end if;

   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG2.PFM_TXT_035),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
     htp.formselectopen( 'P19A' );
     htp.formselectoption( NULL );
       if c11rec.limit_scene = 'T'
        then
         for c2rec in c2 loop
          if c1rec.default_category = c2rec.scene_name
           then
            htp.formselectoption( c2rec.scene_name, 'SELECTED' );
           else
            htp.formselectoption( c2rec.scene_name );
          end if;
         end loop;
        else
         for c9rec in c9(owner_id) loop
          if c1rec.default_category = c9rec.scene_name
           then
            htp.formselectoption( c9rec.scene_name, 'SELECTED' );
           else
            htp.formselectoption( c9rec.scene_name );
          end if;
         end loop;
       end if;
     htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG4.AHC_TXT_307),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
     htp.formselectopen( 'P19B' );
     htp.formselectoption( NULL );
       if c11rec.limit_bf = 'T'
        then
         for c3arec in c3a loop
          if c1rec.default_bf = c3arec.theme_type
           then
            htp.formselectoption( c3arec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c3arec.theme_type );
          end if;
         end loop;
        else
         for c12rec in c12(owner_id) loop
          if c1rec.default_bf = c12rec.theme_type
           then
            htp.formselectoption( c12rec.theme_type, 'SELECTED' );
           else
            htp.formselectoption( c12rec.theme_type );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG4.AHC_TXT_308),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
     htp.formselectopen( 'P19C' );
     htp.formselectoption( NULL );
       if c11rec.limit_laf = 'T'
        then
         for c3rec in c3(owner_id) loop
          if c1rec.default_lf = c3rec.theme_name
           then
            htp.formselectoption( c3rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c3rec.theme_name );
          end if;
         end loop;
        else
         for c10rec in c10(owner_id) loop
          if c1rec.default_lf = c10rec.theme_name
           then
            htp.formselectoption( c10rec.theme_name, 'SELECTED' );
           else
            htp.formselectoption( c10rec.theme_name );
          end if;
         end loop;
       end if;
       htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata(htf.bold(replace(LNG.PHG_TXT_498,'<PHOTOGRAPHER>',c1rec.photographer_title)),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P13' );
   for j in 0..23 loop
    if c1rec.business_hours_min = j
     then
      tmp := tmp || htf.formselectoption(j,'SELECTED');
     else
      tmp := tmp || htf.formselectoption(j);
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_487),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P14' );
   for j in 0..23 loop
    if c1rec.business_hours_max = j
     then
      tmp := tmp || htf.formselectoption(j,'SELECTED');
     else
      tmp := tmp || htf.formselectoption(j);
    end if;
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_487),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_496),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
    htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if substr(c1rec.business_days,1,1) = 'T'
    then
     tmp := htf.formcheckbox( 'P15A','T','CHECKED' );
    else
     tmp := htf.formcheckbox( 'P15A','T' );
   end if;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_489),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if substr(c1rec.business_days,2,1) = 'T'
    then
     tmp := htf.formcheckbox( 'P15B','T','CHECKED' );
    else
     tmp := htf.formcheckbox( 'P15B','T' );
   end if;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_490),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if substr(c1rec.business_days,3,1) = 'T'
    then
     tmp := htf.formcheckbox( 'P15C','T','CHECKED' );
    else
     tmp := htf.formcheckbox( 'P15C','T' );
   end if;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_491),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if substr(c1rec.business_days,4,1) = 'T'
    then
     tmp := htf.formcheckbox( 'P15D','T','CHECKED' );
    else
     tmp := htf.formcheckbox( 'P15D','T' );
   end if;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_492),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if substr(c1rec.business_days,5,1) = 'T'
    then
     tmp := htf.formcheckbox( 'P15E','T','CHECKED' );
    else
     tmp := htf.formcheckbox( 'P15E','T' );
   end if;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_493),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if substr(c1rec.business_days,6,1) = 'T'
    then
     tmp := htf.formcheckbox( 'P15F','T','CHECKED' );
    else
     tmp := htf.formcheckbox( 'P15F','T' );
   end if;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_494),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
   if substr(c1rec.business_days,7,1) = 'T'
    then
     tmp := htf.formcheckbox( 'P15G','T','CHECKED' );
    else
     tmp := htf.formcheckbox( 'P15G','T' );
   end if;
   htp.tablerowopen;
    htp.tabledata(htf.bold(LNG.PHG_TXT_495),cattributes=>pfx.qbground || 'valign="MIDDLE" align="RIGHT"');
    htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG.GLB_TXT_060 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PERSONAL',owner_id,errmsg=>sqlerrm);
end phg_personal;

procedure accept_phg_personal(surl in varchar2,p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p5a in varchar2 default 'F', p5b in varchar2, p6 in varchar2,
                              p7 in varchar2, p8 in varchar2, p9 in varchar2, p10 in varchar2, p4a in varchar2, p4b in varchar2, p11 in varchar2, p12 in varchar2,
                              p13 in varchar2, p14 in varchar2, p15a in varchar2 DEFAULT 'F', p15b in varchar2 DEFAULT 'F', p15c in varchar2 DEFAULT 'F', p15d in varchar2 DEFAULT 'F',
                              p15e in varchar2 DEFAULT 'F', p15f in varchar2 DEFAULT 'F', p15g in varchar2 DEFAULT 'F', p16 in varchar2,
                              p17a in varchar2 DEFAULT 'F', p17b in varchar2 DEFAULT 'F', p17c in varchar2 DEFAULT 'F', p17d in varchar2 DEFAULT 'F', p17e in varchar2 DEFAULT 'F', p18 in varchar2,
                              p19a in varchar2, p19b in varchar2, p19c in varchar2, p11a in varchar2,
                              pmca in varchar2, pmcb in varchar2, pmcc in varchar2, pmcd in varchar2, pmce in varchar2 default 'FALSE', pmcf in varchar2 default 'FALSE')
as
 sts		varchar2(200);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		number;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_PHG_PERSONAL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 begin nmb := round(to_number(p5b),2); exception when others then nmb := NULL; end;

 update photographer
  set
   business_name = p1,
   business_desc = p2,
   home_site = p3,
   work_phone = p4,
   mobile_phone = p5,
   contact_street = p6,
   contact_suburb = p7,
   contact_city = p8,
   contact_pcode = p9,
   dob = p10,
   contact_fax = p4a,
   contact_email = p4b,
   abn_number = p11,
   abn_title = p11a,
   contact_name = p12,
   cc_mastercard = p17a,
   cc_visa = p17b,
   cc_bankcard = p17c,
   cc_amex = p17d,
   cc_diners = p17e,
   business_hours_min = p13,
   business_hours_max = p14,
   business_days = p15a || p15b || p15c || p15d || p15e || p15f || p15g,
   enable_sms = p5a,
   notify_order_min = nmb,
   private_gallery = p16,
   skill_level = (select decode(skill_control,'F',skill_level,'T',p18) from photographer where pid = owner_id),
   default_category = p19a,
   default_bf = p19b,
   default_lf = p19c,
   merchant_used = pmca,
   merchant_id = pmcb,
   merchant_url_site = pmcc,
   merchant_return_url = pmcd,
   merchant_popup_window = pmce
  where pid = owner_id;
 commit;

 if p5a = 'T' and p5 is null
  then
   update photographer
    set
     enable_sms = 'F'
   where pid = owner_id;
   commit;
   phg_personal( surl, LNG2.PFM_TXT_079 );
   return;
 end if;

 if p4b is null
  then
   phg_personal( surl, LNG.CST_TXT_163 );
  else
   phg_personal( surl, LNG.PHG_TXT_245 );
 end if;

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_PHG_PERSONAL',owner_id,errmsg=>sqlerrm);
end accept_phg_personal;

procedure phg_stats_prefs( surl in varchar2,acid in integer, msg in varchar2 default null, type in varchar2 default null )
as

 cursor c1(owner_id integer) is select skill_level from photographer where pid = owner_id;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STATS_PREFS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if type in (LNG.PHG_BUT_312,LNG2.PBK_TXT_128)
  then
   phg_comma_del(surl,acid,type);
   return;
 end if;
 theme_rec := get_theme_types( surl,acid );
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_246,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
 if substr(theme_rec.theme_data,12,1) = 'T' then
  htp.tablerowopen;
   htp.tabledata(htf.anchor('phg.phg_stat_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_acct.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_140 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.anchor('phg.phg_stat_acct?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.GLB_TXT_017 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
  end if;
 if substr(theme_rec.theme_data,13,1) = 'T' then
  htp.tablerowopen;
   htp.tabledata(htf.anchor('phg.phg_stat_all?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_all.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_291 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.anchor('phg.phg_stat_all?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_248 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
  end if;
 if substr(theme_rec.theme_data,14,1) = 'T' then
  htp.tablerowopen;
   htp.tabledata(htf.anchor('phg.phg_stat_cplan?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_charge.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_292)),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata(htf.anchor('phg.phg_stat_cplan?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_249 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
  end if;
  if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
   then
    if not (substr(theme_rec.theme_data,15,1) = 'F') and (substr(theme_rec.theme_data,16,1) = 'F') and (substr(theme_rec.theme_data,5,1) = 'F')
     then
      htp.tablerowopen;
       htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
       htp.tabledata(htf.bold( '<font size="+1">' || LNG.PHG_TXT_250 || '</FONT>' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
      htp.tablerowclose;
    end if;
   if substr(theme_rec.theme_data,15,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.phg_stat_comment?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_email1.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_251 )),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('&nbsp&nbsp&nbsp;' || htf.anchor('phg.phg_stat_comment?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+0">' || LNG.PHG_TXT_251 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
    end if;
   if substr(theme_rec.theme_data,16,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.phg_stat_gcard?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_email2.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_252 )),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('&nbsp&nbsp&nbsp;' || htf.anchor('phg.phg_stat_gcard?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+0">' || LNG.PHG_TXT_252 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
    end if;
   if substr(theme_rec.theme_data,5,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.phg_stat_guestem?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_email3.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_293 )),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata('&nbsp&nbsp&nbsp;' || htf.anchor('phg.phg_stat_guestem?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+0">' || LNG.PHG_TXT_293 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    htp.tablerowclose;
    end if;
   if substr(theme_rec.theme_data,17,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.phg_stat_usage?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_usage.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_295 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.phg_stat_usage?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_253 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,413,1) = 'T' then
    htp.tablerowopen;
     htp.tabledata(htf.anchor('phg.phg_stat_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_search.gif',cattributes=>'border=0',calt=>LNG.GLB_TXT_092 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata(htf.anchor('phg.phg_stat_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.GLB_TXT_092 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   end if;
  end if;
  htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STATS_PREFS',owner_id,acid,errmsg=>sqlerrm,extdet=>msg);
end phg_stats_prefs;

procedure phg_stat_acct( surl in varchar2,acid in integer )
as

 cursor c1(photid integer, acid integer) is
  select * from customer_account where aid=acid and pid=photid;

 cursor c2(acid integer, phgid integer) is
  select count('x')
  from ecard ec, customer_account ca
  where ec.aid = acid and
        ec.aid = ca.aid and
	ca.pid = phgid;

 c1rec 		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 tphot		integer;
 tmast		integer;
 tcard		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 v_quota	ump.quotalist;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STAT_ACCT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_TXT_254 || c1rec.account_name,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 ump.get_quota( surl,'PHOTOGRAPHER', owner_id, null, acid, v_quota);
-- ump.get_quota( 'PHOTOGRAPHER', owner_id, null, acid, v_plan_style,v_tot, v_cnt, v_max_size, v_max_photos, v_max_storage, v_renewal, v_plan_name);
 open c2( acid, owner_id );
 fetch c2 into tcard;
 close c2;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_164),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(c1rec.account_name),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_256),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(nvl(c1rec.date_held,'&nbsp;')),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_257),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(to_char( c1rec.date_created, LNG.MASK)),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.CST_TXT_033),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(nvl(to_char( c1rec.date_expires, LNG.MASK),'&nbsp;')),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_259),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(to_char(v_quota.total_asset)),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_260),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(to_char(v_quota.total_used) || htf.nl || to_char(round(v_quota.total_used/1024,1),glbx.KB_MASK) || ' Kb' || htf.nl || to_char(round((v_quota.total_used/1024)/1024,2),glbx.MB_MASK) || ' Mb'),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_263),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(to_char(tcard)),cattributes=>pfx.qcbground );
    htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.p(ump.acct_details(surl,	owner_id,acid));
  htp.tableclose;
  htp.formopen( 'phg.phg_stats_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( null, LNG.PHG_TXT_264 );
  htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STAT_ACCT',owner_id,acid,errmsg=>sqlerrm);
end phg_stat_acct;

procedure phg_stat_all( surl in varchar2, acid in integer )
as
 cursor c1(photid integer, acid integer) is select * from customer_account where aid=acid and pid=photid;

 c1rec c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 v_quota	ump.quotalist;
 x		number;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STAT_ALL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_TXT_265,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P18',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
  ump.get_quota( surl,'PHOTOGRAPHER', owner_id, null, acid, v_quota);
  htp.nl;
  htp.tableopen(cattributes=>'width="600" cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.CST_TXT_138),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG.PHG_TXT_259),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG.PHG_TXT_260),cattributes=>pfx.qbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold('&nbsp;'),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(to_char(v_quota.total_asset)),cattributes=>pfx.qcbground );
      htp.tabledata( to_char(v_quota.total_used) || htf.nl || to_char(round(v_quota.total_used/1024,1),glbx.KB_MASK) || ' Kb' || htf.nl || to_char(round((v_quota.total_used/1024)/1024,2),glbx.MB_MASK) || ' Mb',cattributes=>pfx.qcbground );
    htp.tablerowclose;
   htp.tableclose;
  htp.nl;
  htp.tableopen(cattributes=>'width="600" cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_373),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(to_char(round((((v_quota.max_storage*1024)-v_quota.total_used)/1024)/1024,2),glbx.MB_MASK) || ' Mb' || ' / ' ||
                              to_char(round((((v_quota.max_storage*1024)/1024)/1024),2),glbx.MB_MASK) || ' Mb') ,cattributes=>pfx.qcbground );
    htp.tablerowclose;
    -- Average Bytes per Image
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_374),cattributes=>pfx.qcbground );
      if nvl(v_quota.total_asset,0) = 0
       then
        htp.tabledata( htf.bold(to_char(nvl(v_quota.total_used,0))) || htf.bold(' Bytes'),cattributes=>pfx.qcbground );
       else
        htp.tabledata( htf.bold(to_char(round(v_quota.total_used/v_quota.total_asset))) || htf.bold( ' Bytes'),cattributes=>pfx.qcbground );
      end if;
    htp.tablerowclose;
    -- Estimated number of images that could be stored.
    if v_quota.total_asset > 0
     then
      htp.tablerowopen;
        htp.tabledata( htf.bold(LNG.PHG_TXT_375),cattributes=>pfx.qcbground );
        if nvl(v_quota.total_asset,0) = 0
         then
           x := (v_quota.max_storage*1024) / (v_quota.total_used);
         else
           x := (v_quota.max_storage*1024) / (v_quota.total_used/v_quota.total_asset);
        end if;
        htp.tabledata( htf.bold(to_char(round(x))),cattributes=>pfx.qcbground );
      htp.tablerowclose;
    end if;
   htp.tableclose;
  htp.nl;
  htp.formopen( 'phg.phg_stats_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( null, LNG.PHG_TXT_264 );
  htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STAT_ALL',owner_id,acid,errmsg=>sqlerrm);
end phg_stat_all;

procedure phg_stat_cplan( surl in varchar2, acid in integer )
as
 cursor c1(photid integer, acid integer) is select * from customer_account where aid=acid and pid=photid;
 cursor c2(phgid integer) is select * from photographer where pid = phgid;
 cursor c4(phgid integer) is select * from charge_plan where id = (select plan_id from photographer where pid=phgid);
 cursor c5(phgid integer) is select count('x') from customer_account where pid = phgid;

 c1rec 		c1%ROWTYPE;
 c2rec 		c2%ROWTYPE;
 c4rec 		c4%ROWTYPE;
 c5rec 		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tot		integer;
 v_quota	ump.quotalist;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STAT_CPLAN', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 open c4(owner_id);
 fetch c4 into c4rec;
 close c4;
 open c2(owner_id);
 fetch c2 into c2rec;
 close c2;
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_TXT_280,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
  ump.get_quota( surl,'PHOTOGRAPHER', owner_id, null, acid, v_quota);
--  ump.get_quota( 'PHOTOGRAPHER', owner_id, null, null, v_plan_style,v_tot, v_cnt, v_max_size, v_max_photos, v_max_storage, v_renewal, v_plan_name);
  htp.tableopen(cattributes=>'width="600" cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_249),cattributes=>pfx.qbground );
      htp.tabledata( htf.italic(v_quota.plan_name),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_445),cattributes=>pfx.qbground );
      htp.tabledata( htf.italic(v_quota.plan_style),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_446),cattributes=>pfx.qbground );
      htp.tabledata( htf.italic(nvl(to_char(c2rec.date_expires,LNG.MASK),LNG.PHG_TXT_001)),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    if c2rec.renewal_sent_on is not null
     then
      htp.tablerowopen;
          htp.tabledata( htf.bold(LNG.PHG_TXT_002),cattributes=>pfx.qbground );
      htp.tabledata( htf.italic(to_char(c2rec.renewal_sent_on,LNG.MASK)),cattributes=>pfx.qcbground );
      htp.tablerowclose;
    end if;
  htp.tableclose;
  htp.nl;
  htp.tableopen(cattributes=>'width="600" cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_281),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(htf.italic(LNG.PHG_TXT_282)),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(LNG.CST_TXT_209),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(htf.italic(LNG.PHG_TXT_284)),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(htf.italic('% ' || LNG.PHG_TXT_285)),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_286),cattributes=>pfx.qbground );
      htp.tabledata( htf.italic(v_quota.max_storage),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(to_char(round((v_quota.total_used)/1024,2))),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(htf.italic(to_char(v_quota.max_storage - round((v_quota.total_used)/1024,2)))),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(htf.italic(to_char( round((v_quota.max_storage - round((v_quota.total_used)/1024,2)) / v_quota.max_storage,2)*100) )),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_287),cattributes=>pfx.qbground );
      htp.tabledata( htf.italic(c4rec.max_accounts),cattributes=>pfx.qcbground );
	  open c5(owner_id);
	  fetch c5 into tot;
	  close c5;
      htp.tabledata( htf.bold(nvl(tot,0)),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(htf.italic(c4rec.max_accounts - nvl(tot,0))),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(htf.italic(round((c4rec.max_accounts - nvl(tot,0)) /c4rec.max_accounts,2)*100 )),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_288),cattributes=>pfx.qbground );
      htp.tabledata( htf.italic(v_quota.max_photos),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(nvl(v_quota.total_asset,0)),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(htf.italic(v_quota.max_photos-nvl(v_quota.total_asset,0))),cattributes=>pfx.qcbground );
      htp.tabledata( htf.bold(htf.italic(round((v_quota.max_photos-nvl(v_quota.total_asset,0)) / v_quota.max_photos,2)*100)),cattributes=>pfx.qcbground );
    htp.tablerowclose;
   htp.tableclose;

 htp.nl;
  htp.formopen( 'phg.phg_stats_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( null, LNG.PHG_TXT_264 );
  htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STAT_CPLAN',owner_id,acid,errmsg=>sqlerrm);
end phg_stat_cplan;

procedure phg_stat_comment( surl in varchar2, acid in integer )
as

 cursor c1(photid integer, acid integer) is select * from customer_account where aid=acid and pid=photid;
 cursor c2(acid integer, phgid integer) is
  select ut.value,ut.position_id,uts.sub_category,uts.umo_type, um.umo_id
  from umo um, customer_account ca, umo_attribute ut, umo_attributes uts
  where ut.attribute_id = uts.attribute_id and
        uts.category = 'COMMENT' and
        uts.umo_type = 'PHOTO' and
        um.umo_id = ut.umo_id and
        um.aid = ca.aid and
        ca.aid = acid and
        ca.pid = phgid
  order by um.umo_id,uts.umo_type,ut.position_id,uts.sub_category;

 c1rec c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 lastposid	varchar2(100);
 email_address	varchar2(1000);
 made_by	varchar2(1000);
 the_comment	varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STAT_COMMENT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_TXT_290,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_376),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG.PHG_TXT_301),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG.PHG_TXT_302),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG.PHG_TXT_303),cattributes=>pfx.qbground );
    htp.tablerowclose;
  lastposid := NULL;
  for c2rec in c2(acid,owner_id) loop
    if (to_char(c2rec.umo_id) || '-' || to_char(c2rec.position_id) <> lastposid)
     then
      if c2rec.sub_category = 'EMAIL ADDRESS' then email_address := c2rec.value;
      elsif c2rec.sub_category = 'THE COMMENT' then the_comment := c2rec.value;
      elsif c2rec.sub_category = 'MADE BY' then made_by := c2rec.value;
      end if;
      if not(email_address is null and
             made_by is null and
             the_comment is null)
        then
        htp.tablerowopen;
          htp.tabledata( nvl(c2rec.umo_type,'&nbsp;'),cattributes=>pfx.qcbground );
          htp.tabledata( nvl(email_address,'&nbsp;'),cattributes=>pfx.qcbground );
          htp.tabledata( nvl(made_by,'&nbsp;'),cattributes=>pfx.qcbground );
          htp.tabledata( nvl(the_comment,'&nbsp;'),cattributes=>pfx.qcbground || ' CLASS="SMALL"' );
        htp.tablerowclose;
      end if;
      lastposid := to_char(c2rec.umo_id) || '-' || to_char(c2rec.position_id);
      email_address := NULL;
      made_by := NULL;
      the_comment := NULL;
     else
      if c2rec.sub_category = 'EMAIL ADDRESS' then email_address := c2rec.value;
      elsif c2rec.sub_category = 'THE COMMENT' then the_comment := c2rec.value;
      elsif c2rec.sub_category = 'MADE BY' then made_by := c2rec.value;
      end if;
      if lastposid is null then lastposid := to_char(c2rec.umo_id) || '-' || to_char(c2rec.position_id); end if;
    end if;
  end loop;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground );
   htp.tabledata( nvl(email_address,'&nbsp;'),cattributes=>pfx.qcbground );
   htp.tabledata( nvl(made_by,'&nbsp;'),cattributes=>pfx.qcbground );
   htp.tabledata( nvl(the_comment,'&nbsp;'),cattributes=>pfx.qcbground || ' CLASS="SMALL"' );
   htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formopen( 'phg.phg_stats_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( 'TYPE', LNG.PHG_TXT_264 );
  htp.formsubmit( 'TYPE', LNG.PHG_BUT_312 );
  htp.formsubmit( 'TYPE', LNG2.PBK_TXT_128 );
  htp.formclose;
 htp.nl;

 if top_frame_business_feature( owner_id, 158 )
  then
   htp.formopen( 'pbk.phg_reverse_email' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'TYP', 'COMMENT' );
    htp.formsubmit( null, LNG2.FNM_TXT_173 );
    htp.formtext( 'EBOOK', 30, 100 );
    htp.nl;
  htp.formclose;
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STAT_COMMENT',owner_id,acid,errmsg=>sqlerrm);
end phg_stat_comment;

procedure phg_stat_gcard( surl in varchar2,acid in integer )
as
 cursor c1(photid integer,acid integer) is select * from customer_account where aid=acid and pid=photid;
 cursor c2(acid integer, phgid integer) is
  select from_email,sendto,decode(nvl(is_accessed,'F'),'F',LNG.PHG_TXT_046,LNG.PHG_TXT_045) is_accessed
  from ecard ec, customer_account ca
  where ec.aid = acid and
        ec.aid = ca.aid and
		ca.pid = phgid
  order by from_email;
 c1rec c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STAT_GCARD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_TXT_304,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P21',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.PHG_TXT_305),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG.PHG_TXT_306),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG.PHG_TXT_307),cattributes=>pfx.qbground );
    htp.tablerowclose;
  for c2rec in c2(acid,owner_id) loop
    htp.tablerowopen;
      htp.tabledata( nvl(c2rec.from_email,'&nbsp;'),cattributes=>pfx.qcbground );
      htp.tabledata( nvl(c2rec.sendto,'&nbsp;'),cattributes=>pfx.qcbground );
      htp.tabledata( c2rec.is_accessed,cattributes=>pfx.qcbground );
    htp.tablerowclose;
  end loop;
  htp.tableclose;
 htp.nl;
  htp.formopen( 'phg.phg_stats_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( 'TYPE', LNG.PHG_TXT_264);
  htp.formsubmit( 'TYPE', LNG.PHG_BUT_312 );
  htp.formsubmit( 'TYPE', LNG2.PBK_TXT_128 );
  htp.formclose;
 htp.nl;

 if top_frame_business_feature( owner_id, 158 )
  then
   htp.formopen( 'pbk.phg_reverse_email' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'TYP', 'GCARD' );
    htp.formsubmit( null, LNG2.FNM_TXT_173 );
    htp.formtext( 'EBOOK', 30, 100 );
    htp.nl;
    htp.formclose;
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STAT_GCARD',owner_id,acid,errmsg=>sqlerrm);
end phg_stat_gcard;

procedure phg_stat_guestem( surl in varchar2,acid in integer )
as

 cursor c1(photid integer,acid integer) is select * from customer_account where aid=acid and pid=photid;
 cursor c2(acid integer, phgid integer) is
  select guest_email, date_created, unsolicited_email
  from login_session
  where aid = acid and
        guest_email is not null
  union
    select email_address,date_created,unsolicited_email
    from grab_email
    where aid = acid
  order by 2 desc, 1;

 c1rec c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STAT_GUESTEM', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_TXT_299,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P21',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.ORD_TXT_188),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG4.AHC_TXT_443),cattributes=>pfx.qbground );
      htp.tabledata( htf.bold(LNG.PHG_TXT_301),cattributes=>pfx.qbground );
    htp.tablerowclose;
  for c2rec in c2(acid,owner_id) loop
    htp.tablerowopen;
      htp.tabledata( to_char(c2rec.date_created,LNG.TSMASK),cattributes=>pfx.qcbground );
      if c2rec.unsolicited_email = 'T'
       then
        htp.tabledata( LNG.PHG_TXT_045,cattributes=>pfx.qcbground );
       else
        htp.tabledata( LNG.PHG_TXT_046,cattributes=>pfx.qcbground );
      end if;
      htp.tabledata( c2rec.guest_email,cattributes=>pfx.qcbground );
    htp.tablerowclose;
  end loop;
  htp.tableclose;
 htp.nl;
  htp.formopen( 'phg.phg_stats_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( 'TYPE', LNG.PHG_TXT_264);
  htp.formsubmit( 'TYPE', LNG.PHG_BUT_312 );
  htp.formsubmit( 'TYPE', LNG2.PBK_TXT_128 );
  htp.formclose;

 if top_frame_business_feature( owner_id, 158 )
  then
   htp.nl;
   htp.formopen( 'pbk.phg_reverse_email' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'TYP', 'GUEST' );
    htp.formsubmit( null, LNG2.FNM_TXT_173 );
    htp.formtext( 'EBOOK', 30, 100 );
    htp.nl;
    htp.formclose;
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STAT_GUESTEM',owner_id,acid,errmsg=>sqlerrm);
end phg_stat_guestem;

function top_frame_business_feature( phgid in integer, bf_numb in integer )
 return boolean
as

 cursor c1( phgid integer ) is select theme_data from photographer p, theme_types tp where p.pid = phgid and p.theme_type = tp.theme_type;
 c1rec	c1%ROWTYPE;

begin
 open c1(phgid);
 fetch c1 into c1rec;
 close c1;
 if substr(c1rec.theme_data,bf_numb,1) = 'T'
  then
   return( TRUE );
  else
   return( FALSE );
 end if;
end top_frame_business_feature;

procedure phg_home(surl in varchar2,acid in integer)
as
begin
 glbx.acct_home(surl,acid);
exception when others then
 glbx.error_details( 'PHG', 'PHG_HOME',errmsg=>sqlerrm);
end phg_home;

procedure phg_stat_search( surl in varchar2, acid in integer, action in varchar2 default LNG5.EXT_TXT_002 )
as

 cursor c1(acid integer, oby integer) is
  select distinct src_name,aid,pid,rows_returned,date_updated,sessid,login_type,oby
  from advanced_search
  where (((aid = acid) and login_type in ('OWNER','CUSTOMER')) or
         ((aid in (select profile_id from customer_profile where aid = acid )) and login_type in ('PROFILE','PROFILEG'))
        ) and
        pid = 0
  order by decode(oby,1,rows_returned,
                           2,9999999999-rows_returned,
                           3,to_number(to_char(date_updated,'YYYYMMDD')),
                           4,999999999-to_number(to_char(date_updated,'YYYYMMDD')),
                           rows_returned);

 cursor c2(phgid integer, acid integer) is select * from customer_account where aid=acid and pid=phgid;

 cusrec		customer_account%ROWTYPE;
 c1rec 		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 order_by	integer;
 rowsret	integer;
 lbox		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STAT_SEARCH', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c2( owner_id, acid );
 fetch c2 into cusrec;
 if c2%NOTFOUND then close c2; return; end if;
 close c2;
 pfx := glbx.get_thm( cusrec.theme_name );
 lbox := glbx.userpref(cusrec.pid,cusrec.aid,'LIGHTBOX');
 glbx.main_title( surl, LNG.GLB_TXT_092 || ' ' || LNG.PHG_ALT_127,glbx.backimg(surl,acid,pfx.text_back,cusrec.background_img,ltype),helpid=>'P62',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 if action = LNG5.EXT_TXT_002 then order_by := 1;
 elsif action = LNG5.EXT_TXT_003 then order_by := 2;
 elsif action = LNG5.EXT_TXT_004 then order_by := 3;
 elsif action = LNG5.EXT_TXT_005 then order_by := 4;
 end if;
 htp.formopen( 'phg.phg_stat_search');
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formsubmit( 'ACTION',LNG5.EXT_TXT_002);
 htp.formsubmit( 'ACTION',LNG5.EXT_TXT_003);
 htp.formsubmit( 'ACTION',LNG5.EXT_TXT_004);
 htp.formsubmit( 'ACTION',LNG5.EXT_TXT_005);
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
    htp.tabledata( htf.bold(LNG5.EXT_TXT_006),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
    htp.tabledata( htf.bold(LNG.PHG_TXT_503),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
    htp.tabledata( htf.bold(LNG3.ADM_TXT_836),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
    htp.tabledata( htf.bold(LNG5.EXT_TXT_007),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
    htp.tabledata( htf.bold(LNG3.ADM_TXT_659),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
 htp.tablerowclose;
 for c1rec in c1(acid,order_by) loop
  htp.tablerowopen;
    htp.tabledata( c1rec.src_name,cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
    htp.p( '<TD ' || pfx.qcbground || ' ALIGN="LEFT">' );
    glbx.display_query(c1rec.aid,c1rec.src_name,c1rec.login_type,c1rec.sessid,c1rec.pid,lbox,rowsret);
    htp.p( '</TD>' );
    htp.tabledata( nvl(to_char(c1rec.rows_returned),'?'),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
    htp.tabledata( nvl(to_char(c1rec.date_updated,LNG.TSMASK),'?'),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
    htp.tabledata( initcap(c1rec.login_type),cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION',LNG5.EXT_TXT_002);
 htp.formsubmit( 'ACTION',LNG5.EXT_TXT_003);
 htp.formsubmit( 'ACTION',LNG5.EXT_TXT_004);
 htp.formsubmit( 'ACTION',LNG5.EXT_TXT_005);
 htp.formclose;
 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STAT_SEARCH',owner_id,acid,errmsg=>sqlerrm);
end phg_stat_search;

procedure phg_stat_usage( surl in varchar2,acid in integer )
as

 cursor c1(photid integer, acid integer) is select * from customer_account where aid=acid and pid=photid;

 cursor c2(acid integer) is
  select /*+ ALL_ROWS */  count(call_ctr) cc,
         sum(call_ctr) sc,
         round(avg(call_ctr),2) ac,
         sum(decode(screen_type,'1',1,0)) s1,
         sum(decode(screen_type,'2',1,0)) s2,
         sum(decode(screen_type,'3',1,0)) s3,
         sum(decode(screen_type,'4',1,0)) s4,
         sum(decode(screen_type,'5',1,0)) s5,
         sum(decode(screen_type,'6',1,0)) s6,
	 sum(decode(login_type,'OWNER',1,'PROFILE',1,0)) lo,
	 sum(decode(login_type,'CUSTOMER',1,'PROFILEG',1,'VIRTUAL',1,0)) lc,
	 round(avg(date_updated-date_created)*60*24,2) avrg
  from login_session
  where (
         (login_type in ('OWNER','CUSTOMER') and aid = acid) or
         (login_type in ('PROFILE','PROFIELG') and exists (select 'x' from customer_profile where profile_id = aid and aid = acid))
        )
         and
        browser_version is not null and
        os is not null and
        browser_type is not null;

 /*
 cursor c2a(acid integer) is
  select count('x') cc
  from login_session ls, audit_all_activity aa
  where (
         (ls.login_type in ('OWNER','CUSTOMER') and aid = acid) or
         (ls.login_type in ('PROFILE','PROFIELG') and exists (select 'x' from customer_profile where profile_id = aid and aid = acid))
        )
         and
        browser_version is not null and
        os is not null and
        browser_type is not null and
        ls.sessid = aa.sessid and
        display_what is null;
 */

 cursor c2a(acid integer) is
  select /*+ ALL_ROWS */ sum(cc) cc from
  (
   select /*+ ALL_ROWS */  count('x') cc
   from login_session ls, audit_all_activity aa
   where ls.login_type in ('OWNER','CUSTOMER') and aid = acid and
         browser_version is not null and
         os is not null and
         browser_type is not null and
         ls.sessid = aa.sessid and
         display_what is null
  union all
   select /*+ ALL_ROWS */  count('x') cc
   from login_session ls, audit_all_activity aa, customer_profile cp
   where ls.login_type in ('PROFILE','PROFIELG') and
         cp.profile_id = ls.aid and
         ls.aid = acid and
         browser_version is not null and
         os is not null and
         browser_type is not null and
         ls.sessid = aa.sessid and
         display_what is null
  );

 cursor c3(acid integer) is
  select trunc(date_created) date_created,count('x') tot, round(avg(date_updated-date_created)*60*24,2) avrg
  from login_session
  where aid = acid and
        browser_version is not null and
        os is not null and
        browser_type is not null
  group by trunc(date_created)
  order by 1 desc;

 cursor c4(acid integer) is
  select to_char(date_created,'HH24') hr, count('x') ctr, round(avg(date_updated-date_created)*60*24,2) avrg
  from login_session
  where aid = acid and
        browser_version is not null and
        os is not null and
        browser_type is not null and
        login_type in ('OWNER','CUSTOMER','PROFILE','PROFILEG','VIRTUAL')
  group by to_char(date_created,'HH24');

 cursor c5(acid integer) is
  select nvl(os,' ') os,browser_type,browser_version,count('x') tot, round(avg(date_updated-date_created)*60*24,2) avrg
  from login_session
  where aid = acid and
        browser_version is not null and
        os is not null and
        browser_type is not null
  group by nvl(os,' '),browser_type,browser_version;


 cursor c6(acid integer) is
  select count('x') tot
  from login_session
  where aid = acid and
        browser_version is null and
        os is null and
        browser_type is null;

 c1rec 		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c2arec		c2a%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 sdate		date;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STAT_USAGE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1( owner_id, acid );
 fetch c1 into c1rec;
 if c1%NOTFOUND then close c1; return; end if;
 close c1;
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG.PHG_TXT_313 || c1rec.account_name,glbx.backimg(surl,acid,pfx.text_back,c1rec.background_img,ltype),helpid=>'P22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 open c2( acid );
 fetch c2 into c2rec;
 close c2;
 open c2a( acid );
 fetch c2a into c2arec;
 close c2a;
 open c6( acid );
 fetch c6 into c6rec;
 close c6;

  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_BUT_340) );
     htp.tabledata( '&nbsp;' );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_314),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(c2rec.cc),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_315),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(c2arec.cc || '(' || c2rec.sc || ')'),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_316),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      if nvl(c2rec.cc,0) = 0
       then
        htp.tabledata( htf.bold(to_char(round(c2arec.cc)) || '(' || c2rec.ac || ')'),cattributes=>pfx.qcbground );
       else
        htp.tabledata( htf.bold(to_char(round(c2arec.cc/c2rec.cc)) || '(' || c2rec.ac || ')'),cattributes=>pfx.qcbground );
      end if;
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_321),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c2rec.lo),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG5.EXT_TXT_221),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c6rec.tot),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG5.EXT_TXT_641),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c2rec.avrg),cattributes=>pfx.qcbground );
    htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_279) );
     htp.tabledata( htf.bold(LNG.PHG_TXT_314) );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 800 x 600'),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(c2rec.s1),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 1024 x 768'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c2rec.s2),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 1280 x 1024'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c2rec.s3),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 1400 x 1050'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c2rec.s4),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 1600 x 1200'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c2rec.s5),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': > 1600 x 1200'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c2rec.s6),cattributes=>pfx.qcbground );
    htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_276) );
     htp.tabledata( htf.bold(LNG.PHG_TXT_314) );
     htp.tabledata( htf.bold(LNG5.EXT_TXT_641) );
    htp.tablerowclose;
    for c5rec in c5( acid ) loop
    htp.tablerowopen;
      htp.tabledata( htf.italic(c5rec.os || '-' || c5rec.browser_type || '(' || c5rec.browser_version || ')'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c5rec.tot),cattributes=>pfx.qcbground );
      htp.tabledata( to_char(c5rec.avrg),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    end loop;
  htp.tableclose;
  htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_ALT_359) );
   htp.tabledata( htf.bold(LNG.PHG_TXT_314) );
   htp.tabledata( htf.bold(LNG5.EXT_TXT_641) );
  htp.tablerowclose;
  for c3rec in c3(acid) loop
    htp.tablerowopen;
      htp.tabledata( htf.italic(to_char(c3rec.date_created,LNG.MASK)),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(c3rec.tot),cattributes=>pfx.qcbground );
      htp.tabledata( to_char(c3rec.avrg),cattributes=>pfx.qcbground );
    htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.bold( LNG.PHG_TXT_318 );
  htp.nl;
  htp.nl;
  --sdate := to_date('01-' || to_char(sysdate,'MON-YYYY'),'DD-MON-YYYY');
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_319) );
   htp.tabledata( htf.bold(LNG.PHG_TXT_322) );
   htp.tabledata( htf.bold(LNG5.EXT_TXT_641) );
  htp.tablerowclose;
  for c4rec in c4(acid) loop
    htp.tablerowopen;
      htp.tabledata( htf.bold( c4rec.hr),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
      htp.tabledata( htf.bold( c4rec.ctr),cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
      htp.tabledata( to_char(c4rec.avrg),cattributes=>pfx.qcbground );
    htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.formopen( 'phg.phg_stats_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( null, LNG.PHG_TXT_264 );
  htp.formclose;
 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STAT_USAGE',owner_id,acid,errmsg=>sqlerrm);
end phg_stat_usage;

procedure phg_comma_del( surl in varchar2, acid in integer, typ in varchar2 )
as

 cursor c1(photid integer, acid integer) is select * from customer_account where aid=acid and pid=photid;

 cursor c2(acid integer, phgid integer) is
  select ut.value,ut.position_id,uts.sub_category,uts.umo_type
  from umo um,customer_account ca, umo_attribute ut, umo_attributes uts
  where ut.attribute_id = uts.attribute_id and
        uts.category = 'COMMENT' and
        uts.sub_category <> 'THE COMMENT' and
        um.umo_id = ut.umo_id and
        um.aid = ca.aid and
        ca.aid = acid and
        ca.pid = phgid
  order by uts.umo_type,ut.position_id,uts.sub_category;

 cursor c2a(acid integer, phgid integer) is
  select from_email,sendto,decode(nvl(is_accessed,'F'),'F',LNG.PHG_TXT_046,LNG.PHG_TXT_045) is_accessed,nfrom_email,nsendto
  from ecard ec, customer_account ca
  where ec.aid = acid and
        ec.aid = ca.aid and
	ca.pid = phgid
  order by from_email;

 cursor c3(acid integer, phgid integer) is
  select guest_email, date_created, unsolicited_email
  from login_session
  where aid = acid and
        guest_email is not null
  order by date_created desc, guest_email;

 cursor c4(acid integer, phgid integer) is
  select distinct email_address, date_created, unsolicited_email
  from grab_email
  where aid = acid
  order by email_address;

 c1rec 		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 lastposid	integer;
 email_address	varchar2(1000);
 made_by	varchar2(1000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_COMMA_DEL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1( owner_id, acid );
 fetch c1 into c1rec;
 close c1;

 -- Download
 if typ = LNG2.PBK_TXT_128
  then
     htp.prn('Content-type: ' || 'bad/type' || chr(10));
     htp.prn('Content-Disposition: attachment; filename=' || 'email_addresses_' || to_char(sysdate,'dd_mon_yyyy') || '.csv' || chr(10));
     htp.prn('Content-Transfer-Encoding: binary' || chr(10));
     htp.prn(chr(10));
     htp.p( '"Type of Email Address","Receive Unsolicited Email U-Unknown, T-Yes, F-No","Email Address","Made By"' );
 end if;

  lastposid := 0;
  for c2rec in c2(acid,owner_id) loop
    if (c2rec.position_id <> lastposid) and (lastposid <> 0)
     then
       if typ = LNG2.PBK_TXT_128
        then
         htp.p( '"COMMENT",' ||
                '"U",' ||
                '"' || replace(email_address,'"','''') || '",' ||
                '"' || replace(made_by,'"','''') || '"' );
        else
         htp.p( email_address || ',"' || made_by || '",' ); htp.nl;
       end if;
      lastposid := c2rec.position_id;
      email_address := NULL;
      made_by := NULL;
     else
      if c2rec.sub_category = 'EMAIL ADDRESS' then email_address := c2rec.value;
      elsif c2rec.sub_category = 'MADE BY' then made_by := c2rec.value;
      end if;
    end if;
  end loop;

  for c2arec in c2a(acid,owner_id) loop
    if typ = LNG2.PBK_TXT_128
     then
      htp.p( '"GREETING CARD FROM",' ||
             '"U",' ||
             '"' || replace(c2arec.from_email,'"','''') || '",' ||
             '"' || replace(c2arec.nfrom_email,'"','''') || '"' );
      htp.p( '"GREETING CARD TO",' ||
             '"U",' ||
             '"' || replace(c2arec.sendto,'"','''') || '",' ||
             '"' || replace(c2arec.nsendto,'"','''') || '"' );
     else
      htp.p( c2arec.from_email || ',' ); htp.nl;
      htp.p( c2arec.sendto || ',' ); htp.nl;
    end if;
  end loop;

  for c3rec in c3(acid,owner_id) loop
    if typ = LNG2.PBK_TXT_128
     then
      htp.p( '"LOGIN",' ||
             '"' || c3rec.unsolicited_email || '",' ||
             '"' || replace(c3rec.guest_email,'"','''') || '",' ||
             '""' );
     else
      htp.p( c3rec.guest_email || ',' ); htp.nl;
    end if;
  end loop;

  for c4rec in c4(acid,owner_id) loop
    if typ = LNG2.PBK_TXT_128
     then
      htp.p( '"ACCOUNT NOT OPENED",' ||
             '"' || c4rec.unsolicited_email || '",' ||
             '"' || replace(c4rec.email_address,'"','''') || '",' ||
             '""' );
     else
      htp.p( c4rec.email_address || ',' ); htp.nl;
    end if;
  end loop;

 if typ = LNG.PHG_BUT_312
  then
   htp.nl;
   htp.formopen( 'phg.phg_stats_prefs' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formsubmit( null, LNG.PHG_TXT_264  );
    htp.formclose;
   htp.htmlclose;
 end if;

exception when others then
 glbx.error_details( 'PHG', 'PHG_COMMA_DEL',owner_id,acid,errmsg=>sqlerrm);
end phg_comma_del;

procedure phg_prefs_thb( surl in varchar2,acid in integer, msg in varchar2 default null )
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 thmb_qual	varchar2(100);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PREFS_THB', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_016,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P23',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
  htp.nl;
  htp.formopen( 'phg.accept_prefs_thb' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=0 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.PHG_TXT_371 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext( 'P3', 10,20,'%'),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.PHG_TXT_325 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext( 'P1', 10,20,nvl(glbx.photo_pref(owner_id,acid,'THUMBNAIL_WIDTH'),'100')),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
      thmb_qual := nvl(glbx.photo_pref(owner_id,acid,'SUPER_THB'),'1');
      htp.tabledata(htf.bold( LNG.PHG_TXT_324 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(glbx.quality_loop( 'P2', thmb_qual ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata(htf.bold( 'Recreate any Adobe PDF Documents Thumbnails' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formcheckbox( 'P4', 'T' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG.PHG_TXT_016 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PREFS_THB',owner_id,vaid=>acid,errmsg=>sqlerrm);
end phg_prefs_thb;

procedure accept_prefs_thb( surl in varchar2,acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in char default 'F' )
as
 cursor c1(acid integer, phgr integer, wildcard varchar2) is
  select um.umo_id,um.extras.film_name film_name, um.umo_type, um.doc_mimetype
  from umo um, customer_account ca
  where um.aid = ca.aid and
        ca.aid = acid and
        um.umo_type in ('PHOTO','DOCUMENT') and
        (nvl(um.photo_master.contentlength,0) > 0 or
         nvl(um.doc_length,0) > 0) and
        ca.pid = phgr and
        um.extras.film_name like wildcard;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 ctr		integer;
 pfx		THEME%ROWTYPE;
 parm1		ump.parameters;
 parm2		ump.parameters;
 retval		varchar2(4000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_PREFS_THB', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 ctr := 0;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG5.EXT_TXT_372,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P23',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

 begin nmb := to_number(p1); exception when others then phg_prefs_thb(surl,acid,LNG.PHG_TXT_328 || p1 ); return; end;
 for c1rec in c1(acid,owner_id,p3) loop
  if p4 = 'T' and c1rec.umo_type = 'DOCUMENT' and lower(trim(c1rec.doc_mimetype)) = 'application/pdf'
   then
    retval := ump.create_document_tnail( surl, c1rec.umo_id );
    if retval is null
     then
      parm1(1) := 'UMO_ID';
      parm2(1) := c1rec.umo_id;
      parm1(2) := 'AID';
      parm2(2) := to_char(acid);
      parm1(3) := 'OBJECT_TYPE';
      parm2(3) := 'PHOTO';
      parm1(4) := 'KEEP_STATUS';
      parm2(4) := 'KEEP';
      parm1(5) := 'CREATE_THUMBNAIL';
      parm2(5) := 'TRUE';
      parm1(6) := 'THUMBNAIL_WIDTH';
      parm2(6) := to_char(nmb);
      parm1(7) := 'THUMBNAIL_QUALITY';
      parm2(7) := p2;
      ump.modify_uma(surl,parm1,parm2,retval);
    end if;
  elsif c1rec.umo_type = 'PHOTO'
   then
    retval := NULL;
    parm1(1) := 'UMO_ID';
    parm2(1) := c1rec.umo_id;
    parm1(2) := 'AID';
    parm2(2) := to_char(acid);
    parm1(3) := 'OBJECT_TYPE';
    parm2(3) := 'PHOTO';
    parm1(4) := 'KEEP_STATUS';
    parm2(4) := 'KEEP';
    parm1(5) := 'CREATE_THUMBNAIL';
    parm2(5) := 'TRUE';
    parm1(6) := 'THUMBNAIL_WIDTH';
    parm2(6) := to_char(nmb);
    parm1(7) := 'THUMBNAIL_QUALITY';
    parm2(7) := p2;
    ump.modify_uma(surl,parm1,parm2,retval);
  end if;
  if retval is null
   then
    htp.p( LNG.PHG_TXT_519 || ': ' || c1rec.film_name);
   else
    htp.p( LNG.PHG_TXT_520 || ': ' || retval );
  end if;
  htp.nl;
  ctr := ctr + 1;
  commit;
 end loop;
 if ctr = 0
  then
   phg_utlts_prefs(surl, acid, LNG5.EXT_TXT_371 || '-' || ctr );
 end if;
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_PREFS_THB',owner_id,vaid=>acid,errmsg=>sqlerrm,extdet=>'P1:' || p1 || ' P2:' || p2);
end accept_prefs_thb;

function  get_theme_types( surl in varchar2, acid in integer, ltype in varchar2 default null)
 return theme_types%ROWTYPE
as
 cursor c1(acid integer) is select * from theme_types tt where theme_type in (select theme_type from customer_account where aid=acid);
 cursor c2(phgid integer) is select * from theme_types tt where theme_type in (select theme_type from photographer where pid=phgid);
 c1rec  c1%ROWTYPE;
begin
 if ltype is null
  then
   open c1(acid);
   fetch c1 into c1rec;
   close c1;
   return( c1rec );
  else
   open c2(acid);
   fetch c2 into c1rec;
   close c2;
   return( c1rec );
 end if;
exception when others then
 glbx.error_details( 'PHG', 'GET_THEME_TYPES',errmsg=>sqlerrm,extdet=>'ACID:' || acid);
end get_theme_types;

function image_exists_in_nested( uscid integer, phgr integer )
 return boolean
as

 cursor c1(uscid integer, phgr integer) is
  select umo_scene_id catid
  from  umo_scene
  where parent_scene = uscid and
       ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgr ));

 cursor c4(scid integer) is select 'x' from dual where exists (select 'x' from umo um where um.umo_scene_id = scid );

 c4rec		c4%ROWTYPE;

begin
 for c1rec in c1(uscid, phgr) loop
  if image_exists_in_nested( c1rec.catid, phgr) then return( TRUE ); end if;
 end loop;
 open c4(uscid);
 fetch c4 into c4rec;
 if c4%FOUND then close c4; return( TRUE ); end if;
 close c4;
 return( FALSE );
end image_exists_in_nested;

procedure private_scenes( surl in varchar2, acid in integer, msg in varchar2 default null)
as

 cursor c1(acid integer,owner_id integer) is select scene_name,theme_name from customer_account where aid=acid and pid=owner_id;

 cursor c2(v_category varchar2, v_owner_id integer) is
  select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;

 cursor c5(scid integer) is select title from umo_scene where umo_scene_id = scid;
 cursor c6(acid integer, spbb integer, uscid integer) is select 'x' from price_book_map where aid = acid and spb = spbb and umo_scene_id = uscid;
 cursor c7(phgid integer) is select ppb.name,ppb.spb from phg_price_book ppb where pid = phgid order by ppb.name;

 c1rec		c1%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 tmp		char(1);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 dummy		varchar2(10000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PRIVATE_SCENES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(acid,owner_id);
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, LNG.PHG_TXT_333 || ':' || c1rec.scene_name,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P24',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.tableopen;
 htp.tablerowopen;
 htp.tabledata( LNG.PHG_TXT_343,cattributes=>pfx.qbground );
 htp.tablerowclose;
 htp.tablerowopen;
 htp.tabledata( LNG.PHG_TXT_350,cattributes=>pfx.qbground );
 htp.tablerowclose;
 htp.tablerowopen;
 htp.tabledata( LNG.PHG_TXT_351,cattributes=>pfx.qbground );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formopen( 'phg.accept_private_scenes' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );

 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
  if substr(theme_rec.theme_data,92,1) = 'T'
   then
    htp.tabledata( htf.bold(LNG3.ADM_TXT_578),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  end if;
  htp.tabledata( htf.bold(LNG.SLD_TXT_004),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  htp.tabledata( htf.bold(LNG.PHG_TXT_348),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  htp.tabledata( htf.bold(LNG.PHG_TXT_344),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  htp.tabledata( htf.bold(LNG.PHG_TXT_345),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  if substr(theme_rec.theme_data,92,1) = 'T'
   then
    htp.tabledata( htf.bold(LNG3.ADM_TXT_582),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  end if;
  if substr(theme_rec.theme_data,110,1) = 'T'
   then
    htp.tabledata( htf.bold(LNG2.PBK_TXT_059),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
  end if;
 htp.tablerowclose;

 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );
 htp.formhidden( 'P3', null );
 htp.formhidden( 'P4', null );

 for c2rec in c2( c1rec.scene_name, owner_id ) loop

  htp.tablerowopen;

    if substr(theme_rec.theme_data,92,1) = 'T'
     then
      htp.tabledata(htf.anchor( 'phg.scene_utility?surl=' || glbx.rndsurl(surl) || '&typ=NEST&scnm=' || translate(c1rec.scene_name,' ','+') || '&scid=' || c2rec.umo_scene_id || '&acid=' || acid,'[Ins 1]' ) || htf.nl ||
                    htf.anchor( 'phg.scene_utility?surl=' || glbx.rndsurl(surl) || '&typ=NEST5&scnm=' || translate(c1rec.scene_name,' ','+') || '&scid=' || c2rec.umo_scene_id || '&acid=' || acid,'[Ins 5]' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
      if c2rec.owned_by = 'PHOTOGRAPHER'
       then
        if image_exists_in_nested( c2rec.umo_scene_id, owner_id )
         then
          htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
         else
          htp.tabledata(htf.anchor( 'phg.scene_utility?surl=' || glbx.rndsurl(surl) || '&typ=DELETE&scnm=' || translate(c1rec.scene_name,' ','+') || '&scid=' || c2rec.umo_scene_id || '&acid=' || acid, LNG.SLD_TXT_004),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
        end if;
       else
          htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
      end if;
     else
      if c2rec.owned_by = 'PHOTOGRAPHER'
       then
        if image_exists_in_nested( c2rec.umo_scene_id, owner_id )
         then
          htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
         else
          htp.tabledata(htf.anchor( 'phg.scene_utility?surl=' || glbx.rndsurl(surl) || '&typ=DELETE&scnm=' || translate(c1rec.scene_name,' ','+') || '&scid=' || c2rec.umo_scene_id || '&acid=' || acid, LNG.SLD_TXT_004),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
        end if;
       else
          htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
      end if;
    end if;
    htp.tabledata( initcap(c2rec.owned_by),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');

    if c2rec.owned_by = 'PHOTOGRAPHER'
     then
      htp.tabledata( htf.formhidden( 'P3', c2rec.umo_scene_id ) || htf.formtext( 'P1', 10, 20, c2rec.order_by ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
      htp.tabledata( htf.formhidden( 'P3', c2rec.umo_scene_id ) || htf.formhidden( 'P1', c2rec.order_by ) || c2rec.order_by,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;

    if substr(theme_rec.theme_data,92,1) = 'T'
     then
      if c2rec.parent_scene is not null
       then
        open c5(c2rec.parent_scene);
        fetch c5 into c5rec;
        close c5;
        htp.tabledata( htf.italic(c5rec.title),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
       else
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
      end if;
    end if;

    if c2rec.owned_by = 'PHOTOGRAPHER'
     then
      htp.tabledata( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || htf.formtext( 'P2', 20, 100, nvl(c2rec.title,LNG.GLB_TXT_136) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
      htp.tabledata( lpad(nvl(pfx.nested_scene_delim,'&nbsp;'), indnt(c2rec.parent_scene),nvl(pfx.nested_scene_delim,'&nbsp;')) || htf.formhidden( 'P2', c2rec.title ) || htf.bold(nvl(c2rec.title,LNG.GLB_TXT_136) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;

    if substr(theme_rec.theme_data,110,1) = 'T'
     then
      dummy := htf.formselectopen( 'P4' ) || htf.formselectoption( NULL );
      for c7rec in c7(owner_id) loop
       open c6(acid,c7rec.spb,c2rec.umo_scene_id);
       fetch c6 into tmp;
       if c6%FOUND
        then
         dummy := dummy || htf.formselectoption( c7rec.name, 'SELECTED', cattributes=>'VALUE="' || c7rec.spb || '"' );
        else
         dummy := dummy || htf.formselectoption( c7rec.name, cattributes=>'VALUE="' || c7rec.spb || '"' );
       end if;
       close c6;
      end loop;
      dummy := dummy || htf.formselectclose;
      htp.tabledata( dummy, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
--    else
--     -- htp.formhidden( NULL );
    end if;

    htp.tablerowclose;

 end loop;

 for j in 1..5 loop
  htp.tablerowopen;
     if substr(theme_rec.theme_data,92,1) = 'T'
      then
       htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
     htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
     htp.tabledata( p_title( owner_id ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.formhidden( 'P3', '0' );
     htp.tabledata( htf.formtext( 'P1', 10, 20, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     if substr(theme_rec.theme_data,92,1) = 'T'
      then
       htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
     end if;
     htp.tabledata( htf.formtext( 'P2', 20, 100, null ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     if substr(theme_rec.theme_data,110,1) = 'T'
      then
       htp.tabledata( htf.formhidden( 'P4', null ) || '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
      else
       htp.formhidden( 'P4', null );
     end if;
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.PHG_BUT_347 );
 htp.formsubmit( 'ACTION', LNG.PHG_TXT_052 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PRIVATE_SCENES',owner_id,vaid=>acid,errmsg=>sqlerrm);
end private_scenes;

procedure accept_private_scenes( surl in varchar2,acid in integer, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY)
as

 cursor c1( acid integer, owner_id integer) is select scene_name from customer_account where aid=acid and pid=owner_id;
 cursor c2( uscid integer ) is select * from umo_scene where umo_scene_id = uscid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 new_nmb	integer;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_PRIVATE_SCENES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if action = LNG.PHG_TXT_052
  then
   phg_utlts_prefs( surl,acid );
   return;
 end if;
 theme_rec := get_theme_types( surl,acid );

 open c1(acid,owner_id);
 fetch c1 into c1rec;
 close c1;

 for j in p1.first..p1.last loop
  if p3(j) is not null
   then
    open c2(p3(j));
    fetch c2 into c2rec;
    close c2;

    if ((nvl(c2rec.owned_by,'PUBLIC') = 'PUBLIC') or (c2rec.owned_by = 'PHOTOGRAPHER' and nvl(c2rec.owner_id,0) <> owner_id)) and (p3(j) <> '0')
     then
      null;

     else
      begin nmb := to_number(p1(j)); exception when others then nmb := 99901; end;
      nmb := nvl(nmb,99901);

      if p1(j) is null and p2(j) is null
       then
        null; -- Now need to explicitly delete it, using the DELETE button

       elsif (p2(j) is not null) and (p3(j) = '0')
        then
         select s_umo_scene.nextval into new_nmb from dual;
         insert into umo_scene(umo_scene_id,category,owned_by,owner_id,order_by,title) values
                              (new_nmb,c1rec.scene_name,'PHOTOGRAPHER',owner_id,nmb,p2(j));
       elsif p3(j) <> '0'
        then
         update umo_scene
          set
            order_by = nmb,
            title = nvl(p2(j),LNG.PHG_TXT_521)
          where category = c1rec.scene_name and
                owner_id = owner_id and
                owned_by = 'PHOTOGRAPHER' and
                umo_scene_id = p3(j);
        update umo um
        set
          um.extras.orderby_scene = nmb,
          um.extras.title = nvl(p2(j),LNG.PHG_TXT_521)
        where um.umo_scene_id = p3(j);

       end if;
    end if;

    if substr(theme_rec.theme_data,110,1) = 'T'
     then
      delete from price_book_map where aid = acid and umo_scene_id = p3(j);
      if p4(j) is not null
       then
        insert into price_book_map(aid,spb,umo_scene_id) values (acid,to_number(p4(j)),to_number(p3(j)) );
      end if;
    end if;

  end if;
 end loop;

 commit;
 private_scenes(surl,acid, LNG.PHG_ALT_413 );
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_PRIVATE_SCENES',owner_id,vaid=>acid,errmsg=>sqlerrm);
end accept_private_scenes;

procedure scene_utility( surl in varchar2,scnm in varchar2, typ in varchar2, scid in integer, acid in integer )
as
 cursor c1(scid integer) is select order_by+1 from umo_scene where umo_scene_id = scid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb	integer;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.SCENE_UTILITY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if typ = 'DELETE'
  then
   delete from umo_scene
    where category = scnm and
          umo_scene_id = scid and
          not exists( select 'x' from umo um where um.umo_scene_id = scid);
   delete from price_book_map where umo_scene_id = scid and aid = acid and aid in (select aid from customer_account where pid = owner_id);
  elsif typ in ('NEST','NEST5')
   then
     open c1(scid);
     fetch c1 into nmb;
     close c1;
     insert into umo_scene(umo_scene_id,category,owned_by,order_by,title,parent_scene,owner_id) values
        (s_umo_scene.nextval,scnm,'PHOTOGRAPHER',nvl(nmb,100),LNG3.ADM_TXT_577,scid,owner_id);
     if typ = 'NEST5'
      then
       for j in 1..4 loop
        insert into umo_scene(umo_scene_id,category,owned_by,order_by,title,parent_scene,owner_id) values
          (s_umo_scene.nextval,scnm,'PHOTOGRAPHER',nvl(nmb,100),LNG3.ADM_TXT_577 || to_char(j+1),scid,owner_id);
       end loop;
     end if;
  end if;
 commit;
 private_scenes(surl,acid, LNG3.ADM_TXT_184 );
exception when others then
 glbx.error_details( 'PHG', 'SCENE_UTILITY', errmsg=>sqlerrm, extdet=>null);
end scene_utility;

procedure phg_rename(surl in varchar2,acid in integer, scene in varchar2 default null, msg in varchar2 default null)
as

  cursor c1(acid integer,phgid integer) is select scene_name from customer_account where aid = acid and pid = phgid;
  cursor c2 is select scene_name from scene order by scene_name;
  cursor c2a(uscid integer) is select parent_scene from umo_scene where umo_scene_id = uscid;
  cursor c3(acid integer) is select distinct um.umo_scene_id,um.extras.title title from umo um where aid = acid;
  cursor c4(v_category varchar2, v_owner_id integer) is
  select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;
  cursor c5(v_category varchar2, v_owner_id integer) is
  select count('x') tot
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select count('x') tot
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER';
  cursor c9(phid integer) is select scene_name from limit_scenes where pid = phid order by scene_name;
  cursor c11(phid integer) is select limit_scene from photographer where pid = phid;

 c1rec		c1%ROWTYPE;
 c2arec		c2a%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c11rec		c11%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 cnt		integer;
 sts		varchar2(100);
 tmp		varchar2(32767);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_RENAME', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 if scene is not null
  then
   begin
         cnt := 0;
         open c5(scene,owner_id);
         fetch c5 into c5rec;
         cnt := cnt + nvl(c5rec.tot,0);
         fetch c5 into c5rec;
         cnt := cnt + nvl(c5rec.tot,0);
         close c5;
         if cnt = 0
          then
           phg_rename(surl,acid,null,'No Titles exist in this Category. Please Choose another one.' );
           return;
         end if;
    exception
     when others then begin close c5; exception when others then null; end;
          phg_rename(surl,acid,null,'No Titles exist in this Category. Please Choose another one.' );
          return;
    end;
 end if;
 glbx.main_title( surl, LNG.PHG_TXT_530,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P37',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 open c1(acid,owner_id);
 fetch c1 into c1rec;
 close c1;
 if scene is null
  then
       glbx.instruction( LNG.PHG_TXT_518, pfx );
       glbx.instruction( LNG5.EXT_TXT_036, pfx );
       htp.formopen( 'phg.phg_rename' );
       htp.formhidden( 'SURL', glbx.rndsurl(surl));
       htp.formhidden( 'ACID', acid );
       open c11(owner_id);
       fetch c11 into c11rec;
       close c11;
       tmp := htf.formselectopen( 'SCENE' );
       if c11rec.limit_scene = 'T'
        then
         for c2rec in c2 loop
          if c1rec.scene_name = c2rec.scene_name
           then
            tmp := tmp || htf.formselectoption( c2rec.scene_name, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c2rec.scene_name );
          end if;
         end loop;
         tmp := tmp || htf.formselectclose;
        else
         for c9rec in c9(owner_id) loop
          if c1rec.scene_name = c9rec.scene_name
           then
            tmp := tmp || htf.formselectoption( c9rec.scene_name, 'SELECTED' );
           else
            tmp := tmp || htf.formselectoption( c9rec.scene_name );
          end if;
         end loop;
         tmp := tmp || htf.formselectclose;
       end if;
       htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_517), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tabledata( tmp, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tablerowclose;
       htp.tableclose;
       htp.nl;
       htp.formsubmit(null,LNG.PHG_TXT_514);
       htp.formclose;

   else

       htp.formopen( 'phg.accept_rename', ctarget=>'PHG_BOTTOM' );
       htp.formhidden( 'SURL', glbx.rndsurl(surl));
       htp.formhidden( 'ACID', acid );
       htp.formhidden( 'SCENE', scene );
       htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_515), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tabledata( htf.bold(LNG.PHG_TXT_516), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tablerowclose;
        foundrec := FALSE;
        for c3rec in c3(acid) loop
         htp.tablerowopen;
          foundrec := TRUE;
          if c3rec.umo_scene_id is not null
           then
            open c2a(c3rec.umo_scene_id);
            fetch c2a into c2arec;
            close c2a;
            htp.tabledata( htf.bold(lpad(pfx.nested_scene_delim, indnt(c2arec.parent_scene),pfx.nested_scene_delim) || c3rec.title), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.formhidden( 'P1', c3rec.umo_scene_id );
            htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">');
              htp.formselectopen( 'P2' );
              for c4rec in c4(scene,owner_id) loop
                htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c4rec.parent_scene),pfx.nested_scene_delim) || c4rec.title, cattributes=>'VALUE="' || c4rec.umo_scene_id || '"'  );
              end loop;
              htp.formselectclose;
            htp.p( '</TD>' );
          end if;
        htp.tablerowclose;
        end loop;
       htp.tableclose;
       htp.nl;
       if foundrec
        then
         htp.formsubmit(null,LNG.PHG_TXT_514);
         htp.formclose;
        else
         update customer_account set scene_name = scene where aid = acid and pid = owner_id;
         commit;
         htp.nl;
         htp.nl;
         htp.anchor2( 'phg.phg_acct_master?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, LNG2.PBK_TXT_062, ctarget=>'PHG_BOTTOM');
         htp.nl;
       end if;
 end if;
 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_RENAME',owner_id,vaid=>acid,errmsg=>sqlerrm,extdet=>'SCENE:' || scene);
end phg_rename;

procedure accept_rename( surl in varchar2, acid in integer, scene in varchar2, p1 in MYARRAY, p2 in MYARRAY )
as

 cursor c1(umscid integer) is select order_by from umo_scene where umo_scene_id = umscid;
 cursor c2(umscid integer, acid integer) is select rowid, umo_id from umo where aid = acid and umo_scene_id = umscid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;

 sts		varchar2(100);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_RENAME', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 for j in p1.first..p1.last loop
  open c1(to_number(p2(j)));
  fetch c1 into c1rec;
  close c1;
   for c2rec in c2(to_number(p1(j)),acid) loop
    update umo um
     set
      um.extras.title = (select title from umo_scene usc where umo_scene_id = to_number(p2(j))),
      um.extras.orderby_scene = c1rec.order_by,
      um.umo_scene_id = to_number(p2(j))
     where rowid = c2rec.rowid;
    audit_utility( c2rec.umo_id,'UMO_SCENE_ID', p1(j),p2(j), 'ACCEPT_RENAME' );
   end loop;
 end loop;
 update customer_account set scene_name = scene where aid = acid and pid = owner_id;
 commit;
 phg_acct_master(surl,acid);
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_RENAME',owner_id,vaid=>acid,errmsg=>sqlerrm,extdet=>'SCENE:' || scene);
end accept_rename;

procedure audit_utility( v_umo in integer, colval in varchar2, oldval in varchar2, newval in varchar2, extdet in varchar2 default null )
as
begin
 insert into log_umo_utility_modification(umo_id,column_name,date_changed,old_value,new_value,extra_information) values
  (v_umo,colval,sysdate,oldval,newval,extdet);
end audit_utility;

procedure mnt_resize(surl in varchar2, acid in integer, action in varchar2 default 'MENU', msg in varchar2 default null)
as

 cursor c1(acid integer,owner_id integer) is select scene_name from customer_account where aid=acid and pid=owner_id;
 cursor c2(acid integer) is
  select /*+ ALL_ROWS */ distinct ut.attribute_id, category, sub_category, order_by
  from umo um, umo_attribute uta, umo_attributes ut
  where ut.attribute_id = uta.attribute_id and
        um.aid = acid and
        um.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT') and
        ((ut.umo_type = um.umo_type and ut.editeable = 'T') or (ut.umo_type = 'ALL')) and
        uta.umo_id = um.umo_id
  order by order_by,sub_category;

 cursor c3( snm varchar2, acid integer, phgid integer ) is
   select umo_scene_id,title,parent_scene
   from umo_scene
   where category = snm and
         ((owned_by = 'PUBLIC') or (owned_by in ('OWNER','CUSTOMER') and owner_id = acid) or (owned_by='PHOTOGRAPHER' and owner_id = phgid))
   order by order_by;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 ctr		integer;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.MNT_RESIZE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, nvl(msg,LNG.PHG_TXT_367),glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P25',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 ctr := 0;

 if action = 'MENU'
  then
  ctr := ctr + 1;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=REDUCE_IMG&msg=' || replace(LNG5.EXT_TXT_165,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_165 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;

   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=REDUCEW&msg=' || replace('Change Width of Web Quality Images',' ','+'), to_char(ctr) || '. ' || 'Change Width of Web Quality Images' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=REDUCEH&msg=' || replace('Change Height of Web Quality Images',' ','+'), to_char(ctr) || '. ' || 'Change Height of Web Quality Images' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;

   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=RENAME&msg=' || replace(LNG5.EXT_TXT_168,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_168 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   if substr(theme_rec.theme_data,89,1) = 'T'
    then
     ctr := ctr + 1;
     htp.tablerowopen;
      htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=META&msg=' || replace(LNG5.EXT_TXT_169,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_169 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,136,1) = 'T'
    then
     ctr := ctr + 1;
     htp.tablerowopen;
      htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=SORT&msg=' || replace(LNG5.EXT_TXT_170,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_170 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   if substr(theme_rec.theme_data,189,1) = 'T'
    then
     ctr := ctr + 1;
     htp.tablerowopen;
      htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=PHOTO_NO&msg=' || replace(LNG5.EXT_TXT_222,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_222 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   end if;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=CATEGORIES&msg=' || replace(LNG5.EXT_TXT_172,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_172 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=ROLL&msg=' || replace(LNG5.EXT_TXT_173,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_173 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=FILM&msg=' || replace(LNG5.EXT_TXT_174,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_174 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=PRODUCT&msg=' || replace(LNG5.EXT_TXT_175,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_175 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=FTP&msg=' || replace(LNG5.EXT_TXT_176,' ','+'), to_char(ctr) || '. ' || LNG5.EXT_TXT_176 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     -- xxx language file
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=FTP_RANDOMISE&msg=' || replace('Randomise FTP Locations',' ','+'), to_char(ctr) || '. ' || 'Randomise FTP Locations' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=CTG&msg=' || replace('Convert Category Names',' ','+'), to_char(ctr) || '. ' || 'Convert Category Names' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.mnt_resize?surl=' || surl || '&acid=' || acid || '&action=DIR&msg=' || replace('Create Directory Thumbnail Listing in Each Category',' ','+'), to_char(ctr) || '. ' || 'Create Directory Thumbnail Listing in Each Category' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   ctr := ctr + 1;
   htp.tablerowopen;
     htp.tabledata(htf.anchor( 'phg.phg_utlts_prefs?surl=' || surl || '&acid=' || acid, LNG.PHG_TXT_052 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
  return;
 end if;

 if action in ('CATEGORIES','ROLL','FILM','PRODUCT','FTP','FTP_RANDOMISE','PHOTO_NO','CTG','DIR')
  then
   phg_mass_ch(surl, acid, action, msg, startover=>'F' );
   return;
 end if;

 htp.nl;
 htp.formopen( 'phg.accept_resize' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );

 if action = 'REDUCE_IMG'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
    htp.formhidden( 'P1', NULL );
    htp.formhidden( 'ACTION','SIZE' );
    htp.nl;
    htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.PHG_TXT_368 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',20,100,'%' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.PHG_TXT_369 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P3',30,100,'80' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata(htf.bold( LNG.PHG_TXT_370 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P4',30,100,'80' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.tableopen;
   htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, LNG.PHG_ALT_414 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
  return;
 end if;

 if action = 'REDUCEW'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
    htp.formhidden( 'P1', NULL );
   htp.formhidden( 'ACTION','PIXELS' );
   htp.nl;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_368 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',20,100,'%' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_453 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P3',30,100,'800' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_454 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P4',30,100,'800' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen;
  htp.tablerowopen;
  htp.tabledata( htf.formsubmit( null, LNG.PHG_ALT_414 ) || htf.formclose );
  htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
  return;
 end if;

 if action = 'REDUCEH'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
    htp.formhidden( 'P1', NULL );
   htp.formhidden( 'ACTION','PIXELSH' );
   htp.nl;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_368 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',20,100,'%' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_455 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P3',30,100,'900' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_456 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P4',30,100,'900' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen;
  htp.tablerowopen;
  htp.tabledata( htf.formsubmit( null, LNG.PHG_ALT_414 ) || htf.formclose );
  htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
  return;
 end if;

 if action = 'RENAME'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
    htp.formhidden( 'P1', NULL );
   htp.formhidden( 'ACTION','RENAME' );
   htp.nl;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_182 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',20,100,'%' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_181 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formselectopen('P3') || htf.formselectoption( LNG.PHG_TXT_045 ) || htf.formselectoption( LNG.PHG_TXT_046,'SELECTED' ) || htf.formselectclose,cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_180 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formselectopen('P4') || htf.formselectoption( LNG.PHG_TXT_045,'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_046 ) || htf.formselectclose,cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen;
  htp.tablerowopen;
  htp.tabledata( htf.formsubmit( null, LNG.PHG_TXT_169 ) || htf.formclose );
  htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.italic( LNG.PHG_TXT_194 );
  htp.p( '</CENTER>' );
  htp.htmlclose;
  return;
 end if;

 if action = 'SORT'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
    htp.formhidden( 'P1', NULL );
    htp.formhidden( 'P4', NULL );
    htp.formhidden( 'ACTION','SORT' );
    htp.nl;
     htp.tablerowopen;
      htp.tabledata(htf.bold( LNG4.AHC_TXT_365 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(' &nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata(htf.formradio( 'P2', '1', 'CHECKED' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG4.AHC_TXT_375 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext('P3',5,10,'1'),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata(htf.formradio( 'P2', '2' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG4.AHC_TXT_376 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata(htf.formradio( 'P2', '3' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG4.AHC_TXT_377 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata(htf.formradio( 'P2', '4' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.bold( LNG5.EXT_TXT_048 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.tableopen;
   htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_387 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                  htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.italic( LNG.PHG_TXT_194 );
   htp.p( '</CENTER>' );
   htp.htmlclose;
  return;
 end if;

 if action = 'META'
  then
   open c1(acid,owner_id);
   fetch c1 into c1rec;
   close c1;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
    htp.formhidden( 'ACTION','META' );
    htp.nl;
     htp.tablerowopen;
      htp.tabledata(htf.bold( LNG4.AHC_TXT_413 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">');
      htp.formselectopen( 'P1' );
      for c2rec in c2(acid) loop
       htp.formselectoption( c2rec.sub_category || '(' || c2rec.category || ')', cattributes=>'VALUE="' || c2rec.attribute_id || '"' );
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG5.EXT_TXT_177),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext( 'P2', 40, 1000 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG5.EXT_TXT_178),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">');
      htp.formselectopen( 'P3' );
      htp.formselectoption( NULL );
      for c3rec in c3(c1rec.scene_name,acid,owner_id) loop
       htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c3rec.parent_scene),'.') || c3rec.title, cattributes=>'VALUE="' || c3rec.umo_scene_id || '"' );
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata(htf.bold(LNG5.EXT_TXT_179),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata(htf.formtext('P4',40, 1000),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata(htf.formcheckbox( 'P5', 'T' ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="RIGHT"');
      htp.tabledata( LNG5.EXT_TXT_171,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tablerowclose;
     htp.tablerowopen;
     -- xxx language file
      htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="RIGHT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
      htp.formselectopen( 'P6' );
       htp.formselectoption( 'Replace Existing Value', 'SELECTED', cattributes=>'VALUE="R"' );
       htp.formselectoption( 'Append Value (After)', cattributes=>'VALUE="A"' );
       htp.formselectoption( 'Append Value (Before)', cattributes=>'VALUE="B"' );
       htp.formselectoption( 'Replace Occurance A, with Occurance B (e.g. Large,Larger)', cattributes=>'VALUE="S"' );
       htp.formselectoption( 'Convert to Upper Case', cattributes=>'VALUE="U"' );
       htp.formselectoption( 'Convert to Lower Case', cattributes=>'VALUE="L"' );
       htp.formselectoption( 'Convert to Initialised Case', cattributes=>'VALUE="I"' );
       htp.formselectoption( 'Shrink to Length of Characters (eg. 5 - is 5 characters long)', cattributes=>'VALUE="T"' );
       htp.formselectoption( 'Apply the Censor to the Value', cattributes=>'VALUE="C"' );
       htp.formselectoption( 'Empty Field', cattributes=>'VALUE="E"' );
       htp.formselectoption( 'Remove Symbols Identified (eg. ()~+)', cattributes=>'VALUE="X"' );
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.tableopen;
   htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, LNG3.ADM_TXT_938 ) || htf.formclose );
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                  htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
  return;
 end if;

exception when others then
 glbx.error_details( 'PHG', 'MNT_RESIZE',owner_id,vaid=>acid,errmsg=>sqlerrm);
end mnt_resize;

procedure accept_resize(surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in char default 'F', p6 in char default 'F', action in varchar2)
as

 cursor c1(phgid integer, acid integer, minsize integer, wcard varchar2) is
  select um.umo_id,um.photo_master.contentlength ct, um.photo_master.width width, um.photo_master.height height
  from umo um
  where aid = acid and
        aid = (select aid from customer_account where pid=phgid and aid=acid) and
        um.extras.film_name like nvl(wcard,'%') and
        um.photo_master.contentlength > minsize
  order by um.umo_id;

 cursor c2(phgid integer, acid integer, minsize integer, wcard varchar2) is
  select um.umo_id,um.photo_master.contentlength ct, um.photo_master.width width, um.photo_master.height height
  from umo um
  where aid = acid and
        aid = (select aid from customer_account where pid=phgid and aid=acid) and
        um.extras.film_name like nvl(wcard,'%') and
        um.photo_master.width > minsize
  order by um.umo_id;

 cursor c3(phgid integer, acid integer, minsize integer, wcard varchar2) is
  select um.umo_id,um.photo_master.contentlength ct, um.photo_master.width width, um.photo_master.height height
  from umo um
  where aid = acid and
        aid = (select aid from customer_account where pid=phgid and aid=acid) and
        um.extras.film_name like nvl(wcard,'%') and
        um.photo_master.height > minsize
  order by um.umo_id;

 cursor c4(phgid integer, acid integer, wcard varchar2) is
  select um.umo_id,um.photo_original_loc
  from umo um
  where aid = acid and
        aid = (select aid from customer_account where pid=phgid and aid=acid) and
        um.extras.film_name like nvl(wcard,'%')
  order by um.umo_id;

 cursor c5(phgid integer, acid integer) is
  select count('x') tot from umo where aid = acid and aid = (select aid from customer_account where aid = acid and pid = phgid);

 cursor c6(phgid integer, acid integer) is
  select count('x') tot
  from login_session ls, shopping_basket sb, purchase_order po
  where po.sessid = ls.sessid and
        ls.aid = acid and
        po.poid = sb.poid and
        ls.login_type in ('OWNER','PROFILE','VIRTUAL','PROFILEG','CUSTOMER') and
        po.status not in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,'PreOrder - Confirmed without Payment');

 cursor c7(acid integer) is select min(umo_id) mn from umo where aid = acid;

 cursor c8(acid integer, uscid integer, imgname varchar2, atribid integer ) is
  select um.umo_id, um.extras.film_name fname, um.extras.title title, uta.value, um.umo_type
  from umo um, umo_attribute uta
  where aid = acid and
        uta.umo_id = um.umo_id and
        uta.attribute_id = atribid and
        ((uscid is null) or (uscid is not null and um.umo_scene_id = uscid)) and
        ((imgname is null) or (imgname is not null and upper(um.extras.film_name) like upper(replace(imgname,'*','%')) || '%'))
  order by um.extras.title,um.extras.film_name,um.umo_id;

 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 nmb2		integer;
 nmbw		integer;
 retval		varchar2(4000);
 np2		varchar2(1000);
 min_nmb	integer;
 pfound		boolean;
 parm1		ump.parameters;
 parm2		ump.parameters;
 theme_rec	theme_types%ROWTYPE;
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_RESIZE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, LNG2.FNM_TXT_098,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P72',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 pfound := FALSE;
 if action = 'SIZE'
  then
   begin nmb2 := to_number(p3)*1024; exception when others then nmb := 65*1024; end;
   begin nmb := to_number(p4)*1024; exception when others then nmb := 80*1024; end;
   for c1rec in c1(owner_id,acid,nmb,replace(p2,'*','%')) loop
    retval := NULL;
    pfound := TRUE;
    parm1(1) := 'UMO_ID';
    parm2(1) := c1rec.umo_id;
    parm1(2) := 'AID';
    parm2(2) := to_char(acid);
    parm1(3) := 'OBJECT_TYPE';
    parm2(3) := 'PHOTO';
    parm1(4) := 'KEEP_STATUS';
    parm2(4) := 'KEEP';
    parm1(5) := 'RESIZE_WIDTH';
    parm2(5) := to_char( nmb2 );
    parm1(6) := 'RESIZE_THRESHOLD';
    parm2(6) := to_char( nmb );
    if substr(theme_rec.theme_data,64,1) = 'T'
     then
      parm1(7) := 'BACKUP_PHOTO';
      parm2(7) := 'TRUE';
    end if;
    ump.modify_uma(surl,parm1,parm2,retval);
    if retval is null
     then
      htp.p( LNG.PHG_TXT_173 || ' #' || c1rec.umo_id || ' ' || LNG.PHG_TXT_195 );
      audit_utility( c1rec.umo_id,'RESIZE_WIDTH', null,parm2(5), 'ACCEPT_RESIZE-SIZE' );
     else
      htp.p( LNG.PHG_TXT_209 || ': ' || retval );
    end if;
    htp.nl;
  end loop;

 elsif action = 'PIXELS'
  then
   begin nmb := to_number(p4); exception when others then nmb := null; end;
   begin nmb2 := to_number(p3); exception when others then nmb2 := null; end;
   if nmb is not null and nmb2 is not null
    then
     for c2rec in c2(owner_id,acid,nmb,replace(p2,'*','%')) loop
      retval := NULL;
      pfound := TRUE;
      parm1(1) := 'UMO_ID';
      parm2(1) := c2rec.umo_id;
      parm1(2) := 'AID';
      parm2(2) := to_char(acid);
      parm1(3) := 'OBJECT_TYPE';
      parm2(3) := 'PHOTO';
      parm1(4) := 'KEEP_STATUS';
      parm2(4) := 'KEEP';
      parm1(5) := 'RESIZE_WIDTH';
      parm2(5) := to_char(nmb2);
      if substr(theme_rec.theme_data,64,1) = 'T'
       then
        parm1(6) := 'BACKUP_PHOTO';
        parm2(6) := 'TRUE';
      end if;
      ump.modify_uma(surl,parm1,parm2,retval);
      if retval is null
       then
        htp.p( LNG.PHG_TXT_173 || ' #' || c2rec.umo_id || ' ' || LNG.PHG_TXT_195 || ' ' || to_char(nmb2) );
        htp.nl;
        audit_utility( c2rec.umo_id,'RESIZE_WIDTH', null,parm2(5), 'ACCEPT_RESIZE-PIXELS' );
       else
        htp.p( LNG.PHG_TXT_209 || ': ' || retval );
        htp.nl;
      end if;
     end loop;
    else
     htp.p( LNG.PHG_TXT_210 || ':' || p3 || '-' || p4);
    end if;
    htp.nl;

 elsif action = 'RENAME'
  then
    for c4rec in c4(owner_id,acid,replace(p2,'*','%')) loop
      pfound := TRUE;
      parm1(1) := 'UMO_ID';
      parm2(1) := c4rec.umo_id;
      parm1(2) := 'AID';
      parm2(2) := to_char(acid);
      parm1(3) := 'OBJECT_TYPE';
      parm2(3) := 'PHOTO';
      parm1(4) := 'KEEP_STATUS';
      parm2(4) := 'KEEP';
      parm1(5) := 'FILM_NAME';
      if p4 = LNG.PHG_TXT_045
       then
        parm2(5) := glbx.extract_fname(c4rec.photo_original_loc,'KEEP_EXTENSION',100);
       else
        parm2(5) := glbx.extract_fname(c4rec.photo_original_loc,'NO_EXTENSION',100);
      end if;
      if p3 = LNG.PHG_TXT_045
       then
        parm1(6) := 'NAME';
        parm2(6) := parm2(5);
      end if;
     ump.modify_uma(surl,parm1,parm2,retval);
     if retval is null
      then
       htp.p( LNG.PHG_TXT_205 || ' #' || c4rec.umo_id || ' ' || LNG.PHG_TXT_206 || ' ' || parm2(5) );
       htp.nl;
       audit_utility( c4rec.umo_id,'FILM_NAME', null,parm2(5), 'ACCEPT_RESIZE-RENAME' );
      else
       htp.p( LNG.PHG_TXT_209 || ': ' || retval );
       htp.nl;
     end if;
    end loop;

 elsif action = 'SORT'
  then
   if p2 = '1'
    then
     begin nmb := to_number(p3); exception when others then nmb := null; end;
     if nmb < 1 then nmb := 1; end if;
     if nmb > 100 then nmb := 100; end if;
     if nmb is not null
      then
       update umo
        set
         sort_priority = nmb
       where
        aid = acid and aid = (select aid from customer_account where aid = acid and pid = owner_id);
       nmb2 := SQL%ROWCOUNT;
       htp.p( LNG2.PFM_TXT_075 || '-' || nmb2 ); htp.nl;
       commit;
     end if;
   elsif p2 = '2'
    then
     -- Images Viewed
       -- Stage 1. For any image not viewed set its sort to be 100
       update umo
        set
         sort_priority = 100
       where
        aid = acid and aid = (select aid from customer_account where aid = acid and pid = owner_id);
       -- Extract total number of images in the account
       open c5(owner_id,acid);
       fetch c5 into c5rec;
       close c5;
       update umo um
        set
         sort_priority = (
          select trunc(100 - ((count('x') / c5rec.tot)/100))
          from audit_all_activity aaa, login_session ls
          where aaa.sessid = ls.sessid and
                ls.aid = acid and
                ls.login_type in ('OWNER','PROFILE','VIRTUAL','PROFILEG','CUSTOMER') and
                display_what = 'MASTER' and
                aaa.umo_id = um.umo_id)
       where
        aid = acid and aid = (select aid from customer_account where aid = acid and pid = owner_id);
       nmb2 := SQL%ROWCOUNT;
       htp.p( LNG2.PFM_TXT_075 || '-' || nmb2 ); htp.nl;
       commit;
   elsif p2 = '3'
    then
     -- Images Purchased
       -- Stage 1. For any image not viewed set its sort to be 100
       update umo
        set
         sort_priority = 100
       where
        aid = acid and aid = (select aid from customer_account where aid = acid and pid = owner_id);
       -- Extract total number of images in the account
       open c6(owner_id,acid);
       fetch c6 into c6rec;
       close c6;
       update umo um
        set
         sort_priority = (
          select trunc(100 - ((count('x') / c6rec.tot)/100))
          from login_session ls, shopping_basket sb, purchase_order po
          where po.sessid = ls.sessid and
                ls.aid = acid and
                po.poid = sb.poid and
                ls.login_type in ('OWNER','PROFILE','VIRTUAL','PROFILEG','CUSTOMER') and
                po.status not in (LNG.ORD_TXT_120,LNG4.AHC_TXT_672,'PreOrder - Confirmed without Payment') and
                sb.phid = um.umo_id)
       where
        aid = acid and aid = (select aid from customer_account where aid = acid and pid = owner_id);
       nmb2 := SQL%ROWCOUNT;
       htp.p( LNG2.PFM_TXT_075 || '-' || nmb2 ); htp.nl;
       commit;
   elsif p2 = '4'
    then
       open c7(acid);
       fetch c7 into min_nmb;
       close c7;
       update umo um
        set
         um.extras.orderby_nmb = (umo_id - min_nmb) + 1
       where
        aid = acid and aid = (select aid from customer_account where aid = acid and pid = owner_id);
   end if;

 elsif action = 'META'
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_048 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.bold( LNG.CST_TXT_042 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.bold( LNG.CST_TXT_132 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
    htp.tabledata( htf.bold( LNG4.AHC_TXT_987 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
    if p5 = 'F'
     then
      htp.tabledata( htf.bold( LNG4.AHC_TXT_104 ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
    end if;
   htp.tablerowclose;
   for c8rec in c8(acid, p3, p4, p1 ) loop
    pfound := TRUE;
    htp.tablerowopen;
     htp.tabledata( c8rec.umo_id, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( c8rec.title, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( nvl(c8rec.fname,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( nvl(c8rec.value,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     if p5 = 'F'
      then
       parm1(1) := 'UMO_ID';
       parm2(1) := c8rec.umo_id;
       parm1(2) := 'AID';
       parm2(2) := to_char(acid);
       parm1(3) := 'OBJECT_TYPE';
       parm2(3) := c8rec.umo_type;
       parm1(4) := 'KEEP_STATUS';
       parm2(4) := 'KEEP';
       parm1(5) := 'ATTRIBUTE_ID';
       if p6 = 'F' then np2 := c8rec.value;  -- Do Nothing
       elsif p6 = 'R' then np2 :=  p2;  -- Replace
       elsif p6 = 'A' then np2 :=  c8rec.value || p2;  -- Append After
       elsif p6 = 'B' then np2 :=  p2 || c8rec.value;  -- Append Before
       elsif p6 = 'S' then np2 :=  replace(c8rec.value,substr(p2,instr(p2,',')-1),substr(p2,instr(p2,',')+1));  -- Substitute
       elsif p6 = 'U' then np2 :=  upper(initcap(c8rec.value));  -- Upper
       elsif p6 = 'L' then np2 :=  lower(c8rec.value);  -- Lower
       elsif p6 = 'I' then np2 :=  initcap(c8rec.value);  -- Initialise
       elsif p6 = 'T' then np2 :=  substr(c8rec.value,glbx.conv_nmb(p2),1000);  -- Shrink
       elsif p6 = 'C' then np2 :=  glbx.censor(c8rec.value);  -- Censor
       elsif p6 = 'E' then np2 :=  null;  -- Empty
       elsif p6 = 'X' then np2 :=  replace(translate(c8rec.value,p2,lpad(chr(20),length(p2),chr(20))),chr(20),'');  -- Remove Symbols
       end if;
       parm2(5) := '[' || p1 || ']' || np2;
       ump.modify_uma(surl,parm1,parm2,retval);
       if retval is null
        then
         htp.tabledata( nvl(np2,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
        else
         htp.tabledata( nvl(np2,'&nbsp;') || htf.nl || LNG.PHG_TXT_209 || ': ' || retval, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
       end if;
     end if;
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   commit;
   htp.nl;

 else

   begin nmb := to_number(p4); exception when others then nmb := null; end;
   begin nmb2 := to_number(p3); exception when others then nmb2 := null; end;
   if nmb is not null and nmb2 is not null
    then
     for c2rec in c2(owner_id,acid,nmb,replace(p2,'*','%')) loop
      retval := NULL;
      pfound := TRUE;
      parm1(1) := 'UMO_ID';
      parm2(1) := c2rec.umo_id;
      parm1(2) := 'AID';
      parm2(2) := to_char(acid);
      parm1(3) := 'OBJECT_TYPE';
      parm2(3) := 'PHOTO';
      parm1(4) := 'KEEP_STATUS';
      parm2(4) := 'KEEP';
      parm1(5) := 'RESIZE_HEIGHT';
      parm2(5) := to_char(nmb2);
      if substr(theme_rec.theme_data,64,1) = 'T'
       then
        parm1(6) := 'BACKUP_PHOTO';
        parm2(6) := 'TRUE';
      end if;
      ump.modify_uma(surl,parm1,parm2,retval);
      if retval is null
       then
        htp.p( LNG.PHG_TXT_173 || ' #' || c2rec.umo_id || ' ' || LNG.PHG_TXT_203 || ' ' || to_char(nmb2) );
        htp.nl;
        audit_utility( c2rec.umo_id,'RESIZE_HEIGHT', null,parm2(5), 'ACCEPT_RESIZE-RESIZE HEIGHT' );
       else
        htp.p( LNG.PHG_TXT_209 || ': ' || retval );
        htp.nl;
      end if;
     end loop;
    else
     htp.p( LNG.PHG_TXT_210 || ':' || p3 || '-' || p4);
    end if;
    htp.nl;
  end if;
  if not pfound then htp.bold(LNG.GLB_TXT_103); htp.nl; htp.nl; end if;
  htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                  htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_RESIZE',owner_id,vaid=>acid,errmsg=>sqlerrm);
end accept_resize;

procedure manage_gallery(surl in varchar2,acid in integer,msg in varchar2)
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'PHG.MANAGE_GALLERY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
  htp.htmlopen;
  htp.framesetopen(glbx.sctrl(glbx.fndtheme( owner_id, acid ),'GALLERY_FRAME_SIZE',stype),'100%',cattributes=>'frameborder="1" framespacing="0" border="1"');
   htp.frame( 'phg.gallery_top?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=' || translate(msg,' ','+'),'GALLERY_TOP');
   htp.frame( 'phg.gallery_bottom?surl=' || glbx.rndsurl(surl) || '&acid=' ||acid,'GALLERY_BOTTOM');
  htp.framesetclose;
  htp.p( '<BODY>' );
  htp.noframesopen;
   glbx.noframe(surl,'PHG.MANAGE_GALLERY');
  htp.noframesclose;
  htp.p( '</BODY>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'MANAGE_GALLERY',errmsg=>sqlerrm);
end manage_gallery;

procedure gallery_top(surl in varchar2,acid in integer, msg in varchar2 default null)
as

 cursor c1(phgr_id integer) is
  select um.umo_id, um.version, um.extras
  from umo um
  where umo_owner = 'PHOTOGRAPHER' and
        umo_type = 'GALLERY' and
        aid = phgr_id
  order by um.extras.orderby_nmb;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 isfound	boolean := FALSE;
 ftype		varchar2(20);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.GALLERY_TOP', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if acid is null
  then
   pfx := glbx.photo_lf(owner_id);
  else
   pfx := glbx.get_thm( acid );
 end if;
 glbx.main_title( surl, nvl(msg,LNG.CST_TXT_225),glbx.backimg(surl,acid,pfx.gallery_back),helpid=>'P26',stype=>stype,sstyle=>pfx.gallery_text_font,sclr=>pfx.gallery_text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.italic( LNG.PHG_ALT_416);
 htp.nl;
 htp.italic( LNG.PHG_ALT_417 );
 htp.nl;
 htp.tableopen;
 ftype := 'PHG_RIGHT';
 if acid is null then ftype := 'PHG_BOTTOM'; end if;
 for c1rec in c1(owner_id) loop
  isfound := TRUE;
  if mod( c1%ROWCOUNT,glbx.sctrl(pfx.theme_name,'GALLERY_HORIZONTAL',stype)) = 0
   then
    htp.tablerowclose;
    htp.tablerowopen;
  end if;
  htp.tabledata( htf.anchor2(
                'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&msg=&footer_api=GALLERY&left_api_parm=&current_page_number=&display_detail=&phgid=' || c1rec.umo_id,
                '<IMG STYLE="display:block;" BORDER=0 SRC="' ||
                'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
                '&parm1=LOGIN_TYPE&parm2=GALLERY&parm1=AID&parm2=' || to_char(acid) || '" ' ||
	        'ALT="' || c1rec.extras.photo_name || '">',ctarget=>ftype) || htf.nl ||
	        htf.bold(c1rec.extras.photo_name), cattributes=>' valign="MIDDLE" ALIGN="CENTER" CLASS="SMALL"' );
 end loop;
 htp.tablerowclose;
 htp.tableclose;
 if not isfound
  then
   htp.bold( LNG.PHG_ALT_418 ); htp.nl;
 end if;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'GALLERY_TOP',errmsg=>sqlerrm);
end gallery_top;

procedure gallery_bottom(surl in varchar2,acid in integer)
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(1000);
 ftype		varchar2(20);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.GALLERY_BOTTOM', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if acid is null
  then
   pfx := glbx.photo_lf(owner_id);
  else
   pfx := glbx.get_thm( acid );
 end if;
 theme_rec := get_theme_types( surl,acid );
 ftype := 'PHG_RIGHT';
 if acid is null then ftype := 'PHG_BOTTOM'; end if;
 glbx.main_title( surl, null,glbx.backimg(surl,acid,pfx.gallery_back),stype=>stype,sstyle=>pfx.gallery_text_font,sclr=>pfx.gallery_text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.gallery_load', cattributes=>'enctype="multipart/form-data"', ctarget=>ftype );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 tmp := htf.formselectopen( 'P2' ) || htf.formselectoption( LNG.PHG_ALT_427 );
 tmp := tmp || htf.formselectoption( LNG.PHG_TXT_308,'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_309 ) || htf.formselectoption( LNG.PHG_TXT_310 );
 tmp := tmp || htf.formselectclose;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0');
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_ALT_419 ) );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;');
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_ALT_422) );
   htp.tabledata( htf.formtext( 'P1', 15, 100 ) );
   htp.tabledata( '&nbsp;');
   htp.tabledata( '&nbsp;');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_217 ) );
   htp.tabledata( tmp || htf.formselectclose);
   htp.tabledata( htf.bold(LNG.PHG_TXT_325) );
   htp.tabledata( htf.formtext( 'P3', 5, 100, nvl(glbx.photo_pref(owner_id,acid,'THUMBNAIL_WIDTH'),'150') ) );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_ALT_421) );
   htp.tabledata( GLBX.UPLOAD_NAME);
   htp.tabledata( htf.bold(LNG3.ADM_TXT_332) );
   htp.p( '<TD>' );
   /*
   htp.formselectopen( 'P4' );
   for j in 1..8 loop
    htp.formselectoption( to_char(j) );
   end loop;
   htp.formselectclose;
   */
    htp.p( glbx.quality_loop( 'P4', null ) );
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;');
   htp.tabledata( htf.formsubmit(null,LNG.PHG_ALT_423) );
   htp.tabledata( '&nbsp;');
   htp.tabledata( '&nbsp;');
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'GALLERY_BOTTOM',errmsg=>sqlerrm);
end gallery_bottom;

procedure gallery_load(surl in varchar2, acid in integer, file in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F')
as

 ltype		varchar2(100);
 stype		integer;
 pid		integer;
 new_id		integer;
 sts		varchar2(100);
 parm1		ump.parameters;
 parm2		ump.parameters;
 newid_arr	ump.myarray_int;
 retval		varchar2(100);
 theme_rec	theme_types%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, pid, sts, progcalled=>'PHG.GALLERY_LOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 theme_rec := get_theme_types( surl,acid );
 if file is not null
   then
       parm1(1)  := 'AID';
       parm2(1)  := to_char(pid);
       parm1(2)  := 'OBJECT_TYPE';
       parm2(2)  := 'GALLERY';
       parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
       parm2(3)  := 'UPLOAD';
       parm1(4)  := 'FILE_NAME';
       parm2(4)  := file;
       parm1(5)  := 'STORE_ORIGINAL';
       parm2(5)  := 'FALSE';
       parm1(6)  := 'CREATE_THUMBNAIL';
       parm2(6)  := 'TRUE';
       parm1(7) := 'KEEP_STATUS';
       parm2(7) := 'KEEP';
       parm1(8) := 'ORIGINAL_LOCATION';
       parm2(8) := file;
       parm1(9) := 'PARENT_UMO_ID';
       parm2(9) := NULL;
       parm1(10) := 'SCENE_ID';
       parm2(10) := null;
       parm1(11) := 'UMO_OWNER';
       parm2(11) := 'PHOTOGRAPHER';
       parm1(12) := 'BYPASS_QUOTA_CHECK';
       parm2(12) := 'FALSE';
       parm1(13) := 'PHGR_ID';
       parm2(13) := to_char(pid);
       parm1(14) := 'OWS_NAME';
       parm2(14) := file;
       parm1(15) := 'FILM_NAME';
       parm2(15) := nvl(p1,glbx.extract_fname(file));
       parm1(16) := 'THUMBNAIL_WIDTH';
       parm2(16) := nvl(p3,nvl(glbx.photo_pref(pid,acid,'THUMBNAIL_WIDTH'),'100'));
       parm1(17) := 'PHOTOGRAPHER';
       parm2(17) := 'TRUE';
       parm1(18) := 'NAME';
       parm2(18) := nvl(p1,glbx.extract_fname(file));
       parm1(19) := 'COMPRESSION';
       parm2(19) := p2;
       parm1(20) := 'CONVERT_TO';
       parm2(20) := 'JPEG';
       parm1(11) := 'THUMBNAIL_QUALITY';
       parm2(11) := p4;
       ump.load_uma(surl,parm1,parm2,retval, newid_arr ); new_id := newid_arr(1);
   end if;
  commit;
  manage_gallery( surl, acid, nvl(retval,LNG.PHG_ALT_424 || p1 || LNG.PHG_ALT_425) );
exception when others then
 --owa_content.delete_document( file );
 glbx.error_details( 'PHG', 'GALLERY_LOAD',pid,acid,errmsg=>sqlerrm);
end gallery_load;

procedure phg_utlts_prefs(surl in varchar2, acid in integer, msg in varchar2 default null)
as

 cursor c1(owner_id integer) is select skill_level from photographer where pid = owner_id;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_UTLTS_PREFS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_352,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P27',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;
 theme_rec := get_theme_types( surl,acid );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=3 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
  if substr(theme_rec.theme_data,23,1) = 'T' then
   htp.tablerowopen;
    htp.tabledata(htf.anchor('phg.private_scenes?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/card1.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_333 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    if substr(theme_rec.theme_data,110,1) = 'F'
     then
      htp.tabledata(htf.anchor('phg.private_scenes?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_333 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     else
      htp.tabledata(htf.anchor('phg.private_scenes?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_333 || '-' || LNG2.PBK_TXT_058 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
    end if;
   htp.tablerowclose;
  end if;
  if c1rec.skill_level in (LNG2.PBK_TXT_080,LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
   then
    if substr(theme_rec.theme_data,52,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.mnt_resize?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_resize.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_367 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.mnt_resize?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_367 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
    if substr(theme_rec.theme_data,82,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.phg_rename?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_rename.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_514 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.phg_rename?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_514 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
  end if;
  /* Moved into above option
  if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
   then
    if substr(theme_rec.theme_data,73,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.phg_mass_ch?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_msc.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_439 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.phg_mass_ch?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_439 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
  end if;
  */
  if substr(theme_rec.theme_data,99,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.phg_move?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&p1=&p2=',htf.img( DECS.IMAGE_LOCATION || 'admin/pref_mve.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_527 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.phg_move?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&p1=&p2=','<b><font size="+1">' || LNG.PHG_TXT_527 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
  end if;
  if c1rec.skill_level in (LNG2.PBK_TXT_082)
   then
    if substr(theme_rec.theme_data,98,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=LINK&stype=' || stype || '&mwidth=4',htf.img( DECS.IMAGE_LOCATION || 'admin/pref_lnk.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_528 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.photo_fast_edit_acct_mst?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&typ=LINK&stype=' || stype || '&mwidth=4','<b><font size="+1">' || LNG.PHG_TXT_528 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
  end if;
  if substr(theme_rec.theme_data,62,1) = 'T' then
   htp.tablerowopen;
    htp.tabledata(htf.anchor('phg.phg_password?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_pass.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_431 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata(htf.anchor('phg.phg_password?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_ALT_431 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
  end if;
  if substr(theme_rec.theme_data,111,1) = 'T' then
   htp.tablerowopen;
    htp.tabledata(htf.anchor('phg.phg_prefs_thb?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_thb.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_016 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata(htf.anchor('phg.phg_prefs_thb?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_016 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
   htp.tablerowclose;
  end if;
  if c1rec.skill_level in (LNG2.PBK_TXT_082)
   then
    if substr(theme_rec.theme_data,79,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.check_images?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_check.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_012 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.check_images?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_012 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
    if substr(theme_rec.theme_data,100,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.restore_from_backup?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_back.gif',cattributes=>'border=0',calt=>LNG.PHG_TXT_075 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.restore_from_backup?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_075 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
    if substr(theme_rec.theme_data,9,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('pfm.main?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_pfr.gif',cattributes=>'border=0',calt=>LNG.PHG_ALT_331 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('pfm.main?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG.PHG_TXT_332 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
    if substr(theme_rec.theme_data,134,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.isglobal_photos?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_glb.gif',cattributes=>'border=0',calt=>LNG2.PBK_TXT_069 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.isglobal_photos?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG2.PFM_TXT_069 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
  end if;
  if c1rec.skill_level in (LNG2.PBK_TXT_081,LNG2.PBK_TXT_082)
   then
    if substr(theme_rec.theme_data,75,1) = 'T' then
     htp.tablerowopen;
      htp.tabledata(htf.anchor('phg.delete_disabled_photos?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'admin/pref_del.gif',cattributes=>'border=0',calt=>LNG2.PBK_TXT_094 )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
      htp.tabledata(htf.anchor('phg.delete_disabled_photos?surl=' || glbx.rndsurl(surl) || '&acid=' || acid,'<b><font size="+1">' || LNG2.PBK_TXT_094 || '</font></b>'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
    end if;
  end if;
  htp.tableclose;
  htp.nl;

  if substr(theme_rec.theme_data,193,1) = 'T'
   then
    htp.anchor2( 'phg.customer_logon?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || 'admin/log_ownr.gif',cattributes=>' border=0',calt=>LNG.PHG_ALT_358 ),ctarget=>'CUSTOMER_WINDOW_' || to_char(sysdate,'SSSSS'));
  end if;
  if substr(theme_rec.theme_data,190,1) = 'T'
   then
    htp.anchor2( 'phg.customer_logon?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&login_type=CUSTOMER', htf.img( DECS.IMAGE_LOCATION || 'admin/log_cust.gif',cattributes=>' border=0',calt=>LNG.PHG_ALT_135 ),ctarget=>'CUSTOMER_WINDOW_' || to_char(sysdate,'SSSSS'));
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'PHG', 'PHG_UTLTS_PREFS',errmsg=>sqlerrm);
end phg_utlts_prefs;

procedure phg_password(surl in varchar2,acid in integer, msg in varchar2 default null)
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PASSWORD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_433,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P29',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 theme_rec := get_theme_types( surl,acid );
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.formopen( 'glbx.change_password' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.GLB_TXT_117),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formpassword( 'P1', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.GLB_TXT_116),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formpassword( 'P2', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.GLB_TXT_105),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.formpassword( 'P3', 30, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( 'ACTION', LNG.PHG_ALT_431 );
  htp.formsubmit( 'ACTION', LNG.PHG_TXT_052 );
  htp.formclose;
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_PASSWORD',errmsg=>sqlerrm);
end phg_password;

procedure phg_mass_ch(surl in varchar2, acid in integer, action in varchar2, msg in varchar2 default null, startover in char default 'F')
as

 cursor c1(acid integer) is select scene_name from customer_account where aid = acid;
 cursor c2( snm varchar2, acid integer, phgid integer ) is
   select umo_scene_id,title,parent_scene
   from umo_scene
   where category = snm and
         ((owned_by = 'PUBLIC') or (owned_by in ('OWNER','CUSTOMER') and owner_id = acid) or (owned_by='PHOTOGRAPHER' and owner_id = phgid))
   order by order_by;
 cursor c3 is select film_size from film_sizes order by film_size;
 cursor c4(threc varchar2) is select film_type from film_types where theme_type = threc order by film_type;
 cursor c5(acid integer) is select count('x') tot from umo um where aid = acid;
 cursor c6(acid integer, phgid integer) is
  select um.umo_id, um.extras.film_name film_name
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT') and
        um.aid = ca.aid and
	ca.pid = phgid
  order by umo_id;
 cursor c7(phgid integer) is select virtual_directory from ftp_sites_phg where pid = phgid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 bl		boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 tot		integer;
 tmp		varchar2(32767);
 fnames		GLBX.MYARRAY;

 procedure disp_title( surl in varchar2,keyparm in varchar2, counter in integer )
 as
 begin
  if counter <= 1000
   then
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
     htp.formselectopen( keyparm );
     htp.formselectoption( NULL );
     for j in fnames.first..fnames.last loop
      htp.p( fnames(j) );
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
   else
     htp.tabledata( htf.formtext( keyparm, 10, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
  end if;
 end disp_title;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_MASS_CH', iscust=>FALSE, reset=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 if startover = 'T'
  then
   glbx.main_title( surl, null,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P25',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.nl;
 open c5(acid);
 fetch c5 into tot;
 close c5;
 tot := nvl(tot,0);
 if tot <= 1000
  then
   for c6rec in c6(acid,owner_id) loop
    fnames(c6%ROWCOUNT) := htf.formselectoption( c6%ROWCOUNT || '. ' || c6rec.film_name, cattributes=>'VALUE="' || c6%ROWCOUNT || '"' );
   end loop;
  else
   glbx.header_msg( LNG2.PBK_TXT_093 );
 end if;

 htp.formopen( 'phg.accept_mass_ch' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'TYP', action );

 if action = 'CATEGORIES'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0');
   open c1(acid);
   fetch c1 into c1rec;
   close c1;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_440),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.PHG_TXT_441),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.CST_TXT_042),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   for j in 1..10 loop
     htp.tablerowopen;
      disp_title( surl, 'P1', tot );
      disp_title( surl, 'P2', tot );
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">');
      htp.formselectopen( 'P3' );
      for c2rec in c2(c1rec.scene_name,acid,owner_id) loop
       htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
      end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
     htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( NULL, LNG.PHG_TXT_442 );
   htp.formclose;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 if action = 'ROLL'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0');
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_440),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG.PHG_TXT_441),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG.PHG_TXT_338),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   for j in 1..10 loop
     htp.tablerowopen;
      disp_title( surl, 'P1', tot );
      disp_title( surl, 'P2', tot );
      htp.tabledata( htf.formtext( 'P3', 10, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( NULL, LNG.PHG_TXT_524 );
   htp.formclose;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 if action = 'PHOTO_NO'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0');
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_440),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.tabledata( htf.bold(LNG.PHG_TXT_441),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   for j in 1..10 loop
     htp.tablerowopen;
      disp_title( surl, 'P1', tot );
      disp_title( surl, 'P2', tot );
      htp.formhidden( 'P3', NULL );
     htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( NULL, LNG5.EXT_TXT_222 );
   htp.formclose;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 if action = 'DIR'
  then
   bl := ump.create_directory_images(surl, acid );
   htp.nl;
   htp.bold( 'Thumbnail Directory Listing Created');
   htp.nl;
   htp.htmlclose;
   return;
 end if;

 if action = 'FILM'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0');
   htp.formopen( 'phg.accept_mass_ch' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'TYP', 'SIZE' );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
   tmp := htf.formselectopen( 'P3' );
   for c3rec in c3 loop
    tmp := tmp || htf.formselectoption( c3rec.film_size );
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_440),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.PHG_TXT_441),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.PHG_TXT_360),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   for j in 1..10 loop
    htp.tablerowopen;
     disp_title( surl, 'P1', tot );
     disp_title( surl, 'P2', tot );
     htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( NULL, LNG.PHG_TXT_525 );
   htp.formclose;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 if action = 'PRODUCT'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0');
   tmp := NULL;
   for c4rec in c4( theme_rec.theme_type ) loop
    tmp := tmp || htf.formselectoption( c4rec.film_type );
   end loop;
   if tmp is null
    then
     tmp := htf.formselectopen( 'P3' ) || htf.formselectoption( LNG.ORD_TXT_194 ) || htf.formselectclose;
    else
     tmp := htf.formselectopen( 'P3' ) || tmp || htf.formselectclose;
   end if;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_440),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.PHG_TXT_441),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.LAB_TXT_014),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   for j in 1..10 loop
     htp.tablerowopen;
      disp_title( surl, 'P1', tot );
      disp_title( surl, 'P2', tot );
      htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( NULL, LNG.PHG_TXT_526 );
   htp.formclose;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 if action = 'FTP'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0');
   tmp := htf.formselectopen( 'P3' ) || htf.formselectoption( NULL );
   for c7rec in c7(owner_id) loop
    tmp := tmp || htf.formselectoption( c7rec.virtual_directory );
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_440),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.PHG_TXT_441),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.PHG_TXT_533),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   for j in 1..10 loop
     htp.tablerowopen;
      disp_title( surl, 'P1', tot );
      disp_title( surl, 'P2', tot );
      htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( NULL, LNG2.PBK_TXT_127 );
   htp.formclose;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 if action = 'CTG'
  then
   htp.italic( 'Search for all Private Categories with the same name but different case and convert/merge them:' );
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0');
    htp.tablerowopen;
     htp.tabledata( htf.bold('Change to'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     htp.p( '<TD ' || pfx.qbground || 'valign="MIDDLE" align="CENTER">');
      htp.formselectopen( 'P3' );
      htp.formselectoption( 'Uppercase' );
      htp.formselectoption( 'Initialised Case' );
      htp.formselectoption( 'Lowercase' );
      htp.formselectclose;
     htp.p( '</TD>' );
     htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( NULL, 'Change Category Details' );
   htp.formclose;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 if action = 'FTP_RANDOMISE'
  then
   -- xxx language file
   htp.bold( 'Will rename the FTP File Name and the actual external File Name (if it exists in the Directory) to an encrypted name' );
   htp.nl;
   htp.bold( 'Can either Encrypt or Reset the filename back' );
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0');
   tmp := htf.formselectopen( 'P3' ) || htf.formselectoption( NULL );
   tmp := tmp || htf.formselectoption( 'Encrypt' );
   tmp := tmp || htf.formselectoption( 'Reset back to Film Name' );
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.PHG_TXT_440),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold(LNG.PHG_TXT_441),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
    htp.tabledata( htf.bold('Option'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
   for j in 1..10 loop
     htp.tablerowopen;
      disp_title( surl, 'P1', tot );
      disp_title( surl, 'P2', tot );
      htp.tabledata( tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
     htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( NULL, 'Modify FTP File Names' );
   htp.formclose;
   htp.tabledata( htf.formopen( 'phg.mnt_resize' ) ||  htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ACID', acid ) ||
                 htf.formsubmit( null, LNG2.PFM_TXT_027 ) || htf.formclose );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

exception when others then
 glbx.error_details( 'PHG', 'PHG_MASS_CH',errmsg=>sqlerrm);
end phg_mass_ch;

procedure accept_mass_ch( surl in varchar2, acid in integer, typ in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

 cursor c1(acid integer, phgid integer) is
  select um.rowid, um.umo_id,  um.extras.film_name film_name, um.ftp_location, um.ftp_virtual_dir
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT') and
        um.aid = ca.aid and
	ca.pid = phgid
  order by umo_id;

 cursor c2 is select attribute_id from umo_attributes where umo_type = 'PHOTO' and sub_category = 'FILM_TYPE';
 cursor c3 is select attribute_id from umo_attributes where umo_type = 'PHOTO' and sub_category = 'FILM_SIZE';
 cursor c4 is select attribute_id from umo_attributes where umo_type = 'PHOTO' and sub_category = 'ROLL_ID';

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb1		integer;
 nmb2		integer;
 ctr		integer;
 attrid		integer;
 pnmb		integer;
 msg		varchar2(2000);

 function find_nmb( val in varchar2 )
  return integer
 is
  x	integer;
  y	integer;
  tmp	varchar2(1000);
 begin

  x := instr(val,'1');
  y := instr(val,'2');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'3');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'4');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'5');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'6');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'7');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'8');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(val,'9');
  if not((y = 0) or (y > x)) then x := y; end if;
  if x = 0 then return( NULL ); end if;
  tmp := substr(val,x);

  x := instr(tmp,'.');
  y := instr(tmp,';');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'-');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,',');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'[');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'{');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'<');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'(');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'*');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'+');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'@');
  if not((y = 0) or (y > x)) then x := y; end if;
  y := instr(tmp,'$');
  if not((y = 0) or (y > x)) then x := y; end if;
  for j in 65..90 loop
   y := instr(tmp,chr(j));
   if not((y = 0) or (y > x)) then x := y; end if;
  end loop;
  for j in 97..122 loop
   y := instr(tmp,chr(j));
   if not((y = 0) or (y > x)) then x := y; end if;
  end loop;
  tmp := substr(tmp,1,x-1);

  begin
   y := to_number(tmp);
   return( y );
  exception
   when others then return( NULL );
  end;

 end find_nmb;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_MASS_CH', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 msg := NULL;
 if typ = 'ROLL'
  then
   open c4;
   fetch c4 into attrid;
   close c4;
 end if;
 if typ = 'FILM'
  then
   open c3;
   fetch c3 into attrid;
   close c3;
 end if;
 if typ = 'PRODUCT'
  then
   open c2;
   fetch c2 into attrid;
   close c2;
 end if;
 if typ = 'CTG'
  then
   -- xxx ctg
   -- loop through and find all title the sames
   -- take first and convert to case
   -- update umo accordingly
   -- take second and update accordingly
   -- delete second
   -- repeat
   /* xxx
   for c5rec in c5(acid,p3) loop
     update umo um
      set
       umo_scene_id = c5rec.scene_id,
       um.extras.title = c5rec.title,
       um.extras.orderby_scene = c5rec.orderby
     where rowid = c5rec.umo_id;
   end loop;
   */
   commit;
   phg_mass_ch(surl,acid,typ,nvl(msg,LNG.CST_TXT_010),startover=>'T');
 end if;

 for j in p1.first..p1.last loop
  begin nmb1 := to_number(p1(j)); exception when others then nmb1 := null; end;
  begin nmb2 := to_number(p2(j)); exception when others then nmb2 := null; end;
  if (nmb1 is not null) and (nmb2 is not null) and (nmb1 > 0) and (nmb2 > 0) and (nmb2 >= nmb1)
   then
    for c1rec in c1(acid,owner_id) loop
     if c1%ROWCOUNT >= nmb1 and
        c1%ROWCOUNT <= nmb2
         then
          if typ = 'CATEGORIES'
           then
            update umo um
             set
              umo_scene_id = p3(j),
              um.extras.title = (select title from umo_scene usc where umo_scene_id = to_number(p3(j))),
              um.extras.orderby_scene = (select order_by from umo_scene usc where umo_scene_id = to_number(p3(j)))
            where rowid = c1rec.rowid;
          elsif typ = 'ROLL'
           then
            update umo um
             set
              um.extra_roll_id = p3(j)
            where rowid = c1rec.rowid;
            update umo_attribute set value = p3(j) where umo_id = c1rec.umo_id and attribute_id = attrid;
          elsif typ = 'PHOTO_NO'
           then
            pnmb := find_nmb(c1rec.film_name);
            update umo um
             set
              um.extras.orderby_nmb = pnmb
            where rowid = c1rec.rowid;
          elsif typ = 'FILM'
           then
            update umo um
             set
              um.extra_film_size = p3(j)
            where rowid = c1rec.rowid;
            update umo_attribute set value = p3(j) where umo_id = c1rec.umo_id and attribute_id = attrid;
          elsif typ = 'PRODUCT'
           then
            update umo um
             set
              um.extra_film_colour = p3(j)
            where rowid = c1rec.rowid;
            update umo_attribute set value = p3(j) where umo_id = c1rec.umo_id and attribute_id = attrid;
          elsif typ = 'FTP'
           then
            update umo um
             set
              um.ftp_virtual_dir = p3(j),
              um.ftp_location = nvl(um.ftp_location,um.extras.film_name)
            where rowid = c1rec.rowid;
          elsif typ = 'FTP_RANDOMISE'
           then
            change_loc( c1rec.umo_id, c1rec.film_name, c1rec.ftp_virtual_dir, p3(j) );
          end if;
     end if;
    end loop;
    msg := msg || '(' || SQL%ROWCOUNT || ')-' || LNG.PHG_TXT_443 || ': ' || nmb1 || '-' || nmb2;
  end if;
 end loop;
 commit;
 phg_mass_ch(surl,acid,typ,nvl(msg,LNG.CST_TXT_010),startover=>'T');
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_MASS_CH',errmsg=>sqlerrm);
end accept_mass_ch;

procedure change_loc( v_umo in integer, film_name in varchar2, virdir in varchar2, voption in varchar2 )
as

 cursor c1(virdir varchar2) is select * from ftp_sites where virtual_directory = virdir;
 cursor c2(v_umo integer) is select ftp_location from umo where umo_id = v_umo;

 c1rec  	c1%ROWTYPE;
 c2rec  	c2%ROWTYPE;
 oldname	varchar2(1000);
 newname	varchar2(1000);
 sfx		varchar2(100);
 bl		boolean;
begin
 if virdir is null then return; end if;
 open c1(virdir);
 fetch c1 into c1rec;
 close c1;
 if c1rec.actual_location is null then return; end if;

 if voption = 'Encrypt'
  then
   open c2(v_umo);
   fetch c2 into c2rec;
   close c2;
   if c2rec.ftp_location is null
    then
     oldname := film_name;
    else
     oldname := c2rec.ftp_location;
     if c2rec.ftp_location like 'd' || to_char(v_umo) || '%' then return; end if; -- Sanity Check. It means the name is already encrypted.
   end if;
   sfx := glbx.extract_fname( oldname, 'SUFFIX');
   if sfx is null
    then
     newname := 'd' || to_char(v_umo) || glbx.encrypt_password(glbx.extract_fname( film_name,'NO_EXTENSION'),8);
    else
     newname := 'd' || to_char(v_umo) || glbx.encrypt_password(glbx.extract_fname( film_name,'NO_EXTENSION'),8) || '.' || sfx;
   end if;

  elsif voption = 'Reset back to Film Name'
   then
   open c2(v_umo);
   fetch c2 into c2rec;
   close c2;
   oldname := c2rec.ftp_location;
   sfx := glbx.extract_fname( oldname, 'SUFFIX');
   if sfx is null
    then
     newname := film_name;
    else
     newname := film_name || '.' || sfx;
   end if;
 end if;

 if oldname is not null then bl := ump.file_rename( source=>c1rec.actual_location || oldname, destination=>newname ); end if;
 if bl
  then
   update umo
    set
     ftp_location = newname
   where
    umo_id = v_umo;
   commit;
 end if;
end change_loc;

procedure readme(surl in varchar2)
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 cusrec		customer_account%ROWTYPE;
 tag_name	GLBX.MYARRAY;
 tag_title	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.README', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 htp.htmlopen;
 htp.p( '<BODY bgcolor="#FFFFFF">' );
 htp.p( '<CENTER>' );
 htp.tableopen;
  htp.tablerowopen;
  htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || '>' );
  cusrec.pid := owner_id;
  cusrec.username := NULL;
  glbx.external_html_file( surl, cusrec, 'README', tag_name, tag_title );
  htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'README',errmsg=>sqlerrm);
end readme;

procedure check_images( surl in varchar2,acid in integer )
as
 cursor c1(acid integer,owner_id integer) is select umo_id,version from umo where umo_type = 'PHOTO' and aid = acid and aid in (select aid from customer_account where aid = acid and pid = owner_id) order by umo_id;
 cursor c2(v_umo integer) is select um.photo_original,um.photo_master,um.photo_thumbnail from umo um where umo_id = v_umo for update;
 cursor c3(v_umo integer) is select decode(um.extras.enabled_phg,'T',LNG.PHG_TXT_045,'TRUE',LNG.PHG_TXT_045,LNG.PHG_TXT_046) enabled from umo um where umo_id = v_umo;
 cursor c4(acid integer) is select * from umo um where aid = acid;
 cursor c5(usc integer) is select * from umo_scene where umo_scene_id = usc;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tnail		integer;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.CHECK_IMAGES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_012,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P31',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>');
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tableheader( LNG.PHG_TXT_048,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.PHG_TXT_049,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.PHG_TXT_050,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.GLB_TXT_064,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tableheader( LNG.GLB_TXT_055,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;

 for c1rec in c1(acid,owner_id) loop
  begin
   open c2(c1rec.umo_id);
   fetch c2 into c2rec;
   close c2;
   htp.tablerowopen;
   htp.tabledata( to_char(c1rec.umo_id),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
   begin
    if (nvl(c2rec.photo_original.contentlength,0) = 0) or (nvl(dbms_lob.getlength(c2rec.photo_original.source.localdata),0) = 0)
     then
      htp.tabledata( LNG.PHG_TXT_013,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     else
      c2rec.photo_original.setproperties;
      htp.tabledata( LNG.PHG_TXT_043,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    end if;
    exception
     when others then
      htp.tabledata( htf.bold(LNG.PHG_TXT_044),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   end;

   begin
    if (nvl(c2rec.photo_master.contentlength,0) = 0) or (nvl(dbms_lob.getlength(c2rec.photo_master.source.localdata),0) = 0)
     then
      htp.tabledata( LNG.PHG_TXT_013,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      update umo um set um.extras.enabled_phg = 'F' where umo_id = c1rec.umo_id;
     else
      c2rec.photo_master.setproperties;
      if c2rec.photo_master.mimetype not in ('image/gif','image/jpeg')
       then
        c2rec.photo_master.process('fileformat=JFIF compressionFormat=JPEG compressionQuality=MAXINTEGRITY');
        update umo um set photo_master = c2rec.photo_master where umo_id = c1rec.umo_id;
        htp.tabledata( htf.anchor2('ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
             '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid), LNG.PHG_TXT_051, ctarget=>'NEW_WINDOW'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
       else
        htp.tabledata( htf.anchor2('ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
             '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid), LNG.PHG_TXT_043, ctarget=>'NEW_WINDOW'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
      end if;
    end if;
    exception
     when others then
      htp.tabledata( htf.bold(LNG.PHG_TXT_044),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      update umo um set um.extras.enabled_phg = 'F' where umo_id = c1rec.umo_id;
   end;

   begin
    c2rec.photo_thumbnail.setproperties;
    if (nvl(c2rec.photo_thumbnail.contentlength,0) = 0) or (nvl(dbms_lob.getlength(c2rec.photo_thumbnail.source.localdata),0) = 0)
     then
      tnail := glbx.userpref(owner_id,acid,'THUMBNAIL_WIDTH');
      tnail := nvl(tnail,100);
      c2rec.photo_master.copy(c2rec.photo_thumbnail);
      c2rec.photo_thumbnail.process('fileformat=JFIF compressionFormat=JPEG compressionQuality=MAXINTEGRITY maxScale=(' || tnail || ' ' || tnail || ')');
      update umo um set photo_thumbnail = c2rec.photo_thumbnail where umo_id = c1rec.umo_id;
      htp.tabledata( htf.anchor2('ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
             '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid), LNG.PHG_TXT_051, ctarget=>'NEW_WINDOW'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     else
      if c2rec.photo_thumbnail.mimetype not in ('image/gif','image/jpeg')
       then
        c2rec.photo_master.process('fileformat=JFIF compressionFormat=JPEG compressionQuality=MAXINTEGRITY');
        update umo um set photo_thumbnail = c2rec.photo_thumbnail where umo_id = c1rec.umo_id;
        htp.tabledata( htf.anchor2('ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
             '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid), LNG.PHG_TXT_051, ctarget=>'NEW_WINDOW'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
       else
        htp.tabledata( htf.anchor2('ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
             '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid), LNG.PHG_TXT_043, ctarget=>'NEW_WINDOW'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
      end if;
    end if;
    exception
     when others then
      htp.tabledata( htf.bold(LNG.PHG_TXT_044),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   end;
   commit;
 exception
   when others then
   htp.tablerowopen;
    htp.tabledata( to_char(c1rec.umo_id),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( LNG2.UMP_TXT_005,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
  end;
  open c3(c1rec.umo_id);
  fetch c3 into c3rec;
  close c3;
  htp.tabledata( c3rec.enabled,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;

 update umo um
  set
   um.extras = repeated_fields(null,null,null,null,null,null,null,'TRUE','TRUE')
   where um.extras is null;
 if SQL%ROWCOUNT > 0
  then
   htp.nl; htp.bold( LNG.PHG_TXT_438 || ':' || SQL%ROWCOUNT ); htp.nl;
 end if;
 commit;

 -- Fix where replicated data fields do not match
 for c4rec in c4(acid) loop
  open c5(c4rec.umo_scene_id);
  fetch c5 into c5rec;
  close c5;
  if (nvl(c5rec.order_by,0) <> nvl(c4rec.extras.orderby_scene,0)) or
     (nvl(c5rec.title,'x') <> nvl(c4rec.extras.title,'x'))
   then
    update umo um
     set
      um.extras.orderby_scene = c5rec.order_by,
      um.extras.title = c5rec.title
     where umo_id = c4rec.umo_id;
    htp.bold( LNG.PHG_TXT_346 || ':' || c4rec.umo_id ); htp.nl;
  end if;
 end loop;
 commit;

 htp.formopen( 'phg.phg_utlts_prefs');
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formsubmit( null, LNG.PHG_TXT_052);
 htp.formclose;
 htp.p( '</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'CHECK_IMAGES',errmsg=>sqlerrm,extdet=>'AID:' || acid);
end check_images;

procedure mng_prof_scenes(surl in varchar2,acid in integer, profid in integer, msg in varchar2 default null)
as
 cursor c1( profid integer ) is select umo_scene_id from profile_scenes where profile_id = profid;
 cursor c2(v_category varchar2, v_owner_id integer) is
 select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;
 cursor c3( profid integer) is select scene_name from customer_profile where profile_id = profid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 -- tmp		varchar2(32767);
 pfx		THEME%ROWTYPE;
 vcat		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.MNG_PROF_SCENES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_069,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P34',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); else glbx.header_msg( LNG.PHG_TXT_068 ); end if;
 htp.p( '<CENTER>');
 htp.formopen( 'phg.accept_prof_scenes' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'PROFID', profid );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( LNG.PHG_TXT_200,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
  open c3(profid);
  fetch c3 into vcat;
  close c3;
  for c1rec in c1(profid) loop
  htp.tablerowopen;
   htp.p( '<TD>' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    for c2rec in c2(vcat,owner_id) loop
     if c2rec.umo_scene_id = c1rec.umo_scene_id
      then
       htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title,'SELECTED', cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
      else
       htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  end loop;
  for j in 1..10 loop
   htp.tablerowopen;
    htp.p( '<TD>' );
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    for c2rec in c2(vcat,owner_id) loop
     htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"'  );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.PHG_TXT_070 );
 htp.formsubmit( 'ACTION', LNG2.PFM_TXT_027 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'MNG_PROF_SCENES',errmsg=>sqlerrm,extdet=>'AID:' || acid || ' PROFID:' || profid);
end mng_prof_scenes;

procedure accept_prof_scenes(surl in varchar2,acid in integer, profid in integer, action in varchar2, p1 in MYARRAY)
as
 cursor c1(uid integer) is select title,order_by from umo_scene where umo_scene_id = uid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_PROF_SCENES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if action = LNG2.PFM_TXT_027
  then
   phg_acct_details(surl,acid,profid=>profid);
   return;
 end if;

 delete from profile_scenes where profile_id = profid;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    nmb := to_number(p1(j));
    open c1(nmb);
    fetch c1 into c1rec;
    close c1;
    insert into profile_scenes(profile_id,umo_scene_id,title,order_by)
     select profid,nmb,c1rec.title,c1rec.order_by
     from dual
     where not exists (select 'x' from profile_scenes where profile_id = profid and umo_scene_id = nmb);
  end if;
 end loop;
 commit;
 mng_prof_scenes(surl,acid,profid,LNG.PHG_TXT_071);
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_PROF_SCENES',errmsg=>sqlerrm,extdet=>'AID:' || acid || ' PROFID:' || profid);
end accept_prof_scenes;

procedure mng_prof_order(surl in varchar2,acid in integer, profid in integer, msg in varchar2 default null)
as
 cursor c1(profid integer) is select umo_id, qty from profile_order where profile_id = profid;
 cursor c2(v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c3(acid integer) is select umo_id,um.extras.film_name film_name from umo um where aid = acid order by umo_id;

 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 --tmp		varchar2(32767);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.MNG_PROF_ORDER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_064,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P35',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); else glbx.header_msg( LNG.PHG_TXT_063 ); end if;
 htp.p( '<CENTER>');
 htp.formopen( 'phg.accept_prof_order' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'PROFID', profid );
 htp.formhidden( 'P1', null );
 htp.formhidden( 'P3', null );
 htp.formhidden( 'P4', null );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( LNG.PHG_BUT_117,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( LNG.CST_TXT_132,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tableheader( LNG.CST_TXT_135,cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tablerowclose;
  for c1rec in c1(profid) loop
   htp.tablerowopen;
    open c2(c1rec.umo_id);
    fetch c2 into c2rec;
    close c2;

    htp.tabledata( htf.formcheckbox( 'P1', c1rec.umo_id ) ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">');
     htp.anchor2(
               'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c2rec.version) ||
               '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid),
               '<IMG BORDER=0 WIDTH=' || to_char(c2rec.photo_thumbnail.width) || ' HEIGHT=' || to_char(c2rec.photo_thumbnail.height) || ' SRC="' ||
               'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=VERSION&parm2=' || to_char(c2rec.version) ||
               '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid) ||
               '" ALT="' || c2rec.extras.film_name || '" STYLE="display:block;">',
               ctarget=>'NEW_WINDOW');
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P3', 5, 10, c1rec.qty ) ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.formhidden( 'P4',c1rec.umo_id );
   htp.tablerowclose;
  end loop;

  for j in 1..3 loop
   htp.tablerowopen;
    htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
    htp.p( '<TD>' );
     htp.formselectopen( 'P2' );
     htp.formselectoption( NULL );
      for c3rec in c3(acid) loop
       htp.formselectoption( c3rec.film_name, cattributes=>'VALUE="' || c3rec.umo_id || '"'  );
      end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'P5', 5, 10, '1' ) ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tablerowclose;
  end loop;

 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG.PHG_TXT_073 );
 htp.formsubmit( 'ACTION', LNG2.PFM_TXT_027 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'MNG_PROF_ORDER',errmsg=>sqlerrm,extdet=>'AID:' || acid || ' PROFID:' || profid);
end mng_prof_order;

procedure accept_prof_order(surl in varchar2,acid in integer, profid in integer, action in varchar2, p1 in MYARRAY, p2 in MYARRAY, p3 in MYARRAY, p4 in MYARRAY, p5 in MYARRAY)
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 nmb2		integer;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_PROF_ORDER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if action = LNG2.PFM_TXT_027
  then
   phg_acct_details(surl,acid,profid=>profid);
   return;
 end if;

 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    delete from profile_order where profile_id = profid and umo_id = p1(j);
  end if;
 end loop;

 for j in p4.first..p4.last loop
  if p4(j) is not null
   then
    begin nmb := to_number(p3(j)); exception when others then nmb := 1; end;
    update profile_order set qty = nmb where profile_id = profid and umo_id = p4(j);
  end if;
 end loop;

 for j in p2.first..p2.last loop
  if p2(j) is not null
   then
    nmb := to_number(p2(j));
    begin nmb2 := to_number(p5(j)); exception when others then nmb2 := 1; end;
    insert into profile_order(profile_id,umo_id,qty)
     values (profid,nmb,nmb2);
  end if;
 end loop;
 commit;
 mng_prof_order(surl,acid,profid,LNG.PHG_TXT_074);
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_PROF_ORDER',errmsg=>sqlerrm,extdet=>'AID:' || acid || ' PROFID:' || profid);
end accept_prof_order;

procedure phg_move(surl in varchar2,acid in integer, newcust in varchar2 default null, msg in varchar2 default null, pm in varchar2 default 'M', p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY)
as

  cursor c1(acid integer,phgid integer) is select scene_name from customer_account where aid = acid and pid = phgid;
  cursor c2(acid integer) is select scene_name from customer_account where aid = acid;
  cursor c3(acid integer) is select distinct um.umo_scene_id,um.extras.title title from umo um where aid = acid;
/*
   select umo_scene_id,title
   from umo_scene
   where category = scnm and ((owned_by = 'PUBLIC') or (owned_by = 'PRIVATE' and owner_id = phgid)) order by order_by;
*/
  cursor c4(v_category varchar2, v_owner_id integer) is
  select umo_scene_id,owned_by,order_by,title,parent_scene
   from umo_scene
   where category = v_category and
   owned_by = 'PUBLIC'
  union all
  select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
  from umo_scene usc, photographer ph
  where category = v_category and
        usc.owner_id = ph.pid and
        ph.pid = v_owner_id and
        owned_by = 'PHOTOGRAPHER'
  order by 3;

  cursor c5(curr_acid integer, phgid integer) is select aid,nvl(account_name,username) acct_name from customer_account where pid = phgid and aid <> curr_acid order by account_name;
  cursor c6(acid integer, phgid integer) is
   select um.umo_id, um.extras.film_name film_name
   from umo um, customer_account ca
   where um.aid = acid and
         um.umo_type in ('PHOTO','AUDIO','VIDEO','DOCUMENT','RELATIONAL','BLUEPRINT') and
         um.aid = ca.aid and
	 ca.pid = phgid
   order by umo_id;
  cursor c7(acid integer) is select count('x') tot from umo um where aid = acid;
  cursor c9(phid integer) is select scene_name from limit_scenes where pid = phid order by scene_name;
  cursor c11(phid integer) is select limit_scene from photographer where pid = phid;

 c1rec		c1%ROWTYPE;
 c11rec		c11%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 scene		varchar2(100);
 --tmp		varchar2(4000);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;
 tot		integer;
 fnames		GLBX.MYARRAY;

 procedure disp_title( keyparm in varchar2, counter in integer )
 as
 begin
  if counter <= 1000
   then
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
     htp.formselectopen( keyparm );
     htp.formselectoption( NULL );
     for j in fnames.first..fnames.last loop
      htp.p( fnames(j) );
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
   else
     htp.tabledata( htf.formtext( keyparm, 10, 100 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
  end if;
 end disp_title;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_MOVE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_527,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P36',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 open c7(acid);
 fetch c7 into tot;
 close c7;
 tot := nvl(tot,0);
 if tot <= 1000
  then
   for c6rec in c6(acid,owner_id) loop
    fnames(c6%ROWCOUNT) := htf.formselectoption( c6%ROWCOUNT || '. ' || c6rec.film_name, cattributes=>'VALUE="' || c6%ROWCOUNT || '"' );
   end loop;
  else
   glbx.header_msg( LNG2.PBK_TXT_093 );
 end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 open c1(acid,owner_id);
 fetch c1 into c1rec;
 close c1;
 if newcust is null
  then
       htp.header(3,LNG.PHG_TXT_531,'CENTER');
       htp.header(4,LNG.PHG_TXT_532,'CENTER');
       htp.formopen( 'phg.phg_move' );
       htp.formhidden( 'SURL', glbx.rndsurl(surl));
       htp.formhidden( 'ACID', acid );
       htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_529), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">');
          htp.formselectopen( 'NEWCUST' );
          for c5rec in c5(acid,owner_id) loop
           htp.formselectoption( c5rec.acct_name, cattributes=>'VALUE="' || c5rec.aid || '"' );
          end loop;
          htp.formselectclose;
         htp.p( '</TD>' );
        htp.tablerowclose;
       htp.tableclose;
       htp.nl;
       htp.p( htf.formradio( 'PM', 'M', 'CHECKED' ) || ' ' || htf.bold( LNG2.PFM_TXT_152 ) || ' ' || htf.formradio( 'PM', 'C' ) || ' ' || htf.bold( LNG2.PFM_TXT_154 ) );
       htp.nl;
       htp.nl;
       htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_440),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
         htp.tabledata( htf.bold(LNG.PHG_TXT_441),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
       htp.tablerowclose;
       for j in 1..10 loop
        htp.tablerowopen;
         disp_title( 'P1', tot );
         disp_title( 'P2', tot );
        htp.tablerowclose;
      end loop;
      htp.tableclose;
      htp.nl;
      htp.nl;
      htp.formsubmit(null,LNG4.AHC_TXT_760);
      htp.formclose;
   else
       htp.formopen( 'phg.accept_move', ctarget=>'PHG_BOTTOM' );
       htp.formhidden( 'SURL', glbx.rndsurl(surl));
       htp.formhidden( 'ACID', acid );
       htp.formhidden( 'PM', pm );
       htp.formhidden( 'NEWCUST', newcust );
       for j in p1.first..p1.last loop
        htp.formhidden( 'P1', p1(j) );
        htp.formhidden( 'P2', p2(j) );
       end loop;
       open c2(newcust);
       fetch c2 into scene;
       close c2;
       htp.formhidden( 'SCENE', scene );
       htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG.PHG_TXT_515), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
         htp.tabledata( htf.bold(LNG.PHG_TXT_516), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
        htp.tablerowclose;
        foundrec := FALSE;
        htp.formhidden( 'P4', null );
        htp.formhidden( 'P3', null );
        for c3rec in c3(acid) loop
         htp.tablerowopen;
          foundrec := TRUE;
          if c3rec.umo_scene_id is not null
           then
            htp.tabledata( htf.bold(c3rec.title), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.formhidden( 'P4', c3rec.umo_scene_id );
            htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">');
             htp.formselectopen( 'P3' );
             for c4rec in c4(scene,owner_id) loop
              htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c4rec.parent_scene),pfx.nested_scene_delim) || c4rec.title, cattributes=>'VALUE="' || c4rec.umo_scene_id || '"'  );
             end loop;
             htp.formselectclose;
            htp.p( '</TD>' );
          end if;
        htp.tablerowclose;
        end loop;
       htp.tableclose;
       htp.nl;
       if foundrec
        then
         if pm = 'M'
          then
           htp.formsubmit(null,LNG.PHG_TXT_530);
          else
           htp.formsubmit(null,LNG.PHG_TXT_534);
         end if;
         htp.formclose;
        else
         htp.header(3,LNG.GLB_TXT_103,'CENTER');
         htp.nl;
       end if;
 end if;
 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_MOVE',owner_id,vaid=>acid,errmsg=>sqlerrm,extdet=>'SCENE:' || scene);
end phg_move;

procedure accept_move(surl in varchar2,acid in integer, newcust in integer, scene in varchar2, pm in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY)
as
 cursor c1(acid integer, phgid integer) is
  select um.rowid, um.umo_id, um.umo_scene_id,um.umo_type
  from umo um, customer_account ca
  where um.aid = acid and
        um.aid = ca.aid and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','RELATIONAL','DOCUMENT','BLUEPRINT') and
	ca.pid = phgid
  order by umo_id;

 cursor c2(acid integer, phgid integer) is
  select count('x')
  from umo um, customer_account ca
  where um.aid = acid and
        um.umo_type in ('PHOTO','AUDIO','VIDEO','RELATIONAL','DOCUMENT','BLUEPRINT') and
        um.aid = ca.aid and
	ca.pid = phgid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb1		integer;
 nmb2		integer;
 newid		integer;
 sload		GLBX.MYARRAY;
 eload		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_MOVE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 sload := p1;
 eload := p2;
 if sload(1) is null or sload(2) is null
  then
   sload(1) := nvl(sload(1),1);
   open c2(acid,owner_id);
   fetch c2 into eload(1);
   close c2;
   eload(1) := nvl(p2(1),eload(1));
 end if;
 -- Loop through for each new scene
 -- P4 (old Value) P3 New Value
 --htp.p( 'S1:+' || sload(1) || '+ E1:+' || eload(1) || '+'); htp.nl;

 for j in sload.first..sload.last loop
   begin nmb1 := to_number(sload(j)); exception when others then nmb1 := null; end;
   begin nmb2 := to_number(eload(j)); exception when others then nmb2 := null; end;
   if (nmb1 is not null) and (nmb2 is not null) and (nmb1 > 0) and (nmb2 > 0) and (nmb2 > nmb1)
    then

    for c1rec in c1(acid,owner_id) loop
     if c1%ROWCOUNT >= nmb1 and
        c1%ROWCOUNT <= nmb2
       then

        -- loop through all categories
        for k in p3.first..p3.last loop
         --htp.p( 'P1-' || sload(j) || ' P2-' || eload(j) || ' P3-' || p3(j) || ' P4-' || p4(j) || ' USC:' || c1rec.umo_scene_id );htp.nl;
         if pm = 'M'
          then
           if nvl(c1rec.umo_scene_id,0) = nvl(p4(k),0)
            then
             update umo um
              set
               aid = newcust,
               umo_scene_id = p3(k),
               um.extras.title = (select title from umo_scene usc where umo_scene_id = to_number(p3(k))),
               um.extras.orderby_scene = (select order_by from umo_scene usc where umo_scene_id = to_number(p3(k)))
             where rowid = c1rec.rowid and
                   nvl(umo_scene_id,0) = nvl(p4(k),0);
             audit_utility( c1rec.umo_id,'UMO_SCENE_ID', p4(k),p3(k), 'ACCEPT_MOVE-MOVE' );
             audit_utility( c1rec.umo_id,'AID', acid,newcust, 'ACCEPT_MOVE-MOVE' );
             update umo_index um
              set
              aid = newcust
               where aid = acid and
                     umo_id = c1rec.umo_id;
             if c1rec.umo_type = 'AUDIO'
              then
               myaudio.audio_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'MOVE');
             elsif c1rec.umo_type = 'VIDEO'
              then
               myvideo.video_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'MOVE');
             elsif c1rec.umo_type = 'RELATIONAL'
              then
               myrelational.relational_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'MOVE');
             elsif c1rec.umo_type = 'BLUEPRINT'
              then
               myblueprint.blueprint_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'MOVE');
             elsif c1rec.umo_type = 'DOCUMENT'
              then
               mydocument.document_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'MOVE');
             end if;
           end if;

         else

          if nvl(c1rec.umo_scene_id,0) = nvl(p4(k),0)
           then
            select s_umo.nextval into newid from dual;
            insert into umo
             (umo_id,parent_id,aid,umo_type,umo_owner,umo_scene_id,version,extras,extra_film_colour,extra_roll_id,extra_film_size,
              photo_original,photo_master,photo_thumbnail,photo_backup,audio_original,audio_thumbnail,video_original,
              ftp_location,ftp_virtual_dir,photo_original_loc,audio_original_loc,video_original_loc,
              doc_mimetype,doc_type,doc_pov,doc_length,doc_body,doc_html,doc_gist,document_original_loc,image_caption,pricing_structure,
              is_global,date_created,expire_date,report_id,attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,
              blueprint_obj)
             select
              newid,um.parent_id,newcust,um.umo_type,um.umo_owner,um.umo_scene_id,um.version,um.extras,um.extra_film_colour,um.extra_roll_id,um.extra_film_size,
              um.photo_original,um.photo_master,um.photo_thumbnail,um.photo_backup,um.audio_original,um.audio_thumbnail,um.video_original,
              um.ftp_location,um.ftp_virtual_dir,um.photo_original_loc,um.audio_original_loc,um.video_original_loc,
              um.doc_mimetype,um.doc_type,um.doc_pov,um.doc_length,um.doc_body,um.doc_html,um.doc_gist,um.document_original_loc,image_caption,pricing_structure,
              um.is_global,um.date_created,um.expire_date,um.report_id,attribute1,attribute2,attribute3,attribute4,attribute5,attribute6,
              blueprint_obj
             from umo um
              where rowid = c1rec.rowid;
             update umo um
              set
               umo_scene_id = p3(k),
               um.extras.title = (select title from umo_scene usc where umo_scene_id = to_number(p3(k))),
               um.extras.orderby_scene = (select order_by from umo_scene usc where umo_scene_id = to_number(p3(k)))
             where
              umo_id = newid;
             audit_utility( newid,'UMO_SCENE_ID', p4(k),p3(k), 'ACCEPT_MOVE-COPY' );
             audit_utility( newid,'AID', acid,newcust, 'ACCEPT_MOVE-COPY' );
             insert into umo_index(umo_id,aid,attribute_id,position_id,word_original,word_upper,word_soundex,ordering)
              select newid,newcust,attribute_id,position_id,word_original,word_upper,word_soundex,ordering
              from umo_index
              where aid = acid and umo_id = c1rec.umo_id;
              if c1rec.umo_type = 'AUDIO'
                then
                myaudio.audio_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'COPY');
               elsif c1rec.umo_type = 'VIDEO'
                then
                myvideo.video_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'COPY');
               elsif c1rec.umo_type = 'RELATIONAL'
                then
                myrelational.relational_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'COPY');
               elsif c1rec.umo_type = 'BLUEPRINT'
                then
                myblueprint.blueprint_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'COPY');
               elsif c1rec.umo_type = 'DOCUMENT'
                then
                mydocument.document_api(v_umo=>c1rec.umo_id,new_acid=>newcust,old_acid=>acid,action=>'COPY');
              end if;
             insert into umo_attribute(umo_id,attribute_id,position_id,date_made,value)
              select newid,attribute_id,position_id,date_made,value
              from umo_attribute
              where umo_id = c1rec.umo_id;
            commit;
          end if;
         end if;
        end loop;

     end if;
    end loop;

   end if;
end loop;
commit;
phg_acct_master(surl,acid);
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_MOVE',owner_id,vaid=>acid,errmsg=>sqlerrm,extdet=>'SCENE:' || scene);
end accept_move;

procedure restore_from_backup( surl in varchar2,acid in integer, msg in varchar2 default null )
as
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_PREFS_THB', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_075,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P38',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;
  htp.nl;
  htp.p( '<CENTER>' );
  htp.header(3, LNG.PHG_TXT_054, 'CENTER' );
  htp.formopen( 'phg.accept_restore_from_backup' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.nl;
  htp.formtext( 'P1', 30, 30 );
  htp.nl;
  htp.formsubmit( null, LNG.PHG_TXT_075 );
 htp.formclose;
 htp.nl;
 htp.header(3, LNG.PHG_TXT_053, 'CENTER' );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'RESTORE_FROM_BACKUP',owner_id,vaid=>acid,errmsg=>sqlerrm);
end restore_from_backup;

procedure accept_restore_from_backup(surl in varchar2,acid in integer, p1 in varchar2 )
as
 cursor c1(acid integer) is select um.umo_id, um.extras.photo_name photo_name, umo_type from umo um where nvl(um.photo_backup.contentlength,0) > 0 and aid = acid order by umo_id;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		integer;
 foundrec	boolean;
 retval		varchar2(1000);
 pfx		THEME%ROWTYPE;
 parm1		ump.parameters;
 parm2		ump.parameters;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_PROF_SCENES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if (p1 = 'RESTORE')
  then
   null;
  else
   restore_from_backup(acid,LNG.PHG_TXT_057);
   return;
 end if;

 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG.PHG_TXT_056,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>')73',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 foundrec := FALSE;
 for c1rec in c1(acid) loop
  foundrec := TRUE;
  retval := NULL;
  parm1(1) := 'UMO_ID';
  parm2(1) := to_char(c1rec.umo_id);
  parm1(2) := 'AID';
  parm2(2) := to_char(acid);
  parm1(3) := 'OBJECT_TYPE';
  parm2(3) := c1rec.umo_type;
  parm1(4) := 'KEEP_STATUS';
  parm2(4) := 'KEEP';
  parm1(5) := 'RESTORE_PHOTO';
  parm2(5) := 'TRUE';
  ump.modify_uma(surl,parm1,parm2,retval);

  if retval is not null
   then
    glbx.header_msg( retval );
   else
    htp.bold( c1rec.photo_name );
    htp.nl;
  end if;
 end loop;
 if not foundrec
  then
    glbx.header_msg( LNG.PHG_TXT_058 );
 end if;
 htp.nl;
 htp.nl;
 htp.formopen( 'phg.phg_utlts_prefs' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'MSG', LNG.PHG_TXT_027 );
 htp.formsubmit( null, LNG.PHG_TXT_052 );
 htp.formclose;
 commit;
exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_RESTORE_FROM_BACKUP',errmsg=>sqlerrm,extdet=>'AID:' || acid || ' P1:' || p1);
end accept_restore_from_backup;

procedure phg_edit_link(surl in varchar2,acid in integer, v_umo in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer) is select um.extras.film_name film_name,um.version,um.umo_type from umo um where umo_id = v_umo;
 cursor c2(v_umo integer) is
  select to_umo_id,date_last_access,weighting,connections,sum_overtime,um.photo_thumbnail,um.version,um.extras.film_name film_name
  from umo_link ul, umo um
  where um.umo_id = v_umo and
        ul.umo_id = um.umo_id
  order by weighting desc;
 cursor c3(acid integer,owner_id integer) is select um.umo_id,um.extras.film_name film_name,um.umo_type from umo um where aid=acid and aid in (select aid from customer_account where pid=owner_id and aid=acid) order by um.extras.film_name;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_EDIT_LINK', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1(to_number(v_umo));
 fetch c1 into c1rec;
 close c1;

 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG2.PBK_TXT_069,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P39',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 theme_rec := get_theme_types( surl,acid );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2(
          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || v_umo || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
          '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(acid) || '&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
          '&parm1=RETURN_LINK&parm2=phg.phg_edit_link~surl=' || glbx.rndsurl(surl) || '!acid=' || acid || '!v_umo=' || v_umo,
          '<IMG BORDER=0 WIDTH=' || to_char(trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) /2))|| ' SRC="' ||
          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || v_umo || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c1rec.version) ||
          '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(acid) || '" ALT="' || c1rec.film_name || '" STYLE="display:block;">',ctarget=>'NEW_WINDOW' ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD>' );
   htp.bold( LNG2.PBK_TXT_068 );
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.GLB_TXT_064),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( htf.bold(LNG2.PBK_TXT_075),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( htf.bold(LNG2.PBK_TXT_074),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( htf.bold(LNG2.PBK_TXT_076),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( htf.bold(LNG2.PBK_TXT_077),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( htf.bold(LNG2.PBK_TXT_088),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tablerowclose;
    foundrec := FALSE;
    for c2rec in c2(to_number(v_umo)) loop
     foundrec := TRUE;
     htp.tablerowopen;
      htp.tabledata(htf.anchor2(
            'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.to_umo_id || '&parm1=DISPLAY_TYPE&parm2=IMAGENW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' || to_char(c2rec.version) ||
            '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid),
            '<IMG BORDER=0 WIDTH=' || to_char(c2rec.photo_thumbnail.width) || ' HEIGHT=' || to_char(c2rec.photo_thumbnail.height) || ' SRC="' ||
            'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.to_umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=VERSION&parm2=' || to_char(c2rec.version) ||
            '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(acid) ||
            '" ALT="' || c2rec.film_name || '" STYLE="display:block;">',
            ctarget=>'NEW_WINDOW')
                    ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( to_char(c2rec.date_last_access,LNG.MASK) || htf.nl || to_char(c2rec.date_last_access,LNG.TSMASK_ONLY),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( to_char(round(c2rec.weighting,2)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( to_char(c2rec.connections),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( to_char(round(c2rec.sum_overtime,2)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      htp.tabledata( htf.anchor( 'phg.link_control?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&action=DELETE&v_umo=' || v_umo || '&to_umo=' || c2rec.to_umo_id, LNG2.PBK_TXT_071) || htf.nl ||
                     htf.anchor( 'phg.link_control?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&action=RESET&v_umo=' || v_umo || '&to_umo=' || c2rec.to_umo_id, LNG2.PBK_TXT_072),
                     cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
    end loop;
   htp.tableclose;
   if not foundrec then htp.bold( LNG2.PBK_TXT_087 ); htp.nl; end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formopen( 'phg.link_control' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'ACTION', 'INSERT' );
  htp.formhidden( 'V_UMO', v_umo );
  htp.formhidden( 'TO_UMO', null );
  htp.formselectopen( 'TO_UMO', null, 5, cattributes=>'MULTIPLE' );
   for c3rec in c3(acid,owner_id) loop
    htp.formselectoption( c3rec.film_name || ' (' || initcap(c3rec.umo_type) || ')', cattributes=>'VALUE="' || c3rec.umo_id || '"' );
   end loop;
  htp.formselectclose;
  htp.formsubmit( null, LNG2.PBK_TXT_070 );
  htp.formclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_EDIT_LINK',errmsg=>sqlerrm,extdet=>'AID:' || acid || ' V_UMO:' || v_umo);
end phg_edit_link;

procedure link_control(surl in varchar2,acid in integer, v_umo in varchar2, to_umo in GLBX.MYARRAY, action in varchar2 )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 v_to_umo	integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.LINK_CONTROL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if action = 'DELETE'
  then
   delete from umo_link ul
    where
     umo_id = to_number(v_umo) and
     to_umo_id = to_number(to_umo(1)) and
     umo_id = (select umo_id from umo um where um.aid=acid and um.umo_id = ul.umo_id and um.aid=(select aid from customer_account ca where ca.aid=acid and ca.pid=owner_id));
 elsif action = 'RESET'
   then
    update umo_link ul
     set weighting = 0,
         connections = 0,
         sum_overtime = 0
     where
        umo_id = to_number(v_umo) and
        to_umo_id = to_number(to_umo(1)) and
        umo_id = (select umo_id from umo um where um.aid=acid and um.umo_id = ul.umo_id and um.aid=(select aid from customer_account ca where ca.aid=acid and ca.pid=owner_id));
 elsif action = 'INSERT'
    then
     for j in to_umo.first..to_umo.last loop
      if to_umo(j) is not null
       then
        v_to_umo := to_umo(j);
        insert into umo_link (umo_id,to_umo_id,date_last_access,weighting,connections,sum_overtime)
         select v_umo,v_to_umo,sysdate,0,0,0
          from dual where not exists(select 'x' from umo_link where umo_id = to_number(v_umo) and to_umo_id = to_number(v_to_umo));
      end if;
     end loop;
 end if;

 commit;

 phg_edit_link(surl,acid,v_umo,LNG2.PBK_TXT_089);

exception when others then
 glbx.error_details( 'PHG', 'LINK_CONTROL',errmsg=>sqlerrm,extdet=>'AID:' || acid || ' V_UMO:' || v_umo || ' TO_UMO:' || to_umo(1) || ' ACTION:' || action);
end link_control;

procedure completely_delete_account( phgid integer, acid in integer, action in varchar2 DEFAULT 'DISABLE' )
as

 cursor c2(acid integer) is select umo_id,umo_type from umo where aid = acid;
 cursor c3(phgid integer,acid integer) is select 'x' from customer_account where pid=phgid and aid=acid;
 cursor c4(v_umo integer) is select u.umo_id,u.aid,ua.attribute_id,ua.position_id,ua.value from umo_attribute ua, umo u where ua.umo_id = u.umo_id and u.umo_id = v_umo;

 tmp		char(1);

begin
 open c3(phgid,acid);
 fetch c3 into tmp;
 if c3%NOTFOUND
  then
   close c3; -- Someone specified an illegal Account Name
   return;
 end if;
 close c3;

 if action = 'DELETE'
  then
   for c2rec in c2(acid) loop
     delete from umo_index where umo_id = c2rec.umo_id;
     for c4rec in c4( c2rec.umo_id ) loop
             if c2rec.umo_type = 'AUDIO'
              then
               myaudio.audio_api(v_umo=>c2rec.umo_id,new_acid=>acid,old_acid=>null,action=>'DELETE');
             elsif c2rec.umo_type = 'VIDEO'
              then
               myvideo.video_api(v_umo=>c2rec.umo_id,new_acid=>acid,old_acid=>null,action=>'DELETE');
             elsif c2rec.umo_type = 'RELATIONAL'
              then
               myrelational.relational_api(v_umo=>c2rec.umo_id,new_acid=>acid,old_acid=>null,action=>'DELETE');
             elsif c2rec.umo_type = 'BLUEPRINT'
              then
               myblueprint.blueprint_api(v_umo=>c2rec.umo_id,new_acid=>acid,old_acid=>null,action=>'DELETE');
             elsif c2rec.umo_type = 'DOCUMENT'
              then
               mydocument.document_api(v_umo=>c2rec.umo_id,new_acid=>acid,old_acid=>null,action=>'DELETE');
             end if;
     end loop;
     delete from umo_attribute where umo_id = c2rec.umo_id;
     delete from log_photo_mod where phid = c2rec.umo_id;
     delete from log_umo_utility_modification where umo_id = c2rec.umo_id;
     delete from umo_link um where umo_id = c2rec.umo_id;
     delete from umo_link um where to_umo_id = c2rec.umo_id;
   end loop;
   commit;
   delete from umo where aid = acid and umo_type <> 'GALLERY';
   commit;

   delete from slide_details where sid in (select sid from slide_master where aid = acid );
   delete from slide_master where aid = acid;
   delete from ecard_log where eid in (select eid from ecard where aid = acid);
   delete from ecard where aid = acid;
   delete from photographer_preference where aid = acid;
   delete from audit_customer_password where aid = acid;
   delete from audit_profile_password where profile_id in (select profile_id from customer_profile where aid = acid);
   delete from customer_price_book where aid = acid and ltype in ('OWNER','CUSTOMER');
   delete from customer_price_book where ltype in ('PROFILE','PROFILEG') and aid in (select profile_id from customer_profile where aid = acid);
   delete from customer_profile where aid = acid;
   delete from price_book_map where aid = acid;
   delete from advanced_search where aid = acid and login_type in ('OWNER','CUSTOMER');
   delete from error_trap where aid = acid;
   delete from grab_email where aid = acid;
   delete from main_value_customer where aid = acid;
   delete from track_email where aid = acid;
   delete from upl_master where aid = acid;
   delete from phg_batch_upload where aid = acid;

   delete from ALBUM  where aid = acid;
   delete from ANNIVERSARY  where aid = acid and login_type in ('OWNER','CUSTOMER');
   delete from AUDIT_BOOKING  where aid = acid;
   delete from CALENDAR_MAP  where aid = acid;
   delete from CHAT  where aid = acid;
   delete from CUSTOMER_CALENDAR  where aid = acid;
   delete from CUSTOMER_CONTACT  where aid = acid and login_type in ('OWNER','CUSTOMER');
   delete from CUSTOMER_META_DATA  where aid = acid;
   delete from CUSTOMER_META_DATA_GROUP  where aid = acid;
   delete from CUSTOMER_REMINDER_DATES  where aid = acid;
   delete from CUSTOMER_ROLES  where aid = acid;
   delete from CUSTOMER_SAVED_PREFERENCE  where aid = acid and login_type in ('OWNER','CUSTOMER');
   delete from GENERIC_REGISTRATION  where aid = acid;
   delete from GENERIC_REGISTRATION_COLUMNS  where aid = acid;
   delete from GIFT_CERTIFICATE  where aid = acid;
   delete from GIFT_CERTIFICATE_USAGE  where aid = acid;
   delete from HOME_NEWS  where aid = acid;
   delete from LIGHTBOX_HEADER  where aid = acid and login_type in ('OWNER','CUSTOMER');
   delete from LOAD_LOG  where aid = acid;
   delete from LOG_PHOTO_MOD  where aid = acid;
   delete from MANUFACTURER_SEARCH  where aid = acid and login_type in ('OWNER','CUSTOMER');
   delete from META_TAG_QUERY  where aid = acid and login_type in ('OWNER','CUSTOMER');
   delete from NOVELTY_CUSTOMER  where aid = acid;
   delete from ONLINE_POLL_QUESTION  where aid = acid;
   delete from PHOTOGRAPHER_ICON_STATS  where aid = acid;
   delete from PRICE_BOOK_CATEGORY  where aid = acid;
   delete from QUIZ  where aid = acid;
   delete from REPORT_QUEUE  where aid = acid;
   delete from RESOURCES  where aid = acid;
   delete from REVERSE_BID  where aid = acid;
   delete from RFQ_PREFILLED_ORDER  where aid = acid and login_type in ('OWNER','CUSTOMER');
   delete from STATES  where aid = acid;
   delete from TENDER  where aid = acid;
   delete from USERDEFINED_QUERY  where aid = acid;
   delete from VIRTUAL_LOGON  where aid = acid;

   delete from customer_account where aid = acid;
   commit;

 elsif action in ('ENABLE','DISABLE')
  then
   for c2rec in c2(acid) loop
     update umo_index set aid = (aid * -1) where umo_id = c2rec.umo_id;
     update log_photo_mod set aid = (aid * -1) where phid = c2rec.umo_id;
             if c2rec.umo_type = 'AUDIO'
              then
               myaudio.audio_api(v_umo=>c2rec.umo_id,new_acid=>(acid * -1),old_acid=>acid,action=>'MOVE');
             elsif c2rec.umo_type = 'VIDEO'
              then
               myvideo.video_api(v_umo=>c2rec.umo_id,new_acid=>(acid * -1),old_acid=>acid,action=>'MOVE');
             elsif c2rec.umo_type = 'RELATIONAL'
              then
               myrelational.relational_api(v_umo=>c2rec.umo_id,new_acid=>(acid * -1),old_acid=>acid,action=>'MOVE');
             elsif c2rec.umo_type = 'BLUEPRINT'
              then
               myblueprint.blueprint_api(v_umo=>c2rec.umo_id,new_acid=>(acid * -1),old_acid=>acid,action=>'MOVE');
             elsif c2rec.umo_type = 'DOCUMENT'
              then
               mydocument.document_api(v_umo=>c2rec.umo_id,new_acid=>(acid * -1),old_acid=>acid,action=>'MOVE');
             end if;
   end loop;
   commit;
   update umo set aid = (aid * -1) where aid = acid and umo_type <> 'GALLERY';
   commit;
   update slide_master set aid = (aid * -1) where aid = acid;
   update ecard set aid = (aid * -1) where aid = acid;
   update photographer_preference set aid = (aid * -1) where aid = acid;
   update audit_customer_password set aid = (aid * -1) where aid = acid;
   update customer_profile set aid = (aid * -1) where aid = acid;
   update price_book_map set aid = (aid * -1) where aid = acid;
   update advanced_search set aid = (aid * -1) where aid = acid and login_type in ('OWNER','CUSTOMER');
   update customer_price_book set aid = (aid * -1) where aid = acid;
   update error_trap set aid = (aid * -1) where aid = acid;
   update grab_email set aid = (aid * -1) where aid = acid;
   update main_value_customer set aid = (aid * -1) where aid = acid;
   update track_email set aid = (aid * -1) where aid = acid;
   update upl_master set aid = (aid * -1) where aid = acid;

   update ALBUM set aid = (aid * -1) where aid = acid;
   update ANNIVERSARY set aid = (aid * -1) where aid = acid and login_type in ('OWNER','CUSTOMER');
   update AUDIT_BOOKING set aid = (aid * -1) where aid = acid;
   update CALENDAR_MAP set aid = (aid * -1) where aid = acid;
   update CHAT set aid = (aid * -1) where aid = acid;
   update CUSTOMER_CALENDAR set aid = (aid * -1) where aid = acid;
   update CUSTOMER_CONTACT set aid = (aid * -1) where aid = acid and login_type in ('OWNER','CUSTOMER');
   update CUSTOMER_META_DATA set aid = (aid * -1) where aid = acid;
   update CUSTOMER_META_DATA_GROUP set aid = (aid * -1) where aid = acid;
   update CUSTOMER_REMINDER_DATES set aid = (aid * -1) where aid = acid;
   update CUSTOMER_ROLES set aid = (aid * -1) where aid = acid;
   update CUSTOMER_SAVED_PREFERENCE set aid = (aid * -1) where aid = acid and login_type in ('OWNER','CUSTOMER');
   update GENERIC_REGISTRATION set aid = (aid * -1) where aid = acid;
   update GENERIC_REGISTRATION_COLUMNS set aid = (aid * -1) where aid = acid;
   update GIFT_CERTIFICATE set aid = (aid * -1) where aid = acid;
   update GIFT_CERTIFICATE_USAGE set aid = (aid * -1) where aid = acid;
   update HOME_NEWS set aid = (aid * -1) where aid = acid;
   update LIGHTBOX_HEADER set aid = (aid * -1) where aid = acid and login_type in ('OWNER','CUSTOMER');
   update LOAD_LOG set aid = (aid * -1) where aid = acid;
   update LOG_PHOTO_MOD set aid = (aid * -1) where aid = acid;
   update MANUFACTURER_SEARCH set aid = (aid * -1) where aid = acid and login_type in ('OWNER','CUSTOMER');
   update META_TAG_QUERY set aid = (aid * -1) where aid = acid and login_type in ('OWNER','CUSTOMER');
   update NOVELTY_CUSTOMER set aid = (aid * -1) where aid = acid;
   update ONLINE_POLL_QUESTION set aid = (aid * -1) where aid = acid;
   update PHOTOGRAPHER_ICON_STATS set aid = (aid * -1) where aid = acid;
   update PRICE_BOOK_CATEGORY set aid = (aid * -1) where aid = acid;
   update QUIZ set aid = (aid * -1) where aid = acid;
   update REPORT_QUEUE set aid = (aid * -1) where aid = acid;
   update RESOURCES set aid = (aid * -1) where aid = acid;
   update REVERSE_BID set aid = (aid * -1) where aid = acid;
   update RFQ_PREFILLED_ORDER set aid = (aid * -1) where aid = acid and login_type in ('OWNER','CUSTOMER');
   update STATES set aid = (aid * -1) where aid = acid;
   update TENDER set aid = (aid * -1) where aid = acid;
   update USERDEFINED_QUERY set aid = (aid * -1) where aid = acid;
   update VIRTUAL_LOGON set aid = (aid * -1) where aid = acid;

   update phg_batch_upload set aid = (aid * -1) where aid = acid;
   if acid < 0
    then
     update customer_account set date_to_delete = null where aid = acid;
    else
     update customer_account set date_to_delete = sysdate + 7 where aid = acid;
   end if;
   update customer_account set aid = (aid * -1) where aid = acid;
   commit;
 end if;

exception when others then
 glbx.error_details( 'PHG', 'COMPLETELY_DELETE_ACCOUNT',vaid=>acid,errmsg=>sqlerrm);
end completely_delete_account;

procedure delete_account( surl in varchar2, acid in integer, action in varchar2 )
as
 cursor c2(acid integer) is select umo_id from umo where aid = acid;
 cursor c3(phgid integer,acid integer) is select 'x' from customer_account where pid=phgid and aid=acid;

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 tmp		char(1);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.DELETE_ACCOUNT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if action = LNG.GLB_BUT_041
  then
   phg.phg_acct_master(surl,acid, LNG.GLB_TXT_021);
   return;
 end if;
 open c3(owner_id,acid);
 fetch c3 into tmp;
 if c3%NOTFOUND
  then
   close c3; -- Someone specified an illegal Account Name
   return;
 end if;
 close c3;

 completely_delete_account(owner_id,acid,'DISABLE');

 phg.phg_accts(surl,to_char(sysdate,'SSSSS'));

exception when others then
 glbx.error_details( 'PHG', 'DELETE_ACCOUNT',vaid=>acid,errmsg=>sqlerrm,extdet=>'ACTION:' || action);
end delete_account;

procedure cust_roles( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c1( acid integer ) is select cr.aid, cr.role_id, pr.role_type, pr.role_name, pr.parameter_name, pr.parameter_value from customer_roles cr, piction_roles pr where cr.role_id = pr.role_id and cr.aid = acid;
 cursor c2( rid integer ) is select * from piction_roles_rules where role_id = rid;
 cursor c3 is select role_id,role_name,role_type from piction_roles order by role_name;

 c1rec		c1%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.CUST_ROLES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG2.FNM_TXT_165,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P43',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 theme_rec := get_theme_types( surl,acid );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.formopen( 'phg.accept_cust_roles' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG3.ADM_TXT_916),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(LNG3.ADM_TXT_917),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(LNG2.FNM_TXT_166),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 for c1rec in c1(acid) loop
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'P1' );
   htp.formselectoption( NULL );
   for c3rec in c3 loop
    if c3rec.role_id = c1rec.role_id
     then
      htp.formselectoption( c3rec.role_name || ' (' || c3rec.role_type || ')', 'SELECTED', cattributes=>'VALUE="' || c3rec.role_id || '"' );
     else
      htp.formselectoption( c3rec.role_name || ' (' || c3rec.role_type || ')', cattributes=>'VALUE="' || c3rec.role_id || '"' );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( c1rec.role_type,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
   if c1rec.role_type = 'PARAMETER'
    then
      htp.bold( c1rec.parameter_name );
      htp.nl;
      htp.p( c1rec.parameter_value );
    else
     for c2rec in c2( c1rec.role_id ) loop
      if c2%ROWCOUNT > 1 then htp.nl; end if;
      htp.bold( c2rec.restriction_type );
      htp.nl;
      htp.bold( c2rec.table_owner || '.' || c2rec.table_name );
      htp.nl;
      if c2rec.restriction_type = 'RESTRICT'
       then
        htp.p( c2rec.where_clause );
      elsif c2rec.restriction_type = 'COLUMN'
       then
        htp.p( c2rec.if_column || ' ' || c2rec.if_expression || ' ' || c2rec.if_value || ' (' || c2rec.if_value_type || ') ' || c2rec.if_action );
      end if;
     end loop;
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 for j in 1..5 loop
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
   htp.formselectopen( 'P1' );
   htp.formselectoption( NULL );
   for c3rec in c3 loop
    htp.formselectoption( c3rec.role_name || ' (' || c3rec.role_type || ')', cattributes=>'VALUE="' || c3rec.role_id || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tabledata( '&nbsp;' ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tabledata( '&nbsp;' ,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG2.FNM_TXT_165 );
 htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PHG', 'CUST_ROLES',vaid=>acid,errmsg=>sqlerrm,extdet=>NULL );
end cust_roles;

procedure accept_cust_roles( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY )
as

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 nmb		number;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_CUST_ROLES', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 delete from customer_roles where aid = (select aid from customer_account where pid = owner_id and aid = acid );
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    insert into customer_roles(aid,role_id) values (acid,p1(j));
  end if;
 end loop;
 commit;
 cust_roles( surl, acid, LNG2.FNM_TXT_167 );

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_CUST_ROLES', vaid=>acid, errmsg=>sqlerrm, extdet=>NULL);
end accept_cust_roles;

procedure phg_statall(surl in varchar2, msg in varchar2 default null)
as

 cursor c1( phgid integer ) is select aid,account_name,date_created from customer_account where pid = phgid order by account_name;
 cursor c2( acid integer ) is select sum(call_ctr) call_ctr,count(call_ctr) cnt_call from login_session where aid = acid;
 cursor c3( phgid integer) is
  select /*+ ALL_ROWS */ count(call_ctr) cc,
         sum(call_ctr) sc,
         round(avg(call_ctr),2) ac,
         sum(decode(screen_type,'1',1,0)) s1,
         sum(decode(screen_type,'2',1,0)) s2,
         sum(decode(screen_type,'3',1,0)) s3,
         sum(decode(screen_type,'4',1,0)) s4,
         sum(decode(screen_type,'5',1,0)) s5,
         sum(decode(screen_type,'6',1,0)) s6,
	 sum(decode(login_type,'OWNER',1,0)) lo,
	 sum(decode(login_type,'CUSTOMER',1,0)) lc
  from login_session ls, customer_account ca
  where ls.aid = ca.aid and
        ca.pid = phgid;
 cursor c4( phgid integer ) is
  select to_char(ls.date_created,'HH24') hr, count('x') ctr
  from login_session ls, customer_account ca
  where ca.aid = ls.aid and
        ca.pid = phgid and
        login_type in ('OWNER','CUSTOMER')
  group by to_char(ls.date_created,'HH24');

 cursor c5( phgid integer) is
  select nvl(os,' ') os,browser_type,browser_version,count('x') tot
  from login_session ls, customer_account ca
  where ca.aid = ls.aid and
        ca.pid = phgid
  group by nvl(os,' '),browser_type,browser_version;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 v_quota	ump.quotalist;
 pfx		theme%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.PHG_STATALL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.photo_lf(owner_id);
 --glbx.main_title(surl, LNG4.AHC_TXT_117,helpid=>'P44',stype=>stype,sstyle=>'Arial',sclr=>'000000',det_sclr=>'000F00',det_sstyle=>'Verdana');
 glbx.main_title( surl, LNG4.AHC_TXT_117,null,helpid=>'P44',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_164 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG.GLB_TXT_078 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' );
     htp.tabledata( LNG3.ADM_TXT_490 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' ); -- # images
     htp.tabledata( LNG3.ADM_TXT_479 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' ); -- # image size
     htp.tabledata( LNG.PHG_TXT_314 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' ); -- # logins
     htp.tabledata( LNG.PHG_TXT_315 ,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' ); -- # calls
     htp.tabledata( LNG.PHG_TXT_316,cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"' ); -- # calls
  htp.tablerowclose;
  for c1rec in c1(owner_id) loop
   htp.tablerowopen;
    htp.tabledata( c1rec.account_name, cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c1rec.date_created,LNG.MASK), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    ump.get_quota( surl,'PHOTOGRAPHER', owner_id, null, c1rec.aid, v_quota);
    htp.tabledata( to_char(v_quota.total_asset), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="RIGHT"' );
    htp.tabledata( to_char(round((v_quota.total_used/1024)/1024,2),glbx.MB_MASK) || ' Mb', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="RIGHT"' );
    open c2( c1rec.aid );
    fetch c2 into c2rec;
    close c2;
    htp.tabledata( to_char(nvl(c2rec.cnt_call,0)), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="RIGHT"' );
    htp.tabledata( to_char(nvl(c2rec.call_ctr,0)), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="RIGHT"' );
    if nvl(c2rec.cnt_call,0) = 0
     then
      htp.tabledata( '0', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="RIGHT"' );
     else
      htp.tabledata( to_char(round(nvl(c2rec.call_ctr,0)/c2rec.cnt_call,2)), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="RIGHT"' );
    end if;
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  open c3( owner_id );
  fetch c3 into c3rec;
  close c3;
  htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_279) );
     htp.tabledata( htf.bold(LNG.PHG_TXT_314) );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_322),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(nvl(c3rec.lc,0) + nvl(c3rec.lo,0)),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 800 x 600'),cattributes=>pfx.qbground || ' ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(c3rec.s1),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 1024 x 768'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c3rec.s2),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 1280 x 1024'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c3rec.s3),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 1400 x 1050'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c3rec.s4),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': 1600 x 1200'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c3rec.s5),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.italic(LNG.PHG_TXT_317 || ': > 1600 x 1200'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c3rec.s6),cattributes=>pfx.qcbground );
    htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.PHG_TXT_276) );
     htp.tabledata( htf.bold(LNG.PHG_TXT_314) );
    htp.tablerowclose;
    for c5rec in c5( owner_id ) loop
    htp.tablerowopen;
      htp.tabledata( htf.italic(c5rec.os || '-' || c5rec.browser_type || '(' || c5rec.browser_version || ')'),cattributes=>pfx.qbground  || ' ALIGN="RIGHT"');
      htp.tabledata( htf.bold(c5rec.tot),cattributes=>pfx.qcbground );
    htp.tablerowclose;
    end loop;
  htp.tableclose;
  htp.nl;
  htp.bold( LNG5.EXT_TXT_001 );
  htp.nl;
  htp.tableopen(cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_319) );
   htp.tabledata( htf.bold(LNG.PHG_TXT_322) );
  htp.tablerowclose;
  for c4rec in c4(owner_id) loop
    htp.tablerowopen;
      htp.tabledata( htf.bold( c4rec.hr),cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
      htp.tabledata( htf.bold( c4rec.ctr),cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'PHG_STATALL', vaid=>null, errmsg=>sqlerrm, extdet=>NULL);
end phg_statall;

procedure map_store(surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c1(acid integer, void integer) is
  select ppit.ppi ,ppit.name,ppit.phg_code
  from phg_price_item ppit, order_style os
  where os.spb = ppit.spb and
        os.oid = void and
        shop_style = LNG4.AHC_TXT_077 and
        shop_item = 'T';

 cursor c2(phgid integer, acid integer) is
 	 select order_by,title,umo_scene_id,parent_scene
	 from umo_scene usc, customer_account ca
	 where category = ca.scene_name and
	       ca.aid = acid and
	       ((owned_by = 'PUBLIC') or ((owned_by = 'PHOTOGRAPHER') and (owner_id = phgid)))
	 order by order_by;

 cursor c3(acid integer, uscid integer, vppit integer) is select 'x' tot from price_book_category where aid = acid and umo_scene_id = uscid and ppi = vppit;

 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 void		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 b2c_value	char(1);
 --tmp		varchar2(4000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.MAP_STORE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, LNG4.AHC_TXT_079,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P45',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg ); end if;

 htp.p( '<CENTER>' );
 htp.nl;
 htp.formopen( 'phg.accept_map_store' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG2.PBK_TXT_021 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tabledata( htf.bold( LNG4.AHC_TXT_080 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
 htp.tablerowclose;
 void := glbx.get_order_style( acid, null, ltype, b2c_value );
 for c1rec in c1(acid,void) loop
  htp.tablerowopen;
   htp.tabledata( htf.bold( c1rec.name || '(' || c1rec.phg_code || ')' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P1', null, 2, cattributes=>'MULTIPLE' );
     htp.formselectoption( NULL );
     for c2rec in c2( owner_id, acid ) loop
      open c3(acid, c2rec.umo_scene_id, c1rec.ppi );
      fetch c3 into c3rec;
      if c3%FOUND
       then
        close c3;
        htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, 'SELECTED', cattributes=>'VALUE="' || '[' || c1rec.ppi || ']' || c2rec.umo_scene_id || '"' );
       else
        close c3;
        htp.formselectoption( lpad(pfx.nested_scene_delim, indnt(c2rec.parent_scene),pfx.nested_scene_delim) || c2rec.title, cattributes=>'VALUE="' || '[' || c1rec.ppi || ']' || c2rec.umo_scene_id || '"' );
      end if;
     end loop;
     htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG4.AHC_TXT_081 );
 htp.formclose;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'MAP_STORE',owner_id,acid,errmsg=>sqlerrm,extdet=>msg);
end map_store;

procedure accept_map_store( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY )
as

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 nmb		number;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_MAP_STORE', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 delete from price_book_category where aid = acid;
 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    insert into price_book_category(aid,umo_scene_id,ppi) values (acid,to_number(substr(p1(j),instr(p1(j),']')+1)),to_number(substr(p1(j),2,instr(p1(j),']')-2) ));
  end if;
 end loop;
 commit;
 map_store( surl, acid, LNG4.AHC_TXT_082 );

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_MAP_STORE', vaid=>acid, errmsg=>sqlerrm, extdet=>NULL);
end accept_map_store;

procedure accept_fast_meta(surl in varchar2, acid in integer, mctr in integer, a3 in varchar2, rot in varchar2, mwidth in integer default 1, newwin in varchar2, typ in varchar2, typval in varchar2,
                           p11 in varchar2, p11a in varchar2, p11b in varchar2, a0 in MYARRAY, tag_umo in MYARRAY, tag_id in MYARRAY, tag_name in glbx.myarray, tag_value in MYARRAY )
as

 cursor c1(v_umo integer) is select um.extras.film_name fname,umo_type from umo um where umo_id = v_umo;
 cursor c3(acid integer, phgid integer) is select scene_name,background_img,theme_type from customer_account where aid=acid and pid = phgid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 res		boolean;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 nmb		number;
 ntag		GLBX.MYARRAY;
 nval		GLBX.MYARRAY;
 nname		GLBX.MYARRAY;
 reterrors	GLBX.MYARRAY;
 errtxt		GLBX.MYARRAY;
 errctr		integer;
 reterrors_ctr	integer;
 last_umo	integer;
 ctr		integer;
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_FAST_META', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c3(acid,owner_id);
 fetch c3 into c3rec;
 close c3;
 pfx := glbx.get_thm( acid );
 last_umo := 0;
 ctr := 0;
 errctr := 0;
 for j in tag_umo.first..tag_umo.last loop
  if last_umo <> tag_umo(j) and last_umo <> 0
   then
    open c1(last_umo);
    fetch c1 into c1rec;
    close c1;
    res := glbx.update_meta_data( surl, last_umo, acid, c1rec.umo_type, ltype, ntag, nname, nval, reterrors, reterrors_ctr);
    if reterrors_ctr > 0
     then
      for k in reterrors.first..reterrors.last loop
       errctr := errctr + 1;
       errtxt(errctr) := c1rec.fname || '-' || reterrors(k);
      end loop;
    end if;
    ntag.delete;
    nval.delete;
    nname.delete;
    reterrors.delete;
    reterrors_ctr := 0;
    ctr := 0;
    last_umo := tag_umo(j);
  elsif last_umo = 0
   then
    last_umo := tag_umo(j);
  end if;
  ctr := ctr + 1;
  ntag(ctr) := tag_id(j);
  nval(ctr) := tag_value(j);
  nname(ctr) := tag_name(j);
 end loop;

 open c1(last_umo);
 fetch c1 into c1rec;
 close c1;
 res := glbx.update_meta_data( surl, last_umo, acid, c1rec.umo_type, ltype, ntag, nname, nval, reterrors, reterrors_ctr);
 if reterrors_ctr > 0
  then
    for k in reterrors.first..reterrors.last loop
     errctr := errctr + 1;
     errtxt(errctr) := c1rec.fname || '-' || reterrors(k);
    end loop;
 end if;

 -- if errors then display them and then prompt to go back to the meta data page, else go to the meta data page
 if errctr > 0
  then
   glbx.main_title( surl, LNG3.ADM_TXT_091,glbx.backimg(surl,acid,pfx.text_back,c3rec.background_img,ltype),helpid=>'P74',stype=>greatest(stype-4,1),sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   htp.nl;
   for j in errtxt.first..errtxt.last loop
    htp.p( errtxt(j) );
    htp.nl;
   end loop;
   htp.nl;
   htp.nl;
   if newwin = LNG.PHG_TXT_045
    then
     htp.anchor( 'phg.photo_fast_edit_acct?surl=' || surl || '&acid=' || acid || '&mctr=' || mctr || '&mwidth=' || mwidth || '&typ=' || replace(typ,' ','+') || '&typval=' || replace(typval,' ','+') || '&newwin=' || newwin, LNG.CST_BUT_129 );
    else
     htp.anchor( 'phg.photo_fast_edit_acct_mst?surl=' || surl || '&acid=' || acid || '&mctr=' || mctr || '&mwidth=' || mwidth || '&typ=' || replace(typ,' ','+') || '&typval=' || replace(typval,' ','+') || '&stype=' || stype, LNG.CST_BUT_129 );
   end if;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 if newwin = LNG.PHG_TXT_045
  then
   photo_fast_edit_acct( surl, acid, mctr, mwidth, typ, typval, newwin );
  else
   photo_fast_edit_acct_mst( surl, acid, mwidth, typ, typval, mctr,stype=>stype );
 end if;

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_FAST_META', vaid=>acid, errmsg=>sqlerrm, extdet=>'MCTR:' || mctr || ' MWIDTH:' || mwidth);
end accept_fast_meta;

procedure meta_img_load( surl in varchar2, acid in integer, stype  in integer, ltype in varchar2, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, target in char, v_umo in integer default null )
as

 button_found	boolean;
 defval		glbx.myarray;

begin
 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'phg.meta_tload', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 htp.formhidden( 'P3', NULL );

 button_found := FALSE;
 glbx.meta_prompt( surl, acid=>acid, ltype=>ltype, tgroup=>target, v_umo=>NULL, button_found=>button_found, default_names=>defval, default_values=>defval );

 if not button_found
  then
   if target = 'I'
    then
     htp.formsubmit( 'ACTION', 'Upload Data' );
   elsif target = 'P'
    then
     htp.formsubmit( 'ACTION', 'Modify Meta Data' );
   end if;
 end if;

 htp.formclose;
 htp.p( '<CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'META_IMG_LOAD', vaid=>acid, errmsg=>sqlerrm);
end meta_img_load;

procedure meta_tload(surl in varchar2, acid in integer, file in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, v_umo in integer default null, action in varchar2 default null )
as

 cursor c1(phgr integer) is
  select max_photo_size * 1024
  from charge_plan cp, photographer ph
  where ph.pid = phgr and
        ph.plan_id = cp.id;

 cursor c2(phgid integer,acid integer) is select * from customer_account where aid = acid and pid = phgid;
 cursor c3(attid integer) is select * from umo_attributes where attribute_id = attid;
 cursor c6(acid integer, trg char) is select count('x') tot from customer_meta_data_group where aid = acid and target_area = trg;

 cusrec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 sts		varchar2(100);
 maxphoto	integer;
 ctr		integer;
 new_id		integer;
 x		integer;
 profid		integer;
 parm1		ump.parameters;
 parm2		ump.parameters;
 tag_id		GLBX.MYARRAY;
 tag_name	GLBX.MYARRAY;
 tag_value	GLBX.MYARRAY;
 reterrors	GLBX.MYARRAY;
 reterrors_ctr	integer;
 retval		varchar2(1000);
 new_photos	LISTINT;
 pfx		THEME%ROWTYPE;
 newid_arr	ump.myarray_int;
 theme_rec	theme_types%ROWTYPE;
 foundrec	boolean;
 otype		varchar2(100);

 function findval( p3 in GLBX.MYARRAY, attribid integer )
  return varchar2
 as
 begin
  for j in p3.first..p3.last loop
   if substr(p3(j),1,1) = '['
    then
     if to_number(substr(p3(j),2,instr(p3(j),']')-2)) = attribid
      then
       return( substr(p3(j),instr(p3(j),']')+1));
     end if;
   end if;
  end loop;
  return( NULL );
 end findval;

begin
 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'PHG.META_TLOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 cusrec := glbx.get_cusrec( sess_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := get_theme_types( surl, acid );

 open c1(cusrec.pid);
 fetch c1 into maxphoto;
 close c1;

/*
htp.bold('P1:' ); htp.nl;
 for j in p1.first..p1.last loop
  htp.p( j || ':' || p1(j) || '-' || p2(j) ); htp.nl;
 end loop;
 htp.nl;
htp.bold('P3:' ); htp.nl;
 for j in p3.first..p3.last loop
  htp.p( j || ':' || p3(j) ); htp.nl;
 end loop;

 if file is null
  then
   htp.bold( 'File is null' );
   return;
 end if;
*/

 -- Upload File
 if file is not null
  then
   parm1(1)  := 'AID';
   parm2(1)  := to_char(cusrec.aid);
   parm1(2)  := 'LOAD_FROM_FILE_OR_UPLOAD';
   parm2(2)  := 'UPLOAD';
   parm1(3) := 'THUMBNAIL_WIDTH';
   parm2(3) := nvl(glbx.photo_pref(cusrec.pid,cusrec.aid,'THUMBNAIL_WIDTH'),'100');
   parm1(4) := 'KEEP_STATUS';
   parm2(4) := 'KEEP';
   parm1(5) := 'ORIGINAL_LOCATION';
   parm2(5) := file;
   parm1(6)  := 'CREATE_THUMBNAIL';
   parm2(6)  := 'TRUE';
   parm1(7) := 'PHOTOGRAPHER';
   parm2(7) := 'TRUE';
   parm1(8) := 'NAME';
   parm2(8) := file;
   parm1(9) := 'PHOTO ALBUM';
   parm2(9) := 'FALSE';
   parm1(10) := 'BRIDAL';
   parm2(10) := 'TRUE';
   parm1(11) := 'QUALITY';
   parm2(11) := 'STANDARD';
   parm1(12) := 'UMO_OWNER';
   parm2(12) := ltype;
   parm1(13) := 'BYPASS_QUOTA_CHECK';
   parm2(13) := 'FALSE';
   parm1(14) := 'PHGR_ID';
   parm2(14) := to_char(cusrec.pid);
   parm1(15) := 'OWS_NAME';
   parm2(15) := file;
   parm1(16) := 'FILM_NAME';
   parm2(16) := glbx.extract_fname(file,'NO_EXTENSION',100);
   parm1(17) := 'PHOTOGRAPHER_QUOTA';
   parm2(17) := to_char(maxphoto);
   parm1(18) := 'NEG_NO';
   parm2(18) := '1';
   ctr := 19;

   for j in p1.first..p1.last loop
     if p1(j) = '-5'
      then
       parm1(ctr) := 'SCENE_ID';
       parm2(ctr) := p2(j);
       ctr := ctr + 1;

     elsif p1(j) = '-6'
      then
       parm1(ctr) := 'COMPRESSION';
       parm2(ctr) := p2(j);
       ctr := ctr + 1;

     elsif p1(j) = '-7'
      then
       parm1(ctr) := 'OBJECT_TYPE';
       parm2(ctr) := p2(j);
       ctr := ctr + 1;

     end if;
   end loop;

  retval := NULL;
  /*
  for j in parm1.first..parm1.last loop
   htp.p( 'PARM1:' || j || '-' || parm1(j) || '-' || parm2(j)); htp.nl;
  end loop;
  */
  ump.load_uma(surl,parm1,parm2,retval,newid_arr); new_id := newid_arr(1);
  if retval is not null
   then
    htp.bold( 'Bad Load:' || retval );
    return;
  end if;
 end if;

 -- Update Meta Data
 foundrec := FALSE;
 ctr := 1;
 for j in p1.first..p1.last loop
   if to_number(p1(j)) > 0
    then
      foundrec := TRUE;
      tag_id(ctr) := p1(j);
      tag_name(ctr) := NULL;
      tag_value(ctr) := p2(j);
      ctr := ctr + 1;

    elsif p1(j) = '-5'
     then
      tag_id(ctr) := p1(j);
      tag_name(ctr) := 'SCENE_ID';
      tag_value(ctr) := p2(j);
      ctr := ctr + 1;

    end if;
 end loop;

 if otype is null
  then
   otype := 'PHOTO';
 end if;

 if foundrec
  then
   foundrec := glbx.update_meta_data( surl, nvl(new_id,v_umo), cusrec.aid, otype, ltype, tag_id, tag_name, tag_value, reterrors, reterrors_ctr);
   if reterrors_ctr > 0
    then
     htp.bold( 'Bad Load:' || reterrors(1) );
     return;
   end if;
 end if;


 -- Update Meta Data Checkbox Values. Multiple values can be entered for a checkbox or a multivalue list
 -- All the checkbox values are initially displayed using curly braces. Values picked are in square brackets.
 tag_id.delete;
 tag_name.delete;
 tag_value.delete;
 ctr := 1;
 for j in p3.first..p3.last loop
  if substr(p3(j),1,1) = '{'
   then
     foundrec := TRUE;
     x := to_number(substr(p3(j),2,instr(p3(j),'}')-2));
     open c3(x);
     fetch c3 into c3rec;
     close c3;
     if c3rec.edit_type = 'Boolean'
      then
       tag_id(ctr) := to_char(x);
       tag_name(ctr) := NULL;
       tag_value(ctr) := '[' || to_char(x) || ']' || nvl(findval(p3,x),substr(p3(j),instr(p3(j),'}')+1));
       foundrec := glbx.update_meta_data( surl, nvl(new_id,v_umo), cusrec.aid, otype, ltype, tag_id, tag_name, tag_value, reterrors, reterrors_ctr);
       tag_id.delete;
       tag_name.delete;
       tag_value.delete;
       ctr := 1;
      /*
      else
       if findval(p3,x) is not null
      */
     end if;
  end if;
 end loop;

 htp.bold( 'Loaded:' || new_id );
 -- Check if post load
 open c6(acid, 'P');
 fetch c6 into c6rec;
 close c6;
 if c6rec.tot > 0
  then
   glbx.main_title(surl, LNG.PHG_TXT_183,glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'P11',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   meta_img_load( surl, cusrec.aid, stype, ltype, cusrec, pfx, theme_rec, 'P', nvl(new_id,v_umo) );
   return;
  else
   new_photos( 1 ) := nvl(new_id,v_umo);
   disp_new_photos( surl, cusrec.aid, new_photos );
 end if;

exception when others then
 glbx.error_details( 'PHG', 'META_TLOAD', vaid=>acid, errmsg=>sqlerrm);
end meta_tload;

procedure novelty_access( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c1( acid integer ) is
  select count('x') tot
  from  novelty_customer nc
  where aid = acid;

 cursor c2( acid integer, nvid integer ) is
  select 'x' exst
  from  novelty_customer nc
  where nc.aid = acid and
        nc.novelty_id = nvid;

 cursor c3( acid integer ) is
  select display_name,call_type,program_name,first_parameter, nd.novelty_id, display_suffix
  from  novelty_definition nd, novelty_set ns, charge_plan cp, photographer p, customer_account ca
  where nd.novelty_id = ns.novelty_id and
        ns.novelty_set_id = cp.novelty_set_id and
        cp.id = p.plan_id and
        p.pid = ca.pid and
        ca.aid = acid
  order by nd.order_by,display_name;

 cursor c4(acid integer) is select * from customer_account where aid = acid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.NOVELTY_ACCESS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, LNG2.FNM_TXT_165,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P71',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 theme_rec := get_theme_types( surl,acid );
 if msg is not null then glbx.header_msg( msg ); end if;
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 open c4(acid);
 fetch c4 into cusrec;
 close c4;
 htp.p( '<CENTER>' );
 htp.formopen( 'phg.accept_novelty_access' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'P2', null );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   if nvl(cusrec.enable_novelties,'F') = 'F' and c1rec.tot = 0
    then
     htp.tabledata( htf.formradio( 'P1', 'N', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'N' ) );
   end if;
   htp.tabledata( LNG5.EXT_TXT_640 );
   if c1rec.tot = 0 and cusrec.enable_novelties = 'T'
    then
     htp.tabledata( htf.formradio( 'P1', 'T', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'T' ) );
   end if;
   htp.tabledata( LNG5.EXT_TXT_394 );
   if c1rec.tot > 0 and cusrec.enable_novelties = 'T'
    then
     htp.tabledata( htf.formradio( 'P1', 'F', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'F' ) );
   end if;
   htp.tabledata( LNG5.EXT_TXT_395 );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
   for c3rec in c3(acid) loop
    if c1rec.tot = 0
     then
      htp.bold( c3rec.display_name );
      htp.nl;
     else
      htp.p( c3rec.display_name );
      htp.nl;
    end if;
   end loop;
   htp.p( '</TD>' );
   htp.tabledata( '&nbsp;' );
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
   htp.formselectopen( 'P2', null, 8, cattributes=>'MULTIPLE' );
   for c3rec in c3(acid) loop
    open c2( acid, c3rec.novelty_id );
    fetch c2 into c2rec;
    if c2%FOUND
     then
      htp.formselectoption( c3rec.display_name, 'SELECTED', cattributes=>'VALUE="' || c3rec.novelty_id || '"' );
     else
      htp.formselectoption( c3rec.display_name, cattributes=>'VALUE="' || c3rec.novelty_id || '"' );
    end if;
    close c2;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_396 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'NOVELTY_ACCESS', vaid=>acid, errmsg=>sqlerrm);
end novelty_access;

procedure accept_novelty_access( surl in varchar2, acid in integer, p1 in varchar2, p2 in GLBX.MYARRAY )
as

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_NOVELTY_ACCESS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if p1 = 'N'
  then
   update customer_account set enable_novelties = 'F' where aid = acid;
   delete from novelty_customer where aid = acid and aid in (select aid from customer_account where pid = owner_id);
   commit;
   novelty_access( surl, acid, LNG5.EXT_TXT_397 );
   return;
 end if;

 update customer_account set enable_novelties = 'T' where aid = acid;
 if p1 = 'T'
  then
   delete from novelty_customer where aid = acid and aid in (select aid from customer_account where pid = owner_id);
  else
   delete from novelty_customer where aid = acid and aid in (select aid from customer_account where pid = owner_id);
   for j in p2.first..p2.last loop
    if p2(j) is not null
     then
      insert into novelty_customer(aid,novelty_id) values (acid, p2(j) );
    end if;
   end loop;
 end if;

 commit;
 novelty_access( surl, acid, LNG5.EXT_TXT_397 );

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_NOVELTY_ACCESS', vaid=>acid, errmsg=>sqlerrm);
end accept_novelty_access;

procedure sanity( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c1 is select * from sanity_check;

 c1rec		c1%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 stmt		varchar2(32767);
 txt1		varchar2(4000);
 txt2		varchar2(4000);
 txt3		varchar2(4000);
 tmp		integer;
 ctmp		char(1);
 vtmp		varchar2(4000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.SANITY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, LNG5.EXT_TXT_642,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P72',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG5.EXT_TXT_643),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(LNG5.EXT_TXT_644),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold(LNG.CST_TXT_144),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;

 for c1rec in c1 loop
  txt1 := c1rec.sanity_text;
  txt3 := NULL;
  stmt := replace(c1rec.sanity_stmt,'<AID>',acid);
  stmt := replace(stmt,'<PID>',owner_id);
  -- htp.bold( stmt );htp.nl;
  if c1rec.sanity_type = 'NOT EXISTS'
   then
    begin
     execute immediate stmt into tmp;
     if nvl(tmp,0) = 0
      then
       txt2 := LNG5.EXT_TXT_646; txt3 := c1rec.sanity_error_text;
      else
       txt2 := LNG5.EXT_TXT_645;
     end if;
    exception
     when no_data_found then txt2 := LNG5.EXT_TXT_646; txt3 := c1rec.sanity_error_text;
     when others then txt2 := LNG5.EXT_TXT_647;
    end;

  elsif c1rec.sanity_type = 'EXISTS'
   then
    begin
     execute immediate stmt into tmp;
     if nvl(tmp,0) = 0
      then
       txt2 := LNG5.EXT_TXT_645;
      else
       txt2 := LNG5.EXT_TXT_646; txt3 := c1rec.sanity_error_text;
     end if;
    exception
     when no_data_found then txt2 := LNG5.EXT_TXT_645;
     when others then txt2 := LNG5.EXT_TXT_647;
    end;

  elsif c1rec.sanity_type = 'TOO MANY FOUND'
   then
    begin
     execute immediate stmt into tmp;
     if nvl(tmp,0) > 1
      then
       txt2 := LNG5.EXT_TXT_645;
      else
       txt2 := LNG5.EXT_TXT_646; txt3 := c1rec.sanity_error_text;
     end if;
    exception
     when no_data_found then txt2 := LNG5.EXT_TXT_645;
     when others then txt2 := LNG5.EXT_TXT_647;
    end;

  elsif c1rec.sanity_type = 'BLANK VALUE'
   then
    begin
     execute immediate stmt into vtmp;
     if vtmp is null
      then
       txt2 := LNG5.EXT_TXT_646; txt3 := c1rec.sanity_error_text;
      else
       txt2 := LNG5.EXT_TXT_645;
     end if;
    exception
     when no_data_found then txt2 := LNG5.EXT_TXT_646; txt3 := c1rec.sanity_error_text;
     when others then txt2 := LNG5.EXT_TXT_647;
    end;

  elsif c1rec.sanity_type = 'FEATURE DISABLED'
   then
    begin
     execute immediate stmt into ctmp;
     if ctmp = 'F'
      then
       txt2 := LNG5.EXT_TXT_646; txt3 := c1rec.sanity_error_text;
      else
       txt2 := LNG5.EXT_TXT_645;
     end if;
    exception
     when no_data_found then txt2 := LNG5.EXT_TXT_646; txt3 := c1rec.sanity_error_text;
     when others then txt2 := LNG5.EXT_TXT_647;
    end;

  end if;
  htp.tablerowopen;
   htp.tabledata( txt1, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( txt2,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( nvl(txt3,'&nbsp;'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;

 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.formopen( 'phg.phg_prefs' ) || htf.formhidden( 'SURL', surl ) ||htf.formhidden( 'ACID', acid ) ||
                  htf.formsubmit( null, LNG.PHG_TXT_028 ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PHG', 'SANITY',vaid=>acid,errmsg=>sqlerrm,extdet=>NULL );
end sanity;

procedure toggle_meta( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c3(bftr varchar2) is
  select attribute_id, sub_category, umo_type
  from umo_attributes
  where ((business_feature is null) or (business_feature is not null and business_feature = bftr)) and
         disp_phg = 'T' and
         umo_type in ('ALL','PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT')
  order by sub_category;

 cursor c4(acid integer) is select * from customer_account where aid = acid;

 cusrec		customer_account%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.NOVELTY_ACCESS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Toggle Meta Data',glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P75',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 theme_rec := get_theme_types( surl,acid );
 if msg is not null then glbx.header_msg( msg ); end if;
 open c4(acid);
 fetch c4 into cusrec;
 close c4;
 htp.p( '<CENTER>' );
 htp.formopen( 'phg.accept_toggle_meta' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   if nvl(cusrec.toggle_default,'N') = 'N'
    then
     htp.tabledata( htf.formradio( 'P1', 'N', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'N' ) );
   end if;
   htp.tabledata( 'Disabled' );
   if cusrec.toggle_default = 'A'
    then
     htp.tabledata( htf.formradio( 'P1', 'A', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'A' ) );
   end if;
   htp.tabledata( 'View All Initial Default' );
   if cusrec.toggle_default = 'R'
    then
     htp.tabledata( htf.formradio( 'P1', 'R', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'R' ) );
   end if;
   htp.tabledata( 'Toggle Restrict Initial Default' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( 'Restriction' );
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
    htp.formselectopen( 'P2' );
    for c3rec in c3(cusrec.theme_type) loop
     if cusrec.toggle_tag = c3rec.attribute_id
       then
         htp.formselectoption( c3rec.sub_category, 'SELECTED', cattributes=>'VALUE="' || c3rec.attribute_id || '"' );
       else
         htp.formselectoption( c3rec.sub_category, cattributes=>'VALUE="' || c3rec.attribute_id || '"' );
      end if;
    end loop;
    if cusrec.toggle_tag = -1 then htp.formselectoption( 'Film Size', 'SELECTED', cattributes=>'VALUE="-1"' ); else htp.formselectoption( 'Film Size', cattributes=>'VALUE="-1"' ); end if;
    if cusrec.toggle_tag = -2 then htp.formselectoption( 'Roll Id', 'SELECTED', cattributes=>'VALUE="-2"' ); else htp.formselectoption( 'Roll Id', cattributes=>'VALUE="-2"' ); end if;
    if cusrec.toggle_tag = -3 then htp.formselectoption( 'Film Colour', 'SELECTED', cattributes=>'VALUE="-3"' ); else htp.formselectoption( 'Film Colour', cattributes=>'VALUE="-3"' ); end if;
    if cusrec.toggle_tag = -4 then htp.formselectoption( 'Film Name', 'SELECTED', cattributes=>'VALUE="-4"' ); else htp.formselectoption( 'Film Name', cattributes=>'VALUE="-4"' ); end if;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
    htp.formselectopen( 'P3' );
    if cusrec.toggle_condition = '=' then htp.formselectoption( '=', 'SELECTED' ); else htp.formselectoption( '=' ); end if;
    if cusrec.toggle_condition = '<=' then htp.formselectoption( '<=', 'SELECTED' ); else htp.formselectoption( '<=' ); end if;
    if cusrec.toggle_condition = '>=' then htp.formselectoption( '>=', 'SELECTED' ); else htp.formselectoption( '>=' ); end if;
    if cusrec.toggle_condition = '<' then htp.formselectoption( '<', 'SELECTED' ); else htp.formselectoption( '<' ); end if;
    if cusrec.toggle_condition = '>' then htp.formselectoption( '>', 'SELECTED' ); else htp.formselectoption( '>' ); end if;
    if cusrec.toggle_condition = '!=' then htp.formselectoption( '!=', 'SELECTED' ); else htp.formselectoption( '!=' ); end if;
    if cusrec.toggle_condition = 'LIKE' then htp.formselectoption( 'LIKE', 'SELECTED' ); else htp.formselectoption( 'LIKE' ); end if;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
   htp.tabledata( htf.formtext( 'P4', 30, 4000, cusrec.toggle_value ));
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Update Meta Toggle Details' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'TOGGLE_META', vaid=>acid, errmsg=>sqlerrm);
end toggle_meta;

procedure accept_toggle_meta( surl in varchar2, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 )
as

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_TOGGLE_META', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 update customer_account
  set toggle_default = p1,
      toggle_tag = to_number(p2),
      toggle_condition = p3,
      toggle_value = p4
 where aid = acid and
       pid = owner_id;

 commit;
 toggle_meta( surl, acid, 'Details Updated' );

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_TOGGLE_META', vaid=>acid, errmsg=>sqlerrm);
end accept_toggle_meta;

procedure metatag( surl in varchar2, acid in integer, v_umo in integer, metaload in varchar2 )
as

 cursor c1(acid integer, v_umo integer) is select umo_id from umo um where umo_id = v_umo and aid = acid;

 c1rec		c1%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 res 		boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.METATAG', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(acid, v_umo);
 fetch c1 into c1rec;
 close c1;
 if c1rec.umo_id is null then return; end if;
 htp.htmlopen;
 res := mload.load_one_image( surl, owner_id, metaload, acid, v_umo, printoutput=>TRUE );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'METATAG', vaid=>acid, errmsg=>sqlerrm);
end metatag;

procedure gcard_access( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c2( acid integer, neid varchar2 ) is
  select 'x' exst
  from  gcard_customer nc
  where nc.aid = acid and
        nc.style_name = neid;

 cursor c3( vpid integer ) is
  select style_name
  from ecard_style
  where pid is null or
        (pid is not null and pid = vpid)
  order by style_name;

 cursor c4(acid integer) is select * from customer_account where aid = acid;

 c2rec		c2%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.GCARD_ACCESS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Greeting Card Access',glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P80',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 theme_rec := get_theme_types( surl,acid );
 if msg is not null then glbx.header_msg( msg ); end if;
 open c4(acid);
 fetch c4 into cusrec;
 close c4;
 htp.p( '<CENTER>' );
 htp.formopen( 'phg.accept_gcard_access' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'P2', null );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   if nvl(cusrec.enable_greetingcards,'F') = 'N'
    then
     htp.tabledata( htf.formradio( 'P1', 'N', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'N' ) );
   end if;
   htp.tabledata( 'No Access to any Greeting Cards' );
   if cusrec.enable_greetingcards = 'T'
    then
     htp.tabledata( htf.formradio( 'P1', 'T', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'T' ) );
   end if;
   htp.tabledata( 'Can Access all Greeting Cards' );
   if cusrec.enable_greetingcards = 'F'
    then
     htp.tabledata( htf.formradio( 'P1', 'F', 'CHECKED' ) );
    else
     htp.tabledata( htf.formradio( 'P1', 'F' ) );
   end if;
   htp.tabledata( 'Can only Access these Greeting Cards' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
   htp.tabledata( '&nbsp;' );
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
   for c3rec in c3(owner_id) loop
     htp.bold( c3rec.style_name );
     htp.nl;
   end loop;
   htp.p( '</TD>' );
   htp.tabledata( '&nbsp;' );
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
   htp.formselectopen( 'P2', null, 8, cattributes=>'MULTIPLE' );
   for c3rec in c3(owner_id) loop
    open c2( acid, c3rec.style_name );
    fetch c2 into c2rec;
    if c2%FOUND
     then
      htp.formselectoption( c3rec.style_name, 'SELECTED', cattributes=>'VALUE="' || c3rec.style_name || '"' );
     else
      htp.formselectoption( c3rec.style_name, cattributes=>'VALUE="' || c3rec.style_name || '"' );
    end if;
    close c2;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG5.EXT_TXT_396 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'GCARD_ACCESS', vaid=>acid, errmsg=>sqlerrm);
end gcard_access;

procedure accept_gcard_access( surl in varchar2, acid in integer, p1 in varchar2, p2 in GLBX.MYARRAY )
as

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_NOVELTY_ACCESS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if p1 = 'N'
  then
   update customer_account set enable_greetingcards = 'N' where aid = acid;
   delete from gcard_customer where aid = acid and aid in (select aid from customer_account where pid = owner_id);
   commit;
   gcard_access( surl, acid, LNG5.EXT_TXT_397 );
   return;
 end if;

 update customer_account set enable_greetingcards = p1 where aid = acid;
 if p1 = 'T'
  then
   delete from gcard_customer where aid = acid and aid in (select aid from customer_account where pid = owner_id);
  else
   delete from gcard_customer where aid = acid and aid in (select aid from customer_account where pid = owner_id);
   for j in p2.first..p2.last loop
    if p2(j) is not null
     then
      insert into gcard_customer(aid,style_name) values (acid, p2(j) );
    end if;
   end loop;
 end if;

 commit;
 gcard_access( surl, acid, LNG5.EXT_TXT_397 );

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_GCARD_ACCESS', vaid=>acid, errmsg=>sqlerrm);
end accept_gcard_access;

procedure eml_temp( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c1 is select * from email_template where pid is null and aid is null and profile_id is null order by template;
 cursor c2(ownr integer, acid integer) is select * from email_template where pid = ownr and (aid is null or nvl(aid,0) = nvl(acid,0)) order by template;
 cursor c3(acid integer) is select profile_id,username from customer_profile where aid = acid order by username;
 cursor c4(acid integer) is select * from customer_account where aid = acid;

 cusrec		customer_account%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.EML_TEMP', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Email Template Management',glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P85',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 theme_rec := get_theme_types( surl,acid );
 if msg is not null then glbx.header_msg( msg ); end if;
 open c4(acid);
 fetch c4 into cusrec;
 close c4;
 htp.p( '<CENTER>' );
 htp.formopen( 'phg.accept_eml_temp' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( 'Template' );
   htp.tabledata( 'Subject' );
   htp.tabledata( 'Account Id' );
   htp.tabledata( 'Profile Id' );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
 for c2rec in c2(owner_id, acid) loop
  htp.tablerowopen;
   htp.p( '<TD>' );
    htp.formhidden( 'P1', 'ECODE' );
    htp.formhidden( 'P2', c2rec.email_code );
    htp.formhidden( 'P1', 'V_ACID' );
    htp.formhidden( 'P2', c2rec.aid );
    htp.formhidden( 'P1', 'V_PROFILE_ID' );
    htp.formhidden( 'P2', c2rec.profile_id );
    htp.formhidden( 'P1', 'TMP' );
    htp.formtext( 'P2', 30, 100, c2rec.template );
   htp.p( '</TD>' );
   htp.p( '<TD>' );
    htp.formhidden( 'P1', 'ECODE' );
    htp.formhidden( 'P2', c2rec.email_code );
    htp.formhidden( 'P1', 'V_ACID' );
    htp.formhidden( 'P2', c2rec.aid );
    htp.formhidden( 'P1', 'V_PROFILE_ID' );
    htp.formhidden( 'P2', c2rec.profile_id );
    htp.formhidden( 'P1', 'SUBJ' );
    htp.formtext( 'P2', 60, 100, replace(replace(replace(c2rec.subject_line,'<','&lt;'),'>','&gt;'),'"','') );
   htp.p( '</TD>' );
   htp.p( '<TD>' );
    htp.formhidden( 'P1', 'ECODE' );
    htp.formhidden( 'P2', c2rec.email_code );
    htp.formhidden( 'P1', 'V_ACID' );
    htp.formhidden( 'P2', c2rec.aid );
    htp.formhidden( 'P1', 'V_PROFILE_ID' );
    htp.formhidden( 'P2', c2rec.profile_id );
    htp.formhidden( 'P1', 'ACCID' );
     htp.formselectopen( 'P2' );
      if c2rec.aid is null
       then
        htp.formselectoption( null, 'SELECTED' );
       else
        htp.formselectoption( null );
      end if;
       if c2rec.aid = acid
       then
        htp.formselectoption( 'This Account', 'SELECTED', cattributes=>'VALUE="' || acid || '"' );
       else
        htp.formselectoption( 'This Account', cattributes=>'VALUE="' || acid || '"' );
      end if;
     htp.formselectclose;
   htp.p( '</TD>' );
   if acid is null
    then
     htp.tabledata( '&nbsp;' );
    else
     htp.p( '<TD>' );
      htp.formhidden( 'P1', 'ECODE' );
      htp.formhidden( 'P2', c2rec.email_code );
      htp.formhidden( 'P1', 'V_ACID' );
      htp.formhidden( 'P2', c2rec.aid );
      htp.formhidden( 'P1', 'V_PROFILE_ID' );
      htp.formhidden( 'P2', c2rec.profile_id );
      htp.formhidden( 'P1', 'PROFID' );
      htp.formselectopen( 'P2' );
      htp.formselectoption( NULL );
      for c3rec in c3(acid) loop
       if c3rec.profile_id = c2rec.profile_id
       then
        htp.formselectoption( c3rec.username, 'SELECTED', cattributes=>'VALUE="' || c3rec.profile_id || '"' );
       else
        htp.formselectoption( c3rec.username, cattributes=>'VALUE="' || c3rec.profile_id || '"' );
      end if;
      end loop;
      htp.formselectclose;
     htp.p( '</TD>' );
   end if;
   htp.tabledata( htf.anchor( 'phg.define_eml_temp?surl=' || surl || '&acid=' || acid || '&tmpl=' || c2rec.email_code || '&v_pid=' || c2rec.pid || '&v_acid=' || c2rec.aid || '&v_profile_id=' || c2rec.profile_id || '&action=DELETE', 'Delete Template' ));
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.nl;
 htp.formsubmit( null, 'Update Email Template Details' );
 htp.formclose;
 htp.nl;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( 'Template' );
   htp.tabledata( 'Subject' );
   htp.tabledata( '&nbsp;' );
  htp.tablerowclose;
 for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( c1rec.template );
   htp.tabledata( replace(replace(replace(nvl(c1rec.subject_line,'&nbsp;'),'<','&lt;'),'>','&gt;'),'"','') );
   htp.tabledata( htf.anchor( 'phg.define_eml_temp?surl=' || surl || '&acid=' || acid || '&tmpl=' || c1rec.email_code || '&action=INSERT', 'Define Template' ));
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PHG', 'EML_TEMP', vaid=>acid, errmsg=>sqlerrm);
end eml_temp;

procedure accept_eml_temp( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 ecode		varchar2(100);
 v_acid		integer;
 v_profile_id	integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.ACCEPT_EML_TEMP', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 for j in p1.first..p1.last loop
  if p1(j) = 'ECODE'
   then
    ecode := p2(j);
  end if;
  if p1(j) = 'V_ACID'
   then
    v_acid := p2(j);
  end if;
  if p1(j) = 'V_PROFILE_ID'
   then
    v_profile_id := p2(j);
  end if;

  if p1(j) = 'TMP'
   then
    update email_template
     set
      template = p2(j)
    where
     email_code = ecode and
     pid = owner_id and
     nvl(aid,0) = nvl(v_acid,0) and
     nvl(profile_id,0) = nvl(v_profile_id,0);
    v_profile_id := null;
    v_acid := null;
  end if;
  if p1(j) = 'SUBJ'
   then
    update email_template
     set
      subject_line = p2(j)
    where
     email_code = ecode and
     pid = owner_id and
     nvl(aid,0) = nvl(v_acid,0) and
     nvl(profile_id,0) = nvl(v_profile_id,0);
    v_profile_id := null;
    v_acid := null;
  end if;
  if p1(j) = 'ACCID'
   then
    update email_template
     set
      aid = trim(p2(j))
    where
     email_code = ecode and
     pid = owner_id and
     nvl(aid,0) = nvl(v_acid,0) and
     nvl(profile_id,0) = nvl(v_profile_id,0);
    v_profile_id := null;
    v_acid := null;
  end if;
  if p1(j) = 'PROFID'
   then
    if p2(j) is not null
     then
      update email_template
       set
        aid = (select aid from customer_profile where profile_id = to_number(p2(j))),
        profile_id = trim(p2(j))
      where
       email_code = ecode and
       pid = owner_id and
       nvl(aid,0) = nvl(v_acid,0) and
       nvl(profile_id,0) = nvl(v_profile_id,0);
     else
      update email_template
       set
        profile_id = null
      where
       email_code = ecode and
       pid = owner_id and
       nvl(aid,0) = nvl(v_acid,0) and
       nvl(profile_id,0) = nvl(v_profile_id,0);
    end if;
    v_profile_id := null;
    v_acid := null;
  end if;
 end loop;

 commit;
 eml_temp( surl, acid, 'Details Updated' );

exception when others then
 glbx.error_details( 'PHG', 'ACCEPT_EML_TEMP', vaid=>acid, errmsg=>sqlerrm);
end accept_eml_temp;

procedure define_eml_temp( surl in varchar2, acid in integer, tmpl in varchar2, action in varchar2, v_pid in integer default null, v_acid in integer default null, v_profile_id in integer default null )
as

 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PHG.DEFINE_EML_TEMP', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if action = 'INSERT'
  then
   insert into email_template(email_code,subject_line,template,pid,aid)
    select email_code,subject_line,template,owner_id,acid
    from email_template
    where email_code = tmpl;
 elsif action = 'DELETE'
  then
   delete from email_template
    where
     email_code = tmpl and
     pid = owner_id and
     nvl(aid,0) = nvl(v_acid,0) and
     nvl(profile_id,0) = nvl(profile_id,0);
 end if;
 commit;

 eml_temp( surl, acid, 'Details Updated' );

exception when others then
 glbx.error_details( 'PHG', 'DEFINE_EML_TEMP', vaid=>acid, errmsg=>sqlerrm);
end define_eml_temp;

end phg;

/
