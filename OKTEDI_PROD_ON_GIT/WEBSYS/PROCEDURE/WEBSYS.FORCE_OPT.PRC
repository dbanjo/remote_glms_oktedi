CREATE OR REPLACE procedure WEBSYS.force_opt(surl varchar2, calc_stats in char default 'F', v_schema varchar2 default 'WEBSYS')
as

  cursor c1 is
   select *
   from   all_tables
   where  owner  =v_schema
   order by table_name
   ;

   sessid	integer;
   sts		varchar2(200);
   status       varchar2(100);
   dstart       date;
   dstop        date;
   pvalue       number;

-- Start inline procedures

procedure main_title( ttl in varchar2, other_elements in varchar2 default null, style in varchar2 default 'BIG' )
as
begin
 htp.htmlopen;
 htp.print('<BODY BGCOLOR="#FFFFFF">');
 if style = 'BIG'
  then
   htp.tableopen( cattributes=>'width="100%" cellpadding=2 cellspacing=0 border=0 ' || glbx.TABLE_BACKGROUND );
    htp.tablerowopen;
     htp.tabledata('<b><font size="+1" color="#ffffff">' || ttl || '</font></b>',cattributes=>glbx.TITLE_BACKGROUND || 'valign="TOP"');
     if other_elements is not null
      then
	   htp.p( other_elements );
     end if;
    htp.tablerowclose;
   htp.tableclose;
 elsif style = 'SIMPLE'
  then
   htp.bold( ttl );
   htp.nl;
 end if;
end main_title;

-- End inline procedures

