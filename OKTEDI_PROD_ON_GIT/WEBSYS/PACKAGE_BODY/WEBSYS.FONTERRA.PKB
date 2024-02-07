CREATE OR REPLACE package body WEBSYS.fonterra
as

-- Colour definitions
BACKGROUND_COLOUR   constant varchar2(7)   := '#ffffff';
COLOUR1             constant varchar2(7)   := '#9999FF';
COLOUR2             constant varchar2(7)   := '#99cc33';
COLOUR3             constant varchar2(7)   := '#f3f4f4';
COLOUR4             constant varchar2(7)   := '#f5f5f5';
COLOUR5             constant varchar2(7)   := '#6699cc';
COLOUR5             constant varchar2(7)   := '#cccccc';
GStatus             constant varchar2(7)   := '#336699'; -- You are viewing your search results background colour
GFClr		    constant varchar2(7)   := '#FFFFFF'; -- FOnt Colour
GSpacerClrA         constant varchar2(7)   := '#336699'; -- Spacer colour above search results message
GSpacerClrB         constant varchar2(7)   := '#FFFFFF'; -- Spacer colour below search results message
GSearch             constant varchar2(7)   := '#6699cc'; -- Middle bits background colour
GSearch2            constant varchar2(7)   := '#000000'; -- Text font colour
GSearch3            constant varchar2(7)   := '#6699cc'; -- Side bits background colour --993451
GSearch4	    constant varchar2(7)   := '#6699cc'; -- Other colours in middle bit

-- Constants
CRLF                constant varchar2(10) := CHR(13) || CHR(10);
LOGO_HEIGHT         constant integer := 51;
LOGO_WIDTH          constant integer := 152;
LOGO_ALT_CAPTION    constant varchar2(100) := 'Fonterra';
LOGO_IMAGE_NAME     constant varchar2(100) := 'fonterra_logo.gif';
IMAGE_SUB_DIR       constant varchar2(100) := 'skin/fonterra/';
ADVANCED_SKIN       constant skinType := 1;
SIMPLE_SKIN         constant skinType := 2;

HOME_TAB_HEIGHT     constant integer := 24;
HOME_TAB_WIDTH      constant integer := 53;
HOME_TAB_ALT_CAPTION constant varchar2(100) := 'Home';
HOME_TAB_IMAGE_OFF  constant varchar2(100)  := 'home.gif';
HOME_TAB_IMAGE_ON   constant varchar2(100)  := 'homex.gif';

cursor c1a(profid integer ) is select count('x') tot from profile_scenes where profile_id = profid;
cursor c1b(sess_id integer ) is select aid from login_session where sessid = sess_id;

cursor c1(cacid integer) is
   select distinct um.extras.title category,  um.umo_scene_id scene_id
   from umo um
   where  aid = cacid;

cursor c1c(cacid integer, profid integer) is
   select distinct um.extras.title category,  um.umo_scene_id scene_id
   from umo um, profile_scenes ps
   where  aid = cacid and
          ps.profile_id = profid and
          ps.umo_scene_id = um.umo_scene_id;

cursor c2(cumoid integer) is
   select distinct um.extras.photo_name name
   from umo um
   where umo_id = cumoid;

cursor c3(cumoid integer) is
   select *
   from umo um
   where um.umo_id = cumoid;

cursor c4(caid integer, cltype varchar2) is
   select name, lightid, is_default
   from  lightbox_header
   where  aid = caid and
          login_type = cltype
   order by name;

cursor c5(ctsurl varchar2) is
   select aid, login_type,sessid, application_parameters
   from login_session
   where securl = ctsurl;

cursor c6(csessid varchar2) is
   select count('x')
   from shopping_basket sb
   where sb.poid in (select poid from purchase_order where sessid = csessid);

cursor c7(csessid integer, clightid varchar2, cacid integer, cltype varchar2) is
   select count('x') tot
   from lightbox lb
   where lb.sessid = csessid and
         (( clightid is not null and lb.lightid = clightid )
         or
         ( lb.lightid is null ));
/*
               (
                  select lh.lightid
                  from lightbox_header lh
                  where lh.aid = cacid and
                        lh.login_type = cltype and
                        lh.is_default = 'T'
               )
   select
      sum(tot) tot
   from
   (
      select count('x') tot
      from lightbox lb
      where lb.sessid = csessid and
            (
               (
                  clightid is not null and lb.lightid = clightid
               )
               or
               (
                  clightid is null and lb.lightid in
                  (
                     select lh.lightid
                     from lightbox_header lh
                     where lh.aid = cacid and
                           lh.login_type = cltype -- and
                           -- lh.is_default = 'T'
                  )
               )
            )
      union all
      select count('x') tot
      from lightbox_header lh
      where lh.aid = cacid and lh.login_type = cltype and lh.is_default = 'T'

   select
      count('x')
   from
      lightbox lb
   where
      lb.sessid = csessid and
      (
      (clightid is not null and lb.lightid = clightid)
      or
      (clightid is null and lb.lightid in (select lh.lightid from lightbox_header lh where lh.aid = cacid and lh.login_type = cltype and lh.is_default = 'T'))
      );
*/

cursor c8(cprofid integer) is
   select request_authority
   from customer_profile
   where profile_id = cprofid;

c1rec 		 c1%ROWTYPE;
c2rec 		 c2%ROWTYPE;
c3rec 		 c3%rowtype;
c4rec 		 c4%ROWTYPE;
c5rec  		 c5%ROWTYPE;
c8rec 		 c8%ROWTYPE;
iCategory        integer;
tWidth           integer; -- Thumbnail width
tHeight          integer; -- Thumbnail height
number_of_pages  integer;
number_of_images integer;
number_of_images_in_order integer;
hor_but          varchar2(4000); -- Small buttons with thumbnail
owner_id         integer;
profid           integer;
appParm          varchar2(100);
lightboxLov      varchar2(4000);
lbcount          integer;
lViewType        varchar2(100);
lInLightbox      boolean;

function getAppParm(parms varchar2, parmName varchar2) return varchar2
as
   beginPos integer;
   endPos   integer;
   parmPos  integer;
   result   varchar2(1000);
begin
   parmPos := INSTR(parms, parmName);
   if parmPos = 0 then
      result := null;
   else
      beginPos := parmPos + LENGTH(parmName) + 1;
      endPos   := INSTR(parms, ';', parmPos);
      result := SUBSTR(parms, beginPos, endPos - beginPos);
   end if;
   return result;
end;

procedure disp_meta_query_search(
  surl        varchar2,
  acid        integer
  )
as
   cursor c12(intid integer) is
      select
         interest_name
      from
         interest_groups
      where
         interest_id = intid;

   cursor c12a(ttype varchar2) is
      select
         attribute_id,
         category,
         sub_category,
         edit_type,
         lov_list,
         maxlength,
         mandatory,
         umo_type
      from
         umo_attributes
      where
         umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT','ALL') and
         queryable = 'T' and
         ((business_feature is null) or (business_feature is not null and business_feature = ttype)) and
         displayed = 'T'
      order by
         category,sub_category;

   cursor c12b(ttype varchar2) is
      select
         count('x') cnt
      from
         umo_attributes
      where
         umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT','ALL') and
         queryable = 'T' and
         ((business_feature is null) or (business_feature is not null and business_feature = ttype)) and
         displayed = 'T';

   cursor c13(acid integer, ltype varchar2, sess_id integer, vpid integer) is
      select
         distinct src_name,cust_id
      from
         meta_tag_query
      where
         pid = vpid and
         nvl(aid,0) = nvl(acid,0) and
         login_type = ltype and
         ((ltype = 'PHOTOGRAPHER') or
         (ltype in ('OWNER','PROFILE')) or
         (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) )
      order by
         src_name;

   cursor c14(acid integer, srcnme varchar2, ltype varchar2, sess_id integer, vpid integer) is
      select
         *
      from
         meta_tag_query
      where
         pid = vpid and
         nvl(aid,0) = nvl(acid,0) and
         src_name = srcnme and
         login_type = ltype and
         ((ltype = 'PHOTOGRAPHER') or
         (ltype in ('OWNER','PROFILE')) or
         (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) )
      order by
         order_by;

   cursor c15(acid integer, srcnme varchar2, ltype varchar2, sess_id integer, vpid integer) is
      select
         count('x') cnt
      from
         meta_tag_query
      where
         pid = vpid and
         nvl(aid,0) = nvl(acid,0) and
         src_name = srcnme and
         login_type = ltype and
         ((ltype = 'PHOTOGRAPHER') or
         (ltype in ('OWNER','PROFILE')) or
         (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) );

   c12rec	c12%ROWTYPE;
   c12brec	c12b%ROWTYPE;
   c15rec	c15%ROWTYPE;
   cusrec    customer_account%ROWTYPE;
   foundrec	boolean;
   rowsret	integer;
   vpid		integer;
   last_umo	integer;
   isnew		char(1);
   lbox		varchar2(100);
   ltype    varchar2(100);
   owner_id integer;
   sts      varchar2(100);
   stype    varchar2(100);
   profid   integer;
   theme_rec	theme_types%ROWTYPE;
   pfx theme%ROWTYPE;
   extraJavaScript varchar2(2000);
