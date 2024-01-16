CREATE OR REPLACE procedure STRANG.generate_sad_sad_com(v_entry varchar2, err in out varchar2, mail_to integer default 2, refresh boolean default TRUE, send_email boolean default TRUE) as

TYPE t_ctr_item is table of number index by varchar2(64);

cursor c1(v_ent varchar2) is
 select cs.*
 from   detailrs dr, receivals rc, customers cs
 where  dr.entry_no_com = v_ent
        and rc.deliveryno = dr.deliveryno
		and cs.customer_id = rc.cust_customer_id
		and cs.customer_type = 'CUSTOMER'
 ;


cursor c2a(v_ent varchar2) is
 select l2.entry_item entry_item,l2.cola cola
 from (
 select distinct p.entry_item entry_item,l1.cola cola
 from   strang.detailrs dr, strang.pos p, strang.lov l1,
        (select dt.entry_no enmb
         from  strang.duty dt
         where dt.entry_no = v_ent and
         nvl(dt.previous_entry_no,0) = 0
	    ) z2
 where  entry_no_com = v_ent and
        p.deliveryno = dr.deliveryno and
        p.inventoryno = l1.code and
        l1.lov_name = 'INVENT'
        order by p.entry_item, l1.cola) l2
		where l2.entry_item < 2
 ;


cursor c2b(v_ent varchar2) is
 select distinct p.entry_item entry_item, l1.cola cola
 from   strang.detailrs dr, strang.pos p, strang.lov l1,
        (select dt.entry_no enmb
         from  strang.duty dt
         where dt.entry_no = v_ent and
         nvl(dt.previous_entry_no,0) = 0
	    ) z2
 where  entry_no_com = v_ent and
        p.deliveryno = dr.deliveryno and
        p.inventoryno = l1.code and
        l1.lov_name = 'INVENT'
        order by p.entry_item, l1.cola
 ;

cursor c3(v_ent varchar2) is
select * from strang.sad_following
where entry_no = v_ent
order by order_by;

cursor c4(v_ent varchar2) is
select * from strang.sad_general_data
where entry_no = v_ent and
rownum < 2;

cursor c5(v_ent varchar2) is
select distinct m.movement_no, m.iso_container_type, nvl(m.tare,0) gross_weight, m.sumweight packages_weight, decode(m.sumweight,0,'EMPTY','FCL') EMPTY_FULL, m.container_type
from strang.movements m, strang.detailrs dr
where dr.entry_no_com = v_ent and
dr.movement_no = m.movement_no and
m.movement_type = 'CARGO' and
nvl(dr.camov_seal,'|') = nvl(m.seal,'|');

cursor c5a(v_ent varchar2) is
 select count (distinct m.movement_no) ctrno
 from strang.movements m, strang.detailrs dr
 where dr.entry_no_com = v_ent and
 dr.movement_no = m.movement_no and
 m.movement_type = 'CARGO' and
 nvl(dr.camov_seal,'|') = nvl(m.seal,'|');

cursor c6( v_ent varchar2 ) is
 select count( distinct dr.movement_no ) cgo
 from detailrs dr
 where dr.entry_no_com = v_ent and
 dr.camov_seal is not null;

cursor c7( cde varchar2, lv varchar2) is
select description
from lov
where lov_name = lv and
code = cde;

cursor c7a( cde varchar2, lv varchar2) is
select cola
from lov
where lov_name = lv and
code = cde;

cursor c8( v_ent varchar2 ) is
 select count( distinct r.supplier_customer_id ) suppno
 from detailrs dr, receivals r
 where dr.entry_no_com = v_ent and
 dr.deliveryno = r.deliveryno;

chk_bfr   CONSTANT integer := 25000;
ctr_itm   t_ctr_item;
t_weight	number;
tr_weight	number;
pr_weight	number;
p_weight	number;
ss_ref		varchar2(100);
ss_ref1		varchar2(100);
ss_ref2		integer;
ss_ref3		varchar2(100);
ss_ref4		varchar2(100);
firstitem	boolean;
cgotmp		integer;
cgotmp2		varchar2(100);
exportctyname	varchar2(100);
ctr_counter	integer;
f_dir	        varchar2(1000);
f_name	      varchar2(1000);
f             utl_file.file_type;
c1rec         c1%ROWTYPE;
c2arec        c2a%ROWTYPE;
c5rec	      c5%ROWTYPE;
c5arec	      c5a%ROWTYPE;
c6rec         c6%ROWTYPE;
c7rec         c7%ROWTYPE;
c7arec        c7a%ROWTYPE;
c8rec         c8%ROWTYPE;
gen_rec	      strang.sad_general_data%ROWTYPE;
fol_rec	      strang.sad_following%ROWTYPE;
v_cust        varchar2(100);
v_tariff      varchar2(100);
v_entryitem   number;
err_msg       varchar2(4000);
v_buf         varchar2(32000);
vtot	        number;
v_item_description varchar2(100);
num0	        number;
num1          number;
num2          number;
num3          number;
num4          number;
num5          number;
num6          number;
num7          number;
num8          number;
num9          number;
num10         number;
num11         number;
num12         number;
num13         number;
num14         number;
item_exf      number;
item_ins      number;
item_oc       number;
item_inf      number;
item_ded      number;
item_inv      number;
tot_dec	      number;
tmp	          number;
value_in_natcurr  varchar2(15);
item_exf_fc   number;
item_ins_fc   number;
item_oc_fc    number;
item_inf_fc   number;
item_ded_fc   number;
item_inv_fc   number;
item_taxduty  number;
value_in_forcurr  varchar2(15);
recalc        varchar2(1);
v_excise      number;
stp           varchar2(1000);
sad_file_ctr  integer;
sad_file_len  integer;
src_blb       BLOB;
dst_blb       BLOB;
lob_ret_val   number;

-- Start inline programs

 -- Function to create repeating ASCII characters
 function rep_chr(asc_chr in integer, mult in integer default 1) return varchar2 is
  v_txt varchar2(1000);
 begin
  v_txt := null;
  for j in 1..mult loop
   v_txt := v_txt || chr(asc_chr);
  end loop;
  return(v_txt);
 exception when others then return(null);
 end rep_chr;

 function add_field(vval in varchar2, max_length integer default null, delim integer default 0, is_num boolean default FALSE) return varchar2 is
  v_txt varchar2(1000);
  xtxt varchar2(1000);
 begin
  v_txt := trim(vval);
  if max_length is not null and length(v_txt) > max_length
   then
    v_txt := substr(v_txt, 1, max_length);
  end if;
