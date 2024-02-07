CREATE OR REPLACE PROCEDURE WEBSYS.p_getcountry_code( Vendor_id in number, parse_text in varchar2, p_country_code out varchar2, p_state out varchar2 )
 --  return varchar2
  as
   cursor c1(v_country_txt varchar2)  is
    select c.alpha2
    from websys.temp_country_codes c
    where 
     ( CASE WHEN length(v_country_txt) > 3 THEN UPPER(c.name)
          WHEN length(v_country_txt) = 3 THEN UPPER(c.ALPHA3)
          WHEN length(v_country_txt) = 2 THEN UPPER(c.ALPHA2) else null end ) = v_country_txt;
    
   c1rec  c1%ROWTYPE;
   v_country_text varchar2(100);
   v_first_part varchar2(100);
   v_second_part varchar2(100);
   v_filler varchar2(100);

   v_part1 varchar2(100);
   v_part2 varchar2(100);
   v_part3 varchar2(100);
   v_state varchar2(100);

   begin
     
    if vendor_id = 4002397 then
       v_country_text := ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(ORIGIN CODE\s*[.:]\s*YY[-][[:alpha:]]+)\s*([[:alpha:]]+)',1,1,'i',3)));
       if v_country_text is null then
          v_part1 := ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(ORIGIN CODE\s*[.:])\s*(AU)[-]\s*([[:alpha:]]+)',1,1,'i',3)));
          v_part2 := ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(ORIGIN CODE\s*[.:]\s*AU[-])\s*([[:alpha:]]+)',1,1,'i',3)));
          if v_part1 = 'AU' then
             v_country_text := v_part1;
          end if;
          if v_part2 in ('WA','SA','NT','QL','OL','TS','VI','NS') THEN
             v_state := v_part2;
             v_state := 
             CASE 
                WHEN v_state IN ('QL', 'OL') THEN 'QLD'
                WHEN v_state = 'VI' THEN 'VIC'
                WHEN v_state = 'NS' THEN 'NSW'
                WHEN v_state = 'TS' THEN 'TAS'
                ELSE v_state
             END ; 
            glbx.dbg(' v_state '|| v_state);
            glbx.dbg(' v_country_text '|| v_country_text);
          
          end if;

       end if;   

       if v_country_text is null then
          
          v_filler := LTRIM(RTRIM(REGEXP_SUBSTR( UPPER(parse_text) , '(\s+|^)(ORIGIN CODE\s*[.:]\s*)(*.*)',1,1,'i',2)));
          if v_filler is not null then
             v_country_text := 'AU';
             v_state := 'WA';
          end if;
       end if; 
       
--       select *
--       from websys.debug order by ctr;

     --  WIRE INNERSHIELD NR212 1.7MM 11.3KG ITEM 2; STOCK CODE 10001429 COUNTRY OF ORIGIN; NEW SOUTH WALES NET WEIGHT: NET QTY:
          
    elsif vendor_id = 4002512 then 
       v_part1 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(ORIGIN\s*[:-;])\s+([[:alpha:]]+)\s*(*.*)\s*NET WE',1,1,'i',3))),'');
       v_part2 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(ORIGIN\s*[:-;])\s+([[:alpha:]]+)\s*([[:alpha:]]*)\s*(*.*)\s*NET WE',1,1,'i',4))),'');
       v_part3 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(ORIGIN\s*[:-;])\s+([[:alpha:]]+)\s+([[:alpha:]]+)\s*([[:alpha:]]*)\s*NET WE',1,1,'i',5))),'');
       
       glbx.dbg(' v_part1 '|| v_part1);
       glbx.dbg(' v_part2 '|| v_part2);
       glbx.dbg(' v_part3 '|| v_part3);
    --   FLAP DISC ZIRCONIA 127 X 22MM X 80 GRIT ITEM 13: STOCK CODE 10058121 COUNTRY OF ORIGIN: QUEENSLAND NET WEIGHT: NET QTY:
