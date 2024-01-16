CREATE OR REPLACE TRIGGER STRANG.T_RECEIVALS 
 after insert or update or delete
 ON STRANG.RECEIVALS
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
   pk1 := :NEW.DELIVERYNO;
   pk2 := NULL;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.DELIVERYNO;
   pk2 := NULL;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.DELIVERYNO;
   pk2 := NULL;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.DELIVERYNO = :NEW.DELIVERYNO) and (:OLD.DELIVERYNO is not null and :NEW.DELIVERYNO is not null)) and not (:OLD.DELIVERYNO is null and :NEW.DELIVERYNO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','DELIVERYNO',rid,sysdate,mod_type,:OLD.DELIVERYNO,:NEW.DELIVERYNO,:OLD.DELIVERYNO,pk2);
 end if;

 if not((:OLD.CURRDATE = :NEW.CURRDATE) and (:OLD.CURRDATE is not null and :NEW.CURRDATE is not null)) and not (:OLD.CURRDATE is null and :NEW.CURRDATE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','CURRDATE',rid,sysdate,mod_type,:OLD.CURRDATE,:NEW.CURRDATE,'D',pk1,pk2);
 end if;

 if not((:OLD.CURR = :NEW.CURR) and (:OLD.CURR is not null and :NEW.CURR is not null)) and not (:OLD.CURR is null and :NEW.CURR is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','CURR',rid,sysdate,mod_type,:OLD.CURR,:NEW.CURR,pk1,pk2);
 end if;

 if not((:OLD.EXRATE = :NEW.EXRATE) and (:OLD.EXRATE is not null and :NEW.EXRATE is not null)) and not (:OLD.EXRATE is null and :NEW.EXRATE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','EXRATE',rid,sysdate,mod_type,:OLD.EXRATE,:NEW.EXRATE,pk1,pk2);
 end if;

 if not((:OLD.GSTC_GSTCODE = :NEW.GSTC_GSTCODE) and (:OLD.GSTC_GSTCODE is not null and :NEW.GSTC_GSTCODE is not null)) and not (:OLD.GSTC_GSTCODE is null and :NEW.GSTC_GSTCODE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','GSTC_GSTCODE',rid,sysdate,mod_type,:OLD.GSTC_GSTCODE,:NEW.GSTC_GSTCODE,pk1,pk2);
 end if;

 if not((:OLD.CUST_CUSTOMER_ID = :NEW.CUST_CUSTOMER_ID) and (:OLD.CUST_CUSTOMER_ID is not null and :NEW.CUST_CUSTOMER_ID is not null)) and not (:OLD.CUST_CUSTOMER_ID is null and :NEW.CUST_CUSTOMER_ID is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','CUST_CUSTOMER_ID',rid,sysdate,mod_type,:OLD.CUST_CUSTOMER_ID,:NEW.CUST_CUSTOMER_ID,pk1,pk2);
 end if;

 if not((:OLD.SUPPLIER_CUSTOMER_ID = :NEW.SUPPLIER_CUSTOMER_ID) and (:OLD.SUPPLIER_CUSTOMER_ID is not null and :NEW.SUPPLIER_CUSTOMER_ID is not null)) and not (:OLD.SUPPLIER_CUSTOMER_ID is null and :NEW.SUPPLIER_CUSTOMER_ID is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','SUPPLIER_CUSTOMER_ID',rid,sysdate,mod_type,:OLD.SUPPLIER_CUSTOMER_ID,:NEW.SUPPLIER_CUSTOMER_ID,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'RECEIVALS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_receivals;
/
