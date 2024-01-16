CREATE OR REPLACE procedure STRANG.generate_sad_sad_com_s(v_entry varchar2, mail_to integer default 2, refresh boolean default TRUE) as

cursor c1(v_ent varchar2) is
 select cs.*
 from   detailrs dr, receivals rc, customers cs
 where  dr.entry_no = v_ent
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
 where  entry_no = v_ent and
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
 where  entry_no = v_ent and
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

f_dir	        varchar2(1000);
f_name	      varchar2(1000);
f             utl_file.file_type;
c1rec         c1%ROWTYPE;
c2arec        c2a%ROWTYPE;
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
err	      varchar2(1000);

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
 begin
  v_txt := trim(vval);
  if max_length is not null and length(v_txt) > max_length
   then
    v_txt := substr(v_txt, 1, max_length);
  end if;
  v_txt := v_txt || rep_chr(0);
  return(v_txt);
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
   gen_rec.SAD_015_CUO_COD:= f15_parameter_range_sad_com_s( 'A3_SAD', v_entry, v_cust );
   gen_rec.SAD_016_DECLARANT:= f15_parameter_range_sad_com_s( 'AD', v_entry, v_cust );
   gen_rec.SAD_017_USER_NBER:= f15_parameter_range_sad_com_s( 'A17_SAD', v_entry, v_cust );
   gen_rec.SAD_014_USER_YEAR:=to_char(sysdate, 'YYYY');
   gen_rec.SAD_018_NOT_DEFINED:= '1';
   gen_rec.SAD_019_TYP_DEC:= f15_parameter_range_sad_com_s( 'A4_SAD', v_entry, v_cust );
   gen_rec.SAD_020_TYP_PROC:= f15_parameter_range_sad_com_s( 'A5_SAD', v_entry, v_cust );
   gen_rec.SAD_023_MANIF_NBER:= f15_parameter_range_sad_com_s( 'AS_REG', v_entry, v_cust );
   gen_rec.SAD_028_ITM_TOTAL := f15_parameter_range_sad_com_s( 'A00', v_entry, v_cust );
   gen_rec.SAD_029_PACK_TOTAL := f15_parameter_range_sad_com_s( 'A000', v_entry, v_cust );
   gen_rec.SAD_030_CONSIGNEE := f15_parameter_range_sad_com_s( 'A5', v_entry, v_cust );
   gen_rec.SAD_031_FINANCIAL := f15_parameter_range_sad_com_s( 'A6_SAD', v_entry, v_cust );
   gen_rec.SAD_032_CTY_1DLP := f15_parameter_range_sad_com_s( 'A7_SAD', v_entry, v_cust );
   gen_rec.SAD_033_TRA_CTY := f15_parameter_range_sad_com_s( 'A8_SAD', v_entry, v_cust );
   num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AG', v_entry, v_cust )), 0);
   num3 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AI', v_entry, v_cust )), 0);
   num4 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJ', v_entry, v_cust )), 0);
   num7 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AGI', v_entry, v_cust )), 0); --internal freight;
   num8 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJD', v_entry, v_cust )), 0); -- deductions;
   gen_rec.SAD_034_VAL_DETAILS := to_char((num1+num3+num4+num7-num8)/f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ), '999999999990.00');
   gen_rec.SAD_036_CTY_EXPCOD := f15_parameter_range_sad_com_s( 'A9_SAD', v_entry, v_cust );
   gen_rec.SAD_038_CTY_DESTCOD := f15_parameter_range_sad_com_s( 'A10_SAD', v_entry, v_cust );
   gen_rec.SAD_040_TRSP_IDDEPAR := f15_parameter_range_sad_com_s( 'AS', v_entry, v_cust );
   gen_rec.SAD_041_TRSP_NATDEPAR := f15_parameter_range_sad_com_s( 'AB_3', v_entry, v_cust );
   gen_rec.SAD_042_CTNR_FLAG := f15_parameter_range_sad_com_s( 'SAD_AWWWW_5', v_entry, v_cust );
   gen_rec.SAD_043_TOD_COD := f15_parameter_range_sad_com_s( 'A8', v_entry, v_cust );
   gen_rec.SAD_044_TOD_NAM := f15_parameter_range_sad_com_s( 'A11_SAD', v_entry, v_cust );
   gen_rec.SAD_048_CUR_COD := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );
   gen_rec.SAD_049_TOT_INVOICED := f15_parameter_range_sad_com_s( 'AE', v_entry, v_cust );
   gen_rec.SAD_052_MOT_BORD := f15_parameter_range_sad_com_s( 'SAD_AWWWW_6', v_entry, v_cust );
   gen_rec.SAD_054_LOP_COD := f15_parameter_range_sad_com_s( 'A12_SAD', v_entry, v_cust );
   gen_rec.SAD_055_TOP_COD := f15_parameter_range_sad_com_s( 'SAD_AWWWW_7', v_entry, v_cust );
   gen_rec.SAD_056_CUO_BORD := f15_parameter_range_sad_com_s( 'A3_SAD_1', v_entry, v_cust );
   gen_rec.SAD_057_LOC_GOODS := f15_parameter_range_sad_com_s( 'A13_SAD', v_entry, v_cust );
   gen_rec.SAD_058_BNK_COD := f15_parameter_range_sad_com_s( 'SAD_AWWWW_8', v_entry, v_cust );
   gen_rec.SAD_059_BNK_BRA := f15_parameter_range_sad_com_s( 'SAD_AWWWW_9', v_entry, v_cust );
   gen_rec.SAD_060_BNK_FNBER := f15_parameter_range_sad_com_s( 'A16_SAD', v_entry, v_cust );
   gen_rec.SAD_062_WHS_COD := f15_parameter_range_sad_com_s( 'A14_SAD', v_entry, v_cust );
   gen_rec.SAD_063_WHS_TIME := f15_parameter_range_sad_com_s( 'A15_SAD', v_entry, v_cust );
   gen_rec.SAD_071_GRTY_AMOUNT := f15_parameter_range_sad_com_s( 'AE_1', v_entry, v_cust );
   gen_rec.SAD_072_GRTY_DATE := f15_parameter_range_sad_com_s( 'AE_2', v_entry, v_cust );
   gen_rec.SAD_073_TOT_FEES := to_char(f15_parameter_range_sad_com_s( 'A18_SAD', v_entry, v_cust ),'999999999999990.99');
   tot_dec:=0;
   for c2brec in c2b(v_entry) loop
     v_excise:=0;
     v_tariff:= c2brec.cola;
     v_entryitem := c2brec.entry_item; --20161109
     tot_dec := tot_dec +  nvl(form_15_continue_sad_com_s( 'XX_2',v_entry, v_entryitem, v_tariff,c2b%ROWCOUNT,vtot ),0);
     tmp := nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'CPY_3a',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot )), 0);
      if tmp > 0
      then
        num13:= nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot )), 0); -- excise rate tax amount
        num14:= nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot )), 0); -- excise by unit tax amount
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
          tot_dec := tot_dec + nvl(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
          v_excise:= nvl(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);
         when tmp = 2 then
          tot_dec := tot_dec + nvl(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
          v_excise:= nvl(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);
         when tmp = 3 then
          tot_dec := tot_dec + nvl(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
          tot_dec := tot_dec + nvl(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
          v_excise:= nvl(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);
          v_excise:= v_excise + nvl(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot ),0);
        end case;
      end if;
     tot_dec := tot_dec +  nvl(form_15_continue_sad_com_s( 'SSS_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,v_excise ),0);  -- VAT
     tot_dec := tot_dec +  nvl(form_15_continue_sad_com_s( 'TTT_2',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,v_excise ),0);  -- LEVY
    end loop;
     gen_rec.SAD_074_TOTAL_TAXES:= to_char(tot_dec+(strang.f15_parameter_range_sad_com_s( 'A18_SAD', v_entry, v_cust )), '999999999999990.99' );
--     gen_rec.SAD_074_TOTAL_TAXES:= to_char(tot_dec, '999999999999990.99' );  -- 20150821
     gen_rec.SAD_075_CTRL_RESULTS := '0';
     gen_rec.SAD_077_DEC_DATE := to_char(sysdate, 'YYYYMMDD');
     gen_rec.SAD_080_NOT_DEFINED := '0';
     gen_rec.SAD_081_ITOTINV_VALC := f15_parameter_range_sad_com_s( 'AE', v_entry, v_cust );
     gen_rec.SAD_082_ITOTINV_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );
     gen_rec.SAD_083_ITOTINV_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999');
     gen_rec.SAD_084_ITOTINV_REF := '1.00000'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); -- JY CHANGE
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AE', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);
     if num2 <> 0
     then
      gen_rec.SAD_085_ITOTINV_VALN :=to_char(num1/num2, '99999990.00');
     else
      gen_rec.SAD_085_ITOTINV_VALN :='0.00';
     end if;
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AG', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_086_ITOTEFR_VALC:= to_char(f15_parameter_range_sad_com_s( 'AG', v_entry, v_cust ),'99999990.00');      -- AG [N11] [EXTERNAL FREIGHT IN AUD] 86/5 SAD_ITOTEFR_VALC
       gen_rec.SAD_087_ITOTEFR_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );
       gen_rec.SAD_088_ITOTEFR_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999');
     else
       gen_rec.SAD_086_ITOTEFR_VALC:= NULL;      -- AG [N11] [EXTERNAL FREIGHT IN AUD] 86/5 SAD_ITOTEFR_VALC
       gen_rec.SAD_087_ITOTEFR_CUR := NULL;
       gen_rec.SAD_088_ITOTEFR_RAT := NULL;
     end if;
     gen_rec.SAD_089_ITOTEFR_REF := '1.00000'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); -- JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_090_ITOTEFR_VALN := to_char(num1/num2, '99999990.00');    -- AG/A9 [EXTERNAL FREIGHT IN PGK] 90/8 SAD_ITOTEFR_VALN
     else
       gen_rec.SAD_090_ITOTEFR_VALN := '0.00';    -- AG/A9 [EXTERNAL FREIGHT IN PGK] 90/8 SAD_ITOTEFR_VALN
     end if;
--
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AI', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_091_ITOTINS_VALC:= to_char(f15_parameter_range_sad_com_s( 'AI', v_entry, v_cust ),'99999990.00');      --       -- AI [N11] [INSURANCE IN AUD] 91/9 SAD_ITOTINS_VALC
       gen_rec.SAD_092_ITOTINS_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );  -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 92/10 SAD_ITOTINS_CUR
       gen_rec.SAD_093_ITOTINS_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- A9  [N8] [23] [EXCHANGE RATE] 93/11 SAD_ITOTINS_RAT
     else
       gen_rec.SAD_091_ITOTINS_VALC:= NULL;            -- AI [N11] [INSURANCE IN AUD] 91/9 SAD_ITOTINS_VALC
       gen_rec.SAD_092_ITOTINS_CUR := NULL;            -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 92/10 SAD_ITOTINS_CUR
       gen_rec.SAD_093_ITOTINS_RAT := NULL;            -- A9  [N8] [23] [EXCHANGE RATE] 93/11 SAD_ITOTINS_RAT
     end if;
     gen_rec.SAD_094_ITOTINS_REF := '1.00000'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust );  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 94/- SAD_ITOTINS_REF --JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_095_ITOTINS_VALN := to_char(num1/num2, '99999990.00');     -- AI/A9 [INSURANCE IN PGK] 95/12 SAD_ITOTINS_VALN-- AG/A9 [EXTERNAL FREIGHT IN PGK] 90/8 SAD_ITOTINS_VALN
     else
       gen_rec.SAD_095_ITOTINS_VALN := '0.00';     -- AI/A9 [INSURANCE IN PGK] 95/12 SAD_ITOTINS_VALN
     end if;
