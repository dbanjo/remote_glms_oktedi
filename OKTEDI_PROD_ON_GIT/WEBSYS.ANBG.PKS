CREATE OR REPLACE package WEBSYS.anbg
as

procedure main_display(
      surl                 varchar2,
      stype                in integer,
      ltype                in varchar2,
      umrec                in UMP.SEARCH_RESULT_PHG,
      cusrec               in CUSTOMER_ACCOUNT%ROWTYPE,
      pfx                  THEME%ROWTYPE,
      theme_rec            theme_types%ROWTYPE,
      footer_api           in varchar2,
      current_page_number  in integer default 1,
      search_total         in integer default 0,
      display_detail       in char default null,
      left_api             in varchar2,
      left_api_parm        in varchar2,
      cusloc               in varchar2,
      lbox                 in varchar2,
      acid                 in integer default null,
      sessid               in integer,
      msg                  in varchar2
      );

procedure simple_search(
      surl           varchar2,
      acid           integer,
      keywords       varchar2 default null,
      search_type    varchar2 default null,
      categories     GLBX.MYARRAY,
      image_per_page varchar2 default null,
      image_from     varchar2 default null,
      ppn            GLBX.MYARRAY,
      pb             GLBX.MYARRAY,
      action         varchar2
      );

procedure main_image_api_call(
      surl                varchar2,
      acid                integer,
      v_umo               integer,
      footer_api          varchar2,
      left_api_parm       varchar2,
      current_page_number integer
      );

procedure image_display2(
      surl                varchar2,
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
      ispopup             char default 'F'
      );

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
      );

--function reloadImage(pSURL varchar2, pAccountId integer, pFileName varchar2, pUmoId integer) return integer;

procedure acct_home(surl in varchar2, acid in integer, ltype in varchar2);
procedure anbg_search( surl in varchar2, acid in integer, msg in varchar2 default null );
procedure accept_anbg_search( surl in varchar2, acid in integer, ltype in varchar2, ty in varchar2, p0 in varchar2, edit_type in glbx.myarray, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, a1 in glbx.myarray, a2 in glbx.myarray, action in varchar2 );

end anbg;

/
