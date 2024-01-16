CREATE OR REPLACE PACKAGE BODY WEBSYS.convoy_plan_load
as


procedure convoy_plan_mng(surl in varchar2, vtyp varchar2 default 'CONVOY_PLAN', msg in varchar2 default null, batchno number default null) as

 v_g_gst_rate number(15,2) := invoice_parser.g_gst_rate;

cursor c1a (v_batchno number) is
   select max(batch_id) batch_id, max(title) title, min(week) week, max(convoy_type) convoy_type,   min(convoy_date) convoy_start_date
     from STRANG.stg_linehaul_plan a
    where a.batch_id = v_batchno
      and sheet_number = 1;
  
cursor c2a (v_batchno number) is
   select *
     from STRANG.stg_linehaul_plan a
    where a.batch_id = v_batchno
      and a.sheet_number = 1
  order by record, convoy_date, load_number;

 cursor c3 is
  select mo.name, mv.name_default
  from   main_object mo, main_value mv
  where  mo.mid = mv.mid
         and mo.theme_type = 'STRANG_TMP_RECEIVALS_FOLDERS';
  
cursor c4 (v_batchno number) is
   select max(batch_id) batch_id, max(title) title, min(week) week, max(convoy_type) convoy_type,   min(convoy_date) convoy_start_date
    from STRANG.stg_linehaul_plan a
  where  a.batch_id = v_batchno
   and sheet_number = 2;
  
 cursor c5 (v_batchno number) is
   select *
    from STRANG.stg_linehaul_plan a
  where  a.batch_id = v_batchno
    and  sheet_number = 2
  order by record, convoy_date, load_number;
  
 cursor c6 (v_batchno number) is
 select case when error_convoy_day > 0 then 'Error: Convoy Day is incorrect. Please correct Day(s) and reload Convoy Plan again.' 
             when error_convoy_date > 0 then 'Error: Convoy Date is incorrect. Please correct Date(s) and reload Convoy Plan again.' 
             when error_load_number > 0 then 'Error: Convoy Load Number is incorrect. Please correct Load Number(s) and reload Convoy Plan again.' 
             when error_operator > 0 then 'Error: Convoy operator is incorrect. Please correct Operator(s) and reload Convoy Plan again.' 
             when error_truck > 0 then 'Error: Convoy truck is incorrect. Please correct truck(s) and reload Convoy Plan again.' 
             when error_trailer > 0 then 'Error: Convoy trailer is incorrect. Please correct trailer(s) and reload Convoy Plan again.'
             when error_container > 0 then 'Warning: Some Container(s) have not arrived in Kiunga over the last 120 days. Please check Container Number(s) again before proceeding.'  
             else 'Convoy Plan uploaded, Verified. Click Create Convoy Plan button to proceed' end msg,
           case when error_convoy_day + error_convoy_date + error_operator + error_truck + error_trailer > 0 then 'N' else 'Y' end proceed 
   from (select sum (case when valid_convoy_day = 'N' then 1 else 0 end) over () error_convoy_day,
          sum (case when valid_convoy_date = 'N' then 1 else 0 end) over () error_convoy_date,
          sum (case when valid_load_number = 'N' then 1 else 0 end) over () error_load_number,
          sum (case when valid_operator = 'N' then 1 else 0 end) over () error_operator,
          sum (case when valid_truck = 'N' then 1 else 0 end) over () error_truck,
          sum (case when valid_trailer = 'N' then 1 else 0 end) over () error_trailer,
          sum (case when valid_container = 'N' then 1 else 0 end) over () error_container,
          sum (case when valid_container_type = 'N' then 1 else 0 end) over () error_container_type,
          row_number() over ( order by load_number, operator, truck, trailer) rnk
    from STRANG.stg_linehaul_plan a
  where  a.batch_id = v_batchno
  ) tmp
 where rnk = 1;

 INVALID_RID exception;
 PRAGMA EXCEPTION_INIT(INVALID_RID, -1410);

 c1rec          customer_account%ROWTYPE;
 po_item_list   owa.vc_arr default glbx.empty_array;
 c1arec         c1a%ROWTYPE;
 c2arec         c2a%ROWTYPE;
 c4rec          c4%ROWTYPE;
 c5rec          c5%ROWTYPE;
 c6rec          c6%ROWTYPE;
 pfx            THEME%ROWTYPE;
 ltype          varchar2(100);
 stype          integer;
 owner_id       integer;
 sts            varchar2(100);
 vaccess        varchar2(20);
 vste           varchar2(10);
 seclevel       varchar2(100);
 v_inventory    varchar2(100);
 v_po_item      varchar2(100);
 v_unit_price   number(15,2);
 v_url          varchar2(1000);
 v_open_qty     varchar2(20);
 v_background   varchar2(30);	
 v_proceed      varchar2(10);
 v_full_proceed varchar2(10);
 v_checkbox     varchar2(50);
 v_hide_cell    varchar2(50):= 'style="display:none;"';
 v_gstcode      varchar2(4);
 v_valid_start_dt varchar2(1);
 file_types   CONSTANT varchar2(1000) := '.xlsx';
 c integer := 0;
 vmsg varchar2(500);
 v_convoy_start_dt date;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CONVOY_PLAN_LOAD.CONVOY_PLAN_MNG' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 v_full_proceed := 'NO';
 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste :=  invoice_parser.customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := strangp.data_access( owner_id, 'CONVOY_PLAN_MNG', null );
 seclevel := oltp.security_role( owner_id );
 
 open c2a(batchno);
 fetch c2a into c2arec;
 if c2a%notfound and batchno is not null then
    vmsg := 'Excel file loaded contains wrong convoy entries';
 end if;
 close c2a;
 
 if batchno is not null then 
   open c6(batchno);
   fetch c6 into c6rec;
   close c6;
   
   vmsg := nvl(vmsg,c6rec.msg);
   
   if c6rec.proceed = 'Y' then
     v_full_proceed := 'YES';
   end if;  
 end if;

 htp.p('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"');
 htp.p('"http://www.w3.org/TR/html4/strict.dtd"> ');
 htp.htmlopen;
 htp.headopen;
 htp.p('<link rel="stylesheet" type="text/css" href="/images/str/style_convoy_plan.css" />');
 htp.p('<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script>');
 htp.headclose;

 htp.bodyopen;
 htp.p('<CENTER>');
 htp.header(1,'Load Weekly Convoy Plan xlsx file to be processed', 'CENTER' );
 htp.nl;
 
 if msg is not null then
    htp.header(1, msg, cattributes=>'style="color: red;"');
 elsif vmsg is not null then
    htp.header(1, vmsg, cattributes=>'style="color: red;"');
 end if;
 
 htp.formopen('convoy_plan_load.convoy_plan_mng_accept', 'POST', null, 'multipart/form-data', cattributes=>'name="item_box"' );
 htp.formhidden('SURL', surl );
 htp.formhidden('VTYP', vtyp );
 htp.formhidden('BATCHNO', batchno);
 htp.tableopen;
 
 for c3rec in c3 loop
    v_url := htf.anchor('javascript: window.open(''' || '/convoy_plan/' || to_char(sysdate,'YYYYMM') || '/' || ''',''' || 'vtyp' || ''',''height=800,width=600,scrollbars=yes,resizable=yes'');void('''');', 'Month''s Uploads' );
    htp.tablerowopen;
    if c3%ROWCOUNT = 1 then
       htp.tabledata(htf.formfile('infile', file_types, 'multiple'));
	else
       htp.tabledata('&nbsp;');
	end if;

    htp.tabledata(htf.formsubmit('action', 'Load Convoy Plan')); --  || c3rec.name_default));
    if batchno is not null then 
       if v_full_proceed = 'YES' then 
          htp.tabledata('<INPUT TYPE="submit" NAME="action" VALUE="Create Convoy Plan" onclick="return confirm(''Are you definitely sure you want to Create the Convoy Plan?'');">');
       end if;
    end if;

	htp.tabledata(v_url);
    htp.tablerowclose;
 end loop;
 htp.tableclose;
 htp.nl;

 open c1a(batchno);
 fetch c1a into c1arec;
 if c1a%notfound then
     close c1a;
        return;
 end if;
 close c1a;
 
 
 if c1arec.batch_id is not null then 
    if NOT((websys.strangp.week_of_year(c1arec.convoy_start_date) = c1arec.week)  and ( 'MONDAY' = UPPER(to_char(to_date(c1arec.convoy_start_date), 'fmDAY')))) then
       v_valid_start_dt := 'N';
       v_convoy_start_dt := next_day( trunc( c1arec.convoy_start_date) - 7, strangp.g_convoy_week_start );
    else
       v_valid_start_dt := 'Y';
    end if;
     
     htp.tableopen ( CATTRIBUTES=>'style="font-size:18px;"');
     htp.tablerowopen;
     htp.tableheader('Convoy Batch ID: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata(c1arec.batch_id,cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen; 
     htp.tableheader('Convoy Main Title: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata('WK_'||to_char(c1arec.week)||' '||c1arec.convoy_type||' '||'MASTER PLAN' , cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen; 
     htp.tableheader('Convoy Direction: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     --htp.tabledata('INBOUND' , cattributes=>'style="font-weight:bold;"');
     htp.p('<TD style="color:blue; font-weight:bold; ">
           <div class="blink">INBOUND ONLY</div></TD>');
     htp.tablerowclose;
     htp.tableclose;
     htp.nl;
     htp.nl;
     htp.tableopen ( CATTRIBUTES=>'style="font-size:18px;"');
     htp.tablerowopen; 
     htp.tableheader('Convoy Sheet Title: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata(c1arec.title , cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen; 
     htp.tableheader('Convoy Week: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     if v_valid_start_dt = 'Y' then 
        htp.tabledata(c1arec.week, cattributes=>'style="font-weight:bold;"');
        htp.tablerowclose;
        htp.tablerowopen; 
        htp.tableheader('Convoy Start Date: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
        htp.tabledata(c1arec.convoy_start_date, cattributes=>'style="font-weight:bold; "');
        htp.tablerowclose;
     else
       -- v_full_proceed := 'NO';
        htp.p('<TD style="color:red">
               <DIV CLASS="tooltip">'||c1arec.week||
               '<SPAN CLASS="tooltiptext">Convoy week: '||c1arec.week||' should start on '||to_char (v_convoy_start_dt,'Day, ddth Month, yyyy')||'</SPAN>
               </DIV></TD>');
        htp.tablerowclose;
        htp.tablerowopen; 
        htp.tableheader('Convoy Start Date: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
        
        htp.p('<TD style="color:red">
               <DIV CLASS="tooltip">'||c1arec.convoy_start_date||
               '<SPAN CLASS="tooltiptext">Convoy week: '||c1arec.week||' should start on '||to_char (v_convoy_start_dt,'Day, ddth Month, yyyy')||'</SPAN>
               </DIV></TD>');
        htp.tablerowclose;
        v_convoy_start_dt := null;
     end if;
     
     htp.tablerowopen;
     htp.tableheader('Convoy Type: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.p( '<TD ALIGN="LEFT">' );
       websys.convoy_plan_load.lov_list( 'CONVOY TYPES', 'P12', c1arec.convoy_type, TRUE, TRUE, TRUE );
     htp.p( '</TD>' );
     
     
     htp.tablerowclose;
     htp.tablerowopen;
     htp.tableclose;
    

     htp.nl;
     htp.nl;
     htp.tableopen;
     htp.tablerowopen;
     htp.tableheader('Convoy Day');
     htp.tableheader('Convoy Date');
     htp.tableheader('Load<BR>Number');
     htp.tableheader('Operator');
     htp.tableheader('Truck');
     htp.tableheader('Trailer');
     htp.tableheader('Container');
     htp.tableheader('Type');
     htp.tableheader('Description');
     htp.tableheader('Weight');
     htp.tableheader('Error Description');
     htp.tablerowclose;
           
           for c2arec in c2a ( batchno)
           loop
             c := c + 1;

             if upper(c2arec.convoy_day) = 'MONDAY' then
                null;
             --  htp.tablerowopen ( cattributes=>'style="background-color:#FFFFFF;"') ;
             elsif upper(c2arec.convoy_day) = 'TUESDAY' then
               htp.tablerowopen ( cattributes=>'style="background-color:#eefff8;"') ;
             elsif upper(c2arec.convoy_day) = 'WEDNESDAY' then
                null;
             --  htp.tablerowopen ( cattributes=>'style="background-color:#FFFFFF;"') ;
             elsif upper(c2arec.convoy_day) = 'THURSDAY' then
               htp.tablerowopen ( cattributes=>'style="background-color:#eefff8;"') ;
             elsif upper(c2arec.convoy_day) = 'FRIDAY' then
                null;
             --  htp.tablerowopen ( cattributes=>'style="background-color:#FFFFFF;"') ;
             elsif upper(c2arec.convoy_day) = 'SATURDAY' then
               htp.tablerowopen ( cattributes=>'style="background-color:#eefff8;"') ;
             elsif upper(c2arec.convoy_day) = 'SUNDAY' then
                null;
             --  htp.tablerowopen ( cattributes=>'style="background-color:#FFFFFF;"') ;
             else  
                htp.tablerowopen ;
             end if;
           --  htp.formhidden( 'RID', null);
           --  htp.formhidden( 'recItm', null);  
             
             if  c2arec.valid_convoy_day = 'Y' then
                htp.tabledata(c2arec.convoy_day);
             else 
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.convoy_day||
                      '<SPAN CLASS="tooltiptext">Incorrect Convoy Day</SPAN>
                       </DIV></TD>');
             end if;
             
             if c2arec.valid_convoy_date = 'Y' then
                htp.tabledata(c2arec.convoy_date);
             else 
                v_full_proceed := 'NO';
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.convoy_date||
                      '<SPAN CLASS="tooltiptext">Incorrect Convoy Date</SPAN>
                       </DIV></TD>');
              --  htp.tabledata(c2arec.convoy_date, cattributes=>'style="color:red"');
             end if;
             
             if c2arec.valid_load_number = 'Y' then
                htp.tabledata(c2arec.load_number);
             else
                htp.tabledata(c2arec.load_number, cattributes=>'style="color:red"');
             end if;
             
             if c2arec.valid_operator = 'Y' then
                htp.tabledata(c2arec.operator);
             else
                v_full_proceed := 'NO';
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.operator||
                      '<SPAN CLASS="tooltiptext">'||c2arec.operator||' is not in the list of Operators</SPAN>
                       </DIV></TD>');
               -- htp.tabledata(c2arec.operator , cattributes=>'style="color:red"');
             end if;
             
             if c2arec.valid_truck = 'Y' then
                htp.tabledata(c2arec.truck);
             else
                v_full_proceed := 'NO';
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.truck||
                      '<SPAN CLASS="tooltiptext">'||c2arec.truck||' is not in the list of Trucks</SPAN>
                       </DIV></TD>');
               -- htp.tabledata(c2arec.truck, cattributes=>'style="color:red"');
             end if;
             
             if c2arec.valid_trailer = 'Y' then
                htp.tabledata(c2arec.trailer);
             else
                v_full_proceed := 'NO';
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.trailer||
                      '<SPAN CLASS="tooltiptext">'||c2arec.trailer||' is not in the list of Trailers</SPAN>
                       </DIV></TD>');
               -- htp.tabledata(c2arec.trailer, cattributes=>'style="color:red"');
             end if;
             
             if c2arec.container is not null then
                if c2arec.valid_container = 'Y' then
                 --  htp.tabledata(c2arec.container);
                    htp.p('<TD style="color:black">
                       <DIV CLASS="tooltip">'||c2arec.container||
                      '<SPAN CLASS="tooltiptext">'||c2arec.container||' arrived in Kiunga on '||c2arec.shipname||'('||c2arec.shipname||')'||'</SPAN>
                       </DIV></TD>');
                else
                 --  v_full_proceed := 'NO';
                   htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.container||
                      '<SPAN CLASS="tooltiptext">'||c2arec.container||' not yet in Kiunga Location</SPAN>
                       </DIV></TD>');
                end if;
             else 
                htp.tabledata(c2arec.container, cattributes=>'style="background-color:lightgrey;"');
             end if;
             
             if c2arec.container is not null then
                htp.tabledata(c2arec.container_type);
             else
                htp.tabledata(c2arec.container_type, cattributes=>'style="background-color:lightgrey;"');
             end if;
             
             if c2arec.container is not null then
                htp.tabledata(c2arec.cargo_description, cattributes=>'style="max-width: 400px;"');
             else
                htp.tabledata(c2arec.cargo_description, cattributes=>'style="background-color:lightgrey; max-width: 400px;"');
             end if;
             
             if c2arec.container is not null then
                htp.tabledata(c2arec.weight);
             else
                htp.tabledata(c2arec.weight, cattributes=>'style="background-color:lightgrey;"');
             end if;
             if c2arec.container is not null then
                htp.tabledata('&nbsp;');
             else
                htp.tabledata('No container details will be saved', cattributes=>'style="color:red"');
             end if; 
                                 
             htp.tablerowclose;
             v_inventory := null;
             v_po_item := null;

           end loop;
           po_item_list := glbx.empty_array;
              
  
  htp.tableclose;
  htp.nl;
  htp.nl;
  
  open c4(batchno);
  fetch c4 into c4rec;
  close c4;
  
  if NOT((websys.strangp.week_of_year(c4rec.convoy_start_date) = c4rec.week)  and ( 'MONDAY' = UPPER(to_char(to_date(c4rec.convoy_start_date), 'fmDAY')))) then
        v_valid_start_dt := 'N';
        v_convoy_start_dt := next_day( trunc( c4rec.convoy_start_date) - 7, strangp.g_convoy_week_start );
  else
        v_valid_start_dt := 'Y';
  end if;
  
  htp.tableopen ( CATTRIBUTES=>'style="font-size:18px;"');
  htp.tablerowopen; 
  htp.tableheader('Convoy Sheet Title: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
  htp.tabledata(c4rec.title , cattributes=>'style="font-weight:bold;"');
  htp.tablerowclose;
  htp.tablerowopen; 
  htp.tableheader('Convoy Week: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
  if v_valid_start_dt = 'Y' then 
     htp.tabledata(c4rec.week, cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen; 
     htp.tableheader('Convoy Start Date: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata(c4rec.convoy_start_date, cattributes=>'style="font-weight:bold; "');
     htp.tablerowclose;
  else
     htp.p('<TD style="color:red">
            <DIV CLASS="tooltip">'||c4rec.week||
           '<SPAN CLASS="tooltiptext">Convoy week: '||c4rec.week||' should start on '||to_char (v_convoy_start_dt,'Day, ddth Month, yyyy')||'</SPAN>
            </DIV></TD>');
     htp.tablerowclose;
     htp.tablerowopen; 
     htp.tableheader('Convoy Start Date: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
        
     htp.p('<TD style="color:red">
               <DIV CLASS="tooltip">'||c4rec.convoy_start_date||
               '<SPAN CLASS="tooltiptext">Convoy week: '||c4rec.week||' should start on '||to_char (v_convoy_start_dt,'Day, ddth Month, yyyy')||'</SPAN>
               </DIV></TD>');
     htp.tablerowclose;
   end if;
     
   htp.tablerowopen;
   htp.tableheader('Convoy Type: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
   htp.p( '<TD ALIGN="LEFT">' );
   websys.convoy_plan_load.lov_list( 'CONVOY TYPES', 'P12', c4rec.convoy_type, TRUE, TRUE, TRUE );
   htp.p( '</TD>' );

   htp.tablerowclose;
   htp.tablerowopen;
   htp.tableclose;
    
   htp.nl;
   htp.nl;
   
   htp.tableopen;
   htp.tablerowopen;
   htp.tableheader('Convoy Day');
   htp.tableheader('Convoy Date');
   htp.tableheader('Load<BR>Number');
   htp.tableheader('Operator');
   htp.tableheader('Truck');
   htp.tableheader('Trailer');
   htp.tableheader('Fuel Capacity');
   htp.tableheader('Error Description');
   htp.tablerowclose;
           
   for c5rec in c5 ( batchno) loop
     c := c + 1;
     if upper(c5rec.convoy_day) = 'MONDAY' then
        null;
     elsif upper(c5rec.convoy_day) = 'TUESDAY' then
        htp.tablerowopen ( cattributes=>'style="background-color:#eefff8;"') ;
     elsif upper(c5rec.convoy_day) = 'WEDNESDAY' then
        null;
     elsif upper(c5rec.convoy_day) = 'THURSDAY' then
        htp.tablerowopen ( cattributes=>'style="background-color:#eefff8;"') ;
     elsif upper(c5rec.convoy_day) = 'FRIDAY' then
        null;
     elsif upper(c5rec.convoy_day) = 'SATURDAY' then
        htp.tablerowopen ( cattributes=>'style="background-color:#eefff8;"') ;
     elsif upper(c5rec.convoy_day) = 'SUNDAY' then
        null;
     else  
        htp.tablerowopen ;
     end if;
             
     if  c5rec.valid_convoy_day = 'Y' then
        htp.tabledata(c5rec.convoy_day);
     else 
        htp.p('<TD style="color:red">
               <DIV CLASS="tooltip">'||c5rec.convoy_day||
               '<SPAN CLASS="tooltiptext">Incorrect Convoy Day</SPAN>
                </DIV></TD>');
     end if;
             
     if c5rec.valid_convoy_date = 'Y' then
        htp.tabledata(c5rec.convoy_date);
     else 
        htp.p('<TD style="color:red">
               <DIV CLASS="tooltip">'||c5rec.convoy_date||
              '<SPAN CLASS="tooltiptext">Incorrect Convoy Date</SPAN>
               </DIV></TD>');
     end if;
             
     if c5rec.valid_load_number = 'Y' then
        htp.tabledata(c5rec.load_number);
     else
        htp.tabledata(c5rec.load_number, cattributes=>'style="color:red"');
     end if;
             
     if c5rec.valid_operator = 'Y' then
        htp.tabledata(c5rec.operator);
     else
        htp.p('<TD style="color:red">
              <DIV CLASS="tooltip">'||c5rec.operator||
              '<SPAN CLASS="tooltiptext">'||c5rec.operator||' is not in the list of Operators</SPAN>
              </DIV></TD>');
     end if;
             
     if c5rec.valid_truck = 'Y' then
        htp.tabledata(c5rec.truck);
     else
        htp.p('<TD style="color:red">
              <DIV CLASS="tooltip">'||c5rec.truck||
              '<SPAN CLASS="tooltiptext">'||c5rec.truck||' is not in the list of Trucks</SPAN>
              </DIV></TD>');
     end if;
             
     if c5rec.valid_trailer = 'Y' then
        htp.tabledata(c5rec.trailer);
     else
        htp.p('<TD style="color:red">
               <DIV CLASS="tooltip">'||c5rec.trailer||
              '<SPAN CLASS="tooltiptext">'||c5rec.trailer||' is not in the list of Trailers</SPAN>
               </DIV></TD>');
     end if;
             
     if c5rec.valid_fuel_capacity = 'Y' then
         htp.tabledata(c5rec.fuel_capacity);
     else
         htp.p('<TD style="color:red">
                <DIV CLASS="tooltip">'||c5rec.fuel_capacity||
               '<SPAN CLASS="tooltiptext">'||c5rec.fuel_capacity||' different from GLMS data</SPAN>
               </DIV></TD>');
     end if;
      
     htp.tabledata('&nbsp;');   
   
     htp.tablerowclose;
     v_inventory := null;
     v_po_item := null;

  end loop;
  
    po_item_list := glbx.empty_array;
    htp.tableclose;
    htp.nl;
    htp.nl;
 --   htp.formhidden('P5', v_proceed);
   
   
 end if;
 
 if batchno is not null then 
    if v_full_proceed = 'YES' then 
       htp.formsubmit('action','Create Convoy Plan');
    end if;
 end if;

  htp.formclose;
  htp.nl;
  htp.nl;
  htp.bold('<a href="" onClick="self.close()">[Close Window]</a>');
  htp.p('</CENTER>');

 htp.bodyclose;
 htp.htmlclose;
end convoy_plan_mng;

procedure convoy_plan_mng_accept( surl in varchar2, vtyp varchar2, infile in owa.vc_arr default glbx.empty_array
                                , action varchar2, batchno number default null
                                , p12 in varchar2 default null                                
                                ) as
                            
    
 cursor c2 (v_batch integer, v_sheet_number integer, record integer ) is 
    select *
      from (select batch_id, title, week, convoy_day, convoy_date, load_number
                 , min(convoy_date) over () as convoy_start_date
                 , dense_rank() over (partition by convoy_date order by sheet_number, load_number) rnk_big
                 , row_number() over (partition by convoy_date, sheet_number, operator, truck, trailer order by case when container is not null then lp.record else 9999 end) rnk_small
                 , operator, truck, trailer, container, container_type, cargo_description
                 , weight, total_weight, fuel_capacity, iso_container_type
                 , valid_convoy_day, valid_convoy_date, valid_load_number
                 , valid_operator, valid_truck, valid_trailer, valid_container
                 , valid_container_type, valid_weight, valid_total_weight, valid_fuel_capacity
                 , created_by, create_date, convoy_type, sheet_number, convoy_id, lp.rowid as row_id
                 , 'WK_'||to_char(week)||' '||convoy_type||' '||'MASTER PLAN' as convoy_name
              from strang.stg_linehaul_plan lp
             where lp.batch_id = v_batch
               and (( v_sheet_number is null ) or (lp.sheet_number = v_sheet_number))) tmp
      where ((record is null) or (tmp.convoy_start_date + record = tmp.convoy_date))
    order by sheet_number, rnk_big, rnk_small, tmp.convoy_date, tmp.load_number ; 
     
 cursor c3a (v_convoy_type varchar2, v_convoy_start_date date)
    is
    select *
      from strang.convoy
     where portload = 'KIU'
       and portdisc = 'TAB'
       and estdepart between v_convoy_start_date and v_convoy_start_date +6
       and convoy_type = v_convoy_type;
  

cursor c3(v_file varchar2) is select * from apache_ows_content where name = v_file;
cursor c4( sname varchar2 ) is select screen_id from oltp_overview where screen_name = sname;
   
cursor c5( vMv varchar2 ) is    
   select m.movement_no, m.seal, m.container_type, m.iso_container_type
        , s.shipname||' - '||s.voy vvoy, m.overdimensional, m.set_point
        , m.consignee, m.consignee_location, m.warehouse_destination, m.owner
        , m.urgency, m.current_location, (nvl(vgm,nvl(sumweight,0)+nvl(tare,0))/1000) weight
        , decode(m.full_mt,'EMPTY','EMPTY','FULL') FULL_MT, s.estdepart, dispatch_date
 from strang.movements m, strang.ships_airway s
 where m.local_ship_id = s.ship_id
 and m.movement_no = vMv 
 and current_location in (select code from strang.lov where lov_name='LOCATIONS' and colc = 'KIUNGA' and substr(code,1,1)='K')
 and nvl(m.io,'I') = 'I'
 and nvl(s.estdepart,sysdate) >= (sysdate - 240) 
 and m.convoy_id is null
 and complete <> 'H'
-- order by dispatch_date desc;  
order by s.estdepart desc, dispatch_date desc;  

            
 c1rec         customer_account%ROWTYPE;
 c2rec         c2%ROWTYPE;
 c3rec         c3%ROWTYPE;
 c3arec        c3a%ROWTYPE;
 c4rec         c4%ROWTYPE;
 c5rec         c5%ROWTYPE;
 status        number;
 deliveryno    number := 123456;
 v_dir         varchar2(64);
 v_dir2        varchar2(64);
 v_file        varchar2(1000);
 pfx           THEME%ROWTYPE;
 ltype         varchar2(100);
 stype         integer;
 owner_id      integer;
 sts           varchar2(100);
 vaccess       varchar2(20);
 vste          varchar2(10);
 seclevel      varchar2(100);
 chkval        varchar2(1000);
 msg           varchar2(1000);
 v_batch       number;
 v_recitm      owa.vc_arr;
 v_priceitm    owa.vc_arr;
 itm_ctr       integer;
 v_p3          number;
 v_p4          number;
 xrate		   number(6,4) := 1;
 Interface1	   boolean;
 vClient	   boolean;
 newdlr		   number(8);
 v_curr        varchar2(3) := 'AUD';
 v_io          varchar2(1) := 'I';
 v_gst_code    varchar2(10);
 nlog		   varchar2(9);
 v_user        varchar2(20);
 v_status      varchar2(20) := 'STANDARD';
 --newrid		   rowid;
 v_sa          varchar2(1) := 'S';
 qt            number;
 itn           number(5,2);
 qte           number;
 am            number(15,2);
 tam           number(15,2);
 dc            number(15,2);
 gs            number(15,2);
 oqty          number;
 lno           integer;
 vmsg          varchar2(2000);
 v_grn_status  number := 0;
 v_chk         varchar2(100);
 diffqty       number;
 v_gst_rate    number(15,2);
 v_unit        varchar2(10) := 'NO';
 -- added by DB on 25/3/2022
 f             utl_file.file_type;
 v_jobno       varchar2(100);
 jobno         number;
 qpdf_path     CONSTANT VARCHAR2(100) := 'C:\Program Files\qpdf';     
 qpdf_prog     CONSTANT VARCHAR2(100) := 'qpdf';
 work_dir      VARCHAR2(1000);
 work_file     VARCHAR2(1000);

-- combine invoice pdf files:
 c_pdf_tk      CONSTANT varchar2(100) := 'C:\Program Files (x86)\PDFtk\bin';
 c_cmd_2       CONSTANT varchar2(1000) := 'pdftk.exe';
 v_cmd         varchar2(32767);
 pdf_array     owa.vc_arr;
 outp_array    owa.vc_arr;
 ctr           integer;
 n_umo         integer;
 pdf_trgt_1    varchar2(1000);
 pdf_trgt_2    varchar2(1000);
 pdf_file      varchar2(1000);
 v_gst         number(15,2);
 v_inv_tot     number(15,2);
 v_del_chg     number(15,2);
 v_recno       integer;
 v_rid         owa.vc_arr;
 v_rowid       rowid;
 v_step        varchar2(10);
 v_p10         number;
 v_del_item    number;
 v_ck_qty      number;
 newconvoy	   number;
 v_cnt_detail  number := 1;
 -----------------------------
 dtime         varchar2(20); -- Added by David Banjo
 v_page        number := 0;
 newrid		   rowid;
 convoy_header_newrid rowid;
 v_container   varchar2(20);

begin

glbx.dbg('I am in The only one  ');
 v_batch := batchno;
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'CONVOY_PLAN_LOAD.CONVOY_PLAN_MNG_ACCEPT' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 --vste := strangp.customer_state(c1rec.aid);
 vste := invoice_parser.customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := strangp.data_access( owner_id, 'CONVOY_PLAN_MNG_ACCEPT', null );
 seclevel := oltp.security_role( owner_id );
 v_user := REGEXP_SUBSTR (c1rec.username, '(\S*)') ;

  -- The following if statement was added by DB on 17/11/2021
  if vste = 'BNE' then
   --  dtime := to_char(new_time(sysdate, 'ADT', 'AST'),'HH24:MI:SS');
     dtime := TO_CHAR(current_timestamp at time zone 'AUSTRALIA/BRISBANE','HH24:MI:SS');
  end if;

 if infile.count < 1
  then
   convoy_plan_mng(surl, vtyp, 'No Files Selected');
 end if;

 if upper(action) = 'CREATE CONVOY PLAN' then

    open c2 (batchno, NULL,NULL);
    fetch c2 into c2rec;
    close c2; 
    
    
    open c3a(c2rec.convoy_type, c2rec.convoy_start_date);
    fetch c3a into c3arec;
    if c3a%found then
       msg := 'Invalid action: Convoy Plan for week '||c2rec.week||' with start date '||to_char(c2rec.convoy_start_date, 'fmDD-MON-YYYY')||' and type '||c2rec.convoy_type||' already has entries created<br>';
       convoy_plan_mng(surl, vtyp, msg, batchno => batchno );
       return;
    
    end if;
  
--  delete from strang.convoy_fuel where convoy_id between 8006385 and 8006391; 
--  delete from strang.convoy where convoy_id between 8006385 and 8006391;
--  delete from strang.convoy_details where convoy_id between 8006385 and 8006391;
--  commit;
    
    for r in 0..6 loop 
    
       glbx.dbg('I am in loop '||r);
       select strang.s_convoy_id.nextval into newconvoy from dual;
       for r_convoy_detail in c2 ( batchno, NULL, r) loop
          
          -- added by DB 29/3/2023
          update strang.stg_linehaul_plan
             set convoy_id = newconvoy
               , created_by = v_user
           where rowid = r_convoy_detail.row_id;
       
          if c2%rowcount = 1 then  -- do the convoy table first
             insert into strang.convoy
             (convoy_id, estdepart, date_modified, io, convoyname, status, convoy_type, 
              portload, portdisc, masterplan, no_of_sections) 
             values 
            (newconvoy, r_convoy_detail.convoy_date, sysdate, 'I', r_convoy_detail.convoy_name, 'PLANNING', r_convoy_detail.convoy_type, 
             'KIU', 'TAB', 'YES', 1) returning rowid into convoy_header_newrid;
             
             insert into strang.convoy_fuel(convoy_id) values (newconvoy);
      
          end if;
          if r_convoy_detail.rnk_small = 1 then
             if r_convoy_detail.sheet_number = 1 then
             
                insert into strang.convoy_details
                (convoy_id, rno, truck_id, trailer_id, truck_tanker, convoy_section, operator)
                 values 
                 (newconvoy, r_convoy_detail.rnk_big, r_convoy_detail.truck, r_convoy_detail.trailer,'TRUCK',1,r_convoy_detail.operator) 
                 returning rowid into newrid;
                
             elsif r_convoy_detail.sheet_number = 2 then
             
                insert into strang.convoy_details
                (convoy_id, rno, truck_id, trailer_id, truck_tanker, convoy_section, operator) 
                values (newconvoy,r_convoy_detail.rnk_big,  r_convoy_detail.truck, r_convoy_detail.trailer, 'TANKER',1, r_convoy_detail.operator )
                returning rowid into newrid;
                
             end if;

          end if;
          
          if r_convoy_detail.container is not null then
          
             open c5( r_convoy_detail.container);
             fetch c5 into c5rec;
             if c5%found then
               v_container := r_convoy_detail.container;
               glbx.dbg('found : '||r_convoy_detail.container);
             else
               null;
               glbx.dbg('not found : '||r_convoy_detail.container);
               
             end if;
             close c5;
          end if;
          
          if  r_convoy_detail.rnk_small = 1  then
             
             if v_container is null and r_convoy_detail.container is not null  then
                  update strang.convoy_details
                     set movement_no1 = r_convoy_detail.container
                      ,  container_type1 = substr(r_convoy_detail.cargo_description,1,99)
                      ,  iso_container_type1 = r_convoy_detail.iso_container_type
                      ,  weight1 = r_convoy_detail.weight
                      ,  lookup1 = null
                      ,  full_mt1 = 'FULL'
                   where rowid = chartorowid(newrid);
             elsif v_container is not null then

                  update strang.convoy_details
                     set movement_no1 = c5rec.movement_no       
                      ,  seal1 = c5rec.seal
                      ,  container_type1 = nvl(c5rec.container_type,'BBULK')||' '||strang.f_getLovColumn('CTRTYPE','COLC',c5rec.container_type)
                      ,  iso_container_type1 = c5rec.iso_container_type
                      ,  weight1 = c5rec.weight
                      ,  vessel1 = c5rec.vvoy
                      ,  overdimensional1 = c5rec.overdimensional
                      ,  set_point1 = c5rec.set_point
                      ,  container_owner1 = c5rec.owner
                      ,  consignee1 = c5rec.consignee
                      ,  consignee_location1 = c5rec.consignee_location
                      ,  warehouse_destination1 = c5rec.warehouse_destination
                      ,  hazard1 = substr(strang.f_display_convoy_ctr(c5rec.movement_no,c5rec.seal,'HAZARD'),1,50)
                      ,  urgency1 = c5rec.urgency
                      ,  full_mt1 = c5rec.full_mt
                      ,  lookup1 = null
                   where rowid = chartorowid(newrid);
                 
                  update strang.movements m
                     set m.convoy_id = (select cn.convoy_id from strang.convoy_details cn where cn.rowid = chartorowid(newrid)), m.date_modified = sysdate
                   where m.movement_no=c5rec.movement_no and nvl(m.seal,'|')=nvl(c5rec.seal,'|');	
             end if;
               
          elsif r_convoy_detail.rnk_small = 2 then
             
               if v_container is null and r_convoy_detail.container is not null then
               
                  update strang.convoy_details
                     set movement_no2 = r_convoy_detail.container
                       , container_type2 = substr(r_convoy_detail.cargo_description,1,99)
                       , iso_container_type2 =  r_convoy_detail.iso_container_type
                       , weight2 = r_convoy_detail.weight
                       , lookup2 = null
                       , full_mt2 = 'FULL'
                   where rowid = chartorowid(newrid);
                 
               elsif v_container is not null then
             
                  update strang.convoy_details
                     set movement_no2 = c5rec.movement_no       
                        ,seal2 = c5rec.seal
                        ,container_type2 = nvl(c5rec.container_type,'BBULK')||' '||strang.f_getLovColumn('CTRTYPE','COLC',c5rec.container_type)
                        ,iso_container_type2 = c5rec.iso_container_type
                        ,weight2 = c5rec.weight
                        ,vessel2 = c5rec.vvoy
                        ,overdimensional2 = c5rec.overdimensional
                        ,set_point2 = c5rec.set_point
                        ,container_owner2 = c5rec.owner
                        ,consignee2 = c5rec.consignee
                        ,consignee_location2 = c5rec.consignee_location
                        ,warehouse_destination2 = c5rec.warehouse_destination
                        ,hazard2 = substr(strang.f_display_convoy_ctr(c5rec.movement_no,c5rec.seal,'HAZARD'),1,50)
                        ,urgency2 = c5rec.urgency
                        ,full_mt2 = c5rec.full_mt
                        ,lookup2 = null
                   where rowid = chartorowid(newrid);
             
                   update strang.movements m
                      set m.convoy_id = (select cn.convoy_id from strang.convoy_details cn where cn.rowid = chartorowid(newrid)), m.date_modified = sysdate
                    where m.movement_no=c5rec.movement_no and nvl(m.seal,'|')=nvl(c5rec.seal,'|');	
                   
               end if;
                
          elsif r_convoy_detail.rnk_small = 3 then   
             
                if v_container is null and r_convoy_detail.container is not null then
               
                  update strang.convoy_details
                     set movement_no3 = r_convoy_detail.container
                       , container_type3 = substr(r_convoy_detail.cargo_description,1,99)
                       , iso_container_type3 =  r_convoy_detail.iso_container_type
                       , weight3 = r_convoy_detail.weight
                       , lookup3 = null
                       , full_mt3 = 'FULL'
                   where rowid = chartorowid(newrid);
                 
                elsif v_container is not null then
             
                   update strang.convoy_details
                      set movement_no3 = c5rec.movement_no       
                        , seal3 = c5rec.seal
                        , container_type3 = nvl(c5rec.container_type,'BBULK')||' '||strang.f_getLovColumn('CTRTYPE','COLC',c5rec.container_type)
                        , iso_container_type3 = c5rec.iso_container_type
                        , weight3 = c5rec.weight
                        , vessel3 = c5rec.vvoy
                        , overdimensional3 = c5rec.overdimensional
                        , set_point3 = c5rec.set_point
                        , container_owner3 = c5rec.owner
                        , consignee3 = c5rec.consignee
                        , consignee_location3 = c5rec.consignee_location
                        , warehouse_destination3 = c5rec.warehouse_destination
                        , hazard3 = substr(strang.f_display_convoy_ctr(c5rec.movement_no,c5rec.seal,'HAZARD'),1,50)
                        , urgency3 = c5rec.urgency
                        , full_mt3 = c5rec.full_mt
                        , lookup3 = null
                    where rowid = chartorowid(newrid);
             
                   update strang.movements m
                      set m.convoy_id = (select cn.convoy_id from strang.convoy_details cn where cn.rowid = chartorowid(newrid)), m.date_modified = sysdate
                    where m.movement_no=c5rec.movement_no and nvl(m.seal,'|')=nvl(c5rec.seal,'|');	
                    
                end if;
             
           elsif r_convoy_detail.rnk_small = 4 then   
             
             
                if v_container is null and r_convoy_detail.container is not null then
               
                   update strang.convoy_details
                     set movement_no4 = r_convoy_detail.container
                       , container_type4 = substr(r_convoy_detail.cargo_description,1,99)
                       , iso_container_type4 =  r_convoy_detail.iso_container_type
                       , weight4 = r_convoy_detail.weight
                       , lookup4 = null
                       , full_mt4 = 'FULL'
                   where rowid = chartorowid(newrid);
                 
                elsif v_container is not null then
                
                   update strang.convoy_details
                      set movement_no4 = c5rec.movement_no       
                        , seal4 = c5rec.seal
                        , container_type4 = nvl(c5rec.container_type,'BBULK')||' '||strang.f_getLovColumn('CTRTYPE','COLC',c5rec.container_type)
                        , iso_container_type4 = c5rec.iso_container_type
                        , weight4 = c5rec.weight
                        , vessel4 = c5rec.vvoy
                        , overdimensional4 = c5rec.overdimensional
                        , set_point4 = c5rec.set_point
                        , container_owner4 = c5rec.owner
                        , consignee4 = c5rec.consignee
                        , consignee_location4 = c5rec.consignee_location
                        , warehouse_destination4 = c5rec.warehouse_destination
                        , hazard4 = substr(strang.f_display_convoy_ctr(c5rec.movement_no,c5rec.seal,'HAZARD'),1,50)
                        , urgency4 = c5rec.urgency
                        , full_mt4 = c5rec.full_mt
                        , lookup4 = null
                    where rowid = chartorowid(newrid);
             
                   update strang.movements m
                      set m.convoy_id = (select cn.convoy_id from strang.convoy_details cn where cn.rowid = chartorowid(newrid)), m.date_modified = sysdate
                    where m.movement_no=c5rec.movement_no and nvl(m.seal,'|')=nvl(c5rec.seal,'|');	
               
                 end if;
                    
          
          elsif r_convoy_detail.rnk_small = 5 then   
             
             if v_container is null and r_convoy_detail.container is not null then
               
                update strang.convoy_details
                   set movement_no5 = r_convoy_detail.container
                    , container_type5 = substr(r_convoy_detail.cargo_description,1,99)
                    , iso_container_type5 =  r_convoy_detail.iso_container_type
                    , weight5 = r_convoy_detail.weight
                    , lookup5 = null
                    , full_mt5 = 'FULL'
                 where rowid = chartorowid(newrid);
                 
             elsif v_container is not null then
             
                update strang.convoy_details
                   set movement_no5 = c5rec.movement_no       
                        , seal5 = c5rec.seal
                        , container_type5 = nvl(c5rec.container_type,'BBULK')||' '||strang.f_getLovColumn('CTRTYPE','COLC',c5rec.container_type)
                        , iso_container_type5 = c5rec.iso_container_type
                        , weight5 = c5rec.weight
                        , vessel5 = c5rec.vvoy
                        , overdimensional5 = c5rec.overdimensional
                        , set_point5 = c5rec.set_point
                        , container_owner5 = c5rec.owner
                        , consignee5 = c5rec.consignee
                        , consignee_location5 = c5rec.consignee_location
                        , warehouse_destination5 = c5rec.warehouse_destination
                        , hazard5 = substr(strang.f_display_convoy_ctr(c5rec.movement_no,c5rec.seal,'HAZARD'),1,50)
                        , urgency5 = c5rec.urgency
                        , full_mt5 = c5rec.full_mt
                        , lookup5 = null
                    where rowid = chartorowid(newrid);
             
                   update strang.movements m
                      set m.convoy_id = (select cn.convoy_id from strang.convoy_details cn where cn.rowid = chartorowid(newrid)), m.date_modified = sysdate
                    where m.movement_no=c5rec.movement_no and nvl(m.seal,'|')=nvl(c5rec.seal,'|');	
                    
             end if;
          
          elsif r_convoy_detail.rnk_small = 6 then   
          
             if v_container is null and r_convoy_detail.container is not null then
               
                update strang.convoy_details
                   set movement_no6 = r_convoy_detail.container
                    , container_type6 = substr(r_convoy_detail.cargo_description,1,99)
                    , iso_container_type6 =  r_convoy_detail.iso_container_type
                    , weight6 = r_convoy_detail.weight
                    , lookup6 = null
                    , full_mt6 = 'FULL'
                 where rowid = chartorowid(newrid);
                 
             elsif v_container is not null then
             
                update strang.convoy_details
                   set movement_no6 = c5rec.movement_no       
                        , seal6 = c5rec.seal
                        , container_type6 = nvl(c5rec.container_type,'BBULK')||' '||strang.f_getLovColumn('CTRTYPE','COLC',c5rec.container_type)
                        , iso_container_type6 = c5rec.iso_container_type
                        , weight6 = c5rec.weight
                        , vessel6 = c5rec.vvoy
                        , overdimensional6 = c5rec.overdimensional
                        , set_point6 = c5rec.set_point
                        , container_owner6 = c5rec.owner
                        , consignee6 = c5rec.consignee
                        , consignee_location6 = c5rec.consignee_location
                        , warehouse_destination6 = c5rec.warehouse_destination
                        , hazard6 = substr(strang.f_display_convoy_ctr(c5rec.movement_no,c5rec.seal,'HAZARD'),1,50)
                        , urgency6 = c5rec.urgency
                        , full_mt6 = c5rec.full_mt
                        , lookup6 = null
                    where rowid = chartorowid(newrid);
             
                   update strang.movements m
                      set m.convoy_id = (select cn.convoy_id from strang.convoy_details cn where cn.rowid = chartorowid(newrid)), m.date_modified = sysdate
                    where m.movement_no=c5rec.movement_no and nvl(m.seal,'|')=nvl(c5rec.seal,'|');	
                    
               end if;
          
           end if;
          
           v_cnt_detail := v_cnt_detail+ 1;
           v_container := null;

          
       end loop;
    
    end loop;

    commit;
    
    if msg is not null then
       convoy_plan_mng(surl, vtyp, msg, batchno => v_batch );
    else
      strangp.manentry( surl, convoy_header_newrid, c4rec.screen_id, 'strangp.manentry', 'ME', 'x', msg );
    end if;
    return;
 
 
 end if;

 if upper (action) not like 'LOAD CONVOY PLAN%'
  then
   convoy_plan_mng(surl,  vtyp, 'Invalid action: ' || action);
   return;
 end if;
 
 
 for j in infile.first..infile.last loop
 
  open c3(infile(j));
  fetch c3 into c3rec;
  if c3%FOUND
   then
    close c3;
    v_dir :=  'P:\piction\shared\convoy_plan\' || to_char(sysdate,'YYYYMM')|| decs.UNIX_OR_NT;
	v_file :=  glbx.extract_fname(c3rec.name, 'FILE');

    if chkval is not null
	 then
	  msg := msg || chkval || '<br>';
	else
      if utl_os.mkdir(v_dir) then null; end if;
      utl_blob.blobtofile(c3rec.blob_content, v_dir || decs.UNIX_OR_NT || v_file, FALSE);
	  if file_exists(v_dir, v_file)
	   then
	    null;
	    WEBSYS.accept_ingest_convoy_file(infile(j), upper(action), v_batch);
      else
	    msg := msg || 'File NOT saved: ' || v_file || '<br>';
	   end if;
  end if;
  else
  close c3;
  end if;
  delete from apache_ows_content where name = infile(j); commit;
 end loop;
 
 convoy_plan_mng(surl, vtyp, msg, batchno => v_batch );
exception when others then
 glbx.dbg( 'v_step: '||v_step);
 glbx.dbg('Error: ' || sqlerrm);
 htp.bold('Error: ' || sqlerrm);
 glbx.error_details( 'CONVOY_PLAN_LOAD', 'CONVOY_PLAN_MNG_ACCEPT',null,owner_id,errmsg=>sqlerrm,extdet=>'PARM:' ||'CONVOY');
end convoy_plan_mng_accept;
 
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
    if lname in ('INOUT') and parm in ('P2a') then
      htp.formselectopen( cname=>'P2', cattributes=>'id="'||parm||'"'||' ONCHANGE="convoy_direction_switch()"' );  
    elsif lname in ('LOCATIONS') and parm in ('P2b', 'P2c') then
      htp.formselectopen( cname=>'P2', cattributes=>'id="'||parm||'"'  );
    else     
       htp.formselectopen( cname=>parm, cattributes=>'id="'||parm||'" class="'||parm||'"');
    end if;
    if not ismand then htp.formselectoption( NULL ); end if;
    for c1rec in c1( lname, snd, xtr_a, xtr_b ) loop
     if (cd is not null) and (cd = c1rec.code)
      then
       if showdesc
        then
         if showcola
          then
           htp.formselectoption( c1rec.code || '-' || c1rec.cola, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
           fval := TRUE;
          else
           htp.formselectoption( c1rec.description, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
           fval := TRUE;
        end if;
       else
         if showcola then
            htp.formselectoption( c1rec.code|| '-' || c1rec.cola, 'SELECTED', cattributes=>'VALUE="' || c1rec.code|| '"' );
            fval := TRUE;
         else
            htp.formselectoption( c1rec.code, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
            fval := TRUE;
         end if;
       end if;
      else
       if showdesc
        then
         if showcola
          then
           htp.formselectoption( c1rec.code || '-' || c1rec.cola, cattributes=>'VALUE="' || c1rec.code || '"' );
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
 
end convoy_plan_load;
/
