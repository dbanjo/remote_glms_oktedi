CREATE OR REPLACE package body WEBSYS.mfctr
as

 procedure accept_logon( un in varchar2, pw in varchar2 )
 as

 cursor c1( phgid integer ) is select * from customer_account where pid = phgid order by account_name;

 sts		varchar2(1000);
 surl		varchar2(100);
 session_id	integer;
 stype		integer;
 ltype		varchar2(100);
 owner_id	integer;

 begin

  glbx.logon_user( upper(un), upper(pw), sts, session_id, stype, null, null, 'F', null, surl );
  if sts = 'PHOTOGRAPHER'
   then
    sts := NULL;
    glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MFCTR.ACCEPT_LOGON', iscust=>FALSE );
    if sts is not null
     then
      htp.p( '<ERROR>' || sts || '</ERROR>' );
      return;
    end if;
   else
    htp.p( '<ERROR>NOT A PHOTOGRAPHER ACCOUNT</ERROR>' );
    return;
  end if;
  for c1rec in c1(owner_id) loop
   htp.p( '<CUSTOMER_ACCOUNT>' );
    htp.p( '<ACCOUNT_NAME>' || c1rec.account_name || '</ACCOUNT_NAME>' );
    htp.p( '<AID>' || c1rec.aid || '</AID>' );
    htp.p( '<USERNAME>' || c1rec.username || '</USERNAME>' );
   htp.p( '</CUSTOMER_ACCOUNT>' );
  end loop;
 exception
  when others
   then
      htp.p( '<ERROR>' || sqlerrm || '</ERROR>' );
      return;
 end accept_logon;

 procedure available_categories( surl in varchar2, aid in integer )
 as

 cursor c1( accid integer) is select umo_scene_id,um.extras.title title,count('x') tot from umo um where aid=accid and umo_type = 'PHOTO' group by umo_scene_id,um.extras.title;

 sts		varchar2(1000);
 stype		integer;
 ltype		varchar2(100);
 owner_id	integer;

 begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MFCTR.AVAILABLE_CATEGORIES', iscust=>FALSE );
 if sts is not null
  then
     htp.p( '<ERROR>' || sts || '</ERROR>' );
     return;
 end if;

 for c1rec in c1(aid) loop
  htp.p( '<CATEGORY>' );
   htp.p( '<TITLE>' || c1rec.title || '</TITLE>' );
   htp.p( '<CATEGORY_ID>' || c1rec.umo_scene_id || '</CATEGORY_ID>' );
   htp.p( '<IMAGES>' || c1rec.tot || '</IMAGES>' );
  htp.p( '</CATEGORY>' );
 end loop;

 exception
  when others
   then
      htp.p( '<ERROR>' || sqlerrm || '</ERROR>' );
      return;
 end available_categories;

 procedure images_in_category( surl in varchar2, aid in integer, category_id in integer )
 as

 cursor c1(accid integer, category_id integer) is
  select umo_id,um.photo_thumbnail.contentlength tsize, um.photo_master.contentlength msize, um.extras.film_name film_name
  from umo um
  where aid = accid and
        umo_scene_id = category_id and
        umo_type = 'PHOTO'
  order by umo_id;

 sts		varchar2(1000);
 stype		integer;
 ltype		varchar2(100);
 owner_id	integer;

 begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MFCTR.IMAGES_IN_CATEGORY', iscust=>FALSE );
 if sts is not null
  then
     htp.p( '<ERROR>' || sts || '</ERROR>' );
     return;
 end if;

 for c1rec in c1(aid,category_id) loop
  htp.p( '<IMAGE>' );
   htp.p( '<UMO_ID>' || c1rec.umo_id || '</UMO_ID>' );
   htp.p( '<THUMBNAIL_SIZE>' || c1rec.tsize || '</THUMBNAIL_SIZE>' );
   htp.p( '<MASTER_SIZE>' || c1rec.tsize || '</MASTER_SIZE>' );
   htp.p( '<NAME>' || c1rec.film_name || '</NAME>' );
  htp.p( '</IMAGE>' );
 end loop;

 exception
  when others
   then
      htp.p( '<ERROR>' || sqlerrm || '</ERROR>' );
      return;
 end images_in_category;

 procedure photo_album( surl in varchar2, aid in integer )
 as

 cursor c1(accid integer) is select * from album where aid = accid and album_name is not null order by album_id;
 cursor c2 is select max(album_id) tot from album;

 sts		varchar2(1000);
 stype		integer;
 ltype		varchar2(100);
 owner_id	integer;
 acid		integer;
 tot		integer;

 begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MFCTR.PHOTO_ALBUM', iscust=>FALSE );
 if sts is not null
  then
     htp.p( '<ERROR>' || sts || '</ERROR>' );
     return;
 end if;

 acid := aid;
 delete from album a where a.aid = acid and album_name is null;
 for c1rec in c1(acid) loop
  htp.p( '<ALBUM>' );
   htp.p( '<ALBUM_NAME>' || c1rec.album_name || '</ALBUM_NAME>' );
   htp.p( '<ALBUM_ID>' || c1rec.album_id || '</ALBUM_ID>' );
   htp.p( '<VERSION>' || c1rec.version || '<VERSION>' );
   htp.p( '<ALBUM_TYPE>' || c1rec.album_type || '</ALBUM_TYPE>' );
   htp.p( '<ALBUM_SHAPE>' || c1rec.album_shape || '</ALBUM_SHAPE>' );
   htp.p( '<ALBUM_COVER>' || c1rec.album_cover || '</ALBUM_COVER>' );
  htp.p( '</ALBUM>' );
 end loop;
 open c2;
 fetch c2 into tot;
 close c2;
 tot := nvl(tot,0) + 1;
 insert into album(aid,album_id,album_name,date_created,date_updated,manufacturer_id) values
                  (acid,tot,null,sysdate,sysdate,null);
 commit;
 -- Default New Album
 htp.p( '<ALBUM>' );
  htp.p( '<ALBUM_NAME></ALBUM_NAME>' );
  htp.p( '<ALBUM_ID>' || tot || '</ALBUM_ID>' );
  htp.p( '<VERSION><VERSION>' );
  htp.p( '<ALBUM_TYPE></ALBUM_TYPE>' );
  htp.p( '<ALBUM_SHAPE></ALBUM_SHAPE>' );
  htp.p( '<ALBUM_COVER></ALBUM_COVER>' );
 htp.p( '</ALBUM>' );

 exception
  when others
   then
      htp.p( '<ERROR>' || sqlerrm || '</ERROR>' );
      return;
 end photo_album;

 procedure photo_album_details( surl in varchar2, aid in integer, album_id in integer )
 as

 cursor c1(accid integer, albid integer) is
  select *
  from album_details
  where album_id = albid and
        album_id in (select album_id from album where aid = accid)
  order by page_number;

 sts		varchar2(1000);
 stype		integer;
 ltype		varchar2(100);
 owner_id	integer;

 begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MFCTR.PHOTO_ALBUM_DETAILS', iscust=>FALSE );
 if sts is not null
  then
     htp.p( '<ERROR>' || sts || '</ERROR>' );
     return;
 end if;

 for c1rec in c1(aid,album_id) loop
  htp.p( '<PAGE>' );
   htp.p( '<PAGE_NUMBER>' || c1rec.page_number || '</PAGE_NUMBER>' );
   htp.p( '<PAGE_TEMPLATE>' || c1rec.page_template || '</PAGE_TEMPLATE>' );
   htp.p( '<UMO_ID_IMAGE_1>' || c1rec.umo_id_image_1 || '</UMO_ID_IMAGE_1' );
   htp.p( '<UMO_ID_IMAGE_1_XCOORD>' || c1rec.umo_id_image_1_xcoord || '</UMO_ID_IMAGE_1_XCOORD' );
   htp.p( '<UMO_ID_IMAGE_1_YCCORD>' || c1rec.umo_id_image_1_ycoord || '</UMO_ID_IMAGE_1_YCOORD' );
   htp.p( '<UMO_ID_IMAGE_2>' || c1rec.umo_id_image_2 || '</UMO_ID_IMAGE_2' );
   htp.p( '<UMO_ID_IMAGE_2_XCOORD>' || c1rec.umo_id_image_2_xcoord || '</UMO_ID_IMAGE_2_XCOORD' );
   htp.p( '<UMO_ID_IMAGE_2_YCCORD>' || c1rec.umo_id_image_2_ycoord || '</UMO_ID_IMAGE_2_YCOORD' );
   htp.p( '<UMO_ID_IMAGE_3>' || c1rec.umo_id_image_3 || '</UMO_ID_IMAGE_3' );
   htp.p( '<UMO_ID_IMAGE_3_XCOORD>' || c1rec.umo_id_image_3_xcoord || '</UMO_ID_IMAGE_3_XCOORD' );
   htp.p( '<UMO_ID_IMAGE_3_YCCORD>' || c1rec.umo_id_image_3_ycoord || '</UMO_ID_IMAGE_3_YCOORD' );
   htp.p( '<UMO_ID_IMAGE_4>' || c1rec.umo_id_image_4 || '</UMO_ID_IMAGE_4' );
   htp.p( '<UMO_ID_IMAGE_4_XCOORD>' || c1rec.umo_id_image_4_xcoord || '</UMO_ID_IMAGE_4_XCOORD' );
   htp.p( '<UMO_ID_IMAGE_4_YCCORD>' || c1rec.umo_id_image_4_ycoord || '</UMO_ID_IMAGE_4_YCOORD' );
  htp.p( '</PAGE>' );
 end loop;

 exception
  when others
   then
      htp.p( '<ERROR>' || sqlerrm || '</ERROR>' );
      return;
 end photo_album_details;

 procedure update_photo_album_details( surl in varchar2, aid in integer, album_id in integer, fname in varchar2 )
 as

 sts		varchar2(1000);
 stype		integer;
 ltype		varchar2(100);
 owner_id	integer;
 status		varchar2(100);
 albid		integer;

 begin

 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MFCTR.UPDATE_PHOTO_ALBUM_DETAILS', iscust=>FALSE );
 if sts is not null
  then
     htp.p( '<ERROR>' || sts || '</ERROR>' );
     return;
 end if;

 albid := album_id;
 htp.p( '<STATUS>' || status || '</STATUS>' );

 update album a set date_updated = sysdate where a.album_id = albid;
 commit;

 exception
  when others
   then
      htp.p( '<ERROR>' || sqlerrm || '</ERROR>' );
      return;
 end update_photo_album_details;


end mfctr;

/
