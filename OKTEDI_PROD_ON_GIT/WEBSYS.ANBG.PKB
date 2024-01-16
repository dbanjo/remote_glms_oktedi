CREATE OR REPLACE package body WEBSYS.anbg
as

   BACKGROUND_COLOUR   constant varchar2(7)   := '#FEFFDD';
   FOREGROUND_COLOUR   constant varchar2(7)   := '#12A003';
   FULL_IMAGE_TAB      constant varchar2(100) := 'FULL IMAGE';
   FULL_IMAGE_TAB_TEXT constant varchar2(100) := 'FULL IMAGE';

procedure acct_home(surl in varchar2, acid in integer, ltype in varchar2)
as

   cursor c1(acid integer, tgroup varchar2, vtitle varchar2) is select group_id from customer_meta_data_group where aid = acid and target_area = tgroup and title = vtitle;

   cursor c5(sess_id integer, ltype varchar2, acid integer) is
      select p.pid,  scene_name, object_access, ca.theme_name, can_edit_meta_data_values, ca.aid aid
      from photographer p, customer_account ca, login_session ls
      where p.pid = ca.pid and
            ca.aid = ls.aid and
            ls.sessid = sess_id and
            ltype in ('CUSTOMER','OWNER')
     union all
      select p.pid,  scene_name, object_access, ca.theme_name, can_edit_meta_data_values, ca.aid aid
      from photographer p, customer_account ca
      where p.pid = ca.pid and
            ca.aid = acid and
            ltype in ('PHOTOGRAPHER')
     union all
      select p.pid,  scene_name, object_access, cp.theme_name, can_edit_meta_data_values, cp.aid aid
      from photographer p, login_session ls, customer_profile cp
      where p.pid = cp.pid and
            ls.aid = cp.profile_id and
            ls.sessid = sess_id and
            ltype in ('PROFILE','PROFILEG');

   c1rec  	  c1%ROWTYPE;
   c5rec  	  c5%ROWTYPE;
   button_found   boolean;
   lOwnerId	  integer;
   lStatus        varchar2(100);
   lScreenType	  integer;
   lLoginType     varchar2(100);
   pfx	      	  THEME%ROWTYPE;
   defval	  GLBX.MYARRAY;

begin
 glbx.cookie_id(surl, lScreenType, lLoginType, lOwnerId, lStatus, 'S', progcalled=>'ANBG.ACCT_HOME');
 if lStatus is not null then
    glbx.redisplay_login_page( lStatus );
    return;
 end if;

 open c5(lOwnerId, lLoginType, acid );
 fetch c5 into c5rec;
 close c5;

 open c1(nvl(acid,c5rec.aid), 'G', 'All Details' );
 fetch c1 into c1rec;
 close c1;

 pfx := glbx.get_thm( c5rec.theme_name );
 glbx.main_title( surl, null,  glbx.backimg(surl,acid,pfx.fullimg_back,null,lLoginType), helpid=>null, stype=>lScreenType, sstyle=>pfx.fullimg_text_font, sclr=>pfx.fullimg_text_colour,  det_sstyle=>pfx.title_text_font, det_sclr=>pfx.title_text_colour,  det_font=>pfx.title_colour_font, hover=>pfx.hover_colour, jscript=>pfx.javascript,   disptop=>pfx.keep_lhf,  finc=>pfx.text_font_inc,  errclr=>pfx.error_text_colour,   errfnt=>pfx.error_text_font,  instclr=>pfx.instruct_text_colour,  instfnt=>pfx.instruct_text_font,   instfntinc=>pfx.instruct_font_inc,  excolour=>pfx.caption_text_colour,  exfont=>pfx.caption_text_font,  ltype=>lLoginType, icra_label=>pfx.icra_label, top_padding=>pfx.top_padding, left_padding=>pfx.left_padding, ispopup=>TRUE,stylesh=>pfx.stylesheet );

 htp.tableOpen(cattributes=>'border=0 celpadding=0 cellspacing=0 bgcolor="' || BACKGROUND_COLOUR || '"');
 htp.tableRowOpen(cattributes=>' height="100%"');
 htp.p('<TD colspan=50 style="border: solid medium ' || FOREGROUND_COLOUR || '">');

 htp.formOpen('anbg.update_image_display');
 htp.formHidden('pSURL', surl);
 htp.formHidden('pAccountId', acid);
 htp.formHidden('pUmoId', null);
 htp.formHidden('pFooterApi', null);
 htp.formHidden('pLeftApiParm', null);
 htp.formHidden('pCurrentPageNumber', 1);
 htp.formHidden('pActiveTab', c1rec.group_id);
 htp.formHidden('p1', '0');
 htp.formHidden('p2', '0');
 htp.formHidden('p3', '0');
 htp.formhidden('currno', null );
 htp.formhidden('rectotal', null );
 htp.formhidden('qmode', 'T' );

 glbx.meta_prompt(
  surl=>surl,
  acid=>nvl(acid,c5rec.aid),
  ltype=>ltype,
  tgroup=>'G',
  v_umo=>null,
  button_found=>button_found,
  onegrouponly=>c1rec.group_id,
  can_edit=>'F',
  query_mode=>TRUE,
  default_names=>defval,
  default_values=>defval);

 htp.formclose;

   htp.p('</TD>');
   htp.tableRowCLose;
   htp.tableClose;

 glbx.close_page( pfx );

 exception when others then  glbx.error_details( 'ANBG', 'ACCT_HOME', errmsg=>sqlerrm);
end acct_home;

