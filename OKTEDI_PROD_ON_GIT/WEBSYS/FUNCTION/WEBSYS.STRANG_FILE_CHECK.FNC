CREATE OR REPLACE function WEBSYS.strang_file_check(v_delivery integer, parm1 varchar2 default null) return varchar2
as

cursor c1(vname varchar2) is
 select mo.name, mv.name_default
 from   main_object mo, main_value mv
 where  mo.mid = mv.mid
        and mo.theme_type = 'STRANG_RECEIVALS_FOLDERS'
        and mo.name=vname
 ;
cursor c2(v_delno integer) is
 select count(*) from strang.detailrs where deliveryno = v_delno and hazard is not null;

c_i_fname    CONSTANT varchar2(100) := v_delivery || '_INVOICE.PDF';
c_h1_fname   CONSTANT varchar2(100) := v_delivery || '_MO41.PDF';
c_h2_fname   CONSTANT varchar2(100) := v_delivery || '_MSDS.PDF';

c1rec        c1%ROWTYPE;
file_list    glbx.myarray;
retval       integer;
v_tot        integer;
f_err        varchar2(150) := 'There are no <FOLDER_NAME> files attached to this Receivals Item';
f_err1       varchar2(150) := '<FOLDER_NAME> folder does not contain the file <FILE_NAME>';
v_msg        varchar2(4000);
file_ok      boolean;

begin
 -- 1. Check for invoice file
 open c1('INVOICE');
 fetch c1 into c1rec;
 close c1;
 retval := strangp.http_file_listing(glbx.extract_master_parameter('APACHE_RECEIVALS_DIR') || '/' || v_delivery || '/'  || c1rec.name, file_list);
 if nvl(retval, file_list.count) = 0
  then
   v_msg := v_msg || (case when length(v_msg) > 1 then '<br>' end) || replace(f_err, '<FOLDER_NAME>', c1rec.name);
 else
   file_ok := FALSE;
   for j in file_list.first..file_list.last loop
    if upper(file_list(j)) = c_i_fname then file_ok := TRUE; exit; end if;
   end loop;
   if not file_ok
    then
     v_msg := v_msg || (case when length(v_msg) > 1 then '<br>' end) || replace(replace(f_err1, '<FOLDER_NAME>', c1rec.name), '<FILE_NAME>', c_i_fname);
   end if;
 end if;

 -- 2. Check for Hazardous
 open c2(v_delivery);
 fetch c2 into v_tot;
 close c2;

 if v_tot > 0
  then
   -- 2a. Check for MO41
   open c1('MO41');
   fetch c1 into c1rec;
   close c1;

   retval := strangp.http_file_listing(glbx.extract_master_parameter('APACHE_RECEIVALS_DIR') || '/' || v_delivery || '/'  || c1rec.name, file_list);
   if nvl(retval, file_list.count) = 0
    then
     v_msg := v_msg || (case when length(v_msg) > 1 then '<br>' end) || replace(f_err, '<FOLDER_NAME>', c1rec.name);
   else
     file_ok := FALSE;
     for j in file_list.first..file_list.last loop
      if upper(file_list(j)) = c_h1_fname then file_ok := TRUE; exit; end if;
     end loop;
     if not file_ok
      then
       v_msg := v_msg || (case when length(v_msg) > 1 then '<br>' end) || replace(replace(f_err1, '<FOLDER_NAME>', c1rec.name), '<FILE_NAME>', c_h1_fname);
     end if;
   end if;
   -- 2a. Check for MSDS
   open c1('MSDS');
   fetch c1 into c1rec;
   close c1;
   retval := strangp.http_file_listing(glbx.extract_master_parameter('APACHE_RECEIVALS_DIR') || '/' || v_delivery || '/'  || c1rec.name, file_list);
   if nvl(retval, file_list.count) = 0
    then
     v_msg := v_msg || (case when length(v_msg) > 1 then '<br>' end) || replace(f_err, '<FOLDER_NAME>', c1rec.name);
   else
     file_ok := FALSE;
     for j in file_list.first..file_list.last loop
      if upper(file_list(j)) = c_h2_fname then file_ok := TRUE; exit; end if;
     end loop;
     if not file_ok
      then
       v_msg := v_msg || (case when length(v_msg) > 1 then '<br>' end) || replace(replace(f_err1, '<FOLDER_NAME>', c1rec.name), '<FILE_NAME>', c_h2_fname);
     end if;
   end if;

 end if;

 return(v_msg);
exception when others
 then
  return(null);
end strang_file_check;
/
