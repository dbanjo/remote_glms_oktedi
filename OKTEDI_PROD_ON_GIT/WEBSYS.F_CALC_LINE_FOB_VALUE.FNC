CREATE OR REPLACE function WEBSYS.f_calc_line_fob_value ( p_container varchar2, p_seal varchar2 default null, p_invoice_value in number default null, p_goods_weight in number default null)
 return number
as

 cursor c1(vmov varchar2, vseal varchar2) is 
 select revton, sumweight, iso_container_type, substr(l.cola,1,2) len_of_container
   from  strang.movements m, strang.lov l
  where m.movement_no = p_container 
    and  nvl(m.seal,'|') = nvl(p_seal, '|')
    and l.lov_name = 'UNCTNTAB'
    and m.iso_container_type = l.CODE
 union all
 select revton, sumweight, 'AIR', 'AIR'
   from  strang.movements m
  where m.movement_no = p_container 
   and nvl(m.seal,'|') = nvl(p_seal, '|')
   and m.movement_type = 'AIRWAY';
    
    
    

   
 c1rec  c1%ROWTYPE;
 tmp	varchar2(1000);
 v_revised_value number;
 v_air_type  varchar2(20);
 
 a_cons_and_packing number := 38.25; -- Consolidation and Packing per revtonne
 b_sys_support number := 4.25; -- System Support per revtonne
 c_cartage_full_20 number := 351.37; -- Cartage Full 20' flat charge
 d_cartage_MT_20 number := 142.86; -- Cartage MT 20' flat charge 
 e_cartage_full_40 number := 702.74; -- Cartage Full 40' flat charge
 f_cartage_MT_40 number := 285.72; -- Cartage MT 40' flat charge
 g_cartage_BB number := 49.62; -- Cartage Breakbulk
 h_cartage_air_lt_40 number := 3.76; -- Cartage Air (under 40kg) 
 i_cartage_air_gt_40 number := 99.25; -- Cartage Air (over 40kg)
 j_cartage_air_gt_2rt number := 49.62; -- Cartage Air (over 2R/T)
 k_air_security_surcharge number := 30.08; -- Airline Security Surcharge
 l_master_air_waybill number := 37.60; -- Master Air Waybill
 
 
begin
 tmp:= '';
 open c1(  p_container , p_seal );
 fetch c1 into c1rec;
 if c1%found then 
    
    if c1rec.len_of_container = 'AIR' and c1rec.sumweight < 40 then
       v_air_type := 'H';
    elsif c1rec.len_of_container = 'AIR' and c1rec.sumweight >= 40 and c1rec.revton < 2 then
       v_air_type := 'I';
    elsif c1rec.len_of_container = 'AIR' and c1rec.revton >= 2 then
       v_air_type := 'J';
    end if;
     
    
 
    if c1rec.len_of_container = '20' then
       v_revised_value := round(((((c1rec.revton * (a_cons_and_packing + b_sys_support)) + (c_cartage_full_20 + d_cartage_MT_20) *1 )/(c1rec.sumweight))* p_goods_weight) +p_invoice_value ,0);
    elsif c1rec.len_of_container = '40' then
       v_revised_value := round(((((c1rec.revton * (a_cons_and_packing + b_sys_support)) + (e_cartage_full_40 + f_cartage_MT_40) *1)/(c1rec.sumweight))* p_goods_weight) +p_invoice_value ,0);
    elsif c1rec.len_of_container = 'AIR' and v_air_type = 'H' then
       v_revised_value := round(((((c1rec.revton * (a_cons_and_packing + b_sys_support)) + (c1rec.sumweight * h_cartage_air_lt_40 ) + k_air_security_surcharge + l_master_air_waybill )/(c1rec.sumweight)) * p_goods_weight) + p_invoice_value ,0);  
    elsif c1rec.len_of_container = 'AIR' and v_air_type = 'I' then 
       v_revised_value := round(((((c1rec.revton * (a_cons_and_packing + b_sys_support)) + i_cartage_air_gt_40 + k_air_security_surcharge + l_master_air_waybill )/(c1rec.sumweight)) * p_goods_weight) + p_invoice_value ,0);  
    elsif c1rec.len_of_container = 'AIR' and v_air_type = 'J' then  
       v_revised_value := round(((((c1rec.revton * (a_cons_and_packing + b_sys_support)) + ( c1rec.revton * j_cartage_air_gt_2rt ) + k_air_security_surcharge + l_master_air_waybill )/(c1rec.sumweight)) * p_goods_weight) + p_invoice_value ,0);
    else
      v_revised_value := p_invoice_value;
    end if;
 else 
    v_revised_value := null;
 end if;
 close c1;
  return ( v_revised_value);
end f_calc_line_fob_value;
/
