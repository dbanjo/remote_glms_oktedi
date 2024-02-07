CREATE OR REPLACE TRIGGER WEBSYS.T_LOV_1 
 before insert or update
 ON WEBSYS.LOV
 for each row
declare
 cursor c1(lname varchar2, lcode varchar2, lcola varchar2) is select 'x' exst from lov where lov_name = lname and code = upper(lcode) and cola = upper(lcola);
 cursor c2(lname varchar2, lcode varchar2) is select 'x' exst from lov where lov_name = lname and code = upper(lcode);
 c1rec c1%ROWTYPE;
 c2rec c2%ROWTYPE;
begin
 if :NEW.lov_name = 'CONTROLS' and :NEW.cola is null
  then
    raise_application_error(-20101,'State must have a value');
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
