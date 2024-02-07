CREATE OR REPLACE package STX1.strangw
as -- version 1.0

  procedure main( p_path in varchar2 default null, MODOWA$CONTENT_BODY in varchar2 default null, MODOWA$REST_PATH in varchar2 default null);
  procedure batch_pos( vkey in varchar2 );
  function interface2(vpk1 in varchar2, vpk2 in varchar2, ud1 in varchar2 default null, ud2 in varchar2 default null, ud3 in varchar2 default null, ud4 in varchar2 default null, ud5 in varchar2 default null, vtest in char default 'F', vtestinfo in varchar2 default null) return boolean;
  function push_to_strang(vld in integer) return boolean;
  function push_cust_strang(vld in integer) return boolean;
  function push_material_strang(vld in integer) return boolean;
  procedure batch_interface_2( v_command in varchar2 );
  procedure batch_interface_4( v_command in varchar2 );
  function interface4(ud1 in varchar2 default null, ud2 in varchar2 default null, ud3 in varchar2 default null, ud4 in varchar2 default null, ud5 in varchar2 default null, vtest in char default 'F', vtestinfo in varchar2 default null) return boolean;

end strangw;
/
