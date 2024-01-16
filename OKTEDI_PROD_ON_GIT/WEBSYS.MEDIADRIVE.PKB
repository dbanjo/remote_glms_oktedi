CREATE OR REPLACE package body WEBSYS.mediadrive
as

MD_SEARCH constant integer := 1;
MD_UPLOAD constant integer := 2;
MD_ADVANCED_SEARCH constant integer := 3;

function format_name( fname in varchar2 ) return varchar2;
function tag( vsurl in varchar2, fname in varchar2 ) return varchar2;
function exst( vsurl varchar2 ) return boolean;
procedure top( surl varchar2, acid integer, footer_api varchar2, left_api_parm varchar, current_page_number integer, umrec UMP.SEARCH_RESULT_PHG, screen integer );
procedure bottom( surl varchar2, stype integer, loadscreen in boolean default TRUE );

function smallMenu( surl varchar2, acid integer, footer_api varchar2,
                    left_api_parm varchar2, current_page_number integer,
                    pCategory varchar2 default null )
return varchar2
as
   result varchar2(4000);
begin
   result := htf.ulistopen( cattributes=>'compact style="color: #ffffff; font-size: 10px; white-space: nowrap; ;line-height: 15px"' ) ||
             htf.listItem( htf.anchor( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'mediadrive.addImage?surl=' ||
                                       surl || '&acid=' || acid || '&v_umo=' || '&footer_api=' ||
                                       footer_api || '&left_api_parm=' || left_api_parm ||
                                       '&current_page_number=' || current_page_number || '&new=T' ||
                                       '&pCategory=' || pCategory,
                                       'add image' , cattributes=>'style="color: white; text-decoration: none;"' ) ) ||
             htf.listItem( htf.anchor( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'mediadrive.advancedSearch?surl=' ||
                                       surl || '&acid=' || acid || '&footer_api=' || footer_api ||
                                       '&left_api_parm=' || left_api_parm || '&current_page_number=' ||
                                       current_page_number,
                                       'adv search' , cattributes=>'style="color: white; text-decoration: none;"' ) ) ||
             -- htf.listItem( htf.anchor( '#', 'save search' , cattributes=>'style="color: white; text-decoration: none;"' ) ) ||
             -- htf.listItem( htf.anchor( '#', 'light boxes' , cattributes=>'style="color: white; text-decoration: none;"' ) ) ||
             htf.ulistClose;
   return result;
end smallMenu;

procedure main_display( surl varchar2, stype integer, ltype varchar2,
                        umrec UMP.SEARCH_RESULT_PHG,
                        cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx THEME%ROWTYPE,
                        theme_rec theme_types%ROWTYPE, footer_api varchar2,
                        current_page_number integer default 1,
                        search_total integer default 0,
                        display_detail char default null, left_api varchar2,
                        left_api_parm varchar2, cusloc varchar2, lbox varchar2,
                        acid integer default null, sessid integer, msg varchar2 )
as
   procedure showThumbnailSummary
   as
      line integer;
      twidth number;
      tHeight number;
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
               for j in umrec.first..umrec.last loop
                  if (MOD(line, glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype)+1) = 1) and (line <> 1) then
                     htp.tableRowClose;
                     htp.tableRowOpen(cvalign=>'top');
                  end if;
                  htp.p('<TD valign="bottom" width="' || tWidth || '" BGCOLOR="#' || pfx.text_back || '">');
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

begin
   /*
   htp.init;
   htp.p( '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' );
   htp.htmlOpen;
   htp.headOpen;
   htp.title( 'Mediadrive' );
   htp.headClose;
   htp.bodyOpen;
   */
   htp.formclose;
   htp.tableOpen( 'border="0" cellpadding="0" cellspacing="0" width="100%"' );
   /* Top cell */
   htp.tableRowOpen;
   htp.p( '<td colspan="2">' );
   htp.formOpen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'mediadrive.processSearch' );
   htp.formHidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   mediadrive.top( surl, acid, footer_api, left_api_parm, current_page_number, umrec, MD_SEARCH );
   htp.formClose;
   htp.p( '</td>' );
   htp.tableRowClose;
   /* Left cell */
   htp.tableRowOpen;
   htp.p( '<td>' );
   showThumbnailSummary;
   htp.p( '</td>' );
   htp.tableRowClose;
   /* Bottom cell */
   htp.tableRowOpen;
   htp.p( '<td colspan="2">' );
   bottom( surl, stype, FALSE );
   htp.p( '</td>' );
   htp.tableRowClose;
   /*
   htp.bodyClose;
   htp.htmlClose;
   */
end main_display;

/* Display the top frame */
procedure top( surl varchar2, acid integer, footer_api varchar2, left_api_parm varchar, current_page_number integer, umrec UMP.SEARCH_RESULT_PHG, screen integer )
as
   cursor c1(cacid integer) is
      select
         distinct um.extras.title category,
         um.umo_scene_id scene_id
      from
         umo um
      where
         aid = cacid;
   c1rec c1%ROWTYPE;
   lAccountId integer;
   lCurrentCategory varchar2( 100 );
   cusrec	customer_account%ROWTYPE;
