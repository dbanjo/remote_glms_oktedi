CREATE OR REPLACE TRIGGER WEBSYS.T_HEALTH_GROUP_1 
 BEFORE INSERT OR UPDATE
 ON WEBSYS.HEALTH_GROUP
 FOR EACH ROW
DECLARE
 cursor c1(vl varchar2) is select 'x' from lov where lov_type = 'CATEGORY' and lov_value = vl;
 tmp 	char(1);
BEGIN

 if (inserting or updating)
  then
   tmp := NULL;
   open c1( :NEW.CATEGORY );
   fetch c1 into tmp;
   close c1;
   if tmp is null
    then
     raise_application_error(-20203,'Category: ' || :NEW.CATEGORY || ' does not exist.' );
   end if;
 end if;
END T_HEALTH_GROUP_1;
/
