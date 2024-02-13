CREATE OR REPLACE PACKAGE BODY WEBSYS.INVOICE_PARSER
AS
-- Reviewed by David Banjo on 13/2/2024
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


procedure invoice_mng(surl in varchar2, vtyp varchar2 default 'INVOICE', msg in varchar2 default null, batchno number default null) as

 v_g_gst_rate number(15,2) := invoice_parser.g_gst_rate;

 cursor c2 (v_batchno number) is
  select h.*, c.customer supplier
    from strang.parsed_invoice_header h,
         strang.parsed_customer_lookup l,
         strang.customers c
  where  h.batch_id = v_batchno
   and   upper(h.vendor) = upper(l.invoice_supplier(+))
   and   l.customer_id = c.customer_id (+);
   
 cursor c3 is
  select mo.name, mv.name_default
  from   main_object mo, main_value mv
  where  mo.mid = mv.mid
         and mo.theme_type = 'STRANG_TMP_RECEIVALS_FOLDERS';
  
  
  cursor c4 (v_batchno number) is
  SELECT *
    FROM ( SELECT batch_id, inv_verified_date, po_verified_date, po_number, po_item, proceed, freight_po_item, supinv, payment_due, invoice_filename,tamount
                , max(delivery_charge) over ( partition by po_number, supinv) delivery_charge
                , sum(nvl(case when nvl(po_item,9999) = nvl(freight_po_item,8888) then delivery_charge else 0 end,0)) over ( partition by po_number, supinv) delivery_charge_chk
                , gst
                , reviewlink, ROW_NUMBER() OVER (PARTITION BY batch_id,  po_number, supinv, invoice_filename order by date_created desc) rnk
                , SUM(NVL(item_gst,0)) OVER () sum_item_gst_orig
                , SUM(NVL(item_amount * nvl(ii.gst_rate,v_g_gst_rate),0)) OVER (PARTITION BY  batch_id,  po_number, supinv, invoice_filename) sum_item_gst  -- ADDED BY DB 8/6/22
                , MAX(date_created) OVER (PARTITION BY batch_id,  po_number, supinv, invoice_filename) max_dt
                , SUM(CASE WHEN po_item IS NULL THEN 1 ELSE 0 END) OVER () CNT
                , SUM(CASE WHEN item_amount IS NULL 
              -- then round(calc_amount * (1 - (nvl(discount,0)/100)) + nvl(calc_amount * v_g_gst_rate,0),2)
                     THEN ROUND(NVL(calc_amount,0)  + NVL(calc_amount * nvl(ii.gst_rate,v_g_gst_rate),0),2)
                   ELSE 
                     ROUND(NVL(item_amount,0) + nvl(item_amount * nvl(ii.gst_rate,v_g_gst_rate),0),2) END) OVER (PARTITION BY batch_id,  po_number, supinv, invoice_filename) sum_itm_amt 
              --  round(nvl(item_amount,0) * (1 - (nvl(discount,0)/100)) + nvl(item_amount * v_g_gst_rate,0),2) end) over (partition by batch_id,  po_number, supinv, invoice_filename) sum_itm_amt 
                , COUNT(*) OVER (PARTITION BY batch_id,  po_number, supinv, invoice_filename) cnt2
                , COUNT(*) OVER (PARTITION BY batch_id) gcnt
             FROM strang.parsed_invoice_items ii
            WHERE batch_id = v_batchno
              AND delete_flg IS NULL
          ) tmp
   WHERE tmp.rnk = 1
  ORDER BY max_dt DESC;
  
  cursor c5 (v_batchno number, v_invoice_filename varchar2) is
   select rowid row_id, batch_id, recno, po_number, supinv, invoice_filename, proceed, orig_item_amount, item_gst_code
        , short_text, inventoryno, qty, gstc_gstcode, priceitm, gst, round(nvl(calc_amount,0) * (1 - (nvl(discount,0)/100)),2) calc_amount
        , discount ,item_gst as actual_gst,
            case when item_amount is null and nvl(nvl(ii.gst_rate,v_g_gst_rate),0) <> 0 then
               round(calc_amount * nvl(ii.gst_rate,v_g_gst_rate),2) 
             when  item_amount is not null and nvl(nvl(ii.gst_rate,v_g_gst_rate),0) <> 0  then
               round(item_amount * nvl(ii.gst_rate,v_g_gst_rate),2) 
              else null end item_gst
          --, round( nvl(item_amount,0) * (1 - (nvl(discount,0)/100)),2) item_amount, 
          , round( nvl(item_amount,0),2) item_amount, 
            case when item_amount is null and nvl(nvl(ii.gst_rate,v_g_gst_rate),0) > 0 
                --    then round(nvl(calc_amount,0) * (1 - (nvl(discount,0)/100)) + nvl(calc_amount,0) * (1 - (nvl(discount,0)/100)) * nvl(v_g_gst_rate,0),2)
                    then round(nvl(calc_amount,0) + nvl(calc_amount,0) * nvl(nvl(ii.gst_rate,v_g_gst_rate),0),2)
                 when item_amount is not null and nvl(nvl(ii.gst_rate,v_g_gst_rate),0) > 0
                  --  then round(item_amount * (1 - (nvl(discount,0)/100)) + nvl(item_amount,0) *(1 - (nvl(discount,0)/100)) * nvl(v_g_gst_rate,0),2) 
                     then round(item_amount  + nvl(item_amount,0) * nvl(nvl(ii.gst_rate,v_g_gst_rate),0),2) 
                 when item_amount is null and item_gst is null 
                   -- then round(calc_amount * (1 - (nvl(discount,0)/100)),2)
                   then round(calc_amount,2)
                 when item_amount is not null and item_gst is null   
                  -- then round(item_amount * (1 - (nvl(discount,0)/100)),2)
                   then round(item_amount,2)
                 else null end item_tamount
        , tamount ,max(delivery_charge) over () delivery_charge ,po_item ,unit_price ,base_unit_price, date_created
          , country_code, strang.f_getlovColumn('UNCTYTAB','DESCRIPTION', country_code) as country_desc, ii.state        
     from strang.parsed_invoice_items ii
     where batch_id = v_batchno
       and invoice_filename = v_invoice_filename
       and delete_flg is null
     order by batch_id, recno asc, po_number, supinv, invoice_filename;  
     
     
  cursor c6 (v_po varchar2, v_po_item varchar2) is
   select po_number
        , po_item
        , net_price, quantity, shipping_text, short_text, vend_name, tax_code, material, openqty
        , count(*) over (partition by po_number,net_price) cnt
        , count(*) over (partition by po_number,material) cnt2
     from strang.po_pool pp
     where po_number= v_po
      and  pp.PO_ITEM = case when v_po_item is null then pp.po_item else v_po_item end
      and  openqty > 0
--      and not exists (select 1
--                        from strang.pos p
--                       where pp.po_number = p.po
--                        and pp.po_item = p.po_item_no)
    order by TO_NUMBER(GLBX.GUESS_NUMBER(po_item));
   -- order by po_item;
                     
  cursor c7 (v_inventory varchar2) is
   select 'x' 
   from strang.lov l
  where l.code = v_inventory
    and l.lov_name = 'INVENT';
     
  cursor c8 (v_po varchar2 , v_item varchar2) is
    select po_item
         , po_item||'~'||case when UPPER(substr(shipping_text,1,15)) like '%AIR%' then 'AIR'
                         when UPPER(substr(shipping_text,1,15)) like '%SEA%' then 'SEA'
                         when UPPER(substr(shipping_text,1,15)) like '%ROAD%' then 'ROAD' end||'~'||
        --   material||'~'||short_text||'~'||Quantity||'~'||Net_price det  
           material||'~'||short_text||'~'||nvl(to_char(openqty),'')||'~'||Net_price det    
      from strang.po_pool pp
     where pp.po_number = v_po
      and po_item = v_item;    
                                	 
--  cursor c9 (v_batchno number, v_invoice_filename varchar2) is 
  cursor c9 (v_po varchar2) is 
       select po_item 
     from strang.po_pool pp
     where pp.po_number = v_po
     order by 1;
    --  and po_item = v_item;
       
   cursor c10 (v_po varchar2) is 
       select 'x' 
         from strang.parsed_invoice_items ii
             ,strang.parsed_invoice_header h
        where ii.batch_id = h.BATCH_ID
         and  ii.po_number = v_po
         and  h.batch_id = batchno
          and  exists (select 1 
                        from strang.po_pool pp
                       where pp.po_number = ii.po_number
                       and nvl(pp.openqty,0) <> 0
                       and nvl(h.VENDOR_ID,pp.VENDOR) = to_number(pp.VENDOR));
                       
     
   cursor c11 (v_po varchar2, v_po_item varchar2,v_invoice_filename varchar2 ) is
   select 'x'
   from strang.parsed_invoice_items ii
   where ii.po_number =  v_po
     and ii.po_item = v_po_item
     and ii.batch_id = batchno
     and ii.invoice_filename = v_invoice_filename;

   cursor c12 ( v_batch number) is 
     select h.proceed, h.VENDOR_ID
      from strang.parsed_invoice_items ii
         , strang.parsed_invoice_header h
     where ii.batch_id = v_batch
       and h.batch_id = ii.batch_id
       and ii.delete_flg is null
       and ii.invoice_filename = (select tmp.invoice_filename
                                    from (select ii2.invoice_filename
                                               , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                            from strang.parsed_invoice_items ii2
                                           where ii2.batch_id = v_batch
                                             and ii2.DELETE_FLG IS NULL) tmp
                                   where rnk = 1)
       and (  (NVL(ii.COUNTRY_CODE,'YYYY') = 'XX') or
              (NVL(ii.COUNTRY_CODE,'YYYY') = 'AU' and ii.state is null) or
            (ii.country_code is null) or
            (NVL(ii.COUNTRY_CODE,'YYYY') <>  'AU' and ii.state is not null)
           )
       and h.vendor_id in ( 4002377 , 4000023, 4002398, 4001974, 4002092, 4001779, 4002397, 4001344, 4001449, 4002545, 4001903) ;       

   cursor c13 ( v_batch number) is 
     select h.batch_id, h.proceed, h.VENDOR_ID
      from strang.parsed_invoice_items ii
         , strang.parsed_invoice_header h
     where ii.batch_id = v_batch
       and h.batch_id = ii.batch_id
       and ii.delete_flg is null
       and ii.invoice_filename = (select tmp.invoice_filename
                                    from (select ii2.invoice_filename
                                               , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                            from strang.parsed_invoice_items ii2
                                           where ii2.batch_id = v_batch
                                             and ii2.DELETE_FLG IS NULL) tmp
                                   where rnk = 1)
       and ii.PO_VERIFIED_DATE is null;




 INVALID_RID exception;
 PRAGMA EXCEPTION_INIT(INVALID_RID, -1410);

 c1rec          customer_account%ROWTYPE;
 po_item_list   owa.vc_arr default glbx.empty_array;
 c2rec          c2%ROWTYPE;
 c4rec          c4%ROWTYPE;
 c6rec          c6%ROWTYPE;
 c7rec          c7%ROWTYPE;
 c8rec          c8%ROWTYPE;
 c10rec         c10%ROWTYPE;
 c11rec         c11%ROWTYPE;
 c12rec         c12%ROWTYPE;
 c13rec         c13%ROWTYPE;
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
-- v_g_gst_rate number(15,2) := g_gst_rate;
 file_types   CONSTANT varchar2(1000) := '.pdf,image/x-png,image/gif,image/jpeg,.csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel';
 c integer := 0;
 vmsg varchar2(1000);

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'INVOICE_PARSER.INVOICE_MNG' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste :=  invoice_parser.customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := strangp.data_access( owner_id, 'INVOICE_MNG', null );
 seclevel := oltp.security_role( owner_id );

 if batchno is not null then 
   open c12(batchno);
   fetch c12 into c12rec;
   if ( c12%found and (c12rec.proceed is null or NVL(c12rec.proceed,'NO') = 'NO'))  then
      vmsg := msg||'Please ensure that the Country Codes and State codes are properly completed!'||htf.nl; 
      if c12rec.vendor_id = 4001370 then
         vmsg := vmsg||'S M C PNEUMATICS PTY sometimes shows the Country of Origin at the bottom of the invoice.'||htf.nl;
      elsif c12rec.vendor_id = 4001568 then
         vmsg := vmsg||'BANKSIA SCIENTIFIC CO. PTY sometimes shows the Country of Origin at the top of the invoice.'||htf.nl;
      elsif c12rec.vendor_id =  4001754 then
         vmsg := vmsg||'POWER STEP (AUSTRALIA) PTY sometimes shows the Country of Origin at the top of the invoice.'||htf.nl;
      elsif c12rec.vendor_id =  4001512 then
         vmsg := vmsg||'TEREX LIFTING AUSTRALIA PTY shows the Country of Origin as a column labelled as COO. PLEASE change item header from ''Unit'' to ''Country of Origin'' and CONFIRM!!'||htf.nl;
      elsif c12rec.vendor_id =  4002024  then  
         vmsg := vmsg||'TEREX/JAQUES invoice typically shows the Country of Origin at the top of invoice at sometimes included with a COO title in item table'||htf.nl; 
      elsif c12rec.vendor_id =  4001903  then  
         vmsg := vmsg||'COMPLETE OFFICE SUPPLIES now includes the Country of Origin with the invoice item description field'||htf.nl;
      end if;  
   end if;
   close c12;
   
   open c13(batchno);
   fetch c13 into c13rec;
   if (c13%found and NVL(c13rec.proceed,'NO') = 'YES') then
      vmsg := msg||' You are strongly advised to confirm all invoices. Thank you!'||htf.nl; 
   end if;
   close c13;
   
 end if;


 htp.p('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"');
 htp.p('"http://www.w3.org/TR/html4/strict.dtd"> ');
 htp.htmlopen;
 htp.headopen;
 htp.p('<link rel="stylesheet" type="text/css" href="/images/str/style_invoice.css" />');
 htp.p('<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script>');
 htp.p('<script type="text/javascript" src="/images/js/js_invoice_parser.js"></script>');
 htp.p('<script src="/images/js/sweetalert2.all.min.js"></script>'); 
 htp.p('<link rel="stylesheet" type="text/css" href="/images/str/sweetalert2.min.css" />');
 
 htp.headclose;
 -- added by DB 4/7/2023
 if upper(msg) like '%CUMULATIVE QUANTITY THAT EXCEEDS THE SAP OPEN QUANTITY%' then
   --htp.bodyopen( CATTRIBUTES=>'onload="alert(''Cumulative Quantity of item exceeds SAP Open Qty. Please Contact Manager!!'')" ');
   htp.bodyopen( CATTRIBUTES=>'onload="Swal.fire(''Warning'', ''Cumulative Quantity of item exceeds SAP Open Qty. Please Contact Manager!!'', ''warning'')" ');
 else
   htp.bodyopen;
 end if;

-- htp.bodyopen;
  htp.p('<CENTER>');
  htp.header(1,'Load Invoice pdf file to be processed by API', 'CENTER' );
  v_url := htf.anchor( 'javascript: window.open(''' || '/invoices/' || to_char(sysdate,'YYYYMMDD') || '/'  || ''',''' || 'vtyp' || ''',''height=800,width=600,scrollbars=yes,resizable=yes'');void('''');', to_char(sysdate,'YYYYMMDD') );
  htp.header(2,'Today''s files:  ' ||v_url, 'CENTER' );
  htp.nl;

  if msg is not null
   then
    htp.header(1, msg, cattributes=>'style="color: red;"');
  end if;
  htp.formopen('invoice_parser.invoice_mng_accept', 'POST', null, 'multipart/form-data', cattributes=>'name="item_box"' );
  htp.formhidden( 'SURL', surl );
--  htp.formhidden( 'RID', rid );
  -- htp.formhidden( 'RECCTR', recctr );
  htp.formhidden('VTYP', vtyp );
  htp.formhidden('BATCHNO', batchno);
 -- htp.formhidden('RID', null);
 -- htp.formhidden('RECITM', null);
  --htp.formhidden('P1', null);
  --htp.formhidden('P2', null);

  
  htp.tableopen;
   for c3rec in c3 loop
   v_url := htf.anchor( 'javascript: window.open(''' || '/invoices/' || to_char(sysdate,'YYYYMMDD') || '/' || ''',''' || 'vtyp' || ''',''height=800,width=600,scrollbars=yes,resizable=yes'');void('''');', 'Today''s List' );
   htp.tablerowopen;
    if c3%ROWCOUNT = 1
	 then
	  htp.tabledata(htf.formfile('infile', file_types, 'multiple'));
	else
      htp.tabledata('&nbsp;');
	end if;
--	if nvl(batchno,0) = 0 then
	   htp.tabledata(htf.formsubmit('action', 'Load into ' || c3rec.name_default));
