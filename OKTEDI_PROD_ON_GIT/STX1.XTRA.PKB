CREATE OR REPLACE package body STX1.xtra
as

 SPEC_XMLCONV	char(1);

function number_expr( val in varchar2 )
 return varchar2
as
 vl     number;
begin
 if instr(val,'SELECT') > 0 then return( null ); end if;
 if instr(val,'SYS.') > 0 then return( null ); end if;
 if instr(val,'OWA_UTIL.') > 0 then return( null ); end if;
 if instr(val,'OWA.') > 0 then return( null ); end if;
 begin
  execute immediate 'select ' || val || ' from dual' into vl;
 exception
  when others then return( null );
 end;
 return( to_char( vl ) );
exception
 when others then return( null );
end number_expr;

function guess_number( val in varchar2, enable_eq in char default 'T', starting_mask in varchar2 default null, defval in integer default null  )
 return varchar2
as
 nmb    number;
begin
 if val is null then return( defval ); end if;
 if substr(trim(val),1,1) = '=' and enable_eq = 'T'
  then
   return( number_expr( upper(trim(substr(trim(val),2))) ) );
 end if;
 if starting_mask is not null
  then
    begin
      nmb := to_number( val, starting_mask );
      return( to_char( nmb ) );
    exception when others then null;
    end;
 end if;
 begin nmb := to_number( replace(replace(replace(replace(replace(val,',',''),'_',''),chr(13),''),chr(10),''),chr(11),'') ); return( to_char( nmb ) ); exception when others then null; end;
 return( defval );
exception
 when others then return( defval );
end guess_number;

function to_dec( p_str in varchar2, p_from_base in number default 16 ) return number
is
	l_num   number default 0;
	l_hex   varchar2(16) default '0123456789ABCDEF';
begin
	if ( p_str is null or p_from_base is null )
	then
		return null;
	end if;
	for i in 1 .. length(p_str) loop
		l_num := l_num * p_from_base + instr(l_hex,upper(substr(p_str,i,1)))-1;
	end loop;
	return l_num;
end to_dec;