procedure main_display( surl varchar2,
                      stype               in integer,
                      ltype               in varchar2,
                      umrec               in UMP.SEARCH_RESULT_PHG,
                      cusrec              in CUSTOMER_ACCOUNT%ROWTYPE,
                      pfx                    THEME%ROWTYPE,
                      theme_rec              theme_types%ROWTYPE,
                      footer_api          in varchar2,
                      current_page_number in integer default 1,
                      search_total        in integer default 0,
                      display_detail      in char default null,
                      left_api            in varchar2,
                      left_api_parm       in varchar2,
                      cusloc              in varchar2,
                      lbox                in varchar2,
                      acid                in integer default null,
                      sessid              in integer,
                      msg                 in varchar2)
as
   cursor c1(cacid integer) is select distinct um.extras.title category, um.umo_scene_id scene_id from umo um where aid = cacid;
   c1rec c1%ROWTYPE;

   cursor c2(cumoid integer) is select distinct um.extras.photo_name name from umo um where umo_id = cumoid;
   c2rec c2%ROWTYPE;

   iCategory integer;
   tWidth integer; -- Thumbnail width
   tHeight integer; -- Thumbnail height
   number_of_pages integer;
   number_of_images integer;
begin
   --
   -- Calculate total number of pages
   --
   number_of_images := 0;
   for i in umrec.first..umrec.last loop
      number_of_images := number_of_images + 1;
   end loop;
   htp.formClose;

   htp.formOpen('anbg.simple_search');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   htp.tableOpen(cattributes=>'width="100%" border=0 cellspacing=0 cellpadding=3 bgcolor="' || BACKGROUND_COLOUR || '"');

    htp.tableRowOpen;
     htp.tableData('&nbsp;', ccolspan=>'5');
    htp.tableRowClose;

    htp.tableRowOpen(cvalign=>'top', cnowrap=>'nowrap');
     htp.tableData('&nbsp;', crowspan=>'9', cattributes=>'width=2');
     htp.tableData(htf.bold('SEARCH CRITERIA'), cattributes=>'style="background-color: ' || FOREGROUND_COLOUR || '"');
     htp.tableData('&nbsp;', crowspan=>'9', cattributes=>'width=2');
     htp.tableData(htf.bold('PAGE INFORMATION'), cattributes=>'width="100%" style="background-color: ' || FOREGROUND_COLOUR || '"');
     htp.tableData('&nbsp;', crowspan=>'9', cattributes=>'width=2');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.p('<td rowspan=3 style="background-color: ' || BACKGROUND_COLOUR || '">');
      htp.p('KEYWORD(S)*'); htp.nl;
      htp.formText('keywords', cvalue=>'', cattributes=>'style="{width: 130}"');
      htp.formSubmit('action', 'Search', cattributes=>'style="height: 17; width: 43"');
      htp.nl;
      htp.p('SEARCH TYPE*'); htp.nl;
      htp.formSelectOpen('search_type');
      htp.formSelectOption('Keyword search', cattributes=>'VALUE="keyword" SELECTED');
      htp.formSelectOption('Image number search', cattributes=>'VALUE="image"');
      htp.formSelectOption('Photographer search', cattributes=>'VALUE="photographer"');
      htp.formSelectOption('Brand/Catalogue search', cattributes=>'VALUE="catalogue"');
      htp.formSelectClose;
     htp.p('</td>');
     htp.p('<td>');
     htp.p('Seeing page 1 of 2');
     htp.formText('go_page', cvalue=>'1');
     htp.formSubmit('action', 'GO');
     htp.p('</td>');
     htp.tableData('Seeing page 1 of 2');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.tableData(htf.bold('SEARCH RESULT'), cattributes=>'style="background-color: ' || FOREGROUND_COLOUR || '"');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.tableData('Your search has ' || search_total || ' results');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.tableData(htf.bold('CATEGORIES'), cattributes=>'style="background-color: ' || BACKGROUND_COLOUR || '"');
     --
     -- Show thumbnails
     --
     htp.p('<TD rowspan=5 style="background-color: ' || BACKGROUND_COLOUR || '">');

      htp.tableOpen(cattributes=>'border=0 CELLPADDING=0 CELLSPACING=10');
       htp.tableRowOpen(cvalign=>'top');
       tWidth  := 0;
       tHeight := 0;
        if umrec.count > 0 then
         for j in umrec.first..umrec.last loop
         	if tWidth < umrec(j).photo_thumbnail.width then
         		tWidth := umrec(j).photo_thumbnail.width;
         	end if;
         	if tHeight < umrec(j).photo_thumbnail.height then
         		tHeight := umrec(j).photo_thumbnail.height;
         	end if;
         end loop;
         tWidth  := tWidth * 1.2;
         tHeight := tHeight * 1.2;
         for j in umrec.first..umrec.last loop
          if (MOD(j, glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype)+1) = 1)  and (j <> 1) then
           htp.tableRowClose;
           htp.tableRowOpen(cvalign=>'top');
          end if;
          htp.p('<TD STYLE="{border-width: thin; border-color: ' || FOREGROUND_COLOUR || '; border-style: solid}; font-size: xx-small">');
           --
           -- Display the image
           --
           cst.display_thumbnail(surl,ltype,umrec(j),theme_rec,pfx,footer_api,left_api_parm,current_page_number,display_detail,null,null,null,null,null,null,acid);
           -- htp.nl;
           htp.img(DECS.IMAGE_LOCATION || 'abg/jfp_info.gif');
           htp.nl;
           htp.formHidden('PPN', null);
           --
           -- Checkbox to choose image
           --
           if umrec(j).umo_type = 'MANUFACTURER' then
              htp.formcheckbox( 'P1', 'S' || umrec(j).extras.quality );
           else
              htp.formcheckbox( 'P1', umrec(j).umo_id );
           end if;
           htp.p('Choose image');
           htp.nl;
           htp.formHidden('PB', null);
           --
           -- Checkbox to dis-/enable image
           --
           if ltype = 'PHOTOGRAPHER' then
             if umrec(j).extras.enabled_phg = 'TRUE' then
              htp.formcheckbox( 'PB', umrec(j).umo_id, 'CHECKED' );
         	 else
      	     htp.formcheckbox( 'PB', umrec(j).umo_id );
             end if;
           else
             if umrec(j).extras.enabled_cus = 'TRUE' then
      	     htp.formcheckbox( 'PB', umrec(j).umo_id, 'CHECKED' );
        	    else
      	     htp.formcheckbox( 'PB', umrec(j).umo_id );
             end if;
           end if;
           htp.p('Enable image');
           htp.nl;
           --
           -- Image name
           --
           if ltype = 'PHOTOGRAPHER' then
              htp.p(htf.bold(umrec(j).extras.film_name));
           else
              htp.p(htf.bold(umrec(j).extras.photo_name));
           end if;
          htp.p('</TD>');
         end loop;
        else
           htp.tableData('&nbsp;');
        end if;
       htp.tableRowClose;
      htp.tableClose;
     htp.p('</TD>');
    htp.tableRowClose;

    htp.tableRowOpen;
       htp.p('<TD>');
       htp.tableOpen;
       iCategory := 0;
       htp.tableRowOpen;
        htp.formHidden('categories', '<empty>');
        for c1rec in c1(cusrec.aid) loop
         if (mod(iCategory, 2) = 0) then
         htp.tableRowClose;
            htp.tableRowOpen;
         end if;
         htp.p('<TD NOWRAP>');
          htp.formCheckbox('categories', c1rec.scene_id, 'CHECKED');
          htp.anchor('cst.disp_category?surl=' || surl || '&' || 'left_api_parm=' || c1rec.scene_id || '&' || 'start_from=1', c1rec.category);
         htp.p('</TD>');
         iCategory := iCategory + 1;
        end loop;
       htp.tableRowClose;
       htp.tableClose;
       htp.p('</TD>');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.tableData(htf.bold('ADVANCED OPTIONS'), cattributes=>'style="background-color: ' || FOREGROUND_COLOUR || '"');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.p('<TD>');
     /*
      htp.p('Images per page'); htp.nl;
      htp.formSelectOpen('image_per_page');
      htp.formSelectOption('15', cattributes=>'SELECTED');
      htp.formSelectOption('30');
      htp.formSelectOption('45');
      htp.formSelectOption('60');
      htp.formSelectOption('75');
      htp.formSelectOption('90');
      htp.formSelectOption('105');
      htp.formSelectOption('120');
      htp.formSelectOption('135');
      htp.formSelectOption('150');
      htp.formSelectClose;
      htp.nl;
      */
      htp.p('Age of images'); htp.nl;
      htp.formSelectOpen('image_from');
      htp.formselectoption( LNG5.EXT_TXT_047, cattributes=>'VALUE="X"' );
      htp.formselectoption( '1 ' || LNG3.ADM_TXT_668, cattributes=>'VALUE="1D"' );
      htp.formselectoption( '2 ' || LNG3.ADM_TXT_668, cattributes=>'VALUE="2D"' );
      htp.formselectoption( '3 ' || LNG3.ADM_TXT_668, cattributes=>'VALUE="3D"' );
      htp.formselectoption( '4 ' || LNG3.ADM_TXT_668, cattributes=>'VALUE="4D"' );
      htp.formselectoption( '5 ' || LNG3.ADM_TXT_668, cattributes=>'VALUE="5D"' );
      htp.formselectoption( '6 ' || LNG3.ADM_TXT_668, cattributes=>'VALUE="6D"' );
      htp.formselectoption( '7 ' || LNG3.ADM_TXT_668, cattributes=>'VALUE="7D"' );
      htp.formselectoption( '1 ' || LNG5.EXT_TXT_046, cattributes=>'VALUE="1W"' );
      htp.formselectoption( '2 ' || LNG5.EXT_TXT_046, cattributes=>'VALUE="2W"' );
      htp.formselectoption( '3 ' || LNG5.EXT_TXT_046, cattributes=>'VALUE="3W"' );
      htp.formselectoption( '4 ' || LNG5.EXT_TXT_046, cattributes=>'VALUE="4W"' );
      htp.formselectoption( '1 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="1M"' );
      htp.formselectoption( '2 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="2M"' );
      htp.formselectoption( '3 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="3M"' );
      htp.formselectoption( '4 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="4M"' );
      htp.formselectoption( '5 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="5M"' );
      htp.formselectoption( '6 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="6M"' );
      htp.formselectoption( '7 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="7M"' );
      htp.formselectoption( '8 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="8M"' );
      htp.formselectoption( '9 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="9M"' );
      htp.formselectoption( '10 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="10M"' );
      htp.formselectoption( '11 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="11M"' );
      htp.formselectoption( '12 ' || LNG3.ADM_TXT_667, cattributes=>'VALUE="12M"' );
      htp.formselectoption( '1 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="1Y"' );
      htp.formselectoption( '2 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="2Y"' );
      htp.formselectoption( '3 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="3Y"' );
      htp.formselectoption( '4 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="4Y"' );
      htp.formselectoption( '5 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="5Y"' );
      htp.formselectoption( '6 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="6Y"' );
      htp.formselectoption( '7 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="7Y"' );
      htp.formselectoption( '8 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="8Y"' );
      htp.formselectoption( '9 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="9Y"' );
      htp.formselectoption( '10 ' || LNG2.PBK_TXT_034, cattributes=>'VALUE="10Y"' );
      htp.formSelectClose;
      htp.nl;
     htp.p('</TD>');
    htp.tableRowClose;

    htp.tableRowOpen;
     htp.p('<TD valign=top style="background-color: ' || BACKGROUND_COLOUR || '; padding: 5px">');

      htp.formReset('Clear', cattributes=>'style="height: smaller"');
     htp.p('</TD>');
    htp.tableRowClose;

   htp.tableClose;

   htp.formClose;
