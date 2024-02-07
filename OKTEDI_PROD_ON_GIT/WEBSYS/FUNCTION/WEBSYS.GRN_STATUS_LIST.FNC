CREATE OR REPLACE function WEBSYS.grn_status_list( parm in varchar2, cstat in varchar2 default null, ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE )
 as

  cursor c1(cstat varchar2) is
  select substr(code,2,1) code
  from lov
  where lov_name='GRN_STATUS' and
  substr(code,1,1) = cstat and
  colb is null
  order by 1;


  c1rec	c1%ROWTYPE;
 begin

  if isedit
   then
    htp.formselectopen( parm );
    if not ismand then htp.formselectoption( NULL ); end if;
    for c1rec in c1( cstat ) loop
     if (cstat is not null) and (cstat = c1rec.code)
      then
       htp.formselectoption( c1rec.code, 'SELECTED', cattributes=>'VALUE="' || c1rec.code || '"' );
      else
       htp.formselectoption( c1rec.code, cattributes=>'VALUE="' || c1rec.code || '"' );
     end if;
    end loop;
    htp.formselectclose;
   else
    htp.bold( cstat );
  end if;
 exception
  when others then htp.p( sqlerrm );
 end grn_status_list;

/
