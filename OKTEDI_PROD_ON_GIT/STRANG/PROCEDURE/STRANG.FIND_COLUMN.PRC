CREATE OR REPLACE procedure STRANG.find_column( val in varchar2 )
as

 cursor c1 is select column_name,table_name from user_tab_columns where data_type = 'VARCHAR2' order by table_name,column_name;
 cursor c2 is select column_name,table_name from user_tab_columns where data_type in ('FLOAT','NUMBER','INTEGER') order by table_name,column_name;

 nmb		number;
 tot		integer;
 foundrec	boolean;

begin
 foundrec := FALSE;
 for c1rec in c1 loop
  tot := NULL;
  execute immediate 'select count(1) from ' || c1rec.table_name || ' where ' || c1rec.column_name || ' = ''' || val || '''' into tot;
  if nvl(tot,0) > 0
   then
    foundrec := TRUE;
    dbms_output.put_line( c1rec.table_name || '.' || c1rec.column_name || '-' || to_char(tot) );
  end if;
 end loop;

 begin
  nmb := to_number( val );
  for c2rec in c2 loop
  tot := NULL;
  execute immediate 'select count(1) from ' || c2rec.table_name || ' where ' || c2rec.column_name || ' = ''' || val || '''' into tot;
  if nvl(tot,0) > 0
   then
    foundrec := TRUE;
    dbms_output.put_line( c2rec.table_name || '.' || c2rec.column_name || '-' || to_char(tot) );
  end if;
  end loop;
 exception
  when others then null;
 end;
 if not foundrec
  then
   for c1rec in c1 loop
    tot := NULL;
    execute immediate 'select count(1) from ' || c1rec.table_name || ' where ' || c1rec.column_name || ' like ''%' || val || '%''' into tot;
    if nvl(tot,0) > 0
     then
      foundrec := TRUE;
      dbms_output.put_line( c1rec.table_name || '.' || c1rec.column_name || '-' || to_char(tot) );
    end if;
   end loop;
 end if;
 if not foundrec then dbms_output.put_line( 'No Tables found that match the value ' || val ); end if;

end find_column;

/
