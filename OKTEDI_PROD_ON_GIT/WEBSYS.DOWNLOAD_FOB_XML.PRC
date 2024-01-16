CREATE OR REPLACE procedure WEBSYS.download_fob_xml(surl in varchar2, action in varchar2, p_movement_no varchar2, p_seal varchar2, msg out varchar2) 
as
-- TYPE            column_desc is record(v_col varchar2(1000), v_alias varchar2(1000));
-- TYPE            column_array is table of column_desc index by binary_integer;
ltype            varchar2(100);
stype            integer;
owner_id         integer;
sts              varchar2(100);
--v_parms_1        column_array;
--v_query_1        varchar2(30000);
--useref         varchar2(200) := 'STILL OUTSTANDING';
v_agent          varchar2(200) := 'Y';
v_prescribed     varchar2(200) := 'N';
v_excisable      varchar2(200) := 'N';
v_confirm_status varchar2(200) := 'N';
v_exisewhse      varchar2(200) := '';
v_exponame       varchar2(200) := '26004243887 STRANG INTERNATIONAL PTY. LIMITED';
v_consname       varchar2(200) := '46010780677 OK TEDI MINING LIMITED';
v_destctryna     varchar2(200) := 'PAPUA NEW GUINEA';
v_destctrycd     varchar2(200) := 'PG';
v_loadname       varchar2(200) := 'BRISBANE';
v_loadcode       varchar2(200) := 'BNEAU';
v_dischname      varchar2(200) := 'MOTUKEA';
v_dischcode      varchar2(200) := 'MTKPG';
v_vesselname     varchar2(200) := '';
v_vesselid       varchar2(200) := '';
v_voyage         varchar2(200) := '';
v_exportdate     varchar2(200) := '';
v_cargocode      varchar2(200) := 'CONTAINERISED';
v_goodscode      varchar2(200) := 'OTHER';
v_invcurrcd      varchar2(200) := 'AUD';
v_fobcurrcd      varchar2(200) := 'AUD';
v_invoiced       varchar2(200) := '';
v_status_with_ICS varchar2(200) := 'NEW';



uniqueConsRef varchar2(500) := p_movement_no||case when p_seal is not null then '/'||p_seal else '' end;
--v_parms_2     column_array;
--v_query_2     varchar2(30000);
--v_union_2     varchar2(100);
date_mask     CONSTANT varchar2(100) := ', ''dd-MON-yyyy''';
xml_clob      CLOB;
xml_blob      BLOB;
vblob         BLOB;
--csv_blob      BLOB;
f_name        varchar2(1000) := 'fob_extract.csv';
NL_CHAR 	constant char(1) := chr(10);