begin
   glbx.cookie_id( surl, stype, ltype, owner_id, sts , 'S', progcalled=>'FONTERRA.DISP_META_QUERY_SEARCH', reset=>FALSE);
   if sts is not null then
      glbx.redisplay_login_page( sts );
      return;
   end if;
   lbox := glbx.userpref(cusrec.pid,cusrec.aid,'LIGHTBOX');
   cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
   theme_rec := glbx.get_theme_types(cusrec.theme_type );
   pfx := glbx.get_thm( cusrec.theme_name );
   extraJavaScript :=
      '<script type="text/javascript">' || CRLF ||
      '<!--' || CRLF ||
      'function submitForm()' || CRLF ||
      '{' || CRLF ||
      '   document.ffform1.target = "opener";' || CRLF ||
      '   document.ffform1.submit();' || CRLF ||
      '   window.close();' || CRLF ||
      '}' || CRLF ||
      '// End Javascript -->' || CRLF ||
      '</script>';
   glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, /* disptop=>pfx.keep_lhf, */ finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>extraJavaScript, ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding, /* sim_three_frame=>pfx.sim_three_frame, */lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

   if substr(pfx.search_choices,4,1) = 'T' then
      htp.bold( LNG3.ADM_TXT_954 );
      htp.nl;
      foundrec := FALSE;
      if ltype = 'PHOTOGRAPHER' then vpid := cusrec.pid; else vpid := 0; end if;
      for c13rec in c13(cusrec.aid,ltype,owner_id,vpid) loop
         if c13%ROWCOUNT = 1 then
            if pfx.search_display_style = 'S' then
               htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
            elsif pfx.search_display_style = 'E' then
               htp.tableopen( cattributes=>'cellpadding=6 cellspacing=0 border=0 rules="NONE" frame="HSIDES,VSIDES"' );
            end if;
            htp.tablerowopen;
            htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
            htp.tabledata( htf.bold(LNG.PHG_TXT_502),cattributes=>pfx.qbground);
            htp.tabledata( htf.bold(LNG.PHG_TXT_503),cattributes=>pfx.qbground);
            htp.tabledata( htf.bold(LNG4.AHC_TXT_998),cattributes=>pfx.qbground);
            htp.tablerowclose;
            foundrec := TRUE;
         end if;
         htp.tablerowopen;
            htp.tabledata( htf.anchor( 'cst.delete_query?surl=' || glbx.rndsurl(surl) || '&typ=T&p1=' || translate( c13rec.src_name,' ','+') || '&search_call=META&acid=' || acid, LNG.PHG_TXT_501),cattributes=>pfx.qcbground);
            htp.tabledata( htf.anchor( 'ump.meta_tag_search?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || '[' || cusrec.aid || ']' || replace( c13rec.src_name,' ','+') || '&start_from=1&display_detail=' || '&acid=' || acid, c13rec.src_name, cattributes=>'target="opener" onClick="window.close(); return true;"'), cattributes=>pfx.qcbground);
            htp.p( '<TD ' || pfx.qcbground || '>');
               htp.p( LNG.PHG_TXT_500 || ' ' );
               last_umo := NULL;
               open c15(cusrec.aid,c13rec.src_name,ltype,owner_id,vpid);
               fetch c15 into c15rec;
               close c15;
               for c14rec in c14(cusrec.aid,c13rec.src_name,ltype,owner_id,vpid) loop
                  htp.p(nvl(c14rec.search_item, ' ' || LNG.PHG_TXT_505));
                  htp.p( ' ' );
                  htp.bold(c14rec.value_a);
                  if c14rec.stem = 'T' then
                     htp.p( '(' || LNG2.PFM_TXT_169 || ')' );
                  end if;
                  if c14%ROWCOUNT < c15rec.cnt then
                     htp.p( ' ' || c14rec.andor || ' ' );
                  end if;
                  isnew := c14rec.notify_on_new;
                  rowsret := c14rec.rows_returned;
               end loop;
               if isnew = 'T' then htp.italic( '-' || LNG4.AHC_TXT_997 ); end if;
            htp.p( '</TD>' );
            htp.tabledata( nvl(rowsret,0),cattributes=>pfx.qcbground);
         htp.tablerowclose;
      end loop;
      if foundrec then htp.tableclose; end if;

      htp.formopen( 'cst.meta_tag_search', cattributes=>'name="ffform1" onSubmit="submitForm(); return false;"' );
      htp.formhidden( 'surl', surl );
      htp.formhidden( 'acid', acid );
      htp.formhidden( 'acctype', ltype );
      htp.formhidden( 'ps', null );
      htp.formhidden( 'pshow', null );
      if pfx.search_display_style = 'S' then
         htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
      elsif pfx.search_display_style = 'E' then
         htp.tableopen( cattributes=>'cellpadding=6 cellspacing=0 border=0 rules="NONE" frame="HSIDES,VSIDES"' );
      end if;
      htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
      htp.tabledata( htf.bold(LNG5.EXT_TXT_080),cattributes=>pfx.qcbground);
      htp.tabledata( htf.bold(LNG.PHG_TXT_504),cattributes=>pfx.qcbground);
      htp.tabledata( htf.formtext( 'P1N', 30, 100 ),cattributes=>pfx.qcbground);
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
      if pfx.search_stem = 'T' then
         htp.tabledata( LNG2.FRM_TXT_054 ,cattributes=>pfx.qcbground);
      end if;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground); -- And Or
      htp.tablerowclose;
      if pfx.search_email_on_new = 'T' then
         htp.tablerowopen;
         htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         htp.tabledata( htf.bold(LNG4.AHC_TXT_996),cattributes=>pfx.qcbground);
         htp.tabledata( htf.formcheckbox( 'P1S', 'T' ),cattributes=>pfx.qcbground);
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         if pfx.search_stem = 'T' then
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         end if;
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground); -- And Or
         htp.tablerowclose;
      end if;
      if pfx.search_ignore_lbox = 'T' then
         htp.tablerowopen;
         -- Ignore Lightbox
         htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         htp.tabledata( htf.bold(LNG4.AHC_TXT_431 || ' ' || lbox),cattributes=>pfx.qcbground);
         htp.tabledata( htf.formcheckbox( 'LBOX', 'T' ),cattributes=>pfx.qcbground);
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         if pfx.search_stem = 'T' then
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         end if;
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground); -- And Or
         htp.tablerowclose;
      end if;
      open c12b(theme_rec.theme_type);
      fetch c12b into c12brec;
      close c12b;
      --htp.p( 'X:' || theme_rec.theme_type );
      for c12arec in c12a(theme_rec.theme_type) loop
         htp.tablerowopen;
         htp.tabledata( initcap(c12arec.category),cattributes=>pfx.qbground);
         htp.tabledata( htf.formcheckbox( 'PSHOW', c12arec.sub_category,'CHECKED'),cattributes=>pfx.qcbground);
         htp.tabledata( initcap(c12arec.sub_category) || ' - ' || initcap(htf.italic( c12arec.umo_type )),cattributes=>pfx.qcbground);
         if c12arec.edit_type in ('VARCHAR','EMAIL','LINK','DATE','TIME','Keyword','SQL QUERY') then
            htp.formhidden( 'ATTRID', c12arec.attribute_id );
            htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
            htp.tabledata( htf.formselectopen( 'P1' ) || htf.formselectoption( LNG.PHG_TXT_505, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_506 ) || htf.formselectoption( LNG.PHG_TXT_508 ) || htf.formselectoption( LNG.PHG_TXT_507 ) || htf.formselectclose,cattributes=>pfx.qcbground);
            htp.tabledata( htf.formtext('TAG_VALUE',30,c12arec.maxlength),cattributes=>pfx.qcbground);
         elsif c12arec.edit_type = 'LOV' then
            htp.formhidden( 'ATTRID', c12arec.attribute_id );
            htp.formhidden( 'P1', NULL );
            htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
            htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
            glbx.meta_lov( 'TAG_VALUE', 'F', c12arec.lov_list, NULL );
            htp.p( '</TD>' );
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         elsif c12arec.edit_type = 'INTEGER' then
            htp.formhidden( 'ATTRID', c12arec.attribute_id );
            htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
            htp.tabledata( LNG2.FNM_TXT_131 || ':' || htf.formtext('P1',10,20),cattributes=>pfx.qcbground);
            htp.tabledata( LNG2.FNM_TXT_132 || ':' || htf.formtext('TAG_VALUE',10,20),cattributes=>pfx.qcbground);
         elsif c12arec.edit_type = 'NUMBER' then
            htp.formhidden( 'ATTRID', c12arec.attribute_id );
            htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
            htp.tabledata( htf.formselectopen( 'P1' ) || htf.formselectoption( '=', 'SELECTED' ) || htf.formselectoption( '<' )  || htf.formselectoption( '>' )   || htf.formselectoption( '>=' )  || htf.formselectoption( '<=' )  || htf.formselectoption( '<>' )   || htf.formselectclose,cattributes=>pfx.qcbground);
            htp.tabledata( htf.formtext('TAG_VALUE',10,20),cattributes=>pfx.qcbground);
         elsif c12arec.edit_type = 'SQL' then
             htp.formhidden( 'ATTRID', c12arec.attribute_id );
             htp.formhidden( 'P1', NULL );
             htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
             htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
             glbx.meta_sql( null, null, 'TAG_VALUE', 'F', c12arec.lov_list, NULL );
             htp.p( '</TD>' );
             htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         elsif c12arec.edit_type = 'Boolean' then
            htp.formhidden( 'ATTRID', c12arec.attribute_id );
            htp.formhidden( 'P1', NULL );
            htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
            htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
            htp.formselectopen( 'TAG_VALUE' );
            htp.formselectoption( NULL );
            htp.formselectoption( substr(c12arec.lov_list,instr(c12arec.lov_list,',')+1) );
            htp.formselectoption( substr(c12arec.lov_list,1,instr(c12arec.lov_list,',')-1) );
            htp.formselectclose;
            htp.p( '</TD>' );
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         end if;
         if pfx.search_stem = 'T' then
            htp.tabledata( htf.formcheckbox( 'PS',to_char(c12arec.attribute_id) ) ,cattributes=>pfx.qcbground);
         end if;
         if c12a%ROWCOUNT < c12brec.cnt then
            htp.tabledata( htf.formselectopen( 'AOR' ) || htf.formselectoption( 'OR','SELECTED') || htf.formselectoption( 'AND' ) || htf.formselectclose,cattributes=>pfx.qcbground);
         else
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
            htp.formhidden( 'AOR', null );
         end if;
         htp.tablerowclose;
      end loop;
      htp.tableclose;
      htp.nl;
      htp.formsubmit( null, LNG3.ADM_TXT_955 );
      htp.formclose;
   end if;
   glbx.close_page( pfx );
exception when others then
   glbx.error_details( 'FONTERRA', 'DISP_META_QUERY_SEARCH',errmsg=>sqlerrm);
end disp_meta_query_search;

