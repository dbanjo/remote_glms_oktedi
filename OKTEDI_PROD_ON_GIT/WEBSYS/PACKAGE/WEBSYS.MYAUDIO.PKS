CREATE OR REPLACE package WEBSYS.myaudio
as

 function audio_api( v_filename varchar2 ) return char;
 procedure audio_api(v_umo integer, attrib_id integer, data_value varchar2, acid integer, posid integer, action varchar2 );
 procedure audio_api(v_umo integer, new_acid integer,old_acid integer, action varchar2 );
 procedure audio_api(v_umo integer, schemaname varchar2, howloaded varchar2, action varchar2 );
 procedure audio_api(surl in varchar2, umo_rec in integer, theme_data in CHAR, left_api_parm in VARCHAR2, current_page_number in integer, display_detail in varchar2, footer_api in varchar2, ltype in varchar2, acid in integer );
 procedure audio_api(v_umo integer, ltype varchar2, left_api varchar2,left_api_parm varchar2, footer_api varchar2);
 procedure audio_api(origfile in varchar2, filetype out varchar2, mimetype out varchar2 );
 function audio_api(surl in varchar2, phgid in integer, acid in integer, v_umo integer, vload_id integer, action varchar2) return boolean;
 procedure play_audio(surl in varchar2, v_umo in integer, acid in integer, image_type in varchar2);
 procedure embed_tag(surl in varchar2, v_umo in integer, acid in integer, image_type in varchar2 );

end myaudio;

/
