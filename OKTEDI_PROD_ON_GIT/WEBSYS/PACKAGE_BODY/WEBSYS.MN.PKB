CREATE OR REPLACE package body WEBSYS.mn
as

procedure style_c
as
begin
htp.p('<style>
<!--
/* Piction Tab CSS Document */

BODY{background:#e3e3df url(' || DECS.IMAGE_LOCATION || 'nstmnu/ccentre_border.gif) repeat-y left;color:#003300;
        font-family:Verdana, Tahoma, Lucida Grande, Helvetica;
        font-size:small;margin:10px 5px 5px 25px;padding:0px;}

/* TAB Menu styles */
.PictionTab{background:#e3e3df}
DIV.PictionTab{float:left;width:100%;background:#e3e3df url(' || DECS.IMAGE_LOCATION || 'nstmnu/pictiontabborder.gif) repeat-x bottom;}
DIV.PictionTab UL{margin:0px;padding:0px;list-style:none;}
DIV.PictionTab LI{display:inline;margin:0px;padding:0px;}
DIV.PictionTab A{float:left;background:url(' || DECS.IMAGE_LOCATION || 'nstmnu/pictiontabright.gif) no-repeat right top;
        border-bottom:1px solid #919b9c;font-size:x-small;font-weight:bold;text-decoration:none;}
DIV.PictionTab A:hover{background-position:100% -200px;}
DIV.PictionTab A:link, DIV.PictionTab A:visited,DIV.PictionTab A:active, DIV.PictionTab A:hover{color: #003300;}
DIV.PictionTab SPAN{float:left;display:block;background:url(' || DECS.IMAGE_LOCATION || 'nstmnu/pictiontableft.gif) no-repeat left top;
        padding:5px 9px;white-space:nowrap;}
/* Commented Backslash Hack hides rule from IE5-Mac \*/
DIV.PictionTab SPAN {float : none;}
/* End IE5-Mac hack */
DIV.PictionTab A:hover SPAN{background-position:0% -200px;}
DIV.PictionTab LI#current A{background-position:100% -100px;border-width:0px;}
DIV.PictionTab LI#current SPAN{background-position:0% -100px;padding-bottom:6px;}
TABLE.PictionFullWidth{border-width:0px;border-spacing:0px;border-collapse:collapse;width:100%}
.PictionFullWidth TD{padding:0px;}
TD.PictionFullWidth{width:100%;}
.PictionTabContent td{padding:1px;}
TD.PictionTabContent{width:100%;padding:6px;border-right:1px solid #919b9c;
        border-bottom: 1px solid #919b9c;border-left: 1px solid #919b9c;background:#FFFFFF;}
-->
</style>
');
end style_c;

procedure style_s
as
begin
 htp.p('<style TYPE="text/css"><!-- P { page-break-after: auto; } A:link { font-family: verdana; color :  #000000  ;} A:active { font-family: verdana; color :  #8A2BE2  ;} A:visited { font-family: verdana; color :  #000000  ;} A:hover { font-family: verdana; color :  #8B0000 ;} BODY{font-size: 8pt; font-family: verdana; color:  #000000 ;} TD  {font-family: verdana; font-size: 8pt; color:  #000000 ; text-align: left;} --> </style>' );
end style_s;

function tableopen_style
 return varchar2
as
begin
 return( 'style="border: black solid 1px; padding: 10px; background-color: #FFFFFF;"' );
end tableopen_style;

function header_style
 return varchar2
as
begin
 return( 'valign="MIDDLE" style="text-align:center; font-weight:bold; background-color:#CCCCCC;"' );
end header_style;

end mn;
/