begin
   if not dapi.init( surl, 'MEDIADRIVE.TOP', acid, FALSE ) then
      dapi.initFailed( surl );
      return;
   end if;
   lAccountId := dapi.getAccountId;
   cusrec := dapi.getCustomerAccountRecord;
   htp.tableOpen( cattributes=>'border="0" cellpadding="0" cellspacing="0" width="100%"' );
   htp.tableRowOpen( cattributes=>'height="10"' );
   /* Thin line at the top */
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/spacer.gif',
                           cattributes=>'width="100%" height="10"'), ccolspan=>'8',
                  cattributes=>'height="10" background="' ||
                  DECS.IMAGE_LOCATION || 'skin/mediadrive/bg_line.gif"' );
   /* Small cell at the end */
   htp.tableData( '&nbsp;', cattributes=>'height="10" width="1" background="' ||
                  DECS.IMAGE_LOCATION || 'skin/mediadrive/bg_line.gif"' );
   htp.tableRowClose;
   htp.tableRowOpen( cattributes=>'height="25"' );
   /* Mediadrive logo */
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/mediadrive.gif',
                           cattributes=>'width="191"' ),
                  ccolspan=>'2', cattributes=>'height="25" width="191" bgcolor="#6873c9"' );
   /* Username */
   htp.tableData( '<div style="text-align: right; font: 11px arial, helvetica, sans-serif; text-transform: uppercase; color: white;">' ||
                  'User: <strong style="color: white">' || cusrec.account_name || '</strong>&nbsp;</div>',
                  cattributes=>'height="25" align="right" bgcolor="#6873c9"' );
   /* Home button */
   htp.tableData( htf.anchor( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'glbx.acct_home?surl=' || surl,
                              htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/home.gif' ,
                                       cattributes=>'name="home" border="0"' ),
                              cattributes=>'onMouseOver="home.src=''' || DECS.IMAGE_LOCATION ||
                              'skin/mediadrive/homex.gif''" onMouseOut="home.src=''' || DECS.IMAGE_LOCATION ||
                              'skin/mediadrive/home.gif''" target="_parent"' ),
                  cattributes=>'height="25" width="65" bgcolor="#6873c9"' );
   /* Contact us button */
   htp.tableData( htf.anchor( 'http://www.mediadrive.com.au',
                              htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/contact.gif' ,
                                       cattributes=>'name="home" border="0"' ),
                              cattributes=>'onMouseOver="home.src=''' || DECS.IMAGE_LOCATION ||
                              'skin/mediadrive/contactx.gif''" onMouseOut="home.src=''' || DECS.IMAGE_LOCATION ||
                              'skin/mediadrive/contact.gif''" target="_parent"' ),
                  cattributes=>'height="25" width="90" bgcolor="#6873c9"' );
   /* About button */
   htp.tableData( htf.anchor( 'http://www.mediadrive.com.au',
                              htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/about.gif' ,
                                       cattributes=>'name="home" border="0"' ),
                              cattributes=>'onMouseOver="home.src=''' || DECS.IMAGE_LOCATION ||
                              'skin/mediadrive/aboutx.gif''" onMouseOut="home.src=''' || DECS.IMAGE_LOCATION ||
                              'skin/mediadrive/about.gif''" target="_parent"' ), ccolspan=>'2',
                  cattributes=>'height="25" width="119" bgcolor="#6873c9"' );
   /* Info button */
   htp.tableData( htf.anchor( 'http://www.mediadrive.com.au',
                              htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/info.gif' ,
                                       cattributes=>'name="home" border="0"' ),
                              cattributes=>'onMouseOver="home.src=''' || DECS.IMAGE_LOCATION ||
                              'skin/mediadrive/infox.gif''" onMouseOut="home.src=''' || DECS.IMAGE_LOCATION ||
                              'skin/mediadrive/info.gif''" target="_parent"' ),
                  cattributes=>'height="25" width="71" bgcolor="#6873c9"' );
   htp.tableData( '&nbsp;', cattributes=>'height="25" width="1" bgcolor="#6873c9"' );
   htp.tableRowClose;
   htp.tableRowOpen( cattributes=>'height="55"' );
   /* Empty cell */
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/spacer.gif',
                           cattributes=>'height="55" width="72"' ),
                  cattributes=>'width="72" background="' || DECS.IMAGE_LOCATION || 'skin/mediadrive/bg_line.gif"' );
   /* Large logo */
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/logo.gif',
                           cattributes=>'height="129" width="119"' ), crowspan=>'3',
                  cattributes=>'valign="bottom" width="119" height="129"' );
   /* Browse button */
   htp.p( '<td align="right" width="72" style="text-align: right" background="' || DECS.IMAGE_LOCATION || 'skin/mediadrive/bg_line.gif">' );
      if screen = MD_SEARCH then
         htp.p( '<div style="text-align: right; white-space: nowrap">' );
         htp.formSelectOpen( 'pCategory', cattributes=>'style="text-align: right"' );
         for c1rec in c1( lAccountId ) loop
            if umrec.first > 0 then
               if umrec(umrec.first).umo_scene_id = c1rec.scene_id then
                  htp.formSelectOption(c1rec.category, cattributes=>'SELECTED value="' || c1rec.scene_id || '"');
                  lCurrentCategory := c1rec.scene_id;
               else
                  htp.formSelectOption(c1rec.category, cattributes=>'value="' || c1rec.scene_id || '"');
               end if;
            else
               htp.formSelectOption(c1rec.category, cattributes=>'value="' || c1rec.scene_id || '"');
            end if;
         end loop;
         htp.formSelectClose;
         htp.formText( 'pSearch' );
         htp.p( '</div>' );
      elsif screen = MD_UPLOAD then
         htp.p(GLBX.UPLOAD_NAME);
      elsif screen = MD_ADVANCED_SEARCH then
         htp.p( '&nbsp;' );
      end if;
   htp.p( '</td>' );
   /* Add to list button */
   htp.p( '<td colspan="3" align="right" width="72" style="text-align: right" background="' ||
          DECS.IMAGE_LOCATION || 'skin/mediadrive/bg_line.gif">' );
      if screen = MD_SEARCH then
         htp.p( '<div style="text-align: right; white-space: nowrap">' );
         htp.formSubmit( 'pSearchSubmit', 'search' );
         htp.p( '</div>' );
      elsif screen = MD_UPLOAD then
         htp.formSubmit( null, 'Add to list' );
         null;
      elsif screen = MD_ADVANCED_SEARCH then
         htp.p( '&nbsp;' );
      end if;
   htp.p( '</td>' );
   /* List of choices */
   htp.tableData( smallMenu( surl, acid, footer_api, left_api_parm, current_page_number,
                  lCurrentCategory ), ccolspan=>'2', crowspan=>'2',
                  cattributes=>'width="101" background="' || DECS.IMAGE_LOCATION || 'skin/mediadrive/bg_line.gif" nowrap' );
   /* Empty cell */
   htp.tableData( '&nbsp;',
                  cattributes=>'height="55" width="1" background="' || DECS.IMAGE_LOCATION || 'skin/mediadrive/bg_line.gif"' );
   htp.tableRowOpen( cattributes=>'height="43"' );
   /* Gradient on left */
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/grad.gif',
                           cattributes=>'height="74" width="72"' ), crowspan=>'2',
                  cattributes=>'height="74" width="72"' );
   /* Long gradient */
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/grad-14.gif',
                           cattributes=>'height="74" width="100%"' ), crowspan=>'2',
                  cattributes=>'height="74" width="80%"' );
   /* Curving line on the right */
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/grad2.gif',
                           cattributes=>'height="74" width="244"' ), crowspan=>'2',
                  ccolspan=>'3', cattributes=>'height="74" width="244"' );
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/spacer.gif',
                           cattributes=>'height="43" width="1"' ),
                  cattributes=>'height="43" background="' || DECS.IMAGE_LOCATION || 'skin/mediadrive/bg_line.gif"' );
   htp.tableRowClose;
   htp.tableRowOpen( cattributes=>'height="31"' );
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/space2.gif',
                           cattributes=>'height="31" width="101"' ), ccolspan=>'2',
                  cattributes=>'height="31" width="101"' );
   htp.tableData( htf.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/space2.gif',
                           cattributes=>'height="31" width="1"' ), ccolspan=>'2',
                  cattributes=>'height="31"' );
   htp.tableRowClose;
   htp.tableClose;
