CREATE OR REPLACE FUNCTION WEBSYS."HTTP_FILE_LISTING" (u_target varchar2, file_list in out glbx.myarray) return integer
as

p_url         varchar2(1000);
pieces        utl_http.html_pieces;
c_delim_s     CONSTANT varchar2(1000) := '<td><a href="';
c_delim_e     CONSTANT varchar2(1000) := '</a></td>';
v_buf         varchar2(4000);
clb           clob;
is_empty      boolean;
x             integer;
y             integer;
ctr           integer;
file_ctr      integer;
stp           varchar2(100);

begin

 p_url := 'http' || (case when nvl(upper(owa_util.get_cgi_env('HTTPS')), 'OFF') = 'ON' then 's' end) || '://' || owa_util.get_cgi_env('SERVER_NAME')|| ':' || owa_util.get_cgi_env( 'SERVER_PORT' ) || '/' || u_target;

 file_ctr := 0;

 pieces := utl_http.request_pieces( p_url );
 dbms_lob.createtemporary( clb, TRUE );
 stp := 'A';
 is_empty := FALSE;
 for j in pieces.first..pieces.last loop
  if length(pieces(j)) > 0
   then
    if upper(pieces(j)) like '%<!--ERROR-->%'
	 then
	  is_empty := TRUE;
	  exit;
	end if;
	pieces(j) := regexp_replace(pieces(j), '(>)([[:blank:]]+)([^[:blank:]]*)', '\1\3');
	-- htp.p(pieces(j));
	dbms_lob.writeappend(clb,length(pieces(j)),pieces(j));
  end if;
 end loop;
 stp := 'B';

 if is_empty
  then
   file_ctr := 0;
 else
   ctr := 0;
   stp := 'C';
   loop
 stp := 'D';
    x := dbms_lob.instr(clb, c_delim_s, 1, ctr + 1);
	-- htp.p('X: ' || x);
 stp := 'E';
	if x = 0 then exit; end if;
 stp := 'F';
	ctr := ctr + 1;
 stp := 'G';
	y := dbms_lob.instr(clb, c_delim_e, x, 1);
	-- htp.p('Y: ' || y);
 stp := 'H';
	v_buf := regexp_replace(dbms_lob.substr(clb, y-x, x), '(.*)(>)(.*)$', '\3');
	-- htp.p('..' || v_buf); htp.nl;
	if upper(v_buf) <> 'PARENT DIRECTORY'
	 then
	  file_ctr := file_ctr + 1;
	  file_list(file_ctr) := v_buf;
	end if;
   end loop;

 end if;
 dbms_lob.freetemporary( clb );
 return(file_ctr);

exception
 when others then
  glbx.dbg( 'HTTP_FILE_LISTING. Error at stp ' || stp || ': ' || sqlerrm );
  return(0);
end http_file_listing;
/
