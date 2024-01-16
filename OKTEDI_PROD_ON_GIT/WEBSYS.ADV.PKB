CREATE OR REPLACE package body WEBSYS.adv
as

 procedure insert_adv( v_advid integer, v_frequency in integer, t_theme in varchar2, t_phg in char, t_cpl in char, t_gst in char);
 procedure delete_adv( v_advid integer, v_frequency in integer, t_theme in varchar2, t_phg in char, t_cpl in char, t_gst in char);
 procedure add_adv( v_advid integer );
 procedure del_adv( v_advid integer );


 function display_advert( surl in varchar2, sess_id in integer, theme_type in varchar2, custtype in varchar2, screen_estate in varchar2 )
  return varchar2
 as
  cursor c1(theme_type varchar2, custtype varchar2) is
   select rowid,advid,next_advid,target_phg,target_cpl,target_gst
   from advert_sequence
   where is_current = 'T' and
         target_theme = theme_type and
         ( (target_phg = 'T' and custtype = 'PHOTOGRAPHER') or
           (target_cpl = 'T' and custtype = 'OWNER') or
           (target_gst = 'T' and custtype = 'CUSTOMER')
         )
   for update;

   cursor c2( v_advid integer) is select * from advertisement_details where advid = v_advid;

  c1rec		c1%ROWTYPE;
  c2rec		c2%ROWTYPE;
  currsec	integer;

 begin

  open c1(theme_type,custtype);
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    return( NULL );
  end if;
  close c1;

  update advert_sequence
   set is_current = 'F'
    where rowid = c1rec.rowid;

  update advert_sequence
   set is_current = 'T'
    where
     advid = c1rec.next_advid and
     target_theme = theme_type and
     target_phg = c1rec.target_phg and
     target_cpl = c1rec.target_cpl and
     target_gst = c1rec.target_gst;
  commit;

  open c2(c1rec.advid);
  fetch c2 into c2rec;
  if c2%NOTFOUND
   then
    close c2;
    return( NULL );
  end if;
  close c2;

  insert into advertisement_stats(advid,login_session,view_type,date_created) values (c1rec.advid, sess_id, 'S', sysdate );
  commit;

  if c2rec.image_in_db = 'T'
   then
    return( htf.anchor('adv.redirect?sess_id=' || sess_id || '&v_advid=' || c1rec.advid || '&url=' || c2rec.http_link,
            htf.img(
            'ump.retrieve_uma?surl=' || surl || '&parm1=UMO_ID&parm2=' || c2rec.image_loc || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
            '&parm1=LOGIN_TYPE&parm2=' || custtype || '&parm1=OVERRIDE_DISPLAY&parm2=ADVERT&parm1=AID&parm2=' || sess_id || '"',
            cattributes=>'BORDER=0 WIDTH=' || c2rec.width || ' HEIGHT=' || c2rec.height || ' ALT="' || c2rec.altval || '"')));
   else
    return( htf.anchor('adv.redirect?sess_id=' || sess_id || '&v_advid=' || c1rec.advid || '&url=' || c2rec.http_link,
            htf.img(DECS.ADVERT_LOCATION || c2rec.display_image,cattributes=>'BORDER=0 WIDTH=' || c2rec.width || ' HEIGHT=' || c2rec.height || ' ALT="' || c2rec.altval || '"')));
  end if;

 exception when others then
  glbx.error_details( 'ADV', 'DISPLAY_ADVERT',errmsg=>sqlerrm, extdet=>'SESSID:' || sess_id || ' THEME_TYPE:' || theme_type || ' CUSTTYPE:' || custtype || ' SCREEN_ESTATE:' || screen_estate );
 end display_advert;

procedure redirect( sess_id in integer, v_advid in integer, url in varchar2 )
as
begin

 insert into advertisement_stats(advid,login_session,view_type,date_created) values (v_advid, sess_id, 'C', sysdate );
 commit;
 owa_util.redirect_url( url );
 exception when others then
  glbx.error_details( 'ADV', 'REDIRECT',errmsg=>sqlerrm, extdet=>'SESSID:' || sess_id || ' V_ADVID:' || v_advid );
 end redirect;

procedure mng_advert(surl varchar2)
as
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
  htp.htmlopen;
  htp.framesetopen('100%','20%,80%',cattributes=>'frameborder="1" framespacing="1" border="1"');
   htp.frame( 'adv.edit_advert_left?surl=' || surl,'LEFT');
   htp.frame( 'adv.edit_advert_details?surl=' || surl,'RIGHT');
  htp.framesetclose;
  htp.noframesopen;
  htp.p( '<BODY>' );
  htp.p('This Browser does not support Frames');
  htp.noframesclose;
  htp.p( '</BODY>' );
  htp.htmlclose;
end mng_advert;

