CREATE OR REPLACE package WEBSYS.mediadrive
as

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
msg                  varchar2
);

/*
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
pLeftapiParm   varchar2 default null,
footer_api     varchar2 default null,
start_from     integer default null,
display_detail char default null,
pLightboxId    varchar2 default null,
pCommand       varchar2 default null,
pGotoPage      varchar2 default '1'
);
*/

procedure addImage( surl varchar2, acid integer, v_umo integer, footer_api varchar2,
                    left_api_parm varchar2, current_page_number integer, new char,
                    pCategory varchar2 default null,
                    pPublicationName varchar2 default null,
                    pType varchar2 default null, pDistribution varchar2 default null,
                    pCirculation varchar2 default null );
procedure processAddImage( surl varchar2, acid integer, v_umo integer, footer_api varchar2,
                           left_api_parm varchar2, current_page_number integer,
                           pCategory varchar2 default null, pCirculation varchar2 default null,
                           pDistribution varchar2 default null, pType varchar2 default null,
                           pPublicationName varchar2 default null, file varchar2 default null,
                           pName varchar2 default null, pMainSubject varchar2 default null,
                           pSecondarySubject varchar2 default null, pScene varchar2 default null,
                           pBackground varchar2 default null, pAddToListSubmit varchar2 default null,
                           pImageList GLBX.MYARRAY, pCommand varchar2 default null );
procedure advancedSearch( surl varchar2, acid integer, footer_api varchar2, left_api_parm varchar2, current_page_number integer );
procedure processSearch( surl varchar2, acid integer, pSearch varchar2, pCategory varchar2, pSearchSubmit varchar2 default null );

end mediadrive;

/