end main_display;

procedure simple_search(surl varchar2,
                        acid integer,
                        keywords varchar2 default null,
                        search_type varchar2 default null,
                        categories GLBX.MYARRAY,
                        image_per_page varchar2 default null,
                        image_from varchar2 default null,
                        ppn GLBX.MYARRAY,
                        pb GLBX.MYARRAY,
                        action varchar2)
as
   i integer;
   umoids varchar2(1000);
begin
   i := 0;
   for i in categories.first..categories.last loop
    umoids := umoids || categories(i) || ',';
   end loop;

   -- Get rid of the last komma
   umoids := RTRIM(umoids, ',');

   cst.simple_search(surl, p1=>keywords, p3=>categories, acid=>acid, age=>image_from, umoids=>umoids);
end simple_search;

procedure main_image_api_call(surl                varchar2,
                              acid                integer,
                              v_umo               integer,
                              footer_api          varchar2,
                              left_api_parm       varchar2,
                              current_page_number integer)
as
   cursor c1(csurl varchar) is
   	select aid from login_session where securl = csurl and login_type in ('PHOTOGRAPHER','CUSTOMER','OWNER') union all
   	select cp.aid from login_session ls, customer_profile cp where securl = csurl and login_type in ('PROFILE','PROFILEG') and ls.aid = cp.profile_id;

   c1rec c1%ROWTYPE;
