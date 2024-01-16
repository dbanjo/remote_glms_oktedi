CREATE OR REPLACE TRIGGER STRANG.T_LOV_1 
 before insert or update
 ON STRANG.LOV
 for each row
declare
 cursor c1(lname varchar2, lcode varchar2, lcola varchar2) is select 'x' exst from lov where lov_name = lname and code = upper(lcode) and cola = upper(lcola);
 cursor c2(lname varchar2, lcode varchar2) is select 'x' exst from lov where lov_name = lname and code = upper(lcode);
 cursor c3(lname varchar2, lcode varchar2, f_date varchar2, t_date varchar2) is
  select *
  from   lov
  where  lov_name = lname
         and code = upper(lcode)
         and ( ( to_date(f_date) >= to_date(cola) and to_date(f_date) <= to_date(colb))
              or
               (to_date(t_date) >= to_date(cola) and to_date(t_date) <= to_date(colb))
             )
  ;

 c1rec        c1%ROWTYPE;
 c2rec        c2%ROWTYPE;
 c3rec        c3%ROWTYPE;
 v_date1      varchar2(100);
 v_date2      varchar2(100);
begin
 if :NEW.lov_name = 'CONTROLS' and :NEW.cola is null
  then
    raise_application_error(-20101,'State must have a value');
 end if;
 if :NEW.lov_name = 'UNRATTAB' and :NEW.cola is null
  then
    raise_application_error(-20101,'Start date must have a value');
 end if;
 if :NEW.lov_name = 'UNRATTAB' and :NEW.colb is null
  then
    raise_application_error(-20101,'End date must have a value');
 end if;
 if inserting
  then
   if :NEW.lov_name = 'CONTROLS'
    then
     open c1('CONTROLS',:NEW.code,:NEW.cola);
     fetch c1 into c1rec;
     if c1%FOUND
      then
       close c1;
       raise_application_error(-20102,'Control Value Already Exists');
     end if;
     close c1;
   elsif :NEW.lov_name = 'UNRATTAB'
    then
     -- Check date syntax
     v_date1 := websys.glbx.guess_date(:NEW.cola);
     if v_date1 is null
      then
       raise_application_error(-20102,'"FROM" date is invalid: ' || :NEW.cola);
     end if;
     v_date2 := websys.glbx.guess_date(:NEW.colb);
     if v_date1 is null
      then
       raise_application_error(-20102,'"TO" date is invalid: ' || :NEW.colb);
     end if;
     -- Check if dates overlap for same code
     open c3('UNRATTAB',:NEW.code, v_date1, v_date2);
     fetch c3 into c3rec;
     if c3%FOUND
      then
       close c3;
       raise_application_error(-20102,'Dates conflict with [' || c3rec.code || ']: ' || c3rec.cola || ' - ' || c3rec.colb);
     end if;
     close c3;
    else
     open c2(:NEW.lov_name,:NEW.code);
     fetch c2 into c2rec;
     if c2%FOUND
      then
       close c2;
       raise_application_error(-20103,'Lov Already Exists');
     end if;
     close c2;
   end if;
/*
 elsif updating
  then
   if nvl(:NEW.code,'!') <> nvl(:OLD.code,'\')
    then
     if :NEW.lov_name = 'CONTROLS'
      then
       open c1('CONTROLS',:NEW.code,:NEW.cola);
       fetch c1 into c1rec;
       if c1%FOUND
        then
         close c1;
         raise_application_error(-20104,'Control Value Already Exists');
       end if;
       close c1;
      else
       open c2(:NEW.lov_name,:NEW.code);
       fetch c2 into c2rec;
       if c2%FOUND
        then
         close c2;
         raise_application_error(-20105,'Lov Value Already Exists');
       end if;
       close c2;
     end if;
   end if;
 */
 end if;

end;
/