--------------------- start cursor here -----------------------------------------------------
 cursor c1( vmov varchar2, vseal varchar2) is
  select distinct replace(t.ahecc, '.') ahecc
                , t.unit
                , t.description
                , substr(t.country,1,2) country
                , case when tariff_group is null then strang.f_getlovColumn('UNCTYTAB','DESCRIPTION', t.country)  else  strang.f_getlovColumn('UNCTYTAB','DESCRIPTION', substr(t.country,1,2)) end countryname
                , nvl(t.origin, 'FOR') origin
                , case when (t.quantity is null or (trim(t.unit) = 'NR' and t.quantity is not null) )then '' else to_char(t.quantity) end qty
                , t.invoice_value  
                , f_calc_line_fob_value (vmov, vseal, t.invoice_value , t.goods_weight_kg) fob_value
                , case when round(t.goods_weight_kg,0) =  0 then 1 else round(t.goods_weight_kg,0) end goods_weight_kg
                , t.tariff_category
                , t.tariff_group
                , row_number() over (order by to_char(t.tariff_category) nulls last, to_char(t.tariff_group), to_char(t.ahecc)) rnk
   from (select tmp.ahecc, tmp.unit_unitused unit, tmp.description 
              , tmp.origin origin 
              , tmp.TARIFF_CATEGORY
              , tmp.tariff_group 
              , case when tmp.tariff_category is not null 
                       then f_fob_country_list (vmov, vseal, tmp.tariff_category, tmp.tariff_group)
                        else ctry_countrycode end country 
              , case when tmp.unit_unitused = 'NR' then null else sum(tmp.p_qty) end quantity 
              , sum(amount) invoice_value, sum(partweight) goods_weight_kg 
          from ( select /*+ ALL_ROWS */ distinct r.deliveryno, p.recno, p.po, p.po_item_no 
                     , p.supinv, p.qty p_qty 
	                 , f_calc_poitem_weight (dr.movement_no, dr.deliveryno, dr.itemno, p.recno) partweight 
	                 , case when p.tariff_category is not null then 'NR' else rtrim(t.COLA,'-') end unit_unitused 
	                 , p.inventoryno invent
	                 , case when p.tariff_category is not null then 'MINING SUPPLIES' else i.description end description 
	                 , i.coli||' '||t.description||'%' tariff 
                     , p.ahecc 
	                 , p.tariff_category
	                 , p.state origin 
	                 , p.tariff_group 
	                 , case when p.tariff_category is not null then NULL else p.ctry_countrycode end ctry_countrycode
	                 , p.state 
                     , nvl(p.amount,0) amount, nvl(p.gst,0) gst
	                 , (nvl(p.tamount,0)+nvl(p.delivery_charge,0)) tam_dc, r.curr, c.customer
                  from strang.pos p,strang.receivals r, strang.customers c, strang.lov i, strang.lov t, 
                       strang.customers c1, strang.detailrs dr, strang.movements m, strang.ships_airway s
                 where dr.movement_no = m.movement_no 
                   and nvl(dr.camov_seal,'|') = nvl(m.seal,'|') 
                   and m.ship_id = s.ship_id 
                   and dr.deliveryno = p.deliveryno 
                   and nvl(r.supplier_customer_id,0) = c.customer_id 
                   and i.lov_name = 'INVENT'
                   and t.lov_name = 'AU_TARIFF' 
                   and c.customer_type = 'SUPPLIER' 
                   and nvl(r.cust_customer_id,0) = c1.customer_id
                   and p.deliveryno = r.deliveryno 
                   and nvl(p.inventoryno,'NOT ALLOCATED') = i.code 
                   and nvl(i.coli,'NOT ALLOCATED') = t.code 
                   and m.movement_no = vmov 
                   and nvl(m.seal,'|') = nvl(vseal,'|')
                 union 
                 select /*+ ALL_ROWS */ distinct r.deliveryno, p.recno, p.po, p.po_item_no 
                     , p.supinv, p.qty p_qty 
                     , f_calc_poitem_weight (dr.movement_no, dr.deliveryno, dr.itemno, p.recno) partweight
                     , null
                     , p.inventoryno invent, 'NOT ALLOCATED' description, 'NOT ALLOCATED' tariff 
                	 , p.ahecc 
                     , p.tariff_category
                     , p.state origin 
                     , p.tariff_group 
                     , case when p.tariff_category is not null then NULL else p.ctry_countrycode end ctry_countrycode 
                     , p.state 
                     , nvl(p.amount,0) amount, nvl(p.gst,0) gst 
                     , (nvl(p.tamount,0)+nvl(p.delivery_charge,0)) tam_dc, r.curr, c.customer 
                  from strang.pos p,strang.receivals r, strang.customers c,
                       strang.customers c1, strang.detailrs dr, strang.movements m, strang.ships_airway s
                 where dr.movement_no = m.movement_no 
                   and nvl(dr.camov_seal,'|') = nvl(m.seal,'|') 
                   and m.ship_id = s.ship_id 
                   and dr.deliveryno = p.deliveryno 
                   and nvl(r.supplier_customer_id,0) = c.customer_id 
                   and c.customer_type = 'SUPPLIER' 
                   and nvl(r.cust_customer_id,0) = c1.customer_id 
                   and p.deliveryno = r.deliveryno 
                   and p.inventoryno is not null 
                   and nvl(p.inventoryno,'xxxx') not in (select code from strang.lov where lov_name = 'INVENT') 
                   and m.movement_no = vmov 
                   and nvl(m.seal,'|') = nvl(vseal, '|')
                union 
                select /*+ ALL_ROWS */ distinct r.deliveryno, p.recno, p.po, p.po_item_no 
                      , p.supinv, p.qty p_qty 
                      , f_calc_poitem_weight (dr.movement_no, dr.deliveryno, dr.itemno, p.recno) partweight
                      , case when p.tariff_category is not null then 'NR' else null end unit_unitused
                      , p.inventoryno invent 
                      , case when p.tariff_category is not null then 'MINING SUPPLIES' else i.description end description
                      , 'NOT ALLOCATED' tariff 
                      , p.ahecc
                      , p.tariff_category
                      , p.state origin
                      , p.tariff_group
                      , case when p.tariff_category is not null then NULL else p.ctry_countrycode end ctry_countrycode
                      , p.state
                      , nvl(p.amount,0) amount, nvl(p.gst,0) gst,  (nvl(p.tamount,0)+nvl(p.delivery_charge,0)) tam_dc, r.curr, c.customer
                  from strang.pos p,strang.receivals r, strang.customers c,
                       strang.customers c1, strang.detailrs dr, strang.movements m, strang.lov i, strang.ships_airway s
                 where dr.movement_no = m.movement_no 
                   and nvl(dr.camov_seal,'|') = nvl(m.seal,'|') 
                   and m.ship_id = s.ship_id 
                   and dr.deliveryno = p.deliveryno 
                   and nvl(r.supplier_customer_id,0) = c.customer_id 
                   and c.customer_type = 'SUPPLIER' 
                   and nvl(r.cust_customer_id,0) = c1.customer_id 
                   and p.deliveryno = r.deliveryno 
                   and i.lov_name = 'INVENT'
                   and p.inventoryno = i.code 
                   and nvl(i.coli,'xxxxx') not in (select code from strang.lov where lov_name='AU_TARIFF')
                   and m.movement_no = vmov
                   and nvl(m.seal,'|') = nvl(vseal, '|')
                ) tmp             
            group by tmp.ahecc, tmp.unit_unitused, tmp.description 
                , tmp.tariff_category, tmp.origin , tmp.tariff_group, tmp.ctry_countrycode
    ) t 
    order by to_char(t.tariff_category) nulls last, to_char(t.tariff_group), replace(t.ahecc, '.');

 cursor c2( vmov varchar2, vseal varchar2) is
   select deliveryno 
    from strang.detailrs dr
   where dr.movement_no = vmov
     and nvl(dr.camov_seal,'|') = nvl(vseal,'|')
     and not exists
          (select 'x'
             from strang.detailrs dr1
            where dr1.movement_no <> vmov
              and dr1.deliveryno = dr.deliveryno);
 
 cursor c3( vmov varchar2, vseal varchar2) is             
 select case when tmp.movement_type in ('CARGO') then '' else to_char(tmp.qty) end pkg_cnt
      , case when tmp.movement_type in ('CARGO') then '1' else '' end container_cnt
      , case when tmp.movement_type in ('CARGO') then 'C' 
             when tmp.movement_type in ('CONMOV') then 'B'
             when tmp.movement_type in ('AIRWAY') then 'N'
             else 'CO' end cargocode 
      , ss.ship_id, ss.shipname, ss.VOY
      , to_char(CASE WHEN tmp.ship_id < 7 then  trunc(SYSDATE)-1
                     ELSE ss.estdepart END,'dd/mm/yyyy') estdepart
   from ( select m.ship_id, m.movement_type, sum(dr.qty) qty
            from strang.detailrs dr, strang.movements m
           where m.movement_no = vmov
             and nvl(m.seal,'|') = nvl(vseal,'|')
             and dr.movement_no = m.movement_no
             and nvl(dr.camov_seal,'|') = nvl(m.seal,'|') 
           group by m.ship_id, m.movement_type) tmp,
           strang.ships_airway ss
   where tmp.ship_id = ss.ship_id;

     
 c1rec	     C1%ROWTYPE;
 c2rec	     C2%ROWTYPE;
 c3rec	     C3%ROWTYPE;