procedure edit_advert_left(surl varchar2)
as

 cursor c1 is select avid,advertiser_name from advertiser order by advertiser_name;
 cursor c2 is select chid,charge_name from advert_charge_plan order by chid;

 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG4.AHC_TXT_140, helpid=>'V05', style=>'NOMENU' );
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adv.edit_advert_details?surl=' || surl || '&v_avid=0', '[' || LNG4.AHC_TXT_141 || ']',ctarget=>'RIGHT') );
  htp.tablerowclose;
  for c1rec in c1 loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adv.edit_advert_details?surl=' || surl || '&v_avid=' || c1rec.avid, c1rec.advertiser_name,ctarget=>'RIGHT') );
  htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 adm.main_title( surl, sessid, LNG4.AHC_TXT_142, helpid=>'V06', style=>'NOMENU' );
  htp.tablerowopen;
   htp.tabledata( htf.anchor2('adv.edit_advert_plan?surl=' || surl || '&v_chid=0', '[' || LNG3.ADM_TXT_112 || ']',ctarget=>'RIGHT') );
  htp.tablerowclose;
 htp.tableopen;
  for c2rec in c2 loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor2('adv.edit_advert_plan?surl=' || surl || '&v_chid=' || c2rec.chid, c2rec.charge_name,ctarget=>'RIGHT') );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor2( 'adm.acct_bottom?surl=' || surl || '&msg=','[' || LNG4.AHC_TXT_144 || ']',ctarget=>'_top');
 htp.htmlclose;
end edit_advert_left;

procedure edit_advert_details( surl in varchar2, v_avid in integer default 0, msg in varchar2 default null )
as
 cursor c1(v_avid integer) is select * from advertiser where avid = v_avid;
 cursor c2(v_avid integer) is select * from advertisement where avid = v_avid order by date_created desc;
 cursor c3(v_chid integer) is select charge_name from advert_charge_plan where chid = v_chid;
 c1rec	c1%ROWTYPE;
 c3rec	c3%ROWTYPE;
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(v_avid);
 fetch c1 into c1rec;
 close c1;
 if v_avid = 0
  then
   adm.main_title( surl, sessid, nvl(msg, LNG4.AHC_TXT_145), style=>'NOMENU', helpid=>'V01' );
  else
   adm.main_title( surl, sessid, nvl( msg, LNG4.AHC_TXT_146 || ': ' || c1rec.advertiser_name), style=>'NOMENU', helpid=>'V01' );
 end if;
 htp.formopen( 'adv.accept_advert' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'V_AVID', v_avid );
 htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_147 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',40, 100, c1rec.advertiser_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_148 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',40, 100, c1rec.contact_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_149 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P3',40, 100, c1rec.contact_email ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_150 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P4',40, 100, c1rec.contact_phone ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_151 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P5',40, 100, c1rec.contact_name2 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_152 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P6',40, 100, c1rec.contact_email2 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_153 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P7',40, 100, c1rec.contact_phone2 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_154 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P8',40, 100, c1rec.contact_name3 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_155 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P9',40, 100, c1rec.contact_email3 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_156 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P10',40, 100, c1rec.contact_phone3 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_157 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P11',40, 100, c1rec.contact_address ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_158 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P12',40, 4000, c1rec.business_summary ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 if v_avid = 0
  then
 	htp.formsubmit( 'PA',LNG4.AHC_TXT_159 );
  else
 	htp.formsubmit( 'PA',LNG4.AHC_TXT_160 );
 	htp.formsubmit( 'PA',LNG4.AHC_TXT_161 );
 end if;
 htp.formclose;
 htp.nl;
 htp.header(3,LNG4.AHC_TXT_162 );
 htp.tableopen;
 htp.tablerowopen;
  htp.tableheader( '&nbsp;' );
  htp.tableheader( LNG4.AHC_TXT_163 );
  htp.tableheader( LNG.GLB_TXT_078 );
  htp.tableheader( LNG4.AHC_TXT_164 );
  htp.tableheader( LNG.PHG_TXT_249 );
 htp.tablerowclose;
 for c2rec in c2(v_avid) loop
  htp.tablerowopen;
  htp.tabledata( htf.anchor( 'adv.edit_campaign?surl=' || surl || '&v_avid=' || v_avid || '&v_adid=' || c2rec.adid,'[' || LNG.GLB_TXT_123 || ']'));
  htp.tabledata( htf.bold( c2rec.campaign_name ) );
  htp.tabledata( htf.italic( to_char(c2rec.date_created,LNG.MASK ) ) );
  htp.tabledata( c2rec.target_theme );
  open c3(c2rec.chid);
  fetch c3 into c3rec;
  close c3;
  htp.tabledata( c3rec.charge_name );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.anchor( 'adv.edit_campaign?surl=' || surl || '&v_avid=' || v_avid || '&v_adid=0','[' || LNG4.AHC_TXT_165 || ']');
 htp.nl;
 htp.htmlclose;
 end edit_advert_details;

 procedure accept_advert(surl in varchar2, v_avid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2,
                         p8 in varchar2, p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, pa in varchar2 )
 as
  cursor c1(v_avid integer) is select advid from advertisement_details where adid in (select adid from advertisement where avid = v_avid);
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
 newad	integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if pa = LNG.ORD_ALT_062
  then
   edit_advert_details(surl, v_avid);
   return;
 end if;

 if pa = LNG4.AHC_TXT_161
  then
   for c1rec in c1(v_avid) loop
    del_adv( c1rec.advid );
   end loop;
   delete from advertisement_stats where advid in (select advid from advertisement_details where adid in (select adid from advertisement where avid = v_avid));
   delete from advertisement_details where adid in (select adid from advertisement where avid = v_avid);
   delete from advertisement where avid = v_avid;
   delete from advertiser where avid = v_avid;
   commit;
   htp.htmlopen;
    htp.header(2, LNG4.AHC_TXT_166, 'CENTER' );
   htp.htmlclose;
   return;
 end if;

 if v_avid = 0
  then
   select s_advertiser.nextval into newad from dual;
   insert into advertiser
    (avid,advertiser_name,contact_name,contact_email,contact_phone,contact_name2,contact_email2,contact_phone2,contact_name3,contact_email3,contact_phone3,contact_address,business_summary)
   values
    (newad,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12);
  else
   update advertiser
    set
     advertiser_name = p1,
     contact_name = p2,
     contact_email = p3,
     contact_phone = p4,
     contact_name2 = p5,
     contact_email2 = p6,
     contact_phone2 = p7,
     contact_name3 = p8,
     contact_email3 = p9,
     contact_phone3 = p10,
     contact_address = p11,
     business_summary = p12
    where avid = v_avid;
    newad := v_avid;
 end if;
 commit;

 edit_advert_details( surl, newad, LNG4.AHC_TXT_167 );

 end accept_advert;

