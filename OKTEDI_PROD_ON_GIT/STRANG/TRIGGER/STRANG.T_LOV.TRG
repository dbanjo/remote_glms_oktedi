CREATE OR REPLACE TRIGGER STRANG.T_LOV 
 after insert or update or delete
 ON STRANG.LOV
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
   pk1 := :NEW.lov_name;
   pk2 := :NEW.code;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.lov_name;
   pk2 := :NEW.code;
 else
   if :old.lov_name = 'CONTROLS' then return; end if;
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.lov_name;
   pk2 := :OLD.code;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'LOV','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 -- Check if LOV NAME is CONTROL
 -- If so do not replicate
 if :NEW.lov_name = 'CONTROLS' then return; end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.lov_name = :NEW.lov_name) and (:OLD.lov_name is not null and :NEW.lov_name is not null)) and not (:OLD.lov_name is null and :NEW.lov_name is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'LOV','LOV_NAME',rid,sysdate,mod_type,:OLD.lov_name,:NEW.lov_name,:OLD.lov_name,:OLD.CODE);
 end if;

 if not((:OLD.CODE = :NEW.CODE) and (:OLD.CODE is not null and :NEW.CODE is not null)) and not (:OLD.CODE is null and :NEW.CODE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'LOV','CODE',rid,sysdate,mod_type,:OLD.CODE,:NEW.CODE,:OLD.lov_name,:OLD.CODE);
 end if;

 if not((:OLD.DESCRIPTION = :NEW.DESCRIPTION) and (:OLD.DESCRIPTION is not null and :NEW.DESCRIPTION is not null))  and not (:OLD.DESCRIPTION is null and :NEW.DESCRIPTION is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'LOV','DESCRIPTION',rid,sysdate,mod_type,:OLD.DESCRIPTION,:NEW.DESCRIPTION,pk1,pk2);
 end if;

 if not((:OLD.COLA = :NEW.COLA) and (:OLD.COLA is not null and :NEW.COLA is not null)) and not (:OLD.COLA is null and :NEW.COLA is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'LOV','COLA',rid,sysdate,mod_type,:OLD.COLA,:NEW.COLA,pk1,pk2);
 end if;

 if not((:OLD.COLB = :NEW.COLB) and (:OLD.COLB is not null and :NEW.COLB is not null)) and not (:OLD.COLB is null and :NEW.COLB is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'LOV','COLB',rid,sysdate,mod_type,:OLD.COLB,:NEW.COLB,pk1,pk2);
 end if;

 if not((:OLD.COLC = :NEW.COLC) and (:OLD.COLC is not null and :NEW.COLC is not null)) and not (:OLD.COLC is null and :NEW.COLC is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'LOV','COLC',rid,sysdate,mod_type,:OLD.COLC,:NEW.COLC,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'LOV','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;


end t_lov;
/