begin

 -- glbx.dbg('I am in the debug function');
  glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'DOWNLOAD_FOB_XML' );
  if sts is not null
   then
   glbx.redisplay_login_page( sts, TRUE );
   return;
  end if;
  
  open c2(p_movement_no, p_seal);
  fetch c2 into c2rec;
  close c2;
  
  open c3(p_movement_no, p_seal);
  fetch c3 into c3rec;
  close c3;

  xml_clob := EMPTY_CLOB();
  dbms_lob.createtemporary(xml_clob,true);
  dbms_lob.createtemporary(xml_blob,TRUE);
  case upper(trim(action))
  when 'DOWNLOAD FOB XML EXTRACT'
   then
     f_name := 'EDN'||to_char(sysdate,'YYYYMMDDHH24MISS')||'.xml';
     
     xml_clob := '<?xml version="1.0"?>';
     xml_clob := xml_clob||'<EDN.Data.Transfer>';
     xml_clob := xml_clob||'<EDN.Header>';
     xml_clob := xml_clob||'<USERREF>'||c2rec.deliveryno||'</USERREF>';
     xml_clob := xml_clob||'<VERSION>'||''||'</VERSION>';
     xml_clob := xml_clob||'<CONFSTATUS>'||v_confirm_status||'</CONFSTATUS>';
     xml_clob := xml_clob||'<AGENT>'||v_agent||'</AGENT>';
     xml_clob := xml_clob||'<EDNNUMB>'||''||'</EDNNUMB>';
     xml_clob := xml_clob||'<PRESCRIBED>'||v_prescribed||'</PRESCRIBED>';
     xml_clob := xml_clob||'<EXCISABLE>'||v_excisable||'</EXCISABLE>';
     xml_clob := xml_clob||'<EXISEWHSE>'||v_exisewhse||'</EXISEWHSE>';
     xml_clob := xml_clob||'<EXPONAME>'||v_exponame||'</EXPONAME>';
     xml_clob := xml_clob||'<CONSNAME>'||v_consname||'</CONSNAME>';
     xml_clob := xml_clob||'<CONSKEY>'||''||'</CONSKEY>';
     xml_clob := xml_clob||'<DESTCTRYNA>'||v_destctryna||'</DESTCTRYNA>';
     xml_clob := xml_clob||'<DESTCTRYCD>'||v_destctrycd||'</DESTCTRYCD>';
     xml_clob := xml_clob||'<LOADNAME>'||v_loadname||'</LOADNAME>';
     xml_clob := xml_clob||'<LOADCODE>'||v_loadcode||'</LOADCODE>';
     xml_clob := xml_clob||'<DISCHNAME>'||v_dischname||'</DISCHNAME>';
     xml_clob := xml_clob||'<DISCHCODE>'||v_dischcode||'</DISCHCODE>';
     xml_clob := xml_clob||'<VESSELNAME>'||c3rec.shipname||'</VESSELNAME>';
     xml_clob := xml_clob||'<VESSELID>'||c3rec.ship_id||'</VESSELID>';
     xml_clob := xml_clob||'<VOYAGE>'||c3rec.voy||'</VOYAGE>';
     xml_clob := xml_clob||'<EXPORTDATE>'||c3rec.estdepart||'</EXPORTDATE>';
     xml_clob := xml_clob||'<CARGOCODE>'||c3rec.cargocode||'</CARGOCODE>';
     xml_clob := xml_clob||'<GOODSCODE>'||v_goodscode||'</GOODSCODE>';
     xml_clob := xml_clob||'<INVCURRCD>'||v_invcurrcd||'</INVCURRCD>';
     xml_clob := xml_clob||'<FOBCURRCD>'||v_fobcurrcd||'</FOBCURRCD>';
     xml_clob := xml_clob||'<PACKCOUNT>'||c3rec.pkg_cnt||'</PACKCOUNT>';
     xml_clob := xml_clob||'<CONTCOUNT>'||c3rec.container_cnt||'</CONTCOUNT>';
     xml_clob := xml_clob||'<INVOICED>'||v_invoiced||'</INVOICED>';
     xml_clob := xml_clob||'<STATUS>'||v_status_with_ICS||'</STATUS>';
     xml_clob := xml_clob||'<UniqueConsRef>'||p_movement_no||case when p_seal is null then '' else '/'||p_seal end ||'</UniqueConsRef>';
    
     for c1rec in c1(p_movement_no, p_seal) loop
        xml_clob := xml_clob||'<Line.Item>';
        xml_clob := xml_clob||'<LINENO>'||c1rec.rnk||'</LINENO>';
        xml_clob := xml_clob||'<AHECCCODE>'||c1rec.ahecc||'</AHECCCODE>';
        xml_clob := xml_clob||'<ORIGCTRYNA>'||c1rec.countryname||'</ORIGCTRYNA>';
        xml_clob := xml_clob||'<ORIGCTRYCD>'||c1rec.country||'</ORIGCTRYCD>';
        xml_clob := xml_clob||'<ORIGSTATE>'||c1rec.origin||'</ORIGSTATE>';
        xml_clob := xml_clob||'<NETQTY>'||c1rec.qty||'</NETQTY>';
        xml_clob := xml_clob||'<WEIGHTUOM>'||'KG'||'</WEIGHTUOM>';
        xml_clob := xml_clob||'<WEIGHT>'||c1rec.goods_weight_kg||'</WEIGHT>';
        xml_clob := xml_clob||'<LINEFOB>'||c1rec.fob_value||'</LINEFOB>';
        xml_clob := xml_clob||'<DESCRIPT>'||replace(c1rec.description, '&', '')||'</DESCRIPT>';


