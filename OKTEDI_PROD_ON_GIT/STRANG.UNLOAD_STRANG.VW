CREATE OR REPLACE FORCE VIEW STRANG.UNLOAD_STRANG
(DEBTOR_BRANCH, DEBTOR_CODE, INVDATE, INVOICENO, TOTAL, 
 GST, JOB_BRANCH, PROFIT_CENTRE, JOB_CODE, COST_CENTRE, 
 TRANSACTION_TYPE, INVDESC)
AS 
select i.debtor_branch,
       i.debtor_code,
       i.invdate,
       i.invoiceno,
       gl.total,
       gl.gst,
       i.job_branch,
       gl.profit_centre,
       i.job_code,
       gl.cost_centre,
       gl.transaction_type,
       i.invdesc
from strang.invoices i, strang.general_ledger gl
where i.invoiceno = gl.invoiceno and
      i.transfer_date is null and
      i.completed = 'COMPLETE' and
      i.status = 'GL COMPLETE' and
      gl.cost_centre <> 'NO COST'
order by i.invoiceno, gl.recno;


GRANT SELECT ON STRANG.UNLOAD_STRANG TO WEBSYS;
