CREATE OR REPLACE procedure WEBSYS.storage_manager
as

 cursor c2( ts varchar2 ) is select sum(bytes) tot from dba_data_files where tablespace_name = ts;
 cursor c2t( ts varchar2 ) is select sum(bytes) tot from dba_temp_files where tablespace_name = ts;
 cursor c3( ts varchar2 ) is select sum(bytes) tot from dba_free_space where tablespace_name = ts;
 cursor c4(ts varchar2) is
  select d.file_id, d.file_name, d.tablespace_name, v.create_bytes, d.maxbytes, d.bytes, d.status, v.enabled, d.autoextensible, d.increment_by
  from dba_data_files d, v$datafile v
  where v.file# = d.file_id and
        d.tablespace_name = ts
  order by d.file_id;
 cursor c4t(ts varchar2) is
  select d.file_id, d.file_name, d.tablespace_name, v.create_bytes, d.maxbytes, d.bytes, d.status, v.enabled, d.autoextensible, d.increment_by
  from dba_temp_files d, v$datafile v
  where v.file# = d.file_id and
        d.tablespace_name = ts
  order by d.file_id;
 cursor c7 is select * from dba_tablespaces order by tablespace_name;

 sessid		integer;
 sts		varchar2(200);
 tmp		varchar2(2000);
 url		varchar2(1000);
 tot_free	number;
 tot_used	number;
 gtot_free	number;
 gtot_used	number;
 vtot_free	number;
 vtot_used	number;
 tot_img	number;
 avg_size	number;
 avg_free	number;
 pct_free	number;
 used_mst	number;
 used_ori	number;
 used_bac	number;
 used_thm	number;
 actused	number;
----------------------------------------------------------------

function img_size( lng in number, szto in char default 'K' )
 return varchar2
as
 vl	number;
 stp	varchar2(100);
begin
 if lng is null then return( 0 ); end if;
 stp := 'A';
 if szto = 'A' and lng < 9999
  then
   return( to_char(lng) || ' bytes' );
 elsif szto = 'K' or (szto = 'A' and lng < 1500000)
  then
   return( trim(to_char(round( nvl(lng,0)/1024),'999,999,999')) || ' ' || 'Kb' );
 elsif szto = 'M'
  then
   return( trim(to_char(round( nvl(lng,0)/(1024*1000)),'999,999,999')) || ' ' || 'Mb' );
 elsif szto = 'A'
  then
 stp := 'B';
   if lng < 1500000000
    then
    return( trim(to_char(round( nvl(lng,0)/(1024*1000),1),'999,999,999.9')) || ' ' || 'Mb' );
   elsif lng < 1500000000000
    then
    return( trim(to_char(round( nvl(lng,0)/(1024*1000*1000),2),'999,999,999.99')) || ' ' || 'Gb' );
   else
 stp := 'C'; -- note has to be done this way otherwise and error occurs
    vl := lng / 1024;
 stp := 'D';
    vl := vl / (1000*1000*1000);
 stp := 'E';
    return( trim(to_char(round(vl,3),'999,999,999.999')) || ' ' || 'Tb' );
   end if;
 end if;
exception
 when others then return( lng || ':' || stp || '-' || sqlerrm  );
end img_size;

