CREATE OR REPLACE package body WEBSYS.gcard
as

 function card_img( surl varchar2,currcard in integer, card_id in integer ) return varchar2;
 function extract_email( surl varchar2,em in varchar2 ) return GLBX.MYARRAY;

 procedure create_card(surl varchar2, photo_id in integer, scard in varchar2 default null, card_shape in integer, msg in varchar2 default null,
                       p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null, p6 in date default null, p1a in varchar2 default null, p2a in varchar2 default null,
                       footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2);
 procedure gcard_menu( surl varchar2,scard in integer, msg in varchar2, owner_id in integer, c1rec in customer_account%ROWTYPE, pfx in THEME%ROWTYPE, stype in integer,
                       footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, ltype in varchar2);
 procedure display_year( surl in varchar2, ltype in varchar2, pfx in theme%ROWTYPE, cusrec in customer_account%ROWTYPE, main_image in integer, tnails in GLBX.MYARRAY, yyyy in varchar2, style in varchar2, clr in varchar2, nmb_months_across in integer, date_array in GLBX.MYARRAY, date_summary in GLBX.MYARRAY, date_type in varchar2 );
 procedure display_month( surl in varchar2, ltype in varchar2, pfx in theme%ROWTYPE, cusrec in customer_account%ROWTYPE, tnail in integer, mon in varchar2, yyyy in varchar2, style in varchar2, clr in varchar2, date_array in GLBX.MYARRAY, date_type in varchar2 );
 procedure calendar_run(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure calendar_run_lbox(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure calendar_run_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure pricing_initiate(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure pricing_calculator( price in out number, calcrec in calculator_pricing_reference%ROWTYPE );
 procedure poll_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
 procedure reminder_main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );

 --
 -- Greeting Card API
 --

 procedure main_program(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2 )
 as
 begin
  -- Nothing Fancy about this Novelty API call
  create_card(surl=>surl,photo_id=>loc_id,card_shape=>1,footer_api=>footer_api,left_api_parm=>left_api_parm,current_page_number=>current_page_number,display_detail=>display_detail);

 exception when others then
  glbx.error_details( 'GCARD', 'MAIN_PROGRAM',errmsg=>sqlerrm);
 end main_program;

 function extract_email( surl varchar2,em in varchar2 )
  return GLBX.MYARRAY
 as
  retem	GLBX.MYARRAY;
  ctr	integer;
  ptr	integer;
  lptr	integer;
 begin
  ctr := 1;
  lptr := 0;
  loop
   ptr := nvl(instr(em,',',1,ctr),0);
   if ptr = 0
    then
     retem( ctr ) := substr(em,lptr+1);
     exit;
    else
     retem( ctr ) := substr(em,lptr+1,(ptr-lptr)-1);
   end if;
   lptr := ptr;
   ctr := ctr + 1;
  end loop;
  return( retem );
exception when others then
 glbx.error_details( 'GCARD', 'EXTRACT_EMAIL',errmsg=>sqlerrm,extdet=>EM);
end extract_email;

procedure create_card(surl varchar2, photo_id in integer, scard in varchar2 default null, card_shape in integer, msg in varchar2 default null,
                      p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null,
	              p4 in varchar2 default null, p5 in varchar2 default null, p6 in date default null, p1a in varchar2 default null, p2a in varchar2 default null,
	              footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2)
 as

 cursor c2(acid integer, photo_id integer) is select photo_master,version from umo where umo_id = photo_id and aid = acid;
 cursor c3(acid integer, enbl char) is
  select style_name
  from ecard_style
  where enbl = 'T' and
        (pid is null or
         (pid is not null and pid = (select pid from customer_account where aid = acid))
        )
  union all
  select es.style_name
  from ecard_style es, gcard_customer gc
  where enbl = 'F' and
        es.style_name = gc.style_name and
        gc.aid = acid
  order by 1;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 photo_name	varchar2(100);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 retem		GLBX.MYARRAY;
 ctr		integer;
 oth		integer;

 begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'GCARD.CREATE_CARD' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

  if pfx.gcard_external_call is not null
   then
    execute immediate 'begin ' || pfx.gcard_external_call || '.create_card(surl=>:surl, photo_id=>:photo_id, scard=>:scard, msg=>:msg, footer_api=>:footer_api, left_api_parm=>:left_api_parm, current_page_number=>:current_page_number, display_detail=>:display_detail ); end;'
     using surl, photo_id, scard, msg, footer_api, left_api_parm, current_page_number, display_detail;
    return;
  end if;

 open c2(owner_id,photo_id);
 fetch c2 into c2rec;
 close c2;
 retem := extract_email(surl,p2);
 if not retem.exists(1)
  then
   retem(1) := NULL;
 end if;
 photo_name := ump.uma_attribute( surl,photo_id, 'PHOTO','NAME');
 glbx.main_title( surl, nvl(msg,LNG2.GCARD_TXT_001),glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'D01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if p6 is not null
  then
    htp.header(3,htf.bold(LNG2.GCARD_TXT_025) || ' : ' || htf.italic( to_char(p6,LNG.MASK)),'CENTER' );
 end if;
 htp.p( '<CENTER>');
 htp.formopen( 'gcard.accept_create' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'PHOTO_ID', photo_id );
 htp.formhidden( 'SCARD', scard );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 --htp.formhidden( 'CARD_SHAPE', nvl(card_shape,'1') );
 htp.nl;

  htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
   htp.tablerowopen;
   htp.p( '<td valign="TOP">' );
  htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
   htp.tablerowopen;
     htp.tabledata( '*' || htf.bold(LNG2.GCARD_TXT_004));
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.formtext( 'P1A', 20, 100, p1a ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '*' || htf.bold(LNG.CST_TXT_143));
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.formtext( 'P1', 20, 100, nvl(p1,glbx.get_email(surl)) ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '*' || htf.bold(LNG.PHG_TXT_084) );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P2A', 20, 100, p2a ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( '*' || htf.bold(LNG2.GCARD_TXT_007) );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P2', 20, 1000, retem(1) ));
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P3' );
   if c1rec.enable_greetingcards = 'N'
    then
       tmp := tmp || htf.formselectoption( null );
    else
    for c3rec in c3(c1rec.aid,c1rec.enable_greetingcards) loop
     if c3rec.style_name = p3
 	 then
       tmp := tmp || htf.formselectoption( c3rec.style_name, 'SELECTED' );
 	 else
       tmp := tmp || htf.formselectoption( c3rec.style_name );
 	end if;
    end loop;
  end if;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.GCARD_TXT_008));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( tmp );
   htp.tablerowclose;
   tmp := htf.formselectopen( 'P4' );
   if p4 = LNG.SLD_TXT_021 then tmp := tmp || htf.formselectoption( LNG.SLD_TXT_021, 'SELECTED' ); else tmp := tmp || htf.formselectoption( LNG.SLD_TXT_021 ); end if;
   if p4 = LNG.SLD_TXT_022 then tmp := tmp || htf.formselectoption(LNG.SLD_TXT_022, 'SELECTED'  ); else tmp := tmp || htf.formselectoption( LNG.SLD_TXT_022); end if;
   if p4 = LNG.SLD_TXT_023 or p4 is null then tmp := tmp || htf.formselectoption( LNG.SLD_TXT_023, 'SELECTED' ); else tmp := tmp || htf.formselectoption( LNG.SLD_TXT_023 ); end if;
   if p4 = LNG.SLD_TXT_024 then tmp := tmp || htf.formselectoption( LNG.SLD_TXT_024, 'SELECTED'  ); else tmp := tmp || htf.formselectoption( LNG.SLD_TXT_024 ); end if;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.GCARD_TXT_009) );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( tmp );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.GCARD_TXT_010));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formtextareaopen( 'P5', 4, 20, cattributes=>'WRAP="VIRTUAL"' ) || p5 || htf.formtextareaclose);
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.italic( LNG2.GCARD_ALT_037));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.GCARD_TXT_002) || ' ' ||  card_img( surl,0, nvl(card_shape,'1') ));
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( card_img(surl,card_shape,1) || card_img(surl,card_shape,2) || card_img(surl,card_shape,3) || card_img(surl,card_shape,4) );
   htp.tablerowclose;
   ctr := 10;
   htp.tablerowopen;
    htp.tabledata( '&nbsp;' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNG2.GCARD_TXT_012) );
   htp.tablerowclose;
   for j in 2..retem.last loop
    if retem.exists(j)
     then
      if retem(j) is not null
       then
        ctr := ctr - 1;
        htp.tablerowopen;
         htp.tabledata( htf.formtext( 'EXT', 20, 1000, retem(j)));
        htp.tablerowclose;
      end if;
     end if;
   end loop;
   if ctr > 0
    then
     for j in 1..ctr loop
        htp.tablerowopen;
         htp.tabledata( htf.formtext( 'EXT', 20, 1000 ));
        htp.tablerowclose;
     end loop;
   end if;
   htp.tablerowopen;
   if scard is null
    then
      htp.tabledata(htf.formsubmit( 'ACTION', LNG2.GCARD_BUT_011 ),cattributes=>'ALIGN="CENTER"');
    else
      htp.tabledata(htf.formsubmit( 'ACTION', LNG.CST_BUT_017 ) || htf.formsubmit( 'ACTION', LNG.CST_BUT_016 ),cattributes=>'ALIGN="CENTER"');
   end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</td>' );
  htp.p( '<td valign="TOP">' );
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0' );
   htp.tablerowopen;
   if scard is null
    then
      htp.tabledata(htf.formsubmit( 'ACTION', LNG2.GCARD_BUT_011 ),cattributes=>'ALIGN="CENTER"');
    else
      htp.tabledata(htf.formsubmit( 'ACTION', LNG.CST_BUT_017 ) || htf.formsubmit( 'ACTION', LNG.CST_BUT_016 ),cattributes=>'ALIGN="CENTER"');
   end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.tableopen( cattributes=>'align="CENTER" valign="MIDDLE" cellpadding=0 cellspacing=0 bordercolordark="#' || pfx.tnail_border_colour || '" bordercolorlight="#' || pfx.tnail_border_colour_l || '" border=' || to_char(nvl(pfx.tnail_border,0)) );
   htp.tablerowopen;
   if c2rec.photo_master.width > c2rec.photo_master.height
    then
     oth := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / c2rec.photo_master.width) * c2rec.photo_master.height;
     htp.tabledata( '<IMG BORDER=0 WIDTH=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=VERSION&parm2=' || c2rec.version ||
                    '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(owner_id) || '" ' ||
                    'ALT="' || photo_name || '">', cattributes=>'align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" style="text-align: center;"' );
    else
     oth := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / c2rec.photo_master.height ) * c2rec.photo_master.width;
     htp.tabledata( '<IMG BORDER=0 HEIGHT=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || photo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=VERSION&parm2=' || c2rec.version ||
                    '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || to_char(owner_id) || '" ' ||
                    'ALT="' || photo_name || '">', cattributes=>'align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + nvl(pfx.tnail_width,0)) || '" style="text-align: center;"' );
   end if;
   htp.tablerowclose;
   htp.tablerowopen;
  htp.tableclose;
  htp.p( '</td>' );
  htp.tablerowclose;
  htp.tableclose;

 htp.formclose;
 htp.nl;
 htp.p( '</CENTER>');
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GCARD', 'CREATE_CARD',c1rec.pid,owner_id,photo_id,errmsg=>sqlerrm);
end create_card;

function card_img( surl varchar2,currcard in integer, card_id in integer )
 return varchar2
as
begin
if currcard = 0
 then
	if card_id = 1
	 then
	  return(htf.img( DECS.IMAGE_LOCATION || 'admin/card1.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_031 ));
	elsif card_id = 2
	 then
	  return(htf.img( DECS.IMAGE_LOCATION || 'admin/card2.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_032 ));
	elsif card_id = 3
	 then
	  return(htf.img( DECS.IMAGE_LOCATION || 'admin/card3.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_033 ));
	elsif card_id = 4
	 then
	  return(htf.img( DECS.IMAGE_LOCATION || 'admin/card4.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_034 ));
	end if;
 else
 if currcard = card_id
  then
	if card_id = 1
	 then
	  return(htf.formradio('CARD_SHAPE','1','CHECKED') || htf.img( DECS.IMAGE_LOCATION || 'admin/card1.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_031 ));
	elsif card_id = 2
	 then
	  return(htf.formradio('CARD_SHAPE','2','CHECKED') || htf.img( DECS.IMAGE_LOCATION || 'admin/card2.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_032 ));
	elsif card_id = 3
	 then
	  return(htf.formradio('CARD_SHAPE','3','CHECKED') || htf.img( DECS.IMAGE_LOCATION || 'admin/card3.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_033 ));
	elsif card_id = 4
	 then
	  return(htf.formradio('CARD_SHAPE','4','CHECKED') || htf.img( DECS.IMAGE_LOCATION || 'admin/card4.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_034 ));
	end if;
  else
	if card_id = 1
	 then
	  return(htf.formradio('CARD_SHAPE','1') || htf.img( DECS.IMAGE_LOCATION || 'admin/card1.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_031 ));
	elsif card_id = 2
	 then
	  return(htf.formradio('CARD_SHAPE','2') || htf.img( DECS.IMAGE_LOCATION || 'admin/card2.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_032 ));
	elsif card_id = 3
	 then
	  return(htf.formradio('CARD_SHAPE','3') || htf.img( DECS.IMAGE_LOCATION || 'admin/card3.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_033 ));
	elsif card_id = 4
	 then
	  return(htf.formradio('CARD_SHAPE','4') || htf.img( DECS.IMAGE_LOCATION || 'admin/card4.gif',cattributes=>'border=0',calt=>LNG2.GCARD_ALT_034 ));
	end if;
  end if;
 end if;
exception when others then
 glbx.error_details( 'GCARD', 'CARD_IMG',errmsg=>sqlerrm,extdet=>'CARD_ID:' || card_id || ' CURRCARD:' || currcard);
end card_img;


procedure accept_create( surl varchar2, photo_id in integer, scard in integer, action in varchar2, card_shape in integer,
                         p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p1a in varchar2, p2a in varchar2, ext in GLBX.MYARRAY,
                         footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2)
 as

 cursor c2(photo_id integer,acid integer) is
  select um.extras.photo_name photo_name,um.photo_master.width width, um.photo_master.height height
  from umo um
  where umo_id = photo_id and
        um.extras.enabled_phg = 'TRUE' and
		aid = acid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		varchar2(2000);
 new_scard	integer;
 cexp		integer;
 np2		varchar2(32767);
 np5		varchar2(4000);

 begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'GCARD.ACCEPT_CREATE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 np2 := p2;

 for j in ext.first..ext.last loop
  if ext(j) is not null
   then
    begin
     np2 := np2 || ',' || ext(j);
    exception
     when others then exit;
    end;
  end if;
 end loop;
 np2 := substr(np2,1,1000);
 np5 := glbx.censor(p5,1000);
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c2(photo_id,owner_id);
 fetch c2 into c2rec;
 close c2;
 if action = LNG.CST_BUT_016 and scard is not null
  then
   gcard_menu(surl,scard,LNG2.GCARD_TXT_026,owner_id,c1rec,pfx,stype,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail, ltype=>ltype);
   htp.htmlclose;
   return;
 end if;
 if p1 is null or p1a is null
  then
   create_card(surl,photo_id,scard,card_shape,LNG2.GCARD_TXT_027,p1,np2,p3,p4,np5,null,p1a,p2a,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
   return;
 end if;
 if np2 is null or p2a is null
  then
   create_card(surl,photo_id,scard,card_shape,LNG2.GCARD_TXT_028,p1,np2,p3,p4,np5,null,p1a,p2a,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
   return;
 end if;
 if scard is null
  then
   cexp := glbx.extract_master_parameter('CARD_EXPIRY');
   select s_ecard.nextval into new_scard from dual;
   insert into ecard(eid,aid,phid,created,expires,style,border,photo_name,from_email,sendto,greeting,width,height,is_accessed,shape,nfrom_email,nsendto)
    values
     (new_scard,c1rec.aid,photo_id,sysdate,sysdate+cexp,p3,p4,c2rec.photo_name,p1,np2,np5,c2rec.width,c2rec.height,'F',card_shape,p1a,p2a);
   insert into track_email(pid,aid,date_stored,track_type,email_address,made_by)
    values
	 (photo_id,c1rec.aid,sysdate,'GREETING CARD',np2,p1);
   commit;
   gcard_menu(surl,new_scard,LNG2.GCARD_TXT_029,owner_id,c1rec,pfx,stype,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail, ltype=>ltype);
  else
   update ecard
    set
	 from_email = p1,
	 sendto = np2,
	 nfrom_email = p1a,
	 nsendto = p2a,
	 style = p3,
	 border = p4,
	 greeting = np5,
	 shape = card_shape
   where eid = scard;
   commit;
   gcard_menu(surl,scard,LNG2.GCARD_TXT_020,owner_id,c1rec,pfx,stype,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail, ltype=>ltype);
 end if;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GCARD', 'ACCEPT_CREATE',c1rec.pid,owner_id,photo_id,errmsg=>sqlerrm);
end accept_create;

procedure gcard_menu( surl varchar2, scard in integer, msg in varchar2, owner_id in integer, c1rec in customer_account%ROWTYPE, pfx in THEME%ROWTYPE, stype in integer,
                      footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, ltype in varchar2)
as
begin
 glbx.main_title( surl, null, glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'D02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null
  then
   htp.p( '<CENTER>' );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   htp.tablerowopen;
   htp.tabledata(htf.header(2,msg, 'CENTER' ));
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
 end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.tabledata(htf.header(3,LNG2.GCARD_TXT_031, 'CENTER' ));
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formopen( 'gcard.accept_menu' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'SCARD', scard );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
  htp.formimage( 'ACTION_VIEW', DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'view.gif',cattributes=>'BORDER="0"'  );
  --htp.formsubmit( 'ACTION', 'View Greeting Card' );
  htp.nl;
  htp.formimage( 'ACTION_EDIT', DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'edit.gif',cattributes=>'BORDER="0"'  );
  --htp.formsubmit( 'ACTION', 'Edit Greeting Card' );
  htp.nl;
  htp.formimage( 'ACTION_SEND', DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'send.gif',cattributes=>'BORDER="0"' );
  --htp.formsubmit( 'ACTION', 'Send Greeting Card' );
  htp.nl;
  htp.formimage( 'ACTION_DEL', DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'del.gif',cattributes=>'BORDER="0"'  );
  --htp.formsubmit( 'ACTION', 'Delete Greeting Card' );
  htp.nl;
  htp.formimage( 'ACTION_RET', DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'ret.gif',cattributes=>'BORDER="0"'  );
  --htp.formsubmit( 'ACTION', 'Return to Photo Display' );
  htp.nl;
 htp.formclose;
 htp.p( '</CENTER>' );
exception when others then
 glbx.error_details( 'GCARD', 'GCARD_MENU',c1rec.pid,owner_id,errmsg=>sqlerrm,extdet=>'SCARD:' || scard);
end gcard_menu;

procedure accept_menu( surl varchar2, scard in integer, action_send in varchar2 default null, action_edit in varchar2 default null, action_view in varchar2 default null,
                       action_del in varchar2 default null, action_ret in varchar2 default null,
                       footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2)
 as
 cursor c2(scard integer,acid integer) is select * from ecard where eid = scard and aid = acid;
 cursor c3(acid integer) is select business_name,nvl(home_site,contact_email) cnt from photographer where pid in (select pid from customer_account where aid = acid);
 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 action		varchar2(40);
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

 begin

 if action_send is not null then action := 'Send Greeting Card';
 elsif action_edit is not null then action := 'Edit Greeting Card';
 elsif action_view is not null then action := 'View Greeting Card';
 elsif action_del is not null then action := 'Delete Greeting Card';
 elsif action_ret is not null then action := 'Return to Photo Display';
 end if;

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.ACCEPT_MENU' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, null, profid );
 --c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 if action = 'Return to Photo Display'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   if pfx.keep_lhf = 'L'
    then
     cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_032,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
    else
     --glbx.acct_home(surl=>surl,rnd=>to_char(sysdate,'SSSSS'),acid=>null);
      begin
      execute immediate
       'begin ' || footer_api ||
        '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>null);' ||
       'end;'
       using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail;
      exception when others then
       cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_032,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
      end;
   end if;
   return;
 end if;

 if action = 'Delete Greeting Card'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   delete from ecard where eid = scard;
   --cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_033,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
   if pfx.keep_lhf = 'L'
    then
     cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_033,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
    else
     --glbx.acct_home(surl=>surl,rnd=>to_char(sysdate,'SSSSS'),acid=>null);
     begin
      execute immediate
       'begin ' || footer_api ||
        '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>null);' ||
       'end;'
       using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail;
     exception when others then
     cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_033,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
     end;
   end if;
   return;
 end if;

 if action = 'Edit Greeting Card'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   create_card(surl,c2rec.phid,c2rec.eid,c2rec.shape,'Edit Greeting Card', c2rec.from_email, c2rec.sendto, c2rec.style, c2rec.border, c2rec.greeting, c2rec.expires, c2rec.nfrom_email, c2rec.nsendto,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail );
   return;
 end if;

 if action = 'Send Greeting Card'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   open c3(c1rec.aid);
   fetch c3 into c3rec;
   close c3;
   gcode(1) := 'NFROM_EMAIL';
   gparam(1) := c2rec.nfrom_email;
   gcode(2) := 'FROM_EMAIL';
   gparam(2) := c2rec.from_email;
   gcode(3) := 'LOGIN_ADDRESS';
   gparam(3) := glbx.extract_master_parameter('ECARD_LINK') || '?scard=' || scard || '&pw=' || glbx.encrypt( DECS.GREETING_CARD_KEYWORD || c2rec.eid, TRUE );
   gcode(4) := 'PHOTOGRAPHER';
   gparam(4) := c3rec.business_name;
   gcode(5) := 'PHOTOGRAPHER_SITE';
   gparam(5) := c3rec.cnt;
   gcode(6) := 'SIGNATURE';
   gparam(6) := glbx.extract_master_parameter('MAIL SIGNATURE');
   glbx.send( gcode, gparam, 'greeting_card.tmp', c2rec.sendto, LNG2.GCARD_TXT_034, c2rec.from_email,ltype=>ltype,own_id=>c1rec.aid,is_attachment=>TRUE, scode=>'GC1', v_pid=>c1rec.pid, v_aid=>c1rec.aid, v_profile_id=>profid);
   --cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_035 || c2rec.sendto,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
   if pfx.keep_lhf = 'L'
    then
     cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_035 || c2rec.sendto,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
    else
     --glbx.acct_home(surl=>surl,rnd=>to_char(sysdate,'SSSSS'),acid=>null);
     begin
      execute immediate
       'begin ' || footer_api ||
        '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
       'end;'
       using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,c1rec.aid;
      exception when others then
       cst.disp_acct_photo(surl=>surl,photo_id=>c2rec.phid,msg=>LNG2.GCARD_TXT_035 || c2rec.sendto,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail);
      end;
   end if;
   return;
 end if;

 if action = 'View Greeting Card'
  then
   open c2(scard,c1rec.aid);
   fetch c2 into c2rec;
   close c2;
   view_card(c2rec.eid,glbx.encrypt( DECS.GREETING_CARD_KEYWORD || c2rec.eid, TRUE ),TRUE,stype,ltype,surl=>surl);
   htp.nl;
   htp.p( '<CENTER>' );
   htp.formopen( 'gcard.disp_menu' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'SCARD', scard );
   htp.formhidden( 'FOOTER_API', footer_api );
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
   htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
   htp.formhidden( 'DISPLAY_DETAIL', display_detail );
   htp.formsubmit( null, 'Display Greeting Card Menu' );
   htp.formclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 end if;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'GCARD', 'ACCEPT_MENU',c1rec.pid,c1rec.aid,c2rec.phid,errmsg=>sqlerrm,extdet=>'SCARD:' || scard || ' ACTION:' || action);
end accept_menu;

procedure disp_menu( surl varchar2,scard in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2 )
 as
 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'GCARD.DISP_MENU' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 htp.p( '<CENTER>' );
 gcard_menu(surl,scard,null,owner_id,c1rec,pfx,stype,footer_api=>footer_api,left_api_parm=>left_api_parm, current_page_number=>current_page_number, display_detail=>display_detail, ltype=>ltype);
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GCARD', 'DISP_MENU',c1rec.pid,owner_id,errmsg=>sqlerrm,extdet=>'SCARD:' || scard);
end disp_menu;

procedure view_card( scard in varchar2, pw in varchar2, bypass in boolean default FALSE, stype in integer default 1, ltype in varchar2 default 'EXTERNAL', surl varchar2 default null )
as
 cursor c1(scard integer) is select * from ecard where eid=scard;
 cursor c2(acid integer) is select * from customer_account where aid=acid;
 cursor c3(styl varchar2) is select * from ecard_style where style_name = styl;
 cursor c4(acid integer) is select * from photographer where pid = (select pid from customer_account where aid=acid);
 cursor c5(thm varchar2) is select gcard_external_call from theme where theme_name = thm;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 brd		integer;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

 procedure greeting_display_photo(surl varchar2)
 as
 begin
   htp.p( '<TD>' );
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=' || brd );
   htp.tablerowopen;
   if c1rec.width > c1rec.height
    then
     htp.tabledata( '<IMG BORDER=0 WIDTH=' || glbx.sctrl('DEFAULT','PHOTO_WIDTH',stype) || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                    '&parm1=LOGIN_TYPE&parm2=EXTERNAL&parm1=PASSWORD&parm2=' || replace(pw,'3D',null) || '&parm1=GREETING_CARD&parm2=' || replace(scard,'3D',null) || '" ' ||
                    'ALT="' || c1rec.photo_name || '">' );
    else
     htp.tabledata( '<IMG BORDER=0 HEIGHT=' || glbx.sctrl('DEFAULT','PHOTO_WIDTH',stype) || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.phid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                    '&parm1=LOGIN_TYPE&parm2=EXTERNAL&parm1=PASSWORD&parm2=' || replace(pw,'3D',null) || '&parm1=GREETING_CARD&parm2=' || replace(scard,'3D',null) || '" ' ||
                    'ALT="' || c1rec.photo_name || '">' );
   end if;
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</TD>' );
 end;

 procedure greeting_display_message( surl varchar2,show_msg in varchar2 )
 as
 begin
  if show_msg = 'FULL'
   then
    htp.tabledata( '<FONT SIZE="+3">' || htf.italic(c1rec.nsendto) || htf.nl || htf.italic(c1rec.greeting) || '</FONT>' || htf.nl || htf.nl ||
	               '<FONT SIZE="+2">' || 'From' || ': ' || htf.bold( c1rec.nfrom_email ) || '(' || htf.italic( c1rec.from_email ) || ')' || '</FONT>'
	            || htf.nl || htf.mailto( c1rec.from_email, 'Click here to Reply to:' || c1rec.nfrom_email ) );
  elsif show_msg = 'TOP'
   then
    htp.tabledata( '<FONT SIZE="+3">' || htf.italic(c1rec.nsendto) || htf.nl || htf.italic(c1rec.greeting) || '</FONT>' );
  elsif show_msg = 'BOTTOM'
   then
    htp.tabledata( '<FONT SIZE="+2">' || 'From' || ': ' || htf.bold( c1rec.nfrom_email ) || '('|| htf.italic( c1rec.from_email ) || ')' || '</FONT>'
                   || htf.nl || htf.mailto( c1rec.from_email, 'Click here to Reply to:' || c1rec.nfrom_email ) );
  end if;

 end;

begin
 htp.htmlopen;
  if replace(pw,'3D',null) <> glbx.encrypt( DECS.GREETING_CARD_KEYWORD || replace(scard,'3D',null), TRUE )
   then
    htp.header( 2, LNG2.GCARD_TXT_036, 'CENTER' );
	htp.htmlclose;
	return;
  end if;

  open c1(replace(scard,'3D',null));
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    htp.header( 2, 'Card does not Exist Anymore', 'CENTER' );
    htp.htmlclose;
    return;
  end if;
  close c1;

  open c3(c1rec.style);
  fetch c3 into c3rec;
  close c3;

  if sysdate > c1rec.expires
   then
    htp.header( 2, LNG2.GCARD_TXT_037, 'CENTER' );
    htp.htmlclose;
    return;
  end if;

  open c2(c1rec.aid);
  fetch c2 into c2rec;
  close c2;

  open c5(c2rec.theme_name);
  fetch c5 into c5rec;
  close c5;

  if c5rec.gcard_external_call is not null
   then
    execute immediate 'begin ' || c5rec.gcard_external_call || '.view_card(scard=>:scard, pw=>:pw, stype=>:stype, ltype=>:ltype, surl=>:surl ); end;'
     using scard, pw, stype, ltype, surl;
    return;
  end if;

  if c1rec.border = LNG.SLD_TXT_021 then brd := 0;
  elsif c1rec.border = LNG.SLD_TXT_022 then brd := 1;
  elsif c1rec.border = LNG.SLD_TXT_023 then brd := 5;
  elsif c1rec.border = LNG.SLD_TXT_024 then brd := 10;
  end if;

  htp.p('<HEAD><meta http-equiv="imagetoolbar" content="no">' );
  htp.p('<SCRIPT LANGUAGE="JavaScript">
              function click(e) {
              var message="' || LNG.GLB_TXT_104 || '";
              if ( navigator.appName.substring ( 0, 9 ) == "Microsoft") {
              if (event.button == 2) {
              alert(message);
              return false;
              }
              }
              if (document.layers || navigator.appName.substring ( 0, 9 ) == "Netscape") {
              if (e.which==3) {
              alert(message);
              return false;
              }
              }
              }
function trap()
  {
  if(document.images)
    {
    for(i=0;i<document.images.length;i++)
      {
      document.images[i].onmousedown = click;
      document.images[i].onmouseup = click;
      }
    }
  }
// End -->
</SCRIPT>');
htp.p('</HEAD>');

  htp.p( '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || 'gcard/' || c3rec.ec_image || '" TEXT="#' || c3rec.ec_font || '" link="#' || c3rec.ec_font || '" vlink="#' || c3rec.ec_font || '" alink="#' || c3rec.ec_font || '" onLoad="trap()">' );
  htp.p( '<CENTER>' );
  htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0');
 if c1rec.shape = 1
  then
	 htp.tablerowopen;
	 greeting_display_photo(surl);
	 greeting_display_message( surl,'FULL' );
	 htp.tablerowclose;
 elsif c1rec.shape = 2
  then
	 htp.tablerowopen;
	 greeting_display_message( surl,'FULL' );
	 greeting_display_photo(surl);
	 htp.tablerowclose;
 elsif c1rec.shape = 3
  then
	 htp.tablerowopen;
	 greeting_display_message( surl,'TOP' );
	 htp.tablerowclose;
	 htp.tablerowopen;
	 greeting_display_photo(surl);
	 htp.tablerowclose;
	 htp.tablerowopen;
	 greeting_display_message( surl,'BOTTOM' );
	 htp.tablerowclose;
 elsif c1rec.shape = 4
  then
	 htp.tablerowopen;
	 greeting_display_message( surl,'FULL' );
	 htp.tablerowclose;
	 htp.tablerowopen;
	 greeting_display_photo(surl);
	 htp.tablerowclose;
 end if;
 htp.tableclose;

 open c4(c1rec.aid);
 fetch c4 into c4rec;
 close c4;

 if not bypass and c1rec.is_accessed = 'F'
  then
   update ecard
    set is_accessed = 'T'
	 where eid = replace(scard,'3D',null);
   commit;
   gcode(1) := 'NSENDTO';
   gparam(1) := c1rec.nsendto;
   gcode(2) := 'SENDTO';
   gparam(2) := c1rec.sendto;
   gcode(3) := 'LOGIN_ADDRESS';
   gparam(3) := glbx.extract_master_parameter('ECARD_LINK') || '?scard=' || replace(scard,'3D',null) || '&pw=' || glbx.encrypt( DECS.GREETING_CARD_KEYWORD || c1rec.eid, TRUE );
   gcode(4) := 'PHOTOGRAPHER';
   gparam(4) := c4rec.business_name;
   gcode(5) := 'PHOTOGRAPHER_SITE';
   gparam(5) := nvl(c4rec.home_site,c4rec.contact_email);
   gcode(6) := 'SIGNATURE';
   gparam(6) := glbx.extract_master_parameter('MAIL SIGNATURE');
   glbx.send( gcode, gparam, 'greeting_accept.tmp', c1rec.from_email,LNG2.GCARD_ALT_035, glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE, scode=>'GA1', v_pid=>c2rec.pid, v_aid=>c2rec.aid);
 end if;
 if not bypass then insert into ecard_log(eid,date_viewed) values (replace(scard,'3D',null),sysdate); end if;
 commit;

 --
 -- Photographer Logo, Piction Logo, and Screen Resize
 --

 htp.tableopen( cattributes=>'cellpadding=5 cellspacing=5 border=0 ');
  htp.tablerowopen;

  if c4rec.home_site is null
   then
    htp.tabledata(htf.bold(c4rec.business_name));
  else
   htp.tabledata(htf.bold(htf.anchor2(glbx.adjust_for_http(c4rec.home_site),c4rec.business_name,ctarget=>'_top')));
  end if;

  if not bypass
   then
    htp.tabledata( htf.italic( LNG2.GCARD_ALT_036 ));
    htp.tabledata( htf.anchor( 'gcard.view_card?surl=' || glbx.rndsurl(surl) || '&scard=' || replace(scard,'3D',null) || '&PW=' || pw || '&stype=1','[SVGA]' ));
    htp.tabledata( htf.anchor( 'gcard.view_card?surl=' || glbx.rndsurl(surl) || '&scard=' || replace(scard,'3D',null) || '&PW=' || pw || '&stype=2','[XGA]' ));
    htp.tabledata( htf.anchor( 'gcard.view_card?surl=' || glbx.rndsurl(surl) || '&scard=' || replace(scard,'3D',null) || '&PW=' || pw || '&stype=3','[SXGA]' ));
    htp.tabledata( htf.anchor( 'gcard.view_card?surl=' || glbx.rndsurl(surl) || '&scard=' || replace(scard,'3D',null) || '&PW=' || pw || '&stype=4','[UGA]' ));
    htp.tabledata( htf.anchor( 'gcard.view_card?surl=' || glbx.rndsurl(surl) || '&scard=' || replace(scard,'3D',null) || '&PW=' || pw || '&stype=5','[SUGA]' ));
  end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.p( '<FONT SIZE="-1">' || glbx.userpref( c2rec.pid,c2rec.aid,'IMG_DISC') || '<FONT>' );
 htp.nl;
 htp.nl;
 htp.anchor2( glbx.extract_master_parameter('PICTION_HOME_PAGE'), '<FONT SIZE="-1">' || glbx.extract_master_parameter('PAGE_TITLE') || '<FONT>', ctarget=>'_top' );
 htp.nl;

 --
 --
 --

 htp.p( '</CENTER>' );
 if not bypass then htp.p( '</BODY>' ); htp.htmlclose; end if;
exception when others then
 glbx.error_details( 'GCARD', 'VIEW_CARD',errmsg=>sqlerrm,extdet=>'SCARD:' || replace(scard,'3D',null) );
end view_card;

--
-- Add Audio API
--

procedure add_audio(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as
 cursor c2(acid integer) is
  select sum(nvl(to_number(um.audio_original.description),0)) sf,nvl(count(um.audio_original.description),0) cf
  from umo um
  where aid = acid and
        nvl(to_number(um.audio_original.description),0) > 0;
 cursor c3(acid integer, photo_id integer) is
  select um.umo_id,um.audio_original.description file_size
  from umo um
  where aid=acid and
        umo_id = photo_id and
        um.audio_original.description is not null;
 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 audmsg		varchar2(1000);
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 audio_ext	boolean;
 v_quota	ump.quotalist;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.ADD_AUDIO' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if ltype not in ('OWNER','PROFILE') then return; end if; -- Trying to break in.
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 open c2(owner_id);
 fetch c2 into c2rec;
 close c2;
 audio_ext := TRUE;
 open c3(owner_id,loc_id);
 fetch c3 into c3rec;
 if c3%NOTFOUND
  then
   audio_ext := FALSE;
 end if;
 close c3;

 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, lng.CST_ALT_027,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'C12',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.bold(htf.italic( lng.CST_TXT_152 ));
 htp.bold(htf.italic( lng.CST_TXT_153 ));
 htp.nl;

 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'gcard.aload', cattributes=>'enctype="multipart/form-data"' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'FOOTER_API', footer_api  );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 htp.formhidden( 'ACID', acid  );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );

 if msg is not null
  then
   glbx.header_msg( msg );
   htp.nl;
 end if;

 ump.get_quota( surl,ltype, owner_id, ltype, owner_id, v_quota );
 v_quota.max_storage := v_quota.max_storage * 1024;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  if audio_ext
   then
    htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_154 )),cattributes=>pfx.qbground);
     htp.tabledata(htf.bold( LNG.PHG_TXT_025 || ': ' || c3rec.file_size || ' bytes' ),cattributes=>pfx.qcbground);
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_155 )),cattributes=>pfx.qbground);
     htp.tabledata(htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c3rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOWX&parm1=DISPLAY_WHAT&parm2=ORIGINAL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=OVERRIDE&parm2=AUDIO',
	                        htf.img( DECS.IMAGE_LOCATION || 'adminc/audio.gif',cattributes=>'border=0',calt=>lng.CST_ALT_086 ),ctarget=>'AUDIO_WINDOW'),cattributes=>pfx.qcbground);
    htp.tablerowclose;
   else
    htp.tablerowopen;
     htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
     htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_156 )),cattributes=>pfx.qcbground);
    htp.tablerowclose;
  end if;
  htp.tablerowopen;
   htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_157 )),cattributes=>pfx.qbground);
   htp.tabledata(htf.bold( c2rec.cf ),cattributes=>pfx.qcbground);
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_158 )),cattributes=>pfx.qbground);
   htp.tabledata(htf.bold( to_char(v_quota.max_storage - nvl(c2rec.sf,0)) || ' bytes' || htf.nl ||
                 to_char(round((v_quota.max_storage - nvl(c2rec.sf,0))/1024)) || ' Kb' ),cattributes=>pfx.qcbground);
  htp.tablerowclose;

   htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_159 )),cattributes=>pfx.qbground);
     htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>pfx.qcbground );
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_160 )),cattributes=>pfx.qbground);
     audmsg := ump.uma_attribute( surl,loc_id,'AUDIO','NAME');
     htp.tabledata( htf.formtext( 'P1', 20, 500, audmsg ),cattributes=>pfx.qcbground);
   htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 if audio_ext
  then
    htp.formsubmit( 'ACTION', lng.CST_BUT_149 );
    htp.formsubmit( 'ACTION', lng.CST_BUT_150 );
  else
    htp.formsubmit( 'ACTION', lng.CST_BUT_161 );
 end if;
 htp.formsubmit( 'ACTION', lng.CST_BUT_016 );
 htp.formclose;
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'GCARD', 'ADD_AUDIO',owner_id,errmsg=>sqlerrm,extdet=>'loc_id:' || loc_id );
end add_audio;

procedure aload(surl in varchar2, file in varchar2, p1 in varchar2, action in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2 )
as

 cursor c1(loc_id integer) is select umo_scene_id from umo where umo_id = loc_id;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 extn		varchar2(20);
 audio_id	integer;
 parm1		ump.parameters;
 parm2		ump.parameters;
 retval		varchar2(100);
 new_id		integer;
 um_scene_id	integer;
 msg		varchar2(2000);
 newid_arr	ump.myarray_int;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GCARD.ALOAD', iscust=>TRUE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if ltype <> 'OWNER' then return; end if; -- Trying to break in.
 if action = 'Cancel'
  then
   cst.acct_details(surl);
   return;
 end if;

 if action = LNG.CST_BUT_150
  then
   update umo um
   set um.audio_original = ORDSYS.ORDAudio(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL)
   where um.umo_id = loc_id and
         aid = owner_id;
   delete from umo_index
   where umo_id = loc_id and
         aid = owner_id and
         attribute_id in (select attribute_id from umo_attributes where umo_type = 'AUDIO' );
   delete from umo_attribute
   where umo_id = loc_id and
         attribute_id in (select attribute_id from umo_attributes where umo_type = 'AUDIO' );
   commit;
   gcard.add_audio(surl,nvid,loc_id,footer_api,left_api_parm,current_page_number,display_detail,acid,first_parameter,called_from,nvl(msg,LNG.GLB_TXT_045) );
   return;
 end if;

 if action = LNG.CST_BUT_149
  then
   update umo um
   set um.audio_original = ORDSYS.ORDAudio(NULL,ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,empty_clob(),NULL,NULL,NULL,NULL,NULL,NULL)
   where um.umo_id = loc_id and
         aid = owner_id;
   commit;
 end if;

 open c1(loc_id);
 fetch c1 into um_scene_id;
 close c1;

        parm1(1)  := 'AID';
        parm2(1)  := to_char(owner_id);
        parm1(2)  := 'OBJECT_TYPE';
        parm2(2)  := 'AUDIO';
        parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
        parm2(3)  := 'UPLOAD';
        parm1(4)  := 'FILE_NAME';
        parm2(4)  := file;
        parm1(5)  := 'STORE_ORIGINAL';
        parm2(5)  := 'TRUE';
        parm1(6)  := 'CREATE_THUMBNAIL';
        parm2(6)  := 'FALSE';
        parm1(7) := 'KEEP_STATUS';
        parm2(7) := 'LOAD AGAIN';
        parm1(8) := 'ORIGINAL_LOCATION';
        parm2(8) := file;
        parm1(9) := 'PARENT_UMO_ID';
        parm2(9) := NULL;
        parm1(10) := 'SCENE_ID';
        parm2(10) := to_char(um_scene_id);
        parm1(11) := 'UMO_OWNER';
        parm2(11) := 'OWNER';
        parm1(12) := 'BYPASS_QUOTA_CHECK';
        parm2(12) := 'FALSE';
        parm1(13) := 'OWS_NAME';
        parm2(13) := file;
        parm1(14) := 'PHOTOGRAPHER';
        parm2(14) := 'TRUE';
        parm1(15) := 'NAME';
        parm2(15) := nvl(p1,'No Name');
        parm1(16) := 'UMO_ID';
        parm2(16) := to_char(loc_id);
        ump.load_uma(surl,parm1,parm2,retval,newid_arr); new_id := newid_arr(1);

        gcard.add_audio(surl,loc_id,footer_api,left_api_parm,current_page_number,display_detail,acid,first_parameter,called_from,nvl(retval,LNG.GLB_TXT_046) );

exception when others then
 glbx.error_details( 'GCARD', 'ALOAD',errmsg=>sqlerrm,extdet=>'loc_id:' || loc_id || ' FILE:' || file || ' P1:' || p1 || ' ACTION:' || action);
end aload;

--
-- Calendar API
--

procedure display_month( surl in varchar2, ltype in varchar2, pfx in theme%ROWTYPE, cusrec in customer_account%ROWTYPE, tnail in integer, mon in varchar2, yyyy in varchar2, style in varchar2, clr in varchar2, date_array in GLBX.MYARRAY, date_type in varchar2 )
as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;
 umrec	c1%ROWTYPE;

 fday	integer;
 lday	integer;
 ldate	date;
 ctr	integer;
 dcol	varchar2(100);
 dcol2	varchar2(100);
 dcol3	varchar2(100);

 function check_date( d1 in varchar2, mon in varchar2, yyyy in varchar2, date_array in GLBX.MYARRAY, date_type in varchar2 )
  return varchar2
 as
 begin
  if date_array.count = 0 or nvl(date_type,'NONE') = 'NONE' then return( d1 ); end if;
  for j in date_array.first..date_array.last loop
   if upper(date_array(j)) = upper((d1 || '-' || mon || '-' || yyyy))
    then
     if date_type = 'BOLD'
      then
       return( htf.bold( d1 ));
      else
       return( htf.anchor( date_type || '&dt=' || d1 || '-' || mon || '-' || yyyy, d1 ));
     end if;
   end if;
  end loop;
  return( d1 );
 end check_date;

begin
if style = 'WEEKEND'
 then
  dcol2 := NULL;
 else
  dcol2 := 'BGCOLOR=#' || clr;
end if;

if style = 'BLANK'
 then
  dcol := NULL;
  dcol2 := NULL;
 else
  dcol := 'BGCOLOR=#' || clr;
end if;

if style = 'CHEQUERBOARD'
 then
  dcol := NULL;
  dcol2 := NULL;
  dcol3 := 'BGCOLOR=#' || clr;
end if;

fday := to_number(to_char(to_date( '01-' || mon || '-' || yyyy, 'DD-MON-YYYY' ),'D'));
ldate := last_day(to_date( '01-' || mon || '-' || yyyy, 'DD-MON-YYYY' ));
lday := to_number(to_char(ldate,'DD'));
ctr := 0;
htp.tableopen;
 if tnail is not null
  then
   htp.tablerowopen;
   open c1(tnail);
   fetch c1 into umrec;
   close c1;
   htp.p( '<TD ALIGN="CENTER" valign="MIDDLE">' );
       glbx.image_matte(pfx,umrec.photo_thumbnail.width,umrec.photo_thumbnail.height,
                        null,
                        '<IMG BORDER=0 WIDTH=' || umrec.photo_thumbnail.width || ' HEIGHT=' || umrec.photo_thumbnail.height || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || cusrec.aid || '&parm1=VERSION&parm2=' || umrec.version ||
                        '" ALT="' || umrec.extras.photo_name || '">', null );
   htp.p( '</TD>' );
   htp.tablerowclose;
 end if;

 htp.tablerowopen;
 htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
 htp.bold( initcap( mon ));
 htp.nl;
htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
 htp.tablerowopen;
  htp.tabledata( 'S', cattributes=>dcol );
  htp.tabledata( 'M' );
  htp.tabledata( 'T', cattributes=>dcol2 );
  htp.tabledata( 'W' );
  htp.tabledata( 'T', cattributes=>dcol2 );
  htp.tabledata( 'F' );
  htp.tabledata( 'S', cattributes=>dcol );
 htp.tablerowclose;
 htp.tablerowopen;
 for j in 1..(fday-1) loop
  if j = 1
   then
    htp.tabledata( '&nbsp;', cattributes=>dcol );
   elsif j in (3,5)
    then
     htp.tabledata( '&nbsp;', cattributes=>dcol2 );
    else
     htp.tabledata( '&nbsp;' );
  end if;
 end loop;
 for j in fday..7 loop
  ctr := ctr + 1;
  if style = 'CHEQUERBOARD'
   then
    if mod(ctr,2) = 1 then htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol3 ); else htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol ); end if;
   else
    if j in (1,7)
     then
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol );
    elsif j in (3,5)
     then
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol2 );
     else
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type) );
    end if;
  end if;
 end loop;
 htp.tablerowclose;
 htp.tablerowopen;
 for j in 1..7 loop
  ctr := ctr + 1;
  if style = 'CHEQUERBOARD'
   then
    if mod(ctr,2) = 1 then htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol3 ); else htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol ); end if;
   else
    if j in (1,7)
     then
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol );
    elsif j in (3,5)
     then
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol2 );
     else
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type) );
    end if;
  end if; end loop;
 htp.tablerowclose;
 htp.tablerowopen;
 for j in 1..7 loop
  ctr := ctr + 1;
  if style = 'CHEQUERBOARD'
   then
    if mod(ctr,2) = 1 then htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol3 ); else htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol ); end if;
   else
    if j in (1,7)
     then
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol );
    elsif j in (3,5)
     then
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol2 );
     else
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type) );
    end if;
  end if; end loop;
 htp.tablerowclose;
 htp.tablerowopen;
 for j in 1..7 loop
  ctr := ctr + 1;
  if style = 'CHEQUERBOARD'
   then
    if mod(ctr,2) = 1 then htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol3 ); else htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol ); end if;
   else
    if j in (1,7)
     then
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol );
    elsif j in (3,5)
     then
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol2 );
     else
      htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type) );
    end if;
  end if; end loop;
 htp.tablerowclose;
 htp.tablerowopen;
 for j in 1..7 loop
  ctr := ctr + 1;
  if ctr > lday
   then
    if j in (1,7)
     then
      htp.tabledata( '&nbsp;', cattributes=>dcol );
    elsif j in (3,5)
     then
      htp.tabledata( '&nbsp;', cattributes=>dcol2 );
     else
      htp.tabledata( '&nbsp;' );
    end if;
   else
    if style = 'CHEQUERBOARD'
     then
      if mod(ctr,2) = 1 then htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol3 ); else htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol ); end if;
     else
      if j in (1,7)
       then
        htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol );
      elsif j in (3,5)
       then
        htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type), cattributes=>dcol2 );
       else
        htp.tabledata( check_date(ctr,upper(mon),yyyy,date_array,date_type) );
      end if;
    end if;
  end if;
 end loop;
 htp.tablerowclose;
 htp.tableclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
