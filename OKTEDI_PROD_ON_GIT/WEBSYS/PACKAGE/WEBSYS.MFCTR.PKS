CREATE OR REPLACE package WEBSYS.mfctr
as

 procedure accept_logon( un in varchar2, pw in varchar2 );
 procedure available_categories( surl in varchar2, aid in integer );
 procedure images_in_category( surl in varchar2, aid in integer, category_id in integer );
 procedure photo_album( surl in varchar2, aid in integer );
 procedure photo_album_details( surl in varchar2, aid in integer, album_id in integer );
 procedure update_photo_album_details( surl in varchar2, aid in integer, album_id in integer, fname in varchar2 );

end mfctr;

/
