CREATE OR REPLACE TRIGGER STRANG.T_INVDELS 
 after insert or update or delete
 ON STRANG.INVDELS
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
   pk1 := :NEW.invoiceno;
   pk2 := NULL;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.invoiceno;
   pk2 := NULL;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.invoiceno;
   pk2 := NULL;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVDELS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.INVOICENO = :NEW.INVOICENO) and (:OLD.INVOICENO is not null and :NEW.INVOICENO is not null)) and not (:OLD.INVOICENO is null and :NEW.INVOICENO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVDELS','INVOICENO',rid,sysdate,mod_type,:OLD.INVOICENO,:NEW.INVOICENO,:OLD.INVOICENO,pk2);
 end if;

 if not((:OLD.INVDATE = :NEW.INVDATE) and (:OLD.INVDATE is not null and :NEW.INVDATE is not null)) and not (:OLD.INVDATE is null and :NEW.INVDATE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVDELS','INVDATE',rid,sysdate,mod_type,:OLD.INVDATE,:NEW.INVDATE,'D',pk1,pk2);
 end if;

 if not((:OLD.DELDATE = :NEW.DELDATE) and (:OLD.DELDATE is not null and :NEW.DELDATE is not null)) and not (:OLD.DELDATE is null and :NEW.DELDATE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVDELS','DELDATE',rid,sysdate,mod_type,:OLD.DELDATE,:NEW.DELDATE,'D',pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVDELS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_invdels;
/
