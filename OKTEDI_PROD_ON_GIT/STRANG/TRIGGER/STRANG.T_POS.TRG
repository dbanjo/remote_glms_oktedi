CREATE OR REPLACE TRIGGER STRANG.T_POS 
 after insert or update or delete
 ON STRANG.POS
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
   pk1 := :NEW.deliveryno;
   pk2 := :NEW.recno;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.deliveryno;
   pk2 := :NEW.recno;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.deliveryno;
   pk2 := :OLD.recno;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.DELIVERYNO = :NEW.DELIVERYNO) and (:OLD.DELIVERYNO is not null and :NEW.DELIVERYNO is not null)) and not (:OLD.DELIVERYNO is null and :NEW.DELIVERYNO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','DELIVERYNO',rid,sysdate,mod_type,:OLD.DELIVERYNO,:NEW.DELIVERYNO,:OLD.DELIVERYNO,:OLD.RECNO);
 end if;

 if not((:OLD.RECNO = :NEW.RECNO) and (:OLD.RECNO is not null and :NEW.RECNO is not null)) and not (:OLD.RECNO is null and :NEW.RECNO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','RECNO',rid,sysdate,mod_type,:OLD.RECNO,:NEW.RECNO,:OLD.DELIVERYNO,:OLD.RECNO);
 end if;

 if not((:OLD.INVENTORYNO = :NEW.INVENTORYNO) and (:OLD.INVENTORYNO is not null and :NEW.INVENTORYNO is not null)) and not (:OLD.INVENTORYNO is null and :NEW.INVENTORYNO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','INVENTORYNO',rid,sysdate,mod_type,:OLD.INVENTORYNO,:NEW.INVENTORYNO,pk1,pk2);
 end if;

 if not((:OLD.PO = :NEW.PO) and (:OLD.PO is not null and :NEW.PO is not null)) and not (:OLD.PO is null and :NEW.PO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','PO',rid,sysdate,mod_type,:OLD.PO,:NEW.PO,pk1,pk2);
 end if;

 if not((:OLD.SUPINV = :NEW.SUPINV) and (:OLD.SUPINV is not null and :NEW.SUPINV is not null)) and not (:OLD.SUPINV is null and :NEW.SUPINV is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','SUPINV',rid,sysdate,mod_type,:OLD.SUPINV,:NEW.SUPINV,pk1,pk2);
 end if;

 if not((:OLD.AMOUNT = :NEW.AMOUNT) and (:OLD.AMOUNT is not null and :NEW.AMOUNT is not null)) and not (:OLD.AMOUNT is null and :NEW.AMOUNT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','AMOUNT',rid,sysdate,mod_type,:OLD.AMOUNT,:NEW.AMOUNT,pk1,pk2);
 end if;

 if not((:OLD.QTY = :NEW.QTY) and (:OLD.QTY is not null and :NEW.QTY is not null)) and not (:OLD.QTY is null and :NEW.QTY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','QTY',rid,sysdate,mod_type,:OLD.QTY,:NEW.QTY,pk1,pk2);
 end if;

 if not((:OLD.UNIT_UNITUSED = :NEW.UNIT_UNITUSED) and (:OLD.UNIT_UNITUSED is not null and :NEW.UNIT_UNITUSED is not null)) and not (:OLD.UNIT_UNITUSED is null and :NEW.UNIT_UNITUSED is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','UNIT_UNITUSED',rid,sysdate,mod_type,:OLD.UNIT_UNITUSED,:NEW.UNIT_UNITUSED,pk1,pk2);
 end if;

 if not((:OLD.CTRY_COUNTRYCODE = :NEW.CTRY_COUNTRYCODE) and (:OLD.CTRY_COUNTRYCODE is not null and :NEW.CTRY_COUNTRYCODE is not null)) and not (:OLD.CTRY_COUNTRYCODE is null and :NEW.CTRY_COUNTRYCODE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','CTRY_COUNTRYCODE',rid,sysdate,mod_type,:OLD.CTRY_COUNTRYCODE,:NEW.CTRY_COUNTRYCODE,pk1,pk2);
 end if;

 if not((:OLD.GSTC_GSTCODE = :NEW.GSTC_GSTCODE) and (:OLD.GSTC_GSTCODE is not null and :NEW.GSTC_GSTCODE is not null)) and not (:OLD.GSTC_GSTCODE is null and :NEW.GSTC_GSTCODE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','GSTC_GSTCODE',rid,sysdate,mod_type,:OLD.GSTC_GSTCODE,:NEW.GSTC_GSTCODE,pk1,pk2);
 end if;

 if not((:OLD.GST = :NEW.GST) and (:OLD.GST is not null and :NEW.GST is not null)) and not (:OLD.GST is null and :NEW.GST is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','GST',rid,sysdate,mod_type,:OLD.GST,:NEW.GST,pk1,pk2);
 end if;

 if not((:OLD.TAMOUNT = :NEW.TAMOUNT) and (:OLD.TAMOUNT is not null and :NEW.TAMOUNT is not null)) and not (:OLD.TAMOUNT is null and :NEW.TAMOUNT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','TAMOUNT',rid,sysdate,mod_type,:OLD.TAMOUNT,:NEW.TAMOUNT,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'POS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;


end t_pos;
/