--
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJ', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_096_ITOTOTC_VALC:= to_char(f15_parameter_range_sad_com_s( 'AJ', v_entry, v_cust ),'99999990.00');      -- AJ [N11][OTHER COSTS IN AUD] 96/13 SAD_ITOTOTC_VALC
       gen_rec.SAD_097_ITOTOTC_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );  -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 97/14 SAD_ITOTOTC_CUR
       gen_rec.SAD_098_ITOTOTC_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- A9  [N8] [23] [EXCHANGE RATE] 98/15 SAD_ITOTOTC_RAT
     else
       gen_rec.SAD_096_ITOTOTC_VALC:= NULL;            -- AJ [N11][OTHER COSTS IN AUD] 96/13 SAD_ITOTOTC_VALC
       gen_rec.SAD_097_ITOTOTC_CUR := NULL;            -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 97/14 SAD_ITOTOTC_CUR
       gen_rec.SAD_098_ITOTOTC_RAT := NULL;            -- A9  [N8] [23] [EXCHANGE RATE] 98/15 SAD_ITOTOTC_RAT
     end if;
     gen_rec.SAD_099_ITOTOTC_REF := '1.00000'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust );  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 99/- SAD_ITOTOTC_REF --JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_100_ITOTOTC_VALN := to_char(num1/num2, '99999990.00');     -- -- AJ/A9  [OTHER COSTS AMOUNT IN PGK] 100/16 SAD_ITOTOTC_VALN
     else
       gen_rec.SAD_100_ITOTOTC_VALN := '0.00';     -- AJ/A9  [OTHER COSTS AMOUNT IN PGK] 100/16 SAD_ITOTOTC_VALN
     end if;
--
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AGI', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_101_ITOTIFR_VALC:= to_char(f15_parameter_range_sad_com_s( 'AGI', v_entry, v_cust ),'99999990.00');      -- [NUMBER11] 101/17 SAD_ITOTIFR_VALC & [AN3] 102/18 SAD_ITOTIFR_CUR & [NUMBER 8] 103/19 SAD_ITOTIFR_RAT
       gen_rec.SAD_102_ITOTIFR_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );  -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 102/18 SAD_ITOTIFRC_CUR
       gen_rec.SAD_103_ITOTIFR_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- A9  [N8] [23] [EXCHANGE RATE] 103/19 SAD_ITOTIFR_RAT
     else
       gen_rec.SAD_101_ITOTIFR_VALC:= NULL;            -- [NUMBER11] 101/17 SAD_ITOTIFR_VALC & [AN3] 102/18 SAD_ITOTIFR_CUR & [NUMBER 8] 103/19 SAD_ITOTIFR_RAT
       gen_rec.SAD_102_ITOTIFR_CUR := NULL;            -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 102/18 SAD_ITOTIFRC_CUR
       gen_rec.SAD_103_ITOTIFR_RAT := NULL;            -- A9  [N8] [23] [EXCHANGE RATE] 103/19 SAD_ITOTIFR_RAT
     end if;
     gen_rec.SAD_104_ITOTIFR_REF := '1.00000'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust );  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 104/- SAD_ITOTIFR_REF -- JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_105_ITOTIFR_VALN := to_char(num1/num2, '99999990.00');     -- -- [NUMBER 11] AGI/A9  [INTERNAL FREIGHT AMOUNT IN PGK] 105/20 SAD_ITOTIFR_VALN
     else
       gen_rec.SAD_105_ITOTIFR_VALN := '0.00';     -- AGI/A9 [NUMBER 11] [INTERNAL FREIGHT AMOUNT IN PGK] 105/20 SAD_ITOTIFR_VALN
     end if;
--
     num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJD', v_entry, v_cust )), 0);
     num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);
     if num1 > 0
     then
       gen_rec.SAD_106_ITOTDED_VALC:= to_char(f15_parameter_range_sad_com_s( 'AJD', v_entry, v_cust ),'99999990.00');      -- [NUMBER11] 106/21 SAD_ITOTDED_VALC
       gen_rec.SAD_107_ITOTDED_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );  -- [AN3] 107/22 SAD_ITOTDED_CUR [REF - UNCURTAB]
       gen_rec.SAD_108_ITOTDED_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- A9  [N8] [23] [EXCHANGE RATE] 108/23 SAD_ITOTDED_RAT
     else
       gen_rec.SAD_106_ITOTDED_VALC:= NULL;            -- [NUMBER11] 106/21 SAD_ITOTDED_VALC
       gen_rec.SAD_107_ITOTDED_CUR := NULL;            -- [AN3] 107/22 SAD_ITOTDED_CUR [REF - UNCURTAB]
       gen_rec.SAD_108_ITOTDED_RAT := NULL;            -- A9  [N8] [23] [EXCHANGE RATE] 108/23 SAD_ITOTDED_RAT
     end if;
     gen_rec.SAD_109_ITOTDED_REF := '1.00000'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust );  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 109/- SAD_ITOTDED_REF --JY CHANGE
     if num2 <> 0
      then
       gen_rec.SAD_110_ITOTDED_VALN := to_char(num1/num2, '99999990.00');     -- -- [NUMBER 11] AJD/A9  [DEDUCTIONS AMOUNT IN PGK] 110/24 SAD_ITOTDED_VALN
     else
       gen_rec.SAD_110_ITOTDED_VALN := '0.00';     -- -- [NUMBER 11] AJD/A9  [DEDUCTIONS AMOUNT IN PGK] 110/24 SAD_ITOTDED_VALN
     end if;
--
 num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AG', v_entry, v_cust )), 0);
 num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);
 num3 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AI', v_entry, v_cust )), 0);
 num4 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJ', v_entry, v_cust )), 0);
 num7 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AGI', v_entry, v_cust )), 0); --internal freight;
 num8 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJD', v_entry, v_cust )), 0); -- deductions;
 if num2 <> 0
  then
   gen_rec.SAD_111_ITOTADD_CST := to_char((num1+num3+num4+num7-num8)/num2, '999999999990.00');    -- [NUMBER 15] ((AG+AI+AJ+AGI-AJD)/A9) [TOTAL COSTS IN PGK]  111/26 SAD_ITOTADD_CST
 else
   gen_rec.SAD_111_ITOTADD_CST := '0.00';    -- -- [NUMBER 15] ((AG+AI+AJ+AGI-AJD)/A9) [TOTAL COSTS IN PGK]  111/26 SAD_ITOTADD_CST
 end if;
--
 num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AG', v_entry, v_cust )), 0);
 num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);
 num3 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AI', v_entry, v_cust )), 0);
 num4 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJ', v_entry, v_cust )), 0);
 num5 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AE', v_entry, v_cust )), 0);
 num7 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AGI', v_entry, v_cust )), 0); --internal freight;
 num8 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJD', v_entry, v_cust )), 0); -- deductions;
 if num2 <> 0
  then
   gen_rec.SAD_112_ICIF_VALN := to_char((num5/num2)+(num1+num3+num4+num7-num8)/num2, '999999999990.00');    -- [NUMBER 15] AE/A9 + ((AG+AI+AJ+AGI-AJD)/A9)  [INVOICE TOTAL+ TOTAL COSTS IN PGK] 112/27 SAD_ICIF_VALN
 else
   gen_rec.SAD_112_ICIF_VALN := '0.00';    -- [NUMBER 15] AE/A9 + ((AG+AI+AJ+AGI-AJD)/A9)  [INVOICE TOTAL+ TOTAL COSTS IN PGK] 112/27 SAD_ICIF_VALN
 end if;
 -- PART 4: OCCASIONAL DATA - EXPORTER (ASYCUDA++ TECHNICAL DOC V1.3 - SAD FILE STRUCTURE)
-- =====================================================================================
 gen_rec.SAD_115_EXP_NAM := f15_parameter_range_sad_com_s( 'A4', v_entry, v_cust );
 gen_rec.SAD_116_EXP_ADD1:= f15_parameter_range_sad_com_s( 'A4X', v_entry, v_cust );
 gen_rec.SAD_117_EXP_ADD2:= f15_parameter_range_sad_com_s( 'A4XX', v_entry, v_cust );
 gen_rec.SAD_118_EXP_CITY:= f15_parameter_range_sad_com_s( 'A4X1', v_entry, v_cust );
 gen_rec.SAD_119_EXP_ZIP:=  f15_parameter_range_sad_com_s( 'A4XX1', v_entry, v_cust );

