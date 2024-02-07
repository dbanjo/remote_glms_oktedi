CREATE OR REPLACE TRIGGER STRANG.T_SHIPS_AIRWAY 
 after insert or update or delete
 ON STRANG.SHIPS_AIRWAY
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
   pk1 := :NEW.SHIP_ID;
   pk2 := NULL;
 elsif updating
  then
   mod_type := 'U';
   rid := :OLD.ROWID;
   pk1 := :NEW.SHIP_ID;
   pk2 := NULL;
 else
   if global_site.get_name is null then global_site.set_name; end if;
   mod_type := 'D';
   rid := :OLD.ROWID;
   pk1 := :OLD.SHIP_ID;
   pk2 := NULL;
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
   return;
 end if;

 if global_site.get_name is null then global_site.set_name; end if;
 if not((:OLD.SHIP_ID = :NEW.SHIP_ID) and (:OLD.SHIP_ID is not null and :NEW.SHIP_ID is not null)) and not (:OLD.SHIP_ID is null and :NEW.SHIP_ID is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','SHIP_ID',rid,sysdate,mod_type,:OLD.SHIP_ID,:NEW.SHIP_ID,:OLD.SHIP_ID,pk2);
 end if;

 if not((:OLD.SHIPNAME = :NEW.SHIPNAME) and (:OLD.SHIPNAME is not null and :NEW.SHIPNAME is not null)) and not (:OLD.SHIPNAME is null and :NEW.SHIPNAME is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','SHIPNAME',rid,sysdate,mod_type,:OLD.SHIPNAME,:NEW.SHIPNAME,pk1,pk2);
 end if;

 if not((:OLD.VOY = :NEW.VOY) and (:OLD.VOY is not null and :NEW.VOY is not null)) and not (:OLD.VOY is null and :NEW.VOY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','VOY',rid,sysdate,mod_type,:OLD.VOY,:NEW.VOY,pk1,pk2);
 end if;

 if not((:OLD.SHIPMASTER = :NEW.SHIPMASTER) and (:OLD.SHIPMASTER is not null and :NEW.SHIPMASTER is not null)) and not (:OLD.SHIPMASTER is null and :NEW.SHIPMASTER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','SHIPMASTER',rid,sysdate,mod_type,:OLD.SHIPMASTER,:NEW.SHIPMASTER,pk1,pk2);
 end if;

 if not((:OLD.ESTDEPART = :NEW.ESTDEPART) and (:OLD.ESTDEPART is not null and :NEW.ESTDEPART is not null)) and not (:OLD.ESTDEPART is null and :NEW.ESTDEPART is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ESTDEPART',rid,sysdate,mod_type,:OLD.ESTDEPART,:NEW.ESTDEPART,'D',pk1,pk2);
 end if;

 if not((:OLD.ESTARRIVE = :NEW.ESTARRIVE) and (:OLD.ESTARRIVE is not null and :NEW.ESTARRIVE is not null)) and not (:OLD.ESTARRIVE is null and :NEW.ESTARRIVE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_date,new_date,data_type,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ESTARRIVE',rid,sysdate,mod_type,:OLD.ESTARRIVE,:NEW.ESTARRIVE,'D',pk1,pk2);
 end if;

 if not((:OLD.PORTLOAD = :NEW.PORTLOAD) and (:OLD.PORTLOAD is not null and :NEW.PORTLOAD is not null)) and not (:OLD.PORTLOAD is null and :NEW.PORTLOAD is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','PORTLOAD',rid,sysdate,mod_type,:OLD.PORTLOAD,:NEW.PORTLOAD,pk1,pk2);
 end if;

 if not((:OLD.PORTDISC = :NEW.PORTDISC) and (:OLD.PORTDISC is not null and :NEW.PORTDISC is not null)) and not (:OLD.PORTDISC is null and :NEW.PORTDISC is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','PORTDISC',rid,sysdate,mod_type,:OLD.PORTDISC,:NEW.PORTDISC,pk1,pk2);
 end if;

 if not((:OLD.SHIPCOUNTRY = :NEW.SHIPCOUNTRY) and (:OLD.SHIPCOUNTRY is not null and :NEW.SHIPCOUNTRY is not null)) and not (:OLD.SHIPCOUNTRY is null and :NEW.SHIPCOUNTRY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','SHIPCOUNTRY',rid,sysdate,mod_type,:OLD.SHIPCOUNTRY,:NEW.SHIPCOUNTRY,pk1,pk2);
 end if;

 if not((:OLD.SHIPWEIGHT = :NEW.SHIPWEIGHT) and (:OLD.SHIPWEIGHT is not null and :NEW.SHIPWEIGHT is not null)) and not (:OLD.SHIPWEIGHT is null and :NEW.SHIPWEIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','SHIPWEIGHT',rid,sysdate,mod_type,:OLD.SHIPWEIGHT,:NEW.SHIPWEIGHT,pk1,pk2);
 end if;

 if not((:OLD.AUSTCREW = :NEW.AUSTCREW) and (:OLD.AUSTCREW is not null and :NEW.AUSTCREW is not null)) and not (:OLD.AUSTCREW is null and :NEW.AUSTCREW is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','AUSTCREW',rid,sysdate,mod_type,:OLD.AUSTCREW,:NEW.AUSTCREW,pk1,pk2);
 end if;

 if not((:OLD.PNGCREW = :NEW.PNGCREW) and (:OLD.PNGCREW is not null and :NEW.PNGCREW is not null)) and not (:OLD.PNGCREW is null and :NEW.PNGCREW is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','PNGCREW',rid,sysdate,mod_type,:OLD.PNGCREW,:NEW.PNGCREW,pk1,pk2);
 end if;

 if not((:OLD.FRNCREW = :NEW.FRNCREW) and (:OLD.FRNCREW is not null and :NEW.FRNCREW is not null)) and not (:OLD.FRNCREW is null and :NEW.FRNCREW is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','FRNCREW',rid,sysdate,mod_type,:OLD.FRNCREW,:NEW.FRNCREW,pk1,pk2);
 end if;

 if not((:OLD.FINALDEST = :NEW.FINALDEST) and (:OLD.FINALDEST is not null and :NEW.FINALDEST is not null)) and not (:OLD.FINALDEST is null and :NEW.FINALDEST is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','FINALDEST',rid,sysdate,mod_type,:OLD.FINALDEST,:NEW.FINALDEST,pk1,pk2);
 end if;

 if not((:OLD.CUSTOMER_ID = :NEW.CUSTOMER_ID) and (:OLD.CUSTOMER_ID is not null and :NEW.CUSTOMER_ID is not null)) and not (:OLD.CUSTOMER_ID is null and :NEW.CUSTOMER_ID is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','CUSTOMER_ID',rid,sysdate,mod_type,:OLD.CUSTOMER_ID,:NEW.CUSTOMER_ID,pk1,pk2);
 end if;

 if not((:OLD.SHIP_AIRWAY = :NEW.SHIP_AIRWAY) and (:OLD.SHIP_AIRWAY is not null and :NEW.SHIP_AIRWAY is not null)) and not (:OLD.SHIP_AIRWAY is null and :NEW.SHIP_AIRWAY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','SHIP_AIRWAY',rid,sysdate,mod_type,:OLD.SHIP_AIRWAY,:NEW.SHIP_AIRWAY,pk1,pk2);
 end if;

 if not((:OLD.MANIFEST_CREATED = :NEW.MANIFEST_CREATED) and (:OLD.MANIFEST_CREATED is not null and :NEW.MANIFEST_CREATED is not null)) and not (:OLD.MANIFEST_CREATED is null and :NEW.MANIFEST_CREATED is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','MANIFEST_CREATED',rid,sysdate,mod_type,:OLD.MANIFEST_CREATED,:NEW.MANIFEST_CREATED,pk1,pk2);
 end if;

 if not((:OLD.CONTROLLING_OFFICE = :NEW.CONTROLLING_OFFICE) and (:OLD.CONTROLLING_OFFICE is not null and :NEW.CONTROLLING_OFFICE is not null)) and not (:OLD.CONTROLLING_OFFICE is null and :NEW.CONTROLLING_OFFICE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','CONTROLLING_OFFICE',rid,sysdate,mod_type,:OLD.CONTROLLING_OFFICE,:NEW.CONTROLLING_OFFICE,pk1,pk2);
 end if;

 if not((:OLD.RATE = :NEW.RATE) and (:OLD.RATE is not null and :NEW.RATE is not null)) and not (:OLD.RATE is null and :NEW.RATE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','RATE',rid,sysdate,mod_type,:OLD.RATE,:NEW.RATE,pk1,pk2);
 end if;

 if not((:OLD.FREIGHT = :NEW.FREIGHT) and (:OLD.FREIGHT is not null and :NEW.FREIGHT is not null)) and not (:OLD.FREIGHT is null and :NEW.FREIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','FREIGHT',rid,sysdate,mod_type,:OLD.FREIGHT,:NEW.FREIGHT,pk1,pk2);
 end if;

 if not((:OLD.INSURANCE = :NEW.INSURANCE) and (:OLD.INSURANCE is not null and :NEW.INSURANCE is not null)) and not (:OLD.INSURANCE is null and :NEW.INSURANCE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','INSURANCE',rid,sysdate,mod_type,:OLD.INSURANCE,:NEW.INSURANCE,pk1,pk2);
 end if;

 if not((:OLD.OTHER_COSTS = :NEW.OTHER_COSTS) and (:OLD.OTHER_COSTS is not null and :NEW.OTHER_COSTS is not null)) and not (:OLD.OTHER_COSTS is null and :NEW.OTHER_COSTS is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','OTHER_COSTS',rid,sysdate,mod_type,:OLD.OTHER_COSTS,:NEW.OTHER_COSTS,pk1,pk2);
 end if;

 if not((:OLD.VAT = :NEW.VAT) and (:OLD.VAT is not null and :NEW.VAT is not null)) and not (:OLD.VAT is null and :NEW.VAT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','VAT',rid,sysdate,mod_type,:OLD.VAT,:NEW.VAT,pk1,pk2);
 end if;

 if not((:OLD.STATUS = :NEW.STATUS) and (:OLD.STATUS is not null and :NEW.STATUS is not null)) and not (:OLD.STATUS is null and :NEW.STATUS is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','STATUS',rid,sysdate,mod_type,:OLD.STATUS,:NEW.STATUS,pk1,pk2);
 end if;

 if not((:OLD.PORT_FROM = :NEW.PORT_FROM) and (:OLD.PORT_FROM is not null and :NEW.PORT_FROM is not null)) and not (:OLD.PORT_FROM is null and :NEW.PORT_FROM is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','PORT_FROM',rid,sysdate,mod_type,:OLD.PORT_FROM,:NEW.PORT_FROM,pk1,pk2);
 end if;

 if not((:OLD.CUSTOMS_AGENT = :NEW.CUSTOMS_AGENT) and (:OLD.CUSTOMS_AGENT is not null and :NEW.CUSTOMS_AGENT is not null)) and not (:OLD.CUSTOMS_AGENT is null and :NEW.CUSTOMS_AGENT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','CUSTOMS_AGENT',rid,sysdate,mod_type,:OLD.CUSTOMS_AGENT,:NEW.CUSTOMS_AGENT,pk1,pk2);
 end if;

 if not((:OLD.LICENCE_NO = :NEW.LICENCE_NO) and (:OLD.LICENCE_NO is not null and :NEW.LICENCE_NO is not null)) and not (:OLD.LICENCE_NO is null and :NEW.LICENCE_NO is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','LICENCE_NO',rid,sysdate,mod_type,:OLD.LICENCE_NO,:NEW.LICENCE_NO,pk1,pk2);
 end if;

 if not((:OLD.P2ACODE = :NEW.P2ACODE) and (:OLD.P2ACODE is not null and :NEW.P2ACODE is not null)) and not (:OLD.P2ACODE is null and :NEW.P2ACODE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','P2ACODE',rid,sysdate,mod_type,:OLD.P2ACODE,:NEW.P2ACODE,pk1,pk2);
 end if;

 if not((:OLD.CPC = :NEW.CPC) and (:OLD.CPC is not null and :NEW.CPC is not null)) and not (:OLD.CPC is null and :NEW.CPC is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','CPC',rid,sysdate,mod_type,:OLD.CPC,:NEW.CPC,pk1,pk2);
 end if;

 if not((:OLD.PRECEDING_DOCUMENTS = :NEW.PRECEDING_DOCUMENTS) and (:OLD.PRECEDING_DOCUMENTS is not null and :NEW.PRECEDING_DOCUMENTS is not null)) and not (:OLD.PRECEDING_DOCUMENTS is null and :NEW.PRECEDING_DOCUMENTS is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','PRECEDING_DOCUMENTS',rid,sysdate,mod_type,:OLD.PRECEDING_DOCUMENTS,:NEW.PRECEDING_DOCUMENTS,pk1,pk2);
 end if;

 if not((:OLD.TERMS_OF_DELIVERY = :NEW.TERMS_OF_DELIVERY) and (:OLD.TERMS_OF_DELIVERY is not null and :NEW.TERMS_OF_DELIVERY is not null)) and not (:OLD.TERMS_OF_DELIVERY is null and :NEW.TERMS_OF_DELIVERY is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','TERMS_OF_DELIVERY',rid,sysdate,mod_type,:OLD.TERMS_OF_DELIVERY,:NEW.TERMS_OF_DELIVERY,pk1,pk2);
 end if;

 if not((:OLD.ACCOUNT_NUMBER = :NEW.ACCOUNT_NUMBER) and (:OLD.ACCOUNT_NUMBER is not null and :NEW.ACCOUNT_NUMBER is not null)) and not (:OLD.ACCOUNT_NUMBER is null and :NEW.ACCOUNT_NUMBER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ACCOUNT_NUMBER',rid,sysdate,mod_type,:OLD.ACCOUNT_NUMBER,:NEW.ACCOUNT_NUMBER,pk1,pk2);
 end if;

 if not((:OLD.ATTACHMENTS_INVOICES = :NEW.ATTACHMENTS_INVOICES) and (:OLD.ATTACHMENTS_INVOICES is not null and :NEW.ATTACHMENTS_INVOICES is not null)) and not (:OLD.ATTACHMENTS_INVOICES is null and :NEW.ATTACHMENTS_INVOICES is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ATTACHMENTS_INVOICES',rid,sysdate,mod_type,:OLD.ATTACHMENTS_INVOICES,:NEW.ATTACHMENTS_INVOICES,pk1,pk2);
 end if;

 if not((:OLD.ATTACHMENTS_PACKING = :NEW.ATTACHMENTS_PACKING) and (:OLD.ATTACHMENTS_PACKING is not null and :NEW.ATTACHMENTS_PACKING is not null)) and not (:OLD.ATTACHMENTS_PACKING is null and :NEW.ATTACHMENTS_PACKING is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ATTACHMENTS_PACKING',rid,sysdate,mod_type,:OLD.ATTACHMENTS_PACKING,:NEW.ATTACHMENTS_PACKING,pk1,pk2);
 end if;

 if not((:OLD.ATTACHMENTS_ORDER = :NEW.ATTACHMENTS_ORDER) and (:OLD.ATTACHMENTS_ORDER is not null and :NEW.ATTACHMENTS_ORDER is not null)) and not (:OLD.ATTACHMENTS_ORDER is null and :NEW.ATTACHMENTS_ORDER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ATTACHMENTS_ORDER',rid,sysdate,mod_type,:OLD.ATTACHMENTS_ORDER,:NEW.ATTACHMENTS_ORDER,pk1,pk2);
 end if;

 if not((:OLD.ATTACHMENTS_LICENCE = :NEW.ATTACHMENTS_LICENCE) and (:OLD.ATTACHMENTS_LICENCE is not null and :NEW.ATTACHMENTS_LICENCE is not null)) and not (:OLD.ATTACHMENTS_LICENCE is null and :NEW.ATTACHMENTS_LICENCE is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ATTACHMENTS_LICENCE',rid,sysdate,mod_type,:OLD.ATTACHMENTS_LICENCE,:NEW.ATTACHMENTS_LICENCE,pk1,pk2);
 end if;

 if not((:OLD.ATTACHMENTS_FREIGHT = :NEW.ATTACHMENTS_FREIGHT) and (:OLD.ATTACHMENTS_FREIGHT is not null and :NEW.ATTACHMENTS_FREIGHT is not null)) and not (:OLD.ATTACHMENTS_FREIGHT is null and :NEW.ATTACHMENTS_FREIGHT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ATTACHMENTS_FREIGHT',rid,sysdate,mod_type,:OLD.ATTACHMENTS_FREIGHT,:NEW.ATTACHMENTS_FREIGHT,pk1,pk2);
 end if;

 if not((:OLD.ATTACHMENTS_OTHER = :NEW.ATTACHMENTS_OTHER) and (:OLD.ATTACHMENTS_OTHER is not null and :NEW.ATTACHMENTS_OTHER is not null)) and not (:OLD.ATTACHMENTS_OTHER is null and :NEW.ATTACHMENTS_OTHER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','ATTACHMENTS_OTHER',rid,sysdate,mod_type,:OLD.ATTACHMENTS_OTHER,:NEW.ATTACHMENTS_OTHER,pk1,pk2);
 end if;

 if not((:OLD.PCOMMENT = :NEW.PCOMMENT) and (:OLD.PCOMMENT is not null and :NEW.PCOMMENT is not null)) and not (:OLD.PCOMMENT is null and :NEW.PCOMMENT is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','PCOMMENT',rid,sysdate,mod_type,:OLD.PCOMMENT,:NEW.PCOMMENT,pk1,pk2);
 end if;

 if not((:OLD.COMPARATIVE_WORKSHEET = :NEW.COMPARATIVE_WORKSHEET) and (:OLD.COMPARATIVE_WORKSHEET is not null and :NEW.COMPARATIVE_WORKSHEET is not null)) and not (:OLD.COMPARATIVE_WORKSHEET is null and :NEW.COMPARATIVE_WORKSHEET is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','COMPARATIVE_WORKSHEET',rid,sysdate,mod_type,:OLD.COMPARATIVE_WORKSHEET,:NEW.COMPARATIVE_WORKSHEET,pk1,pk2);
 end if;

 if not((:OLD.NATIONALITY_MASTER = :NEW.NATIONALITY_MASTER) and (:OLD.NATIONALITY_MASTER is not null and :NEW.NATIONALITY_MASTER is not null)) and not (:OLD.NATIONALITY_MASTER is null and :NEW.NATIONALITY_MASTER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','NATIONALITY_MASTER',rid,sysdate,mod_type,:OLD.NATIONALITY_MASTER,:NEW.NATIONALITY_MASTER,pk1,pk2);
 end if;

 if not((:OLD.SITE_OWNER = :NEW.SITE_OWNER) and (:OLD.SITE_OWNER is not null and :NEW.SITE_OWNER is not null)) and not (:OLD.SITE_OWNER is null and :NEW.SITE_OWNER is null)
  then
   insert into replication(replication_id,site,table_name,column_name,row_changed,date_changed,change_type,old_value,new_value,pk_col1,pk_col2) values
    (s_replication.nextval,nvl(global_site.site_name,'PRIMARY'),'SHIPS_AIRWAY','SITE_OWNER',rid,sysdate,mod_type,:OLD.SITE_OWNER,:NEW.SITE_OWNER,pk1,pk2);
 end if;

end t_ships_airway;
/
