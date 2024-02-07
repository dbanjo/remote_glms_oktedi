CREATE OR REPLACE TRIGGER STRANG.T_INVOICES 
 after insert or update or delete
 ON STRANG.INVOICES
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
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.INVOICENO = :NEW.INVOICENO) and (:OLD.INVOICENO is not null and :NEW.INVOICENO is not null)) and not (:OLD.INVOICENO is null and :NEW.INVOICENO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','INVOICENO',rid,sysdate,mod_type,:OLD.INVOICENO,:NEW.INVOICENO,:OLD.INVOICENO,pk2);
 end if;

 if not((:OLD.INVDATE = :NEW.INVDATE) and (:OLD.INVDATE is not null and :NEW.INVDATE is not null)) and not (:OLD.INVDATE is null and :NEW.INVDATE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','INVDATE',rid,sysdate,mod_type,:OLD.INVDATE,:NEW.INVDATE,'D',pk1,pk2);
 end if;

 if not((:OLD.CTRK_CONTRACT = :NEW.CTRK_CONTRACT) and (:OLD.CTRK_CONTRACT is not null and :NEW.CTRK_CONTRACT is not null)) and not (:OLD.CTRK_CONTRACT is null and :NEW.CTRK_CONTRACT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','CTRK_CONTRACT',rid,sysdate,mod_type,:OLD.CTRK_CONTRACT,:NEW.CTRK_CONTRACT,pk1,pk2);
 end if;

 if not((:OLD.BILLINGMONTH = :NEW.BILLINGMONTH) and (:OLD.BILLINGMONTH is not null and :NEW.BILLINGMONTH is not null)) and not (:OLD.BILLINGMONTH is null and :NEW.BILLINGMONTH is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','BILLINGMONTH',rid,sysdate,mod_type,:OLD.BILLINGMONTH,:NEW.BILLINGMONTH,pk1,pk2);
 end if;

 if not((:OLD.BILLINGYEAR = :NEW.BILLINGYEAR) and (:OLD.BILLINGYEAR is not null and :NEW.BILLINGYEAR is not null)) and not (:OLD.BILLINGYEAR is null and :NEW.BILLINGYEAR is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','BILLINGYEAR',rid,sysdate,mod_type,:OLD.BILLINGYEAR,:NEW.BILLINGYEAR,pk1,pk2);
 end if;

 if not((:OLD.COMPLETED = :NEW.COMPLETED) and (:OLD.COMPLETED is not null and :NEW.COMPLETED is not null)) and not (:OLD.COMPLETED is null and :NEW.COMPLETED is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','COMPLETED',rid,sysdate,mod_type,:OLD.COMPLETED,:NEW.COMPLETED,pk1,pk2);
 end if;

 if not((:OLD.VOLUME = :NEW.VOLUME) and (:OLD.VOLUME is not null and :NEW.VOLUME is not null)) and not (:OLD.VOLUME is null and :NEW.VOLUME is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','VOLUME',rid,sysdate,mod_type,:OLD.VOLUME,:NEW.VOLUME,pk1,pk2);
 end if;

 if not((:OLD.GROSS = :NEW.GROSS) and (:OLD.GROSS is not null and :NEW.GROSS is not null)) and not (:OLD.GROSS is null and :NEW.GROSS is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','GROSS',rid,sysdate,mod_type,:OLD.GROSS,:NEW.GROSS,pk1,pk2);
 end if;

 if not((:OLD.WEIGHT = :NEW.WEIGHT) and (:OLD.WEIGHT is not null and :NEW.WEIGHT is not null)) and not (:OLD.WEIGHT is null and :NEW.WEIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','WEIGHT',rid,sysdate,mod_type,:OLD.WEIGHT,:NEW.WEIGHT,pk1,pk2);
 end if;

 if not((:OLD.REVTON = :NEW.REVTON) and (:OLD.REVTON is not null and :NEW.REVTON is not null)) and not (:OLD.REVTON is null and :NEW.REVTON is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','REVTON',rid,sysdate,mod_type,:OLD.REVTON,:NEW.REVTON,pk1,pk2);
 end if;

 if not((:OLD.CHARGEWEIGHT = :NEW.CHARGEWEIGHT) and (:OLD.CHARGEWEIGHT is not null and :NEW.CHARGEWEIGHT is not null)) and not (:OLD.CHARGEWEIGHT is null and :NEW.CHARGEWEIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','CHARGEWEIGHT',rid,sysdate,mod_type,:OLD.CHARGEWEIGHT,:NEW.CHARGEWEIGHT,pk1,pk2);
 end if;

 if not((:OLD.TOTAL = :NEW.TOTAL) and (:OLD.TOTAL is not null and :NEW.TOTAL is not null)) and not (:OLD.TOTAL is null and :NEW.TOTAL is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','TOTAL',rid,sysdate,mod_type,:OLD.TOTAL,:NEW.TOTAL,pk1,pk2);
 end if;

 if not((:OLD.GSTINCLUSIVE = :NEW.GSTINCLUSIVE) and (:OLD.GSTINCLUSIVE is not null and :NEW.GSTINCLUSIVE is not null)) and not (:OLD.GSTINCLUSIVE is null and :NEW.GSTINCLUSIVE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','GSTINCLUSIVE',rid,sysdate,mod_type,:OLD.GSTINCLUSIVE,:NEW.GSTINCLUSIVE,pk1,pk2);
 end if;

 if not((:OLD.TRANSMITTED = :NEW.TRANSMITTED) and (:OLD.TRANSMITTED is not null and :NEW.TRANSMITTED is not null)) and not (:OLD.TRANSMITTED is null and :NEW.TRANSMITTED is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','TRANSMITTED',rid,sysdate,mod_type,:OLD.TRANSMITTED,:NEW.TRANSMITTED,'D',pk1,pk2);
 end if;

 if not((:OLD.OWNER = :NEW.OWNER) and (:OLD.OWNER is not null and :NEW.OWNER is not null)) and not (:OLD.OWNER is null and :NEW.OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','OWNER',rid,sysdate,mod_type,:OLD.OWNER,:NEW.OWNER,pk1,pk2);
 end if;

 if not((:OLD.INVDESC = :NEW.INVDESC) and (:OLD.INVDESC is not null and :NEW.INVDESC is not null)) and not (:OLD.INVDESC is null and :NEW.INVDESC is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','INVDESC',rid,sysdate,mod_type,:OLD.INVDESC,:NEW.INVDESC,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'INVOICES','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_invoices;
/
