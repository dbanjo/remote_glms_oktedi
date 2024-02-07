CREATE OR REPLACE procedure WEBSYS.status
as
 --cursor c1 is select * from master_piction;
 cursor c2 is select * from v$instance;
 cursor c3 is select count('x') tot from customer_account;
 cursor c4 is select count('x') tot from photographer;
 cursor c5 is select count('x') tot from umo;
 cursor c6 is select count('x') tot from login_session;

 --c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 c3rec	c3%ROWTYPE;
 c4rec	c4%ROWTYPE;
 c5rec	c5%ROWTYPE;
 c6rec	c6%ROWTYPE;

begin


/*
open c1;
fetch c1 into c1rec;
close c1;
*/

open c2;
fetch c2 into c2rec;
close c2;

open c3;
fetch c3 into c3rec;
close c3;

open c4;
fetch c4 into c4rec;
close c4;

open c5;
fetch c5 into c5rec;
close c5;

open c6;
fetch c6 into c6rec;
close c6;

htp.htmlopen;
htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );

 htp.tablerowopen;
  htp.tabledata( 'Name' );
  htp.tabledata( htf.bold(glbx.extract_master_parameter('NODE_NAME')) );
 htp.tablerowclose;

 htp.tablerowopen;
  htp.tabledata( 'Instance Name' );
  htp.tabledata( htf.bold(c2rec.instance_name) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Host Name' );
  htp.tabledata( htf.bold(c2rec.host_name) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Oracle Version' );
  htp.tabledata( htf.bold(c2rec.version) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Piction Version' );
  htp.tabledata( htf.bold(glbx.current_version) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Total Customers' );
  htp.tabledata( htf.bold(c3rec.tot) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Total Photographers' );
  htp.tabledata( htf.bold(c4rec.tot) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Total Images' );
  htp.tabledata( htf.bold(c5rec.tot) );
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( 'Total Logins' );
  htp.tabledata( htf.bold(c6rec.tot) );
 htp.tablerowclose;
htp.tableclose;
htp.htmlclose;
exception
 when others then htp.p( sqlerrm ); htp.htmlclose;
end status;

/
