CREATE OR REPLACE TRIGGER STRANG.T_HAWBS 
 after insert or update or delete
 ON STRANG.HAWBS
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
   pk1 := :NEW.MAWB;
   pk2 := :NEW.HAWB;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.MAWB;
   pk2 := :NEW.HAWB;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.MAWB;
   pk2 := :OLD.HAWB;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'HAWBS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;

 if not((:OLD.MAWB = :NEW.MAWB) and (:OLD.MAWB is not null and :NEW.MAWB is not null)) and not (:OLD.MAWB is null and :NEW.MAWB is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'HAWBS','MAWB',rid,sysdate,mod_type,:OLD.MAWB,:NEW.MAWB,:OLD.MAWB,:OLD.HAWB);
 end if;

 if not((:OLD.HAWB = :NEW.HAWB) and (:OLD.HAWB is not null and :NEW.HAWB is not null)) and not (:OLD.HAWB is null and :NEW.HAWB is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'HAWBS','HAWB',rid,sysdate,mod_type,:OLD.HAWB,:NEW.HAWB,:OLD.MAWB,:OLD.HAWB);
 end if;

 if not((:OLD.VALUE = :NEW.VALUE) and (:OLD.VALUE is not null and :NEW.VALUE is not null)) and not (:OLD.VALUE is null and :NEW.VALUE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'HAWBS','VALUE',rid,sysdate,mod_type,:OLD.VALUE,:NEW.VALUE,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'HAWBS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_hawbs;
/
