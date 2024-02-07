CREATE OR REPLACE package body WEBSYS.xscore
as

HARD_CODED_PHOTO_WIDTH   CONSTANT INTEGER := 391;
HARD_CODED_PHOTO_HEIGHT  CONSTANT INTEGER := 316;
HARD_CODED_TNAIL_WIDTH   CONSTANT INTEGER := 180;
HARD_CODED_TNAIL_HEIGHT  CONSTANT INTEGER := 133;
SKIN_LOC	 	 CONSTANT VARCHAR2(50) := 'skin/spi/';
C_BACKIMG	         CONSTANT VARCHAR2(1000) := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || SKIN_LOC || 'spi_bottom.jpg"';
C_ALT	                 CONSTANT VARCHAR2(1000) := '<BODY BACKGROUND="' || DECS.IMAGE_LOCATION || SKIN_LOC || 'spi_gcard.jpg"';
DMASK			 CONSTANT VARCHAR2(100)  := 'DD-MON-YYYY';
START_DATE		 CONSTANT VARCHAR2(100)  := '02-JUL-2003';
GCARD			 CONSTANT INTEGER := 25;
PADWIDTH		 CONSTANT INTEGER := 5;
PROGRAM_INITIAL		 CONSTANT VARCHAR2(20)   := 'spi';
SUBMIT_BUTTON 		 CONSTANT VARCHAR2(40)   := 'login_submit_19h.gif';
TAG_NAME		 CONSTANT VARCHAR2(40)   := ' CAPTION';
TAG_CAT		         CONSTANT VARCHAR2(40)   := 'SOUTH PACIFIC';

NO_RESULTS		 CONSTANT VARCHAR2(1000) := '<b>The Search Returned No Results</b>';
TEXT_HTML		 CONSTANT VARCHAR2(1000) := 'ALIGN="CENTER" VALIGN="TOP" style="text-align: center;"';
TEXT_001		 CONSTANT VARCHAR2(1000) := 'The Photo Code Entered is not a valid number';
TEXT_002		 CONSTANT VARCHAR2(1000) := 'Date';
TEXT_003		 CONSTANT VARCHAR2(1000) := 'Location';
TEXT_004		 CONSTANT VARCHAR2(1000) := 'Photo Code';
TEXT_005		 CONSTANT VARCHAR2(1000) := 'Photo''s taken at';
TEXT_006		 CONSTANT VARCHAR2(1000) := 'No Images Found that Matched your Query';
TEXT_007		 CONSTANT VARCHAR2(1000) := 'Previous Set';
TEXT_008		 CONSTANT VARCHAR2(1000) := 'Next Set';
TEXT_009		 CONSTANT VARCHAR2(1000) := 'Buy Photo';
TEXT_010		 CONSTANT VARCHAR2(1000) := 'Send e-card';

TEXT_013		 CONSTANT VARCHAR2(1000) := 'Search again';
TEXT_014		 CONSTANT VARCHAR2(1000) := 'Your Name';
TEXT_015		 CONSTANT VARCHAR2(1000) := 'Your Email Address';
TEXT_016		 CONSTANT VARCHAR2(1000) := 'Send To Name';
TEXT_017		 CONSTANT VARCHAR2(1000) := 'Send To Email Address';
TEXT_018		 CONSTANT VARCHAR2(1000) := 'Greeting';
TEXT_019		 CONSTANT VARCHAR2(1000) := 'Click here to Reply to';
TEXT_020		 CONSTANT VARCHAR2(1000) := 'Your Electronic Greeting Card has been viewed';

