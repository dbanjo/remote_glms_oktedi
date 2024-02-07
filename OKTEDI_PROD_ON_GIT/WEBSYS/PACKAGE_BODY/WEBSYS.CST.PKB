CREATE OR REPLACE PACKAGE BODY WEBSYS."CST" 
as

function cust_button( pfx in THEME%ROWTYPE, gif in varchar2, element in integer default 1 ) return varchar2;
function check_cntry( phgid in integer, acid in integer, sess_id in integer ) return boolean;
function small_above_thumbnail( surl in varchar2, acid in integer, ltype in varchar2, newdt in integer, pfx in theme%ROWTYPE, umrec in umo%ROWTYPE, phg_title in varchar2 ) return varchar2;
function horizontal_meta_tags( surl in varchar2, ltype in varchar2, nmb1 in integer, nmb2 in integer, nmb3 in integer, theme_rec in theme_types%ROWTYPE, umrec in umo%ROWTYPE) return varchar2;
function fimage_object( surl in varchar2, ltype in varchar2, cusrec in customer_account%ROWTYPE, umrec in umo%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, voidrec in order_style%ROWTYPE, footer_api in varchar2, left_api_parm in varchar2, ctr in integer, acid in integer, display_detail in char, display_original in varchar2, stype in integer default 1, inhomepage in boolean default FALSE, extra_term in varchar2 default null) return varchar2;

procedure request_details( surl in varchar2, rqid in integer, pfx in THEME%ROWTYPE, acid in integer );
procedure buttons_header(surl varchar2,theme_rec in theme_types%ROWTYPE, ltype in varchar2, pfx in theme%ROWTYPE, slides in boolean, owner_id in integer, ttl in varchar2 default null);
procedure buttons_footer(surl varchar2, theme_rec in theme_types%ROWTYPE, ltype in varchar2, pfx in THEME%ROWTYPE, slides in boolean, owner_id in integer, sctype in varchar2, isleft in boolean default TRUE, stype in integer, cellspc in varchar2 default null, ttl in varchar2 default null);
procedure initialise_api_variables(surl in varchar2, sess_id in integer, ltype in varchar2, nmb1 in integer, nmb2 in integer, nmb3 in integer, cusrec in customer_account%ROWTYPE, theme_rec in theme_types%ROWTYPE, document_api out varchar2, video_api out varchar2, audio_api out varchar2, relational_api out varchar2, blueprint_api out varchar2, upref out varchar2, newdt out integer, is_local out boolean, display_original out varchar2, phg_title out varchar2 );
procedure manufacturer_object(surl in varchar2, ltype in varchar2, nmb1a in integer, nmb2a in integer, nmb3a in integer, nmb1b in integer, nmb2b in integer, nmb3b in integer, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, umrec in umo%ROWTYPE, close_tabledata in boolean DEFAULT TRUE );
procedure preselect_price( surl in varchar2, ltype in varchar2, is_local in boolean, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, umrec in umo%ROWTYPE, voidrec in order_style%ROWTYPE );

procedure disp_advanced_search(surl in varchar2, ltype in varchar2, owner_id in integer, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE );
procedure disp_manufacturer_search(surl in varchar2, ltype in varchar2, owner_id in integer, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, style in varchar2 default 'STANDARD' );

procedure disp_by_scene_buttons_standard
  (surl in varchar2, sess_id integer, ltype in varchar2, title in varchar2, umrec in UMP.SEARCH_RESULT_PHG, cusrec in customer_account%ROWTYPE, left_api_parm in varchar2,
   start_from in integer, search_total in integer, footer_api in varchar2, numb_photos in integer,
   lbox in varchar2, lboxall in varchar2,
   theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE, dispvert in varchar2 default 'T', acid in integer default null, show_vertically in boolean, pbook in phg_price_book%ROWTYPE );
procedure disp_by_scene_buttons_grouped
  (surl in varchar2, sess_id integer, ltype in varchar2, title in varchar2, umrec in UMP.SEARCH_RESULT_PHG, cusrec in customer_account%ROWTYPE, left_api_parm in varchar2,
   start_from in integer, search_total in integer, footer_api in varchar2, numb_photos in integer,
   lbox in varchar2, lboxall in varchar2,
   theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE, dispvert in varchar2 default 'T', acid in integer default null, with_title in boolean, pbook in phg_price_book%ROWTYPE );

procedure disp_by_scene_vertical( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                  umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                  footer_api in varchar2, left_api_parm in varchar2, ctr in integer default 1, overdv in char default null, acid in integer default null, sess_id in integer,
                                  no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, extra_term in varchar2 default null,image_style in varchar2 );
procedure disp_by_scene_simple_vertical( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                footer_api in varchar2, left_api_parm in varchar2, ctr in integer default 1, overdv in char default null, acid in integer default null, sess_id in integer,
                                no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, extra_term in varchar2 default null,image_style in varchar2 );
procedure disp_by_scene_horizontal( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                    umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                    footer_api in varchar2, ctr in integer default 1, overdv in char default null,
                                    left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                    no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, extra_term in varchar2 default null,image_style in varchar2);

procedure disp_by_scene_slider( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                footer_api in varchar2, current_page_number in integer default 1, display_detail in char default null,
                                left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, extra_term in varchar2 default null,image_style in varchar2);
procedure slider_main( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                footer_api in varchar2, current_page_number in integer default 1, display_detail in char default null,
                                left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, position_of_main_image_text in char);
procedure slider_thumbnails( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                footer_api in varchar2, current_page_number in integer default 1, display_detail in char default null,
                                left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, numb_tnails in integer, extra_term in varchar2 default null, image_style in varchar2);
procedure slider_search( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                footer_api in varchar2, current_page_number in integer default 1, display_detail in char default null,
                                left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE);

procedure disp_bottom( surl varchar2, ltype in varchar2, search_total in integer, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, numb_photos in integer,
                       cusloc in varchar2, pfx in THEME%ROWTYPE, c1rec in customer_account%ROWTYPE, display_detail in char default null, acid in integer default null );
procedure display_comments( surl in varchar2, umrec in UMO%ROWTYPE, theme_rec in theme_types%ROWTYPE, cusrec in customer_account%ROWTYPE, ltype in varchar2,
                            nmb1 in integer, nmb2 in integer, nmb3 in integer, nmb4 in integer, nmb5 in integer, nmb6 integer, backcol in varchar2,
                            footer_api in varchar2, left_api_parm in varchar2, current_page_number in varchar2, display_detail in varchar2, acid in integer default null, retstop in varchar2);
procedure display_who( surl in varchar2, ltype in varchar2, theme_rec theme_types%ROWTYPE, photo_id in integer, nmb1 in integer, nmb2 in integer, nmb3 in integer, nmb4 in integer, nmb5 in integer, nmb6 in integer,
                       footer_api in varchar2, left_api_parm in varchar2, current_page_number in varchar2, display_detail in varchar2, acid in integer default null, retstop in varchar2);
procedure pr_disp_nav_bar(surl in varchar2, pfx in THEME%ROWTYPE, acid in number, left_api_parm in varchar2, current_page in integer, total_records in integer, numb_photos in integer, cusloc in varchar2, footer_api in varchar2 );
procedure lov_select( select_stmt in varchar2, currvalue in varchar2 );
procedure prompt_email_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, lbox in varchar2, cusrec in customer_account%ROWTYPE, stype in integer, ltype in varchar2, owner_id in integer, lightid in integer );
procedure category_search( surl in varchar2, stype in integer, ltype in varchar2, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, p1 in varchar2 );

function is_bf( theme_rec in theme_types%ROWTYPE, ltype in varchar2, nmb1 in integer, nmb2 in integer, exp1 in char, exp2 in char, nmb3 in integer default null, exp3 in char default null )
 return boolean
as
begin
  if ltype = 'PHOTOGRAPHER' and nmb3 is null then return( FALSE ); end if;

  if ((substr(theme_rec.theme_data,nmb1,1) = exp1) and ltype in ('OWNER','PROFILE')) or
     ((substr(theme_rec.theme_data,nmb2,1) = exp2) and ltype in ('CUSTOMER','PROFILEG')) or
     ((substr(theme_rec.theme_data,nmb3,1) = exp3) and ltype = 'PHOTOGRAPHER')
   then
     return( TRUE );
  end if;
  return( FALSE );
end is_bf;

procedure screen_sze(surl varchar2, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null)
as
 cursor c1( vsurl varchar2 ) is
  select keep_lhf
  from theme t, login_session ls, customer_account ca
  where ls.securl = vsurl and
        ls.login_type in ('OWNER','CUSTOMER') and
        ls.aid = ca.aid and
        ca.theme_name = t.theme_name
 union all
  select keep_lhf
  from theme t, login_session ls, customer_account ca, customer_profile cp
  where ls.securl = vsurl and
        ls.login_type in ('PROFILE','PROFILEG') and
        ls.aid = cp.profile_id and
        cp.aid = ca.aid and
        ca.theme_name = t.theme_name;
c1rec	c1%ROWTYPE;
begin
-- SimpleSearch with an exit goes right in without a screen definition, so it can exit correctly
if substr(simplesearch,1,8) = '::EXIT::'
 then
  cst.acct_master(surl=>glbx.rndsurl(surl),stype=>1,bplatform=>'::EXIT::',simplesearch=>simplesearch,v_umo=>v_umo,v_product_id=>v_product_id,screen_name=>screen_name,screen_parms=>screen_parms,screen_type=>screen_type);
  return;
end if;

htp.htmlopen;
htp.p( '<HEAD>' );
htp.title( glbx.extract_master_parameter('PAGE_TITLE') );
-- try moving this script into the body

htp.p( '
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function fillFrame()
{
  var url1 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=1&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url2 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=2&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url3 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=3&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url4 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=4&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url5 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=5&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url6 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=6&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url7 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=7&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";

 if (parseInt(navigator.appVersion.substring(0,1)) <= 4 && navigator.appName.substring(0,9) != "Microsoft" )
  {
   location.replace("cst.acct_master?surl=' || glbx.rndsurl(surl) || '&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform +' || '"&stype=1&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '");
  }
 else
  {
  if (screen.width < 800)
   location.replace (url1 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform);
  else if ((screen.width >= 800) && (screen.width < 1024))
   location.replace (url2 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform);
  else if ((screen.width >= 1024) && (screen.width < 1280))
   location.replace (url3 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform);
  else if ((screen.width >= 1280) && (screen.width < 1400))
   location.replace (url4 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform);
  else if ((screen.width >= 1400) && (screen.width < 1600))
   location.replace (url5 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform);
  else if ((screen.width >= 1600) && (screen.width < 1900))
   location.replace (url6 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform);
  else
   location.replace (url7 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform);
   }
}
//  End -->
</script>
</HEAD>
<FRAMESET ROWS="100%,0" frameborder="no" framespacing="0" border="0" onLoad="fillFrame(); return false;">
  <FRAME NAME="xtop">
</FRAMESET>
<BODY>
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
  var url1 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=1&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url2 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=2&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url3 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=3&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url4 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=4&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url5 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=5&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url6 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=6&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";
  var url7 = "cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=7&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') || '";

  if (screen.width < 800)
   parent.xtop.location.href= url1 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 800) && (screen.width < 1024))
   parent.xtop.location.href= url2 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1024) && (screen.width < 1280))
   parent.xtop.location.href= url3 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1280) && (screen.width < 1400))
   parent.xtop.location.href= url4 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1400) && (screen.width < 1600))
   parent.xtop.location.href= url5 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else if ((screen.width >= 1600) && (screen.width < 1900))
   parent.xtop.location.href= url6 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
  else
   parent.xtop.location.href= url7 + "&bvers=" + parseFloat(navigator.appVersion) + "&bplatform=" + navigator.appName + "&bos=" + navigator.platform;
//  End -->
</script>
<NOFRAMES>' );
-- Added for mobile phone support
open c1(glbx.truncsurl(surl));
fetch c1 into c1rec;
close c1;
if c1rec.keep_lhf = 'N'
 then
  htp.anchor( 'cst.acct_master?surl=' || glbx.rndsurl(surl) || '&stype=0&simplesearch=' || translate(simplesearch,' "','++') || '&v_umo=' || translate(v_umo,' "','++') || '&v_product_id=' || translate(v_product_id,' "','++') || '&screen_name=' || translate(screen_name,' "','++') || '&screen_parms=' || translate(screen_parms,' "','++') || '&screen_type=' || translate(screen_type,' "','++') ||
              '&bvers=MOBILE&bplatform=MOBILE&bos=MOBILE', 'Click to Enter Site' );
 else
  glbx.noframe(surl,'CST.SCREEN_SZE');
end if;
--glbx.noframe(surl,'PHG.SCREEN_SZE');
htp.p( '</NOFRAMES>' );
htp.p( '</BODY>' );
htp.htmlclose;
exception when others then
 glbx.error_details( 'CST', 'ACCT_MASTER',errmsg=>sqlerrm);
end screen_sze;

procedure acct_master( surl varchar2, stype in integer default 1, bplatform in varchar2 default null, bvers in varchar2 default NULL, bos in varchar2 default null, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null )
as

 cursor c1(sesid integer) is select rowid, login_type, aid, os, browser_type from login_session where sessid = sesid;
 cursor c1p(profid integer) is select aid from customer_profile where profile_id = profid;
 cursor c2(acid integer) is select theme_name from customer_account where aid = acid;
 cursor c2a(profid integer) is select theme_name from customer_profile where profile_id = profid;
 cursor c3(acid integer) is select pid from customer_account where aid = acid;
 cursor c4(phgid integer) is select username from photographer where pid = phgid;

 c1rec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 sxtype		integer;
 owner_id	integer;
 nmb		number;
 acid		integer;
 sts		varchar2(100);
 theme_name	CUSTOMER_ACCOUNT.THEME_NAME%TYPE;
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,sxtype, ltype, owner_id, sts, 'S', progcalled=>'CST.ACCT_MASTER', ignore_cookie_check=>TRUE );
  if sts is not null
   then
    glbx.redisplay_login_page( sts, TRUE );
    return;
  end if;

  open c1(owner_id);
  fetch c1 into c1rec;
  close c1;
/*
 -- Attempt to allow the back to exit
  if c1rec.os is not null and c1rec.browser_type is not null
   then
    htp.htmlopen;
     htp.title( glbx.extract_master_parameter('PAGE_TITLE') );
     htp.p('<BODY>' );
     if upper(substr(owa_util.get_cgi_env( 'QUERY_STRING' ),1,5)) = 'SURL='
      then
       -- owa_util.print_cgi_env;
       -- return;
       htp.p( '<SCRIPT LANGUAGE="JavaScript">' );
       htp.p( 'history.go(-2)' );
       htp.p( '</SCRIPT>' );
       htp.p( '</HTML>' );
       return;
    end if;
  end if;
*/
  acid := c1rec.aid;

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
   where rowid = c1rec.rowid;
  commit;

  if ltype in ('PROFILE','PROFILEG')
   then
    open c1p(c1rec.aid);
    fetch c1p into acid;
    close c1p;
    open c2a(c1rec.aid);
    fetch c2a into theme_name;
    close c2a;
    pfx := glbx.get_thm( theme_name );
   else
    open c2(acid);
    fetch c2 into theme_name;
    close c2;
    pfx := glbx.get_thm( theme_name );
  end if;


  htp.htmlopen;

  open c3(acid);
  fetch c3 into c3rec;
  close c3;

  htp.p( '<HEAD>' || pfx.icra_label || htf.title( glbx.userpref( c3rec.pid, acid, 'MENU_BAR' )) || '</HEAD>' );
  if pfx.keep_lhf in ('L','R','2')
   then
     if pfx.disploc = 'T'
      then
       htp.framesetopen(glbx.sctrl(pfx.theme_name,'CST_OUTER_FRAME_SIZE_TOPBUTTON',stype),'100%',cattributes=>'frameborder="' || pfx.frame_border || '" framespacing="0" border="' || pfx.frame_border || '"');   --  onUnload="history.go(-1);"
       htp.frame( 'cst.acct_topx?surl=' || glbx.rndsurl(surl) || '&stypex=' || stype,'TOP');
      else
       -- Redundant code. Not needed in V5.
       open c4(c3rec.pid);
       fetch c4 into c4rec;
       close c4;
       if c4rec.username = 'STEFAN'
        then
         htp.framesetopen('70,*','100%',cattributes=>'frameborder="' || pfx.frame_border || '" framespacing="0" border="' || pfx.frame_border || '"  onUnload="history.go(-1);"');
        else
         htp.framesetopen(glbx.sctrl(pfx.theme_name,'CST_OUTER_FRAME_SIZE',stype),'100%',cattributes=>'frameborder="' || pfx.frame_border || '" framespacing="0" border="' || pfx.frame_border || '" ');   --  onUnload="history.go(-1);"
       end if;
       htp.frame( 'cst.acct_topx?surl=' || glbx.rndsurl(surl) || '&stypex=' || stype,'TOP');
     end if;

     if screen_name is not null and upper(screen_type) = 'BOTTOM'
      then
       htp.frame( screen_name || '?surl=' || glbx.rndsurl(surl) || '&screen_parms=' || replace(screen_parms,' ','+'),'CUS_BOTTOM');

     elsif pfx.bottom_frame_external is null
      then
       htp.frame( 'cst.acct_bottom?surl=' || glbx.rndsurl(surl) || '&stype=' || stype || '&simplesearch=' || replace(simplesearch,' ','+') || '&v_umo=' || replace(v_umo,' ','+') || '&v_product_id=' || replace(v_product_id,' ','+') || '&screen_name=' || replace(screen_name,' ','+') || '&screen_parms=' || replace(screen_parms,' ','+') || '&screen_type=' || replace(screen_type,' ','+'),'CUS_BOTTOM');

     else
       htp.frame( pfx.bottom_frame_external || '?surl=' || glbx.rndsurl(surl) || '&stype=' || stype,'CUS_BOTTOM');

     end if;

     htp.framesetclose;
     htp.p( '<BODY >' ); -- onUnload="history.go(-1);"
     htp.noframesopen;
      glbx.noframe(surl,'CST.ACCT_MASTER');
     htp.noframesclose;

   else
    if pfx.bottom_frame_external is null
     then
      cst.acct_bottom(surl=>glbx.rndsurl(surl),stype=>stype,simplesearch=>simplesearch,v_umo=>v_umo,v_product_id=>v_product_id,screen_name=>screen_name,screen_parms=>screen_parms,screen_type=>screen_type);
      if substr(simplesearch,1,8) = '::EXIT::' then return; end if;
     else
       execute immediate
       'begin ' || pfx.bottom_frame_external ||
       '(surl=>:surl,stype=>:stype);' ||
       'end;'
       using glbx.rndsurl(surl),stype;
    end if;
  end if;
  glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'CST', 'ACCT_MASTER',errmsg=>sqlerrm,extdet=>'User Session Id is: ' || owner_id);
end acct_master;

procedure acct_bottom(surl varchar2, stype in integer, simplesearch in varchar2 default null, v_umo in varchar2 default NULL, v_product_id in varchar2 default null, screen_name in varchar2 default null, screen_parms in varchar2 default null, screen_type in varchar2 default null)
as

 cursor c2(v_umo integer) is select * from umo um where umo_id = v_umo;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 sxtype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 frm		varchar2(20);
 empty_array	GLBX.MYARRAY;
 arr1		GLBX.MYARRAY;
 arr2		GLBX.MYARRAY;
 arr3		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl,sxtype, ltype, owner_id, sts, progcalled=>'CST.ACCT_BOTTOM' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 if pfx.keep_lhf = 'L'
  then
   htp.htmlopen;
    if pfx.icra_label is not null then htp.p( '<HEAD>' || pfx.icra_label || '</HEAD>' ); end if;
    htp.framesetopen('100%',glbx.sctrl(pfx.theme_name,'CST_INNER_FRAME_SIZE',stype),cattributes=>'frameborder="' || pfx.frame_border || '" framespacing="0" border="' || pfx.frame_border || '"');

    htp.frame( 'cst.acct_leftx?surl=' || glbx.rndsurl(surl) || '&expanded_scenes=','CUS_LEFT');
    if screen_name is not null
     then
       htp.frame( screen_name || '?surl=' || glbx.rndsurl(surl) || '&screen_parms=' || replace(screen_parms,' ','+'),'CUS_RIGHT');
    elsif trim(simplesearch) is null and trim(v_umo) is null and trim(v_product_id) is null
     then
      htp.frame( 'glbx.acct_home?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS'),'CUS_RIGHT');
     elsif simplesearch is not null
      then
       if pfx.search_before_entry_api is null
        then
          htp.frame( 'cst.simple_search?surl=' || glbx.rndsurl(surl) || '&p1=' || replace(simplesearch,' ','+') || '&p3=0&acid=','CUS_RIGHT');
        else
          htp.frame( pfx.search_before_entry_api || '?surl=' || glbx.rndsurl(surl) || '&p1=' || replace(simplesearch,' ','+') || '&p3=0&acid=','CUS_RIGHT');
       end if;
     else
      -- add to basket
      open c2(v_umo);
      fetch c2 into c2rec;
      close c2;
      if c2rec.umo_type = 'MANUFACTURER'
       then
        htp.frame( 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=' || v_umo || '&p1=S' || v_product_id || '&pa=&pb=' || v_umo || '&pc=' || 'IU' || v_umo || '&ppn=&add_to_trolley=Order+Photos' || '&footer_api=QUICKBUY&left_api_parm=&current_page_number=&display_detail=&acid=','CUS_RIGHT');
       else
        htp.frame( 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=' || v_umo || '&p1=0&pa=0&pb=0&pc=' || 'IP[' || v_product_id || ']' || v_umo || '&ppn=&p1=0&add_to_trolley=Order+Photos' || '&footer_api=QUICKBUY&left_api_parm=&current_page_number=&display_detail=&acid=','CUS_RIGHT');
      end if;
    end if;
   htp.framesetclose;
   htp.p( '<BODY>' );
   htp.noframesopen;
    glbx.noframe(surl,'CST.ACCT_BOTTOM');
   htp.noframesclose;

 elsif pfx.keep_lhf = 'R'
  then
   htp.htmlopen;
    if pfx.icra_label is not null then htp.p( '<HEAD>' || pfx.icra_label || '</HEAD>' ); end if;
    frm := glbx.sctrl(pfx.theme_name,'CST_INNER_FRAME_SIZE',stype);
    htp.framesetopen('100%', substr(frm,instr(frm,',')+1) || ',' || substr(frm,1,instr(frm,',')-1),cattributes=>'frameborder="' || pfx.frame_border || '" framespacing="0" border="' || pfx.frame_border || '"');
    if screen_name is not null and screen_type = 'BOTTOM'
     then
      htp.frame( screen_name || '?surl=' || glbx.rndsurl(surl) || '&screen_parms=' || replace(screen_parms,' ','+'),'CUS_RIGHT');
      htp.framesetclose;
      htp.p( '<BODY>' );
      htp.noframesopen;
       glbx.noframe(surl,'CST.ACCT_BOTTOM');
      htp.noframesclose;
      htp.htmlclose;
      return;
    end if;

    if screen_name is not null
     then
       htp.frame( screen_name || '?surl=' || glbx.rndsurl(surl) || '&screen_parms=' || replace(screen_parms,' ','+'),'CUS_RIGHT');
    elsif trim(simplesearch) is null and trim(v_umo) is null and trim(v_product_id) is null
     then
      htp.frame( 'glbx.acct_home?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS'),'CUS_RIGHT');
     elsif simplesearch is not null
      then
       if pfx.search_before_entry_api is null
        then
         htp.frame( 'cst.simple_search?surl=' || glbx.rndsurl(surl) || '&p1=' || replace(simplesearch,' ','+') || '&p3=0&acid=','CUS_RIGHT');
        else
         htp.frame( pfx.search_before_entry_api || '?surl=' || glbx.rndsurl(surl) || '&p1=' || replace(simplesearch,' ','+') || '&p3=0&acid=','CUS_RIGHT');
       end if;
     else
      -- add to basket
      open c2(v_umo);
      fetch c2 into c2rec;
      close c2;
      if c2rec.umo_type = 'MANUFACTURER'
       then
        htp.frame( 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=' || v_umo || '&p1=S' || v_product_id || '&pa=&pb=' || v_umo || '&pc=' || 'IU' || v_umo || '&ppn=&add_to_trolley=Order+Photos' || '&footer_api=QUICKBUY&left_api_parm=&current_page_number=&display_detail=&acid=','CUS_RIGHT');
       else
        htp.frame( 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=' || v_umo || '&p1=0&pa=0&pb=0&pc=' || 'IP[' || v_product_id || ']' || v_umo || '&ppn=&p1=0&add_to_trolley=Order+Photos' || '&footer_api=QUICKBUY&left_api_parm=&current_page_number=&display_detail=&acid=','CUS_RIGHT');
      end if;
    end if;
    htp.frame( 'cst.acct_leftx?surl=' || glbx.rndsurl(surl) || '&expanded_scenes=','CUS_LEFT');
   htp.framesetclose;
   htp.p( '<BODY>' );
   htp.noframesopen;
    glbx.noframe(surl,'CST.ACCT_BOTTOM');
   htp.noframesclose;

 else

   if screen_name is not null
    then
      execute immediate 'begin ' || screen_name || '(surl=>:surl, screen_parms=>:screen_parms); end;'
       using surl, screen_parms;
   elsif trim(simplesearch) is null and trim(v_umo) is null and trim(v_product_id) is null
    then
     glbx.acct_home(surl=>glbx.rndsurl(surl), rnd=>to_char(sysdate,'SSSSS'));
   elsif simplesearch is not null
    then
     if pfx.search_before_entry_api is null
      then
       simple_search(surl=>glbx.rndsurl(surl),p1=>simplesearch,acid=>NULL,p3=>empty_array);
      else
       execute immediate 'begin ' || pfx.search_before_entry_api || '(surl=>:surl, p1=>:p1); end;'
        using surl, simplesearch;
     end if;
     return;
   else
    -- add to basket
    open c2(v_umo);
    fetch c2 into c2rec;
    close c2;
    if c2rec.umo_type = 'MANUFACTURER'
     then
      arr1(1) := '0';
      arr2(1) := '0';
      arr1(2) := v_umo;
      arr2(2) := 'IU' || v_umo;
      arr3(2) := 'S' || v_product_id;
      accept_display(surl=>surl, p0=>arr1, p1=>arr3, pa=>arr1, pb=>arr1, pc=>arr2, ppn=>empty_array, add_to_trolley=>'Order Photos', footer_api=>'QUICKBUY', left_api_parm=>NULL, display_detail=>NULL, acid=>NULL );
     else
      --arr1(2) := v_umo;
      --arr2(2) := 'IP[' || v_product_id || ']' || v_umo;
      arr1(1) := '0';
      arr3(1) := '0';
      arr3(2) := v_umo;
      accept_display(surl=>surl, p0=>arr1, p1=>arr3, pa=>arr1, pb=>arr1, pc=>arr1, ppn=>empty_array, add_to_trolley=>'Order Photos', footer_api=>'QUICKBUY', left_api_parm=>NULL, display_detail=>NULL, acid=>NULL );
    end if;
  end if;
  return;
 -- 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umorec.umo_id || '&add_to_trolley=Order+Photos'

 end if;
 glbx.close_page(pfx);
exception when others then
 glbx.error_details( 'CST', 'ACCT_BOTTOM',errmsg=>sqlerrm);
end acct_bottom;

procedure acct_showinf( surl in varchar2, typ in varchar2 )
as

 c1rec		customer_account%ROWTYPE;
 profid		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME.DISP_PREFIX%TYPE;
 tag_name	GLBX.MYARRAY;
 tag_title	GLBX.MYARRAY;

begin

glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.ACCT_SHOWINF' );
if sts is not null
 then
  glbx.redisplay_login_page( sts );
  return;
end if;

c1rec := glbx.get_cusrec( owner_id, ltype, null, profid );
if typ = 'HELP'
 then
  glbx.external_html_file( surl, c1rec, 'HELP', tag_name, tag_title );
elsif typ = 'README'
 then
  glbx.external_html_file( surl, c1rec, 'README', tag_name, tag_title );
elsif typ = 'FEEDBACK'
 then
  glbx.external_html_file( surl, c1rec, 'FEEDBACK', tag_name, tag_title );
elsif typ = 'CONTACTUS'
 then
  glbx.external_html_file( surl, c1rec, 'CONTACTUS', tag_name, tag_title );
elsif typ = 'LEGAL'
 then
  glbx.external_html_file( surl, c1rec, 'LEGAL', tag_name, tag_title );
elsif typ = 'PRIVACY'
 then
  glbx.external_html_file( surl, c1rec, 'PRIVACY', tag_name, tag_title );
end if;

exception when others then
 glbx.error_details( 'CST', 'ACCT_SHOWINF',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'TYP:' || typ);
end acct_showinf;

procedure acct_topx(surl varchar2, stypex in integer, bypass_check in varchar2 default 'F', ttl in varchar2 default NULL, helpid in varchar2 default NULL)
as

 cursor c1(acid integer) is select pid,advert,business_name,username,home_site,logo_phid,abn_number,private_gallery from photographer where pid = (select pid from customer_account where aid=acid);
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
 cursor c4(phgid integer) is select business_name from photographer ph where ph.pid = phgid;
 cursor c5(acid integer ) is select count('x') from slide_master where aid=acid;
 cursor c6(profid integer) is select request_authority from customer_profile where profile_id = profid;
 cursor c7(sess_id integer) is select browser_type from login_session where sessid = sess_id;
 cursor c8(profid integer) is select * from customer_profile where profile_id = profid;
 cursor c11(profid integer) is select count('x') from profile_scenes where profile_id = profid;

 c1rec		customer_account%ROWTYPE;
 c1arec		c1%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 tmpi		integer;
 sts		varchar2(100);
 bgcol		varchar2(100);
 pfx		THEME%ROWTYPE;
 msg		varchar2(4000);
 tmp		varchar2(2000);
 theme_rec	theme_types%ROWTYPE;
 slides		boolean;
 width		integer;
 height		integer;
 proftot	integer;
 profid		integer;
 http		varchar2(100);
 ps		char(1);
 dscroll	boolean;
 dummy		glbx.myarray;

 procedure disp_icons( pfx in THEME%ROWTYPE, typ in varchar2 )
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
   htp.tableopen( cattributes=> 'cellpadding=0 cellspacing=' || nvl(pfx.SF_BG_CELLSPC,2) || ' border=0' );
    htp.tablerowopen;
     if typ in ('I','J','K','i','j','k')
      then
       for c2rec in c2( c1rec.aid, c1rec.pid, 'ICON' ) loop
         if upper(c2rec.typ) = upper(typ) or typ = 'I'
          then
           hsite := NULL;
           http := ump.uma_attribute( surl,c2rec.umo_id, 'ICON', 'HTTP_LINK' );
           if http is null then hsite := c1arec.home_site; else hsite := http; end if;
           hsite := glbx.adjust_for_http( hsite );
           if nvl(c2rec.attribute1,'F') = 'T' or
              nvl(c2rec.attribute2,'F') = 'T'
            then
             hsite := 'cst.intercept_icon?surl=' || surl || '&v_umo=' || c2rec.umo_id;
           end if;
           width := to_number(ump.uma_attribute( surl,c2rec.umo_id, 'ICON', 'DISPLAY_WIDTH' ));
           height := to_number(ump.uma_attribute( surl,c2rec.umo_id, 'ICON', 'DISPLAY_HEIGHT' ));
           if hsite is null
             then
              htp.tabledata('<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                  '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
                  '" ALT="' || c1arec.business_name || '" STYLE="display:block;">');
           else
            htp.tabledata(htf.anchor2( hsite,'<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' ||
                  '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=OVERRIDE_DISPLAY&parm2=ICON&parm1=AID&parm2=' ||
                  '" ALT="' || nvl(http,c1arec.home_site) || '" STYLE="display:block;">',ctarget=>'_top' ));
         end if;
      end if;
     end loop;
     end if;

     if typ in ('I','L','i')
      then
       if c1arec.private_gallery is not null
        then
         htp.tabledata(htf.anchor2(glbx.adjust_for_http(c1arec.private_gallery),htf.img( DECS.IMAGE_LOCATION || 'adminc/gallery.gif',cattributes=>'border=0',calt=>lng.PHG_TXT_497 ),ctarget=>'_top'));
       end if;

        -- Authorise
        /*
        if ltype = 'PROFILE'
         then
          open c6(profid);
          fetch c6 into c6rec;
          close c6;
          if nvl(c6rec.request_authority ,'F') <> 'F'
           then
            htp.tabledata(htf.anchor2('cst.auth_payment?surl=' || glbx.rndsurl(surl),htf.img( cust_button(pfx,'authorise.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_692 ),ctarget=>'CUS_RIGHT'));
          end if;
        end if;
        */

        -- Help
        if is_bf(theme_rec,ltype,124,125,'T','T')
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=HELP',htf.img( cust_button(pfx,'help.gif',7),cattributes=>'border=0',calt=>lng.CST_ALT_022 ),ctarget=>'CUS_RIGHT'));
        end if;

        -- Readme
        if is_bf(theme_rec,ltype,353,354,'T','T')
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=README',htf.img( cust_button(pfx,'readme.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_455 ),ctarget=>'CUS_RIGHT'));
        end if;

        -- Feedback
        if is_bf(theme_rec,ltype,355,356,'T','T')
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=FEEDBACK',htf.img( cust_button(pfx,'feedback.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_456 ),ctarget=>'CUS_RIGHT'));
        end if;

        -- Contact Us
        if is_bf(theme_rec,ltype,357,358,'T','T')
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=CONTACTUS',htf.img( cust_button(pfx,'contactus.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_457 ),ctarget=>'CUS_RIGHT'));
        end if;

        -- Legal
        if is_bf(theme_rec,ltype,359,360,'T','T')
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=LEGAL',htf.img( cust_button(pfx,'legal.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_458 ),ctarget=>'CUS_RIGHT'));
        end if;

        -- Privacy
        if is_bf(theme_rec,ltype,361,362,'T','T')
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=PRIVACY',htf.img( cust_button(pfx,'privacy.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_459 ),ctarget=>'CUS_RIGHT'));
        end if;

        -- Logoff
         if glbx.userpref( c1rec.pid,c1rec.aid,'CUST_LOGOFF' ) = LNG.PHG_TXT_045
          then
            htp.tabledata(htf.anchor2('glbx.acct_logoff?surl=' || glbx.rndsurl(surl),htf.img( cust_button(pfx,'logoff.gif',7),cattributes=>'border=0',calt=>lng.CST_ALT_021 ),ctarget=>'_top'));
          elsif glbx.userpref( c1rec.pid,c1rec.aid,'CUST_LOGOFF' ) = LNG.PHG_TXT_046
          then
            htp.tabledata(htf.anchor2('glbx.acct_logoff?surl=' || glbx.rndsurl(surl),htf.img( cust_button(pfx,'home.gif',7),cattributes=>'border=0',calt=>lng.LAB_TXT_002 ),ctarget=>'_top'));
         end if;

      end if;
     htp.tablerowclose;
    htp.tableclose;
   htp.p( '</TD>' );
 end disp_icons;

 procedure disp_advert( surl in varchar2 )
 as
  tmp	varchar2(32767);
 begin
   tmp := adv.display_advert(surl,c1rec.aid,c1rec.theme_type,ltype,'TOP' );
   if tmp is not null
    then
     htp.tabledata( tmp, cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
   end if;
 end disp_advert;

 procedure disp_photographer_title
 as
 begin
   htp.tabledata('<FONT SIZE="+2">' || glbx.userpref( c1rec.pid,c1rec.aid,'TOP_MESSAGE') || '</FONT>',cattributes=>'valign="MIDDLE" ALIGN="CENTER"');
 end disp_photographer_title;

 procedure disp_scrollbar( szin in boolean default TRUE, dsp in varchar2 default null, browser_type in varchar2 )
 as
 begin

  -- New Scroll Method using Marquee
  if browser_type = 'Microsoft Internet Explorer'
   then
    if szin and msg is not null
     then
     htp.p( '<TD>' );
     if dsp = 'S' -- LOV ( S is SHORT, Q is LONG)
      then
       htp.p('<MARQUEE DIRECTION="LEFT" BEHAVIOR="SCROLL" SCROLLDELAY="250" WIDTH="' || to_char( greatest(1,round(glbx.sctrl(pfx.theme_name,'SCROLLBAR_WIDTH',least(stypex,6))/2)*12) ) || '" SCROLLAMOUNT="10">');
      else
       htp.p('<MARQUEE DIRECTION="LEFT" BEHAVIOR="SCROLL" SCROLLDELAY="250" WIDTH="' || to_char(to_number(glbx.sctrl(pfx.theme_name,'SCROLLBAR_WIDTH',least(stypex,6))) * 12) || '" SCROLLAMOUNT="10">');
     end if;
     htp.p( msg );
     htp.p('</MARQUEE>');
     htp.p( '</TD>' );
    end if;

   else
    -- Old Scroll Method Using Javascript
    htp.p( '<TD>' );
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
     htp.tablerowopen;
      htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
      htp.p( '<FONT SIZE="+0">' );
      htp.p( '<FORM NAME="Scroll">' );
      if szin
       then
        if dsp = 'S'
         then
           htp.p( '<INPUT TYPE="text" size="' || to_char( greatest(1,round(glbx.sctrl(pfx.theme_name,'SCROLLBAR_WIDTH',least(stypex,6))/2)) ) || '" name="ScrollBox" value="">' );
         else
          htp.p( '<INPUT TYPE="text" size="' || glbx.sctrl(pfx.theme_name,'SCROLLBAR_WIDTH',least(stypex,6)) || '" name="ScrollBox" value="">' );
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
   htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
      glbx.image_nmb_index( surl, c1rec, pfx , ltype, null, pfx.gap);
     htp.p( '</TD>' );
    htp.tablerowclose;
   htp.tableclose;
   htp.p( '</TD>' );
 end disp_nmblist;

 procedure noframe_disp_category
 as
 begin
   if (pfx.nested_scene_style = LNG3.ADM_TXT_576) and (pfx.scene_position ='T')
    then
     if ltype in ('PROFILE','PROFILEG')
      then
       open c11(profid);
       fetch c11 into proftot;
       close c11;
      else
       proftot := 0;
     end if;
     htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
     htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
      htp.tablerowopen;
       htp.p( '<TD valign="MIDDLE" ALIGN="CENTER">' );
        glbx.scene_display( surl, c1rec, pfx, ltype, stype, profid, substr(theme_rec.theme_data,92,1), pfx.nested_scene_style, null, null, proftot, dummy, align=>'ALIGN="LEFT" VALIGN="TOP"' );
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
    htp.tabledata( '&nbsp;', cattributes=>'width="10"');
  elsif ps = '2'
   then
    htp.tabledata( '&nbsp;', cattributes=>'width="20"');
  elsif ps = '3'
   then
    htp.tabledata( '&nbsp;', cattributes=>'width="40"');
  elsif ps = '4'
   then
    htp.tabledata( '&nbsp;', cattributes=>'width="80"');
  elsif ps = '5'
   then
    htp.tabledata( '&nbsp;', cattributes=>'width="160"');
  elsif ps = '6'
   then
    htp.tabledata( '&nbsp;', cattributes=>'width="250"');
  elsif ps = '7'
   then
    htp.tabledata( '&nbsp;', cattributes=>'width="300"');
  elsif ps = '8'
   then
    htp.tabledata( '&nbsp;', cattributes=>'width="400"');
  elsif ps = '9'
   then
    htp.tabledata( '&nbsp;', cattributes=>'width="600"');
  end if;
 end disp_width;

 procedure disp_option( opt in varchar2, nodisp in boolean default false )
 as
 begin
        -- Authorise
        if opt = 'AUTHORISE'
         then
          if nodisp
           then
            null;
           -- htp.tabledata(htf.img( cust_button(pfx,'authorise.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_692 ));
           else
            htp.tabledata(htf.anchor2('cst.auth_payment?surl=' || glbx.rndsurl(surl) || '&newwin=T',htf.img( cust_button(pfx,'authorise.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_692 ),ctarget=>'DISP_OPTION_WINDOW'));
          end if;

        -- Help
        elsif opt = 'HELP'
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=HELP',htf.img( cust_button(pfx,'help.gif',7),cattributes=>'border=0',calt=>lng.CST_ALT_022 ),ctarget=>'DISP_OPTION_WINDOW'));

        -- Readme
        elsif opt = 'README'
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=README',htf.img( cust_button(pfx,'readme.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_455 ),ctarget=>'DISP_OPTION_WINDOW'));

        -- Feedback
        elsif opt = 'FEEDBACK'
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=FEEDBACK',htf.img( cust_button(pfx,'feedback.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_456 ),ctarget=>'DISP_OPTION_WINDOW'));

        -- Contact Us
        elsif opt = 'CONTACTUS'
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=CONTACTUS',htf.img( cust_button(pfx,'contactus.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_457 ),ctarget=>'DISP_OPTION_WINDOW'));

        -- Legal
        elsif opt = 'LEGAL'
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=LEGAL',htf.img( cust_button(pfx,'legal.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_458 ),ctarget=>'DISP_OPTION_WINDOW'));

        -- Privacy
        elsif opt = 'PRIVACY'
         then
          htp.tabledata(htf.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=PRIVACY',htf.img( cust_button(pfx,'privacy.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_459 ),ctarget=>'DISP_OPTION_WINDOW'));

        -- Logoff
        elsif opt = 'LOGOFF'
         then
          if glbx.userpref( c1rec.pid,c1rec.aid,'CUST_LOGOFF' ) = LNG.PHG_TXT_045
           then
             htp.tabledata(htf.anchor2('glbx.acct_logoff?surl=' || glbx.rndsurl(surl),htf.img( cust_button(pfx,'logoff.gif',7),cattributes=>'border=0',calt=>lng.CST_ALT_021 ),ctarget=>'_top'));
           else
             htp.tabledata(htf.anchor2('glbx.acct_logoff?surl=' || glbx.rndsurl(surl),htf.img( cust_button(pfx,'home.gif',7),cattributes=>'border=0',calt=>lng.LAB_TXT_002 ),ctarget=>'_top'));
          end if;
       end if;
 end disp_option;

 procedure disp_title
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

begin

 if bypass_check = 'F'
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.ACCT_TOPX' );
  else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.ACCT_TOPX', reset=>FALSE );
 end if;

 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, null, profid );
 open c4( c1rec.pid );
 fetch c4 into c4rec;
 close c4;
 open c7(owner_id);
 fetch c7 into c7rec;
 close c7;
 pfx := glbx.get_thm( c1rec.theme_name );

 -- Call to Replace TopFrame
 if pfx.top_frame_api_call is not null
  then
   execute immediate
    'begin ' || pfx.top_frame_api_call || '(surl=>:surl); end;'
   using surl;
   return;
 end if;

 msg := glbx.userpref( c1rec.pid,c1rec.aid,'SCROLL_MESSAGE');
 theme_rec := glbx.get_theme_types(c1rec.theme_type );

 open c1(c1rec.aid);
 fetch c1 into c1arec;
 close c1;

 slides := TRUE;
 open c5(c1rec.aid);
 fetch c5 into tmpi;
 if c5%NOTFOUND then slides := FALSE; end if;
 close c5;

 if tmpi < 1 then slides := FALSE; end if;

 -- Javascript Load
 dummy(1) := 0;
 if pfx.keep_lhf in ('L','R','2')
  then
   if pfx.top_frame_background is null
    then
     bgcol := 'BGCOLOR="#' || pfx.top_back || '"';
    else
     bgcol := 'BACKGROUND="' || DECS.IMAGE_LOCATION || pfx.top_frame_background || '"';
   end if;
   if (pfx.nested_scene_style = LNG3.ADM_TXT_575) and (pfx.scene_position = 'T')
    then
     if ltype in ('PROFILE','PROFILEG')
      then
       open c11(profid);
       fetch c11 into proftot;
       close c11;
       glbx.scene_display( surl, c1rec, pfx, ltype, stype, profid, substr(theme_rec.theme_data,92,1), pfx.nested_scene_style, null, null, proftot, dummy, align=>'ALIGN="LEFT" VALIGN="TOP"' );
      else
       proftot := 0;
       glbx.scene_display( surl, c1rec, pfx, ltype, stype, c1rec.aid, substr(theme_rec.theme_data,92,1), pfx.nested_scene_style, null, null, proftot, dummy, align=>'ALIGN="LEFT" VALIGN="TOP"' );
     end if;
     glbx.main_title( surl, null,'<BODY onLoad="navBarInit()"' || bgcol || '>',stype=>stypex,sstyle=>pfx.top_text_font,sclr=>pfx.top_text_colour,lnk=>pfx.underline_active,det_sstyle=>pfx.top_text_font,det_sclr=>pfx.top_text_colour,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
   elsif msg is not null and c7rec.browser_type <> 'Microsoft Internet Explorer'
    then
     glbx.main_title( surl, null,'<BODY onLoad="ScrollAlong()" ' || bgcol || '>',stype=>stypex,sstyle=>pfx.top_text_font,sclr=>pfx.top_text_colour,lnk=>pfx.underline_active,det_sstyle=>pfx.top_text_font,det_sclr=>pfx.top_text_colour,hover=>pfx.hover_colour,jscript=>glbx.scrollbar( msg,'MENUBAR') , disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
    else
     glbx.main_title( surl, null,'<BODY ' || bgcol || '>',stype=>stypex,sstyle=>pfx.top_text_font,sclr=>pfx.top_text_colour,lnk=>pfx.underline_active,det_sstyle=>pfx.top_text_font,det_sclr=>pfx.top_text_colour,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,stylesh=>pfx.stylesheet);
   end if;
  else
   htp.title( glbx.userpref( c1rec.pid,c1rec.aid,'TITLE'));
 end if;

 if pfx.scene_position = 'T'
  then
   htp.print('<SCRIPT LANGUAGE="Javascript">');
   buttons_header( surl, theme_rec, ltype, pfx, slides, owner_id, ttl);
 end if;

 if pfx.keep_lhf = 'N' and pfx.top_back is not null and msg is not null and c7rec.browser_type <> 'Microsoft Internet Explorer'
  then
    htp.p('<SCRIPT LANGUAGE="JavaScript">
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
          </SCRIPT>');
    htp.p( '<BODY onLoad="ScrollAlong()" BGCOLOR="#' || pfx.top_back || '">' );
 end if;

 htp.p( '<CENTER>' );
 dscroll := FALSE;
  for k in 1..4 loop
  if k = 1
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || pfx.sf_table_width );
  elsif k = 2 and (instr(pfx.row1,'j') = 0 and instr(pfx.row1,'k') = 0)
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || pfx.sf_table_width );
  elsif k = 3 and (instr(pfx.row2,'j') = 0 and instr(pfx.row2,'k') = 0)
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || pfx.sf_table_width );
  elsif k = 4 and (instr(pfx.row3,'j') = 0 and instr(pfx.row3,'k') = 0)
   then
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' || pfx.sf_table_width );
  end if;

  htp.tablerowopen;

   for j in 1..10 loop
    if k = 1
     then
      ps := nvl(substr(pfx.row1,j,1),' ');
    elsif k = 2
     then
      ps := nvl(substr(pfx.row2,j,1),' ');
    elsif k = 3
     then
      ps := nvl(substr(pfx.row3,j,1),' ');
    elsif k = 4
     then
      ps := nvl(substr(pfx.row4,j,1),' ');
    end if;
    if ps <> ' '
     then
      if ps = 'T' and pfx.keep_lhf = 'N' then disp_title;
      elsif ps = 'S' and msg is not null then disp_scrollbar( TRUE, ps, c7rec.browser_type ); dscroll := TRUE;
      elsif ps = 'Q' and msg is not null then disp_scrollbar( TRUE, ps, c7rec.browser_type ); dscroll := TRUE;
      elsif ps = 'I' then disp_icons( pfx, 'I' );
      elsif ps = 'i' then disp_icons( pfx, 'i' );
      elsif ps = 'J' then disp_icons( pfx, 'J' );
      elsif ps = 'j' then disp_icons( pfx, 'j' );
      elsif ps = 'K' then disp_icons( pfx, 'K' );
      elsif ps = 'k' then disp_icons( pfx, 'k' );
      elsif ps = 'L' then disp_icons( pfx, 'L' );
      elsif ps = 'H' and pfx.keep_lhf = 'N' then disp_option( 'HELP' );
      elsif ps = 'A' then disp_advert( surl );
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
      elsif ps = 'R' and ltype = 'PROFILE'
       then
        open c8(profid);
        fetch c8 into c8rec;
        close c8;
        if nvl(c8rec.request_authority,'F') <> 'F'
         then
          disp_option( 'AUTHORISE' );
         else
          disp_option( 'AUTHORISE', true );
        end if;
      elsif ps = 'P' then disp_photographer_title;
      elsif ps = 'C' and pfx.scene_position = 'T' then noframe_disp_category;
      elsif ps = 'B' and pfx.disploc = 'T'
       then
        if pfx.sf_bg_img is null
         then
          htp.p( '<TD>' );
         else
          htp.p( '<TD BACKGROUND="' || DECS.IMAGE_LOCATION || pfx.sf_bg_img || '" HEIGHT=' || pfx.sf_bg_cell_height ||' WIDTH=' || pfx.sf_bg_cell_width || ' VALIGN="' || nvl( pfx.sf_bg_valign,'CENTER') || '">' );
        end if;
        buttons_footer( surl, theme_rec, ltype, pfx, slides, c1rec.aid, null, FALSE, stypex, pfx.sf_bg_cellspc, ttl );
        htp.p( '</TD>' );
      elsif ps in ('1','2','3','4','5','6','7','8','9') then disp_width(ps);
     end if;
    end if;
   end loop;
  htp.tablerowclose;

  if k = 1 and (instr(pfx.row1,'j') = 0 and instr(pfx.row1,'k') = 0)
   then
    htp.tableclose;
  elsif k = 2 and (instr(pfx.row2,'j') = 0 and instr(pfx.row2,'k') = 0)
   then
    htp.tableclose;
  elsif k = 3 and (instr(pfx.row3,'j') = 0 and instr(pfx.row3,'k') = 0)
   then
    htp.tableclose;
  elsif k = 4
   then
    htp.tableclose;
  end if;
  end loop;
  if not dscroll then disp_scrollbar( FALSE, null, c7rec.browser_type ); end if;

 htp.p( '</CENTER>' );
 if pfx.keep_lhf in ('L','R','2')
  then
   htp.htmlclose;
 end if;

exception when others then
 glbx.error_details( 'CST', 'ACCT_TOPX',c1rec.pid,c1rec.aid,errmsg=>sqlerrm);
end acct_topx;

procedure buttons_header(surl varchar2, theme_rec in theme_types%ROWTYPE, ltype in varchar2, pfx in THEME%ROWTYPE, slides in boolean, owner_id in integer, ttl varchar2)
as

 cursor c1(ltype varchar2, owner_id integer) is
  select a.*, case when upper(ttl) = upper(a.help_on) then 'Y' 
              when ttl is null and upper(a.help_on) = 'DETAILS' then 'Y'
              when ttl = 'Duty Management' and upper(a.help_on) = 'DUTY' then 'Y'
              when ttl = 'Administration' and upper(a.help_on) = 'CODES' then 'Y'  
              when UPPER(ttl) in ('SOUTHBOUND CONTAINERS','SOUTHBOUND DANS','SOUTHBOUND HOUSE BILLS') and upper(a.help_on) = 'MAIN MENU' then 'Y'
              when ttl = 'Convoy Header' and upper(a.help_on) = 'MANUAL ENTRY' then 'Y'  
              when UPPER(ttl) LIKE '%QUICKTRAC%' and upper(a.help_on) LIKE '%QUICKTRAC%' then 'Y'
              when upper(ttl) = 'SHIP/AIR MANAGEMENT' and upper(a.help_on) = 'SHIPS / AIRWAYS' then 'Y'
              when upper(ttl) = 'BOLS' and upper(a.help_on) = 'SHIPS / AIRWAYS' then 'Y'
              when upper(ttl) = 'MANAGE SMP DETAILS' and upper(a.help_on) = 'RECEIVALS' then 'Y'
              when upper(ttl) = 'MANAGE CUSTOMER DETAILS' and upper(a.help_on) = 'RECEIVALS' then 'Y'
              when upper(ttl)= 'TARIFF CODES' and upper(a.help_on) = 'MAIN MENU' then 'Y' 
              when substr(UPPER(ttl),1, instr(ttl,' ') -1) = substr(UPPER(a.help_on),1, instr(a.help_on,' ') -1) AND instr(a.help_on,' ') > 0 THEN 'Y'       
              when sign(instr(upper(ttl), 'REPORT')) = sign(instr(upper(a.help_on), 'REPORT')) and instr(upper(a.help_on), 'REPORT') > 0 THEN 'Y' 
              when sign(instr(upper(ttl), 'INVOICING')) = sign(instr(upper(a.help_on), 'INVOIC')) and instr(upper(a.help_on), 'INVOIC') > 0 THEN 'Y' else 'N'
            end highlight                
  from configurable_menu a
  where login_type = ltype and
       ((aid is null) or ((aid = owner_id) and (aid is not null)))
     and img not in ('str13') -- , 'str11')
  order by order_by;

 lty	varchar2(20);


begin

 lty := ltype;
 if ltype = 'PROFILE' then lty := 'OWNER'; end if;
 if ltype = 'PROFILEG' then lty := 'CUSTOMER'; end if;
 if ltype = 'VIRTUAL' then lty := 'CUSTOMER'; end if;

 for c1rec in c1(lty,owner_id) loop
  if (c1rec.theme_id is not null and substr(theme_rec.theme_data,c1rec.theme_id,1) = 'T') or (c1rec.theme_id is null)
   then
    if c1rec.menu_type = 'MOUSE OVER'
     then
      if (c1rec.img = 'szd' and slides) or (c1rec.img <> 'szd')
       then
        if (c1rec.highlight = 'N')
          then
           htp.print( 'function turnon' || c1rec.img || '(img' || c1rec.img || ') {img' || c1rec.img || '.src="' || DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c1rec.subdirectory || c1rec.img || '.gif' || '"} ');
           htp.print( 'function turnoff' || c1rec.img || '(img' || c1rec.img || '){img' || c1rec.img || '.src="' || DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c1rec.subdirectory || c1rec.img || 'x.gif' || '"}');
        else
          htp.print( 'function turnon' || c1rec.img || '(img' || c1rec.img || ') {img' || c1rec.img || '.src="' || DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c1rec.subdirectory || c1rec.img || 'x.gif' || '"} ');
          htp.print( 'function turnoff' || c1rec.img || '(img' || c1rec.img || '){img' || c1rec.img || '.src="' || DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c1rec.subdirectory || c1rec.img || 'x.gif' || '"}');
      end if;
      end if;
    end if;
  end if;
 end loop;

 htp.print('</SCRIPT>');
exception when others then
 glbx.error_details( 'CST', 'BUTTONS_HEADER',errmsg=>sqlerrm);
end buttons_header;

procedure buttons_footer(surl varchar2, theme_rec in theme_types%ROWTYPE, ltype in varchar2, pfx in THEME%ROWTYPE, slides in boolean, owner_id in integer, sctype in varchar2, isleft in boolean default TRUE, stype in integer, cellspc in varchar2 default null, ttl in varchar2 default null)
as

 cursor c1(ltype varchar2, owner_id integer) is
  select a.*, 
         case when upper(ttl) = upper(a.help_on) then 'Y' 
              when ttl is null and upper(a.help_on) = 'DETAILS' then 'Y'
          --    when exists (select 'x' from websys.oltp_overview where UPPER(menu_call) = 'ENQUIRIES' and upper(screen_name) = upper(ttl)) AND 
          --    upper(a.help_on) = 'MAIN MENU' then 'Y'
              when ttl = 'Duty Management' and upper(a.help_on) = 'DUTY' then 'Y'
              when ttl = 'Administration' and upper(a.help_on) = 'CODES' then 'Y'  
              when ttl = 'Convoy Header' and upper(a.help_on) = 'MANUAL ENTRY' then 'Y'  
              when UPPER(ttl) LIKE '%QUICKTRAC%' and upper(a.help_on) LIKE '%QUICKTRAC%' then 'Y'
              when upper(ttl) = 'SHIP/AIR MANAGEMENT' and upper(a.help_on) = 'SHIPS / AIRWAYS' then 'Y'
              when upper(ttl) = 'BOLS' and upper(a.help_on) = 'SHIPS / AIRWAYS' then 'Y'
              when upper(ttl) = 'MANAGE SMP DETAILS' and upper(a.help_on) = 'RECEIVALS' then 'Y'
              when upper(ttl) = 'MANAGE CUSTOMER DETAILS' and upper(a.help_on) = 'RECEIVALS' then 'Y'
              when upper(ttl)= 'TARIFF CODES' and upper(a.help_on) = 'MAIN MENU' then 'Y'
              when upper(ttl)= 'SOUTHBOUND SHIP MANAGEMENT' and upper(a.help_on) = 'SOUTHBOUND SHIPPING' then 'Y'
              --when substr(UPPER(ttl),1, instr(ttl,' ') -1) = substr(UPPER(a.help_on),1, instr(a.help_on,' ') -1) AND instr(a.help_on,' ') > 0 THEN 'Y'       
              when sign(instr(upper(ttl), 'REPORT')) = sign(instr(upper(a.help_on), 'REPORT')) and instr(upper(a.help_on), 'REPORT') > 0 THEN 'Y'
              when sign(instr(upper(ttl), 'INVOICING')) = sign(instr(upper(a.help_on), 'INVOIC')) and instr(upper(a.help_on), 'INVOIC') > 0 THEN 'Y' else 'N'
          end highlight                
  from configurable_menu a
  where login_type = ltype and
       ((aid is null) or ((aid = owner_id) and (aid is not null)))
   and img not in ('str13') --, 'str11')
  order by order_by;
  
  

 trg	varchar2(20);
 lty	varchar2(20);
 ucall	varchar2(2000);

begin

 if pfx.keep_lhf = '2'
  then
   trg := 'CUS_BOTTOM';
 elsif pfx.keep_lhf = 'N'
  then
   trg := '_top';
 else
   trg := 'CUS_RIGHT';
 end if;

 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=' || nvl(cellspc,'0') || ' border=0 ' );
 htp.tablerowopen;
 if pfx.uses_boundary = 'T'
  then
   htp.tabledata(htf.img( curl=>DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'cup.gif',cattributes=>'BORDER=0 ' ));
   if isleft then htp.tablerowclose; end if;
 end if;

 lty := ltype;
 if ltype = 'PROFILE' then lty := 'OWNER'; end if;
 if ltype = 'PROFILEG' then lty := 'CUSTOMER'; end if;

 for c1rec in c1(lty,owner_id) loop
  if (c1rec.theme_id is not null and substr(theme_rec.theme_data,c1rec.theme_id,1) = 'T') or (c1rec.theme_id is null)
   then
    ucall := replace(c1rec.url_call,'~SURL',surl);
    ucall := replace(ucall,'~RND',to_char(sysdate,'SSSSS'));
    ucall := replace(ucall,'~SCTYPE', sctype );
    ucall := replace(ucall,'~STYPE', stype );
    if c1rec.menu_type = 'MOUSE OVER'
     then
      if (c1rec.img = 'szd' and slides) or (c1rec.img <> 'szd')
       then
        if isleft then htp.tablerowopen; end if;

        if (c1rec.highlight = 'Y' )
           then
            htp.tabledata(htf.anchor2( ucall,htf.img( curl=>DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c1rec.subdirectory || c1rec.img ||'x.gif',
                    calt=>c1rec.help_on,cattributes=>'BORDER=0 name="opt' || c1rec.img || '"' ),
                    ctarget=>nvl(c1rec.override_target,trg),
                    cattributes=>'onMouseover="turnoff' || c1rec.img || '(opt' || c1rec.img || '); return true;" onMouseout="turnon' || c1rec.img || '(opt' || c1rec.img || '); return true;"'));       
        else 
        htp.tabledata(htf.anchor2( ucall,htf.img( curl=>DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || c1rec.subdirectory || c1rec.img ||'.gif',
                    calt=>c1rec.help_on,cattributes=>'BORDER=0 name="opt' || c1rec.img || '"' ),
                    ctarget=>nvl(c1rec.override_target,trg),
                    cattributes=>'onMouseover="turnoff' || c1rec.img || '(opt' || c1rec.img || '); return true;" onMouseout="turnon' || c1rec.img || '(opt' || c1rec.img || '); return true;"'));
        end if;
        if isleft then htp.tablerowclose; end if;
      end if;
    end if;
  end if;
 end loop;

 if pfx.uses_boundary = 'T'
  then
  if isleft then htp.tablerowopen; end if;
   htp.tabledata(htf.img( curl=>DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || 'cdw.gif',cattributes=>'BORDER=0 ' ));
  if isleft then htp.tablerowclose; end if;
 end if;
 htp.tablerowclose;
 htp.tableclose;
exception when others then
 glbx.error_details( 'CST', 'BUTTONS_FOOTER',errmsg=>sqlerrm);
end buttons_footer;

procedure acct_leftx( surl varchar2, scnm in integer default null, expanded_scenes in GLBX.MYARRAY, left_api in varchar2 default null, left_api_parm in varchar2 default null, new_nested in varchar2 default null )
as

 cursor c2( snm varchar2 ) is select image_gif,title_gif,scene_descript from scene where scene_name  = snm;

 cursor c4( acid integer ) is select count('x') from slide_master where aid=acid;

 cursor c5( ctgry varchar2, acid integer, utype varchar2, phgid integer ) is
  select umo_scene_id,title,associated_gif
  from umo_scene
  where category = ctgry and
        parent_scene is null and
        ((owned_by = 'PUBLIC') or (owned_by = utype and utype in ('CUSTOMER','PROFILEG') and owner_id = acid) or
         (owned_by = 'PHOTOGRAPHER' and owner_id = phgid))
  order by order_by;

 cursor c6( ctgry  varchar2, scnm integer ) is
  select umo_scene_id,title,associated_gif
  from umo_scene
  where category = ctgry and
        parent_scene = scnm
  order by order_by;

 cursor c7(acid integer, scnm integer,utype varchar2,mm_type varchar2) is
  select count('x') tot
  from umo um
  where aid = acid and
        umo_scene_id = scnm and
        umo_type = mm_type and
        um.extras.enabled_phg = 'TRUE' and
        (utype in ('OWNER','PROFILE') or (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_cus = 'TRUE'));

 cursor c8(phgid integer) is
   select count('x') tot
   from umo um
   where umo_type = 'GALLERY' and
         aid = phgid;

 cursor c9( v_scene_id integer) is
  select umo_type
  from umo_scene
  where umo_scene_id = v_scene_id;

 cursor c10(phgid integer) is select abn_number from photographer where pid = phgid;

 cursor c11(profid integer) is select count('x') from profile_scenes where profile_id = profid;

 c1rec		customer_account%ROWTYPE;
 c2rec 		c2%ROWTYPE;
 c10rec 	c10%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tmp		integer;
 slides		boolean;
 tot		integer;
 proftot	integer;
 dummy		integer;
 v_umo_type	varchar2(20);
 hlp		varchar2(100);
 theme_rec	theme_types%ROWTYPE;
 use_lnk	boolean;
 bg		varchar2(1000);

 procedure dispscene
 as
 begin

    if ltype in ('PROFILE','PROFILEG')
     then
      open c11(owner_id);
      fetch c11 into proftot;
      close c11;
     else
      proftot := 0;
    end if;
    glbx.scene_display( surl, c1rec, pfx, ltype, stype, owner_id,
                        substr(theme_rec.theme_data,92,1),
                        pfx.nested_scene_style,
                        htf.img( DECS.IMAGE_LOCATION || 'category/' || c2rec.image_gif,cattributes=>'border=0',calt=>c2rec.scene_descript ),
                        c2rec.title_gif, proftot, expanded_scenes, align=>'ALIGN="LEFT" VALIGN="TOP"', new_nested=>new_nested );
 end dispscene;

 procedure dispnmb
 as
 begin
      glbx.image_nmb_index( surl, c1rec, pfx , ltype, null, pfx.gap);
 end dispnmb;

 procedure displnk
 as
  src	varchar2(1000);
 begin

  if pfx.lhf_subdir is null
   then
    src := DECS.IMAGE_LOCATION || 'order_style/' || pfx.lhf_clickable_img;
   else
    src := DECS.IMAGE_LOCATION || 'order_style/' || pfx.lhf_subdir || '/' || pfx.lhf_clickable_img;
  end if;
  if pfx.lhf_clickable_target is null
   then
    htp.anchor( glbx.adjust_for_http(pfx.lhf_clickable_anchor), htf.img( src, cattributes=>'border=0') );
    htp.nl;
   else
    htp.anchor2( glbx.adjust_for_http(pfx.lhf_clickable_anchor), htf.img( src, cattributes=>'border=0'), ctarget=>pfx.lhf_clickable_target );
    htp.nl;
  end if;
 end displnk;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.ACCT_LEFTX', reset=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );

 if pfx.tnail_disp_sml_font = 'T'
  then
   use_lnk := TRUE;
  else
   use_lnk := FALSE;
 end if;

 slides := TRUE;
 open c4(c1rec.aid);
 fetch c4 into tmp;
 if c4%NOTFOUND then slides := FALSE; end if;
 close c4;
 if tmp < 1 then slides := FALSE; end if;

 if pfx.sim_three_frame = 'F' or pfx.keep_lhf in ('L','R')
  then
   if pfx.lhf_backimg is null
    then
     bg := '<BODY BGCOLOR="#' || pfx.lhs_back || '">';
    else
     if pfx.lhf_subdir is null
      then
       bg := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || 'order_style/' || pfx.lhf_backimg || '">';
      else
       bg := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || 'order_style/' || pfx.lhf_subdir || '/' || pfx.lhf_backimg || '">';
     end if;
   end if;
   glbx.main_title( surl, null, bg,
   stype=>greatest(stype-nvl(pfx.tnumb_adj,0),1),sstyle=>pfx.lhs_text_font,sclr=>pfx.lhs_text_colour,lnk=>pfx.underline_active,
   det_sstyle=>pfx.lhs_text_font,det_sclr=>pfx.lhs_text_colour,hover=>pfx.hover_colour,
   disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,
   errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font,
   instfntinc=>pfx.instruct_font_inc,
   small_link=>use_lnk,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,uline=>pfx.uline,stylesh=>pfx.stylesheet);
 end if;

 htp.print('<SCRIPT LANGUAGE="Javascript">');

 if pfx.disploc = 'S'
  then
   buttons_header( surl, theme_rec, ltype, pfx, slides, owner_id);
  else
   htp.print('</SCRIPT>');
 end if;
 if pfx.lhf_clickable_position = '1' then displnk; end if;

 if is_bf(theme_rec,ltype,367,368,'T','T')
  then
   htp.italic( htf.bold(c1rec.account_name));
   htp.nl;
 end if;

 hlp := glbx.userpref( c1rec.pid, c1rec.aid, 'TITLE_CHOOSER' );
 if hlp is not null
  then
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' );
    htp.tablerowopen;
    htp.tabledata( hlp );
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
 end if;

 htp.p( '<CENTER>' );
 open c2( c1rec.scene_name );
 fetch c2 into c2rec;
 close c2;

 if pfx.cus_but_scene = 'F' and
    pfx.scene_position in ('L','R') and
    is_bf(theme_rec,ltype,50,27,'T','T',50,'T') and
    nvl(c1rec.site_type,'S') <> 'V'
  then
   if pfx.lhf_clickable_position = '2' then displnk; end if;
   dispscene;
 end if;

 if pfx.cus_but_scene = 'F' and
    pfx.scene_position in ('L','R') and
    is_bf(theme_rec,ltype,376,377,'T','T') and
    nvl(c1rec.site_type,'S') = 'P'
  then
   dispnmb;
 end if;

 if pfx.disploc = 'S' and scnm is null
  then
   if pfx.lhf_clickable_position = '3' then displnk; end if;
   buttons_footer( surl, theme_rec, ltype, pfx, slides, owner_id, null, TRUE, stype, '0' ); htp.nl;
 elsif pfx.disploc = 'S' and scnm is not null
  then
   if pfx.lhf_clickable_position = '3' then displnk; end if;
   buttons_footer( surl,theme_rec, ltype, pfx, slides, owner_id, v_umo_type, TRUE, stype, '0' ); htp.nl;
 end if;

 if pfx.cus_but_scene = 'T' and
    pfx.scene_position in ('L','R') and
    is_bf(theme_rec,ltype,50,27,'T','T',50,'T') and
    nvl(c1rec.site_type,'S') <> ('V')
  then
   if pfx.lhf_clickable_position = '2' then displnk; end if;
   dispscene;
 end if;

 if pfx.cus_but_scene = 'T' and
    pfx.scene_position in ('L','R') and
    is_bf(theme_rec,ltype,376,377,'T','T') and
    nvl(c1rec.site_type,'S') = 'P'
  then
   dispnmb;
 end if;

 open c8(c1rec.pid);
 fetch c8 into tot;
 close c8;
 if is_bf(theme_rec,ltype,54,55,'T','T') and nvl(tot,0) > 0
   then
    htp.anchor2('cst.display_gallery?surl=' || glbx.rndsurl(surl) || '&msg=', htf.img( DECS.IMAGE_LOCATION || 'adminc/galleryx.gif', cattributes=>'BORDER=0'), ctarget=>'CUS_RIGHT');
    htp.nl;
 end if;

 if c1rec.is_beta_tester = 'T'
  then
   htp.anchor2( 'glbx.beta_bug',htf.img( DECS.IMAGE_LOCATION || 'admin/bug.gif', cattributes=>'BORDER=0'), ctarget=>'CUS_RIGHT');
 end if;

 if left_api is not null
  then
   execute immediate
      'begin ' || left_api || '(surl=>:surl,left_api_parm=>:left_api_parm); end;'
      using glbx.rndsurl(surl),left_api_parm;
 end if;

 htp.p( '</CENTER>' );

 hlp := glbx.userpref( c1rec.pid, c1rec.aid, 'HELP_CHOOSER' );
 open c10(c1rec.pid);
 fetch c10 into c10rec;
 close c10;
 if hlp is not null or c10rec.abn_number is not null
  then
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0 ' );
    if hlp is not null
     then
      htp.tablerowopen;
       htp.tabledata('<FONT SIZE="-2" face="Verdana">' || hlp || '</FONT>');
      htp.tablerowclose;
    end if;
    if c10rec.abn_number is not null
     then
      htp.tablerowopen;
       htp.tabledata('<FONT SIZE="-2" face="Verdana">' || LNG.GLB_TXT_107 || ' ' || c10rec.abn_number || '</FONT>');
      htp.tablerowclose;
    end if;
   htp.tableclose;
 end if;

 if pfx.lhf_external_call is not null
  then
    execute immediate
      'begin ' || pfx.lhf_external_call ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,search_total=>:search_total,display_detail=>:display_detail,ltype=>:ltype,acid=>:acid);' ||
       'end;'
     using glbx.rndsurl(surl),left_api_parm,dummy,pfx.keep_lhf,ltype,c1rec.aid;
 end if;

 if pfx.lhf_clickable_position = '4' then displnk; end if;

 glbx.close_page(pfx);

exception when others then
 glbx.error_details( 'CST', 'ACCT_LEFTX',c1rec.pid,owner_id,errmsg=>sqlerrm);
end acct_leftx;

procedure acct_phg( surl varchar2, acid in integer default null)
as

 cursor c2(phid integer) is select * from photographer where pid = phid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 hght		integer;
 profid		integer;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.ACCT_PHG' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c2(c1rec.pid);
 fetch c2 into c2rec;
 close c2;
 glbx.main_title(surl, c2rec.business_name,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'C02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 if c2rec.business_desc is not null
  then
   htp.italic( htf.bold(c2rec.business_desc) );
   htp.nl;
 end if;
 htp.nl;
 htp.bold( lng.CST_TXT_005 ); htp.nl;
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1' );
  if c2rec.home_site is not null then
    htp.tablerowopen;
       htp.tabledata(htf.bold( htf.italic(lng.PHG_TXT_236) ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( htf.anchor(glbx.adjust_for_http(c2rec.home_site),c2rec.home_site) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  if c2rec.contact_name is not null then
    htp.tablerowopen;
       htp.tabledata(htf.bold( htf.italic(lng.PHG_TXT_022) ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.contact_name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  if c2rec.contact_email is not null then
    htp.tablerowopen;
       htp.tabledata(htf.bold( htf.italic(lng.PHG_TXT_250) ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.mailto( c2rec.contact_email,c2rec.contact_email ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  if c2rec.contact_street is not null then
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_006) ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.contact_street ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  end if;
  if c2rec.contact_suburb is not null then
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic('&nbsp;') ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.contact_suburb ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  end if;
  if c2rec.contact_city is not null then
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic('&nbsp;') ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.contact_city ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  end if;
  if c2rec.contact_pcode is not null then
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic('&nbsp;') ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.contact_pcode ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  end if;
  if c2rec.work_phone is not null then
  htp.tablerowopen;
     htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_008) ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata(htf.bold( c2rec.work_phone ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  end if;
  if c2rec.mobile_phone is not null then
    htp.tablerowopen;
       htp.tabledata(htf.bold( htf.italic(lng.CST_TXT_009) ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.mobile_phone ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  if c2rec.contact_fax is not null then
    htp.tablerowopen;
       htp.tabledata(htf.bold( htf.italic(lng.PHG_TXT_336) ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.bold( c2rec.contact_fax ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.p( '<CENTER>' );
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'CST', 'ACCT_PHG',c1rec.pid,owner_id,errmsg=>sqlerrm);
end acct_phg;

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

procedure disp_privacy(surl in varchar2, ltype in varchar2, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE )
as
begin
 htp.tableopen( cattributes=>'width="80%" cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.line, cattributes=>'colspan="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(glbx.userpref( cusrec.pid, cusrec.aid, 'IMG_DISC' ), cattributes=>' valign="TOP" align="LEFT" CLASS="SMALL"' );
   htp.p( '<TD valign="TOP" align="LEFT" CLASS="SMALL">' );

   -- Legal
   if is_bf(theme_rec,ltype,359,360,'T','T')
    then
     htp.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=LEGAL',htf.img( cust_button(pfx,'legal.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_458 ),ctarget=>'CUS_RIGHT');
   end if;

   -- Privacy
   if is_bf(theme_rec,ltype,361,362,'T','T')
    then
     htp.anchor2('cst.acct_showinf?surl=' || glbx.rndsurl(surl) || '&typ=PRIVACY',htf.img( cust_button(pfx,'privacy.gif',7),cattributes=>'border=0',calt=>LNG4.AHC_TXT_459 ),ctarget=>'CUS_RIGHT');
   end if;

   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
end disp_privacy;

procedure disp_standard_search(surl in varchar2, stype in integer, ltype in varchar2, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, style in varchar2 default 'STANDARD' )
as

 cursor c2( snm varchar2, acid integer, phgid integer ) is
   select distinct usc.umo_scene_id,title,parent_scene,order_by
   from umo um, umo_scene usc
   where category = snm and
         um.umo_scene_id = usc.umo_scene_id and
         um.aid = acid
   order by order_by;

 cursor c2a( profid integer ) is
   select psc.umo_scene_id,psc.title,usc.parent_scene
   from profile_scenes psc, umo_scene usc
   where profile_id = profid and
         psc.umo_scene_id = usc.umo_scene_id
   order by psc.order_by;

 cursor c3( profid integer) is
   select count('x') tot
   from profile_scenes
   where profile_id = profid;

 ntot	integer;

begin
 -- Standard Search
 if pfx.search_before_entry_api is not null
  then
   execute immediate 'begin ' || pfx.search_before_entry_api || '(surl=>:surl, acid=>:acid); end;'
    using surl, acid;
   return;
 end if;

 if substr(pfx.search_choices,1,1) = 'T'
 then
  htp.formopen( 'cst.simple_search' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
  if style in ('STANDARD','MULTIPLE')
   then
     if style = 'STANDARD'
      then
        htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
      else
        htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=1' );
     end if;

     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG4.AHC_TXT_829),cattributes=>'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.formtext( 'P1',30, 100, null),cattributes=>'valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.italic(glbx.userpref( cusrec.pid, cusrec.aid, 'HELP_SEARCH' )),cattributes=>'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;

     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.CST_TXT_042),cattributes=>'valign="MIDDLE" align="LEFT"');
      htp.p( '<TD valign="MIDDLE" align="LEFT">' );
      if style = 'SIMPLE'
       then
        htp.formselectopen( 'P3' );
       else
        htp.formselectopen( 'P3', null, 5, cattributes=>'MULTIPLE' );
      end if;
      htp.formselectoption( LNG.PHG_ALT_390, 'SELECTED' );
      ntot := 0;
      if ltype in ('PROFILE','PROFILEG')
       then
        ntot := 0;
        open c3(profid);
        fetch c3 into ntot;
        close c3;
       end if;

       if ntot = 0
        then
         for c2rec in c2(cusrec.scene_name, cusrec.aid, cusrec.pid ) loop
         htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
         end loop;
        else
        for c2rec in c2a( profid ) loop
          htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
         end loop;
       end if;
       htp.formselectclose;
       htp.p( '</TD>' );
       htp.tabledata(htf.italic(LNG.CST_TXT_043),cattributes=>'valign="MIDDLE" align="LEFT"');
      htp.tablerowclose;
     htp.tableclose;
     htp.nl;
     htp.formsubmit( null, LNG.GLB_TXT_092 );
     htp.formclose;
     htp.nl;

  elsif style = 'VERY SIMPLE'
   then
    htp.tableopen( cattributes=>'width="100%" cellpadding=4 cellspacing=0 border=0' );
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.GLB_TXT_092), cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT" STYLE="font-size: ' || to_char(2+stype) || 'pt"' );
      htp.formhidden( 'P3', '0' );
      if substr(pfx.search_choices,2,1) = 'T'
       then
         htp.tabledata(htf.anchor( 'cst.acct_search?surl=' || surl || '&acid=' || acid || '&search_call=ADVANCED',LNG2.FNM_TXT_139,cattributes=>'STYLE="font-size: ' || to_char(2+stype) || 'pt"'),cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"');
       else
        htp.tabledata('&nbsp;',cattributes=>pfx.qbground );
      end if;
     htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata(htf.formtext( 'P1', glbx.sctrl(pfx.theme_name,'SCROLLBAR_WIDTH',round(stype/2)), 100, null),cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT" STYLE="font-size: ' || to_char(2+stype) || 'pt"');
      htp.tabledata(htf.formimage( 'Find', DECS.IMAGE_LOCATION || 'adminc/find.gif',cattributes=>'BORDER="0"'),cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"');
     htp.tablerowclose;
   htp.tableclose;
   htp.formclose;

  elsif style = 'SIMPLE'
   then
    htp.tableopen( cattributes=>'width="80%" cellpadding=3 cellspacing=0 border=0' );
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.GLB_TXT_092), cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qbground || ' valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P3' );
      htp.formselectoption( LNG.PHG_ALT_390, 'SELECTED' );
      ntot := 0;
      if ltype in ('PROFILE','PROFILEG')
       then
        ntot := 0;
        open c3(profid);
        fetch c3 into ntot;
        close c3;
       end if;

      if ntot = 0
       then
        for c2rec in c2(cusrec.scene_name, cusrec.aid, cusrec.pid ) loop
        htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
        end loop;
       else
       for c2rec in c2a( profid ) loop
         htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
        end loop;
      end if;
      htp.formselectclose;
      htp.p( '</TD>' );
      if substr(pfx.search_choices,2,1) = 'T'
       then
         htp.tabledata(htf.anchor( 'cst.acct_search?surl=' || surl || '&acid=' || acid || '&search_call=ADVANCED',LNG2.FNM_TXT_139),cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"');
      end if;
      htp.tabledata(htf.formtext( 'P1',30, 100, null),cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT"');
      htp.tabledata(htf.formsubmit( null, LNG5.EXT_TXT_207 ),cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
   htp.tableclose;
   htp.formclose;

  elsif style = 'LIST_CATEGORIES'
   then
       htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=1' );
       htp.tablerowopen;
        htp.tabledata( htf.bold(LNG4.AHC_TXT_829),cattributes=>'valign="MIDDLE" align="LEFT"');
        htp.tabledata(htf.formtext( 'P1',30, 100, null),cattributes=>'valign="MIDDLE" align="LEFT"');
        htp.tabledata(htf.italic(glbx.userpref( cusrec.pid, cusrec.aid, 'HELP_SEARCH' )),cattributes=>'valign="MIDDLE" align="LEFT"');
       htp.tablerowclose;

       htp.tablerowopen;
        htp.tabledata( htf.bold(LNG.CST_TXT_042),cattributes=>'valign="TOP" align="LEFT"');
        htp.p( '<TD valign="MIDDLE" align="LEFT">' );
        ntot := 0;
        if ltype in ('PROFILE','PROFILEG')
         then
          ntot := 0;
          open c3(profid);
          fetch c3 into ntot;
          close c3;
         end if;
        htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
        if ntot = 0
         then
          htp.tablerowopen;
          for c2rec in c2(cusrec.scene_name, cusrec.aid, cusrec.pid ) loop
           if mod(c2%ROWCOUNT,2) = 1
            then
             htp.tablerowclose;
             htp.tablerowopen;
           end if;
           htp.tabledata( htf.formcheckbox( 'P3', c2rec.umo_scene_id, 'CHECKED' ) || ' ' || lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title );
          end loop;
          htp.tablerowclose;
         else
         for c2rec in c2a( profid ) loop
           if mod(c2%ROWCOUNT,2) = 1
            then
             htp.tablerowclose;
             htp.tablerowopen;
           end if;
           htp.tabledata( htf.formcheckbox( 'P3', c2rec.umo_scene_id, 'CHECKED' ) || ' ' || lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title );
          end loop;
          htp.tablerowclose;
        end if;
        htp.tableclose;
        htp.p( '</TD>' );
        htp.tabledata(htf.nl || htf.formsubmit( null, LNG5.EXT_TXT_207 ) || htf.formclose, cattributes=>'valign="TOP" align="LEFT"');
       htp.tablerowclose;
      htp.tableclose;
     htp.nl;

  elsif style = 'SEARCH_ON_CATEGORIES'
   then
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=1' );

     htp.tablerowopen;
      htp.tabledata( htf.bold('Search for a Category'),cattributes=>'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.formhidden( 'P3','CATEGORY_SEARCH' ) || htf.formtext( 'P1',30, 100, null),cattributes=>'valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.italic(glbx.userpref( cusrec.pid, cusrec.aid, 'HELP_SEARCH' )),cattributes=>'valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;

     htp.tableclose;
     htp.nl;
     htp.formsubmit( null, LNG.GLB_TXT_092 );
     htp.formclose;
     htp.nl;

  end if;

 end if;
end disp_standard_search;

procedure disp_advanced_search(surl in varchar2, ltype in varchar2, owner_id in integer, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE )
as

 cursor c2( snm varchar2, acid integer, phgid integer ) is
   select distinct usc.umo_scene_id,title,parent_scene,order_by
   from umo um, umo_scene usc
   where category = snm and
         um.umo_scene_id = usc.umo_scene_id and
         um.aid = acid
   order by order_by;

 cursor c2a( profid integer ) is
   select psc.umo_scene_id,psc.title,usc.parent_scene
   from profile_scenes psc, umo_scene usc
   where profile_id = profid and
         psc.umo_scene_id = usc.umo_scene_id
   order by psc.order_by;

 cursor c3( profid integer) is
   select count('x') tot
   from profile_scenes
   where profile_id = profid;

 cursor c4(acid integer, ltype varchar2, sess_id integer, vpid integer) is
  select distinct src_name,cust_id
  from advanced_search
  where pid = vpid and
       nvl(aid,0) = nvl(acid,0) and
       login_type = ltype and
       ((ltype = 'PHOTOGRAPHER') or
        (ltype in ('OWNER','PROFILE')) or
        (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) )
  order by src_name;

 ntot		integer;
 vpid		integer;
 rowsret	integer;
 lbox		varchar2(1000);
 foundrec	boolean;
 tmp		varchar2(32767);

begin
 lbox := glbx.userpref(cusrec.pid,cusrec.aid,'LIGHTBOX');
 if substr(pfx.search_choices,2,1) = 'T'
  then
   -- Advanced Search
     -- Owner can see the last query
       htp.bold( LNG2.FNM_TXT_139 );
       htp.nl;
          -- Check for previous searches
          foundrec := FALSE;
          if ltype = 'PHOTOGRAPHER' then vpid := cusrec.pid; else vpid := 0; end if;
          for c4rec in c4(cusrec.aid,ltype,owner_id,vpid) loop
           if c4%ROWCOUNT = 1
            then
             if pfx.search_display_style = 'S'
              then
               htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
             elsif pfx.search_display_style = 'E'
              then
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
             htp.tabledata( htf.anchor( 'cst.delete_query?surl=' || glbx.rndsurl(surl) || '&typ=A&p1=' || translate( c4rec.src_name,' ','+') || '&search_call=ADVANCED&acid=' || acid, LNG.PHG_TXT_501),cattributes=>pfx.qcbground);
             htp.tabledata( htf.anchor( 'ump.advanced_search_phg?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || '[' || cusrec.aid || ']' || replace( c4rec.src_name,' ','+') || '&start_from=1&display_detail=' || '&acid=' || acid || '&ctx=' || pfx.search_with_context, c4rec.src_name),cattributes=>pfx.qcbground);
             htp.p( '<TD ' || pfx.qcbground || '>');
              htp.p( LNG.PHG_TXT_500 || ' ' );
              glbx.display_query(cusrec.aid,c4rec.src_name,ltype,owner_id,vpid,lbox,rowsret);
             htp.p( '</TD>' );
             htp.tabledata( nvl(rowsret,0),cattributes=>pfx.qcbground);
            htp.tablerowclose;
          end loop;
          if foundrec then htp.tableclose; end if;
          htp.nl;

     htp.formopen( 'cst.run_query' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACID', acid );
     htp.formhidden( 'PS', null );
     --htp.formhidden( 'SORTON','I');
     --htp.formhidden( 'IMAGE_DIM','P' );
     if pfx.search_display_style = 'S'
      then
       htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     elsif pfx.search_display_style = 'E'
      then
       htp.tableopen( cattributes=>'cellpadding=6 cellspacing=0 border=0 rules="NONE" frame="HSIDES,VSIDES"' );
     end if;
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.PHG_TXT_504),cattributes=>pfx.qbground);
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
       htp.tabledata( htf.formtext( 'P1N', 30, 100 ),cattributes=>pfx.qcbground);
       -- Stem Search
       if pfx.search_stem = 'T'
        then
         htp.tabledata( LNG2.FRM_TXT_054 ,cattributes=>pfx.qcbground);
       end if;
      htp.tablerowclose;

      if pfx.search_email_on_new = 'T' and ltype not in ('CUSTOMER','PROFILEG','VIRTUAL')
       then
        htp.tablerowopen;
         htp.tabledata( htf.bold(LNG4.AHC_TXT_996),cattributes=>pfx.qbground);
         htp.tabledata( htf.formcheckbox( 'P1S', 'T' ),cattributes=>pfx.qcbground);
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         if pfx.search_stem = 'T'
          then
           htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         end if;
        htp.tablerowclose;
      end if;

      if pfx.search_global = 'T'
       then
        htp.tablerowopen;
        -- Global Search
        htp.tabledata( htf.bold(LNG2.PFM_TXT_170),cattributes=>pfx.qbground);
        htp.tabledata( htf.formcheckbox( 'ISGLB', 'T' ),cattributes=>pfx.qcbground);
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
        if pfx.search_stem = 'T'
         then
          htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
        end if;
       htp.tablerowclose;
      end if;

      if pfx.search_ignore_lbox = 'T'
       then
        htp.tablerowopen;
        -- Ignore Lightbox
        htp.tabledata( htf.bold(LNG4.AHC_TXT_431 || ' ' || lbox),cattributes=>pfx.qbground);
        htp.tabledata( htf.formcheckbox( 'LBOX', 'T' ),cattributes=>pfx.qcbground);
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
        if pfx.search_stem = 'T'
         then
          htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
        end if;
       htp.tablerowclose;
      end if;

       tmp := htf.formselectopen( 'P1' ) || htf.formselectoption( LNG.PHG_ALT_390, 'SELECTED' );
       ntot := 0;
       if ltype in ('PROFILE','PROFILEG')
        then
         ntot := 0;
         open c3(profid);
         fetch c3 into ntot;
         close c3;
        end if;

       if ntot = 0
        then
         for c2rec in c2(cusrec.scene_name, cusrec.aid, cusrec.pid ) loop
          tmp := tmp || htf.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
         end loop;
        else
         for c2rec in c2a( profid ) loop
          tmp := tmp || htf.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
         end loop;
       end if;
       tmp := tmp || htf.formselectclose;

      htp.tablerowopen;
       htp.tabledata(htf.bold(lng.CST_TXT_042 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
       htp.tabledata(tmp,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"');
         if pfx.search_stem = 'T'
          then
           htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         end if;
      htp.tablerowclose;
      tmp := htf.formselectopen( 'P2' ) || htf.formselectoption( LNG.PHG_TXT_505, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_506 ) || htf.formselectoption( LNG.PHG_TXT_508 ) || htf.formselectoption( LNG.PHG_TXT_507 ) || htf.formselectclose;
      for j in 1..5 loop
       htp.tablerowopen;
        htp.tabledata( htf.bold(LNG.PHG_TXT_513),cattributes=>pfx.qbground);
        htp.tabledata( tmp,cattributes=>pfx.qcbground);
        htp.tabledata( htf.formtext( 'P3', 30, 100 ),cattributes=>pfx.qcbground);
        if pfx.search_stem = 'T'
        then
          htp.tabledata( htf.formcheckbox( 'PS', to_char(j) ), cattributes=>pfx.qcbground);
        else
         htp.formhidden( 'PS', null );
       end if;
       htp.tablerowclose;
       if j < 5
        then
         htp.tablerowopen;
          htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
          htp.tabledata( htf.formselectopen( 'P5' ) || htf.formselectoption( LNG.PHG_TXT_509, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_510 )  || htf.formselectoption( LNG.PHG_TXT_511 ) || htf.formselectclose,cattributes=>pfx.qcbground);
          htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
          if pfx.search_stem = 'T'
           then
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
          end if;
         htp.tablerowclose;
       end if;
      end loop;
      htp.tablerowopen;
       htp.tabledata(htf.bold(LNG5.EXT_TXT_045 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"');
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">');
       htp.formselectopen( 'P1A' );
       htp.formselectoption( NULL );
        if ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
         then
          htp.formselectoption( LNG5.EXT_TXT_047, cattributes=>'VALUE="X"' );
        end if;
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
       htp.formselectclose;
       htp.p( '</TD>' );
         if pfx.search_stem = 'T'
          then
           htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         end if;
      htp.tablerowclose;
     htp.tableclose;
     htp.nl;
     htp.formsubmit( null, LNG.PHG_TXT_512 );
     htp.formclose;
 end if;

end disp_advanced_search;

procedure disp_manufacturer_search(surl in varchar2, ltype in varchar2, owner_id in integer, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, style in varchar2 default 'STANDARD' )
as

 cursor c2( snm varchar2, acid integer, phgid integer ) is
   select distinct usc.umo_scene_id,title,parent_scene,order_by
   from umo um, umo_scene usc
   where category = snm and
         um.umo_scene_id = usc.umo_scene_id and
         um.aid = acid
   order by order_by;

 cursor c6( uscid integer ) is select title from umo_scene where umo_scene_id = uscid;

 cursor c9(acid integer, ltype varchar2, sess_id integer, vpid integer) is
  select distinct src_name,cust_id
  from manufacturer_search
  where pid = vpid and
       nvl(aid,0) = nvl(acid,0) and
       login_type = ltype and
       ((ltype = 'PHOTOGRAPHER') or
        (ltype in ('OWNER','PROFILE')) or
        (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) )
  order by src_name;

 cursor c10(acid integer, srcnme varchar2, ltype varchar2, sess_id integer, vpid integer) is
   select *
   from manufacturer_search
   where pid = vpid and
         nvl(aid,0) = nvl(acid,0) and
         src_name = srcnme and
         login_type = ltype and
        ((ltype = 'PHOTOGRAPHER') or
         (ltype in ('OWNER','PROFILE')) or
         (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) )
   order by order_by;

 cursor c11 is select interest_id,interest_name from interest_groups order by interest_name;

 cursor c12(intid integer) is select interest_name from interest_groups where interest_id = intid;

 c12rec		c12%ROWTYPE;
 foundrec	boolean;
 rowsret	integer;
 vpid		integer;
 last_umo	integer;
 isnew		char(1);
 lbox		varchar2(100);
 tmp		varchar2(32767);

begin

 -- Styles: STANDARD, SIMPLE and SHOP

 lbox := glbx.userpref(cusrec.pid,cusrec.aid,'LIGHTBOX');
 if substr(pfx.search_choices,3,1) = 'T'
 then
   -- Manufacturer Search
  if style = 'SIMPLE'
   then

    htp.formopen( 'cst.run_query_mfc' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'P1', NULL );
    htp.formhidden( 'P2', LNG.PHG_TXT_506 );
    htp.formhidden( 'P1N', NULL );
    htp.formhidden( 'P1S', 'F' );
    htp.formhidden( 'P5', NULL );
    htp.formhidden( 'P8', NULL );
     htp.tableopen( cattributes=>'width="80%" cellpadding=3 cellspacing=0 border=0' );
      htp.tablerowopen;
      htp.tabledata( htf.bold(LNG.GLB_TXT_092), cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT"' );
      htp.p( '<TD ' || pfx.qbground || ' valign="MIDDLE" align="LEFT">' );
      htp.formselectopen( 'P4' );
      htp.formselectoption( LNG.PHG_ALT_390, 'SELECTED' );
       for c2rec in c2(cusrec.scene_name, cusrec.aid, cusrec.pid ) loop
        htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
       end loop;
      htp.formselectclose;
      htp.p( '</TD>' );
      if substr(pfx.search_choices,2,1) = 'T'
       then
         htp.tabledata(htf.anchor( 'cst.acct_search?surl=' || surl || '&acid=' || acid || '&search_call=ADVANCED',LNG2.FNM_TXT_139),cattributes=>pfx.qbground || ' valign="MIDDLE" align="CENTER"');
      end if;
      htp.tabledata(htf.formtext( 'P3',30, 100, null),cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT"');
      htp.tabledata( htf.bold( LNG2.FNM_TXT_130 ),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
      htp.tabledata( LNG2.FNM_TXT_131 || ' ' || htf.formtext( 'P6A', 10, 20 ),cattributes=>pfx.qbground);
      htp.tabledata( LNG2.FNM_TXT_132 || ' ' || htf.formtext( 'P6B', 10, 20 ),cattributes=>pfx.qbground);
      htp.tabledata(htf.formsubmit( null, LNG5.EXT_TXT_207 ),cattributes=>pfx.qbground || ' valign="MIDDLE" align="LEFT"');
     htp.tablerowclose;
   htp.tableclose;
   htp.formclose;

   else

     htp.bold( nvl(pfx.search_mfctr_title,LNG2.PBK_TXT_009) || ' ' || LNG.GLB_TXT_092 );
     htp.nl;
          -- Check for previous searches
          foundrec := FALSE;
          if ltype = 'PHOTOGRAPHER' then vpid := cusrec.pid; else vpid := 0; end if;
          for c9rec in c9(cusrec.aid,ltype,owner_id,vpid) loop
           if c9%ROWCOUNT = 1
            then
             if pfx.search_display_style = 'S'
              then
               htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
             elsif pfx.search_display_style = 'E'
              then
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
             htp.tabledata( htf.anchor( 'cst.delete_query?surl=' || glbx.rndsurl(surl) || '&typ=M&p1=' || translate( c9rec.src_name,' ','+') || '&search_call=MANUFACTURER&acid=' || acid, LNG.PHG_TXT_501),cattributes=>pfx.qcbground);
             htp.tabledata( htf.anchor( 'ump.manufacturer_search_phg?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || '[' || cusrec.aid || ']' || replace( c9rec.src_name,' ','+') || '&start_from=1&display_detail=' || '&acid=' || acid, c9rec.src_name),cattributes=>pfx.qcbground);
             htp.p( '<TD ' || pfx.qcbground || '>');
              htp.p( LNG.PHG_TXT_500 || ' ' );
              last_umo := NULL;
              isnew := 'F';
              for c10rec in c10(cusrec.aid,c9rec.src_name,ltype,owner_id,vpid) loop
               if c10%ROWCOUNT = 1 and c10rec.is_global = 'T'
                then
                 htp.p( LNG2.PFM_TXT_168 || ' ' );
               end if;
               htp.p(c10rec.clause);
               htp.p( ' ' );
               htp.bold(c10rec.keyword);
               if c10rec.stem = 'T'
                then
                 htp.p( '(' || LNG2.PFM_TXT_169 || ')' );
               end if;
               if c10rec.brand is not null
                then
                 htp.p( ' ' );
                 htp.p(LNG2.FNM_TXT_137 || '  ' || c10rec.brand);
               end if;
               if c10rec.interest_id is not null
                then
                 htp.p( ' ' );
                 open c12(c10rec.interest_id);
                 fetch c12 into c12rec;
                 close c12;
                 htp.p(LNG2.FNM_TXT_138 || ' ' || c12rec.interest_name);
               end if;
               htp.p( ' ' );
               if c10rec.price_from is not null
                then
                 htp.p( LNG2.FNM_TXT_135 || ' ' || ltrim(to_char(c10rec.price_from,LNG.MONEY_FORMAT)) || '-' || ltrim(to_char(c10rec.price_to,LNG.MONEY_FORMAT)) );
               end if;
               last_umo := c10rec.umo_scene_id;
               isnew := c10rec.notify_on_new;
               rowsret := c10rec.rows_returned;
              end loop;
              tmp := NULL;
              if last_umo is not null
               then
                htp.p( 'in' || ' ' );
                open c6(last_umo);
                fetch c6 into tmp;
                close c6;
                htp.bold( tmp );
              end if;
              if isnew = 'T' then htp.italic( '-' || LNG4.AHC_TXT_997 ); end if;
             htp.p( '</TD>' );
             htp.tabledata( nvl(rowsret,0),cattributes=>pfx.qcbground);
            htp.tablerowclose;
          end loop;
          if foundrec then htp.tableclose; end if;
          htp.nl;
          htp.formopen( 'cst.run_query_mfc' );
          htp.formhidden( 'SURL', glbx.rndsurl(surl));
          htp.formhidden( 'ACID', acid );
          htp.formhidden( 'P1', NULL );
           if pfx.search_display_style = 'S'
            then
             htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
           elsif pfx.search_display_style = 'E'
            then
             htp.tableopen( cattributes=>'cellpadding=6 cellspacing=0 border=0 rules="NONE" frame="HSIDES,VSIDES"' );
           end if;
           htp.tablerowopen;
            htp.tabledata( htf.bold(LNG.PHG_TXT_504),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
            htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
            htp.tabledata( htf.formtext( 'P1N', 30, 100 ),cattributes=>pfx.qcbground);
           htp.tablerowclose;
           if pfx.search_email_on_new = 'T'
            then
             htp.tablerowopen;
              htp.tabledata( htf.bold(LNG4.AHC_TXT_996),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
              htp.tabledata( htf.formcheckbox( 'P1S', 'T' ),cattributes=>pfx.qcbground);
              htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
             htp.tablerowclose;
           end if;
           tmp := htf.formselectopen( 'P2' ) || htf.formselectoption( LNG.PHG_TXT_505, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_506 ) || htf.formselectoption( LNG.PHG_TXT_508 ) || htf.formselectoption( LNG.PHG_TXT_507 ) || htf.formselectclose;
            htp.tablerowopen;
             htp.tabledata( htf.bold(LNG.PHG_TXT_513),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
             htp.tabledata( tmp,cattributes=>pfx.qcbground);
             htp.tabledata( htf.formtext( 'P3', 30, 100 ),cattributes=>pfx.qcbground);
            htp.tablerowclose;
            htp.tablerowopen;
             htp.tabledata( htf.bold(LNG2.FNM_TXT_128),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
             htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
             htp.tabledata( htf.formtext( 'P8', 30, 100 ),cattributes=>pfx.qcbground);
            htp.tablerowclose;
            htp.tablerowopen;
             htp.tabledata( htf.bold( LNG.CST_TXT_042 ),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
             htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
              htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
              htp.formselectopen( 'P4' );
              htp.formselectoption( LNG.PHG_ALT_390, 'SELECTED', cattributes=>'VALUE="0"' );
              for c2rec in c2(cusrec.scene_name, cusrec.aid, cusrec.pid ) loop
               htp.formselectoption( lpad('.', indnt(c2rec.parent_scene),'.') || c2rec.title, cattributes=>'VALUE="' || c2rec.umo_scene_id || '"' );
              end loop;
              htp.formselectclose;
              htp.p( '</TD>' );
            htp.tablerowclose;

            if style = 'STANDARD'
             then
              htp.tablerowopen;
               htp.tabledata( htf.bold( LNG3.ADM_TXT_817 ),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
               htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
                htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
                htp.formselectopen( 'P5' );
                htp.formselectoption( NULL, 'SELECTED' );
                for c11rec in c11 loop
                 htp.formselectoption( c11rec.interest_name, cattributes=>'VALUE="' || c11rec.interest_id || '"' );
                end loop;
                htp.formselectclose;
                htp.p( '</TD>' );
              htp.tablerowclose;
             else
              htp.formhidden( 'P5', NULL );
            end if;

            htp.tablerowopen;
             htp.tabledata( htf.bold( LNG2.FNM_TXT_130 ),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
             htp.tabledata( LNG2.FNM_TXT_131 || ' ' || htf.formtext( 'P6A', 10, 20 ),cattributes=>pfx.qcbground);
             htp.tabledata( LNG2.FNM_TXT_132 || ' ' || htf.formtext( 'P6B', 10, 20 ),cattributes=>pfx.qcbground);
            htp.tablerowclose;

            if style = 'STANDARD'
             then
              htp.tablerowopen;
               htp.tabledata( htf.bold( LNG2.FNM_TXT_133 ),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
              htp.tabledata( htf.formcheckbox( 'P7A', 'T' ),cattributes=>pfx.qcbground);
               htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
              htp.tablerowclose;
              htp.tablerowopen;
               htp.tabledata( htf.bold( LNG2.FNM_TXT_134 ),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
               htp.tabledata( htf.formcheckbox( 'P7B', 'T' ),cattributes=>pfx.qcbground);
               htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
              htp.tablerowclose;
             else
              htp.formhidden( 'P7A', 'F' );
              htp.formhidden( 'P7B', 'F' );
           end if;

           if pfx.search_global = 'T'
            then
             htp.tablerowopen;
              htp.tabledata( htf.bold(LNG2.PFM_TXT_170),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
              htp.tabledata( htf.formcheckbox( 'ISGLB', 'T' ),cattributes=>pfx.qcbground);
              htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
             htp.tablerowclose;
           end if;

           if pfx.search_stem = 'T'
            then
             htp.tablerowopen;
             htp.tabledata( htf.bold( LNG2.FRM_TXT_054 ),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
             htp.tabledata( htf.formcheckbox( 'PS','1' ), cattributes=>pfx.qcbground);
             htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
            htp.tablerowclose;
           end if;

           if pfx.search_ignore_lbox = 'T'
            then
              htp.tablerowopen;
              -- Ignore Lightbox
              htp.tabledata( htf.bold(LNG4.AHC_TXT_431 || ' ' || lbox),cattributes=>pfx.qbground || ' ALIGN="RIGHT"');
              htp.tabledata( htf.formcheckbox( 'LBOX', 'T' ),cattributes=>pfx.qcbground);
              htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
              htp.tablerowclose;
           end if;

          htp.tableclose;
          htp.nl;
          htp.formsubmit( null, LNG2.FNM_TXT_127 );
          htp.formclose;
  end if; -- End is style = 'SIMPLE'
 end if;
end disp_manufacturer_search;

procedure disp_meta_query_search(surl in varchar2, ltype in varchar2, owner_id in integer, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE )
as

 cursor c12(intid integer) is select interest_name from interest_groups where interest_id = intid;

 cursor c12a(ttype varchar2) is
  select attribute_id,category,sub_category,edit_type,lov_list,maxlength,mandatory,umo_type
  from umo_attributes
  where umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT','ALL') and
        queryable = 'T' and
        ((business_feature is null) or (business_feature is not null and business_feature = ttype)) and
        displayed = 'T'
  order by category,sub_category;

 cursor c12b(ttype varchar2) is
  select count('x') cnt
  from umo_attributes
  where umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT','ALL') and
        queryable = 'T' and
        ((business_feature is null) or (business_feature is not null and business_feature = ttype)) and
        displayed = 'T';

 cursor c13(acid integer, ltype varchar2, sess_id integer, vpid integer) is
  select distinct src_name,cust_id
  from meta_tag_query
  where pid = vpid and
       nvl(aid,0) = nvl(acid,0) and
       login_type = ltype and
       ((ltype = 'PHOTOGRAPHER') or
        (ltype in ('OWNER','PROFILE') and sessid is null) or
        (ltype in ('OWNER','PROFILE') and sessid is not null and sessid = sess_id) or
        (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) )
  order by src_name;

 cursor c14(acid integer, srcnme varchar2, ltype varchar2, sess_id integer, vpid integer) is
   select *
   from meta_tag_query
   where pid = vpid and
         nvl(aid,0) = nvl(acid,0) and
         src_name = srcnme and
         login_type = ltype and
        ((ltype = 'PHOTOGRAPHER') or
        (ltype in ('OWNER','PROFILE') and sessid is null) or
        (ltype in ('OWNER','PROFILE') and sessid is not null and sessid = sess_id) or
         (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) )
   order by order_by;

 cursor c15(acid integer, srcnme varchar2, ltype varchar2, sess_id integer, vpid integer) is
   select count('x') cnt
   from meta_tag_query
   where pid = vpid and
         nvl(aid,0) = nvl(acid,0) and
         src_name = srcnme and
         login_type = ltype and
        ((ltype = 'PHOTOGRAPHER') or
         (ltype in ('OWNER','PROFILE') and sessid is null) or
         (ltype in ('OWNER','PROFILE') and sessid is not null and sessid = sess_id) or
         (ltype in ('CUSTOMER','PROFILEG') and (src_name = LNG.PHG_TXT_055) and (sessid = sess_id)) );

 c12rec		c12%ROWTYPE;
 c12brec	c12b%ROWTYPE;
 c15rec		c15%ROWTYPE;
 foundrec	boolean;
 rowsret	integer;
 vpid		integer;
 last_umo	integer;
 isnew		char(1);
 lbox		varchar2(100);

begin
 lbox := glbx.userpref(cusrec.pid,cusrec.aid,'LIGHTBOX');
 if substr(pfx.search_choices,4,1) = 'T'
  then
    htp.bold( LNG3.ADM_TXT_954 );
    htp.nl;
    foundrec := FALSE;
    if ltype = 'PHOTOGRAPHER' then vpid := cusrec.pid; else vpid := 0; end if;
    for c13rec in c13(cusrec.aid,ltype,owner_id,vpid) loop
     if c13%ROWCOUNT = 1
      then
        if pfx.search_display_style = 'S'
         then
          htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
        elsif pfx.search_display_style = 'E'
         then
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
       htp.tabledata( htf.anchor( 'ump.meta_tag_search?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || '[' || cusrec.aid || ']' || replace( c13rec.src_name,' ','+') || '&start_from=1&display_detail=' || '&acid=' || acid, c13rec.src_name),cattributes=>pfx.qcbground);
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
         if c14rec.stem = 'T'
          then
           htp.p( '(' || LNG2.PFM_TXT_169 || ')' );
         end if;
         if c14%ROWCOUNT < c15rec.cnt
          then
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

    htp.formopen( 'cst.meta_tag_search' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'ACID', acid );
    htp.formhidden( 'ACCTYPE', ltype );
    htp.formhidden( 'PS', null );
    htp.formhidden( 'PSHOW', null );
    if pfx.search_display_style = 'S'
     then
      htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    elsif pfx.search_display_style = 'E'
     then
      htp.tableopen( cattributes=>'cellpadding=6 cellspacing=0 border=0 rules="NONE" frame="HSIDES,VSIDES"' );
    end if;
     htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
      htp.tabledata( htf.bold(LNG5.EXT_TXT_080),cattributes=>pfx.qcbground);
      htp.tabledata( htf.bold(LNG.PHG_TXT_504),cattributes=>pfx.qcbground);
      htp.tabledata( htf.formtext( 'P1N', 30, 100 ),cattributes=>pfx.qcbground);
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
      if pfx.search_stem = 'T'
       then
         htp.tabledata( LNG2.FRM_TXT_054 ,cattributes=>pfx.qcbground);
      end if;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground); -- And Or
      htp.tablerowclose;
      if pfx.search_email_on_new = 'T'
       then
        htp.tablerowopen;
         htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         htp.tabledata( htf.bold(LNG4.AHC_TXT_996),cattributes=>pfx.qcbground);
         htp.tabledata( htf.formcheckbox( 'P1S', 'T' ),cattributes=>pfx.qcbground);
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         if pfx.search_stem = 'T'
          then
           htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         end if;
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground); -- And Or
        htp.tablerowclose;
      end if;
      if pfx.search_ignore_lbox = 'T'
       then
        htp.tablerowopen;
        -- Ignore Lightbox
        htp.tabledata( '&nbsp;',cattributes=>pfx.qbground);
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
        htp.tabledata( htf.bold(LNG4.AHC_TXT_431 || ' ' || lbox),cattributes=>pfx.qcbground);
        htp.tabledata( htf.formcheckbox( 'LBOX', 'T' ),cattributes=>pfx.qcbground);
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
        if pfx.search_stem = 'T'
         then
          htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
        end if;
        htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground); -- And Or
       htp.tablerowclose;
      end if;
    open c12b(theme_rec.theme_type);
    fetch c12b into c12brec;
    close c12b;
    for c12arec in c12a(theme_rec.theme_type) loop
     htp.tablerowopen;
      htp.tabledata( initcap(c12arec.category),cattributes=>pfx.qbground);
      htp.tabledata( htf.formcheckbox( 'PSHOW', c12arec.sub_category,'CHECKED'),cattributes=>pfx.qcbground);
      htp.tabledata( initcap(c12arec.sub_category) || ' - ' || initcap(htf.italic( c12arec.umo_type )),cattributes=>pfx.qcbground);
      if c12arec.edit_type in ('VARCHAR','EMAIL','LINK','DATE','TIME','Keyword','SQL QUERY')
       then
         htp.formhidden( 'ATTRID', c12arec.attribute_id );
         htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
         htp.tabledata( htf.formselectopen( 'P1' ) || htf.formselectoption( LNG.PHG_TXT_505, 'SELECTED' ) || htf.formselectoption( LNG.PHG_TXT_506 ) || htf.formselectoption( LNG.PHG_TXT_508 ) || htf.formselectoption( LNG.PHG_TXT_507 ) || htf.formselectclose,cattributes=>pfx.qcbground);
         htp.tabledata( htf.formtext('TAG_VALUE',30,c12arec.maxlength),cattributes=>pfx.qcbground);
      elsif c12arec.edit_type = 'LOV'
       then
         htp.formhidden( 'ATTRID', c12arec.attribute_id );
         htp.formhidden( 'P1', NULL );
         htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
         glbx.meta_lov( 'TAG_VALUE', 'F', c12arec.lov_list, NULL );
         htp.p( '</TD>' );
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
      elsif c12arec.edit_type = 'INTEGER'
       then
         htp.formhidden( 'ATTRID', c12arec.attribute_id );
         htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
         htp.tabledata( LNG2.FNM_TXT_131 || ':' || htf.formtext('P1',10,20),cattributes=>pfx.qcbground);
         htp.tabledata( LNG2.FNM_TXT_132 || ':' || htf.formtext('TAG_VALUE',10,20),cattributes=>pfx.qcbground);
      elsif c12arec.edit_type = 'NUMBER'
       then
         htp.formhidden( 'ATTRID', c12arec.attribute_id );
         htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
         htp.tabledata( htf.formselectopen( 'P1' ) || htf.formselectoption( '=', 'SELECTED' ) || htf.formselectoption( '<' )  || htf.formselectoption( '>' )   || htf.formselectoption( '>=' )  || htf.formselectoption( '<=' )  || htf.formselectoption( '<>' )   || htf.formselectclose,cattributes=>pfx.qcbground);
         htp.tabledata( htf.formtext('TAG_VALUE',10,20),cattributes=>pfx.qcbground);
      elsif c12arec.edit_type = 'SQL'
       then
         htp.formhidden( 'ATTRID', c12arec.attribute_id );
         htp.formhidden( 'P1', NULL );
         htp.formhidden( 'EDIT_TYPE', c12arec.edit_type );
         htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
         glbx.meta_sql( null, null, 'TAG_VALUE', 'F', c12arec.lov_list, NULL );
         htp.p( '</TD>' );
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground);
      elsif c12arec.edit_type = 'Boolean'
       then
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
      if pfx.search_stem = 'T'
       then
         htp.tabledata( htf.formcheckbox( 'PS',to_char(c12arec.attribute_id) ) ,cattributes=>pfx.qcbground);
      end if;
      if c12a%ROWCOUNT < c12brec.cnt
       then
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
end disp_meta_query_search;

procedure acct_search( surl varchar2, acid in integer default null, search_call in varchar2 default NULL )
as

 cursor c1a(sess_id varchar2) is select aid from login_session where sessid = sess_id;

 cusrec		customer_account%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 pfx		THEME%ROWTYPE;
 vsearch	varchar2(20);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 retbool	boolean;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.ACCT_SEARCH' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 pfx := glbx.get_thm( cusrec.theme_name );
 glbx.main_title( surl, lng.CST_TXT_036,glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,sim_three_frame=>pfx.sim_three_frame,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );

 vsearch := search_call;
 -- hard Coded Defaults
 if vsearch is null
  then
   if ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
    then
     vsearch := glbx.saved_preference_value(acid, profid, ltype, 'SEARCH_DEFAULT' );
   end if;
   if vsearch is null
    then
     if pfx.search_default = 'S'
      then
       vsearch := 'SIMPLE';
     elsif pfx.search_default = 'A'
      then
       vsearch := 'ADVANCED';
     elsif pfx.search_default = 'M'
      then
       vsearch := 'MANUFACTURER';
     elsif pfx.search_default = 'Q'
      then
       vsearch := 'META';
     end if;
     if ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
      then
       retbool := glbx.saved_preference_update(acid, profid, ltype, 'SEARCH_DEFAULT', vsearch );
     end if;
   end if;

  else

   if ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
    then
     retbool := glbx.saved_preference_update(acid, profid, ltype, 'SEARCH_DEFAULT', vsearch );
   end if;

 end if;

 if pfx.search_icons = 'F'
  then
   if not (substr(pfx.search_choices,1,4) in ('TFFF','FTFF','FFTF','FFFT'))
    then
     htp.tableopen( cattributes=>'cellpadding=4 cellspacing=0 border=0' );
      htp.tablerowopen;
       if nvl(vsearch,'SIMPLE') = 'SIMPLE' and substr(pfx.search_choices,1,1) = 'T'
        then
         htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=SIMPLE',LNG4.AHC_TXT_412), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
        else
         if substr(pfx.search_choices,1,1) = 'T' then htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=SIMPLE',LNG4.AHC_TXT_412), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"'); end if;
       end if;
       if vsearch = 'ADVANCED' and substr(pfx.search_choices,2,1) = 'T'
        then
         htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=ADVANCED',initcap(LNG2.PBK_TXT_082)), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
        else
         if substr(pfx.search_choices,2,1) = 'T' then htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=ADVANCED',initcap(LNG2.PBK_TXT_082)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"'); end if;
       end if;
       if vsearch = 'MANUFACTURER' and substr(pfx.search_choices,3,1) = 'T'
        then
         htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=MANUFACTURER',nvl(pfx.search_mfctr_title,LNG2.PBK_TXT_009)), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
        else
         if substr(pfx.search_choices,3,1) = 'T' then htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=MANUFACTURER',nvl(pfx.search_mfctr_title,LNG2.PBK_TXT_009)), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"'); end if;
       end if;
       if vsearch = 'META' and substr(pfx.search_choices,4,1) = 'T'
        then
         htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=META',LNG4.AHC_TXT_413), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
        else
         if substr(pfx.search_choices,4,1) = 'T' then htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=META',LNG4.AHC_TXT_413), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"'); end if;
       end if;
      htp.tablerowclose;
     htp.tableclose;
     htp.line;
   end if;

 else

   -- Display Icons
   if not (substr(pfx.search_choices,1,4) in ('TFFF','FTFF','FFTF','FFFT'))
    then
     htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
      htp.tablerowopen;
       if substr(pfx.search_choices,1,1) = 'T'
        then
         htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=SIMPLE',htf.img( cust_button(pfx,'search_a.gif',5),cattributes=>'border=0',calt=>LNG4.AHC_TXT_412 )), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
       end if;
       if substr(pfx.search_choices,2,1) = 'T'
        then
         htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=ADVANCED',htf.img( cust_button(pfx,'search_b.gif',5),cattributes=>'border=0',calt=>initcap(LNG2.PBK_TXT_082) )), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
       end if;
       if substr(pfx.search_choices,3,1) = 'T'
        then
         htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=MANUFACTURER',htf.img( cust_button(pfx,'search_c.gif',5),cattributes=>'border=0',calt=>nvl(pfx.search_mfctr_title,LNG2.PBK_TXT_009) )), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
       end if;
       if substr(pfx.search_choices,4,1) = 'T'
        then
         htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&search_call=META',htf.img( cust_button(pfx,'search_d.gif',5),cattributes=>'border=0',calt=>LNG4.AHC_TXT_413 )), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"');
       end if;
      htp.tablerowclose;
     htp.tableclose;
     htp.line;
   end if;

 end if;

 if nvl(vsearch,'SIMPLE') = 'SIMPLE'
  then
   disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, pfx.search_style_simple );
 end if;

 if vsearch = 'ADVANCED'
  then
   disp_advanced_search(surl, ltype, owner_id, profid, acid, cusrec, pfx, theme_rec );
 end if;

 if vsearch = 'MANUFACTURER'
  then
   disp_manufacturer_search(surl, ltype, owner_id, profid, acid, cusrec, pfx, theme_rec, pfx.search_style_mfctr );
 end if;

 if vsearch='META'
  then
   disp_meta_query_search(surl, ltype, owner_id, profid, acid, cusrec, pfx, theme_rec );
 end if;

 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'ACCT_SEARCH',cusrec.pid,owner_id,errmsg=>sqlerrm);
end acct_search;

procedure simple_search( surl in varchar2, p1 in varchar2, p2 in varchar2 default 'N', p3 in GLBX.MYARRAY, acid in integer, age in varchar2 default null, umoids in varchar2 default null, find in varchar2 default null, display_number in varchar2 default null, sorton in char default 'N', image_dim in char default 'A', sec_details in ump.SECURITY_DETAILS default ump.empty_sec )
as

 cusrec		customer_account%ROWTYPE;
 vp2		GLBX.MYARRAY;
 vp3		GLBX.MYARRAY;
 vp5		GLBX.MYARRAY;
 vps		GLBX.MYARRAY;
 lctr		integer;
 actr		integer;
 ctr		integer;
 x		integer;
 nmb		number;
 v_id		varchar2(100);
 v_ids		varchar2(32767);
 e_arr		GLBX.MYARRAY;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin
 -- convert a simple search into an advanced search (replace * with %)
 -- p1 search term
 -- p2 not used
 -- p3 umo_scene_id

 -- Handle the case if multiple umo_ids are passed through from the simple search
 if sec_details.ltype is null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.SIMPLE_SEARCH' );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   ltype := sec_details.ltype;
   profid := sec_details.profid;
 end if;

 if ltype = 'PHOTOGRAPHER' or sec_details.ltype is not null
  then
   cusrec := glbx.get_aid( acid, 'C', ltype );
  else
   cusrec := glbx.get_aid( owner_id, 'S', ltype );
 end if;
 pfx := glbx.get_thm( cusrec.theme_name );

 if p3.count = 1
  then
   if p3(1) = 'CATEGORY_SEARCH'
    then
     category_search( surl, stype, ltype, profid, acid, cusrec, p1 );
     return;
   end if;
 end if;

 if substr(p1,1,10) = '::SEARCH::'
  then
   cst.disp_category(surl=>surl,left_api_parm=> substr(p1,11),start_from=>1);
   return;
 elsif substr(p1,1,8) = '::EXIT::'
  then
   dapi.GLOBAL_SURL := surl;
   return;
 end if;

 if p3.count > 1
  then
   for j in p3.first..p3.last loop
    v_ids := v_ids || ',' || p3(j);
   end loop;
   simple_search(surl, p1, p2, e_arr, acid, age, v_ids, find, display_number, sorton, image_dim, sec_details=>sec_details);
   return;

  elsif p3.count = 1
   then
    v_id := p3(1);

  else
   v_id := '0';

 end if;

 /*
  To Build:
   . handle "xx xx"
   . remove stop words
   . minus sign is NOT
   . add support for "sound like" either as a special symbol or
   . brackets override and go straight into contains clause - no interpretation
   . strip special characters (what are they?)
 */
 for j in 1..5 loop
  vps(j) := NULL;
  vp5(j) := LNG.PHG_TXT_509;
  vp2(j) := LNG.PHG_TXT_505;
  vp3(j) := null;
 end loop;
 actr := 1;
 ctr := 1;
 lctr := 0;

 loop
  x := instr( p1, ' ', 1, actr );
  if x = 0
   then
    vp3(ctr) := substr(p1,lctr+1);
    if upper(vp3(ctr)) = upper(LNG.PHG_TXT_509) or upper(vp3(ctr)) = upper(LNG.PHG_TXT_510) or vp3(ctr) in ('&','|')
     then
      null;
     else

      if substr(vp3(ctr),1,1) = '!'  -- Sounds Like
       then
        vp2(ctr) := LNG.PHG_TXT_508;
        vp3(ctr) := substr(vp3(ctr),2);
      elsif substr(vp3(ctr),1,1) = '$'  -- Stem
       then
        vps(ctr) := 'T';
        vp3(ctr) := substr(vp3(ctr),2);
      elsif instr(vp3(ctr),'%') > 0
       then
        vp2(ctr) := LNG.PHG_TXT_506;
      elsif instr(vp3(ctr),'*') > 0
       then
        vp3(ctr) := replace(vp3(ctr),'*','%');
        vp2(ctr) := LNG.PHG_TXT_506;
      else

       begin
        -- If Search for a number is enabled then search on number and mark it as a number search (looks for a number either side of it
        if pfx.search_number_enable = 'T'
         then
          nmb := to_number(vp3(ctr));
          vp2(ctr) := 'N' || LNG.PHG_TXT_505;
         else
          vp2(ctr) := LNG.PHG_TXT_506;
          vp3(ctr) := vp3(ctr);
        end if;
       exception
        when others then
        vp2(ctr) := LNG.PHG_TXT_506;
        vp3(ctr) := vp3(ctr) || '%';
       end;

      end if;
     end if;
    exit;
  end if;
  vp3(ctr) := substr(p1,lctr+1,(x-lctr)-1);

  if (upper(vp3(ctr)) = upper(LNG.PHG_TXT_509)) or (vp3(ctr) = '&') -- And Check
   then
    null;

  elsif (upper(vp3(ctr)) = upper(LNG.PHG_TXT_510)) or (vp3(ctr) = '|') -- Or Check
   then
    if ctr > 1
     then
      vp5(ctr-1) := LNG.PHG_TXT_510;
    end if;

  else

    if substr(vp3(ctr),1,1) = '!'  -- Sounds Like
     then
      vp2(ctr) := LNG.PHG_TXT_508;
      vp3(ctr) := substr(vp3(ctr),2);
    elsif substr(vp3(ctr),1,1) = '$'  -- Stem
     then
      vps(ctr) := 'T';
      vp3(ctr) := substr(vp3(ctr),2);
    elsif instr(vp3(ctr),'%') > 0     -- Starts With
     then
      vp2(ctr) := LNG.PHG_TXT_506;
    elsif instr(vp3(ctr),'*') > 0
     then
      vp3(ctr) := replace(vp3(ctr),'*','%'); -- Starts With and replace wildcard with Oracle wildcard
      vp2(ctr) := LNG.PHG_TXT_506;
    else
     -- Check if Number. If so, then don't do a wildcard search
     begin
      if pfx.search_number_enable = 'T'
       then
        nmb := to_number(vp3(ctr));
        vp2(ctr) := 'N' || LNG.PHG_TXT_505;
       else
        vp2(ctr) := LNG.PHG_TXT_506;
        vp3(ctr) := vp3(ctr) || '%';
      end if;
     exception
      when others then
      vp2(ctr) := LNG.PHG_TXT_506;
      vp3(ctr) := vp3(ctr) || '%';
     end;

    end if;
    ctr := ctr + 1;

  end if;

  actr := actr + 1;
  lctr := x;
  if actr > 5 then exit; end if;
 end loop;

 run_query( surl, v_id, p1s=>'F', acid=>acid, lbox=>'F', p1n=>LNG.PHG_TXT_055, isglb=>'F', p2=>vp2, p3=>vp3, p5=>vp5, ps=>vps, umoids=>umoids, p1a=>age, display_number=>display_number, sorton=>sorton, image_dim=>image_dim, sec_details=>sec_details );

exception when others then
 glbx.error_details( 'CST', 'SIMPLE_SEARCH',null,null,errmsg=>sqlerrm);
end simple_search;

procedure run_query( surl varchar2, p1 in varchar2, p1n in varchar2, p1s in char default 'F', p1a in varchar2 default null, umoids in varchar2 default null, isglb in varchar2 default 'F', acid in integer, lbox in varchar2 default 'F', display_number in varchar2 default null, sorton in char default 'N', image_dim in char default 'A', p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, ps in GLBX.MYARRAY, sec_details in ump.SECURITY_DETAILS default ump.empty_sec )
as

 cursor c2(kword varchar2) is select 'x' foundrec from dictionary where term = kword and association_type = 'S';
 cursor c3(acid integer) is select * from customer_account where aid = acid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 maxctr		integer;
 vpid		integer;
 dsp		integer;
 profid		integer;
 retbool	boolean;
 adj_term	char(1);
 trm		varchar2(100);
 stem		GLBX.MYARRAY;

begin
 if sec_details.ltype is null
  then
   glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.RUN_QUERY' );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
   c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
  else
   open c3(sec_details.aid);
   fetch c3 into c1rec;
   close c3;
 end if;

 pfx := glbx.get_thm( c1rec.theme_name );
 if ltype = 'PHOTOGRAPHER'
  then
   vpid := c1rec.pid;
  else
   vpid := 0;
 end if;

 begin dsp := to_number(display_number); exception when others then dsp := NULL; end;
 if dsp is not null and ltype not in ('CUSTOMER','PROFILEG')
  then
   retbool := glbx.saved_preference_update(c1rec.aid, profid, ltype, 'DISPLAY_NUMBER', to_char(dsp) );
 end if;

 for j in 1..5 loop
  stem(j) := 'F';
 end loop;
 for j in ps.first..ps.last loop
  if nvl(to_number(ps(j)),0) > 0
   then
    stem(to_number(ps(j))) := 'T';
  end if;
 end loop;

 adj_term := 'F';
 if p1 is not null
  then
   delete from advanced_search where pid = vpid and aid = c1rec.aid and src_name = nvl(p1n,LNG.PHG_TXT_055) and login_type = ltype;
   for j in p3.first..p3.last loop
    if p3(j) is not null
     then
      -- Look for adjacent terms enclosed in Quotes
      trm := trim(substr(p3(j),1,100));
      if substr(trm,1,1) = '"'
       then
        if adj_term = 'F' then adj_term := 'T'; else adj_term := 'F'; end if;
        trm := trim(substr(trm,2));
      end if;
      if substr(trm,length(trm),1) = '"'
       then
        if adj_term = 'F' then adj_term := 'T'; else adj_term := 'F'; end if;
        trm := trim(substr(trm, 1, length(trm)-1));
      end if;

      -- Look for Stopwords and ignore them
      open c2(upper(adj_term));
      fetch c2 into c2rec;
      if c2%NOTFOUND
       then
        close c2;
        maxctr := j;
        insert into advanced_search(pid,aid,order_by,src_name,keyword,clause,join_clause,
                                    umo_scene_id,cust_id,login_type,sessid,stem,is_global,ignore_lightbox,adjacent_term,notify_on_new,age,umo_scene_ids,photo_dimension,sort_on) values
         (vpid,c1rec.aid,j,nvl(p1n,LNG.PHG_TXT_055),decode(p2(j),LNG.PHG_TXT_506,replace(trm,'*','%'),trm),p2(j),p5(j),
          to_number(decode(p1,LNG.PHG_ALT_390,null,p1)),c1rec.aid,ltype,owner_id, stem(j), isglb, lbox, adj_term, p1s, p1a, umoids, image_dim, sorton);
       else
        close c2;
      end if;

    end if;
   end loop;
   update advanced_search
    set
     join_clause = NULL
   where order_by = maxctr and
         aid = c1rec.aid and
         pid = vpid and
         login_type = ltype and
         ignore_lightbox = lbox and
         src_name = nvl(p1n,LNG.PHG_TXT_055);
   commit;
 end if;

 if pfx.search_before_entry_api is not null and pfx.search_after_entry_api is not null
  then
   execute immediate 'begin ' || pfx.search_after_entry_api || '(surl=>:surl, acid=>:acid, query_name=>:query_name, query_type=>''ADVANCED''); end;'
    using surl, acid, nvl(p1n,LNG.PHG_TXT_055);
   return;
  else
   ump.advanced_search_phg( surl=>glbx.rndsurl(surl), left_api_parm=>'[' || c1rec.aid || ']' || nvl(p1n,LNG.PHG_TXT_055), start_from =>1, display_detail=>NULL,acid=>acid, ctx=>pfx.search_with_context, sec_details=>sec_details );
 end if;

exception when others then
 glbx.error_details( 'CST', 'RUN_QUERY',owner_id,c1rec.aid,errmsg=>sqlerrm,extdet=>'P1:' || p1 || ' TRM:' || trm);
end run_query;

procedure run_query_mfc( surl in varchar2, p1 in varchar2, p1n in varchar2, p1s in char default 'F', isglb in varchar2 default 'F', p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6a in varchar2, p6b in varchar2,
                         p7a in varchar2 default 'F', p7b in varchar2 default 'F', p8 in varchar2, ps in varchar2 default 'F', acid in integer, lbox in varchar2 default 'F', display_number in varchar2 default null )
as

 cursor c2( brnd varchar2 ) is
  select brand_id from brand where brand_name = brnd
  union all
  select brand_id from brand where brand_name like brnd || '%'
  union all
  select brand_id from brand where soundex(brand_name) = soundex(brnd)
  union all
  select brand_id from brand where brand_name like '%' || brnd || '%';

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 maxctr		integer;
 nmb1		number;
 nmb2		number;
 dsp		integer;
 bid		integer;
 vpid		integer;
 profid		integer;
 retbool	boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.RUN_QUERY_MFC' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );

 if ltype = 'PHOTOGRAPHER'
  then
   vpid := c1rec.pid;
  else
   vpid := 0;
 end if;
 begin dsp := to_number(display_number); exception when others then dsp := NULL; end;
 if dsp is not null and ltype not in ('CUSTOMER','PROFILEG')
  then
   retbool := glbx.saved_preference_update(c1rec.aid, profid, ltype, 'DISPLAY_NUMBER', to_char(dsp) );
 end if;
 begin nmb1 := to_number(p6a); exception when others then nmb1 := NULL; end;
 begin nmb2 := to_number(p6b); exception when others then nmb2 := NULL; end;
 if p8 is null
  then
   bid := NULL;
  else
   open c2(upper(p8));
   fetch c2 into bid;
   close c2;
 end if;
 delete from manufacturer_search where pid = vpid and nvl(aid,0) = nvl(c1rec.aid,0) and src_name = nvl(p1n,LNG.PHG_TXT_055) and login_type = ltype;
 insert into manufacturer_search
    (pid,aid,order_by,login_type,
     cust_id,umo_scene_id,
     sessid,src_name,keyword,brand,
     interest_id,price_from,price_to,
     mfctr_clearance,reverse_auction,is_global,stem,clause,ignore_lightbox,notify_on_new) values
    (vpid,c1rec.aid,1,ltype,
     c1rec.aid,p4,
     owner_id,nvl(p1n,LNG.PHG_TXT_055),p3,bid,
     p5,nmb1,nmb2,
     p7a,p7b,isglb,ps,p2,lbox,p1s);
  commit;

 if pfx.search_before_entry_api is not null and pfx.search_after_entry_api is not null
  then
   execute immediate 'begin ' || pfx.search_after_entry_api || '(surl=>:surl, acid=>:acid, query_name=>:query_name, query_type=>''MANUFACTURER''); end;'
    using surl, acid, nvl(p1n,LNG.PHG_TXT_055);
   return;
  else
   ump.manufacturer_search_phg( surl=>glbx.rndsurl(surl), left_api_parm=>'[' || c1rec.aid || ']' || nvl(p1n,LNG.PHG_TXT_055), start_from =>1, display_detail=>NULL,acid=>acid );
 end if;

exception when others then
 glbx.error_details( 'PHG', 'RUN_QUERY_MFC',owner_id,c1rec.aid,errmsg=>sqlerrm,extdet=>'P1:' || p1);
end run_query_mfc;

procedure meta_tag_search( surl varchar2, acctype in varchar2, p1n in varchar2, p1s in char default 'F', acid in integer, lbox in varchar2 default 'F', attrid in GLBX.MYARRAY, edit_type in GLBX.MYARRAY, P1 in GLBX.MYARRAY, PS in GLBX.MYARRAY, TAG_VALUE in GLBX.MYARRAY, AOR IN GLBX.MYARRAY, PSHOW IN GLBX.MYARRAY, display_number in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 t1		integer;
 t2		integer;
 t3		number;
 incr		integer;
 ctr		integer;
 lastctr	integer;
 vpid		integer;
 dsp		integer;
 profid		integer;
 retbool	boolean;
 cstem		char(1);
 shw		char(1);
 tempstr	varchar2(100);

 function check_stem( attribute_id in integer, ps in GLBX.MYARRAY )
  return char
 as
  str varchar2(100);
 begin
  begin
   str := to_char(attribute_id);
  exception when others
   then
    str := null;
  end;
  if ps.count = 0 then return( 'F' ); end if;
  for j in ps.first..ps.last loop
   if (ps(j) = str) and (ps(j) is not null)
    then
     return( 'T' );
   end if;
  end loop;
  return( 'F' );
 end check_stem;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.META_TAG_SEARCH' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 delete from meta_tag_query where sessid = owner_id;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );

 if ltype = 'PHOTOGRAPHER'
  then
   vpid := c1rec.pid;
  else
   vpid := 0;
 end if;


 delete from meta_tag_query where pid = vpid and aid = c1rec.aid and src_name = nvl(p1n,LNG.PHG_TXT_055) and login_type = ltype;

 begin dsp := to_number(display_number); exception when others then dsp := NULL; end;
 if dsp is not null and ltype not in ('CUSTOMER','PROFILEG')
  then
  retbool := glbx.saved_preference_update(c1rec.aid, profid, ltype, 'DISPLAY_NUMBER', to_char(dsp) );
 end if;

 for j in attrid.first..attrid.last loop
  incr := 1;
  lastctr := 0;

  loop
   ctr := nvl(instr(tag_value(j),' ',1,incr),0);
   if ctr = 0
    then
    tempstr := substr(tag_value(j),lastctr+1);
   else
    tempstr := substr(tag_value(j),lastctr+1, (ctr - lastctr) - 1);
   end if;
   incr := incr + 1;
   lastctr := ctr;
   tempstr := trim(tempstr);
   if incr > 100 then exit; end if; -- Infinite Loop Protection

   if edit_type(j) in ('VARCHAR','EMAIL','LINK','DATE','TIME','Keyword','SQL QUERY')
   then
    if tempstr is not null
     then
      cstem := check_stem(attrid(j),ps);
      shw := check_stem(attrid(j),pshow);
      insert into meta_tag_query(pid,aid,order_by,login_type,cust_id,sessid,attribute_id,value_a,value_b,search_type,search_item,src_name,ignore_lightbox,stem,andor,notify_on_new,show_column) values
      (vpid,c1rec.aid,1,ltype,c1rec.aid,owner_id,attrid(j),tempstr,null,edit_type(j),p1(j),nvl(p1n,LNG.PHG_TXT_055),lbox,cstem,aor(j),p1s,shw);
    end if;

   elsif edit_type(j) in ('LOV','SQL','Boolean')
   then
    if tempstr is not null
    then
      cstem := check_stem(attrid(j),ps);
      shw := check_stem(attrid(j),pshow);
      insert into meta_tag_query(pid,aid,order_by,login_type,cust_id,sessid,attribute_id,value_a,value_b,search_type,search_item,src_name,ignore_lightbox,stem,andor,notify_on_new,show_column) values
      (vpid,c1rec.aid,1,ltype,c1rec.aid,owner_id,attrid(j),tempstr,null,edit_type(j),p1(j),nvl(p1n,LNG.PHG_TXT_055),lbox,cstem,aor(j),p1s,shw);
    end if;

   elsif edit_type(j) = 'INTEGER'
   then
    begin t1 := tempstr; exception when others then t1 := NULL; end;
    begin t2 := p1(j); exception when others then t2 := NULL; end;
    if t1 is not null and t2 is not null
    then
     cstem := check_stem(attrid(j),ps);
     shw := check_stem(attrid(j),pshow);
     insert into meta_tag_query(pid,aid,order_by,login_type,cust_id,sessid,attribute_id,value_a,value_b,search_type,search_item,src_name,ignore_lightbox,stem,andor,notify_on_new,show_column) values
     (vpid,c1rec.aid,1,ltype,c1rec.aid,owner_id,attrid(j),to_char(nvl(t1,0)),to_char(nvl(t2,99999999)),edit_type(j),null,nvl(p1n,LNG.PHG_TXT_055),lbox,cstem,aor(j),p1s,shw);
    end if;

   elsif edit_type(j) = 'NUMBER' and tempstr is not null
   then
    begin t3 := tempstr; exception when others then t3 := NULL; end;
    if t3 is not null
    then
     cstem := check_stem(attrid(j),ps);
     shw := check_stem(attrid(j),pshow);
     insert into meta_tag_query(pid,aid,order_by,login_type,cust_id,sessid,attribute_id,value_a,value_b,search_type,search_item,src_name,ignore_lightbox,stem,andor,notify_on_new,show_column) values
     (vpid,c1rec.aid,1,ltype,c1rec.aid,owner_id,attrid(j),to_char(t3),null,edit_type(j),p1(j),nvl(p1n,LNG.PHG_TXT_055),lbox,cstem,aor(j),p1s,shw);
    end if;
   end if;
   if ctr = 0 then exit; end if;
  end loop;
 end loop;

 commit;

 if pfx.search_before_entry_api is not null and pfx.search_after_entry_api is not null
 then
  execute immediate 'begin ' || pfx.search_after_entry_api || '(surl=>:surl, acid=>:acid, query_name=>:query_name, query_type=>''META''); end;'
  using surl, acid, nvl(p1n,LNG.PHG_TXT_055);
  return;
 else
  ump.meta_tag_search( surl=>glbx.rndsurl(surl), left_api_parm=>'[' || c1rec.aid || ']' || nvl(p1n,LNG.PHG_TXT_055), start_from =>1, display_detail=>NULL,acid=>acid );
 end if;

exception when others then
 glbx.error_details( 'CST', 'META_TAG_SEARCH', owner_id, c1rec.aid, errmsg=>sqlerrm);
end meta_tag_search;

procedure delete_query( surl varchar2, p1 in varchar2, typ in varchar2 default 'A', search_call in varchar2, acid in integer )
as

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 vpid		integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S',progcalled=>'CST.DELETE_QUERY' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if ltype = 'PHOTOGRAPHER'
  then
   c1rec := glbx.get_aid( acid, 'C', ltype );
   vpid := c1rec.pid;
  else
   c1rec := glbx.get_aid( owner_id, 'S', ltype );
   vpid := 0;
 end if;

 if typ = 'A'
  then
   delete from advanced_search where pid = vpid and aid = c1rec.aid and src_name = p1 and login_type = ltype;
 elsif typ = 'M'
  then
   delete from manufacturer_search where pid = vpid and nvl(aid,0) = nvl(c1rec.aid,0) and src_name = p1 and login_type = ltype;
 elsif typ = 'T'
  then
   delete from meta_tag_query where pid = vpid and aid = c1rec.aid and src_name = p1 and login_type = ltype;
 end if;
 commit;

 acct_search(surl=>glbx.rndsurl(surl),acid=>acid,search_call=>search_call);

exception when others then
 glbx.error_details( 'CST', 'DELETE_QUERY',owner_id,c1rec.aid,errmsg=>sqlerrm,extdet=>'P1:' || p1);
end delete_query;

function get_image_style( lsessid in integer )
 return varchar2
as
 cursor c1(lsessid integer) is select browser_type, os from login_session where sessid = lsessid;
 c1rec  c1%ROWTYPE;
begin
 open c1( lsessid );
 fetch c1 into c1rec;
 close c1;

 if upper(c1rec.browser_type) = 'NETSCAPE' or upper(c1rec.os) in ('MACPPC') then return( NULL ); else return( 'STYLE="display:block;"' ); end if;
end get_image_style;

procedure disp_by_scene( surl varchar2, result_list in ump.search_result_phg, search_total in integer,
                         left_api in varchar2, left_api_parm in varchar2,
                         display_detail in char, title in varchar2, help_file_code in varchar2, footer_api in varchar2,
                         current_page_number in integer, no_results_message in varchar2 default null, acid in integer default null,
                         msg in varchar2 default null, extra_term in varchar2 default null)
as

cursor c2( sess_id integer ) is select count('x') tot from shopping_basket sb, purchase_order po where po.sessid=sess_id and po.poid = sb.poid;
cursor c3( sess_id integer ) is select count('x') tot from lightbox where sessid=sess_id;
cursor c4( vspb integer ) is select * from phg_price_book where spb = vspb;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 pbook		phg_price_book%ROWTYPE;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 dispvert	char(1);
 klhf		char(1);
 pfx		theme%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 numb_photos	integer;
 disp_msg	varchar2(100);
 lbox		varchar2(100);
 cusloc		varchar2(100);
 hlp		varchar2(4000);
 vtitle		varchar2(4000);
 use_lnk	boolean;
 ispackprod	boolean;
 lboxall	varchar2(32767);
 image_style	varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.DISP_BY_SCENE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 --c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 --theme_rec := glbx.get_theme_types(c1rec.theme_type );
 --pfx := glbx.get_thm( c1rec.theme_name );
 glbx.get_all_order_details(owner_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec );

 lbox := glbx.userpref(c1rec.pid,c1rec.aid,'LIGHTBOX');
 image_style := get_image_style( owner_id );
 if acid is null
  then
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'NUMBER_PHOTOS'));
   numb_photos := nvl(numb_photos,10);
  else
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'PHOTO_DISPLAY'));
   numb_photos := nvl(numb_photos,10);
 end if;
 if pfx.keep_lhf = 'L'
   then
    if ltype = 'PHOTOGRAPHER'
     then
      cusloc := 'PHG_RIGHT';
     else
      cusloc := 'CUS_RIGHT';
    end if;
   else
    if ltype = 'PHOTOGRAPHER'
     then
      cusloc := 'PHG_RIGHT';
     else
      cusloc := '_top';
    end if;
 end if;

 if display_detail is null
  then
   dispvert := pfx.display_style;
  else
   dispvert := display_detail;
 end if;

 if pfx.tnail_disp_sml_font = 'T'
  then
   use_lnk := TRUE;
  else
   use_lnk := FALSE;
 end if;

 if pfx.tnail_disable_top = 'F'
  then
   klhf := pfx.keep_lhf;
   vtitle := title;
  else
   klhf := 'L'; -- Force it not to display anything in no frame mode
   vtitle := NULL;
 end if;

 --
 -- Packaged product check
 --
 open c4(voidrec.spb);
 fetch c4 into pbook;
 close c4;
 if packaged_product_check( 'CAT', purchord.poid, pbook, ltype )
  then
   vtitle := 'Packaged Products';
   ispackprod := TRUE;
  else
   ispackprod := FALSE;
 end if;

 if ltype = 'PHOTOGRAPHER'
  then
   glbx.main_title( surl, vtitle, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>nvl(help_file_code,'C05'),
   stype=>greatest(stype-nvl(pfx.tnumb_adj,0),1),sstyle=>pfx.text_font,lnk=>pfx.tnail_underline_active,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,
   det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,
   disptop=>klhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,
   errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font,
   instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,
   small_link=>use_lnk,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,
   uline=>pfx.uline, uline_active=>pfx.uline_active, uline_visited=>pfx.uline_visited,stylesh=>pfx.stylesheet);
  else
   glbx.main_title( surl, vtitle, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>nvl(help_file_code,'C05'),
   stype=>greatest(stype-nvl(pfx.tnumb_adj,0),1),sstyle=>pfx.text_font,lnk=>pfx.tnail_underline_active,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,
   det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript,
   disptop=>klhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,
   errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font,
   instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,
   small_link=>use_lnk,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,
   uline=>pfx.uline, uline_active=>pfx.uline_active, uline_visited=>pfx.uline_visited,stylesh=>pfx.stylesheet);
 end if;

 htp.p( '<CENTER>' );

 if ispackprod
  then
   packprod(surl,ltype,stype,owner_id,profid,acid,c1rec,pfx,theme_rec,purchord,voidrec, left_api, left_api_parm);
   return;
 end if;

 -- Instruction Text
 hlp := glbx.userpref(c1rec.pid,c1rec.aid,'HELP_INST');
 if hlp is not null
  then
   if pfx.tnail_disable_top = 'F' then glbx.instruction( hlp, pfx ); end if;
 end if;

 -- You have images in your basket message and lightbox
 if is_bf(theme_rec,ltype,429,429,'T','T',429,'T') and pfx.tnail_disable_top = 'F'
  then
   open c2(owner_id);
   fetch c2 into c2rec;
   close c2;
   open c3(owner_id);
   fetch c3 into c3rec;
   close c3;
   disp_msg := NULL;
   if c2rec.tot > 0
    then
     disp_msg := LNG5.EXT_TXT_244 || ' ' || voidrec.text_shopping_basket || ': ' || c2rec.tot;
   end if;
   if c3rec.tot > 0
    then
     if disp_msg is not null then disp_msg := disp_msg || '. '; end if;
     disp_msg := disp_msg || LNG5.EXT_TXT_244 || ' ' || lbox || ': ' || c3rec.tot;
   end if;
   glbx.instruction( disp_msg, pfx );
 end if;

 if msg is not null
  then
   if pfx.tnail_disable_top = 'F' then glbx.header_msg( msg ); end if;
 end if;

 initialise_control_buttons( surl, footer_api, left_api_parm, current_page_number, cusloc, dispvert, acid );

 -- Buttons at top of page (except for slider display where they only appear at the bottom of the screen
 if is_bf(theme_rec,ltype,186,187,'T','T',263,'T') and nvl(dispvert,'F') <> 'S' and pfx.tnail_disable_top = 'F'
  then
   if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and footer_api <> 'cst.disp_lightbox'
    then
    begin
     if result_list.count > 0
      then
       for j in result_list.first..result_list.last loop
        lboxall := lboxall || ',' || result_list(j).umo_id;
       end loop;
     end if;
    exception
     when others then null;
    end;
    else
     lboxall := NULL;
   end if;
   if substr(pfx.tnail_control_buttons,1,1) = 'T'
    then
     control_buttons(surl, owner_id, ltype, title, result_list, c1rec, left_api_parm, current_page_number, search_total, footer_api, numb_photos, lbox, lboxall, theme_rec, pfx, dispvert, acid, pfx.tnail_control_style, pbook=>pbook);
   end if;
 end if;

 if pfx.use_line = 'T' and pfx.tnail_disable_top = 'F' then htp.line; end if;

 if nvl(dispvert,'F') = 'T'
  then
   disp_by_scene_vertical(surl,stype,ltype,profid,result_list,c1rec,pfx,theme_rec,footer_api,left_api_parm,current_page_number,dispvert,acid,owner_id,no_results_message,voidrec,extra_term,image_style );
 elsif nvl(dispvert,'F') = 'D'
  then
   disp_by_scene_simple_vertical(surl,stype,ltype,profid,result_list,c1rec,pfx,theme_rec,footer_api,left_api_parm,current_page_number,dispvert,acid,owner_id,no_results_message,voidrec,extra_term,image_style);
  elsif nvl(dispvert,'F') = 'F'
   then
    disp_by_scene_horizontal(surl,stype,ltype,profid,result_list,c1rec,pfx,theme_rec,footer_api,current_page_number,dispvert,left_api_parm,cusloc,lbox,acid,owner_id,no_results_message,voidrec,extra_term,image_style);
  elsif nvl(dispvert,'F') = 'S'
   then
    -- Old Comic Style Interface, now called Slider Interface
    disp_by_scene_slider(surl,stype,ltype,profid,result_list,c1rec,pfx,theme_rec,footer_api,current_page_number,dispvert,left_api_parm,cusloc,lbox,acid,owner_id,no_results_message,voidrec,extra_term,image_style);
  elsif nvl(dispvert,'F') = 'V'
   then
    -- Old Image Vault
    htp.bold( 'This Option is Currently not Available' );
  elsif nvl(dispvert,'F') = 'M'
   then
    -- Museum Call
    cas_disp_pkg.pr_display(surl,stype,ltype,result_list,c1rec,pfx,theme_rec,footer_api,current_page_number,search_total,dispvert,left_api,left_api_parm,cusloc,lbox,acid,owner_id,msg);
  elsif nvl(dispvert,'F') = 'P'
   then
    -- Shop / Purchase Interface
    null;
    -- To be built
  elsif nvl(dispvert,'F') = 'X'
   then
    -- External Call
    display_api.main_display(surl,stype,ltype,result_list,c1rec,pfx,theme_rec,voidrec,footer_api,current_page_number,search_total,dispvert,left_api,left_api_parm,cusloc,lbox,acid,owner_id,msg,extra_term);
 end if;

 if pfx.use_line = 'T' then htp.line; end if;
 -- Buttons at bottom of page
 if is_bf(theme_rec,ltype,186,187,'T','T',263,'T')
  then
   if substr(pfx.tnail_control_buttons,2,1) = 'T'
    then
     control_buttons(surl, owner_id, ltype, title, result_list, c1rec, left_api_parm, current_page_number, search_total, footer_api, numb_photos, lbox, lboxall, theme_rec, pfx, dispvert, acid, pfx.tnail_control_style, pbook=>pbook);
   end if;
 end if;

 -- optionally display bottom of page markers
 if left_api is null and ltype = 'PHOTOGRAPHER'
  then
   cusloc := 'PHG_RIGHT';
 elsif left_api is null and ltype <> 'PHOTOGRAPHER' and pfx.keep_lhf = 'N'
  then
   cusloc := '_top';
 elsif left_api is null and ltype <> 'PHOTOGRAPHER' and pfx.keep_lhf = '2'
  then
   cusloc := 'CUS_BOTTOM';
 elsif left_api is null and ltype <> 'PHOTOGRAPHER'
  then
   cusloc := 'CUS_RIGHT';
 elsif left_api is not null and ltype = 'PHOTOGRAPHER'
  then
   cusloc := 'PHG_RIGHT';
 elsif pfx.keep_lhf = 'N'
  then
   cusloc := '_top';
 elsif pfx.keep_lhf = '2'
  then
   cusloc := 'CUS_BOTTOM';
 else
   cusloc := 'CUS_RIGHT';
 end if;
 htp.formclose;

 disp_bottom(surl,ltype,search_total,footer_api,left_api_parm,current_page_number,numb_photos,cusloc,pfx,c1rec,dispvert,acid);

 if pfx.tnail_inc_simple = 'T'
  then
    disp_standard_search(surl, stype, ltype, profid, acid, c1rec, pfx, theme_rec, 'SIMPLE' );
    if pfx.tnail_inc_privacy = 'T' then htp.nl; end if;
 end if;

 if pfx.tnail_inc_privacy = 'T'
  then
    disp_privacy(surl, ltype, profid, acid, c1rec, pfx, theme_rec );
 end if;

 htp.p( '</CENTER>' );

 if pfx.tnail_page_bottom is not null
  then
    execute immediate
      'begin ' || pfx.tnail_page_bottom ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,search_total=>:search_total,display_detail=>:display_detail,ltype=>:ltype,acid=>:acid);' ||
       'end;'
     using glbx.rndsurl(surl),left_api_parm,search_total,dispvert,ltype,acid;
 end if;

 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'CST', 'DISP_BY_SCENE',c1rec.pid,c1rec.aid,errmsg=>sqlerrm );
end disp_by_scene;

procedure disp_bottom( surl varchar2, ltype in varchar2, search_total in integer, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, numb_photos in integer,
                       cusloc in varchar2, pfx in THEME%ROWTYPE, c1rec in customer_account%ROWTYPE, display_detail in char default null, acid in integer default null )
as

 x1			integer;
 x2			integer;
 x3			integer;
 mchar			integer;
 i_query_id 		integer(16);
 s_selected_coll 	varchar2(20);
 s_view_type 		varchar2(5) := 'BRIEF';
 s_left_api_temp 	varchar(200) := '';

begin

 -- Need extra look and feel option supporting the delimeter (vertical bar is the default)

 -- Normal Numbers
 if pfx.image_counter_style = 'N'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
    htp.tablerowopen;
     htp.tabledata( htf.bold(lng.CST_TXT_045),cattributes=>' CLASS="SMALL"');
     for j in 1..trunc(search_total/numb_photos) loop
        if start_from = ((j-1)*numb_photos) + 1
         then
          htp.tabledata( '[' || to_char(((j-1)*numb_photos) + 1) || '-' || to_char( j*numb_photos ) || ']' ,cattributes=>' CLASS="SMALL"');
         else
          htp.tabledata( htf.anchor2(
                         footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || to_char(((j-1)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
                          '[' || to_char(((j-1)*numb_photos) + 1) || '-' || to_char( j*numb_photos ) || ']' ,ctarget=>cusloc),cattributes=>' CLASS="SMALL"');
        end if;
     end loop;
     if mod(search_total,numb_photos) <> 0
      then
        if start_from = (trunc(search_total/numb_photos)*numb_photos) + 1
         then
          htp.tabledata( '[' || to_char((trunc(search_total/numb_photos)*numb_photos) + 1) || '-' || to_char( search_total ) || ']',cattributes=>' CLASS="SMALL"');
         else
          htp.tabledata( htf.anchor2(
                           footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' ||  to_char((trunc(search_total/numb_photos)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
	                  '[' || to_char((trunc(search_total/numb_photos)*numb_photos) + 1) || '-' || to_char( search_total ) || ']' ,ctarget=>cusloc),cattributes=>' CLASS="SMALL"');
        end if;
     end if;
    htp.tablerowclose;
   htp.tableclose;

  -- Page Number
  elsif pfx.image_counter_style = 'P'
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 align="CENTER"' );
     htp.tablerowopen;
      htp.p( '<TD CLASS="SMALL" ALIGN="CENTER" VALIGN="TOP" CLASS="SMALL">');
       for j in 1..trunc(search_total/numb_photos) loop
        if start_from = ((j-1)*numb_photos) + 1
         then
           htp.p( to_char(j) || ' ' || pfx.page_delim || ' ');
         else
           htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                        '&start_from=' || to_char(((j-1)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
                        to_char(j),ctarget=>cusloc);
           htp.p( ' ' || pfx.page_delim || ' ' );
        end if;
       end loop;
       if (mod(search_total,numb_photos) <> 0) and (trunc(search_total/numb_photos)+1 > 1)
        then
        if start_from = (trunc(search_total/numb_photos)*numb_photos) + 1
         then
           htp.p( to_char(trunc(search_total/numb_photos)+1) );
         else
           htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                        '&start_from=' || to_char((trunc(search_total/numb_photos)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
                        to_char(trunc(search_total/numb_photos)+1),ctarget=>cusloc);
        end if;
       end if;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;

  -- Page Number Limit 10
  elsif pfx.image_counter_style = 'L'
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 align="CENTER"' );
     htp.tablerowopen;
      htp.p( '<TD ALIGN="CENTER" VALIGN="TOP" CLASS="SMALL">');
       x2 := trunc(start_from/numb_photos);
       x1 := least(((trunc(x2/10) + 1) * 10), trunc(search_total/numb_photos)+1 );
       x2 := (trunc(x2/10) * 10 ) + 1;
       if x2 >= 10
        then
           if x2 >= 20
            then
             htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                          '&start_from=1&display_detail=' || display_detail || '&acid=' || acid,
                          '&lt;&lt;' || LNG4.AHC_TXT_420 || ' ',ctarget=>cusloc,cattributes=>'CLASS="SMALL"');
            end if;
           htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                        '&start_from=' || to_char(((x2-11)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
                        '&lt;' || LNG4.AHC_TXT_419 || ' ',ctarget=>cusloc,cattributes=>'CLASS="SMALL"');
       end if;
       for j in x2..x1 loop
        if start_from = ((j-1)*numb_photos) + 1
         then
           htp.p( to_char(j) );
           if j < x1 then htp.p( ' ' || pfx.page_delim || ' ' ); end if;
         else
           htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                        '&start_from=' || to_char(((j-1)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
                        to_char(j),ctarget=>cusloc,cattributes=>'CLASS="SMALL"');
           if j < x1 then htp.p( ' ' || pfx.page_delim || ' ' ); end if;
        end if;
       end loop;

       if ((trunc(x2/10) + 1) * 10) < trunc(search_total/numb_photos)+1
        then
           htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                        '&start_from=' || to_char(least(((x2+9)*numb_photos) + 1,search_total-numb_photos)) || '&display_detail=' || display_detail || '&acid=' || acid,
                        ' ' || LNG.SLD_TXT_087 || '&gt;',ctarget=>cusloc);
           htp.p( ' / ' || to_char(trunc(search_total/numb_photos)+1) );
           htp.p( '</TD>' );
           htp.p( '<TD ALIGN="CENTER" VALIGN="TOP" CLASS="SMALL">');
           htp.formopen( 'cst.goto_page',cattributes=>'CLASS="SMALL"', ctarget=>cusloc );
           htp.formhidden( 'SURL', glbx.rndsurl(surl) );
           htp.formhidden( 'FOOTER_API', footer_api );
           htp.formhidden( 'LEFT_API_PARM', left_api_parm );
           htp.formhidden( 'DISPLAY_DETAIL', display_detail );
           htp.formhidden( 'ACID', acid );
           htp.formhidden( 'SEARCH_TOTAL', search_total );
           htp.formhidden( 'CURRPAGE', start_from );
           htp.formtext( 'PAGE', 5, 5 );
           htp.formsubmit( null, LNG4.AHC_TXT_426 );
           htp.formclose;
       end if;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;

  -- Page Number Limit 10 Display Style II, Museum Interface but will now work in the standard environment
  elsif pfx.image_counter_style = 'M'
   then
    pr_disp_nav_bar(surl, pfx, acid, replace(left_api_parm,'&','~'), start_from, search_total, numb_photos, cusloc, footer_api );

  -- Page Number Limit 10 Display Style III
  elsif pfx.image_counter_style = '3'
   then
    htp.tableopen( cattributes=>'width="80%" cellpadding=2 cellspacing=0 border=0 align="CENTER"' );
     htp.tablerowopen;
      htp.p( '<TD ' || pfx.qbground || ' ALIGN="LEFT" VALIGN="TOP" CLASS="SMALL">');
       x3 := trunc(search_total/numb_photos)+1;
       x2 := trunc(start_from/numb_photos);
       x1 := least(((trunc(x2/10) + 1) * 10), trunc(search_total/numb_photos)+1 );
       x2 := (trunc(x2/10) * 10 ) + 1;
       if x3 >= 10
        then
           if x2 >= 20
            then
             htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                          '&start_from=1&display_detail=' || display_detail || '&acid=' || acid,
                          '&lt;&lt;' || LNG4.AHC_TXT_420 || ' ',ctarget=>cusloc,cattributes=>'CLASS="SMALL"'); -- First
            end if;
            if x2 > 10
             then
              htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                           '&start_from=' || to_char(((x2-11)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
                           '&lt;' || LNG4.AHC_TXT_419 || ' ',ctarget=>cusloc,cattributes=>'CLASS="SMALL"'); -- Previous
            end if;
       end if;
       for j in x2..x1 loop
        if start_from = ((j-1)*numb_photos) + 1
         then
           htp.p( to_char(j) );
           mchar := j;
           if j < x1 then htp.p( ' ' || pfx.page_delim || ' ' ); end if;
         else
           htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                        '&start_from=' || to_char(((j-1)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
                        to_char(j),ctarget=>cusloc,cattributes=>'CLASS="SMALL"');
           if j < x1 then htp.p( ' ' || pfx.page_delim || ' ' ); end if;
        end if;
       end loop;
       if x3 >= 10
        then
           if x2 <= (x3-10)
            then
              htp.anchor2( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                           '&start_from=' || to_char(((x2+11)*numb_photos) + 1) || '&display_detail=' || display_detail || '&acid=' || acid,
                           ' ' || LNG.SLD_TXT_087 || '&gt; ',ctarget=>cusloc,cattributes=>'CLASS="SMALL"'); -- Previous
           end if;
       end if;
      htp.p( '</TD>' );
      htp.p( '<TD ' || pfx.qbground || ' ALIGN="RIGHT" VALIGN="TOP" CLASS="SMALL">');
       htp.p( 'page ' || to_char(mchar) || ' of ' || to_char(x3) );
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
  end if;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'CST', 'DISP_BOTTOM',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'search_total: ' || search_total || ' footer_api:' || footer_api || ' left_api_parm:' || left_api_parm );
end disp_bottom;

procedure pr_disp_nav_bar(surl in varchar2, pfx in THEME%ROWTYPE, acid in number, left_api_parm in varchar2, current_page in integer, total_records in integer, numb_photos in integer, cusloc in varchar2, footer_api in varchar2 )
is

    -- Code extracted from the CAS Package and integrated here
    --

    s_navback_anchor VARCHAR2(200) := '';
    s_navforward_anchor VARCHAR2(200) := '';
    s_navfullback_anchor VARCHAR2(200) := '';
    s_navfullforward_anchor VARCHAR2(200) := '';
    s_navpage_anchor VARCHAR2(200) := '';
    s_obj_purpose_prefix VARCHAR2(10) := '';

    -- Page numbering
    i_starting_page INTEGER := 0;
    i_ending_page INTEGER := 0;
    i_max_page INTEGER := 0;
    i_back_page INTEGER := 0;
    i_forward_page INTEGER := 0;
    i_table_width INTEGER := 0;
    cpage integer;

  begin

    --
    -- Determine "Maximum Page" possible for this query...
    --

    if mod(nvl(total_records,0),nvl(numb_photos,10)) = 0
     then
      i_max_page := trunc(nvl(total_records,0) / nvl(numb_photos,10));
      --i_max_page := nvl(total_records,0);
     else
      i_max_page := trunc(nvl(total_records,0) / nvl(numb_photos,10)) + 1;
      --i_max_page := nvl(total_records,0) + 1;
    end if;

    --
    -- Determine "Starting/Ending Page" to display in NavBar...
    --
    i_starting_page := trunc(trunc((current_page-1) / nvl(numb_photos,10)) + 1,-1) + 1;
    i_ending_page := least(i_max_page, i_starting_page + 9);
    cpage := ((current_page - 1) / nvl(numb_photos,10)) + 1;
    if cpage > 1 then i_back_page := cpage - 1; else i_back_page := 1; end if;
    i_forward_page := cpage;

    htp.nl;
    htp.nl;
    htp.tableopen(cattributes=>'cellpadding=3 cellspacing=3 valign="MIDDLE" ALIGN="CENTER"');

    htp.tablerowopen;

    --
    -- Display the 'Navigate To Start |<' image...
    --
    IF cpage > 1 THEN
      s_navfullback_anchor := footer_api || '?surl=' || glbx.truncsurl(surl) ||
                              '&acid=' || acid ||
                              '&start_from=1' ||
                              '&left_api_parm=' || left_api_parm;
      htp.tabledata(htf.anchor2(replace(s_navfullback_anchor,' ', '+'),
      htf.img( DECS.IMAGE_LOCATION || '/cas/cas_leftmaxarrow.gif', cattributes=>'width=10 border=0'), ctarget=>cusloc),
      cattributes=>'valign="TOP" ALIGN="LEFT"');
    END IF;

    --
    -- Display the 'Navigate Backwards <<' image...
    --
    IF cpage > 1 THEN
      s_navfullback_anchor := footer_api || '?surl=' || glbx.truncsurl(surl) ||
                              '&acid=' || acid ||
                              '&start_from=' || to_char((i_back_page * nvl(numb_photos,10)) + 1) ||
                              '&left_api_parm=' || left_api_parm;
      htp.tabledata(htf.anchor2(replace(s_navfullback_anchor,' ', '+'),
      htf.img( DECS.IMAGE_LOCATION || '/cas/cas_leftarrow.gif', cattributes=>'width=10 border=0'), ctarget=>cusloc),
      cattributes=>'valign="TOP" ALIGN="LEFT"');
    END IF;

    --
    -- Loop thru all available PAGE NUMBERS...
    --
    FOR i_navpage_ctr in i_starting_page..i_ending_page
    LOOP

      IF i_navpage_ctr = cpage THEN
        htp.tabledata(htf.bold(i_navpage_ctr), cattributes=>pfx.qcbground || 'align="CENTER"');
      ELSE
        --
        -- Display the HYPERLINKED PAGE NUMBER...
        --
      s_navfullback_anchor := footer_api || '?surl=' || glbx.truncsurl(surl) ||
                              '&acid=' || acid ||
                              '&start_from=' || to_char(((i_navpage_ctr - 1) * nvl(numb_photos,10)) + 1) ||
                              '&left_api_parm=' || left_api_parm;
        htp.tabledata(htf.anchor2(replace(s_navfullback_anchor,' ', '+'), i_navpage_ctr, ctarget=>cusloc),cattributes=>pfx.qcbground || 'valign="TOP" ALIGN="LEFT"');
      END IF;

    END LOOP;


    --
    -- Display the 'Navigate Forward >>' image... This is the next page
    --
    IF cpage < i_max_page THEN
      s_navfullback_anchor := footer_api || '?surl=' || glbx.truncsurl(surl) ||
                              '&acid=' || acid ||
                              '&start_from=' || to_char((i_forward_page * nvl(numb_photos,10))+1) ||
                              '&left_api_parm=' || left_api_parm;
      htp.tabledata(htf.anchor2(replace(s_navfullback_anchor,' ', '+'),htf.img( DECS.IMAGE_LOCATION || '/cas/cas_rightarrow.gif', cattributes=>'width="10" border=0'), ctarget=>cusloc),cattributes=>'valign="TOP" ALIGN="LEFT"');
    END IF;


    --
    -- Display the 'Navigate To End >|' image...
    --
    IF cpage < i_max_page THEN
      s_navfullback_anchor := footer_api || '?surl=' || glbx.truncsurl(surl) ||
                              '&acid=' || acid ||
                              '&start_from=' || to_char(((i_max_page-1) * nvl(numb_photos,10))+1) ||
                              '&left_api_parm=' || left_api_parm;
      htp.tabledata(htf.anchor2(replace(s_navfullback_anchor,' ', '+'),htf.img( DECS.IMAGE_LOCATION || '/cas/cas_rightmaxarrow.gif', cattributes=>'width="10" border=0'), ctarget=>cusloc),cattributes=>'valign="TOP" ALIGN="LEFT"');
    END IF;

    htp.tablerowclose;

    htp.tableclose;

exception
    when no_data_found then null;
    when others then
     glbx.error_details( 'CST', 'PR_DISP_NAV_BAR',null,acid,errmsg=>sqlerrm );

end pr_disp_nav_bar;

procedure accept_display( surl varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, pa in GLBX.MYARRAY, pb in GLBX.MYARRAY, pc in GLBX.MYARRAY, ppn in GLBX.MYARRAY,
                          left_api_parm in varchar2 default null, footer_api in varchar2, current_page_number in varchar2 default 1, display_detail in char  DEFAULT null,
                          add_to_trolley in varchar2 default null, display in varchar2 default null, modify_details in varchar2 default null, add_lightbox in varchar2 default null, del_lightbox in varchar2 default null, empty_lightbox in varchar2 default null, acid in integer default null, lboxid in integer default null )
as

 cursor c6(v_umo integer) is select umo_scene_id,um.extras.photo_name photo_name from umo um where umo_id = v_umo;
 cursor c15( v_umo integer) is select umo_type from umo where umo_id = v_umo;
 cursor c16(sess_id integer) is select max(order_by) from lightbox where sessid = sess_id;
 cursor c17(acid integer, ltype varchar2) is select lightid from lightbox_header where aid = acid and login_type = ltype and is_default = 'T';

 voidrec	order_style%ROWTYPE;
 c1rec		customer_account%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c15rec		c15%ROWTYPE;

 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 sts		varchar2(100);
 profid		integer;
 tmp		varchar2(4000);
 maxctr		integer;
 vlboxid	integer;
 typ		varchar2(30);
 photo_name	varchar2(100);
 theme_rec 	theme_types%ROWTYPE;
 pfx		THEME%ROWTYPE;
 parm1		ump.parameters;
 parm2		ump.parameters;
 retval		varchar2(4000);
 cusloc		varchar2(100);
 quick_exit	boolean;
 b2c_value	char(1);
 dummy		GLBX.MYARRAY;

 function indx( v_umo integer, pc in GLBX.MYARRAY )
  return integer
 as
 begin
  for j in pc.first..pc.last loop
   if substr(substr(pc(j),2,instr(pc(j),']')-2),2) = to_char(v_umo)
    then
     return( j );
   end if;
  end loop;
  return( NULL );
 end indx;

begin
 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'CST.ACCEPT_DISPLAY' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if Add_To_Trolley is not null
  then
   typ := 'Order Photos';
  elsif display is not null
   then
    typ := 'Display Photos';
  elsif modify_details is not null
   then
    typ := 'Modify Photo Details';
  elsif add_lightbox is not null
   then
    typ := 'Lightbox';
  elsif del_lightbox is not null
   then
    typ := 'Delete Lightbox';
  elsif empty_lightbox is not null
   then
    typ := 'Empty Lightbox';
 end if;

 c1rec := glbx.get_cusrec( sess_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );

 if pfx.keep_lhf = 'L'
  then
   if ltype = 'PHOTOGRAPHER'
    then
     cusloc := 'PHG_RIGHT';
    else
     cusloc := 'CUS_RIGHT';
   end if;
  else
   if ltype = 'PHOTOGRAPHER'
    then
     cusloc := 'PHG_RIGHT';
    else
     if pfx.keep_lhf = 'N'
      then
       cusloc := '_top';
      else
       cusloc := 'CUS_RIGHT';
     end if;
   end if;
 end if;

 if p1.count = 1 and typ not in ('Modify Photo Details','Empty Lightbox')
  then
   glbx.main_title( surl, null,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.header(3,lng.CST_TXT_056,'CENTER');
   htp.header(4, lng.CST_TXT_057,'CENTER');
   htp.nl;
   htp.bold( '<CENTER><FORM><INPUT TYPE="button" VALUE="' || lng.CST_TXT_058 || '" OnClick="history.go(-1)"></FORM></CENTER>'); htp.nl;
   glbx.close_page( pfx );
   return;
 end if;

 if typ = 'Order Photos'
  then
   quick_exit := FALSE;
   voidrec := glbx.get_order_style( glbx.get_order_style( c1rec.aid, profid, ltype, b2c_value ));
   -- Update the Shopping Basket
   -- DUMMY - Shopping Id
   -- P1 - New Choice (PPIT Id or UMO_ID)
   -- DUMMY - Quantity (defaults to min_qty or 1)
   -- PC - Before Choice Value (PPIT Id or UMO_ID) same as P1, except it contains all values on the screen or
   --    - [F24590]2839 if customer can prechoose price book item
   fname.process_purchase_order(surl, sess_id, profid, ltype, acid, 'INSERT', voidrec, c1rec, p1, dummy, pc, dummy, quick_exit );
   if quick_exit then return; end if;

   commit;
   if voidrec.disp_goto_order_pge = 'T' or
     (footer_api is null or footer_api = 'SLIDESHOW_CATEGORY' or footer_api = 'QUICKBUY')
    then
     fname.acct_orders(surl,acid=>acid, footer_api=>footer_api,left_api_parm=>left_api_parm);

    else
     execute immediate
      'begin ' || footer_api ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
      'end;'
      using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
   end if;

 elsif typ = 'Lightbox'
  then
   open c16(sess_id);
   fetch c16 into maxctr;
   close c16;
   if add_lightbox is not null
    then
     if ltype = 'PHOTOGRAPHER'
      then
       if lboxid is null
        then
         open c17(c1rec.aid,ltype);
         fetch c17 into vlboxid;
         close c17;
        else
         vlboxid := lboxid;
       end if;
     elsif ltype = 'OWNER'
      then
       if lboxid is null
        then
         open c17(c1rec.aid,ltype);
         fetch c17 into vlboxid;
         close c17;
        else
         vlboxid := lboxid;
       end if;
     elsif ltype = 'PROFILE'
      then
       if lboxid is null
        then
         open c17(profid,ltype);
         fetch c17 into vlboxid;
         close c17;
        else
         vlboxid := lboxid;
       end if;
     end if;
   else
    vlboxid := NULL;
   end if;

   maxctr := nvl(maxctr,0) + 1;
   for j in (p1.first+1)..p1.last loop
    if substr(p1(j),1,1) = 'S'
     then
      null;
     else
      if vlboxid is null
       then
        insert into lightbox(sessid,umo_id,order_by)
         select sess_id,p1(j),maxctr
         from dual
         where not exists( select 'x' from lightbox where sessid = sess_id and umo_id = to_number(p1(j)));
       else
        insert into lightbox(sessid,umo_id,order_by,lightid)
         select sess_id,p1(j),maxctr,vlboxid
         from dual
         where not exists( select 'x' from lightbox where sessid = sess_id and umo_id = to_number(p1(j)) and lightid = vlboxid);
      end if;
      maxctr := maxctr + 1;
    end if;
   end loop;
   commit;

   -- Return back to Category Listing or go to the Lightbox
   if glbx.userpref(c1rec.pid,c1rec.aid,'RET_ORIG') = LNG.PHG_TXT_046
    then
     if vlboxid is null
      then
       execute immediate
        'begin ' || 'cst.disp_lightbox' ||
         '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
       'end;'
        using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
     else
       execute immediate
        'begin ' || 'cst.disp_lightbox' ||
         '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
       'end;'
        using glbx.rndsurl(surl),'[LBOX:' || vlboxid,current_page_number,display_detail,acid;
    end if;
    else
     execute immediate
      'begin ' || footer_api ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
      'end;'
      using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
   end if;
   return;

 elsif typ = 'Delete Lightbox'
  then
   for j in (p1.first+1)..p1.last loop
    if substr(p1(j),1,1) = 'S'
     then
      null;
     else
      delete from lightbox where sessid = sess_id and umo_id = to_number(p1(j));
    end if;
   end loop;
   commit;
     execute immediate
      'begin ' || 'cst.disp_lightbox' ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
      'end;'
      using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
   return;

 elsif typ = 'Empty Lightbox'
  then
   delete from lightbox where sessid = sess_id;
   commit;
     execute immediate
      'begin ' || 'cst.disp_lightbox' ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
      'end;'
      using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
   return;

 elsif typ = 'Display Photos'
  then
   glbx.main_title( surl, lng.CST_TXT_059,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C08',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.formopen( 'cst.accept_display', ctarget=>cusloc );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'DISPLAY_DETAIL', display_detail);
   htp.formhidden('ADD_TO_TROLLEY','Order Photos');
   htp.formhidden('P0','0');
   htp.formhidden('P1','0');
   htp.formhidden('PA','0');
   htp.formhidden('PB','0');
   htp.formhidden('PC','0');
   htp.formhidden('PPN','0');
   htp.formhidden('FOOTER_API', footer_api );
   htp.formhidden('ACID', acid );
   htp.formhidden('CURRENT_PAGE_NUMBER', current_page_number );
   if (substr(theme_rec.theme_data,29,1) = 'T' and ltype in ('OWNER','PROFILE')) or (substr(theme_rec.theme_data,41,1) = 'T' and ltype in ('CUSTOMER','PROFILEG'))
    then
     htp.formsubmit( null, lng.CST_TXT_064 );
   end if;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=10' );
   htp.tablerowopen;
   for j in (p1.first+1)..p1.last loop
    open c6(p1(j));
    fetch c6 into c6rec;
    close c6;

      photo_name := c6rec.photo_name;
      if mod(j,2) = 1
       then
         if ltype = 'PHOTOGRAPHER'
          then
           htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || p1(j) || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || acid,
                          '<IMG BORDER=0 WIDTH=' || trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype)*0.5) || ' SRC="' ||
                          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || p1(j) || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                          '" ALT="' || photo_name || '" STYLE="display:block;">',ctarget=>'NEW_WINDOW' ));
          else
           htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || p1(j) || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype ,
                          '<IMG BORDER=0 WIDTH=' || trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype)*0.5) || ' SRC="' ||
                          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || p1(j) || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                          '" ALT="' || photo_name || '" STYLE="display:block;">',ctarget=>'NEW_WINDOW' ));
         end if;
      end if;
      if mod(j,2) = 0
       then
        htp.p( '<TD BGCOLOR="#' || pfx.vert_colour_a || '">' );
        else
        htp.p( '<TD BGCOLOR="#' || pfx.vert_colour_b || '">' );
      end if;
      htp.bold( htf.italic(photo_name ));
      htp.nl;
      htp.nl;
      /*
      if is_bf(theme_rec,ltype,36,48,'T','T',276,'T') and is_bf(theme_rec,ltype,162,163,'F','F',275,'T')
	 then
          htp.anchor('cst.add_name?surl=' || glbx.rndsurl(surl) || '&photo_id=' || p1(j) || '&stp=BP' || '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,lng.CST_TXT_061 );
	  htp.nl;
      end if;

      if is_bf(theme_rec,ltype,35,47,'T','T',277,'T') and is_bf(theme_rec,ltype,162,163,'F','F',275,'T')
	 then
          htp.anchor('cst.add_comment?surl=' || glbx.rndsurl(surl) || '&photo_id=' || p1(j) || '&stp=BP' || '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,lng.CST_TXT_055);
          htp.nl;
      end if;
      */
      htp.nl;
      if is_bf(theme_rec,ltype,205,206,'T','T',267,'T')
       then
        htp.formcheckbox( 'P1', p1(j));
      end if;
      htp.bold( lng.CST_TXT_065 );
      htp.nl;
      htp.p( '</TD>' );
      if mod(j,2) = 0
       then
         if ltype = 'PHOTOGRAPHER'
          then
           htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || p1(j) || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || acid,
                          '<IMG BORDER=0 WIDTH=' || trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype)*0.5) || ' SRC="' ||
                          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || p1(j) || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                          '" ALT="' || photo_name || '" STYLE="display:block;">',ctarget=>'NEW_WINDOW' ));
          else
           htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || p1(j) || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype ,
                          '<IMG BORDER=0 WIDTH=' || trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype)*0.5) || ' SRC="' ||
                          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || p1(j) || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                          '" ALT="' || photo_name || '" STYLE="display:block;">',ctarget=>'NEW_WINDOW' ));
         end if;
      end if;
      if mod(j,2) = 1
       then
        htp.tablerowclose;
        htp.tablerowopen;
      end if;
   end loop;
   htp.tablerowclose;
   htp.tableclose;
   tmp := htf.formopen( footer_api, ctarget=>cusloc ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'DISPLAY_DETAIL', display_detail ) || htf.formhidden( 'ACID', acid );
   tmp := tmp || htf.formhidden( 'LEFT_API_PARM', c6rec.umo_scene_id );
   tmp := tmp || htf.formhidden( 'START_FROM', current_page_number );
   tmp := tmp || htf.formsubmit( null, lng.CST_TXT_063 );
   tmp := tmp || htf.formclose;
   htp.tableopen;
    htp.tablerowopen;
     if is_bf(theme_rec,ltype,205,206,'T','T',267,'T')
      then
       htp.tabledata( htf.formsubmit( null, lng.CST_TXT_064 ) || htf.formclose);
      else
       htp.formclose;
     end if;
     htp.tabledata( tmp );
    htp.tablerowclose;
   htp.tableclose;
   glbx.close_page( pfx );

 elsif typ = 'Modify Photo Details'
  then
   for j in p0.first..p0.last loop
    htp.p( 'P0:' || p0(j)); htp.nl;
    if p0(j) <> '0'
     then
       c15rec.umo_type := NULL;
       open c15(p0(j));
       fetch c15 into c15rec;
       if c15%FOUND and c15rec.umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT')
        then
         close c15;
         parm1.delete;
         parm2.delete;
         parm1(1) := 'UMO_ID';
         parm2(1) := p0(j);
         parm1(2) := 'AID';
         parm2(2) := c1rec.aid;
         parm1(3) := 'OBJECT_TYPE';
         parm2(3) := c15rec.umo_type;
         parm1(4) := 'CHECK_EXISTS';
         parm2(4) := 'FALSE';
         parm1(5) := 'PHOTO ALBUM';
         parm2(5) := 'FALSE';
         if ltype = 'PHOTOGRAPHER'
          then
           parm1(6) := 'PHOTOGRAPHER';
          else
           parm1(6) := 'BRIDAL';
         end if;
         parm2(6) := 'FALSE';
         -- Image Name can be edited of Detail or Summary Display
         if (display_detail = 'T' and is_bf(theme_rec,ltype,8,214,'T','T',272,'T')) or
            (display_detail = 'F' and is_bf(theme_rec,ltype,229,230,'T','T',290,'T'))
          then
           if ltype = 'PHOTOGRAPHER'
            then
             parm1(7) := 'FILM_NAME';
            else
             parm1(7) := 'NAME';
           end if;
           parm2(7) := ppn(j);
         end if;
         ump.modify_uma(surl,parm1,parm2,retval);
        else
         close c15;
       end if;
    end if;
   end loop;
   for j in pa.first..pa.last loop
    if pa(j) <> '0'
     then
       open c15(pa(j));
       fetch c15 into c15rec;
       if c15%FOUND
        then
         close c15;
         parm1.delete;
         parm2.delete;
         parm1(1) := 'UMO_ID';
         parm2(1) := pa(j);
         parm1(2) := 'AID';
         parm2(2) := c1rec.aid;
         parm1(3) := 'OBJECT_TYPE';
         parm2(3) := c15rec.umo_type;
         parm1(4) := 'CHECK_EXISTS';
         parm2(4) := 'FALSE';
         parm1(5) := 'PHOTO ALBUM';
         parm2(5) := 'TRUE';
         ump.modify_uma(surl,parm1,parm2,retval);
        else
         close c15;
       end if;
     --  else
	--  null;
    -- end if;
   end if;
   end loop;
   for j in pb.first..pb.last loop
    if pb(j) <> '0'
     then
       open c15(pb(j));
       fetch c15 into c15rec;
       if c15%FOUND
        then
         close c15;
         parm1.delete;
         parm2.delete;
         parm1(1) := 'UMO_ID';
         parm2(1) := pb(j);
         parm1(2) := 'AID';
         parm2(2) := c1rec.aid;
         parm1(3) := 'OBJECT_TYPE';
         parm2(3) := c15rec.umo_type;
         parm1(4) := 'CHECK_EXISTS';
         parm2(4) := 'FALSE';
         if ltype = 'PHOTOGRAPHER'
          then
           parm1(5) := 'PHOTOGRAPHER';
          else
           parm1(5) := 'BRIDAL';
         end if;
         parm2(5) := 'TRUE';
         ump.modify_uma(surl,parm1,parm2,retval);
        else
         close c15;
       end if;
    end if;
   end loop;
   commit;

   execute immediate
      'begin ' || footer_api ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
      'end;'
      using glbx.rndsurl(surl),left_api_parm,current_page_number,display_detail,acid;
 end if;

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_DISPLAY',errmsg=>sqlerrm,extdet=>'SESS_ID:' || sess_id);
end accept_display;

procedure disp_acct_photo( surl varchar2, photo_id in integer, msg in varchar2 default null, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer default null, how_display in varchar2 default 'TRADITIONAL', extra_term in varchar2 default null )
as

 cursor c2(acid integer,utype varchar2,photo_id integer) is
  select *
  from umo um
  where um.aid = acid and
        um.umo_id = photo_id and
        um.umo_type in ('PHOTO','DOCUMENT','AUDIO','VIDEO','BLUEPRINT','RELATIONAL') and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'));

 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vkeep_lhf	char(1);
 b2c_value	char(1);
 hght		integer;
 usemap		varchar2(100);
 tmp		varchar2(2000);
 foundrec	boolean;
 dspv		integer;
 oth		integer;
 profid		integer;
 photo_name	varchar2(100);
 tmpx		varchar2(1000);
 at_date	date;
 adj		integer;
 dbool		boolean;
 jscript	varchar2(1000);
 jscript_close	varchar2(1000);
 dmy		GLBX.MYARRAY;
 tag_name	GLBX.MYARRAY;
 tag_title	GLBX.MYARRAY;
 empty_array	GLBX.MYARRAY;
 img_to_disp	ordsys.ordimage;
 imgdisp	varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.DISP_ACCT_PHOTO' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 /*
 if ltype = 'PHOTOGRAPHER'
  then
   phg.phg_modify( surl, acid, photo_id, dmy, footer_api, left_api_parm, current_page_number, display_detail );
   return;
 end if;
 */

 -- c1rec := glbx.get_aid( owner_id, 'S', ltype );
 -- pfx := glbx.get_thm( c1rec.theme_name );
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( c1rec.aid, profid, ltype, b2c_value ));

 if pfx.main_image_api_call is not null
  then
     execute immediate
       'begin ' ||
       pfx.main_image_api_call ||
       '(surl=>:surl,acid=>:acid,v_umo=>:v_umo,footer_api=>:footer_api,left_api_parm=>:left_api_parm,current_page_number=>:current_page_number); end;'
       using surl,acid,photo_id,footer_api,left_api_parm,current_page_number;
     return;
 end if;

 if pfx.fullimg_jscript_popup = 'T'
  then
   jscript := 'javascript: parent.opener.location = ''';
   jscript_close := '''; parent.close();';
 end if;

 open c2(c1rec.aid,ltype,photo_id);
 fetch c2 into c2rec;
 close c2;

 photo_name := c2rec.extras.photo_name;
 if how_display = 'TEMPLATE'
  then
   tag_name(1) := '<PICTION_IMAGE_CELL>';
   tag_title(1) := main_image(surl, stype, ltype, acid, c2rec, c1rec, pfx, theme_rec, usemap, photo_name, 'CELL', footer_api, left_api_parm, current_page_number, display_detail, voidrec);
   tag_name(2) := '<PICTION_IMAGE>';
   tag_title(2) := main_image(surl, stype, ltype, acid, c2rec, c1rec, pfx, theme_rec, usemap, photo_name,'IMAGE', footer_api, left_api_parm, current_page_number, display_detail, voidrec);
   tag_name(3) := '<PICTION_IMAGE_SOURCE>';
   tag_title(3) := main_image(surl, stype, ltype, acid, c2rec, c1rec, pfx, theme_rec, usemap, photo_name,'SOURCE', footer_api, left_api_parm, current_page_number, display_detail, voidrec);
   tag_name(4) := '<PICTION_IMAGE_NAME>';
   tmpx := main_image(surl, stype, ltype, acid, c2rec, c1rec, pfx, theme_rec, usemap, photo_name,'NAME', footer_api, left_api_parm, current_page_number, display_detail, voidrec);
   if instr(tmpx,'.') > 0 then tmpx := substr(tmpx,1,instr(tmpx,'.')-1); end if;
   tag_title(4) := tmpx;
   tag_name(5) := '<SURL>';
   tag_title(5) := surl;
   tag_name(6) := '<LTYPE>';
   tag_title(6) := ltype;
   tag_name(7) := '<ACID>';
   tag_title(7) := acid;
   tag_name(8) := '<STYPE>';
   tag_title(8) := stype;
   tag_name(9) := '<PICTION_BUTTONS1>';
   tag_title(9) := substr(main_image(surl, stype, ltype, acid, c2rec, c1rec, pfx, theme_rec, usemap, photo_name,'BUTTON', footer_api, left_api_parm, current_page_number, display_detail, voidrec),1,4000);
   tag_name(10) := '<PICTION_BUTTONS2>';
   tag_title(10) := substr(main_image(surl, stype, ltype, acid, c2rec, c1rec, pfx, theme_rec, usemap, photo_name,'BUTTON', footer_api, left_api_parm, current_page_number, display_detail, voidrec),4001,4000);
   tag_name(11) := '<UMO_ID>';
   tag_title(11) := photo_id;
   tag_name(12) := '<LEFT_API_PARM>';
   tag_title(12) := replace(left_api_parm,' ','+');
   tag_name(13) := '<FOOTER_API>';
   tag_title(13) := replace(footer_api,' ','+');
   tag_name(14) := '<BACKGROUND_IMAGE>';
   tag_title(14) := glbx.backimg(surl,c1rec.aid,pfx.fullimg_back,c1rec.background_img,ltype);
   tag_name(15) := '<IMAGE_BORDER_COLOUR>';
   tag_title(15) := '#' || pfx.tnail_matte_colour;
   tag_name(16) := '<IMAGE_BORDER>';
   tag_title(16) := pfx.tnail_border ;
   tag_name(17) := '<IMAGE_STYLE>';
   tag_title(17) := pfx.matte_border_style ;
   tag_name(18) := '<PICTION_IMAGE_NAME_FULL>';
   tag_title(18) := main_image(surl, stype, ltype, acid, c2rec, c1rec, pfx, theme_rec, usemap, photo_name,'NAME', footer_api, left_api_parm, current_page_number, display_detail, voidrec);
   glbx.external_html_file( surl, c1rec, 'MAIN_IMAGE', tag_name, tag_title );
   return;
 end if;

 -- If No Frame and Pop-up window then do not display the header
 if pfx.fullimg_jscript_popup = 'T' and pfx.keep_lhf = 'N'
  then
   vkeep_lhf := 'L';
  else
   vkeep_lhf := pfx.keep_lhf;
 end if;

 if pfx.fullimg_title_style = 'M'
  then
   glbx.main_title( surl, photo_name, glbx.backimg(surl,c1rec.aid,pfx.fullimg_back,c1rec.background_img,ltype), helpid=>'C09',stype=>stype,sstyle=>pfx.fullimg_text_font,sclr=>pfx.fullimg_text_colour, det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour, det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript,  disptop=>vkeep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,  errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font,  instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font, ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  else
   glbx.main_title( surl, null, glbx.backimg(surl,c1rec.aid,pfx.fullimg_back,c1rec.background_img,ltype), helpid=>'C09',stype=>stype,sstyle=>pfx.fullimg_text_font,sclr=>pfx.fullimg_text_colour, det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour, det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript,  disptop=>vkeep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,  errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font,  instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font, ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;

 if pfx.fullimg_jscript_popup = 'T'
  then
   htp.title( photo_name );
 end if;
 if msg is not null
  then
   glbx.header_msg( msg );
   htp.nl;
 end if;
 if c2rec.umo_id is null then htp.bold( 'Unable to find Image-' || c1rec.aid || '-' || ltype || '-' || photo_id ); return; end if;

 htp.p( '<CENTER>' );

 image_object( surl, ltype, c1rec, c2rec, pfx, theme_rec, voidrec, footer_api, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(c1rec.pid,c1rec.aid,'DISPLAY_ORIGINAL'), stype );

 htp.tableopen(cattributes=>'style="text-align: center;"');
 htp.tablerowopen;

 if dbms_lob.getlength(c2rec.photo_master.source.localdata) > 0
  then
    img_to_disp := c2rec.photo_master;
  else
    img_to_disp := c2rec.photo_thumbnail;
 end if;

 htp.p( '<td style="text-align: center;">' );
 htp.tableopen( cattributes=>'style="text-align: center;" cellpadding=0 cellspacing=0 bordercolordark="#' || pfx.tnail_border_colour || '" bordercolorlight="#' || pfx.tnail_border_colour_l || '" border=' || to_char(nvl(pfx.tnail_border,0)) );
 htp.tablerowopen;
 imgdisp := get_image_style( owner_id );
 if img_to_disp.width > img_to_disp.height
  then
   -- If Zoom disabled do not anchor the image
   if glbx.userpref(c1rec.pid,c1rec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
    then
     dspv := img_to_disp.width;
     oth := img_to_disp.height;
     adj := 1;
    else
     dspv := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
     oth := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / img_to_disp.width) * img_to_disp.height;
     adj := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / img_to_disp.width);
   end if;
   if is_bf(theme_rec,ltype,408,408,'T','T') then usemap := glbx.embed_image_map( surl, photo_id, adj, acid ); end if;
   if is_bf(theme_rec,ltype,160,161,'T','T') and not (substr(c1rec.zoom_factor,1,9) = 'FFFFFFFFF')
    then
     htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || c1rec.aid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version,
                    '<IMG BORDER=0 WIDTH=' || to_char(dspv) || usemap || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || c1rec.aid || '&parm1=VERSION&parm2=' || c2rec.version ||
                    '" ALT="' || photo_name || '" ' || imgdisp || '>',ctarget=>'NEW_WINDOW' ), cattributes=>'style="text-align: center;" align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' );
    else
     htp.tabledata( '<IMG BORDER=0 WIDTH=' || to_char(dspv) || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || c1rec.aid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version ||
                    '" ALT="' || photo_name || '" ' || imgdisp || '">',cattributes=>'style="text-align: center;" align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' );
   end if;

  else

   if glbx.userpref(c1rec.pid,c1rec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
    then
     dspv := img_to_disp.height;
     oth := img_to_disp.width;
     adj := 1;
    else
     dspv := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
     oth := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / img_to_disp.height ) * img_to_disp.width;
     adj := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / img_to_disp.height);
   end if;
   if is_bf(theme_rec,ltype,408,408,'T','T') then usemap := glbx.embed_image_map( surl, photo_id, adj, acid ); end if;
   if is_bf(theme_rec,ltype,160,161,'T','T') and not (substr(c1rec.zoom_factor,1,9) = 'FFFFFFFFF')
    then
      htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version,
                     '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || usemap || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version ||
                     '" ALT="' || photo_name || '" ' || imgdisp || '">',ctarget=>'NEW_WINDOW' ), cattributes=>'style="text-align: center;" align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '"' );
    else
      htp.tabledata( '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version ||
                     '" ALT="' || photo_name || '" ' || imgdisp || '">', cattributes=>'style="text-align: center;" align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '"' );
   end if;
 end if;

 htp.tablerowclose;
 htp.tableclose;
 if pfx.fullimg_title_style = 'B'
  then
   htp.bold( photo_name );
 end if;
 htp.p( '</td>' );

 if how_display = 'VERTICAL'
  then
   htp.tablerowclose;
   htp.tablerowopen;
 end if;

 htp.p( '<td valign="TOP">' );

 -- Display Caption
 if is_bf(theme_rec,ltype,255,256,'T','T') and c2rec.image_caption is not null
  then
     htp.nl;
     htp.tableopen( cattributes=>pfx.vertical_disp_table );
      htp.tablerowopen;
       htp.tabledata(c2rec.image_caption, cattributes=>'valign="TOP" align="LEFT" STYLE="font-family: ' || pfx.caption_text_font || '; color: #' || pfx.caption_text_colour || '"');
      htp.tablerowclose;
     htp.tableclose;
 end if;

 -- Display Meta Tags
 if is_bf(theme_rec,ltype,257,258,'T','T')
  then
     htp.nl;
     dbool := glbx.disp_mt( surl, ltype, c2rec.umo_id, c2rec.umo_type, substr(theme_rec.theme_data,167,1), pfx, acid, empty_array );
 end if;

 if c2rec.audio_original.description is not null
  then
   htp.nl;
   htp.tableopen( cattributes=>'BORDER=0');
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNG.CST_TXT_207) );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOWX&parm1=DISPLAY_WHAT&parm2=ORIGINAL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=OVERRIDE&parm2=AUDIO',
	                        htf.img( DECS.IMAGE_LOCATION || 'adminc/audio.gif',cattributes=>'border=0',calt=>lng.CST_ALT_086 ),ctarget=>'AUDIO_WINDOW'),cattributes=>pfx.qcbground);
    htp.tablerowclose;
   htp.tableclose;
 end if;

 htp.p( '</td>' );
 htp.tablerowclose;
 htp.tableclose;

 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'DISP_ACCT_PHOTO',c1rec.pid,c1rec.aid,photo_id,errmsg=>sqlerrm);
end disp_acct_photo;

procedure load_img(surl varchar2, typ in varchar2 default 'PHOTO')
as

 cursor c2a(acid integer, sess_id integer) is
   select umo_type,nvl(sum(um.photo_master.contentlength),0) sf,nvl(count(um.photo_master.contentlength),0) cf
   from umo um
   where aid = acid and
         sessid = sess_id and
         umo_type = 'PHOTO'
   group by umo_type;

 cursor c2b(acid integer, sess_id integer) is
   select umo_type,nvl(sum(to_number(um.audio_original.description)),0) sf,nvl(count(um.audio_original.description),0) cf
   from umo um
   where aid = acid and
         sessid = sess_id and
         umo_type = 'AUDIO'
   group by umo_type;

 cursor c2c(acid integer, sess_id integer) is
   select umo_type,nvl(sum(to_number(um.video_original.description)),0) sf,nvl(count(um.video_original.description),0) cf
   from umo um
   where aid = acid and
         sessid = sess_id and
         umo_type = 'VIDEO'
   group by umo_type;

 cursor c2d(acid integer, sess_id integer) is
   select umo_type,nvl(sum(um.doc_length),0) sf,nvl(count(um.doc_length),0) cf
   from umo um
   where aid = acid and
         sessid = sess_id and
         umo_type = 'DOCUMENT'
   group by umo_type;

 cursor c2e(acid integer, sess_id integer) is
   select umo_type,0 sf,nvl(count('x'),0) cf
   from umo um
   where aid = acid and
         sessid = sess_id and
         umo_type = 'RELATIONAL'
   group by umo_type;

 cursor c2f(acid integer, sess_id integer) is
   select umo_type,nvl(sum(um.blueprint_obj.blueprint_length),0) sf,nvl(count(um.blueprint_obj.blueprint_length),0) cf
   from umo um
   where aid = acid and
         sessid = sess_id and
         umo_type = 'BLUEPRINT'
   group by umo_type;

 cursor c3(v_category varchar2, v_owner_id integer) is
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

 cursor c4(phgid integer) is select object_access from photographer where pid = phgid;
 cursor c6(acid integer, trg char) is select count('x') tot from customer_meta_data_group where aid = acid and target_area = trg;
 cursor c7(sess_id integer) is select application_parameters from login_session where sessid = sess_id;

 c1rec		customer_account%ROWTYPE;
 c2arec		c2a%ROWTYPE;
 c2brec		c2b%ROWTYPE;
 c2crec		c2c%ROWTYPE;
 c2drec		c2d%ROWTYPE;
 c2erec		c2e%ROWTYPE;
 c2frec		c2f%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 hlp		varchar2(4000);
 tmp		varchar2(32767);
 vtg		integer;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.LOAD_IMG' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, null, profid );
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 hlp := glbx.userpref( c1rec.pid, c1rec.aid, 'HELP_UPLOAD' );
 open c4(c1rec.pid);
 fetch c4 into c4rec;
 close c4;
 open c7(owner_id);
 fetch c7 into c7rec;
 close c7;
 vtg := glbx.guess_number(c7rec.application_parameters);

 glbx.main_title( surl, LNG.CST_TXT_208,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'C13',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );

  -- Does a Specialised Meta Data Upload Screen Exist?
  open c6(c1rec.aid, 'C');
  fetch c6 into c6rec;
  close c6;
  if c6rec.tot > 0
   then
    phg.meta_img_load( surl, c1rec.aid, stype, ltype, c1rec, pfx, theme_rec, 'C' );
    return;
  end if;

 if hlp is not null
  then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=1' );
    htp.tablerowopen;
    htp.p( '<TD>' );
     glbx.instruction( hlp, pfx );
    htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tableclose;
    htp.nl;
  else
   htp.nl;
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.CST_TXT_042),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_211),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( htf.bold( LNG.CST_TXT_212),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
   htp.tablerowclose;

   if substr(c4rec.object_access,1,1) = 'T'
    then
     open c2a(c1rec.aid,owner_id);
     fetch c2a into c2arec;
     close c2a;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG4.AHC_TXT_470 ),cattributes=>pfx.qcbground);
      htp.tabledata( to_char(nvl(round(c2arec.sf/1024),0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
      htp.tabledata( to_char(nvl(c2arec.cf,0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
     htp.tablerowclose;
   end if;

   if substr(c4rec.object_access,2,1) = 'T'
    then
     open c2d(c1rec.aid,owner_id);
     fetch c2d into c2drec;
     close c2d;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.CST_TXT_216 ),cattributes=>pfx.qcbground);
      htp.tabledata( to_char(nvl(round(c2drec.sf/1024),0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
      htp.tabledata( to_char(nvl(c2drec.cf,0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
     htp.tablerowclose;
   end if;


   if substr(c4rec.object_access,3,1) = 'T'
    then
     open c2b(c1rec.aid,owner_id);
     fetch c2b into c2brec;
     close c2b;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.GLB_TXT_065 ),cattributes=>pfx.qcbground);
      htp.tabledata( to_char(nvl(round(c2brec.sf/1024),0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
      htp.tabledata( to_char(nvl(c2brec.cf,0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
     htp.tablerowclose;
   end if;

   if substr(c4rec.object_access,4,1) = 'T'
    then
     open c2c(c1rec.aid,owner_id);
     fetch c2c into c2crec;
     close c2c;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG.CST_TXT_215 ),cattributes=>pfx.qcbground);
      htp.tabledata( to_char(nvl(round(c2crec.sf/1024),0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
      htp.tabledata( to_char(nvl(c2crec.cf,0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
    htp.tablerowclose;
  end if;

   if substr(c4rec.object_access,5,1) = 'T'
    then
     open c2e(c1rec.aid,owner_id);
     fetch c2e into c2erec;
     close c2e;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG4.AHC_TXT_469 ),cattributes=>pfx.qcbground);
      htp.tabledata( to_char(nvl(round(c2erec.sf/1024),0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
      htp.tabledata( to_char(nvl(c2erec.cf,0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
    htp.tablerowclose;
  end if;

   if substr(c4rec.object_access,6,1) = 'T'
    then
     open c2f(c1rec.aid,owner_id);
     fetch c2f into c2frec;
     close c2f;
     htp.tablerowopen;
      htp.tabledata( htf.bold( LNG4.AHC_TXT_468 ),cattributes=>pfx.qcbground);
      htp.tabledata( to_char(nvl(round(c2frec.sf/1024),0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
      htp.tabledata( to_char(nvl(c2frec.cf,0)),cattributes=>pfx.qcbground || ' ALIGN="RIGHT"' );
    htp.tablerowclose;
  end if;

  htp.tableclose;

 htp.formopen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'cst.tload', cattributes=>'enctype="multipart/form-data"' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  --htp.formhidden( 'TYP', typ );

 if vtg is null
  then
   tmp := htf.formselectopen( 'SCNM' );
   for c3rec in c3(c1rec.scene_name,c1rec.pid) loop
     tmp := tmp || htf.formselectoption( lpad('.', indnt(c3rec.parent_scene),'.') || c3rec.title, cattributes=>'VALUE="' || c3rec.umo_scene_id || '"' );
   end loop;
   tmp := tmp || htf.formselectclose;
   htp.tablerowopen;
    htp.tabledata( LNG.CST_TXT_217 );
    htp.tabledata( tmp );
   htp.tablerowclose;
  else
   htp.formhidden( 'SCNM', vtg );
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  if substr(c4rec.object_access,1,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG4.AHC_TXT_470 ) );
     htp.tabledata( htf.formradio( 'TYP', 'PHOTO', 'CHECKED' ));
    htp.tablerowclose;
  end if;
  if substr(c4rec.object_access,2,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.CST_TXT_216 ) );
     htp.tabledata( htf.formradio( 'TYP', 'DOCUMENT' ));
    htp.tablerowclose;
  end if;
  if substr(c4rec.object_access,3,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.GLB_TXT_065 ) );
     htp.tabledata( htf.formradio( 'TYP', 'AUDIO' ));
    htp.tablerowclose;
  end if;
  if substr(c4rec.object_access,4,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG.CST_TXT_215 ) );
     htp.tabledata( htf.formradio( 'TYP', 'VIDEO' ));
    htp.tablerowclose;
  end if;
  if substr(c4rec.object_access,5,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG4.AHC_TXT_469 ) );
     htp.tabledata( htf.formradio( 'TYP', 'RELATIONAL' ));
    htp.tablerowclose;
  end if;
  if substr(c4rec.object_access,6,1) = 'T'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNG4.AHC_TXT_468 ) );
     htp.tabledata( htf.formradio( 'TYP', 'BLUEPRINT' ));
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.CST_TXT_218),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold(LNG.CST_TXT_219),cattributes=>pfx.qbground );
  htp.tablerowclose;
  for j in 1..5 loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'PNAME', 20, 100 ),cattributes=>pfx.qcbground );
    htp.tabledata( GLBX.UPLOAD_NAME,cattributes=>pfx.qcbground );
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( null, LNG.PHG_TXT_185 );
 htp.formclose;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'CST', 'LOAD_IMG',errmsg=>sqlerrm,extdet=>'TYP:' || typ);
end load_img;

procedure tload(surl varchar2, file in GLBX.MYARRAY, pname in GLBX.MYARRAY, scnm in varchar2, typ in varchar2)
as

 cursor c2(v_umo integer) is select * from umo where umo_id = v_umo;

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(4000);
 last_file	varchar2(1000);
 new_photo	integer;
 ctr1		integer;
 ctr2		integer;
 profid		integer;
 new_photos	UMP.SEARCH_RESULT_PHG;
 newid_arr	ump.myarray_int;
 theme_rec	theme_types%ROWTYPE;
 parm1		ump.parameters;
 parm2		ump.parameters;
 bad_img	glbx.myarray;
 empty_array	GLBX.MYARRAY;
 dummy_array	GLBX.MYARRAY;
 ret_array	GLBX.MYARRAY;
 retval		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.TLOAD' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, null, profid );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 ctr1 := 0;
 ctr2 := 0;
  for j in file.first..file.last loop
  if file(j) is not null
   then
    last_file := file(j);
    parm1.delete;
    parm2.delete;
    parm1(1)  := 'AID';
    parm2(1)  := to_char(c1rec.aid);
    parm1(2)  := 'OBJECT_TYPE';
    parm2(2)  := nvl(typ,'PHOTO');
    parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
    parm2(3)  := 'UPLOAD';
    parm1(4)  := 'FILE_NAME';
    parm2(4)  := file(j);
    parm1(5)  := 'STORE_ORIGINAL';
    parm2(5)  := 'TRUE';
    parm1(6)  := 'CREATE_THUMBNAIL';
    parm2(6)  := 'TRUE';
    parm1(7) := 'KEEP_STATUS';
    parm2(7) := 'KEEP';
    parm1(8) := 'ORIGINAL_LOCATION';
    parm2(8) := file(j);
    parm1(9) := 'PARENT_UMO_ID';
    parm2(9) := NULL;
    parm1(10) := 'SCENE_ID';
    parm2(10) := scnm;
    parm1(11) := 'UMO_OWNER';
    parm2(11) := 'OWNER';
    parm1(12) := 'BYPASS_QUOTA_CHECK';
    parm2(12) := 'FALSE';
    parm1(13) := 'PHGR_ID';
    parm2(13) := to_char(c1rec.pid);
    parm1(14) := 'OWS_NAME';
    parm2(14) := file(j);
    parm1(15) := 'THUMBNAIL_WIDTH';
    parm2(15) := nvl(glbx.photo_pref(c1rec.pid,c1rec.aid,'THUMBNAIL_WIDTH'),'100');
    parm1(16) := 'PHOTOGRAPHER';
    parm2(16) := 'TRUE';
    parm1(17) := 'NAME';
    parm2(17) := nvl(pname(j),'No Name');
    parm1(18) := 'PHOTO ALBUM';
    parm2(18) := 'FALSE';
    parm1(19) := 'BRIDAL';
    parm2(19) := 'TRUE';
    parm1(20) := 'QUALITY';
    parm2(20) := 'STANDARD';
    parm1(21) := 'COMPRESSION';
    parm2(21) := 'S'; -- Size to 80k
    parm1(22) := 'CONVERT_TO';
    parm2(22) := 'JPEG';
    parm1(23) := 'SESSION_ID';
    -- If the images are Public (Business Feature) then no session id is attached to them
    if is_bf(theme_rec,ltype,365,34,'T','T')
     then
      parm2(23) := NULL;
     else
      parm2(23) := owner_id;
    end if;
    parm1(24) := 'FILM_NAME';
    parm2(24) := nvl(pname(j),'No Name');
    ump.load_uma(surl,parm1,parm2,retval,newid_arr ); new_photo := newid_arr(1);

    if retval is null
     then
      if newid_arr.count > 0
       then
        for j in newid_arr.first..newid_arr.last loop
          ctr1 := ctr1 + 1;
          ret_array(ctr1) := newid_arr(j);
          open c2(new_photo);
          fetch c2 into new_photos(ctr1);
          close c2;
        end loop;
      end if;
     else
      ctr2 := ctr2 + 1;
      bad_img(ctr2) := retval;
    end if;

   end if;
  end loop;
  /*
  for j in ret_array.first..ret_array.last loop
   insert into temp values (j || '-' || ret_array(j)); commit;
  end loop;
     insert into temp values ('A' || '-' || ctr2); commit;
  */

 if ctr2 > 0
  then
   htp.htmlopen;
   glbx.header_msg(LNG.PHG_ALT_429);
   for j in 1..ctr2 loop
     htp.bold( bad_img( j ) );
     htp.nl;
   end loop;
   htp.htmlclose;
  else
   -- Auto Add Images to the Shopping Trolley
   if is_bf(theme_rec,ltype,366,46,'T','T')
    then
     ret_array(0) := '0';
     dummy_array(1) := '0';
     cst.accept_display(surl=>surl, p0=>empty_array, p1=>ret_array, pa=>empty_array, pb=>empty_array, pc=>dummy_array, ppn=>empty_array,
                        left_api_parm=>scnm, footer_api=>'cst.disp_category', current_page_number=>'1', display_detail=>NULL,
                        add_to_trolley=>'Order Photos' );
    else
     glbx.extended_search_api(surl, ltype, new_photos, new_photos.count,
                              display_detail=>NULL, title=>LNG4.AHC_TXT_471, help_file_code=>NULL,
                              left_api=>NULL, left_api_parm=>scnm, footer_api=>'cst.disp_category',
                              current_page_number=>'1', no_results_message=>LNG4.AHC_TXT_472);
   end if;
 end if;

exception when others then
 -- owa_content.delete_document( last_file );
 glbx.error_details( 'CST', 'TLOAD',errmsg=>sqlerrm,extdet=>'SCNM:' || scnm);
end tload;

procedure display_gallery(surl varchar2,msg in varchar2 default null)
as

 cursor c1(phgr_id integer) is
  select um.umo_id, um.extras, um.version
  from umo um
  where umo_owner = 'PHOTOGRAPHER' and
        umo_type = 'GALLERY' and
        um.aid = phgr_id and
        um.extras.enabled_phg = 'TRUE'
  order by um.extras.orderby_nmb;

 cursor c2(phgr_id integer) is select photographer_title from photographer where pid = phgr_id;

 crec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 phg_title	varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.DISPLAY_GALLERY' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 crec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( crec.theme_name );
 open c2( owner_id );
 fetch c2 into phg_title;
 close c2;

 glbx.main_title( surl, nvl(msg,replace(LNG.CST_TXT_220,'<PHOTOGRAPHER>',phg_title)),'<BODY BGCOLOR="#' || pfx.gallery_back || '">',helpid=>'C14',stype=>stype,sstyle=>pfx.gallery_text_font,sclr=>pfx.gallery_text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 -- glbx.main_title( surl, nvl(msg,LNG.CST_TXT_220),glbx.backimg(surl,crec.aid,pfx.gallery_back,crec.background_img),helpid=>'C14',stype=>stype,sstyle=>pfx.gallery_text_font,sclr=>pfx.gallery_text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
 htp.nl;
 htp.italic( LNG.CST_TXT_221 );
 htp.nl;
 htp.tableopen;
 for c1rec in c1(crec.pid) loop
  if mod( c1%ROWCOUNT,glbx.sctrl(pfx.theme_name,'GALLERY_HORIZONTAL',stype)) = 0
   then
    htp.tablerowclose;
    htp.tablerowopen;
  end if;
  htp.tabledata( htf.anchor(
              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=GALLERY&parm1=DISPLAY_WHAT&parm2=MASTER'  || '&parm1=VERSION&parm2=' || c1rec.version || '&parm1=LOGIN_TYPE&parm2=CUSTOMER_GALLERY&parm1=RETURN_LINK&parm2=cst.display_gallery~surl=' || glbx.rndsurl(surl),
              '<IMG BORDER=0 SRC="' ||
              'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c1rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL'  || '&parm1=VERSION&parm2=' || c1rec.version||
              '&parm1=LOGIN_TYPE&parm2=CUSTOMER_GALLERY&parm1=AID&parm2=' || to_char(owner_id) || '" ' ||
	      'ALT="' || c1rec.extras.photo_name || '" STYLE="display:block;">') || htf.nl ||
	      htf.bold(c1rec.extras.photo_name) ,cattributes=>' valign="MIDDLE" ALIGN="CENTER" CLASS="SMALL"' );
 end loop;
 htp.tablerowclose;
 htp.tableclose;
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'DISPLAY_GALLERY',errmsg=>sqlerrm);
end display_gallery;

procedure acct_details(surl varchar2, acid in integer default null, msg in varchar2 default null)
as

 cursor c7(custid integer, vltype varchar2) is select * from address_book where own_id = custid and ltype = vltype order by book_name;

 cursor c9(acid integer) is select email_address,date_created from grab_email where aid = acid;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 lval1		varchar2(100);
 lval2		varchar2(100);
 tmp		varchar2(2000);
 xltype		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.ACCT_DETAILS', iscust=>TRUE );
 if sts is not null
  then
   glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.ACCT_DETAILS', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
 end if;

 if ltype = 'PHOTOGRAPHER'
  then
   xltype := 'OWNER';
   c1rec := glbx.get_aid( acid, 'C', xltype );
  else
   c1rec := glbx.get_aid( owner_id, 'C', ltype );
 end if;
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );

 htp.p( '<CENTER>' );

 /*  Now moved to a novelty
 if ltype in ('OWNER','PROFILE','PHOTOGRAPHER')
   then
    glbx.main_title( surl, LNG.CST_TXT_236,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C15',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
    if msg is not null then glbx.header_msg( msg ); end if;
    for c5rec in c5(c1rec.aid) loop
     htp.anchor( 'cst.manage_object?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&vmid=' || c5rec.mid || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || c5rec.img,cattributes=>'border=0',calt=>lng.CST_ALT_023 || ':' || c5rec.name ));
    end loop;
    htp.nl;

  else
    glbx.main_title( surl, LNG.CST_TXT_236,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C15',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);
    if msg is not null then glbx.header_msg( msg ); end if;
    for c5rec in c6(c1rec.aid) loop
     htp.anchor( 'cst.manage_object?surl=' || glbx.rndsurl(surl) || '&rnd=' || to_char(sysdate,'SSSSS') || '&vmid=' || c5rec.mid, htf.img( DECS.IMAGE_LOCATION || c5rec.img,cattributes=>'border=0',calt=>c5rec.name ));
    end loop;
    htp.nl;

 end if;

  if ltype in ('CUSTOMER','PROFILEG')
  then
    htp.nl;
    htp.tableopen;
    lval1 := 'x';
    lval2 := 'x';
    for carec in c1(c1rec.aid) loop
     htp.tablerowopen;
      if lval1 <> carec.nm1
       then
        htp.tabledata( htf.bold( carec.nm1 ));
       else
        htp.tabledata( '&nbsp;' );
      end if;
      if lval2 <> carec.nm2
       then
        htp.tabledata( htf.italic(htf.bold( carec.nm2 )));
       else
        htp.tabledata( '&nbsp;' );
      end if;
      htp.tabledata( htf.italic( carec.response ));
     htp.tablerowclose;
     lval1 := carec.nm1;
     lval2 := carec.nm2;
    end loop;
    htp.tableclose;
    glbx.close_page( pfx );

    return;
 end if;
 */

 if (substr(theme_rec.theme_data,411,1) = 'T') and  ltype in ('OWNER','PROFILE','PHOTOGRAPHER')
  then
    htp.tableopen(cattributes=>'cellpadding="2" border="1"');
    htp.tablerowopen;
    htp.p( '<TD>' );
    htp.tableopen(cattributes=>'cellpadding="2" border="0"');
    htp.formopen( 'glbx.modify_cust_access' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'ACID', acid );
    if ltype = 'PHOTOGRAPHER' then htp.formhidden( 'ACID', c1rec.aid ); end if;
    htp.tablerowopen;
    htp.tabledata( htf.bold(LNG.CST_TXT_031) );
    if c1rec.customer_disabled = 'T'
     then
      htp.tabledata( LNG.GLB_TXT_055 || htf.formradio( 'P1', 'F' ) || LNG.GLB_TXT_056 || htf.formradio('P1','T', 'CHECKED') );
     else
      htp.tabledata( LNG.GLB_TXT_055 || htf.formradio( 'P1', 'F', 'CHECKED' ) || LNG.GLB_TXT_056 || htf.formradio('P1','T') );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
   htp.tabledata(  htf.bold(LNG.GLB_TXT_059) );
   htp.tabledata(  htf.formtext('P2', 30, 200, c1rec.customer_message ) );
   htp.tablerowclose;
   htp.tableclose;
   htp.formsubmit( null, LNG.GLB_TXT_060 );
   htp.formclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
 end if;

 htp.nl;
 if ltype in ('OWNER','PROFILE','PHOTOGRAPHER')
  then
   -- Following Guests Have Supplied their Email Address
   htp.line;
   htp.nl;
   htp.bold(LNG.CST_TXT_232);
   htp.tableopen(cattributes=>'cellpadding="2" border="1"');
    htp.tablerowopen;
    for c9rec in c9(c1rec.aid) loop
     htp.tabledata( c9rec.email_address || htf.nl || to_char(c9rec.date_created,LNG.MASK) );
     if mod(c9%ROWCOUNT,3) = 0 then htp.tablerowclose; htp.tablerowopen; end if;
    end loop;
    htp.tablerowclose;
   htp.tableclose;

  if c1rec.customer_disabled = 'F'
   then
     htp.nl;
     htp.tableopen(cattributes=>'cellpadding="2" border="1"');
     htp.formopen('glbx.send_emails' );
     htp.formhidden( 'SURL', glbx.rndsurl(surl));
     htp.formhidden( 'ACID', acid );
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.CST_TXT_233) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata( htf.formtext( 'P1', 50, 1000 ));
      htp.tablerowclose;
     htp.tableclose;
     htp.formsubmit( null, LNG.CST_TXT_234 );
     htp.formclose;
     if ltype = 'PHOTOGRAPHER' and substr(theme_rec.theme_data,158,1) = 'T'
      then
       htp.nl;
       htp.formopen( 'pbk.phg_reverse_email' );
       htp.formhidden( 'SURL', glbx.rndsurl(surl));
       htp.formhidden( 'ACID', acid );
       htp.formhidden( 'TYP', 'DISABLED' );
       htp.formsubmit( null, LNG2.FNM_TXT_173 );
       htp.formtext( 'EBOOK', 30, 100 );
       htp.nl;
       htp.formclose;
     end if;
  end if;
 end if;

 -- Customer Address Book
 if (substr(theme_rec.theme_data,157,1) = 'T' and ltype in ('OWNER','PROFILE','PHOTOGRAPHER'))
  then
   htp.line;
   htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
   for c7rec in c7(owner_id,ltype) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'cst.edit_addr?surl=' || glbx.rndsurl(surl) || '&addrid=' || c7rec.abid || '&acid=' || acid, c7rec.book_name), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c7rec.date_created,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.anchor( 'cst.del_addr?surl=' || glbx.rndsurl(surl) || '&addrid=' || c7rec.abid || '&acid=' || acid, LNG2.FNM_TXT_155),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
   htp.bold( LNG2.FNM_TXT_154 );
   htp.formopen( 'cst.create_new_addr' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid);
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
    htp.tablerowopen;
     htp.tabledata( LNG2.FNM_TXT_156 );
     htp.tabledata( htf.formtext( 'P1', 20, 100 ) );
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG2.PBK_TXT_012 );
   htp.formclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
 end if;

 -- Change Password
 if (substr(theme_rec.theme_data,363,1) = 'T') and ltype in ('OWNER','PROFILE')
  then
   htp.line;
   htp.bold( LNG.PHG_TXT_433 );
   htp.nl;
   htp.formopen( 'glbx.change_password' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', null );
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
  htp.formclose;
 end if;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'ACCT_DETAILS',c1rec.pid,c1rec.aid,errmsg=>sqlerrm);
end acct_details;

procedure mfc_clearance( surl in varchar2, mcid in integer, msg in varchar2 default null )
as

 cursor c3(v_umo integer) is select um.photo_thumbnail.width width, um.photo_thumbnail.height height from umo um where umo_id = v_umo;

 cursor c5(mcid integer) is
  select min_amount,max_amount,price_per_unit from mfctr_clearance_items where mfc_clr_id = mcid order by min_amount;

 cursor c6(acid integer, ltype varchar2, mcid integer) is
  select mc.display_description,mc.expiry_date,mc.warranty_id,mc.detailed_description,mc.mfc_clr_id, mc.shipping_manual, mc.shipping_charge, mc.umo_id, mc.manufacturer_id, mc.commission_rate, mc.product_doco
  from customer_contact cc, customer_interest ci, mfctr_interest_group mig, mfctr_clearance mc
       where cc.contact_id = ci.contact_id and
             ci.interest_id = mig.interest_id and
             mc.mfc_clr_id  = mig.mfc_clr_id and
             mc.expiry_date is not null and
             mc.expiry_date >= sysdate and
             mc.contact_home_page = 'T' and
             cc.aid = acid and
             cc.login_type = ltype and
             mc.mfc_clr_id = mcid;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c6rec		c6%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'CST.MFC_CLEARANCE', iscust=>TRUE );
 if sts is not null
  then
    glbx.redisplay_login_page( sts );
    return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG2.FNM_TXT_052,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'C16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 open c6(owner_id,ltype,mcid);
 fetch c6 into c6rec;
 if c6%NOTFOUND
  then
   close c6;
   return; -- trying to break in
 end if;
 close c6;
 glbx.header_msg( nvl(msg,c6rec.display_description ));

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD>' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata(  LNG2.FNM_TXT_053,cattributes=>pfx.qbground);
   htp.tabledata( htf.bold( to_char(c6rec.expiry_date,LNG.MASK) ),cattributes=>pfx.qcbground);
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(  LNG2.FNM_TXT_062,cattributes=>pfx.qbground);
   htp.tabledata( htf.bold( c6rec.detailed_description ),cattributes=>pfx.qcbground);
  htp.tablerowclose;
  if c6rec.product_doco is not null
   then
    htp.tablerowopen;
     htp.tabledata(  LNG4.AHC_TXT_348,cattributes=>pfx.qbground);
     htp.tabledata( htf.anchor2( c6rec.product_doco, LNG4.AHC_TXT_348, ctarget=>'PRODUCT_DOCUMENTATION'),cattributes=>pfx.qcbground);
    htp.tablerowclose;
  end if;
  htp.tablerowopen;
   htp.tabledata(  LNG.ORD_TXT_013,cattributes=>pfx.qbground);
   if c6rec.shipping_manual = 'T'
    then
     htp.tabledata( htf.bold( LNG2.FNM_TXT_083 ),cattributes=>pfx.qcbground);
    else
     htp.tabledata( htf.bold( LNG2.FNM_TXT_082 ) || ' ' || to_char(c6rec.shipping_charge,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground);
   end if;
  htp.tablerowclose;
 htp.tableclose;

 htp.p( '</TD>' );
 if c6rec.umo_id is not null
  then
    open c3(c6rec.umo_id);
    fetch c3 into c3rec;
    close c3;
    htp.tabledata(htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c6rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || c6rec.manufacturer_id || '&parm1=LOGIN_TYPE&parm2=MANUFACTURER',
                  '<IMG BORDER=0 WIDTH=' || c3rec.width || ' HEIGHT=' || c3rec.height || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c6rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=LOGIN_TYPE&parm2=MANUFACTURER&parm1=AID&parm2=' || c6rec.manufacturer_id ||
                  '" ALT="' || LNG2.PBK_TXT_057 || '" STYLE="display:block;">', ctarget=>'CUSTOMER_CLEARANCE'),
                  cattributes=>'valign="MIDDLE" align="CENTER" CLASS="SMALL"');
 end if;
 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.nl;
 htp.bold( LNG2.FNM_TXT_078 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.PBK_TXT_044 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.PBK_TXT_045 ),cattributes=>pfx.qbground );
   htp.tabledata( htf.bold( LNG2.FNM_TXT_078 ),cattributes=>pfx.qbground );
  htp.tablerowclose;
 for c5rec in c5(mcid) loop
  htp.tablerowopen;
   htp.tabledata( c5rec.min_amount,cattributes=>pfx.qcbground );
   htp.tabledata( c5rec.max_amount,cattributes=>pfx.qcbground );
   htp.tabledata( to_char(round(c5rec.price_per_unit * ((nvl(c6rec.commission_rate,0)/100) + 1),2),LNG.MONEY_FORMAT),cattributes=>pfx.qcbground );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' );
  htp.tablerowopen;
  htp.formopen( 'cst.accept_mfc_clearance' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'MCID', mcid );
   htp.tabledata( htf.bold(LNG.ORD_TXT_185),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formtext( 'P1', 5, 20, 1 ),cattributes=>pfx.qcbground );
   htp.tabledata( htf.formsubmit( null, LNG2.FNM_TXT_084 ),cattributes=>pfx.qcbground );
  htp.formclose;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 glbx.display_warranty(surl,c6rec.warranty_id,c1rec.pid);
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );


exception when others then
 glbx.error_details( 'CST', 'MFC_CLEARANCE',c1rec.pid,c1rec.aid,errmsg=>sqlerrm);
end mfc_clearance;

procedure accept_mfc_clearance( surl in varchar2, mcid in integer, p1 in varchar2 )
as

 cursor c3(mcid integer) is
  select mc.shipping_manual, mc.shipping_charge, mc.display_description, mc.umo_id, mc.manufacturer_id, mc.commission_rate
  from mfctr_clearance mc
  where mc.mfc_clr_id = mcid;

 cursor c4( ltype varchar2, acid integer) is
  select *
  from customer_contact
  where (ltype = 'PROFILE' and aid = acid) or
        (ltype = 'OWNER' and aid = acid);

 cursor c5(sess_id integer) is select aid from login_session where sessid = sess_id;

 cursor c10(mcid integer, nmb integer) is
  select price_per_unit
  from mfctr_clearance_items
  where mfc_clr_id = mcid and
        min_amount <= nmb and
        max_amount >= nmb;

 cursor c12( sess_id integer ) is
  select * from purchase_order where sessid in
  (select sessid from login_session where aid in (select aid from login_session where sessid = sess_id) and login_type in ('PROFILE','PROFILEG'))
  order by date_created desc;

 purchord	purchase_order%ROWTYPE;
 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c12rec		c12%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 acid		integer;
 sess_id	integer;
 ltype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 nmb		integer;
 phg_id		integer;
 profid		integer;
 dcost		number;
 order_status	varchar2(20);

begin
 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'CST.MFC_CLEARANCE', iscust=>TRUE );
 if sts is not null
  then
    glbx.redisplay_login_page( sts );
    return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec );

 begin nmb := to_number( p1 ); exception when others then mfc_clearance(surl,mcid,LNG2.FNM_TXT_085); return; end;
 if nmb is null then mfc_clearance(surl,mcid,LNG2.FNM_TXT_085); return; end if;
 open c10( mcid, nmb );
 fetch c10 into c10rec;
 if c10%NOTFOUND
  then
   close c10;
   mfc_clearance(surl,mcid,LNG2.FNM_TXT_085);
   return;
 end if;
 close c10;

 open c3(mcid);
 fetch c3 into c3rec;
 close c3;
 if c3rec.shipping_manual = 'F'
  then
   dcost := c3rec.shipping_charge;
  else
   dcost := 0;
 end if;

 update purchase_order
  set
   status = decode(status,'PreOrder - No Order Made','PreOrder',status),
   manual_shipping_charge = nvl(manual_shipping_charge,0) + dcost,
   delivery_cost = nvl(delivery_cost,0) + dcost
 where poid = purchord.poid;

 insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value) values (purchord.poid,'MANUAL_SHIPPING_CHARGE',sysdate,'U','C',to_char(dcost));
 insert into purchase_audit(poid,column_name,date_changed,action,changed_by,new_value) values (purchord.poid,'DELIVERY_COST',sysdate,'U','C',to_char(dcost));

 insert into shopping_basket
   (poid,shopping_id,phid,qty,photo_size,photo_cost,film_type,
    ppi,phg_code,lab_id,manufctr_code,
    xref_mfctr_code,is_discounted,name,price,tax,commission,
    b2c_lab_discount,lab_charge_perc,film_name,isgallery)
 values
   (purchord.poid,s_shopping_basket.nextval,c3rec.umo_id,nmb,c3rec.display_description,round(c10rec.price_per_unit * ((nvl(c3rec.commission_rate,0)/100) + 1),2),null,
    null,null,c3rec.manufacturer_id,mcid,
    null,null,c3rec.display_description,c10rec.price_per_unit,null,null,
    null,null,null, 'C');
 commit;
 fname.acct_orders(surl);

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_MFC_CLEARANCE',c1rec.pid,c1rec.aid,errmsg=>sqlerrm);
end accept_mfc_clearance;

procedure show_mfc_clearance( surl in varchar2, rnd in varchar2 default null )
as

 cursor c2(acid integer, ltype varchar2) is
  select distinct mc.display_description,mc.expiry_date,mc.warranty_id,mc.detailed_description,mc.mfc_clr_id
  from customer_contact cc, customer_interest ci, mfctr_interest_group mig, mfctr_clearance mc
       where cc.contact_id = ci.contact_id and
             ci.interest_id = mig.interest_id and
             mc.mfc_clr_id  = mig.mfc_clr_id and
             mc.expiry_date is not null and
             mc.expiry_date >= sysdate and
             mc.contact_home_page = 'T' and
             cc.aid = acid and
             cc.login_type = ltype
  order by mc.expiry_date desc;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 sess_id	integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.SHOW_MFC_CLEARANCE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 glbx.main_title( surl, LNG2.FNM_TXT_052,glbx.backimg(surl,owner_id,pfx.text_back,c1rec.background_img,ltype),helpid=>'C17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 foundrec := FALSE;
 for c2rec in c2(owner_id,ltype) loop
  foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'cst.mfc_clearance?surl=' || glbx.rndsurl(surl) || '&mcid=' || c2rec.mfc_clr_id, c2rec.display_description ),cattributes=>pfx.qcbground);
   htp.tablerowclose;
 end loop;
 htp.tableclose;
 if not foundrec
  then
   glbx.header_msg( LNG2.FNM_TXT_144 );
 end if;
 htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.formclose;

exception when others then
 glbx.error_details( 'CST', 'SHOW_MFC_CLEARANCE',c1rec.pid,c1rec.aid,errmsg=>sqlerrm);
end show_mfc_clearance;

procedure edit_addr(surl varchar2, addrid in integer, acid in integer default null, msg in varchar2 default null)
as

 cursor c2(phgid integer, addrid integer, vltype varchar2) is select email_address from address_book_entry where abid = addrid and addrid = (select addrid from address_book where own_id = phgid and ltype = vltype and abid = addrid ) order by email_address;

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 profid		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.EDIT_ADDR' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG2.FNM_TXT_159, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C18',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_301 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.formopen( 'cst.accept_addr' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ADDRID', addrid );
   htp.formhidden( 'ACID', acid );
   for c2rec in c2(owner_id,addrid,ltype) loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P1', 30, 100, c2rec.email_address ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
   for j in 1..10 loop
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P1', 30, 100, null ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG2.FNM_TXT_160 );
   htp.formclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</CENTER>' );
  glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'EDIT_ADDR', errmsg=>sqlerrm);
end edit_addr;

procedure accept_addr( surl varchar2, addrid in integer, acid in integer default null, p1 in GLBX.MYARRAY)
as

 vltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl, stype, vltype, owner_id, sts, progcalled=>'CST.ACCEPT_ADDR' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  delete from address_book_entry where abid = addrid and abid = (select addrid from address_book where abid = addrid and ltype = vltype and own_id = owner_id);
  for j in p1.first..p1.last loop
   if p1(j) is not null
    then
     insert into address_book_entry(abid,email_address) values (addrid,p1(j));
   end if;
  end loop;
  commit;
  edit_addr(surl, addrid, acid, LNG2.FNM_TXT_161);

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_ADDR', errmsg=>sqlerrm);
end accept_addr;

procedure del_addr( surl varchar2, addrid in integer, acid in integer default null)
as

 vltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, vltype, owner_id, sts, progcalled=>'CST.DEL_ADDR' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  delete from address_book_entry where abid = addrid and abid = (select abid from address_book where ltype = vltype and own_id = owner_id and abid = addrid);
  delete from address_book where ltype = vltype and own_id = owner_id and abid = addrid;
  commit;
  acct_details(surl, acid, LNG2.FNM_TXT_157);

exception when others then
 glbx.error_details( 'CST', 'DEL_ADDR', errmsg=>sqlerrm);
end del_addr;

procedure create_new_addr( surl varchar2, p1 in varchar2, acid in integer default null )
as

 cursor c1(aname varchar2, custid integer, vltype varchar2) is select 'x' from address_book where own_id = custid and book_name = aname and ltype = vltype;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newid		integer;
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.DEL_ADDR' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c1(upper(p1),owner_id,ltype);
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    acct_details(surl, acid, LNG2.FNM_TXT_158 );
    return;
  end if;
  close c1;

  select max(abid) into newid from address_book;
  newid := nvl(newid,0) + 1;
  insert into address_book(abid,book_name,ltype,own_id,date_created) values (newid,upper(p1),ltype,owner_id,sysdate);
  commit;
  edit_addr(surl, newid, acid );

exception when others then
 glbx.error_details( 'CST', 'DEL_ADDR', errmsg=>sqlerrm);
end create_new_addr;

procedure tender_list(surl varchar2, rnd in varchar2, msg in varchar2 default null)
as

 cursor c2( acid integer ) is select * from tender where aid = acid order by date_locked desc;
 cursor c3( acid integer, vtid integer ) is select count('x') tot from tender_mfctr_item tmi, tender_item ti where ti.tender_id = vtid and ti.item_id = tmi.item_id and tmi.tender_id = vtid and tmi.successful_bid = 'T';
 cursor c4( acid integer, vtid integer ) is select count('x') tot from tender_item ti where ti.tender_id = vtid;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.TENDER_LIST' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_001, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_002 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( '&nbsp;' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   for c2rec in c2( owner_id ) loop
   htp.tablerowopen;
    htp.tabledata( htf.anchor( 'cst.modify_tender_list?surl=' || glbx.rndsurl(surl) || '&tid=' || c2rec.tender_id, c2rec.quote_reference), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_locked,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_created,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c2rec.date_locked <= trunc(sysdate)
     then
      htp.tabledata( htf.bold( LNG4.AHC_TXT_019 ) || htf.nl || LNG4.AHC_TXT_283, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      open c3( owner_id, c2rec.tender_id );
      fetch c3 into c3rec;
      close c3;
      open c4( owner_id, c2rec.tender_id );
      fetch c4 into c4rec;
      close c4;
      if (c4rec.tot = c3rec.tot) and (c4rec.tot > 0)
       then
        htp.tabledata( htf.bold( LNG4.AHC_TXT_282 ) || htf.nl || LNG4.AHC_TXT_283, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
        htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
    end if;
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formopen( 'cst.modify_tender_list' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'TID', null );
   htp.formsubmit( null, LNG4.AHC_TXT_004 );
   htp.formclose;
  htp.p( '</CENTER>' );
  glbx.close_page( pfx );


exception when others then
 glbx.error_details( 'CST', 'TENDER_LIST', errmsg=>sqlerrm);
end tender_list;

procedure modify_tender_list(surl varchar2, tid in varchar2, msg in varchar2 default null)
as

 cursor c2( acid integer, tid integer ) is select * from tender where aid = acid and tender_id = tid;
 cursor c3( phgid integer) is select * from warranty where pid = phgid order by warranty_name desc;
 cursor c4( acid integer, tid integer ) is select * from tender_item where tender_id = tid and tender_id = (select tender_id from tender where aid = acid and tender_id = tid) order by item_id;
 cursor c5( tid integer, itid integer ) is select price_per_unit,shipping from tender_mfctr_item where tender_id = tid and item_id = itid and successful_bid = 'T';
 cursor c6( acid integer, vtid integer ) is select count('x') tot from tender_mfctr_item tmi, tender_item ti where ti.tender_id = vtid and ti.item_id = tmi.item_id and tmi.tender_id = vtid and tmi.successful_bid = 'T';
 cursor c7( acid integer, vtid integer ) is select count('x') tot from tender_item ti where ti.tender_id = vtid;
 cursor c3x( acid integer, vtid integer ) is select count('x') tot from tender_mfctr_item tmi, tender_item ti where ti.tender_id = vtid and ti.item_id = tmi.item_id and tmi.tender_id = vtid and tmi.successful_bid = 'T';
 cursor c4x( acid integer, vtid integer ) is select count('x') tot from tender_item ti where ti.tender_id = vtid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3xrec		c3x%ROWTYPE;
 c4xrec		c4x%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 ttl		number;
 readonly	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.MODIFY_TENDER_LIST' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );
  if tid is null
   then
    glbx.main_title( surl, LNG4.AHC_TXT_005, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   else
    glbx.main_title( surl, LNG4.AHC_TXT_006, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  end if;
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  if tid is not null
   then
    open c2(owner_id, tid );
    fetch c2 into c2rec;
    close c2;
  end if;

  open c6( owner_id, tid );
  fetch c6 into c6rec;
  close c6;
  open c7( owner_id, tid );
  fetch c7 into c7rec;
  close c7;

  if c2rec.date_locked <= trunc(sysdate)
   then
    readonly := TRUE;
   else
      open c3x( owner_id, tid );
      fetch c3x into c3xrec;
      close c3x;
      open c4x( owner_id, tid );
      fetch c4x into c4xrec;
      close c4x;
      if (c4xrec.tot = c3xrec.tot) and (c4xrec.tot > 0)
       then
        readonly := TRUE;
       else
        readonly := FALSE;
      end if;
  end if;

  if not readonly
   then
    htp.formopen( 'cst.accept_tender_list' );
    htp.formhidden( 'SURL', glbx.rndsurl(surl));
    htp.formhidden( 'TID', tid );
  end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_002 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if readonly
     then
      htp.tabledata( c2rec.quote_reference, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.formtext( 'P1', 30, 100, c2rec.quote_reference ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( nvl(to_char( c2rec.date_created,LNG.MASK),'&nbsp;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_008 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( nvl(to_char( c2rec.date_updated,LNG.MASK),'&nbsp;')),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if readonly
     then
      htp.tabledata( to_char( c2rec.date_locked,LNG.MASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.formtext( 'P2', 20, 40, to_char( c2rec.date_locked,LNG.MASK)) || ' ' || htf.italic( LNG.MASK || ' eg. 17-JAN-2002'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.CST_TXT_118 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if readonly
     then
       htp.tabledata( c2rec.postcode,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
       htp.tabledata( htf.formtext( 'P3', 10, 20, c2rec.postcode),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_285 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if readonly
     then
      htp.tabledata( c2rec.tender_details,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.formtextareaopen( 'P3D', 5, 40 ) || c2rec.tender_details || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_009 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_074 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_011 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_010 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    if (c2rec.date_locked < trunc(sysdate)) or (c6rec.tot = c7rec.tot and c7rec.tot > 0)
     then
      htp.tabledata( htf.bold( LNG4.AHC_TXT_021 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
      htp.tabledata( htf.bold( LNG.ORD_TXT_013 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    end if;
   htp.tablerowclose;
   ttl := 0;
   for c4rec in c4(owner_id,tid) loop
    htp.tablerowopen;
     if readonly
      then
       htp.tabledata( c4rec.cust_description,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( c4rec.qty,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( to_char(c4rec.cust_max_price,LNG.LRG_MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( c4rec.item_valid,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
      else
       htp.formhidden( 'R0', c4rec.item_id );
       htp.tabledata( htf.formtext( 'R1', 35, 100, c4rec.cust_description),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'R2', 5, 10, c4rec.qty),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( htf.formtext( 'R3', 15, 20, to_char(c4rec.cust_max_price,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       if c4rec.item_valid = 'T'
        then
         htp.tabledata( htf.formcheckbox( 'R4', '[' || c4rec.tender_id || ']' || c4rec.item_id, 'CHECKED'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
        else
         htp.tabledata( htf.formcheckbox( 'R4', '[' || c4rec.tender_id || ']' || c4rec.item_id),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       end if;
     end if;
    if (c2rec.date_locked < trunc(sysdate)) or (c6rec.tot = c7rec.tot and c7rec.tot > 0)
     then

      c5rec.price_per_unit := NULL;
      open c5( tid, c4rec.item_id );
      fetch c5 into c5rec;
      close c5;
      if c5rec.price_per_unit is null
       then
         htp.tabledata( htf.bold(LNG4.AHC_TXT_022),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
         htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
         --htp.tabledata( htf.bold(to_char(c5rec.price_per_unit,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
         ttl := ttl + nvl(c4rec.max_price * nvl(c4rec.qty,1),0);
         htp.tabledata( htf.bold(to_char((c4rec.max_price),LNG.LRG_MONEY_FORMAT)) || htf.nl ||
                        to_char(c4rec.max_price * nvl(c4rec.qty,1),LNG.LRG_MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
         htp.tabledata( htf.bold(to_char(c5rec.shipping,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
      end if;
    end if;
   htp.tablerowclose;
   end loop;

   if (c2rec.date_locked >= trunc(sysdate) or c2rec.date_locked is null) and not (c6rec.tot = c7rec.tot and c7rec.tot > 0)
    then
     for j in 1..10 loop
      htp.tablerowopen;
       htp.formhidden( 'R0', NULL );
       htp.tabledata( htf.formtext( 'R1', 35, 100, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formtext( 'R2', 5, 10, '1'),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( htf.formtext( 'R3', 15, 20, null),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="RIGHT"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
     end loop;
    else
      htp.tablerowopen;
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( htf.bold(to_char(ttl,LNG.LRG_MONEY_FORMAT)),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
       htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
   end if;

   if not readonly then htp.formhidden( 'R4', null ); end if;
  htp.tableclose;
  htp.nl;
  if not readonly
   then
    if tid is null
     then
      htp.formsubmit( 'ACTION', LNG4.AHC_TXT_005 );
     else
      htp.formsubmit( 'ACTION', LNG4.AHC_TXT_006);
      htp.formsubmit( 'ACTION', LNG4.AHC_TXT_007);
    end if;
    htp.formsubmit( 'ACTION', LNG4.AHC_TXT_020);
    htp.formclose;
  end if;
  if c2rec.warranty_id is not null
   then
    glbx.display_warranty(surl,c2rec.warranty_id,c1rec.pid);
  end if;
  htp.p( '</CENTER>' );
  glbx.close_page( pfx );


exception when others then
 glbx.error_details( 'CST', 'MODIFY_TENDER_LIST', errmsg=>sqlerrm);
end modify_tender_list;

procedure accept_tender_list( surl varchar2, tid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p3d in varchar2, action in varchar2, r0 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY )
as

 cursor c1( tid integer ) is select max(item_id) from tender_item where tender_id = tid;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 ntid		integer;
 dt1		date;
 msg		varchar2(200);
 nqty		integer;
 mprice		number;
 newid		integer;
 tdet		varchar2(4000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.ACCEPT_TENDER_LIST' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  begin dt1 := to_date( p2, LNG.MASK ); exception when others then msg := LNG4.AHC_TXT_015; dt1 := sysdate +14; end;
  if dt1 < sysdate
   then
    msg := LNG4.AHC_TXT_015;
    dt1 := sysdate +14;
  end if;

  if action = LNG4.AHC_TXT_007
   then
    delete from tender_mfctr_item where tender_id = tid and tender_id in (select tender_id from tender where aid = owner_id and tender_id = tid);
    delete from tender_item where tender_id in (select tender_id from tender where tender_id = tid and aid = owner_id);
    delete from tender where tender_id = tid and aid = owner_id;
    tender_list( surl, to_char(sysdate,'SSSS'), LNG3.ADM_TXT_433 );
    return;
  end if;
  if p3 is null then msg := msg || LNG4.AHC_TXT_017; end if;
  tdet := substr(p3d,1,4000);

  if tid is null
   then
    select s_tender.nextval into ntid from dual;
    insert into tender(tender_id, aid, quote_reference,date_created,date_updated,date_locked,warranty_id,postcode,tender_details) values
     (ntid, owner_id, nvl(p1,LNG4.AHC_TXT_014), sysdate,null, dt1, null, p3, tdet );
   else
    ntid := tid;
    update tender
     set
      quote_reference = translate(nvl(p1,LNG4.AHC_TXT_014),'+"',' '''),
      date_updated = sysdate,
      date_locked = dt1,
      postcode = p3,
      tender_details = tdet
    where tender_id = ntid and
          aid = owner_id;
  end if;

  update tender_item set item_valid = 'F' where tender_id = ntid;

  for j in r0.first..r0.last loop
   if r0(j) is null and r1(j) is not null
    then
     -- Insert
      begin nqty := nvl(to_number( r2(j) ), 1); exception when others then nqty := 1; end;
      begin mprice := to_number(r3(j)); exception when others then begin mprice := to_number(r3(j),LNG.MONEY_FORMAT); exception when others then mprice := 0; end; end;
      newid := null;
      open c1( ntid );
      fetch c1 into newid;
      close c1;
      newid := nvl(newid,1) + 1;
      insert into tender_item(tender_id,item_id,cust_description,disp_description,qty,cust_max_price,item_valid) values
       (ntid, newid, translate(nvl(r1(j),LNG4.AHC_TXT_018),'+"',' '''), translate(nvl(r1(j),LNG4.AHC_TXT_018),'+"',' '''), nqty, mprice, 'T');
      insert into tender_mfctr_item(tender_id,item_id,successful_bid,manufacturer_id)
       select ntid, newid, null, manufacturer_id
       from tender_mfctr
       where tender_id = ntid;
    elsif r0(j) is not null and r1(j) is null
     then
      -- Delete
      delete from tender_mfctr_item where tender_id = tid and tender_id = (select tender_id from tender where aid = owner_id and tender_id = tid) and item_id = r0(j);
      delete from tender_item where tender_id = tid and tender_id = (select tender_id from tender where aid = owner_id and tender_id = tid) and item_id = r0(j);
    elsif r0(j) is not null and r1(j) is not null
     then
     -- Update
     begin nqty := nvl(to_number( r2(j) ), 1 ); exception when others then nqty := 1; end;
     begin mprice := to_number(r3(j)); exception when others then begin mprice := to_number(r3(j),LNG.MONEY_FORMAT); exception when others then mprice := 0; end; end;
     if nqty < 1 then nqty := 1; end if;
     if mprice < 0 then mprice := 0; end if;
     update tender_item
      set
       qty = nqty,
       cust_description = translate(nvl(r1(j),LNG4.AHC_TXT_018),'+"',' '''),
       cust_max_price = mprice
     where tender_id = tid and tender_id = (select tender_id from tender where aid = owner_id and tender_id = tid) and item_id = r0(j);
   end if;
  end loop;

  for j in r4.first..r4.last loop
   if r4(j) is not null
    then
     update tender_item
      set
       item_valid = 'T'
      where tender_id = to_number(substr(r4(j),2,instr(r4(j),']')-2)) and
            item_id = to_number(substr(r4(j),instr(r4(j),']')+1)) and
            tender_id = (select tender_id from tender where aid = owner_id and tender_id = ntid);
    end if;
  end loop;

  commit;

  if action = LNG4.AHC_TXT_020 and tid is null
   then
    tender_list( surl, to_char(sysdate,'SSSS'), nvl(msg,LNG4.AHC_TXT_012) );
    return;
  elsif action = LNG4.AHC_TXT_020 and tid is not null
   then
    tender_list( surl, to_char(sysdate,'SSSS'), nvl(msg,LNG4.AHC_TXT_013) );
    return;
  end if;

  if tid is null
   then
    modify_tender_list(surl, ntid, nvl(msg,LNG4.AHC_TXT_012));
   else
    modify_tender_list(surl, ntid, nvl(msg,LNG4.AHC_TXT_013));
  end if;

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_TENDER_LIST', errmsg=>sqlerrm);
end accept_tender_list;

procedure reverse_list(surl varchar2, rnd in varchar2, msg in varchar2 default null)
as

 cursor c2( acid integer, phgid integer, ltype varchar2 ) is
  select distinct ra.reverse_id,ra.product_name,ra.date_created,ra.date_locked,ra.warranty_id,ra.product_location_pcode
  from reverse_auction ra, reverse_interest ri, customer_interest ci, customer_contact cc
  where pid = phgid and
        ci.contact_id = cc.contact_id and
        cc.aid = acid and
        cc.login_type = ltype and
        ri.reverse_id = ra.reverse_id and
        ri.interest_id = ci.interest_id
  order by ra.date_locked desc;

 cursor c3( wid integer ) is select warranty_name from warranty where warranty_id = wid;
 cursor c6(raid integer, acid integer) is select bid_qty from reverse_bid where reverse_id = raid and aid = acid;
 cursor c7(raid integer) is select price_per_unit from reverse_history where reverse_id = raid and date_updated = (select max(date_updated) from reverse_history where reverse_id = raid);

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.REVERSE_LIST' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNG4.AHC_TXT_039, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_040 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_041 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( '&nbsp;' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_071 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
   htp.tablerowclose;
   foundrec := FALSE;
   for c2rec in c2( owner_id, c1rec.pid, ltype ) loop
   foundrec := TRUE;
   htp.tablerowopen;
    if c2rec.date_locked <= sysdate
     then
      htp.tabledata( htf.bold(c2rec.product_name), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.anchor( 'cst.manage_reverse?surl=' || glbx.rndsurl(surl) || '&raid=' || c2rec.reverse_id, c2rec.product_name), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    htp.tabledata( c2rec.product_location_pcode, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_locked,LNG.MASK || ' HH24:MI'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char(c2rec.date_created,LNG.MASK), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    if c2rec.date_locked <= sysdate
     then
      htp.tabledata( htf.bold( LNG4.AHC_TXT_042 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.bold( LNG4.AHC_TXT_043 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    open c6(c2rec.reverse_id,owner_id);
    fetch c6 into c6rec;
    if c6%FOUND
     then
      open c7(c2rec.reverse_id);
      fetch c7 into c7rec;
      if c7%FOUND
       then
         htp.tabledata( to_char(c7rec.price_per_unit * c6rec.bid_qty,LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
       else
         htp.tabledata( LNG4.AHC_TXT_068, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
      close c7;
     else
      htp.tabledata( LNG4.AHC_TXT_060, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
    close c6;
   htp.tablerowclose;
   end loop;
   htp.tableclose;
   if not foundrec
    then
     htp.nl;
     htp.bold( LNG4.AHC_TXT_044 );
     htp.nl;
   end if;
  htp.p( '</CENTER>' );
  glbx.close_page( pfx );


exception when others then
 glbx.error_details( 'CST', 'REVERSE_LIST', errmsg=>sqlerrm);
end reverse_list;

procedure manage_reverse(surl varchar2, raid in integer, msg in varchar2 default null)
as

 cursor c2( raid integer, phgid integer) is
  select *
  from reverse_auction ra
  where ra.reverse_id = raid and
        pid = phgid;

 cursor c3( raid integer, acid integer ) is select bid_qty from reverse_bid where aid = acid and reverse_id = raid;
 cursor c6(raid integer) is select price_per_unit,date_updated from reverse_history where reverse_id = raid order by date_updated desc;
 cursor c7(raid integer) is select price_per_unit from reverse_history where reverse_id = raid and date_updated = (select max(date_updated) from reverse_history where reverse_id = raid);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.MANAGE_REVERSE' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );
  open c2( raid, c1rec.pid );
  fetch c2 into c2rec;
  close c2;
  open c3( raid, owner_id );
  fetch c3 into c3rec;
  close c3;
  open c7(raid);
  fetch c7 into c7rec;
  close c7;
  glbx.main_title( surl, LNG4.AHC_TXT_059, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  htp.nl;
  htp.formopen( 'cst.accept_reverse_bid' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'RAID', raid );
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_040 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( c2rec.product_name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_041 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( c2rec.product_location_pcode,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.GLB_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char( c2rec.date_created, LNG.MASK ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.ORD_TXT_153 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( to_char( c2rec.date_locked, LNG.MASK || ' HH24:MI' ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_061 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if c7rec.price_per_unit is null
     then
      htp.tabledata( LNG4.AHC_TXT_068,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( to_char(c7rec.price_per_unit,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_062 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    if c3rec.bid_qty is null
     then
      htp.tabledata( htf.formtext( 'P1', 10, 10, null ) || ' ' || LNG4.AHC_TXT_060,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     else
      htp.tabledata( htf.formtext( 'P1', 10, 10, c3rec.bid_qty ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      if c7rec.price_per_unit is not null
       then
        htp.tablerowclose;
         htp.tabledata( htf.bold( LNG4.AHC_TXT_071 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         htp.tabledata( to_char(c7rec.price_per_unit * c3rec.bid_qty,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      end if;
    end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_063 );
  htp.formsubmit( 'ACTION', LNG4.AHC_TXT_020 );
  htp.formclose;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_052 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG2.FNM_TXT_078 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_053 ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c6rec in c6(raid) loop
    htp.tablerowopen;
     htp.tabledata( to_char(c6rec.price_per_unit,LNG.MONEY_FORMAT),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(c6rec.date_updated,LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
   end loop;
  htp.tableclose;
  htp.nl;
  glbx.display_warranty(surl,c2rec.warranty_id,c1rec.pid);
  htp.p( '</CENTER>' );
  glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'MANAGE_REVERSE', errmsg=>sqlerrm);
end manage_reverse;

procedure accept_reverse_bid( surl in varchar2, raid in integer, p1 in varchar2, action in varchar2 )
as

 cursor c1(raid integer, acid integer) is select bid_qty from reverse_bid where reverse_id = raid and aid = acid;
 cursor c2(raid integer) is select sum(nvl(bid_qty,0)) tot from reverse_bid where reverse_id = raid;
 cursor c3(raid integer, qty integer) is select price_per_unit from reverse_price where reverse_id = raid and qty >= qty_from and qty <= qty_to;
 cursor c4(raid integer) is select max(qty_to) max_qty,min(qty_from) min_qty from reverse_price where reverse_id = raid;
 cursor c5(raid integer, qty integer) is select price_per_unit from reverse_price where reverse_id = raid and qty_to = qty;
 cursor c6(raid integer, qty integer) is select price_per_unit from reverse_price where reverse_id = raid and qty_from = qty;
 cursor c7(raid integer) is select price_per_unit from reverse_history where reverse_id = raid and date_updated = (select max(date_updated) from reverse_history where reverse_id = raid);

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 qty		integer;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CST.ACCEPT_REVERSE_BID' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNG4.AHC_TXT_020
   then
     reverse_list( surl, to_char(sysdate,'SSSSS') );
     return;
  end if;

  begin
   qty := to_number( p1 );
   if qty < 1
    then
     manage_reverse(surl,raid,LNG4.AHC_TXT_067 || ':' || p1 );
     return;
   end if;
  exception
   when others
    then
     manage_reverse(surl,raid,LNG4.AHC_TXT_066 || ':' || p1 );
     return;
  end;

  open c1( raid, owner_id );
  fetch c1 into c1rec;
  if c1%NOTFOUND
   then
    close c1;
    insert into reverse_bid(reverse_id,aid,bid_qty) values (raid,owner_id,qty);
   else
    close c1;
    update reverse_bid
     set
      bid_qty = qty
    where
     reverse_id = raid and
     aid = owner_id;
  end if;

  if p1 is null
   then
    delete from reverse_bid where reverse_id = raid and aid = owner_id;
    qty := 0;
    commit;
  end if;

  open c2(raid);
  fetch c2 into c2rec;
  close c2;

  open c4(raid);
  fetch c4 into c4rec;
  close c4;

  open c3(raid,c2rec.tot);
  fetch c3 into c3rec;
  if c3%NOTFOUND
   then
    close c3;
    if qty >= c4rec.max_qty
     then
      open c5( raid, c4rec.max_qty );
      fetch c5 into c3rec.price_per_unit;
      close c5;
    elsif qty <= c4rec.min_qty
     then
      open c6( raid, c4rec.min_qty );
      fetch c6 into c3rec.price_per_unit;
      close c6;
    else
     -- There are no bids entered
      c3rec.price_per_unit := null;
      manage_reverse(surl,raid,LNG4.AHC_TXT_068);
      return;
    end if;
   else
    close c3;
  end if;

  open c7(raid);
  fetch c7 into c7rec;
  close c7;

  if nvl(c7rec.price_per_unit,0) <> nvl(c3rec.price_per_unit,0)
   then
    insert into reverse_history(reverse_id,date_updated,price_per_unit) values (raid,sysdate,c3rec.price_per_unit);
   end if;

   commit;

   if p1 is null
    then
     manage_reverse(surl,raid,LNG4.AHC_TXT_070);
   elsif qty < c1rec.bid_qty
    then
     manage_reverse(surl,raid,LNG4.AHC_TXT_064);
   elsif qty = c1rec.bid_qty
    then
     manage_reverse(surl,raid,LNG4.AHC_TXT_069);
    else
     manage_reverse(surl,raid,LNG4.AHC_TXT_065);
   end if;

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_REVERSE_BID', errmsg=>sqlerrm);
end accept_reverse_bid;

function cust_button( pfx in THEME%ROWTYPE, gif in varchar2, element in integer default 1 )
 return varchar2
as
begin
 if nvl(substr(pfx.separate_customer_bt,1,1),'F') = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
 end if;

 if nvl(substr(pfx.separate_customer_bt,element,1),'F') = 'F'
  then
   return( DECS.IMAGE_LOCATION || 'adminc/' || gif );
  else
   return( DECS.IMAGE_LOCATION || pfx.disp_prefix || '/' || gif );
 end if;
end cust_button;

function check_cntry( phgid in integer, acid in integer, sess_id in integer )
 return boolean
is

 cursor c1( sess_id integer ) is select * from login_session where sessid=sess_id;
 cursor c2( profid integer ) is select aid from customer_profile where profile_id = profid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 b2c_value	char(1);
 profid		integer;
 voidrec	order_style%ROWTYPE;

begin
 open c1( sess_id );
 fetch c1 into c1rec;
 close c1;
 if c1rec.login_type in ('PROFILE','PROFILEG')
  then
   profid := c1rec.aid;
   open c2(profid);
   fetch c2 into c2rec;
   close c2;
  else
   profid := NULL;
   c2rec.aid := nvl(acid,c1rec.aid);
 end if;
 voidrec := glbx.get_order_style( glbx.get_order_style( c2rec.aid, profid, c1rec.login_type, b2c_value ));
 if c1rec.country is null then return( TRUE ); end if;
 if voidrec.residing_country = c1rec.country then return( TRUE ); end if;
 return( FALSE );
exception
 when others then return( TRUE );
end check_cntry;

function small_above_thumbnail( surl in varchar2, acid in integer, ltype in varchar2, newdt in integer, pfx in theme%ROWTYPE, umrec in umo%ROWTYPE, phg_title in varchar2 )
 return varchar2
as

 temp	varchar2(1000);

begin
   temp := NULL;
   if umrec.extras.quality in ('SPECIAL MOMENT','DETAIL PHOTO')
    then
     temp := htf.img( cust_button( pfx, 'special.gif',4),cattributes=>'border=0',calt=>replace(LNG.CST_ALT_024,'<PHOTOGRAPHER>',phg_title) );
   elsif umrec.sessid is not null
    then
     temp := htf.bold( LNG4.AHC_TXT_474 );
   elsif umrec.date_created + newdt >= sysdate
    then
     temp := htf.img( cust_button( pfx, 'new.gif',4),cattributes=>'border=0',calt=>LNG5.EXT_TXT_052 );
   end if;

   if umrec.audio_original.description is not null and
      umrec.umo_type <> 'AUDIO'
    then
     temp := temp || htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id ||
                                  '&parm1=DISPLAY_TYPE&parm2=WINDOWX&parm1=DISPLAY_WHAT&parm2=ORIGINAL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                                  '&parm1=OVERRIDE&parm2=AUDIO&parm1=AID&parm2=' || acid,
	                          htf.img( cust_button( pfx, 'smaudio.gif',4),cattributes=>'border=0',calt=>lng.CST_ALT_086 ),ctarget=>'AUDIO_WINDOW');
   end if;
  return( temp );
end small_above_thumbnail;

procedure initialise_api_variables(surl in varchar2, sess_id in integer, ltype in varchar2, nmb1 in integer, nmb2 in integer, nmb3 in integer, cusrec in customer_account%ROWTYPE, theme_rec in theme_types%ROWTYPE, document_api out varchar2, video_api out varchar2, audio_api out varchar2, relational_api out varchar2, blueprint_api out varchar2, upref out varchar2, newdt out integer, is_local out boolean, display_original out varchar2, phg_title out varchar2 )
as

 cursor c1(phgid integer) is select photographer_title from photographer where pid = phgid;

begin

 upref := glbx.userpref(cusrec.pid,cusrec.aid,'LINK_STRENGTH');
 is_local := check_cntry( cusrec.pid, cusrec.aid, sess_id );

 if is_bf(theme_rec,ltype,nmb1,nmb2,'T','T',nmb3,'T')
  then
   newdt := glbx.since_last_session( surl );
  else
   newdt := 0;
 end if;

 is_local := check_cntry( cusrec.pid, cusrec.aid, sess_id );
 display_original := glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL');
 open c1(cusrec.pid);
 fetch c1 into phg_title;
 close c1;

end initialise_api_variables;

function horizontal_meta_tags( surl in varchar2, ltype in varchar2, nmb1 in integer, nmb2 in integer, nmb3 in integer, theme_rec in theme_types%ROWTYPE, umrec in umo%ROWTYPE )
 return varchar2
as

 cursor c10(v_umo integer) is
  select ut.value , uts.edit_type, uts.external_query, uts.sql_select_mask
  from umo_attribute ut, umo_attributes uts
  where ut.attribute_id = uts.attribute_id and
        uts.cust_hor = 'T' and
        ut.umo_id = v_umo
  order by uts.order_by,ut.position_id;

 mt		varchar2(32767);
 foundrec	boolean;

begin
     -- Display Horizontal Meta Tags
 mt := NULL;
 foundrec := FALSE;
 if is_bf(theme_rec,ltype,nmb1,nmb2,'T','T',nmb3,'T')
   then
    mt := htf.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
    for c10rec in c10( umrec.umo_id ) loop
     if c10rec.external_query = 'T'
      then
        mt := mt || htf.tablerowopen || htf.tabledata( nvl(glbx.meta_sql_query( umrec.umo_id, umrec.umo_type, c10rec.sql_select_mask ),'&nbsp;') , cattributes=>' CLASS="SMALL"' );

     elsif c10rec.edit_type = LNG3.ADM_TXT_583
      then
        mt := mt || htf.tablerowopen || htf.tabledata( nvl(htf.anchor( substr(c10rec.value,instr(c10rec.value,',')+1),substr(c10rec.value,1,instr(c10rec.value,',')-1) ),'&nbsp;'), cattributes=>' CLASS="SMALL"');

     elsif c10rec.edit_type = LNG3.ADM_TXT_612
       then
        mt := mt || htf.tablerowopen || htf.tabledata( nvl(htf.mailto( substr(c10rec.value,instr(c10rec.value,',')+1),substr(c10rec.value,1,instr(c10rec.value,',')-1) ),'&nbsp;'), cattributes=>' CLASS="SMALL"');

     else
        mt := mt || htf.tablerowopen || htf.tabledata( c10rec.value, cattributes=>' CLASS="SMALL"' );
      end if;
      foundrec := TRUE;
     end loop;
    mt := mt || htf.tableclose;
 end if;
 if not foundrec then mt := NULL; end if;
 return( mt );
exception
 when others then return( mt );
end horizontal_meta_tags;

procedure manufacturer_object(surl in varchar2, ltype in varchar2, nmb1a in integer, nmb2a in integer, nmb3a in integer, nmb1b in integer, nmb2b in integer, nmb3b in integer, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, umrec in umo%ROWTYPE, close_tabledata in boolean DEFAULT TRUE  )
as

 prod_doco	varchar2(1000);

begin
  if is_bf(theme_rec,ltype,nmb1a,nmb2a,'T','T',nmb3a,'T') and umrec.document_original_loc is not null -- attached_doco
   then
     prod_doco := htf.nl || htf.anchor2( umrec.document_original_loc, LNG4.AHC_TXT_348,ctarget=>'PRODUCT_DOCUMENTATION') || htf.nl;
   else
     prod_doco := NULL;
  end if;
  if umrec.umo_id is null
   then
     -- If there is no image to display, display the default Manufacturer Image
     if pfx.tnail_global_border = 'F' then htp.p( '<TD ' || 'valign="TOP" align="LEFT" CLASS="SMALL">' ); end if;
     glbx.image_matte(pfx,umrec.photo_thumbnail.width,umrec.photo_thumbnail.height,
                      null,
                      htf.img( DECS.IMAGE_LOCATION || 'admin/mfc.gif',cattributes=>'border=0',calt=>LNG2.FNM_TXT_110 ), null );
     htp.p( htf.nl || prod_doco );
     if close_tabledata and pfx.tnail_global_border = 'F' then htp.p( '</TD>' ); end if;
   else
   -- Display Thumbnail
    if pfx.tnail_global_border = 'F' then htp.p( '<TD ' || 'valign="TOP" align="LEFT" CLASS="SMALL">' ); end if;
    if is_bf(theme_rec,ltype,nmb1b,nmb2b,'T','T',nmb3b,'T')
     then
         glbx.image_matte(pfx,umrec.photo_thumbnail.width,umrec.photo_thumbnail.height,
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || umrec.aid || '&parm1=LOGIN_TYPE&parm2=MANUFACTURER',
                  '<IMG BORDER=0 WIDTH=' || umrec.photo_thumbnail.width || ' HEIGHT=' || umrec.photo_thumbnail.height || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.extras.orderby_scene || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL&parm1=LOGIN_TYPE&parm2=MANUFACTURER&parm1=AID&parm2=' || umrec.aid || '&parm1=VERSION&parm2=' || umrec.version ||
                '" ALT="' || LNG.CST_TXT_183 || ' (' || umrec.extras.photo_name || ')" STYLE="display:block;">', ctarget=>'SHOW_IMAGE' );
         htp.p( htf.nl || prod_doco );
     else
	     htp.p( htf.bold(umrec.extras.photo_name) || htf.nl || htf.italic( umrec.extras.title ) || htf.nl || prod_doco );
    end if;
    if close_tabledata and pfx.tnail_global_border = 'F' then htp.p( '</TD>' ); end if;
  end if;
end manufacturer_object;

procedure preselect_price( surl in varchar2, ltype in varchar2, is_local in boolean, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, umrec in umo%ROWTYPE, voidrec in order_style%ROWTYPE )
as

 cursor c11( vspb integer ) is
  select /*+ ALL_ROWS */
         ppit.name photo_size,
         decode(nvl(ppit.item_discounted,'F'),'F',ppit.charge,
                decode(sign(sysdate - nvl(ppit.item_disc_from,sysdate)),-1,ppit.charge,0,ppit.charge,
                       decode(sign(nvl(ppit.item_disc_to,sysdate) - sysdate),-1,ppit.charge,0,ppit.charge,ppit.item_disc_charge)
                       )
               ) photo_cost,
         ppit.film_type, ppit.lease_download_object, ppit.limit_download_object,
         ppit.ppi,ppit.manufacturer_id lab_id,ppit.lab_id manufctr_code,
         ppit.name film_name
  from phg_price_item ppit
  where spb = vspb and
        enabled = 'T' and
        is_default = 'T';
 cursor c12( v_umo integer ) is select * from umo where umo_id = v_umo;
 cursor c13( v_umo integer ) is select * from gallery_charge where umo_id = v_umo;
 cursor c14( acid integer, uscid integer ) is select spb from price_book_map where aid = acid and umo_scene_id = uscid;

 c11rec		c11%ROWTYPE;
 c12rec		c12%ROWTYPE;
 c13rec		c13%ROWTYPE;
 c14rec		c14%ROWTYPE;
 prec		shopping_basket%ROWTYPE;
 tmp		varchar2(32767);
 tmp1		varchar2(1000);
 tmp2		varchar2(1000);

 begin
 if is_bf(theme_rec,ltype,403,404,'T','T',402,'T')
  then
   htp.nl;

   -- Determine Price Book of Image
   open c12(umrec.umo_id);
   fetch c12 into c12rec;
   close c12;
   if umrec.umo_type = 'MANUFACTURER'
    then
     prec.phid := umrec.umo_id;
     prec.ppi := umrec.attribute6;
     prec.must_download := 'F';
     prec.isgallery := 'S';

   elsif  c12rec.pricing_structure = 'I' -- Individual Pricing then
    then
     open c13( umrec.umo_id );
     fetch c13 into c13rec;
     close c13;
     prec.phid := c13rec.umo_id;
     prec.photo_size := c13rec.charge_desc;
     prec.photo_cost := c13rec.charge;
     prec.must_download := 'F';
     prec.isgallery := 'I';

  else
     open c14( cusrec.aid, umrec.umo_scene_id );
     fetch c14 into c14rec;
     if c14%NOTFOUND
       then
       close c14;
       -- Not Found Price Book is the one for the account
        c14rec.spb := voidrec.spb;
      else
       close c14;
     end if;
     open c11( c14rec.spb );
     fetch c11 into c11rec;
     close c11;
     prec.photo_size := c11rec.photo_size;
     prec.photo_cost := c11rec.photo_cost;
     prec.must_download := 'F';
     prec.ppi := c11rec.ppi;
     prec.film_name := c11rec.film_name;
     prec.ppm_id := c11rec.lease_download_object;
     prec.ppm_id_limit := c11rec.limit_download_object;
     prec.lab_id := c11rec.lab_id;
     prec.manufctr_code := c11rec.manufctr_code;
     prec.isgallery := 'F';
   end if;

   -- Extra Price Book Details
   prec.phid := c12rec.umo_id;
   prec.film_type := c12rec.extra_film_colour;
   prec.qty := 1;
   prec.umo_type := c12rec.umo_type;
   prec.ftp_location := c12rec.ftp_location;
   prec.ftp_virtual_dir := c12rec.ftp_virtual_dir;
   prec.umo_film_name := c12rec.extras.film_name;
   prec.umo_photo_name := c12rec.extras.photo_name;
   prec.umo_width := c12rec.photo_thumbnail.width;
   prec.umo_height := c12rec.photo_thumbnail.height;
   prec.contentlength := dbms_lob.getlength(c12rec.photo_original.source.localdata);

   fname.determine_price_book_display( surl, cusrec.aid, voidrec, cusrec, prec, theme_rec, 'SUMMARY', ltype, pfx.qcbground, pfx.qcbground, tmp, tmp1, tmp2, is_local, umrec );
   htp.p( tmp );
 else
  htp.formhidden( 'PC', 'IU' || umrec.umo_id );
 end if;
end preselect_price;

procedure image_statistics( ltype in varchar2, theme_rec in theme_types%ROWTYPE, umrec in umo%ROWTYPE )
as
begin
   -- Image Statistics
   if is_bf(theme_rec,ltype,217,218,'T','T',282,'T')
    then
      htp.p( '<TD ' || ' valign="TOP" ALIGN="RIGHT">');
      htp.p( LNG.CST_TXT_042 || ':' || htf.bold( umrec.extras.title) || htf.nl ||
             LNG.PHG_TXT_338 || ':' || htf.strong( nvl(umrec.extra_roll_id,LNG2.FNM_TXT_004) ) || htf.nl ||
             LNG.PHG_TXT_356 || ':' || htf.strong( umrec.extras.film_name ) || htf.nl );
      if substr(theme_rec.theme_data,189,1) = 'T'
       then
        htp.p(LNG.PHG_TXT_357 || ':' || htf.strong( umrec.extra_roll_id ) || htf.nl);
      end if;
      if umrec.umo_type = 'PHOTO'
       then
         htp.p( LNG.PHG_TXT_193 || htf.bold(umrec.photo_master.width) || 'x' || htf.bold(umrec.photo_master.height) ||
	          LNG.PHG_TXT_156 || htf.bold(umrec.photo_master.contentlength) );
      elsif umrec.umo_type = 'DOCUMENT'
       then
         htp.p( LNG.PHG_TXT_228 || htf.bold(umrec.doc_mimetype) ||
	          LNG.PHG_TXT_156 || htf.bold(umrec.doc_length) );
      elsif umrec.umo_type = 'VIDEO'
       then
         htp.p( LNG.PHG_TXT_228 || htf.bold(umrec.video_original.mimetype) ||
	          LNG.PHG_TXT_156 || htf.bold(umrec.video_original.videoduration) );
      elsif umrec.umo_type = 'AUDIO'
       then
         htp.p( LNG.PHG_TXT_228 || htf.bold(umrec.audio_original.mimetype) ||
	          LNG.PHG_TXT_156 || htf.bold(umrec.audio_original.audioduration) );
	end if;
      htp.p( '</TD>');
   end if;
end image_statistics;

procedure disp_by_scene_vertical( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                  umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                  footer_api in varchar2, left_api_parm in varchar2, ctr in integer default 1, overdv in char default null, acid in integer default null, sess_id in integer,
                                  no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, extra_term in varchar2 default null,image_style in varchar2 )
as

cursor c8(v_umo integer) is
  select weighting, um.extras.photo_name photo_name, um.extras.film_name film_name, ul.to_umo_id
  from umo_link ul, umo um
  where ul.umo_id = v_umo and
        ul.to_umo_id = um.umo_id
  order by weighting desc;

cursor c9(v_umo integer) is
 select value
 from umo_attribute ua, umo_attributes uas
 where ua.umo_id = v_umo and
       ua.attribute_id = uas.attribute_id and
       sub_category = 'PHOTO ALBUM';


 c9rec			c9%ROWTYPE;
 lastpos		integer;
 phg_title		varchar2(100);
 upref			varchar2(100);
 prod_doco		varchar2(1000);
 hor_caption		varchar2(4000);
 vhor_caption		varchar2(4000);
 video_api		varchar2(1000);
 audio_api		varchar2(1000);
 relational_api		varchar2(1000);
 blueprint_api		varchar2(1000);
 document_api		varchar2(1000);
 backcol		varchar2(100);
 display_original	varchar2(100);
 tmp			varchar2(32767);
 tmp1			varchar2(1000);
 tmp2			varchar2(1000);
 is_local		boolean;
 newdt			number;
 dbool			boolean;
 empty_array		GLBX.MYARRAY;

begin

 -- The calling program should trap if no results are returned.
 if umrec.count = 0
  then
   glbx.header_msg( no_results_message );
   htp.htmlclose;
   return;
 end if;

 initialise_api_variables(surl, sess_id, ltype, 419, null, 418, cusrec, theme_rec, document_api, video_api, audio_api, relational_api, blueprint_api, upref, newdt, is_local, display_original, phg_title );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=3 border=0 ' );
 vhor_caption := glbx.userpref( cusrec.pid, cusrec.aid, 'TNAIL_PREF' );

 if nvl(pfx.vert_header,'T') = 'T'
  then
 -- Headings
     htp.tablerowopen;
     -- Choose Image
     if is_bf(theme_rec,ltype,186,187,'T','T',263,'T') and is_bf(theme_rec,ltype,210,211,'T','T',270,'T')
      then
       htp.tabledata(htf.bold(LNG.CST_TXT_187),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     end if;
     -- Thumbnail
     if is_bf(theme_rec,ltype,212,213,'T','T',271,'T') or is_bf(theme_rec,ltype,8,214,'T','T',272,'T')
      then
       htp.tabledata(htf.bold(lng.GLB_TXT_064),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     end if;
     -- Image Caption
     if is_bf(theme_rec,ltype,200,201,'T','T',274,'T')
      then
        htp.tabledata(htf.bold(LNG4.AHC_TXT_381),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     end if;
     if footer_api <> 'cst.disp_store'
      then
       /*
       -- Who is in Photo
       if is_bf(theme_rec,ltype,162,163,'F','F',275,'T') and is_bf(theme_rec,ltype,36,48,'T','T',276,'T')
        then
         htp.tabledata(htf.bold(lng.CST_TXT_050),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
       end if;
       -- Comments
       if is_bf(theme_rec,ltype,162,163,'T','T',275,'T') or is_bf(theme_rec,ltype,35,47,'T','T',277,'T')
        then
         htp.tabledata(htf.bold(glbx.userpref( cusrec.pid, cusrec.aid, 'COMMENT' )),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
       end if;
       */
       -- Is Photo Album
       if is_bf(theme_rec,ltype,38,215,'T','T',278,'T')
        then
         htp.tabledata(htf.bold(LNG.CST_TXT_052),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
       end if;

       -- Enabled Guest
       if is_bf(theme_rec,ltype,37,216,'T','T',279,'T')
        then
          htp.tabledata(htf.bold(LNG.CST_TXT_053),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
       end if;

     end if;

     -- Meta Tag
     if is_bf(theme_rec,ltype,90,91,'T','T',280,'T')
      then
         htp.tabledata(htf.bold(lng.CST_TXT_012),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     end if;

     -- See Also
     if is_bf(theme_rec,ltype,126,127,'T','T',281,'T')
      then
         htp.tabledata(htf.bold(lng2.PBK_TXT_090),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     end if;

     -- Image Statistics
     if is_bf(theme_rec,ltype,217,218,'T','T',282,'T')
      then
         htp.tabledata(htf.bold(lng4.AHC_TXT_408),cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"');
     end if;

    htp.tablerowclose;
 end if;

 for j in umrec.first..umrec.last loop

  htp.tablerowopen;

  if mod(j,2) = 0
   then
    backcol := 'bgcolor="#' || nvl(pfx.vert_colour_a,glbx.QUERY_CELL_BACKGROUND1) || '"';
   else
    backcol := 'bgcolor="#' || nvl(pfx.vert_colour_b,glbx.QUERY_CELL_BACKGROUND2) || '"';
  end if;


  if is_bf(theme_rec,ltype,186,187,'T','T',263,'T') and is_bf(theme_rec,ltype,210,211,'T','T',270,'T')
   then
    if umrec(j).umo_type = 'MANUFACTURER'
     then
      htp.tabledata( htf.formhidden( 'P0', umrec(j).umo_id ) || htf.formcheckbox( 'P1', 'S' || umrec(j).extras.quality ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
       -- Check for Out of Stock Option
       if (umrec(j).attribute3 is null or umrec(j).attribute1 is null) or (to_number(umrec(j).attribute3) >= to_number(umrec(j).attribute1))
        then
         -- If Stock level is null or value to check is null then it is traditional behaviour or if there is sufficient stock
         htp.tabledata( htf.formcheckbox( 'P1', 'S' || umrec(j).extras.quality ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
       elsif to_number(umrec(j).attribute3) < to_number(umrec(j).attribute1)
        then
         -- If mfctr stock less is less than what is requested
         if umrec(j).attribute2 = 'T' -- Item can still be purchased
          then
           htp.tabledata( htf.formcheckbox( 'P1', 'S' || umrec(j).extras.quality ) || htf.nl || umrec(j).attribute4 ,cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
          else
           htp.tabledata( umrec(j).attribute4 ,cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
         end if;
       end if;
     else
      htp.tabledata( htf.formhidden( 'P0', umrec(j).umo_id ) || htf.formcheckbox( 'P1', umrec(j).umo_id ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
    end if;
  end if;

   if umrec(j).umo_type = 'MANUFACTURER'
    then
      manufacturer_object(surl, ltype, 195, 196, 273, 212, 213, 271, pfx, theme_rec, umrec(j));

   else

     if is_bf(theme_rec,ltype,212,213,'T','T',271,'T') or is_bf(theme_rec,ltype,8,214,'T','T',272,'T')
      then
       htp.p( '<TD ' || backcol || 'valign="MIDDLE" align="CENTER" CLASS="SMALL">' );
       htp.p( small_above_thumbnail(surl, acid, ltype, newdt, pfx, umrec(j), phg_title) || htf.nl);
       if is_bf(theme_rec,ltype,212,213,'T','T',271,'T')
        then
          hor_caption := replace(replace(vhor_caption,'~CAPTION',umrec(j).image_caption),'~NAME', umrec(j).extras.photo_name);
          display_thumbnail(surl,ltype,umrec(j),theme_rec,pfx,footer_api,left_api_parm,ctr,overdv,hor_caption,document_api,video_api,audio_api,relational_api,blueprint_api,acid,display_original,stype,extra_term,image_style);
       end if;
        if is_bf(theme_rec,ltype,8,214,'T','T',272,'T')
         then
          if ltype = 'PHOTOGRAPHER'
           then
            htp.p( htf.nl || htf.formtext('PPN',20,100,umrec(j).extras.film_name) );
           else
            htp.p( htf.nl || htf.formtext('PPN',20,100,umrec(j).extras.photo_name) );
          end if;
         else
          if is_bf(theme_rec,ltype,416,417,'T','T',415,'T')
           then
            if ltype = 'PHOTOGRAPHER'
             then
              if umrec(j).extras.film_name = umrec(j).extras.photo_name
               then
                htp.p( htf.nl || htf.bold(umrec(j).extras.film_name) || htf.formhidden( 'PPN', null ));
               else
                htp.p( htf.nl || htf.bold(umrec(j).extras.film_name || htf.nl || htf.italic(umrec(j).extras.photo_name)) || htf.formhidden( 'PPN', null ));
              end if;
             else
              htp.p( htf.nl || htf.bold(umrec(j).extras.photo_name) || htf.formhidden( 'PPN', null ));
            end if;
          end if;
        end if;
        if is_bf(theme_rec,ltype,382,383,'T','T',381,'T')
         then
          htp.p( htf.nl || '#' || htf.bold(umrec(j).extras.orderby_nmb));
        end if;
     end if;

     preselect_price(surl, ltype, is_local, cusrec, pfx, theme_rec, umrec(j), voidrec );
     htp.p( '</TD>' );
    end if;

   -- See Caption
   if is_bf(theme_rec,ltype,200,201,'T','T',274,'T')
      then
        htp.tabledata(nvl(umrec(j).image_caption,'&nbsp;'),cattributes=>backcol || ' valign="TOP" align="LEFT" STYLE="font-family: ' || pfx.caption_text_font || '; color: #' || pfx.caption_text_colour || '"');
   end if;

   if footer_api <> 'cst.disp_store'
    then
     /*
     -- Who is in the Image
     if is_bf(theme_rec,ltype,162,163,'F','F',275,'T') and is_bf(theme_rec,ltype,36,48,'T','T',276,'T')
      then
       htp.p( '<TD ' || backcol || 'valign="TOP" align="CENTER" CLASS="SMALL">' );
        htp.tableopen;
         htp.tablerowopen;
          display_who(surl, ltype, theme_rec, umrec(j).umo_id, 162, 163, 275, 36, 48, 276, footer_api, left_api_parm, ctr, overdv, acid, 'BP' );
         htp.tablerowclose;
        htp.tableclose;
       htp.p( '</TD>' );
     end if;

     -- Comment
     if is_bf(theme_rec,ltype,162,163,'T','T',275,'T') or is_bf(theme_rec,ltype,35,47,'T','T',277,'T')
      then
       htp.p( '<TD ' || backcol || 'valign="TOP" align="CENTER" CLASS="SMALL">' );
        htp.tableopen;
         htp.tablerowopen;
          display_comments(surl,umrec(j), theme_rec, cusrec, ltype, 35, 47, 162, 163, 275, 277, backcol, footer_api, left_api_parm, ctr, overdv, acid, 'BP' );
        htp.tablerowclose;
       htp.tableclose;
       htp.p( '</TD>' );
     end if;
     */

     -- Album Enabled
     if is_bf(theme_rec,ltype,38,215,'T','T',278,'T')
      then
        -- Open Cursor to extract Meta Tag Value to see if it is enabled
        c9rec.value := NULL;
        open c9(umrec(j).umo_id);
        fetch c9 into c9rec;
        close c9;
        if nvl(c9rec.value,'FALSE') = 'TRUE'
         then
           htp.tabledata( htf.formcheckbox( 'PA', umrec(j).umo_id, 'CHECKED' ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
         else
           htp.tabledata( htf.formcheckbox( 'PA', umrec(j).umo_id ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
        end if;
      else
       htp.formhidden( 'PA',null );
     end if;

     -- Image Enabled
     if is_bf(theme_rec,ltype,37,216,'T','T',279,'T')
      then
       if ltype = 'PHOTOGRAPHER'
        then
         if umrec(j).extras.enabled_phg = 'TRUE'
	   then
	    htp.tabledata( htf.formcheckbox( 'PB', umrec(j).umo_id, 'CHECKED' ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
	   else
	    htp.tabledata( htf.formcheckbox( 'PB', umrec(j).umo_id ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
         end if;
        else
         if umrec(j).extras.enabled_cus = 'TRUE'
	   then
	    htp.tabledata( htf.formcheckbox( 'PB', umrec(j).umo_id, 'CHECKED' ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
	   else
	    htp.tabledata( htf.formcheckbox( 'PB', umrec(j).umo_id ),cattributes=>backcol || 'valign="MIDDLE" align="CENTER"' );
         end if;
       end if;
     else
      htp.formhidden( 'PB',umrec(j).umo_id );
     end if;

  end if;

   -- Meta Tags
   if is_bf(theme_rec,ltype,90,91,'T','T',280,'T')
    then
      htp.p( '<TD ' || backcol || ' valign="TOP" ALIGN="LEFT">');
       dbool := glbx.disp_mt(surl, ltype, umrec(j).umo_id, umrec(j).umo_type, substr(theme_rec.theme_data,167,1), pfx, acid, empty_array, TRUE);
      htp.p('</TD>' );
   end if;

   -- See Also
   if is_bf(theme_rec,ltype,126,127,'T','T',281,'T')
    then
      htp.p( '<TD ' || backcol || ' valign="TOP" ALIGN="LEFT">');
      for c8rec in c8( umrec(j).umo_id ) loop
       htp.p( glbx.linkdisp( surl, umrec(j).umo_id, c8rec.to_umo_id, c8rec.weighting, upref, c8rec.film_name, c8rec.photo_name, stype, acid ) );
       htp.nl;
      end loop;
      htp.p('&nbsp;</TD>' );
   end if;

  image_statistics(ltype, theme_rec, umrec(j));

  htp.tablerowclose;

 end loop;

 htp.tableclose;

exception when others then
 glbx.error_details( 'CST', 'DISP_BY_SCENE_VERTICAL',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end disp_by_scene_vertical;

procedure disp_by_scene_simple_vertical( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                  umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                  footer_api in varchar2, left_api_parm in varchar2, ctr in integer default 1, overdv in char default null, acid in integer default null, sess_id in integer,
                                  no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, extra_term in varchar2 default null,image_style in varchar2 )
as

cursor c8(v_umo integer) is
  select weighting, um.extras.photo_name photo_name, um.extras.film_name film_name, ul.to_umo_id
  from umo_link ul, umo um
  where ul.umo_id = v_umo and
        ul.to_umo_id = um.umo_id
  order by weighting desc;

cursor c9(v_umo integer) is
 select value
 from umo_attribute ua, umo_attributes uas
 where ua.umo_id = v_umo and
       ua.attribute_id = uas.attribute_id and
       sub_category = 'PHOTO ALBUM';

 c9rec			c9%ROWTYPE;
 lastpos		integer;
 phg_title		varchar2(100);
 upref			varchar2(100);
 prod_doco		varchar2(1000);
 video_api		varchar2(1000);
 audio_api		varchar2(1000);
 relational_api		varchar2(1000);
 blueprint_api		varchar2(1000);
 document_api		varchar2(1000);
 display_original	varchar2(100);
 temp			varchar2(32767);
 tmp			varchar2(32767);
 tmp1			varchar2(1000);
 tmp2			varchar2(1000);
 is_local		boolean;
 newdt			number;
 dbool			boolean;
 empty_array		GLBX.MYARRAY;

begin

 -- The calling program should trap if no results are returned.
 if umrec.count = 0
  then
   glbx.header_msg( no_results_message );
   htp.htmlclose;
   return;
 end if;

 initialise_api_variables(surl, sess_id, ltype, 419, null, 418, cusrec, theme_rec, document_api, video_api, audio_api, relational_api, blueprint_api, upref, newdt, is_local, display_original, phg_title );

 htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=2 border=1 frame="VOID" rules="ROWS"' );

 for j in umrec.first..umrec.last loop

   htp.tablerowopen;

   htp.formhidden( 'P0', umrec(j).umo_id );

   if umrec(j).umo_type = 'MANUFACTURER'
    then
      manufacturer_object(surl, ltype, 195, 196, 273, 212, 213, 271, pfx, theme_rec, umrec(j));

    else

     if is_bf(theme_rec,ltype,212,213,'T','T',271,'T') or is_bf(theme_rec,ltype,8,214,'T','T',272,'T')
      then
       htp.p( '<TD ' || 'valign="TOP" align="LEFT" CLASS="SMALL">' );
       htp.p( small_above_thumbnail(surl, acid, ltype, newdt, pfx, umrec(j), phg_title) || htf.nl);
       if is_bf(theme_rec,ltype,212,213,'T','T',271,'T')
        then
          display_thumbnail(surl,ltype,umrec(j),theme_rec,pfx,footer_api,left_api_parm,ctr,overdv,umrec(j).image_caption,document_api,video_api,audio_api,relational_api,blueprint_api,acid,display_original,stype,extra_term,image_style);
       end if;
     end if;

     preselect_price(surl, ltype, is_local, cusrec, pfx, theme_rec, umrec(j), voidrec );
     htp.p( '</TD>' );
    end if;

    htp.p( '<TD ' || 'valign="TOP" align="LEFT" CLASS="SMALL">' );
    if is_bf(theme_rec,ltype,8,214,'T','T',272,'T')
     then
      if ltype = 'PHOTOGRAPHER'
       then
        htp.p( htf.nl || htf.formtext('PPN',20,100,umrec(j).extras.film_name) );
       else
        htp.p( htf.nl || htf.formtext('PPN',20,100,umrec(j).extras.photo_name) );
      end if;
     else
      if is_bf(theme_rec,ltype,416,417,'T','T',415,'T')
       then
        if ltype = 'PHOTOGRAPHER'
         then
          if umrec(j).extras.film_name = umrec(j).extras.photo_name
           then
            htp.p( htf.nl || htf.bold(umrec(j).extras.film_name) || htf.formhidden( 'PPN', null ));
           else
            htp.p( htf.nl || htf.bold(umrec(j).extras.film_name || htf.nl || htf.italic(umrec(j).extras.photo_name)) || htf.formhidden( 'PPN', null ));
          end if;
         else
          htp.p( htf.nl || htf.bold(umrec(j).extras.photo_name) || htf.formhidden( 'PPN', null ));
        end if;
      end if;
    end if;

    if is_bf(theme_rec,ltype,382,383,'T','T',381,'T')
     then
      htp.p( htf.nl || '#' || htf.bold(umrec(j).extras.orderby_nmb));
    end if;
    htp.p( '</TD>' );

   if footer_api <> 'cst.disp_store'
    then

     htp.p( '<TD width="20%" valign="TOP" align="CENTER" CLASS="SMALL">' );
     /*
     -- Who is in the Image
     if is_bf(theme_rec,ltype,162,163,'F','F',275,'T') and is_bf(theme_rec,ltype,36,48,'T','T',276,'T')
      then
        htp.tableopen;
         htp.tablerowopen;
          display_who(surl, ltype, theme_rec, umrec(j).umo_id, 162, 163, 275, 36, 48, 276, footer_api, left_api_parm, ctr, overdv, acid, 'BP' );
         htp.tablerowclose;
        htp.tableclose;
        htp.nl;
     end if;

     -- Comment
     if is_bf(theme_rec,ltype,162,163,'T','T',275,'T') or is_bf(theme_rec,ltype,35,47,'T','T',277,'T')
      then
        htp.tableopen;
         htp.tablerowopen;
          display_comments(surl,umrec(j), theme_rec, cusrec, ltype, 35, 47, 162, 163, 275, 277, null, footer_api, left_api_parm, ctr, overdv, acid, 'BP' );
        htp.tablerowclose;
       htp.tableclose;
     end if;
     */
     htp.p( '</TD>' );

   end if;

   -- Check Box Options
   htp.p( '<TD width="20%" valign="TOP" align="LEFT" CLASS="SMALL">' );
   htp.tableopen( cattributes=>'cellspacing=1 cellpadding=1 border=0' );
   if is_bf(theme_rec,ltype,186,187,'T','T',263,'T') and is_bf(theme_rec,ltype,210,211,'T','T',270,'T')
    then
     if umrec(j).umo_type = 'MANUFACTURER'
      then
       htp.tablerowopen;
        htp.tabledata(htf.formcheckbox( 'P1', 'S' || umrec(j).extras.quality ));
        htp.tabledata( LNG.CST_TXT_187, cattributes=>'align="LEFT" CLASS="SMALL"' );
       htp.tablerowclose;
     else
       htp.tablerowopen;
        htp.tabledata(htf.formcheckbox( 'P1', umrec(j).umo_id ));
        htp.tabledata( LNG.CST_TXT_187, cattributes=>'align="LEFT" CLASS="SMALL"' );
       htp.tablerowclose;
     end if;
   end if;

   -- Album Enabled
   if is_bf(theme_rec,ltype,38,215,'T','T',278,'T')
    then
      -- Open Cursor to extract Meta Tag Value to see if it is enabled
      c9rec.value := NULL;
      open c9(umrec(j).umo_id);
      fetch c9 into c9rec;
      close c9;
      if nvl(c9rec.value,'FALSE') = 'TRUE'
       then
        htp.tablerowopen;
         htp.tabledata(htf.formcheckbox( 'PA', umrec(j).umo_id, 'CHECKED' ));
         htp.tabledata( LNG.CST_TXT_052, cattributes=>'align="LEFT" CLASS="SMALL"' );
        htp.tablerowclose;
       else
        htp.tablerowopen;
         htp.tabledata(htf.formcheckbox( 'PA', umrec(j).umo_id ));
         htp.tabledata( LNG.CST_TXT_052, cattributes=>'align="LEFT" CLASS="SMALL"' );
        htp.tablerowclose;
      end if;
    else
     htp.formhidden( 'PA',null );
   end if;

   -- Image Enabled
   if is_bf(theme_rec,ltype,37,216,'T','T',279,'T')
    then
     if ltype = 'PHOTOGRAPHER'
      then
       if umrec(j).extras.enabled_phg = 'TRUE'
	   then
            htp.tablerowopen;
	     htp.tabledata(htf.formcheckbox( 'PB', umrec(j).umo_id, 'CHECKED' ));
             htp.tabledata( LNG.CST_TXT_053, cattributes=>'align="LEFT" CLASS="SMALL"' );
            htp.tablerowclose;
	   else
            htp.tablerowopen;
	     htp.tabledata(htf.formcheckbox( 'PB', umrec(j).umo_id ));
             htp.tabledata( LNG.CST_TXT_053, cattributes=>'align="LEFT" CLASS="SMALL"' );
            htp.tablerowclose;
       end if;
      else
       if umrec(j).extras.enabled_cus = 'TRUE'
	   then
            htp.tablerowopen;
	     htp.tabledata(htf.formcheckbox( 'PB', umrec(j).umo_id, 'CHECKED' ));
             htp.tabledata( LNG.CST_TXT_053, cattributes=>'align="LEFT" CLASS="SMALL"' );
            htp.tablerowclose;
	   else
            htp.tablerowopen;
	     htp.tabledata(htf.formcheckbox( 'PB', umrec(j).umo_id ));
             htp.tabledata( LNG.CST_TXT_053, cattributes=>'align="LEFT" CLASS="SMALL"' );
            htp.tablerowclose;
       end if;
     end if;
   else
    htp.formhidden( 'PB',umrec(j).umo_id );
   end if;
   htp.tableclose;
   htp.p( '</TD>' );

   -- See Also
   if is_bf(theme_rec,ltype,126,127,'T','T',281,'T')
    then
      htp.p( '<TD ' || ' valign="TOP" ALIGN="CENTER">');
      for c8rec in c8( umrec(j).umo_id ) loop
       htp.p( glbx.linkdisp( surl, umrec(j).umo_id, c8rec.to_umo_id, c8rec.weighting, upref, c8rec.film_name, c8rec.photo_name, stype, acid ) );
       htp.nl;
      end loop;
      htp.p('&nbsp;</TD>' );
   end if;

   image_statistics(ltype, theme_rec, umrec(j));

   -- Meta Tags
   if is_bf(theme_rec,ltype,90,91,'T','T',280,'T')
    then
      htp.p( '<TD ' || ' valign="TOP" ALIGN="RIGHT">');
       dbool := glbx.disp_mt(surl, ltype, umrec(j).umo_id, umrec(j).umo_type, substr(theme_rec.theme_data,167,1), pfx, acid, empty_array);
      htp.p('</TD>' );
   end if;

  htp.tablerowclose;

 end loop;

 htp.tableclose;

exception when others then
 glbx.error_details( 'CST', 'DISP_BY_SCENE_SIMPLE_VERTICAL',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end disp_by_scene_simple_vertical;

procedure disp_by_scene_horizontal( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                    umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                    footer_api in varchar2, ctr in integer default 1, overdv in char default null,
                                    left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                    no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, extra_term in varchar2 default null,image_style in varchar2)
as

cursor c9(v_umo integer) is
 select value
 from umo_attribute ua, umo_attributes uas
 where ua.umo_id = v_umo and
       ua.attribute_id = uas.attribute_id and
       sub_category = 'PHOTO ALBUM';

 c9rec			c9%ROWTYPE;
 foundrec		boolean;
 jctr			integer;
 phg_title		varchar2(100);
 upref			varchar2(100);
 prod_doco		varchar2(1000);
 hor_caption		varchar2(4000);
 vhor_caption		varchar2(4000);
 verttemp		varchar2(32767);
 temp			varchar2(32767);
 mt			varchar2(32767);
 hor_but		varchar2(4000);
 video_api		varchar2(1000);
 audio_api		varchar2(1000);
 relational_api		varchar2(1000);
 blueprint_api		varchar2(1000);
 document_api		varchar2(1000);
 display_original	varchar2(100);
 tmp			varchar2(32767);
 tmp1			varchar2(1000);
 tmp2			varchar2(1000);
 is_local		boolean;
 newdt			number;
 mxwidth		integer;
 mxheight		integer;
 screen_width		integer;
 url			varchar2(4000);

begin

 -- The calling program should trap if no results are returned.
 if umrec.count = 0
  then
   glbx.header_msg( no_results_message );
   htp.htmlclose;
   return;
 end if;

 initialise_api_variables(surl, sess_id, ltype, 421, null, 420, cusrec, theme_rec, document_api, video_api, audio_api, relational_api, blueprint_api, upref, newdt, is_local, display_original, phg_title );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=3 border=0 ' );
 jctr := 1;
 vhor_caption := glbx.userpref( cusrec.pid, cusrec.aid, 'TNAIL_PREF' );
 screen_width := glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype);

 for j in umrec.first..umrec.last loop

   -- and for horizintal buttons the contentlength is checked not the actual object length, so don't forget to change it.
   -- and product documentation is stored in document_original_loc
   -- and audio_locaiton
  if jctr = 1
    then
     htp.tablerowopen;
    elsif (mod(jctr, screen_width) = 1 or screen_width=1)
     then
      htp.tablerowclose;
      htp.tablerowopen;
  end if;
  jctr := jctr + 1;

  if pfx.tnail_global_border = 'T'
   then
    -- Calculate maximum width and height for box display
    mxwidth := 0;
    mxheight := 0;
    for j in umrec.first..umrec.last loop
     if umrec(j).photo_thumbnail.width > mxwidth then mxwidth := umrec(j).photo_thumbnail.width; end if;
     if umrec(j).photo_thumbnail.height > mxheight then mxheight := umrec(j).photo_thumbnail.height; end if;
    end loop;
    mxwidth := mxwidth + nvl(pfx.tnail_global_spacer,0);
    mxheight := mxheight + nvl(pfx.tnail_global_spacer,0) + 75;
    if ltype = 'PHOTOGRAPHER' then mxheight := mxheight + 50; end if; -- Add more for a photographer
    htp.p( '<TD valign="BOTTOM" align="CENTER">' );
    htp.tableopen( cattributes=>'cellspacing=0 border=0' );
    --htp.tableopen( cattributes=>'cellpadding=' || pfx.tnail_global_spacer || ' cellspacing=0 border=0' );
    htp.tablerowopen;
    htp.p( '<TD valign="MIDDLE" align="CENTER" BGCOLOR="#' || pfx.tnail_global_colour || '">' );
    htp.tableopen( cattributes=>'cellpadding=' || pfx.tnail_global_offset || ' cellspacing=0 border=0' );
    htp.tablerowopen;
  end if;

  /*
  if cusrec.background_img is null
   then
    htp.p( '<TD valign="BOTTOM" align="LEFT" CLASS="SMALL" BGCOLOR="#' || pfx.text_back || '">' );
   else
    htp.p( '<TD valign="BOTTOM" align="LEFT" CLASS="SMALL" ' ||
           'BACKGROUND="ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || cusrec.background_img || '&parm1=DISPLAY_TYPE&parm2=RAW' ||
           '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '">' );
  end if;
  */
  htp.p( '<TD valign="BOTTOM" align="LEFT" CLASS="SMALL" BGCOLOR="#' || pfx.text_back || '" style="width: ' || mxwidth || 'px; height: ' || mxheight || 'px; ">' );
  htp.formhidden( 'P0', umrec(j).umo_id );

  if umrec(j).umo_type in ('PHOTO','MANUFACTURER','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT')
   then

     mt := horizontal_meta_tags(surl, ltype, 221, 222, 284, theme_rec, umrec(j));
     if umrec(j).umo_type = 'MANUFACTURER'
      then
        manufacturer_object(surl, ltype, 223, 224, 285, 225, 226, 286, pfx, theme_rec, umrec(j),FALSE);

     else

      small_buttons(surl, ltype, cusrec, umrec(j), pfx, theme_rec, voidrec, footer_api, left_api_parm, lbox, cusloc, overdv, ctr, acid, hor_but, overdv, display_original,stype,extra_term );

      -- Determine if Image Caption is to be displayed in Balloon Help
      hor_caption := replace(replace(vhor_caption,'~CAPTION',umrec(j).image_caption),'~NAME', umrec(j).extras.photo_name);
      /*
      if is_bf(theme_rec,ltype,227,228,'T','T',289,'T')
       then
         hor_caption := nvl(umrec(j).image_caption,LNG.CST_TXT_183 || ' (' || umrec(j).extras.photo_name || ')');
       else
         hor_caption := LNG.CST_TXT_183 || ' (' || umrec(j).extras.photo_name || ')';
      end if;
      */

      temp := small_above_thumbnail(surl, acid, ltype, newdt, pfx, umrec(j), phg_title);
      -- Display Image Name
      if is_bf(theme_rec,ltype,93,188,'T','T',287,'T')
       then
        -- If the Image Name can be edited then do not display it
        if is_bf(theme_rec,ltype,229,230,'T','T',290,'T')
         then
          if mt is not null
           then
            temp := mt || htf.nl || temp;
          end if;

         else

            if ltype = 'PHOTOGRAPHER'
             then
              if umrec(j).extras.film_name = umrec(j).extras.photo_name
               then
                if is_bf(theme_rec,ltype,379,380,'T','T',378,'T')
                 then
                  temp := htf.bold(umrec(j).extras.film_name) || mt || '#' || umrec(j).extras.orderby_nmb || htf.nl || temp;
                 else
                  temp := htf.bold(umrec(j).extras.film_name) || mt || htf.nl || temp;
                end if;
               else
                if is_bf(theme_rec,ltype,379,380,'T','T',378,'T')
                 then
                  temp := htf.bold(umrec(j).extras.film_name) || htf.nl || htf.italic(umrec(j).extras.photo_name) || mt || '#' || umrec(j).extras.orderby_nmb || temp;
                 else
                  temp := htf.bold(umrec(j).extras.film_name) || htf.nl || htf.italic(umrec(j).extras.photo_name) || mt || htf.nl || temp;
                end if;
              end if;
             else
              if is_bf(theme_rec,ltype,379,380,'T','T',378,'T')
               then
                temp := htf.bold(umrec(j).extras.photo_name) || mt || '#' || umrec(j).extras.orderby_nmb || temp;
               else
                temp := htf.bold(umrec(j).extras.photo_name) || mt || htf.nl || temp;
              end if;
            end if;
          end if;

       else
        if mt is not null
         then
          temp := mt || htf.nl || temp;
        end if;
      end if;

      htp.p( '<CENTER>' );
      htp.p( temp );

      -- Display Thumbnail
      if is_bf(theme_rec,ltype,225,226,'T','T',286,'T')
       then
         display_thumbnail(surl,ltype,umrec(j),theme_rec,pfx,footer_api,left_api_parm,ctr,overdv,hor_caption,document_api,video_api,audio_api,relational_api,blueprint_api,acid,display_original,stype,extra_term,image_style);
      end if;
      htp.p( '</CENTER>' );
      -- Edit Image Name
      if is_bf(theme_rec,ltype,229,230,'T','T',290,'T')
       then
        if ltype = 'PHOTOGRAPHER'
         then
          htp.p( hor_but || htf.formtext('PPN',20,100,umrec(j).extras.film_name) || htf.nl || htf.italic(umrec(j).extras.photo_name) );
         else
          htp.p( hor_but || htf.formtext('PPN',20,100,umrec(j).extras.photo_name));
        end if;
       else
       htp.p( hor_but || htf.formhidden( 'PPN', null ));
      end if;

    end if; -- End If umorec = MANUFACTURER
  end if;

  /*
  -- Add Name
  if is_bf(theme_rec,ltype,231,232,'T','T',291,'T') and (umrec(j).umo_type <> 'MANUFACTURER') and is_bf(theme_rec,ltype,233,234,'F','F',292,'T')
   then
      htp.p( htf.nl || htf.anchor('cst.add_name?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || overdv || '&acid=' || acid, LNG.CST_TXT_133));
  end if;

  -- Comment
  if is_bf(theme_rec,ltype,235,236,'T','T',293,'T') and (umrec(j).umo_type <> 'MANUFACTURER') and is_bf(theme_rec,ltype,233,234,'F','F',292,'T')
   then
      htp.p( htf.nl || htf.anchor('cst.add_comment?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || overdv || '&acid=' || acid, lng.CST_TXT_055));
  end if;
  */

  -- Choose Image
  if is_bf(theme_rec,ltype,186,187,'T','T',263,'T') and is_bf(theme_rec,ltype,219,220,'T','T',283,'T')
   then
     if umrec(j).umo_type = 'MANUFACTURER'
      then
       -- Check for Out of Stock Option
       if (umrec(j).attribute3 is null or umrec(j).attribute1 is null) or (to_number(umrec(j).attribute3) >= to_number(umrec(j).attribute1))
        then
         -- If Stock level is null or value to check is null then it is traditional behaviour or if there is sufficient stock
         htp.p( htf.nl || htf.formcheckbox( 'P1', 'S' || umrec(j).extras.quality ) || LNG.CST_TXT_201);
       elsif to_number(umrec(j).attribute3) < to_number(umrec(j).attribute1)
        then
         -- If mfctr stock less is less than what is requested
         if umrec(j).attribute2 = 'T' -- Item can still be purchased
          then
           htp.p( htf.nl || htf.formcheckbox( 'P1', 'S' || umrec(j).extras.quality ) || LNG.CST_TXT_201 || htf.nl || umrec(j).attribute4);
          else
           htp.p( htf.nl || umrec(j).attribute4);
         end if;
       end if;
      else
       htp.p( htf.nl || htf.formcheckbox( 'P1', umrec(j).umo_id ) || LNG.CST_TXT_201);
     end if;
  end if;

  if is_bf(theme_rec,ltype,237,238,'T','T',294,'T') and umrec(j).umo_type <> 'MANUFACTURER' then
    -- Open Cursor to extract Meta Tag Value to see if it is enabled
    -- Photo Album
    c9rec.value := NULL;
    open c9(umrec(j).umo_id);
    fetch c9 into c9rec;
    close c9;
    if nvl(c9rec.value,'FALSE') = 'TRUE'
     then
      htp.p( htf.nl || htf.formcheckbox( 'PA', umrec(j).umo_id, 'CHECKED' ) || LNG.CST_TXT_202);
     else
      htp.p( htf.nl || htf.formcheckbox( 'PA', umrec(j).umo_id ) || LNG.CST_TXT_202);
    end if;
  else
   htp.formhidden( 'PA',null );
  end if;

  -- Enable Photographer (depends on Photographer or customer)
  if is_bf(theme_rec,ltype,239,240,'T','T',295,'T') and umrec(j).umo_type <> 'MANUFACTURER' then
   if ltype = 'PHOTOGRAPHER'
    then
     if umrec(j).extras.enabled_phg = 'TRUE'
      then
       htp.p( htf.nl || htf.formcheckbox( 'PB', umrec(j).umo_id, 'CHECKED' ) || LNG.CST_TXT_203);
      else
        htp.p( htf.nl ||htf.formcheckbox( 'PB', umrec(j).umo_id ) || LNG.CST_TXT_203);
     end if;
    else
     if umrec(j).extras.enabled_cus = 'TRUE'
      then
       htp.p( htf.nl || htf.formcheckbox( 'PB', umrec(j).umo_id, 'CHECKED' ) || LNG.CST_TXT_203);
      else
        htp.p( htf.nl ||htf.formcheckbox( 'PB', umrec(j).umo_id ) || LNG.CST_TXT_203);
     end if;
   end if;
  else
   htp.formhidden( 'PB',umrec(j).umo_id );
  end if;

  preselect_price(surl, ltype, is_local, cusrec, pfx, theme_rec, umrec(j), voidrec );

  htp.p( '</TD>' );

  if pfx.tnail_global_border = 'T'
   then
    htp.tablerowclose;
    htp.tableclose;
    htp.tablerowclose;
    htp.tableclose;
    htp.p( '</TD>' );
  end if;

 end loop;
 htp.tableclose;

exception when others then
 glbx.error_details( 'CST', 'DISP_BY_SCENE_HORIZONTAL',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end disp_by_scene_horizontal;

procedure disp_by_scene_slider( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                footer_api in varchar2, current_page_number in integer default 1, display_detail in char default null,
                                left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, extra_term in varchar2 default null,image_style in varchar2)
as

 numb_tnails		integer;
 numb_tnails_sml	integer;

begin

-- The pfx.slider_style determines the screen style
-- The pfx.slider_choice determines what gets displayed

numb_tnails := glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype);
numb_tnails_sml := greatest(round(glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype)/2),2);

if pfx.slider_style = '1'
 then
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
    if substr(pfx.slider_choice,1,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'R' );
    elsif substr(pfx.slider_choice,1,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails, extra_term, image_style );
    elsif substr(pfx.slider_choice,1,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
    if substr(pfx.slider_choice,2,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'R' );
    elsif substr(pfx.slider_choice,2,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails, extra_term, image_style );
    elsif substr(pfx.slider_choice,2,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

elsif pfx.slider_style = '2'
 then
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
    if substr(pfx.slider_choice,1,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'B' );
    elsif substr(pfx.slider_choice,1,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
    elsif substr(pfx.slider_choice,1,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
    end if;
    htp.p( '</TD>' );
    htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
    if substr(pfx.slider_choice,2,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'B' );
    elsif substr(pfx.slider_choice,2,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
    elsif substr(pfx.slider_choice,2,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

elsif pfx.slider_style = '3'
 then
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
    if substr(pfx.slider_choice,1,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'B' );
    elsif substr(pfx.slider_choice,1,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
    elsif substr(pfx.slider_choice,1,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
    end if;
    htp.p( '</TD>' );
    htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
     htp.tablerowopen;
      htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
      if substr(pfx.slider_choice,2,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'R' );
      elsif substr(pfx.slider_choice,2,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
      elsif substr(pfx.slider_choice,2,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
      end if;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
      if substr(pfx.slider_choice,3,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'R' );
      elsif substr(pfx.slider_choice,3,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
      elsif substr(pfx.slider_choice,3,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
      end if;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

elsif pfx.slider_style = '4'
 then
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
    htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
     htp.tablerowopen;
      htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
      if substr(pfx.slider_choice,1,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'R' );
      elsif substr(pfx.slider_choice,1,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
      elsif substr(pfx.slider_choice,1,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
      end if;
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tablerowopen;
      htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
      if substr(pfx.slider_choice,2,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'R' );
      elsif substr(pfx.slider_choice,2,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
      elsif substr(pfx.slider_choice,2,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
      end if;
      htp.p( '</TD>' );
     htp.tablerowclose;
    htp.tableclose;
    htp.p( '</TD>' );
    htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
    if substr(pfx.slider_choice,3,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'B' );
    elsif substr(pfx.slider_choice,3,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
    elsif substr(pfx.slider_choice,3,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

elsif pfx.slider_style = '5'
 then
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.p( '<TD align="CENTER" valign="TOP" COLSPAN="2" style="text-align: center;">' );
     if substr(pfx.slider_choice,1,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'R' );
     elsif substr(pfx.slider_choice,1,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails, extra_term, image_style );
     elsif substr(pfx.slider_choice,1,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
     end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
      if substr(pfx.slider_choice,2,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'B' );
      elsif substr(pfx.slider_choice,2,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
      elsif substr(pfx.slider_choice,2,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
      end if;
     htp.p( '</TD>' );
     htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
      if substr(pfx.slider_choice,3,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'B' );
      elsif substr(pfx.slider_choice,3,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
      elsif substr(pfx.slider_choice,3,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
      end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
  htp.tableclose;

elsif pfx.slider_style = '6'
 then
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=2 border=0' );
   htp.tablerowopen;
    htp.tablerowopen;
     htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
      if substr(pfx.slider_choice,1,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'B' );
      elsif substr(pfx.slider_choice,1,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
      elsif substr(pfx.slider_choice,1,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
      end if;
     htp.p( '</TD>' );
     htp.p( '<TD align="CENTER" valign="TOP" style="text-align: center;">' );
      if substr(pfx.slider_choice,2,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'B' );
      elsif substr(pfx.slider_choice,2,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails_sml, extra_term, image_style );
      elsif substr(pfx.slider_choice,2,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
      end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.p( '<TD align="CENTER" valign="TOP" COLSPAN="2" style="text-align: center;">' );
     if substr(pfx.slider_choice,3,1) = 'M' then slider_main(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, 'R' );
     elsif substr(pfx.slider_choice,3,1) = 'T' then slider_thumbnails(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec, numb_tnails, extra_term, image_style );
     elsif substr(pfx.slider_choice,3,1) = 'S' then slider_search(surl, stype, ltype, profid, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, display_detail, left_api_parm, cusloc, lbox, acid, sess_id, no_results_message, voidrec );
     end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
  htp.tableclose;

end if;

exception when others then
 glbx.error_details( 'CST', 'DISP_BY_SCENE_SLIDER',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end disp_by_scene_slider;

procedure slider_main( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                       umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                       footer_api in varchar2, current_page_number in integer default 1, display_detail in char default null,
                       left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                       no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, position_of_main_image_text in char)
as

 cursor c2(acid integer,utype varchar2,photo_id integer) is
  select *
  from umo um
  where um.aid = acid and
        um.umo_id = photo_id and
        um.umo_type = 'PHOTO' and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'));

 c2rec			c2%ROWTYPE;
 upref			varchar2(100);
 foundrec		boolean;
 dbool			boolean;
 jctr			integer;
 lap			varchar2(1000);
 vlap			integer;
 dspv			integer;
 oth			integer;
 currimg		integer;
 newdt			integer;
 phg_title		varchar2(100);
 usemap			varchar2(100);
 imgno			varchar2(100);
 vcusloc		varchar2(100);
 url			varchar2(1000);
 hor_caption		varchar2(4000);
 vhor_caption		varchar2(4000);
 temp			varchar2(32767);
 mt			varchar2(32767);
 hor_but		varchar2(4000);
 video_api		varchar2(1000);
 audio_api		varchar2(1000);
 relational_api		varchar2(1000);
 blueprint_api		varchar2(1000);
 document_api		varchar2(1000);
 display_original	varchar2(100);
 tmp			varchar2(32767);
 tmp1			varchar2(1000);
 tmp2			varchar2(1000);
 adj			integer;
 is_local		boolean;
 jscript		varchar2(1000);
 jscript_close		varchar2(1000);
 empty_array		GLBX.MYARRAY;

begin

 -- The calling program should trap if no results are returned.
 if umrec.count = 0
  then
   glbx.header_msg( no_results_message );
   htp.htmlclose;
   return;
 end if;

 if pfx.fullimg_jscript_popup = 'T'
  then
   jscript := 'javascript: window.opener.location = ''';
   jscript_close := '''; window.close();';
 end if;

 initialise_api_variables(surl, sess_id, ltype, 421, null, 420, cusrec, theme_rec, document_api, video_api, audio_api, relational_api, blueprint_api, upref, newdt, is_local, display_original, phg_title );

 if instr(left_api_parm,'][') > 0
  then
   begin vlap := substr(left_api_parm,2,instr(left_api_parm,']')-2); exception when others then vlap := NULL; end;
   lap := substr(left_api_parm,instr(left_api_parm,']')+1);
 elsif substr(left_api_parm,1,1) = '['
  then
   begin vlap := substr(left_api_parm,2,instr(left_api_parm,']')-2); exception when others then vlap := NULL; end;
   lap := substr(left_api_parm,instr(left_api_parm,']')+1);
   -- Check if lap is a number, if it is then vlap points to the master image, otherwise it is the AID
   begin oth := to_number(lap); exception when others then lap := left_api_parm; vlap := NULL; end;
  else
   lap := left_api_parm;
   vlap := NULL;
 end if;

 --
 -- Display Main Image Here
 --
 if vlap is null and umrec.count > 0
  then
   -- Extract first image from the array
   vlap := umrec(umrec.first).umo_id;
 end if;

 if vlap is not null
  then
   open c2(cusrec.aid,ltype,vlap);
   fetch c2 into c2rec;
   if c2%NOTFOUND then close c2; return; end if;
   close c2;
   -- Display Buttons
   htp.tableopen;
   htp.tablerowopen;

    -- Previous Button
    if is_bf(theme_rec,ltype,351,352,'T','T',350,'T')
     then
      currimg := NULL;
      for k in umrec.first..umrec.last loop
       if umrec(k).umo_id = c2rec.umo_id then currimg := k - 1; if currimg < umrec.first then currimg := NULL; end if; exit; end if;
      end loop;
      if currimg is not null
       then
        htp.tabledata(htf.anchor(footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=[' || umrec(currimg).umo_id || ']' || replace(substr(left_api_parm,instr(left_api_parm,']')+1),' ','+') || '&start_from=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,
                      htf.img(cust_button(pfx,'modprev.gif',2), cattributes=>'BORDER=0', calt=>LNG2.PFM_TXT_085 )));
      end if;
    end if;

    -- Shopping Trolley
    if is_bf(theme_rec,ltype,348,349,'T','T',347,'T')
     then
      htp.tabledata( htf.anchor(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || c2rec.umo_id ||
                                  '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail ||
                                  '&add_to_trolley=Order+Photos&acid=' || acid,
                     htf.img( cust_button(pfx,'order.gif',2), cattributes=>'BORDER=0',calt=>LNG.CST_TXT_064 )));
    end if;

    -- Novelties
   htp.p(glbx.novelty_option( surl, pfx, footer_api, left_api_parm,  current_page_number, display_detail, cusrec, ltype, 'MAIN', 'HOR_TABLE', vlap ));

   -- Enable Zoom
   /* -- Now a Novelty
   if is_bf(theme_rec,ltype,302,303,'T','T',298,'T') and not (substr(cusrec.zoom_factor,1,9) = 'FFFFFFFFF')
    then
     htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || acid,
                    htf.img( cust_button(pfx,'zoom.gif',3),cattributes=>'border=0',calt=>LNG.CST_TXT_072 ),ctarget=>'NEW_WINDOW'));
   end if;
   */
    -- Add to Lightbox
    --
    if is_bf(theme_rec,ltype,339,340,'T','T',338,'T') and
       footer_api <> 'cst.disp_lightbox'
      then
       htp.tabledata(htf.anchor(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || c2rec.umo_id ||
                                  '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail ||
                                  '&add_lightbox=ADD&acid=' || acid,
                    htf.img( cust_button(pfx,'lightbox.gif',8), cattributes=>'BORDER=0', calt=>LNG4.AHC_TXT_436 || ' ' || lbox )));
    end if;

    -- Delete/Empty from Lightbox
    if is_bf(theme_rec,ltype,339,340,'T','T',338,'T') and
       footer_api = 'cst.disp_lightbox'
      then
       htp.tabledata(htf.anchor(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || c2rec.umo_id ||
                                  '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail ||
                                  '&empty_lightbox=ADD&acid=' || acid,
                     htf.img( cust_button(pfx,'emptylight.gif',8), cattributes=>'BORDER=0', calt=>LNG4.AHC_TXT_432 || ' ' || lbox  )));
       htp.tabledata(htf.anchor(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || c2rec.umo_id ||
                                  '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail ||
                                  '&del_lightbox=ADD&acid=' || acid,
                     htf.img( cust_button(pfx,'dellight.gif',8), cattributes=>'BORDER=0', calt=>LNG4.AHC_TXT_437 || ' ' || lbox  )));
    end if;

    -- Next Button
    if is_bf(theme_rec,ltype,351,352,'T','T',350,'T')
     then
      currimg := NULL;
      for k in umrec.first..umrec.last loop
       if umrec(k).umo_id = c2rec.umo_id then currimg := k + 1; if currimg > umrec.last then currimg := NULL; end if; exit; end if;
      end loop;
      if currimg is not null
       then
        htp.tabledata(htf.anchor(footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=[' || umrec(currimg).umo_id || ']' || replace(substr(left_api_parm,instr(left_api_parm,']')+1),' ','+') || '&start_from=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,
                      htf.img(cust_button(pfx,'modnext.gif',2), cattributes=>'BORDER=0', calt=>LNG2.PFM_TXT_088 )));
      end if;
    end if;

   htp.tablerowclose;
   htp.tableclose;

   -- Display Main Image Here
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=0' );
   htp.tablerowopen;
   htp.p( '<TD style="text-align: center;">' );
   if is_bf(theme_rec,ltype,385,386,'T','T',384,'T')
    then
     imgno := htf.nl || '#' || c2rec.extras.orderby_nmb;
    else
     imgno := NULL;
   end if;
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 bordercolordark="#' || pfx.tnail_border_colour || '" bordercolorlight="#' || pfx.tnail_border_colour_l || '" border=' || to_char(nvl(pfx.tnail_border,0)) );
    htp.tablerowopen;
    if ltype = 'PHOTOGRAPHER'
     then
       url := 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&phgid=' || c2rec.umo_id || '&acid=' || acid || '&msg=&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail;
       vcusloc := cusloc;
     else
       url := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid;
       vcusloc := 'NEW WINDOW';
    end if;

    if c2rec.photo_master.width > c2rec.photo_master.height
     then
      -- If Zoom disabled do not anchor the image
      if glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
       then
        dspv := c2rec.photo_master.width;
        oth := c2rec.photo_master.height;
        adj := 1;
       else
        dspv := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
        oth := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / c2rec.photo_master.width) * c2rec.photo_master.height;
        adj := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / c2rec.photo_master.width);
      end if;
      if is_bf(theme_rec,ltype,408,408,'T','T') then usemap := glbx.embed_image_map( surl, c2rec.umo_id, adj, acid ); end if;
      if is_bf(theme_rec,ltype,302,303,'T','T',298,'T') and not (substr(cusrec.zoom_factor,1,9) = 'FFFFFFFFF')
       then
        htp.tabledata( htf.anchor2( url,
                       '<IMG BORDER=0 WIDTH=' || to_char(dspv) || ' SRC="' ||
                       'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                       '" ALT="' || c2rec.extras.photo_name || '" STYLE="display:block;">',ctarget=>vcusloc ) || imgno, cattributes=>'style="text-align: center;"  align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' );
       else
        htp.tabledata( '<IMG BORDER=0 WIDTH=' || to_char(dspv) || ' SRC="' ||
                       'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                       '" ALT="' || c2rec.extras.photo_name || '" STYLE="display:block;">' || imgno,cattributes=>'style="text-align: center;"  align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"');
      end if;

     else

      if glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
       then
        dspv := c2rec.photo_master.height;
        oth := c2rec.photo_master.width;
        adj := 1;
       else
        dspv := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
        oth := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / c2rec.photo_master.height ) * c2rec.photo_master.width;
        adj := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / c2rec.photo_master.height);
      end if;
      if is_bf(theme_rec,ltype,408,408,'T','T') then usemap := glbx.embed_image_map( surl, c2rec.umo_id, adj, acid ); end if;
      if is_bf(theme_rec,ltype,302,303,'T','T',298,'T') and not (substr(cusrec.zoom_factor,1,9) = 'FFFFFFFFF')
       then
         htp.tabledata( htf.anchor2( url,
                        '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                        '" ALT="' || c2rec.extras.photo_name || '" STYLE="display:block;">',ctarget=>vcusloc ) || imgno, cattributes=>'style="text-align: center;"  align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '"' );
       else
         htp.tabledata( '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                        '" ALT="' || c2rec.extras.photo_name || '" STYLE="display:block;">' || imgno, cattributes=>'style="text-align: center;"  align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '"' );
      end if;
    end if;

    htp.tablerowclose;
   htp.tableclose;
   htp.p( '</TD>' );

   -- Force Image Details to go under the main image
   if position_of_main_image_text = 'B'
    then
     htp.tablerowclose;
     htp.tablerowopen;
   end if;

   htp.p( '<TD VALIGN="TOP">' );

    -- Who is in the image
    display_who(surl, ltype, theme_rec, c2rec.umo_id, 305, 306, 304, 308, 309, 307, footer_api, left_api_parm, current_page_number, display_detail, acid, 'MS' );
    htp.nl;
    htp.nl;

   -- Image Comments
    htp.tableopen;
     htp.tablerowopen;
      display_comments(surl, c2rec, theme_rec, cusrec, ltype, 311, 312, 314, 315, 313, 310, null, footer_api, left_api_parm, current_page_number, display_detail, acid, 'MS' );
     htp.tablerowclose;
    htp.tableclose;

    -- Display Caption
    if is_bf(theme_rec,ltype,317,318,'T','T',316,'T') and c2rec.image_caption is not null
     then
       htp.nl;
       htp.tableopen( cattributes=>pfx.vertical_disp_table );
        htp.tablerowopen;
         htp.tabledata(c2rec.image_caption,cattributes=>'valign="TOP" align="LEFT" STYLE="font-family: ' || pfx.caption_text_font || '; color: #' || pfx.caption_text_colour || '"');
        htp.tablerowclose;
       htp.tableclose;
    end if;

   -- Display Meta Tags
   if is_bf(theme_rec,ltype,320,321,'T','T',319,'T')
    then
       htp.nl;
       dbool := glbx.disp_mt( surl,ltype,c2rec.umo_id, c2rec.umo_type, substr(theme_rec.theme_data,167,1), pfx, acid, empty_array );
   end if;

   if c2rec.audio_original.description is not null
    then
     htp.nl;
     htp.tableopen( cattributes=>'BORDER=0');
      htp.tablerowopen;
       htp.tabledata( htf.bold(LNG.CST_TXT_207) );
      htp.tablerowclose;
      htp.tablerowopen;
       htp.tabledata(htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOWX&parm1=DISPLAY_WHAT&parm2=ORIGINAL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=OVERRIDE&parm2=AUDIO',
                                   htf.img( DECS.IMAGE_LOCATION || 'adminc/audio.gif',cattributes=>'border=0',calt=>lng.CST_ALT_086 ),ctarget=>'AUDIO_WINDOW'),cattributes=>pfx.qcbground);
      htp.tablerowclose;
     htp.tableclose;
   end if;

   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
   htp.line;
 end if;

exception when others then
 glbx.error_details( 'CST', 'slider_main',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end slider_main;

procedure slider_thumbnails( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                footer_api in varchar2, current_page_number in integer default 1, display_detail in char default null,
                                left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE, numb_tnails in integer, extra_term in varchar2 default null, image_style in varchar2)
as

cursor c9(v_umo integer) is
 select value
 from umo_attribute ua, umo_attributes uas
 where ua.umo_id = v_umo and
       ua.attribute_id = uas.attribute_id and
       sub_category = 'PHOTO ALBUM';

 c9rec			c9%ROWTYPE;
 upref			varchar2(100);
 foundrec		boolean;
 dbool			boolean;
 jctr			integer;
 lap			varchar2(1000);
 vlap			integer;
 dspv			integer;
 oth			integer;
 currimg		integer;
 newdt			integer;
 phg_title		varchar2(100);
 usemap			varchar2(100);
 imgno			varchar2(100);
 vcusloc		varchar2(100);
 url			varchar2(1000);
 hor_caption		varchar2(4000);
 vhor_caption		varchar2(4000);
 temp			varchar2(32767);
 mt			varchar2(32767);
 hor_but		varchar2(4000);
 video_api		varchar2(1000);
 audio_api		varchar2(1000);
 relational_api		varchar2(1000);
 blueprint_api		varchar2(1000);
 document_api		varchar2(1000);
 display_original	varchar2(100);
 tmp			varchar2(32767);
 tmp1			varchar2(1000);
 tmp2			varchar2(1000);
 adj			integer;
 is_local		boolean;
 jscript		varchar2(1000);
 jscript_close		varchar2(1000);

begin

 -- The calling program should trap if no results are returned.
 if umrec.count = 0
  then
   glbx.header_msg( no_results_message );
   htp.htmlclose;
   return;
 end if;

 if pfx.fullimg_jscript_popup = 'T'
  then
   jscript := 'javascript: window.opener.location = ''';
   jscript_close := '''; window.close();';
 end if;

 initialise_api_variables(surl, sess_id, ltype, 421, null, 420, cusrec, theme_rec, document_api, video_api, audio_api, relational_api, blueprint_api, upref, newdt, is_local, display_original, phg_title );

 if instr(left_api_parm,'][') > 0
  then
   begin vlap := substr(left_api_parm,2,instr(left_api_parm,']')-2); exception when others then vlap := NULL; end;
   lap := substr(left_api_parm,instr(left_api_parm,']')+1);
 elsif substr(left_api_parm,1,1) = '['
  then
   begin vlap := substr(left_api_parm,2,instr(left_api_parm,']')-2); exception when others then vlap := NULL; end;
   lap := substr(left_api_parm,instr(left_api_parm,']')+1);
   -- Check if lap is a number, if it is then vlap points to the master image, otherwise it is the AID
   begin oth := to_number(lap); exception when others then lap := left_api_parm; vlap := NULL; end;
  else
   lap := left_api_parm;
   vlap := NULL;
 end if;

 -- If the Option to Display the Thumbnails when main image is turned then return;
 if vlap is not null and
    is_bf(theme_rec,ltype,406,407,'T','T',405,'T')
  then
   return;
 end if;

 vhor_caption := glbx.userpref( cusrec.pid, cusrec.aid, 'TNAIL_PREF' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=3 border=0 ' );
 jctr := 1;
 for j in umrec.first..umrec.last loop

  if jctr = 1
    then
     htp.tablerowopen;
    elsif (mod(jctr, numb_tnails) = 1 or numb_tnails=1)
     then
      htp.tablerowclose;
      htp.tablerowopen;
  end if;
  jctr := jctr + 1;

  if pfx.tnail_global_border = 'T'
   then
    htp.p( '<TD valign="BOTTOM" align="CENTER" style="text-align: center;">' );
    htp.tableopen( cattributes=>'cellpadding=' || pfx.tnail_global_spacer || ' cellspacing=0 border=0' );
    htp.tablerowopen;
    htp.p( '<TD valign="MIDDLE" align="CENTER" style="text-align: center;" BGCOLOR="#' || pfx.tnail_global_colour || '">' );
    htp.tableopen( cattributes=>'cellpadding=' || pfx.tnail_global_offset || ' cellspacing=0 border=0' );
    htp.tablerowopen;
  end if;

  --htp.p( '<TD valign="BOTTOM" align="left" CLASS="SMALL">' );
  /*
  if cusrec.background_img is null
   then
    htp.p( '<TD valign="BOTTOM" align="LEFT" CLASS="SMALL" style="text-align: left;" BGCOLOR="#' || pfx.text_back || '">' );
   else
    htp.p( '<TD valign="BOTTOM" align="LEFT" CLASS="SMALL" style="text-align: left;" ' ||
           'BACKGROUND="ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || cusrec.background_img || '&parm1=DISPLAY_TYPE&parm2=RAW' ||
           '&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '">' );
  end if;
  */
  htp.p( '<TD valign="BOTTOM" align="LEFT" CLASS="SMALL" style="text-align: left;" BGCOLOR="#' || pfx.text_back || '">' );
  htp.formhidden( 'P0', umrec(j).umo_id );

  if umrec(j).umo_type in ('PHOTO','MANUFACTURER','DOCUMENT','AUDIO','VIDEO','RELATIONAL','BLUEPRINT')
   then
     -- Display Horizontal Meta Tags
     mt := NULL;
     foundrec := FALSE;
     mt := horizontal_meta_tags(surl, ltype, 321, 322, 320, theme_rec, umrec(j));

     if umrec(j).umo_type = 'MANUFACTURER'
      then
        manufacturer_object(surl, ltype, 223, 224, 285, 323, 324, 322, pfx, theme_rec, umrec(j), FALSE);

     else

      -- Individual Customer Buttons
      if is_bf(theme_rec,ltype,326,327,'T','T',325,'T')
       then
        hor_but := NULL;
        -- a button
        if is_bf(theme_rec,ltype,348,349,'T','T',347,'T')
         then
          hor_but := hor_but || htf.anchor(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec(j).umo_id || '&add_to_trolley=Order+Photos' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_a.gif',cattributes=>'border=0',calt=>lng.CST_TXT_065 ));
        end if;

        -- b button
        if is_bf(theme_rec,ltype,339,340,'T','T',338,'T') and
            footer_api <> 'cst.disp_lightbox'
         then
          hor_but := hor_but || htf.anchor2( 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec(j).umo_id || '&add_lightbox=TRUE' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_b.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_379 || ' ' || lbox), ctarget=>cusloc );
         elsif
           is_bf(theme_rec,ltype,39,340,'T','T',338,'T') and footer_api = 'cst.disp_lightbox'
         then
          hor_but := hor_but || htf.anchor2(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec(j).umo_id || '&del_lightbox=TRUE' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_b.gif',cattributes=>'border=0',calt=>LNG4.AHC_TXT_380 || ' ' ||  lbox), ctarget=>cusloc );
        end if;

        -- c button
        if voidrec.download_original_any_time = 'T'
         then
          -- Note: Relational Objects have no Download Capability
          if (umrec(j).umo_type = 'PHOTO' and nvl(umrec(j).photo_original.contentlength,0) > 0) or
             (umrec(j).umo_type = 'DOCUMENT' and nvl(umrec(j).doc_length,0) > 0) or
             (umrec(j).umo_type = 'VIDEO' and nvl(dbms_lob.getlength(umrec(j).video_original.source.localdata),0) > 0) or
             (umrec(j).umo_type = 'AUDIO' and nvl(dbms_lob.getlength(umrec(j).audio_original.source.localdata),0) > 0) or
             (umrec(j).umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(umrec(j).blueprint_obj.localdata),0) > 0)
          then
            hor_but := hor_but || htf.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec(j).umo_id || '&purchid=&mthod=ORIGINAL&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_157 ));
          elsif (umrec(j).ftp_virtual_dir || umrec(j).ftp_location) is not null
           then
            hor_but := hor_but || htf.anchor2( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec(j).umo_id || '&purchid=&mthod=FTP&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_157 ), ctarget=>'DOWNLOAD_WINDOW');
          end if;
        end if;

        if voidrec.download_web_any_time = 'T'
         then
          -- Note: Relational Objects have no Download Capability
          if (umrec(j).umo_type = 'PHOTO' and nvl(umrec(j).photo_master.contentlength,0) > 0) or
             (umrec(j).umo_type = 'DOCUMENT' and nvl(dbms_lob.getlength(umrec(j).doc_html),0) > 0) or
             (umrec(j).umo_type = 'AUDIO' and nvl(dbms_lob.getlength(umrec(j).audio_thumbnail.source.localdata),0) > 0) or
             (umrec(j).umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(umrec(j).blueprint_obj.online_version),0) > 0)
          then
            hor_but := hor_but || htf.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec(j).umo_id || '&purchid=&mthod=WEB&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 ));
          elsif (umrec(j).ftp_virtual_dir || umrec(j).ftp_location) is not null
           then
            hor_but := hor_but || htf.anchor2( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec(j).umo_id || '&purchid=&mthod=FTP&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 ), ctarget=>'DOWNLOAD_WINDOW');
          end if;
        end if;

        -- d button
        if ltype = 'PHOTOGRAPHER'
         then
          hor_but := hor_but || htf.anchor( 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&phgid=' || umrec(j).umo_id || '&acid=' || acid || '&msg=&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_d.gif',cattributes=>'border=0',calt=>lng.PHG_TXT_178 ));
         else
          hor_but := hor_but || htf.anchor( 'cst.disp_acct_photo?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&extra_term=' || replace(extra_term,' ','+'),htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_d.gif',cattributes=>'border=0',calt=>lng.PHG_TXT_178 ));
        end if;
      else
        hor_but := NULL;
      end if;

      -- Determine if Image Caption is to be displayed in Balloon Help
      hor_caption := replace(replace(vhor_caption,'~CAPTION',umrec(j).image_caption),'~NAME', umrec(j).extras.photo_name);
      /*
      if is_bf(theme_rec,ltype,335,336,'T','T',334,'T')
       then
         hor_caption := nvl(umrec(j).image_caption,LNG.CST_TXT_183 || ' (' || umrec(j).extras.photo_name || ')');
       else
         hor_caption := LNG.CST_TXT_183 || ' (' || umrec(j).extras.photo_name || ')';
      end if;
      */

      -- Display Image Name
      if is_bf(theme_rec,ltype,329,330,'T','T',328,'T')
       then
        -- If the Image Name can be edited then do not display it
        if is_bf(theme_rec,ltype,332,333,'T','T',331,'T')
         then
          if mt is not null
           then
            temp := mt;
          end if;
         else
          if mt is not null
           then
            temp := htf.bold(umrec(j).extras.photo_name) || mt;
          end if;
        end if;
       else
        if mt is not null
         then
          temp := mt;
        end if;
      end if;
      if is_bf(theme_rec,ltype,385,386,'T','T',384,'T') then temp := temp || htf.nl || '#' || umrec(j).extras.orderby_nmb; end if;
      htp.p( temp );

      -- Display Thumbnail
      if is_bf(theme_rec,ltype,323,324,'T','T',322,'T')
       then
         display_thumbnail(surl,ltype,umrec(j),theme_rec,pfx,footer_api,lap,current_page_number,display_detail,hor_caption,document_api,video_api,audio_api,relational_api,blueprint_api,acid,display_original,stype,extra_term,image_style);
      end if;
      if is_bf(theme_rec,ltype,332,333,'T','T',331,'T')
       then
        if ltype = 'PHOTOGRAPHER'
         then
          htp.p( hor_but || htf.nl || htf.formtext('PPN',20,100,umrec(j).extras.film_name) || htf.nl || htf.italic(umrec(j).extras.photo_name) );
         else
          htp.p( hor_but || htf.nl || htf.formtext('PPN',20,100,umrec(j).extras.photo_name));
        end if;
       else
       htp.p( hor_but || htf.formhidden( 'PPN', null ));
      end if;

    end if; -- End If umorec = MANUFACTURER

     -- Album Enabled
     if is_bf(theme_rec,ltype,342,343,'T','T',341,'T') and umrec(j).umo_type <> 'MANUFACTURER'
      then
        -- Open Cursor to extract Meta Tag Value to see if it is enabled
        c9rec.value := NULL;
        open c9(umrec(j).umo_id);
        fetch c9 into c9rec;
        close c9;
        if nvl(c9rec.value,'FALSE') = 'TRUE'
         then
           htp.nl;
           htp.p( htf.formcheckbox( 'PA', umrec(j).umo_id, 'CHECKED' ) || LNG.CST_TXT_202 );
         else
           htp.nl;
           htp.p( htf.formcheckbox( 'PA', umrec(j).umo_id ) || LNG.CST_TXT_202 );
        end if;
      else
       htp.formhidden( 'PA',null );
     end if;
     -- Enable / Disable Image is not a feature which can be enabled
     htp.formhidden( 'PB',umrec(j).umo_id );
      -- Choose Image
      if is_bf(theme_rec,ltype,345,346,'T','T',344,'T')
       then
        if umrec(j).umo_type = 'MANUFACTURER'
         then
          -- Check for Out of Stock Option
          if (umrec(j).attribute3 is null or umrec(j).attribute1 is null) or (to_number(umrec(j).attribute3) >= to_number(umrec(j).attribute1))
           then
            -- If Stock level is null or value to check is null then it is traditional behaviour or if there is sufficient stock
            htp.p( htf.nl || htf.formcheckbox( 'P1', 'S' || umrec(j).extras.quality ) || LNG.CST_TXT_201);
          elsif to_number(umrec(j).attribute3) < to_number(umrec(j).attribute1)
           then
            -- If mfctr stock less is less than what is requested
            if umrec(j).attribute2 = 'T' -- Item can still be purchased
             then
              htp.p( htf.nl || htf.formcheckbox( 'P1', 'S' || umrec(j).extras.quality ) || LNG.CST_TXT_201 || htf.nl || umrec(j).attribute4);
             else
             htp.p( htf.nl || umrec(j).attribute4);
            end if;
          end if;
         else
          htp.p( htf.nl || htf.formcheckbox( 'P1', umrec(j).umo_id ) || LNG.CST_TXT_201);
        end if;
      end if;

    preselect_price(surl, ltype, is_local, cusrec, pfx, theme_rec, umrec(j), voidrec );

  end if;

  htp.p( '</TD>' );

  if pfx.tnail_global_border = 'T'
   then
    htp.tablerowclose;
    htp.tableclose;
    htp.tablerowclose;
    htp.tableclose;
    htp.p( '</TD>' );
  end if;

 end loop;
 htp.tableclose;

exception when others then
 glbx.error_details( 'CST', 'slider_thumbnails',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end slider_thumbnails;

procedure slider_search( surl varchar2, stype in integer, ltype in varchar2, profid in integer,
                                umrec in UMP.SEARCH_RESULT_PHG, cusrec in CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE,
                                footer_api in varchar2, current_page_number in integer default 1, display_detail in char default null,
                                left_api_parm in varchar2, cusloc in varchar2, lbox in varchar2, acid in integer default null, sess_id in integer,
                                no_results_message in varchar2 default null, voidrec in order_style%ROWTYPE)
as
begin
 htp.formclose;
 disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, pfx.slider_search_style );
 htp.formopen( 'cst.accept_display', ctarget=>cusloc );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 htp.formhidden( 'P0', '0' );
 htp.formhidden( 'P1', '0' );
 htp.formhidden( 'PA', '0' );
 htp.formhidden( 'PB', '0' );
 htp.formhidden( 'PC', '0' );
 htp.formhidden( 'PPN', '0' );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );

exception when others then
 glbx.error_details( 'CST', 'slider_search',cusrec.pid,cusrec.aid,errmsg=>sqlerrm );
end slider_search;

procedure disp_by_scene_buttons_standard
  (surl in varchar2, sess_id integer, ltype in varchar2, title in varchar2, umrec in UMP.SEARCH_RESULT_PHG, cusrec in customer_account%ROWTYPE, left_api_parm in varchar2,
   start_from in integer, search_total in integer, footer_api in varchar2, numb_photos in integer,
   lbox in varchar2, lboxall in varchar2,
   theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE, dispvert in varchar2 default 'T', acid in integer default null, show_vertically in boolean, pbook in phg_price_book%ROWTYPE )
as

 cursor c2(sess_id integer) is
   select /*+ ALL_ROWS */ count('x') tot
   from lightbox l
   where l.sessid = sess_id;

 c2rec		c2%ROWTYPE;
 cd1		varchar2(32767);
 cd2		varchar2(20);

begin
 -- 186,187 Enable all buttons
 open c2(sess_id);
 fetch c2 into c2rec;
 close c2;
    htp.tableopen;
    htp.tablerowopen;

    -- Previous Button
    if (start_from > 1) and ((start_from - numb_photos) >= 1) and
       is_bf(theme_rec,ltype,207,208,'T','T',264,'T')
     then
      htp.tabledata(htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                               '&start_from=' ||  to_char(start_from - numb_photos) || '&display_detail=' || dispvert || '&acid=' || acid,
                    htf.img(cust_button(pfx,'modprev.gif',2), cattributes=>'BORDER=0', calt=>LNG2.PFM_TXT_085 )));
      if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

    -- Customer can toggle between vertical and horizontal display
    -- if is_bf(theme_rec,ltype,198,199,'T','T',265,'T') (Old Call)
    if pfx.toggle_style is not null
     then
      if dispvert = pfx.display_style
       then
          htp.tabledata(htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || pfx.toggle_style || '&acid=' || acid,
                        htf.img( cust_button(pfx,'summary.gif',2),cattributes=>'border=0', calt=>LNG3.ADM_TXT_619 )));
          if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       elsif dispvert = pfx.toggle_style
        then
          htp.tabledata(htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || pfx.display_style || '&acid=' || acid,
                        htf.img( cust_button(pfx,'detail.gif',2),cattributes=>'border=0', calt=>LNG4.AHC_TXT_396 )));
          if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
      end if;
    end if;

    -- Shopping Trolley
    if is_bf(theme_rec,ltype,205,206,'T','T',267,'T')
     then
      htp.tabledata(htf.formimage( 'Add_To_Trolley',cust_button(pfx,'order.gif',2), cattributes=>'BORDER=0' ));
      if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

    -- Display Photo Details
    if is_bf(theme_rec,ltype,181,184,'T','T',266,'T')
     then
      htp.tabledata(htf.formimage( 'Display',cust_button(pfx,'display.gif',2), cattributes=>'BORDER=0'  ));
      if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

     -- Modify Images
    if is_bf(theme_rec,ltype,203,204,'T','T',268,'T')
      then
       htp.tabledata(htf.formimage( 'Modify_Details',cust_button(pfx,'moddet.gif',2), cattributes=>'BORDER=0'  ));
      if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

    -- Whats New
    if is_bf(theme_rec,ltype,423,NULL,'T','T',422,'T')
      then
       htp.tabledata(htf.anchor( 'cst.whatsnew' || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'whatsnew.gif',9),cattributes=>'border=0', calt=>LNG5.EXT_TXT_050 )));
       if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

    -- Package Product xxx for language file
    if pbook.call_location in ('2','4','5','7')
      then
       htp.tabledata(htf.anchor( 'cst.packprod_hdr' || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'packprod.gif',9),cattributes=>'border=0', calt=>'Choose a Package' )));
       if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;
    if pbook.call_location in ('1','2','4','5','7')
      then
       htp.tabledata(htf.anchor( 'cst.packprod_edit' || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'packprode.gif',9),cattributes=>'border=0', calt=>'Edit Package Details' )));
       if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

    -- Category Special MiniSlideshow
    if is_bf(theme_rec,ltype,425,426,'T','T',424,'T')
     then
      if search_total > 0 and footer_api = 'cst.disp_category' -- and integrate business feature
       then
        htp.tabledata(
          '<A HREF="javascript: window.open(''sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&dispstyle=SETUP&uscid=' || left_api_parm || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=700,height=500'');void('''');">' ||
          htf.img( cust_button(pfx,'catshow.gif',9),cattributes=>'border=0', calt=>'Show Images by Category' ) || '</A>');
        if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
      elsif search_total > 0 and footer_api <> 'cst.disp_category' and umrec.count > 0
        then
         cd2 := umrec(umrec.first).umo_id;
         for j in umrec.first..umrec.last loop
          cd1 := cd1 || ';' || umrec(j).umo_id;
         end loop;
         cd1 := cd1 || ';';
         htp.tabledata(
           '<A HREF="javascript: window.open(''sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&dispstyle=FRAME&uscid=' || left_api_parm || '&acid=' || acid || '&codes=' || cd1 || '&currcode=' || cd2 || '&ttl=' || replace(title,' ','+') || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=700,height=500'');void('''');">' ||
           htf.img( cust_button(pfx,'catshow.gif',9),cattributes=>'border=0', calt=>'Show Images by Category' ) || '</A>');
         if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
      end if;
    end if;

    --
    -- Activities
    --

    -- See Previous Orders (Note: Guests cannot see previous orders as their logon id is anonymous)
    if is_bf(theme_rec,ltype,393,null,'T','T',392,'T') and ltype in ('PHOTOGRAPHER','OWNER','PROFILE','VIRTUAL')
      then
          htp.tabledata(htf.anchor( 'cst.previous_orders' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'prv.gif',9),cattributes=>'border=0', calt=>LNG4.AHC_TXT_629 )));
      if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

    -- Registration
    if is_bf(theme_rec,ltype,399,400,'T','T',398,'T')
      then
       if ltype in ('PROFILEG','CUSTOMER')
        then
          htp.tabledata(htf.anchor( 'cst.cust_contact' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid || '&profid=&ACTION=NEW',
                        htf.img( cust_button(pfx,'regn.gif',9),cattributes=>'border=0', calt=>LNG4.AHC_TXT_802 )));
          if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       elsif ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
        then
          htp.tabledata(htf.anchor( 'cst.cust_contact' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid || '&profid=&action=UPDATE',
                        htf.img( cust_button(pfx,'regc.gif',9),cattributes=>'border=0', calt=>LNG4.AHC_TXT_801 )));
          if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       end if;
    end if;

    -- Simple RFQ
    if is_bf(theme_rec,ltype,390,391,'T','T',389,'T')
      then
          htp.tabledata(htf.anchor( 'cst.srfq' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'rfq.gif',9),cattributes=>'border=0', calt=>LNG4.AHC_TXT_630 )));
          if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;


    --
    -- Lightbox Management Buttons
    --

    -- Add to Lightbox
    --
    if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and
       footer_api <> 'cst.disp_lightbox'
      then
       htp.tabledata(htf.formimage( 'Add_Lightbox',cust_button(pfx,'lightbox.gif',8), cattributes=>'BORDER=0'  ));
       if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       htp.tabledata(htf.anchor( 'cst.add_all_lightbox?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid || '&p1=' || lboxall,
                        htf.img( cust_button(pfx,'lightboxall.gif',8),cattributes=>'border=0', calt=>LNG5.EXT_TXT_109 || ' ' || lbox ) ));
       if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       if c2rec.tot > 0
        then
          htp.tabledata(htf.anchor( 'cst.disp_lightbox?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'seelight.gif',8),cattributes=>'border=0', calt=>LNG4.AHC_TXT_435 || ' ' || lbox ) ));
          if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       end if;
       -- Only Valid Authorised User Sessions can create their own lightbox
       if ltype in ('PHOTOGRAPHER','OWNER','PROFILE' )
        then
          htp.tabledata(htf.anchor( 'cst.mng_lightbox?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'lboxes.gif',8),cattributes=>'border=0', calt=>LNG5.EXT_TXT_051 || ' ' || lbox ) ));
          if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       end if;
    end if;

    -- Delete from Lightbox
    if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and
       footer_api = 'cst.disp_lightbox'
      then
       htp.tabledata(htf.formimage( 'Empty_Lightbox',cust_button(pfx,'emptylight.gif',8), cattributes=>'BORDER=0'  ));
       if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       htp.tabledata(htf.formimage( 'Del_Lightbox',cust_button(pfx,'dellight.gif',8), cattributes=>'BORDER=0'  ));
       if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       -- Only Valid Authorised User Sessions can create their own lightbox
       if ltype in ('PHOTOGRAPHER','OWNER','PROFILE' )
        then
        htp.tabledata(htf.anchor( 'cst.mng_lightbox?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                      '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                       htf.img( cust_button(pfx,'lboxes.gif',8),cattributes=>'border=0', calt=>LNG5.EXT_TXT_051 || ' ' || lbox ) ));
        if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
       end if;
    end if;

    -- Lighbox List of Values
    if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and
       footer_api <> 'cst.disp_lightbox'
      then
       htp.tabledata(lightbox_headers('LBOXID',cusrec.aid,ltype),cattributes=>' VALIGN="BOTTOM" CLASS="SMALL"');
       if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

    -- Toggle Display
    if cusrec.toggle_default in ( 'A', 'R' ) and
       footer_api <> 'cst.disp_lightbox'
      then
      htp.tabledata(htf.anchor( 'cst.handle_toggle?surl=' || glbx.rndsurl(surl) || '&footer=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                    '&start_from=1' || '&display_detail=' || dispvert || '&acid=' || acid,
                    htf.img(cust_button(pfx,'modtoggle.gif',2), cattributes=>'BORDER=0', calt=>'Toggle Display' )));
      if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

    -- Next Button
    if ((start_from + numb_photos) <= search_total) and
       is_bf(theme_rec,ltype,207,208,'T','T',264,'T')
     then
      htp.tabledata(htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                    '&start_from=' ||  to_char(start_from + numb_photos) || '&display_detail=' || dispvert || '&acid=' || acid,
                    htf.img(cust_button(pfx,'modnext.gif',2), cattributes=>'BORDER=0', calt=>LNG2.PFM_TXT_088 )));
      if show_vertically then htp.tablerowclose; htp.tablerowopen; end if;
    end if;

   htp.tablerowclose;
   htp.tableclose;
exception when others then
 glbx.error_details( 'CST', 'DISP_BY_SCENE_BUTTONS',null,null );
end disp_by_scene_buttons_standard;

procedure disp_by_scene_buttons_grouped
  (surl in varchar2, sess_id integer, ltype in varchar2, title in varchar2, umrec in UMP.SEARCH_RESULT_PHG, cusrec in customer_account%ROWTYPE, left_api_parm in varchar2,
   start_from in integer, search_total in integer, footer_api in varchar2, numb_photos in integer,
   lbox in varchar2, lboxall in varchar2,
   theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE, dispvert in varchar2 default 'T', acid in integer default null, with_title in boolean, pbook in phg_price_book%ROWTYPE )
as

 cursor c2(sess_id integer) is
   select /*+ ALL_ROWS */ count('x') tot
   from lightbox l
   where l.sessid = sess_id;

 c2rec		c2%ROWTYPE;
 cd1		varchar2(32767);
 cd2		varchar2(20);

begin
    -- 186,187 Enable all buttons
    open c2(sess_id);
    fetch c2 into c2rec;
    close c2;

    if with_title
     then
      htp.tableopen( cattributes=>'width="100%" rules="NONE" frame="HSIDES,VSIDES" border=1');
     else
      --htp.tableopen( cattributes=>'width="100%" border=1 frame="VOID" RULES="COLS"');
      htp.tableopen( cattributes=>'width="100%" border=0');
    end if;
    htp.tablerowopen;

    -- Previous Button (Group 1)
    htp.p( '<TD ALIGN="LEFT" VALIGN="TOP">' );
    if with_title then htp.bold( 'Navigation' ); htp.nl; end if;
    if (start_from > 1) and ((start_from - numb_photos) >= 1) and
       is_bf(theme_rec,ltype,207,208,'T','T',264,'T')
     then
      htp.p(htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                               '&start_from=' ||  to_char(start_from - numb_photos) || '&display_detail=' || dispvert || '&acid=' || acid,
                    htf.img(cust_button(pfx,'modprev.gif',2), cattributes=>'BORDER=0', calt=>LNG2.PFM_TXT_085 )));
    end if;

    -- Customer can toggle between vertical and horizontal display
    -- if is_bf(theme_rec,ltype,198,199,'T','T',265,'T') (Old Call)
    if pfx.toggle_style is not null
     then
      if dispvert = pfx.display_style
       then
          htp.p(htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || pfx.toggle_style || '&acid=' || acid,
                        htf.img( cust_button(pfx,'summary.gif',2),cattributes=>'border=0', calt=>LNG3.ADM_TXT_619 )));
       elsif dispvert = pfx.toggle_style
        then
          htp.p(htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || pfx.display_style || '&acid=' || acid,
                        htf.img( cust_button(pfx,'detail.gif',2),cattributes=>'border=0', calt=>LNG4.AHC_TXT_396 )));
      end if;
    end if;

    -- Next Button
    if ((start_from + numb_photos) <= search_total) and
       is_bf(theme_rec,ltype,207,208,'T','T',264,'T')
     then
      htp.p(htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                    '&start_from=' ||  to_char(start_from + numb_photos) || '&display_detail=' || dispvert || '&acid=' || acid,
                    htf.img(cust_button(pfx,'modnext.gif',2), cattributes=>'BORDER=0', calt=>LNG2.PFM_TXT_088 )));
    end if;
    htp.p( '</TD>' );


    -- Shopping Trolley  (Group 2)
    htp.p( '<TD ALIGN="CENTER" VALIGN="TOP">' );
    if with_title then htp.bold( 'Actions' ); htp.nl; end if;
    if is_bf(theme_rec,ltype,205,206,'T','T',267,'T')
     then
      htp.p(htf.formimage( 'Add_To_Trolley',cust_button(pfx,'order.gif',2), cattributes=>'BORDER=0' ));
    end if;

    -- Display Photo Details
    if is_bf(theme_rec,ltype,181,184,'T','T',266,'T')
     then
      htp.p(htf.formimage( 'Display',cust_button(pfx,'display.gif',2), cattributes=>'BORDER=0'  ));
    end if;

     -- Modify Images
    if is_bf(theme_rec,ltype,203,204,'T','T',268,'T')
      then
       htp.p(htf.formimage( 'Modify_Details',cust_button(pfx,'moddet.gif',2), cattributes=>'BORDER=0'  ));
    end if;

    -- Whats New
    if is_bf(theme_rec,ltype,423,NULL,'T','T',422,'T')
      then
          htp.p(htf.anchor( 'cst.whatsnew' || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'whatsnew.gif',9),cattributes=>'border=0', calt=>LNG5.EXT_TXT_050 )));
    end if;

    -- Package Product xxx for language file
    if pbook.call_location in ('2','4','5','7')
      then
       htp.p(htf.anchor( 'cst.packprod_hdr' || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'packprod.gif',9),cattributes=>'border=0', calt=>'Choose a Package' )));
    end if;
    if pbook.call_location in ('1','2','4','5','7')
      then
       htp.p(htf.anchor( 'cst.packprod_edit' || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'packprode.gif',9),cattributes=>'border=0', calt=>'Edit Package Details' )));
    end if;

    htp.p( '</TD>' );

    --
    -- Activities  (Group 3)
    --
    -- See Previous Orders (Note: Guests cannot see previous orders as their logon id is anonymous)
    htp.p( '<TD ALIGN="CENTER" VALIGN="TOP">' );
    if with_title then htp.bold( 'Activities' ); htp.nl; end if;
    if is_bf(theme_rec,ltype,393,null,'T','T',392,'T') and ltype in ('PHOTOGRAPHER','OWNER','PROFILE','VIRTUAL')
      then
          htp.p(htf.anchor( 'cst.previous_orders' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'prv.gif',9),cattributes=>'border=0', calt=>LNG4.AHC_TXT_629 )));
    end if;

    -- Category Special MiniSlideshow
    if is_bf(theme_rec,ltype,425,426,'T','T',424,'T')
     then
      if search_total > 0 and footer_api = 'cst.disp_category' -- and integrate business feature
       then
        htp.p(
          '<A HREF="javascript: window.open(''sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&dispstyle=SETUP&uscid=' || left_api_parm || '&acid=' || acid || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=700,height=500'');void('''');">' ||
          htf.img( cust_button(pfx,'catshow.gif',9),cattributes=>'border=0', calt=>'Show Images by Category' ) || '</A>');
      elsif search_total > 0 and footer_api <> 'cst.disp_category' and umrec.count > 0
        then
         cd2 := umrec(umrec.first).umo_id;
         for j in umrec.first..umrec.last loop
          cd1 := cd1 || ';' || umrec(j).umo_id;
         end loop;
         cd1 := cd1 || ';';
         htp.p(
           '<A HREF="javascript: window.open(''sld.slideshow_category?surl=' || glbx.rndsurl(surl) || '&dispstyle=FRAME&uscid=' || left_api_parm || '&acid=' || acid || '&codes=' || cd1 || '&currcode=' || cd2 || '&ttl=' || replace(title,' ','+') || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=700,height=500'');void('''');">' ||
           htf.img( cust_button(pfx,'catshow.gif',9),cattributes=>'border=0', calt=>'Show Images by Category' ) || '</A>');
      end if;
    end if;

    -- Registration
    if is_bf(theme_rec,ltype,399,400,'T','T',398,'T')
      then
       if ltype in ('PROFILEG','CUSTOMER')
        then
          htp.p(htf.anchor( 'cst.cust_contact' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid || '&profid=&ACTION=NEW',
                        htf.img( cust_button(pfx,'regn.gif',9),cattributes=>'border=0', calt=>LNG4.AHC_TXT_802 )));
       elsif ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
        then
          htp.p(htf.anchor( 'cst.cust_contact' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid || '&profid=&action=UPDATE',
                        htf.img( cust_button(pfx,'regc.gif',9),cattributes=>'border=0', calt=>LNG4.AHC_TXT_801 )));
       end if;
    end if;

    -- Simple RFQ
    if is_bf(theme_rec,ltype,390,391,'T','T',389,'T')
      then
          htp.p(htf.anchor( 'cst.srfq' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'rfq.gif',9),cattributes=>'border=0', calt=>LNG4.AHC_TXT_630 )));
    end if;
    -- Toggle Display
    if cusrec.toggle_default in ( 'A', 'R' ) and
       footer_api <> 'cst.disp_lightbox'
      then
      htp.p(htf.anchor( 'cst.handle_toggle?surl=' || glbx.rndsurl(surl) || '&footer=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                    '&start_from=1' || '&display_detail=' || dispvert || '&acid=' || acid,
                    htf.img(cust_button(pfx,'modtoggle.gif',2), cattributes=>'BORDER=0', calt=>'Toggle Display' )));
    end if;
    htp.p( '</TD>' );


    --
    -- Lightbox Management Buttons  (Group 4)
    --
    -- Add to Lightbox
    --
    htp.p( '<TD ALIGN="RIGHT" VALIGN="TOP">' );
    if with_title then htp.bold( lbox ); htp.nl; end if;
    if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and
       footer_api <> 'cst.disp_lightbox'
      then
       htp.p(htf.formimage( 'Add_Lightbox',cust_button(pfx,'lightbox.gif',8), cattributes=>'BORDER=0'  ));
       htp.p(htf.anchor( 'cst.add_all_lightbox?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid || '&p1=' || lboxall,
                        htf.img( cust_button(pfx,'lightboxall.gif',8),cattributes=>'border=0', calt=>LNG5.EXT_TXT_109 || ' ' || lbox ) ));
       if c2rec.tot > 0
        then
          htp.p(htf.anchor( 'cst.disp_lightbox?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                        '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                        htf.img( cust_button(pfx,'seelight.gif',8),cattributes=>'border=0', calt=>LNG4.AHC_TXT_435 || ' ' || lbox ) ));
       end if;
       -- Only Valid Authorised User Sessions can create their own lightbox
       if ltype in ('PHOTOGRAPHER','OWNER','PROFILE' )
        then
        htp.p(htf.anchor( 'cst.mng_lightbox?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                      '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                       htf.img( cust_button(pfx,'lboxes.gif',8),cattributes=>'border=0', calt=>LNG5.EXT_TXT_051 || ' ' || lbox ) ));
       end if;
    end if;

    -- Delete from Lightbox
    if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and
       footer_api = 'cst.disp_lightbox'
      then
       htp.p(htf.formimage( 'Empty_Lightbox',cust_button(pfx,'emptylight.gif',8), cattributes=>'BORDER=0'  ));
       htp.p(htf.formimage( 'Del_Lightbox',cust_button(pfx,'dellight.gif',8), cattributes=>'BORDER=0'  ));
       -- Only Valid Authorised User Sessions can create their own lightbox
       if ltype in ('PHOTOGRAPHER','OWNER','PROFILE' )
        then
        htp.p(htf.anchor( 'cst.mng_lightbox?surl=' || glbx.rndsurl(surl) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                      '&start_from=' || start_from || '&display_detail=' || dispvert || '&acid=' || acid,
                       htf.img( cust_button(pfx,'lboxes.gif',8),cattributes=>'border=0', calt=>LNG5.EXT_TXT_051 || ' ' || lbox ) ));
       end if;
    end if;
    htp.p( '</TD>' );
    -- Lighbox List of Values
    if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and
       footer_api <> 'cst.disp_lightbox'
      then
       htp.tabledata(lightbox_headers('LBOXID',cusrec.aid,ltype),cattributes=>'ALIGN="RIGHT" VALIGN="BOTTOM" CLASS="SMALL"');
    end if;

   htp.tablerowclose;
   htp.tableclose;
exception when others then
 glbx.error_details( 'CST', 'DISP_BY_SCENE_BUTTONS_GROUPED',null,null );
end disp_by_scene_buttons_grouped;

procedure display_thumbnail(surl in varchar2, ltype in varchar2, umrec in UMO%ROWTYPE, theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE,
                            footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, hor_caption in varchar2,
                            document_api in varchar2, video_api in varchar2, audio_api in varchar2, relational_api in varchar2, blueprint_api in varchar2, acid in integer default null,
                            display_original in varchar2 default null, stype in integer default 1, extra_term in varchar2 default null, image_style in varchar2 default 'STYLE="display:block;"' )
as

 tmp	varchar2(1000);
 url	varchar2(32767);

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
   else
    -- Type is PHOTO (or no API built to support other types)
     if hor_caption is null
      then
       tmp := LNG.CST_TXT_183 || ' -' || umrec.extras.photo_name;
      else
       tmp := hor_caption;
     end if;

     if ltype = 'PHOTOGRAPHER'
      then
       if display_detail = 'S'
        then
         url := footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=[' || umrec.umo_id || ']' || replace(left_api_parm,' ','+') || '&start_from=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid;
        else
         url := 'phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&phgid=' || umrec.umo_id || '&acid=' || acid || '&msg=&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail;
       end if;
      else
       if display_detail = 'S'
        then
         url := footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=[' || umrec.umo_id || ']' || replace(left_api_parm,' ','+') || '&start_from=' || current_page_number || '&display_detail=' || display_detail;
        else
         url := 'cst.disp_acct_photo?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec.umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&how_display=' || pfx.fullimg_display_type || '&extra_term=' || replace(extra_term,' ','+');
       end if;
     end if;

     if ltype = 'PHOTOGRAPHER'
      then
       glbx.image_matte(pfx,umrec.photo_thumbnail.width,umrec.photo_thumbnail.height,
                        url,
                        '<IMG BORDER=0 WIDTH=' || umrec.photo_thumbnail.width || ' HEIGHT=' || umrec.photo_thumbnail.height || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=AID&parm2=' || acid || '&parm1=VERSION&parm2=' || umrec.version ||
                          '" ALT="' || tmp || '"' || image_style || '>',null );
      else
       if pfx.fullimg_jscript_popup = 'F' or display_detail = 'S' -- Slider display never pops up
        then
         glbx.image_matte(pfx,umrec.photo_thumbnail.width,umrec.photo_thumbnail.height,
                          url,
                          '<IMG BORDER=0 WIDTH=' || umrec.photo_thumbnail.width || ' HEIGHT=' || umrec.photo_thumbnail.height || ' SRC="' ||
                          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umrec.version ||
                          '" ALT="' || tmp || '"' || image_style || '>',null );
        else
         --
         url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_037,' ','_') || ''',''' || popup_size(stype,umrec,pfx,display_original) || ',scrollbars=yes,resizable=yes'');void('''');';
         glbx.image_matte(pfx,umrec.photo_thumbnail.width,umrec.photo_thumbnail.height,
                          url,
                          '<IMG BORDER=0 WIDTH=' || umrec.photo_thumbnail.width || ' HEIGHT=' || umrec.photo_thumbnail.height || ' SRC="' ||
                          'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umrec.version ||
                          '" ALT="' || tmp || '"' || image_style || '>',null );
       end if;
     end if;
   end if;
exception
 when others then
 glbx.error_details( 'CST', 'DISPLAY_THUMBNAIL', errmsg=>sqlerrm,extdet=>'UMO_ID:' || umrec.umo_id);
end display_thumbnail;

procedure display_who( surl in varchar2, ltype in varchar2, theme_rec theme_types%ROWTYPE, photo_id in integer, nmb1 in integer, nmb2 in integer, nmb3 in integer, nmb4 in integer, nmb5 in integer, nmb6 in integer,
                       footer_api in varchar2, left_api_parm in varchar2, current_page_number in varchar2, display_detail in varchar2, acid in integer default null, retstop in varchar2)
as

 cursor c3(v_umo integer) is
  select ut.value
  from umo_attribute ut, umo_attributes uts
  where ut.attribute_id = uts.attribute_id and
        uts.category = 'IN THE PHOTO' and
        uts.sub_category = 'PERSON' and
        ut.umo_id = v_umo
  order by ut.position_id;

tmp	varchar2(32767);

begin
 -- Who is in the Image
 if is_bf(theme_rec,ltype,nmb1,nmb2,'T','T',nmb3,'T')
  then
   if is_bf(theme_rec,ltype,nmb4,nmb5,'T','T',nmb6,'T')
    then
     /*
   addname(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );
     htp.anchor2('cst.add_name?surl=' || glbx.rndsurl(surl) || '&photo_id=' || photo_id || '&stp=' || retstop ||
                 '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,
                 htf.img( DECS.IMAGE_LOCATION || 'adminc/add_names.gif',cattributes=>'border=0',calt=>lng.CST_ALT_029 ));
     */
     htp.anchor2('gimmick.main?surl=' || glbx.rndsurl(surl) || '&nvid=310&loc_id=' || photo_id || '&first_parameter=ADDNAME&called_from=MAIN' ||
                 '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,
                 htf.img( DECS.IMAGE_LOCATION || 'adminc/add_names.gif',cattributes=>'border=0',calt=>lng.CST_ALT_029 ));
   end if;

   if is_bf(theme_rec,ltype,nmb4,nmb5,'T','T',nmb6,'T')
    then
     htp.bold( lng.CST_TXT_066 );
     htp.nl;
     tmp := null;
     for c3rec in c3(photo_id) loop
      if c3rec.value is not null
       then
        tmp := tmp || ', ' || c3rec.value;
      end if;
     end loop;
     htp.italic( substr( tmp,3 ));
     htp.nl;
    end if;

    if is_bf(theme_rec,ltype,nmb4,nmb5,'T','T',nmb6,'T') and display_detail not in ('T')
      then
     htp.anchor2('glbx.main?surl=' || glbx.rndsurl(surl) || '&nvid=310&loc_id=' || photo_id || '&first_parameter=ADDNAME&called_from=MAIN' ||
                 '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,
                 lng.CST_TXT_068);
/*
 htp.anchor2('cst.add_name?surl=' || glbx.rndsurl(surl) || '&photo_id=' || photo_id || '&stp=' || retstop ||
                   '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,
                  lng.CST_TXT_068);
*/
    end if;
 end if;
end display_who;

procedure display_comments( surl in varchar2, umrec in UMO%ROWTYPE, theme_rec in theme_types%ROWTYPE, cusrec in customer_account%ROWTYPE, ltype in varchar2,
                            nmb1 in integer, nmb2 in integer, nmb3 in integer, nmb4 in integer, nmb5 in integer, nmb6 in integer, backcol in varchar2,
                            footer_api in varchar2, left_api_parm in varchar2, current_page_number in varchar2, display_detail in varchar2, acid in integer default null, retstop in varchar2)
as

 cursor c3(photo_id integer) is
  select ut.position_id,uts.sub_category,ut.value
  from umo_attribute ut, umo_attributes uts
  where ut.attribute_id = uts.attribute_id and
        uts.category = 'COMMENT' and
        ut.umo_id = photo_id
  order by ut.position_id,ut.date_made desc;

 exitloop	boolean;
 made_by	varchar2(100);
 the_comment	varchar2(1000);
 lastpos	integer;
 tstnull	varchar2(100);
 temp		varchar2(32767);

begin
   -- Comments
   if is_bf(theme_rec,ltype,nmb3,nmb4,'T','T',nmb5,'T') or is_bf(theme_rec,ltype,nmb1,nmb2,'T','T',nmb6,'T')
    then
     if is_bf(theme_rec,ltype,nmb1,nmb2,'T','T',nmb6,'T')
      then
      /*
       htp.anchor2('cst.add_comment?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec.umo_id || '&stp=' || retstop ||
                   '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,
                   htf.img( DECS.IMAGE_LOCATION || 'adminc/add_comments.gif',cattributes=>'border=0',calt=>lng.CST_TXT_141 ));
      */
     htp.anchor2('gimmick.main?surl=' || glbx.rndsurl(surl) || '&nvid=310&loc_id=' || umrec.umo_id || '&first_parameter=ADDCOMMENT&called_from=MAIN' ||
                 '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid,
                 htf.img( DECS.IMAGE_LOCATION || 'adminc/add_comments.gif',cattributes=>'border=0',calt=>lng.CST_TXT_141 ));
       htp.bold( glbx.userpref( cusrec.pid, cusrec.aid, 'COMMENT' ) || ':' );
     end if;
     temp := NULL;
     exitloop := FALSE;
     lastpos := 1;
     made_by := NULL;
     the_comment := NULL;
     for c3rec in c3(umrec.umo_id) loop
      if (lastpos <> c3rec.position_id)
       then
        if made_by is not null or the_comment is not null then temp := temp || htf.bold(made_by) || htf.nl || htf.italic( the_comment ) || htf.nl; end if;
        if (c3rec.position_id >= 4) or (length(temp) > 30000)
         then
            if is_bf(theme_rec,ltype,nmb1,nmb2,'T','T',nmb6,'T')
             then
              if temp is null
               then
                -- temp := htf.anchor('cst.add_comment?surl=' || glbx.rndsurl(surl) || '&stp=' || retstop || '&photo_id=' || umrec.umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid, lng.CST_TXT_054);
                temp := htf.anchor('gimmick.main?surl=' || glbx.rndsurl(surl) || '&nvid=310&loc_id=' || umrec.umo_id || '&first_parameter=ADDCOMMENT&called_from=MAIN' || '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid, lng.CST_TXT_054);

               else
                -- temp := temp || htf.nl || htf.anchor('cst.add_comment?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec.umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid, lng.CST_TXT_054);
                temp := temp || htf.nl || htf.anchor('gimmick.main?surl=' || glbx.rndsurl(surl) || '&nvid=310&loc_id=' || umrec.umo_id || '&first_parameter=ADDCOMMENT&called_from=MAIN' || '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid, lng.CST_TXT_054);
              end if;
            end if;
         exitloop := TRUE;
         exit;
        end if;
        made_by := NULL;
        the_comment := NULL;
        lastpos := c3rec.position_id;
      end if;
      if c3rec.sub_category = 'MADE BY' then made_by := c3rec.value; elsif c3rec.sub_category = 'THE COMMENT' then the_comment := c3rec.value; end if;
     end loop;

     if not exitloop
      then
       if made_by is not null or the_comment is not null
         then
	  if is_bf(theme_rec,ltype,nmb3,nmb4,'T','T',nmb5,'T')
	   then
	    temp := temp || htf.italic( the_comment ) || htf.nl;
	   else
	    temp := temp || htf.bold(made_by) || htf.nl || htf.italic( the_comment ) || htf.nl;
	  end if;
       end if;
       if is_bf(theme_rec,ltype,nmb1,nmb2,'T','T',nmb6,'T') and is_bf(theme_rec,ltype,nmb3,nmb4,'F','F',nmb5,'F') and (umrec.umo_type <> 'MANUFACTURER') and display_detail not in ('T')
	then
	 -- temp := nvl(temp,'&nbsp;') || htf.anchor('cst.add_comment?surl=' || glbx.rndsurl(surl) || '&photo_id=' || umrec.umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid, lng.CST_TXT_055);
         temp := nvl(temp,'&nbsp;') || htf.anchor('gimmick.main?surl=' || glbx.rndsurl(surl) || '&nvid=310&loc_id=' || umrec.umo_id || '&first_parameter=ADDCOMMENT&called_from=MAIN' || '&footer_api=' || translate(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid, lng.CST_TXT_054);
        end if;
     else
      temp := nvl(temp,'&nbsp;');
     end if;

     htp.tabledata( temp, cattributes=>backcol || ' valign="TOP" align="LEFT" CLASS="SMALL"' );

   end if;

end display_comments;

procedure goto_page( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, display_detail in varchar2, search_total in integer, acid in integer, currpage in integer, page in varchar2 )
as

 c1rec		customer_account%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 numb_photos	integer;

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'THES.GOTO_PAGE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 if acid is null
  then
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'NUMBER_PHOTOS'));
   numb_photos := nvl(numb_photos,10);
  else
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'PHOTO_DISPLAY'));
   numb_photos := nvl(numb_photos,10);
 end if;

 begin nmb := abs(to_number(page)); exception when others then nmb := NULL; end;
 if nmb = 0 then nmb := null; end if;

 nmb := numb_photos * nmb;
 if nmb > search_total then nmb := search_total; end if;
 if nmb is null then nmb := currpage; end if;

 execute immediate
   'begin ' || footer_api ||
    '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
    'end;'
  using glbx.rndsurl(surl),left_api_parm,nmb,display_detail,acid;

exception when others then
 glbx.error_details( 'CST', 'GOTO_PAGE',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'page: ' || page || ' footer_api:' || footer_api || ' left_api_parm:' || left_api_parm );
end goto_page;

procedure disp_category( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null )
as

 cursor c2a(acid integer, uscid integer, utype varchar2, sess_id integer, exc number, exc_max number, srt char) is
   select *
   from umo um
   where um.umo_scene_id = uscid and
         um.aid = acid and
         ( (exclusive_purchased = 'F') or
           (date_created + exc <= sysdate and exclusive_purchased = 'T' )
         ) and
        ((um.sessid is null or utype = 'PHOTOGRAPHER') or (um.sessid is not null and sessid = sess_id)) and
         umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
         ((utype = 'PHOTOGRAPHER') or
          (utype = 'OWNER' and um.extras.enabled_phg='TRUE') or
          (utype = 'CUSTOMER' and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by decode(srt,'F',to_char(um.sort_priority,'0000000'),'T',um.extras.film_name),to_char(um.extras.orderby_nmb,'0000000'),to_char(um.umo_id,'0000000');


 cursor c2a_prof(profid integer, acid integer, uscid integer, utype varchar2, sess_id integer, exc number, exc_max number, srt char) is
   select *
   from umo um
   where um.umo_scene_id = uscid and
         ( (exclusive_purchased = 'F') or
           (date_created + exc <= sysdate and exclusive_purchased = 'T' )
         ) and
        ((um.sessid is null or utype = 'PHOTOGRAPHER') or (um.sessid is not null and sessid = sess_id)) and
        (um.umo_scene_id in (select umo_scene_id from profile_scenes where profile_id = profid) or
         0 = (select count('x') tot from profile_scenes where profile_id = profid)
         ) and
         umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
         um.aid = acid and
         ((utype = 'PROFILE' and um.extras.enabled_phg='TRUE') or
          (utype = 'PROFILEG' and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   order by decode(srt,'F',to_char(um.sort_priority,'0000000'),to_char(um.extras.orderby_nmb,'0000000'),to_char(um.umo_id,'0000000'),'T',um.extras.film_name);

 cursor c2b(voidrec_spb integer) is
  select /*+ ALL_ROWS */ ppit.umo_id,ppit.ppi,repeated_fields(ppit.manufacturer_id,null,ppit.umo_id,
         to_char(decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
                ),LNG.MONEY_FORMAT),
         ppi,ppit.name,ppit.name,'TRUE','TRUE') rf,ppi vrs, p.attached_doco,ppit.stock_less_than_value,ppit.stock_less_purch,ppit.stock_less_than_desc,p.current_stock, p.detailed_desc
  from product p,phg_price_item ppit,phg_price_book ppb
  where ppit.spb = voidrec_spb and
        shop_item = 'T' and
        ppb.spb = ppit.spb and
        p.product_id = ppit.lab_id and
        shop_style = LNG2.FNM_TXT_109
  order by ppit.name;

 cursor c2c(acid integer, uscid integer, voidrec_spb integer) is
  select /*+ ALL_ROWS */ ppit.umo_id,ppit.ppi,repeated_fields(ppit.manufacturer_id,null,ppit.umo_id,
         to_char(decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ),LNG.MONEY_FORMAT),
         ppit.ppi,ppit.name,ppit.name,'TRUE','TRUE') rf,ppit.ppi vrs,p.attached_doco,ppit.stock_less_than_value,ppit.stock_less_purch,ppit.stock_less_than_desc,p.current_stock, p.detailed_desc
  from product p, phg_price_item ppit,phg_price_book ppb, price_book_category pbc
  where ppit.spb = voidrec_spb and
        shop_item = 'T' and
        pbc.aid = acid and
        pbc.umo_scene_id = uscid and
        ppb.spb = ppit.spb and
        pbc.ppi = ppit.ppi and
        p.product_id = ppit.lab_id and
        shop_style = LNG4.AHC_TXT_077
  order by ppit.name;

 cursor c3(v_umo integer) is
  select um.photo_thumbnail from umo um where umo_id = v_umo;

 cursor c4(acid integer, uscid integer, utype varchar2, sess_id integer, exc number, exc_max number, voidrec_spb integer) is
  select /*+ ALL_ROWS */ sum(tot) tot
  from
  (
  select count('x') tot
  from umo um
  where um.umo_scene_id = uscid and
        um.aid = acid and
         ( (exclusive_purchased = 'F') or
           (date_created + exc <= sysdate and exclusive_purchased = 'T' )
         ) and
        ((um.sessid is null or utype = 'PHOTOGRAPHER') or (um.sessid is not null and sessid = sess_id)) and
        umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ((utype = 'PHOTOGRAPHER') or
         (utype = 'OWNER' and um.extras.enabled_phg='TRUE') or
         (utype = 'CUSTOMER' and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
  union all
  select count('x') tot
  from product p,phg_price_item ppi,phg_price_book ppb
  where ppi.spb = voidrec_spb and
        shop_item = 'T' and
        ppb.spb = ppi.spb and
        p.product_id = ppi.lab_id and
        shop_style = LNG2.FNM_TXT_109
  union all
  select count('x') tot
    from product p, phg_price_item ppit,phg_price_book ppb, price_book_category pbc
    where ppit.spb = voidrec_spb and
          shop_item = 'T' and
          pbc.aid = acid and
          pbc.umo_scene_id = uscid and
          ppb.spb = ppit.spb and
          pbc.ppi = ppit.ppi and
          p.product_id = ppit.lab_id and
          shop_style = LNG4.AHC_TXT_077
   );

--        um.umo_scene_id in (select umo_scene_id from profile_scenes where profile_id = profid) and

 cursor c4_prof(profid integer, acid integer, uscid integer, utype varchar2, sess_id integer, exc number, exc_max number, voidrec_spb integer) is
  select /*+ ALL_ROWS */ sum(tot) tot
  from
  (
  select count('x') tot
  from umo um
  where um.umo_scene_id = uscid and
        um.aid = acid and
         ( (exclusive_purchased = 'F') or
           (date_created + exc <= sysdate and exclusive_purchased = 'T' )
         ) and
        ((um.sessid is null or utype = 'PHOTOGRAPHER') or (um.sessid is not null and sessid = sess_id)) and
        (um.umo_scene_id in (select umo_scene_id from profile_scenes where profile_id = profid) or
         0 = (select count('x') tot from profile_scenes where profile_id = profid)
         ) and
        umo_type in ('PHOTO','DOCUMENT','VIDEO','AUDIO','RELATIONAL','BLUEPRINT') and
        ((utype = 'PROFILE' and um.extras.enabled_phg='TRUE') or
         (utype = 'PROFILEG' and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
  union all
  select count('x') tot
  from product p,phg_price_item ppi,phg_price_book ppb
  where ppi.spb = voidrec_spb and
        shop_item = 'T' and
        ppb.spb = ppi.spb and
        p.product_id = ppi.lab_id and
        shop_style = LNG2.FNM_TXT_109
  union all
  select count('x') tot
    from product p, phg_price_item ppit,phg_price_book ppb, price_book_category pbc
    where ppit.spb = voidrec_spb and
          shop_item = 'T' and
          pbc.aid = acid and
          pbc.umo_scene_id = uscid and
          ppb.spb = ppit.spb and
          pbc.ppi = ppit.ppi and
          p.product_id = ppit.lab_id and
          shop_style = LNG4.AHC_TXT_077
   );

 cursor c5(scnm integer) is select title from umo_scene where umo_scene_id = scnm;
 cursor c6(acid integer, sess_id integer,voidrec_spb integer) is
  select (nvl(decode(nvl(ls.country,pp.value),pp.value,ppi.exclusive_local,ppi.exclusive_int),0) * 60) / (86500) exc,
  greatest(nvl(ppi.exclusive_local,0),nvl(ppi.exclusive_int,0)) exc_max
  from
   login_session ls, phg_price_item ppi,phg_price_book ppb, photographer_preference pp
  where ppi.spb = voidrec_spb and
        ppb.spb = ppi.spb and
        pp.prefid = 43 and
        pp.aid = acid and
        ls.sessid = sess_id;

 cursor c7(sess_id integer, v_umo integer) is select lightid from lightbox where sessid = sess_id and umo_id = v_umo;

 ctr		integer;
 c1rec		customer_account%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 numb_photos	integer;
 total_records	integer;
 lap		integer;
 sts		varchar2(100);
 b2c_value	char(1);
 result_list	UMP.SEARCH_RESULT_PHG;
 theme_rec 	theme_types%ROWTYPE;
 gal		varchar2(100);

function checkexp( v1 in varchar2, expr in varchar2, v2 in varchar2 )
 return boolean
as
begin
 if expr = '=' then return( v1 = v2 );
 elsif expr = '<' then return( v1 < v2 );
 elsif expr = '>' then return( v1 > v2 );
 elsif expr = '<=' then return( v1 <= v2 );
 elsif expr = '>=' then return( v1 >= v2 );
 elsif expr = '!=' then return( v1 != v2 );
 elsif expr = 'LIKE' then return( v1 like v2 || '%' );
 end if;
end checkexp;

function keep_record( cusrec in customer_account%ROWTYPE, umorec in umo%ROWTYPE )
 return boolean
as
 cursor c1(v_umo integer, attribid integer) is select value from umo_attribute where umo_id = v_umo and attribute_id = attribid;
 c1rec  c1%ROWTYPE;
 kr	boolean;
begin
 if cusrec.toggle_default in ('A','R')
  then
   if gal = 'A'
    then
     return( TRUE );
    else
     if cusrec.toggle_tag = -1
      then
       return( checkexp( umorec.extra_film_size, cusrec.toggle_condition, cusrec.toggle_value ) );
     elsif cusrec.toggle_tag = -2
      then
       return( checkexp( umorec.extra_roll_id, cusrec.toggle_condition, cusrec.toggle_value ) );
     elsif cusrec.toggle_tag = -3
      then
       return( checkexp( umorec.extra_film_colour, cusrec.toggle_condition, cusrec.toggle_value ) );
     elsif cusrec.toggle_tag = -4
      then
       return( checkexp( umorec.extras.photo_name, cusrec.toggle_condition, cusrec.toggle_value ) );
     else
      open c1( umorec.umo_id, cusrec.toggle_tag );
      fetch c1 into c1rec;
      close c1;
      return( checkexp( c1rec.value, cusrec.toggle_condition, cusrec.toggle_value ) );
     end if;
   end if;
  else
   return( TRUE );
 end if;

end keep_record;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.DISP_CATEGORY' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( c1rec.aid, profid, ltype, b2c_value ));
 if c1rec.toggle_default in ('A','R')
  then
   gal := glbx.get_login_application( owner_id, 'TOGGLE' );
 end if;

 -- xxx get price book and check for first access into packaged product

 -- Get Exclusivity Information
 open c6(c1rec.aid,owner_id,voidrec.spb);
 fetch c6 into c6rec;
 close c6;

 ctr := 1;
 if acid is null
  then
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'NUMBER_PHOTOS'));
   numb_photos := nvl(numb_photos,10);
  else
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'PHOTO_DISPLAY'));
   numb_photos := nvl(numb_photos,10);
 end if;

 if substr(left_api_parm,1,1) = '['
  then
   if substr(left_api_parm,1,6) = '[LBOX:'
    then
     -- Ignore Lightbox Reference
     lap := substr(left_api_parm,instr(left_api_parm,']',1,2)+1);
    else
     lap := substr(left_api_parm,instr(left_api_parm,']')+1);
   end if;
  else
   lap := left_api_parm;
 end if;

 if ltype in ('PROFILE','PROFILEG')
  then
   for c2arec in c2a_prof(profid,c1rec.aid,lap,ltype,owner_id,c6rec.exc,c6rec.exc_max, substr(theme_rec.theme_data,428,1)) loop

    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos)
       then
        exit;
       else
        if keep_record( c1rec, c2arec )
         then
          result_list( result_list.count + 1 ) := c2arec;
          -- Check if Lightbox
          if substr(theme_rec.theme_data,427,1) = 'T'
           then
            open c7(owner_id,c2arec.umo_id);
            fetch c7 into c7rec;
            if c7%FOUND
             then
              result_list( result_list.count ).attribute1 := nvl(to_char(c7rec.lightid),'~');
            end if;
            close c7;
          end if;
        end if;
      end if;
    end if;
    ctr := ctr + 1;
   end loop;

  else
   for c2arec in c2a(c1rec.aid,lap,ltype,owner_id,c6rec.exc,c6rec.exc_max, substr(theme_rec.theme_data,428,1)) loop
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos)
       then
        exit;
       else
        if keep_record( c1rec, c2arec )
         then
          result_list( result_list.count + 1 ) := c2arec;
          -- Check if Lightbox
          if substr(theme_rec.theme_data,427,1) = 'T'
           then
            open c7(owner_id,c2arec.umo_id);
            fetch c7 into c7rec;
            if c7%FOUND
             then
              result_list( result_list.count ).attribute1 := nvl(to_char(c7rec.lightid),'~');
            end if;
            close c7;
          end if;
        end if;
      end if;
    end if;
    ctr := ctr + 1;
   end loop;
 end if;

 if ctr < (start_from + numb_photos)
  then
   for c2brec in c2b(voidrec.spb) loop
    if ctr < start_from
     then
      null;
     else
      if ctr >= (start_from + numb_photos)
       then
        exit;
       else
        result_list(ctr).umo_id := c2brec.umo_id;
        result_list(ctr).extras := c2brec.rf;
        result_list(ctr).version := c2brec.vrs;
        result_list(ctr).photo_thumbnail := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        result_list(ctr).photo_original := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        result_list(ctr).photo_master := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        if c2brec.umo_id is not null
         then
          open c3(c2brec.umo_id);
          fetch c3 into c3rec;
          close c3;
          result_list(ctr).photo_thumbnail := c3rec.photo_thumbnail;
         else
          result_list(ctr).photo_thumbnail.width := 0;
          result_list(ctr).photo_thumbnail.height := 0;
        end if;
        result_list(ctr).umo_type := 'MANUFACTURER';
        result_list(ctr).aid := c1rec.aid;
        result_list(ctr).photo_original.source.localdata := empty_blob();
        result_list(ctr).document_original_loc := c2brec.attached_doco;
        result_list(ctr).attribute1 := c2brec.stock_less_than_value;
        result_list(ctr).attribute2 := c2brec.stock_less_purch;
        result_list(ctr).attribute3 := c2brec.current_stock;
        result_list(ctr).attribute4 := c2brec.stock_less_than_desc;
        result_list(ctr).attribute5 := c2brec.detailed_desc;
        result_list(ctr).attribute6 := c2brec.ppi;
      end if;
    end if;
    ctr := ctr + 1;
   end loop;
 end if;

  if ctr < (start_from + numb_photos)
   then
    for c2crec in c2c(c1rec.aid,lap,voidrec.spb) loop
     if ctr < start_from
      then
       null;
      else
       if ctr >= (start_from + numb_photos)
        then
         exit;
        else
         result_list(ctr).umo_id := c2crec.umo_id;
         result_list(ctr).extras := c2crec.rf;
         result_list(ctr).version := c2crec.vrs;
         result_list(ctr).photo_thumbnail := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
         result_list(ctr).photo_original := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
         result_list(ctr).photo_master := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
         if c2crec.umo_id is not null
          then
           open c3(c2crec.umo_id);
          fetch c3 into c3rec;
           close c3;
           result_list(ctr).photo_thumbnail := c3rec.photo_thumbnail;
          else
           result_list(ctr).photo_thumbnail.width := 0;
           result_list(ctr).photo_thumbnail.height := 0;
         end if;
         result_list(ctr).umo_type := 'MANUFACTURER';
         result_list(ctr).aid := c1rec.aid;
         result_list(ctr).photo_original.source.localdata := empty_blob();
         result_list(ctr).document_original_loc := c2crec.attached_doco;
         result_list(ctr).attribute1 := c2crec.stock_less_than_value;
         result_list(ctr).attribute2 := c2crec.stock_less_purch;
         result_list(ctr).attribute3 := c2crec.current_stock;
         result_list(ctr).attribute4 := c2crec.stock_less_than_desc;
         result_list(ctr).attribute5 := c2crec.detailed_desc;
         result_list(ctr).attribute6 := c2crec.ppi;
       end if;
     end if;
     ctr := ctr + 1;
    end loop;
  end if;

  open c5(lap);
  fetch c5 into c5rec.title;
  close c5;
  if ltype in ('PROFILE','PROFILEG')
   then
    open c4_prof(profid,c1rec.aid,lap,ltype,owner_id,c6rec.exc,c6rec.exc_max,voidrec.spb);
    fetch c4_prof into total_records;
    close c4_prof;
   else
    open c4(c1rec.aid,lap,ltype,owner_id,c6rec.exc,c6rec.exc_max,voidrec.spb);
    fetch c4 into total_records;
    close c4;
  end if;
  glbx.extended_search_api( surl=>surl, ltype=>ltype, result_list=>result_list, search_total=>total_records,
                            display_detail=>display_detail, title=>c5rec.title,
                            left_api=>NULL, left_api_parm=>left_api_parm, footer_api=>'cst.disp_category',
                            current_page_number=>start_from,no_results_message=>LNG4.AHC_TXT_409,acid=>acid);

exception when others then
 glbx.error_details( 'CST', 'DISP_CATEGORY',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end disp_category;

procedure whatsnew( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null )
as

 vp2	GLBX.MYARRAY;
 vp3	GLBX.MYARRAY;
 vp5	GLBX.MYARRAY;
 vps	GLBX.MYARRAY;

begin
 vp2(1) := LNG.PHG_TXT_506;
 vp3(1) := '%';
 vp5(1) := LNG.PHG_TXT_509;
 vps(1) := NULL;
 run_query( surl, 0, p1s=>'F', acid=>acid, lbox=>'F', p1n=>LNG.PHG_TXT_055, isglb=>'F', p2=>vp2, p3=>vp3, p5=>vp5, ps=>vps, p1a=>'X' );

exception when others then
 glbx.error_details( 'CST', 'WHATSNEW',errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end whatsnew;

procedure disp_lightbox( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null )
as

 cursor c2(sess_id integer, acid integer, utype varchar2, lid integer ) is
  select *
  from umo um
  where um.umo_id in (select umo_id from lightbox lb where lb.sessid = sess_id and nvl(lb.lightid,0) = nvl(lid,0) ) and
        um.aid = acid and
        ((um.sessid is null or utype = 'PHOTOGRAPHER') or (um.sessid is not null and sessid = sess_id)) and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'));

 cursor c4(sess_id integer, acid integer, utype varchar2, lid integer) is
  select /*+ ALL_ROWS */ sum(tot) tot
  from
  (
  select count('x') tot
  from umo um, lightbox lb
  where um.umo_id = lb.umo_id and
        lb.sessid = sess_id and
        nvl(lb.lightid,0) = nvl(lid,0) and
        um.aid = acid and
        ((um.sessid is null or utype = 'PHOTOGRAPHER') or (um.sessid is not null and um.sessid = sess_id)) and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   );

 ctr		integer;
 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 numb_photos	integer;
 total_records	integer;
 lid		integer;
 sts		varchar2(100);
 lbox		varchar2(1000);
 result_list	UMP.SEARCH_RESULT_PHG;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.DISP_LIGHTBOX' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 ctr := 1;
 if acid is null
  then
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'NUMBER_PHOTOS'));
   numb_photos := nvl(numb_photos,10);
  else
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'PHOTO_DISPLAY'));
   numb_photos := nvl(numb_photos,10);
 end if;

 lid := NULL;
 if substr(left_api_parm,1,6) = '[LBOX:'
  then
   begin lid := substr(left_api_parm,7,instr(left_api_parm,']')-7); exception when others then lid := NULL; end;
 end if;

 for c2rec in c2(owner_id,c1rec.aid,ltype,lid) loop
  if ctr < start_from
   then
    null;
   else
    if ctr >= (start_from + numb_photos)
     then
      exit;
     else
      result_list( ctr ) := c2rec;
    end if;
  end if;
  ctr := ctr + 1;
 end loop;

 lbox := glbx.userpref(c1rec.pid,c1rec.aid,'LIGHTBOX');
 open c4(owner_id,c1rec.aid,ltype,lid);
 fetch c4 into total_records;
 close c4;
 glbx.extended_search_api( surl=>surl, ltype=>ltype, result_list=>result_list, search_total=>total_records,
                           display_detail=>display_detail, title=>lbox,
                           left_api=>NULL, left_api_parm=>left_api_parm, footer_api=>'cst.disp_lightbox',
                           current_page_number=>start_from,no_results_message=>LNG4.AHC_TXT_410,acid=>acid);

exception when others then
 glbx.error_details( 'CST', 'DISP_LIGHTBOX',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end disp_lightbox;

procedure disp_store( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null )
as

 cursor c2(voidrec_spb integer) is
  select ppi.umo_id,null,
         repeated_fields(ppi.manufacturer_id,null,ppi.umo_id,
         to_char(decode(nvl(item_discounted,'F'),'F',charge,
                decode(sign(sysdate - nvl(item_disc_from,sysdate)),-1,charge,0,charge,
                       decode(sign(nvl(item_disc_to,sysdate) - sysdate),-1,charge,0,charge,item_disc_charge)
                       )
               ),LNG.MONEY_FORMAT),
         ppi,ppi.name,ppi.name,'TRUE','TRUE') rf,
         ppi vrs, p.attached_doco,ppi.stock_less_than_value,ppi.stock_less_purch,ppi.stock_less_than_desc,p.current_stock
  from product p,phg_price_item ppi,phg_price_book ppb
  where ppi.spb = voidrec_spb and
        shop_item = 'T' and
        ppb.spb = ppi.spb and
        p.product_id = ppi.lab_id and
        shop_style = LNG2.FNM_TXT_108
  order by ppi.name;

 cursor c3(v_umo integer) is
  select um.photo_thumbnail from umo um where umo_id = v_umo;

 cursor c4(voidrec_spb integer) is
  select count('x') tot
  from product p,phg_price_item ppi,phg_price_book ppb
  where ppi.spb = voidrec_spb and
        shop_item = 'T' and
        ppb.spb = ppi.spb and
        p.product_id = ppi.lab_id and
        shop_style = LNG2.FNM_TXT_108;

 ctr		integer;
 c1rec		customer_account%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 numb_photos	integer;
 total_records	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 result_list	UMP.SEARCH_RESULT_PHG;
 b2c_value	char(1);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'CST.DISP_LIGHTBOX' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 voidrec := glbx.get_order_style( glbx.get_order_style( c1rec.aid, profid, ltype, b2c_value ));
 pfx := glbx.get_thm( c1rec.theme_name );

 ctr := 1;
 if acid is null
  then
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'NUMBER_PHOTOS'));
   numb_photos := nvl(numb_photos,10);
  else
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'PHOTO_DISPLAY'));
   numb_photos := nvl(numb_photos,10);
 end if;

 for c2rec in c2(voidrec.spb) loop
  if ctr < start_from
   then
    null;
   else
    if ctr >= (start_from + numb_photos)
     then
      exit;
     else
        result_list(ctr).umo_id := c2rec.umo_id;
        result_list(ctr).extras := c2rec.rf;
        result_list(ctr).version := c2rec.vrs;
        result_list(ctr).photo_thumbnail := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        result_list(ctr).photo_original := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        result_list(ctr).photo_master := ORDSYS.ORDImage(ORDSYS.ORDSource(empty_blob(), NULL,NULL,NULL,SYSDATE,1),NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        if c2rec.umo_id is not null
         then
          open c3(c2rec.umo_id);
          fetch c3 into c3rec;
          close c3;
          result_list(ctr).photo_thumbnail := c3rec.photo_thumbnail;
         else
          result_list(ctr).photo_thumbnail.width := 0;
          result_list(ctr).photo_thumbnail.height := 0;
        end if;
        result_list(ctr).umo_type := 'MANUFACTURER';
        result_list(ctr).aid := c1rec.aid;
        result_list(ctr).photo_original.source.localdata := empty_blob();
        result_list(ctr).document_original_loc := c2rec.attached_doco;
        result_list(ctr).attribute1 := c2rec.stock_less_than_value;
        result_list(ctr).attribute2 := c2rec.stock_less_purch;
        result_list(ctr).attribute3 := c2rec.current_stock;
        result_list(ctr).attribute4 := c2rec.stock_less_than_desc;
    end if;
  end if;
  ctr := ctr + 1;
 end loop;

 open c4(voidrec.spb);
 fetch c4 into total_records;
 close c4;

 glbx.extended_search_api( surl=>surl, ltype=>ltype, result_list=>result_list, search_total=>total_records,
                           display_detail=>nvl(display_detail,pfx.shop_style), title=>LNG2.FNM_TXT_143,
                           left_api=>NULL, left_api_parm=>left_api_parm, footer_api=>'cst.disp_store',
                           current_page_number=>start_from,no_results_message=>LNG4.AHC_TXT_411,acid=>acid);

exception when others then
 glbx.error_details( 'CST', 'DISP_STORE',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end disp_store;

procedure disp_event( surl in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null )
as

 cursor c2(sess_id integer, acid integer, utype varchar2 ) is
  select *
  from umo um
  where um.aid = acid and
        um.extras.orderby_nmb in (select umo_id from advanced_query_temp_result_a) and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'));

 cursor c3(acid integer) is select min(um.extras.orderby_nmb) from umo um where aid = acid;

 cursor c4(sess_id integer, acid integer, utype varchar2) is
  select /*+ ALL_ROWS */ sum(tot) tot
  from
  (
  select count('x') tot
  from umo um
  where um.aid = acid and
        um.extras.orderby_nmb in (select umo_id from advanced_query_temp_result_a) and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'))
   );

 cursor c5( acid integer, clid integer ) is
  select *
  from virtual_logon
  where aid = acid and
        client_id = clid;

 ctr		integer;
 c1rec		customer_account%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 numb_photos	integer;
 total_records	integer;
 x		integer;
 y		integer;
 ttl		varchar2(100);
 tmp		varchar2(100);
 sts		varchar2(100);
 lbox		varchar2(1000);
 result_list	UMP.SEARCH_RESULT_PHG;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.DISP_EVENT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 -- Left API Parm = NULL or [x-y] or x
 delete from advanced_query_temp_result_a; -- Added to get around Oracle bug
 if left_api_parm is null or c1rec.site_type = 'V' -- V stands for Private (P stands for Public and S is Standard)
  then
   if ltype = 'PHOTOGRAPHER'
    then
     -- Use the First Customer as the Display on Home Page
     open c3(acid);
     fetch c3 into profid;
     close c3;
   end if;
   insert into advanced_query_temp_result_a (umo_id) values (profid);
   -- Look for Public Accounts
   insert into advanced_query_temp_result_a (umo_id) select client_id from virtual_logon where aid = c1rec.aid and public_event = 'T' and client_id <> profid;
   commit;

  elsif substr( left_api_parm,1,1) = '['
   then
    x := substr(left_api_parm,2,instr(left_api_parm,'-')-2);
    tmp := substr(left_api_parm,instr(left_api_parm,'-')+1);
    y := substr(tmp,1,length(tmp)-1);
    for j in x..y loop
     insert into advanced_query_temp_result_a (umo_id) values (j);
    end loop;

  else
   begin x := to_number(left_api_parm); exception when others then x := profid; end;
   insert into advanced_query_temp_result_a (umo_id) values (x);
   -- Look for Public Accounts
   insert into advanced_query_temp_result_a (umo_id) select client_id from virtual_logon where aid = c1rec.aid and public_event = 'T' and client_id <> x;

 end if;

 ctr := 1;
 if acid is null
  then
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'NUMBER_PHOTOS'));
   numb_photos := nvl(numb_photos,10);
  else
   numb_photos := to_number(glbx.photo_pref(c1rec.pid,c1rec.aid,'PHOTO_DISPLAY'));
   numb_photos := nvl(numb_photos,10);
 end if;

 for c2rec in c2(owner_id,c1rec.aid,ltype) loop
  if ctr < start_from
   then
    null;
   else
    if ctr >= (start_from + numb_photos)
     then
      exit;
     else
      result_list( ctr ) := c2rec;
    end if;
  end if;
  ctr := ctr + 1;
 end loop;

 open c4(owner_id,c1rec.aid,ltype);
 fetch c4 into total_records;
 close c4;

 if left_api_parm is null
  then
   open c5(c1rec.aid,profid);
   fetch c5 into c5rec;
   close c5;
   ttl := c5rec.first_name || ' ' || c5rec.surname || ' (' || profid || ')';
   if c5rec.first_name is null and c5rec.surname is null then ttl := '#' || to_char(profid); end if;
  elsif y is null
   then
    ttl := '#' || to_char(x);
  else
    ttl := '#' || to_char(x) || ' - ' || '#' || to_char(y);
 end if;
 ttl := nvl(ttl, '#' || to_char(profid));
 glbx.extended_search_api( surl=>surl, ltype=>ltype, result_list=>result_list, search_total=>total_records,
                           display_detail=>display_detail, title=>ttl,
                           left_api=>NULL, left_api_parm=>left_api_parm, footer_api=>'cst.disp_event',
                           current_page_number=>start_from,no_results_message=>LNG4.AHC_TXT_592,acid=>acid);

exception when others then
 glbx.error_details( 'CST', 'DISP_EVENT',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end disp_event;

procedure srfq( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, msg in varchar2 default null, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null )
as

 cursor c2(acid integer, ltype varchar2  ) is select * from customer_contact where login_type = ltype and aid = acid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.SRFQ' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 if ltype = 'OWNER'
  then
   open c2(c1rec.aid,ltype);
   fetch c2 into c2rec;
   close c2;
 elsif ltype = 'PROFILE'
  then
   open c2(profid,ltype);
   fetch c2 into c2rec;
   close c2;
 end if;

 glbx.main_title( surl, LNG4.AHC_TXT_630,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.formopen( 'cst.accept_srfq' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm  );
 htp.formhidden( 'START_FROM', start_from  );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail  );
 htp.formhidden( 'ACID', acid  );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_022), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1', 40, 100, nvl(p1,c2rec.sendto_name) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_097), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P2', 40, 100, nvl(p2,c2rec.contact_phone) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG.PHG_TXT_301), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P3', 40, 100, nvl(glbx.get_email( surl ),c2rec.contact_email) ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG4.AHC_TXT_653), cattributes=>pfx.qbground || 'valign="TOP" ALIGN="LEFT"');
   htp.tabledata( htf.formtextareaopen( 'P4', 10, 30, cattributes=>'WRAP="VIRTUAL"' ) || p4 || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="TOP" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG2.PFM_TXT_027 );
 htp.formsubmit( 'ACTION', LNG4.AHC_TXT_654 );
 htp.formclose;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'SRFQ',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end srfq;

procedure accept_srfq( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, action in varchar2 )
as

 cursor c2(phgid integer) is select * from photographer where pid = phgid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 nmb		integer;
 rq		varchar2(4000);
 theme_rec 	theme_types%ROWTYPE;
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.ACCEPT_SRFQ' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 if action = LNG2.PFM_TXT_027
  then
     execute immediate
      'begin ' || footer_api ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
      'end;'
      using glbx.rndsurl(surl),left_api_parm,start_from,display_detail,acid;
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 pfx := glbx.get_thm( c1rec.theme_name );
 if p4 is null
  then
   srfq(surl,footer_api,left_api_parm,start_from,display_detail,acid,LNG4.AHC_TXT_655,p1,p2,p3,p4);
   return;
 elsif p2 is null and p3 is null
  then
   srfq(surl,footer_api,left_api_parm,start_from,display_detail,acid,LNG4.AHC_TXT_656,p1,p2,p3,p4);
   return;
 end if;
 rq := glbx.censor( p4, 4000 );

 select s_purchase_order.nextval into nmb from dual;

 insert into simple_rfq(srfq_id,sessid,pid,contact_name,contact_phone,contact_email,request_made,date_made,status) values
  (nmb,owner_id,c1rec.pid,p1,p2,p3,rq,sysdate,LNG.ORD_TXT_120);
 commit;

 glbx.main_title( surl, LNG4.AHC_TXT_657,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 glbx.header_msg( LNG4.AHC_TXT_658 || ':' || nmb );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( LNG.PHG_TXT_022, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.bold(p1), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG.PHG_TXT_097, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.bold(p2), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG.PHG_TXT_301, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.bold( p3 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( LNG4.AHC_TXT_653, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.italic( rq ), cattributes=>pfx.qcbground || 'valign="TOP" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid ,LNG2.PFM_TXT_027 );
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

 open c2(c1rec.pid);
 fetch c2 into c2rec;
 close c2;
 gcode(1) := 'PHOTOGRAPHER';
 gparam(1) := c2rec.business_name;
 gcode(2) := 'SIGNATURE';
 gparam(2) := glbx.extract_master_parameter('MAIL SIGNATURE');
 gcode(3) := 'USERNAME';
 gparam(3) := c1rec.username;
 gcode(4) := 'CUSTOMER';
 gparam(4) := c1rec.account_name;
 gcode(5) := 'DATE_MADE';
 gparam(5) := to_char(sysdate,LNG.TSMASK);
 gcode(6) := 'NAME';
 gparam(6) := p1;
 gcode(7) := 'CONTACT';
 gparam(7) := p2;
 gcode(8) := 'EMAIL';
 gparam(8) := p3;
 gcode(9) := 'REQUEST';
 gparam(9) := rq;
 if c2rec.contact_email is not null
  then
   glbx.send( gcode, gparam, 'simple_request.tmp', p_to=>c2rec.contact_email, p_subj=>'Customer Request', p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'SR1', v_pid=>c1rec.pid, v_aid=>c1rec.aid, v_profile_id=>profid);
 end if;
 commit;

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_SRFQ',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end accept_srfq;

procedure previous_orders( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, msg in varchar2 default null, disp_close_window in char default 'F' )
as

 cursor c2( purchid integer) is select * from purchase_order where poid = purchid;
 cursor c3( rfq integer) is select * from simple_rfq where srfq_id = rfq;

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
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.PREVIOUS_ORDERS' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );

 -- Extract Listing of Orders
 ordlist := glbx.historic_purchase_orders( owner_id );

 glbx.main_title( surl, LNG4.AHC_TXT_631,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C21',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if ordlist.count = 0
  then
   glbx.header_msg( LNG4.AHC_TXT_632 );
   htp.nl;
   htp.p( '<CENTER>' );
   if disp_close_window = 'F'
    then
     if footer_api is not null
      then
       htp.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid ,LNG2.PFM_TXT_027 );
     end if;
    else
     if footer_api is not null then
        htp.anchor('javascript:top.window.close();', '[close]');
     end if;
   end if;
   htp.p( '</CENTER>' );
   glbx.close_page( pfx );

   return;
 end if;
 htp.nl;

 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold( LNG.PHG_TXT_081 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.bold( LNG4.AHC_TXT_634 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.bold( LNG.PHG_TXT_082 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.bold( LNG.PHG_TXT_083 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata(htf.bold( LNG2.FNM_TXT_016 ),cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
 for j in ordlist.first..ordlist.last loop
   htp.tablerowopen;
    begin
    htp.tabledata( htf.anchor( 'fname.order_details?surl=' || glbx.rndsurl(surl) || '&vpoid=' || substr(ordlist(j),2) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&disp_close_window=' || disp_close_window, substr(ordlist(j),2) ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    if substr(ordlist(j),1,1) = 'A'
     then
      open c2( substr(ordlist(j),2) );
      fetch c2 into c2rec;
      close c2;
      htp.tabledata( LNG.ORD_TXT_120,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( '&nbsp;',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( to_char(nvl(c2rec.date_purchased,c2rec.date_created),LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( '[' || htf.anchor( 'cst.mng_previous_orders?surl=' || glbx.rndsurl(surl) || '&otype=D&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&ordid=' || ordlist(j) || '&disp_close_window=' || disp_close_window, LNG.SLD_TXT_004 ) || '] [' ||
                    htf.anchor( 'cst.mng_previous_orders?surl=' || glbx.rndsurl(surl) || '&otype=C&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&ordid=' || ordlist(j) || '&disp_close_window=' || disp_close_window, LNG4.AHC_TXT_637) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    elsif substr(ordlist(j),1,1) = 'P'
     then
      open c2( substr(ordlist(j),2) );
      fetch c2 into c2rec;
      close c2;
      htp.tabledata( LNG.ORD_TXT_121,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( to_char(nvl(c2rec.date_purchased,c2rec.date_created),LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( htf.anchor( 'fname.order_details?surl=' || glbx.rndsurl(surl) || '&vpoid=' || substr(ordlist(j),2) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&disp_close_window=' || disp_close_window, LNG2.PFM_TXT_149 ),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    elsif substr(ordlist(j),1,1) = 'C'
     then
      open c2( substr(ordlist(j),2) );
      fetch c2 into c2rec;
      close c2;
      htp.tabledata( LNG.ORD_TXT_207,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( to_char(nvl(c2rec.date_purchased,c2rec.date_created),LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( htf.anchor( 'fname.order_details?surl=' || glbx.rndsurl(surl) || '&vpoid=' || substr(ordlist(j),2) || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid, LNG2.PFM_TXT_149 ) || '&disp_close_window=' || disp_close_window,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    elsif substr(ordlist(j),1,1) = 'W'
     then
      htp.tabledata( LNG4.AHC_TXT_635,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      open c2( substr(ordlist(j),2) );
      fetch c2 into c2rec;
      close c2;
      htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( to_char(nvl(c2rec.date_purchased,c2rec.date_created),LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( '[' || htf.anchor( 'cst.mng_previous_orders?ssurl=' || glbx.rndsurl(surl) || '&otype=D&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&ordid=' || ordlist(j) || '&disp_close_window=' || disp_close_window, LNG.SLD_TXT_004 ) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    elsif substr(ordlist(j),1,1) = 'R'
     then
      htp.tabledata( LNG4.AHC_TXT_636,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      open c3( substr(ordlist(j),2) );
      fetch c3 into c3rec;
      close c3;
      htp.tabledata( c2rec.status,cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( to_char(nvl(c3rec.date_completed,c3rec.date_made),LNG.TSMASK),cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
      htp.tabledata( '[' || htf.anchor( 'cst.mng_previous_orders?surl=' || glbx.rndsurl(surl) || '&otype=D&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&ordid=' || ordlist(j) || '&disp_close_window=' || disp_close_window, LNG.SLD_TXT_004 ) || ']',cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    end if;
    exception
     when others then null;
    end;
   htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 if disp_close_window = 'F'
  then
   if footer_api is not null
    then
     htp.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid ,LNG2.PFM_TXT_027 );
   end if;
  else
   if footer_api is not null then
      htp.anchor('javascript:top.window.close();', '[close]');
   end if;
 end if;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'PREVIOUS_ORDERS',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end previous_orders;

procedure mng_previous_orders( surl in varchar2, otype in char, ordid in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null, disp_close_window in char default 'F' )
as

 cursor c2( sess_id integer ) is select poid from purchase_order where sessid = sess_id;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 msg		varchar2(200);
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.MNG_PREVIOUS_ORDERS' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 -- Delete
 if otype = 'D'
  then
   if substr( ordid, 1, 1 ) = 'A'
    then
     delete from shopping_basket where poid = to_number(substr(ordid,2));
     delete from purchase_order where poid = to_number(substr(ordid,2));
   elsif substr( ordid, 1, 1 ) = 'W'
    then
     delete from shopping_basket where poid = to_number(substr(ordid,2));
     delete from purchase_order where poid = to_number(substr(ordid,2));
   elsif substr( ordid, 1, 1 ) = 'R'
    then
     delete from simple_rfq_item where srfq_id = to_number(substr(ordid,2));
     delete from simple_rfq_mfctr where srfq_id = to_number(substr(ordid,2));
     delete from simple_rfq where srfq_id = to_number(substr(ordid,2));
   end if;
   msg := LNG4.AHC_TXT_679;
 elsif otype = 'C'
  then
   if substr( ordid, 1, 1 ) = 'A'
    then
     open c2( owner_id );
     fetch c2 into c2rec;
     if c2%NOTFOUND
      then
        close c2;
        update purchase_order set sessid = owner_id where poid = to_number(substr(ordid,2));
      else
        close c2;
        update shopping_basket
         set
          poid = c2rec.poid
        where
         poid = to_number(substr(ordid,2));
        delete from purchase_order where poid = to_number(substr(ordid,2));
     end if;
     msg := LNG4.AHC_TXT_678;
   end if;
 end if;

 commit;
 previous_orders( surl, footer_api, left_api_parm, start_from, display_detail, acid, msg, disp_close_window=>disp_close_window );

exception when others then
 glbx.error_details( 'CST', 'MNG_PREVIOUS_ORDERS',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end mng_previous_orders;

/*
procedure order_details( surl in varchar2, ordid in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer default 1, display_detail in char default null, acid in integer default null )
as

 cursor c2( sess_id integer ) is select poid from purchase_order where sessid = sess_id;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 msg		varchar2(200);
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.ORDER_DETAILS' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNG4.AHC_TXT_653,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C23',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active);

 if substr( ordid, 1, 1 ) in ('A','W','P')
  then
    ord.module_acct_orders( surl, substr(ordid,2), c1rec.pid, 'MAIN', ltype, pfx=>pfx, acid=>acid );
  elsif substr( ordid, 1, 1 ) = 'R'
  then
   request_details( surl, substr(ordid,2), pfx, acid );
 end if;

 htp.nl;
 htp.anchor( 'cst.previous_orders' || '?surl=' || glbx.rndsurl(surl) || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid ,LNG2.PFM_TXT_027 );
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'ORDER_DETAILS',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'left_api_parm:' || left_api_parm );
end order_details;
*/

procedure request_details( surl in varchar2, rqid in integer, pfx in THEME%ROWTYPE, acid in integer )
as

 cursor c1( rqid integer ) is select * from simple_rfq where srfq_id = rqid;
 cursor c2( rqid integer ) is select * from simple_rfq_item where srfq_id = rqid order by ranking desc;

 c1rec	c1%ROWTYPE;

begin

 open c1(rqid);
 fetch c1 into c1rec;
 close c1;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG4.AHC_TXT_636 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.bold( rqid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.CST_TXT_005 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c1rec.contact_name, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.ORD_TXT_180 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c1rec.contact_phone, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_301 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c1rec.contact_email, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_301 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c1rec.request_made, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.PHG_TXT_082 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( c1rec.status, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.nl;
  htp.bold( LNG4.AHC_TXT_661 );
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_663 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG3.ADM_TXT_105 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_664 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_665 ), cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   for c2rec in c2( rqid ) loop
    htp.tablerowopen;
     htp.tabledata( c2rec.ranking, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c2rec.free_text_description, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     if c2rec.email_sent = 'T'
      then
       htp.tabledata( c2rec.email_or_phone || htf.nl || htf.italic( LNG4.AHC_TXT_668 || '-' || to_char( c2rec.email_sent_date, LNG.MASK )), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      else
       htp.tabledata( c2rec.email_or_phone, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     end if;
     htp.tabledata( c2rec.general_comments, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
   end loop;
  htp.p( '</CENTER>' );
  glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'REQUEST_DETAILS',null,acid,errmsg=>sqlerrm,extdet=>'RQID:' || rqid);
end request_details;

function usg( vpoid integer )
 return varchar2
as
 cursor c1( vpoid integer ) is select distinct user_fee_code from shopping_basket where poid = vpoid;
 txt varchar2(4000);
begin
 for c1rec in c1(vpoid) loop
  txt := ',' || c1rec.user_fee_code;
 end loop;
 return( nvl(substr(txt,2),'&nbsp;') );
end usg;

procedure auth_payment( surl in varchar2, acid in integer default null, msg in varchar2 default null, footer_api in varchar2 default null, left_api_parm in varchar2 default null, newwin in char default 'F')
as

  cursor c1( phgid integer ) is select project_code from project_codes where pid = phgid order by project_code;
  cursor c2( profid integer ) is
   select poid, cp2.username, po.project_code, po.pid, po.order_comment
   from customer_profile cp, purchase_order po, login_session ls, customer_profile cp2
   where sysdate >= nvl(cp.authority_valid_from,sysdate-1) and
         sysdate <= nvl(cp.authority_valid_to,sysdate+1) and
         (cp.authority_own_request in ('T','A') or not(cp.authority_own_request = 'F' and cp.profile_id = profid)) and
         po.sessid = ls.sessid and
         po.paid_method = 'AUTHORISATION' and
         po.status = 'Awaiting Authorisation' and
         ls.aid = cp2.profile_id and
         cp.profile_id = profid and
         (((cp.request_authority = 'A') and (cp.pid = cp2.pid)) or
          ((cp.request_authority = 'B') and (cp.aid = cp2.aid)) or
          ((cp.request_authority = 'D') and (cp.profile_id = cp2.profile_id)) or
          ((cp.request_authority = 'C') and (cp.profile_id,cp2.profile_id) in (select mgmt_profile_id,profile_id from profile_purchase_authority))
         )
   order by poid;

  cursor c3( profid integer ) is select * from customer_profile where profile_id = profid;
  cursor c4( vpoid integer ) is select * from order_style where oid = (select oid from purchase_order where poid = vpoid);

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 txt		varchar2(4000);
 foundrec	boolean;
 ttl		number;
 sm		number;
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.AUTH_PAYMENT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 if newwin = 'F'
  then
   glbx.main_title( surl, LNG4.AHC_TXT_692, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C24',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  else
   glbx.main_title( surl, null, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C24',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;
 open c3(profid);
 fetch c3 into c3rec;
 if c3%NOTFOUND
  then
   close c3;
   glbx.header_msg( LNG4.AHC_TXT_707 );
   glbx.close_page( pfx );

   return;
 end if;
 close c3;
 if c3rec.request_authority = 'F'
  then
   glbx.header_msg( LNG4.AHC_TXT_707 );
   glbx.close_page( pfx );

   return;
 end if;
 if sysdate <= nvl(c3rec.authority_valid_from,sysdate-1) or
    sysdate >= nvl(c3rec.authority_valid_to,sysdate+1)
  then
   glbx.header_msg( LNG4.AHC_TXT_707 );
   glbx.close_page( pfx );

   return;
 end if;

 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 glbx.instruction( LNG4.AHC_TXT_712, pfx );
 sm := nvl(glbx.authority_outstanding(profid),0);
 if c3rec.authority_limit is null
  then
   htp.bold( LNG.ORD_TXT_132 || ' ' || to_char(sm,LNG.MONEY_FORMAT));
  else
   htp.bold( LNG.PHG_TXT_282 || ' ' || to_char(c3rec.authority_limit- sm,LNG.MONEY_FORMAT) || '(' || to_char(c3rec.authority_limit,LNG.MONEY_FORMAT) || ' )' );
 end if;
 htp.nl;
 c3rec.authority_limit := c3rec.authority_limit - sm;
 htp.formopen( 'fname.accept_auth_payment' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );
 htp.formhidden( 'P3', null );
 htp.formhidden( 'P4', null );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG4.AHC_TXT_692), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG4.AHC_TXT_983), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG.CST_TXT_099), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG.PHG_TXT_095), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG.GLB_TXT_076), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( 'Usage'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( 'Terms and Conditions of Usage'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 foundrec := FALSE;
 for c2rec in c2(profid) loop
  ttl := glbx.grand_total_payment(c2rec.poid, include_gift_certificate=>TRUE);
  if (ttl <= nvl(c3rec.authority_limit,ttl+1) and c3rec.attribute_id is null) or
     (c3rec.attribute_id is not null)
   then
    foundrec := TRUE;
    -- Display Purchase Order Details
    htp.tablerowopen;
     htp.tabledata( htf.formcheckbox( 'P1', c2rec.poid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     open c4( c2rec.poid );
     fetch c4 into c4rec;
     close c4;
     if nvl(c4rec.payment_auth_project_code,'F') = 'F'
      then
       htp.formhidden( 'P3', c2rec.poid );
       htp.formhidden( 'P2', NULL );
       htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
      else
       htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="LEFT">' );
       htp.formhidden( 'P3', c2rec.poid );
       htp.formselectopen( 'P2' );
       for c1rec in c1( c2rec.pid ) loop
        if c1rec.project_code = nvl(c2rec.project_code,c3rec.project_code)  -- Default to Profile Owner's Project Code
         then
          htp.formselectoption( c1rec.project_code, 'SELECTED' );
         else
          htp.formselectoption( c1rec.project_code );
        end if;
       end loop;
       htp.formselectclose;
       htp.p( '</TD>' );
      end if;
     htp.tabledata( htf.anchor( 'fname.order_details?surl=' || surl || '&called_from=AUTH&vpoid=' || c2rec.poid || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=1' || '&display_detail=' || '&acid=' || acid, c2rec.poid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( to_char(ttl,LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c2rec.username, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     txt := usg( c2rec.poid );
     htp.tabledata( txt, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P4', 30, 4000, c2rec.order_comment), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec
  then
   htp.formclose;
   glbx.header_msg( LNG4.AHC_TXT_708 );
   htp.anchor( 'cst.auth_payment_report?surl=' || surl || '&acid=' || acid || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&newwin=' || newwin, LNG4.AHC_TXT_711 );
   htp.p( '</CENTER>' );
   glbx.close_page( pfx );
   return;
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 borer=0' );
 htp.tablerowopen;
 htp.tabledata( htf.formsubmit( null, LNG4.AHC_TXT_709) || htf.formclose );
 if left_api_parm is not null
  then
   htp.p( '<TD>' );
   htp.anchor( footer_api || '?surl=' || surl || '&acid=' || acid || '&left_api_parm=' || replace(left_api_parm,' ','+'), LNG.CST_TXT_063 );
   htp.p( '</TD>' );
 end if;
 htp.tablerowclose;
 htp.nl;
 htp.nl;
 htp.anchor( 'cst.auth_payment_report?surl=' || surl || '&acid=' || acid || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&newwin=' || newwin, LNG4.AHC_TXT_711 );
 htp.p( '</CENTER>' );
 if newwin = 'T'
  then
   htp.nl;
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
 end if;
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'AUTH_PAYMENT',null,acid,errmsg=>sqlerrm);
end auth_payment;

procedure auth_payment_report( surl in varchar2, acid in integer default null, footer_api in varchar2 default null, left_api_parm in varchar2 default null, newwin in char default 'F' )
as

 cursor c2( profid integer ) is select poid,status,sessid,project_code,order_comment from purchase_order po where authorised_by = profid order by date_purchased desc;
 cursor c3( sess_id integer ) is select username from login_session ls,customer_profile cp where  ls.sessid = sess_id and ls.aid = cp.profile_id;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 foundrec	boolean;
 ttl		number;
 txt		varchar2(4000);
 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.AUTH_PAYMENT_REPORT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 pfx := glbx.get_thm( c1rec.theme_name );
 if newwin = 'F'
  then
   glbx.main_title( surl, LNG4.AHC_TXT_713, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C24',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
  else
   glbx.main_title( surl, null, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C24',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNG.CST_TXT_099), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG4.AHC_TXT_983), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG.PHG_TXT_095), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG.PHG_TXT_082), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( LNG.GLB_TXT_076), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( 'Usage'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
  htp.tabledata( htf.bold( 'Terms and Conditions of Usage'), cattributes=>pfx.qbground || 'valign="MIDDLE" align="CENTER"' );
 htp.tablerowclose;
 for c2rec in c2(profid) loop
  ttl := glbx.grand_total_payment(c2rec.poid, include_gift_certificate=>TRUE);
  htp.tablerowopen;
     htp.tabledata( htf.anchor2( 'fname.order_details?surl=' || surl || '&called_from=AUTHP&vpoid=' || c2rec.poid || '&footer_api=' || footer_api || '&left_api_parm=' || translate(left_api_parm,' ','+') || '&start_from=1' || '&display_detail=' || '&acid=' || acid, c2rec.poid, ctarget=>'PURCHASE_DETAILS' ), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"' );
     htp.tabledata( nvl(c2rec.project_code,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( to_char(ttl,LNG.MONEY_FORMAT), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( c2rec.status, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     open c3(c2rec.sessid);
     fetch c3 into c3rec;
     if c3%FOUND
      then
       close c3;
       htp.tabledata( c3rec.username, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
      else
       close c3;
       htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     end if;
     txt := usg( c2rec.poid );
     htp.tabledata( txt, cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata(nvl(c2rec.order_comment,'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.anchor( 'cst.auth_payment?surl=' || surl || '&acid=' || acid || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&newwin=' || newwin, LNG4.AHC_TXT_564 );
 if newwin = 'T'
  then
   htp.nl;
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
 end if;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'AUTH_PAYMENT_REPORT',null,acid,errmsg=>sqlerrm);
end auth_payment_report;

procedure lov_select( select_stmt in varchar2, currvalue in varchar2 )
 as

   cursor_name		integer;
   dummy 		integer;
   col_count		integer;
   desc_t		dbms_sql.desc_tab;
   common_nmb		number;
   common_vc2		varchar2(4000);
   common_dte		date;
   tmpval		varchar2(4000);
   tmpval2		varchar2(4000);

 begin

   cursor_name := dbms_sql.open_cursor;
   dbms_sql.parse( cursor_name, select_stmt, dbms_sql.native );
   dbms_sql.describe_columns(cursor_name,col_count,desc_t);

   for j in 1..least(2,col_count) loop
    if desc_t(j).col_type in (1,96)
     then
      dbms_sql.define_column_char(cursor_name,j,common_vc2,desc_t(j).col_max_len);
    elsif desc_t(j).col_type = 2
     then
      dbms_sql.define_column(cursor_name,j,common_nmb);
    elsif desc_t(j).col_type = 12
     then
      dbms_sql.define_column(cursor_name,j,common_dte);
    end if;
   end loop;
   dummy := dbms_sql.execute( cursor_name );

   loop
     dummy := dbms_sql.fetch_rows(cursor_name);
     if dummy = 0 then exit; end if;
     tmpval := NULL;
     tmpval2 := NULL;
     for j in 1..least(2,col_count) loop
      common_vc2 := NULL;
      common_nmb := NULL;
      common_dte := NULL;
      if desc_t(j).col_type in (1,96)
       then
        dbms_sql.column_value_char(cursor_name,j,common_vc2);
        if j = 1 then tmpval := rtrim( common_vc2 ); else tmpval2 := rtrim( common_vc2 ); end if;
       elsif desc_t(j).col_type = 2
        then
         dbms_sql.column_value(cursor_name,j,common_nmb);
         if j = 1 then tmpval := to_char( common_nmb ); else tmpval2 := to_char( common_nmb ); end if;
       elsif desc_t(j).col_type = 12
        then
         dbms_sql.column_value(cursor_name,j,common_dte);
         if j = 1 then tmpval := to_char( common_dte,LNG.TSMASK ); else tmpval2 := to_char( common_dte,LNG.TSMASK ); end if;
      end if;
     end loop;
     if trim(tmpval) = trim(currvalue)
      then
       htp.formselectoption( tmpval2, 'SELECTED', cattributes=>'VALUE="' || tmpval || '"' );
      else
       htp.formselectoption( tmpval2, cattributes=>'VALUE="' || tmpval || '"' );
     end if;
   end loop;

   dbms_sql.close_cursor( cursor_name );

 exception when others then
  glbx.error_details( 'CST', 'LOV_SELECT',null,null,errmsg=>sqlerrm);
end lov_select;

procedure cust_contact( surl in varchar2, acid in integer, profid in integer, action in varchar2 default 'UPDATE', cust_type in char default null, msg in varchar2 default null, err_inst in integer default null, err_cust in customer_contact%ROWTYPE default null, extra_inf in varchar2 default null,
                        footer_api in varchar2 default null, left_api_parm in varchar2 default null, start_from in integer default null, display_detail in char default null )
as

 cursor c1( acid integer, ltype varchar2 ) is select * from customer_contact where login_type = ltype and aid = acid;
 cursor c2 is select distinct region from postal_charge order by region;
 cursor c3( cid integer, intid integer ) is select 'x' tot from customer_interest where contact_id = cid and interest_id = intid;
 cursor c4 is select interest_id,interest_name from interest_groups order by interest_name;
 cursor c5(acid integer) is select * from generic_registration where aid = acid;
 cursor c6(acid integer) is select * from customer_account where aid = acid;
 cursor c7(acid integer, phgid integer, ut char ) is
   select gcn.internal_column,gcn.column_name,gcn.lov,gcn.grouping,gcn.column_type
   from generic_registration_columns grc, generic_columns_names gcn
   where grc.column_name = gcn.column_name and
         grc.pid = phgid and
         grc.aid = acid and
         gcn.user_type = ut and
         gcn.column_type <> 'H' and
         gcn.user_type = grc.user_type
   order by gcn.order_by;
 cursor c8( ut char ) is
   select gcn.internal_column,gcn.column_name,gcn.lov,gcn.grouping,gcn.column_type
   from generic_columns_names gcn
   where gcn.user_type = ut
   order by gcn.grouping,gcn.order_by;


 cusrec		customer_account%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 cuscont	c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 owner_id	integer;
 ltype		varchar2(100);
 stype		integer;
 nprofid	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 home_ctry	varchar2(100);
 utype		char(1);
 tag_name	GLBX.MYARRAY;
 tag_title	GLBX.MYARRAY;
 propusers	GLBX.MYARRAY;
 align		varchar2(20);
 brd		varchar2(100);
 last_grp	varchar2(100);
 clra		varchar2(100);
 clrb		varchar2(100);
 ut		char(1);
 b2c_value	char(1);

 function extract( cuscont in c1%ROWTYPE, intcol in varchar2 )
  return varchar2
 as
 begin
  if intcol = 'SENDTO_NAME' then return( cuscont.sendto_name );
  elsif intcol = 'SENDTO_STREET' then return( cuscont.sendto_street );
  elsif intcol = 'SENDTO_SUBURB' then return( cuscont.sendto_suburb );
  elsif intcol = 'SENDTO_CITY' then return( cuscont.sendto_city );
  elsif intcol = 'SENDTO_POSTCODE' then return( cuscont.sendto_postcode );
  elsif intcol = 'SENDTO_COUNTRY' then return( cuscont.sendto_country );
  elsif intcol = 'SENDTO_STATE' then return( cuscont.sendto_state );
  elsif intcol = 'SENDTO_DEPARTMENT' then return( cuscont.sendto_department );
  elsif intcol = 'SENDTO_BRANCH' then return( cuscont.sendto_branch );
  elsif intcol = 'CONTACT_PHONE' then return( cuscont.contact_phone );
  elsif intcol = 'CONTACT_MOBILE' then return( cuscont.contact_mobile );
  elsif intcol = 'CONTACT_EMAIL' then return( cuscont.contact_email );
  elsif intcol = 'BILLING_NAME' then return( cuscont.billing_name );
  elsif intcol = 'BILLING_STREET' then return( cuscont.billing_street );
  elsif intcol = 'BILLING_SUBURB' then return( cuscont.billing_suburb );
  elsif intcol = 'BILLING_CITY' then return( cuscont.billing_city );
  elsif intcol = 'BILLING_POSTCODE' then return( cuscont.billing_postcode );
  elsif intcol = 'BILLING_COUNTRY' then return( cuscont.billing_country );
  elsif intcol = 'BILLING_EMAIL' then return( cuscont.billing_email );
  elsif intcol = 'BILLING_PHONE' then return( cuscont.billing_phone );
  elsif intcol = 'BILLING_STATE' then return( cuscont.billing_state );
  elsif intcol = 'BILLING_DEPARTMENT' then return( cuscont.billing_department );
  elsif intcol = 'BILLING_BRANCH' then return( cuscont.billing_branch );
  elsif intcol = 'BILLING_GPO_BOX' then return( cuscont.billing_gpo_box );
  elsif intcol = 'ACCEPT_PAY_BY_ACCT' then return( cuscont.accept_pay_by_acct );
  elsif intcol = 'ACCOUNT_BILLING_ID' then return( cuscont.account_billing_id );
  elsif intcol = 'ACCOUNT_PASSWORD' then return( cuscont.account_password );
  elsif intcol = 'BILLING_FAX' then return( cuscont.billing_fax );
  elsif intcol = 'ACCOUNT_LIMIT' then return( cuscont.account_limit );
  elsif intcol = 'RECEIVE_EMAILS' then return( cuscont.receive_emails );
  elsif intcol = 'USER_TYPE' then return( cuscont.user_type );
  elsif intcol = 'TAX_CODE' then return( cuscont.tax_code );
  elsif intcol = 'TAX_GROUP' then return( cuscont.tax_group );
  elsif intcol = 'EXTRA' then return( cuscont.extra );
  else return( NULL );
  end if;
 end extract;

begin
 if surl is null and action in ('NEW','DISCLAIMER','INSERT')
  then
   open c5(acid);
   fetch c5 into c5rec;
   close c5;
   if substr(c5rec.on_presubmit,1,1) = 'T' and
      substr(c5rec.on_presubmit,3,1) = 'T'
    then
     ltype := 'PUBLIC';
     sts := NULL;
     owner_id := acid;
     stype := 1;
    else
     return; -- Registration Form Disabled
   end if;
 elsif surl is null
  then
   return; -- Bad Access
 else
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.CUST_CONTACT' );
  if sts is not null
   then
    glbx.redisplay_login_page( sts );
    return;
  end if;
 end if;

 if ltype = 'PUBLIC'
  then
   nprofid := null;
   open c6(owner_id);
   fetch c6 into cusrec;
   close c6;
  else
   cusrec := glbx.get_cusrec( owner_id, ltype, acid, nprofid );
   open c5(cusrec.aid);
   fetch c5 into c5rec;
   -- If Action is UPDATE, check if Registration Details Exist. If none then reject. Action must be insert
   if c5%NOTFOUND and action = 'UPDATE' and ltype in ( 'PROFILE', 'OWNER' )
    then
     close c5;
     htp.bold( 'Registration Form does not exist. Unable to update details' );
     return; -- Registration Form has been Disabled
   end if;
   close c5;
 end if;

 -- Check if Form is Enabled
 if ltype in ('PUBLIC','PROFILEG','CUSTOMER','OWNER','PROFILE') and
    nvl(substr(c5rec.on_presubmit,1,1),'F') = 'F'
  then
   htp.bold( 'Registration Form has been Disabled' );
   return; -- Registration Form has been Disabled
 end if;

 pfx := glbx.get_thm( cusrec.aid );
 theme_rec := glbx.get_theme_types(cusrec.aid );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));

 if nvl(substr(c5rec.on_form,2,1),'F') = 'T'
  then
   align := 'align="RIGHT"';
  else
   align := 'align="LEFT"';
 end if;
 if nvl(substr(c5rec.on_form,3,1),'F') = 'T'
  then
   brd := 'border=1';
  else
   brd := 'border=0';
 end if;
 if nvl(substr(c5rec.on_form,8,1),'F') = 'T'
  then
   brd := brd || ' rules="NONE" frame="HSIDES,VSIDES"';
 end if;
 if nvl(substr(c5rec.on_form,5,1),'F') = 'T'
  then
   clra := pfx.qbground;
   clrb := pfx.qcbground;
  else
   clra := null;
   clrb := null;
 end if;

 -- Check to see if Prompt for Type of User Should be displayed
 if ltype in ('PUBLIC','PROFILEG','CUSTOMER') and
    action = 'NEW' and
    nvl(substr(c5rec.on_presubmit,4,1),'F') = 'T'
  then
   glbx.main_title( surl, LNG2.PFM_TXT_115,glbx.backimg(surl,cusrec.aid,pfx.text_back,null,ltype),helpid=>'C25',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   -- Display Types of Users
   if nvl(substr(c5rec.on_form,1,1),'F') = 'T' -- Prompt for Username
    then
     glbx.login_page( style=>'EMBEDDED', pfx=>pfx, on_form=>c5rec.on_form );
   end if;
   htp.nl;
   htp.nl;
   glbx.instruction( LNG4.AHC_TXT_782, pfx );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.formopen( 'cst.cust_contact' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'PROFID', null );
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
   htp.formhidden( 'FOOTER_API', footer_api );
   htp.formhidden( 'START_FROM', start_from );
   htp.formhidden( 'DISPLAY_DETAIL', display_detail );
   htp.formhidden( 'ACTION', 'DISCLAIMER' );
   htp.tablerowopen;
    if nvl(substr(c5rec.on_presubmit,5,1),'F') = 'T'
     then
      htp.tabledata( htf.formradio( 'CUST_TYPE','I','CHECKED' ), cattributes=>clra || 'valign="MIDDLE" align="CENTER"' );
     else
      htp.tabledata( htf.formradio( 'CUST_TYPE','I' ), cattributes=>clra || 'valign="MIDDLE" align="CENTER"' );
    end if;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_730 ), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    if nvl(substr(c5rec.on_presubmit,5,1),'F') = 'T'
     then
      htp.tabledata( htf.formradio( 'CUST_TYPE','S' ), cattributes=>clra || 'valign="MIDDLE" align="CENTER"' );
     else
      htp.tabledata( htf.formradio( 'CUST_TYPE','S','CHECKED' ), cattributes=>clra || 'valign="MIDDLE" align="CENTER"' );
    end if;
    htp.tabledata( htf.bold( LNG4.AHC_TXT_731 ), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formradio( 'CUST_TYPE','C' ), cattributes=>clra || 'valign="MIDDLE" align="CENTER"' );
    htp.tabledata( htf.bold( LNG4.AHC_TXT_732 ), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( null, LNG4.AHC_TXT_781 );
   htp.formclose;
   htp.p( '</CENTER>' );
   glbx.close_page( pfx );

   return;
 end if;

 -- Determine Customer Type
 if ltype in ('PUBLIC','PROFILEG','CUSTOMER') and
    action in ('NEW','DISCLAIMER','INSERT')
  then
   if cust_type is null and nvl(substr(c5rec.on_presubmit,5,1),'F') = 'T'
    then
     utype := 'I';
    elsif cust_type is null
    then
     utype := 'S';
    else
     utype := cust_type;
   end if;
 end if;

 if ltype = 'PHOTOGRAPHER' then nprofid := profid; end if;

 -- Extract Contact Details if they exist
 if action = 'UPDATE'
  then
   if nprofid is null
    then
     open c1(cusrec.aid,'OWNER');
    else
     open c1(nprofid,'PROFILE');
   end if;

   fetch c1 into cuscont;
   if c1%NOTFOUND
    then
     home_ctry := nvl(voidrec.residing_country,'AUSTRALIA');
     select s_customer_contact.nextval into cuscont.contact_id from dual;
     cuscont.sendto_country := upper(home_ctry);
     cuscont.billing_country := upper(home_ctry);
     if nprofid is null
      then
       cuscont.aid := cusrec.aid;
       cuscont.login_type := 'OWNER';
      else
       cuscont.aid := nprofid;
       cuscont.login_type := 'PROFILE';
     end if;
   end if;
   close c1;
   utype := nvl(cuscont.user_type,'I');

  else
   -- Default Values on Registration
   home_ctry := nvl(voidrec.residing_country,'AUSTRALIA');
   select s_customer_contact.nextval into cuscont.contact_id from dual;
   cuscont.sendto_country := upper(home_ctry);
   cuscont.billing_country := upper(home_ctry);
   cuscont.user_type := utype;
   -- Refresh if Error has been returned
   if err_cust.contact_id is not null then cuscont := err_cust; end if;
   if nprofid is null
    then
     cuscont.aid := cusrec.aid;
     cuscont.login_type := 'OWNER';
    else
     cuscont.aid := nprofid;
     cuscont.login_type := 'PROFILE';
   end if;
 end if;

 if ltype = 'PHOTOGRAPHER'
  then
  glbx.main_title( surl, LNG2.PFM_TXT_115,glbx.backimg(surl,cusrec.aid,pfx.text_back,null,ltype),helpid=>'P42',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 elsif ltype in ('OWNER','PROFILE')
  then
  glbx.main_title( surl, LNG4.AHC_TXT_801,glbx.backimg(surl,cusrec.aid,pfx.text_back,null,ltype),helpid=>'C25',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 else
  glbx.main_title( surl, LNG4.AHC_TXT_802,glbx.backimg(surl,cusrec.aid,pfx.text_back,null,ltype),helpid=>'C26',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 end if;

 htp.nl;
 htp.p( '<CENTER>' );

 -- Check to see if Public Username Prompt is to be Displayed
 if ltype <> 'PHOTOGRAPHER' and nvl(substr(c5rec.on_form,1,1),'F') = 'T' -- Prompt for Username
   then
     glbx.login_page( style=>'EMBEDDED', pfx=>pfx, on_form=>c5rec.on_form );
 end if;

 htp.p( '<CENTER>' );
 if nprofid is not null then htp.bold( cusrec.account_name ); htp.nl; end if;
 if err_inst > 0
  then
   glbx.header_msg( msg );
   -- If Username Already Exists display alternatives
   if err_inst = 1 and nvl(substr(c5rec.on_submit,1,1),'F') = 'T'
    then
     propusers := glbx.proposed_users( extra_inf, 10 );
     for j in propusers.first..propusers.last loop
      htp.bold( propusers(j) ); htp.nl;
     end loop;
   end if;
 end if;
 htp.formopen( 'cst.accept_cust_contact' );
 htp.formhidden( 'SURL', surl);
 htp.formhidden( 'CONTID', cuscont.contact_id );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'PROFID', nprofid );
 htp.formhidden( 'LTYPE', cuscont.login_type );
 htp.formhidden( 'ACTION', action );
 htp.formhidden( 'P3', NULL );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'START_FROM', start_from );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 last_grp := NULL;
 -- Photographer Sees All
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 ' || brd );
 if ltype = 'PHOTOGRAPHER'
  then
   htp.formhidden( 'P5', null );
   for c8rec in c8(nvl(cuscont.user_type,utype)) loop
    htp.tablerowopen;
     if nvl(substr(c5rec.on_form,6,1),'F') = 'T'
      then
       if last_grp is null or last_grp <> c8rec.grouping
        then
         if nvl(substr(c5rec.on_form,7,1),'F') = 'T'
          then
           htp.tablerowclose;
           htp.tableclose;
           htp.nl;
           htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 ' || brd );
           htp.tablerowopen;
         end if;
         htp.tabledata( htf.bold(c8rec.grouping),cattributes=>clra || 'valign="MIDDLE" align="LEFT"' );
        else
         htp.tabledata( '&nbsp;',cattributes=>clra || 'valign="MIDDLE" ' || align );
       end if;
     end if;
     htp.tabledata( htf.bold(c8rec.column_name),cattributes=>clra || 'valign="MIDDLE" ' || align );
     if c8rec.column_type in ('V','H')
      then
       htp.tabledata( htf.formtext( 'P1', 30, 100, extract(cuscont,c8rec.internal_column)), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
     elsif c8rec.column_type = 'P'
      then
       htp.tabledata( htf.formpassword( 'P1', 30, 100, extract(cuscont,c8rec.internal_column)), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
     elsif c8rec.column_type = 'L'
      then
       htp.p( '<TD ' || clrb || 'valign="MIDDLE" align="LEFT">' );
       htp.formselectopen( 'P1' );
       lov_select( c8rec.lov,extract(cuscont,c8rec.internal_column));
       htp.formselectclose;
       htp.p( '</TD>' );
     elsif c8rec.column_type = 'B'
      then
       if nvl(extract(cuscont,c8rec.internal_column),'F') = 'T'
        then
         htp.tabledata( htf.formcheckbox( 'P3', c8rec.internal_column,'CHECKED'), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
        else
         htp.tabledata( htf.formcheckbox( 'P3', c8rec.internal_column), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
       end if;
     end if;
     if c8rec.column_type <> 'B' then htp.formhidden( 'P2', c8rec.internal_column ); end if;
    htp.tablerowclose;
    last_grp := c8rec.grouping;
   end loop;
   if c5rec.extra_prompt is not null
    then
      htp.tablerowopen;
       if nvl(substr(c5rec.on_form,6,1),'F') = 'T' then htp.tabledata( '&nbsp;',cattributes=>clra || 'valign="MIDDLE" ' || align ); end if;
       htp.tabledata( htf.bold(c5rec.extra_prompt),cattributes=>clra || 'valign="MIDDLE" ' || align );
       htp.tabledata( htf.formtext( 'P1', 30, 100, extract(cuscont,'EXTRA')), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
       htp.formhidden( 'P2', 'EXTRA' );
      htp.tablerowclose;
   end if;

  else

   htp.formhidden( 'P5', null );
   -- Display Username and Password Prompt, but only on insert
   if action in ('NEW','INSERT','DISCLAIMER')
    then
     htp.tablerowopen;
      if nvl(substr(c5rec.on_form,6,1),'F') = 'T'
       then
        htp.tabledata( '&nbsp;',cattributes=>clra || 'valign="MIDDLE" ' || align );
      end if;
      htp.tabledata( htf.bold(LNG.GLB_TXT_076),cattributes=>clra || 'valign="MIDDLE" ' || align );
      htp.tabledata( htf.formtext( 'P5', 30, 100, null), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
     htp.tablerowopen;
      if nvl(substr(c5rec.on_form,6,1),'F') = 'T'
       then
        htp.tabledata( '&nbsp;',cattributes=>clra || 'valign="MIDDLE" ' || align );
      end if;
      htp.tabledata( htf.bold(LNG.GLB_TXT_018),cattributes=>clra || 'valign="MIDDLE" ' || align );
      htp.tabledata( htf.formpassword( 'P5', 30, 100, null), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
     htp.tablerowclose;
   end if;

   for c7rec in c7(cusrec.aid,cusrec.pid,nvl(utype,'I')) loop
    htp.tablerowopen;
     if nvl(substr(c5rec.on_form,6,1),'F') = 'T'
      then
       if last_grp is null or last_grp <> c7rec.grouping
        then
         htp.tabledata( htf.bold(c7rec.grouping),cattributes=>clra || 'valign="MIDDLE" align="LEFT"' );
        else
         htp.tabledata( '&nbsp;',cattributes=>clra || 'valign="MIDDLE" ' || align );
       end if;
     end if;
     htp.tabledata( htf.bold(c7rec.column_name),cattributes=>clra || 'valign="MIDDLE" ' || align );
     if c7rec.column_type = 'V'
      then
       htp.tabledata( htf.formtext( 'P1', 30, 100, extract(cuscont,c7rec.internal_column)), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
     elsif c7rec.column_type = 'P'
      then
       htp.tabledata( htf.formpassword( 'P1', 30, 100, extract(cuscont,c7rec.internal_column)), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
     elsif c7rec.column_type = 'L'
      then
       htp.p( '<TD ' || clrb || 'valign="MIDDLE" align="LEFT">' );
       htp.formselectopen( 'P1' );
       lov_select( c7rec.lov,extract(cuscont,c7rec.internal_column));
       htp.formselectclose;
       htp.p( '</TD>' );
     elsif c7rec.column_type = 'B'
      then
       if nvl(extract(cuscont,c7rec.internal_column),'F') = 'T'
        then
         htp.tabledata( htf.formcheckbox( 'P3', c7rec.internal_column,'CHECKED'), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
        else
         htp.tabledata( htf.formcheckbox( 'P3', c7rec.internal_column), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
       end if;
     end if;
     if c7rec.column_type <> 'B' then htp.formhidden( 'P2', c7rec.internal_column ); end if;
    htp.tablerowclose;
    last_grp := c7rec.grouping;
   end loop;
   if c5rec.extra_prompt is not null
    then
      htp.tablerowopen;
       if nvl(substr(c5rec.on_form,6,1),'F') = 'T' then htp.tabledata( '&nbsp;',cattributes=>clra || 'valign="MIDDLE" ' || align ); end if;
       htp.tabledata( htf.bold(c5rec.extra_prompt),cattributes=>clra || 'valign="MIDDLE" ' || align );
       htp.tabledata( htf.formtext( 'P1', 30, 100, extract(cuscont,'EXTRA')), cattributes=>clrb || 'valign="MIDDLE" align="LEFT"' );
       htp.formhidden( 'P2', 'EXTRA' );
      htp.tablerowclose;
   end if;
 end if;
 htp.tableclose;

 -- Display Interest Groups
 htp.formhidden( 'P4', null );
 if nvl(substr(c5rec.on_form,4,1),'F') = 'T'
  then
   htp.nl;
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 ' || brd );
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNG3.ADM_TXT_817),cattributes=>clra || 'valign="MIDDLE" align="CENTER"' );
     htp.tablerowclose;
      htp.tablerowopen;
       htp.p( '<TD ' || clra || 'valign="MIDDLE" align="CENTER">');
       htp.formselectopen( 'P4', null, 5, cattributes=>'MULTIPLE' );
       htp.formselectoption( NULL );
       for c4rec in c4 loop
        open c3(cuscont.contact_id, c4rec.interest_id );
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          htp.formselectoption( c4rec.interest_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.interest_id || '"' );
         else
          close c3;
          htp.formselectoption( c4rec.interest_name, cattributes=>'VALUE="' || c4rec.interest_id || '"' );
        end if;
       end loop;
       htp.formselectclose;
       htp.p( '</TD>' );
      htp.tablerowclose;
    htp.tableclose;
   htp.nl;
 end if;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 if action = 'UPDATE'
  then
   htp.tabledata(htf.formsubmit( null, LNG2.PFM_TXT_116 ));
  else
   htp.tabledata(htf.formsubmit( null, LNG3.ADM_TXT_344 ));
 end if;
 htp.formclose;

 -- Display Button to Return to Image Listing
 if footer_api is not null
  then
   htp.formopen( footer_api );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
   htp.formhidden( 'START_FROM', start_from );
   htp.formhidden( 'DISPLAY_DETAIL', display_detail );
   htp.formhidden( 'ACID', acid );
   htp.tabledata( htf.formsubmit( null, LNG.CST_BUT_129 ));
 end if;
 htp.tablerowclose;
 htp.tableclose;
 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'CUST_CONTACT',vaid=>cusrec.aid,errmsg=>sqlerrm,extdet=>'Profid:' || PROFID);
end cust_contact;

procedure accept_cust_contact( surl in varchar2, acid in integer, profid in integer, contid in integer, ltype in varchar2, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY,
                               footer_api in varchar2 default null, left_api_parm in varchar2 default null, start_from in integer default null, display_detail in char default null )
as

 cursor c1( contid integer, ltype varchar2, acid integer ) is select * from customer_contact where contact_id = contid and login_type = ltype and aid = acid;
 cursor c2( intid integer, cid integer) is select 'x' from customer_interest where interest_id = intid and contact_id = cid;
 cursor c4( phgid integer ) is select * from photographer where pid = phgid;
 cursor c5(acid integer) is select * from generic_registration where aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 owner_id	integer;
 lgtype		varchar2(100);
 stype		integer;
 sts		varchar2(100);
 nmb		number;
 tlbox		boolean;
 nprofid	integer;
 bftr		varchar2(100);
 laf		varchar2(100);
 returnsurl	varchar2(100);
 result		varchar2(1000);
 gcode		GLBX.MYARRAY;
 gparam		GLBX.MYARRAY;

 function find_parm( fnd in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, defval in varchar2 default null )
  return varchar2
 is
 begin
  for j in p1.first..p1.last loop
   if p2(j) = fnd then return( p1(j) ); end if;
  end loop;
  return( defval );
 end find_parm;

begin
 glbx.cookie_id( surl, stype, lgtype, owner_id, sts, 'S', progcalled=>'CST.ACCEPT_CUST_CONTACT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, lgtype, acid, nprofid );
 if lgtype = 'PHOTOGRAPHER' then nprofid := profid; end if;
 -- Extra Details as Sent Down
 c1rec.sendto_name := find_parm('SENDTO_NAME',p1,p2);
 glbx.fixnm(c1rec.sendto_name,c1rec.sendto_firstname,c1rec.sendto_lastname);
 c1rec.sendto_street := find_parm('SENDTO_STREET',p1,p2);
 c1rec.sendto_branch := find_parm('SENDTO_BRANCH',p1,p2);
 c1rec.sendto_department := find_parm('SENDTO_DEPARTMENT',p1,p2);
 c1rec.sendto_suburb := find_parm('SENDTO_SUBURB',p1,p2);
 c1rec.sendto_city := find_parm('SENDTO_CITY',p1,p2);
 c1rec.sendto_country := find_parm('SENDTO_COUNTRY',p1,p2);
 c1rec.sendto_postcode := find_parm('SENDTO_POSTCODE',p1,p2);
 c1rec.sendto_state := find_parm('SENDTO_STATE',p1,p2);
 c1rec.contact_phone := find_parm('CONTACT_PHONE',p1,p2);
 c1rec.contact_mobile := find_parm('CONTACT_MOBILE',p1,p2);
 c1rec.contact_email := find_parm('CONTACT_EMAIL',p1,p2);
 c1rec.account_billing_id := find_parm('ACCOUNT_BILLING_ID',p1,p2);
 c1rec.account_password := find_parm('ACCOUNT_PASSWORD',p1,p2);
 begin nmb := to_number(find_parm('ACCOUNT_LIMIT',p1,p2)); exception when others then nmb := NULL; end;
 c1rec.account_limit := nmb;
 c1rec.billing_name := find_parm('BILLING_NAME',p1,p2);
 glbx.fixnm(c1rec.billing_name,c1rec.billing_firstname,c1rec.billing_lastname);
 c1rec.billing_street := find_parm('BILLING_STREET',p1,p2);
 c1rec.billing_suburb := find_parm('BILLING_SUBURB',p1,p2);
 c1rec.billing_city := find_parm('BILLING_CITY',p1,p2);
 c1rec.billing_department := find_parm('BILLING_DEPARTMENT',p1,p2);
 c1rec.billing_state := find_parm('BILLING_STATE',p1,p2);
 c1rec.billing_country := find_parm('BILLING_COUNTRY',p1,p2);
 c1rec.billing_postcode := find_parm('BILLING_POSTCODE',p1,p2);
 c1rec.billing_phone := find_parm('BILLING_PHONE',p1,p2);
 c1rec.billing_state := find_parm('BILLING_STATE',p1,p2);
 c1rec.billing_email := find_parm('BILLING_EMAIL',p1,p2);
 c1rec.billing_fax := find_parm('BILLING_FAX',p1,p2);
 c1rec.billing_gpo_box := find_parm('BILLING_GPO_BOX',p1,p2);
 c1rec.user_type := substr(find_parm('USER_TYPE',p1,p2),1,1);
 c1rec.tax_code := find_parm('TAX_CODE',p1,p2);
 c1rec.tax_group := find_parm('TAX_GROUP',p1,p2);
 c1rec.extra := find_parm('EXTRA',p1,p2);
 c1rec.accept_pay_by_acct := 'F';
 c1rec.receive_emails := 'F';
 if p3.count > 0
  then
   for j in p3.first..p3.last loop
    if p3(j) = 'ACCEPT_PAY_BY_ACCT' then c1rec.accept_pay_by_acct := 'T'; end if;
    if p3(j) = 'RECEIVE_EMAILS' then c1rec.receive_emails := 'T'; end if;
   end loop;
 end if;

 if action in ('NEW','DISCLAIMER','INSERT')
  then
   --
   if glbx.userexists( upper(p5(1)) )
    then
     -- This Username Already Exists Try Again
     cust_contact(surl=>surl, acid=>acid, profid=>profid, action=>'INSERT', cust_type=>c1rec.user_type, msg=>LNG4.AHC_TXT_487,
                  err_inst=>1, err_cust=>c1rec, extra_inf=>upper(p5(1)),
                  footer_api=>footer_api, left_api_parm=>left_api_parm, start_from=>start_from, display_detail=>display_detail );
     return;
    end if;

    -- Check Password Exists
    if p5(2) is null
     then
      cust_contact(surl=>surl, acid=>acid, profid=>profid, action=>'INSERT', cust_type=>c1rec.user_type, msg=>LNG3.ADM_TXT_163,
                   err_inst=>2, err_cust=>c1rec, extra_inf=>NULL,
                   footer_api=>footer_api, left_api_parm=>left_api_parm, start_from=>start_from, display_detail=>display_detail );
     return;
    end if;

    -- Create Profile
    open c5( cusrec.aid );
    fetch c5 into c5rec;
    close c5;
    if c1rec.user_type = 'I'
     then
      bftr := c5rec.business_feature_i;
      laf := c5rec.lov_i;
    elsif c1rec.user_type = 'S'
     then
      bftr := c5rec.business_feature_s;
      laf := c5rec.lov_s;
    elsif c1rec.user_type = 'C'
     then
      bftr := c5rec.business_feature_c;
      laf := c5rec.lov_c;
    end if;
    tlbox := FALSE;
    if nvl(substr(c5rec.on_submit,10,1),'F') = 'T' then tlbox := TRUE; end if;

    result := NULL;
    if nvl(substr(c5rec.on_submit,2,1),'F') = 'T' and c1rec.user_type = 'I' or
       nvl(substr(c5rec.on_submit,3,1),'F') = 'T' and c1rec.user_type = 'S' or
       nvl(substr(c5rec.on_submit,4,1),'F') = 'T' and c1rec.user_type = 'C'
     then
      glbx.create_profile( surl=>surl, profile_name=>initcap(p5(1)), profile_un=>upper(p5(1)), profile_pw=>upper(p5(2)), profile_pwg=>upper(p5(2)) || 'G',
                           bftr=>bftr, laf=>laf, transfer_lbox=>tlbox, acid=>cusrec.aid, return_surl=>returnsurl, result=>result);
      -- Check for an error on create
      if result is not null
       then
        cust_contact(surl=>surl, acid=>acid, profid=>profid, action=>'INSERT', cust_type=>c1rec.user_type, msg=>result,
                     err_inst=>3, err_cust=>c1rec, extra_inf=>NULL,
                     footer_api=>footer_api, left_api_parm=>left_api_parm, start_from=>start_from, display_detail=>display_detail );
        return;
      end if;

      -- Check for Auto Email
      if nvl(substr(c5rec.on_submit,5,1),'F') = 'T' and c1rec.user_type = 'I' or
         nvl(substr(c5rec.on_submit,6,1),'F') = 'T' and c1rec.user_type = 'S' or
         nvl(substr(c5rec.on_submit,7,1),'F') = 'T' and c1rec.user_type = 'C'
       then
        open c4(cusrec.pid);
        fetch c4 into c4rec;
        close c4;
        gcode(1) := 'PHOTOGRAPHER';
        gparam(1) := c4rec.business_name;
        gcode(2) := 'SIGNATURE';
        gparam(2) := glbx.extract_master_parameter('MAIL SIGNATURE');
        gcode(3) := 'USERNAME';
        gparam(3) := p5(1);
        gcode(4) := 'CUSTOMER';
        gparam(4) := cusrec.account_name;
        gcode(5) := 'USER_TYPE';
        gparam(5) := c1rec.user_type;
        gcode(6) := 'NAME';
        gparam(6) := c1rec.sendto_name;
        gcode(7) := 'STREET';
        gparam(7) := c1rec.sendto_street;
        gcode(8) := 'SUBURB';
        gparam(8) := c1rec.sendto_suburb;
        gcode(9) := 'CITY';
        gparam(9) := c1rec.sendto_city;
        gcode(10) := 'COUNTRY';
        gparam(10) := c1rec.sendto_country;
        gcode(11) := 'POSTCODE';
        gparam(11) := c1rec.sendto_postcode;
        gcode(12) := 'PHONE';
        gparam(12) := c1rec.contact_phone || '/' || c1rec.contact_mobile || '-' || c1rec.contact_email;
        glbx.send( gcode, gparam, 'phg_registration.tmp', p_to=>c4rec.contact_email, p_subj=>LNG4.AHC_TXT_803 || ':' || upper(p5(1)), p_from=>glbx.extract_master_parameter('MAIL_FROM'), scode=>'PR1');
      end if;

    end if;

  else

   open c1(contid,ltype,nvl(nprofid,cusrec.aid));
   fetch c1 into c1rec;
   if c1%NOTFOUND
    then
     close c1;
     if ltype = 'OWNER'
      then
       insert into customer_contact(contact_id,aid,login_type) values (contid,cusrec.aid,ltype);
      else
       insert into customer_contact(contact_id,aid,login_type) values (contid,nprofid,ltype);
     end if;
     commit;
     open c1(contid,ltype,nvl(nprofid,cusrec.aid));
     fetch c1 into c1rec;
   end if;
   close c1;
 end if;

 c1rec.sendto_name := find_parm('SENDTO_NAME',p1,p2,c1rec.sendto_name);
 glbx.fixnm(c1rec.sendto_name,c1rec.sendto_firstname,c1rec.sendto_lastname);
 c1rec.sendto_street := find_parm('SENDTO_STREET',p1,p2,c1rec.sendto_street);
 c1rec.sendto_suburb := find_parm('SENDTO_SUBURB',p1,p2,c1rec.sendto_suburb);
 c1rec.sendto_branch := find_parm('SENDTO_BRANCH',p1,p2,c1rec.sendto_branch);
 c1rec.sendto_department := find_parm('SENDTO_DEPARTMENT',p1,p2,c1rec.sendto_department);
 c1rec.sendto_city := find_parm('SENDTO_CITY',p1,p2,c1rec.sendto_city);
 c1rec.sendto_country := find_parm('SENDTO_COUNTRY',p1,p2,c1rec.sendto_country);
 c1rec.sendto_postcode := find_parm('SENDTO_POSTCODE',p1,p2,c1rec.sendto_postcode);
 c1rec.sendto_state := find_parm('SENDTO_STATE',p1,p2,c1rec.sendto_state);
 c1rec.contact_phone := find_parm('CONTACT_PHONE',p1,p2,c1rec.contact_phone);
 c1rec.contact_mobile := find_parm('CONTACT_MOBILE',p1,p2,c1rec.contact_mobile);
 c1rec.contact_email := find_parm('CONTACT_EMAIL',p1,p2,c1rec.contact_email);
 c1rec.account_billing_id := find_parm('ACCOUNT_BILLING_ID',p1,p2,c1rec.account_billing_id);
 c1rec.account_password := find_parm('ACCOUNT_PASSWORD',p1,p2,c1rec.account_password);
 begin nmb := to_number(find_parm('ACCOUNT_LIMIT',p1,p2,c1rec.account_limit)); exception when others then nmb := NULL; end;
 c1rec.account_limit := nmb;
 c1rec.billing_name := find_parm('BILLING_NAME',p1,p2,c1rec.billing_name);
 glbx.fixnm(c1rec.billing_name,c1rec.billing_firstname,c1rec.billing_lastname);
 c1rec.billing_street := find_parm('BILLING_STREET',p1,p2,c1rec.billing_street);
 c1rec.billing_suburb := find_parm('BILLING_SUBURB',p1,p2,c1rec.billing_suburb);
 c1rec.billing_branch := find_parm('BILLING_BRANCH',p1,p2,c1rec.billing_branch);
 c1rec.billing_department := find_parm('BILLING_DEPARTMENT',p1,p2,c1rec.billing_department);
 c1rec.billing_city := find_parm('BILLING_CITY',p1,p2,c1rec.billing_city);
 c1rec.billing_country := find_parm('BILLING_COUNTRY',p1,p2,c1rec.billing_country);
 c1rec.billing_postcode := find_parm('BILLING_POSTCODE',p1,p2,c1rec.billing_postcode);
 c1rec.billing_phone := find_parm('BILLING_PHONE',p1,p2,c1rec.billing_phone);
 c1rec.billing_email := find_parm('BILLING_EMAIL',p1,p2,c1rec.billing_email);
 c1rec.billing_state := find_parm('BILLING_STATE',p1,p2,c1rec.billing_state);
 c1rec.billing_gpo_box := find_parm('BILLING_GPO_BOX',p1,p2,c1rec.billing_gpo_box);
 c1rec.billing_fax := find_parm('BILLING_FAX',p1,p2,c1rec.billing_fax);
 c1rec.tax_code := find_parm('TAX_CODE',p1,p2,c1rec.tax_code);
 c1rec.tax_group := find_parm('TAX_GROUP',p1,p2,c1rec.tax_group);
 c1rec.user_type := find_parm('USER_TYPE',p1,p2,c1rec.user_type);
 c1rec.extra := find_parm('EXTRA',p1,p2,c1rec.extra);
 c1rec.accept_pay_by_acct := 'F';
 c1rec.receive_emails := 'F';
 if p3.count > 0
  then
   for j in p3.first..p3.last loop
    if p3(j) = 'ACCEPT_PAY_BY_ACCT' then c1rec.accept_pay_by_acct := 'T'; end if;
    if p3(j) = 'RECEIVE_EMAILS' then c1rec.receive_emails := 'T'; end if;
   end loop;
 end if;
 update customer_contact
  set
   sendto_name = c1rec.sendto_name,
   sendto_firstname = c1rec.sendto_firstname,
   sendto_lastname = c1rec.sendto_lastname,
   sendto_street = c1rec.sendto_street,
   sendto_suburb = c1rec.sendto_suburb,
   sendto_city = c1rec.sendto_city,
   sendto_country = c1rec.sendto_country,
   sendto_postcode = c1rec.sendto_postcode,
   sendto_state = c1rec.sendto_state,
   sendto_branch = c1rec.sendto_branch,
   sendto_department = c1rec.sendto_department,
   contact_phone = c1rec.contact_phone,
   contact_mobile = c1rec.contact_mobile,
   contact_email = c1rec.contact_email,
   receive_emails = c1rec.receive_emails,
   account_billing_id = c1rec.account_billing_id,
   account_password = c1rec.account_password,
   account_limit = c1rec.account_limit,
   billing_name = c1rec.billing_name,
   billing_firstname = c1rec.billing_firstname,
   billing_lastname = c1rec.billing_lastname,
   billing_street = c1rec.billing_street,
   billing_suburb = c1rec.billing_suburb,
   billing_city = c1rec.billing_city,
   billing_branch = c1rec.billing_branch,
   billing_department = c1rec.billing_department,
   billing_country = c1rec.billing_country,
   billing_postcode = c1rec.billing_postcode,
   billing_phone = c1rec.billing_phone,
   billing_email = c1rec.billing_email,
   billing_fax = c1rec.billing_fax,
   billing_state = c1rec.billing_state,
   billing_gpo_box = c1rec.billing_gpo_box,
   tax_code = c1rec.tax_code,
   tax_group = c1rec.tax_group,
   accept_pay_by_acct = c1rec.accept_pay_by_acct,
   extra = c1rec.extra,
   user_type = c1rec.user_type
  where contact_id = contid;

 delete from customer_interest where contact_id = contid;
 for j in p4.first..p4.last loop
  if p4(j) is not null
   then
    open c2(p4(j),contid);
    fetch c2 into c2rec;
    if c2%NOTFOUND
     then
      insert into customer_interest( interest_id, contact_id ) values (p4(j), contid);
    end if;
    close c2;
  end if;
 end loop;
 commit;

 cust_contact(surl,acid,nprofid,msg=>LNG2.PBK_TXT_116);

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_CUST_CONTACT',vaid=>acid,errmsg=>sqlerrm,extdet=>'Contid:' || contid);
end accept_cust_contact;

procedure mng_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, msg in varchar2 default null, ispopup in boolean default FALSE )
as

 cursor c2( acid integer, ltype varchar2 ) is select * from lightbox_header where aid = acid and login_type = ltype order by decode(is_default,'T',0,1),name;
 cursor c3( lid integer ) is select count('x') tot, sum( sign( nvl(length(note) ,0))) snote from lightbox where lightid = lid;
 cursor c4( sess_id integer ) is select count('x') tot, nvl(sum( sign( nvl(length(note) ,0))),0) snote from lightbox where lightid is null and sessid = sess_id;
 cursor c5( acid integer, ltype varchar2) is select lightid,name from lightbox_header where aid = acid and login_type = ltype order by name;
 cursor c6( acid integer, nmb integer ) is
  select order_by,display_name,call_type,program_name,first_parameter, nd.novelty_id
  from  novelty_definition nd, novelty_set ns, charge_plan cp, photographer p, customer_account ca
  where substr(where_called,2,1) = 'T' and
        substr(available_to,nmb,1) = 'T' and
        nd.novelty_id = ns.novelty_id and
        ns.novelty_set_id = cp.novelty_set_id and
        cp.id = p.plan_id and
        p.pid = ca.pid and
        ca.aid = acid and
        0 in (select count('x') tot from novelty_customer where aid = acid)
  union
  select order_by,display_name,call_type,program_name,first_parameter, nd.novelty_id
  from  novelty_definition nd, customer_account ca, novelty_customer nc
  where substr(where_called,2,1) = 'T' and
        substr(available_to,nmb,1) = 'T' and
        nd.novelty_id = nc.novelty_id and
        ca.aid = acid and
        nc.aid = ca.aid
  order by 1;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 tb_open	boolean;
 tb_close	boolean;
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 jscript	varchar2(1000);
 jscript_close	varchar2(1000);
 lbox		varchar2(1000);
 url		varchar2(32767);
 mvto		varchar2(32767);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.MNG_LIGHTBOX');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 if ltype in ('PHOTOGRAPHER','OWNER') then profid := c1rec.aid; end if;
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );

 if pfx.fullimg_jscript_popup = 'T'
  then
   jscript := 'javascript: parent.opener.location = ''';
   jscript_close := '''; parent.close();';
  else
   jscript := NULL;
   jscript_close := NULL;
 end if;

 lbox := glbx.userpref(c1rec.pid,c1rec.aid,'LIGHTBOX');
 glbx.main_title( surl, LNG5.EXT_TXT_092 || ' ' || lbox,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C27' ,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,ispopup=>TRUE,stylesh=>pfx.stylesheet);
 htp.nl;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNG5.EXT_TXT_090 || ' ' || lbox), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( htf.bold(LNG3.ADM_TXT_490), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
   htp.tabledata( htf.bold(LNG5.EXT_TXT_091), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
   if is_bf(theme_rec,ltype,192,null,'T','T',191,'T') --Lightbox Utilities
    then
      htp.tabledata( htf.bold(LNG3.ADM_TXT_064), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.bold(LNG.PHG_TXT_352), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
  htp.tablerowclose;
  -- Extract Default Lightbox
  open c4(owner_id);
  fetch c4 into c4rec;
  close c4;
  htp.tablerowopen;
   htp.tabledata( htf.anchor( 'cst.disp_lightbox?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid, LNG.PHG_TXT_042), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( c4rec.tot, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c4rec.snote),'&nbsp;'), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   tb_open := FALSE;
   tb_close := FALSE;
   if is_bf(theme_rec,ltype,192,null,'T','T',191,'T') --Lightbox Utilities
    then
     htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
      tb_open := TRUE;
      tb_close := TRUE;
      url := 'cst.accept_mng_lightbox?surl=' || surl || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&lbox=' || replace(lbox,' ','+') || '&action=' ||  replace(LNG5.EXT_TXT_238,' ','+')  || '&p1=' || '&p2=';
      if pfx.fullimg_jscript_popup = 'T'
       then
         url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_301,' ','_') ||
                ''',''height=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + pfx.fullimg_popup_height) ||
                ',width=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + 100 + pfx.fullimg_popup_width) || ',scrollbars=yes,resizable=yes'');void('''');';
      end if;
      htp.anchor( url, '. ' || LNG5.EXT_TXT_238);
   end if;

   -- Review Novelty Items
   for c6rec in c6( c1rec.aid, glbx.available_to( ltype ) ) loop
    if c6%ROWCOUNT = 1 and not tb_open then htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' ); else htp.nl; end if;
    tb_close := TRUE;
    url := c6rec.program_name || '?surl=' || surl || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&called_from=' || 'LIGHTBOX' || '&first_parameter=' || replace(c6rec.first_parameter,' ','+') || '&loc_id=' || '&nvid=' || c6rec.novelty_id;
    if pfx.fullimg_jscript_popup = 'T'
     then
       url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_301,' ','_') ||
              ''',''height=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + pfx.fullimg_popup_height) ||
              ',width=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + 100 + pfx.fullimg_popup_width) || ',scrollbars=yes,resizable=yes'');void('''');';
    end if;
    htp.anchor( url, '. ' || c6rec.display_name);
   end loop;
   if tb_close then htp.p( '</TD>' ); end if;

   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
    htp.anchor('cst.accept_mng_lightbox?surl=' || surl || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&called_from=' || replace(lbox,' ','+') || '&action=' ||  replace(LNG4.AHC_TXT_432,' ','+') || '&p1=&p2=', '. ' || LNG4.AHC_TXT_432);
    mvto := NULL;
    for c5rec in c5(profid,ltype) loop
     mvto := mvto || htf.formselectoption( c5rec.name, cattributes=>'VALUE="' || c5rec.lightid || '"' );
    end loop;
    if mvto is null
     then
      null;
    else
     htp.nl;
     htp.p(htf.formopen( 'cst.accept_mng_lightbox' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'FOOTER_API', footer_api ) || htf.formhidden( 'LEFT_API_PARM', left_api_parm ) || htf.formhidden( 'START_FROM', start_from ) || htf.formhidden( 'DISPLAY_DETAIL', display_detail ) || htf.formhidden( 'ACID', acid ) || htf.formhidden( 'LBOX', lbox ) ||
           htf.formhidden( 'P2', NULL ) || htf.formsubmit( 'ACTION', LNG2.PFM_TXT_152 ) || htf.formselectopen( 'P1' ) || htf.formselectoption( NULL ) || mvto || htf.formselectclose || htf.formclose);
    end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  for c2rec in c2(profid, ltype ) loop
   open c3(c2rec.lightid);
   fetch c3 into c3rec;
   close c3;
   -- Fix any missing lightbox session ids
   update lightbox
    set sessid = owner_id
   where
    lightid = c2rec.lightid and
    sessid <> owner_id;

   htp.tablerowopen;
    if c2rec.is_default = 'T'
     then
      htp.tabledata( htf.anchor( 'cst.disp_lightbox?surl=' || surl || '&left_api_parm=[LBOX:' || c2rec.lightid || ']' || left_api_parm || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid, '* ' || c2rec.name ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
     else
      htp.tabledata( htf.anchor( 'cst.disp_lightbox?surl=' || surl || '&left_api_parm=[LBOX:' || c2rec.lightid || ']' || left_api_parm || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid, c2rec.name), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    end if;
    htp.tabledata( c3rec.tot, cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata( nvl(to_char(c3rec.snote),'0'), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');

    tb_open := FALSE;
    tb_close := FALSE;
    if is_bf(theme_rec,ltype,192,null,'T','T',191,'T') --Lightbox Utilities
     then
      tb_open := TRUE;
      tb_close := TRUE;
      htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
      url := 'cst.accept_mng_lightbox?surl=' || surl || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&lbox=' || replace(lbox,' ','+') || '&action=' ||  replace(LNG5.EXT_TXT_238,' ','+')  || '&p1=' || c2rec.lightid || '&p2=';
      if pfx.fullimg_jscript_popup = 'T'
       then
         url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_301,' ','_') ||
                ''',''height=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + pfx.fullimg_popup_height) ||
                ',width=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + 100 + pfx.fullimg_popup_width) || ',scrollbars=yes,resizable=yes'');void('''');';
      end if;
      htp.anchor( url, '. ' || LNG5.EXT_TXT_238);
    end if;

   -- Review Novelty Items
   for c6rec in c6( c1rec.aid, glbx.available_to( ltype ) ) loop
    if c6%ROWCOUNT = 1 and not tb_open then htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' ); else htp.nl; end if;
    tb_close := TRUE;
    url := c6rec.program_name || '?surl=' || surl || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&called_from=' || 'LIGHTBOX' || '&first_parameter=' || replace(c6rec.first_parameter,' ','+') || '&loc_id=' || c2rec.lightid || '&nvid=' || c6rec.novelty_id;
    if pfx.fullimg_jscript_popup = 'T'
     then
       url := 'javascript: window.open(''' || url || ''',''' || replace(LNG5.EXT_TXT_301,' ','_') ||
              ''',''height=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + pfx.fullimg_popup_height) ||
              ',width=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) + 100 + pfx.fullimg_popup_width) || ',scrollbars=yes,resizable=yes'');void('''');';
    end if;
    htp.anchor( url, '. ' || c6rec.display_name);
   end loop;
   if tb_close then htp.p( '</TD>' ); end if;

   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT">' );
    if nvl(c3rec.tot,0) = 0
     then
      -- Delete
      htp.anchor('cst.accept_mng_lightbox?surl=' || surl || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&lbox=' || replace(lbox,' ','+') || '&action=' ||  replace(LNG.SLD_TXT_004,' ','+')  || '&p1=' || c2rec.lightid || '&p2=', '. ' || LNG.SLD_TXT_004);
     else
      -- Empty
      htp.anchor('cst.accept_mng_lightbox?surl=' || surl || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&lbox=' || replace(lbox,' ','+') || '&action=' ||  replace(LNG4.AHC_TXT_432,' ','+') || '&p1=' || c2rec.lightid || '&p2=','. ' || LNG4.AHC_TXT_432);
    end if;
    if c2rec.is_default = 'F'
     then
      htp.nl;
      htp.anchor('cst.accept_mng_lightbox?surl=' || surl || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&lbox=' || replace(lbox,' ','+') || '&action=' ||  replace(LNG5.EXT_TXT_237,' ','+')  || '&p1=' || c2rec.lightid || '&p2=', '. ' || LNG5.EXT_TXT_237);
    end if;
    mvto := NULL;
    for c5rec in c5(profid,ltype) loop
     if c5rec.lightid = c2rec.lightid
      then
       null;
       -- mvto := mvto || htf.formselectoption( c5rec.name, 'SELECTED', cattributes=>'VALUE="' || c5rec.lightid || '"' );
      else
       mvto := mvto || htf.formselectoption( c5rec.name, cattributes=>'VALUE="' || c5rec.lightid || '"' );
     end if;
    end loop;
    if mvto is null
     then
      null;
     else
      htp.nl;
      htp.p( htf.formopen( 'cst.accept_mng_lightbox' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'FOOTER_API', footer_api ) || htf.formhidden( 'LEFT_API_PARM', left_api_parm ) || htf.formhidden( 'START_FROM', start_from ) || htf.formhidden( 'DISPLAY_DETAIL', display_detail ) || htf.formhidden( 'ACID', acid ) || htf.formhidden( 'LBOX', lbox ) ||
             htf.formhidden( 'P2', c2rec.lightid ) || htf.formsubmit( 'ACTION', LNG2.PFM_TXT_152 ) || htf.formselectopen( 'P1' ) || htf.formselectoption( NULL ) || mvto || htf.formselectclose || htf.formclose);
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  end loop;

  htp.formopen( 'cst.accept_mng_lightbox' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'FOOTER_API', footer_api );
  htp.formhidden( 'LEFT_API_PARM', left_api_parm );
  htp.formhidden( 'START_FROM', start_from );
  htp.formhidden( 'DISPLAY_DETAIL', display_detail );
  htp.formhidden( 'ACID', acid );
  htp.formhidden( 'LBOX', lbox );
   htp.tablerowopen;
    htp.tabledata( htf.formtext( 'P1', 30, 100 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata( htf.formsubmit('ACTION', LNG5.EXT_TXT_087 || ' ' || lbox ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
    htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.nl;
 if ispopup
  then
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
  else
   htp.anchor( nvl(footer_api,'cst.disp_lightbox') || '?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid,LNG.CST_TXT_014 );
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'CST', 'MNG_LIGHTBOX',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end mng_lightbox;

procedure accept_mng_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, p1 in varchar2, p2 in varchar2 default null, lbox in varchar2, action in varchar2 )
as

 cursor c2(acid integer, ltype varchar2, nme varchar2) is
  select 'x' exst from lightbox_header where aid = acid and login_type = ltype and name = nme;

 cusrec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 msg		varchar2(1000);
 llight		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts , 'S', progcalled=>'CST.ACCEPTMNG_LIGHTBOX');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 if ltype in ('PHOTOGRAPHER','OWNER') then profid := cusrec.aid; end if;

 if action = LNG5.EXT_TXT_087 || ' ' || lbox
  then
   -- Create
   if p1 is null
    then
     mng_lightbox( surl, footer_api, left_api_parm, start_from, display_detail, acid, lbox || ' ' || LNG5.EXT_TXT_089 );
     return;
   end if;
   open c2(profid,ltype,upper(p1));
   fetch c2 into c2rec;
   if c2%FOUND
    then
     close c2;
     mng_lightbox( surl, footer_api, left_api_parm, start_from, display_detail, acid, lbox || ' ' || LNG5.EXT_TXT_088 );
     return;
   end if;
   close c2;
   select s_lightbox_header.nextval into llight from dual;
   insert into lightbox_header(lightid,aid,login_type,date_created,name) values ( llight, profid, ltype, sysdate, upper(p1) );
   commit;
   msg := lbox || ' ' || LNG3.ADM_TXT_367;

 elsif action = LNG2.PFM_TXT_152
  then
   -- Move Contents
   update lightbox
    set
     lightid = p1
   where
    (
     ((lightid = p2) and (p2 is not null)) or
     ((lightid is null) and (p2 is null))
     ) and
    sessid = owner_id;
   commit;
   msg := LNG4.AHC_TXT_918;

 elsif action = LNG4.AHC_TXT_432
  then
   -- Empty Contents
   delete from lightbox
   where
    (
     ((lightid = p1) and (p1 is not null)) or
     ((lightid is null) and (p1 is null))
     ) and
    sessid = owner_id;
   commit;
   msg := LNG4.AHC_TXT_918;

 elsif action = LNG5.EXT_TXT_237
  then
   -- Make Default
   update lightbox_header
    set
     is_default = 'F'
    where aid = cusrec.aid and
          login_type = ltype;
   update lightbox_header
    set
     is_default = 'T'
    where aid = cusrec.aid and
          lightid = p1;
   commit;

 elsif action = LNG.SLD_TXT_004
  then
   -- Delete Contents
   delete from lightbox
   where
    (
     ((lightid = p1) and (p1 is not null)) or
     ((lightid is null) and (p1 is null))
     ) and
    sessid = owner_id;
   delete from lightbox_header
    where (lightid = p1) and (p1 is not null);
   commit;
   msg := LNG4.AHC_TXT_918;

 elsif action = LNG5.EXT_TXT_238
  then
   prompt_email_lightbox(surl, footer_api, left_api_parm, start_from, display_detail, acid, lbox, cusrec, stype, ltype, owner_id, p1 );
   return;

 end if;
 mng_lightbox( surl, footer_api, left_api_parm, start_from, display_detail, acid, msg );
exception when others then
 glbx.error_details( 'CST', 'ACCEPT_MNG_LIGHTBOX',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end accept_mng_lightbox;

procedure add_all_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, p1 in varchar2, msg in varchar2 default null )
as

 cursor c2(sess_id integer) is select max(order_by) from lightbox where sessid = sess_id;

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 maxctr		integer;
 sts		varchar2(100);
 lst		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.ADD_ALL_LIGHTBOX');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 if ltype in ('PHOTOGRAPHER','OWNER') then profid := c1rec.aid; end if;
 lst := glbx.extract_umos( p1 );
 open c2(owner_id);
 fetch c2 into maxctr;
 close c2;

 for j in lst.first..lst.last loop
  if lst(j) is not null
   then
    maxctr := nvl(maxctr,0) + 1;
    insert into lightbox(sessid,umo_id,order_by)
     select owner_id,lst(j),maxctr
     from dual
     where not exists( select 'x' from lightbox where sessid = owner_id and umo_id = to_number(lst(j)));
    maxctr := maxctr + 1;
  end if;
 end loop;
 commit;

 -- Return back to Category Listing or go to the Lightbox
 if glbx.userpref(c1rec.pid,c1rec.aid,'RET_ORIG') = LNG.PHG_TXT_046
  then
   execute immediate
    'begin ' || 'cst.disp_lightbox' ||
     '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
    'end;'
    using glbx.rndsurl(surl),left_api_parm,start_from,display_detail,acid;
  else
   execute immediate
    'begin ' || footer_api ||
     '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
    'end;'
    using glbx.rndsurl(surl),left_api_parm,start_from,display_detail,acid;
 end if;

exception when others then
 glbx.error_details( 'CST', 'ADD_ALL_LIGHTBOX',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end add_all_lightbox;

procedure lightbox_note(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, v_umo integer, msg in varchar2 default null )
as

 cursor c2(lid integer, v_umo integer, sess_id integer) is
  select *
  from lightbox
  where ((lid is null and sessid=sess_id) or
         (lid is not null and lightid = lid) ) and
        (umo_id = v_umo);

 cursor c3(v_umo integer) is select nvl(um.extras.photo_name,um.extras.film_name) pname from umo um where umo_id = v_umo;

 cursor c4(acid integer, ltype varchar2) is select lightid,name from lightbox_header where aid = acid and login_type = ltype order by name;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 lbox		varchar2(1000);
 lid		integer;
 mvto		varchar2(32767);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.LIGHTBOX_NOTE');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 if ltype in ('PHOTOGRAPHER','OWNER') then profid := c1rec.aid; end if;
 pfx := glbx.get_thm( c1rec.theme_name );
 lbox := glbx.userpref(c1rec.pid,c1rec.aid,'LIGHTBOX');
 if substr(left_api_parm,1,6) = '[LBOX:'
  then
   begin lid := substr(left_api_parm,7,instr(left_api_parm,']')-7); exception when others then lid := NULL; end;
 end if;
 open c2(lid,v_umo,owner_id);
 fetch c2 into c2rec;
 close c2;
 open c3(v_umo);
 fetch c3 into c3rec;
 close c3;
 mvto := NULL;
 for c4rec in c4(profid,ltype) loop
  if c4rec.lightid = lid
   then
    mvto := mvto || htf.formselectoption( c4rec.name, 'SELECTED', cattributes=>'VALUE="' || c4rec.lightid || '"' );
   else
    mvto := mvto || htf.formselectoption( c4rec.name, cattributes=>'VALUE="' || c4rec.lightid || '"' );
  end if;
 end loop;
 glbx.main_title( surl, LNG5.EXT_TXT_093, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C28' ,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,ispopup=>TRUE,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 if msg is not null then glbx.header_msg(msg); end if;
 htp.formopen( 'cst.accept_lightbox_note' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'START_FROM', start_from );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'V_UMO', v_umo );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( c3rec.pname ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formtextareaopen( 'P1', 10, 60, cattributes=>'WRAP="VIRTUAL"' ) || c2rec.note || htf.formtextareaclose, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
  htp.tablerowclose;
 if mvto is null
  then
   htp.formhidden( 'P2', null );
  else
  htp.tablerowopen;
   htp.tabledata( LNG5.EXT_TXT_097 || ' ' || lbox || ' ' || htf.formselectopen( 'P2' ) || htf.formselectoption( NULL ) || mvto || htf.formselectclose, cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="CENTER"');
  htp.tablerowclose;
 end if;
 htp.tableclose;
 htp.nl;

 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_095 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_096 );
 htp.formsubmit( 'ACTION', LNG4.AHC_TXT_919 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'CST', 'LIGHTBOX_NOTE',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end lightbox_note;

procedure accept_lightbox_note(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, v_umo integer, p1 in varchar2, p2 in varchar2, action in varchar2 )
as

 cursor c2(lid integer, v_umo integer, sess_id integer) is
  select rowid
  from lightbox
  where ((lid is null and sessid=sess_id) or
         (lid is not null and lightid = lid) ) and
        (umo_id = v_umo);

 cursor c3(v_umo integer) is select nvl(um.extras.photo_name,um.extras.film_name) pname from umo um where umo_id = v_umo;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 lbox		varchar2(1000);
 lid		integer;
 nt		varchar2(4000);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.ACCEPT_LIGHTBOX_NOTE');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if action = LNG4.AHC_TXT_919
  then
    execute immediate
      'begin ' || 'cst.disp_lightbox' ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
      'end;'
      using glbx.rndsurl(surl),left_api_parm,start_from,display_detail,acid;
    return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 if ltype in ('PHOTOGRAPHER','OWNER') then profid := c1rec.aid; end if;
 pfx := glbx.get_thm( c1rec.theme_name );
 lbox := glbx.userpref(c1rec.pid,c1rec.aid,'LIGHTBOX');
 if substr(left_api_parm,1,6) = '[LBOX:'
  then
   begin lid := substr(left_api_parm,7,instr(left_api_parm,']')-7); exception when others then lid := NULL; end;
 end if;
 open c2(lid,v_umo,owner_id);
 fetch c2 into c2rec;
 close c2;
 nt := glbx.censor(p1,4000);
 update lightbox
  set
   note = nt,
   lightid = p2
 where
  rowid = c2rec.rowid;
 commit;

 if action = LNG5.EXT_TXT_095
  then
    lightbox_note(surl, footer_api, left_api_parm, start_from, display_detail, acid, v_umo, 'Note Successfully Attached' );
  else
    execute immediate
      'begin ' || 'cst.disp_lightbox' ||
       '(surl=>:surl,left_api_parm=>:left_api_parm,start_from=>:start_from,display_detail=>:display_detail,acid=>:acid);' ||
      'end;'
      using glbx.rndsurl(surl),left_api_parm,start_from,display_detail,acid;
 end if;
exception when others then
 glbx.error_details( 'CST', 'ACCEPT_LIGHTBOX_NOTE',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end accept_lightbox_note;

procedure intercept_icon( surl in varchar2, v_umo in integer )
as

 cursor c2(acid integer, phgr integer, imgtype varchar2, v_umo in integer) is
   select um.photo_master, um.umo_id, um.version, 'J' typ, um.extras.orderby_nmb orderby_nmb, attribute1, attribute2
   from umo um, customer_account ca
   where um.aid = acid and
         um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'F' and
         umo_type = imgtype and
         um.umo_id = v_umo
   union all
   select um.photo_master, um.umo_id, um.version, 'K' typ, um.extras.orderby_nmb orderby_nmb, attribute1, attribute2
   from umo um, customer_account ca
   where um.aid = ca.aid and
         ca.pid = phgr and
         um.is_global = 'T' and
         umo_type = imgtype and
         um.umo_id = v_umo;

 cursor c3(acid integer) is select pid,advert,business_name,username,home_site,logo_phid,abn_number,private_gallery from photographer where pid = (select pid from customer_account where aid=acid);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 hsite		varchar2(1000);
 http		varchar2(1000);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.INTERCEPT_ICON');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, null, profid );
 open c3( c1rec.aid );
 fetch c3 into c3rec;
 close c3;
 hsite := c3rec.home_site;
 open c2( c1rec.aid, c1rec.pid, 'ICON', v_umo );
 fetch c2 into c2rec;
 close c2;
 http := ump.uma_attribute( surl, c2rec.umo_id, 'ICON', 'HTTP_LINK' );
 if http is not null then hsite := http; end if;
 hsite := glbx.adjust_for_http( hsite );
 -- Add Statistics on Click
 if nvl(c2rec.attribute1,'F') = 'T'
  then
   insert into photographer_icon_stats(pid,aid,umo_id,login_session,date_created) values (c1rec.pid,c1rec.aid,v_umo,owner_id,sysdate);
   commit;
 end if;
 -- Logoff
 if nvl(c2rec.attribute2,'F') = 'T'
  then
   glbx.acct_logoff(surl,'T','F',hsite);
  else
   glbx.acct_logoff(surl,'T','F',null);
 end if;
exception when others then
 glbx.error_details( 'CST', 'INTERCEPT_ICON',errmsg=>sqlerrm,extdet=>'V_UMO:' || v_umo);
end intercept_icon;

procedure meta_edit( surl in varchar2, v_umo in integer, acid in integer, reterrors in GLBX.MYARRAY )
as

 cursor c2(v_umo integer) is select * from umo where umo_id = v_umo;

 c1rec		customer_account%ROWTYPE;
 umorec		umo%ROWTYPE;
 utype		varchar2(100);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 res		boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.META_EDIT');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 -- Anonymous Accounts cannot edit meta data
 if not ltype in ('PHOTOGRAPHER','OWNER','PROFILE') then htp.bold( 'Invalid Access' ); return; end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 if not is_bf(theme_rec,ltype,90,91,'T','T',89,'T') then htp.p( 'Illegal Access'); return; end if;
 glbx.main_title( surl, LNG3.ADM_TXT_938, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C29',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;
 if reterrors.exists(1)
  then
   for j in reterrors.first..reterrors.last loop
    if reterrors(j) is not null
     then
      glbx.header_msg(reterrors(j));
    end if;
   end loop;
 end if;

 open c2(v_umo);
 fetch c2 into umorec;
 close c2;
 htp.p( main_image(surl, stype, ltype, acid, umorec, c1rec, pfx, theme_rec, null, nvl(umorec.extras.photo_name,umorec.extras.film_name), 'CELL', null, null, null, null, null) );

 htp.formopen( 'cst.accept_meta_edit' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'V_UMO', v_umo );
 htp.formhidden( 'ACID', acid );
 res := glbx.img_meta_edit( v_umo, umorec.umo_type, pfx, TRUE, stype, acid, ltype, bftr=>c1rec.theme_type );
 htp.nl;
 htp.formsubmit( null, LNG3.ADM_TXT_938 );
 htp.formclose;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'CST', 'META_EDIT',vaid=>acid,errmsg=>sqlerrm,extdet=>'V_UMO:' || v_umo);
end meta_edit;

procedure accept_meta_edit( surl in varchar2, v_umo in integer, acid in integer, tag_id in glbx.myarray, tag_name in glbx.myarray, tag_value in glbx.myarray )
as

 cursor c2(v_umo integer) is select umo_type from umo where umo_id = v_umo;

 c1rec		customer_account%ROWTYPE;
 utype		varchar2(100);
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 res		boolean;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 reterrors	GLBX.MYARRAY;
 reterrors_ctr	integer;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.META_EDIT');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 -- Anonymous Accounts cannot edit meta data
 if not ltype in ('PHOTOGRAPHER','OWNER','PROFILE') then htp.bold( 'Invalid Access' ); return; end if;
 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 if not is_bf(theme_rec,ltype,90,91,'T','T',89,'T') then htp.p( 'Illegal Access'); return; end if;

 open c2(v_umo);
 fetch c2 into utype;
 close c2;

 res := glbx.update_meta_data( surl, v_umo, acid, utype, ltype, tag_id, tag_name, tag_value, reterrors, reterrors_ctr);
 commit;

 if reterrors_ctr > 0
  then
   meta_edit(surl, v_umo, acid, reterrors );
   return;
  else
   reterrors(1) := LNG3.ADM_TXT_559;
   meta_edit(surl, v_umo, acid, reterrors );
 end if;

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_META_EDIT',vaid=>acid,errmsg=>sqlerrm,extdet=>'V_UMO:' || v_umo);
end accept_meta_edit;

function main_image(surl in varchar2, stype in integer, ltype in varchar2, acid in integer, umorec in umo%ROWTYPE, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, usemap in varchar2, photo_name in varchar2, style in varchar2 default 'CELL', footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, voidrec in order_style%ROWTYPE )
 return varchar2
as

 dspv		integer;
 oth		integer;
 adj		integer;

begin
   if umorec.photo_master.width > umorec.photo_master.height
    then
     if glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
      then
       dspv := umorec.photo_master.width;
       oth := umorec.photo_master.height;
       adj := 1;
      else
       dspv := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
       oth := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / umorec.photo_master.width) * umorec.photo_master.height;
       adj := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / umorec.photo_master.width);
     end if;
   else
    if glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
    then
     dspv := umorec.photo_master.height;
     oth := umorec.photo_master.width;
     adj := 1;
    else
     dspv := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
     oth := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / umorec.photo_master.height ) * umorec.photo_master.width;
     adj := trunc(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / umorec.photo_master.height);
    end if;
   end if;

   if style = 'CELL'
    then
     if umorec.photo_master.width > umorec.photo_master.height
      then
       if is_bf(theme_rec,ltype,160,161,'T','T') and not (substr(cusrec.zoom_factor,1,9) = 'FFFFFFFFF')
        then
         return(  htf.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version,
                     '<IMG BORDER=0 WIDTH=' || to_char(dspv) || usemap || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version ||
                     '" ALT="' || photo_name || '" STYLE="display:block;">',ctarget=>'NEW_WINDOW' ), cattributes=>'align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' ));
       else
        return(  htf.tabledata( '<IMG BORDER=0 WIDTH=' || to_char(dspv) || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version ||
                     '" ALT="' || photo_name || '">',cattributes=>'align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' ));
       end if;
      else
       if is_bf(theme_rec,ltype,160,161,'T','T') and not (substr(cusrec.zoom_factor,1,9) = 'FFFFFFFFF')
        then
         return( htf.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version,
                     '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || usemap || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version ||
                     '" ALT="' || photo_name || '" STYLE="display:block;">',ctarget=>'NEW_WINDOW' ), cattributes=>'align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' ));
       else
        return( htf.tabledata( '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version ||
                     '" ALT="' || photo_name || '" STYLE="display:block;">',cattributes=>'align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '" height="' || to_char(oth + nvl(pfx.tnail_width,0)) || '"' ));
       end if;
     end if;

   elsif style = 'IMAGE'
    then
     if umorec.photo_master.width > umorec.photo_master.height
      then
         return(  '<IMG BORDER=0 WIDTH=' || to_char(dspv) || usemap || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version ||
                     '" ALT="' || photo_name || '" STYLE="display:block;">');
      else
         return( '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || usemap || ' SRC="' ||
                     'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version ||
                     '" ALT="' || photo_name || '" STYLE="display:block;">');
     end if;

   elsif style = 'SOURCE'
    then
     if umorec.photo_master.width > umorec.photo_master.height
      then
         return(  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version );
      else
         return( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version );
     end if;

   elsif style = 'NAME'
    then
     return( umorec.extras.film_name );

   elsif style = 'BUTTON'
    then
      return( fimage_object(surl, ltype, cusrec, umorec, pfx, theme_rec, voidrec, footer_api, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, FALSE ));

   end if;

exception
 when others
  then return( sqlerrm );
end main_image;

function lightbox_headers(p1 in varchar2, acid in integer, ltype in varchar2 )
 return varchar2
as
 cursor c1(acid integer, ltype varchar2) is select nvl(name,LNG.PHG_TXT_042) name, lightid, is_default from lightbox_header where aid = acid and login_type = ltype order by name;
 retvar	varchar2(32767);
begin
 if ltype in ('CUSTOMER','PROFILEG') then return( NULL ); end if;
 for c1rec in c1(acid, ltype) loop
  if c1rec.is_default = 'T'
   then
    retvar := retvar || htf.formselectoption( c1rec.name, 'SELECTED', cattributes=>'VALUE="' || c1rec.lightid || '"' );
   else
    retvar := retvar || htf.formselectoption( c1rec.name, cattributes=>'VALUE="' || c1rec.lightid || '"' );
  end if;
 end loop;
 if retvar is null then return( NULL ); end if;
 return( '<font face="Arial,Helvetica" size=-2>' || htf.formselectopen( p1 ) || htf.formselectoption( LNG.PHG_TXT_042, cattributes=>'VALUE="' || NULL || '"' ) || retvar || htf.formselectclose || '</FONT>');
end lightbox_headers;

function default_eml( cusrec in customer_account%ROWTYPE, owner_id in integer, ltype in varchar2 )
 return varchar2
as

 cursor c3(acid integer, ltype varchar2) is select contact_email from customer_contact where aid=acid and login_type = ltype;
 cursor c4(phgid integer) is select contact_email from photographer where pid = phgid;
 cursor c5(sess_id integer) is select guest_email from login_session where sessid = sess_id;

 from_eml varchar2(1000);

begin

 if ltype = 'PHOTOGRAPHER'
  then
   open c4(cusrec.pid);
   fetch c4 into from_eml;
   close c4;

 elsif ltype in ('OWNER','PROFILE')
  then
   open c3(cusrec.aid,ltype);
   fetch c3 into from_eml;
   close c3;

 else
   open c5(owner_id);
   fetch c5 into from_eml;
   close c5;

 end if;

return( nvl( from_eml, glbx.extract_master_parameter('MAIL_FROM')) );

end default_eml;

procedure prompt_email_lightbox(surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in varchar2, acid in integer default null, lbox in varchar2, cusrec in customer_account%ROWTYPE, stype in integer, ltype in varchar2, owner_id in integer, lightid in integer )
as

 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 glbx.main_title( surl, LNG5.EXT_TXT_245, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C29',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,ispopup=>TRUE,stylesh=>pfx.stylesheet);
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'html_email.accept_email_lightbox' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'START_FROM', start_from );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'LBOX', lbox );
 htp.formhidden( 'LIGHTHDR', lightid );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG2.GCARD_TXT_007), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1', 30, 1000 ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG.CST_TXT_143), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P3', 30, 1000,  default_eml( cusrec, owner_id, ltype )), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG4.AHC_TXT_543), cattributes=>pfx.qbground || 'valign="TOP" ALIGN="LEFT"');
   htp.tabledata( htf.formtextarea( 'P2', 5, 30 ), cattributes=>pfx.qcbground || 'valign="TOP" ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_246 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_247 );
 htp.formclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'CST', 'PROMPT_EMAIL_LIGHTBOX',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end prompt_email_lightbox;

procedure initialise_control_buttons( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, cusloc in varchar2, dispvert in char, acid integer )
as
begin
 htp.formopen( 'cst.accept_display', ctarget=>cusloc );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'DISPLAY_DETAIL', dispvert );
 htp.formhidden( 'P0', '0' );
 htp.formhidden( 'P1', '0' );
 htp.formhidden( 'PA', '0' );
 htp.formhidden( 'PB', '0' );
 htp.formhidden( 'PC', '0' );
 htp.formhidden( 'PPN', '0' );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
exception when others then
 glbx.error_details( 'CST', 'INITIALISE_CONTROL_BUTTONS',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end initialise_control_buttons;

procedure control_buttons(surl in varchar2, sess_id integer, ltype in varchar2, title in varchar2, umrec in UMP.SEARCH_RESULT_PHG, cusrec in customer_account%ROWTYPE, left_api_parm in varchar2,
                          start_from in integer, search_total in integer, footer_api in varchar2, numb_photos in integer, lbox in varchar2, lboxall in varchar2,
                          theme_rec in theme_types%ROWTYPE, pfx in THEME%ROWTYPE, dispvert in varchar2 default 'T', acid in integer default null, control_style in varchar2, pbook in phg_price_book%ROWTYPE )
as
begin
  if pfx.tnail_control_style = 'Standard'
   then
    disp_by_scene_buttons_standard(surl, sess_id, ltype, title, umrec, cusrec, left_api_parm, start_from, search_total, footer_api, numb_photos, lbox, lboxall, theme_rec, pfx, dispvert, acid, FALSE, pbook);
  elsif pfx.tnail_control_style = 'Grouped Vertically'
   then
    disp_by_scene_buttons_standard(surl, sess_id, ltype, title, umrec, cusrec, left_api_parm, start_from, search_total, footer_api, numb_photos, lbox, lboxall, theme_rec, pfx, dispvert, acid, TRUE, pbook);
  elsif pfx.tnail_control_style = 'Grouped'
   then
    disp_by_scene_buttons_grouped(surl, sess_id, ltype, title, umrec, cusrec, left_api_parm, start_from, search_total, footer_api, numb_photos, lbox, lboxall, theme_rec, pfx, dispvert, acid, FALSE, pbook);
  elsif pfx.tnail_control_style = 'Grouped with Title'
   then
    disp_by_scene_buttons_grouped(surl, sess_id, ltype, title, umrec, cusrec, left_api_parm, start_from, search_total, footer_api, numb_photos, lbox, lboxall, theme_rec, pfx, dispvert, acid, TRUE, pbook);
  end if;
exception when others then
 glbx.error_details( 'CST', 'CONTROL_BUTTONS',vaid=>acid, errmsg=>sqlerrm, extdet=>'LEFT_API_PARM:' || left_api_parm);
end control_buttons;

function popup_size( stype in integer, umrec in umo%ROWTYPE, pfx in theme%ROWTYPE, display_original in varchar2 )
 return varchar2
as
 wd	integer;
 hg	integer;
begin
 if umrec.umo_type = 'PHOTO'
  then
   if display_original = LNG.PHG_TXT_045
    then
     wd := umrec.photo_master.width;
     hg := umrec.photo_master.height;
    else
     wd := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
     hg := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / umrec.photo_master.width) * umrec.photo_master.height;
   end if;
  else
   wd := 100;
   hg := 100;
 end if;

 return( 'height=' || to_char(nvl(hg,0) + pfx.fullimg_popup_height) || ',width=' || to_char(nvl(wd,0) + pfx.fullimg_popup_width) );
end popup_size;

procedure accept_display_mfctr( surl varchar2, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, pa in GLBX.MYARRAY, pb in GLBX.MYARRAY, pc in GLBX.MYARRAY, ppn in GLBX.MYARRAY,
                                left_api_parm in varchar2 default null, footer_api in varchar2, current_page_number in varchar2 default 1, display_detail in char  DEFAULT null,
                                add_to_trolley in varchar2 default null, display in varchar2 default null, modify_details in varchar2 default null, add_lightbox in varchar2 default null,
                                del_lightbox in varchar2 default null, empty_lightbox in varchar2 default null, acid in integer default null, lboxid in integer default null )
as

 cursor c1( phgid integer, pcode varchar2, vspb integer ) is
  select ppit.ppi
  from phg_price_book ppb, phg_price_item ppit
  where ppit.spb = ppb.spb and
        ppb.pid = phgid and
        ppb.spb = vspb and
        ppit.phg_code = pcode;

 np1		GLBX.MYARRAY;
 cusrec		customer_account%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 b2c_value	char(1);
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 sts		varchar2(100);
 profid		integer;

begin

 glbx.cookie_id( surl, stype, ltype, sess_id, sts, 'S', progcalled=>'CST.ACCEPT_DISPLAY_MFCTR' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 -- This Call uses the Photographer Code in the Price Book to Determine the PPI. It translates the Code into the PPI value before calling the API.
 cusrec := glbx.get_cusrec( sess_id, ltype, acid, profid );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));

 for j in p1.first..p1.last loop
  if nvl(p1(j),'0') = '0'
   then
    np1(j) := p1(j);
   else
    np1(j) := NULL;
    open c1(cusrec.pid, p1(j),voidrec.spb);
    fetch c1 into np1(j);
    close c1;
    np1(j) := 'S' || np1(j);
  end if;
 end loop;

 accept_display(surl, p0, np1, pa, pb, pc, ppn, left_api_parm, footer_api, current_page_number, display_detail, add_to_trolley, display, modify_details, add_lightbox, del_lightbox, empty_lightbox, acid, lboxid );

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_DISPLAY_MFCTR',vaid=>acid, errmsg=>sqlerrm, extdet=>'LEFT_API_PARM:' || left_api_parm);
end accept_display_mfctr;

procedure small_buttons( surl in varchar2, ltype in varchar2, cusrec in customer_account%ROWTYPE, umrec in umo%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, voidrec in order_style%ROWTYPE, footer_api in varchar2, left_api_parm in varchar2, lbox in varchar2, cusloc in varchar2, overdv in varchar2, ctr in integer, acid in integer, hor_but out varchar2, display_detail in char, display_original in varchar2, stype in integer default 1, extra_term in varchar2 default null)
as

 url			varchar2(1000);

begin
  -- Individual Customer Buttons
  if is_bf(theme_rec,ltype,180,183,'T','T',288,'T')
   then
    hor_but := NULL;
    --
    if footer_api = 'cst.disp_lightbox'
     then
      if pfx.fullimg_jscript_popup = 'T'
       then
        hor_but := hor_but || htf.anchor( 'javascript: window.open(''' ||'cst.lightbox_note?surl=' || surl || '&v_umo=' || umrec.umo_id || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || ctr || '&display_detail=' || overdv || '&acid=' || acid  || ''',''' || replace(LNG.PHG_TXT_178,' ','_') || ''',''' ||
                   'height=700,width=700,scrollbars=yes,resizable=yes'');void('''');',
                   htf.img( cust_button(pfx,'note.gif',6),cattributes=>'border=0',calt=>LNG5.EXT_TXT_093 ));
       else
        hor_but := hor_but || htf.anchor2( 'cst.lightbox_note?surl=' || surl || '&v_umo=' || umrec.umo_id || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || ctr || '&display_detail=' || overdv || '&acid=' || acid,htf.img( cust_button(pfx,'note.gif',6),cattributes=>'border=0',calt=>LNG5.EXT_TXT_093 ),ctarget=>'LIGHTBOX_NOTE');
      end if;
    end if;

    -- a button (Add to Basket)
    if is_bf(theme_rec,ltype,291,292,'T','T',293,'T')
     then
      hor_but := hor_but || htf.anchor(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec.umo_id || '&add_to_trolley=Order+Photos' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || overdv || '&acid=' || acid,htf.img( cust_button(pfx,'sml_a.gif',6),cattributes=>'border=0',calt=>lng.CST_TXT_065 ));
    end if;

    -- b button (Display Lightbox)
    if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and
        footer_api <> 'cst.disp_lightbox'
     then
      -- Check if aleady in lightbox - Attribute1 must be set by the search or list accordingly
      if umrec.attribute1 is null
       then
        hor_but := hor_but || htf.anchor2( 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec.umo_id || '&add_lightbox=TRUE' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || overdv || '&acid=' || acid,htf.img( cust_button(pfx,'sml_b.gif',6),cattributes=>'border=0',calt=>LNG4.AHC_TXT_379 || ' ' || lbox), ctarget=>cusloc );
       elsif umrec.attribute1 = '~'
        then
         hor_but := hor_but || htf.anchor2( 'cst.disp_lightbox?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=1&display_detail=' || display_detail || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || 'adminc/lbox.gif',cattributes=>'border=0',calt=>lbox), ctarget=>cusloc );
       else
         hor_but := hor_but || htf.anchor2( 'cst.disp_lightbox?surl=' || surl || '&left_api_parm=[LBOX:' || umrec.attribute1 || ']' || left_api_parm || '&start_from=1&display_detail=' || display_detail || '&acid=' || acid, htf.img( DECS.IMAGE_LOCATION || 'adminc/lbox.gif',cattributes=>'border=0',calt=>lbox), ctarget=>cusloc );
      end if;

     elsif
       -- We are in the lightbox
       is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and footer_api = 'cst.disp_lightbox'
     then
      hor_but := hor_but || htf.anchor2(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec.umo_id || '&del_lightbox=TRUE' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || overdv || '&acid=' || acid,htf.img( cust_button(pfx,'sml_b.gif',6),cattributes=>'border=0',calt=>LNG4.AHC_TXT_380 || ' ' ||  lbox), ctarget=>cusloc );
    end if;

    -- c button
    if voidrec.download_original_any_time = 'T'
     then
      -- Note: Relational Objects have no Download Capability
      if (umrec.umo_type = 'PHOTO' and nvl(umrec.photo_original.contentlength,0) > 0) or
         (umrec.umo_type = 'DOCUMENT' and nvl(umrec.doc_length,0) > 0) or
         (umrec.umo_type = 'VIDEO' and nvl(dbms_lob.getlength(umrec.video_original.source.localdata),0) > 0) or
         (umrec.umo_type = 'AUDIO' and nvl(dbms_lob.getlength(umrec.audio_original.source.localdata),0) > 0) or
         (umrec.umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(umrec.blueprint_obj.localdata),0) > 0)
      then
        hor_but := hor_but || htf.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec.umo_id || '&purchid=&mthod=ORIGINAL&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_157 ));
      elsif (umrec.ftp_virtual_dir || umrec.ftp_location) is not null
       then
        hor_but := hor_but || htf.anchor2( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec.umo_id || '&purchid=&mthod=FTP&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_157 ), ctarget=>'DOWNLOAD_WINDOW');
      end if;
    end if;

    if voidrec.download_web_any_time = 'T'
     then
      -- Note: Relational Objects have no Download Capability
      if (umrec.umo_type = 'PHOTO' and nvl(umrec.photo_master.contentlength,0) > 0) or
         (umrec.umo_type = 'DOCUMENT' and nvl(dbms_lob.getlength(umrec.doc_html),0) > 0) or
         (umrec.umo_type = 'AUDIO' and nvl(dbms_lob.getlength(umrec.audio_thumbnail.source.localdata),0) > 0) or
         (umrec.umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(umrec.blueprint_obj.online_version),0) > 0)
      then
        hor_but := hor_but || htf.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec.umo_id || '&purchid=&mthod=WEB&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 ));
      elsif (umrec.ftp_virtual_dir || umrec.ftp_location) is not null
       then
        hor_but := hor_but || htf.anchor2( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec.umo_id || '&purchid=&mthod=FTP&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 ), ctarget=>'DOWNLOAD_WINDOW');
      end if;
    end if;

    -- d button (Display Image)
    if pfx.fullimg_jscript_popup = 'T'
     then
      url :=  'cst.disp_acct_photo?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&photo_id=' || umrec.umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || overdv || '&how_display=' || pfx.fullimg_display_type || '&extra_term=' || replace(extra_term,' ','+');
      url := 'javascript: window.open(''' || url || ''',''' || replace(LNG.PHG_TXT_178,' ','_') || ''',''' || popup_size(stype,umrec,pfx,display_original) || ',scrollbars=yes,resizable=yes'');void('''');';
      url := htf.anchor(url,htf.img( cust_button(pfx,'sml_d.gif',6),cattributes=>'border=0',calt=>lng.PHG_TXT_178 ));
      hor_but := hor_but || url;
     else
      url :=  htf.anchor( 'cst.disp_acct_photo?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&photo_id=' || umrec.umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || overdv || '&extra_term=' || replace(extra_term,' ','+'),htf.img( cust_button(pfx,'sml_d.gif',6),cattributes=>'border=0',calt=>lng.PHG_TXT_178 ));
      hor_but := hor_but || url;
    end if;

    -- h button (API)
    if pfx.sml_button_api is not null
     then
      hor_but := hor_but || htf.anchor2( pfx.sml_button_api || '?surl=' || surl || '&loc_id=' || umrec.umo_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=1&display_detail=' || display_detail || '&acid=' || acid, htf.img( cust_button(pfx,'sml_h.gif',6),cattributes=>'border=0',calt=>pfx.sml_button_api_txt ), ctarget=>'W' || to_char(sysdate,'SSSSS') );
    end if;

    if (cusrec.can_edit_meta_data_values = 'T') and
       is_bf(theme_rec,ltype,90,91,'T','T',89,'T') and
       ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
     then
        hor_but := hor_but || htf.anchor2( 'cst.meta_edit?surl=' || surl || '&v_umo=' || umrec.umo_id || '&acid=' || acid || '&reterrors=',htf.img( cust_button(pfx,'sml_e.gif',6),cattributes=>'border=0',calt=>LNG3.ADM_TXT_938 ), ctarget=>'EDIT_META_DATA' || umrec.umo_id);
    end if;

    if umrec.umo_type = 'DOCUMENT' and dbms_lob.getlength(umrec.doc_html) > 0
     then
       hor_but := hor_but || htf.anchor2( 'cst.view_html?surl=' || surl || '&v_umo=' || umrec.umo_id || '&typ=HTML&acid=' || acid || '&sterm=' || replace(extra_term,' ','+'), htf.img( cust_button(pfx,'sml_f.gif',6),cattributes=>'border=0',calt=>LNG.CST_TXT_216 ), ctarget=>'HTML_VIEWER');
    end if;

    if umrec.umo_type = 'DOCUMENT' and dbms_lob.getlength(umrec.doc_gist) > 0
     then
       hor_but := hor_but || htf.anchor2( 'cst.view_html?surl=' || surl || '&v_umo=' || umrec.umo_id || '&typ=GIST&acid=' || acid || '&sterm=' || replace(extra_term,' ','+'), htf.img( cust_button(pfx,'sml_g.gif',6),cattributes=>'border=0',calt=>LNG3.ADM_TXT_619 ), ctarget=>'HTML_VIEWER');
    end if;

    hor_but := hor_but || htf.nl;

  else
    hor_but := NULL;
  end if;

exception when others then
 glbx.error_details( 'CST', 'SMALL_BUTTONS',vaid=>acid,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end small_buttons;

procedure image_object( surl in varchar2, ltype in varchar2, cusrec in customer_account%ROWTYPE, umrec in umo%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, voidrec in order_style%ROWTYPE, footer_api in varchar2, left_api_parm in varchar2, ctr in integer, acid in integer, display_detail in char, display_original in varchar2, stype in integer default 1, inhomepage in boolean default FALSE, extra_term in varchar2 default null)
as
begin
 htp.p( fimage_object(surl, ltype, cusrec, umrec, pfx, theme_rec, voidrec, footer_api, left_api_parm, ctr, acid, display_detail, display_original, stype, inhomepage, extra_term ));
end image_object;

function fimage_object( surl in varchar2, ltype in varchar2, cusrec in customer_account%ROWTYPE, umrec in umo%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, voidrec in order_style%ROWTYPE, footer_api in varchar2, left_api_parm in varchar2, ctr in integer, acid in integer, display_detail in char, display_original in varchar2, stype in integer default 1, inhomepage in boolean default FALSE, extra_term in varchar2 default null)
return varchar2
as

 lbox		varchar2(1000);
 ctarg		varchar2(100);
 cattr		varchar2(1000);
 jscript_open	varchar2(1000);
 jscript_close	varchar2(1000);
 jscript_open1	varchar2(1000);
 jscript_close1	varchar2(1000);
 retxt		varchar2(32767);

begin

 lbox := glbx.userpref(cusrec.pid,cusrec.aid,'LIGHTBOX');

 if not inhomepage
  then
   if ltype = 'PHOTOGRAPHER'
    then
     ctarg := 'PHG_RIGHT';
    else
     if pfx.keep_lhf = 'N'
      then
       ctarg := '_top';
      elsif pfx.keep_lhf = '2'
       then
        ctarg := 'CUS_BOTTOM';
      else
        ctarg := 'CUS_RIGHT';
     end if;
   end if;
 end if;

 jscript_open1 := NULL;
 jscript_close1 := NULL;
 if pfx.fullimg_jscript_popup = 'T' and not inhomepage
  then
   if pfx.keep_lhf = 'N' and ltype not in ('PHOTOGRAPHER') -- If no-frame, redisplay in the current screen which is a pop-up.
    then
     cattr := NULL;
     jscript_open := NULL;
     jscript_close := NULL;
     -- xxx review this
     --jscript_open1 := 'javascript: parent.opener.location = '''; -- Used for shopping basket
     --jscript_close1 := '''; parent.close();';
    else
     cattr := 'onsubmit="javascript: parent.close();"';
     jscript_open := 'javascript: parent.opener.location = ''';
     jscript_close := '''; parent.close();';
   end if;
  else
   cattr := NULL;
   jscript_open := NULL;
   jscript_close := NULL;
 end if;

-- Shopping Basket always returns back to main window
if pfx.fullimg_jscript_popup = 'T'
 then
     jscript_open1 := 'javascript: parent.opener.location = ''';
     jscript_close1 := '''; parent.close();';
end if;

retxt := NULL;
retxt := retxt || htf.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
 retxt := retxt || htf.tablerowopen;
  retxt := retxt || '<TD VALIGN="TOP" ALIGN="CENTER" STYLE="vertical-align: top; text-align: center;">';

  if is_bf(theme_rec,ltype,180,183,'T','T',288,'T')
   then
    --
    if footer_api = 'cst.disp_lightbox'
     then
     retxt := retxt || htf.anchor2( 'cst.lightbox_note?surl=' || surl || '&v_umo=' || umrec.umo_id || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || ctr || '&display_detail=' || display_detail || '&acid=' || acid, htf.img( cust_button(pfx,'note.gif',6),cattributes=>'border=0',calt=>LNG5.EXT_TXT_093 ),ctarget=>'LIGHTBOX_NOTE');
    end if;

    -- a button (Add to Basket)
    if is_bf(theme_rec,ltype,241,242,'T','T',293,'T')
     then
      retxt := retxt || htf.anchor( jscript_open1 || 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec.umo_id || '&add_to_trolley=Order+Photos' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || display_detail || '&acid=' || acid || jscript_close1, htf.img( cust_button(pfx,'sml_a.gif',6),cattributes=>'border=0',calt=>lng.CST_TXT_065 ));
    end if;

    -- b button (Display Lightbox)
    if is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and
        footer_api <> 'cst.disp_lightbox'
     then
      -- Check if aleady in lightbox - Attribute1 must be set by the search or list accordingly
      if umrec.attribute1 is null
       then
        retxt := retxt || htf.anchor( jscript_open || 'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec.umo_id || '&add_lightbox=TRUE' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || display_detail || '&acid=' || acid || jscript_close,htf.img( cust_button(pfx,'sml_b.gif',6),cattributes=>'border=0',calt=>LNG4.AHC_TXT_379 || ' ' || lbox) );
       elsif umrec.attribute1 = '~'
        then
         retxt := retxt || htf.anchor( jscript_open || 'cst.disp_lightbox?surl=' || surl || '&left_api_parm=' || left_api_parm || '&start_from=1&display_detail=' || display_detail || '&acid=' || acid || jscript_close, htf.img( DECS.IMAGE_LOCATION || 'adminc/lbox.gif',cattributes=>'border=0',calt=>lbox) );
       else
         retxt := retxt || htf.anchor( jscript_open || 'cst.disp_lightbox?surl=' || surl || '&left_api_parm=[LBOX:' || umrec.attribute1 || ']' || left_api_parm || '&start_from=1&display_detail=' || display_detail || '&acid=' || acid || jscript_close, htf.img( DECS.IMAGE_LOCATION || 'adminc/lbox.gif',cattributes=>'border=0',calt=>lbox) );
      end if;

     elsif
       -- We are in the lightbox
       is_bf(theme_rec,ltype,182,185,'T','T',269,'T') and footer_api = 'cst.disp_lightbox'
     then
      htp.anchor2(  'cst.accept_display?surl=' || glbx.rndsurl(surl) || '&p0=0&p1=0&pa=0&pb=0&pc=0&ppn=&p1=' || umrec.umo_id || '&del_lightbox=TRUE' || '&footer_api=' || footer_api || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || ctr || '&display_detail=' || display_detail || '&acid=' || acid,htf.img( cust_button(pfx,'sml_b.gif',6),cattributes=>'border=0',calt=>LNG4.AHC_TXT_380 || ' ' ||  lbox) );
    end if;

    -- c button
    if voidrec.download_original_any_time = 'T'
     then
      -- Note: Relational Objects have no Download Capability
      if (umrec.umo_type = 'PHOTO' and nvl(umrec.photo_original.contentlength,0) > 0) or
         (umrec.umo_type = 'DOCUMENT' and nvl(umrec.doc_length,0) > 0) or
         (umrec.umo_type = 'VIDEO' and nvl(dbms_lob.getlength(umrec.video_original.source.localdata),0) > 0) or
         (umrec.umo_type = 'AUDIO' and nvl(dbms_lob.getlength(umrec.audio_original.source.localdata),0) > 0) or
         (umrec.umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(umrec.blueprint_obj.localdata),0) > 0)
      then
        retxt := retxt || htf.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec.umo_id || '&purchid=&mthod=ORIGINAL&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_157 ));
      elsif (umrec.ftp_virtual_dir || umrec.ftp_location) is not null
       then
        retxt := retxt || htf.anchor2( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec.umo_id || '&purchid=&mthod=FTP&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_157 ), ctarget=>'DOWNLOAD_WINDOW');
      end if;
    end if;

    if voidrec.download_web_any_time = 'T'
     then
      -- Note: Relational Objects have no Download Capability
      if (umrec.umo_type = 'PHOTO' and nvl(umrec.photo_master.contentlength,0) > 0) or
         (umrec.umo_type = 'DOCUMENT' and nvl(dbms_lob.getlength(umrec.doc_html),0) > 0) or
         (umrec.umo_type = 'AUDIO' and nvl(dbms_lob.getlength(umrec.audio_thumbnail.source.localdata),0) > 0) or
         (umrec.umo_type = 'BLUEPRINT' and nvl(dbms_lob.getlength(umrec.blueprint_obj.online_version),0) > 0)
      then
        retxt := retxt || htf.anchor( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec.umo_id || '&purchid=&mthod=WEB&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 ));
      elsif (umrec.ftp_virtual_dir || umrec.ftp_location) is not null
       then
        retxt := retxt || htf.anchor2( 'fname.download_file?surl=' || surl || '&v_umo=' || umrec.umo_id || '&purchid=&mthod=FTP&acid=' || acid,htf.img( DECS.IMAGE_LOCATION || 'adminc/sml_c.gif',cattributes=>'border=0',calt=>LNG.ORD_TXT_165 ), ctarget=>'DOWNLOAD_WINDOW');
      end if;
    end if;

    if (cusrec.can_edit_meta_data_values = 'T') and
       is_bf(theme_rec,ltype,90,91,'T','T',89,'T') and
       ltype in ('PHOTOGRAPHER','OWNER','PROFILE')
     then
       retxt := retxt || htf.anchor( 'cst.meta_edit?surl=' || surl || '&v_umo=' || umrec.umo_id || '&acid=' || acid || '&reterrors=', htf.img( cust_button(pfx,'sml_e.gif',6),cattributes=>'border=0',calt=>LNG3.ADM_TXT_938 ));
    end if;

    if umrec.umo_type = 'DOCUMENT' and dbms_lob.getlength(umrec.doc_html) > 0
     then
       retxt := retxt || htf.anchor2( 'cst.view_html?surl=' || surl || '&v_umo=' || umrec.umo_id || '&typ=HTML&acid=' || acid || '&sterm=' || replace(extra_term,' ','+'), htf.img( cust_button(pfx,'sml_f.gif',6),cattributes=>'border=0',calt=>LNG.CST_TXT_216 ), ctarget=>'HTML_VIEWER');
    end if;

    if umrec.umo_type = 'DOCUMENT' and dbms_lob.getlength(umrec.doc_gist) > 0
     then
       retxt := retxt || htf.anchor2( 'cst.view_html?surl=' || surl || '&v_umo=' || umrec.umo_id || '&typ=GIST&acid=' || acid || '&sterm=' || replace(extra_term,' ','+'), htf.img( cust_button(pfx,'sml_g.gif',6),cattributes=>'border=0',calt=>LNG3.ADM_TXT_619 ), ctarget=>'HTML_VIEWER');
    end if;

   -- Return to Previous Screen
   if not inhomepage
    then
     if is_bf(theme_rec,ltype,245,246,'T','T')
      then
       if pfx.fullimg_jscript_popup = 'F'
        then
         retxt := retxt || htf.anchor( footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || ctr || '&display_detail=' || display_detail,
                     htf.img( cust_button(pfx,'return.gif',3),cattributes=>'border=0',calt=>lng.CST_ALT_028 || ':' || umrec.extras.title ));
        else
         retxt := retxt || htf.anchor( 'javascript:self.close()',
                     htf.img( cust_button(pfx,'return.gif',3),cattributes=>'border=0',calt=>lng.CST_ALT_028 || ':' || umrec.extras.title ));
       end if;
     end if;
   end if;

  end if;
  retxt := retxt || '</TD>';
  retxt := retxt || '<TD VALIGN="BOTTOM" ALIGN="CENTER" STYLE="vertical-align: bottom; text-align: center;">';

  if nvl(cusrec.enable_novelties,'F') = 'T'
   then

   if pfx.fullimg_novelty = 'L' -- Lov
    then
     retxt := retxt || htf.formopen( 'cst.call_novelty', ctarget=>ctarg, cattributes=>cattr);

     if pfx.scene_position = 'L' and pfx.keep_lhf in ('L','R')
      then
       retxt := retxt || htf.formselectopen( 'P1' );
      elsif pfx.scene_position = 'T' and pfx.keep_lhf = '2'
       then
        retxt := retxt || htf.formselectopen( 'P1' );
      elsif pfx.scene_position = 'T' and pfx.keep_lhf = 'N' and ltype = 'PHOTOGRAPHER'
       then
        retxt := retxt || htf.formselectopen( 'P1' );
      elsif pfx.scene_position = 'T' and pfx.keep_lhf = 'N'
       then
        retxt := retxt || htf.formselectopen( 'P1' );
      else
       retxt := retxt || htf.formselectopen( 'P1' );
     end if;
     retxt := retxt || glbx.novelty_option( surl, pfx, footer_api, left_api_parm,  1, display_detail, cusrec, ltype, 'MAIN', 'LOV', umrec.umo_id );
     retxt := retxt || htf.formselectclose;
     retxt := retxt || '&nbsp;';
     -- retxt := retxt || htf.formsubmit( null, 'Run Novelty' );
     retxt := retxt || htf.formimage( 'Run_Novelty', DECS.IMAGE_LOCATION || 'adminc/run_novelty.gif',cattributes=>'BORDER="0"');
     retxt := retxt || htf.formclose;

   elsif pfx.fullimg_novelty = 'B'
    then
     retxt := retxt || htf.tableopen( cattributes=>'cellpadding=0 cellsapcing=0 border=0' ) ||
              htf.tablerowopen ||
              glbx.novelty_option( surl, pfx, footer_api, left_api_parm,  1, display_detail, cusrec, ltype, 'MAIN', 'HOR_TABLE', umrec.umo_id ) ||
              htf.tablerowclose ||
              htf.tableclose;

   end if;

  end if;

 retxt := retxt || '</TD>';
 retxt := retxt || htf.tablerowclose;
 retxt := retxt || htf.tableclose;
 return( retxt );
exception when others then
 glbx.error_details( 'CST', 'FIMAGE_OBJECT',vaid=>acid,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
 return( 'FIMAGE:' || sqlerrm );
end fimage_object;

procedure call_novelty( p1 in varchar2, run_novelty in varchar2 default null )
as
begin
 -- insert into temp values ('http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || p1); commit;
 owa_util.redirect_url( 'http://' || owa_util.get_cgi_env( 'SERVER_NAME' ) || ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || owa_util.get_cgi_env('SCRIPT_NAME') || '/' || p1 );
end call_novelty;

procedure view_html( surl in varchar2, typ in varchar2, v_umo in integer, acid in integer, sterm in varchar2 default null)
as

 cursor c2(v_umo integer, acid integer) is select * from umo um where umo_id = v_umo and aid = acid and umo_type = 'DOCUMENT';

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 clb		clob;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 c_imgchunk 	integer;
 v_imgchunk	integer;
 v_count	integer;
 c_buffer	varchar2(32767);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts , 'S', progcalled=>'CST.VIEW_HTML');
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 c1rec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( c1rec.theme_name );
 theme_rec := glbx.get_theme_types(c1rec.theme_type );
 open c2(v_umo,c1rec.aid);
 fetch c2 into c2rec;
 close c2;
 if c2rec.umo_id is null then htp.p('Invalid Access'); return; end if;

 if typ = 'HTML' then clb := c2rec.doc_html; end if;
 if typ = 'GIST' then clb := c2rec.doc_gist; end if;

 if dbms_lob.getlength(clb) = 0 then htp.p('Invalid Access'); return; end if;

 c_imgchunk := 25000; -- Leave room for marking up documents
 v_imgchunk := 25000;
 v_count := 0;

 owa_util.mime_header('text/html');
 begin
  loop
   dbms_lob.read(clb,v_imgchunk,(v_count*c_imgchunk)+1,c_buffer);
   v_count := v_count + 1;
   if sterm is not null
    then
     c_buffer := replace(c_buffer, lower(sterm), htf.bold(lower(sterm)));
     c_buffer := replace(c_buffer, upper(sterm), htf.bold(upper(sterm)));
     c_buffer := replace(c_buffer, initcap(sterm), htf.bold(initcap(sterm)));
     htp.prn( c_buffer );
    else
     htp.prn( c_buffer );
   end if;
  end loop;
  exception
   when no_data_found then null;
   when others
    then glbx.error_details( 'CST', 'VIEW_HTML',errmsg=>sqlerrm,extdet=>'Error Occurred in Program Subloop: V_COUNT:' || v_count);
 end;

exception when others then
 glbx.error_details( 'CST', 'VIEW_HTML',vaid=>acid,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype);
end view_html;

procedure category_search( surl in varchar2, stype in integer, ltype in varchar2, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, p1 in varchar2 )
as

 cursor c1( phgid integer, scnm varchar2, ctg varchar2 ) is
  select umo_scene_id, title
  from umo_scene
  where category = scnm and
        ((owned_by = 'PUBLIC') or (owned_by = 'PHOTOGRAPHER' and owner_id = phgid)) and
        upper(title) like '%' || upper(ctg) || '%'
  order by order_by,upper(title);

 pfx		THEME%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;

begin

 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 pfx := glbx.get_thm( cusrec.theme_name );
 glbx.main_title( surl, 'Search Results',glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,sim_three_frame=>pfx.sim_three_frame,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );

 htp.bold( 'Search for Categories' || ':' || p1 );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 for c1rec in c1( cusrec.pid, cusrec.scene_name, p1 ) loop
  htp.tablerowopen;
  htp.p( '<TD>' );
  if ltype = 'PHOTOGRAPHER'
   then
    htp.anchor( 'phg.phg_disp_by_scene_fm?surl=' || surl || '&acid=' || acid || '&scnm=' || c1rec.umo_scene_id, c1rec.title );
   else
    htp.anchor( 'cst.disp_category?surl=' || surl || '&left_api_parm=' || c1rec.umo_scene_id || '&start_from=1', c1rec.title );
  end if;
  htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;

 disp_standard_search(surl, stype, ltype, profid, acid, cusrec, pfx, theme_rec, pfx.search_style_simple );

 htp.p( '</CENTER>' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'CATEGORY_SEARCH',vaid=>acid,errmsg=>sqlerrm,extdet=>'LTYPE:' || ltype || ' P1:' || p1);
end category_search;

function packaged_product_check( callloc in varchar2, vpoid in integer, pbook in phg_price_book%ROWTYPE, ltype in varchar2 )
 return boolean
as
 cursor c2( vpoid integer ) is select count('x') cnt from shopping_basket where poid = vpoid and isgallery = 'P';
 c2rec  c2%ROWTYPE;
begin
 if pbook.call_location = 'N' or ltype = 'PHOTOGRAPHER' then return( FALSE ); end if;

 if callloc = 'CAT'
  then
   if pbook.call_location in ('1','4','6','7') then null; else return( FALSE ); end if;
 elsif callloc = 'PACK'
  then
   if pbook.call_location in ('2','4','5','7') then null; else return( FALSE ); end if;
 elsif callloc = 'BASKET'
  then
   if pbook.call_location in ('3','5','6','7') then null; else return( FALSE ); end if;
 end if;

 --
 -- At this point there is a package requested, but nothing in the basket for it
 --
 open c2( vpoid );
 fetch c2 into c2rec;
 close c2;
 if c2rec.cnt = 0 then return( TRUE ); end if;

 return( FALSE );

exception when others then
 glbx.error_details( 'CST', 'PACKAGED_PRODUCT_CHECK',errmsg=>sqlerrm,extdet=>'VPOID:' || vpoid || ' CALLLOC:' || callloc); return( FALSE );
end packaged_product_check;

procedure packprod(surl in varchar2, ltype in varchar2, stype in integer, sess_id in integer, profid in integer, acid in integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE, purchord in purchase_order%ROWTYPE, voidrec in order_style%ROWTYPE, left_api in varchar2, left_api_parm in varchar2, msg in varchar2 default null)
as

 cursor c1(vspb integer) is select * from phg_price_item where spb = vspb and shop_item = 'P' and enabled = 'T' order by decode(is_default,'T',1,2),ppi;
 cursor c1a(vspb integer) is select count('x') cnt from phg_price_item where spb = vspb and shop_item = 'P' and enabled = 'T' and is_default = 'T';
 cursor c2( v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c6(vspb integer) is select * from phg_price_book where spb = vspb;

 c2rec			c2%ROWTYPE;
 c6rec			c6%ROWTYPE;
 jctr 			integer;
 tot			integer;
 video_api		varchar2(1000);
 audio_api		varchar2(1000);
 relational_api		varchar2(1000);
 blueprint_api		varchar2(1000);
 document_api		varchar2(1000);
 upref			varchar2(100);
 newdt			number;
 is_local		boolean;
 phg_title		varchar2(100);
 display_original	varchar2(100);
 image_style		varchar2(100);

begin
 -- Assume main_title already called
 -- List all packed products for customer to choose one
 initialise_api_variables(surl, sess_id, ltype, 421, null, 420, cusrec, theme_rec, document_api, video_api, audio_api, relational_api, blueprint_api, upref, newdt, is_local, display_original, phg_title );
 image_style := get_image_style( sess_id );

 glbx.instruction( 'Choose a Packaged Product from the List Below', pfx );
 if msg is not null then glbx.instruction( msg, pfx ); end if;

 htp.formopen( 'cst.accept_packprod' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'LEFT_API', left_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );

 jctr := 1;
 tot := 0;
 open c6(voidrec.spb);
 fetch c6 into c6rec;
 close c6;
 open c1a(voidrec.spb);
 fetch c1a into tot;
 close c1a;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=3 border=0 ' );
  for c1rec in c1(voidrec.spb) loop
   if jctr = 1
    then
     htp.tablerowopen;
    elsif mod(jctr, glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype)) = 1
     then
      htp.tablerowclose;
      htp.tablerowopen;
   end if;
   jctr := jctr + 1;

   htp.p( '<TD>' );
   if c1rec.umo_id is not null
    then
     open c2(c1rec.umo_id);
     fetch c2 into c2rec;
     close c2;
     display_thumbnail(surl,ltype,c2rec,theme_rec,pfx,null,left_api_parm,jctr,null,c1rec.name,document_api,video_api,audio_api,relational_api,blueprint_api,acid,display_original,stype,null,image_style);
   end if;
   htp.nl;
   if c1rec.is_default = 'T' or (tot = 0 and jctr = 2) -- Must pick a default
    then
     htp.formradio( 'P1', c1rec.ppi, 'CHECKED' );
    else
     htp.formradio( 'P1', c1rec.ppi );
   end if;
   htp.p( ' ' || c1rec.name );
   htp.p( '</TD>' );
  end loop;
 htp.tableclose;
 htp.nl;
 --htp.p( '<BUTTON NAME="ACTION" TYPE="submit" TABINDEX="2" VALUE="Return">Return</BUTTON>' );
 --htp.p( '<BUTTON NAME="ACTION" TYPE="submit" TABINDEX="1" VALUE="Choose Packaged Product">Choose Packaged Product</BUTTON>' );
 htp.formsubmit( 'ACTION', 'Return' );
 htp.formsubmit( 'ACTION', 'Choose Packaged Product' );
 htp.formclose;
 htp.nl;

 if c6rec.call_location in ('2')
  then
   htp.nl;
   htp.nl;
   htp.bold( 'OR' );
   htp.nl;
   htp.nl;
   htp.anchor( 'cst.packprod_individual?surl=' || surl || '&left_api=' || replace(left_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&acid=' || acid, 'Individually' );
 end if;

 htp.p( '</CENTER>' );
 glbx.close_page( pfx );
exception when others then
 glbx.error_details( 'CST', 'PACKPROD',errmsg=>sqlerrm);
end packprod;

procedure packprod_individual( surl in varchar2, left_api_parm in varchar2, left_api in varchar2, acid in integer )
as
begin
 fname.acct_orders(surl,left_api=>left_api, left_api_parm=>left_api_parm, acid=>acid );
end packprod_individual;

procedure accept_packprod( surl in varchar2, left_api_parm in varchar2, left_api in varchar2, p1 in varchar2, action in varchar2, acid in integer )
as

 cursor c3( vspb integer, vppi integer ) is select * from item_package_product where spb = vspb and ppi = vppi;
 cursor c4( vshopid integer ) is select * from shopping_basket where shopping_id = vshopid;
 cursor c5( vppi integer ) is select * from phg_price_item where ppi = vppi;
 cursor c5a( vpoid integer) is select * from shopping_basket where poid = vpoid order by shopping_id desc;
 cursor c6( vspb integer) is select * from phg_price_book where spb = vspb;
 cursor c7( vpoid integer, vshopid integer ) is select * from purchase_package_product where poid = vpoid and shopping_id = vshopid;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 theme_rec 	theme_types%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 sts		varchar2(100);
 profid		integer;
 quick_exit	boolean;
 b2c_value	char(1);
 nmb		integer;
 dummy		GLBX.MYARRAY;
 vp1		GLBX.MYARRAY;
 vpc		GLBX.MYARRAY;

begin
 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'CST.ACCEPT_PACKPROD' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 -- add to shopping basket
 quick_exit := FALSE;
 glbx.get_all_order_details(sess_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec );
   -- Update the Shopping Basket
   -- DUMMY - Shopping Id
   -- P1 - New Choice (PPIT Id or UMO_ID)
   -- DUMMY - Quantity (defaults to min_qty or 1)
   -- PC - Before Choice Value (PPIT Id or UMO_ID) same as P1, except it contains all values on the screen or
   --    - [F24590]2839 if customer can prechoose price book item
 vp1(1) := '0';
 vpc(1) := '0';
 vp1(2) := p1;
 vpc(2) := 'IR[' || p1 || ']' || p1;

 -- Add the Package to the Shopping Basket
 fname.process_purchase_order(surl, sess_id, profid, ltype, acid, 'INSERT', voidrec, c1rec, vp1, dummy, vpc, dummy, quick_exit );

 --
 -- If callloc = '2' then add all items in the basket to the package, until we encounter another package
 --
 open c6(voidrec.spb);
 fetch c6 into c6rec;
 close c6;
 -- This option is only available for call #2 xxx (maybe other call values can be added here)
 if c6rec.call_location in ('2')
  then
   nmb := NULL;
   for c5arec in c5a( purchord.poid ) loop
    if c5a%ROWCOUNT = 1 and c5arec.isgallery = 'P'
     then
      nmb := c5arec.shopping_id;
      open c4(nmb);
      fetch c4 into c4rec;
      close c4;
      open c5(c4rec.ppi);
      fetch c5 into c5rec;
      close c5;
      open c3( c5rec.spb, c5rec.ppi );
      fetch c3 into c3rec;
      close c3;
     else
      if c5a%ROWCOUNT > 1 and c5arec.isgallery in ('P','Q') then exit; end if;
      if c5arec.packaged_product_id is null
       then
        if attach_package_item( nmb, purchord, c3rec, c5rec, c5arec ) then null; end if;
      end if;
    end if;
   end loop;
   commit;
   packprod_edit( surl, left_api_parm, 1, null, acid, nmb );
   return;
 end if;

 begin
  nmb := to_number(left_api_parm);
  disp_category(surl, left_api_parm, display_detail=>NULL, acid=>acid );
 exception
  when others then
   glbx.acct_home(surl);
 end;
 -- Now Display listing of thumbnails (if search - unsure what to do)
exception when others then
 glbx.error_details( 'CST', 'ACCEPT_PACKPROD',errmsg=>sqlerrm);
end accept_packprod;

procedure packprod_hdr( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer )
as

 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		theme%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 purchord	purchase_order%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'CST.PACKPROD_HDR' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec );
 glbx.main_title( surl, null,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 packprod(surl,ltype,stype,sess_id,profid,acid,c1rec,pfx,theme_rec,purchord,voidrec,null,left_api_parm);

exception when others then
 glbx.error_details( 'CST', 'PACKPROD_HDR',errmsg=>sqlerrm);
end packprod_hdr;

procedure packprod_edit( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, pkg in integer default null )
as

 cursor c2( vpoid integer ) is select * from shopping_basket where poid = vpoid and isgallery = 'P' order by shopping_id;
 cursor c3( vpkg integer, vpoid integer ) is select * from shopping_basket where poid = vpoid and shopping_id = vpkg;
 cursor c4( vppi integer ) is select * from item_package_product where ppi = vppi;
 cursor c5( vpoid integer, vshp integer ) is
  select sb.photo_size, sb.shopping_id, sb.ppi,sb.film_name
  from shopping_basket sb
  where sb.poid = vpoid and
        sb.packaged_product_id = vshp;
 cursor c6( vpoid integer ) is select * from shopping_basket where poid = vpoid and packaged_product_id is null and isgallery <> 'P' order by shopping_id;
 cursor c7( v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c8(vppi integer) is select * from phg_price_item where ppi = vppi;
 cursor c9(vspb integer) is select * from phg_price_book where spb = vspb;
 cursor c10( vpoid integer, pkg integer ) is select * from shopping_basket where poid = vpoid and packaged_product_id = pkg order by shopping_id;
 cursor c11( vpoid integer, pkg integer ) is select count('x') cnt from shopping_basket where poid = vpoid and packaged_product_id = pkg;

 c1rec			customer_account%ROWTYPE;
 c3rec			c3%ROWTYPE;
 c4rec			c4%ROWTYPE;
 umorec			c7%ROWTYPE;
 c8rec			c8%ROWTYPE;
 c9rec			c9%ROWTYPE;
 ltype			varchar2(100);
 stype			integer;
 sess_id		integer;
 profid			integer;
 tot			integer;
 sts			varchar2(100);
 pfx			theme%ROWTYPE;
 theme_rec		theme_types%ROWTYPE;
 voidrec		order_style%ROWTYPE;
 purchord		purchase_order%ROWTYPE;
 video_api		varchar2(1000);
 audio_api		varchar2(1000);
 relational_api		varchar2(1000);
 blueprint_api		varchar2(1000);
 document_api		varchar2(1000);
 upref			varchar2(100);
 newdt			number;
 is_local		boolean;
 checkout		boolean;
 ord_exists		boolean;
 phg_title		varchar2(100);
 display_original	varchar2(100);
 image_style		varchar2(100);
 newline		boolean;
 grand_ttl		number;
 retlink		varchar2(1000);

begin

 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'CST.PACKPROD_HDR' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec );

 if pkg is null
  then
   open c2( purchord.poid );
   fetch c2 into c3rec;
   close c2;
  else
   open c3( pkg, purchord.poid );
   fetch c3 into c3rec;
   close c3;
 end if;

 open c4( c3rec.ppi );
 fetch c4 into c4rec;
 close c4;

 glbx.main_title( surl, 'Edit Package Basket',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'C33',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER> ' );
 htp.nl;
 initialise_api_variables(surl, sess_id, ltype, 421, null, 420, c1rec, theme_rec, document_api, video_api, audio_api, relational_api, blueprint_api, upref, newdt, is_local, display_original, phg_title );
 image_style := get_image_style( sess_id );
 open c8(c3rec.ppi);
 fetch c8 into c8rec;
 close c8;
 open c9(c8rec.spb);
 fetch c9 into c9rec;
 close c9;
 if c8rec.umo_id is not null
  then
   open c7( c8rec.umo_id );
   fetch c7 into umorec;
   close c7;
   display_thumbnail(surl,ltype,umorec,theme_rec,pfx,null,left_api_parm,1,null,c3rec.film_name,document_api,video_api,audio_api,relational_api,blueprint_api,acid,display_original,stype,null,image_style);
   htp.nl;
   htp.bold(c9rec.package_help);
   htp.nl;
  else
   htp.bold( c8rec.name );
   htp.nl;
   htp.bold(c9rec.package_help);
   htp.nl;
 end if;
 htp.nl;
 htp.formopen( 'cst.accept_packprod_edit_basket' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'PKG', pkg );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'START_FROM', start_from );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 htp.formhidden( 'P0','0' ); -- Dummy values required for array
 htp.formhidden( 'P1','0' ); -- Dummy values required for array
 htp.formhidden( 'P2','0' ); -- Dummy values required for array
 htp.formhidden( 'P3','0' ); -- Dummy values required for array
 htp.formhidden( 'P6','0' ); -- Dummy values required for array

 open c11( purchord.poid, pkg );
 fetch c11 into tot;
 close c11;

 --htp.bold( '[Debug]Number in Package Basket: ' || tot );
 --htp.nl;
 --htp.bold( '[Debug]Min Number:' || c4rec.min_number );
 --htp.nl;
 --htp.bold( '[Debug]Max Number:' || c4rec.max_number );
 --htp.nl;
 --htp.bold( '[Debug]Items included in Price:' || c4rec.images_included_in_price );
 --htp.nl;
 --htp.bold( '[Debug]Price:' || c8rec.charge );
 --htp.nl;
 --htp.nl;
 if tot < c4rec.min_number
  then
   htp.bold( 'There are only ' || tot || ' items in the Package Cart. You will need to add more to reach the minimum of ' || c4rec.min_number );
   checkout := FALSE;
 elsif tot > c4rec.max_number
  then
   htp.bold( 'There are ' || tot || ' items in the Package Cart.' );
   if c4rec.min_number = c4rec.max_number
    then
     htp.bold( ' ' || 'Only ' || c4rec.max_number || ' are allowed. Please remove image(s) from the Package Cart.' );
    else
     htp.bold( ' ' || 'Between ' || c4rec.min_number || ' and ' || c4rec.max_number || ' images are allowed. Please remove image(s) from the Package Cart.' );
   end if;
   checkout := FALSE;
  else
   htp.bold( 'You have the required number of items in the Package Cart.' );
   checkout := TRUE;
  end if;

 newline := FALSE;
 fname.show_customer_order( surl, c1rec, theme_rec, voidrec, sess_id, stype, ltype, pfx, acid, 'EDIT', ord_exists, grand_ttl, newline, retlink=>retlink, pkg=>pkg, disable_show_total=>TRUE, show_package_items=>TRUE );

 htp.nl;
 if tot <= c4rec.max_number then htp.formsubmit( 'ACTION', 'Add More Items' ); end if;
 htp.formsubmit( 'ACTION', 'Recalculate' );
 if checkout then htp.formsubmit( 'ACTION', 'Confirm' ); end if;
 htp.formclose;

 /* This was the transfer method: Maybe add it in as an option in a later release (shame to lose the interface)
 htp.formopen( 'cst.accept_packprod_edit' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'PKG', c3rec.shopping_id );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'START_FROM', start_from );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.p( '<TD>' );
    htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
     -- Column 1: Items in Package
     htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
      htp.bold( 'Items in Package' );
      htp.nl;
      htp.nl;
      htp.nl;
      htp.p( '1.' || c4rec.instruction_1 );
      if c4rec.max_number > 1 then htp.nl; htp.p( '2.' || c4rec.instruction_2 ); end if;
      if c4rec.max_number > 2 then htp.nl; htp.p( '3.' || c4rec.instruction_3 ); end if;
      if c4rec.max_number > 3 then htp.nl; htp.p( '4.' || c4rec.instruction_4 ); end if;
      if c4rec.max_number > 4 then htp.nl; htp.p( '5.' || c4rec.instruction_5 ); end if;
      if c4rec.max_number > 5 then htp.nl; htp.p( '6.' || c4rec.instruction_6 ); end if;
      if c4rec.max_number > 6 then htp.nl; htp.p( '7.' || c4rec.instruction_7 ); end if;
      if c4rec.max_number > 7 then htp.nl; htp.p( '8.' || c4rec.instruction_8 ); end if;
      if c4rec.max_number > 8 then htp.nl; htp.p( '9.' || c4rec.instruction_9 ); end if;
      if c4rec.max_number > 9 then htp.nl; htp.p( '10.' || c4rec.instruction_10 ); end if;
     htp.p( '</TD>' );

     htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
      htp.nl;
      htp.nl;
      htp.formselectopen( 'P1', null, nvl(c4rec.max_number,1) + 1, cattributes=>'MULTIPLE' );
      htp.formselectoption( 'Click <-- Add to Add Items', cattributes=>'VALUE=""');
      for c5rec in c5( purchord.poid, c3rec.shopping_id ) loop
       htp.formselectoption( c5rec.film_name, cattributes=>'VALUE="' || '[P]' || c5rec.shopping_id || '"' );
      end loop;
      htp.formselectclose;
     htp.p( '</TD>' );

     -- Column 2: Form Submit Buttons
     htp.p( '<TD VALIGN="MIDDLE" ALIGN="CENTER">' );
      htp.formsubmit( 'ACTION', '<-- Add' );
      htp.nl;
      htp.nl;
      htp.formsubmit( 'ACTION', 'Remove -->' );
     htp.p( '</TD>' );

     -- Column 3: Items in Shopping Basket not in Package
     htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
      htp.bold( 'Items in Basket' );
      htp.nl;
      htp.formselectopen( 'P2', null, 10, cattributes=>'MULTIPLE' );
      htp.formselectoption( NULL );
      for c6rec in c6( purchord.poid ) loop
       htp.formselectoption( c6rec.film_name, cattributes=>'VALUE="' || '[B]' || c6rec.shopping_id || '"' );
      end loop;
      htp.formselectclose;

     htp.p( '</TD>' );
    htp.tableclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.anchor( 'fname.acct_orders?surl=' || surl || '&acid=' || acid, 'Shopping Basket' );
 htp.nl;
 htp.line;
 htp.bold( 'Modify Details of Other Packages in the Shopping Basket' );
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 for c2rec in c2( purchord.poid ) loop
  if c2rec.shopping_id <> c3rec.shopping_id
   then
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'cst.packprod_edit?surl=' || surl || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid || '&pkg=' || c2rec.shopping_id, c2rec.photo_size ) );
    htp.tablerowclose;
  end if;
 end loop;
 htp.tableclose;
 */
 htp.p( '</CENTER> ' );
 glbx.close_page( pfx );

exception when others then
 glbx.error_details( 'CST', 'PACKPROD_EDIT',errmsg=>sqlerrm);
end packprod_edit;

procedure accept_packprod_edit_basket( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, pkg in integer default null, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c2( shopid integer ) is select photo_cost from shopping_basket where shopping_id = shopid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		theme%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 quick_exit	boolean;

begin
  -- Remove redundant items from the shopping basket
 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'CST.ACCEPT_PACKPROD_EDIT_BASKET' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

  glbx.get_all_order_details(sess_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec );
  for j in p1.first..p1.last loop
    if p1(j) <> '0'
     then
      open c2(p1(j));
      fetch c2 into c2rec;
      close c2;
      if fname.cleanup_package(purchord.poid, p1(j) ) then null; end if;
      fname.purchase_audit_trail( surl, purchord.poid, 'DELETE FROM BASKET', 'D', 'C', c2rec.photo_cost, purchord, voidrec );
    end if;
  end loop;

  fname.process_purchase_order(surl, sess_id, profid, ltype, acid, 'UPDATE', voidrec, c1rec, p6, p1, p2, p0, quick_exit, check_just_added_package=>FALSE );

  -- Set Price Back to 0, if images included in Price
  update shopping_basket
   set
    photo_cost = 0
  where
   poid = purchord.poid and
   packaged_product_id = pkg and
   exists (select 'x' from item_package_product where spb = voidrec.spb and ppi = (select ppi from shopping_basket where shopping_id = pkg));
  commit;

/*
 for j in p0.first..p0.last loop
  htp.p( 'P0:' || p0(j) ); htp.nl;
 end loop;
 for j in p1.first..p1.last loop
  htp.p( 'P1:' || p1(j) ); htp.nl;
 end loop;
 for j in p2.first..p2.last loop
  htp.p( 'P2:' || p2(j) ); htp.nl;
 end loop;
 for j in p3.first..p3.last loop
  htp.p( 'P3:' || p3(j) ); htp.nl;
 end loop;
 for j in p6.first..p6.last loop
  htp.p( 'P6:' || p6(j) ); htp.nl;
 end loop;
 htp.nl;
 htp.bold( action );
 return;
*/

  if action = 'Recalculate'
   then
    packprod_edit( surl, left_api_parm, start_from, display_detail, acid, pkg );

  elsif action = 'Add More Items'
   then
    -- xxx for the moment just go home, otherwise try to remember where
    glbx.acct_home( surl );

  elsif action = 'Confirm'
   then
    -- Confirm Screen
     update shopping_basket
      set
       isgallery = 'Q'
     where
      poid = purchord.poid and
      shopping_id = pkg;
     commit;

     glbx.main_title( surl, null,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
     htp.p( '<CENTER>' );
      htp.nl;
      htp.bold( 'Do you wish to buy more Images?' );
      htp.nl;
      htp.nl;
      htp.formopen( 'cst.accept_confirm_addmore' );
      htp.formhidden( 'SURL', surl );
      htp.formhidden( 'ACID', acid );
      htp.formhidden( 'PKG', pkg );
      htp.formhidden( 'LEFT_API_PARM', left_api_parm );
      htp.formhidden( 'START_FROM', start_from );
      htp.formhidden( 'DISPLAY_DETAIL', display_detail );
      htp.formsubmit( 'ACTION', 'Yes' );
      htp.formsubmit( 'ACTION', 'No' );
      htp.formclose;
     htp.p( '</CENTER>' );
     htp.htmlclose;

  end if;

exception when others then
 glbx.error_details( 'CST', 'PACKPROD_EDIT',errmsg=>sqlerrm);
end accept_packprod_edit_basket;

procedure accept_confirm_addmore( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, pkg in integer default null, action in varchar2 )
as
begin
 if action = 'Yes'
  then
    -- xxx for the moment just go home, otherwise try to remember where
    glbx.acct_home( surl );
  else
    fname.acct_orders( surl );
 end if;
exception when others then
 glbx.error_details( 'CST', 'ACCEPT_CONFIRM_ADDMORE',errmsg=>sqlerrm);
end accept_confirm_addmore;

procedure accept_packprod_edit( surl in varchar2, left_api_parm in varchar2, start_from in integer, display_detail in char, acid in integer, pkg in integer default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c2( vpoid integer, vshopid integer ) is select * from purchase_package_product where poid = vpoid and shopping_id = vshopid;
 cursor c3( vspb integer, vppi integer ) is select * from item_package_product where spb = vspb and ppi = vppi;
 cursor c4( vshopid integer ) is select * from shopping_basket where shopping_id = vshopid;
 cursor c5( vppi integer ) is select spb,ppi from phg_price_item where ppi = vppi;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sess_id	integer;
 profid		integer;
 sts		varchar2(100);
 vshopid	integer;
 x		integer;
 fin		boolean;
 pfx		theme%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 purchord	purchase_order%ROWTYPE;

begin

 glbx.cookie_id( surl,stype, ltype, sess_id, sts, 'S', progcalled=>'CST.ACCEPT_PACKPROD_HDR' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(sess_id, ltype, acid, profid, c1rec, pfx, theme_rec, purchord, voidrec );
 open c2( purchord.poid, pkg );
 fetch c2 into c2rec;
 if c2%NOTFOUND
  then
   close c2;
   open c4(pkg);
   fetch c4 into c4rec;
   close c4;
   open c5(c4rec.ppi);
   fetch c5 into c5rec;
   close c5;
   open c3( c5rec.spb, c5rec.ppi );
   fetch c3 into c3rec;
   close c3;
   insert into purchase_package_product(spb,ppi,poid,shopping_id,number_of_images) values
     (c5rec.spb,c5rec.ppi,purchord.poid,pkg,nvl(c3rec.min_number,1));
   open c2( purchord.poid, pkg );
   fetch c2 into c2rec;
   close c2;
  else
   close c2;
 end if;
 open c3( c2rec.spb, c2rec.ppi );
 fetch c3 into c3rec;
 close c3;
 if action = 'Remove -->' and p1.count > 0
  then
   for j in p1.first..p1.last loop
    if p1(j) is not null and substr(p1(j),2,1) = 'P'
     then
      x := substr(p1(j),instr(p1(j),']') + 1);

      if c2rec.umo_id_1 = x then c2rec.umo_id_1 := NULL; end if;
      if c2rec.umo_id_2 = x then c2rec.umo_id_2 := NULL; end if;
      if c2rec.umo_id_3 = x then c2rec.umo_id_3 := NULL; end if;
      if c2rec.umo_id_4 = x then c2rec.umo_id_4 := NULL; end if;
      if c2rec.umo_id_5 = x then c2rec.umo_id_5 := NULL; end if;
      if c2rec.umo_id_6 = x then c2rec.umo_id_6 := NULL; end if;
      if c2rec.umo_id_7 = x then c2rec.umo_id_7 := NULL; end if;
      if c2rec.umo_id_8 = x then c2rec.umo_id_8 := NULL; end if;
      if c2rec.umo_id_9 = x then c2rec.umo_id_9 := NULL; end if;
      if c2rec.umo_id_10 = x then c2rec.umo_id_10 := NULL; end if;
    end if;
    if c3rec.images_included_in_price = 'T'
     then
      update shopping_basket
        set photo_cost = nvl(original_photo_cost,0)
      where poid = purchord.poid and
            shopping_id = x;
    end if;
    update shopping_basket
     set packaged_product_id = null
    where shopping_id = x and
          poid = purchord.poid;
   end loop;
    update purchase_package_product
     set umo_id_1 = c2rec.umo_id_1,
         umo_id_2 = c2rec.umo_id_2,
         umo_id_3 = c2rec.umo_id_3,
         umo_id_4 = c2rec.umo_id_4,
         umo_id_5 = c2rec.umo_id_5,
         umo_id_6 = c2rec.umo_id_6,
         umo_id_7 = c2rec.umo_id_7,
         umo_id_8 = c2rec.umo_id_8,
         umo_id_9 = c2rec.umo_id_9,
         umo_id_10 = c2rec.umo_id_10
    where shopping_id = pkg and
          poid = purchord.poid;

 elsif action = '<-- Add' and p2.count > 0
  then
   for j in p2.first..p2.last loop
    if p2(j) is not null and substr(p2(j),2,1) = 'B'
     then
      fin := FALSE;
      x := substr(p2(j),instr(p2(j),']') + 1);
      if c2rec.umo_id_1 is null  and not fin  and c3rec.max_number > 0  then c2rec.umo_id_1 := x; fin := TRUE; end if;
      if c2rec.umo_id_2 is null  and not fin  and c3rec.max_number > 1  then c2rec.umo_id_2 := x; fin := TRUE; end if;
      if c2rec.umo_id_3 is null  and not fin  and c3rec.max_number > 2  then c2rec.umo_id_3 := x; fin := TRUE; end if;
      if c2rec.umo_id_4 is null  and not fin  and c3rec.max_number > 3  then c2rec.umo_id_4 := x; fin := TRUE; end if;
      if c2rec.umo_id_5 is null  and not fin  and c3rec.max_number > 4  then c2rec.umo_id_5 := x; fin := TRUE; end if;
      if c2rec.umo_id_6 is null  and not fin  and c3rec.max_number > 5  then c2rec.umo_id_6 := x; fin := TRUE; end if;
      if c2rec.umo_id_7 is null  and not fin  and c3rec.max_number > 6  then c2rec.umo_id_7 := x; fin := TRUE; end if;
      if c2rec.umo_id_8 is null  and not fin  and c3rec.max_number > 7  then c2rec.umo_id_8 := x; fin := TRUE; end if;
      if c2rec.umo_id_9 is null  and not fin  and c3rec.max_number > 8  then c2rec.umo_id_9 := x; fin := TRUE; end if;
      if c2rec.umo_id_10 is null and not fin  and c3rec.max_number > 9  then c2rec.umo_id_10 := x; fin := TRUE; end if;
    end if;
    if fin
     then
      if c3rec.images_included_in_price = 'T'
       then
        update shopping_basket
          set original_photo_cost = photo_cost
        where poid = purchord.poid and
              shopping_id = x;
        update shopping_basket
          set photo_cost = 0
        where poid = purchord.poid and
              shopping_id = x;
      end if;
      update shopping_basket
       set packaged_product_id = pkg
       where shopping_id = x and
            poid = purchord.poid;
    end if;
   end loop;
    update purchase_package_product
     set umo_id_1 = c2rec.umo_id_1,
         umo_id_2 = c2rec.umo_id_2,
         umo_id_3 = c2rec.umo_id_3,
         umo_id_4 = c2rec.umo_id_4,
         umo_id_5 = c2rec.umo_id_5,
         umo_id_6 = c2rec.umo_id_6,
         umo_id_7 = c2rec.umo_id_7,
         umo_id_8 = c2rec.umo_id_8,
         umo_id_9 = c2rec.umo_id_9,
         umo_id_10 = c2rec.umo_id_10
    where shopping_id = pkg and
          poid = purchord.poid;

 end if;

 commit;

 packprod_edit( surl, left_api_parm, start_from, display_detail, acid, pkg );

exception when others then
 glbx.error_details( 'CST', 'ACCEPT_PACKPROD_EDIT',errmsg=>sqlerrm);
end accept_packprod_edit;

function attach_package_item( nmb in integer, purchord purchase_order%ROWTYPE, c3rec in item_package_product%ROWTYPE, c5rec in phg_price_item%ROWTYPE, c5arec in shopping_basket%ROWTYPE )
 return boolean
as

 cursor c7( vpoid integer, vshopid integer ) is select * from purchase_package_product where poid = vpoid and shopping_id = vshopid;

 c7rec		c7%ROWTYPE;

begin
  update shopping_basket set packaged_product_id = nmb where shopping_id = c5arec.shopping_id;
  if c3rec.images_included_in_price = 'T'
   then
    update shopping_basket set original_photo_cost = photo_cost where shopping_id = c5arec.shopping_id;
    update shopping_basket set photo_cost = 0 where shopping_id = c5arec.shopping_id;
  end if;
  open c7(purchord.poid,nmb);
  fetch c7 into c7rec;
  if c7%NOTFOUND
   then
     close c7;
     insert into purchase_package_product(spb,ppi,poid,shopping_id,number_of_images) values (c5rec.spb,c5rec.ppi,purchord.poid,nmb,nvl(c3rec.min_number,1));
     open c7(purchord.poid,nmb);
     fetch c7 into c7rec;
  end if;
  close c7;
  if c7rec.umo_id_1 is null then update purchase_package_product set umo_id_1 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_2 is null then update purchase_package_product set umo_id_2 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_3 is null then update purchase_package_product set umo_id_3 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_4 is null then update purchase_package_product set umo_id_4 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_5 is null then update purchase_package_product set umo_id_5 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_6 is null then update purchase_package_product set umo_id_6 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_7 is null then update purchase_package_product set umo_id_7 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_8 is null then update purchase_package_product set umo_id_8 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_9 is null then update purchase_package_product set umo_id_9 = c5arec.shopping_id where shopping_id = nmb;
   elsif c7rec.umo_id_10 is null then update purchase_package_product set umo_id_10 = c5arec.shopping_id where shopping_id = nmb;
  end if;
  return( TRUE );
end attach_package_item;

procedure handle_toggle( surl in varchar2, footer in varchar2, left_api_parm in varchar2, start_from in varchar2, display_detail in varchar2, acid in integer )
as

 cusrec		customer_account%ROWTYPE;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		theme%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 voidrec	order_style%ROWTYPE;
 purchord	purchase_order%ROWTYPE;
 vl		varchar2(100);
 bl		boolean;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'CST.HANDLE_TOGGLE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 glbx.get_all_order_details(owner_id, ltype, acid, profid, cusrec, pfx, theme_rec, purchord, voidrec );
 vl := glbx.get_login_application( owner_id, 'TOGGLE' );
 if vl is null then vl := cusrec.toggle_default; elsif vl = 'R' then vl := 'A'; else vl := 'R'; end if;
 bl := glbx.update_login_application( owner_id, 'TOGGLE', vl );
 owa_util.redirect_url( footer || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || translate(left_api_parm,' &','+~') ||
                    '&start_from=' || start_from || '&display_detail=' || display_detail || '&acid=' || acid );
end handle_toggle;

end cst;
/