begin
   if acid is null then
   	open c1(glbx.truncsurl(surl));
      fetch c1 into c1rec;
      close c1;
   end if;
   image_display2(surl, nvl(acid, c1rec.aid), v_umo, footer_api, left_api_parm, current_page_number, ispopup=>'T');
end;

procedure image_display2(
      surl               varchar2,
      acid                integer,
      v_umo               integer,
      footer_api          varchar2,
      left_api_parm       varchar2,
      current_page_number integer,
      p_active_tab        varchar2 default null,
      dbstate             varchar2 default 'update',
      currno		  integer default 1,
      recno		  integer default 1,
      rectotal		  integer default null,
      ispopup		  char default 'F'
      )
as
   cursor c1(acid integer, tgroup varchar2) is
      select * from customer_meta_data_group where aid = acid and target_area = tgroup order by display_order;

   cursor c2(acid integer, gip integer) is
      select * from customer_meta_data where aid = acid and group_id = gip order by display_order;

   cursor c3(attribid integer) is
      select * from umo_attributes where attribute_id = attribid;

   cursor c4(v_umo integer, attribid integer) is
      select value from umo_attribute where umo_id = v_umo and attribute_id = attribid;

   cursor c5(sess_id integer, ltype varchar2, acid integer) is
      select p.pid,  scene_name, object_access, ca.theme_name, can_edit_meta_data_values, ca.aid
      from photographer p, customer_account ca, login_session ls
      where p.pid = ca.pid and
            ca.aid = ls.aid and
            ls.sessid = sess_id and
            ltype in ('CUSTOMER','OWNER')
     union all
      select p.pid,  scene_name, object_access, ca.theme_name, can_edit_meta_data_values, ca.aid
      from photographer p, customer_account ca
      where p.pid = ca.pid and
            ca.aid = acid and
            ltype in ('PHOTOGRAPHER')
     union all
      select p.pid,  scene_name, object_access, cp.theme_name, can_edit_meta_data_values, cp.aid
      from photographer p, login_session ls, customer_profile cp
      where p.pid = cp.pid and
            ls.aid = cp.profile_id and
            ls.sessid = sess_id and
            ltype in ('PROFILE','PROFILEG');

   cursor c6(v_category varchar2, v_owner_id integer) is
      select umo_scene_id, owned_by, order_by, title, parent_scene
      from umo_scene
      where category = v_category and owned_by = 'PUBLIC'
     union all
      select usc.umo_scene_id, usc.owned_by, usc.order_by, usc.title, usc.parent_scene
      from umo_scene usc, photographer ph
      where
         category = v_category and
         usc.owner_id = ph.pid and
         ph.pid = v_owner_id and
         owned_by = 'PHOTOGRAPHER'
      order by 3;

   cursor c7(v_umo integer) is select * from umo where  umo_id = v_umo;

   c3rec	      c3%ROWTYPE;
   c4rec	      c4%ROWTYPE;
   c5rec	      c5%ROWTYPE;
   umrec	      c7%ROWTYPE;
   theme_rec   	      theme_types%ROWTYPE;
   pfx	      	      THEME%ROWTYPE;

   lValue         varchar2(32767);
   lLabel	  varchar2(100);
   lLoginType     varchar2(100);
   lPhotoName     varchar2(100);
   lTabImage      varchar2(100);
   lLastCategory  varchar2(100);
   lFirstCategory varchar2(100);
   lActiveTab     varchar2(100);
   lTabAnchor     varchar2(1000);
   lTabStyle      varchar2(1000);
   lScreenType	  integer;
   lOwnerId	  integer;
   lStatus        varchar2(100);
   lActiveGroup   integer;
   nme		  varchar2(1000);
   button_found   boolean;
   qmode	  boolean;
   isp		  boolean;
   defnam	  glbx.myarray;
   defval	  glbx.myarray;