procedure edit_advert_plan( surl in varchar2, v_chid in integer default 0, msg in varchar2 default null )
as
 cursor c1(v_chid integer) is select * from advert_charge_plan where chid = v_chid;
 cursor c2(v_chid integer) is select count('x') tot from advertisement where chid = v_chid;
 cursor c3 is select theme_type from theme_types order by theme_type;
 c1rec	c1%ROWTYPE;
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
 tot	integer;

 function click(cd in varchar2, val in varchar2)
  return varchar2
 as
 begin
  if val = 'T'
   then
    return( htf.formcheckbox( cd, 'T', 'CHECKED' ) );
   else
    return( htf.formcheckbox( cd, 'T' ));
  end if;
 end click;

begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(v_chid);
 fetch c1 into c1rec;
 close c1;
 if v_chid = 0
  then
   adm.main_title( surl, sessid, nvl( msg, LNG4.AHC_TXT_168 ), helpid=>'V02', style=>'NOMENU' );
  else
   adm.main_title( surl, sessid, nvl( msg, LNG4.AHC_TXT_169 || ': ' || c1rec.charge_name), helpid=>'V02', style=>'NOMENU' );
 end if;
 htp.formopen( 'adv.accept_plan' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'V_CHID', v_chid );
 htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_170 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',40, 100, c1rec.charge_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_171 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',40, 100, c1rec.charged_amount ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_172 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P3',40, 100, c1rec.frequency ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_173 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P3A',10, 10, c1rec.days_valid_for ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_174 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     tmp := htf.formselectopen( 'P4' );
     for c3rec in c3 loop
      if c3rec.theme_type = c1rec.target_theme
       then
        tmp := tmp || htf.formselectoption( c3rec.theme_type, 'SELECTED' );
       else
        tmp := tmp || htf.formselectoption( c3rec.theme_type );
      end if;
     end loop;
     tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_175 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(click('P5',c1rec.target_phg),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_176 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(click('P6',c1rec.target_cpl),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_177 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(click('P7',c1rec.target_gst),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_178 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(click('P8',c1rec.page_loc_a),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_179 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(click('P9',c1rec.page_loc_b),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_180 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(click('P10',c1rec.page_loc_c),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_181 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(click('P11',c1rec.page_loc_d),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 if v_chid = 0
  then
 	htp.formsubmit( 'PA',LNG4.AHC_TXT_182 );
  else
 	htp.formsubmit( 'PA',LNG3.ADM_TXT_113 );
 	tot := 0;
 	open c2(v_chid);
 	fetch c2 into tot;
 	close c2;
 	if tot = 0 then htp.formsubmit( 'PA', LNG3.ADM_TXT_114 ); end if;
 end if;
 htp.formclose;
 htp.htmlclose;
 end edit_advert_plan;

 procedure accept_plan(surl in varchar2, v_chid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p3a in varchar2, p4 in varchar2, p5 in varchar2 default 'F', p6 in varchar2 default 'F', p7 in varchar2 default 'F',
                         p8 in varchar2 default 'F', p9 in varchar2 default 'F', p10 in varchar2 default 'F', p11 in varchar2 default 'F', pa in varchar2 )
 as
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
 newad	integer;
 nmb	integer;
 nmb2	integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if pa = LNG.ORD_ALT_062
  then
   edit_advert_plan(surl, v_chid);
   return;
 end if;

 if pa = LNG3.ADM_TXT_114
  then
   delete from advert_charge_plan where chid = v_chid;
   commit;
   htp.htmlopen;
    htp.header(2, LNG4.AHC_TXT_186, 'CENTER' );
   htp.htmlclose;
   return;
 end if;
 begin nmb2 := trunc(to_number(p3a)); exception when others then nmb2 := 90; end;
 begin nmb := trunc(to_number(p3)); exception when others then nmb := 1; end;
 if nmb < 1 or nmb > 5 then nmb := 1; end if;
 if v_chid = 0
  then
   select s_advert_charge_plan.nextval into newad from dual;
   insert into advert_charge_plan
    (chid,charge_name,charged_amount,frequency,target_theme,target_phg,target_cpl,target_gst,page_loc_a,page_loc_b,page_loc_c,page_loc_d,days_valid_for)
   values
    (newad,p1,p2,nmb,p4,p5,p6,p7,p8,p9,p10,p11,nvl(nmb2,90));
  else
   update advert_charge_plan
    set
      charge_name = nvl(p1,LNG3.ADM_TXT_351),
      charged_amount = nvl(p2,LNG4.AHC_TXT_187),
      frequency = nvl(nmb,1),
      target_theme = nvl(p4,'WEDDING'),
      target_phg = p5,
      target_cpl = p6,
      target_gst = p7,
      page_loc_a = p8,
      page_loc_b = p9,
      page_loc_c = p10,
      page_loc_d = p11,
      days_valid_for = nvl(nmb2,90)
    where chid = v_chid;
    newad := v_chid;
 end if;
 commit;

 edit_advert_plan( surl, newad, LNG4.AHC_TXT_188 );

 end accept_plan;

procedure edit_campaign( surl in varchar2, v_avid in integer,v_adid in integer default 0, msg in varchar2 default null )
as
 cursor ca(v_avid integer) is select * from advertiser where avid = v_avid;
 cursor c1(v_avid integer, v_adid integer) is select * from advertisement where avid = v_avid and adid = v_adid;
 cursor c2(v_avid integer) is select * from advertisement where avid = v_avid order by date_created desc;
 cursor c3 is select chid,charge_name from advert_charge_plan order by chid;
 cursor c4(v_adid integer) is select * from advertisement_details where adid = v_adid order by advid;

 carec	ca%ROWTYPE;
 c1rec	c1%ROWTYPE;
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open ca(v_avid);
 fetch ca into carec;
 close ca;
 open c1(v_avid,v_adid);
 fetch c1 into c1rec;
 close c1;

 adm.main_title( surl, sessid, nvl( msg,LNG4.AHC_TXT_146 || ': ' || carec.advertiser_name) || htf.nl || LNG4.AHC_TXT_189 || ': ' || c1rec.campaign_name, helpid=>'V03', style=>'NOMENU' );

 htp.formopen( 'adv.accept_campaign' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'V_AVID', v_avid );
 htp.formhidden( 'V_ADID', v_adid );
 htp.formhidden( 'OLD_CHID', c1rec.chid);
 htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_163 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',40, 100, c1rec.campaign_name ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_249 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     tmp := htf.formselectopen( 'P2' );
     for c3rec in c3 loop
      if c3rec.chid = c1rec.chid
       then
        tmp := tmp || htf.formselectoption( '[' || c3rec.chid || '] ' || c3rec.charge_name, 'SELECTED' );
       else
        tmp := tmp || htf.formselectoption( '[' || c3rec.chid || '] ' || c3rec.charge_name );
      end if;
     end loop;
     tmp := tmp || htf.formselectclose;
     htp.tabledata(tmp,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 if v_adid > 0
  then
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.GLB_TXT_078 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(to_char(c1rec.date_created,LNG.MASK),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG3.ADM_TXT_415 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(to_char(c1rec.date_expires,LNG.MASK),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_191 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.charged_amount,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_192 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.frequency,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_174 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.target_theme,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_175 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.target_phg,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_176 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.target_cpl,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_177 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.target_gst,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_178 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.page_loc_a,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_179 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.page_loc_b,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_180 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.page_loc_c,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_181 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(c1rec.page_loc_d,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 end if;
 htp.tableclose;

 if v_adid = 0
  then
 	htp.formsubmit( 'PA', LNG4.AHC_TXT_193 );
  else
 	htp.formsubmit( 'PA', LNG4.AHC_TXT_194 );
 	htp.formsubmit( 'PA', LNG4.AHC_TXT_195 );
 	htp.formsubmit( 'PA', LNG.ORD_ALT_062 );
 end if;
 htp.formclose;
 htp.nl;
 htp.header(3, LNG4.AHC_TXT_196 );
 htp.tableopen;
 htp.tablerowopen;
  htp.tableheader( LNG.GLB_TXT_123 );
  htp.tableheader( LNG.CST_TXT_132 );
 htp.tablerowclose;
 for c4rec in c4(v_adid) loop
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'adv.edit_image?surl=' || surl || '&v_avid=' || v_avid || '&v_adid=' || v_adid || '&v_advid=0' || c4rec.advid,'[' || LNG.GLB_TXT_123 || ']'));
   htp.tabledata( nvl(c4rec.altval, LNG4.AHC_TXT_198 ));
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor( 'adv.edit_image?surl=' || surl || '&v_avid=' || v_avid || '&v_adid=' || v_adid || '&v_advid=0','[' || LNG4.AHC_TXT_199 || ']');
 htp.nl;
 htp.nl;
 htp.header(3, LNG4.AHC_TXT_201 );
 htp.anchor('adv.campaign_stats?surl=' || surl || '&v_avid=' || v_avid || '&v_adid=' || v_adid, LNG4.AHC_TXT_200 );
 htp.nl;
 htp.htmlclose;
 end edit_campaign;

 procedure campaign_stats(surl varchar2,v_avid integer, v_adid integer)
 as
  cursor c1(v_adid integer) is
   select ad.altval,sum(decode(asx.view_type,'S',1,0)) tot,count(distinct asx.login_session) tot_log,sum(decode(asx.view_type,'C',1,0)) tot_click

   from advertisement_stats asx, advertisement_details ad
   where  asx.advid = ad.advid and
          ad.adid = v_adid
   group by ad.altval;

 sessid	integer;
 sts	varchar2(200);
 newid	integer;
 cplan	integer;

begin
 glbx.adm_cookie_id( surl,sessid, sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 adm.main_title( surl, sessid, LNG.PHG_ALT_127, helpid=>'V07', style=>'NOMENU' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen(cattributes=>'BORDER=1');
  htp.tablerowopen;
   htp.tableheader( LNG4.AHC_TXT_202,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tableheader( LNG4.AHC_TXT_203,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tableheader( LNG4.AHC_TXT_204,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tableheader( LNG4.AHC_TXT_205,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 for c1rec in c1(v_adid) loop
  htp.tablerowopen;
   htp.tabledata( htf.bold(c1rec.altval),cattributes=>GLBX.QUERY_CELL_BACKGROUND );
   htp.tabledata( c1rec.tot,cattributes=>GLBX.QUERY_CELL_BACKGROUND );
   htp.tabledata( c1rec.tot_log,cattributes=>GLBX.QUERY_CELL_BACKGROUND );
   htp.tabledata( c1rec.tot_click,cattributes=>GLBX.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
 end campaign_stats;

 procedure accept_campaign(surl in varchar2, v_avid integer, v_adid integer, p1 in varchar2, p2 in varchar2, pa in varchar2, old_chid in integer )
 as
  cursor c1(v_avid integer) is select advid from advertisement_details where adid in (select adid from advertisement where avid = v_avid);
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
 newid	integer;
 cplan	integer;
begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if pa = LNG.ORD_ALT_062
  then
   edit_advert_details(surl,v_avid);
   return;
 end if;
 if pa = LNG4.AHC_TXT_195
   then
    for c1rec in c1(v_avid) loop
     del_adv( c1rec.advid );
    end loop;
    delete from advertisement_stats where advid in (select advid from advertisement_details where adid = v_adid);
    delete from advertisement_details where adid in (select adid from advertisement where avid = v_avid);
    delete from advertisement where adid = v_adid;
    commit;
    htp.htmlopen;
     htp.header(2, LNG4.AHC_TXT_206, 'CENTER' );
    htp.htmlclose;
    return;
  end if;
  cplan := to_number(substr(p2,2,instr(p2,']')-2));
  if pa = LNG4.AHC_TXT_193
   then
    select s_advertisement.nextval into newid from dual;
    insert into advertisement
     (avid,adid,chid,campaign_name,charged_amount,date_created,date_expires,frequency,target_theme,
     target_phg,target_cpl,target_gst,page_loc_a,page_loc_b,page_loc_c,page_loc_d)
     select
     v_avid,newid,chid,nvl(p1,LNG4.AHC_TXT_207),charged_amount,sysdate,sysdate+days_valid_for,frequency,target_theme,
     target_phg,target_cpl,target_gst,page_loc_a,page_loc_b,page_loc_c,page_loc_d
     from advert_charge_plan
     where chid = cplan;
  else
    if cplan = old_chid
     then
      update advertisement
       set
         campaign_name = nvl(p1,LNG4.AHC_TXT_207)
       where adid = v_adid;
     else
      delete from advertisement where avid = v_avid and adid = v_adid;
      insert into advertisement
       (avid,adid,chid,campaign_name,charged_amount,date_created,date_expires,frequency,target_theme,
        target_phg,target_cpl,target_gst,page_loc_a,page_loc_b,page_loc_c,page_loc_d)
       select
        v_avid,v_adid,chid,nvl(p1,LNG4.AHC_TXT_207),charged_amount,sysdate,sysdate+days_valid_for,frequency,target_theme,
        target_phg,target_cpl,target_gst,page_loc_a,page_loc_b,page_loc_c,page_loc_d
        from advert_charge_plan
        where chid = cplan;
     end if;
     newid := v_adid;
  end if;

  commit;
  edit_campaign(surl, v_avid,newid,LNG4.AHC_TXT_208);

end accept_campaign;

procedure edit_image( surl in varchar2, v_avid in integer, v_adid in integer, v_advid in integer default 0, msg in varchar2 default null )
as
 cursor c1(v_avid integer) is select * from advertiser where avid = v_avid;
 cursor c3(v_advid integer) is select * from advertisement_details where advid = v_advid;
 c1rec	c1%ROWTYPE;
 c3rec	c3%ROWTYPE;
 tmp	varchar2(2000);
 sessid	integer;
 sts	varchar2(200);
begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;
 open c1(v_avid);
 fetch c1 into c1rec;
 close c1;
 open c3(v_advid);
 fetch c3 into c3rec;
 close c3;
 if v_advid = 0
  then
   adm.main_title( surl, sessid, nvl( msg,LNG4.AHC_TXT_209), style=>'NOMENU', helpid=>'V04' );
  else
   adm.main_title( surl, sessid, nvl( msg,LNG4.AHC_TXT_146 || ': ' || c1rec.advertiser_name), style=>'NOMENU', helpid=>'V04' );
 end if;

 if v_advid = 0
  then
   htp.bold( LNG4.AHC_TXT_210 );
   htp.nl;
  else
   if c3rec.image_in_db = 'T'
    then
     htp.anchor('adv.redirect?sess_id=' || sessid || '&v_advid=' || c3rec.advid || '&url=' || c3rec.http_link, htf.img(
              'ump.retrieve_uma?surl=' || surl || '&parm1=UMO_ID&parm2=' || c3rec.image_loc || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
              '&parm1=LOGIN_TYPE&parm2=ADMINISTRATOR&parm1=OVERRIDE_DISPLAY&parm2=ADVERT',
              cattributes=>'BORDER=0 WIDTH=' || c3rec.width || ' HEIGHT=' || c3rec.height || ' ALT="' || c3rec.altval || '"'));
    else
     htp.anchor('adv.redirect?sess_id=' || sessid || '&v_advid=' || c3rec.advid || '&url=' || c3rec.http_link, htf.img(DECS.ADVERT_LOCATION || c3rec.display_image,cattributes=>'BORDER=0 WIDTH=' || c3rec.width || ' HEIGHT=' || c3rec.height || ' ALT="' || c3rec.altval || '"'));
   end if;
   htp.nl;
 end if;

 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'adv.accept_image', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'V_AVID', v_avid );
 htp.formhidden( 'V_ADID', v_adid );
 htp.formhidden( 'V_ADVID', v_advid );

 htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=1 ' || GLBX.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_211 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P1',40, 100, c3rec.altval ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_212 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P2',40, 1000, c3rec.http_link ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_213 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P3',10, 10, c3rec.width ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_214 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P4',10, 10, c3rec.height ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_215 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c3rec.image_in_db = 'T'
      then
       htp.tabledata(htf.formradio('P5','T','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formradio('P5','T'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic( LNG3.ADM_TXT_762 )),cattributes=>glbx.QUERY_BACKGROUND);
     htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_217 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     if c3rec.image_in_db = 'F'
      then
       htp.tabledata(htf.formradio('P5','F','CHECKED'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
      else
       htp.tabledata(htf.formradio('P5','F'),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata(htf.bold( LNG4.AHC_TXT_218 ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.formtext('P6',40, 100, c3rec.display_image ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 if v_advid = 0
  then
 	htp.formsubmit( 'PA',LNG4.AHC_TXT_219 );
  else
 	htp.formsubmit( 'PA',LNG4.AHC_TXT_221 );
 	htp.formsubmit( 'PA',LNG.PHG_BUT_117);
 	htp.formsubmit( 'PA',LNG.ORD_ALT_062 );
 end if;
 htp.formclose;
 htp.htmlclose;
 end edit_image;

procedure accept_image(surl in varchar2,file in varchar2, v_avid in integer, v_adid in integer, v_advid integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, pa in varchar2 )
as

cursor c1(v_avid integer) is select advid from advertisement_details where adid in (select adid from advertisement where avid = v_avid);

 sessid		integer;
 sts		varchar2(200);
 newid		integer;
 tval		integer;
 nmb1		integer;
 nmb2		integer;
 parm1		ump.parameters;
 parm2		ump.parameters;
 retlink	varchar2(100);
 new_id		integer;
 newid_arr	ump.myarray_int;

begin
 glbx.adm_cookie_id( surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
 end if;

 if pa = LNG.ORD_ALT_062
  then
   edit_campaign(surl, v_avid,v_adid);
   return;
 end if;

 if pa = LNG.PHG_BUT_117
  then
   for c1rec in c1(v_avid) loop
    del_adv( c1rec.advid );
   end loop;
   delete from advertisement_details where advid = v_advid;
   delete from advertisement_stats where advid = v_advid;
   commit;
   htp.htmlopen;
    htp.header(2, LNG4.AHC_TXT_223, 'CENTER' );
   htp.htmlclose;
   return;
 end if;

 begin nmb1 := trunc(to_number( p3 )); exception when others then nmb1 := null; end;
 begin nmb2 := trunc(to_number( p4 )); exception when others then nmb2 := null; end;
 if nmb1 < 0 then nmb1 := null; end if;
 if nmb2 < 0 then nmb2 := null; end if;

 if  (p5 = 'F') or (p5 is null and p6 is not null)
  then
   if pa = LNG4.AHC_TXT_219
    then
     select s_advertisement_details.nextval into newid from dual;
     insert into advertisement_details(advid,adid,image_in_db,display_image,width,height,altval,http_link)
      values
       (newid,v_adid,'F',p6,nmb1,nmb2,p1,p2);
     add_adv(newid);
    else
    update advertisement_details
     set
      image_in_db = 'F',
      width = nmb1,
      height = nmb2,
      altval = p1,
      http_link = p2,
      display_image = p6,
      image_loc = null
      where advid = v_advid;
     newid := v_advid;
   end if;

   commit;
   edit_image(surl,v_avid,v_adid,newid, LNG4.AHC_TXT_224 );
   return;
 end if;

 -- Check if not loading file but just updating message

 if (p5 = 'T' and file is null)
  then
   if pa = LNG4.AHC_TXT_219
    then
     select s_advertisement_details.nextval into newid from dual;
     insert into advertisement_details(advid,adid,image_in_db,display_image,width,height,altval,http_link)
      values
       (newid,v_adid,'T',null,nmb1,nmb2,p1,p2);
   add_adv(newid);
   else
    update advertisement_details
     set
      image_in_db = 'T',
      width = nmb1,
      height = nmb2,
      altval = p1,
      http_link = p2,
      display_image = null
      where advid = v_advid;
     newid := v_advid;
   end if;

   commit;
   edit_image(surl,v_avid,v_adid,newid,LNG4.AHC_TXT_224 );
   return;
 end if;

 -- Assume loading gif or equivalent into the database

  if pa = LNG4.AHC_TXT_219
   then
    select s_advertisement_details.nextval into newid from dual;
   else
    -- If reloading must delete then re-insert
    newid := v_advid;
    delete from advertisement_details where advid = v_advid;
    commit;
  end if;

 parm1(1)  := 'OBJECT_TYPE';
 parm2(1)  := 'ADVERT';
 parm1(2)  := 'OWS_NAME';
 parm2(2)  := file;
 parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
 parm2(3)  := 'UPLOAD';
 parm1(4)  := 'FILE_NAME';
 parm2(4)  := file;
 parm1(5)  := 'STORE_ORIGINAL';
 parm2(5)  := 'FALSE';
 parm1(6)  := 'CREATE_THUMBNAIL';
 parm2(6)  := 'FALSE';
 parm1(7) := 'KEEP_STATUS';
 parm2(7) := 'REPLACE';
 parm1(8) := 'ORIGINAL_LOCATION';
 parm2(8) := file;
 parm1(9) := 'PARENT_UMO_ID';
 parm2(9) := NULL;
 parm1(10) := 'SCENE_ID';
 parm2(10) := NULL;
 parm1(11) := 'UMO_OWNER';
 parm2(11) := 'ADMINISTRATOR';
 parm1(12) := 'BYPASS_QUOTA_CHECK';
 parm2(12) := 'TRUE';
 ump.load_uma(surl,parm1,parm2,retlink,newid_arr ); newid := newid_arr(1);

insert into advertisement_details(advid,adid,image_in_db,display_image,width,height,altval,http_link,image_loc)
 values
 (newid,v_adid,'T',null,nmb1,nmb2,p1,p2,new_id);

commit;

 if pa = LNG4.AHC_TXT_219
   then
    add_adv(newid);
 end if;

 edit_image(surl,v_avid,v_adid,newid,LNG4.AHC_TXT_224 );

exception when others then
 glbx.error_details( 'ADV', 'ACCEPT_IMAGE',errmsg=>sqlerrm);
end accept_image;

procedure insert_adv( v_advid integer, v_frequency in integer, t_theme in varchar2, t_phg in char, t_cpl in char, t_gst in char)
as
 cursor c1(v_advid integer, t_theme varchar2, t_phg char, t_cpl char, t_gst char) is
  select rowid,advid from advert_sequence where target_theme = t_theme and target_phg = t_phg and target_cpl = t_cpl and target_gst = t_gst;

 last_advid	integer;
 first_rowid	rowid;
 last_rowid	rowid;
 -- Assumes that out of the three targets only one is T, the others are F
begin
 delete from advert_sequence
  where
   advid = v_advid and
   target_theme = t_theme and
   target_phg = t_phg and
   target_cpl = t_cpl and
   target_gst = t_gst;

 for j in 1..v_frequency loop
  insert into advert_sequence(advid,next_advid,target_theme,target_phg,target_cpl,target_gst) values
   (v_advid,null,t_theme,t_phg,t_cpl,t_gst);
 end loop;

 last_advid := NULL;
 for c1rec in c1(v_advid, t_theme, t_phg, t_cpl, t_gst) loop
  if c1%ROWCOUNT = 1 then first_rowid := c1rec.rowid; end if;
  update advert_sequence
   set
    is_current = 'F',
    next_advid = last_advid
   where rowid = c1rec.rowid;
  last_advid := c1rec.advid;
  last_rowid := c1rec.rowid;
 end loop;
 update advert_sequence
   set
    next_advid = last_advid
   where rowid = first_rowid;
 update advert_sequence
   set
    is_current = 'T'
   where rowid = last_rowid;
 commit;

end insert_adv;

procedure delete_adv( v_advid integer, v_frequency in integer, t_theme in varchar2, t_phg in char, t_cpl in char, t_gst in char)
as
 cursor c1(v_advid integer, t_theme varchar2, t_phg char, t_cpl char, t_gst char) is
  select rowid,advid from advert_sequence where target_theme = t_theme and target_phg = t_phg and target_cpl = t_cpl and target_gst = t_gst;

 last_advid	integer;
 first_rowid	rowid;
 last_rowid	rowid;
 -- Assumes that out of the three targets only one is T, the others are F
begin
 delete from advert_sequence
  where
   advid = v_advid and
   target_theme = t_theme and
   target_phg = t_phg and
   target_cpl = t_cpl and
   target_gst = t_gst;

 last_advid := NULL;
 for c1rec in c1(v_advid, t_theme, t_phg, t_cpl, t_gst) loop
  if c1%ROWCOUNT = 1 then first_rowid := c1rec.rowid; end if;
  update advert_sequence
   set
    is_current = 'F',
    next_advid = last_advid
   where rowid = c1rec.rowid;
  last_advid := c1rec.advid;
  last_rowid := c1rec.rowid;
 end loop;
 update advert_sequence
   set
    next_advid = last_advid
   where rowid = first_rowid;
 update advert_sequence
   set
    is_current = 'T'
   where rowid = last_rowid;
 commit;

end delete_adv;

procedure add_adv( v_advid integer )
as
 cursor c1(v_advid integer) is select adid from advertisement_details where advid = v_advid;
 cursor c2(v_adid integer) is select * from advertisement where adid = v_adid;
 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
begin
 open c1(v_advid);
 fetch c1 into c1rec;
 close c1;

 open c2(c1rec.adid);
 fetch c2 into c2rec;
 close c2;

 if nvl(c2rec.target_phg,'T') = 'T'
  then
   insert_adv(v_advid,c2rec.frequency,c2rec.target_theme,'T', 'F', 'F');
 end if;

 if nvl(c2rec.target_cpl,'T') = 'T'
  then
   insert_adv(v_advid,c2rec.frequency,c2rec.target_theme,'F', 'T', 'F');
 end if;

 if nvl(c2rec.target_gst,'T') = 'T'
  then
   insert_adv(v_advid,c2rec.frequency,c2rec.target_theme,'F', 'F', 'T');
 end if;

 commit;

end add_adv;

procedure del_adv( v_advid integer )
as
 cursor c1(v_advid integer) is select adid from advertisement_details where advid = v_advid;
 cursor c2(v_adid integer) is select * from advertisement where adid = v_adid;
 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
begin
 open c1(v_advid);
 fetch c1 into c1rec;
 close c1;

 open c2(c1rec.adid);
 fetch c2 into c2rec;
 close c2;

 if nvl(c2rec.target_phg,'T') = 'T'
  then
   delete_adv(v_advid,c2rec.frequency,c2rec.target_theme,'T', 'F', 'F');
 end if;

 if nvl(c2rec.target_cpl,'T') = 'T'
  then
   delete_adv(v_advid,c2rec.frequency,c2rec.target_theme,'F', 'T', 'F');
 end if;

 if nvl(c2rec.target_gst,'T') = 'T'
  then
   delete_adv(v_advid,c2rec.frequency,c2rec.target_theme,'F', 'F', 'T');
 end if;

 commit;

end del_adv;

end adv;

/
