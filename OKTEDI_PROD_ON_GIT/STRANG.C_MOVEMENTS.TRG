CREATE OR REPLACE TRIGGER STRANG.C_MOVEMENTS 
 after update
 on strang.movements
 for each row
declare

 mod_type	varchar2(20);
 rid		rowid;
 pk1		varchar2(4000);
 pk2		varchar2(4000);

begin

 if nvl(global_site.disable_trigger,FALSE) then return; end if;
 if updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.movement_no;
   pk2 := :NEW.seal;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.CURRENT_LOCATION = :NEW.CURRENT_LOCATION) and (:OLD.CURRENT_LOCATION is not null and :NEW.CURRENT_LOCATION is not null)) and not (:OLD.CURRENT_LOCATION is null and :NEW.CURRENT_LOCATION is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','CURRENT_LOCATION',rid,sysdate,mod_type,:OLD.CURRENT_LOCATION,:NEW.CURRENT_LOCATION,pk1,pk2);
 end if;

 if not((:OLD.URGENCY = :NEW.URGENCY) and (:OLD.URGENCY is not null and :NEW.URGENCY is not null)) and not (:OLD.URGENCY is null and :NEW.URGENCY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','URGENCY',rid,sysdate,mod_type,:OLD.URGENCY,:NEW.URGENCY,pk1,pk2);
 end if;

end t_movements;
/
