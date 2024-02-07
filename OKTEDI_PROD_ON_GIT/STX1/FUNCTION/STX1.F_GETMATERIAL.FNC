CREATE OR REPLACE function STX1.f_getMaterial( vCode in varchar2, isShortDesc in boolean )
return varchar2
as

 cursor c1 is
 select description|| '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||' Tariff: '|| nvl(cola,'TBC')||'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'||' MaterialGroup: '|| colc idesc
 from strang.lov
 where lov_name = 'INVENT' and
 code = vCode;

 cursor c2 is
 select description idesc
 from strang.lov
 where lov_name = 'INVENT' and
 code = vCode;

 c1rec    c1%ROWTYPE;
 c2rec    c2%ROWTYPE;
 retvar   varchar2(1000);

 begin

 if isShortdesc then
  open c2;
  fetch c2 into c2rec;
  if c2%NOTFOUND then
     retvar := ' ';
  else
     retvar := c2rec.idesc;
  end if;
  close c2;
 else
  open c1;
  fetch c1 into c1rec;
  if c1%NOTFOUND then
     retvar := ' ';
  else
     retvar := c1rec.idesc;
  end if;
  close c1;
 end if;
 return ( substr(retvar,1,200) );
 end f_getMaterial;
/