end top;

function exst( vsurl varchar2 )
 return boolean
as
 cursor c1( vsurl varchar2 ) is select 'x' ex from apache_ows_content where name in (select filename from file_upload_metadata where surl = vsurl );
 c1rec  c1%ROWTYPE;
begin
 open c1(vsurl);
 fetch c1 into c1rec;
 if c1%FOUND then close c1; return ( TRUE ); end if;
 close c1;
 return( FALSE );
end exst;

/* Display the top frame */
procedure bottom( surl varchar2, stype integer, loadscreen in boolean default TRUE )
as
begin
   htp.tableOpen( cattributes=>'border="0" cellspacing="0" cellpadding="0" width="100%"' );
   htp.tableRowOpen;
   htp.p( '<td bgcolor="#6873c9" valign="middle">' );
   htp.p( '<center>' );
   if loadscreen
    then
     htp.anchor( 'javascript:submitForm(''REMOVE FROM LIST'')', htf.bold( 'REMOVE FROM LIST' ), cattributes=>'style="color: #ffffff"' );
     htp.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/menu_line.gif' );
     htp.anchor( 'javascript:submitForm(''REMOVE ALL'')', htf.bold( 'REMOVE ALL' ), cattributes=>'style="color: #ffffff"' );
     htp.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/menu_line.gif' );
     if exst( glbx.truncsurl(surl) )
      then
       htp.anchor( 'javascript:submitForm(''UPLOAD ALL'')', htf.bold( 'UPLOAD' ), cattributes=>'style="color: #ffffff"' );
      else
       htp.bold( 'UPLOAD' ); --, cattributes=>'style="color: #ffffff"' );
     end if;
    else
     htp.p( '&nbsp;' );
   end if;
   htp.p( '</center>' );
   htp.p( '</td>' );
   htp.tableRowClose;
   htp.tableClose;
end bottom;

procedure addImage( surl varchar2, acid integer, v_umo integer, footer_api varchar2,
                    left_api_parm varchar2, current_page_number integer, new char,
                    pCategory varchar2 default null,
                    pPublicationName varchar2 default null,
                    pType varchar2 default null, pDistribution varchar2 default null,
                    pCirculation varchar2 default null )
