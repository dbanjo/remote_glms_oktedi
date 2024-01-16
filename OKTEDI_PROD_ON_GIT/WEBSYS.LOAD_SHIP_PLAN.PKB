CREATE OR REPLACE PACKAGE BODY WEBSYS.LOAD_SHIP_PLAN
as

procedure LOCAL_SHIP_PLAN_MNG(surl in varchar2, vtyp varchar2 default 'LOAD_SHIP_PLAN', action in varchar2, msg in varchar2 default null, batchno number default null) as

cursor c1a (v_batchno number) is
   select max(batch_id) batch_id, max(title) title, min(week) week, min(loading_date) loading_date
     from STRANG.stg_local_ship_plan a
    where a.batch_id = v_batchno
      and sheet_number = 1;
  
cursor c2a (v_batchno number) is
   select a.*, rownum rowno, m.rowid row_id
     from STRANG.stg_local_ship_plan a, strang.movements m
    where a.batch_id = v_batchno
      and m.MOVEMENT_TYPE (+) <> 'AIRWAY'
      and m.movement_no (+) = a.container
      and m.ship_id (+) = a.intl_ship_id
      and a.sheet_number = 1
  order by load_number;

 cursor c3 is
  select mo.name, mv.name_default
  from   main_object mo, main_value mv
  where  mo.mid = mv.mid
         and mo.theme_type = 'STRANG_TMP_RECEIVALS_FOLDERS';
  
cursor c4( sname varchar2 ) is select screen_id from oltp_overview where screen_name = sname;
  
-- cursor c5 (v_batchno number) is
--   select *
--    from STRANG.stg_local_ship_plan a
--  where  a.batch_id = v_batchno
--    and  sheet_number = 2
--  order by record, convoy_date, load_number;
  
 cursor c6 (v_batchno number) is
 select case when error_load_number > 0 then 'Error: Load Number(s) incorrect. Please amend Load Number(s) and reload the Local Shipping Plan.' 
             when error_load_date_s > 0 then 'Error: Load Date(s) earlier than corresponding Intl Ship arrival date. Please amend and reload the Local Shipping Plan.'
             when error_load_date_e > 0 then 'Error: Load Date(s) later than corresponding local Ship departure date. Please amend and reload the Local Shipping Plan.'
             when error_load_date_n > 0 then 'Error: Load Date(s) invalid. Please amend and reload the Local Shipping Plan.'
             when error_local_vessel > 0 then 'Error: Local vessel(s) non existent. Please amend and reload the Local Shipping Plan.'
             when error_intl_vessel > 0 then 'Error: Container(s) not in the corresponding intl vessel. Please amend and reload the Local Shipping Plan.'
             when error_container > 0 then 'Error: Container(s) not in the International vessel or default Intl Ship. Please check Intl Ship to container assignment!'  
             when error_load_date_l > 0 then 'Warning: Load Date(s) earlier than today''s date. The affected container(s) will not be assigned to Local Vessel.'
             else 'Local Ship Plan uploaded and verified. Click "Assign Containers to Local Ships" button to proceed' end msg,
           case when  error_intl_vessel + error_local_vessel + error_load_date_s + error_load_date_e + error_load_date_n + error_load_number + error_container > 0 then 'N' else 'Y' end proceed 
   from (select sum (case when valid_load_number = 'N' then 1 else 0 end) over () error_load_number,
          sum (case when valid_load_date = 'L' then 1 else 0 end) over () error_load_date_l,
          sum (case when valid_load_date = 'S' then 1 else 0 end) over () error_load_date_s,
          sum (case when valid_load_date = 'E' then 1 else 0 end) over () error_load_date_e,
          sum (case when valid_load_date = 'N' then 1 else 0 end) over () error_load_date_n,
          sum (case when valid_local_vessel = 'X' then 1 else 0 end) over () error_local_vessel,
          sum (case when valid_intl_vessel = 'X' then 1 else 0 end) over () error_intl_vessel,
          sum (case when valid_container = 'N' then 1 else 0 end) over () error_container,
          sum (case when valid_container_type = 'N' then 1 else 0 end) over () error_container_type,
          row_number() over ( order by nvl(valid_container,'Y'),NVL(valid_load_number,'Y')
                     , NVL(valid_local_vessel,'N'), NVL(valid_intl_vessel,'N'), case when upper(valid_load_date) = 'L' then 'Z' else upper(valid_load_date) end ) rnk
    from STRANG.stg_local_ship_plan a
  where  a.batch_id = v_batchno
  ) tmp
 where rnk = 1 ;

 INVALID_RID exception;
 PRAGMA EXCEPTION_INIT(INVALID_RID, -1410);

 c1rec          customer_account%ROWTYPE;
 po_item_list   owa.vc_arr default glbx.empty_array;
 c1arec         c1a%ROWTYPE;
-- c2rec          c2%ROWTYPE;
 c2arec         c2a%ROWTYPE;
 c4rec          c4%ROWTYPE;
-- c5rec          c5%ROWTYPE;
 c6rec          c6%ROWTYPE;
 --c4rec          c4%ROWTYPE;
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

