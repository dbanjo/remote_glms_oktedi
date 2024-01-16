CREATE OR REPLACE PACKAGE WEBSYS.INVOICE_PARSER
as
g_gst_rate  number := 0.1;

function customer_state(acid in integer) return varchar2;     

procedure lov_list( lname in varchar2, parm in varchar2, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showdesc in boolean DEFAULT TRUE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null );
 
procedure invoice_mng(surl in varchar2, vtyp varchar2 default 'INVOICE', msg in varchar2 default null, batchno number default null);

--procedure invoice_mng_accept(surl in varchar2, vtyp varchar2, infile owa.vc_arr, action varchar2, batchno number default null, recItm varchar2 default null, p1 varchar2 default null, p2 varchar2 default null ); 
procedure invoice_mng_accept(surl in varchar2, vtyp varchar2, infile in owa.vc_arr default glbx.empty_array
                              , action varchar2, batchno number default null
                              , rid in owa.vc_arr default glbx.empty_array
                              , recItm in owa.vc_arr default glbx.empty_array
                              , priceItm in owa.vc_arr default glbx.empty_array
                              , p1 in owa.vc_arr default glbx.empty_array, p2 in owa.vc_arr default glbx.empty_array 
                              , p3 in owa.vc_arr default glbx.empty_array, p4 in owa.vc_arr default glbx.empty_array
                              , p5 in varchar2 default null      
                              , p6 in varchar2 default null 
                              , p7 in varchar2 default null
                              , p8 in varchar2 default null   
                              , p9 in owa.vc_arr default glbx.empty_array
                              , p10 in owa.vc_arr default glbx.empty_array
                              , p11 in owa.vc_arr default glbx.empty_array   
                              , p12 in varchar2 default null     
                              , p13 in varchar2 default null 
                              , p14 in varchar2 default null 
                              , p15 in varchar2 default null   
                              , p16 in owa.vc_arr default glbx.empty_array 
                              , p17 in owa.vc_arr default glbx.empty_array    
                              , p18 in owa.vc_arr default glbx.empty_array  
                              , p19 in varchar2 default null  
                              , p20 in varchar2 default null                                    
                              );

PROCEDURE parse_invoice (vfile in varchar2 default null, batchno in out number, msg in out varchar2, p_identifier in varchar2 default null);

PROCEDURE po_pool_list2( po_number in varchar2, po_item in varchar2 default null, batchno number default null,  parm in varchar2 default null,  p_unit_price number
                       , ismand in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE );

end INVOICE_PARSER;
/
