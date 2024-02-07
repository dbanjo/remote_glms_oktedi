CREATE OR REPLACE package WEBSYS.ord
as

 TYPE myarray 	IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
 TYPE listint 	IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;

function sbitemtotal(shpid in integer , vpoid in integer) return varchar2;
--
-- Kept for Backwards Compatibility - Hardcoded into Secure Pages
--
procedure accept_pay_by_credit( surl varchar2,CreditCardNumber in varchar2 default null, CreditCardType in varchar2 default null, ExpirationYear in varchar2 default null, ExpirationMonth in varchar2 default null, ExpirationDay in varchar2 default null, cc4 in varchar2 default null, HomeURL in varchar2 default null );
procedure accept_merchant_safepay(SESSIONID in varchar2, MERCHANTID in varchar2, PURCHASEAMOUNT in varchar2, LOCALE in varchar2, RECEIPTNO in varchar2, TRANSACTIONNO in varchar2, ACQRESPONSECODE in varchar2, QSIRESPONSECODE in varchar2 );


procedure workflow_order( surl in varchar2, acid in integer, ws in integer default null, wspd in integer default null );
procedure modify_order( surl varchar2,acid in integer, purchord in integer, msg in varchar2 default null, prnt_type in varchar2 default 'STANDARD', typ in varchar2 );
procedure accept_modify_order(surl varchar2,parm1 in MYARRAY, parm2 in MYARRAY, p1 in MYARRAY, p2 in MYARRAY, rm in MYARRAY, action in varchar2, sts in varchar2, pr in varchar2 default 'F', typ in varchar2 );
procedure gallery_order( surl varchar2, v_umo in integer, gc in varchar2, acid in integer );
procedure accept_labs_edit( surl varchar2, vpoid in integer, p1b in varchar2, p2 in varchar2, p4 in varchar2, p4x in varchar2, p4y in varchar2, action in varchar2 );

procedure phg_acct_orders( surl in varchar2, acid in integer, typ in varchar2, comma_delim in varchar2 default null, tm in char default 'L' );
procedure labs(surl varchar2,archived in varchar2 default null, phgid in integer default null, acid in integer default null);
procedure labs_edit( surl varchar2, vpoid in integer, msg in varchar2 default null );
--procedure phg_rep( surl varchar2,acid in integer, repid in integer );
procedure phg_ord_prefs( surl varchar2,acid in integer, msg in varchar2 default null, tm in char default 'D' );
procedure phg_search(surl varchar2,acid in integer, p1 in varchar2, p2 in varchar2 default null, p3 in varchar2, p4 in varchar2);
procedure audit_trail( surl in varchar2, acid in integer, purchord in integer );
--procedure list_orders_placed(surl varchar2, acid integer, nSortOn in integer, download in char default 'F');
procedure display_order_subtotal( surl in varchar2, ltype in varchar2, purchrec in purchase_order%ROWTYPE, options in GLBX.MYARRAY );
procedure display_order_details(surl in varchar2, ltype in varchar2, purchrec in purchase_order%ROWTYPE, options in GLBX.MYARRAY );

end ord;

/