begin
   glbx.cookie_id(surl, lScreenType, lLoginType, lOwnerId, lStatus, 'S', progcalled=>'ANBG.IMAGE_DISPLAY2');
   if lStatus is not null then
      glbx.redisplay_login_page( lStatus );
      return;
   end if;

   open c5(lOwnerId, lLoginType, acid );
   fetch c5 into c5rec;
   close c5;
   pfx := glbx.get_thm( c5rec.theme_name );
   isp := FALSE;
   if ispopup = 'T' then isp := TRUE; end if;
   --
   -- Initialise
   --
   lLastCategory  := '<none>';
   lFirstCategory := null;
   lActiveTab     := nvl(p_active_tab,'All Details');
   --
   -- Set the active tab image
   --
   if lActiveTab = FULL_IMAGE_TAB then
      lTabImage := 'anbg_tabx.gif';
   else
      lTabImage := 'anbg_tab.gif';
   end if;
   --
   -- Create anchor for tabs
   --
   lTabAnchor :=  'anbg.image_display2'   ||
                  '?surl='                || surl ||
                  '&acid='                || acid ||
                  '&v_umo='               || v_umo ||
                  '&footer_api='          || footer_api ||
                  '&left_api_parm='       || left_api_parm ||
                  '&current_page_number=' || current_page_number ||
                  '&recno=' || recno ||
                  '&rectotal=' || rectotal ||
                  '&currno=' || currno ||
                  '&ispopup=' || ispopup ||
                  '&p_active_tab=';
   lTabStyle  :=  'nowrap width=130 height=32 ' ||
                  'style="' ||
                  'width: 130; height: 32; ' ||
                  'background-color: ' || BACKGROUND_COLOUR || '; ' ||
                  'background: no-repeat bottom url(' || DECS.IMAGE_LOCATION || 'abg/';
   --
   -- Retrieve image details
   --
   if v_umo is not null
    then
     open c7(v_umo);
     fetch c7 into umrec;
     close c7;
   end if;

   --
   -- Setup the page
   --
   glbx.main_title(
         surl,
         lPhotoName,
         glbx.backimg(surl,acid,pfx.fullimg_back,null,lLoginType),
         helpid=>'C09',
         stype=>lScreenType,
         sstyle=>pfx.fullimg_text_font,
         sclr=>pfx.fullimg_text_colour,
         det_sstyle=>pfx.title_text_font,
         det_sclr=>pfx.title_text_colour,
         det_font=>pfx.title_colour_font,
         hover=>pfx.hover_colour,
         jscript=>pfx.javascript,
         disptop=>pfx.keep_lhf,
         finc=>pfx.text_font_inc,
         errclr=>pfx.error_text_colour,
         errfnt=>pfx.error_text_font,
         instclr=>pfx.instruct_text_colour,
         instfnt=>pfx.instruct_text_font,
         instfntinc=>pfx.instruct_font_inc,
         excolour=>pfx.caption_text_colour,
         exfont=>pfx.caption_text_font,
         ltype=>lLoginType,
         icra_label=>pfx.icra_label,
         top_padding=>pfx.top_padding,
         left_padding=>pfx.left_padding,
         ispopup=>isp,
         title_only=>isp,
         stylesh=>pfx.stylesheet
         );
   --

   defval(1) := null;
   defnam(1) := 'NAME';
   begin
     execute immediate 'select genus || ''.'' || species || decode(nvl(infrasp,''|''),''|'',null,''.'' || infrasp) nme from ibis.photo where photo_class = :1 and photo_no = :2'
      into defval(1)
       using umrec.extra_film_colour, umrec.extra_roll_id;
   exception
     when others then null;
   end;


   htp.p('<CENTER>');
   --
   -- Define form
   --
   if (c5rec.can_edit_meta_data_values = 'T')
    then
     if (lActiveTab = FULL_IMAGE_TAB or lActiveTab = null)
      then
       htp.formOpen('anbg.update_image_display', cattributes=> 'enctype="multipart/form-data"');
      else
       htp.formOpen('anbg.update_image_display');
     end if;
     htp.formHidden('pSURL', surl);
     htp.formHidden('pAccountId', nvl(acid,c5rec.aid));
     htp.formHidden('pUmoId', v_umo);
     htp.formHidden('pFooterApi', footer_api);
     htp.formHidden('pLeftApiParm', left_api_parm);
     htp.formHidden('pCurrentPageNumber', current_page_number);
     htp.formHidden('pActiveTab', p_active_tab);
     htp.formHidden('p1', '0');
     htp.formHidden('p2', '0');
     htp.formHidden('p3', '0');
     --htp.formhidden('currno', currno );
     htp.formhidden('rectotal', rectotal );
     htp.formhidden('qmode', 'F' );
     htp.formhidden('currno', recno );
     htp.formhidden('rectotal', rectotal );
     qmode := FALSE;
   end if;

   --
   -- Put the whole page in a table
   --
   htp.tableOpen(cattributes=>'border=0 celpadding=0 cellspacing=0 width="100%"');
   htp.tableRowOpen;
   htp.p('<TD>');

   htp.tableOpen(cattributes=>'border=0 celpadding=0 cellspacing=0 bgcolor="' || BACKGROUND_COLOUR || '"');
   htp.tableRowOpen(cattributes=>'align=center valign=center style="border: solid medium ' || FOREGROUND_COLOUR || '"');
   --
   -- Show tabs, the first tab is the full image
   --
   if lActiveTab = FULL_IMAGE_TAB or lActiveTab is null then
      lTabImage := 'tabx.gif';
   else
      lTabImage := 'tab.gif';
   end if;

   if (c5rec.can_edit_meta_data_values = 'T') then
   htp.tableData('&nbsp;' ||
      htf.anchor(
         lTabAnchor || FULL_IMAGE_TAB,
         FULL_IMAGE_TAB_TEXT,
         cattributes=>'style="{color: ' || BACKGROUND_COLOUR || '}"'
      ) || '&nbsp;',
      cattributes=>lTabStyle || lTabImage || ');"'
      );
   end if;

   --
   -- Loop through the groups and create the remaining tabs
   --
   for c1rec in c1(nvl(acid,c5rec.aid), 'G') loop
      if c1%ROWCOUNT = 1 then lActiveGroup := c1rec.group_id; end if;
      if lFirstCategory is null and lActiveTab is null then
         lFirstCategory := c1rec.title;
         lActiveTab := FULL_IMAGE_TAB;
      end if;
      if lActiveTab = c1rec.title then
         lTabImage := 'tabx.gif';
         lActiveGroup := c1rec.group_id;
      else
         lTabImage := 'tab.gif';
      end if;
      if c1rec.title != lLastCategory  then
         lLastCategory := c1rec.title;
         htp.tableData('&nbsp;' ||
               htf.anchor(
                     lTabAnchor || lLastCategory,
                     c1rec.title,
                     cattributes=>'STYLE="color: ' || BACKGROUND_COLOUR || '"'
                     ) || '&nbsp;',
               cattributes=>lTabStyle || lTabImage || ');"'
               );
      end if;
   end loop;

   htp.tableData('&nbsp;', cattributes=>'width="100%"');
   htp.tableRowClose;
   htp.tableClose;
   htp.p('</TD>');
   htp.tableRowClose;

   htp.tableRowOpen(cattributes=>' height="100%"');
   htp.p('<TD colspan=50 style="border: solid medium ' || FOREGROUND_COLOUR || '">');
   --
   -- Show the edit fields in a table
   --
   htp.tableOpen(cattributes=>'border=1 cellpadding=4 cellspacing=0 width="100%"');
   htp.tableRowOpen(cattributes=>'valign=top');

   if (lActiveTab = FULL_IMAGE_TAB or lActiveTab = null) and (c5rec.can_edit_meta_data_values = 'T') then
      --
      -- Display full image
      --
      htp.p('<TD>');
      htp.bold(lng.CST_TXT_216);
      htp.bold('Reload image');
      htp.formCheckbox('reload_image', 'T');
      htp.nl;
      htp.p(GLBX.UPLOAD_NAME);
      htp.nl;
      -- Only if Image exists
      if nvl(umrec.photo_master.contentlength,0) > 0
       then
        htp.p('<IMG BORDER=0 ' || ' SRC="' ||
              'ump.retrieve_uma' || '?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || v_umo || '&parm1=DISPLAY_TYPE&parm2=RAW' ||
              '&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || to_char(nvl(acid,c5rec.aid)) || '&parm1=LOGIN_TYPE&parm2=' || lLoginType ||
              '" ALT="' || umrec.extras.film_name || '">' );
       else
        htp.bold( 'Image does not exist' || ' : ' || umrec.extras.film_name );
      end if;
      htp.p('</TD>');

   else
      --
      -- Display meta data
      --
      htp.p('<TD>');

      if (c5rec.can_edit_meta_data_values = 'T') then htp.formHidden('pReloadImage', 'F'); end if;
      if (c5rec.can_edit_meta_data_values = 'T') then htp.formHidden('file', null); end if;

      --
      -- Show meta data
      --
      glbx.meta_prompt( surl=>surl, acid=>nvl(acid,c5rec.aid), ltype=>lLoginType, tgroup=>'G', v_umo=>v_umo, button_found=>button_found,
                        onegrouponly=>lActiveGroup, can_edit=>c5rec.can_edit_meta_data_values, query_mode=>qmode, default_names=>defnam, default_values=>defval, recno=>recno, rectotal=>rectotal );


      htp.p('</TD>');
   end if;
   htp.tableRowClose;
   htp.tableClose;

   htp.p('</TD>');
   htp.tableRowCLose;
   htp.tableClose;

   if (c5rec.can_edit_meta_data_values = 'T')
    then
     if dbstate = 'update' and v_umo is not null then
       htp.formSubmit('pAction', LNG.PHG_BUT_116);
    else
       htp.formSubmit('pAction', 'Insert New Details');
    end if;
   htp.formClose;
   end if;

   htp.centerClose;

   glbx.close_page( pfx );

   exception when others then
      glbx.error_details( 'ANBG',
                          'IMAGE_DISPLAY2',
                           errmsg=>sqlerrm);
