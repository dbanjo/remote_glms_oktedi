CREATE OR REPLACE FORCE VIEW WEBSYS.UNLOAD_FORM_MADE
(LAB_ACCOUNT_ID, PID, BUSINESS_NAME, PHOTOGRAPHER_ACCOUNT_ID, AID, 
 ACCOUNT_NAME, STATUS, PHG_ABN, PAY_STATUS, DATE_RECEIVED, 
 DATE_DUE, TOTAL_CHARGE, FSID)
AS 
select ph.lab_account_id,ph.pid,ph.business_name,ca.photographer_account_id,ca.aid,ca.account_name,fm.status,fm.phg_abn,fm.pay_status,fm.date_received,fm.date_due,fm.total_charge,fm.fsid
from form_made fm, photographer ph, customer_account ca
where fm.aid = ca.aid and
      fm.pid = ph.pid
order by ph.business_name,ca.account_name,fm.fsid;