htp.tableclose;

end display_month;

procedure display_year( surl in varchar2, ltype in varchar2, pfx in theme%ROWTYPE, cusrec in customer_account%ROWTYPE, main_image in integer, tnails in GLBX.MYARRAY, yyyy in varchar2, style in varchar2, clr in varchar2, nmb_months_across in integer, date_array in GLBX.MYARRAY, date_summary in GLBX.MYARRAY, date_type in varchar2 )
as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;
 umrec	c1%ROWTYPE;

begin

if nmb_months_across = 3
 then
  htp.tableopen;
   if main_image is not null
    then
     open c1(main_image);
     fetch c1 into umrec;
     close c1;
     htp.tablerowopen;
     if date_array.count = 0
      then
       htp.p( '<TD COLSPAN="3" valign="MIDDLE" ALIGN="CENTER">' );
      else
       htp.p( '<TD COLSPAN="4" valign="MIDDLE" ALIGN="CENTER">' );
     end if;
     -- Image here
     glbx.image_matte(pfx,umrec.photo_master.width,umrec.photo_master.height,
                      null,
                      '<IMG BORDER=0 WIDTH=' || umrec.photo_master.width || ' HEIGHT=' || umrec.photo_master.height || ' SRC="' ||
                      'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || cusrec.aid || '&parm1=VERSION&parm2=' || umrec.version ||
                      '" ALT="' || umrec.extras.photo_name || '">', null );
     htp.tablerowclose;
   end if;

   htp.tablerowopen;
    htp.tabledata( htf.header( 3, yyyy, 'CENTER' ), cattributes=>'colspan=3 align="CENTER"' );
    if date_array.count > 0
     then
      htp.p( '<TD ROWSPAN="5" VALIGN="TOP" ALIGN="LEFT">' );
      htp.strong( 'Reminder Dates');
      htp.nl;
      for j in date_summary.first..date_summary.last loop
       htp.bold( date_array(j) );
       htp.nl;
       htp.italic( date_summary(j));
       htp.nl;
       htp.nl;
      end loop;
      htp.p( '</TD>' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(1), mon=>'JAN', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(2), mon=>'FEB', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(3), mon=>'MAR', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(4), mon=>'APR', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(5), mon=>'MAY', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(6), mon=>'JUN', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(7), mon=>'JUL', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(8), mon=>'AUG', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(9), mon=>'SEP', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(10), mon=>'OCT', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(11), mon=>'NOV', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(12), mon=>'DEC', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

elsif nmb_months_across = 4
 then
  htp.tableopen;
   if main_image is not null
    then
     open c1(main_image);
     fetch c1 into umrec;
     close c1;
     htp.tablerowopen;
     if date_array.count = 0
      then
       htp.p( '<TD COLSPAN="4" valign="MIDDLE" ALIGN="CENTER">' );
      else
       htp.p( '<TD COLSPAN="5" valign="MIDDLE" ALIGN="CENTER">' );
     end if;
     -- Image here
     glbx.image_matte(pfx,umrec.photo_master.width,umrec.photo_master.height,
                      null,
                      '<IMG BORDER=0 WIDTH=' || umrec.photo_master.width || ' HEIGHT=' || umrec.photo_master.height || ' SRC="' ||
                      'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || cusrec.aid || '&parm1=VERSION&parm2=' || umrec.version ||
                      '" ALT="' || umrec.extras.photo_name || '">', null );
     htp.tablerowclose;
   end if;
   htp.tablerowopen;
    htp.tabledata( htf.header( 3, yyyy, 'CENTER' ), cattributes=>'colspan=4 align="CENTER"' );
    if date_array.count > 0
     then
      htp.p( '<TD ROWSPAN="4" VALIGN="TOP" ALIGN="LEFT">' );
      htp.header( 4, 'Reminder Dates', 'CENTER' );
      htp.nl;
      for j in date_summary.first..date_summary.last loop
       htp.bold( date_array(j) );
       htp.nl;
       htp.italic( date_summary(j));
       htp.nl;
       htp.nl;
      end loop;
      htp.p( '</TD>' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(1), mon=>'JAN', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(2), mon=>'FEB', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(3), mon=>'MAR', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(4), mon=>'APR', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(5), mon=>'MAY', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(6), mon=>'JUN', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(7), mon=>'JUL', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(8), mon=>'AUG', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(9), mon=>'SEP', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(10), mon=>'OCT', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(11), mon=>'NOV', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.p( '<TD ALIGN="CENTER" VALIGN="BOTTOM">' );
    display_month( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec, tnail=>tnails(12), mon=>'DEC', yyyy=>yyyy, style=>style, clr=>clr, date_array=>date_array, date_type=>date_type );
   htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;
end if;

end display_year;

procedure calendar(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as
begin

 if called_from in ('MAIN','HOME')
  then
   calendar_run(surl,nvid,loc_id,footer_api,left_api_parm,current_page_number,display_detail,acid,first_parameter,called_from );

 elsif called_from = 'LIGHTBOX'
  then
   calendar_run_lbox(surl,nvid,loc_id,footer_api,left_api_parm,current_page_number,display_detail,acid,first_parameter,called_from );

 elsif called_from = 'PREFERENCES'
  then
   calendar_run_pref(surl,nvid,loc_id,acid,first_parameter,called_from );

 end if;

exception when others then
 glbx.error_details( 'GCARD', 'CALENDAR',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end calendar;

procedure calendar_run(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(acid integer) is select * from customer_calendar where aid = acid;
 cursor c2(acid integer) is select * from customer_reminder_dates where aid = acid order by reminder_date;

 main_image	integer;

 c1rec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 show_date	glbx.myarray;
 show_summ	glbx.myarray;
 tnail_list	glbx.myarray;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.CALENDAR_RUN' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 open c1( cusrec.aid );
 fetch c1 into c1rec;
 close c1;

 if first_parameter = 'VARIABLE'
  then
   main_image := loc_id;
 end if;

 for c2rec in c2(c1rec.aid) loop
  show_date(c2%ROWCOUNT) := to_char(c2rec.reminder_date,LNG.MASK);
  show_summ(c2%ROWCOUNT) := c2rec.reminder_message;
 end loop;

 c1rec.calendar_type := nvl(c1rec.calendar_type,'BLANK');
 c1rec.display_width := nvl(c1rec.display_width,3);

 tnail_list(1) := c1rec.jan_image;
 tnail_list(2) := c1rec.feb_image;
 tnail_list(3) := c1rec.mar_image;

 tnail_list(4) := c1rec.apr_image;
 tnail_list(5) := c1rec.may_image;
 tnail_list(6) := c1rec.jun_image;

 tnail_list(7) := c1rec.jul_image;
 tnail_list(8) := c1rec.aug_image;
 tnail_list(9) := c1rec.sep_image;

 tnail_list(10) := c1rec.oct_image;
 tnail_list(11) := c1rec.nov_image;
 tnail_list(12) := c1rec.dec_image;

 glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype), stype=>1, sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 display_year( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec,
               main_image=>main_image, tnails=>tnail_list, yyyy=>to_char(sysdate,'YYYY'),style=>c1rec.calendar_type, clr=>pfx.ord_qcbground,
               nmb_months_across=>c1rec.display_width, date_array=>show_date, date_summary=>show_summ, date_type=>'BOLD' );
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GCARD', 'CALENDAR_RUN',cusrec.pid,owner_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end calendar_run;

procedure calendar_run_lbox(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(acid integer) is select * from customer_calendar where aid = acid;
 cursor c2(acid integer) is select * from customer_reminder_dates where aid = acid order by reminder_date desc;
 cursor c3(acid integer, boxid integer) is select * from lightbox_header where aid = acid and lightid = boxid;
 cursor c4(sess_id integer, boxid integer) is select * from lightbox where nvl(lightid,0) = nvl(boxid,0) and sessid = sess_id order by order_by;

 main_image	integer;

 c1rec		c1%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 ctr		integer;
 ctr2		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 show_date	glbx.myarray;
 show_summ	glbx.myarray;
 tnail_list	glbx.myarray;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.CALENDAR_RUN_LBOX' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 open c1( cusrec.aid );
 fetch c1 into c1rec;
 close c1;

 for c2rec in c2(c1rec.aid) loop
  show_date(c2%ROWCOUNT) := to_char(c2rec.reminder_date,LNG.MASK);
  show_summ(c2%ROWCOUNT) := c2rec.reminder_message;
 end loop;

 c1rec.calendar_type := nvl(c1rec.calendar_type,'BLANK');
 c1rec.display_width := nvl(c1rec.display_width,3);

 tnail_list(1) := c1rec.jan_image;
 tnail_list(2) := c1rec.feb_image;
 tnail_list(3) := c1rec.mar_image;

 tnail_list(4) := c1rec.apr_image;
 tnail_list(5) := c1rec.may_image;
 tnail_list(6) := c1rec.jun_image;

 tnail_list(7) := c1rec.jul_image;
 tnail_list(8) := c1rec.aug_image;
 tnail_list(9) := c1rec.sep_image;

 tnail_list(10) := c1rec.oct_image;
 tnail_list(11) := c1rec.nov_image;
 tnail_list(12) := c1rec.dec_image;

 main_image := c1rec.main_image;

 -- Overwrite default thumbnails with those in the lightbox
 ctr := 1;
 ctr2 := 1;
 loop

  for c4rec in c4( owner_id, loc_id ) loop
   if ctr > 12 then exit; end if;
   tnail_list(ctr) := c4rec.umo_id;
   ctr := ctr + 1;
  end loop;
  if ctr > 12 then exit; end if;
  ctr2 := ctr2 + 1;
  if ctr2 > 12 then exit; end if; -- Infinite Loop Protection

 end loop;

 glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype), stype=>1, sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 display_year( surl=>surl, ltype=>ltype, pfx=>pfx, cusrec=>cusrec,
               main_image=>main_image, tnails=>tnail_list, yyyy=>to_char(sysdate,'YYYY'),style=>c1rec.calendar_type, clr=>pfx.ord_qcbground,
               nmb_months_across=>c1rec.display_width, date_array=>show_date, date_summary=>show_summ, date_type=>'BOLD' );
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GCARD', 'CALENDAR_RUN_LBOX',cusrec.pid,owner_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end calendar_run_lbox;

procedure calendar_run_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(phgid integer, acid integer) is select * from customer_calendar where aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);
 cursor c2(acid integer) is select umo_id,um.extras.film_name film_name from umo um where aid=acid and umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','RELATIONAL') order by um.extras.film_name;
 cursor c3(acid integer) is select reminder_date, reminder_message from customer_reminder_dates where aid = acid order by reminder_date;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

 procedure lov_month(txt varchar2, key_val in integer, pval in varchar2)
 as
 begin
  htp.tablerowopen;
   htp.tabledata(htf.bold(txt),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
   htp.formselectopen( pval );
   htp.formselectoption( NULL );
    for c2rec in c2(c1rec.aid) loop
     if c2rec.umo_id = key_val
      then
       htp.formselectoption( c2rec.film_name, 'SELECTED', cattributes=>'VALUE="' || c2rec.umo_id || '"' );
      else
       htp.formselectoption( c2rec.film_name, cattributes=>'VALUE="' || c2rec.umo_id || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 end lov_month;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GCARD.CALENDAR_RUN_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Manage Calendar',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Calendar Management' );
 htp.nl;
 htp.p( '<CENTER>' );
 open c1(owner_id,acid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   insert into customer_calendar(aid,calendar_type,display_width) values (acid,'BLANK',3);
   commit;
   c1rec.aid := acid;
   c1rec.calendar_type := 'BLANK';
   c1rec.display_width := 3;
  else
   close c1;
 end if;

 htp.formopen( 'gcard.accept_calendar_pref' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
  htp.tablerowopen;
   htp.tabledata(htf.bold('Type of Calendar to Display'),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
   htp.formselectopen( 'P1' );
   if nvl(c1rec.calendar_type,'BLANK') = 'BLANK'
    then
     htp.formselectoption( 'BLANK', 'SELECTED' );
    else
     htp.formselectoption( 'BLANK' );
   end if;
   if nvl(c1rec.calendar_type,'BLANK') = 'WEEKEND'
    then
     htp.formselectoption( 'WEEKEND', 'SELECTED' );
    else
     htp.formselectoption( 'WEEKEND' );
   end if;
   if nvl(c1rec.calendar_type,'BLANK') = 'CHEQUERBOARD'
    then
     htp.formselectoption( 'CHEQUERBOARD', 'SELECTED' );
    else
     htp.formselectoption( 'CHEQUERBOARD' );
   end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Number of Months per Row'),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
   if c1rec.display_width = '3'
    then
     htp.formradio( 'P2', '3', 'CHECKED' );
    else
     htp.formradio( 'P2', '3' );
   end if;
   htp.p( ' ' || '3' || ' ' );
   if c1rec.display_width = '4'
    then
     htp.formradio( 'P2', '4', 'CHECKED' );
    else
     htp.formradio( 'P2', '4' );
   end if;
   htp.p( ' ' || '4' );
   htp.p( '</TD>' );
  htp.tablerowclose;
  lov_month('Main Image', c1rec.main_image, 'P3');
 htp.tableclose;
 htp.nl;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=0' );
  lov_month('January Thumbnail', c1rec.jan_image, 'P4');
  lov_month('February Thumbnail', c1rec.feb_image, 'P4');
  lov_month('March Thumbnail', c1rec.mar_image, 'P4');
  lov_month('April Thumbnail', c1rec.apr_image, 'P4');
  lov_month('May Thumbnail', c1rec.may_image, 'P4');
  lov_month('June Thumbnail', c1rec.jun_image, 'P4');
  lov_month('July Thumbnail', c1rec.jul_image, 'P4');
  lov_month('August Thumbnail', c1rec.aug_image, 'P4');
  lov_month('September Thumbnail', c1rec.sep_image, 'P4');
  lov_month('October Thumbnail', c1rec.oct_image, 'P4');
  lov_month('November Thumbnail', c1rec.nov_image, 'P4');
  lov_month('December Thumbnail', c1rec.dec_image, 'P4');
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.bold( 'Reminder Dates' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold('Day Month<BR>(DD-MON)'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Reminder Details'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  for c3rec in c3(c1rec.aid) loop
   htp.tablerowopen;
    htp.tabledata(htf.formtext( 'P5', 10, 10, to_char(c3rec.reminder_date,'DD-MON')),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formtext( 'P6', 40, 4000, c3rec.reminder_message ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
   htp.tablerowclose;
  end loop;
  for j in 1..5 loop
   htp.tablerowopen;
    htp.tabledata(htf.formtext( 'P5', 10, 10),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formtext( 'P6', 40, 4000 ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Modify Calendar Values' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'GCARD', 'CALENDAR_RUN_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end calendar_run_pref;

procedure accept_calendar_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 dt		date;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GCARD.ACCEPT_CALENDAR_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 update customer_calendar
  set
   calendar_type = p1,
   display_width = p2,
   main_image = p3,
   jan_image = p4(1),
   feb_image = p4(2),
   mar_image = p4(3),
   apr_image = p4(4),
   may_image = p4(5),
   jun_image = p4(6),
   jul_image = p4(7),
   aug_image = p4(8),
   sep_image = p4(9),
   oct_image = p4(10),
   nov_image = p4(11),
   dec_image = p4(12)
 where aid = acid and aid = (select aid from customer_account where aid = acid and pid = owner_id);

 delete from customer_reminder_dates where aid = acid;
 for j in p5.first..p5.last loop
  begin dt := to_date( p5(j) || '-' || to_char(sysdate,'YYYY'),'DD-MON-YYYY'); exception when others then dt := NULL; end;
  if dt is not null
   then
    begin
     insert into customer_reminder_dates(aid,reminder_date,reminder_message) values (acid,dt,p6(j));
    exception
     when others then null;
    end;
  end if;
 end loop;

 commit;

 calendar_run_pref( surl, nvid, loc_id, acid, first_parameter, called_from, 'Details Updated' );

exception when others then
 glbx.error_details( 'GCARD', 'ACCEPT_CALENDAR_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_calendar_pref;

procedure pricing(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as
begin

 if called_from = 'MAIN'
  then
   pricing_initiate(surl,nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'LIGHTBOX'
  then
    pricing_initiate(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'PREFERENCES'
  then
   -- XXX Add security bits
   htp.bold( 'Calculator Tables' );
   htp.nl;
   htp.nl;
   htp.anchor( 'oltp.display_screen?surl=' || surl || '&sname=' || replace('Calculator Media',' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY&acid=' || acid, 'Media' );
   htp.nl;
   htp.nl;
   htp.anchor( 'oltp.display_screen?surl=' || surl || '&sname=' || replace('Calculator Image Size',' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY&acid=' || acid, 'Image Size' );
   htp.nl;
   htp.nl;
   htp.anchor( 'oltp.display_screen?surl=' || surl || '&sname=' || replace('Calculator Circulation',' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY&acid=' || acid, 'Circulation' );
   htp.nl;
   htp.nl;
   htp.anchor( 'oltp.display_screen?surl=' || surl || '&sname=' || replace('Calculator Industry Use',' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY&acid=' || acid, 'Industry Use' );
   htp.nl;
   htp.nl;
   htp.anchor( 'oltp.display_screen?surl=' || surl || '&sname=' || replace('Calculator Region',' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY&acid=' || acid, 'Region Use' );
   htp.nl;
   htp.nl;
   htp.anchor( 'oltp.display_screen?surl=' || surl || '&sname=' || replace('Calculator Period',' ','+') || '&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=QUERY&acid=' || acid, 'Period Use' );


 end if;

exception when others then
 glbx.error_details( 'GCARD', 'PRICING',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end pricing;

function extract_meta_value( sub_cat varchar2, bftr in varchar2 )
  return varchar2
 as
  cursor c1( sub_cat varchar2, bftr varchar2 ) is select * from umo_attributes where sub_category like '%' || sub_cat and nvl(business_feature,'|') = nvl(bftr,'|');
  cursor c2( attribid integer ) is
   select *
   from novelty_values
   where (parm_type = '1' and parm1 = to_char(attribid)) or
         (parm_type = '3' and substr(parm3,2,instr(parm3,'}')-2) = to_char(attribid)) or
         (parm_type = '3' and substr(parm3,2,instr(parm3,']')-2) = to_char(attribid));

  c1rec	 c1%ROWTYPE;
  vl	 varchar2(4000);

 begin
  open c1(sub_cat,bftr);
  fetch c1 into c1rec;
  close c1;
  vl := NULL;
  for c2rec in c2( c1rec.attribute_id ) loop
   if c2rec.parm_type = '1' then return( c2rec.parm2 ); end if;
   if substr(c2rec.parm3,1,1) = '{' and vl is null then vl := substr(c2rec.parm3,instr(c2rec.parm3,'}')+1); end if;
   if substr(c2rec.parm3,1,1) = '[' then vl := substr(c2rec.parm3,instr(c2rec.parm3,']')+1); end if;
  end loop;
  return( vl );
end extract_meta_value;

function extract_lov( tbl varchar2, id integer )
  return varchar2
 as
  vl	varchar2(4000);
 begin
  execute immediate 'select ' || tbl || '_type from calculator_' || tbl || ' where ' || tbl || '_id = :1'
   into vl
    using id;
  return( vl );
 exception
  when others then return( NULL );
end extract_lov;

-- Overloaded. Called when a meta data screen has been completed
procedure pricing(surl in varchar2, acid in integer, called_from in varchar2, callid in integer, first_parameter in varchar2 )
as

 cursor c1 is select * from novelty_values;
 cursor c2(v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c3(acid integer, boxid integer) is select * from lightbox_header where aid = acid and lightid = boxid;
 cursor c4(sess_id integer, boxid integer) is select * from lightbox where nvl(lightid,0) = nvl(boxid,0) and sessid = sess_id order by order_by;
 cursor c5(nm varchar2) is select novelty_id from novelty_definition where display_name = nm;

 calcrec	calculator_pricing_reference%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 umrec		umo%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 price		number;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 audio_api 	varchar2(1000);
 video_api 	varchar2(1000);
 relational_api	varchar2(1000);
 blueprint_api	varchar2(1000);
 document_api 	varchar2(1000);
 anch		varchar2(32767);


begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.PRICING' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 glbx.main_title( surl, 'Pricing Calculator', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>'L', finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Pricing Calculator' );
 htp.p( '<CENTER>' );
 htp.nl;
 /*
 for cxrec in (select * from novelty_values) loop
  htp.p( cxrec.parm_type || '-' || cxrec.parm1 || '-' || cxrec.parm2 || '-' || cxrec.parm3 );
  htp.nl;
 end loop;
 for c1rec in c1 loop
  htp.p( c1rec.parm_type || '-' || c1rec.parm1 || '-' || c1rec.parm2 || '-' || c1rec.parm3 );
  htp.nl;
 end loop;
 */

 calcrec.media_id := extract_meta_value( 'MEDIA TYPE',cusrec.theme_type );
 calcrec.industry_use_id := extract_meta_value( 'INDUSTRY USE',cusrec.theme_type );
 calcrec.image_size_id := extract_meta_value( 'IMAGE SIZE',cusrec.theme_type );
 calcrec.circulation_id := extract_meta_value( 'CIRCULATION',cusrec.theme_type );
 calcrec.is_credited := extract_meta_value( 'CREDITED',cusrec.theme_type );
 calcrec.region_id := extract_meta_value( 'REGIONAL',cusrec.theme_type );
 calcrec.period_id := extract_meta_value( 'PERIOD',cusrec.theme_type );
 --begin calcrec.period := extract_meta_value( 'PERIOD PUB' ); exception when others then calcrec.period := 1; end;
 calcrec.publication_name := extract_meta_value( 'PUBLICATION',cusrec.theme_type );
 begin calcrec.start_date := extract_meta_value( 'START DATE',cusrec.theme_type ); exception when others then calcrec.start_date := sysdate; end;

 htp.bold( 'Please Confirm Usage Details' );
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
  if called_from = 'MAIN'
   then
    open c2( callid );
    fetch c2 into umrec;
    close c2;
    cst.display_thumbnail(surl,ltype,umrec,theme_rec,pfx,null,null,1,null,null,document_api,video_api,audio_api,relational_api,blueprint_api,acid);
  elsif called_from = 'LIGHTBOX'
   then
    open c3( cusrec.aid, callid );
    fetch c3 into c3rec;
    close c3;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
    for c4rec in c4(owner_id, callid) loop
     if mod(c4%ROWCOUNT,3) = 1
      then
       if c4%ROWCOUNT > 1 then htp.tablerowclose; end if;
       htp.tablerowopen;
     end if;
     htp.p( '<TD>' );
     open c2( c4rec.umo_id );
     fetch c2 into umrec;
     close c2;
     cst.display_thumbnail(surl,ltype,umrec,theme_rec,pfx,null,null,1,null,null,document_api,video_api,audio_api,relational_api,blueprint_api,acid);
     htp.p( '</TD>' );
    end loop;
    htp.tablerowclose;
    htp.tableclose;
  end if;
  htp.p( '</TD>' );
  htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
 htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=0' );
  htp.tablerowopen;
   htp.tabledata( 'Media' );
   htp.tabledata( htf.bold(extract_lov( 'MEDIA', calcrec.media_id )) ) ;
  htp.tablerowclose;
  htp.tablerowopen;
  if calcrec.is_credited = 'T'
   then
    htp.tabledata( 'Credited' );
    else
    htp.tabledata( 'Not Credited' );
   end if;
   htp.tabledata( '&nbsp;' ) ;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Image Size' );
   htp.tabledata( htf.bold(extract_lov( 'IMAGE_SIZE', calcrec.image_size_id )) ) ;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Circulation' );
   htp.tabledata( htf.bold(extract_lov( 'CIRCULATION', calcrec.circulation_id )) ) ;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Industry Use' );
   htp.tabledata( htf.bold(extract_lov( 'INDUSTRY_USE', calcrec.industry_use_id )) ) ;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Region' );
   htp.tabledata( htf.bold(extract_lov( 'REGION', calcrec.region_id )) ) ;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Period' );
   htp.tabledata( htf.bold(to_char(calcrec.start_date,'DDTh Month YYYY') || ' for ' || extract_lov( 'PERIOD', calcrec.period_id )) ) ;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Publication' );
   htp.tabledata( htf.bold(calcrec.publication_name) ) ;
  htp.tablerowclose;

  htp.tableclose;
  htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 pricing_calculator(price, calcrec );
 htp.nl;

 if called_from = 'MAIN'
  then
    htp.bold( 'The final price for this image based on your licencing parameters is ' || to_char(price,LNG.MONEY_FORMAT ));
 elsif called_from = 'LIGHTBOX'
  then
    htp.bold( 'The final price for each of the images in your lightbox called ' || nvl(c3rec.name, 'Default') || ' based on your licencing parameters is ' || to_char(price,LNG.MONEY_FORMAT ));
 end if;
 htp.nl;
 htp.nl;
 if pfx.fullimg_jscript_popup = 'T'
  then
    htp.p( '<a href="" onClick="self.close()">' || trim(translate(LNG.GLB_TXT_033,'[]','  ')) || '</a>' );
  else
   if called_from = 'LIGHTBOX'
    then
     htp.anchor( 'cst.mng_lightbox?surl=' || surl || '&footer_api=cst.disp_category&left_api_parm=&start_from=1&display_detail=&acid=' || acid, trim(translate(LNG.GLB_TXT_033,'[]','  ')) );
   end if;
 end if;
 htp.p( ' | ' );
 open c5('Pricing Calculator');
 fetch c5 into c5rec;
 close c5;

 htp.anchor( 'gcard.pricing?surl=' || surl || '&nvid=' || c5rec.novelty_id || '&called_from=' || replace(called_from,' ','+') ||'&loc_id=' || callid || '&footer_api=&left_api_parm=&current_page_number=&display_detail=&acid=' || acid || '&first_parameter=' || replace(first_parameter,' ','+'),'Change' );
 htp.p( ' | ' );
 anch := 'gcard.pricing_confirm?surl=' || surl || '&acid=' || acid || '&called_from=' || replace(called_from,' ','+') || '&callid=' || callid || '&first_parameter=' || replace(first_parameter,' ','+');
 for c1rec in c1 loop
  anch := anch || '&p_type=' || c1rec.parm_type || '&p1=' || c1rec.parm1 || '&p2=' || replace(c1rec.parm2,' ','+') || '&p3=' || replace(c1rec.parm3,' ','+');
 end loop;
 if called_from = 'LIGHTBOX'
  then
   htp.anchor( anch, 'Confirm' );
 elsif called_from = 'MAIN'
  then
   htp.anchor( anch, 'Confirm' );
 end if;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception
 when others then
   glbx.error_details( 'GCARD', 'PRICING', errmsg=>sqlerrm);
end pricing;

procedure pricing_initiate(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(acid integer, nvid integer) is
  select target_area
  from customer_meta_data_group
  where aid = acid and
        novelty_id = nvid and
        substr(target_area,1,1) = 'U' and
        to_number(substr(target_area,2)) =
         (select min(substr(target_area,2)) mn
          from customer_meta_data_group
          where aid = acid and
                novelty_id = nvid and
                substr(target_area,1,1) = 'U');

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 tgroup		varchar2(100);
 pfx		THEME%ROWTYPE;
 p1		GLBX.MYARRAY;
 p2		GLBX.MYARRAY;
 p3		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.PRICING_INITIATE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 p1(1) := NULL;
 p2(1) := NULL;
 p3(1) := NULL;
 open c1(cusrec.aid,nvid);
 fetch c1 into tgroup;
 close c1;

 if tgroup is null
  then
   htp.bold( 'Pricing Calculator Screen Not Found' );
   return;
 end if;
 -- Find the First Screen to Call
 delete from novelty_values;
 pbk.user_defined_screen( surl, cusrec.aid, tgroup, called_from, loc_id, p1, p2, p3 );

exception when others then
 glbx.error_details( 'GCARD', 'PRICING_INITIATE',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end pricing_initiate;

procedure pricing_confirm(surl in varchar2, acid in integer, called_from in varchar2, callid in integer, first_parameter in varchar2, p_type in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

 cursor c3(acid integer, boxid integer) is select * from lightbox_header where aid = acid and lightid = boxid;

 c3rec		c3%ROWTYPE;
 calcrec	calculator_pricing_reference%ROWTYPE;
 cusrec		customer_account%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 price		number;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 b2c_value	char(1);
 quick_exit	boolean;
 dummy		GLBX.MYARRAY;
 pricing1	GLBX.MYARRAY;
 pricing2	GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.PRICING_CONFIRM' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 for j in p_type.first..p_type.last loop
  insert into novelty_values (parm_type, parm1, parm2, parm3) values (p_type(j),p1(j),p2(j),p3(j));
 end loop;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 glbx.main_title( surl, 'Pricing Calculator', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>'L', finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Pricing Calculator' );
 htp.p( '<CENTER>' );
 htp.nl;

 calcrec.media_id := extract_meta_value( 'MEDIA TYPE',cusrec.theme_type );
 calcrec.industry_use_id := extract_meta_value( 'INDUSTRY USE',cusrec.theme_type );
 calcrec.image_size_id := extract_meta_value( 'IMAGE SIZE',cusrec.theme_type );
 calcrec.circulation_id := extract_meta_value( 'CIRCULATION',cusrec.theme_type );
 calcrec.is_credited := extract_meta_value( 'CREDITED',cusrec.theme_type );
 calcrec.period_id := extract_meta_value( 'PERIOD',cusrec.theme_type );
 calcrec.region_id := extract_meta_value( 'REGIONAL',cusrec.theme_type );
-- begin calcrec.period := extract_meta_value( 'PERIOD PUB' ); exception when others then calcrec.period := 1; end;
 calcrec.publication_name := extract_meta_value( 'PUBLICATION',cusrec.theme_type );
 begin calcrec.start_date := extract_meta_value( 'START DATE',cusrec.theme_type ); exception when others then calcrec.start_date := sysdate; end;

 pricing_calculator(price, calcrec );
 if called_from = 'LIGHTBOX'
  then
    open c3( cusrec.aid, callid );
    fetch c3 into c3rec;
    close c3;
    -- Is there a PK already?
    if c3rec.royalty_api_pk is null
     then
      select s_calculator_pricing_reference.nextval into c3rec.royalty_api_pk from dual;
      update lightbox_header set royalty_api_pk = c3rec.royalty_api_pk where aid = cusrec.aid and lightid = callid;
      insert into calculator_pricing_reference(pricing_pk) values (c3rec.royalty_api_pk);
    end if;
    update calculator_pricing_reference
     set
      media_id          =   calcrec.media_id,
      is_credited       =   calcrec.is_credited,
      image_size_id     =   calcrec.image_size_id,
      circulation_id    =   calcrec.circulation_id,
      start_date        =   calcrec.start_date,
      industry_use_id   =   calcrec.industry_use_id,
      region_id		=   calcrec.region_id,
      period_id		=   calcrec.period_id,
      publication_name  =   calcrec.publication_name
     where
     pricing_pk = c3rec.royalty_api_pk;

 elsif called_from = 'MAIN'
  then
    voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
    select s_calculator_pricing_reference.nextval into c3rec.royalty_api_pk from dual;
    insert into calculator_pricing_reference(pricing_pk) values (c3rec.royalty_api_pk);
    update calculator_pricing_reference
     set
      media_id          =   calcrec.media_id,
      is_credited       =   calcrec.is_credited,
      image_size_id     =   calcrec.image_size_id,
      circulation_id    =   calcrec.circulation_id,
      start_date        =   calcrec.start_date,
      industry_use_id   =   calcrec.industry_use_id,
      region_id		=   calcrec.region_id,
      period_id		=   calcrec.period_id,
      publication_name  =   calcrec.publication_name
     where
     pricing_pk = c3rec.royalty_api_pk;
    pricing1(1) := '0';
    pricing2(1) := '0';
    pricing1(2) := callid;
    pricing2(2) := 'IA[' || c3rec.royalty_api_pk || '~' || to_char(price) || ']' || callid;
    fname.process_purchase_order(surl, owner_id, profid, ltype, acid, 'INSERT', voidrec, cusrec, pricing1, dummy, pricing2, dummy, quick_exit );

 end if;
 htp.nl;

 commit;

 if calcrec.is_credited = 'T'
  then
   htp.bold( 'Credited' );
  else
   htp.bold( 'Not Credited' );
 end if;
 htp.bold( 'Image Size:' || extract_lov( 'IMAGE_SIZE', calcrec.image_size_id ));
 htp.nl;

 if called_from = 'LIGHTBOX'
  then
   htp.header( 3, 'Thank you' );
   htp.bold( 'The Lightbox has been updated to Reflect the new Pricing Structure' );
   htp.nl;
 elsif called_from = 'MAIN'
  then
   htp.header( 3, 'Thank you' );
   htp.bold( 'The Image has been added to your current order' );
   htp.nl;
 end if;

 htp.nl;
 if pfx.fullimg_jscript_popup = 'T' and called_from <> 'MAIN'
  then
   htp.p( '<a href="" onClick="self.close()">' || trim(translate(LNG.GLB_TXT_033,'[]','  ')) || '</a>' );
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception
 when others then
   glbx.error_details( 'GCARD', 'PRICING_CONFIRM', errmsg=>sqlerrm);
end pricing_confirm;

procedure pricing_calculator( price in out number, calcrec in calculator_pricing_reference%ROWTYPE )
as
begin
 price := 34.35 * nvl(calcrec.region_id,1) * (nvl(calcrec.industry_use_id,1)/0.32) * (nvl(calcrec.period_id,1)/.13);
end pricing_calculator;

procedure poll(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 price		number;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.POLL', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );

 if called_from in ('MAIN','HOME')
  then
   glbx.main_title( surl, 'Online Poll', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   htp.nl;
   glbx.online_poll(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, '30%' );
   htp.nl;
   htp.p( '</CENTER>' );
   htp.htmlclose;

 elsif called_from = 'LIGHTBOX'
  then
   null;

 elsif called_from = 'PREFERENCES'
  then
   poll_pref(surl,nvid,loc_id,acid,first_parameter,called_from );

 end if;

exception when others then
 glbx.error_details( 'GCARD', 'POLL',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end poll;

procedure poll_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(phgid integer, acid integer) is select * from online_poll_question where aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GCARD.POLL_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(owner_id,acid);
 fetch c1 into c1rec;
 close c1;
 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Manage Poll Question',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Manage Poll Question' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'gcard.accept_poll_pref' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );
 htp.formhidden( 'P3', null );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Poll Question' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formtext( 'P1', 50, 100, c1rec.poll_question),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Question or Series of Responses' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P2' );
     if nvl(c1rec.is_question,'T') = 'T'
      then
       htp.formselectoption( 'Question', 'SELECTED', cattributes=>'VALUE="T"' );
      else
       htp.formselectoption( 'Question', cattributes=>'VALUE="T"' );
     end if;
     if c1rec.is_question = 'F'
      then
       htp.formselectoption( 'Responses', 'SELECTED', cattributes=>'VALUE="F"' );
      else
       htp.formselectoption( 'Responses', cattributes=>'VALUE="F"' );
     end if;
    htp.formselectclose;
    htp.p( '</TD>' );
  htp.tablerowclose;
  if nvl(c1rec.is_question,'T') = 'T'
   then
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_045 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_yes),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( LNG.PHG_TXT_046 ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_no),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
   else
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 1' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_1),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_1),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 2' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_2),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_2),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 3' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_3),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_3),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 4' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_4),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_4),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 5' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_5),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_5),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 6' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_6),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_6),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 7' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_7),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_7),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 8' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_8),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_8),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 9' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_9),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_9),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold( 'Response 10' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.formtext( 'P3', 30, 100, c1rec.text_10),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tabledata(htf.bold( nvl(to_char(c1rec.answer_10),'0') ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', 'Modify Poll Details' );
 htp.formsubmit( 'ACTION', 'Reset Poll Values to Empty' );
 htp.formsubmit( 'ACTION', 'Delete Poll' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GCARD', 'POLL_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end poll_pref;

procedure accept_poll_pref(surl in varchar2, nvid in integer, loc_id in integer, acid in integer, first_parameter in varchar2, called_from in varchar2, action in varchar2, p1 in varchar2, p2 in varchar2, p3 in GLBX.MYARRAY )
as

 cursor c1(phgid integer, acid integer) is select * from online_poll_question where aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 ctr		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 np3		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'GCARD.ACCEPT_POLL_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if action = 'Delete Poll'
  then
   delete from online_poll_question where aid = acid and aid = (select aid from customer_account where aid=acid and pid=owner_id);

 elsif action = 'Reset Poll Values to Empty'
  then
   update online_poll_question
    set
     answer_yes = null,
     answer_no = null,
     answer_1 = null,
     answer_2 = null,
     answer_3 = null,
     answer_4 = null,
     answer_5 = null,
     answer_6 = null,
     answer_7 = null,
     answer_8 = null,
     answer_9 = null,
     answer_10 = null
   where aid = acid and aid = (select aid from customer_account where aid=acid and pid=owner_id);

 elsif action = 'Modify Poll Details'
  then
   if p2 = 'T'
    then
     update online_poll_question
      set
       poll_question = p1,
       is_question = p2
     where aid = acid and aid = (select aid from customer_account where aid=acid and pid=owner_id);
     if sql%NOTFOUND
      then
       insert into online_poll_question(poll_id,aid,poll_question,is_question) values (s_online_poll_question.nextval,acid,p1,p2);
     end if;
   else
     ctr := 0;
     for j in p3.first..p3.last loop
      if p3(j) is not null
       then
        ctr := ctr + 1;
        np3( ctr ) := p3(j);
      end if;
     end loop;
     ctr := ctr + 1;
     for j in ctr..10 loop
      np3(j) := NULL;
     end loop;
     update online_poll_question
      set
       poll_question = p1,
       is_question = p2,
       text_1 = np3(1),
       text_2 = np3(2),
       text_3 = np3(3),
       text_4 = np3(4),
       text_5 = np3(5),
       text_6 = np3(6),
       text_7 = np3(7),
       text_8 = np3(8),
       text_9 = np3(9),
       text_10 = np3(10)
     where aid = acid and aid = (select aid from customer_account where aid=acid and pid=owner_id);
     if sql%NOTFOUND
      then
       insert into online_poll_question(poll_id,aid,poll_question,is_question,text_1,text_2,text_3,text_4,text_5,text_6,text_7,text_8,text_9,text_10) values
       (s_online_poll_question.nextval,acid,p1,p2,np3(1),np3(2),np3(3),np3(4),np3(5),np3(6),np3(7),np3(8),np3(9),np3(10));
     end if;
   end if;

 end if;
 commit;
 poll_pref(surl,nvid,loc_id,acid,first_parameter,called_from, 'Details Modified' );

exception when others then
 glbx.error_details( 'GCARD', 'ACCEPT_POLL_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_poll_pref;

procedure reminder(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 price		number;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin

 if called_from in ('MAIN','HOME')
  then
   reminder_main(surl,nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'LIGHTBOX'
  then
   null;

 elsif called_from = 'PREFERENCES'
  then
   null;

 end if;

exception when others then
 glbx.error_details( 'GCARD', 'POLL',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end reminder;

procedure reminder_main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(acid integer, ltype varchar2) is select * from anniversary where aid = acid and login_type = ltype order by anniversary_type, anniversary_id;

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 price		number;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.REMINDER_MAIN', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 if ltype not in ('PROFILE','PROFILEG') then profid := cusrec.aid; end if;
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );

 glbx.main_title( surl, 'Anniversary Reminder',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Anniversary Reminder' );
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'gcard.accept_reminder' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Reminder<BR>Type' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tabledata(htf.bold( 'Reminder<BR>Time Period' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tabledata(htf.bold( 'How to be<BR>Contacted' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tabledata(htf.bold( 'Date of Anniversary<BR>Birthday or Event' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tabledata(htf.bold( 'Number of Days<BR>Before Event<BR>to be Notified' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tabledata(htf.bold( 'Reminder<BR>Message' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 for c1rec in c1(profid, ltype ) loop
  htp.tablerowopen;
   htp.formhidden( 'P0', c1rec.anniversary_id );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    if c1rec.anniversary_type = 'A'
     then
      htp.formselectoption( 'Anniversary', 'SELECTED', cattributes=>'VALUE="A"' );
     else
      htp.formselectoption( 'Anniversary', cattributes=>'VALUE="A"' );
    end if;
    if c1rec.anniversary_type = 'B'
     then
      htp.formselectoption( 'Birthday', 'SELECTED', cattributes=>'VALUE="B"' );
     else
      htp.formselectoption( 'Birthday', cattributes=>'VALUE="B"' );
    end if;
    if c1rec.anniversary_type = 'E'
     then
      htp.formselectoption( 'Event', 'SELECTED', cattributes=>'VALUE="E"' );
     else
      htp.formselectoption( 'Event', cattributes=>'VALUE="E"' );
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P2' );
    if c1rec.reminder_period = 'M'
     then
      htp.formselectoption( 'Every Month', 'SELECTED', cattributes=>'VALUE="M"' );
     else
      htp.formselectoption( 'Every Month', cattributes=>'VALUE="M"' );
    end if;
    if c1rec.reminder_period = 'Y'
     then
      htp.formselectoption( 'Every Year', 'SELECTED', cattributes=>'VALUE="Y"' );
     else
      htp.formselectoption( 'Every Year', cattributes=>'VALUE="Y"' );
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P3' );
    if c1rec.how_notify = 'E'
     then
      htp.formselectoption( 'Email', 'SELECTED', cattributes=>'VALUE="E"' );
     else
      htp.formselectoption( 'Email', cattributes=>'VALUE="E"' );
    end if;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P6A' );
    for j in 1..31 loop
     if to_number(to_char(c1rec.reminder_date,'DD')) = to_number(to_char(j))
      then
       htp.formselectoption( to_char(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
      else
       htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.formselectopen( 'P6B' );
    for j in 1..12 loop
     if to_number(to_char(c1rec.reminder_date,'MM')) = to_number(to_char(j))
      then
       htp.formselectoption( to_char(to_date('01-' || lpad(to_char(j),2,'0') || '-2000','DD-MM-YYYY'),'MON'), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
      else
       htp.formselectoption( to_char(to_date('01-' || lpad(to_char(j),2,'0') || '-2000','DD-MM-YYYY'),'MON'), cattributes=>'VALUE="' || to_char(j) || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.formselectopen( 'P6C' );
    if c1rec.reminder_period = 'M'
     then
      htp.formselectoption( NULL, 'SELECTED' );
     else
      htp.formselectoption( NULL );
    end if;
    for j in 1900..2020 loop
     if to_char(c1rec.reminder_date,'YYYY') = to_char(j) and c1rec.reminder_period <> 'M'
      then
       htp.formselectoption( to_char(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
      else
       htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P4' );
    for j in 1..10 loop
     if c1rec.reminder_before_days = to_char(j)
      then
       htp.formselectoption( to_char(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
      else
       htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata(htf.formtext( 'P5', 30, 4000, c1rec.reminder_message ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
 end loop;
 for j in 1..5 loop
  htp.tablerowopen;
   htp.formhidden( 'P0', null );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P1' );
    htp.formselectoption( NULL );
    htp.formselectoption( 'Anniversary', cattributes=>'VALUE="A"' );
    htp.formselectoption( 'Birthday', cattributes=>'VALUE="B"' );
    htp.formselectoption( 'Event', cattributes=>'VALUE="E"' );
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P2' );
    htp.formselectoption( 'Every Month', cattributes=>'VALUE="M"' );
    htp.formselectoption( 'Every Year', cattributes=>'VALUE="Y"' );
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P3' );
     htp.formselectoption( 'Email', cattributes=>'VALUE="E"' );
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P6A' );
    for j in 1..31 loop
     htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
    end loop;
    htp.formselectclose;
    htp.formselectopen( 'P6B' );
    for j in 1..12 loop
     htp.formselectoption( to_char(to_date('01-' || lpad(to_char(j),2,'0') || '-2000','DD-MM-YYYY'),'MON'), cattributes=>'VALUE="' || to_char(j) || '"' );
    end loop;
    htp.formselectclose;
    htp.formselectopen( 'P6C' );
    htp.formselectoption( NULL );
    for j in 1900..2020 loop
     if j = to_number(to_char(sysdate,'YYYY'))
      then
       htp.formselectoption( to_char(j), 'SELECTED', cattributes=>'VALUE="' || to_char(j) || '"' );
      else
       htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
     end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
    htp.formselectopen( 'P4' );
    for j in 1..10 loop
     htp.formselectoption( to_char(j), cattributes=>'VALUE="' || to_char(j) || '"' );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata(htf.formtext( 'P5', 30, 4000 ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', 'Update Details' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GCARD', 'REMINDER_MAIN',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end reminder_main;

procedure accept_reminder(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, action in varchar2,
                          p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6a in GLBX.MYARRAY, p6b in GLBX.MYARRAY, p6c in GLBX.MYARRAY)
as

 cursor c1(acid integer, ltype varchar2) is select * from anniversary where aid = acid and login_type = ltype order by anniversary_type, anniversary_id;

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 dt		date;
 sts		varchar2(100);
 txt		varchar2(4000);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GCARD.ACCEPT_REMINDER', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 if ltype not in ('PROFILE','PROFILEG') then profid := cusrec.aid; end if;

 delete from anniversary where aid = cusrec.aid and login_type = ltype;
 for j in p0.first..p0.last loop
  if p1(j) is not null
   then
    if p2(j) = 'M'
     then
      dt := to_date( p6a(j) || '-' || p6b(j) || '-' || '2000', 'DD-MM-YYYY' );
     else
      dt := to_date( p6a(j) || '-' || p6b(j) || '-' || p6c(j), 'DD-MM-YYYY' );
    end if;
    txt := glbx.censor(p5(j),4000);
    insert into anniversary(aid,login_type,anniversary_id,reminder_before_days,anniversary_type,reminder_period,how_notify,reminder_date,reminder_message)
     values
      (cusrec.aid,ltype,s_anniversary.nextval,p4(j),p1(j),p2(j),p3(j),dt,txt);
  end if;
 end loop;
 commit;

 reminder_main(surl,nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Anniversary Details Updated' );

exception when others then
 glbx.error_details( 'GCARD', 'ACCEPT_REMINDER',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_reminder;

end gcard;

/
