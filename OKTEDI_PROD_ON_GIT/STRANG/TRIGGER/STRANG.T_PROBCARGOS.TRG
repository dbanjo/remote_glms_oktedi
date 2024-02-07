CREATE OR REPLACE TRIGGER STRANG.T_PROBCARGOS 
 after insert or update or delete
 ON STRANG.PROBCARGOS
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
   pk1 := :NEW.RVAL_DELIVERYNO;
   pk2 := :NEW.recno;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.RVAL_DELIVERYNO;
   pk2 := :NEW.recno;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.RVAL_DELIVERYNO;
   pk2 := :OLD.recno;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;

 if not((:OLD.RVAL_DELIVERYNO = :NEW.RVAL_DELIVERYNO) and (:OLD.RVAL_DELIVERYNO is not null and :NEW.RVAL_DELIVERYNO is not null)) and not (:OLD.RVAL_DELIVERYNO is null and :NEW.RVAL_DELIVERYNO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','RVAL_DELIVERYNO',rid,sysdate,mod_type,:OLD.RVAL_DELIVERYNO,:NEW.RVAL_DELIVERYNO,:OLD.RVAL_DELIVERYNO,:OLD.RECNO);
 end if;

 if not((:OLD.RECNO = :NEW.RECNO) and (:OLD.RECNO is not null and :NEW.RECNO is not null)) and not (:OLD.RECNO is null and :NEW.RECNO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','RECNO',rid,sysdate,mod_type,:OLD.RECNO,:NEW.RECNO,:OLD.RVAL_DELIVERYNO,:OLD.RECNO);
 end if;

 if not((:OLD.PTYPE_PROBTYPE = :NEW.PTYPE_PROBTYPE) and (:OLD.PTYPE_PROBTYPE is not null and :NEW.PTYPE_PROBTYPE is not null)) and not (:OLD.PTYPE_PROBTYPE is null and :NEW.PTYPE_PROBTYPE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','PTYPE_PROBTYPE',rid,sysdate,mod_type,:OLD.PTYPE_PROBTYPE,:NEW.PTYPE_PROBTYPE,pk1,pk2);
 end if;

 if not((:OLD.DATEOCCUR = :NEW.DATEOCCUR) and (:OLD.DATEOCCUR is not null and :NEW.DATEOCCUR is not null)) and not (:OLD.DATEOCCUR is null and :NEW.DATEOCCUR is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','DATEOCCUR',rid,sysdate,mod_type,:OLD.DATEOCCUR,:NEW.DATEOCCUR,'D',pk1,pk2);
 end if;

 if not((:OLD.REASON = :NEW.REASON) and (:OLD.REASON is not null and :NEW.REASON is not null)) and not (:OLD.REASON is null and :NEW.REASON is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','REASON',rid,sysdate,mod_type,:OLD.REASON,:NEW.REASON,pk1,pk2);
 end if;

 if not((:OLD.DATERESOLVE = :NEW.DATERESOLVE) and (:OLD.DATERESOLVE is not null and :NEW.DATERESOLVE is not null)) and not (:OLD.DATERESOLVE is null and :NEW.DATERESOLVE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','DATERESOLVE',rid,sysdate,mod_type,:OLD.DATERESOLVE,:NEW.DATERESOLVE,'D',pk1,pk2);
 end if;

 if not((:OLD.RESOLUTION = :NEW.RESOLUTION) and (:OLD.RESOLUTION is not null and :NEW.RESOLUTION is not null)) and not (:OLD.RESOLUTION is null and :NEW.RESOLUTION is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','RESOLUTION',rid,sysdate,mod_type,:OLD.RESOLUTION,:NEW.RESOLUTION,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.get_name,'PRIMARY'),'PROBCARGOS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_probcargos;
/