----------------------------------------------------------------
begin

 htp.nl;
 htp.p( '<CENTER>' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( LNG3.ADM_TXT_478 ),cattributes=>'bgcolor="#C0C0A0"');
   htp.tabledata( htf.bold( LNG3.ADM_TXT_479 ),cattributes=>'bgcolor="#C0C0A0"');
   htp.tabledata( htf.bold( LNG3.ADM_TXT_480 ),cattributes=>'bgcolor="#C0C0A0"');
   htp.tabledata( htf.bold( LNG3.ADM_TXT_481 ),cattributes=>'bgcolor="#C0C0A0"');
   htp.tabledata( htf.bold( LNG3.ADM_TXT_482 ),cattributes=>'bgcolor="#C0C0A0"');
   htp.tabledata( htf.bold( 'Physical Files' ),cattributes=>'bgcolor="#C0C0A0"');
  htp.tablerowclose;
  gtot_free := 0;
  gtot_used := 0;
  for c7rec in c7 loop
   tot_used := 0;
   if c7rec.contents = 'TEMPORARY'
    then
     open c2t( c7rec.tablespace_name );
     fetch c2t into vtot_used;
     close c2t;
     tot_free := 0;
     open c3( c7rec.tablespace_name );
     fetch c3 into vtot_free;
     close c3;
    else
     open c2( c7rec.tablespace_name );
     fetch c2 into vtot_used;
     close c2;
     tot_free := 0;
     open c3( c7rec.tablespace_name );
     fetch c3 into vtot_free;
     close c3;
   end if;
   gtot_free := gtot_free + nvl(vtot_free,0);
   gtot_used := gtot_used + nvl(vtot_used,0);
   tot_used := nvl(trunc((vtot_used/1024)/1024),0);
   tot_free := nvl(trunc((vtot_free/1024)/1024),0);
   htp.tablerowopen;
   if c7rec.contents = 'TEMPORARY'
    then
     htp.tabledata( htf.bold( c7rec.tablespace_name  || htf.nl || '<i>Temporary</i>' ),cattributes=>'bgcolor="#E0E0D0"');
   elsif c7rec.contents = 'UNDO'
    then
     -- url := 'javascript: window.open(''' || 'adm.tablespace_map?surl=' || surl || '&tn=' || c7rec.tablespace_name || ''',''' || 'SUPPLIER' || ''',''height=800,width=800,scrollbars=yes,resizable=yes'');void('''');';
     htp.tabledata( htf.bold( c7rec.tablespace_name  || htf.nl || '<i>Undo</i>'  ),cattributes=>'bgcolor="#E0E0D0"');
    else
     -- url := 'javascript: window.open(''' || 'adm.tablespace_map?surl=' || surl || '&tn=' || c7rec.tablespace_name || ''',''' || 'SUPPLIER' || ''',''height=800,width=800,scrollbars=yes,resizable=yes'');void('''');';
     htp.tabledata( htf.bold( c7rec.tablespace_name  ),cattributes=>'bgcolor="#E0E0D0"');
   end if;
   htp.tabledata( htf.bold( img_size(vtot_used,'A') ),cattributes=>'bgcolor="#E0E0D0"');
   if tot_used = 0
    then
     pct_free := round((tot_free/1)*100,2);
    else
     pct_free := round((tot_free/tot_used)*100,2);
   end if;
   if c7rec.contents = 'TEMPORARY'
    then
       htp.tabledata( htf.bold( 'n/a' ),cattributes=>'bgcolor="#E0E0D0"');
       htp.tabledata( htf.bold( 'n/a'),cattributes=>'bgcolor="#E0E0D0"');
       htp.tabledata( htf.bold( 'Check Storage' ),cattributes=>'bgcolor="#E0E0D0"');
    else
      htp.tabledata( htf.bold( IMG_SIZE(vtot_free,'A') ),cattributes=>'bgcolor="#E0E0D0"');
     if pct_free < 10
      then
       htp.tabledata( htf.bold( to_char( pct_free )),cattributes=>'bgcolor="#C0C0A0"');
       htp.tabledata( htf.bold( 'Check Storage' ),cattributes=>'bgcolor="#E0E0D0"');
      else
       htp.tabledata( to_char( pct_free ),cattributes=>'bgcolor="#E0E0D0"');
       htp.tabledata( LNG3.ADM_TXT_486 ,cattributes=>'bgcolor="#E0E0D0"');
     end if;
   end if;
   htp.p( '<TD ' || 'bgcolor="#E0E0D0"' || '>' );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'File Id' ),cattributes=>'bgcolor="#C0C0A0"' || ' style="font-size: x-small;"');
     htp.tabledata( htf.bold( 'Datafile' ),cattributes=>'bgcolor="#C0C0A0"' || ' style="font-size: x-small;"');
     htp.tabledata( htf.bold( 'Autoextensible' ),cattributes=>'bgcolor="#C0C0A0"' || ' style="font-size: x-small;"');
     htp.tabledata( htf.bold( 'Current Size' ),cattributes=>'bgcolor="#C0C0A0"' || ' style="font-size: x-small;"');
     htp.tabledata( htf.bold( 'Status' ),cattributes=>'bgcolor="#C0C0A0"' || ' style="font-size: x-small;"');
    htp.tablerowclose;
    if c7rec.contents = 'TEMPORARY'
     then
      for c4trec in c4t(c7rec.tablespace_name) loop
      htp.tablerowopen;
       htp.tabledata( htf.bold( c4trec.file_id ),cattributes=>'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;"');
       htp.tabledata( c4trec.file_name,cattributes=>'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;"');
       htp.p( '<TD ' || 'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;">' );
        htp.p( c4trec.autoextensible || htf.nl || IMG_SIZE(c4trec.maxbytes,'A') || '-' || c4trec.increment_by );
       htp.p( '</TD>' );
       htp.tabledata( IMG_SIZE(c4trec.bytes,'A'),cattributes=>'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;"');
       htp.p( '<TD ' || 'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;">' );
        htp.p( c4trec.status || ':' || c4trec.enabled );
       htp.p( '</TD>' );
      htp.tablerowclose;
      end loop;
     else
      for c4rec in c4(c7rec.tablespace_name) loop
      htp.tablerowopen;
       htp.tabledata( htf.bold( c4rec.file_id ),cattributes=>'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;"');
       htp.tabledata( c4rec.file_name,cattributes=>'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;"');
       htp.p( '<TD ' || 'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;">' );
        htp.p( c4rec.autoextensible || htf.nl || IMG_SIZE(c4rec.maxbytes,'A') || '-' || c4rec.increment_by );
       htp.p( '</TD>' );
       htp.tabledata( IMG_SIZE(c4rec.bytes,'A'),cattributes=>'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;"');
       htp.p( '<TD ' || 'bgcolor="#E0E0D0"' || ' style="font-size: xx-small;">' );
        htp.p( c4rec.status || ':' || c4rec.enabled );
       htp.p( '</TD>' );
      htp.tablerowclose;
      end loop;
    end if;
   htp.tableclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 end loop;
 htp.tablerowopen;
   htp.tabledata( '&nbsp;',cattributes=>'bgcolor="#E0E0D0"');
   htp.tabledata( htf.bold( IMG_SIZE(gtot_used,'A') ),cattributes=>'bgcolor="#E0E0D0"');
   htp.tabledata( htf.bold( IMG_SIZE(gtot_free,'A') ),cattributes=>'bgcolor="#E0E0D0"');
   htp.tabledata( '&nbsp;',cattributes=>'bgcolor="#E0E0D0"' || ' colspan="3"');
 htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 htp.p(sqlerrm);
end storage_manager;
/
