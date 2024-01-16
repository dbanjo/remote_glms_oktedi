CREATE OR REPLACE package WEBSYS.soap
as

 G_MESSAGE	varchar2(32767);

 procedure main( file in varchar2 default null );
 procedure testscreen;
 procedure accepttest( p1 in varchar2 );
 function xmlname( vl in varchar2 ) return varchar2;
 function xmlconv( vl in varchar2 )  return varchar2;
 function testprogram( p1 in varchar2, p2 in varchar2 ) return varchar2;
 function decrypt_key( input_string_hex in varchar2, maxlength in integer default 128, ky in varchar2 ) return varchar2;
 function generate_webservice(purchord in purchase_order%ROWTYPE, sbrec in shopping_basket%ROWTYPE, umorec in umo%ROWTYPE ) return varchar2;

end;

/