end image_display2;

procedure update_image_display(
      pSURL                varchar2,
      pAccountId           integer,
      pUmoId               integer,
      pFooterApi           varchar2,
      pLeftApiParm         varchar2,
      pCurrentPageNumber   integer,
      pActiveTab           varchar2,
      p1                   GLBX.MYARRAY,
      p2                   GLBX.MYARRAY,
      p3                   GLBX.MYARRAY,
      file                 varchar2 default null,
      pReloadImage         varchar2 default null,
      pAction              varchar2 default null,
      Action               varchar2 default null,
      pCommand             varchar2 default 'update',
      qmode		   char default 'F',
      currno		   integer default 1,
      reload_image	   char default 'F',
      rectotal		   integer default null
      )
as

   cursor c1( sess_id integer ) is select count('x') from customer_meta_data_query where sessid = sess_id;
   cursor c2( tname varchar2 ) is select attribute_id from umo_attributes where sub_category = tname;
   cursor c5(sess_id integer, ltype varchar2, acid integer) is
      select p.pid,  scene_name, object_access, ca.theme_name, can_edit_meta_data_values, ca.aid
      from photographer p, customer_account ca, login_session ls
      where p.pid = ca.pid and
            ca.aid = ls.aid and
            ls.sessid = sess_id and
            ltype in ('CUSTOMER','OWNER')
     union all
      select p.pid,  scene_name, object_access, ca.theme_name, can_edit_meta_data_values, ca.aid
      from photographer p, customer_account ca
      where p.pid = ca.pid and
            ca.aid = acid and
            ltype in ('PHOTOGRAPHER')
     union all
      select p.pid,  scene_name, object_access, cp.theme_name, can_edit_meta_data_values, cp.aid
      from photographer p, login_session ls, customer_profile cp
      where p.pid = cp.pid and
            ls.aid = cp.profile_id and
            ls.sessid = sess_id and
            ltype in ('PROFILE','PROFILEG');

   c5rec		c5%ROWTYPE;
   lLoginType   	varchar2(100);
   lScreenType	 	integer;
   lOwnerId	    	integer;
   lStatus	    	varchar2(100);
   lUmoId       	integer;
   recno		integer;
   vrectotal		integer;
   pclass_id		integer;
   photo_no_id		integer;
   cnt			integer;
   pcl_tmp		varchar2(1000);
   pno_tmp		varchar2(1000);
   vpaction		varchar2(100);
   vUmoId               integer;
   acid			integer;
   succeeded		boolean;

