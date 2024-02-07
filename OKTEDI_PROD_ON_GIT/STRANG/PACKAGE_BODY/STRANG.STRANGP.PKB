CREATE OR REPLACE package body STRANG.strangp
as

 function currsite return varchar2;
 function new_log_no( p1 in varchar2, vste in varchar2 ) return varchar2;
 function control_code( cd in varchar2, vste in varchar2 ) return varchar2;
 function customer_state(acid in integer) return varchar2;
 function pop_up_window(v_features in varchar2, v_title in varchar2 default '_blank') return varchar2;

 procedure lov_list( lname in varchar2, parm in varchar2, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showdesc in boolean DEFAULT TRUE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null );
 procedure lov_ship( cd in varchar2, lname in varchar2, val in varchar2 default null, isedit in boolean DEFAULT TRUE );
 procedure customer_list( custype in varchar2, parm in varchar2, custid in varchar2 default null, ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE );
 procedure search( surl in varchar2, msearch in varchar2, curr_rowid in varchar2, samerow in boolean DEFAULT FALSE, buttons_only in boolean DEFAULT FALSE, override_top in varchar2 default null, search_only in boolean DEFAULT FALSE, button_text in varchar2 default NULL, lmnu in rowid default null );
 procedure display_report( surl in varchar2, acid in integer, typ in varchar2, repname in varchar2, r1 in varchar2 default null, r2 in varchar2 default null, r3 in varchar2 default null );
 procedure allocate_hawb( mawb in varchar2, vste in varchar2 );
 procedure generate_entry(vship_id in integer, vste in varchar2);
 procedure generate_entry_airfreight(vship_id in integer, vste in varchar2);
 -- procedure trac_search( surl in varchar2, msg in varchar2 default null );
 procedure create_duty(vship_id varchar2, entryno number, vcust_id integer );
 procedure create_duty_com(vship_id varchar2, entryno number, vcust_id integer );
 procedure create_line_no( vShip_id integer, typ in varchar2 );
 procedure unallocate_entry( vShip_id integer );
 procedure generate_ost256( surl in varchar2, vShip_id in integer );
 procedure generate_ost156( surl in varchar2, vShip_id in integer );
 procedure generate_OST157( surl in varchar2, vShip_id in integer );
 -- procedure generate_ost185( surl in varchar2, vtoday in date, is_batch in boolean default FALSE );
 procedure generate_ccdets( surl in varchar2, vShip_id in integer );
 procedure generate_ccpo( surl in varchar2, vShip_id in integer );
 procedure download_gl(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, cusrec in customer_account%ROWTYPE, vste in varchar2, pfx in THEME%ROWTYPE, vaccess in varchar2 );
 procedure generate_containers( shpid in integer );
 procedure generate_containers_onhire( crec in strang.containers%ROWTYPE );
 procedure generate_containers_offhire( crec in strang.containers%ROWTYPE );

 function currsite
  return varchar2
 as
 begin
  return( 'PRIMARY' );
  --
  -- commented out for centralised use of Piction
  --strang.global_site.set_name;
  --return( nvl(strang.global_site.site_name,'PRIMARY') );
 end;

 function customer_state(acid in integer)
  return varchar2
 as
 begin
  oltp.identify_user( acid );
  return(nvl(OLTP.USER_SITE,'SYD'));
 end customer_state;

 procedure lov_list( lname in varchar2, parm in varchar2, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showdesc in boolean DEFAULT TRUE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null )
 as

  cursor c1( lname varchar2, snd varchar2, xtr_a varchar2, xtr_b varchar2 ) is
   select *
   from strang.lov
   where lov_name = lname and
         ((xtr_a is null) or (xtr_a is not null and cola = xtr_a) ) and
         ((xtr_b is null) or (xtr_b is not null and colb = xtr_b) )
   order by decode(snd,'A',code,'B',description);

  cursor c2( cd varchar2, xtr_a varchar2, xtr_b varchar2 ) is
   select *
   from strang.lov
   where lov_name = lname and
         code = cd and
         ((xtr_a is null) or (xtr_a is not null and cola = xtr_a) ) and
         ((xtr_b is null) or (xtr_b is not null and colb = xtr_b) );

  c2rec	c2%ROWTYPE;
  snd	varchar2(10);
  fval	boolean;

 begin

  if showdesc then snd := 'B'; else snd := 'A'; end if;
  fval := false;
  if isedit
   then
    htp.formselectopen( parm );
    if not ismand then htp.formselectoption( NULL ); end if;
    for c1rec in c1( lname, snd, xtr_a, xtr_b ) loop
     if (cd is not null) and (cd = c1rec.code)
      then
       if showdesc
        then
         if showcola
          then
           htp.formselectoption( c1rec.description || '-' || c1rec.cola, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
           fval := TRUE;
          else
           htp.formselectoption( c1rec.description, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
           fval := TRUE;
        end if;
       else
         htp.formselectoption( c1rec.code, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
         fval := TRUE;
       end if;
      else
       if showdesc
        then
         if showcola
          then
           htp.formselectoption( c1rec.description || '-' || c1rec.cola, cattributes=>'VALUE="' || c1rec.code || '"' );
          else
           htp.formselectoption( c1rec.description, cattributes=>'VALUE="' || c1rec.code || '"' );
         end if;
        else
         htp.formselectoption( c1rec.code, cattributes=>'VALUE="' || c1rec.code || '"' );
       end if;
     end if;
     end loop;
    if not fval and cd is not null then htp.formselectoption( cd, 'SELECTED' ); end if;
    htp.formselectclose;
  else

    open c2(cd, xtr_a, xtr_b);
    fetch c2 into c2rec;
    close c2;
    if showdesc
     then
      htp.bold(c2rec.description);
     else
      htp.bold(c2rec.code);
    end if;
  end if;
 exception
  when others then htp.p( sqlerrm );
 end lov_list;

 procedure lov_ship( cd in varchar2, lname in varchar2, val in varchar2 default null, isedit in boolean DEFAULT TRUE )
 as

  cursor c1( lname varchar2 ) is select ship_id,shipname || '-' || voy ||'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ||'  (Ship No '|| sap_ship_id ||')' nm from strang.ships_airway where ship_airway = lname order by shipname,voy;
  cursor c2( shd integer ) is select ship_id,shipname || '-' || voy || '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' ||'  (Ship No '|| sap_ship_id ||')' nm from strang.ships_airway where ship_id = shd;
  cursor c3 is select ship_id from strang.ships_airway where estdepart = (select max(estdepart) from strang.ships_airway);

  c2rec	c2%ROWTYPE;
  c3rec c3%ROWTYPE;

 begin
  if val is null
   then
    open c3;
    fetch c3 into c3rec;
    close c3;
  end if;

  if isedit
   then
    htp.formselectopen( cd );
    for c1rec in c1( lname ) loop
     if c1rec.ship_id = nvl(val,c3rec.ship_id)
        then
         htp.formselectoption( c1rec.nm, 'SELECTED', cattributes=>'VALUE="' || c1rec.ship_id || '"' );
        else
         htp.formselectoption( c1rec.nm, cattributes=>'VALUE="' || c1rec.ship_id || '"' );
     end if;
   end loop;
   htp.formselectclose;
   else
   open c2(nvl(val,c3rec.ship_id));
   fetch c2 into c2rec;
   close c2;
   htp.bold( c2rec.nm );
  end if;
 exception
  when others then htp.p( sqlerrm );
 end lov_ship;

 procedure customer_list( custype in varchar2, parm in varchar2, custid in varchar2 default null, ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE )
 as

  cursor c1( custype varchar2 ) is select customer_id, customer from strang.customers where customer_type = custype order by customer;
  cursor c2( custid integer) is select customer from strang.customers where customer_id = custid;

  c2rec	c2%ROWTYPE;
 begin

  if isedit
   then
    htp.formselectopen( parm );
    if not ismand then htp.formselectoption( NULL ); end if;
    for c1rec in c1( custype ) loop
     if (custid is not null) and (custid = c1rec.customer_id)
      then
       htp.formselectoption( c1rec.customer, 'SELECTED', cattributes=>'VALUE="' || c1rec.customer_id || '"' );
      else
       htp.formselectoption( c1rec.customer, cattributes=>'VALUE="' || c1rec.customer_id || '"' );
     end if;
    end loop;
    htp.formselectclose;
   else
    open c2(custid);
    fetch c2 into c2rec;
    close c2;
    htp.bold(c2rec.customer);
  end if;
 exception
  when others then htp.p( sqlerrm );
 end customer_list;

function pop_up_window(v_features in varchar2, v_title in varchar2 default '_blank')
 return varchar2

as

 v_txt varchar2(32767);

begin
v_txt := '<script LANGUAGE="JavaScript">';
v_txt := v_txt || chr(10) || '<!--';
v_txt := v_txt || chr(10) || 'function popUpWindow(vmsg)';
v_txt := v_txt || chr(10) || '{';
v_txt := v_txt || chr(10) || 'window.open(vmsg,"' || v_title || '","' || v_features || '")';
v_txt := v_txt || chr(10) || '}';
v_txt := v_txt || chr(10) || '// -->';
v_txt := v_txt || chr(10) || '</script>';

return( v_txt );

exception when others then
 return(null);
end pop_up_window;
-- BEGINNING OF CODES
 procedure lov(surl in varchar2, call_name in varchar2, parm in varchar2, lrange in varchar2 default '*', src in varchar2 default null, msg in varchar2 default null, accin varchar2 default 'EDIT', src1 in varchar2 default null )
 as

  cursor c2(lname varchar2, vala varchar2, valb varchar2, src varchar2, src1 varchar2) is
   select /*+ ALL_ROWS */ rowid,lov_name,code,description,cola,colb,colc,cold,cole,colf,colg,colh,coli,colj
   from strang.lov
   where lov_name = lname and
         (
          (src is null and src1 is null and
           substr(upper(code),1,1) >= vala and
           substr(upper(code),1,1) <= valb) or
          (src is not null and src1 is null and code like src || '%') or
          (src is not null and src1 is not null and code like src || '%' and upper(description) like upper(src1) || '%') or
          (src is null and src1 is not null and upper(description) like upper(src1) || '%')
          )
   order by code, decode(lov_name, 'UNRATTAB', to_date(glbx.guess_date(cola))) desc;
--   order by code;
  cursor c3(lname varchar2) is select count('x') tot from strang.lov where lov_name = lname;
  cursor c4(lname varchar2, vala varchar2, valb varchar2) is
   select count('x') tot
   from strang.lov
   where lov_name = lname and substr(upper(code),1,1) >= vala and substr(upper(code),1,1) <= valb;
  cursor c5(lname varchar2) is select max(nvl(to_number(colj),0)) colj from strang.lov where lov_name = lname;
 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 tot_af		integer;
 tot_gm		integer;
 tot_nr		integer;
 tot_sz		integer;
 tot_09		integer;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 low_val	char(1);
 high_val	char(1);
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 vaccess	varchar2(20);
 vaccess2	varchar2(20);
 p2_null	boolean;
 p5d_null	boolean;
 p5e_null	boolean;
 p5f_null	boolean;
 p3_null	boolean;
 p4_null	boolean;
 p5_null	boolean;
 p5g_null	boolean;
 p5h_null	boolean;
 p5i_null	boolean;
 p5j_null	boolean;
 candel		boolean;
 v_row          number;
/*
Controls 	- Desc
Gstcodes	- Desc,Cola
Ctrtype		- Desc,Cola,Colb
Units		- Desc
Invcontrols	- Desc
Packtypes	- Desc
Movements	- Desc
Locations	- Desc
Countries	- Desc,Cola
Contracts	- Desc
Currency        - Desc
Probtypes
Debtor_Branch	- Desc
Debtor_Code	- Desc
Job_Branch	- Desc
Warehouses	- Desc
Profit_Centre	- Desc
Cost_Centre	- Desc

*/

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.LOV' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, parm, null );
  candel := FALSE;
  vaccess2 := data_access( owner_id, 'DELLOV', null );
  if vaccess2 = 'EDIT' then candel := TRUE; end if;

  if parm not in ('INVENT','TARIFF')
   then
    if lrange = '*'
     then
      -- Check range of values and see if it should be broken down
      open c3(parm);
      fetch c3 into c3rec;
      close c3;
      low_val := 'A';
      high_val := 'F';
     else
      low_val := substr(lrange,1,1);
      high_val := substr(lrange,2,1);
    end if;
    if nvl(c3rec.tot,0) > 20 or lrange <> '*'
     then
      open c4(parm,'A','F');
      fetch c4 into tot_af;
      close c4;
      open c4(parm,'G','M');
      fetch c4 into tot_gm;
      close c4;
      open c4(parm,'N','R');
      fetch c4 into tot_nr;
      close c4;
      open c4(parm,'S','Z');
      fetch c4 into tot_sz;
      close c4;
      open c4(parm,'A','F');
      fetch c4 into tot_af;
      close c4;
      open c4(parm,'0','9');
      fetch c4 into tot_09;
      close c4;
      if lrange = '*' and nvl(tot_af,0) = 0
       then
        if lrange = '*' and nvl(tot_gm,0) = 0
         then
          if lrange = '*' and nvl(tot_nr,0) = 0
           then
            if lrange = '*' and nvl(tot_sz,0) = 0
             then
              if lrange = '*' and nvl(tot_09,0) = 0
               then
                low_val := chr(1);
                high_val := chr(255);
               else
                low_val := '0';
                high_val := '9';
              end if;
             else
              low_val := 'S';
              high_val := 'Z';
            end if;
           else
            low_val := 'N';
            high_val := 'R';
          end if;
         else
          low_val := 'G';
          high_val := 'M';
        end if;
      end if;
     else
      low_val := '0';
      high_val := 'Z';
    end if;
  end if;

  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );
  glbx.main_title( surl, LNGS.STR_TXT_001 || ': ' || parm, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR01',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour,jscript=>'DISABLE', disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc );
  htp.nl;
  if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
--  if vaccess = 'READ' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
  htp.p( '<CENTER>' );
  if msg is not null then glbx.header_msg( msg ); end if;
  if parm not in ('INVENT','TARIFF')
   then
    if nvl(c3rec.tot,0) > 20 or lrange <> '*'
     then
      htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
      htp.tablerowopen;
       if nvl(tot_af,0) > 0 then htp.tabledata( htf.anchor( 'strangp.lov?surl=' || surl || '&call_name=&parm=' || replace(parm,' ','+') || '&lrange=AF','[A-F]'), cattributes=>'align="CENTER"'); end if;
       if nvl(tot_gm,0) > 0 then htp.tabledata( htf.anchor( 'strangp.lov?surl=' || surl || '&call_name=&parm=' || replace(parm,' ','+') || '&lrange=GM','[G-M]'), cattributes=>'align="CENTER"'); end if;
       if nvl(tot_nr,0) > 0 then htp.tabledata( htf.anchor( 'strangp.lov?surl=' || surl || '&call_name=&parm=' || replace(parm,' ','+') || '&lrange=NR','[N-R]'), cattributes=>'align="CENTER"'); end if;
       if nvl(tot_sz,0) > 0 then htp.tabledata( htf.anchor( 'strangp.lov?surl=' || surl || '&call_name=&parm=' || replace(parm,' ','+') || '&lrange=SZ','[S-Z]'), cattributes=>'align="CENTER"'); end if;
       if nvl(tot_09,0) > 0 then htp.tabledata( htf.anchor( 'strangp.lov?surl=' || surl || '&call_name=&parm=' || replace(parm,' ','+') || '&lrange=09','[0-9]'), cattributes=>'align="CENTER"'); end if;
      htp.tablerowclose;
      htp.tablerowopen;
       if nvl(tot_af,0) > 0 then htp.tabledata( to_char(tot_af), cattributes=>'align="CENTER"'); end if;
       if nvl(tot_gm,0) > 0 then htp.tabledata( to_char(tot_gm), cattributes=>'align="CENTER"'); end if;
       if nvl(tot_nr,0) > 0 then htp.tabledata( to_char(tot_nr), cattributes=>'align="CENTER"'); end if;
       if nvl(tot_sz,0) > 0 then htp.tabledata( to_char(tot_sz), cattributes=>'align="CENTER"'); end if;
       if nvl(tot_09,0) > 0 then htp.tabledata( to_char(tot_09), cattributes=>'align="CENTER"'); end if;
      htp.tablerowclose;
      htp.tableclose;
    end if;
  end if;
  htp.nl;
  htp.tableopen;
   htp.tablerowopen;
    htp.tabledata( 'Code', cattributes=>'valign="TOP" align="CENTER"'  );
    htp.tabledata( htf.formopen( 'strangp.lov' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'CALL_NAME', call_name ) || htf.formhidden( 'PARM', parm ) || htf.formhidden( 'LRANGE', low_val || high_val ) || htf.formtext( 'SRC', 10, 30, null ), cattributes=>'valign="TOP" align="CENTER"'  );
    htp.tabledata( 'Description', cattributes=>'valign="TOP" align="CENTER"'  );
    htp.tabledata( htf.formtext( 'SRC1', 40, 40, null ), cattributes=>'valign="TOP" align="CENTER"' );
    htp.tabledata( htf.formsubmit( null, LNGS.STR_TXT_003 ) || htf.formclose, cattributes=>'valign="TOP" align="CENTER"' );
   htp.tablerowclose;
  htp.tableclose;
  --htp.nl;
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  if vaccess = 'EDIT'
   then
    htp.formopen( 'strangp.accept_lov' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'PARM', parm );
    htp.formhidden( 'SRC', src);
    htp.formhidden( 'SRC1', src1);
    /*
    htp.formhidden( 'p5d', NULL);
    htp.formhidden( 'p5e', NULL);
    htp.formhidden( 'p5f', NULL);
    htp.formhidden( 'P5G', NULL);
    htp.formhidden( 'P5H', NULL);
    htp.formhidden( 'P5I', NULL);
    htp.formhidden( 'P5J', NULL);
    */
    htp.formhidden( 'LRANGE', low_val || high_val );
  end if;
    htp.tablerowopen;
    -- Code
    if parm = 'INVENT'
     then
      htp.tabledata( LNGS.STR_TXT_004, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    elsif parm = 'TARIFF'
     then
      htp.tabledata( LNGS.STR_TXT_005, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
     else
      htp.tabledata( LNGS.STR_TXT_006, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    -- Description
    if parm in ('CONTROLS','GSTCODES','CTRTYPE','UNITS','INVCONTROLS','PACKTYPES','MOVEMENTS','LOCATIONS','COUNTRIES','CONTRACTS','CURRENCY','DEBTOR_BRANCH','DEBTOR_CODE','JOB_BRANCH','PROFIT_CENTRE','COST_CENTRE','WAREHOUSES',
                'UNCUOTAB','UNDECTAB','UNMODTAB','UNCP1TAB','UNCMPTAB','UNCTYTAB','UNCAPTAB','UNREGTAB',
                'UNTODTAB','UNCURTAB','UNTR1TAB','UNTR2TAB','UNMOTTAB','UNLOCTAB','UNTOPTAB','UNSHDTAB',
                'UNBNKTAB','UNBRATAB','UNWHSTAB','UNTARTAB','UNPKGTAB','UNPRFTAB','UNCP4TAB',
                'UNCP3TAB','UNATDTAB','UNCTNTAB','UNINDTAB','UNSEATAB'
               )
     then
      htp.tabledata( LNGS.STR_TXT_007, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    elsif parm = 'INVENT'
     then
      htp.tabledata( LNGS.STR_TXT_007, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    elsif parm = 'UNRATTAB'
     then
      htp.tabledata( 'Exchange Rate', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;


    -- Cola
    if parm in ('COUNTRIES')
     then
      htp.tabledata( LNGS.STR_TXT_009, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    -- Cola
    if parm in ('UNCTNTAB')
     then
      htp.tabledata( LNGS.STR_TXT_009, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;


    -- Cola
    if parm in ('COST_CENTRE')
     then
      htp.tabledata( 'Transaction Type', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'GST Applicable', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    -- Cola
    if parm in ('CONTROLS')
     then
      htp.tabledata( LNGS.STR_TXT_328, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    -- Cola, Colb
    if parm in ('PACKTYPES')
     then
      htp.tabledata( 'OTML Type', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'UNPKGTAB Description', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    if parm in ('GSTCODES')
     then
      htp.tabledata( LNGS.STR_TXT_105, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( LNGS.STR_TXT_365, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    if parm in ('LOCATIONS')
     then
      htp.tabledata( LNGS.STR_TXT_382, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( LNGS.STR_TXT_383, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    -- Colb and Colc
    if parm = 'CTRTYPE'
     then
      htp.tabledata( LNGS.STR_TXT_010, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( LNGS.STR_TXT_011, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( LNGS.STR_TXT_381, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    -- Colb and Colc
    if parm = 'INVENT'
     then
      htp.tabledata( LNGS.STR_TXT_005, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    -- Description, cola, Colb and Colc
    if parm = 'TARIFF'
     then
      htp.tabledata( 'Description', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'Precision 1', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'Precision 2', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( LNGS.STR_TXT_214, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( LNGS.STR_TXT_101, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( LNGS.STR_TXT_013, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( LNGS.STR_TXT_014, cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'Excise Calc', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'Charge', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'Unit', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'Single Charge', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;
--      htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );


-- UN CODES FOR SADS
    -- Cola
    if parm in ('UNREGTAB')
     then
      htp.tabledata( 'City Code', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;


    if parm in ('UNPKGTAB')
     then
      htp.tabledata( 'Bulk', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    -- Cola, Colb

    if parm in ('UNCP3TAB')
     then
      htp.tabledata( 'RUL_COD', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CP3_AGR', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    if parm in ('UNPRFTAB')
     then
      htp.tabledata( 'RUL_COD', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'PRF_QUO', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

-- Cola, Colb, Colc
    if parm in ('UNRATTAB')
     then
      htp.tabledata( 'Valid From', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'Valid Until', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
 --     htp.tabledata( 'CUR_REF', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    if parm in ('UNMODTAB')
     then
      htp.tabledata( 'MOD_FLW', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CUS_SER', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'ASS_SER', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    if parm in ('UNCAPTAB')
     then
      htp.tabledata( 'EEA_EOV', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CAP_DSC', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CAP_LIC', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

-- Cola, Colb, Colc, Cold
    if parm in ('UNCP4TAB')
     then
      htp.tabledata( 'CPR_COD', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CPP_COD', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'SPE_TRA', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'GEN_TRA', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

-- Cola, Colb, Colc, Cold, Cole, Colf
    if parm in ('UNBNKTAB','UNWHSTAB','UNCUOTAB','UNDECTAB')
     then
      htp.tabledata( 'ADDRESS1', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'ADDRESS2', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'ADDRESS3', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'ADDRESS4', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'TELEPHONE', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'FAX', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

-- Cola, Colb, Colc, Cold, Cole, Colf, Colg

    if parm in ('UNBRATAB')
     then
      htp.tabledata( 'BRA_NAM', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'BRA_ADR', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'BRA_AD2', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'BRA_AD3', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'BRA_AD4', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'BRA_TEL', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'BRA_FAX', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

    if parm in ('UNCMPTAB')
     then
      htp.tabledata( 'CMP_ADR', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CMP_AD2', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CMP_AD3', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CMP_AD4', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CMP_TEL', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CMP_FAX', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'CMP_TLX', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

-- Cola, Colb, Colc, Cold, Cole, Colf, Colg, Colh, Coli
    if parm in ('UNSHDTAB')
     then
      htp.tabledata( 'EEA_DOV', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'EEA_EOV', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'SHD_ADR', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'SHD_AD2', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'SHD_AD3', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'SHD_AD4', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'SHD_TEL', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'SHD_FAX', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
      htp.tabledata( 'SHD_PUB', cattributes=>glbx.QUERY_BACKGROUND || 'valign="CENTER" align="CENTER"' );
    end if;

   htp.tablerowclose;

  if accin = 'EDIT'
   then
  for c2rec in c2( parm, low_val, high_val, src, src1 ) loop
   p2_null := FALSE;
   p5d_null := TRUE; --htp.formhidden( 'p5d', null );
   p5e_null := TRUE; --htp.formhidden( 'p5e', null );
   p5f_null := TRUE; --htp.formhidden( 'p5f', null );
   p3_null := FALSE;
   p4_null := FALSE;
   p5_null := FALSE;
   p5g_null := TRUE; --htp.formhidden( 'P5g', null );
   p5h_null := TRUE; --htp.formhidden( 'P5h', null );
   p5i_null := TRUE; --htp.formhidden( 'P5i', null );
   p5j_null := TRUE; --htp.formhidden( 'P5j', null );
   htp.tablerowopen;
-- Code
   if vaccess = 'EDIT'
    then
    if parm in ('PROFIT_CENTRE')
     then
      htp.tabledata( htf.formhidden( 'P0', c2rec.code ) || htf.formtext( 'P1', 20, 20, c2rec.code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
     else
      htp.tabledata( htf.formhidden( 'P0', c2rec.code ) || htf.formtext( 'P1', 30, 100, c2rec.code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
    end if;
-- Description
      if parm in ('CONTROLS','GSTCODES','CTRTYPE','UNITS','INVCONTROLS','PACKTYPES','MOVEMENTS','LOCATIONS','CONTRACTS','CURRENCY','DEBTOR_BRANCH','DEBTOR_CODE','JOB_BRANCH','COST_CENTRE','PROFIT_CENTRE','WAREHOUSES',
                  'UNCUOTAB','UNDECTAB','UNMODTAB','UNCP1TAB','UNCMPTAB','UNCTYTAB','UNCAPTAB','UNREGTAB',
		  'UNTODTAB','UNCURTAB','UNTR1TAB','UNTR2TAB','UNMOTTAB','UNLOCTAB','UNTOPTAB','UNSHDTAB',
		  'UNBNKTAB','UNBRATAB','UNWHSTAB','UNRATTAB','UNTARTAB','UNPKGTAB','UNPRFTAB','UNCP4TAB',
		  'UNCP3TAB','UNATDTAB','UNCTNTAB','UNINDTAB','UNSEATAB'
                  )
       then
        htp.tabledata( htf.formtext( 'P2', 30, 1000, replace(c2rec.description,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
      elsif parm in ('TARIFF')
       then
        htp.tabledata( htf.formtext( 'p5d', 30, 100, replace(c2rec.cold,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
        htp.tabledata( htf.formtext( 'p5e', 3, 100, replace(c2rec.cole,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
        htp.tabledata( htf.formtext( 'p5f', 4, 100, replace(c2rec.colf,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
        htp.tabledata( htf.formtext( 'P2',  10, 100, replace(c2rec.description,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
        p5d_null := FALSE; --htp.formhidden( 'p5d', null );
        p5e_null := FALSE; --htp.formhidden( 'p5e', null );
        p5f_null := FALSE; --htp.formhidden( 'p5f', null );
      elsif parm in ('INVENT')
       then
        htp.tabledata( htf.formtext( 'P2', 90, 1000, replace(c2rec.description,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
      elsif parm in ('COUNTRIES')
       then
        htp.tabledata( htf.formtext( 'P2', 40, 1000, replace(c2rec.description,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       else
        p2_null := TRUE; --htp.formhidden( 'P2', null );
      end if;
-- Cola
      if parm in ('COST_CENTRE')
       then
        htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT">' );
        htp.formselectopen( 'P3' );
         htp.formselectoption( null );
         if c2rec.cola = 'S' then htp.formselectoption( 'S', 'SELECTED' ); else htp.formselectoption( 'S' ); end if;
         if c2rec.cola = 'C' then htp.formselectoption( 'C', 'SELECTED' ); else htp.formselectoption( 'C' ); end if;
        htp.formselectclose;
        htp.p( '</TD>' );
        htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT">' );
        htp.formselectopen( 'P4' );
         htp.formselectoption( null );
         if c2rec.colb = 'GST' then htp.formselectoption( 'GST', 'SELECTED' ); else htp.formselectoption( 'GST' ); end if;
         if c2rec.colb = 'NO_GST' then htp.formselectoption( 'NO_GST', 'SELECTED' ); else htp.formselectoption( 'NO_GST' ); end if;
        htp.formselectclose;
        htp.p( '</TD>' );

      elsif parm in ('GSTCODES','COUNTRIES','CTRTYPE','TARIFF','INVENT','LOCATIONS','CONTROLS','PACKTYPES',
      		    'UNCTNTAB','UNCUOTAB','UNDECTAB','UNMODTAB','UNCMPTAB','UNCAPTAB','UNREGTAB','UNSHDTAB','UNBNKTAB',
                    'UNBRATAB','UNWHSTAB','UNRATTAB','UNTARTAB','UNPKGTAB','UNPRFTAB','UNCP4TAB','UNCP3TAB'
      		    )
       then
        if parm = 'LOCATIONS'
         then
          htp.tabledata( htf.formtext( 'P3', 20, 100, replace(c2rec.cola,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
         elsif parm = 'PACKTYPES'
          then
          htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT">' );
          htp.formselectopen( 'P3' );
          if c2rec.cola is null or c2rec.cola = 'LC' then htp.formselectoption( 'LC', 'SELECTED' ); else htp.formselectoption( 'LC' ); end if;
          if c2rec.cola = 'CT' then htp.formselectoption( 'CT', 'SELECTED' ); else htp.formselectoption( 'CT' ); end if;
          htp.formselectclose;
          htp.p( '</TD>' );
         elsif parm = 'TARIFF'
          then
            htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
	    lov_list( 'UNITS', 'P3', c2rec.cola, TRUE, FALSE, TRUE );
	    htp.p( '</TD>' );
         else
          htp.tabledata( htf.formtext( 'P3', 10, 100, replace(c2rec.cola,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
         end if;
      else
        p3_null := TRUE; --htp.formhidden( 'P3', null );
      end if;
-- Colb
      if parm in ('CTRTYPE','TARIFF','GSTCODES','LOCATIONS','PACKTYPES',
                  'UNCUOTAB','UNDECTAB','UNMODTAB','UNCMPTAB','UNCAPTAB','UNSHDTAB','UNBNKTAB',
                  'UNBRATAB','UNWHSTAB','UNRATTAB','UNTARTAB','UNPRFTAB','UNCP4TAB','UNCP3TAB'
                  )
       then
        if parm = 'GSTCODES'
         then
          htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT">' );
          htp.formselectopen( 'P4' );
          if c2rec.colb is null or c2rec.colb = LNGS.STR_TXT_366 then htp.formselectoption( LNGS.STR_TXT_366, 'SELECTED' ); else htp.formselectoption( LNGS.STR_TXT_366 ); end if;
          if c2rec.colb = LNGS.STR_TXT_367 then htp.formselectoption( LNGS.STR_TXT_367, 'SELECTED' ); else htp.formselectoption( LNGS.STR_TXT_367 ); end if;
          if c2rec.colb = LNGS.STR_TXT_368 then htp.formselectoption( LNGS.STR_TXT_368, 'SELECTED' ); else htp.formselectoption( LNGS.STR_TXT_368 ); end if;
          htp.formselectclose;
          htp.p( '</TD>' );
         elsif parm = 'LOCATIONS'
          then
           htp.tabledata( htf.formtext( 'P4', 20, 100, replace(c2rec.colb,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
         elsif parm = 'PACKTYPES'
          then
	     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
	     lov_list( 'UNPKGTAB', 'P4', c2rec.colb, TRUE, TRUE, FALSE );
	     htp.p( '</TD>' );
--           htp.tabledata( htf.formtext( 'P4', 20, 100, replace(c2rec.colb,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
         else
          htp.tabledata( htf.formtext( 'P4', 10, 100, replace(c2rec.colb,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
        end if;
       else
        p4_null := TRUE; --htp.formhidden( 'P4', null );
      end if;
-- Colc

      if parm = 'TARIFF'
       then
          htp.tabledata( htf.formtext( 'P5', 10, 100, replace(c2rec.colc,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
--
          htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT">' );
          htp.formselectopen( 'P5g' );
          if c2rec.colg is null or c2rec.colg = 'NONE' then htp.formselectoption( 'NONE', 'SELECTED' ); else htp.formselectoption( 'NONE' ); end if;
          if c2rec.colg = 'BOTH' then htp.formselectoption( 'BOTH', 'SELECTED' ); else htp.formselectoption( 'BOTH' ); end if;
          if c2rec.colg = 'HIGHER' then htp.formselectoption( 'HIGHER', 'SELECTED' ); else htp.formselectoption( 'HIGHER' ); end if;
          if c2rec.colg = 'LOWER' then htp.formselectoption( 'LOWER', 'SELECTED' ); else htp.formselectoption( 'LOWER' ); end if;
          htp.formselectclose;
          htp.p( '</TD>' );
          htp.tabledata( htf.formtext( 'P5h', 10, 100, replace(c2rec.colh,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
	  htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
	  lov_list( 'UNITS', 'P5i', c2rec.coli, FALSE, FALSE, TRUE );
	  htp.p( '</TD>' );
          htp.tabledata( htf.formtext( 'P5j', 10, 100, replace(c2rec.colj,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
          p5g_null := FALSE; --htp.formhidden( 'P5g', null );
          p5h_null := FALSE; --htp.formhidden( 'P5h', null );
          p5i_null := FALSE; --htp.formhidden( 'P5i', null );
          p5j_null := FALSE; --htp.formhidden( 'P5j', null );
       elsif parm in ('CTRTYPE','UNCUOTAB','UNDECTAB','UNMODTAB','UNCMPTAB','UNCAPTAB','UNSHDTAB','UNBNKTAB',
                      'UNBRATAB','UNWHSTAB','UNTARTAB','UNCP4TAB'
                      )
        then
          htp.tabledata( htf.formtext( 'P5', 10, 100, replace(c2rec.colc,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );

       else
        p5_null := TRUE; --htp.formhidden( 'P5', null );
      end if;
-- Cold
      if parm in ('UNCUOTAB','UNDECTAB','UNCMPTAB','UNSHDTAB','UNBNKTAB',
                  'UNBRATAB','UNWHSTAB','UNTARTAB','UNCP4TAB'
                 )
      then
          htp.tabledata( htf.formtext( 'p5d', 10, 100, replace(c2rec.cold,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       else
        p5d_null := TRUE; --htp.formhidden( 'p5d', null );
      end if;
-- Cole & Colf
      if parm in ('UNCUOTAB','UNDECTAB','UNCMPTAB','UNSHDTAB','UNBNKTAB',
                  'UNBRATAB','UNWHSTAB','UNTARTAB'
                 )
      then
          htp.tabledata( htf.formtext( 'p5e', 10, 100, replace(c2rec.cole,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
          htp.tabledata( htf.formtext( 'p5f', 10, 100, replace(c2rec.colf,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       else
        p5e_null := TRUE; --htp.formhidden( 'p5e', null );
        p5f_null := TRUE; --htp.formhidden( 'p5f', null );
      end if;
-- Colg
      if parm in ('UNCMPTAB','UNSHDTAB','UNBRATAB')
      then
          htp.tabledata( htf.formtext( 'P5g', 10, 100, replace(c2rec.colg,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       else
        p5g_null := TRUE; --htp.formhidden( 'P5g', null );
      end if;
-- Colh & Coli
      if parm = 'UNSHDTAB'
      then
          htp.tabledata( htf.formtext( 'P5h', 10, 100, replace(c2rec.colh,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
          htp.tabledata( htf.formtext( 'P5i', 10, 100, replace(c2rec.coli,'"','&#34;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       else
        p5h_null := TRUE; --htp.formhidden( 'P5h', null );
        p5i_null := TRUE; --htp.formhidden( 'P5i', null );
      end if;
      if parm = 'UNRATTAB'
      then
        htp.formhidden( 'P5J', c2rec.colj);
		htp.formhidden( 'P5I', c2rec.rowid);
      end if;
-- >>>
      if candel
       then
        if parm in ('UNRATTAB')
		 then
 		  htp.tabledata( htf.anchor( 'strangp.accept_lov?surl=' || surl || '&parm=' || replace(parm,' ','+') || '&src=' || replace(src,' ','+') || '&src1=' || replace(src1,' ','+') || '&lrange=' || low_val || high_val ||
                                   '&action=' || LNGS.STR_TXT_151 || '&p0=' || replace(c2rec.code,' ','+') || '&p1=&p2=&p5d=&p5e=&p5f=&p3=' || replace(c2rec.cola,' ','+') || '&p4=&p5=&p5g=&p5h=&p5i=' || replace(c2rec.rowid,'+','~') || '&p5j=', LNGS.STR_TXT_151 ) );
		else
		  htp.tabledata( htf.anchor( 'strangp.accept_lov?surl=' || surl || '&parm=' || replace(parm,' ','+') || '&src=' || replace(src,' ','+') || '&src1=' || replace(src1,' ','+') || '&lrange=' || low_val || high_val ||
                                   '&action=' || LNGS.STR_TXT_151 || '&p0=' || replace(c2rec.code,' ','+') || '&p1=&p2=&p5d=&p5e=&p5f=&p3=' || replace(c2rec.cola,' ','+') || '&p4=&p5=&p5g=&p5h=&p5i=&p5j=', LNGS.STR_TXT_151 ) );
        end if;
	  end if;
    else
     htp.tabledata( htf.bold( c2rec.code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
     htp.tabledata( htf.bold( c2rec.description ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
     htp.tabledata( htf.bold( c2rec.cola ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
     htp.tabledata( htf.bold( c2rec.colb ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
     htp.tabledata( htf.bold( c2rec.colc ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
    end if;

    -- Put here to try and get around an IE6 issue of displaying blank lines when using Formhidden
    if parm in ('COST_CENTRE') then p3_null := FALSE; p4_null := FALSE; end if;
    if parm in ('UNRATTAB') then p2_null := FALSE; p3_null := FALSE; p4_null := FALSE; p5_null := FALSE; end if;

    if p2_null or p3_null or p4_null or p5_null
     then
      htp.p('<TD>' );
      if p2_null then htp.formhidden( 'P2', null ); end if;
      if p5d_null then htp.formhidden( 'p5d', null ); end if;
      if p5e_null then htp.formhidden( 'p5e', null ); end if;
      if p5f_null then htp.formhidden( 'p5f', null ); end if;
      if p3_null then htp.formhidden( 'P3', null ); end if;
      if p4_null then htp.formhidden( 'P4', null ); end if;
      if p5_null then htp.formhidden( 'P5', null ); end if;
      if p5g_null then htp.formhidden( 'P5g', null ); end if;
      if p5h_null then htp.formhidden( 'P5h', null ); end if;
      if p5i_null then htp.formhidden( 'P5i', null ); end if;
      if p5j_null then htp.formhidden( 'P5j', null ); end if;
      htp.p( '&nbsp;' );
      htp.p( '</TD>' );
    end if;

   htp.tablerowclose;
   end loop;
  end if;

  if vaccess = 'EDIT' and accin = 'INSERT'
   then
    for j in 1..5 loop
     htp.tablerowopen;
    if parm in ('PROFIT_CENTRE')
     then
      htp.tabledata( htf.formhidden( 'P0', null ) || htf.formtext( 'P1', 20, 20, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
     else
      htp.tabledata( htf.formhidden( 'P0', null ) || htf.formtext( 'P1', 30, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
    end if;

      if parm in ('CONTROLS','GSTCODES','CTRTYPE','UNITS','INVCONTROLS','PACKTYPES','MOVEMENTS','LOCATIONS','CONTRACTS','CURRENCY','DEBTOR_BRANCH',
                  'DEBTOR_CODE','JOB_BRANCH','COST_CENTRE','PROFIT_CENTRE','WAREHOUSES','UNRATTAB')
       then
        htp.tabledata( htf.formtext( 'P2', 30, 1000, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
      elsif parm in ('TARIFF')
       then
       htp.tabledata( htf.formtext( 'p5d', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'p5e', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'p5f', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
        htp.tabledata( htf.formtext( 'P2', 10, 1000, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
      elsif parm in ('INVENT')
       then
        htp.tabledata( htf.formtext( 'P2', 90, 1000, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
      elsif parm in ('COUNTRIES')
       then
        htp.tabledata( htf.formtext( 'P2', 40, 1000, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       else
        htp.formhidden( 'P2', null );
      end if;

      if parm in ('COST_CENTRE')
       then
        htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT">' );
        htp.formselectopen( 'P3' );
         htp.formselectoption( null, 'SELECTED' );
          htp.formselectoption( 'S' );
          htp.formselectoption( 'C' );
        htp.formselectclose;
        htp.p( '</TD>' );
        htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT">' );
        htp.formselectopen( 'P4' );
         htp.formselectoption( null, 'SELECTED' );
         htp.formselectoption( 'GST' );
         htp.formselectoption( 'NO_GST' );
        htp.formselectclose;
        htp.p( '</TD>' );

      elsif parm in ('GSTCODES','COUNTRIES','CTRTYPE','TARIFF','INVENT','LOCATIONS','CONTROLS')
       then
        htp.tabledata( htf.formtext( 'P3', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       else
        if parm in('UNRATTAB') then null; else htp.formhidden( 'P3', null ); end if;
      end if;
     if parm in ('CTRTYPE','TARIFF','GSTCODES','LOCATIONS')
      then
       htp.tabledata( htf.formtext( 'P4', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       else
        if parm in('COST_CENTRE','UNRATTAB') then null; else htp.formhidden( 'P4', null ); end if;
      end if;
     if parm in ('UNRATTAB')
      then
       htp.tabledata( htf.formtext( 'P3', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P4', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       v_row := null;
       open c5(parm);
        fetch c5 into c5rec;
        v_row := c5rec.colj;
       close c5;
 --      -- find max value colj for UNRATTAB
 --      -- select max(to_number(colj) into v_row from lov where lov_name = 'UNRATTAB';
 --      -- nvl(0);
 --
       v_row := nvl(v_row, 0) + j;
       htp.formhidden( 'P5J', v_row );
     end if;
     if parm in ('TARIFF')
      then
       htp.tabledata( htf.formtext( 'P5', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5G', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5H', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5I', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5J', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
      elsif parm in ('CTRTYPE')
      then
       htp.tabledata( htf.formtext( 'P5', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'p5d', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'p5e', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'p5f', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5G', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5H', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5I', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       htp.tabledata( htf.formtext( 'P5J', 10, 100, null ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'valign="CENTER" align="LEFT"' );
       elsif parm not in ('UNRATTAB','CTRTYPE','TARIFF')
        then
        htp.formhidden( 'P5', null );
      end if;

    htp.tablerowclose;
    end loop;
  end if;

  htp.tableclose;
  htp.nl;
  if vaccess = 'EDIT'
   then
    htp.formhidden( 'P0', null );
    htp.formhidden( 'P1', null );
    htp.formhidden( 'P2', null );
    htp.formhidden( 'p5d', null );
    htp.formhidden( 'p5e', null );
    htp.formhidden( 'p5f', null );
    htp.formhidden( 'P3', null );
    htp.formhidden( 'P4', null );
    htp.formhidden( 'P5', null );
    htp.formhidden( 'P5g', null );
    htp.formhidden( 'P5h', null );
    htp.formhidden( 'P5i', null );
    htp.formhidden( 'P5j', null );
    if accin = 'INSERT'
     then
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_357 );
     else
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_358 );
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_357 );
    end if;
    htp.formsubmit( 'ACTION', LNGS.STR_TXT_016 );
   htp.formclose;
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'LOV',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end lov;

procedure accept_lov( surl in varchar2, parm in varchar2, lrange in varchar2, action in varchar2, src in varchar2,
                      p0 in GLBX.MYARRAY default strangp.empty_array, p1 in GLBX.MYARRAY default strangp.empty_array,
                      p2 in GLBX.MYARRAY default strangp.empty_array, p3 in GLBX.MYARRAY default strangp.empty_array,
                      p4 in GLBX.MYARRAY default strangp.empty_array, p5 in GLBX.MYARRAY default strangp.empty_array,
                      p5d in GLBX.MYARRAY default strangp.empty_array,p5e in GLBX.MYARRAY default strangp.empty_array,
                      p5f in GLBX.MYARRAY default strangp.empty_array, p5g in GLBX.MYARRAY default strangp.empty_array,
                      p5h in GLBX.MYARRAY default strangp.empty_array, p5i in GLBX.MYARRAY default strangp.empty_array,
                      p5j in GLBX.MYARRAY default strangp.empty_array, src1 in varchar2 default null )
as

 cursor c1( lname varchar2, cd varchar2 ) is select 'x' from strang.lov where lov_name = lname and code = cd;
 cursor c1a( lname varchar2, cd varchar2, ca varchar2 ) is select 'x' from strang.lov where lov_name = lname and code = cd and cola = ca;
 cursor c2( inv varchar2 ) is select recno from strang.pos where inventoryno = inv;
 cursor c3( tarf varchar2 ) is select 'x' from strang.lov where lov_name = 'TARIFF' and code = tarf;
 cursor c4(lname varchar2, lcode varchar2, f_date varchar2, t_date varchar2, rid rowid) is
  select *
  from   strang.lov
  where  lov_name = lname
         and code = upper(lcode)
         and rowid <> rid
         and ( ( to_date(f_date) >= to_date(cola) and to_date(f_date) <= to_date(colb))
              or
               (to_date(t_date) >= to_date(cola) and to_date(t_date) <= to_date(colb))
             )
  ;

 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 dummy		char(1);
 msg		varchar2(1000);
 nctr		integer;
 uctr		integer;
 dctr		integer;
 v_from         varchar2(100);
 v_to           varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_LOV' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  for j in p0.first..p0.last loop
  nctr := 0;
  uctr := 0;
  dctr := 0;
  if p0(j) is null and p1(j) is not null
   then
    -- New Record
    if parm <> 'CONTROLS'
     then
      if parm = 'UNRATTAB'
      then
      /*
      open c1a( parm, upper(p1(j)), upper(p3(j)) );
      fetch c1a into dummy;
      if c1a%FOUND
       then
        close c1a;
        commit;
        lov(surl,null,parm,lrange,src,LNGS.STR_TXT_017 || ':' || upper(p1(j)) ||  ' Date: '|| ':' || upper(p3(j)) || ' ' || 'Currency Period Already Exists',src1=>src1);
        return;
       else
        close c1a;
      end if;
      */
      null;
      else
      open c1( parm, upper(p1(j)) );
      fetch c1 into dummy;
      if c1%FOUND
       then
        close c1;
        commit;
        lov(surl,null,parm,lrange,src,LNGS.STR_TXT_017 || ':' || upper(p1(j)) || ' ' || LNGS.STR_TXT_018,src1=>src1);
        return;
       else
        close c1;
      end if;
     end if;
    end if;
    if parm = 'INVENT' and p3(j) is not null
     then
      open c3(p3(j));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        lov(surl,null,parm,lrange,src,LNGS.STR_TXT_346 || ':' || p3(j),src1=>src1);
        return;
      end if;
      close c3;
    end if;
    if parm = 'TARIFF' and (p2(j) is null or p4(j) is null or p5(j) is null)
     then
      commit;
      lov(surl,null,parm,lrange,src,LNGS.STR_TXT_345,src1=>src1);
      return;
     else
      if parm = 'COST_CENTRE' and p3(j) is null
       then
        lov(surl,null,parm,lrange,src,'Must Specify a Transaction Type',src1=>src1);
        return;
       elsif
         parm = 'TARIFF'
         then
        insert into strang.lov(lov_name,code,description,cola,colb,colc,cold,cole,colf,colg,colh,coli,colj) values
        (parm,upper(p1(j)),p2(j),p3(j),p4(j),p5(j),p5d(j),p5e(j),p5f(j),p5g(j),p5h(j),p5i(j),p5j(j));
       else
        insert into strang.lov(lov_name,code,description,cola,colb,colc) values (parm,upper(p1(j)),p2(j),upper(p3(j)),upper(p4(j)),p5(j));
     end if;
    end if;
    nctr := nctr + 1;

  elsif (p0(j) is not null and p1(j) is null) or (action = LNGS.STR_TXT_151)
   then
    -- Delete LOV
    -- If Invent check does not delete in PO
    if parm = 'INVENT'
     then
      open c2(p0(j));
      fetch c2 into c2rec;
      if c2%FOUND
       then
        close c2;
        commit;
        lov(surl,null,parm,lrange,src,LNGS.STR_TXT_019 || ':' || upper(p0(j)) || ' ' || ' ' || LNGS.STR_TXT_020 || ' (Recno ' || c2rec.recno || ' ).',src1=>src1);
        return;
      end if;
      close c2;
      delete from strang.lov where lov_name = parm and code = p0(j) and nvl(cola,'!') = nvl(p3(j),'!');
     else
      delete from strang.lov where lov_name = parm and code = p0(j) and nvl(cola,'!') = nvl(p3(j),'!');
    end if;
    dctr := dctr + 1;
    -- Cascade Delete

  elsif p0(j) is not null and p1(j) is not null and p0(j) <> upper(p1(j))
   then
    -- Update Primary Key
    if parm <> 'CONTROLS'
     then
      open c1( parm, upper(p1(j)) );
      fetch c1 into dummy;
      if c1%FOUND
       then
        close c1;
        commit;
        lov(surl,null,parm,lrange,src,LNGS.STR_TXT_017 || ':' || upper(p1(j)) || ' ' || LNGS.STR_TXT_018,src1=>src1);
        return;
       else
        close c1;
      end if;
    end if;
    if parm = 'INVENT' and p3(j) is not null
     then
      open c3(p3(j));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        lov(surl,null,parm,lrange,src,LNGS.STR_TXT_346 || ':' || p3(j),src1=>src1);
        return;
      end if;
      close c3;
    end if;
    if parm = 'TARIFF' and (p2(j) is null or p4(j) is null or p5(j) is null)
     then
      commit;
      lov(surl,null,parm,lrange,src,LNGS.STR_TXT_345,src1=>src1);
      return;
    end if;
    if parm = 'CONTROLS'
     then
      update strang.lov
       set
        code = upper(p1(j)),
        description = p2(j),
        cola = p3(j),
        colb = p4(j),
        colc = p5(j)
      where
       lov_name = parm and
       code = p0(j) and
       nvl(cola,'!') = nvl(p3(j),'!');
     elsif parm = 'TARIFF'
      then
       update strang.lov
        set
        code = upper(p1(j)),
        description = p2(j),
        cola = p3(j),
        colb = p4(j),
        colc = p5(j),
        cold = p5d(j),
        cole = p5e(j),
        colf = p5f(j),
        colg = p5g(j),
        colh = p5h(j),
        coli = p5i(j),
        colj = p5j(j)
      where
       lov_name = parm and
       code = p0(j);
     elsif parm = 'UNRATTAB'
      then
       update strang.lov
        set
        code = upper(p1(j))
      , description = p2(j)
      , cola = upper(p3(j))
      , colb = upper(p4(j))
      -- , colc = p5(j)
      where
       rowid = p5i(j)
       /*
       lov_name = parm and
       code = p0(j) and
       colj = p5j(j)
       */
       ;
     else
       update strang.lov
        set
        code = upper(p1(j)),
        description = p2(j),
        cola = p3(j),
        colb = p4(j),
        colc = p5(j)
      where
       lov_name = parm and
       code = p0(j);
    end if;
    if parm = 'COST_CENTRE'
     then
      update strang.lov
       set
        cola = upper(p3(j)),
        colb = p4(j)
      where
       lov_name = parm and
       code = p0(j);
      if upper(p3(j)) not in ('S','C') and parm = 'COST_CENTRE'
       then
        update strang.lov
         set
          cola = 'S'
        where
         lov_name = parm and
         code = p0(j);
      end if;
      if upper(p4(j)) not in ('GST','NO_GST') and parm = 'COST_CENTRE'
       then
        update strang.lov
         set
          colb = 'GST'
        where
         lov_name = parm and
         code = p0(j);
      end if;
    end if;

    uctr := uctr + 1;
  elsif p0(j) is null and p1(j) is null
   then
    -- Do Nothing
    null;
  else
    -- Update Values
    if parm = 'INVENT' and p3(j) is not null
     then
      open c3(p3(j));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        lov(surl,null,parm,lrange,src,LNGS.STR_TXT_346 || ':' || p3(j),src1=>src1);
        return;
      end if;
      close c3;
    end if;
    if parm = 'TARIFF' and (p2(j) is null or p4(j) is null or p5(j) is null)
     then
      commit;
      lov(surl,null,parm,lrange,src,LNGS.STR_TXT_345,src1=>src1);
      return;
    end if;
    if parm = 'CONTROLS'
     then
      update strang.lov
       set
        description = p2(j),
        cola = p3(j),
        colb = p4(j),
        colc = p5(j)
      where
       lov_name = parm and
       code = p0(j) and
       nvl(cola,'!') = nvl(p3(j),'!');
      elsif parm = 'TARIFF'
       then
        update strang.lov
         set
         description = p2(j),
         cola = p3(j),
         colb = p4(j),
         colc = p5(j),
         cold = p5d(j),
         cole = p5e(j),
         colf = p5f(j),
         colg = p5g(j),
         colh = p5h(j),
         coli = p5i(j),
         colj = p5j(j)
       where
        lov_name = parm and
        code = p0(j);
      elsif parm = 'UNRATTAB'
       then
        -- Validate 'From' date
        v_from := websys.glbx.guess_date(p3(j));
        if v_from is null
         then
          lov(surl,null,parm,lrange,src,'[' || p1(j) || ' - ' || p2(j) || '] Invalid FROM date: ' || p3(j),src1=>src1);
          return;
        end if;
        -- Validate 'To' date
        v_to := websys.glbx.guess_date(nvl(p4(j), to_char(sysdate,'DD-MON-YYYY')));
        if v_to is null
         then
          lov(surl,null,parm,lrange,src,'[' || p1(j) || ' - ' || p2(j) || '] Invalid TO date: ' || p4(j),src1=>src1);
          return;
        end if;
        if to_date(v_from) > to_date(v_to)
         then
          lov(surl,null,parm,lrange,src,'[' || p1(j) || ' - ' || p2(j) || '] FROM date is after TO date: ' || v_from || ' - ' || v_to,src1=>src1);
          return;
        end if;

        -- Check for overlapping dates for same code
        open c4('UNRATTAB',p1(j), p3(j), p4(j), p5i(j));
        fetch c4 into c4rec;
        if c4%FOUND
         then
          close c4;
          lov(surl,null,parm,lrange,src,'[' || p1(j) || ' - ' || p2(j) || '] Dates conflict with [' || c4rec.code || ']: ' || c4rec.cola || ' - ' || c4rec.colb,src1=>src1);
          return;
        end if;
        close c4;

        update strang.lov
         set
         code = upper(p1(j))
       , description = p2(j)
       , cola = upper(p3(j))
       , colb = upper(p4(j))
       where
        rowid = p5i(j)
        ;
      else
      update strang.lov
       set
        description = p2(j),
        cola = upper(p3(j)),
        colb = upper(p4(j)),
        colc = p5(j)
      where
       lov_name = parm and
       code = p0(j);
    end if;
    uctr := uctr + 1;
   end if;
  end loop;

  commit;

  if nctr > 0
   then
    msg := nctr || ' ' || ' ' || LNGS.STR_TXT_021;
  elsif uctr > 0
   then
    msg := uctr || ' ' || ' ' || LNGS.STR_TXT_022;
  end if;

  if action = LNGS.STR_TXT_016
   then
    oltp.display_screen(surl=>surl,sname=>'Administration',rnd=>to_char(sysdate,'SSSSS'),access_in=>NULL,rid=>NULL);
   elsif action = LNGS.STR_TXT_357
    then
     lov(surl,null,parm,lrange,src,msg,'INSERT',src1=>src1);
   else
     lov(surl,null,parm,lrange,src,msg,src1=>src1);
  end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_LOV',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_lov;

procedure after_lov(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as
 cursor c1(rid rowid) is select * from strang.lov where rowid = rid;
 c1rec	c1%ROWTYPE;
begin
 open c1(rid);
 fetch c1 into c1rec;
 close c1;
 lov(surl,call_name,parm,null,c1rec.code);
exception when others then
 glbx.error_details( 'STRANGP', 'AFTER_LOV',null,null,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end after_lov;
-- END OF CODES
procedure receive(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, vrecctr in varchar2 default null )
as

 cursor c2(rid rowid) is select rowid from strang.receivals where deliveryno = (select deliveryno from strang.detailrs where rowid=rid);
 cursor c3(rid rowid) is select rowid from strang.receivals where deliveryno = (select deliveryno from strang.pos where rowid=rid);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.RECEIVE' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 if parm = 'RECEIVALS'
  then
   nrid := replace(rid,'~','+');
 elsif parm = 'DETAILRS'
  then
   open c2(rid);
   fetch c2 into c2rec;
   close c2;
   nrid := rowidtochar( c2rec.rowid );
 elsif parm = 'POS'
  then
   open c3(replace(rid,'~','+'));
   fetch c3 into c3rec;
   close c3;
   nrid := rowidtochar( c3rec.rowid );
 end if;

  htp.htmlopen;
  htp.title( glbx.extract_master_parameter('BAR_TITLE'));
   htp.htmlopen;
    htp.framesetopen('47%,29%,24%','100%',cattributes=>'scrolling="AUTO" resize frameborder="1" framespacing="0" border="1"');
     htp.frame( 'strangp.receive_top?surl=' || glbx.rndsurl(surl) || '&rid=' || replace(nrid,'+','~') || '&scid=' || scid || '&call_name=' || call_name || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id || '&msg=' || replace(msg,' ','+'),'STRANG_TOP');
     htp.frame( 'strangp.receive_bottom?surl=' || glbx.rndsurl(surl) || '&rid=' || replace(nrid,'+','~') || '&scid=' || scid || '&call_name=' || call_name || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id || '&recctr=' || nvl(vrecctr,'1'),'STRANG_BOTTOM');
     htp.frame( 'strangp.receive_po?surl=' || glbx.rndsurl(surl) || '&rid=' || replace(nrid,'+','~') || '&scid=' || scid || '&call_name=' || call_name || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id,'STRANG_BOTTOM');
   htp.framesetclose;
  htp.noframesopen;
  htp.p(lng.GLB_TXT_029);
  htp.noframesclose;
  htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'RECEIVE',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end receive;

procedure receive_top(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.receivals where rowid = rid;
 cursor c3( sname varchar2 ) is select screen_id from oltp_overview where screen_name = sname;
 cursor c4( scid integer ) is select * from oltp_object where screen_id = scid and original_column = 'CUSTOMER_TYPE';
 cursor c5( sto varchar2 ) is select max(deliveryno) + 1 dlr from strang.receivals;
 cursor c5x( sto varchar2, dlr varchar2 ) is select max(deliveryno) + 1 dlr from strang.receivals where substr(to_char(deliveryno),1,1) = dlr;
 cursor c6( dlrv number ) is select 'x' from dual where exists (select 'x' from strang.detailrs where movement_no is not null and deliveryno = dlrv );
 cursor c7(vste varchar2) is select customer_id from strang.lov l, strang.customers c where lov_name = 'CONTROLS' and code = 'DEFAULT RECEIVAL CUSTOMER' and description = customer and customer_type = 'CUSTOMER' and cola = vste;
 cursor c8(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'DEFAULT GST CODE' and cola = vste;
 cursor c9 is select code,description,cola from strang.lov where lov_name = 'COUNTRIES' order by cola;
 cursor c10(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'SEE_ALL_DELIVERIES' and cola = vste;
 cursor c11(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'DELIVERYNO' and cola = vste;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c3arec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c10rec 	c10%ROWTYPE;
 c11rec 	c11%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 ttl		varchar2(200);
 seclevel	varchar2(100);
 vste		varchar2(10);
 v_link 	varchar2(1000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.RECEIVE_TOP' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'RECEIVAL', rid );

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 vste := customer_state(c1rec.aid);
 ttl := LNGS.STR_TXT_023;
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, NULL,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if msg is not null
  then
   ttl := msg;
 end if;
 htp.p( '<CENTER>' );
 if access_id <> 'z'
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
  else
   c2rec.curr := 'AUD';
 end if;

 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_receive_top', ctarget=>'_top' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', 'RECEIVALS' );
   htp.formhidden( 'ACCESS_ID', access_id );
   if access_id = 'z'
    then
     htp.formhidden( 'RID', null );
     open c10(vste);
     fetch c10 into c10rec;
     close c10;
     if c10rec.description = 'YES'
      then
       open c11(vste);
       fetch c11 into c11rec;
       close c11;
       open c5x(currsite,substr(c11rec.description,1,1));
       fetch c5x into c5rec;
       close c5x;
       if c5rec.dlr is null then c5rec.dlr := c11rec.description; end if;
      else
       open c11(vste);
       fetch c11 into c11rec;
       close c11;
       open c5x(currsite,substr(c11rec.description,1,1));
       fetch c5x into c5rec;
       close c5x;
       if c5rec.dlr is null then c5rec.dlr := c11rec.description; end if;
    end if;
     open c7(vste);
     fetch c7 into c2rec.cust_customer_id;
     close c7;
     open c8(vste);
     fetch c8 into c2rec.gstc_gstcode;
     close c8;
    else
     htp.formhidden( 'RID', replace(rid,'~','+') );
   end if;
 end if;

 open c3('Customers');
 fetch c3 into c3rec;
 close c3;
 open c3('Receival');
 fetch c3 into c3arec;
 close c3;
 open c4(c3rec.screen_id);
 fetch c4 into c4rec;
 close c4;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_024),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if access_id = 'z'
    then
     htp.tabledata( htf.bold(c5rec.dlr),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' then htp.formhidden( 'P1', c5rec.dlr ); end if;
    else
     htp.tabledata( htf.bold(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' then htp.formhidden( 'P1', null ); end if;
   end if;
   htp.tabledata( htf.bold(LNGS.STR_TXT_025),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       htp.formhidden( 'P6', c2rec.cust_customer_id );
       customer_list( 'CUSTOMER', 'P6', c2rec.cust_customer_id, TRUE, isedit=>FALSE );
       htp.p(htf.bold('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||'Strang Customer ID'||c2rec.cust_customer_id||'&nbsp;&nbsp;&nbsp;'));
       htp.p( '</TD>' );
      else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       customer_list( 'CUSTOMER', 'P6', c2rec.cust_customer_id, TRUE );
       htp.p(htf.bold('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||'Strang Customer ID  '||c2rec.cust_customer_id||'&nbsp;&nbsp;&nbsp;'));
       htp.p( '</TD>' );
     end if;
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     customer_list( 'CUSTOMER', 'P6', c2rec.cust_customer_id, TRUE, isedit=>FALSE );
     htp.p(htf.bold('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||'Strang Customer ID'||c2rec.cust_customer_id||'&nbsp;&nbsp;&nbsp;'));
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_026) || htf.nl || htf.italic( LNGS.STR_DATE_02 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.tabledata( htf.formhidden( 'P3', to_char(nvl(c2rec.currdate,sysdate),LNGS.STR_DATE_02)) || to_char(nvl(c2rec.currdate,sysdate),LNGS.STR_DATE_02),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.formtext('P3',15,20,to_char(nvl(c2rec.currdate,sysdate),LNGS.STR_DATE_02)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
    else
     htp.tabledata( to_char(nvl(c2rec.currdate,sysdate),LNGS.STR_DATE_02),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   htp.tabledata( htf.bold(LNGS.STR_TXT_027),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       htp.formhidden( 'P8', c2rec.supplier_customer_id );
       customer_list( 'SUPPLIER', 'P8', c2rec.supplier_customer_id, FALSE, isedit=>FALSE );
       htp.p(htf.bold('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||'Vendor ID  '|| strang.f_get_vendor_id(c2rec.supplier_customer_id)||'&nbsp;&nbsp;&nbsp;'));
       htp.p( '</TD>' );
      else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       customer_list( 'SUPPLIER', 'P8', c2rec.supplier_customer_id, FALSE );
       htp.p(htf.bold('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||'Vendor ID  '|| strang.f_get_vendor_id(c2rec.supplier_customer_id)||'&nbsp;&nbsp;&nbsp;'));
       htp.p( '</TD>' );
     end if;
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     customer_list( 'SUPPLIER', 'P8', c2rec.supplier_customer_id, FALSE, isedit=>FALSE );
     htp.p(htf.bold('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||'Vendor ID  '|| strang.f_get_vendor_id(c2rec.supplier_customer_id)||'&nbsp;&nbsp;&nbsp;'));
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_028),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     htp.formselectopen( 'P5' );
     for c9rec in c9 loop
      if c9rec.cola = c2rec.curr
       then
        htp.formselectoption( c9rec.cola, 'SELECTED' );
       else
        htp.formselectoption( c9rec.cola );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
    else
     htp.tabledata( c2rec.curr,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   if c2rec.curr = 'AUD' and c2rec.exrate is null then c2rec.exrate := 1; end if;
   htp.tabledata( htf.bold(LNGS.STR_TXT_029),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P7',15,20,to_char(c2rec.exrate,LNGS.STR_FRMT_05)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( to_char(c2rec.exrate,LNGS.STR_FRMT_05),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
  htp.tabledata( htf.bold('Value ('||c2rec.curr||')'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');              -- this line
  htp.tabledata( strang.f_display_po_total(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');  -- this line
  htp.tabledata( htf.bold(LNGS.STR_TXT_030),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       htp.formhidden( 'P4', c2rec.gstc_gstcode );
       lov_list( 'GSTCODES', 'P4', c2rec.gstc_gstcode, TRUE, TRUE, TRUE, isedit=>FALSE );
       htp.p( '</TD>' );
      else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       lov_list( 'GSTCODES', 'P4', c2rec.gstc_gstcode, TRUE, TRUE, TRUE );
       htp.p( '</TD>' );
     end if;
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'GSTCODES', 'P4', c2rec.gstc_gstcode, TRUE, TRUE, TRUE, isedit=>FALSE );
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT'
  then
   if access_id = 'z'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       null;
      else
       htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_031 ),cattributes=>'VALIGN="TOP"');
     end if;
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_318 ),cattributes=>'VALIGN="TOP"');
     htp.formclose;
    else
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_032 ),cattributes=>'VALIGN="TOP"');
     open c6( c2rec.deliveryno );
     fetch c6 into c6rec;
     if c6%NOTFOUND
      then
       if seclevel in ( 'LEVEL 8' )
        then
         null;
        else
         htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_033 ),cattributes=>'VALIGN="TOP"');
       end if;
     end if;
     htp.formclose;
     if seclevel in ( 'LEVEL 8' )
      then
       null;
      else
      htp.tabledata( htf.formopen( 'oltp.process_query', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RND', to_char(sysdate,'SSSSS') ) || htf.formhidden( 'ACCESS_IN', 'EDIT' ) || htf.formhidden( 'RID', null ) ||
                  htf.formhidden( 'SCID', c3arec.screen_id ) || htf.formhidden( 'PARM1', 'CUSTOMER' ) || htf.formhidden( 'PARM2', c4rec.oltp_id ) || htf.formhidden( 'PARM3', null ) || htf.formhidden( 'PARM4', '=' ) ||
                  htf.formhidden( 'SORT', null ) ||
                  htf.formsubmit( null, LNGS.STR_TXT_034 ) ||
                  htf.formclose, cattributes=>'VALIGN="TOP"');
      htp.tabledata( htf.formopen( 'strangp.mng_cust', ctarget=>'CUSTOMER_WINDOW' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RID', null ) || htf.formsubmit( null, LNGS.STR_TXT_035 ) || htf.formclose,cattributes=>'VALIGN="TOP"');
     end if;
--OST185-     if seclevel in ( 'LEVEL 7' )
--OST185-      then
--OST185-      -- htp.tabledata( htf.formopen( 'strangp.mng_cust', ctarget=>'CUSTOMER_WINDOW' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RID', null ) || htf.formsubmit( null, LNGS.STR_TXT_035 ) || htf.formclose,cattributes=>'VALIGN="TOP"');
--OST185-      htp.p(pop_up_window( 'height=800,width=500,scrollbars=yes,resizable=yes'));
--OST185-      v_link := '''strangp.ost_185_screen?surl=' || surl || '&action=NEW''';
--OST185-      htp.tabledata('<form><input type="button" onClick="popUpWindow(' || v_link || ')" value="' || LNGS.STR_TXT_461 || '"></form>');
--OST185-      htp.p(pop_up_window( 'height=600,width=500,scrollbars=yes,resizable=yes'));
--OST185-      v_link := '''strangp.ost_185_batch?surl=' || surl || '''';
--OST185-      htp.tabledata('<form><input type="button" onClick="popUpWindow(' || v_link || ')" value="' || LNGS.STR_TXT_462 || '"></form>');
--OST185-     end if;
     --htp.anchor2( 'oltp.process_query?id=z&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT&surl=' || surl || '&rid=&scid=' || c3arec.screen_id || '&parm1=CUSTOMER&parm2=' || c4rec.oltp_id || '&parm3=&parm4==&sort=',LNGS.STR_TXT_034, ctarget=>'_top');
     --htp.anchor2( 'oltp.process_query?id=z&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT&surl=' || surl || '&rid=&scid=' || c3rec.screen_id || '&parm1=CUSTOMER&parm2=' || c4rec.oltp_id || '&parm3=&parm4==&sort=',LNGS.STR_TXT_035,ctarget=>'CUSTOMER_WINDOW');
     -- htp.anchor2( 'oltp.process_query?id=z&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT&surl=' || surl || '&rid=&scid=' || c3rec.screen_id || '&parm1=SUPPLIER&parm2=' || c4rec.oltp_id || '&parm3=&parm4==&sort=',LNGS.STR_TXT_036,ctarget=>'CUSTOMER_WINDOW');
   end if;
  else
     htp.tabledata( htf.formopen( 'strangp.mng_cust', ctarget=>'CUSTOMER_WINDOW' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RID', null ) || htf.formsubmit( null, LNGS.STR_TXT_035 ) || htf.formclose,cattributes=>'VALIGN="TOP"');
  -- htp.anchor2( 'oltp.process_query?id=z&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT&surl=' || surl || '&rid=&scid=' || c3rec.screen_id || '&parm1=CUSTOMER&parm2=' || c4rec.oltp_id || '&parm3=&parm4==&sort=',LNGS.STR_TXT_035,ctarget=>'CUSTOMER_WINDOW');
  -- htp.anchor2( 'oltp.process_query?id=z&rnd=' || to_char(sysdate,'SSSSS') || '&access_in=EDIT&surl=' || surl || '&rid=&scid=' || c3rec.screen_id || '&parm1=SUPPLIER&parm2=' || c4rec.oltp_id || '&parm3=&parm4==&sort=',LNGS.STR_TXT_036,ctarget=>'CUSTOMER_WINDOW');
 end if;
 search( surl, 'RECEIVALS', rid, samerow=>TRUE );
 htp.tablerowclose;
 htp.tableclose;
 htp.bold( ttl );
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'RECEIVE_TOP',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end receive_top;

procedure accept_receive_top( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2, p1 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2, action in varchar2 )
as

 cursor c1( dlrv number ) is select 'x' from strang.receivals where deliveryno = dlrv;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 dt		date;
 newrid		rowid;
 xrate		number(6,4);
 tmp		char(1);
 nlog		varchar2(9);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ACCEPT_RECEIVE_TOP' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action in (LNGS.STR_TXT_032, LNGS.STR_TXT_031)
   then
    begin dt := to_date(p3,LNGS.STR_DATE_02); exception when others then receive( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_037 || ':' || LNGS.STR_DATE_02 ); return; end;
    begin xrate := to_number(p7); exception when others then receive( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_038 || ':' || P7 ); return; end;
    if rid is null
     then
     insert into strang.receivals(deliveryno,currdate,curr,exrate,gstc_gstcode,cust_customer_id,supplier_customer_id) values
       (p1,dt,p5,decode(p5,'AUD',1,xrate),p4,to_number(p6),to_number(p8)) returning rowid into newrid;
      -- Insert two dummy records
      nlog := null;
      insert  into strang.detailrs(deliveryno,itemno,sa,cl,pktpe_packtype,owner,partvolume,partweight,qty,logno) values
       (p1,1,'S','C','UNIT','1',0,0,1,nlog);
      insert into strang.pos(deliveryno,recno,po,ctry_countrycode,gstc_gstcode,unit_unitused,qty) values
       (p1,1,0,'AU',p4,'NO',1);
    else
     update strang.receivals
      set
       currdate = dt,
       curr = p5,
       exrate = to_number(p7),
       gstc_gstcode = p4,
       cust_customer_id = to_number(p6),
       supplier_customer_id = to_number(p8)
     where rowid = chartorowid(replace(rid,'~','+'));
     newrid := chartorowid(replace(rid,'~','+'));
   end if;
 elsif action = LNGS.STR_TXT_318
  then
   -- receive( surl, rid, scid, null, parm, 'x', LNGS.STR_TXT_320 );
   menu( surl, to_char(sysdate,'SSSS'), 'RECEIVALS');
   return;
 elsif action = LNGS.STR_TXT_033
  then
   htp.htmlopen;
   glbx.header_msg( LNGS.STR_TXT_361 );
   htp.nl;
   htp.p( '<CENTER>' );
   htp.tableopen;
   htp.tablerowopen;
   htp.p( '<TD>' );
   htp.formopen( 'strangp.accept_receive_top', ctarget=>'_top' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'ACTION', 'DELX' );
   htp.formhidden( 'P1', p1 );
   htp.formhidden( 'P3', p3 );
   htp.formhidden( 'P4', p4 );
   htp.formhidden( 'P5', p5 );
   htp.formhidden( 'P6', p6 );
   htp.formhidden( 'P7', p7 );
   htp.formhidden( 'P8', p8 );
   htp.formsubmit( null, LNG.PHG_TXT_045 );
   htp.formclose;
   htp.p( '</TD>' );
   htp.p( '<TD>' );
   htp.formopen( 'strangp.receive', ctarget=>'_top' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'CALL_NAME', null );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', 'x' );
   htp.formhidden( 'MSG', LNGS.STR_TXT_362 );
   htp.formsubmit( null, LNG.PHG_TXT_046 );
   htp.formclose;
   htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tableclose;
   htp.p( '</CENTER>' );
   htp.htmlclose;
   return;
 elsif action = 'DELX'
  then
   delete from strang.pos where deliveryno = (select deliveryno from strang.receivals where rowid = chartorowid(replace(rid,'~','+')) );
   delete from strang.detailrs where deliveryno = (select deliveryno from strang.receivals where rowid = chartorowid(replace(rid,'~','+')) );
   delete from strang.receivals where rowid = chartorowid(replace(rid,'~','+'));
   menu( surl, to_char(sysdate,'SSSS'), 'RECEIVALS');
   return;
 end if;

 commit;
 if rid is null
  then
   receive( surl, rowidtochar(newrid), scid, null, parm, 'x', LNGS.STR_TXT_039 );
  elsif action = LNGS.STR_TXT_033 -- Delete
   then
   receive( surl, null, scid, null, parm, 'z', LNGS.STR_TXT_040 );
  else
   receive( surl, rid, scid, null, parm, 'x', LNGS.STR_TXT_041 );
 end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_RECEIVE_TOP',null,owner_id,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end accept_receive_top;

procedure ost_185_screen(surl in varchar2, action in varchar2 default 'NEW', msg in varchar default null)
as

 cursor c1 is
select count(*)
from
(select distinct p.deliveryno, p.recno
from strang.pos p, strang.detailrs dr, strang.receivals r
where p.off_site_receipt is null and
  p.po_item_no is not null and
  p.deliveryno = r.deliveryno and
  p.deliveryno = dr.deliveryno and
  dr.deliveryno = p.deliveryno and
  r.cust_customer_id = 1   and
  dr.detaildesc not like '%PERSONAL EFFECT%' and
  substr(dr.logno,5,2) in ('BS','BA','CA'));

 cursor c3 ( acid integer, time_out integer ) is
  select count(*) tot
  from   login_session
  where  nvl(is_connected, 'F') = 'T'
         and aid <> acid
         and (nvl(date_updated, date_created) + time_out/1440) > sysdate
         and login_type not in ('ADMIN', 'PHOTOGRAPHER')
  ;

 cursor c4 ( acid integer, time_out integer ) is
  select *
  from   login_session
  where  nvl(is_connected, 'F') = 'T'
         and aid <> acid
         and (nvl(date_updated, date_created) + time_out/1440) > sysdate
         and login_type not in ('ADMIN', 'PHOTOGRAPHER')
  order  by date_created
  ;

 c1rec    c1%ROWTYPE;

 cusrec    customer_account%ROWTYPE;
 stype     integer;
 ltype     varchar2(100);
 owner_id  integer;
 sts       varchar2(100);
 pfx       THEME%ROWTYPE;
 rec_ctr   integer;
 timeout   integer;
 login_cnt integer;
 profid    integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.OST_185_SCREEN' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( cusrec.theme_name );

 begin timeout := to_number(glbx.extract_master_parameter('DISCONNECT_AFTER')); exception when others then timeout := 180; end;

 glbx.main_title( surl, 'OST 185 Report',glbx.backimg(surl, cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);

 open c3(owner_id, timeout);
 fetch c3 into login_cnt;
 close c3;

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

   open c1;
   fetch c1 into rec_ctr;
   close c1;
   if rec_ctr > 0 and action not in ('CONFIRM','CANCEL','MESSAGE')
    then
      htp.p('Report has aready been run today (' || rec_ctr || ' records processed).<BR><BR>Do you wish to re-run it? ');
      htp.anchor2('strangp.ost_185_screen?surl=' || surl || '&action=CONFIRM','[Yes]');
      htp.anchor2('strangp.ost_185_screen?surl=' || surl || '&action=CANCEL&msg=Action Cancelled','[No]');
   elsif action in ('CANCEL', 'MESSAGE')
    then
     null;
   elsif nvl(login_cnt, 0) > 0
    then
     glbx.header_msg( 'Cannot run report. The following users are logged on:');
     htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
     htp.tablerowopen;
     htp.tableheader('Username', cattributes=>glbx.QUERY_BACKGROUND);
     htp.tableheader('Account name', cattributes=>glbx.QUERY_BACKGROUND);
     htp.tableheader('Date connected', cattributes=>glbx.QUERY_BACKGROUND);
     htp.tableheader('Date updated', cattributes=>glbx.QUERY_BACKGROUND);
     htp.tablerowclose;
     for c4rec in c4(owner_id, timeout) loop
      htp.tablerowopen;
      ltype := c4rec.login_type;
      cusrec := glbx.get_cusrec(c4rec.sessid, ltype, c4rec.aid, profid);
      htp.tabledata(cusrec.username, cattributes=>glbx.QUERY_CELL_BACKGROUND);
      htp.tabledata(cusrec.account_name, cattributes=>glbx.QUERY_CELL_BACKGROUND);
      htp.tabledata(to_char(c4rec.date_created, 'dd-MON-yyyy hh24:mi:ss'), cattributes=>glbx.QUERY_CELL_BACKGROUND);
      htp.tabledata(to_char(c4rec.date_updated, 'dd-MON-yyyy hh24:mi:ss'), cattributes=>glbx.QUERY_CELL_BACKGROUND);
      htp.tablerowclose;
     end loop;
     htp.tableclose;
   else
     update strang.pos set off_site_receipt = null where off_site_receipt >= trunc(sysdate);
     generate_ost185( surl, sysdate );
     return;
   end if;
   htp.nl;
   htp.nl;
   htp.p('<a href="" onClick="self.close()">[Close Window]</a>');
  htp.bodyclose;

 htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'OST_185_SCREEN',null,owner_id,errmsg=>sqlerrm);
end ost_185_screen;

procedure ost_185_batch(surl in varchar2, msg in varchar default null)
as

cursor c1 is
 select *
 from   user_scheduler_jobs
 where  job_name = 'OST_185_BATCH'
 ;

cursor c2 (j_name varchar2) is
 select * from user_scheduler_job_run_details
 where  job_name = j_name
 order  by log_date desc
 ;

 cusrec    customer_account%ROWTYPE;
 stype     integer;
 ltype     varchar2(100);
 owner_id  integer;
 sts       varchar2(100);
 pfx       THEME%ROWTYPE;
 c1rec     c1%ROWTYPE;
 c2rec     c2%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.OST_185_BATCH' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( cusrec.theme_name );

 glbx.main_title( surl, 'OST 185 Batch Job Definition',glbx.backimg(surl, cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR02',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

 open c1;
 fetch c1 into c1rec;
 close c1;

 open c2 (nvl(c1rec.job_name, 'OST_185_BATCH'));
 fetch c2 into c2rec;
 close c2;

 htp.formopen('strangp.accept_ost_185_batch');
 htp.formhidden('surl', surl);
 htp.formhidden('job_name', nvl(c1rec.job_name, 'OST_185_BATCH'));

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata('Start Date<BR><I>DD-MON-YYYY</I>', cattributes=>glbx.QUERY_BACKGROUND);
  htp.tabledata(htf.formtext('P1', 20, 15, to_char(nvl(c1rec.start_date, sysdate), LNGS.STR_DATE_02)), cattributes=>glbx.QUERY_CELL_BACKGROUND);
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata('Run Time<BR><I>HH24:MM</I>', cattributes=>glbx.QUERY_BACKGROUND);
  htp.tabledata(htf.formtext('P2', 20, 15, to_char(nvl(c1rec.start_date, sysdate), 'hh24:mi')), cattributes=>glbx.QUERY_CELL_BACKGROUND);
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata('Last Run Time: ', cattributes=>glbx.QUERY_BACKGROUND);
  htp.tabledata(nvl(to_char(c2rec.log_date, LNGS.STR_DATE_01), 'Job not run'), cattributes=>glbx.QUERY_CELL_BACKGROUND);
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata('Result: ', cattributes=>glbx.QUERY_BACKGROUND);
  htp.tabledata(nvl(c2rec.additional_info, c2rec.status), cattributes=>glbx.QUERY_CELL_BACKGROUND);
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata('Next Run Time: ', cattributes=>glbx.QUERY_BACKGROUND);
  htp.tabledata(nvl(to_char(c1rec.next_run_date, LNGS.STR_DATE_01), 'Job not enabled'), cattributes=>glbx.QUERY_CELL_BACKGROUND);
 htp.tablerowclose;
 htp.tableclose;

 htp.formsubmit( 'ACTION', 'Update');
 htp.formsubmit( 'ACTION', 'Cancel');

 htp.formclose;

 htp.nl;
 htp.nl;
 htp.p('<a href="" onClick="self.close()">[Close Window]</a>');
 htp.bodyclose;

 htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'OST_185_BATCH',null,owner_id,errmsg=>sqlerrm);
end ost_185_batch;

procedure accept_ost_185_batch( surl in varchar2, job_name in varchar2, p1 in varchar2, p2 in varchar2, action in varchar2 default 'CANCEL')
as

 cusrec    customer_account%ROWTYPE;
 stype     integer;
 ltype     varchar2(100);
 owner_id  integer;
 sts       varchar2(100);
 pfx       THEME%ROWTYPE;
 start_dte date;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.OST_185_BATCH' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 if upper(action) in ('CANCEL')
  then
   ost_185_batch(surl, 'Update Cancelled');
   return;
 elsif upper(action) in ('UPDATE')
  then
   begin
    start_dte := to_date(trim(p1) || ' ' || trim(p2), LNGS.STR_DATE_01);
   exception when others then
    ost_185_batch(surl, 'Date must be format "' || LNGS.STR_DATE_02 || '".<BR>Time must be format "hh24:mm"');
    return;
   end;
   if start_dte < sysdate
    then
     ost_185_batch(surl, 'Date cannot be in the past: ' || to_char(start_dte, LNGS.STR_DATE_01));
     return;
   end if;
   begin dbms_scheduler.drop_job(job_name); exception when others then null; end;
   dbms_scheduler.create_job( job_name=> job_name
                            , job_type=> 'STORED_PROCEDURE'
                            , job_action=> 'strangp.generate_ost185'
                            , start_date=> start_dte
                            , repeat_interval=> 'FREQ=DAILY;INTERVAL=1'
                            , number_of_arguments=> 3
                            , enabled=> FALSE
                            , comments=> 'Generate OST185'
                           )
   ;
   dbms_scheduler.set_job_argument_value( job_name => job_name
                                        , argument_position => 1
                                        , argument_value => surl
                                        )
   ;

   dbms_scheduler.set_job_argument_value( job_name => job_name
                                        , argument_position => 2
                                        , argument_value => sysdate
                                        )
   ;

   dbms_scheduler.set_job_argument_value( job_name => job_name
                                        , argument_position => 3
                                        , argument_value => 'TRUE'
                                        )
   ;

   dbms_scheduler.enable(job_name);
   ost_185_batch(surl, 'Batch job created: ' || to_char(start_dte, LNGS.STR_DATE_01));
   return;
 end if;

ost_185_batch(surl, 'Invlid action: ' || action);
return;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_OST_185_BATCH',null,owner_id,errmsg=>sqlerrm);
end accept_ost_185_batch;

procedure receive_bottom(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL )
as

 cursor c2( rid rowid ) is select * from strang.receivals where rowid = rid;

 cursor c3( dlrvy number ) is
  select rowid,itemno,logno,hawb_hawbno,camov_seal,detaildesc,hazard,ecn,sa,cl,warehouse,pktpe_packtype,owner,partvolume,partweight,qty,movement_no,deliveryno,entry_no,line_no,handling_unit
  from strang.detailrs
  where deliveryno = dlrvy
  order by itemno,logno;

 cursor c4( dlrvy number ) is select count('x') tot from strang.detailrs where deliveryno = dlrvy;

 cursor c5(hwb varchar2) is select mawb from strang.hawbs where hawb = hwb;
 cursor c6(dlry number, sto varchar2) is select max(itemno) tot from strang.detailrs where deliveryno = dlry; --  and site_owner = sto
 cursor c7(dlry number) is select max(itemno) + 1 tot from strang.detailrs where deliveryno = dlry;
 cursor c9 is select code,description,cola from strang.lov where lov_name = 'WAREHOUSES' order by code;
 cursor c10(v_entry number) is select * from strang.duty where entry_no = v_entry;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec         c10%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 vrecctr	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 ttl		varchar2(200);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.RECEIVE_BOTTOM' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'DETAILRS', rid );

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 seclevel := oltp.security_role( owner_id );
 open c2( replace(rid,'~','+') );
 fetch c2 into c2rec;
 close c2;

 if access_id = 'z'
  then
   ttl := LNGS.STR_TXT_042;
   glbx.main_title( surl, NULL, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR03',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
   return;
  else
   if recctr > 0
    then
     open c4( c2rec.deliveryno );
     fetch c4 into c4rec;
     close c4;
     vrecctr := recctr;
     if recctr > c4rec.tot then vrecctr := c4rec.tot; end if;
     ttl := nvl(msg,LNGS.STR_TXT_043 || ' (' || vrecctr || '/' || c4rec.tot || ')');
     glbx.main_title( surl, NULL,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
    else
     vrecctr := 0;
     ttl := nvl(msg,LNGS.STR_TXT_044);
     glbx.main_title( surl, NULL,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR04',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
   end if;
 end if;

 if vaccess = 'READ' and vrecctr = 0
  then
   vrecctr := 1;
 end if;

 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );
 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_receive_detailr' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
   -- Added at Sallies Request, behaviour is now on insert to stay on current screen
   if vrecctr = 0
    then
     open c7(c2rec.deliveryno);
     fetch c7 into c7rec;
     close c7;
     c7rec.tot := nvl(c7rec.tot,1);
     htp.formhidden( 'RECCTR', c7rec.tot);
    else
     htp.formhidden( 'RECCTR', vrecctr);
   end if;
 end if;

 if vrecctr > 0
  then
   open c3( c2rec.deliveryno );
   for j in 1..vrecctr loop
   fetch c3 into c3rec;
    if c3%NOTFOUND then exit; end if;
   end loop;
   close c3;
 else
   c3rec.PKTPE_PACKTYPE := 'UNIT';
   c3rec.qty := 1;
   c3rec.partweight := 0;
   c3rec.partvolume := 0;
 end if;

 if vaccess = 'EDIT' then htp.formhidden( 'DETRID', rowidtochar( c3rec.rowid )); end if;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_045 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c3rec.rowid is null
      then
       open c6( c2rec.deliveryno, currsite );
       fetch c6 into c3rec.itemno;
       close c6;
       c3rec.itemno := nvl(c3rec.itemno,0) + 1;
     end if;
     htp.tabledata( htf.bold( c3rec.itemno ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"' );
     if vaccess = 'EDIT' then htp.formhidden( 'P1', c3rec.itemno ); end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_046 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
         htp.tabledata( htf.formhidden( 'P2', c3rec.logno ) || c3rec.logno, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' );
       else
       if c3rec.rowid is null or c3rec.logno is null
        then
           htp.tabledata( htf.formradio( 'A1','T','CHECKED' ) || ' ' || LNGS.STR_TXT_047 || htf.nl ||
                         htf.formradio( 'A1','N' ) || ' ' || LNGS.STR_TXT_048,cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext( 'P2', 9, 9, c3rec.logno), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       end if;
      end if;
      else
         htp.tabledata( c3rec.logno, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_049 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        if c3rec.sa = 'A'
         then
          htp.tabledata( htf.formhidden( 'P3', c3rec.sa ) || LNGS.STR_TXT_050, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' );
         else
          htp.tabledata( htf.formhidden( 'P3', c3rec.sa ) || LNGS.STR_TXT_051, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' );
        end if;
       else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
        htp.formselectopen( 'P3' );
        if c3rec.sa = 'A'
         then
          htp.formselectoption( LNGS.STR_TXT_050, 'SELECTED', cattributes=>'VALUE="A"' );
          htp.formselectoption( LNGS.STR_TXT_051, cattributes=>'VALUE="S"' );
         else
          htp.formselectoption( LNGS.STR_TXT_050, cattributes=>'VALUE="A"' );
          htp.formselectoption( LNGS.STR_TXT_051, 'SELECTED', cattributes=>'VALUE="S"' );
        end if;
        htp.formselectclose;
       htp.p( '</TD>' );
       end if;
      else
         htp.tabledata( c3rec.sa, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_052 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        if c3rec.cl = 'L'
         then
          htp.tabledata( htf.formhidden( 'P8', c3rec.cl ) || LNGS.STR_TXT_053, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3' );
         else
          htp.tabledata( htf.formhidden( 'P8', c3rec.cl ) || LNGS.STR_TXT_054, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3' );
        end if;
       else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3>' );
        htp.formselectopen( 'P8' );
        if c3rec.cl = 'L'
         then
          htp.formselectoption( LNGS.STR_TXT_053, cattributes=>'VALUE="C"' );
          htp.formselectoption( LNGS.STR_TXT_054, 'SELECTED', cattributes=>'VALUE="L"' );
         else
          htp.formselectoption( LNGS.STR_TXT_053, 'SELECTED', cattributes=>'VALUE="C"' );
          htp.formselectoption( LNGS.STR_TXT_054, cattributes=>'VALUE="L"' );
        end if;
        htp.formselectclose;
       htp.p( '</TD>' );
       end if;
     else
         htp.tabledata( c3rec.cl, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3' );
    end if;
  --   htp.tabledata( htf.bold( 'OTML Handling Unit (HU)' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        htp.tabledata( htf.bold( 'Handling Unit/Case#' )|| '&nbsp;&nbsp;'|| htf.formhidden( 'P6i', c3rec.handling_unit ) || c3rec.handling_unit, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       else
        htp.tabledata( htf.bold( 'Handling Unit/Case#' )||'&nbsp;&nbsp;'|| htf.formtext( 'P6i', 12, 15, c3rec.handling_unit), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       end if;
      else
       htp.tabledata( htf.bold( 'Handling Unit/Case#' )||'&nbsp;&nbsp;'|| c3rec.handling_unit, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_055 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        htp.tabledata( htf.formhidden( 'P6', c3rec.qty ) || c3rec.qty, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       else
        htp.tabledata( htf.formtext( 'P6', 15, 15, c3rec.qty), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       end if;
      else
       htp.tabledata( c3rec.qty, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_056 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        htp.tabledata( htf.formhidden( 'P7', c3rec.pktpe_packtype ) || c3rec.pktpe_packtype, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       else
        htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
         htp.formtext( 'P7', 10, 4, c3rec.pktpe_packtype );
        htp.p( '</TD>' );
       end if;
      else
       htp.tabledata( c3rec.pktpe_packtype, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"' );
     end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_057 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        htp.tabledata( htf.formhidden( 'P5', c3rec.partweight ) || c3rec.partweight, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       else
        htp.tabledata( htf.formtext( 'P5', 10, 20, c3rec.partweight), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
      end if;
      else
       htp.tabledata( c3rec.partweight, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"' );
     end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_058 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        htp.tabledata( htf.formhidden( 'P4', ltrim(to_char(c3rec.partvolume,LNGS.STR_FRMT_07)) ) || ltrim(to_char(c3rec.partvolume,LNGS.STR_FRMT_07)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3' );
       else
        htp.tabledata( htf.formtext( 'P4', 10, 20, ltrim(to_char(c3rec.partvolume,LNGS.STR_FRMT_07))), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3' );
      end if;
      else
       htp.tabledata( ltrim(to_char(c3rec.partvolume,LNGS.STR_FRMT_07)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"' );
     end if;
--     htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
     htp.p( '</TD>' );

  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_059 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=9>' );
       htp.formtext( 'D8', 90, 90, c3rec.detaildesc);
---       if c3rec.logno is not null and seclevel not in ( 'LEVEL 8' ) then htp.anchor2( 'strangp.edit_ecn_log?surl=' || surl || '&lg=' || c3rec.logno || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr), LNGS.STR_TXT_409, ctarget=>'ASSIGN_BY_LOG' ); end if;
---        htp.anchor2( 'strangp.po_item_no_maintain?surl=' || surl || '&strt=' || c3rec.deliveryno || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'PO Maintain', ctarget=>'_top' );
---       if seclevel in ( 'LEVEL 5','LEVEL 7','LEVEL 8' )
---       then
---        htp.anchor2( 'strangp.entry_maintain?surl=' || surl || '&strt=' || c3rec.entry_no || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'Entry Maintain', ctarget=>'_top' );
---        htp.anchor2( 'strangp.container_maintain?surl=' || surl || '&strt=' || c3rec.movement_no || '&strt2=' || c3rec.camov_seal || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'Container Maintain', ctarget=>'_top' );
 --       htp.anchor2( 'strangp.delivery_maintain?surl=' || surl || '&strt=' || c3rec.deliveryno || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'Delivery Maintain', ctarget=>'_top' );
---        end if;
       htp.p( '</TD>' );
      else
       htp.tabledata( c3rec.detaildesc, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=9' );
     end if;
--     htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
     htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_060 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        htp.tabledata( htf.formhidden( 'D6', c3rec.ecn ) || c3rec.ecn, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       else
        htp.tabledata( htf.formtext( 'D6', 20, 15, c3rec.ecn), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
      end if;
      else
       htp.tabledata( c3rec.ecn, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_061 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
      if seclevel in ( 'LEVEL 8' )
       then
        htp.tabledata( htf.formhidden( 'D5', c3rec.hazard ) || c3rec.hazard, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
       else
        htp.tabledata( htf.formtext( 'D5', 30, 120, c3rec.hazard), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
      end if;
      else
       htp.tabledata( c3rec.hazard, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
   htp.tabledata( htf.bold('Warehouse'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     htp.formselectopen( 'P9' );
     for c9rec in c9 loop
      if c9rec.code = c3rec.warehouse
       then
        htp.formselectoption( c9rec.code, 'SELECTED' );
       else
        htp.formselectoption( c9rec.code );
      end if;
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
    else
     htp.tabledata( c3rec.warehouse,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_062 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( nvl(c3rec.movement_no,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     htp.tabledata( htf.bold( LNGS.STR_TXT_063 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( nvl(c3rec.camov_seal,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
--     htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
--     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
--     htp.p( '</TD>' );
     if vaccess = 'EDIT'
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=9>' );
       if c3rec.logno is not null and seclevel not in ( 'LEVEL 8' ) then htp.anchor2( 'strangp.edit_ecn_log?surl=' || surl || '&lg=' || c3rec.logno || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr), 'ECN Assign', ctarget=>'ASSIGN_BY_LOG' ); end if;
       if seclevel in ( 'LEVEL 5','LEVEL 7','LEVEL 8' )
       then
        htp.anchor2( 'strangp.entry_maintain?surl=' || surl || '&strt=' || c3rec.entry_no || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'Entry Maintain', ctarget=>'_top' );
        htp.anchor2( 'strangp.container_maintain?surl=' || surl || '&strt=' || c3rec.movement_no || '&strt2=' || c3rec.camov_seal || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'Container Maintain', ctarget=>'_top' );
        htp.anchor2( 'strangp.log_maintain?surl=' || surl || '&strt=' || c3rec.logno || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'Log Maintain', ctarget=>'_top' );
 --       htp.anchor2( 'strangp.delivery_maintain?surl=' || surl || '&strt=' || c3rec.deliveryno || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'Delivery Maintain', ctarget=>'_top' );
        end if;
       htp.p( '</TD>' );
     end if;
--     htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
--     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
--     htp.p( '</TD>' );

  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_064 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c3rec.entry_no is not null
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       htp.tableopen;
       htp.tablerowopen;
        htp.p( '<TD>' );
         open c10(c3rec.entry_no);
         fetch c10 into c10rec;
         if c10%FOUND
          then
           htp.anchor2( 'strangp.duty_edit?surl=' || surl || '&entry=' || strang.ent.get_entry_no(c3rec.entry_no), strang.ent.get_entry_no(c3rec.entry_no), ctarget=>'_top');
         else
           htp.p( strang.ent.get_entry_no(c3rec.entry_no));
         end if;
         close c10;
        htp.p( '</TD>' );
       htp.tabledata( '&nbsp;&nbsp;&nbsp;&nbsp;' );
        search( surl, 'ENTRY_NO', c3rec.rowid, samerow=>TRUE, buttons_only=>TRUE, override_top=>'_top' );
       htp.tablerowclose;
       htp.tableclose;
       htp.p( '</TD>' );
      else
       htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
     htp.tabledata( htf.bold( LNGS.STR_TXT_065 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold(c3rec.line_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     htp.tabledata( htf.bold( LNGS.STR_TXT_066 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     open c5(c3rec.hawb_hawbno);
     fetch c5 into c5rec;
     close c5;
     if c5rec.mawb is not null
      then
       htp.tabledata( htf.bold( c3rec.hawb_hawbno), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' ); -- || '(' || c5rec.mawb || ')'
      else
       htp.tabledata( htf.bold( c3rec.hawb_hawbno), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
--
--     htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
       htp.anchor2( 'strangp.po_item_no_maintain?surl=' || surl || '&strt=' || c3rec.deliveryno || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'PO Maintain', ctarget=>'_top' );
       htp.p( '</TD>' );
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
       htp.anchor2( 'strangp.po_inventory_maintain?surl=' || surl || '&strt=' || c3rec.deliveryno || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'PO2 Maintain', ctarget=>'_top' );
       htp.p( '</TD>' );
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
       htp.anchor2( 'strangp.po_inventdate_maintain?surl=' || surl || '&strt=' || c3rec.deliveryno || '&rid=' || replace(c3rec.rowid,'+','~') || '&vrecctr=' || vrecctr, 'PO3 Maintain', ctarget=>'_top' );
       htp.p( '</TD>' );
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1');
     else
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN=4');
     end if;

     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER">' );
     htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
     htp.tablerowopen;
     if vaccess = 'EDIT'
      then
       if c3rec.rowid is not null
        then
         htp.tabledata( htf.formimage( LNGS.STR_TXT_067,glbx.IMAGE_LOCATION || 'adminc_save.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
         if seclevel in ( 'LEVEL 8' )
          then
            null;
          else
           htp.tabledata( htf.formimage( LNGS.STR_TXT_068,glbx.IMAGE_LOCATION || 'adminc_insert.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
           htp.tabledata( htf.formimage( LNGS.STR_TXT_069,glbx.IMAGE_LOCATION || 'adminc_split.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
           if c3rec.movement_no is null
            then
             htp.tabledata( htf.formimage( LNGS.STR_TXT_070,glbx.IMAGE_LOCATION || 'adminc_delete.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
           end if;
         end if;
        else
         htp.tabledata( htf.formimage( LNGS.STR_TXT_067,glbx.IMAGE_LOCATION || 'adminc_save.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       end if;
     end if;

     if recctr = 0
      then
       htp.tabledata( htf.formimage( LNGS.STR_TXT_359,glbx.IMAGE_LOCATION || 'adminc_cancel.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
      elsif vrecctr > 1 and vrecctr < c4rec.tot
       then
        if vaccess = 'EDIT'
         then
          htp.tabledata( htf.formimage( LNGS.STR_TXT_071,glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
          htp.tabledata( htf.formimage( LNGS.STR_TXT_072,glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
        elsif vaccess = 'READ'
         then
          htp.tabledata( htf.anchor( 'strangp.receive_bottom?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr-1), htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0',calt=>'Previous Record' ) ));
          htp.tabledata( htf.anchor( 'strangp.receive_bottom?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr+1), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ) ));
        end if;
      elsif vrecctr = c4rec.tot
       then
        if vrecctr > 1
         then
          if vaccess = 'EDIT'
           then
            htp.tabledata( htf.formimage( LNGS.STR_TXT_071,glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=> ' BORDER=0 ALIGN="LEFT"' ));
          elsif vaccess = 'READ'
           then
            htp.tabledata( htf.anchor( 'strangp.receive_bottom?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr-1), htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0',calt=>'Previous Record' ) ));
          end if;
        end if;
      else
       if vaccess = 'EDIT'
        then
         htp.tabledata( htf.formimage( LNGS.STR_TXT_072,glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       elsif vaccess = 'READ'
        then
          htp.tabledata( htf.anchor( 'strangp.receive_bottom?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr+1), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ) ));
       end if;
     end if;

     htp.formclose;

     htp.tabledata( htf.formopen( 'strangp.receive_bottom' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
            htf.formhidden( 'SCID', scid ) || htf.formtext( 'RECCTR', 2, 5, vrecctr ) || htf.formhidden( 'CALL_NAME', call_name ) ||
            htf.formhidden( 'PARM', parm ) || htf.formhidden( 'ACCESS_ID', access_id ) || htf.formsubmit( null, 'GoTo' ) || htf.formclose );

    if seclevel in ( 'LEVEL 5','LEVEL 7','LEVEL 8' )
     then
      htp.tabledata( htf.formopen( 'strangp.menu', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', NULL ) ||
            htf.formhidden( 'RND', to_char(sysdate, 'SSSSS' )) || htf.formhidden( 'ACTION', 'SEARCH' ) || htf.formhidden( 'MTYPE', 'ENTRY_NO' ) ||
            htf.formtext( 'MSEARCH', 20, 100 ) || htf.formsubmit( null, 'Entry' ) || htf.formclose );
    end if;
    htp.tablerowclose;
    htp.tableclose;
    htp.p( '</TD>' );

  htp.tablerowclose;
 htp.tableclose;
 htp.bold( ttl );
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'RECEIVE_BOTTOM',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end receive_bottom;

procedure accept_receive_detailr(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer,
                                detrid in varchar2, p1 in varchar2, p2 in varchar2 default null, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2,p6i in varchar2, p7 in varchar2, p8 in varchar2,
                                p9 in varchar2, a1 in varchar2 default null, d5 in varchar2, d6 in varchar2, d8 in varchar2, cancel in varchar2 default null,
                                save_record in varchar2 default null, previous_record in varchar2 default null, next_record in varchar2 default null, insert_record in varchar2 default null, delete_record in varchar2 default null, split_record in varchar2 default null)
as

 cursor c2( rid rowid ) is select deliveryno from strang.receivals where rowid = rid;
 cursor c3( dlryno number, itn integer, lgn varchar2, rid rowid ) is
  select 'x' tot
  from strang.detailrs
  where itemno = itn and
        deliveryno = dlryno and
        logno = lgn and
        rowid <> rid;
 --cursor c4( dlryno number, sto varchar2 ) is select max(recno) tot from strang.pos where deliveryno = dlryno and site_owner = sto;
 cursor c5( str varchar2, vste varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and cola = vste and code = str and exists
                               (select 'x' from strang.lov where lov_name = 'CONTROLS' and cola = vste and code = str || '_DATE' and description = to_char(sysdate,'DD-MON-YYYY'));
 cursor c6( rid rowid ) is select movement_no, camov_seal from strang.detailrs where rowid = rid;
 cursor c7( pk varchar2 ) is select 'x' from strang.lov where lov_name = 'PACKTYPES' and code = pk;
 cursor c9( whse varchar2 ) is select 'x' from strang.lov where lov_name = 'WAREHOUSES' and code = whse;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 --c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c9rec		c9%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 np3		varchar2(9);
 vlogno		varchar2(9);
 pv		number(8,3);
 pw		number(9,1);
 qt		integer;
 nmb1		number;
 nrowid		rowid;
 itn		number(5,2);
 am		number(9,2);
 tam		number(9,2);
 gs		number(9,2);
 sts		varchar2(100);
 vste		varchar2(10);

begin

 if cancel is not null
  then
   receive_bottom(surl,rid,scid,null,parm,'x',1,LNGS.STR_TXT_359 );
   return;
 end if;

 if delete_record is not null
  then
   confirm_delete_detailrs(surl,rid,scid,detrid,parm,access_id,recctr, 'Confirm Delete of Detail'  );
   return;
 end if;

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_RECEIVE_DETAILR' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);

 open c2( chartorowid( replace(rid,'~','+') ) );
 fetch c2 into c2rec;
 close c2;

 begin itn := to_number( p1 ); exception when others then receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_074 || ': ' || p1 ); return; end;

 open c3( c2rec.deliveryno, itn, p2, detrid );
 fetch c3 into c3rec;
 if c3%FOUND
  then
    close c3;
    receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_075 || ': ' || p1 || '-' || p2 );
    return;
  end if;
  close c3;

  begin pv := to_number( replace(p4,',','') ); exception when others then receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_076 || ': ' || p4 ); return; end;
  begin pw := to_number( replace(p5,',','') ); exception when others then receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_077 || ': ' || p5 ); return; end;
  begin qt := to_number( replace(p6,',','') ); exception when others then receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_078 || ': ' || p6 ); return; end;
  open c7(upper(p7));
  fetch c7 into c7rec;
  if c7%NOTFOUND
   then
    close c7;
    receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_360 || ': ' || p7 );
    return;
  end if;
  close c7;
  open c9(upper(p9));
  fetch c9 into c9rec;
  if c9%NOTFOUND
   then
    close c9;
    receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_360 || ': ' || p9 );
    return;
  end if;
  close c9;
  if detrid is null
   then
    begin
     if a1 = 'T'
      then
       open c5( 'LOGNO' || p3, vste );
       fetch c5 into np3;
       if c5%NOTFOUND
        then
         np3 := nvl(p2,new_log_no( p3, vste ) );
       end if;
       close c5;
      else
       np3 := nvl(p2,new_log_no( p3, vste ) );
     end if;
     insert into strang.detailrs( deliveryno, itemno, logno, sa, partvolume, partweight, qty, pktpe_packtype, cl, owner, entry_no, hazard, ecn, detaildesc, warehouse ) values
      ( c2rec.deliveryno, itn, np3, p3, pv, pw, nvl(qt,1), upper(p7), p8,'1',nmb1, d5, d6, d8, p9 ) returning rowid into nrowid;
    exception
      when others then
            receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_079 || ': ' || sqlerrm );
            return;
    end;
   else
    -- Update The Row
    begin
    if a1 is null
     then
      np3 := p2;
     else
      if a1 = 'T'
       then
        open c5( 'LOGNO' || p3, vste );
        fetch c5 into np3;
        if c5%NOTFOUND
         then
          np3 := nvl(p2,new_log_no( p3, vste ) );
        end if;
        close c5;
       else
        np3 := nvl(p2,new_log_no( p3, vste ) );
      end if;
    end if;
    update strang.detailrs
        set
         logno = np3,
         sa = p3,
         partvolume = pv,
         partweight = pw,
         qty = qt,
         handling_unit = strang.f_sap_format(p6i,'HANDLING_UNIT'),
         pktpe_packtype = upper(p7),
         warehouse = upper(p9),
         cl = p8,
         hazard = d5,
         ecn = d6,
         detaildesc = d8
       where rowid = chartorowid( detrid );
        exception
             when others then
              receive_bottom(surl,rid,scid,null,parm,access_id,'Details',LNGS.STR_TXT_080 || ': ' || sqlerrm );
              return;
       end;
   end if;

 commit;

 if previous_record is not null
  then
   receive_bottom(surl,rid,scid,null,parm,access_id,recctr - 1,null );
   return;
 elsif next_record is not null
  then
   receive_bottom(surl,rid,scid,null,parm,access_id,recctr + 1,null );
   return;
 elsif insert_record is not null
  then
   receive_bottom(surl,rid,scid,null,parm,access_id,0,null );
   return;
 elsif split_record is not null
  then
   split_detailrs(surl,detrid,scid,null,parm,access_id,recctr,null );
   return;
 elsif save_record is not null
  then
   receive_bottom(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_081 );
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_RECEIVE_DETAILR',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_receive_detailr;

procedure split_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL )
as

 cursor c2( rid rowid ) is select * from strang.detailrs where rowid = rid;


 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.SPLIT_DETAILRS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'DETAILRS', rid );

  open c2(chartorowid(replace(rid,'~','+')));
  fetch c2 into c2rec;
  close c2;
  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );

  glbx.main_title( surl, LNGS.STR_TXT_082,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR05',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);

  htp.nl;
  htp.p( '<CENTER>' );
  htp.formopen( 'strangp.accept_split_detailrs' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RECCTR', recctr);
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( htf.bold( LNGS.STR_TXT_083 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold( c2rec.qty ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold( LNGS.STR_TXT_317 ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formradio( 'P1', 'A', 'CHECKED'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold( LNGS.STR_TXT_084 ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'P2', 5, 10 ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.formradio( 'P1', 'M'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold( LNGS.STR_TXT_085 ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'P2', 5, 10 ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  htp.tableclose;
  htp.nl;
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_086 );
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_318 );
  htp.formclose;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'SPLIT_DETAILRS',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end split_detailrs;

procedure accept_split_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY )
as

 cursor c2( rid rowid ) is select * from strang.detailrs where rowid = rid;
 cursor c3( dlr number ) is select rowid from strang.receivals where deliveryno = dlr;
 cursor c4( dlr number ) is
  select max(itemno) mx
  from strang.detailrs
  where deliveryno = dlr;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		integer;
 sts		varchar2(100);
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_SPLIT_DETAILRS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  vaccess := data_access( owner_id, 'DETAILRS', rid );

  open c2(chartorowid(replace(rid,'~','+')));
  fetch c2 into c2rec;
  close c2;
  c2rec.partweight := nvl(c2rec.partweight,0);
  c2rec.partvolume := nvl(c2rec.partvolume,0);
  c2rec.qty := nvl(c2rec.qty,0);

  open c3(c2rec.deliveryno);
  fetch c3 into c3rec;
  close c3;
  if action = LNGS.STR_TXT_318
   then
    receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_320 );
    return;
  end if;

  if p1 = 'A'
   then
    begin nmb := nvl(to_number(p2(1)),0); exception when others then receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_087 ); return; end;
   else
    begin nmb := nvl(to_number(p2(2)),0); exception when others then receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_087 ); return; end;
  end if;
  if nmb > c2rec.qty then receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_088 ); return; end if;
  if nmb = 0 then receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,'Invalid Value Entered. Number must be greater than 0. Operation Cancelled.' ); return; end if;
  open c4(c2rec.deliveryno);
  fetch c4 into c4rec;
  close c4;
  c4rec.mx := nvl(c4rec.mx,1);

  if p1 = 'A'
   then
    for j in 1..nmb loop
     if j = 1
      then
       insert into strang.detailrs
        (itemno,logno,hawb_hawbno,camov_seal,detaildesc,hazard,ecn,sa,cl,
         pktpe_packtype,owner,partvolume,partweight,qty,movement_no,
         deliveryno,entry_no,line_no,warehouse,handling_unit) values
        (c4rec.mx+j,c2rec.logno,c2rec.hawb_hawbno,c2rec.camov_seal,c2rec.detaildesc,c2rec.hazard,c2rec.ecn,c2rec.sa,c2rec.cl,
         c2rec.pktpe_packtype,c2rec.owner,round(c2rec.partvolume/nmb,5),trunc(c2rec.partweight/nmb) + mod(c2rec.partweight,nmb),trunc(c2rec.qty/nmb) + mod(c2rec.qty,nmb),c2rec.movement_no,
         c2rec.deliveryno,c2rec.entry_no,c2rec.line_no,c2rec.warehouse,c2rec.handling_unit);
      else
       insert into strang.detailrs
        (itemno,logno,hawb_hawbno,camov_seal,detaildesc,hazard,ecn,sa,cl,
         pktpe_packtype,owner,partvolume,partweight,qty,movement_no,
         deliveryno,entry_no,line_no,warehouse,handling_unit) values
        (c4rec.mx+j,c2rec.logno,c2rec.hawb_hawbno,c2rec.camov_seal,c2rec.detaildesc,c2rec.hazard,c2rec.ecn,c2rec.sa,c2rec.cl,
         c2rec.pktpe_packtype,c2rec.owner,round(c2rec.partvolume/nmb,5),trunc(c2rec.partweight/nmb),trunc(c2rec.qty/nmb),c2rec.movement_no,
         c2rec.deliveryno,c2rec.entry_no,c2rec.line_no,c2rec.warehouse,c2rec.handling_unit);
      end if;
    end loop;
    delete from strang.detailrs where rowid = chartorowid(replace(rid,'~','+'));
    commit;
    receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_319 );
    return;
  end if;

  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );

  glbx.main_title( surl, LNGS.STR_TXT_089,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR06',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);

  htp.nl;
  htp.p( '<CENTER>' );
  htp.formopen( 'strangp.accept_manual_split' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RECCTR', recctr);
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
    htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold( LNGS.STR_TXT_083 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold( c2rec.qty ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( LNGS.STR_TXT_090,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( LNGS.STR_TXT_091,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
   for j in 1..nmb loop
    htp.tablerowopen;
     htp.tabledata( to_char(j),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     if j = 1
      then
       htp.tabledata( htf.formtext('P1',5,5,to_char(trunc(c2rec.qty/nmb) + mod(c2rec.qty,nmb))),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.formtext('P1',5,5,to_char(trunc(c2rec.qty/nmb))),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     end if;
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     if j = 1
      then
       htp.tabledata( htf.formtext( 'P2', 10, 20, to_char(trunc(c2rec.partweight/nmb) + mod(c2rec.partweight,nmb))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( htf.formtext( 'P3', 10, 20, to_char(round(c2rec.partvolume/nmb,5))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.formtext( 'P2', 10, 20, to_char(trunc(c2rec.partweight/nmb))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( htf.formtext( 'P3', 10, 20, to_char(round(c2rec.partvolume/nmb,5))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
   htp.formsubmit( 'ACTION', LNGS.STR_TXT_092 );
   htp.formsubmit( 'ACTION', LNGS.STR_TXT_318 );
   htp.formclose;
   htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_SPLIT_DETAILRS',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_split_detailrs;

procedure accept_manual_split(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

 cursor c2( rid rowid ) is select * from strang.detailrs where rowid = rid;
 cursor c3( dlr number ) is select rowid from strang.receivals where deliveryno = dlr;
 cursor c4( dlr number ) is select max(itemno) mx from strang.detailrs where deliveryno = dlr;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		integer;
 nmb2		integer;
 nmb3		number;
 nmb4		number;
 sts		varchar2(100);
 vaccess	varchar2(20);
 tot_nmb	number;
 tot_weight	number;
 tot_volume	number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_SPLIT_DETAILRS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'DETAILRS', rid );

  open c2(chartorowid(replace(rid,'~','+')));
  fetch c2 into c2rec;
  close c2;
  c2rec.partweight := nvl(c2rec.partweight,0);
  c2rec.partvolume := nvl(c2rec.partvolume,0);
  c2rec.qty := nvl(c2rec.qty,0);

  open c3(c2rec.deliveryno);
  fetch c3 into c3rec;
  close c3;
  if action = LNGS.STR_TXT_318
   then
    receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_320 );
    return;
  end if;
  begin nmb := p1.last; exception when others then receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_087 ); return; end;

  if nmb > c2rec.qty then receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_088 ); return; end if;
  open c4(c2rec.deliveryno);
  fetch c4 into c4rec;
  close c4;
  c4rec.mx := nvl(c4rec.mx,0);

  tot_nmb := 0;
  tot_weight := 0;
  tot_volume := 0;
  for j in 1..nmb loop
   begin nmb2 := to_number(p1(j)); exception when others then nmb2 := 0; end;
   begin nmb3 := to_number(p2(j)); exception when others then nmb3 := 0; end;
   begin nmb4 := to_number(p3(j)); exception when others then nmb4 := 0; end;
   --if nmb2 < 1 or nmb2 > c2rec.qty then nmb2 := 1; end if;

   update strang.detailrs
    set
     partvolume = nmb4,
     partweight = nmb3,
     qty = nmb2
   where
    itemno = c4rec.mx+j and
    deliveryno = c2rec.deliveryno;
   if sql%notfound
    then
     insert into strang.detailrs
         (itemno,logno,hawb_hawbno,camov_seal,detaildesc,hazard,ecn,sa,cl,pktpe_packtype,owner,
          partvolume,partweight,qty,
          movement_no,deliveryno,entry_no,line_no,warehouse,handling_unit) values
         (c4rec.mx+j,c2rec.logno,c2rec.hawb_hawbno,c2rec.camov_seal,c2rec.detaildesc,c2rec.hazard,c2rec.ecn,c2rec.sa,c2rec.cl,
          c2rec.pktpe_packtype,c2rec.owner,
          nmb4,nmb3,nmb2,
          c2rec.movement_no,c2rec.deliveryno,c2rec.entry_no,c2rec.line_no,c2rec.warehouse,strang.f_sap_format(c2rec.handling_unit,'HANDLING_UNIT'));
    end if;

    tot_nmb := tot_nmb + nmb2;
    tot_weight := tot_weight + nmb3;
    tot_volume := tot_volume + nmb4;
  end loop;

  if tot_nmb <> c2rec.qty
   then
    rollback;
    receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_342 || ':' || to_char(tot_nmb) || '-' || to_char(c2rec.qty) );
    return;
  elsif tot_weight <> c2rec.partweight
   then
    rollback;
    receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_343 || ':' || to_char(tot_weight) || '-' || to_char(c2rec.partweight) );
    return;
  elsif tot_volume <> c2rec.partvolume
   then
    rollback;
    receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_344 || ':' || to_char(tot_volume) || '-' || to_char(c2rec.partvolume) );
    return;
  else
   delete from strang.detailrs where rowid = chartorowid(replace(rid,'~','+'));
  end if;

  commit;
  receive_bottom(surl,c3rec.rowid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_093 );
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MANUAL_SPLIT',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_manual_split;

procedure receive_po(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL )
as

 cursor c2( rid rowid ) is select * from strang.receivals where rowid = rid;
 cursor c3( dlrvy number ) is
  select rowid,recno,inventoryno,po,supinv,amount,qty,unit_unitused,excise_qty, excise_unit, ctry_countrycode,gstc_gstcode,gst,tamount,delivery_charge,deliveryno,po_item_no,off_site_receipt,sap_delno,sap_delno_item,grn,state
  from strang.pos
  where deliveryno = dlrvy
  order by recno,inventoryno;
 cursor c4( dlrvy number ) is select count('x') tot, max(recno) mx from strang.pos where deliveryno = dlrvy;
 cursor c5( dlryno number ) is select max(recno) tot from strang.pos where deliveryno = dlryno;
 cursor c6( vste varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'DEFAULT COUNTRY CODE' and cola = vste;
 cursor c7( dlryno number ) is
  select nvl(l.cola,'LC') wbill
  from strang.lov l, strang.detailrs dr
  where lov_name = 'PACKTYPES' and
  dr.pktpe_packtype = l.code and
  dr.deliveryno = dlryno and
  dr.itemno in
  (select min(itemno)
   from strang.detailrs
   where deliveryno = dlryno)
;

 c1rec    customer_account%ROWTYPE;
 c2rec    c2%ROWTYPE;
 c3rec    c3%ROWTYPE;
 c4rec    c4%ROWTYPE;
 c5rec    c5%ROWTYPE;
 pfx    THEME%ROWTYPE;
 ltype    varchar2(100);
 stype    integer;
 owner_id integer;
 sts    varchar2(100);
 vrecctr  integer;
 vaccess  varchar2(20);
 ttl    varchar2(200);
 vste   varchar2(10);
 seclevel varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.RECEIVE_BOTTOM' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'POS', rid );

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 seclevel := oltp.security_role( owner_id );

 open c2( replace(rid,'~','+') );
 fetch c2 into c2rec;
 close c2;
 if access_id = 'z'
  then
   ttl := LNGS.STR_TXT_094;
   glbx.main_title( surl, NULL,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR07',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
   return;
  else
   if recctr > 0
    then
     open c4( c2rec.deliveryno );
     fetch c4 into c4rec;
     close c4;

     vrecctr := recctr;
     if recctr > c4rec.tot then vrecctr := c4rec.tot; end if;
     ttl := nvl(msg,LNGS.STR_TXT_095 ||  '(' || vrecctr || '/' || c4rec.tot || ')');
     glbx.main_title( surl, NULL,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR07',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
    else
     vrecctr := 0;
     ttl := nvl(msg,LNGS.STR_TXT_096);
     glbx.main_title( surl, NULL,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR07',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
   end if;
 end if;
 htp.p( '<CENTER>' );
  if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_receive_po' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RECCTR', vrecctr);
 end if;

 if vaccess = 'READ' and vrecctr = 0
  then
   vrecctr := 1;
 end if;

 if vrecctr > 0
  then
   open c3( c2rec.deliveryno );
   for j in 1..vrecctr loop
   fetch c3 into c3rec;
    if c3%NOTFOUND then exit; end if;
   end loop;
   close c3;
end if;

 if recctr = 0
  then
    c5rec.tot := NULL;
    open c5( c2rec.deliveryno );
    fetch c5 into c5rec;
    close c5;
    open c6(vste);
    fetch c6 into c3rec.ctry_countrycode;
    close c6;
    c3rec.unit_unitused := 'NO';
    c3rec.qty := 1;
--    c3rec.po_item_no := 1;
/*    open c7(c2rec.deliveryno);
    fetch c7 into c3rec.po_waybill_type ;
    close c7;
    if c3rec.po_waybill_type is null
      then c3rec.po_waybill_type := 'LC';
    end if;
*/ -- 20150526
 end if;

 if vaccess = 'EDIT' then htp.formhidden( 'DETRID', rowidtochar( c3rec.rowid )); end if;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_097 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if recctr = 0
    then
     htp.tabledata( htf.bold( to_char(nvl(c5rec.tot,0) + 1) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.formhidden( 'P0', to_char(nvl(c5rec.tot,0) + 1) );
    else
     htp.tabledata( htf.bold( c3rec.recno ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.formhidden( 'P0', to_char(c3rec.recno) );
   end if;
   htp.formhidden( 'P1', c3rec.recno );
   htp.tabledata( htf.bold( LNGS.STR_TXT_098 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'P3', 12, 15, c3rec.po ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( c3rec.po,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   htp.tabledata( htf.bold( LNGS.STR_TXT_099 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'P5', 12, 15, c3rec.supinv ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( c3rec.supinv,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   htp.tabledata( htf.bold( 'OTML PO Item' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'P51', 5, 10, c3rec.po_item_no ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( c3rec.po_item_no,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
       htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_100 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
       htp.formtext( 'P2', 12, 15, c3rec.inventoryno );
       htp.anchor2( 'strangp.lov?surl=' || surl || '&call_name=strangp.lov&parm=INVENT&lrange=&src=' || c3rec.inventoryno, 'Inventory',ctarget=>'INVENT_SEARCH' );

       htp.p( '</TD>' );
    else
     htp.tabledata( c3rec.inventoryno,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   htp.tabledata( htf.bold( LNGS.STR_TXT_055 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'D6', 12, 15, c3rec.qty), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    else
     htp.tabledata( c3rec.qty, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( LNGS.STR_TXT_101 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'D7', 8, 10, c3rec.unit_unitused), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    else
     htp.tabledata( c3rec.unit_unitused, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'State' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if VACCESS = 'EDIT'
   then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'STATE', 'ST', c3rec.state, FALSE, FALSE, TRUE );
     htp.p( '</TD>' );
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'STATE', 'ST', c3rec.state, FALSE, FALSE, TRUE, isedit=>FALSE );
     htp.p( '</TD>' );
   end if;
   htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
       htp.p( '</TD>' );
  htp.tablerowclose;
---------------------------------------------------------------
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'OTML Delivery No' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'p53', 12, 15, c3rec.sap_delno), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    else
     htp.tabledata( c3rec.sap_delno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'OTML Delivery Qty' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'p53a', 10, 15, c3rec.sap_delno_item), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    else
     htp.tabledata( c3rec.sap_delno_item, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Excise Qty'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'D6e', 12, 15, c3rec.excise_qty), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    else
     htp.tabledata( c3rec.excise_qty, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Excise Unit' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'D7e', 8, 10, c3rec.excise_unit), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
--	  htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
--	  lov_list( 'UNITS', 'D7E', c3rec.excise_unit, FALSE, TRUE, FALSE, isedit=>FALSE );
--	  htp.p( '</TD>' );
    else
     htp.tabledata( c3rec.excise_unit, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
       htp.p( '</TD>' );
  htp.tablerowclose;

---------------------------------------------------------------
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_102 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'UNCTYTAB', 'P4', c3rec.ctry_countrycode, TRUE, TRUE, TRUE );
     htp.p( '</TD>' );
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'UNCTYTAB', 'P4', c3rec.ctry_countrycode, TRUE, TRUE, TRUE, isedit=>FALSE );
     htp.p( '</TD>' );
   end if;
   htp.tabledata( htf.bold( LNGS.STR_TXT_103 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3>' );
       htp.formhidden( 'D4', nvl(c3rec.gstc_gstcode,c2rec.gstc_gstcode) );
       lov_list( 'GSTCODES', 'D4', nvl(c3rec.gstc_gstcode,c2rec.gstc_gstcode), FALSE, TRUE, TRUE, isedit=>FALSE );
       htp.p( '</TD>' );
      else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3>' );
       lov_list( 'GSTCODES', 'D4', nvl(c3rec.gstc_gstcode,c2rec.gstc_gstcode), FALSE, TRUE, TRUE );
       htp.p( '</TD>' );
     end if;
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=3>' );
     lov_list( 'GSTCODES', 'D4', nvl(c3rec.gstc_gstcode,c2rec.gstc_gstcode), FALSE, TRUE, TRUE, isedit=>FALSE );
     htp.p( '</TD>' );
   end if;
--   htp.tabledata( htf.bold( 'PNG Warehouse' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.formhidden( 'P52', null);
--     htp.tabledata( htf.formtext( 'P52', 10, 15, c3rec.po_warehouse), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
--    else
--     htp.tabledata( c3rec.po_warehouse, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( 'Goods Receipt No.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'pgrn', 11, 17, c3rec.grn), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    else
     htp.tabledata( c3rec.grn, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( '' ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=1>' );
       htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_104 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.tabledata( htf.formhidden( 'D3', ltrim(to_char(c3rec.amount,LNGS.STR_FRMT_06))) || ltrim(to_char(c3rec.amount,LNGS.STR_FRMT_06)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
      else
       htp.tabledata( htf.formtext( 'D3', 15, 15, ltrim(to_char(c3rec.amount,LNGS.STR_FRMT_06))), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
    else
     htp.tabledata( ltrim(to_char(c3rec.amount,LNGS.STR_FRMT_06)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( LNGS.STR_TXT_105 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.tabledata( htf.formhidden( 'D5', ltrim(to_char(c3rec.gst,LNGS.STR_FRMT_06))) || ltrim(to_char(c3rec.gst,LNGS.STR_FRMT_06)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
      else
       htp.tabledata( htf.formtext( 'D5', 12, 12, ltrim(to_char(c3rec.gst,LNGS.STR_FRMT_06))), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
     end if;
    else
     htp.tabledata( ltrim(to_char(c3rec.gst,LNGS.STR_FRMT_06)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.tabledata( htf.bold( LNGS.STR_TXT_106 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'D8', 15, 15, ltrim(to_char(c3rec.tamount,LNGS.STR_FRMT_06))), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    else
     htp.tabledata( ltrim(to_char(c3rec.tamount,LNGS.STR_FRMT_06)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
     htp.tabledata( htf.bold('Freight Charge') ,cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext( 'D8a', 15, 15, ltrim(to_char(c3rec.delivery_charge,LNGS.STR_FRMT_06))), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
    else
     htp.tabledata( ltrim(to_char(c3rec.delivery_charge,LNGS.STR_FRMT_06)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"' );
   end if;
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
   htp.tablerowopen;
   if vaccess = 'EDIT'
    then
     if c3rec.rowid is not null
      then
       htp.tabledata( htf.formimage( LNGS.STR_TXT_067,glbx.IMAGE_LOCATION || 'adminc_save.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       htp.tabledata( htf.formimage( LNGS.STR_TXT_068,glbx.IMAGE_LOCATION || 'adminc_insert.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       if seclevel in ( 'LEVEL 8' )
        then
         null;
        else
         htp.tabledata( htf.formimage( LNGS.STR_TXT_107,glbx.IMAGE_LOCATION || 'adminc_copy.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       end if;
       if vrecctr <> '0' then htp.tabledata( htf.formimage( LNGS.STR_TXT_070,glbx.IMAGE_LOCATION || 'adminc_delete.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' )); end if;
      else
       htp.tabledata( htf.formimage( LNGS.STR_TXT_067,glbx.IMAGE_LOCATION || 'adminc_save.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       if recctr > 0
        then
         htp.tabledata( htf.formimage( LNGS.STR_TXT_068,glbx.IMAGE_LOCATION || 'adminc_insert.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       end if;
     end if;
   end if;

    if recctr = 0
     then
      if vrecctr <> '0' then htp.tabledata( htf.formimage( LNGS.STR_TXT_359,glbx.IMAGE_LOCATION || 'adminc_cancel.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' )); end if;
    elsif vrecctr > 1 and vrecctr < c4rec.tot
    then
     if vaccess = 'EDIT'
      then
       htp.tabledata( htf.formimage( LNGS.STR_TXT_410,glbx.IMAGE_LOCATION || 'adminc_first.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       htp.tabledata( htf.formimage( LNGS.STR_TXT_071,glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       htp.tabledata( htf.formimage( LNGS.STR_TXT_072,glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       htp.tabledata( htf.formimage( LNGS.STR_TXT_411,glbx.IMAGE_LOCATION || 'adminc_last.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
      elsif vaccess = 'READ'
       then
         htp.tabledata( htf.anchor( 'strangp.receive_po?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=1', htf.img( glbx.IMAGE_LOCATION || 'adminc_first.gif', cattributes=>' BORDER=0',calt=>'First Record' ) ));
         htp.tabledata( htf.anchor( 'strangp.receive_po?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr-1), htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0',calt=>'Previous Record' ) ));
         htp.tabledata( htf.anchor( 'strangp.receive_po?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr+1), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ) ));
      end if;
    elsif vrecctr = c4rec.tot
     then
      if vrecctr > 1
       then
        if vaccess = 'EDIT'
         then
          htp.tabledata( htf.formimage( LNGS.STR_TXT_410,glbx.IMAGE_LOCATION || 'adminc_first.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
          htp.tabledata( htf.formimage( LNGS.STR_TXT_071,glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=> ' BORDER=0 ALIGN="LEFT"' ));
        elsif vaccess = 'READ'
         then
          htp.tabledata( htf.anchor( 'strangp.receive_po?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=1', htf.img( glbx.IMAGE_LOCATION || 'adminc_first.gif', cattributes=>' BORDER=0',calt=>'First Record' ) ));
          htp.tabledata( htf.anchor( 'strangp.receive_po?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr-1), htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0',calt=>'Previous Record' ) ));
        end if;
      end if;
    else
     if vaccess = 'EDIT'
      then
       htp.tabledata( htf.formimage( LNGS.STR_TXT_072,glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
       htp.tabledata( htf.formimage( LNGS.STR_TXT_411,glbx.IMAGE_LOCATION || 'adminc_last.gif', cattributes=>' BORDER=0 ALIGN="LEFT"' ));
      elsif vaccess = 'READ'
       then
         htp.tabledata( htf.anchor( 'strangp.receive_po?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(vrecctr+1), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ) ));
     end if;
   end if;
   htp.formclose;

   htp.tabledata( htf.formopen( 'strangp.receive_po' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
          htf.formhidden( 'SCID', scid ) || htf.formtext( 'RECCTR', 2, 5, vrecctr ) || htf.formhidden( 'CALL_NAME', call_name ) ||
          htf.formhidden( 'PARM', parm ) || htf.formhidden( 'ACCESS_ID', access_id ) || htf.formsubmit( null, 'Goto' ) || htf.formclose );
    htp.tablerowclose;
    htp.tableclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.bold( ttl );
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'RECEIVE_PO',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end receive_po;

procedure confirm_delete_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL )
as

 cursor c2( rid rowid ) is select * from strang.detailrs where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 ttl		varchar2(200);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.CONFIRM_DELETE_DETAILRS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'POS', rid );

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c2( replace(detrid,'~','+') );
 fetch c2 into c2rec;
 close c2;
 if vaccess <> 'EDIT' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 glbx.main_title( surl, 'Confirm Delete of ' || c2rec.itemno, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR07',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
 htp.p( '<CENTER>' );
 htp.formopen( 'strangp.accept_delete_detailrs' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'DETRID', replace(detrid,'~','+') );
 htp.formhidden( 'ACCESS_ID', access_id );
 htp.formhidden( 'RECCTR', recctr);
 htp.formsubmit( 'ACTION', LNGS.STR_TXT_450 );
 htp.formsubmit( 'ACTION', 'Delete Detail Record' );
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'CONFIRM_DELETE_DETAILRS',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end confirm_delete_detailrs;

procedure confirm_delete_po(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default NULL )
as

 cursor c2( rid rowid ) is select * from strang.pos where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 ttl		varchar2(200);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.CONFIRM_DELETE_PO' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'POS', rid );

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 open c2( replace(detrid,'~','+') );
 fetch c2 into c2rec;
 close c2;
 if vaccess <> 'EDIT' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 glbx.main_title( surl, 'Confirm Delete of ' || c2rec.po, glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR07',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc, title_only=>TRUE);
 htp.p( '<CENTER>' );
 htp.formopen( 'strangp.accept_delete_po' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'DETRID', replace(detrid,'~','+') );
 htp.formhidden( 'ACCESS_ID', access_id );
 htp.formhidden( 'RECCTR', recctr);
 htp.formsubmit( 'ACTION', LNGS.STR_TXT_450 );
 htp.formsubmit( 'ACTION', 'Delete Purchase Order Record' );
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'CONFIRM_DELETE_PO',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end confirm_delete_po;

procedure accept_delete_detailrs(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer, action in varchar2 )
as

 cursor c2( rid rowid ) is select deliveryno from strang.receivals where rowid = rid;
 cursor c6( rid rowid ) is select movement_no, camov_seal from strang.detailrs where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c6rec		c6%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newrid		rowid;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_DELETE_DETAILRS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );

 open c2( chartorowid( replace(rid,'~','+') ) );
 fetch c2 into c2rec;
 close c2;

 if action = 'Delete Detail Record'
  then
   open c6( chartorowid( detrid ));
   fetch c6 into c6rec;
   close c6;
   delete from strang.detailrs where rowid = chartorowid( detrid );
   if c6rec.movement_no is not null
    then
     recalc_weight( c6rec.movement_no, sl=>c6rec.camov_seal );
   end if;
   commit;
   receive_bottom(surl,rid,scid,null,parm,access_id,recctr - 1,LNGS.STR_TXT_073 );
  else
   receive_bottom(surl,rid,scid,null,parm,access_id,recctr,'Action Cancelled' );
 end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_DELETE_DETAILRS',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_delete_detailrs;

procedure accept_delete_po(surl in varchar2, rid in varchar2, scid in varchar2, detrid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer, action in varchar2 )
as

 cursor c2( rid rowid ) is select deliveryno from strang.receivals where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 newrid		rowid;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_DELETE_PO' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );

 open c2( chartorowid( replace(rid,'~','+') ) );
 fetch c2 into c2rec;
 close c2;

 if action = 'Delete Purchase Order Record'
  then
   delete from strang.pos where rowid = chartorowid( detrid );
   commit;
   receive_po(surl,rid,scid,null,parm,access_id,recctr - 1,LNGS.STR_TXT_073 );
  else
   receive_po(surl,rid,scid,null,parm,access_id,recctr,'Action Cancelled' );
 end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_DELETE_PO',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_delete_po;

procedure accept_receive_po(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer,
                            detrid in varchar2, p0 in varchar2, p1 in varchar2, p2 in varchar2 default null, p3 in varchar2, p4 in varchar2, p5 in varchar2,
                            p51 in varchar2, p52 in varchar2, p53 in varchar2, p53a in varchar2,pgrn in varchar2,
                            d3 in varchar2, d4 in varchar2, d5 in varchar2, d6 in varchar2, d7 in varchar2, st in varchar2, d6e in varchar2, d7e in varchar2, d8 in varchar2, d8a in varchar2, cancel in varchar2 default null,
                            save_record in varchar2 default null, first_record in varchar2 default null, previous_record in varchar2 default null, next_record in varchar2 default null, last_record in varchar2 default null, insert_record in varchar2 default null, delete_record in varchar2 default null, copy_record in varchar2 default null)
as

 cursor c2( rid rowid ) is select deliveryno from strang.receivals where rowid = rid;
 cursor c3( dlryno number, rno integer, rid rowid ) is select 'x' tot from strang.pos where recno = rno and deliveryno = dlryno and rowid <> rid;
 cursor c4( lname varchar2, inv varchar2 ) is select 'x' from strang.lov where lov_name = lname and code = inv;
 cursor c5( cde varchar2 ) is select to_number(cola) cola, colb from strang.lov where lov_name = 'GSTCODES' and code = cde;
 cursor c6( rid rowid ) is select * from strang.pos where rowid = rid;
 cursor c7( rid rowid ) is select max(recno)+1 mx from strang.pos where deliveryno = (select deliveryno from strang.pos where rowid = rid );
 cursor c8( rid rowid ) is select count('x') ctr from strang.pos where deliveryno = (select deliveryno from strang.pos where rowid = rid );

 c1rec    customer_account%ROWTYPE;
 c2rec    c2%ROWTYPE;
 c3rec    c3%ROWTYPE;
 c4rec    c4%ROWTYPE;
 c5rec    c5%ROWTYPE;
 c6rec    c6%ROWTYPE;
 c7rec    c7%ROWTYPE;
 c8rec    c8%ROWTYPE;
 pfx    THEME%ROWTYPE;
 ltype    varchar2(100);
 stype    integer;
 owner_id integer;
 pv   number(8,3);
 pw   number(9,1);
 qt   number;
 itn  number(5,2);
 qte  number;
 am   number(9,2);
 tam  number(9,2);
 dc   number(9,2);
 gs   number(9,2);
 lno            integer;
 vmsg   varchar2(100);
 sts    varchar2(100);
 newrid   rowid;

begin
 if cancel is not null
  then
   receive_po(surl,rid,scid,null,parm,access_id,1,null );
   return;
 elsif first_record is not null
  then
   receive_po(surl,rid,scid,null,parm,access_id,1,null );
   return;
 elsif previous_record is not null
  then
   receive_po(surl,rid,scid,null,parm,access_id,recctr - 1,null );
   return;
 elsif next_record is not null
  then
   receive_po(surl,rid,scid,null,parm,access_id,recctr + 1,null );
   return;
 elsif last_record is not null
  then
   open c8( chartorowid(detrid) );
   fetch c8 into c8rec;
   close c8;
   receive_po(surl,rid,scid,null,parm,access_id,c8rec.ctr,null );
   return;
 elsif insert_record is not null
  then
   receive_po(surl,rid,scid,null,parm,access_id,0,null );
   return;
 elsif copy_record is not null
  then
   open c6( chartorowid(detrid) );
   fetch c6 into c6rec;
   close c6;
   open c7( chartorowid(detrid) );
   fetch c7 into c7rec;
   close c7;
   insert into strang.pos(recno,inventoryno,po,supinv,amount,qty,unit_unitused,excise_qty,excise_unit,ctry_countrycode,gstc_gstcode,gst,tamount,delivery_charge,deliveryno,po_item_no,off_site_receipt,sap_delno, sap_delno_item,grn,state) values
    (nvl(c7rec.mx,1),upper(c6rec.inventoryno),c6rec.po,c6rec.supinv,c6rec.amount,c6rec.qty,c6rec.unit_unitused,c6rec.excise_qty,c6rec.excise_unit,c6rec.ctry_countrycode,c6rec.gstc_gstcode,c6rec.gst,c6rec.tamount,c6rec.delivery_charge,c6rec.deliveryno,c6rec.po_item_no,c6rec.off_site_receipt,c6rec.sap_delno,nvl(c6rec.sap_delno_item,c6rec.qty),c6rec.grn,c6rec.state)
    returning rowid into newrid;
   commit;
   open c8( newrid );
   fetch c8 into c8rec;
   close c8;
   receive_po(surl,rid,scid,null,parm,access_id,c8rec.ctr,null );
   return;
 elsif delete_record is not null
  then
   confirm_delete_po(surl,rid,scid,detrid,parm,access_id,recctr,'Confirm Delete of Purchase'  );
   return;
 end if;

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_RECEIVE_PO' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );

 open c2( chartorowid( replace(rid,'~','+') ) );
 fetch c2 into c2rec;
 close c2;

 itn := to_number( p1 );
 lno := to_number( p51 );
 open c3( c2rec.deliveryno, itn, detrid );
 fetch c3 into c3rec;
 if c3%FOUND
  then
    close c3;
    receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_108 || ': ' || p1 || '-' || p2 );
    return;
  end if;
  close c3;

  begin qt := to_number( d6 ); exception when others then receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_109 || ': ' || d6 ); return; end;
  begin qte := to_number( d6e ); exception when others then receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_109e || ': ' || d6e ); return; end;
  begin am := to_number( d3 ); exception when others then receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_110 || ': ' || d3 ); return; end;
  begin tam := to_number( d8 ); exception when others then receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_111 || ': ' || d8 ); return; end;
  begin gs := to_number( d5 ); exception when others then receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_112 || ': ' || d5 ); return; end;
  begin dc := to_number( nvl(d8a,'0.00') ); exception when others then receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_111 || ': ' || d8a ); return; end;

  open c4( 'INVENT', p2 );
  fetch c4 into c4rec;
  /*
  -- Inventory Check currently disabled as requested by Strang
  if c4%NOTFOUND
   then
    close c4;
    receive_po(surl,rid,scid,null,parm,access_id,recctr,'Inventory Number does not exist: ' || p2 );
    return;
  end if;
  */
  close c4;

  if d7 is not null
   then
    open c4( 'UNITS', upper(d7) );
    fetch c4 into c4rec;
    -- Inventory Check currently disabled as requested by Strang
    if c4%NOTFOUND
     then
      close c4;
      receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_379 );
      return;
    end if;
    close c4;
  end if;

  if am is null and tam is null and gs is null
   then

    -- Do not do any checking. Put in at the request of Sallie.
    NULL;

   else

    if gs is null and tam is null
     then
      open c5(d4);
      fetch c5 into c5rec;
      close c5;
      if c5rec.colb = LNGS.STR_TXT_366
       then
        gs := c5rec.cola;
        tam := am;
      elsif c5rec.colb = LNGS.STR_TXT_367
       then
        gs := c5rec.cola;
        tam := am;
        am := ((100 * tam) / (100 + nvl(gs,0) ));
        gs := am * (c5rec.cola/100);
      else
        gs := c5rec.cola;
        tam := am * (1 + (gs/100));
        gs := am * (c5rec.cola/100);
      end if;
     else
      if c5rec.colb = LNGS.STR_TXT_367
       then
        vmsg := LNGS.STR_TXT_113;
      elsif c5rec.colb = LNGS.STR_TXT_366
        then
         vmsg := LNGS.STR_TXT_114;
      end if;
    end if;

    if am is null and tam is not null and gs is not null
     then
      open c5(d4);
      fetch c5 into c5rec;
      close c5;
      am := tam - nvl(gs,0);
      if c5rec.colb = LNGS.STR_TXT_368
       then
        vmsg := LNGS.STR_TXT_115;
      end if;
     else
      -- removed as requested
      NULL;
      /*
      if c5rec.colb = LNGS.STR_TXT_367
       then
        vmsg := LNGS.STR_TXT_116;
      end if;
      */
    end if;

    if tam is null
     then
      open c5(d4);
      fetch c5 into c5rec;
      close c5;
      if c5rec.colb = LNGS.STR_TXT_366
       then
        gs := c5rec.cola;
        tam := am;
      elsif c5rec.colb = LNGS.STR_TXT_367
       then
        gs := c5rec.cola;
        tam := am;
        am := ((100 * tam) / (100 + nvl(gs,0) ));
        gs := am * (c5rec.cola/100);
      else
        gs := c5rec.cola;
        tam := am * (1 + (gs/100));
        gs := am * (c5rec.cola/100);
      end if;
      if c5rec.colb = LNGS.STR_TXT_367
       then
        vmsg := LNGS.STR_TXT_117;
      elsif c5rec.colb = LNGS.STR_TXT_368
       then
        vmsg := LNGS.STR_TXT_118;
      end if;
    end if;

  end if; /* To: are all values null */

  if detrid is null
   then
    begin
        insert into strang.pos(deliveryno,recno,inventoryno,po,ctry_countrycode,supinv,gstc_gstcode,gst,amount,tamount,delivery_charge,qty,unit_unitused,excise_qty,excise_unit, po_item_no,off_site_receipt,sap_delno,sap_delno_item,grn,state) values
            ( c2rec.deliveryno, to_number(p0), strang.f_sap_format(p2,'INVENTORYNO'),strang.f_sap_format(p3,'PO'),p4,p5,d4 ,gs,am,tam,dc,qt,upper(d7),qte,upper(d7e),lno,p52,strang.f_sap_format( to_char(p53),'DELIVERYNO'),nvl(p53a,d6),strang.f_sap_format(pgrn,'GRN'),st) returning rowid into newrid;
    exception
      when others then
            receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_079 || ': ' || sqlerrm );
            return;
    end;
   else
    -- Update The Row
    begin
         update strang.pos
          set
           inventoryno = strang.f_sap_format(p2,'INVENTORYNO'),
           po = strang.f_sap_format(p3,'PO'),
           ctry_countrycode = p4,
           supinv = p5,
           amount = am,
           gstc_gstcode = d4,
           gst = gs,
           qty = qt,
           unit_unitused = upper(d7),
           excise_qty = qte,
           excise_unit = upper(d7e),
           tamount = tam ,
           delivery_charge = dc,
           po_item_no = lno,
 	   sap_delno = strang.f_sap_format(p53,'DELIVERYNO'),
 	   sap_delno_item = nvl(p53a,qt),
 	   grn = strang.f_sap_format(pgrn,'GRN'),
 	   state = st
       where rowid = chartorowid( detrid );
        exception
             when others then
              receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_080 || ': ' || sqlerrm );
              return;
       end;
   end if;

 commit;

 if save_record is not null
  then
   if detrid is null
    then
     open c8( newrid );
     fetch c8 into c8rec;
     close c8;
     receive_po(surl,rid,scid,null,parm,access_id,c8rec.ctr,nvl(vmsg,LNGS.STR_TXT_081) );
    else
     receive_po(surl,rid,scid,null,parm,access_id,recctr,nvl(vmsg,LNGS.STR_TXT_081) );
   end if;
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_RECEIVE_PO',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_receive_po;

procedure movement(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2(rid rowid) is select * from strang.movements where rowid = rid;
 cursor c2d(rid rowid) is
  select ship_id
       , complete
	   , container_type
	   , iso_container_type
	   , tare
	   , dispatch_date
	   , departure
	   , arrival
	   , bol
	   , booking_ref
	   , move_description
	   , physical_pack
	   , computer_pack
  from   strang.movements
  where  rowid = rid
  ;
 cursor c3(shp integer) is select rowid,status from strang.ships_airway where ship_id = shp;
 cursor c4(mvid varchar2) is select count('x') tot from strang.detailrs where movement_no = mvid;
 cursor c5 is select chargecode from strang.charges order by chargecode;
 cursor c6(cd varchar2, vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = vste;
 --  and nvl(estarrive,sysdate) > add_months(sysdate,-2)
 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c2drec		c2d%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c6rec		c6%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 seclevel	varchar2(100);
 mf		varchar2(100);
 vste		varchar2(10);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.MOVEMENT' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 seclevel := oltp.security_role( owner_id );
 vaccess := data_access( owner_id, 'MOVEMENT', rid );

 if parm = 'CARGO'
  then
   glbx.main_title( surl, LNGS.STR_TXT_119,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR08',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 elsif parm = 'CONMOV'
  then
   glbx.main_title( surl, LNGS.STR_TXT_120,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR08',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 elsif parm = 'AIRWAY'
  then
   glbx.main_title( surl, LNGS.STR_TXT_121,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR08',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 end if;
 htp.p( '<CENTER>' );
  if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if access_id = 'z'
  then
   c2rec.complete := 'F';
   c2rec.dispatch_date := sysdate;
   if parm = 'CARGO'
    then
     open c6( 'CARGODEPARTLOC', vste );
     fetch c6 into c6rec;
     close c6;
     c2rec.departure := c6rec.description;
     open c6( 'CARGOARRIVELOC', vste );
     fetch c6 into c6rec;
     close c6;
     c2rec.arrival := c6rec.description;
     open c6( 'TARE_DEFAULT', vste );
     fetch c6 into c6rec;
     close c6;
     begin c2rec.tare := c6rec.description; exception when others then null; end;
     if msg = lngs.STR_TXT_463 -- Insert New Movement as Copy
      then
       -- glbx.dbg('Record: ' || replace(rid,'~','+'));
       open c2d(replace(rid,'~','+'));
       fetch c2d into c2drec;
       if c2d%FOUND
        then
         c2rec.ship_id := c2drec.ship_id;
         c2rec.complete := c2drec.complete;
         c2rec.container_type := c2drec.container_type;
         c2rec.iso_container_type := c2drec.iso_container_type;
         c2rec.tare := c2drec.tare;
         c2rec.dispatch_date := c2drec.dispatch_date;
         c2rec.departure := c2drec.departure;
         c2rec.arrival := c2drec.arrival;
         c2rec.bol := c2drec.bol;
         c2rec.booking_ref  := c2drec.booking_ref;
         c2rec.move_description := c2drec.move_description;
         c2rec.physical_pack := c2drec.physical_pack;
         c2rec.computer_pack := c2drec.computer_pack;
       end if;
       close c2d;
     end if;

   elsif parm = 'CONMOV'
    then
     open c6( 'CONDEPARTLOC', vste );
     fetch c6 into c6rec;
     close c6;
     c2rec.departure := c6rec.description;
     open c6( 'CONARRIVELOC', vste );
     fetch c6 into c6rec;
     close c6;
     c2rec.arrival := c6rec.description;
   elsif parm = 'AIRWAY'
    then
     open c6( 'AIRARRIVELOC', vste );
     fetch c6 into c6rec;
     close c6;
     c2rec.arrival := c6rec.description;
     open c6( 'AIRDEPARTLOC', vste );
     fetch c6 into c6rec;
     close c6;
     c2rec.departure := c6rec.description;
     open c6( 'AIRCHARGECODE', vste );
     fetch c6 into c6rec;
     close c6;
     c2rec.chargecode := c6rec.description;
   end if;
  else
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
   if (mf is not null) and (vaccess = 'EDIT') and (c2rec.complete in ('N','F'))
    then
     -- Check if the Controlling Office. If not then Read Only Access
     if mf <> c2rec.controlling_office
      then
       vaccess := 'READ';
     end if;
   end if;
 end if;

 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<TD align="LEFT">' );

 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_movement' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );

   if access_id = 'z'
    then
     htp.formhidden( 'RID', null );
    else
   htp.formhidden( 'RID', replace(rid,'~','+') );
   end if;
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  if mf <> c2rec.controlling_office and mf is not null
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_309),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold(c2rec.controlling_office),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  htp.tablerowopen;
   if parm = 'CARGO'
    then
     htp.tabledata( htf.bold(LNGS.STR_TXT_122),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   elsif parm = 'CONMOV'
    then
     htp.tabledata( htf.bold(LNGS.STR_TXT_123),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   elsif parm = 'AIRWAY'
    then
     htp.tabledata( htf.bold(LNGS.STR_TXT_124),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   end if;

   if access_id = 'z'
    then
     htp.tabledata( htf.formtext('P1',20,40,c2rec.movement_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.movement_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' then htp.formhidden( 'P1', null ); end if;
   end if;

   htp.p( '<TD>' );
   if seclevel in ( 'LEVEL 8' )
    then
     htp.tabledata( '&nbsp;');
    else
     open c3( c2rec.ship_id );
     fetch c3 into c3rec;
     close c3;
     if parm = 'AIRWAY'
      then
       htp.anchor2( 'strangp.shp?surl=' || surl || '&rid=' || replace(rowidtochar(c3rec.rowid),'+','~') || '&parm=X' || parm || '&scid=' || scid || '&access_id=' || access_id,LNGS.STR_TXT_125,ctarget=>'NEWSHIP' );
      else
       htp.anchor2( 'strangp.shp?surl=' || surl || '&rid=' || replace(rowidtochar(c3rec.rowid),'+','~') || '&parm=X' || parm || '&scid=' || scid || '&access_id=' || access_id,LNGS.STR_TXT_126,ctarget=>'NEWSHIP' );
     end if;
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   if parm = 'CARGO'
    then
     htp.tabledata( htf.bold(LNGS.STR_TXT_063),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       if access_id = 'z'
        then
         htp.tabledata( htf.formtext('P2',20,20,c2rec.seal),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.bold(c2rec.seal),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
         htp.formhidden( 'P2', null );
       end if;
      else
       htp.tabledata( htf.bold(c2rec.seal),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
     htp.tabledata( '&nbsp;' );
   else
     htp.formhidden( 'P2', null );
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   if parm = 'CARGO'
    then
     htp.tabledata( htf.bold(LNGS.STR_TXT_126),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     if vaccess = 'EDIT' and nvl(c3rec.status,'INCOMPLETE') <> 'COMPLETE'
      then
       lov_ship( 'P3', 'S', c2rec.ship_id );
      else
       if vaccess = 'EDIT' then htp.formhidden( 'P3', c2rec.ship_id ); end if;
       lov_ship( 'P3', 'S', c2rec.ship_id, isedit=>FALSE );
     end if;
     htp.p( '</TD>' );
     if seclevel in ( 'LEVEL 1','LEVEL 6', 'LEVEL 8')
      then
       htp.tabledata( '&nbsp;');
      else
       htp.tabledata( htf.anchor2( 'strangp.edit_bol?surl=' || surl || '&rid=' || replace(rowidtochar(c3rec.rowid),'+','~') || '&rid2=' || replace(rowidtochar(rid),'+','~') || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&shpid=' || c2rec.ship_id,LNGS.STR_TXT_127,ctarget=>'NEWECN' ));
     end if;
   elsif parm = 'CONMOV'
    then
     htp.tabledata( htf.bold(LNGS.STR_TXT_126),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     if vaccess = 'EDIT' and nvl(c3rec.status,'INCOMPLETE') <> 'COMPLETE'
      then
       lov_ship( 'P3', 'S', c2rec.ship_id );
      else
       if vaccess = 'EDIT' then htp.formhidden( 'P3', c2rec.ship_id ); end if;
       lov_ship( 'P3', 'S', c2rec.ship_id, isedit=>FALSE );
     end if;
     htp.p( '</TD>' );
     if seclevel in ( 'LEVEL 1','LEVEL 6', 'LEVEL 8')
      then
       htp.tabledata( '&nbsp;');
      else
       htp.tabledata( htf.anchor2( 'strangp.edit_bol?surl=' || surl || '&rid=' || replace(rowidtochar(c3rec.rowid),'+','~') || '&rid2=' || replace(rowidtochar(rid),'+','~') || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&shpid=' || c2rec.ship_id,LNGS.STR_TXT_127,ctarget=>'NEWECN' ));
     end if;
   elsif parm = 'AIRWAY'
    then
     htp.tabledata( htf.bold(LNGS.STR_TXT_125),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     if vaccess = 'EDIT' and nvl(c3rec.status,'INCOMPLETE') <> 'COMPLETE'
      then
       lov_ship( 'P3', 'A', c2rec.ship_id );
      else
       if vaccess = 'EDIT' then htp.formhidden( 'P3', c2rec.ship_id ); end if;
       lov_ship( 'P3', 'A', c2rec.ship_id, isedit=>FALSE );
     end if;
     htp.p( '</TD>' );
     if seclevel in ( 'LEVEL 1','LEVEL 6', 'LEVEL 8')
      then
       htp.tabledata( '&nbsp;');
      else
       htp.tabledata( htf.anchor2( 'strangp.edit_mawb_ecn?surl=' || surl || '&rid=' || replace(rowidtochar(c3rec.rowid),'+','~') || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&mwb=' || c2rec.movement_no,LNGS.STR_TXT_128,ctarget=>'NEWECN' ));
     end if;
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_130),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
   if vaccess = 'EDIT'
    then
     htp.formselectopen( 'P4' );
     if c2rec.complete = 'F'
      then
       htp.formselectoption( 'INCOMPLETE', 'SELECTED', cattributes=>'VALUE="F"' );
      else
       htp.formselectoption( 'INCOMPLETE', cattributes=>'VALUE="F"' );
     end if;
     if c2rec.complete = 'P'
      then
       htp.formselectoption( 'PACKING COMPLETE', 'SELECTED', cattributes=>'VALUE="P"' );
      else
       htp.formselectoption( 'PACKING COMPLETE', cattributes=>'VALUE="P"' );
     end if;
     if c2rec.complete = 'A'
      then
       htp.formselectoption( 'ARRIVED AT PORT', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'ARRIVED AT PORT', cattributes=>'VALUE="A"' );
     end if;
     if c2rec.complete = 'D'
     then
       htp.formselectoption( 'DESPATCHED', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'DESPATCHED', cattributes=>'VALUE="D"' );
     end if;
     if c2rec.complete = 'W'
     then
       htp.formselectoption( 'AWAITING SHIPMENT', 'SELECTED', cattributes=>'VALUE="W"' );
      else
       htp.formselectoption( 'AWAITING SHIPMENT', cattributes=>'VALUE="W"' );
     end if;
     if c2rec.complete = 'S'
     then
       htp.formselectoption( 'SHIPPED', 'SELECTED', cattributes=>'VALUE="S"' );
      else
       htp.formselectoption( 'SHIPPED', cattributes=>'VALUE="S"' );
     end if;
   else
    if c2rec.complete = 'F' then htp.bold( LNGS.STR_TXT_131 ); elsif c2rec.complete = 'P' then htp.bold( LNGS.STR_TXT_132 ); elsif c2rec.complete = 'A' then htp.bold( LNGS.STR_TXT_133 ); else htp.bold( LNGS.STR_TXT_134 ); end if;
   end if;
   htp.p( '</TD>' );
   if seclevel in ( 'LEVEL 1','LEVEL 6', 'LEVEL 8')
    then
     htp.tabledata( '&nbsp;');
    else
     if parm in ('CARGO','CONMOV')
      then
       htp.tabledata( htf.anchor2( 'strangp.edit_ecn?surl=' || surl || '&rid=' || replace(rowidtochar(rid),'+','~') || '&rid2=' || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&shpid=' || c2rec.ship_id,LNGS.STR_TXT_128,ctarget=>'NEWECN' ));
      else
       htp.tabledata( htf.anchor2( 'strangp.edit_mawb?surl=' || surl || '&rid=' || translate(rid,'+ ','~+') || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&mwb=' || c2rec.movement_no,LNGS.STR_TXT_380,ctarget=>'HAWB'));
     end if;
  end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_135),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold(c2rec.invoiceno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT' then htp.tabledata( htf.anchor2( 'strangp.cascade_movement?surl=' || surl || '&rid=' || replace(rowidtochar(rid),'+','~') || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&oldid=' || c2rec.movement_no || '&oldseal=' || replace(c2rec.seal,' ','+') || '&mtype=' || parm,LNGS.STR_TXT_136 )); end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if parm = 'AIRWAY'
  then
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_129),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      if vaccess = 'EDIT' and nvl(c3rec.status,'INCOMPLETE') <> 'COMPLETE'
       then
        htp.tabledata( htf.formtext('PX1',15,15,c2rec.carrier),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        if vaccess = 'EDIT' then htp.formhidden( 'PX1', c2rec.carrier ); end if;
        htp.tabledata( c2rec.carrier,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
    htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_275),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      if vaccess = 'EDIT' and nvl(c3rec.status,'INCOMPLETE') <> 'COMPLETE'
       then
        htp.tabledata( htf.formtext('PX2',15,15,c2rec.flight),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        if vaccess = 'EDIT' then htp.formhidden( 'PX2', c2rec.flight ); end if;
        htp.tabledata( c2rec.carrier,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
    htp.tablerowclose;
     htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_232),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      if vaccess = 'EDIT' and nvl(c3rec.status,'INCOMPLETE') <> 'COMPLETE'
       then
         htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
         htp.formselectopen( 'PX3' );
         for c5rec in c5 loop
          if c5rec.chargecode = c2rec.chargecode
           then
            htp.formselectoption( c5rec.chargecode, 'SELECTED' );
           else
            htp.formselectoption( c5rec.chargecode );
          end if;
         end loop;
         htp.formselectclose;
         htp.p( '</TD>' );
       else
        if vaccess = 'EDIT' then htp.formhidden( 'PX3', c2rec.chargecode ); end if;
        htp.tabledata( c2rec.chargecode,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
 else
  htp.formhidden( 'PX1',null);
  htp.formhidden( 'PX2',null);
  htp.formhidden( 'PX3',null);
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  if parm = 'CARGO'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Cargo Type'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c2rec.complete = 'F'
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       if vaccess = 'EDIT'
        then
         lov_list( 'CTRTYPE', 'P5', nvl(c2rec.container_type,'GENERAL'), TRUE, FALSE, FALSE );
        else
         lov_list( 'CTRTYPE', 'P5', nvl(c2rec.container_type,'GENERAL'), TRUE, FALSE, FALSE, isedit=>FALSE );
       end if;
       htp.p( '</TD>' );
      else
       htp.tabledata( htf.bold( c2rec.container_type ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       if vaccess = 'EDIT' then htp.formhidden( 'P5', c2rec.container_type ); end if;
     end if;
    htp.tablerowclose;
  else
   htp.formhidden( 'P5', null );
  end if;

  if parm = 'CARGO'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('ISO Container Type'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c2rec.complete = 'F'
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       if vaccess = 'EDIT'
        then
         lov_list( 'UNCTNTAB', 'P5i', nvl(c2rec.iso_container_type,'22G1'), TRUE, FALSE, FALSE );
        else
         lov_list( 'UNCTNTAB', 'P5i', nvl(c2rec.iso_container_type,'22G1'), TRUE, FALSE, FALSE, isedit=>FALSE );
       end if;
       htp.p( '</TD>' );
      else
       htp.tabledata( htf.bold( c2rec.iso_container_type ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       if vaccess = 'EDIT' then htp.formhidden( 'P5i', c2rec.iso_container_type ); end if;
     end if;
    htp.tablerowclose;
  else
   htp.formhidden( 'P5i', null );
  end if;


  if parm = 'CARGO'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_138),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c2rec.complete = 'F' and vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext('P6',15,20,to_char(c2rec.tare)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(to_char(c2rec.tare)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'P6', to_char(c2rec.tare) );
     end if;
    htp.tablerowclose;
   else
    htp.formhidden( 'P6', null );
  end if;

  if parm in ('CARGO','CONMOV')
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_139),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c2rec.complete = 'F' and vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext('P7',15,20,to_char(c2rec.dispatch_date,LNGS.STR_DATE_02)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(to_char(c2rec.dispatch_date,LNGS.STR_DATE_02)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'P7', to_char(c2rec.dispatch_date,LNGS.STR_DATE_02) );
     end if;
    htp.tablerowclose;
   else
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_140),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c2rec.complete = 'F' and vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext('P7',15,20,to_char(c2rec.dispatch_date,LNGS.STR_DATE_02)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(to_char(c2rec.dispatch_date,LNGS.STR_DATE_02)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'P7', to_char(c2rec.dispatch_date,LNGS.STR_DATE_02));
     end if;
    htp.tablerowclose;
  end if;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_141),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if c2rec.complete = 'F' and vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'LOCATIONS', 'P8', c2rec.departure, FALSE, TRUE, FALSE );
     htp.p( '</TD>' );
    else
       htp.tabledata( htf.bold(c2rec.departure),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'P8', c2rec.departure );
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_142),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if c2rec.complete = 'F' and vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'LOCATIONS', 'P9', c2rec.arrival, FALSE, TRUE, FALSE );
     htp.p( '</TD>' );
    else
       htp.tabledata( htf.bold(c2rec.arrival),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'P9', c2rec.arrival );
   end if;
  htp.tablerowclose;

  if parm in ('CARGO','CONMOV')
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_143),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c2rec.complete = 'F' and vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext('P10',20,20,c2rec.bol),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(c2rec.bol),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'P10', c2rec.bol );
     end if;
    htp.tablerowclose;
   else
    htp.formhidden( 'P10', null );
  end if;

  if parm in ('CARGO','CONMOV')
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold('Booking Reference'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if c2rec.complete = 'F' and vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext('P10a',20,20,c2rec.booking_ref),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(c2rec.booking_ref),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'P10a', c2rec.booking_ref );
     end if;
    htp.tablerowclose;
   else
    htp.formhidden( 'P10a', null );
  end if;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_144),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if c2rec.complete = 'F' and vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P11',70,100,c2rec.move_description),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.move_description),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.formhidden( 'P11', c2rec.move_description );
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Physical Packing Completed By'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if c2rec.complete = 'F' and vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('PP',30,35,c2rec.physical_pack),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.physical_pack),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.formhidden( 'PP', c2rec.physical_pack );
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Computer Packing Completed By'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if c2rec.complete = 'F' and vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('CP',30,35,c2rec.computer_pack),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.computer_pack),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.formhidden( 'CP', c2rec.computer_pack );
   end if;
  htp.tablerowclose;


  if vaccess = 'EDIT'
  then
   if access_id = 'z'
    then
     if parm = 'CARGO'
      then
       htp.tablerowopen;
        htp.tabledata( htf.bold(LNGS.STR_TXT_145),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
        htp.tabledata( htf.formtext('P12',10,10,'1'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tablerowclose;
      else
       htp.formhidden( 'P12', '1' );
     end if;
   end if;
  end if;

  htp.tableclose;

  htp.nl;
  htp.anchor2( 'strangp.assign_det?surl=' || surl || '&FL=T&rid=' || translate(rid,'+ ','~+') || '&scid=' || scid || '&parm=' || parm || '&access_id=' || access_id, '[' || LNGS.STR_TXT_130 || ']',ctarget=>'ASSIGN');
  if c2rec.complete <> 'F' and c2rec.movement_type = 'AIRWAY'
   then
     if seclevel in ( 'LEVEL 1','LEVEL 6', 'LEVEL 8')
      then
       NULL;
      else
       htp.anchor( 'strangp.assign_hawb?surl=' || surl || '&rid=' || translate(rid,'+ ','~+') || '&scid=' || scid || '&parm=' || parm || '&access_id=' || access_id, '[' || LNGS.STR_TXT_392 || ']');
     end if;
  end if;
  htp.nl;
  htp.nl;
 htp.tableopen( cattributes=>'cellpadding=4 cellspacing=4 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_090),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold(to_char(c2rec.sumweight,LNGS.STR_FRMT_04)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
   htp.tabledata( htf.bold(LNGS.STR_TXT_091),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold(to_char(c2rec.sumvolume,LNGS.STR_FRMT_03)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
   htp.tabledata( htf.bold(LNGS.STR_TXT_147),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold(to_char(c2rec.revton,LNGS.STR_FRMT_03)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
   if parm = 'AIRWAY'
    then
     htp.tabledata( htf.bold(LNGS.STR_TXT_148),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold(to_char(c2rec.chargeweight,LNGS.STR_FRMT_04)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
   end if;
  htp.tablerowclose;
 htp.tableclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT'
  then
   if access_id = 'z'
    then
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_149 ),cattributes=>'VALIGN="TOP"');
    else
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_150 ),cattributes=>'VALIGN="TOP"');
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_149 ),cattributes=>'VALIGN="TOP"');
     if c2rec.complete not in ('S')
      then
         htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_463 ),cattributes=>'VALIGN="TOP"');
     end if;
     open c4( c2rec.movement_no );
     fetch c4 into c4rec;
     close c4;
     if c4rec.tot = 0
      then
       htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_151 ),cattributes=>'VALIGN="TOP"');
     end if;
   end if;
   htp.formclose;
 end if;
 search( surl, parm, rid, samerow=>TRUE );
 htp.tablerowclose;
 htp.tableclose;

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MOVEMENT',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end movement;

procedure accept_movement( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                           p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2 default 'F', p5 in varchar2, p5i in varchar2, p6 in varchar2, p7 in varchar2,
                           p8 in varchar2, p9 in varchar2, p10 in varchar2, p10a in varchar2, p11 in varchar2, p12 in varchar2 default '1',
                           px1 in varchar2, px2 in varchar2, px3 in varchar2, pp in varchar2, cp in varchar2)
as

 cursor c1( mvid varchar2, mtype varchar2) is select 'x' from strang.movements where movement_no = mvid;
 cursor c2( mvid varchar2, sl varchar2, mtype varchar2) is select 'x' from strang.movements where movement_no = mvid and movement_type = mtype and nvl(seal,'|') = nvl(sl,'|');
 cursor c4( rid rowid ) is select movement_no,seal,ship_id from strang.movements where rowid = rid;
 cursor c5( mvid varchar2 ) is select 'x' from strang.movements where movement_no = mvid and movement_type in ('CONMOV','AIRWAY');
 cursor c6( ctrtyp varchar2) is select l.description from strang.lov l where l.lov_name='CTRTYPE' and l.code = ctrtyp; -- 20140907

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE; -- 20140907
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 newrid		rowid;
 sts		varchar2(100);
 nmb1		integer;
 nmb2		integer;
 dt		date;
 mf		varchar2(100);
 vste		varchar2(10);
 p11x           varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_MOVEMENT' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);

 if action = LNGS.STR_TXT_149 and access_id <> 'z'
  then
   movement(surl,null,scid,null,parm,'z',LNGS.STR_TXT_149);
   return;
 end if;

 if action in (LNGS.STR_TXT_463) and access_id <> 'z' -- Insert New Movement as Copy
  then
   movement(surl,rid,scid,null,parm,'z',action);
   return;
 end if;

 begin dt := to_date(p7,LNGS.STR_DATE_02); exception when others then movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_152 || ':' || p7 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_02 ); return; end;
 begin nmb1 := to_number(p6); exception when others then movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_154 || ':' || p6 || ' ' || LNGS.STR_TXT_153 || ':' || '999,999' ); return; end;
 begin nmb2 := to_number(p12); exception when others then nmb2 := 1; end;

 if p1 is null and access_id = 'z'
  then
    movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_155 );
    return;
 end if;

 if p2 is null and access_id = 'z' and parm = 'CARGO'
  then
    movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_156 );
    return;
 end if;

 if action = LNGS.STR_TXT_151
  then
   delete from strang.movements where rowid = chartorowid( rid );
   movement( surl, newrid, scid, null, parm, 'z', LNGS.STR_TXT_157 );
   return;
 end if;


 if access_id = 'z'
  then
   -- Check for Uniqueness
   if parm = 'CARGO'
    then
     open c5(p1);
     fetch c5 into c5rec;
     if c5%FOUND
      then
       close c5;
       movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_159 );
       return;
     end if;
     close c5;
     open c2(p1,p2,parm);
     fetch c2 into c2rec;
     if c2%FOUND
      then
       close c2;
       movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_158 );
       return;
     end if;
     close c2;
    else
     open c1(p1,parm);
     fetch c1 into c1rec;
     if c1%FOUND
      then
       close c1;
       movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_159 );
       return;
     end if;
     close c1;
   end if;
   mf := control_code( 'OFFICE', vste );
    p11x := p11;      -- 20140907
   if parm = 'CARGO' -- 20140907
    then
     open c6(p5);
     fetch c6 into c6rec;
     if p11x is null
      then
       p11x := c6rec.description;
      else
       if c6rec.description is not null
        then
         p11x := c6rec.description || ' / '|| p11x;
       end if;
     end if;
    close c6;
   end if;
  insert into strang.movements(movement_type,movement_no,seal,ship_id,complete,container_type, iso_container_type,tare,dispatch_date,departure,arrival,bol,
                                booking_ref, move_description,manifest_created,controlling_office,carrier,flight,chargecode, physical_pack, computer_pack) values
    (parm,decode(parm,'AIRWAY',p1,replace(p1,' ','')),p2,p3,p4,p5,p5i,nmb1,dt,p8,p9,upper(p10),upper(p10a),
     p11x,mf,mf,px1,px2,px3,pp,cp)
    returning rowid into newrid;
  else
   -- This call is used to extract the Ship Id and compare
   open c4( replace(rid,'~','+') );
   fetch c4 into c4rec;
   close c4;
   mf := control_code( 'OFFICE', vste );
   update strang.movements
    set
     ship_id = p3,
     complete = p4,
     container_type = p5,
     iso_container_type = p5i,
     tare = nmb1,
     dispatch_date = dt,
     departure = p8,
     arrival = p9,
     bol = upper(p10),
     booking_ref = upper(p10a),
     move_description = p11,
     controlling_office = mf,
     carrier = px1,
     flight = px2,
     chargecode = px3,
     physical_pack = upper(pp),
     computer_pack = upper(cp)

  where
    rowid = chartorowid( replace(rid,'~','+') );
  newrid := replace(rid,'~','+');
  -- Reset the Line No and Entry No to NULL if the SHIP_ID Changes
  if c4rec.ship_id <> p3
   then
    update strang.detailrs
     set
      line_no = NULL,
      entry_no = NULL
    where
     movement_no = c4rec.movement_no and
     nvl(camov_seal,'x') = nvl(c4rec.seal,'x');
  end if;
 end if;

 commit;
 open c4( newrid );
 fetch c4 into c4rec;
 close c4;

 recalc_weight(c4rec.movement_no,null,c4rec.seal);

 if access_id = 'z'
  then
   if nmb2 > 1
    then
     mass_movement( surl, newrid, scid, null, parm, 'x', nmb2, LNGS.STR_TXT_160 );
    else
     movement( surl, newrid, scid, null, parm, 'x', LNGS.STR_TXT_160 );
   end if;
  else
   movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_161 );
 end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MOVEMENT',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_movement;

procedure mass_movement( surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, nmb in integer, msg in varchar2 default null )
as

 cursor c2(rid rowid) is select * from strang.movements where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;

 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.MOVEMENT' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'MOVEMENT', rid );
 open c2(chartorowid(replace(rid,'~','+')));
 fetch c2 into c2rec;
 close c2;
 glbx.main_title( surl, LNGS.STR_TXT_162,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR09',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 htp.formopen( 'strangp.accept_mass_movement' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'ACCESS_ID', access_id );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_062), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_063), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_138), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_163), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_164), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;

  htp.tablerowopen;
   htp.formhidden( 'P1', c2rec.movement_no );
   htp.formhidden( 'P2', c2rec.seal );
   htp.formhidden( 'P5', c2rec.tare );
   htp.tabledata( '1', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
   htp.tabledata( htf.bold( c2rec.movement_no ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( c2rec.seal ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( c2rec.tare ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.formtext( 'P3', 10, 20 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.formtext( 'P4', 10, 20 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
 for j in 1..(nmb-1) loop
  htp.tablerowopen;
   htp.tabledata( to_char(j+1), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
   htp.tabledata( htf.formtext( 'P1', 10, 40, c2rec.movement_no ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.formtext( 'P2', 10, 40, c2rec.seal ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.formtext( 'P5', 10, 20, c2rec.tare ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.formtext( 'P3', 10, 20 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.formtext( 'P4', 10, 20 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
 end loop;

 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNGS.STR_TXT_165 );
 htp.formclose;
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MASS_MOVEMENT',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end mass_movement;

procedure accept_mass_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY )
as

 cursor c1(mv varchar2, sl varchar2) is select 'x' cntr from strang.movements where nvl(movement_no,'|') = nvl(mv,'|') and nvl(seal,'|') = nvl(sl,'|');
 cursor c2(rid rowid) is select * from strang.movements where rowid = rid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nmb		number;
 dlr		number;
 tr		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_MASS_MOVEMENT' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  open c2(chartorowid(replace(rid,'~','+')));
  fetch c2 into c2rec;
  close c2;

  for j in p1.first..p1.last loop
   begin nmb := to_number(p4(j)); exception when others then nmb := null; end;
   begin dlr := to_number(p3(j)); exception when others then dlr := null; end;
   begin tr := to_number(p5(j)); exception when others then tr := null; end;

   if j = 1
    then
     if dlr is not null
      then
       update strang.detailrs
        set
         movement_no = p1(j),
         camov_seal = p2(j)
        where deliveryno = dlr and
              itemno = nmb and
              cl = 'C' and
              sa = 'S' and
              movement_no is null and
              camov_seal is null;
       recalc_weight(p1(j),c2rec.container_type,p2(j),c2rec.movement_type);
     end if;

    else

     if p1(j) is not null
      then
       open c1(p1(j),p2(j));
       fetch c1 into c1rec;
       if c1%NOTFOUND
        then
         close c1;
         insert into strang.movements(invoiceno,movement_no,bol,movement_type,seal,container_type,move_description,
          complete,departure,arrival,dispatch_date,sumvolume,sumweight,revton,
          chargeweight,ship_id,manifest_created,controlling_office,tare) values
         (c2rec.invoiceno,p1(j),c2rec.bol,c2rec.movement_type,p2(j),c2rec.container_type,c2rec.move_description,
          c2rec.complete,c2rec.departure,c2rec.arrival,c2rec.dispatch_date,c2rec.sumvolume,c2rec.sumweight,c2rec.revton,
          c2rec.chargeweight,c2rec.ship_id,c2rec.manifest_created,c2rec.controlling_office,tr);
        else
         close c1;
       end if;
     end if;
     if dlr is not null
      then
       update strang.detailrs
        set
         movement_no = p1(j),
         camov_seal = p2(j)
        where deliveryno = dlr and
              itemno = nmb and
              cl = 'C' and
              sa = 'S' and
              movement_no is null and
              camov_seal is null;
       recalc_weight(p1(j),c2rec.container_type,p2(j),c2rec.movement_type);
     end if;
   end if;
  end loop;
  commit;
  movement( surl, rid, scid, null, parm, 'x', LNGS.STR_TXT_166 );
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MASS_MOVEMENT',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_mass_movement;

function control_code( cd in varchar2, vste in varchar2 )
 return varchar2
as

 cursor c1( cd varchar2, vste varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = vste;

 c1rec	c1%ROWTYPE;

begin
 open c1( cd, vste );
 fetch c1 into c1rec;
 close c1;
 return( c1rec.description );
exception
 when others
  then return( NULL );
end control_code;

procedure shp(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null )
as

 cursor c2(rid rowid) is select * from strang.ships_airway where rowid = rid;
 cursor c3(cname varchar2) is select customer_id from strang.customers where customer = cname and customer_type = 'AGENT';
 cursor c4(shid integer) is select count('x') tot from strang.movements where ship_id = shid;
 cursor c5(vshipid integer) is
  select 'x'
  from strang.movements m, strang.detailrs d
  where d.movement_no = m.movement_no and
        nvl(m.seal,'|') = nvl(d.camov_seal,'|') and
        d.entry_no is not null and
        m.ship_id = vshipid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
-- vaccess2	varchar2(20); 20140529
 mf		varchar2(100);
 vste		varchar2(10);
 seclevel	varchar2(100);
 found_entry    boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.SHP' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'SHP', rid );
-- vaccess2 := data_access( owner_id, 'SHP2', rid ); 20140529
 mf := control_code( 'OFFICE', vste );
 seclevel := oltp.security_role( owner_id );
 glbx.main_title( surl, LNGS.STR_TXT_167,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR10',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if access_id = 'z'
  then
   -- Populate with Default Values
   begin c2rec.insurance   := control_code( 'CUSTOMS_INSURANCE', vste ); exception when others then null; end;
   begin c2rec.vat         := control_code( 'CUSTOMS_VAT', vste ); exception when others then null; end;
   begin c2rec.other_costs := control_code( 'CUSTOMS_OTHER_COSTS', vste ); exception when others then null; end;
   begin c2rec.freight     := control_code( 'CUSTOMS_FREIGHT', vste ); exception when others then null; end;
   begin c2rec.licence_no  := control_code( 'CUSTOMS_LICENCE_NO', vste ); exception when others then null; end;
   begin c2rec.p2acode     := control_code( 'CUSTOMS_P2ACODE', vste ); exception when others then null; end;
   begin c2rec.cpc         := control_code( 'CUSTOMS_CPC', vste ); exception when others then null; end;
   begin c2rec.rate        := control_code( 'CUSTOMS_RATE', vste ); exception when others then null; end;
   open c3( control_code( 'AGENTNAME', vste ));
   fetch c3 into c3rec;
   close c3;
   begin c2rec.customs_agent  := c3rec.customer_id; exception when others then null; end;
   c2rec.status := 'INCOMPLETE';
  else
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
   if (mf is not null) and (vaccess = 'EDIT') and (c2rec.status = 'INCOMPLETE')
    then
     -- Check if the Controlling Office. If not then Read Only Access
     if (mf <> nvl(c2rec.controlling_office,mf)) -- and (vaccess2 = 'NONE') 20140529
      then
       vaccess := 'READ';
     end if;
   end if;
 end if;
 c2rec.status := nvl(c2rec.status,'INCOMPLETE');

 c2rec.sad_cuo_code := nvl(c2rec.sad_cuo_code,'UNG');
 c2rec.sad_cuo_bord := nvl(c2rec.sad_cuo_bord,'UNG');
 c2rec.sad_054_lop_cod := nvl(c2rec.sad_054_lop_cod,'PGUNG');
 c2rec.sad_057_loc_goods := nvl(c2rec.sad_057_loc_goods,'UNG1');


 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<TD align="LEFT">' );
 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_shp' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
 end if;

 if access_id = 'z'
  then
   htp.formhidden( 'RID', null );
  else
   htp.formhidden( 'RID', replace(rid,'~','+') );
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  if (mf <> c2rec.controlling_office) and (mf is not null) and (c2rec.status = 'INCOMPLETE')
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_309),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold(c2rec.controlling_office),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_168),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE' and seclevel not in ('LEVEL 8')
      then
       if c2rec.ship_airway = 'A'
        then
         htp.tabledata( htf.formselectopen( 'P1' ) || htf.formselectoption( LNGS.STR_TXT_169, cattributes=>'VALUE="S"') || htf.formselectoption( LNGS.STR_TXT_050,'SELECTED', cattributes=>'VALUE="A"') || htf.formselectclose  || ' ' || htf.italic(c2rec.ship_id) ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formselectopen( 'P1' ) || htf.formselectoption( LNGS.STR_TXT_169,'SELECTED', cattributes=>'VALUE="S"') || htf.formselectoption( LNGS.STR_TXT_050, cattributes=>'VALUE="A"') || htf.formselectclose  || ' ' || htf.italic(c2rec.ship_id),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold( c2rec.ship_airway ) || ' - ' || htf.italic(c2rec.ship_id),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       if seclevel in ('LEVEL 8') then
         htp.formhidden('P1',C2REC.ship_airway);
       end if ;
     end if;

  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_170),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE' and seclevel not in ('LEVEL 8')
      then
       htp.tabledata( htf.formtext('P2',30,30,c2rec.shipname),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(c2rec.shipname),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       if seclevel in ('LEVEL 8') then
         htp.formhidden('P2',C2REC.shipname);
       end if ;
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_171),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'  and seclevel not in ('LEVEL 8')
      then
       htp.tabledata( htf.formtext('P3',10,10,c2rec.voy),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(c2rec.voy),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       if seclevel in ('LEVEL 8') then
         htp.formhidden('P3',C2REC.voy);
       end if ;
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('OTML Ship Number'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'  and seclevel not in ('LEVEL 8')
      then
       htp.tabledata( htf.formtext('P3i',10,10,c2rec.sap_ship_id),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(c2rec.sap_ship_id),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       if seclevel in ('LEVEL 8') then
         htp.formhidden('P3i',C2REC.sap_ship_id);
       end if ;
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_172),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     if vaccess = 'EDIT'
      then
       htp.formselectopen( 'P1A' );
       if c2rec.status = 'INCOMPLETE'
        then
         htp.formselectoption( 'INCOMPLETE', 'SELECTED' );
        else
         htp.formselectoption( 'INCOMPLETE' );
       end if;
       if c2rec.status = 'COMPLETE'
        then
         htp.formselectoption( 'COMPLETE', 'SELECTED' );
        else
         htp.formselectoption( 'COMPLETE' );
       end if;
       if c2rec.status = 'FINAL'
        then
         htp.formselectoption( 'FINAL', 'SELECTED' );
        else
         htp.formselectoption( 'FINAL' );
       end if;
       if c2rec.status = 'CUSTOMS COMPLETE'
        then
         htp.formselectoption( 'CUSTOMS COMPLETE', 'SELECTED' );
        else
         htp.formselectoption( 'CUSTOMS COMPLETE' );
       end if;
       htp.formselectclose;

      else
       htp.bold( c2rec.status );
     end if;
     htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') = 'CUSTOMS COMPLETE'
  then
   htp.nl;
   htp.anchor( 'javascript: window.open(''' || 'p_sads_by_ship?surl=' || surl || '&shipid=' || c2rec.ship_id  || ''',''' || 'Generate SAD' || ''',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');', '[Generate SAD]' );
   htp.nl;
 end if;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_173),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
      then
       htp.tabledata( htf.formtext('P4',30,30, to_char(c2rec.estdepart,LNGS.STR_DATE_01)) || ' ' || htf.italic(LNGS.STR_DATE_01),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(to_char(c2rec.estdepart,LNGS.STR_DATE_01)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_174),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
    then
     lov_list( 'LOCATIONS', 'P5', c2rec.portload, FALSE, TRUE, FALSE );
    else
     lov_list( 'LOCATIONS', 'P5', c2rec.portload, FALSE, TRUE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_175),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
      then
       htp.tabledata( htf.formtext('P6',30,30, to_char(c2rec.estarrive,LNGS.STR_DATE_01)) || ' ' || htf.italic(LNGS.STR_DATE_01),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold(to_char(c2rec.estarrive,LNGS.STR_DATE_01)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_176),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
    then
     lov_list( 'LOCATIONS', 'P7', c2rec.portdisc, FALSE, TRUE, FALSE );
    else
     lov_list( 'LOCATIONS', 'P7', c2rec.portdisc, FALSE, TRUE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_177),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.formhidden( 'P8', c2rec.customer_id );
       customer_list( 'AGENT', 'P8', c2rec.customer_id, FALSE, isedit=>FALSE );
      else
       customer_list( 'AGENT', 'P8', c2rec.customer_id, FALSE );
     end if;
    else
     customer_list( 'AGENT', 'P8', c2rec.customer_id, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_178),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.formhidden( 'P9', c2rec.shipcountry );
       lov_list( 'COUNTRIES', 'P9', c2rec.shipcountry, FALSE, TRUE, FALSE, isedit=>FALSE );
      else
       lov_list( 'COUNTRIES', 'P9', c2rec.shipcountry, FALSE, TRUE, FALSE );
     end if;
    else
     lov_list( 'COUNTRIES', 'P9', c2rec.shipcountry, FALSE, TRUE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_179),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
      then
       if seclevel in ( 'LEVEL 8' )
        then
         htp.tabledata( htf.formhidden( 'P10', c2rec.shipmaster ) || htf.bold(c2rec.shipmaster),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext('P10',25,25, c2rec.shipmaster),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold(c2rec.shipmaster),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_397),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
    then
     if seclevel in ( 'LEVEL 8' )
      then
       htp.formhidden( 'P9M', c2rec.nationality_master );
       lov_list( 'COUNTRIES', 'P9M', c2rec.nationality_master, FALSE, TRUE, FALSE, isedit=>FALSE );
      else
       lov_list( 'COUNTRIES', 'P9M', c2rec.nationality_master, FALSE, TRUE, FALSE );
     end if;
    else
     lov_list( 'COUNTRIES', 'P9M', c2rec.nationality_master, FALSE, TRUE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_090),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
      then
       if seclevel in ( 'LEVEL 8' )
        then
         htp.tabledata( htf.formhidden( 'P11', c2rec.shipweight ) || htf.bold(to_number(c2rec.shipweight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext('P11',10,20, to_number(c2rec.shipweight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold(to_number(c2rec.shipweight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_180),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
      then
       if seclevel in ( 'LEVEL 8' )
        then
         htp.tabledata( htf.formhidden( 'P12', c2rec.austcrew ) || htf.bold(to_number(c2rec.austcrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext('P12',5,20, to_number(c2rec.austcrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold(to_number(c2rec.austcrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_181),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
      then
       if seclevel in ( 'LEVEL 8' )
        then
         htp.tabledata( htf.formhidden( 'P13', c2rec.pngcrew ) || htf.bold(to_number(c2rec.pngcrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext('P13',5,20, to_number(c2rec.pngcrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold(to_number(c2rec.pngcrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_182),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
      then
       if seclevel in ( 'LEVEL 8' )
        then
         htp.tabledata( htf.formhidden( 'P14', c2rec.frncrew ) || htf.bold( to_number(c2rec.frncrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext('P14',5,20, to_number(c2rec.frncrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold( to_number(c2rec.frncrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_183),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
    then
     lov_list( 'LOCATIONS', 'P15', c2rec.finaldest, FALSE, TRUE, FALSE );
    else
     lov_list( 'LOCATIONS', 'P15', c2rec.finaldest, FALSE, TRUE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Manifest Reg.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and nvl(c2rec.manifest_reg,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
      then
       if seclevel in ( 'LEVEL 8' )
        then
         htp.tabledata( htf.formhidden( 'P16', c2rec.manifest_reg ) || htf.bold( to_number(c2rec.frncrew)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext('P16',20,28, to_char(c2rec.manifest_reg)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold( to_char(c2rec.manifest_reg)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold('Customs Clearance Office'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       if seclevel in ( 'LEVEL 5','LEVEL 7','LEVEL 8' )
        then
         htp.tabledata( htf.formtext('PC1',5,20, c2rec.sad_cuo_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formhidden( 'PC1', c2rec.sad_cuo_code ) || htf.bold( c2rec.sad_cuo_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold( c2rec.sad_cuo_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Border Customs Office'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       if seclevel in ( 'LEVEL 5','LEVEL 7','LEVEL 8' )
        then
         htp.tabledata( htf.formtext('PC2',5,20, c2rec.sad_cuo_bord),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formhidden( 'PC2', c2rec.sad_cuo_bord ) || htf.bold( c2rec.sad_cuo_bord),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold( c2rec.sad_cuo_bord),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Place of Unloading'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       if seclevel in ( 'LEVEL 5','LEVEL 7','LEVEL 8' )
        then
         htp.tabledata( htf.formtext('PC3',5,20, c2rec.sad_054_lop_cod),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formhidden( 'PC3', c2rec.sad_054_lop_cod ) || htf.bold( c2rec.sad_054_lop_cod),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold( c2rec.sad_054_lop_cod),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Location of Goods'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       if seclevel in ( 'LEVEL 5','LEVEL 7','LEVEL 8' )
        then
         htp.tabledata( htf.formtext('PC4',5,20, c2rec.sad_057_loc_goods),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formhidden( 'PC4', c2rec.sad_057_loc_goods ) || htf.bold( c2rec.sad_057_loc_goods),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold( c2rec.sad_057_loc_goods),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;

 if vaccess = 'EDIT' and nvl(c2rec.status,'INCOMPLETE') in ('CUSTOMS COMPLETE')
  then
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
   htp.formhidden( 'P3', null );
   htp.formhidden( 'P4', null );
   htp.formhidden( 'P5', null );
   htp.formhidden( 'P6', null );
   htp.formhidden( 'P7', null );
   htp.formhidden( 'P8', null );
   htp.formhidden( 'P9', null );
   htp.formhidden( 'P9M', null );
   htp.formhidden( 'P10', null );
   htp.formhidden( 'P11', null );
   htp.formhidden( 'P12', null );
   htp.formhidden( 'P13', null );
   htp.formhidden( 'P14', null );
   htp.formhidden( 'P15', null );
   htp.formhidden( 'PC1', null );
   htp.formhidden( 'PC2', null );
   htp.formhidden( 'PC3', null );
   htp.formhidden( 'PC4', null );
 end if;

 if vaccess = 'EDIT'
  then
   if access_id = 'z'
    then
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_184 );
    else
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_185 );
     if seclevel not in ('LEVEL 8') then
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_186 );
     end if;
     open c4(c2rec.ship_id);
     fetch c4 into c4rec;
     close c4;
     if c4rec.tot = 0 and seclevel not in ('LEVEL 8')
      then
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_187 );
     end if;
   end if;
   htp.formclose;
 end if;
   htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
    htp.tablerowopen;
    if c2rec.ship_airway = 'S' and nvl(c2rec.status,'INCOMPLETE') not in ('FINAL','CUSTOMS COMPLETE')
     then
      htp.p( '<TD>' );
       htp.formopen( 'strangp.edit_bol', ctarget=>'NEWECN' );
       htp.formhidden( 'SURL', surl );
       htp.formhidden( 'RID', replace(rid,'~','+') );
       htp.formhidden( 'PARM', parm );
       htp.formhidden( 'SCID', scid );
       htp.formhidden( 'ACCESS_ID', access_id );
       htp.formhidden( 'SHPID', c2rec.ship_id );
       htp.formsubmit( null, LNGS.STR_TXT_127 );
       htp.formclose;
      htp.p( '</TD>' );
   end if;
  search( surl, 'SHIP_AIRWAY', rid, samerow=>TRUE );
  htp.tablerowclose;
     if seclevel in ('LEVEL 5','LEVEL 7','LEVEL 8')
      then
--htp.formsubmit( 'ACTION', LNGS.STR_TXT_188 );

 if nvl(c2rec.status,'INCOMPLETE') in ('FINAL') and seclevel in ('LEVEL 5','LEVEL 7')
  then
    open c5( c2rec.ship_id );
    fetch c5 into c5rec;
    if c5%FOUND
     then
      found_entry := TRUE;
     else
      found_entry := FALSE;
    end if;
    close c5;
    htp.tablerowopen;
    htp.p( '<TD>' );
    -- Allocate
    if not found_entry
     then
--      htp.anchor( 'strangp.confirm_genduty?surl=' || surl || '&rid=' || replace(rid,'+','~') || '&scid=' || scid || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id || '&msg=DUTY' , '[' || LNGS.STR_TXT_311 || ']' );
      htp.formsubmit( cvalue =>'Allocate Entry Nos', cattributes => 'onclick="window.location=''strangp.confirm_genduty?surl=' || surl || '&rid=' || replace(rid,'+','~') || '&scid=' || scid || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id || '&msg=DUTY'''|| '"' );
    end if;

    -- UnAllocate
    if found_entry
     then
--      htp.anchor( 'strangp.confirm_genduty?surl=' || surl || '&rid=' || replace(rid,'+','~') || '&scid=' || scid || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id || '&msg=UNALLOCATE' , '[' || LNGS.STR_TXT_314 || ']' );
      htp.formsubmit( cvalue =>'Unallocate Entry Nos', cattributes => 'onclick="window.location=''strangp.confirm_genduty?surl=' || surl || '&rid=' || replace(rid,'+','~') || '&scid=' || scid || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id || '&msg=UNALLOCATE'''|| '"' );

    end if;
    htp.p( '</TD>' );
    htp.tablerowclose;
   end if;
  end if;
 htp.tableclose;
 htp.nl;
 /*
 if nvl(c2rec.status,'INCOMPLETE') <> 'INCOMPLETE'
  then
   htp.anchor( 'strangp.genduty?surl=' || surl || '&rid=' || rid || '&scid=' || scid || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id || '&msg=LINE_NO' , LNGS.STR_TXT_313 );
   htp.nl;
   display_report( surl, owner_id, 'REPORT B','Ship Manifests',c2rec.shipname,c2rec.ship_id);
 end if;
 display_report( surl, owner_id, 'REPORT B','Bill of Lading for Combined Transport',c2rec.shipname,c2rec.ship_id);
 display_report( surl, owner_id, 'REPORT B','Drawback',c2rec.shipname,c2rec.ship_id);
 display_report( surl, owner_id, 'REPORT B','Repair and Return',c2rec.shipname,c2rec.ship_id);
 display_report( surl, owner_id, 'REPORT B','PartShipment',c2rec.shipname,c2rec.ship_id);
 display_report( surl, owner_id, 'REPORT B','ECN Report',c2rec.shipname,c2rec.ship_id);
 */
 if substr(parm,1,1) = 'X'
  then
   htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 end if;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'SHP',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end shp;

procedure generate_containers( shpid in integer )
as

 cursor c1(shpid integer) is
  select movement_no, bol, container_type
  from strang.movements
  where ship_id = shpid;

 cursor c2(shpid integer) is select * from strang.ships_airway where ship_id = shpid;

 cursor c3(mv varchar2) is select * from strang.tracking_header where containerno = mv;

 cursor c4(sno integer, sname varchar2, vy varchar2) is select * from strang.tracking_details where id = sno and ship = sname and voyage = vy;

 cursor c5(sno integer) is select nvl(max(rno),0) + 1 mx from strang.tracking_details where id = sno;

 cursor c6(v_cntr varchar2) is select * from strang.containers where upper(trim(containerno)) = upper(trim(v_cntr));

 c2rec	 c2%ROWTYPE;
 c3rec   c3%ROWTYPE;
 c4rec   c4%ROWTYPE;
 c6rec   c6%ROWTYPE;
 sno	 integer;
 calcrno integer;

begin

 open c2(shpid);
 fetch c2 into c2rec;
 close c2;
 for c1rec in c1(shpid) loop
  c6rec.cat_company := null;
  open c6(c3rec.containerno);
  fetch c6 into c6rec;
  close c6;
  open c3( c1rec.movement_no );
  fetch c3 into c3rec;
  if c3%FOUND
   then
    -- check if ship and voyage already inserted
    open c4(c3rec.id, c2rec.shipname, c2rec.voy);
    fetch c4 into c4rec;
    if c4%FOUND
     then
      update strang.tracking_details
       set
        departure_location = c2rec.portload,
        etd_date = c2rec.estdepart,
        arrival_location = nvl(c2rec.finaldest,c2rec.portdisc),
        eta_date = c2rec.estarrive,
        current_location = nvl(c2rec.finaldest,c2rec.portdisc),
        date_at_current_loc = c2rec.estarrive
      where
       id = c3rec.id and
       rno = c4rec.rno;
     else
      open c5(c3rec.id);
      fetch c5 into calcrno;
      close c5;
      insert into strang.tracking_details(id,rno,remark,movement_type,departure_location,etd_date,arrival_location,eta_date,ship,voyage,current_location,date_at_current_loc)
       values(c3rec.id,calcrno,'Bill of lading: ' || c1rec.bol,'NORTHBOUND SHIP',c2rec.portload,c2rec.estdepart,nvl(c2rec.finaldest,c2rec.portdisc),c2rec.estarrive,c2rec.shipname,c2rec.voy,nvl(c2rec.finaldest,c2rec.portdisc),c2rec.estarrive);
    end if;
    close c4;
    if c3rec.cat_code is null or c3rec.cat_company is null
     then
      c3rec.cat_code := nvl(c3rec.cat_code, c1rec.container_type);
      c3rec.cat_company := nvl(c3rec.cat_company, c6rec.cat_company);
      update strang.tracking_header
      set    cat_code = c3rec.cat_code
        ,    cat_company = c3rec.cat_company
      where  id = c3rec.id;
    end if;

   else

    -- insert new
    select strang.s_tracking_header.nextval into sno from dual;
    insert into strang.tracking_header(id,containerno,cat_code,cat_company) values
     (sno,c1rec.movement_no,c1rec.container_type,c6rec.cat_company);
    insert into strang.tracking_details(id,rno,remark,movement_type,departure_location,etd_date,arrival_location,eta_date,ship,voyage,current_location,date_at_current_loc)
     values(sno,1,'Bill of lading: ' || c1rec.bol,'SHIP',c2rec.portload,c2rec.estdepart,nvl(c2rec.finaldest,c2rec.portdisc),c2rec.estarrive,c2rec.shipname,c2rec.voy,nvl(c2rec.finaldest,c2rec.portdisc),c2rec.estarrive);

  end if;
  close c3;
 end loop;
 commit;
end generate_containers;

procedure accept_shp( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                      p1 in varchar2, p1a in varchar2, p2 in varchar2, p3 in varchar2, p3i in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2,
                      p8 in varchar2, p9 in varchar2, p9m in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, p13 in varchar2, p14 in varchar2, p15 in varchar2, p16 in varchar2,
                      pc1 in varchar2, pc2 in varchar2, pc3 in varchar2, pc4 in varchar2 )
as

 cursor c1(sto varchar2) is select max(ship_id) ship_id from strang.ships_airway;
 cursor c2(rid rowid) is select status,ship_id,shipname,voy from strang.ships_airway where rowid = rid;
 cursor c10(v_shipname varchar2, v_voy varchar2) is select rowid from strang.ships_airway where upper(shipname) = upper(v_shipname) and upper(voy) = upper(v_voy);
 cursor c11(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'DELIVERYNO' and cola = vste;


 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec 	c11%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 newrid		rowid;
 sts		varchar2(100);
 nmb1		number;
 nmb2		integer;
 nmb3		integer;
 nmb4		integer;
 dt1		date;
 dt2		date;
 mf		varchar2(100);
 vste		varchar2(10);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_SHP' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 cusrec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(cusrec.aid);
 if action = LNGS.STR_TXT_186
  then
   shp(surl,null,scid,parm,'z',LNGS.STR_TXT_186 );
   return;
 end if;

 if action = LNGS.STR_TXT_187
  then
   delete from strang.ships_airway where rowid = chartorowid( replace(rid,'~','+') );
   shp(surl,null,scid,parm,'z',LNGS.STR_TXT_189 );
   return;
 end if;

 begin dt1 := to_date(p4,LNGS.STR_DATE_01); exception when others then shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_152 || ':' || p4 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_01 ); return; end;
 begin dt2 := to_date(p6,LNGS.STR_DATE_01); exception when others then shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_152 || ':' || p6 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_01 ); return; end;
 if (dt1 is not null) and (dt2 is not null) and (dt2 < dt1 )
  then
   shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_190 );
   return;
 end if;
 begin nmb1 := to_number(p11); exception when others then shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_191 || ':' || p11 || ' ' || LNGS.STR_TXT_195 ); return; end;
 begin nmb2 := to_number(p12); exception when others then shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_192 || ':' || p12 || ' ' || LNGS.STR_TXT_195 ); return; end;
 begin nmb3 := to_number(p13); exception when others then shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_193 || ':' || p13 || ' ' || LNGS.STR_TXT_195 ); return; end;
 begin nmb4 := to_number(p14); exception when others then shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_194 || ':' || p14 || ' ' || LNGS.STR_TXT_195 ); return; end;

 if p2 is null and access_id = 'z'
  then
    shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_196 );
    return;
 end if;

 if p3 is null and access_id = 'z'
  then
    shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_197 );
    return;
 end if;

 if access_id = 'z'
  then
   open c10(p2,p3);
   fetch c10 into c10rec;
   if c10%FOUND
    then
     close c10;
     shp( surl, c10rec.rowid, scid, parm, 'x', LNGS.STR_TXT_406 );
     return;
   end if;
   close c10;
   open c11(vste);
   fetch c11 into c11rec;
   close c11;
   open c1(currsite);
   fetch c1 into c1rec;
   close c1;
   if c1rec.ship_id is null then c1rec.ship_id := c11rec.description; end if;
   c1rec.ship_id := nvl(c1rec.ship_id,0) + 1;
   mf := control_code( 'OFFICE', vste );
   insert into strang.ships_airway(ship_airway,ship_id,shipname,voy,sap_ship_id, shipmaster,estdepart,estarrive,portload,portdisc,shipcountry,shipweight,austcrew,pngcrew,
                                   frncrew,finaldest,customer_id,status,manifest_created,controlling_office,nationality_master, manifest_reg,
                                   sad_cuo_code, sad_cuo_bord, sad_054_lop_cod, sad_057_loc_goods) values
    (p1,c1rec.ship_id,p2,p3,p3i,p10,dt1,dt2,p5,p7,p9,nmb1,nmb2,nmb3,nmb4,p15,p8,nvl(p1a,'INCOMPLETE'),mf,mf,p9m, p16, pc1, pc2, pc3, pc4)
    returning rowid into newrid;

  else
   open c2(chartorowid( replace(rid,'~','+') ));
   fetch c2 into c2rec;
   close c2;
   if (c2rec.shipname <> p2) or (c2rec.voy <> p3 )
    then
     -- Shipname or Voyage changed, check for uniqueness
     open c10(p2,p3);
     fetch c10 into c10rec;
     if c10%FOUND
      then
       close c10;
       shp( surl, rid, scid, parm, 'x', LNGS.STR_TXT_406 );
       return;
     end if;
     close c10;
   end if;
   if nvl(c2rec.status,'INCOMPLETE') <> 'CUSTOMS COMPLETE'
    then
    update strang.ships_airway
     set
      ship_airway = p1,
      shipname = p2,
      voy = p3,
      sap_ship_id = p3i,
      shipmaster = p10,
      estdepart = dt1,
      estarrive = dt2,
      portload = p5,
      portdisc = p7,
      shipcountry = p9,
      nationality_master = p9m,
      shipweight = nmb1,
      austcrew = nmb2,
      pngcrew = nmb3,
      frncrew = nmb4,
      finaldest = p15,
      customer_id = p8,
      status = nvl(p1a,'INCOMPLETE'),
      controlling_office = mf,
      manifest_reg = p16,
      sad_cuo_code = pc1,
      sad_cuo_bord = pc2,
      sad_054_lop_cod = pc3,
      sad_057_loc_goods = pc4
    where
     rowid = chartorowid( replace(rid,'~','+') );
   else
    update strang.ships_airway
     set
      status = nvl(p1a,'INCOMPLETE')
    where
     rowid = chartorowid( replace(rid,'~','+') );
   end if;
   -- If the Ship is Marked as COMPLETE then update all Movements to S which stands for SHIPPED
   if nvl(p1a,'INCOMPLETE') in ('COMPLETE','FINAL','CUSTOMS COMPLETE')
    then
     update strang.movements
      set
       complete = 'S'
     where
      ship_id = c2rec.ship_id;
    end if;
   if nvl(p1a,'INCOMPLETE') = 'INCOMPLETE'
    then
     update strang.movements
      set
       complete = 'W'
     where
      ship_id = c2rec.ship_id and
      complete = 'S';
    end if;
    if nvl(p1a,'INCOMPLETE') in ('FINAL') and nvl(c2rec.status,'INCOMPLETE') not in ('FINAL')
     then
      generate_ost256( surl, c2rec.ship_id );
      generate_ost156( surl, c2rec.ship_id );
      generate_ost157( surl, c2rec.ship_id );
      generate_ccdets( surl, c2rec.ship_id );
      generate_ccpo( surl, c2rec.ship_id );
      -- populate tracking_header and tracking_details
      generate_containers( c2rec.ship_id );
    end if;
    if nvl(c2rec.status,'INCOMPLETE') in ('FINAL') and nvl(p1a,'INCOMPLETE') not in ('FINAL')
     then
      delete from strang.tracking_details where upper(ship) = upper(c2rec.shipname) and upper(voyage) = upper(c2rec.voy);
    end if;
 end if;

 commit;
 /* 20140529
 if action = LNGS.STR_TXT_188
  then
   if access_id = 'z'
    then
     shp2( surl, newrid, scid, parm, 'x', LNGS.STR_TXT_160 );
    else
     shp2( surl, rid, scid, parm, access_id, LNGS.STR_TXT_161 );
   end if;
   return;
 end if;
 */
 if access_id = 'z'
  then
   shp( surl, newrid, scid, parm, 'x', LNGS.STR_TXT_160 );
  else
   shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_161 );
 end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_SHP',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_shp;

/* 20140529 removed procedure shp2 & procedure accept_shp2 */

procedure entry_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ENTRY_MAINTAIN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'ENTRY_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Choose Entry Number',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Entry Maintain') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 htp.formopen( 'strangp.entry_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'PK1', NULL );
 htp.formhidden( 'PK2', NULL );
 htp.formhidden( 'PK3', NULL );
 htp.formhidden( 'V1', NULL );
 htp.formhidden( 'V1i', NULL );
 htp.formhidden( 'V8i', NULL );
 htp.formhidden( 'V8ii', NULL );
 htp.formhidden( 'V2', NULL );
 htp.formhidden( 'V3', NULL );
 htp.formhidden( 'V4', NULL );
 htp.formhidden( 'V5', NULL );
 htp.formhidden( 'V6', NULL );
 htp.formhidden( 'V7', NULL );
 htp.formhidden( 'V8', NULL );
 htp.formhidden( 'ERRMSG', NULL );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  if strt is NULL
   then
    htp.tablerowopen;
       htp.tabledata( htf.bold('Entry From'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
       htp.tabledata( htf.formtext('P1',20,30),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
       htp.tabledata( htf.bold('Entry To'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
       htp.tabledata( htf.formtext('P2',20,30),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
  else
    htp.tablerowopen;
       htp.tabledata( htf.bold('Entry From'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
       htp.tabledata( htf.formtext('P1',20,30, strang.ent.get_entry_no(strt)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
       htp.tabledata( htf.bold('Entry To'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
       htp.tabledata( htf.formtext('P2',20,30, strang.ent.get_entry_no(nvl(strt2, strt))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Submit' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'ENTRY_MAINTAIN',null,owner_id,errmsg=>sqlerrm,extdet=>'Strt:' || strt);
end entry_maintain;

procedure entry_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null )
as

 cursor c2(ent_from number, ent_to number) is
  select /*+ ALL_ROWS */ distinct dr.entry_no, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused, t.cola tunit, i.code,  i.description, i.cola cola
  from strang.lov i, strang.pos p, strang.detailrs dr, strang.lov t
  where dr.entry_no >= ent_from and
        dr.entry_no <= ent_to and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        t.lov_name = 'TARIFF' and
        t.code = i.cola
 union all
  select /*+ ALL_ROWS */ distinct dr.entry_no, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused, null tunit, i.code,  i.description, i.cola cola
  from strang.lov i, strang.pos p, strang.detailrs dr
  where dr.entry_no >= ent_from and
        dr.entry_no <= ent_to and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        (i.cola is null or i.cola not in (select t.code from strang.lov t where t.lov_name = 'TARIFF'))
 union all
  select /*+ ALL_ROWS */ distinct dr.entry_no, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused, null tunit, p.inventoryno code, null description, null cola
  from strang.pos p, strang.detailrs dr
  where dr.entry_no >= ent_from and
        dr.entry_no <= ent_to and
        dr.deliveryno = p.deliveryno and
        (p.inventoryno is null or p.inventoryno not in (select i.code from strang.lov i where i.lov_name = 'INVENT'))
order by 1,2,3;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);
 ent_from	number;
 ent_to		number;

 function vld( p_k1 in varchar2, p_k2 in varchar2, p_k3 in varchar2, fld in varchar2, defval in varchar2 )
  return varchar2
 as
 begin
  for j in pk1.first..pk1.last loop
   if pk1(j) = p_k1 and pk2(j) = p_k2 and pk3(j) = p_k3
    then
     if fld = 'ERRMSG'
      then
       return( errmsg(j) );
     elsif fld = 'V1'
      then
       return( strang.f_sap_format(v1(j),'PO') );
     elsif fld = 'V2'
      then
       return( v2(j) );
     elsif fld = 'V3'
      then
       return( v3(j) );
     elsif fld = 'V4'
      then
       return( v4(j) );
     elsif fld = 'V5'
      then
       return( v5(j) );
     elsif fld = 'V6'
      then
       return( strang.f_sap_format(v6(j),'INVENTORYNO') );
     elsif fld = 'V7'
      then
       return( v7(j) );
     elsif fld = 'V8'
      then
       return( v8(j) );
     elsif fld = 'V1i'
      then
       return( strang.f_sap_format(v1i(j),'DELIVERYNO') );
     elsif fld = 'V8i'
      then
       return( v8i(j) );
     elsif fld = 'V8ii'
      then
       return( v8ii(j) );
     end if;
   end if;
  end loop;
  return( defval );
 end vld;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ENTRY_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 if instr(p1, '.') > 0
  then
   begin ent_from := to_number(strang.ent.get_entry_no(p1)); exception when others then entry_maintain( surl, p1, p2, rid, vrecctr, 'Entry From Number is not a Valid Number' ); return; end;
 else
   begin ent_from := to_number('1' || '.' || strang.ent.get_entry_no(p1, 'D')); exception when others then entry_maintain( surl, p1, p2, rid, vrecctr, 'Entry From Number is not a Valid Number' ); return; end;
 end if;
 if instr(p2, '.') > 0
  then
   begin ent_to := to_number(strang.ent.get_entry_no(p2)); exception when others then entry_maintain( surl, p1, p2, rid, vrecctr, 'Entry To Number is not a Valid Number' ); return; end;
 else
   begin ent_to := to_number('1' || '.' || strang.ent.get_entry_no(p2, 'D')); exception when others then entry_maintain( surl, p1, p2, rid, vrecctr, 'Entry To Number is not a Valid Number' ); return; end;
 end if;
 if ent_from <= 0 or ent_from > ent_to then entry_maintain( surl, p1, p2, rid, vrecctr, 'Entry Number Range is Invalid' ); return; end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'ENTRY_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Entry Maintain Mass Edit',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Entry Maintain Mass Edit') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.bold( 'Entries From' || ':' || strang.ent.get_entry_no(ent_from) || '&nbsp;&nbsp;&nbsp;' || 'To' || ':' || strang.ent.get_entry_no(ent_to));
 htp.nl;

 htp.formopen( 'strangp.accept_entry_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'P1', ent_from );
 htp.formhidden( 'P2', ent_to );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold('Entry No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Delivery No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO Record No.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Delno'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Line'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Inventory Number'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Tariff'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Purchase Order'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO Item'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Supplier Invoice'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Amount Orig Curr'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Quantity'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Corrected Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Old Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Data Entry Validation Message'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2(ent_from, ent_to) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.formhidden( 'PK1', c2rec.entry_no ) || htf.bold(c2rec.entry_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK2', c2rec.deliveryno ) || htf.bold(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK3', c2rec.recno ) || htf.bold(c2rec.recno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1i',10,15,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V1i',c2rec.sap_delno)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8i',10,15,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V8i',c2rec.sap_delno_item)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V6',12,100,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V6',c2rec.code)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V7',20,1000,nvl(vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V7',c2rec.description),c2rec.description)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8',11,20,nvl(vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V8',c2rec.cola),c2rec.cola)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1',12,15,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V1',c2rec.po)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8ii',8,15,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V8ii',c2rec.po_item_no)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V2',8,15,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V2',c2rec.supinv)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3',10,20,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V3',trim(to_char(c2rec.tamount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V4',5,10,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V4',c2rec.qty)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V5',5,8,vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V5',c2rec.tunit)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(c2rec.unit_unitused,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(vld(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'ERRMSG','&nbsp;'),'Success'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec then htp.init; entry_maintain( surl, p1, p2, rid, vrecctr, 'No Entries found that Satisfy this Query' ); return; end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Modify Data' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'ENTRY_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 || '-' || 'P2:' || p2);
end entry_maintain_mass;

procedure accept_entry_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY )
as

 cursor c3(lname varchar2, lcode varchar2) is select * from strang.lov where lov_name = lname and code = lcode;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 errmsg		GLBX.MYARRAY;
 errfound	boolean;
 dupl_values	boolean;
 errunit	char(1);
 msg		varchar2(1000);
 nmb1		STRANG.POS.TAMOUNT%TYPE;
 nmb2		STRANG.POS.QTY%TYPE;
 oinv		STRANG.POS.INVENTORYNO%TYPE;
 dupctr_a	integer;
 dupctr_b	integer;
 tmp		number;
 tmp2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_ENTRY_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 vaccess := data_access( owner_id, 'ENTRY_MAINTAIN', null );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 errfound := FALSE;

 for j in pk1.first..pk1.last loop
  errmsg(j) := NULL;
  if pk1(j) is not null
   then
    -- Validate Numbers Entered
    begin
      nmb1 := to_number( replace(replace(v3(j),',',''),'$','') );
    exception when others then
     begin
       nmb1 := to_number( v3(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Total Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb2 := to_number( v4(j) );
      if nmb2 < 0
       then
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Quantity cannot be less than 0.';
        nmb2 := NULL;
      end if;
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Quantity Entered.';
       nmb2 := NULL;
    end;

    oinv := trim( v6(j) );

    if v1(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Purchase Order cannot be blank.';
    end if;

    if v8ii(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'PO Item cannot be blank.';
    end if;

    if v2(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Supplier Invoice cannot be blank.';
    end if;

    -- Check Unit
    c3rec.code := NULL;
    errunit := 'F';
    if v5(j) is not null
     then
      open c3( 'UNITS', upper(v5(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Incorrect Current Unit.';
        errunit := 'T';
       else
        close c3;
      end if;
    end if;

    -- Update Purchase Order
    update strang.pos
     set
      sap_delno = nvl(strang.f_sap_format(v1i(j),'DELIVERYNO'),sap_delno),
      sap_delno_item = nvl(v8i(j),sap_delno_item),
      po = nvl(strang.f_sap_format(v1(j),'PO'),po),
      po_item_no = nvl(v8ii(j),po_item_no),
      supinv = nvl(v2(j),supinv),
      tamount = nvl(nmb1,tamount),
      qty = nvl(nmb2,qty),
      unit_unitused = decode(errunit,'F',upper(v5(j)),'T',unit_unitused),
      inventoryno = nvl(strang.f_sap_format(oinv,'INVENTORYNO'),inventoryno)
    where
     deliveryno = pk2(j) and
     recno = pk3(j);


    -- Update Purchase Order Quantities for new Form 15  19-Apr-07 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if v5(j) = 'KG' or v5(j) = 'TONNE'
    then

     if v5(j) = 'KG'
       then
        tmp2 := null;
        select sum(nvl(partweight,0)) into tmp2 from strang.detailrs where deliveryno=pk2(j);
        select count('x') into tmp from strang.pos where deliveryno = pk2(j);
        tmp2 := round(tmp2/tmp,0);
        if tmp2 < 1
         then
          tmp2 := 1;
        end if;
     elsif v5(j) = 'TONNE'
      then
        tmp2 := null;
        select sum(nvl(partweight,0)) into tmp2 from strang.detailrs where deliveryno=pk2(j);
        select count('x') into tmp from strang.pos where deliveryno = pk2(j);
        tmp2 := round((tmp2/tmp)/1000,3);
        if tmp2 < 0.001
         then
         tmp2 := 0.001;
        end if;

     end if;
     update strang.pos
      set
      qty = tmp2
     where
      deliveryno = pk2(j) and
      recno = pk3(j);
    end if;


    -- Check if Inventory Exists
    if oinv is not null
     then

      -- Check if multiple inventory numbers have been entered, and if
      dupl_values := FALSE;
      dupctr_a := 0;
      dupctr_b := 0;
      for k in pk1.first..pk1.last loop
       if oinv is not null and trim(v6(k)) is not null and oinv = trim(v6(k))
        then
         -- Check if the Description is different and not null
         if trim(v7(j)) is not null and trim(v7(k)) is not null and trim(v7(j)) <> trim(v7(k))
          then
           dupctr_a := dupctr_a + 1;
         end if;
         -- Check if the Tariff number is different and not null
         if trim(v8(j)) is not null and trim(v8(k)) is not null and trim(v8(j)) <> trim(v8(k))
          then
           dupctr_b := dupctr_b + 1;
         end if;
       end if;
      end loop;

      if dupctr_a > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different descriptions exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupctr_b > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different Tariff Numbers exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupl_values
       then
        --
        errfound := TRUE;

       else
        open c3('INVENT',v6(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            description = nvl(v7(j),description)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          insert into strang.lov(lov_name,code,description,cola) values ('INVENT',v6(j),v7(j),v8(j));
        end if;
      end if;

      -- Check if Tariff Exists
      if v8(j) is null
       then
        null;
       else
        open c3('TARIFF',v8(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            cola = v8(j)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          errfound := TRUE;
          errmsg(j) := errmsg(j) || ' ' || 'Tariff value not found - ' || htf.anchor2( 'strangp.accept_lov?surl=' || surl || '&parm=TARIFF&SRC=&LRANGE=&P0=&P1=&P2=&P3=&P4=&P5=&ACTION=' || replace(LNGS.STR_TXT_357,' ','+'),'Insert New Tariff.', ctarget=>'INSWIND');
        end if;
      end if;
    end if;

  end if;
 end loop;
 commit;
 if errfound then msg := 'Errors found Modifying Data. Please Review each Entry Record to see what the Error was.'; end if;

 entry_maintain_mass(surl, p1, p2, rid,vrecctr, pk1, pk2, pk3, v1, v2, v3, v4, v5, v6, v7, v8, v1i, v8i, v8ii, errmsg, msg );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_ENTRY_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 || '-' || 'P2:' || p2);
end accept_entry_maintain_mass;

-- xxxxxx 20160615
procedure po_inventory_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.po_inventory_MAINTAIN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'POS', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Choose Inventory Number',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Update By Inventory') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 htp.formopen( 'strangp.poinventory_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'PK2', NULL );
 htp.formhidden( 'PK3', NULL );
 htp.formhidden( 'V1', NULL );
 htp.formhidden( 'V2', NULL );
 htp.formhidden( 'V9', NULL );
 htp.formhidden( 'V1i', NULL );
 htp.formhidden( 'V8i', NULL );
 htp.formhidden( 'V3_1', NULL );
 htp.formhidden( 'V3_1_1', NULL );
 htp.formhidden( 'V3_2', NULL );
 htp.formhidden( 'V3', NULL );
 htp.formhidden( 'V4', NULL );
 htp.formhidden( 'V5', NULL );
 htp.formhidden( 'V6', NULL );
 htp.formhidden( 'V7', NULL );
 htp.formhidden( 'V8', NULL );
 htp.formhidden( 'ERRMSG', NULL );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold('Inventory Number'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P1',20,30, ''),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Submit' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'po_inventory_MAINTAIN',null,owner_id,errmsg=>sqlerrm,extdet=>'Strt:' || strt);
end po_inventory_maintain;

procedure poinventory_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY, v3_2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null )
as

 cursor c2(inventno varchar2) is
  select /*+ ALL_ROWS */ distinct p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item,p.po, p.po_item_no, p.supinv, p.grn, p.amount, p.gstc_gstcode, p.gst, p.tamount, p.qty, p.unit_unitused, i.code,  i.description
  from strang.lov i, strang.pos p
  where p.inventoryno = inventno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        p.sap_delno is null
 union all
  select /*+ ALL_ROWS */ distinct p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.grn, p.amount, p.gstc_gstcode, p.gst, p.tamount, p.qty, p.unit_unitused, p.inventoryno code, null description
  from strang.pos p
  where p.inventoryno = inventno and
        p.sap_delno is null and
       ( p.inventoryno not in (select i.code from strang.lov i where i.lov_name = 'INVENT'))
order by 1,2,3;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);
 inventno	integer;

 function vld( p_k2 in varchar2, p_k3 in varchar2, fld in varchar2, defval in varchar2 )
  return varchar2
 as
 begin
  for j in pk2.first..pk2.last loop
   if pk2(j) = p_k2 and pk3(j) = p_k3
    then
     if fld = 'ERRMSG'
      then
       return( errmsg(j) );
     elsif fld = 'V1'
      then
       return( strang.f_sap_format(v1(j),'PO') );
     elsif fld = 'V1i'
      then
       return( strang.f_sap_format(v1i(j),'DELIVERYNO') );
     elsif fld = 'V2'
      then
       return( v2(j) );
     elsif fld = 'V3_1'
      then
       return( v3_1(j) );
     elsif fld = 'V3_1_1'
      then
       return( v3_1_1(j) );
     elsif fld = 'V3_2'
      then
       return( v3_2(j) );
     elsif fld = 'V3'
      then
       return( v3(j) );
     elsif fld = 'V4'
      then
       return( v4(j) );
     elsif fld = 'V5'
      then
       return( v5(j) );
     elsif fld = 'V6'
      then
       return( strang.f_sap_format(v6(j),'INVENTORYNO') );
     elsif fld = 'V7'
      then
       return( v7(j) );
     elsif fld = 'V8'
      then
       return( v8(j) );
     elsif fld = 'V8i'
      then
       return( v8i(j) );
     elsif fld = 'V9'
      then
       return( strang.f_sap_format(v9(j),'GRN') );
     end if;
   end if;
  end loop;
  return( defval );
 end vld;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.poinventory_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 begin inventno := to_char(p1); exception when others then po_inventory_maintain( surl, p1, rid, vrecctr, 'Inventory Number is not a Valid' ); return; end;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'po_inventory_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'PO Inventory Maintain Mass Edit',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'PO Inventory Maintain Mass Edit') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.bold( 'Inventory Number' || ':' || to_char(inventno));
 htp.nl;

 htp.formopen( 'strangp.accept_poinvent_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'P1', p1 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold('Delivery No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('RecNo'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Delno'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Line'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Purchase Order'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO Item'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Supplier Inv'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Goods Receipt'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Net Amount'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('GST Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('GST'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Total Amount'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Qty'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Inventory'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Data Entry Validation Message'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2(inventno) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.formhidden( 'PK2', c2rec.deliveryno ) || htf.bold(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK3', c2rec.recno ) || htf.bold(c2rec.recno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1i',10,15,vld(c2rec.deliveryno,c2rec.recno,'V1i',c2rec.sap_delno)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8i',5,10,vld(c2rec.deliveryno,c2rec.recno,'V8i',c2rec.sap_delno_item)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1',12,15,vld(c2rec.deliveryno,c2rec.recno,'V1',c2rec.po)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8',5,10,vld(c2rec.deliveryno,c2rec.recno,'V8',c2rec.po_item_no)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V2',8,15,vld(c2rec.deliveryno,c2rec.recno,'V2',c2rec.supinv)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V9',12,15,vld(c2rec.deliveryno,c2rec.recno,'V9',c2rec.grn)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3_1',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3_1',trim(to_char(c2rec.amount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'GSTCODES', 'V3_1_1', c2rec.gstc_gstcode, TRUE, FALSE, FALSE, isedit=>TRUE );
     htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'V3_2',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3_2',trim(to_char(c2rec.gst,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3',trim(to_char(c2rec.tamount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V4',10,12,vld(c2rec.deliveryno,c2rec.recno,'V4',c2rec.qty)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V5',5,8,vld(c2rec.deliveryno,c2rec.recno,'V5',c2rec.unit_unitused)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V6',12,100,vld(c2rec.deliveryno,c2rec.recno,'V6',c2rec.code)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V7',20,1000,nvl(vld(c2rec.deliveryno,c2rec.recno,'V7',c2rec.description),c2rec.description)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(vld(c2rec.deliveryno,c2rec.recno,'ERRMSG','&nbsp;'),'Success'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec then htp.init; po_inventory_maintain( surl, p1, rid, vrecctr, 'No Records found that Satisfy this Query' ); return; end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Modify Data' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'poinventory_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 );
end poinventory_maintain_mass;

procedure accept_poinvent_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY,v3_2 in GLBX.MYARRAY,v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY )
as

 cursor c3(lname varchar2, lcode varchar2) is select * from strang.lov where lov_name = lname and code = lcode;
 cursor c5( cde varchar2 ) is select to_number(cola) cola, colb from strang.lov where lov_name = 'GSTCODES' and code = cde;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 errmsg		GLBX.MYARRAY;
 errfound	boolean;
 dupl_values	boolean;
 errunit	char(1);
 msg		varchar2(1000);
 nmb1_1		STRANG.POS.AMOUNT%TYPE;
 nmb1_2		STRANG.POS.GST%TYPE;
 nmb1		STRANG.POS.TAMOUNT%TYPE;
 nmb2		STRANG.POS.QTY%TYPE;
 nmb3		STRANG.POS.GRN%TYPE;
 oinv		STRANG.POS.INVENTORYNO%TYPE;
 dupctr_a	integer;
 dupctr_b	integer;
 tmp		number;
 tmp2		number;
 vmsg   varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_ENTRY_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 vaccess := data_access( owner_id, 'po_inventory_MAINTAIN', null );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 errfound := FALSE;

 for j in pk2.first..pk2.last loop
  errmsg(j) := NULL;
  if pk2(j) is not null
   then
    -- Validate Numbers Entered
    begin
      nmb1_1 := to_number( replace(replace(v3_1(j),',',''),'$','') );
    exception when others then
     begin
       nmb1_1 := to_number( v3_1(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Net Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb1_2 := to_number( replace(replace(v3_2(j),',',''),'$','') );
    exception when others then
     begin
       nmb1_2 := to_number( v3_2(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid GST Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb1 := to_number( replace(replace(v3(j),',',''),'$','') );
    exception when others then
     begin
       nmb1 := to_number( v3(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Total Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb2 := to_number( v4(j) );
      if nmb2 < 0
       then
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Quantity cannot be less than 0.';
        nmb2 := NULL;
      end if;
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Quantity Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v1i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Delno Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v8i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Line Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb3 := to_number( v9(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid GRN Entered.';
       nmb3 := NULL;
    end;

    oinv := trim( v6(j) );

    if v1(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Purchase Order cannot be blank.';
    end if;

    if v2(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Supplier Invoice cannot be blank.';
    end if;

    -- Check Unit
    c3rec.code := NULL;
    errunit := 'F';
    if v5(j) is not null
     then
      open c3( 'UNITS', upper(v5(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Incorrect Unit.';
        errunit := 'T';
       else
        close c3;
      end if;
    end if;

    -- Check and calculate gst and totalamount

    if nmb1_1 is not null
     then
     if nmb1_2 is null and nmb1 is null
     then
      open c5(v3_1_1(j));
      fetch c5 into c5rec;
      close c5;
      if to_number(c5rec.cola) = 0
      then
        nmb1_2 := 0 ;
        nmb1 := nmb1_1 ;
      else
        if c5rec.colb = 'Inc GST' then
          nmb1_2 := c5rec.cola;
          nmb1 := nmb1_1;
          nmb1_1 := ((100 * nmb1) / (100 + nvl(nmb1_2,0) ));
          nmb1_2 := nmb1_1 * (c5rec.cola/100);
        else
          nmb1_2 := c5rec.cola;
          nmb1 := nmb1_1 * (1 + (nmb1_2/100));
          nmb1_2 := nmb1_1 * (c5rec.cola/100);
        end if;
      end if;
     end if;
    end if;

    -- Update Purchase Order
    update strang.pos
     set
      po = nvl(strang.f_sap_format( v1(j), 'PO' ),po),
      po_item_no = nvl(to_number( v8(j) ),null),
      sap_delno = nvl(strang.f_sap_format( v1i(j), 'DELIVERYNO' ),null),
      sap_delno_item = nvl(to_number( v8i(j) ),null),
      supinv = nvl(v2(j),supinv),
      grn = nvl(strang.f_sap_format( v9(j), 'GRN' ),null),
      amount = nvl(nmb1_1,amount),
      gstc_gstcode = nvl(v3_1_1(j),gstc_gstcode),
      gst = nvl(nmb1_2,gst),
      tamount = nvl(nmb1,tamount),
      qty = nvl(to_number(v4(j)),qty),
      unit_unitused = decode(errunit,'F',upper(v5(j)),'T',unit_unitused),
      inventoryno = nvl(strang.f_sap_format( oinv, 'INVENTORYNO'),inventoryno)
--      inventoryno = nvl(oinv,inventoryno)
    where
     deliveryno = pk2(j) and
     recno = pk3(j);


    -- Check if Inventory Exists
    if oinv is not null
     then

      -- Check if multiple inventory numbers have been entered, and if
      dupl_values := FALSE;
      dupctr_a := 0;
      dupctr_b := 0;
      for k in pk2.first..pk2.last loop
       if oinv is not null and trim(v6(k)) is not null and oinv = trim(v6(k))
        then
         -- Check if the Description is different and not null
         if trim(v7(j)) is not null and trim(v7(k)) is not null and trim(v7(j)) <> trim(v7(k))
          then
           dupctr_a := dupctr_a + 1;
         end if;
       end if;
      end loop;

      if dupctr_a > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different descriptions exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupl_values
       then
        --
        errfound := TRUE;

       else
        open c3('INVENT',v6(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            description = nvl(v7(j),description)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          insert into strang.lov(lov_name,code,description) values ('INVENT',v6(j),v7(j));
        end if;
      end if;

    end if;
   end if;
 end loop;
 commit;
 if errfound then msg := 'Errors found Modifying Data. Please Review each Entry Record to see what the Error was.'; end if;

 poinventory_maintain_mass(surl, p1, rid,vrecctr, pk2, pk3, v1, v2, v9, v3_1 , v3_1_1 ,v3_2 ,v3, v4, v5, v6, v7, v8, v1i,v8i,errmsg, msg );

exception when others then
 glbx.error_details( 'STRANGP', 'accept_poinvent_maintain_mass',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 );
end accept_poinvent_maintain_mass;


-- xxxxxx 20160615
-- xxxxxx 20160714
procedure po_inventdate_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.po_inventdate_MAINTAIN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'POS', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Choose Inventory Number',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Update By Inventory') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 htp.formopen( 'strangp.poinvdte_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'PK2', NULL );
 htp.formhidden( 'PK3', NULL );
 htp.formhidden( 'V1', NULL );
 htp.formhidden( 'V2', NULL );
 htp.formhidden( 'V9', NULL );
 htp.formhidden( 'V1i', NULL );
 htp.formhidden( 'V8i', NULL );
 htp.formhidden( 'V3_1', NULL );
 htp.formhidden( 'V3_1_1', NULL );
 htp.formhidden( 'V3_2', NULL );
 htp.formhidden( 'V3', NULL );
 htp.formhidden( 'V4', NULL );
 htp.formhidden( 'V5', NULL );
 htp.formhidden( 'V6', NULL );
 htp.formhidden( 'V7', NULL );
 htp.formhidden( 'V8', NULL );
 htp.formhidden( 'ERRMSG', NULL );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold('Inventory Number'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P1',20,30, ''),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Date From'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P2',20,30, to_char(add_months(sysdate,-3),'DD-MON-YYYY')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Submit' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'po_inventdate_MAINTAIN',null,owner_id,errmsg=>sqlerrm,extdet=>'Strt:' || strt);
end po_inventdate_maintain;

procedure poinvdte_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY, v3_2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null )
as

 cursor c2(inventno varchar2, rdte varchar2) is
  select /*+ ALL_ROWS */ distinct p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item,p.po, p.po_item_no, p.supinv, p.grn, p.amount, p.gstc_gstcode, p.gst, p.tamount, p.qty, p.unit_unitused, i.code,  i.description
  from strang.lov i, strang.pos p, strang.receivals r
  where p.inventoryno = inventno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        p.deliveryno = r.deliveryno and
        to_date(r.currdate,'DD-MON-YYYY') >= to_date(rdte,'DD-MON-YYYY')
 union all
  select /*+ ALL_ROWS */ distinct p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.grn, p.amount, p.gstc_gstcode, p.gst, p.tamount, p.qty, p.unit_unitused, p.inventoryno code, null description
  from strang.pos p, strang.receivals r
  where p.inventoryno = inventno and
        p.deliveryno = r.deliveryno and
        to_date(r.currdate,'DD-MON-YYYY') >= to_date(rdte,'DD-MON-YYYY') and
       ( p.inventoryno not in (select i.code from strang.lov i where i.lov_name = 'INVENT'))
order by 1,2,3;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);
 inventno	integer;
 rdte		varchar2(20);

 function vld( p_k2 in varchar2, p_k3 in varchar2, fld in varchar2, defval in varchar2 )
  return varchar2
 as
 begin
  for j in pk2.first..pk2.last loop
   if pk2(j) = p_k2 and pk3(j) = p_k3
    then
     if fld = 'ERRMSG'
      then
       return( errmsg(j) );
     elsif fld = 'V1'
      then
       return( strang.f_sap_format(v1(j),'PO') );
     elsif fld = 'V1i'
      then
       return( strang.f_sap_format(v1i(j),'DELIVERYNO') );
     elsif fld = 'V2'
      then
       return( v2(j) );
     elsif fld = 'V3_1'
      then
       return( v3_1(j) );
     elsif fld = 'V3_1_1'
      then
       return( v3_1_1(j) );
     elsif fld = 'V3_2'
      then
       return( v3_2(j) );
     elsif fld = 'V3'
      then
       return( v3(j) );
     elsif fld = 'V4'
      then
       return( v4(j) );
     elsif fld = 'V5'
      then
       return( v5(j) );
     elsif fld = 'V6'
      then
       return( strang.f_sap_format(v6(j),'INVENTORYNO') );
     elsif fld = 'V7'
      then
       return( v7(j) );
     elsif fld = 'V8'
      then
       return( v8(j) );
     elsif fld = 'V8i'
      then
       return( v8i(j) );
     elsif fld = 'V9'
      then
       return( strang.f_sap_format(v9(j),'GRN') );
     end if;
   end if;
  end loop;
  return( defval );
 end vld;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.poinvdte_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 begin inventno := to_char(p1); exception when others then po_inventdate_maintain( surl, p1, rid, vrecctr, 'Inventory Number is not a Valid' ); return; end;
 begin rdte := to_date(p2,'DD-MON-YYYY'); exception when others then po_inventdate_maintain( surl, p1, rid, vrecctr, 'Date is not a Valid' ); return; end;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'po_inventdate_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'PO Inventory Maintain Mass Edit',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'PO Inventory Maintain Mass Edit') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.bold( 'Inventory Number' || ':' || to_char(inventno));
 htp.nl;

 htp.formopen( 'strangp.accept_poinvdte_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'P1', p1 );
 htp.formhidden( 'P2', p2 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold('Delivery No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('RecNo'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Delno'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Line'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Purchase Order'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO Item'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Supplier Inv'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Goods Receipt'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Net Amount'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('GST Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('GST'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Total Amount'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Qty'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Inventory'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Data Entry Validation Message'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2(inventno,rdte) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.formhidden( 'PK2', c2rec.deliveryno ) || htf.bold(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK3', c2rec.recno ) || htf.bold(c2rec.recno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1i',10,15,vld(c2rec.deliveryno,c2rec.recno,'V1i',c2rec.sap_delno)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8i',5,10,vld(c2rec.deliveryno,c2rec.recno,'V8i',c2rec.sap_delno_item)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1',12,15,vld(c2rec.deliveryno,c2rec.recno,'V1',c2rec.po)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8',5,10,vld(c2rec.deliveryno,c2rec.recno,'V8',c2rec.po_item_no)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V2',8,15,vld(c2rec.deliveryno,c2rec.recno,'V2',c2rec.supinv)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V9',12,15,vld(c2rec.deliveryno,c2rec.recno,'V9',c2rec.grn)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3_1',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3_1',trim(to_char(c2rec.amount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'GSTCODES', 'V3_1_1', c2rec.gstc_gstcode, TRUE, FALSE, FALSE, isedit=>TRUE );
     htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'V3_2',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3_2',trim(to_char(c2rec.gst,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3',trim(to_char(c2rec.tamount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V4',10,12,vld(c2rec.deliveryno,c2rec.recno,'V4',c2rec.qty)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V5',5,8,vld(c2rec.deliveryno,c2rec.recno,'V5',c2rec.unit_unitused)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V6',12,100,vld(c2rec.deliveryno,c2rec.recno,'V6',c2rec.code)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V7',20,1000,nvl(vld(c2rec.deliveryno,c2rec.recno,'V7',c2rec.description),c2rec.description)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(vld(c2rec.deliveryno,c2rec.recno,'ERRMSG','&nbsp;'),'Success'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec then htp.init; po_inventdate_maintain( surl, p1, rid, vrecctr, 'No Records found that Satisfy this Query' ); return; end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Modify Data' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'poinvdte_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 );
end poinvdte_maintain_mass;

procedure accept_poinvdte_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY,v3_2 in GLBX.MYARRAY,v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY )
as

 cursor c3(lname varchar2, lcode varchar2) is select * from strang.lov where lov_name = lname and code = lcode;
 cursor c5( cde varchar2 ) is select to_number(cola) cola, colb from strang.lov where lov_name = 'GSTCODES' and code = cde;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 errmsg		GLBX.MYARRAY;
 errfound	boolean;
 dupl_values	boolean;
 errunit	char(1);
 msg		varchar2(1000);
 nmb1_1		STRANG.POS.AMOUNT%TYPE;
 nmb1_2		STRANG.POS.GST%TYPE;
 nmb1		STRANG.POS.TAMOUNT%TYPE;
 nmb2		STRANG.POS.QTY%TYPE;
 nmb3		STRANG.POS.GRN%TYPE;
 oinv		STRANG.POS.INVENTORYNO%TYPE;
 dupctr_a	integer;
 dupctr_b	integer;
 tmp		number;
 tmp2		number;
 vmsg   varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_poinvdte_maintain_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 vaccess := data_access( owner_id, 'po_inventdate_MAINTAIN', null );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 errfound := FALSE;

 for j in pk2.first..pk2.last loop
  errmsg(j) := NULL;
  if pk2(j) is not null
   then
    -- Validate Numbers Entered
    begin
      nmb1_1 := to_number( replace(replace(v3_1(j),',',''),'$','') );
    exception when others then
     begin
       nmb1_1 := to_number( v3_1(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Net Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb1_2 := to_number( replace(replace(v3_2(j),',',''),'$','') );
    exception when others then
     begin
       nmb1_2 := to_number( v3_2(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid GST Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb1 := to_number( replace(replace(v3(j),',',''),'$','') );
    exception when others then
     begin
       nmb1 := to_number( v3(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Total Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb2 := to_number( v4(j) );
      if nmb2 < 0
       then
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Quantity cannot be less than 0.';
        nmb2 := NULL;
      end if;
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Quantity Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v1i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Delno Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v8i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Line Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb3 := to_number( v9(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid GRN Entered.';
       nmb3 := NULL;
    end;

    oinv := trim( v6(j) );

    if v1(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Purchase Order cannot be blank.';
    end if;

    if v2(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Supplier Invoice cannot be blank.';
    end if;

    -- Check Unit
    c3rec.code := NULL;
    errunit := 'F';
    if v5(j) is not null
     then
      open c3( 'UNITS', upper(v5(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Incorrect Unit.';
        errunit := 'T';
       else
        close c3;
      end if;
    end if;

    -- Check and calculate gst and totalamount

    if nmb1_1 is not null
     then
     if nmb1_2 is null and nmb1 is null
     then
      open c5(v3_1_1(j));
      fetch c5 into c5rec;
      close c5;
      if to_number(c5rec.cola) = 0
      then
        nmb1_2 := 0 ;
        nmb1 := nmb1_1 ;
      else
        if c5rec.colb = 'Inc GST' then
          nmb1_2 := c5rec.cola;
          nmb1 := nmb1_1;
          nmb1_1 := ((100 * nmb1) / (100 + nvl(nmb1_2,0) ));
          nmb1_2 := nmb1_1 * (c5rec.cola/100);
        else
          nmb1_2 := c5rec.cola;
          nmb1 := nmb1_1 * (1 + (nmb1_2/100));
          nmb1_2 := nmb1_1 * (c5rec.cola/100);
        end if;
      end if;
     end if;
    end if;

    -- Update Purchase Order
    update strang.pos
     set
      po = nvl(strang.f_sap_format( v1(j), 'PO' ),po),
      po_item_no = nvl(to_number( v8(j) ),null),
      sap_delno = nvl(strang.f_sap_format( v1i(j), 'DELIVERYNO' ),null),
      sap_delno_item = nvl(to_number( v8i(j) ),null),
      supinv = nvl(v2(j),supinv),
      grn = nvl(strang.f_sap_format( v9(j), 'GRN' ),null),
      amount = nvl(nmb1_1,amount),
      gstc_gstcode = nvl(v3_1_1(j),gstc_gstcode),
      gst = nvl(nmb1_2,gst),
      tamount = nvl(nmb1,tamount),
      qty = nvl(to_number(v4(j)),qty),
      unit_unitused = decode(errunit,'F',upper(v5(j)),'T',unit_unitused),
      inventoryno = nvl(strang.f_sap_format( oinv, 'INVENTORYNO'),inventoryno)
--      inventoryno = nvl(oinv,inventoryno)
    where
     deliveryno = pk2(j) and
     recno = pk3(j);


    -- Check if Inventory Exists
    if oinv is not null
     then

      -- Check if multiple inventory numbers have been entered, and if
      dupl_values := FALSE;
      dupctr_a := 0;
      dupctr_b := 0;
      for k in pk2.first..pk2.last loop
       if oinv is not null and trim(v6(k)) is not null and oinv = trim(v6(k))
        then
         -- Check if the Description is different and not null
         if trim(v7(j)) is not null and trim(v7(k)) is not null and trim(v7(j)) <> trim(v7(k))
          then
           dupctr_a := dupctr_a + 1;
         end if;
       end if;
      end loop;

      if dupctr_a > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different descriptions exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupl_values
       then
        --
        errfound := TRUE;

       else
        open c3('INVENT',v6(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            description = nvl(v7(j),description)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          insert into strang.lov(lov_name,code,description) values ('INVENT',v6(j),v7(j));
        end if;
      end if;

    end if;
   end if;
 end loop;
 commit;
 if errfound then msg := 'Errors found Modifying Data. Please Review each Entry Record to see what the Error was.'; end if;

 poinvdte_maintain_mass(surl, p1, p2,rid,vrecctr, pk2, pk3, v1, v2, v9, v3_1 , v3_1_1 ,v3_2 ,v3, v4, v5, v6, v7, v8, v1i,v8i,errmsg, msg );

exception when others then
 glbx.error_details( 'STRANGP', 'accept_poinvdte_maintain_mass',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 );
end accept_poinvdte_maintain_mass;


-- xxxxxx 20160714
procedure po_item_no_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.PO_ITEM_NO_MAINTAIN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'POS', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Choose Delivery Number',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'PO Maintain') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 htp.formopen( 'strangp.poitemno_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'PK2', NULL );
 htp.formhidden( 'PK3', NULL );
 htp.formhidden( 'V1', NULL );
 htp.formhidden( 'V2', NULL );
  htp.formhidden( 'V9', NULL );
htp.formhidden( 'V1i', NULL );
 htp.formhidden( 'V8i', NULL );
 htp.formhidden( 'V3_1', NULL );
 htp.formhidden( 'V3_1_1', NULL );
 htp.formhidden( 'V3_2', NULL );
 htp.formhidden( 'V3', NULL );
 htp.formhidden( 'V4', NULL );
 htp.formhidden( 'V5', NULL );
 htp.formhidden( 'V6', NULL );
 htp.formhidden( 'V7', NULL );
 htp.formhidden( 'V8', NULL );
 htp.formhidden( 'ERRMSG', NULL );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold('Delivery From'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P1',20,30, strt),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Delivery To'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P2',20,30, nvl(strt2, strt)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Submit' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'PO_ITEM_NO_MAINTAIN',null,owner_id,errmsg=>sqlerrm,extdet=>'Strt:' || strt);
end po_item_no_maintain;

procedure POITEMNO_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY, v3_2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null )
as

 cursor c2(del_from integer, del_to integer) is
  select /*+ ALL_ROWS */ distinct p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item,p.po, p.po_item_no, p.supinv, p.grn, p.amount, p.gstc_gstcode, p.gst, p.tamount, p.qty, p.unit_unitused, i.code,  i.description
  from strang.lov i, strang.pos p
  where p.deliveryno >= del_from and
        p.deliveryno <= del_to and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT'
 union all
  select /*+ ALL_ROWS */ distinct p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.grn, p.amount, p.gstc_gstcode, p.gst, p.tamount, p.qty, p.unit_unitused, p.inventoryno code, null description
  from strang.pos p
  where p.deliveryno >= del_from and
        p.deliveryno <= del_to and
        (p.inventoryno is null or p.inventoryno not in (select i.code from strang.lov i where i.lov_name = 'INVENT'))
order by 1,2,3;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);
 del_from	integer;
 del_to		integer;

 function vld( p_k2 in varchar2, p_k3 in varchar2, fld in varchar2, defval in varchar2 )
  return varchar2
 as
 begin
  for j in pk2.first..pk2.last loop
   if pk2(j) = p_k2 and pk3(j) = p_k3
    then
     if fld = 'ERRMSG'
      then
       return( errmsg(j) );
     elsif fld = 'V1'
      then
       return( strang.f_sap_format(v1(j),'PO') );
     elsif fld = 'V1i'
      then
       return( strang.f_sap_format(v1i(j),'DELIVERYNO') );
     elsif fld = 'V2'
      then
       return( v2(j) );
     elsif fld = 'V3_1'
      then
       return( v3_1(j) );
     elsif fld = 'V3_1_1'
      then
       return( v3_1_1(j) );
     elsif fld = 'V3_2'
      then
       return( v3_2(j) );
     elsif fld = 'V3'
      then
       return( v3(j) );
     elsif fld = 'V4'
      then
       return( v4(j) );
     elsif fld = 'V5'
      then
       return( v5(j) );
     elsif fld = 'V6'
      then
       return( strang.f_sap_format(v6(j),'INVENTORYNO') );
     elsif fld = 'V7'
      then
       return( v7(j) );
     elsif fld = 'V8'
      then
       return( v8(j) );
     elsif fld = 'V8i'
      then
       return( v8i(j) );
     elsif fld = 'V9'
      then
       return( strang.f_sap_format(v9(j),'GRN') );
     end if;
   end if;
  end loop;
  return( defval );
 end vld;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.POITEMNO_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 begin del_from := to_number(p1); exception when others then po_item_no_maintain( surl, p1, p2, rid, vrecctr, 'Delivery From Number is not a Valid Number' ); return; end;
 begin del_to := to_number(p2); exception when others then po_item_no_maintain( surl, p1, p2, rid, vrecctr, 'Delivery To Number is not a Valid Number' ); return; end;
 if del_from <= 0 or del_from > del_to then po_item_no_maintain( surl, p1, p2, rid, vrecctr, 'Delivery Number Range is Invalid' ); return; end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'PO_ITEM_NO_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'PO Item No Maintain Mass Edit',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'PO Item No Maintain Mass Edit') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.bold( 'Deliveries From' || ':' || to_char(del_from) || '&nbsp;&nbsp;&nbsp;' || 'To' || ':' || to_char(del_to));
 htp.nl;

 htp.formopen( 'strangp.accept_poitemno_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'P1', p1 );
 htp.formhidden( 'P2', p2 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold('Delivery No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('RecNo'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Delno'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Line'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Purchase Order'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO Item'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Supplier Inv'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Goods Receipt'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Net Amount'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('GST Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('GST'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Total Amount'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Qty'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Inventory'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Data Entry Validation Message'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2(del_from, del_to) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.formhidden( 'PK2', c2rec.deliveryno ) || htf.bold(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK3', c2rec.recno ) || htf.bold(c2rec.recno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1i',10,15,vld(c2rec.deliveryno,c2rec.recno,'V1i',c2rec.sap_delno)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8i',5,10,vld(c2rec.deliveryno,c2rec.recno,'V8i',c2rec.sap_delno_item)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1',12,15,vld(c2rec.deliveryno,c2rec.recno,'V1',c2rec.po)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8',5,10,vld(c2rec.deliveryno,c2rec.recno,'V8',c2rec.po_item_no)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V2',8,15,vld(c2rec.deliveryno,c2rec.recno,'V2',c2rec.supinv)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V9',12,15,vld(c2rec.deliveryno,c2rec.recno,'V9',c2rec.grn)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3_1',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3_1',trim(to_char(c2rec.amount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'GSTCODES', 'V3_1_1', c2rec.gstc_gstcode, TRUE, FALSE, FALSE, isedit=>TRUE );
     htp.p( '</TD>' );
    htp.tabledata( htf.formtext( 'V3_2',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3_2',trim(to_char(c2rec.gst,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3',10,20,vld(c2rec.deliveryno,c2rec.recno,'V3',trim(to_char(c2rec.tamount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V4',10,12,vld(c2rec.deliveryno,c2rec.recno,'V4',c2rec.qty)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V5',5,8,vld(c2rec.deliveryno,c2rec.recno,'V5',c2rec.unit_unitused)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V6',12,100,vld(c2rec.deliveryno,c2rec.recno,'V6',c2rec.code)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V7',20,1000,nvl(vld(c2rec.deliveryno,c2rec.recno,'V7',c2rec.description),c2rec.description)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(vld(c2rec.deliveryno,c2rec.recno,'ERRMSG','&nbsp;'),'Success'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec then htp.init; po_item_no_maintain( surl, p1, p2, rid, vrecctr, 'No Records found that Satisfy this Query' ); return; end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Modify Data' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'POITEMNO_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 || '-' || 'P2:' || p2);
end poitemno_maintain_mass;

procedure accept_poitemno_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v3_1 in GLBX.MYARRAY, v3_1_1 in GLBX.MYARRAY,v3_2 in GLBX.MYARRAY,v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY )
as

 cursor c3(lname varchar2, lcode varchar2) is select * from strang.lov where lov_name = lname and code = lcode;
 cursor c5( cde varchar2 ) is select to_number(cola) cola, colb from strang.lov where lov_name = 'GSTCODES' and code = cde;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 errmsg		GLBX.MYARRAY;
 errfound	boolean;
 dupl_values	boolean;
 errunit	char(1);
 msg		varchar2(1000);
 nmb1_1		STRANG.POS.AMOUNT%TYPE;
 nmb1_2		STRANG.POS.GST%TYPE;
 nmb1		STRANG.POS.TAMOUNT%TYPE;
 nmb2		STRANG.POS.QTY%TYPE;
 nmb3		STRANG.POS.GRN%TYPE;
 oinv		STRANG.POS.INVENTORYNO%TYPE;
 dupctr_a	integer;
 dupctr_b	integer;
 tmp		number;
 tmp2		number;
 vmsg   varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_ENTRY_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 vaccess := data_access( owner_id, 'PO_ITEM_NO_MAINTAIN', null );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 errfound := FALSE;

 for j in pk2.first..pk2.last loop
  errmsg(j) := NULL;
  if pk2(j) is not null
   then
    -- Validate Numbers Entered
    begin
      nmb1_1 := to_number( replace(replace(v3_1(j),',',''),'$','') );
    exception when others then
     begin
       nmb1_1 := to_number( v3_1(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Net Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb1_2 := to_number( replace(replace(v3_2(j),',',''),'$','') );
    exception when others then
     begin
       nmb1_2 := to_number( v3_2(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid GST Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb1 := to_number( replace(replace(v3(j),',',''),'$','') );
    exception when others then
     begin
       nmb1 := to_number( v3(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Total Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb2 := to_number( v4(j) );
      if nmb2 < 0
       then
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Quantity cannot be less than 0.';
        nmb2 := NULL;
      end if;
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Quantity Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v1i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Delno Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v8i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Line Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb3 := to_number( v9(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid GRN Entered.';
       nmb3 := NULL;
    end;

    oinv := trim( v6(j) );

    if v1(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Purchase Order cannot be blank.';
    end if;

    if v2(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Supplier Invoice cannot be blank.';
    end if;

    -- Check Unit
    c3rec.code := NULL;
    errunit := 'F';
    if v5(j) is not null
     then
      open c3( 'UNITS', upper(v5(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Incorrect Unit.';
        errunit := 'T';
       else
        close c3;
      end if;
    end if;

    -- Check and calculate gst and totalamount

    if nmb1_1 is not null
     then
     if nmb1_2 is null and nmb1 is null
     then
      open c5(v3_1_1(j));
      fetch c5 into c5rec;
      close c5;
      if to_number(c5rec.cola) = 0
      then
        nmb1_2 := 0 ;
        nmb1 := nmb1_1 ;
      else
        if c5rec.colb = 'Inc GST' then
          nmb1_2 := c5rec.cola;
          nmb1 := nmb1_1;
          nmb1_1 := ((100 * nmb1) / (100 + nvl(nmb1_2,0) ));
          nmb1_2 := nmb1_1 * (c5rec.cola/100);
        else
          nmb1_2 := c5rec.cola;
          nmb1 := nmb1_1 * (1 + (nmb1_2/100));
          nmb1_2 := nmb1_1 * (c5rec.cola/100);
        end if;
      end if;
     end if;
    end if;

    -- Update Purchase Order
    update strang.pos
     set
      po = nvl(strang.f_sap_format( v1(j), 'PO' ),po),
      po_item_no = nvl(to_number( v8(j) ),null),
      sap_delno = nvl(strang.f_sap_format( v1i(j), 'DELIVERYNO' ),null),
      sap_delno_item = nvl(to_number( v8i(j) ),qty),
      supinv = nvl(v2(j),supinv),
      grn = nvl(strang.f_sap_format( v9(j), 'GRN' ),null),
      amount = nvl(nmb1_1,amount),
      gstc_gstcode = nvl(v3_1_1(j),gstc_gstcode),
      gst = nvl(nmb1_2,gst),
      tamount = nvl(nmb1,tamount),
      qty = nvl(to_number(v4(j)),qty),
      unit_unitused = decode(errunit,'F',upper(v5(j)),'T',unit_unitused),
      inventoryno = nvl(strang.f_sap_format( oinv, 'INVENTORYNO'),inventoryno)
--      inventoryno = nvl(oinv,inventoryno)
    where
     deliveryno = pk2(j) and
     recno = pk3(j);


    -- Check if Inventory Exists
    if oinv is not null
     then

      -- Check if multiple inventory numbers have been entered, and if
      dupl_values := FALSE;
      dupctr_a := 0;
      dupctr_b := 0;
      for k in pk2.first..pk2.last loop
       if oinv is not null and trim(v6(k)) is not null and oinv = trim(v6(k))
        then
         -- Check if the Description is different and not null
         if trim(v7(j)) is not null and trim(v7(k)) is not null and trim(v7(j)) <> trim(v7(k))
          then
           dupctr_a := dupctr_a + 1;
         end if;
       end if;
      end loop;

      if dupctr_a > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different descriptions exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupl_values
       then
        --
        errfound := TRUE;

       else
        open c3('INVENT',v6(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            description = nvl(v7(j),description)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          insert into strang.lov(lov_name,code,description) values ('INVENT',v6(j),v7(j));
        end if;
      end if;

    end if;
   end if;
 end loop;
 commit;
 if errfound then msg := 'Errors found Modifying Data. Please Review each Entry Record to see what the Error was.'; end if;

 poitemno_maintain_mass(surl, p1, p2, rid,vrecctr, pk2, pk3, v1, v2, v9, v3_1 , v3_1_1 ,v3_2 ,v3, v4, v5, v6, v7, v8, v1i,v8i,errmsg, msg );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_POITEMNO_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 || '-' || 'P2:' || p2);
end accept_poitemno_maintain_mass;


-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  below added 090107

procedure container_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.CONTAINER_MAINTAIN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'CONTAINER_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Choose Container Number',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Container Maintain') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 htp.formopen( 'strangp.container_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'PK1', NULL );
 htp.formhidden( 'PK2', NULL );
 htp.formhidden( 'PK3', NULL );
 htp.formhidden( 'V1', NULL );
 htp.formhidden( 'V2', NULL );
 htp.formhidden( 'V3', NULL );
 htp.formhidden( 'V4', NULL );
 htp.formhidden( 'V5', NULL );
 htp.formhidden( 'V6', NULL );
 htp.formhidden( 'V7', NULL );
 htp.formhidden( 'V8', NULL );
 htp.formhidden( 'V1i', NULL );
 htp.formhidden( 'V8i', NULL );
 htp.formhidden( 'V8ii', NULL );
 htp.formhidden( 'V9i', NULL );
 htp.formhidden( 'V9', NULL );
 htp.formhidden( 'V10', NULL );
 htp.formhidden( 'ERRMSG', NULL );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold('Container'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P1',20,30, strt),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Seal'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P2',20,30, nvl(strt2, strt)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Submit' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'CONTAINER_MAINTAIN',null,owner_id,errmsg=>sqlerrm,extdet=>'Strt:' || strt);
end container_maintain;

procedure container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null )
as

 cursor c2(container varchar2, seal varchar2) is
  select /*+ ALL_ROWS */ distinct dr.movement_no,dr.camov_seal, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused,t.cola tunit, i.code,  i.description, i.cola cola, p.state, p.ahecc, p.delivery_charge
  from strang.lov i, strang.pos p, strang.detailrs dr, strang.lov t
  where dr.movement_no = container and
        dr.camov_seal = seal and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        t.lov_name = 'TARIFF' and
        t.code = i.cola
 union all
  select /*+ ALL_ROWS */ distinct dr.movement_no,dr.camov_seal, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused, null tunit, i.code,  i.description, i.cola cola, p.state, p.ahecc, p.delivery_charge
  from strang.lov i, strang.pos p, strang.detailrs dr
  where  dr.movement_no = container and
        dr.camov_seal = seal and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        (i.cola is null or i.cola not in (select t.code from strang.lov t where t.lov_name = 'TARIFF'))
 union all
  select /*+ ALL_ROWS */ distinct dr.movement_no,dr.camov_seal, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused, null tunit, p.inventoryno code, null description, null cola, p.state, p.ahecc, p.delivery_charge
  from strang.pos p, strang.detailrs dr
  where  dr.movement_no = container and
        dr.camov_seal = seal and
        dr.deliveryno = p.deliveryno and
        (p.inventoryno is null or p.inventoryno not in (select i.code from strang.lov i where i.lov_name = 'INVENT'))
order by 1,2,3,4;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);
 container	varchar2(40);
 seal		varchar2(15);

 function vld( p_k1 in varchar2, p_k2 in varchar2, p_k3 in varchar2, fld in varchar2, defval in varchar2 )
  return varchar2
 as
 begin
  for j in pk1.first..pk1.last loop
   if pk1(j) = p_k1 and pk2(j) = p_k2 and pk3(j) = p_k3
    then
     if fld = 'ERRMSG'
      then
       return( errmsg(j) );
     elsif fld = 'V1'
      then
       return( strang.f_sap_format(v1(j),'PO') );
     elsif fld = 'V2'
      then
       return( v2(j) );
     elsif fld = 'V3'
      then
       return( v3(j) );
     elsif fld = 'V4'
      then
       return( v4(j) );
     elsif fld = 'V5'
      then
       return( v5(j) );
     elsif fld = 'V6'
      then
       return( strang.f_sap_format(v6(j),'INVENTORYNO') );
     elsif fld = 'V7'
      then
       return( v7(j) );
     elsif fld = 'V8'
      then
       return( v8(j) );
     elsif fld = 'V1i'
      then
       return( strang.f_sap_format(v1i(j),'DELIVERYNO') );
     elsif fld = 'V8i'
      then
       return( v8i(j) );
     elsif fld = 'v8ii'
      then
       return( v8ii(j) );
     elsif fld = 'V9i'
      then
       return( v9i(j) );
     elsif fld = 'V9'
      then
       return( v9(j) );
     elsif fld = 'V10'
      then
       return( v10(j) );
     end if;
   end if;
  end loop;
  return( defval );
 end vld;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.CONTAINER_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 begin container := p1; exception when others then container_maintain( surl, p1, p2, rid, vrecctr, 'Container is not a Valid Number' ); return; end;
 begin seal := p2; exception when others then container_maintain( surl, p1, p2, rid, vrecctr, 'Seal is not a Valid Number' ); return; end;
 if container = ' ' or seal = ' ' then container_maintain( surl, p1, p2, rid, vrecctr, 'Container is Invalid' ); return; end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'CONTAINER_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Container Maintain Mass Edit',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Container Maintain Mass Edit') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.bold( 'Container' || ':' || container || '&nbsp;&nbsp;&nbsp;' || 'Seal' || ':' || seal);
 htp.nl;

 htp.formopen( 'strangp.accept_container_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'P1', p1 );
 htp.formhidden( 'P2', p2 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold('Container'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Delivery No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO RecNo'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Delno'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Qty'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Purchase Order'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO Item'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Supplier Invoice'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Amount Orig Curr'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Delivery Charge'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Quantity'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Corrected Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Old Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Inventory Number'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Tariff'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('AHECC'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('State'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Data Entry Validation Message'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2(container, seal) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.formhidden( 'PK1', c2rec.movement_no ) || htf.bold(c2rec.movement_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK2', c2rec.deliveryno ) || htf.bold(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK3', c2rec.recno ) || htf.bold(c2rec.recno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1i',10,15,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V1i',c2rec.sap_delno)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8i',8,10,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V8i',c2rec.sap_delno_item)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1',12,15,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V1',c2rec.po)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8ii',5,10,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V8ii',c2rec.po_item_no)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V2',8,15,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V2',c2rec.supinv)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3',10,20,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V3',trim(to_char(c2rec.tamount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V10',5,10,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V10',trim(to_char(c2rec.delivery_charge,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V4',5,10,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V4',c2rec.qty)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V5',5,8,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V5',c2rec.tunit)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(c2rec.unit_unitused,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V6',12,100,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V6',c2rec.code)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V7',20,1000,nvl(vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V7',c2rec.description),c2rec.description)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8',11,20,nvl(vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V8',c2rec.cola),c2rec.cola)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V9i',11,20,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V9i',strang.f_ahecc(c2rec.ahecc,c2rec.state,c2rec.tamount,c2rec.delivery_charge,container,seal))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V9',3,8,vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'V9',c2rec.state)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(vld(c2rec.movement_no,c2rec.deliveryno,c2rec.recno,'ERRMSG','&nbsp;'),'Success'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec then htp.init; container_maintain( surl, p1, p2, rid, vrecctr, 'No Containers found that Satisfy this Query' ); return; end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Modify Data' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'CONTAINER_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 || '-' || 'P2:' || p2);
end container_maintain_mass;


--  %%%%%%%%%%%%%%%%%%%%%%%%% new work 190407 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

procedure accept_container_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY )
as

 cursor c3(lname varchar2, lcode varchar2) is select * from strang.lov where lov_name = lname and code = lcode;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 errmsg		GLBX.MYARRAY;
 errfound	boolean;
 dupl_values	boolean;
 errunit	char(1);
 errstate	char(1);
 msg		varchar2(1000);
 nmb1		STRANG.POS.TAMOUNT%TYPE;
 nmb2		STRANG.POS.QTY%TYPE;
 nmb3		STRANG.POS.DELIVERY_CHARGE%TYPE;
 oinv		STRANG.POS.INVENTORYNO%TYPE;
 dupctr_a	integer;
 dupctr_b	integer;
 tmp		number;
 tmp2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_CONTAINER_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 vaccess := data_access( owner_id, 'CONTAINER_MAINTAIN', null );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 errfound := FALSE;

 for j in pk1.first..pk1.last loop
  errmsg(j) := NULL;
  if pk1(j) is not null
   then
    -- Validate Numbers Entered
    begin
      nmb1 := to_number( replace(replace(v3(j),',',''),'$','') );
    exception when others then
     begin
       nmb1 := to_number( v3(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Total Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    if v10(j) is not null
    then
      begin
        nmb3 := to_number( replace(replace(v10(j),',',''),'$','') );
      exception when others then
       begin
         nmb3 := to_number( v10(j), LNGS.MONEY_FORMAT );
        exception when others then
         errfound := TRUE;
         errmsg(j) := errmsg(j) || ' ' || 'Invalid Delivery Charge Entered.';
         nmb3 := NULL;
       end;
      end;
    end if;
    begin
      nmb2 := to_number( v4(j) );
      if nmb2 < 0.001
       then
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Quantity cannot be less than 0.001';
        nmb2 := NULL;
      end if;
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Quantity Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v1i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Delno Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v8i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Line Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v8ii(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid PO Item Entered.';
       nmb2 := NULL;
    end;

    oinv := trim( v6(j) );

    if v1(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Purchase Order cannot be blank.';
    end if;

    if v2(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Supplier Invoice cannot be blank.';
    end if;

    -- Check Unit
    c3rec.code := NULL;
    errunit := 'F';
    if v5(j) is not null
     then
      open c3( 'UNITS', upper(v5(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Incorrect Current Unit.';
        errunit := 'T';
       else
        close c3;
      end if;
    end if;

    -- Check State
    c3rec.code := NULL;
    errstate := 'F';
    if v9(j) is not null
     then
      open c3( 'STATE', upper(v9(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'State should be FOR, NSW, QLD, VIC, SA, NT, WA, ACT';
        errstate := 'T';
       else
        close c3;
      end if;
    end if;


    update strang.pos
     set
      sap_delno = nvl(strang.f_sap_format(v1i(j),'DELIVERYNO'),sap_delno),
      sap_delno_item = nvl(v8i(j),sap_delno_item),
      supinv = nvl(v2(j),supinv),
      po = nvl(strang.f_sap_format(v1(j),'PO'),po),
      po_item_no = nvl(v8ii(j),po_item_no),
      tamount = nvl(nmb1,tamount),
      qty = nvl(V4(j),qty),
      unit_unitused = decode(errunit,'F',upper(v5(j)),'T',unit_unitused),
      inventoryno = nvl(strang.f_sap_format(oinv,'INVENTORYNO'),inventoryno),
      state = decode(errstate,'F',upper(v9(j)),'T',state),
      ahecc = nvl(v9i(j),ahecc), --strang.f_ahecc(v9i(j),decode(errstate,'F',upper(v9(j)),'T',state),nvl(nmb1,tamount),nmb3,p1,p2)  , --nvl(v9i(j),ahecc),
      delivery_charge = nmb3 --v10(j)
    where
     deliveryno = pk2(j) and
     recno = pk3(j);

    -- Update Purchase Order Quantities for new Form 15  19-Apr-07 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if v5(j) = 'KG' or v5(j) = 'TONNE'
    then

     if v5(j) = 'KG'
       then
        tmp2 := null;
        select sum(nvl(partweight,0)) into tmp2 from strang.detailrs where deliveryno=pk2(j);
        select count('x') into tmp from strang.pos where deliveryno = pk2(j);
        tmp2 := round(tmp2/tmp,0);
        if tmp2 < 1
         then
          tmp2 := 1;
        end if;
     elsif v5(j) = 'TONNE'
      then
        tmp2 := null;
        select sum(nvl(partweight,0)) into tmp2 from strang.detailrs where deliveryno=pk2(j);
        select count('x') into tmp from strang.pos where deliveryno = pk2(j);
        tmp2 := round((tmp2/tmp)/1000,3);
        if tmp2 < 0.001
         then
         tmp2 := 0.001;
        end if;

     end if;
     update strang.pos
      set
      qty = tmp2
     where
      deliveryno = pk2(j) and
      recno = pk3(j);
    end if;


    -- Check if Inventory Exists
    if oinv is not null
     then

      -- Check if multiple inventory numbers have been entered, and if
      dupl_values := FALSE;
      dupctr_a := 0;
      dupctr_b := 0;
      for k in pk1.first..pk1.last loop
       if oinv is not null and trim(v6(k)) is not null and oinv = trim(v6(k))
        then
         -- Check if the Description is different and not null
         if trim(v7(j)) is not null and trim(v7(k)) is not null and trim(v7(j)) <> trim(v7(k))
          then
           dupctr_a := dupctr_a + 1;
         end if;
         -- Check if the Tariff number is different and not null
         if trim(v8(j)) is not null and trim(v8(k)) is not null and trim(v8(j)) <> trim(v8(k))
          then
           dupctr_b := dupctr_b + 1;
         end if;
       end if;
      end loop;

      if dupctr_a > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different descriptions exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupctr_b > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different Tariff Numbers exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupl_values
       then
        --
        errfound := TRUE;

       else
        open c3('INVENT',v6(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            description = nvl(v7(j),description)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          insert into strang.lov(lov_name,code,description,cola) values ('INVENT',v6(j),v7(j),v8(j));
        end if;
      end if;

      -- Check if Tariff Exists
      if v8(j) is null
       then
        null;
       else
        open c3('TARIFF',v8(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            cola = v8(j)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          errfound := TRUE;
          errmsg(j) := errmsg(j) || ' ' || 'Tariff value not found - ' || htf.anchor2( 'strangp.accept_lov?surl=' || surl || '&parm=TARIFF&SRC=&LRANGE=&P0=&P1=&P2=&P3=&P4=&P5=&ACTION=' || replace(LNGS.STR_TXT_357,' ','+'),'Insert New Tariff.', ctarget=>'INSWIND');
        end if;
      end if;
    end if;

  end if;
 end loop;
 commit;
 if errfound then msg := 'Errors found Modifying Data. Please Review each Log Record to see what the Error was.'; end if;

 container_maintain_mass(surl, p1, p2, rid,vrecctr, pk1, pk2, pk3, v1, v2, v3, v4, v5, v6, v7, v8, v1i, v8i, v8ii, v9, v9i,v10, errmsg, msg );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_CONTAINER_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 || '-' || 'P2:' || p2);
end accept_container_maintain_mass;
-- 20170517

procedure log_maintain(surl in varchar2, strt in varchar2, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.LOG_MAINTAIN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'LOG_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Choose Log Number',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Log Maintain') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 htp.formopen( 'strangp.log_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'PK1', NULL );
 htp.formhidden( 'PK2', NULL );
 htp.formhidden( 'PK3', NULL );
 htp.formhidden( 'V1', NULL );
 htp.formhidden( 'V2', NULL );
 htp.formhidden( 'V3', NULL );
 htp.formhidden( 'V4', NULL );
 htp.formhidden( 'V5', NULL );
 htp.formhidden( 'V6', NULL );
 htp.formhidden( 'V7', NULL );
 htp.formhidden( 'V8', NULL );
 htp.formhidden( 'V1i', NULL );
 htp.formhidden( 'V8i', NULL );
 htp.formhidden( 'V8ii', NULL );
 htp.formhidden( 'V9i', NULL );
 htp.formhidden( 'V9', NULL );
 htp.formhidden( 'V10', NULL );
 htp.formhidden( 'ERRMSG', NULL );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold('Log No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P1',20,30, strt),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Submit' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'LOG_MAINTAIN',null,owner_id,errmsg=>sqlerrm,extdet=>'Strt:' || strt);
end log_maintain;

procedure log_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null )
as

 cursor c2(logno varchar2) is
  select /*+ ALL_ROWS */ distinct dr.logno,dr.movement_no, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused,t.cola tunit, i.code,  i.description, i.cola cola, p.state, p.ahecc, p.delivery_charge
  from strang.lov i, strang.pos p, strang.detailrs dr, strang.lov t
  where dr.logno = p1 and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        t.lov_name = 'TARIFF' and
        t.code = i.cola
 union all
  select /*+ ALL_ROWS */ distinct dr.logno,dr.movement_no, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused, null tunit, i.code,  i.description, i.cola cola, p.state, p.ahecc, p.delivery_charge
  from strang.lov i, strang.pos p, strang.detailrs dr
  where  dr.logno = p1 and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        (i.cola is null or i.cola not in (select t.code from strang.lov t where t.lov_name = 'TARIFF'))
 union all
  select /*+ ALL_ROWS */ distinct dr.logno,dr.movement_no, p.deliveryno, p.recno, p.sap_delno, p.sap_delno_item, p.po, p.po_item_no, p.supinv, p.tamount, p.qty, p.unit_unitused, null tunit, p.inventoryno code, null description, null cola, p.state, p.ahecc, p.delivery_charge
  from strang.pos p, strang.detailrs dr
  where  dr.logno = p1 and
        dr.deliveryno = p.deliveryno and
        (p.inventoryno is null or p.inventoryno not in (select i.code from strang.lov i where i.lov_name = 'INVENT'))
order by 1,2,3,4;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);
 logno		varchar2(15);

 function vld( p_k1 in varchar2, p_k2 in varchar2, p_k3 in varchar2, fld in varchar2, defval in varchar2 )
  return varchar2
 as
 begin
  for j in pk1.first..pk1.last loop
   if pk1(j) = p_k1 and pk2(j) = p_k2 and pk3(j) = p_k3
    then
     if fld = 'ERRMSG'
      then
       return( errmsg(j) );
     elsif fld = 'V1'
      then
       return( strang.f_sap_format(v1(j),'PO') );
     elsif fld = 'V2'
      then
       return( v2(j) );
     elsif fld = 'V3'
      then
       return( v3(j) );
     elsif fld = 'V4'
      then
       return( v4(j) );
     elsif fld = 'V5'
      then
       return( v5(j) );
     elsif fld = 'V6'
      then
       return( strang.f_sap_format(v6(j),'INVENTORYNO') );
     elsif fld = 'V7'
      then
       return( v7(j) );
     elsif fld = 'V8'
      then
       return( v8(j) );
     elsif fld = 'V1i'
      then
       return( strang.f_sap_format(v1i(j),'DELIVERYNO') );
     elsif fld = 'V8i'
      then
       return( v8i(j) );
     elsif fld = 'v8ii'
      then
       return( v8ii(j) );
     elsif fld = 'V9i'
      then
       return( v9i(j) );
     elsif fld = 'V9'
      then
       return( v9(j) );
     elsif fld = 'V10'
      then
       return( v10(j) );
     end if;
   end if;
  end loop;
  return( defval );
 end vld;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.LOG_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 begin logno := p1; exception when others then log_maintain( surl, p1, rid, vrecctr, 'Log is not a Valid Number' ); return; end;
 if logno = ' ' then log_maintain( surl, p1, rid, vrecctr, 'Log number is Invalid' ); return; end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'LOG_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Log Maintain Mass Edit',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Log Maintain Mass Edit') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.bold( 'Log Number' || ':' || logno );
 htp.nl;

 htp.formopen( 'strangp.accept_log_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'P1', p1 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold('Log No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Delivery No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO RecNo'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Delno'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('OTML Qty'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Purchase Order'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO Item'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Supplier Invoice'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Amount Orig Curr'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Delivery Charge'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Quantity'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Corrected Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Old Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Inventory Number'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Tariff'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('AHECC'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('State'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Data Entry Validation Message'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2(logno) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.formhidden( 'PK1', c2rec.logno ) || htf.bold(c2rec.logno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK2', c2rec.deliveryno ) || htf.bold(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK3', c2rec.recno ) || htf.bold(c2rec.recno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1i',10,15,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V1i',c2rec.sap_delno)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8i',8,10,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V8i',c2rec.sap_delno_item)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1',12,15,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V1',c2rec.po)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8ii',5,10,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V8ii',c2rec.po_item_no)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V2',8,15,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V2',c2rec.supinv)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3',10,20,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V3',trim(to_char(c2rec.tamount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V10',5,10,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V10',c2rec.delivery_charge)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V4',5,10,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V4',c2rec.qty)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V5',5,8,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V5',c2rec.tunit)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(c2rec.unit_unitused,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V6',12,100,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V6',c2rec.code)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V7',20,1000,nvl(vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V7',c2rec.description),c2rec.description)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8',11,20,nvl(vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V8',c2rec.cola),c2rec.cola)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V9i',11,20,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V9i',c2rec.ahecc)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V9',3,8,vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'V9',c2rec.state)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(vld(c2rec.logno,c2rec.deliveryno,c2rec.recno,'ERRMSG','&nbsp;'),'Success'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec then htp.init; log_maintain( surl, p1, rid, vrecctr, 'No Logs found that Satisfy this Query' ); return; end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Modify Data' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'LOG_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1);
end log_maintain_mass;


--  %%%%%%%%%%%%%%%%%%%%%%%%% new work 190407 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

procedure accept_log_maintain_mass(surl in varchar2, p1 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, v1i in GLBX.MYARRAY, v8i in GLBX.MYARRAY, v8ii in GLBX.MYARRAY, v9 in GLBX.MYARRAY, v9i in GLBX.MYARRAY, v10 in GLBX.MYARRAY )
as

 cursor c3(lname varchar2, lcode varchar2) is select * from strang.lov where lov_name = lname and code = lcode;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 errmsg		GLBX.MYARRAY;
 errfound	boolean;
 dupl_values	boolean;
 errunit	char(1);
 errstate	char(1);
 msg		varchar2(1000);
 nmb1		STRANG.POS.TAMOUNT%TYPE;
 nmb2		STRANG.POS.QTY%TYPE;
 nmb3		STRANG.POS.DELIVERY_CHARGE%TYPE;
 oinv		STRANG.POS.INVENTORYNO%TYPE;
 dupctr_a	integer;
 dupctr_b	integer;
 tmp		number;
 tmp2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_LOG_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 vaccess := data_access( owner_id, 'LOG_MAINTAIN', null );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 errfound := FALSE;

 for j in pk1.first..pk1.last loop
  errmsg(j) := NULL;
  if pk1(j) is not null
   then
    -- Validate Numbers Entered
    begin
      nmb1 := to_number( replace(replace(v3(j),',',''),'$','') );
    exception when others then
     begin
       nmb1 := to_number( v3(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Total Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    if v10(j) is not null
    then
      begin
        nmb3 := to_number( replace(replace(v10(j),',',''),'$','') );
      exception when others then
       begin
         nmb3 := to_number( v10(j), LNGS.MONEY_FORMAT );
        exception when others then
         errfound := TRUE;
         errmsg(j) := errmsg(j) || ' ' || 'Invalid Delivery Charge Entered.';
         nmb3 := NULL;
       end;
      end;
    end if;
    begin
      nmb2 := to_number( v4(j) );
      if nmb2 < 0.001
       then
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Quantity cannot be less than 0.001';
        nmb2 := NULL;
      end if;
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Quantity Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v1i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Delno Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v8i(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid SAP Line Entered.';
       nmb2 := NULL;
    end;
    begin
      nmb2 := to_number( v8ii(j) );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid PO Item Entered.';
       nmb2 := NULL;
    end;

    oinv := trim( v6(j) );

    if v1(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Purchase Order cannot be blank.';
    end if;

    if v2(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Supplier Invoice cannot be blank.';
    end if;

    -- Check Unit
    c3rec.code := NULL;
    errunit := 'F';
    if v5(j) is not null
     then
      open c3( 'UNITS', upper(v5(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Incorrect Current Unit.';
        errunit := 'T';
       else
        close c3;
      end if;
    end if;

    -- Check State
    c3rec.code := NULL;
    errstate := 'F';
    if v9(j) is not null
     then
      open c3( 'STATE', upper(v9(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'State should be FOR, NSW, QLD, VIC, SA, NT, WA, ACT';
        errstate := 'T';
       else
        close c3;
      end if;
    end if;


    update strang.pos
     set
      sap_delno = nvl(strang.f_sap_format(v1i(j),'DELIVERYNO'),sap_delno),
      sap_delno_item = nvl(v8i(j),sap_delno_item),
      supinv = nvl(v2(j),supinv),
      po = nvl(strang.f_sap_format(v1(j),'PO'),po),
      po_item_no = nvl(v8ii(j),po_item_no),
      tamount = nvl(nmb1,tamount),
      qty = nvl(V4(j),qty),
      unit_unitused = decode(errunit,'F',upper(v5(j)),'T',unit_unitused),
      inventoryno = nvl(strang.f_sap_format(oinv,'INVENTORYNO'),inventoryno),
      state = decode(errstate,'F',upper(v9(j)),'T',state),
      ahecc = nvl(v9i(j),ahecc),
      delivery_charge = nmb3 --v10(j)
    where
     deliveryno = pk2(j) and
     recno = pk3(j);

    -- Update Purchase Order Quantities for new Form 15  19-Apr-07 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if v5(j) = 'KG' or v5(j) = 'TONNE'
    then

     if v5(j) = 'KG'
       then
        tmp2 := null;
        select sum(nvl(partweight,0)) into tmp2 from strang.detailrs where deliveryno=pk2(j);
        select count('x') into tmp from strang.pos where deliveryno = pk2(j);
        tmp2 := round(tmp2/tmp,0);
        if tmp2 < 1
         then
          tmp2 := 1;
        end if;
     elsif v5(j) = 'TONNE'
      then
        tmp2 := null;
        select sum(nvl(partweight,0)) into tmp2 from strang.detailrs where deliveryno=pk2(j);
        select count('x') into tmp from strang.pos where deliveryno = pk2(j);
        tmp2 := round((tmp2/tmp)/1000,3);
        if tmp2 < 0.001
         then
         tmp2 := 0.001;
        end if;

     end if;
     update strang.pos
      set
      qty = tmp2
     where
      deliveryno = pk2(j) and
      recno = pk3(j);
    end if;


    -- Check if Inventory Exists
    if oinv is not null
     then

      -- Check if multiple inventory numbers have been entered, and if
      dupl_values := FALSE;
      dupctr_a := 0;
      dupctr_b := 0;
      for k in pk1.first..pk1.last loop
       if oinv is not null and trim(v6(k)) is not null and oinv = trim(v6(k))
        then
         -- Check if the Description is different and not null
         if trim(v7(j)) is not null and trim(v7(k)) is not null and trim(v7(j)) <> trim(v7(k))
          then
           dupctr_a := dupctr_a + 1;
         end if;
         -- Check if the Tariff number is different and not null
         if trim(v8(j)) is not null and trim(v8(k)) is not null and trim(v8(j)) <> trim(v8(k))
          then
           dupctr_b := dupctr_b + 1;
         end if;
       end if;
      end loop;

      if dupctr_a > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different descriptions exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupctr_b > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different Tariff Numbers exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupl_values
       then
        --
        errfound := TRUE;

       else
        open c3('INVENT',v6(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            description = nvl(v7(j),description)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          insert into strang.lov(lov_name,code,description,cola) values ('INVENT',v6(j),v7(j),v8(j));
        end if;
      end if;

      -- Check if Tariff Exists
      if v8(j) is null
       then
        null;
       else
        open c3('TARIFF',v8(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            cola = v8(j)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          errfound := TRUE;
          errmsg(j) := errmsg(j) || ' ' || 'Tariff value not found - ' || htf.anchor2( 'strangp.accept_lov?surl=' || surl || '&parm=TARIFF&SRC=&LRANGE=&P0=&P1=&P2=&P3=&P4=&P5=&ACTION=' || replace(LNGS.STR_TXT_357,' ','+'),'Insert New Tariff.', ctarget=>'INSWIND');
        end if;
      end if;
    end if;

  end if;
 end loop;
 commit;
 if errfound then msg := 'Errors found Modifying Data. Please Review each Log Record to see what the Error was.'; end if;

 log_maintain_mass(surl, p1, rid,vrecctr, pk1, pk2, pk3, v1, v2, v3, v4, v5, v6, v7, v8, v1i, v8i, v8ii, v9, v9i,v10, errmsg, msg );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_LOG_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 );
end accept_log_maintain_mass;

--zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz



-- end 20170517
--zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
-- new work 290508

procedure delivery_maintain(surl in varchar2, strt in varchar2, strt2 in varchar2 default null, rid in varchar2, vrecctr in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.DELIVERY_MAINTAIN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'DELIVERY_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Choose Delivery Number',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Delivery Maintain') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 htp.formopen( 'strangp.delivery_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'PK1', NULL );
 htp.formhidden( 'PK2', NULL );
 htp.formhidden( 'PK3', NULL );
 htp.formhidden( 'V1', NULL );
 htp.formhidden( 'V2', NULL );
 htp.formhidden( 'V3', NULL );
 htp.formhidden( 'V4', NULL );
 htp.formhidden( 'V5', NULL );
 htp.formhidden( 'V6', NULL );
 htp.formhidden( 'V7', NULL );
 htp.formhidden( 'V8', NULL );
 htp.formhidden( 'ERRMSG', NULL );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
     htp.tabledata( htf.bold('Delivery No From'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P1',20,30, strt),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Delivery No To'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('P2',20,30, nvl(strt2, strt)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Submit' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'DELIVERY_MAINTAIN',null,owner_id,errmsg=>sqlerrm,extdet=>'Strt:' || strt);
end delivery_maintain;

procedure delivery_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY, errmsg in GLBX.MYARRAY, msg in varchar2 default null )
as

 cursor c2(del_from integer, del_to integer) is
  select /*+ ALL_ROWS */ distinct dr.entry_no, p.deliveryno, p.recno, p.po, p.supinv, p.tamount, p.qty, p.unit_unitused, t.cola tunit, i.code,  i.description, i.cola cola
  from strang.lov i, strang.pos p, strang.detailrs dr, strang.lov t
  where dr.deliveryno >= del_from and
        dr.deliveryno <= del_to and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        t.lov_name = 'TARIFF' and
        t.code = i.cola
 union all
  select /*+ ALL_ROWS */ distinct dr.entry_no, p.deliveryno, p.recno, p.po, p.supinv, p.tamount, p.qty, p.unit_unitused, null tunit, i.code,  i.description, i.cola cola
  from strang.lov i, strang.pos p, strang.detailrs dr
  where dr.deliveryno >= del_from and
        dr.deliveryno <= del_to and
        dr.deliveryno = p.deliveryno and
        p.inventoryno = i.code and
        i.lov_name = 'INVENT' and
        (i.cola is null or i.cola not in (select t.code from strang.lov t where t.lov_name = 'TARIFF'))
 union all
  select /*+ ALL_ROWS */ distinct dr.entry_no, p.deliveryno, p.recno, p.po, p.supinv, p.tamount, p.qty, p.unit_unitused, null tunit, p.inventoryno code, null description, null cola
  from strang.pos p, strang.detailrs dr
  where dr.deliveryno >= del_from and
        dr.deliveryno <= del_to and
        dr.deliveryno = p.deliveryno and
        (p.inventoryno is null or p.inventoryno not in (select i.code from strang.lov i where i.lov_name = 'INVENT'))
order by 2,3;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 foundrec	boolean;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 seclevel	varchar2(100);
 del_from	integer;
 del_to		integer;

 function vldd( p_k1 in varchar2, p_k2 in varchar2, p_k3 in varchar2, fld in varchar2, defval in varchar2 )
  return varchar2
 as
 begin
  for j in pk2.first..pk2.last loop
   if pk2(j) = p_k2 and pk3(j) = p_k3
    then
     if fld = 'ERRMSG'
      then
       return( errmsg(j) );
     elsif fld = 'V1'
      then
       return( v1(j) );
     elsif fld = 'V2'
      then
       return( v2(j) );
     elsif fld = 'V3'
      then
       return( v3(j) );
     elsif fld = 'V4'
      then
       return( v4(j) );
     elsif fld = 'V5'
      then
       return( v5(j) );
     elsif fld = 'V6'
      then
       return( v6(j) );
     elsif fld = 'V7'
      then
       return( v7(j) );
     elsif fld = 'V8'
      then
       return( v8(j) );
     end if;
   end if;
  end loop;
  return( defval );
 end vldd;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.DELIVERY_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 begin del_from := to_number(p1); exception when others then delivery_maintain( surl, p1, p2, rid, vrecctr, 'Delivery From Number is not a Valid Number' ); return; end;
 begin del_to := to_number(p2); exception when others then delivery_maintain( surl, p1, p2, rid, vrecctr, 'Delivery To Number is not a Valid Number' ); return; end;
 if del_from <= 0 or del_from > del_to then delivery_maintain( surl, p1, p2, rid, vrecctr, 'Delivery Number Range is Invalid' ); return; end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'DELIVERY_MAINTAIN', null );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Delivery Maintain Mass Edit',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR30',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 glbx.header_msg( nvl(msg,'Delivery Maintain Mass Edit') );

 htp.p( '<CENTER>' );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.bold( 'Deliveries From' || ':' || to_char(del_from) || '&nbsp;&nbsp;&nbsp;' || 'To' || ':' || to_char(del_to));
 htp.nl;

 htp.formopen( 'strangp.accept_delivery_maintain_mass' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'VRECCTR', vrecctr );
 htp.formhidden( 'P1', p1 );
 htp.formhidden( 'P2', p2 );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold('Entry No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Delivery No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('PO Record No.'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Purchase Order'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Supplier Invoice'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Amount Orig Curr'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Quantity'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Corrected Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Old Unit'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Inventory Number'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Tariff'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Data Entry Validation Message'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2(del_from, del_to) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.tabledata( htf.formhidden( 'PK1', c2rec.entry_no ) || htf.bold(c2rec.entry_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK2', c2rec.deliveryno ) || htf.bold(c2rec.deliveryno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'PK3', c2rec.recno ) || htf.bold(c2rec.recno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V1',8,15,vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V1',c2rec.po)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V2',8,15,vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V2',c2rec.supinv)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V3',10,20,vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V3',trim(to_char(c2rec.tamount,LNGS.MONEY_FORMAT)))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V4',5,10,vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V4',c2rec.qty)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V5',5,8,vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V5',c2rec.tunit)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(c2rec.unit_unitused,'&nbsp;'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V6',10,100,vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V6',c2rec.code)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V7',20,1000,nvl(vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V7',c2rec.description),c2rec.description)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext( 'V8',11,20,nvl(vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'V8',c2rec.cola),c2rec.cola)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( nvl(vldd(c2rec.entry_no,c2rec.deliveryno,c2rec.recno,'ERRMSG','&nbsp;'),'Success'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 if not foundrec then htp.init; delivery_maintain( surl, p1, p2, rid, vrecctr, 'No Deliveries found that Satisfy this Query' ); return; end if;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( null, 'Modify Data' ) || htf.formclose );
   htp.tabledata( htf.formopen( 'strangp.receive', ctarget=>'_top' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'RID', replace(rid,'~','+') ) ||
                  htf.formhidden( 'SCID', NULL ) || htf.formhidden( 'VRECCTR', vrecctr ) || htf.formhidden( 'CALL_NAME', null ) || htf.formhidden( 'PARM', 'DETAILRS' ) || htf.formhidden( 'ACCESS_ID', 'x' ) || htf.formsubmit( null, 'Cancel' ) || htf.formclose );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'DELIVERY_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 || '-' || 'P2:' || p2);
end delivery_maintain_mass;

procedure accept_delivery_maintain_mass(surl in varchar2, p1 in varchar2, p2 in varchar2, rid in varchar2, vrecctr in varchar2, pk1 in GLBX.MYARRAY, pk2 in GLBX.MYARRAY, pk3 in GLBX.MYARRAY,
                              v1 in GLBX.MYARRAY, v2 in GLBX.MYARRAY, v3 in GLBX.MYARRAY, v4 in GLBX.MYARRAY, v5 in GLBX.MYARRAY, v6 in GLBX.MYARRAY, v7 in GLBX.MYARRAY, v8 in GLBX.MYARRAY )
as

 cursor c3(lname varchar2, lcode varchar2) is select * from strang.lov where lov_name = lname and code = lcode;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 errmsg		GLBX.MYARRAY;
 errfound	boolean;
 dupl_values	boolean;
 errunit	char(1);
 msg		varchar2(1000);
 nmb1		STRANG.POS.TAMOUNT%TYPE;
 nmb2		STRANG.POS.QTY%TYPE;
 oinv		STRANG.POS.INVENTORYNO%TYPE;
 dupctr_a	integer;
 dupctr_b	integer;
 tmp		number;
 tmp2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_DELIVERY_MAINTAIN_MASS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 vaccess := data_access( owner_id, 'DELIVERY_MAINTAIN', null );
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 errfound := FALSE;

 for j in pk2.first..pk2.last loop
  errmsg(j) := NULL;
  if pk1(j) is not null
   then
    -- Validate Numbers Entered
    begin
      nmb1 := to_number( replace(replace(v3(j),',',''),'$','') );
    exception when others then
     begin
       nmb1 := to_number( v3(j), LNGS.MONEY_FORMAT );
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Total Amount Entered.';
       nmb1 := NULL;
     end;
    end;
    begin
      nmb2 := to_number( v4(j) );
      if nmb2 < 0
       then
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Quantity cannot be less than 0.';
        nmb2 := NULL;
      end if;
      exception when others then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Invalid Quantity Entered.';
       nmb2 := NULL;
    end;

    oinv := trim( v6(j) );

    if v1(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Purchase Order cannot be blank.';
    end if;

    if v2(j) is null
     then
       errfound := TRUE;
       errmsg(j) := errmsg(j) || ' ' || 'Supplier Invoice cannot be blank.';
    end if;

    -- Check Unit
    c3rec.code := NULL;
    errunit := 'F';
    if v5(j) is not null
     then
      open c3( 'UNITS', upper(v5(j)));
      fetch c3 into c3rec;
      if c3%NOTFOUND
       then
        close c3;
        errfound := TRUE;
        errmsg(j) := errmsg(j) || ' ' || 'Incorrect Current Unit.';
        errunit := 'T';
       else
        close c3;
      end if;
    end if;

    -- Update Purchase Order
    update strang.pos
     set
      po = nvl(v1(j),po),
      supinv = nvl(v2(j),supinv),
      tamount = nvl(nmb1,tamount),
      qty = nvl(nmb2,qty),
      unit_unitused = decode(errunit,'F',upper(v5(j)),'T',unit_unitused),
      inventoryno = nvl(oinv,inventoryno)
    where
     deliveryno = pk2(j) and
     recno = pk3(j);


    -- Update Purchase Order Quantities for new Form 15  19-Apr-07 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if v5(j) = 'KG' or v5(j) = 'TONNE'
    then

     if v5(j) = 'KG'
       then
        tmp2 := null;
        select sum(nvl(partweight,0)) into tmp2 from strang.detailrs where deliveryno=pk2(j);
        select count('x') into tmp from strang.pos where deliveryno = pk2(j);
        tmp2 := round(tmp2/tmp,0);
        if tmp2 < 1
         then
          tmp2 := 1;
        end if;
     elsif v5(j) = 'TONNE'
      then
        tmp2 := null;
        select sum(nvl(partweight,0)) into tmp2 from strang.detailrs where deliveryno=pk2(j);
        select count('x') into tmp from strang.pos where deliveryno = pk2(j);
        tmp2 := round((tmp2/tmp)/1000,3);
        if tmp2 < 0.001
         then
         tmp2 := 0.001;
        end if;

     end if;
     update strang.pos
      set
      qty = tmp2
     where
      deliveryno = pk2(j) and
      recno = pk3(j);
    end if;


    -- Check if Inventory Exists
    if oinv is not null
     then

      -- Check if multiple inventory numbers have been entered, and if
      dupl_values := FALSE;
      dupctr_a := 0;
      dupctr_b := 0;
      for k in pk1.first..pk1.last loop
       if oinv is not null and trim(v6(k)) is not null and oinv = trim(v6(k))
        then
         -- Check if the Description is different and not null
         if trim(v7(j)) is not null and trim(v7(k)) is not null and trim(v7(j)) <> trim(v7(k))
          then
           dupctr_a := dupctr_a + 1;
         end if;
         -- Check if the Tariff number is different and not null
         if trim(v8(j)) is not null and trim(v8(k)) is not null and trim(v8(j)) <> trim(v8(k))
          then
           dupctr_b := dupctr_b + 1;
         end if;
       end if;
      end loop;

      if dupctr_a > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different descriptions exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupctr_b > 0
       then
        errmsg(j) := errmsg(j) || ' ' || 'Different Tariff Numbers exist for the same Inventory Number.';
        dupl_values := TRUE;
      end if;

      if dupl_values
       then
        --
        errfound := TRUE;

       else
        open c3('INVENT',v6(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            description = nvl(v7(j),description)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          insert into strang.lov(lov_name,code,description,cola) values ('INVENT',v6(j),v7(j),v8(j));
        end if;
      end if;

      -- Check if Tariff Exists
      if v8(j) is null
       then
        null;
       else
        open c3('TARIFF',v8(j));
        fetch c3 into c3rec;
        if c3%FOUND
         then
          close c3;
          update strang.lov
           set
            cola = v8(j)
          where
           lov_name = 'INVENT' and
           code = oinv;
         else
          close c3;
          errfound := TRUE;
          errmsg(j) := errmsg(j) || ' ' || 'Tariff value not found - ' || htf.anchor2( 'strangp.accept_lov?surl=' || surl || '&parm=TARIFF&SRC=&LRANGE=&P0=&P1=&P2=&P3=&P4=&P5=&ACTION=' || replace(LNGS.STR_TXT_357,' ','+'),'Insert New Tariff.', ctarget=>'INSWIND');
        end if;
      end if;
    end if;

  end if;
 end loop;
 commit;
 if errfound then msg := 'Errors found Modifying Data. Please Review each Entry Record to see what the Error was.'; end if;

 delivery_maintain_mass(surl, p1, p2, rid,vrecctr, pk1, pk2, pk3, v1, v2, v3, v4, v5, v6, v7, v8, errmsg, msg );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_DELIVERY_MAINTAIN_MASS',null,owner_id,errmsg=>sqlerrm,extdet=>'P1:' || p1 || '-' || 'P2:' || p2);
end accept_delivery_maintain_mass;



--vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
procedure confirm_genduty(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2(rid rowid) is select * from strang.ships_airway where rowid = rid;

 cursor c3(vship_id integer)
 is
 select distinct r.curr
 from strang.receivals r, strang.detailrs dr, strang.movements m, strang.ships_airway s, strang.customers c
 where
   m.ship_id = vship_id and
   s.ship_id = m.ship_id and
   r.deliveryno = dr.deliveryno and
   r.cust_customer_id = c.customer_id and
   c.customs_agent is not null and
   dr.movement_no = m.movement_no and
   nvl(dr.camov_seal,'|') = nvl(seal,'|') and
   not exists(select 'x' from strang.lov l
              where l.lov_name = 'UNRATTAB' and
                    l.code = r.curr and
                    nvl(to_date(glbx.guess_date(l.cola),'DD-MON-YYYY'),s.estarrive) <= s.estarrive and
		    nvl(to_date(glbx.guess_date(l.colb),'DD-MON-YYYY'),s.estarrive) >= s.estarrive);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);
 currneeded     boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.CONFIRM_GENDUTY' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'SHP2', rid );

 glbx.main_title( surl, 'Confirm', glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR11',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );
 htp.nl;
 currneeded := false;
 open c2(replace(rid,'~','+'));
  fetch c2 into c2rec;
  if c2%NOTFOUND
  then
    currneeded :=true;
    htp.p('Ship Id '|| replace(rid,'~','+'));
    htp.nl;
  end if;
 close c2;
 htp.formopen( 'strangp.genduty' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'ACCESS_ID', access_id );
 htp.formhidden( 'MSG', msg );
 htp.formsubmit( 'ACTION', LNGS.STR_TXT_412 );
 if msg = 'DUTY'
  then
    for c3rec in c3(c2rec.ship_id) loop
     htp.p('Currency Code Needed For ' || c3rec.curr );
     htp.nl;
     currneeded := true;
    end loop;
   if not currneeded then
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_413 );
   end if;
  else
   htp.formsubmit( 'ACTION', LNGS.STR_TXT_414 );
 end if;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'STRANGP', 'CONFIRM_GENDUTY',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end confirm_genduty;

procedure genduty(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, action in varchar2 default null )
as

 cursor c2(rid rowid) is select * from strang.ships_airway where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENDUTY' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 if action = LNGS.STR_TXT_412
  then
--    shp2( surl, rid, scid, parm, access_id, LNGS.STR_TXT_415 );
    shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_415 );
    return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'SHP2', rid );

 if vaccess in ('NONE','READ') then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if access_id <> 'z'
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
   if c2rec.ship_airway = 'A'
    then
     generate_ships_manifest( c2rec.ship_id, nvl(msg,'LINE_NO'), 'AIRWAY', vste=>vste );
    else
     generate_ships_manifest( c2rec.ship_id, nvl(msg,'LINE_NO'), 'SHIP', vste=>vste );
   end if;

   if msg = 'LINE_NO'
    then
     shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_315 );
    else
     if msg = 'DUTY'
      then
       shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_312 );
      else
       shp( surl, rid, scid, parm, access_id, LNGS.STR_TXT_316 );
     end if;
   end if;
 end if;
exception when others then
 glbx.error_details( 'STRANGP', 'GENDUTY',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end genduty;

procedure inv(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.invoices where rowid = rid;
 cursor c3( invno varchar2 ) is select rowid,inv_invoiceno,quantity,cgunit,cgdesc,cge_chargecode,cgrate,gstc_gstcode,gst from strang.invcharges where inv_invoiceno = invno order by cge_chargecode;
 cursor c4 is select * from strang.charges order by upper(chargecode);
 cursor c5( invno varchar2 ) is select cust_customer_id from strang.receivals r, strang.movements m, strang.detailrs d where d.movement_no = m.movement_no and d.deliveryno = r.deliveryno and m.invoiceno = invno;
 cursor c6( rid rowid ) is select rowid from strang.invoices where invoiceno = (select inv_invoiceno from strang.invcharges where rowid = rid );
 cursor c7(cde varchar2) is
  select colb
  from strang.lov
  where lov_name = 'GSTCODES' and
        code = cde;
 cursor c8(cde varchar2,vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = cde and cola = vste;
 cursor c9(invno varchar2 ) is select rowid,g.* from strang.general_ledger g where invoiceno = invno order by recno,transaction_type,profit_centre,cost_centre,total;
 cursor c10(cday number) is select invoiceno from strang.invoices where completed = 'COMPLETE' and status = 'GL INCOMPLETE' and (sysdate - invdate) > cday and rownum < 5;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 mn		char(3);
 fnd		boolean;
 glcomplete	boolean;
 print_status	boolean;
 ttl1		number;
 ttl2		number;
 ttl3		number;
 check_day	integer;
 vaccess	varchar2(20);
 nrid		varchar2(100);
 seclevel	varchar2(100);
 vste		varchar2(10);
 tmpstr		varchar2(32767);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.INV' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 if parm = 'INVCHARGES'
  then
   open c6(replace(rid,'~','+'));
   fetch c6 into c6rec;
   close c6;
   nrid := rowidtochar( c6rec.rowid );
  else
   nrid := replace(rid,'~','+');
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'INVOICING', nrid );
 seclevel := oltp.security_role( c1rec.aid );

 glbx.main_title( surl, LNGS.STR_TXT_226,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR12',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );
  if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if access_id = 'z'
  then
   c2rec.invdate := sysdate;
   c2rec.billingmonth := to_char(sysdate, 'MON' );
   c2rec.billingyear := to_char(sysdate, 'YYYY' );
   open c8('CONTRACT',vste);
   fetch c8 into c8rec;
   close c8;
   c2rec.ctrk_contract := c8rec.description;
  else
   open c2(nrid);
   fetch c2 into c2rec;
   close c2;
 end if;

 if msg is not null
  then
   glbx.header_msg( msg );
  else
   begin check_day := nvl(to_number(control_code( 'GL ALERT', vste )),7); exception when others then check_day := 7; end;

   -- Previous check
   if c2rec.completed = 'INCOMPLETE' and (sysdate - c2rec.invdate) > 7
    then
     glbx.header_msg( 'Warning: This Invoice is Over 1 Week Old' );
   end if;

   tmpstr := null;
   for c10rec in c10( check_day ) loop
    tmpstr := tmpstr || ',' || c10rec.invoiceno;
   end loop;
   tmpstr := substr(tmpstr,2);
   if tmpstr is not null
    then
     glbx.header_msg( 'Warning: The following General Ledgers are over ' || check_day || ' days old:' || tmpstr );
   end if;
 end if;

 -- Fields to toggle read write and read only
 if c2rec.status = 'GL COMPLETE'
  then
   glcomplete := TRUE;
  else
   glcomplete := FALSE;
 end if;
 if c2rec.completed = 'COMPLETE'
  then
   print_status := TRUE;
  else
   print_status := FALSE;
 end if;

 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<TD align="LEFT">' );
 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_inv' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
   if access_id = 'z'
    then
     htp.formhidden( 'RID', null );
    else
   htp.formhidden( 'RID', replace(nrid,'~','+') );
   end if;
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_227),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     if vaccess = 'EDIT'
      then
       if not(access_id = 'z')
        then
         htp.tabledata( htf.bold(c2rec.invoiceno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
         htp.formhidden( 'P1', c2rec.invoiceno );
        else
         htp.tabledata( htf.formtext('P1',10,10,c2rec.invoiceno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
      else
       htp.tabledata( htf.bold(c2rec.invoiceno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
     htp.tabledata( htf.bold(LNGS.STR_TXT_228),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     if vaccess = 'EDIT' and not glcomplete and not print_status
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       lov_list( 'CONTRACTS', 'P2', c2rec.ctrk_contract, FALSE, FALSE, FALSE );
       htp.p( '</TD>' );
       -- htp.tabledata( htf.formtext('P2',10,10,c2rec.ctrk_contract),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.formhidden( 'P2', c2rec.ctrk_contract ) || htf.bold(c2rec.ctrk_contract),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
     htp.tabledata( htf.bold(LNGS.STR_TXT_229),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     if vaccess = 'EDIT' and not glcomplete and not print_status
      then
       htp.tabledata( htf.formtext('P3',10,20,to_char(c2rec.invdate,LNGS.STR_DATE_02)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.formhidden( 'P3', to_char(c2rec.invdate,LNGS.STR_DATE_02) ) || htf.bold(to_char(c2rec.invdate,LNGS.STR_DATE_02)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
     htp.tabledata( htf.bold('Print Status'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"'); -- change from LNGS.STR_TXT_172
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     if vaccess = 'EDIT'
      then
       htp.formselectopen( 'P4' );
       if c2rec.completed = 'COMPLETE'
        then
         htp.formselectoption( 'COMPLETE', 'SELECTED' );
         htp.formselectoption( 'INCOMPLETE' );
        else
         htp.formselectoption( 'COMPLETE' );
         htp.formselectoption( 'INCOMPLETE', 'SELECTED' );
       end if;
       htp.formselectclose;
      else
       htp.bold( c2rec.completed );
     end if;
     htp.p( '</TD>' );
     htp.tabledata( htf.bold('Branch/Profit Centre'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     if vaccess = 'EDIT' and not glcomplete and not print_status
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
        lov_list( 'JOB_BRANCH', 'P9', nvl(c2rec.job_branch, control_code( 'JOB BRANCH', vste )), TRUE, FALSE, FALSE );
       htp.p( '</TD>' );
      else
       htp.tabledata( htf.formhidden( 'P9', c2rec.job_branch ) || htf.bold(c2rec.job_branch),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
   htp.tablerowclose;
   htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_230),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     if vaccess = 'EDIT'
      then
       htp.formselectopen( 'P5' );
       for j in 1..12 loop
        mn := to_char( to_date( '01-' || lpad( to_char(j),2,'0') || '-2000','DD-MM-YYYY'),'MON');
        if mn = c2rec.billingmonth
         then
          htp.formselectoption( mn, 'SELECTED' );
         else
          htp.formselectoption( mn );
        end if;
       end loop;
       htp.formselectclose;
      else
       htp.bold( c2rec.billingmonth );
     end if;
     htp.p( '</TD>' );
     htp.tabledata( htf.bold(LNGS.STR_TXT_231),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     if vaccess = 'EDIT'
      then
       htp.formselectopen( 'P6' );
       for j in 1998..2020 loop
         if to_char(j) = c2rec.billingyear
         then
          htp.formselectoption( to_char(j), 'SELECTED' );
         else
          htp.formselectoption( to_char(j) );
        end if;
       end loop;
       htp.formselectclose;
      else
       htp.bold( c2rec.billingyear );
     end if;
     htp.p( '</TD>' );
     if vaccess = 'EDIT' and not glcomplete and not print_status
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=2>' );
        htp.bold('Debtor Branch' || ' ');
        lov_list( 'DEBTOR_BRANCH', 'P10', nvl(c2rec.debtor_branch, control_code( 'DEBTOR BRANCH', vste )), TRUE, FALSE, FALSE );
       htp.p( '</TD>' );
      else
       htp.tabledata( htf.formhidden( 'P10', c2rec.debtor_branch ) || htf.bold('Debtor Branch') || ' ' || htf.bold(c2rec.debtor_branch),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=2');
     end if;
     if vaccess = 'EDIT' and not glcomplete and not print_status
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=2>' );
        htp.bold('Debtor Code' || ' ');
        lov_list( 'DEBTOR_CODE', 'P11', nvl(c2rec.debtor_code, control_code( 'DEBTOR CODE', vste )), TRUE, FALSE, FALSE );
       htp.p( '</TD>' );
      else
       htp.tabledata( htf.formhidden( 'P11', c2rec.debtor_code ) || htf.bold('Debtor Code') || ' ' || htf.bold(c2rec.debtor_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=2');
     end if;
     htp.tabledata( htf.bold('Job Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     if vaccess = 'EDIT' and not glcomplete and not print_status
      then
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
        htp.formtext('P12',10,10,nvl(c2rec.job_code, c2rec.invoiceno));
       htp.p( '</TD>' );
      else
       htp.tabledata( htf.formhidden( 'P12', c2rec.job_code ) || htf.bold(c2rec.job_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
     htp.formhidden( 'P7', '0' );
     /*
     htp.tabledata( htf.bold('Owner'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     if vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P7', 3, 1, c2rec.owner ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold( c2rec.owner ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
     */
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_059),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     if vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtextareaopen( 'P8', 5, 75 ) || c2rec.invdesc || htf.formtextareaclose,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=9');
      else
       htp.tabledata( c2rec.invdesc,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=9');
     end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_232),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_059),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_214),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_101),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_083),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_008),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_105),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_233),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_106),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_151),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
  ttl1 := 0;
  ttl2 := 0;
  ttl3 := 0;
  if vaccess = 'EDIT'
   then
    htp.formhidden( 'R7', null );
    if c2rec.completed = 'COMPLETE' or glcomplete
     then
       htp.formhidden( 'R0', null );
       htp.formhidden( 'R1', null );
       htp.formhidden( 'R2', null );
       htp.formhidden( 'R3', null );
       htp.formhidden( 'R4', null );
       htp.formhidden( 'R5', null );
       htp.formhidden( 'R6', null );
       htp.formhidden( 'R7', null );
    end if;
  end if;

  for c3rec in c3( c2rec.invoiceno ) loop
  htp.tablerowopen;
   if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT' or glcomplete
    then
     htp.tabledata( c3rec.cge_chargecode,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.formhidden( 'R0', c3rec.cge_chargecode );
     htp.tabledata( htf.formtext( 'R1', 10, 10, c3rec.cge_chargecode ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT' or glcomplete
    then
     htp.tabledata( c3rec.cgdesc,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.formtext( 'R2', 30, 30, c3rec.cgdesc ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT' or glcomplete
    then
     htp.tabledata( ltrim(to_char(c3rec.cgrate,'99999999.9999')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.formtext( 'R3', 9, 20, ltrim(to_char(c3rec.cgrate,'99999999.9999')), cattributes=>'align="RIGHT"' ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT' or glcomplete
    then
     htp.tabledata( c3rec.cgunit,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'UNITS', 'R4', c3rec.cgunit, FALSE, FALSE, FALSE );
     htp.p( '</TD>' );
   end if;
   if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT' or glcomplete
    then
     htp.tabledata( ltrim(to_char(c3rec.quantity,'99999999.999')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.formtext( 'R5', 8, 20, ltrim(to_char(c3rec.quantity,'99999999.999')), cattributes=>'align="RIGHT"' ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   htp.tabledata( to_char(round(c3rec.cgrate*c3rec.quantity,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
   ttl1 := ttl1 + round(nvl(c3rec.cgrate*c3rec.quantity,0),2);
   if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT' or glcomplete
    then
     htp.tabledata( c3rec.gstc_gstcode,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'GSTCODES', 'R6', c3rec.gstc_gstcode, FALSE, FALSE, FALSE );
     htp.p( '</TD>' );
   end if;
   htp.tabledata( to_char(round(c3rec.gst,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
   ttl2 := ttl2 + round(nvl(c3rec.gst,0),2);
   open c7(c3rec.gstc_gstcode);
   fetch c7 into c7rec;
   close c7;
   if c7rec.colb = LNGS.STR_TXT_368
    then
     htp.tabledata( to_char(round(c3rec.cgrate*c3rec.quantity+c3rec.gst,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     ttl3 := ttl3 + round(nvl(c3rec.cgrate*c3rec.quantity+c3rec.gst,0),2);
    else
     htp.tabledata( to_char(round(c3rec.cgrate*c3rec.quantity,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     ttl3 := ttl3 + round(nvl(c3rec.cgrate*c3rec.quantity,0),2);
   end if;
   if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT' or glcomplete
    then
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.formcheckbox( 'R7', c3rec.rowid ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   end if;
  htp.tablerowclose;
  end loop;

 if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT' or glcomplete
   then
    null;
   else
    for j in 1..3 loop
    htp.tablerowopen;
     htp.formhidden( 'R0', null );
     htp.formhidden( 'R2', null );
     htp.formhidden( 'R3', null );
     htp.formhidden( 'R4', null );
     htp.formhidden( 'R6', null );
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     htp.formselectopen( 'R1' );
     htp.formselectoption( NULL );
     for c4rec in c4 loop
      htp.formselectoption( c4rec.chargecode );
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formtext( 'R5', 8, 20, null, cattributes=>'align="RIGHT"' ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
    end loop;
  end if;
  htp.tablerowopen;
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_012),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(to_char(round(ttl1,2),LNGS.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold(to_char(round(ttl2,2),LNGS.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold(to_char(round(ttl3,2),LNGS.MONEY_FORMAT)),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 if vaccess <> 'EDIT' or glcomplete
  then
   null;
  else
   htp.formsubmit( 'ACTION', 'Populate GL' );
 end if;

 htp.nl;
 htp.tableopen;
  htp.tablerowopen;
     htp.tabledata( htf.bold('General Ledger'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     -- add status here
     if (vaccess <> 'EDIT') or (c2rec.status = 'GL COMPLETE' and c2rec.transfer_date is not null)
      then
       htp.tabledata( htf.formhidden( 'PSTS', c2rec.status ) ||
                      htf.bold(c2rec.status),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="2"');
      else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="2">');
        htp.formselectopen( 'PSTS' );
        if c2rec.status = 'GL COMPLETE'
         then
          htp.formselectoption( 'GL COMPLETE', 'SELECTED' );
         else
          htp.formselectoption( 'GL COMPLETE' );
        end if;
        if nvl(c2rec.status, 'GL INCOMPLETE') = 'GL INCOMPLETE'
         then
          htp.formselectoption( 'GL INCOMPLETE', 'SELECTED' );
         else
          htp.formselectoption( 'GL INCOMPLETE' );
        end if;
        htp.formselectclose;
       htp.p( '</TD>' );
     end if;

     if c2rec.status = 'GL COMPLETE'
      then
       if c2rec.transfer_date is null
        then
         htp.tabledata( 'Not Transferred',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT" COLSPAN="3"');
        else
         htp.tabledata( 'Transferred on ' || trim(to_char(c2rec.transfer_date,'DD Mon YYYY HH24:MI' )),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT" COLSPAN="3"');
       end if;
      else
       htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT" COLSPAN="3"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Transaction Type'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     --htp.tabledata( htf.bold('Profit Centre'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold('Cost Centre'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold('Total (Incl. GST)'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold('GST'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_151),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;

  if vaccess = 'EDIT'
   then
    htp.formhidden( 'G2', null ); -- moved to address issue when removing profit centres
    if c2rec.status = 'GL COMPLETE'
     then
       htp.formhidden( 'G0', null );
       htp.formhidden( 'G1', null );
       htp.formhidden( 'G3', null );
       htp.formhidden( 'G4', null );
       htp.formhidden( 'G5', null );
       htp.formhidden( 'G6', null );
    end if;
  end if;
  htp.formhidden( 'G6', null );
  fnd := FALSE;
  for c9rec in c9( c2rec.invoiceno ) loop
   fnd := TRUE;
   htp.tablerowopen;
    if c2rec.status = 'GL COMPLETE' or vaccess <> 'EDIT'
     then
      htp.tabledata( c9rec.transaction_type,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
     else
      htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER">' );
       htp.formhidden( 'G0', c9rec.recno );
       htp.formselectopen( 'G1' );
       if c9rec.transaction_type = 'S'
        then
         htp.formselectoption( 'S', 'SELECTED' );
        else
         htp.formselectoption( 'S' );
       end if;
       if c9rec.transaction_type = 'C'
        then
         htp.formselectoption( 'C', 'SELECTED' );
        else
         htp.formselectoption( 'C' );
       end if;
       htp.formselectclose;
      htp.p( '</TD>' );
    end if;
    /*
    if c2rec.status = 'GL COMPLETE' or vaccess <> 'EDIT'
     then
      htp.tabledata( c9rec.profit_centre,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER">' );
        lov_list( 'PROFIT_CENTRE', 'G2', c9rec.profit_centre, TRUE, FALSE, FALSE );
       htp.p( '</TD>' );
    end if;
    */
    if c2rec.status = 'GL COMPLETE' or vaccess <> 'EDIT'
     then
      htp.tabledata( c9rec.cost_centre,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER">' );
        lov_list( 'COST_CENTRE', 'G3', c9rec.cost_centre, TRUE, FALSE, FALSE );
       htp.p( '</TD>' );
    end if;
    if c2rec.status = 'GL COMPLETE' or vaccess <> 'EDIT'
     then
      htp.tabledata( to_char(round(c9rec.total,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
      htp.tabledata( htf.formtext( 'G4', 12, 20, trim(to_char(round(c9rec.total,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
    end if;
    if c2rec.status = 'GL COMPLETE' or vaccess <> 'EDIT'
     then
      htp.tabledata( to_char(round(c9rec.gst,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
      htp.tabledata( htf.formtext( 'G5', 12, 20, trim(to_char(round(c9rec.gst,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
    end if;
    if vaccess <> 'EDIT' -- was c2rec.status = 'GL COMPLETE' or : changed I think at recommendation of Sallie
     then
      htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
      htp.tabledata( htf.formcheckbox( 'G6', c9rec.rowid ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
    end if;

   htp.tablerowclose;
  end loop;

  if c2rec.status = 'GL COMPLETE' or vaccess <> 'EDIT'
   then
    null;
   else
    for j in 1..3 loop
    htp.tablerowopen;
     htp.formhidden( 'G0', null );
      htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER">' );
       htp.formselectopen( 'G1' );
         htp.formselectoption( null, 'SELECTED' );
         htp.formselectoption( 'S' );
         htp.formselectoption( 'C' );
       htp.formselectclose;
      htp.p( '</TD>' );
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER">' );
        lov_list( 'PROFIT_CENTRE', 'G2', null, FALSE, FALSE, FALSE );
       htp.p( '</TD>' );
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER">' );
        lov_list( 'COST_CENTRE', 'G3', null, FALSE, FALSE, FALSE );
       htp.p( '</TD>' );
       if j = 1 and not fnd
        then
         htp.tabledata( htf.formtext( 'G4', 12, 20, trim(to_char(round(ttl3,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
         htp.tabledata( htf.formtext( 'G5', 12, 20, trim(to_char(round(ttl2,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
        else
         htp.tabledata( htf.formtext( 'G4', 12, 20),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
         htp.tabledata( htf.formtext( 'G5', 12, 20),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
       end if;
      htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
    end loop;
  end if;

 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT'
  then
   if access_id = 'z'
    then
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_234 ),cattributes=>'VALIGN="TOP"');
    else
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_235 ),cattributes=>'VALIGN="TOP"');
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_236 ),cattributes=>'VALIGN="TOP"');
     if c2rec.completed <> 'COMPLETE'
      then
       htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_237 ),cattributes=>'VALIGN="TOP"');
     end if;
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_398 ),cattributes=>'VALIGN="TOP"');
     htp.tabledata( htf.formsubmit( 'ACTION', 'Draft Invoice' ),cattributes=>'VALIGN="TOP"');
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_234 ),cattributes=>'VALIGN="TOP"');
   end if;
   htp.formclose;
 end if;

 search( surl, 'INVOICES', nrid, samerow=>TRUE );
 htp.tablerowclose;
 htp.tableclose;
 -- display_report( surl, owner_id, 'REPORT C','Invoicing',c2rec.invoiceno);
 -- display_report( surl, owner_id, 'REPORT C','Invoices Report',to_char(add_months(sysdate,-1),'DD-MON-YYY'),to_char(sysdate,'DD-MON-YYY'));
 -- display_report( surl, owner_id, 'REPORT C','Charges Report',substr(c2rec.invoiceno,3,10),substr(c2rec.invoiceno,3,10),substr(c2rec.invoiceno,1,2));
 -- display_report( surl, owner_id, 'REPORT C','Seafreight Statistics',c2rec.invoiceno);
 -- display_report( surl, owner_id, 'REPORT C','Airfreight Statistics',to_char(add_months(sysdate,-1),'DD-MON-YYY'),to_char(sysdate,'DD-MON-YYY'));
-- open c5( c2rec.invoiceno );
-- fetch c5 into c5rec;
-- close c5;
 -- display_report( surl, owner_id, 'REPORT C','GST Rebate - All Codes',to_char(add_months(sysdate,-1),'DD-MON-YYY'),to_char(sysdate,'DD-MON-YYY'),c5rec.cust_customer_id);
 -- display_report( surl, owner_id, 'REPORT C','GST Rebate - Net Only',c2rec.invoiceno);

 if seclevel = 'LEVEL 7'
  then
   download_gl( surl, rid, scid, call_name, parm, access_id, c1rec, vste, pfx, vaccess );
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'INV',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end inv;

procedure download_gl(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, cusrec in customer_account%ROWTYPE, vste in varchar2, pfx in THEME%ROWTYPE, vaccess in varchar2 )
as
-- cursor c1 is select * from all_jobs where upper(what) like 'STRANGP.DO_DOWNLOAD_GL%';
 cursor c1 is select * from all_scheduler_jobs where upper(job_name) like '%DO_DOWNLOAD_GL%';
 cursor c2( cd varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = 'SYD';
 c1rec  c1%ROWTYPE;
 c2rec  c2%ROWTYPE;
begin

 htp.line;
 htp.bold( 'Invoice Download Control' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
    htp.tabledata( htf.bold('Manual Run'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3"');
  htp.tablerowclose;
  htp.formopen( 'strangp.do_download_gl' );
   open c2( 'INVOICE_INTERFACE_DIRECTORY' );
   fetch c2 into c2rec;
   close c2;
  htp.tablerowopen;
    htp.tabledata( htf.bold('Directory'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formhidden( 'RUN_ONCE', 'T' ) ||
                   htf.formtext('VDIR', 40, 100, c2rec.description ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
   c2rec.description := NULL;
   open c2( 'INVOICE_INTERFACE_FILENAME' );
   fetch c2 into c2rec;
   close c2;
  htp.tablerowopen;
    htp.tabledata( htf.bold('File Name'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext('FNAME', 40, 100, c2rec.description ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold('From Invoice Date'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext('FRM', 30, 100, to_char(sysdate,'DD-Mon-YYYY') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( htf.bold('To Invoice Date'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formtext('FTO', 30, 100, to_char(sysdate,'DD-Mon-YYYY') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.formsubmit( null, 'Manual Run'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.formclose;

  htp.tablerowopen;
    htp.tabledata( htf.bold('Batch Run Details'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3"');
  htp.tablerowclose;
  open c1;
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
   -- htp.tablerowopen;
   --   htp.tabledata( htf.bold('Job Number'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   --   htp.tabledata( htf.bold(c1rec.job), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   -- htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold('Name'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.bold(c1rec.job_name), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold('Next Run at'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.bold(to_char(c1rec.next_run_date,'DD Mon YYYY HH24:MI')), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( htf.bold('Frequency'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.p('<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
      if c1rec.repeat_interval like '%BYDAY%'
       then
        htp.bold(regexp_replace(c1rec.repeat_interval, '^(.+)(BYDAY=)([^;]*)(;)(.+)', '\3')); htp.nl;
      end if;
      if c1rec.repeat_interval like '%BYHOUR%'
       then
        htp.bold(replace(regexp_replace(c1rec.repeat_interval, '^(.+)(BYHOUR=)([^;]*)(;)(.+)', '\3'), ',', ':00, ') || ':00');
      end if;
      htp.p('</TD>');
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
--      htp.tabledata( htf.formopen( 'strangp.stop_batch_job' ) || htf.formsubmit( null, 'Stop Batch Job' ) || htf.formclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=""');
    htp.formopen( 'strangp.stop_batch_job' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'SCID', scid );
    htp.formhidden( 'PARM', parm );
    htp.formhidden( 'ACCESS_ID', access_id );
    htp.formhidden( 'RID', rid );

    htp.tabledata( htf.formsubmit( null, 'Stop Batch Job' ) || htf.formclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=""');
    htp.tablerowclose;
   else
    close c1;
    htp.tablerowopen;
      htp.tabledata( htf.bold('No Job is on the Queue'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN="2"');
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
--      htp.tabledata( htf.formopen( 'strangp.start_batch_job' ) || htf.formsubmit( null, 'Start Batch Job' ) || htf.formclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.formopen( 'strangp.start_batch_job' );
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'SCID', scid );
    htp.formhidden( 'PARM', parm );
    htp.formhidden( 'ACCESS_ID', access_id );
    htp.formhidden( 'RID', rid );

    htp.tabledata( htf.formsubmit( null, 'Start Batch Job' ) || htf.formclose, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN=""');
    htp.tablerowclose;
  end if;
 htp.tableclose;

end download_gl;

procedure do_download_gl( vdir in varchar2 default null, fname in varchar2 default null, frm in varchar2 default null, fto in varchar2 default null, run_once in char default 'F' )
as

 cursor c1( cd varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = 'SYD';
 cursor c2( frm date, fto date ) is
  select *
  from strang.unload_strang
  where ((frm is null) or (frm is not null and invdate >= frm)) and
        ((fto is null) or (fto is not null and invdate <= fto));

 c2rec  c2%ROWTYPE;
 frec   boolean;
 fl     utl_file.file_type;
 dr     varchar2(1000);
 fn     varchar2(1000);
 bfr    varchar2(32767);
 sd     date;
 tm     varchar2(100);
 tmp    varchar2(100);
 tmn    integer;
 jb     number;
 ctr    integer;

begin
 if vdir is null
  then
   open c1( 'INVOICE_INTERFACE_DIRECTORY' );
   fetch c1 into dr;
   close c1;
  else
   dr := vdir;
 end if;

 if fname is null
  then
   open c1( 'INVOICE_INTERFACE_FILENAME' );
   fetch c1 into fn;
   close c1;
  else
   fn := fname;
 end if;

 sd := sysdate;
 fn := fn || to_char(sd,'DD_MON_YYYY_HH24_MI' ) || '.csv';

 open c2(to_date(frm,'DD-Mon-YYYY'), to_date(fto,'DD-Mon-YYYY') + (99999/100000));
 fetch c2 into c2rec;
  frec := c2%FOUND;
 close c2;

 ctr := 0;
 if frec
  then
   begin
    fl := utl_file.fopen( dr, fn, 'w', 32767 );
   exception
    when others then
     htp.htmlopen;
      htp.header(2,'Unload Could not Run' );
      htp.header(3,'File could not be created:' || dr || '\' || fn );
      htp.nl;
      htp.header(4,'Hit Back Button to return to previous screen and try again.' );
     htp.htmlclose;
     return;
   end;

   for c2rec in c2(to_date(frm,'DD-Mon-YYYY'), to_date(fto,'DD-Mon-YYYY') + (99999/100000)) loop
    if c2rec.total < 0 then
      tmp:= 'C' ;
   else
     tmp:= 'I' ;
   end if;
    bfr := '"' || tmp || '",' ||
         '"' ||
         c2rec.debtor_branch || '","' ||
         c2rec.debtor_code || '","' ||
--         to_char(c2rec.invdate,'DD-MON-YYYY') || '","' ||
         to_char(c2rec.invdate,'DDMMYYYY') || '","' ||
         c2rec.invoiceno || '",' ||
         c2rec.total || ',' ||
         c2rec.gst || ',"' ||
         c2rec.job_branch || '","' ||
--         c2rec.profit_centre || '","' ||
         c2rec.job_code || '","' ||
         c2rec.cost_centre || '","' ||
         c2rec.transaction_type || '","' ||
         substr(trim(replace(replace(replace(c2rec.invdesc,chr(13),' '),chr(10),' '),chr(11),' ')),1,60) || '"' ;

    utl_file.put_line( fl, bfr );
    ctr := ctr + 1;
   end loop;
   utl_file.fclose( fl );

   -- Update invoice to indicate unloaded
   update strang.invoices
    set
     transfer_date = sd
   where
    (invoiceno,invdate) in
    (select invoiceno,invdate
     from strang.unload_strang
    where ((frm is null) or (frm is not null and invdate >= to_date(frm,'DD-Mon-YYYY'))) and
           ((fto is null) or (fto is not null and invdate <= to_date(fto,'DD-Mon-YYYY') + (99999/100000)))
    );

   commit;
 end if;

 if run_once = 'T'
  then
   htp.htmlopen;
    htp.header(2,'Unload has run.' );
    if ctr = 0
     then
      htp.header( 3, 'No Rows Unloaded.' );
     else
      htp.header( 3, '# Rows Unloaded: ' || ctr );
    end if;
    htp.header(3,'Check output in file:' || dr || '\' || fn );
    htp.nl;
    htp.header(4,'Hit Back Button to return to previous screen' );
   htp.htmlclose;
   return;
 end if;

 /* Remove - not needed for dbms_scheduler
 -- Resubmit
 open c1( 'INVOICE_INTERFACE_FREQUENCY' );
 fetch c1 into tm;
 close c1;
 begin tmn := to_number(tm); exception when others then tmn := null; end;
 tmn := nvl(tmn,24);

 dbms_job.submit( jb, 'strangp.do_download_gl;', sysdate + (tmn/24) );
 */

exception
 when others then
 glbx.error_details( 'STRANGP', 'DO_DOWNLOAD_GL',null,null,errmsg=>sqlerrm);
end do_download_gl;
/*
procedure start_batch_job
as
 cursor c1( cd varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = 'SYD';
 jb	number;
 tm	varchar2(100);
 tmn	integer;
begin

 -- Resubmit
 open c1( 'INVOICE_INTERFACE_FREQUENCY' );
 fetch c1 into tm;
 close c1;
 begin tmn := to_number(tm); exception when others then tmn := null; end;
 tmn := nvl(tmn,24);
 dbms_job.submit( jb, 'strangp.do_download_gl;', sysdate + (tmn/24) );
   htp.htmlopen;
    htp.header( 2,'Job Started' );
    htp.header( 2,'Click Back Button to go back' );
   htp.htmlclose;

exception
 when others then
 glbx.error_details( 'STRANGP', 'START_BATCH_JOB',null,null,errmsg=>sqlerrm);
end start_batch_job;

procedure stop_batch_job
as
 cursor c1 is select * from all_jobs where upper(what) like 'STRANGP.DO_DOWNLOAD_GL%';
 c1rec  c1%ROWTYPE;
begin
 open c1;
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   dbms_job.remove(c1rec.job);
   htp.htmlopen;
    htp.header( 2,'Job Stopped' );
    htp.header( 2,'Click Back Button to go back' );
   htp.htmlclose;
   return;
 end if;
 close c1;
 htp.htmlopen;
  htp.header( 2,'Job is not running' );
  htp.header( 2,'Click Back Button to go back' );
 htp.htmlclose;

exception
 when others then
 glbx.error_details( 'STRANGP', 'STOP_BATCH_JOB',null,null,errmsg=>sqlerrm);
end stop_batch_job;
*/

procedure start_batch_job(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null )
as
 cursor c1( cd varchar2 ) is select description from strang.lov where lov_name = 'CONTROLS' and code = cd and cola = 'SYD';
 jb	number;
 tm	varchar2(1000);

begin

 -- Resubmit
 open c1( 'INVOICE_INTERFACE_FREQUENCY' );
 fetch c1 into tm;
 close c1;

 dbms_scheduler.create_job(  job_name=> 'do_download_gl'
                           , job_type=> 'STORED_PROCEDURE'
                           , job_action=> 'strangp.do_download_gl'
                           , repeat_interval=> 'FREQ=' || tm
                           , number_of_arguments=> 0
                           , enabled=> TRUE
                           , comments=> 'Invoice Download'
                          )
;

inv( surl, rid, scid, null, parm, access_id, 'Batch Job Started');
--   htp.htmlopen;
--    htp.header( 2,'Job Started' );
--    htp.header( 2,'Click Back Button to go back' );
--   htp.htmlclose;

exception
 when others then
 glbx.error_details( 'STRANGP', 'START_BATCH_JOB',null,null,errmsg=>sqlerrm);
end start_batch_job;

procedure stop_batch_job(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null )
as
 cursor c1 is select * from all_scheduler_jobs where upper(job_name) like '%DO_DOWNLOAD_GL%';
 c1rec  c1%ROWTYPE;
begin
 open c1;
 fetch c1 into c1rec;
 if c1%FOUND
  then
   close c1;
   dbms_scheduler.drop_job(c1rec.job_name);
   inv( surl, rid, scid, null, parm, access_id, 'Batch Job Stopped');
--   htp.htmlopen;
--    htp.header( 2,'Job Stopped' );
--    htp.header( 2,'Click Back Button to go back' );
--   htp.htmlclose;
   return;
 end if;
 close c1;

 inv( surl, rid, scid, null, parm, access_id, 'Batch Job is not Running');

-- htp.htmlopen;
--  htp.header( 2,'Job is not running' );
--  htp.header( 2,'Click Back Button to go back' );
-- htp.htmlclose;

exception
 when others then
 glbx.error_details( 'STRANGP', 'STOP_BATCH_JOB',null,null,errmsg=>sqlerrm);
end stop_batch_job;

procedure accept_inv( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                      p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2, p8 in varchar2,
                      p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, psts in varchar2,
                      r0 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY, r6 in GLBX.MYARRAY, r7 in GLBX.MYARRAY,
                      g0 in GLBX.MYARRAY, g1 in GLBX.MYARRAY, g2 in GLBX.MYARRAY, g3 in GLBX.MYARRAY, g4 in GLBX.MYARRAY, g5 in GLBX.MYARRAY, g6 in GLBX.MYARRAY)
as

 cursor c1(invnmb varchar2) is select 'x' tot from strang.invoices where invoiceno = invnmb;
 cursor c2(rid rowid) is select invoiceno from strang.invoices where rowid = rid;
 cursor c3(cde varchar2, nmb1 number, nmb2 number)
  is
  select decode(colb,LNGS.STR_TXT_366,0,
                     LNGS.STR_TXT_367,(nmb1*nmb2) - ((100 * (nmb1*nmb2)) / (100 + nvl(cola,0) )),
                     LNGS.STR_TXT_368,(nmb1*nmb2) * ((nvl(to_number(cola),0))/100) ) subgst,
         decode(colb,LNGS.STR_TXT_366,(nmb1*nmb2),
                     LNGS.STR_TXT_367,(nmb1*nmb2),
                     LNGS.STR_TXT_368,(nmb1*nmb2) + ((nmb1*nmb2) * ((nvl(to_number(cola),0))/100)) ) newtotal
  from strang.lov
  where lov_name = 'GSTCODES' and
        code = cde;
 cursor c4(cde varchar2 ) is select * from strang.charges where chargecode = cde;
 cursor c5(inv1 varchar2, cge2 varchar2 ) is select 'x' ex from strang.invcharges where inv_invoiceno = inv1 and cge_chargecode = cge2;
 cursor c6(inv varchar2) is select nvl(max(recno),0)+1 nmb from strang.general_ledger where invoiceno = inv;
 cursor c7(lname varchar2, cd varchar2) is select cola from strang.lov where lov_name = lname and code = cd;
 cursor c8(invc varchar2) is
   select decode(nvl(i.gstc_gstcode,'EX'), 'EX', c.sales_costcentre_no_gst, c.sales_costcentre_gst) tt,
         c.costs_costcentre,
         sum( ((cgrate*quantity)+gst) ) sm,
         sum( gst ) sgst
    from strang.charges c, strang.invcharges i, strang.invoices inv
    where c.chargecode = i.cge_chargecode and
          inv.invoiceno = i.inv_invoiceno and
          inv.invoiceno = invc
    group by decode(nvl(i.gstc_gstcode,'EX'), 'EX', c.sales_costcentre_no_gst, c.sales_costcentre_gst), c.costs_costcentre;
 cursor c9(invc varchar2) is
   select c.costs_costcentre tt
    from strang.charges c, strang.invcharges i, strang.invoices inv
    where c.chargecode = i.cge_chargecode and
          inv.invoiceno = i.inv_invoiceno and
          inv.invoiceno = invc
    group by c.costs_costcentre;
 cursor c10(invc varchar2) is select status from strang.invoices where invoiceno=invc;
 cursor c11(invc varchar2, trtyp varchar2) is select sum(total) from strang.general_ledger where invoiceno=invc and transaction_type=trtyp;
 cursor c12( invno varchar2 ) is select cgrate, quantity, gst from strang.invcharges where inv_invoiceno = invno order by cge_chargecode;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c12rec		c12%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 pfx		THEME%ROWTYPE;
 newrid		rowid;
 sts		varchar2(100);
 nmb1		number;
 nmb2		number;
 nmb3s		number;
 nmb3t		number;
 nmb4		integer;
 rc		integer;
 dt1		date;
 err		boolean;
 prdone		char(1);
 vp8		varchar2(4000);
 vmsg		varchar2(1000);
 totsales	number;
 totchrg	number;
 ttl1		number;
 prev_status	varchar2(14);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_SHP' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 if action = LNGS.STR_TXT_234 and access_id <> 'z'
  then
   inv(surl,null,scid,null,parm,'z',LNGS.STR_TXT_234 );
   return;
 end if;

 if action = LNGS.STR_TXT_235
  then
   open c2(chartorowid( replace(rid,'~','+') ));
   fetch c2 into c2rec;
   close c2;
   open c10(c2rec.invoiceno);
   fetch c10 into prev_status;
   close c10;
 end if;

 if action = LNGS.STR_TXT_398
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
   invoke_report(surl,repname=>'Invoice',r1=>c2rec.invoiceno,r2=>'Y',r3=>NULL);
   return;
 end if;

 if action = 'Draft Invoice'
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
   invoke_report(surl,repname=>'draft_invoice',r1=>c2rec.invoiceno,r2=>'Y',r3=>NULL);
   return;
 end if;

 vmsg := NULL;
 begin dt1 := to_date(p3,LNGS.STR_DATE_02); exception when others then inv( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_152 || ':' || p3 || ' ' || LNGS.STR_TXT_153 || ':' || LNGS.STR_DATE_02 ); return; end;
 if p1 is null and access_id = 'z'
  then
    inv( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_238 );
    return;
 end if;
 if p2 is null and access_id = 'z'
  then
    inv( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_239 );
    return;
 end if;
 if p3 is null and access_id = 'z'
  then
    inv( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_240 );
    return;
 end if;

 if action = LNGS.STR_TXT_400 -- Confirm Deletion of this Invoice
  then
   update strang.movements set invoiceno = null where invoiceno = (select invoiceno from strang.invoices where rowid = chartorowid( replace(rid,'~','+') ));
   delete from strang.invcharges where inv_invoiceno = (select invoiceno from strang.invoices where rowid = chartorowid( replace(rid,'~','+') ));
   delete from strang.general_ledger where invoiceno = (select invoiceno from strang.invoices where rowid = chartorowid( replace(rid,'~','+') ));
   delete from strang.invoices where rowid = chartorowid( replace(rid,'~','+') );
   insert into strang.invdels(invoiceno,invdate,deldate) values (p1,dt1,sysdate);
   commit;
   inv(surl,null,scid,null,parm,'z',LNGS.STR_TXT_401);
   return;

 elsif action = LNGS.STR_TXT_237 -- Delete Invoice
  then
    cusrec := glbx.get_aid( owner_id, 'C', ltype );
    pfx := glbx.get_thm( cusrec.theme_name );
    open c2(replace(rid,'~','+'));
    fetch c2 into c2rec;
    close c2;
    glbx.main_title( surl, LNGS.STR_TXT_400 || ' : ' || c2rec.invoiceno,glbx.backimg(surl,cusrec.aid,pfx.text_back,cusrec.background_img,ltype),helpid=>'STR12',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
    htp.formopen( 'strangp.accept_inv' );
    htp.p( '<CENTER>' );
    htp.nl;
    htp.nl;
    htp.nl;
    htp.formhidden( 'SURL', surl );
    htp.formhidden( 'SCID', scid );
    htp.formhidden( 'PARM', parm );
    htp.formhidden( 'ACCESS_ID', access_id );
    htp.formhidden( 'RID', replace(rid,'~','+') );
    htp.formhidden( 'P1', p1 );
    htp.formhidden( 'P2', p2 );
    htp.formhidden( 'P3', p3 );
    htp.formhidden( 'P4', p4 );
    htp.formhidden( 'P5', p5 );
    htp.formhidden( 'P6', p6 );
    htp.formhidden( 'P7', p7 );
    htp.formhidden( 'P8', p8 );
    htp.formhidden( 'P9', p9 );
    htp.formhidden( 'P10', p10 );
    htp.formhidden( 'P11', p11 );
    htp.formhidden( 'P12', p12 );
    htp.formhidden( 'PSTS', psts );
    for j in r0.first..r0.last loop
     htp.formhidden( 'R0', r0(j) );
    end loop;
    for j in r1.first..r1.last loop
     htp.formhidden( 'R1', r1(j) );
    end loop;
    for j in r2.first..r2.last loop
     htp.formhidden( 'R2', r2(j) );
    end loop;
    for j in r3.first..r3.last loop
     htp.formhidden( 'R3', r3(j) );
    end loop;
    for j in r4.first..r4.last loop
     htp.formhidden( 'R4', r4(j) );
    end loop;
    for j in r5.first..r5.last loop
     htp.formhidden( 'R5', r5(j) );
    end loop;
    for j in r6.first..r6.last loop
     htp.formhidden( 'R6', r6(j) );
    end loop;
    for j in r7.first..r7.last loop
     htp.formhidden( 'R7', r7(j) );
    end loop;
    for j in g0.first..g0.last loop
     htp.formhidden( 'G0', g0(j) );
    end loop;
    for j in g1.first..g1.last loop
     htp.formhidden( 'G1', g1(j) );
    end loop;
    for j in g2.first..g2.last loop
     htp.formhidden( 'G2', g2(j) );
    end loop;
    for j in g3.first..g3.last loop
     htp.formhidden( 'G3', g3(j) );
    end loop;
    for j in g4.first..g4.last loop
     htp.formhidden( 'G4', g4(j) );
    end loop;
    for j in g5.first..g5.last loop
     htp.formhidden( 'G5', g5(j) );
    end loop;
    for j in g6.first..g6.last loop
     htp.formhidden( 'g6', g6(j) );
    end loop;
    htp.formsubmit( 'ACTION', LNGS.STR_TXT_400 );
    htp.formclose;
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;
 end if;

 vp8 := substr(p8,1,4000);
 if access_id = 'z'
  then
   open c1(p1);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     inv( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_241 || ':' || p1 );
     return;
   end if;
   close c1;
   insert into strang.invoices(invoiceno,ctrk_contract,invdate,completed,billingmonth,billingyear,owner,invdesc,gstinclusive,job_branch,debtor_branch,debtor_code,job_code,status) values
    (p1,p2,dt1,p4,p5,p6,p7,vp8,'Y',p9,p10,p11,nvl(p12,p1),psts)
    returning rowid into newrid; -- Added change to use invoice no instead of x.
   if p12 is null then vmsg := 'Job Code must have a value'; end if;
  else
   update strang.invoices
    set
     ctrk_contract = p2,
     invdate = nvl(dt1,invdate),
     completed = p4,
     billingmonth = p5,
     billingyear = p6,
     owner = p7,
     invdesc = vp8,
     job_branch = p9,
     debtor_branch = p10,
     debtor_code = p11,
     job_code = nvl(p12,job_code),
     status = psts
   where
    rowid = chartorowid( replace(rid,'~','+') );
   if p12 is null then vmsg := 'Job Code must have a value'; end if;
   if dt1 is null then vmsg := vmsg || ' ' || 'Inv Date must have a value'; end if;
   open c2(chartorowid( replace(rid,'~','+') ));
   fetch c2 into c2rec;
   close c2;
   if c2rec.invoiceno <> p1
    then
     open c1(p1);
     fetch c1 into c1rec;
     if c1%FOUND
      then
       close c1;
       rollback;
       inv( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_241 || ':' || p1 || ' ' || vmsg);
       return;
      end if;
     close c1;
     -- Cascade Update
     update strang.invcharges set inv_invoiceno = p1 where inv_invoiceno = c2rec.invoiceno;
     update strang.invdels set invoiceno = p1 where invoiceno = c2rec.invoiceno;
     update strang.movements set invoiceno = p1 where invoiceno = c2rec.invoiceno;
     update strang.invoices set invoiceno = p1 where rowid = chartorowid( replace(rid,'~','+') );
   end if;
 end if;

 for j in r0.first..r0.last loop
   begin nmb1 := to_number( r3(j) ); exception when others then nmb1 := null; end;
   begin nmb2 := to_number( r5(j) ); exception when others then nmb2 := null; end;
   nmb2 := nvl(nmb2,1);
   open c3(r6(j),nmb1,nmb2);
   fetch c3 into nmb3s,nmb3t;
   if c3%NOTFOUND then nmb3s := 0; end if;
   close c3;
   if r0(j) is null
   then
    -- Insert
    if r1(j) is not null
     then
     open c4( r1(j) );
     fetch c4 into c4rec;
     close c4;
     open c3(c4rec.gstc_gstcode,c4rec.rate,nmb2);
     fetch c3 into nmb3s,nmb3t;
     close c3;
     open c5(p1,c4rec.chargecode);
     fetch c5 into c5rec;
     if c5%FOUND
      then
       close c5;
      else
       close c5;
       insert into strang.invcharges(inv_invoiceno,quantity,cgunit,cgdesc,cge_chargecode,cgrate,gstc_gstcode,gst) values
       (p1,nmb2,c4rec.unit_unitused,nvl(c4rec.chargedesc,LNGS.STR_TXT_242),c4rec.chargecode,c4rec.rate,c4rec.gstc_gstcode,nmb3s);
     end if;
    end if;
   else
    -- Update
    if r1(j) = r0(j)
     then
      update strang.invcharges
       set
        quantity = nmb2,
        cgunit = r4(j),
        cgdesc = nvl(r2(j),LNGS.STR_TXT_242),
        cgrate = nmb1,
        gstc_gstcode = r6(j),
        gst = nmb3s
      where inv_invoiceno = p1 and
            cge_chargecode = r1(j);
     else
      update strang.invcharges
       set
        cge_chargecode = r1(j),
        quantity = nmb2,
        cgunit = r4(j),
        cgdesc = nvl(r2(j),LNGS.STR_TXT_242),
        cgrate = nmb1,
        gstc_gstcode = r6(j),
        gst = nmb3s
      where inv_invoiceno = p1 and
            cge_chargecode = r0(j);
    end if;
  end if;
 end loop;

 prdone := 'T';
 for j in g0.first..g0.last loop
-- glbx.dbg( 'X:' || g0.first || '-' || g0.last || ':' || j );

   begin
    nmb1 := to_number( g4(j) );
   exception when others then
    begin
     nmb1 := to_number( g4(j),LNGS.MONEY_FORMAT );
    exception when others then
     begin
      nmb1 := to_number( g4(j),LNGS.MONEY_FORMAT2 );
     exception when others then
      vmsg := vmsg || htf.nl || 'General Ledger line ' || j || ' "Total" incorrect money format: ' || g4(j);
      nmb1 := 0;
     end;
    end;
   end;
   begin nmb2 := to_number( g5(j) );
   exception when others then
    begin
     nmb2 := to_number( g5(j),LNGS.MONEY_FORMAT );
    exception when others then
     begin
      nmb2 := to_number( g5(j),LNGS.MONEY_FORMAT2 );
     exception when others then
      vmsg := vmsg || htf.nl || 'General Ledger line ' || j || ' "GST" incorrect money format: ' || g5(j);
      nmb2 := 0;
     end;
    end;
   end;
   nmb2 := nvl(nmb2,0);

   err := FALSE;
   if g3(j) is not null and g1(j) is not null
    then
     open c7('COST_CENTRE',g3(j));
     fetch c7 into c7rec;
     close c7;
   end if;
   if c7rec.cola is not null and g3(j) is not null
    then
     if g1(j) <> c7rec.cola
      then
       -- error
       err := TRUE;
       if vmsg is not null then vmsg := vmsg || htf.nl; end if;
       vmsg := vmsg || 'Cost Centre not correct for Transaction Type';
     end if;
   end if;

   if err
    then
     null;
   elsif g0(j) is null
    then

     -- Modified to remove profit centre
     if g3(j) is not null and nmb1 is not null
      then
       open c6( p1 );
       fetch c6 into nmb4;
       close c6;
       if g1(j) = 'C' then nmb2 := 0; end if;
       insert into strang.general_ledger(invoiceno,recno,transaction_type,cost_centre,total,gst) values
        (p1,nmb4,g1(j),g3(j),nmb1,nmb2);
     --elsif g2(j) is not null and g3(j) is null
   --  elsif g3(j) is null
   --   then
   --    if vmsg is not null then vmsg := vmsg || htf.nl; end if;
   --    vmsg := vmsg || 'Cost Centre not entered';
     --elsif g2(j) is null and g3(j) is not null
     -- then
     --  if vmsg is not null then vmsg := vmsg || htf.nl; end if;
     --  vmsg := vmsg || 'PROFIT CENTRE/S NEED TO BE ENTERED';
     --  prdone := 'F';
     end if;

    else

     if g1(j) = 'C' then nmb2 := 0; end if;
     update strang.general_ledger
      set
       transaction_type = g1(j),
       -- profit_centre = g2(j),
       cost_centre = g3(j),
       total = nmb1,
       gst = nmb2
     where invoiceno = p1 and
           recno = g0(j);
   end if;
 end loop;

 for j in r7.first..r7.last loop
  if r7(j) is not null
   then
    delete from strang.invcharges where rowid = chartorowid( r7(j) );
  end if;
 end loop;

 for j in g6.first..g6.last loop
  if g6(j) is not null
   then
    delete from strang.general_ledger where rowid = chartorowid( g6(j) );
  end if;
 end loop;

 if action = 'Populate GL'
  then
   delete from strang.general_ledger
    where invoiceno = p1;
   rc := 0;
   for c8rec in c8(p1) loop
    rc := rc + 1;
    insert into strang.general_ledger(invoiceno,recno,transaction_type,profit_centre,cost_centre,total,gst) values
     (p1, rc, 'S', 'X', nvl(c8rec.tt,'X'), nvl(c8rec.sm,0), nvl(c8rec.sgst,0) );
   end loop;
   for c9rec in c9(p1) loop
    rc := rc + 1;
    insert into strang.general_ledger(invoiceno,recno,transaction_type,profit_centre,cost_centre,total,gst) values
     (p1, rc, 'C', 'X', nvl(c9rec.tt,'X'), 0, 0 );
   end loop;

   -- Change status to complete automatically
   update strang.invoices
    set
     completed = decode(prdone,'T','COMPLETE',completed)
   where
    rowid = chartorowid( replace(rid,'~','+') );

 end if;

 if action = LNGS.STR_TXT_235 and    -- Update Invoice ?
    psts = 'GL COMPLETE' and         -- Status changing from GL INCOMPLETE to GL COMPLETE
    prev_status = 'GL INCOMPLETE'
  then
   open c11(c2rec.invoiceno, 'C');
   fetch c11  into totchrg;
   close c11;
   open c11(c2rec.invoiceno, 'S');
   fetch c11 into totsales;
   close c11;
   ttl1 := 0;
   for c12rec in c12(c2rec.invoiceno) loop
     ttl1 := ttl1 + round(nvl(c12rec.cgrate*c12rec.quantity+c12rec.gst,0), 2);
   end loop;
   ttl1 := round(ttl1,2);
   if totchrg > totsales or
      totsales <> ttl1
    then
     if totchrg > totsales
      then
       vmsg := 'GL COSTS CANNOT EXCEED SALES';
     end if;
     if totsales <> ttl1
      then
       vmsg := vmsg || '<BR>SALES TOTAL (' || totsales  || ') MUST EQUAL TOTAL INVOICE VALUE (' || ttl1 || ')';
     end if;
     update strang.invoices set status = 'GL INCOMPLETE' where rowid = chartorowid( replace(rid,'~','+') );
   else
     update strang.invoices set invdate=sysdate where rowid = chartorowid( replace(rid,'~','+') );
   end if;
 end if;

 commit;

 if access_id = 'z'
  then
   inv( surl, newrid, scid, null, parm, 'x', nvl(vmsg,LNGS.STR_TXT_243) );
  else
   if action in (LNGS.STR_TXT_235, 'Populate GL')
    then
     inv( surl, rid, scid, null, parm, access_id, nvl(vmsg,LNGS.STR_TXT_161) );
    else
     inv2( surl, rid, scid, null, parm, access_id, nvl(vmsg,LNGS.STR_TXT_161) );
    end if;
 end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_INV',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_inv;

procedure inv2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.invoices where rowid = rid;
 cursor c3( invno varchar2 ) is select rowid,movement_no,seal,movement_type from strang.movements where invoiceno = invno;
 cursor c4( mtype varchar2 ) is select rowid,movement_no,seal from strang.movements where invoiceno is null and movement_type = mtype order by 2, 3;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 mn		char(3);
 ttl1		number;
 ttl2		number;
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.INV2' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'INVOICING', rid );

 glbx.main_title( surl, LNGS.STR_TXT_236,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR13',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '<CENTER>' );
  if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 open c2(replace(rid,'~','+'));
 fetch c2 into c2rec;
 close c2;

 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_inv2' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID', replace(rid,'~','+') );
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_227),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold(c2rec.invoiceno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_172),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold(c2rec.completed),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_057),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( to_char(c2rec.weight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_058),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( to_char(c2rec.volume)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_244),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( to_char(c2rec.revton)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_245),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( to_char(c2rec.gross)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( LNGS.STR_TXT_246,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_148),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( to_char(c2rec.chargeweight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( LNGS.STR_TXT_247,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 if vaccess = 'EDIT'
  then
   if c2rec.completed = 'COMPLETE'
    then
       htp.formhidden( 'R0', null );
       htp.formhidden( 'R1', null );
       htp.formhidden( 'R2', null );
       htp.formhidden( 'R3', null );
       htp.formhidden( 'R4', null );
       htp.formhidden( 'R5', null );
   end if;
 end if;
 htp.tableopen;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_248),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_063),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_249),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold(LNGS.STR_TXT_124),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     if c2rec.completed = 'COMPLETE'
      then
       null;
      else
       htp.tabledata( htf.bold(LNGS.STR_TXT_151),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     end if;
  htp.tablerowclose;
  htp.formhidden( 'R5', null );
  for c3rec in c3( c2rec.invoiceno ) loop
  htp.tablerowopen;
   if vaccess = 'EDIT'
    then
     htp.formhidden( 'R0', rowidtochar(c3rec.rowid) );
     htp.formhidden( 'R6', c3rec.movement_type );
     if c3rec.movement_type = 'CARGO'
      then
       if c2rec.completed = 'COMPLETE'
        then
         htp.tabledata( c3rec.movement_no,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
         htp.tabledata( c3rec.seal,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext( 'R1', 15, 15, c3rec.movement_no ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
         htp.tabledata( htf.formtext( 'R2', 15, 15, c3rec.seal ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'R3', null );
       htp.formhidden( 'R4', null );
     elsif c3rec.movement_type = 'CONMOV'
      then
       htp.formhidden( 'R1', null );
       htp.formhidden( 'R2', null );
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       if c2rec.completed = 'COMPLETE'
        then
         htp.tabledata( c3rec.movement_no,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext( 'R3', 15, 15, c3rec.movement_no ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.formhidden( 'R4', null );
     elsif c3rec.movement_type = 'AIRWAY'
      then
       htp.formhidden( 'R1', null );
       htp.formhidden( 'R2', null );
       htp.formhidden( 'R3', null );
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       if c2rec.completed = 'COMPLETE'
        then
         htp.tabledata( c3rec.movement_no,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        else
         htp.tabledata( htf.formtext( 'R4', 15, 15, c3rec.movement_no ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
     end if;
     if c2rec.completed = 'COMPLETE'
      then
       null;
      else
       htp.tabledata( htf.formcheckbox( 'R5', c3rec.rowid ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
     end if;
   else
    if c3rec.movement_type = 'CARGO'
     then
      htp.tabledata( c3rec.movement_no,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.seal,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    elsif c3rec.movement_type = 'CONMOV'
     then
      htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.movement_no,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    elsif c3rec.movement_type = 'AIRWAY'
     then
      htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.movement_no,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    end if;
   end if;
  htp.tablerowclose;
  end loop;

 if c2rec.completed = 'COMPLETE' or vaccess <> 'EDIT'
  then
   null;
  else
   htp.tablerowopen;
     htp.formhidden( 'R0', null );
     htp.formhidden( 'R6', 'CARGO' );
     htp.formhidden( 'R2', null );
     htp.formhidden( 'R3', null );
     htp.formhidden( 'R4', null );
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     htp.formselectopen( 'R1' );
     htp.formselectoption( NULL );
     for c4rec in c4( 'CARGO' ) loop
      htp.formselectoption( c4rec.movement_no || '-' || c4rec.seal, cattributes=>'VALUE="' || c4rec.rowid || '"'  );
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tablerowclose;

   htp.tablerowopen;
     htp.formhidden( 'R0', null );
     htp.formhidden( 'R6', 'CONMOV' );
     htp.formhidden( 'R1', null );
     htp.formhidden( 'R2', null );
     htp.formhidden( 'R4', null );
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     htp.formselectopen( 'R3' );
     htp.formselectoption( NULL );
     for c4rec in c4( 'CONMOV' ) loop
      htp.formselectoption( c4rec.movement_no, cattributes=>'VALUE="' || c4rec.rowid || '"'  );
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tablerowclose;

   htp.tablerowopen;
     htp.formhidden( 'R0', null );
     htp.formhidden( 'R6', 'AIRWAY' );
     htp.formhidden( 'R1', null );
     htp.formhidden( 'R2', null );
     htp.formhidden( 'R3', null );
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( '&nbsp;' ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     htp.formselectopen( 'R4' );
     htp.formselectoption( NULL );
     for c4rec in c4( 'AIRWAY' ) loop
      htp.formselectoption( c4rec.movement_no, cattributes=>'VALUE="' || c4rec.rowid || '"'  );
     end loop;
     htp.formselectclose;
     htp.p( '</TD>' );
     htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tablerowclose;
 end if;
 htp.tableclose;
 htp.nl;
 if vaccess = 'EDIT'
  then
   if c2rec.completed = 'COMPLETE'
    then
     htp.formhidden( 'R0', null );
     htp.formhidden( 'R1', null );
     htp.formhidden( 'R2', null );
     htp.formhidden( 'R3', null );
     htp.formhidden( 'R4', null );
     htp.formhidden( 'R5', null );
     htp.formhidden( 'R6', null );
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_250 );
    else
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_251 );
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_252 );
   end if;
   htp.formclose;
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'INV2',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end inv2;

procedure accept_inv2( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2,
                       r0 in GLBX.MYARRAY, r1 in GLBX.MYARRAY, r2 in GLBX.MYARRAY, r3 in GLBX.MYARRAY, r4 in GLBX.MYARRAY, r5 in GLBX.MYARRAY, r6 in GLBX.MYARRAY )
as

 cursor c1(rid rowid) is select invoiceno,completed from strang.invoices where rowid = rid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 dt1		date;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_SHP' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 if action = LNGS.STR_TXT_250
  then
   inv( surl, rid, scid, null, parm, access_id, null );
   return;
 end if;

 open c1(chartorowid( replace(rid,'~','+') ));
 fetch c1 into c1rec;
 close c1;
 if c1rec.completed = 'COMPLETE'
  then
   inv( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_253 );
   return;
 end if;

 for j in r0.first..r0.last loop
  if r0(j) is null
  then
   if r6(j) = 'CARGO'
    then
     update strang.movements
      set
       invoiceno = c1rec.invoiceno
      where
       rowid = chartorowid(r1(j));
    elsif r6(j) = 'CONMOV'
     then
     update strang.movements
      set
       invoiceno = c1rec.invoiceno
      where
       rowid = chartorowid(r3(j));
    elsif r6(j) = 'AIRWAY'
     then
     update strang.movements
      set
       invoiceno = c1rec.invoiceno
      where
       rowid = chartorowid(r4(j));
   end if;
  else
   /*
   if r6(j) = 'CARGO'
    then
     update strang.movements
      set
       movement_no = r1(j),
       seal = r2(j)
      where
       rowid = chartorowid( r0(j) );
    elsif r6(j) = 'CONMOV'
     then
     update strang.movements
      set
       movement_no = r3(j)
      where
       rowid = chartorowid( r0(j) );
    elsif r6(j) = 'AIRWAY'
     then
     update strang.movements
      set
       movement_no = r4(j)
      where
       rowid = chartorowid( r0(j) );
   end if;
   */
   NULL; -- commented out at the request of Sallie
  end if;
 end loop;

 for j in r5.first..r5.last loop
  if r5(j) is not null
   then
     update strang.movements
      set
       invoiceno = null
      where
       rowid = chartorowid( r5(j) );
  end if;
 end loop;
 commit;

 update strang.invoices i
  set
   volume = (select sum(sumvolume) from strang.movements m where m.invoiceno = i.invoiceno),
   gross = (select sum(nvl(sumweight,0)+nvl(tare,0)) from strang.movements m where m.invoiceno = i.invoiceno),
   weight = (select sum(sumweight) from strang.movements m where m.invoiceno = i.invoiceno),
   revton = (select sum(revton) from strang.movements m where m.invoiceno = i.invoiceno),
   chargeweight = (select sum(chargeweight) from strang.movements m where m.invoiceno = i.invoiceno)
 where
  invoiceno = c1rec.invoiceno;

 if action = LNGS.STR_TXT_251
  then
    inv2( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_161 );
   else
    inv( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_161 );
 end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_INV2',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_inv2;

procedure edit_mawb( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, mwb in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( mwb varchar2 ) is select distinct h.mawb, h.hawb, h.value, dr.deliveryno, dr.itemno
 from strang.hawbs h, strang.detailrs dr
 where h.mawb like mwb || '%' and
 h.mawb = dr.movement_no and
 nvl(dr.camov_seal,'|') = '|' and
 h.hawb=dr.hawb_hawbno
 order by hawb;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;
 ttl1		number;
 ttl2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.EDIT_MAWB' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_254,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR14',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_edit_mawb' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'P0', mwb );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_124), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
   htp.tabledata( htf.formhidden( 'P1', mwb ) || htf.bold( mwb ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 if mwb is null
  then
   htp.formhidden( 'P2', null );
   htp.formhidden( 'P3', null );
   htp.formsubmit( null, LNGS.STR_TXT_255 );
   htp.formclose;
   htp.nl;
   htp.htmlclose;
   return;
 end if;
 htp.formhidden( 'P4', null );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_163), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_164), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_256), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_017), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   --htp.tabledata( htf.bold( LNGS.STR_TXT_151), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
  foundrec := FALSE;
  for c2rec in c2( mwb ) loop
   foundrec := TRUE;
   htp.tablerowopen;
    htp.formhidden( 'P2', c2rec.hawb );
    htp.formhidden( 'P5', c2rec.hawb );
    htp.tabledata( c2rec.deliveryno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( c2rec.itemno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( c2rec.hawb, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
--    htp.tabledata( htf.formtext( 'P3', 15, 1000, to_char(c2rec.value,LNGS.MONEY_FORMAT)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
    htp.tabledata( htf.formtext( 'P3', 15, 1000, to_char(nvl(c2rec.value,strang.f_display_po_total(c2rec.deliveryno)),LNGS.MONEY_FORMAT)), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');

    -- delete removed as requested by Strang
    htp.formhidden( 'P4', null );
    -- htp.tabledata( htf.formcheckbox( 'P4', c2rec.hawb ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tablerowclose;
  end loop;
  /*
  for j in 1..5 loop
   htp.tablerowopen;
    htp.formhidden( 'P5', null );
    htp.tabledata( htf.formtext( 'P2', 20, 1000, null), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
    htp.tabledata( htf.formtext( 'P3', 20, 1000, null), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
    --htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
   htp.tablerowclose;
  end loop;
  */
  htp.tableclose;
  if not foundrec
   then
     htp.formhidden( 'P2', null );
     htp.formhidden( 'P3', null );
     htp.formhidden( 'P4', null );
     htp.formhidden( 'P5', null );
     htp.formclose;
     htp.htmlclose;
     htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
    return;
    htp.bold( LNGS.STR_TXT_257 );
    htp.nl;
    htp.formsubmit( null, LNGS.STR_TXT_258 );
    htp.formclose;
    htp.nl;
    htp.htmlclose;
   return;
  end if;
  htp.nl;
  htp.formsubmit( null, LNGS.STR_TXT_259 );
  htp.formclose;
  htp.nl;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
  htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'EDIT_MAB',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end edit_mawb;

procedure accept_edit_mawb( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, p0 in varchar2, p1 in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		number(15,2);
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_EDIT_MAB' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if p0 is null
   then
    edit_mawb(surl, rid, scid, parm, access_id, p1 );
    return;
  end if;

  for j in p2.first..p2.last loop
   begin
    nmb := to_number(p3(j),LNGS.MONEY_FORMAT);
   exception
    when others
     then
      begin
       nmb := to_number(p3(j));
      exception
       when others then nmb := NULL;
      end;
    end;
   if p2(j) is not null
    then
     if p5(j) is null
      then
       null;
       --insert into strang.hawbs(hawb,mawb,value) values (p2(j),nvl(p0,p1),nmb);
      else
       update strang.hawbs set value = nvl(nmb,value) where hawb = p2(j) and mawb = nvl(p0,p1);
     end if;
   end if;
  end loop;

  /*
  for j in p4.first..p4.last loop
   if p4(j) is not null
    then
     delete from strang.hawbs where hawb = p4(j) and mawb = nvl(p0,p1);
   end if;
  end loop;
  */

  commit;

  edit_mawb(surl, rid, scid, parm, access_id, p1, LNGS.STR_TXT_260 );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_EDIT_MAWB',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_edit_mawb;

procedure edit_bol( surl in varchar2, rid in varchar2, rid2 in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( shpid integer) is select shipname,voy from strang.ships_airway where ship_id = shpid;

 cursor c3( shpid integer ) is
  select rowid,movement_no,seal,container_type,booking_ref, bol
  from strang.movements m
  where ship_id = shpid
  order by container_type, movement_no;

cursor c4(rid rowid) is
 select *
 from strang.movements
 where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;
 ttl1		number;
 ttl2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.EDIT_BOL' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_261,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR15',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_edit_bol' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'ACCESS_ID', access_id );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'RID2', replace(rid2,'~','+') );
 htp.formhidden( 'P0', shpid );

 open c2(shpid);
 fetch c2 into c2rec;
 close c2;
 open c4(chartorowid(replace(rid2,'~','+')));
 fetch c4 into c4rec;
 close c4;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_169), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
   htp.tabledata( htf.bold( c2rec.shipname), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( c2rec.voy), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.formhidden( 'P1', shpid );
   -- htp.tabledata( htf.anchor2( 'strangp.edit_bol?surl=' || surl || '&rid=' || translate(rid,'+ ','~+') || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&shpid=' || shpid,'List of Ships',ctarget=>'HAWB'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_248), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_063), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Cargo Type'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Booking Reference'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_143), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
  foundrec := FALSE;
    for c3rec in c3( shpid ) loop
     foundrec := TRUE;
     htp.tablerowopen;
     htp.formhidden( 'P2', rowidtochar( c3rec.rowid ) );
      htp.tabledata( c3rec.movement_no, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.seal, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.container_type, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formtext( 'P3a', 20, 1000, c3rec.booking_ref), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P3', 20, 1000, c3rec.bol), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
     htp.tablerowclose;
    end loop;
  htp.tableclose;
  if not foundrec
   then
    htp.formhidden( 'P2', null );
    htp.formhidden( 'P3a', null );
    htp.formhidden( 'P3', null );
    htp.nl;
    htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');
    htp.formclose;
    htp.p( '</CENTER>' );
    htp.htmlclose;
   return;
  end if;
  htp.nl;
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_263 );
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_264 );
  htp.formclose;
  if c4rec.movement_no is null
   then
    htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
   else
    htp.anchor( 'javascript: parent.opener.location = ''' || 'strangp.menu?surl=' || surl || '&rnd=' || to_char(sysdate,'SSSSS') || '&msearch=' || replace(c4rec.movement_no,' ','+') || '&mtype=' || c4rec.movement_type || '&action=SEARCH' || '''; parent.close();', LNG.GLB_TXT_033);
  end if;

  if msg is not null
   then
    glbx.header_msg( msg );
  end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'EDIT_BOL',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end edit_bol;

procedure accept_edit_bol( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3a in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_EDIT_BOL' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if p0 is null
   then
    edit_bol(surl, rid, rid2, scid, parm, access_id, p1 );
    return;
  end if;

  for j in p2.first..p2.last loop
     if p2(j) is not null
      then
       if action = LNGS.STR_TXT_263
        then
         update strang.movements set booking_ref = p3a(j) where rowid = chartorowid( p2(j) );
         update strang.movements set bol = p3(j) where rowid = chartorowid( p2(j) );
       elsif action = LNGS.STR_TXT_264
        then
         if p3(j) is null
          then
           update strang.movements set booking_ref = p3a(1) where rowid = chartorowid( p2(j) );
           update strang.movements set bol = p3(1) where rowid = chartorowid( p2(j) );
          else
           update strang.movements set booking_ref = p3a(j) where rowid = chartorowid( p2(j) );
           update strang.movements set bol = p3(j) where rowid = chartorowid( p2(j) );
         end if;
       end if;
     end if;
  end loop;

  commit;

  edit_bol(surl, rid, rid2, scid, parm, access_id, p1, LNGS.STR_TXT_265 );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_EDIT_BOL',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_edit_bol;

procedure edit_ecn( surl in varchar2, rid in varchar2, rid2 in varchar2 default null, scid in varchar2, parm in varchar2, access_id in varchar2 default null, shpid in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( shpid integer) is select shipname,voy from strang.ships_airway where ship_id = shpid;

 cursor c3( mv varchar2, sl varchar2 ) is
  select d.rowid,d.movement_no,d.camov_seal seal,deliveryno,ecn,itemno, handling_unit
  from strang.detailrs d
  where d.movement_no = mv and
        nvl(d.camov_seal,'x') = nvl(sl,'x')
  order by deliveryno;

 cursor c4( rid rowid ) is select * from strang.movements where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;
 ttl1		number;
 ttl2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.EDIT_ECN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_266,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_edit_ecn' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'ACCESS_ID', access_id );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'P0', shpid );
 htp.formhidden( 'RID2', replace(rid2,'~','+') );

 open c2(shpid);
 fetch c2 into c2rec;
 close c2;
 open c4(replace(rid,'~','+'));
 fetch c4 into c4rec;
 close c4;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_169), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
   htp.tabledata( htf.bold( c2rec.shipname), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( c2rec.voy), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.formhidden( 'P1', shpid );
   -- htp.tabledata( htf.anchor2( 'strangp.edit_bol?surl=' || surl || '&rid=' || translate(rid,'+ ','~+') || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&shpid=' || shpid,'List of Ships',ctarget=>'HAWB'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   if c4rec.movement_type = 'CARGO'
    then
     htp.tabledata( htf.bold( LNGS.STR_TXT_248), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   elsif c4rec.movement_type = 'CONMOV'
    then
     htp.tabledata( htf.bold( LNGS.STR_TXT_249), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   else
     htp.tabledata( htf.bold( LNGS.STR_TXT_066), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   end if;
   if c4rec.movement_type = 'CARGO'
    then
     htp.tabledata( htf.bold( LNGS.STR_TXT_063), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   end if;
   htp.tabledata( htf.bold( LNGS.STR_TXT_163), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_045), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_060), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Handling Unit'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
  foundrec := FALSE;
    for c3rec in c3( c4rec.movement_no, c4rec.seal ) loop
     foundrec := TRUE;
     htp.tablerowopen;
     htp.formhidden( 'P2', rowidtochar( c3rec.rowid ) );
      htp.tabledata( c3rec.movement_no, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      if c4rec.movement_type = 'CARGO'
       then
        htp.tabledata( c3rec.seal, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
      htp.tabledata( c3rec.deliveryno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.itemno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formtext( 'P3', 20, 1000, c3rec.ecn), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P3i', 20, 1000, c3rec.handling_unit), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
     htp.tablerowclose;
    end loop;
  htp.tableclose;
  if not foundrec
   then
    htp.formhidden( 'P2', null );
    htp.formhidden( 'P3', null );
    htp.formhidden( 'P3i', null );
    htp.nl;
    htp.formsubmit( null, LNGS.STR_TXT_364 );
    htp.formclose;
    htp.nl;
    htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
    htp.htmlclose;
   return;
  end if;
  htp.nl;
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_267 );
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_264 );
  htp.formclose;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'EDIT_ECN',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end edit_ecn;

procedure accept_edit_ecn( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, rid2 in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p3i in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_EDIT_ECN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if p0 is null
   then
    edit_bol(surl, rid, rid2, scid, parm, access_id, p1 );
    return;
  end if;

  for j in p2.first..p2.last loop
     if p2(j) is not null
      then
       if action = LNGS.STR_TXT_267
        then
         update strang.detailrs set ecn = p3(j) where rowid = chartorowid( p2(j) );
         update strang.detailrs set handling_unit = strang.f_sap_format(p3i(j),'HANDLING_UNIT') where rowid = chartorowid( p2(j) );
       elsif action = LNGS.STR_TXT_264
        then
         if p3(j) is null
          then
           update strang.detailrs set ecn = p3(1) where rowid = chartorowid( p2(j) );
         update strang.detailrs set handling_unit = strang.f_sap_format(p3i(j),'HANDLING_UNIT') where rowid = chartorowid( p2(j) );
          else
           update strang.detailrs set ecn = p3(j) where rowid = chartorowid( p2(j) );
         update strang.detailrs set handling_unit = strang.f_sap_format(p3i(j),'HANDLING_UNIT') where rowid = chartorowid( p2(j) );
         end if;
       end if;
     end if;
  end loop;

  commit;

  edit_ecn(surl, rid, rid2, scid, parm, access_id, p1, LNGS.STR_TXT_268 );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_EDIT_ECN',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_edit_ecn;

procedure edit_mawb_ecn( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, mwb in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( mwb varchar2 ) is
  select rowid,hawb_hawbno,deliveryno,itemno,ecn,cl,handling_unit
  from strang.detailrs
  where hawb_hawbno in (select hawb from strang.hawbs where mawb like mwb || '%')
  order by hawb_hawbno;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;
 ttl1		number;
 ttl2		number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.EDIT_MAWB_ECN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_269,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_edit_mawb_ecn' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'ACCESS_ID', access_id );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'P0', mwb );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_124), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
   --htp.tabledata( htf.formtext( 'P1', 20, 1000, mwb ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( mwb ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   -- Disabled as requested by SS
   --htp.tabledata( htf.anchor2( 'strangp.edit_mawb?surl=' || surl || '&rid=' || translate(rid,'+ ','~+') || '&parm=' || parm || '&scid=' || scid || '&access_id=' || access_id || '&mwb=' || mwb,LNGS.STR_TXT_270,ctarget=>'HAWB'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 if mwb is null
  then
   htp.formhidden( 'P1', mwb );
   htp.formhidden( 'P2', null );
   htp.formhidden( 'P3', null );
   -- htp.formsubmit( null, LNGS.STR_TXT_255 );
   htp.formclose;
   htp.nl;
   htp.htmlclose;
   return;
 end if;

 htp.formhidden( 'P1', mwb );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_066), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_163), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_164), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_060), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Handling Unit'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
  foundrec := FALSE;
    for c2rec in c2( mwb ) loop
     foundrec := TRUE;
     htp.tablerowopen;
     htp.formhidden( 'P2', rowidtochar( c2rec.rowid ) );
      htp.tabledata( c2rec.hawb_hawbno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c2rec.deliveryno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c2rec.itemno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formtext( 'P3', 20, 1000, c2rec.ecn), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P3i', 20, 1000, c2rec.handling_unit), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
     htp.tablerowclose;
    end loop;
  htp.tableclose;
  if not foundrec
   then
    htp.formhidden( 'P2', null );
    htp.formhidden( 'P3', null );
    htp.nl;
    htp.bold( LNGS.STR_TXT_257 );
    htp.formclose;
    htp.nl;
    htp.htmlclose;
   return;
  end if;
  htp.nl;
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_267 );
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_264 );
  htp.formclose;
  htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'EDIT_MAWB_ECN',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end edit_mawb_ecn;

procedure accept_edit_mawb_ecn( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, p0 in varchar2, p1 in varchar2, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p3i in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_EDIT_MAWB_ECN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if p0 is null
   then
    edit_mawb_ecn(surl, rid, scid, parm, access_id, p1 );
    return;
  end if;

  for j in p2.first..p2.last loop
     if p2(j) is not null
      then
       if action = LNGS.STR_TXT_267
        then
         update strang.detailrs set ecn = p3(j) where rowid = chartorowid( p2(j) );
         update strang.detailrs set handling_unit = strang.f_sap_format(p3i(j),'HANDLING_UNIT') where rowid = chartorowid( p2(j) );
       elsif action = LNGS.STR_TXT_264
        then
         if p3(j) is null
          then
           update strang.detailrs set ecn = p3(1) where rowid = chartorowid( p2(j) );
           update strang.detailrs set handling_unit = strang.f_sap_format(p3i(j),'HANDLING_UNIT') where rowid = chartorowid( p2(j) );
          else
           update strang.detailrs set ecn = p3(j) where rowid = chartorowid( p2(j) );
           update strang.detailrs set handling_unit = strang.f_sap_format(p3i(j),'HANDLING_UNIT') where rowid = chartorowid( p2(j) );
         end if;
       end if;
     end if;
  end loop;

  commit;

  edit_mawb_ecn(surl, rid, scid, parm, access_id, p1, LNGS.STR_TXT_268 );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_EDIT_MAWB_ECN',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_edit_mawb_ecn;

procedure assign_det( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null, fl in varchar2, lcl in varchar2 default 'F' )
as

 cursor c2( rid rowid ) is
  select seal,shipname,voy,movement_no,movement_type,complete
  from strang.movements m,strang.ships_airway sa
  where m.rowid = rid and sa.ship_id = m.ship_id;

 cursor c3( mv varchar2, mtype varchar2, sl varchar2, cd varchar2 ) is
  select rowid, deliveryno, itemno, movement_no, handling_unit
  from strang.detailrs
  where (movement_no = mv and nvl(camov_seal,'x') = nvl(sl,'x')) or
        (movement_no is null and
         ((mtype = 'CARGO' and sa = 'S' and cl = 'C') or (mtype <> 'CARGO')) and
         ((mtype = 'CONMOV' and sa = 'S' and cl = 'L') or (mtype <> 'CONMOV')) and
         ((mtype = 'AIRWAY' and sa = 'A') or (mtype <> 'AIRWAY'))
        ) and
        ((cd is null) or (cd is not null and substr(to_char(deliveryno),1,1) = cd))
  order by deliveryno,itemno;

 cursor c4( mv varchar2, cd varchar2 ) is
  select rowid, deliveryno, itemno, movement_no, handling_unit
  from strang.detailrs
  where movement_no = mv and
        ((cd is null) or (cd is not null and substr(to_char(deliveryno),1,1) = cd))
  order by deliveryno;

 cursor c10(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'SEE_ALL_DELIVERIES' and cola = vste;
 cursor c11(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'DELIVERYNO' and cola = vste;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c10rec 	c10%ROWTYPE;
 c11rec 	c11%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;
 ttl1		number;
 ttl2		number;
 cd		varchar2(10);
 vaccess	varchar2(20);
 vste		varchar2(10);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ASSIGN_DET' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 vste := customer_state(c1rec.aid);
 vaccess := data_access( owner_id, 'ASSIGN', rid );

 glbx.main_title( surl, LNGS.STR_TXT_271,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR18',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );
  if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;

 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_assign_det' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
   if fl in ('X','Y')
    then
     htp.formhidden( 'FL', 'T' );
    else
     if fl = 'Y1'
      then
       htp.formhidden( 'FL', 'F' );
      else
       htp.formhidden( 'FL', fl );
     end if;
   end if;
 end if;

 open c2( chartorowid( replace(rid,'~','+') ));
 fetch c2 into c2rec;
 close c2;
 open c10(vste);
 fetch c10 into c10rec;
 close c10;
 open c11(vste);
 fetch c11 into c11rec;
 close c11;
 if c10rec.description = 'YES' and c1rec.username <> 'DAWN' and lcl = 'F'
  then
   cd := NULL;
  else
   cd := substr(c11rec.description,1,1);
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   if c2rec.movement_type = 'CONMOV'
    then
     htp.tabledata( htf.bold( LNGS.STR_TXT_272), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
   elsif c2rec.movement_type = 'CARGO'
    then
     htp.tabledata( htf.bold( LNGS.STR_TXT_273), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
   else
     htp.tabledata( htf.bold( LNGS.STR_TXT_274), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
   end if;
   htp.tabledata( htf.bold( c2rec.movement_no ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  if c2rec.movement_type = 'CARGO'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_063), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( c2rec.seal ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
  end if;
  if c2rec.movement_type = 'AIRWAY'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_129), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( c2rec.shipname ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_275), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( c2rec.voy ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
   else
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_169), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( c2rec.shipname ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_276), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( c2rec.voy ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tablerowclose;
  end if;

 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_163), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     htp.tabledata( htf.bold( LNGS.STR_TXT_164), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     if c2rec.complete = 'F'
      then
       htp.tabledata( htf.bold( LNGS.STR_TXT_310), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
     end if;
     htp.tabledata( htf.bold( 'Handling_Unit'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
  if fl in ('T','X','Y')
   then
    for c3rec in c3( c2rec.movement_no, c2rec.movement_type, c2rec.seal, cd ) loop
     if (c2rec.complete = 'F') or (c2rec.complete <> 'F' and c3rec.movement_no is not null)
     then
     htp.tablerowopen;
       htp.tabledata( htf.bold( c3rec.deliveryno), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
       htp.tabledata( htf.bold( c3rec.itemno), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
       if c2rec.complete = 'F'
        then
         if c3rec.movement_no is null
          then
           if fl = 'X'
            then
             if vaccess = 'EDIT'
              then
               htp.tabledata( htf.formcheckbox( 'P1', c3rec.rowid, 'CHECKED' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
              else
               htp.tabledata( htf.bold( 'X' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
             end if;
            else
             if vaccess = 'EDIT'
              then
               htp.tabledata( htf.formcheckbox( 'P1', c3rec.rowid ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
              else
               htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
             end if;
            end if;
          else
           if fl = 'Y'
            then
             if vaccess = 'EDIT'
              then
               htp.tabledata( htf.formcheckbox( 'P1', c3rec.rowid ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
              else
               htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
             end if;
            else
             if vaccess = 'EDIT'
              then
               htp.tabledata( htf.formcheckbox( 'P1', c3rec.rowid, 'CHECKED' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
              else
               htp.tabledata( htf.bold( 'X' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
             end if;
           end if;
           htp.formhidden( 'P2', c3rec.rowid );
        end if;
       end if;
     htp.tabledata( htf.bold( c3rec.handling_unit), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tablerowclose;
     end if;
    end loop;
  else
    for c4rec in c4( c2rec.movement_no, cd ) loop
     htp.tablerowopen;
       htp.tabledata( htf.bold( c4rec.deliveryno), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
       htp.tabledata( htf.bold( c4rec.itemno), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
       if c2rec.complete = 'F'
        then
         if c4rec.movement_no is null
          then
           if fl = 'X'
            then
             if vaccess = 'EDIT'
              then
               htp.tabledata( htf.formcheckbox( 'P1', c4rec.rowid, 'CHECKED' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
              else
               htp.tabledata( htf.bold( 'X' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
             end if;
            else
             if vaccess = 'EDIT'
              then
               htp.tabledata( htf.formcheckbox( 'P1', c4rec.rowid ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
              else
               htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
             end if;
           end if;
          else
           if fl in ('Y','Y1')
            then
             if vaccess = 'EDIT'
              then
               htp.tabledata( htf.formcheckbox( 'P1', c4rec.rowid ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
              else
               htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
             end if;
            else
             if vaccess = 'EDIT'
              then
               htp.tabledata( htf.formcheckbox( 'P1', c4rec.rowid, 'CHECKED' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
              else
               htp.tabledata( htf.bold( 'X' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
             end if;
           end if;
           if vaccess = 'EDIT' then htp.formhidden( 'P2', c4rec.rowid ); end if;
         end if;
       end if;
     htp.tabledata( htf.bold( c4rec.handling_unit), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tablerowclose;
    end loop;
 end if;
 htp.tableclose;
 htp.nl;
 if vaccess = 'EDIT'
  then
   if fl in ('T','X','Y') and c2rec.complete = 'F'
    then
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_277 );
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_278 );
     htp.formsubmit( 'ACTION', LNGS.STR_TXT_279 );
     if c10rec.description = 'YES' and c1rec.username <> 'DAWN' and lcl = 'F'
      then
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_416 );
     elsif c10rec.description = 'YES' and c1rec.username <> 'DAWN' and lcl = 'T'
      then
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_417 );
     end if;
    --  htp.formsubmit( 'ACTION', LNGS.STR_TXT_146 );
  end if;
   htp.formclose;
 end if;
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'ASSIGN_DET',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end assign_det;

procedure accept_assign_det( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, fl in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c2( rid rowid ) is select movement_no, seal, container_type, movement_type from strang.movements m where m.rowid = rid;

 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 newrid		rowid;
 sts		varchar2(100);

 function isdel( p1 in GLBX.MYARRAY, p2 in varchar2 ) return boolean
 as
 begin
  for j in p1.first..p1.last loop
   if p1(j) = p2
    then
     return( FALSE );
   end if;
  end loop;
  return( TRUE );
 end;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_MOVEMENT' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 if action = LNGS.STR_TXT_416 then assign_det( surl, rid, scid, parm, access_id, LNGS.STR_TXT_416, fl,'T' ); return; end if;
 if action = LNGS.STR_TXT_417 then assign_det( surl, rid, scid, parm, access_id, LNGS.STR_TXT_417, fl,'F' ); return; end if;
 if action = LNGS.STR_TXT_278 then assign_det( surl, rid, scid, parm, access_id, LNGS.STR_TXT_418, 'X' ); return; end if;
 if fl = 'F'
  then
   if action = LNGS.STR_TXT_279 then assign_det( surl, rid, scid, parm, access_id, LNGS.STR_TXT_419, 'Y1' ); return; end if;
  else
   if action = LNGS.STR_TXT_279 then assign_det( surl, rid, scid, parm, access_id, LNGS.STR_TXT_419, 'Y' ); return; end if;
 end if;

 open c2( chartorowid( replace(rid,'~','+') ) );
 fetch c2 into c2rec;
 close c2;

 for j in p2.first..p2.last loop
  -- Check to see if the appropriate record can have its values set to null.
  -- If it is found in P1 it means it has been checked and is not to be deleted
  if isdel(p1,p2(j))
   then
    update strang.detailrs set movement_no = null, camov_seal = null, hawb_hawbno = null where rowid = chartorowid( p2(j) );
  end if;
 end loop;

 for j in p1.first..p1.last loop
  update strang.detailrs set movement_no = c2rec.movement_no, camov_seal = c2rec.seal where rowid = chartorowid( p1(j) );
 end loop;

 recalc_weight( c2rec.movement_no, c2rec.container_type, c2rec.seal, c2rec.movement_type );
 delete from strang.hawbs
  where
   mawb = c2rec.movement_no and
   hawb not in
    (select hawb_hawbno from strang.detailrs where movement_no = c2rec.movement_no);

 commit;

 assign_det( surl, rid, scid, parm, access_id, LNGS.STR_TXT_280, fl );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_ASSIGN_DET',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_assign_det;

function new_log_no( p1 in varchar2, vste in varchar2 )
 return varchar2
as

 cursor c1(vste varchar2) is select substr(description,1,1) code from strang.lov where lov_name = 'CONTROLS' and code = 'REGION' and cola = vste;
 cursor c2( str varchar2, sto varchar2 ) is select max(to_number(substr(logno,1,3))) nmb from strang.detailrs where substr(logno,4) = str;

 c1rec 	c1%ROWTYPE;
 c2rec 	c2%ROWTYPE;
 tmp	varchar2(20);

begin
 open c1(vste);
 fetch c1 into c1rec;
 close c1;
 tmp := '-' || c1rec.code || p1 || '/' || to_char(sysdate,'YY');
 open c2(tmp,currsite);
 fetch c2 into c2rec;
 if c2%FOUND
  then
   close c2;
   tmp := lpad(to_char(nvl(c2rec.nmb,0) + 1),3,'0') || tmp;
  else
   close c2;
   tmp := '001' || tmp;
 end if;
 update strang.lov
  set description = to_char(sysdate,LNGS.STR_DATE_02)
  where code = 'LOGNO' || p1 || '_DATE' and
        lov_name = 'CONTROLS' and
        cola = vste;
 update strang.lov
  set description = tmp
  where code = 'LOGNO' || p1 and
        lov_name = 'CONTROLS' and
        cola = vste;
 return( tmp );
end new_log_no;

procedure recalc_weight( mvid varchar2, ctrtype varchar2 default null, sl in varchar2 default null, mtype in varchar2 default null )
as

 cursor c1(mvid varchar2) is select container_type,movement_type from strang.movements where movement_no = mvid;
 cursor c1a(mvid varchar2, sl varchar2) is select container_type,movement_type from strang.movements where movement_no = mvid and seal = sl;
 cursor c2(ctr varchar2) is select colb from strang.lov where lov_name = 'CTRTYPE' and code = ctr;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;

begin
 if mvid is null then return; end if;
 if ctrtype is null
  then
   if sl is not null
    then
     open c1a(mvid,sl);
     fetch c1a into c1rec;
     close c1a;
    else
     open c1(mvid);
     fetch c1 into c1rec;
     close c1;
   end if;
  else
   c1rec.container_type := ctrtype;
 end if;

 update strang.movements
  set
   sumweight = (select sum(nvl(partweight,0)) from strang.detailrs where movement_no = mvid and nvl(camov_seal,'x') = nvl(sl,'x')),
   sumvolume = (select sum(nvl(partvolume,0)) from strang.detailrs where movement_no = mvid and nvl(camov_seal,'x') = nvl(sl,'x'))
 where
  movement_no = mvid and nvl(seal,'x') = nvl(sl,'x');

 open c2( c1rec.container_type );
 fetch c2 into c2rec;
 close c2;
 if c2rec.colb is not null
  then
   update strang.movements
    set
     revton = (select strang.revenue_tonne(sum(nvl(partweight,0)),sum(nvl(partvolume,0))) from strang.detailrs where movement_no = mvid and nvl(camov_seal,'x') = nvl(sl,'x'))
    where
      movement_no = mvid and nvl(seal,'x') = nvl(sl,'x');
  else
   update strang.movements
    set
     revton = (select sum(strang.revenue_tonne(nvl(partweight,0),nvl(partvolume,0))) from strang.detailrs where movement_no = mvid and nvl(camov_seal,'x') = nvl(sl,'x'))
    where
      movement_no = mvid and nvl(seal,'x') = nvl(sl,'x');
 end if;

 if mtype = 'AIRWAY'
  then
   update strang.movements
    set
     chargeweight = (select sum(strang.chargeable_weight(nvl(partweight,0),nvl(partvolume,0))) from strang.detailrs where movement_no = mvid and nvl(camov_seal,'x') = nvl(sl,'x'))
    where
      movement_no = mvid and nvl(seal,'x') = nvl(sl,'x');
 end if;

 update strang.invoices i
  set
   volume = (select sum(sumvolume) from strang.movements m where m.invoiceno = i.invoiceno),
   gross = (select sum(nvl(sumweight,0)+nvl(tare,0)) from strang.movements m where m.invoiceno = i.invoiceno),
   weight = (select sum(sumweight) from strang.movements m where m.invoiceno = i.invoiceno),
   revton = (select sum(revton) from strang.movements m where m.invoiceno = i.invoiceno),
   chargeweight = (select sum(chargeweight) from strang.movements m where m.invoiceno = i.invoiceno)
 where
  invoiceno in (select invoiceno from strang.movements where movement_no = mvid);

 commit;

end recalc_weight;

procedure cascade_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, oldid in varchar2, oldseal in varchar2, mtype in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.CASCADE_MOVEMENT' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_281,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_cascade_movement' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'MTYPE', mtype );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_282), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.bold( mtype ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_283), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('OLD_MOVEMENT',20,30,oldid), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  if mtype = 'CARGO'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_284), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('OLD_SEAL',20,30,oldseal), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
    htp.tablerowclose;
   else
    htp.formhidden( 'OLD_SEAL', null );
  end if;
  htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_285), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('NEW_MOVEMENT',20,30), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  if mtype = 'CARGO'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( LNGS.STR_TXT_286), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="RIGHT"');
     htp.tabledata( htf.formtext('NEW_SEAL',20,30), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
    htp.tablerowclose;
   else
    htp.formhidden( 'NEW_SEAL', null );
  end if;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=0' );
 htp.tablerowopen;
 htp.tabledata( htf.formsubmit( null, LNGS.STR_TXT_287 ));
 htp.formclose;
 htp.formopen( 'strangp.movement' );
 htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'CALL_NAME', null );
 htp.formhidden( 'ACCESS_ID', access_id );
 htp.tabledata( htf.formsubmit( null, LNGS.STR_TXT_318 ));
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'CASCADE_MOVEMENT',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end cascade_movement;

procedure accept_cascade_movement( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2, mtype in varchar2, old_movement in varchar2, old_seal in varchar2 default null, new_movement in varchar2, new_seal in varchar2 default null)
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_CASCADE_MOVEMENT' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 if old_movement is null then cascade_movement( surl, rid, scid, parm, access_id, old_movement, old_seal, mtype, 'Old Movement No must be entered' ); return; end if;
 if new_movement is null then cascade_movement( surl, rid, scid, parm, access_id, old_movement, old_seal, mtype, 'New Movement No must be entered' ); return; end if;

 if old_seal is null
  then
   -- If we cascade update HAWBS, just do a safety check and make sure it is an AIR type
   update strang.hawbs
    set
     mawb = new_movement
    where
     mawb = old_movement and
     exists (select 'x' from strang.movements where movement_type = 'AIRWAY' and movement_no = old_movement);
   update strang.detailrs
    set
     movement_no = new_movement
    where
     movement_no = old_movement;
   update strang.movements
    set
     movement_no = new_movement
    where
     movement_no = old_movement;

  else

   update strang.detailrs
    set
     movement_no = new_movement,
     camov_seal = new_seal
    where
     movement_no = old_movement and
     camov_seal = old_seal;
   update strang.movements
    set
     movement_no = new_movement,
     seal = new_seal
    where
     movement_no = old_movement and
     seal = old_seal;
 end if;

 recalc_weight( new_movement, new_seal );
 menu( surl, null, mtype, new_movement, 'SEARCH' );
exception
 when
  others
   then
    glbx.main_title( surl, 'Error on Update',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR19',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
    htp.nl;
    htp.nl;
    htp.bold( 'Error Found: ' || sqlerrm );
    htp.nl;
    htp.nl;
    htp.bold( 'Likely cause: This Movement No already exists' );
    htp.nl;
    htp.nl;
    htp.italic( LNGS.STR_TXT_420 );
    htp.nl;
    htp.htmlclose;
    return;
end accept_cascade_movement;

function data_access( acid in integer, typ in varchar2, rid in rowid, ext in varchar2 default null )
 return varchar2
as

 seclevel	varchar2(100);

begin
 -- RECEIVAL, DETAILRS, MOVEMENT, SHP, INVOICING, POS, ASSIGN, DUTY, CODES
 seclevel := oltp.security_role( acid );
 if seclevel = 'LEVEL 7' then return( 'EDIT' ); end if;

 -- Screens
 if typ in ( 'MOVEMENT', 'ASSIGN' )
  then
   if seclevel in ( 'LEVEL 6','LEVEL 8' ) then return( 'READ' ); elsif seclevel in ('LEVEL 2','LEVEL 3','LEVEL 4','LEVEL 5' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ in ( 'SHP')
  then
   if seclevel in ( 'LEVEL 1','LEVEL 6' ) then return( 'READ' ); elsif seclevel in ('LEVEL 2','LEVEL 3','LEVEL 4','LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
-- xxxSouthbound Start
 elsif typ in ( 'SHP_SB')
  then
   if seclevel in ( 'LEVEL 1','LEVEL 6' ) then return( 'READ' ); elsif seclevel in ('LEVEL 2','LEVEL 3','LEVEL 4','LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
-- xxxSouthbound End
 elsif typ in ( 'ENTRY_MAINTAIN')
  then
   if seclevel in ('LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ in ( 'CONTAINER_MAINTAIN')
  then
   if seclevel in ( 'LEVEL 1','LEVEL 6' ) then return( 'READ' ); elsif seclevel in ('LEVEL 2','LEVEL 3','LEVEL 4','LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ in ( 'DELIVERY_MAINTAIN')
  then
   if seclevel in ('LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ in ( 'RECEIVAL' )
  then
   if seclevel in ( 'LEVEL 1', 'LEVEL 6') then return( 'READ' ); elsif seclevel in ('LEVEL 2','LEVEL 3','LEVEL 4','LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ in ( 'POS', 'DETAILRS' )
  then
   if seclevel in (  'LEVEL 1','LEVEL 6') then return( 'READ' ); elsif seclevel in ('LEVEL 2','LEVEL 3','LEVEL 4','LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'SHP2'
  then
   if seclevel in ('LEVEL 5','LEVEL 8') then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'DELLOV'
  then
   return( 'NONE' );
 elsif typ = 'HOTSYNC'
  then
   if seclevel in ('LEVEL 3','LEVEL 4','LEVEL 5') then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'HOTSYNC_SUPER'
  then
   return( 'NONE' );
 elsif typ in ( 'INVOICING','CHARGES', 'INVCONTROLS')
  then
   if seclevel in ('LEVEL 3','LEVEL 4', 'LEVEL 5','LEVEL 6' ) then return( 'EDIT' ); else return( 'NONE' ); end if;

 -- Control Codes
 elsif typ in ( 'CONTROLS','CONTRACTS','GSTCODES' )
  then
   if seclevel in ('LEVEL 3', 'LEVEL 4', 'LEVEL 5', 'LEVEL 6' ) then return( 'READ' ); else return( 'NONE' ); end if;
 elsif typ in ('TARIFF','INVENT')
  then
   if seclevel in (  'LEVEL 1','LEVEL 6' ) then return( 'READ' ); elsif seclevel in ('LEVEL 3','LEVEL 4','LEVEL 5', 'LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ in ('SAD')
  then
   if seclevel in (  'LEVEL 9' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'DUTY'
  then
   if seclevel in (  'LEVEL 1','LEVEL 6' ) then return( 'READ' ); elsif seclevel in ('LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ in ( 'UNRATTAB','CURRENCY', 'COUNTRIES', 'CUSTOMERS' , 'CTRTYPE','LOCATIONS','PACKTYPES','UNITS','DEBTOR_BRANCH','DEBTOR_CODE','JOB_BRANCH','PROFIT_CENTRE','COST_CENTRE','WAREHOUSES')
  then
   if seclevel in ( 'LEVEL 6','LEVEL 8' ) then return( 'READ' ); elsif seclevel in ( 'LEVEL 2', 'LEVEL 3','LEVEL 4', 'LEVEL 5') then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'MANENTRY'
  then
   if seclevel in (  'LEVEL 1','LEVEL 6' ) then return( 'READ' ); elsif seclevel in ('LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'CONTAINERS'
  then
   if seclevel in ( 'LEVEL 1','LEVEL 8' ) then return( 'READ' ); elsif seclevel in ('LEVEL 6' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 -- Reports
 elsif typ = 'REPORT A'
  then
   if seclevel in ( 'LEVEL 1','LEVEL 2','LEVEL 3','LEVEL 4','LEVEL 5','LEVEL 8' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'REPORT B'
  then
   if seclevel in ( 'LEVEL 2','LEVEL 3','LEVEL 8' ) then return( 'EDIT' ); elsif seclevel in ('LEVEL 1','LEVEL 4','LEVEL 5' ) then return( 'READ' ); else return( 'NONE' ); end if;
 elsif typ = 'REPORT C'
  then
   if seclevel in ( 'LEVEL 1' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'REPORT D'
  then
   if seclevel in ( 'LEVEL 3','LEVEL 4' ) then return( 'EDIT' ); elsif seclevel in ('LEVEL 1','LEVEL 2','LEVEL 5','LEVEL 8' ) then return( 'READ' ); else return( 'NONE' ); end if;
 elsif typ = 'REPORT E'
  then
   if seclevel in ( 'LEVEL 3','LEVEL 4' ) then return( 'EDIT' ); elsif seclevel in ('LEVEL 1','LEVEL 2','LEVEL 5','LEVEL 8' ) then return( 'READ' ); else return( 'NONE' ); end if;
 elsif typ = 'REPORT F'
  then
   if seclevel in ( 'LEVEL 1','LEVEL 3','LEVEL 4' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 elsif typ = 'REPORT G'
  then
   if seclevel in ( 'LEVEL 3','LEVEL 4' ) then return( 'EDIT' ); else return( 'NONE' ); end if;
 else
   if seclevel in ('LEVEL 1','LEVEL 4','LEVEL 5' ) then return( 'READ' ); else return( 'EDIT' ); end if;
 end if;
 return( 'READ' );

exception
 when others then return( 'NONE' );
end data_access;

procedure menu( surl in varchar2, rnd in varchar2, mtype in varchar2, msearch in varchar2 default null, action in varchar2 default 'SEARCH', rid in varchar2 default null )
as

 cursor c2( sname varchar2 ) is select screen_id from oltp_overview where screen_name = sname;

 cursor c1 is select rowid from strang.receivals order by deliveryno desc;
 cursor c1s( nmb number )is select rowid from strang.receivals where to_char(deliveryno) like to_char(nmb) || '%';
 cursor c1x( dlr varchar2 ) is select rowid from strang.receivals where substr(to_char(deliveryno),1,1) = dlr order by deliveryno desc;
 cursor c1sx( nmb number, dlr varchar2 )is select rowid from strang.receivals where to_char(deliveryno) like to_char(nmb) || '%' and substr(to_char(deliveryno),1,1) = dlr;
 cursor c3( mtype varchar2 ) is select rowid from strang.movements where movement_type = mtype order by movement_no, dispatch_date desc;
 cursor c3s( mtype varchar2, msearch varchar2 ) is select rowid from strang.movements where movement_type = mtype and upper(movement_no) like upper(msearch) || '%' order by movement_no, dispatch_date desc;
 cursor c4 is select rowid from strang.invoices order by invoiceno;
 cursor c4s( msearch varchar2 ) is select rowid from strang.invoices where upper(invoiceno) like upper(msearch) || '%';
 cursor c5 is select rowid from strang.duty order by entry_no;
-- cursor c5s( msearch varchar2 ) is select rowid from strang.duty where to_char(entry_no) like strang.ent.get_entry_no(msearch) || '%';
-- cursor c5s( msearch varchar2 ) is select rowid from strang.duty where to_char(strang.ent.get_entry_no(entry_no)) like msearch || '%';
 cursor c5s( m_search integer ) is select rowid from strang.duty where entry_no = strang.ent.get_entry_no(m_search);
 cursor c6 is select rowid from strang.ships_airway order by shipname,voy asc;
 cursor c6s( msearch varchar2 ) is
  select rowid
  from strang.ships_airway
  where (upper(voy) like upper(msearch) || '%' and instr(msearch,'-') = 0) or
        (instr(msearch,'-') > 0 and upper(voy) = substr(upper(msearch),1,instr(msearch,'-')-1) and upper(shipname) like substr(upper(msearch),instr(msearch,'-')+1) || '%')
  order by shipname,voy asc;
 cursor c6ss( shipid integer ) is select rowid from strang.ships_airway where (ship_id = shipid or sap_ship_id = shipid) and rownum < 2;
 cursor c7 is select rowid from strang.customers order by customer;
 cursor c7s( msearch varchar2 ) is select rowid from strang.customers where upper(customer) like upper(msearch) || '%' order by customer;
 cursor c7n( msearch integer ) is select rowid from strang.customers where customer_id = msearch order by customer;
 cursor c8 is select rowid,chargecode from strang.charges order by chargecode;
 cursor c8s( msearch varchar2 ) is select rowid,chargecode from strang.charges where upper(chargecode) like upper(msearch) || '%';
 cursor c9 is select rowid,entry_no from strang.detailrs where entry_no is not null order by entry_no,line_no;
 cursor c9a(lrid rowid) is select rowid from strang.receivals where deliveryno = (select deliveryno from strang.detailrs where rowid = lrid);
 cursor c9b(lrid rowid) is select rowid from strang.detailrs where deliveryno in (select deliveryno from strang.receivals where rowid = lrid) order by itemno,logno;
 cursor c9s( msearch integer ) is select rowid,entry_no from strang.detailrs where entry_no = strang.ent.get_entry_no(msearch);
 cursor c10(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'SEE_ALL_DELIVERIES' and cola = vste;
 cursor c11(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'DELIVERYNO' and cola = vste;
 cursor c12 is select rowid,entry_no from strang.manentry order by entry_no desc;
 cursor c12s( nmb number ) is select rowid,entry_no from strang.manentry where to_char(entry_no) like to_char(nmb) || '%';
 cursor c12x is select count('x') tot from strang.manentry;
 cursor c14(ent integer) is select rowid,entry_no from strang.manent2 where entry_no = ent order by rno;
 cursor c14s( ent integer, nmb number ) is select rowid,entry_no from strang.manent2 where entry_no = ent and to_char(rno) like to_char(nmb) || '%' order by rno;
 cursor c14x(ent integer) is select count('x') tot from strang.manent2 where entry_no = ent;
 cursor c14z(nrid rowid) is select entry_no from strang.manent2 where rowid = nrid;
 cursor c15 is select rowid from strang.containers order by containerno, timeshired desc;
 cursor c15s( msearch varchar2 ) is select rowid from strang.containers where containerno like msearch || '%' order by containerno, timeshired desc;
 -- xxx change to reference categories
 cursor c16 is select rowid from strang.categories order by contract,company,codedesc;
 cursor c16s( msearch varchar2 ) is select rowid from strang.categories where contract||codedesc||company like '%' || msearch || '%' order by contract,company,codedesc;
 cursor c17 is select rowid from strang.onlocs order by cat_contract,cat_company,cat_code;
 cursor c17s( msearch varchar2 ) is select rowid from strang.onlocs where replace(cat_contract||cat_company||cat_code,' ','') like '%' || replace(upper(msearch),' ','') || '%' order by cat_contract,cat_company,cat_code;
 cursor c18 is select rowid from strang.offlocs order by cat_contract,cat_company,cat_code;
 cursor c18s( msearch varchar2 ) is select rowid from strang.offlocs where replace(cat_contract||cat_company||cat_code ,' ','') like '%' || replace(upper(msearch),' ','') || '%' order by cat_contract,cat_company,cat_code;
 cursor c19 is select rowid from strang.tracking_header order by containerno, cat_code, cat_company;
 cursor c19s( msearch varchar2 ) is select rowid from strang.tracking_header where containerno like msearch || '%' order by containerno, cat_code, cat_company;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;
 c3rec	c3%ROWTYPE;
 c4rec	c4%ROWTYPE;
 c5rec	c5%ROWTYPE;
 c6rec	c6%ROWTYPE;
 c7rec	c7%ROWTYPE;
 c8rec	c8%ROWTYPE;
 c9rec	c9%ROWTYPE;
 c9arec	c9a%ROWTYPE;
 c10rec c10%ROWTYPE;
 c11rec c11%ROWTYPE;
 c12rec c12%ROWTYPE;
 c14rec c14%ROWTYPE;
 c15rec c15%ROWTYPE;
 c16rec c16%ROWTYPE;
 c17rec c17%ROWTYPE;
 c18rec c18%ROWTYPE;
 c19rec c19%ROWTYPE;

 -- xxx (remember this bit, add what here?)

 nmb		number;
 lrid		rowid;
 cusrec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 rctr		integer;
 tot		integer;
 ent		integer;
 vste		varchar2(10);
 arr_rid	src_rid;
 v_search       varchar2(1000);
 v_cus		integer;
 v_ship_search	integer;
begin

  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.MENU' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  cusrec := glbx.get_aid( owner_id, 'C', ltype );
  vste := customer_state(cusrec.aid);


 if mtype = 'RECEIVALS'
  then
   open c10(vste);
   fetch c10 into c10rec;
   close c10;
   if action = 'SEARCH'
    then
     if msearch is null
      then
       if c10rec.description = 'YES' and cusrec.username <> 'DAWN'
        then
         open c1;
         fetch c1 into c1rec;
         close c1;
        else
         open c11(vste);
         fetch c11 into c11rec;
         close c11;
         open c1x( substr(c11rec.description,1,1) );
         fetch c1x into c1rec;
         close c1x;
       end if;
      else
       begin nmb := to_number( msearch ); exception when others then nmb := NULL; end;
       if c10rec.description = 'YES' and cusrec.username <> 'DAWN'
        then
         open c1s( nmb );
         fetch c1s into c1rec;
         close c1s;
        else
         open c11(vste);
         fetch c11 into c11rec;
         close c11;
         open c1sx( nmb,substr(c11rec.description,1,1)  );
         fetch c1sx into c1rec;
         close c1sx;
       end if;
     end if;
     open c2( 'Receival' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     if c10rec.description = 'YES'  and cusrec.username <> 'DAWN'
      then
       open c1;
      else
       open c11(vste);
       fetch c11 into c11rec;
       close c11;
       open c1x(substr(c11rec.description,1,1) );
     end if;
     lrid := NULL;
     loop
      if c10rec.description = 'YES'  and cusrec.username <> 'DAWN'
       then
        fetch c1 into c1rec;
        if c1%NOTFOUND then c1rec.rowid := lrid; exit; end if;
       else
        fetch c1x into c1rec;
        if c1x%NOTFOUND then c1rec.rowid := lrid; exit; end if;
      end if;
      exit when c1rec.rowid = replace(rid,'~','+');
      lrid := c1rec.rowid;
     end loop;
     if c10rec.description = 'YES' and cusrec.username <> 'DAWN' then close c1; else close c1x; end if;
     if lrid is not null then c1rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     if c10rec.description = 'YES'  and cusrec.username <> 'DAWN'
      then
       open c1;
      else
       open c11(vste);
       fetch c11 into c11rec;
       close c11;
       open c1x(substr(c11rec.description,1,1) );
     end if;
     lrid := NULL;
     loop
      if c10rec.description = 'YES'  and cusrec.username <> 'DAWN'
       then
        fetch c1 into c1rec;
        if c1%NOTFOUND then c1rec.rowid := lrid; exit; end if;
       else
        fetch c1x into c1rec;
        if c1x%NOTFOUND then c1rec.rowid := lrid; exit; end if;
      end if;
      if c1rec.rowid = replace(rid,'~','+')
       then
        lrid := c1rec.rowid;
        if c10rec.description = 'YES'  and cusrec.username <> 'DAWN'
         then
          fetch c1 into c1rec;
          if c1%NOTFOUND then c1rec.rowid := lrid; end if;
         else
          fetch c1x into c1rec;
          if c1x%NOTFOUND then c1rec.rowid := lrid; end if;
        end if;
        exit;
      end if;
      lrid := c1rec.rowid;
     end loop;
     if c10rec.description = 'YES'  and cusrec.username <> 'DAWN' then close c1; else close c1x; end if;
   end if;
   if c1rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_288 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   receive(surl,c1rec.rowid, c2rec.screen_id, 'strangp.receive', 'RECEIVALS', 'x', null );
   return;
 end if;

 if mtype in ('CARGO','CONMOV','AIRWAY')
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c3( mtype );
       fetch c3 into c3rec;
       close c3;
      else
       open c3s( mtype, msearch );
       fetch c3s into c3rec;
       close c3s;
     end if;
     if mtype = 'CARGO'
      then
       open c2( 'Cargo' );
     elsif mtype = 'CONMOV'
      then
       open c2( 'Consignment' );
     else
       open c2( 'Air Freight' );
     end if;
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c3( mtype );
     lrid := NULL;
     loop
      fetch c3 into c3rec;
      if c3%NOTFOUND then c3rec.rowid := lrid; exit; end if;
      exit when c3rec.rowid = replace(rid,'~','+');
      lrid := c3rec.rowid;
     end loop;
     close c3;
     if lrid is not null then c3rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c3( mtype );
     lrid := NULL;
     loop
      fetch c3 into c3rec;
      if c3%NOTFOUND then c3rec.rowid := lrid; exit; end if;
      if c3rec.rowid = replace(rid,'~','+')
       then
        lrid := c3rec.rowid;
        fetch c3 into c3rec;
        if c3%NOTFOUND then c3rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c3rec.rowid;
     end loop;
     close c3;
   end if;
   if c3rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_291 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   movement(surl,c3rec.rowid, c2rec.screen_id, 'strangp.movement', mtype, 'x', null );
   return;
 end if;

 if mtype = 'INVOICES'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c4;
       fetch c4 into c4rec;
       close c4;
      else
       open c4s( msearch );
       fetch c4s into c4rec;
       close c4s;
     end if;
     open c2( 'Invoicing' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c4;
     lrid := NULL;
     loop
      fetch c4 into c4rec;
      if c4%NOTFOUND then c4rec.rowid := lrid; exit; end if;
      exit when c4rec.rowid = replace(rid,'~','+');
      lrid := c4rec.rowid;
     end loop;
     close c4;
     if lrid is not null then c4rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c4;
     lrid := NULL;
     loop
      fetch c4 into c4rec;
      if c4%NOTFOUND then c4rec.rowid := lrid; exit; end if;
      if c4rec.rowid = replace(rid,'~','+')
       then
        lrid := c4rec.rowid;
        fetch c4 into c4rec;
        if c4%NOTFOUND then c4rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c4rec.rowid;
     end loop;
     close c4;
   end if;
   if c4rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_292 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   inv(surl,c4rec.rowid, c2rec.screen_id, 'strangp.inv', 'INVOICES', 'x', null );
   return;
 end if;

 if mtype = 'DUTY'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c5;
       fetch c5 into c5rec;
       close c5;
      else
       if instr(msearch, '.') > 0
        then
         begin nmb := to_number(strang.ent.get_entry_no(msearch)); exception when others then nmb := null; end;
       else
         begin nmb := to_number('1' || '.' || strang.ent.get_entry_no(msearch, 'D')); exception when others then nmb := null; end;
       end if;
       open c5s( nmb );
--       open c5s( msearch );
       fetch c5s into c5rec;
       close c5s;
     end if;
     open c2( 'Duty' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c5;
     lrid := NULL;
     loop
      fetch c5 into c5rec;
      if c5%NOTFOUND then c5rec.rowid := lrid; exit; end if;
      exit when c5rec.rowid = replace(rid,'~','+');
      lrid := c5rec.rowid;
     end loop;
     close c5;
     if lrid is not null then c5rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c5;
     lrid := NULL;
     loop
      fetch c5 into c5rec;
      if c5%NOTFOUND then c5rec.rowid := lrid; exit; end if;
      if c5rec.rowid = replace(rid,'~','+')
       then
        lrid := c5rec.rowid;
        fetch c5 into c5rec;
        if c5%NOTFOUND then c5rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c5rec.rowid;
     end loop;
     close c5;
   end if;
   if c5rec.rowid is null
    then
     htp.htmlopen;
--      htp.header(3,LNGS.STR_TXT_293 || ' : ' || msearch, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_293 || ' : ' || nvl(to_char(nmb), msearch), 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   duty_edit(surl,c5rec.rowid, c2rec.screen_id, 'DUTY', 'x', null );
   return;
 end if;

 if mtype = 'SHIP_AIRWAY'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c6;
       fetch c6 into c6rec;
       close c6;
     else
       v_ship_search := glbx.guess_number(trim(msearch));
       if v_ship_search is not null
       then
        open c6ss( v_ship_search );
        fetch c6ss into c6rec;
        close c6ss;
       else
        open c6s( msearch );
        fetch c6s into c6rec;
        close c6s;
       end if;
     end if;
     open c2( 'Ship/Air' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c6;
     lrid := NULL;
     loop
      fetch c6 into c6rec;
      if c6%NOTFOUND then c6rec.rowid := lrid; exit; end if;
      exit when c6rec.rowid = replace(rid,'~','+');
      lrid := c6rec.rowid;
     end loop;
     close c6;
     if lrid is not null then c6rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c6;
     lrid := NULL;
     loop
      fetch c6 into c6rec;
      if c6%NOTFOUND then c6rec.rowid := lrid; exit; end if;
      if c6rec.rowid = replace(rid,'~','+')
       then
        lrid := c6rec.rowid;
        fetch c6 into c6rec;
        if c6%NOTFOUND then c6rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c6rec.rowid;
     end loop;
     close c6;
   end if;
   if c6rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_294 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   shp(surl,c6rec.rowid, c2rec.screen_id, 'SHIP_AIRWAY', 'x', null );
   return;
 end if;

 if mtype = 'CUSTOMERS'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c7;
       fetch c7 into c7rec;
       close c7;
       else
       v_cus := glbx.guess_number(msearch);
       if v_cus is not null
        then
        open c7n( v_cus );
        fetch c7n into c7rec;
        close c7n;
       else
        open c7s( msearch );
        fetch c7s into c7rec;
        close c7s;
       end if;
     end if;
     open c2( 'Customers' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c7;
     lrid := NULL;
     loop
      fetch c7 into c7rec;
      if c7%NOTFOUND then c7rec.rowid := lrid; exit; end if;
      exit when c7rec.rowid = replace(rid,'~','+');
      lrid := c7rec.rowid;
     end loop;
     close c7;
     if lrid is not null then c7rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c7;
     lrid := NULL;
     loop
      fetch c7 into c7rec;
      if c7%NOTFOUND then c7rec.rowid := lrid; exit; end if;
      if c7rec.rowid = replace(rid,'~','+')
       then
        lrid := c7rec.rowid;
        fetch c7 into c7rec;
        if c7%NOTFOUND then c7rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c7rec.rowid;
     end loop;
     close c7;
   end if;
   if c7rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_294 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   mng_cust(surl,c7rec.rowid, 'x', null );
   return;
 end if;

 if mtype = 'CHARGES'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c8;
       fetch c8 into c8rec;
       close c8;
       else
       open c8s( msearch );
       fetch c8s into c8rec;
       close c8s;
     end if;
     open c2( 'Charge Codes' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c8;
     lrid := NULL;
     loop
      fetch c8 into c8rec;
      if c8%NOTFOUND then c8rec.rowid := lrid; exit; end if;
      exit when c8rec.rowid = replace(rid,'~','+');
      lrid := c8rec.rowid;
     end loop;
     close c8;
     if lrid is not null then c8rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c8;
     lrid := NULL;
     loop
      fetch c8 into c8rec;
      if c8%NOTFOUND then c8rec.rowid := lrid; exit; end if;
      if c8rec.rowid = replace(rid,'~','+')
       then
        lrid := c8rec.rowid;
        fetch c8 into c8rec;
        if c8%NOTFOUND then c8rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c8rec.rowid;
     end loop;
     close c8;
   end if;
   if c8rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_375 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   mng_charge(surl,c8rec.rowid, 'x', null );
   return;
 end if;

 if mtype = 'ENTRY_NO'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c9;
       fetch c9 into c9rec;
       close c9;
      else
       if instr(msearch, '.') > 0
        then
         begin nmb := to_number(strang.ent.get_entry_no(msearch)); exception when others then nmb := null; end;
       else
         begin nmb := to_number('1' || '.' || strang.ent.get_entry_no(msearch, 'D')); exception when others then nmb := null; end;
       end if;
       -- begin nmb := to_number(msearch); exception when others then nmb := NULL; end;
       open c9s( nmb );
       fetch c9s into c9rec;
       close c9s;
     end if;
     lrid := c9rec.rowid;
     if lrid is null
      then
       htp.init;
       htp.htmlopen;
       htp.header(3,LNGS.STR_TXT_293 || ' : ' || nvl(to_char(nmb), msearch), 'CENTER' );
       htp.header(3,LNGS.STR_TXT_289,'CENTER');
       htp.header(4,LNGS.STR_TXT_290,'CENTER');
       return;
     end if;
     open c2( 'Detailrs' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c9;
     lrid := NULL;
     loop
      fetch c9 into c9rec;
      if c9%NOTFOUND then c9rec.rowid := lrid; exit; end if;
      exit when c9rec.rowid = replace(rid,'~','+');
      lrid := c9rec.rowid;
     end loop;
     close c9;
     if lrid is not null then c9rec.rowid := lrid; else lrid := replace(rid,'~','+'); end if;
   elsif action = 'NEXT'
    then
     open c9;
     lrid := NULL;
     loop
      fetch c9 into c9rec;
      if c9%NOTFOUND then c9rec.rowid := lrid; exit; end if;
      if c9rec.rowid = replace(rid,'~','+')
       then
        lrid := c9rec.rowid;
        fetch c9 into c9rec;
        if c9%NOTFOUND then c9rec.rowid := lrid; end if;
        lrid := c9rec.rowid;
        exit;
      end if;
      lrid := c9rec.rowid;
     end loop;
     close c9;
   end if;
   open c9a(nvl(lrid,replace(rid,'~','+')));
   fetch c9a into c9arec;
   close c9a;
   rctr := 0;
   for c9brec in c9b(c9arec.rowid) loop
    rctr := rctr + 1;
    if c9brec.rowid = lrid then exit; end if;
   end loop;
   -- Now having to replace the whole screen
   receive(surl, lrid, c2rec.screen_id, 'strangp.receive', 'DETAILRS', 'x', null );
   --receive_bottom(surl,c9arec.rowid,5,null,'DETAILRS','e',rctr,null );
   return;
 end if;

 if mtype = 'ME'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c12;
       fetch c12 into c12rec;
       if c12%NOTFOUND
        then
         close c12;
         open c12x;
         fetch c12x into tot;
         close c12x;
         if tot = 0
          then
            open c2( 'Manual Entry' );
            fetch c2 into c2rec;
            close c2;
            manentry(surl, null, c2rec.screen_id, 'strangp.movement', mtype, 'x', null );
            return;
         end if;
        else
         close c12;
       end if;
      else
       open c12s( msearch );
       fetch c12s into c12rec;
       if c12s%NOTFOUND
        then
         close c12s;
         open c12x;
         fetch c12x into tot;
         close c12x;
         if tot = 0
          then
            open c2( 'Manual Entry' );
            fetch c2 into c2rec;
            close c2;
            manentry(surl, null, c2rec.screen_id, 'strangp.movement', mtype, 'x', msg=>null );
            return;
         end if;
        else
         close c12s;
       end if;
     end if;
     open c2( 'Manual Entry' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c12;
     lrid := NULL;
     loop
      fetch c12 into c12rec;
      if c12%NOTFOUND then c12rec.rowid := lrid; exit; end if;
      exit when c12rec.rowid = replace(rid,'~','+');
      lrid := c12rec.rowid;
     end loop;
     close c12;
     if lrid is not null then c12rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c12;
     lrid := NULL;
     loop
      fetch c12 into c12rec;
      if c12%NOTFOUND then c12rec.rowid := lrid; exit; end if;
      if c12rec.rowid = replace(rid,'~','+')
       then
        lrid := c12rec.rowid;
        fetch c12 into c12rec;
        if c12%NOTFOUND then c12rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c12rec.rowid;
     end loop;
     close c12;
   end if;
   if c12rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_292 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   manentry(surl,c12rec.rowid, c2rec.screen_id, 'strangp.movement', mtype, 'x', null );
   return;
 end if;

 if mtype = 'ME2'
  then
   open c14z(rid);
   fetch c14z into ent;
   close c14z;
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c14(ent);
       fetch c14 into c14rec;
       if c14%NOTFOUND
        then
         close c14;
         open c14x(ent);
         fetch c14x into tot;
         close c14x;
         if tot = 0
          then
            open c2( 'Manual Entry' );
            fetch c2 into c2rec;
            close c2;
            manentry_page3(surl,null, c2rec.screen_id, 'strangp.movement', mtype, 'x', null );
            return;
         end if;
        else
         close c14;
       end if;
      else
       open c14s( ent, msearch );
       fetch c14s into c14rec;
       if c14s%NOTFOUND
        then
         close c14s;
         open c14x(ent);
         fetch c14x into tot;
         close c14x;
         if tot = 0
          then
            open c2( 'Manual Entry' );
            fetch c2 into c2rec;
            close c2;
            manentry_page3(surl, null, c2rec.screen_id, 'strangp.movement', mtype, 'x', null );
            return;
         end if;
        else
         close c14s;
       end if;
     end if;
     open c2( 'Manual Entry' );
     fetch c2 into c2rec;
     close c2;
   elsif action = 'PREVIOUS'
    then
     open c14(ent);
     lrid := NULL;
     loop
      fetch c14 into c14rec;
      if c14%NOTFOUND then c14rec.rowid := lrid; exit; end if;
      exit when c14rec.rowid = replace(rid,'~','+');
      lrid := c14rec.rowid;
     end loop;
     close c14;
     if lrid is not null then c14rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c14(ent);
     lrid := NULL;
     loop
      fetch c14 into c14rec;
      if c14%NOTFOUND then c14rec.rowid := lrid; exit; end if;
      if c14rec.rowid = replace(rid,'~','+')
       then
        lrid := c14rec.rowid;
        fetch c14 into c14rec;
        if c14%NOTFOUND then c14rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c14rec.rowid;
     end loop;
     close c14;
   end if;
   if c14rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_292 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   manentry_page3(surl,c14rec.rowid, c2rec.screen_id, 'strangp.movement', mtype, 'x', null );
   return;
 end if;

 if mtype = 'TRAC'
  then
   trac_search( surl, null );
 end if;

 -- xxx copy this and convert to search on categories. use c16
if mtype = 'CTR'
  then
   open c2( 'Container Hire' );
   fetch c2 into c2rec;
   close c2;
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c15;
       fetch c15 into c15rec;
       close c15;
      else
       open c15s( msearch );
       fetch c15s into c15rec;
       close c15s;
     end if;
   elsif action = 'PREVIOUS'
    then
     open c15;
     lrid := NULL;
     loop
      fetch c15 into c15rec;
      if c15%NOTFOUND then c15rec.rowid := lrid; exit; end if;
      exit when c15rec.rowid = replace(rid,'~','+');
      lrid := c15rec.rowid;
     end loop;
     close c15;
     if lrid is not null then c15rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c15;
     lrid := NULL;
     loop
      fetch c15 into c15rec;
      if c15%NOTFOUND then c15rec.rowid := lrid; exit; end if;
      if c15rec.rowid = replace(rid,'~','+')
       then
        lrid := c15rec.rowid;
        fetch c15 into c15rec;
        if c15%NOTFOUND then c15rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c15rec.rowid;
     end loop;
     close c15;
   end if;
   if c15rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_293 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   mng_ctr(surl,c15rec.rowid, c2rec.screen_id, 'Container Hire', 'x', null );
   return;
 end if;


if mtype = 'CATEG'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c16;
       fetch c16 into c16rec;
       close c16;
      else
       open c16s( msearch );
       fetch c16s into c16rec;
       close c16s;
     end if;
   elsif action = 'PREVIOUS'
    then
     open c16;
     lrid := NULL;
     loop
      fetch c16 into c16rec;
      if c16%NOTFOUND then c16rec.rowid := lrid; exit; end if;
      exit when c16rec.rowid = replace(rid,'~','+');
      lrid := c16rec.rowid;
     end loop;
     close c16;
     if lrid is not null then c16rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c16;
     lrid := NULL;
     loop
      fetch c16 into c16rec;
      if c16%NOTFOUND then c16rec.rowid := lrid; exit; end if;
      if c16rec.rowid = replace(rid,'~','+')
       then
        lrid := c16rec.rowid;
        fetch c16 into c16rec;
        if c16%NOTFOUND then c16rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c16rec.rowid;
     end loop;
     close c16;
   end if;
   if c16rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_293 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   mng_categories(surl,c16rec.rowid, 'x' , 'Categories', 'x', null );
   return;
 end if;


if mtype = 'ONLOCS'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c17;
       for j in 1..10 loop
        fetch c17 into c17rec;
        if c17%FOUND then arr_rid(arr_rid.count+1) := c17rec.rowid; else exit; end if;
       end loop;
       close c17;
      else
       open c17s( msearch );
       for j in 1..10 loop
        fetch c17s into c17rec;
        if c17s%FOUND then arr_rid(arr_rid.count+1) := c17rec.rowid; else exit; end if;
       end loop;
       close c17s;
     end if;

   elsif action = 'PREVIOUS'
    then
     open c17;
     lrid := NULL;
     for j in 1..10 loop
      arr_rid(j) := null;
     end loop;

     loop
      fetch c17 into c17rec;
      if c17%NOTFOUND then c17rec.rowid := lrid; exit; end if;
      exit when c17rec.rowid = replace(rid,'~','+');
      for j in 2..10 loop
       arr_rid(j-1) := arr_rid(j);
      end loop;
      arr_rid(10) := c17rec.rowid;
      lrid := c17rec.rowid;
     end loop;

     close c17;
     if lrid is not null then c17rec.rowid := lrid; end if;

   elsif action = 'NEXT'
    then
     open c17;
     lrid := NULL;
     loop
      fetch c17 into c17rec;
      if c17%NOTFOUND then c17rec.rowid := lrid; exit; end if;
      if c17rec.rowid = replace(rid,'~','+')
       then
        lrid := c17rec.rowid;
        fetch c17 into c17rec;
        if c17%NOTFOUND then c17rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c17rec.rowid;
     end loop;
     arr_rid(arr_rid.count+1) := c17rec.rowid;
     for j in 1..9 loop
      fetch c17 into c17rec;
      if c17%FOUND then arr_rid(arr_rid.count+1) := c17rec.rowid; else exit; end if;
     end loop;
     close c17;
   end if;
   if c17rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_293 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   mng_onlocs(surl, arr_rid, 'x' , 'Onhire Details', 'x', null );
   return;
 end if;


if mtype = 'OFFLOCS'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c18;
       for j in 1..10 loop
        fetch c18 into c18rec;
        if c18%FOUND then arr_rid(arr_rid.count+1) := c18rec.rowid; else exit; end if;
       end loop;
       close c18;
      else
       open c18s( msearch );
       for j in 1..10 loop
        fetch c18s into c18rec;
        if c18s%FOUND then arr_rid(arr_rid.count+1) := c18rec.rowid; else exit; end if;
       end loop;
       close c18s;
     end if;

   elsif action = 'PREVIOUS'
    then
     open c18;
     lrid := NULL;
     for j in 1..10 loop
      arr_rid(j) := null;
     end loop;

     loop
      fetch c18 into c18rec;
      if c18%NOTFOUND then c18rec.rowid := lrid; exit; end if;
      exit when c18rec.rowid = replace(rid,'~','+');
      for j in 2..10 loop
       arr_rid(j-1) := arr_rid(j);
      end loop;
      arr_rid(10) := c18rec.rowid;
      lrid := c18rec.rowid;
     end loop;

     close c18;
     if lrid is not null then c18rec.rowid := lrid; end if;

   elsif action = 'NEXT'
    then
     open c18;
     lrid := NULL;
     loop
      fetch c18 into c18rec;
      if c18%NOTFOUND then c18rec.rowid := lrid; exit; end if;
      if c18rec.rowid = replace(rid,'~','+')
       then
        lrid := c18rec.rowid;
        fetch c18 into c18rec;
        if c18%NOTFOUND then c18rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c18rec.rowid;
     end loop;
     arr_rid(arr_rid.count+1) := c18rec.rowid;
     for j in 1..9 loop
      fetch c18 into c18rec;
      if c18%FOUND then arr_rid(arr_rid.count+1) := c18rec.rowid; else exit; end if;
     end loop;
     close c18;
   end if;
   if c18rec.rowid is null
    then
     htp.htmlopen;
      htp.header(3,LNGS.STR_TXT_293 || ' : ' || msearch, 'CENTER' );
      htp.header(2,LNGS.STR_TXT_289, 'CENTER' );
      htp.header(3,LNGS.STR_TXT_290, 'CENTER' );
     htp.htmlclose;
     return;
   end if;
   mng_offlocs(surl, arr_rid, 'x' , 'Offhire Details', 'x', null );
   return;
 end if;

if mtype = 'CTRACK'
  then
   if action = 'SEARCH'
    then
     if msearch is null
      then
       open c19;
       fetch c19 into c19rec;
       close c19;
      else
       open c19s( msearch );
       fetch c19s into c19rec;
       close c19s;
     end if;
   elsif action = 'PREVIOUS'
    then
     open c19;
     lrid := NULL;
     loop
      fetch c19 into c19rec;
      if c19%NOTFOUND then c19rec.rowid := lrid; exit; end if;
      exit when c19rec.rowid = replace(rid,'~','+');
      lrid := c19rec.rowid;
     end loop;
     close c19;
     if lrid is not null then c19rec.rowid := lrid; end if;
   elsif action = 'NEXT'
    then
     open c19;
     lrid := NULL;
     loop
      fetch c19 into c19rec;
      if c19%NOTFOUND then c19rec.rowid := lrid; exit; end if;
      if c19rec.rowid = replace(rid,'~','+')
       then
        lrid := c19rec.rowid;
        fetch c19 into c19rec;
        if c19%NOTFOUND then c19rec.rowid := lrid; end if;
        exit;
      end if;
      lrid := c19rec.rowid;
     end loop;
     close c19;
   end if;
   ctr_track(surl, c19rec.rowid, 'x', 'Container Tracking', 'x', null );
   return;
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'MENU',null,null,errmsg=>sqlerrm,extdet=>'MTYPE:' || mtype);
end menu;

procedure search( surl in varchar2, msearch in varchar2, curr_rowid in varchar2, samerow in boolean DEFAULT FALSE, buttons_only in boolean DEFAULT FALSE, override_top in varchar2 default null, search_only in boolean DEFAULT FALSE, button_text in varchar2 default NULL, lmnu in rowid default null )
as
 ctrg	varchar2(20);
begin
 if not samerow
  then
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
   htp.tablerowopen;
 end if;
 if not buttons_only
  then
   if not search_only then htp.p( '<TD>' ); end if;
   htp.formopen( 'strangp.menu', ctarget=>'_top' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'MTYPE', msearch );
   htp.formhidden( 'ACTION', 'SEARCH' );
   htp.formhidden( 'RID', replace(curr_rowid,'~','+') );
   htp.formhidden( 'RND', to_char(sysdate, 'SSSSS' ));
   if search_only
    then
     htp.formtext( 'MSEARCH', 5, 100 );
    else
     htp.formtext( 'MSEARCH', 20, 100 );
   end if;
   htp.formsubmit( null, nvl(button_text,'Search') );
   htp.formclose;
   if search_only then return; end if;
   htp.p( '</TD>' );
   ctrg := '_top';
  else
   ctrg := '_self';
 end if;

 ctrg := nvl(override_top,ctrg);
 htp.p( '<TD ALIGN="CENTER" VALIGN="TOP">' );
 if msearch = 'RECEIVALS'
  then
   htp.anchor2( 'strangp.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=PREVIOUS&rid=' || replace(curr_rowid,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0',calt=>'Previous Record' ), ctarget=>ctrg );
   htp.anchor2( 'strangp.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=NEXT&rid=' || replace(curr_rowid,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ), ctarget=>ctrg );
  else
   htp.anchor2( 'strangp.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=PREVIOUS&rid=' || replace(curr_rowid,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_previous.gif', cattributes=>' BORDER=0',calt=>'Previous Record' ), ctarget=>ctrg );
   if lmnu is null
    then
     htp.anchor2( 'strangp.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=NEXT&rid=' || replace(curr_rowid,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ), ctarget=>ctrg );
    else
     htp.anchor2( 'strangp.menu?surl=' || surl || '&mtype=' || msearch || '&rnd=' || to_char(sysdate,'SSSSS') || '&action=NEXT&rid=' || replace(lmnu,'+','~'), htf.img( glbx.IMAGE_LOCATION || 'adminc_next.gif', cattributes=>' BORDER=0',calt=>'Next Record' ), ctarget=>ctrg );
   end if;
 end if;
 htp.p( '</TD>' );
 if not samerow
  then
   htp.tablerowclose;
   htp.tableclose;
 end if;
end search;

procedure duty_edit(surl in varchar2, entry in number )
as

 cursor c1(entry number) is select rowid from strang.duty where entry_no = entry;
 cursor c2( sname varchar2 ) is select screen_id from oltp_overview where screen_name = sname;

 c1rec	c1%ROWTYPE;
 c2rec	c2%ROWTYPE;

begin
 open c1(entry);
 fetch c1 into c1rec;
 close c1;
 open c2( 'Duty' );
 fetch c2 into c2rec;
 close c2;
 duty_edit(surl,c1rec.rowid,c2rec.screen_id, 'DUTY', 'x', null );
end duty_edit;

procedure duty_edit(surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2(rid rowid) is select * from strang.duty where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.DUTY_EDIT' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := data_access( owner_id, 'DUTY', rid );

 glbx.main_title( surl, LNGS.STR_TXT_295,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR20',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );
  if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
  if access_id <> 'z'
    then
     open c2(replace(rid,'~','+'));
     fetch c2 into c2rec;
     close c2;
  end if;

 htp.tableopen;
 htp.tablerowopen;
 htp.p( '<TD align="LEFT">' );
 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_duty' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'ACCESS_ID', access_id );
 end if;

 if access_id = 'z'
  then
   htp.formhidden( 'RID', null );
  else
   htp.formhidden( 'RID', replace(rid,'~','+') );
 end if;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_064),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( strang.ent.get_entry_no(c2rec.entry_no) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_296),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P1', 20, 100, c2rec.warrant_no ) ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold( c2rec.warrant_no ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_297),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P2', 20, 100, c2rec.cheque ) ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold( c2rec.cheque ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;

  htp.tablerowopen;
     htp.tabledata( htf.bold('Guarrantee Amount'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P3', 20, 100, c2rec.guarrantee_amount ) ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold( c2rec.guarrantee_amount ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Guarrantee Date'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P4', 20, 100, to_char(c2rec.guarrantee_date,LNGS.STR_DATE_02) ) ,cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      else
       htp.tabledata( htf.bold( to_char(c2rec.guarrantee_date,LNGS.STR_DATE_02) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     end if;
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_298),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.total_invoice,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_300),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(c2rec.ratio_factor,LNGS.STR_FRMT_08) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_301),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.correct_freight,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_217),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.other_costs,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_215),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.insurance,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_302),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( nvl(to_char(c2rec.previous_entry_no),'&nbsp;') ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_299),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.duty,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_303),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.excise,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_216),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.vat,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Levy'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.levy,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold('Exchange Rate'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.exrate,0),9990.9999)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
     htp.tabledata( htf.bold(LNGS.STR_TXT_304),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.bold( to_char(nvl(c2rec.pvariance,0),LNGS.STR_FRMT_06) ),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if data_access(owner_id, 'SAD', rid ) = 'EDIT'
  then
   htp.anchor( 'javascript: window.open(''' || 'strangs.list_entry?surl=' || surl || ''',''' || 'SAD_ENTRY' || ''',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');', '[Find SAD]' );
   htp.anchor( 'javascript: window.open(''' || 'strangs.edit_entry?surl=' || surl || '&pk=' || c2rec.entry_no || ''',''' || 'SAD_ENTRY' || ''',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');', '[Edit SAD:' || strang.ent.get_entry_no(c2rec.entry_no) || ']' );
   htp.nl;
 end if;

 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT'
  then
   if access_id = 'z'
    then
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_305 ),cattributes=>'VALIGN="TOP"');
    else
     htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_306 ),cattributes=>'VALIGN="TOP"');
   end if;
   htp.formclose;
 end if;
 search( surl, 'DUTY', rid, samerow=>TRUE );
 htp.tablerowclose;
 htp.tableclose;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'DUTY_EDIT',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end duty_edit;

procedure accept_duty( surl in varchar2, scid in integer, parm in varchar2, access_id in varchar2, rid in varchar2, action in varchar2, p1 in varchar2, p2 in varchar2 , p3 in varchar2 , p4 in varchar2 )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 newrid		rowid;
 sts		varchar2(100);
 nmb1		number;
 nmb2		number;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_DUTY' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts, TRUE );
   return;
 end if;

 update strang.duty
  set
   warrant_no = p1,
   cheque = p2,
   guarrantee_amount = p3,
   guarrantee_date = p4
  where
   rowid = chartorowid( replace(rid,'~','+') );

 commit;

 duty_edit( surl, rid, scid, parm, access_id, LNGS.STR_TXT_307 );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_DUTY',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end accept_duty;

procedure generate_entry(vship_id in integer, vste in varchar2)
as
  cursor c2( vship_id integer) is
   select /*+ ALL_ROWS */ distinct r.cust_customer_id vcust_id
   from strang.detailrs dr, strang.receivals r,strang.movements m, strang.customers c
   where
    m.ship_id = ship_id and
    nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
    m.movement_no = dr.movement_no and
    dr.deliveryno = r.deliveryno and
    r.cust_customer_id = c.customer_id and
    c.customs_agent is not null
    order by r.cust_customer_id;

 cursor c3( vship_id integer, vcust_id integer ) is
  select /*+ ALL_ROWS */ r.cust_customer_id, dr.deliveryno,dr.rowid,r.supplier_customer_id
  from strang.detailrs dr, strang.receivals r,strang.movements m, strang.customers c
  where
   m.ship_id = vship_id and
   nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
   m.movement_no = dr.movement_no and
   dr.deliveryno = r.deliveryno and
   nvl(r.cust_customer_id,0) = vcust_id and
   nvl(r.cust_customer_id,0) = nvl(c.customer_id,0) and
   c.customs_agent is not null
  order by dr.line_no,dr.deliveryno,dr.itemno;

 cursor c4(vcust_id number) is
  select nvl(max(entry_no),vcust_id) tot
   from strang.detailrs
   where entry_no >= vcust_id and
   entry_no < (vcust_id + 1);

 cursor c5( dlr integer ) is select min(entry_no) entry_no from strang.detailrs dr where deliveryno = dlr;
 cursor c5a( dlr integer, ent number ) is select entry_no from strang.detailrs dr where deliveryno = dlr and entry_no = ent;


 c2rec		 c2%ROWTYPE;
 c3rec		 c3%ROWTYPE;
 c4rec		 c4%ROWTYPE;
 c5rec		 c5%ROWTYPE;
 c5arec		 c5a%ROWTYPE;
 currcustomer    integer;
 currsupplier    integer;
 is_maincustomer boolean;
 is_partshipment boolean;
 is_loop	 boolean;
 created_duty	 boolean;

begin

for c2rec in c2( vShip_id ) loop

open c4( c2rec.vcust_id );
fetch c4 into c4rec;
close c4;
c4rec.tot := nvl(c4rec.tot,0);
currcustomer:= c2rec.vcust_id;
currsupplier := 0;
is_partshipment := FALSE;
is_loop := FALSE;
created_duty := FALSE;

for c3rec in c3( vShip_id, c2rec.vcust_id ) loop

 c5rec.entry_no := NULL;
 c5arec.entry_no := NULL;
 open c5(c3rec.deliveryno);
 fetch c5 into c5rec;
 close c5;
 open c5a(c3rec.deliveryno,c4rec.tot);
 fetch c5a into c5arec;
 close c5a;

 if currsupplier <> c3rec.supplier_customer_id
  then
   is_partshipment := FALSE;
   is_loop := FALSE;
 end if;

 if not is_loop
  then

   if c5rec.entry_no is null
    then
     is_partshipment := FALSE;
    else
     is_partshipment := TRUE;
   end if;

   if c5arec.entry_no is null and is_partshipment
    then
     is_loop := TRUE;
    else
     is_loop := FALSE;
   end if;

 end if;

 if not (is_partshipment and is_loop)
  then

   if currsupplier = 0 or
      currsupplier = c3rec.supplier_customer_id
    then
     if currsupplier = 0
     then
       if created_duty
       then
--        glbx.dbg('Inner loop : ' || c4rec.tot ||' ' || c2rec.vcust_id );
        create_duty( vship_id, c4rec.tot, c2rec.vcust_id);
       end if;
       c4rec.tot := c4rec.tot + 0.0000001;
     end if;
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;
    else
     if created_duty then
--     glbx.dbg('Inner loop 2: ' || c4rec.tot ||' ' || c2rec.vcust_id );
     create_duty( vship_id, c4rec.tot,c2rec.vcust_id ); end if;
     c4rec.tot := c4rec.tot + 0.0000001;
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;
    end if;
    created_duty := TRUE;

  else

     if created_duty then
--     glbx.dbg('Inner loop 3: ' || c4rec.tot ||' ' || c2rec.vcust_id );
     create_duty( vship_id, c4rec.tot,c2rec.vcust_id ); end if;
     c4rec.tot := c4rec.tot + 0.0000001;
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;

  created_duty := TRUE;

 end if;

 currsupplier := c3rec.supplier_customer_id;

 end loop;
 -- Last Entry No has yet to be generated
 if created_duty then
--  glbx.dbg('Outer loop : ' || c4rec.tot ||' ' || c2rec.vcust_id );
  Create_duty( vship_id, c4rec.tot,c2rec.vcust_id ); end if;
end loop;
end generate_entry;

--- 20170518
procedure generate_entry_airfreight(vship_id in integer, vste in varchar2)
as
  cursor c2( vship_id integer) is
   select /*+ ALL_ROWS */ distinct r.cust_customer_id vcust_id
   from strang.detailrs dr, strang.receivals r,strang.movements m, strang.customers c
   where
    m.ship_id = ship_id and
    nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
    m.movement_no = dr.movement_no and
    dr.deliveryno = r.deliveryno and
    r.cust_customer_id = c.customer_id and
    c.customs_agent is not null
    order by r.cust_customer_id;

 cursor c3( vship_id integer, vcust_id integer ) is
  select /*+ ALL_ROWS */ r.cust_customer_id, dr.deliveryno,dr.rowid,r.supplier_customer_id,dr.hawb_hawbno
  from strang.detailrs dr, strang.receivals r,strang.movements m, strang.customers c
  where
   m.ship_id = vship_id and
   nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
   m.movement_no = dr.movement_no and
   dr.deliveryno = r.deliveryno and
   nvl(r.cust_customer_id,0) = vcust_id and
   nvl(r.cust_customer_id,0) = nvl(c.customer_id,0) and
   c.customs_agent is not null
  order by dr.line_no,dr.deliveryno,dr.itemno;

 cursor c4(vcust_id number) is
  select nvl(max(entry_no),vcust_id) tot
   from strang.detailrs
   where entry_no >= vcust_id and
   entry_no < (vcust_id + 1);

 cursor c5( dlr integer ) is select min(entry_no) entry_no from strang.detailrs dr where deliveryno = dlr;
 cursor c5a( dlr integer, ent number ) is select entry_no from strang.detailrs dr where deliveryno = dlr and entry_no = ent;


 c2rec		 c2%ROWTYPE;
 c3rec		 c3%ROWTYPE;
 c4rec		 c4%ROWTYPE;
 c5rec		 c5%ROWTYPE;
 c5arec		 c5a%ROWTYPE;
 currcustomer    integer;
 currhawb	 integer;
 is_maincustomer boolean;
 is_partshipment boolean;
 is_loop	 boolean;
 created_duty	 boolean;

begin

for c2rec in c2( vShip_id ) loop

open c4( c2rec.vcust_id );
fetch c4 into c4rec;
close c4;
c4rec.tot := nvl(c4rec.tot,0);
currcustomer:= c2rec.vcust_id;
currhawb := 0;
is_partshipment := FALSE;
is_loop := FALSE;
created_duty := FALSE;

for c3rec in c3( vShip_id, c2rec.vcust_id ) loop

 c5rec.entry_no := NULL;
 c5arec.entry_no := NULL;
 open c5(c3rec.deliveryno);
 fetch c5 into c5rec;
 close c5;
 open c5a(c3rec.deliveryno,c4rec.tot);
 fetch c5a into c5arec;
 close c5a;

 if currhawb <> c3rec.hawb_hawbno
  then
   is_partshipment := FALSE;
   is_loop := FALSE;
 end if;

 if not is_loop
  then

   if c5rec.entry_no is null
    then
     is_partshipment := FALSE;
    else
     is_partshipment := TRUE;
   end if;

   if c5arec.entry_no is null and is_partshipment
    then
     is_loop := TRUE;
    else
     is_loop := FALSE;
   end if;

 end if;

 if not (is_partshipment and is_loop)
  then

   if currhawb = 0 or
      currhawb = c3rec.hawb_hawbno
    then
     if currhawb = 0
     then
       if created_duty
       then
--        glbx.dbg('Inner loop : ' || c4rec.tot ||' ' || c2rec.vcust_id );
        create_duty( vship_id, c4rec.tot, c2rec.vcust_id);
       end if;
       c4rec.tot := c4rec.tot + 0.0000001;
     end if;
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;
    else
     if created_duty then
--     glbx.dbg('Inner loop 2: ' || c4rec.tot ||' ' || c2rec.vcust_id );
     create_duty( vship_id, c4rec.tot,c2rec.vcust_id ); end if;
     c4rec.tot := c4rec.tot + 0.0000001;
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;
    end if;
    created_duty := TRUE;

  else

     if created_duty then
--     glbx.dbg('Inner loop 3: ' || c4rec.tot ||' ' || c2rec.vcust_id );
     create_duty( vship_id, c4rec.tot,c2rec.vcust_id ); end if;
     c4rec.tot := c4rec.tot + 0.0000001;
     update strang.detailrs
      set
       entry_no = c4rec.tot
      where
      rowid = c3rec.rowid;

  created_duty := TRUE;

 end if;

 currhawb := c3rec.hawb_hawbno;

 end loop;
 -- Last Entry No has yet to be generated
 if created_duty then
--  glbx.dbg('Outer loop : ' || c4rec.tot ||' ' || c2rec.vcust_id );
  Create_duty( vship_id, c4rec.tot,c2rec.vcust_id ); end if;
end loop;
end generate_entry_airfreight;

--- 20170518

procedure create_duty(vship_id varchar2, entryno number, vcust_id integer)
as

 cursor c3( vship_id integer, entryno in number, vcust_id integer ) is
  select dr.rowid,dr.deliveryno,entry_no,line_no, l2.description rate, round(c.freight/l3.description,2) freight,c.insurance,c.other_costs,c.vat, c.infreight, c.deductions,
         m.bol,nvl(m.container_type,'BREAK BULK') container_type,r.supplier_customer_id supplier, r.curr, sa.estarrive, c.levy_rate
  from strang.detailrs dr, strang.movements m, strang.lov l, strang.ships_airway sa, strang.receivals r, strang.lov l2, strang.customers c, strang.lov l3
  where
   m.ship_id = vship_id and
   sa.ship_id = m.ship_id and
   nvl(m.container_type,'BREAK BULK') = l.code and
   l.lov_name = 'CTRTYPE' and
   l2.lov_name = 'UNRATTAB' and
   l2.code = r.curr and
   to_date(glbx.guess_date(l2.cola),'DD-MON-YYYY') <= sa.estarrive and
   nvl(to_date(glbx.guess_date(l2.colb),'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
   l3.lov_name = 'UNRATTAB' and
   l3.code = 'USD' and
   to_date(glbx.guess_date(l3.cola),'DD-MON-YYYY') <= sa.estarrive and
   nvl(to_date(glbx.guess_date(l3.colb),'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
   r.deliveryno = dr.deliveryno and
   r.cust_customer_id = c.customer_id and
   dr.movement_no = m.movement_no and
   nvl(dr.camov_seal,'|') = nvl(seal,'|') and
   dr.entry_no = entryno;

cursor c5( entryno number ) is
  select /*+ ALL_ROWS */ sum(p.tamount) tot
  from strang.pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from strang.detailrs dr
    where entry_no = entryno
   );

cursor c5a( entryno number ) is
  select /*+ ALL_ROWS */ sum(nvl(p.delivery_charge,0)) totdc
  from strang.pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from strang.detailrs dr
    where entry_no = entryno
   );

 cursor c7a( entryno number, vat number, ratio_factor number ) is
 select /*+ ALL_ROWS */ sum(kvalue) kvalue, sum(duty) duty, sum(excise) excise, sum(vat) vat,sum(old_duty) old_duty
 from
 (
  select /*+ ALL_ROWS */
       sum(tamount) * nvl(ratio_factor,1) kvalue,
       sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100) duty,
       ((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100))) * (nvl(to_number(t.colc),0)/100) excise,
       ((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100)) +
        (((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100))) * (nvl(to_number(t.colc),0)/100))
       ) * (nvl(vat,0)/100) vat,
       (t.colb * sum(tamount) * nvl(ratio_factor,1)) / 100 old_duty
from strang.lov i, strang.pos p, strang.lov t
where i.code = p.inventoryno and
      i.lov_name = 'INVENT' and
      t.lov_name = 'TARIFF' and
      p.deliveryno in
         (select distinct dr.deliveryno
          from strang.detailrs dr
          where entry_no = entryno
      ) and
      t.code = i.cola
group by i.description, t.code, p.ctry_countrycode, p.unit_unitused, t.colb, ratio_factor, t.description, t.colc, vat
  );


cursor c11b(shipid integer, entryno number, fr number ) is
  select /*+ ALL_ROWS */ sum(strang.revenue_tonne(partweight,partvolume) * nvl(fr,0)) sm
  from strang.detailrs dr, strang.movements m
  where m.ship_id=shipid and
        m.movement_no = dr.movement_no and
        nvl(dr.camov_seal,'|') = nvl(seal,'|') and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no = entryno);

cursor c11c(shipid integer, entryno number, ifr number ) is
  select /*+ ALL_ROWS */ sum(strang.revenue_tonne(partweight,partvolume) * nvl(ifr,0)) ism
  from strang.detailrs dr, strang.movements m
  where m.ship_id=shipid and
        m.movement_no = dr.movement_no and
        nvl(dr.camov_seal,'|') = nvl(seal,'|') and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no = entryno);



cursor c14( dlr integer, ent number ) is
   select min(entry_no)
   from strang.detailrs dr
   where dr.deliveryno = dlr and
         entry_no <> ent;

 c3rec		c3%ROWTYPE;
 c5arec		c5a%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 c11rec		c11b%ROWTYPE;
 c11crec	c11c%ROWTYPE;
 ti		number;
 tdc		number;
 dt		number;
 rf		number;
 pin		number;
 v1		number;
 v2		number;
 v3		number;
 v4		number;
 v5		number;
 v6		number;
 lv		number;

begin

    open c3(vship_id,entryno, vcust_id);
    fetch c3 into c3rec;
    close c3;
    if c3rec.entry_no is null then return; end if;
--  glbx.dbg('GOT THERE : ' || C3REC.ENTRY_NO );

    -- Note: Do not set to 0. Must be Null, code relies on it to be NULL
    pin := NULL;
    open c14(c3rec.deliveryno,c3rec.entry_no);
    fetch c14 into pin;
    close c14;
    if pin is not null and pin < c3rec.entry_no then null; else pin := null; end if;

    open c5( c3rec.entry_no );
    fetch c5 into ti;
    close c5;

    open c5a( c3rec.entry_no );
    fetch c5a into tdc;
    close c5a;

    open c11b( vship_id, c3rec.entry_no, c3rec.freight );
    fetch c11b into c11rec;
    close c11b;

    open c11c( vship_id, c3rec.entry_no, c3rec.infreight );
    fetch c11c into c11crec;
    close c11c;


    v1 := ti / c3rec.rate;
    v2 := c11rec.sm;
    v3 := v1 * (c3rec.insurance/100);
    v4 := (v1 * (c3rec.other_costs/100))+(nvl(tdc,0)/c3rec.rate);
    v5 := nvl(c11crec.ism,0);
    v6 := nvl(v1 * (c3rec.deductions/100),0);
    if nvl(ti,0) = 0
     then
      rf := 0;
     else
      rf := round((v1+v2+v3+v4+v5-v6)/ti,8);
    end if;

    open c7a(c3rec.entry_no, c3rec.vat, rf);
    fetch c7a into c7arec;
    close c7a;

    if pin is null
     then
      lv := nvl(((c7arec.duty + c7arec.excise + c7arec.kvalue) * c3rec.levy_rate ) / 100 , 0);
      update strang.duty
        set
	  total_invoice = v1,
	  duty = c7arec.duty,
	  ratio_factor = rf,
	  correct_freight = round(v2,2),
	  internal_freight = round(v5,2),
	  other_costs = round(v4,2),
	  insurance = round(v3,3),
	  deductions = round(v6,2),
	  previous_entry_no= pin,
          excise = c7arec.excise,
          vat = c7arec.vat,
          pvariance = (c7arec.duty + c7arec.excise + c7arec.vat + lv) - ((c7arec.kvalue * (1.5/100)) + c7arec.old_duty),
          levy = lv,
          exrate = c3rec.rate
       where
	   entry_no = c3rec.entry_no;
      if sql%NOTFOUND
       then
         insert into strang.duty
         ( entry_no, total_invoice, duty, ratio_factor, correct_freight, internal_freight, other_costs, deductions, insurance, previous_entry_no, excise, vat, pvariance, levy, exrate )
          values
         ( c3rec.entry_no, v1, c7arec.duty, rf, round(v2,2), round(v5,2), round(v4,2), round(v6,2), round(v3,2) , pin, c7arec.excise, c7arec.vat, (c7arec.duty + c7arec.excise + c7arec.vat + lv) - ((c7arec.kvalue * (1.5/100)) + c7arec.old_duty), lv, c3rec.rate);
      end if;

    else

      -- Partshipments do not have values except form previous_entry_no
      update strang.duty
        set
	  total_invoice = null,
	  duty = null,
	  ratio_factor = null,
	  correct_freight = null,
	  internal_freight = null,
	  other_costs = null,
	  deductions = null,
	  insurance = null,
	  previous_entry_no= pin,
          excise = null,
          vat = null,
          pvariance = null,
          levy = null,
          exrate = null
       where
	   entry_no = c3rec.entry_no;
      if sql%NOTFOUND
       then
         insert into strang.duty         ( entry_no, previous_entry_no )
          values
         ( c3rec.entry_no, pin );
      end if;

    end if;

exception when others
 then
  glbx.dbg('Error in Create Duty [movement.ship_id = ' || vship_id || ', detailrs.entry_no = ' || entryno || ']: ' || sqlerrm);
end create_duty;
----
procedure create_duty_com(vship_id varchar2, entryno number, vcust_id integer)
as

 cursor c3( vship_id integer, entryno in number, vcust_id integer ) is
  select dr.rowid,dr.deliveryno,entry_no_com,line_no, l2.description rate, round(c.freight/l3.description,2) freight,c.insurance,c.other_costs,c.vat, c.infreight, c.deductions,
         m.bol,nvl(m.container_type,'BREAK BULK') container_type,r.supplier_customer_id_com supplier, r.curr, sa.estarrive, c.levy_rate
  from strang.detailrs dr, strang.movements m, strang.lov l, strang.ships_airway sa, strang.receivals r, strang.lov l2, strang.customers c, strang.lov l3
  where
   m.ship_id = vship_id and
   sa.ship_id = m.ship_id and
   nvl(m.container_type,'BREAK BULK') = l.code and
   l.lov_name = 'CTRTYPE' and
   l2.lov_name = 'UNRATTAB' and
   l2.code = r.curr and
   to_date(glbx.guess_date(l2.cola),'DD-MON-YYYY') <= sa.estarrive and
   nvl(to_date(glbx.guess_date(l2.colb),'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
   l3.lov_name = 'UNRATTAB' and
   l3.code = 'USD' and
   to_date(glbx.guess_date(l3.cola),'DD-MON-YYYY') <= sa.estarrive and
   nvl(to_date(glbx.guess_date(l3.colb),'DD-MON-YYYY'),sa.estarrive) >= sa.estarrive and
   r.deliveryno = dr.deliveryno and
   r.cust_customer_id = c.customer_id and
   dr.movement_no = m.movement_no and
   nvl(dr.camov_seal,'|') = nvl(seal,'|') and
   dr.entry_no_com = entryno;

cursor c5( entryno number ) is
  select /*+ ALL_ROWS */ sum(p.tamount) tot
  from strang.pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from strang.detailrs dr
    where dr.entry_no_com = entryno
   );

cursor c5a( entryno number ) is
  select /*+ ALL_ROWS */ sum(nvl(p.delivery_charge,0)) totdc
  from strang.pos p
  where p.deliveryno in
   (select distinct dr.deliveryno
    from strang.detailrs dr
    where dr.entry_no_com = entryno
   );

 cursor c7a( entryno number, vat number, ratio_factor number ) is
 select /*+ ALL_ROWS */ sum(kvalue) kvalue, sum(duty) duty, sum(excise) excise, sum(vat) vat,sum(old_duty) old_duty
 from
 (
  select /*+ ALL_ROWS */
       sum(tamount) * nvl(ratio_factor,1) kvalue,
       sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100) duty,
       ((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100))) * (nvl(to_number(t.colc),0)/100) excise,
       ((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100)) +
        (((sum(tamount) * nvl(ratio_factor,1)) + (sum(tamount) * nvl(ratio_factor,1) * (nvl(to_number(t.description),0)/100))) * (nvl(to_number(t.colc),0)/100))
       ) * (nvl(vat,0)/100) vat,
       (t.colb * sum(tamount) * nvl(ratio_factor,1)) / 100 old_duty
from strang.lov i, strang.pos p, strang.lov t
where i.code = p.inventoryno and
      i.lov_name = 'INVENT' and
      t.lov_name = 'TARIFF' and
      p.deliveryno in
         (select distinct dr.deliveryno
          from strang.detailrs dr
          where dr.entry_no_com = entryno
      ) and
      t.code = i.cola
group by i.description, t.code, p.ctry_countrycode, p.unit_unitused, t.colb, ratio_factor, t.description, t.colc, vat
  );


cursor c11b(shipid integer, entryno number, fr number ) is
  select /*+ ALL_ROWS */ sum(strang.revenue_tonne(partweight,partvolume) * nvl(fr,0)) sm
  from strang.detailrs dr, strang.movements m
  where m.ship_id=shipid and
        m.movement_no = dr.movement_no and
        nvl(dr.camov_seal,'|') = nvl(seal,'|') and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no_com = entryno);

cursor c11c(shipid integer, entryno number, ifr number ) is
  select /*+ ALL_ROWS */ sum(strang.revenue_tonne(partweight,partvolume) * nvl(ifr,0)) ism
  from strang.detailrs dr, strang.movements m
  where m.ship_id=shipid and
        m.movement_no = dr.movement_no and
        nvl(dr.camov_seal,'|') = nvl(seal,'|') and
        dr.deliveryno in
         (select dr2.deliveryno from strang.detailrs dr2 where dr2.entry_no_com = entryno);



cursor c14( dlr integer, ent number ) is   -- partshipment query 20161021
   select min(entry_no)
   from strang.detailrs dr
   where dr.deliveryno = dlr and
         entry_no < ent;

 c3rec		c3%ROWTYPE;
 c5arec		c5a%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 c11rec		c11b%ROWTYPE;
 c11crec	c11c%ROWTYPE;
 ti		number;
 tdc		number;
 dt		number;
 rf		number;
 pin		number;
 v1		number;
 v2		number;
 v3		number;
 v4		number;
 v5		number;
 v6		number;
 lv		number;

begin

    open c3(vship_id,entryno, vcust_id);
    fetch c3 into c3rec;
    close c3;
    if c3rec.entry_no_com is null then return; end if;
--  glbx.dbg('GOT THERE : ' || C3REC.ENTRY_NO_com );

    -- Note: Do not set to 0. Must be Null, code relies on it to be NULL
    pin := NULL;
    open c14(c3rec.deliveryno,c3rec.entry_no_com);
    fetch c14 into pin;
    close c14;
    if pin is not null and pin < c3rec.entry_no_com then null; else pin := null; end if;

    open c5( c3rec.entry_no_com );
    fetch c5 into ti;
    close c5;

    open c5a( c3rec.entry_no_com );
    fetch c5a into tdc;
    close c5a;

    open c11b( vship_id, c3rec.entry_no_com, c3rec.freight );
    fetch c11b into c11rec;
    close c11b;

    open c11c( vship_id, c3rec.entry_no_com, c3rec.infreight );
    fetch c11c into c11crec;
    close c11c;


    v1 := ti / c3rec.rate;
    v2 := c11rec.sm;
    v3 := v1 * (c3rec.insurance/100);
    v4 := (v1 * (c3rec.other_costs/100))+(nvl(tdc,0)/c3rec.rate);
    v5 := nvl(c11crec.ism,0);
    v6 := nvl(v1 * (c3rec.deductions/100),0);
    if nvl(ti,0) = 0
     then
      rf := 0;
     else
      rf := round((v1+v2+v3+v4+v5-v6)/ti,8);
    end if;

    open c7a(c3rec.entry_no_com, c3rec.vat, rf);
    fetch c7a into c7arec;
    close c7a;

    if pin is null
     then
      lv := nvl(((c7arec.duty + c7arec.excise + c7arec.kvalue) * c3rec.levy_rate ) / 100 , 0);
      update strang.duty
        set
	  total_invoice = v1,
	  duty = c7arec.duty,
	  ratio_factor = rf,
	  correct_freight = round(v2,2),
	  internal_freight = round(v5,2),
	  other_costs = round(v4,2),
	  insurance = round(v3,3),
	  deductions = round(v6,2),
	  previous_entry_no= pin,
          excise = c7arec.excise,
          vat = c7arec.vat,
          pvariance = (c7arec.duty + c7arec.excise + c7arec.vat + lv) - ((c7arec.kvalue * (1.5/100)) + c7arec.old_duty),
          levy = lv,
          exrate = c3rec.rate
       where
	   entry_no = c3rec.entry_no_com;
      if sql%NOTFOUND
       then
         insert into strang.duty
         ( entry_no, total_invoice, duty, ratio_factor, correct_freight, internal_freight, other_costs, deductions, insurance, previous_entry_no, excise, vat, pvariance, levy, exrate )
          values
         ( c3rec.entry_no_com, v1, c7arec.duty, rf, round(v2,2), round(v5,2), round(v4,2), round(v6,2), round(v3,2) , pin, c7arec.excise, c7arec.vat, (c7arec.duty + c7arec.excise + c7arec.vat + lv) - ((c7arec.kvalue * (1.5/100)) + c7arec.old_duty), lv, c3rec.rate);
      end if;

    else

      -- Partshipments do not have values except form previous_entry_no
      update strang.duty
        set
	  total_invoice = null,
	  duty = null,
	  ratio_factor = null,
	  correct_freight = null,
	  internal_freight = null,
	  other_costs = null,
	  deductions = null,
	  insurance = null,
	  previous_entry_no= pin,
          excise = null,
          vat = null,
          pvariance = null,
          levy = null,
          exrate = null
       where
	   entry_no = c3rec.entry_no_com;
      if sql%NOTFOUND
       then
         insert into strang.duty
         ( entry_no, previous_entry_no )
          values
         ( c3rec.entry_no_com, pin );
      end if;

    end if;

exception when others
 then
  glbx.dbg('Error in Create Duty [movement.ship_id = ' || vship_id || ', detailrs.entry_no_com = ' || entryno || ']: ' || sqlerrm);
end create_duty_com;

---
procedure create_line_no( vShip_id integer, typ in varchar2 )
as

 cursor c1( vship_id integer ) is
  select dr.rowid
  from strang.detailrs dr, strang.movements m, strang.lov l, strang.receivals r, strang.customers c
  where
   m.ship_id = vship_id and
   nvl(m.container_type,'BREAK BULK') = l.code and
   l.lov_name = 'CTRTYPE' and
   dr.movement_no = m.movement_no and
   nvl(dr.camov_seal,'|') = nvl(seal,'|') and
   dr.deliveryno = r.deliveryno and
   r.supplier_customer_id = c.customer_id
  order by m.movement_type,nvl(l.cola,chr(32)),m.bol,m.container_type,m.movement_no,c.customer, dr.deliveryno,dr.itemno;

 cursor c1m( vship_id integer ) is
  select dr.rowid
  from strang.detailrs dr, strang.movements m, strang.receivals r, strang.customers c
  where
   m.ship_id = vship_id and
   dr.movement_no = m.movement_no and
   nvl(dr.camov_seal,'|') = nvl(m.seal,'|') and
   dr.deliveryno = r.deliveryno and
   r.supplier_customer_id = c.customer_id
  order by m.movement_no,c.customer, dr.deliveryno,dr.itemno;

 ctr		integer;

begin

 ctr := 1;

 if typ = 'SHIP'
  then
   for c1rec in c1(to_number(vship_id)) loop
    update strang.detailrs set line_no = ctr where rowid = c1rec.rowid;
    ctr := ctr + 1;
   end loop;

 elsif typ = 'AIRWAY'
  then
   for c1mrec in c1m(vship_id) loop
    update strang.detailrs set line_no = ctr where rowid = c1mrec.rowid;
    ctr := ctr + 1;
   end loop;
 end if;

end create_line_no;

procedure unallocate_entry( vShip_id integer )
as

begin

  delete from strang.duty
   where entry_no in
    (select entry_no
     from strang.detailrs dr, strang.movements m
     where
      ship_id = vShip_id and
      m.movement_no = dr.movement_no and
      nvl(m.seal,'|') = nvl(dr.camov_seal,'|')
    );


  update strang.detailrs dr
   set
    entry_no = null
  where
   (movement_no,nvl(dr.camov_seal,'|')) in (select movement_no,nvl(m.seal,'|') from strang.movements m where ship_id = vship_id);

end unallocate_entry;

procedure generate_ships_manifest( vship_id varchar2, action in varchar2 default 'LINE_NO', typ in varchar2 default 'SHIP', entryno in number default null, vste in varchar2 )
as

begin

 -- Generate Line Numbers
 if action = 'LINE_NO'
  then
   create_line_no(vship_id,typ);
   commit;
 end if;

 if action in ('DUTY')
  then
   unallocate_entry(vship_id);
   -- Generate Entry Numbers
   if typ = 'AIRWAY' then
    generate_entry_airfreight(vship_id,nvl(vste,OLTP.USER_SITE));
   else
    generate_entry(vship_id,nvl(vste,OLTP.USER_SITE));
   end if;
   commit;
 end if;

 if action in ('EXCISE')
  then
   create_duty(vShip_id,entryno, trunc(entryno));
   commit;
 end if;

 if action in ('T_EXCISE')
  then
   create_duty_com(vShip_id,entryno, trunc(entryno));
   commit;
 end if;

 if action in ('UNALLOCATE')
  then
   unallocate_entry(vship_id);
   commit;
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_SHIPS_MANIFEST',null,null,errmsg=>sqlerrm,extdet=>'VSHIP_ID:' || vship_id);
end generate_ships_manifest;

procedure invoke_report( surl in varchar2, repname in varchar2, r1 in varchar2 default null, r2 in varchar2 default null, r3 in varchar2 default null )
as

 cursor c1(repname varchar2) is select report_id from report_definition where upper(report_name) = upper(repname);
 cursor c2(repid integer) is select parameter_name, parameter_type from report_parameters where report_id = repid order by order_by;
 cursor c3(repid integer) is select max(parameter_level) mx from report_parameters where report_id = repid;

 c1rec	c1%ROWTYPE;
 c3rec	c3%ROWTYPE;
 p0     GLBX.MYARRAY;
 p1     GLBX.MYARRAY;
 p2     GLBX.MYARRAY;

begin
 open c1( repname );
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.htmlopen;
   htp.header(3,LNGS.STR_TXT_308 || ' : ' || repname, 'CENTER' );
   htp.htmlclose;
   return;
 end if;
 close c1;

 for c2rec in c2( c1rec.report_id ) loop
  if c2%ROWCOUNT = 1
   then
    p0(1) := c2rec.parameter_name;
    p1(1) := r1;
    if c2rec.parameter_type in ('SQL','CONSTANT') then p2(1) := 'C'; else p2(1) := 'RFROM'; end if;
  elsif c2%ROWCOUNT = 2
   then
    p0(2) := c2rec.parameter_name;
    p1(2) := r2;
    if c2rec.parameter_type in ('SQL','CONSTANT') then p2(2) := 'C'; else p2(2) := 'RFROM'; end if;
  elsif c2%ROWCOUNT = 3
   then
    p0(3) := c2rec.parameter_name;
    p1(3) := r3;
    if c2rec.parameter_type in ('SQL','CONSTANT') then p2(3) := 'C'; else p2(3) := 'RFROM'; end if;
  end if;
 end loop;

 open c3( c1rec.report_id );
 fetch c3 into c3rec;
 close c3;
 oltp.run_report( surl, c1rec.report_id, c3rec.mx + 1, p0, p1, p2 );

exception when others then
 glbx.error_details( 'STRANGP', 'INVOKE_REPORT',null,null,errmsg=>sqlerrm,extdet=>'REPNAME:' || repname);
end invoke_report;

procedure display_report( surl in varchar2, acid in integer, typ in varchar2, repname in varchar2, r1 in varchar2 default null, r2 in varchar2 default null, r3 in varchar2 default null )
as

 cursor c1(repname varchar2) is select report_id from report_definition where upper(report_name) = upper(repname);

 c1rec	c1%ROWTYPE;
 secaccess	varchar2(100);

begin

 secaccess := data_access(acid,typ,null);
 if secaccess = 'NONE' then return; end if;

 if secaccess = 'READ'
  then
   open c1( repname );
   fetch c1 into c1rec;
   if c1%FOUND
    then
     htp.anchor2( 'oltp.view_report?surl=' || surl || '&repid=' || c1rec.report_id,repname,ctarget=>'_top');
     htp.nl;
   end if;
   close c1;
 end if;

 if secaccess = 'EDIT'
  then
   htp.anchor2( 'strangp.invoke_report?surl=' || surl || '&repname=' || replace(repname,' ','+' ) || '&r1=' || replace(r1,' ','+') || '&r2=' || replace(r2,' ','+') || '&r3=' || replace(r3,' ','+'),repname,ctarget=>'_top');
   htp.nl;
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'DISPLAY_REPORT',null,null,errmsg=>sqlerrm,extdet=>'REPNAME:' || repname);
end display_report;

procedure mng_cust( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, scid in varchar2 default null, access_id in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.customers where rowid = rid;
 cursor c2a is select * from strang.customers where rownum < 2 order by customer;
 cursor c2b( custid integer) is select rowid from strang.customers where customer_id = custid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c2brec		c2b%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.MNG_CUST' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'CUSTOMERS', rid );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, LNGS.STR_TXT_321,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR21',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '<CENTER>' );
 if id is null and rid is not null
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
 elsif id is null
  then
   open c2a;
   fetch c2a into c2rec;
   close c2a;
   open c2b(c2rec.customer_id);
   fetch c2b into c2brec;
   close c2b;
 elsif nvl(id,'x') <> 'z'
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
 end if;

 htp.formopen( 'strangp.accept_mng_cust', ctarget=>'_top' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', replace(nvl(rid,c2brec.rowid),'~','+') );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
 if c2rec.customer_id is not null
  then
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNGS.STR_TXT_324),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold(c2rec.customer_id),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tablerowclose;
  end if;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_325),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P1', 60, 100, c2rec.customer),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.customer),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('OTML Vendor ID'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P1i', 60, 100, c2rec.sap_vendor_id),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.sap_vendor_id),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_326),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P2', 30, 30, c2rec.street),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.street),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_327),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P3', 30, 30, c2rec.suburb),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.suburb),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_328),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P4', 20, 20, c2rec.state),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.state),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
   htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_329),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P5', 10, 10, c2rec.postcode),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.postcode),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_330),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P6', 25, 25, c2rec.city),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.city),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_331),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P7', 25, 25, c2rec.country),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.country),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_332),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P8', 20, 20, c2rec.abn),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.abn),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_333),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P9', 60, 60, c2rec.email),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.email),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_334),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P10', 20, 20, c2rec.phone),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.phone),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_335),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P11', 20, 20, c2rec.fax),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.fax),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
  if c2rec.customer_type = 'CUSTOMER'
   then
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_395),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      customer_list( 'PARTY', 'P13', c2rec.shipper_id, FALSE );
     else
      customer_list( 'PARTY', 'P13', c2rec.shipper_id, FALSE, isedit=>FALSE );
    end if;
     htp.p(('&nbsp;&nbsp;('||' ID '||c2rec.shipper_id|| ') &nbsp;&nbsp;&nbsp;&nbsp;'||strang.f_get_party_address(c2rec.shipper_id)));
     htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Consigned To'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      customer_list( 'PARTY', 'P14a', c2rec.consigned_to_id, FALSE );
     else
      customer_list( 'PARTY', 'P14a', c2rec.consigned_to_id, FALSE, isedit=>FALSE );
    end if;
     htp.p(('&nbsp;&nbsp;('||' ID '||c2rec.consigned_to_id|| ') &nbsp;&nbsp;&nbsp;&nbsp;'||strang.f_get_party_address(c2rec.consigned_to_id)));
     htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Notify Party'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      customer_list( 'PARTY', 'P14', c2rec.notify_party_id, FALSE );
     else
      customer_list( 'PARTY', 'P14', c2rec.notify_party_id, FALSE, isedit=>FALSE );
    end if;
     htp.p(('&nbsp;&nbsp;('||' ID '||c2rec.notify_party_id||' ) &nbsp;&nbsp;&nbsp;&nbsp;'|| strang.f_get_party_address(c2rec.notify_party_id)));
     htp.p( '</TD>' );
  htp.tablerowclose;


  end if;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_336),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT' and id = 'z'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">');
     htp.formselectopen( 'P12' );
     htp.formselectoption( 'CUSTOMER' );
     htp.formselectoption( 'SUPPLIER', 'SELECTED' );
     htp.formselectoption( 'PARTY' );
     htp.formselectoption( 'AGENT' );
     htp.formselectoption( 'BRANCHES' );
     htp.formselectoption( 'AIRALERT' );
     htp.formselectoption( lngs.STR_STH_001 ); -- SOUTHBOUND -- xxxSouthbound
     htp.formselectclose;
     htp.p( '</TD>' );
   elsif vaccess = 'EDIT'
    then
     htp.tabledata( htf.bold(c2rec.customer_type),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     htp.formhidden( 'P12', c2rec.customer_type );
    else
     htp.tabledata( htf.bold(c2rec.customer_type),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 -- ============================================================================================================================
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNGS.STR_TXT_199),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'LOCATIONS', 'R6', c2rec.port_from, FALSE, TRUE, FALSE );
     else
      lov_list( 'LOCATIONS', 'R6', c2rec.port_from, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold('Place of Loading/Unloading'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNLOCTAB', 'R6_1', c2rec.sad_lop_cod, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNLOCTAB', 'R6_1', c2rec.sad_lop_cod, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold(LNGS.STR_TXT_177),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      customer_list( 'AGENT', 'R7', c2rec.customs_agent, FALSE );
     else
      customer_list( 'AGENT', 'R7', c2rec.customs_agent, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold('Country of 1st Dest/Last Provenance'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNCTYTAB', 'R6_2', c2rec.sad_cty_1dlp, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNCTYTAB', 'R6_2', c2rec.sad_cty_1dlp, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Position'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
        htp.formtext('R22',20,30, c2rec.position);
     else
        htp.bold(c2rec.position);
    end if;
    htp.p( '</TD>' );
    htp.tabledata( htf.bold('Trading Country'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNCTYTAB', 'R6_3', c2rec.sad_tra_cty, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNCTYTAB', 'R6_3', c2rec.sad_tra_cty, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_200),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R8',20,20, c2rec.licence_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.licence_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
    htp.tabledata( htf.bold('Country of Export'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNCTYTAB', 'R6_4', c2rec.sad_cty_expcod, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNCTYTAB', 'R6_4', c2rec.sad_cty_expcod, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_201),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R9',20,15, c2rec.p2acode),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.p2acode),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
    htp.tabledata( htf.bold('Country of Destination'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNCTYTAB', 'R6_5', c2rec.sad_cty_destcod, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNCTYTAB', 'R6_5', c2rec.sad_cty_destcod, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_202),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R10',20,30, c2rec.cpc),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.cpc),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
    htp.tabledata( htf.bold('Warehouse Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNWHSTAB', 'R6_6', c2rec.sad_whs_cod, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNWHSTAB', 'R6_6', c2rec.sad_whs_cod, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_144),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R21',70,200, c2rec.pcomment),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.pcomment),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
    htp.tabledata( htf.bold('Warehouse Time Delay'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
     then
      htp.tabledata( htf.formtext('R6_7',20,10, to_char(c2rec.sad_whs_time)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
      htp.tabledata( htf.bold(to_char(c2rec.sad_whs_time)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_203),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        if (c2rec.comparative_worksheet is not null) or (c2rec.port_from is null) -- entered in first time
         then
          htp.tabledata( htf.formcheckbox( 'R11', 'T', 'CHECKED' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
         else
          htp.tabledata( htf.formcheckbox( 'R11', 'T' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
        end if;
       else
        htp.tabledata( htf.bold(c2rec.comparative_worksheet),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
    htp.tabledata( htf.bold('Location of Goods'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNSHDTAB', 'R6_8', c2rec.sad_loc_goods, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNSHDTAB', 'R6_8', c2rec.sad_loc_goods, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
  htp.tableclose;

  htp.nl;
  htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
  htp.tablerowopen;
  htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_204),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R14',15,15, c2rec.account_number),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.account_number),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_205),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R12',15,15, c2rec.preceding_documents),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.preceding_documents),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Terms of Delivery'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNTODTAB', 'R13', c2rec.terms_of_delivery, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNTODTAB', 'R13', c2rec.terms_of_delivery, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Bank Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R13_1',15,30, c2rec.bank_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.bank_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Bank Name'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R13_2',15,30, c2rec.bank_name),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.bank_name),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Branch'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R13_3',15,30, c2rec.branch),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.branch),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Terms of Payment'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R13_4',15,30, c2rec.terms_of_payment),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.terms_of_payment),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Bank Ref No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R13_5',15,30, c2rec.bank_ref_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.bank_ref_no),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</TD>' );

  htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
      htp.tabledata( htf.bold('External '||LNGS.STR_TXT_212|| htf.nl ||'USD per RevTonne'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R2',10,20, to_char(c2rec.freight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.freight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Inland Freight'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R2_1',10,20, to_char(c2rec.infreight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.infreight)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_215),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R3',10,20, to_char(c2rec.insurance)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.insurance)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_216),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R4',10,20, to_char(c2rec.vat)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.vat)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold(LNGS.STR_TXT_217),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R5',10,20, to_char(c2rec.other_costs)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.other_costs)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Levy Rate'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R5V',10,20, trim(to_char(c2rec.levy_rate,'999999.99'))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(trim(to_char(c2rec.levy_rate,'999999.99'))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Deductions'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R2_2',10,20, to_char(c2rec.deductions)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.deductions)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.p( '</TD>' );
  htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tabledata( htf.bold('Attachments'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT'
    then
     lov_list( 'UNATDTAB', 'R15', c2rec.attachments_invoices, FALSE, FALSE, FALSE );
    else
     lov_list( 'UNMODTAB', 'R15', c2rec.attachments_invoices, FALSE, FALSE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Attachments'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT'
    then
     lov_list( 'UNATDTAB', 'R16', c2rec.attachments_packing, FALSE, FALSE, FALSE );
    else
     lov_list( 'UNMODTAB', 'R16', c2rec.attachments_packing, FALSE, FALSE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Attachments'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT'
    then
     lov_list( 'UNATDTAB', 'R17', c2rec.attachments_order, FALSE, FALSE, FALSE );
    else
     lov_list( 'UNMODTAB', 'R17', c2rec.attachments_order, FALSE, FALSE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Attachments'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT'
    then
     lov_list( 'UNATDTAB', 'R18', c2rec.attachments_licence, FALSE, FALSE, FALSE );
    else
     lov_list( 'UNMODTAB', 'R18', c2rec.attachments_licence, FALSE, FALSE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Attachments'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT'
    then
     lov_list( 'UNATDTAB', 'R19', c2rec.attachments_freight, FALSE, FALSE, FALSE );
    else
     lov_list( 'UNMODTAB', 'R19', c2rec.attachments_freight, FALSE, FALSE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Attachments'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
   if vaccess = 'EDIT'
    then
     lov_list( 'UNATDTAB', 'R20', c2rec.attachments_other, FALSE, FALSE, FALSE );
    else
     lov_list( 'UNMODTAB', 'R20', c2rec.attachments_other, FALSE, FALSE, FALSE, isedit=>FALSE );
   end if;
   htp.p( '</TD>' );
   htp.tablerowopen;
      htp.tabledata( htf.bold('Total Fees'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R20_1',10,10, to_char(c2rec.sad_tot_fees)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.sad_tot_fees)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Method of Payment'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R20_2',10,1, to_char(c2rec.method_of_payment)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.method_of_payment)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
  htp.tableclose;

 ----****
  htp.p( '<TD VALIGN="TOP" ALIGN="CENTER">' );
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Type of Declaration'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNMODTAB', 'R15_1', c2rec.sad_typ_dec, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNMODTAB', 'R15_1', c2rec.sad_typ_dec, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Type of Transit Document'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R15_2',10,5, c2rec.sad_typ_transit),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(c2rec.sad_typ_transit),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Declaration General Procedure'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNCP1TAB', 'R15_3', c2rec.sad_typ_proc, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNCP1TAB', 'R15_3', c2rec.sad_typ_proc, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Customs Clearance Office'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNCUOTAB', 'R15_4', c2rec.sad_cuo_code, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNCUOTAB', 'R15_4', c2rec.sad_cuo_code, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Border Customs Office'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNCUOTAB', 'R15_5', c2rec.sad_cuo_bord, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNCUOTAB', 'R15_5', c2rec.sad_cuo_bord, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Person Resp for Financial Settlement'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
    if vaccess = 'EDIT'
     then
      lov_list( 'UNCMPTAB', 'R15_6', c2rec.sad_financial, FALSE, TRUE, FALSE );
     else
      lov_list( 'UNCMPTAB', 'R15_6', c2rec.sad_financial, FALSE, TRUE, FALSE, isedit=>FALSE );
    end if;
    htp.p( '</TD>' );
   htp.tablerowclose;
   htp.tablerowopen;
      htp.tabledata( htf.bold('Terms of Delivery Place'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R15_7',10,17, to_char(c2rec.sad_tod_nam)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.sad_tod_nam)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;

   htp.tablerowopen;
      htp.tabledata( htf.bold('EPG'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
       then
        htp.tabledata( htf.formtext('R15_8',10,10, to_char(c2rec.epg)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       else
        htp.tabledata( htf.bold(to_char(c2rec.epg)),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      end if;
   htp.tablerowclose;
  htp.tableclose;
  htp.tablerowclose;
  htp.tableclose;
  htp.nl;

  htp.nl;

 -- ============================================================================================================================
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT' and nvl(id,'x') = 'z'
  then
   htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_322 ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'EDIT' and nvl(id,'x') <> 'z'
  then
   htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_323 ),cattributes=>'VALIGN="TOP"');
   if seclevel = 'LEVEL 7' then htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_337 ),cattributes=>'VALIGN="TOP"'); end if;
 end if;
 htp.formclose;
 if vaccess = 'EDIT' and nvl(id,'x') <> 'z'
  then
   htp.tabledata( htf.formopen( 'strangp.mng_cust', ctarget=>'CUSTOMER_WINDOW' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RID', null ) || htf.formsubmit( null, LNGS.STR_TXT_035 ) || htf.formclose,cattributes=>'VALIGN="TOP"');
 end if;
 htp.tablerowclose;
 htp.tableclose;
 search( surl, 'CUSTOMERS', rid );
 htp.nl;
 if call_name is null then htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl; end if;
 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MNG_CUST',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end mng_cust;

procedure accept_mng_cust( surl in varchar2, rid in varchar2, p1 in varchar2 default null, p1i in varchar2 , p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                           p5 in varchar2 default null, p6 in varchar2 default null, p7 in varchar2 default null, p8 in varchar2 default null, p9 in varchar2 default null,
                           p10 in varchar2 default null, p11 in varchar2 default null, p12 in varchar2 default null, p13 in varchar2 default null, p14 in varchar2 default null, p14a in varchar2 default null, action in varchar2,
                           r2 in varchar2, r2_1 in varchar2, r2_2 in varchar2, r3 in varchar2, r4 in varchar2, r5 in varchar2, r5v in varchar2,
                           r6 in varchar2, r6_1 in varchar2, r6_2 in varchar2, r6_3 in varchar2, r6_4 in varchar2, r6_5 in varchar2, r6_6 in varchar2, r6_7 in varchar2, r6_8 in varchar2,
                           r7 in varchar2, r8 in varchar2, r9 in varchar2,
                           r10 in varchar2, r11 in varchar2 default null, r12 in varchar2, r13 in varchar2, r13_1 in varchar2, r13_2 in varchar2, r13_3 in varchar2,
                           r13_4 in varchar2,r13_5 in varchar2,  r14 in varchar2, r15 in varchar2,
                           r15_1 in varchar2,r15_2 in varchar2,r15_3 in varchar2,r15_4 in varchar2,r15_5 in varchar2,r15_6 in varchar2,r15_7 in varchar2,r15_8 in varchar2,
                           r16 in varchar2, r17 in varchar2, r18 in varchar2, r19 in varchar2, r20 in varchar2, r20_1 in varchar2, r20_2 in varchar2, r21 in varchar2, r22 in varchar2 )

as

 cursor c1( cst varchar2 ) is select 'x' from strang.customers where upper(cst) = upper(customer);
 cursor c2( sto varchar2 ) is select max(customer_id) + 1 cnt from strang.customers;
 cursor c3( rid rowid ) is select customer from strang.customers where rowid = rid;
 cursor c11(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'DELIVERYNO' and cola = vste;

 cusrec		customer_account%ROWTYPE;
 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c11rec 	c11%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb1		integer;
 nmb2		integer;
 nmb3		integer;
 sts		varchar2(100);
 newrid		rowid;
 vste		varchar2(10);
  rmb1		number;
  rmb2		number;
  rmb3		number;
  rmb4		number;
  rmb5		number;
  rmb5a		number;
  rmb2_1	number;
  rmb2_2	number;
  rmb20_1	number;
  rmb20_2	number;
  rmb6_7        number;
  rmb15_3       number;
  rmb15_8       number;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ACCEPT_MNG_CUST' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  cusrec := glbx.get_aid( owner_id, 'C', ltype );
  vste := customer_state(cusrec.aid);

  if action = LNGS.STR_TXT_337
   then
    update strang.receivals
     set
      cust_customer_id = null
     where
      cust_customer_id = (select customer_id from strang.customers where rowid = chartorowid( replace(rid,'~','+') ));
    update strang.receivals
     set
      supplier_customer_id = null
     where
      supplier_customer_id = (select customer_id from strang.customers where rowid = chartorowid( replace(rid,'~','+') ));
    update strang.ships_airway
     set
      customer_id = null
     where
      customer_id = (select customer_id from strang.customers where rowid = chartorowid( replace(rid,'~','+') ));
/* 20140529
    update strang.ships_airway
     set
      customs_agent = null
     where
      customs_agent = (select customer_id from strang.customers where rowid = chartorowid( replace(rid,'~','+') ));
*/
	  delete from strang.customers where rowid = chartorowid( replace(rid,'~','+') );
    commit;
    menu( surl, to_char(sysdate,'SSSS'), 'CUSTOMERS');
    return;
  end if;

 begin nmb1 := to_number(p13); exception when others then nmb1 := NULL; end;
 begin nmb2 := to_number(p14); exception when others then nmb2 := NULL; end;
 begin nmb3 := to_number(p14a); exception when others then nmb3 := NULL; end;

 if action = LNGS.STR_TXT_322
  then
   if p1 is null
    then
     mng_cust(surl,null,'z',LNGS.STR_TXT_341);
     return;
   end if;
   open c1(p1);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     mng_cust(surl,null,'z',LNGS.STR_TXT_338);
     return;
   end if;
   close c1;
   open c2(currsite);
   fetch c2 into c2rec;
   close c2;
   -- Use deliveryno as the ID
   if c2rec.cnt is null
    then
     open c11(vste);
     fetch c11 into c11rec;
     close c11;
     c2rec.cnt := c11rec.description;
   end if;
   insert into strang.customers(customer,sap_vendor_id,street,suburb,state,postcode,city,country,abn,email,phone,fax,customer_type,customer_id,shipper_id,notify_party_id,consigned_to_id) values
    ( p1, p1i, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, c2rec.cnt,nmb1,nmb2,nmb3 ) returning rowid into newrid;
   commit;
   mng_cust(surl,newrid,'x',LNGS.STR_TXT_339);
   return;
 end if;

 open c3( chartorowid( replace(rid,'~','+') ));
 fetch c3 into c3rec;
 close c3;
 if p1 is null
  then
   mng_cust(surl,rid,'x',LNGS.STR_TXT_341);
   return;
 elsif p1 <> c3rec.customer
  then
   open c1(p1);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     mng_cust(surl,rid,'x',LNGS.STR_TXT_338);
     return;
   end if;
   close c1;
 end if;

  begin rmb2 := to_number(r2); exception when others then return; end;
  begin rmb2_1 := to_number(r2_1); exception when others then return; end;
  begin rmb2_2 := to_number(r2_2); exception when others then return; end;
  begin rmb3 := to_number(r3); exception when others then return; end;
  begin rmb4 := to_number(r4); exception when others then return; end;
  begin rmb5 := to_number(r5); exception when others then return; end;
  begin rmb5a := to_number(r5v); exception when others then return; end;
  begin rmb20_1 := to_number(r20_1); exception when others then return; end;
  begin rmb20_2 := to_number(r20_2); exception when others then return; end;
  begin rmb6_7 := to_number(r6_7); exception when others then return; end;
  begin rmb15_3 := to_number(r15_3); exception when others then return; end;
  begin rmb15_8 := to_number(r15_8); exception when others then return; end;


 update strang.customers
  set
   customer = p1,
   sap_vendor_id = p1i,
   street = p2,
   suburb = p3,
   state = p4,
   postcode = p5,
   city = p6,
   country = p7,
   abn = p8,
   email = p9,
   phone = p10,
   fax = p11,
   shipper_id=nmb1,
   notify_party_id = nmb2,
   consigned_to_id = nmb3,
   freight = rmb2,
   insurance = rmb3,
   vat = rmb4,
   other_costs = rmb5,
   port_from = r6,
   customs_agent = r7,
   licence_no = r8,
   p2acode = r9,
   cpc = r10,
   comparative_worksheet = r11,
   preceding_documents = r12,
   terms_of_delivery = r13,
   bank_code = r13_1,
   bank_name = r13_2,
   branch = r13_3,
   terms_of_payment = r13_4,
   bank_ref_no = r13_5,
   account_number = r14,
   attachments_invoices = r15,
   attachments_packing = r16,
   attachments_order = r17,
   attachments_licence = r18,
   attachments_freight = r19,
   attachments_other = r20,
   pcomment = r21,
   position = r22,
   levy_rate = rmb5a,
   infreight = rmb2_1,
   deductions = rmb2_2,
   sad_tot_fees = rmb20_1,
   method_of_payment = rmb20_2,
   sad_lop_cod = r6_1,
   sad_cty_1dlp = r6_2,
   sad_tra_cty = r6_3,
   sad_cty_expcod = r6_4,
   sad_cty_destcod = r6_5,
   sad_whs_cod = r6_6,
   sad_whs_time = rmb6_7,
   sad_loc_goods = r6_8,
   sad_typ_dec = r15_1,
   sad_typ_transit = r15_2,
   sad_typ_proc = rmb15_3,
   sad_cuo_code = r15_4,
   sad_cuo_bord = r15_5,
   sad_financial = r15_6,
   sad_tod_nam = r15_7,
   epg = rmb15_8

  where rowid = chartorowid( replace(rid,'~','+') );
 commit;
 mng_cust(surl,rid,'x',LNGS.STR_TXT_340);
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MNG_CUST',null,owner_id,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end accept_mng_cust;

procedure mng_charge( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.charges where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.MNG_CHARGE' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'CHARGES', rid );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_369,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );
 if id <> 'z' and rid is not null
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
 end if;

 htp.formopen( 'strangp.accept_mng_charge', ctarget=>'_top' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_232),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT' and (id = 'z' or rid is null)
    then
     htp.tabledata( htf.formtext('P1', 10, 10, c2rec.chargecode),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     if vaccess = 'EDIT' then htp.formhidden( 'P1', c2rec.chargecode ); end if;
     htp.tabledata( htf.bold(c2rec.chargecode),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_376),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P2', 30, 30, c2rec.chargedesc),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.chargedesc),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_214),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P3', 10, 30, c2rec.rate),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.rate),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_377),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P4', 12, 12, c2rec.costcode),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(c2rec.costcode),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_101),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'UNITS', 'P5', c2rec.unit_unitused, TRUE, FALSE, FALSE );
     htp.p( '</TD>' );
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'UNITS', 'P5', c2rec.unit_unitused, TRUE, TRUE, FALSE, isedit=>FALSE );
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Default GST Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'GSTCODES', 'P6', c2rec.gstc_gstcode, TRUE, TRUE, TRUE );
     htp.p( '</TD>' );
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'GSTCODES', 'P6', c2rec.gstc_gstcode, TRUE, TRUE, TRUE, isedit=>FALSE );
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Sales Cost Centre with GST'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'COST_CENTRE', 'P7A', c2rec.sales_costcentre_gst, TRUE, FALSE, TRUE, xtr_a=>'S',xtr_b=>'GST' );
     htp.p( '</TD>' );
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'COST_CENTRE', 'P7A', c2rec.sales_costcentre_gst, TRUE, FALSE, TRUE, isedit=>FALSE, xtr_a=>'S',xtr_b=>'GST' );
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Sales Cost Centre NO GST'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'COST_CENTRE', 'P7B', c2rec.sales_costcentre_no_gst, TRUE, FALSE, TRUE, xtr_a=>'S',xtr_b=>'NO_GST' );
     htp.p( '</TD>' );
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'COST_CENTRE', 'P7B', c2rec.sales_costcentre_no_gst, TRUE, FALSE, TRUE, isedit=>FALSE, xtr_a=>'S',xtr_b=>'NO_GST' );
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Costs Cost Centre'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'COST_CENTRE', 'P7C', c2rec.costs_costcentre, TRUE, FALSE, TRUE, xtr_a=>'C' );
     htp.p( '</TD>' );
    else
     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
     lov_list( 'COST_CENTRE', 'P7C', c2rec.costs_costcentre, TRUE, FALSE, TRUE, isedit=>FALSE, xtr_a=>'C' );
     htp.p( '</TD>' );
   end if;
  htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT' and (id = 'z' or rid is null)
  then
   htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_373 ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_374 ),cattributes=>'VALIGN="TOP"');
   htp.tabledata( htf.formsubmit( 'ACTION', LNGS.STR_TXT_372 ),cattributes=>'VALIGN="TOP"');
 end if;
 htp.formclose;
 if vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formopen( 'strangp.mng_charge', ctarget=>'CUSTOMER_WINDOW' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RID', null ) || htf.formsubmit( null, LNGS.STR_TXT_373 ) || htf.formclose,cattributes=>'VALIGN="TOP"');
 end if;
 htp.tablerowclose;
 htp.tableclose;
 search( surl, 'CHARGES', rid );
 htp.nl;
 --if call_name is null then htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl; end if;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MNG_CHARGE',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end mng_charge;

procedure accept_mng_charge( surl in varchar2, rid in varchar2, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null,
                           p5 in varchar2 default null, p6 in varchar2 default null, p7a in varchar2, p7b in varchar2, p7c in varchar2, action in varchar2 )
as

 cursor c1( chg varchar2 ) is select 'x' from strang.charges where upper(chargecode) = upper(chg);

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 np3		number;
 newrid		rowid;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ACCEPT_MNG_CHARGE' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  if action = LNGS.STR_TXT_372
   then
    delete from strang.invcharges
     where
      cge_chargecode = (select chargecode from strang.charges where rowid = chartorowid( replace(rid,'~','+') ));
    delete from strang.charges where rowid = chartorowid( replace(rid,'~','+') );
    menu( surl, to_char(sysdate,'SSSS'), 'CHARGES');
    return;
  end if;

 begin np3 := to_number(p3); exception when others then np3 := null; end;

 if action = LNGS.STR_TXT_373
  then
   if p1 is null
    then
     mng_charge(surl,null,'z',LNGS.STR_TXT_370);
     return;
   end if;
   open c1(p1);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     mng_charge(surl,null,'z',LNGS.STR_TXT_371);
     return;
   end if;
   close c1;
   insert into strang.charges(chargecode,chargedesc,rate,costcode,unit_unitused,gstc_gstcode,sales_costcentre_gst,sales_costcentre_no_gst,costs_costcentre) values
    ( p1, p2, np3, p4, p5, p6, p7a, p7b, p7c ) returning rowid into newrid;
   commit;
   mng_charge(surl,newrid,'x',LNGS.STR_TXT_399);
   return;
 end if;

 update strang.charges
  set
   chargedesc = p2,
   rate = np3,
   costcode = p4,
   unit_unitused = p5,
   gstc_gstcode = p6,
   sales_costcentre_gst = p7a,
   sales_costcentre_no_gst = p7b,
   costs_costcentre = p7c
  where rowid = chartorowid( replace(rid,'~','+') );
 commit;
 mng_charge(surl,rid,'x',LNGS.STR_TXT_378);
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MNG_CHARGE',null,owner_id,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end accept_mng_charge;

procedure allocate_hawb( mawb in varchar2, vste in varchar2 )
as

 cursor c1(dlr varchar2) is select max(hawb_hawbno) + 1 from strang.detailrs where substr(to_char(hawb_hawbno),1,2) = dlr;

 cursor c2(mawb varchar2) is
  select dr.rowid,dr.deliveryno,dr.itemno
  from strang.detailrs dr, strang.movements m
  where hawb_hawbno is null and
        dr.movement_no = m.movement_no and
        m.movement_no = mawb and
        m.movement_type = 'AIRWAY'
  order by deliveryno,itemno;

 cursor c3(mawb varchar2)  is
  select dr.hawb_hawbno, dr.deliveryno
  from strang.detailrs dr, strang.movements m
  where hawb_hawbno is not null and
        dr.movement_no = m.movement_no and
        m.movement_no = mawb and
        m.movement_type = 'AIRWAY';

 cursor c11(vste varchar2) is select description from strang.lov where lov_name = 'CONTROLS' and code = 'HAWB' and cola = vste;

 c3rec		c3%ROWTYPE;
 c11rec 	c11%ROWTYPE;
 maxnmb		integer;
 vmawbs		varchar(100);
 last_del	integer;


 function inlist( dlrv integer, mawb varchar2 )
  return boolean
 as
  cursor c1(dlrv integer, mawb varchar2)  is
   select dr.hawb_hawbno
   from strang.detailrs dr, strang.movements m
   where hawb_hawbno is not null and
         dr.movement_no = m.movement_no and
         m.movement_no = mawb and
         dr.deliveryno = dlrv and
         m.movement_type = 'AIRWAY';
  c1rec  c1%ROWTYPE;
  begin
   open c1(dlrv,mawb);
   fetch c1 into c1rec;
   if c1%FOUND
    then
     close c1;
     return( TRUE );
    else
      close c1;
      return( FALSE );
   end if;
 end inlist;

 function inlistval( dlrv integer, mawb varchar2 )
   return integer
  as
   cursor c1(dlrv integer, mawb varchar2)  is
    select dr.hawb_hawbno
    from strang.detailrs dr, strang.movements m
    where hawb_hawbno is not null and
          dr.movement_no = m.movement_no and
          m.movement_no = mawb and
          dr.deliveryno = dlrv and
          m.movement_type = 'AIRWAY';
   c1rec  c1%ROWTYPE;
   begin
    open c1(dlrv,mawb);
    fetch c1 into c1rec;
    if c1%FOUND
     then
      close c1;
      return( c1rec.hawb_hawbno );
     else
       close c1;
       return( NULL );
    end if;
  end inlistval;

begin

 open c3(mawb);
 fetch c3 into maxnmb,last_del;
 if c3%NOTFOUND
  then
   open c11(vste);
   fetch c11 into c11rec;
   close c11;
   open c1(substr(c11rec.description,1,2));
   fetch c1 into maxnmb;
   close c1;
   if maxnmb is null then maxnmb := c11rec.description; end if;
   --insert into strang.hawbs(hawb,mawb) values (maxnmb,mawb);
   vmawbs := mawb;
   insert into strang.hawbs(hawb,mawb) select maxnmb,vmawbs from dual where not exists (select 'x' from strang.hawbs h where h.hawb = maxnmb and h.mawb = vmawbs);
 end if;
 close c3;

 for c2rec in c2(mawb) loop
  if (last_del is null)
   then
    update strang.detailrs
      set
       hawb_hawbno = maxnmb
      where rowid = c2rec.rowid;
  elsif inlist(c2rec.deliveryno,mawb)
   then
    maxnmb := inlistval(c2rec.deliveryno,mawb);
    update strang.detailrs
      set
       hawb_hawbno = maxnmb
      where rowid = c2rec.rowid;
   else
    open c11(vste);
    fetch c11 into c11rec;
    close c11;
    open c1(substr(c11rec.description,1,2));
    fetch c1 into maxnmb;
    close c1;
    --insert into strang.hawbs(hawb,mawb) values (maxnmb,mawb);
    vmawbs := mawb;
    insert into strang.hawbs(hawb,mawb) select maxnmb,vmawbs from dual where not exists (select 'x' from strang.hawbs h where h.hawb = maxnmb and h.mawb = vmawbs);
    update strang.detailrs
      set
       hawb_hawbno = maxnmb
      where rowid = c2rec.rowid;
   end if;
   last_del := c2rec.deliveryno;
 end loop;

end allocate_hawb;

procedure hotsync( surl in varchar2 )
as

 cursor c2 is select * from strang.hot_sync order by decode(table_name,'SHIPS_AIRWAY',0,'RECEIVALS',1,'MOVEMENTS',2,'HAWBS',3,'DETAILRS',4,'POS',5,6), table_name;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.HOTSYNC' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'HOTYSNC', null );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, NULL,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR24',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );
 htp.formopen( 'strangp.accept_hotsync' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
 htp.tablerowopen;
  htp.tabledata( htf.bold( LNGS.STR_TXT_385 ),cattributes=>glbx.QUERY_BACKGROUND );
  htp.tabledata( htf.bold( LNGS.STR_TXT_386 ),cattributes=>glbx.QUERY_BACKGROUND );
 htp.tablerowclose;
 for c2rec in c2 loop
  htp.tablerowopen;
   htp.tabledata( initcap(replace(c2rec.table_name,'_',' ')), cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata( initcap(c2rec.allowed_change), cattributes=>glbx.QUERY_CELL_BACKGROUND );
  htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold(LNGS.STR_TXT_387), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.formradio( 'P2', 'STANDARD', 'CHECKED' ), cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata( LNGS.STR_TXT_388 || htf.nl ||
                  ' &nbsp;&nbsp;&nbsp' || htf.formcheckbox('P6','T') || ' Continue if Error ' || htf.nl ||
                  ' &nbsp;&nbsp;&nbsp ' || htf.formcheckbox( 'P4', 'T' ) || ' ' || LNGS.STR_TXT_402 || htf.nl ||
                  ' &nbsp;&nbsp;&nbsp ' || htf.formcheckbox( 'P7', 'T' ) || ' ' || 'Only Extract the SQL Statements to file' || htf.nl ||
                  ' &nbsp;&nbsp;&nbsp ' || htf.formcheckbox( 'P8', 'T' ) || ' ' || 'Only Run SQL Statements from file'
                  , cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tabledata( htf.anchor( 'strangp.analyse_hotsync?surl=' || surl, LNGS.STR_TXT_403 ), cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
  vaccess := data_access( owner_id, 'HOTYSNC_SUPER', null );
  if vaccess = 'EDIT'
   then
    htp.tablerowopen;
     htp.tabledata( htf.formradio( 'P2', 'CULL' ), cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.tabledata( LNGS.STR_TXT_404, cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.tabledata( LNGS.STR_TXT_405|| ':' || htf.formtext( 'P5',10,20, to_char(sysdate-100,'DD-MON-YYYY')), cattributes=>glbx.QUERY_BACKGROUND );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formradio( 'P2', 'REFRESH' ), cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.tabledata( LNGS.STR_TXT_389, cattributes=>glbx.QUERY_CELL_BACKGROUND );
     htp.tabledata( 'Complete Delete Password' || ' :' || htf.formpassword( 'P3',10, 100 ), cattributes=>glbx.QUERY_BACKGROUND );
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNGS.STR_TXT_390 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'HOTSYNC',null,null,errmsg=>sqlerrm );
end hotsync;

procedure analyse_hotsync( surl in varchar2 )
as

 TYPE REPCurTyp IS REF CURSOR;  -- define weak REF CURSOR type

 cursor c2 is select * from strang.hot_sync order by site,table_name desc; -- Descending so that Ships Airway goes first
 cursor c3 is
  select r.table_name,r.column_name,min(r.replication_id) mn,max(r.replication_id) mx,count('x') cnt,min(r.date_changed) mnd,max(r.date_changed) mxd
  from strang.replication r, strang.hot_sync h
  where r.table_name = h.table_name and
        r.replication_id >= nvl(h.local_load_id,0)
  group by r.table_name,r.column_name;
 cursor c4 is select * from strang.hot_sync;

 rep_cv   	REPCurTyp;
 str		varchar2(4000);
 fstr		varchar2(4000);
 cola		varchar2(4000);
 colb		varchar2(4000);
 tot		integer;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 result		varchar2(1000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_HOTSYNC' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'HOTYSNC', null );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_403,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR24',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.bold( 'Hot Sync' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Site' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Table Name' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'DB Link' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Allowed Change' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Local Load Id' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Primary Load Id' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'PK Col1' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'PK Col2' ), cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
  for c2rec in c2 loop
   htp.tablerowopen;
    htp.tabledata( c2rec.site, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c2rec.table_name, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c2rec.dblink, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c2rec.allowed_change, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c2rec.local_load_id, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c2rec.primary_load_id, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c2rec.pk_col1, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( nvl(c2rec.pk_col2,'&nbsp;'), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;
 htp.nl;
 htp.bold( 'Replication Statistics' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Table Name' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Column Name' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Min load Id' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Max Load Id' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Min Date Changed' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Max Date Changed' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( '# Records' ), cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
  for c3rec in c3 loop
   htp.tablerowopen;
    htp.tabledata( c3rec.table_name, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c3rec.column_name, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c3rec.mn, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c3rec.mx, cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( to_char(c3rec.mnd,'DD Mon YYYY HH24:MI:SS'), cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( to_char(c3rec.mxd,'DD Mon YYYY HH24:MI:SS'), cattributes=>glbx.QUERY_BACKGROUND );
    htp.tabledata( c3rec.cnt, cattributes=>glbx.QUERY_BACKGROUND );
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.line;
 htp.nl;

 htp.bold( 'Duplicate Values in the Strang Database' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Table Name' ));
   htp.tabledata( htf.bold( 'Primary Key Column A' ));
   htp.tabledata( htf.bold( 'Primary Key Column B' ));
   htp.tabledata( htf.bold( 'Value Column A' ));
   htp.tabledata( htf.bold( 'Value Column B' ));
   htp.tabledata( htf.bold( 'Number of Duplicates' ));
  htp.tablerowclose;
 for c4rec in c4 loop
  if c4rec.pk_col2 is null
   then
    str := c4rec.pk_col1;
   else
    str := c4rec.pk_col1 || ',' || c4rec.pk_col2;
  end if;
  fstr := 'select ' || str || ', count(''x'') tot from strang.' || c4rec.table_name || ' group by ' || str || ' having count(''x'') > 1';
  OPEN rep_cv FOR fstr;

  loop
   if c4rec.pk_col2 is null
    then
     FETCH rep_cv into cola,tot;
    else
     FETCH rep_cv into cola,colb,tot;
   end if;
   EXIT WHEN rep_cv%NOTFOUND;
   htp.tablerowopen;
    htp.tabledata( c4rec.table_name );
    htp.tabledata( htf.anchor('strangp.check_dupl?surl=' || surl || '&tname=' || c4rec.table_name || '&cname=' || c4rec.pk_col1 || '&pkcol1=' || replace(cola,' ','+') || '&pkcol2=' || replace(colb,' ','+'),c4rec.pk_col1 ));
    htp.tabledata( nvl(c4rec.pk_col2,'&nbsp;') );
    htp.tabledata( cola );
    htp.tabledata( nvl(colb,'&nbsp;'));
    htp.tabledata( tot );
   htp.tablerowclose;
  end loop;
  CLOSE rep_cv;

 end loop;
 htp.tableclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'ANALYSE_HOTSYNC',null,null,errmsg=>sqlerrm );
end analyse_hotsync;

procedure delete_dupl(surl in varchar2, tname in varchar2, rw in varchar2 )
as
 c1rec		customer_account%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 rw2		varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.DELETE_DUPL' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  rw2 := replace(rw,'~','+');
  strang.global_site.disable_trigger := TRUE;
  execute immediate 'delete from strang.' || tname || ' where rowid = :1'
   using chartorowid(rw2);
  commit;
  strang.global_site.disable_trigger := FALSE;
  analyse_hotsync(surl);
exception when others then
 glbx.error_details( 'STRANGP', 'DELETE_DUPL',null,null,errmsg=>sqlerrm );
end delete_dupl;

procedure check_dupl(surl in varchar2, tname in varchar2, cname in varchar2, pkcol1 in varchar2, pkcol2 in varchar2 )
as

 TYPE REPCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
 cursor c2(tname varchar2, ownr varchar2) is select column_name from all_tab_columns where owner = ownr and table_name = tname;
 cursor c3(tname varchar2) is select pk_col1,pk_col2 from strang.hot_sync where table_name = tname;

 rep_cv   	REPCurTyp;
 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 wclause	varchar2(1000);
 rep_cv4   	REPCurTyp;
 pr1		rowid;
 pr2		rowid;
 val1		varchar2(4000);
 val2		varchar2(4000);
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_HOTSYNC' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'HOTYSNC', null );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, 'Looking for Duplicates on table' || ':' || tname,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR23',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Column Name' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'First Row' ), cattributes=>glbx.QUERY_BACKGROUND );
   htp.tabledata( htf.bold( 'Second Row' ), cattributes=>glbx.QUERY_BACKGROUND );
  htp.tablerowclose;
  open c3(tname);
  fetch c3 into c3rec;
  close c3;
  if pkcol1 is null
   then
    wclause := c3rec.pk_col1 || ' is null';
   else
    wclause := c3rec.pk_col1 || ' = ''' || pkcol1 || '''';
  end if;
  if c3rec.pk_col2 is not null
   then
    if pkcol2 is null
     then
      wclause := wclause || ' and ' || c3rec.pk_col2 || ' is null';
     else
      wclause := wclause || ' and ' || c3rec.pk_col2 || ' = ''' || pkcol2 || '''';
    end if;
  end if;
  OPEN rep_cv FOR 'select rowid from strang.' || tname || ' where ' || wclause;
  FETCH rep_cv INTO pr1;
  FETCH rep_cv INTO pr2;
  close rep_cv;

  for c2rec in c2(tname,'STRANG') loop
  htp.tablerowopen;
   val1 := NULL;
   val2 := NULL;
   execute immediate 'select ' || c2rec.column_name || ' from strang.' || tname || ' where rowid=:1'
    into val1
     using pr1;
   execute immediate 'select ' || c2rec.column_name || ' from strang.' || tname || ' where rowid=:1'
    into val2
     using pr2;
   if nvl(val1,'|') = nvl(val2,'|')
    then
     htp.tabledata( c2rec.column_name, cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( nvl(val1,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( nvl(val2,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND);
    else
     htp.tabledata( htf.bold(c2rec.column_name), cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( htf.bold(nvl(val1,'&nbsp;')), cattributes=>glbx.QUERY_CELL_BACKGROUND);
     htp.tabledata( htf.bold(nvl(val2,'&nbsp;')), cattributes=>glbx.QUERY_CELL_BACKGROUND);
   end if;
   htp.tablerowclose;
  end loop;
  htp.tableclose;
  htp.nl;
  htp.anchor( 'strangp.delete_dupl?surl=' || surl || '&tname=' || tname || '&rw=' || replace(pr1,'+','~'),'Delete First Row' );
  htp.nl;
  htp.anchor( 'strangp.delete_dupl?surl=' || surl || '&tname=' || tname || '&rw=' || replace(pr2,'+','~'),'Delete Second Row' );
  htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'CHECK_DUPL',null,null,errmsg=>sqlerrm );
end check_dupl;

procedure accept_hotsync( surl in varchar2, p2 in varchar2, p3 in varchar2 default NULL, p4 in varchar2 default 'F', p5 in varchar2 default null, p6 in varchar2 default 'F', p7 in varchar2 default 'F', p8 in varchar2 default 'F' )
as

 cursor c2 is select last_load from strang.hot_sync;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 result		varchar2(1000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_HOTSYNC' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'HOTYSNC', null );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, 'Hot Sync Results',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR23',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 open c2;
 fetch c2 into c2rec;
 close c2;
 if ((sysdate - nvl(c2rec.last_load,(sysdate-100))) * 60 * 60 * 24) < 30
  then
   -- Hit button twice
   htp.nl;
   htp.bold( 'Hot Sync Already Running' );
   return;
  else
   -- OK to run
   update strang.hot_sync set last_load = sysdate;
   commit;
 end if;

 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );
 htp.nl;
 result := NULL;
 strangz.hot_sync_all(p2,result,p3,p4,p5,p6,p7,p8);
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
   htp.tablerowopen;
     htp.tabledata( nvl(result,'Completed'), cattributes=>glbx.QUERY_CELL_BACKGROUND );
   htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 -- htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_HOTSYNC',null,null,errmsg=>sqlerrm );
end accept_hotsync;

procedure assign_hawb( surl in varchar2, rid in varchar2, scid in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2(rid rowid) is select movement_no from strang.movements where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 vste		varchar2(10);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ASSIGN_DET' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 open c2(chartorowid(replace(rid,'~','+')));
 fetch c2 into c2rec;
 close c2;

 allocate_hawb( c2rec.movement_no, vste );

 movement( surl, rid, scid, null, parm, access_id, LNGS.STR_TXT_393);

exception when others then
 glbx.error_details( 'STRANGP', 'ASSIGN_HAWB',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' || parm);
end assign_hawb;

procedure edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, msg in varchar2 default null )
as

 cursor c3( lg varchar2 ) is
  select d.rowid,d.movement_no,d.camov_seal seal,logno,deliveryno,itemno,ecn,handling_unit,qty,pktpe_packtype,partweight,partvolume,detaildesc,hazard,warehouse
  from strang.detailrs d
  where logno = lg
  order by deliveryno,itemno,logno;

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 foundrec	boolean;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.EDIT_ECN_LOG' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_266,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_edit_ecn_log' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'LG', lg );
 htp.formhidden( 'RID', rid );
 htp.formhidden( 'SCID', scid );
 htp.formhidden( 'CALL_NAME', call_name );
 htp.formhidden( 'PARM', parm );
 htp.formhidden( 'ACCESS_ID', access_id );
 htp.formhidden( 'RECCTR', recctr );

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Container'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Seal'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Log No'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Delivery No'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Item'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'ECN'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Handling Unit'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Qty'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Pack Type'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Weight (Kg)'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Volume (m3)'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Description'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Hazardous'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Warehouse'), cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="CENTER"');
  htp.tablerowclose;
  foundrec := FALSE;
    for c3rec in c3( lg ) loop
     foundrec := TRUE;
     htp.tablerowopen;
     htp.formhidden( 'P2', rowidtochar( c3rec.rowid ) );
      htp.tabledata( c3rec.movement_no, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( nvl(c3rec.seal,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.logno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.deliveryno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( c3rec.itemno, cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formtext( 'P3', 10, 1000, c3rec.ecn), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P3i', 10, 1000, c3rec.handling_unit), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P4', 10, 1000, c3rec.qty), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P5', 8, 1000, c3rec.pktpe_packtype), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P6', 10, 1000, c3rec.partweight), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P7', 10, 1000, c3rec.partvolume), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P8', 90, 1000, c3rec.detaildesc), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P9', 40, 1000, c3rec.hazard), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
      htp.tabledata( htf.formtext( 'P10', 10, 1000, c3rec.warehouse), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER"');
     htp.tablerowclose;
    end loop;
  htp.tableclose;
  if not foundrec
   then
    htp.formhidden( 'P2', null );
    htp.formhidden( 'P3', null );
    htp.nl;
    htp.formsubmit( null, LNGS.STR_TXT_364 );
    htp.formclose;
    htp.nl;
    htp.anchor(  'javascript: parent.opener.location = ''' || 'strangp.receive_bottom?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(recctr) || '''; parent.close();', LNG.GLB_TXT_033);
    htp.htmlclose;
   return;
  end if;
  htp.nl;
  htp.formsubmit( 'ACTION', 'Save Changes' );
  htp.formsubmit( 'ACTION', 'Repeat First ECN for All' );
  htp.formsubmit( 'ACTION', 'Repeat First Handling Unit for All' );
  htp.formclose;
  htp.anchor(  'javascript: parent.opener.location = ''' || 'strangp.receive_bottom?surl=' || surl || '&rid=' || replace( rid, '+', '~' ) || '&scid=' || replace(scid,' ','+') || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || replace(access_id,' ','+') || '&recctr=' || to_char(recctr) || '''; parent.close();', LNG.GLB_TXT_033);
  --htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
  htp.p( '</CENTER>' );
  htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'EDIT_ECN_LOG',null,owner_id,errmsg=>sqlerrm,extdet=>'LG:' || lg);
end edit_ecn_log;

procedure accept_edit_ecn_log( surl in varchar2, lg in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, recctr in integer default 1, action in varchar2, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p3i in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, p7 in GLBX.MYARRAY, p8 in GLBX.MYARRAY, p9 in GLBX.MYARRAY, p10 in GLBX.MYARRAY )
as

 cursor c3(lname varchar2, lcode varchar2) is select * from strang.lov where lov_name = lname and code = lcode;

 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 errmsg		GLBX.MYARRAY;
 errfound	boolean;
 errunit	varchar2(1);


begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_EDIT_ECN' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  for j in p2.first..p2.last loop
     errmsg(j):=null;
     if p2(j) is not null
      then
       if action = 'Save Changes'
        then
--       Validations
         -- Check PackType
         c3rec.code := NULL;
         errunit := 'F';
         if p5(j) is not null
         then
          open c3( 'PACKTYPES', upper(p5(j)));
          fetch c3 into c3rec;
          if c3%NOTFOUND
          then
            close c3;
            errfound := TRUE;
            errmsg(j) := errmsg(j) || ' ' || 'PackType NOT updated';
            errunit := 'T';
          else
            close c3;
            update strang.detailrs set pktpe_packtype = upper(nvl(p5(j),pktpe_packtype)) where rowid = chartorowid( p2(j) );
          end if;
        end if;

         -- Check Warehouses
         c3rec.code := NULL;
         errunit := 'F';
         if p10(j) is not null
         then
          open c3( 'WAREHOUSES', upper(p10(j)));
          fetch c3 into c3rec;
          if c3%NOTFOUND
          then
            close c3;
            errfound := TRUE;
            errmsg(j) := errmsg(j) || ' ' || 'Warehouse NOT updated';
            errunit := 'T';
          else
            close c3;
            update strang.detailrs set warehouse = upper(nvl(p10(j),warehouse)) where rowid = chartorowid( p2(j) );
          end if;
        end if;

         update strang.detailrs set
          ecn = p3(j),
          handling_unit = strang.f_sap_format(p3i(j),'HANDLING_UNIT'),
          qty = nvl(p4(j),qty),
          partweight = nvl(p6(j),partweight),
          partvolume = nvl(p7(j),partvolume),
          detaildesc = upper(nvl(p8(j),detaildesc)),
          hazard = upper(p9(j))
         where rowid = chartorowid( p2(j) );
       elsif action = 'Repeat First ECN for All'
        then
         if p3(j) is null
          then
           update strang.detailrs set ecn = p3(1) where rowid = chartorowid( p2(j) );
          else
           update strang.detailrs set ecn = p3(j) where rowid = chartorowid( p2(j) );
         end if;
       elsif action = 'Repeat First Handling Unit for All'
        then
         if p3i(j) is null
          then
           update strang.detailrs set handling_unit = strang.f_sap_format(p3i(1),'HANDLING_UNIT') where rowid = chartorowid( p2(j) );
          else
           update strang.detailrs set handling_unit = strang.f_sap_format(p3i(j),'HANDLING_UNIT') where rowid = chartorowid( p2(j) );
         end if;
       end if;
     end if;
  end loop;

  commit;

  edit_ecn_log(surl, lg, rid, scid, call_name, parm, access_id, recctr, 'VALUES SAVED' );

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_EDIT_ECN_LOG',null,owner_id,errmsg=>sqlerrm,extdet=>'LG:' || lg);
end accept_edit_ecn_log;

procedure trac_search( surl in varchar2, msg in varchar2 default null )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.TRAC_SEARCH' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_443,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 htp.p( '<CENTER>' );

 if msg is not null
 then
  glbx.header_msg( msg );
 end if;

 htp.nl;

htp.tableopen;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_444), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_446), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;
htp.tablerowopen;
htp.p('<TD valign="TOP">');
 htp.p('Northbound Ships');
 htp.formopen( 'strangp.accept_trac_search' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_437 || ':'), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Strang Delivery No'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'OTML Delivery No'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4i', 20, 100 ), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Item '), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4ii', 10, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_438), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1', 20, 100 ), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Line '), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1a', 10, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Stock/Inventory No'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'p4aa', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'OTML Handling Unit'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'p4a', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_439), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P2', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_440), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P3', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Container/Connote/Mawb'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P5', 20, 100 ), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Seal'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P6', 10, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
htp.tableclose;
htp.nl;
htp.p('<CENTER>');
htp.formsubmit( null, LNGS.STR_TXT_441 );
htp.formclose;
htp.p('</CENTER>');
htp.p('</TD>');

-- Southbound Ships Start
htp.p('<TD valign="TOP">');
 htp.p('Southbound Ships');
 htp.formopen( 'strangsb.accept_trac_search' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_437 || ':'), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Consignee Name'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Customs Authority Number'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P2', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Container Number' ), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P3', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'OTML DAN Number' ), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'OTML Tracking Order Number'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P5', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Date Range From'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P6', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Date Range To'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P7', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
htp.tableclose;
htp.nl;
htp.p('<CENTER>');
htp.formsubmit( null, LNGS.STR_TXT_441 );
htp.formclose;
htp.p('</CENTER>');
htp.p('</TD>');
-- Southbound Ships End

htp.tablerowclose;
htp.tableclose;
htp.nl;
htp.nl;
-- htp.italic( LNGS.STR_TXT_447 );
-- htp.p( '</CENTER>' );
htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'TRAC_SEARCH',null,owner_id,errmsg=>sqlerrm);
end trac_search;

procedure accept_trac_search( surl in varchar2, p1 in varchar2, p1a in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p4i in varchar2, p4ii in varchar2, p4a in varchar2, p5 in varchar2, p6 in varchar2, p4aa in varchar2 )
as

 cursor c21(po_nmbr varchar2, po_line varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        (p.po = po_nmbr and p.po_item_no = po_line)
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c22(po_nmbr varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        p.po = po_nmbr
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c23(sapdelno varchar2, sapitem varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
	 (strang.f_sap_format(sapdelno,'DELIVERYNO')=p.sap_delno and p.sap_delno_item = sapitem)
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c24(sapdelno varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
	strang.f_sap_format(sapdelno,'DELIVERYNO')=p.sap_delno
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c25(supinv_val varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        supinv_val = p.supinv
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;


 cursor c26(invent varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        invent = p.inventoryno
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c27(hu varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        hu = dr.handling_unit
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c28(sname varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        c1.customer like sname || '%'
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c29(dlr varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        dlr = dr.deliveryno
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c30(mvn varchar2, sl varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
        mvn = dr.movement_no and
        nvl(sl,'|') = nvl(m.seal,'|')
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;

 cursor c31(mvn varchar2, vste varchar2 ) is
  select /*+ ALL_ROWS */
         distinct
         p.po,
         p.po_item_no,
         p.inventoryno,
         p.supinv,
         dr.logno,
         p.deliveryno,
         dr.itemno,
         dr.handling_unit,
         p.sap_delno,
         p.sap_delno_item,
         r.currdate,
         l.description,
         decode(dr.sa,'S','Sea','A','Air') mode_of_transport,
         decode(dr.sa,'S',s.status,'A',decode(nvl(m.complete,'F'),'F','INCOMPLETE','P','PACKING COMPLETE','A','ARRIVED AT PORT','D','DESPATCHED''W','AWAITING SHIPMENT','S','SHIPPED')) status,
         decode(dr.sa,'S',s.shipname || '&nbsp;&nbsp;' || s.voy || htf.nl || s.sap_ship_id,'A',m.carrier || '&nbsp;&nbsp' || m.flight) vy,
         decode(m.movement_type,'CARGO',m.movement_no || '&nbsp;&nbsp;' || m.seal,'&nbsp;') cargo,
         decode(m.movement_type,'CONMOV',m.movement_no,'&nbsp;') conmov,
         decode(m.movement_type,'AIRWAY',m.movement_no,'&nbsp;') airway,
         nvl(to_char(dr.hawb_hawbno),'&nbsp;') hawb,
         decode(dr.sa,'S',s.estdepart,'A',m.dispatch_date) date_desp,
         decode(dr.sa,'S',s.estarrive,'A',null) eta,
         dr.line_no
  from strang.pos p, strang.detailrs dr, strang.customers c1, strang.receivals r, strang.movements m, strang.ships_airway s, strang.lov l
  where p.deliveryno = dr.deliveryno and
        s.ship_id = m.ship_id and
        l.lov_name = 'CONTROLS' and l.cola = vste and
        substr(l.code,1,11) = 'LOG_PREFIX_' and
        substr(dr.logno,5,1) = substr(l.code,12,1) and
        nvl(r.supplier_customer_id,0) = c1.customer_id and
        c1.customer_type = 'SUPPLIER' and
        p.deliveryno = r.deliveryno and
        m.movement_no = dr.movement_no and
        nvl(m.seal, '|') = nvl(dr.camov_seal, '|') and
        mvn = dr.movement_no
        order by r.currdate desc, p.po, p.po_item_no, p.supinv,dr.logno,p.deliveryno;


 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		integer;
 clr		varchar2(100);
 sts		varchar2(100);
 vste		varchar2(10);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.TRAC_SEARCH' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, LNGS.STR_TXT_443,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR16',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);

 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_444 ), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_445 ), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_446 ), ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
  htp.tablerowclose;
 htp.tableclose;

 -- Alternate Colours + Header Colour
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Purchase Order & Line'), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'Stock / Inventory No'), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( 'OTML Delivery & Item' || htf.nl || 'Handling Unit'), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_422), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_423), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_424), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_425), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_426), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_427), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_428), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_429), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_430), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_431), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_432), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_433), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_434), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_435), ' ALIGN="CENTER"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_436), ' ALIGN="CENTER"');
  htp.tablerowclose;

 -- If the deliveryno is invalid set it to 0. Query will return no rows.
 begin nmb := to_number(p4); exception when others then nmb := 0; end;

--- 20170524
if (trim(p1) is not null and trim(p1a) is not null) then
 for c21rec in c21(trim(p1),trim(p1a),vste ) loop
  if mod(c21%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c21rec.po,'&nbsp;') || htf.nl || nvl(to_char(c21rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c21rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c21rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c21rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c21rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c21rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c21rec.logno,'&nbsp;') || htf.nl || c21rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c21rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c21rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c21rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c21rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c21rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;

  elsif (trim(p1) is not null and trim(p1a) is null) then
 for c22rec in c22(trim(p1), vste ) loop
  if mod(c22%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c22rec.po,'&nbsp;') || htf.nl || nvl(to_char(c22rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c22rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c22rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c22rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c22rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c22rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c22rec.logno,'&nbsp;') || htf.nl || c22rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c22rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c22rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c22rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c22rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c22rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;

 elsif (trim(p4i) is not null and trim(p4ii) is not null) then
 for c23rec in c23(trim(p4i),trim(p4ii), vste ) loop
  if mod(c23%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c23rec.po,'&nbsp;') || htf.nl || nvl(to_char(c23rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c23rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c23rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c23rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c23rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c23rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c23rec.logno,'&nbsp;') || htf.nl || c23rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c23rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c23rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c23rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c23rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c23rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;

 elsif (trim(p4i) is not null and trim(p4ii) is null) then
 for c24rec in c24(trim(p4i), vste ) loop
  if mod(c24%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c24rec.po,'&nbsp;') || htf.nl || nvl(to_char(c24rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c24rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c24rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c24rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c24rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c24rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c24rec.logno,'&nbsp;') || htf.nl || c24rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c24rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c24rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c24rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c24rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c24rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;

 elsif trim(p2) is not null then
 for c25rec in c25(trim(p2), vste ) loop
  if mod(c25%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c25rec.po,'&nbsp;') || htf.nl || nvl(to_char(c25rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c25rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c25rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c25rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c25rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c25rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c25rec.logno,'&nbsp;') || htf.nl || c25rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c25rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c25rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c25rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c25rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c25rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;

   elsif trim(p4aa) is not null then
 for c26rec in c26(trim(p4aa), vste ) loop
  if mod(c26%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c26rec.po,'&nbsp;') || htf.nl || nvl(to_char(c26rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c26rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c26rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c26rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c26rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c26rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c26rec.logno,'&nbsp;') || htf.nl || c26rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c26rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c26rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c26rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c26rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c26rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
   elsif trim(p4a) is not null then
 for c27rec in c27(trim(p4a), vste ) loop
  if mod(c27%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c27rec.po,'&nbsp;') || htf.nl || nvl(to_char(c27rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c27rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c27rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c27rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c27rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c27rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c27rec.logno,'&nbsp;') || htf.nl || c27rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c27rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c27rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c27rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c27rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c27rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
   elsif trim(p3) is not null then
 for c28rec in c28(trim(p3), vste ) loop
  if mod(c28%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c28rec.po,'&nbsp;') || htf.nl || nvl(to_char(c28rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c28rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c28rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c28rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c28rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c28rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c28rec.logno,'&nbsp;') || htf.nl || c28rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c28rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c28rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c28rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c28rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c28rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;

 elsif trim(p4) is not null then
 for c29rec in c29(trim(p4), vste ) loop
  if mod(c29%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c29rec.po,'&nbsp;') || htf.nl || nvl(to_char(c29rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c29rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c29rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c29rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c29rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c29rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c29rec.logno,'&nbsp;') || htf.nl || c29rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c29rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c29rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c29rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c29rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c29rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
   elsif (trim(p5) is not null and trim(p6) is not null) then
 for c30rec in c30(trim(p5),trim(p6), vste ) loop
  if mod(c30%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c30rec.po,'&nbsp;') || htf.nl || nvl(to_char(c30rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c30rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c30rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c30rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c30rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c30rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c30rec.logno,'&nbsp;') || htf.nl || c30rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c30rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c30rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c30rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c30rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c30rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
   elsif (trim(p5) is not null and trim(p6) is null) then
 for c31rec in c31(trim(p5), vste ) loop
  if mod(c31%ROWCOUNT,2) = 1
   then
    clr := glbx.QUERY_CELL_BACKGROUND;
   else
    clr := 'bgcolor="#FFFFFF"';
  end if;
  htp.tablerowopen;
   htp.tabledata( nvl(c31rec.po,'&nbsp;') || htf.nl || nvl(to_char(c31rec.po_item_no),'&nbsp;') , cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c31rec.inventoryno,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c31rec.sap_delno),'&nbsp;') || htf.nl || nvl(to_char(c31rec.sap_delno_item),'&nbsp;') || htf.nl || nvl(to_char(c31rec.handling_unit),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c31rec.supinv,'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(c31rec.logno,'&nbsp;') || htf.nl || c31rec.deliveryno, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c31rec.itemno),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c31rec.currdate,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.description, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.mode_of_transport, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.status, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.vy, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.line_no, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.cargo, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.conmov, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.airway, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( c31rec.hawb, cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c31rec.date_desp,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
   htp.tabledata( nvl(to_char(c31rec.eta,LNGS.STR_DATE_01),'&nbsp;'), cattributes=> clr || ' ALIGN="LEFT"');
  htp.tablerowclose;
 end loop;
--   else result
end if;
--- 20170524

 htp.tableclose;
htp.nl;
htp.nl;
 htp.formopen( 'strangp.accept_trac_search' );
 htp.formhidden( 'SURL', surl );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=10 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNGS.STR_TXT_437 || ':'), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Strang Delivery No'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'OTML Delivery No'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4i', 20, 100 ), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Item '), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P4ii', 10, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_438), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1', 20, 100 ), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Line '), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P1a', 10, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Stock/Inventory No'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'p4aa', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'OTML Handling Unit'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'p4a', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_439), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P2', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( LNGS.STR_TXT_440), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P3', 20, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Container/Connote/Mawb'), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P5', 20, 100 ), ' ALIGN="LEFT"');
   htp.tabledata( htf.bold( 'Seal '), ' ALIGN="LEFT"');
   htp.tabledata( htf.formtext( 'P6', 10, 100 ), ' ALIGN="LEFT"');
  htp.tablerowclose;
htp.tableclose;
htp.nl;
htp.formsubmit( null, LNGS.STR_TXT_441 );
htp.formclose;
htp.nl;
htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_TRAC_SEARCH',null,owner_id,errmsg=>sqlerrm);
end accept_trac_search;
--
procedure generate_ost256( surl in varchar2, vShip_id in integer )
as

 cursor c1( vShip_id integer ) is
   select distinct dr.movement_no, dr.deliveryno, dr.camov_seal, s.voy, s.shipname,
   decode(l.description,'BRISBANE','BRIS','GLADSTONE','GLAD','TOWNSVILLE','TVL','PORT ALMA','ALMA','NEWCASTLE','NEWC','MELBOURNE','MELB') pload,
   decode(l1.description,'KIUNGA','KNG','PORT MORESBY','POM') pdischarge, s.estdepart, s.estarrive
   from strang.detailrs dr, strang.ships_airway s, strang.receivals r, strang.movements m, strang.lov l, strang.lov l1
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.cust_customer_id = 1 and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    l1.lov_name = 'LOCATIONS' and
    l1.code = s.portdisc ;

 cursor c2( vShip_id integer ) is
   select count('x') tot
   from
   (  select distinct dr.movement_no, dr.deliveryno, dr.camov_seal, s.voy, s.shipname,
   decode(l.description,'BRISBANE','BRIS','GLADSTONE','GLAD','TOWNSVILLE','TVL','PORT ALMA','ALMA','NEWCASTLE','NEWC','MELBOURNE','MELB') pload,
   decode(l1.description,'KIUNGA','KNG','PORT MORESBY','POM') pdischarge, s.estdepart, s.estarrive
   from strang.detailrs dr, strang.ships_airway s, strang.receivals r, strang.movements m, strang.lov l, strang.lov l1
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.cust_customer_id = 1 and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    l1.lov_name = 'LOCATIONS' and
    l1.code = s.portdisc );

  cursor c3(vShipid integer) is select * from strang.ships_airway where ship_id = vShipid;

  c1rec		customer_account%ROWTYPE;
  c3rec		c3%ROWTYPE;
  f 		utl_file.file_type;
  tot		integer;
  gcode		GLBX.MYARRAY;
  gparam	GLBX.MYARRAY;
  vste		varchar2(10);
  eml		varchar2(100);
  ltype		varchar2(100);
  stype		integer;
  owner_id	integer;
  sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENERATE_CCDETS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 eml := control_code( 'OST256_EMAIL_ADDRESS', vste );
 eml := nvl( eml, glbx.extract_master_parameter('MAIL_FROM') );

 open c2(vShip_id);
 fetch c2 into tot;
 close c2;
 open c3(vShip_id);
 fetch c3 into c3rec;
 close c3;
 f := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'OST256_' || c3rec.shipname || '_' || c3rec.voy || '.csv', 'w', 32767);

 -- Output Header
 utl_file.put_line(f, buffer=>'H,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot || ','',,'',,'',,'',,'',,'',,'',,'',,'',' );



 for c1rec in c1(vShip_id) loop
  utl_file.put_line(f, buffer=>','|| c1rec.deliveryno ||','|| c1rec.movement_no || ',' || 'OTML TABUBIL' ||','|| c1rec.camov_seal ||','|| c1rec.shipname ||' '|| c1rec.voy ||','||
                               c1rec.shipname ||' '|| c1rec.voy ||','|| 'es,s,Y,' || c1rec.pload || ',' || c1rec.pdischarge || ',' ||
                               to_char(c1rec.estdepart,'YYYYMMDD') || ',' || to_char(c1rec.estarrive,'YYYYMMDD') || ',' ||
                               c1rec.shipname ||' '|| c1rec.voy||','|| c1rec.movement_no || ',' || c1rec.pload );
 end loop;


 -- Output Header
 utl_file.put_line(f, buffer=>'F,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot || ','',,'',,'',,'',,'',,'',,'',,'',,'',' );
 utl_file.fclose( f );

 gcode(1) := 'XXXX'; -- Dummy Parameter
 gparam(1) := 'XXXX';
 glbx.send( gcode, gparam, 'OST256_' || c3rec.shipname || '_' || c3rec.voy || '.csv', p_to=>eml, p_subj=>'OST256_' || c3rec.shipname || '_' || c3rec.voy, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE);

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_OST256',null,null,errmsg=>sqlerrm);
end generate_ost256;

--
procedure generate_ost156( surl in varchar2, vShip_id in integer )
as

 cursor c1( vShip_id integer ) is
   select distinct dr.movement_no, dr.logno, dr.deliveryno, dr.itemno, p.po, dr.camov_seal, s.voy, s.shipname, s.estdepart, s.estarrive, l.description pload, dr.hazard, dr.partweight, dr.partvolume, c.customer cus1, c1.customer cus2
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.customers c, strang.customers c1, strang.receivals r, strang.movements m, strang.lov l
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    r.cust_customer_id = c.customer_id and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    r.supplier_customer_id = c1.customer_id;

 cursor c2( vShip_id integer ) is
   select count('x') tot
   from
   ( select distinct dr.movement_no, dr.logno, dr.deliveryno, dr.itemno, p.po, dr.camov_seal, s.voy, s.shipname, s.estdepart, s.estarrive, l.description pload, dr.hazard, dr.partweight, dr.partvolume, c.customer cus1, c1.customer cus2
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.customers c, strang.customers c1, strang.receivals r, strang.movements m, strang.lov l
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    r.cust_customer_id = c.customer_id and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    r.supplier_customer_id = c1.customer_id );

  cursor c3(vShipid integer) is select * from strang.ships_airway where ship_id = vShipid;

  c1rec		customer_account%ROWTYPE;
  c3rec		c3%ROWTYPE;
  f 		utl_file.file_type;
  tot		integer;
  gcode		GLBX.MYARRAY;
  gparam	GLBX.MYARRAY;
  vste		varchar2(10);
  eml		varchar2(100);
  ltype		varchar2(100);
  stype		integer;
  owner_id	integer;
  sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENERATE_CCDETS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 eml := control_code( 'OST156_EMAIL_ADDRESS', vste );
 eml := nvl( eml, glbx.extract_master_parameter('MAIL_FROM') );

 open c2(vShip_id);
 fetch c2 into tot;
 close c2;
 open c3(vShip_id);
 fetch c3 into c3rec;
 close c3;
 f := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'OST156_' || c3rec.shipname || '_' || c3rec.voy || '.csv', 'w', 32767);

 -- Output Header
 utl_file.put_line(f, buffer=>'H,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot || ','',,'',,'',,'',,'',,'',,' );
 for c1rec in c1(vShip_id) loop
  utl_file.put_line(f, buffer=>c1rec.movement_no || ',' || c1rec.logno || ',' || c1rec.deliveryno || ',' || c1rec.itemno || ',' || c1rec.po || ',' || c1rec.camov_seal || ',' || c1rec.voy || ',' || c1rec.shipname ||
                    ',' || to_char(c1rec.estdepart,'DD.MM.YYYY') || ',' || to_char(c1rec.estarrive,'DD.MM.YYYY') || ',' || c1rec.pload || ',' || replace(c1rec.hazard, ',', ' ') || ',' || c1rec.partweight || ',' || c1rec.partvolume || ',' || c1rec.cus1 || ',' || c1rec.cus2 );
 end loop;
 -- Output Header
 utl_file.put_line(f, buffer=>'F,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot || ','',,'',,'',,'',,'',,'',,' );
 utl_file.fclose( f );

 gcode(1) := 'XXXX'; -- Dummy Parameter
 gparam(1) := 'XXXX';
 glbx.send( gcode, gparam, 'OST156_' || c3rec.shipname || '_' || c3rec.voy || '.csv', p_to=>eml, p_subj=>'OST156_' || c3rec.shipname || '_' || c3rec.voy, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE);

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_OST156',null,null,errmsg=>sqlerrm);
end generate_ost156;

procedure generate_OST157( surl in varchar2, vShip_id in integer )
as

 cursor c1a( vShip_id integer ) is
   select distinct dr.movement_no, dr.logno, dr.deliveryno, dr.itemno, p.po, dr.camov_seal, s.voy, s.shipname, s.estdepart, s.estarrive, l.description pload, dr.hazard, dr.partweight, dr.partvolume, c.customer cus1, c1.customer cus2
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.customers c, strang.customers c1, strang.receivals r, strang.movements m, strang.lov l
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    r.cust_customer_id = c.customer_id and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    r.supplier_customer_id = c1.customer_id AND
    R.CUST_CUSTOMER_ID=1 AND
    (DR.CAMOV_SEAL is not null); -- RETRIEVES ONLY OK-TEDI CONTAINERIZED CARGO

 cursor c1b( vShip_id integer ) is
   select distinct dr.movement_no, dr.logno, dr.deliveryno, dr.itemno, p.po, dr.camov_seal, s.voy, s.shipname, s.estdepart, s.estarrive, l.description pload, dr.hazard, dr.partweight, dr.partvolume, c.customer cus1, c1.customer cus2
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.customers c, strang.customers c1, strang.receivals r, strang.movements m, strang.lov l
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    r.cust_customer_id = c.customer_id and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    r.supplier_customer_id = c1.customer_id AND
    R.CUST_CUSTOMER_ID=1 AND
    (DR.CAMOV_SEAL is null); -- RETRIEVES ONLY OK-TEDI BREAK-BULK CARGO


   cursor c1c( vShip_id integer ) is
     select distinct dr.movement_no
     from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.customers c, strang.customers c1, strang.receivals r, strang.movements m, strang.lov l
     where
      s.ship_id = vShip_id and
      m.ship_id = s.ship_id and
      m.movement_no = dr.movement_no and
      nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
      r.deliveryno = dr.deliveryno and
      r.deliveryno = p.deliveryno and
      r.cust_customer_id = c.customer_id and
      l.lov_name = 'LOCATIONS' and
      l.code = s.portload and
      r.supplier_customer_id = c1.customer_id AND
      R.CUST_CUSTOMER_ID>=2 AND
      (DR.CAMOV_SEAL is not null); -- RETRIEVES ONLY CONTRACTOR CONTAINER NUMBERS


 cursor c2a( vShip_id integer ) is
   select count('x') tota
   from
   ( select distinct dr.movement_no, dr.logno, dr.deliveryno, dr.itemno, p.po, dr.camov_seal, s.voy, s.shipname, s.estdepart, s.estarrive, l.description pload, dr.hazard, dr.partweight, dr.partvolume, c.customer cus1, c1.customer cus2
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.customers c, strang.customers c1, strang.receivals r, strang.movements m, strang.lov l
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    r.cust_customer_id = c.customer_id and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    r.supplier_customer_id = c1.customer_id  AND
    R.CUST_CUSTOMER_ID=1 AND
    (DR.CAMOV_SEAL is not null) ); -- RETRIEVES ONLY OK-TEDI CONTAINERIZED CARGO


 cursor c2b( vShip_id integer ) is
   select count('x') totb
   from
   ( select distinct dr.movement_no, dr.logno, dr.deliveryno, dr.itemno, p.po, dr.camov_seal, s.voy, s.shipname, s.estdepart, s.estarrive, l.description pload, dr.hazard, dr.partweight, dr.partvolume, c.customer cus1, c1.customer cus2
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.customers c, strang.customers c1, strang.receivals r, strang.movements m, strang.lov l
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    r.cust_customer_id = c.customer_id and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    r.supplier_customer_id = c1.customer_id  AND
    R.CUST_CUSTOMER_ID=1 AND
    (DR.CAMOV_SEAL is null) ); -- RETRIEVES ONLY OK-TEDI BREAK-BULK CARGO

 cursor c2c( vShip_id integer ) is
   select count('x') totc
   from
   ( select distinct dr.movement_no
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.customers c, strang.customers c1, strang.receivals r, strang.movements m, strang.lov l
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    r.cust_customer_id = c.customer_id and
    l.lov_name = 'LOCATIONS' and
    l.code = s.portload and
    r.supplier_customer_id = c1.customer_id  AND
    (DR.CAMOV_SEAL is not null) ); -- RETRIEVES ONLY CONTRACTOR CONTAINER NUMBERS



  cursor c3(vShipid integer) is select * from strang.ships_airway where ship_id = vShipid;

  c1arec		customer_account%ROWTYPE;
  c1brec		customer_account%ROWTYPE;
  c1crec		customer_account%ROWTYPE;
  c3rec		c3%ROWTYPE;
  f 		utl_file.file_type;
  tot		integer;
  tota		integer;
  totb		integer;
  totc		integer;
  gcode		GLBX.MYARRAY;
  gparam	GLBX.MYARRAY;
  vste		varchar2(10);
  lastctr	varchar2(100);
  eml		varchar2(100);
  ltype		varchar2(100);
  stype		integer;
  owner_id	integer;
  sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENERATE_CCDETS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1arec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1arec.aid);
 eml := control_code( 'OST156_EMAIL_ADDRESS', vste );
 eml := nvl( eml, glbx.extract_master_parameter('MAIL_FROM') );

 -- open c2(vShip_id);
 -- fetch c2 into tot;
 -- close c2;

 open c2a(vShip_id);
 fetch c2a into tota;
 close c2a;
 open c2b(vShip_id);
 fetch c2b into totb;
 close c2b;
 open c2c(vShip_id);
 fetch c2c into totc;
 close c2c;
 tot := tota + totb +totc;
 lastctr := 'BREAKBULK';


 open c3(vShip_id);
 fetch c3 into c3rec;
 close c3;
 f := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'OST157_' || c3rec.shipname || '_' || c3rec.voy || '.csv', 'w', 32767);

 -- Output Header
 utl_file.put_line(f, buffer=>'H,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot || ','',,'',,'',,'',,'',,'',,' );
 for c1arec in c1a(vShip_id) loop
  utl_file.put_line(f, buffer=>c1arec.movement_no || ',' || c1arec.logno || ',' || c1arec.deliveryno || ',' || c1arec.itemno || ',' || c1arec.po || ',' || c1arec.camov_seal || ',' || c1arec.voy || ',' || c1arec.shipname ||
                    ',' || to_char(c1arec.estdepart,'DD.MM.YYYY') || ',' || to_char(c1arec.estarrive,'DD.MM.YYYY') || ',' || c1arec.pload || ',' || replace(c1arec.hazard, ',', ' ') || ',' || c1arec.partweight || ',' || c1arec.partvolume || ',' || c1arec.cus1 || ',' || c1arec.cus2 );
  lastctr := c1arec.movement_no ;
 end loop;
 for c1brec in c1b(vShip_id) loop
  utl_file.put_line(f, buffer=>lastctr || ',' || c1brec.logno || ',' || c1brec.deliveryno || ',' || c1brec.itemno || ',' || c1brec.po || ',' || c1brec.camov_seal || ',' || c1brec.voy || ',' || c1brec.shipname ||
                    ',' || to_char(c1brec.estdepart,'DD.MM.YYYY') || ',' || to_char(c1brec.estarrive,'DD.MM.YYYY') || ',' || c1brec.pload || ',' || replace(c1brec.hazard, ',', ' ') || ',' || c1brec.partweight || ',' || c1brec.partvolume || ',' || c1brec.cus1 || ',' || c1brec.cus2 );
 end loop;
 for c1crec in c1c(vShip_id) loop
  utl_file.put_line(f, buffer=>c1crec.movement_no || ','',,'',,'',,'',,'',,'',,'',,' );
 end loop;
 -- Output Header
 utl_file.put_line(f, buffer=>'F,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot || ','',,'',,'',,'',,'',,'',,' );
 utl_file.fclose( f );

 gcode(1) := 'XXXX'; -- Dummy Parameter
 gparam(1) := 'XXXX';
 glbx.send( gcode, gparam, 'OST157_' || c3rec.shipname || '_' || c3rec.voy || '.csv', p_to=>eml, p_subj=>'OST157_' || c3rec.shipname || '_' || c3rec.voy, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE);

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_OST157',null,null,errmsg=>sqlerrm);
end generate_OST157;

procedure generate_ost185( surl in varchar2, vtoday in date, is_batch in varchar2 default 'FALSE' )
as

 cursor c1( vtoday date ) is
select distinct p.po,p.recno,p.po_item_no,'0'|| to_char(p.deliveryno) waybill, nvl(l.cola,'LC') po_waybill_type,
  decode(substr(dr.logno,5,2), 'BS' , 'BRIS','TS','TVL','CA','CRNS','BA','BRIS')  forward_warehouse,
  decode(substr(dr.logno,5,2), 'BS' , 'BRIS','TS','TVL','CA','AIR','BA','AIR') current_location,
  decode(substr(dr.logno,5,2), 'BS' , 'TAB', 'TS' , 'TAB','CA','TAB','BA','POM')  delivery_location,
  substr(trim(replace(replace(UPPER(l.description),' STB'),' STC')),1,10) dr_unit,
  dr.qty dr_qty, dr.partweight, dr.partvolume,p.qty,dr.logno receipt_reference,
  to_char(r.currdate,'YYYYMMDD') r_currdate, p.rowid
from strang.pos p, strang.detailrs dr, strang.receivals r, strang.lov l
where p.off_site_receipt is null and
  p.po_item_no is not null and
  p.deliveryno = r.deliveryno and
  p.deliveryno = dr.deliveryno and
  dr.deliveryno = p.deliveryno and
  dr.itemno = 1 and
  r.cust_customer_id = 1   and
  l.lov_name = 'PACKTYPES' and
  dr.pktpe_packtype = l.code and
  dr.detaildesc not like '%PERSONAL EFFECT%' and
  substr(dr.logno,5,2) in ('BS','BA','CA','TS');

 cursor c2( vtoday date ) is
   select count('x') tot
   from
   ( select distinct p.po,p.recno,p.po_item_no,'0'|| to_char(p.deliveryno) waybill, nvl(l.cola,'LC') po_waybill_type,
  decode(substr(dr.logno,5,2), 'BS' , 'BRIS','TS','TVL','CA','CRNS','BA','BRIS')  forward_warehouse,
  decode(substr(dr.logno,5,2), 'BS' , 'BRIS','TS','TVL','CA','AIR','BA','AIR') current_location,
  decode(substr(dr.logno,5,2), 'BS' , 'TAB', 'TS' , 'TAB','CA','TAB','BA','POM')  delivery_location,
  substr(trim(replace(replace(UPPER(l.description),' STB'),' STC')),1,10) dr_unit,
  dr.qty dr_qty, dr.partweight, dr.partvolume,p.qty,dr.logno receipt_reference,
  to_char(r.currdate,'YYYYMMDD') r_currdate, p.rowid
from strang.pos p, strang.detailrs dr, strang.receivals r, strang.lov l
where p.off_site_receipt is null and
  p.po_item_no is not null and
  p.deliveryno = r.deliveryno and
  p.deliveryno = dr.deliveryno and
  dr.deliveryno = p.deliveryno and
  dr.itemno = 1 and
  r.cust_customer_id = 1   and
  l.lov_name = 'PACKTYPES' and
  dr.pktpe_packtype = l.code and
  dr.detaildesc not like '%PERSONAL EFFECT%' and
  substr(dr.logno,5,2) in ('BS','BA','CA','TS'));

  cursor c3(vtoday date) is select to_char(sysdate) v1date from dual;

  c1rec       customer_account%ROWTYPE;
  c3rec       c3%ROWTYPE;
  f           utl_file.file_type;
  tot         integer;
  gcode       GLBX.MYARRAY;
  gparam      GLBX.MYARRAY;
  vste        varchar2(10);
  eml         varchar2(100);
  ltype       varchar2(100);
  stype       integer;
  owner_id    integer;
  sts         varchar2(100);
  ctr         integer;

begin
 if nvl(is_batch, 'FALSE') = 'TRUE'
  then
   sts := null;
   vste := 'SYD';
 else
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENERATE_OST185' );
   c1rec := glbx.get_aid( owner_id, 'C', ltype );
   vste := customer_state(c1rec.aid);
 end if;

 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 eml := control_code( 'OST185_EMAIL_ADDRESS', vste );
 eml := nvl( eml, glbx.extract_master_parameter('MAIL_FROM') );

 open c2(vtoday);
 fetch c2 into tot;
 close c2;
 open c3(vtoday);
 fetch c3 into c3rec;
 close c3;
 f := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'OST185_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv', 'w', 32767);

 -- Output Header
 utl_file.put_line(f, buffer=>'H,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot || ','',,'',,'',,'',,' );
 ctr := 0;
 for c1rec in c1(vtoday) loop
  utl_file.put_line(f, buffer=>c1rec.po || ',' || c1rec.po_item_no || ',0' || c1rec.waybill || ',OK TEDI MINING LTD ,' || c1rec.po_waybill_type || ','
                        || c1rec.forward_warehouse || ',' || c1rec.current_location || ',' || c1rec.delivery_location || ','
                        ||  c1rec.dr_qty || ',' || c1rec.dr_unit || ',' || c1rec.partvolume || ',' || c1rec.partweight || ',' || c1rec.qty || ',' || c1rec.receipt_reference || ',' || c1rec.r_currdate );
  update strang.pos set off_site_receipt = sysdate where rowid = c1rec.rowid;
  update strang.pos set po_waybill_type = c1rec.po_waybill_type where rowid = c1rec.rowid;
  update strang.pos set qty = c1rec.partweight where unit_unitused in ('BAGS','BAG') and rowid = c1rec.rowid;
  update strang.pos set unit_unitused = 'KG' where unit_unitused in ('BAGS','BAG') and rowid = c1rec.rowid;

  ctr := ctr + 1;
 end loop;
 -- Output Header
 utl_file.put_line(f, buffer=>'F,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot || ','',,'',,'',,'',,' );
 utl_file.fclose( f );

 gcode(1) := 'XXXX'; -- Dummy Parameter
 gparam(1) := 'XXXX';

 if ctr > 0
  then
   glbx.send( gcode, gparam, 'OST185_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv', p_to=>eml, p_subj=>'OST185_' || c3rec.v1date || '_' || to_char(sysdate, 'hh24mi'), p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE);
 else
   begin
    utl_file.fremove(glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'OST185_' || to_char(sysdate, 'dd_mon_yyyy_hh24mi') || '.csv');
   exception when others then null;
   end;
 end if;

 if nvl(is_batch, 'FALSE') = 'TRUE'
  then
   return;
 else
   strangp.ost_185_screen(surl,'MESSAGE', ctr || ' records processed');
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_OST185',null,null,errmsg=>sqlerrm);
end generate_ost185;

procedure manentry(surl in varchar2, rid in varchar2 default null, scid in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null, access_id in varchar2 default null, msg in varchar2 default null, id in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.manentry where rowid = rid;
 cursor c5( entryno number) is select rowid from strang.manent2 where entry_no = entryno and rno = (select min(rno) from strang.manent2 where entry_no = entryno);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c5rec		c5%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.MANENTRY' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'MANENTRY', rid );
 open c2( nrid );
 fetch c2 into c2rec;
 close c2;

 glbx.main_title( surl, LNGS.STR_TXT_448,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 --htp.anchor( 'javascript: window.open(''' || 'strangs.list_entry?surl=' || surl || ''',''' || 'SAD_ENTRY' || ''',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');', '[Test List All SAD]' );
 if data_access(owner_id, 'SAD', rid ) = 'EDIT'
  then
   htp.anchor( 'javascript: window.open(''' || 'strangs.accept_list_entry?surl=' || surl || '&p1=&p2=&p3=&p4=' || c2rec.entry_no || ''',''' || 'SAD_ENTRY' || ''',''height=800,width=1200,scrollbars=yes,resizable=yes'');void('''');', '[Generate and Edit SAD:' || c2rec.entry_no || ']' );
   htp.nl;
 end if;

 htp.formopen( 'strangp.accept_manentry' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'SCID', scid );
  htp.formhidden( 'PARM', parm );
  htp.formhidden( 'CALL_NAME', call_name );
  htp.formhidden( 'ACCESS_ID', access_id );
  htp.formhidden( 'RID', nrid );
  htp.formhidden( 'OLD_ENTRY', c2rec.entry_no );

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold(LNGS.STR_TXT_449), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' and c2rec.entry_no is null
    then
     htp.tabledata( htf.formtext( 'ENTRYNO', 10, 20, c2rec.entry_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    elsif vaccess = 'EDIT' and c2rec.entry_no is not null
     then
     htp.tabledata( htf.formhidden( 'ENTRYNO', c2rec.entry_no ) || htf.bold( c2rec.entry_no ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    else
     htp.tabledata( htf.bold( c2rec.entry_no ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold(LNGS.STR_TXT_296), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'WARRANT_NO' ) || htf.formtext( 'P2', 10, 15, c2rec.warrant_no), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.warrant_no ), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('CPC') || htf.nl || htf.bold('Account'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'CPC' ) || htf.formtext( 'P2', 30, 30, c2rec.cpc) || htf.nl ||
                                           htf.formhidden( 'P1', 'ACCOUNT_NUMBER' ) || htf.formtext( 'P2', 10, 15, c2rec.account_number), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.cpc ) || htf.nl || htf.bold( c2rec.account_number ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Cheque No'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'CHEQUE_NO' ) || htf.formtext( 'P2', 10, 15, c2rec.cheque_no), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.cheque_no ), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Exporter/Consignor'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'EXPORTER' ) || htf.formtext( 'P2', 40, 40, c2rec.exporter), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.exporter ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Duty'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( htf.bold( nvl(to_char(c2rec.duty,'999999999.99'),'&nbsp;') ), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Address'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'EXPORTER_ADDRESS' ) || htf.formtext( 'P2', 20, 25, c2rec.exporter_address), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.exporter_address ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Excise'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( htf.bold( nvl(to_char(c2rec.excise,'999999999.99'),'&nbsp;' )), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'EXPORTER_ADDRESS1' ) || htf.formtext( 'P2', 20, 25, c2rec.exporter_address1), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.exporter_address1 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('VAT'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( htf.bold( nvl(to_char(c2rec.vat,'999999999.99'),'&nbsp;' )), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('1a Code'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'ONE_A_CODE' ) || htf.formtext( 'P2', 20, 25, c2rec.one_a_code), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.one_a_code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Levy'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( htf.bold( nvl(to_char(c2rec.levy,'999999999.99'),'&nbsp;' ) ), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Importer/Consignee'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'IMPORTER' ) || htf.formtext( 'P2', 40, 40, c2rec.importer), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="1"' );
   else htp.tabledata( htf.bold( c2rec.importer ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="1"' );
   end if;
   htp.tabledata( htf.bold('Variance'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( htf.bold( nvl(to_char(c2rec.pvariance,'999999999999.99'),'&nbsp;' )), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Address'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'IMPORTER_ADDRESS' ) || htf.formtext( 'P2', 20, 25, c2rec.importer_address), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   else htp.tabledata( htf.bold( c2rec.importer_address ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'IMPORTER_ADDRESS1' ) || htf.formtext( 'P2', 20, 25, c2rec.importer_address1), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.importer_address1 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('2a Code'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'TWO_A_CODE' ) || htf.formtext( 'P2', 15, 15, c2rec.two_a_code), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.two_a_code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Declarant Agent'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'DECLARER' ) || htf.formtext( 'P2', 20, 20, c2rec.declarer), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   else htp.tabledata( htf.bold( c2rec.declarer ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Address'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'DECLARER_ADDRESS' ) || htf.formtext( 'P2', 25, 25, c2rec.declarer_address), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   else htp.tabledata( htf.bold( c2rec.declarer_address ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'DECLARER_ADDRESS1' ) || htf.formtext( 'P2', 25, 25, c2rec.declarer_address1), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.declarer_address1 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('3a Code'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'THREE_A_CODE' ) || htf.formtext( 'P2', 15, 15, c2rec.three_a_code), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.three_a_code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   htp.tabledata( htf.bold('3b Reference'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'THREE_B_REFERENCE' ) || htf.formtext( 'P2', 15, 15, c2rec.three_b_reference), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.three_b_reference ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Agent'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'AGENT' ) || htf.formtext( 'P2', 25, 25, c2rec.agent), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.agent ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Position'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'POSITION' ) || htf.formtext( 'P2', 20, 30, c2rec.position), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.position ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Short Description<BR>of Cargo'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'SHORTDESC' ) || htf.formtext( 'P2', 30, 30, c2rec.shortdesc), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   else htp.tabledata( htf.bold( c2rec.shortdesc ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Port of Loading'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'PORT_OF_LOADING' ) || htf.formtext( 'P2', 15, 15, c2rec.port_of_loading), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.port_of_loading ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Port of Discharge'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'PORT_OF_DISCHARGE' ) || htf.formtext( 'P2', 15, 15, c2rec.port_of_discharge), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.port_of_discharge ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Ship'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'SHIP_NAME' ) || htf.formtext( 'P2', 30, 40, c2rec.ship_name), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.ship_name ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Voyage'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'VOYAGE' ) || htf.formtext( 'P2', 15, 15, c2rec.voyage), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.voyage ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Manifest Lines'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'MANIFEST_LINES' ) || htf.formtext( 'P2', 25, 25, c2rec.manifest_lines), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.manifest_lines ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Bills of Lading'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'BILL_OF_LADING' ) || htf.formtext( 'P2', 15, 15, c2rec.bill_of_lading), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.bill_of_lading ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Arr/Dept Date'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'DATE_OF_ARRIVAL_DEPARTURE' ) || htf.formtext( 'P2', 15, 15, c2rec.date_of_arrival_departure), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.date_of_arrival_departure ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Country'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'COUNTRY_NAME' ) || htf.formtext( 'P2', 25, 25, c2rec.country_name), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.country_name ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Code'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'COUNTRY_CODE' ) || htf.formtext( 'P2', 3, 3, c2rec.country_code), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.country_code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Invoice Total'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'INVOICE_TOTAL' ) || htf.formtext( 'P2', 15, 20, trim(to_char(c2rec.invoice_total,'999999999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c2rec.invoice_total,'999999999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Currency'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'CURRENCY_CODE' ) || htf.formtext( 'P2', 3, 3, c2rec.currency_code), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.currency_code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Exchange Rate'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'EXCHANGE_RATE' ) || htf.formtext( 'P2', 10, 20, c2rec.exchange_rate), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.exchange_rate ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Insurance Rate'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'INSURANCE_RATE' ) || htf.formtext( 'P2', 10, 20, trim(to_char(c2rec.insurance_rate,'999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c2rec.insurance_rate,'999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   htp.tabledata( htf.bold('Other Costs Rate'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'OTHER_COSTS_RATE' ) || htf.formtext( 'P2', 10, 20, c2rec.other_costs_rate), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.other_costs_rate ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Freight Rate'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'FREIGHT_RATE' ) || htf.formtext( 'P2', 10, 20, trim(to_char(c2rec.freight_rate,'999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c2rec.freight_rate,'999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   htp.tabledata( htf.bold('Revenue Tonne'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'REVENUE_TONNE' ) || htf.formtext( 'P2', 10, 20, c2rec.revenue_tonne), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.exchange_rate ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Freight'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'FREIGHT' ) || htf.formtext( 'P2', 10, 20, to_char(c2rec.freight,'999999.99')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c2rec.freight,'999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Insurance'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'INSURANCE' ) || htf.formtext( 'P2', 10, 20, to_char(c2rec.insurance,'999999.99')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c2rec.insurance,'999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Other Costs'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'OTHER_COSTS' ) || htf.formtext( 'P2', 10, 20, to_char(c2rec.other_costs,'999999.99')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c2rec.other_costs,'999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Ratio Factor'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'RATIO_FACTOR' ) || htf.formtext( 'P2', 20, 20, to_char(c2rec.ratio_factor,'999.99999999')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="2"' );
   else htp.tabledata( htf.bold( to_char(c2rec.ratio_factor,'999.99999999') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="2"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Mode of Transport'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'MODE_OF_TRANSPORT' ) || htf.formtext( 'P2', 10, 10, c2rec.mode_of_transport), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.mode_of_transport ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Code'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'CODE' ) || htf.formtext( 'P2', 10, 15, c2rec.code), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   else htp.tabledata( htf.bold( c2rec.code ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Warehouse'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'WAREHOUSE_NAME' ) || htf.formtext( 'P2', 10, 15, c2rec.warehouse_name), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.warehouse_name ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('No'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'WAREHOUSE_NUMBER' ) || htf.formtext( 'P2', 10, 15, c2rec.warehouse_number), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   else htp.tabledata( htf.bold( c2rec.warehouse_number ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Terms of Delivery'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'TERMS_OF_DELIVERY' ) || htf.formtext( 'P2', 15, 15, c2rec.terms_of_delivery), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.terms_of_delivery ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Predeeding Doc'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'PRECEDING_DOCUMENTS' ) || htf.formtext( 'P2', 15, 15, c2rec.preceding_documents), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   else htp.tabledata( htf.bold( c2rec.preceding_documents ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Supporting Documents'), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT" COLSPAN="6"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Invoice'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'ATTACHMENTS_INVOICES' ) || htf.formtext( 'P2', 3, 3, c2rec.attachments_invoices), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.attachments_invoices ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Packing List'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'ATTACHMENTS_PACKING' ) || htf.formtext( 'P2', 3, 3, c2rec.attachments_packing), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.attachments_packing ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Delivery Order'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'ATTACHMENTS_ORDER' ) || htf.formtext( 'P2', 3, 3, c2rec.attachments_order), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.attachments_order ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Licence'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'ATTACHMENTS_LICENCE' ) || htf.formtext( 'P2', 3, 3, c2rec.attachments_licence), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.attachments_licence ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Freight Doc'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'ATTACHMENTS_FREIGHT' ) || htf.formtext( 'P2', 3, 3, c2rec.attachments_freight), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.attachments_freight ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Other'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'ATTACHMENTS_OTHER' ) || htf.formtext( 'P2', 3, 3, c2rec.attachments_other), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c2rec.attachments_other ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
 htp.tableclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
  if vaccess = 'EDIT'
   then

    if rid is not null
     then
      htp.p( '<TD VALIGN="TOP">' );
       htp.formsubmit( 'ACTION', 'Update' );
      htp.p( '</TD>' );
      htp.p( '<TD VALIGN="TOP">' );
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_458 );
      htp.p( '</TD>' );
      htp.p( '<TD VALIGN="TOP">' );
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_459 );
      htp.p( '</TD>' );
      htp.p( '<TD VALIGN="TOP">' );
       htp.formsubmit( 'ACTION', 'Delete' );
      htp.p( '</TD>' );
      htp.p( '<TD VALIGN="TOP">' );
       htp.formsubmit( 'ACTION', LNGS.STR_TXT_460 );
      htp.p( '</TD>' );
      htp.p( '<TD VALIGN="TOP">' );
       htp.formsubmit( 'ACTION', 'Recalculate' );
       htp.formclose;
      htp.p( '</TD>' );
     else
      htp.p( '<TD VALIGN="TOP">' );
       htp.formsubmit( 'ACTION', 'Insert' );
       htp.formclose;
      htp.p( '</TD>' );
    end if;

  else

    if rid is not null
     then
      htp.p( '<TD VALIGN="TOP">' );
       htp.anchor( 'strangp.manentry_page2?surl=' || surl || '&rid=' || replace(nrid,'+','~') || '&scid=' || scid || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id, LNGS.STR_TXT_458 );
      htp.p( '</TD>' );
      open c5(c2rec.entry_no);
      fetch c5 into c5rec;
      close c5;
      htp.p( '<TD VALIGN="TOP">' );
       htp.anchor( 'strangp.manentry_page3?surl=' || surl || '&rid=' || replace(rowidtochar(c5rec.rowid),'+','~') || '&scid=' || scid || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id, LNGS.STR_TXT_459 );
      htp.p( '</TD>' );
    end if;

 end if;

 htp.p( '<TD VALIGN="TOP">' );
   search( surl, 'ME', nrid, samerow=>TRUE );
 htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MANENTRY',null,owner_id,errmsg=>sqlerrm);
end manentry;

procedure accept_manentry(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, entryno in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c2( rid rowid ) is select * from strang.manentry where rowid = rid;
 cursor c3( ent varchar2 ) is select count('x') exst from strang.manentry where entry_no = ent;
 cursor c4( entryno number) is select rowidtochar(rowid) from strang.manentry where entry_no = entryno;
 cursor c5( entryno number) is select rowid from strang.manent2 where entry_no = entryno and rno = (select min(rno) from strang.manent2 where entry_no = entryno);
 cursor c8( entryno number) is select rowid,tariff from strang.manent2 where entry_no = entryno;
 cursor c9( lv varchar2, cd varchar2 ) is select * from strang.lov where lov_name = lv and code = cd;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c9rec		c9%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);
 msg		varchar2(100);
 nmb		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_MANENTRY' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'MANENTRY', rid );

 if vaccess = 'EDIT'
  then

 -- Validate Number
 begin
  nmb := to_number(entryno);
 exception
  when others then
   manentry( surl, nrid, scid, call_name, parm, access_id, 'Invalid Number:' || entryno );
   return;
 end;
 if entryno is null
  then
   manentry( surl, nrid, scid, call_name, parm, access_id, 'Entry Number cannot be empty:' || entryno );
   return;
 end if;
 if action = 'Insert'
  then
   open c3( entryno );
   fetch c3 into c3rec;
   close c3;
   if c3rec.exst > 0
    then
     manentry( surl, nrid, scid, call_name, parm, access_id, 'Already exists: ' || entryno  );
     return;
   end if;
   insert into strang.manentry(entry_no) values (entryno);
   insert into strang.manent1(entry_no) values (entryno);
   insert into strang.manent2(entry_no,rno) values (entryno,1);
   msg := 'Manual Entry Inserted';
 elsif action = 'Delete'
  then
   confirm_manentry_delete( surl, nrid, scid, call_name, parm, access_id, 'Delete Manual Entry ' || entryno );
   return;
 else
   if nvl(old_entry,'!') <> nvl(entryno,'\')
    then
     open c3( entryno );
     fetch c3 into c3rec;
     close c3;
     if c3rec.exst > 0
      then
        manentry( surl, nrid, scid, call_name, parm, access_id, 'Already exists: ' || entryno  );
       return;
     end if;
     update strang.manentry set entry_no = entryno where entry_no = old_entry;
   end if;
   open c2( nrid );
   fetch c2 into c2rec;
   close c2;
 end if;
 if action <> 'Delete'
  then
   for j in p1.first..p1.last loop
    begin
     execute immediate
      'update strang.manentry set ' || p1(j) || ' = :1 where entry_no = :2'
        using p2(j), entryno;
    exception
     when others then msg := msg || '[Error Modifying ' || initcap(p1(j)) || ' to value: ' || p2(j) || ']';
    end;
   end loop;
 end if;
 commit;
 if action = 'Recalculate'
  then
   update strang.manentry
    set
     freight = nvl(revenue_tonne,1) * nvl(freight_rate,1) * nvl(exchange_rate,1),
     insurance = (nvl(insurance_rate,0) / 100) * nvl(invoice_total,1),
     other_costs = nvl(invoice_total,1) * (nvl(other_costs_rate,0)/100)
   where entry_no = entryno;
   update strang.manentry
    set
     ratio_factor = ((nvl(invoice_total,0) + nvl(freight,0) + nvl(other_costs,0) + nvl(insurance,0)) /
                      decode(nvl(exchange_rate,1),0,1,nvl(exchange_rate,1)) ) /
                    decode(nvl(invoice_total,1),0,1,nvl(invoice_total,1))
   where entry_no = entryno;
  else
   update strang.manentry
    set
     freight = nvl(freight,nvl(revenue_tonne,1) * nvl(freight_rate,1) * nvl(exchange_rate,1)),
     insurance = nvl(insurance,(nvl(insurance_rate,0) / 100) * nvl(invoice_total,1)),
     other_costs = nvl(other_costs,nvl(invoice_total,1) * (nvl(other_costs_rate,0)/100))
   where entry_no = entryno;
   update strang.manentry
    set
     ratio_factor = nvl(ratio_factor,
                    ((nvl(invoice_total,0) + nvl(freight,0) + nvl(other_costs,0) + nvl(insurance,0)) /
                      decode(nvl(exchange_rate,1),0,1,nvl(exchange_rate,1)) ) /
                      decode(nvl(invoice_total,1),0,1,nvl(invoice_total,1)))
   where entry_no = entryno;
 end if;

 if action = 'Recalculate'
  then
   -- Refresh all the Tariff's
   update strang.manentry m1
    set
      duty = (select sum(nvl(m2.duty,0)) from strang.manent2 m2 where m2.entry_no = entryno ),
      vat = (select sum(nvl(m2.vat,0)) from strang.manent2 m2 where m2.entry_no = entryno ),
      excise = (select sum(nvl(m2.excise,0)) from strang.manent2 m2 where m2.entry_no = entryno ),
      levy = (select sum(nvl(m2.levy,0)) from strang.manent2 m2 where m2.entry_no = entry_no )
     where
      entry_no = entryno;
   update strang.manentry m1
    set
      pvariance = (select (m1.duty + m1.excise + m1.vat + nvl(m1.levy,0)) - ((sum(nvl(m2.kinavalue,0)) * 0.015) + sum(nvl(m2.oldduty,0)) ) from strang.manent2 m2 where entry_no = entryno )
     where
      entry_no = entryno;

   for c8rec in c8(entryno) loop
    open c9( 'TARIFF', c8rec.tariff );
    fetch c9 into c9rec;
    if c9%FOUND
     then
     close c9;

     update strang.manent2 m2
      set
       unit = c9rec.cola,
       rate = c9rec.description,
        excise_rate = c9rec.colc,
       oldrate = c9rec.colb,
       kinavalue = (select ratio_factor * m2.value from strang.manentry where entry_no = entryno)
      where rowid = c8rec.rowid;

     update strang.manent2 m2
      set
       duty = (select (ratio_factor * m2.value * m2.rate ) / 100 from strang.manentry where entry_no = entryno)
     where rowid = c8rec.rowid;

     update strang.manent2 m2
      set
       oldduty = (select (ratio_factor * m2.value * m2.oldrate ) / 100 from strang.manentry where entry_no = entryno)
     where rowid = c8rec.rowid;

     update strang.manent2 m2
      set
       excise = (select ( ((ratio_factor * m2.value) + m2.duty) * m2.excise_rate ) / 100 from strang.manentry where entry_no = entryno)
     where rowid = c8rec.rowid;

     update strang.manent2 m2
      set
       vat = ((nvl(kinavalue,0) + nvl(duty,0) + nvl(excise,0)) * nvl(vat_rate,1)) / 100
     where rowid = c8rec.rowid;

    else
     close c9;
    end if;

   end loop;

   commit;
 end if;

 end if; -- End of Edit Data
 msg := nvl(msg,'Manual Record Updated');
 open c4(entryno);
 fetch c4 into nrid;
 close c4;

 if action in ('Insert','Update','Recalculate')
  then
   manentry( surl, nrid, scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_460
  then
   manentry( surl, null, scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_458
  then
   manentry_page2( surl, nrid, scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_459
  then
   open c5(entryno);
   fetch c5 into c5rec;
   close c5;
   manentry_page3( surl, rowidtochar(c5rec.rowid), scid, call_name, parm, access_id, msg );
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MANENTRY',null,owner_id,errmsg=>sqlerrm);
end accept_manentry;

procedure manentry_page2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.manentry where rowid = rid;
 cursor c3( entryno number ) is select * from strang.manent1 where entry_no = entryno;
 cursor c5( entryno number) is select rowid from strang.manent2 where entry_no = entryno and rno = (select min(rno) from strang.manent2 where entry_no = entryno);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.MANENTRY_PAGE2' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'MANENTRY', rid );
 open c2( nrid );
 fetch c2 into c2rec;
 close c2;
 open c3( c2rec.entry_no );
 fetch c3 into c3rec;
 close c3;

 glbx.main_title( surl, 'Manual Entry - Package Description',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_manentry_page2' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'CALL_NAME', call_name );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID', nrid );
   htp.formhidden( 'OLD_ENTRY', c2rec.entry_no );
 end if;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('No of<BR>Packages'), cattributes=>glbx.QUERY_BACKGROUND || 'align="CENTER"' );
   htp.tabledata( htf.bold('Description'), cattributes=>glbx.QUERY_BACKGROUND || 'align="CENTER"' );
  htp.tablerowclose;
  if vaccess = 'EDIT'
   then
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Manual Entry No' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.bold( c2rec.entry_no), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK1' ) || htf.formtext( 'P2', 7, 7, c3rec.pack1), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION1' ) || htf.formtext( 'P2', 67, 67, c3rec.description1), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK2' ) || htf.formtext( 'P2', 7, 7, c3rec.pack2), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION2' ) || htf.formtext( 'P2', 67, 67, c3rec.description2), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK3' ) || htf.formtext( 'P2', 7, 7, c3rec.pack3), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION3' ) || htf.formtext( 'P2', 67, 67, c3rec.description3), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK4' ) || htf.formtext( 'P2', 7, 7, c3rec.pack4), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION4' ) || htf.formtext( 'P2', 67, 67, c3rec.description4), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK5' ) || htf.formtext( 'P2', 7, 7, c3rec.pack5), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION5' ) || htf.formtext( 'P2', 67, 67, c3rec.description5), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK6' ) || htf.formtext( 'P2', 7, 7, c3rec.pack6), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION6' ) || htf.formtext( 'P2', 67, 67, c3rec.description6), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK7' ) || htf.formtext( 'P2', 7, 7, c3rec.pack7), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION7' ) || htf.formtext( 'P2', 67, 67, c3rec.description7), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK8' ) || htf.formtext( 'P2', 7, 7, c3rec.pack8), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION8' ) || htf.formtext( 'P2', 67, 67, c3rec.description8), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK9' ) || htf.formtext( 'P2', 7, 7, c3rec.pack9), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION9' ) || htf.formtext( 'P2', 67, 67, c3rec.description9), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.formhidden( 'P1', 'PACK10' ) || htf.formtext( 'P2', 7, 7, c3rec.pack10), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION10' ) || htf.formtext( 'P2', 67, 67, c3rec.description10), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
   else
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack1,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description1,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack2,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description2,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack3,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description3,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack4,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description4,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack5,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description5,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack6,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description6,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack7,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description7,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack8,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description8,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack9,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description9,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( nvl(c3rec.pack10,'&nbsp;') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
     htp.tabledata( nvl(c3rec.description10,'&nbsp;'), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
    htp.tablerowclose;
  end if;

 htp.tableclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   if vaccess = 'EDIT'
    then
     htp.p( '<TD VALIGN="TOP">' );
      htp.formsubmit( 'ACTION', 'Update' );
     htp.p( '</TD>' );
     htp.p( '<TD VALIGN="TOP">' );
      htp.formsubmit( 'ACTION', LNGS.STR_TXT_457 );
     htp.p( '</TD>' );
     htp.p( '<TD VALIGN="TOP">' );
      htp.formsubmit( 'ACTION', LNGS.STR_TXT_459 );
      htp.formclose;
     htp.p( '</TD>' );
   else
     htp.p( '<TD VALIGN="TOP">' );
      htp.anchor( 'strangp.manentry?surl=' || surl || '&rid=' || replace(nrid,'+','~') || '&scid=' || scid || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id, LNGS.STR_TXT_457 );
     htp.p( '</TD>' );
     open c5(c2rec.entry_no);
     fetch c5 into c5rec;
     close c5;
     htp.p( '<TD VALIGN="TOP">' );
      htp.anchor( 'strangp.manentry_page3?surl=' || surl || '&rid=' || replace(rowidtochar(c5rec.rowid),'+','~') || '&scid=' || scid || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id, LNGS.STR_TXT_459 );
     htp.p( '</TD>' );
  end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MANENTRY_PAGE2',null,owner_id,errmsg=>sqlerrm);
end manentry_page2;

procedure accept_manentry_page2(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c2( rid rowid ) is select * from strang.manentry where rowid = rid;
 cursor c3( ent varchar2 ) is select count('x') exst from strang.manentry where entry_no = ent;
 cursor c4( entryno number) is select rowidtochar(rowid) from strang.manentry where entry_no = entryno;
 cursor c5( entryno number) is select rowid from strang.manent2 where entry_no = entryno and rno = (select min(rno) from strang.manent2 where entry_no = entryno);

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);
 msg		varchar2(100);
 nmb		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_MANENTRY_PAGE2' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'MANENTRY', rid );

 if vaccess = 'EDIT'
  then

 -- Validate Number
 if old_entry is null
  then
   manentry( surl, nrid, scid, call_name, parm, access_id, 'Entry Number cannot be empty:' || old_entry );
   return;
 end if;
 if action <> 'Delete'
  then
   for j in p1.first..p1.last loop
    begin
     execute immediate
      'update strang.manent1 set ' || p1(j) || ' = :1 where entry_no = :2'
        using p2(j), old_entry;
    exception
     when others then msg := msg || '[Error Modifying ' || initcap(p1(j)) || ' to value: ' || p2(j) || ']';
    end;
   end loop;
 end if;
 commit;
 end if; -- End of Edit Data
 msg := nvl(msg,'Manual Record Updated');
 open c4(old_entry);
 fetch c4 into nrid;
 close c4;

 if action = 'Update'
  then
   manentry_page2( surl, nrid, scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_460
  then
   manentry( surl, null, scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_457
  then
   manentry( surl, nrid, scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_459
  then
   open c5(old_entry);
   fetch c5 into c5rec;
   close c5;
   manentry_page3( surl, rowidtochar(c5rec.rowid), scid, call_name, parm, access_id, msg );
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MANENTRY_PAGE2',null,owner_id,errmsg=>sqlerrm);
end accept_manentry_page2;

procedure manentry_page3(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( entno number) is select rowid from strang.manentry where entry_no = entno;
 cursor c3( rid rowid) is select * from strang.manent2 where rowid = rid;
 cursor c4( entryno number ) is select count('x') tot from strang.manent2 where entry_no = entryno;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.MANENTRY_PAGE3' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'MANENTRY', rid );
 open c3( nrid );
 fetch c3 into c3rec;
 close c3;
 open c4(c3rec.entry_no);
 fetch c4 into c4rec;
 close c4;
 open c2(c3rec.entry_no);
 fetch c2 into c2rec;
 close c2;

 glbx.main_title( surl, 'Manual Entry - Tariff Groups',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 if vaccess = 'EDIT'
  then
   htp.formopen( 'strangp.accept_manentry_page3' );
   htp.formhidden( 'SURL', surl );
   htp.formhidden( 'SCID', scid );
   htp.formhidden( 'PARM', parm );
   htp.formhidden( 'CALL_NAME', call_name );
   htp.formhidden( 'ACCESS_ID', access_id );
   htp.formhidden( 'RID', nrid );
   htp.formhidden( 'OLD_ENTRY', c3rec.entry_no );
 end if;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.tablerowopen;
 htp.p( '<TD VALIGN="TOP" ALIGN="LEFT">' );

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Manual Entry No' ), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
   htp.tabledata( htf.bold( c3rec.entry_no), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT" COLSPAN="3"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Description'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION1' ) || htf.formtext( 'P2', 30, 30, c3rec.description1), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c3rec.description1 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Record #'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'RNO' ) || htf.formhidden( 'P2', c3rec.rno ) || htf.bold( c3rec.rno ) || ' / ' || htf.bold( c4rec.tot ), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c3rec.rno ) || ' / ' || htf.bold( c4rec.tot ), cattributes=>glbx.QUERY_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION2' ) || htf.formtext( 'P2', 30, 30, c3rec.description2), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c3rec.description2 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'DESCRIPTION3' ) || htf.formtext( 'P2', 30, 30, c3rec.description3), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c3rec.description3 ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Origin'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'ORIGIN' ) || htf.formtext( 'P2', 6, 6, c3rec.origin), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c3rec.origin ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Value'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'VALUE' ) || htf.formtext( 'P2', 15, 15, trim(to_char(c3rec.value,'999999999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.value,'999999999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( 'In Original Currency', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT" COLSPAN="4"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('VAT Rate %'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'VAT_RATE' ) || htf.formtext( 'P2', 10, 10, trim(to_char(c3rec.vat_rate,'999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.vat_rate,'999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
   htp.tabledata( htf.bold('Levy Rate %'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'LEVY_RATE' ) || htf.formtext( 'P2', 10, 10, trim(to_char(c3rec.levy_rate,'9999999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( trim(to_char(c3rec.levy_rate,'999999999.99')) ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Tariff'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'TARIFF' ) || htf.formtext( 'P2', 10, 10, c3rec.tariff), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c3rec.tariff ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Quantity'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'QUANTITY' ) || htf.formtext( 'P2', 10, 10, c3rec.quantity), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c3rec.quantity ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Unit'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'UNIT' ) || htf.formtext( 'P2', 10, 8, c3rec.unit), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( c3rec.unit ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT" COLSPAN="4"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Duty Rate %'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'RATE' ) || htf.formtext( 'P2', 10, 10, trim(to_char(c3rec.rate,'999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.rate,'999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Old Duty Rate %'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'OLDRATE' ) || htf.formtext( 'P2', 10, 10, trim(to_char(c3rec.oldrate,'999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.oldrate,'999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Excise Rate %'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'EXCISE_RATE' ) || htf.formtext( 'P2', 10, 10, to_char(c3rec.excise_rate,'999.99')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.excise_rate,'999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT" COLSPAN="4"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Kina Value'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'KINAVALUE' ) || htf.formtext( 'P2', 15, 15, trim(to_char(c3rec.kinavalue,'999999999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.kinavalue,'999999999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Duty'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'DUTY' ) || htf.formtext( 'P2', 15, 15, trim(to_char(c3rec.duty,'999999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.duty,'999999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( htf.bold('Old Duty'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'OLDDUTY' ) || htf.formtext( 'P2', 15, 15, to_char(c3rec.oldduty,'999999999.99')), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.oldduty,'999999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Excise'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'EXCISE' ) || htf.formtext( 'P2', 15, 15, trim(to_char(c3rec.excise,'999999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.excise,'999999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('VAT'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'VAT' ) || htf.formtext( 'P2', 15, 15, trim(to_char(c3rec.vat,'999999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.vat,'999999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold('Levy'), cattributes=>glbx.QUERY_BACKGROUND || 'align="RIGHT"' );
   if vaccess = 'EDIT' then htp.tabledata( htf.formhidden( 'P1', 'LEVY' ) || htf.formtext( 'P2', 15, 20, trim(to_char(c3rec.levy,'999999999.99'))), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   else htp.tabledata( htf.bold( to_char(c3rec.levy,'999999999.99') ), cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="LEFT"' );
   end if;
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
   htp.tabledata( '&nbsp;', cattributes=>glbx.QUERY_CELL_BACKGROUND || 'align="RIGHT"' );
  htp.tablerowclose;
 htp.tableclose;

 htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   if vaccess = 'EDIT'
    then
     htp.p( '<TD VALIGN="TOP">' );
      htp.formsubmit( 'ACTION', 'Update' );
     htp.p( '</TD>' );
     htp.p( '<TD VALIGN="TOP">' );
      htp.formsubmit( 'ACTION', LNGS.STR_TXT_457 );
     htp.p( '</TD>' );
     htp.p( '<TD VALIGN="TOP">' );
      htp.formsubmit( 'ACTION', LNGS.STR_TXT_458 );
     htp.p( '</TD>' );
     htp.p( '<TD VALIGN="TOP">' );
      htp.formsubmit( 'ACTION', LNGS.STR_TXT_452 );
     htp.p( '</TD>' );
     htp.p( '<TD VALIGN="TOP">' );
      htp.formsubmit( 'ACTION', LNGS.STR_TXT_456 );
      htp.formclose;
     htp.p( '</TD>' );
   else
     htp.p( '<TD VALIGN="TOP">' );
      htp.anchor( 'strangp.manentry?surl=' || surl || '&rid=' || replace(rowidtochar(c2rec.rowid),'+','~') || '&scid=' || scid || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id, LNGS.STR_TXT_457 );
     htp.p( '</TD>' );
     htp.p( '<TD VALIGN="TOP">' );
      htp.anchor( 'strangp.manentry_page2?surl=' || surl || '&rid=' || replace(rowidtochar(c2rec.rowid),'+','~') || '&scid=' || scid || '&call_name=' || replace(call_name,' ','+') || '&parm=' || replace(parm,' ','+') || '&access_id=' || access_id, LNGS.STR_TXT_458 );
     htp.p( '</TD>' );
  end if;

  htp.tablerowclose;
 htp.tableclose;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.p( '<TD VALIGN="TOP">' );
    search( surl, 'ME2', nrid, samerow=>TRUE );
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MANENTRY_PAGE3',null,owner_id,errmsg=>sqlerrm);
end manentry_page3;

procedure accept_manentry_page3(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 cursor c2( rid rowid ) is select * from strang.manent2 where rowid = rid;
 cursor c4( entryno number) is select rowidtochar(rowid) from strang.manentry where entry_no = entryno;
 cursor c5( entryno number) is select rowid from strang.manent2 where entry_no = entryno and rno = (select min(rno) from strang.manent2 where entry_no = entryno);
 cursor c6( entryno number) is select max(rno) + 1 from strang.manent2 where entry_no = entryno;
 cursor c7( entryno number, recno integer) is select rowid from strang.manent2 where entry_no = entryno and rno = recno;
 cursor c8( entryno number) is select count('x') tot from strang.manent2 where entry_no = entryno;
 cursor c9( lv varchar2, cd varchar2 ) is select * from strang.lov where lov_name = lv and code = cd;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);
 msg		varchar2(100);
 nmb		integer;
 mx		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_MANENTRY_PAGE3' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'MANENTRY', rid );
 open c2(rid);
 fetch c2 into c2rec;
 close c2;

 if vaccess = 'EDIT'
  then

 -- Validate Number
 if old_entry is null
  then
   manentry( surl, nrid, scid, call_name, parm, access_id, LNGS.STR_TXT_451 || ':' || old_entry );
   return;
 end if;
 if action = LNGS.STR_TXT_452
  then
   delete from strang.manent2 where rowid = chartorowid(rid);
   open c5(c2rec.entry_no);
   fetch c5 into c5rec;
   close c5;
   open c8(c2rec.entry_no);
   fetch c8 into c8rec;
   close c8;
   if c8rec.tot = 0
    then
     insert into strang.manent2(entry_no,rno) values (c2rec.entry_no,1);
     commit;
     open c7(c2rec.entry_no,1);
     fetch c7 into c5rec;
     close c7;
   end if;
   manentry_page3( surl, rowidtochar(c5rec.rowid), scid, call_name, parm, access_id, 'Tariff Manual Entry Deleted' );
   return;
 end if;
 if action <> LNGS.STR_TXT_452
  then
   for j in p1.first..p1.last loop
    begin
     execute immediate
      'update strang.manent2 set ' || p1(j) || ' = :1 where rowid = :2'
        using p2(j), chartorowid(rid);
    exception
     when others then msg := msg || '[Error Modifying ' || initcap(p1(j)) || ' to value: ' || p2(j) || ']';
    end;
   end loop;
 end if;

  -- Refresh the values
 open c2(rid);
 fetch c2 into c2rec;
 close c2;
 open c9( 'TARIFF', c2rec.tariff );
 fetch c9 into c9rec;
 close c9;
 update strang.manent2
  set
   unit = nvl(unit, c9rec.cola ),
   rate = nvl(rate, c9rec.description ),
   oldrate = nvl(oldrate, c9rec.colb ),
   excise_rate = nvl(excise_rate, c9rec.colc)
 where
  rowid = chartorowid(rid);

-- Calculations
 update strang.manent2 m2
  set
   kinavalue = (select ratio_factor * m2.value from strang.manentry where entry_no = old_entry)
 where rowid = chartorowid(rid) and kinavalue is null;
 update strang.manent2 m2
  set
   duty = (select (ratio_factor * m2.value * m2.rate ) / 100 from strang.manentry where entry_no = old_entry)
 where rowid = chartorowid(rid) and duty is null;
 update strang.manent2 m2
  set
   oldduty = (select (ratio_factor * m2.value * m2.oldrate ) / 100 from strang.manentry where entry_no = old_entry)
 where rowid = chartorowid(rid) and oldduty is null;
 update strang.manent2 m2
  set
   excise = (select ( ((ratio_factor * m2.value) + m2.duty) * m2.excise_rate ) / 100 from strang.manentry where entry_no = old_entry)
 where rowid = chartorowid(rid) and excise is null;
 update strang.manent2 m2
  set
   vat = ((nvl(kinavalue,0) + nvl(duty,0) + nvl(excise,0)) * nvl(vat_rate,1)) / 100
 where rowid = chartorowid(rid) and vat is null;
 update strang.manent2 m2
  set
   levy = ((nvl(kinavalue,0) + nvl(duty,0) + nvl(excise,0)) * nvl(levy_rate,1)) / 100
 where rowid = chartorowid(rid) and levy is null;
 commit;

 update strang.manentry m1
  set
    duty = (select sum(nvl(m2.duty,0)) from strang.manent2 m2 where m2.entry_no = c2rec.entry_no ),
    vat = (select sum(nvl(m2.vat,0)) from strang.manent2 m2 where m2.entry_no = c2rec.entry_no ),
    excise = (select sum(nvl(m2.excise,0)) from strang.manent2 m2 where m2.entry_no = c2rec.entry_no ),
    levy = (select sum(nvl(m2.levy,0)) from strang.manent2 m2 where m2.entry_no = c2rec.entry_no )
   where
    entry_no = c2rec.entry_no;

 update strang.manentry m1
  set
    pvariance = (select (m1.duty + m1.excise + m1.vat + nvl(m1.levy,0)) - ((sum(nvl(m2.kinavalue,0)) * 0.015) + sum(nvl(m2.oldduty,0)) ) from strang.manent2 m2 where entry_no = c2rec.entry_no )
   where
    entry_no = c2rec.entry_no;
 commit;

 end if; -- End of Edit Data

 msg := nvl(msg,LNGS.STR_TXT_455);

 if action = 'Update'
  then
   manentry_page3( surl, nrid, scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_456
  then
   open c6(c2rec.entry_no);
   fetch c6 into mx;
   close c6;
   insert into strang.manent2(entry_no,rno) values (c2rec.entry_no,mx);
   open c7(c2rec.entry_no,mx);
   fetch c7 into c7rec;
   close c7;
   commit;
   manentry_page3( surl, rowidtochar(c7rec.rowid), scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_457
  then
   open c4(old_entry);
   fetch c4 into nrid;
   close c4;
   manentry( surl, nrid, scid, call_name, parm, access_id, msg );
 elsif action = LNGS.STR_TXT_458
  then
   open c4(old_entry);
   fetch c4 into nrid;
   close c4;
   manentry_page2( surl, nrid, scid, call_name, parm, access_id, msg );
 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MANENTRY_PAGE3',null,owner_id,errmsg=>sqlerrm);
end accept_manentry_page3;

procedure confirm_manentry_delete(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, access_id in varchar2 default null, msg in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.manentry where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.CONFIRM_MANENTRY_DELETE' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'MANENTRY', rid );
 open c2( nrid );
 fetch c2 into c2rec;
 close c2;

 glbx.main_title( surl, LNGS.STR_TXT_448,glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_manentry_delete' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'SCID', scid );
  htp.formhidden( 'PARM', parm );
  htp.formhidden( 'CALL_NAME', call_name );
  htp.formhidden( 'ACCESS_ID', access_id );
  htp.formhidden( 'RID', nrid );
  htp.formhidden( 'OLD_ENTRY', c2rec.entry_no );
  htp.nl;
  htp.nl;
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_450 );
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_453 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'CONFIRM_MANENTRY_DELETE',null,owner_id,errmsg=>sqlerrm);
end confirm_manentry_delete;

procedure accept_manentry_delete(surl in varchar2, rid in varchar2, scid in varchar2, call_name in varchar2, parm in varchar2, old_entry in varchar2, access_id in varchar2 default null, action in varchar2 )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_MANENTRY' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'MANENTRY', rid );

 if vaccess = 'EDIT'
  then

 if action = LNGS.STR_TXT_450
  then
   manentry( surl, nrid, scid, call_name, parm, access_id, 'Deletion Stopped' );
 else
   delete from strang.manentry where entry_no = old_entry;
   delete from strang.manent1 where entry_no = old_entry;
   delete from strang.manent2 where entry_no = old_entry;
   commit;
   manentry( surl, null, scid, call_name, parm, access_id, 'Manual Entry Record ' || old_entry || ' Deleted' );
 end if;

 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MANENTRY_DELETE',null,owner_id,errmsg=>sqlerrm);
end accept_manentry_delete;

procedure generate_ccdets( surl in varchar2, vShip_id in integer )
as

 cursor c4( vShip_id integer ) is
   select dr.line_no, m.bol, m.container_type,m.movement_no, m.seal, m.tare, dr.deliveryno, dr.itemno, dr.detaildesc, dr.pktpe_packtype,
   dr.qty,dr.partvolume, dr.partweight,dr.ecn, dr.hazard,dr.logno,  c.customer cus4, c4.customer cus2, r.currdate, s.voy, s.shipname
   from strang.detailrs dr, strang.ships_airway s, strang.customers c, strang.customers c4, strang.receivals r, strang.movements m
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    m.movement_type = 'CARGO' and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.deliveryno = dr.deliveryno and
    r.cust_customer_id = c.customer_id and
    r.supplier_customer_id = c4.customer_id
   order by dr.line_no ;

  cursor c5( vShip_id integer ) is
    select dr.line_no, m.bol, m.container_type,m.movement_no, m.seal, m.tare, dr.deliveryno, dr.itemno, dr.detaildesc, dr.pktpe_packtype,
    dr.qty,dr.partvolume, dr.partweight,dr.ecn, dr.hazard,dr.logno,  c.customer cus4, c4.customer cus2, r.currdate, s.voy, s.shipname
    from strang.detailrs dr, strang.ships_airway s, strang.customers c, strang.customers c4, strang.receivals r, strang.movements m
    where
     s.ship_id = vShip_id and
     m.ship_id = s.ship_id and
     m.movement_no = dr.movement_no and
     m.movement_type = 'CONMOV' and
     nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
     r.deliveryno = dr.deliveryno and
     r.cust_customer_id = c.customer_id and
     r.supplier_customer_id = c4.customer_id
    order by dr.line_no ;


  cursor c3(vShipid integer) is select * from strang.ships_airway where ship_id = vShipid;

  c1rec		customer_account%ROWTYPE;
  c3rec		c3%ROWTYPE;
  f 		utl_file.file_type;
  tot		integer;
  gcode		GLBX.MYARRAY;
  gparam	GLBX.MYARRAY;
  vste		varchar2(10);
  eml		varchar2(100);
  ltype		varchar2(100);
  stype		integer;
  owner_id	integer;
  sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENERATE_CCDETS' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 eml := control_code( 'RAWDATA_EMAIL_ADDRESS', vste );
 eml := nvl( eml, glbx.extract_master_parameter('MAIL_FROM') );

 open c3(vShip_id);
 fetch c3 into c3rec;
 close c3;
 f := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'ccdets_' || c3rec.shipname || '_' || c3rec.voy || '.txt', 'w', 32767);

 for c4rec in c4(vShip_id) loop
  utl_file.put_line(f, buffer=>c4rec.line_no || ',"' ||  c4rec.bol || '","' || c4rec.container_type || '","' || c4rec.movement_no || '","' ||  c4rec.seal || '",' ||  c4rec.tare || ',"","","",' ||  c4rec.deliveryno || ',' ||  c4rec.itemno || ',"' ||  substr(c4rec.detaildesc,1,30) || '","'|| substr(c4rec.detaildesc,31,30) || '","'||  c4rec.pktpe_packtype
    || '",' || c4rec.qty || ',' || c4rec.partweight || ',' ||  c4rec.partvolume || ',"' || c4rec.ecn || '","' ||  c4rec.hazard || '","' || c4rec.logno || '","' ||   c4rec.cus2 || '","' ||  c4rec.cus4 || '","' ||  to_char(c4rec.currdate,'DD.MM.YYYY') || '","' ||  c4rec.voy || '","' ||  c4rec.shipname || '"' );

 end loop;

 for c5rec in c5(vShip_id) loop
  utl_file.put_line(f, buffer=>c5rec.line_no || ',"' ||  c5rec.bol || '","","","",'',"","","' || c5rec.movement_no || '",' ||  c5rec.deliveryno || ',' ||  c5rec.itemno || ',"' ||  substr(c5rec.detaildesc,1,30) || '","'|| substr(c5rec.detaildesc,31,30) || '","'||  c5rec.pktpe_packtype
    || '",' || c5rec.qty || ',' || c5rec.partweight || ',' ||  c5rec.partvolume || ',"' || c5rec.ecn || '","' ||  c5rec.hazard || '","' || c5rec.logno || '","' ||   c5rec.cus2 || '","' ||  c5rec.cus4 || '","' ||  to_char(c5rec.currdate,'DD.MM.YYYY') || '","' ||  c5rec.voy || '","' ||  c5rec.shipname || '"' );

 end loop;

 utl_file.fclose( f );

 gcode(1) := 'XXXX'; -- Dummy Parameter
 gparam(1) := 'XXXX';
 glbx.send( gcode, gparam, 'ccdets_' || c3rec.shipname || '_' || c3rec.voy || '.txt', p_to=>eml, p_subj=>'ccdets_' || c3rec.shipname || '_' || c3rec.voy, p_from=>glbx.extract_master_parameter('MAIL_FROM'));

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_CCDETS',null,null,errmsg=>sqlerrm);
end generate_ccdets;

-- 20170607
procedure generate_ccpo( surl in varchar2, vShip_id in integer )
as

 cursor c4( vShip_id integer ) is
   select distinct p.deliveryno, p.recno, p.po, p.po_item_no, p.sap_delno_item qty, p.sap_delno, p.supinv,r.curr,p.tamount, p.delivery_charge, p.inventoryno, nvl(i.description,'NOT ALLOCATED') descn,m.movement_no, m.seal
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.receivals r, strang.movements m, strang.lov i
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.cust_customer_id = 1 and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    nvl(p.inventoryno,'NOT ALLOCATED') = i.code and
    i.lov_name = 'INVENT'
  union
   select distinct p.deliveryno, p.recno, p.po, p.po_item_no, p.sap_delno_item qty, p.sap_delno, p.supinv,r.curr,p.tamount, p.delivery_charge, p.inventoryno, nvl(i.description,'NOT ALLOCATED') descn,m.movement_no, m.seal
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.receivals r, strang.movements m, strang.lov i
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.cust_customer_id = 1 and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    p.inventoryno is not null and
    p.inventoryno not in (select code from strang.lov where lov_name = 'INVENT')
  order by po,po_item_no;

 cursor c5( vShip_id integer ) is
   select count('x') tot
      from
   (
   select distinct p.deliveryno, p.recno, p.po, p.po_item_no, p.sap_delno_item qty, p.sap_delno, p.supinv,r.curr,p.tamount, p.delivery_charge, p.inventoryno, nvl(i.description,'NOT ALLOCATED') descn,m.movement_no, m.seal
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.receivals r, strang.movements m, strang.lov i
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.cust_customer_id = 1 and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    nvl(p.inventoryno,'NOT ALLOCATED') = i.code and
    i.lov_name = 'INVENT'
  union
   select distinct p.deliveryno, p.recno, p.po, p.po_item_no, p.sap_delno_item qty, p.sap_delno, p.supinv,r.curr,p.tamount, p.delivery_charge, p.inventoryno, nvl(i.description,'NOT ALLOCATED') descn,m.movement_no, m.seal
   from strang.detailrs dr, strang.pos p, strang.ships_airway s, strang.receivals r, strang.movements m, strang.lov i
   where
    s.ship_id = vShip_id and
    m.ship_id = s.ship_id and
    m.movement_no = dr.movement_no and
    nvl(m.seal,'|') = nvl(dr.camov_seal,'|') and
    r.cust_customer_id = 1 and
    r.deliveryno = dr.deliveryno and
    r.deliveryno = p.deliveryno and
    p.inventoryno is not null and
    p.inventoryno not in (select code from strang.lov where lov_name = 'INVENT')
  );


  cursor c3(vShipid integer) is select * from strang.ships_airway where ship_id = vShipid;

  c1rec		customer_account%ROWTYPE;
  c3rec		c3%ROWTYPE;
  c5rec		c5%ROWTYPE;
  f 		utl_file.file_type;
  tot		integer;
  gcode		GLBX.MYARRAY;
  gparam	GLBX.MYARRAY;
  vste		varchar2(10);
  eml		varchar2(100);
  ltype		varchar2(100);
  stype		integer;
  owner_id	integer;
  sts		varchar2(100);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.GENERATE_CCPO' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := customer_state(c1rec.aid);
 eml := control_code( 'RAWDATA_EMAIL_ADDRESS', vste );
 eml := nvl( eml, glbx.extract_master_parameter('MAIL_FROM') );

 open c5(vShip_id);
 fetch c5 into tot;
 close c5;
 open c3(vShip_id);
 fetch c3 into c3rec;
 close c3;
 f := utl_file.fopen( glbx.extract_master_parameter('MAIL_TEMPLATE_DIR'), 'POS_' || c3rec.shipname || '_' || c3rec.voy || '.csv', 'w', 32767);
 -- Output Header
 utl_file.put_line(f, buffer=>'H,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot );

 for c4rec in c4(vShip_id) loop
  utl_file.put_line(f, buffer=>'"'||c4rec.po|| '",' || c4rec.po_item_no|| ',' ||  c4rec.qty|| ',"' || c4rec.curr|| '",' || c4rec.tamount|| ',' || c4rec.delivery_charge|| ',' ||  c4rec.sap_delno ||  ',"' ||  c4rec.supinv|| '","' || c4rec.inventoryno|| '","' || c4rec.descn|| '","' || c4rec.movement_no ||'","' || c4rec.seal ||'"' ) ;

 end loop;
 -- Output Footer
 utl_file.put_line(f, buffer=>'F,' || to_char(sysdate,'DD.MM.YYYY') || ',' || tot );
 utl_file.fclose( f );

 gcode(1) := 'XXXX'; -- Dummy Parameter
 gparam(1) := 'XXXX';
 glbx.send( gcode, gparam, 'POS_' || c3rec.shipname || '_' || c3rec.voy || '.csv', p_to=>eml, p_subj=>'POS_' || c3rec.shipname || '_' || c3rec.voy, p_from=>glbx.extract_master_parameter('MAIL_FROM'),is_attachment=>TRUE);

exception when others then
 glbx.error_details( 'STRANGP', 'GENERATE_CCPO',null,null,errmsg=>sqlerrm);
end generate_ccpo;

-- 20170607

-- **************************************************************************************

procedure ctr_menu( surl in varchar2 )
as
 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 seclevel	varchar2(100);
 url		varchar2(1000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.CTR_MENU' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );
  seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Container Menu',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR40',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );

 glbx.header_msg( 'Container Menu' );

 htp.anchor( 'strangp.menu?surl=' || surl || '&rnd=' || to_char(sysdate,'SSSSS') || '&MTYPE=CTR', 'Container Hire' );
 htp.nl;
 htp.nl;
 htp.anchor( 'strangp.menu?surl=' || surl || '&rnd=' || to_char(sysdate,'SSSSS') || '&MTYPE=CTRACK', 'Container Tracking' );
 htp.nl;
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
end ctr_menu;

procedure ctr_track( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null )
as

 cursor c2( vrid rowid ) is select * from strang.tracking_header where rowid = rid;
 cursor c3( sid integer ) is select * from strang.tracking_details where id = sid order by rno;
 cursor c4( sid integer, rnmb integer ) is select * from strang.tracking_details where id = sid and rno = rnmb;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 nxtrec		c4%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 seclevel	varchar2(100);
 url		varchar2(1000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.CTR_TRACK' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'CONTAINERS', rid );
  c1rec := glbx.get_aid( owner_id, 'C', ltype );
  pfx := glbx.get_thm( c1rec.theme_name );
  seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'Container Tracking',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR45',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );
 if id <> 'z' and rid is not null
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
 end if;

 htp.formopen( 'strangp.accept_ctr_track' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'RID', replace(rid,'~','+') );
 htp.formhidden( 'P1', null );
 htp.formhidden( 'P2', null );
 htp.formhidden( 'P3', null );
 htp.formhidden( 'P4', null );

 if rid is null and id <> 'z'
  then
   htp.bold( 'No Container Tracking Record Found' );
   htp.nl;

  else

  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
   htp.tablerowopen;
    htp.tabledata( htf.bold('Container No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT' and id = 'z'
     then
      htp.tabledata( htf.formhidden( 'P1', 'CONTAINERNO' ) || htf.formtext('P2', 40, 100, c2rec.containerno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
      htp.tabledata( htf.bold(c2rec.containerno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Container Type'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
     then
      htp.tabledata( htf.formhidden( 'P1', 'CAT_CODE' ) || htf.formtext('P2', 40, 100, c2rec.cat_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
      htp.tabledata( htf.bold(c2rec.cat_code),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    end if;
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold('Container Owner'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    if vaccess = 'EDIT'
     then
      htp.tabledata( htf.formhidden( 'P1', 'CAT_COMPANY' ) || htf.formtext('P2', 40, 100, c2rec.cat_company),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
     else
      htp.tabledata( htf.bold(c2rec.cat_company),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    end if;
   htp.tablerowclose;

  htp.tableclose;
  htp.nl;
  htp.line;
  htp.nl;
  htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Rno'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Movement<BR>Type'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Ship' || htf.nl || 'Voyage'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Etd' || htf.nl || 'From Loc'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Eta' || htf.nl || 'To Loc'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Current<BR>Location'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Date at<BR>Location'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Remark'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Activity<BR>Status'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;

  for c3rec in c3( c2rec.id ) loop
    htp.tablerowopen;
     htp.tabledata( htf.anchor( 'strangp.ctrdel?surl=' || surl || '&sno=' || c2rec.id || '&rn=' || c3rec.rno,'Delete'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( c3rec.rno, cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'MTYPE' ) || htf.formtext( 'P4', 20, 100, c3rec.movement_type ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'SHIP' ) || htf.formtext( 'P4', 30, 100, c3rec.ship ) || htf.nl ||
                    htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'VOYAGE' ) || htf.formtext( 'P4', 30, 100, c3rec.voyage ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'ETD' ) || htf.formtext( 'P4', 12, 100, to_char(c3rec.etd_date,'DD-MON-YYYY') ) || htf.nl ||
                    htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'FROMLOC' ) || htf.formtext( 'P4', 12, 100, c3rec.departure_location ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'ETA' ) || htf.formtext( 'P4', 12, 100, to_char(c3rec.eta_date,'DD-MON-YYYY') ) || htf.nl ||
                    htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'TOLOC' ) || htf.formtext( 'P4', 12, 100, c3rec.arrival_location ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'CURRLOC' ) || htf.formtext( 'P4', 10, 100, c3rec.current_location ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'DATELOC' ) || htf.formtext( 'P4', 10, 100, to_char(c3rec.date_at_current_loc,'DD-MON-YYYY') ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tabledata( htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'RNO' ) || htf.formhidden( 'P4', c3rec.rno ) ||
                    htf.formhidden( 'P3', '[' || to_char(c3rec.rno) || ']' || 'REMARK' ) || htf.formtext( 'P4', 30, 100, c3rec.remark ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.p( '<TD ' || glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"' || '>' );
      nxtrec := null;
      open c4(c3rec.id, c3rec.rno + 1);
      fetch c4 into nxtrec;
      close c4;
      if nxtrec.rno is null
       then
        htp.bold( to_number(trunc(trunc(sysdate) - c3rec.date_at_current_loc)) );
       else
         htp.bold( to_number(trunc( nvl(nxtrec.etd_date,nxtrec.date_at_current_loc) - c3rec.date_at_current_loc )));
      end if;
     htp.p( '</TD>' );
    htp.tablerowclose;
  end loop;

  if vaccess = 'EDIT'
   then
    for j in 1..3 loop
     htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'MTYPE' ) || htf.formtext( 'P4', 10, 100 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'SHIP' ) || htf.formtext( 'P4', 30, 100 ) || htf.nl ||
                     htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'VOYAGE' ) || htf.formtext( 'P4', 30, 100 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'ETD' ) || htf.formtext( 'P4', 12, 100 ) || htf.nl ||
                     htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'FROMLOC' ) || htf.formtext( 'P4', 12, 100 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'ETA' ) || htf.formtext( 'P4', 12, 100 ) || htf.nl ||
                     htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'TOLOC' ) || htf.formtext( 'P4', 12, 100 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'CURRLOC' ) || htf.formtext( 'P4', 10, 100 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'DATELOC' ) || htf.formtext( 'P4', 10, 100 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( htf.formhidden( 'P3', '[N' || to_char(j) || ']' || 'REMARK' ) || htf.formtext( 'P4', 30, 100 ),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
      htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     htp.tablerowclose;
    end loop;
  end if;
 end if;

 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT' and (id = 'z')
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Insert' ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'EDIT' and id <> 'z' and rid is not null
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Update' ),cattributes=>'VALIGN="TOP"');
   htp.tabledata( htf.formsubmit( 'ACTION', 'Delete' ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'READ' and id <> 'z' AND seclevel in ( 'LEVEL 6','LEVEL 7' )
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Delete' ),cattributes=>'VALIGN="TOP"');
 end if;

 htp.formclose;
 if vaccess = 'EDIT'
  then
   htp.tabledata( htf.formopen( 'strangp.ctr_track' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RID', null ) || htf.formsubmit( null, 'Create New Record' ) || htf.formclose,cattributes=>'VALIGN="TOP"');
 end if;
 htp.tablerowclose;
 htp.tableclose;
 htp.formclose;

 htp.nl;
 htp.nl;
 search( surl, 'CTRACK', rid );
 htp.nl;

 if msg is not null
  then
   glbx.header_msg( msg );
 end if;

 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'CTR_TRACK',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end ctr_track;

procedure ctrdel( surl in varchar2, sno in varchar2, rn in varchar2 )
as

 cursor c1(sno integer) is select rowid from strang.tracking_header where id = sno;
 cursor c2(sno integer) is select rowid from strang.tracking_details where id = sno order by rno;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb		integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 seclevel	varchar2(100);
begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CTRDEL' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
 delete from strang.tracking_details where id = sno and rno = rn;
 nmb := 0;
 for c2rec in c2(sno) loop
  nmb := nmb + 1;
  update strang.tracking_details set rno = nmb where rowid = c2rec.rowid;
 end loop;
 commit;
 open c1(sno);
 fetch c1 into c1rec;
 close c1;
 ctr_track(surl,c1rec.rowid,'x','Container Tracking Record Deleted' );
end ctrdel;

procedure accept_ctr_track( surl in varchar2, rid in varchar2, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, action in varchar2 )
as

 cursor c1(rid rowid) is select id from strang.tracking_header where rowid = rid;

 cusrec		customer_account%ROWTYPE;
 cnrec		strang.tracking_header%ROWTYPE;
 cdrec		strang.tracking_details%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 nmb1		integer;
 nmb2		integer;
 sts		varchar2(100);
 newrid		rowid;
 vste		varchar2(10);
 sno		integer;
 ctr		integer;

 function getval( cd in varchar2, v1 in glbx.myarray, v2 in glbx.myarray )
  return varchar2
 as
 begin
  for j in v1.first..v1.last loop
   if v1(j) = cd then return( v2(j) ); end if;
  end loop;
  return( null );
 end getval;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'ACCEPT_CTR_TRACK' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;

  cusrec := glbx.get_aid( owner_id, 'C', ltype );
  vste := customer_state(cusrec.aid);

  if action = 'Delete'
   then
    delete from strang.tracking_details where id in (select id from strang.tracking_header where rowid = chartorowid(replace(rid,'~','+')));
    delete from strang.tracking_header where rowid = chartorowid(replace(rid,'~','+'));
    search( surl, 'CTRACK', null );
    return;
  end if;

  if action = 'Insert'
   then
    cnrec.containerno := getval( 'CONTAINERNO', p1, p2 );
    cnrec.cat_code := getval( 'CAT_CODE', p1, p2 );
    cnrec.cat_company := getval( 'CAT_COMPANY', p1, p2 );
    if cnrec.containerno is null or
       cnrec.cat_code is null or
       cnrec.cat_company is null
     then
      ctr_track(surl,rid,'z','You must specify a value for Container, Type and Owner' );
      return;
    end if;
    select strang.s_tracking_header.nextval into sno from dual;
    insert into strang.tracking_header(id,containerno,cat_code,cat_company) values
     (sno,cnrec.containerno,cnrec.cat_code,cnrec.cat_company)
    returning rowid into newrid;
  end if;

  if action = 'Update'
   then
    open c1( chartorowid(replace(rid,'~','+')) );
    fetch c1 into sno;
    close c1;
    --cnrec.containerno := getval( 'CONTAINERNO', p1, p2 );
    cnrec.cat_code := getval( 'CAT_CODE', p1, p2 );
    cnrec.cat_company := getval( 'CAT_COMPANY', p1, p2 );
    update strang.tracking_header
     set
      cat_code = cnrec.cat_code,
      cat_company = cnrec.cat_company
     where
      id = sno;
  end if;

  -- Add tracking body
  ctr := 0;
  if action = 'Update'
   then
    loop
     cdrec := null;
     ctr := ctr + 1;
     cdrec.rno := getval( '[' || ctr || ']' || 'RNO', p3, p4 );
     if cdrec.rno is null then exit; end if;
     cdrec.remark := getval( '[' || ctr || ']' || 'REMARK', p3, p4 );
     cdrec.movement_type := getval( '[' || ctr || ']' || 'MTYPE', p3, p4 );
     cdrec.departure_location := getval( '[' || ctr || ']' || 'FROMLOC', p3, p4 );
     cdrec.etd_date := to_date(getval( '[' || ctr || ']' || 'ETD', p3, p4 ),'DD-MON-YYYY');
     cdrec.arrival_location := getval( '[' || ctr || ']' || 'TOLOC', p3, p4 );
     cdrec.eta_date := to_date(getval( '[' || ctr || ']' || 'ETA', p3, p4 ),'DD-MON-YYYY');
     cdrec.ship := getval( '[' || ctr || ']' || 'SHIP', p3, p4 );
     cdrec.voyage := getval( '[' || ctr || ']' || 'VOYAGE', p3, p4 );
     cdrec.current_location := getval( '[' || ctr || ']' || 'CURRLOC', p3, p4 );
     cdrec.date_at_current_loc := to_date(getval( '[' || ctr || ']' || 'DATELOC', p3, p4 ),'DD-MON-YYYY');
     update strang.tracking_details
      set
       remark = cdrec.remark,
       movement_type = cdrec.movement_type,
       departure_location = cdrec.departure_location,
       etd_date = cdrec.etd_date,
       arrival_location = cdrec.arrival_location,
       eta_date = cdrec.eta_date,
       ship = cdrec.ship,
       voyage = cdrec.voyage,
       current_location = cdrec.current_location,
       date_at_current_loc = cdrec.date_at_current_loc
     where
      id = sno and
      rno = ctr;
    end loop;
  end if;

  ctr := 0;
  if action in ('Insert','Update')
   then
    for j in 1..3 loop
     cdrec := null;
     select nvl(max(rno),0) + 1 nmb into cdrec.rno from strang.tracking_details where id = sno;
     cdrec.remark := getval( '[N' || j || ']' || 'REMARK', p3, p4 );
     cdrec.movement_type := getval( '[N' || j || ']' || 'MTYPE', p3, p4 );
     cdrec.departure_location := getval( '[N' || j || ']' || 'FROMLOC', p3, p4 );
     begin cdrec.etd_date := to_date(getval( '[N' || j || ']' || 'ETD', p3, p4 ),'DD-MON-YYYY'); exception when others then cdrec.etd_date := null; end;
     cdrec.arrival_location := getval( '[N' || j || ']' || 'TOLOC', p3, p4 );
     begin cdrec.eta_date := to_date(getval( '[N' || j || ']' || 'ETA', p3, p4 ),'DD-MON-YYYY'); exception when others then cdrec.eta_date := null; end;
     cdrec.ship := getval( '[N' || j || ']' || 'SHIP', p3, p4 );
     cdrec.voyage := getval( '[N' || j || ']' || 'VOYAGE', p3, p4 );
     cdrec.current_location := getval( '[N' || j || ']' || 'CURRLOC', p3, p4 );

     begin cdrec.date_at_current_loc := to_date(getval( '[N' || j || ']' || 'DATELOC', p3, p4 ),'DD-MON-YYYY'); exception when others then cdrec.date_at_current_loc := null; end;

     cdrec.current_location := nvl(cdrec.current_location,cdrec.arrival_location);
     cdrec.date_at_current_loc := nvl(cdrec.date_at_current_loc,cdrec.eta_date);

     if cdrec.movement_type is null or
        cdrec.date_at_current_loc is null
      then
       null;
      else
       insert into strang.tracking_details(id,rno,remark,movement_type,departure_location,etd_date,arrival_location,eta_date,ship,voyage,current_location,date_at_current_loc)
        values(sno,cdrec.rno,cdrec.remark,cdrec.movement_type,cdrec.departure_location,cdrec.etd_date,cdrec.arrival_location,cdrec.eta_date,cdrec.ship,cdrec.voyage,cdrec.current_location,cdrec.date_at_current_loc);
     end if;
    end loop;
  end if;

  commit;

  if action = 'Update'
   then
    ctr_track( surl, rid, 'x', 'Record Modified' );
  elsif action = 'Insert'
   then
    ctr_track( surl, newrid, 'x', 'Record Inserted' );
  end if;
exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_CTR_TRACK',null,owner_id,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end accept_ctr_track;

procedure mng_ctr( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null )
as

 cursor c2( rid rowid ) is select * from strang.containers where rowid = rid;
 cursor c3 is select * from strang.onlocs order by loc_location;
 cursor c4( ccomp varchar2, cct varchar2,ccode varchar2) is select * from strang.onlocs
 where
 cat_company = ccomp and
 cat_contract = cct and
 cat_code = ccode
 order by cat_contract, cat_company;
 cursor c5 is select * from strang.offlocs order by loc_location;
 cursor c6( ccomp varchar2, cct varchar2,ccode varchar2) is select * from strang.offlocs
 where
 cat_company = ccomp and
 cat_contract = cct and
 cat_code = ccode
 order by cat_contract, cat_company;
 cursor c7 is select * from strang.categories order by contract;
 cursor c7a(ck varchar2, cd varchar2, cm varchar2) is select rno from strang.categories where contract = ck and codedesc = cd and company = cm;
 cursor c8 is select * from strang.lov where lov_name = 'UNCTNTAB' order by code;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c7arec		c7a%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 seclevel	varchar2(100);
 url		varchar2(1000);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.MNG_CTR' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'CONTAINERS', rid );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 seclevel := oltp.security_role( owner_id );

 glbx.main_title( surl, 'CONTAINER HIRE MAINTENANCE',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );
 if id <> 'z' and rid is not null
  then
   open c2(replace(rid,'~','+'));
   fetch c2 into c2rec;
   close c2;
 end if;
 --GLBX.DBG( 'X1:' || VACCESS );
 --GLBX.DBG( C2REC.OFFDATE);
 --GLBX.DBG( C2REC.FLOC_LOCATION);
 if vaccess = 'EDIT'  and (c2rec.offdate is not null) and (c2rec.floc_location is not null) then
    vaccess := 'READ';
 end if;

 htp.formopen( 'strangp.accept_mng_ctr', ctarget=>'_top' );
 htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'ID', id );

if vaccess = 'READ' then
   htp.formhidden( 'P1', null );
   htp.formhidden( 'P2', null );
   htp.formhidden( 'P3', null );
   htp.formhidden( 'P4', null );
   htp.formhidden( 'P5', null );
   htp.formhidden( 'P6', null );
   htp.formhidden( 'P7', null );
   htp.formhidden( 'P8', null );
   htp.formhidden( 'P9', null );
   htp.formhidden( 'P10', null );
   htp.formhidden( 'P11', null );
   htp.formhidden( 'P12', null );
end if;


 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Container No'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT' and id = 'z'
    then
     htp.tabledata( htf.formtext('P1', 15, 15, c2rec.containerno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.formhidden( 'P1', c2rec.containerno ) || htf.bold(c2rec.containerno),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   htp.tabledata( htf.bold('Company Name'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold(nvl(c2rec.cat_company,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
  htp.tablerowclose;
     if vaccess = 'EDIT' and id = 'z'
      then
       htp.tablerowopen;
       htp.tabledata( htf.bold('Details'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
        htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"  COLSPAN="5">' );
          htp.formselectopen( 'P2' );
              for c7rec in c7  loop
                if c7rec.contract=c2rec.cat_contract then
                  htp.formselectoption( ' --- '|| c7rec.contract || ' --- '|| c7rec.codedesc || ' --- '|| c7rec.company, 'SELECTED', cattributes=>'VALUE="'||c7rec.rno ||'"');
                else
                  htp.formselectoption( ' --- '|| c7rec.contract || ' --- '|| c7rec.codedesc || ' --- '|| c7rec.company, cattributes=>'VALUE="'||c7rec.rno ||'"');
               end if;
              end loop;
          htp.formselectclose;
        htp.p( '</TD>');
       htp.tablerowclose;
     elsif vaccess = 'EDIT'
      then
       open c7a(c2rec.cat_contract, c2rec.cat_code, c2rec.cat_company);
       fetch c7a into c7arec;
       close c7a;
       htp.formhidden('P2', c7arec.rno );
      else
       htp.tablerowopen;
        htp.tabledata( htf.bold('Details'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
        htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="5"');
       htp.tablerowclose;
     end if;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Contract'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold(nvl(c2rec.cat_contract,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');


   htp.tabledata( htf.bold('ISO Container Type'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');

     if vaccess = 'EDIT'
      then
        htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3">' );
          htp.formselectopen( 'P3' );
              for c8rec in c8 loop
                if c8rec.code=c2rec.ctpe_ctrtype
                 then
                  htp.formselectoption( c8rec.code, 'SELECTED', cattributes=>'VALUE="'|| c8rec.code || '"');
                else
                  htp.formselectoption( c8rec.code, cattributes=>'VALUE="' ||c8rec.code || '"');
               end if;
              end loop;

          htp.formselectclose;
        htp.p( '</TD>');
      else
       htp.tabledata( htf.bold(nvl(c2rec.ctpe_ctrtype,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3"');
     end if;
  htp.tablerowclose;


  htp.tablerowopen;
   htp.tabledata( htf.bold('Category Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold(nvl(c2rec.cat_code,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P4', 30, 30, c2rec.ctrdesc),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
    else
     htp.tabledata( htf.bold(nvl(c2rec.ctrdesc,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" colspan="2"');
   htp.tabledata( htf.bold('Backcharge'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');

   if vaccess = 'EDIT'
    then
      htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"  >' );
        htp.formselectopen( 'P5' );
        if c2rec.backcharge='NO' then
           htp.formselectoption('NO', 'SELECTED');
        else
           htp.formselectoption('NO');
        end if;
        if c2rec.backcharge='YES' then
           htp.formselectoption('YES', 'SELECTED');
        else
           htp.formselectoption('YES');
        end if;
        htp.formselectclose;
        htp.p( '</TD>');
    else
     htp.tabledata( htf.bold(nvl(c2rec.backcharge,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;

 htp.tabledata( htf.bold('Times Hired'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold(nvl(to_char(c2rec.timeshired),'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  htp.tablerowclose;
  htp.tablerowopen;
  htp.tabledata(htf.line(cattributes=>'width=50% size=4'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' colspan="6" ALIGN="CENTER" style="text-align: center;"');
  htp.tablerowclose;

  if vaccess = 'EDIT' and id = 'z'
   then
    htp.formhidden( 'P6', NULL );
    htp.formhidden( 'P7', NULL );
    htp.formhidden( 'P8', NULL );
    htp.formhidden( 'P9', NULL );
    htp.formhidden( 'P10', NULL );
    htp.formhidden( 'P11', NULL );
    htp.formhidden( 'P12', NULL );
   else

  htp.tablerowopen;
  htp.tabledata(htf.bold('Onhire Information'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' colspan="3" ALIGN="CENTER" style="text-align: center;"');
  htp.tabledata(htf.bold('Offhire Information'),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' colspan="3" ALIGN="CENTER" style="text-align: center;"');
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Date Hired'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P6', 15, 15, to_char(c2rec.datehired, 'dd-MON-yyyy')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(nvl(to_char(c2rec.datehired, 'dd-MON-yyyy'),'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
   htp.tabledata( htf.bold('Off Hire Date'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT' and (id <> 'z')
    then
     htp.tabledata( htf.formtext('P7', 15, 15, to_char(c2rec.offdate, 'dd-MON-yyyy')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
    else
     htp.tabledata( htf.bold(nvl(to_char(c2rec.offdate,'dd-MON-yyyy'),'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
   end if;
  htp.tablerowclose;

if vaccess = 'EDIT' then
htp.tablerowopen;
   htp.tabledata( htf.bold('On Hire Details'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
      htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
        htp.formselectopen( 'P8' );
          if id = 'z' then
            for c3rec in c3 loop
              htp.formselectoption( c3rec.loc_location || ' '|| c3rec.cat_company || ' '|| c3rec.cat_contract || ' '|| c3rec.cat_code , cattributes=>'VALUE="'|| C3rec.loc_location || '"');
            end loop;
          else
          --glbx.dbg( 'X2:c2rec.cat_company '|| c2rec.cat_company );
         --glbx.dbg( 'X2:c2rec.cat_contract '|| c2rec.cat_contract );
         --glbx.dbg( 'X2:c2rec.cat_code '|| c2rec.cat_code );
         --glbx.dbg( 'X2:c2rec.cat_cdate '|| c2rec.cat_cdate );
           htp.formselectoption( NULL );
            for c4rec in c4( c2rec.cat_company,c2rec.cat_contract,c2rec.cat_code) loop
              if c4rec.loc_location=c2rec.nloc_location then
                htp.formselectoption( c4rec.loc_location, 'SELECTED', cattributes=>'VALUE="'|| c4rec.loc_location || '"');
              else
                htp.formselectoption( c4rec.loc_location , cattributes=>'VALUE="'|| c4rec.loc_location || '"');
             end if;
            end loop;
          end if;

        htp.formselectclose;
      htp.p( '</TD>');
    else
     htp.tabledata( htf.bold(nvl(c2rec.nloc_location,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;

   htp.tabledata( htf.bold('Off Hire Details'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT' and (id <> 'z')
    then
      htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"  COLSPAN="3" >' );
        htp.formselectopen( 'P9' );
        htp.formselectoption( null );
          if id = 'z' then
            for c5rec in c5 loop
              htp.formselectoption( c5rec.loc_location || ' '||  c5rec.cat_company || ' '|| c5rec.cat_contract || ' '|| c5rec.cat_code , cattributes=>'VALUE="'|| c5rec.loc_location || '"');
            end loop;
          else
            for c6rec in c6( c2rec.cat_company,c2rec.cat_contract,c2rec.cat_code)

            loop
              if c6rec.loc_location=c2rec.floc_location then
                htp.formselectoption( c6rec.loc_location, 'SELECTED', cattributes=>'VALUE="'|| c6rec.loc_location || '"');
              else
                htp.formselectoption( c6rec.loc_location, cattributes=>'VALUE="'|| c6rec.loc_location || '"');
             end if;
            end loop;
          end if;

        htp.formselectclose;
      htp.p( '</TD>');
    else
     htp.tabledata( htf.bold(nvl(c2rec.floc_location,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');

   end if;
   htp.tablerowclose;
 end if;

if vaccess = 'EDIT'
 then
  null;
 else
htp.tablerowopen;
    htp.tabledata( htf.bold('On Hire Location'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold(nvl(c2rec.nloc_location,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold('Off Hire Location'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
    htp.tabledata( htf.bold(nvl(c2rec.floc_location,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
  htp.tablerowclose;
end if;
  --htp.tablerowopen;
  --  htp.tabledata( htf.bold('On Hire Validation Date'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  --  htp.tabledata( htf.bold(nvl(to_char(c2rec.nloc_cdate,'DD-MON-YYYY'),'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
  --  htp.tabledata( htf.bold('Off Hire Validation Date'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
  --  htp.tabledata( htf.bold(nvl(to_char(c2rec.floc_cdate,'DD-MON-YYYY'),'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
  --htp.tablerowclose;

  htp.tablerowopen;
  htp.tabledata( htf.bold('Release'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"  VALIGN="TOP" ');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P10', 15, 15, c2rec.crelease),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" VALIGN="TOP" ');
    else
     htp.tabledata( htf.bold(nvl(c2rec.crelease,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" VALIGN="TOP" ');
   end if;
  htp.tabledata( htf.bold('Turn In'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P11', 15, 15, c2rec.turnin),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
    else
     htp.tabledata( htf.bold(nvl(c2rec.turnin,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
  htp.tabledata( '&nbsp;',cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT" COLSPAN="2" ');
  htp.tabledata( htf.bold('EIR'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P12', 15, 15, c2rec.eir),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
    else
     htp.tabledata( htf.bold(nvl(c2rec.eir,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="3" ');
   end if;
  htp.tablerowclose;

 end if;


 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT' and (id = 'z' or rid is null)
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Insert' ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Update' ),cattributes=>'VALIGN="TOP"');
   htp.tabledata( htf.formsubmit( 'ACTION', 'Delete' ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'READ' and id <> 'z' AND seclevel in ( 'LEVEL 6','LEVEL 7' )
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Delete' ),cattributes=>'VALIGN="TOP"');
 end if;

 htp.formclose;
 if id <> 'z' -- vaccess = 'EDIT' and
  then
   htp.tabledata( htf.formopen( 'strangp.mng_ctr' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RID', null ) || htf.formsubmit( null, 'Create New Record' ) || htf.formclose,cattributes=>'VALIGN="TOP"');
 end if;
 htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.nl;
 if seclevel in ( 'LEVEL 1','LEVEL 8' )
  then
   null;
  else
   htp.anchor2( 'strangp.menu?surl=' || surl || '&mtype=CATEG&action=SEARCH&rid=&rnd=&msearch=', 'Categories', ctarget=>'POPUP');
   htp.p ('&nbsp;');
   htp.anchor2( 'strangp.menu?surl=' || surl || '&mtype=ONLOCS&action=SEARCH&rid=&rnd=&msearch=', 'Onhire Details', ctarget=>'POPUP');
   htp.p ('&nbsp;');
   htp.anchor2( 'strangp.menu?surl=' || surl || '&mtype=OFFLOCS&action=SEARCH&rid=&rnd=&msearch=', 'Offhire Details', ctarget=>'POPUP');
   htp.p ('&nbsp;');
   url := 'oltp.display_screen?surl=' || surl || '&sname=Container+Type&access_in=QUERY&rid=&rnd=';
   htp.anchor( 'javascript: window.open(''' || url || ''',''' || 'POPUP1' ||
               ''',''height=' || '400' ||
               ',width=' || '600' || ',scrollbars=yes,resizable=yes'');void('''');',
               'Container Types' );
   htp.p ('&nbsp;');

    url := 'oltp.display_screen?surl=' || surl || '&sname=Locations&access_in=QUERY&rid=&rnd=';
    htp.anchor( 'javascript: window.open(''' || url || ''',''' || 'POPUP2' ||
                ''',''height=' || '400' ||
               ',width=' || '600' || ',scrollbars=yes,resizable=yes'');void('''');',
                'Locations' );

   htp.p ('&nbsp;');

    url := 'oltp.display_screen?surl=' || surl || '&sname=Countries&access_in=QUERY&rid=&rnd=';
    htp.anchor( 'javascript: window.open(''' || url || ''',''' || 'POPUP3' ||
                ''',''height=' || '400' ||
                ',width=' || '600' || ',scrollbars=yes,resizable=yes'');void('''');',
                'Currencies' );

 end if;
 htp.nl;
 htp.nl;
 search( surl, 'CTR', rid );
 htp.nl;
 --if call_name is null then htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl; end if;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MNG_CTR',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end mng_ctr;

-- **********************************************************

procedure accept_mng_ctr( SURL IN VARCHAR2, RID IN VARCHAR2, ID in VARCHAR2, P1 IN VARCHAR2, P2 IN VARCHAR2, P3 IN VARCHAR2, P4 IN VARCHAR2, P5 IN VARCHAR2,
P6 IN VARCHAR2, P7 IN VARCHAR2 default null, P8 IN VARCHAR2, P9 IN VARCHAR2 default null, P10 IN VARCHAR2, P11 IN VARCHAR2, P12 IN VARCHAR2, ACTION IN VARCHAR2 )
as
cursor c1 ( cno varchar2 ) is select max(timeshired) mx from strang.containers where containerno = cno;
cursor c2 ( cno varchar2 , th number ) is select * from strang.containers where containerno = cno and timeshired = th;
cursor c3 ( rn number ) is select * from strang.categories where rno = rn ;
cursor c5 ( ct varchar2, ccode varchar2, ccomp varchar2, loc varchar2 ) is select * from strang.onlocs
  where
  cat_company = ccomp and
  cat_contract = ct and
  cat_code = ccode and
  loc_location = loc;
cursor c6 ( ct varchar2, ccode varchar2, ccomp varchar2, loc varchar2 ) is select * from strang.offlocs
  where
  cat_company = ccomp and
  cat_contract = ct and
  cat_code = ccode and
  loc_location = loc;
cursor c7 (rid rowid) is select * from strang.containers where rowid=rid;
cursor c8 (ctr varchar2) is select * from strang.containers where containerno = ctr and offdate is null;

c1rec c1%ROWTYPE;
c2rec c2%ROWTYPE;
c3rec c3%ROWTYPE;
c5rec c5%ROWTYPE;
c6rec c6%ROWTYPE;
c7rec c7%ROWTYPE;
c8rec c8%ROWTYPE;

dt1 date;
dt2 date;
oloc varchar2(4);
ovdt date;
floc varchar2(4);
fvdt date;
errmsg varchar2(1000);
newrid rowid;
fnd	boolean;
fndo	boolean;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 seclevel	varchar2(100);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_MNG_CTR' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'CONTAINERS', rid );
 seclevel := oltp.security_role( owner_id );



IF VACCESS = 'READ' THEN
  mng_ctr( surl, rid, 'x', 'CANNOT MODIFY' );

END IF;
if action = 'Delete' then
  confirm_ctr_delete( surl,rid );
  return;
end if;
/*
glbx.dbg('P1:' ||P1);
glbx.dbg('P2:' ||P2);
glbx.dbg('P3:' ||P3);
glbx.dbg('P4:' ||P4);
glbx.dbg('P5:' ||P5);
glbx.dbg('P6:' ||P6);
glbx.dbg('P7:' ||P7);
glbx.dbg('P8:' ||P8);
glbx.dbg('P9:' ||P9);
glbx.dbg('P10:' ||P10);
glbx.dbg('P11:' ||P11);
glbx.dbg('P12:' ||P12);
*/
if P1 is null then
  mng_ctr( surl, rid, ID, 'Must Enter A Container No' );
  return;
end if;
oloc := p8; --substr(P8,2,instr(P8,']')-2);
--ovdt:=substr(p8,instr(P8,']')+1);
floc := p9; --substr(P9,2,instr(P9,']')-2);
--fvdt:=substr(p9,instr(P9,']')+1);
begin
 if P6 is null and action <> 'Insert' then
  mng_ctr( surl, rid, ID, 'On hire Date cannot be blank' );
  return;
 end if;

 dt1:=to_date(P6,'DD-MON-YYYY');
 exception when others then
  mng_ctr( surl, rid, ID, 'Invalid On hire date ' || P6 );
  return;
end;
begin
 dt2:=to_date(P7,'DD-MON-YYYY');
 exception when others then
 errmsg := 'Invalid Off hire date ' || P7 ;
 dt2:= null;
end;

if action='Insert' then
  open c1( upper(P1) );
    fetch c1 into c1rec;
    c1rec.mx := nvl(c1rec.mx,0);
    if c1rec.mx = 0 then
      close c1;
      c1rec.mx:= 1;
    else
      close c1;
      open c2( P1 , c1rec.mx );
        fetch c2 into c2rec;
      close c2;
      if c2rec.offdate is null then
        mng_ctr( surl, rid, 'z', 'Container ' || P1 ||' Already On Hire' );
        return;
      end if;
      c1rec.mx:= c1rec.mx + 1;
    end if;
    open c3 ( P2 );
    fetch c3 into c3rec;
    close c3;

    open c5 ( c3rec.contract, c3rec.codedesc, c3rec.company, oloc);
    fetch c5 into c5rec;
    close c5;

    open c6 ( c3rec.contract, c3rec.codedesc, c3rec.company, floc);
    fetch c6 into c6rec;
    close c6;
--glbx.dbg( 'c1:' || c5rec.cat_contract || '-' || c3rec.contract );
--glbx.dbg( 'c1:' || c5rec.cat_code || '-' || c3rec.codedesc );
--glbx.dbg( 'c1:' || c5rec.cat_company || '-' || c3rec.company );
--glbx.dbg( 'c1:' || c5rec.cat_cdate || '-' || c3rec.cdate );

    if c5rec.cat_contract is null
      then
       oloc := 'XXXX';
       --ovdt := sysdate;
       if floc is not null then
         floc := 'XXXX';
       end if;
    end if;

    insert into strang.containers ( containerno,timeshired,datehired,backcharge,cat_code,
                                    ctrdesc,cat_company,cat_contract,ctpe_ctrtype,
                                    nloc_location,crelease,turnin,eir,
                                    offdate,floc_location ) values
                ( upper(P1),c1rec.mx,dt1,P5,c3rec.codedesc,
                  P4,c3rec.company,c3rec.contract,P3,
                  oloc,P10,P11,P12,
                  dt2,floc ) returning rowid into newrid;
     commit;
     mng_ctr( surl, newrid, 'x', nvl(errmsg,'Insert Successful'));
     return;
end if;

fnd := false;
fndo := false;
if action='Update' then
  open c7(rid);
  fetch c7 into c7rec;
  close c7;
  if (c7rec.datehired is null or
      c7rec.datehired <> dt1)
     or
     (c7rec.nloc_location is null or
      c7rec.nloc_location <> oloc)
   then
    fnd := TRUE;
  end if;

  c7rec.datehired := dt1;
  c7rec.offdate := dt2;
  c7rec.ctpe_ctrtype := P3;
  c7rec.ctrdesc := P4;
  c7rec.backcharge := P5;
  c7rec.crelease := P10;
  c7rec.turnin := P11;
  c7rec.eir := P12;
  if ((c7rec.offdate is null and dt2 is not null) or
      c7rec.offdate <> dt2)
     or
     ((c7rec.floc_location is null and floc is not null) or
      c7rec.floc_location <> floc)
   then
    fndo := TRUE;
  end if;
  c7rec.floc_location := floc;
  if c7rec.containerno <> upper(P1) then
    open c8( upper(P1) );
    fetch c8 into c8rec;
    if c8%FOUND then
      mng_ctr( surl, rid, 'x', 'Container ' || P1 ||' Already On Hire' );
      return;
    end if;
    c1rec.mx:= 0;
    open c1( P1 );
     fetch c1 into c1rec;
    close c1;
    c7rec.timeshired := nvl(c1rec.mx,0) + 1;
    c7rec.containerno := upper(P1);
  end if;
  open c3(P2);
  fetch c3 into c3rec;
  close c3;

  if (c7rec.nloc_location='XXXX') or (c7rec.nloc_location <> oloc) or (c7rec.nloc_location is null) then
-- glbx.dbg( 'P2:'||c7rec.cat_contract);
-- glbx.dbg( 'P2:'||c3rec.codedesc);
-- glbx.dbg( 'P2:'||c3rec.company);
-- glbx.dbg( 'P2:'||oloc);
-- glbx.dbg( 'P2:'||ovdt);
-- glbx.dbg( 'PX:'||p2);
-- glbx.dbg( 'PN:'||c7rec.nloc_location);
    open c5 ( c7rec.cat_contract, c3rec.codedesc, c3rec.company, oloc);
    fetch c5 into c5rec;
    close c5;
    c7rec.nloc_location := c5rec.loc_location;
    --c7rec.nloc_cdate := c5rec.cdate;
  end if;
  if (c7rec.floc_location='XXXX') or  (c7rec.floc_location <> floc) or (c7rec.floc_location is null) then
    open c6 ( P2, c3rec.codedesc, c3rec.company , floc);
    fetch c6 into c6rec;
    close c6;
    c7rec.floc_location := c6rec.loc_location;
    --c7rec.floc_cdate := c6rec.cdate;
  end if;

  if not (c7rec.cat_contract = c3rec.contract and
     c7rec.cat_code=c3rec.codedesc and
     c7rec.cat_company=c3rec.company)
    then
     c7rec.nloc_location := 'XXXX';
     --c7rec.nloc_cdate := sysdate;
     if c7rec.floc_location is not null then
       c7rec.floc_location := 'XXXX';
     end if;
     --if c7rec.floc_location is not null then
     --  c7rec.floc_cdate := sysdate;
     --end if;
     c7rec.cat_contract := c3rec.contract;
     c7rec.cat_company := c3rec.company;
     c7rec.cat_code := c3rec.codedesc;
  end if;

--  glbx.dbg(c7rec.datehired);
  update strang.containers set
   containerno = c7rec.containerno,
   timeshired = c7rec.timeshired,
   datehired = nvl(c7rec.datehired,datehired),
   backcharge = c7rec.backcharge,
   cat_code = c7rec.cat_code,
   ctrdesc = c7rec.ctrdesc,
   cat_company = c7rec.cat_company,
   cat_contract = c7rec.cat_contract,
   ctpe_ctrtype = c7rec.ctpe_ctrtype,
   nloc_location = c7rec.nloc_location,
   crelease = c7rec.crelease,
   turnin = c7rec.turnin,
   eir = c7rec.eir,
   offdate = c7rec.offdate,
   floc_location = c7rec.floc_location
  where rowid = rid;

  if fnd then
   generate_containers_onhire( c7rec );
  end if;

  if fndo then
   generate_containers_offhire( c7rec );
  end if;

end if;
commit;
mng_ctr( surl, nvl(newrid,rid), id, nvl(errmsg,'Update Successful'));

exception when others then
glbx.error_details( 'STRANGP', 'ACCEPT_MNG_CTR',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);

end accept_mng_ctr;

-- **************************************************************************************

procedure confirm_ctr_delete(surl in varchar2, rid in varchar2)
as

 cursor c2( rid rowid ) is select * from strang.containers where rowid = rid;

 c1rec		customer_account%ROWTYPE;
 c2rec		c2%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.CONFIRM_CTR_DELETE' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'CONTAINERS', rid );
 open c2( nrid );
 fetch c2 into c2rec;
 close c2;

 glbx.main_title( surl, 'Confirm Container Deletion',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR17',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );
 htp.bold( c2rec.containerno );
 htp.formopen( 'strangp.accept_ctr_delete' );
  htp.formhidden( 'SURL', surl );
  htp.formhidden( 'RID', nrid );
  htp.nl;
  htp.nl;

  htp.formsubmit( 'ACTION', LNGS.STR_TXT_450 );
  htp.formsubmit( 'ACTION', LNGS.STR_TXT_453 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'STRANGP', 'CONFIRM_MCTR_DELETE',null,owner_id,errmsg=>sqlerrm);
end confirm_ctr_delete;

procedure accept_ctr_delete(surl in varchar2, rid in varchar2, action in varchar2 )
as

 c1rec		customer_account%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 nrid		varchar2(100);
 vaccess	varchar2(20);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'STRANGP.ACCEPT_CTR' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );
 nrid := replace(rid,'~','+');
 vaccess := data_access( owner_id, 'CONTAINERS', rid );

 if vaccess = 'EDIT'
  then

 if action = LNGS.STR_TXT_450
  then
  mng_ctr( surl, rid, 'x', 'Deletion Cancelled' );
  return;
 else
   delete from strang.containers where rowid = nrid;
   commit;
   strangp.menu(surl=>surl,rnd=>null,MTYPE=>'CTR');
 end if;

 end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_CTR_DELETE',null,owner_id,errmsg=>sqlerrm);
end accept_ctr_delete;

--******************************************************************************************
procedure mng_categories( surl in varchar2, rid in varchar2 default null, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null )
as

 cursor c3( rid rowid ) is select * from strang.categories where rowid = rid;
 cursor c4( cont varchar2, comp varchar2, ccde varchar2 ) is select count('x') cnt from strang.onlocs
 where cat_contract = cont and
       cat_company  = comp and
       cat_code     = ccde;
 cursor c5( cont varchar2, comp varchar2, ccde varchar2 ) is select count('x') cnt from strang.offlocs
 where cat_contract = cont and
       cat_company  = comp and
       cat_code     = ccde;

 cursor c8 is select distinct cola from strang.lov where lov_name = 'COUNTRIES';

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.MNG_categories' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'CONTAINERS', rid );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, 'CONTAINER HIRE MAINTENANCE',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );
 if id <> 'z' and rid is not null
  then
   open c3(replace(rid,'~','+'));
   fetch c3 into c3rec;
   close c3;
 end if;

 htp.formopen( 'strangp.accept_mng_categories', ctarget=>'_top' );
 htp.formhidden( 'SURL', surl );
   htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'ID', id );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );


  htp.tablerowopen;
   htp.tabledata( htf.bold('Contract'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT' and id = 'z'
    then
     htp.tabledata( htf.formtext('P1', 10, 10, c3rec.contract),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" ');
    else
     htp.tabledata( htf.bold(nvl(c3rec.contract,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" ');
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Code Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');

 if vaccess = 'EDIT' and id = 'z'
    then
     htp.tabledata( htf.formtext('P2', 12, 12, c3rec.codedesc),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"  ');
    else
     htp.tabledata( htf.bold(nvl(c3rec.codedesc,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"  ');
   end if;
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata( htf.bold('Company Name'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT' and id = 'z'
    then
     htp.tabledata( htf.formtext('P3', 20, 20, c3rec.company),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"  ');
     else
       htp.tabledata( htf.bold(nvl(c3rec.company,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" ');
     end if;

  htp.tablerowclose;

  /*
  htp.tablerowopen;
   htp.tabledata( htf.bold('Date Created'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT' and id = 'z'
    then
     htp.tabledata( htf.formtext('P4', 15, 15, to_char(c3rec.cdate,'DD-MON-YYYY')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
    else
     htp.tabledata( htf.bold(nvl(to_char(c3rec.cdate,'DD-MON-YYYY'),'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;
  htp.tablerowclose;
 */

  htp.tablerowopen;
   htp.tabledata( htf.bold('Category Description'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   if vaccess = 'EDIT'
    then
     htp.tabledata( htf.formtext('P5', 15, 12, c3rec.catdesc),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"  ');
    else
     htp.tabledata( htf.bold(nvl(c3rec.catdesc,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"  ');
   end if;
  htp.tablerowclose;


  htp.tablerowopen;
   htp.tabledata( htf.bold('Leasing/Day'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P6', 12, 20, trim(to_char(round(c3rec.leasecost,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.leasecost,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
  htp.tablerowclose;


  htp.tablerowopen;
   htp.tabledata( htf.bold('Company Leasing/Day'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P7', 12, 20, trim(to_char(round(c3rec.compcost,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.compcost,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
  htp.tablerowclose;


   htp.tabledata( htf.bold('Currency'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
     if vaccess = 'EDIT'
      then
        htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" >' );
          htp.formselectopen( 'P8' );
              for c8rec in c8

              loop
                if c8rec.cola=nvl(c3rec.curr_code,'USD') then
                  htp.formselectoption( c8rec.cola, 'SELECTED', cattributes=>'VALUE="'||c8rec.cola ||'"');
                else
                  htp.formselectoption( c8rec.cola, cattributes=>'VALUE="'||c8rec.cola ||'"');
               end if;
              end loop;

          htp.formselectclose;
        htp.p( '</TD>');
      else
       htp.tabledata( htf.bold(nvl(c3rec.curr_code,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" ');
     end if;


 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT' and (id = 'z' or rid is null)
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Insert' ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Update' ),cattributes=>'VALIGN="TOP"');
   open c4(c3rec.contract,c3rec.company,c3rec.codedesc);
   fetch c4 into c4rec;
   close c4;
   open c5(c3rec.contract,c3rec.company,c3rec.codedesc);
   fetch c5 into c5rec;
   close c5;
   if (c4rec.cnt + c5rec.cnt = 0) then
      htp.tabledata( htf.formsubmit( 'ACTION', 'Delete' ),cattributes=>'VALIGN="TOP"');
   end if;
 end if;
 htp.formclose;


 if vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formopen( 'strangp.mng_categories' ) || htf.formhidden( 'SURL', surl ) || htf.formhidden( 'ID', 'z' ) || htf.formhidden( 'RID', null ) || htf.formsubmit( null, 'Create New Record' ) || htf.formclose,cattributes=>'VALIGN="TOP"');
 end if;
 htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.nl;
 search( surl, 'CATEG', rid );
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MNG_CATEGORIES',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end mng_categories;

-- **********************************************************

-- **********************************************************

procedure accept_mng_categories( SURL IN VARCHAR2, RID IN VARCHAR2, ID in VARCHAR2, P1 IN VARCHAR2 default null, P2 IN VARCHAR2 default null, P3 IN VARCHAR2 default null, P4 IN VARCHAR2 default null, P5 IN VARCHAR2,
P6 IN VARCHAR2, P7 IN VARCHAR2, P8 IN VARCHAR2, ACTION IN VARCHAR2 )
as

cursor c2 is select max(rno) mx from strang.categories;
cursor c3 ( cont varchar2, cod varchar2, cname varchar2) is select * from strang.categories
where contract=UPPER(cont) and
 codedesc= UPPER(cod) and
 company = UPPER(cname);

cursor c7 (rid rowid) is select * from strang.categories where rowid=rid;
cursor c8 (ctr varchar2) is select * from strang.containers where containerno = ctr and offdate is null;

c2rec c2%ROWTYPE;
c3rec c3%ROWTYPE;
c7rec c7%ROWTYPE;
c8rec c8%ROWTYPE;

dt1 date;
errmsg varchar2(1000);
newrid rowid;
nmb1 number;
nmb2 number;

begin

if ((P1 is null) or (P2 is null) or (P3 is null) or (P5 is null) or (P6 is null) or (P7 is null) or (P8 is null)) and id='z'  then
  mng_categories( surl, rid, null, 'No Fields Can Be Left Blank' );
  return;
end if;
if ((P5 is null) or (P6 is null) or (P7 is null) or (P8 is null)) and id='x'  then
  mng_categories( surl, rid, null, 'No Fields Can Be Left Blank' );
  return;
end if;

begin nmb1 := to_number( p6 ); exception when others then begin nmb1 := to_number( p6,LNGS.MONEY_FORMAT ); exception when others then nmb1 := 0; end; end;
begin nmb2 := to_number( p7 ); exception when others then begin nmb2 := to_number( p7,LNGS.MONEY_FORMAT ); exception when others then nmb2 := 0; end; end;

if action='Insert' then
    open c3 ( P1,P2,P3 );
    fetch c3 into c3rec;
    close c3;
    open c2;
    fetch c2 into c2rec;
    close c2;
    c2rec.mx := nvl(c2rec.mx,0) + 1;
    insert into strang.categories ( contract,codedesc,company,catdesc,leasecost,compcost,curr_code,rno )
    values ( upper(P1),upper(P2),P3,upper(P5),nmb1,nmb2,P8,c2rec.mx ) returning rowid into newrid;
    mng_categories( surl, newrid, 'x' , 'Insert Successful');
    commit;
    return;
end if;

if action='Update' then
    update strang.categories set
    catdesc = UPPER(P5),
    leasecost = nmb1,
    compcost  = nmb2,
    curr_code = P8
  where rowid = rid;
commit;
mng_categories( surl, rid, 'x', 'Update Successful');
end if;

if action='Delete' then
  delete from strang.categories
  where rowid = rid;
  commit;
  mng_categories( surl, rid, 'x', 'Delete Successful');
  menu (surl=>surl,mtype=>'CATEG',action=>'SEARCH',rid=>null,rnd=>null,msearch=>null);
end if;



exception when others then
glbx.error_details( 'STRANGP', 'ACCEPT_MNG_categories',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);

end accept_mng_categories;



--****************************************************************************************
--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
--******************************************************************************************
procedure mng_onlocs( surl in varchar2, id in varchar2 )
as
 arr_rid src_rid;
begin
 for j in 1..10 loop
  arr_rid(j) := null;
 end loop;
 mng_onlocs(surl, arr_rid, id );
end mng_onlocs;

procedure mng_onlocs( surl in varchar2, arr_rid in src_rid, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null )
as

 cursor c3( rid rowid ) is select * from strang.onlocs where rowid = rid;

 cursor c4( cont varchar2, comp varchar2, ccde varchar2 ) is select count('x') cnt from strang.containers
 where cat_contract = cont and
       cat_company  = comp and
       cat_code     = ccde;
 cursor c7 is select * from strang.categories order by contract,company,codedesc;
 cursor c8 is select code from strang.lov where lov_name = 'COUNTRIES' order by code;
 cursor c9(c1 varchar2, c2 varchar2, c3 varchar2, c4 varchar2 ) is select 'x' exst from strang.containers where cat_contract = c1 and cat_code = c2 and cat_company = c3 and nloc_location = c4;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c9rec		c9%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 frid		rowid;
 rid		rowid;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.mng_onlocs' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'CONTAINERS', rid );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, 'CONTAINER HIRE MAINTENANCE',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_mng_onlocs', ctarget=>'_top' );
 htp.formhidden( 'SURL', surl );
   --htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'ID', id );
   htp.formhidden( 'P2', null ); -- was cdate
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );

 htp.tablerowopen;
  htp.tabledata( htf.bold('Category<BR>Selection'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Contract'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Company<BR>Name'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Location'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Charge'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Handling'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('D/I'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Company<BR>Charge'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Company<BR>Handling'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Company<BR>D/I'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
 htp.tablerowclose;

 for j in arr_rid.first..arr_rid.last loop

 if j = arr_rid.first then frid := arr_rid(j); end if;
 rid := arr_rid(j);
 if id <> 'z' and rid is not null
  then
   open c3(replace(rid,'~','+'));
   fetch c3 into c3rec;
   close c3;
 elsif id <> 'z' and vaccess = 'EDIT' and rid is null then rid := null; exit;
 end if;

 htp.tablerowopen;
  if vaccess = 'EDIT' and id = 'z'
      then
        htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="4"  >' );
        htp.formhidden( 'ARR_RID', null );
          htp.formselectopen( 'P1' );
              for c7rec in c7
              loop
                if c7rec.contract=c3rec.cat_contract then
                  htp.formselectoption( ' --- '|| c7rec.contract || ' --- '|| c7rec.codedesc || ' --- '|| c7rec.company, 'SELECTED', cattributes=>'VALUE="'||c7rec.rno ||'"');
                else
                  htp.formselectoption( ' --- '|| c7rec.contract || ' --- '|| c7rec.codedesc || ' --- '|| c7rec.company, cattributes=>'VALUE="'||c7rec.rno ||'"');
               end if;
              end loop;

          htp.formselectclose;
        htp.p( '</TD>');
      else
       open c9(c3rec.cat_contract, c3rec.cat_code, c3rec.cat_company, c3rec.loc_location );
       fetch c9 into c9rec;
       if c9%notfound
        then
         htp.tabledata( htf.formhidden( 'ARR_RID', rid ) ||
                        htf.formhidden( 'P1', null ) ||
                        htf.formhidden( 'P3', null ) ||
                        htf.anchor( 'strangp.onlocs_del?surl=' || surl || '&rid=' || replace(rowidtochar(rid),'+','~'), 'Delete' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" ');
        else
         htp.tabledata( htf.formhidden( 'ARR_RID', rid ) || htf.formhidden( 'P1', null ) || htf.formhidden( 'P3', null ) || '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
       close c9;
       htp.tabledata( htf.bold(nvl(c3rec.cat_contract,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( htf.bold(nvl(c3rec.cat_code,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( htf.bold(nvl(c3rec.cat_company,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;

   if vaccess = 'EDIT' and id = 'z'
      then
        htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" >' );
          htp.formselectopen( 'P3' );
              for c8rec in c8 loop
                if c8rec.code=c3rec.loc_location then
                  htp.formselectoption( c8rec.code, 'SELECTED', cattributes=>'VALUE="'||c8rec.code ||'"');
                else
                  htp.formselectoption( c8rec.code, cattributes=>'VALUE="'||c8rec.code ||'"');
               end if;
              end loop;

          htp.formselectclose;
        htp.p( '</TD>');
      else
       htp.tabledata( htf.bold(nvl(c3rec.loc_location,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" ');
     end if;

    if  vaccess = 'EDIT'
     then
       htp.tabledata( htf.formtext( 'P4', 12, 20, trim(to_char(round(c3rec.oncharge,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.oncharge,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P5', 12, 20, trim(to_char(round(c3rec.onhandle,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.onhandle,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P6', 12, 20, trim(to_char(round(c3rec.intchange,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.intchange,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P7', 12, 20, trim(to_char(round(c3rec.concharge,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.concharge,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P8', 12, 20, trim(to_char(round(c3rec.conhandle,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.conhandle,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P9', 12, 20, trim(to_char(round(c3rec.cintchange,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.cintchange,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;

  htp.tablerowclose;
 end loop;

 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT' and (id = 'z' or frid is null)
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Insert' ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Update' ),cattributes=>'VALIGN="TOP"');
 end if;
 htp.formclose;


 if vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formopen( 'strangp.mng_onlocs' ) || htf.formhidden( 'SURL', surl ) ||
                  htf.formhidden( 'ID', 'z' ) ||
                  htf.formsubmit( null, 'Create New Record' ) || htf.formclose,cattributes=>'VALIGN="TOP"');
 end if;
 htp.tabledata( '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' );
 htp.tabledata( 'NB. Search Order: Contract Company Code. % can be used as wildcard.' );
 htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.nl;
 search( surl, 'ONLOCS', frid, lmnu=>rid );
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MNG_onlocs',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end mng_onlocs;

-- **********************************************************

-- **********************************************************
--****************************************************************************************

procedure onlocs_del( surl in varchar2, rid in varchar2 )
as
 vrid	rowid;
begin
 vrid := chartorowid(replace(rid,'~','+'));
 delete from strang.onlocs where rowid = vrid;
 commit;
 menu (surl=>surl,mtype=>'ONLOCS',action=>'SEARCH',rid=>null,rnd=>null,msearch=>null);
end onlocs_del;

procedure accept_mng_onlocs( surl in varchar2, arr_rid in glbx.myarray, id in varchar2, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, p5 in glbx.myarray, p6 in glbx.myarray, p7 in glbx.myarray, p8 in glbx.myarray, p9 in glbx.myarray, action in varchar2 )
as

cursor c2 is select max(rno) mx from strang.onlocs;

cursor c3 ( vrno integer ) is select * from strang.categories where rno = vrno ;
cursor c7 (rid rowid) is select * from strang.onlocs where rowid=rid;
cursor c8 (ctr varchar2) is select * from strang.containers where containerno = ctr and offdate is null;

c2rec 	c2%ROWTYPE;
c3rec 	c3%ROWTYPE;
c7rec 	c7%ROWTYPE;
c8rec 	c8%ROWTYPE;

dt1 	date;
errmsg 	varchar2(1000);
newrid 	rowid;
nmb1 	number(6,2);
nmb2 	number(6,2);
nmb3 	number(6,2);
nmb4 	number(6,2);
nmb5 	number(6,2);
nmb6 	number(6,2);
rid  	rowid;
narr_rid src_rid;
ctr	integer;

begin
ctr := 0;
for j in 1..10 loop
  narr_rid(j) := null;
end loop;
for j in arr_rid.first..arr_rid.last loop

 if ( ((P1(j) is null) or (P3(j) is null) or (P4(j) is null) or (P5(j) is null) or (P6(j) is null) or (P7(j) is null) or (P8(j) is null) or (P9(j) is null)) and id = 'z' ) or
    ( ((P4(j) is null) or (P5(j) is null) or (P6(j) is null) or (P7(j) is null) or (P8(j) is null) or (P9(j) is null)) and id = 'x' )
  then
   null;
  else

  begin nmb1 := to_number( p4(j) ); exception when others then begin nmb1 := to_number( p4(j),LNGS.MONEY_FORMAT ); exception when others then nmb1 := 0; end; end;
  begin nmb2 := to_number( p5(j) ); exception when others then begin nmb2 := to_number( p5(j),LNGS.MONEY_FORMAT ); exception when others then nmb2 := 0; end; end;
  begin nmb3 := to_number( p6(j) ); exception when others then begin nmb3 := to_number( p6(j),LNGS.MONEY_FORMAT ); exception when others then nmb3 := 0; end; end;
  begin nmb4 := to_number( p7(j) ); exception when others then begin nmb4 := to_number( p7(j),LNGS.MONEY_FORMAT ); exception when others then nmb4 := 0; end; end;
  begin nmb5 := to_number( p8(j) ); exception when others then begin nmb5 := to_number( p8(j),LNGS.MONEY_FORMAT ); exception when others then nmb5 := 0; end; end;
  begin nmb6 := to_number( p9(j) ); exception when others then begin nmb6 := to_number( p9(j),LNGS.MONEY_FORMAT ); exception when others then nmb6 := 0; end; end;

  if action = 'Insert' then
      open c3 ( P1(j) );
      fetch c3 into c3rec;
      close c3;
      open c2;
      fetch c2 into c2rec;
      close c2;
      c2rec.mx := nvl(c2rec.mx,0) + 1;

      begin
       insert into strang.onlocs (loc_location,cat_company,cat_contract,cat_code,oncharge,onhandle,intchange,concharge,conhandle,cintchange,rno )
       values ( P3(j), c3rec.company,c3rec.contract,c3rec.codedesc,nmb1,nmb2,nmb3,nmb4,nmb5,nmb6,c2rec.mx ) returning rowid into newrid;
      exception
       when others then
        mng_onlocs( surl, narr_rid, 'z', 'Insert Failed:' || sqlerrm);
        return;
      end;

      ctr := ctr + 1;
      narr_rid(ctr) := newrid;
      commit;
  end if;

 if action='Update' then
     rid := chartorowid(arr_rid(j));
     update strang.onlocs set
     oncharge = nmb1,
     onhandle = nmb2,
     intchange = nmb3,
     concharge = nmb4,
     conhandle = nmb5,
     cintchange =nmb6
     where rowid = rid;
     commit;
 end if;

end if;

end loop;

if action = 'Insert' and ctr > 0
 then
   mng_onlocs( surl, narr_rid, 'x', 'Insert Successful');

elsif action = 'Insert' and ctr = 0
 then
   mng_onlocs( surl, narr_rid, 'z', 'Nothing to Insert');

elsif action = 'Update'
 then
   for j in arr_rid.first..arr_rid.last loop
    narr_rid(j) := chartorowid(arr_rid(j));
   end loop;
   mng_onlocs( surl, narr_rid, 'x', 'Update Successful');
end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MNG_onlocs',null,null,errmsg=>sqlerrm);
end accept_mng_onlocs;



--((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((
--****************************************************************************************
--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
--******************************************************************************************
procedure mng_offlocs( surl in varchar2, id in varchar2 )
as
 arr_rid src_rid;
begin
 for j in 1..10 loop
  arr_rid(j) := null;
 end loop;
 mng_offlocs(surl, arr_rid, id );
end mng_offlocs;

procedure mng_offlocs( surl in varchar2, arr_rid in src_rid, id in varchar2 default null, msg in varchar2 default null, call_name in varchar2 default null, parm in varchar2 default null )
as

 cursor c3( rid rowid ) is select * from strang.offlocs where rowid = rid;

 cursor c4( cont varchar2, comp varchar2, ccde varchar2 ) is select count('x') cnt from strang.containers
 where cat_contract = cont and
       cat_company  = comp and
       cat_code     = ccde;
 cursor c7 is select * from strang.categories order by contract,company,codedesc;
 cursor c8 is select code from strang.lov where lov_name = 'COUNTRIES' order by code;
 cursor c9(c1 varchar2, c2 varchar2, c3 varchar2, c4 varchar2 ) is select 'x' exst from strang.containers where cat_contract = c1 and cat_code = c2 and cat_company = c3 and floc_location = c4;

 c1rec		customer_account%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c9rec		c9%ROWTYPE;
 pfx		THEME%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 vaccess	varchar2(20);
 frid		rowid;
 rid		rowid;

begin
  glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'STRANGP.MNG_OFFLOCS' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  vaccess := data_access( owner_id, 'CONTAINERS', rid );
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 pfx := glbx.get_thm( c1rec.theme_name );

 glbx.main_title( surl, 'CONTAINER HIRE MAINTENANCE',glbx.backimg(surl,c1rec.aid,pfx.text_back,c1rec.background_img,ltype),helpid=>'STR22',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, disptop=>pfx.keep_lhf, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc);
 if vaccess = 'NONE' then htp.bold( LNGS.STR_TXT_002 ); htp.htmlclose; return; end if;
 htp.p( '<CENTER>' );

 htp.formopen( 'strangp.accept_mng_offlocs', ctarget=>'_top' );
 htp.formhidden( 'SURL', surl );
   --htp.formhidden( 'RID', replace(rid,'~','+') );
   htp.formhidden( 'ID', id );
   htp.formhidden( 'P2', null ); -- was cdate
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1 ' || glbx.TABLE_BACKGROUND );

 htp.tablerowopen;
  htp.tabledata( htf.bold('Category<BR>Selection'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Contract'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Code'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Company<BR>Name'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Location'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Charge'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Handling'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('D/I'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Company<BR>Charge'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Company<BR>Handling'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
   htp.tabledata( htf.bold('Company<BR>D/I'),cattributes=>glbx.QUERY_BACKGROUND || ' ALIGN="LEFT"');
 htp.tablerowclose;

 for j in arr_rid.first..arr_rid.last loop

 if j = arr_rid.first then frid := arr_rid(j); end if;
 rid := arr_rid(j);
 if id <> 'z' and rid is not null
  then
   open c3(replace(rid,'~','+'));
   fetch c3 into c3rec;
   close c3;
 elsif id <> 'z' and vaccess = 'EDIT' and rid is null then rid := null; exit;
 end if;

 htp.tablerowopen;
  if vaccess = 'EDIT' and id = 'z'
      then
        htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" COLSPAN="4"  >' );
        htp.formhidden( 'ARR_RID', null );
          htp.formselectopen( 'P1' );
              for c7rec in c7
              loop
                if c7rec.contract=c3rec.cat_contract then
                  htp.formselectoption( ' --- '|| c7rec.contract || ' --- '|| c7rec.codedesc || ' --- '|| c7rec.company, 'SELECTED', cattributes=>'VALUE="'||c7rec.rno ||'"');
                else
                  htp.formselectoption( ' --- '|| c7rec.contract || ' --- '|| c7rec.codedesc || ' --- '|| c7rec.company, cattributes=>'VALUE="'||c7rec.rno ||'"');
               end if;
              end loop;

          htp.formselectclose;
        htp.p( '</TD>');
      else
       open c9(c3rec.cat_contract, c3rec.cat_code, c3rec.cat_company, c3rec.loc_location );
       fetch c9 into c9rec;
       if c9%notfound
        then
         htp.tabledata( htf.formhidden( 'ARR_RID', rid ) ||
                        htf.formhidden( 'P1', null ) ||
                        htf.formhidden( 'P3', null ) ||
                        htf.anchor( 'strangp.offlocs_del?surl=' || surl || '&rid=' || replace(rowidtochar(rid),'+','~'), 'Delete' ), cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" ');
        else
         htp.tabledata( htf.formhidden( 'ARR_RID', rid ) || htf.formhidden( 'P1', null ) || htf.formhidden( 'P3', null ) || '&nbsp;',cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       end if;
       close c9;
       htp.tabledata( htf.bold(nvl(c3rec.cat_contract,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( htf.bold(nvl(c3rec.cat_code,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
       htp.tabledata( htf.bold(nvl(c3rec.cat_company,'&nbsp')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT"');
   end if;

   if vaccess = 'EDIT' and id = 'z'
      then
        htp.p( '<TD '|| glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" >' );
          htp.formselectopen( 'P3' );
              for c8rec in c8 loop
                if c8rec.code=c3rec.loc_location then
                  htp.formselectoption( c8rec.code, 'SELECTED', cattributes=>'VALUE="'||c8rec.code ||'"');
                else
                  htp.formselectoption( c8rec.code, cattributes=>'VALUE="'||c8rec.code ||'"');
               end if;
              end loop;

          htp.formselectclose;
        htp.p( '</TD>');
      else
       htp.tabledata( htf.bold(nvl(c3rec.loc_location,'&nbsp;')),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT" ');
     end if;

    if  vaccess = 'EDIT'
     then
       htp.tabledata( htf.formtext( 'P4', 12, 20, trim(to_char(round(c3rec.offcharge,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.offcharge,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P5', 12, 20, trim(to_char(round(c3rec.offhandle,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.offhandle,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P6', 12, 20, trim(to_char(round(c3rec.intchange,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.intchange,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P7', 12, 20, trim(to_char(round(c3rec.coffcharge,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.coffcharge,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P8', 12, 20, trim(to_char(round(c3rec.coffhandle,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.coffhandle,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;
     if  vaccess = 'EDIT'
      then
       htp.tabledata( htf.formtext( 'P9', 12, 20, trim(to_char(round(c3rec.cintchange,2),LNGS.MONEY_FORMAT))),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
      else
       htp.tabledata( to_char(round(c3rec.cintchange,2),LNGS.MONEY_FORMAT),cattributes=>glbx.QUERY_CELL_BACKGROUND || ' ALIGN="RIGHT"');
     end if;

  htp.tablerowclose;
 end loop;

 htp.tableclose;
 htp.nl;
 htp.tableopen( cattributes=>'cellspacing=0 cellpadding=0 border=0' );
 htp.tablerowopen;
 if vaccess = 'EDIT' and (id = 'z' or frid is null)
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Insert' ),cattributes=>'VALIGN="TOP"');
 elsif vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formsubmit( 'ACTION', 'Update' ),cattributes=>'VALIGN="TOP"');
 end if;
 htp.formclose;


 if vaccess = 'EDIT' and id <> 'z'
  then
   htp.tabledata( htf.formopen( 'strangp.mng_offlocs' ) || htf.formhidden( 'SURL', surl ) ||
                  htf.formhidden( 'ID', 'z' ) ||
                  htf.formsubmit( null, 'Create New Record' ) || htf.formclose,cattributes=>'VALIGN="TOP"');
 end if;
 htp.tabledata( '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' );
 htp.tabledata( 'NB. Search Order: Contract Company Code. % can be used as wildcard.' );
 htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.nl;
 search( surl, 'OFFLOCS', frid, lmnu=>rid );
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'); htp.nl;
 if msg is not null
  then
   glbx.header_msg( msg );
 end if;
 htp.p( '</CENTER>' );
 htp.tableclose;
exception when others then
 glbx.error_details( 'STRANGP', 'MNG_OFFLOCS',null,null,errmsg=>sqlerrm,extdet=>'RID:' || rid);
end mng_offlocs;

procedure offlocs_del( surl in varchar2, rid in varchar2 )
as
 vrid	rowid;
begin
 vrid := chartorowid(replace(rid,'~','+'));
 delete from strang.offlocs where rowid = vrid;
 commit;
 menu (surl=>surl,mtype=>'OFFLOCS',action=>'SEARCH',rid=>null,rnd=>null,msearch=>null);
end offlocs_del;

procedure accept_mng_offlocs( surl in varchar2, arr_rid in glbx.myarray, id in varchar2, p1 in glbx.myarray, p2 in glbx.myarray, p3 in glbx.myarray, p4 in glbx.myarray, p5 in glbx.myarray, p6 in glbx.myarray, p7 in glbx.myarray, p8 in glbx.myarray, p9 in glbx.myarray, action in varchar2 )
as

cursor c2 is select max(rno) mx from strang.offlocs;

cursor c3 ( vrno integer ) is select * from strang.categories where rno = vrno ;
cursor c7 (rid rowid) is select * from strang.offlocs where rowid=rid;
cursor c8 (ctr varchar2) is select * from strang.containers where containerno = ctr and offdate is null;

c2rec 	c2%ROWTYPE;
c3rec 	c3%ROWTYPE;
c7rec 	c7%ROWTYPE;
c8rec 	c8%ROWTYPE;

dt1 	date;
errmsg 	varchar2(1000);
newrid 	rowid;
nmb1 	number(6,2);
nmb2 	number(6,2);
nmb3 	number(6,2);
nmb4 	number(6,2);
nmb5 	number(6,2);
nmb6 	number(6,2);
rid  	rowid;
narr_rid src_rid;
ctr	integer;

begin
ctr := 0;
for j in 1..10 loop
  narr_rid(j) := null;
end loop;
for j in arr_rid.first..arr_rid.last loop

 if ( ((P1(j) is null) or (P3(j) is null) or (P4(j) is null) or (P5(j) is null) or (P6(j) is null) or (P7(j) is null) or (P8(j) is null) or (P9(j) is null)) and id = 'z' ) or
    ( ((P4(j) is null) or (P5(j) is null) or (P6(j) is null) or (P7(j) is null) or (P8(j) is null) or (P9(j) is null)) and id = 'x' )
  then
   null;
  else

  begin nmb1 := to_number( p4(j) ); exception when others then begin nmb1 := to_number( p4(j),LNGS.MONEY_FORMAT ); exception when others then nmb1 := 0; end; end;
  begin nmb2 := to_number( p5(j) ); exception when others then begin nmb2 := to_number( p5(j),LNGS.MONEY_FORMAT ); exception when others then nmb2 := 0; end; end;
  begin nmb3 := to_number( p6(j) ); exception when others then begin nmb3 := to_number( p6(j),LNGS.MONEY_FORMAT ); exception when others then nmb3 := 0; end; end;
  begin nmb4 := to_number( p7(j) ); exception when others then begin nmb4 := to_number( p7(j),LNGS.MONEY_FORMAT ); exception when others then nmb4 := 0; end; end;
  begin nmb5 := to_number( p8(j) ); exception when others then begin nmb5 := to_number( p8(j),LNGS.MONEY_FORMAT ); exception when others then nmb5 := 0; end; end;
  begin nmb6 := to_number( p9(j) ); exception when others then begin nmb6 := to_number( p9(j),LNGS.MONEY_FORMAT ); exception when others then nmb6 := 0; end; end;

  if action = 'Insert' then
      open c3 ( P1(j) );
      fetch c3 into c3rec;
      close c3;
      open c2;
      fetch c2 into c2rec;
      close c2;
      c2rec.mx := nvl(c2rec.mx,0) + 1;
      begin
        insert into strang.offlocs (loc_location,cat_company,cat_contract,cat_code,offcharge,offhandle,intchange,coffcharge,coffhandle,cintchange,rno )
        values ( P3(j), c3rec.company,c3rec.contract,c3rec.codedesc,nmb1,nmb2,nmb3,nmb4,nmb5,nmb6,c2rec.mx ) returning rowid into newrid;
      exception
       when others then
        mng_offlocs( surl, narr_rid, 'z', 'Insert Failed:' || sqlerrm);
        return;
      end;

      ctr := ctr + 1;
      narr_rid(ctr) := newrid;
      commit;
  end if;

 if action='Update' then
     rid := chartorowid(arr_rid(j));
     update strang.offlocs set
     offcharge = nmb1,
     offhandle = nmb2,
     intchange = nmb3,
     coffcharge = nmb4,
     coffhandle = nmb5,
     cintchange =nmb6
     where rowid = rid;
     commit;
 end if;

end if;

end loop;

if action = 'Insert' and ctr > 0
 then
   mng_offlocs( surl, narr_rid, 'x', 'Insert Successful');

elsif action = 'Insert' and ctr = 0
 then
   mng_offlocs( surl, narr_rid, 'z', 'Nothing to Insert');

elsif action = 'Update'
 then
   for j in arr_rid.first..arr_rid.last loop
    narr_rid(j) := chartorowid(arr_rid(j));
   end loop;
   mng_offlocs( surl, narr_rid, 'x', 'Update Successful');
end if;

exception when others then
 glbx.error_details( 'STRANGP', 'ACCEPT_MNG_OFFLOCS',null,null,errmsg=>sqlerrm);
end accept_mng_offlocs;

procedure generate_containers_onhire( crec in strang.containers%ROWTYPE )
as

 cursor c3(mv varchar2) is select * from strang.tracking_header where containerno = mv;

 cursor c5(sno integer) is select nvl(max(rno),0) + 1 mx from strang.tracking_details where id = sno;

 c3rec   c3%ROWTYPE;
 sno	 integer;
 calcrno integer;

begin

  open c3( crec.containerno );
  fetch c3 into c3rec;
  if c3%FOUND
   then
    -- check if ship and voyage already inserted
      open c5(c3rec.id);
      fetch c5 into calcrno;
      close c5;
      insert into strang.tracking_details(id,rno,remark,movement_type,departure_location,etd_date,arrival_location,eta_date,ship,voyage,current_location,date_at_current_loc)
       values(c3rec.id,calcrno,null,'ONHIRE',null,null,null,null,null,null,crec.nloc_location,crec.datehired);

   else

    -- insert new
    select strang.s_tracking_header.nextval into sno from dual;
    insert into strang.tracking_header(id,containerno,cat_code,cat_company) values
     (sno,crec.containerno,crec.cat_code,crec.cat_company);
    insert into strang.tracking_details(id,rno,remark,movement_type,departure_location,etd_date,arrival_location,eta_date,ship,voyage,current_location,date_at_current_loc)
     values(sno,1,null,'ONHIRE',null,null,null,null,null,null,crec.nloc_location,crec.datehired);

  end if;
  close c3;
 commit;
end generate_containers_onhire;

procedure generate_containers_offhire( crec in strang.containers%ROWTYPE )
as

 cursor c3(mv varchar2) is select * from strang.tracking_header where containerno = mv;

 cursor c5(sno integer) is select nvl(max(rno),0) + 1 mx from strang.tracking_details where id = sno;

 c3rec   c3%ROWTYPE;
 sno	 integer;
 calcrno integer;

begin

  open c3( crec.containerno );
  fetch c3 into c3rec;
  if c3%FOUND
   then
    -- check if ship and voyage already inserted
      open c5(c3rec.id);
      fetch c5 into calcrno;
      close c5;
    insert into strang.tracking_details(id,rno,remark,movement_type,departure_location,etd_date,arrival_location,eta_date,ship,voyage,current_location,date_at_current_loc)
     values(c3rec.id,calcrno,null,'OFFHIRE',null,null,null,null,null,null,crec.floc_location,crec.offdate);

   else

    -- insert new
    select strang.s_tracking_header.nextval into sno from dual;
    insert into strang.tracking_header(id,containerno,cat_code,cat_company) values
     (sno,crec.containerno,crec.cat_code,crec.cat_company);
    insert into strang.tracking_details(id,rno,remark,movement_type,departure_location,etd_date,arrival_location,eta_date,ship,voyage,current_location,date_at_current_loc)
     values(sno,1,null,'OFFHIRE',null,null,null,null,null,null,crec.floc_location,crec.offdate);

  end if;
  close c3;
 commit;
end generate_containers_offhire;

end strangp;
/
