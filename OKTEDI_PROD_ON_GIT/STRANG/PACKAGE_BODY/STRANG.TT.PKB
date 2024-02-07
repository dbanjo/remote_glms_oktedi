CREATE OR REPLACE package body STRANG.tt
as

 vlast		varchar2(32767);
 lastrepid 	integer;

 function find_primary_row( c1rec in STRANG.HOT_SYNC%ROWTYPE, pk_col1 in varchar2, pk_col2 in varchar2, debug in varchar2, dblink in varchar2 default NULL, exit_clause out varchar2 ) return rowid;
 procedure perform_remote_update_instead( fl in out rtable, c1rec in STRANG.HOT_SYNC%ROWTYPE, first_repid integer, repid integer, last_rowid in rowid, debug in varchar2, dblink in varchar2 );
 procedure write_sqlstmt( fl in out rtable, repid in integer, bfr in varchar2, xforce in boolean default false, dc in date default null, lrid in rowid default null, tname in varchar2 default null, stm in varchar2 default null );

procedure get_records( mt in out ttable, mxid integer, sname varchar2  )
as

cursor c1(mxid integer, sname varchar2) is
 select *
 from strang.replication
 where replication_id > nvl(mxid,0) and
      site <> sname
      order by replication_id;

j	integer;

begin

for c1rec in c1(mxid,sname) loop
 j := c1%ROWCOUNT;
 mt(j) := c1rec;
end loop;

end get_records;