--	else
--	   htp.tabledata(htf.formsubmit('action', 'Load Another Invoice'));
--	end if;
    -- Added by David Banjo 15/6/2022
    if batchno is not null then 
       open c2(batchno);
       fetch c2 into c2rec;
       close c2;
       
       if not ( nvl(c2rec.proceed,'NO') = 'YES') then 
          htp.tabledata(htf.formsubmit('action','Reload Latest Invoice'));
       end if;
       htp.tabledata('<INPUT TYPE="button" NAME="action" VALUE="Update" onClick="validateItems(this.form, ''Update'',''NotNull'')">');
       if not ( nvl(c2rec.proceed,'NO') = 'YES') then 
       --   cname=>'P20', cattributes=>'id="P20" ONCHANGE="full_empty_switch()"' 
        --  htp.tabledata('<INPUT TYPE="button" NAME="action" VALUE="Set Default Country" onClick="toggleCountry(''InvoiceItem'', ''P17'')">');
          htp.p( '<TD ONCHANGE="toggleCountry(''InvoiceItem'', ''P17'')" ' || glbx.QUERY_CELL_BACKGROUND || '>' );
             WEBSYS.INVOICE_PARSER.lov_list( 'UNCTYTAB2', 'P19', 'AA', FALSE, TRUE, FALSE );   
          htp.p( '</TD>' );
          
          htp.p( '<TD ONCHANGE="toggleState(''InvoiceItem'', ''P18'')" ' ||glbx.QUERY_CELL_BACKGROUND || '>' );
                     WEBSYS.INVOICE_PARSER.lov_list( 'STATE2', 'P20', 'AA', FALSE, TRUE, FALSE );
          htp.p( '</TD>' );
          
       end if;
   -- htp.formsubmit('action','Update');
       if c2rec.proceed = 'YES' then 
        -- htp.tabledata(htf.formsubmit('action','Create Delivery'));
            htp.tabledata('<INPUT TYPE="button" id="mybutton"  NAME="action" VALUE="Create Delivery" onclick="return confirmMessage(this.form, ''Create Delivery'', event);">'); 
       --    htp.tabledata('<INPUT TYPE="submit" NAME="action" VALUE="Create Delivery" onclick="return confirm(''Are you definitely sure you want to Create Delivery?'');">');
       end if;
      -- htp.tabledata(htf.formsubmit('action','Clear All'));
       htp.tabledata('<INPUT TYPE="button" id="mybutton"  NAME="action" VALUE="Clear All" onclick="return confirmMessage(this.form, ''Clear All'', event);">');
      -- htp.tabledata('<INPUT TYPE="submit" NAME="action" VALUE="Clear All" onclick="return confirm(''Are you definitely sure you want to Clear All?'');">');
       
       
    end if;


	htp.tabledata(v_url);
    htp.tablerowclose;
   end loop;
   htp.tableclose;
   htp.nl;
  
  -- Start the form building right here!!
  if batchno is not null then
     open c2(batchno);
     fetch c2 into c2rec;
     close c2;
     
     open c4(batchno);
     fetch c4 into c4rec;
     close c4;
     htp.tableopen ( CATTRIBUTES=>'style="font-size:18px;"');
     htp.tablerowopen;
     htp.tableheader('Delivery Batch ID: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata(c2rec.batch_id,cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen;
     htp.tableheader('Supplier: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata(nvl(c2rec.supplier,c2rec.Vendor)||' ('||c2rec.Vendor_id||')', cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen;
     htp.tableheader('Customer: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     htp.tabledata(c2rec.Customer||' ('||c2rec.customer_id||')',cattributes=>'style="font-weight:bold;"');
     htp.tablerowclose;
     htp.tablerowopen;
     
     
     
    If c2rec.gstcode is null or TO_NUMBER(GLBX.GUESS_NUMBER(c2rec.gstcode)) = 0 then 
       if nvl(c4rec.gst,0) = 0 and nvl(c4rec.sum_item_gst_orig,0) = 0 then
            v_g_gst_rate := 0.0; 
            v_gstcode := 'NS';
       else
            v_g_gst_rate := 0.1;
            v_gstcode := 'NET';
       end if;
    elsif  c2rec.gstcode  in ('EX', 'NS', 'PRO0', 'PRO1') then
           v_g_gst_rate := 0.0; 
           v_gstcode := 'NS';
    elsif  c2rec.gstcode  in ('INC', 'NET') then
           v_g_gst_rate := 0.1; 
           v_gstcode := 'NET';
    else 
          v_g_gst_rate := 0.0; 
          v_gstcode := 'NS';
    end if;
     
     htp.tableheader('Default GST Code: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
     if NVL(c2rec.proceed,'NO') = 'YES' then
        htp.tabledata(c2rec.gstcode,cattributes=>'style="font-weight:bold;"');
        htp.formhidden('P15', c2rec.gstcode);
     else
       htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="LEFT">' );
       lov_list( 'GSTCODES', 'P15', nvl(c2rec.gstcode,v_gstcode), TRUE, FALSE, TRUE );
       htp.p( '</TD>' );
     end if;
 
     htp.tablerowclose;
     if NVL(c2rec.proceed,'NO') = 'YES' then
        htp.tablerowopen;
        htp.tableheader('Total Amount/Count: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
        htp.tabledata(to_char(c2rec.gtotal,'fm999G999G999D00')||' ('||c4rec.gcnt||')',cattributes=>'style="font-weight:bold;"');
        htp.tablerowclose;
     end if;
     htp.tableclose;
     htp.nl;
     htp.p('<div id="mydiv"></div>');
        
        
        for c4rec in c4 (batchno)
        loop
           v_checkbox := null;
           if c4%ROWCOUNT <> 1 then
              htp.tableclose;
           end if; 
           htp.nl;
           htp.nl;
           htp.tableopen ( CATTRIBUTES=>'style="font-size:18px;"');
           htp.tablerowopen;
           htp.tableheader('Invoice File Name: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
           --htp.tabledata('Invoice File Name: ' );
           htp.tabledata(htf.anchor2(c4rec.reviewlink,c4rec.invoice_filename, ctarget=>'NEWECN'), cattributes=>'COLSPAN=2' );
           htp.tablerowclose;
           htp.tablerowopen;
           --htp.tabledata('Invoice Number: ');
           htp.tableheader('Invoice Number: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
           if  nvl(c2rec.proceed,'NO') = 'YES' then 
              if c4rec.inv_verified_date is not null then
                 htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(c4rec.supinv)||htf.fontClose, cattributes=>'COLSPAN=2' );
                 htp.formhidden('P14', c4rec.supinv);
              else 
                 htp.tabledata(c4rec.supinv, cattributes=>'COLSPAN=2' );
                 htp.formhidden('P14', c4rec.supinv);
              end if;
           else 
              if nvl(c4rec.proceed,'NO') = 'NO'  then
                 if c4rec.supinv is null or length(c4rec.supinv) > 15 then 
                    htp.p( '<TD ALIGN="LEFT" COLSPAN=2>' );
                    htp.formtext( 'P14', 12, 12,  c4rec.supinv, CATTRIBUTES=>'style="border:1px solid red; font-size:16px;"' );
                    htp.p( '</TD>' );
                 else
                    htp.p( '<TD ALIGN="LEFT" COLSPAN=2>' );
                    htp.formtext( 'P14', 12, 12,  c4rec.supinv, CATTRIBUTES=>'style="font-size:16px;"' );
                    htp.p( '</TD>' );
                 end if;
              else
                 htp.tabledata(c4rec.supinv, cattributes=>'COLSPAN=2' );
                 htp.formhidden('P14', c4rec.supinv);
              end if;
           end if;
          -- htp.tabledata(c4rec.supinv, cattributes=>'COLSPAN=2' );
           htp.tablerowclose;
           htp.tablerowopen;
           -- htp.tabledata('PO Number: ');
           htp.tableheader('PO Number: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
           if  nvl(c4rec.proceed,'NO') = 'YES' then 
              if c4rec.po_verified_date is not null then
                 htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(c4rec.po_number)||htf.fontClose, cattributes=>'COLSPAN=2' );
                 htp.formhidden('P13', c4rec.po_number);
              else
                htp.tabledata(c4rec.po_number, cattributes=>'COLSPAN=2' );
                htp.formhidden('P13', c4rec.po_number);
              end if;
           else
            --  if nvl(c2rec.proceed,'NO') = 'NO'  then
                open c10 (nvl(c4rec.po_number,'9999999'));
                fetch c10 into c10rec;
                if c10%found then
                   htp.p( '<TD ALIGN="LEFT" COLSPAN=2>' );
                   htp.formtext( 'P13', 12, 12,  c4rec.po_number, CATTRIBUTES=>'style="font-size:16px;"');
                   htp.p( '</TD>' );
                else 
                   htp.p( '<TD ALIGN="LEFT" COLSPAN=2>' );
                   htp.formtext( 'P13', 12, 12,  c4rec.po_number,cattributes=>'style="border:1px solid red; font-size:16px;"' );
                   htp.p( '</TD>' );
                end if;
                close c10;
            --  else
            --    htp.tabledata(c4rec.po_number, cattributes=>'COLSPAN=2' );
             --   htp.formhidden('P13', c4rec.po_number);
            --  end if;
              htp.tablerowclose;
           end if;
           htp.tablerowopen;
           --htp.tabledata('Invoice Gross Value: ');
           htp.tableheader('Invoice Gross Value: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');

           if  nvl(c4rec.proceed,'NO') = 'YES' then 
              htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(to_char(nvl(c4rec.tamount,c4rec.payment_due),'fm99G999G999D00'))||htf.fontClose,  cattributes=>'COLSPAN=2' );
              htp.formhidden('P7', nvl(c4rec.tamount,c4rec.payment_due));
              if v_proceed is null and c4rec.cnt = 0 then
                 v_full_proceed := 'YES';
             --    v_proceed := 'YES';
              elsif v_proceed is null then
                  v_proceed := 'YES';
                 
              end if;
           
           else 
              if (round(nvl(c4rec.tamount,c4rec.payment_due),0) = round(nvl(c4rec.sum_itm_amt,0) + nvl(c4rec.delivery_charge,0),0)   )  then -- + nvl(c4rec.gst,0),0)) then
                 htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(to_char(nvl(c4rec.tamount,c4rec.payment_due),'fm99G999G999D00'))||htf.fontClose,  cattributes=>'COLSPAN=2' );
                 htp.formhidden('P7', nvl(c4rec.tamount,c4rec.payment_due));
                 if v_proceed is null and c4rec.cnt = 0 then
                    v_full_proceed := 'YES';
              --    v_proceed := 'YES';
                 elsif v_proceed is null then
                    v_proceed := 'YES';
                 
                 end if;
            --  htp.tabledata(nvl(c4rec.tamount,c4rec.payment_due) );
              else
                 htp.p( '<TD ALIGN="LEFT" >' );
                 htp.formtext( 'P7', 12, 12, nvl(c4rec.tamount,c4rec.payment_due),cattributes=>'style="border:1px solid red; font-size:16px;"' );
                 htp.p( '</TD>' );
                 htp.tabledata(htf.fontOpen(ccolor=>'Red' )||htf.bold('Diff: '||round(nvl(c4rec.tamount,c4rec.payment_due) - (nvl(c4rec.sum_itm_amt,0) + nvl(c4rec.delivery_charge,0)) ,2))||htf.fontClose);
                 v_proceed := 'NO';
                 v_full_proceed := 'NO';
             --  htp.tabledata(nvl(c4rec.tamount,c4rec.payment_due) );
              end if;
           end if;
           htp.tablerowclose; 
           htp.tablerowopen;
          -- htp.tabledata('GST Value: ');
           htp.tableheader('GST Value: ', cattributes=>'style="text-align:left; height:40px; border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
           if  nvl(c4rec.proceed,'NO') = 'YES' then 
              if nvl(c4rec.gst,0) = 0 and nvl(c4rec.sum_item_gst,0) > 0  then
                 htp.p( '<TD ALIGN="LEFT" >' );
                 htp.formtext( 'P8', 12, 12,  c4rec.gst ,cattributes=>'style="border:1px solid red; font-size:16px;"'  );
                 htp.p( '</TD>' );
                 htp.tabledata(htf.fontOpen(ccolor=>'Red' )||htf.bold('GST missing')||htf.fontClose);
               else
                 htp.tabledata(case when c4rec.gst = 0 then null else TO_CHAR(c4rec.gst,'fm99G999G999D00') end , cattributes=>'COLSPAN=2');
                 htp.formhidden('P8', c4rec.gst);
               end if;
             else 
              if nvl(c4rec.gst,0) = 0 and nvl(c4rec.sum_item_gst,0) > 0  then
                 htp.p( '<TD ALIGN="LEFT" >' );
                 htp.formtext( 'P8', 12, 12,  null ,cattributes=>'style="border:1px solid red; font-size:16px;"'  );
                 htp.p( '</TD>' );
                 htp.tabledata(htf.fontOpen(ccolor=>'Red' )||htf.bold('GST missing')||htf.fontClose);
               else
                 htp.p( '<TD ALIGN="LEFT" >' );
                 htp.formtext( 'P8', 12, 12,  c4rec.gst ,cattributes=>'style="font-size:16px;"'  );
                 htp.p( '</TD>' );
               end if;
            
             end if;
           
           
           htp.tablerowclose;
          
          -- if nvl(c4rec.delivery_charge,0) = 0 and c2rec.proceed = 'YES' then
           if nvl(c4rec.delivery_charge,0) = 0 and nvl(c4rec.proceed,'NO') = 'YES' then
             null;
             htp.formhidden('P6',c4rec.delivery_charge);
             htp.formhidden('P12',c4rec.freight_po_item);
           elsif c4rec.delivery_charge <> 0 and  nvl(c4rec.proceed,'NO') = 'YES' then
              htp.tablerowopen;
             -- htp.tabledata('Freight/PO Item: ');
              htp.tableheader('Freight/PO Item: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
              htp.tabledata(to_char(round(c4rec.delivery_charge,2),'fm99G999G999D00'));
              htp.tabledata(round(c4rec.freight_po_item,2));
              htp.formhidden('P6',c4rec.delivery_charge);
              htp.formhidden('P12',c4rec.freight_po_item);
              htp.tablerowclose;
           else
              htp.tablerowopen;
            --  htp.tabledata('Freight/PO Item: ');
              htp.tableheader('Freight/PO Item: ', cattributes=>'style="text-align:left;border-bottom:1px solid #663;border-right:1px solid #663;font-weight:bold;background-color:#fff; color:#663"');
                 if c4%ROWCOUNT = 1 and nvl(c4rec.proceed,'NO') <> 'YES' then
                    htp.p( '<TD ALIGN="LEFT" COLSPAN="1">' );
                    htp.formtext( 'P6', 12, 12, c4rec.delivery_charge, cattributes=>'style="font-size:16px;"' );    
                    htp.p( '</TD>' );                
                    
                    if nvl(c4rec.delivery_charge,0) = nvl(c4rec.delivery_charge_chk,0) then
                       htp.p( '<TD ' || v_BACKGROUND|| ' ALIGN="LEFT">' );
                    else
                       htp.p( '<TD ' || v_BACKGROUND|| 'style="outline:3px solid red;" ALIGN="LEFT">' );
                    end if;
                   -- htp.p( '<TD ' || v_BACKGROUND|| ' ALIGN="LEFT">' );
                    htp.formselectopen( 'P12' );
                    for c9rec in c9 (c4rec.po_number) loop
                       if c9rec.po_item = c4rec.freight_po_item
                       then
                          htp.formselectoption( c9rec.po_item, 'SELECTED' );
                       else
                          htp.formselectoption( c9rec.po_item );
                       end if;
                    end loop;
                    htp.formselectclose;
                    htp.p( '</TD>' );
                    --   htp.tabledata('<a href="javascript:;" onclick="insRow_InvoiceItem(this,''InvoiceItem'')">[Insert New Item]</a>');  
                 else
                    htp.p( '<TD ALIGN="LEFT" COLSPAN="1">' );
                    htp.formtext( 'P6', 12, 12, c4rec.delivery_charge ,cattributes=>'style="font-size:16px;"' );    
                    htp.p( '</TD>' ); 
                    
                    if nvl(c4rec.delivery_charge,0) = nvl(c4rec.delivery_charge_chk,0) then
                       htp.p( '<TD ' || v_BACKGROUND|| ' ALIGN="LEFT">' );
                    else
                       htp.p( '<TD ' || v_BACKGROUND|| 'style="outline:1px solid red;" ALIGN="LEFT">' );
                    end if;
                  -- htp.p( '<TD ' || v_BACKGROUND|| ' ALIGN="LEFT">' );
                    htp.formselectopen( 'P12' );
                    for c9rec in c9 (c4rec.po_number) loop
                       if c9rec.po_item = c4rec.freight_po_item
                       then
                          htp.formselectoption( c9rec.po_item, 'SELECTED' );
                       else
                          htp.formselectoption( c9rec.po_item );
                       end if;
                    end loop;
                    htp.formselectclose;
                    htp.p( '</TD>' );
                 end if;
              htp.tablerowclose;
           end if;
          
           htp.tableclose;
           htp.nl;
            
           if c4%ROWCOUNT = 1  then
              htp.tableopen(cattributes=>'id="InvoiceItem"');
              v_checkbox := 'InvoiceItem';
           else
              htp.tableopen (cattributes=>'id="InvoiceItemOther"');
              v_checkbox := 'InvoiceItemOther';
           end if;
           htp.tablerowopen;
           if c4%ROWCOUNT = 1  then
           htp.p('<TH'||case when c4rec.proceed = 'YES' then ' style="display:none;"' else ' style="max-width: 0px;" ' end||'>Select<br>');
           htp.p('<input type="checkbox" onClick="toggle(this,''InvoiceItem'')" checked />');
           htp.p('</TH>');
           else
           htp.p('<TH'||case when c4rec.proceed = 'YES' then ' style="display:none;"' else ' style="max-width: 0px;" ' end||'>Select<br>');
           htp.p('<input type="checkbox" onClick="toggle(this,''InvoiceItemOther'')" checked />');
           htp.p('</TH>');  
           
           end if;
           htp.tableheader('Item Description ('||c4rec.cnt2||')');
           htp.tableheader('Material No');
           htp.tableheader('Qty', cattributes=>'style="padding:10px;" ');
           htp.tableheader('Base<br>Unit Price', cattributes=>'style="padding:10px;" ');
           htp.tableheader('Disc.(%)', cattributes=>'style="padding:10px;" ');
           htp.tableheader('Unit Price');
           htp.tableheader('Net Price');
           htp.tableheader('GST<BR>Code');
           htp.tableheader('GST');
           htp.tableheader('Total Price');
           htp.tableheader('PO Item Details');
           htp.tableheader('Country<br>Of Origin');
           htp.tableheader('State<br>Of Origin');
           if c4rec.proceed = 'YES' then
              null;
           else
              htp.tableheader('<a href="javascript:;" onclick="insRow_InvoiceItem(this,''InvoiceItem'')">[Insert Row]</a>', cattributes=>'style="padding:10px;" ');
              htp.p('<TH style="padding:10px;">Price/Item<br>Overrride');
           --htp.p('<input type="checkbox" onClick="toggle(this,''InvoiceItem'')" checked />');
              htp.p('</TH>');
           end if;
           htp.tablerowclose;
           
           for c5rec in c5 ( batchno, c4rec.invoice_filename)
           loop
             c := c + 1;
             
             for c6rec in c6 ( c5rec.po_number, c5rec.po_item) 
             loop
                begin v_unit_price := to_number(c6rec.net_price); exception when others then v_unit_price := null; end;
            -- open c6 (c5rec.po_number, c5rec.unit_price);
                if v_unit_price is not null then
  
                   if  (round(v_unit_price,2) = round(c5rec.unit_price,2)  and c6rec.cnt = 1 ) then -- and c5rec.discount is null)
                   -- or (round(v_unit_price,2) = round(c5rec.unit_price,2)* ((100 - nvl(c5rec.discount,0))/100)  and c6rec.cnt = 1 and c5rec.discount is not null)                                                                       then  -- c6rec.cnt2 = 1  removed by DB

                      v_open_qty := c6rec.openqty;
                      if c6rec.material is null and c5rec.inventoryno is not null then
                         open c7 (c5rec.inventoryno);
                         fetch c7 into c7rec;
                         if c7%found then
                            v_inventory := c5rec.inventoryno;
                         else 
                            v_inventory := null;
                         end if;
                         close c7;
                        --- v_inventory := c5rec.inventoryno;
                         v_po_item := c6rec.po_item;
                         v_open_qty := c6rec.openqty;
                         exit;
                      end if;
                      open c7 (c6rec.material);
                      fetch c7 into c7rec;
                      if c7%found then
                        v_inventory := c6rec.material;
                      elsif c6rec.material is not null then
                        v_inventory := 'not_found';
                      else 
                        v_inventory := null;
                      end if;
                      close c7;
                      open c11 (c5rec.po_number, c6rec.po_item, c4rec.invoice_filename);
                      fetch c11 into c11rec;
                      if c11%found and c5rec.po_item is null then
                        v_po_item := null;
                        v_inventory := null;
                      else    
                        v_po_item := c6rec.po_item;
                      end if;
                      close c11;
                      v_open_qty := c6rec.openqty;
                      v_po_item := c6rec.po_item;
                      exit;
                   elsif  nvl(c5rec.inventoryno,'zzzz') = nvl(c6rec.material, 'xxxx') and c6rec.cnt2 = 1   then  
                       v_po_item := c6rec.po_item;
                       v_inventory := c6rec.material;
                       v_unit_price := c6rec.net_price;
                       v_open_qty := c6rec.openqty;
                      open c7 (c6rec.material);
                      fetch c7 into c7rec;
                      if c7%found then
                        v_inventory := c6rec.material;
                      elsif c6rec.material is not null then
                        v_inventory := 'not_found';
                      else 
                        v_inventory := null;
                      end if;
                      close c7;
                     --  v_unit_price:= null;
                     --  v_open_qty := null;
                       if nvl(round(v_unit_price,2),0) <> nvl(round(c5rec.unit_price,2),0) and round(nvl(c5rec.qty * c5rec.unit_price,0),0) = round(nvl(c5rec.orig_item_amount,0),0)   then
                       --   v_unit_price := c5rec.unit_price;
                         v_unit_price := round(v_unit_price,2);
                       else
                          v_unit_price := round(v_unit_price,2);
                       end if;
                      exit;
                    elsif c5rec.inventoryno is not null and c5rec.po_item is not null and c6rec.material is null then
                       v_inventory := c5rec.inventoryno;
                       v_po_item :=  c5rec.po_item;
                    else
                       v_po_item :=  c5rec.po_item;
                       if c5rec.po_item is not null and round(nvl(v_unit_price,0),2) <> round(nvl(c5rec.unit_price,0),2) then
                          v_open_qty := c6rec.openqty;
                          exit;
                       end if;
                    end if;
                end if;
               v_open_qty := null;
               v_unit_price := null;
               v_inventory := null;
             end loop;
               
             htp.tablerowopen;
             htp.formhidden( 'RID', ROWIDTOCHAR(c5rec.row_id));                        
             if v_checkbox = 'InvoiceItem'  then
                htp.tabledata('<input type="hidden"  name="recItm" value="0" />' || htf.formcheckbox( 'recItm', 'T', cattributes=>'class="InvoiceItem" CHECKED' ) , cattributes=>case when c5rec.proceed = 'YES' then v_hide_cell else '' end||' style="width: 50px;" '   );
             else
                htp.tabledata('<input type="hidden"  name="recItm" value="0" />' || htf.formcheckbox( 'recItm', 'T', cattributes=>'class="InvoiceItemOther" CHECKED' ),cattributes=>case when c5rec.proceed = 'YES' then v_hide_cell else '' end );     
             end if;
             
            if (nvl(c5rec.proceed,'NO') <> 'YES' ) then
                   htp.p( '<TD ALIGN="LEFT" >' );
                   htp.formtext( 'P9', 30, 30, c5rec.short_text);
                   htp.p( '</TD>' );
              --  htp.tabledata(htf.fontOpen(ccolor=>'Red' )||htf.bold(to_char(round(to_number(c5rec.qty),2)))||htf.fontClose); -- ,cattributes=>'title="Supplied Qty = '||to_char(round(to_number(c5rec.qty),2))||' Ordered Qty = '||v_open_qty );
             else
                htp.tabledata(substr(c5rec.short_text,1,47));
                htp.formhidden( 'P9', c5rec.short_text );
             end if;
             if v_inventory is not null and v_inventory <> 'not_found' then
              --  htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(v_inventory)||htf.fontClose);
              --  htp.tabledata(v_inventory);
             --   htp.formhidden( 'P2', v_inventory );
                htp.p( '<TD ALIGN="LEFT" >' );
              --  htp.formtext( 'P2', 12, 12, v_inventory, cattributes=>'style="color:green" readonly');
                htp.formtext( 'P2', 8, 12, v_inventory, cattributes=>'style="color:green"');
                htp.anchor2( 'strangp.lov?surl=' || surl || '&call_name=strangp.lov&parm=INVENT&lrange=&src=' || v_inventory, 'Inventory',ctarget=>'INVENT_SEARCH' );
                htp.p( '</TD>' );
             elsif v_inventory <> 'not_found' then
                htp.p( '<TD ALIGN="LEFT" >' );
               -- htp.formtext( 'P2', 12, 12, v_inventory, cattributes=>'readonly' );
                htp.formtext( 'P2', 8, 12, v_inventory );
                htp.anchor2( 'strangp.lov?surl=' || surl || '&call_name=strangp.lov&parm=INVENT&lrange=&src=' || v_inventory, 'Inventory',ctarget=>'INVENT_SEARCH' );
                htp.p( '</TD>' );
             else 
                htp.p( '<TD  ALIGN="LEFT" >' );
             --   htp.formtext( 'P2', 12, 12, v_inventory, cattributes=>'readonly' );
                htp.formtext( 'P2', 8, 12, v_inventory );
                htp.anchor2( 'strangp.lov?surl=' || surl || '&call_name=strangp.lov&parm=INVENT&lrange=&src=' || v_inventory, 'Inventory',ctarget=>'INVENT_SEARCH' );
                htp.p( '</TD>' );
             end if;
             if nvl(c5rec.proceed,'NO') = 'YES' then
                if (nvl(TO_NUMBER(c5rec.qty),0) <> nvl(TO_NUMBER(v_open_qty),0) and c5rec.unit_price is not null) or (c5rec.qty is null)  then
                   htp.tabledata(htf.fontOpen(ccolor=>'Red' )||htf.bold(to_char(round(to_number(c5rec.qty),2)))||htf.fontClose);
                   htp.formhidden('P3', c5rec.qty);
                else
                   htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(to_char(round(to_number(c5rec.qty),2)))||htf.fontClose);
                   htp.formhidden('P3', c5rec.qty);
                end if;
             else
                if (nvl(TO_NUMBER(c5rec.qty),0) <> nvl(TO_NUMBER(v_open_qty),0) and c5rec.unit_price is not null) or (c5rec.qty is null)  then 
                   if c5rec.qty is null then
                      htp.p( '<TD ALIGN="LEFT" >' );
                      htp.formtext( 'P3', 3, 8, nvl(c5rec.qty,0), cattributes=>'style="color:red; border:1px solid red;"');
                      htp.p( '</TD>' );
                   else 
                      htp.p( '<TD ALIGN="LEFT" >' );
                      htp.formtext( 'P3', 3, 8, nvl(c5rec.qty,0), cattributes=>'style="color:red"');
                      htp.p( '</TD>' );
                   end if;
              --  htp.tabledata(htf.fontOpen(ccolor=>'Red' )||htf.bold(to_char(round(to_number(c5rec.qty),2)))||htf.fontClose); -- ,cattributes=>'title="Supplied Qty = '||to_char(round(to_number(c5rec.qty),2))||' Ordered Qty = '||v_open_qty );
               else
                   htp.p( '<TD ALIGN="LEFT" >' );
                   htp.formtext( 'P3', 3, 8, nvl(c5rec.qty,0), cattributes=>'style="color:green"');
                   htp.p( '</TD>' );
               -- htp.tabledata(to_char(round(to_number(c5rec.qty),2)));
               -- htp.formhidden('P3', c5rec.qty);
                end if;
             end if;
             if nvl(c5rec.proceed,'NO') = 'YES' then
             -- base price final
                 htp.tabledata(to_char(round(to_number(c5rec.base_unit_price),2)));
                 htp.formhidden('P4', c5rec.base_unit_price);
             -- discount final
                 htp.tabledata(to_char(round(to_number(c5rec.discount),2)));
                 htp.formhidden('P10', c5rec.discount);
             else
             --  base price wip
                htp.p( '<TD ALIGN="LEFT" >' );
                htp.formtext( 'P4', 8, 10, c5rec.base_unit_price);
                htp.p( '</TD>' );
             
             -- discount wip
                htp.p( '<TD ALIGN="LEFT" >' );
                htp.formtext( 'P10', 3, 8, to_char(c5rec.discount));
                htp.p( '</TD>' );
             end if;
             htp.formhidden( 'P11', c5rec.recno, cattributes=>'Id="P11"');
             -- unit price 
             if (nvl(TO_NUMBER(c5rec.unit_price),0) <> nvl(TO_NUMBER(v_unit_price),0)) then
             --  or  (nvl(TO_NUMBER(c5rec.unit_price),0)* (1 - (nvl(c5rec.discount,0)/100)) <> nvl(TO_NUMBER(v_unit_price),0) and c5rec.discount is not null) then 
                htp.tabledata(htf.fontOpen(ccolor=>'Red' )||htf.bold(to_char(round(to_number(c5rec.unit_price),2)))||htf.fontClose, cattributes=>'class="makeBlank"');
             else
                htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(to_char(round(to_number(c5rec.unit_price),2)))||htf.fontClose,cattributes=>'class="makeBlank"');
             --   htp.tabledata(to_char(round(to_number(c5rec.unit_price),2)));
                
             end if;
           --  htp.formhidden('P4', c5rec.unit_price);
             
            -- htp.tabledata(to_char(c5rec.discount));
            -- htp.formhidden( 'P10', c5rec.discount);
             htp.tabledata(to_char(nvl(c5rec.item_amount,c5rec.calc_amount)),cattributes=>'class="makeBlank"');
             --- Add GST code here 
             if NVL(c5rec.proceed,'NO') = 'YES' then
                htp.tabledata(nvl(c5rec.item_gst_code, v_gstcode));
                htp.formhidden('P16', nvl(c5rec.item_gst_code, v_gstcode));
             else
                htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' ALIGN="CENTER">' );
                lov_list( 'GSTCODES', 'P16', nvl(c5rec.item_gst_code,v_gstcode), TRUE, FALSE, TRUE );
                htp.p( '</TD>' );
             end if;
             
             
             htp.tabledata(to_char(c5rec.item_gst), cattributes=>'class="makeBlank"');
             htp.tabledata(to_char(c5rec.item_tamount), cattributes=>'class="makeBlank"');
             if substr(c5rec.po_number,1,2) = '47' or substr(c5rec.po_number,1,2) = '80' then
                   if NVL(c2rec.proceed,'NO') = 'YES' then
                      htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(nvl(c5rec.po_item, v_po_item))||htf.fontClose);
                      --  htp.tabledata(nvl(c5rec.po_item, v_po_item));
                      htp.formhidden('P1', nvl(c5rec.po_item, v_po_item));
                   else
                      htp.p( '<TD ALIGN="LEFT" >' );
                      htp.formtext( 'P1', 6, 6, nvl(c5rec.po_item, v_po_item), cattributes=>'style="color:green"');
                      htp.p( '</TD>' );
                   end if;
              -- manual entry stuff here!!
             else 
             --   if v_po_item is not null and c5rec.po_item is not null then
                if c5rec.po_item is not null then
                   open c8(c5rec.po_number, v_po_item);
                   fetch c8 into c8rec;
                   close c8;
                   htp.tabledata(htf.fontOpen(ccolor=>'Green' )||htf.bold(c8rec.det)||htf.fontClose);
                   htp.formhidden('P1', c8rec.po_item);
                elsif  v_po_item is not null and c5rec.po_item is null and po_item_list.EXISTS(to_number(v_po_item)) then
                   po_item_list(to_number(v_po_item)) := 'YES';
                   htp.p( '<TD class="duplicated_item" ' || v_BACKGROUND|| ' ALIGN="LEFT" >' );  --border-right:
                 --  htp.p( '<TD ' || v_BACKGROUND|| ' ALIGN="LEFT"  style="background:silver;">' );  --border-right:
                   po_pool_list2( c5rec.po_number, v_po_item, batchno, 'P1', round(c5rec.unit_price,2), FALSE );
                   htp.p( '</TD>' );
                elsif v_po_item is not null and c5rec.po_item is null then
                   po_item_list(to_number(v_po_item)) := 'YES';
                   htp.p( '<TD class="selected_item" ' || v_BACKGROUND|| ' ALIGN="LEFT" >' );
                  -- htp.p( '<TD ' || v_BACKGROUND|| ' ALIGN="LEFT">' );
                   po_pool_list2( c5rec.po_number, v_po_item, batchno, 'P1', round(c5rec.unit_price,2), FALSE );
                   htp.p( '</TD>' );
                else
                   htp.p( '<TD ' || v_BACKGROUND|| ' ALIGN="LEFT">' );
                   po_pool_list2( c5rec.po_number, v_po_item, batchno, 'P1', round(c5rec.unit_price,2), FALSE );
                   htp.p( '</TD>' );
                end if;
             end if;
             
             if NVL(c5rec.proceed,'NO') = 'YES' then
                htp.tabledata(substr(c5rec.country_desc,1,80));
                htp.formhidden('P17', c5rec.country_code);
             else 
                if c5rec.country_code is null then
                   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' style="max-width: 90px; ALIGN="LEFT">' );  --  outline:1px solid red;
                   htp.p('<div style="border: 2px solid red; ">');
                   WEBSYS.INVOICE_PARSER.lov_list( 'UNCTYTAB', 'P17', c5rec.country_code, FALSE, TRUE, FALSE);
                    htp.p('</div>');
                   htp.p( '</TD>' );
                else 
                   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' style="max-width: 90px; ALIGN="LEFT">' );
                   WEBSYS.INVOICE_PARSER.lov_list( 'UNCTYTAB', 'P17', c5rec.country_code, FALSE, TRUE, FALSE );
                   htp.p( '</TD>' );
                end if;
             end if;
             if NVL(c5rec.proceed,'NO') = 'YES' then
                htp.tabledata(c5rec.state);
                htp.formhidden( 'P18', c5rec.state );
             else 
             
                  if c5rec.country_code = 'AU' and c5rec.state is null then
                     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' style="max-width: 20px; ALIGN="LEFT">' );
                     htp.p('<div style="border: 2px solid red; width: 60px; ">');
                     WEBSYS.INVOICE_PARSER.lov_list( 'STATE', 'P18', c5rec.state, FALSE, FALSE, TRUE );
                     htp.p('</div>');
                     htp.p( '</TD>' );
                  else
                     htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' style="max-width: 20px; ALIGN="LEFT">' );
                     WEBSYS.INVOICE_PARSER.lov_list( 'STATE', 'P18', c5rec.state, FALSE, FALSE, TRUE );
                     htp.p( '</TD>' );
                  end if;
