CREATE OR REPLACE package body WEBSYS.dapi
as
 TYPE TStyleRecord is RECORD (
    selector varchar2(100),
    properties varchar2(2000));
 TYPE TExtraStyles is VARRAY(256) OF TStyleRecord;

 GLOBAL_MY_STYLES         	TExtraStyles := TExtraStyles();
 GLOBAL_MY_STYLES_CTR     	integer := 0;
 GLOBAL_EXTERNAL_STYLESHEET 	varchar2( 200 ) := NULL;

 GLOBAL_STYLE             	varchar2(200);
 GLOBAL_STYLE_PARM        	varchar2(200);
 GLOBAL_RETURN_LINK       	varchar2(200);
 GLOBAL_MY_CLASS          	varchar2(200);
 GLOBAL_MY_FONT           	varchar2(200);
 GLOBAL_MY_SIZE           	varchar2(200);
 GLOBAL_MY_COLOUR         	varchar2(200);
 GLOBAL_BODY_ADDITION     	varchar2(200);

 procedure cookie_id( surl in varchar2, sts out varchar2, iscust in boolean default TRUE, ignore_cookie_check in boolean default FALSE )
 is

  cursor c1( id integer ) is select *  from login_session where sessid = id;
  cursor c3( id integer, surl varchar2 ) is select *  from login_session where securl = surl and sessid = id;

  c1rec		c1%ROWTYPE;
  id		varchar2(100);
  x		integer;
  ck		owa_cookie.cookie;
  timeout	integer;
  vsurl         varchar2(100);

 begin
  vsurl := surl;

  -- Check if Cookie Enabled and not a customer
  if not ignore_cookie_check and iscust
   then
    if glbx.extract_master_parameter('COOKIE_ENABLED') = 'TRUE'
     then
       ck := owa_cookie.get(nvl(glbx.extract_master_parameter('COOKIE_NAME'),'PICTION_COOKIE'));
       if ck.num_vals > 0
        then
         id := ck.vals(1);
         if id is not null and surl is not null and glbx.truncsurl(id) <> glbx.truncsurl(surl)
          then
            -- The Stored Cookie Value is greater than the one passed down. We should use the stored cookie value
            -- insert into temp values ('F2:' || vsurl || '-' || surl || '-' || id ); commit;
            vsurl := id;
         end if;
       end if;
    end if;
  end if;

  -- Put in so that external APIs can get access to the SURL.
    id := substr(vsurl,1,12);
    x := instr(id,'Z');
    if x > 0 then id := substr(id,1,x-1); end if;
    begin
     x := to_number(id);
    exception
     when others then
     sts := 'Invalid ID:' || id;
     return;
    end;

    open c3(x, substr(vsurl,1,22));
    fetch c3 into DAPI.GLOBAL_LOGIN_SESSION;
    if c3%NOTFOUND
     then
      close c3;
      sts := 'Invalid ID:' || id;
      return;
    end if;
    close c3;

    begin
     open c1( to_number(id) );
    exception
     when others then
      sts := 'Invalid ID:' || id;
      return;
    end;

    fetch c1 into DAPI.GLOBAL_LOGIN_SESSION;
    if c1%NOTFOUND
     then
      close c1;
      sts := LNG.GLB_TXT_010;
      return;
    end if;
    close c1;

    if DAPI.GLOBAL_LOGIN_SESSION.is_connected = 'F'
     then
      sts := LNG.GLB_TXT_011;
      return;
    end if;

    update login_session
     set
	 date_updated = sysdate,
	 call_ctr = call_ctr + 1
    where sessid = DAPI.GLOBAL_LOGIN_SESSION.sessid;

   begin timeout := to_number(glbx.extract_master_parameter('DISCONNECT_AFTER')); exception when others then timeout := 180; end;

   if (sysdate - nvl(DAPI.GLOBAL_LOGIN_SESSION.date_updated,DAPI.GLOBAL_LOGIN_SESSION.date_created))*1440 > timeout
    then
     update login_session
	set is_connected = 'F'
	where sessid = DAPI.GLOBAL_LOGIN_SESSION.sessid;
	commit;
	sts := LNG.GLB_TXT_012 || timeout || LNG.GLB_TXT_013;
	htp.nl;
	htp.nl;
	glbx.login_page( LNG.GLB_TXT_014 );
	return;
   end if;

  commit;

end cookie_id;

function initialise_setup( surl in varchar2, program_called in varchar2, acid in integer default null, reset boolean default TRUE, iscust boolean default TRUE )
 return boolean