-- GLOBAL TAXES
-- ===============
 gen_rec.GLOBAL_TAX_1 := strang.f15_parameter_range_sad_com_s( 'A21_SAD', v_entry,v_cust );
 gen_rec.GLOBAL_TAX_2 := 'EPG';
 gen_rec.GLOBAL_TAX_3 := to_char(f15_parameter_range_sad_com_s( 'A18_SAD', v_entry, v_cust ),999990.99 );
 gen_rec.GLOBAL_TAX_4 := '1.0000';
 gen_rec.GLOBAL_TAX_5 := to_char(f15_parameter_range_sad_com_s( 'A18_SAD', v_entry, v_cust ),999990.99 );
 gen_rec.GLOBAL_TAX_6 := strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );
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
       fol_rec.SAD_132_PACK_MARK1:= 'OTML/TAB';
       fol_rec.SAD_133_PACK_MARK2:= f15_parameter_range_sad_com_s( 'AWWW_1X', v_entry, v_cust );
     else
       fol_rec.SAD_132_PACK_MARK1:= form_15_continue_sad_com_s( 'AWW', v_entry, v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
       fol_rec.SAD_133_PACK_MARK2:= 'PO '|| form_15_continue_sad_com_s( 'AWW_SAD', v_entry, v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
     end if;
--     fol_rec.SAD_132_PACK_MARK1:= f15_parameter_range_sad_com_s( 'AWW', v_entry, v_cust );
--     fol_rec.SAD_133_PACK_MARK2:= f15_parameter_range_sad_com_s( 'AWWW_SAD', v_entry, v_cust );
     fol_rec.SAD_134_HS_COD:=   form_15_continue_sad_com_s( 'CPC_1',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
     fol_rec.SAD_135_HSPREC_COD := form_15_continue_sad_com_s( 'CPC_1_1',v_entry,v_entryitem,v_tariff,c2b%ROWCOUNT,vtot );
     fol_rec.SAD_138_TAR_SPC := form_15_continue_sad_com_s( 'CPC_1_2',v_entry,v_entryitem,v_tariff,1,vtot );
     fol_rec.SAD_139_GOODS_DESC1:= f15_parameter_range_sad_com_s( 'SAD_AWWWWW_1', v_entry, v_tariff );
     fol_rec.SAD_140_GOODS_DESC2 := f15_parameter_range_sad_com_s( 'SAD_AWWWWW_2', v_entry, v_tariff );
     fol_rec.SAD_141_GOODS_DESC3 := f15_parameter_range_sad_com_s( 'SAD_AWWWWW_3', v_entry, v_tariff );
     fol_rec.SAD_142_PACK_NBER := f15_parameter_range_sad_com_s( 'AWWW_1', v_entry, v_cust );
     fol_rec.SAD_143_PACK_KINDCOD := f15_parameter_range_sad_com_s( 'AWWW_2', v_entry, v_cust );
     fol_rec.SAD_144_CTY_ORIGCOD := f15_parameter_range_sad_com_s( '000A', v_entry, v_cust );
     fol_rec.SAD_146_GROSS_MASS := to_char(form_15_continue_sad_com_s( 'CPG_4',v_entry,v_entryitem,v_tariff,1,vtot ),'9999990.999' );
     fol_rec.SAD_148_CTNR_NBER1 := f15_parameter_range_sad_com_s( 'SAD_AWWWW_1', v_entry, v_cust );
     fol_rec.SAD_149_CTNR_NBER2 := f15_parameter_range_sad_com_s( 'SAD_AWWWW_2', v_entry, v_cust );
     fol_rec.SAD_150_CTNR_NBER3 := f15_parameter_range_sad_com_s( 'SAD_AWWWW_3', v_entry, v_cust );
     fol_rec.SAD_151_CTNR_NBER4 := f15_parameter_range_sad_com_s( 'SAD_AWWWW_4', v_entry, v_cust );
     fol_rec.SAD_152_EXTD_PROC := form_15_continue_sad_com_s( 'CPG_2',v_entry,v_entryitem,v_tariff,1,vtot );
     fol_rec.SAD_153_NAT_PROC := form_15_continue_sad_com_s( 'CPG_3',v_entry,v_entryitem,v_tariff,1,vtot );
     fol_rec.SAD_154_NET_MASS := to_char(form_15_continue_sad_com_s( 'CPG_4',v_entry,v_entryitem,v_tariff,1,vtot ),'9999990.999' );
     fol_rec.SAD_156_TRSP_DOC := form_15_continue_sad_com_s( 'CPH_2',v_entry,v_entryitem,v_tariff,1,vtot );
     fol_rec.SAD_157_SUPP_UNITS := to_char(form_15_continue_sad_com_s( 'CPY',v_entry,v_entryitem,v_tariff,1,vtot ),'9999990.999' );
     fol_rec.SAD_158_ITM_PRICE := to_char(form_15_continue_sad_com_s( 'CPY_3',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999999990.99' );
-- CALCULATIONS
     stp := 'FOL [' || v_tariff || ']:B';
 num1 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AE', v_entry, v_cust )), 0);  -- total invoice
 num2 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust )), 0);  -- exchange rate
 num3 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AG', v_entry, v_cust )), 0);  -- exfreight
 num4 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AI', v_entry, v_cust )), 0);  -- insurance
 num5 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJ', v_entry, v_cust )), 0);  -- other costs
 num6 := nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'CPY_3',v_entry,v_entryitem,v_tariff,1,vtot )), 0);  -- item's invoice in foreign currency
 num7 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AGI', v_entry, v_cust )), 0); --internal freight;
 num8 := nvl(websys.glbx.guess_number(f15_parameter_range_sad_com_s( 'AJD', v_entry, v_cust )), 0); -- deductions;
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
   fol_rec.SAD_165_ADJ_RATE := '1.00'; -- strang.f15_parameter_range_sad_com_s( 'AA', v_entry,v_cust ); --JY CHANGE
   fol_rec.SAD_166_PREV_DOC := strang.f15_parameter_range_sad_com_s( 'AWWW_3', v_entry,v_cust );
   fol_rec.SAD_170_STAT_VAL := to_char((trunc(form_15_continue_sad_com_s( 'TT',v_entry,v_entryitem,v_tariff,1,vtot ))+1),'999999999990.99');  -- added trunc 20150311
 num0 := nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'CPY_3a',v_entry,v_entryitem,v_tariff,1,vtot )), 0);
   stp := 'FOL [' || v_entryitem ||' '|| v_tariff || ']:D';

 v_excise := 0;
   if num0 > 0
   then
    num13:=nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- excise rate tax amount
    num14:=nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- excise by unit tax amount
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
      v_excise := nvl(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    when num0 = 2 then
     v_excise := nvl(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    when num0 = 3 then
     v_excise := nvl(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
     v_excise := v_excise + nvl(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    end case;
   end if;
   item_taxduty := nvl(form_15_continue_sad_com_s( 'XX_2',v_entry,v_entryitem,v_tariff,1,vtot ),0) + v_excise;      -- DUTY AND EXCISE
   item_taxduty := item_taxduty + nvl(form_15_continue_sad_com_s( 'SSS_2',v_entry,v_entryitem,v_tariff,1,v_excise ),0); -- GST
   item_taxduty := item_taxduty + nvl(form_15_continue_sad_com_s( 'TTT_2',v_entry,v_entryitem,v_tariff,1,v_excise ),0); -- LEVY
   fol_rec.SAD_171_ITM_TOTAMT := item_taxduty;
   fol_rec.SAD_172_ITM_TOTMOP := strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );
--   fol_rec.SAD_173_ATT_DOCUMENTS := strang.f15_parameter_range_sad_com_s( 'A20_SAD', v_entry,v_cust ); -- 20150311
   fol_rec.SAD_173_ATT_DOCUMENTS := 'LINE NO/S '|| strang.f15_parameter_range_sad_com_s( 'AT_SAD', v_entry,v_cust )||'. ATTACHED DOCUMENTS';
   fol_rec.SAD_174_IITMSUP_VAL1 := form_15_continue_sad_com_s( 'CPY_1',v_entry,v_entryitem,v_tariff,1,vtot );
   fol_rec.SAD_175_IITMSUP_VAL2 := form_15_continue_sad_com_s( 'CPY_1_1',v_entry,v_entryitem,v_tariff,1,vtot );
-- TAXES FOR ITEM
-- =================
   fol_rec.NO_OF_ITEM_TAXES := form_15_continue_sad_com_s( 'CPY_2',v_entry,v_entryitem,v_tariff,1,vtot );
   fol_rec.ITEM_DUTY_TAX_CODE := 'IMD';
   fol_rec.ITEM_DUTY_TAX_BASE_AMOUNT := to_char((trunc(form_15_continue_sad_com_s( 'TT',v_entry,v_entryitem,v_tariff,1,vtot ))+1),'999999999990.99');
   fol_rec.ITEM_DUTY_TAX_RATE := to_char(form_15_continue_sad_com_s( 'XX_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_DUTY_TAX_AMOUNT := to_char(form_15_continue_sad_com_s( 'XX_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_DUTY_TAX_MOP:= strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );

-- EXCISE
   stp := 'FOL [' || v_entryitem || ' '|| v_tariff || ']:E';

 num0 := nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'CPY_3a',v_entry,v_entryitem,v_tariff,1,vtot )), 0);
 if num0 > 0
 then
    v_excise:=0;
  num13:=nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- excise rate tax amount
   num14:=nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- excise by unit tax amount
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
   fol_rec.ITEM_EXCISE_TAX_BASE_AMOUNT := to_char(form_15_continue_sad_com_s( 'TT_IXD',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_RATE := to_char(form_15_continue_sad_com_s( 'ZZ_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_EXCISE_TAX_AMOUNT := to_char(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_MOP:= strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );
     v_excise := nvl(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    when num0 = 2 then
   fol_rec.ITEM_EXCISE_TAX_CODE := 'IXD';
   fol_rec.ITEM_EXCISE_TAX_BASE_AMOUNT := to_char(form_15_continue_sad_com_s( 'TT_IXD_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_RATE := to_char(form_15_continue_sad_com_s( 'ZZ_1_2',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_EXCISE_TAX_AMOUNT := to_char(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_MOP:= strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );
   v_excise := nvl(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
    when num0 = 3 then
   fol_rec.ITEM_EXCISE_TAX_CODE := 'IXD';
   fol_rec.ITEM_EXCISE_TAX_BASE_AMOUNT := to_char(form_15_continue_sad_com_s( 'TT_IXD',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_RATE := to_char(form_15_continue_sad_com_s( 'ZZ_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_EXCISE_TAX_AMOUNT := to_char(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE_TAX_MOP:= strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );
   fol_rec.ITEM_EXCISE1_TAX_CODE := 'IXD';
   fol_rec.ITEM_EXCISE1_TAX_BASE_AMOUNT := to_char(form_15_continue_sad_com_s( 'TT_IXD_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE1_TAX_RATE := to_char(form_15_continue_sad_com_s( 'ZZ_1_2',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_EXCISE1_TAX_AMOUNT := to_char(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_EXCISE1_TAX_MOP:= strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );
     v_excise := nvl(form_15_continue_sad_com_s( 'ZZ_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
     v_excise := v_excise + nvl(form_15_continue_sad_com_s( 'ZZ_2_2',v_entry,v_entryitem,v_tariff,1,vtot ),0);
   end case;
   end if;
-- GST BASE CALC
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G';

num9 := nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'TT',v_entry,v_entryitem,v_tariff,1,vtot )), 0);    -- item value for duty (PGK)
num10:= nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'XX_2',v_entry,v_entryitem,v_tariff,1,vtot )), 0); -- duty for item  (PGK)
num12:= num9 + num10 + v_excise ; -- gst tax base amount and also levy base amount
-- GST
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G1';
 num0 := nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'SSS_2',v_entry,v_entryitem,v_tariff,1,v_excise )), 0);
 if num0 > 0
 then
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G10';
   fol_rec.ITEM_VAT_TAX_CODE := 'GST';
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G11';
   fol_rec.ITEM_VAT_TAX_BASE_AMOUNT := to_char(num12,'999999999990.99');
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G12';
   fol_rec.ITEM_VAT_TAX_RATE := to_char(form_15_continue_sad_com_s( 'SSS_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G13';
   fol_rec.ITEM_VAT_TAX_AMOUNT := to_char(form_15_continue_sad_com_s( 'SSS_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G14';
   fol_rec.ITEM_VAT_TAX_MOP:= strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );
 end if;
 -- LEVY
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G2';
  num0 := nvl(websys.glbx.guess_number(form_15_continue_sad_com_s( 'TTT_2',v_entry,v_entryitem,v_tariff,1,v_excise )), 0);
 if num0 > 0
 then
   fol_rec.ITEM_LEVY_TAX_CODE := 'LVY';
   fol_rec.ITEM_LEVY_TAX_BASE_AMOUNT := to_char(num12,'999999999990.99');
   fol_rec.ITEM_LEVY_TAX_RATE := to_char(form_15_continue_sad_com_s( 'TTT_1',v_entry,v_entryitem,v_tariff,1,vtot ),'99999999990.999');
   fol_rec.ITEM_LEVY_TAX_AMOUNT := to_char(form_15_continue_sad_com_s( 'TTT_2',v_entry,v_entryitem,v_tariff,1,vtot ),'999999999990.99');
   fol_rec.ITEM_LEVY_TAX_MOP:= strang.f15_parameter_range_sad_com_s( 'A19_SAD', v_entry,v_cust );
 end if;
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:G3';
fol_rec.SAD_179_IITMINV_VALC := to_char(form_15_continue_sad_com_s( 'CPY_3',v_entry,v_entryitem,v_tariff,1,vtot ),'99999990.99');
fol_rec.SAD_180_IITMINV_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );
fol_rec.SAD_181_IITMINV_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999');
fol_rec.SAD_182_IITMINV_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); --JY CHANGE
fol_rec.SAD_183_IITMINV_VALN := to_char(item_inv, '99999990.00');
stp := 'FOL [' || v_entryitem || ' ' || v_tariff || ']:H';
 if item_exf_fc > 0
 then
  fol_rec.SAD_184_IITMEFR_VALC := to_char(item_exf_fc, '99999990.00');   -- [N11] ITEM 1 EXTERNAL FREIGHT IN FOREIGN CURRENCY 184/34          SAD_IITMEFR_VALC             SAD_IITMEFR_VALC
  fol_rec.SAD_185_IITMEFR_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust ); -- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 EXTERNAL FREIGHT 185/35     SAD_IITMEFR_CUR
  fol_rec.SAD_186_IITMEFR_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 EXTERNAL FREIGHT 186/36 SAD_IITMEFR_RAT
  fol_rec.SAD_187_IITMEFR_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust );		     -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 187/-                      SAD_IITMEFR_REF --JY CHANGE
  fol_rec.SAD_188_IITMEFR_VALN := to_char(item_exf, '99999990.00');   -- [N11] ITEM 1 EXTERNAL FREIGHT IN NATIONAL CURR 188/37             SAD_IITMEFR_VALN
 else
    fol_rec.SAD_184_IITMEFR_VALC :=  '0.00';
    fol_rec.SAD_187_IITMEFR_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); --JY CHANGE
    fol_rec.SAD_188_IITMEFR_VALN := '0.00';
 end if;
--
 if item_ins_fc > 0
 then
  fol_rec.SAD_189_IITMINS_VALC := to_char(item_ins_fc, '99999990.00');   -- [N11] ITEM 1 INSURANCE IN FOREIGN CURRENCY 189/38            SAD_IITMINS_VALC
  fol_rec.SAD_190_IITMINS_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust ); -- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INSURANCE 190/39       SAD_IITMINS_CUR
  fol_rec.SAD_191_IITMINS_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INSURANCE 191/40   SAD_IITMINS_RAT
  fol_rec.SAD_192_IITMINS_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 192/-                 SAD_IITMINS_REF --JY CHANGE
  fol_rec.SAD_193_IITMINS_VALN := to_char(item_ins, '99999990.00');   -- [N11] ITEM 1 INSURANCE IN NATIONAL CURR 193/41               SAD_IITMINS_VALN
 else
    fol_rec.SAD_189_IITMINS_VALC := '0.00';
    fol_rec.SAD_192_IITMINS_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); --JY CHANGE
    fol_rec.SAD_193_IITMINS_VALN := '0.00';
 end if;
--
 if item_oc_fc > 0
 then
  fol_rec.SAD_194_IITMOTC_VALC := to_char(item_oc_fc, '99999990.00');   -- [N11] ITEM 1 OTHER COST AMT IN FOREIGN CURRENCY 194/42              SAD_IITMOTC_VALC
  fol_rec.SAD_195_IITMOTC_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 OTHER COST AMT 195/43       SAD_IITMOTC_CUR
  fol_rec.SAD_196_IITMOTC_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 OTHER COST AMT 196/44   SAD_IITMOTC_RAT
  fol_rec.SAD_197_IITMOTC_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 197/-                        SAD_IITMOTC_REF --JY CHANGE
  fol_rec.SAD_198_IITMOTC_VALN := to_char(item_oc, '99999990.00');   -- [N11] ITEM 1 OTHER COST AMT IN NATIONAL CURR 198/45                 SAD_IITMOTC_VALN
 else
    fol_rec.SAD_194_IITMOTC_VALC := '0.00';
    fol_rec.SAD_197_IITMOTC_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); --JY CHANGE
    fol_rec.SAD_198_IITMOTC_VALN := '0.00';
 end if;

--
 if item_inf_fc > 0
 then
  fol_rec.SAD_199_IITMIFR_VALC := to_char(item_inf_fc, '99999990.00');   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN FOREIGN CURRENCY 199/46              SAD_IITMIFR_VALC
  fol_rec.SAD_200_IITMIFR_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INTERNAL FREIGHT AMT 200/47       SAD_IITMIFR_CUR
  fol_rec.SAD_201_IITMIFR_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INTERNAL FREIGHT AMT 201/48   SAD_IITMIFR_RAT
  fol_rec.SAD_202_IITMIFR_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 202/- SAD_IITMIFR_REF --JY CHANGE
  fol_rec.SAD_203_IITMIFR_VALN := to_char(item_inf, '99999990.00');   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN NATIONAL CURR 203/49                 SAD_IITMIFR_VALN
 else
  fol_rec.SAD_199_IITMIFR_VALC := '0.00';	     -- [N11] ITEM 1 INTERNAL FREIGHT IN FOREIGN CURRENCY 199/46                  SAD_IITMIFR_VALC
  fol_rec.SAD_202_IITMIFR_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 202/- SAD_IITMIFR_REF -- JY CHANGE
  fol_rec.SAD_203_IITMIFR_VALN := '0.00';             -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN NATIONAL CURR 203/49                 SAD_IITMIFR_VALN
 end if;
--
 if item_ded_fc > 0
 then
  fol_rec.SAD_204_IITMDED_VALC := to_char(item_ded_fc, '99999990.00');   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN FOREIGN CURRENCY 204/50  SAD_IITMDED_VALC
  fol_rec.SAD_205_IITMDED_CUR := f15_parameter_range_sad_com_s( 'AF', v_entry, v_cust );-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INTERNAL FREIGHT AMT 205/51       SAD_IITMDED_CUR
  fol_rec.SAD_206_IITMDED_RAT := to_char(f15_parameter_range_sad_com_s( 'A9', v_entry, v_cust ),'990.9999'); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INTERNAL FREIGHT AMT 206/52   SAD_IITMDED_RAT
  fol_rec.SAD_207_IITMDED_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 207/- SAD_IITMDED_REF --JY CHANGE
  fol_rec.SAD_208_IITMDED_VALN := to_char(item_ded, '99999990.00');   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN NATIONAL CURR 208/53                 SAD_IITMDED_VALN
 else
 fol_rec.SAD_204_IITMDED_VALC := '0.00';	     -- [N11] ITEM 1 DEDUCTIONS IN FOREIGN CURRENCY 204/50                  SAD_IITMDED_VALC
 fol_rec.SAD_207_IITMDED_REF := '1'; -- f15_parameter_range_sad_com_s( 'AA', v_entry, v_cust ); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 207/-                        SAD_IITMDED_REF -- JY CHANGE
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

 vtot := to_number(form_15_continue_sad_com_s( 'N',v_entry, c2arec.entry_item,c2arec.cola,1,null ));

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

 f_dir := nvl(WEBSYS.GLBX.EXTRACT_MASTER_PARAMETER('MAIL_OUTPUT_DIR'),'C:\TEMP');
-- f_name := 'SAD_' || strang.ent_com.get_entry_no(v_entry,'C')||'_'||strang.ent_com.get_entry_no(v_entry,'X') || '.sad';
 f_name := strang.ent_com.get_entry_no(v_entry,'C')||'_'||strang.ent_com.get_entry_no(v_entry,'X') || '.sad';
 -- f := utl_file.fopen(f_dir,f_name,'wb',32000);
 dbms_lob.createtemporary(src_blb, TRUE);
 dbms_lob.createtemporary(dst_blb, TRUE);
 sad_file_len := 0;

-- PART 0 : FORMAT DESCRIPTION FIELD (ASYCUDA++ TECHNICAL DOC V1.3 - SAD FILE STRUCTURE)
-- =====================================================================================
-- xxx move these to end of procedure
-- v_buf := '1' || rep_chr(0);                   -- 1
-- v_buf := v_buf || '9607' || rep_chr(0);       -- [NUMBER] FILE LENGTH
 v_buf := v_buf || rep_chr(1);
 v_buf := v_buf || rep_chr(0,3);
 v_buf := v_buf || rep_chr(1);
 v_buf := v_buf || rep_chr(0,7);
 v_buf := v_buf || rep_chr(1);
 v_buf := v_buf || rep_chr(0,19);
 v_buf := v_buf || rep_chr(to_number(gen_rec.SAD_028_ITM_TOTAL));
 v_buf := v_buf || rep_chr(0,3);
 v_buf := v_buf || rep_chr(to_number(gen_rec.SAD_028_ITM_TOTAL));
 v_buf := v_buf || rep_chr(0,3);
 v_buf := v_buf || rep_chr(to_number(gen_rec.SAD_028_ITM_TOTAL));
 v_buf := v_buf || rep_chr(0,7);

-- PART 1 : GENERAL DATA  (ASYCUDA++ TECHNICAL DOC V1.3 - SAD FILE STRUCTURE)
-- =====================================================================================
 v_buf := v_buf || to_char(sysdate, 'YYYY') || rep_chr(0);        -- [N4] YEAR() 14/20 SAD_USER_YEAR
 v_buf := v_buf || add_field(gen_rec.SAD_015_CUO_COD, 3);         -- A3 [AN5] [CUSTOMS CLEARANCE OFFICE CODE - REF UNCUOTAB] 15/0 SAD_CUO_CODE
 v_buf := v_buf || add_field(gen_rec.SAD_016_DECLARANT, 17);    -- AD [AN17] [DECLARANT CODE - REF UNDECTAB] 16/36 SAD_DECLARANT
 v_buf := v_buf || add_field(gen_rec.SAD_017_USER_NBER, 11);    -- AH [AN11] ENTRYNO 17/21 SAD_USER_NBER
 v_buf := v_buf || add_field('1', 3);           -- 1   18 [flow number 0 for export 1 for import
 v_buf := v_buf || add_field(gen_rec.SAD_019_TYP_DEC, 3);   -- [AN3] [?TYPE OF DECLARATION - REF UNMODTAB] 19/2 SAD_TYP_DEC
 v_buf := v_buf || add_field(gen_rec.SAD_020_TYP_PROC, 1);   -- [N1] [?DECLARATION GENERAL PROCEDURE - REF UNCPLTAB] 20/3 SAD_TYP_PROC
 v_buf := v_buf || rep_chr(0,2);                -- 21/4, 22/1 UNUSED
 v_buf := v_buf || add_field(to_char(sysdate, 'YYYY'), 28); -- AHH? [AN28] MANIFEST NUMBER 23/6 SAD_MANIF_NBER
-- v_buf := v_buf || add_field(gen_rec.SAD_023_MANIF_NBER, 28); -- AHH? [AN28] MANIFEST NUMBER 23/6 SAD_MANIF_NBER -- 20150821
 v_buf := v_buf || rep_chr(0,4);                -- 24/11, 25/12, 26/13, 27/14 UNUSED
 v_buf := v_buf || add_field(gen_rec.SAD_028_ITM_TOTAL, 3);          -- A00 [N3] [TOTAL NUMBER OF ITEMS] 28/18 SAD_ITM_TOTAL
 v_buf := v_buf || add_field(gen_rec.SAD_029_PACK_TOTAL, 6);        -- A000 [NUMBER (6] [TOTAL NUMBER OF PACKAGES] 29/19 SAD_PACK_TOTAL
 v_buf := v_buf || add_field(gen_rec.SAD_030_CONSIGNEE, 17);      -- A5 [AN17] [8] [IMPORTER TC NO CODE - REF UNCMPTAB] 30/22 SAD_CONSIGNEE
 v_buf := v_buf || add_field(gen_rec.SAD_031_FINANCIAL, 17);      -- A5  [AN17] [9] [PERSON RESP. FOR FIN SETTLEMENT TC NO CODE - REF UNCMPTAB] 31/23 SAD_FINANCIAL
 v_buf := v_buf || add_field(gen_rec.SAD_032_CTY_1DLP, 3);     -- AU [AN3] [10] [COUNTRY OF LAST CONSIGNMENT] [REF - UNCTYTAB] 32/32 SAD_CTY_1DLP
 v_buf := v_buf || add_field(gen_rec.SAD_033_TRA_CTY, 3);          -- AU [AN3] [11] [TRADING COUNTRY] [REF - UNCTYTAB] 33/33 SAD_TRA_CTY
 v_buf := v_buf || add_field(gen_rec.SAD_034_VAL_DETAILS, 15);    -- ((AG+AI+AJ+AGI-AJD)/CURR) [VAL DETAILS IN KINA]  34/34 SAD_VALUE_DETAILS 20150312
 v_buf := v_buf || rep_chr(0);                  -- 35/35 UNUSED
 v_buf := v_buf || add_field(gen_rec.SAD_036_CTY_EXPCOD, 3); -- AU [AN3] [15C] [COUNTRY EXPORT CODE] [REF - UNCTYTAB] 36/39 SAD_CTY_EXPCOD
 v_buf := v_buf || rep_chr(0);                  -- 37/40 UNUSED
 v_buf := v_buf || add_field(gen_rec.SAD_038_CTY_DESTCOD, 3);        -- PG [AN3] [17C] [COUNTRY DESTINATION CODE] [REF - UNCTYTAB] 38/41 SAD_CTY_DESTCOD
 v_buf := v_buf || rep_chr(0);                  -- 39/42 UNUSED
 v_buf := v_buf || add_field(gen_rec.SAD_040_TRSP_IDDEPAR, 26);   -- AS  [AN26] 40/47 SAD_TRSP_IDDEPAR
--JY CHANGE v_buf := v_buf || add_field(gen_rec.SAD_041_TRSP_NATDEPAR, 3);  -- AU [AN3]  [FLAG] [REF - UNCTYTAB] 41/48 SAD_TRSP_NATDEPAR
 v_buf := v_buf || rep_chr(0);                  -- 41/48 SAD_TRSP_NATDEPAR -- JY CHANGE
 v_buf := v_buf || add_field(gen_rec.SAD_042_CTNR_FLAG, 1); -- 1  [0 OR 1] [19 CT] [APPEARED 0 FOR AIR IN 92038670/562] 42/49 SAD_CTNR_FLAG
 v_buf := v_buf || add_field(gen_rec.SAD_043_TOD_COD, 3);  -- A8 [AN3] [REF - UNTODTAB] 43/50 SAD_TOD_COD [SGLMS TERMS_OF_DELIVERY]
 v_buf := v_buf || add_field(gen_rec.SAD_044_TOD_NAM, 17); -- AB [AN17] 44/51 SAD_TOD_NAM
 v_buf := v_buf || rep_chr(0,3);                --  UNUSED 45/52, 46/53, 47/54
 v_buf := v_buf || add_field(gen_rec.SAD_048_CUR_COD, 3);  -- AC [AN3] [22] [INVOICE CURRENCY CODE] [REF - UNCURTAB] 48/55 SAD_CUR_COD
 v_buf := v_buf || add_field(gen_rec.SAD_049_TOT_INVOICED, 11);  -- AE [N11]  [22] [TOTAL INVOICE AMOUNT] 49/56 SAD_TOT_INVOICED
 v_buf := v_buf || rep_chr(0,2);                --  UNUSED 50/58, 51/59
 v_buf := v_buf || add_field(gen_rec.SAD_052_MOT_BORD, 1);  -- 1  [N1 OR AN3]  [25] [MODE OF TRANSPORT][ 1 (sea),4 (air), 5 (postal delivery)] 52/61 SAD_MOT_BORD
 v_buf := v_buf || rep_chr(0);                --  UNUSED 53/62
 v_buf := v_buf || add_field(gen_rec.SAD_054_LOP_COD, 5);       -- A3 [AN5] [27] [PORT OF DISCHARGE] [REF - UNLOCTAB] 54/63 SAD_LOP_COD
 v_buf := v_buf || add_field(gen_rec.SAD_055_TOP_COD, 3);       -- 99 [AN3] [28] [TERMS OF PAYMENT] [REF - UNTOPTAB] 55/66 SAD_TOP_COD [SGLMS TERMS_OF_PAYMENT]
 v_buf := v_buf || add_field(gen_rec.SAD_056_CUO_BORD, 5);         -- A3 [AN5] [29] [OFFICE OF ENTRY]  [REF - UNCUOTAB] 56/69 SAD_CUO_BORD
 v_buf := v_buf || add_field(gen_rec.SAD_057_LOC_GOODS, 17);  -- ?  [AN17] [30] [LOCATION OF GOODS/TEMPORARY SHED] [REF - UNSHDTAB][APPEARED AS JAS1 FOR AIR IN 92038670/562] 57/71 SAD_LOC_GOODS
 v_buf := v_buf || add_field(gen_rec.SAD_058_BNK_COD,11);   -- ?  [AN11] [28] [BANK CODE] [REF - UNBNKTAB] 58/60 SAD_BNK_COD [SGLMS BANK_CODE]
 v_buf := v_buf || add_field(gen_rec.SAD_059_BNK_BRA, 17);     -- ?  [AN17] [28] [BRANCH] [REF - UNBRATAB] 59/72 SAD_BNK_BRA [SGLMS BRANCH]
 v_buf := v_buf || add_field(gen_rec.SAD_060_BNK_FNBER, 17);  --  ENTRYNO [AN17] [BANK REF NO] 60/73 SAD_BNK_FNBER [SGLMS BANK_REF_NO] -- 20150311
 v_buf := v_buf || rep_chr(0);                --  UNUSED 61/116
 v_buf := v_buf || substr(gen_rec.SAD_062_WHS_COD,1,17) || add_field(gen_rec.SAD_063_WHS_TIME, 4); -- OPTIONAL [AN17 / N4] [49] [IDENTIFICATION OF WAREHOUSE / WAREHOUSE TIME DELAY] [[REF - UNWHSTAB] 62/117 AND 63/118 SAD_WHS_COD AND SAD_WHS_TIME
 v_buf := v_buf || rep_chr(0,8);                --  UNUSED 64/129, 65/146, 66/147, 67/148, 68/154, 69/155, 70/156,
 v_buf := v_buf || add_field(nvl(gen_rec.SAD_071_GRTY_AMOUNT,'0.00'), 11);   -- ? [N11] [GUARANTEE AMOUNT] 71/162 SAD_GRTY_AMOUNT -- JY CHANGE
 v_buf := v_buf || add_field(gen_rec.SAD_072_GRTY_DATE, 10);  --  [N10] [GUARRANTEE DATE] 72/163 SAD_GRTY_DATE

-- CALCULATION OF TAXES AND DUTIES FOR ENTRY
-- =========================================
v_buf := v_buf || add_field(gen_rec.SAD_073_TOT_FEES, 15);        -- ? [N15] [FEE]      73/169 SAD_TOT_FEES
--JY CHANGE v_buf := v_buf || add_field(gen_rec.SAD_074_TOTAL_TAXES, 15);    -- B4 [N15] [TOTAL DECLARATION] 74/172 SAD_TOTAL_TAXES
v_buf := v_buf || add_field(gen_rec.SAD_073_TOT_FEES, 15);    --JY CHANGE    -- ? [N15] [FEE]      73/169 SAD_TOT_FEES
-- v_buf := v_buf || 'TOTAL DECLARATION ' || TOT_DEC || ' ' || add_field(f15_parameter_range_sad_com_s( 'B4_SAD', v_entry, v_cust ), 15);    -- B4 [N15] [TOTAL DECLARATION] 74/172 SAD_TOTAL_TAXES
 v_buf := v_buf || gen_rec.SAD_075_CTRL_RESULTS  || rep_chr(0);          -- ????????
 v_buf := v_buf || rep_chr(0,3);                --  UNUSED
-- v_buf := v_buf || gen_rec.SAD_077_DEC_DATE || rep_chr(0);     -- ? [DATE] [54] [DECLARATION DATE] 77/199 SAD_DEC_DATE -- COMMENTED OUT 20150311
v_buf := v_buf || rep_chr(0);  -- ADDED 20150311
 v_buf := v_buf || gen_rec.SAD_080_NOT_DEFINED || rep_chr(0);            -- ????????

-- PART 2: VALUATION NOTE - EXPORT (ASYCUDA++ TECHNICAL DOC V1.3 - SAD FILE STRUCTURE) NOT APPLICABLE AT PRESENT TIME
-- =====================================================================================

-- PART 3: VALUATION NOTE - IMPORT (ASYCUDA++ TECHNICAL DOC V1.3 - SAD FILE STRUCTURE)
-- =====================================================================================
 v_buf := v_buf || add_field(gen_rec.SAD_081_ITOTINV_VALC, 11);     -- AE [N11] [22] [TOTAL INVOICE AMOUNT IN FOREIGN CURRENCY] 81/1 SAD_ITOTINV_VALC
 v_buf := v_buf || add_field(gen_rec.SAD_082_ITOTINV_CUR, 3);      -- AF [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 82/2 SAD_ITOTINV_CUR
 v_buf := v_buf || add_field(gen_rec.SAD_083_ITOTINV_RAT,8);       -- A9 [N8] [23] [EXCHANGE RATE] 83/3 SAD_ITOTINV_RAT
 v_buf := v_buf || add_field(gen_rec.SAD_084_ITOTINV_REF, 7);  -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR OR CURRENCY MULTIPLYING CO-EFFICIENT] 84/- SAD_ITOTINV_REF
 v_buf := v_buf || add_field(gen_rec.SAD_085_ITOTINV_VALN, 11);   -- AE/A9 [N11] [INVOICE AMT IN PGK] 85/4 SAD_ITOTINV_VALN
-- BELOW VARIES DEPENDING ON TRADING TERMS I.E. WHETHER FOB, CIF, CNF
-- EXTERNAL FREIGHT
   v_buf := v_buf || add_field(gen_rec.SAD_086_ITOTEFR_VALC, 11);      -- AG [N11] [EXTERNAL FREIGHT IN AUD] 86/5 SAD_ITOTEFR_VALC
   v_buf := v_buf || add_field(gen_rec.SAD_087_ITOTEFR_CUR, 3);        -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 87/6 SAD_ITOTEFR_CUR
   v_buf := v_buf || add_field(gen_rec.SAD_088_ITOTEFR_RAT,8);       -- A9  [N8] [23] [EXCHANGE RATE] 88/7 SAD_ITOTEFR_RAT
   v_buf := v_buf || add_field(gen_rec.SAD_089_ITOTEFR_REF, 7);      -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 89/- SAD_ITOTEFR_REF
   v_buf := v_buf || add_field(gen_rec.SAD_090_ITOTEFR_VALN, 11);    -- AG/A9 [EXTERNAL FREIGHT IN PGK] 90/8 SAD_ITOTEFR_VALN
-- INSURANCE
   v_buf := v_buf || add_field(gen_rec.SAD_091_ITOTINS_VALC, 11);       -- AI [N11] [INSURANCE IN AUD] 91/9 SAD_ITOTINS_VALC
   v_buf := v_buf || add_field(gen_rec.SAD_092_ITOTINS_CUR, 3);        -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 92/10 SAD_ITOTINS_CUR
   v_buf := v_buf || add_field(gen_rec.SAD_093_ITOTINS_RAT,8);       -- A9  [N8] [23] [EXCHANGE RATE] 93/11 SAD_ITOTINS_RAT
   v_buf := v_buf || add_field(gen_rec.SAD_094_ITOTINS_REF, 7);      -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 94/- SAD_ITOTINS_REF
   v_buf := v_buf || add_field(gen_rec.SAD_095_ITOTINS_VALN, 11);    -- AI/A9 [INSURANCE IN PGK] 95/12 SAD_ITOTINS_VALN
-- OTHER COSTS
   v_buf := v_buf || add_field(gen_rec.SAD_096_ITOTOTC_VALC, 11);       -- AJ [N11][OTHER COSTS IN AUD] 96/13 SAD_ITOTOTC_VALC
   v_buf := v_buf || add_field(gen_rec.SAD_097_ITOTOTC_CUR, 3);        -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 97/14 SAD_ITOTOTC_CUR
   v_buf := v_buf || add_field(gen_rec.SAD_098_ITOTOTC_RAT,8);       -- A9  [N8] [23] [EXCHANGE RATE] 98/15 SAD_ITOTOTC_RAT
   v_buf := v_buf || add_field(gen_rec.SAD_099_ITOTOTC_REF, 7);      -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 99/- SAD_ITOTOTC_REF
   v_buf := v_buf || add_field(gen_rec.SAD_100_ITOTOTC_VALN, 11);    -- -- AJ/A9  [OTHER COSTS AMOUNT IN PGK] 100/16 SAD_ITOTOTC_VALN
-- INTERNAL FREIGHT
   v_buf := v_buf || add_field(gen_rec.SAD_101_ITOTIFR_VALC, 11);   -- [NUMBER11] 101/17 SAD_ITOTIFR_VALC & [AN3] 102/18 SAD_ITOTIFR_CUR & [NUMBER 8] 103/19 SAD_ITOTIFR_RAT
   v_buf := v_buf || add_field(gen_rec.SAD_102_ITOTIFR_CUR, 3);        -- AF  [AN3] [22] [CURRENCY CODE] [REF - UNCURTAB] 102/18 SAD_ITOTIFRC_CUR
   v_buf := v_buf || add_field(gen_rec.SAD_103_ITOTIFR_RAT,8);       -- A9  [N8] [23] [EXCHANGE RATE] 103/19 SAD_ITOTIFR_RAT
   v_buf := v_buf || add_field(gen_rec.SAD_104_ITOTIFR_REF, 7);      -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 104/- SAD_ITOTIFR_REF
   v_buf := v_buf || add_field(gen_rec.SAD_105_ITOTIFR_VALN, 11);    -- -- [NUMBER 11] AGI/A9  [INTERNAL FREIGHT AMOUNT IN PGK] 105/20 SAD_ITOTIFR_VALN
-- DEDUCTIONS
   v_buf := v_buf || add_field(gen_rec.SAD_106_ITOTDED_VALC, 11);   -- [NUMBER11] 106/21 SAD_ITOTDED_VALC
   v_buf := v_buf || add_field(gen_rec.SAD_107_ITOTDED_CUR, 3);        -- [AN3] 107/22 SAD_ITOTDED_CUR [REF - UNCURTAB]
   v_buf := v_buf || add_field(gen_rec.SAD_108_ITOTDED_RAT,8);       -- A9  [N8] [23] [EXCHANGE RATE] 108/23 SAD_ITOTDED_RAT
   v_buf := v_buf || add_field(gen_rec.SAD_109_ITOTDED_REF, 7);      -- IN EXAMPLES ALWAYS 1.00000? [N5] [RATIO FACTOR] ? 109/- SAD_ITOTDED_REF
   v_buf := v_buf || add_field(gen_rec.SAD_110_ITOTDED_VALN, 11);    -- -- [NUMBER 11] AJD/A9  [DEDUCTIONS AMOUNT IN PGK] 110/24 SAD_ITOTDED_VALN
-- TOTALS
   v_buf := v_buf || add_field(gen_rec.SAD_111_ITOTADD_CST, 15);    -- [NUMBER 15] ((AG+AI+AJ+AGI-AJD)/A9) [TOTAL COSTS IN PGK]  111/26 SAD_ITOTADD_CST
--
   v_buf := v_buf || add_field(gen_rec.SAD_112_ICIF_VALN, 15);    -- [NUMBER 15] AE/A9 + ((AG+AI+AJ+AGI-AJD)/A9)  [INVOICE TOTAL+ TOTAL COSTS IN PGK] 112/27 SAD_ICIF_VALN
   v_buf := v_buf || rep_chr(0,2);  -- UNUSED 113/25, 114/28

 -- PART 4: OCCASIONAL DATA - EXPORTER (ASYCUDA++ TECHNICAL DOC V1.3 - SAD FILE STRUCTURE)
-- =====================================================================================
 v_buf := v_buf || add_field(gen_rec.SAD_115_EXP_NAM, 35);  -- A4 [AN35] [EXPORTER] 115/7 SAD_EXP_NAM
 v_buf := v_buf || add_field(gen_rec.SAD_116_EXP_ADD1, 35);   -- A4X [AN35] [ADDRESS] 116/8 SAD_EXP_ADD1
 v_buf := v_buf || add_field(gen_rec.SAD_118_EXP_CITY, 35);   -- A4X1 [AN35] [ADDRESS] 118/16 SAD_EXP_CITY     -- 20150312
 v_buf := v_buf || add_field(gen_rec.SAD_117_EXP_ADD2, 35);    -- A4XX [AN35] [ADDRESS] 117/15 SAD_EXP_ADD2
 v_buf := v_buf || add_field(gen_rec.SAD_119_EXP_ZIP, 35);    -- A4XX1 [AN35] [ADDRESS] 119/17 SAD_EXP_ZIP  -- 20150312
-- v_buf := v_buf || rep_chr(0,2);  -- UNUSED 118/16, 119/17 -- 20150312 ADDED ABOVE 2 LINES

-- PART 8 : ITEM 1  (ASYCUDA++ TECHNICAL DOC V1.3 - SAD FILE STRUCTURE)
-- =====================================================================================
 for fol_rec in c3(v_entry) loop
 v_buf := v_buf || fol_rec.SAD_131_ITM_NBER || rep_chr(0);                                          -- RNUMB [N2] [ITEM 1] 131/75 SAD_ITM_NBER
 if fol_rec.SAD_131_ITM_NBER = '1'
 then
   v_buf := v_buf || add_field(fol_rec.SAD_132_PACK_MARK1, 35);  -- AWW [AN35] [MARKS AND NUMBERS] 132/74 SAD_PACK_MARK1  -- 20150325
   v_buf := v_buf || add_field(fol_rec.SAD_133_PACK_MARK2, 35); -- AWWWW [AN35] [MARKS AND NUMBERS] 133/81 SAD_PACK_MARK2
--   v_buf := v_buf || add_field('PO/s '||fol_rec.SAD_132_PACK_MARK1, 35);  -- AWW [AN35] [MARKS AND NUMBERS] 132/74 SAD_PACK_MARK1
--   v_buf := v_buf || add_field(fol_rec.SAD_133_PACK_MARK2, 35); -- AWWWW [AN35] [MARKS AND NUMBERS] 133/81 SAD_PACK_MARK2
 else
   v_buf := v_buf || add_field(fol_rec.SAD_132_PACK_MARK1, 35);  -- AWW [AN35] [MARKS AND NUMBERS] 132/74 SAD_PACK_MARK1  -- 20150325
   v_buf := v_buf || add_field(fol_rec.SAD_133_PACK_MARK2, 35); -- AWWWW [AN35] [MARKS AND NUMBERS] 133/81 SAD_PACK_MARK2
--   v_buf := v_buf || add_field(fol_rec.SAD_139_GOODS_DESC1, 44);  -- AWWWWW AN44 [31]  139/97 SAD_GOODS_DESC1                      -- 20150325
--   v_buf := v_buf || rep_chr(0,2);
 end if;
 v_buf := v_buf || add_field(fol_rec.SAD_134_HS_COD, 8); -- CPC TMP2 [N8] [TARIFF] [REF - UNTARTAB] 134/76 SAD_HS_COD
 v_buf := v_buf || add_field(fol_rec.SAD_135_HSPREC_COD, 3);     -- [N3] [COMM CODE NATIONAL PRECISION] 135/77 SAD_HSPREC_COD
 v_buf := v_buf || rep_chr(0,2);  -- UNUSED 136/78, 137/79
 -- JY CHANGE -- v_buf := v_buf || add_field(fol_rec.SAD_138_TAR_SPC, 4);    -- [N4] [COMM CODE NATIONAL PRECISION] 138/80 SAD_TAR_SPC
 v_buf := v_buf || rep_chr(0);  -- 138/80 SAD_TAR_SPC -- JY CHANGE
 v_buf := v_buf || add_field(fol_rec.SAD_141_GOODS_DESC3, 44);  -- AWWWWW AN44 [31] 141/100 SAD_GOODS_DESC3
 v_buf := v_buf || add_field(fol_rec.SAD_140_GOODS_DESC2, 44);  -- AWWWWW AN44 [31] 140/99 SAD_GOODS_DESC2
 v_buf := v_buf || add_field(fol_rec.SAD_139_GOODS_DESC1, 44);  -- AWWWWW AN44 [31]  139/97 SAD_GOODS_DESC1
 if fol_rec.SAD_131_ITM_NBER = '1'
 then
  v_buf := v_buf || add_field(fol_rec.SAD_142_PACK_NBER, 6); -- [N6] [31] [PACKAGE NOS FOR ITEM] 142/82 SAD_PACK_NBER
  v_buf := v_buf || add_field(fol_rec.SAD_143_PACK_KINDCOD, 17);  -- [AN17] [31] [REF - UNPKGTAB] 143/83 SAD_PACK_KINDCOD
else
--  v_buf := v_buf || '1'||rep_chr(0);    -- 20150325 -- 20170413
--  v_buf := v_buf || 'XX' ||rep_chr(0);  -- 20150325 -- 20170413
  v_buf := v_buf || rep_chr(0);
  v_buf := v_buf || 'OT' ||rep_chr(0);
end if;
 v_buf := v_buf || add_field(fol_rec.SAD_144_CTY_ORIGCOD, 3);  -- [AN3] [31] [REF - UNCTYTAB] 144/85 SAD_CTY_ORIGCOD
 v_buf := v_buf || rep_chr(0);  -- UNUSED 145/86
 v_buf := v_buf || add_field(fol_rec.SAD_146_GROSS_MASS, 11); -- [N11] [38] [NET MASS] 146/87 SAD_GROSS_MASS
 v_buf := v_buf || rep_chr(0);  -- UNUSED 147/88
 if fol_rec.SAD_131_ITM_NBER = '1'
 then
 v_buf := v_buf || add_field(fol_rec.SAD_148_CTNR_NBER1, 17);  -- [AN17] [31] [CONTAINER NO] 148/89 SAD_CTNR_NBER1
 v_buf := v_buf || add_field(fol_rec.SAD_149_CTNR_NBER2, 17);  -- [AN17] [31] [CONTAINER NO] 149/90 SAD_CTNR_NBER2
 v_buf := v_buf || add_field(fol_rec.SAD_150_CTNR_NBER3, 17);  -- [AN17] [31] [CONTAINER NO] 150/91 SAD_CTNR_NBER3
 v_buf := v_buf || add_field(fol_rec.SAD_151_CTNR_NBER4, 17);  -- [AN17] [31] [CONTAINER NO] 151/92 SAD_CTNR_NBER4
 else
  v_buf := v_buf || rep_chr(0,4);
 end if;
 v_buf := v_buf || add_field(fol_rec.SAD_152_EXTD_PROC, 4); -- [N4] [37] [PROCEDURE] [EXTENDED CUSTOMS PROCEDURE CODE] [REF - UNCP4TAB] 152/93 SAD_EXTD_PROC
 v_buf := v_buf || add_field(fol_rec.SAD_153_NAT_PROC, 3); -- [N3] [37] [PROCEDURE] [NATIONAL CUSTOMS PROCEDURE CODE] [REF - UNREGTAB] 153/94 SAD_NAT_PROC
 v_buf := v_buf || add_field(fol_rec.SAD_154_NET_MASS, 11);  -- [N11] [38] [NET MASS]  [ITEM 1 ONLY] 154/95 SAD_NET_MASS
 v_buf := v_buf || rep_chr(0);  -- UNUSED 155/96
 v_buf := v_buf || add_field(fol_rec.SAD_156_TRSP_DOC, 26);  -- [AN26] [40] [BOL / SUMMARY DECL/PREVIOUS DOC] 156/98 SAD_TRSP_DOC
 v_buf := v_buf || add_field(fol_rec.SAD_157_SUPP_UNITS, 11);   -- [N11] [41] [QUANTITY] 157/101 SAD_SUPP_UNITS
 v_buf := v_buf || add_field(to_char(fol_rec.SAD_158_ITM_PRICE,'99999999999990.99' ), 17);  -- [AN17] [42] [ITEM PRICE FCY] 158/102 SAD_ITM_PRICE
-- v_buf := v_buf || rep_chr(0,4);  -- UNUSED 159/103, 160/104, 161/105, 162/106 -- JY CHANGE 20130620
v_buf := v_buf || rep_chr(0);  -- UNUSED 159/103
-- v_buf := v_buf || add_field(fol_rec.SAD_156_TRSP_DOC, 17);  -- USED FOR BOL 160/104 20150313
v_buf := v_buf || rep_chr(0);  -- UNUSED 160/104 20150313
v_buf := v_buf || rep_chr(0,2);  -- UNUSED 161/105, 162/106 -- END JY CHANGE 20130620
-- CALCULATIONS
 v_buf := v_buf || add_field(fol_rec.SAD_159_VAL_METHOD,56);      -- [AN56] [44]  = EXFREIGHT + INS + OCOSTS + INFREIGHT - DEDUCTIONS IN PGK [LINE FOR ITEM VALUE DETAILS] 163/107 SAD_VALUE_DETAILS
 v_buf := v_buf || rep_chr(0);  -- UNUSED 164/109
 v_buf := v_buf || add_field(fol_rec.SAD_165_ADJ_RATE, 10);     -- [45] ALWAYS 1.00? [N10] [RATE OF ADJUSTMENT] 165/110 SAD_ADJ_RATE
 v_buf := v_buf || add_field(fol_rec.SAD_166_PREV_DOC, 20);  -- [AN20] [44]  [PREVIOUS DOCUMENT REFERENCE] [PREVIOUS ENTRY NO???] 166/111 SAD_PREV_DOC
-- v_buf := v_buf || rep_chr(0);  -- UNUSED 167/112   -- JY CHANGE
 v_buf := v_buf || rep_chr(0);                        -- [AN35] [44]  [RESERVED FIELD : FREE TEXT] 168/113 SAD_FREE_TEXT
 if fol_rec.SAD_131_ITM_NBER = '1'
 then
  v_buf := v_buf || add_field(fol_rec.SAD_173_ATT_DOCUMENTS, 56);   -- LINE FOR ATTACHED DOCUMENTS CODES [AN56] SAD_ATT_DOCUMENTS [REF - UNATDTAB]-- JY CHANGE (MOVED POSITION)
 else
  v_buf := v_buf || rep_chr(0);
 end if;
 v_buf := v_buf || rep_chr(0);  -- UNUSED 169/114
 v_buf := v_buf || add_field(to_char(fol_rec.SAD_170_STAT_VAL,'999999999990.99'), 15); -- add_field(value_in_natcurr,15); -- [46] [N15] [VALUE FOR DUTY PGK] [STATISTICAL VALUE] [ROUNDED UP???] 170/115 SAD_STAT_VAL
-- Caclulation of total amount of duties and taxes for item
-- EXCISE
-- End of calculation of total amount of duties and taxes for item
 v_buf := v_buf || add_field(to_char(fol_rec.SAD_171_ITM_TOTAMT,'9999999990.99'), 11); -- add_field(form_15_continue_sad_com_s( 'WWW',v_entry,c2arec.cola,1,vtot ), 11); -- [47] [N11]  [TOTAL AMT OF DUTIES AND TAXES FOR ITEM] 171/170 SAD_ITM_TOTAMT
 v_buf := v_buf || add_field(fol_rec.SAD_172_ITM_TOTMOP, 1);   -- [47] [AN1] [MODE OF PAYMENT FOR TOTAL ITEM AMT] SAD_ITM_TOTMOP 172/171
 v_buf := v_buf || rep_chr(0,3);  -- UNUSED   -- JY CHANGE
-- v_buf := v_buf || add_field(fol_rec.SAD_174_IITMSUP_VAL1, 10); -- [N10] [41] [QUANTITY] SUPPLEMENTARY VALUE 1 AMOUNT 174/64 SAD_IITMSUP_VAL1
-- v_buf := v_buf || add_field(fol_rec.SAD_175_IITMSUP_VAL2, 10);  -- [N10] [41] [QUANTITY] SUPPLEMENTARY VALUE 2 (my assumptin is for excise qty) 175/39
-- JY CHANGE
 -- GLOBAL TAXES
 if fol_rec.SAD_131_ITM_NBER = '1'
 then
  v_buf := v_buf || add_field(gen_rec.GLOBAL_TAX_1, 1); -- [N1] NUMBER OF GLOBAL TAXES 176
  v_buf := v_buf || add_field(gen_rec.GLOBAL_TAX_2, 3 ) || rep_chr(0);            -- [AN3] GLOBAL TAXES CODE 1
  v_buf := v_buf || add_field(to_char(gen_rec.GLOBAL_TAX_3,999990.99999), 9); -- [N9] GLOBAL TAXES TB VALUE 3
  v_buf := v_buf || add_field(gen_rec.GLOBAL_TAX_4, 7);          -- [N7] GLOBAL TAX RATE  4
  v_buf := v_buf || add_field(to_char(gen_rec.GLOBAL_TAX_5,999990.99999 ), 9);  -- [N9] GLOBAL TAXES AMOUNT 5
  v_buf := v_buf || add_field(gen_rec.GLOBAL_TAX_6, 1);  -- [AN1] GLOBAL TAXES MPCODE 6
 end if;
-- TAXES FOR ITEM 1
-- DUTY
 v_buf := v_buf || add_field(fol_rec.NO_OF_ITEM_TAXES, 1);  -- [N1] NUMBER OF TAXES FOR ITEM 1  177
 v_buf := v_buf || fol_rec.ITEM_DUTY_TAX_CODE || rep_chr(0,2);            -- DUTY DUTY TAX CODE 1           SAD_TAXi_CODE
 v_buf := v_buf || add_field(to_char(fol_rec.ITEM_DUTY_TAX_BASE_AMOUNT,'999999999990.99'), 15); -- DUTY TAX BASE AMOUNT 3         SAD_TAXi_BASE
 v_buf := v_buf || add_field(to_char(fol_rec.ITEM_DUTY_TAX_RATE,'99999999990.999'), 15);  -- DUTY TAX RATE 4                SAD_TAXi_RATE
 v_buf := v_buf || add_field(to_char(fol_rec.ITEM_DUTY_TAX_AMOUNT,'999999999990.99'), 15);  -- DUTY TAX AMOUNT 5              SAD_TAXi_AMOUNT
 v_buf := v_buf || add_field(fol_rec.ITEM_DUTY_TAX_MOP, 1); -- DUTY MP - METHOD OF PAYMENT 6  SAD_TAXi_MOP xx_3
-- EXCISE
     if fol_rec.ITEM_EXCISE_TAX_AMOUNT is not null
     then
     v_buf := v_buf || fol_rec.ITEM_EXCISE_TAX_CODE || rep_chr(0,2);            -- (excise rate) EXCISE DUTY TAX CODE 1           SAD_TAXi_CODE
     v_buf := v_buf || add_field(to_char(fol_rec.ITEM_EXCISE_TAX_BASE_AMOUNT,'999999999990.99'), 15);	     -- EXCISE TAX BASE AMOUNT 3         SAD_TAXi_BASE
     v_buf := v_buf || add_field(to_char(fol_rec.ITEM_EXCISE_TAX_RATE,'999999999990.999'), 15);	     -- EXCISE TAX RATE 4                SAD_TAXi_RATE
     v_buf := v_buf || add_field(to_char(fol_rec.ITEM_EXCISE_TAX_AMOUNT,'999999999990.99'), 15);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
     v_buf := v_buf || add_field(fol_rec.ITEM_EXCISE_TAX_MOP, 1);  -- EXCISE MP - METHOD OF PAYMENT 6  SAD_TAXi_MOP  old zz_3
     end if;
     if fol_rec.ITEM_EXCISE1_TAX_AMOUNT is not null
     then
     v_buf := v_buf || fol_rec.ITEM_EXCISE1_TAX_CODE || rep_chr(0,2);            -- (excise unit) EXCISE DUTY TAX CODE 1           SAD_TAXi_CODE
     v_buf := v_buf || add_field(to_char(fol_rec.ITEM_EXCISE1_TAX_BASE_AMOUNT,'999999999990.99'), 15);	     -- EXCISE TAX BASE AMOUNT 3         SAD_TAXi_BASE
     v_buf := v_buf || add_field(to_char(fol_rec.ITEM_EXCISE1_TAX_RATE,'999999999990.999'), 15);	     -- EXCISE TAX RATE 4                SAD_TAXi_RATE
     v_buf := v_buf || add_field(to_char(fol_rec.ITEM_EXCISE1_TAX_AMOUNT,'999999999990.99'), 15);	     -- EXCISE TAX AMOUNT 5              SAD_TAXi_AMOUNT
     v_buf := v_buf || add_field(fol_rec.ITEM_EXCISE1_TAX_MOP, 1);  -- EXCISE MP - METHOD OF PAYMENT 6  SAD_TAXi_MOP  old zz_3
     end if;


-- GST
-- if fol_rec.ITEM_VAT_TAX_AMOUNT is not null   -- 20150311
-- then    -- 20150311
  v_buf := v_buf || NVL(fol_rec.ITEM_VAT_TAX_CODE,'GST') || rep_chr(0,2);            -- GST DUTY TAX CODE 1           SAD_TAXi_CODE
--  v_buf := v_buf || add_field(to_char(trunc(fol_rec.ITEM_VAT_TAX_BASE_AMOUNT),'999999999990.99'),15); --add_field(to_char(form_15_continue_sad_com_s( 'TT_GST',v_entry,c2arec.cola,1,vtot ),'999999999990.99'), 15);	     -- GST TAX BASE AMOUNT 3         SAD_TAXi_BASE
  v_buf := v_buf || add_field(to_char(trunc(fol_rec.ITEM_DUTY_TAX_BASE_AMOUNT - 1),'999999999990.99'),15); --add_field(to_char(form_15_continue_sad_com_s( 'TT_GST',v_entry,c2arec.cola,1,vtot ),'999999999990.99'), 15);	     -- GST TAX BASE AMOUNT 3         SAD_TAXi_BASE
  v_buf := v_buf || add_field(NVL(to_char(fol_rec.ITEM_VAT_TAX_RATE,'999999999990.999'),'0.000'), 15);	     -- GST TAX RATE 4                SAD_TAXi_RATE
  v_buf := v_buf || add_field(NVL(to_char(fol_rec.ITEM_VAT_TAX_AMOUNT,'999999999990.99'),'0.00'), 15);	     -- GST TAX AMOUNT 5              SAD_TAXi_AMOUNT
  v_buf := v_buf || add_field(NVL(fol_rec.ITEM_VAT_TAX_MOP,'1'), 1);                                   -- GST MP - METHOD OF PAYMENT 6  SAD_TAXi_MOP
-- end if;  -- 20150311
-- LEVY
 if fol_rec.ITEM_LEVY_TAX_AMOUNT is not null
 then
  v_buf := v_buf || fol_rec.ITEM_LEVY_TAX_CODE || rep_chr(0,2);            -- LEVY TAX CODE 1           SAD_TAXi_CODE
  v_buf := v_buf || add_field(fol_rec.ITEM_LEVY_TAX_BASE_AMOUNT,15); --add_field(to_char(form_15_continue_sad_com_s( 'TT_LVY',v_entry,c2arec.cola,1,vtot ),'999999999990.99'), 15);	     -- LEVY TAX BASE AMOUNT 3         SAD_TAXi_BASE
  v_buf := v_buf || add_field(to_char(fol_rec.ITEM_LEVY_TAX_RATE,'999999999990.999'), 15);	     -- LEVY TAX RATE 4                SAD_TAXi_RATE
  v_buf := v_buf || add_field(to_char(fol_rec.ITEM_LEVY_TAX_AMOUNT,'999999999990.99'), 15);	     -- LEVY TAX AMOUNT 5              SAD_TAXi_AMOUNT
  v_buf := v_buf || add_field(fol_rec.ITEM_LEVY_TAX_MOP, 1);                                   -- LEVY MP - METHOD OF PAYMENT 6  SAD_TAXi_MOP
 end if;

-- VALUATION NOTE FOR ITEM 1
 v_buf := v_buf || fol_rec.SAD_131_ITM_NBER || rep_chr(0);		     -- ITEM NUMBER 1  178
 v_buf := v_buf || add_field(to_char(fol_rec.SAD_179_IITMINV_VALC,'99999990.99'), 11);	-- [N11] ITEM 1 INVOICE AMT IN FOREIGN CURRENCY 179/30          SAD_IITMINV_VALC
 v_buf := v_buf || add_field(fol_rec.SAD_180_IITMINV_CUR, 3); -- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INVOICE AMT 180/31     SAD_IITMINV_CUR
 v_buf := v_buf || add_field(to_char(fol_rec.SAD_181_IITMINV_RAT,'990.9999'),8); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INVOICE AMT 181/32 SAD_IITMINV_RAT
 v_buf := v_buf || add_field(fol_rec.SAD_182_IITMINV_REF, 7);                -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 182/-                 SAD_IITMINV_REF
 v_buf := v_buf || add_field(to_char(fol_rec.SAD_183_IITMINV_VALN, '99999990.00'), 11);    -- [N11] AE/A9 ITEM 1 INVOICE AMT IN NATIONAL CURR 183/33             SAD_IITMINV_VALN

  v_buf := v_buf || add_field(to_char(fol_rec.SAD_184_IITMEFR_VALC, '99999990.00'), 11);   -- [N11] ITEM 1 EXTERNAL FREIGHT IN FOREIGN CURRENCY 184/34          SAD_IITMEFR_VALC             SAD_IITMEFR_VALC
  v_buf := v_buf || add_field(fol_rec.SAD_185_IITMEFR_CUR, 3); -- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 EXTERNAL FREIGHT 185/35     SAD_IITMEFR_CUR
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_186_IITMEFR_RAT,'990.9999'),8); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 EXTERNAL FREIGHT 186/36 SAD_IITMEFR_RAT
  v_buf := v_buf || add_field(fol_rec.SAD_187_IITMEFR_REF, 7);		     -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 187/-                      SAD_IITMEFR_REF
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_188_IITMEFR_VALN, '99999990.00'), 11);   -- [N11] ITEM 1 EXTERNAL FREIGHT IN NATIONAL CURR 188/37             SAD_IITMEFR_VALN          SAD_IITMEFR_VALC             SAD_IITMINV_VALN

--
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_189_IITMINS_VALC, '99999990.00'), 11);   -- [N11] ITEM 1 INSURANCE IN FOREIGN CURRENCY 189/38            SAD_IITMINS_VALC          SAD_IITMEFR_VALC             SAD_IITMINV_VALN
  v_buf := v_buf || add_field(fol_rec.SAD_190_IITMINS_CUR, 3); -- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INSURANCE 190/39       SAD_IITMINS_CUR
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_191_IITMINS_RAT,'990.9999'),8); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INSURANCE 191/40   SAD_IITMINS_RAT
  v_buf := v_buf || add_field(fol_rec.SAD_192_IITMINS_REF, 7); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 192/-                 SAD_IITMINS_REF
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_193_IITMINS_VALN, '99999990.00'), 11);   -- [N11] ITEM 1 INSURANCE IN NATIONAL CURR 193/41               SAD_IITMINS_VALN             SAD_IITMEFR_VALN          SAD_IITMEFR_VALC             SAD_IITMINV_VALN

  v_buf := v_buf || add_field(to_char(fol_rec.SAD_194_IITMOTC_VALC, '99999990.00'), 11);   -- [N11] ITEM 1 OTHER COST AMT IN FOREIGN CURRENCY 194/42              SAD_IITMOTC_VALC
  v_buf := v_buf || add_field(fol_rec.SAD_195_IITMOTC_CUR, 3);-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 OTHER COST AMT 195/43       SAD_IITMOTC_CUR
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_196_IITMOTC_RAT,'990.9999'),8); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 OTHER COST AMT 196/44   SAD_IITMOTC_RAT
  v_buf := v_buf || add_field(fol_rec.SAD_197_IITMOTC_REF, 7); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 197/-                        SAD_IITMOTC_REF
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_198_IITMOTC_VALN, '99999990.00'), 11);   -- [N11] ITEM 1 OTHER COST AMT IN NATIONAL CURR 198/45                 SAD_IITMOTC_VALN

  v_buf := v_buf || add_field(to_char(fol_rec.SAD_199_IITMIFR_VALC, '99999990.00'), 11);   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN FOREIGN CURRENCY 199/46              SAD_IITMIFR_VALC
  v_buf := v_buf || add_field(fol_rec.SAD_200_IITMIFR_CUR, 3);-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INTERNAL FREIGHT AMT 200/47       SAD_IITMIFR_CUR
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_201_IITMIFR_RAT,'990.9999'),8); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INTERNAL FREIGHT AMT 201/48   SAD_IITMIFR_RAT
  v_buf := v_buf || add_field(fol_rec.SAD_202_IITMIFR_REF, 7); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 202/- SAD_IITMIFR_REF
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_203_IITMIFR_VALN, '99999990.00'), 11);   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN NATIONAL CURR 203/49                 SAD_IITMIFR_VALN

  v_buf := v_buf || add_field(to_char(fol_rec.SAD_204_IITMDED_VALC, '99999990.00'), 11);   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN FOREIGN CURRENCY 204/50  SAD_IITMDED_VALC
  v_buf := v_buf || add_field(fol_rec.SAD_205_IITMDED_CUR, 3);-- [AN3] [UNCURTAB] CURR CODE FOR ITEM 1 INTERNAL FREIGHT AMT 205/51       SAD_IITMDED_CUR
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_206_IITMDED_RAT,'990.9999'),8); -- [N8]  [UNRATTAB] EXCHANGE RATE FOR ITEM 1 INTERNAL FREIGHT AMT 206/52   SAD_IITMDED_RAT
  v_buf := v_buf || add_field(fol_rec.SAD_207_IITMDED_REF, 7); -- [N5] CURRENCY MULTIPLYING CO-EFFICIENT 207/- SAD_IITMDED_REF
  v_buf := v_buf || add_field(to_char(fol_rec.SAD_208_IITMDED_VALN, '99999990.00'), 11);   -- [N11] ITEM 1 INTERNAL FREIGHT AMT IN NATIONAL CURR 208/53                 SAD_IITMDED_VALN