TEXT_021		 CONSTANT VARCHAR2(1000) := 'Card Created';
TEXT_022		 CONSTANT VARCHAR2(1000) := 'Card Successfully Edited';
TEXT_023		 CONSTANT VARCHAR2(1000) := 'Shopping Basket';
TEXT_024		 CONSTANT VARCHAR2(1000) := 'From';
TEXT_025		 CONSTANT VARCHAR2(1000) := 'Photo';
TEXT_026		 CONSTANT VARCHAR2(1000) := 'Enlarge Image';
TEXT_027		 CONSTANT VARCHAR2(1000) := 'Search by';


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

 procedure score_master( vscore in varchar2 default null, action in varchar2 default null, acid in integer )
 as
  cursor c1 is select max(score_id) tot from score_main where aid = acid;
  cursor c2(scid number) is select * from score_main where score_id = scid and aid = acid;
  cursor c3(scid number) is select * from score_details where score_id = scid and aid = acid order by score desc;

  c1rec	c1%ROWTYPE;
  c2rec c2%ROWTYPE;
  c3rec c3%ROWTYPE;

  tot 		 number;
  hscore	 number;
  lscore	 number;
  ctr		 integer;
  c75		 integer;
  c80		 integer;
  c85		 integer;
  c90		 integer;
  c95		 integer;
  diff		 integer;
  avg1		 number;
  fscore	 integer;
  initial_scores GLBX.MYARRAY;

 begin
  if action = 'Refresh' then score_master(acid=>acid); return; end if;
  htp.htmlopen;
  htp.p( '<META HTTP-EQUIV="Refresh" CONTENT="30;URL=xscore.score_master?acid=' || acid || '">');
  open c1;
  fetch c1 into c1rec;
  close c1;
  if vscore is not null or c1rec.tot is null
   then
    c1rec.tot := nvl(c1rec.tot,0) + 1;
    insert into score_main(score_id,score_name,date_created,aid) values (c1rec.tot,nvl(vscore,'Start Score'),sysdate,acid);
    commit;
  end if;
  open c2(c1rec.tot);
  fetch c2 into c2rec;
  close c2;

  htp.header(2,c2rec.score_id || ':' || c2rec.score_name, 'CENTER' );
  htp.header(3,htf.italic(to_char(c2rec.date_created,LNG.TSMASK)), 'CENTER' );
  htp.p( '<CENTER>' );
  htp.tableopen( cattributes=>'cellpadding=3 cellspacing=3 border=1' );
   for c3rec in c3(c1rec.tot) loop
   htp.tablerowopen;
    if c3%ROWCOUNT = 1
     then
      htp.tabledata( c3rec.ipaddress,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
      htp.tabledata( htf.bold(to_char(c3rec.score)),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
     else
      htp.tabledata( c3rec.ipaddress,cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
      htp.tabledata( to_char(c3rec.score),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
    end if;

    htp.tablerowclose;
    initial_scores(c3%ROWCOUNT) := c3rec.score;
   end loop;
   calcscore(initial_scores, c75, c80, c85, c90, c95, tot, hscore, lscore, diff, avg1, fscore );

   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Total' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
    htp.tabledata( htf.bold( tot ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Highest Score' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
    htp.tabledata( htf.bold( hscore ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Lowest Score' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
    htp.tabledata( htf.bold( lscore ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Difference' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
    htp.tabledata( htf.bold( diff ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tablerowclose;

   htp.tablerowopen;
    htp.tabledata( htf.bold('Average' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
    htp.tabledata( htf.bold(to_char(avg1) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
   htp.tablerowclose;
   if fscore is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold('Majority Score' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
      htp.tabledata( htf.bold(to_char(fscore) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
     htp.tablerowclose;
   end if;
  htp.tableclose;
  htp.nl;
  htp.line;
  htp.nl;
  htp.formopen( 'xscore.score_master' );
  htp.formtext( 'VSCORE', 30, 30 );
  htp.formhidden( 'ACID', acid );
  htp.formsubmit( 'ACTION', 'New Score' );
  htp.nl;
  htp.nl;
  htp.formsubmit( 'ACTION', 'Refresh' );
  htp.formclose;
  htp.nl;
  htp.nl;
  htp.header(2,'Powered by Piction','CENTER' );
  htp.p( '</CENTER>' );
  htp.htmlclose;
 exception
  when others
   then
    htp.bold( sqlerrm );
 end score_master;

 procedure scorer( nscore in varchar2 default null, msg in varchar2 default null, action in varchar2 default null, acid in integer )
 as
  cursor c1 is select max(score_id) tot from score_main where aid = acid;
  cursor c2(scid number) is select * from score_main where score_id = scid and aid = acid;
  cursor c3(scid number, ipaddr varchar2) is select * from score_details where score_id = scid and ipaddress = ipaddr and aid = acid;

  c1rec	c1%ROWTYPE;
  c2rec c2%ROWTYPE;
  c3rec c3%ROWTYPE;

  ipaddr varchar2(1000);
  nmb	 integer;

 begin
  if action = 'Refresh' then scorer(acid=>acid); return; end if;
  ipaddr := owa_util.get_cgi_env( 'REMOTE_ADDR');
  htp.htmlopen;
  htp.p( '<META HTTP-EQUIV="Refresh" CONTENT="15;URL=xscore.scorer?acid=' || acid || '">');
  open c1;
  fetch c1 into c1rec;
  close c1;
  if c1rec.tot is null
   then
    htp.bold( 'Entry Not Ready Yet. Wait' );
    htp.htmlclose;
    return;
  end if;
  open c2(c1rec.tot);
  fetch c2 into c2rec;
  close c2;
  if nscore is not null
   then
    begin nmb := to_number(nscore); exception when others then scorer(msg=>'Bad Score Entered',acid=>acid); return; end;
    if nmb < 1 or nmb > 100
     then
      scorer(msg=>'Bad Score Entered. Must be between 1 and 100',acid=>acid);
      return;
    end if;
    delete from score_details where score_id = c1rec.tot and ipaddress = ipaddr and aid = acid;
    insert into score_details(score_id,ipaddress,score,aid) values (c1rec.tot,ipaddr,nmb,acid);
    commit;
  end if;
  open c3(c1rec.tot,ipaddr);
  fetch c3 into c3rec;
  close c3;
  if msg is not null then htp.header(1,msg,'CENTER' ); end if;
  htp.header(2,c2rec.score_id || ':' || c2rec.score_name, 'CENTER' );
  htp.header(3,htf.italic(to_char(c2rec.date_created,LNG.TSMASK)), 'CENTER' );
  htp.p( '<CENTER>' );
  if c3rec.score is null
   then
    htp.formopen( 'xscore.scorer' );
    htp.formhidden( 'ACID', acid );
    htp.formtext( 'NSCORE', 10, 10 );
    htp.formsubmit( null, 'New Score' );
    htp.nl;
    htp.nl;
    htp.nl;
    htp.nl;
    htp.nl;
    htp.nl;
    htp.formsubmit( 'ACTION', 'Refresh' );
    htp.formclose;
   else
    htp.bold( 'Score Entered was: ' || c3rec.score );
    htp.formopen( 'xscore.scorer' );
    htp.formhidden( 'ACID', acid );
    htp.nl;
    htp.nl;
    htp.nl;
    htp.nl;
    htp.nl;
    htp.nl;
    htp.formsubmit( 'ACTION', 'Refresh' );
    htp.formclose;
  end if;

  htp.p( '</CENTER>' );
  htp.nl;
  htp.header(2,'Powered by Piction','CENTER' );
  htp.htmlclose;
 exception
  when others
   then
    htp.bold( sqlerrm );
 end scorer;

procedure err_page( surl in varchar2, errm in varchar2 )
as
begin
 htp.htmlopen;
  htp.p( C_BACKIMG );
   glbx.error_details( 'SPI', 'SKIN',errmsg=>errm);
  htp.p( '</BODY>' );
 htp.htmlclose;
end err_page;

function fixnm( val in varchar2 )
 return varchar2
as
 tmp	varchar2(1000);
 x	integer;
begin
 tmp := replace(replace( val, '.jpg', null ), '.JPG', null );
 x := instr(tmp,'-');
 return( substr(tmp,x+1) );
end fixnm;

procedure initialise_control_buttons( surl in varchar2, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, cusloc in varchar2, dispvert in char, acid integer )
as
begin
 htp.formopen( 'cst.accept_display', ctarget=>cusloc );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'DISPLAY_DETAIL', null );
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
 glbx.error_details( 'SPI', 'INITIALISE_CONTROL_BUTTONS',vaid=>acid,errmsg=>sqlerrm,extdet=>'LEFT_API_PARM:' || left_api_parm);
end initialise_control_buttons;

procedure disp_src( surl in varchar2, acid in integer, cusrec in customer_account%ROWTYPE, stype in integer, pfx in theme%ROWTYPE, left_api_parm in varchar2, search_total in integer, itext in varchar2 )
as
 cursor c1(uscid integer) is select title from umo_scene where umo_scene_id = uscid;
 c1rec  c1%ROWTYPE;
begin
 htp.formclose;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=1 border=1' );
  htp.tablerowopen;
   if substr(left_api_parm,1,1) = '['
    then
     htp.tabledata( '# Results' || ' : ' || search_total, cattributes=>'VALIGN="CENTER" ALIGN="CENTER" style="text-align: center;"' );
    else
     open c1(left_api_parm);
     fetch c1 into c1rec;
     close c1;
     htp.tabledata( 'Category' || ' : ' || c1rec.title, cattributes=>'VALIGN="CENTER" ALIGN="CENTER" style="text-align: center;"' );
   end if;
   htp.p( '<TD VALIGN="CENTER" ALIGN="CENTER" style="text-align: center;">' );
   htp.formopen( 'cst.simple_search' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'P3', '0' );
   htp.formtext( 'P1', 30, 100, null);
   htp.formsubmit( null, LNG.GLB_TXT_092 );
   htp.p( '</TD>' );
   htp.tabledata( htf.anchor( 'cst.acct_search?surl=' || surl || '&acid=' || acid || '&search_call=META', htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'advsrc.gif', cattributes=>'BORDER=0', calt=>'Advanced Search' ) ), cattributes=>'VALIGN="CENTER" ALIGN="CENTER" style="text-align: center;"' );
   htp.formclose;
  htp.tablerowclose;
    htp.tablerowopen;
    if nvl(to_number(itext),0) = 0
     then
       htp.tabledata( '&nbsp;', cattributes=>'colspan="1"' );
     else
       htp.tabledata( 'Images in Basket' || ' : ' || itext, cattributes=>'colspan="1"' );
    end if;
    htp.tabledata( glbx.userpref(cusrec.pid,cusrec.aid,'HELP_SEARCH'), cattributes=>'colspan="2"' );
    htp.tablerowclose;
   htp.tableclose;
end disp_src;

procedure pg(stype in integer, tname in varchar2 default 'DEFAULT')
as
 x integer;
begin
 return;
 -- not used but kept just in case
 begin x := nvl(glbx.sctrl(tname,'DISPLAY_HORIZONTAL',stype),3); exception when others then x := 1; end;
 htp.tablerowopen( cattributes=>'bgcolor="#333333"' );
 htp.p( '<TD colspan="' || x || '" bgcolor="#333333" valign="middle" height="18">' );
  htp.tableopen( cattributes=>'<table width="100%" border="0" cellspacing="1" cellpadding="1"' );
   htp.tablerowopen;
    htp.p( '<td width="559" height="15" valign="middle"> ' );
    htp.p( '<Font face=verdana size=1 color=''red''><b>1</b></font>&nbsp;
    <Font face=verdana size=1 color=''#ffffff''>|</font>&nbsp;
    <a href=''xx''>
    <Font face=verdana size=1 color=white>2</font></a>&nbsp;');
    htp.p( '</td>' );
    htp.p( '<td align="right" width="177" height="15" valign="middle" style="text-align: right;">' );
     htp.p( '<font face="Verdana, Arial, Helvetica, sans-serif" size="1" color="#FFFFFF">Page 1 of 6&nbsp;</font>' );
    htp.p( '</td>' );
   htp.tablerowclose;
  htp.tableclose;
 htp.p('</td>' );

 htp.tablerowclose;

end pg;

procedure delayed_score(surl varchar2, v_umo integer, p1 in varchar2 )
as
 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 nmb 		integer;
 acid		integer;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'XSCORE.DELAYED_SCORE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>null ,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,ispopup=>TRUE);
 htp.nl;
 begin nmb := to_number(p1); exception when others then nmb := null; end;
 if nmb < 0 or nmb > 100 then nmb := null; htp.bold( 'Bad Score Entered:' || p1 ); htp.nl; end if;
 update judge_score
  set score = nmb,
      date_scored = sysdate
 where aid = acid and
       profile_id = (select aid from login_session where sessid = owner_id) and
       umo_id = v_umo;
 if sql%notfound
  then
   insert into judge_score(aid,profile_id,umo_id,score,date_scored)
   select cusrec.aid, aid, v_umo, nmb, sysdate
   from login_session
   where sessid = owner_id;
 end if;
 commit;
 htp.bold( 'Score Set to' || ' : ' || nmb );
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="javascript:top.window.close()">' || LNG.GLB_TXT_033 || '</a>');
 htp.htmlclose;
exception
 when others then htp.bold( 'Score not set: ' || sqlerrm );
end delayed_score;


procedure delayed_score_phg(surl varchar2, v_umo integer, acid in integer, p1 in varchar2 )
as

 cursor c4(acid integer) is select * from judge_novelty where aid = acid;

 cusrec		customer_account%ROWTYPE;
 c4rec		c4%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 nmb 		integer;
begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'XSCORE.DELAYED_SCORE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;
 if ltype <> 'PHOTOGRAPHER' then return; end if;
 open c4(acid);
 fetch c4 into c4rec;
 close c4;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>null ,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,ispopup=>TRUE);
 htp.nl;
 begin nmb := to_number(p1); exception when others then nmb := null; end;
 if nmb < 0 or nmb > 100 then nmb := null; htp.bold( 'Bad Score Entered:' || p1 ); htp.nl; end if;
 update umo_attribute
  set value = nmb,
      date_made = sysdate
 where attribute_id = c4rec.mt_score and
       umo_id = v_umo;
 commit;
 htp.bold( 'Score Set to' || ' : ' || nmb );
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="javascript:top.window.close()">' || LNG.GLB_TXT_033 || '</a>');
 htp.htmlclose;
exception
 when others then htp.bold( 'Score not set: ' || sqlerrm );
end delayed_score_phg;

procedure main_display(surl  varchar2, stype integer, ltype varchar2, umrec UMP.SEARCH_RESULT_PHG, cusrec CUSTOMER_ACCOUNT%ROWTYPE, pfx   THEME%ROWTYPE,
		       theme_rec  theme_types%ROWTYPE, footer_api varchar2, current_page_number  integer default 1, search_total    integer default 0,
		       display_detail  char default null, left_api   varchar2, left_api_parm   varchar2, cusloc varchar2, lbox  varchar2, acid  integer default null,
		       sessid integer, msg   varchar2 )
as

 cursor c2(v_umo integer, attid integer )
  is
   select value
   from umo_attribute uta
   where uta.umo_id = v_umo and
         uta.attribute_id = attid;

cursor c3( sess_id integer ) is select count('x') tot from shopping_basket sb, purchase_order po where po.sessid=sess_id and po.poid = sb.poid;

cursor c4(acid integer) is select * from judge_novelty where aid = acid;

cursor c5(v_umo integer) is select * from umo where umo_id = v_umo;

cursor c6(sess_id integer, acid integer, v_umo integer) is
 select * from judge_score
 where aid = acid and
       umo_id = v_umo and
       profile_id = (select aid from login_session where sessid = sess_id);

cursor c7(sess_id integer, acid integer) is
 select category_restrict
 from judges
 where aid = acid and
       profile_id = (select aid from login_session where sessid = sess_id);

cursor c8(acid integer, v_umo integer) is
 select score,account_name,username
 from judge_score js, customer_profile cp
 where js.aid = acid and
       js.umo_id = v_umo and
       cp.profile_id = js.profile_id
 order by score desc, cp.account_name;

cursor c9(acid integer, v_umo integer) is
 select score,account_name,username
 from score_main js, customer_profile cp, score_details sd
 where js.aid = acid and
       to_number(js.score_name) = v_umo and
       sd.score_id = js.score_id and
       cp.profile_id = to_number(sd.ipaddress)
 order by score desc, cp.account_name;

cursor c10(acid integer, v_umo integer) is select max(score_id) tot from score_main where aid = acid and to_number(score_name) = v_umo;
cursor c11 is select max(score_id) tot from score_main;

  c2rec			c2%ROWTYPE;
  c3rec			c3%ROWTYPE;
  c4rec			c4%ROWTYPE;
  umorec		c5%ROWTYPE;
  c6rec			c6%ROWTYPE;
  c7rec			c7%ROWTYPE;
  c10rec		c10%ROWTYPE;
  c11rec		c11%ROWTYPE;
  nmb			integer;
  ctr			integer;
  x			integer;
  hor_caption		varchar2(4000);
  vhor_caption		varchar2(4000);
  url			varchar2(4000);
  voidrec 		order_style%ROWTYPE;
  hor_but		varchar2(4000);
  display_original	varchar2(100);
  txtclr		varchar2(20);
  xt			varchar2(100);
  lparm			varchar2(100);
  mainid		integer;
  usemap		varchar2(100);
  dspv			integer;
  oth			integer;
  adj			integer;
  isjudge		boolean;
  tot 		 	number;
  hscore	 	number;
  lscore	 	number;
  c75		 	integer;
  c80		 	integer;
  c85		 	integer;
  c90		 	integer;
  c95		 	integer;
  diff		 	integer;
  avg1		 	number;
  fscore	 	integer;
  initial_scores 	GLBX.MYARRAY;

 procedure dispval( v_umo integer, mtid in integer, tg in varchar2 default null )
 as
  c2rec			c2%ROWTYPE;
 begin
  c2rec.value := NULL;
  if mtid is null then return; end if;
  open c2(v_umo, mtid );
  fetch c2 into c2rec;
  close c2;
  if c2rec.value is not null and tg is null then htp.p( c2rec.value ); htp.nl;
  elsif c2rec.value is not null and tg is null then htp.p( tg || ' ' || c2rec.value ); htp.nl;
  end if;
 end dispval;

begin

  htp.init;

  open c4(cusrec.aid);
  fetch c4 into c4rec;
  close c4;

  if c4rec.scoring_system = 'MANUAL' and ltype = 'PHOTOGRAPHER'
   then
    xscore.score_master(acid=>cusrec.aid);
    return;

  elsif c4rec.scoring_system = 'MANUAL'
   then
    xscore.scorer(acid=>cusrec.aid, msg=>'Starting Manual Score System');
    return;

  elsif c4rec.scoring_system = 'REALTIME' and ltype <> 'PHOTOGRAPHER'
   then
    open c7(sessid, cusrec.aid);
    fetch c7 into c7rec;
    isjudge := c7%FOUND;
    close c7;
    if isjudge
     then
      xscore.scorer_realtime(surl=>surl, acid=>cusrec.aid, msg=>'Starting Realtime Scoring System');
      return;
    end if;

  end if;

   glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>null,
   stype=>greatest(stype-nvl(pfx.tnumb_adj,0),1),sstyle=>pfx.text_font,lnk=>pfx.tnail_underline_active,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,
   det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript,
   disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour,
   errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font,
   instfntinc=>pfx.instruct_font_inc, excolour=>pfx.caption_text_colour, exfont=>pfx.caption_text_font,ltype=>ltype,
   small_link=>TRUE,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,
   uline=>pfx.uline, uline_active=>pfx.uline_active, uline_visited=>pfx.uline_visited);

  if left_api_parm is null
   then
    lparm := null;
    mainid := null;
  elsif substr(left_api_parm,1,1) = '['
   then
    mainid := substr(left_api_parm,2,instr(left_api_parm,']')-2);
    lparm := substr(left_api_parm,instr(left_api_parm,']')+1);
  else
   lparm := left_api_parm;
   mainid := null;
  end if;

  -- Mouse over Javascript Links
  htp.print('<SCRIPT LANGUAGE="Javascript">');
  for j in umrec.first..umrec.last loop
   htp.print( 'function turnon' || umrec(j).umo_id || '(img' || umrec(j).umo_id || ') {img' || umrec(j).umo_id || '.src="' ||
    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
    '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
    '&parm1=VERSION&parm2=' || umrec(j).version  || '&parm1=OVERRIDE_DISPLAY&parm2=AUDIO_BW' || '"} ');
   htp.print( 'function turnoff' || umrec(j).umo_id || '(img' || umrec(j).umo_id || '){img' || umrec(j).umo_id || '.src="' ||
    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
    '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
    '&parm1=VERSION&parm2=' || umrec(j).version || '"} ');
  end loop;
  htp.print('</SCRIPT>');

  open c3(sessid);
  fetch c3 into c3rec;
  close c3;

  txtclr := pfx.vert_colour_a;
  display_original := glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL');
  vhor_caption := glbx.userpref( cusrec.pid, cusrec.aid, 'TNAIL_PREF' );
  --disp_src( surl, acid, cusrec, stype, pfx, left_api_parm, search_total, c3rec.tot );
  --initialise_control_buttons( surl, footer_api, left_api_parm, current_page_number, cusloc, null, acid );
  if umrec.count = 0
   then
    htp.p( NO_RESULTS );
    htp.nl;
    htp.nl;
    --htp.anchor( 'cst.acct_search?surl=' || surl || '&acid=' || acid || '&search_call=META', htf.img( DECS.IMAGE_LOCATION || SKIN_LOC || 'advsrc.gif', cattributes=>'BORDER=0', calt=>'Advanced Search' ) );
    htp.p( '</BODY>' );
    return;
  end if;


  htp.tableopen( cattributes=>nvl(pfx.vertical_disp_table,'cellpadding="1" cellspacing="1" border="0" width="100%"') || ' bgcolor="#' || pfx.vert_colour_b || '"' );
  -- pg(stype);
  htp.tablerowopen( cattributes=>'bgcolor="#' || txtclr || '" align="center"');
  ctr := 0;

  -- begin x := nvl(glbx.sctrl(pfx.theme_name,'DISPLAY_HORIZONTAL',stype),3); exception when others then x := 1; end;
  -- Thumbnails get displayed across the screen, main image below.
  htp.p( '<TD>' );
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;

  for j in umrec.first..umrec.last loop

   ctr := ctr + 1;
   xt := null;
   xt := '&parm1=OVERRIDE_DISPLAY&parm2=AUDIO_BW';
   if mainid = umrec(j).umo_id then xt := '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO'; end if;
   if umrec(j).umo_type <> 'PHOTO' then xt := '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO'; end if;

   -- Display Thumbnail
   htp.p( '<TD ' || TEXT_HTML || ' bgcolor="#' || txtclr || '">' );

   url := footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || '[' || umrec(j).umo_id || ']' || translate(lparm,' &','+~') ||
                        '&start_from=' ||  to_char(current_page_number) || '&display_detail=' || display_detail || '&acid=' || acid;
   if ltype = 'PHOTOGRAPHER'
      then
      htp.anchor('phg.phg_modify?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&phgid=' || umrec(j).umo_id || '&footer_api=' || replace(footer_api,' ','+') ||
                  '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail ||
                  '&msg=' || null,
                  '<IMG BORDER=0 WIDTH=' || umrec(j).photo_thumbnail.width || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
                  '&parm1=AID&parm2=' || acid || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=VERSION&parm2=' || umrec(j).version || xt ||
                  '" ALT="' || hor_caption || '"' || 'STYLE="display:block;"' || ' name="opt' || umrec(j).umo_id || '">',
                  cattributes=>'onMouseover="turnoff' || umrec(j).umo_id || '(opt' || umrec(j).umo_id || '); return true;" onMouseout="turnon' || umrec(j).umo_id || '(opt' || umrec(j).umo_id || '); return true;"');
      else
       if umrec(j).umo_type = 'DOCUMENT' then url := 'mydocument.embed_tag?surl=' || surl || '&v_umo=' || umrec(j).umo_id || '&acid=' || umrec(j).aid; end if;
       if mainid = umrec(j).umo_id
        then
         -- Selected Image is Coloured.
         htp.anchor( url,
                  '<IMG BORDER=0 WIDTH=' || umrec(j).photo_thumbnail.width || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
                  '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=VERSION&parm2=' || umrec(j).version || xt ||
                  '" ALT="' || hor_caption || '"' || 'STYLE="display:block;">');
        else
         htp.anchor( url,
                  '<IMG BORDER=0 WIDTH=' || umrec(j).photo_thumbnail.width || ' SRC="' ||
                  'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umrec(j).umo_id ||
                  '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=THUMBNAIL' || '&parm1=LOGIN_TYPE&parm2=' || ltype ||
                  '&parm1=VERSION&parm2=' || umrec(j).version || xt ||
                  '" ALT="' || hor_caption || '"' || 'STYLE="display:block;"' || ' name="opt' || umrec(j).umo_id || '">',
                  cattributes=>'onMouseover="turnoff' || umrec(j).umo_id || '(opt' || umrec(j).umo_id || '); return true;" onMouseout="turnon' || umrec(j).umo_id || '(opt' || umrec(j).umo_id || '); return true;"');
       end if;
   end if;

   htp.nl;
   htp.p( '<font face="' || pfx.text_font || '" color="#' || pfx.text_colour || '" size="1">' );

    htp.p( htf.anchor( url, umrec(j).extras.photo_name ) );
    htp.nl;
    if ltype = 'PHOTOGRAPHER' then dispval(umrec(j).umo_id,c4rec.mt_score); end if;
    dispval(umrec(j).umo_id,c4rec.mt_result);
    dispval(umrec(j).umo_id,c4rec.mt_photographer);

   htp.p( '</font>' );

   /*
    cst.small_buttons(surl, ltype, cusrec, umrec(j), pfx, theme_rec, voidrec, footer_api, left_api_parm, lbox, cusloc, null, current_page_number, acid, hor_but, null, display_original,stype,null );
    htp.p( substr(hor_but,1,length(hor_but)-4) );
    htp.nl;
    htp.nl;
    htp.p( '<font face="' || pfx.text_font || '" color="#' || pfx.text_colour || '" size="1">' || nvl(umrec(j).image_caption,c2rec.value) || '</font>' );
    htp.nl; htp.p( '&nbsp;' );
   */

   htp.p( '</TD>' );

  end loop;
  htp.tablerowclose;
  htp.tableclose;

  htp.p( '</TD>' );
  htp.tablerowclose;

  -- Display Main Image With Meta Data
  if mainid is not null
   then
    open c5(mainid);
    fetch c5 into umorec;
    close c5;
    htp.tablerowopen;
    -- Extract the meta tag values based on
    -- mt_score, mt_result, mt_photographer, mt_date_taken, mt_details, mt_other
    htp.p( '<TD>' );
     htp.line;
     htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
     htp.tablerowopen;
      htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
       -- Meta Data: Name, Score, Result, Photographer, Date Taken.
       htp.p(umorec.extras.photo_name);
       htp.nl;

       -- Realtime Judging can manually enter in their score here, or if a photographer can override the main score
       if c4rec.scoring_system = 'REALTIME' and ltype = 'PHOTOGRAPHER'
        then
         -- Results from Entered Scores
         c2rec.value := NULL;
         open c2(mainid, c4rec.mt_score);
         fetch c2 into c2rec;
         close c2;
         if c2rec.value is null
          then
           -- Set this image to be the new one for viewing
            open c10(acid,mainid);
            fetch c10 into c10rec;
            close c10;
            if c10rec.tot is null
             then
              open c11;
              fetch c11 into c11rec;
              close c11;
              c10rec.tot := nvl(c11rec.tot,0) + 1;
              insert into score_main(score_id,score_name,date_created,aid) values (c10rec.tot,to_char(mainid),sysdate,acid);
              commit;
            end if;
         end if;

         htp.tableopen( cattributes=>'cellpadding=3 cellspacing=3 border=1' );
         for c9rec in c9(acid, mainid) loop
          htp.tablerowopen;
          htp.tabledata( c9rec.account_name,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
          if c9%ROWCOUNT = 1
           then
            htp.tabledata( htf.bold(to_char(c9rec.score)),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
           else
            htp.tabledata( to_char(c9rec.score),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
          end if;
          htp.tablerowclose;
          initial_scores(c9%ROWCOUNT) := c9rec.score;
         end loop;
         calcscore(initial_scores, c75, c80, c85, c90, c95, tot, hscore, lscore, diff, avg1, fscore );
         htp.tablerowopen;
          htp.tabledata( htf.bold( 'Total' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold( tot ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold('Highest Score' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold( hscore ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold('Lowest Score' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold( lscore ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold('Difference' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold( diff ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold('Average' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold(to_char(avg1) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         if fscore is not null
          then
           htp.tablerowopen;
            htp.tabledata( htf.bold('Majority Score' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
            htp.tabledata( htf.bold(to_char(fscore) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
           htp.tablerowclose;
         end if;
         htp.tableclose;
         -- Update Final Score
           htp.formopen( 'xscore.delayed_score_phg', cattributes=>'onsubmit="javascript: window.open('''',''DELALYED_SCORE'',''top=100,left=100,height=300,width=300,location=no,resizable=yes,scrollbars=yes,status=no''); this.target=''DELAYED_SCORE'';"' );
           htp.formhidden( 'SURL', surl );
           htp.formhidden( 'V_UMO', mainid );
           htp.formhidden( 'ACID', acid );
           if c2rec.value is null
            then
             htp.p( 'Score : ' || htf.formtext( 'P1', 10, 20, 'Not Scored' ) );
             htp.nl;
            else
             htp.p( 'Score : ' || htf.formtext( 'P1', 10, 20, c2rec.value ) );
             htp.nl;
           end if;
           htp.formsubmit( null, 'Enter Score' );
           htp.formclose;
           htp.nl;
           url := footer_api || '?surl=' || glbx.rndsurl(surl) || '&left_api_parm=' || '[' || mainid || ']' || translate(lparm,' &','+~') ||
                                '&start_from=' ||  to_char(current_page_number) || '&display_detail=' || display_detail || '&acid=' || acid;
           htp.anchor( url, 'Refresh');

       -- Delayed Judging can manually enter in their score here, or if a photographer can override the main score
       elsif c4rec.scoring_system = 'DELAYED' and ltype = 'PHOTOGRAPHER'
        then
         -- Results from Entered Scores
         htp.tableopen( cattributes=>'cellpadding=3 cellspacing=3 border=1' );
         for c8rec in c8(acid, mainid) loop
          htp.tablerowopen;
          htp.tabledata( c8rec.account_name,cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
          if c8%ROWCOUNT = 1
           then
            htp.tabledata( htf.bold(to_char(c8rec.score)),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
           else
            htp.tabledata( to_char(c8rec.score),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"' );
          end if;
          htp.tablerowclose;
          initial_scores(c8%ROWCOUNT) := c8rec.score;
         end loop;
         calcscore(initial_scores, c75, c80, c85, c90, c95, tot, hscore, lscore, diff, avg1, fscore );
         htp.tablerowopen;
          htp.tabledata( htf.bold( 'Total' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold( tot ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold('Highest Score' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold( hscore ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold('Lowest Score' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold( lscore ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold('Difference' ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold( diff ),cattributes=>GLBX.QUERY_CELL_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         htp.tablerowopen;
          htp.tabledata( htf.bold('Average' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
          htp.tabledata( htf.bold(to_char(avg1) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
         htp.tablerowclose;
         if fscore is not null
          then
           htp.tablerowopen;
            htp.tabledata( htf.bold('Majority Score' ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
            htp.tabledata( htf.bold(to_char(fscore) ),cattributes=>GLBX.QUERY_BACKGROUND || 'valign="CENTER" ALIGN="RIGHT"');
           htp.tablerowclose;
         end if;
         htp.tableclose;
         -- Update Final Score
          c2rec.value := NULL;
          open c2(mainid, c4rec.mt_score);
          fetch c2 into c2rec;
          close c2;
           htp.formopen( 'xscore.delayed_score_phg', cattributes=>'onsubmit="javascript: window.open('''',''DELALYED_SCORE'',''top=100,left=100,height=300,width=300,location=no,resizable=yes,scrollbars=yes,status=no''); this.target=''DELAYED_SCORE'';"' );
           htp.formhidden( 'SURL', surl );
           htp.formhidden( 'V_UMO', mainid );
           htp.formhidden( 'ACID', acid );
           if c2rec.value is null
            then
             htp.p( 'Score : ' || htf.formtext( 'P1', 10, 20, 'Not Scored' ) );
             htp.nl;
            else
             htp.p( 'Score : ' || htf.formtext( 'P1', 10, 20, c2rec.value ) );
             htp.nl;
           end if;
           htp.formsubmit( null, 'Enter Score' );
           htp.formclose;
            htp.p( 'Judging Opened at ' || to_char(c4rec.judging_start, LNG.TSMASK ) );
            htp.nl;
            htp.p( 'Judging Closes at ' || to_char(c4rec.judging_finish, LNG.TSMASK ) );
            htp.nl;

       elsif c4rec.scoring_system = 'DELAYED'
        then
         open c7(sessid, cusrec.aid);
         fetch c7 into c7rec;
         isjudge := c7%FOUND;
         close c7;
         c2rec.value := NULL;
         open c2(mainid, c4rec.mt_score);
         fetch c2 into c2rec;
         close c2;
         if (nvl(c4rec.judging_start,sysdate-1) < sysdate) and
            (nvl(c4rec.judging_finish,sysdate+1) > sysdate) and isjudge and c2rec.value is null
          then
           open c6(sessid, cusrec.aid, mainid);
           fetch c6 into c6rec;
           close c6;
           htp.formopen( 'xscore.delayed_score', cattributes=>'onsubmit="javascript: window.open('''',''DELALYED_SCORE'',''top=100,left=100,height=300,width=300,location=no,resizable=yes,scrollbars=yes,status=no''); this.target=''DELAYED_SCORE'';"' );
           htp.formhidden( 'SURL', surl );
           htp.formhidden( 'V_UMO', mainid );
           if c6rec.score is null
            then
             htp.p( 'Score : ' || htf.formtext( 'P1', 10, 20, 'Not Scored' ) );
             htp.nl;
            else
             htp.p( 'Score : ' || htf.formtext( 'P1', 10, 20, to_char(c6rec.score) ) );
             htp.nl;
           end if;
           htp.formsubmit( null, 'Enter Score' );
           htp.formclose;
           htp.p( 'Judging Opened at ' || to_char(c4rec.judging_start, LNG.TSMASK ) );
           htp.nl;
           htp.p( 'Judging Closes at ' || to_char(c4rec.judging_finish, LNG.TSMASK ) );
           htp.nl;
         elsif isjudge
          then
           open c6(sessid, cusrec.aid, mainid);
           fetch c6 into c6rec;
           close c6;
          if c2rec.value is not null
           then
            htp.bold( 'Photo Offically Scored' );
            htp.nl;
            htp.bold( 'Your Score : ' || nvl(to_char(c6rec.score),'Not Scored') );
            htp.nl;
            htp.bold( 'Offical Score : ' || c2rec.value );
            htp.nl;

          elsif (nvl(c4rec.judging_start,sysdate-1) > sysdate)
           then
            htp.p( 'Judging Opens at ' || to_char(c4rec.judging_start, LNG.TSMASK ) );
            htp.nl;
           else
            htp.p( 'Judging Closed at ' || to_char(c4rec.judging_finish, LNG.TSMASK ) );
            htp.nl;
            if c6rec.score is null
             then
              htp.bold( 'Not Scored' );
              htp.nl;
             else
              dispval(mainid,c4rec.mt_score,'Score : ' || nvl(to_char(c6rec.score),'Not Scored') || '/' );
            end if;
          end if;
         else
          -- Not a judge, so can only view score
          dispval(mainid,c4rec.mt_score,'Score : ');
        end if;

       else
         dispval(mainid,c4rec.mt_score,'Score : ');

       end if;

       dispval(mainid,c4rec.mt_result,'Result : ');
       dispval(mainid,c4rec.mt_photographer,'Photographer : ');
       dispval(mainid,c4rec.mt_date_taken,'Date Taken : ');
      htp.p( '</TD>' );

      htp.p( '<TD>' );
       -- Main Image
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
       if is_bf(theme_rec,ltype,408,408,'T','T') then usemap := glbx.embed_image_map( surl, mainid, adj, acid ); end if;
       if is_bf(theme_rec,ltype,160,161,'T','T') and not (substr(cusrec.zoom_factor,1,9) = 'FFFFFFFFF')
        then
          htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version,
                        '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || usemap || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || acid ||
                        '" ALT="' || umorec.extras.photo_name || '">',ctarget=>'NEW_WINDOW' ), cattributes=>'style="text-align: center;" align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '"' );
        else
          htp.tabledata( '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || ' SRC="' ||
                         'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || acid ||
                         '" ALT="' || umorec.extras.photo_name || '">', cattributes=>'style="text-align: center;" align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '"' );
       end if;
      htp.p( '</TD>' );

      htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
       -- Meta Data: Details, Other
       dispval(mainid,c4rec.mt_details,'Details : ');
       dispval(mainid,c4rec.mt_other,'Other : ');
      htp.p( '</TD>' );
     htp.tablerowclose;
     htp.tableclose;

    htp.p( '</TD>' );
   htp.tablerowclose;
  end if;

  pg(stype,pfx.theme_name);
  htp.tableclose;

  htp.p( '</BODY>' );

exception
 when others then err_page( surl, sqlerrm );
end main_display;

procedure scorer_realtime( surl in varchar2, nscore in varchar2 default null, msg in varchar2 default null, action in varchar2 default null, acid in integer )
 as

 cursor c1 is select max(score_id) tot from score_main where aid = acid;
 cursor c2(scid number) is select * from score_main where score_id = scid and aid = acid;
 cursor c3(scid number, ipaddr varchar2) is select * from score_details where score_id = scid and ipaddress = ipaddr and aid = acid;
 cursor c4(acid integer) is select * from judge_novelty where aid = acid;
 cursor c5(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 c1rec		c1%ROWTYPE;
 c2rec 		c2%ROWTYPE;
 c3rec 		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 umorec		c5%ROWTYPE;
 theme_rec  	theme_types%ROWTYPE;
 nmb	 	integer;

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 dspv		integer;
 oth		integer;
 adj		integer;

 begin
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'XSCORE.SCORER_REALTIME' );
  if sts is not null
   then
    glbx.redisplay_login_page( sts, TRUE );
    return;
  end if;

  if action = 'Refresh' then scorer_realtime(surl=>surl,acid=>acid); return; end if;

  cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
  pfx := glbx.get_thm( cusrec.theme_name );
  theme_rec := glbx.get_theme_types(cusrec.theme_type );

  glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>null ,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,ispopup=>TRUE);
  htp.nl;

  htp.htmlopen;
  htp.p( '<META HTTP-EQUIV="Refresh" CONTENT="15;URL=xscore.scorer_realtime?surl=' || surl || '&acid=' || acid || '">');
  open c1;
  fetch c1 into c1rec;
  close c1;
  if c1rec.tot is null
   then
    htp.nl;
    htp.bold( 'Entry Not Ready Yet. Please Wait' );
    htp.htmlclose;
    return;
  end if;
  open c2(c1rec.tot);
  fetch c2 into c2rec;
  close c2;
  if nscore is not null
   then
    begin nmb := to_number(nscore); exception when others then scorer(msg=>'Bad Score Entered',acid=>acid); return; end;
    if nmb < 1 or nmb > 100
     then
      scorer(msg=>'Bad Score Entered. Must be between 1 and 100',acid=>acid);
      return;
    end if;
    delete from score_details where score_id = c1rec.tot and ipaddress = profid and aid = acid;
    insert into score_details(score_id,ipaddress,score,aid) values (c1rec.tot,profid,nmb,acid);
    commit;
  end if;
  open c3(c1rec.tot,profid);
  fetch c3 into c3rec;
  close c3;
  if msg is not null then htp.header(1,msg,'CENTER' ); end if;
  open c5(to_number(c2rec.score_name),cusrec.aid);
  fetch c5 into umorec;
  close c5;
  htp.header(2,c2rec.score_id || ':' || umorec.extras.photo_name, 'CENTER' );
  htp.header(3,htf.italic(to_char(c2rec.date_created,LNG.TSMASK)), 'CENTER' );
  htp.p( '<CENTER>' );
  if c3rec.score is null
   then
    htp.formopen( 'xscore.scorer_realtime' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'ACID', acid );
    htp.formtext( 'NSCORE', 10, 10 );
    htp.formsubmit( null, 'New Score' );
    htp.nl;
    htp.nl;
    htp.formsubmit( 'ACTION', 'Refresh' );
    htp.formclose;
   else
    htp.bold( 'Score Entered was: ' || c3rec.score );
    htp.formopen( 'xscore.scorer_realtime' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'ACID', acid );
    htp.nl;
    htp.nl;
    htp.formsubmit( 'ACTION', 'Refresh' );
    htp.formclose;
  end if;

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
   htp.tablerowopen;
      htp.p( '<TD>' );
       -- Main Image
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
       if is_bf(theme_rec,ltype,160,161,'T','T') and not (substr(cusrec.zoom_factor,1,9) = 'FFFFFFFFF')
        then
          htp.tabledata( htf.anchor2( 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=DISPLAY_TYPE&parm2=WINDOW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version,
                        '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || ' SRC="' ||
                        'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || acid ||
                        '" ALT="' || umorec.extras.photo_name || '">',ctarget=>'NEW_WINDOW' ), cattributes=>'style="text-align: center;" align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '"' );
        else
          htp.tabledata( '<IMG BORDER=0 HEIGHT=' || to_char(dspv) || ' SRC="' ||
                         'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || acid ||
                         '" ALT="' || umorec.extras.photo_name || '">', cattributes=>'style="text-align: center;" align="CENTER" valign="MIDDLE" bgcolor="#' || pfx.tnail_matte_colour || '" width="' || to_char(oth + nvl(pfx.tnail_width,0)) || '" height="' || to_char(dspv + nvl(pfx.tnail_width,0)) || '"' );
       end if;
      htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

  htp.p( '</CENTER>' );
  htp.nl;
  htp.header(2,'Powered by Piction','CENTER' );
  htp.htmlclose;
 exception
  when others
   then
    htp.bold( sqlerrm );
 end scorer_realtime;

procedure calcscore(initial_scores in GLBX.MYARRAY, c75 out integer, c80 out integer, c85 out integer, c90 out integer, c95 out integer, tot out integer, hscore out integer, lscore out integer, diff out integer, avg1 out number, fscore out integer )
as
 ctr	integer;
begin
  ctr := 0;
  c75 := 0;
  c80 := 0;
  c85 := 0;
  c90 := 0;
  c95 := 0;
  tot := 0;
  hscore := 0;
  lscore := 0;
  diff := 0;
  avg1 := 0;
  fscore := 0;
  if initial_scores.count = 0 then return; end if;

  for j in initial_scores.first..initial_scores.last loop
   tot := tot + nvl(initial_scores(j),0);
   ctr := ctr + 1;
    if j = initial_scores.first
     then
      hscore := initial_scores(j);
      lscore := initial_scores(j);
     else
      if initial_scores(j) > hscore then hscore := initial_scores(j); end if;
      if initial_scores(j) < hscore then lscore := initial_scores(j); end if;
    end if;
    if initial_scores(j) >= 75 and initial_scores(j) <= 79 then c75 := c75 + 1; end if;
    if initial_scores(j) >= 80 and initial_scores(j) <= 84 then c80 := c80 + 1; end if;
    if initial_scores(j) >= 85 and initial_scores(j) <= 89 then c85 := c85 + 1; end if;
    if initial_scores(j) >= 90 and initial_scores(j) <= 94 then c90 := c90 + 1; end if;
    if initial_scores(j) >= 95 and initial_scores(j) <= 100 then c95 := c95 + 1; end if;
   end loop;
   diff := hscore - lscore;
   avg1 := round(tot/ctr,2);
   if c75 >= 3 and ctr > 0
    then
     if avg1 < 75 then fscore := 75; elsif avg1 > 79 then fscore := 79; end if;
   elsif c80 >= 3 and ctr > 0
    then
     if avg1 < 80 then fscore := 80; elsif avg1 > 84 then fscore := 84; end if;
   elsif c85 >= 3 and ctr > 0
    then
     if avg1 < 85 then fscore := 85; elsif avg1 > 89 then fscore := 89; end if;
   elsif c90 >= 3 and ctr > 0
    then
     if avg1 < 90 then fscore := 90; elsif avg1 > 94 then fscore := 94; end if;
   elsif c95 >= 3 and ctr > 0
    then
     if avg1 < 95 then fscore := 95; elsif avg1 > 100 then fscore := 100; end if;
   end if;
   if fscore = 0 then fscore := null; end if;
end calcscore;

end xscore;

/