--
--                   htp.p( '<TD ' || glbx.QUERY_CELL_BACKGROUND || ' style="max-width: 20px; ALIGN="LEFT">' );
--                   WEBSYS.INVOICE_PARSER.lov_list( 'STATE', 'P18', c5rec.state, FALSE, FALSE, TRUE );
--                   htp.p( '</TD>' );
          --      end if;
             end if;
             --  htp.tabledata('<a href="javascript:;" onclick="cloneRow(''InvoiceItem'', this)">[Copy]</a><a href="javascript:;" onclick="deleteRow(''InvoiceItem'', this)">[Delete]</a>');
             --  htp.tabledata('&nbsp;', cattributes=>case when c5rec.proceed = 'YES' then v_hide_cell else '' end);
             htp.tabledata('<a href="javascript:;" onclick="NewcloneRow(''InvoiceItem'', this)">[Copy]</a>',  cattributes=>case when c5rec.proceed = 'YES' then v_hide_cell else '' end);
             --Price Override
             if nvl(c5rec.priceitm,'T') = 'F' then
                htp.tabledata('<input type="hidden"  name="priceItm" value="0" />' || htf.formcheckbox( 'priceItm', NVL(c5rec.priceitm,'F') ), cattributes=>case when c5rec.proceed = 'YES' then v_hide_cell else '' end );
             else
                htp.tabledata('<input type="hidden"  name="priceItm" value="0" />' || htf.formcheckbox( 'priceItm', NVL(c5rec.priceitm,'T'), cattributes=>'CHECKED'  ), cattributes=>case when c5rec.proceed = 'YES' then v_hide_cell else '' end );
             end if;
             
             htp.tablerowclose;
             v_inventory := null;
             v_po_item := null;

           end loop;
           po_item_list := glbx.empty_array;
        end loop;
              
  end if;
   htp.tableclose;
   htp.nl;
   htp.nl;
   
   htp.formhidden('P5', v_proceed);

-- htp.p('<INPUT TYPE="button" NAME="action" VALUE="Update" onClick="validateItems(this.form, ''Update'')">');
 if batchno is not null then 
  --  if not (c2rec.proceed = 'YES' and v_full_proceed = 'YES') then 
  if not ( nvl(c2rec.proceed,'NO') = 'YES' and NVL(v_full_proceed,'NO') = 'YES' ) then 
       htp.formsubmit('action','Reload Latest Invoice');
    end if;
    htp.p('<INPUT TYPE="button" NAME="action" VALUE="Update" onClick="validateItems(this.form, ''Update'',''NotNull'')">');
   -- htp.formsubmit('action','Update');
    if c2rec.proceed = 'YES' and v_full_proceed = 'YES' then 
        htp.tabledata('<INPUT TYPE="button" id="mybutton"  NAME="action" VALUE="Create Delivery" onclick="return confirmMessage(this.form, ''Create Delivery'', event);">'); 
      -- htp.formsubmit('action','Create Delivery');
    end if;
 end if;
 
 

  htp.formclose;
  htp.nl;
  htp.nl;
  htp.bold('<a href="" onClick="self.close()">[Close Window]</a>');
  htp.p('</CENTER>');

 htp.bodyclose;
 htp.htmlclose;
end invoice_mng;

procedure invoice_mng_accept(surl in varchar2, vtyp varchar2, infile in owa.vc_arr default glbx.empty_array
                              , action varchar2, batchno number default null
                              , rid in owa.vc_arr default glbx.empty_array
                              , recItm in owa.vc_arr default glbx.empty_array
                              , PriceItm in owa.vc_arr default glbx.empty_array
                              , p1 in owa.vc_arr default glbx.empty_array, p2 in owa.vc_arr default glbx.empty_array 
                              , p3 in owa.vc_arr default glbx.empty_array, p4 in owa.vc_arr default glbx.empty_array 
                              , p5 in varchar2 default null 
                              , p6 in varchar2 default null
                              , p7 in varchar2 default null
                              , p8 in varchar2 default null  
                              , p9 in owa.vc_arr default glbx.empty_array
                              , p10 in owa.vc_arr default glbx.empty_array   
                              , p11 in owa.vc_arr default glbx.empty_array  
                              , p12 in varchar2 default null 
                              , p13 in varchar2 default null 
                              , p14 in varchar2 default null 
                              , p15 in varchar2 default null    
                              , p16 in owa.vc_arr default glbx.empty_array 
                              , p17 in owa.vc_arr default glbx.empty_array    
                              , p18 in owa.vc_arr default glbx.empty_array
                              , p19 in varchar2 default null   
                              , p20 in varchar2 default null                                        
                              ) as
                              
cursor c2 (v_batch integer) is 
    select ii.qty, ii.discount, ii.recno, ii.gst, ii.item_amount, ii.item_tamount, ii.invoice_filename, ii.item_gst, substr(ii.supinv,1.15) supinv, l.code as inventoryno
         , ii.delivery_charge, ii.freight_po_item 
         , row_number() over ( partition by ii.po_number, ii.supinv order by ii.priceitm desc, ii.recno) del_rnk
         , p.po_number, p.po_item, p.net_price, p.vendor, p.shipping_text
         , sum(case when upper(p.shipping_text) like '% AIR %' then 1 else 0 end) over () mode_cnt
         , p.openqty, p.quantity
         , ih.customer, ih.vendor vendor_name, ih.customer_id, ih.vendor_id, ih.multiple_invoices, ih.proceed
         , p.po_unit_iso,  p.critical, p.manual_gr, p.vend_name, p.street, p.district, p.region, p.postl_code, p.countryiso
         , p.city, p.short_text, p.matl_group
         , row_number() over ( order by ii.date_created, ii.supinv, ii.po_number, ii.recno) po_recno 
         , ii.gst_rate, ii.item_gst_code, p.preq_item, p.preq_name, p.preq_no
         , case when (ii.country_code = 'ZZ' or ii.country_code is null) then 'XX' else ii.country_code end country_code
         , ii.state
         , p.collect_no
    from strang.parsed_invoice_items ii
       , strang.parsed_invoice_header ih
        ,strang.po_pool p
        ,strang.lov l
    where ii.batch_id = v_batch
    and ii.po_number = p.po_number 
    and ii.po_item = p.po_item 
    and l.lov_name(+) = 'INVENT'
    and p.material = l.code (+)
    and ii.delete_flg is null
    and ii.batch_id = ih.batch_id
    and p.openqty > 0 
    -- add this in production and UAT.
    -- and ii.item_amount > 0
    order by ii.date_created, ii.po_number, ii.recno ;


cursor c3(v_file varchar2) is select * from apache_ows_content where name = v_file;
cursor c4( sname varchar2 ) is select screen_id from oltp_overview where screen_name = sname;
cursor c5( cde varchar2 ) is select to_number(cola) cola, colb, code from strang.lov where lov_name = 'GSTCODES' and code = cde;
cursor c6 ( v_batch number) is select round(sum(item_tamount) over (),2) item_amt
                                    , outer_tmp.tot_amt 
                                    , round(sum(nvl(case when po_item = freight_po_item then delivery_charge else 0.00 end,0)) over(),2) delivery_charge
                                    , sum(case when po_item is null then 1 else 0 end) over () cnt
                                    , sum(case when supinv is null then 1 else 0 end) over () cnt2
                                 from strang.parsed_invoice_items a
                                     , (select sum (max_tamount) tot_amt
                                          from (select max(tamount) over (partition by supinv, invoice_filename) max_tamount
                                                    , row_number() over (partition by supinv, invoice_filename order by recno) rnk
                                                    , batch_id 
                                                 from strang.parsed_invoice_items
                                                where batch_id = v_batch and delete_flg is null) inner_tmp
                                         where inner_tmp.rnk = 1 ) outer_tmp
                                where batch_id = v_batch
                                  and delete_flg is null
                                order by supinv, recno;

