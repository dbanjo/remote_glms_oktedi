CREATE OR REPLACE procedure WEBSYS.accept_ingest_convoy_file(infile varchar2, action varchar2, batchno out number)
as
cursor c1(v_file varchar2) is select * from apache_ows_content where name = v_file;

cursor c2(v_operator varchar2) 
is
select *
  from strang.lov
 where lov_name = 'OPERATORS'
   and rtrim(ltrim(code)) = case when v_operator = 'BRONTY PORA' then 'BRONTHY PORA SIPRA' else v_operator end;

cursor c3(v_truck varchar2) 
is
select *
  from strang.lov
 where lov_name = 'TRUCKS'
   and (code = v_truck or (v_truck is null));
   
cursor c4(v_trailer varchar2) 
is
select *
  from strang.lov
 where lov_name = 'TRAILERS'
   and (code = v_trailer or ( v_trailer is null));
   
cursor c5(v_container varchar2) 
is
select m.*, s.shipname, s.voy as voyage
  from strang.movements m, strang.ships_airway s
 where m.movement_no =  v_container
  -- and m.current_location = 'KUI'
   and m.current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA' and substr(code,1,1)='K')
   and nvl(m.io,'I') = 'I'
   and nvl(s.estdepart,sysdate) >= (sysdate - 240) 
   and m.convoy_id is null
   and m.local_ship_id = s.ship_id
   and m.complete <> 'H'
   order by s.estdepart desc, m.dispatch_date desc; 
   
cursor c6(v_type varchar2) 
is
select *
  from strang.lov
 where lov_name = 'UNCTNTAB'
   and cola = v_type;
   
cursor c7
is
select string_val, sheet_name
 from table( as_read_xlsx.read(
  (select blob_content from apache_ows_content where name = infile )))
     where upper(sheet_nr) = 3
      and cell = 'A1'; 
 
cursor c8 (v_index integer)
is
select string_val
 from table( as_read_xlsx.read(
  (select blob_content from apache_ows_content where name = infile )))
     where upper(sheet_nr) = 3
      and col_nr = 1
      and row_nr = v_index; 
      
cursor c9(v_trailer varchar2, v_fuel_capacity varchar2) 
is
select *
  from strang.lov
 where lov_name = 'TRAILERS'
   and (code = v_trailer or (v_trailer is null))
   and replace(colc,',','') = replace(v_fuel_capacity,',','');
   

v_batch               number;
c1rec                 c1%rowtype;
c2rec                 c2%rowtype;
c3rec                 c3%rowtype;
c4rec                 c4%rowtype;
c5rec                 c5%rowtype;
c6rec                 c6%rowtype;
c7rec                 c7%rowtype;
c8rec                 c8%rowtype;
c9rec                 c9%rowtype;
v_clb                 clob;
v_array               owa.vc_arr;
line_array            glbx.myarray;
stp                   varchar2(1000);
-- c_rec              strang.po_pool%ROWTYPE;
-- c_rec                 strang.convoy_staging%rowtype;
msg                   varchar2(4000);
r_ctr                 integer;
v_count               integer;
v_title1              varchar2(500);
v_title2              varchar2(500);
v_week                integer;
v_day                 varchar2(50);
v_valid_day           varchar2(1);
v_stg_convoy_dt       varchar2(50);
v_convoy_dt           date;
v_valid_convoy_dt     varchar2(1);
v_load                integer;
v_valid_load_number   varchar2(1);
v_operator            varchar2(500);
v_truck               varchar2(100);
v_trailer             varchar2(100);
v_container_type      varchar2(50);
v_cargo_desc          varchar2(1000);
v_tot_weight          number(10,4);
record_linehaul       strang.stg_linehaul_plan%rowtype;
v_container           varchar2(500);
a_container           owa.vc_arr default glbx.empty_array;
a_shipname            owa.vc_arr default glbx.empty_array;
a_voyage              owa.vc_arr default glbx.empty_array;
a_container_valid     owa.vc_arr default glbx.empty_array;
cnt                   integer;
v_type                varchar2(500);
a_type                owa.vc_arr default glbx.empty_array;
a_type_valid          owa.vc_arr default glbx.empty_array;
v_type_valid          varchar2(1);
v_description         varchar2(500);
a_description         owa.vc_arr default glbx.empty_array;
v_weight              varchar2(500);
n_weight              number(10,4);
a_weight              owa.vc_arr default glbx.empty_array;
v_tare                varchar2(500);
n_tare                number(10,4);
a_tare                owa.vc_arr default glbx.empty_array;
v_convoy_type         varchar2(500);
v_sheet_number        integer;
v_convoy_day_date     varchar2(500);
v_fuel_tanker_details varchar2(500);
v_fuel_capacity       varchar2(500);
v_record              integer := 0;
a_iso_container_type  owa.vc_arr default glbx.empty_array;
v_suffix              varchar2(1);

