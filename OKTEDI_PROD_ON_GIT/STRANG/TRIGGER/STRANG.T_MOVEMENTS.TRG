CREATE OR REPLACE TRIGGER STRANG.T_MOVEMENTS 
 after insert or update or delete
 ON STRANG.MOVEMENTS
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
   pk1 := :NEW.movement_no;
   pk2 := :NEW.seal;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.movement_no;
   pk2 := :NEW.seal;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.movement_no;
   pk2 := :OLD.seal;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
  return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.INVOICENO = :NEW.INVOICENO) and (:OLD.INVOICENO is not null and :NEW.INVOICENO is not null)) and not (:OLD.INVOICENO is null and :NEW.INVOICENO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','INVOICENO',rid,sysdate,mod_type,:OLD.INVOICENO,:NEW.INVOICENO,pk1,pk2);
 end if;

 if not((:OLD.MOVEMENT_NO = :NEW.MOVEMENT_NO) and (:OLD.MOVEMENT_NO is not null and :NEW.MOVEMENT_NO is not null)) and not (:OLD.MOVEMENT_NO is null and :NEW.MOVEMENT_NO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','MOVEMENT_NO',rid,sysdate,mod_type,:OLD.MOVEMENT_NO,:NEW.MOVEMENT_NO,:OLD.MOVEMENT_NO,:OLD.SEAL);
 end if;

 if not((:OLD.SEAL = :NEW.SEAL) and (:OLD.SEAL is not null and :NEW.SEAL is not null)) and not (:OLD.SEAL is null and :NEW.SEAL is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','SEAL',rid,sysdate,mod_type,:OLD.SEAL,:NEW.SEAL,:OLD.MOVEMENT_NO,:OLD.SEAL);
 end if;

 if not((:OLD.BOL = :NEW.BOL) and (:OLD.BOL is not null and :NEW.BOL is not null)) and not (:OLD.BOL is null and :NEW.BOL is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','BOL',rid,sysdate,mod_type,:OLD.BOL,:NEW.BOL,pk1,pk2);
 end if;

 if not((:OLD.MOVEMENT_TYPE = :NEW.MOVEMENT_TYPE) and (:OLD.MOVEMENT_TYPE is not null and :NEW.MOVEMENT_TYPE is not null)) and not (:OLD.MOVEMENT_TYPE is null and :NEW.MOVEMENT_TYPE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','MOVEMENT_TYPE',rid,sysdate,mod_type,:OLD.MOVEMENT_TYPE,:NEW.MOVEMENT_TYPE,pk1,pk2);
 end if;

 if not((:OLD.CONTAINER_TYPE = :NEW.CONTAINER_TYPE) and (:OLD.CONTAINER_TYPE is not null and :NEW.CONTAINER_TYPE is not null)) and not (:OLD.CONTAINER_TYPE is null and :NEW.CONTAINER_TYPE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','CONTAINER_TYPE',rid,sysdate,mod_type,:OLD.CONTAINER_TYPE,:NEW.CONTAINER_TYPE,pk1,pk2);
 end if;

 if not((:OLD.MOVE_DESCRIPTION = :NEW.MOVE_DESCRIPTION) and (:OLD.MOVE_DESCRIPTION is not null and :NEW.MOVE_DESCRIPTION is not null)) and not (:OLD.MOVE_DESCRIPTION is null and :NEW.MOVE_DESCRIPTION is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','MOVE_DESCRIPTION',rid,sysdate,mod_type,:OLD.MOVE_DESCRIPTION,:NEW.MOVE_DESCRIPTION,pk1,pk2);
 end if;

 if not((:OLD.COMPLETE = :NEW.COMPLETE) and (:OLD.COMPLETE is not null and :NEW.COMPLETE is not null)) and not (:OLD.COMPLETE is null and :NEW.COMPLETE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','COMPLETE',rid,sysdate,mod_type,:OLD.COMPLETE,:NEW.COMPLETE,pk1,pk2);
 end if;

 if not((:OLD.DEPARTURE = :NEW.DEPARTURE) and (:OLD.DEPARTURE is not null and :NEW.DEPARTURE is not null)) and not (:OLD.DEPARTURE is null and :NEW.DEPARTURE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','DEPARTURE',rid,sysdate,mod_type,:OLD.DEPARTURE,:NEW.DEPARTURE,pk1,pk2);
 end if;

 if not((:OLD.ARRIVAL = :NEW.ARRIVAL) and (:OLD.ARRIVAL is not null and :NEW.ARRIVAL is not null)) and not (:OLD.ARRIVAL is null and :NEW.ARRIVAL is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','ARRIVAL',rid,sysdate,mod_type,:OLD.ARRIVAL,:NEW.ARRIVAL,pk1,pk2);
 end if;

 if not((:OLD.DISPATCH_DATE = :NEW.DISPATCH_DATE) and (:OLD.DISPATCH_DATE is not null and :NEW.DISPATCH_DATE is not null)) and not (:OLD.DISPATCH_DATE is null and :NEW.DISPATCH_DATE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','DISPATCH_DATE',rid,sysdate,mod_type,:OLD.DISPATCH_DATE,:NEW.DISPATCH_DATE,'D',pk1,pk2);
 end if;

 if not((:OLD.SUMVOLUME = :NEW.SUMVOLUME) and (:OLD.SUMVOLUME is not null and :NEW.SUMVOLUME is not null)) and not (:OLD.SUMVOLUME is null and :NEW.SUMVOLUME is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','SUMVOLUME',rid,sysdate,mod_type,:OLD.SUMVOLUME,:NEW.SUMVOLUME,pk1,pk2);
 end if;

 if not((:OLD.SUMWEIGHT = :NEW.SUMWEIGHT) and (:OLD.SUMWEIGHT is not null and :NEW.SUMWEIGHT is not null)) and not (:OLD.SUMWEIGHT is null and :NEW.SUMWEIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','SUMWEIGHT',rid,sysdate,mod_type,:OLD.SUMWEIGHT,:NEW.SUMWEIGHT,pk1,pk2);
 end if;

 if not((:OLD.REVTON = :NEW.REVTON) and (:OLD.REVTON is not null and :NEW.REVTON is not null)) and not (:OLD.REVTON is null and :NEW.REVTON is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','REVTON',rid,sysdate,mod_type,:OLD.REVTON,:NEW.REVTON,pk1,pk2);
 end if;

 if not((:OLD.TARE = :NEW.TARE) and (:OLD.TARE is not null and :NEW.TARE is not null)) and not (:OLD.TARE is null and :NEW.TARE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','TARE',rid,sysdate,mod_type,:OLD.TARE,:NEW.TARE,pk1,pk2);
 end if;

 if not((:OLD.CHARGEWEIGHT    = :NEW.CHARGEWEIGHT   ) and (:OLD.CHARGEWEIGHT    is not null and :NEW.CHARGEWEIGHT    is not null)) and not (:OLD.CHARGEWEIGHT    is null and :NEW.CHARGEWEIGHT    is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','CHARGEWEIGHT   ',rid,sysdate,mod_type,:OLD.CHARGEWEIGHT   ,:NEW.CHARGEWEIGHT   ,pk1,pk2);
 end if;

 if not((:OLD.SHIP_ID = :NEW.SHIP_ID) and (:OLD.SHIP_ID is not null and :NEW.SHIP_ID is not null)) and not (:OLD.SHIP_ID is null and :NEW.SHIP_ID is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','SHIP_ID',rid,sysdate,mod_type,:OLD.SHIP_ID,:NEW.SHIP_ID,pk1,pk2);
 end if;

 if not((:OLD.MANIFEST_CREATED = :NEW.MANIFEST_CREATED) and (:OLD.MANIFEST_CREATED is not null and :NEW.MANIFEST_CREATED is not null)) and not (:OLD.MANIFEST_CREATED is null and :NEW.MANIFEST_CREATED is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','MANIFEST_CREATED',rid,sysdate,mod_type,:OLD.MANIFEST_CREATED,:NEW.MANIFEST_CREATED,pk1,pk2);
 end if;

 if not((:OLD.CARRIER = :NEW.CARRIER) and (:OLD.CARRIER is not null and :NEW.CARRIER is not null)) and not (:OLD.CARRIER is null and :NEW.CARRIER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','CARRIER',rid,sysdate,mod_type,:OLD.CARRIER,:NEW.CARRIER,pk1,pk2);
 end if;

 if not((:OLD.FLIGHT = :NEW.FLIGHT) and (:OLD.FLIGHT is not null and :NEW.FLIGHT is not null)) and not (:OLD.FLIGHT is null and :NEW.FLIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','FLIGHT',rid,sysdate,mod_type,:OLD.FLIGHT,:NEW.FLIGHT,pk1,pk2);
 end if;

 if not((:OLD.CHARGECODE = :NEW.CHARGECODE) and (:OLD.CHARGECODE is not null and :NEW.CHARGECODE is not null)) and not (:OLD.CHARGECODE is null and :NEW.CHARGECODE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','CHARGECODE',rid,sysdate,mod_type,:OLD.CHARGECODE,:NEW.CHARGECODE,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'MOVEMENTS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_movements;
/
