CREATE OR REPLACE function STRANG.f_receival_link( deliveryno number, surl varchar2 )
   return varchar
  as

    cursor c1(vdeliveryno number) is
     select rowid as row_id
     from strang.receivals r
     where deliveryno = deliveryno;
     
   cursor c2 is
     select screen_id
     from websys.oltp_overview
     where upper(screen_name) = 'RECEIVAL';

   c1rec	C1%ROWTYPE;
   c2rec	C2%ROWTYPE;

   retvar varchar2(32767);

   begin

   retvar := null;

      open c1(deliveryno);
      fetch c1 into c1rec;
      if c1%NOTFOUND
       then
        close c1;
        return(to_char(deliveryno));
      else
        open c2;
        fetch c2 into c2rec;
        close c2;
        retvar := htf.anchor('STRANGP.receive?surl=' || surl || '&rid=' || replace(c1rec.row_id, '+', '~') ||'&scid='||c2rec.screen_id||'&call_name=OLTP.RUN_REPORT&parm=RECEIVALS&access_id=x&msg=&call_name=' ||'OLTP', htf.bold(to_char(deliveryno)));
        
      end if;
      close c1;
      return( retvar );

 end f_receival_link;
/
