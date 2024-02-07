CREATE OR REPLACE TRIGGER STRANG.T_CHARGES 
 after insert or update or delete
 ON STRANG.CHARGES
 for each row
DISABLE
declare

 mod_type	varchar2(20);
 rid		rowid;
 pk1		varchar2(4000);
 pk2		varchar2(4000);

begin

 if nvl(global_site.disable_trigger,FALSE) then return; end if;

 if inserting
  then
   mod_type := 'I';
   rid := :NEW.ROWID;
   pk1 := :NEW.chargecode;
   pk2 := NULL;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.chargecode;
   pk2 := NULL;
 else
  if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.chargecode;
   pk2 := NULL;
   -- If Deleting then only store the one value
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'CHARGES','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.chargecode = :NEW.chargecode) and (:OLD.chargecode is not null and :NEW.chargecode is not null)) and not (:OLD.chargecode is null and :NEW.chargecode is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'CHARGES','CHARGECODE',rid,sysdate,mod_type,:OLD.chargecode,:NEW.chargecode,:OLD.chargecode,pk2);
 end if;

 if not((:OLD.chargedesc = :NEW.chargedesc) and (:OLD.chargedesc is not null and :NEW.chargedesc is not null)) and not (:OLD.chargedesc is null and :NEW.chargedesc is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'CHARGES','CHARGEDESC',rid,sysdate,mod_type,:OLD.chargedesc,:NEW.chargedesc,pk1,pk2);
 end if;

 if not((:OLD.rate = :NEW.rate) and (:OLD.rate is not null and :NEW.rate is not null)) and not (:OLD.rate is null and :NEW.rate is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'CHARGES','RATE',rid,sysdate,mod_type,:OLD.rate,:NEW.rate,pk1,pk2);
 end if;

 if not((:OLD.costcode = :NEW.costcode) and (:OLD.costcode is not null and :NEW.costcode is not null)) and not (:OLD.costcode is null and :NEW.costcode is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'CHARGES','COSTCODE',rid,sysdate,mod_type,:OLD.costcode,:NEW.costcode,pk1,pk2);
 end if;

 if not((:OLD.unit_unitused = :NEW.unit_unitused) and (:OLD.unit_unitused is not null and :NEW.unit_unitused is not null)) and not (:OLD.unit_unitused is null and :NEW.unit_unitused is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'CHARGES','UNIT_UNITUSED',rid,sysdate,mod_type,:OLD.unit_unitused,:NEW.unit_unitused,pk1,pk2);
 end if;

 if not((:OLD.gstc_gstcode = :NEW.gstc_gstcode) and (:OLD.gstc_gstcode is not null and :NEW.gstc_gstcode is not null)) and not (:OLD.gstc_gstcode is null and :NEW.gstc_gstcode is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'CHARGES','GSTC_GSTCODE',rid,sysdate,mod_type,:OLD.gstc_gstcode,:NEW.gstc_gstcode,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'CHARGES','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_charges;
/