-- Start inline procedures
procedure conv_blob_clob( blb in blob, clb in out clob )
as

 r_buffer     raw(32767);
 v_buffer     varchar2(32767);
 c_imgchunk   integer;
 v_imgchunk   integer;
 v_count      integer;

begin
-- convert from blob to clob
dbms_lob.createtemporary(clb,TRUE);
c_imgchunk := 32767;
v_imgchunk := 32767;
v_count := 0;
begin
 loop
   dbms_lob.read(blb,v_imgchunk,(v_count*c_imgchunk)+1,r_buffer);
   v_count := v_count + 1;
   v_buffer := utl_raw.cast_to_varchar2( r_buffer );
   if v_buffer is null then exit; end if;
   dbms_lob.writeappend(clb,length(v_buffer), v_buffer);
 end loop;
exception when others then null;
end;
end conv_blob_clob;


begin
 
 v_count := 1;
 open c1(infile);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
    close c1;
    ingest_convoy_excel_file('File not uploaded: ' || infile);
    return;
 else
    close c1;
    -- msg := 'File: ' || c1rec.name || ', type: ' || c1rec.mime_type || ', size: ' || c1rec.doc_size || '<br>';
    conv_blob_clob(c1rec.blob_content, v_clb); 

    --delete from apache_ows_content where name = infile; commit;
    if dbms_lob.getlength(v_clb) = 0
    then
    --  ingest_hg_csv_file('Zero-length file: ' || infile);
       ingest_convoy_excel_file('Zero-length file: ' || infile);
       return;
    end if;
 
 end if;
 
 if nvl( v_batch,0) = 0 then
         select strang.s_convoy_plans.nextval into v_batch from dual;
         batchno := v_batch;
 end if;
   
 v_sheet_number := 1;
 for rec_linehaul in   (select *
                           from table( as_read_xlsx.read(
                           (select blob_content from apache_ows_content where name = infile )))
                                where upper(sheet_nr) = 2) loop
 
     if v_convoy_type is null then
        v_convoy_type := upper(rec_linehaul.sheet_name);
        v_convoy_type := replace(v_convoy_type,'DAILY CARGO','');
        v_convoy_type := replace(v_convoy_type,'-','');
        v_convoy_type := ltrim(rtrim(v_convoy_type));
     end if;
    
     if  v_count = 1 and rec_linehaul.cell = 'A1' then
        v_title1 := rec_linehaul.string_val;
        v_week  := TO_NUMBER(substr(rec_linehaul.string_val,instr(rec_linehaul.string_val,'WEEK',1) +4));
     end if;
     
     --  glbx.dbg('Title: '||v_title1);
     --  glbx.dbg('rec_linehaul.col_nr before: '||rec_linehaul.col_nr);    
     if rec_linehaul.row_nr > 2 and NVL(rec_linehaul.col_nr,99) = 1 and (rec_linehaul.cell is not null and substr(rec_linehaul.cell,1,1) = 'A') AND (rec_linehaul.string_val is not null and  NVL(rec_linehaul.string_val,'XXX') <> 'DAY') then
        
         if upper(rec_linehaul.string_val) in ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') then
            record_linehaul.valid_convoy_day  := 'Y';
         else
            record_linehaul.valid_convoy_day  := 'N';
         end if;
         
         
         record_linehaul.convoy_day := rec_linehaul.string_val;
         v_day := rec_linehaul.string_val;
         v_valid_day := record_linehaul.valid_convoy_day;
         
     --    glbx.dbg('Convoy day: '||record_linehaul.convoy_day);
         
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 2 and (rec_linehaul.cell is not null and substr(rec_linehaul.cell,1,1) = 'B') AND (rec_linehaul.date_val is not null) then  
        --  v_stg_convoy_dt 
        begin v_convoy_dt  := rec_linehaul.date_val; exception when others then null; end;
        if v_stg_convoy_dt is not null then
           v_stg_convoy_dt := v_convoy_dt;
        end if;
        -- glbx.dbg('v_day '||to_char(v_day) );
        -- glbx.dbg('to_char(v_convoy_dt, DAY '||to_char(v_convoy_dt, 'DAY') );
        if upper(v_day) = to_char(v_convoy_dt, 'fmDAY') then 
           record_linehaul.valid_convoy_date := 'Y';
        else
           record_linehaul.valid_convoy_date := 'N';
           record_linehaul.valid_convoy_day  := 'N';
           v_valid_day := 'N';
        end if;
        
        if not (record_linehaul.valid_convoy_date =  'Y' and websys.strangp.week_of_year(v_stg_convoy_dt) = v_week) then
            record_linehaul.valid_convoy_date := 'N';
            record_linehaul.valid_convoy_day  := 'N';
            v_valid_day := 'N';
        end if;
        
        v_valid_convoy_dt := record_linehaul.valid_convoy_date;
        record_linehaul.convoy_date := v_convoy_dt;
        
       -- glbx.dbg('CONVOY DATE: '||to_char(record_linehaul.convoy_date));
       
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 3 and substr(rec_linehaul.cell,1,1) = 'C' AND NVL(rec_linehaul.string_val,'XXX') <> 'LOAD' then  
        begin v_load  := to_number(rec_linehaul.number_val); exception when others then null; end;
        
        if v_load between 1 and 100 then 
           record_linehaul.valid_load_number := 'Y';
        else
           record_linehaul.valid_load_number := 'N';
        end if;
        
        record_linehaul.load_number := v_load ;
     
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 4 and substr(rec_linehaul.cell,1,1) = 'D' AND NVL(rec_linehaul.string_val,'XXX') <> 'OPERATOR' then  
        v_operator := upper(rtrim(ltrim(rec_linehaul.string_val)));
        
        open c2(v_operator);
        fetch c2 into c2rec;
        
        if c2%found then
           record_linehaul.valid_operator := 'Y';
        else
           record_linehaul.valid_operator := 'N';
        end if;
        close c2;
        
        record_linehaul.operator := v_operator ;
        
         
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 5 and substr(rec_linehaul.cell,1,1) = 'E' AND nvl(rec_linehaul.string_val,'XXX') <> 'TRUCK' then  
        
        if substr(rec_linehaul.string_val, 1, 3) = 'MSL' then 
           v_suffix := upper(substr(trim(rec_linehaul.string_val),-1));
           v_truck := substr(rec_linehaul.string_val, 1, 3) ||'-';
           v_truck := v_truck||regexp_replace(replace(rec_linehaul.string_val,' ',''),'[^0-9]', '');
           if v_suffix in ('K','Z') then
              v_truck := v_truck||v_suffix;
           end if;
        else 
           v_truck := replace(rec_linehaul.string_val,' ','');
        end if;
        
        open c3(v_truck);
        fetch c3 into c3rec;
        if c3%found then
           record_linehaul.valid_truck := 'Y';
        else
           record_linehaul.valid_truck := 'N';
        end if;
        close c3;
        
        record_linehaul.truck := v_truck;
        
        
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 6 and substr(rec_linehaul.cell,1,1) = 'F' AND nvl(rec_linehaul.string_val,'XXX') <> 'TRAILER' then  
        
        v_trailer := rtrim(ltrim(rec_linehaul.string_val));
        v_trailer := case when substr(v_trailer,1,1) = 'T' and substr(v_trailer,-2) in ('DD', 'FD')  then rtrim(substr(v_trailer,1,length(v_trailer) -2))
                            else v_trailer end ;
              
        open c4(v_trailer);
        fetch c4 into c4rec;
        if c4%found then
           record_linehaul.valid_trailer := 'Y';
        else
           record_linehaul.valid_trailer := 'N';
        end if;
        close c4;
        
        record_linehaul.trailer := v_trailer ;
        
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 7 and substr(rec_linehaul.cell,1,1) = 'G' AND nvl(rec_linehaul.string_val,'XXX') <> 'CONTAINER' then  
       
        -- glbx.dbg('Container : '||trim(rec_linehaul.string_val));
        
        v_container := replace(rec_linehaul.string_val,chr(10),'~');
        
        if v_container is not null then
           cnt := 1;
           for r_container in (SELECT rtrim(ltrim(regexp_substr( v_container,'(.*?)(~|$)',1,level, NULL, 1))) as result FROM dual connect by level<= regexp_count(v_container,'~')+1) loop
            --   if length(r_container.result) > 4 then 
                  open c5(r_container.result); 
                  fetch c5 into c5rec;
                  if c5%found then
                     a_shipname(cnt) := c5rec.shipname;
                     a_voyage(cnt) := c5rec.voyage;
                     a_container_valid(cnt) := 'Y';
                  else 
                     a_shipname(cnt) := null;
                     a_voyage(cnt) := null;
                     a_container_valid(cnt) := 'N';
                  end if;
                  close c5;
                  
                  a_container(cnt) := trim(r_container.result);
                  
               --   glbx.dbg('a_container(cnt) : '||a_container(cnt) );
               --   glbx.dbg('cnt : '||cnt );
                  cnt := cnt +1; 
                  
                  
             --  end if;
           
           end loop;
        end if; 
      
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 8 and (rec_linehaul.cell is not null and substr(rec_linehaul.cell,1,1) = 'H') AND (rec_linehaul.string_val is not null and  nvl(rec_linehaul.string_val,'XXX') <> 'TYPE') then  
       
        v_type := replace(rec_linehaul.string_val, chr(10), '~' );
        
             if v_type is not null then
           cnt := 1;
           
           for r_type in (SELECT rtrim(ltrim(regexp_substr( v_type,'(.*?)(~|$)',1,level, NULL, 1))) as result FROM dual connect by level<= regexp_count(v_type,'~')+1) loop
              if UPPER(rtrim(ltrim(r_type.result))) = 'EACH' and cnt > 1 then
                 a_type_valid(cnt) := a_type_valid(1);
                 a_type(cnt) := a_type(1);
                 a_iso_container_type(cnt) := a_iso_container_type(1);
                 cnt := cnt +1; 
              else   
                 open c6(r_type.result); 
                 fetch c6 into c6rec;
                 if c6%found then
                    a_iso_container_type(cnt) := c6rec.code;
                    a_type_valid(cnt) := 'Y';
                 else 
                    a_iso_container_type(cnt) := '';
                    a_type_valid(cnt) := 'N';
                 end if;
                 close c6;
                 
                 a_type(cnt) := trim(r_type.result);
                 cnt := cnt +1; 
              end if;   
           
           end loop;
        end if;  

     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 9 and substr(rec_linehaul.cell,1,1) = 'I' AND (Upper(rec_linehaul.string_val) not like  '%DESCRIPTION%' or rec_linehaul.number_val is not null) then  
       
        -- v_container := replace(rec_linehaul.string_val,chr(10),'~');
        v_description := replace(trim(nvl(rec_linehaul.string_val,to_char(rec_linehaul.number_val)) ),chr(10),'~') ;

        if v_description  is not null then
           cnt := 1;
           
           for r_description in (SELECT regexp_substr( v_description,'(.*?)(~|$)',1,level, NULL, 1) Result FROM dual connect by level<= regexp_count(v_description,'~')+1) loop
            --   if length(r_description.result) > 2 then 
                     a_description(cnt) := trim(r_description.result);
                     cnt := cnt +1;           
            --   end if;
           
           end loop;
        end if;   
     
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr = 10 and substr(rec_linehaul.cell,1,1) = 'J'  then  
        
        if rec_linehaul.cell_type = 'S' and  Upper(rec_linehaul.string_val) not like  '%WEIGHT%' then 
          v_weight := replace(trim(rec_linehaul.string_val),  chr(10), '~' );
        
          if v_weight is not null then
             cnt := 1;
            
             
            for r_weight in (SELECT regexp_substr( v_weight,'(.*?)(~|$)',1,level, NULL, 1) as Result FROM dual connect by level<= regexp_count(v_weight ,'~')+1) loop
             --  if length(r_weight.result) > 2 then 
                     begin  n_weight := to_number(r_weight.result); exception when others then null; end;
               
                     a_weight(cnt) := to_char(n_weight);
                     cnt := cnt +1;  
                     n_weight := null;         
              -- end if;
           
             end loop;
           end if;
        elsif  rec_linehaul.cell_type = 'N' then
        
            a_weight(1) := to_char(rec_linehaul.number_val);
        
        end if;  
       
 
        

        if a_container.count <1 and record_linehaul.load_number >= 1 then
           v_record := v_record + 1;
           
           insert into STRANG.stg_linehaul_plan
           ( batch_id, record, title, week, convoy_day, convoy_date, load_number,
             operator, truck, trailer, container, container_type, cargo_description, weight, total_weight,
             valid_convoy_day, valid_convoy_date, valid_load_number,
             valid_operator, valid_truck, valid_trailer, valid_container, valid_container_type, created_by, convoy_type, sheet_number) values
           ( v_batch, v_record, v_title1, v_week, case when record_linehaul.load_number > 1 then v_day else record_linehaul.convoy_day end, 
             case when record_linehaul.load_number > 1 then v_convoy_dt else record_linehaul.convoy_date end, record_linehaul.load_number,  
             record_linehaul.operator, record_linehaul.truck, record_linehaul.trailer, null,  null, null, null, null,
             case when record_linehaul.load_number > 1 then v_valid_day else record_linehaul.valid_convoy_day end, 
             case when record_linehaul.load_number > 1 then v_valid_convoy_dt else record_linehaul.valid_convoy_date end, record_linehaul.valid_load_number, 
             record_linehaul.valid_operator, record_linehaul.valid_truck, record_linehaul.valid_trailer, null, null, null, v_convoy_type, v_sheet_number);
             
           commit;
           
           --alter table STRANG.stg_linehaul_plan modify  convoy_date date;

        elsif a_container.count = 1 and record_linehaul.load_number >= 1 then
           null;
           
           if a_type.exists(1) then 
              v_type := a_type(1);
              v_type_valid := a_type_valid(1);
           else 
              v_type := null;
              v_type_valid := null;
           end if;
           
           if a_description.exists(1) then 
              v_description := a_description(1);
           else 
             v_description := null;
           end if;
           
           if a_weight.exists(1) then 
              v_weight := a_weight(1);
           else 
              v_weight := null;
           end if;
           
           v_record := v_record + 1;
          -- truncate table STRANG.stg_linehaul_plan
           insert into STRANG.stg_linehaul_plan
           ( batch_id, record, title, week, convoy_day, convoy_date, load_number,
             operator, truck, trailer, container, container_type, iso_container_type, cargo_description, weight, 
             valid_convoy_day, valid_convoy_date, valid_load_number,
             valid_operator, valid_truck, valid_trailer, valid_container, valid_container_type, created_by, convoy_type, sheet_number, shipname, voyage) values
           ( v_batch, v_record, v_title1, v_week, case when record_linehaul.load_number > 1 then v_day else record_linehaul.convoy_day end, 
             case when record_linehaul.load_number > 1 then v_convoy_dt else record_linehaul.convoy_date end, record_linehaul.load_number,  
             record_linehaul.operator, record_linehaul.truck, record_linehaul.trailer, a_container(1), v_type, a_iso_container_type(1), v_description, v_weight,
             case when record_linehaul.load_number > 1 then v_valid_day else record_linehaul.valid_convoy_day end, 
             case when record_linehaul.load_number > 1 then v_valid_convoy_dt else record_linehaul.valid_convoy_date end, record_linehaul.valid_load_number, 
             record_linehaul.valid_operator, record_linehaul.valid_truck, record_linehaul.valid_trailer,a_container_valid(1), 
             v_type_valid, null, v_convoy_type, v_sheet_number, a_shipname(1), a_voyage(1) );
             
           commit;
            
        elsif a_container.count > 1 and record_linehaul.load_number >= 1 then
           for j in 1..a_container.count loop
           
              if a_type.exists(j) then 
                 v_type := a_type(j);
                 v_type_valid := a_type_valid(j);
              else 
                 v_type := null;
                 v_type_valid := null;
              end if;
              
              if a_description.exists(j) then 
                 v_description := a_description(j);
              else 
                 v_description := null;
              end if;
           
              if a_weight.exists(j) then 
                 v_weight := a_weight(j);
              else 
                 v_weight := null;
              end if;
              
              v_record := v_record + 1;
              insert into STRANG.stg_linehaul_plan
               ( batch_id, record, title, week, convoy_day, convoy_date, load_number,
                 operator, truck, trailer, container, container_type, iso_container_type, cargo_description, weight,
                 valid_convoy_day, valid_convoy_date, valid_load_number,
                 valid_operator, valid_truck, valid_trailer, valid_container, valid_container_type, 
                 created_by, convoy_type, sheet_number, shipname, voyage) values
               ( v_batch, v_record, v_title1, v_week, case when record_linehaul.load_number > 1 then v_day else record_linehaul.convoy_day end, 
                 case when record_linehaul.load_number > 1 then v_convoy_dt else record_linehaul.convoy_date end, record_linehaul.load_number,  
                 record_linehaul.operator, record_linehaul.truck, record_linehaul.trailer, a_container(j), v_type,  a_iso_container_type(j), v_description, v_weight,
                 case when record_linehaul.load_number > 1 then v_valid_day else record_linehaul.valid_convoy_day end, 
                 case when record_linehaul.load_number > 1 then v_valid_convoy_dt else record_linehaul.valid_convoy_date end, record_linehaul.valid_load_number, 
                 record_linehaul.valid_operator, record_linehaul.valid_truck, record_linehaul.valid_trailer,a_container_valid(j), 
                 v_type_valid , null, v_convoy_type, v_sheet_number,  a_shipname(j), a_voyage(j));
              
              commit;

              v_type := null;
              v_type_valid := null;
              v_description := null;
              v_weight := null;
              
           end loop;
           
           
        end if;
        
        record_linehaul := null;
        v_stg_convoy_dt := null;
        v_load := null;
        v_operator := null;
        v_trailer := null;
        v_truck := null;
        v_container := null;
        a_container := glbx.empty_array;
        a_shipname := glbx.empty_array;
        a_voyage := glbx.empty_array;
        a_iso_container_type := glbx.empty_array;
        a_container_valid := glbx.empty_array;
        a_description := glbx.empty_array;
        v_description := null;
        a_type  := glbx.empty_array;
        v_type := null;
        v_type_valid := null;
        a_type_valid := glbx.empty_array;
        a_weight := glbx.empty_array;
        v_weight := null;
        n_weight := null;
        v_count := v_count + 1;
         
     end if;
  end loop;