begin
   glbx.cookie_id(pSURL, lScreenType, lLoginType, lOwnerId, lStatus, 'S', progcalled=>'ANBG.UPDATE_IMAGE_DISPLAY' );
   if lStatus is not null then
      glbx.redisplay_login_page(lStatus);
      return;
   end if;

   if pAction = 'Insert New Details'
    then
     -- Extract Photo Class and Photo No values
     open c2( 'PHOTO CLASS' );
     fetch c2 into pclass_id;
     close c2;
     open c2( 'PHOTO NO' );
     fetch c2 into photo_no_id;
     close c2;
     for j in p1.first..p1.last loop
      if p1(j) = pclass_id then pcl_tmp := p2(j); exit; end if;
     end loop;
     for j in p1.first..p1.last loop
      if p1(j) = photo_no_id then pno_tmp := p2(j); exit; end if;
     end loop;

     pcl_tmp := trim(substr(pcl_tmp,1,5));
     begin pno_tmp := to_char(round(to_number(pno_tmp))); exception when others then pno_tmp := null; end;

     -- Validate (not null, do not already exist in ibis)

     if pcl_tmp is null or pno_tmp is null
      then
       htp.htmlopen;
       glbx.header_msg( 'Invalid Values entered in for Photo Class or Photo No.' );
       glbx.header_msg( 'Hit the Back Button and enter in Valid Values.' );
       htp.htmlclose;
       return;
     end if;

     begin
      execute immediate 'select count(''x'') cnt from ibis.photo where photo_no = :1 and upper(photo_class) = :2' into cnt using to_number(pno_tmp), upper(pcl_tmp);
     exception
      when others then htp.htmlopen; glbx.header_msg( sqlerrm ); htp.htmlclose; return;
     end;

     if cnt > 0
      then
       htp.htmlopen;
       glbx.header_msg( 'A Record already Exists for this Photo Class and Photo No.' );
       glbx.header_msg( 'Hit the Back Button and enter in Unique Photo Class and Photo No values.' );
       htp.htmlclose;
       return;
     end if;

     -- insert record
     begin
      execute immediate 'insert into ibis.photo(photo_no,photo_class) values (:1,:2)' using to_number(pno_tmp), pcl_tmp;
     exception
      when others then htp.htmlopen; glbx.header_msg( sqlerrm ); htp.htmlclose; return;
     end;

     -- add new umo_record
     open c5(lOwnerId, lLoginType, pAccountId );
     fetch c5 into c5rec;
     close c5;
     ump.init( c5rec.aid, 'PHOTO', vUmoid );
     update umo um
      set
       extra_roll_id = pno_tmp,
       extra_film_colour = pcl_tmp,
       extra_film_size = 'NO_IMAGE',
       um.extras.film_name = lpad(pno_tmp,3,'0') || '_2.jpg'
     where
      umo_id = vUmoid;
     delete from customer_meta_data_query where sessid = lOwnerId;
     insert into customer_meta_data_query(order_by,sessid,umo_id) values (1,lOwnerId,vUmoid);
     succeeded := ump.umo_modify_entry( v_umo=>vUmoid, attribid=>pclass_id, key_val=>pcl_tmp, acid=>c5rec.aid, position=>1, actual_api=>null, extract_numbers=>'F');
     succeeded := ump.umo_modify_entry( v_umo=>vUmoid, attribid=>photo_no_id, key_val=>pno_tmp, acid=>c5rec.aid, position=>1, actual_api=>null, extract_numbers=>'F');
     commit;
     vpaction := LNG.PHG_BUT_116;
     -- continue on as per normal with the update

    else -- not insert new details
     vUmoid := pUmoid;
     vpaction := paction;
   end if;

   if Action = '?' -- Query Mode
    then
      htp.init;
      acct_home(pSURL,pAccountId,lLoginType);
      return;
   end if;
   glbx.meta_handle_query_action(pSURL, pAccountId, lOwnerId, lLoginType, nvl(vpaction,action), qmode, file, vUmoId, lUmoId, currno, recno, p1, p2, p3 );

   if rectotal is null
    then
     open c1( lOwnerId );
     fetch c1 into vrectotal;
     close c1;
    else
     vrectotal := rectotal;
   end if;

--glbx.dbg( 'A:' || action );
--glbx.dbg( 'B:' || pAction );
--glbx.dbg( 'C:' || currno || '-' || recno || ':' || pCurrentPageNumber );

   if Action in ('-','*-*')
    then
     image_display2(pSURL, pAccountId, lUmoId, pFooterApi, pLeftApiParm, pCurrentPageNumber, pActiveTab, currno=>null, recno=>null, rectotal=>null);

    elsif pAction = 'Insert New Details'
     then
      -- Go straight to the Load Image Screen after insert
      image_display2(pSURL, pAccountId, lUmoId, pFooterApi, pLeftApiParm, pCurrentPageNumber, 'FULL IMAGE', currno=>1, recno=>1, rectotal=>vrectotal);

    else
     image_display2(pSURL, pAccountId, lUmoId, pFooterApi, pLeftApiParm, pCurrentPageNumber, pActiveTab, currno=>currno, recno=>recno, rectotal=>vrectotal);

   end if;

end update_image_display;