procedure push_data( mt in out ttable, fl in out rtable, result out varchar2 )
 as

  cursor c3(tname varchar2) is select * from strang.hot_sync where table_name = tname;

 TYPE REPCurTyp IS REF CURSOR;  -- define weak REF CURSOR type

 rep_cv   	REPCurTyp;
 r_rec		STRANG.REPLICATION%ROWTYPE;
 l_rec		STRANG.REPLICATION%ROWTYPE;
 c1rec		STRANG.HOT_SYNC%ROWTYPE;
 last_table	STRANG.HOT_SYNC%ROWTYPE;
 trec		char(1);
 change_rec	boolean;
 check_rowid	rowid;
 first_repid	integer;
 cols		varchar2(32767);
 vals		varchar2(32767);
 last_rowid	rowid;
 u_rowid	rowid;
 ux_rowid	rowid;
 primary_rowid	rowid;
 ctr		integer;
 exit_clause	varchar2(32767);
 x_exit_clause	varchar2(32767);

 begin

  --strang.global_site.site_name := c1rec.site;
  cols := NULL;
  vals := NULL;
  last_rowid := NULL;
  u_rowid := NULL;
  ctr := 0;
  if not mt.exists(1) then return; end if;

  begin
   for j in mt.first..mt.last loop
    begin
     open c3(mt(j).table_name);
     fetch c3 into c1rec;
     close c3;

     -- Insert
     if mt(j).change_type = 'I'
      then
       if last_rowid is null
        then
         last_rowid := mt(j).row_changed;
         first_repid := mt(j).replication_id;
         last_table := c1rec;
       end if;
       if mt(j).row_changed <> last_rowid
        then
         -- Check if this row already exists
         check_rowid := NULL;
         check_rowid := find_primary_row( last_table,mt(j-1).pk_col1,mt(j-1).pk_col2,null,null,exit_clause);
         if check_rowid is null
          then
           write_sqlstmt( fl,  mt(j-1).replication_id,  'insert into strang.' || last_table.table_name || ' (' || substr(cols,2) || ') values (' || substr(vals,2) || ')' );
          else
           perform_remote_update_instead( fl, last_table, first_repid, mt(j-1).replication_id, check_rowid, null, last_table.dblink );
         end if;

         exit_clause := NULL;
         cols := NULL;
         vals := NULL;
         ctr := ctr + 1;
         first_repid := mt(j).replication_id;
         last_table := c1rec;
       end if;

       cols := cols || ',' || mt(j).column_name;
       if mt(j).data_type = 'D'
        then
         vals := vals || ',' || 'to_date(''' || to_char(mt(j).new_date,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ')';
        else
         vals := vals || ',' || '''' || replace(replace(replace(mt(j).new_value,'''',''''''),chr(10),'<BR>'),chr(13),'<BR>') || '''';
       end if;
       last_rowid := mt(j).row_changed;

     -- Update
     elsif mt(j).change_type = 'U'
      then
       -- Check to see if an Insert needs to be done, if it does maybe an update needs to be done instead
       if cols is not null and vals is not null
        then
          -- Check if this row already exists
          check_rowid := NULL;
          check_rowid := find_primary_row( last_table,mt(j-1).pk_col1,mt(j-1).pk_col2,null,null,exit_clause);
          if check_rowid is null
           then
              write_sqlstmt( fl,  mt(j-1).replication_id,  'insert into strang.' || last_table.table_name || ' (' || substr(cols,2) || ') values (' || substr(vals,2) || ')' );
             else
              perform_remote_update_instead( fl, last_table, first_repid, mt(j-1).replication_id, check_rowid, null, last_table.dblink );
           end if;
          ctr := ctr + 1;
          cols := NULL;
          vals := NULL;
          last_rowid := NULL;
          last_table := c1rec;
       end if;

       change_rec := TRUE;
       last_rowid := NULL;
       cols := NULL;
       vals := NULL;

       if mt(j).row_changed = u_rowid
        then
         mt(j).row_changed := ux_rowid;
         exit_clause := x_exit_clause;
        else
         u_rowid := mt(j).row_changed;
         mt(j).row_changed := find_primary_row( c1rec,mt(j).pk_col1,mt(j).pk_col2,null,null, exit_clause);
         ux_rowid := mt(j).row_changed;
         x_exit_clause := exit_clause;
       end if;

       if change_rec
        then
         if mt(j).data_type = 'D' -- Date
          then
           if mt(j).row_changed is null
           then
            write_sqlstmt( fl,  mt(j).replication_id,
                                'update strang.' || c1rec.table_name || ' set ' || mt(j).column_name ||
                                ' = ' || 'to_date(''' || to_char(mt(j).new_date,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ')' ||
                                ' where ' || replace(replace(exit_clause,':1','''' || mt(j).pk_col1 || ''''),':2','''' || mt(j).pk_col2 || '''')  );
           else
            -- Check if the row has already been updated. If it has then don't do this date check as the timestamp is now wrong.
            write_sqlstmt( fl,  mt(j).replication_id,
                                  'update strang.' || c1rec.table_name || ' set ' || mt(j).column_name ||
                                  ' = ' || 'to_date(''' || to_char(mt(j).new_date,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ')' ||
                                  ' where rowid = ''' || mt(j).row_changed ||
                                  ''' and  to_date(''' || to_char(mt(j).date_changed,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') >= nvl(date_modified,sysdate-100)',false,mt(j).date_changed,mt(j).row_changed, 'strang.' || c1rec.table_name, ' and  to_date(''' || to_char(mt(j).date_changed,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') >= nvl(date_modified,sysdate-100)' );
           end if;

          else

           if mt(j).row_changed is null
           then
            write_sqlstmt( fl,  mt(j).replication_id,
                                'update strang.' || c1rec.table_name || ' set ' || mt(j).column_name ||
                                ' = ''' || replace(mt(j).new_value,'''','''''') ||
                                ''' where ' || replace(replace(exit_clause,':1','''' || mt(j).pk_col1 || ''''),':2','''' || mt(j).pk_col2 || '''')  );
           else
            -- Check if the row has already been updated. If it has then don't do this date check as the timestamp is now wrong.
              write_sqlstmt( fl,  mt(j).replication_id,
                                  'update strang.' || c1rec.table_name || ' set ' || mt(j).column_name ||
                                  ' = ''' || replace(mt(j).new_value,'''','''''') || ''' where rowid = ''' || mt(j).row_changed ||
                                  ''' and  to_date(''' || to_char(mt(j).date_changed,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') >= nvl(date_modified,sysdate-100)',false,mt(j).date_changed,mt(j).row_changed, 'strang.' || c1rec.table_name, ' and  to_date(''' || to_char(mt(j).date_changed,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') >= nvl(date_modified,sysdate-100)' );
           end if;
         end if;
         ctr := ctr + 1;
       end if;

     -- Delete
     elsif mt(j).change_type = 'D'
      then

       -- Check if the last command was an insert
       if cols is not null and vals is not null
        then
          -- Check if this row already exists
          check_rowid := NULL;
          check_rowid := find_primary_row( last_table,mt(j-1).pk_col1,mt(j-1).pk_col2,null,null,exit_clause);
          if check_rowid is null
           then
            write_sqlstmt( fl,  mt(j-1).replication_id, 'insert into strang.' || last_table.table_name || ' (' || substr(cols,2) || ') values (' || substr(vals,2) || ')' );
           else
            perform_remote_update_instead( fl, last_table, first_repid, mt(j-1).replication_id, check_rowid, null, last_table.dblink );
           end if;
          ctr := ctr + 1;
          cols := NULL;
          vals := NULL;
          last_rowid := NULL;
          last_table := c1rec;
       end if;

       last_rowid := NULL;
       cols := NULL;
       vals := NULL;
       primary_rowid := find_primary_row( c1rec,mt(j).pk_col1,mt(j).pk_col2,null,null,exit_clause);
       if primary_rowid is not null
        then
         write_sqlstmt( fl,  mt(j).replication_id, 'delete from strang.' || c1rec.table_name || ' where rowid = ''' || primary_rowid || '''' );
        else
         write_sqlstmt( fl,  mt(j).replication_id, 'delete from strang.' || c1rec.table_name || ' where ' || replace(replace(exit_clause,':1','''' || mt(j).pk_col1 || ''''),':2','''' || mt(j).pk_col2 || '''') );
       end if;
       ctr := ctr + 1;
     end if;

   exception
    when others
     then
      result := result || sqlerrm;
   end;
  end loop;

  begin
   if nvl(mt.last,0) = 0
    then
     write_sqlstmt( fl, null, null, TRUE );
     return;
   end if;
   exception
    when
     others
      then write_sqlstmt( fl, null, null, TRUE );
      return;
   end;

  if cols is not null and vals is not null
   then
    -- Check if this row already exists
    check_rowid := NULL;
    check_rowid := find_primary_row( last_table,mt(mt.last).pk_col1,mt(mt.last).pk_col2,null,null,exit_clause);
    if check_rowid is null
     then
      write_sqlstmt( fl,  mt(mt.last).replication_id, 'insert into strang.' || last_table.table_name || ' (' || substr(cols,2) || ') values (' || substr(vals,2) || ')' );
     else
      perform_remote_update_instead( fl, last_table, first_repid, mt(mt.last).replication_id, check_rowid, null, c1rec.dblink );
    end if;
    ctr := ctr + 1;
  end if;

  write_sqlstmt( fl, null, null, TRUE );

 exception
   when others then
    result := result || sqlerrm;
  end;

 end push_data;

 function find_primary_row( c1rec in STRANG.HOT_SYNC%ROWTYPE, pk_col1 in varchar2, pk_col2 in varchar2, debug in varchar2, dblink in varchar2 default NULL, exit_clause out varchar2 )
  return rowid
 as

  ret_rowid	rowid;
  str		varchar2(4000);
 begin
 exit_clause := NULL;
 if dblink is null
  then
   if c1rec.pk_col2 is null
    then
     execute immediate
      'select rowid from strang.' || c1rec.table_name || ' where ' || c1rec.pk_col1 || ' = :1 and rownum < 2'
     into ret_rowid
     using pk_col1;
    else
     if pk_col2 is null
      then
       str := c1rec.pk_col2 || ' IS NULL';
      else
       str := 'nvl(' || c1rec.pk_col2 || ',''0'') = nvl(:2,''0'')';
     end if;
     if debug = 'T' then htp.p( to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || '-' || 'Pull - Find Primary : ' || 'select rowid from strang.' || c1rec.table_name || ' where ' || c1rec.pk_col1 || ' = :1 and ' || str || '-' || pk_col1 || '+' || pk_col2); htp.nl; end if;
     if pk_col2 is null
      then
       execute immediate 'select rowid from strang.' || c1rec.table_name || ' where ' || c1rec.pk_col1 || ' = :1 and rownum < 2 and ' || str into ret_rowid using pk_col1;
      else
       execute immediate 'select rowid from strang.' || c1rec.table_name || ' where ' || c1rec.pk_col1 || ' = :1 and rownum < 2 and ' || str into ret_rowid using pk_col1, pk_col2;
     end if;
   end if;

 else

   if c1rec.pk_col2 is null
    then
     execute immediate
      'select rowid from strang.' || c1rec.table_name || ' where ' || c1rec.pk_col1 || ' = :1 and rownum < 2'
     into ret_rowid
     using pk_col1;
   else
     if pk_col2 is null
      then
       str := c1rec.pk_col2 || ' IS NULL';
      else
       str := 'nvl(' || c1rec.pk_col2 || ',''0'') = nvl(:2,''0'')';
     end if;
     if debug = 'T' then htp.p( 'Push - Find Primary : ' || 'select rowid from strang.' || c1rec.table_name || ' where ' || c1rec.pk_col1 || ' = :1 and ' || str || '-' || pk_col1 || '+' || pk_col2 ); htp.nl; end if;
     if pk_col2 is null
      then
       execute immediate 'select rowid from strang.' || c1rec.table_name || ' where ' || c1rec.pk_col1 || ' = :1 and rownum < 2 and ' || str into ret_rowid using pk_col1;
      else
       execute immediate 'select rowid from strang.' || c1rec.table_name || ' where ' || c1rec.pk_col1 || ' = :1 and rownum < 2 and ' || str into ret_rowid using pk_col1, pk_col2;
     end if;
   end if;
 end if;

 if debug = 'T' then htp.bold( to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || '-' || 'Found Rowid:' || rowidtochar(ret_rowid) ); htp.nl; end if;
 return( ret_rowid );
 exception when others
 then
  if debug = 'T'
   then
    htp.bold( to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || '-' || '..Rowid not found using PK instead:' || sqlerrm ); htp.nl;
    htp.bold( to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || '-' || '..' || c1rec.table_name || '-' || c1rec.pk_col1 || '-' || c1rec.pk_col2 ); htp.nl;
    htp.bold( to_char(sysdate,'DD-MON-YYYY HH24:MI:SS') || '-' || '..Exit Clause: ' || exit_clause ); htp.nl;
  end if;
  if str is null
   then
    exit_clause := c1rec.pk_col1 || ' = :1 ';
   else
    exit_clause := c1rec.pk_col1 || ' = :1 and ' || str;
  end if;
  return( NULL );
 end find_primary_row;

 procedure perform_remote_update_instead( fl in out rtable, c1rec in STRANG.HOT_SYNC%ROWTYPE, first_repid integer, repid integer, last_rowid in rowid, debug in varchar2, dblink in varchar2 )
 as

  TYPE REPCurTyp IS REF CURSOR;  -- define weak REF CURSOR type
  rep_cv4   	REPCurTyp;
  r_rec		STRANG.REPLICATION%ROWTYPE;
  change_rec	boolean;
  setcl		varchar2(32767);

 begin

   setcl := NULL;
   OPEN rep_cv4 FOR
     'SELECT replication_id,column_name,change_type,old_value,new_value,row_changed,data_type,old_date,new_date,date_changed,pk_col1,pk_col2 FROM strang.replication where replication_id >=' || first_repid ||
     ' and table_name=''' || c1rec.table_name || ''' and site <> ''PRIMARY'' and replication_id < ' || repid  || ' and change_type=''I'' order by replication_id';

   loop
     FETCH rep_cv4 INTO r_rec.replication_id,r_rec.column_name,r_rec.change_type,r_rec.old_value,r_rec.new_value,r_rec.row_changed,r_rec.data_type,r_rec.old_date,r_rec.new_date,r_rec.date_changed,r_rec.pk_col1,r_rec.pk_col2;
     EXIT WHEN rep_cv4%NOTFOUND;

     change_rec := TRUE;
     if change_rec
      then
       if r_rec.data_type = 'D'
        then
         setcl := setcl || ',' || r_rec.column_name || ' = ' || 'to_date(''' || to_char(r_rec.new_date,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') ' ;

        else
         setcl := setcl || ',' ||  r_rec.column_name || ' = ''' || replace(replace(replace(r_rec.new_value,'''',''''''),chr(10),'<BR>'),chr(13),'<BR>') || ''' ';
       end if;
     end if;

   end loop;
  CLOSE rep_cv4;
  write_sqlstmt( fl,  r_rec.replication_id,
                      'update strang.' || c1rec.table_name || ' set ' || substr(setcl,2) ||
                      ' where rowid = ''' || last_rowid ||
                      ''' and  to_date(''' || to_char(r_rec.date_changed,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') >= nvl(date_modified,sysdate-100)',false,r_rec.date_changed,r_rec.row_changed, 'strang.' || c1rec.table_name,' and  to_date(''' || to_char(r_rec.date_changed,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') >= nvl(date_modified,sysdate-100)' );

 end perform_remote_update_instead;

 procedure write_sqlstmt( fl in out rtable, repid in integer, bfr in varchar2, xforce in boolean default false, dc in date default null, lrid in rowid default null, tname in varchar2 default null, stm in varchar2 default null )
 as

  x1	varchar2(100);
  x2	varchar2(100);
  y1	integer;
  y2    integer;
  z1	integer;
  z2    integer;

 begin
  if (bfr is null or repid is null) and not xforce then return; end if;
  if xforce and (vlast is not null) and (lastrepid is not null)
   then
    fl(nvl(fl.last+1,0)) := ( '[' || lastrepid || ']' || vlast );
    vlast := NULL;
    if dc is not null
     then
      fl(nvl(fl.last+1,0)) := ( '[' || lastrepid || ']' || 'update ' || tname || ' set date_modified = to_date(''' || to_char(dc,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') where rowid = ''' || lrid || '''' || stm);
    end if;
    return;
  end if;

  if upper(substr(bfr,1,6)) = 'UPDATE'
   then
    if vlast is null then vlast := bfr; lastrepid := repid; return; end if;

    -- See if the last needs to be merged in
    --htp.p( 'Z1:' || substr(vlast,1,instr(vlast,' ',1,2)) ); htp.nl;
    --htp.p( 'Z2:' || substr(bfr,1,instr(bfr,' ',1,2)) ); htp.nl;
    if substr(vlast,1,instr(vlast,' ',1,2)) = substr(bfr,1,instr(bfr,' ',1,2))
     then
      null;
     else
      fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || vlast );
      lastrepid := repid;
      vlast := bfr;
      if dc is not null
       then
        fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || 'update ' || tname || ' set date_modified = to_date(''' || to_char(dc,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') where rowid = ''' || lrid || '''' || stm);
      end if;
      return;
    end if;

    -- See if it is the same rowid
    y1 := instr(vlast,'where rowid =');
    y2 := instr(bfr,'where rowid =');
    -- if there is no rowid then the statements cannot be merged. just dump it out as is
    if nvl(y1,0) = 0 or nvl(y2,0) = 0
     then
      fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || vlast );
      lastrepid := repid;
      vlast := bfr;
      if dc is not null
       then
        fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || 'update ' || tname || ' set date_modified = to_date(''' || to_char(dc,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') where rowid = ''' || lrid || '''' || stm);
      end if;
      return;
    end if;

    z1 := instr(vlast,'''',y1,2);
    z2 := instr(bfr,'''',y2,2);
    --htp.p( 'X1:' || substr(vlast,y1,(z1-y1)) ); htp.nl;
    --htp.p( 'X2:' || substr(bfr,y2,(z2-y2)) ); htp.nl;
    if substr(vlast,y1,(z1-y1)) = substr(bfr,y2,(z2-y2))
     then
      null;
     else
      fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || vlast );
      lastrepid := repid;
      vlast := bfr;
      if dc is not null
       then
        fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || 'update ' || tname || ' set date_modified = to_date(''' || to_char(dc,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') where rowid = ''' || lrid || '''' || stm);
      end if;
      return;
    end if;

    -- Look to see if the column name is already there
    y2 := instr(bfr,'set');
    z2 := instr(bfr,'where rowid =');
    x1 := substr(bfr,y2+3,(z2-(y2+3)));
    if instr(vlast,trim(substr( x1, 1, instr(x1,'=')-1))) > 0
     then
      fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || vlast );
      lastrepid := repid;
      vlast := bfr;
      if dc is not null
       then
        fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || 'update ' || tname || ' set date_modified = to_date(''' || to_char(dc,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') where rowid = ''' || lrid || '''' || stm);
      end if;
      return;
    end if;

    -- Merge them
    y1 := instr(vlast,'set');
    y2 := instr(bfr,'set');
    z1 := instr(vlast,'where rowid =');
    z2 := instr(bfr,'where rowid =');
    vlast := substr(vlast,1,z1-1) || ',' || substr(bfr,y2+3,(z2-(y2+3))) || ' ' || substr(vlast,z1);
    lastrepid := repid;

    /*
    htp.p( 'Y0:' || bfr ); htp.nl;
    htp.p( 'Y1:' || substr(vlast,1,z1-1) ); htp.nl;
    htp.p( 'Y2:' || substr(bfr,y2+3,(z2-(y2+3)) ) ); htp.nl;
    htp.p( 'Y3:' || substr(vlast,z1) ); htp.nl;
    htp.p( 'Y4:' || vlast ); htp.nl;
    */

   else

    if vlast is not null then fl(nvl(fl.last+1,0)) := ( '[' || greatest(nvl(lastrepid,0),nvl(repid,0)) || ']' || vlast ); end if;
    lastrepid := repid;
    if repid is not null then fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || bfr ); end if;
    vlast := NULL;
    if dc is not null
     then
      fl(nvl(fl.last+1,0)) := ( '[' || repid || ']' || 'update ' || tname || ' set date_modified = to_date(''' || to_char(dc,'DD-MON-YYYY HH24:MI:SS') || ''',' || '''' || 'DD-MON-YYYY HH24:MI:SS' || '''' || ') where rowid = ''' || lrid || '''' || stm);
    end if;

  end if;

 end write_sqlstmt;

--
-- This Procedure is called from strangz.run_stmtsx
--

procedure mass_run(fl in rtable, last_repid out integer, result out varchar2, errs in out rtable )
as

 flx		UTL_FILE.FILE_TYPE;
 bfr		varchar2(32767);
 stmts		varchar2(32767);
 x		integer;
 good_ctr	integer;
 bad_ctr	integer;
 norows_ctr	integer;

begin

 good_ctr := 0;
 bad_ctr := 0;
 norows_ctr := 0;
 if not fl.exists(1) then return; end if;

 for j in fl.first..fl.last loop

  begin
   -- utl_file.get_line( fl, bfr );
   bfr := fl(j);
   x := instr( bfr, ']' );
   stmts := substr(bfr,x+1);
   stmts := replace(stmts,'<BR>',chr(10));
   last_repid := substr(bfr,2,x-2);

   if stmts is not null
    then
     begin
      execute immediate stmts;
      good_ctr := good_ctr + 1;
      if sql%ROWCOUNT = 0
       then
        norows_ctr := norows_ctr + 1;
      end if;
     exception
      when others
       then
        bad_ctr := bad_ctr + 1;
        errs(bad_ctr) := substr(bfr,1,x) || '-' || sqlerrm;
     end;
   end if;

  exception
   when others
    then
     /*
      Does not work in a remote procedure call
      flx := utl_file.fopen( websys.glbx.extract_master_parameter('REPORTS_DIRECTORY'), 'push_errors.txt', 'a', 32767 );
      utl_file.put_line( flx, bfr );
      utl_file.fclose(flx);
     */
     null;
  end;

 end loop;

 result :=  htf.nl ||
            htf.bold( 'Number of Statements Correctly Executed: ' || good_ctr ) ||
            htf.nl ||
            htf.bold( 'Number of Statements Correctly Executed but did not process any rows: ' || norows_ctr ) ||
            htf.nl ||
            htf.bold( 'Number of Statements that did not run: ' || bad_ctr );

end mass_run;

end tt;

/