cursor c7 ( v_batch number) is select distinct max(date_created) over (partition by batch_id, invoice_filename) date_created
                                    , invoice_filename
                                 from strang.parsed_invoice_items
                                where batch_id = v_batch
                                order by 1,2 ; --date_created, invoice_filename;   
                               
 cursor c8 ( v_batch number) is select ii.*
                                  from strang.parsed_invoice_items ii
                                 where ii.batch_id = v_batch
                                   and ii.delete_flg is null
                                   and ii.invoice_filename = (select tmp.invoice_filename
                                                                from (select ii2.invoice_filename
                                                                           , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                                                        from strang.parsed_invoice_items ii2
                                                                       where ii2.batch_id = v_batch
                                                                         and  ii2.DELETE_FLG is null) tmp
                                                               where rnk = 1)
                                 order by recno desc ;                    
 cursor c9 ( v_batch number) is select gstcode, proceed, vendor_id, deliveryno from strang.parsed_invoice_header where batch_id = v_batch;        
 
 cursor c10 ( v_batch number, v_filename varchar2) is select batch_id
                                                           , invoice_filename
                                                        from strang.parsed_invoice_items
                                                       where batch_id = v_batch
                                                         and delete_flg is null
                                                         and invoice_filename = v_filename
                                                       order by 1,2 ; 
                                                       
 cursor c11 (v_batch number, v_po varchar2) is 
       select h.vendor_id 
         from strang.parsed_invoice_items ii
             ,strang.parsed_invoice_header h
        where ii.batch_id = h.BATCH_ID
         and  ii.po_number = v_po
         and  ii.delete_flg is null
         and  ii.invoice_filename = (select tmp.invoice_filename
                                       from (select ii2.invoice_filename
                                                  , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                               from strang.parsed_invoice_items ii2
                                              where ii2.delete_flg is null
                                                and ii2.batch_id = v_batch) tmp
                                       where tmp.rnk = 1)
         and  h.batch_id = v_batch
         and  exists (select 1 
                        from strang.po_pool pp
                       where pp.po_number = ii.po_number
                         and  pp.date_created >= sysdate - 700
                         and nvl(pp.openqty,0) <> 0
                       and nvl(h.VENDOR_ID,pp.VENDOR) = to_number(pp.VENDOR));                                                      
                                                       
 cursor c12 ( v_batch number) is select batch_id
                                  from strang.parsed_invoice_header h
                                 where h.batch_id = v_batch
                                   and not exists (select '1'
                                                     from strang.parsed_invoice_items ii
                                                    where ii.batch_id = v_batch
                                                      and ii.delete_flg is null);                                                         
 cursor c13 (v_batch number, v_po varchar2, v_po_item varchar2, v_user varchar2) is 
       select h.batch_id, h.username 
         from strang.parsed_invoice_items ii
            , strang.parsed_invoice_header h
        where v_po = ii.po_number 
          and v_po_item = ii.po_item 
          and ii.batch_id = h.batch_id                                  
          and ii.date_created > trunc(sysdate)
          and h.deliveryno is  null
          and ii.delete_flg is null
          and h.USERNAME <> v_user
          and ii.batch_id <> batchno;
          
 cursor c14 (v_po varchar2, v_po_item varchar2) is       
    select po_item
         , po_number
         , openqty
      from strang.po_pool pp
     where pp.po_number = v_po
      and po_item = v_po_item;    
       
   cursor c15 (v_rid varchar2,  v_po_item varchar2 ) is       
          select ii.invoice_filename, ii.po_number, 
              (select sum(i.qty)
             from strang.parsed_invoice_items i 
            where i.BATCH_ID = ii.batch_id and 
                  i.DELETE_FLG is null and
                   --  i.supinv <> ii.supinv and 
                     i.rowid <> v_rid and
                     i.po_number = ii.po_number  and
                     i.po_item = v_po_item) sum_qty
         from strang.parsed_invoice_items ii
        where rowid = v_rid
          and ii.batch_id = batchno; 

   cursor c17 (rid varchar2) is       
    select ii.*
      from strang.parsed_invoice_items ii
     where rowid =rid ;  
     
   cursor c18 ( v_batch number) is select h.VENDOR_ID
                                  from strang.parsed_invoice_items ii
                                       , strang.parsed_invoice_header h
                                 where ii.batch_id = v_batch
                                   and ii.batch_id = h.batch_id
                                   and ii.delete_flg is null
                                   and ii.invoice_filename = (select tmp.invoice_filename
                                                                from (select ii2.invoice_filename
                                                                           , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                                                        from strang.parsed_invoice_items ii2
                                                                       where ii2.batch_id = v_batch
                                                                         and ii2.DELETE_FLG IS NULL) tmp
                                                               where rnk = 1)
   order by recno desc ;   
     
   cursor c19  ( v_batch number) is select h.VENDOR_ID, h.vendor, ii.supinv, r.deliveryno
                                      from strang.parsed_invoice_items ii
                                         , strang.parsed_invoice_header h
                                         , strang.pos p
                                         , strang.receivals r
                                     where ii.batch_id = v_batch
                                       and ii.batch_id = h.batch_id
                                       and ii.delete_flg is null
                                       and ii.invoice_filename = (select tmp.invoice_filename
                                                                    from (select ii2.invoice_filename
                                                                              , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                                                          from strang.parsed_invoice_items ii2
                                                                         where ii2.batch_id = v_batch
                                                                           and ii2.DELETE_FLG IS NULL) tmp
                                                                   where rnk = 1)
                                       and p.deliveryno = r.deliveryno
                                       and h.vendor_id = r.SUPPLIER_CUSTOMER_ID 
                                       and p.supinv = ii.SUPINV
                                       order by ii.recno desc ;  
  
  cursor c20  ( v_batch number) is select h.VENDOR_ID, h.vendor, ii.supinv, r.deliveryno, p.po, p.po_item_no
                                      from strang.parsed_invoice_items ii
                                         , strang.parsed_invoice_header h
                                         , strang.pos p
                                         , strang.receivals r
                                     where ii.batch_id = v_batch
                                       and ii.batch_id = h.batch_id
                                       and ii.delete_flg is null
                                       and ii.invoice_filename = (select tmp.invoice_filename
                                                                    from (select ii2.invoice_filename
                                                                              , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                                                          from strang.parsed_invoice_items ii2
                                                                         where ii2.batch_id = v_batch
                                                                           and ii2.DELETE_FLG IS NULL) tmp
                                                                   where rnk = 1)
                                       and p.deliveryno = r.deliveryno
                                       and h.vendor_id = r.SUPPLIER_CUSTOMER_ID 
                                       and p.supinv = ii.SUPINV
                                       and p.po = ii.po_number
                                       and p.po_item_no = ii.po_item
                                       order by ii.recno desc ;  
 
  cursor c21 ( v_batch number) is  
  select freight_po_item, po_item, count(*) 
  from strang.parsed_invoice_items ii
  where batch_id = v_batch  
    and ii.DELETE_FLG IS NULL
    and ii.invoice_filename = (select tmp.invoice_filename
                               from (select ii2.invoice_filename
                                   , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                    from strang.parsed_invoice_items ii2
                                   where ii2.batch_id = v_batch
                                     and ii2.DELETE_FLG IS NULL) tmp
                               where rnk = 1)  
  group by freight_po_item, po_item
  having nvl(freight_po_item,po_item) = po_item;  

  cursor c22 ( v_batch number, vdelitemno number ) is  
   select min(po_item) min_po_item, sum( case when ii.po_item = vdelitemno then 1 else 0 end) cnt
     from strang.parsed_invoice_items ii
    where ii.batch_id = v_batch
      and ii.po_item is not null
      and ii.delete_flg is null
      and ii.invoice_filename = (select tmp.invoice_filename
                                  from (select ii2.invoice_filename
                                             , row_number() over (partition by ii2.batch_id order by ii2.date_created desc) rnk
                                          from strang.parsed_invoice_items ii2
                                         where ii2.batch_id = v_batch
                                           and ii2.DELETE_FLG IS NULL) tmp
                                         where rnk = 1);  

 c1rec         customer_account%ROWTYPE;
 c2rec         c2%ROWTYPE;
 c3rec         c3%ROWTYPE;
 c4rec         c4%ROWTYPE;
 c5rec         c5%ROWTYPE;
 c6rec         c6%ROWTYPE;
 c7rec         c7%ROWTYPE;
 c8rec         c8%ROWTYPE;
 itmrec        c8%ROWTYPE;
 c9rec         c9%ROWTYPE;
 c10rec        c10%ROWTYPE;
 c11rec        c11%ROWTYPE;
 c12rec        c12%ROWTYPE;
 c13rec        c13%ROWTYPE;
 c14rec        c14%ROWTYPE;
 c15rec        c15%ROWTYPE;
 c17rec        c17%ROWTYPE;
 c18rec        c18%ROWTYPE;
 c19rec        c19%ROWTYPE;
 c20rec        c20%ROWTYPE;
 c21rec        c21%ROWTYPE;
 c22rec        c22%ROWTYPE;
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
 newrid		   rowid;
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
 --v_unit        varchar2(10);
 v_other       varchar2(10);
 v_country varchar2(20);
 v_state varchar2(20);
 -----------------------------
 dtime      varchar2(20); -- Added by David Banjo

begin

 v_batch := batchno;
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'INVOICE_PARSER.INVOICE_MNG_ACCEPT' );
 if sts is not null
  then
  glbx.redisplay_login_page( sts, TRUE );
  return;
 end if;

 c1rec := glbx.get_aid( owner_id, 'C', ltype );
 vste := invoice_parser.customer_state(c1rec.aid);
 pfx := glbx.get_thm( c1rec.theme_name );
 vaccess := strangp.data_access( owner_id, 'INVOICE_MNG_ACCEPT', null );
 seclevel := oltp.security_role( owner_id );
 v_user := REGEXP_SUBSTR (c1rec.account_name, '(\S*)') ;

  -- The following if statement was added by DB on 17/11/2021
  if vste = 'BNE' then
   --  dtime := to_char(new_time(sysdate, 'ADT', 'AST'),'HH24:MI:SS');
     dtime := TO_CHAR(current_timestamp at time zone 'AUSTRALIA/BRISBANE','HH24:MI:SS');
  end if;

 if infile.count < 1
  then
   invoice_mng(surl, vtyp, 'No Files Selected');
 end if;
 
 if upper(action) = 'CLEAR ALL' then
    
   update strang.parsed_invoice_header
       set proceed = 'NO'
        ,  username = c1rec.username
        ,  deliveryno = 99999999
   where batch_id = batchno;
 
    insert into strang.parsed_invoice_items_archive
    select * 
    from strang.parsed_invoice_items
    where batch_id = batchno;
    --and delete_flg is not null;
    
    delete from strang.parsed_invoice_items
    where batch_id = batchno;
    -- and delete_flg is not null;
    
    commit;
   invoice_mng(surl,  vtyp, action||' Action: previous entries cleared....',batchno => null);
   return;
 elsif upper(action) = 'UPDATE' then
 
   open c18 (batchno);
   fetch c18 into c18rec;
   close c18;
   
   
   open c19 (batchno);
   fetch c19 into c19rec;
   if c19%found then 
      vmsg := 'WARNING: Invoice Number '||c19rec.supinv||' already processed for supplier '||c19rec.vendor ||' on deliveryno '||c19rec.deliveryno||' . Please Contact Manager!!';
   end if;
   close c19;
   
   open c20 (batchno);
   fetch c20 into c20rec;
   if c20%found then 
      close c20;
      vmsg := 'ERROR: Invoice Number '||c20rec.supinv||' already processed for supplier '||c20rec.vendor ||' on deliveryno '||c20rec.deliveryno||' with same PO details : '||c20rec.po||'('||c20rec.po_item_no||'). Invoice Parser tool can not proceed!';
      invoice_mng(surl,  vtyp, vmsg,batchno => v_batch );
      return;
   end if;
   close c20;
 
    UPDATE strang.parsed_invoice_header h
      set ( vendor_id
         , vendor ) =
      ( select pp.vendor
              , pp.vend_name
          from strang.po_pool pp
             ,strang.customers c
          where po_number= p13
            and pp.vendor = c.customer_id
            and c.customer_type = 'SUPPLIER'
            and rownum < 2)       
    where h.batch_id = batchno
    and ( ( h.vendor_id is null )
       or (h.vendor_id is not null and 
          h.proceed IS NULL)
       or (h.vendor_id is not null and 
           1 = (select count(distinct ii.invoice_filename)
                      from  strang.parsed_invoice_items ii
                      where ii.delete_flg is null
                      and   h.batch_id = ii.batch_id))      
          );  
     
    if p5 = 'YES' then
       null;
    else
      update strang.parsed_invoice_header
      set proceed = 'NO'
        , username = c1rec.username
      where batch_id = batchno;
      
