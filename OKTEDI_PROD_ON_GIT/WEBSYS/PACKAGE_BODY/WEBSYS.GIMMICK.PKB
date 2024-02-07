CREATE OR REPLACE package body WEBSYS.gimmick
as

function getval( val in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY ) return varchar2;
procedure adjust( pfx in theme%ROWTYPE, stype in integer, cusrec in customer_account%ROWTYPE, umrec in umo%ROWTYPE, wd out integer, hg out integer );
procedure zoom(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure port(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure magnify(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure morph(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure puzzle(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure html_zoom_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure cusobj_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure addname_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure addname(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure addcomment_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure addcomment(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure judge_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );

procedure main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as
begin

 if called_from = 'MAIN' and first_parameter = 'ZOOM'
  then
   zoom(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'MAIN' and first_parameter = 'PORT'
  then
   port(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'MAIN' and first_parameter = 'MAGNIFY'
  then
   magnify(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'MAIN' and first_parameter = 'MORPH'
  then
   morph(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'MAIN' and first_parameter = 'PUZZLE'
  then
   puzzle(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif first_parameter = 'HTML_ZOOM' and called_from = 'PREFERENCES'
  then
   html_zoom_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'MAIN' and first_parameter = 'HTML_ZOOM'
  then
   html_zoom(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, '1', msg );

 elsif called_from = 'PREFERENCES' and first_parameter = 'JUDGE'
  then
   judge_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif first_parameter = 'CUSTOMER_OBJECT' and called_from = 'PREFERENCES'
  then
   cusobj_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif first_parameter = 'CUSTOMER_OBJECT'
  then
   cusobj_cus(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif first_parameter = 'ADDNAME' and called_from = 'PREFERENCES'
  then
   addname_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif first_parameter = 'ADDNAME'
  then
   addname(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif first_parameter = 'ADDCOMMENT' and called_from = 'PREFERENCES'
  then
   addcomment_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif first_parameter = 'ADDCOMMENT'
  then
   addcomment(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'MAIN' and first_parameter = 'IMAGE_MAGICK'
  then
   image_magick(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'PREFERENCES' and first_parameter = 'JUDGE'
  then
   puzzle(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );

 elsif called_from = 'LIGHTBOX'
  then
   null;

 elsif called_from = 'PREFERENCES'
  then
   null;

 end if;

exception when others then
 glbx.error_details( 'GIMMICK', 'MAIN',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end main;

procedure zoom(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 wd		integer;
 hg		integer;
 sts		varchar2(100);
 numb_photos	integer;
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ZOOM' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;
 adjust( pfx, stype, cusrec, c1rec, wd, hg );

htp.htmlopen;
htp.p( '<HEAD>' );
htp.p('
<script language="JavaScript1.2">

//Image zoom in/out script- by javascriptkit.com
//Visit JavaScript Kit (http://www.javascriptkit.com) for script
//Credit must stay intact for use

var zoomfactor=0.05 //Enter factor (0.05=5%)

function zoomhelper(){
if (parseInt(whatcache.style.width)>10&&parseInt(whatcache.style.height)>10){
whatcache.style.width=parseInt(whatcache.style.width)+parseInt(whatcache.style.width)*zoomfactor*prefix
whatcache.style.height=parseInt(whatcache.style.height)+parseInt(whatcache.style.height)*zoomfactor*prefix
}
}

function zoom(originalW, originalH, what, state){
if (!document.all&&!document.getElementById)
return
whatcache=eval("document.images."+what)
prefix=(state=="in")? 1 : -1
if (whatcache.style.width==""||state=="restore"){
whatcache.style.width=originalW
whatcache.style.height=originalH
if (state=="restore")
return
}
else{
zoomhelper()
}
beginzoom=setInterval("zoomhelper()",100)
}

function clearzoom(){
if (window.beginzoom)
clearInterval(beginzoom)
}

</script>' );

htp.p( '</HEAD>' );

glbx.main_title( surl, 'Image Zoom', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
cst.image_object( surl, ltype, cusrec, c1rec, pfx, theme_rec, voidrec, null, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, TRUE );

htp.p( '
<BODY>
<CENTER>
<a href="#" onmouseover="zoom(' || wd || ',' || hg || ',''myimage'',''in'')" onmouseout="clearzoom()">Zoom In</a> | <a href="#" onmouseover="zoom(' || wd || ',' || hg || ',''myimage'',''restore'')">Normal</a> | <a href="#" onmouseover="zoom(' || wd || ',' || hg || ',''myimage'',''out'')" onmouseout="clearzoom()">Zoom Out</a>
</CENTER>
<BR>
<div style="position:relative;width:' || wd || ';height:' || hg || '">
<div style="position:absolute">
<img name="myimage" STYLE="display:block;" src="' ||
'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || loc_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype
|| '">
</div></div>
</BODY>'
);
htp.htmlclose;
exception when others then
 glbx.error_details( 'GIMMICK', 'ZOOM',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end zoom;

procedure port(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 wd		integer;
 hg		integer;
 numb_photos	integer;
 src		varchar2(4000);
 port		varchar2(4000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.PORT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;
 adjust( pfx, stype, cusrec, c1rec, wd, hg );

src := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || loc_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype;
port := DECS.IMAGE_LOCATION || 'gimmick/gimmick_port.gif';
htp.htmlopen;
htp.p(
'
<script language=javaScript>
<!-- Beginning of JavaScript -

bild0 = new Image();
bild0.src = "' || port || '";

bild1 = new Image();
bild1.src = "' || src || '";

var moveimageby
var x
var y
var stopit=0
var speed=5
var timer
var zoomfactor=0.03 //Enter factor (0.05=5%)

function stopmov() {
	stopit=1
}

function showonload() {
	if(document.all) {
		document.all.mainbod.style.posLeft=0
		document.all.preloadinfo.style.posLeft=0
		document.all.behind.style.posLeft=0
		document.all.peep.style.posLeft=0
	}
	else if(document.layers) {
		document.mainbod.left=0
		document.preloadinfo.left=0
		document.behind.left=0
		document.peep.left=0
	}
}

function choosedirection(direction) {
	stopit=0
	moveimageby = direction
	if (moveimageby==''left''){x=speed; y=0}
	if (moveimageby==''right''){x=-speed; y=0}
	if (moveimageby==''up''){x=0; y=speed}
	if (moveimageby==''down''){x=0; y=-speed}
	moveimage()
}

function moveimage() {
	if(document.all && stopit==0) {
		document.all.behind.style.posLeft+=x
		document.all.behind.style.posTop+=y
		timer=setTimeout("moveimage()",100)
	}
	else if(document.layers && stopit==0) {
		document.behind.left+=x
		document.behind.top+=y
		timer=setTimeout("moveimage()",100)
	}
	else {
		clearTimeout(timer)
	}
}

function zoomhelper(){
if (parseInt(whatcache.style.width)>10&&parseInt(whatcache.style.height)>10){
whatcache.style.width=parseInt(whatcache.style.width)+parseInt(whatcache.style.width)*zoomfactor*prefix
whatcache.style.height=parseInt(whatcache.style.height)+parseInt(whatcache.style.height)*zoomfactor*prefix
}
}

function zoom(originalW, originalH, what, state){
if (!document.all&&!document.getElementById)
return
whatcache=eval("document.images."+what)
prefix=(state=="in")? 1 : -1
if (whatcache.style.width==""||state=="restore"){
whatcache.style.width=originalW
whatcache.style.height=originalH
if (state=="restore")
return
}
else{
zoomhelper()
}
beginzoom=setInterval("zoomhelper()",100)
}

function clearzoom(){
if (window.beginzoom)
clearInterval(beginzoom)
}

// - End of JavaScript - -->
</script>' );

htp.p( '</HEAD>' );

glbx.main_title( surl, null, '<body BGCOLOR="#000000">',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

htp.p( '
<CENTER>
<div id="behind" style="position:absolute;visibility:visible;top:0px;left:0px">
<img name="myimage" STYLE="display:block;" src="' || src || '" border=0></div>

<div id="peep" style="position:absolute;visibility:visible;top:0px;left:0px">
<table cellspacing="0" cellpadding="0" border="0">
<tr>
 <td ALIGN="CENTER" BGCOLOR="#000000" colspan="2" >
<H2><font color="#FFFFFF">Image Port Hole View</FONT></H2>
<H3><font color="#FFFFFF">Note: When using zoom, hold down Zoom in to enlarge the image from very small to large</FONT></H3>
 </td>
</tr>
<tr>
 <td>
  <img STYLE="display:block;"  SRC="' || port || '" border=0>
 </td>
 <td width=1500 BGCOLOR="#000000" VALIGN="TOP">
<font color="#FFFFFF">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a style="color: #ffffff" href="#" onMouseOver="choosedirection(''up'')" onMouseOut="stopmov()">Up</a><BR><BR>
<a style="color: #ffffff" href="#" onMouseOver="choosedirection(''left'')" onMouseOut="stopmov()">Left</a> |
<a style="color: #ffffff" href="#" onMouseOver="choosedirection(''right'')" onMouseOut="stopmov()">Right</a><BR><BR>
&nbsp;&nbsp;&nbsp;<a style="color: #ffffff" href="#" onMouseOver="choosedirection(''down'')" onMouseOut="stopmov()">Down</a>
<BR>
<BR>
<BR>
<a style="color: #ffffff" href="#" onmouseover="zoom(' || wd || ',' || hg || ',''myimage'',''in'')" onmouseout="clearzoom()">Zoom In</a>
<BR>
<BR>
<a style="color: #ffffff" href="#" onmouseover="zoom(' || wd || ',' || hg || ',''myimage'',''out'')" onmouseout="clearzoom()">Zoom Out</a>
</FONT>
 </td>
</tr>
<tr>
 <td colspan="2" BGCOLOR="#000000" HEIGHT="800" >&nbsp;
 </td>
</tr>
</table>

</div>
'
);
htp.nl;
--cst.image_object( surl, ltype, cusrec, c1rec, pfx, theme_rec, voidrec, null, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, TRUE );
htp.p( '</CENTER>' );
htp.p( '</BODY>' );
htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'PORT',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end port;

procedure magnify(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 numb_photos	integer;
 wd		integer;
 hg		integer;
 src		varchar2(4000);
 magnify_glass	varchar2(4000);
 frame		varchar2(4000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.MAGNIFY' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;
 adjust( pfx, stype, cusrec, c1rec, wd, hg );

src := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || loc_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype;
magnify_glass := DECS.IMAGE_LOCATION || 'gimmick/gimmick_magnify.gif';
frame := DECS.IMAGE_LOCATION || 'gimmick/gimmick_frame.gif';

htp.htmlopen;
htp.p( '<HEAD>' );
htp.p('
<style type="text/css">
	#mglass {position:absolute;left:-2000;top:50;}
	#thumb {position:absolute;left:-2000;top:50;}
	#large {position:absolute;left:-2000;top:50;}
	#framegif {position:absolute;left:-2000;top:50;}
	.baseline	{
		position:absolute;
		left:50px;
		top:260px;
    	font-family:Arial;
    	font-size:9pt;
		color:000000;
	}
</STYLE>

<SCRIPT LANGUAGE="JavaScript">
<!-- Beginning of JavaScript -
var isNav, isIE
var offsetX, offsetY
var selectedObj

var enlargefactor=5

var largewidth = 455
var largeheight = 523
var largeleft = ' || to_char((c1rec.photo_thumbnail.width * 2) + 60) || '
var largetop = 100

var thumbwidth = Math.floor(largewidth/enlargefactor)
var thumbheight = Math.floor(largeheight/enlargefactor)
var thumbleft = 50
var thumbtop = 100

var mglasswidth = 50
var mglassheight = 50
var mglassleft = 120
var mglasstop = 110

var difleft= largeleft-thumbleft
var diftop= largetop-thumbtop

var clippoints

var cliptop = (thumbheight-mglassheight)*enlargefactor
var clipbottom = cliptop+(mglassheight*enlargefactor)
var clipleft =(thumbwidth-mglasswidth)*enlargefactor
var clipright = clipleft+(mglasswidth*enlargefactor)


if (parseInt(navigator.appVersion) >= 4) {
	if (navigator.appName == "Netscape") {
		isNav = true
	} else {
		isIE = true
	}
}

function setZIndex(obj, zOrder) {
	obj.zIndex = zOrder
}

function shiftTo(obj, x, y) {
	if (isNav) {
		obj.moveTo(x,y)
	} else {
		obj.pixelLeft = x
		obj.pixelTop = y
	}
	cliptop = (y-thumbtop)*enlargefactor
	clipbottom = cliptop+(mglassheight*enlargefactor)
	clipleft = (x-thumbleft)*enlargefactor
	clipright = clipleft+(mglasswidth*enlargefactor)


	if (document.all) {
		clippoints ="rect("+cliptop+" "+clipright+" "+clipbottom+" "+clipleft+")"
		document.all.large.style.posTop=largetop-cliptop
		document.all.large.style.posLeft=largeleft-clipleft
		document.all.large.style.clip=clippoints
	}
	if (document.layers) {
		document.large.top=largetop-cliptop
		document.large.left=largeleft-clipleft
		document.large.clip.left = clipleft
		document.large.clip.right = clipright
		document.large.clip.top = cliptop
		document.large.clip.bottom = clipbottom
	}
}

function setSelectedElem(evt) {
	if (isNav) {
		var testObj
		var clickX = evt.pageX
		var clickY = evt.pageY
		for (var i = document.layers.length - 1; i >= 0; i--) {
			testObj = document.layers[i]
			if ((clickX > testObj.left) &&
				(clickX < testObj.left + testObj.clip.width) &&
				(clickY > testObj.top) &&
				(clickY < testObj.top + testObj.clip.height)) {
					selectedObj = testObj
					setZIndex(selectedObj, 100)
					return
			}
		}
	} else {
		var imgObj = window.event.srcElement
		if (imgObj.parentElement.id.indexOf("mglass") != -1) {
			selectedObj = imgObj.parentElement.style
			setZIndex(selectedObj,100)
			return
		}
	}
	selectedObj = null
	return
}

function dragIt(evt) {
	if (selectedObj) {
		if (isNav) {
			shiftTo(selectedObj, (evt.pageX - offsetX), (evt.pageY - offsetY))
		} else {
			shiftTo(selectedObj, (window.event.clientX - offsetX), (window.event.clientY - offsetY))
			return false
		}
	}
}

function engage(evt) {
	setSelectedElem(evt)
	if (selectedObj) {
		if (isNav) {
			offsetX = evt.pageX - selectedObj.left
			offsetY = evt.pageY - selectedObj.top
		} else {
			offsetX = window.event.offsetX
			offsetY = window.event.offsetY
		}
	}
	return false
}

function release(evt) {
	if (selectedObj) {
		setZIndex(selectedObj, 0)
		selectedObj = null
	}
}

function setNavEventCapture() {
	if (isNav) {
		document.captureEvents(Event.MOUSEDOWN | Event.MOUSEMOVE | Event.MOUSEUP)
	}
}

function init() {

	if (document.layers) {
		document.large.left=largeleft
		document.large.top=largetop

		document.framegif.left=largeleft-3
		document.framegif.top=largetop-3

		document.thumb.left=thumbleft
		document.thumb.top=thumbtop

		document.mglass.left=mglassleft
		document.mglass.top=mglasstop

		document.large.clip.left = 0
		document.large.clip.right = 0
		document.large.clip.top = 0
		document.large.clip.bottom = 0

		setNavEventCapture()
	}

	if (document.all) {
		document.all.large.style.posLeft=largeleft
		document.all.large.style.posTop=largetop

		document.all.framegif.style.posLeft=largeleft-3
		document.all.framegif.style.posTop=largetop-3

		document.all.thumb.style.posLeft=thumbleft
		document.all.thumb.style.posTop=thumbtop

		document.all.mglass.style.posLeft=mglassleft
		document.all.mglass.style.posTop=mglasstop
		document.all.large.style.clip="rect(0 0 0 0)"
	}

	document.onmousedown = engage
	document.onmousemove = dragIt
	document.onmouseup = release
}
// - End of JavaScript - -->
</SCRIPT>' );

htp.p( '</HEAD>' );

glbx.main_title( surl, 'Magnify Image', '<BODY onLoad="init()">',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
htp.p( '<CENTER>' );
cst.image_object( surl, ltype, cusrec, c1rec, pfx, theme_rec, voidrec, null, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, TRUE );

htp.p( '
<H3>Drag the Magnifying glass over the image.</H3>
<DIV ID="thumb"><IMG STYLE="display:block;" NAME="thumbpic" SRC="' || src || '" width=' || to_char(c1rec.photo_thumbnail.width * 2) || '></DIV>
<DIV ID="framegif"><IMG STYLE="display:block;" NAME="framepic" SRC="' || frame || '"></DIV>
<DIV ID="large"><IMG STYLE="display:block;" NAME="largepic" SRC="' || src || '" width=' || to_char(wd * 2) || '></DIV>
<DIV ID="mglass"><IMG STYLE="display:block;" NAME="mglasspic" SRC="' || magnify_glass || '"></DIV>
</CENTER>
</BODY>'
);
htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'MAGNIFY',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end magnify;

procedure morph(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 wd		integer;
 hg		integer;
 sts		varchar2(100);
 numb_photos	integer;
 src		varchar2(4000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.MORPH' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;
 adjust( pfx, stype, cusrec, c1rec, wd, hg );

src := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || loc_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype;

htp.htmlopen;
htp.p( '<HEAD>' );
htp.p('
<script language="JavaScript">

/*

INFORMATION:
============

Copyright 2001 by CodeFoot.com
Free for all users, but leave in this notice

<body onload="iBeReady=true;">

*/

// THE SCRIPT:
// ===========

// sets the default size of the image(s)
defaultXsize = ' || wd || ';
defaultYsize = ' || hg || ';

// sets the minimum size of the image(s)
minimumXsize = ' || c1rec.photo_thumbnail.width || ';
minimumYsize = ' || c1rec.photo_thumbnail.height || ';

// sets the maximum size of the image(s)
maximumXsize = ' || to_char(wd * 2) || ';
maximumYsize = ' || to_char(hg * 2) || ';

// Do not edit below this line.
// ----------------------------

iBeReady =  false;

function dragResizeImage(dragEvent,which){
if (iBeReady){
posX = eval("document."+which+".offsetLeft");
posY = eval("document."+which+".offsetTop");
newXsize = dragEvent.x;
newYsize = dragEvent.y;
newXsize = newXsize - posX;
newYsize = newYsize - posY;
if (newXsize >= maximumXsize) newXsize = maximumXsize;
if (newYsize >= maximumYsize) newYsize = maximumYsize;
if (newXsize <= minimumXsize) newXsize = minimumXsize;
if (newYsize <= minimumYsize) newYsize = minimumYsize;
eval("document."+which+".width=newXsize");
eval("document."+which+".height=newYsize");
}
}

function clickResetImageSize(which){
if (iBeReady){
eval("document."+which+".width=defaultXsize");
eval("document."+which+".height=defaultYsize");
}
}

</script>
<title>Resizable Image</title>

' );

htp.p( '</HEAD>' );

glbx.main_title( surl, 'Image Morph', '<body bgcolor="#FFFFFF" onload="iBeReady=true;"',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
cst.image_object( surl, ltype, cusrec, c1rec, pfx, theme_rec, voidrec, null, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, TRUE );

htp.p( '
<center>
<table>
  <tr>
    <td>
    <font size="2" face="Arial" color="#84A5EF">
    - click, hold, and drag over an image to resize it<br>
    - left-click on an image to return it to default size.
    </font>
    </td>
  </tr>
</table>
<BR>
<img STYLE="display:block;" src="' || src || '"
width="' || wd || '" height="' || hg || '"
name="imageZero"
onDrag="dragResizeImage(event,this.name)"
onClick="clickResetImageSize(this.name)" align="top">

</center>
</body>
</html>
'
);
htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'MORPH',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end morph;

procedure puzzle(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 wd		integer;
 hg		integer;
 sts		varchar2(100);
 numb_photos	integer;
 src		varchar2(4000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.PUZZLE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;
 adjust( pfx, stype, cusrec, c1rec, wd, hg );

src := 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || loc_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype;

htp.htmlopen;
htp.p(
'
<HEAD>
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function Puzzle(q,v,n,W,H,c,g) {
this.mixem=null
this.x=new Array()
this.y=new Array()
this.n=new Array()
this.name=n
this.f=false
this.ma=false
this.g=0
this.w=W/3
this.h=H/3
s=css(n+"kDiv",q,v,W+20,H+60,c)
s+=css(n+"mDiv",10,50,W,H,c)
d=''<DIV ID="''+n+''kDiv"><center><font color=blue size=5>''
d+=''<a href="javascript:''+n+''.scramble()">Scramble</a> or ''
d+=''<a href="javascript:''+n+''.solve()">Solve</a></font></center>\n''
d+=''<DIV ID="''+n+''mDiv">\n''
for(i=0;i<8;i++){
m=n+i
cn1=i
cn2=0
if(cn1>5)cn1-=6,cn2=2
if(cn1>2)cn1-=3,cn2=1
x=this.w*cn1
y=this.h*cn2
s+=css(m+"aDiv",x,y,this.w,this.h,c)
s+=css(m+"bDiv",0-x,0-y,W,H)
d+=''<DIV ID="''+m+''aDiv" onclick="javascript:''+n+''.mov(''+i+'')">''
d+=''<DIV ID="''+m+''bDiv"><img STYLE="display:block;" src=''+g+'' height=''+H+'' width=''+W+''>''
d+=''</div></div>\n''
this.x[i]=cn1
this.y[i]=cn2
this.n[i]=m + "a"
}
d+=''</div></div>\n''
this.x[8]=2
this.y[8]=2
this.s=s
this.d=d
this.getCss  =PuzzleGetCss
this.getDiv  =PuzzleGetDiv
this.move    =PuzzleMove
this.mov     =PuzzleMov
this.scramble=PuzzleSc
this.solve   =PuzzleSolve
this.mixemup =PuzzleSC
this.stop    =PuzzleStop
}
function PuzzleMov(i){if(this.ma)return
eval(this.name+''.move(i)'')
}
function PuzzleStop(){
eval(''clearInterval(''+this.mixem+'')'')
this.ma=false
}
function PuzzleSc(){if(this.ma)return
this.ma=true
eval(''setTimeout("''+this.name+''.stop()",15500)'')
eval(''this.mixem=setInterval("''+this.name+''.mixemup()",300)'')
}
function PuzzleSC(){
this.f=false
while(!this.f){
eval(this.name+''.move(''+this.g+++'')'')
if(this.g==8)this.g=-1}
}
function PuzzleSolve(){if(this.ma)return
for(i=0;i<3;i++){for(j=0;j<3;j++){
if(i*3+j<8)eval(this.n[i*3+j]+''.slideTo(this.w * j,this.h * i)'')
this.y[i*3+j]=i
this.x[i*3+j]=j}}
}
function PuzzleMove(n){
x = this.x[n]
y = this.y[n]
w = this.x[8]
z = this.y[8]
if(((x==w)|(y==z))&(((x-1)==w)|((x+1)==w)|((y-1)==z)|((y+1)==z))){
this.f=true
eval(this.n[n]+''.slideTo(this.w*w,this.h*z)'')
this.x[n] = w
this.y[n] = z
this.x[8] = x
this.y[8] = y}
}
function PuzzleGetCss(){return this.s}
function PuzzleGetDiv(){return this.d}
function init(){DynLayerInit()}
// Dynamic Layer Object
// sophisticated layer/element targeting and animation object which provides the core functionality needed in most DHTML applications
// 19990604

// Copyright (C) 1999 Dan Steinman
// Distributed under the terms of the GNU Library General Public License
// Available at http://www.dansteinman.com/dynapi/

function DynLayer(id,nestref,frame) {
if (!is.ns5 && !DynLayer.set && !frame) DynLayerInit()
this.frame = frame || self
if (is.ns) {
if (is.ns4) {
if (!frame) {
if (!nestref) var nestref = DynLayer.nestRefArray[id]
if (!DynLayerTest(id,nestref)) return
this.css = (nestref)? eval("document."+nestref+".document."+id) : document.layers[id]
}
else this.css = (nestref)? eval("frame.document."+nestref+".document."+id) : frame.document.layers[id]
this.elm = this.event = this.css
this.doc = this.css.document
}
else if (is.ns5) {
this.elm = document.getElementById(id)
this.css = this.elm.style
this.doc = document
}
this.x = this.css.left
this.y = this.css.top
this.w = this.css.clip.width
this.h = this.css.clip.height
}
else if (is.ie) {
this.elm = this.event = this.frame.document.all[id]
this.css = this.frame.document.all[id].style
this.doc = document
this.x = this.elm.offsetLeft
this.y = this.elm.offsetTop
this.w = (is.ie4)? this.css.pixelWidth : this.elm.offsetWidth
this.h = (is.ie4)? this.css.pixelHeight : this.elm.offsetHeight
}
this.id = id
this.nestref = nestref
this.obj = id + "DynLayer"
eval(this.obj + "=this")
}
function DynLayerMoveTo(x,y) {
if (x!=null) {
this.x = x
if (is.ns) this.css.left = this.x
else this.css.pixelLeft = this.x
}
if (y!=null) {
this.y = y
if (is.ns) this.css.top = this.y
else this.css.pixelTop = this.y
}
}
function DynLayerMoveBy(x,y) {
this.moveTo(this.x+x,this.y+y)
}
function DynLayerShow() {
this.css.visibility = (is.ns4)? "show" : "visible"
}
function DynLayerHide() {
this.css.visibility = (is.ns4)? "hide" : "hidden"
}
DynLayer.prototype.moveTo = DynLayerMoveTo
DynLayer.prototype.moveBy = DynLayerMoveBy
DynLayer.prototype.show = DynLayerShow
DynLayer.prototype.hide = DynLayerHide
DynLayerTest = new Function(''return true'')

// DynLayerInit Function
function DynLayerInit(nestref) {
if (!DynLayer.set) DynLayer.set = true
if (is.ns) {
if (nestref) ref = eval(''document.''+nestref+''.document'')
else {nestref = ''''; ref = document;}
for (var i=0; i<ref.layers.length; i++) {
var divname = ref.layers[i].name
DynLayer.nestRefArray[divname] = nestref
var index = divname.indexOf("Div")
if (index > 0) {
eval(divname.substr(0,index)+'' = new DynLayer("''+divname+''","''+nestref+''")'')
}
if (ref.layers[i].document.layers.length > 0) {
DynLayer.refArray[DynLayer.refArray.length] = (nestref=='''')? ref.layers[i].name : nestref+''.document.''+ref.layers[i].name
}
}
if (DynLayer.refArray.i < DynLayer.refArray.length) {
DynLayerInit(DynLayer.refArray[DynLayer.refArray.i++])
}
}
else if (is.ie) {
for (var i=0; i<document.all.tags("DIV").length; i++) {
var divname = document.all.tags("DIV")[i].id
var index = divname.indexOf("Div")
if (index > 0) {
eval(divname.substr(0,index)+'' = new DynLayer("''+divname+''")'')
}
}
}
return true
}
DynLayer.nestRefArray = new Array()
DynLayer.refArray = new Array()
DynLayer.refArray.i = 0
DynLayer.set = false

// Slide Methods
function DynLayerSlideTo(endx,endy,inc,speed,fn) {
if (endx==null) endx = this.x
if (endy==null) endy = this.y
var distx = endx-this.x
var disty = endy-this.y
this.slideStart(endx,endy,distx,disty,inc,speed,fn)
}
function DynLayerSlideBy(distx,disty,inc,speed,fn) {
var endx = this.x + distx
var endy = this.y + disty
this.slideStart(endx,endy,distx,disty,inc,speed,fn)
}
function DynLayerSlideStart(endx,endy,distx,disty,inc,speed,fn) {
if (this.slideActive) return
if (!inc) inc = 20
if (!speed) speed = 20
var num = Math.sqrt(Math.pow(distx,2) + Math.pow(disty,2))/inc
if (num==0) return
var dx = distx/num
var dy = disty/num
if (!fn) fn = null
this.slideActive = true
this.slide(dx,dy,endx,endy,num,1,speed,fn)
}
function DynLayerSlide(dx,dy,endx,endy,num,i,speed,fn) {
if (!this.slideActive) return
if (i++ < num) {
this.moveBy(dx,dy)
this.onSlide()
if (this.slideActive) setTimeout(this.obj+".slide("+dx+","+dy+","+endx+","+endy+","+num+","+i+","+speed+",\""+fn+"\")",speed)
else this.onSlideEnd()
}
else {
this.slideActive = false
this.moveTo(endx,endy)
this.onSlide()
this.onSlideEnd()
eval(fn)
}
}
function DynLayerSlideInit() {}
DynLayer.prototype.slideInit = DynLayerSlideInit
DynLayer.prototype.slideTo = DynLayerSlideTo
DynLayer.prototype.slideBy = DynLayerSlideBy
DynLayer.prototype.slideStart = DynLayerSlideStart
DynLayer.prototype.slide = DynLayerSlide
DynLayer.prototype.onSlide = new Function()
DynLayer.prototype.onSlideEnd = new Function()

// Clip Methods
function DynLayerClipInit(clipTop,clipRight,clipBottom,clipLeft) {
if (is.ie) {
if (arguments.length==4) this.clipTo(clipTop,clipRight,clipBottom,clipLeft)
else if (is.ie4) this.clipTo(0,this.css.pixelWidth,this.css.pixelHeight,0)
}
}
function DynLayerClipTo(t,r,b,l) {
if (t==null) t = this.clipValues(''t'')
if (r==null) r = this.clipValues(''r'')
if (b==null) b = this.clipValues(''b'')
if (l==null) l = this.clipValues(''l'')
if (is.ns) {
this.css.clip.top = t
this.css.clip.right = r
this.css.clip.bottom = b
this.css.clip.left = l
}
else if (is.ie) this.css.clip = "rect("+t+"px "+r+"px "+b+"px "+l+"px)"
}
function DynLayerClipBy(t,r,b,l) {
this.clipTo(this.clipValues(''t'')+t,this.clipValues(''r'')+r,this.clipValues(''b'')+b,this.clipValues(''l'')+l)
}
function DynLayerClipValues(which) {
if (is.ie) var clipv = this.css.clip.split("rect(")[1].split(")")[0].split("px")
if (which=="t") return (is.ns)? this.css.clip.top : Number(clipv[0])
if (which=="r") return (is.ns)? this.css.clip.right : Number(clipv[1])
if (which=="b") return (is.ns)? this.css.clip.bottom : Number(clipv[2])
if (which=="l") return (is.ns)? this.css.clip.left : Number(clipv[3])
}
DynLayer.prototype.clipInit = DynLayerClipInit
DynLayer.prototype.clipTo = DynLayerClipTo
DynLayer.prototype.clipBy = DynLayerClipBy
DynLayer.prototype.clipValues = DynLayerClipValues

// Write Method
function DynLayerWrite(html) {
if (is.ns) {
this.doc.open()
this.doc.write(html)
this.doc.close()
}
else if (is.ie) {
this.event.innerHTML = html
}
}
DynLayer.prototype.write = DynLayerWrite

// BrowserCheck Object
function BrowserCheck() {
var b = navigator.appName
if (b=="Netscape") this.b = "ns"
else if (b=="Microsoft Internet Explorer") this.b = "ie"
else this.b = b
this.version = navigator.appVersion
this.v = parseInt(this.version)
this.ns = (this.b=="ns" && this.v>=4)
this.ns4 = (this.b=="ns" && this.v==4)
this.ns5 = (this.b=="ns" && this.v==5)
this.ie = (this.b=="ie" && this.v>=4)
this.ie4 = (this.version.indexOf(''MSIE 4'')>0)
this.ie5 = (this.version.indexOf(''MSIE 5'')>0)
this.min = (this.ns||this.ie)
}
is = new BrowserCheck()

// CSS Function
function css(id,left,top,width,height,color,vis,z,other) {
if (id=="START") return ''<STYLE TYPE="text/css">\n''
else if (id=="END") return ''</STYLE>''
var str = (left!=null && top!=null)? ''#''+id+'' {position:absolute; left:''+left+''px; top:''+top+''px;'' : ''#''+id+'' {position:relative;''
if (arguments.length>=4 && width!=null) str += '' width:''+width+''px;''
if (arguments.length>=5 && height!=null) {
str += '' height:''+height+''px;''
if (arguments.length<9 || other.indexOf(''clip'')==-1) str += '' clip:rect(0px ''+width+''px ''+height+''px 0px);''
}
if (arguments.length>=6 && color!=null) str += (is.ns)? '' layer-background-color:''+color+'';'' : '' background-color:''+color+'';''
if (arguments.length>=7 && vis!=null) str += '' visibility:''+vis+'';''
if (arguments.length>=8 && z!=null) str += '' z-index:''+z+'';''
if (arguments.length==9 && other!=null) str += '' ''+other
str += ''}\n''
return str
}
function writeCSS(str,showAlert) {
str = css(''START'')+str+css(''END'')
document.write(str)
if (showAlert) alert(str)
}
//  End -->
</script>' );
htp.p( '</HEAD>' );

glbx.main_title( surl, 'Image Puzzle', '<BODY OnLoad="init()">',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
cst.image_object( surl, ltype, cusrec, c1rec, pfx, theme_rec, voidrec, null, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, TRUE );

htp.p( '
<SCRIPT LANGUAGE="JavaScript">

<!-- Begin
puz = new Puzzle(100, 140, ''puz'', ' || wd || ', ' || hg || ', ''#FAFC4A'', ''' || src || ''');

// Name = new Puzzle(Xpos, Ypos, ''Name'', width, height, ''Color'', ''GifPath'');
// Name must be the same in both places GifPath may be relative or absolute

writeCSS( puz.getCss() );
//  End -->
</script>


<script>
document.write( puz.getDiv() ); // change ''puz'' to the name you gave your puzzle above
</script>

<center>
<table>
  <tr>
    <td>
    <font size="2" face="Arial" color="#84A5EF">
    - Choose Scramble to rearrange the pieces, (this will take about 15 seconds)<br>
    - Click on the square to move it. Click Solve if you are stuck.<br>
    </font>
    </td>
  </tr>
</table>
<BR>

</BODY>
</center>
</html>
'
);
htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'PUZZLE',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end puzzle;

procedure adjust( pfx in theme%ROWTYPE, stype in integer, cusrec in customer_account%ROWTYPE, umrec in umo%ROWTYPE, wd out integer, hg out integer )
as
begin
  if umrec.photo_master.width > umrec.photo_master.height
   then
   -- If Zoom disabled do not anchor the image
   if glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
    then
     wd := umrec.photo_master.width;
     hg := umrec.photo_master.height;
    else
     wd := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
     hg := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / umrec.photo_master.width) * umrec.photo_master.height;
   end if;

  else

   if glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL') = LNG.PHG_TXT_045
    then
     hg := umrec.photo_master.height;
     wd := umrec.photo_master.width;
    else
     hg := glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype);
     wd := (glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) / umrec.photo_master.height ) * umrec.photo_master.width;
   end if;
 end if;

end adjust;

procedure html_zoom(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, zoom_factor in varchar2 default '1', msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 crec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 zoom		number;
 retcall	varchar2(10000);
 b2c_value	char(1);
 url		varchar2(4000);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.HTML_ZOOM' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into crec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;

 zoom := to_number(zoom_factor);

 glbx.main_title( surl, crec.extras.photo_name,glbx.backimg(surl,acid,pfx.text_back,cusrec.background_img,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet );
 cst.image_object( surl, ltype, cusrec, crec, pfx, theme_rec, voidrec, null, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, TRUE );
 if crec.umo_type = 'AUDIO'
  then
   htp.title( LNG.GLB_TXT_127 );
  elsif crec.umo_type = 'VIDEO'
  then
   htp.title( LNG.GLB_TXT_128 );
 elsif crec.umo_type = 'DOCUMENT'
  then
   htp.title( LNG.GLB_TXT_129 );
 else
   htp.title( LNG.CST_TXT_072 );
 end if;

 if footer_api is not null
  then
   url := 'href="' || footer_api || '?surl=' || surl || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&display_detail=' || display_detail|| '&start_from=' || current_page_number || '"';
  else
   url := 'href="" onClick="self.close()"';
 end if;

 htp.p('<CENTER>');
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 htp.tablerowopen;

 if nvl(crec.photo_master.contentlength,0) = 0
  then
    htp.tabledata( '<a ' || url || '>' || '<IMG STYLE="display:block;" BORDER=0 SRC=' || DECS.IMAGE_LOCATION || 'admin/audio.gif alt="' || LNG.GLB_TXT_033 || '">' || '</a>' );
  else
   htp.tabledata( '<a ' || url || '>' || '<IMG STYLE="display:block;" BORDER=0 HEIGHT=' || to_char(glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) * nvl(zoom,1)) ||
                    ' SRC=ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || to_char(crec.version) ||
                    ' alt="' || LNG.GLB_TXT_033 || '">' || '</a>' );
 end if;
 htp.tablerowclose;
 htp.tableclose;

 retcall := 'gimmick.html_zoom?surl=' || surl || '&nvid=' || nvid || '&loc_id=' || loc_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ','+');
 if substr(cusrec.zoom_factor,1,1) = 'T' then htp.anchor( retcall || '&zoom_factor=0.25','[x 25%]' ); end if;
 if substr(cusrec.zoom_factor,2,1) = 'T' then htp.anchor( retcall || '&zoom_factor=0.5','[x 50%]' ); end if;
 if substr(cusrec.zoom_factor,3,1) = 'T' then htp.anchor( retcall || '&zoom_factor=0.75','[x 75%]' ); end if;
 if substr(cusrec.zoom_factor,4,1) = 'T' then htp.anchor( retcall || '&zoom_factor=1','[x 1]' ); end if;
 if substr(cusrec.zoom_factor,5,1) = 'T' then htp.anchor( retcall || '&zoom_factor=1.5','[x 1.5]' ); end if;
 if substr(cusrec.zoom_factor,6,1) = 'T' then htp.anchor( retcall || '&zoom_factor=2','[x 2]' ); end if;
 if substr(cusrec.zoom_factor,7,1) = 'T' then htp.anchor( retcall || '&zoom_factor=3','[x 3]' ); end if;
 if substr(cusrec.zoom_factor,8,1) = 'T' then htp.anchor( retcall || '&zoom_factor=4','[x 4]' ); end if;
 if substr(cusrec.zoom_factor,9,1) = 'T' then htp.anchor( retcall || '&zoom_factor=5','[x 5]' ); end if;

 if (crec.audio_original.format is not null)
 then
  --htp.p( '<BODY>' );
  htp.nl;
  if crec.audio_original.format = 'WAV'
   then
    htp.p( '<EMBED SRC="ump.wav?surl=' || glbx.rndsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=OVERRIDE_DISPLAY&parm2=AUDIO">' );
  elsif crec.audio_original.format = 'AIF'
   then
    htp.p( '<EMBED SRC="ump.aiff?surl=' || glbx.rndsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=OVERRIDE_DISPLAY&parm2=AUDIO">' );
  elsif crec.audio_original.format = 'MP3'
   then
    htp.p( '<EMBED  HEIGHT=200 WIDTH=200 SRC="ump.mp3?surl=' || glbx.rndsurl(surl) || '&parm1=UMO_ID&parm2=' || crec.umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=OVERRIDE_DISPLAY&parm2=AUDIO">' );
  end if;
  --htp.p( '</OBJECT>' );
 end if;

 if footer_api is not null
  then
   htp.nl;
   htp.nl;
   htp.anchor( footer_api || '?surl=' || surl || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&display_detail=' || display_detail|| '&start_from=' || current_page_number, LNG2.PFM_TXT_027 ); -- Return to previous screen
 end if;

 htp.p( '</CENTER>' );
 htp.p( '</BODY>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'HTML_ZOOM',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end html_zoom;

procedure html_zoom_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 pfx		THEME%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.HTML_ZOOM_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, 'Modify Zoom Factor',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Modify Zoom Factor' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'gimmick.accept_html_zoom' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 htp.formhidden( 'P3', null );

 -- Zoom Options
 htp.nl;
 htp.bold( LNG4.AHC_TXT_319 );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,1,1) = 'T'
    then
     htp.formcheckbox( 'P3', '1', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '1' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 25%' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,2,1) = 'T'
    then
     htp.formcheckbox( 'P3', '2', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '2' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 50%' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,3,1) = 'T'
    then
     htp.formcheckbox( 'P3', '3', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '3' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 75%' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,4,1) = 'T'
    then
     htp.formcheckbox( 'P3', '4', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '4' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 1' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,5,1) = 'T'
    then
     htp.formcheckbox( 'P3', '5', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '5' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 1.5' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,6,1) = 'T'
    then
     htp.formcheckbox( 'P3', '6', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '6' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 2' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,7,1) = 'T'
    then
     htp.formcheckbox( 'P3', '7', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '7' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 3' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,8,1) = 'T'
    then
     htp.formcheckbox( 'P3', '8', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '8' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 4' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   if substr(cusrec.zoom_factor,9,1) = 'T'
    then
     htp.formcheckbox( 'P3', '9', 'CHECKED' );
    else
     htp.formcheckbox( 'P3', '9' );
   end if;
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'x 5' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Modify HTML Zoom Factors' );
 htp.p( '</CENTER>' );
 htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'HTML_ZOOM_PREF',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end html_zoom_pref;

procedure accept_html_zoom(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, p3 in GLBX.MYARRAY )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_HTML_ZOOM', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

  update customer_account
   set
    zoom_factor = rpad('F',10,'F')
    where
     aid = acid and pid = cusrec.pid;

  for j in p3.first..p3.last loop
   if p3(j) is not null
    then
     update customer_account
      set
       zoom_factor = substr(zoom_factor,1,to_number(p3(j))-1) || 'T' || substr(zoom_factor,to_number(p3(j))+1)
     where
       aid = acid and pid = cusrec.pid;
   end if;
  end loop;

  commit;

  html_zoom_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Zoom Details Modified' );

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_HTML_ZOOM',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_html_zoom;

procedure cusobj_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1 is select distinct theme_type from main_object;
 cursor c2(ttype varchar2) is select * from main_object where theme_type = ttype order by name;
 cursor c3(vid integer) is select name_default from main_value where mid = vid order by name_default;


 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.CUSOBJ_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, 'Modify Customer Object',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Modify Customer Object' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'gimmick.accept_cusobj' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 -- Customer Object
 htp.nl;
 htp.bold( 'Choose the Object to be mapped to the Customer'  );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;

   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   htp.formselectopen( 'P3' );
   htp.formselectoption( NULL );
   for c1rec in c1 loop
    if cusrec.cusobj = c1rec.theme_type
     then
      htp.formselectoption( c1rec.theme_type, 'SELECTED' );
     else
      htp.formselectoption( c1rec.theme_type );
    end if;
   end loop;
   htp.p( '</TD>' );
   htp.formselectclose;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Modify Customer Object' );
 htp.formclose;
 if cusrec.cusobj is not null
  then
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=0' );
   htp.tablerowopen;
   htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
   htp.ulistopen;
   for c2rec in c2(cusrec.cusobj) loop
    htp.listitem(c2rec.name);
    htp.ulistopen;
    for c3rec in c3(c2rec.mid) loop
     htp.listitem( c3rec.name_default );
    end loop;
    htp.ulistclose;
   end loop;
   htp.ulistclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'CUSOBJ_PREF',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end cusobj_pref;

procedure accept_cusobj(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, p3 in varchar2 )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_CUSOBJ', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

  update customer_account
   set
    cusobj = p3
    where
     aid = acid and pid = cusrec.pid;

  commit;

  cusobj_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Details Modified' );

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_CUSOBJ',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_cusobj;

procedure cusobj_cus(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, v_mid in integer default null, msg in varchar2 default null )
as

 cursor c2(vobj varchar2) is
  select mid,name,img
  from main_object mo
  where mo.theme_type = vobj;

 cursor c3(acid integer, vmid integer) is
  select mv.mvid,mv.name_default,mvc.name mvc_name,mvc.response
  from main_value mv, main_value_customer mvc
  where mvc.aid(+) = acid and
        mvc.mvid(+) = mv.mvid and
		mv.mid = vmid
  order by mv.mvid;

 cursor c4(acid integer, vmid integer) is
  select mvc.name,mvc.response
  from main_value_customer mvc, main_value mv
  where mvc.aid = acid and
        mv.mvid = mvc.mvid and
		mv.mid = vmid
  order by mvc.mvid;

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 c2rec		c2%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 vv_mid		integer;
 sts		varchar2(100);
 backcol	varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.CUSOBJ_CUS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, c2rec.name, glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Modify Customer Object' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );

 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 vv_mid := v_mid;
 htp.tablerowopen;
 for c2rec in c2(cusrec.cusobj) loop
  vv_mid := nvl(vv_mid,c2rec.mid);
   htp.tabledata( htf.anchor( 'gimmick.cusobj_cus?surl=' || surl || '&v_mid=' || c2rec.mid || '&nvid=' || nvid || '&loc_id=' || loc_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ','+'), '[' || c2rec.name || ']' ));
 end loop;
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 c2rec.mid := vv_mid;

 if ltype in ('OWNER','PROFILE','PHOTOGRAPHER')
  then
   htp.header(3, lng.CST_TXT_011);
   htp.nl;
   htp.formopen( 'gimmick.accept_manage_object' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'NVID', nvid );
   htp.formhidden( 'V_MID', vv_mid );
   htp.formhidden( 'LOC_ID', loc_id );
   htp.formhidden( 'FIRST_PARAMETER', first_parameter );
   htp.formhidden( 'CALLED_FROM', called_from );
   htp.formhidden( 'FOOTER_API', footer_api );
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
   htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
   htp.formhidden( 'DISPLAY_DETAIL', display_detail );
   htp.formhidden( 'P0', null );
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
   htp.tableopen( cattributes=>' cellpadding=1 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNG.PHG_TXT_022 ),cattributes=>pfx.qcbground);
    htp.tabledata( htf.bold( LNG.PHG_ALT_296 ),cattributes=>pfx.qcbground);
   htp.tablerowclose;
   for c3rec in c3(cusrec.aid,c2rec.mid) loop
     if mod(c3%ROWCOUNT,2) = 0
      then
        backcol := 'bgcolor="#' || nvl(pfx.vert_colour_a,glbx.QUERY_CELL_BACKGROUND1) || '"';
      else
        backcol := 'bgcolor="#' || nvl(pfx.vert_colour_b,glbx.QUERY_CELL_BACKGROUND2) || '"';
     end if;
     htp.tablerowopen;
     htp.formhidden( 'P0', c3rec.mvid );
      htp.tabledata( htf.formtext( 'P1', 30, 100, nvl(c3rec.mvc_name,c3rec.name_default)),cattributes=>backcol);
      htp.tabledata( htf.formtext( 'P2', 30, 100, c3rec.response),cattributes=>backcol);
     htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNG.CST_BUT_017 );
   htp.formsubmit( 'ACTION', LNG.CST_BUT_018 );
   htp.formsubmit( 'ACTION', LNG.CST_BUT_016 );
   htp.formclose;
  else
   htp.p( '<CENTER>' );
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=3 border=0' );
   for c4rec in c4(cusrec.aid,c2rec.mid) loop
     htp.tablerowopen;
      htp.tabledata( htf.bold(c4rec.name) || ':',cattributes=>'ALIGN="RIGHT" ' || backcol);
      htp.tabledata( htf.bold(htf.italic( c4rec.response)),cattributes=>'ALIGN="LEFT" ' || backcol);
     htp.tablerowclose;
   end loop;
   htp.tableclose;
 end if;

 htp.p( '</CENTER>' );
 htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'CUSOBJ_CUS',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end cusobj_cus;

procedure accept_manage_object(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, p0 in GLBX.MYARRAY, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, action in varchar2, v_mid in integer )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 cens_nm	varchar2(100);
 cens_res	varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_MANAGE_OBJECT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 if action = LNG.CST_BUT_016
  then
   if footer_api is null then glbx.acct_home(surl); return; end if;
   owa_util.redirect_url( footer_api || '?surl=' || surl || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&display_detail=' || display_detail|| '&start_from=' || current_page_number|| '&acid=' || acid );
   return;
 end if;

 if ltype not in ('OWNER','PROFILE','PHOTOGRAPHER') then return; end if; -- Someone trying to break in.

 for j in p0.first..p0.last loop
  delete from main_value_customer where aid=c1rec.aid and mvid = p0(j);
  if p1(j) is not null and p2(j) is not null
   then
    cens_nm := substr(glbx.censor( p1(j) ),1,100);
    cens_res := substr(glbx.censor( p2(j) ),1,100);
    insert into main_value_customer(mvid,aid,name,response)
     values
      (p0(j),cusrec.aid,cens_nm,cens_res);
  end if;
 end loop;

 commit;

 if action = LNG.CST_BUT_017
  then
   cusobj_cus(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, v_mid, 'Details Modified' );
 else
   if footer_api is null then glbx.acct_home(surl); return; end if;
   owa_util.redirect_url( footer_api || '?surl=' || surl || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&display_detail=' || display_detail|| '&start_from=' || current_page_number|| '&acid=' || acid );
 end if;

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_MANAGE_OBJECT',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_manage_object;

procedure addname_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ADDNAME_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, 'Options for Adding a Name to an Image',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Options for Adding a Name to an Image' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'gimmick.accept_addname_pref' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( '&nbsp;', cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.tableheader( 'Customer', cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.tableheader( 'Guest', cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Can Insert, Edit and Delete Details', cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   if substr(cusrec.novelty_features,1,1) = 'E'
    then
      htp.tabledata( htf.formradio( 'P1', 'E', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P1', 'E'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
   if substr(cusrec.novelty_features,2,1) = 'E'
    then
      htp.tabledata( htf.formradio( 'P2', 'E', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P2', 'E'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Can View Image Name Details', cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   if substr(cusrec.novelty_features,1,1) = 'T'
    then
      htp.tabledata( htf.formradio( 'P1', 'T', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P1', 'T'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
   if substr(cusrec.novelty_features,2,1) = 'T'
    then
      htp.tabledata( htf.formradio( 'P2', 'T', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P2', 'T'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'No Access to Image Names', cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   if substr(cusrec.novelty_features,1,1) = 'F'
    then
      htp.tabledata( htf.formradio( 'P1', 'F', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P1', 'F'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
   if substr(cusrec.novelty_features,2,1) = 'F'
    then
      htp.tabledata( htf.formradio( 'P2', 'F', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P2', 'F'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Modify Details' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'ADDNAME_PREF',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end addname_pref;

procedure accept_addname_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, p1 in varchar2, p2 in varchar2 )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_ADDNAME_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

  update customer_account
   set
     novelty_features = p1 || p2 || substr(novelty_features,3)
    where
     aid = acid and pid = cusrec.pid;

  commit;

  addname_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Details Modified' );

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_ADDNAME_PREF',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_addname_pref;

procedure addname(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c2(acid integer, utype varchar2, photo_id integer) is
  select *
  from umo um
  where um.aid = acid and
        um.umo_id = photo_id and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'));

 cursor c4(photo_id integer) is
  select ut.value
  from umo_attribute ut, umo_attributes uts
  where ut.attribute_id = uts.attribute_id and
        uts.category = 'IN THE PHOTO' and
        uts.sub_category = 'PERSON' and
        ut.value is not null and
        ut.umo_id = photo_id
  order by ut.position_id;

 cusrec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 vaccess	char(1);
 sts		varchar2(100);
 backcol	varchar2(100);
 retcall	varchar2(10000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ADDNAME', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));

 if ltype = 'PHOTOGRAPHER'
  then
   vaccess := 'E';
 elsif ltype in ('OWNER','PROFILE')
  then
   vaccess := substr(cusrec.novelty_features,1,1);
 else
  vaccess := substr(cusrec.novelty_features,2,1);
 end if;

 open c2(cusrec.aid, ltype, loc_id);
 fetch c2 into c2rec;
 close c2;

 if vaccess = 'F'
  then
    glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C10' ,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.bold( 'This Option is not Available' );
    htp.nl;
    return;
 end if;

 glbx.main_title( surl, LNG.CST_BUT_128, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C10',stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 cst.image_object( surl, ltype, cusrec, c2rec, pfx, theme_rec, voidrec, null, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, TRUE );

 if vaccess = 'E'
  then
   htp.formopen( 'gimmick.accept_addname' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'NVID', nvid );
   htp.formhidden( 'LOC_ID', loc_id );
   htp.formhidden( 'FIRST_PARAMETER', first_parameter );
   htp.formhidden( 'CALLED_FROM', called_from );
   htp.formhidden( 'FOOTER_API', footer_api );
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
   htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
   htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 end if;

 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<td>' );
 retcall := '?surl=' || surl || '&nvid=' || nvid || '&loc_id=' || loc_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ','+');

 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=10' );
  htp.tablerowopen;
   if c2rec.photo_master.width > c2rec.photo_master.height
    then
     htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 WIDTH=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                    '" ALT="' || c2rec.extras.photo_name || '">' );
	else
     htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 HEIGHT=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                    '" ALT="' || c2rec.extras.photo_name || '">' );
   end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</td>' );
  htp.p( '<td bgcolor="#' || glbx.QUERY_CELL_BACKGROUND1 || '" valign="TOP">' );
  htp.tableopen;

 for c4rec in c4( loc_id ) loop
  htp.tablerowopen;
   if vaccess = 'E'
    then
     htp.tabledata( htf.bold( c4%ROWCOUNT ) || '. ' || c4rec.value,cattributes=>pfx.qcbground );
     htp.tabledata( htf.anchor( 'gimmick.delete_name' || retcall || '&nme=' ||translate(c4rec.value,' ','+'), LNG.CST_TXT_140),cattributes=>pfx.qbground );
    else
     htp.tabledata( htf.bold( c4%ROWCOUNT ) || '. ' || c4rec.value,cattributes=>pfx.qcbground );
   end if;
  htp.tablerowclose;
 end loop;

 if vaccess = 'E'
  then
   for j in 1..7 loop
    htp.tablerowopen;
     htp.tabledata( htf.formtext( 'P1', 30, 100, null ) );
    htp.tablerowclose;
   end loop;
 end if;
 htp.tableclose;

 htp.nl;

 htp.p( '</td>' );
 htp.tablerowclose;
 htp.tableclose;

 if vaccess = 'E'
  then
   htp.tableopen;
    htp.tablerowopen;
     htp.tabledata( htf.formsubmit( 'ACTION', LNG.CST_BUT_128 ));
     htp.tabledata( htf.formsubmit( 'ACTION', LNG.CST_BUT_129 ));
    htp.tablerowclose;
   htp.tableclose;
   htp.formclose;
 end if;

 glbx.close_page( pfx );

 htp.p( '</CENTER>' );
 htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'ADDNAME',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end addname;

procedure accept_addname(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, p1 in GLBX.MYARRAY, action in varchar2 )
as

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 temp		varchar2(32767);
 cens_nm	varchar2(100);
 vaccess	char(1);
 parm1		ump.parameters;
 parm2		ump.parameters;
 retval		varchar2(4000);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_ADDNAME', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 if ltype = 'PHOTOGRAPHER'
  then
   vaccess := 'E';
 elsif ltype in ('OWNER','PROFILE')
  then
   vaccess := substr(cusrec.novelty_features,1,1);
 else
  vaccess := substr(cusrec.novelty_features,2,1);
 end if;

 if vaccess <> 'E' then return; end if;

 for j in p1.first..p1.last loop
  if p1(j) is not null
   then
    cens_nm := substr( p1(j),1,100);
    parm1(1) := 'UMO_ID';
    parm2(1) := loc_id;
    parm1(2) := 'AID';
    parm2(2) := cusrec.aid;
    parm1(3) := 'OBJECT_TYPE';
    parm2(3) := 'PHOTO';
    parm1(4) := 'CHECK_EXISTS';
    parm2(4) := 'TRUE';
    parm1(5) := 'PERSON';
    parm2(5) := cens_nm;
    ump.modify_uma(surl,parm1,parm2,retval);
  end if;
 end loop;
 commit;

 if action = LNG.CST_BUT_128
  then
   addname(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Name Details Updated' );
 else
   if footer_api is null then glbx.acct_home(surl); return; end if;
   owa_util.redirect_url( footer_api || '?surl=' || surl || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&display_detail=' || display_detail|| '&start_from=' || current_page_number|| '&acid=' || acid );
 end if;
exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_ADDNAME',vphid=>loc_id,errmsg=>sqlerrm,extdet=>' ACTION:' || action);
end accept_addname;

procedure delete_name(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, nme in varchar2 )
as

 cursor c2(v_umo integer, cg varchar2, sc varchar2) is
  select u.umo_id,u.aid,ua.attribute_id,ua.position_id,ua.value ,u.umo_type
  from umo_attribute ua, umo u, umo_attributes uts
  where ua.umo_id = u.umo_id and
        uts.attribute_id = ua.attribute_id and
        uts.category = cg and
        uts.sub_category = sc and
        ua.umo_id = v_umo;

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 vaccess	char(1);
 sts		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S',progcalled=>'GIMMICK.DELETE_NAME', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 if ltype = 'PHOTOGRAPHER'
  then
   vaccess := 'E';
 elsif ltype in ('OWNER','PROFILE')
  then
   vaccess := substr(cusrec.novelty_features,1,1);
 else
  vaccess := substr(cusrec.novelty_features,2,1);
 end if;
 if vaccess <> 'E' then return; end if;

 for c2rec in c2( loc_id,'COMMENT','PHOTO' ) loop
   if c2rec.umo_type = 'AUDIO'
    then
     myaudio.audio_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'VIDEO'
    then
     myvideo.video_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'RELATIONAL'
    then
     myrelational.relational_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'BLUEPRINT'
    then
     myblueprint.blueprint_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'DOCUMENT'
    then
     mydocument.document_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   end if;
 end loop;

 delete from umo_index
  where attribute_id = (select attribute_id from umo_attributes where category='IN THE PHOTO' and sub_category = 'PERSON') and
        word_original = nme and
        umo_id = loc_id and
        umo_id in (select umo_id from umo where aid = cusrec.aid);
 delete from umo_attribute
  where attribute_id = (select attribute_id from umo_attributes where category='IN THE PHOTO' and sub_category = 'PERSON') and
        value = nme and
        umo_id = loc_id and
        umo_id in (select umo_id from umo where aid = cusrec.aid);

 addname(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Name Details Deleted' );

exception when others then
 glbx.error_details( 'GIMMICK', 'DELETE_NAME', cusrec.aid,loc_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id || ' NME:' || nme);
end delete_name;

procedure addcomment_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ADDCOMMENT_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, 'Options for Adding a Comment to an Image',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Options for Adding a Comment to an Image' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'gimmick.accept_addcomment_pref' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( '&nbsp;', cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.tableheader( 'Customer', cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.tableheader( 'Guest', cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Can Insert, Edit and Delete Details', cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   if substr(cusrec.novelty_features,3,1) = 'E'
    then
      htp.tabledata( htf.formradio( 'P1', 'E', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P1', 'E'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
   if substr(cusrec.novelty_features,4,1) = 'E'
    then
      htp.tabledata( htf.formradio( 'P2', 'E', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P2', 'E'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Can Insert Delete Details Only', cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   if substr(cusrec.novelty_features,3,1) = 'I'
    then
      htp.tabledata( htf.formradio( 'P1', 'I', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P1', 'I'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
   if substr(cusrec.novelty_features,4,1) = 'I'
    then
      htp.tabledata( htf.formradio( 'P2', 'I', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P2', 'I'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Can View Comments Only', cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   if substr(cusrec.novelty_features,3,1) = 'T'
    then
      htp.tabledata( htf.formradio( 'P1', 'T', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P1', 'T'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
   if substr(cusrec.novelty_features,4,1) = 'T'
    then
      htp.tabledata( htf.formradio( 'P2', 'T', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P2', 'T'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'No Access to Comments', cattributes=>pfx.qcbground || ' ALIGN="LEFT"' );
   if substr(cusrec.novelty_features,3,1) = 'F'
    then
      htp.tabledata( htf.formradio( 'P1', 'F', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P1', 'F'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
   if substr(cusrec.novelty_features,4,1) = 'F'
    then
      htp.tabledata( htf.formradio( 'P2', 'F', 'CHECKED'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
    else
      htp.tabledata( htf.formradio( 'P2', 'F'), cattributes=>pfx.qcbground || ' ALIGN="CENTER"' );
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Modify Details' );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'ADDCOMMENT_PREF',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end addcomment_pref;

procedure accept_addcomment_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, p1 in varchar2, p2 in varchar2 )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_ADDCOMMENT_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

  update customer_account
   set
     novelty_features = substr(novelty_features,1,2) || p1 || p2 || substr(novelty_features,5)
    where
     aid = acid and pid = cusrec.pid;

  commit;

  addname_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Details Modified' );

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_ADDCOMMENT_PREF',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_addcomment_pref;

procedure addcomment(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c2(acid integer, utype varchar2, photo_id integer) is
  select *
  from umo um
  where um.aid = acid and
        um.umo_id = photo_id and
        um.umo_type = 'PHOTO' and
        ((utype = 'PHOTOGRAPHER') or
         (utype in ('OWNER','PROFILE') and um.extras.enabled_phg='TRUE') or
         (utype in ('CUSTOMER','PROFILEG') and um.extras.enabled_phg='TRUE' and um.extras.enabled_cus='TRUE'));

 cursor c3(photo_id integer) is
  select ut.position_id,uts.sub_category,ut.value,ut.date_made
  from umo_attribute ut, umo_attributes uts
  where ut.attribute_id = uts.attribute_id and
        uts.category = 'COMMENT' and
        ut.value is not null and
        ut.umo_id = photo_id
  order by ut.position_id,ut.date_made desc;

 cusrec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 vaccess	char(1);
 sts		varchar2(100);
 backcol	varchar2(100);
 hght		integer;
 photo_name	varchar2(100);
 made_by	varchar2(100);
 the_comment	varchar2(1000);
 at_date	date;
 em		varchar2(100);
 isfound	boolean;
 lastpos	integer;
 recctr		integer;
 retcall	varchar2(10000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

 procedure disp_comm(surl varchar2, inctr in integer, ltype in varchar2, v_umo in integer, posi in integer, made_by in varchar2, at_date in date, the_comment in varchar2, em in varchar2, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in varchar2, acid in integer )
 as
    retcall	varchar2(10000);
 begin
     retcall := '?surl=' || surl || '&nvid=' || nvid || '&loc_id=' || loc_id || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ','+');
     htp.tablerowopen;
      htp.tabledata( htf.bold( inctr ) || '.','CUS_RIGHT' );
      if em is null
       then
        htp.tabledata( htf.bold(made_by) || ' ' || htf.italic(to_char(at_date,LNG.TSMASK )) || htf.nl ||
                       the_comment,cattributes=>pfx.qcbground || ' CLASS="SMALL"' );
       else
        htp.tabledata( htf.mailto(em,made_by) || ' ' || htf.italic(to_char(at_date,LNG.TSMASK )) || htf.nl ||
                       the_comment,cattributes=>pfx.qcbground || ' CLASS="SMALL"' );
      end if;
      if vaccess = 'E'
       then
        htp.tabledata( htf.anchor( 'gimmick.delete_comment' || retcall || '&posid=' || posi,LNG.SLD_TXT_004),cattributes=>pfx.qbground );
      end if;
      htp.tablerowclose;
  end disp_comm;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ADDCOMMENT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));

 if ltype = 'PHOTOGRAPHER'
  then
   vaccess := 'E';
 elsif ltype in ('OWNER','PROFILE')
  then
   vaccess := substr(cusrec.novelty_features,3,1);
 else
  vaccess := substr(cusrec.novelty_features,4,1);
 end if;

 open c2(cusrec.aid, ltype, loc_id);
 fetch c2 into c2rec;
 close c2;

 if vaccess = 'F'
  then
    glbx.main_title( surl, null, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C10' ,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
    htp.bold( 'This Option is not Available' );
    htp.nl;
    return;
 end if;

 glbx.main_title( surl, LNG.CST_TXT_141, glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'C10' ,stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, jscript=>pfx.javascript, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,ltype=>ltype,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 cst.image_object( surl, ltype, cusrec, c2rec, pfx, theme_rec, voidrec, null, left_api_parm, current_page_number, acid, display_detail, glbx.userpref(cusrec.pid,cusrec.aid,'DISPLAY_ORIGINAL'), stype, TRUE );

 if vaccess in ('E','I')
  then
   htp.formopen( 'gimmick.accept_addcomment' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'NVID', nvid );
   htp.formhidden( 'LOC_ID', loc_id );
   htp.formhidden( 'FIRST_PARAMETER', first_parameter );
   htp.formhidden( 'CALLED_FROM', called_from );
   htp.formhidden( 'FOOTER_API', footer_api );
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
   htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
   htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 end if;

  htp.tableopen;
  htp.tablerowopen;
  htp.p( '<td>' );
  htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=10' );
  htp.tablerowopen;

  if c2rec.umo_type = 'PHOTO'
   then
   if c2rec.photo_master.width > c2rec.photo_master.height
    then
     htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 WIDTH=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                    '" ALT="' || photo_name || '">' );
     else
     htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 HEIGHT=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                    'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c2rec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || c2rec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                    '" ALT="' || photo_name || '">' );
   end if;
   else
     htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 SRC=' || DECS.IMAGE_LOCATION || 'adminc/audio.gif ALT="' || photo_name || '">' );
  end if;

  htp.tablerowclose;
  htp.tableclose;
  htp.p( '</td>' );
  htp.p( '<td valign="TOP">' );
  htp.tableopen(cattributes=>'cellspacing=1 cellpadding=2 border=1');
  htp.tablerowopen;
  htp.p( '<td bgcolor="#' || glbx.QUERY_CELL_BACKGROUND1 || '" valign="TOP">');
  htp.tableopen(cattributes=>'cellspacing=1 cellpadding=2 border=0');

  the_comment := NULL;
  at_date := NULL;
  made_by := NULL;
  em := NULL;
  lastpos := 0;
  isfound := FALSE;
  for c3rec in c3( loc_id ) loop
   isfound := TRUE;
   if (lastpos <> 0 and lastpos <> c3rec.position_id)
    then
     recctr := nvl(recctr,0) + 1;
     disp_comm( surl,recctr, ltype, c2rec.umo_id, lastpos, made_by, at_date, the_comment, em, footer_api, left_api_parm, current_page_number, display_detail, acid );
     the_comment := NULL;
     at_date := NULL;
     made_by := NULL;
     em := NULL;
   end if;
   lastpos := c3rec.position_id;
   at_date := c3rec.date_made;
   if c3rec.sub_category = 'THE COMMENT'
    then
     the_comment := c3rec.value;
   elsif c3rec.sub_category = 'MADE BY'
    then
     made_by := c3rec.value;
   elsif c3rec.sub_category = 'EMAIL ADDRESS'
    then
     em := c3rec.value;
   end if;
 end loop;

 recctr := nvl(recctr,0) + 1;
 if isfound then disp_comm( surl,recctr, ltype, loc_id, lastpos, made_by, at_date, the_comment, em, footer_api, left_api_parm, current_page_number, display_detail, acid); end if;

  htp.tablerowopen;
   htp.tabledata( htf.bold( lng.CST_TXT_142 ));
   htp.tabledata( htf.formtext('P1',30,100,null));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( lng.CST_TXT_143 ));
   htp.tabledata( htf.formtext('P2',30,100,glbx.get_email(surl)));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( lng.CST_TXT_144 ));
   htp.tabledata(htf.formtextarea( 'P3', 5, 30, cattributes=>'WRAP="VIRTUAL"' ) );
  htp.tablerowclose;
 htp.tableclose;
 htp.p( '</td>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.p( '</td>' );
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if vaccess in ('E','I')
  then
   htp.tableopen;
    htp.tablerowopen;
     htp.tabledata( htf.formsubmit( 'ACTION', LNG.CST_BUT_146 ));
     htp.tabledata( htf.formsubmit( 'ACTION', LNG.CST_BUT_129 ));
    htp.tablerowclose;
   htp.tableclose;
   htp.formclose;
 end if;

 glbx.close_page( pfx );

 htp.p( '</CENTER>' );
 htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'ADDCOMMENT',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end addcomment;

procedure accept_addcomment(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, p1 in varchar2, p2 in varchar2, p3 in varchar2, action in varchar2 )
as

 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 temp		varchar2(32767);
 cens_nm	varchar2(100);
 vaccess	char(1);
 parm1		ump.parameters;
 parm2		ump.parameters;
 retval		varchar2(4000);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_ADDCOMMENT', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 if ltype = 'PHOTOGRAPHER'
  then
   vaccess := 'E';
 elsif ltype in ('OWNER','PROFILE')
  then
   vaccess := substr(cusrec.novelty_features,3,1);
 else
  vaccess := substr(cusrec.novelty_features,4,1);
 end if;

 if vaccess not in ('E','I') then return; end if;

 if p3 is not null
  then
   parm1(1) := 'UMO_ID';
   parm2(1) := loc_id;
   parm1(2) := 'AID';
   parm2(2) := cusrec.aid;
   parm1(3) := 'OBJECT_TYPE';
   parm2(3) := 'PHOTO';
   parm1(4) := 'CHECK_EXISTS';
   parm2(4) := 'COMMENT';
   parm1(5) := 'MADE BY';
   parm2(5) := substr( nvl(p1,LNG.CST_TXT_007),1,100);
   parm1(6) := 'EMAIL ADDRESS';
   parm2(6) := substr( nvl(p2,LNG.CST_TXT_007),1,100);
   parm1(7) := 'THE COMMENT';
   parm2(7) := substr( p3,1,4000);
   ump.modify_uma(surl,parm1,parm2,retval);
 end if;
 commit;

 if action = LNG.CST_BUT_146
  then
   addcomment(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Comments Updated' );
 else
   if footer_api is null then glbx.acct_home(surl); return; end if;
   --htp.p( footer_api || '?surl=' || surl || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&display_detail=' || display_detail|| '&start_from=' || current_page_number );
   --return;
   owa_util.redirect_url( footer_api || '?surl=' || surl || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&display_detail=' || display_detail|| '&start_from=' || current_page_number || '&acid=' || acid );
 end if;

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_ADDCOMMENT',vphid=>loc_id,errmsg=>sqlerrm,extdet=>' ACTION:' || action);
end accept_addcomment;

procedure delete_comment(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, posid in integer )
as

 cursor c2(v_umo integer, cg varchar2, sc varchar2) is
  select u.umo_id,u.aid,ua.attribute_id,ua.position_id,ua.value ,u.umo_type
  from umo_attribute ua, umo u, umo_attributes uts
  where ua.umo_id = u.umo_id and
        uts.attribute_id = ua.attribute_id and
        uts.category = cg and
        uts.sub_category = sc and
        ua.umo_id = v_umo;

 cusrec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 vaccess	char(1);
 sts		varchar2(100);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, 'S',progcalled=>'GIMMICK.DELETE_COMMENT, iscust=>FALSE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 for c2rec in c2( loc_id,'COMMENT','PHOTO' ) loop
   if c2rec.umo_type = 'AUDIO'
    then
     myaudio.audio_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'VIDEO'
    then
     myvideo.video_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'RELATIONAL'
    then
     myrelational.relational_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'BLUEPRINT'
    then
     myblueprint.blueprint_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   elsif c2rec.umo_type = 'DOCUMENT'
    then
     mydocument.document_api(v_umo=>c2rec.umo_id,attrib_id=>c2rec.attribute_id,data_value=>c2rec.value,acid=>cusrec.aid,posid=>nvl(c2rec.position_id,1),action=>'DELETE');
   end if;
 end loop;

 delete from umo_index
  where attribute_id in (select attribute_id from umo_attributes where category='COMMENT' and umo_type = 'PHOTO') and
        position_id = posid and
        umo_id = loc_id and
        umo_id in (select umo_id from umo where aid = cusrec.aid);
 delete from umo_attribute
  where attribute_id in (select attribute_id from umo_attributes where category='COMMENT' and umo_type = 'PHOTO') and
        position_id = posid and
        umo_id = loc_id and
        umo_id in (select umo_id from umo where aid = cusrec.aid);

 if ltype = 'PHOTOGRAPHER'
  then
   vaccess := 'E';
 elsif ltype in ('OWNER','PROFILE')
  then
   vaccess := substr(cusrec.novelty_features,3,1);
 else
  vaccess := substr(cusrec.novelty_features,4,1);
 end if;
 if vaccess <> 'E' then return; end if;


 addcomment(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Comments Deleted' );

exception when others then
 glbx.error_details( 'GIMMICK', 'DELETE_COMMENT', cusrec.aid,loc_id,errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id || ' POSID:' || posid);
end delete_comment;

procedure image_vote(surl in varchar2, loc_id in integer, footer_api in varchar2 default null, left_api_parm in varchar2 default null, current_page_number in integer default null, display_detail in char default null, acid in integer, first_parameter in varchar2 default null, called_from in varchar2 default null, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;
 cursor c2(sess_id integer) is select * from image_vote where sessid = sess_id;
 cursor c3(sess_id integer) is select * from purchase_order where sessid = sess_id;

 fl 		UTL_FILE.FILE_TYPE;
 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 wd		integer;
 hg		integer;
 sts		varchar2(100);
 numb_photos	integer;
 b2c_value	char(1);
 nl		boolean;
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 bfr		varchar2(25000);
 err		boolean;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.IMAGE_VOTE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 err := FALSE;
 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;

 open c2( owner_id );
 fetch c2 into c2rec;
 close c2;
 open c3( owner_id );
 fetch c3 into c3rec;
 close c3;

 begin
  if voidrec.login_html_subdir is null
   then
    fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style', 'vote_display.html', 'r', 25000 );
   else
    fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || voidrec.login_html_subdir, 'vote_display.html', 'r', 25000 );
  end if;
 exception
  when others then
   glbx.main_title( surl, 'Vote for this Image', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.p( '<CENTER>' );
   htp.nl;
   err := TRUE;
 end;

 if not err
  then
   loop
    begin
     utl_file.get_line( fl, bfr );
     if upper(trim(bfr)) = '<PICTION_IMAGE>'
      then
       htp.p('<img name="myimage" STYLE="display:block;" src="' || 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || loc_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '">' );
     elsif upper(trim(bfr)) = '<PICTION_CONTACT>'
      then
       exit;
     else
       htp.p( bfr );
     end if;
    exception
     when others
      then
       utl_file.fclose( fl );
       return;
     end;
   end loop;
 end if;

 htp.formopen( 'gimmick.accept_image_vote' );
 htp.formhidden( 'SURL', surl);
 htp.formhidden( 'LOC_ID', loc_id);
 htp.formhidden( 'FOOTER_API', footer_api);
 htp.formhidden( 'LEFT_API_PARM', left_api_parm);
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number);
 htp.formhidden( 'DISPLAY_DETAIL', display_detail);
 htp.formhidden( 'ACID', acid);
 htp.formhidden( 'FIRST_PARAMETER', first_parameter);
 htp.formhidden( 'CALLED_FROM', called_from);
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 nl := FALSE;

 htp.bold( 'Please Confirm Your Contact Details' );
 htp.tableopen( cattributes=>pfx.order_nocol_table || ' cellpadding=2 cellspacing=2 rules="NONE" frame="HSIDES,VSIDES" border=' || pfx.ord_text_table_border );
  fname.disp_cust_details(surl=>surl, stype=>stype, sess_id=>owner_id, ltype=>ltype, acid=>acid, profid=>profid, cusrec=>cusrec, pfx=>pfx, theme_rec=>theme_rec, purchord=>c3rec, voidrec=>voidrec, browser_edit=>'EDIT', newline=>nl, onecol=>TRUE);
 htp.tableclose;

 htp.line;
 htp.nl;
 if c2rec.umo_id is null
  then
   htp.formsubmit( 'ACTION', 'Vote for this Image' );
  else
   htp.formsubmit( 'ACTION', 'Cancel Previous Vote and Vote for this Image' );
 end if;

 htp.formclose;

 if not err
  then
   loop
    begin
     utl_file.get_line( fl, bfr );
     if upper(trim(bfr)) = '<PICTION_IMAGE>'
      then
       htp.p('<img name="myimage" STYLE="display:block;" src="' || 'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || loc_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=AID&parm2=' || acid || '&parm1=LOGIN_TYPE&parm2=' || ltype || '">' );
      else
       htp.p( bfr );
     end if;
    exception
     when others
      then
       utl_file.fclose( fl );
       return;
     end;
   end loop;
  else
   htp.p( '</CENTER>' );
   htp.htmlclose;
 end if;

exception when others then
 glbx.error_details( 'GIMMICK', 'IMAGE_VOTE',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end image_vote;

function getval( val in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
  return varchar2
 as
 begin
  for j in p1.first..p1.last loop
   if p1(j) = val
    then
     return( p2(j) );
   end if;
  end loop;
  return( NULL );
end getval;

procedure accept_image_vote(surl in varchar2, loc_id in integer, footer_api in varchar2 default null, left_api_parm in varchar2 default null, current_page_number in integer default null, display_detail in char default null, acid in integer, first_parameter in varchar2 default null, called_from in varchar2 default null, action in varchar2, p1 in glbx.myarray, p2 in glbx.myarray )
as

 cursor c3(sess_id integer) is select * from purchase_order where sessid = sess_id;
 cursor c4(loc_id integer) is select * from umo where umo_id = loc_id;

 fl 		UTL_FILE.FILE_TYPE;
 cusrec		customer_account%ROWTYPE;
 purchrec	purchase_order%ROWTYPE;
 umorec		c4%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 wd		integer;
 hg		integer;
 sts		varchar2(100);
 numb_photos	integer;
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 bfr		varchar2(25000);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_IMAGE_VOTE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));

 delete from image_vote where sessid = owner_id;
 insert into image_vote(umo_id,sessid,date_created,pid,aid,score) values
  (loc_id,owner_id,sysdate,cusrec.pid,cusrec.aid,null);
 commit;

 open c3(owner_id);
 fetch c3 into purchrec;
 close c3;

 open c4(loc_id);
 fetch c4 into umorec;
 close c4;

  purchrec.sendto_name := trim(getval( '6-NAME', p1, p2 ));
  purchrec.sendto_street := trim(getval( '6-STREET', p1, p2 ));
  purchrec.sendto_branch := trim(getval( '6-BRANCH', p1, p2 ));
  purchrec.sendto_department := trim(getval( '6-DEPARTMENT', p1, p2 ));
  purchrec.sendto_suburb := trim(getval( '6-SUBURB', p1, p2 ));
  purchrec.sendto_city := trim(getval( '6-CITY', p1, p2 ));
  purchrec.sendto_postcode := trim(getval( '6-POSTCODE', p1, p2 ));
  purchrec.sendto_state := trim(getval( '6-STATE', p1, p2 ));
  purchrec.sendto_country := trim(getval( '6-COUNTRY', p1, p2 ));
  purchrec.contact_phone := trim(getval( '6-PHONE', p1, p2 ));
  purchrec.contact_email := getval( '6-EMAIL', p1, p2 );
  purchrec.customer_comment := trim(getval( '6-CUSTOMER_COMMENT', p1, p2 ));
  purchrec.customer_column1 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN1', p1, p2 ),100));
  purchrec.customer_column2 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN2', p1, p2 ),100));
  purchrec.customer_column3 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN3', p1, p2 ),100));
  purchrec.customer_column4 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN4', p1, p2 ),100));
  purchrec.customer_column5 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN5', p1, p2 ),100));
  purchrec.customer_column6 := trim(glbx.censor(getval( '6-CUSTOMER_COLUMN6', p1, p2 ),100));

  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_NAME', 'U', 'C', purchrec.sendto_name, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_STREET', 'U', 'C', purchrec.sendto_street, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_BRANCH', 'U', 'C', purchrec.sendto_branch, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_DEPARTMENT', 'U', 'C', purchrec.sendto_department, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_SUBURB', 'U', 'C', purchrec.sendto_suburb, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_CITY', 'U', 'C', purchrec.sendto_city, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_POSTCODE', 'U', 'C', purchrec.sendto_postcode, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_STATE', 'U', 'C', purchrec.sendto_state, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'SENDTO_COUNTRY', 'U', 'C', purchrec.sendto_country, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CONTACT_PHONE', 'U', 'C', purchrec.contact_phone, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CONTACT_EMAIL', 'U', 'C', purchrec.contact_email, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COMMENT', 'U', 'C', purchrec.customer_comment, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN1', 'U', 'C', purchrec.customer_column1, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN2', 'U', 'C', purchrec.customer_column2, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN3', 'U', 'C', purchrec.customer_column3, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN4', 'U', 'C', purchrec.customer_column4, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN5', 'U', 'C', purchrec.customer_column5, purchrec, voidrec);
  fname.purchase_audit_trail( surl, purchrec.poid, 'CUSTOMER_COLUMN6', 'U', 'C', purchrec.customer_column6, purchrec, voidrec);
  glbx.fixnm(purchrec.sendto_name,purchrec.sendto_firstname,purchrec.sendto_lastname);
  update purchase_order
   set
    sendto_name = purchrec.sendto_name,
    sendto_firstname = purchrec.sendto_firstname,
    sendto_lastname = purchrec.sendto_lastname,
    sendto_street = purchrec.sendto_street,
    sendto_suburb = purchrec.sendto_suburb,
    sendto_branch = purchrec.sendto_branch,
    sendto_department = purchrec.sendto_department,
    sendto_city = purchrec.sendto_city,
    sendto_postcode = purchrec.sendto_postcode,
    sendto_state = purchrec.sendto_state,
    sendto_country = purchrec.sendto_country,
    contact_phone = purchrec.contact_phone,
    contact_email = purchrec.contact_email,
    customer_comment = purchrec.customer_comment,
    customer_column1 = purchrec.customer_column1,
    customer_column2 = purchrec.customer_column2,
    customer_column3 = purchrec.customer_column3,
    customer_column4 = purchrec.customer_column4,
    customer_column5 = purchrec.customer_column5,
    customer_column6 = purchrec.customer_column6
  where
   poid = purchrec.poid;

  commit;

   begin
    if voidrec.login_html_subdir is null
     then
      fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style', 'vote_confirm.html', 'r', 25000 );
     else
      fl := utl_file.fopen( glbx.extract_master_parameter('IMAGE_DIR') || DECS.UNIX_OR_NT || 'order_style' || DECS.UNIX_OR_NT || voidrec.login_html_subdir, 'vote_confirm.html', 'r', 25000 );
    end if;
   exception
    when others then
     glbx.main_title( surl, 'Vote Confirmed', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
     htp.p( '<CENTER>' );
     htp.nl;
     htp.nl;
     htp.bold( 'Your Vote has Been Recorded' );
     htp.nl;
     htp.nl;
     htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
     htp.nl;
     htp.p( '</CENTER>' );
     htp.htmlclose;
     return;
   end;

   loop
    begin
     utl_file.get_line( fl, bfr );
     htp.p( replace(replace(replace(bfr,'<PICTION_IMAGE_ID>',loc_id),'<PICTION_SURL>', surl ),'<PICTION_IMAGE_NAME>',umorec.extras.film_name) );
    exception
     when others
      then
       utl_file.fclose( fl );
       return;
     end;
   end loop;

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_IMAGE_VOTE',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_image_vote;

procedure image_magick(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;
 cursor c2 is select * from image_magick_definition;

 cusrec		customer_account%ROWTYPE;
 umorec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 zoom		number;
 retcall	varchar2(10000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.IMAGE_MAGICK' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into umorec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;

 glbx.main_title( surl, 'Image Special Effect', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;

 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<td>' );
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=10' );
 htp.tablerowopen;

 if umorec.umo_type = 'PHOTO'
  then
  if umorec.photo_master.width > umorec.photo_master.height
   then
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 WIDTH=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                   '" ALT="' || umorec.extras.photo_name || '">' );
    else
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 HEIGHT=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                   '" ALT="' || umorec.extras.photo_name || '">' );
  end if;
  else
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 SRC=' || DECS.IMAGE_LOCATION || 'adminc/audio.gif ALT="' || umorec.extras.photo_name || '">' );
 end if;

 htp.tablerowclose;
 htp.tableclose;

 htp.nl;

 htp.formopen( 'gimmick.accept_image_magick' );
 htp.formhidden( 'SURL', surl);
 htp.formhidden( 'NVID', nvid);
 htp.formhidden( 'LOC_ID', loc_id);
 htp.formhidden( 'FOOTER_API', footer_api);
 htp.formhidden( 'LEFT_API_PARM', left_api_parm);
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number);
 htp.formhidden( 'DISPLAY_DETAIL', display_detail);
 htp.formhidden( 'ACID', acid);
 htp.formhidden( 'FIRST_PARAMETER', first_parameter);
 htp.formhidden( 'CALLED_FROM', called_from);

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tableheader( htf.bold('Special Effect'), cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.p( '<TD ' || pfx.qbground || ' ALIGN="CENTER">' );
   htp.formselectopen( 'P1' );
    for c2rec in c2 loop
     htp.formselectoption( c2rec.name, cattributes=>'VALUE="' || c2rec.magid || '"' );
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null,'Next Page for Special Effect Parameters' );
 htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'IMAGE_MAGICK',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end image_magick;

procedure accept_image_magick(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;
 cursor c2(vparm integer) is select * from image_magick_definition where magid = vparm;
 cursor c3(vparm integer) is select * from image_magick_param where magid = vparm order by order_by;
 cursor c4(phgrid integer, acid integer, imgtype varchar2 ) is
   select um.photo_master, um.umo_id, um.version, um.aid, um.extras.photo_name photo_name
   from umo um, customer_account ca
   where um.aid = ca.aid and
         ca.pid = phgrid and
         umo_type = imgtype;
 cursor c5(phgid integer) is select * from photographer where pid = phgid;

 cusrec		customer_account%ROWTYPE;
 umorec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 zoom		number;
 retcall	varchar2(10000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_IMAGE_MAGICK' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c5(cusrec.pid);
 fetch c5 into c5rec;
 close c5;
 open c1(loc_id, cusrec.aid);
 fetch c1 into umorec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;

 glbx.main_title( surl, 'Image Special Effect', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;

 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<td>' );
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=10' );
 htp.tablerowopen;

 if umorec.umo_type = 'PHOTO'
  then
  if umorec.photo_master.width > umorec.photo_master.height
   then
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 WIDTH=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                   '" ALT="' || umorec.extras.photo_name || '">' );
    else
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 HEIGHT=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                   '" ALT="' || umorec.extras.photo_name || '">' );
  end if;
  else
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 SRC=' || DECS.IMAGE_LOCATION || 'adminc/audio.gif ALT="' || umorec.extras.photo_name || '">' );
 end if;

 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 open c2( to_number(p1) );
 fetch c2 into c2rec;
 close c2;

 if msg is not null then glbx.header_msg( msg ); end if;

 htp.formopen( 'gimmick.process_image_magick' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'NVID', nvid);
 htp.formhidden( 'LOC_ID', loc_id);
 htp.formhidden( 'FOOTER_API', footer_api);
 htp.formhidden( 'LEFT_API_PARM', left_api_parm);
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number);
 htp.formhidden( 'DISPLAY_DETAIL', display_detail);
 htp.formhidden( 'ACID', acid);
 htp.formhidden( 'FIRST_PARAMETER', first_parameter);
 htp.formhidden( 'CALLED_FROM', called_from);
 htp.formhidden( 'P1', p1);
 htp.formhidden( 'P2', null);
 htp.formhidden( 'P3', null);

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 for c3rec in c3(c2rec.magid) loop
  htp.tablerowopen;
  htp.tabledata( htf.bold(c3rec.title), cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
  htp.p( '<TD ' || pfx.qcbground || ' ALIGN="LEFT">' );
  htp.formhidden( 'P2', c3rec.param_name );
  if c3rec.param_type = 1 -- Geometry
   then
    htp.formtext( 'P3', 20, 100, '+0+0' );
  elsif c3rec.param_type = 2 -- Number 0-100
   then
    htp.formtext( 'P3', 20, 100, '0' );
  elsif c3rec.param_type = 3 -- Watermark UMO ID
   then
    htp.formselectopen( 'P3' );
    for c4rec in c4( cusrec.pid, acid, 'WATERMARK' ) loop
     htp.formselectoption( c4rec.photo_name, cattributes=>'VALUE="' || c4rec.umo_id || '"' );
    end loop;
    htp.formselectclose;
  elsif c3rec.param_type = 4 -- Number 0-360
   then
    htp.formtext( 'P3', 20, 100, '0' );
  elsif c3rec.param_type = 5 -- Number widthxheight
   then
    htp.formtext( 'P3', 20, 100, to_char(umorec.photo_master.width) || 'x' || to_char(umorec.photo_master.height) );
  elsif c3rec.param_type = 6 -- Number 0-100 Compression
   then
    htp.formtext( 'P3', 20, 100, '75' );
  elsif c3rec.param_type = 7 -- Font
   then
    htp.formselectopen( 'P3' );
     htp.formselectoption( 'arial' );
     htp.formselectoption( 'courier' );
     htp.formselectoption( 'helvetica' );
    htp.formselectclose;
  elsif c3rec.param_type = 8 -- Colour
   then
    htp.formselectopen( 'P3' );
     htp.formselectoption( 'aliceblue' );
     htp.formselectoption( 'black' );
     htp.formselectoption( 'blue' );
     htp.formselectoption( 'brown' );
     htp.formselectoption( 'chocolate' );
     htp.formselectoption( 'darkred' );
     htp.formselectoption( 'gold' );
     htp.formselectoption( 'gray50' );
     htp.formselectoption( 'green' );
     htp.formselectoption( 'lightcyan' );
     htp.formselectoption( 'lime' );
     htp.formselectoption( 'limegreen' );
     htp.formselectoption( 'mediumblue' );
     htp.formselectoption( 'mediumvioletred' );
     htp.formselectoption( 'olive' );
     htp.formselectoption( 'pink' );
     htp.formselectoption( 'plum' );
     htp.formselectoption( 'purple' );
     htp.formselectoption( 'red' );
     htp.formselectoption( 'snow' );
     htp.formselectoption( 'tan' );
     htp.formselectoption( 'tomato' );
     htp.formselectoption( 'violet' );
     htp.formselectoption( 'wheat' );
     htp.formselectoption( 'whitesmoke' );
     htp.formselectoption( 'white' );
     htp.formselectoption( 'yellow' );
     htp.formselectoption( 'yellowgreen' );
    htp.formselectclose;
  elsif c3rec.param_type = 9 -- Image or Text Positioning
   then
    htp.formtext( 'P3', 20, 100, '100,100' );
  elsif c3rec.param_type = 10 -- Free Form Text
   then
    htp.formtext( 'P3', 20, 100, 'Watermark Text' );
  elsif c3rec.param_type = 11 -- Pointsize/Pitch
   then
    htp.formtext( 'P3', 20, 100, '32' );
  elsif c3rec.param_type = 12 -- RadiusxSigma
   then
    htp.formtext( 'P3', 20, 100, '1x5' );
  elsif c3rec.param_type = 13 -- Frame Width
   then
    htp.formtext( 'P3', 20, 100, '6x6+2+2' );
  elsif c3rec.param_type = 14 -- Photographer Directory
   then
    htp.p(c5rec.ftp_load_dir || htf.formtext( 'P3', 20, 100 ));
  elsif c3rec.param_type = 15 -- Image Type
   then
    htp.formselectopen( 'P3' );
     htp.formselectoption( 'jpg' );
     htp.formselectoption( 'gif' );
     htp.formselectoption( 'pcd' );
    htp.formselectclose;
  end if;
  htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 htp.tablerowopen;
   htp.tabledata( htf.bold('Update Thumbnail'), cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.p( '<TD ' || pfx.qcbground || ' ALIGN="LEFT">' );
   htp.formcheckbox( 'P4', 'T' );
   htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tablerowopen;
   htp.tabledata( htf.bold('Show Calling Parameters'), cattributes=>pfx.qbground || ' ALIGN="CENTER"' );
   htp.p( '<TD ' || pfx.qcbground || ' ALIGN="LEFT">' );
   htp.formcheckbox( 'P5', 'T' );
   htp.p( '</TD>' );
 htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 htp.formsubmit( 'ACTION','Run Special Effect Against Image' );
 htp.formsubmit( 'ACTION','Return to Previous Screen' );
 htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_IMAGE_MAGICK',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_image_magick;

procedure process_image_magick(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2, p2 in UMP.MYARRAY, p3 in UMP.MYARRAY, p4 in char default 'F', p5 in char default 'F', action in varchar2, msg in varchar2 default null )
as

 cursor c1(v_umo integer, acid integer) is select * from umo where umo_id = v_umo and aid = acid;
 cursor c2(v_umo integer, uscid integer, acid integer) is
  select umo_id
  from umo um
  where umo_scene_id = uscid and
        aid = acid and
        umo_id <> v_umo and
        umo_type in ('PHOTO')
  order by um.extras.orderby_scene;
 cursor c3(vparm integer) is select * from image_magick_definition where magid = vparm;

 cusrec		customer_account%ROWTYPE;
 umorec		c1%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 zoom		number;
 montage_id	integer;
 retcall	varchar2(10000);
 b2c_value	char(1);
 voidrec	order_style%ROWTYPE;
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;
 retarr		UMP.MYARRAY;
 extra_umo	UMP.MYARRAY_INT;

begin

 if action = 'Return to Previous Screen'
  then
   image_magick(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, msg );
   return;
 end if;

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.PROCESS_IMAGE_MAGICK' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );
 theme_rec := glbx.get_theme_types(cusrec.theme_type );
 voidrec := glbx.get_order_style( glbx.get_order_style( cusrec.aid, profid, ltype, b2c_value ));
 open c1(loc_id, cusrec.aid);
 fetch c1 into umorec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( 'Illegal Access');
   return;
 end if;
 close c1;

 glbx.main_title( surl, 'Result of Image Special Effect', glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),stype=>stype, sstyle=>pfx.text_font,sclr=>pfx.ord_text_colour,det_sstyle=>pfx.ord_title_text_font,det_sclr=>pfx.ord_title_text_colour, det_font=>pfx.ord_title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.ord_text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, jscript=>pfx.javascript, icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.p( '<CENTER>' );
 htp.nl;

 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<td>' );
 htp.tableopen( cattributes=>'cellpadding=0 cellspacing=0 border=10' );
 htp.tablerowopen;

 if umorec.umo_type = 'PHOTO'
  then
  if umorec.photo_master.width > umorec.photo_master.height
   then
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 WIDTH=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                   '" ALT="' || umorec.extras.photo_name || '">' );
    else
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 HEIGHT=' || glbx.sctrl(pfx.theme_name,'PHOTO_WIDTH',stype) || ' SRC="' ||
                   'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || umorec.umo_id || '&parm1=OVERRIDE_DISPLAY&parm2=PHOTO&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER' || '&parm1=LOGIN_TYPE&parm2=' || ltype || '&parm1=VERSION&parm2=' || umorec.version || '&parm1=AID&parm2=' || cusrec.aid ||
                   '" ALT="' || umorec.extras.photo_name || '">' );
  end if;
  else
    htp.tabledata( '<IMG STYLE="display:block;" BORDER=0 SRC=' || DECS.IMAGE_LOCATION || 'adminc/audio.gif ALT="' || umorec.extras.photo_name || '">' );
 end if;

 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 for j in p2.first..p2.last loop
  if p2(j) = 'WATERMARK' then montage_id := to_number(p3(j)); end if;
 end loop;

 extra_umo(1) := loc_id;

 open c3(to_number(p1));
 fetch c3 into c3rec;
 close c3;

 -- Mass unload of all images in category
 if c3rec.utility in (6)
  then
   for c2rec in c2(loc_id,umorec.umo_scene_id,acid) loop
    extra_umo( c2%ROWCOUNT + 1 ) := c2rec.umo_id;
   end loop;
 end if;

 retarr := ump.process_image_magick( surl, cusrec.pid, acid, extra_umo, montage_id, to_number(p1), p4, p5, p2, p3 );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 if retarr.count > 0
  then
   for j in retarr.first..retarr.last loop
   htp.tablerowopen;
    htp.tabledata( retarr(j) );
   htp.tablerowclose;
   end loop;
  else
   htp.tablerowopen;
    htp.tabledata( 'No Values Returned' );
   htp.tablerowclose;
 end if;
 htp.tableclose;

 htp.htmlclose;
exception when others then
 glbx.error_details( 'GIMMICK', 'PROCESS_IMAGE_MAGICK',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end process_image_magick;

procedure judge_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(acid integer) is select count('x') cnt from umo um where aid = acid and dbms_lob.getlength(um.audio_thumbnail.source.localdata) > 0;
 cursor c2(acid integer) is select count('x') cnt from umo um where aid = acid;
 cursor c3(acid integer) is select * from judge_novelty where aid = acid;
 cursor c4(acid integer) is select account_name,username,profile_id from customer_profile where aid = acid order by username;
 cursor c5(acid integer, profid integer) is select 'x' from judges where aid=acid and profile_id = profid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 pfx		THEME%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

function tg(surl in varchar2, acid in integer, tgid in integer, tname in varchar2)
 return varchar2
as
 cursor c2(objtype varchar2, acid integer) is
  select attribute_id, category, sub_category, umo_type
  from umo_attributes
   where umo_type = objtype and
         ((business_feature is null) or
          (business_feature is not null and business_feature = (select theme_type from customer_account ca where ca.aid = acid))
         )
  order by category, sub_category;
 txt	varchar2(32767);
begin
 txt := htf.formhidden( 'P1', tname );
 txt := txt || htf.formselectopen( 'P2' );
 txt := txt || htf.formselectoption( NULL );
 for c2rec in c2('PHOTO',acid) loop
  if c2rec.attribute_id = tgid
   then
    txt := txt || htf.formselectoption( '[' || c2rec.category || '] ' || c2rec.sub_category || ' (' || c2rec.umo_type || ')', 'SELECTED', cattributes=>'VALUE="' || c2rec.attribute_id || '"' );
   else
    txt := txt || htf.formselectoption( '[' || c2rec.category || '] ' || c2rec.sub_category || ' (' || c2rec.umo_type || ')', cattributes=>'VALUE="' || c2rec.attribute_id || '"' );
  end if;
 end loop;
 txt := txt || htf.formselectclose;
 return( txt );
end tg;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.HTML_ZOOM_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, 'Judge Preferences',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Modify Zoom Factor' );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'gimmick.accept_judge_pref' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', loc_id );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 open c1(acid);
 fetch c1 into c1rec;
 close c1;
 open c2(acid);
 fetch c2 into c2rec;
 close c2;
 open c3(acid);
 fetch c3 into c3rec;
 close c3;

 -- Options
 htp.nl;
 htp.bold( 'Options' );
 htp.nl;
 htp.p( 'Map Meta Tags to Fixed Results' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Result'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( tg(surl,acid,c3rec.mt_result,'MT_RESULT'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Score'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( tg(surl,acid,c3rec.mt_score,'MT_SCORE'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Photographer'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( tg(surl,acid,c3rec.mt_photographer,'MT_PHOTOGRAPHER'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Date Taken'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( tg(surl,acid,c3rec.mt_date_taken,'MT_DATE_TAKEN'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Details about Photo'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( tg(surl,acid,c3rec.mt_details,'MT_DETAILS'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Other Tag'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( tg(surl,acid,c3rec.mt_other,'MT_OTHER'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( 'Additional Judging Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Scoring System'),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   htp.formhidden( 'P1', 'SCORING_SYSTEM' );
   htp.formselectopen( 'P2' );
    htp.formselectoption( NULL );
    if c3rec.scoring_system = 'DELAYED'
     then
      htp.formselectoption( 'Over a Period of Time (Delayed)', 'SELECTED', cattributes=>'VALUE="DELAYED"' );
     else
      htp.formselectoption( 'Over a Period of Time (Delayed)', cattributes=>'VALUE="DELAYED"' );
    end if;
    if c3rec.scoring_system = 'REALTIME'
     then
      htp.formselectoption( 'Interactive (Real Time)', 'SELECTED', cattributes=>'VALUE="REALTIME"' );
     else
      htp.formselectoption( 'Interactive (Real Time)', cattributes=>'VALUE="REALTIME"' );
    end if;
    if c3rec.scoring_system = 'MANUAL'
     then
      htp.formselectoption( 'Manual (Scoring Only, no Images)', 'SELECTED', cattributes=>'VALUE="MANUAL"' );
     else
      htp.formselectoption( 'Manual (Scoring Only, no Images)', cattributes=>'VALUE="MANUAL"' );
    end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('If Delayed: Start Date and Time') || htf.nl || htf.italic(LNG.TSMASK),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formhidden( 'P1', 'JUDGING_START') ||
                  htf.formtext( 'P2', 30, 100, to_char(c3rec.judging_start,LNG.TSMASK)) ,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('If Delayed: Finish Date and Time') || htf.nl || htf.italic(LNG.TSMASK),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.tabledata( htf.formhidden( 'P1', 'JUDGING_FINISH') ||
                  htf.formtext( 'P2', 30, 100, to_char(c3rec.judging_finish,LNG.TSMASK)) ,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Judges (Delayed and Real Time Only)' ,cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
   htp.p('<TD ' || pfx.qbground || 'valign="MIDDLE" align="LEFT">' );
    htp.formselectopen( 'J1', null, 5, cattributes=>'MULTIPLE' );
    htp.formselectoption( null );
    for c4rec in c4(acid) loop
     open c5(acid,c4rec.profile_id);
     fetch c5 into c5rec;
     if c5%FOUND
      then
       htp.formselectoption( c4rec.account_name || '(' || c4rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c4rec.profile_id || '"' );
      else
       htp.formselectoption( c4rec.account_name || '(' || c4rec.username || ')', cattributes=>'VALUE="' || c4rec.profile_id || '"' );
     end if;
     close c5;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.line;

 -- Utilities
 htp.nl;
 htp.bold( 'Utilities' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   htp.p( '&nbsp;' );
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( to_char(nvl(c1rec.cnt,0)) || '/' || to_char(nvl(c2rec.cnt,0)) || ' ' || 'Black and White Thumbnails Generated' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   htp.formcheckbox( 'P3A', 'T' );
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'Generate ALL Black and White of Thumbnails' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   htp.formcheckbox( 'P3B', 'T' );
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'Generate MISSING Black and White of Thumbnails' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   htp.formcheckbox( 'P3C', 'T' );
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'Empty Tables used for Manual and Realtime Scoring' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.p( '<TD ' || pfx.qcbground || 'valign="MIDDLE" align="CENTER">' );
   htp.formcheckbox( 'P3D', 'T' );
   htp.p( '</TD>' );
   htp.tabledata( htf.bold( 'Empty Tables used for Delayed Scoring' ),cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Modify Options and/or Generate Black and White Thumbnails' );
 htp.p( '</CENTER>' );
 htp.formclose;

 -- Reports
 htp.line;
 htp.nl;
 htp.bold( 'Reports and Various Utilities' );
 htp.nl;
 htp.nl;
 htp.p( 'Over a Period of Time (Delayed)' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=D1', '1. Generate Scores (Missing Only)', ctarget=>'REP' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=D2', '2. Generate Scores (All)', ctarget=>'REP' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=D3', '3. Generate Results', ctarget=>'REP' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=D4', '4. HTML View of Results', ctarget=>'REP' );
 htp.nl;
 htp.anchor( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=D5', '5. CSV View of Results' );
 htp.nl;
 htp.nl;
 htp.p( 'Interactive (Real Time)' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=R1', '1. Generate Scores (Missing Only)', ctarget=>'REP' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=R2', '2. Generate Scores (All)', ctarget=>'REP' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=R3', '3. Generate Results', ctarget=>'REP' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=R4', '4. HTML View of Results', ctarget=>'REP' );
 htp.nl;
 htp.anchor( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=R5', '5. CSV View of Results' );
 htp.nl;
 htp.nl;
 htp.p( 'Manual (Scoring Only, no Images)' );
 htp.nl;
 htp.anchor2( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=M1', '1. HTML View of Results', ctarget=>'REP' );
 htp.nl;
 htp.anchor( 'gimmick.judge_pref_rep?surl=' || surl || '&acid=' || acid || '&repid=M2', '2. CSV View of Results' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'GIMMICK', 'JUDGE_PREF',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end judge_pref;

procedure genbw(surl in varchar2, acid in integer, v_umo in integer)
as
 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo for update;
 c1rec  c1%ROWTYPE;
 bimage ordsys.ordimage;
begin
 -- Its not elegant but it works.
 open c1(v_umo);
 fetch c1 into c1rec;
 close c1;
 bimage := ORDSYS.ORDImage.init( );
 dbms_lob.createtemporary( bimage.source.localdata, FALSE);
 c1rec.photo_thumbnail.copy(bimage);
 bimage.process( 'contentFormat=8BITGREYSCALE' );
 dbms_lob.copy(c1rec.audio_thumbnail.source.localdata,bimage.source.localdata,dbms_lob.getlength(bimage.source.localdata));

 update umo um
  set
   um.audio_thumbnail.source.localdata = c1rec.audio_thumbnail.source.localdata,
   um.audio_thumbnail.description = dbms_lob.getlength(c1rec.audio_thumbnail.source.localdata)
  where umo_id = v_umo;
 commit;
 dbms_lob.freetemporary( bimage.source.localdata );

end genbw;

procedure accept_judge_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null, p3a in char default 'F', p3b in char default 'F', p3c in char default 'F', p3d in char default 'F', p1 in glbx.myarray, p2 in glbx.myarray, j1 in glbx.myarray )
as

 cursor c1(acid integer) is select umo_id from umo um where aid = acid and dbms_lob.getlength(um.audio_thumbnail.source.localdata) = 0;
 cursor c2(acid integer) is select umo_id from umo um where aid = acid;
 cursor c3(acid integer) is select * from judge_novelty where aid = acid;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.ACCEPT_JUDGE_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );

 if p3a = 'T'
  then
   for c2rec in c2(acid) loop
    genbw(surl,acid,c2rec.umo_id);
   end loop;

 elsif p3b = 'T'
  then
   for c1rec in c1(acid) loop
    genbw(surl,acid,c1rec.umo_id);
   end loop;

 end if;

 if p3c = 'T'
  then
   delete from score_main where aid = acid;
   delete from score_details where aid = acid;
 end if;

 if p3d = 'T'
  then
   delete from judges where aid = acid;
   delete from judge_score where aid = acid;
 end if;

 open c3(acid);
 fetch c3 into c3rec;
 if c3%NOTFOUND then insert into judge_novelty(aid) values (acid); end if;
 close c3;

 delete from judges where aid = acid;
 for j in j1.first..j1.last loop
  if j1(j) is not null
   then
    insert into judges(aid,profile_id) values (acid,j1(j));
  end if;
 end loop;

 for j in p1.first..p1.last loop
  if p1(j) = 'MT_RESULT' then update judge_novelty set mt_result = p2(j) where aid = acid; end if;
  if p1(j) = 'MT_SCORE' then update judge_novelty set mt_score = p2(j) where aid = acid; end if;
  if p1(j) = 'MT_PHOTOGRAPHER' then update judge_novelty set mt_photographer = p2(j) where aid = acid; end if;
  if p1(j) = 'MT_DATE_TAKEN' then update judge_novelty set mt_date_taken = p2(j) where aid = acid; end if;
  if p1(j) = 'MT_DETAILS' then update judge_novelty set mt_details = p2(j) where aid = acid; end if;
  if p1(j) = 'MT_OTHER' then update judge_novelty set mt_other = p2(j) where aid = acid; end if;
  if p1(j) = 'SCORING_SYSTEM' then update judge_novelty set scoring_system = p2(j) where aid = acid; end if;
  begin if p1(j) = 'JUDGING_START' then update judge_novelty set judging_start = to_date(p2(j),LNG.TSMASK) where aid = acid; end if; exception when others then null; end;
  begin if p1(j) = 'JUDGING_FINISH' then update judge_novelty set judging_finish = to_date(p2(j),LNG.TSMASK) where aid = acid; end if; exception when others then null; end;
 end loop;
 commit;

 judge_pref(surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Action Performed' );

exception when others then
 glbx.error_details( 'GIMMICK', 'ACCEPT_JUDGE_PREF',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end accept_judge_pref;

procedure judge_pref_rep(surl in varchar2, acid in integer, repid in varchar2)
as

 cursor c2(acid integer) is select * from umo where aid = acid;

 cursor c3(acid integer) is select * from judge_novelty where aid = acid;

 cursor c4(acid integer) is
  select sm.score_id, score_name, date_created, ipaddress, score
  from score_details sd, score_main sm
  where sd.score_id = sm.score_id and
        sd.aid = sm.aid and
        sm.aid = acid
  order by sm.score_id,ipaddress;

 cursor c5(acid integer) is
  select um.umo_id, um.extras.photo_name photo_name, ua.date_made, cp.account_name, nvl(ua.value,'No Score') value
  from judge_novelty jn, judge_score js, umo_attribute ua, customer_profile cp, umo um
  where jn.aid = acid and
        jn.aid = js.aid and
        js.umo_id = um.umo_id and
        js.profile_id = cp.profile_id and
        js.umo_id = ua.umo_id and
        ua.attribute_id = jn.mt_score
  order by um.umo_id;

 cursor c5a(acid integer) is
  select um.umo_id, um.extras.photo_name photo_name, ua.date_made, cp.account_name, nvl(ua.value,'No Score') value
  from judge_novelty jn, score_details sd, score_main sm, umo_attribute ua, customer_profile cp, umo um
  where jn.aid = acid and
        sm.aid = acid and
        sd.aid = acid and
        to_number(sm.score_name) = um.umo_id and
        to_number(sd.ipaddress) = cp.profile_id and
        sd.score_id = sm.score_id and
        ua.attribute_id = jn.mt_score and
        ua.umo_id = um.umo_id
  order by um.umo_id;

 cursor c6(acid integer, v_umo integer, attid integer )
  is
   select value
   from umo_attribute uta
   where uta.umo_id = v_umo and
         uta.attribute_id = attid;

 cursor c7(acid integer, v_umo integer) is select score from judge_score where aid = acid and umo_id = v_umo;
 cursor c7a(acid integer, v_umo integer) is select score from score_details sd, score_main sm where sd.aid = acid and sm.aid = acid and sd.score_id = sm.score_id and to_number(sm.score_name) = v_umo;

 cusrec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c6rec		c6%ROWTYPE;
 nmb		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 profid		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 tot 		number;
 hscore	 	number;
 lscore	 	number;
 c75		integer;
 c80		integer;
 c85		integer;
 c90		integer;
 c95		integer;
 diff		integer;
 avg1		number;
 fscore	 	integer;
 ctr		integer;
 ctr2		integer;
 initial_scores GLBX.MYARRAY;

begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, 'S', progcalled=>'GIMMICK.JUDGE_PREF_REP', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 cusrec := glbx.get_cusrec( owner_id, ltype, acid, profid );
 pfx := glbx.get_thm( cusrec.theme_name );

 open c3(acid);
 fetch c3 into c3rec;
 close c3;

 if repid = 'D1'
  then
   ctr2 := 0;
   for c2rec in c2(acid) loop
    open c6(acid, c2rec.umo_id, c3rec.mt_score);
    fetch c6 into c6rec;
    close c6;
    if c6rec.value is null
     then
      initial_scores.delete;
      for c7rec in c7(acid, c2rec.umo_id) loop
       initial_scores(c7%ROWCOUNT) := c7rec.score;
      end loop;
      avg1 := null;
      fscore := null;
      xscore.calcscore(initial_scores, c75, c80, c85, c90, c95, tot, hscore, lscore, diff, avg1, fscore );
      if nvl(fscore,avg1) is not null
       then
         update umo_attribute set value = nvl(fscore,avg1) where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_score;
         ctr2 := ctr2 + 1;
      end if;
     end if;
     end loop;
     commit;
     htp.bold( 'Done: Generate Scores (Missing Only) #' || ctr2 );
     return;

 elsif repid = 'D2'
  then
   ctr2 := 0;
   for c2rec in c2(acid) loop
    initial_scores.delete;
    for c7rec in c7(acid, c2rec.umo_id) loop
     initial_scores(c7%ROWCOUNT) := c7rec.score;
    end loop;
      avg1 := null;
      fscore := null;
    xscore.calcscore(initial_scores, c75, c80, c85, c90, c95, tot, hscore, lscore, diff, avg1, fscore );
    if nvl(fscore,avg1) is not null
     then
       update umo_attribute set value = nvl(fscore,avg1) where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_score;
         ctr2 := ctr2 + 1;
    end if;
   end loop;
   commit;
   htp.bold( 'Done: Generate Scores (All) #' || ctr2 );
   return;

 elsif repid = 'D3'
  then
   for c2rec in c2(acid) loop
    open c6(acid, c2rec.umo_id, c3rec.mt_score);
    fetch c6 into c6rec;
    close c6;
    if c6rec.value is not null
     then
      begin
       if to_number(c6rec.value) >= 90
        then
         update umo_attribute set value = 'Gold' where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_result;
       elsif to_number(c6rec.value) >= 80
        then
         update umo_attribute set value = 'Silver' where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_result;
       else
         update umo_attribute set value = 'No Award' where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_result;
       end if;
      exception
       when others then null;
      end;
    end if;
   end loop;
   commit;
   htp.bold( 'Done: Generate Results' );
   return;

 elsif repid = 'D4'
  then

   glbx.main_title( surl, 'Judge Delayed Report',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.title( 'Modify Zoom Factor' );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Image Id' ) );
     htp.tabledata( htf.bold( 'Image Name' ) );
     htp.tabledata( htf.bold( 'Date Created' ) );
     htp.tabledata( htf.bold( 'Judge' ) );
     htp.tabledata( htf.bold( 'Score' ) );
    htp.tablerowclose;
    for c5rec in c5(acid) loop
     htp.tablerowopen;
      htp.tabledata( c5rec.umo_id );
      htp.tabledata( c5rec.photo_name );
      htp.tabledata( to_char(c5rec.date_made,'DD-Mon-YYYY HH24:MI:SS') );
      htp.tabledata( c5rec.account_name );
      htp.tabledata( c5rec.value );
     htp.tablerowclose;
    end loop;
   htp.tableclose;

 elsif repid = 'D5'
  then
    htp.prn('Content-type: ' || 'bad/type' || chr(10));
    htp.prn('Content-Disposition: attachment; filename=' || 'manual.csv' || chr(10));
    htp.prn('Content-Transfer-Encoding: binary' || chr(10));
    htp.prn(chr(10));
    htp.p( '"Image Id","Image Name","Date Created","Judge","Score"');
    for c5rec in c5(acid) loop
     htp.p( c5rec.umo_id || ',"' || c5rec.photo_name || '",' || to_char(c5rec.date_made,'DD-MON-YYYY HH24:MI:SS') || ',"' || c5rec.account_name || '",' || c5rec.value );
    end loop;
    return;

 elsif repid = 'R1'
  then
   ctr2 := 0;
   for c2rec in c2(acid) loop
    open c6(acid, c2rec.umo_id, c3rec.mt_score);
    fetch c6 into c6rec;
    close c6;
    if c6rec.value is null
     then
      initial_scores.delete;
      for c7arec in c7a(acid, c2rec.umo_id) loop
       initial_scores(c7a%ROWCOUNT) := c7arec.score;
      end loop;
      avg1 := null;
      fscore := null;
      xscore.calcscore(initial_scores, c75, c80, c85, c90, c95, tot, hscore, lscore, diff, avg1, fscore );
      if nvl(fscore,avg1) is not null and nvl(fscore,avg1) > 0
       then
         update umo_attribute set value = nvl(fscore,avg1) where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_score;
         ctr2 := ctr2 + 1;
      end if;
     end if;
     end loop;
     commit;
     htp.bold( 'Done: Generate Scores (Missing Only) #' || ctr2 );
     return;

 elsif repid = 'R2'
  then
   ctr2 := 0;
   for c2rec in c2(acid) loop
    initial_scores.delete;
    for c7arec in c7a(acid, c2rec.umo_id) loop
     initial_scores(c7a%ROWCOUNT) := c7arec.score;
    end loop;
    avg1 := null;
    fscore := null;
    xscore.calcscore(initial_scores, c75, c80, c85, c90, c95, tot, hscore, lscore, diff, avg1, fscore );
    if nvl(fscore,avg1) is not null and nvl(fscore,avg1) > 0
     then
       update umo_attribute set value = nvl(fscore,avg1) where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_score;
         ctr2 := ctr2 + 1;
    end if;
   end loop;
   commit;
   htp.bold( 'Done: Generate Scores (All) #' || ctr2 );
   return;

 elsif repid = 'R3'
  then
   for c2rec in c2(acid) loop
    open c6(acid, c2rec.umo_id, c3rec.mt_score);
    fetch c6 into c6rec;
    close c6;
    if c6rec.value is not null
     then
      begin
       if to_number(c6rec.value) >= 90
        then
         update umo_attribute set value = 'Gold' where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_result;
       elsif to_number(c6rec.value) >= 80
        then
         update umo_attribute set value = 'Silver' where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_result;
       else
         update umo_attribute set value = 'No Award' where umo_id = c2rec.umo_id and attribute_id = c3rec.mt_result;
       end if;
      exception
       when others then null;
      end;
    end if;
   end loop;
   commit;
   htp.bold( 'Done: Generate Results' );
   return;

 elsif repid = 'R4'
  then

   glbx.main_title( surl, 'Judge Realtime Report',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.title( 'Modify Zoom Factor' );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Image Id' ) );
     htp.tabledata( htf.bold( 'Image Name' ) );
     htp.tabledata( htf.bold( 'Date Created' ) );
     htp.tabledata( htf.bold( 'Judge' ) );
     htp.tabledata( htf.bold( 'Score' ) );
    htp.tablerowclose;
    for c5arec in c5a(acid) loop
     htp.tablerowopen;
      htp.tabledata( c5arec.umo_id );
      htp.tabledata( c5arec.photo_name );
      htp.tabledata( to_char(c5arec.date_made,'DD-Mon-YYYY HH24:MI:SS') );
      htp.tabledata( c5arec.account_name );
      htp.tabledata( c5arec.value );
     htp.tablerowclose;
    end loop;
   htp.tableclose;

 elsif repid = 'R5'
  then
    htp.prn('Content-type: ' || 'bad/type' || chr(10));
    htp.prn('Content-Disposition: attachment; filename=' || 'manual.csv' || chr(10));
    htp.prn('Content-Transfer-Encoding: binary' || chr(10));
    htp.prn(chr(10));
    htp.p( '"Image Id","Image Name","Date Created","Judge","Score"');
    for c5arec in c5a(acid) loop
     htp.p( c5arec.umo_id || ',"' || c5arec.photo_name || '",' || to_char(c5arec.date_made,'DD-MON-YYYY HH24:MI:SS') || ',"' || c5arec.account_name || '",' || c5arec.value );
    end loop;
    return;

 elsif repid = 'M1'
  then

   glbx.main_title( surl, 'Judge Manual Report',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.title( 'Modify Zoom Factor' );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Score Id' ) );
     htp.tabledata( htf.bold( 'Score Name' ) );
     htp.tabledata( htf.bold( 'Date Created' ) );
     htp.tabledata( htf.bold( 'IP Address' ) );
     htp.tabledata( htf.bold( 'Score' ) );
    htp.tablerowclose;
    for c4rec in c4(acid) loop
     htp.tablerowopen;
      htp.tabledata( c4rec.score_id );
      htp.tabledata( c4rec.score_name );
      htp.tabledata( to_char(c4rec.date_created,'DD-Mon-YYYY HH24:MI:SS') );
      htp.tabledata( c4rec.ipaddress );
      htp.tabledata( c4rec.score );
     htp.tablerowclose;
    end loop;
   htp.tableclose;

 elsif repid = 'M2'
  then
    htp.prn('Content-type: ' || 'bad/type' || chr(10));
    htp.prn('Content-Disposition: attachment; filename=' || 'manual.csv' || chr(10));
    htp.prn('Content-Transfer-Encoding: binary' || chr(10));
    htp.prn(chr(10));
    htp.p( '"Score Id","Score Name","Date Created","IP Address","Score"');
    for c4rec in c4(acid) loop
     htp.p( c4rec.score_id || ',"' || c4rec.score_name || '",' || to_char(c4rec.date_created,'DD-MON-YYYY HH24:MI:SS') || ',' || c4rec.ipaddress || ',' || c4rec.score );
    end loop;
    return;
 end if;

exception when others then
 glbx.error_details( 'GIMMICK', 'JUDGE_PREF_REP',errmsg=>sqlerrm,extdet=>'REPID:' || repid);
end judge_pref_rep;

end gimmick;

/