--       select *
--       from websys.debug order by ctr;
         
       if  ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) in ('VICTORIA', 'SOUTH AUSTRALIA', 'WEST AUSTRALIA', 'NEW SOUTH'
                                                                , 'QUEENSLAND', 'NEW SOUTH WALES', 'AUSTRALIAN CAPITAL TERRITORY', 'TASMANIA', 'NORTHERN TERRITORY') THEN
         v_country_text :=  'AUSTRALIA';
         v_state := case when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'VICTORIA' then 'VIC'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'SOUTH AUSTRALIA' then 'SA'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'WEST AUSTRALIA' then 'WA'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'QUEENSLAND' then 'QLD'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) LIKE 'NEW SOUTH%' then 'NSW'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'AUSTRALIAN CAPITAL TERRITORY' then 'ACT'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'TASMANIA' then 'TAS'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'NORTHERN TERRITORY' then 'NT' end;
                       
        glbx.dbg('v_state  united '||v_state );       
         
        else    
           v_country_text :=  ltrim(rtrim(v_part1||' '|| nvl(v_part2,'')||' '||nvl(v_part3,'')));
           glbx.dbg('v_country_text united '||v_country_text);
        end if;  
    elsif vendor_id in ( 4004043, 4002736, 4002024, 4003442,4006205, 4002166, 4001230,  4001512, 4000023) then
       if vendor_id in (4001230) then
          v_country_text := replace(rtrim(ltrim(upper(parse_text))),'.','');
          v_country_text := REGEXP_SUBSTR( upper(v_country_text) , '([[:alnum:] ]+)\W?([[:alnum:] ]+)\W?',1,1,'i',2);
       elsif vendor_id in (4001512) then
          v_country_text := rtrim(ltrim(upper(parse_text)));
        elsif vendor_id in (4000023) then
          v_country_text := rtrim(ltrim(upper(parse_text)));   
       else
          v_country_text := rtrim(ltrim(upper(parse_text)));
          v_country_text := REGEXP_SUBSTR( upper(v_country_text) , '([[:alnum:] ]+)\W?',1,1,'i',1);
       end if;
       --glbx.dbg('v_country_text newer '||v_country_text);
       
       if upper(v_country_text) IN ( 'AUSTRALIA', 'AUS', 'AU') and vendor_id = 4003442 THEN
          v_state := 'QLD';
       end if;
       
       
    elsif vendor_id = 4001447 then 
 
      v_second_part := REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[:-]\s* [[:alpha:]]+)\s+([[:alpha:]]+)\s+NET',1,1,'i',3);
      --glbx.dbg('v_second_part '||v_second_part);
      if  Upper(nvl(v_second_part, 'xxxx')) = 'NET' or v_second_part is null or v_second_part = '' then
         v_country_text := ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[:-])\s*([[:alpha:]]+)\s+NET',1,1,'i',3)));
      ELSE
         v_country_text := ltrim(rtrim(v_second_part));
         v_first_part := REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[:-])\s* ([[:alpha:]]+)\s+([[:alpha:]]+)\s+NET',1,1,'i',3);
         --glbx.dbg('v_first_part '||v_first_part);
         IF v_first_part IN ( 'QLD', 'NSW', 'VIC','WA','SA', 'TAS') THEN
            v_state := v_first_part;
            v_first_part := null;
         END IF;
         
         v_first_part := null;
      END IF;

      if v_country_text is null then 
      
          v_filler := LTRIM(RTRIM(REGEXP_SUBSTR( UPPER(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[-:]\s*)',1,1,'i',2)));
          if v_filler is not null then
             v_country_text := 'AU';
             v_state := 'QLD';
          end if;
       end if; 
       
      
    elsif vendor_id = 4002398 then
    
       v_country_text := ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(HS\s*[[:digit:]]+[.][[:digit:]]+)\s*([[:alpha:]]+)',1,1,'i',3)));
       glbx.dbg('v_country_text '||v_country_text);
       
       if upper(v_country_text) IN ( 'AUSTRALIA', 'AUS', 'AU') THEN
          v_state := 'NSW';
       elsif upper(v_country_text) is null then
          v_country_text := 'AU';
          v_state := 'NSW';
       end if; 
       
    elsif vendor_id in (  4002545, 9001199) then
    
       v_part1 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(OR[I]*GIN\s*[:-])\s+([[:alpha:]]+)',1,1,'i',3))),'');
       v_part2 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(OR[I]*GIN\s*[:-])\s+([[:alpha:]]+)\s*([[:alpha:]]*)',1,1,'i',4))),'');
       v_part3 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(OR[I]*GIN\s*[:-])\s+([[:alpha:]]+)\s*([[:alpha:]]*)\s*([[:alpha:]]*)',1,1,'i',5))),'');
       
       glbx.dbg(' v_part1 '|| v_part1);
       glbx.dbg(' v_part2 '|| v_part2);
       glbx.dbg(' v_part3 '|| v_part3);
       
       if  ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) in ('VICTORIA', 'SOUTH AUSTRALIA', 'WEST AUSTRALIA', 'NEW SOUTH'
                                                                , 'QUEENSLAND', 'NEW SOUTH WALES', 'AUSTRALIAN CAPITAL TERRITORY', 'TASMANIA', 'NORTHERN TERRITORY') THEN
         v_country_text :=  'AUSTRALIA';
         v_state := case when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'VICTORIA' then 'VIC'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'SOUTH AUSTRALIA' then 'SA'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'WEST AUSTRALIA' then 'WA'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'QUEENSLAND' then 'QLD'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) LIKE 'NEW SOUTH%' then 'NSW'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'AUSTRALIAN CAPITAL TERRITORY' then 'ACT'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'TASMANIA' then 'TAS'
                         when ltrim(rtrim(v_part1||' '|| v_part2||' '||v_part3)) = 'NORTHERN TERRITORY' then 'NT' end;
                       
        glbx.dbg('v_state  united '||v_state );       
         
        elsif v_part2 = 'PACK' then 
           v_country_text :=  ltrim(rtrim(v_part1));
        else      
           v_country_text :=  ltrim(rtrim(v_part1||' '|| nvl(v_part2,'')||' '||nvl(v_part3,'')));
           glbx.dbg('v_country_text united '||v_country_text);
        end if;                                                     
                                                                
    elsif vendor_id in ( 4001974) then  
         
          v_country_text := ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(MADE IN)\s*([[:alpha:]]+['']*[[:alpha:]]*)',1,1,'i',3)));

           glbx.dbg('v_country_text EU  united '||v_country_text );   

          if v_country_text = 'EU' then 
             v_country_text := 'GERMANY';
          elsif v_country_text = 'AFRICA' then
             v_country_text := 'ZA'; 
          elsif v_country_text IN ( 'QLD', 'NSW', 'VIC','WA','SA', 'TAS') then 
              v_state := v_country_text;
              v_country_text := 'AU'; 
          elsif v_country_text IN ( 'S''AUST', 'S''AUSTRALIA') then 
              v_state := 'SA';
              v_country_text := 'AU'; 
          end if;
                
    elsif vendor_id = 4001579 then
       v_part1 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(OR[I]*GIN\s*[:-])\s+([[:alpha:]]+)',1,1,'i',3))),'');   
       if v_part1 in ( 'QLD', 'NSW', 'VIC','WA','SA', 'TAS') THEN 
           v_state := v_part1;
           v_country_text := 'AU';
       else
         v_country_text := REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[:-]\s* [[:alpha:]]+)',1,1,'i',2);
         v_country_text := upper(rtrim(ltrim(replace(replace(replace(upper(v_country_text),'COUNTRY OF ORIGIN',''),':',''),'-',''))));    
       end if;
       if v_country_text = 'UK' then v_country_text := 'GB'; end if;
    elsif vendor_id = 4002092 then
     --     v_part1 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(ORIGIN\s*[:-;])\s+([[:alpha:]]+)\s*(*.*)\s*NET WE',1,1,'i',3))),'');
    --   v_part2 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(ORIGIN\s*[:-;])\s+([[:alpha:]]+)\s*([[:alpha:]]*)\s*(*.*)\s*NET WE',1,1,'i',4))),'');
    
    
       v_part1 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(OR[I]*GIN CODE\s*\W)\s+([[:alpha:]]+)\W*([[:alpha:]]*)\W*\s*WEIGHT',1,1,'i',3))),'');  
       if v_part1 = 'AU' then
         v_country_text := 'AU';
         v_part2 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(OR[I]*GIN CODE\s*\W)\s+([[:alpha:]]+)\W*([[:alpha:]]*)\W*\s*WEIGHT',1,1,'i',4))),''); 
          if v_part2 in ('WA','SA','NT','QL','OL','TS','VI','NS') THEN
             v_state := v_part2;
             v_state := 
             CASE 
                WHEN v_state IN ('QL', 'OL') THEN 'QLD'
                WHEN v_state = 'VI' THEN 'VIC'
                WHEN v_state = 'NS' THEN 'NSW'
                WHEN v_state = 'TS' THEN 'TAS'
                ELSE v_state
             END ;
         end if;
      else
       v_country_text := v_part1; 
      end if;
    
    elsif vendor_id = 4002130 then
       v_part1 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(OR[I]*GIN\s*\W)\s+([[:alpha:]]+)',1,1,'i',3))),'');  
       if v_part1 in ( 'QLD', 'NSW', 'VIC','WA','SA','TAS')  then
         v_country_text := 'AU';
         v_state := v_part1;
       else 
         v_country_text := case when v_part1 = 'UK' then 'GB' else v_part1 end; 
       end if;
    elsif vendor_id = 4001826 then
       v_part1 := nvl(ltrim(rtrim(REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(OR[I]*GIN\s*\W)\s+([[:alpha:]]+)\s*\W*\s*HS CODE',1,1,'i',3))),'');  
       if v_part1 in ( 'QLD', 'NSW', 'VIC','WA','SA','TAS')  then
         v_country_text := 'AU';
         v_state := v_part1;
       else 
         v_country_text := case when v_part1 = 'UK' then 'GB' else v_part1 end; 
       end if;
    elsif vendor_id = 4002650 then   
        v_country_text := REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[:-]\s* [[:alpha:]]+)',1,1,'i',2);
        v_country_text := upper(rtrim(ltrim(replace(replace(replace(upper(v_country_text),'COUNTRY OF ORIGIN',''),':',''),'-',''))));
        if v_country_text = 'AUSTRALIA' then
           v_state := 'SA';
        end if; 
    elsif vendor_id IN ( 4001253, 4002198, 4001779, 4002267, 4001267, 4001284
                       , 4001344, 9000449, 4002995, 4003727, 4003046, 4002952
                       , 4002141, 4002090, 4001973, 4002633, 4001578
                       , 4001630, 4002099, 4003410, 4002421, 4003494, 4001997
                       , 4002256, 4003838, 4001913, 4002403, 4006115, 4001838
                       , 4003645, 4002101, 4002511, 4001419, 9002757, 4001621
                       , 4003565, 4002345, 4003551, 4002038, 4002150, 4002208
                       , 4001925) then
         v_country_text := 'AU';
         v_state := 'QLD';
    elsif vendor_id in ( 4001449, 4002169, 4003497, 9002663, 4001635, 4003079, 4003373, 4003085) then
         v_country_text := 'AU';
         v_state := 'WA';
    elsif vendor_id in (4002433, 4001986, 4002488, 4002069, 4003373 ) then 
         v_country_text := 'AU';
         v_state := 'VIC';  
    elsif vendor_id in ( 4001446, 4002550, 4002432, 4002981, 4001408, 4002151, 4001468, 4001394, 4001734, 4004202) then
         v_country_text := 'AU';
         v_state := 'NSW';
    elsif vendor_id IN (9001883, 4002178, 4002802, 9001920) then
         v_country_text := 'AU';
         v_state := 'SA';    
    elsif vendor_id IN (4003511) then
         v_country_text := 'AU';
         v_state := 'TAS';   
    elsif vendor_id in (4002172) then
       v_country_text := REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[:-]\s* [[:alpha:]]+)',1,1,'i',2);
       v_country_text := upper(rtrim(ltrim(replace(replace(replace(upper(v_country_text),'COUNTRY OF ORIGIN',''),':',''),'-',''))));     
       v_state := REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(REGION OF ORIGIN\s*[:-]\s* [[:alpha:]]+)',1,1,'i',2);
       v_state := upper(rtrim(ltrim(replace(replace(replace(upper(v_state),'REGION OF ORIGIN',''),':',''),'-',''))));    
       
       if v_country_text is null then
          v_country_text := 'AU';
       end if;
       
       if v_country_text = 'AU' and v_state is null then
          v_state := 'WA';
       end if;

    elsif vendor_id in (4004008) then  
       v_country_text := REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[:-]\s* [[:alpha:] ]+)\s+WEIGHT',1,1,'i',2);

       v_filler := v_country_text;
       v_country_text := upper(rtrim(ltrim(replace(replace(replace(upper(v_country_text),'COUNTRY OF ORIGIN',''),':',''),'-',''))));   
        if v_country_text = 'AUSTRALIA' then
             v_state :=  'QLD';
        elsif v_country_text is null and v_filler is not null 
            then
              v_country_text := 'AUS';
              v_state :=  'QLD';
        end if;

    else
       v_country_text := REGEXP_SUBSTR( upper(parse_text) , '(\s+|^)(COUNTRY OF ORIGIN\s*[:-]*\s* [[:alpha:]]+)',1,1,'i',2);
       v_filler := v_country_text;
       v_country_text := upper(rtrim(ltrim(replace(replace(replace(upper(v_country_text),'COUNTRY OF ORIGIN',''),':',''),'-',''))));
       if vendor_iD IN (4002377, 4002353, 4001340, 4001771, 4001925) and v_country_text in ( 'AUS', 'AUSTRALIA')  then
          v_state := 'QLD';
       elsif v_country_text is null and v_filler is not null and vendor_iD IN (4002377) then
          v_country_text := 'AUS';
          v_state :=  'QLD';
       end if;
    end if;   
    

    
    open c1(v_country_text);
    fetch c1 into c1rec;
    if c1%FOUND
     then
      close c1;
       p_country_code := c1rec.alpha2 ;
     else
       close c1;
       p_country_code := null;
    end if;
    
    if v_first_part is not null then
       p_state := v_first_part; 
    elsif  v_state is not null then
       p_state := v_state; 
    end if;
    
 end p_getcountry_code;
/