--      update strang.parsed_invoice_items
--      set proceed = 'NO'
--      where batch_id = batchno;
    end if;
    
    open c12 (batchno);
	fetch c12 into c12rec;
	if c12%found then
       close c12;
       invoice_mng(surl,  vtyp, action||' Action: previous entries cleared....',batchno => null);
       return;
	end if;
	close c12;
    
	if length(p14) > 15 then
	   invoice_mng(surl,  vtyp, action||': Invoice No. can not be greater than 15 Characters..',batchno => v_batch );
       return;
	end if;
	

    update strang.parsed_invoice_header
    set gstcode = p15
    where nvl(gstcode,'xxx') <> nvl(p15,'xxx');
    
    begin v_gst := to_number(p8); exception when others then null; end;
	begin v_inv_tot := to_number(p7); exception when others then null; end;
	begin v_del_chg := to_number(p6); exception when others then null; end;
	begin v_del_item := to_number(p12); exception when others then null; end;
	
    open c8 (batchno);
	fetch c8 into c8rec;
	close c8;
	
	open c9 (batchno);
	fetch c9 into c9rec;
	close c9;
	
    
    if v_gst is not null then
    
       update strang.parsed_invoice_items ii
          set gst = v_gst
         --  , tamount = tamount - nvl(gst
           , orig_gst = case when orig_gst is not null then orig_gst else ii.gst end
        where batch_id = batchno
          and invoice_filename = c8rec.invoice_filename
          and delete_flg is null;
          
    elsif v_gst is null then
    
       update strang.parsed_invoice_items ii
          set gst = v_gst
           , orig_gst = case when orig_gst is not null then orig_gst else ii.gst end
        where batch_id = batchno
          and invoice_filename = c8rec.invoice_filename
          and delete_flg is null
          and ii.gst is not null;
          
    end if;
    
    UPDATE strang.parsed_invoice_items ii
       set supinv = p14
          , po_number = p13
          , orig_po_number = case when orig_po_number is not null then orig_po_number else ii.po_number end
          , orig_supinv = case when orig_supinv is not null then orig_supinv else ii.supinv end
      where batch_id = batchno
        and invoice_filename = c8rec.invoice_filename;
     commit;
   
          
    if nvl(v_del_chg,0) <> 0 then
    
       update strang.parsed_invoice_items ii
          set delivery_charge = v_del_chg
             ,freight_po_item = v_del_item
        where batch_id = batchno
          and invoice_filename = c8rec.invoice_filename
          and delete_flg is null;
    else
      
       update strang.parsed_invoice_items ii
          set delivery_charge = 0.00
             ,freight_po_item = null  -- added by David 
        where batch_id = batchno
          and invoice_filename = c8rec.invoice_filename
          and delete_flg is null;   -- added by David
     
    end if;
    
    if v_inv_tot is not null then
       update strang.parsed_invoice_items ii
          set tamount = v_inv_tot
           , orig_tamount = case when orig_tamount is not null then orig_tamount else ii.tamount end
        where batch_id = batchno
          and invoice_filename = c8rec.invoice_filename;
    end if;

   --- Start reall stuff here 
    itm_ctr := 0;
    if recitm.count > 1 then
    
       for j in recitm.first..recitm.last-1 loop
	      if recitm(j) = '0' and recitm(j + 1) <> '0' then
	         itm_ctr := itm_ctr + 1; v_recitm(itm_ctr) := recitm(j + 1);
	         --  if v_recitm(itm_ctr) = 'T' then print_ok := TRUE; end if;
	      elsif recitm(j) = '0' then
	         itm_ctr := itm_ctr + 1; v_recitm(itm_ctr) := 'F';
	      end if;

       end loop;
       if recitm(recitm.last) = '0' then
	      itm_ctr := itm_ctr + 1;
	      v_recitm(itm_ctr) := 'F';
       end if;
    elsif recitm.count = 1 then
       v_recitm(1) := 'F';
    end if;
    
---------------------------------------------------------------------------------
  -- Deal with new inserts here  
  v_rid := rid;
  v_recno := c8rec.recno;
  if v_recitm.count > 0
  then
     
     for j in v_recitm.first..v_recitm.last loop
     glbx.dbg('glbx.guess_number(p11('||j||') '||glbx.guess_number(p11(j)));
     glbx.dbg('glbx.guess_number(p4('||j||') '||glbx.guess_number(p4(j)));
     glbx.dbg('v_rid('||j||') '||v_rid(j));
      if nvl(glbx.guess_number(p11(j)), 0) = 0 then --DB
        v_recno := v_recno + 1;
        glbx.dbg('v_recno '||v_recno);
        glbx.dbg('p11(j) '||p11(j));
        glbx.dbg('p4(j)) '||p4(j));
      --  glbx.dbg('v_rid(j) '||v_rid(j));
        itmrec := null;
        itmrec := c8rec;
        itmrec.short_text := p9(j);
        itmrec.inventoryno := p2(j);
        glbx.dbg('p4(j)) 2 '||p4(j));
        itmrec.qty := glbx.guess_number(p3(j));
        itmrec.item_gst := null;
        itmrec.item_tamount := null;
        itmrec.item_amount  := null;
        itmrec.discount :=  glbx.guess_number(p10(j));
        itmrec.calc_amount := null;
        itmrec.po_item := null;
        itmrec.po_number := p13;
        itmrec.supinv := p14;
        itmrec.base_unit_price := glbx.guess_number(p4(j));
        itmrec.recno := v_recno;
        itmrec.delete_flg := null; 
        itmrec.orig_qty         := null; 
        itmrec.orig_base_unit_price  := null;
        itmrec.orig_inventoryno := null;
        itmrec.code             := null;
        itmrec.orig_item_gst    := null;
        itmrec.orig_item_amount := null;
        itmrec.other            := null;
        itmrec.orig_tamount     := null;
        itmrec.orig_gst         := null;
        itmrec.remarks          := 'ADDED';
    
        insert into strang.parsed_invoice_items values itmrec RETURNING rowid into v_rowid  ; --DB

           v_rid(j) := ROWIDTOCHAR(v_rowid);
        -- v_rid(v_recno) := ROWIDTOCHAR(v_rowid);
         glbx.dbg( 'v_rid('||j||') := '|| ROWIDTOCHAR(v_rowid)); 
        v_rowid := null;
       end if; -- DB
    end loop;
  end if;
  commit;
--select *
--from websys.debug
--order by ctr;
--  invoice_mng(surl,  vtyp, action||' process done..',batchno => v_batch );
--  RETURN;

--- Deal with PriceItem Checkbox entries here.
--------------------------------------------------------------------------------
    itm_ctr := 0;
    if priceitm.count > 1 then
    
       for j in priceitm.first..priceitm.last-1 loop
	      if priceitm(j) = '0' and priceitm(j + 1) = '0' then
	         itm_ctr := itm_ctr + 1; v_priceitm(itm_ctr) := 'F'; -- priceitm(j + 1);
	         --  if v_recitm(itm_ctr) = 'T' then print_ok := TRUE; end if;
	      elsif priceitm(j) = '0' then
	         itm_ctr := itm_ctr + 1; v_priceitm(itm_ctr) := 'T';
	      end if;
	      
       end loop;
       if priceitm(priceitm.last) = '0' then
	      itm_ctr := itm_ctr + 1;
	      v_priceitm(itm_ctr) := 'F';   
       end if;
    elsif priceitm.count = 1 then
       v_priceitm(1) := 'F';
    end if;
--    
---------------------------------------------------------------------------------        
    for j in v_recitm.first..v_recitm.last loop
       v_p3 := null;
       v_p4 := null;
       v_p10 := null;
       
       v_step :=  'step 3';  
       glbx.dbg('p3('||j||') '||p3(j));       
       glbx.dbg('p4('||j||') '||p4(j));
       glbx.dbg('p9('||j||') '||p9(j));
       v_step :=  'step 3a';  
       glbx.dbg('p10('||j||') '||p10(j));
       glbx.dbg('p11('||j||') '||p11(j));
        
       
       if p16(j) is not null then
       
          if  p16(j)  in ('EX', 'NS', 'PRO0', 'PRO1')  then
           --  v_g_gst_rate := 0.0; 
           --   v_gstcode := 'NS';
             update strang.parsed_invoice_items
	            set item_gst =  null
	              , gst_rate =  0.0
	              , item_gst_code = p16(j)
	          where rowid = CHARTOROWID(v_rid(j));
	          
          elsif  p16(j) in ('INC', 'NET')  then
           --  v_g_gst_rate := 0.1; 
           --  v_gstcode := 'NET';
             update strang.parsed_invoice_items
	            set gst_rate = 0.1
	              , item_gst_code = p16(j)
	          where rowid = CHARTOROWID(v_rid(j));
           
         else 
            null;
       end if;
       
       
       end if; 
        
       v_step :=  'step 4';   
       if nvl(v_recitm(j),'T') = 'F' then
	      update strang.parsed_invoice_items
	         set delete_flg = 'X'
	      where rowid = CHARTOROWID(v_rid(j));
	   else 
          glbx.dbg('after step 5: j='||j);
	      begin v_p3 := nvl(to_number(p3(j)),0); exception when others then null; end;
	      if p3(j) is null then
	         invoice_mng(surl,  vtyp, action||': Please ensure that Quantities are not null..',batchno => v_batch );
             return;
	      end if;
	      
	      -- DB start here
	      
	      open c15 ( CHARTOROWID(v_rid(j)), p1(j));
	      fetch c15 into c15rec;
	      close c15;
	      
	      if v_p3 is not null and p1(j) is not null and c15rec.invoice_filename = c8rec.invoice_filename and c15rec.po_number = c8rec.po_number  then
	        open c14 ( c8rec.po_number, p1(j));
	        fetch c14 into c14rec;
	        close c14;
	       
	        if nvl(c15rec.sum_qty,0) + nvl(v_p3,0) > nvl(c14rec.openqty,0) then
	           if vmsg is not null then
	              vmsg := vmsg||htf.nl||'WARNING: PO '||c8rec.po_number||' Item '||p1(j)||' in batch has a Cumulative Quantity that exceeds the SAP Open Quantity. Please Contact Manager!!';
	           else
	              vmsg := 'WARNING: PO '||c8rec.po_number||' Item '||p1(j)||' in batch has a Cumulative Quantity that exceeds the SAP Open Quantity. Please Contact Manager!!';
	           end if;

	        end if;
	        
	        
	      end if;   
	      
	      begin v_p4 := to_number(p4(j)); exception when others then null; end;
	      glbx.dbg('after step 5 v_p4 : j='||j);
	      begin v_p10 := to_number(p10(j)); exception when others then null; end;

	      glbx.dbg('approaching step 5a v_p4 : j='||j);
	      if p10(j) is not null then
	         v_step :=  'step 5a';  
             update strang.parsed_invoice_items ii
                set discount = v_p10 -- p3(j)
                  , orig_discount = case when orig_discount is not null then orig_discount else ii.discount end
              where rowid = CHARTOROWID(v_rid(j))
                and p10(j) is not null; 
          else 
             update strang.parsed_invoice_items ii
                set discount = null
                  , orig_discount = case when orig_discount is not null then orig_discount else ii.discount end
              where rowid = CHARTOROWID(v_rid(j))
                and p10(j) is null
                and discount is not null;
                
          end if;
          
          
          -- Add new block of code for saving country codes here.
          
         open c17 (CHARTOROWID(v_rid(j)));
       	 fetch c17 into c17rec;
	     close c17;
	     
	     glbx.dbg ('c17rec.po_number '||c17rec.po_number);
         glbx.dbg ('p13 '|| p13);
         glbx.dbg ('c8rec.po_number  '|| c8rec.po_number );
         
         -- START COUNTRY CODE parsing here  -- DAVID BANJO 
	     if (c17rec.po_number = p13 and p13 <> nvl(c8rec.po_number,'XXXXXXX') or (c8rec.po_number = p13 and c18rec.vendor_id is null)) then 
 
         
            if c9rec.vendor_id in (4001579 ,4002377 ,4002353 ,4000023, 4001447, 4002398, 9000558, 4002587, 4002172 
                                 , 4002545 ,9001199 ,4001974 ,4004043, 4002512, 4002736, 4002024, 4002428
                                 , 4002397 ,4003442 ,4002092, 4006205, 4002130, 4001826, 4001568
                                 , 4001865 ,4001449 ,4001253, 4002198, 4002433, 4001903, 4002169, 4001779, 4003497, 9002663, 4002267
                                 , 9001883, 4002178, 4002802, 9001920 -- LIEBHERR
                                 , 4001986, 4001267, 4001446, 4003511, 4002650, 4001284
                                 , 4001344, 9000449  -- Procureit
                                 , 4002995, 4003727, 4003046 
                                 , 4002536 -- trailer sales hand written 
                                 , 4002952, 4001903
                                 , 4002166 -- COSOL 
                                 , 4002141
                                 , 4002311
                                 , 4001230 -- ESTRY  
                                 , 4001340
                                 , 4001635 -- Dynamics   
                                 , 4002550  -- voith 
                                 , 4001973, 4002633, 4001578 -- Flsmidth
                                 , 4002090 -- Clark Equipment 
                                 , 4001630  -- Adaptalift  
                                 , 4002432 -- Custom Fluids    
                                 , 4002099 -- Southeast Fasteners 
                                 , 4003410 -- Global Welding 
                                 , 4002421 -- HELLA AUSTRALIA
                                 , 4002488 -- Volgren 
                                 , 4003494 -- Australian Wholesale 
                                 , 4001997 -- Alcolizer
                                 , 4002256 -- Caps Australia
                                 , 4003838 -- Southern Queensland Steel
                                 , 4001771 -- Protector Alsafe
                                 , 4001913 -- Fenner Conveyors
                                 , 4002403 -- Combustion & Chemical
                                 , 4002981 -- Moly-COP
                                 , 4001408 -- CHUBB FIRE AND SAFETY
                                 , 4006115 -- MTIS GROUP
                                 , 4001370 -- S M C PNEUMATICS
                                 , 4001838 -- POWERLINK QUEENSLAND
                                 , 4002151 -- R F INDUSTRIES PTY LTD
                                 , 4003645 -- HIGHMARK SOLUTIONS
                                 , 4002069 -- GARDNER DENVER
                                 , 4001468 -- JAMES WALKER
                                 , 4002101 -- C and L tool Centre
                                 , 4002511 -- Cummins South Pacific
                                 , 4001419 -- Valve Torque
                                 , 4003079 -- Prok Conveyor Components
                                 , 4004008 -- Danfoss Power
                                 , 4001925 -- 2MT MINING PRODUCTS
                                 , 4001754 -- Power Step 
                                 , 9002757 -- ARPANSA
                                 , 4001621 -- CORTELA CARBON
                                 , 4003565 -- PURE OIL MAINTENANCE
                                 , 4003373 -- HARTAC SALES 
                                 , 4002345 -- RCS Telecommunications 
                                 , 4003551 -- ROC instrumentation
                                 , 4002038 -- Holmwood Highgate
                                 , 4001394 -- LECO Australia
                                 , 4002150 -- MEDICAL AND SURGICAL REQUISITES
                                 , 4001512 -- TEREX LIFTING 
                                 , 4001734 -- LIVINGSTONE INTL
                                 , 4002208 -- SSS AUSTRALIA
                                 , 4003373 -- HARTAC SALES
                                 , 4003085 -- AUXANO GROUP PTY LTD
                                 , 4004202 -- HYDRAULINK AUSTRALIA PTY LTD
                                 , 4003515 -- FLENDER PTY LTD
                                 , 4001925 -- 2MT MINING PRODUCTS PTY LTD
                                 )  then  -- last B2B
              begin 

              if c9rec.vendor_id in (4002736, 4002024) then
                 websys.p_getcountry_code (c9rec.vendor_id, nvl(c17rec.unit,''),  v_country, v_state);  -- USE unit
              elsif  c9rec.vendor_id in (4001512) then
                 websys.p_getcountry_code (c9rec.vendor_id, nvl(c17rec.country_code,''),  v_country, v_state);  -- USE Country of origin
              elsif c9rec.vendor_id  in (4004043, 4003442, 4006205, 4002166, 4001230 ) then
                 websys.p_getcountry_code (c9rec.vendor_id, nvl(c17rec.other,''),  v_country, v_state);  -- USER OTHER.
              else
                 websys.p_getcountry_code (c9rec.vendor_id, nvl(p9(j),'')||' '||nvl(c17rec.other,''), v_country, v_state);
              end if; 
               exception when others then 
                null;
               end;
            else
               v_country := 'AU';
            end if;
            
            
            
             if v_country is not null then
                update strang.parsed_invoice_items ii
                   set country_code = v_country
                     , orig_country_code = case when orig_country_code is not null then orig_country_code else ii.country_code end
                 where rowid = CHARTOROWID(v_rid(j))
                   and  v_country is not null; 
             else 
                update strang.parsed_invoice_items ii
                   set country_code = null
                     , orig_country_code = case when orig_country_code is not null then orig_country_code else ii.country_code end
                 where rowid = CHARTOROWID(v_rid(j))
                   and v_country is null
                   and country_code is not null;
             end if;
                
             if v_state is not null then
                update strang.parsed_invoice_items ii
                   set state = v_state
                     , original_state = case when original_state is not null then original_state else ii.state end
                 where rowid = CHARTOROWID(v_rid(j))
                   and  v_state is not null; 
             else 
                update strang.parsed_invoice_items ii
                   set state = null
                     , original_state  = case when original_state is not null then original_state  else ii.state end
                 where rowid = CHARTOROWID(v_rid(j))
                   and v_state is null
                   and state is not null;
             end if;
            
        
          else
        
             if p17(j) is not null then
                update strang.parsed_invoice_items ii
                   set country_code = p17(j)
                     , orig_country_code = case when orig_country_code is not null then orig_country_code else ii.country_code end
                 where rowid = CHARTOROWID(v_rid(j))
                   and  p17(j) is not null; 
             else 
                update strang.parsed_invoice_items ii
                   set country_code = null
                     , orig_country_code = case when orig_country_code is not null then orig_country_code else ii.country_code end
                 where rowid = CHARTOROWID(v_rid(j))
                   and p17(j) is null
                   and country_code is not null;
             end if;
          
             if p18(j) is not null then
                update strang.parsed_invoice_items ii
                   set state = p18(j)
                     , original_state = case when original_state is not null then original_state else ii.state end
                 where rowid = CHARTOROWID(v_rid(j))
                   and  p18(j) is not null; 
             else 
                update strang.parsed_invoice_items ii
                   set state = null
                     , original_state  = case when original_state is not null then original_state  else ii.state end
                 where rowid = CHARTOROWID(v_rid(j))
                   and p18(j) is null
                   and state is not null;
             end if;
          
          end if;
          
          if p9(j) is not null then
	       v_step :=  'step 5ac';  
             update strang.parsed_invoice_items ii
                set short_text = p9(j)
                  , orig_short_text = case when orig_short_text is not null then orig_short_text else ii.short_text end
              where rowid = CHARTOROWID(v_rid(j))
                and p9(j) is not null; 
                
          else
              v_step :=  'step 5ad';  
              update strang.parsed_invoice_items ii
                set short_text = null
                  , orig_short_text = case when orig_short_text is not null then orig_short_text else ii.short_text end
              where rowid = CHARTOROWID(v_rid(j))
                and p9(j) is null
                and short_text is not null;
                
          end if;
	      
          if v_priceitm(j) is not null then
             update strang.parsed_invoice_items ii
                set priceitm = v_priceitm(j)
              where rowid = CHARTOROWID(v_rid(j))
                and ii.priceitm <> v_priceitm(j);               
          end if;
	      
	      
	      if p3(j) is not null then  
             update strang.parsed_invoice_items ii
                set qty = v_p3 -- p3(j)
                  , orig_qty = case when orig_qty is not null then orig_qty else ii.qty end
                  , calc_amount = round(ii.base_unit_price * v_p3  *(1 - (nvl(ii.discount,0)/100)),2) -- check for number pls.
                  , item_amount = round(ii.base_unit_price * v_p3  *(1 - (nvl(ii.discount,0)/100)),2) -- check for number pls.
              where rowid = CHARTOROWID(v_rid(j))
                and p3(j) is not null;       
          end if;
          
          if p4(j) is not null then
             update strang.parsed_invoice_items ii
                set base_unit_price = v_p4
                  , orig_base_unit_price  = case when orig_base_unit_price is not null then orig_base_unit_price else ii.base_unit_price end
                  , unit_price = round(to_number(v_p4) *(1 - (nvl(ii.discount,0)/100)),4) 
                  , calc_amount = round(to_number(v_p4) * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2)  -- check for number later.
                  , item_amount = round(to_number(v_p4) * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2)  -- check for number later.
                  , item_tamount = case when nvl(nvl(ii.gst_rate,ii.gst),0) > 0 
                                     then round(v_p4 * ii.QTY,2) + round(round(v_p4 * ii.QTY,2) * nvl(invoice_parser.g_gst_rate,0),2) 
                                      else  round(v_p4 * ii.QTY,2) end
                  , item_gst = case when nvl(nvl(ii.gst_rate,ii.gst),0) > 0 then
                                    round(round(v_p4 * ii.QTY,2) * nvl(invoice_parser.g_gst_rate,0),2)      
                                     else null end
             where rowid = CHARTOROWID(v_rid(j))
               and p4(j) is not null; 
          end if;
          
          v_step :=  'step 10';   
          
          if p1(j) is not null then
             v_step :=  'step 10a';   
                
               -- David Banjo START HERE!!!!
             open c13(batchno, p13, p1(j), c1rec.username);
             fetch c13 into c13rec;
             if c13%found then
                close c13;
                invoice_mng(surl,  vtyp, action||': Another User('||c13rec.username||') on batch '||batchno||' is currently using PO: '||p13||'('||p1(j)||'). Please hold on and retry later', batchno => v_batch );
                return;
	         end if;
             close c13;
             
             update  strang.parsed_invoice_items ii
                set  po_item  = p1(j)
              where rowid = CHARTOROWID(v_rid(j))
                and p1(j) is not null
                and ((not exists (select 1
                                  from strang.parsed_invoice_items i
                                 where i.po_number = ii.po_number
                                   and i.batch_id = batchno
                                   and ii.invoice_filename = i.invoice_filename
                                   and i.delete_flg is null
                                   and nvl(i.po_item,99999) = p1(j)) )
                  or v_priceitm(j) = 'T');   -- added by David Banjo
             
             
             if v_priceitm(j) = 'T' and NOT ( substr(p13,1,2) = '47' or substr(p13,1,2) = '80')  then 
               --- qty multipled twice in total
                update  strang.parsed_invoice_items ii
                   set (base_unit_price, unit_price, calc_amount, item_amount, item_tamount, item_gst, inventoryno, orig_inventoryno, po_item ) = 
                   
                         (select ii.base_unit_price
                               , case when ii.discount is null then to_number(ii.base_unit_price)
                                      when ii.discount is not null then round(to_number(ii.unit_price) *(1 - (nvl(ii.discount,0)/100)),4) end
                               , round(round(ii.base_unit_price * ii.QTY,2) *(1 - (nvl(ii.discount,0)/100)),2)
                               , round(round(ii.base_unit_price * ii.QTY,2) *(1 - (nvl(ii.discount,0)/100)),2)
                               
                               , case when nvl(nvl(ii.gst_rate,ii.gst),0) > 0 
                               
                                     then round(round(ii.base_unit_price * ii.QTY,2) *(1 - (nvl(ii.discount,0)/100)),2) + round(round(round(ii.base_unit_price * ii.QTY,2) *(1 - (nvl(ii.discount,0)/100)),2) * nvl(invoice_parser.g_gst_rate,0),2) 
                                     
                                    else  round(round(ii.base_unit_price * ii.QTY,2) *(1 - (nvl(ii.discount,0)/100)),2) end
                                      
                               , case when nvl(nvl(ii.gst_rate, ii.gst),0) > 0 then
                                  -- round(round(net_price * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2) * nvl(g_gst_rate,0),2)    
                                    round(round(ii.base_unit_price * ii.QTY,2)* nvl(invoice_parser.g_gst_rate,0),2)   
                                     else null end
                               , nvl(p.material,p2(j)) 
                               , null
                               , p1(j)
                            from strang.po_pool p --, strang.parsed_invoice_items ii2
                           where ii.PO_NUMBER = p.PO_NUMBER
                             and ii.rowid = CHARTOROWID(v_rid(j))
                             and p.po_item = p1(j))
                where rowid = CHARTOROWID(v_rid(j))
                and p1(j) is not null
                and po_item =   p1(j); 
--                and not exists (select 1
--                                  from strang.parsed_invoice_items i
--                                 where i.po_number = ii.po_number
--                                   and i.delete_flg is null
--                                   and i.batch_id = batchno
--                                   and ii.invoice_filename = i.invoice_filename
--                                   and nvl(i.po_item,99999) = p1(j)) ;        
             
             elsif NOT ( substr(p13,1,2) = '47' or substr(p13,1,2) = '80') then
             
                update  strang.parsed_invoice_items ii
                   set  po_item  = p1(j)
                 where rowid = CHARTOROWID(v_rid(j))
                   and p1(j) is not null
                   and not exists (select 1
                                  from strang.parsed_invoice_items i
                                 where i.po_number = ii.po_number
                                   and i.batch_id = batchno
                                   and ii.invoice_filename = i.invoice_filename
                                   and i.delete_flg is null
                                   and nvl(i.po_item,99999) = p1(j)) ; 
                   
                update  strang.parsed_invoice_items ii
                   set (base_unit_price, unit_price, calc_amount, item_amount, item_tamount, item_gst, inventoryno, orig_inventoryno ) = 
                         (select case when ii.discount is null then to_number(net_price)
                                      when ii.discount is not null then round(to_number(net_price)/(1.00 - (nvl(ii.discount,0.00)/100.00)),4) end
                               , round(net_price,4)
                               , round(net_price * ii.QTY,2)   --*(1 - (nvl(ii.discount,0)/100)),2)
                               , round(net_price * ii.QTY,2)   --*(1 - (nvl(ii.discount,0)/100)),2)
                               , case when nvl(nvl(ii.gst_rate, ii.gst),0) > 0 
                                     then round(net_price * ii.QTY,2) + round(round(net_price * ii.QTY,2) * nvl(invoice_parser.g_gst_rate,0),2) 
                                      else  round(net_price * ii.QTY,2) end
--                                     then round(net_price * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2) + round(round(net_price * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2) * nvl(g_gst_rate,0),2) 
--                                      else  round(net_price * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2) end
                               , case when nvl(nvl(ii.gst_rate,ii.gst),0) > 0 then
                                  -- round(round(net_price * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2) * nvl(g_gst_rate,0),2)    
                                    round(round(net_price * ii.QTY,2) * nvl(invoice_parser.g_gst_rate,0),2)      
                                     else null end
                               , nvl(p.material,p2(j)) 
                               , null
                          --     ,p1(j)
                            from strang.po_pool p --, strang.parsed_invoice_items ii2
                           where ii.PO_NUMBER = p.PO_NUMBER
                             and ii.rowid = CHARTOROWID(v_rid(j))
                             and p.po_item = p1(j))
                where rowid = CHARTOROWID(v_rid(j))
                and p1(j) is not null
                and po_item =   p1(j); 
