CREATE OR REPLACE TRIGGER WEBSYS.T_HEALTH_PARAMETERS_1 
 BEFORE INSERT OR UPDATE
 ON WEBSYS.HEALTH_PARAMETERS
 FOR EACH ROW
DECLARE
 cursor c1( grp varchar2 ) is select 'x' from health_group where group_name = grp;
 cursor c2( grp varchar2, grpid varchar2 ) is select 'x' from health_group where group_name = grp and code = grpid;
 cursor c3( sct varchar2 ) is select 'x' from lov where lov_type = 'SECTION' and lov_value = sct;
 cursor c4( rt varchar2 ) is select 'x' from lov where lov_type = 'RESPONSE TYPE' and lov_value = rt;
 cursor c5( dt varchar2 ) is select 'x' from lov where lov_type = 'DATABASE TYPE' and lov_value = dt;
 tmp char(1);
 dmy integer;

BEGIN
  tmp := NULL;
  open c1( :NEW.GROUP_TOPIC );
  fetch c1 into tmp;
  close c1;
  if tmp is null
   then raise_application_error( -20101,'Group: ' || :NEW.GROUP_TOPIC || ' does not exist' );
  end if;

  tmp := NULL;
  open c2( :NEW.GROUP_TOPIC, substr(:NEW.PARAMETER_CODE,1,2));
  fetch c2 into tmp;
  close c2;
  if tmp is null
   then
    raise_application_error( -20102,'Parameter Code: ' || :NEW.GROUP_TOPIC || '. First two characters are not a valid code. See table LOV.' );
  end if;

  begin
   dmy := to_number(substr(:NEW.PARAMETER_CODE,3,2));
  exception
   when others then
    raise_application_error( -20103,'Parameter Code: ' || :NEW.PARAMETER_CODE || '. The last two values are not a valid number.' );
  end;

  tmp := NULL;
  open c3( :NEW.SECTION );
  fetch c3 into tmp;
  close c3;
  if tmp is null
   then
    raise_application_error( -21004,'Section: ' || :NEW.SECTION || ' does not exist' );
  end if;
  tmp := NULL;
  open c4( :NEW.RESPONSE_TYPE );
  fetch c4 into tmp;
  close c4;
  if tmp is null
   then
    raise_application_error( -20105,'Response Type: ' || :NEW.RESPONSE_TYPE || ' does not exist' );
  end if;

  tmp := NULL;
  open c5( :NEW.DATABASE_TYPE );
  fetch c5 into tmp;
  close c5;
  if tmp is null
   then
    raise_application_error( -20106,'Database Type: ' || :NEW.DATABASE_TYPE || ' does not exist' );
  end if;

  if updating
   then
    :new.version_number := :old.version_number + 1;
    :new.date_updated := sysdate;
  end if;
END T_HEALTH_PARAMETERS_1;
/
