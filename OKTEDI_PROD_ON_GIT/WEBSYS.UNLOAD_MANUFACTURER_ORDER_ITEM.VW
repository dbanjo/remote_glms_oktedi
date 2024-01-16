CREATE OR REPLACE FORCE VIEW WEBSYS.UNLOAD_MANUFACTURER_ORDER_ITEM
(LAB_ACCOUNT_ID, MFC_PURCH_ID, FSID, POID, SHOPPING_ID, 
 QTY, PHOTO_SIZE, PRICE, TAX, COMMISSION, 
 FILM_TYPE, NAME, IS_DISCOUNTED, FILM_NAME, MANUFCTR_CODE, 
 XREF_MFCTR_CODE)
AS 
select ph.lab_account_id,
       fm.mfc_purch_id,fm.fsid,
       sb.poid, sb.shopping_id,sb.qty,sb.photo_size,sb.price,sb.tax,sb.commission,sb.film_type,sb.name, sb.is_discounted, sb.film_name,
       sb.manufctr_code, sb.xref_mfctr_code
from shopping_basket sb, form_orders fo, form_made fm, purchase_order po, photographer ph
where fm.fsid = fo.fsid and
      fo.poid = sb.poid and
      sb.poid = po.poid and
      po.pid = ph.pid and
      po.is_b2c = 'T'
order by ph.lab_account_id,fm.fsid;