v_buf := v_buf || add_field(to_char(fol_rec.SAD_209_IITMADD_CST, '999999999990.99'), 15);   -- [N15] ADDED COSTS AMOUNT FOR ITEM 1 (national currency)  209/54    SAD_IITMADD_CST
--  v_buf := v_buf || add_field(to_char((value_in_natcurr), '999999999990.99'), 15);   -- [N15] CIF VALUE AMT IN NATIONAL CURRENCY 210/56       SAD_IITMCIF_VALN
v_buf := v_buf || add_field(to_char(fol_rec.SAD_210_IITMCIF_VALN,'999999999990.99'), 15);
v_buf := v_buf || rep_chr(0,9);

-- Write buffer into source BLOB
dbms_lob.writeappend(src_blb, length(v_buf), utl_raw.cast_to_raw(v_buf));
sad_file_len := sad_file_len + length(v_buf);
v_buf := null;

end loop;

 v_buf := v_buf || '0' || rep_chr(0);
 v_buf := v_buf || '0' || rep_chr(0);
 v_buf := v_buf || '0' || rep_chr(0);
 v_buf := v_buf || '0' || rep_chr(0);

 -- num1:=0;
 -- num1:= length(v_buf);

 -- Final write into source BLOB
dbms_lob.writeappend(src_blb, length(v_buf), utl_raw.cast_to_raw(v_buf));
sad_file_len := sad_file_len + length(v_buf);
v_buf := null;

