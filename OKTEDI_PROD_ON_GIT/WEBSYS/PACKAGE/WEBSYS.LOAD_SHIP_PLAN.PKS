CREATE OR REPLACE PACKAGE WEBSYS.LOAD_SHIP_PLAN
as
g_gst_rate  number := 0.1;

function customer_state(acid in integer) return varchar2;     
procedure lov_list( lname in varchar2, parm in varchar2, cd in varchar2 default null, ismand in boolean DEFAULT FALSE, showdesc in boolean DEFAULT TRUE, showcola in boolean DEFAULT FALSE, isedit in boolean DEFAULT TRUE, xtr_a in varchar2 default null, xtr_b in varchar2 default null );
procedure LOCAL_SHIP_PLAN_MNG(surl in varchar2, vtyp varchar2 default 'LOAD_SHIP_PLAN', action in varchar2, msg in varchar2 default null, batchno number default null);
procedure local_ship_plan_accept(surl in varchar2, vtyp varchar2, infile in owa.vc_arr default glbx.empty_array
                               , action varchar2, batchno number default null
                               , p12 in varchar2 default null);
--procedure ingest_ships_excel_file (msg in varchar2 default null);

--procedure accept_ingest_ships_file(infile varchar2, action varchar2, batchno out number);
 procedure accept_ingest_ships_file(infile varchar2, action varchar2, batchno out number, p_msg out varchar2 );
end LOAD_SHIP_PLAN;
/