as

 cursor c1_cust(acid integer) is select * from customer_account ca where ca.aid = acid;
 cursor c1_prof(acid integer) is select * from customer_profile cp where cp.profile_id = acid;
 cursor c2(phgid integer) is select * from photographer where pid = phgid;
 cursor c3(acc_id integer, ltype varchar2) is select * from customer_contact where aid = acc_id and login_type = ltype;
 cursor c4(cmid integer) is select * from manufacturer where manufacturer_id = cmid;

 sts		varchar2(1000);
 c1prec		c1_prof%ROWTYPE;

 begin
  if reset then htp.init; end if;
  GLOBAL_SURL := glbx.truncsurl(surl);
  dapi.cookie_id( surl, GLOBAL_ERROR, iscust=>iscust);
  if GLOBAL_ERROR is not null
   then
    return( FALSE );
  end if;

  GLOBAL_PROGRAM_CALLED := program_called;

  if  GLOBAL_LOGIN_SESSION.login_type = 'PHOTOGRAPHER'
   then
    open c1_cust(acid);
    fetch c1_cust into GLOBAL_CUSTOMER_ACCOUNT;
    close c1_cust;
    GLOBAL_PROFILE_ID := nvl(acid,GLOBAL_LOGIN_SESSION.aid);
  elsif  GLOBAL_LOGIN_SESSION.login_type = 'VIRTUAL'
   then
    open c1_cust(GLOBAL_LOGIN_SESSION.aid);
    fetch c1_cust into GLOBAL_CUSTOMER_ACCOUNT;
    close c1_cust;
    GLOBAL_PROFILE_ID := GLOBAL_LOGIN_SESSION.event_id;
    GLOBAL_LOGIN_SESSION.login_type := 'CUSTOMER';
  elsif  GLOBAL_LOGIN_SESSION.login_type in ('PROFILE','PROFILEG')
   then
    open c1_prof(GLOBAL_LOGIN_SESSION.aid);
    fetch c1_prof into c1prec;
    close c1_prof;
    open c1_cust(c1prec.aid);
    fetch c1_cust into GLOBAL_CUSTOMER_ACCOUNT;
    close c1_cust;
    GLOBAL_PROFILE_ID := c1prec.profile_id;
    GLOBAL_CUSTOMER_ACCOUNT := glbx.conv_account(c1prec, GLOBAL_CUSTOMER_ACCOUNT);
   else
    open c1_cust(GLOBAL_LOGIN_SESSION.aid);
    fetch c1_cust into GLOBAL_CUSTOMER_ACCOUNT;
    close c1_cust;
    GLOBAL_PROFILE_ID := GLOBAL_LOGIN_SESSION.aid;
  end if;

  GLOBAL_LF := glbx.get_thm( GLOBAL_CUSTOMER_ACCOUNT.theme_name );
  GLOBAL_BF := glbx.get_theme_types( GLOBAL_CUSTOMER_ACCOUNT.theme_type );
  GLOBAL_PURCHASE_ORDER := glbx.get_purchase_order( GLOBAL_LOGIN_SESSION.sessid );

  if GLOBAL_PURCHASE_ORDER.oid is null
   then
    GLOBAL_ORDER_STYLE := glbx.get_order_style( glbx.get_order_style( GLOBAL_CUSTOMER_ACCOUNT.aid, GLOBAL_PROFILE_ID, GLOBAL_LOGIN_SESSION.login_type, GLOBAL_B2C_VALUE ));
   else
    GLOBAL_ORDER_STYLE := glbx.get_order_style( GLOBAL_PURCHASE_ORDER.oid );
  end if;
  if GLOBAL_PURCHASE_ORDER.poid is null
   then
    fname.create_purchase_order(GLOBAL_LOGIN_SESSION.securl, GLOBAL_LOGIN_SESSION.sessid, 'PreOrder - No Order Made', GLOBAL_PROFILE_ID, GLOBAL_LOGIN_SESSION.login_type, GLOBAL_CUSTOMER_ACCOUNT, GLOBAL_ORDER_STYLE, GLOBAL_PURCHASE_ORDER);
  end if;

  --if decs.audit_all_activity
  -- then
    insert into audit_all_activity(sessid,date_updated,program_called,umo_id,display_what,login_type) values
    ( GLOBAL_LOGIN_SESSION.sessid, sysdate, GLOBAL_PROGRAM_CALLED, null, null, GLOBAL_LOGIN_SESSION.login_type );
  --end if;

  GLOBAL_ERROR := NULL;
  open c2( GLOBAL_CUSTOMER_ACCOUNT.PID );
  fetch c2 into GLOBAL_PHOTOGRAPHER;
  close c2;
  open c3(GLOBAL_LOGIN_SESSION.aid, GLOBAL_LOGIN_SESSION.login_type);
  fetch c3 into GLOBAL_CUSTOMER_CONTACT;
  close c3;
  if GLOBAL_LOGIN_SESSION.login_type = 'MANUFACTURER'
   then
     open c4(GLOBAL_LOGIN_SESSION.aid);
     fetch c4 into GLOBAL_MANUFACTURER;
     close c4;
     if GLOBAL_LF.theme_name is null then GLOBAL_LF := glbx.get_thm(GLOBAL_MANUFACTURER.theme_name); end if;
  elsif GLOBAL_LOGIN_SESSION.login_type = 'PHOTOGRAPHER'
   then
     open c2(GLOBAL_LOGIN_SESSION.aid);
     fetch c2 into GLOBAL_PHOTOGRAPHER;
     close c2;
     if GLOBAL_LF.theme_name is null then GLOBAL_LF := glbx.get_thm(GLOBAL_PHOTOGRAPHER.top_frame_lf); end if;
  end if;
  return( TRUE );
 end initialise_setup;

 procedure failed_connection( surl in varchar2, program_called in varchar2, nodisplay in boolean default FALSE, extra_parameter in varchar2 default null )
 as
 begin
  htp.init;
  if glbx.extract_master_parameter('ON_LOGOUT_API') is not null
   then
    begin
     execute immediate
      'begin ' || glbx.extract_master_parameter('ON_LOGOUT_API') || '(extra_parameter=>:extra_parameter); end;'
      using extra_parameter;
     return;
    exception
     when others then null;
    end;
  end if;

  htp.htmlopen;
  if nodisplay
   then
    htp.bold( GLOBAL_ERROR );
    htp.htmlclose;
    return;
  end if;
  htp.header(2, LNG.GLB_TXT_001, 'CENTER' );
  htp.nl;
  htp.header(3, GLOBAL_ERROR, 'CENTER' );
  htp.nl;
  htp.header(4, LNG.GLB_TXT_002, 'CENTER' );
  htp.nl;
  htp.p( '<CENTER>' );
  glbx.login_page;

 end failed_connection;

 procedure header_open( title in varchar2 default null, help in varchar2 default null, style in varchar2 default 'STANDARD', styleparm in varchar2 default null, return_link in varchar2 default null,
                        my_class in varchar2 default null, my_font in varchar2 default null, my_size in varchar2 default null, my_colour in varchar2 default null, body_addition in varchar2 default null )
 as

   fsize		integer;
   lnkh			varchar2(40);
   smlsz		integer;
   sstyle		varchar2(100);
   sclr			varchar2(100);
   h2_sclr		varchar2(100);
   h2_sstyle		varchar2(100);
   uline		varchar2(100);
   uline_active		varchar2(100);
   uline_visited	varchar2(100);
   expanded_scenes	GLBX.MYARRAY;
   msg			varchar2(4000);
   background		varchar2(4000);

 begin
  -- Display DOCTYPE (Note: This should be a Master Parameter)
  htp.p('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">' );
  htp.htmlopen;
  htp.p( '<head>' );

  -- Display STYLE Sheet
  if GLOBAL_LF.underline_active = 'ACTIVE'
   then
    lnkh := NULL;
   else
    lnkh := '; Text-Decoration : None';
  end if;

  fsize := 8 + trunc(GLOBAL_LOGIN_SESSION.screen_type/1.5) + nvl(GLOBAL_LF.text_font_inc,0);

  if GLOBAL_LF.tnail_disp_sml_font = 'T'
   then
    smlsz := greatest(fsize - 2,1);
   else
    smlsz := fsize;
  end if;

  if NVL(NVL(style, GLOBAL_STYLE), 'STANDARD') = 'STANDARD'
   then
    sstyle := GLOBAL_LF.text_font;
    sclr := GLOBAL_LF.text_colour;
    uline := NULL;
    h2_sclr := sclr;
    h2_sstyle := sstyle;
  elsif NVL(style, GLOBAL_STYLE) = 'TOP'
   then
    sstyle := GLOBAL_LF.top_text_font;
    sclr := GLOBAL_LF.top_text_colour;
    uline := NULL;
    h2_sclr := sclr;
    h2_sstyle := sstyle;
  elsif NVL(style, GLOBAL_STYLE) = 'LEFT'
   then
    sstyle := GLOBAL_LF.lhs_text_font;
    sclr := GLOBAL_LF.lhs_text_colour;
    uline := NULL;
    h2_sclr := sclr;
    h2_sstyle := sstyle;
  elsif NVL(style, GLOBAL_STYLE) = 'GALLERY'
   then
    sstyle := GLOBAL_LF.gallery_text_font;
    sclr := GLOBAL_LF.gallery_text_colour;
    uline := NULL;
    h2_sclr := sclr;
    h2_sstyle := sstyle;
  elsif NVL(style, GLOBAL_STYLE) = 'HOME'
   then
    sstyle := GLOBAL_LF.det_text_font;
    sclr := GLOBAL_LF.det_text_colour;
    uline := NULL;
    h2_sclr := GLOBAL_LF.det_title_colour;
    h2_sstyle := GLOBAL_LF.det_title_font;
  elsif NVL(style, GLOBAL_STYLE) = 'THUMBNAIL'
   then
    sstyle := GLOBAL_LF.text_font;
    sclr := GLOBAL_LF.text_colour;
    uline := GLOBAL_LF.uline;
    uline_active := GLOBAL_LF.uline_active;
    uline_visited := GLOBAL_LF.uline_visited;
    h2_sclr := sclr;
    h2_sstyle := sstyle;
  else
    sstyle := GLOBAL_LF.text_font;
    sclr := GLOBAL_LF.text_colour;
    h2_sclr := sclr;
    h2_sstyle := sstyle;
    uline := NULL;
  end if;

  htp.p('<style type="text/css"><!-- ' ||
        ' P { page-break-after: auto; }' ||
        ' A:link { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(uline,sclr) || '  ' || lnkh || ';}' ||
        ' A:active { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(uline_active,nvl(uline,sclr)) || '  ' || lnkh || ';}' ||
        ' A:visited { font-family:  ' || sstyle || ' ; color :  ' || '#' || nvl(uline_visited,nvl(uline,sclr)) || '  ' || lnkh || ';}' ||
        ' A:hover { font-family:  ' || sstyle || ' ; color :  ' || '#' || GLOBAL_LF.hover_colour || ' ;}' ||
        ' TD.HEADWHITE {font-size: ' || to_char(fsize+6) || 'pt;font-family:  ' || GLOBAL_LF.title_text_font || ' ; color:  #' || GLOBAL_LF.title_colour_font || ' ; text-align: center;}' ||
        ' BODY{font-size: ' || fsize || 'pt;font-family:  ' || sstyle || ' ; color:  #' || sclr || ' ;}' ||
        ' H1  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 6) || 'pt; color:  #' || sclr || ' ;}' ||
        ' H2  {font-family:  ' || h2_sstyle || ' ; font-size: ' || to_char(fsize + 6) || 'pt; color:  #' || h2_sclr || ' ;}' ||
        ' H2.ERROR {font-family:  ' || nvl(GLOBAL_LF.error_text_font,sstyle) || ' ; font-size: ' || to_char(fsize + 6) || 'pt; color:  ' || GLOBAL_LF.error_text_colour || ' ;}' ||
        ' H3  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 4) || 'pt; color:  #' || sclr || ' ;}' ||
        ' H4  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 2) || 'pt; color:  #' || sclr || ' ;}' ||
        ' H5  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize + 1) || 'pt; color:  #' || sclr || ' ;}' ||
        ' H6  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(fsize - 2) || 'pt;font-style: italic; color:  #' || sclr || ' ;}' ||
        ' TD  {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || sclr || ' ;}' ||
        ' TD.SMALL  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(greatest(0,fsize - 2)) || 'pt; color:  #' || sclr || ' ;}' ||
        ' SMALL  {font-family:  ' || sstyle || ' ; font-size: ' || to_char(greatest(0,fsize - 2)) || 'pt; color:  #' || sclr || ' ;}' ||
        ' SUP {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || sclr || ' ;}' ||
        ' DIV {font-family:  ' || sstyle || ' ; font-size: ' || fsize || 'pt; color:  #' || sclr || ' ;}' ||
        nvl(NVL(my_class, GLOBAL_MY_CLASS),'MYCLASS') || '{font-family:  ' || nvl(NVL(my_font, GLOBAL_MY_FONT),sstyle) || ' ; font-size: ' || nvl(NVL(my_size, GLOBAL_MY_SIZE),fsize) || 'pt; color:  #' || nvl(NVL(my_colour, GLOBAL_MY_COLOUR),sclr) || ' ;}');
        for i in 1..GLOBAL_MY_STYLES_CTR loop
           htp.p(GLOBAL_MY_STYLES(i).selector || ' ' || GLOBAL_MY_STYLES(i).properties);
        end loop;
        htp.p('--> </style>');
  if GLOBAL_EXTERNAL_STYLESHEET IS NOT NULL then
     htp.p( '<link rel="StyleSheet" href="' || GLOBAL_EXTERNAL_STYLESHEET || '" type="text/css" media="screen">' );
  else
     htp.comment( 'External stylesheet goes here' );
  end if;


  -- Display Title
  -- xxx Review this, make sure it really does display BAR_TITLE in no frame
  htp.title( nvl(glbx.userpref( GLOBAL_CUSTOMER_ACCOUNT.pid, GLOBAL_CUSTOMER_ACCOUNT.aid, 'TITLE'), glbx.extract_master_parameter('BAR_TITLE')) );

  -- Meta Heading containing code allowing access to site as specified by Internet Content Rating Association
  if GLOBAL_LF.icra_label is not null then htp.p(GLOBAL_LF.icra_label); end if;
  if GLOBAL_LF.javascript = 'DISABLE'then htp.p( '<meta http-equiv="imagetoolbar" content="no">' ); end if;
  htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8">');

  -- Disable Right Mouse Click (for older style browsers)
  background := NVL(body_addition, GLOBAL_BODY_ADDITION);

  if  GLOBAL_LF.javascript = 'DISABLE'
   then
        htp.p('<script type="text/javascript" language="JavaScript">
              var message="' || LNG.GLB_TXT_104 || '";
              function click(e) {
              if (document.all) {
              if (event.button == 2) {
              alert(message);
              return false;
              }
              }
              if (document.layers) {
              if (e.which==3) {
              alert(message);
              return false;
              }
              }
              }
              if (document.layers) {
              document.captureEvents(Event.MOUSEDOWN);
              }
              document.onmousedown=click;
              // End -->
              </script>');
  end if;

  if (NVL(style, GLOBAL_STYLE) = 'TOP' or GLOBAL_LF.keep_lhf = 'N') and (GLOBAL_LOGIN_SESSION.browser_type <> 'Microsoft Internet Explorer')
   then
     msg := glbx.userpref( GLOBAL_CUSTOMER_ACCOUNT.pid, GLOBAL_CUSTOMER_ACCOUNT.aid, 'SCROLL_MESSAGE');
     if msg is not null
      then
       htp.p('<script type="text/javascript" language="JavaScript">
              var space = "                                                                           "
              var scr = space + "' || translate(msg,'"<>','   ') || '"
              function ScrollAlong()
              {
               temp = scr.substring(0,1);
               scr += temp
               scr = scr.substring(1,scr.length);
               document.Scroll.ScrollBox.value = scr.substring(0,80);
               var counts = setTimeout("ScrollAlong()",100);
              }
            </script>');
       background := background || ' onLoad="ScrollAlong()" ';
     end if;
  end if;

  if GLOBAL_LF.scene_position = 'T'
   then
    buttons_header;
  end if;

  -- Display Body Statement (different background depending on where it is displayed)
  if NVL(style, GLOBAL_STYLE) = 'TOP'
   then

    if GLOBAL_LF.top_frame_background is null
     then
      background := background || ' bgcolor="#' || GLOBAL_LF.top_back || '"';
     else
      background := background || ' background="' || DECS.IMAGE_LOCATION || GLOBAL_LF.top_frame_background || '"';
    end if;

   else

    if GLOBAL_CUSTOMER_ACCOUNT.background_img is null
     then
      background := background || ' bgcolor="#' || GLOBAL_LF.text_back || '"';
     else
      background := background ||
        ' background="ump.retrieve_uma?surl=' || glbx.truncsurl(GLOBAL_SURL) || '&parm1=UMO_ID&parm2=' || GLOBAL_CUSTOMER_ACCOUNT.background_img || '&parm1=DISPLAY_TYPE&parm2=RAW' ||
        '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || GLOBAL_CUSTOMER_ACCOUNT.aid || '&parm1=LOGIN_TYPE&parm2=' || GLOBAL_LOGIN_SESSION.login_type || '"';
    end if;

  end if;

  htp.p( '</head>' );
  htp.p( '<body ' || background || '>'); -- TOPMARGIN="' || GLOBAL_LF.top_padding || '" LEFTMARGIN="' || GLOBAL_LF.left_padding || '"' || ' MARGINHEIGHT="' || GLOBAL_LF.top_padding || '" MARGINWIDTH="' || GLOBAL_LF.left_padding || '">' );

  -- Display Three Frame
  if GLOBAL_LF.sim_three_frame = 'T' and GLOBAL_LOGIN_SESSION.login_type not in  ('PHOTOGRAPHER','MANUFACTURER')
   then
    htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.p( '<TD VALIGN="TOP" COLSPAN=2>' );
      acct_top( NVL(title, GLOBAL_TITLE) );
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
    htp.p( '<TD VALIGN="TOP">' );
     cst.acct_leftx( GLOBAL_SURL, null, expanded_scenes, null, null  ); -- Add later: expanded_scenes, left_api, left_api_parm
    htp.p( '</TD>' );
    htp.p( '<TD VALIGN="TOP">' );
  end if;

  -- For No Frame Mode (without three frame simulation) just display the header
  if (GLOBAL_LF.keep_lhf = 'N') and (GLOBAL_LF.sim_three_frame = 'F') and (GLOBAL_LOGIN_SESSION.login_type not in  ('PHOTOGRAPHER','MANUFACTURER'))
   then
    acct_top( NVL(title, GLOBAL_TITLE) );
  end if;

  -- For Two or Three Frame Mode, display the Menu Bar Title
  if (GLOBAL_LF.keep_lhf <> 'N' or GLOBAL_LOGIN_SESSION.login_type = 'PHOTOGRAPHER') and NVL(title, GLOBAL_TITLE) is not null
   then
    htp.tableopen( cattributes=>'width="100%" cellpadding=0 cellspacing=0 border=0 align="CENTER"' );
     htp.tablerowopen;
     if NVL(return_link, GLOBAL_RETURN_LINK) is not null
      then
       htp.tabledata( NVL(return_link, GLOBAL_RETURN_LINK), cattributes=>'bgcolor="#' || GLOBAL_LF.title_text_colour || '" valign="middle" align="LEFT" width="5%" style="background-color: #' || GLOBAL_LF.title_text_colour || '; text-align: center; font-family: ''' || GLOBAL_LF.title_text_font || '''; color: #' || GLOBAL_LF.title_colour_font || '"' );
     end if;
     htp.tabledata('<b>'|| NVL(title, GLOBAL_TITLE) || '</b>',cattributes=>'bgcolor="#' || GLOBAL_LF.title_text_colour || '" valign="middle" align="CENTER" style="background-color: #' || GLOBAL_LF.title_text_colour || '; text-align: center; font-family: ''' || GLOBAL_LF.title_text_font || '''; color: #' || GLOBAL_LF.title_colour_font || '"');
     if NVL(help, GLOBAL_HELP) is not null
      then
       htp.tabledata( htf.anchor2( 'glbx.show_help?surl=' || glbx.rndsurl(GLOBAL_SURL) || '&helpid=' || NVL(help, GLOBAL_HELP),
                      htf.img( DECS.IMAGE_LOCATION || 'admin_help.gif',cattributes=>' border=0', calt=>LNG.GLB_ALT_071), ctarget=>'HELP_WINDOW' ),
                      cattributes=>'bgcolor="#' || GLOBAL_LF.title_text_colour || '" valign="middle" align="CENTER" width="5%" style="background-color: #' || GLOBAL_LF.title_text_colour || '; text-align: center; font-family: ''' || GLOBAL_LF.title_text_font || '''; color: #' || GLOBAL_LF.title_colour_font || '"');
     end if;
     htp.tablerowclose;
    htp.tableclose;
  end if;

 end header_open;

 procedure header_close( extra_code in varchar2 default null )
 as
 begin

  if extra_code is not null then htp.p( extra_code ); end if;
  if GLOBAL_LF.keep_lhf not in ('L','R') and GLOBAL_LF.sim_three_frame = 'T'
   then
    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;
    htp.p( '</BODY>' );
    htp.htmlclose;
   else
    htp.p( '</BODY>' );
    htp.htmlclose;
  end if;

 end header_close;

procedure acct_top( ttl in varchar2 default null )
as

 cursor c2(acid integer, phgr integer, imgtype varchar2) is
   select um.photo_master, um.umo_id, um.version, 'J' typ, um.extras.orderby_nmb orderby_nmb, attribute1, attribute2
   from umo um, customer_account ca
   where um.aid = acid and
         um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'F' and
         umo_type = imgtype
   union all
   select um.photo_master, um.umo_id, um.version, 'K' typ, um.extras.orderby_nmb orderby_nmb, attribute1, attribute2
   from umo um, customer_account ca
   where um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'T' and
         umo_type = imgtype
   order by 4,5;
 cursor c5(acid integer ) is select count('x') from slide_master where aid=acid;

 tmpi		integer;
 bgcol		varchar2(100);
 tmp		varchar2(2000);
 slides		boolean;
 width		integer;
 height		integer;
 http		varchar2(100);
 ps		char(1);
 dscroll	boolean;

 procedure disp_icons( typ in varchar2 )
 as
  rspan	varchar2(20);
  hsite	varchar2(1000);
 begin
  if typ in ('i','j','k')
   then
    htp.p( '<TD ALIGN="RIGHT" ROWSPAN="2">' );
   else
    htp.p( '<TD ALIGN="RIGHT">' );
  end if;
   htp.tableopen( cattributes=> 'cellpadding=0 cellspacing=' || nvl(GLOBAL_LF.SF_BG_CELLSPC,2) || ' border=0' );
    htp.tablerowopen;
     if typ in ('I','J','K','i','j','k')
      then
       for c2rec in c2( GLOBAL_CUSTOMER_ACCOUNT.aid, GLOBAL_CUSTOMER_ACCOUNT.pid, 'ICON' ) loop
         if upper(c2rec.typ) = upper(typ) or typ = 'I'
          then
           hsite := NULL;
           http := ump.uma_attribute( GLOBAL_SURL, c2rec.umo_id, 'ICON', 'HTTP_LINK' );
           if http is null then hsite := GLOBAL_PHOTOGRAPHER.home_site; else hsite := http; end if;
           hsite := glbx.adjust_for_http( hsite );
           if nvl(c2rec.attribute1,'F') = 'T' or
              nvl(c2rec.attribute2,'F') = 'T'
            then
             hsite := 'cst.intercept_icon?surl=' || GLOBAL_SURL || '&v_umo=' || c2rec.umo_id;
           end if;
           width := to_number(ump.uma_attribute( GLOBAL_SURL,c2rec.umo_id, 'ICON', 'DISPLAY_WIDTH' ));
           height := to_number(ump.uma_attribute( GLOBAL_SURL,c2rec.umo_id, 'ICON', 'DISPLAY_HEIGHT' ));
           if hsite is null
             then
              htp.tabledata('<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(GLOBAL_SURL) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                  '&parm1=LOGIN_TYPE&parm2=' || GLOBAL_LOGIN_SESSION.login_type ||
                  '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
                  '" ALT="' || GLOBAL_PHOTOGRAPHER.business_name || '">');
           else
            htp.tabledata(htf.anchor2( hsite,'<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(GLOBAL_SURL) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                  '&parm1=LOGIN_TYPE&parm2=' || GLOBAL_LOGIN_SESSION.login_type ||
                  '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
                  '" ALT="' || nvl(http, GLOBAL_PHOTOGRAPHER.home_site) || '">',ctarget=>'_top' ));
         end if;
      end if;
     end loop;
     end if;
     htp.tablerowclose;
    htp.tableclose;
   htp.p( '</TD>' );
 end disp_icons;

 procedure disp_advert
 as
  tmp	varchar2(32767);
 begin
   tmp := adv.display_advert(GLOBAL_SURL, GLOBAL_LOGIN_SESSION.sessid, GLOBAL_BF.theme_type, GLOBAL_LOGIN_SESSION.login_type, 'TOP' );
   if tmp is not null
    then
     htp.tabledata( tmp, cattributes=>'valign="middle" ALIGN="CENTER"');
   end if;
 end disp_advert;

 procedure disp_photographer_title
 as
 begin
   htp.tabledata('<FONT SIZE="+2">' || glbx.userpref( GLOBAL_CUSTOMER_ACCOUNT.pid, GLOBAL_CUSTOMER_ACCOUNT.aid,'TOP_MESSAGE') || '</FONT>',cattributes=>'valign="middle" ALIGN="CENTER"');
 end disp_photographer_title;

 procedure disp_scrollbar( szin in boolean default TRUE, dsp in varchar2 default null, browser_type in varchar2 )
 as
  msg	varchar2(4000);
 begin

  -- New Scroll Method using Marquee
  if browser_type = 'Microsoft Internet Explorer'
   then
    msg := glbx.userpref( GLOBAL_CUSTOMER_ACCOUNT.pid, GLOBAL_CUSTOMER_ACCOUNT.aid, 'SCROLL_MESSAGE');
    if szin and msg is not null
     then
     htp.p( '<TD>' );
     if dsp = 'S' -- LOV ( S is SHORT, Q is LONG)
      then
       htp.p('<MARQUEE DIRECTION="LEFT" BEHAVIOR="SCROLL" SCROLLDELAY="250" WIDTH="' || to_char( greatest(1,round(glbx.sctrl(GLOBAL_LF.theme_name,'SCROLLBAR_WIDTH',GLOBAL_LOGIN_SESSION.screen_type)/2)*6) ) || '" SCROLLAMOUNT="10">');
      else
       htp.p('<MARQUEE DIRECTION="LEFT" BEHAVIOR="SCROLL" SCROLLDELAY="250" WIDTH="' || to_char(to_number(glbx.sctrl(GLOBAL_LF.theme_name,'SCROLLBAR_WIDTH',GLOBAL_LOGIN_SESSION.screen_type)) * 6) || '" SCROLLAMOUNT="10">');
     end if;
    end if;
    htp.p( msg );
    htp.p('</MARQUEE>');
    htp.p( '</TD>' );

   else
    -- Old Scroll Method Using Javascript
    htp.p( '<TD>' );
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
     htp.tablerowopen;
      htp.p( '<TD VALIGN="middle" ALIGN="CENTER">' );
      htp.p( '<FONT SIZE="+0">' );
      htp.p( '<FORM NAME="Scroll">' );
      if szin
       then
        if dsp = 'S'
         then
           htp.p( '<INPUT TYPE="text" size="' || to_char( greatest(1,round(glbx.sctrl(GLOBAL_LF.theme_name,'SCROLLBAR_WIDTH',GLOBAL_LOGIN_SESSION.screen_type)/2)) ) || '" name="ScrollBox" value="">' );
         else
          htp.p( '<INPUT TYPE="text" size="' || glbx.sctrl(GLOBAL_LF.theme_name,'SCROLLBAR_WIDTH',GLOBAL_LOGIN_SESSION.screen_type) || '" name="ScrollBox" value="">' );
        end if;
       else
          htp.p( '<INPUT TYPE="hidden" size="0" name="ScrollBox" value="">' );
      end if;
      htp.p( '</FORM>' );
      htp.p( '</FONT>' );
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.p( '</TD>' );
  end if;
 end disp_scrollbar;

 procedure disp_nmblist
 as
 begin
   htp.p( '<TD VALIGN="middle" ALIGN="CENTER">' );
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.p( '<TD VALIGN="middle" ALIGN="CENTER">' );
      glbx.image_nmb_index( GLOBAL_SURL, GLOBAL_CUSTOMER_ACCOUNT, GLOBAL_LF , GLOBAL_LOGIN_SESSION.login_type, null, GLOBAL_LF.gap);
     htp.p( '</TD>' );
    htp.tablerowclose;
   htp.tableclose;
   htp.p( '</TD>' );
 end disp_nmblist;

 procedure noframe_disp_category
 as
  cursor c11(profid integer) is select count('x') from profile_scenes where profile_id = profid;
  proftot	integer;
  dummy		glbx.myarray;
 begin
   if (GLOBAL_LF.nested_scene_style = LNG3.ADM_TXT_576) and (GLOBAL_LF.scene_position ='T')
    then
     if GLOBAL_LOGIN_SESSION.login_type in ('PROFILE','PROFILEG')
      then
       open c11(GLOBAL_PROFILE_ID);
       fetch c11 into proftot;
       close c11;
      else
       proftot := 0;
     end if;
     htp.p( '<TD VALIGN="middle" ALIGN="CENTER">' );
     htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
      htp.tablerowopen;
       htp.p( '<TD VALIGN="middle" ALIGN="CENTER">' );
        glbx.scene_display( GLOBAL_SURL, GLOBAL_CUSTOMER_ACCOUNT, GLOBAL_LF, GLOBAL_LOGIN_SESSION.login_type, GLOBAL_LOGIN_SESSION.screen_type, GLOBAL_PROFILE_ID, substr(GLOBAL_BF.theme_data,92,1), GLOBAL_LF.nested_scene_style, null, null, proftot, dummy, align=>'ALIGN="LEFT" VALIGN="TOP"' );
       htp.p( '</TD>' );
      htp.tablerowclose;
     htp.tableclose;
     htp.p( '</TD>' );
   end if;
 end noframe_disp_category;

 procedure disp_width( ps in varchar2 )
 as
 begin
  if ps = '1'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="10"');
  elsif ps = '2'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="20"');
  elsif ps = '3'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="40"');
  elsif ps = '4'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="80"');
  elsif ps = '5'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="160"');
  elsif ps = '6'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="250"');
  elsif ps = '7'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="300"');
  elsif ps = '8'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="400"');
  elsif ps = '9'
   then
    htp.tabledata( '&nbsp', cattributes=>'width="600"');
  end if;
 end disp_width;

 procedure disp_option( opt in varchar2 )
 as
 begin
   -- Help
   if opt = 'AUTHORISE'
    then
     htp.tabledata(htf.anchor2('cst.auth_payment?surl=' || glbx.rndsurl(GLOBAL_SURL) || '&newwin=T',htf.img( cust_button('authorise.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_692 ),ctarget=>'DISP_OPTION_WINDOW'));

   -- Help
   elsif opt = 'HELP'
    then
     htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(GLOBAL_SURL) || '&typ=HELP',htf.img( cust_button('help.gif',7),cattributes=>'border=0',calt=>lng.CST_ALT_022 ),ctarget=>'DISP_OPTION_WINDOW'));

   -- Readme
   elsif opt = 'README'
    then
     htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(GLOBAL_SURL) || '&typ=README',htf.img( cust_button('readme.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_455 ),ctarget=>'DISP_OPTION_WINDOW'));

   -- Feedback
   elsif opt = 'FEEDBACK'
    then
     htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(GLOBAL_SURL) || '&typ=FEEDBACK',htf.img( cust_button('feedback.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_456 ),ctarget=>'DISP_OPTION_WINDOW'));

   -- Contact Us
   elsif opt = 'CONTACTUS'
    then
     htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(GLOBAL_SURL) || '&typ=CONTACTUS',htf.img( cust_button('contactus.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_457 ),ctarget=>'DISP_OPTION_WINDOW'));

   -- Legal
   elsif opt = 'LEGAL'
    then
     htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(GLOBAL_SURL) || '&typ=LEGAL',htf.img( cust_button('legal.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_458 ),ctarget=>'DISP_OPTION_WINDOW'));

   -- Privacy
   elsif opt = 'PRIVACY'
    then
     htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(GLOBAL_SURL) || '&typ=PRIVACY',htf.img( cust_button('privacy.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_459 ),ctarget=>'DISP_OPTION_WINDOW'));

   -- Logoff
   elsif opt = 'LOGOFF'
    then
     if glbx.userpref( GLOBAL_CUSTOMER_ACCOUNT.pid, GLOBAL_CUSTOMER_ACCOUNT.aid, 'CUST_LOGOFF' ) = LNG.PHG_TXT_045
      then
        htp.tabledata(htf.anchor2('glbx.acct_logoff?surl=' || glbx.rndsurl(GLOBAL_SURL),htf.img( cust_button('logoff.gif',7),cattributes=>'border=0',calt=>lng.CST_ALT_021 ),ctarget=>'_top'));
      else
        htp.tabledata(htf.anchor2('glbx.acct_logoff?surl=' || glbx.rndsurl(GLOBAL_SURL),htf.img( cust_button('home.gif',7),cattributes=>'border=0',calt=>lng.LAB_TXT_002 ),ctarget=>'_top'));
     end if;
  end if;
 end disp_option;

 procedure disp_title( ttl in varchar2 )
 as
 begin
   htp.tabledata( htf.header( 3, ttl, 'CENTER' ) );
 end disp_title;

 procedure disp_datetime
 as
 begin
   htp.tabledata( to_char(sysdate, LNG.TSMASK ), cattributes=>'ALIGN="RIGHT"' );
 end disp_datetime;

 procedure disp_date
 as
 begin
   htp.tabledata( to_char(sysdate, LNG.MASK ), cattributes=>'ALIGN="RIGHT"' );
 end disp_date;

 procedure disp_time
 as
 begin
   htp.tabledata( to_char(sysdate, LNG.TSMASK_ONLY ), cattributes=>'ALIGN="RIGHT"' );
 end disp_time;

-- Start of Body of ACCT_TOP
begin

  -- Call to Replace TopFrame
  if GLOBAL_LF.top_frame_api_call is not null
   then
    execute immediate
     'begin ' || GLOBAL_LF.top_frame_api_call || '(surl=>:surl); end;'
    using GLOBAL_SURL;
    return;
  end if;

  slides := TRUE;
  open c5(GLOBAL_CUSTOMER_ACCOUNT.aid);
  fetch c5 into tmpi;
  close c5;
  if tmpi < 1 then slides := FALSE; end if;

  div_center;
  dscroll := FALSE;
  for k in 1..4 loop
  if k = 1
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || GLOBAL_LF.sf_table_width );
  elsif k = 2 and (instr(GLOBAL_LF.row1,'j') = 0 and instr(GLOBAL_LF.row1,'k') = 0)
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || GLOBAL_LF.sf_table_width );
  elsif k = 3 and (instr(GLOBAL_LF.row2,'j') = 0 and instr(GLOBAL_LF.row2,'k') = 0)
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || GLOBAL_LF.sf_table_width );
  elsif k = 4 and (instr(GLOBAL_LF.row3,'j') = 0 and instr(GLOBAL_LF.row3,'k') = 0)
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || GLOBAL_LF.sf_table_width );
  end if;

  htp.tablerowopen;

   for j in 1..10 loop
    if k = 1
     then
      ps := nvl(substr(GLOBAL_LF.row1,j,1),' ');
    elsif k = 2
     then
      ps := nvl(substr(GLOBAL_LF.row2,j,1),' ');
    elsif k = 3
     then
      ps := nvl(substr(GLOBAL_LF.row3,j,1),' ');
    elsif k = 4
     then
      ps := nvl(substr(GLOBAL_LF.row4,j,1),' ');
    end if;
    if ps <> ' '
     then
      if ps = 'T' and GLOBAL_LF.keep_lhf = 'N' then disp_title( ttl );
      elsif ps = 'S' then disp_scrollbar( TRUE, ps, GLOBAL_LOGIN_SESSION.browser_type ); dscroll := TRUE;
      elsif ps = 'Q' then disp_scrollbar( TRUE, ps, GLOBAL_LOGIN_SESSION.browser_type ); dscroll := TRUE;
      elsif ps = 'I' then disp_icons( 'I' );
      elsif ps = 'i' then disp_icons( 'i' );
      elsif ps = 'J' then disp_icons( 'J' );
      elsif ps = 'j' then disp_icons( 'j' );
      elsif ps = 'K' then disp_icons( 'K' );
      elsif ps = 'k' then disp_icons( 'k' );
      elsif ps = 'L' then disp_icons( 'L' );
      elsif ps = 'H' and GLOBAL_LF.keep_lhf = 'N' then disp_option( 'HELP' );
      elsif ps = 'A' then disp_advert;
      elsif ps = 'X' then disp_datetime;
      elsif ps = 'Y' then disp_date;
      elsif ps = 'Z' then disp_time;
      elsif ps = 'O' then disp_nmblist;
      elsif ps = 'D' then disp_option( 'README' );
      elsif ps = 'E' then disp_option( 'FEEDBACK' );
      elsif ps = 'F' then disp_option( 'CONTACTUS' );
      elsif ps = 'G' then disp_option( 'LEGAL' );
      elsif ps = 'M' then disp_option( 'PRIVACY' );
      elsif ps = 'N' then disp_option( 'LOGOFF' );
      elsif ps = 'R' then disp_option( 'AUTHORISE' );
      elsif ps = 'P' then disp_photographer_title;
      elsif ps = 'C' and GLOBAL_LF.scene_position = 'T' then noframe_disp_category;
      elsif ps = 'B' and GLOBAL_LF.disploc = 'T'
       then
        if GLOBAL_LF.sf_bg_img is null
         then
          htp.p( '<TD>' );
         else
          htp.p( '<TD BACKGROUND="' || DECS.IMAGE_LOCATION || GLOBAL_LF.sf_bg_img || '" HEIGHT=' || GLOBAL_LF.sf_bg_cell_height ||' WIDTH=' || GLOBAL_LF.sf_bg_cell_width || ' VALIGN="' || nvl( GLOBAL_LF.sf_bg_valign,'CENTER') || '">' );
        end if;
        buttons_footer( slides, FALSE );
        htp.p( '</TD>' );
      elsif ps in ('1','2','3','4','5','6','7','8','9') then disp_width(ps);
     end if;
    end if;
   end loop;
  htp.tablerowclose;

  if k = 1 and (instr(GLOBAL_LF.row1,'j') = 0 and instr(GLOBAL_LF.row1,'k') = 0)
   then
    htp.tableclose;
  elsif k = 2 and (instr(GLOBAL_LF.row2,'j') = 0 and instr(GLOBAL_LF.row2,'k') = 0)
   then
    htp.tableclose;
  elsif k = 3 and (instr(GLOBAL_LF.row3,'j') = 0 and instr(GLOBAL_LF.row3,'k') = 0)
   then
    htp.tableclose;
  elsif k = 4
   then
    htp.tableclose;
  end if;
  end loop;
  if not dscroll then disp_scrollbar( FALSE, null, GLOBAL_LOGIN_SESSION.browser_type ); end if;

  end_div_center;

 exception when others then
  glbx.error_details( 'DAPI', 'ACCT_TOP',GLOBAL_CUSTOMER_ACCOUNT.pid, GLOBAL_CUSTOMER_ACCOUNT.aid, errmsg=>sqlerrm);
 end acct_top;

 procedure buttons_header
 as

  cursor c1(ltype varchar2, owner_id integer) is
   select *
   from configurable_menu
   where login_type = ltype and
        ((aid is null) or ((aid = owner_id) and (aid is not null)))
   order by order_by;

  lty	varchar2(20);


 begin

  htp.print('<SCRIPT LANGUAGE="Javascript">');
  lty := GLOBAL_LOGIN_SESSION.login_type;
  if lty = 'PROFILE' then lty := 'OWNER'; end if;
  if lty = 'PROFILEG' then lty := 'CUSTOMER'; end if;
  if lty = 'VIRTUAL' then lty := 'CUSTOMER'; end if;

  for c1rec in c1(lty, GLOBAL_CUSTOMER_ACCOUNT.aid) loop
   if (c1rec.theme_id is not null and substr(GLOBAL_BF.theme_data,c1rec.theme_id,1) = 'T') or (c1rec.theme_id is null)
    then
     if c1rec.menu_type = 'MOUSE OVER'
      then
        htp.print( 'function turnon' || c1rec.img || '(img' || c1rec.img || ') {img' || c1rec.img || '.src="' || DECS.IMAGE_LOCATION || c1rec.subdirectory || GLOBAL_LF.disp_prefix || c1rec.img || '.gif' || '"} ');
        htp.print( 'function turnoff' || c1rec.img || '(img' || c1rec.img || '){img' || c1rec.img || '.src="' || DECS.IMAGE_LOCATION || c1rec.subdirectory || GLOBAL_LF.disp_prefix || c1rec.img || 'x.gif' || '"}');
     end if;
   end if;
  end loop;

  htp.print('</SCRIPT>');
 exception when others then
  glbx.error_details( 'DAPI', 'BUTTONS_HEADER',errmsg=>sqlerrm);
 end buttons_header;

 procedure buttons_footer( slides in boolean, isleft in boolean default TRUE )
 as

  cursor c1(ltype varchar2, owner_id integer) is
   select *
   from configurable_menu
   where login_type = ltype and
        ((aid is null) or ((aid = owner_id) and (aid is not null)))
   order by order_by;

  trg	varchar2(20);
  lty	varchar2(20);
  ucall	varchar2(2000);

begin

 if GLOBAL_LF.keep_lhf = '2'
  then
   trg := 'CUS_BOTTOM';
 elsif GLOBAL_LF.keep_lhf = 'N'
  then
   trg := '_top';
 else
   trg := 'CUS_RIGHT';
 end if;

 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=' || nvl(GLOBAL_LF.sf_bg_cellspc,'0') || ' border=0 ' );
 htp.tablerowopen;
 if GLOBAL_LF.uses_boundary = 'T'
  then
   htp.tabledata(htf.img( curl=>DECS.IMAGE_LOCATION || GLOBAL_LF.disp_prefix || 'cup.gif',cattributes=>'BORDER=0 ' ));
   if isleft then htp.tablerowclose; end if;
 end if;

 lty := GLOBAL_LOGIN_SESSION.login_type;
 if lty = 'PROFILE' then lty := 'OWNER'; end if;
 if lty = 'PROFILEG' then lty := 'CUSTOMER'; end if;

 for c1rec in c1(lty, GLOBAL_CUSTOMER_ACCOUNT.aid) loop
  if (c1rec.theme_id is not null and substr(GLOBAL_BF.theme_data,c1rec.theme_id,1) = 'T') or (c1rec.theme_id is null)
   then
    ucall := replace(c1rec.url_call,'~SURL', GLOBAL_SURL);
    ucall := replace(ucall,'~RND',to_char(sysdate,'SSSSS'));
    ucall := replace(ucall,'~SCTYPE', GLOBAL_LOGIN_SESSION.screen_type );
    ucall := replace(ucall,'~STYPE', GLOBAL_LOGIN_SESSION.screen_type );
    if c1rec.menu_type = 'MOUSE OVER'
     then
      if (c1rec.img = 'szd' and slides) or (c1rec.img <> 'szd')
       then
        if isleft then htp.tablerowopen; end if;

        htp.tabledata(htf.anchor2( ucall,htf.img( curl=>DECS.IMAGE_LOCATION || c1rec.subdirectory || GLOBAL_LF.disp_prefix || c1rec.img ||'.gif',
                      calt=>c1rec.help_on,cattributes=>'BORDER=0 name="opt' || c1rec.img || '"' ),
                      ctarget=>nvl(c1rec.override_target,trg),
                      cattributes=>'onMouseover="turnoff' || c1rec.img || '(opt' || c1rec.img || '); return true;" onMouseout="turnon' || c1rec.img || '(opt' || c1rec.img || '); return true;"'));
        if isleft then htp.tablerowclose; end if;
      end if;
    end if;
  end if;
 end loop;

 if GLOBAL_LF.uses_boundary = 'T'
  then
  if isleft then htp.tablerowopen; end if;
   htp.tabledata(htf.img( curl=>DECS.IMAGE_LOCATION || GLOBAL_LF.disp_prefix || 'cdw.gif',cattributes=>'BORDER=0 ' ));
  if isleft then htp.tablerowclose; end if;
 end if;
 htp.tablerowclose;
 htp.tableclose;
exception when others then
 glbx.error_details( 'DAPI', 'BUTTONS_FOOTER',errmsg=>sqlerrm);
end buttons_footer;

 -- Disables the Key once pressed
 procedure formsubmit( id in varchar2, display in varchar2 )
 as
 begin
  htp.p('<BUTTON TYPE="submit" ID="' || id || '" onclick="javascript:document.getElementById(''' || id || ''').disabled=true">' || display || '</BUTTON>' );
 end formsubmit;

 procedure div_center
 as
 begin
  htp.p( '<DIV align=center>' );
 end div_center;

 procedure end_div_center
 as
 begin
  htp.p( '</DIV>' );
 end end_div_center;

function cust_button( gif in varchar2, element in integer default 1 )
 return varchar2
as
begin
 if nvl(substr(GLOBAL_LF.separate_customer_bt,1,1),'F') = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
 end if;

 if nvl(substr(GLOBAL_LF.separate_customer_bt,element,1),'F') = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
  else
   return( DECS.IMAGE_LOCATION || '/' || GLOBAL_LF.disp_prefix || '/' || gif );
 end if;
end cust_button;

procedure generate_category_list( acid in integer )
as

 cursor c1(acid integer) is select * from customer_profile where aid = acid;
 cursor c2(acid integer) is select pid from customer_account where aid = acid;

 phgid		integer;
 Gbufr		varchar2(32767);
 Gout_clob	clob;
 chr_14		char(1) := chr(14);
 chr_15		char(1) := chr(15);
 chr_16		char(1) := chr(16);
 chr_17		char(1) := chr(17);

 procedure clob_append( bufr in varchar2 )
 as
  loc1		integer;
  loc2		integer;
  abc		varchar2(2000);
 begin
  loc1 := length( bufr );
  loc2 := length( Gbufr );
  if ( loc1 + loc2 ) >= 32767
   then
    GBufr := GBufr || substr(bufr,1,(32767-loc2));
    dbms_lob.writeappend(Gout_clob,32767,GBufr);
    GBufr := substr(bufr,(32767-loc2)+1);
  else
   GBufr := GBufr || bufr;
 end if;
 end clob_append;

 procedure extract_category( phgid in integer, scnm in varchar2, par_scn in integer, accid in integer, ltype in varchar2, acid in integer )
 as
  cursor c1(phgid integer, scnm varchar2, par_scn integer) is
   select *
   from umo_scene
   where nvl(parent_scene,0) = nvl(par_scn,0) and
         category = scnm and
         ((owned_by = 'PUBLIC') or
          ((owned_by = 'PHOTOGRAPHER') and (owner_id = phgid))
         )
   order by order_by;

  cursor c_phg(uscid integer) is
   select count('x') tot
   from umo_map ump, umo um
   where um.umo_scene_id = uscid and
         umo_type in ('PHOTO','DOCUMENT','RELATIONAL','VIDEO','AUDIO','BLUEPRINT') and
         um.umo_id = ump.umo_id;

  cursor c_own(uscid integer) is
   select count('x') tot
   from umo_map ump, umo um
   where um.umo_scene_id = uscid and
         umo_type in ('PHOTO','DOCUMENT','RELATIONAL','VIDEO','AUDIO','BLUEPRINT') and
         um.umo_id = ump.umo_id and
         um.extras.enabled_phg = 'TRUE';

  cursor c_cus(uscid integer) is
   select count('x') tot
   from umo_map ump, umo um
   where um.umo_scene_id = uscid and
         umo_type in ('PHOTO','DOCUMENT','RELATIONAL','VIDEO','AUDIO','BLUEPRINT') and
         um.umo_id = ump.umo_id and
         um.extras.enabled_phg = 'TRUE' and
         um.extras.enabled_cus = 'TRUE';

  cursor c_prf(uscid integer, accid integer) is
   select count('x') tot
   from umo_map ump, umo um
   where um.umo_scene_id = uscid and
         umo_type in ('PHOTO','DOCUMENT','RELATIONAL','VIDEO','AUDIO','BLUEPRINT') and
         um.umo_id = ump.umo_id and
         um.extras.enabled_phg = 'TRUE' and
         not exists (select 'x' from profile_scenes where profile_id = accid)
   union all
   select count('x') tot
   from umo_map ump, umo um, profile_scenes pf
   where um.umo_scene_id = uscid and
         umo_type in ('PHOTO','DOCUMENT','RELATIONAL','VIDEO','AUDIO','BLUEPRINT') and
         um.umo_id = ump.umo_id and
         um.extras.enabled_phg = 'TRUE' and
         pf.profile_id = accid and
         pf.umo_scene_id = um.umo_scene_id;

  cursor c_prg(uscid integer, accid integer) is
   select count('x') tot
   from umo_map ump, umo um
   where um.umo_scene_id = uscid and
         umo_type in ('PHOTO','DOCUMENT','RELATIONAL','VIDEO','AUDIO','BLUEPRINT') and
         um.umo_id = ump.umo_id and
         um.extras.enabled_phg = 'TRUE' and
         um.extras.enabled_cus = 'TRUE' and
         not exists (select 'x' from profile_scenes where profile_id = accid)
   union all
   select count('x') tot
   from umo_map ump, umo um, profile_scenes pf
   where um.umo_scene_id = uscid and
         umo_type in ('PHOTO','DOCUMENT','RELATIONAL','VIDEO','AUDIO','BLUEPRINT') and
         um.umo_id = ump.umo_id and
         um.extras.enabled_phg = 'TRUE' and
         um.extras.enabled_cus = 'TRUE' and
         pf.profile_id = accid and
         pf.umo_scene_id = um.umo_scene_id;

  tot	integer;
 begin
  for c1rec in c1(phgid, scnm, par_scn) loop
   tot := 0;
   if ltype = 'PHOTOGRAPHER'
    then
     open c_phg(c1rec.umo_scene_id);
     fetch c_phg into tot;
     close c_phg;
   elsif ltype = 'OWNER'
    then
     open c_own(c1rec.umo_scene_id);
     fetch c_own into tot;
     close c_own;
   elsif ltype = 'CUSTOMER'
    then
     open c_cus(c1rec.umo_scene_id);
     fetch c_cus into tot;
     close c_cus;
   elsif ltype = 'PROFILE'
    then
     open c_prf(c1rec.umo_scene_id, accid );
     fetch c_prf into tot;
     close c_prf;
   elsif ltype = 'PROFILE'
    then
     open c_prg(c1rec.umo_scene_id, accid );
     fetch c_prg into tot;
     close c_prg;
   end if;

   clob_append( chr_14 || c1rec.title || chr_16 || c1rec.umo_scene_id || chr_17 || tot  );
    extract_category( phgid, scnm, c1rec.umo_scene_id, accid, ltype, acid );
   clob_append( chr_15 );

  end loop;
 end extract_category;

 procedure create_index( accid in integer, ltype in varchar2, acid in integer, phgid in integer  )
 as
  cursor c1( acctid integer, ltype varchar2 ) is select * from umo_category_index where account_id = acctid and login_type = ltype for update;
  cursor c2( acid integer ) is select scene_name from customer_account where aid = acid;

  c1rec  c1%ROWTYPE;
  c2rec  c2%ROWTYPE;

 begin
  delete from umo_category_index where account_id = accid and login_type = ltype;
  insert into umo_category_index(account_id, login_type, generated_index) values (accid, ltype, empty_clob());
  commit;
  GBufr := NULL;
  dbms_lob.createtemporary(Gout_clob, FALSE);

  open c2(acid);
  fetch c2 into c2rec;
  close c2;
  extract_category( phgid, c2rec.scene_name, null, accid, ltype, acid );

  if GBufr is not null
   then
    dbms_lob.writeappend(Gout_clob,length(GBufr),GBufr);
   else
    dbms_lob.writeappend(Gout_clob,2, chr_14 || chr_15);
  end if;
  open c1(accid, ltype);
  fetch c1 into c1rec;
  close c1;
  dbms_lob.copy(c1rec.generated_index,Gout_clob,dbms_lob.getlength( Gout_clob ));
  dbms_lob.freetemporary( Gout_clob );
  update umo_category_index set generated_index = c1rec.generated_index where account_id = accid and login_type = ltype;
  commit;

 end create_index;

begin

 open c2(acid);
 fetch c2 into phgid;
 close c2;

 -- Calculate for Photographer
 create_index( acid, 'PHOTOGRAPHER', acid, phgid );
 -- Calculate for Owner
 create_index( acid, 'OWNER', acid, phgid );
 -- Calculate for Guest
 create_index( acid, 'CUSTOMER', acid, phgid );
 -- Calculate for Each Profile
 for c1rec in c1(acid) loop
  create_index( c1rec.profile_id, 'PROFILE', acid, phgid );
  create_index( c1rec.profile_id, 'PROFILEG', acid, phgid );
 end loop;
 -- Virtual Accounts?

end generate_category_list;

procedure display_category_list( display_style in varchar2, show_total in boolean, accid in integer, ltype in varchar2, acid in integer, expanded in GLBX.MYARRAY )
as

 cursor c1(accid integer, ltype varchar2) is select generated_index from umo_category_index where account_id = accid and login_type = ltype;

 c1rec  c1%ROWTYPE;
 bfr		varchar2(32767);
 rmd		varchar2(2000);
 amt		integer;
 offset		integer;
 ctr		integer;
 chr_14		char(1) := chr(14);
 chr_15		char(1) := chr(15);
 chr_16		char(1) := chr(16);
 chr_17		char(1) := chr(17);

 function not_in_list(display_style in varchar2, uscid in integer)
  return boolean
 as
 begin
  if display_style <> 'DRILL DOWN' then return( FALSE ); end if;
  for j in expanded.first..expanded.last loop
   if to_char(j) = expanded(j)
    then
     return( FALSE );
   end if;
  end loop;
  return( TRUE );
 end not_in_list;

 procedure strip_list(display_style in varchar2, show_total in boolean, acid in integer, bfr in varchar2, ctr in out integer, lvl in integer, display in boolean, display_empty_parent in boolean, rmd out varchar2 )
 as
  loc_s		integer;
  loc_e1	integer;
  loc_e2	integer;
  loc_16	integer;
  loc_17	integer;
  catg		varchar2(100);
  uscid		integer;
  tot		integer;
  inf_prot	integer;
  b_display	boolean;
 begin
  inf_prot := 1;
  loop
   inf_prot := inf_prot + 1; if inf_prot > 20000 then exit; end if; -- Infinite loop protection
   loc_s := instr(bfr,chr_14,ctr,1);
   loc_e1 := instr(bfr,chr_15,loc_s,1);
   loc_e2 := instr(bfr,chr_14,loc_s + 1,1);
   exit when loc_s = 0;
   if loc_e1 = 0 then rmd := substr(bfr,loc_s); exit; end if;

   loc_16 := instr(bfr,chr_16,loc_s,1);
   loc_17 := instr(bfr,chr_17,loc_s,1);
   catg := substr(bfr,loc_s + 1, (loc_16 - loc_s) - 1);
   uscid := substr(bfr,loc_16 + 1, (loc_17 - loc_16) - 1);
   if loc_e1 < loc_e2
    then
     tot := substr(bfr,loc_17 + 1, (loc_e1 - loc_17) - 1);
    else
     tot := substr(bfr,loc_17 + 1, (loc_e2 - loc_17) - 1);
   end if;

   -- Display Results
   --dbms_output.put_line( lpad( '.', lvl, '.' ) || catg || '-' || uscid || '-' || tot );
   if lvl = 1 and not display_empty_parent and tot = 0
    then
     b_display := FALSE;
    else
     b_display := display;
   end if;

   if b_display
    then
     if display_style = 'DRILL DOWN'
      then
       null;
     elsif display_style = 'EXPAND ALL'
      then
       null;
     elsif display_style = 'LOV'
      then
       null;
     end if;
   end if;

   if loc_e1 < loc_e2
    then
     ctr := loc_e1 + 1;
     if substr(bfr,ctr+1,1) = chr_15 then exit; end if; -- Nested, need to exit
    else
     -- nested
     ctr := loc_e2;
     -- If it is not meant to be displayed - drill down - then keep looping through, but do not display
     if not b_display or not_in_list( display_style, uscid )
      then
       b_display := FALSE;
      else
       b_display := TRUE;
     end if;
     strip_list(display_style, show_total, acid, bfr, ctr, lvl + 1, b_display,display_empty_parent,rmd);
     if rmd is not null then exit; end if;
     if substr(bfr,ctr+1,1) = chr_15 then exit; end if; -- Nested, need to exit
     ctr := ctr + 1;
   end if;

  end loop;

 end strip_list;

begin
 open c1(accid, ltype);
 fetch c1 into c1rec;
 if c1rec.generated_index is null
  then
   c1rec.generated_index := empty_clob();
   dbms_lob.writeappend(c1rec.generated_index,2,chr_14 || chr_15);
 end if;
 close c1;

 offset := 0;
 rmd := NULL;
 loop
  amt := 30000;
  dbms_lob.read( c1rec.generated_index, amt, (offset * 30000) + 1, bfr );
  offset := offset + 1;
  exit when amt = 0;
  bfr := rmd || bfr; -- Attach left over from previous run through

  ctr := 1;
  -- TRUE, TRUE = TRUE, look and feel for display empty parent categories
  strip_list(display_style, show_total, acid, bfr, ctr, 1, TRUE, TRUE, rmd );

  exit when amt < 32767;
 end loop;
end display_category_list;

function init(surl in varchar2, program_called in varchar2, acid in integer default null, reset boolean default TRUE, iscust boolean default TRUE) return boolean
as
begin
 GLOBAL_PROGRAM_CALLED := program_called;
 return initialise_setup(surl, program_called, acid, reset, iscust);
end init;

procedure initFailed(surl in varchar2, nodisplay in boolean default FALSE, extra_parameter in varchar2 default null)
as
begin
 failed_connection(surl, GLOBAL_PROGRAM_CALLED, nodisplay, extra_parameter);
end initFailed;

procedure pageOpen(title in varchar2 default null, help in varchar2 default null, style in varchar2 default 'STANDARD', styleparm in varchar2 default null, return_link in varchar2 default null, my_class in varchar2 default null, my_font in varchar2 default null, my_size in varchar2 default null, my_colour in varchar2 default null, body_addition in varchar2 default null)
as
begin
 header_open(title, help, style, styleparm, return_link, my_class, my_font, my_size, my_colour, body_addition);
end pageOpen;

procedure pageClose(cattributes varchar2 default null)
as
begin
 header_close(cattributes);
end pageClose;

function getAccountId return integer
as
begin
 return GLOBAL_LOGIN_SESSION.aid;
end getAccountId;

function getProfileId return integer
as
begin
 return GLOBAL_PROFILE_ID;
end getProfileId;

function getPhotographerId return integer
as
begin
   return GLOBAL_PHOTOGRAPHER.pid;
end getPhotographerId;

function getUserType return char
as
begin
   return GLOBAL_CUSTOMER_CONTACT.user_type;
end getUsertype;

function getSessionId return integer
as
begin
 return GLOBAL_LOGIN_SESSION.sessid;
end getSessionId;

function getLoginType return varchar2
as
begin
 return GLOBAL_LOGIN_SESSION.login_type;
end getLoginType;

function getScreenType return integer
as
begin
 return GLOBAL_LOGIN_SESSION.screen_type;
end getScreenType;

procedure setTitle(title varchar2)
as
begin
 GLOBAL_TITLE := title;
end setTitle;

procedure setHelp(help varchar2)
as
begin
 GLOBAL_HELP := help;
end setHelp;

procedure setStyle(style varchar2)
as
begin
 GLOBAL_STYLE := style;
end setStyle;

procedure setStyleParm(styleparm varchar2)
as
begin
 GLOBAL_STYLE_PARM := styleparm;
end setStyleParm;

procedure setExternalStyleSheet(externalStypeSheet varchar2)
as
begin
 GLOBAL_EXTERNAL_STYLESHEET := externalStypeSheet;
end setExternalStyleSheet;

procedure setReturnLink(returnLink varchar2)
as
begin
 GLOBAL_RETURN_LINK := returnLink;
end setReturnLink;

procedure setMyClass(myClass varchar2)
as
begin
 GLOBAL_MY_CLASS := myClass;
end setMyClass;

procedure setMyFont(myFont varchar2)
as
begin
 GLOBAL_MY_FONT := myFont;
end setMyFont;

procedure setMySize(mySize varchar2)
as
begin
 GLOBAL_MY_SIZE := mySize;
end setMySize;

procedure setMyColour(myColour varchar2)
as
begin
 GLOBAL_MY_COLOUR := myColour;
end setMyColour;

procedure setBodyAddition(bodyAddition varchar2)
as
begin
 GLOBAL_BODY_ADDITION := bodyAddition;
end setBodyAddition;

function getLFRecord return theme%ROWTYPE
as
begin
 return GLOBAL_LF;
end getLFRecord;

function getBFRecord return theme_types%ROWTYPE
as
begin
 return GLOBAL_BF;
end getBFRecord;

function getCustomerAccountRecord return customer_account%ROWTYPE
as
begin
 return GLOBAL_CUSTOMER_ACCOUNT;
end getCustomerAccountRecord;

procedure addStyle(selector varchar2, properties varchar2)
as
   newStyle TStyleRecord;
begin
   if GLOBAL_MY_STYLES_CTR < 256 then
      GLOBAL_MY_STYLES_CTR := GLOBAL_MY_STYLES_CTR + 1;
      newStyle.selector := selector;
      newStyle.properties := properties;
      GLOBAL_MY_STYLES.extend;
      GLOBAL_MY_STYLES(GLOBAL_MY_STYLES_CTR) := newStyle;
   end if;
end addStyle;

function min(a integer, b integer)
return integer
as
begin
   if a < b then
      return a;
   else
      return b;
   end if;
end min;

function max(a integer, b integer)
return integer
as
begin
   if a > b then
      return a;
   else
      return b;
   end if;
end max;

function login(surl varchar2) return varchar2
as
   newSurl varchar2(100) := NULL;
begin
   return newSurl;
end login;

end dapi;

/


GRANT EXECUTE ON WEBSYS.DAPI TO STRANG;