-- v_buf := '1' || rep_chr(0) || to_char(num1) || rep_chr(0) || v_buf;       -- [NUMBER] FILE LENGTH

 -- Get length of file and put into destination BLOB
 v_buf := '1' || rep_chr(0) || to_char(sad_file_len) || rep_chr(0);       -- [NUMBER] FILE LENGTH
 dbms_lob.writeappend(dst_blb, length(v_buf), utl_raw.cast_to_raw(v_buf));

 -- Append source BLOB to destination BLOB
 dbms_lob.append(dst_blb, src_blb);

 --websys.glbx.dbg('Source BLOB     : ' || dbms_lob.getlength(src_blb));
 --websys.glbx.dbg('Destination BLOB: ' || dbms_lob.getlength(dst_blb));

 -- Write destination BLOB to file

 websys.utl_blob.blobtofile( dst_blb, f_dir || '\' || f_name, FALSE );

 dbms_lob.freetemporary(src_blb);
 dbms_lob.freetemporary(dst_blb);

 -- utl_file.put_RAW(f, utl_raw.cast_to_raw(v_buf), autoflush=>TRUE);
 -- utl_file.fclose(f);

 if websys.file_exists(f_dir,f_name)
 then
  err := 'SAD File Generated to '|| f_dir || '\' || f_name ;
  sad_file_ctr := nvl(websys.dapi.GLOBAL_ARRAY.count, 0);
  sad_file_ctr := sad_file_ctr + 1;
  websys.dapi.GLOBAL_ARRAY(sad_file_ctr) := f_dir || '\' || f_name ;
 else
  err := 'SAD File Not Generated' ;
 end if;

-- if to_number(v_entry) >= websys.dapi.GLOBAL_END_NUMBER and websys.dapi.GLOBAL_ARRAY.count > 0
--  then
  websys.strangs.email_sad_file_multi(websys.dapi.GLOBAL_SURL);
-- end if;  -- 20150824

exception when others then
-- utl_file.fclose(f);
 begin
  dbms_lob.freetemporary(src_blb);
  dbms_lob.freetemporary(dst_blb);
 exception when others then null;
 end;
websys.glbx.dbg('Generate Sad Error [' || stp || '] ' ||sqlerrm);
err := '['|| err_msg || '] Generate Sad Error at step ' || stp || ' - '||sqlerrm;
end generate_sad_sad_com_s;
/


GRANT EXECUTE ON STRANG.GENERATE_SAD_SAD_COM_S TO WEBSYS;
