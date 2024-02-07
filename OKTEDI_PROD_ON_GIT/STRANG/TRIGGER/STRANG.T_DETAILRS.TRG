CREATE OR REPLACE TRIGGER STRANG.T_DETAILRS 
 after insert or update or delete
 ON STRANG.DETAILRS
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
   pk1 := :NEW.deliveryno;
   pk2 := :NEW.itemno;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.deliveryno;
   pk2 := :NEW.itemno;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.deliveryno;
   pk2 := :OLD.itemno;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;

 if not((:OLD.DELIVERYNO = :NEW.DELIVERYNO) and (:OLD.DELIVERYNO is not null and :NEW.DELIVERYNO is not null)) and not (:OLD.DELIVERYNO is null and :NEW.DELIVERYNO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','DELIVERYNO',rid,sysdate,mod_type,:OLD.DELIVERYNO,:NEW.DELIVERYNO,:OLD.DELIVERYNO,:OLD.itemno);
 end if;

 if not((:OLD.itemno = :NEW.itemno) and (:OLD.itemno is not null and :NEW.itemno is not null)) and not (:OLD.itemno is null and :NEW.itemno is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','ITEMNO',rid,sysdate,mod_type,:OLD.itemno,:NEW.itemno,:OLD.DELIVERYNO,:OLD.itemno);
 end if;

 if not((:OLD.logno = :NEW.logno) and (:OLD.logno is not null and :NEW.logno is not null)) and not (:OLD.logno is null and :NEW.logno is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','LOGNO',rid,sysdate,mod_type,:OLD.logno,:NEW.logno,pk1,pk2);
 end if;

 if not((:OLD.HAWB_HAWBNO = :NEW.HAWB_HAWBNO) and (:OLD.HAWB_HAWBNO is not null and :NEW.HAWB_HAWBNO is not null)) and not (:OLD.HAWB_HAWBNO is null and :NEW.HAWB_HAWBNO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','HAWB_HAWBNO',rid,sysdate,mod_type,:OLD.HAWB_HAWBNO,:NEW.HAWB_HAWBNO,pk1,pk2);
 end if;

 if not((:OLD.CAMOV_SEAL = :NEW.CAMOV_SEAL) and (:OLD.CAMOV_SEAL is not null and :NEW.CAMOV_SEAL is not null)) and not (:OLD.CAMOV_SEAL is null and :NEW.CAMOV_SEAL is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','CAMOV_SEAL',rid,sysdate,mod_type,:OLD.CAMOV_SEAL,:NEW.CAMOV_SEAL,pk1,pk2);
 end if;

 if not((:OLD.DETAILDESC = :NEW.DETAILDESC) and (:OLD.DETAILDESC is not null and :NEW.DETAILDESC is not null)) and not (:OLD.DETAILDESC is null and :NEW.DETAILDESC is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','DETAILDESC',rid,sysdate,mod_type,:OLD.DETAILDESC,:NEW.DETAILDESC,pk1,pk2);
 end if;

 if not((:OLD.HAZARD = :NEW.HAZARD) and (:OLD.HAZARD is not null and :NEW.HAZARD is not null)) and not (:OLD.HAZARD is null and :NEW.HAZARD is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','HAZARD',rid,sysdate,mod_type,:OLD.HAZARD,:NEW.HAZARD,pk1,pk2);
 end if;

 if not((:OLD.ECN = :NEW.ECN) and (:OLD.ECN is not null and :NEW.ECN is not null)) and not (:OLD.ECN is null and :NEW.ECN is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','ECN',rid,sysdate,mod_type,:OLD.ECN,:NEW.ECN,pk1,pk2);
 end if;

 if not((:OLD.SA = :NEW.SA) and (:OLD.SA is not null and :NEW.SA is not null)) and not (:OLD.SA is null and :NEW.SA is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','SA',rid,sysdate,mod_type,:OLD.SA,:NEW.SA,pk1,pk2);
 end if;

 if not((:OLD.CL = :NEW.CL) and (:OLD.CL is not null and :NEW.CL is not null)) and not (:OLD.CL is null and :NEW.CL is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','CL',rid,sysdate,mod_type,:OLD.CL,:NEW.CL,pk1,pk2);
 end if;

 if not((:OLD.PKTPE_PACKTYPE = :NEW.PKTPE_PACKTYPE) and (:OLD.PKTPE_PACKTYPE is not null and :NEW.PKTPE_PACKTYPE is not null)) and not (:OLD.PKTPE_PACKTYPE is null and :NEW.PKTPE_PACKTYPE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','PKTPE_PACKTYPE',rid,sysdate,mod_type,:OLD.PKTPE_PACKTYPE,:NEW.PKTPE_PACKTYPE,pk1,pk2);
 end if;

 if not((:OLD.OWNER = :NEW.OWNER) and (:OLD.OWNER is not null and :NEW.OWNER is not null)) and not (:OLD.OWNER is null and :NEW.OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','OWNER',rid,sysdate,mod_type,:OLD.OWNER,:NEW.OWNER,pk1,pk2);
 end if;

 if not((:OLD.PARTVOLUME = :NEW.PARTVOLUME) and (:OLD.PARTVOLUME is not null and :NEW.PARTVOLUME is not null)) and not (:OLD.PARTVOLUME is null and :NEW.PARTVOLUME is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','PARTVOLUME',rid,sysdate,mod_type,:OLD.PARTVOLUME,:NEW.PARTVOLUME,pk1,pk2);
 end if;

 if not((:OLD.PARTWEIGHT = :NEW.PARTWEIGHT) and (:OLD.PARTWEIGHT is not null and :NEW.PARTWEIGHT is not null)) and not (:OLD.PARTWEIGHT is null and :NEW.PARTWEIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','PARTWEIGHT',rid,sysdate,mod_type,:OLD.PARTWEIGHT,:NEW.PARTWEIGHT,pk1,pk2);
 end if;

 if not((:OLD.QTY = :NEW.QTY) and (:OLD.QTY is not null and :NEW.QTY is not null)) and not (:OLD.QTY is null and :NEW.QTY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','QTY',rid,sysdate,mod_type,:OLD.QTY,:NEW.QTY,pk1,pk2);
 end if;

 if not((:OLD.MOVEMENT_NO = :NEW.MOVEMENT_NO) and (:OLD.MOVEMENT_NO is not null and :NEW.MOVEMENT_NO is not null)) and not (:OLD.MOVEMENT_NO is null and :NEW.MOVEMENT_NO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','MOVEMENT_NO',rid,sysdate,mod_type,:OLD.MOVEMENT_NO,:NEW.MOVEMENT_NO,pk1,pk2);
 end if;

 if not((:OLD.ENTRY_NO = :NEW.ENTRY_NO) and (:OLD.ENTRY_NO is not null and :NEW.ENTRY_NO is not null)) and not (:OLD.ENTRY_NO is null and :NEW.ENTRY_NO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','ENTRY_NO',rid,sysdate,mod_type,:OLD.ENTRY_NO,:NEW.ENTRY_NO,pk1,pk2);
 end if;

 if not((:OLD.LINE_NO = :NEW.LINE_NO) and (:OLD.LINE_NO is not null and :NEW.LINE_NO is not null)) and not (:OLD.LINE_NO is null and :NEW.LINE_NO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','LINE_NO',rid,sysdate,mod_type,:OLD.LINE_NO,:NEW.LINE_NO,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'DETAILRS','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_detailrs;
/
