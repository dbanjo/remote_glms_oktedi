CREATE OR REPLACE package WEBSYS.fonterra
as

SUBTYPE skinType IS pls_integer;

procedure disp_meta_query_search(surl varchar2, acid integer);

--procedure previous_orders(surl varchar2, footer_api varchar2, left_api_parm varchar2, start_from integer default 1, display_detail char default null, acid integer default null, msg varchar2 default null);

procedure simpleSkin(surl varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE, footer_api varchar2, current_page_number integer default 1, search_total integer default 0, display_detail char default null, left_api varchar2, left_api_parm varchar2, cusloc varchar2, lbox varchar2, acid integer default null, sessid integer, msg varchar2);

procedure advancedSkin(surl varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE, footer_api varchar2, current_page_number integer default 1, search_total integer default 0, display_detail char default null, left_api varchar2, left_api_parm varchar2, cusloc varchar2, lbox varchar2, acid integer default null, sessid integer, msg varchar2);

procedure main_display(surl varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE, theme_rec theme_types%ROWTYPE, footer_api varchar2, current_page_number integer default 1, search_total integer default 0, display_detail char default null, left_api varchar2, left_api_parm varchar2, cusloc varchar2, lbox varchar2, acid integer default null, sessid integer, msg varchar2, skin skinType);

procedure filter(surl varchar2, acid integer, ltype varchar2, pCategories glbx.MyArray, pPN glbx.MyArray, pB glbx.MyArray, pChosenImage glbx.MyArray, pMetaStem glbx.MyArray, pMetaAttrId glbx.MyArray, pMetaEditType glbx.MyArray, pMetaP1 glbx.MyArray, pMetaTagValue glbx.MyArray, pCategory varchar2 default null, pKeywords varchar2 default null, pAction varchar2 default null, pSearchType varchar2 default null, pLightbox varchar2 default null, pDataView varchar2 default null, pSoundsLike varchar2 default null, pImageFrom varchar2 default null, pFormat varchar2 default null, pLeftapiParm varchar2 default null, footer_api varchar2 default null, start_from integer default null, display_detail char default null, pLightboxId varchar2 default null, pCommand varchar2 default null, pGotoPage varchar2 default '1');

procedure eml(surl in varchar2, left_api_parm in varchar2 default null, search_total in integer default null, display_detail in varchar2 default null, ltype in varchar2,acid in integer, screen_location in varchar2 default null);

end;

/