begin
 glbx.adm_cookie_id(surl,sessid,sts);
 if sts is not null
  then
   htp.htmlopen; htp.bold( sts ); htp.htmlclose; return;
   return;
 end if;
 case calc_stats
 when 'F' then main_title('Optimisation Figures - ' || v_schema);
 when 'D' then main_title('Dictionary Statistics');
 when 'T' then main_title('Force Optimisation - ' || v_schema);
 else main_title( LNG3.ADM_TXT_189 );
 end case;
 htp.nl;

 htp.bold('<a href="" onClick="self.close()">[Close Window]</a>');
 htp.nl;
 htp.nl;


 if calc_stats = 'T'
  then
  $if DBMS_Db_Version.Ver_LE_10_1 $then
   dbms_stats.gather_schema_stats( v_schema, null, granularity=>'ALL', cascade=>TRUE, method_opt => 'FOR ALL COLUMNS SIZE AUTO' );
  $else
   dbms_stats.gather_schema_stats( v_schema, null, granularity=>'ALL', cascade=>TRUE, force=>TRUE, method_opt => 'FOR ALL COLUMNS SIZE AUTO' );
  $end
 end if;

 if calc_stats in ('T','F')
  then
   htp.tableopen( cattributes=>mn.tableopen_style );
   htp.tablerowopen;
    htp.tableheader( LNG3.ADM_TXT_296, cattributes=>mn.header_style );
    htp.tableheader( LNG3.ADM_TXT_224, cattributes=>mn.header_style );
    htp.tableheader( LNG3.ADM_TXT_301, cattributes=>mn.header_style );
    htp.tableheader( LNG3.ADM_TXT_236, cattributes=>mn.header_style );
    htp.tableheader( 'Average Space', cattributes=>mn.header_style );
    htp.tableheader( 'Row Chain Count', cattributes=>mn.header_style );
    htp.tableheader( 'Last Analyzed', cattributes=>mn.header_style );
   htp.tablerowclose;
   for c1rec in c1 loop
    htp.tablerowopen;
     htp.tabledata( htf.bold(htf.italic(c1rec.table_name)) );
     htp.tabledata( nvl(to_char(c1rec.num_rows),'[-]') );
     htp.tabledata( nvl(to_char(c1rec.avg_row_len),'[-]') );
     htp.tabledata( nvl(to_char(c1rec.blocks),'[-]') );
     htp.tabledata( nvl(to_char(c1rec.AVG_SPACE),'[-]') );
     htp.tabledata( nvl(to_char(c1rec.CHAIN_CNT),'[-]') );
     htp.tabledata( nvl(to_char(c1rec.LAST_ANALYZED,LNG.TSMASK),'[-]') );
    htp.tablerowclose;
   end loop;
   htp.tableclose;
 end if;

 if calc_stats = 'S'
  then
   begin
    dbms_stats.gather_system_stats( 'INTERVAL', 10 );
   exception
    when others then
     htp.p( 'Error gathering stats: ' || sqlerrm );
   end;

   htp.nl;
   htp.nl;
   htp.italic( 'The Database is now gathering System Statistics from ' || to_char(sysdate,LNG.TSMASK) || ' until ' || to_char(sysdate+(10/(24*60)),LNG.TSMASK) );
   htp.nl;
   htp.nl;
   htp.p( 'Please use Piction normally so that the database can gather meaningful statistics on database performance.' );
   htp.nl;
   htp.tableopen( cattributes=>mn.tableopen_style );
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS(status, dstart, dstop, pname=>'iotfrspeed',pvalue=>pvalue);
     htp.tabledata( htf.bold('iotfrspeed') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('I/O transfer speed in bytes for each millisecond'));
    htp.tablerowclose;
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS (status, dstart, dstop, pname=>'ioseektim',pvalue=>pvalue);
     htp.tabledata( htf.bold('ioseektim') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('seek time + latency time + operating system overhead time, in milliseconds'));
    htp.tablerowclose;
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS (status, dstart, dstop, pname=>'sreadtim',pvalue=>pvalue);
     htp.tabledata( htf.bold('sreadtim') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('average time to read single block (random read), in milliseconds'));
    htp.tablerowclose;
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS (status, dstart, dstop, pname=>'mreadtim',pvalue=>pvalue);
     htp.tabledata( htf.bold('mreadtim') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('average time to read an mbrc block at once (sequential read), in milliseconds'));
    htp.tablerowclose;
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS (status, dstart, dstop, pname=>'cpuspeed',pvalue=>pvalue);
     htp.tabledata( htf.bold('cpuspeed') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('average number of CPU cycles for each second, in millions, captured for the workload'));
    htp.tablerowclose;
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS (status, dstart, dstop, pname=>'cpuspeednw',pvalue=>pvalue);
     htp.tabledata( htf.bold('cpuspeednw') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('average number of CPU cycles for each second, in millions, captured for the noworkload (statistics collected using ''NOWORKLOAD'' option.'));
    htp.tablerowclose;
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS (status, dstart, dstop, pname=>'mbrc',pvalue=>pvalue);
     htp.tabledata( htf.bold('mbrc') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('average multiblock read count for sequential read, in blocks'));
    htp.tablerowclose;
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS (status, dstart, dstop, pname=>'maxthr',pvalue=>pvalue);
     htp.tabledata( htf.bold('maxthr') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('maximum I/O system throughput, in bytes/second'));
    htp.tablerowclose;
    htp.tablerowopen;
     DBMS_STATS.GET_SYSTEM_STATS (status, dstart, dstop, pname=>'slavethr',pvalue=>pvalue);
     htp.tabledata( htf.bold('slavethr') );
     htp.tabledata( pvalue );
     htp.tabledata( htf.italic('average slave I/O throughput, in bytes/second'));
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
 end if;

 if calc_stats = 'D'
  then
   begin
    dbms_stats.gather_dictionary_stats( null, null, granularity=>'ALL', cascade=>TRUE, method_opt => 'FOR ALL COLUMNS SIZE AUTO' );
   exception
    when others then
     htp.p( 'Error gathering Dictionary stats: ' || sqlerrm );
   end;

   htp.nl;
   htp.italic( 'The Database has gathered Statistics on the Data Dictionary' );
   htp.nl;

 end if;

 htp.nl;
 htp.bold('<a href="" onClick="self.close()">[Close Window]</a>');
 htp.nl;

 htp.htmlclose;
exception
 when others then htp.p( 'Optimizer Error:' || sqlerrm );
end force_opt;
/