---------------------------------------------------------------------------------   
  -- START THE FUEL TANKERS here
   v_count := 1;
   v_load := 1;
   v_sheet_number := 2;
   v_convoy_type := null;
   v_stg_convoy_dt := null;
   v_convoy_day_date := null;
   record_linehaul := null;
   
   open c7;
   fetch c7 into c7rec;
   close c7;
   
   if v_convoy_type is null then
      v_convoy_type := upper(c7rec.sheet_name);
      v_convoy_type := replace(v_convoy_type,'DAILY FUEL TANKERS','');
      v_convoy_type := replace(v_convoy_type,'-','');
      v_convoy_type := ltrim(rtrim(v_convoy_type));
   end if;
  
   if c7rec.string_val is not null then
      v_title1 := c7rec.string_val;
      v_week  := TO_NUMBER(glbx.guess_number(substr(v_title1,instr(v_title1,'WEEK ',1) +4)));     
   end if;

   for z in 2..8 loop 
   
      for rec_linehaul in   (select *
                           from table( as_read_xlsx.read(
                           (select blob_content from apache_ows_content where name = infile )))
                                where upper(sheet_nr) = 3
                                and col_nr = z) loop
      
        if v_load is null then
           open c8(rec_linehaul.row_nr);
           fetch c8 into c8rec;
           close c8;
           v_load := GLBX.GUESS_NUMBER(replace(UPPER(c8rec.string_val), 'LOAD'));

           v_valid_load_number := 'Y';
         --  v_load := 1;
        
        end if;
    
        if rec_linehaul.row_nr = 2 and NVL(rec_linehaul.col_nr,99) > 1 and rec_linehaul.cell is not null AND (rec_linehaul.string_val is not null) then
           
           if rec_linehaul.row_nr = 2 then
             v_convoy_day_date := replace(rec_linehaul.string_val,chr(10),'~');
           end if;
           
           if v_convoy_day_date is not null then
           cnt := 1;
           for r_convoy_day_date in (SELECT regexp_substr( v_convoy_day_date,'(.*?)(~|$)',1,level, NULL, 1) as result FROM dual connect by level<= regexp_count(v_convoy_day_date,'~')+1) loop
                if cnt = 1 then
                 --  v_day := null;
                --   v_valid_day := null;
                   if upper(r_convoy_day_date.result) in ('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') and cnt = 1 then
                      
                      if upper(r_convoy_day_date.result) <> upper(v_day) then 
                              
                         open c8(rec_linehaul.row_nr);
                         fetch c8 into c8rec;
                         close c8;
                         v_load := glbx.guess_number(replace(UPPER(c8rec.string_val), 'LOAD'));

                      end if;
                   
                      v_day := Initcap(r_convoy_day_date.result);
                      v_valid_day  := 'Y';
                   else
                      
                      v_valid_day  := 'N';
                   end if;
                   
                
                elsif cnt = 2 then
                   v_convoy_dt  := null;
                   v_valid_convoy_dt := null;
                   begin v_convoy_dt  := to_date(r_convoy_day_date.result, 'DD Mon YY'); exception when others then null; end;
                   if v_stg_convoy_dt is null then
                      v_stg_convoy_dt := v_convoy_dt;
                   end if;
                   
                   if upper(v_day) = to_char(v_convoy_dt, 'fmDAY') then 
                      v_valid_convoy_dt := 'Y';
                   else
                      v_valid_convoy_dt  := 'N';
                      v_valid_day := 'N';
                   end if;
                   
                   if not (record_linehaul.valid_convoy_date =  'Y' and websys.strangp.week_of_year(v_stg_convoy_dt) = v_week) then
                       record_linehaul.valid_convoy_date := 'N';
                       record_linehaul.valid_convoy_day  := 'N';
                       v_valid_day := 'N';
                   end if;
                   
                end if;
                cnt := cnt +1; 
                  
           end loop;
        end if; 
     
     elsif rec_linehaul.row_nr > 2 and rec_linehaul.col_nr between 2 and 8  then  
        v_fuel_tanker_details := upper(rtrim(ltrim(rec_linehaul.string_val)));
        v_fuel_tanker_details := replace(v_fuel_tanker_details,chr(10),'~');
        if v_fuel_tanker_details is not null then
           cnt := 1;
           for r_fuel_tanker_details in (SELECT regexp_substr( v_fuel_tanker_details,'(.*?)(~|$)',1,level, NULL, 1) as result FROM dual connect by level<= regexp_count(v_fuel_tanker_details,'~')+1) loop
             
                if cnt = 1 then
                   v_operator := rtrim(ltrim(upper(r_fuel_tanker_details.result)));
                   open c2(v_operator);
                   fetch c2 into c2rec;
                   if c2%found then
                      record_linehaul.valid_operator := 'Y';
                   else
                      record_linehaul.valid_operator := 'N';
                   end if;
                   close c2;
        
                   record_linehaul.operator := v_operator ;
                   
               -- William Pinia
               -- VT28
               -- FT193
               -- Capacity: 43,000L
                   
                elsif  cnt = 2 then  
                  if substr(r_fuel_tanker_details.result, 1, 3) = 'MSL' then 
                     v_truck := substr(r_fuel_tanker_details.result, 1, 3) ||'-';
                     v_truck := v_truck||regexp_replace(replace(r_fuel_tanker_details.result,' ',''),'[^0-9]', '');
                  else 
                     v_truck := replace(r_fuel_tanker_details.result,' ','');
                  end if;
        
                  open c3(v_truck);
                  fetch c3 into c3rec;
                  if c3%found then
                     record_linehaul.valid_truck := 'Y';
                  else
                     record_linehaul.valid_truck := 'N';
                  end if;
                  close c3;
        
                  record_linehaul.truck := v_truck;

                elsif cnt = 3 then  
                   v_trailer := rtrim(ltrim(r_fuel_tanker_details.result));
                   v_trailer := case when substr(v_trailer,1,1) = 'T' and substr(v_trailer,-2) in ('DD', 'FD')  then rtrim(substr(v_trailer,1,length(v_trailer) -2))
                            else v_trailer end ;
                   open c4(v_trailer);
                   fetch c4 into c4rec;
                   if c4%found then
                      record_linehaul.valid_trailer := 'Y';
                   else
                      record_linehaul.valid_trailer := 'N';
                   end if;
                   close c4;
        
                   record_linehaul.trailer := v_trailer ;
                 elsif cnt = 4 then    
                   v_fuel_capacity :=  ltrim(rtrim(replace(replace(UPPER(r_fuel_tanker_details.result),'CAPACITY',''),':','')));
                   open c9(v_trailer, v_fuel_capacity);
                   fetch c9 into c9rec;
                   if c9%found then
                      record_linehaul.valid_fuel_capacity := 'Y';
                   else
                      record_linehaul.valid_fuel_capacity := 'N';
                   end if;
                   close c9;
                   
                 end if;
                 cnt := cnt +1; 
                  
           end loop;
        end if; 
      ------------------------------------------------------------------------------------------------------------------------------
        
      if  record_linehaul.operator is not null and  record_linehaul.truck is not null and  record_linehaul.trailer is not null then
           v_record := v_record + 1;
           insert into strang.stg_linehaul_plan
           ( batch_id, record, title, week, convoy_day, convoy_date, load_number,
             operator, truck, trailer, fuel_capacity,
             valid_convoy_day, valid_convoy_date, valid_load_number,
             valid_operator, valid_truck, valid_trailer, valid_fuel_capacity , created_by, convoy_type, sheet_number) values
           ( v_batch, v_record, v_title1, v_week, v_day,v_convoy_dt, v_load,  
             record_linehaul.operator, record_linehaul.truck, record_linehaul.trailer, v_fuel_capacity,
             v_valid_day,v_valid_convoy_dt, v_valid_load_number, 
             record_linehaul.valid_operator, record_linehaul.valid_truck, record_linehaul.valid_trailer, record_linehaul.valid_fuel_capacity, null, v_convoy_type, v_sheet_number);
             
           commit;
        end if;

        
           record_linehaul := null;
           v_stg_convoy_dt := null;
          -- v_load := null;
           v_load := v_load +1 ;
           v_operator := null;
           v_trailer := null;
           v_truck := null;
           v_fuel_capacity := null;
           v_count := v_count + 1;
         
        end if;

     end loop;
  end loop;
  msg := msg || r_ctr || ' entr' || (case when r_ctr = 1 then 'y' else 'ies' end) || ' added';
  begin dbms_lob.freetemporary(v_clb); exception when others then null; end;
-- end if;
   
  ingest_convoy_excel_file(msg);

 return;
exception when others then
-- begin delete from apache_ows_content where name = infile; exception when others then null; end;
 begin dbms_lob.freetemporary(v_clb); exception when others then null; end;
 commit;
 htp.bold('Error: ' || sqlerrm);
end accept_ingest_convoy_file;
/