procedure anbg_search( surl in varchar2, acid in integer, msg in varchar2 default null )
as
 cursor c1 is
  select attribute_id,category,sub_category,edit_type,lov_list,maxlength,mandatory,umo_type
  from umo_attributes
  where umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT','ALL') and
        queryable = 'T' and
        category in ('IMAGE','LOCATION','METADATA','NAME','PHOTO','PHOTOGRAPHER','SYSTEM','WHERE TAKEN' ) and
        displayed = 'T'
  order by sub_category;

 cursor c2( vsurl varchar2 ) is select * from login_session where securl = vsurl;
 c2rec  c2%ROWTYPE;

begin
 open c2(glbx.truncsurl( surl ) );
 fetch c2 into c2rec;
 close c2;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.formopen( 'anbg.accept_anbg_search' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'LTYPE', c2rec.login_type );

 htp.tableopen( cattributes=>'cellpadding=3 cellspacing=2 border=1 rules="NONE" frame="HSIDES,VSIDES" bgcolor="#DDDDDD"' );
  htp.tablerowopen;
   htp.p( '<TD colspan="4">' );
    htp.bold( 'Output Format' );
    htp.formselectopen( 'TY' );
     htp.formselectoption( 'HTML Table' );
     htp.formselectoption( 'CSV File' );
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.line( cattributes=>'width="50%"'), cattributes=>'align="CENTER" colspan="4" style="text-align: center;"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Quick Search ' ) || htf.formtext( 'P0', 70, 1000 ), cattributes=>'colspan="4"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.line( cattributes=>'width="50%"'), cattributes=>'align="CENTER" colspan="4" style="text-align: center;"' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Adhoc Tag Search' ), cattributes=>'colspan="4"' );
  htp.tablerowclose;
  for j in 1..5 loop
  htp.tablerowopen;
   htp.p( '<TD>' );
    htp.formselectopen( 'P1' );
     htp.formselectoption( NULL );
     for c1rec in c1 loop
      htp.formselectoption( c1rec.sub_category || '(' || c1rec.category || ')', cattributes=>'VALUE="' || c1rec.attribute_id || '"' );
     end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.p( '<TD>' );
    htp.formhidden( 'EDIT_TYPE', 'VARCHAR' );
    htp.formselectopen( 'P2' );
     htp.formselectoption( 'Matches' );
     htp.formselectoption( 'Starts With', 'SELECTED' );
     htp.formselectoption( 'Exactly Matches' );
     htp.formselectoption( 'Sounds Like' );
    htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata( htf.formtext( 'P3', 20, 100 ) );
   htp.p( '<TD>' );
    htp.formselectopen( 'P4' );
     htp.formselectoption( 'And' );
     htp.formselectoption( 'Or' );
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  end loop;

  htp.tablerowopen;
   htp.tabledata( htf.line( cattributes=>'width="50%"'), cattributes=>'align="CENTER" colspan="4" style="text-align: center;"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Search by Tag Name' ), cattributes=>'colspan="4"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '<small>% is wildcard</small>', cattributes=>'colspan="4"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Class' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'CLASS' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Family' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'FAMILY' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Species' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'SPECIES' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Genus' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'GENUS' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Acc No' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'ACCNO' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Description' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'DESCRIPTION' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Photographer' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'PHOTOGRAPHER' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Notes' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'NOTES' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Cultivar' ), cattributes=>'align="RIGHT" style="text-align: right;"' );
   htp.tabledata( htf.formhidden( 'A1', 'CULTIVAR' ) || htf.formtext( 'A2', 40, 100 ), cattributes=>'colspan="3"');
  htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION','Execute Query' );
 htp.p( '<input type="reset" value="Reset Form">');
 htp.formclose;

 htp.htmlclose;
end anbg_search;

procedure accept_anbg_search( surl in varchar2, acid in integer, ltype in varchar2, ty in varchar2, p0 in varchar2, edit_type in glbx.myarray, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, a1 in glbx.myarray, a2 in glbx.myarray, action in varchar2 )
as
  cursor c1( sctg varchar2 ) is select attribute_id from umo_attributes where sub_category = sctg;

  c1rec			c1%ROWTYPE;
  foundrec		boolean;
  empty_array		glbx.myarray;
  vp1			glbx.myarray;
  vp2			glbx.myarray;
  vp3			glbx.myarray;
  vp4			glbx.myarray;
  vp5			glbx.myarray;

begin

 if p0 is not null
  then
   cst.simple_search(surl=>glbx.rndsurl(surl),p1=>p0,acid=>acid,p3=>empty_array);
   return;
 end if;

 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    cst.meta_tag_search( surl=>surl, acctype=>ltype, p1n=>LNG.PHG_TXT_055, p1s=>'F', acid=>acid,
                         lbox=>'F', attrid=>p1, edit_type=>edit_type,
                         P1=>p2, PS=>empty_array, TAG_VALUE=>p3, AOR=>p4, PSHOW=>empty_array,
                         display_number=>null );
    return;
  end if;
 end loop;

 foundrec := FALSE;
 for j in a1.first..a1.last loop
  if a2(j) is not null
   then
    foundrec := TRUE;
    open c1( a1(j) );
    fetch c1 into c1rec;
    close c1;
    vp1(vp1.count+1) := c1rec.attribute_id;
    vp2(vp2.count+1) := 'VARCHAR';
    vp3(vp3.count+1) := 'Starts With';
    vp4(vp4.count+1) := 'And';
    vp5(vp5.count+1) := a2(j);
  end if;
 end loop;

 if foundrec
  then
    cst.meta_tag_search( surl=>surl, acctype=>ltype, p1n=>LNG.PHG_TXT_055, p1s=>'F', acid=>acid,
                         lbox=>'F', attrid=>vp1, edit_type=>vp2,
                         P1=>vp3, PS=>empty_array, TAG_VALUE=>vp5, AOR=>vp4, PSHOW=>empty_array,
                         display_number=>null );
    return;
 end if;

 cst.acct_search(surl, acid );

exception
 when others then htp.p( sqlerrm );
end accept_anbg_search;

end anbg;

/
