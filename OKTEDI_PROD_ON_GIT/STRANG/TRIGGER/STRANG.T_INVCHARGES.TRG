CREATE OR REPLACE TRIGGER STRANG.T_INVCHARGES 
 after insert or update or delete
 ON STRANG.INVCHARGES
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
   pk1 := :NEW.inv_invoiceno;
   pk2 := :NEW.cge_chargecode;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.inv_invoiceno;
   pk2 := :NEW.cge_chargecode;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.inv_invoiceno;
   pk2 := :OLD.cge_chargecode;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.INV_INVOICENO = :NEW.INV_INVOICENO) and (:OLD.INV_INVOICENO is not null and :NEW.INV_INVOICENO is not null)) and not (:OLD.INV_INVOICENO is null and :NEW.INV_INVOICENO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','INV_INVOICENO',rid,sysdate,mod_type,:OLD.INV_INVOICENO,:NEW.INV_INVOICENO,:OLD.INV_INVOICENO,:OLD.CGE_CHARGECODE);
 end if;

 if not((:OLD.CGE_CHARGECODE = :NEW.CGE_CHARGECODE) and (:OLD.CGE_CHARGECODE is not null and :NEW.CGE_CHARGECODE is not null)) and not (:OLD.CGE_CHARGECODE is null and :NEW.CGE_CHARGECODE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','CGE_CHARGECODE',rid,sysdate,mod_type,:OLD.CGE_CHARGECODE,:NEW.CGE_CHARGECODE,:OLD.INV_INVOICENO,:OLD.CGE_CHARGECODE);
 end if;

 if not((:OLD.QUANTITY = :NEW.QUANTITY) and (:OLD.QUANTITY is not null and :NEW.QUANTITY is not null)) and not (:OLD.QUANTITY is null and :NEW.QUANTITY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','QUANTITY',rid,sysdate,mod_type,:OLD.QUANTITY,:NEW.QUANTITY,pk1,pk2);
 end if;

 if not((:OLD.CGUNIT = :NEW.CGUNIT) and (:OLD.CGUNIT is not null and :NEW.CGUNIT is not null)) and not (:OLD.CGUNIT is null and :NEW.CGUNIT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','CGUNIT',rid,sysdate,mod_type,:OLD.CGUNIT,:NEW.CGUNIT,pk1,pk2);
 end if;

 if not((:OLD.CGDESC = :NEW.CGDESC) and (:OLD.CGDESC is not null and :NEW.CGDESC is not null)) and not (:OLD.CGDESC is null and :NEW.CGDESC is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','CGDESC',rid,sysdate,mod_type,:OLD.CGDESC,:NEW.CGDESC,pk1,pk2);
 end if;

 if not((:OLD.CGRATE = :NEW.CGRATE) and (:OLD.CGRATE is not null and :NEW.CGRATE is not null)) and not (:OLD.CGRATE is null and :NEW.CGRATE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','CGRATE',rid,sysdate,mod_type,:OLD.CGRATE,:NEW.CGRATE,pk1,pk2);
 end if;

 if not((:OLD.GSTC_GSTCODE = :NEW.GSTC_GSTCODE) and (:OLD.GSTC_GSTCODE is not null and :NEW.GSTC_GSTCODE is not null)) and not (:OLD.GSTC_GSTCODE is null and :NEW.GSTC_GSTCODE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','GSTC_GSTCODE',rid,sysdate,mod_type,:OLD.GSTC_GSTCODE,:NEW.GSTC_GSTCODE,pk1,pk2);
 end if;

 if not((:OLD.GST = :NEW.GST) and (:OLD.GST is not null and :NEW.GST is not null)) and not (:OLD.GST is null and :NEW.GST is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','GST',rid,sysdate,mod_type,:OLD.GST,:NEW.GST,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVCHARGES','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_invcharges;
/
