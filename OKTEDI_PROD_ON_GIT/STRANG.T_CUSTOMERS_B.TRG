CREATE OR REPLACE TRIGGER STRANG.T_CUSTOMERS_B 
 Before Insert Or Update
 ON STRANG.CUSTOMERS
 For Each Row
DISABLE
Declare

BEGIN

 if nvl(global_site.disable_trigger,FALSE) then return; end if;
 if global_site.disable_trigger is NULL or :NEW.date_modified is NULL
  then
   :NEW.date_modified := sysdate;
 end if;
 if global_site.get_name is null then global_site.set_name; end if;
 If :New.Site_Owner Is Not Null Then Return; End If;
 If Inserting
  Then
   :New.Site_Owner := Global_Site.Site_Name;
 Elsif Updating
  Then
   :New.Site_Owner := Global_Site.Site_Name;
 End If;

END T_CUSTOMERS_B;
/
