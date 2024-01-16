CREATE OR REPLACE FORCE VIEW WEBSYS.UNLOAD_MANUFACTURER
(MFC_PURCH_ID, LAB_ACCOUNT_ID, BUSINESS_NAME, ABN_NUMBER, PHG_USERNAME, 
 PHOTOGRAPHER_ACCOUNT_ID, CUST_USERNAME, FSID, STATUS, PAY_STATUS, 
 DATE_RECEIVED, DATE_DUE, TOTAL_CHARGE)
AS 
select fm.mfc_purch_id,ph.lab_account_id,ph.business_name,ph.abn_number,ph.username phg_username,ca.photographer_account_id,ca.username cust_username,fm.fsid,fm.status,
       fm.pay_status,fm.date_received,fm.date_due,fm.total_charge
from form_made fm, photographer ph, customer_account ca
where fm.aid = ca.aid and
      fm.pid = ph.pid
order by ph.business_name,ca.account_name,fm.fsid;