function xmlconv( vl in varchar2, override_conv in char default null )
  return varchar2
 as

  start_quote constant varchar2(20) := chr(50082) || chr(48) || chr(49) || chr(67);
  end_quote constant varchar2(20) := chr(50082) || chr(48) || chr(49) || chr(68);
  single_quote constant varchar2(20) := chr(50082) || chr(48) || chr(49) || chr(57);

  xrv 	varchar2(32767);
  xvl 	varchar2(32767);
  x   	integer;
  xstr	varchar2(100);

 begin
  if vl is null then return( NULL ); end if;
  xvl := vl;
  if nvl(SPEC_XMLCONV,override_conv) = 'T'
   then
    if upper(xvl) like 'HTTP://%'
     then
      xvl := replace(replace(xvl,'/','Xx002F'),'\','Xx005C');
      xvl := utl_url.escape(xvl,TRUE);
      xvl := replace(replace(xvl,'Xx002F','$002F'),'Xx005C','$005C');
      return( xvl );
    end if;
  end if;

  -- added for PG to fix quote display
  xvl := replace(xvl,start_quote,'&#34;');
  xvl := replace(xvl,end_quote,'&#34;');
  xvl := replace(xvl,single_quote,'&#39;');

  for j in 1..length(xvl) loop
   x := ascii(substr(xvl,j,1));
   xstr := asciistr(substr(xvl,j,1));
   if x = 226
    then
     null;  --xrv := replace( xrv, chr(226), 'a' ); -- Causing 10gR2 to crash.
   elsif substr(xstr,1,1) = '\' and not (x between 32 and 126)
    then
     xrv := xrv || '&#' || to_dec(substr(xstr,2)) || ';';
   elsif x < 32 or x > 126 or x in (33,34,35,37,38,39)
    then
     if x < 999
      then
       xrv := xrv || '&#' || lpad(to_char(x),3,'0') || ';';
      else
       xrv := xrv || '&#' || to_char(x) || ';';
     end if;
   elsif x = 47
    then
     xrv := xrv || '&#47;';
   elsif x = 60
    then
     xrv := xrv || '&lt;';
   elsif x = 62
    then
     xrv := xrv || '&gt;';
    else
     xrv := xrv || substr(xvl,j,1);
   end if;
  end loop;

  /*
  xrv := vl;
  xrv := replace( xrv, '<', '&lt;' );
  xrv := replace( xrv, '>', '&gt;' );
  xrv := replace( xrv, '"', '&#034;' );
  xrv := replace( xrv, '#', '&#035;' );
  xrv := replace( xrv, '!', '&#033;' );
  xrv := replace( xrv, '%', '&#037;' );
  xrv := replace( xrv, '&', '&#038;' );
  xrv := replace( xrv, '''', '&#039;' );
  xrv := replace( xrv, chr(9), '&#009;' );
  xrv := replace( xrv, chr(10), '&#010;' );
  xrv := replace( xrv, chr(13), '&#013;' );
  xrv := replace( xrv, chr(147), '.' );
  xrv := replace( xrv, chr(225), '.' );
  xrv := replace( xrv, chr(50081), 's' );

  */
   xrv := replace( xrv, '&#008;', ' ' );
   xrv := replace(xrv,chr(50082) || '019','''');
  return( xrv );
end xmlconv;

procedure comma_delimited_wide(bfr in varchar2, comma_delim in out nocopy owa.vc_arr, delimchar in char default ',', append in boolean default FALSE)
as

 vbfr	varchar2(32767);
 ctr    integer;
 pos    integer;
 lctr   integer;
 xctr   integer;
 len    integer;
 delim  varchar2(100);

begin
 vbfr := bfr;

 ctr := 1;
 lctr := 0;
 if append
  then
   xctr := nvl(comma_delim.count,0) + 1;
  else
   xctr := 1;
 end if;
 delim := trim(delimchar); -- spaces not allowed around
 len := length(delim);

 loop
  pos := instr( vbfr, delim, lctr+1, 1 );
  -- dbms_output.put_line(pos || ':[' || vbfr || '][' || delim || '][' || to_char(lctr+1) || '][' || '1' || ']' );
  if pos = 0
   then
    comma_delim( xctr ) := substr(vbfr,lctr+1);
    exit;
  end if;

  comma_delim( xctr ) := substr(vbfr, lctr+1, (pos - (lctr + 1)));

  lctr := pos + (len-1);

  ctr := ctr + 1;
  xctr := xctr + 1;
  if ctr > 9999 then exit; end if;
 end loop;

end comma_delimited_wide;

procedure comma_delimited(bfr in varchar2, comma_delim in out nocopy owa.vc_arr, delimchar in char default ',', append in boolean default FALSE, extra_dquote in boolean default FALSE)
as

 dchar	constant char(7) := '&quote;';
 cchar	constant char(7) := '&comma;';
 vbfr	varchar2(32767);
 ctr    integer;
 pos    integer;
 lctr   integer;
 xctr   integer;
 rctr	integer;
 delim  char(1);

begin

 if bfr is null then return; end if;
 if length(delimchar) > 1 and not(upper(delimchar) like 'CHR(%)%')
  then
   comma_delimited_wide(bfr, comma_delim, delimchar, append);
   return;
 end if;
 vbfr := bfr;

 ctr := 1;
 lctr := 0;
 if append
  then
   xctr := nvl(comma_delim.count,0) + 1;
  else
   xctr := 1;
 end if;

 if upper(delimchar) like 'CHR(%)%'
  then
   delim := substr(chr( nvl(guess_number(replace(substr(delimchar,5),')','')),255) ),1,1);
  else
   delim := delimchar;
 end if;

 if delimchar = ',' or extra_dquote
   then
    -- New York\, New York
    if instr(vbfr,'\,') > 0
     then
      vbfr := replace(vbfr,'\,',cchar);
    end if;

    -- ,"""field value""",
    if instr(vbfr,'"""') > 0
     then

      if substr(vbfr,1,3) = '"""'
       then
        vbfr := '"' || dchar || substr(vbfr,4);
      end if;
      vbfr := replace(vbfr,',"""',',"' || dchar );
      vbfr := replace(vbfr,'""',dchar);
      -- dbms_output.put_line( '[' || vbfr || ']' );
     else
      vbfr := replace(vbfr,'""',dchar);
    end if;

 end if;

 -- Not sure which customer wanted this, but and the second clause to avoid issues.
 -- If the whole string is in double quotes do not parse it out
 if substr(vbfr,1,1) = '"' and substr(vbfr,length(vbfr),1) = '"' and delimchar = ',' and instr(vbfr,'"',1,2) = length(vbfr)
   then
    comma_delim(1) := substr(vbfr,2,length(vbfr)-2);
    return;
 end if;


 loop
  rctr := 1;
  <<RESTART_LOOP>>
  pos := instr( vbfr, delim, lctr+1, rctr );
  if pos = 0
   then
    if delim = '"'
     then
      comma_delim( xctr ) := substr(vbfr,lctr+1);
      comma_delim( xctr ) := substr(comma_delim( xctr ),1,length(comma_delim( xctr ))-1);
     else
      comma_delim( xctr ) := substr(vbfr,lctr+1);
    end if;
    if rctr > 1 then comma_delim( xctr ) := replace(comma_delim( xctr ),'\' || delim,delim); end if;
    if rctr > 1 and delimchar = ',' then comma_delim( xctr ) := replace(comma_delim( xctr ),'\' || '"','"'); end if;
    exit;
  end if;

  if substr(vbfr,pos-1,2) = '\' || delim
   then
    -- ignore this char
    rctr := rctr + 1;
    goto RESTART_LOOP;
  end if;

  if (delimchar = ',' or extra_dquote) and substr(vbfr,pos-1,2) = '\' || '"'
   then
    -- ignore this char
    rctr := rctr + 1;
    goto RESTART_LOOP;
  end if;

  comma_delim( xctr ) := substr(vbfr, lctr+1, (pos - (lctr + 1)));
  if rctr > 1 then comma_delim( xctr ) := replace(comma_delim( xctr ),'\' || delim,delim); end if;
  if rctr > 1 and delimchar = ',' then comma_delim( xctr ) := replace(comma_delim( xctr ),'\' || '"','"'); end if;

  if delim = '"'
   then
    delim := delimchar;
    pos := pos + 1;
    lctr := pos;
  end if;

  if delim = delimchar and substr(vbfr,pos+1,1) = '"'
   then
    delim := '"';
    lctr := pos + 1;
  else
    lctr := pos;
  end if;

  ctr := ctr + 1;
  xctr := xctr + 1;
  if ctr > 9999 then exit; end if;
  if lctr > length(vbfr) then exit; end if;
 end loop;

 if (delimchar = ',' or extra_dquote) and comma_delim.count > 0
   then
    for j in comma_delim.first..comma_delim.last loop
     if comma_delim(j) = dchar then comma_delim(j) := null; end if;
     -- If leading and trailing quotes, remove them
     if comma_delim( j ) like '"%"'
      then
       comma_delim( j ) := substr(comma_delim( j ),2,length(comma_delim( j ))-2);
     end if;
     comma_delim(j) := replace(comma_delim(j),dchar,'"');
     comma_delim(j) := replace(comma_delim(j),cchar,',');
    end loop;
 end if;

end comma_delimited;

function encrypt_pk( input_string in varchar2, maxlength in integer default 32, filler_only in boolean default FALSE )
 return varchar2
as
   raw_input            raw(256);
   raw_key              raw(256);
   encrypted_raw        raw(2048);

 begin
   if filler_only
    then
     raw_key := utl_raw.cast_to_raw(substr(FILLER_KEY,1,8));
    else
     raw_key := utl_raw.cast_to_raw(substr(FILLER_KEY,1,8));
   end if;
   raw_input := utl_raw.cast_to_raw(substr(rpad(nvl(upper(input_string),'|'),maxlength,' '),1,maxlength));
   dbms_obfuscation_toolkit.desencrypt(input => raw_input, key => raw_key, encrypted_data => encrypted_raw );
   return( rawtohex(encrypted_raw) );

exception
 when others
  then
   return( NULL );
end encrypt_pk;

end xtra;
/
