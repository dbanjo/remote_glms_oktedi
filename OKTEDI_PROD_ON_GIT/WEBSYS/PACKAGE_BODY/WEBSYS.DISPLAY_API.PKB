CREATE OR REPLACE package body WEBSYS.display_api
as

--
-- This Procedure calls the other display pages
--

procedure main_display( surl varchar2,
  stype in integer,
  ltype in varchar2,
  umrec in UMP.SEARCH_RESULT_PHG,
  cusrec in CUSTOMER_ACCOUNT%ROWTYPE,
  pfx THEME%ROWTYPE,
  theme_rec theme_types%ROWTYPE,
  voidrec in order_style%ROWTYPE,
  footer_api in varchar2,
  current_page_number in integer default 1,
  search_total in integer default 0,
  display_detail in char default null,
  left_api in varchar2,
  left_api_parm in varchar2,
  cusloc in varchar2,
  lbox in varchar2,
  acid in integer default null,
  sessid in integer,
  msg in varchar2,
  extra_term in varchar2 default null)
as

 ext_call	varchar2(100);

begin

if display_detail = pfx.display_style
 then
  ext_call := pfx.external_call;
elsif display_detail = pfx.shop_style
 then
  ext_call := pfx.shop_external_call;
elsif display_detail = pfx.toggle_style
 then
  ext_call := pfx.toggle_external_call;
else
  ext_call := pfx.external_call;
end if;

if ext_call is null
 then
  return;
else
if upper(ext_call) = 'FAIRFAX' then
  fairfax.main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg, 1);
 elsif upper(ext_call) = 'FAIRFAX_SIMPLE' then
  fairfax.simpleSkin(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'FAIRFAX_ADVANCED' then
  fairfax.advancedSkin(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'MEDIADRIVE' then
  mediadrive.main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'FONTERRA_SIMPLE' then
  fonterra.simpleSkin(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'FONTERRA_ADVANCED' then
  fonterra.advancedSkin(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'ARU' then
  aru.main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'SPI' then
  spi.main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'QUICKSEARCH' then
  spi.main_display_qs(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'JUDGE' then
  xscore.main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'LINEMODE' then
  spi.main_display_lm(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'LANDCARE' then
  lc.main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
 elsif upper(ext_call) = 'FTP' then
  ftp.main_display(surl, stype, ltype, umrec, cusrec, pfx, theme_rec, footer_api, current_page_number, search_total, display_detail, left_api, left_api_parm, cusloc, lbox, acid, sessid, msg);
end if;

  --
  -- Add Calls to other skins here.
  -- Use pfx.external_call to distinguish between them
  --
end if;

end main_display;

end display_api;

/