as

   cursor c4(vsurl varchar2) is select distinct filename, date_loaded from file_upload_metadata where surl = vsurl order by 2 desc, 1;

   stype integer;
   aDummy UMP.SEARCH_RESULT_PHG;
   listBeginPos integer;
   listEndPos integer;
   tList varchar2(4000);
   i integer;
   lFileName varchar2(512);

procedure form
as
begin
   htp.tableopen( cattributes=>'width="100%" cellpadding="0" cellspacing="0" border="0"' );
   htp.tableRowOpen;
   htp.tableData( htf.header( 2, 'Publication Detail' ), ccolspan=>'5', cattributes=>'bgcolor="#cccccc"' );
   htp.tableRowClose;
   htp.tableRowOpen( cattributes=>'height="10"' );
   htp.tableData( '&nbsp;', ccolspan=>'5' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Publication Name:' ) );
   htp.tableData( htf.formText( 'pPublicationName', cvalue=>pPublicationName ), ccolspan=>'2' );
   htp.tableRowClose;
   htp.tableRowOpen( cattributes=>'height="10"' );
   htp.tableData( '&nbsp;', ccolspan=>'5' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.p( '<td>' );
   htp.bold( 'Type' );
   htp.nl;
   if pType = 'print' then
      htp.formRadio( 'pType', 'print', 'CHECKED' );
   else
      htp.formRadio( 'pType', 'print' );
   end if;
   htp.p( 'Print' );
   htp.nl;
   if pType = 'web' then
      htp.formRadio( 'pType', 'web', 'CHECKED' );
   else
      htp.formRadio( 'pType', 'web' );
   end if;
   htp.p( 'Web' );
   htp.nl;
   if pType = 'presentation' then
      htp.formRadio( 'pType', 'presentation', 'CHECKED' );
   else
      htp.formRadio( 'pType', 'presentation' );
   end if;
   htp.p( 'Presentation' );
   htp.nl;
   if pType = 'other' then
      htp.formRadio( 'pType', 'other', 'CHECKED' );
   else
      htp.formRadio( 'pType', 'other' );
   end if;
   htp.p( 'Other' );
   htp.p( '</td>' );
   htp.p( '<td>' );
   htp.bold( 'Distribution' );
   htp.nl;
   if pDistribution = 'confidential' then
      htp.formRadio( 'pDistribution', 'confidential', 'CHECKED' );
   else
      htp.formRadio( 'pDistribution', 'confidential' );
   end if;
   htp.p( 'Confidential/internal' );
   htp.nl;
   if pDistribution = 'government' then
      htp.formRadio( 'pDistribution', 'government', 'CHECKED' );
   else
      htp.formRadio( 'pDistribution', 'government' );
   end if;
   htp.p( 'Government' );
   htp.nl;
   if pDistribution = 'industry' then
      htp.formRadio( 'pDistribution', 'industry', 'CHECKED' );
   else
      htp.formRadio( 'pDistribution', 'industry' );
   end if;
   htp.p( 'Industry' );
   htp.nl;
   if pDistribution = 'public' then
      htp.formRadio( 'pDistribution', 'public', 'CHECKED' );
   else
      htp.formRadio( 'pDistribution', 'public' );
   end if;
   htp.p( 'Public' );
   htp.p( '</td>' );
   htp.p( '<td>' );
   htp.bold( 'Circulation' );
   htp.nl;
   if pCirculation = '100' then
      htp.formRadio( 'pCirculation', '100', 'CHECKED' );
   else
      htp.formRadio( 'pCirculation', '100' );
   end if;
   htp.p( '1 to 100' );
   htp.nl;
   if pCirculation = '1000' then
      htp.formRadio( 'pCirculation', '1000', 'CHECKED' );
   else
      htp.formRadio( 'pCirculation', '1000' );
   end if;
   htp.p( '101 to 1,000' );
   htp.nl;
   if pCirculation = '10000' then
      htp.formRadio( 'pCirculation', '10000', 'CHECKED' );
   else
      htp.formRadio( 'pCirculation', '10000' );
   end if;
   htp.p( '1,001 to 10,000' );
   htp.nl;
   if pCirculation = 'plus' then
      htp.formRadio( 'pCirculation', 'plus', 'CHECKED' );
   else
      htp.formRadio( 'pCirculation', 'plus' );
   end if;
   htp.p( '10,000 plus' );
   htp.p( '</td>' );
   htp.tableRowClose;
   htp.tableRowOpen( cattributes=>'height="10"' );
   htp.tableData( '&nbsp;', ccolspan=>'5' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.header( 2, 'Image Detail' ), ccolspan=>'5', cattributes=>'bgcolor="#cccccc"' );
   htp.tableRowClose;
   htp.tableRowOpen( cattributes=>'height="10"' );
   htp.tableData( '&nbsp;', ccolspan=>'5' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Name:' ) );
   htp.tableData( htf.formText( 'pName' ), ccolspan=>'2' );
   htp.tableData( htf.bold( 'Category' ) );
   htp.p( '<td>' );
   htp.formSelectOpen( 'pCategory' );
   htp.formSelectOption( 'Photo' );
   htp.formSelectOption( 'Document' );
   htp.formSelectOption( 'Audio' );
   htp.formSelectOption( 'Video' );
   htp.formSelectClose;
   htp.p( '</td>' );
   htp.tableRowClose;
   htp.tableRowOpen( cattributes=>'height="10"' );
   htp.tableData( '&nbsp;', ccolspan=>'5' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( '&nbsp;' );
   htp.tableData( htf.bold( 'Main Subject' ) );
   htp.tableData( htf.bold( 'Secondary Subject' ) );
   htp.tableData( '&nbsp;' );
   htp.tableData( htf.bold( 'Background' ) );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableData( htf.bold( 'Keywords' ) );
   htp.p( '<td>' );
   htp.formTextarea( 'pMainSubject', nrows=>'4', ncolumns=>'10' ); -- cattributes=>'size="2" multiple style="width: 180px"' );
   htp.formSelectClose;
   htp.p( '</td>' );
   htp.p( '<td>' );
   htp.formTextarea( 'pSecondarySubject', nrows=>'4', ncolumns=>'10' ); -- cattributes=>'size="2" multiple style="width: 180px"' );
   htp.formSelectClose;
   htp.p( '</td>' );
   htp.tableData( '&nbsp;' );
   htp.p( '<td>' );
   htp.formTextarea( 'pBackground', nrows=>'4', ncolumns=>'10' ); -- cattributes=>'size="2" multiple style="width: 180px"' );
   htp.formSelectClose;
   htp.p( '</td>' );
   htp.tableRowClose;
   htp.tableRowOpen;
   htp.tableRowClose;
   htp.tableClose;
end form;

begin
   if not dapi.init( surl, 'MEDIADRIVE.ADDIMAGE', acid ) then
      dapi.initFailed( surl );
      return;
   end if;
   dapi.setBodyAddition( 'style="margin: 0em; padding: 0em"' );
   dapi.pageOpen;
   --htp.comment( pMetagTagList );

   htp.p(
'<script type="text/javascript">
 <!--
  function submitForm(cmd)
  {
    document.MediaDrive.pCommand.value = cmd;
    document.MediaDrive.submit();
  }
  // End Javascript -->
  </script>' );

   htp.formOpen( owa_util.get_cgi_env('SCRIPT_NAME') || '/' || 'mediadrive.processAddImage', cattributes=>'name="MediaDrive" enctype="multipart/form-data"' );
   htp.formhidden( 'surl', surl );
   htp.formHidden( 'acid', acid );
   htp.formHidden( 'v_umo', v_umo );
   htp.formHidden( 'footer_api', footer_api );
   htp.formHidden( 'left_api_parm', left_api_parm );
   htp.formHidden( 'current_page_number', current_page_number );
   htp.formHidden( 'pScene', pCategory );
   htp.formHidden( 'pCommand', null );
   htp.tableOpen( 'border="0" cellpadding="0" cellspacing="0" width="100%"' );
   htp.tableRowOpen;

   /* Top cell */
   htp.p( '<td colspan="2">' );
   top( surl, acid, footer_api, left_api_parm, current_page_number, aDummy, MD_UPLOAD );
   htp.p( '</td>' );
   htp.tableRowClose;

   /* Left cell */
   htp.tableRowOpen( cattributes=>'valign="top"' );
   htp.p( '<td width="200" style="vertical-align: top;">' );
   htp.img( DECS.IMAGE_LOCATION || 'skin/mediadrive/spacer.gif', cattributes=>'width="200" height="1"' );
   listBeginPos := 1;
   listEndPos := 0;
   i := 0;
   htp.tableOpen( cattributes=>'border="0" cellpadding="0" cellspacing="0"' );
   htp.formHidden( 'pImageList', null );
   for c4rec in c4(glbx.truncsurl(surl)) loop
      htp.tableRowOpen;
       htp.tableData( htf.formCheckbox( 'pImageList', c4rec.filename, 'CHECKED' ) ||
                      format_name(c4rec.filename) || ' ' ||
                      htf.img( DECS.IMAGE_LOCATION || 'adminc/list.gif',cattributes=>'border=0', calt=>tag(glbx.truncsurl(surl),c4rec.filename)), cattributes=>'style="vertical-align: baseline;"' );
       --
      htp.tableRowClose;
   end loop;
   htp.tableClose;
   htp.p( '</td>' );

   /* Right cell */
   htp.p( '<td width="100%">' );
   form;
   htp.p( '</td>' );
   htp.tableRowClose;

   /* Bottom cell */
   htp.tableRowOpen;
   htp.p( '<td colspan="2">' );
   bottom( surl, stype, TRUE );
   htp.p( '</td>' );
   htp.tableRowClose;
   htp.tableClose;
   dapi.pageClose;
exception
 when others then htp.p( 'AI:' || sqlerrm );
end addImage;

function tag( vsurl in varchar2, fname in varchar2 )
 return varchar2
as

 cursor c1( vsurl varchar2, fname varchar2 ) is select * from file_upload_metadata where surl = vsurl and filename = fname order by attribute_id;
 retvar varchar2(4000);

begin
 for c1rec in c1(vsurl, fname ) loop
  retvar := c1rec.parm1 || ':' || c1rec.parm2 || chr(13) || retvar;
 end loop;
 return( retvar );
exception
 when others then return( sqlerrm );
end tag;

function format_name( fname in varchar2 )
 return varchar2
as
 x	integer;
begin
 x := instr(fname, '/' );
 if x = 0 then x := instr(fname,'\'); end if;
 if x = 0 then return( fname ); end if;
 return( substr(fname,x+1));
end format_name;

procedure processAddImage( surl varchar2, acid integer, v_umo integer, footer_api varchar2,
                           left_api_parm varchar2, current_page_number integer,
                           pCategory varchar2 default null, pCirculation varchar2 default null,
                           pDistribution varchar2 default null, pType varchar2 default null,
                           pPublicationName varchar2 default null, file varchar2 default null,
                           pName varchar2 default null, pMainSubject varchar2 default null,
                           pSecondarySubject varchar2 default null, pScene varchar2 default null,
                           pBackground varchar2 default null, pAddToListSubmit varchar2 default null,
                           pImageList GLBX.MYARRAY, pCommand varchar2 default null )
as
   cursor c1( cAccountId integer, cSubCategory varchar2 ) is
   select
      attribute_id
   from
      umo_attributes
   where
      sub_category = UPPER( cSubCategory )  and
      category = 'MEDIADRIVE' and
      umo_type in ('PHOTO','ALL');

   c1rec c1%ROWTYPE;

   cursor c2( cAccountId integer ) is
   select
      pid
   from
      customer_account
   where
      aid = cAccountId;

   cursor c3( v_umo integer ) is select * from umo where umo_id = v_umo;
   cursor c4( vsurl varchar2 ) is select * from file_upload_metadata where surl = vsurl;

   parm1		ump.parameters;
   parm2  		ump.parameters;
   lAccountId 		integer;
   lPhotographerId 	integer;
   lNewId 		umo.umo_id%TYPE;
   retval 		varchar2(100);
   lTagId 		GLBX.MYARRAY;
   lTagValue 		GLBX.MYARRAY;
   lTagvalueId 		GLBX.MYARRAY;
   lSingleTagId 	varchar2(100);
   i 			integer;
   j 			integer;
   ctr			integer;
   found 		boolean;
   ltype		varchar2(20);
   lList 		varchar2(4000);
   lMetaTagList 	varchar2(4000);
   result_list		UMP.SEARCH_RESULT_PHG;
   newid_arr		ump.myarray_int;

procedure add_filetag( vsurl in varchar2, fname in varchar2, p1 in varchar2, p2 in varchar2, p3 varchar2, attribid integer )
as
begin
 insert into file_upload_metadata(filename,date_loaded,parm1,parm2,parm3,attribute_id,surl) values (fname, sysdate, p1, p2, p3, attribid,vsurl );
exception
 when others
  then htp.p( 'AFT:' || sqlerrm );
end add_filetag;

begin
   if not dapi.init( surl, 'MEDIADRIVE.PROCESSADDIMAGE', acid ) then
      dapi.initFailed( surl );
   end if;

   if file is not null then
      lAccountId := dapi.getAccountId;
      --i := 0;
      open c1( lAccountId, 'Circulation' );
      fetch c1 into lSingleTagId;
      found := c1%FOUND;
      close c1;
      if found then
       add_filetag( glbx.truncsurl(surl), file, 'Circulation', pCirculation, null, lSingleTagId );
       /*
         i := i + 1;
         lTagId( i ) := lSingleTagId;
         lTagValue( i ) := pCirculation;
         lTagValueId( 1 ) := 0;
       */
      end if;
      open c1( lAccountId, 'Distribution' );
      fetch c1 into lSingleTagId;
      found := c1%FOUND;
      close c1;
      if found then
       add_filetag( glbx.truncsurl(surl), file, 'Distribution', pDistribution, null, lSingleTagId );
       /*
         i := i + 1;
         lTagId( i ) := lSingleTagId;
         lTagValue( i ) := pDistribution;
         lTagValueId( 1 ) := 0;
       */
      end if;
      open c1( lAccountId, 'Type' );
      fetch c1 into lSingleTagId;
      found := c1%FOUND;
      close c1;
      if found then
       add_filetag( glbx.truncsurl(surl), file, 'Type', pType, null, lSingleTagId );
       /*
         i := i + 1;
         lTagId( i ) := lSingleTagId;
         lTagValue( i ) := pType;
         lTagValueId( 1 ) := 0;
       */
      end if;
      open c1( lAccountId, 'Publication' );
      fetch c1 into lSingleTagId;
      found := c1%FOUND;
      close c1;
      if found then
       add_filetag( glbx.truncsurl(surl), file, 'Publication', pPublicationName, null, lSingleTagId );
       /*
         i := i + 1;
         lTagId( i ) := lSingleTagId;
         lTagValue( i ) := pPublicationName;
         lTagValueId( 1 ) := 0;
       */
      end if;
      open c1( lAccountId, 'Main' );
      fetch c1 into lSingleTagId;
      found := c1%FOUND;
      close c1;
      if found then
       add_filetag( glbx.truncsurl(surl), file, 'Main', pMainSubject, null, lSingleTagId );
       /*
         i := i + 1;
         lTagId( i ) := lSingleTagId;
         lTagValue( i ) := pMainSubject;
         lTagValueId( 1 ) := 0;
       */
      end if;
      open c1( lAccountId, 'Secondary' );
      fetch c1 into lSingleTagId;
      found := c1%FOUND;
      close c1;
      if found then
       add_filetag( glbx.truncsurl(surl), file, 'Secondary', pSecondarySubject, null, lSingleTagId );
        /*
         i := i + 1;
         lTagId( i ) := lSingleTagId;
         lTagValue( i ) := pSecondarySubject;
         lTagValueId( 1 ) := 0;
       */
      end if;
      open c1( lAccountId, 'Background' );
      fetch c1 into lSingleTagId;
      found := c1%FOUND;
      close c1;
      if found then
       add_filetag( glbx.truncsurl(surl), file, 'Background', pBackground, null, lSingleTagId );
       /*
         i := i + 1;
         lTagId( i ) := lSingleTagId;
         lTagValue( i ) := pBackground;
         lTagValueId( 1 ) := 0;
       */
      end if;
      /*
      if i > 0 then
         for j in 1..i loop
            lMetaTagList := lMetaTagList || '[' ||
                             lTagId( j ) || ':' ||
                             lTagValue( j ) || '];';
         end loop;
      end if;
      */
      commit;
      addImage( surl, acid, v_umo, footer_api, left_api_parm, current_page_number, 'T', pCategory, pPublicationName, pType, pDistribution, pCirculation );
   end if;

   if pCommand = 'UPLOAD ALL' then
      ctr := 0;
      lAccountId := dapi.getAccountId;
      open c2( lAccountId );
      fetch c2 into lPhotographerId;
      close c2;
      for i in pImageList.first..pImageList.last loop
       if pImageList(i) is not null
        then
         parm1.delete;
         parm2.delete;
         parm1(1)  := 'AID';
         parm2(1)  := to_char(lAccountId);
         parm1(2)  := 'OBJECT_TYPE';
         parm2(2)  := 'PHOTO';
         parm1(3)  := 'LOAD_FROM_FILE_OR_UPLOAD';
         parm2(3)  := 'UPLOAD';
         parm1(4)  := 'FILE_NAME';
         parm2(4)  := pImageList( i );
         parm1(5)  := 'STORE_ORIGINAL';
         parm2(5)  := 'TRUE';
         parm1(6)  := 'CREATE_THUMBNAIL';
         parm2(6)  := 'TRUE';
         parm1(7) := 'KEEP_STATUS';
         parm2(7) := 'KEEP';
         parm1(8) := 'ORIGINAL_LOCATION';
         parm2(8) := pImageList( i );
         parm1(9) := 'PARENT_UMO_ID';
         parm2(9) := NULL;
         parm1(10) := 'SCENE_ID';
         parm2(10) := pScene;
         parm1(11) := 'UMO_OWNER';
         parm2(11) := 'PHOTOGRAPHER';
         parm1(12) := 'BYPASS_QUOTA_CHECK';
         parm2(12) := 'FALSE';
         parm1(13) := 'PHGR_ID';
         parm2(13) := to_char(lPhotographerId);
         parm1(14) := 'OWS_NAME';
         parm2(14) := pImageList( i );
         parm1(15) := 'ROLL_ID';
         parm2(15) := null;
         parm1(16) := 'FILM_SIZE';
         parm2(16) := null;
         parm1(17) := 'FILM_TYPE';
         parm2(17) := null;
         parm1(18) := 'FILM_NAME';
         parm2(18) := glbx.extract_fname(pImageList( i ),'NO_EXTENSION',100);
         parm1(19) := 'THUMBNAIL_WIDTH';
         parm2(19) := nvl(glbx.photo_pref(lPhotographerId,lAccountId,'THUMBNAIL_WIDTH'),'100');
         parm1(20) := 'PHOTOGRAPHER';
         parm2(20) := 'TRUE';
         parm1(21) := 'NAME';
         parm2(21) := pName;
         parm1(22) := 'PHOTO ALBUM';
         parm2(22) := 'FALSE';
         parm1(23) := 'BRIDAL';
         parm2(23) := 'TRUE';
         parm1(24) := 'QUALITY';
         parm2(24) := 'STANDARD';
         parm1(25) := 'COMPRESSION';
         parm2(25) := 'Do not Compress';
         parm1(26) := 'CONVERT_TO';
         parm2(26) := 'JPEG';
         parm1(27) := 'THUMBNAIL_QUALITY';
         parm2(27) := '2';
         /* upload the image */
         retval := NULL;
         ump.load_uma( surl, parm1, parm2, retval, newid_arr ); lnewid := newid_arr(1);
         --htp.p( 'file' || pImageList( i ) );
         --htp.p( 'new id' || lNewId );
         --htp.p( 'retval' || retval );

         /* upload the meta data */
         if retval is null
          then
           ctr := ctr + 1;
           open c3( lNewId );
           fetch c3 into result_list(ctr);
           close c3;
           for c4rec in c4(glbx.truncsurl(surl)) loop
            -- htp.p( c4rec.parm1 || '-' || c4rec.parm2 ); htp.nl;
            parm1.delete;
            parm2.delete;
            parm1(1) := 'UMO_ID';
            parm2(1) := lNewId;
            parm1(2) := 'AID';
            parm2(2) := to_char(lAccountId);
            parm1(3) := 'OBJECT_TYPE';
            parm2(3) := 'PHOTO';
            parm1(4) := 'KEEP_STATUS';
            parm2(4) := 'KEEP';
            parm1(5) := 'ATTRIBUTE_ID';
            parm2(5) := '[' || c4rec.attribute_id || ']' || c4rec.parm2;
            ump.modify_uma(surl,parm1,parm2,retval);
            -- addImage( surl, acid, v_umo, footer_api, left_api_parm, current_page_number, 'T', pCategory, pPublicationName, pType, pDistribution, pCirculation );
           end loop;
          end if;

        end if;

      end loop;
      ltype := dapi.getLoginType;
      glbx.extended_search_api( surl=>surl, ltype=>ltype, result_list=>result_list, search_total=>ctr,
                                display_detail=>'X', title=>'Listing of Loaded Images',
                                left_api=>NULL, left_api_parm=>left_api_parm, footer_api=>'cst.disp_category',
                                current_page_number=>1, no_results_message=>'No Images were Chosen to be Loaded',acid=>acid);

   elsif pCommand = 'REMOVE ALL' then
     execute immediate
      'delete from apache_ows_content where name in (select name from file_upload_metadata where surl = :1)' using glbx.truncsurl(surl);
     execute immediate
      'delete from file_upload_metadata where surl = :1' using glbx.truncsurl(surl);
      commit;
      addImage( surl, acid, v_umo, footer_api, left_api_parm, current_page_number, 'T', pCategory, pPublicationName, pType, pDistribution, pCirculation );

   elsif pCommand = 'REMOVE FROM LIST' then
      for i in pImageList.first..pImageList.last loop
       if pImageList(i) is not null
        then
         execute immediate
          'delete from file_upload_metadata where filename = :1' using  pImageList(i);
         execute immediate
          'delete from apache_ows_content where name = :1' using pImageList(i);
       end if;
       end loop;
      commit;
      addImage( surl, acid, v_umo, footer_api, left_api_parm, current_page_number, 'T', pCategory, pPublicationName, pType, pDistribution, pCirculation );

   end if;

exception when others then
   glbx.error_details( 'MEDIADRIVE', 'PROCESSADDIMAGE', errmsg=>sqlerrm );
end processAddImage;

procedure processSearch( surl varchar2, acid integer, pSearch varchar2, pCategory varchar2, pSearchSubmit varchar2 default null )
as
   pCategories glbx.MYARRAY;
   pImageFrom varchar2(100);
begin
   cst.simple_search(surl, p1=>pSearch, p3=>pCategories, acid=>acid, age=>pImageFrom, umoids=>null);
end processSearch;

procedure advancedSearch( surl varchar2, acid integer, footer_api varchar2, left_api_parm varchar2, current_page_number integer )
as
   stype integer;
   aDummy UMP.SEARCH_RESULT_PHG;
   listBeginPos integer;
   listEndPos integer;
   tList varchar2(4000);
   i integer;
   lFileName varchar2(512);
   ltype login_session.login_type%TYPE;
   cusrec customer_account%ROWTYPE;
   owner_id integer;
   profid integer;
   pfx theme%ROWTYPE;
   theme_rec theme_types%ROWTYPE;
begin
   if not dapi.init( surl, 'MEDIADRIVE.ADVANCEDSEARCH', acid ) then
      dapi.initFailed( surl );
      return;
   end if;
   dapi.setBodyAddition( 'style="margin: 0em; padding: 0em"' );
   dapi.pageOpen;
   ltype := dapi.getLogintype;
   profid := dapi.getAccountId;
   cusrec := dapi.getCustomerAccountRecord;
   owner_id := cusrec.aid;
   pfx := dapi.getLFRecord;
   theme_rec := dapi.getBFRecord;
   htp.tableRowOpen;
   /* Top cell */
   htp.p( '<td colspan="2">' );
   top( surl, acid, footer_api, left_api_parm, current_page_number, aDummy, MD_ADVANCED_SEARCH );
   htp.p( '</td>' );
   htp.tableRowClose;
   /* Left cell */
   htp.tableRowOpen( cattributes=>'valign="top"' );
   htp.p( '<td>' );
   -- disp_meta_query_search(surl in varchar2, ltype in varchar2, owner_id in integer, profid in integer, acid integer, cusrec in customer_account%ROWTYPE, pfx in theme%ROWTYPE, theme_rec in theme_types%ROWTYPE )
   htp.p( '<center>' );
   cst.disp_meta_query_search( surl, ltype, owner_id, profid, acid, cusrec, pfx, theme_rec );
   htp.p( '</center>' );
   htp.p( '</td>' );
   htp.tableRowClose;
   /* Bottom cell */
   htp.tableRowOpen;
   htp.p( '<td colspan="2">' );
   bottom( surl, stype, FALSE );
   htp.p( '</td>' );
   htp.tableRowClose;
   htp.tableClose;
   dapi.pageClose;
end advancedSearch;

end mediadrive;

/