/*
procedure previous_orders(
  surl varchar2,
  footer_api varchar2,
  left_api_parm varchar2,
  start_from integer default 1,
  display_detail char default null,
  acid integer default null,
  msg varchar2 default null)
as
   cursor c2( purchid integer) is
   select *
   from purchase_order
   where poid = purchid;

   cursor c3( rfq integer) is
   select *
   from simple_rfq
   where srfq_id = rfq;

   c1rec		customer_account%ROWTYPE;
   c2rec		c2%ROWTYPE;
   c3rec		c3%ROWTYPE;
   ltype		varchar2(100);
   stype		integer;
   owner_id	integer;
   profid		integer;
   sts		varchar2(100);
   pfx		THEME%ROWTYPE;
   theme_rec 	theme_types%ROWTYPE;
   ordlist	glbx.myarray;
begin
   glbx.cookie_id(surl, stype, ltype, owner_id, sts, 'S', progcalled=>'FONTERRA.PREVIOUS_ORDERS');
   if sts is not null then
      glbx.redisplay_login_page( sts, TRUE );
      return;
   end if;
   c1rec := glbx.get_cusrec(owner_id, ltype, acid, profid);
   theme_rec := glbx.get_theme_types(c1rec.theme_type);
   pfx := glbx.get_thm(c1rec.theme_name);
   htp.comment('keep lhf: ' || pfx.keep_lhf);
   -- Extract Listing of Orders
   ordlist := glbx.historic_purchase_orders(owner_id);
   glbx.main_title(surl, LNG4.AHC_TXT_631, glbx.backimg(surl, c1rec.aid, pfx.text_back, c1rec.background_img, ltype), helpid=>'C21', stype=>stype, sstyle=>pfx.text_font, sclr=>pfx.text_colour, det_sstyle=>pfx.title_text_font, det_sclr=>pfx.title_text_colour, det_font=>pfx.title_colour_font, hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding, left_padding=>pfx.left_padding, lnk=>pfx.underline_active, ispopup=>TRUE);

  -- if not dapi.init(surl, 'FONTERRA.PREVIOUS_ORDERS', acid) then
  --    dapi.initFailed(surl);
  --    return;
  -- end if;

   if ordlist.count = 0 then
      glbx.header_msg( LNG4.AHC_TXT_632 );
      htp.nl;
      htp.p( '<CENTER>' );
      htp.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid ,LNG2.PFM_TXT_027 );
      htp.p( '</CENTER>' );
      glbx.close_page( pfx );
      return;
   end if;
   htp.p( '<CENTER>' );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
   htp.tabledata(htf.bold( LNG.PHG_TXT_081 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.bold( LNG4.AHC_TXT_634 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.bold( LNG.PHG_TXT_082 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.bold( LNG2.FNM_TXT_016 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
   for j in ordlist.first..ordlist.last loop
      htp.tablerowopen;
      begin
         htp.tabledata( htf.anchor( 'fname.order_details?surl=' || glbx.rndsurl(surl) || '&vpoid=' || substr(ordlist(j),2) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid, substr(ordlist(j),2) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         if substr(ordlist(j),1,1) = 'A' then
            htp.tabledata( LNG.ORD_TXT_120,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.tabledata( '[' || htf.anchor( 'cst.mng_previous_orders?surl=' || glbx.rndsurl(surl) || '&otype=D&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&ordid=' || ordlist(j), LNG.SLD_TXT_004 ) || '] [' ||
            htf.anchor( 'cst.mng_previous_orders?surl=' || glbx.rndsurl(surl) || '&otype=C&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&ordid=' || ordlist(j), LNG4.AHC_TXT_637) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         elsif substr(ordlist(j),1,1) = 'P' then
            open c2( substr(ordlist(j),2) );
            fetch c2 into c2rec;
            close c2;
            htp.tabledata( LNG.ORD_TXT_121,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.tabledata( htf.anchor( 'fname.order_details?surl=' || glbx.rndsurl(surl) || '&vpoid=' || substr(ordlist(j),2) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid, LNG2.PFM_TXT_149 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         elsif substr(ordlist(j),1,1) = 'C' then
            open c2( substr(ordlist(j),2) );
            fetch c2 into c2rec;
            close c2;
            htp.tabledata( LNG.ORD_TXT_207,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.tabledata( htf.anchor( 'fname.order_details?surl=' || glbx.rndsurl(surl) || '&vpoid=' || substr(ordlist(j),2) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid, LNG2.PFM_TXT_149 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         elsif substr(ordlist(j),1,1) = 'W' then
            htp.tabledata( LNG4.AHC_TXT_635,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            open c2( substr(ordlist(j),2) );
            fetch c2 into c2rec;
            close c2;
            htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.tabledata( '[' || htf.anchor( 'cst.mng_previous_order?ssurl=' || glbx.rndsurl(surl) || '&otype=D&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&ordid=' || ordlist(j), LNG.SLD_TXT_004 ) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         elsif substr(ordlist(j),1,1) = 'R' then
            htp.tabledata( LNG4.AHC_TXT_636,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            open c3( substr(ordlist(j),2) );
            fetch c3 into c3rec;
            close c3;
            htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
            htp.tabledata( '[' || htf.anchor( 'cst.mng_previous_orders?surl=' || glbx.rndsurl(surl) || '&otype=D&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&ordid=' || ordlist(j), LNG.SLD_TXT_004 ) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
         end if;
      exception when others then null;
      end;
      htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   if footer_api is not null then
      htp.anchor('javascript:window.close(); return true;', '[close]');
   end if;
   htp.p('</CENTER>');
   glbx.close_page(pfx);
exception when others then
   glbx.error_details('FONTERRA', 'PREVIOUS_ORDERS', c1rec.pid, c1rec.aid, errmsg=>sqlerrm, extdet=>'left_api_parm:' || left_api_parm);
end previous_orders;
*/

procedure advancedSkin (
  surl                 varchar2,
  stype                integer,
  ltype                varchar2,
  umrec                UMP.SEARCH_RESULT_PHG,
  cusrec               CUSTOMER_ACCOUNT%ROWTYPE,
  pfx                  THEME%ROWTYPE,
  theme_rec            theme_types%ROWTYPE,
  footer_api           varchar2,
  current_page_number  integer default 1,
  search_total         integer default 0,
  display_detail       char default null,
  left_api             varchar2,
  left_api_parm        varchar2,
  cusloc               varchar2,
  lbox                 varchar2,
  acid                 integer default null,
  sessid               integer,
  msg                  varchar2
  )
as
begin
   main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg, ADVANCED_SKIN);
end advancedSkin;

procedure simpleSkin (
  surl                 varchar2,
  stype                integer,
  ltype                varchar2,
  umrec                UMP.SEARCH_RESULT_PHG,
  cusrec               CUSTOMER_ACCOUNT%ROWTYPE,
  pfx                  THEME%ROWTYPE,
  theme_rec            theme_types%ROWTYPE,
  footer_api           varchar2,
  current_page_number  integer default 1,
  search_total         integer default 0,
  display_detail       char default null,
  left_api             varchar2,
  left_api_parm        varchar2,
  cusloc               varchar2,
  lbox                 varchar2,
  acid                 integer default null,
  sessid               integer,
  msg                  varchar2
  )
as
begin
   main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg, SIMPLE_SKIN);
end simpleSkin;

procedure main_display(
  surl                 varchar2,
  stype                integer,
  ltype                varchar2,
  umrec                UMP.SEARCH_RESULT_PHG,
  cusrec               CUSTOMER_ACCOUNT%ROWTYPE,
  pfx                  THEME%ROWTYPE,
  theme_rec            theme_types%ROWTYPE,
  footer_api           varchar2,
  current_page_number  integer default 1,
  search_total         integer default 0,
  display_detail       char default null,
  left_api             varchar2,
  left_api_parm        varchar2,
  cusloc               varchar2,
  lbox                 varchar2,
  acid                 integer default null,
  sessid               integer,
  msg                  varchar2,
  skin skinType
  )
as