--<WEIGHTUOM>Weight.Unit.of.Measure</WEIGHTUOM>
--<WEIGHT>Weight</WEIGHT>
--<LINEFOB>LIne.FOB.Value</LINEFOB>
--<DESCRIPT>Description.of.Goods</DESCRIPT>

--- stop here!!


--<Permit>
--<LINENO>Line.Number</LINENO>
--<PERMITNO>Permit.Number</PERMITNO>
--</Permit>
--<Temporary.Permit>
--<LINENO>Line.Number</LINENO>
--<PERMITNO>Temporary.Permit.Number</PERMITNO>
--</Temporary.Permit>
--<Assay>
--<LINENO>Line.Number</LINENO>
--<ELEMENT>Element.Symbol.Code</ELEMENT>
--<CONCENT>Element.Concentration</CONCENT>
--</Assay>
--</Line.Item>
        xml_clob := xml_clob||'</Line.Item>';
     end loop;
     xml_clob := xml_clob||'</EDN.Header>';
     xml_clob := xml_clob||'</EDN.Data.Transfer>';

  else
   null;
  end case;

    
    xml_blob := clob_to_blob(xml_clob);
    if dbms_lob.getlength(xml_blob) = 0
     then
      msg := 'No rows returned';
    else
     htp.prn('Content-type: ' || 'text/xml' || NL_CHAR);
     htp.prn('Content-Disposition: attachment; filename=' || f_name || NL_CHAR);
--      htp.prn('Content-Disposition: attachment; filename=' || f_name || NL_CHAR);
--     htp.prn('Content-Transfer-Encoding: binary' || NL_CHAR);
--     htp.prn(NL_CHAR);
     wpg_docload.download_file(xml_blob);
    
    end if;

 dbms_lob.freetemporary(xml_clob);
 dbms_lob.freetemporary(xml_blob);

exception when others then
 glbx.error_details( 'STRANGP', 'DOWNLOAD_FOB_XML', null, null, errmsg=>sqlerrm, extdet=>'');
end download_fob_xml;
/
