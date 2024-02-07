CREATE OR REPLACE TRIGGER STRANG.T_DUTY 
 after insert or update or delete
 ON STRANG.DUTY
 for each row
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
   pk1 := :NEW.entry_no;
   pk2 := NULL;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.entry_no;
   pk2 := NULL;
 else
  if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.entry_no;
   pk2 := NULL;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.ENTRY_NO = :NEW.ENTRY_NO) and (:OLD.ENTRY_NO is not null and :NEW.ENTRY_NO is not null)) and not (:OLD.ENTRY_NO is null and :NEW.ENTRY_NO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','ENTRY_NO',rid,sysdate,mod_type,:OLD.ENTRY_NO,:NEW.ENTRY_NO,:OLD.ENTRY_NO,pk2);
 end if;

 if not((:OLD.TOTAL_INVOICE = :NEW.TOTAL_INVOICE) and (:OLD.TOTAL_INVOICE is not null and :NEW.TOTAL_INVOICE is not null)) and not (:OLD.TOTAL_INVOICE is null and :NEW.TOTAL_INVOICE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','TOTAL_INVOICE',rid,sysdate,mod_type,:OLD.TOTAL_INVOICE,:NEW.TOTAL_INVOICE,pk1,pk2);
 end if;

 if not((:OLD.DUTY = :NEW.DUTY) and (:OLD.DUTY is not null and :NEW.DUTY is not null)) and not (:OLD.DUTY is null and :NEW.DUTY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','DUTY',rid,sysdate,mod_type,:OLD.DUTY,:NEW.DUTY,pk1,pk2);
 end if;

 if not((:OLD.RATIO_FACTOR = :NEW.RATIO_FACTOR) and (:OLD.RATIO_FACTOR is not null and :NEW.RATIO_FACTOR is not null)) and not (:OLD.RATIO_FACTOR is null and :NEW.RATIO_FACTOR is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','RATIO_FACTOR',rid,sysdate,mod_type,:OLD.RATIO_FACTOR,:NEW.RATIO_FACTOR,pk1,pk2);
 end if;

 if not((:OLD.CORRECT_FREIGHT = :NEW.CORRECT_FREIGHT) and (:OLD.CORRECT_FREIGHT is not null and :NEW.CORRECT_FREIGHT is not null)) and not (:OLD.CORRECT_FREIGHT is null and :NEW.CORRECT_FREIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','CORRECT_FREIGHT',rid,sysdate,mod_type,:OLD.CORRECT_FREIGHT,:NEW.CORRECT_FREIGHT,pk1,pk2);
 end if;

 if not((:OLD.OTHER_COSTS = :NEW.OTHER_COSTS) and (:OLD.OTHER_COSTS is not null and :NEW.OTHER_COSTS is not null)) and not (:OLD.OTHER_COSTS is null and :NEW.OTHER_COSTS is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','OTHER_COSTS',rid,sysdate,mod_type,:OLD.OTHER_COSTS,:NEW.OTHER_COSTS,pk1,pk2);
 end if;

 if not((:OLD.INSURANCE = :NEW.INSURANCE) and (:OLD.INSURANCE is not null and :NEW.INSURANCE is not null)) and not (:OLD.INSURANCE is null and :NEW.INSURANCE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','INSURANCE',rid,sysdate,mod_type,:OLD.INSURANCE,:NEW.INSURANCE,pk1,pk2);
 end if;

 if not((:OLD.PREVIOUS_ENTRY_NO = :NEW.PREVIOUS_ENTRY_NO) and (:OLD.PREVIOUS_ENTRY_NO is not null and :NEW.PREVIOUS_ENTRY_NO is not null)) and not (:OLD.PREVIOUS_ENTRY_NO is null and :NEW.PREVIOUS_ENTRY_NO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','PREVIOUS_ENTRY_NO',rid,sysdate,mod_type,:OLD.PREVIOUS_ENTRY_NO,:NEW.PREVIOUS_ENTRY_NO,pk1,pk2);
 end if;

 if not((:OLD.WARRANT_NO = :NEW.WARRANT_NO) and (:OLD.WARRANT_NO is not null and :NEW.WARRANT_NO is not null)) and not (:OLD.WARRANT_NO is null and :NEW.WARRANT_NO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','WARRANT_NO',rid,sysdate,mod_type,:OLD.WARRANT_NO,:NEW.WARRANT_NO,pk1,pk2);
 end if;

 if not((:OLD.CHEQUE = :NEW.CHEQUE) and (:OLD.CHEQUE is not null and :NEW.CHEQUE is not null)) and not (:OLD.CHEQUE is null and :NEW.CHEQUE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','CHEQUE',rid,sysdate,mod_type,:OLD.CHEQUE,:NEW.CHEQUE,pk1,pk2);
 end if;

 if not((:OLD.EXCISE = :NEW.EXCISE) and (:OLD.EXCISE is not null and :NEW.EXCISE is not null)) and not (:OLD.EXCISE is null and :NEW.EXCISE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','EXCISE',rid,sysdate,mod_type,:OLD.EXCISE,:NEW.EXCISE,pk1,pk2);
 end if;

 if not((:OLD.VAT = :NEW.VAT) and (:OLD.VAT is not null and :NEW.VAT is not null)) and not (:OLD.VAT is null and :NEW.VAT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','VAT',rid,sysdate,mod_type,:OLD.VAT,:NEW.VAT,pk1,pk2);
 end if;

 if not((:OLD.PVARIANCE = :NEW.PVARIANCE) and (:OLD.PVARIANCE is not null and :NEW.PVARIANCE is not null)) and not (:OLD.PVARIANCE is null and :NEW.PVARIANCE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','PVARIANCE',rid,sysdate,mod_type,:OLD.PVARIANCE,:NEW.PVARIANCE,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DUTY','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_duty;
/