profile_id integer;
tot	   integer;

   procedure writeThumbnails
   as
      procedure showThumbnailSummary
      as
         line integer;
         ctr  integer;
      begin
         htp.tableOpen(cattributes=>'border="0" cellpadding="0" cellspacing="' || pfx.tnail_global_offset || '"');
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
                  line := 1;
                  ctr := 1;
                  for j in umrec.first..umrec.last loop
                     --if (MOD(j, glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype)+1) = 1) and (line <> 1) then
                     if (mod(ctr, glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype)) = 1 ) and (ctr <> 1 ) then
                        htp.tableRowClose;
                        htp.tableRowOpen(cvalign=>'top');
                     end if;
                     ctr := ctr + 1;

                     htp.p('<TD valign="bottom" width="' || tWidth || '" BGCOLOR="' || pfx.text_back || '">');
                        -- htp.tableOpen(cattributes=>'width="' || tWidth || '" cellpadding="3" cellspacing="0" border="0"');
                        if pfx.tnail_global_border = 'T' then
                           htp.tableopen( cattributes=>'rules="none" cellspacing="0" STYLE="border-width: ' || pfx.tnail_global_spacer || 'px; border-style: solid; border-color: #' || pfx.tnail_global_colour || '; background-color: #' || pfx.tnail_global_colour || ';" cellpadding="5" bgcolor="' || pfx.tnail_global_colour || '"' );
                        else
                           htp.tableOpen(cattributes=>'border="0" cellpadding="0" cellspacing="10"');
                        end if;
                           htp.tableRowOpen;
                              htp.p('<td valign="bottom" align="center" style="background-color: #' || pfx.text_back || ';">');
                                 --
                                 -- Display the thumbnail
                                 --
                                 cst.display_thumbnail(surl,ltype,umrec(j),theme_rec,pfx,footer_api,left_api_parm,current_page_number,display_detail,null,null,null,null,null,null,acid);
                              htp.p('</td>');
                           htp.tableRowClose;
                           htp.tableRowOpen;
                              htp.p('<td valign="middle" align="left" style="background-color: #' || pfx.text_back || ';">');
                                 --
                                 -- Display the small buttons
                                 --
                                 open c3(umrec(j).umo_id);
                                 fetch c3 into c3rec;
                                 close c3;
                                 -- cst.small_buttons(surl, ltype, cusrec, umrec(j) c3rec, pfx, theme_rec, null, footer_api, left_api_parm, lbox, cusloc, display_detail, current_page_number, acid, hor_but, display_detail, 'No', stype);
                                 cst.small_buttons(surl, ltype, cusrec, umrec(j), pfx, theme_rec, null, footer_api, left_api_parm, lbox, cusloc, display_detail, current_page_number, acid, hor_but, display_detail, 'Yes', stype);
                                 htp.p(hor_but);
                              htp.p('</td>');
                           htp.tableRowClose;
                           htp.tableRowOpen;
                              htp.p('<td valign="top" align="left" height="1" style="background-color: #' || pfx.text_back || ';">');
                                 htp.img(decs.image_location || IMAGE_SUB_DIR || 'dot.gif', cattributes=>'height="1" width="' || tWidth || '"');
                              htp.p('</td>');
                           htp.tableRowClose;
                           htp.tableRowOpen;
                              htp.p('<td valign="top" align="left" style="background-color: #' || pfx.text_back || ';">');
                                 --
                                 -- Checkbox and Image name
                                 --
                                 htp.formCheckbox('pChosenImage', umrec(j).umo_id, cattributes=>'id=img_' || umrec(j).umo_id);
                                 htp.p('<label style="cursor: hand;" for=img_' || umrec(j).umo_id || '>');
                                 if ltype = 'PHOTOGRAPHER' then
                                    htp.p(htf.bold(umrec(j).extras.film_name));
                                 else
                                    htp.p(htf.bold(umrec(j).extras.photo_name));
                                 end if;
                                 htp.p('</label>');
                              htp.p('</td>');
                           htp.tableRowClose;
                        htp.tableClose;
                     htp.p('</TD>');
                     line := line + 1;
                  end loop;
               else
                  htp.tableData('&nbsp;');
               end if;
            htp.tableRowClose;
         htp.tableClose;
      end;
      procedure showThumbnailDetailed
      as
         line integer;
         dbool			boolean;
         empty_array		GLBX.MYARRAY;
         lLineColour  varchar2(10);
      begin
         lLineColour := SUBSTR(pfx.qbground, INSTR(pfx.qbground, '#'), 7);
         htp.tableOpen(cattributes=>'border="0" frame="none" rules="rows" cellpadding="10" cellspacing="1"');
            htp.tableRowOpen;
               htp.tableData(htf.bold('Choose Image'), cattributes=>'wrap="yes" ' || pfx.qbground);
               htp.tableData(htf.bold('Thumbnail'), cattributes=>pfx.qbground);
               htp.tableData(htf.bold(lng.CST_TXT_012), cattributes=>pfx.qbground);
            htp.tableRowClose;
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
                  line := 1;
                  for j in umrec.first..umrec.last loop
                     htp.comment('pfx.global tnail:' || pfx.tnail_global_border);
                     htp.tableRowOpen(cvalign=>'top');
                        htp.tableData('<center>' || htf.formCheckbox('pChosenImage', umrec(j).umo_id, cattributes=>'id=img_' || umrec(j).umo_id) || '</center>', cattributes=>'valign="middle" align="center"');
                        htp.p('<TD valign="bottom" width="' || tWidth || '" BGCOLOR="' || pfx.text_back || '">');
                           -- htp.tableOpen(cattributes=>'width="' || tWidth || '" cellpadding="3" cellspacing="0" border="0"');
                           if pfx.tnail_global_border = 'T' then
                              htp.tableopen( cattributes=>'name="martijn" cellspacing=' || pfx.tnail_global_spacer || ' style="border: ' || pfx.tnail_global_spacer || ' solid #' || pfx.tnail_global_colour || '" cellpadding=5 border=0' );
                           else
                              htp.tableOpen(cattributes=>'border="0" cellpadding="0" cellspacing="10"');
                           end if;
                              htp.tableRowOpen;
                                 htp.p('<td valign="bottom" align="center">');
                                    --
                                    -- Display the thumbnail
                                    --
                                    cst.display_thumbnail(surl,ltype,umrec(j),theme_rec,pfx,footer_api,left_api_parm,current_page_number,display_detail,null,null,null,null,null,null,acid);
                                    htp.nl(cclear=>'ALL');
                                    cst.small_buttons(surl, ltype, cusrec, umrec(j), pfx, theme_rec, null, footer_api, left_api_parm, lbox, cusloc, display_detail, current_page_number, acid, hor_but, display_detail, 'Yes', stype);
                                    htp.p(hor_but);
                                    htp.p('<label for=img_' || umrec(j).umo_id || ' style="cursor: hand;">');
                                    if ltype = 'PHOTOGRAPHER' then
                                       htp.p(htf.bold(umrec(j).extras.film_name));
                                    else
                                       htp.p(htf.bold(umrec(j).extras.photo_name));
                                    end if;
                                    htp.p('</label>');
                                 htp.p('</td>');
                              htp.tableRowClose;
                           htp.tableClose;
                        htp.p('</TD>');
                        htp.p('<td>');
                           dbool := glbx.disp_mt(surl, ltype, umrec(j).umo_id, umrec(j).umo_type, substr(theme_rec.theme_data,167,1), pfx, acid, empty_array, TRUE);
                        htp.p('</td>');
                     htp.tableRowClose;
                     htp.tableRowOpen;
                        htp.p('<td colspan="3" style="margin: 1px; height: 1; border-bottom: thin solid ' || lLineColour || ';">&nbsp;</td>');
                        line := line + 1;
                     htp.tableRowClose;
                  end loop;
               else
                  htp.tableData('&nbsp;');
               end if;
            htp.tableRowClose;
         htp.tableClose;
      end;
      procedure showThumbnailList
      as
         line integer;
         lImageAnchor varchar2(2000);
      begin
         htp.tableOpen(cattributes=>'border="0" cellpadding="0" cellspacing="10"');
            htp.tableRowOpen;
               htp.tabledata(htf.bold(LNG.CST_TXT_187),cattributes=>pfx.qbground || 'valign="CENTER" align="CENTER"');
               htp.tabledata(htf.bold(LNG4.AHC_TXT_381),cattributes=>pfx.qbground || 'valign="CENTER" align="CENTER"');
               htp.tabledata(htf.bold('Date Loaded'),cattributes=>pfx.qbground || 'valign="CENTER" align="CENTER"');
               htp.tabledata(htf.bold(lng4.AHC_TXT_408),cattributes=>pfx.qbground || 'valign="CENTER" align="CENTER"');
            htp.tableRowClose;
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
                  line := 1;
                  for j in umrec.first..umrec.last loop
                     htp.tableRowOpen(cvalign=>'top');
                        htp.tableData('<center>' || htf.formCheckbox('pChosenImage', umrec(j).umo_id) || '</center>', cattributes=>'valign="middle" align="center"');
                        htp.p('<td>');
                           begin
                              lImageAnchor := 'mim.disp_acct_photo?surl=' || surl || '&photo_id=' || umrec(j).umo_id || '&footer_api=' || footer_api || '&left_api_parm=' || left_api_parm || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&how_display=HORIZONTAL';
                           exception when others then lImageAnchor := null;
                           end;
                           if pfx.fullimg_jscript_popup = 'T' then
                              begin
                                 lImageAnchor := 'javascript: window.open(''' || lImageAnchor || ''',''Full_Image'',''' || cst.popup_size(stype, umrec(j), pfx, LNG.PHG_TXT_045) || ', scrollbars=yes, resizable=yes'');void('''');';
                                 -- lImageAnchor := 'javascript: window.open(''' || lImageAnchor || ''',''Full_Image'',''height=' ||TO_CHAR(umrec(j).photo_master.getHeight + pfx.FULLIMG_POPUP_HEIGHT) || ', width=' || TO_CHAR(umrec(j).photo_master.getWidth + pfx.FULLIMG_POPUP_WIDTH) || ', scrollbars=yes, resizable=yes'');void('''');';
                              exception when others then lImageAnchor := 'false';
                              end;
                           end if;
                           if ltype = 'PHOTOGRAPHER' then
                              htp.anchor(lImageAnchor, htf.bold(umrec(j).extras.film_name));
                           else
                              htp.anchor(lImageAnchor, htf.bold(umrec(j).extras.photo_name));
                           end if;
                        htp.p('</td>');
                        htp.tableData(TO_CHAR(umrec(j).date_created, LNG.MASK));
                        -- cst.image_statistics(ltype, theme_rec, umrec(j));
                     line := line + 1;
                     htp.tableRowClose;
                  end loop;
               else
                  htp.tableData('&nbsp;');
               end if;
            htp.tableRowClose;
         htp.tableClose;
      end;
   begin
      htp.tableOpen(cattributes=>'border="0" cellpadding="2" cellspacing="0"');
         htp.tableRowOpen;
            htp.p('<td align="left" valign="middle">');
               --
               -- Link to pages
               --
               htp.p('<font face="Verdana, Arial, Helvetica, sans-serif" size="1" color="#000000">');
               htp.p('Go to page ');
               htp.formText('pGotoPage', '3', '3', cattributes=>'style="font-family: Verdana, Arial, Helvetica, sans-serif; font-size: xx-small; vertical-align: middle;"');
               htp.p(' of ' || number_of_pages);
               htp.anchor('javascript:submitForm(''GOTO PAGE'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'go3.gif', cattributes=>'border="0" style="vertical-align: middle;"'));
               -- htp.formHidden('start_from', ceil(current_page_number/number_of_images));
            htp.p('</td>');
            htp.p('<td align="right" valign="middle">');
            --htp.p( 'Footer:' || footer_api ); htp.nl;
            --htp.p( 'LAP:' || left_api_parm ); htp.nl;
               -- if (number_of_pages > 1) and (umrec.last < search_total) then
               --htp.p( 'X:' || current_page_number ); htp.nl;
               --htp.p( 'Y:' || number_of_images ); htp.nl;
               --htp.p( 'Z:' || search_total ); htp.nl;
               if (number_of_pages > 1) and ((current_page_number  + number_of_images) <= search_total) then
                  if lInLightbox then
                     htp.anchor('cst.disp_lightbox' || '?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=' || to_char(current_page_number  + number_of_images) || '&display_detail=' || display_detail || '&acid=' || acid, htf.img(decs.image_location || IMAGE_SUB_DIR || 'next.gif', cattributes=>'border="0" width="41" height="12" style="float: right;"'));
                  else
                     htp.anchor(nvl( footer_api, 'cst.disp_category') || '?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=' || to_char(current_page_number  + number_of_images) || '&display_detail=' || display_detail || '&acid=' || acid, htf.img(decs.image_location || IMAGE_SUB_DIR || 'next.gif', cattributes=>'border="0" width="41" height="12" style="float: right;"'));
                  end if;
               else
                  htp.img(decs.image_location || IMAGE_SUB_DIR || 'spacer.gif', cattributes=>'border="0" width="41" height="12" style="float: right;"');
               end if;
               if (number_of_pages > 1) and (current_page_number > number_of_images) then
                  if lInLightbox then
                     htp.anchor('cst.disp_lightbox?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=' || TO_CHAR(greatest(1,umrec.first - number_of_images)) || '&display_detail=' || display_detail || '&acid=' || acid, htf.img(decs.image_location || IMAGE_SUB_DIR || 'previous.gif', cattributes=>'border="0" width="66" height="12" style="float: right;"'));
                  else
                     htp.anchor(nvl( footer_api, 'cst.disp_category') || '?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=' || TO_CHAR(greatest(1,umrec.first - number_of_images)) || '&display_detail=' || display_detail || '&acid=' || acid, htf.img(decs.image_location || IMAGE_SUB_DIR || 'previous.gif', cattributes=>'border="0" width="66" height="12" style="float: right;"'));
                  end if;
               else
                  htp.img(decs.image_location || IMAGE_SUB_DIR || 'spacer.gif', cattributes=>'border="0" width="66" height="10" style="float: right;"');
               end if;
            htp.p('</td>');
         htp.tableRowClose;
         htp.tableRowOpen;
         htp.p('<td colspan="2">');
            lViewType := getAppParm(c5rec.application_parameters, 'VIEWTYPE');
            if lViewType = 'SUMMARY' then
               showThumbnailSummary;
            elsif lViewType = 'DETAILED' then
               showThumbnailDetailed;
            elsif lViewType = 'LIST' then
               showThumbnailList;
            else
               showThumbnailSummary;
            end if;
            exception when NO_DATA_FOUND then
               htp.p('no data found');
         htp.p('</td>');
         htp.tableRowClose;
      htp.tableClose;
   end;

   procedure writeTabs
   as
      procedure writeLogo(cattributes varchar2 default null)
      as
      begin
         htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || LOGO_IMAGE_NAME, calt=>LOGO_ALT_CAPTION, cattributes=>'width="' || LOGO_WIDTH || '" height="' || LOGO_HEIGHT || '" border="0"'), cattributes=>cattributes);
      end;

      procedure writeHomeTab(cattributes varchar2 default null)
      as
      begin
         htp.tableData(htf.anchor('glbx.acct_home?surl=' || surl, htf.img(decs.image_location || IMAGE_SUB_DIR || HOME_TAB_IMAGE_OFF, cattributes=>'name="home_tab" width="' || HOME_TAB_WIDTH || '" height="' || HOME_TAB_HEIGHT || '" border="0" alt="' || HOME_TAB_ALT_CAPTION || '"'), cattributes=>'onMouseOut="home_tab.src=''' || decs.image_location || IMAGE_SUB_DIR || HOME_TAB_IMAGE_OFF || '''" onMouseOver="home_tab.src=''' || decs.image_location || IMAGE_SUB_DIR || HOME_TAB_IMAGE_ON || '''"'), calign=>'top', cattributes=>'width="' || HOME_TAB_WIDTH || '"');
      end;
   begin
      htp.tableOpen(cattributes=>'width="100%" border="0" cellspacing="0" cellpadding="0"');
         --
         -- Piction Logo
         --
         htp.tableRowOpen(cvalign=>'top');
            -- htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'fonterra_logo.gif', calt=>'Fonterra', cattributes=>'width="152" height="51" border="0"'), ccolspan=>'2', crowspan=>'2', calign=>'left', cattributes=>'bgcolor="#cccccc"');
            writeLogo('colspan="2" rowspan="2" align="left" bgcolor="#cccccc"');
            htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'spacer.gif', cattributes=>'width="1" height="27"'), calign=>'left', cattributes=>'width="507" bgcolor="#cccccc"');
            -- htp.tableData('&nbsp;', crowspan=>'2');
         htp.tableRowClose;
         htp.tableRowOpen(cvalign=>'top');
            htp.p('<td width="100%" align="left">');
               htp.tableOpen(cattributes=>'width="100%" border="0" cellspacing="0" cellpadding="0" background="' || decs.image_location || IMAGE_SUB_DIR || 'fill5.gif"');
                  htp.tableRowOpen;
                     htp.p('<td align="left" valign="top">');
                        htp.tableOpen(cattributes=>'width="100%" border="0" cellspacing="0" cellpadding="0" background="' || decs.image_location || IMAGE_SUB_DIR || 'fill5.gif"');
                           htp.tableRowOpen;
                              htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'fill1.gif', cattributes=>'width="23" height="24"'), calign=>'left', cattributes=>'width="23"');
                              if (cst.is_bf(theme_rec, ltype, 205, 206, 'T', 'T', 267, 'T')) then
                                 htp.tableData(htf.anchor('javascript:submitForm(''IMAGE BASKET'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'basket.gif', cattributes=>'name="basket112" width="100" height="24" border="0"'), cattributes=>'onMouseOut="basket112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'basket.gif''" onMouseOver="basket112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'basketx.gif''"'), calign=>'top', cattributes=>'width="100"');
                              end if;
                              if (cst.is_bf(theme_rec, ltype, 182, 185, 'T', 'T', 269, 'T')) then
                                 htp.tableData(htf.anchor('javascript:submitForm(''MANAGE LIGHTBOX'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'mnglb.gif', cattributes=>'name="search112" width="112" height="24" border="0"'), cattributes=>'onMouseOut="search112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'mnglb.gif''" onMouseOver="search112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'mnglbx.gif''"'), calign=>'top', cattributes=>'width="112"');
                              end if;
                              htp.tableData(htf.anchor('javascript:submitForm(''NEW IMAGES'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'wnew.gif', cattributes=>'name="wnew112" width="100" height="24" border="0"'), cattributes=>'onMouseOut="wnew112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'wnew.gif''" onMouseOver="wnew112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'wnewx.gif''"'), calign=>'top', cattributes=>'width="100"');
                              open c8(c5rec.aid);
                              fetch c8 into c8rec;
                              close c8;
                              if (c8rec.request_authority != 'F') then
                                 htp.tableData(htf.anchor('javascript:submitForm(''AUTHORISATION'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'auth.gif', cattributes=>'name="info112" width="100" height="24" border="0"'), cattributes=>'onMouseOut="info112.src=''' || decs.image_location || IMAGE_SUB_DIR  || 'auth.gif''" onMouseOver="info112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'authx.gif''"'), calign=>'top', cattributes=>'width="100"');
                              end if;
                              if substr(pfx.search_choices,4,1) = 'T' then
                                 htp.tableData(htf.anchor('javascript:submitForm(''META SEARCH'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'msearch.gif', cattributes=>'name="msearch112" width="100" height="24" border="0"'), cattributes=>'onMouseOut="msearch112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'msearch.gif''" onMouseOver="msearch112.src=''' || decs.image_location || IMAGE_SUB_DIR || 'msearchx.gif''"'), calign=>'top', cattributes=>'width="100"');
                              end if;
                              htp.p('<td width="100%">');
                                 htp.tableOpen(cattributes=>'border="0" cellpadding="0" cellspacing="0" width="100%"');
                                    htp.tableRowOpen;
                                       htp.tableData('&nbsp;');
                                    htp.tableRowClose;
                                 htp.tableClose;
                              htp.p('</td>');
                           htp.tableRowClose;
                        htp.tableClose;
                     htp.p('</td>');
                  htp.tableRowClose;
               htp.tableClose;
            htp.p('</td>');
         htp.tableRowClose;
      htp.tableClose;
   end;

   procedure writeStatus
   as
      statusMSG varchar2(1000);
      lActiveLBID varchar2(200);
      lLightBox varchar2(200);
   begin
      if lInLightbox then
         lActiveLBID := NVL(getAppParm(c5rec.application_parameters, 'LIGHTBOXID'), '-1');
         begin
            select name into lLightBox from lightbox_header where lightid = lActiveLBID;
         exception when others then lLightBox := 'Default';
         end;
         statusMSG := 'YOU ARE VIEWING LIGHTBOX: ' || lLightBox;
      else
         statusMSG := 'YOU ARE VIEWING YOUR SEARCH RESULTS';
      end if;
      htp.comment(c5rec.application_parameters);
      htp.tableOpen(cattributes=>'width="100%" border="0" cellspacing="0" cellpadding="0"');
         htp.tableRowOpen(cvalign=>'top');
            htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'fill2.gif', cattributes=>'width="23" height="23" border="0"'), crowspan=>'2', calign=>'left', cattributes=>'width="23"');
            htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'spacer.gif', cattributes=>'width="1" height="1"'), calign=>'left', cattributes=>'height="1" bgcolor="' || GSpacerClrA || '"');
         htp.tableRowClose;
         htp.tableRowOpen(cvalign=>'middle');
            htp.tableData('<b>' || statusMSG || '&nbsp;</b>', calign=>'left', cattributes=>'style="color: ' || GFClr || '" bgcolor="' || Gstatus || '" width="100%"');
         htp.tableRowClose;
      htp.tableClose;
   end;

   procedure writeToolbar
   as
      cursor clb(acid integer, ltype varchar2) is
      select
         nvl(name,LNG.PHG_TXT_042) name,
         lightid,
         is_default
      from
         lightbox_header
      where
         aid = acid and login_type = ltype
      order by
         name;
      clbrec clb%ROWTYPE;
      lActiveLBID varchar2(16);

      procedure writeShoppingBasket
      as
      begin
         htp.tableRowOpen;
            htp.p('<td bgcolor="' || GSearch4 || '" nowrap>');
               htp.anchor('javascript:submitForm(''IMAGE BASKET'')',
                  htf.img(decs.image_location || IMAGE_SUB_DIR || 'basket1.gif', cattributes=>'width="25" height="22" border="0"') ||
                  htf.img(decs.image_location || IMAGE_SUB_DIR || 'baskettitle.gif', cattributes=>'width="76" height="19" border="0"')
               );
            htp.p('</td>');
            htp.tableData(htf.fontopen('#000000', 'Verdana, Arial, Helvetica, sans-serif', '1') || number_of_images_in_order || ' items</font>', cattributes=>'nowrap bgcolor="#6699cc" align="center" valign="middle"');
            htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'add.gif', cattributes=>'width="53" height="22"'), cattributes=>'bgcolor="#336699" align="left" valign="middle"');
            htp.tableData(htf.fontOpen('#003366', 'Verdana, Arial, Helvetica, sans-serif', '1') || htf.anchor('javascript:submitForm(''CHOSEN IMAGES TO ORDER'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'corder.gif', cattributes=>'width="93" height="19" border="0"') || '</font>'), cattributes=>'bgcolor="#6699cc" align="left" valign="middle"');
            htp.tableData(htf.fontOpen('#003366', 'Verdana, Arial, Helvetica, sans-serif', '1') || htf.anchor('javascript:submitForm(''ALL TO ORDER'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'allorder.gif', cattributes=>'width="71" height="19" border="0"') || '</font>'), calign=>'left', cattributes=>'bgcolor="#6699cc" valign="middle"');
         htp.tableRowClose;
      end writeShoppingBasket;

      procedure writeLightbox
      as
      begin
         htp.tableRowOpen;
            htp.p('<td bgcolor="' || GSearch4 || '" align="left" valign="middle" nowrap>');
            -- htp.tableData(, cattributes=>'bgcolor="#6699cc" align="left" valign="top" width="107"');
               htp.img(decs.image_location || IMAGE_SUB_DIR || 'lb.gif', cattributes=>'width="25" height="19" border="0"');
               lActiveLBID := NVL(getAppParm(c5rec.application_parameters, 'LIGHTBOXID'), '-1');

               if ltype in ('CUSTOMER', 'PROFILEG') then
                  lightboxLov := null;
               else
                  for clbrec in clb(c5rec.aid, c5rec.login_type) loop
                     if ((lActiveLBID = '-1') and (clbrec.is_default = 'T')) or
                        ((lActiveLBID != '-1') and (clbrec.lightid = TO_NUMBER(NVL(lActiveLBID, null)))) then
                        lightboxLov := lightboxLov ||
                                       htf.formselectoption( clbrec.name, 'SELECTED',
                                       cattributes=>'VALUE="' || clbrec.lightid || '"' );
                     else
                        lightboxLov := lightboxLov ||
                                       htf.formselectoption( clbrec.name,
                                       cattributes=>'VALUE="' || clbrec.lightid || '"' );
                     end if;
                  end loop;
                  lightboxLov := htf.formSelectOpen('pLightboxId',
                                 cattributes=>'style="width: 24ex; font-size: 6pt; ' ||
                                 'font-style: Verdana, Arial, Helvetica, sans-serif; ' ||
                                 'background-color: #6699cc; color: #000000;"' ||
                                 ' onChange="submitForm(''CHANGE LIGHTBOX'');"') ||
                                 htf.formselectoption( LNG.PHG_TXT_042,
                                 cattributes=>'VALUE="0"' ) || lightboxLov ||
                                 htf.formSelectClose;
               end if;

               if lightboxLov IS NULL then
                  open c7(c5rec.sessid, null, c5rec.aid, c5rec.login_type);
                  fetch c7 into lbcount;
                  close c7;
                  -- htp.img(decs.image_location || IMAGE_SUB_DIR || 'lb.gif', cattributes=>'width="25" height="19" border="0"');
                  htp.formHidden('pLightboxId', null);
                  htp.anchor('javascript:submitForm(''VIEW LIGHTBOX'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'lbtitle.gif', cattributes=>'width="76" height="19" border="0"'));
               else
                  begin
                  if lActiveLBID = '-1' then lActiveLBID := null; end if;
                  open c7(c5rec.sessid, lActiveLBID, c5rec.aid, c5rec.login_type);
                  fetch c7 into lbcount;
                  close c7;
                  htp.comment('plightbox is not null');
                  htp.p(lightboxLov);
                  exception when others then null;
                  end;
               end if;
               htp.anchor('javascript:submitForm(''VIEW LIGHTBOX'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'viewlb.gif', cattributes=>'width="30" height="19" border="0"'));
            htp.p('</td>');
            htp.tableData(htf.fontOpen('#000000', 'Verdana, Arial, Helvetica, sans-serif', '1') || TO_CHAR(lbcount) || ' items</font>', cattributes=>'bgcolor="#6699cc" nowrap valign="middle"');
            htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'add.gif', cattributes=>'width="53" height="22"'), cattributes=>'bgcolor="#336699" align="left" valign="middle"');
            htp.tableData(htf.anchor('javascript:submitForm(''CHOSEN IMAGES TO LIGHTBOX'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'clb.gif', cattributes=>'width="94" height="19" border="0"')), cattributes=>'bgcolor="#6699cc" align="left" valign="middle"');
            htp.tableData(htf.anchor('javascript:submitForm(''ALL TO LIGHTBOX'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'alllb.gif', cattributes=>'width="71" height="19" border="0"')), cattributes=>'bgcolor="#6699cc" align="left" valign="middle"');
         htp.tableRowClose;
      end writeLightbox;

      procedure writeView
      as
      begin
         htp.tableOpen('border="0" cellspacing="0" cellpadding="0" height="100%"');
            htp.tableRowOpen;
               htp.p('<td align="left" valign="top" height="100%">');
                  htp.tableOpen(cattributes=>'border="0" cellspacing="1" cellpadding="0" bgcolor="#FFFFFF"');
                     htp.tableRowOpen;
                        htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'view.gif', cattributes=>'width="90" height="19"'));
                     htp.tableRowClose;
                     if (cst.is_bf(theme_rec,ltype,399,400,'T','T',398,'T')) then
                        htp.tableRowOpen;
                        htp.tableData(htf.anchor('javascript:submitForm(''ACCOUNT DETAILS'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'accountd.gif', cattributes=>'width="90" height="21" border="0"')));
                        htp.tableRowClose;
                     end if;
                     if (cst.is_bf(theme_rec, ltype, 393, null, 'T', 'T', 392, 'T')) then
                        htp.tableRowOpen;
                           htp.tableData(htf.anchor('javascript:submitForm(''PREVIOUS ORDERS'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'previouso.gif', cattributes=>'width="90" height="17" border="0"')));
                        htp.tableRowClose;
                     end if;
                     /*
                     htp.tableRowOpen;
                        htp.tableData(htf.anchor('javascript:submitForm(''VIEW LIGHTBOX'')',  htf.img(decs.image_location || IMAGE_SUB_DIR || 'currlb.gif', cattributes=>'width="90" height="17" border="0"')));
                     htp.tableRowClose;
                     */
                     htp.tableRowOpen;
                        htp.tableData('&nbsp;', cattributes=>'height="40" bgcolor="' || GSearch4 || '"');
                     htp.tableRowClose;

                  htp.tableClose;
               htp.p('</td>');
            htp.tableRowClose;
         htp.tableClose;
      end writeView;

      procedure writeDataview
      as
      begin
         htp.fontopen(GSearch2, 'Verdana, Arial, Helvetica, sans-serif', '1');
         htp.p('&nbsp;Data View</font>'); htp.nl; htp.p( '&nbsp;' );
         -- htp.img(decs.image_location || IMAGE_SUB_DIR || 'dataview.gif', cattributes=>'width="115" height="16"'); htp.nl;
         htp.formSelectOpen('pDataview', cattributes=>'onChange="submitForm(''DATA VIEW'');"');
         if getAppParm(c5rec.application_parameters, 'VIEWTYPE') = 'SUMMARY' then
            htp.formSelectOption('Summary', 'SELECTED');
         else
            htp.formSelectOption('Summary');
         end if;
         if getAppParm(c5rec.application_parameters, 'VIEWTYPE') = 'DETAILED' then
            htp.formSelectOption('Detailed', 'SELECTED');
         else
            htp.formSelectOption('Detailed');
         end if;
         if NOT lInLightbox then
            --
            -- Do not show if in lightbox
            --
            if getAppParm(c5rec.application_parameters, 'VIEWTYPE') = 'SLIDESHOW' then
               htp.formSelectOption('Slideshow', 'SELECTED');
            else
               htp.formSelectOption('Slideshow');
            end if;
         end if;
         if getAppParm(c5rec.application_parameters, 'VIEWTYPE') = 'LIST' then
            htp.formSelectOption('List', 'SELECTED');
         else
            htp.formSelectOption('List');
         end if;
         htp.formSelectClose;
         htp.nl;
         htp.fontopen(GSearch2, 'Verdana, Arial, Helvetica, sans-serif', '1');
         htp.p('&nbsp;View Category</font>'); htp.nl; htp.p( '&nbsp;' );
         -- htp.img(decs.image_location || IMAGE_SUB_DIR || 'viewcatagory.gif', cattributes=>'width="81" height="17"'); htp.nl;
         htp.formSelectOpen('pCategory', cattributes=>'onChange="submitForm(''VIEW CATEGORY'');"');
         tot := 0;
         open c1b(sessid);
         fetch c1b into profid;
         close c1b;
         open c1a( profid );
         fetch c1a into tot;
         close c1a;
         if tot = 0
          then
           for c1rec in c1(cusrec.aid) loop
            if umrec.first > 0 then
               if umrec(umrec.first).umo_scene_id = c1rec.scene_id then
                  htp.formSelectOption(c1rec.category, cattributes=>'SELECTED value="' || c1rec.scene_id || '"');
               else
                  htp.formSelectOption(c1rec.category, cattributes=>'value="' || c1rec.scene_id || '"');
               end if;
            else
               htp.formSelectOption(c1rec.category, cattributes=>'value="' || c1rec.scene_id || '"');
            end if;
            iCategory := iCategory + 1;
           end loop;
          else
           for c1crec in c1c(cusrec.aid,profid) loop
            if umrec.first > 0 then
               if umrec(umrec.first).umo_scene_id = c1crec.scene_id then
                  htp.formSelectOption(c1crec.category, cattributes=>'SELECTED value="' || c1crec.scene_id || '"');
               else
                  htp.formSelectOption(c1crec.category, cattributes=>'value="' || c1crec.scene_id || '"');
               end if;
            else
               htp.formSelectOption(c1crec.category, cattributes=>'value="' || c1crec.scene_id || '"');
            end if;
            iCategory := iCategory + 1;
           end loop;
         end if;
         htp.formSelectClose;
      end writeDataview;

      procedure writeSimpleSearch
      as
      begin
         htp.tableOpen(cattributes=>'border="0" cellpadding="2" cellspacing="0" width="100%"');
            htp.p('<td align="right" height="100%" valign="top" nowrap width="170">');
               htp.img(decs.image_location || IMAGE_SUB_DIR || 'searchk.gif', cattributes=>'width="115" height="16"');
               htp.formText('pKeywords', cvalue=>'', csize=>'12', cmaxlength=>'50', cattributes=>'style="height: 24px; width: 120px; float: left; display: inline;"');
               htp.anchor('javascript:submitForm(''KEYWORDSEARCH'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'go.gif', cattributes=>'border="0" style="float: right; display: inline"'));
               -- htp.p('<input type="image" src="' || decs.image_location || IMAGE_SUB_DIR || 'go.gif" alt="GO" name="pAction"');
            htp.p('</td>');
            htp.tableData('<font face="Verdana, Arial, Helvetica, sans-serif" size="1">Search results for <b>&quot;' || getAppParm(appParm, 'SEARCHEDFOR') || '&quot;</b><br><b>' || search_total || '</b> images returned', cattributes=>'width="100%" align="left" valign="middle" bgcolor="' || GSearch || '" nowrap');
         htp.tableClose;
      end writeSimpleSearch;

   begin
      htp.tableOpen(cattributes=>'cellspacing="0" cellpadding="0" border="0"');

         htp.tableRowOpen;
            htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'spacer.gif', cattributes=>'width="1" height="1"'), cattributes=>'colspan="8" align="left" valign="middle" height="1" bgcolor="' || GSpacerClrB || '"');
         htp.tableRowClose;

         htp.tableRowOpen;
            htp.p('<td valign="top">');
               if (cst.is_bf(theme_rec, ltype, 205, 206, 'T', 'T', 267, 'T')) OR (cst.is_bf(theme_rec, ltype, 182, 185, 'T', 'T', 269, 'T')) then
                  htp.tableOpen(cattributes=>'border="0" cellspacing="1" cellpadding="1" bgcolor="#FFFFFF"');
                     if (cst.is_bf(theme_rec, ltype, 205, 206, 'T', 'T', 267, 'T')) then
                        writeShoppingBasket;
                     end if;
                     if (cst.is_bf(theme_rec, ltype, 182, 185, 'T', 'T', 269, 'T')) then
                        writeLightbox;
                     end if;
                  htp.tableClose;
               else
                  htp.img(decs.image_location || IMAGE_SUB_DIR || 'spacer.gif', cattributes=>'width="350" height="1"');
               end if;
            htp.p('</td>');

            if (cst.is_bf(theme_rec,ltype,399,400,'T','T',398,'T')) OR (cst.is_bf(theme_rec, ltype, 393, null, 'T', 'T', 392, 'T'))  then
               htp.p('<td rowspan="2" valign="top" bgcolor="' || GSearch || '" style="border: 0px solid ' || GSearch4 || ';">');
                  writeView;
               htp.p('</td>');
            end if;
            htp.p('<td rowspan="2" align="center" bgcolor="' || GSearch3 || '" valign="top">');
               writeDataView;
            htp.p('</td>');
            htp.tableData('&nbsp;', cattributes=>'width="100%" rowspan="3" bgcolor="' || GSearch3 || '" ');
         htp.tableRowClose;

         htp.tableRowOpen;
            htp.p('<td align="center" valign="bottom" bgcolor="' || GSearch3 || '" >');
               writeSimpleSearch;
            htp.p('</td>');
         htp.tableRowClose;

         htp.tableRowOpen;
            htp.tableData(htf.img(decs.image_location || IMAGE_SUB_DIR || 'spacer.gif', cattributes=>'width="1" height="1"'), cattributes=>'colspan="8" align="left" valign="top" bgcolor="#333333" height="1"');
         htp.tableRowClose;

      htp.tableClose;

      htp.tableOpen(cattributes=>'style="height: 100%; width: 100%;" width="100%" border="0" cellspacing="0" cellpadding="0" style="z-index: 2;"');
         htp.tableRowOpen;
            if (SUBSTR(pfx.search_choices, 2, 1) = 'T') then
               htp.p('<td align="left" valign="top" width="170" bgcolor="#99cc33">');
                  htp.tableOpen(cattributes=>'width="170" border="0" cellpadding="0" cellspacing="1" bgcolor="#99cc33"');
                        htp.tableRowOpen;
                           htp.p('<td align="left" valign="top" width="170" height="21" bgcolor="#339900">');
                              htp.img(decs.image_location || IMAGE_SUB_DIR || 'asearch.gif', cattributes=>'width="169" height="20f"');
                           htp.p('</td>');
                        htp.tableRowClose;
                        htp.tableRowOpen;
                           htp.p('<td align="left" valign="top">');
                              htp.nl;
                              htp.img(decs.image_location || IMAGE_SUB_DIR || 'soundsl.gif', cattributes=>'width="169" height="15"');
                              htp.formText('pSoundsLike', cvalue=>'', csize=>'15', cmaxlength=>'50');
                              -- htp.p('<input type="image" src="' || decs.image_location || IMAGE_SUB_DIR || 'go2.gif" alt="GO" name="pAction2">');
                           htp.p('</td>');
                        htp.tableRowClose;
                        htp.tableRowOpen;
                           htp.p('<td align="left" valign="top">');
                              htp.nl;
                              htp.img(decs.image_location || IMAGE_SUB_DIR || 'age.gif', cattributes=>'width="169" height="15"');
                              htp.formSelectOpen('pImageFrom');
                              htp.formselectoption( '', cattributes=>'VALUE=""' );
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
                           htp.p('</td>');
                        htp.tableRowClose;
                        htp.tableRowOpen;
                           htp.p('<td align="left" valign="top">');
                              htp.nl;
                              htp.img(decs.image_location || IMAGE_SUB_DIR || 'format.gif', cattributes=>'width="169" height="15"');
                              htp.nl;
                              htp.p('<font face="Verdana, Arial, Helvetica, sans-serif" size="1" color="#000000">');
                              htp.formRadio('pFormat', 'vertical', cattributes=>'id=vertical');
                              htp.p('<label for=vertical style="cursor: hand;">vertical</label>');
                              htp.nl;
                              htp.formRadio('pFormat', 'horizontal', cattributes=>'id=horizontal');
                              htp.p('<label for=horizontal style="cursor: hand;">horizontal</label>');
                              htp.nl;
                              htp.formRadio('pFormat', 'all', cchecked => 'CHECKED', cattributes=>'id=all');
                              htp.p('<label for=all style="cursor: hand;">all</label>');
                              htp.p('</font>');
                           htp.p('</td>');
                        htp.tableRowClose;
                        htp.tableRowOpen;
                           htp.p('<td>');
                              htp.nl;
                              htp.img(decs.image_location || IMAGE_SUB_DIR || 'searchin.gif', cattributes=>'width="169" height="15"');
                              htp.tableOpen(cattributes=>'border="0" cellpadding="0" cellspacing="0"');
                                 iCategory := 0;
                                 htp.tableRowOpen;
                                    htp.formHidden('pCategories', '0');
                                    for c1rec in c1(cusrec.aid) loop
                                       if (mod(iCategory, 2) = 0) then
                                       htp.tableRowClose;
                                       htp.tableRowOpen;
                                       end if;
                                       htp.p('<TD NOWRAP>');
                                          htp.formCheckbox('pCategories', c1rec.scene_id, 'CHECKED', cattributes=>'id=cat_' || c1rec.scene_id);
                                          htp.p('<label for=cat_' || c1rec.scene_id || ' style="cursor: hand;"><font face="Verdana, Arial, Helvetica, sans-serif" size="1" color="#000000"');
                                          htp.anchor('cst.disp_category?surl=' || surl || '&' || 'left_api_parm=' || c1rec.scene_id || '&' || 'start_from=1', c1rec.category);
                                          htp.p('</font></label>');
                                       htp.p('</TD>');
                                       iCategory := iCategory + 1;
                                    end loop;
                                 htp.tableRowClose;
                              htp.tableClose;
                           htp.p('</td>');
                        htp.tableRowClose;
                        htp.tableRowOpen;
                           htp.tableData(htf.anchor('javascript:submitForm(''ADVANCEDSEARCH'')', htf.img(decs.image_location || IMAGE_SUB_DIR || 'go2.gif', cattributes=>'border="0" align="right"')), cattributes=>'align="right"');
                        htp.tableRowClose;
                        /*
                        if (cst.is_bf(theme_rec, ltype, 257, 258, 'T', 'T', 319, 'T')) then
                           htp.tableRowOpen;
                              htp.p('<td>');
                                 htp.nl;
                                 htp.img(decs.image_location || IMAGE_SUB_DIR || 'metaquery.gif', cattributes=>'width="169" height="15"');
                                 disp_meta_query_search(surl, acid);
                                 -- cst.disp_meta_query_search(surl, ltype, owner_id, profid, acid, cusrec, pfx, theme_rec);
                                 -- cst.disp_meta_query_search(surl, ltype, owner_id, profid, acid, cusrec, pfx, theme_rec);
                              htp.p('</td>');
                           htp.tableRowClose;
                        end if;
                        */
                     htp.tableRowOpen;
                        htp.tableData('&nbsp;', cattributes=>'style="height: 100%"');
                     htp.tableRowClose;
                  htp.tableClose;
                  htp.p('<div style="position: absolute; width: 172px; height: 100%; background-color: #99cc33; z-index: 0;"></div>');
               htp.p('</td>');
            else
               htp.formHidden('pCategories', 0);
            end if;
            htp.p('<td align="left" valign="top" width="100%">');
               writeThumbnails;
            htp.p('</td>');
         htp.tableRowClose;
      htp.tableClose;
   end;

begin
   htp.formClose;
   --
   -- Fetch info from login session
   --
   open c5(glbx.truncsurl(surl));
   fetch c5 into c5rec;
   close c5;
   appParm := c5rec.application_parameters;
   --
   -- Calculate total number of pages
   --
   number_of_images := 0;
   if acid is null then
      number_of_images := to_number(glbx.photo_pref(cusrec.pid,cusrec.aid,'NUMBER_PHOTOS'));
      number_of_images := nvl(number_of_images,10);
   else
      number_of_images := to_number(glbx.photo_pref(cusrec.pid,cusrec.aid,'PHOTO_DISPLAY'));
      number_of_images := nvl(number_of_images,10);
   end if;
   number_of_pages := ceil(search_total/number_of_images);
   --
   -- Get number of images in order
   --
   open c6(c5rec.sessid);
   fetch c6 into number_of_images_in_order;
   close c6;
   --
   -- Determine if we are in a lightbox
   --
   lInLightbox :=  INSTR(left_api_parm, '[LBOX:') > 0;
   htp.formOpen('fonterra.filter', cattributes=>'name="ffform1"');
   htp.formHidden('surl', surl);
   htp.formHidden('acid', acid);
   htp.formHidden('ltype', c5rec.login_type);
   htp.formHidden('pPN', '0');
   htp.formHidden('pB', '0');
   htp.formHidden('pChosenImage', '0');
   htp.formHidden('pMetaStem', '0');
   htp.formHidden('pMetaAttrId', '0');
   htp.formHidden('pMetaEditType', '0');
   htp.formHidden('pMetaP1', '0');
   htp.formHidden('pMetaTagValue', '0');
   htp.formHidden('pLeftApiParm', left_api_parm);
   htp.formHidden('footer_api', footer_api);
   htp.formHidden('start_from', '1');
   htp.formHidden('display_detail', display_detail);
   htp.formHidden('pCommand', 'KEYWORDSEARCH');
   --
   -- Create Javascript to sumbit form
   --
   htp.p(' <script type="text/javascript">
      <!--
      function startFrom()
      {
        var fromPage;
        var maxNum = ' || number_of_pages || ';
        fromPage = 1 + ((document.ffform1.pGotoPage.value-1) * ' || number_of_images || ');
        if (isNaN(fromPage)) fromPage = 1;
        if (fromPage < 1) fromPage = 1;
        if ((document.ffform1.pGotoPage.value-1) > maxNum) fromPage = 1 + ((maxNum-1) * ' || number_of_images || ');
        return (fromPage);
      }

      function submitForm(cmd)
      {
        var fromPage;
        var newPage;
        var newWin;
        var newWinName = cmd;
        newPage = false;
        switch(cmd)
        {
           case ''GOTO PAGE'':
              document.ffform1.start_from.value = String(startFrom());
              break;
           case ''ALL TO ORDER'':
           case ''ALL TO LIGHTBOX'':
              selectAll(document.ffform1, false);
              if (cmd == ''ALL TO ORDER'') cmd = ''CHOSEN IMAGES TO ORDER'';
              if (cmd == ''ALL TO LIGHTBOX'') cmd = ''CHOSEN IMAGES TO LIGHTBOX'';
              break;
           case ''DATA VIEW'':
              newPage = document.ffform1.pDataview[document.ffform1.pDataview.selectedIndex].text == ''Slideshow'';
              break;
           case ''MANAGE LIGHTBOX'':
           case ''ACCOUNT DETAILS'':
           case ''PREVIOUS ORDERS'':
           case ''AUTHORISATION'':
           case ''IMAGE BASKET'':
           case ''META SEARCH'':
              newPage = true;
              break;
        }

        if (newPage)
        {
           newWinName = "' || surl || '" + cmd.replace(/\s/, "_");
           newWin = window.open("", newWinName, ''height=600,width=800, scrollbars=yes, resizable=yes, toolbar=yes, menubar=yes'');
           if (newWin.opener == null) newWin.opener = window;
           newWin.opener.name = "opener";
           newWin.focus();
           document.ffform1.target = newWin.name;
        }
        else
        {
           document.ffform1.target = "_self";
        }
        document.ffform1.pCommand.value = cmd;
        document.ffform1.submit();
      }

      function selectAll(formObj, isInverse)
      {
         for (var i=0;i < formObj.length;i++)
         {
            fldObj = formObj.elements[i];
            if (fldObj.type == ''checkbox'')
            {
               if(isInverse)
                  fldObj.checked = (fldObj.checked) ? false : true;
               else fldObj.checked = true;
             }
         }
      }
      // End Javascript -->
   </script>');

   htp.p('</center>');
   writeTabs;
   writeStatus;
   writeToolbar;
   htp.p('<center>');
   htp.formClose;
   htp.formOpen('cst.accept_display', cattributes=>'TARGET="X"');
end main_display;

procedure filter(
  surl           varchar2,
  acid           integer,
  ltype          varchar2,
  pCategories    glbx.MyArray,
  pPN            glbx.MyArray,
  pB             glbx.MyArray,
  pChosenImage   glbx.MyArray,
  pMetaStem      glbx.MyArray,
  pMetaAttrId    glbx.MyArray,
  pMetaEditType  glbx.MyArray,
  pMetaP1        glbx.MyArray,
  pMetaTagValue  glbx.MyArray,
  pCategory      varchar2 default null,
  pKeywords      varchar2 default null,
  pAction        varchar2 default null,
  pSearchType    varchar2 default null,
  pLightbox      varchar2 default null,
  pDataView      varchar2 default null,
  pSoundsLike    varchar2 default null,
  pImageFrom     varchar2 default null,
  pFormat        varchar2 default null,
  pLeftApiParm   varchar2 default null,
  footer_api     varchar2 default null,
  start_from     integer default null,
  display_detail char default null,
  pLightboxId    varchar2 default null,
  pCommand       varchar2 default null,
  pGotoPage      varchar2 default '1'
  )
as
   dummy       varchar2(100);
   lFormat     char;
   lSoundsLike varchar2(100);
   lKeyWords   varchar2(100);
   aDummy      glbx.MyArray;
   aMetaShow   glbx.MyArray;
   i           integer;
   lLeftApiParm varchar2(100);
   lMetaSearch boolean;
   lCategories varchar2(2000);
   lLightboxId varchar2(100);
   nLightboxId integer;
   lAccountId integer;
begin
   if not dapi.init(surl, 'fonterra.FILTER', acid) then
      dapi.initFailed(surl);
      return;
   end if;
   lAccountId := dapi.getAccountId;
   --
   -- Determine if we are in a lightbox
   --
   lInLightbox :=  INSTR(pLeftApiParm, '[LBOX:') > 0;
   aDummy(1) := '0';
   if upper(pCommand) = 'KEYWORDSEARCH' then
      lKeyWords := SUBSTR(pKeyWords, 1, 50);
   else
      lKeyWords := SUBSTR(pSoundsLike, 1, 50);
   end if;
   update login_session set
      application_parameters = 'VIEWTYPE=' || upper(pDataView) || ';SEARCHEDFOR=' || lKeywords || ';LIGHTBOXID=' || pLightboxId || ';'
      where securl = glbx.truncsurl(surl);
   if upper(pCommand) = 'KEYWORDSEARCH' then
      cst.simple_search(surl, p1=>pKeyWords, p3=>pCategories, acid=>acid, age=>pImageFrom, umoids=>null);
   elsif upper(pCommand) = 'ADVANCEDSEARCH' then
      ---
      -- Search command
      --
      if pFormat = 'vertical' then
         lFormat := 'P';
      elsif pFormat = 'horizontal' then
         lFormat := 'L';
      elsif pFormat = 'all' then
         lFormat := 'A';
      end if;
      if pSoundsLike is not null then
         lKeyWords := '!' || pSoundsLike;
      else
         lKeyWords := '%';
      end if;
      for i in pCategories.first..pCategories.last loop
         if pCategories(i) != '0' then
            lCategories := pCategories(i);
         end if;
      end loop;
      if pMetaTagValue.COUNT > 1 then
         --
         -- Meta tag query
         --
         for i in pMetaAttrId.first..pMetaAttrId.last loop
            aMetaShow(i) := pMetaAttrId(i);
         end loop;
         for i in (pMetaTagValue.first+1)..pMetaTagValue.last loop
            if pMetaTagValue(i) is not null then
               lMetaSearch := TRUE;
            end if;
         end loop;
      end if;
      if lMetaSearch then
         cst.meta_tag_search(surl, ltype, null, 'F', acid,  'F', pMetaAttrId, pMetaEditType, pMetaP1, pMetaStem, pMetaTagValue, aDummy, aDummy, null);
      else
         cst.simple_search(surl, p1=>lKeyWords, p3=>pCategories, umoids=>null, acid=>acid, age=>pImageFrom, image_dim=>lFormat);
      end if;
   elsif upper(pCommand) = 'VIEW LIGHTBOX' then
      lLightboxId := pLightboxId;
      if lLightboxId = '0' then lLightboxId := null; end if;
      cst.disp_lightbox(surl, '[LBOX:' || lLightboxId || ']', start_from, display_detail, acid);

   elsif upper(pCommand) = 'SET AS DEFAULT' then
      dummy := pCommand;

   elsif upper(pCommand) = 'PREVIOUS ORDERS' then
      cst.previous_orders(surl=>surl, footer_api=>footer_api, left_api_parm=>pLeftApiParm, start_from=>start_from, display_detail=>display_detail, acid=>acid, disp_close_window=>'T');

   elsif upper(pCommand) = 'ACCOUNT DETAILS' then
      if ltype in ('PROFILEG','CUSTOMER') then
         cst.cust_contact(surl=>surl, footer_api=>footer_api, left_api_parm=>pLeftApiParm, start_from=>start_from, display_detail=>display_detail, acid=>acid, profid=>null, action=>'NEW');
      elsif ltype in ('PHOTOGRAPHER','OWNER','PROFILE') then
         cst.cust_contact(surl=>surl, footer_api=>footer_api, left_api_parm=>pLeftApiParm, start_from=>start_from, display_detail=>display_detail, acid=>acid, profid=>null, action=>'UPDATE');
      end if;

   elsif upper(pCommand) = 'NEW IMAGES' then
      cst.whatsnew(surl=>surl, left_api_parm=>pLeftApiParm, start_from=>start_from, display_detail=>display_detail, acid=>acid);

   elsif upper(pCommand) = 'CURRENT ORDER' then
      fname.acct_orders(surl=>surl);

   elsif upper(pCommand) = 'CHOSEN IMAGES TO ORDER' then
      cst.accept_display(surl, aDummy, pChosenImage, aDummy, aDummy, aDummy, aDummy, pLeftApiParm, footer_api, start_from, display_detail, add_to_trolley=>'ADD', acid=>acid);

   elsif upper(pCommand) = 'CHOSEN IMAGES TO LIGHTBOX' then
      lLightboxId := pLightboxId;
      if lLightboxId = '0' then lLightboxId := null; end if;
      cst.accept_display(surl, aDummy, pChosenImage, aDummy, aDummy, aDummy, aDummy, pLeftApiParm, footer_api, start_from, display_detail, add_lightbox=>'ADD', acid=>acid, lboxid=>lLightboxId);

   elsif upper(pCommand) = 'CHANGE LIGHTBOX' then
      begin
         lLightboxId := pLightboxId;
         if pLightboxId = '0' then lLightboxId := null; end if;
         begin
            nLightboxId := TO_NUMBER( lLightboxId );
         exception when others then
            nLightboxId := NULL;
         end;
         update lightbox_header set IS_DEFAULT = 'F' where aid = lAccountId and login_type = ltype;
         update lightbox_header set IS_DEFAULT = 'T' where aid = lAccountId and login_type = ltype and lightid = nLightboxId;
         cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'X', acid=>null);
      exception when others then
         rollback;
         htp.p('what is the problem');
      end;
      commit;

   elsif upper(pCommand) = 'DATA VIEW' then
    --glbx.dbg( 'Z1:' || footer_api );
    --glbx.dbg( 'Z2:' || pLeftApiParm );
      i := instr(pLeftApiParm, ';', 1);
      lLeftApiParm := lLeftApiParm || ';viewformat=' || pDataView;
      if i != 0 then
         lLeftApiParm := substr(pLeftApiParm, 1, i - 1);
      end if;
      if upper(pDataview) = 'SLIDESHOW' then
         sld.slideshow_category(surl=>surl, dispstyle=>'SETUP', uscid=>pCategory, acid=>acid);
      elsif upper(pDataView) = 'DETAILED' then
         if lInLightbox then
            cst.disp_lightbox(surl=>surl, left_api_parm=>pLeftapiParm, start_from=>start_from, display_detail=>display_detail, acid=>acid);
         else
           if nvl(footer_api,'cst.disp_category') = 'cst.disp_category'
            then
              cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'X', acid=>null);
            else
              execute immediate 'begin ' || nvl(footer_api,'cst.disp_category') || '(surl=>:surl, left_api_parm=>:pCategory, start_from=>:start_from, display_detail=>''X'', acid=>null); end;' using surl, pLeftApiParm, start_from;
           end if;
         end if;
      elsif upper(pDataView) = 'SUMMARY' then
         if lInLightbox then
            cst.disp_lightbox(surl=>surl, left_api_parm=>pLeftapiParm, start_from=>start_from, display_detail=>display_detail, acid=>acid);
         else
           -- cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'X', acid=>null);
           if nvl(footer_api,'cst.disp_category') = 'cst.disp_category'
            then
              cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'X', acid=>null);
            else
              execute immediate 'begin ' || nvl(footer_api,'cst.disp_category') || '(surl=>:surl, left_api_parm=>:pCategory, start_from=>:start_from, display_detail=>''X'', acid=>null); end;' using surl, pLeftApiParm, start_from;
           end if;
         end if;
      elsif upper(pDataView) = 'LIST' then
         if lInLightbox then
            cst.disp_lightbox(surl=>surl, left_api_parm=>pLeftapiParm, start_from=>start_from, display_detail=>display_detail, acid=>acid);
         else
           --cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'X', acid=>null);
           if nvl(footer_api,'cst.disp_category') = 'cst.disp_category'
            then
              cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'X', acid=>null);
            else
              execute immediate 'begin ' || nvl(footer_api,'cst.disp_category') || '(surl=>:surl, left_api_parm=>:pCategory, start_from=>:start_from, display_detail=>''X'', acid=>null); end;' using surl, pLeftApiParm, start_from;
           end if;
         end if;
      end if;
      /*
      if upper(pDataview) = 'SLIDESHOW' then
         sld.slideshow_category(surl=>surl, dispstyle=>'SETUP', uscid=>pCategory, acid=>acid);
      elsif upper(pDataView) = 'DETAILED' then
         cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'F', acid=>acid);
      elsif upper(pDataView) = 'SUMMARY' then
         cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'X', acid=>acid);
      elsif upper(pDataView) = 'LIST' then
         cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>'T', acid=>acid);
      end if;
      */
   elsif upper(pCommand) = 'VIEW CATEGORY' then
      cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>display_detail, acid=>null);
      dummy := pCommand;

   elsif upper(pCommand) = 'GOTO PAGE' then
      if lInLightbox then
         cst.disp_lightbox(surl=>surl, left_api_parm=>pLeftapiParm, start_from=>start_from, display_detail=>display_detail, acid=>acid);
      else
         cst.disp_category(surl=>surl, left_api_parm=>pCategory, start_from=>start_from, display_detail=>display_detail, acid=>acid);
      end if;

   elsif upper(pCommand) = 'MANAGE LIGHTBOX' then
      cst.mng_lightbox(surl=>surl, footer_api=>footer_api, left_api_parm=>pLeftapiParm, start_from=>'1', display_detail=>'X', acid=>acid);

   elsif upper(pCommand) = 'AUTHORISATION' then
      -- cst.auth_payment(surl, acid, null, footer_api, pLeftApiParm);
      cst.auth_payment(surl, acid, null);

   elsif upper(pCommand) = 'IMAGE BASKET' then
      fname.acct_orders(surl, ispopup=>'T');

   elsif upper(pCommand) = 'META SEARCH' then
      disp_meta_query_search(surl, acid);
   end if;
exception when others then
   glbx.error_details( 'FONTERRA', 'FILTER',errmsg=>sqlerrm);
end filter;

procedure eml(surl in varchar2, left_api_parm in varchar2 default null, search_total in integer default null, display_detail in varchar2 default null, ltype in varchar2,acid in integer, screen_location in varchar2 default null)
as
begin
 htp.nl;
 htp.p( 'For enquiries, please email <A HREF="mailto:image.library@fonterra.com">image.library@fonterra.com</A>');
end eml;

end fonterra;

/