--                and not exists (select 1
--                  from strang.parsed_invoice_items i
--                 where i.po_number = ii.po_number
--                   and i.batch_id = batchno
--                   and i.delete_flg is null
--                   and ii.invoice_filename = i.invoice_filename
--                   and nvl(i.po_item,99999) = p1(j)) ;  
                                   
             end if;                  
                                   
                                                                     
          elsif p2(j) is not null then
	         if p1(j) is null then
	            v_step :=  'step 10b'; 
	            
	            glbx.dbg('I am in the inv update and p2('||j||') is: '||p2(j));

	            update strang.parsed_invoice_items ii
	              set inventoryno = p2(j)
	            where rowid = CHARTOROWID(v_rid(j));
	            
                update strang.parsed_invoice_items ii
                   set (base_unit_price, unit_price, calc_amount, item_amount, inventoryno) = 
                         (select case when ii.discount is null then to_number(net_price)
                                      when ii.discount is not null then round(to_number(net_price)/(1.00 - (nvl(ii.discount,0.00)/100.00)),4) end
                               , net_price
                               , round(net_price * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2)
                               , round(net_price * ii.QTY *(1 - (nvl(ii.discount,0)/100)),2)
                               , p2(j)
                            from strang.po_pool p
                           where ii.PO_NUMBER = p.PO_NUMBER
                             and ii.INVENTORYNO = p.material
                             and ii.rowid = CHARTOROWID(v_rid(j))
                             and p.material = p2(j))
                 where round(nvl(ii.unit_price,0) * nvl(ii.QTY,0) *(1 - (nvl(ii.discount,0)/100)),2) <> round(nvl(ii.orig_ITEM_AMOUNT,0),2) 
                   and rowid = CHARTOROWID(v_rid(j))
                   and p2(j) is not null;
             end if;
          end if;
       end if; 
    v_step :=  'step 11';   
    
    end loop;
    
    -- check that delivery_item_no is in the selected PO item_no list
    
    if nvl(v_del_chg,0) <> 0 then
    
       open c22(batchno, v_del_item);
        fetch c22 into c22rec;
       close c22;
       
       if c22rec.cnt = 0 and c22rec.min_po_item is not null then
    
          update strang.parsed_invoice_items ii
             set freight_po_item = c22rec.min_po_item
           where batch_id = batchno
             and invoice_filename = c8rec.invoice_filename
             and delete_flg is null;
       end if;
        
    end if;
    
    

 -------------------------------------------------------------------------------   
    v_step :=  'step 12';
     
    open c8 (batchno);
	fetch c8 into c8rec;
	close c8;
    open c11 (batchno,c8rec.po_number);
	fetch c11 into c11rec;
	if c11%found then
	   close c11;
	   
	   if c11rec.vendor_id is null then
	      update strang.parsed_invoice_header
             set proceed = 'NO'
              ,  username = c1rec.username
           where batch_id = batchno;
           
         invoice_mng(surl,  vtyp, action||' Action: No Vendor supplied to GLMS. Please get OKTEDI to push vendor details to GLMS..',batchno => v_batch );
	     return;
	     
	   end if;
    
       open c6(batchno);
       fetch c6 into c6rec;
       close c6;
    
       if abs(nvl(c6rec.tot_amt,0) - nvl(c6rec.item_amt,0) - nvl(c6rec.delivery_charge,0)) < 2 and c6rec.cnt = 0 and c6rec.cnt2 = 0  then
          update strang.parsed_invoice_header
          set proceed = 'YES'
           ,  username = c1rec.username
          where batch_id = batchno; 
       
          update strang.parsed_invoice_items
          set proceed = 'YES'
          where batch_id = batchno
           and NVL(proceed,'NO') <> 'YES'; 
           
       elsif abs(nvl(c6rec.tot_amt,0) - nvl(c6rec.item_amt,0) - nvl(c6rec.delivery_charge,0)) >= 2 then 
       
          open c21(batchno);
          fetch c21 into c21rec;
          if c21%notfound and nvl(v_del_chg,0) <> 0  then 
             if vmsg is not null then
	            vmsg := vmsg||htf.nl||'Check delivery charge item number is in PO item no list';
	         else 
                vmsg := 'Check delivery charge item number is in PO item no list';
             end if;
          
          else
          
             if vmsg is not null then
	            vmsg := vmsg||htf.nl||'The ensure that the invoice total equals the sum of the item amounts + delivery charges';
	         else 
                vmsg := 'The ensure that the invoice total equals the sum of the item amounts + delivery charges';
             end if;
          end if;
          close c21;
          
       end if;
    else 
       close c11;
       update strang.parsed_invoice_header
          set proceed = 'NO'
           ,  username = c1rec.username
        where batch_id = batchno;
        
       if c9rec.vendor_id is null then 
          invoice_mng(surl,  vtyp, action||' Action: previous entries cleared....',batchno => null);
        else
          open c6(batchno);
          fetch c6 into c6rec;
          if c6%found then
            close c6;
	        invoice_mng(surl,  vtyp, action||' Action: PO '||c8rec.po_number||' is associated with a different supplier or no open quantities for this PO ..',batchno => v_batch );
	      else 
	        close c6;
	        invoice_mng(surl,  vtyp, action||' Action: previous entries cleared....',batchno => null);
	      end if;
	   end if;
	   return;
    
    end if;   
    
 -----------------------------------------------------------------------------------------------------------------------   
    
    commit;
    
    insert into strang.parsed_invoice_items_archive
    select * 
    from strang.parsed_invoice_items
    where batch_id = batchno
    and delete_flg is not null;
    
    delete from strang.parsed_invoice_items
    where batch_id = batchno
    and delete_flg is not null;
    
    update strang.parsed_invoice_header
       set gtotal = (select sum(nvl(item_amount,0)) + sum(nvl(item_gst,0)) + sum(nvl(case when nvl(po_item,9999) = nvl(freight_po_item,8888) then delivery_charge else 0 end,0)) 
                      from strang.parsed_invoice_items ii
                     where batch_id = batchno
                       and delete_flg is null)
       where batch_id = batchno; 
    
    
    commit;
    
    if vmsg is not null then
       invoice_mng(surl,  vtyp, vmsg,batchno => v_batch );  -- added by DB;
    else
       invoice_mng(surl,  vtyp, action||' process done..',batchno => v_batch );
    end if;
    
   --- invoice_mng(surl,  vtyp, action||' process done..',batchno => v_batch );
    return;
 elsif upper(action) = 'CREATE DELIVERY' then

    -- Start Here ---
    open c9 (batchno);
	fetch c9 into c9rec;
	close c9;
       
    if c9rec.deliveryno is not null then
       msg := 'Invalid action: Deliveryno: '||c9rec.deliveryno||' has already been created for batch: '||batchno||' <br>';
       -- invoice_mng(surl, vtyp, msg, batchno => v_batch );
       invoice_mng(surl, vtyp, msg, batchno => batchno );
       return;
    end if;
    


    open c2 (batchno);
    fetch c2 into c2rec;
    close c2; 
    open c4( 'Receival' );
    fetch c4 into c4rec;
    close c4;
    
--   Amended on Jon and Jacob's recommendation.
    
--    if Upper(c2rec.shipping_text) like '% AIR %' then
--      v_sa := 'A';
--    else
--      v_sa := 'S';
--    end if;

    if c2rec.mode_cnt > 0 then
       v_sa := 'A';
    else 
       v_sa := 'S';
    end if;
    
    case upper(vste)
           when 'BNE' then
	          select strang.s_deliveryno_bne.nextval into newdlr from dual;
           when 'SYD' then
	          select strang.s_deliveryno_syd.nextval into newdlr from dual;
           when 'TVL' then
	          select strang.s_deliveryno_tvl.nextval into newdlr from dual;
           when 'PER' then
	          select strang.s_deliveryno_per.nextval into newdlr from dual;
           when 'MEL' then
	          select strang.s_deliveryno_mel.nextval into newdlr from dual;
           when 'ADL' then
	          select strang.s_deliveryno_adl.nextval into newdlr from dual;
           when 'CNS' then
	          select strang.s_deliveryno_cns.nextval into newdlr from dual;
           when 'KIU' then
	          select strang.s_deliveryno_kiu.nextval into newdlr from dual;
           when 'TAB' then
	          select strang.s_deliveryno_tab.nextval into newdlr from dual;
           else
	          glbx.error_details( 'INVOICE_PARSER', 'INVOICE_MNG_ACCEPT',null,owner_id,errmsg=>'Invalid Location',extdet=>'VSTE:' || vste);
      end case;
      
      if vste in ('MEL','SYD','MOT','KIU','TAB') then
        v_curr := 'PGK';
        xrate := 1;
        v_gst_code := 'EX';
      else
         if nvl(c2rec.gst,0) > 0 then
            v_gst_code := 'NET';
         else
            v_gst_code := 'NS';
         end if;  
         v_curr := 'AUD';
         xrate := 1;
      end if;

--select strang.f_getlovcolumn('GSTCODES','COLA','INC' ) from dual;

--select to_number(cola) cola, colb, code, description from strang.lov where lov_name = 'GSTCODES'; -- and code = cde;


      if nvl(c2rec.gst,0) > 0 then
         v_gst_code := 'NET';
         v_gst_rate := (strang.f_getlovcolumn('GSTCODES','COLA',v_gst_code )/100);
      else
         v_gst_code := 'NS';
         v_gst_rate := (strang.f_getlovcolumn('GSTCODES','COLA',v_gst_code )/100);
      end if;  
      
     v_step := 'step 1';
     insert into strang.receivals
     (deliveryno,currdate,curr,exrate,gstc_gstcode,cust_customer_id,supplier_customer_id,r_notes,status,rec_docket,rec_trans_company,rec_truck_rego,io, created_by, currtime) values
     (newdlr, trunc(sysdate),v_curr,decode(v_curr,'AUD',1,xrate),v_gst_code,c2rec.customer_id,c2rec.vendor_id,v_user, v_status,null,null,null,v_io,c1rec.username, dtime) returning rowid into newrid;
     
     v_step := 'step 1a';
     nlog := null;
     insert  into strang.detailrs(deliveryno,itemno,sa,cl,pktpe_packtype,owner,partvolume,partweight,qty,logno,io) values
        (newdlr,1,v_sa,'C','UNIT','1',0,0,1,nlog,v_io);

      v_step := 'step 2';
--    select *
--    from strang.lov where lov_name = 'GSTCODES';

   -- start receive_po stuff here!
     for c2rec in c2(batchno) loop
      
        interface1 := TRUE;
        if c2rec.customer_id = 1 and interface1 then
           vClient := TRUE;
        else
           vClient := FALSE;
        end if;

        if vClient and substr(c2rec.po_number,1,2) in ('47','80') then
           vClient := FALSE;
        end if;
        v_step := 'step 3';
        if not vClient then 
           begin
             insert into strang.pos(deliveryno, recno, inventoryno, po, ctry_countrycode, supinv, gstc_gstcode, gst, amount, tamount, delivery_charge, qty, unit_unitused, excise_qty, excise_unit, po_item_no ,off_site_receipt ,sap_delno_unit ,sap_delno_qty, grn
                       , po_pool_lookup, grn_status, grn_item, sap_delno, freight_mode, io, shipping_text
                       , critical_flag, sap_delno_open_qty, preq_item, preq_name, preq_no, state, warehouse_plant) values
                       (newdlr, to_number(c2rec.po_recno ), strang.f_sap_format(c2rec.inventoryno,'INVENTORYNO'), strang.f_sap_format(c2rec.po_number,'PO'), NVL(c2rec.country_code,'XX'),case when c2rec.vendor_id = 4001779 then replace( c2rec.supinv, ' ','') else c2rec.supinv end  ,nvl(c2rec.item_gst_code,v_gst_code), c2rec.item_gst ,c2rec.item_amount, c2rec.item_tamount
                       , case when nvl(c2rec.freight_po_item,9999) = c2rec.po_item then nvl(c2rec.delivery_charge,0.00) else 0.0 end
                       ,c2rec.qty, v_unit, null, null, c2rec.po_item, null, c2rec.po_unit_iso ,c2rec.quantity, null,  null, 0, null, null, null, v_io, c2rec.shipping_text, c2rec.critical, case when nvl(c2rec.openqty,0) - nvl(c2rec.qty,0) = 0 then null else nvl(c2rec.openqty,0) end, c2rec.preq_item
                       , c2rec.preq_name, c2rec.preq_no, c2rec.state, c2rec.collect_no); 

           exception
           
             when others then
              raise;
           -- receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_079 || ': ' || sqlerrm );
              return;
           end;
        else
           begin

            insert into strang.pos(deliveryno, recno, inventoryno, po, ctry_countrycode, supinv, gstc_gstcode, gst, amount, tamount, delivery_charge, qty, unit_unitused,excise_qty,excise_unit, po_item_no,off_site_receipt
                                     ,sap_delno_unit,sap_delno_qty,grn,po_pool_lookup,grn_status,grn_item, sap_delno, freight_mode, io
                                     , shipping_text, critical_flag, sap_delno_open_qty, preq_item, preq_name, preq_no, state, warehouse_plant) values
                                     ( newdlr, to_number(c2rec.po_recno ), strang.f_sap_format(c2rec.inventoryno,'INVENTORYNO'),strang.f_sap_format(c2rec.po_number,'PO') ,nvl(c2rec.country_code,'XX'),case when c2rec.vendor_id = 4001779 then replace( c2rec.supinv, ' ','') else c2rec.supinv end, nvl(c2rec.item_gst_code,v_gst_code)   ,c2rec.item_gst,c2rec.item_amount, c2rec.item_tamount
                                     , case when nvl(c2rec.freight_po_item,9999) = c2rec.po_item then nvl(c2rec.delivery_charge,0.00) else 0.0 end,c2rec.qty, v_unit, null, null, c2rec.po_item, null
                                     , c2rec.po_unit_iso, c2rec.qty, null, null, 0, null, null, null, v_io, c2rec.shipping_text
                                     , c2rec.critical, case when nvl(c2rec.openqty,0) - nvl(c2rec.qty,0) = 0 then null else nvl(c2rec.openqty,0) end
                                     , c2rec.preq_item, c2rec.preq_name, c2rec.preq_no, c2rec.state, c2rec.collect_no );
                                     
           exception
            when others then
              raise;
           -- receive_po(surl,rid,scid,null,parm,access_id,recctr,LNGS.STR_TXT_079 || ': ' || sqlerrm );
              return;
            end;
        end if;
        
        v_step := 'step 4';
        
        if nvl(c2rec.qty,0) > 0 then 
           update strang.po_pool 
           set openqty = to_char(nvl(to_number(openqty),0) - nvl(c2rec.qty,0)) 
           where po_number = c2rec.po_number and po_item = c2rec.po_item;
        end if;
        
     end loop;
     -- updated the header table
     update strang.parsed_invoice_header
        set deliveryno = newdlr
      where batch_id = batchno; 
     
     commit;
     -- end loop here
     -- CONSOLIDATE AND COPY invoice files
     
     BEGIN
        v_dir :=  'P:\piction\shared\invoices\' || to_char(sysdate,'YYYYMMDD')|| decs.UNIX_OR_NT;   
        work_dir := nvl(glbx.extract_master_parameter('WORK_DIRECTORY'), 'c:\temp');
        select to_char(newdlr)||'_'||to_char(sysdate,'YYYYMMDDHH24MISS') into v_jobno from dual;
        work_file := 'batch_' || v_jobno  || '.bat';
        pdf_array.delete;
        outp_array.delete;
        ctr := 0;
        f := utl_file.fopen(work_dir, work_file, 'w', 32700);
        utl_file.put_line(f, '@echo off', TRUE);
        utl_file.put_line(f, 'set PATH=%PATH%;' || c_pdf_tk , TRUE);
     
        for c7rec in c7(batchno) loop
        -- check this path:
           pdf_file  :=  'P:\piction\shared\invoices\' || to_char(c7rec.date_created,'YYYYMMDD')|| decs.UNIX_OR_NT||c7rec.invoice_filename;
        --   pdf_file  :=  'c:\temp\shared\invoices\' || to_char(sysdate,'YYYYMMDD')|| decs.UNIX_OR_NT||c7rec.invoice_filename;  -- to_char(c7rec.date_created,'YYYYMMDD')
           if file_exists(pdf_file, null)
           then
              ctr := ctr + 1;
              pdf_array(ctr) := pdf_file;
           end if;
        end loop;
     
        if pdf_array.count > 0
        then
           pdf_trgt_2 := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT || to_char(newdlr) || decs.UNIX_OR_NT || 'INVOICE' || decs.UNIX_OR_NT || to_char(newdlr)|| '_invoice.pdf';
           v_dir2 := glbx.extract_master_parameter('STRANG_RECEIVALS_DIR') || decs.UNIX_OR_NT || to_char(newdlr) || decs.UNIX_OR_NT || 'INVOICE' || decs.UNIX_OR_NT;
         --  v_cmd := c_cmd_2 || ' "' || pdf_trgt_1 || '" ';
           utl_file.put(f, v_cmd);
           for j in pdf_array.first..pdf_array.last loop
             if j = 1 then
                v_cmd := c_cmd_2 || ' "' ||  pdf_array(j)|| '" ';
                utl_file.put(f, v_cmd);
             else 
                utl_file.put(f, '"' || pdf_array(j) || '" ');
             end if;
          end loop;
        end if;
        utl_file.put_line(f, ' output "' || pdf_trgt_2 || '"', TRUE);
         -- utl_file.put_line(f, 'del "' || pdf_trgt_1 || '"', TRUE);
        utl_file.put_line(f, 'exit', TRUE);
        utl_file.fclose(f);
        if utl_os.mkdir(v_dir2) then null; end if;
        begin utl_os.OsCmdDirectWait(work_dir || decs.UNIX_OR_NT || work_file); exception when others then glbx.error_details( 'INVOICE_PARSER', 'INVOICE_MNG_ACCEPT',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'PARM:' || 'PARSER'); end;
        if utl_os.delete_file(work_dir || decs.UNIX_OR_NT || work_file) then null;  end if;
     exception when others
     then
        glbx.error_details( 'INVOICE_PARSER', 'INVOICE_MNG_ACCEPT',c1rec.pid,c1rec.aid,errmsg=>sqlerrm,extdet=>'PARM:' || 'PARSER');
        begin utl_file.fclose(f); exception when others then null; end;
        glbx.dbg('Error creating file: ' || sqlerrm);
        RETURN;
     END;
     
     strangp.receive( surl, rowidtochar(newrid), c4rec.screen_id, 'strangp.receive', 'RECEIVALS', 'x', LNGS.STR_TXT_039 );
     return;
 
  
 elsif UPPER(ACTION) like '%RELOAD LATEST INVOICE%' then
       
    open c8 (batchno);
	fetch c8 into c8rec;
	close c8;
	
	open c9 (batchno);
	fetch c9 into c9rec;
	close c9;
	    
	insert into strang.parsed_invoice_items_archive
    select * 
    from strang.parsed_invoice_items
    where batch_id = batchno
    and  invoice_filename = c8rec.invoice_filename;
  --  and delete_flg is not null;
    
    delete from strang.parsed_invoice_items
    where batch_id = batchno
    and  invoice_filename = c8rec.invoice_filename;
    --and delete_flg is not null;
    
    if c9rec.proceed is null then 
       null;
    else 
       update strang.parsed_invoice_header
          set proceed = 'NO'
        where batch_id = batchno; 
        

    end if;
       
    
    commit;

        parse_invoice( c8rec.invoice_filename, v_batch, msg, c8rec.identifier);
	    if nvl(v_batch,0) <> 0 then 
	       if msg is not null then
	          msg := msg || ' Invoice file : ' || c8rec.invoice_filename|| '<br>';
	       else
	          msg := 'Invoice file : ' ||c8rec.invoice_filename || ' Reloaded<br>';
	       end if;
	    end if;
	    
	    invoice_mng(surl, vtyp, msg, batchno => v_batch );
        return;
 
 end if;

 if upper (action) not like 'LOAD INTO%'
  then
   invoice_mng(surl,  vtyp, 'Invalid action: ' || action);
   return;
 end if;
 
 if nvl(batchno,0) <> 0 then
    open c9 (batchno);
	fetch c9 into c9rec;
	close c9;
    if nvl(c9rec.proceed,'NO') <> 'YES' then
       msg := 'Invalid action: Please update and reconcile the previous invoice load<br>';
       invoice_mng(surl, vtyp, msg, batchno => v_batch );
       return;
    end if;
 end if;
 