begin

 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LOAD_SHIP_PLAN.LOCAL_SHIP_PLAN_MNG' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;
 v_full_proceed := 'NO';
 c1rec    := glbx.get_aid( owner_id, 'C', ltype );
 vste     := load_ship_plan.customer_state(c1rec.aid);
 pfx      := glbx.get_thm( c1rec.theme_name );
 vaccess  := strangp.data_access( owner_id, 'LOCAL_SHIP_PLAN_MNG', null );
 seclevel := oltp.security_role( owner_id );
 
 open c2a(batchno);
 fetch c2a into c2arec;
 if c2a%notfound and batchno is not null then
    if msg is not null then
       vmsg := msg;
    else 
       vmsg := 'Excel file loaded contains incorrect Local Shipping Plan entries';
    end if;
 elsif  c2a%notfound and batchno is null then
    vmsg := msg;
 elsif msg is not null and batchno is not null then 
    vmsg := msg; 
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
 htp.header(1,'Load Biweekly Local Ship Plan (in Excel *.xlsx format) for processing', 'CENTER' );
 
 if msg is null and vmsg is null then
    htp.nl;
 end if;
 
 if msg is not null then
    htp.header(1, msg, cattributes=>'style="color: red;"');
 elsif vmsg is not null then
    htp.header(1, vmsg, cattributes=>'style="color: red;"');
 end if;
 
 htp.formopen('LOAD_SHIP_PLAN.local_ship_plan_accept', 'POST', null, 'multipart/form-data', cattributes=>'name="item_box"' );
 htp.formhidden('SURL', surl );
 htp.formhidden('VTYP', vtyp );
 htp.formhidden('BATCHNO', batchno);
 htp.tableopen;
 
 for c3rec in c3 loop
    v_url := htf.anchor('javascript: window.open(''' || '/local_ship_plan/' || to_char(sysdate,'YYYYMM') || '/' || ''',''' || 'vtyp' || ''',''height=800,width=600,scrollbars=yes,resizable=yes'');void('''');', 'Month''s Uploads' );
    htp.tablerowopen;
    if c3%ROWCOUNT = 1 then
       htp.tabledata(htf.formfile('infile', file_types, 'multiple'));
	else
       htp.tabledata('&nbsp;');
	end if;

    htp.tabledata(htf.formsubmit('action', 'Load Local Ship Plan')); --  || c3rec.name_default));
    if batchno is not null then 
       if v_full_proceed = 'YES' and NVL(action, 'XXX') <> 'LOADED' then 
          htp.tabledata('<INPUT TYPE="submit" NAME="action" VALUE="Assign Containers to Local Ships" onclick="return confirm(''Are you definitely sure you want to Update the Local Ship Plan?'');">');
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
     
     htp.tableopen ( CATTRIBUTES=>'style="font-size:18px;"');
     htp.tablerowopen;
     htp.tableheader('Local Ship Plan Batch ID: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata(c1arec.batch_id,cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen; 
     htp.tableheader('Local Ship Plan Title: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata('WK_'||to_char(c1arec.week)||' '||'LOCAL SHIP ASSIGNMENT PLAN' , cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen; 
     htp.tableheader('Ship Direction: ', cattributes=>'style="text-align:left; border-bottom:1px solid #663; border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     --htp.tabledata('INBOUND' , cattributes=>'style="font-weight:bold;"');
     htp.p('<TD style="color:blue; font-weight:bold; ">
           <div class="blink">INBOUND ONLY</div></TD>');
     htp.tablerowclose;
     htp.tableclose;
     htp.nl;
    
     htp.nl;
     htp.tableopen;
     htp.tablerowopen;

     htp.tableheader('Load<BR>No.');
     htp.tableheader('Material');
     htp.tableheader('Priority');
     htp.tableheader('Urgency');
     htp.tableheader('Container');
     htp.tableheader('Contr.<BR>size');
     htp.tableheader('Contr.<BR>weight');
     htp.tableheader('SAP<br>Material<BR>Code');
     htp.tableheader('Loading Date<BR>Draft');
     htp.tableheader('Local Vessel<BR>Draft');
     htp.tableheader('Local Voyage<BR>Draft');
     htp.tableheader('Local Ship ID');
     htp.tableheader('Intl Vessel<BR>Draft');
     htp.tableheader('Intl Voyage<BR>Draft');
     htp.tableheader('Intl Ship ID');
     htp.tableheader('Location');
     if action = 'LOADED' then
       htp.tableheader('Status');
     end if;
    -- htp.tableheader('Error Description');
     htp.tablerowclose;
           
           for c2arec in c2a ( batchno)
           loop
             c := c + 1;

             if mod(c2arec.rowno,2) = 1 then
                htp.tablerowopen ;
             else
               htp.tablerowopen ( cattributes=>'style="background-color:#eefff8;"') ;
             end if;       
             
             if c2arec.valid_load_number = 'Y' then
                htp.tabledata(c2arec.load_number);
             else
                htp.tabledata(c2arec.load_number, cattributes=>'style="color:red"');
             end if;
            
             htp.tabledata(c2arec.cargo_description);
             htp.tabledata(c2arec.priority);
             htp.tabledata(c2arec.urgency);
             
             
             if c2arec.container is not null then
             
               if action = 'LOADED' then
                 htp.tabledata( htf.anchor('STRANGP.movement?surl=' || surl || '&rid=' || replace(c2arec.row_id, '+', '~') ||'&scid=&call_name=LOAD_SHIP_PLAN.LOCAL_SHIP_PLAN_MNG&parm=CARGO&access_id=x&msg=&call_name=LOCAL_SHIP_PLAN_MNG', c2arec.container));
               else
                  if c2arec.valid_container = 'Y' then
                     --  htp.tabledata(c2arec.container);
                     htp.p('<TD style="color:black">
                       <DIV CLASS="tooltip">'||c2arec.container||
                      '<SPAN CLASS="tooltiptext">'||c2arec.container||' on '||c2arec.intl_vessel||'('||c2arec.intl_voyage||')</SPAN>
                       </DIV></TD>');
                  else
                     --  v_full_proceed := 'NO';
                     htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.container||
                      '<SPAN CLASS="tooltiptext">'||c2arec.container||' is not on '||c2arec.intl_vessel||'('||c2arec.intl_voyage||')</SPAN>
                       </DIV></TD>');
                  end if;
               end if;
             else 
                htp.tabledata(c2arec.container, cattributes=>'style="background-color:lightgrey;"');
             end if;
             
             
             if nvl(c2arec.valid_container_type, 'N') = 'Y' then
                htp.tabledata(c2arec.container_type);
             else
                 htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.container_type||
                      '<SPAN CLASS="tooltiptext">Container Type: '||c2arec.container_type||' is not valid</SPAN>
                       </DIV></TD>');
             end if;
             
             htp.tabledata(c2arec.weight);
             htp.tabledata(c2arec.material_code);

            if NVL(c2arec.valid_load_date, 'N') = 'Y' then
                htp.tabledata(c2arec.loading_date);
             elsif NVL(c2arec.valid_load_date, 'N') = 'L' then
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.loading_date|| 
                      '<SPAN CLASS="tooltiptext">Loading Date: '||c2arec.loading_date||' is earlier than today''s date</SPAN>
                       </DIV></TD>');
             elsif NVL(c2arec.valid_load_date, 'N') = 'S' then
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.loading_date||
                      '<SPAN CLASS="tooltiptext">Loading Date: '||c2arec.loading_date||' is earlier than Intl Ship arrival date</SPAN>
                       </DIV></TD>');
             elsif NVL(c2arec.valid_load_date, 'N') = 'E' then
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.loading_date||
                      '<SPAN CLASS="tooltiptext">Loading Date: '||c2arec.loading_date||' is later than local ship departure date</SPAN>
                       </DIV></TD>');
             else
               htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.loading_date||
                      '<SPAN CLASS="tooltiptext">Loading Date: '||c2arec.loading_date||' is invalid</SPAN>
                       </DIV></TD>');
             end if;
             
             if NVL(c2arec.valid_local_vessel,'X') = 'Y' then
                htp.tabledata(c2arec.local_vessel);
             else
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.local_vessel||
                      '<SPAN CLASS="tooltiptext">Local Vessel: '||c2arec.local_vessel||'('||c2arec.local_voyage||') is not valid</SPAN>
                       </DIV></TD>');
             end if;
             
             if NVL(c2arec.valid_local_vessel,'X') = 'Y' then
                htp.tabledata(c2arec.local_voyage);
             else
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.local_voyage||
                      '<SPAN CLASS="tooltiptext">Local Voyage: '||c2arec.local_vessel||'('||c2arec.local_voyage||') is not valid</SPAN>
                       </DIV></TD>');
             end if;
             
             if NVL(c2arec.valid_local_vessel,'X') = 'Y' then
                htp.tabledata(c2arec.local_ship_id);
             else
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.local_ship_id||
                      '<SPAN CLASS="tooltiptext">Local Ship ID: '||c2arec.local_ship_id||' is not valid</SPAN>
                       </DIV></TD>');
             end if;
             
             if NVL(c2arec.valid_intl_vessel,'X') = 'Y' then
                htp.tabledata(c2arec.intl_vessel);
             else
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.intl_vessel||
                      '<SPAN CLASS="tooltiptext">Intl Vessel: '||c2arec.intl_vessel||'('||c2arec.intl_voyage||') does not contain '||c2arec.container||'.</SPAN>
                       </DIV></TD>');
             end if;
             
             if NVL(c2arec.valid_intl_vessel,'X') = 'Y' then
                htp.tabledata(c2arec.intl_voyage);
             else
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.intl_voyage||
                      '<SPAN CLASS="tooltiptext">Intl Vessel: '||c2arec.intl_vessel||'('||c2arec.intl_voyage||') does not contain '||c2arec.container||'.</SPAN>
                       </DIV></TD>');
             end if;
             
             if NVL(c2arec.valid_intl_vessel,'X') = 'Y' then
                htp.tabledata(c2arec.intl_ship_id);
             else
                htp.p('<TD style="color:red">
                       <DIV CLASS="tooltip">'||c2arec.intl_ship_id||
                      '<SPAN CLASS="tooltiptext">Intl Ship ID: '||c2arec.intl_ship_id||' does not contain '||c2arec.container||'.</SPAN>
                       </DIV></TD>');
             end if;
             
             
             htp.tabledata(c2arec.current_location);
             
             if action = 'LOADED' then
             
                if c2arec.created_by is not null then
                   htp.tabledata('Success');
                else 
                   htp.tabledata('Failed', cattributes=>'style="color:red"');
                end if;
             
             end if;
             
               
             htp.tablerowclose;
             v_inventory := null;
             v_po_item := null;

           end loop;
           po_item_list := glbx.empty_array;
              
  
  htp.tableclose;
  htp.nl;
  htp.nl;
  

--   
 end if;
 
 if batchno is not null then 
    if v_full_proceed = 'YES' and NVL(action, 'XXX') <> 'LOADED'then 
       htp.formsubmit('action','Assign Containers to Local Ships');
    end if;
 end if;

  htp.formclose;
  htp.nl;
  htp.nl;
  htp.bold('<a href="" onClick="self.close()">[Close Window]</a>');
  htp.p('</CENTER>');

 htp.bodyclose;
 htp.htmlclose;
end local_ship_plan_mng;

procedure local_ship_plan_accept( surl in varchar2, vtyp varchar2, infile in owa.vc_arr default glbx.empty_array
                                , action varchar2, batchno number default null
                                , p12 in varchar2 default null                                
                                ) as
                            
  cursor c2 (v_batch integer ) is 
    select lp.*, lp.rowid lp_rowid, m.rowid m_rowid
       from STRANG.stg_local_ship_plan lp, strang.movements m
       where m.movement_no = lp.container
        and  m.ship_id = lp.intl_ship_id
         and lp.batch_id = v_batch
         and valid_intl_vessel = 'Y'
         and valid_local_vessel = 'Y'
         and valid_container = 'Y'
         and valid_load_number = 'Y'
         and nvl(valid_load_date, '|') not in ('E','S','N','L')
        order by load_number;

cursor c3(v_file varchar2) is select * from apache_ows_content where name = v_file;
cursor c4( sname varchar2 ) is select screen_id from oltp_overview where screen_name = sname;

cursor c5( v_rowid varchar2 ) is select movement_no, ship_id from strang.movements m where m.rowid = v_rowid;

            
 c1rec         customer_account%ROWTYPE;
 c2rec         c2%ROWTYPE;
 c3rec         c3%ROWTYPE;
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
 v_msg         varchar2(100);

begin

--select *
--from websys.debug order by ctr;

 v_batch := batchno;
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'LOAD_SHIP_PLAN.LOCAL_SHIP_PLAN_ACCEPT' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := LOAD_SHIP_PLAN.customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := strangp.data_access( owner_id, 'LOCAL_SHIP_PLAN_ACCEPT', null );
 seclevel := oltp.security_role( owner_id );
 v_user := REGEXP_SUBSTR (c1rec.account_name, '(\S*)') ;

  -- The following if statement was added by DB on 17/11/2021
  if vste = 'BNE' then
     dtime := TO_CHAR(current_timestamp at time zone 'AUSTRALIA/BRISBANE','HH24:MI:SS');
  end if;

 if upper(action) = 'ASSIGN CONTAINERS TO LOCAL SHIPS' then
    ctr := 0;
    for record_c2 in  c2 (batchno) loop
   
       open c5 (record_c2.m_rowid);
       fetch c5 into c5rec;
       if c5%found then
       
          update strang.movements m
            set local_ship_id = record_c2.local_ship_id
          where m.rowid = record_c2.m_rowid;
          
          update STRANG.stg_local_ship_plan lp
            set  created_by = v_user
               , create_date = sysdate
          where lp.rowid = record_c2.lp_rowid;
          
          ctr := ctr + 1;
        
       end if; 
       close c5;
      
    end loop;
    
    commit;
  
    
--    if msg is not null then
--       local_ship_plan_mng(surl, vtyp, msg, batchno => v_batch );
--    else
       msg:= 'You have successfully updated '||ctr||' containers! Close Window to continue';
       local_ship_plan_mng(surl, vtyp, 'LOADED', msg, batchno => v_batch );
       
     --  strangp.manentry( surl, convoy_header_newrid, c4rec.screen_id, 'strangp.manentry', 'ME', 'x', msg );
--    end if;
    return;
 
 
 end if;

 if upper (action) not like '%LOAD LOCAL SHIP PLAN%'
  then
   local_ship_plan_mng(surl,  vtyp, 'Invalid action: ' || action);
   return;
 end if;
 
 if infile.count < 1
  then
   local_ship_plan_mng(surl, vtyp, 'No Files Selected');
 end if;
 
 for j in infile.first..infile.last loop
 
 
  open c3(infile(j));
  fetch c3 into c3rec;
  if c3%FOUND
   then
    close c3;
    v_dir :=  'P:\piction\shared\local_ship_plan\' || to_char(sysdate,'YYYYMM')|| decs.UNIX_OR_NT;
	v_file :=  glbx.extract_fname(c3rec.name, 'FILE');

    if chkval is not null
	 then
	  msg := msg || chkval || '<br>';
	else
      if utl_os.mkdir(v_dir) then null; end if;
      utl_blob.blobtofile(c3rec.blob_content, v_dir || decs.UNIX_OR_NT || v_file, FALSE);
	  if file_exists(v_dir, v_file)
	   then
	      websys.load_ship_plan.accept_ingest_ships_file(infile(j), upper(action), v_batch, v_msg);
	      if v_msg is not null then
	        local_ship_plan_mng(surl, vtyp, 'Load Local Ship Plan',msg => v_msg, batchno => v_batch );
	        return;
	      end if;
	      
      else
	    msg := msg || 'File NOT saved: ' || v_file || '<br>';
	  end if;
  end if;
  else
  close c3;
  end if;
  delete from apache_ows_content where name = infile(j); commit;
 end loop;
 
 local_ship_plan_mng(surl, vtyp, msg, batchno => v_batch );
exception when others then
 glbx.dbg( 'v_step: '||v_step);
 glbx.dbg('Error: ' || sqlerrm);
 htp.bold('Error: ' || sqlerrm);
end local_ship_plan_accept;
 
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
 

procedure accept_ingest_ships_file(infile varchar2, action varchar2, batchno out number, p_msg out varchar2)
as
cursor c1(v_file varchar2) is select * from apache_ows_content where name = v_file;

cursor c2(v_shipname varchar2,v_voy varchar2, v_container varchar2 ) 
is
select m.movement_no, m.seal, m.iso_container_type, m.urgency
     , m.sumweight, m.sumvolume,  ss.estarrive, ss.estdepart, ss.voy
     , ss.shipname, ss.ship_id, ss.portdisc, l.cola, m.local_ship_id
  from strang.movements m, strang.ships_airway ss, strang.lov l
 where m.ship_id = ss.ship_id  
   and m.movement_no = v_container
   and upper(ss.shipname) = Upper(trim(v_shipname))
   and upper(ss.voy) = upper(trim(v_voy))
   and ss.io = 'I'
   and ss.li = 'I' 
   and l.lov_name = 'UNCTNTAB'
   and l.code = m.iso_container_type
   and ss.ship_airway = 'S'
   and nvl(m.complete,'XX') not in ( 'H', 'D');
      
 cursor c3(v_shipname varchar2,v_voy varchar2) 
is
select ss.estarrive, ss.voy, ss.estdepart
     , ss.shipname, ss.ship_id local_ship_id, ss.portdisc
  from strang.ships_airway ss
 where upper(ss.shipname) = Upper(trim(v_shipname))
   and upper(ss.voy) = Upper(trim(v_voy))
   and ss.io = 'I'
   and ss.li = 'L' 
   and ss.ship_airway = 'S'
   and ss.status <> 'ARCHIVED';

   
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
  (select blob_content 
     from apache_ows_content 
    where name = infile )))
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
      
   

v_batch               number;
c1rec                 c1%rowtype;
c2rec                 c2%rowtype;
c3rec                 c3%rowtype;
--c4rec                 c4%rowtype;
--c5rec                 c5%rowtype;
c6rec                 c6%rowtype;
c7rec                 c7%rowtype;
c8rec                 c8%rowtype;
v_clb                 clob;
v_array               owa.vc_arr;
line_array            glbx.myarray;
stp                   varchar2(1000);
msg                   varchar2(4000);
r_ctr                 integer;
v_count               integer;
v_title1              varchar2(500);
v_title2              varchar2(500);
v_week                integer;
v_day                 varchar2(50);
v_valid_day           varchar2(1);
v_valid_convoy_dt     varchar2(1);
v_stg_load_dt         varchar2(50);  -- just added
v_load_dt             date;          -- just added
v_valid_load_dt       varchar2(1);   -- just added
v_load                integer;
v_valid_load_number   varchar2(1);
v_container_type      varchar2(50);
v_cargo_desc          varchar2(1000);
v_tot_weight          number(10,4);
record_linehaul       strang.stg_local_ship_plan%rowtype;
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
v_material            varchar2(500);
n_material            number(10,4);
a_material            owa.vc_arr default glbx.empty_array;

v_local_vessel        varchar2(500);
a_local_vessel        owa.vc_arr default glbx.empty_array;
a_local_vessel_valid  owa.vc_arr default glbx.empty_array;

v_local_voyage        varchar2(500);
a_local_voyage        owa.vc_arr default glbx.empty_array;
a_local_voyage_valid  owa.vc_arr default glbx.empty_array;

v_intl_vessel        varchar2(500);
a_intl_vessel        owa.vc_arr default glbx.empty_array;
a_intl_vessel_valid  owa.vc_arr default glbx.empty_array;

v_intl_voyage        varchar2(500);
a_intl_voyage        owa.vc_arr default glbx.empty_array;
a_intl_voyage_valid  owa.vc_arr default glbx.empty_array;

v_current_location   varchar2(500);
a_current_location   owa.vc_arr default glbx.empty_array;
a_current_location_valid owa.vc_arr default glbx.empty_array;

v_tare                varchar2(500);
n_tare                number(10,4);
a_tare                owa.vc_arr default glbx.empty_array;
v_convoy_type         varchar2(500);
v_sheet_number        integer;
v_record              integer := 0;
a_iso_container_type  owa.vc_arr default glbx.empty_array;
v_week_check          varchar2(20) := to_char(strangp.WEEK_OF_YEAR(strangp.trunc_to_week_start(sysdate)));
v_plan_sheet_name     varchar2(100);
v_priority            integer;
v_material_no         varchar2(100);
v_location            varchar2(100);
v_local_vessel2       varchar2(100);
v_local_voyage2       varchar2(100);
v_local_ship_id       varchar2(100);
v_local_estdepart     varchar2(100);
v_intl_vessel2        varchar2(100);
v_intl_voyage2        varchar2(100);
v_intl_ship_id        varchar2(100);
v_orig_local_ship_id  integer;
v_intl_estarrive      varchar2(100);
v_local_vessel_valid  varchar2(100);
v_intl_vessel_valid   varchar2(100);
v_valid_container     varchar2(1);



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

--select *
--from WEBSYS.DEBUG order by ctr;


begin
 
 v_count := 1;
 open c1(infile);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
    close c1;
    p_msg := 'File not uploaded: ' || infile;
    return;
 else
    close c1;
    -- msg := 'File: ' || c1rec.name || ', type: ' || c1rec.mime_type || ', size: ' || c1rec.doc_size || '<br>';
    conv_blob_clob(c1rec.blob_content, v_clb); 

    --delete from apache_ows_content where name = infile; commit;
    glbx.dbg('dbms_lob.getlength(v_clb) '||dbms_lob.getlength(v_clb));
    if dbms_lob.getlength(v_clb) = 0
    then
       p_msg := 'Zero-length file: ' || infile;
       
       return;
    end if;
 
 end if;
 
 if nvl( v_batch,0) = 0 then
         select strang.s_local_ship_plan.nextval into v_batch from dual;
         batchno := v_batch;
         
 end if;
   
 v_sheet_number := 1;
 for rec_linehaul in   (select *
                          from table( as_read_xlsx.read(
                             (select blob_content 
                                from apache_ows_content 
                               where name = infile )))
                         where upper(sheet_nr) = 1
                          
                          ) loop

   -- glbx.dbg(upper(rec_linehaul.sheet_name));  
     glbx.dbg(upper(rec_linehaul.CELL));                  
 
--    select *
--    from websys.debug order by ctr;
-- 
     if v_plan_sheet_name is null then
        v_plan_sheet_name:= upper(rec_linehaul.sheet_name);
        v_week := regexp_substr(upper(v_plan_sheet_name),  '(\s+|^)[(](WEEK\s*)(*.*)[)]',1,1,'i',3);
        v_title1 := 'Local Ship Loading Plan for Week '||v_week;
     end if;
       
     if rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 1 and substr(rec_linehaul.cell,1,1) = 'A' AND NVL(rec_linehaul.string_val,'XXX') <> 'LOAD' then  
       
          begin v_load  := to_number(rec_linehaul.number_val); exception when others then null; end;
        
          if v_load between 1 and 2000 then 
             record_linehaul.valid_load_number := 'Y';
          else
             record_linehaul.valid_load_number := 'N';
          end if;
        
          record_linehaul.load_number := v_load ;
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 2 and substr(rec_linehaul.cell,1,1) = 'B' AND Upper(rec_linehaul.string_val) not like  'MATERIAL%' then  
       
        v_description := replace(trim(rec_linehaul.string_val),chr(10),'~') ;
        
        if v_description  is not null then
           cnt := 1;
           
           for r_description in (SELECT regexp_substr( v_description,'(.*?)(~|$)',1,level, NULL, 1) Result FROM dual connect by level<= regexp_count(v_description,'~')+1) loop
                     a_description(cnt) := trim(r_description.result);
                     cnt := cnt +1;                    
           end loop;
        end if;   
        
        elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 4 and substr(rec_linehaul.cell,1,1) = 'D' AND NVL(Upper(rec_linehaul.string_val),'XXX') <>  'PRIORITY' then  
        
           begin v_priority  := to_number(rec_linehaul.number_val); exception when others then null; end;
        
           if v_priority between 1 and 20 then 
              record_linehaul.valid_priority := 'Y';
           else
              record_linehaul.valid_priority := 'N';
           end if;
        
          record_linehaul.priority := v_priority ;
     
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 5 and substr(rec_linehaul.cell,1,1) = 'E' AND nvl(rec_linehaul.string_val,'XXX') <> 'CONTAINER' then    
        v_container := replace(rec_linehaul.string_val,chr(10),'~');
        if v_container is not null then
           cnt := 1;
           for r_container in (SELECT rtrim(ltrim(regexp_substr( v_container,'(.*?)(~|$)',1,level, NULL, 1))) as result FROM dual connect by level<= regexp_count(v_container,'~')+1) loop
--                  open c5(r_container.result); 
--                  fetch c5 into c5rec;
--                  if c5%found then
--                     a_shipname(cnt) := c5rec.shipname;
--                     a_voyage(cnt) := c5rec.voyage;
--                     a_container_valid(cnt) := 'Y';
--                  else 
--                     a_shipname(cnt) := null;
--                     a_voyage(cnt) := null;
--                     a_container_valid(cnt) := 'N';
--                  end if;
--                  close c5;
                  a_container_valid(cnt) := 'N';
                  a_container(cnt) := trim(r_container.result);                 
                  cnt := cnt +1;                  
           end loop;
           
        end if; 
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 6 and (rec_linehaul.cell is not null and substr(rec_linehaul.cell,1,1) = 'F') AND (rec_linehaul.string_val is not null and  nvl(rec_linehaul.string_val,'XXX') not like '%CONTR%SIZE%') then  
       
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

     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 7 and substr(rec_linehaul.cell,1,1) = 'G'  then  
        
        if rec_linehaul.cell_type = 'S' and  Upper(rec_linehaul.string_val) not like  '%WEIGHT%' then 
           v_weight := replace(trim(rec_linehaul.string_val),  chr(10), '~' );
           if v_weight is not null then
              cnt := 1;
              for r_weight in (SELECT regexp_substr( v_weight,'(.*?)(~|$)',1,level, NULL, 1) as Result FROM dual connect by level<= regexp_count(v_weight ,'~')+1) loop
                 begin  n_weight := to_number(r_weight.result); exception when others then null; end;
                    a_weight(cnt) := to_char(n_weight);
                    cnt := cnt +1;  
                    n_weight := null;         
              end loop;
           end if;
        elsif  rec_linehaul.cell_type = 'N' then
           a_weight(1) := to_char(rec_linehaul.number_val);
        end if; 
        
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 8 and substr(rec_linehaul.cell,1,1) = 'H'  then  
        
        if rec_linehaul.cell_type = 'S' and  Upper(rec_linehaul.string_val) not like  '%MATERIAL%' then 
           v_material := replace(trim(rec_linehaul.string_val),  chr(10), '~' );
           if v_material is not null then
              cnt := 1;
              for r_material in (SELECT regexp_substr( v_material,'(.*?)(~|$)',1,level, NULL, 1) as Result FROM dual connect by level<= regexp_count(v_material ,'~')+1) loop
                -- begin  n_material := to_number(r_material.result); exception when others then null; end;
                    a_material(cnt) := r_material.result; --to_char(n_material);
                    cnt := cnt +1;  
                    n_material := null;         
              end loop;
           end if;
        elsif  rec_linehaul.cell_type = 'N' then
           a_material(1) := to_char(rec_linehaul.number_val);
        end if;  
        
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 9 and (rec_linehaul.cell is not null and substr(rec_linehaul.cell,1,1) = 'I') AND (rec_linehaul.date_val is not null) then  

        begin v_load_dt  := rec_linehaul.date_val; exception when others then null; end;
--        if v_stg_load_dt is not null then
--           v_stg_load_dt := v_load_dt;
--        end if;
        if nvl(v_load_dt,trunc(sysdate)) < trunc(sysdate) then
          v_valid_load_dt := 'L';
        else 
          v_valid_load_dt := 'Y';
        end if;
        record_linehaul.loading_date := v_load_dt;
       
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 10 and substr(rec_linehaul.cell,1,1) = 'J' AND Upper(rec_linehaul.string_val) not like  'VESSEL - DRAFT%' then  
       
        v_local_vessel := replace(trim(rec_linehaul.string_val),chr(10),'~') ;
        
        if v_local_vessel  is not null then
           cnt := 1;
           
           for r_local_vessel in (SELECT regexp_substr( v_local_vessel,'(.*?)(~|$)',1,level, NULL, 1) Result FROM dual connect by level<= regexp_count(v_local_vessel,'~')+1) loop
                     a_local_vessel(cnt) := trim(r_local_vessel.result);
                     cnt := cnt +1;                    
           end loop;
        end if;   
        
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 11 and substr(rec_linehaul.cell,1,1) = 'K' AND Upper(rec_linehaul.string_val) not like  'VOYAGE - DRAFT%' then  
       
        v_local_voyage := replace(trim(rec_linehaul.string_val),chr(10),'~') ;
        
        if v_local_voyage  is not null then
           cnt := 1;
           
           for r_local_voyage in (SELECT regexp_substr( v_local_voyage,'(.*?)(~|$)',1,level, NULL, 1) Result FROM dual connect by level<= regexp_count(v_local_voyage,'~')+1) loop
                     a_local_voyage(cnt) := trim(r_local_voyage.result);
                     cnt := cnt +1;                    
           end loop;
        end if;  
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 16 and substr(rec_linehaul.cell,1,1) = 'P' AND Upper(nvl(rec_linehaul.string_val,'ILSO')) not like  'INTL. VOYAGE%' then  
     
        v_intl_voyage := replace(trim(rec_linehaul.string_val),chr(10),'~') ;
        
        if v_intl_voyage is null then
          a_intl_voyage (1) := 'ILSO'; -- INBOUND LOCAL SHIPPING ONLY';
        else
            
        
           if v_intl_voyage  is not null then
           cnt := 1;
           
            for r_intl_voyage in (SELECT regexp_substr( v_intl_voyage,'(.*?)(~|$)',1,level, NULL, 1) Result FROM dual connect by level<= regexp_count(v_intl_voyage,'~')+1) loop
                     a_intl_voyage(cnt) := trim(r_intl_voyage.result);
                     cnt := cnt +1;                    
            end loop;
           
           end if; 
        end if; 
        
        
     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 17 and substr(rec_linehaul.cell,1,1) = 'Q' AND Upper(nvl(rec_linehaul.string_val,'INBOUND LOCAL SHIPPING ONLY')) not like  'INTL. VESSEL%' then  
       
        v_intl_vessel := replace(trim(rec_linehaul.string_val),chr(10),'~') ;
        
        if v_intl_vessel is null then
          a_intl_vessel (1) := 'INBOUND LOCAL SHIPPING ONLY';
        else 
        
           if v_intl_vessel  is not null then
              cnt := 1;
           
              for r_intl_vessel in (SELECT regexp_substr( v_intl_vessel,'(.*?)(~|$)',1,level, NULL, 1) Result FROM dual connect by level<= regexp_count(v_intl_vessel,'~')+1) loop
                a_intl_vessel(cnt) := trim(r_intl_vessel.result);
                cnt := cnt +1;                    
              end loop;
           end if; 
        end if;
        

     elsif rec_linehaul.row_nr > 1 and rec_linehaul.col_nr = 18 and substr(rec_linehaul.cell,1,1) = 'R' AND Upper(rec_linehaul.string_val) not like  'LOCATION%' then  
        
        v_current_location := replace(trim(rec_linehaul.string_val),chr(10),'~') ;
      --  glbx.dbg ('v_current_location '||v_current_location);
        if v_current_location  is not null then
           cnt := 1;
           
           for r_current_location in (SELECT regexp_substr( v_current_location,'(.*?)(~|$)',1,level, NULL, 1) Result FROM dual connect by level<= regexp_count(v_current_location,'~')+1) loop
                     a_current_location(cnt) := trim(r_current_location.result);
                     cnt := cnt +1;                    
           end loop;
        end if; 
        
        
--        select *
--        from WEBSYS.DEBUG order by ctr;    
           
        if a_container.count = 1 and record_linehaul.load_number >= 1 then
--           glbx.dbg ('In the if statement');  
--           glbx.dbg ('a_container.count '||a_container(1));
--           glbx.dbg ('record_linehaul.load_number '||record_linehaul.load_number);  
           if a_container.exists(1) then 
              v_container := a_container(1);
              v_valid_container := a_container_valid(1);
             -- v_type_valid := a_type_valid(1);
           else 
              v_container := null;
              v_valid_container := 'N';
             -- v_type_valid := null;
           end if;
                 
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
           
           if a_material.exists(1) then 
              v_material_no := a_material(1);
           else 
              v_material_no := null;
           end if;
           
           if a_weight.exists(1) then 
              v_weight := a_weight(1);
           else 
              v_weight := null;
           end if;
           
           if a_current_location.exists(1) then 
              v_location := a_current_location(1);
           else 
              v_location := null;
           end if;
           
           --- international vessel container check
           if a_intl_vessel.exists(1) and a_intl_voyage.exists(1) then
           
             open c2(a_intl_vessel(1),a_intl_voyage(1), a_container(1));
             fetch c2 into c2rec;
             if c2%notfound then
               v_intl_vessel_valid := 'X';
             else
               v_intl_vessel_valid := 'Y';
               v_valid_container := 'Y';
               v_intl_ship_id := c2rec.ship_id;
               v_intl_estarrive := c2rec.estarrive;
               v_orig_local_ship_id := c2rec.local_ship_id;
               if  v_intl_estarrive > v_load_dt then
                  v_valid_load_dt := 'S';
               end if;
             end if;
             close c2;
             v_intl_vessel2 := a_intl_vessel(1);
             v_intl_voyage2 := a_intl_voyage(1);
             
            elsif a_intl_vessel.exists(1) then
              v_intl_voyage2 := null;
            elsif a_intl_voyage.exists(1) then
              v_intl_vessel2 := null;
            else 
              v_intl_vessel2 := null;
              v_intl_voyage2 := null;
            
            end if;
            
            if a_local_vessel.exists(1) and a_local_voyage.exists(1) then
             
               open c3(a_local_vessel(1),a_local_voyage(1));
               fetch c3 into c3rec;
               if c3%notfound then
                   v_local_vessel_valid := 'X';
               else
                   v_local_vessel_valid := 'Y';
                   v_local_ship_id := c3rec.local_ship_id;
                   v_local_estdepart := c3rec.estdepart;
                   if  v_local_estdepart < v_load_dt then
                      v_valid_load_dt := 'E';
                   end if;
               end if;
               close c3;
               v_local_vessel2 := a_local_vessel(1);
               v_local_voyage2 := a_local_voyage(1);
  
            end if;

           v_record := v_record + 1;
           

--           select count(*) from STRANG.stg_local_ship_plan;
          -- truncate table STRANG.stg_local_ship_plan;
           insert into STRANG.stg_local_ship_plan
           ( batch_id, record, title, week,  load_number, cargo_description
           , priority, urgency, container, container_type, weight, material_code, loading_date
           ,local_vessel
           ,local_voyage
           ,local_ship_id
           ,local_estdepart
           ,intl_vessel
           ,intl_voyage
           ,intl_ship_id
           ,intl_estarrive
           ,current_location
           ,valid_intl_vessel
           ,valid_local_vessel
           ,valid_load_number
           , valid_container, valid_container_type, valid_load_date,  created_by, sheet_number, orig_local_ship_id) values
           ( v_batch, v_record, v_title1, v_week
            , record_linehaul.load_number  -- good
             , a_description(1) -- good
             , record_linehaul.priority -- good
             , c2rec.urgency
             , v_container -- good
             , v_type -- null -- a_type(1) -- not good  TRY AGAIN 
             , v_weight -- good
             , v_material_no
             , record_linehaul.loading_date
             , v_local_vessel2
             , v_local_voyage2
             , v_local_ship_id
             , v_local_estdepart
             , v_intl_vessel2
             , v_intl_voyage2
             , v_intl_ship_id
             , v_intl_estarrive
             , v_location
             , v_intl_vessel_valid
             , v_local_vessel_valid
             , record_linehaul.valid_load_number
             , v_valid_container -- a_container_valid(1)
             , v_type_valid -- a_type_valid(1) -- cont_type
             , v_valid_load_dt
             , null -- 
             , v_sheet_number
             , v_orig_local_ship_id);
             
           commit;
    

                  
       end if;
        c2rec := null;
        record_linehaul := null;
        v_load := null;
        v_container := null;
        a_intl_vessel := glbx.empty_array;
        a_intl_voyage := glbx.empty_array;
        a_local_vessel := glbx.empty_array;
        a_local_voyage := glbx.empty_array;
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
        v_type := null;
        v_weight  := null;
        v_material_no := null;
        v_local_vessel := null;
        v_local_voyage := null;
        v_local_vessel2 := null;
        v_local_voyage2 := null;
        v_local_ship_id := null;
        v_local_estdepart := null;
        v_intl_vessel := null;
        v_intl_voyage := null;
        v_intl_vessel2 := null;
        v_intl_voyage2 := null;
        v_intl_ship_id := null;
        v_intl_estarrive := null;
        v_current_location := null;
        v_local_vessel_valid := null;
        v_intl_vessel_valid := null;
        v_valid_load_dt := null;
        v_count := v_count + 1;
        
        v_local_vessel2 := null;
        v_local_voyage2 := null;
        v_local_ship_id := null;
        v_local_estdepart := null;
        v_intl_vessel2 := null;
        v_intl_voyage2 := null;
        v_intl_ship_id := null;
        v_intl_estarrive := null;
        v_location := null;
--         
     end if;
  end loop;

  begin dbms_lob.freetemporary(v_clb); exception when others then null; end;
-- end if;
   
 --ingest_ships_excel_file(msg);

 --return;
exception when others then
-- begin delete from apache_ows_content where name = infile; exception when others then null; end;
 begin dbms_lob.freetemporary(v_clb); exception when others then null; end;
 commit;
 htp.bold('Error: ' || sqlerrm);
 --msg := 'Error: ' || sqlerrm;
end accept_ingest_ships_file;

end LOAD_SHIP_PLAN;
/
