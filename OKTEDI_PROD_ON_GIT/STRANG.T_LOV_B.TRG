CREATE OR REPLACE TRIGGER STRANG.T_LOV_B 
 before insert or update
 ON STRANG.LOV
 for each row
DISABLE
declare

begin

 if nvl(global_site.disable_trigger,FALSE) then return; end if;
 if global_site.disable_trigger is NULL or :NEW.date_modified is NULL
  then
   :NEW.date_modified := sysdate;
 end if;
 if global_site.get_name is null then global_site.set_name; end if;
 if :NEW.site_owner is not null then return; end if;
 if inserting
  then
   :NEW.site_owner := global_site.site_name;
 elsif updating
  then
   :NEW.site_owner := global_site.site_name;
 end if;

end t_lov_b;
/