--  v_txt := v_txt || rep_chr(0);  -- xml conversion
  xtxt := v_txt;
  if xtxt is not null then
    xtxt := replace(xtxt,'&','&amp;');
    xtxt := replace(xtxt,'''','&apos;');
    xtxt := replace(xtxt,'<','&lt;');
    xtxt := replace(xtxt,'>','&gt;');
    xtxt := replace(xtxt,'"','&quot;');
  end if;
  return(xtxt);
 exception when others then return(null);
 end add_field;

 procedure refresh_sad_tables
 is
 begin
  stp := 'GEN: A';
  delete from strang.sad_general_data where entry_no = v_entry;
  delete from strang.sad_following where entry_no = v_entry;
   gen_rec.entry_no := v_entry;
   gen_rec.SAD_014_USER_YEAR:=to_char(sysdate, 'YYYY');
   gen_rec.SAD_015_CUO_COD:= f15_parameter_range_sad_com( 'A3_SAD', v_entry, v_cust );
   gen_rec.SAD_016_DECLARANT:= f15_parameter_range_sad_com( 'AD', v_entry, v_cust );
   gen_rec.SAD_017_USER_NBER:= f15_parameter_range_sad_com( 'A17_SAD', v_entry, v_cust );
   gen_rec.SAD_014_USER_YEAR:=to_char(sysdate, 'YYYY');
   gen_rec.SAD_018_NOT_DEFINED:= '1';
   gen_rec.SAD_019_TYP_DEC:= f15_parameter_range_sad_com( 'A4_SAD', v_entry, v_cust );
   gen_rec.SAD_020_TYP_PROC:= f15_parameter_range_sad_com( 'A5_SAD', v_entry, v_cust );
   gen_rec.SAD_023_MANIF_NBER:= f15_parameter_range_sad_com( 'AS_REG', v_entry, v_cust );
   gen_rec.SAD_028_ITM_TOTAL := f15_parameter_range_sad_com( 'A00', v_entry, v_cust );
   gen_rec.SAD_029_PACK_TOTAL := f15_parameter_range_sad_com( 'A000', v_entry, v_cust );
   gen_rec.SAD_030_CONSIGNEE := f15_parameter_range_sad_com( 'A5', v_entry, v_cust );
   gen_rec.SAD_031_FINANCIAL := f15_parameter_range_sad_com( 'A6_SAD', v_entry, v_cust );
   gen_rec.SAD_032_CTY_1DLP := f15_parameter_range_sad_com( 'A7_SAD', v_entry, v_cust );
   gen_rec.SAD_033_TRA_CTY := f15_parameter_range_sad_com( 'A8_SAD', v_entry, v_cust );
   num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AG', v_entry, v_cust )), 0);
   num3 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AI', v_entry, v_cust )), 0);
   num4 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJ', v_entry, v_cust )), 0);
   num7 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AGI', v_entry, v_cust )), 0); --internal freight;
   num8 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJD', v_entry, v_cust )), 0); -- deductions;
   gen_rec.SAD_034_VAL_DETAILS := to_char((num1+num3+num4+num7-num8)/f15_parameter_range_sad_com( 'A9', v_entry, v_cust ), '999999999990.00');
   gen_rec.SAD_036_CTY_EXPCOD := f15_parameter_range_sad_com( 'A9_SAD', v_entry, v_cust );
   gen_rec.SAD_038_CTY_DESTCOD := f15_parameter_range_sad_com( 'A10_SAD', v_entry, v_cust );
   gen_rec.SAD_040_TRSP_IDDEPAR := f15_parameter_range_sad_com( 'AS', v_entry, v_cust );
   gen_rec.SAD_041_TRSP_NATDEPAR := f15_parameter_range_sad_com( 'AB_3', v_entry, v_cust );
   gen_rec.SAD_042_CTNR_FLAG := f15_parameter_range_sad_com( 'SAD_AWWWW_5', v_entry, v_cust );
   gen_rec.SAD_043_TOD_COD := f15_parameter_range_sad_com( 'A8', v_entry, v_cust );
   gen_rec.SAD_044_TOD_NAM := f15_parameter_range_sad_com( 'A11_SAD', v_entry, v_cust );
   gen_rec.SAD_048_CUR_COD := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );
   gen_rec.SAD_049_TOT_INVOICED := f15_parameter_range_sad_com( 'AE', v_entry, v_cust );
   gen_rec.SAD_052_MOT_BORD := f15_parameter_range_sad_com( 'SAD_AWWWW_6', v_entry, v_cust );
   gen_rec.SAD_054_LOP_COD := f15_parameter_range_sad_com( 'A12_SAD', v_entry, v_cust );
   gen_rec.SAD_055_TOP_COD := f15_parameter_range_sad_com( 'SAD_AWWWW_7', v_entry, v_cust );
   gen_rec.SAD_056_CUO_BORD := f15_parameter_range_sad_com( 'A3_SAD_1', v_entry, v_cust );
   gen_rec.SAD_057_LOC_GOODS := f15_parameter_range_sad_com( 'A13_SAD', v_entry, v_cust );
   gen_rec.SAD_058_BNK_COD := f15_parameter_range_sad_com( 'SAD_AWWWW_8', v_entry, v_cust );
   gen_rec.SAD_059_BNK_BRA := f15_parameter_range_sad_com( 'SAD_AWWWW_9', v_entry, v_cust );
   gen_rec.SAD_060_BNK_FNBER := f15_parameter_range_sad_com( 'A16_SAD', v_entry, v_cust );
   gen_rec.SAD_062_WHS_COD := f15_parameter_range_sad_com( 'A14_SAD', v_entry, v_cust );
   gen_rec.SAD_063_WHS_TIME := f15_parameter_range_sad_com( 'A15_SAD', v_entry, v_cust );
   gen_rec.SAD_071_GRTY_AMOUNT := f15_parameter_range_sad_com( 'AE_1', v_entry, v_cust );
   gen_rec.SAD_072_GRTY_DATE := f15_parameter_range_sad_com( 'AE_2', v_entry, v_cust );
   gen_rec.SAD_073_TOT_FEES := to_char(f15_parameter_range_sad_com( 'A18_SAD', v_entry, v_cust ),'999999999999990.99');
   tot_dec:=0;
   for c2brec in c2b(v_entry) loop
     v_excise:=0;
     v_tariff:= c2brec.cola;
     v_entryitem := c2brec.entry_item; --20161109
     tot_dec := tot_dec +  nvl(form_15_continue_sad_com( 'XX_2',v_entry, v_entryitem, v_tariff,c2b%ROWCOUNT,vtot ),0);
     tmp := nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'CPY_3a',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot )), 0);
      if tmp > 0
      then
        num13:= nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot )), 0); -- excise rate tax amount
        num14:= nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot )), 0); -- excise by unit tax amount
        if tmp = 4
        then
         if num13 < num14
          then
          tmp := 1;
         else
          tmp := 2;
         end if;
        end if;
        if tmp = 5
        then
         if num13 > num14
         then
          tmp := 1;
         else
          tmp := 2;
         end if;
        end if;
        case
         when tmp = 1 then
          tot_dec := tot_dec + nvl(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
          v_excise:= nvl(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);
         when tmp = 2 then
          tot_dec := tot_dec + nvl(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
          v_excise:= nvl(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);
         when tmp = 3 then
          tot_dec := tot_dec + nvl(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
          tot_dec := tot_dec + nvl(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
          v_excise:= nvl(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);
          v_excise:= v_excise + nvl(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);
        end case;
      end if;
     tot_dec := tot_dec +  nvl(form_15_continue_sad_com( 'SSS_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,v_excise ),0);  -- VAT
     tot_dec := tot_dec +  nvl(form_15_continue_sad_com( 'TTT_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,v_excise ),0);  -- LEVY
    end loop;
     gen_rec.SAD_074_TOTAL_TAXES:= to_char(tot_dec+(strang.f15_parameter_range_sad_com( 'A18_SAD', v_entry, v_cust )), '999999999999990.99' );
--     gen_rec.SAD_074_TOTAL_TAXES:= to_char(tot_dec, '999999999999990.99' );  -- 20150821
     gen_rec.SAD_075_CTRL_RESULTS := '0';
     gen_rec.SAD_077_DEC_DATE := to_char(sysdate, 'YYYYMMDD');
     gen_rec.SAD_080_NOT_DEFINED := '0';
     gen_rec.SAD_081_ITOTINV_VALC := f15_parameter_range_sad_com( 'AE', v_entry, v_cust );
     gen_rec.SAD_082_ITOTINV_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );
     gen_rec.SAD_083_ITOTINV_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999');
     gen_rec.SAD_084_ITOTINV_REF := '1.00000'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); -- JY CHANGE
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AE', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);
     if num2 <> 0
     then
      gen_rec.SAD_085_ITOTINV_VALN :=to_char(num1/num2, '99999990.00');
     else
      gen_rec.SAD_085_ITOTINV_VALN :='0.00';
     end if;
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AG', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_086_ITOTEFR_VALC:= to_char(f15_parameter_range_sad_com( 'AG', v_entry, v_cust ),'99999990.00');      -- AG [N11] [EXTERNAL FREIGHT IN AUD] 86/5 SAD_ITOTEFR_VALC
       gen_rec.SAD_087_ITOTEFR_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );
       gen_rec.SAD_088_ITOTEFR_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999');
     else
       gen_rec.SAD_086_ITOTEFR_VALC:= NULL;      -- AG [N11] [EXTERNAL FREIGHT IN AUD] 86/5 SAD_ITOTEFR_VALC
       gen_rec.SAD_087_ITOTEFR_CUR := NULL;
       gen_rec.SAD_088_ITOTEFR_RAT := NULL;
     end if;
     gen_rec.SAD_089_ITOTEFR_REF := '1.00000'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); -- JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_090_ITOTEFR_VALN := to_char(num1/num2, '99999990.00');    -- AG/A9 [EXTERNAL FREIGHT IN PGK] 90/8 SAD_ITOTEFR_VALN
     else
       gen_rec.SAD_090_ITOTEFR_VALN := '0.00';    -- AG/A9 [EXTERNAL FREIGHT IN PGK] 90/8 SAD_ITOTEFR_VALN
     end if;
--
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AI', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_091_ITOTINS_VALC:= to_char(f15_parameter_range_sad_com( 'AI', v_entry, v_cust ),'99999990.00');      --       -- AI [N11] [INSURANCE IN AUD] 91/9 SAD_ITOTINS_VALC
       gen_rec.SAD_092_ITOTINS_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );  -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 92/10 SAD_ITOTINS_CUR
       gen_rec.SAD_093_ITOTINS_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- A9  [N8] [23] [EXCHANGE RATE] 93/11 SAD_ITOTINS_RAT
     else
       gen_rec.SAD_091_ITOTINS_VALC:= NULL;            -- AI [N11] [INSURANCE IN AUD] 91/9 SAD_ITOTINS_VALC
       gen_rec.SAD_092_ITOTINS_CUR := NULL;            -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 92/10 SAD_ITOTINS_CUR
       gen_rec.SAD_093_ITOTINS_RAT := NULL;            -- A9  [N8] [23] [EXCHANGE RATE] 93/11 SAD_ITOTINS_RAT
     end if;
     gen_rec.SAD_094_ITOTINS_REF := '1.00000'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust );  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 94/- SAD_ITOTINS_REF --JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_095_ITOTINS_VALN := to_char(num1/num2, '99999990.00');     -- AI/A9 [INSURANCE IN PGK] 95/12 SAD_ITOTINS_VALN-- AG/A9 [EXTERNAL FREIGHT IN PGK] 90/8 SAD_ITOTINS_VALN
     else
       gen_rec.SAD_095_ITOTINS_VALN := '0.00';     -- AI/A9 [INSURANCE IN PGK] 95/12 SAD_ITOTINS_VALN
     end if;
--
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJ', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_096_ITOTOTC_VALC:= to_char(f15_parameter_range_sad_com( 'AJ', v_entry, v_cust ),'99999990.00');      -- AJ [N11][OTHER COSTS IN AUD] 96/13 SAD_ITOTOTC_VALC
       gen_rec.SAD_097_ITOTOTC_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );  -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 97/14 SAD_ITOTOTC_CUR
       gen_rec.SAD_098_ITOTOTC_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- A9  [N8] [23] [EXCHANGE RATE] 98/15 SAD_ITOTOTC_RAT
     else
       gen_rec.SAD_096_ITOTOTC_VALC:= NULL;            -- AJ [N11][OTHER COSTS IN AUD] 96/13 SAD_ITOTOTC_VALC
       gen_rec.SAD_097_ITOTOTC_CUR := NULL;            -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 97/14 SAD_ITOTOTC_CUR
       gen_rec.SAD_098_ITOTOTC_RAT := NULL;            -- A9  [N8] [23] [EXCHANGE RATE] 98/15 SAD_ITOTOTC_RAT
     end if;
     gen_rec.SAD_099_ITOTOTC_REF := '1.00000'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust );  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 99/- SAD_ITOTOTC_REF --JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_100_ITOTOTC_VALN := to_char(num1/num2, '99999990.00');     -- -- AJ/A9  [OTHER COSTS AMOUNT IN PGK] 100/16 SAD_ITOTOTC_VALN
     else
       gen_rec.SAD_100_ITOTOTC_VALN := '0.00';     -- AJ/A9  [OTHER COSTS AMOUNT IN PGK] 100/16 SAD_ITOTOTC_VALN
     end if;
--
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AGI', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_101_ITOTIFR_VALC:= to_char(f15_parameter_range_sad_com( 'AGI', v_entry, v_cust ),'99999990.00');      -- [NUMBER11] 101/17 SAD_ITOTIFR_VALC & [AN3] 102/18 SAD_ITOTIFR_CUR & [NUMBER 8] 103/19 SAD_ITOTIFR_RAT
       gen_rec.SAD_102_ITOTIFR_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );  -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 102/18 SAD_ITOTIFRC_CUR
       gen_rec.SAD_103_ITOTIFR_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- A9  [N8] [23] [EXCHANGE RATE] 103/19 SAD_ITOTIFR_RAT
     else
       gen_rec.SAD_101_ITOTIFR_VALC:= NULL;            -- [NUMBER11] 101/17 SAD_ITOTIFR_VALC & [AN3] 102/18 SAD_ITOTIFR_CUR & [NUMBER 8] 103/19 SAD_ITOTIFR_RAT
       gen_rec.SAD_102_ITOTIFR_CUR := NULL;            -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 102/18 SAD_ITOTIFRC_CUR
       gen_rec.SAD_103_ITOTIFR_RAT := NULL;            -- A9  [N8] [23] [EXCHANGE RATE] 103/19 SAD_ITOTIFR_RAT
     end if;
     gen_rec.SAD_104_ITOTIFR_REF := '1.00000'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust );  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 104/- SAD_ITOTIFR_REF -- JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_105_ITOTIFR_VALN := to_char(num1/num2, '99999990.00');     -- -- [NUMBER 11] AGI/A9  [INTERNAL FREIGHT AMOUNT IN PGK] 105/20 SAD_ITOTIFR_VALN
     else
       gen_rec.SAD_105_ITOTIFR_VALN := '0.00';     -- AGI/A9 [NUMBER 11] [INTERNAL FREIGHT AMOUNT IN PGK] 105/20 SAD_ITOTIFR_VALN
     end if;
--
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJD', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_106_ITOTDED_VALC:= to_char(f15_parameter_range_sad_com( 'AJD', v_entry, v_cust ),'99999990.00');      -- [NUMBER11] 106/21 SAD_ITOTDED_VALC
       gen_rec.SAD_107_ITOTDED_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );  -- [AN3] 107/22 SAD_ITOTDED_CUR [REF - UNCURTAB]
       gen_rec.SAD_108_ITOTDED_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- A9  [N8] [23] [EXCHANGE RATE] 108/23 SAD_ITOTDED_RAT
     else
       gen_rec.SAD_106_ITOTDED_VALC:= NULL;            -- [NUMBER11] 106/21 SAD_ITOTDED_VALC
       gen_rec.SAD_107_ITOTDED_CUR := NULL;            -- [AN3] 107/22 SAD_ITOTDED_CUR [REF - UNCURTAB]
       gen_rec.SAD_108_ITOTDED_RAT := NULL;            -- A9  [N8] [23] [EXCHANGE RATE] 108/23 SAD_ITOTDED_RAT
     end if;
     gen_rec.SAD_109_ITOTDED_REF := '1.00000'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust );  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 109/- SAD_ITOTDED_REF --JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_110_ITOTDED_VALN := to_char(num1/num2, '99999990.00');     -- -- [NUMBER 11] AJD/A9  [DEDUCTIONS AMOUNT IN PGK] 110/24 SAD_ITOTDED_VALN
     else
       gen_rec.SAD_110_ITOTDED_VALN := '0.00';     -- -- [NUMBER 11] AJD/A9  [DEDUCTIONS AMOUNT IN PGK] 110/24 SAD_ITOTDED_VALN
     end if;
--
 num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AG', v_entry, v_cust )), 0);
 num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);
 num3 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AI', v_entry, v_cust )), 0);
 num4 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJ', v_entry, v_cust )), 0);
 num7 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AGI', v_entry, v_cust )), 0); --internal freight;
 num8 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJD', v_entry, v_cust )), 0); -- deductions;
 if num2 <> 0
  then
   gen_rec.SAD_111_ITOTADD_CST := to_char((num1+num3+num4+num7-num8)/num2, '999999999990.00');    -- [NUMBER 15] ((AG+AI+AJ+AGI-AJD)/A9) [TOTAL COSTS IN PGK]  111/26 SAD_ITOTADD_CST
 else
   gen_rec.SAD_111_ITOTADD_CST := '0.00';    -- -- [NUMBER 15] ((AG+AI+AJ+AGI-AJD)/A9) [TOTAL COSTS IN PGK]  111/26 SAD_ITOTADD_CST
 end if;
--
 num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AG', v_entry, v_cust )), 0);
 num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);
 num3 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AI', v_entry, v_cust )), 0);
 num4 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJ', v_entry, v_cust )), 0);
 num5 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AE', v_entry, v_cust )), 0);
 num7 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AGI', v_entry, v_cust )), 0); --internal freight;
 num8 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJD', v_entry, v_cust )), 0); -- deductions;
 if num2 <> 0
  then
   gen_rec.SAD_112_ICIF_VALN := to_char((num5/num2)+(num1+num3+num4+num7-num8)/num2, '999999999990.00');    -- [NUMBER 15] AE/A9 + ((AG+AI+AJ+AGI-AJD)/A9)  [INVOICE TOTAL+ TOTAL COSTS IN PGK] 112/27 SAD_ICIF_VALN
 else
   gen_rec.SAD_112_ICIF_VALN := '0.00';    -- [NUMBER 15] AE/A9 + ((AG+AI+AJ+AGI-AJD)/A9)  [INVOICE TOTAL+ TOTAL COSTS IN PGK] 112/27 SAD_ICIF_VALN
 end if;
 -- PART 4: OCCASIONAL DATA - EXPORTER (ASYCUDA++ TECHNICAL DOC V1.3 - SAD FILE STRUCTURE)
-- =====================================================================================
 gen_rec.SAD_115_EXP_NAM := f15_parameter_range_sad_com( 'A4', v_entry, v_cust );
 gen_rec.SAD_116_EXP_ADD1:= f15_parameter_range_sad_com( 'A4X', v_entry, v_cust );
 gen_rec.SAD_117_EXP_ADD2:= f15_parameter_range_sad_com( 'A4XX', v_entry, v_cust );
 gen_rec.SAD_118_EXP_CITY:= f15_parameter_range_sad_com( 'A4X1', v_entry, v_cust );
 gen_rec.SAD_119_EXP_ZIP:=  f15_parameter_range_sad_com( 'A4XX1', v_entry, v_cust );

-- GLOBAL TAXES
-- ===============
 gen_rec.GLOBAL_TAX_1 := strang.f15_parameter_range_sad_com( 'A21_SAD', v_entry,v_cust );
 gen_rec.GLOBAL_TAX_2 := 'EPG';
 gen_rec.GLOBAL_TAX_3 := to_char(f15_parameter_range_sad_com( 'A18_SAD', v_entry, v_cust ),999990.99 );
 gen_rec.GLOBAL_TAX_4 := '1.0000';
 gen_rec.GLOBAL_TAX_5 := to_char(f15_parameter_range_sad_com( 'A18_SAD', v_entry, v_cust ),999990.99 );
 gen_rec.GLOBAL_TAX_6 := strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );
----------------------------------------------------------------------------------------
   insert into strang.sad_general_data
     values  gen_rec;
   commit;
   for c2brec in c2b(v_entry) loop
     fol_rec:= NULL;
     v_tariff := c2brec.cola;
     v_entryitem := c2brec.entry_item; --20161109
     stp := 'FOL [' || v_tariff || ']:A';
     err_msg:=v_tariff;
     fol_rec.entry_no:= v_entry;
     fol_rec.order_by := c2b%ROWCOUNT;
     fol_rec.SAD_131_ITM_NBER:= to_char(c2b%ROWCOUNT);
     if to_char(c2b%ROWCOUNT) = 1
     then
       fol_rec.SAD_132_PACK_MARK1:= 'OTML/TBL';
--       fol_rec.SAD_133_PACK_MARK2:= f15_parameter_range_sad_com( 'AWWW_1X', v_entry, v_cust );
       fol_rec.SAD_133_PACK_MARK2:= 'PO '|| form_15_continue_sad_com( 'AWW_SAD', v_entry, v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
       ss_ref:= form_15_continue_sad_com( 'AWW_SAD', v_entry, v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
       ss_ref4:= f15_parameter_range_sad_com( 'SAD_AWWWW_1', v_entry, v_cust );
       ss_ref4 := replace(ss_ref4,'-');
       if length(ss_ref4)>3 then
         ss_ref4:= nvl( substr(ss_ref4,-3,3),'x');
       end if;
       ss_ref3:= form_15_continue_sad_com( 'AWW_SAD', v_entry, v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ) ||'_'|| ss_ref4 ; -- f15_parameter_range_sad_com( 'SAD_AWWWW_1', v_entry, v_cust );
       ss_ref1:= form_15_continue_sad_com( 'AWW', v_entry, v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
     else
       fol_rec.SAD_132_PACK_MARK1:= form_15_continue_sad_com( 'AWW', v_entry, v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
       fol_rec.SAD_133_PACK_MARK2:= 'PO '|| form_15_continue_sad_com( 'AWW_SAD', v_entry, v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
     end if;
--     fol_rec.SAD_132_PACK_MARK1:= f15_parameter_range_sad_com( 'AWW', v_entry, v_cust );
--     fol_rec.SAD_133_PACK_MARK2:= f15_parameter_range_sad_com( 'AWWW_SAD', v_entry, v_cust );
     fol_rec.SAD_134_HS_COD:=   form_15_continue_sad_com( 'CPC_1',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
     fol_rec.SAD_135_HSPREC_COD := form_15_continue_sad_com( 'CPC_1_1',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
     fol_rec.SAD_138_TAR_SPC := form_15_continue_sad_com( 'CPC_1_2',v_entry,v_entryitem,v_tariff,1,vtot );
     fol_rec.SAD_139_GOODS_DESC1:= f15_parameter_range_sad_com( 'SAD_AWWWWW_1', v_entry, v_tariff );
     fol_rec.SAD_140_GOODS_DESC2 := f15_parameter_range_sad_com( 'SAD_AWWWWW_2', v_entry, v_tariff );
     fol_rec.SAD_141_GOODS_DESC3 := f15_parameter_range_sad_com( 'SAD_AWWWWW_3', v_entry, v_tariff );
     fol_rec.SAD_142_PACK_NBER := f15_parameter_range_sad_com( 'AWWW_1', v_entry, v_cust );
     fol_rec.SAD_143_PACK_KINDCOD := f15_parameter_range_sad_com( 'AWWW_2', v_entry, v_cust );
     fol_rec.SAD_144_CTY_ORIGCOD := f15_parameter_range_sad_com( '000A', v_entry, v_cust );
     fol_rec.SAD_146_GROSS_MASS := to_char(form_15_continue_sad_com( 'CPG_4',v_entry,v_entryitem,v_tariff,1,vtot ),'9999990.999' );
     fol_rec.SAD_148_CTNR_NBER1 := f15_parameter_range_sad_com( 'SAD_AWWWW_1', v_entry, v_cust );
     fol_rec.SAD_149_CTNR_NBER2 := f15_parameter_range_sad_com( 'SAD_AWWWW_2', v_entry, v_cust );
     fol_rec.SAD_150_CTNR_NBER3 := f15_parameter_range_sad_com( 'SAD_AWWWW_3', v_entry, v_cust );
     fol_rec.SAD_151_CTNR_NBER4 := f15_parameter_range_sad_com( 'SAD_AWWWW_4', v_entry, v_cust );
     fol_rec.SAD_152_EXTD_PROC := form_15_continue_sad_com( 'CPG_2',v_entry,v_entryitem,v_tariff,1,vtot );
     fol_rec.SAD_153_NAT_PROC := form_15_continue_sad_com( 'CPG_3',v_entry,v_entryitem,v_tariff,1,vtot );
     fol_rec.SAD_154_NET_MASS := to_char(form_15_continue_sad_com( 'CPG_4',v_entry,v_entryitem,v_tariff,1,vtot ),'9999990.999' );
     fol_rec.SAD_156_TRSP_DOC := form_15_continue_sad_com( 'CPH_2',v_entry,v_entryitem,v_tariff,1,vtot );
     fol_rec.SAD_157_SUPP_UNITS := to_char(form_15_continue_sad_com( 'CPY',v_entry,v_entryitem,v_tariff,1,vtot ),'9999990.999' );
     fol_rec.SAD_158_ITM_PRICE := to_char(form_15_continue_sad_com( 'CPY_3',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999999990.99' );
-- CALCULATIONS
     stp := 'FOL [' || v_tariff || ']:B';
 num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AE', v_entry, v_cust )), 0);  -- total invoice
 num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'A9', v_entry, v_cust )), 0);  -- exchange rate
 num3 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AG', v_entry, v_cust )), 0);  -- exfreight
 num4 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AI', v_entry, v_cust )), 0);  -- insurance
 num5 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJ', v_entry, v_cust )), 0);  -- other costs
 num6 := nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'CPY_3',v_entry,v_entryitem,v_tariff,1,vtot )), 0);  -- item's invoice in foreign currency
 num7 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AGI', v_entry, v_cust )), 0); --internal freight;
 num8 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com( 'AJD', v_entry, v_cust )), 0); -- deductions;
v_item_description := '';
if (num1 <> 0) or (num2 <> 0)
then
-- in national currency
  item_exf:=round((num6/num1)*(num3/num2),2);
  item_ins:=round((num6/num1)*(num4/num2),2);
  item_oc:=round((num6/num1)*(num5/num2),2);
  item_inf:=round((num6/num1)*(num7/num2),2);
  item_ded:=round((num6/num1)*(num8/num2),2);
  item_inv:=round((num6/num2),2);
  value_in_natcurr:= to_char(round((item_inv + item_exf + item_ins + item_oc + item_inf - item_ded),2),'999999990.99');
-- in foreign currency
  item_exf_fc:=round((num6/num1)*(num3),2);
  item_ins_fc:=round((num6/num1)*(num4),2);
  item_oc_fc:=round((num6/num1)*(num5),2);
  item_inf_fc:=round((num6/num1)*(num7),2);
  item_ded_fc:=round((num6/num1)*(num8),2);
  item_inv_fc:=round(num6,2);
  value_in_forcurr:= to_char(round((item_inv_fc + item_exf_fc + item_ins_fc + item_oc_fc + item_inf_fc - item_ded_fc),2),'999999990.99');
else
  item_exf:= 0;
  item_ins:= 0;
  item_oc:=0;
  item_inf:=0;
  item_ded:=0;
  item_inv:= 0;
  value_in_natcurr:= '0.00';
  item_exf_fc:=0;
  item_ins_fc:=0;
  item_oc_fc:=0;
  item_inf_fc:=0;
  item_ded_fc:=0;
  item_inv_fc:=0;
  value_in_forcurr:='0.00';
end if;
  stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:C';

-- item exfreight
   v_item_description := trim(to_char(item_exf, '99999990.00')) || ' ';   -- [N11] ITEM 1 EXTERNAL FREIGHT IN NATIONAL CURR 188/37             SAD_IITMEFR_VALN
-- item insurance
   v_item_description := v_item_description || '+ ' || trim(to_char(item_ins, '99999990.00')) || ' ';   -- [N11] ITEM 1 INSURANCE IN NATIONAL CURR 193/41               SAD_IITMINS_VALN
 -- item other costs
   v_item_description := v_item_description || '+ ' || trim(to_char(item_oc, '99999990.00')) || ' ';   -- [N11] ITEM 1 OTHER COSTS IN NATIONAL CURR 198/45             SAD_IITMOTC_VALN
 -- item infreight
   v_item_description := v_item_description || '+ ' || trim(to_char(item_inf, '99999990.00')) || ' ';   -- [N11] ITEM 1 INFREIGHT IN NATIONAL CURR 203/49             SAD_IITMIFR_VALN
 -- item deductions
   v_item_description := v_item_description || '- ' || trim(to_char(item_ded, '99999990.00'));   -- [N11] ITEM 1 DEDUCTIONS IN NATIONAL CURR 208/53             SAD_IITMDED_VALN
   fol_rec.SAD_159_VAL_METHOD := v_item_description;
   fol_rec.SAD_165_ADJ_RATE := '1.00'; -- strang.f15_parameter_range_sad_com( 'AA', v_entry,v_cust ); --JY CHANGE
   fol_rec.SAD_166_PREV_DOC := strang.f15_parameter_range_sad_com( 'AWWW_3', v_entry,v_cust );
   fol_rec.SAD_170_STAT_VAL := to_char((trunc(form_15_continue_sad_com( 'TT',v_entry,v_entryitem,v_tariff,1,vtot ))+1),'999999999990.99');  -- added trunc 20150311
 num0 := nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'CPY_3a',v_entry,v_entryitem,v_tariff,1,vtot )), 0);
   stp := 'FOL [' || v_entryitem ||' '|| v_tariff || ']:D';

 v_excise := 0;
   if num0 > 0
   then
    num13:=nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- excise rate tax amount
    num14:=nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- excise by unit tax amount
    if num0 = 4
    then
     if num13 < num14
     then
      num0 := 1;
     else
      num0 := 2;
     end if;
    end if;
    if num0 = 5
     then
     if num13 > num14
     then
      num0 := 1;
     else
      num0 := 2;
     end if;
    end if;
    case
    when num0 = 1 then
      v_excise := nvl(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    when num0 = 2 then
     v_excise := nvl(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    when num0 = 3 then
     v_excise := nvl(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
     v_excise := v_excise + nvl(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    end case;
   end if;
   item_taxduty := nvl(form_15_continue_sad_com( 'XX_2',v_entry,v_entryitem,v_tariff,1,vtot ),0) + v_excise;      -- DUTY AND EXCISE
   item_taxduty := item_taxduty + nvl(form_15_continue_sad_com( 'SSS_2',v_entry,v_entryitem,v_tariff,1,v_excise ),0); -- GST
   item_taxduty := item_taxduty + nvl(form_15_continue_sad_com( 'TTT_2',v_entry,v_entryitem,v_tariff,1,v_excise ),0); -- LEVY
   fol_rec.SAD_171_ITM_TOTAMT := item_taxduty;
   fol_rec.SAD_172_ITM_TOTMOP := strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );
--   fol_rec.SAD_173_ATT_DOCUMENTS := strang.f15_parameter_range_sad_com( 'A20_SAD', v_entry,v_cust ); -- 20150311
   fol_rec.SAD_173_ATT_DOCUMENTS := 'LINE NO/S '|| strang.f15_parameter_range_sad_com( 'AT_SAD', v_entry,v_cust )||'. ATTACHED DOCUMENTS';
   fol_rec.SAD_174_IITMSUP_VAL1 := form_15_continue_sad_com( 'CPY_1',v_entry,v_entryitem,v_tariff,1,vtot );
   fol_rec.SAD_175_IITMSUP_VAL2 := form_15_continue_sad_com( 'CPY_1_1',v_entry,v_entryitem,v_tariff,1,vtot );
-- TAXES FOR ITEM
-- =================
   fol_rec.NO_OF_ITEM_TAXES := form_15_continue_sad_com( 'CPY_2',v_entry,v_entryitem,v_tariff,1,vtot );
   fol_rec.ITEM_DUTY_TAX_CODE := 'IMD';
   fol_rec.ITEM_DUTY_TAX_BASE_AMOUNT := to_char((trunc(form_15_continue_sad_com( 'TT',v_entry,v_entryitem,v_tariff,1,vtot ))+1),'999999999990.99');
   fol_rec.ITEM_DUTY_TAX_RATE := to_char(form_15_continue_sad_com( 'XX_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_DUTY_TAX_AMOUNT := to_char(form_15_continue_sad_com( 'XX_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_DUTY_TAX_MOP:= strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );

-- EXCISE
   stp := 'FOL [' || v_entryitem || ' '|| v_tariff || ']:E';

 num0 := nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'CPY_3a',v_entry,v_entryitem,v_tariff,1,vtot )), 0);
 if num0 > 0
 then
    v_excise:=0;
  num13:=nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- excise rate tax amount
   num14:=nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- excise by unit tax amount
   if num0 = 4
   then
    if num13 < num14
    then
     num0 := 1;
    else
     num0 := 2;
    end if;
   end if;
   if num0 = 5
   then
    if num13 > num14
    then
     num0 := 1;
    else
     num0 := 2;
    end if;
   end if;
   stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:F';
   case
    when num0 = 1 then
   fol_rec.ITEM_EXCISE_TAX_CODE := 'IXD';
   fol_rec.ITEM_EXCISE_TAX_BASE_AMOUNT := to_char(form_15_continue_sad_com( 'TT_IXD',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_RATE := to_char(form_15_continue_sad_com( 'ZZ_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_EXCISE_TAX_AMOUNT := to_char(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_MOP:= strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );
     v_excise := nvl(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    when num0 = 2 then
   fol_rec.ITEM_EXCISE_TAX_CODE := 'IXD';
   fol_rec.ITEM_EXCISE_TAX_BASE_AMOUNT := to_char(form_15_continue_sad_com( 'TT_IXD_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_RATE := to_char(form_15_continue_sad_com( 'ZZ_1_2',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_EXCISE_TAX_AMOUNT := to_char(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_MOP:= strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );
   v_excise := nvl(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    when num0 = 3 then
   fol_rec.ITEM_EXCISE_TAX_CODE := 'IXD';
   fol_rec.ITEM_EXCISE_TAX_BASE_AMOUNT := to_char(form_15_continue_sad_com( 'TT_IXD',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_RATE := to_char(form_15_continue_sad_com( 'ZZ_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_EXCISE_TAX_AMOUNT := to_char(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_MOP:= strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );
   fol_rec.ITEM_EXCISE1_TAX_CODE := 'IXD';
   fol_rec.ITEM_EXCISE1_TAX_BASE_AMOUNT := to_char(form_15_continue_sad_com( 'TT_IXD_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE1_TAX_RATE := to_char(form_15_continue_sad_com( 'ZZ_1_2',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_EXCISE1_TAX_AMOUNT := to_char(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE1_TAX_MOP:= strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );
     v_excise := nvl(form_15_continue_sad_com( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
     v_excise := v_excise + nvl(form_15_continue_sad_com( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
   end case;
   end if;
-- GST BASE CALC
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G';

num9 := nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'TT',v_entry,v_entryitem,v_tariff,1,vtot )), 0);    -- item value for duty (PGK)
num10:= nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'XX_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- duty for item  (PGK)
num12:= num9 + num10 + v_excise ; -- gst tax base amount and also levy base amount
-- GST
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G1';
 num0 := nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'SSS_2',v_entry,v_entryitem,v_tariff,1,v_excise )), 0);
 if num0 > 0
 then
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G10';
   fol_rec.ITEM_VAT_TAX_CODE := 'GST';
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G11';
   fol_rec.ITEM_VAT_TAX_BASE_AMOUNT := to_char(num12,'999999999990.99');
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G12';
   fol_rec.ITEM_VAT_TAX_RATE := to_char(form_15_continue_sad_com( 'SSS_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G13';
   fol_rec.ITEM_VAT_TAX_AMOUNT := to_char(form_15_continue_sad_com( 'SSS_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G14';
   fol_rec.ITEM_VAT_TAX_MOP:= strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );
 end if;
 -- LEVY
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G2';
  num0 := nvl(websys.glbx.guess_number(form_15_continue_sad_com( 'TTT_2',v_entry,v_entryitem,v_tariff,1,v_excise )), 0);
 if num0 > 0
 then
   fol_rec.ITEM_LEVY_TAX_CODE := 'LVY';
   fol_rec.ITEM_LEVY_TAX_BASE_AMOUNT := to_char(num12,'999999999990.99');
   fol_rec.ITEM_LEVY_TAX_RATE := to_char(form_15_continue_sad_com( 'TTT_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_LEVY_TAX_AMOUNT := to_char(form_15_continue_sad_com( 'TTT_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_LEVY_TAX_MOP:= strang.f15_parameter_range_sad_com( 'A19_SAD', v_entry,v_cust );
 end if;
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G3';
fol_rec.SAD_179_IITMINV_VALC := to_char(form_15_continue_sad_com( 'CPY_3',v_entry,v_entryitem,v_tariff,1,vtot ),'99999990.99');
fol_rec.SAD_180_IITMINV_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );
fol_rec.SAD_181_IITMINV_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999');
fol_rec.SAD_182_IITMINV_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); --JY CHANGE
fol_rec.SAD_183_IITMINV_VALN := to_char(item_inv, '99999990.00');
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:H';
 if item_exf_fc > 0
 then
  fol_rec.SAD_184_IITMEFR_VALC := to_char(item_exf_fc, '99999990.00');   -- [N11] ITEM 1 EXTERNAL FREIGHT IN FOREIGN CURRENCY 184/34          SAD_IITMEFR_VALC             SAD_IITMEFR_VALC
  fol_rec.SAD_185_IITMEFR_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust ); -- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 EXTERNAL FREIGHT 185/35     SAD_IITMEFR_CUR
  fol_rec.SAD_186_IITMEFR_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 EXTERNAL FREIGHT 186/36 SAD_IITMEFR_RAT
  fol_rec.SAD_187_IITMEFR_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust );		     -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 187/-                      SAD_IITMEFR_REF --JY CHANGE
  fol_rec.SAD_188_IITMEFR_VALN := to_char(item_exf, '99999990.00');   -- [N11] ITEM 1 EXTERNAL FREIGHT IN NATIONAL CURR 188/37             SAD_IITMEFR_VALN
 else
    fol_rec.SAD_184_IITMEFR_VALC :=  '0.00';
    fol_rec.SAD_187_IITMEFR_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); --JY CHANGE
    fol_rec.SAD_188_IITMEFR_VALN := '0.00';
 end if;
--
 if item_ins_fc > 0
 then
  fol_rec.SAD_189_IITMINS_VALC := to_char(item_ins_fc, '99999990.00');   -- [N11] ITEM 1 INSURANCE IN FOREIGN CURRENCY 189/38            SAD_IITMINS_VALC
  fol_rec.SAD_190_IITMINS_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust ); -- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INSURANCE 190/39       SAD_IITMINS_CUR
  fol_rec.SAD_191_IITMINS_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INSURANCE 191/40   SAD_IITMINS_RAT
  fol_rec.SAD_192_IITMINS_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 192/-                 SAD_IITMINS_REF --JY CHANGE
  fol_rec.SAD_193_IITMINS_VALN := to_char(item_ins, '99999990.00');   -- [N11] ITEM 1 INSURANCE IN NATIONAL CURR 193/41               SAD_IITMINS_VALN
 else
    fol_rec.SAD_189_IITMINS_VALC := '0.00';
    fol_rec.SAD_192_IITMINS_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); --JY CHANGE
    fol_rec.SAD_193_IITMINS_VALN := '0.00';
 end if;
--
 if item_oc_fc > 0
 then
  fol_rec.SAD_194_IITMOTC_VALC := to_char(item_oc_fc, '99999990.00');   -- [N11] ITEM 1 OTHER COST AMT IN FOREIGN CURRENCY 194/42              SAD_IITMOTC_VALC
  fol_rec.SAD_195_IITMOTC_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 OTHER COST AMT 195/43       SAD_IITMOTC_CUR
  fol_rec.SAD_196_IITMOTC_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 OTHER COST AMT 196/44   SAD_IITMOTC_RAT
  fol_rec.SAD_197_IITMOTC_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 197/-                        SAD_IITMOTC_REF --JY CHANGE
  fol_rec.SAD_198_IITMOTC_VALN := to_char(item_oc, '99999990.00');   -- [N11] ITEM 1 OTHER COST AMT IN NATIONAL CURR 198/45                 SAD_IITMOTC_VALN
 else
    fol_rec.SAD_194_IITMOTC_VALC := '0.00';
    fol_rec.SAD_197_IITMOTC_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); --JY CHANGE
    fol_rec.SAD_198_IITMOTC_VALN := '0.00';
 end if;

--
 if item_inf_fc > 0
 then
  fol_rec.SAD_199_IITMIFR_VALC := to_char(item_inf_fc, '99999990.00');   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN FOREIGN CURRENCY 199/46              SAD_IITMIFR_VALC
  fol_rec.SAD_200_IITMIFR_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INTERNAL FREIGHT AMT 200/47       SAD_IITMIFR_CUR
  fol_rec.SAD_201_IITMIFR_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INTERNAL FREIGHT AMT 201/48   SAD_IITMIFR_RAT
  fol_rec.SAD_202_IITMIFR_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 202/- SAD_IITMIFR_REF --JY CHANGE
  fol_rec.SAD_203_IITMIFR_VALN := to_char(item_inf, '99999990.00');   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN NATIONAL CURR 203/49                 SAD_IITMIFR_VALN
 else
  fol_rec.SAD_199_IITMIFR_VALC := '0.00';	     -- [N11] ITEM 1 INTERNAL FREIGHT IN FOREIGN CURRENCY 199/46                  SAD_IITMIFR_VALC
  fol_rec.SAD_202_IITMIFR_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 202/- SAD_IITMIFR_REF -- JY CHANGE
  fol_rec.SAD_203_IITMIFR_VALN := '0.00';             -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN NATIONAL CURR 203/49                 SAD_IITMIFR_VALN
 end if;
--
 if item_ded_fc > 0
 then
  fol_rec.SAD_204_IITMDED_VALC := to_char(item_ded_fc, '99999990.00');   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN FOREIGN CURRENCY 204/50  SAD_IITMDED_VALC
  fol_rec.SAD_205_IITMDED_CUR := f15_parameter_range_sad_com( 'AF', v_entry, v_cust );-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INTERNAL FREIGHT AMT 205/51       SAD_IITMDED_CUR
  fol_rec.SAD_206_IITMDED_RAT := to_char(f15_parameter_range_sad_com( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INTERNAL FREIGHT AMT 206/52   SAD_IITMDED_RAT
  fol_rec.SAD_207_IITMDED_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 207/- SAD_IITMDED_REF --JY CHANGE
  fol_rec.SAD_208_IITMDED_VALN := to_char(item_ded, '99999990.00');   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN NATIONAL CURR 208/53                 SAD_IITMDED_VALN
 else
 fol_rec.SAD_204_IITMDED_VALC := '0.00';	     -- [N11] ITEM 1 DEDUCTIONS IN FOREIGN CURRENCY 204/50                  SAD_IITMDED_VALC
 fol_rec.SAD_207_IITMDED_REF := '1'; -- f15_parameter_range_sad_com( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 207/-                        SAD_IITMDED_REF -- JY CHANGE
 fol_rec.SAD_208_IITMDED_VALN := '0.00';             -- [N11] DEDUCTIONS AMT IN NATIONAL CURRENCY  208/53                   SAD_IITMDED_VALN
end if;

stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:I';

fol_rec.SAD_209_IITMADD_CST := to_char((item_exf + item_ins + item_oc + item_inf - item_ded), '999999999990.99');
fol_rec.SAD_210_IITMCIF_VALN:= to_char(nvl(num9,0), '999999999990.99');  -- 20130614 ??
--
     insert into strang.sad_following
     values  fol_rec;
   commit;
   end loop;
  commit;
 end refresh_sad_tables;

-- End inline programs
begin

 open c1(v_entry);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   err_msg := 'Customer not found for entry';
   close c1;
   return;
 end if;
 v_cust := c1rec.customer;
 close c1;

 open c2a(v_entry);
 fetch c2a into c2arec;
 if c2a%NOTFOUND
  then
   err_msg := 'Tariff not found for entry';
   close c2a;
   return;
 end if;
-- v_tariff := c2arec.cola;
 close c2a;

 vtot := to_number(form_15_continue_sad_com( 'N',v_entry, c2arec.entry_item,c2arec.cola,1,null ));

if refresh
then
  refresh_sad_tables;
else
  open c4(v_entry);
   fetch c4 into gen_rec;
   if c4%NOTFOUND
   then
     close c4;
     refresh_sad_tables;
   else
     close c4;
   end if;
end if;

 cgotmp2 := 'OT';
 cgotmp := 0;
 open c6(v_entry);  -- contains the number of containers.. if cgotmp is 0 then don't change package type or numbers
 fetch c6 into c6rec;
 if c6%NOTFOUND
  then
   cgotmp := 0;
  else
   cgotmp := c6rec.cgo;
 end if;
 close c6;
 if cgotmp >= 1 then
  cgotmp2 := 'CN';
 end if;

ctr_counter := 0;
  open c5a(v_entry);  -- contains the number of containers.. if cgotmp is 0 then don't change package type or numbers
  fetch c5a into c5arec;
  if c5a%NOTFOUND
   then
    ctr_counter := 0;
   else
    ctr_counter := c5arec.ctrno;
  end if;
  close c5a;

 ss_ref2 := 0;
 open c8(v_entry);
 fetch c8 into c8rec;
 if c8%NOTFOUND
  then
   ss_ref2 := 0;
  else
   ss_ref2 := c8rec.suppno;
 end if;
 close c8;


 exportctyname := null;
 open c7(gen_rec.SAD_036_CTY_EXPCOD,'UNCTYTAB');
 fetch c7 into c7rec;
 if c7%NOTFOUND
  then
   exportctyname := 'Australia';
  else
   exportctyname := c7rec.description;
 end if;
 close c7;


 f_dir := nvl(WEBSYS.GLBX.EXTRACT_MASTER_PARAMETER('MAIL_OUTPUT_DIR'),'C:\TEMP');
-- f_name := 'SAD_' || strang.ent_com.get_entry_no(v_entry,'C')||'_'||strang.ent_com.get_entry_no(v_entry,'X') || '.sad';
-- 20170322 f_name := strang.ent_com.get_entry_no(v_entry,'C')||'_'||strang.ent_com.get_entry_no(v_entry,'X') || '.sad';
-- if length(replace(replace(fol_rec.SAD_156_TRSP_DOC,'/'),' '))<= 8 then
if ss_ref3 is not null then
	f_name := ss_ref3;
  if instr(f_name, ',') > 0
   then
    f_name := substr(f_name, 1, instr(f_name, ',')-1);
  end if;
  if substr(to_char(f_name),1,2) in ('43','45') then
		f_name := substr(to_char(f_name),1,2) || ltrim(substr(f_name,3),'0');
	else
		f_name := to_char(f_name);
	end if;
  f_name := f_name || '.xml';
else
  f_name:= replace(replace(fol_rec.SAD_156_TRSP_DOC,'/'),' ','_') || '.xml';
--else
--  f_name := strang.ent_com.get_entry_no(v_entry,'C')||'_'||strang.ent_com.get_entry_no(v_entry,'X') || '.xml';
end if;

 -- f := utl_file.fopen(f_dir,f_name,'wb',32000);
 dbms_lob.createtemporary(src_blb, TRUE);
 dbms_lob.createtemporary(dst_blb, TRUE);
 sad_file_len := 0;

-- Beginning of XML File Format
v_buf := v_buf || '<?xml version="1.0" encoding="UTF-8" standalone="no"?>';
v_buf := v_buf || '<ASYCUDA>';
v_buf := v_buf || '<Export_release>';
v_buf := v_buf || '<Date_of_exit/>';
v_buf := v_buf || '<Time_of_exit/>';
v_buf := v_buf || '<Actual_office_of_exit_code>';
v_buf := v_buf || '<null/>';
v_buf := v_buf || '</Actual_office_of_exit_code>';
v_buf := v_buf || '<Actual_office_of_exit_name>';
v_buf := v_buf || '<null/>';
v_buf := v_buf || '</Actual_office_of_exit_name>';
v_buf := v_buf || '<Exit_reference>';
v_buf := v_buf || '<null/>';
v_buf := v_buf || '</Exit_reference>';
v_buf := v_buf || '<Comments>';
v_buf := v_buf || '<null/>';
v_buf := v_buf || '</Comments>';
v_buf := v_buf || '</Export_release>';
v_buf := v_buf || '<Assessment_notice>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '<Item_tax_total/>';
v_buf := v_buf || '</Assessment_notice>';
v_buf := v_buf || '<Global_taxes>';
v_buf := v_buf || '<Global_tax_item/>';
v_buf := v_buf || '<Global_tax_item/>';
v_buf := v_buf || '<Global_tax_item/>';
v_buf := v_buf || '<Global_tax_item/>';
v_buf := v_buf || '<Global_tax_item/>';
v_buf := v_buf || '<Global_tax_item/>';
v_buf := v_buf || '<Global_tax_item/>';
v_buf := v_buf || '<Global_tax_item/>';
v_buf := v_buf || '</Global_taxes>';


-- PROPERTY  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Property>';
		v_buf := v_buf || '<Sad_flow>I</Sad_flow>'; --#
		v_buf := v_buf || '<Forms>';
		v_buf := v_buf || '<Number_of_the_form>1</Number_of_the_form>'; --#
		v_buf := v_buf || '<Total_number_of_forms>1</Total_number_of_forms>';  --#
		v_buf := v_buf || '</Forms>';
		v_buf := v_buf || '<Nbers>';
		v_buf := v_buf || '<Number_of_loading_lists/>';
		v_buf := v_buf || '<Total_number_of_items>'|| add_field(gen_rec.SAD_028_ITM_TOTAL, 3) ||'</Total_number_of_items>';
  	  if cgotmp < 1 then
		v_buf := v_buf || '<Total_number_of_packages>'|| add_field(gen_rec.SAD_029_PACK_TOTAL, 6) ||'</Total_number_of_packages>';
          else
		v_buf := v_buf || '<Total_number_of_packages>'|| add_field(to_char(cgotmp,'99999'), 6) ||'</Total_number_of_packages>';

          end if;
		v_buf := v_buf || '</Nbers>';
		v_buf := v_buf || '<Place_of_declaration>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Place_of_declaration>';
		v_buf := v_buf || '<Date_of_declaration/>';
		v_buf := v_buf || '<Selected_page>1</Selected_page>'; --#
	v_buf := v_buf || '</Property>';

-- IDENTIFICATION  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Identification>';
		v_buf := v_buf || '<Office_segment>';
		v_buf := v_buf || '<Customs_clearance_office_code>'|| add_field(gen_rec.SAD_015_CUO_COD, 3) ||'</Customs_clearance_office_code>';
		v_buf := v_buf || '<Customs_Clearance_office_name>'|| add_field(STRANG.f_getLovColumn( 'UNCUOTAB', 'DESCRIPTION', gen_rec.SAD_015_CUO_COD ), 17) ||'</Customs_Clearance_office_name>'; --#
		v_buf := v_buf || '</Office_segment>';
		v_buf := v_buf || '<Type>';
		v_buf := v_buf || '<Type_of_declaration>'|| add_field(gen_rec.SAD_019_TYP_DEC, 3) ||'</Type_of_declaration>';
		v_buf := v_buf || '<Declaration_gen_procedure_code>'|| add_field(gen_rec.SAD_020_TYP_PROC, 1) ||'</Declaration_gen_procedure_code>';
		v_buf := v_buf || '<Type_of_transit_document>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Type_of_transit_document>';
		v_buf := v_buf || '</Type>';
		v_buf := v_buf || '<Manifest_reference_number>'|| add_field(to_char(sysdate, 'YYYY')||' '||gen_rec.SAD_023_MANIF_NBER, 28) ||'</Manifest_reference_number>';
		v_buf := v_buf || '<Registration>';
		v_buf := v_buf || '<Serial_number>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Serial_number>';
		v_buf := v_buf || '<Number/>';
		v_buf := v_buf || '<Date/>';
		v_buf := v_buf || '</Registration>';
		v_buf := v_buf || '<Assessment>';
		v_buf := v_buf || '<Serial_number>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Serial_number>';
		v_buf := v_buf || '<Number/>';
		v_buf := v_buf || '<Date/>';
		v_buf := v_buf || '</Assessment>';
		v_buf := v_buf || '<receipt>';
		v_buf := v_buf || '<Serial_number>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Serial_number>';
		v_buf := v_buf || '<Number/>';
		v_buf := v_buf || '<Date/>';
		v_buf := v_buf || '</receipt>';
	v_buf := v_buf || '</Identification>';

-- TRADERS  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Traders>';
		v_buf := v_buf || '<Exporter>';
		v_buf := v_buf || '<Exporter_code/>';
		v_buf := v_buf || '<Exporter_name>'|| add_field(ss_ref1, 50) || ' ';
                if ss_ref2 > 1 then
  			v_buf := v_buf || '- VARIOUS SUPPLIERS AS PER INVOICES';
		end if;
		v_buf := v_buf || ' C/- OK TEDI MINING LTD ';
		v_buf := v_buf || '936 NUDGEE ROAD ';  --#
		v_buf := v_buf || 'NORTHGATE QLD 4013 ';  --#
		v_buf := v_buf || 'AUSTRALIA</Exporter_name>';  --#
		v_buf := v_buf || '</Exporter>';
		v_buf := v_buf || '<Consignee>';
		v_buf := v_buf || '<Consignee_code>'|| add_field(gen_rec.SAD_030_CONSIGNEE, 17) ||'</Consignee_code>';
		v_buf := v_buf || '<Consignee_name>OK Tedi Mining Ltd PO Box 1, Tabubil Dakon Rd, Tabubil Western, PNG ';
		v_buf := v_buf || 'Vibbie.Pital@oktedi.com</Consignee_name>';
		v_buf := v_buf || '</Consignee>';
		v_buf := v_buf || '<Financial>';
		v_buf := v_buf || '<Financial_code>'|| add_field('500000321', 17) ||'</Financial_code>';
		v_buf := v_buf || '<Financial_name>OK Tedi Mining Ltd PO Box 1, Tabubil Dakon Rd, Tabubil Western, PNG ';
		v_buf := v_buf || 'Vibbie.Pital@oktedi.com</Financial_name>';
		v_buf := v_buf || '</Financial>';
	v_buf := v_buf || '</Traders>';

-- DECLARANT  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Declarant>';
		v_buf := v_buf || '<Declarant_code>'|| add_field('500000321', 17) ||'</Declarant_code>';
		v_buf := v_buf || '<Declarant_name>OK TEDI MINING LTD ';  --#
		v_buf := v_buf || 'PO BOX 1, TABUBIL. WP ';  --#
		v_buf := v_buf || 'DAKON ROAD, TABUBIL</Declarant_name>';  --#
		v_buf := v_buf || '<Reference>';
		if substr(to_char(ss_ref),1,2) in ('45','43') then
		  v_buf := v_buf || '<Number>'|| substr(to_char(ss_ref),1,2) || add_field(ltrim(substr(to_char(ss_ref),3),'0'), 50) ||'</Number>'; --#
		else
		  v_buf := v_buf || '<Number>'|| add_field(to_char(ss_ref), 50) ||'</Number>'; --#
		end if;
		v_buf := v_buf || '</Reference>';
	v_buf := v_buf || '</Declarant>';

-- GENERAL INFORMATION  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<General_information>';
		v_buf := v_buf || '<Country>';
		v_buf := v_buf || '<Country_first_destination>'|| add_field(gen_rec.SAD_032_CTY_1DLP, 3) ||'</Country_first_destination>';
		v_buf := v_buf || '<Trading_country>'|| add_field(gen_rec.SAD_033_TRA_CTY, 3) ||'</Trading_country>';
		v_buf := v_buf || '<Export>';
		v_buf := v_buf || '<Export_country_code>'|| add_field(gen_rec.SAD_036_CTY_EXPCOD, 3) ||'</Export_country_code>';
		v_buf := v_buf || '<Export_country_name>'|| add_field(exportctyname,25) ||'</Export_country_name>'; --#
		v_buf := v_buf || '<Export_country_region/>';
		v_buf := v_buf || '</Export>';
		v_buf := v_buf || '<Destination>';
		v_buf := v_buf || '<Destination_country_code>'|| add_field(gen_rec.SAD_038_CTY_DESTCOD, 3) ||'</Destination_country_code>';
		v_buf := v_buf || '<Destination_country_name>Papua New Guinea</Destination_country_name>'; --#
		v_buf := v_buf || '<Destination_country_region/>';
		v_buf := v_buf || '</Destination>';
		v_buf := v_buf || '<Country_of_origin_name>'|| add_field(exportctyname,25) ||'</Country_of_origin_name>'; --#
		v_buf := v_buf || '</Country>';
		v_buf := v_buf || '<Value_details>'|| add_field(gen_rec.SAD_034_VAL_DETAILS, 15) ||'</Value_details>'; --#
		v_buf := v_buf || '<CAP/>';
		v_buf := v_buf || '<Additional_information>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Additional_information>';
		v_buf := v_buf || '<Comments_free_text>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Comments_free_text>';
	v_buf := v_buf || '</General_information>';

-- TRANSPORT  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Transport>';
		v_buf := v_buf || '<Means_of_transport>';
		v_buf := v_buf || '<Departure_arrival_information>';
		v_buf := v_buf || '<Identity>'|| add_field(gen_rec.SAD_040_TRSP_IDDEPAR, 26) ||'</Identity>';
		v_buf := v_buf || '<Nationality>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Nationality>';
		v_buf := v_buf || '</Departure_arrival_information>';
		v_buf := v_buf || '<Border_information>';
		v_buf := v_buf || '<Identity/>';
		v_buf := v_buf || '<Nationality/>';
		v_buf := v_buf || '<Mode>'|| add_field(gen_rec.SAD_052_MOT_BORD, 1) ||'</Mode>';
		v_buf := v_buf || '</Border_information>';
		v_buf := v_buf || '<Inland_mode_of_transport>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Inland_mode_of_transport>';
		v_buf := v_buf || '</Means_of_transport>';
		v_buf := v_buf || '<Container_flag>'|| add_field(gen_rec.SAD_042_CTNR_FLAG, 5) ||'</Container_flag>'; --# true or false
		v_buf := v_buf || '<Delivery_terms>';
		v_buf := v_buf || '<Code>'|| add_field(gen_rec.SAD_043_TOD_COD, 3) ||'</Code>';
		v_buf := v_buf || '<Place>'|| add_field(gen_rec.SAD_044_TOD_NAM, 17) ||'</Place>';  --# check should be PORT MORESBY
		v_buf := v_buf || '<Situation/>';
		v_buf := v_buf || '</Delivery_terms>';
		v_buf := v_buf || '<Border_office>';
		v_buf := v_buf || '<Code>'|| add_field(gen_rec.SAD_056_CUO_BORD, 5) ||'</Code>';
		v_buf := v_buf || '<Name>'|| add_field(STRANG.f_getLovColumn( 'UNCUOTAB', 'DESCRIPTION', gen_rec.SAD_056_CUO_BORD ), 17) ||'</Name>'; --#
		v_buf := v_buf || '</Border_office>';
		v_buf := v_buf || '<Place_of_loading>';
		v_buf := v_buf || '<Code>'|| add_field(gen_rec.SAD_054_LOP_COD, 5) ||'</Code>'; --#
		v_buf := v_buf || '<Name>'|| add_field(INITCAP(STRANG.f_getLovColumn( 'UNLOCTAB', 'DESCRIPTION', gen_rec.SAD_054_LOP_COD )), 17) ||'</Name>'; --#
		v_buf := v_buf || '<Country>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Country>';
		v_buf := v_buf || '</Place_of_loading>';
		v_buf := v_buf || '<Location_of_goods>'|| add_field(gen_rec.SAD_057_LOC_GOODS, 17) ||'</Location_of_goods>';
	v_buf := v_buf || '</Transport>';


-- FINANCIAL  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Financial>';
		v_buf := v_buf || '<Financial_transaction>';
		v_buf := v_buf || '<code1/>';
		v_buf := v_buf || '<code2/>';
		v_buf := v_buf || '</Financial_transaction>';
		v_buf := v_buf || '<Bank>';
		v_buf := v_buf || '<Code>'|| add_field(gen_rec.SAD_058_BNK_COD,11) ||'</Code>';
		v_buf := v_buf || '<Name>Bank South Pacific</Name>'; --#
		v_buf := v_buf || '<Branch>'|| add_field(gen_rec.SAD_059_BNK_BRA, 17) ||'</Branch>';
		v_buf := v_buf || '<Reference>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Reference>';
		v_buf := v_buf || '</Bank>';
		v_buf := v_buf || '<Terms>';
		v_buf := v_buf || '<Code>'|| add_field(gen_rec.SAD_055_TOP_COD, 3) ||'</Code>';
		v_buf := v_buf || '<Description>Other terms of payments</Description>'; --#
		v_buf := v_buf || '</Terms>';
		v_buf := v_buf || '<Total_invoice/>';
		v_buf := v_buf || '<Deffered_payment_reference>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Deffered_payment_reference>';
		v_buf := v_buf || '<Mode_of_payment>CASH</Mode_of_payment>'; --#
		v_buf := v_buf || '<Amounts>';
		v_buf := v_buf || '<Total_manual_taxes/>';
		v_buf := v_buf || '<Global_taxes>'|| add_field(gen_rec.SAD_073_TOT_FEES, 15)||'</Global_taxes>'; --# 30.00
		v_buf := v_buf || '<Totals_taxes>'|| add_field(gen_rec.SAD_074_TOTAL_TAXES, 15) ||'</Totals_taxes>'; --# 30.00
		v_buf := v_buf || '</Amounts>';
		v_buf := v_buf || '<Guarantee>';
		v_buf := v_buf || '<Name>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Name>';
		v_buf := v_buf || '<Amount>0.0</Amount>';
		v_buf := v_buf || '<Date/>';
		v_buf := v_buf || '<Excluded_country>';
		v_buf := v_buf || '<Code>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Code>';
		v_buf := v_buf || '<Name>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Name>';
		v_buf := v_buf || '</Excluded_country>';
		v_buf := v_buf || '</Guarantee>';
	v_buf := v_buf || '</Financial>';

-- WAREHOUSE  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Warehouse>';
		v_buf := v_buf || '<Identification>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Identification>';
		v_buf := v_buf || '<Delay/>';
	v_buf := v_buf || '</Warehouse>';

-- TRANSIT  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Transit>';
		v_buf := v_buf || '<Principal>';
		v_buf := v_buf || '<Code>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Code>';
		v_buf := v_buf || '<Name>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Name>';
		v_buf := v_buf || '<Representative>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Representative>';
		v_buf := v_buf || '</Principal>';
		v_buf := v_buf || '<Signature>';
		v_buf := v_buf || '<Place>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Place>';
		v_buf := v_buf || '<Date/>';
		v_buf := v_buf || '</Signature>';
		v_buf := v_buf || '<Destination>';
		v_buf := v_buf || '<Office>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Office>';
		v_buf := v_buf || '<Country>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Country>';
		v_buf := v_buf || '</Destination>';
		v_buf := v_buf || '<Seals>';
		v_buf := v_buf || '<Number/>';
		v_buf := v_buf || '<Identity>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Identity>';
		v_buf := v_buf || '</Seals>';
		v_buf := v_buf || '<Result_of_control/>';
		v_buf := v_buf || '<Time_limit/>';
		v_buf := v_buf || '<Officer_name>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Officer_name>';
	v_buf := v_buf || '</Transit>';

-- VALUATION  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Valuation>';
		v_buf := v_buf || '<Calculation_working_mode>0</Calculation_working_mode>'; --#
		v_buf := v_buf || '<Weight>';
		v_buf := v_buf || '<Gross_weight/>';
		v_buf := v_buf || '</Weight>';
		v_buf := v_buf || '<Total_cost>'|| add_field(gen_rec.SAD_111_ITOTADD_CST, 15) ||'</Total_cost>';  -- in Kina 9958.30
		v_buf := v_buf || '<Total_CIF>'|| add_field(gen_rec.SAD_112_ICIF_VALN, 15) ||'</Total_CIF>';  -- invoice+total_costs in Kina 170003.65
		v_buf := v_buf || '<Gs_Invoice>';
		v_buf := v_buf || '<Amount_national_currency></Amount_national_currency>'; --# 160045.35
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(gen_rec.SAD_081_ITOTINV_VALC, 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(gen_rec.SAD_082_ITOTINV_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>'; --# No foreign currency
		v_buf := v_buf || '<Currency_rate>0.3065</Currency_rate>'; --#0.3065
		v_buf := v_buf || '</Gs_Invoice>';
		v_buf := v_buf || '<Gs_external_freight>';
		v_buf := v_buf || '<Amount_national_currency></Amount_national_currency>'; --# 0.0
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(gen_rec.SAD_087_ITOTEFR_CUR, 3) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(gen_rec.SAD_087_ITOTEFR_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>'; --# No foreign currency
		v_buf := v_buf || '<Currency_rate></Currency_rate>'; --# 0
		v_buf := v_buf || '</Gs_external_freight>';
		v_buf := v_buf || '<Gs_internal_freight>';
		v_buf := v_buf || '<Amount_national_currency></Amount_national_currency>'; --# 0.0
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(gen_rec.SAD_101_ITOTIFR_VALC, 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(gen_rec.SAD_102_ITOTIFR_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>'; --# No foreign currency
		v_buf := v_buf || '<Currency_rate></Currency_rate>'; --# 0
		v_buf := v_buf || '</Gs_internal_freight>';
		v_buf := v_buf || '<Gs_insurance>';
		v_buf := v_buf || '<Amount_national_currency></Amount_national_currency>'; --# 614.25
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(gen_rec.SAD_091_ITOTINS_VALC, 11) ||'</Amount_foreign_currency>'; --# 245.27 CHECK
		v_buf := v_buf || '<Currency_code>'|| add_field(gen_rec.SAD_092_ITOTINS_CUR, 3) ||'</Currency_code>'; --#AUD
		v_buf := v_buf || '<Currency_name></Currency_name>'; --# No foreign currency
		v_buf := v_buf || '<Currency_rate></Currency_rate>'; --# 0.3993
		v_buf := v_buf || '</Gs_insurance>';
		v_buf := v_buf || '<Gs_other_cost>';
		v_buf := v_buf || '<Amount_national_currency></Amount_national_currency>'; --# 9344.05
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(gen_rec.SAD_096_ITOTOTC_VALC, 11) ||'</Amount_foreign_currency>'; --# 3731.08
		v_buf := v_buf || '<Currency_code>'|| add_field(gen_rec.SAD_097_ITOTOTC_CUR, 3) ||'</Currency_code>'; --# AUD
		v_buf := v_buf || '<Currency_name></Currency_name>'; --# No foreign currency
		v_buf := v_buf || '<Currency_rate></Currency_rate>'; --# 0.3993
		v_buf := v_buf || '</Gs_other_cost>';
		v_buf := v_buf || '<Gs_deduction>';
		v_buf := v_buf || '<Amount_national_currency></Amount_national_currency>'; --# 0.0
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(gen_rec.SAD_106_ITOTDED_VALC, 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(gen_rec.SAD_107_ITOTDED_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>'; --# No foreign currency
		v_buf := v_buf || '<Currency_rate></Currency_rate>'; --# 0
		v_buf := v_buf || '</Gs_deduction>';
		v_buf := v_buf || '<Total>';
		v_buf := v_buf || '<Total_invoice>'|| add_field(gen_rec.SAD_049_TOT_INVOICED, 11) ||'</Total_invoice>';  --49053.9
		v_buf := v_buf || '<Total_weight></Total_weight>'; --# total weight + tare 20022.0
		v_buf := v_buf || '</Total>';
	v_buf := v_buf || '</Valuation>';

-- CONTAINER  (ASYCUDA WORLD) - LOOP
-- =====================================================================================
if ctr_counter > 0 then
  for fol_rec in c3(v_entry) loop
   ctr_itm(fol_rec.SAD_131_ITM_NBER) := 0;
  end loop;
  for c5rec in c5(v_entry) loop
   t_weight := trunc(to_number(c5rec.gross_weight)/to_number(gen_rec.SAD_028_ITM_TOTAL),0);
          tr_weight := to_number(c5rec.gross_weight)- (to_number(gen_rec.SAD_028_ITM_TOTAL) * t_weight);
  for fol_rec in c3(v_entry) loop
--          p_weight := trunc((to_number(fol_rec.SAD_146_GROSS_MASS) /ctr_counter),0);
--          pr_weight := remainder(to_number(fol_rec.SAD_146_GROSS_MASS), ctr_counter);
          p_weight := trunc((to_number(c5rec.packages_weight) /to_number(gen_rec.SAD_028_ITM_TOTAL)),0);
          pr_weight := to_number(c5rec.packages_weight)- (to_number(gen_rec.SAD_028_ITM_TOTAL) * p_weight);
    v_buf := v_buf || '<Container>';
		  v_buf := v_buf || '<Item_Number>'|| fol_rec.SAD_131_ITM_NBER ||'</Item_Number>';
		  v_buf := v_buf || '<Container_identity>'|| c5rec.movement_no ||'</Container_identity>';
		  v_buf := v_buf || '<Container_type>'|| c5rec.iso_container_type ||'</Container_type>';
		  v_buf := v_buf || '<Empty_full_indicator>'|| c5rec.empty_full ||'</Empty_full_indicator>'; --# FCL
/*
                  if fol_rec.SAD_131_ITM_NBER = '1' then
  		  	v_buf := v_buf || '<Gross_weight>'|| to_char((t_weight + tr_weight),'999999999.999') ||'</Gross_weight>';
                  else
  		  	v_buf := v_buf || '<Gross_weight>'|| to_char(t_weight,'999999999.999') ||'</Gross_weight>';
                  end if;
*/
 -- only item 1 has tare
                  if fol_rec.SAD_131_ITM_NBER = '1' then
  		  	v_buf := v_buf || '<Gross_weight>'|| to_char(c5rec.gross_weight,'999999999.999') ||'</Gross_weight>';
                  else
  		  	v_buf := v_buf || '<Gross_weight>0</Gross_weight>';
                  end if;


		  v_buf := v_buf || '<Goods_description>'|| c5rec.container_type ||'</Goods_description>';
   		  if cgotmp < 1 then
			  v_buf := v_buf || '<Packages_type>'|| add_field(fol_rec.SAD_143_PACK_KINDCOD, 17)||'</Packages_type>';
		  else
			  v_buf := v_buf || '<Packages_type>'|| add_field(cgotmp2, 17)||'</Packages_type>';
		  end if;
/*  -- only item 1 has weight
                  if fol_rec.SAD_131_ITM_NBER = '1' then
			  v_buf := v_buf || '<Packages_number>1</Packages_number>';  -- change to 1
			  v_buf := v_buf || '<Packages_weight>'||add_field(to_char(c5rec.packages_weight,'99999'), 6) ||'</Packages_weight>';
	          else
			  v_buf := v_buf || '<Packages_number>0</Packages_number>';
			  v_buf := v_buf || '<Packages_weight>0</Packages_weight>';
	          end if;

*/
                  if fol_rec.SAD_131_ITM_NBER = '1' then
			  v_buf := v_buf || '<Packages_number>1</Packages_number>';  -- change to 1
			  v_buf := v_buf || '<Packages_weight>'|| to_char((p_weight+pr_weight),'99999999.999') ||'</Packages_weight>';
	          ctr_itm(fol_rec.SAD_131_ITM_NBER) := ctr_itm(fol_rec.SAD_131_ITM_NBER) + p_weight + pr_weight;
            else
			  v_buf := v_buf || '<Packages_number>0</Packages_number>';
			  v_buf := v_buf || '<Packages_weight>'|| to_char(p_weight,'99999999.999') ||'</Packages_weight>';
	          ctr_itm(fol_rec.SAD_131_ITM_NBER) := ctr_itm(fol_rec.SAD_131_ITM_NBER) + p_weight;
	          end if;
    v_buf := v_buf || '</Container>';
    if length(v_buf) > chk_bfr
     then
      dbms_lob.writeappend(src_blb, length(v_buf), utl_raw.cast_to_raw(v_buf));
      sad_file_len := sad_file_len + length(v_buf);
      v_buf := null;
    end if;

end loop;
end loop;
else
  for fol_rec in c3(v_entry) loop
   ctr_itm(fol_rec.SAD_131_ITM_NBER) := fol_rec.SAD_154_NET_MASS;
  end loop;

    v_buf := v_buf || '<Container>';
    v_buf := v_buf || '</Container>';
end if;

/*
-- SUPPLIER_DOCUMENTS  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Supplier_documents>';
		v_buf := v_buf || '<Invoice_supplier_name>'|| add_field(gen_rec.SAD_115_EXP_NAM, 35) ||'</Invoice_supplier_name>';
		v_buf := v_buf || '<Invoice_supplier_country>'|| add_field(gen_rec.SAD_117_EXP_ADD2, 35) ||'</Invoice_supplier_country>';
		v_buf := v_buf || '<Invoice_supplier_city>'|| add_field(gen_rec.SAD_118_EXP_CITY, 35) ||'</Invoice_supplier_city>';
		v_buf := v_buf || '<Invoice_supplier_street>'|| add_field(gen_rec.SAD_116_EXP_ADD1, 35) ||'</Invoice_supplier_street>';
		v_buf := v_buf || '<Invoice_supplier_telephone>'|| '' ||'</Invoice_supplier_telephone>';
		v_buf := v_buf || '<Invoice_supplier_fax>'|| '' ||'</Invoice_supplier_fax>';
		v_buf := v_buf || '<Invoice_supplier_zip_code>'|| add_field(gen_rec.SAD_119_EXP_ZIP, 35) ||'</Invoice_supplier_zip_code>';
		v_buf := v_buf || '<Invoice_supplier_email_address>'|| '' ||'</Invoice_supplier_email_address>';
	v_buf := v_buf || '</Supplier_documents>';

-- PREVIOUS_DECLARATIONS  (ASYCUDA WORLD)
-- =====================================================================================
	v_buf := v_buf || '<Previous_declarations>';
    v_buf := v_buf || '<Prev_decl>';
      v_buf := v_buf || '<Prev_decl_office_code>'|| '' ||'</Prev_decl_office_code>';
      v_buf := v_buf || '<Prev_decl_reg_year>'|| '' ||'</Prev_decl_reg_year>';
      v_buf := v_buf || '<Prev_decl_reg_serial>'|| '' ||'</Prev_decl_reg_serial>';
      v_buf := v_buf || '<Prev_decl_reg_number>'|| '' ||'</Prev_decl_reg_number>';
      v_buf := v_buf || '<Prev_decl_item_number>'|| '' ||'</Prev_decl_item_number>';
      v_buf := v_buf || '<Prev_decl_HS_code>'|| '' ||'</Prev_decl_HS_code>';
      v_buf := v_buf || '<Prev_decl_HS_prec>'|| '' ||'</Prev_decl_HS_prec>';
      v_buf := v_buf || '<Prev_decl_country_origin>'|| '' ||'</Prev_decl_country_origin>';
      v_buf := v_buf || '<Prev_decl_number_packages>'|| '' ||'</Prev_decl_number_packages>';
      v_buf := v_buf || '<Prev_decl_weight>'|| '' ||'</Prev_decl_weight>';
      v_buf := v_buf || '<Prev_decl_supp_quantity>'|| '' ||'</Prev_decl_supp_quantity>';
      v_buf := v_buf || '<Prev_decl_ref_value>'|| '' ||'</Prev_decl_ref_value>';
      v_buf := v_buf || '<Prev_decl_current_item>'|| '' ||'</Prev_decl_current_item>';
      v_buf := v_buf || '<Prev_decl_number_packages_written_off>'|| '' ||'</Prev_decl_number_packages_written_off>';
      v_buf := v_buf || '<Prev_decl_weight_written_off>'|| '' ||'</Prev_decl_weight_written_off>';
      v_buf := v_buf || '<Prev_decl_supp_quantiity_written_off>'|| '' ||'</Prev_decl_supp_quantiity_written_off>';
      v_buf := v_buf || '<Prev_decl_value_written_off>'|| '' ||'</Prev_decl_value_written_off>';
    v_buf := v_buf || '</Prev_decl>';
	v_buf := v_buf || '</Previous_declarations>';

-- LOADING_LIST  (ASYCUDA WORLD) - LOOP
-- =====================================================================================
	v_buf := v_buf || '<Loading_list>';
    v_buf := v_buf || '<Line>';
      v_buf := v_buf || '<Item_number>'|| '' ||'</Item_number>';
      v_buf := v_buf || '<Vehicle>'|| '' ||'</Vehicle>';
      v_buf := v_buf || '<Container>'|| '' ||'</Container>';
      v_buf := v_buf || '<Packaging_code>'|| '' ||'</Packaging_code>';
      v_buf := v_buf || '<Packaging_description>'|| '' ||'</Packaging_description>';
      v_buf := v_buf || '<Packages>'|| '' ||'</Packages>';
      v_buf := v_buf || '<Goods_description>'|| '' ||'</Goods_description>';
      v_buf := v_buf || '<Gross_weight>'|| '' ||'</Gross_weight>';
    v_buf := v_buf || '</Line>';
	v_buf := v_buf || '</Loading_list>';
*/
-- Write buffer into source BLOB
if length(v_buf) > 0
 then
  dbms_lob.writeappend(src_blb, length(v_buf), utl_raw.cast_to_raw(v_buf));
end if;
sad_file_len := sad_file_len + length(v_buf);
v_buf := null;
-- websys.glbx.dbg('Generate Sad Error 1 [' || stp || '] ' ||sqlerrm);

-- ITEM  (ASYCUDA WORLD) - LOOP
-- =====================================================================================
 firstitem := true;
 for fol_rec in c3(v_entry) loop
	v_buf := v_buf || '<Item>';
--v_buf := v_buf || '<Attached_documents>';
--v_buf := v_buf || '<Attached_document_code>ECL</Attached_document_code>';
--v_buf := v_buf || '<Attached_document_name>Exemption Cerficate/Letters</Attached_document_name>';
--v_buf := v_buf || '<Attached_document_reference>PA/TIN: S.21(1)(d)</Attached_document_reference>';
--v_buf := v_buf || '<Attached_document_date>3/16/16</Attached_document_date>';
--v_buf := v_buf || '</Attached_documents>';
	v_buf := v_buf || '<Packages>';
	if firstitem then
	  if cgotmp < 1 then
        	v_buf := v_buf || '<Number_of_packages>'|| add_field(fol_rec.SAD_142_PACK_NBER, 6) ||'</Number_of_packages>';
          else
        	v_buf := v_buf || '<Number_of_packages>'|| add_field(to_char(cgotmp,'99999'), 6) ||'</Number_of_packages>';
          end if;
          firstitem := false;
        else
      	v_buf := v_buf || '<Number_of_packages>'|| add_field('0', 6) ||'</Number_of_packages>';
        end if;


	v_buf := v_buf || '<Marks1_of_packages>'|| add_field(fol_rec.SAD_132_PACK_MARK1, 35)||'</Marks1_of_packages>';
	v_buf := v_buf || '<Marks2_of_packages>'|| add_field(fol_rec.SAD_133_PACK_MARK2, 35) ||'</Marks2_of_packages>';
--        if cgotmp < 1 then
--   	v_buf := v_buf || '<Kind_of_packages_code>'|| add_field(fol_rec.SAD_143_PACK_KINDCOD, 17) ||'</Kind_of_packages_code>';
--   	else
   	v_buf := v_buf || '<Kind_of_packages_code>'|| add_field(cgotmp2, 17) ||'</Kind_of_packages_code>';
--   	end if;
	if cgotmp >= 1 then
  	v_buf := v_buf || '<Kind_of_packages_name>cont., not otherwise specified</Kind_of_packages_name>'; --# Other type of packages
	else
  	v_buf := v_buf || '<Kind_of_packages_name>Other type of packages</Kind_of_packages_name>'; --# Other type of packages
	end if;

	v_buf := v_buf || '</Packages>';
	v_buf := v_buf || '<IncoTerms>';
	v_buf := v_buf || '<Code>'|| add_field(gen_rec.SAD_043_TOD_COD, 3) ||'</Code>';
	v_buf := v_buf || '<Place>'|| add_field(gen_rec.SAD_044_TOD_NAM, 17) ||'</Place>';
	v_buf := v_buf || '</IncoTerms>';
	v_buf := v_buf || '<Tarification>';
	v_buf := v_buf || '<Tarification_data>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Tarification_data>';
	v_buf := v_buf || '<HScode>';
	v_buf := v_buf || '<Commodity_code>'|| add_field(fol_rec.SAD_134_HS_COD, 8) ||'</Commodity_code>';
	v_buf := v_buf || '<Precision_1>000</Precision_1>';
--	v_buf := v_buf || '<Precision_1>'|| add_field(nvl(fol_rec.SAD_135_HSPREC_COD,'000'), 3) ||'</Precision_1>';
	v_buf := v_buf || '<Precision_2>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Precision_2>';
	v_buf := v_buf || '<Precision_3>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Precision_3>';
	v_buf := v_buf || '<Precision_4>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Precision_4>';
	v_buf := v_buf || '</HScode>';
	v_buf := v_buf || '<Preference_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Preference_code>';
	v_buf := v_buf || '<Extended_customs_procedure>'|| add_field(fol_rec.SAD_152_EXTD_PROC, 4) ||'</Extended_customs_procedure>';
	v_buf := v_buf || '<National_customs_procedure>'|| add_field(fol_rec.SAD_153_NAT_PROC, 3) ||'</National_customs_procedure>';
	v_buf := v_buf || '<Quota_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Quota_code>';
	v_buf := v_buf || '<Quota>';
	v_buf := v_buf || '<QuotaCode/>';
	v_buf := v_buf || '<QuotaId/>';
	v_buf := v_buf || '<QuotaItem>';
	v_buf := v_buf || '<ItmNbr/>';
	v_buf := v_buf || '</QuotaItem>';
	v_buf := v_buf || '</Quota>';
	v_buf := v_buf || '<Supplementary_unit>';
	v_buf := v_buf || '<Suppplementary_unit_code></Suppplementary_unit_code>'; --#
	v_buf := v_buf || '<Suppplementary_unit_name></Suppplementary_unit_name>'; --#
    open c7a('TARIFF', fol_rec.SAD_134_HS_COD);
    fetch c7a into c7arec;
    close c7a;
    if nvl(c7arec.cola, 'OTHER') in ('TONNE','TNE')
     then
      v_buf := v_buf || '<Suppplementary_unit_quantity>'|| add_field(ctr_itm(fol_rec.SAD_131_ITM_NBER)/1000, 11) ||'</Suppplementary_unit_quantity>';
    elsif nvl(c7arec.cola, 'OTHER') in ('KGM','KG')
     then
      v_buf := v_buf || '<Suppplementary_unit_quantity>'|| add_field(ctr_itm(fol_rec.SAD_131_ITM_NBER), 11) ||'</Suppplementary_unit_quantity>';
    else
      v_buf := v_buf || '<Suppplementary_unit_quantity>'|| add_field(fol_rec.SAD_157_SUPP_UNITS, 11) ||'</Suppplementary_unit_quantity>';
    end if;
	v_buf := v_buf || '</Supplementary_unit>';
	v_buf := v_buf || '<Supplementary_unit>';
	v_buf := v_buf || '<Suppplementary_unit_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Suppplementary_unit_code>';
	v_buf := v_buf || '<Suppplementary_unit_name/>';
	v_buf := v_buf || '<Suppplementary_unit_quantity/>';
	v_buf := v_buf || '</Supplementary_unit>';
	v_buf := v_buf || '<Supplementary_unit>';
	v_buf := v_buf || '<Suppplementary_unit_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Suppplementary_unit_code>';
	v_buf := v_buf || '<Suppplementary_unit_name/>';
	v_buf := v_buf || '<Suppplementary_unit_quantity/>';
	v_buf := v_buf || '</Supplementary_unit>';
	v_buf := v_buf || '<Item_price>'|| add_field(to_char(fol_rec.SAD_179_IITMINV_VALC,'99999990.99'), 11) ||'</Item_price>';
	v_buf := v_buf || '<Valuation_method_code/>';
	v_buf := v_buf || '<Value_item>'|| add_field(fol_rec.SAD_159_VAL_METHOD,56) ||'</Value_item>';  --# in Kina
	v_buf := v_buf || '<Attached_doc_item/>';
	v_buf := v_buf || '<A.I._code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</A.I._code>';
	v_buf := v_buf || '</Tarification>';
	v_buf := v_buf || '<write_off_unit>';
	v_buf := v_buf || '<write_off_unit_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</write_off_unit_code>';
	v_buf := v_buf || '<write_off_unit_qty/>';
	v_buf := v_buf || '</write_off_unit>';
	v_buf := v_buf || '<Goods_description>';
	v_buf := v_buf || '<Country_of_origin_code>'|| add_field(fol_rec.SAD_144_CTY_ORIGCOD, 3) ||'</Country_of_origin_code>';
	v_buf := v_buf || '<Country_of_origin_region/>';
	v_buf := v_buf || '<Description_of_goods>Other</Description_of_goods>';
	v_buf := v_buf || '<Commercial_Description>'|| add_field(fol_rec.SAD_139_GOODS_DESC1, 44) ||'</Commercial_Description>';
	v_buf := v_buf || '</Goods_description>';
	v_buf := v_buf || '<Previous_doc>';
	v_buf := v_buf || '<Summary_declaration>'|| add_field(fol_rec.SAD_156_TRSP_DOC, 26) ||'</Summary_declaration>';
	v_buf := v_buf || '<Summary_declaration_sl>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Summary_declaration_sl>';
	v_buf := v_buf || '<Previous_document_reference>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Previous_document_reference>';
	v_buf := v_buf || '<Previous_warehouse_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Previous_warehouse_code>';
	v_buf := v_buf || '</Previous_doc>';
	v_buf := v_buf || '<Licence_number/>';
	v_buf := v_buf || '<Amount_deducted_from_licence/>';
	v_buf := v_buf || '<Quantity_deducted_from_licence/>';
	v_buf := v_buf || '<Free_text_1>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Free_text_1>';
	v_buf := v_buf || '<Free_text_2>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Free_text_2>';
	v_buf := v_buf || '<Taxation>';
	v_buf := v_buf || '<Item_taxes_amount>'|| add_field(to_char(fol_rec.SAD_171_ITM_TOTAMT,'9999999990.99'), 11) ||'</Item_taxes_amount>'; --#
	v_buf := v_buf || '<Item_taxes_guaranted_amount/>';
	v_buf := v_buf || '<Item_taxes_mode_of_payment>'|| add_field(fol_rec.SAD_172_ITM_TOTMOP, 1) ||'</Item_taxes_mode_of_payment>';
	v_buf := v_buf || '<Counter_of_normal_mode_of_payment/>';
	v_buf := v_buf || '<Displayed_item_taxes_amount/>';
	v_buf := v_buf || '<Taxation_line>';
	v_buf := v_buf || '<Duty_tax_code>IMD</Duty_tax_code>';
	v_buf := v_buf || '<Duty_tax_Base>'|| add_field(to_char(fol_rec.ITEM_DUTY_TAX_BASE_AMOUNT,'999999999990.99'), 15) ||'</Duty_tax_Base>';
	v_buf := v_buf || '<Duty_tax_rate>'|| add_field(to_char(fol_rec.ITEM_DUTY_TAX_RATE,'99999999990.999'), 15) ||'</Duty_tax_rate>';
	v_buf := v_buf || '<Duty_tax_amount>'|| add_field(to_char(fol_rec.ITEM_DUTY_TAX_AMOUNT,'999999999990.99'), 15) ||'</Duty_tax_amount>';
	v_buf := v_buf || '<Duty_tax_MP>'|| add_field(fol_rec.ITEM_DUTY_TAX_MOP, 1) ||'</Duty_tax_MP>';
	v_buf := v_buf || '<Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '</Taxation_line>';
	v_buf := v_buf || '<Taxation_line>';
	v_buf := v_buf || '<Duty_tax_code>GST</Duty_tax_code>';
	v_buf := v_buf || '<Duty_tax_Base>'|| add_field(to_char(fol_rec.ITEM_DUTY_TAX_BASE_AMOUNT,'999999999990.99'), 15) ||'</Duty_tax_Base>';
	v_buf := v_buf || '<Duty_tax_rate>'|| add_field(NVL(to_char(fol_rec.ITEM_VAT_TAX_RATE,'999999999990.999'),'0.000'), 15) ||'</Duty_tax_rate>';
	v_buf := v_buf || '<Duty_tax_amount>'|| add_field(NVL(to_char(fol_rec.ITEM_VAT_TAX_AMOUNT,'999999999990.99'),'0.00'), 15) ||'</Duty_tax_amount>';
	v_buf := v_buf || '<Duty_tax_MP>'|| add_field(NVL(fol_rec.ITEM_VAT_TAX_MOP,'1'), 1) ||'</Duty_tax_MP>';
	v_buf := v_buf || '<Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '</Taxation_line>';
	v_buf := v_buf || '<Taxation_line>';
	v_buf := v_buf || '<Duty_tax_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_code>';
	v_buf := v_buf || '<Duty_tax_Base/>';
	v_buf := v_buf || '<Duty_tax_rate/>';
	v_buf := v_buf || '<Duty_tax_amount/>';
	v_buf := v_buf || '<Duty_tax_MP>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_MP>';
	v_buf := v_buf || '<Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '</Taxation_line>';
	v_buf := v_buf || '<Taxation_line>';
	v_buf := v_buf || '<Duty_tax_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_code>';
	v_buf := v_buf || '<Duty_tax_Base/>';
	v_buf := v_buf || '<Duty_tax_rate/>';
	v_buf := v_buf || '<Duty_tax_amount/>';
	v_buf := v_buf || '<Duty_tax_MP>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_MP>';
	v_buf := v_buf || '<Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '</Taxation_line>';
	v_buf := v_buf || '<Taxation_line>';
	v_buf := v_buf || '<Duty_tax_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_code>';
	v_buf := v_buf || '<Duty_tax_Base/>';
	v_buf := v_buf || '<Duty_tax_rate/>';
	v_buf := v_buf || '<Duty_tax_amount/>';
	v_buf := v_buf || '<Duty_tax_MP>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_MP>';
	v_buf := v_buf || '<Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '</Taxation_line>';
	v_buf := v_buf || '<Taxation_line>';
	v_buf := v_buf || '<Duty_tax_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_code>';
	v_buf := v_buf || '<Duty_tax_Base/>';
	v_buf := v_buf || '<Duty_tax_rate/>';
	v_buf := v_buf || '<Duty_tax_amount/>';
	v_buf := v_buf || '<Duty_tax_MP>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_MP>';
	v_buf := v_buf || '<Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '</Taxation_line>';
	v_buf := v_buf || '<Taxation_line>';
	v_buf := v_buf || '<Duty_tax_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_code>';
	v_buf := v_buf || '<Duty_tax_Base/>';
	v_buf := v_buf || '<Duty_tax_rate/>';
	v_buf := v_buf || '<Duty_tax_amount/>';
	v_buf := v_buf || '<Duty_tax_MP>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_MP>';
	v_buf := v_buf || '<Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '</Taxation_line>';
	v_buf := v_buf || '<Taxation_line>';
	v_buf := v_buf || '<Duty_tax_code>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_code>';
	v_buf := v_buf || '<Duty_tax_Base/>';
	v_buf := v_buf || '<Duty_tax_rate/>';
	v_buf := v_buf || '<Duty_tax_amount/>';
	v_buf := v_buf || '<Duty_tax_MP>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_MP>';
	v_buf := v_buf || '<Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '<null/>';
	v_buf := v_buf || '</Duty_tax_Type_of_calculation>';
	v_buf := v_buf || '</Taxation_line>';
	v_buf := v_buf || '</Taxation>';
		v_buf := v_buf || '<Valuation_item>';
		v_buf := v_buf || '<Weight_itm>';
		-- v_buf := v_buf || '<Gross_weight_itm>'|| add_field(fol_rec.SAD_146_GROSS_MASS, 11) ||'</Gross_weight_itm>';
		-- v_buf := v_buf || '<Net_weight_itm>'|| add_field(fol_rec.SAD_154_NET_MASS, 11) ||'</Net_weight_itm>';
		v_buf := v_buf || '<Gross_weight_itm>'|| add_field(ctr_itm(fol_rec.SAD_131_ITM_NBER), 11) ||'</Gross_weight_itm>';
		v_buf := v_buf || '<Net_weight_itm>'|| add_field(ctr_itm(fol_rec.SAD_131_ITM_NBER), 11) ||'</Net_weight_itm>';
		v_buf := v_buf || '</Weight_itm>';
		v_buf := v_buf || '<Total_cost_itm>'|| add_field(to_char(fol_rec.SAD_209_IITMADD_CST, '999999999990.99'), 15) ||'</Total_cost_itm>';
		v_buf := v_buf || '<Total_CIF_itm>'|| add_field(to_char(fol_rec.SAD_210_IITMCIF_VALN,'999999999990.99'), 15) ||'</Total_CIF_itm>';
		v_buf := v_buf || '<Rate_of_adjustement>1</Rate_of_adjustement>';
		v_buf := v_buf || '<Statistical_value>'|| add_field(to_char(fol_rec.SAD_210_IITMCIF_VALN,'999999999990.99'), 15) ||'</Statistical_value>';
		v_buf := v_buf || '<Alpha_coeficient_of_apportionment>1.0</Alpha_coeficient_of_apportionment>';
		v_buf := v_buf || '<Item_Invoice>';
		v_buf := v_buf || '<Amount_national_currency>'|| add_field(to_char(fol_rec.SAD_183_IITMINV_VALN, '99999990.00'), 11) ||'</Amount_national_currency>';
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(to_char(fol_rec.SAD_179_IITMINV_VALC,'99999990.99'), 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(fol_rec.SAD_180_IITMINV_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Currency_name>';
		v_buf := v_buf || '<Currency_rate>'|| add_field(to_char(fol_rec.SAD_181_IITMINV_RAT,'990.9999'),8) ||'</Currency_rate>'; --#
		v_buf := v_buf || '</Item_Invoice>';
		v_buf := v_buf || '<item_external_freight>';
		v_buf := v_buf || '<Amount_national_currency>'|| add_field(to_char(fol_rec.SAD_188_IITMEFR_VALN, '99999990.00'), 11) ||'</Amount_national_currency>'; --#
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(to_char(fol_rec.SAD_184_IITMEFR_VALC, '99999990.00'), 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(fol_rec.SAD_185_IITMEFR_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>'; --#
		v_buf := v_buf || '<Currency_rate>'|| add_field(to_char(fol_rec.SAD_186_IITMEFR_RAT,'990.9999'),8) ||'</Currency_rate>'; --#
		v_buf := v_buf || '</item_external_freight>';
		v_buf := v_buf || '<item_internal_freight>';
		v_buf := v_buf || '<Amount_national_currency>'|| add_field(to_char(fol_rec.SAD_203_IITMIFR_VALN, '99999990.00'), 11) ||'</Amount_national_currency>';
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(to_char(fol_rec.SAD_199_IITMIFR_VALC, '99999990.00'), 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(fol_rec.SAD_200_IITMIFR_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>';
		v_buf := v_buf || '<Currency_rate>'|| add_field(to_char(fol_rec.SAD_201_IITMIFR_RAT,'990.9999'),8) ||'</Currency_rate>';
		v_buf := v_buf || '</item_internal_freight>';
		v_buf := v_buf || '<item_insurance>';
		v_buf := v_buf || '<Amount_national_currency>'|| add_field(to_char(fol_rec.SAD_193_IITMINS_VALN, '99999990.00'), 11) ||'</Amount_national_currency>';
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(to_char(fol_rec.SAD_189_IITMINS_VALC, '99999990.00'), 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(fol_rec.SAD_190_IITMINS_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>';
		v_buf := v_buf || '<Currency_rate>'|| add_field(to_char(fol_rec.SAD_191_IITMINS_RAT,'990.9999'),8) ||'</Currency_rate>';
		v_buf := v_buf || '</item_insurance>';
		v_buf := v_buf || '<item_other_cost>';
		v_buf := v_buf || '<Amount_national_currency>'|| add_field(to_char(fol_rec.SAD_198_IITMOTC_VALN, '99999990.00'), 11) ||'</Amount_national_currency>';
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(to_char(fol_rec.SAD_194_IITMOTC_VALC, '99999990.00'), 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(fol_rec.SAD_195_IITMOTC_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>';
		v_buf := v_buf || '<Currency_rate>'|| add_field(to_char(fol_rec.SAD_196_IITMOTC_RAT,'990.9999'),8) ||'</Currency_rate>';
		v_buf := v_buf || '</item_other_cost>';
		v_buf := v_buf || '<item_deduction>';
		v_buf := v_buf || '<Amount_national_currency>'|| add_field(to_char(fol_rec.SAD_208_IITMDED_VALN, '99999990.00'), 11) ||'</Amount_national_currency>';
		v_buf := v_buf || '<Amount_foreign_currency>'|| add_field(to_char(fol_rec.SAD_204_IITMDED_VALC, '99999990.00'), 11) ||'</Amount_foreign_currency>';
		v_buf := v_buf || '<Currency_code>'|| add_field(fol_rec.SAD_205_IITMDED_CUR, 3) ||'</Currency_code>';
		v_buf := v_buf || '<Currency_name></Currency_name>';
		v_buf := v_buf || '<Currency_rate>'|| add_field(to_char(fol_rec.SAD_206_IITMDED_RAT,'990.9999'),8)||'</Currency_rate>';
		v_buf := v_buf || '</item_deduction>';
		v_buf := v_buf || '<Market_valuer>';
		v_buf := v_buf || '<Rate/>';
		v_buf := v_buf || '<Currency_code>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Currency_code>';
		v_buf := v_buf || '<Currency_amount/>';
		v_buf := v_buf || '<Basis_description>';
		v_buf := v_buf || '<null/>';
		v_buf := v_buf || '</Basis_description>';
		v_buf := v_buf || '<Basis_amount/>';
		v_buf := v_buf || '</Market_valuer>';
		v_buf := v_buf || '</Valuation_item>';
	v_buf := v_buf || '</Item>';
-- Write buffer into source BLOB
if length(v_buf) > 0
 then
 -- Modified by David Banjo - changed length to lengthb
  dbms_lob.writeappend(src_blb, lengthb(v_buf), utl_raw.cast_to_raw(v_buf));
end if;
sad_file_len := sad_file_len + length(v_buf);
v_buf := null;
end loop;

-- END  (ASYCUDA WORLD)
-- =====================================================================================
v_buf := v_buf || '</ASYCUDA>';
 -- Final write into source BLOB
 -- Modified by David Banjo - changed length to lengthb
dbms_lob.writeappend(src_blb, lengthb(v_buf), utl_raw.cast_to_raw(v_buf));

 -- Append source BLOB to destination BLOB
 dbms_lob.append(dst_blb, src_blb);


 -- Write destination BLOB to file

 websys.utl_blob.blobtofile( dst_blb, f_dir || '\' || f_name, FALSE );

 dbms_lob.freetemporary(src_blb);
 dbms_lob.freetemporary(dst_blb);

 if websys.file_exists(f_dir,f_name)
 then
  err := 'SAD File Generated to '|| f_dir || '\' || f_name ;
  sad_file_ctr := nvl(websys.dapi.GLOBAL_ARRAY.count, 0);
  sad_file_ctr := sad_file_ctr + 1;
  websys.dapi.GLOBAL_ARRAY(sad_file_ctr) := f_dir || '\' || f_name ;
 else
  err := 'SAD File Not Generated' ;
 end if;

 if send_email then
  websys.strangs.email_sad_file_multi(websys.dapi.GLOBAL_SURL);
 end if;

exception when others then
 begin
  dbms_lob.freetemporary(src_blb);
  dbms_lob.freetemporary(dst_blb);
 exception when others then null;
 end;
websys.glbx.dbg('Generate Sad Error 2 [' || stp || '] ' ||sqlerrm);
websys.glbx.dbg('Generate Sad Error ..' ||substr(v_buf, -200));
err := '['|| err_msg || '] Generate Sad Error at step ' || stp || ' - '||sqlerrm;
end generate_sad_sad_com;
/


GRANT EXECUTE ON STRANG.GENERATE_SAD_SAD_COM TO WEBSYS;
