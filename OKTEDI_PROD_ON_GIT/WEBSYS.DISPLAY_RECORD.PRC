CREATE OR REPLACE PROCEDURE WEBSYS."DISPLAY_RECORD" (table_name in varchar2 default 'booking', pk in varchar default null, pk_name in varchar2 default NULL, disp_opt varchar2 default 'C', fdir varchar2 default 'c:\temp', fname varchar2 default 'table_listing.txt')
as

  MULTI_RECORDS exception;
  PRAGMA EXCEPTION_INIT(MULTI_RECORDS, -1422);

  cursor c1 (t_name varchar2, t_owner varchar2) is
  select column_id, column_name, data_type
  from   user_tab_columns
  where  t_owner is null
         and table_name=upper(t_name)
  union all
  select column_id, column_name, data_type
  from   all_tab_columns
  where  t_owner is not null
         and owner = upper(t_owner)
		 and table_name=upper(t_name)
  order by column_id;

  parm1   owa.vc_arr;
  parm2   owa.vc_arr;
  pr_key  varchar2(100);
  buf     varchar2(32767);
  v_owner varchar2(100);
  v_table varchar2(100);
  v_rid   rowid;


  procedure disp_head(title in varchar2 default null) as

  hr   varchar2(1000);

  begin

   case upper(disp_opt)
   when 'H' then
     htp.htmlopen;
     htp.bodyopen(cattributes=>'style="font-family: calibri, verdana, arial;"');
     if title is not null
      then
       htp.header(3, title);
     end if;
     htp.tableopen(cattributes=>'cellpadding="5"');
   when 'F' then
     null;
   else
     if title is not null
      then
       dbms_output.put_line(rpad('=',length(title) + 4, '='));
       dbms_output.put_line('| ' || title || ' |');
       dbms_output.put_line(rpad('=',length(title) + 4, '=') || chr(10));
     end if;
   end case;
  end disp_head;

  procedure disp_foot as
  begin
   case upper(disp_opt)
   when 'H' then
     htp.tableclose;
     htp.bodyclose;
     htp.htmlclose;
   when 'F' then
     null;
   else
     null;
   end case;
  end disp_foot;

  procedure output_line(v_line_1 in varchar2, v_line_2 in varchar2 default null)
   is
  begin
   case upper(disp_opt)
    when 'H' then
      htp.tablerowopen;
        htp.tabledata(htf.bold(v_line_1), cattributes=>'style="font-family:Lucida Console; font-size:12px; border:1px solid #0000FF;"');
        -- htp.tabledata(v_line_2, cattributes=>'style="font-family:Lucida Console; font-size:8px; border:1px solid #FF0000;"');
        htp.p('<TD style="font-family:Lucida Console; font-size:12px; border:1px solid #FF0000;">');
          htp.p(v_line_2);
        htp.p('</TD>');
      htp.tablerowclose;
    else
      dbms_output.put_line(v_line_1 || replace(replace(v_line_2, '<B>Data type is', 'Data type is'), '- cannot display</B>', '- cannot display'));
    end case;
  end output_line;

  procedure output_msg(v_line in varchar2, v_attr in varchar2 default null)
   is
  begin
   case upper(disp_opt)
    when 'H' then
	  htp.strong(v_line, cattributes=>v_attr); htp.nl;
    else
      dbms_output.put_line(v_line);
    end case;
  end output_msg;

begin

pr_key := pk_name;
if instr(table_name, '.') > 0
 then
  v_table := substr(table_name, instr(table_name, '.')+1);
  v_owner := substr(table_name, 1, instr(table_name, '.')-1);
else
  v_table := table_name;
  v_owner := null;
end if;
begin
 for c1rec in c1 (v_table, v_owner) loop
   if c1%ROWCOUNT = 1 and pr_key is null then pr_key := c1rec.column_name; end if;
   parm1(c1%ROWCOUNT) := c1rec.column_name;
   case
   when c1rec.data_type in ('LONG','CHAR','NUMBER','VARCHAR2','ROWID') then
     execute immediate 'select ' || c1rec.column_name || ' from ' || table_name || ' where ' || pr_key || '= :1' into parm2(c1%ROWCOUNT) using pk;
   when c1rec.data_type='DATE' then
     execute immediate 'select to_char(' || c1rec.column_name || ', ''dd-MON-yyyy HH24:MI'') from ' || table_name || ' where ' || pr_key || '= :1' into parm2(c1%ROWCOUNT) using pk;
   when c1rec.data_type not in ('LONG','CHAR','NUMBER','DATE','VARCHAR2','ROWID') then
     parm2(c1%ROWCOUNT) := '<B>Data type is ' || c1rec.data_type || ' - cannot display</B>';
   else
     parm2(c1%ROWCOUNT) := '<B>Data type is ' || c1rec.data_type || ' - cannot display</B>';
   end case;
 end loop;
exception when MULTI_RECORDS then
 parm1.delete;
 parm2.delete;
 execute immediate 'select rowid from ' || table_name || ' where ' || pr_key || ' = :1 and rownum < 2' into v_rid using pk;

 for c1rec in c1 (v_table, v_owner) loop
   if c1%ROWCOUNT = 1 and pr_key is null then pr_key := c1rec.column_name; end if;
   parm1(c1%ROWCOUNT) := c1rec.column_name;
   case
   when c1rec.data_type in ('LONG','CHAR','NUMBER','VARCHAR2','ROWID') then
     execute immediate 'select ' || c1rec.column_name || ' from ' || table_name || ' where rowid = :1' into parm2(c1%ROWCOUNT) using v_rid;
   when c1rec.data_type='DATE' then
     execute immediate 'select to_char(' || c1rec.column_name || ', ''dd-MON-yyyy HH24:MI'') from ' || table_name || ' where  rowid = :1' into parm2(c1%ROWCOUNT) using v_rid;
   when c1rec.data_type not in ('LONG','CHAR','NUMBER','DATE','VARCHAR2','ROWID') then
     parm2(c1%ROWCOUNT) := '<B>Data type is ' || c1rec.data_type || ' - cannot display</B>';
   else
     parm2(c1%ROWCOUNT) := '<B>Data type is ' || c1rec.data_type || ' - cannot display</B>';
   end case;
 end loop;
end;

disp_head ('Listing for table ' || upper(table_name) || ', ' || pr_key || ' = ' || nvl(pk, parm2(1)));
if v_rid is not null
 then
  output_msg ('* More than 1 record found. Displaying first row<br>', 'style="color:red;"');
end if;

for j in parm1.first..parm1.last loop
  output_line(rpad(parm1(j), 30), parm2(j));
end loop;

disp_foot;

exception
when MULTI_RECORDS then
case upper(disp_opt)
 when 'H' then
  htp.p('<B>Error:</B> ' || upper(table_name) || ' returned more than one record');
else
  dbms_output.put_line('Error: ' || upper(table_name) || ' returned more than one record');
end case;
when others then
case upper(disp_opt)
 when 'H' then
  htp.p('Error: ' || dbms_utility.format_error_backtrace()); htp.nl;
  htp.p('     : ' || dbms_utility.format_error_stack()); htp.nl;
  for j in parm1.first..parm1.last loop
   htp.p('parm = ' || parm1(j)); htp.nl;
  end loop;
else
  dbms_output.put_line('Error: ' || dbms_utility.format_error_backtrace());
  dbms_output.put_line('     : ' || dbms_utility.format_error_stack());
  for j in parm1.first..parm1.last loop
   dbms_output.put_line('parm = ' || parm1(j));
  end loop;
end case;
end display_record;
/
