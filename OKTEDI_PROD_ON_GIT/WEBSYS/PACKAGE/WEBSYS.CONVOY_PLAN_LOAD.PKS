CREATE OR REPLACE package WEBSYS.convoy_plan_load
as
g_gst_rate  number := 0.1;
function customer_state(acid in integer) return varchar2;     
procedure lov_list( lname in varchar2, parm in varchar2, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showdesc in boolean DEFAULT TRUE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null );
procedure convoy_plan_mng(surl in varchar2, vtyp varchar2 default 'CONVOY_PLAN', msg in varchar2 default null, batchno number default null);
procedure convoy_plan_mng_accept(surl in varchar2, vtyp varchar2, infile in owa.vc_arr default glbx.empty_array
                               , action varchar2, batchno number default null
                               , p12 in varchar2 default null                             
                              );

end CONVOY_PLAN_LOAD;
/