-- if  nvl(batchno,0) = 0  then 
--    null;
-- else 
--    update strang.parsed_invoice_header
--       set proceed = 'NO'
--     where batch_id = batchno; 
--        
-- end if;
 
 for j in infile.first..infile.last loop
 
  open c3(infile(j));
  fetch c3 into c3rec;
  if c3%FOUND
   then
    close c3;
    v_dir :=  'P:\piction\shared\invoices\' || to_char(sysdate,'YYYYMMDD')|| decs.UNIX_OR_NT;
	v_file :=  glbx.extract_fname(c3rec.name, 'FILE');
	--chkval := check_file_name(v_file, c2rec.deliveryno, trim(replace(upper(action), 'LOAD INTO', '')));
	
	open c10(batchno, v_file);
    fetch c10 into c10rec;
    if c10%FOUND then
       close c10;
       delete from apache_ows_content where name = infile(j); commit;
       msg := 'Invalid action: Invoice file - '||c10rec.invoice_filename||' already loaded in this batch<br>';
       invoice_mng(surl, vtyp, msg, batchno => v_batch );
       return;
    end if;
    close c10;

    if chkval is not null
	 then
	  msg := msg || chkval || '<br>';
	else
      if utl_os.mkdir(v_dir) then null; end if;
      utl_blob.blobtofile(c3rec.blob_content, v_dir || decs.UNIX_OR_NT || v_file, FALSE);
	  if file_exists(v_dir, v_file)
	   then
	   -- remove any password protection on pdf file
	      if upper(glbx.extract_fname(v_file, 'SUFFIX', 100)) = 'PDF' then
	         select strang.s_decrypt_pdf.nextval into jobno from dual;
	         work_dir := nvl(glbx.extract_master_parameter('WORK_DIRECTORY'), 'c:\temp');
             work_file := 'batch_' || jobno || '.bat';
             f := utl_file.fopen(work_dir, work_file, 'w', 32700);
             utl_file.put_line(f, '@echo off', TRUE);
             utl_file.put_line(f, 'set PATH=%PATH%;' || qpdf_path, TRUE);
             utl_file.put_line(f, qpdf_prog||' --decrypt "'||v_dir || decs.UNIX_OR_NT || v_file||'" "'||v_dir || decs.UNIX_OR_NT || v_file||'.tmp"');
             utl_file.put_line(f, 'del "'||v_dir || decs.UNIX_OR_NT || v_file||'"');
             utl_file.put_line(f, 'ren "'||v_dir ||decs.UNIX_OR_NT || v_file||'.tmp" "'|| v_file||'"');
             utl_file.put_line(f, 'exit', TRUE);
             utl_file.fclose(f);
             begin utl_os.OsCmdDirectWait(work_dir || decs.UNIX_OR_NT || work_file); exception when others then null; end;
             if utl_os.delete_file(work_dir || decs.UNIX_OR_NT || work_file) then null;  end if;
          else 
              NULL;
--              msg := 'Invalid action: Invoice file - '||c10rec.invoice_filename||' not a PDF file<br>';
--             invoice_mng(surl, vtyp, msg, batchno => v_batch );
--             return;
          
	      end if;
	   
	   -- parse pdf invoice
	   
	   	if  nvl(batchno,0) = 0  then 
           null;
        else 
        
           update strang.parsed_invoice_header
              set proceed = 'NO'
            where batch_id = batchno; 
        
        end if;
        
	    parse_invoice( v_file, v_batch, msg);
	    if nvl(v_batch,0) <> 0 then 
	       if msg is not null then
	          msg := msg || ' Invoice file : ' || v_file || '<br>';
	          if msg like 'PO number starts with 80 or 47%' and c9rec.proceed is null then
	             v_batch  := null;
	          end if;
	       else
	          msg := 'Invoice file saved and parsed: ' || v_file || '<br>'||'Remember to follow File Name Link to Review and Confirm document ALWAYS!!<br>';
--	          update strang.parsed_invoice_header
--	             set proceed  = 'NO'
--	              ,  username = c1rec.username
--	           where batch_id = v_batch;
	       end if;   
	          
	    else 
	       msg := msg || 'Invoice file saved but not parsed: ' || v_file || '<br>';
	    
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
 
 invoice_mng(surl, vtyp, msg, batchno => v_batch );
exception when others then
 glbx.dbg( 'v_step: '||v_step);
 glbx.dbg('Error: ' || sqlerrm);
 htp.bold('Error: ' || sqlerrm);
end invoice_mng_accept;

PROCEDURE parse_invoice (vfile in varchar2 default null, batchno in out number, msg in out varchar2, p_identifier in varchar2 default null ) is
 

  cursor c1 (v_po varchar2, v_inventory varchar2 ) is
   select po_number
        , po_item
        , net_price, quantity, shipping_text, short_text, vend_name, tax_code, material
        , count(*) over (partition by po_number,net_price) cnt
     from strang.po_pool pp
     where po_number= trim(v_po)
      and  material = trim(v_inventory)
      and openqty > 0;
--      and not exists (select 1
--                        from strang.pos p
--                       where pp.po_number = p.po
--                        and pp.po_item = p.po_item_no);
                        
  cursor c2 (v_po varchar2) is
   select po_number
        , po_item
        , pp.vendor vendor_id
        , customer  vendor_name
     from strang.po_pool pp
         ,strang.customers c
     where po_number=  trim(v_po)
       and pp.vendor = c.customer_id
       and c.customer_type = 'SUPPLIER'
       and pp.date_created > sysdate - 800
       order by pp.date_created desc;
   


  cursor c3 (v_batchno integer) is
   select vendor_id
        , customer_id
     from strang.parsed_invoice_header ih
     where batch_id = v_batchno;    
       
  cursor c4 (v_batchno integer, v_supinv varchar2 ) is
   select *
     from strang.parsed_invoice_items ii
     where batch_id = v_batchno
       and supinv = v_supinv
       and delete_flg is null; 
       
 cursor c6 (v_vendor varchar2 ) is
   select customer_id 
     from strang.customers c
     where Upper(CUSTOMER) LIKE Upper(v_vendor)||'%'
      and customer_type = 'SUPPLIER';     
       
  cursor c7 (v_vendor varchar2 ) is
   select customer_id 
     from strang.customers c
     where Upper(CUSTOMER) = Upper(v_vendor)
      and customer_type = 'CUSTOMER';            

 c1rec             c1%rowtype;
 c2rec             c2%rowtype;
 c3rec             c3%rowtype;
 c4rec             c4%rowtype;
 c6rec             c6%rowtype;
 c7rec             c7%rowtype;
 c5rec		       customer_account%ROWTYPE;
 c_node            CONSTANT VARCHAR2(100) := 'C:\Program Files\nodejs';
 jobno             NUMBER := 1020202;
 c_node_js         CONSTANT VARCHAR2(100) := 'node';
 f                 utl_file.file_type;
 v_cmd             VARCHAR2(32767);
 c_rdir            CONSTANT VARCHAR2(100) := 'c:\invoice_affinda';
 work_dir          VARCHAR2(1000);
 work_file         VARCHAR2(1000);
 --invoice_file    VARCHAR2(100) := NVL('1017593_INVOICE.pdf', vfile);
 invoice_file      VARCHAR2(100) := vfile;
 v_dir             VARCHAR2(1000);
 json_file         VARCHAR2(100);
 srcFile           BFILE ;
 fLen              NUMBER;
 dest              BLOB;
 obj               ORDSYS.JSON;
 x                 XMLTYPE;
 v_clb             CLOB;
 v_count           NUMBER(38) := 1;
 v_count_out       NUMBER(38) := 1;
 v_row             NUMBER(38) := 1;
 invhrec           strang.parsed_invoice_header%rowtype;
 invbrec           strang.parsed_invoice_items%rowtype;
 v_batch_no        NUMBER(8) := batchno;
 v_tamount         NUMBER(15,2);
 v_gst             number(15,2);
 v_reviewlink      varchar2(1000);
 v_datetime        varchar2(100);
 v_qty             number(15,2);
 v_payment_due     number(15,2);
 v_payment_base    number(15,2);
 v_basetotal       number(15,2);
 v_po_number       varchar2(100);
 v_inventory       varchar2(100);
 v_customer_id     integer;
 v_vendor_id       integer;
 v_other           number(15,2);
 v_identifier      varchar2(50);
 po_verified_date  varchar2(100); 
 inv_verified_date varchar2(100); 
 v_item_gst_code   varchar2(4);
 v_gst_rate        number(15,2);
 pfx		       THEME%ROWTYPE;
 ltype		       varchar2(100);
 stype		       integer;
 owner_id	       integer;
 sts		       varchar2(100);
 vaccess	       varchar2(20);
 seclevel	       varchar2(100);
-- mf		        varchar2(100);
 vste		       varchar2(10);
 v_step            varchar2(10);
 v_unit_price      number(30,6);
 v_unit            varchar2(10);
 v_coo             varchar2(100);
 
 BEGIN 
   c5rec := glbx.get_aid( owner_id, 'C', ltype );
   vste := customer_state(c5rec.aid);
   pfx := glbx.get_thm( c5rec.theme_name );
   seclevel := oltp.security_role( owner_id );

  -- select strang.s_invoices.nextval into batchno from dual;
  -- batchno := 10040;  -- remove later 
   if nvl(batchno,0) = 0 then
      select strang.s_invoices.nextval into batchno from dual;
--   else 
--      v_batch_no := batchno;
   end if;  
      
   v_datetime := to_char(sysdate,'YYYYMMDDHH24MISS');
   work_dir := nvl(glbx.extract_master_parameter('WORK_DIRECTORY'), 'c:\temp');
   work_file := 'batch_' || batchno ||'_'||v_datetime||'.bat';
   f := utl_file.fopen(work_dir, work_file, 'w', 32700);
   
   utl_file.put_line(f, '@echo off', TRUE);
   utl_file.put_line(f, 'set PATH=%PATH%;' || c_node, TRUE);
   utl_file.put_line(f, 'cd ' || c_rdir);
   if  p_identifier is null then
      utl_file.put_line(f, c_node_js||' api.js --filename "'||invoice_file||'" --jobno '||to_char(batchno)||'_'||v_datetime, TRUE);
   else
      utl_file.put_line(f, c_node_js||' api2.js --identity "'||p_identifier||'" --jobno '||to_char(batchno)||'_'||v_datetime, TRUE);
   end if;
   utl_file.put_line(f, 'exit', TRUE);
   utl_file.fclose(f);
   
   
   -- PLEASE UNDELETE THE FOLLOWING LINE
   begin utl_os.OsCmdDirectWait(work_dir || decs.UNIX_OR_NT || work_file); exception when others then null; end;
   if utl_os.delete_file(work_dir || decs.UNIX_OR_NT || work_file) then null;  end if;
   
 ---- SPLIT the following section into a new procedure;
 
  DBMS_LOB.CREATETEMPORARY(dest, TRUE);
  
  v_dir     :=  c_rdir || websys.decs.UNIX_OR_NT ||'output'||websys.decs.UNIX_OR_NT;
  json_file := to_char(batchno)||'_'||v_datetime||'.json';
  v_step := 'step 1';
  
  
  
  if websys.file_exists(v_dir, json_file) then
     srcFile := BFILENAME('JSON_DIR', json_file);
     DBMS_LOB.OPEN(srcFile, dbms_lob.file_readonly);
     fLen := dbms_lob.getlength(srcFile);
     DBMS_LOB.LoadFromFile(dest, srcFile, fLen); 
     dbms_lob.close(srcFile);
     commit;
  else 
     
     msg := 'No JSON file found! ';
   --  msg := 'process_invoices  error: ' || sqlerrm;
     raise_application_error(-20001,'No JSON file found');  
     return; 
  end if;
   conv_blob_clob (dest,v_clb);
 

  BEGIN
     v_step := 'step 2';
     obj := ORDSYS.json(v_clb);
     --obj.print;
     x := ORDSYS.json_xml.json_to_xml(obj);
    -- dbms_output.put_line(x.getclobval());
     -- if x.existsNode('//invoicePurchaseOrderNumber') = 1 then
     begin 
       --  v_po_number := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//invoicePurchaseOrderNumber/text()').getStringVal(),1),'"'),'"');  db new
           v_po_number := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//invoicePurchaseOrderNumber/parsed/text()').getStringVal(),1),'"'),'"');
           v_po_number := ltrim(rtrim(v_po_number,'.'),'.');
     exception when others then 
        invhrec.po_number := null;  
      --   dbms_output.put_line('PO: ');
     end;   
     
     v_step := 'step 3';
     
     if v_po_number is not null then
        if substr(v_po_number,1,2) in ( '80','47') then
           msg := 'PO number starts with 80 or 47, please process manually! ';
           return;
        end if;
     end if;
        -- end if;
     begin 
      --   dbms_output.put_line('Invoice: '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//invoiceNumber/text()').getStringVal(),1),'"'),'"'));
          invhrec.supinv := replace(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//invoiceNumber/parsed/text()').getStringVal(),1),'"'),'"'),'\u2212','-');
         -- invhrec.supinv := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//invoiceNumber/parsed/text()').getStringVal(),1),'"'),'"');
          glbx.dbg('invoice no '||invhrec.supinv);
          
       --  invhrec.supinv := rtrim(ltrim(x.extract('//invoiceNumber/text()').getStringVal(),'"'),'"');
      exception when others then 
          invhrec.supinv := null;
     end;
     
     v_step := 'step 4';
     
   --  glbx.dbg('v_batch_no '||v_batch_no);
    
     if v_batch_no is not null then
     
        if v_po_number is not null then
           UPDATE strang.parsed_invoice_header h
              set ( vendor_id
                    , vendor ) =
             (  select pp.vendor
                     , pp.vend_name
                 from strang.po_pool pp
                     ,strang.customers c
                where po_number= v_po_number
                  and pp.vendor = c.customer_id
                  and c.customer_type = 'SUPPLIER'
                  and rownum < 2)       
            where h.batch_id = batchno
              and ( ( h.vendor_id is null )
                  or (h.vendor_id is not null and 
                   h.proceed IS NULL)
                  or (h.vendor_id is not null and 
                   1 = (select count(distinct ii.invoice_filename)
                          from strang.parsed_invoice_items ii
                         where ii.delete_flg is null
                           and h.batch_id = ii.batch_id))   
                   );  
        end if;
     
     
        open c2 (v_po_number);
        fetch c2 into c2rec;
        close c2;
        if c2rec.vendor_id is not null then 
          
           open c3(batchno);
           fetch c3 into c3rec;
           close c3;
           
           if c2rec.vendor_id <> c3rec.vendor_id then
             msg := 'Invalid Supplier on PO: '||v_po_number;
            -- return;
           end if;
        else
             msg := 'PO Number: '||v_po_number||' may be wrongly parsed.';
            -- return;
        end if;
        
        v_step := 'step 4a';
        
        if p_identifier is not null then
    
          update strang.parsed_invoice_items
             set delete_flg = 'X'
           where batch_id = batchno
             and invoice_filename = vfile
             and identifier = p_identifier;
    
        end if;
        
        v_step := 'step 4b';
        
        open c4 (batchno, invhrec.supinv);
        fetch c4 into c4rec;
        if c4%found then
         --  close c4;
           msg := 'Duplicate Invoice';
          -- return;
        end if;
        close c4;
        
        
     end if;  
     
     v_step := 'step 5';
     
     begin 
      --   dbms_output.put_line('Supplier: '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//supplierCompanyName/text()').getStringVal(),1),'"'),'"'));
        invhrec.vendor := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//supplierCompanyName/parsed/text()').getStringVal(),1),'"'),'"');
     exception when others then 
         invhrec.vendor := null;
     end;  
        
     begin    
       -- dbms_output.put_line('Total Amount: '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//paymentAmountTotal/text()').getStringVal(),1),'"'),'"'));
         v_tamount := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//paymentAmountTotal/parsed/text()').getStringVal(),1),'"'),'"');
     exception when others then 
         v_tamount := null;
     end;  
     
     begin 
      --  dbms_output.put_line('Tax Amount: '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//paymentAmountTax/text()').getStringVal(),1),'"'),'"'));
        v_gst := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//paymentAmountTax/parsed/text()').getStringVal(),1),'"'),'"');
        
     exception when others then 
        v_gst := null;
     end;
     
     begin 
        v_payment_base := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//paymentAmountBase/parsed/text()').getStringVal(),1),'"'),'"');
     exception when others then 
        v_payment_base := null;
     end;
     
     begin 
       -- v_payment_due := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//paymentAmountDue/text()').getStringVal(),1),'"'),'"');
        v_payment_due := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//paymentAmountDue/parsed/text()').getStringVal(),1),'"'),'"');
     exception when others then 
        v_payment_due := null;
     end;
     
     begin 
       --  invhrec.customer := REGEXP_SUBSTR(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//customerCompanyName/parsed/text()').getStringVal(),1),'"'),'"'),'(OK TEDI)', 1, 1, 'i', 1);
          invhrec.customer := REGEXP_SUBSTR(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//customerCompanyName/parsed/text()').getStringVal(),1),'"'),'"'),'(*.*)', 1, 1, 'i', 1);
      --   dbms_output.put_line('Customer: '||REGEXP_SUBSTR(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//customerCompanyName/text()').getStringVal(),1),'"'),'"'),'(OK TEDI)', 1, 1, 'i', 1));
     exception when others then 
         invhrec.customer := null;
     end;
     
     begin 
          v_reviewlink := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//meta/reviewUrl/text()').getStringVal(),1),'"'),'"');  
      --   v_reviewlink := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//meta/reviewUrl/value/text()').getStringVal(),1),'"'),'"');  
      --   dbms_output.put_line('Customer: '||REGEXP_SUBSTR(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//customerCompanyName/text()').getStringVal(),1),'"'),'"'),'(OK TEDI)', 1, 1, 'i', 1));
     exception when others then 
         v_reviewlink := null;
     end;
     
     -- Added by David Banjo 21/5/2022
     begin 
        v_identifier := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//meta/identifier/text()').getStringVal(),1),'"'),'"');  
     exception when others then 
         v_identifier := null;
     end;
     
     begin 
        --po_verified_date := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//invoicePurchaseOrderNumber/clientVerifiedDt/text()').getStringVal(),1),'"'),'"');  
        po_verified_date := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//validatedDt/text()').getStringVal(),1),'"'),'"');
     exception when others then 
        po_verified_date := null;
     end;
     
     begin 
        --inv_verified_date := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//invoiceNumber/clientVerifiedDt/text()').getStringVal(),1),'"'),'"');  
        inv_verified_date := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//validatedDt/text()').getStringVal(),1),'"'),'"');
     exception when others then 
        inv_verified_date := null;
     end;
     
    if UPPER(invhrec.customer) like 'OK TEDI%' then
       v_customer_id := 1;
    elsif UPPER(invhrec.customer) like 'FUBILAN%' or UPPER(invhrec.customer) like 'STARMART%' then
       open c7(invhrec.customer);
       fetch c7 into c7rec;
       if c7%found then
          v_customer_id := c7rec.customer_id;    ---596;
          open c6(invhrec.vendor);
          fetch c6 into c6rec;
          close c6;
          if c6rec.customer_id is null then
             msg := 'Supplier id not found for '||invhrec.vendor;
          else 
             v_vendor_id := c6rec.customer_id;    
          end if;
          
       else
          v_customer_id := 1;
       end if;
       close c7;
    else 
       v_customer_id := 1;
    end if;
    
     
    v_step := 'step 6';
    
    if v_po_number is not null then
       open c2(v_po_number);
       fetch c2 into c2rec;
       if c2%found then 
          v_vendor_id := c2rec.vendor_id;
       end if;
       close c2;
    end if;
    
    v_step := 'step 7';
    
    if  p_identifier is not null then
      if NVL(v_gst,0) =  0 then
         v_item_gst_code := 'NS';
         v_gst_rate := 0.0;
      else 
         v_item_gst_code := 'NET';
         v_gst_rate := 0.1;
      end if;
    end if;
    
    v_step := 'step 8';
    --select strang.s_invoices.nextval into batchno from dual;
    if nvl(v_batch_no, 0) = 0 then
       insert into strang.parsed_invoice_header 
       --(batch_id, po_number, customer, currency_iso, vendor, supinv, tamount, gst, date_created, invoice_filename)
       (batch_id, customer, currency_iso, vendor, date_created, vendor_id, customer_id, gstcode, username)
       values
       (batchno, nvl(invhrec.customer,'OK TEDI'), invhrec.currency_iso, nvl(c2rec.vendor_name, invhrec.vendor), sysdate,v_vendor_id, NVL(v_customer_id,1)
      , case when v_gst is not null and v_gst <> 0 then 'NET' else 'NS' end, c5rec.username );
    else 
     
       update strang.parsed_invoice_header
       set customer = nvl(invhrec.customer,'OK TEDI')
           , currency_iso = invhrec.currency_iso
           , vendor = nvl(c2rec.vendor_name, invhrec.vendor)
           , vendor_id = v_vendor_id
           ,  customer_id = NVL(v_customer_id,1)
       where batch_id = batchno;
    end if;
    c2rec := null;
    --v_vendor_id := null;
   -- v_customer_id  := null;
    
    v_step := 'step 9';
    
    if x.existsNode('//tables[' || v_count_out || ']'||'/rows[' || v_count || ']') = 0 then
        v_count_out := v_count_out +1;
        insert into strang.parsed_invoice_items
        ( batch_id, po_number, supinv,  short_text, qty
        , item_gst, discount, calc_amount, Item_amount, orig_item_amount,  Item_tamount, base_unit_price, unit_price
        , invoice_filename, recno, tamount, gst, reviewlink, inventoryno, payment_due, code, other, identifier )
         values
        (batchno, v_po_number, invhrec.supinv, invbrec.short_text, null
        ,null, null, null, null
        ,null, null
        ,null
        ,null
        , invoice_file, 1, nvl(nvl(v_tamount,v_payment_due), nvl(v_payment_base,0) + nvl(v_gst,0)), v_gst, v_reviewlink, null , v_payment_due, null, null,v_identifier);
      v_step := 'step 9a';
        v_row := v_row + 1;
    
    end if;
  
    
    -- v_step := 'step 9b';
   -- glbx.dbg('step 1a ');
    WHILE x.existsNode('//tables[' || v_count_out || ']'||'/rows[' || v_count || ']') = 1 LOOP
       glbx.dbg('v_count_out = '||v_count_out);          
       v_count := 1;

       WHILE x.existsNode('//tables[' || v_count_out || ']'||'/rows[' || v_count || ']') = 1 LOOP 
           glbx.dbg('v_count_out = '||v_count_out);   
           glbx.dbg('v_count = '||v_count);
           begin 
              
              invbrec.short_text := TRANSLATE(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/description/text()').getStringVal(),1), '1\"', '1 ');
            --  dbms_output.put_line('Description: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count || ']/rows/description/text()').getStringVal(),1),'"'),'"'));
               glbx.dbg('short_text '||invbrec.short_text);
           exception when others then 
              --dbms_output.put_line('Description: '||to_char(v_count)||' BIG ERROR');
              invbrec.short_text := null;
           end;   
           
          -- glbx.dbg('step 2 ');   
           begin 
             v_step := 'step 10';
              invbrec.qty := to_number(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/quantity/text()').getStringVal(),1),'"'),'"'));
              v_qty :=       to_number(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/quantity/text()').getStringVal(),1),'"'),'"'));
            --  dbms_output.put_line('Quantity: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count || ']/rows/quantity/text()').getStringVal(),1),'"'),'"'));
           exception when others then 
              invbrec.qty := null;
           end;
           
         --  glbx.dbg('step 3 ');  
           begin 
               invbrec.item_gst := to_number(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/taxTotal/text()').getStringVal(),1),'"'),'"'));
             -- dbms_output.put_line('Item Tax: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/taxTotal/text()').getStringVal(),1),'"'),'"'));
           exception when others then 
               invbrec.item_gst := null;
              --dbms_output.put_line('Item Tax: ');
           end;
           
       --   glbx.dbg('step 4 ');  
           begin 
                v_step := 'step 11';
               invbrec.discount := to_number( REGEXP_REPLACE(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/discount/text()').getStringVal(),1),'"'),'"'),'[^0-9.]+', '') );
             -- dbms_output.put_line('Item Tax: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/taxTotal/text()').getStringVal(),1),'"'),'"'));
               if nvl(invbrec.discount,100) = 100 then
                  invbrec.discount := null;
               end if;
           exception when others then 
               invbrec.discount := null;
              --dbms_output.put_line('Item Tax: ');
           end;

         --  glbx.dbg('step 5 ');  
           begin 
              v_step := 'step 12';
               invbrec.item_amount := round(to_number(substr(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/total/text()').getStringVal(),1),'"'),'"'),1,12)),2);
           exception when others then 
               invbrec.item_amount := null;
           end;
           
          -- glbx.dbg('step 6 ');  
           begin
               v_step := 'step 13';
               v_basetotal := to_number(substr(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/baseTotal/text()').getStringVal(),1),'"'),'"'),1,12));
     
              --dbms_output.put_line('Item Amount: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/total/text()').getStringVal(),1),'"'),'"'));
           exception when others then 
               v_basetotal := null;
           end;
           
        --   glbx.dbg('step 7 ');  
           if invbrec.item_amount is null and v_basetotal is not null then
              invbrec.item_amount := v_basetotal;
           end if;
           
          glbx.dbg('Item Amount '||invbrec.item_amount);
    
--           begin 
--              dbms_output.put_line('Item Unit: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/unit/text()').getStringVal(),1),'"'),'"'));
--           exception when others then 
--              dbms_output.put_line('Item Unit: ');
--            end;       
           begin 
--           select *
--           from websys.debug
--           order by ctr;
              v_step := 'step 13';
              glbx.dbg('Item Amount '||substr(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/unitPrice/text()').getStringVal(),1),'"'),'"'),1,10));
               invbrec.unit_price := round(to_number(substr(rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/unitPrice/text()').getStringVal(),1),'"'),'"'),1,10)),2);
               invbrec.unit_price := round(invbrec.unit_price,2);  -- Change back later DB 12/4/2022
             -- dbms_output.put_line('Unit Price: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/unitPrice/text()').getStringVal(),1),'"'),'"'));
           exception when others then 
              --dbms_output.put_line('Unit Price: ');
               invbrec.unit_price := null;
           end;   
           
           begin 
                v_step := 'step 14';
               invbrec.code := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/code/text()').getStringVal(),1),'"'),'"');
             -- dbms_output.put_line('Unit Price: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/unitPrice/text()').getStringVal(),1),'"'),'"'));
           exception when others then 
              --dbms_output.put_line('Unit Price: ');
               invbrec.code := null;
           end;  
           
           begin 
               v_step := 'step 15';
               invbrec.other := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/other/text()').getStringVal(),1),'"'),'"');
             -- dbms_output.put_line('Unit Price: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/unitPrice/text()').getStringVal(),1),'"'),'"'));
           exception when others then 
              --dbms_output.put_line('Unit Price: ');
               invbrec.other := null;
           end;  
           
           begin 
               v_step := 'step 16';
               v_unit := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/unit/text()').getStringVal(),1),'"'),'"');
             -- dbms_output.put_line('Unit Price: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/unitPrice/text()').getStringVal(),1),'"'),'"'));
           exception when others then 
              --dbms_output.put_line('Unit Price: ');
               v_unit := null;
           end;  
           
           begin 
               v_coo := rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables[' || v_count_out || ']/rows[' || v_count || ']/customFields/countryOfOrigin/text()').getStringVal(),1),'"'),'"');
             -- dbms_output.put_line('Unit Price: '||to_char(v_count)||'. '||rtrim(ltrim(dbms_xmlgen.convert(x.extract('//tables/rows[' || v_count || ']/unitPrice/text()').getStringVal(),1),'"'),'"'));
               v_coo := f_getcountrycode(v_coo);
           exception when others then 
              --dbms_output.put_line('Unit Price: ');
               v_coo := null;
           end;  
           
           
        glbx.dbg('count '||v_count);
        glbx.dbg('Quantity '||invbrec.qty);
        if invbrec.other is not null then
            begin
            v_step := 'step 16';
               v_other := to_number(invbrec.other);
               if ( round(nvl(v_other,0) * nvl(v_qty,0),0)  = round(v_basetotal,0)  and round(nvl(invbrec.unit_price,0) * nvl(v_qty,0),0)  <> round(v_basetotal,0) ) and v_other > 0 and v_basetotal >0  then
                  invbrec.unit_price := v_other;
               end if;
            exception when others then 
               null;
            end;
            v_other := null;
        end if;
        
        if v_vendor_id in (4001579, 4002377, 4002353, 4000023, 4001447, 4002398, 9000558, 4002587, 4002172
                         , 4002545, 9001199, 4001974, 4004043, 4002512, 4002736, 4002024, 4002428
                         , 4002397, 4003442, 4002092, 4006205, 4002130, 4001826, 4001568
                         , 4001865, 4001449, 4001253, 4002198, 4002433, 4001903, 4002169, 4001779, 4003497, 9002663, 4002267
                         , 9001883, 4002178, 4002802, 9001920 -- LIEBHERR
                         , 4001986, 4001267, 4001446, 4003511, 4002650, 4001284
                         , 4001344, 9000449  -- Procureit
                         , 4002995, 4003727, 4003046
                         , 4002536 -- trailer sales hand written  
                         , 4002952, 4001903   
                         , 4002166 -- COSOL   
                         , 4002141 -- SANDVIK
                         , 4002311
                         , 4001230 -- ESTRY 
                         , 4001340
                         , 4001635 -- Dynamics     
                         , 4002550 -- Voith
                         , 4001973, 4002633, 4001578 -- Flsmidth
                         , 4002090 -- Clark Equipment   
                         , 4001630  -- Adaptalift
                         , 4002432 -- Custom Fluids   
                         , 4002099 -- Southeast Fasteners 
                         , 4003410 -- Global Welding  
                         , 4002421 -- HELLA AUSTRALIA
                         , 4002488 -- Volgren
                         , 4003494 -- Australian Wholesale 
                         , 4001997 -- Alcolizer
                         , 4002256 -- Caps Australia
                         , 4003838 -- Southern Queensland Steel
                         , 4001771 -- Protector Alsafe
                         , 4001913 -- Fenner Conveyors
                         , 4002403 -- Combustion & Chemical
                         , 4002981 -- Moly-COP
                         , 4001408 -- CHUBB FIRE AND SAFETY
                         , 4006115 -- MTIS GROUP
                         , 4001370 -- S M C PNEUMATICS
                         , 4001838 -- POWERLINK QUEENSLAND
                         , 4002151 -- R F INDUSTRIES PTY LTD
                         , 4003645 -- HIGHMARK SOLUTIONS
                         , 4002069 -- GARDNER DENVER
                         , 4001468 -- JAMES WALKER
                         , 4002101 -- C and L tool Centre
                         , 4002511 -- Cummins South Pacific
                         , 4001419 -- Valve Torque
                         , 4003079 -- Prok Conveyor Components
                         , 4004008 -- Danfoss Power
                         , 4001925 -- 2MT MINING PRODUCTS
                         , 4001754 -- Power Step 
                         , 9002757 -- ARPANSA
                         , 4001621 -- CORTELA CARBON
                         , 4003565 -- PURE OIL MAINTENANCE
                         , 4003373 -- HARTAC SALES 
                         , 4002345 -- RCS Telecommunications 
                         , 4003551 -- ROC instrumentation
                         , 4002038 -- Holmwood Highgate
                         , 4001394 -- LECO Australia
                         , 4002150 -- MEDICAL AND SURGICAL REQUISITES
                         , 4001512 -- TEREX LIFTING 
                         , 4001734 -- LIVINGSTONE INTL
                         , 4002208 -- SSS AUSTRALIA
                         , 4003373 -- HARTAC SALES
                         , 4003085 -- AUXANO GROUP PTY LTD
                         , 4004202 -- HYDRAULINK AUSTRALIA PTY LTD
                         , 4003515 -- FLENDER PTY LTD
                         , 4001925 -- 2MT MINING PRODUCTS PTY LTD
                         )  then  -- last B2B

           begin 
           
           
              if v_vendor_id in (4002736, 4002024) then
                 websys.p_getcountry_code (v_vendor_id, nvl(v_unit,''),  invbrec.country_code, invbrec.state);
              elsif v_vendor_id in (4004043, 4003442, 4006205, 4002166, 4001230) then
                 websys.p_getcountry_code (v_vendor_id, nvl(invbrec.other,''),  invbrec.country_code, invbrec.state);
              elsif  v_vendor_id in (4001512) then
                 websys.p_getcountry_code (v_vendor_id, nvl(v_coo,''), invbrec.country_code, invbrec.state);  -- USE Country of origin 
              elsif  v_vendor_id in (4000023) then
                 websys.p_getcountry_code (v_vendor_id, nvl(v_coo,''), invbrec.country_code, invbrec.state);  -- USE Country of origin     
              else
                 websys.p_getcountry_code (v_vendor_id, nvl(invbrec.short_text,'')||' '||nvl(invbrec.other,''),  invbrec.country_code, invbrec.state);
              end if; 
           exception when others then 
              null;
           end;
      
        else    
           invbrec.country_code := 'AU';
        end if;
        
        
--        if v_vendor_id in (4001579, 4002377, 4000023, 4001447,4002398, 4002398, 4002172, 4002545, 4300005491,4001974)  then
--           begin 
--              websys.p_getcountry_code (v_vendor_id, nvl(invbrec.short_text,'')||' '||nvl(invbrec.other,''),  invbrec.country_code, invbrec.state);
--           exception when others then 
--              null;
--           end;
--      
--        else    
--           invbrec.country_code := 'AU';
--        end if;
--        select *
--        from websys.debug
--        order by ctr
         v_step := 'step 17';
         glbx.dbg('Code stuff '||invbrec.code);
         if invbrec.code is not null and length(substr(invbrec.code, instr(invbrec.code,'100',1),8)) = 8 and instr(invbrec.code,'100',1) <>0  then
           v_inventory := REGEXP_SUBSTR(invbrec.code,'(\s*|^)(100[[:digit:]]{5})',1,1,'i',2);
         elsif  invbrec.other is not null and length(substr(invbrec.other, instr(invbrec.other,'100',1),8)) = 8 and instr(invbrec.other,'100',1) <>0  then
           v_inventory := REGEXP_SUBSTR(invbrec.other,'(\s*|^)(100[[:digit:]]{5})',1,1,'i',2);
          elsif  invbrec.short_text is not null and length(substr(invbrec.short_text, instr(invbrec.short_text,'100',1),8)) = 8 and instr(invbrec.short_text,'100',1) <>0  then
           v_inventory := REGEXP_SUBSTR(invbrec.short_text,'(\s*|^)(100[[:digit:]]{5})',1,1,'i',2);  
         end if; 

         if round(nvl(v_qty,0) * nvl(invbrec.unit_price,0) * (1 - (invbrec.discount/100)),2)  <> round(invbrec.item_amount,2) and (invbrec.code is not null or invbrec.other is not null) then
            
                
            open c1 (v_po_number, v_inventory);
            fetch c1 into c1rec;
            if c1%found then
              invbrec.unit_price := c1rec.net_price;
            end if;
            close c1;
                
         
         end if;
        v_step := 'step 18';
        

        insert into strang.parsed_invoice_items
        ( batch_id, po_number, supinv,  short_text, qty
        , item_gst, discount, calc_amount, Item_amount, orig_item_amount,  Item_tamount, base_unit_price, unit_price
        , invoice_filename, recno, tamount, gst, reviewlink, inventoryno, payment_due, code, other 
        , identifier, po_verified_date, inv_verified_date, item_gst_code, gst_rate, country_code, state, unit)
         values
        (batchno, v_po_number, invhrec.supinv, invbrec.short_text
        , case when abs(v_qty) > 1000000 then 0 else v_qty end 
        ,invbrec.Item_gst, invbrec.discount
        ,case when abs(round(nvl(v_qty,0)*nvl(invbrec.unit_price,0)*(1.00 - (nvl(invbrec.discount,0)/100)),2)) > 100000000 then 0 else round(nvl(v_qty,0)*nvl(invbrec.unit_price,0)*(1.00 - (nvl(invbrec.discount,0)/100)),2) end
        ,case when abs(round(nvl(v_qty,0)*nvl(invbrec.unit_price,0)*(1.00 - (nvl(invbrec.discount,0)/100)),2)) > 100000000 then 0 else round(nvl(v_qty,0)*nvl(invbrec.unit_price,0)*(1.00 - (nvl(invbrec.discount,0)/100)),2) end
        ,invbrec.item_amount, nvl(invbrec.item_amount,0) + nvl(invbrec.Item_gst,0)
        ,invbrec.unit_price
        ,invbrec.unit_price * (1.00 - (nvl(invbrec.discount,0)/100))
        ,invoice_file, v_row, nvl(nvl(v_tamount,v_payment_due), nvl(v_payment_base,0) + nvl(v_gst,0)), v_gst, v_reviewlink, v_inventory , v_payment_due, invbrec.code, invbrec.other
        ,v_identifier, po_verified_date, inv_verified_date, v_item_gst_code, v_gst_rate, nvl(invbrec.country_code,v_coo), invbrec.state, v_unit);
         v_count := v_count + 1;
         v_row   := v_row + 1;
        invbrec := null;
        v_qty := null;
        v_inventory := null;
        v_basetotal := null;
        v_unit := null;
        v_coo := null;

        END LOOP;
        v_count_out := v_count_out + 1;
        v_count := 1;
        glbx.dbg('v_count_out '||v_count_out);
     END LOOP;
  END;
  
  if v_customer_id <> 1 then
  
    delete from strang.po_pool where vendor = v_vendor_id  and po_number =  v_po_number;
    insert into strang.po_pool
    (date_created, po_number, po_item, quantity, openqty, short_text, net_price, shipping_text, vendor, vend_name, trackingno)
    select sysdate, v_po_number , rownum *10, qty, qty, short_text, unit_price,'Pack for Sea Freight', v_vendor_id, invhrec.vendor, 'MANUAL_'||to_char(batchno) 
     from strang.parsed_invoice_items
     where batch_id = batchno;
     
  end if;
  
  COMMIT;
  
  DBMS_LOB.FREETEMPORARY(dest);
   
EXCEPTION WHEN OTHERS THEN
   begin utl_file.fclose_all; exception when others then
     msg := 'process_invoices  error: ' || sqlerrm;
     rollback;
     return;
    end;
   dbms_output.put_line('process_invoices  error: ' || sqlerrm);
   glbx.dbg('process_invoices  error: ' || sqlerrm);
   msg := case when msg is not null then msg||' ' else '' end||'process_invoices  error: ' || sqlerrm||'! '||v_step||' ';
   return;
END parse_invoice;

 procedure po_pool_list2( po_number in varchar2, po_item in varchar2 default null, batchno number default null, parm in varchar2 default null,  p_unit_price number 
                        , ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE )
 as
 
  cursor c2( po_no varchar2, batchno number) is select po_item
                                                     , po_item||'~'||case when UPPER(substr(shipping_text,1,15)) like '%AIR%' then 'AIR'
                                                                          when UPPER(substr(shipping_text,1,15)) like '%SEA%' then 'SEA'
                                                                          when UPPER(substr(shipping_text,1,15)) like '%ROAD%' then 'ROAD' end||'~'||
                                                       material||'~'||short_text||'~'||Openqty||'~'||Net_price det, round(net_price,2) net_price    
                                                  from strang.po_pool pp
                                                 where pp.po_number = po_no
                                                   and ((to_number(nvl(openqty,'0')) > 0  
                                                   and not exists (select 1
                                                                     from strang.parsed_invoice_items ii
                                                                    where pp.po_number = ii.po_number                                   
                                                                      and pp.po_item = ii.po_item 
                                                                      and ii.batch_id = batchno ))
                                                    or ( not (to_number(nvl(openqty,'0')) <=  nvl((select sum(nvl(iii.qty,0))
                                                                                        from strang.parsed_invoice_items iii
                                                                                       where pp.po_number = iii.po_number
                                                                                         and iii.delete_flg is null                                 
                                                                                         and pp.po_item = iii.po_item 
                                                                                         and iii.batch_id = batchno ),0))
                                                       and exists (select 1
                                                                     from strang.parsed_invoice_items iv
                                                                    where pp.po_number = iv.po_number                                   
                                                                      and pp.po_item = iv.po_item 
                                                                      and iv.batch_id = batchno )))                                                
                                                  order by TO_NUMBER(GLBX.GUESS_NUMBER(pp.po_item));

  c2rec	c2%ROWTYPE;
  v_background  varchar2(30);
  
 begin
    
    htp.formselectopen( parm );
    if not ismand then htp.formselectoption( NULL ); end if;
    for c2rec in c2( po_number, batchno ) loop
     if (po_item is not null) and (po_item = c2rec.po_item)
      then
       htp.p('<option class="full" selected="selected" VALUE="'||c2rec.po_item||'" style="background-color: LightGreen">'||c2rec.det||'</option>') ;
     elsif p_unit_price = c2rec.net_price then 
       htp.p('<option  class="multiple" VALUE="'||c2rec.po_item||'" style="background-color: LightGreen"><span class="multiple">'||c2rec.det||'</span></option>' );
     else
       htp.p('<option class="empty" VALUE="'||c2rec.po_item||'">'||c2rec.det||'</option>' );
     end if;
    end loop;
    htp.formselectclose;
    
 exception
  when others then htp.p( sqlerrm );
 end po_pool_list2;
 
END INVOICE_PARSER;
/
