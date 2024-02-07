CREATE OR REPLACE package body WEBSYS.pfm
as

function  get_theme_types( surl in varchar2, acid in integer, ltype in varchar2 default null) return theme_types%ROWTYPE;
procedure disp_colours(p1 in varchar2, p2 in varchar2, p3 in varchar2, pfx in theme%ROWTYPE, cellonly in boolean default FALSE );
procedure pos_loop( posint integer );
function findparm( val in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY ) return varchar2;
function findparm3( val in varchar2, p3 in GLBX.MYARRAY ) return varchar2;

function  get_theme_types( surl in varchar2, acid in integer, ltype in varchar2 default null)
 return theme_types%ROWTYPE
as
 cursor c1(acid integer) is select * from theme_types tt where theme_type in (select theme_type from customer_account where aid=acid);
 cursor c2(phgid integer) is select * from theme_types tt where theme_type in (select theme_type from photographer where pid=phgid);
 c1rec  c1%ROWTYPE;
begin
 if ltype is null
  then
   open c1(acid);
   fetch c1 into c1rec;
   close c1;
   return( c1rec );
  else
   open c2(acid);
   fetch c2 into c1rec;
   close c2;
   return( c1rec );
 end if;
exception when others then
 glbx.error_details( 'PHG', 'GET_THEME_TYPES',errmsg=>sqlerrm,extdet=>'ACID:' || acid);
end get_theme_types;

procedure main( surl in varchar2, acid in integer, msg in varchar2 default null )
as

 cursor c1(phgid integer, acid integer) is select * from phg_batch_upload where pid = phgid and aid = acid;
 cursor c2(acid integer) is select count('x') tot from load_log where aid = acid;
 cursor c3(uscid integer) is select title from umo_scene where umo_scene_id = uscid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 uscid		integer;
 ctr		integer;
 x		integer;
 lastx		integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

 function findparm( vload_id integer, p1 in varchar2 )
  return varchar2
 as
  cursor c1(vload_id integer, p1 varchar2 ) is select parm2 from phg_batch_upload_parms where load_id = vload_id and parm1 = p1;
  c1rec	 c1%ROWTYPE;
 begin
  open c1(vload_id, p1);
  fetch c1 into c1rec;
  close c1;
  return( c1rec.parm2 );
 end findparm;

 function findparm3( vload_id integer, p1 in varchar2 )
  return varchar2
 as
  cursor c1(vload_id integer, p1 varchar2 ) is select 'T' vl from phg_batch_upload_parms where load_id = vload_id and parm3 = p1;
  c1rec	 c1%ROWTYPE;
 begin
  open c1(vload_id, p1);
  fetch c1 into c1rec;
  if c1%FOUND then close c1; return( 'T' ); else close c1; return( 'F' ); end if;
 end findparm3;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PFM.MAIN', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, LNG2.PFM_TXT_044,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P76',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 if msg is not null then glbx.header_msg( msg );end if;
 htp.p( '<CENTER>' );
 htp.nl;
 open c1(owner_id,acid);
 fetch c1 into c1rec;
 close c1;
 open c2(acid);
 fetch c2 into c2rec;
 close c2;

 if c1rec.aid is null
  then
   htp.anchor( 'pfm.ftp_upload?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, LNG2.PFM_TXT_045 );
   htp.nl;
  else
   htp.nl;
   htp.bold( LNG2.PFM_TXT_058 );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( LNG2.PFM_TXT_050, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold(to_char( c1rec.date_submitted,LNG.TSMASK)), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG2.PFM_TXT_051, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( findparm( c1rec.load_id, '[1]FILE' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    if findparm3( c1rec.load_id, '[1]INCLUDE_SUBDIR' ) = 'T'
     then
      htp.tablerowopen;
       htp.tabledata( LNG5.EXT_TXT_130, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.bold( LNG.PHG_TXT_045 ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
    else
      htp.tablerowopen;
       htp.tabledata( LNG5.EXT_TXT_130, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.bold( LNG.PHG_TXT_046 ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
    end if;

    if substr(theme_rec.theme_data,92,1) = 'T'
     then
      if findparm3( c1rec.load_id, '[1]AUTO_CREATE' ) = 'T'
       then
        htp.tablerowopen;
         htp.tabledata( LNG5.EXT_TXT_452, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         htp.tabledata( htf.bold( LNG.PHG_TXT_045 ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        htp.tablerowclose;
      else
        htp.tablerowopen;
         htp.tabledata( LNG5.EXT_TXT_452, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
         htp.tabledata( htf.bold( LNG.PHG_TXT_046 ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
        htp.tablerowclose;
      end if;
    end if;

    htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_217, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( findparm( c1rec.load_id, 'COMPRESSION' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG3.ADM_TXT_332, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.bold( findparm( c1rec.load_id, 'THUMBNAIL_QUALITY' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    for j in 1..20 loop
     uscid := findparm( c1rec.load_id, '[' || to_char(j) || ']' || 'CATEGORY' );
     if uscid is not null
      then
       open c3(uscid);
       fetch c3 into c3rec;
       close c3;
       htp.tablerowopen;
        htp.tabledata( LNG2.PFM_TXT_052, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
        htp.tabledata( htf.bold( c3rec.title ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
       htp.tablerowclose;
     end if;
    end loop;
   htp.tablerowopen;
    htp.tabledata( LNG.PHG_ALT_394, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( findparm( c1rec.load_id, 'FILM_ROLL' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( LNG2.PFM_TXT_059, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
    htp.tabledata( htf.bold( c1rec.status ), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
   htp.tablerowclose;
   htp.tableclose;
   htp.nl;
   htp.nl;
   htp.anchor( 'pfm.ftp_upload?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, LNG2.PFM_TXT_048 );
   htp.nl;
 end if;

 htp.nl;

 if c2rec.tot = 0
  then
   htp.bold( LNG2.PFM_TXT_046 );
   htp.nl;
  else
   htp.anchor2( 'glbx.displog?surl=' || glbx.rndsurl(surl) || '&acid=' || acid || '&acc=PHOTOGRAPHER', LNG2.PFM_TXT_047, ctarget=>'LOG_WINDOW' );
   htp.nl;
 end if;

 htp.nl;
 htp.nl;
 -- Functionality Desupported
 -- htp.anchor( 'pfm.phg_prefs_pfr?surl=' || glbx.rndsurl(surl) || '&acid=' || acid, LNG.PHG_ALT_331 );
 htp.nl;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PFM', 'MAIN',owner_id,vaid=>acid,errmsg=>sqlerrm);
end main;

procedure ftp_upload( surl in varchar2, acid in integer, msg in varchar2 default null, p1 in varchar2 default null, p2 in varchar2 default null, p3 in varchar2 default null, p4 in varchar2 default null, p5 in varchar2 default null, p6 in varchar2 default null)
as
 cursor c1(phgid integer,acid integer) is select aid,account_name,theme_type,scene_name from customer_account where pid=phgid and aid=acid;
 cursor c6(phgid integer, scnm varchar2, acid integer) is
 	 select order_by,title,umo_scene_id,parent_scene
	 from umo_scene usc
	 where category = scnm and
	       ((owned_by = 'PUBLIC') or ((owned_by = 'PHOTOGRAPHER') and (owner_id = phgid)))
	 order by order_by;
 cursor c9(ttype varchar2) is select film_type from film_types where theme_type = ttype;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 thmb_qual	varchar2(100);
 tmp		varchar2(32767);
 pfx		THEME%ROWTYPE;
 theme_rec	theme_types%ROWTYPE;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PFM.FTP_UPLOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 pfx := glbx.get_thm( acid );
 theme_rec := get_theme_types( surl,acid );
 glbx.main_title( surl, LNG2.PFM_TXT_054,glbx.backimg(surl,acid,pfx.text_back,null,ltype),helpid=>'P64',stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);

 -- If the Job Already exists in the queue then delete it.
 delete from phg_batch_upload where pid = owner_id and aid = acid;
 commit;

 open c1(owner_id,acid);
 fetch c1 into c1rec;
 close c1;
 if msg is not null then glbx.header_msg( msg );end if;
 htp.nl;
 htp.p( '<CENTER>' );
 htp.formopen( 'pfm.accept_ftp_load' );
  htp.formhidden( 'SURL', glbx.rndsurl(surl));
  htp.formhidden( 'ACID', acid );
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=1' );
     htp.tablerowopen;
      htp.tabledata( LNG2.PFM_TXT_051, cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"' );
      htp.p( '<TD ' || pfx.qcbground || ' valign="TOP" align="LEFT">' );
       for j in 1..10 loop
        htp.formtext( 'P1', 50, 1000, p1 );
        htp.nl;
        htp.nl;
       end loop;
       htp.p(LNG2.FNM_TXT_141);
      htp.p( '</TD>' );
      htp.p( '<TD ' || pfx.qcbground || ' valign="TOP" align="LEFT">' );
       for j in 1..10 loop
        htp.formselectopen( 'P4' );
        for c6rec in c6(owner_id,c1rec.scene_name,acid) loop
         if c6rec.umo_scene_id = P4
          then
           htp.formselectoption( lpad('.', glbx.indnt(c6rec.parent_scene),'.') || c6rec.title, cattributes=>'VALUE="' || c6rec.umo_scene_id || '"',cselected=>'SELECTED' );
          else
           htp.formselectoption( lpad('.', glbx.indnt(c6rec.parent_scene),'.') || c6rec.title, cattributes=>'VALUE="' || c6rec.umo_scene_id || '"' );
         end if;
        end loop;
        htp.formselectclose;
        htp.nl;
       end loop;
      htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG5.EXT_TXT_130, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formcheckbox( 'P7', 'T'), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;

    if substr(theme_rec.theme_data,92,1) = 'T'
     then
      htp.tablerowopen;
       htp.tabledata( LNG5.EXT_TXT_452, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
       htp.tabledata( htf.formcheckbox( 'P8', 'T'), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
       htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
      htp.tablerowclose;
    end if;

    htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_217, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     if p2 = 'L' then tmp :=  LNG3.ADM_TXT_691 || ' ' || htf.formradio( 'P2', 'L', 'CHECKED' ) || ' '; else tmp :=  LNG3.ADM_TXT_691 || ' ' || htf.formradio( 'P2', 'L' ) || ' '; end if;
     if p2 = 'M' then tmp :=  tmp || LNG3.ADM_TXT_692 || ' ' || htf.formradio( 'P2', 'M', 'CHECKED' ) || ' '; else tmp :=  tmp || LNG3.ADM_TXT_692 || ' ' || htf.formradio( 'P2', 'M' ) || ' '; end if;
     if p2 = 'H' then tmp :=  tmp || LNG3.ADM_TXT_693 || ' ' || htf.formradio( 'P2', 'H', 'CHECKED' ) || ' '; else tmp :=  tmp || LNG3.ADM_TXT_693 || ' ' || htf.formradio( 'P2', 'H' ) || ' '; end if;
     if (p2 = LNG.PHG_ALT_427) or (p2 is null) then tmp :=  tmp || LNG.PHG_ALT_427  || ' ' || htf.formradio( 'P2', LNG.PHG_ALT_427 , 'CHECKED' ); else tmp :=  tmp || LNG.PHG_ALT_427  || ' ' || htf.formradio( 'P2', LNG.PHG_ALT_427  ); end if;
     htp.tabledata( tmp, cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG3.ADM_TXT_332, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
      thmb_qual := nvl(glbx.userpref( owner_id, acid, 'SUPER_THB' ),'1');
      /*
      tmp := htf.formselectopen( 'P3' );
      for j in 1..8 loop
       if to_char(j) = nvl(p3,thmb_qual)
        then
         tmp := tmp || htf.formselectoption( to_char(j), 'SELECTED' );
        else
         tmp := tmp || htf.formselectoption( to_char(j) );
       end if;
      end loop;
      tmp := tmp || htf.formselectclose;
      */
     htp.tabledata( glbx.quality_loop( 'P3', thmb_qual), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG.PHG_TXT_356, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
	  tmp := htf.formselectopen( 'P5' ) || htf.formselectoption( LNG.ORD_TXT_194 );
	  for c9rec in c9( c1rec.theme_type ) loop
	   if c9rec.film_type = P5
	    then
	     tmp := tmp || htf.formselectoption( c9rec.film_type, 'SELECTED' );
	    else
	     tmp := tmp || htf.formselectoption( c9rec.film_type );
	   end if;
	  end loop;
	  tmp := tmp || htf.formselectclose;
      htp.tabledata(tmp,cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"');
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( LNG.PHG_ALT_394, cattributes=>pfx.qbground || 'valign="MIDDLE" align="LEFT"' );
     htp.tabledata( htf.formtext( 'P6', 10, 20, nvl(p6,LNG2.FNM_TXT_004)), cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
     htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || ' valign="MIDDLE" align="LEFT"' );
    htp.tablerowclose;
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, LNG2.PFM_TXT_055 );
 htp.formclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PFM', 'FTP_UPLOAD',owner_id,vaid=>acid,errmsg=>sqlerrm);
end ftp_upload;

procedure accept_ftp_load( surl in varchar2, acid in integer, p1 in GLBX.MYARRAY, p2 in varchar2, p3 in varchar2, p4 in GLBX.MYARRAY, p5 in varchar2, p6 in varchar2, p7 in char default 'F', p8 in char default NULL )
as

 cursor c1(phgid integer) is select * from photographer where pid = phgid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 vlid		integer;
 id		integer;
 dr1		varchar2(1000);
 dr2		varchar2(1000);
 sts		varchar2(100);
 ftp_dir	varchar2(2000);
 pfx		THEME%ROWTYPE;
 fl	        UTL_FILE.FILE_TYPE;
 ctr		integer;
 frec		boolean;

begin
 glbx.cookie_id( surl,stype, ltype, owner_id, sts, progcalled=>'PFM.FTP_UPLOAD', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1(owner_id);
 fetch c1 into c1rec;
 close c1;

-- dr1 := glbx.get_dir(c1rec.ftp_load_dir || ftp_dir,'DIRECTORY');
-- dr2 := glbx.get_dir(c1rec.ftp_load_dir || ftp_dir,'SUBDIRECTORY');

 -- Add Job to Queue
-- delete from phg_batch_upload where pid = owner_id and aid = acid;
-- insert into phg_batch_upload(pid,aid,date_submitted,ftp_dir,compr_qual,thmb_qual,umo_scene_id,film_type,film_roll,status,incl_subdirs,create_subdir) values
--  (owner_id,acid,sysdate,np2,p2,p3,np12,p5,p6,LNG2.PFM_TXT_060,p7,p8);

 select s_phg_batch_upload.nextval into vlid from dual;

 insert into phg_batch_upload(load_id, pid, aid, load_type, usr_type, date_submitted, status ) values
  (vlid, owner_id, acid, 'LOAD', 'CUSTOMER', sysdate, 'SUBMITTED' );

 if c1rec.ftp_load_dir is null then main(surl,acid,'Command Centre Load Directory has not been configured.'); return; end if;

 ctr := 0;
 frec := FALSE;
 for j in p1.first..p1.last loop
  if p1(j) is not null
  then
   ftp_dir := p1(j);
   if substr(ftp_dir,length(ftp_dir),1) = DECS.UNIX_OR_NT
    then
     ftp_dir := ftp_dir || '*.*';
   end if;

   if substr(ftp_dir,1,1) = DECS.UNIX_OR_NT
    then
     ftp_dir := substr(ftp_dir,2);
   end if;
   ftp_dir := c1rec.ftp_load_dir || ftp_dir;
   ftp_dir := replace(replace(ftp_dir,'//','/'),'\\','\');

   if ftp_dir is not null
    then
     ctr := ctr + 1;
     frec := true;
     insert into phg_batch_upload_parms(load_id,parm1,parm2) values (vlid, '[' || ctr || ']FILE', ftp_dir );
     insert into phg_batch_upload_parms(load_id,parm1,parm2) values (vlid, '[' || ctr || ']CATEGORY', p4(j) );
     if p7 = 'T' then insert into phg_batch_upload_parms(load_id,parm3) values (vlid, '[' || ctr || ']INCLUDE_SUBDIR' ); end if;
     if p8 = 'T' then insert into phg_batch_upload_parms(load_id,parm3) values (vlid, '[' || ctr || ']AUTO_CREATE' ); end if;
   end if;
  end if;
 end loop;

 insert into phg_batch_upload_parms(load_id,parm1,parm2) values (vlid, 'COMPRESSION', p2 );
 insert into phg_batch_upload_parms(load_id,parm1,parm2) values (vlid, 'THUMBNAIL_QUALITY', p3 );
 insert into phg_batch_upload_parms(load_id,parm1,parm2) values (vlid, 'THUMBNAIL_WIDTH', nvl(glbx.photo_pref(owner_id,acid,'THUMBNAIL_WIDTH'),'100') );
 insert into phg_batch_upload_parms(load_id,parm1,parm2) values (vlid, 'FILM_ROLL', p6 );
 insert into phg_batch_upload_parms(load_id,parm1,parm2) values (vlid, 'OBJECT_TYPE', 'AUTO' );
 insert into phg_batch_upload_parms(load_id,parm3) values (vlid, 'ENABLE_ALL' );
 commit;

 if not frec
  then
   delete from phg_batch_upload where load_id = vlid;
   delete from phg_batch_upload_parms where load_id = vlid;
   commit;
   main(surl,acid,'No FTP Load Directory Specified');
   return;
 end if;

 if c1rec.ftp_run_now = 'T'
  then
   dbms_job.submit(id,'adm.run_load_job(surl=>''' || glbx.encrypt_password( vlid ) || ''',vload_id=>' || vlid || ', runfrom=>''BATCH'');' );
   commit;
 end if;

 main(surl,acid,LNG2.PFM_TXT_056);

exception when others then
 glbx.error_details( 'PFM', 'ACCEPT_FTP_UPLOAD',owner_id,vaid=>acid,errmsg=>sqlerrm,extdet=>' P2:' || p2 || ' P3:' || p3 || ' P5:' || p5 || ' P6:' || p6 );
end accept_ftp_load;

procedure purchrep( surl in varchar2, msg in varchar2 default null, template in varchar2 default null )
as

 cursor c1( phgid integer ) is select aid,username,account_name from customer_account where pid = phgid order by account_name;
 cursor c2 is select pid,username,business_name from photographer order by business_name;
 cursor c3( manid integer ) is select p.pid,p.username,p.business_name from photographer p, manufacturer_photographer mp where mp.manufacturer_id = manid and mp.pid = p.pid order by business_name;
 cursor c1t( phgid integer ) is select count('x') tot from customer_account where pid = phgid order by account_name;
 cursor c2t is select count('x') tot from photographer order by business_name;
 cursor c3t( manid integer ) is select count('x') tot from photographer p, manufacturer_photographer mp where mp.manufacturer_id = manid and mp.pid = p.pid order by business_name;
 cursor c4 is select clr_hex, clr_name from colours order by clr_name;
 cursor c5 is select manufacturer_id, name, username from manufacturer order by name;
 cursor c6( phgid integer ) is select m.name, m.manufacturer_id from manufacturer_photographer mp, manufacturer m where pid = phgid and mp.manufacturer_id = m.manufacturer_id order by m.name;
 cursor c7 is select order_option from workflow_state_options where work_state = 0 order by order_by;
 cursor c8 is select font_name from fonts order by font_name;
 cursor c9( ltype varchar2, lid integer ) is select distinct prt_id, prt_name from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0);
 cursor c10( tempid integer, ltype varchar2, lid integer ) is select distinct prt_name from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and prt_id = tempid;

 c10rec		c10%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 foundrec	boolean;
 highrec	boolean;
 vtot		integer;
 sts		varchar2(100);
 brk		varchar2(10000);
 pfx		THEME%ROWTYPE;

 function extr1( tmp integer, ltype varchar2, lid integer, pname varchar2, pvalue varchar2, defval in boolean default FALSE )
 return boolean
 as
  cursor c1( tmp integer, ltype varchar2, lid integer, pname varchar2, pvalue varchar2 ) is select 'x' exst from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and prt_id = tmp and param_name = pname and param_value = pvalue;
  c1rec  c1%ROWTYPE;
 begin
  if tmp is null then return( defval ); end if;
  open c1(tmp, ltype, lid, pname, pvalue );
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    return( TRUE );
   else
    close c1;
    return( FALSE );
  end if;
 end extr1;

 function extr2( tmp integer, ltype varchar2, lid integer, pname varchar2, defval in varchar2 default null )
 return varchar2
 as
  cursor c1( tmp integer, ltype varchar2, lid integer, pname varchar2 ) is select param_value from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and prt_id = tmp and param_name = pname;
  c1rec  c1%ROWTYPE;
 begin
  if tmp is null then return( defval ); end if;
  open c1(tmp, ltype, lid, pname );
  fetch c1 into c1rec;
  close c1;
  return( c1rec.param_value );
 end extr2;

 function extr3( tmp integer, ltype varchar2, lid integer, pname varchar2 )
 return varchar2
 as
  cursor c1( tmp integer, ltype varchar2, lid integer, pname varchar2 ) is select param_value from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and prt_id = tmp and param_name = pname;
  c1rec  c1%ROWTYPE;
 begin
  if tmp is null then return( NULL ); end if;
  open c1(tmp, ltype, lid, pname );
  fetch c1 into c1rec;
  close c1;
  if c1rec.param_value = 'T'
   then
    return( 'CHECKED' );
   else
    return( NULL );
  end if;
 end extr3;

 function extr4( tmp integer, ltype varchar2, lid integer, pname varchar2, pvalue varchar2 )
 return varchar2
 as
  cursor c1( tmp integer, ltype varchar2, lid integer, pname varchar2, pvalue varchar2 ) is select 'x' exst from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and prt_id = tmp and param_name = pname and param_value = pvalue;
  c1rec  c1%ROWTYPE;
 begin
  if tmp is null then return( NULL ); end if;
  open c1(tmp, ltype, lid, pname, pvalue );
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    return( 'SELECTED' );
   else
    close c1;
    return( NULL );
  end if;
 end extr4;

begin
 glbx.adm_cookie_id( surl, sessid, sts, 'PFM.PURCHREP');
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.PURCHREP', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   stype := 1;
   ltype := 'ADMIN';
 end if;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, 'Purchase Order Enquiry Screen', glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P77', stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Purchase Order Enquiry Screen' );
 if msg is not null then glbx.header_msg( msg );end if;
 htp.p( '<CENTER>' );
 if template is not null
  then
   open c10(template, ltype, owner_id);
   fetch c10 into c10rec;
   close c10;
 end if;

 htp.formopen( 'pfm.accept_purchrep' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P1M', NULL );
 htp.formhidden( 'P4', NULL );
 htp.formhidden( 'P5', NULL );
 htp.formhidden( 'D1', NULL );
 htp.formhidden( 'D2', NULL );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Search for all Accounts that Match the Following Criteria'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   if ltype = 'PHOTOGRAPHER'
    then
     htp.tabledata( 'Customer Account', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( 'Client Account', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'P1', null, 5, cattributes=>'MULTIPLE' );
   if ltype = 'ADMIN'
    then
     highrec := FALSE;
     open c2t;
     fetch c2t into vtot;
     close c2t;
     if vtot = 1 then highrec := TRUE; end if;
     for c2rec in c2 loop
      if extr1( template, ltype, owner_id, 'P1', c2rec.pid ) or highrec
       then
        highrec := FALSE;
        htp.formselectoption( c2rec.business_name || ' (' || c2rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c2rec.pid || '"' );
       else
        htp.formselectoption( c2rec.business_name || ' (' || c2rec.username || ')', cattributes=>'VALUE="' || c2rec.pid || '"' );
      end if;
     end loop;
   elsif ltype = 'MANUFACTURER'
    then
     highrec := FALSE;
     open c3t(owner_id);
     fetch c3t into vtot;
     close c3t;
     if vtot = 1 then highrec := TRUE; end if;
     for c3rec in c3(owner_id) loop
      if extr1( template, ltype, owner_id, 'P1', c3rec.pid ) or highrec
       then
        highrec := FALSE;
        htp.formselectoption( c3rec.business_name || ' (' || c3rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c3rec.pid || '"' );
       else
        htp.formselectoption( c3rec.business_name || ' (' || c3rec.username || ')', cattributes=>'VALUE="' || c3rec.pid || '"' );
      end if;
     end loop;
   elsif ltype = 'PHOTOGRAPHER'
    then
     highrec := FALSE;
     open c1t(owner_id);
     fetch c1t into vtot;
     close c1t;
     if vtot = 1 then highrec := TRUE; end if;
     for c1rec in c1(owner_id) loop
      if extr1( template, ltype, owner_id, 'P1', c1rec.aid ) or highrec
       then
        highrec := FALSE;
        htp.formselectoption( c1rec.account_name || ' (' || c1rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c1rec.aid || '"' );
       else
        htp.formselectoption( c1rec.account_name || ' (' || c1rec.username || ')', cattributes=>'VALUE="' || c1rec.aid || '"' );
      end if;
     end loop;
   end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  if ltype in ('PHOTOGRAPHER','ADMIN')
   then
    htp.tablerowopen;
     htp.tabledata( 'An Item in the Basket uses Manufacturer', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
     htp.formselectopen( 'P1M', null, 5, cattributes=>'MULTIPLE' );
     if ltype = 'ADMIN'
      then
       for c5rec in c5 loop
        if extr1( template, ltype, owner_id, 'P1M', c5rec.manufacturer_id )
         then
          htp.formselectoption( c5rec.name || ' (' || c5rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c5rec.manufacturer_id || '"' );
         else
          htp.formselectoption( c5rec.name || ' (' || c5rec.username || ')', cattributes=>'VALUE="' || c5rec.manufacturer_id || '"' );
        end if;
      end loop;
     elsif ltype = 'PHOTOGRAPHER'
      then
       for c6rec in c6(owner_id) loop
        if extr1( template, ltype, owner_id, 'P1M', c6rec.manufacturer_id )
         then
          htp.formselectoption( c6rec.name, 'SELECTED', cattributes=>'VALUE="' || c6rec.manufacturer_id || '"' );
         else
          htp.formselectoption( c6rec.name, cattributes=>'VALUE="' || c6rec.manufacturer_id || '"' );
        end if;
       end loop;
     end if;
     htp.formselectclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
  end if;

  htp.tablerowopen;
   htp.tabledata( 'Purchaser Name Matches' || ' ' ||  '(% or * is a wildcard)', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P2', 50, 100, extr2( template, ltype, owner_id, 'P2' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Purchaser Address Matches' || ' ' ||  '(% or * is a wildcard)', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P3', 50, 100, extr2( template, ltype, owner_id, 'P2' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Payment Method', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P4', null, 3, cattributes=>'MULTIPLE' );
    if extr1( template, ltype, owner_id, 'P4', 'AUTHORISATION', TRUE )
     then
      htp.formselectoption( 'AUTHORISATION', 'SELECTED' );
    else
      htp.formselectoption( 'AUTHORISATION' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'BILLING', TRUE )
     then
      htp.formselectoption( 'BILLING', 'SELECTED' );
    else
      htp.formselectoption( 'BILLING' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'CHEQUE', TRUE )
     then
      htp.formselectoption( 'CHEQUE', 'SELECTED' );
    else
      htp.formselectoption( 'CHEQUE' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'GIFT', TRUE )
     then
      htp.formselectoption( 'GIFT', 'SELECTED' );
    else
      htp.formselectoption( 'GIFT' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'MERCHANT', TRUE )
     then
      htp.formselectoption( 'MERCHANT', 'SELECTED' );
    else
      htp.formselectoption( 'MERCHANT' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'PHONE', TRUE )
     then
      htp.formselectoption( 'PHONE', 'SELECTED' );
    else
      htp.formselectoption( 'PHONE' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'Undecided', TRUE )
     then
      htp.formselectoption( 'Undecided', 'SELECTED' );
    else
      htp.formselectoption( 'Undecided' );
    end if;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Order Status', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P5', null, 3, cattributes=>'MULTIPLE' );
    foundrec := FALSE;
    for c7rec in c7 loop
     if c7rec.order_option = 'Ordered' then foundrec := TRUE; end if;
     if extr1( template, ltype, owner_id, 'P5', c7rec.order_option, foundrec )
      then
       htp.formselectoption( c7rec.order_option, 'SELECTED' );
      else
       htp.formselectoption( c7rec.order_option );
     end if;
    end loop;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'User Fee Code', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P5B', 20, 40, extr2( template, ltype, owner_id, 'P5B' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Reached Completed Status within the Month', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'P5A', 'T', extr3( template, ltype, owner_id, 'P5A' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Manually Shipped', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'P5C', 'T', extr3( template, ltype, owner_id, 'P5C' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Purchase Order ID Range From', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P6A', 10, 10, extr2( template, ltype, owner_id, 'P6A' ) ) || ' to ' || htf.formtext( 'P6B', 10, 10, extr2( template, ltype, owner_id, 'P6B' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Order Total is between', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( '$' || htf.formtext( 'P7A', 10, 20, extr2( template, ltype, owner_id, 'P7A' ) ) || ' to $' || htf.formtext( 'P7B', 10, 20, extr2( template, ltype, owner_id, 'P7B' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Date From', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( 'DD (Day)' || htf.formtext( 'P8A', 5, 5, extr2( template, ltype, owner_id, 'P8A' ) ) || ' Month (eg JUL)' || htf.formtext( 'P8B', 5, 5, extr2( template, ltype, owner_id, 'P8B' ) ) || ' Year (eg. 2002)' || htf.formtext( 'P8C', 5, 5, extr2( template, ltype, owner_id, 'P8C' ) ) , cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Date To', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( 'DD (Day)' || htf.formtext( 'P9A', 5, 5, extr2( template, ltype, owner_id, 'P9A' ) ) || ' Month (eg JUL)' || htf.formtext( 'P9B', 5, 5, extr2( template, ltype, owner_id, 'P9B' ) ) || ' Year (eg. 2002)' || htf.formtext( 'P9C', 5, 5, extr2( template, ltype, owner_id, 'P9C' ) ) , cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'A Name of an Item in the Basket Matches' || ' ' ||  '(% or * is a wildcard)', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P10', 50, 100, extr2( template, ltype, owner_id, 'P10' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( 'Display Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  -- Columns to Display
  htp.tablerowopen;
   htp.tabledata( 'Columns/Information to Display', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'D1', null, 10, cattributes=>'MULTIPLE' );
     if extr1( template, ltype, owner_id, 'D1', 'Q', TRUE )
      then
       htp.formselectoption( 'Line Number', 'SELECTED', cattributes=>'VALUE="Q"' );
      else
       htp.formselectoption( 'Line Number', cattributes=>'VALUE="Q"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'A', TRUE )
      then
       htp.formselectoption( 'Order No', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'Order No', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'U', FALSE )
      then
       htp.formselectoption( 'Shopping Basket Items', 'SELECTED', cattributes=>'VALUE="U"' );
      else
       htp.formselectoption( 'Shopping Basket Items', cattributes=>'VALUE="U"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'V', FALSE )
      then
       htp.formselectoption( 'Workflow', 'SELECTED', cattributes=>'VALUE="V"' );
      else
       htp.formselectoption( 'Workflow', cattributes=>'VALUE="V"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'B', TRUE )
      then
       htp.formselectoption( 'Date / Time', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Date / Time', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'C', TRUE )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'D', TRUE )
      then
       htp.formselectoption( 'Customer Details', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'Customer Details', cattributes=>'VALUE="D"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'E', TRUE )
      then
       htp.formselectoption( 'Payment Method', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Payment Method', cattributes=>'VALUE="E"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'S', TRUE )
      then
       htp.formselectoption( 'Order Status', 'SELECTED', cattributes=>'VALUE="S"' );
      else
       htp.formselectoption( 'Order Status', cattributes=>'VALUE="S"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'F', TRUE )
      then
       htp.formselectoption( 'Amount (Gross)', 'SELECTED', cattributes=>'VALUE="F"' );
      else
       htp.formselectoption( 'Amount (Gross)', cattributes=>'VALUE="F"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'G', TRUE )
      then
       htp.formselectoption( 'Shipping', 'SELECTED', cattributes=>'VALUE="G"' );
      else
       htp.formselectoption( 'Shipping', cattributes=>'VALUE="G"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'H', TRUE )
      then
       htp.formselectoption( 'Net Revenue', 'SELECTED', cattributes=>'VALUE="H"' );
      else
       htp.formselectoption( 'Net Revenue', cattributes=>'VALUE="H"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'I', TRUE )
      then
       htp.formselectoption( 'Supplier Cost', 'SELECTED', cattributes=>'VALUE="I"' );
      else
       htp.formselectoption( 'Supplier Cost', cattributes=>'VALUE="I"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'J', TRUE )
      then
       htp.formselectoption( 'Royalty %', 'SELECTED', cattributes=>'VALUE="J"' );
      else
       htp.formselectoption( 'Royalty %', cattributes=>'VALUE="J"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'K', TRUE )
      then
       htp.formselectoption( 'Merchant %', 'SELECTED', cattributes=>'VALUE="K"' );
      else
       htp.formselectoption( 'Merchant %', cattributes=>'VALUE="K"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'T', FALSE )
      then
       htp.formselectoption( 'Net Revenue after Service Charges', 'SELECTED', cattributes=>'VALUE="T"' );
      else
       htp.formselectoption( 'Net Revenue after Service Charges', cattributes=>'VALUE="T"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'W', FALSE )
      then
       htp.formselectoption( 'Additional Options', 'SELECTED', cattributes=>'VALUE="W"' );
      else
       htp.formselectoption( 'Additional Options', cattributes=>'VALUE="W"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'L', TRUE )
      then
       htp.formselectoption( 'Display Totals', 'SELECTED', cattributes=>'VALUE="L"' );
      else
       htp.formselectoption( 'Display Totals', cattributes=>'VALUE="L"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'R' )
      then
       htp.formselectoption( 'Display Grand Total', 'SELECTED', cattributes=>'VALUE="R"' );
      else
       htp.formselectoption( 'Display Grand Total', cattributes=>'VALUE="R"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'M', TRUE )
      then
       htp.formselectoption( 'Logo', 'SELECTED', cattributes=>'VALUE="M"' );
      else
       htp.formselectoption( 'Logo', cattributes=>'VALUE="M"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'N', TRUE )
      then
       htp.formselectoption( 'Client Name as Header', 'SELECTED', cattributes=>'VALUE="N"' );
      else
       htp.formselectoption( 'Client Name as Header', cattributes=>'VALUE="N"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'O', TRUE )
      then
       htp.formselectoption( 'Date', 'SELECTED', cattributes=>'VALUE="O"' );
      else
       htp.formselectoption( 'Date', cattributes=>'VALUE="O"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'P', TRUE )
      then
       htp.formselectoption( 'Embed HTML Page Breaks (IE6.0 + Only)', 'SELECTED', cattributes=>'VALUE="P"' );
      else
       htp.formselectoption( 'Embed HTML Page Breaks (IE6.0 + Only)', cattributes=>'VALUE="P"' );
     end if;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- Break On
  htp.tablerowopen;
   htp.tabledata( 'Break On', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'D2', null, 3, cattributes=>'MULTIPLE' );
     htp.formselectoption( NULL, cattributes=>'VALUE=""' );
     if extr1( template, ltype, owner_id, 'D2', 'A' )
      then
       htp.formselectoption( 'Month and Year', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'Month and Year', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D2', 'B' )
      then
       htp.formselectoption( 'Status', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Status', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D2', 'C' )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D2', 'E' )
      then
       htp.formselectoption( 'Payment Method', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Payment Method', cattributes=>'VALUE="E"' );
     end if;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- Sort On
  htp.tablerowopen;
   htp.tabledata( 'Sort On', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'D3R' );
     if extr1( template, ltype, owner_id, 'D3R', 'A', TRUE )
      then
       htp.formselectoption( 'Order No', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'Order No', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'B', TRUE )
      then
       htp.formselectoption( 'Date / Time', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Date / Time', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'C', TRUE )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'D' )
      then
       htp.formselectoption( 'Customer Details', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'Customer Details', cattributes=>'VALUE="D"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'E' )
      then
       htp.formselectoption( 'Payment Method', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Payment Method', cattributes=>'VALUE="E"' );
     end if;
    htp.formselectclose;

    htp.nl;
    htp.formselectopen( 'D3S' );
     htp.formselectoption( NULL );
     if extr1( template, ltype, owner_id, 'D3S', 'A', TRUE )
      then
       htp.formselectoption( 'Order No', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'Order No', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'B', TRUE )
      then
       htp.formselectoption( 'Date / Time', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Date / Time', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'C', TRUE )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'D' )
      then
       htp.formselectoption( 'Customer Details', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'Customer Details', cattributes=>'VALUE="D"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'E' )
      then
       htp.formselectoption( 'Payment Method', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Payment Method', cattributes=>'VALUE="E"' );
     end if;
    htp.formselectclose;

    htp.nl;
    htp.formselectopen( 'D3T' );
     htp.formselectoption( NULL );
     if extr1( template, ltype, owner_id, 'D3T', 'A', TRUE )
      then
       htp.formselectoption( 'Order No', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'Order No', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'B', TRUE )
      then
       htp.formselectoption( 'Date / Time', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Date / Time', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'C', TRUE )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'D' )
      then
       htp.formselectoption( 'Customer Details', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'Customer Details', cattributes=>'VALUE="D"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'E' )
      then
       htp.formselectoption( 'Payment Method', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Payment Method', cattributes=>'VALUE="E"' );
     end if;
    htp.formselectclose;

   htp.p( '</TD>' );
  htp.tablerowclose;

  -- Heading Colours
  -- Summary Colours
  -- HTML Table Definition
  htp.tablerowopen;
   htp.tabledata( htf.bold('Display Colours and HTML Definitions'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Header Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5A' );
    for c4rec in c4 loop
     if template is null
      then
       if pfx.title_text_colour like '%' || c4rec.clr_hex || '%'
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5A', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Header Font Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5AF' );
    for c4rec in c4 loop
     if template is null
      then
       if pfx.title_colour_font like '%' || c4rec.clr_hex || '%'
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5AF', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Totals Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5B' );
    for c4rec in c4 loop
     if template is null
      then
       if pfx.text_back like '%' || c4rec.clr_hex || '%'
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5B', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Grand Totals Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5G' );
    for c4rec in c4 loop
     if template is null
      then
       if pfx.text_back like '%' || c4rec.clr_hex || '%'
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5G', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Background Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5C' );
    for c4rec in c4 loop
     if template is null
      then
       if c4rec.clr_hex = pfx.text_back
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5C', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Cell Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5D' );
    for c4rec in c4 loop
      if template is null
       then
       if c4rec.clr_hex = pfx.vert_colour_a
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5D', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Cell Font Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5FCA' );
    for c4rec in c4 loop
      if template is null
       then
       if c4rec.clr_hex = pfx.text_colour
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5FCA', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Cell Colour Alt', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5E' );
    for c4rec in c4 loop
     if template is null
      then
       if c4rec.clr_hex = pfx.vert_colour_b
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5E', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Cell Font Colour Alt', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5FCB' );
    for c4rec in c4 loop
      if template is null
       then
       if c4rec.clr_hex = pfx.text_colour
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5FCB', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Font', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'FNT' );
    for c8rec in c8 loop
     if template is null
      then
       if c8rec.font_name = pfx.text_font
        then
         htp.formselectoption( c8rec.font_name, 'SELECTED', cattributes=>'VALUE="' || c8rec.font_name || '"' );
        else
         htp.formselectoption( c8rec.font_name, cattributes=>'VALUE="' || c8rec.font_name || '"' );
       end if;
     else
       htp.formselectoption( c8rec.font_name, extr4( template, ltype, owner_id, 'FNT', c8rec.font_name ), cattributes=>'VALUE="' || c8rec.font_name || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Adjust Font By', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'FSIZE', 10, 20, extr2( template, ltype, owner_id, 'FSIZE','0' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'HTML Table Definition', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D5F', 50, 1000, extr2( template, ltype, owner_id, 'D5F','cellpadding=2 cellspacing=2 border=1' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

  -- Column Titles
  htp.tablerowopen;
   htp.tabledata( htf.bold('Header and Column Titles'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Report Title', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4Z', 30, 100, extr2( template, ltype, owner_id, 'D4Z','Purchase Request Report' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Line No', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4N', 30, 100, extr2( template, ltype, owner_id, 'D4N','Line No' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Order No', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4A', 30, 100, extr2( template, ltype, owner_id, 'D4A','Order No' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Shopping Basket Items', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4U', 30, 100, extr2( template, ltype, owner_id, 'D4U','Shopping Basket Items' )) || ' ' || htf.formcheckbox( 'FULLU', 'T', extr3( template, ltype, owner_id, 'FULLU' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Workflow', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4V', 30, 100, extr2( template, ltype, owner_id, 'D4V','Workflow' )) || ' ' || htf.formcheckbox( 'FULLV', 'T', extr3( template, ltype, owner_id, 'FULLV' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Date / Time', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4B', 30, 100, extr2( template, ltype, owner_id, 'D4B','Date / Time' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Account Name', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4C', 30, 100, extr2( template, ltype, owner_id, 'D4C','Account Name' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Customer Details', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4D', 30, 100, extr2( template, ltype, owner_id, 'D4D','Customer Details' )) || ' ' || htf.formcheckbox( 'FULLX', 'T', extr3( template, ltype, owner_id, 'FULLX' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Payment Method', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4E', 30, 100, extr2( template, ltype, owner_id, 'D4E','Payment Method' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Order Status', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4O', 30, 100, extr2( template, ltype, owner_id, 'D4O','Order Status' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Amount (Gross)', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4F', 30, 100, extr2( template, ltype, owner_id, 'D4F','Amount (Gross)' )) || ' ' || htf.formcheckbox( 'FULLF', 'T', extr3( template, ltype, owner_id, 'FULLF' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Shipping', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4G', 30, 100, extr2( template, ltype, owner_id, 'D4G','Shipping' )) || ' ' || htf.formcheckbox( 'FULLG', 'T', extr3( template, ltype, owner_id, 'FULLG' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Net Revenue', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4H', 30, 100, extr2( template, ltype, owner_id, 'D4H','Net Revenue' )) || ' ' || htf.formcheckbox( 'FULLH', 'T', extr3( template, ltype, owner_id, 'FULLH' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Additional Options', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4W', 30, 100, extr2( template, ltype, owner_id, 'D4W','Additional Options' )) || ' ' || htf.formcheckbox( 'FULLW', 'T', extr3( template, ltype, owner_id, 'FULLW' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Supplier Cost', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4I', 30, 100, extr2( template, ltype, owner_id, 'D4I','Supplier Cost' )) || ' ' || htf.formcheckbox( 'FULLI', 'T', extr3( template, ltype, owner_id, 'FULLI' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Royalty %', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4J', 30, 100, extr2( template, ltype, owner_id, 'D4J','Royalty %' )) || ' ' || htf.formcheckbox( 'FULLJ', 'T', extr3( template, ltype, owner_id, 'FULLJ' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Merchant %', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4K', 30, 100, extr2( template, ltype, owner_id, 'D4K','Merchant %' )) || ' ' || htf.formcheckbox( 'FULLK', 'T', extr3( template, ltype, owner_id, 'FULLK' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Net Revenue after Service Charges', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4T', 30, 100, extr2( template, ltype, owner_id, 'D4T','Net Revenue after Service Charges' )) || ' ' || htf.formcheckbox( 'FULLT', 'T', extr3( template, ltype, owner_id, 'FULLT' ) ) || ' ' || 'Display Full Details', cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Total', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4L', 30, 100, extr2( template, ltype, owner_id, 'D4L','TOTAL' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Grand Total', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4M', 30, 100, extr2( template, ltype, owner_id, 'D4M','GRAND TOTAL' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.bold( 'Additional Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( 'Image (Gif) Containing Logo, Contact and ABN Details', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4IMG', 30, 100, extr2( template, ltype, owner_id, 'D4IMG' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Display Search Parameters', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'R4Z', 'T', extr3( template, ltype, owner_id, 'R4Z' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( 'Add Anchor to View Details of Purchase order', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'XDT', 'T', extr3( template, ltype, owner_id, 'XDT' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( 'Display Option to Download Output to a CSV File<BR>(Available only for Named Templates)', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'CSV', 'T', extr3( template, ltype, owner_id, 'CSV' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;

 -- Special ADMIN Options
 if ltype = 'ADMIN'
  then
   htp.nl;
   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold('Reconcilliation Options'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( 'Perform Reconcilliation', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formcheckbox( 'R1', 'T', extr3( template, ltype, owner_id, 'R1' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( 'Perform Reconcilliation Exception Report', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formcheckbox( 'R2', 'T', extr3( template, ltype, owner_id, 'R2' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( 'Reconcilliation Column Title', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formtext( 'D4R', 50, 100, extr2( template, ltype, owner_id, 'D4R','Reconcilliation' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
   htp.tableclose;
 end if;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold('Save as Template'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formtext( 'TEMPLATE', 50, 100, c10rec.prt_name ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( 'Display Return to Previous Screen Link', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     if template is null
      then
       htp.tabledata( htf.formcheckbox( 'DSPT', 'T', 'CHECKED' ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
      else
       htp.tabledata( htf.formcheckbox( 'DSPT', 'T', extr3( template, ltype, owner_id, 'DSPT' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     end if;
    htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( 'ACTION', 'Run Report' ));
   htp.tabledata( htf.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'));
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.nl;
 htp.nl;

 htp.bold( 'Previously Created Templates' );
 foundrec := false;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 for c9rec in c9(ltype,owner_id) loop
  foundrec := true;
  htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pfm.run_purchrep?surl=' || surl || '&id=' || c9rec.prt_id, c9rec.prt_name ) );
    htp.tabledata( htf.anchor( 'pfm.del_purchrep?surl=' || surl || '&id=' || c9rec.prt_id, '[' || 'Delete' || ']' ) );
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 if not foundrec
  then
   htp.bold( 'No Templates have been Created' );
   htp.nl;
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PFM', 'PURCHREP', owner_id, errmsg=>sqlerrm );
end purchrep;

procedure accept_purchrep( surl in varchar2, p1 in GLBX.MYARRAY, p1m in GLBX.MYARRAY, p4 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, d1 in GLBX.MYARRAY, d2 in GLBX.MYARRAY, d3r in varchar2, d3s in varchar2, d3t in varchar2,
                           p2 in varchar2, p3 in varchar2, p6a in varchar2, p6b in varchar2, action in varchar2, fnt in varchar2, template in varchar2, template2 in varchar2 default null,
                           d5a in varchar2, d5g in varchar2, d5af in varchar2, d5b in varchar2, d5c in varchar2, d5d in varchar2,  d5e in varchar2,  d5f in varchar2, dspt in char default 'F',
                           p7a in varchar2, p7b in varchar2, p8a in varchar2, p8b in varchar2, p8c in varchar2, p9a in varchar2, p9b in varchar2, p9c in varchar2, p10 in varchar2,
                           p5a in char default 'F', p5b in char default null, p5c in char default 'F', r1 in char default 'F', r2 in char default 'F', d4r in varchar2 default null, r4z in varchar2 default 'F', xdt in varchar2 default 'F',
                           d4z in varchar2 default null, d4n in varchar2 default null, d4o in varchar2 default null, d4a in varchar2 default null, d4b in varchar2 default null, d4c in varchar2 default null, d4d in varchar2 default null, d4e in varchar2 default null, d4f in varchar2 default null, d4g in varchar2 default null, d4h in varchar2 default null, d4w in varchar2 default null,
                           d4i in varchar2 default null, d4j in varchar2 default null, d4k in varchar2 default null, d4l in varchar2 default null, d4m in varchar2 default null, d4img in varchar2 default null, d4t in varchar2 default null, d4u in varchar2 default null, d4v in varchar2 default null, csv in char default 'F',
                           fsize in varchar2, fullf in char default 'F', fullg in char default 'F', fullh in char default 'F', fulli in char default 'F', fullj in char default 'F', fullk in char default 'F', fullt in char default 'F', fullu in char default 'F', fullv in char default 'F', fullw in char default 'F', fullx in char default 'F',
                           d5fca in varchar2 default '000000', d5fcb in varchar2 default '000000', dump_to_csv in char default 'F')
as

 TYPE DCurTyp IS REF CURSOR;  -- define weak REF CURSOR type

 cursor c2(vpoid integer, src in varchar2) is
  select 'x' exst
  from shopping_basket
  where poid = vpoid and
        ((upper(photo_size) like src) or (upper(film_name) like src));

 cursor c3( ord1 varchar2, ord2 varchar2, ord3 varchar2 ) is
  select *
  from purchase_order po, advanced_query_temp_result_a aa
  where po.poid = aa.umo_id
  order by decode(ord1,'A',to_char(poid),'B',to_char(date_created,'YYYYMMDD'),'C',upper(sendto_lastname || sendto_firstname),'D',upper(sendto_street),'E',paid_method,to_char(poid)),
           decode(ord2,'A',to_char(poid),'B',to_char(date_created,'YYYYMMDD'),'C',upper(sendto_lastname || sendto_firstname),'D',upper(sendto_street),'E',paid_method,to_char(poid)),
           decode(ord3,'A',to_char(poid),'B',to_char(date_created,'YYYYMMDD'),'C',upper(sendto_lastname || sendto_firstname),'D',upper(sendto_street),'E',paid_method,to_char(poid));

 cursor c3det( sess_id integer ) is
  select p.username p_username, p.business_name, ca.username ca_username, ca.account_name, 'ACCOUNT' acct, ca.aid acid
  from photographer p, customer_account ca, login_session ls
  where p.pid = ca.pid and
        ca.aid = ls.aid and
        ls.sessid = sess_id and
        ls.login_type in ('OWNER','CUSTOMER' )
  union all
  select p.username p_username, p.business_name, cp.username ca_username, cp.account_name, 'PROFILE' acct, cp.aid acid
  from photographer p, customer_profile cp, login_session ls
  where p.pid = cp.pid and
        cp.profile_id = ls.aid and
        ls.sessid = sess_id and
        ls.login_type in ('PROFILE','PROFILEG' );

 cursor c4(vpoid integer) is
  select 'x' exst
  from shopping_basket
  where poid = vpoid and
        lab_id in (select umo_id from advanced_query_temp_result_a);

 cursor c5( tempname varchar2, ltype varchar2, lid integer ) is select distinct prt_id from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and prt_name = tempname;

 cursor c6(dtfrom date, dtto date) is select * from reconcilliation where date_reconcilled >= dtfrom and date_reconcilled <= dtto and actual_poid is null order by extra_col_1,transaction_id;

 dcurs  	DCurTyp;
 c2rec		c2%ROWTYPE;
 c3det_rec	c3det%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 val		number;
 ttl1		number;
 ttl2		number;
 ttl3		number;
 ttl4		number;
 ttl5		number;
 ttlag		number;
 ttl6		number;
 ttl7		number;
 ttl8		number;
 ttl9		number;
 ttlg		number;
 gttl1		number;
 gttl2		number;
 gttl3		number;
 gttl4		number;
 gttl5		number;
 gttlag		number;
 gttl6		number;
 gttl7		number;
 gttl8		number;
 gttl9		number;
 gttlg		number;
 v1		number;
 v2		number;
 vgst		number;
 mx		integer;
 ctr		integer;
 nmb1		integer;
 nmb2		integer;
 nmb3		number;
 nmb4		number;
 ttl		number;
 fz		integer;
 date1		date;
 date2		date;
 page_break	boolean;
 dsp_totals	boolean;
 dsp_grand	boolean;
 dsp_logo	boolean;
 dsp_cname	boolean;
 dsp_date	boolean;
 foundrec	boolean;
 undc		boolean;
 vmsg		varchar2(20);
 srt1		varchar2(100);
 srt2		varchar2(100);
 srt3		varchar2(100);
 sts		varchar2(100);
 tmp		varchar2(1000);
 tmp2		varchar2(1000);
 hdr_txt	varchar2(1000);
 brk		varchar2(10000);
 last_brk	varchar2(10000);
 gbfr		varchar2(32767);
 stmt		varchar2(32767);
 stmt_temp	varchar2(32767);
 pfx		THEME%ROWTYPE;
 poid_array	GLBX.MYARRAY;
 poid_array2	GLBX.MYARRAY;
 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;


procedure dump_to( cattributes varchar2 )
as
begin
 if dump_to_csv = 'F'
  then
   htp.tableopen( cattributes );
 end if;
end dump_to;

procedure dump_tc
as
begin
 if dump_to_csv = 'F'
  then
   htp.tableclose;
 end if;
end dump_tc;

procedure dump_tr
as
begin
 if dump_to_csv = 'F'
  then
   htp.tablerowopen;
  else
   gbfr := NULL;
 end if;
end dump_tr;

procedure dump_trc
as
begin
 if dump_to_csv = 'F'
  then
   htp.tablerowclose;
  else
   htp.p( replace(replace(replace(replace(gbfr,'<BR>',' '),'&nbsp;',' '),'<B>',''),'</B>','') );
 end if;
end dump_trc;

procedure dump_nl
as
begin
 if dump_to_csv = 'F'
  then
   htp.nl;
 end if;
end dump_nl;

procedure dump_th( dt in varchar2, cattributes in varchar2 )
as
begin
 if dump_to_csv = 'F'
  then
   htp.tableheader(dt, cattributes=>cattributes);
  else
   gbfr := gbfr || '"' || dt || '",';
 end if;
end dump_th;

procedure dump_td( dt in varchar2, cattributes in varchar2 )
as
begin
 if dump_to_csv = 'F'
  then
   htp.tabledata(nvl(dt,'&nbsp;'), cattributes=>cattributes);
  else
   gbfr := gbfr || '"' || dt || '",';
 end if;
end dump_td;

procedure display_header( cname in varchar2 default null )
as
begin

  -- Header
  if (dsp_logo or dsp_cname or dsp_date) and dump_to_csv = 'F'
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 width="100%"' );
    htp.tablerowopen;
     if dsp_logo
      then
       htp.tabledata( htf.anchor2(glbx.extract_master_parameter('PICTION_HOME_PAGE'),htf.img( DECS.IMAGE_LOCATION || 'admin/piction.gif',cattributes=>' border=0',calt=>'Go to the Site'),ctarget=>'PICTION_WINDOW'), cattributes=>'ALIGN=LEFT VALIGN=TOP style="text-align: left;"');
     end if;
     if dsp_cname
      then
       htp.tabledata( htf.header(2, cname, 'CENTER'), cattributes=>'ALIGN=CENTER VALIGN=TOP style="text-align: center;"');
     end if;
     if dsp_cname
      then
       htp.tabledata( htf.bold( to_char(sysdate,LNG.MASK) ), cattributes=>'ALIGN=RIGHT VALIGN=TOP style="text-align: right;"');
     end if;
    htp.tablerowclose;
    htp.tableclose;
    htp.nl;
  end if;
  dump_to( cattributes=>d5f );
  dump_tr;
  tmp := 'bgcolor="#' || d5a || '" ALIGN="CENTER" style="text-align: center; font-family: ' || fnt || '; color: #' || d5af || '; background-color: #' || d5a || '"';
  for j in d1.first..d1.last loop
   if d1(j) = 'Q'
    then
     dump_th( nvl(d4n,'&nbsp;'), cattributes=>tmp );
   elsif d1(j) = 'A'
    then
     dump_th( d4a, cattributes=>tmp );
   elsif d1(j) = 'U'
    then
     dump_th( d4u, cattributes=>tmp );
   elsif d1(j) = 'V'
    then
     dump_th( d4v, cattributes=>tmp );
   elsif d1(j) = 'B'
    then
     dump_th( d4b, cattributes=>tmp );
   elsif d1(j) = 'C'
    then
     dump_th( d4c, cattributes=>tmp );
   elsif d1(j) = 'D'
    then
     if dump_to_csv = 'F'
      then
      if fullx = 'F'
       then
        dump_th( d4d, cattributes=>tmp || ' COLSPAN="3"' );
       else
        dump_th( d4d, cattributes=>tmp || ' COLSPAN="10"' );
      end if;
     else
      if fullx = 'F'
       then
        dump_th( 'First Name', cattributes=>tmp );
        dump_th( 'Last Name', cattributes=>tmp );
        dump_th( 'Address', cattributes=>tmp );
       else
        dump_th( 'First Name', cattributes=>tmp );
        dump_th( 'Last Name', cattributes=>tmp );
        dump_th( 'Street', cattributes=>tmp );
        dump_th( 'Branch', cattributes=>tmp );
        dump_th( 'Department', cattributes=>tmp );
        dump_th( 'Suburb', cattributes=>tmp );
        dump_th( 'City', cattributes=>tmp );
        dump_th( 'State', cattributes=>tmp );
        dump_th( 'Country', cattributes=>tmp );
        dump_th( 'Postcode', cattributes=>tmp );
      end if;
     end if;
   elsif d1(j) = 'S'
    then
     dump_th( d4o, cattributes=>tmp );
   elsif d1(j) = 'E'
    then
     dump_th( d4e, cattributes=>tmp );
   elsif d1(j) = 'F'
    then
     dump_th( d4f, cattributes=>tmp );
   elsif d1(j) = 'G'
    then
     dump_th( d4g, cattributes=>tmp );
   elsif d1(j) = 'H'
    then
     dump_th( d4h, cattributes=>tmp );
   elsif d1(j) = 'W'
    then
     dump_th( d4w, cattributes=>tmp );
   elsif d1(j) = 'I'
    then
     dump_th( d4i, cattributes=>tmp );
   elsif d1(j) = 'J'
    then
     dump_th( d4j, cattributes=>tmp );
   elsif d1(j) = 'K'
    then
     dump_th( d4k, cattributes=>tmp );
   elsif d1(j) = 'T'
    then
     dump_th( d4t, cattributes=>tmp );
   end if;
  end loop;
  if r1 = 'T'
   then
    dump_th( d4r, cattributes=>tmp || ' colspan="2"' );
  end if;
  dump_trc;

end display_header;

procedure display_totals
as
begin
  if not dsp_totals then return; end if;
  -- Totals
  dump_tr;
  tmp := 'bgcolor="#' || d5a || '" ALIGN="RIGHT" style="text-align: right; font-family: ' || fnt || '; color: #' || d5af || '; background-color: #' || d5a || '"';
  for j in d1.first..d1.last loop
   if d1(j) = 'Q'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'A'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'U'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'V'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'B'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'C'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'D'
    then
     if dump_to_csv = 'F'
      then
       if fullx = 'F' then dump_td( '&nbsp;', cattributes=>tmp || ' COLSPAN="3"' ); else dump_td( '&nbsp;', cattributes=>tmp || ' COLSPAN="10"' ); end if;
      else
       if fullx = 'F'
        then
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
        else
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
         dump_td( '&nbsp;', cattributes=>tmp );
       end if;
     end if;
   elsif d1(j) = 'S'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'E'
    then
     dump_td( htf.bold( d4l ), cattributes=>tmp );
   elsif d1(j) = 'F'
    then
      dump_td( to_char(ttl1,LNG.MONEY_FORMAT) || htf.nl || 'GST: ' || to_char(ttlg,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'G'
    then
      dump_td( to_char(ttl2,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'H'
    then
      dump_td( to_char(ttl3,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'W'
    then
      dump_td( to_char(ttl9,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'I'
    then
      dump_td( to_char(ttl4,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'J'
    then
      dump_td( to_char(ttl5,LNG.MONEY_FORMAT) || htf.nl || 'GST: ' || to_char(ttlag,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'K'
    then
      dump_td( to_char(ttl6,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'T'
    then
      dump_td( to_char(ttl8,LNG.MONEY_FORMAT), cattributes=>tmp );
   end if;
  end loop;
  if r1 = 'T'
   then
    dump_td( to_char(ttl7,LNG.MONEY_FORMAT), cattributes=>tmp || ' colspan="2"' );
  end if;
  dump_trc;

end display_totals;

procedure display_grandtotal
as
begin
  if not dsp_grand then return; end if;
  -- Grand Totals
  dump_tr;
  tmp := 'bgcolor="#' || d5g || '" ALIGN="RIGHT" style="text-align: right; font-family: ' || fnt || '; color: #' || d5af || '; background-color: #' || d5g || '"';
  for j in d1.first..d1.last loop
   if d1(j) = 'Q'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'A'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'U'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'V'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'B'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'C'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'D'
    then
     if dump_to_csv = 'F'
      then
       dump_td( '&nbsp;', cattributes=>tmp || ' COLSPAN="3"' );
      else
       dump_td( '&nbsp;', cattributes=>tmp );
       dump_td( '&nbsp;', cattributes=>tmp );
       dump_td( '&nbsp;', cattributes=>tmp );
     end if;
   elsif d1(j) = 'S'
    then
     dump_td( '&nbsp;', cattributes=>tmp );
   elsif d1(j) = 'E'
    then
     dump_td( htf.bold( d4m ), cattributes=>tmp );
   elsif d1(j) = 'F'
    then
      dump_td( to_char(gttl1,LNG.MONEY_FORMAT) || htf.nl || 'GST: ' || to_char(gttlg,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'G'
    then
      dump_td( to_char(gttl2,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'H'
    then
      dump_td( to_char(gttl3,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'W'
    then
      dump_td( to_char(gttl9,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'I'
    then
      dump_td( to_char(gttl4,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'J'
    then
      dump_td( to_char(gttl5,LNG.MONEY_FORMAT) || htf.nl || 'GST: ' || to_char(gttlag,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'K'
    then
      dump_td( to_char(gttl6,LNG.MONEY_FORMAT), cattributes=>tmp );
   elsif d1(j) = 'T'
    then
      dump_td( to_char(gttl8,LNG.MONEY_FORMAT), cattributes=>tmp );
   end if;
  end loop;
  if r1 = 'T'
   then
    dump_td( to_char(gttl7,LNG.MONEY_FORMAT), cattributes=>tmp || ' colspan="2"' );
  end if;
  dump_trc;
end display_grandtotal;

procedure display_reconcile( purchrec in c3%ROWTYPE, tmp in varchar2, gtotal in number )
as

 cursor c1(vpoid integer) is select * from reconcilliation where actual_poid = vpoid;
 c1rec	c1%ROWTYPE;

 val	number;

begin
 open c1(purchrec.poid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   dump_td( 'No Reconcile Data Exists', cattributes=>tmp || ' colspan="2"' );
   return;
 end if;
 if dump_to_csv = 'F'
  then
   htp.p( '<TD ' || tmp || '>' );
    htp.p( 'ID:' || htf.bold( c1rec.transaction_id ) );
    htp.nl;
    htp.p( 'Date:' || htf.bold( to_char(c1rec.date_reconcilled,LNG.TSMASK) ) );
    htp.nl;
    htp.p( 'Return Code:' || htf.bold( c1rec.return_code ) );
    htp.nl;
    if trim(c1rec.extra_col_1) is not null
     then
      htp.p( 'Refunded:' || htf.bold( c1rec.extra_col_1 ) );
    end if;
   htp.p( '</TD>' );
   htp.p( '<TD ' || tmp || '>' );
   if c1rec.actual_purchase_order_total = c1rec.transaction_total
    then
     htp.p( to_char(c1rec.actual_purchase_order_total, LNG.MONEY_FORMAT ));
    else
     val := c1rec.actual_purchase_order_total - c1rec.transaction_total;
       ttl7 := nvl(ttl7,0) + nvl(val,0);
     gttl7 := nvl(gttl7,0) + nvl(val,0);
     htp.p( htf.bold( 'Purchase Order: ' || to_char(c1rec.actual_purchase_order_total, LNG.MONEY_FORMAT )) || htf.nl ||
            htf.bold( 'Reconciled Val: ' || to_char(c1rec.transaction_total, LNG.MONEY_FORMAT )) || htf.nl ||
            htf.bold( 'Difference Val: ' || to_char(val, LNG.MONEY_FORMAT )));
   end if;
   htp.p( '</TD>' );
 else
  dump_td( c1rec.transaction_id || '-' || to_char(c1rec.date_reconcilled,LNG.TSMASK) || '-' || c1rec.return_code || '-' || c1rec.extra_col_1, tmp );
 end if;
end display_reconcile;

procedure show_basket( vpoid integer, fullu in char, tmp in varchar2 )
as

 cursor c1(vpoid integer) is select * from shopping_basket where poid = vpoid and packaged_product_id is null order by decode(isgallery,'P',0,1),nvl(packaged_product_id,999999999),shopping_id;
 cursor c2(v_umo integer) is select * from umo where umo_id = v_umo;
 cursor c3(vpoid integer, vshopid integer) is select * from shopping_basket where poid = vpoid and packaged_product_id = vshopid;

 c2rec  c2%ROWTYPE;

begin
 if dump_to_csv = 'F'
  then
   htp.p( '<TD ' || tmp || '>' );
   for c1rec in c1(vpoid) loop
   if fullu = 'F'
    then
     htp.p( c1rec.qty || 'x' || c1rec.photo_size || ' ' || to_char(c1rec.photo_cost,LNG.MONEY_FORMAT));
     if c1rec.isgallery = 'P'
      then
       for c3rec in c3(vpoid,c1rec.shopping_id) loop
        htp.p( htf.nl || c3%ROWCOUNT || ':' || c1rec.qty || 'x' || c1rec.photo_size || ' ' || to_char(c1rec.photo_cost,LNG.MONEY_FORMAT));
       end loop;
     end if;
     if c1rec.user_fee_code is not null then htp.p( '(' || c1rec.user_fee_code || ')' ); end if;
     --htp.nl;
    else
     htp.p( c1rec.shopping_id || '- ' || c1rec.qty || 'x' || c1rec.photo_size || ' ' || to_char(c1rec.photo_cost,LNG.MONEY_FORMAT) || '(' || c1rec.ppi || '-' || c1rec.phg_code || ')');
     open c2(c1rec.phid);
     fetch c2 into c2rec;
     if c2%FOUND
      then
       close c2;
       htp.nl;
       htp.p( '.' || 'Image' || ':' || c2rec.extras.title || '-' || c2rec.extras.film_name );
       --htp.nl;
      else
       close c2;
       --htp.nl;
     end if;
     if c1rec.isgallery = 'P'
      then
       for c3rec in c3(vpoid,c1rec.shopping_id) loop
        htp.p( htf.nl || c3%ROWCOUNT || ':' || c1rec.qty || 'x' || c1rec.photo_size || ' ' || to_char(c1rec.photo_cost,LNG.MONEY_FORMAT));
       end loop;
     end if;
     if c1rec.user_fee_code is not null then htp.nl; htp.p( 'UF' || ':' || c1rec.user_fee_code ); end if;
     htp.nl;
     htp.p( ord.sbitemtotal(c1rec.shopping_id, c1rec.poid) );
   end if;
   htp.line;
   end loop;
   htp.p( '</TD>' );
 else
   gbfr := gbfr || '"';
   for c1rec in c1(vpoid) loop
    gbfr := gbfr || replace( c1rec.qty || 'x' || c1rec.photo_size || ' ' || to_char(c1rec.photo_cost,LNG.MONEY_FORMAT),'"','' ) || '.';
    if c1rec.isgallery = 'P'
     then
      for c3rec in c3(vpoid,c1rec.shopping_id) loop
       gbfr := gbfr || c3%ROWCOUNT || ':' || replace( c1rec.qty || 'x' || c1rec.photo_size || ' ' || to_char(c1rec.photo_cost,LNG.MONEY_FORMAT),'"','' ) || '.';
      end loop;
    end if;
    if c1rec.user_fee_code is not null then gbfr := gbfr || replace( '(' || c1rec.user_fee_code || ')','"','' ) || '.'; end if;
   end loop;
   gbfr := gbfr || '"' || ',';
 end if;
end show_basket;

procedure addopt( vpoid integer )
as

 cursor c1(vpoid integer) is select * from purchase_additional_options where poid = vpoid and display_receipt_page <> 'N';

begin
 if dump_to_csv = 'F'
  then
   htp.p( '<TD ' || tmp || '>' );
   for c1rec in c1(vpoid) loop
    if c1rec.display_receipt_page = 'M'
     then
      htp.p( c1rec.merchant_id_code || ' ' || to_char(c1rec.chosen_price,LNG.MONEY_FORMAT));
    elsif c1rec.display_receipt_page = 'C'
     then
      htp.p( c1rec.display_text || ' ' || to_char(c1rec.chosen_price,LNG.MONEY_FORMAT));
    end if;
    if c1rec.display_receipt_custresp = 'T'
     then
      htp.p( ':' || c1rec.customer_comment );
    end if;
    htp.nl;
   end loop;
   htp.p( '</TD>' );
 else
   gbfr := gbfr || '"';
   for c1rec in c1(vpoid) loop
    if c1rec.display_receipt_page = 'M'
     then
      gbfr := gbfr ||  c1rec.merchant_id_code || ' ' || to_char(c1rec.chosen_price,LNG.MONEY_FORMAT);
    elsif c1rec.display_receipt_page = 'C'
     then
      gbfr := gbfr ||  c1rec.display_text || ' ' || to_char(c1rec.chosen_price,LNG.MONEY_FORMAT);
    end if;
    if c1rec.display_receipt_custresp = 'T'
     then
      gbfr := gbfr ||  ':' || c1rec.customer_comment;
    end if;
   end loop;
   gbfr := gbfr || '"' || ',';
 end if;
end addopt;

procedure show_workflow( vpoid integer, fullv in char, tmp in varchar2 )
as
 cursor c1(vpoid integer) is select * from shopping_basket where poid = vpoid order by shopping_id;
 cursor c6( wsid integer ) is select workflow_name from workflow_set where status_workflow = wsid;
 cursor c7( mfcid integer ) is select name from manufacturer where manufacturer_id = mfcid;

 c6rec			c6%ROWTYPE;
 c7rec			c7%ROWTYPE;

begin
 if dump_to_csv = 'F'
  then
   htp.p( '<TD ' || tmp || '>' );
   for c1rec in c1(vpoid) loop
   if fullv = 'F'
    then
     open c6( c1rec.status_workflow );
     fetch c6 into c6rec;
     close c6;
     htp.bold( c6rec.workflow_name );
     htp.nl;
     htp.p( c1rec.qty || 'x' || c1rec.photo_size || ' ' || to_char(c1rec.photo_cost,LNG.MONEY_FORMAT));
     htp.nl;
    else
     open c6( c1rec.status_workflow );
     fetch c6 into c6rec;
     close c6;
     htp.bold( '[' || c1rec.shopping_id || ']' || c6rec.workflow_name );
     htp.nl;
     htp.p( LNG.PHG_TXT_082 || ':' || c1rec.status || ' (' || c1rec.status_id || ')' );
     if c1rec.status_comment is not null then htp.nl; htp.p( c1rec.status_comment ); end if;
     if c1rec.priority_of_item is not null then htp.nl; htp.p( LNG4.AHC_TXT_726 || ':' || c1rec.priority_of_item ); end if;
     if c1rec.status_mfctr is not null
      then
       open c7(c1rec.status_mfctr);
       fetch c7 into c7rec;
       close c7;
       htp.nl;
       htp.p( 'Mfctr: ' || c7rec.name );
     end if;
     htp.nl;
   end if;
   end loop;
   htp.p( '</TD>' );
  else
   gbfr := gbfr || '"';
   for c1rec in c1(vpoid) loop
     open c6( c1rec.status_workflow );
     fetch c6 into c6rec;
     close c6;
     gbfr := gbfr || replace( c6rec.workflow_name || '-' || c1rec.qty || 'x' || c1rec.photo_size || ' ' || to_char(c1rec.photo_cost,LNG.MONEY_FORMAT),'"','' );
   end loop;
   gbfr := gbfr || '"' || ',';
 end if;
end show_workflow;

procedure save_query
as
 tmp	varchar2(100);
begin
   tmp := nvl(template,'Last Query');
   mx := NULL;
   open c5(tmp, ltype, owner_id);
   fetch c5 into mx;
   close c5;
   if mx is null
    then
     select nvl(max(prt_id),0) + 1 mx into mx from purchase_report_template;
   end if;
   delete from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(owner_id,0) and prt_id = mx;
   for j in p1.first..p1.last loop
    insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P1',p1(j));
   end loop;
   for j in p1m.first..p1m.last loop
    insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P1M',p1m(j));
   end loop;
   for j in p4.first..p4.last loop
    insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P4',p4(j));
   end loop;
   for j in p5.first..p5.last loop
    insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P5',p5(j));
   end loop;
   for j in d1.first..d1.last loop
    insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D1',d1(j));
   end loop;
   for j in d2.first..d2.last loop
    insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D2',d2(j));
   end loop;
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D3R',d3r);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D3S',d3s);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D3T',d3t);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FSIZE',fz);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P2',p2);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P3',p3);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P6A',p6a);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P6B',p6b);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P2',p2);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FNT',fnt);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5A',d5a);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5G',d5g);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5AF',d5af);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5B',d5b);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5C',d5c);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5D',d5d);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5E',d5e);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5FCA',d5fca);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5FCB',d5fcb);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5F',d5F);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P7A',p7a);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P7B',p7b);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P8A',p8a);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P8B',p8b);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P8C',p8C);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P9A',p9a);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P9B',p9b);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P9C',p9C);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P10',p10);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P5A',p5a);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P5B',p5b);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P5C',p5c);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'R1',r1);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'R2',r2);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4R',d4r);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'R4Z',r4z);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'XDT',xdt);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4Z',d4z);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4A',d4a);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4B',d4b);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4C',d4c);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4D',d4d);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4E',d4e);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4F',d4f);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4G',d4g);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4H',d4h);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4I',d4i);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4J',d4j);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4K',d4k);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4L',d4l);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4M',d4m);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4N',d4n);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4O',d4o);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4T',d4t);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4U',d4u);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4V',d4v);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4W',d4w);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4IMG',d4img);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLF',fullf);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLG',fullg);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLH',fullh);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLI',fulli);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLJ',fullj);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLK',fullk);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLT',fullt);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLU',fullu);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLV',fullv);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLW',fullw);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FULLX',fullx);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'DSPT',dspt);
   insert into purchase_report_template(prt_id,prt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'CSV',csv);
   commit;
end save_query;

begin
 glbx.adm_cookie_id( surl, sessid, sts, 'PFM.ACCEPT_PURCHREP');
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.ACCEPT_PURCHREP', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   stype := 1;
   ltype := 'ADMIN';
 end if;

 pfx := glbx.photo_lf(owner_id);
 begin fz := nvl(to_number(fsize),0); exception when others then fz := 0; end;

 if dump_to_csv = 'T'
  then
   htp.prn('Content-type: ' || 'bad/type' || chr(10));
   htp.prn('Content-Disposition: attachment; filename=' || 'pricing_' || to_char(sysdate,'dd_mon_yyyy') || '.csv' || chr(10));
   htp.prn('Content-Transfer-Encoding: binary' || chr(10));
   htp.prn(chr(10));
  else
   glbx.main_title( surl, d4z, '<BODY BGCOLOR="#' || d5c || '">',helpid=>'P78', stype=>stype, sstyle=>fnt,sclr=>pfx.text_colour, finc=>fsize, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.title( 'Purchase Order Report' );
   htp.p( '<CENTER>' );
 end if;

 page_break := FALSE;
 dsp_totals := FALSE;
 dsp_grand := FALSE;
 dsp_logo := FALSE;
 dsp_cname := FALSE;
 dsp_date := FALSE;
 for j in d1.first..d1.last loop
  if d1(j) = 'L' then dsp_totals := TRUE; end if;
  if d1(j) = 'M' then dsp_logo := TRUE; end if;
  if d1(j) = 'N' then dsp_cname := TRUE; end if;
  if d1(j) = 'O' then dsp_date := TRUE; end if;
  if d1(j) = 'P' then page_break := TRUE; end if;
  if d1(j) = 'R' then dsp_grand := TRUE; end if;
 end loop;
 if p1.count = 1
  then
   htp.nl;
   htp.bold( 'You must select at least account' );
   htp.htmlclose;
   return;
 end if;

 if r4z = 'T' and dump_to_csv = 'F'
  then
   htp.bold( 'Search parameters' );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=1 border=1' );
   if p2 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Purchaser Name Matches' ));
      htp.tabledata( p2 );
     htp.tablerowclose;
   end if;
   if p3 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Purchaser Address Matches' ));
      htp.tabledata( p3 );
     htp.tablerowclose;
   end if;
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Payment Method' ));
     htp.p( '<TD>' );
     for j in p4.first..p4.last loop
      if p4(j) is not null then htp.p(initcap(p4(j)) || ', '); end if;
     end loop;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Order Status' ));
     htp.p( '<TD>' );
     for j in p5.first..p5.last loop
      if p5(j) is not null then htp.p(p5(j) || ', '); end if;
     end loop;
     htp.p( '</TD>' );
    htp.tablerowclose;
   if p6a is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Purchase Order ID Range From' ));
      htp.tabledata( p6a || '-' || p6b );
     htp.tablerowclose;
   end if;
   if p7a is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(  'Order Total is between' ));
      htp.tabledata( '$' || p7a || ' - ' || '$' || p7b );
     htp.tablerowclose;
   end if;
   if p8a is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(  'Date Range' ));
      htp.tabledata( p8a || '-' || p8b || '-' || p8c || ' to ' || p9a || '-' || p9b || '-' || p9c );
     htp.tablerowclose;
   end if;
   if p10 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'A Name of an Item in the Basket Matches' ));
      htp.tabledata( p10 );
     htp.tablerowclose;
   end if;
   htp.tableclose;
 end if;

  -- Body
  stmt := 'select poid from purchase_order po where';
  if p2 is not null
   then
    stmt := stmt || ' and upper(sendto_name) like ''' || replace(upper(p2),'*','%') || '''';
  end if;
  if p3 is not null
   then
    stmt := stmt || ' and upper(sendto_street || sendto_branch || sendto_department || sendto_suburb || sendto_city || sendto_postcode || sendto_country || sendto_state || billing_street || billing_branch || billing_department || billing_suburb || billing_city || billing_postcode || billing_country || billing_state ) like ''' || replace(upper(p3),'*','%') || '''';
  end if;

  stmt_temp := NULL;
  if p4.count > 0
   then
    for j in p4.first..p4.last loop
     if p4(j) is not null and p4(j) <> 'Undecided'
      then
       stmt_temp := stmt_temp || ',' || '''' || p4(j) || '''';
     end if;
    end loop;
    if stmt_temp is null
     then
      stmt := stmt || ' and paid_method is NULL';
     else
      undc := FALSE;
      for j in p4.first..p4.last loop
        if p4(j) = 'Undecided' then undc := TRUE; end if;
      end loop;
      if undc
       then
        stmt := stmt || ' and (paid_method in (' || substr(stmt_temp,2) || ') or paid_method is null)';
       else
        stmt := stmt || ' and paid_method in (' || substr(stmt_temp,2) || ')';
      end if;
    end if;
  end if;

  begin nmb1 := to_number(p6a); exception when others then nmb1 := NULL; end;
  begin nmb2 := to_number(p6b); exception when others then nmb2 := NULL; end;
  nmb1 := nvl(nmb1,0);
  nmb2 := nvl(nmb2,9999999);
  stmt := stmt || ' and poid between ' || nmb1 || ' and ' || nmb2;

  begin date1 := to_date(p8a || '-' || p8b || '-' || p8c,'DD-MON-YYYY'); exception when others then date1 := NULL; end;
  begin date2 := to_date(p9a || '-' || p9b || '-' || p9c,'DD-MON-YYYY'); exception when others then date2 := NULL; end;
  date1 := nvl(date1,sysdate-1000);
  date2 := nvl(date2,sysdate+1000);
  stmt := stmt || ' and date_created between to_date(''' || to_char(date1,'DD-MON-YYYY') || ''',''DD-MON-YYYY'') and to_date(''' || to_char(date2+1,'DD-MON-YYYY') || ''',''DD-MON-YYYY'')';

  stmt_temp := NULL;
  for j in p5.first..p5.last loop
   if p5(j) is not null then stmt_temp := stmt_temp || ',' || '''' || p5(j) || ''''; end if;
  end loop;
  stmt := stmt || ' and status in (' || substr(stmt_temp,2) || ')';

  stmt_temp := NULL;
  for j in p1.first..p1.last loop
   if p1(j) is not null then  stmt_temp := stmt_temp || ',' || '''' || p1(j) || ''''; end if;
  end loop;

  if ltype in ('ADMIN','MANUFACTURER')
   then
    stmt := stmt || ' and pid in (' || substr(stmt_temp,2) || ')' ;
   else
    stmt := stmt || ' and pid = ' || owner_id || ' and exists (select aid from login_session ls where po.sessid = ls.sessid and login_type in (''OWNER'',''CUSTOMER'') and aid in (' || substr(stmt_temp,2) || ') union all select aid from login_session ls where po.sessid = ls.sessid and login_type in (''PROFILE'',''PROFILEG'') and aid in (select profile_id from customer_profile cp where cp.profile_id = ls.aid and cp.aid in (' || substr(stmt_temp,2) || ') ))';
  end if;

  -- Order Reached Completed Status within the month
  if p5a = 'T'
   then
    stmt := stmt || ' and exists (select ''x'' exst from purchase_audit pa where to_char(pa.date_changed,''MMYYYY'') = to_char(po.date_created,''MMYYYY'') and pa.poid = po.poid and pa.column_name = ''STATUS'' and pa.new_value = ''Order Completed'')';
  end if;

  -- User Fee Code
  if p5b is not null
   then
    stmt := stmt || ' and exists (select ''x'' exst from shopping_basket sb where sb.poid = po.poid and user_fee_code like ''' || p5b || ''' )';
  end if;

  -- Manually Shipped
  if p5c = 'T'
   then
    stmt := stmt || ' and manual_ship = ''T''';
  end if;

  stmt := replace(stmt,'where and','where ') || ' order by poid';
  -- fetch cursor into array
  ctr := 0;
  -- htp.p( stmt ); htp.nl;
  open dcurs for stmt;
  loop
   ctr := ctr + 1;
   fetch dcurs into poid_array(ctr);
   if dcurs%NOTFOUND then exit; end if;
  end loop;
  close dcurs;

  if r4z = 'T' and dump_to_csv = 'F'
   then
    htp.p( stmt );
    htp.nl;
  end if;

  if ctr = 0
   then
    -- No Data Found
    save_query;
    dump_tc;
    htp.nl;
    htp.bold( 'No Rows Found That Satisfy this Query' );
    htp.nl;
    htp.nl;
    htp.anchor( 'pfm.purchrep?surl=' || surl || '&template=' || mx, 'Return to Report Screen' );
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;
  end if;
  -- go through array and check totals
  begin nmb3 := to_number(p7a); exception when others then nmb3 := NULL; end;
  begin nmb4 := to_number(p7b); exception when others then nmb4 := NULL; end;

  if (nmb3 is not null or nmb4 is not null) and poid_array.count > 0
   then
    nmb3 := nvl(nmb3,0);
    nmb4 := nvl(nmb4,9999999);
    for j in poid_array.first..poid_array.last loop
     ttl := nvl(glbx.grand_total_payment( poid_array(j), FALSE ),0);
     if ttl < nmb3 or ttl > nmb4 then poid_array(j) := NULL; end if;
    end loop;
  end if;

  if p10 is not null and poid_array.count > 0
   then
    for j in poid_array.first..poid_array.last loop
     if poid_array(j) is not null
      then
       open c2(poid_array(j), '%' || replace(upper(p10),'*','%') || '%');
       fetch c2 into c2rec;
       if c2%NOTFOUND
        then
         poid_array(j) := NULL;
       end if;
       close c2;
     end if;
    end loop;
  end if;

  if p1m.count > 1 and poid_array.count > 0
   then
    delete from advanced_query_temp_result_a;
    for j in p1m.first..p1m.last loop
     insert into advanced_query_temp_result_a(umo_id) values (p1m(j));
    end loop;
    for j in poid_array.first..poid_array.last loop
     if poid_array(j) is not null
      then
       open c4(poid_array(j));
       fetch c4 into c4rec;
       if c4%NOTFOUND
        then
         poid_array(j) := NULL;
       end if;
       close c4;
     end if;
    end loop;
  end if;

  if poid_array.count = 0
   then
    -- No Data Found
    save_query;
    htp.tableclose;
    htp.nl;
    htp.bold( 'No Rows Found That Satisfy this Query' );
    htp.nl;
    htp.nl;
    htp.anchor( 'pfm.purchrep?surl=' || surl || '&template=' || mx, 'Return to Report Screen' );
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;
  end if;

  delete from advanced_query_temp_result_a;
  for j in poid_array.first..poid_array.last loop
   if poid_array(j) is not null
    then
     insert into advanced_query_temp_result_a(umo_id) select to_number(poid_array(j)) from dual where not exists (select 'x' from advanced_query_temp_result_a where umo_id = to_number(poid_array(j)));
   end if;
  end loop;

  begin srt1 := d3r; exception when others then null; end;
  begin srt2 := d3s; exception when others then null; end;
  begin srt3 := d3t; exception when others then null; end;

  brk := NULL;
  last_brk := NULL;
  foundrec := FALSE;

  for c3rec in c3(srt1,srt2,srt3) loop

   foundrec := TRUE;
   glbx.calculate_pricing( c3rec.poid, parm1, parm2 );

   open c3det(c3rec.sessid);
   fetch c3det into c3det_rec;
   close c3det;
   brk := NULL;
   hdr_txt := NULL;

   for j in d2.first..d2.last loop

    if d2(j) = 'A'
     then
      brk := brk || to_char(c3rec.date_created,'MON-YYYY');
      hdr_txt := hdr_txt || ' ' || to_char(c3rec.date_created,'Mon-YYYY');
    elsif d2(j) = 'B'
     then
      brk := brk || c3rec.status;
      hdr_txt := hdr_txt || ' ' || c3rec.status;
    elsif d2(j) = 'C'
     then
      if ltype in ('ADMIN','MANUFACTURER')
       then
        brk := brk || c3det_rec.p_username;
        hdr_txt := hdr_txt || ' ' || c3det_rec.business_name;
       else
        brk := brk || c3det_rec.ca_username;
        hdr_txt := hdr_txt || ' ' || c3det_rec.account_name;
      end if;
    elsif d2(j) = 'E'
     then
      brk := brk || c3rec.paid_method;
      hdr_txt := hdr_txt || ' ' || c3rec.paid_method;
    end if;
   end loop;

   if brk is null and last_brk is null
    then
     if c3%ROWCOUNT = 1
      then
       display_header(hdr_txt);
     end if;
   elsif brk is null and last_brk is not null
    then
     null;
   elsif brk is not null and last_brk is null
    then
      display_header(hdr_txt);

   else
    if brk <> last_brk
     then
      display_totals;
      dump_tc;
      dump_nl;
      if page_break
       then
        htp.p('<span style=''font-size:1.0pt;mso-bidi-font-size:10.0pt;font-family:Arial; mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman"; mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA''><br clear=all style=''mso-special-character:line-break;page-break-before:always''></span>');
      end if;
      dump_to( cattributes=>d5f );
      display_header(hdr_txt);
      ttl1 := 0;
      ttl2 := 0;
      ttl3 := 0;
      ttlg := 0;
      ttl4 := 0;
      ttl5 := 0;
      ttlag := 0;
      ttl6 := 0;
      ttl7 := 0;
      ttl8 := 0;
      ttl9 := 0;
    end if;
   end if;
   last_brk := brk;

   dump_tr;
   if mod(c3%ROWCOUNT,2) = 1
    then
     tmp := 'bgcolor="#' || d5d || '" ALIGN="LEFT" style="text-align: left; color: #' || d5fca || '; font-family: ' || fnt || '; background-color: #' || d5d || '"';
    else
     tmp := 'bgcolor="#' || d5e || '" ALIGN="LEFT" style="text-align: left; color: #' || d5fcb || '; font-family: ' || fnt || '; background-color: #' || d5e|| '"';
   end if;
   if mod(c3%ROWCOUNT,2) = 1
    then
     tmp2 := 'bgcolor="#' || d5d || '" ALIGN="RIGHT" style="text-align: right; color: #' || d5fca || '; font-family: ' || fnt || '; background-color: #' || d5d || '"';
    else
     tmp2 := 'bgcolor="#' || d5e || '" ALIGN="RIGHT" style="text-align: right; color: #' || d5fcb || '; font-family: ' || fnt || '; background-color: #' || d5e|| '"';
   end if;
   for j in d1.first..d1.last loop
    if d1(j) = 'Q'
     then
      dump_td( to_char(c3%ROWCOUNT) || htf.nl || ord.sbitemtotal(null, c3rec.poid), cattributes=>tmp2 || ' valign="TOP"' );
    elsif d1(j) = 'A'
     then
      if xdt = 'T' and dump_to_csv = 'F'
       then
        if ltype = 'ADMIN'
         then
          dump_td( htf.anchor2('adm.dispord?surl=' || surl || '&purchid=' || c3rec.poid,c3rec.poid,ctarget=>'X' || c3rec.poid), cattributes=>tmp );
        elsif ltype = 'PHOTOGRAPHER'
         then
          dump_td( htf.anchor2('ord.modify_order?surl=' || surl || '&purchord=' || c3rec.poid || '&acid=' || c3det_rec.acid || '&typ=' || LNG.GLB_TXT_092,c3rec.poid,ctarget=>'X' || c3rec.poid), cattributes=>tmp );
        elsif ltype = 'MANUFACTURER'
         then
          dump_td( htf.anchor2('lab.show_poid?surl=' || surl || '&vpoid=' || c3rec.poid || '&shp=',c3rec.poid,ctarget=>'X' || c3rec.poid), cattributes=>tmp );
        end if;
       else
        dump_td( c3rec.poid, cattributes=>tmp );
      end if;
    elsif d1(j) = 'U'
     then
      show_basket( c3rec.poid, fullu, tmp );
    elsif d1(j) = 'V'
     then
      show_workflow( c3rec.poid, fullv, tmp );
    elsif d1(j) = 'B'
     then
      dump_td( to_char(c3rec.date_created,LNG.TSMASK), cattributes=>tmp );
    elsif d1(j) = 'C'
     then
      -- account name
      if ltype in ('ADMIN','MANUFACTURER')
       then
        dump_td( c3det_rec.business_name || htf.nl || c3det_rec.account_name, cattributes=>tmp );
       else
        dump_td( c3det_rec.account_name, cattributes=>tmp );
      end if;
    elsif d1(j) = 'D'
     then
      dump_td( c3rec.sendto_firstname, cattributes=>tmp );
      dump_td( c3rec.sendto_lastname, cattributes=>tmp );
      if fullx = 'F'
       then
        dump_td( c3rec.sendto_street || htf.nl || c3rec.sendto_branch || ' ' || c3rec.sendto_department || htf.nl || c3rec.sendto_suburb || ' ' || c3rec.sendto_city || ' ' || c3rec.sendto_state || htf.nl || c3rec.sendto_country || ' ' || c3rec.sendto_postcode, cattributes=>tmp );
       else
        dump_td( c3rec.sendto_street, cattributes=>tmp );
        dump_td( c3rec.sendto_branch, cattributes=>tmp );
        dump_td( c3rec.sendto_department, cattributes=>tmp );
        dump_td( c3rec.sendto_suburb, cattributes=>tmp );
        dump_td( c3rec.sendto_city, cattributes=>tmp );
        dump_td( c3rec.sendto_state, cattributes=>tmp );
        dump_td( c3rec.sendto_country, cattributes=>tmp );
        dump_td( c3rec.sendto_postcode, cattributes=>tmp );
      end if;
    elsif d1(j) = 'S'
     then
      dump_td( c3rec.status, cattributes=>tmp );
    elsif d1(j) = 'E'
     then
      dump_td( c3rec.paid_method, cattributes=>tmp );

    elsif d1(j) = 'F'
     then
      -- Amount Gross
      val := nvl(round(glbx.retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 ),2),0);
      ttl1 := nvl(ttl1,0) + nvl(val,0);
      gttl1 := nvl(gttl1,0) + nvl(val,0);
      v1 := nvl(glbx.retrieve_pricing_value( 'GST_VALUE', parm1, parm2 ),0);
      v2 := nvl(glbx.retrieve_pricing_value( 'GST_INCLUSIVE', parm1, parm2 ),0);
      if v2 > v1 then vgst := v2; vmsg := '(Incl)'; else vgst := v1; vmsg := '(Added)'; end if;
      if vgst = 0 then vmsg := NULL; end if;
      ttlg := nvl(ttlg,0) + nvl(vgst,0);
      gttlg := nvl(gttlg,0) + nvl(vgst,0);
      if fullf = 'F'
       then
        dump_td( to_char(val,LNG.MONEY_FORMAT), cattributes=>tmp2 );
       else
        dump_td( to_char(val,LNG.MONEY_FORMAT) || htf.nl ||
                       'GST:' ||  vmsg ||  to_char(vgst,LNG.MONEY_FORMAT) ||
                       '(' || to_char(glbx.retrieve_pricing_value( 'GST', parm1, parm2 )) || '%)' || htf.nl ||
                       'Certificate:' || to_char(glbx.retrieve_pricing_value('CERTIFICATE_TOTAL', parm1, parm2 ),LNG.MONEY_FORMAT) || htf.nl ||
                       'Refund: ' || to_char(glbx.retrieve_pricing_value( 'REFUND', parm1, parm2 ),LNG.MONEY_FORMAT), cattributes=>replace(tmp,'text-align:','font-size: xx-small; text-align:') );
      end if;

    elsif d1(j) = 'G'
     then
      -- Shipping
      val := nvl(round(glbx.retrieve_pricing_value( 'POSTAGE', parm1, parm2 ),2),0);
      ttl2 := nvl(ttl2,0) + nvl(val,0);
      gttl2 := nvl(gttl2,0) + nvl(val,0);
      if fullg = 'F'
       then
        if nvl(c3rec.manual_ship,'F') = 'F'
         then
          dump_td( to_char(val,LNG.MONEY_FORMAT), cattributes=>tmp2 );
         else
          dump_td( 'Manual Shipment', cattributes=>tmp2 );
        end if;
       else
        if nvl(c3rec.manual_ship,'F') = 'F'
         then
          dump_td( to_char(val,LNG.MONEY_FORMAT) || htf.nl ||
                   'Surcharge:' || to_char(nvl(glbx.retrieve_pricing_value( 'SURCHARGE', parm1, parm2 ),0),LNG.MONEY_FORMAT) || htf.nl ||
                   'Postage:' || to_char(nvl(glbx.retrieve_pricing_value( 'POSTAGE', parm1, parm2 ),0),LNG.MONEY_FORMAT), cattributes=>replace(tmp,'text-align:','font-size: xx-small; text-align:') );
         else
          dump_td( to_char(val,LNG.MONEY_FORMAT) || htf.nl ||
                   'Surcharge:' || to_char(nvl(glbx.retrieve_pricing_value( 'SURCHARGE', parm1, parm2 ),0),LNG.MONEY_FORMAT) || htf.nl ||
                   'Postage:' || 'Manual Shipment', cattributes=>replace(tmp,'text-align:','font-size: xx-small; text-align:') );
        end if;
      end if;

    elsif d1(j) = 'H'
     then
      -- Net Revenue
      val := nvl(round(glbx.retrieve_pricing_value( 'SUB_TOTAL1', parm1, parm2 ),2),0) -
             ( nvl(round(glbx.retrieve_pricing_value( 'POSTAGE', parm1, parm2 ),2),0) + nvl(round(glbx.retrieve_pricing_value( 'SURCHARGE', parm1, parm2 ),2),0));
      ttl3 := nvl(ttl3,0) + nvl(val,0);
      gttl3 := nvl(gttl3,0) + nvl(val,0);
      if fullh = 'F'
       then
        dump_td( to_char(val,LNG.MONEY_FORMAT), cattributes=>tmp2 );
       else
        dump_td( to_char(val,LNG.MONEY_FORMAT) || htf.nl ||
                       'Discount Amount:' || to_char(nvl(glbx.retrieve_pricing_value( 'DISCOUNT', parm1, parm2 ),0),LNG.MONEY_FORMAT) || htf.nl ||
                       'Discount:' || to_char(glbx.retrieve_pricing_value( 'PHG_DISCOUNT', parm1, parm2 )) || '%' || htf.nl ||
                       'Special Discount:' || to_char(glbx.retrieve_pricing_value( 'SPECIAL_DISCOUNT', parm1, parm2 )) || '%' || htf.nl ||
                       'Additional Options:' || to_char(glbx.retrieve_pricing_value( 'ADDITIONAL_OPTIONS', parm1, parm2 ),LNG.MONEY_FORMAT), cattributes=>replace(tmp,'text-align:','font-size: xx-small; text-align:') );
      end if;

    elsif d1(j) = 'W'
     then
      -- Additional Options
      val := glbx.retrieve_pricing_value( 'ADDITIONAL_OPTIONS', parm1, parm2 );
      ttl9 := nvl(ttl9,0) + nvl(val,0);
      gttl9 := nvl(gttl9,0) + nvl(val,0);
      if fullw = 'F'
       then
        dump_td( to_char(val,LNG.MONEY_FORMAT), cattributes=>tmp2 );
       else
        addopt( c3rec.poid );
      end if;

    elsif d1(j) = 'I'
     then
      -- Supplier Cost
      val := nvl(round(glbx.retrieve_pricing_value( 'LAB_GETS', parm1, parm2 ),2),0);
      ttl4 := nvl(ttl4,0) + nvl(val,0);
      gttl4 := nvl(gttl4,0) + nvl(val,0);
      if fulli = 'F'
       then
        dump_td( to_char(val,LNG.MONEY_FORMAT), cattributes=>tmp2 );
       else
        dump_td( to_char(val,LNG.MONEY_FORMAT) || htf.nl || 'Mfctr Postage:' || to_char(glbx.retrieve_pricing_value( 'LAB_POSTAGE', parm1, parm2 )) || htf.nl ||
                       'Mfctr Extra:' || to_char(glbx.retrieve_pricing_value( 'LAB_EXTRA_COST', parm1, parm2 ),LNG.MONEY_FORMAT), cattributes=>replace(tmp,'text-align:','font-size: xx-small; text-align:') );
      end if;
    elsif d1(j) = 'J'
     then
      -- Royalty %
      val := nvl(round(glbx.retrieve_pricing_value( 'COMMISSION', parm1, parm2 ),2),0);
      ttl5 := nvl(ttl5,0) + nvl(val,0);
      gttl5 := nvl(gttl5,0) + nvl(val,0);
      ttlag := nvl(ttlag,0) + nvl(glbx.retrieve_pricing_value( 'TAX', parm1, parm2 ),0);
      gttlag := nvl(gttlag,0) + nvl(glbx.retrieve_pricing_value( 'TAX', parm1, parm2 ),0);
      if fullj = 'F'
       then
        dump_td( to_char(val,LNG.MONEY_FORMAT), cattributes=>tmp2 );
       else
        dump_td( to_char(val,LNG.MONEY_FORMAT) || htf.nl ||
                 'Royalty' || ':' || glbx.retrieve_pricing_value( 'ADMIN_ROYALTY', parm1, parm2 ) ||'%' || htf.nl ||
                 'GST' || ':' ||  vmsg || to_char(nvl(glbx.retrieve_pricing_value( 'TAX', parm1, parm2 ),0),LNG.MONEY_FORMAT) || '(' || glbx.retrieve_pricing_value( 'ADMIN_GST', parm1, parm2 ) ||'%)', cattributes=>replace(tmp,'text-align:','font-size: xx-small; text-align:') );
      end if;
    elsif d1(j) = 'K'
     then
      -- Merchant %
      val := nvl(round(glbx.retrieve_pricing_value( 'HANDLING', parm1, parm2 ),2),0);
      ttl6 := nvl(ttl6,0) + nvl(val,0);
      gttl6 := nvl(gttl6,0) + nvl(val,0);
      if fullk = 'F'
       then
        dump_td( to_char(val,LNG.MONEY_FORMAT), cattributes=>tmp2 );
       else
        dump_td( to_char(val,LNG.MONEY_FORMAT) || htf.nl || glbx.retrieve_pricing_value( 'HANDLING_PERC', parm1, parm2 ) || '%', cattributes=>replace(tmp2,'text-align:','font-size: xx-small; text-align:') );
      end if;

    elsif d1(j) = 'T'
     then
       -- Net Revenue after Service Charges
       -- Amount Gross - Shipping, - Royalty, - Merchant
      val := nvl(round(glbx.retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 ),2),0);
      val := val - nvl(round(glbx.retrieve_pricing_value( 'POSTAGE', parm1, parm2 ),2),0);
      val := val - nvl(round(glbx.retrieve_pricing_value( 'SURCHARGE', parm1, parm2 ),2),0);
      val := val - nvl(round(glbx.retrieve_pricing_value( 'LAB_GETS', parm1, parm2 ),2),0);
      val := val - nvl(round(glbx.retrieve_pricing_value( 'COMMISSION', parm1, parm2 ),2),0);
      ttl8 := nvl(ttl8,0) + nvl(val,0);
      gttl8 := nvl(gttl8,0) + nvl(val,0);
      if fullt = 'F'
       then
        dump_td( to_char(val,LNG.MONEY_FORMAT), cattributes=>tmp2 );
       else
        dump_td( 'Order Total:' || to_char(nvl(round(glbx.retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 ),2),0),LNG.MONEY_FORMAT) || htf.nl ||
                 '- Postage:' || to_char(nvl(round(glbx.retrieve_pricing_value( 'POSTAGE', parm1, parm2 ),2),0),LNG.MONEY_FORMAT) || htf.nl ||
                 '- Surcharge:' || to_char(nvl(round(glbx.retrieve_pricing_value( 'SURCHAGE', parm1, parm2 ),2),0),LNG.MONEY_FORMAT) || htf.nl ||
                 '- Mfctr:' || to_char(nvl(round(glbx.retrieve_pricing_value( 'LAB_GETS', parm1, parm2 ),2),0),LNG.MONEY_FORMAT) || htf.nl ||
                 '- Commission:' || to_char(nvl(round(glbx.retrieve_pricing_value( 'COMMISSION', parm1, parm2 ),2),0),LNG.MONEY_FORMAT) || htf.nl ||
                 ' Net Total:' || to_char(val,LNG.MONEY_FORMAT), cattributes=>replace(tmp2,'text-align:','font-size: xx-small; text-align:') );
      end if;

    end if;

   end loop;

   if r1 = 'T'
    then
     display_reconcile( c3rec, tmp, glbx.retrieve_pricing_value( 'GRAND_TOTAL_NOCERT', parm1, parm2 ) );
   end if;
  dump_trc;
  end loop;

  if foundrec then display_totals; end if;

  if foundrec then display_grandtotal; end if;

 dump_tc;


 -- Display Reconcilliation Exception Report
 if r2 = 'T' and ltype = 'ADMIN'
  then
   -- The following Transactions do not have owners
   dump_nl;
   htp.bold( 'Reconcilliation Exception Report' );
   dump_to( cattributes=>d5f );
   dump_tr;
    tmp := 'bgcolor="#' || d5a || '" ALIGN="CENTER" style="text-align: center; font-family: ' || fnt || '; color: #' || d5af || '; background-color: #' || d5a || '"';
    dump_th( 'Transaction ID', cattributes=>tmp );
    dump_th( 'Purchase Order Details', cattributes=>tmp );
    dump_th( 'Timestamp', cattributes=>tmp );
    dump_th( 'Total', cattributes=>tmp );
    dump_th( 'Return Code', cattributes=>tmp );
    dump_th( 'Refunded', cattributes=>tmp );
   dump_trc;
   ttl1 := 0;
   for c6rec in c6(date1,date2) loop
    if mod(c6%ROWCOUNT,2) = 1
     then
      tmp := 'bgcolor="#' || d5d || '" ALIGN="LEFT" style="text-align: left; font-family: ' || fnt || '; background-color: #' || d5d || '"';
     else
      tmp := 'bgcolor="#' || d5e || '" ALIGN="LEFT" style="text-align: left; font-family: ' || fnt || '; background-color: #' || d5e|| '"';
    end if;
    if mod(c6%ROWCOUNT,2) = 1
     then
      tmp2 := 'bgcolor="#' || d5d || '" ALIGN="RIGHT" style="text-align: right; font-family: ' || fnt || '; background-color: #' || d5d || '"';
     else
      tmp2 := 'bgcolor="#' || d5e || '" ALIGN="RIGHT" style="text-align: right; font-family: ' || fnt || '; background-color: #' || d5e|| '"';
    end if;
    dump_tr;
     dump_td( c6rec.transaction_id, cattributes=>tmp );
     dump_td( c6rec.purchase_order_details, cattributes=>tmp );
     dump_td( to_char(c6rec.transaction_timestamp,LNG.TSMASK), cattributes=>tmp );
     dump_td( to_char(c6rec.transaction_total,LNG.MONEY_FORMAT), cattributes=>tmp2 );
     ttl1 := nvl(ttl1,0) + c6rec.transaction_total;
     dump_td( c6rec.return_code, cattributes=>tmp );
     dump_td( c6rec.extra_col_1, cattributes=>tmp );
    dump_trc;
   end loop;
   dump_tr;
    tmp := 'bgcolor="#' || d5a || '" ALIGN="CENTER" style="text-align: center; font-family: ' || fnt || '; color: #' || d5af || '; background-color: #' || d5a || '"';
    dump_th( '&nbsp;', cattributes=>tmp );
    dump_th( '&nbsp;', cattributes=>tmp );
    dump_th( htf.bold(d4m), cattributes=>tmp );
    dump_th( htf.bold(to_char(ttl1,LNG.MONEY_FORMAT)), cattributes=>tmp );
    dump_th( '&nbsp;', cattributes=>tmp );
    dump_th( '&nbsp;', cattributes=>tmp );
   dump_trc;
   dump_tc;
   dump_nl;
 end if;

 if d4img is not null and dump_to_csv = 'F'
  then
   htp.nl;
   htp.img( DECS.IMAGE_LOCATION || 'site_specific/' || d4img,cattributes=>' border=0', calt=>NULL);
   htp.nl;
 end if;

 save_query;

 if csv = 'T' and dump_to_csv = 'F'
  then
   htp.nl;
   htp.nl;
   htp.anchor( 'pfm.run_purchrep?surl=' || surl || '&id=' || mx || '&dump_to_csv=T', 'Extract Data to a CSV File' );
   htp.nl;
   htp.nl;
 end if;

 if dspt = 'T' and dump_to_csv = 'F'
  then
   if mx is null and template2 is not null
    then
     mx := template2;
   end if;
   htp.nl;
   htp.anchor( 'pfm.purchrep?surl=' || surl || '&template=' || mx, 'Return to Report Screen' );
   htp.nl;
 end if;

 if dump_to_csv = 'F' then htp.p( '</CENTER>' ); htp.p( '</BODY>'); htp.htmlclose; end if;

exception when others then
 htp.bold( stmt );
 glbx.error_details( 'PFM', 'ACCEPT_PURCHREP', owner_id, errmsg=>sqlerrm );
end accept_purchrep;

procedure del_purchrep( surl in varchar2, id in integer )
as

 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.adm_cookie_id( surl, sessid, sts, 'PFM.DEL_PURCHREP');
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.DEL_PURCHREP', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   stype := 1;
   ltype := 'ADMIN';
 end if;

 delete from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(owner_id,0) and prt_id = id;
 if sql%FOUND
  then
   purchrep( surl, 'Template Deleted' );
  else
   purchrep( surl, 'Template Not Found' );
 end if;

 commit;

exception when others then
 glbx.error_details( 'PFM', 'DEL_PURCHREP', owner_id, errmsg=>sqlerrm );
end del_purchrep;

procedure run_purchrep( surl in varchar2, id in integer, dump_to_csv in char default 'F' )
as

 cursor c1( ltype varchar2, lid integer, id integer ) is select * from purchase_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and prt_id = id;

 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(32767);

begin
 glbx.adm_cookie_id( surl, sessid, sts, 'PFM.RUN_PURCHREP');
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.RUN_PURCHREP', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   stype := 1;
   ltype := 'ADMIN';
 end if;

 tmp := '&action=&template=&template2=' || id || '&dump_to_csv=' || dump_to_csv;
 for c1rec in c1(ltype, owner_id, id) loop
  tmp := tmp || '&' || c1rec.param_name || '=' || replace(replace(replace(c1rec.param_value,' ','+'),'"','&#34;'),'%','%25');
 end loop;
 tmp := 'pfm.accept_purchrep?surl=' || surl || tmp;

 owa_util.redirect_url( tmp );

exception when others then
 glbx.error_details( 'PFM', 'RUN_PURCHREP', owner_id, errmsg=>sqlerrm );
end run_purchrep;

procedure imgrep( surl in varchar2, msg in varchar2 default null, template in varchar2 default null )
as

 cursor c1( phgid integer ) is select aid,username,account_name from customer_account where pid = phgid order by account_name;
 cursor c2 is select pid,username,business_name from photographer order by business_name;
 cursor c3( manid integer ) is select p.pid,p.username,p.business_name from photographer p, manufacturer_photographer mp where mp.manufacturer_id = manid and mp.pid = p.pid order by business_name;
 cursor c1t( phgid integer ) is select count('x') tot from customer_account where pid = phgid order by account_name;
 cursor c2t is select count('x') tot from photographer order by business_name;
 cursor c3t( manid integer ) is select count('x') tot from photographer p, manufacturer_photographer mp where mp.manufacturer_id = manid and mp.pid = p.pid order by business_name;
 cursor c4 is select clr_hex, clr_name from colours order by clr_name;
 cursor c5 is select manufacturer_id, name, username from manufacturer order by name;
 cursor c6( phgid integer ) is select m.name, m.manufacturer_id from manufacturer_photographer mp, manufacturer m where pid = phgid and mp.manufacturer_id = m.manufacturer_id order by m.name;
 cursor c7 is select order_option from workflow_state_options where work_state = 0 order by order_by;
 cursor c8 is select font_name from fonts order by font_name;
 cursor c9( ltype varchar2, lid integer ) is select distinct irt_id, irt_name from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0);
 cursor c10( tempid integer, ltype varchar2, lid integer ) is select distinct irt_name from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and irt_id = tempid;

 c10rec		c10%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 foundrec	boolean;
 highrec	boolean;
 vtot		integer;
 sts		varchar2(100);
 brk		varchar2(10000);
 pfx		THEME%ROWTYPE;

 function extr1( tmp integer, ltype varchar2, lid integer, pname varchar2, pvalue varchar2, defval in boolean default FALSE )
 return boolean
 as
  cursor c1( tmp integer, ltype varchar2, lid integer, pname varchar2, pvalue varchar2 ) is select 'x' exst from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and irt_id = tmp and param_name = pname and param_value = pvalue;
  c1rec  c1%ROWTYPE;
 begin
  if tmp is null then return( defval ); end if;
  open c1(tmp, ltype, lid, pname, pvalue );
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    return( TRUE );
   else
    close c1;
    return( FALSE );
  end if;
 end extr1;

 function extr2( tmp integer, ltype varchar2, lid integer, pname varchar2, defval in varchar2 default null )
 return varchar2
 as
  cursor c1( tmp integer, ltype varchar2, lid integer, pname varchar2 ) is select param_value from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and irt_id = tmp and param_name = pname;
  c1rec  c1%ROWTYPE;
 begin
  if tmp is null then return( defval ); end if;
  open c1(tmp, ltype, lid, pname );
  fetch c1 into c1rec;
  close c1;
  return( c1rec.param_value );
 end extr2;

 function extr3( tmp integer, ltype varchar2, lid integer, pname varchar2 )
 return varchar2
 as
  cursor c1( tmp integer, ltype varchar2, lid integer, pname varchar2 ) is select param_value from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and irt_id = tmp and param_name = pname;
  c1rec  c1%ROWTYPE;
 begin
  if tmp is null then return( NULL ); end if;
  open c1(tmp, ltype, lid, pname );
  fetch c1 into c1rec;
  close c1;
  if c1rec.param_value = 'T'
   then
    return( 'CHECKED' );
   else
    return( NULL );
  end if;
 end extr3;

 function extr4( tmp integer, ltype varchar2, lid integer, pname varchar2, pvalue varchar2 )
 return varchar2
 as
  cursor c1( tmp integer, ltype varchar2, lid integer, pname varchar2, pvalue varchar2 ) is select 'x' exst from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and irt_id = tmp and param_name = pname and param_value = pvalue;
  c1rec  c1%ROWTYPE;
 begin
  if tmp is null then return( NULL ); end if;
  open c1(tmp, ltype, lid, pname, pvalue );
  fetch c1 into c1rec;
  if c1%FOUND
   then
    close c1;
    return( 'SELECTED' );
   else
    close c1;
    return( NULL );
  end if;
 end extr4;

begin
 glbx.adm_cookie_id( surl, sessid, sts, 'PFM.IMGREP');
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.IMGREP', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   stype := 1;
   ltype := 'ADMIN';
 end if;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, 'Image Details Enquiry Screen', glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P79', stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Purchase Order Enquiry Screen' );
 if msg is not null then glbx.header_msg( msg );end if;
 htp.p( '<CENTER>' );
 if template is not null
  then
   open c10(template, ltype, owner_id);
   fetch c10 into c10rec;
   close c10;
 end if;

 htp.formopen( 'pfm.accept_imgrep' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P4', NULL );
 htp.formhidden( 'D1', NULL );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( htf.bold('Search for all Accounts that Match the Following Criteria'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   if ltype = 'PHOTOGRAPHER'
    then
     htp.tabledata( 'Customer Account', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
    else
     htp.tabledata( 'Client Account', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   end if;
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'P1', null, 5, cattributes=>'MULTIPLE' );
   if ltype = 'ADMIN'
    then
     highrec := FALSE;
     open c2t;
     fetch c2t into vtot;
     close c2t;
     if vtot = 1 then highrec := TRUE; end if;
     for c2rec in c2 loop
      if extr1( template, ltype, owner_id, 'P1', c2rec.pid ) or highrec
       then
        highrec := FALSE;
        htp.formselectoption( c2rec.business_name || ' (' || c2rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c2rec.pid || '"' );
       else
        htp.formselectoption( c2rec.business_name || ' (' || c2rec.username || ')', cattributes=>'VALUE="' || c2rec.pid || '"' );
      end if;
     end loop;
   elsif ltype = 'MANUFACTURER'
    then
     highrec := FALSE;
     open c3t(owner_id);
     fetch c3t into vtot;
     close c3t;
     if vtot = 1 then highrec := TRUE; end if;
     for c3rec in c3(owner_id) loop
      if extr1( template, ltype, owner_id, 'P1', c3rec.pid ) or highrec
       then
        highrec := FALSE;
        htp.formselectoption( c3rec.business_name || ' (' || c3rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c3rec.pid || '"' );
       else
        htp.formselectoption( c3rec.business_name || ' (' || c3rec.username || ')', cattributes=>'VALUE="' || c3rec.pid || '"' );
      end if;
     end loop;
   elsif ltype = 'PHOTOGRAPHER'
    then
     highrec := FALSE;
     open c1t(owner_id);
     fetch c1t into vtot;
     close c1t;
     if vtot = 1 then highrec := TRUE; end if;
     for c1rec in c1(owner_id) loop
      if extr1( template, ltype, owner_id, 'P1', c1rec.aid ) or highrec
       then
        highrec := FALSE;
        htp.formselectoption( c1rec.account_name || ' (' || c1rec.username || ')', 'SELECTED', cattributes=>'VALUE="' || c1rec.aid || '"' );
       else
        htp.formselectoption( c1rec.account_name || ' (' || c1rec.username || ')', cattributes=>'VALUE="' || c1rec.aid || '"' );
      end if;
     end loop;
   end if;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Image Name Matches' || ' ' ||  '(% or * is a wildcard)', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P2', 50, 100, extr2( template, ltype, owner_id, 'P2' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Caption Matches' || ' ' ||  '(% or * is a wildcard)', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'P3', 50, 100, extr2( template, ltype, owner_id, 'P3' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Date From', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( 'DD (Day)' || htf.formtext( 'P8A', 5, 5, extr2( template, ltype, owner_id, 'P8A' ) ) || ' Month (eg JUL)' || htf.formtext( 'P8B', 5, 5, extr2( template, ltype, owner_id, 'P8B' ) ) || ' Year (eg. 2002)' || htf.formtext( 'P8C', 5, 5, extr2( template, ltype, owner_id, 'P8C' ) ) , cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Date To', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( 'DD (Day)' || htf.formtext( 'P9A', 5, 5, extr2( template, ltype, owner_id, 'P9A' ) ) || ' Month (eg JUL)' || htf.formtext( 'P9B', 5, 5, extr2( template, ltype, owner_id, 'P9B' ) ) || ' Year (eg. 2002)' || htf.formtext( 'P9C', 5, 5, extr2( template, ltype, owner_id, 'P9C' ) ) , cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Image Type', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'P4', null, 3, cattributes=>'MULTIPLE' );
    if extr1( template, ltype, owner_id, 'P4', 'PHOTO', TRUE )
     then
      htp.formselectoption( 'PHOTO', 'SELECTED' );
    else
      htp.formselectoption( 'PHOTO' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'DOCUMENT', TRUE )
     then
      htp.formselectoption( 'DOCUMENT', 'SELECTED' );
    else
      htp.formselectoption( 'DOCUMENT' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'VIDEO', TRUE )
     then
      htp.formselectoption( 'VIDEO', 'SELECTED' );
    else
      htp.formselectoption( 'VIDEO' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'AUDIO', TRUE )
     then
      htp.formselectoption( 'AUDIO', 'SELECTED' );
    else
      htp.formselectoption( 'AUDIO' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'RELATIONAL', TRUE )
     then
      htp.formselectoption( 'RELATIONAL', 'SELECTED' );
    else
      htp.formselectoption( 'RELATIONAL' );
    end if;
    if extr1( template, ltype, owner_id, 'P4', 'BLUEPRINT', TRUE )
     then
      htp.formselectoption( 'BLUEPRINT', 'SELECTED' );
    else
      htp.formselectoption( 'BLUEPRINT' );
    end if;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( 'Display Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  -- Columns to Display
  htp.tablerowopen;
   htp.tabledata( 'Columns/Information to Display', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'D1', null, 10, cattributes=>'MULTIPLE' );
     if extr1( template, ltype, owner_id, 'D1', 'Q', TRUE )
      then
       htp.formselectoption( 'Line No', 'SELECTED', cattributes=>'VALUE="Q"' );
      else
       htp.formselectoption( 'Line No', cattributes=>'VALUE="Q"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'A', FALSE )
      then
       htp.formselectoption( 'UMO ID', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'UMO ID', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'I', TRUE )
      then
       htp.formselectoption( 'Category', 'SELECTED', cattributes=>'VALUE="I"' );
      else
       htp.formselectoption( 'Category', cattributes=>'VALUE="I"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'U', FALSE )
      then
       htp.formselectoption( 'Caption', 'SELECTED', cattributes=>'VALUE="U"' );
      else
       htp.formselectoption( 'Caption', cattributes=>'VALUE="U"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'B', TRUE )
      then
       htp.formselectoption( 'Date / Time', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Date / Time', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'C', TRUE )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'W', TRUE )
      then
       htp.formselectoption( 'Image Details', 'SELECTED', cattributes=>'VALUE="W"' );
      else
       htp.formselectoption( 'Image Details', cattributes=>'VALUE="W"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'V', TRUE )
      then
       htp.formselectoption( 'Statistics', 'SELECTED', cattributes=>'VALUE="V"' );
      else
       htp.formselectoption( 'Statistics', cattributes=>'VALUE="V"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'D', TRUE )
      then
       htp.formselectoption( 'Purchase Details', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'Purchase Details', cattributes=>'VALUE="D"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'E', FALSE )
      then
       htp.formselectoption( 'Image Type', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Image Type', cattributes=>'VALUE="E"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'S', FALSE )
      then
       htp.formselectoption( 'Sort Number', 'SELECTED', cattributes=>'VALUE="S"' );
      else
       htp.formselectoption( 'Sort Number', cattributes=>'VALUE="S"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'F', TRUE )
      then
       htp.formselectoption( 'Image Pricing', 'SELECTED', cattributes=>'VALUE="F"' );
      else
       htp.formselectoption( 'Image Pricing', cattributes=>'VALUE="F"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'G', FALSE )
      then
       htp.formselectoption( 'Greeting Card', 'SELECTED', cattributes=>'VALUE="G"' );
      else
       htp.formselectoption( 'Greeting Card', cattributes=>'VALUE="G"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'H', FALSE )
      then
       htp.formselectoption( 'FTP Details', 'SELECTED', cattributes=>'VALUE="H"' );
      else
       htp.formselectoption( 'FTP Details', cattributes=>'VALUE="H"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'J', FALSE )
      then
       htp.formselectoption( 'Thesaurus', 'SELECTED', cattributes=>'VALUE="J"' );
      else
       htp.formselectoption( 'Thesaurus', cattributes=>'VALUE="J"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'K', TRUE )
      then
       htp.formselectoption( 'Enabled', 'SELECTED', cattributes=>'VALUE="K"' );
      else
       htp.formselectoption( 'Enabled', cattributes=>'VALUE="K"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'T', FALSE )
      then
       htp.formselectoption( 'Original Location', 'SELECTED', cattributes=>'VALUE="T"' );
      else
       htp.formselectoption( 'Original Location', cattributes=>'VALUE="T"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'L', FALSE )
      then
       htp.formselectoption( 'Repeating Field Values', 'SELECTED', cattributes=>'VALUE="L"' );
      else
       htp.formselectoption( 'Repeating Field Values', cattributes=>'VALUE="L"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'R', FALSE )
      then
       htp.formselectoption( 'Exclusivity', 'SELECTED', cattributes=>'VALUE="R"' );
      else
       htp.formselectoption( 'Exclusivity', cattributes=>'VALUE="R"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'X', FALSE )
      then
       htp.formselectoption( 'Vote', 'SELECTED', cattributes=>'VALUE="X"' );
      else
       htp.formselectoption( 'Vote', cattributes=>'VALUE="X"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'M', TRUE )
      then
       htp.formselectoption( 'Logo', 'SELECTED', cattributes=>'VALUE="M"' );
      else
       htp.formselectoption( 'Logo', cattributes=>'VALUE="M"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'N', TRUE )
      then
       htp.formselectoption( 'Client Name as Header', 'SELECTED', cattributes=>'VALUE="N"' );
      else
       htp.formselectoption( 'Client Name as Header', cattributes=>'VALUE="N"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'O', TRUE )
      then
       htp.formselectoption( 'Date', 'SELECTED', cattributes=>'VALUE="O"' );
      else
       htp.formselectoption( 'Date', cattributes=>'VALUE="O"' );
     end if;
     if extr1( template, ltype, owner_id, 'D1', 'P', TRUE )
      then
       htp.formselectoption( 'Embed HTML Page Breaks (IE6.0 + Only)', 'SELECTED', cattributes=>'VALUE="P"' );
      else
       htp.formselectoption( 'Embed HTML Page Breaks (IE6.0 + Only)', cattributes=>'VALUE="P"' );
     end if;
    htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  -- Sort On
  htp.tablerowopen;
   htp.tabledata( 'Sort On', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
    htp.formselectopen( 'D3R' );
     if extr1( template, ltype, owner_id, 'D3R', 'A', TRUE )
      then
       htp.formselectoption( 'UMO ID', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'UMO ID', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'B', TRUE )
      then
       htp.formselectoption( 'Date Created', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Date Created', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'C', TRUE )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'D' )
      then
       htp.formselectoption( 'Image Name', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'Image Name', cattributes=>'VALUE="D"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'E' )
      then
       htp.formselectoption( 'Sort Number', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Sort Number', cattributes=>'VALUE="E"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3R', 'F' )
      then
       htp.formselectoption( 'Category', 'SELECTED', cattributes=>'VALUE="F"' );
      else
       htp.formselectoption( 'Category', cattributes=>'VALUE="F"' );
     end if;
    htp.formselectclose;

    htp.nl;
    htp.formselectopen( 'D3S' );
     htp.formselectoption( NULL );
     if extr1( template, ltype, owner_id, 'D3S', 'A', TRUE )
      then
       htp.formselectoption( 'UMO ID', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'UMO ID', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'B', TRUE )
      then
       htp.formselectoption( 'Date Created', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Date Created', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'C', TRUE )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'D' )
      then
       htp.formselectoption( 'Image Name', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'Image Name', cattributes=>'VALUE="D"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'E' )
      then
       htp.formselectoption( 'Sort Number', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Sort Number', cattributes=>'VALUE="E"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3S', 'F' )
      then
       htp.formselectoption( 'Category', 'SELECTED', cattributes=>'VALUE="F"' );
      else
       htp.formselectoption( 'Category', cattributes=>'VALUE="F"' );
     end if;
    htp.formselectclose;

    htp.nl;
    htp.formselectopen( 'D3T' );
     htp.formselectoption( NULL );
     if extr1( template, ltype, owner_id, 'D3T', 'A', TRUE )
      then
       htp.formselectoption( 'UMO ID', 'SELECTED', cattributes=>'VALUE="A"' );
      else
       htp.formselectoption( 'UMO ID', cattributes=>'VALUE="A"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'B', TRUE )
      then
       htp.formselectoption( 'Date Created', 'SELECTED', cattributes=>'VALUE="B"' );
      else
       htp.formselectoption( 'Date Created', cattributes=>'VALUE="B"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'C', TRUE )
      then
       htp.formselectoption( 'Account Name', 'SELECTED', cattributes=>'VALUE="C"' );
      else
       htp.formselectoption( 'Account Name', cattributes=>'VALUE="C"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'D' )
      then
       htp.formselectoption( 'Image Name', 'SELECTED', cattributes=>'VALUE="D"' );
      else
       htp.formselectoption( 'Image Name', cattributes=>'VALUE="D"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'E' )
      then
       htp.formselectoption( 'Sort Number', 'SELECTED', cattributes=>'VALUE="E"' );
      else
       htp.formselectoption( 'Sort Number', cattributes=>'VALUE="E"' );
     end if;
     if extr1( template, ltype, owner_id, 'D3T', 'F' )
      then
       htp.formselectoption( 'Category', 'SELECTED', cattributes=>'VALUE="F"' );
      else
       htp.formselectoption( 'Category', cattributes=>'VALUE="F"' );
     end if;
    htp.formselectclose;

   htp.p( '</TD>' );
  htp.tablerowclose;

  -- Column Titles
  -- Heading Colours
  -- Summary Colours
  -- HTML Table Definition
  htp.tablerowopen;
   htp.tabledata( htf.bold('Display Colours and HTML Definitions'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Header Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5A' );
    for c4rec in c4 loop
     if template is null
      then
       if pfx.title_text_colour like '%' || c4rec.clr_hex || '%'
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5A', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Header Font Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5AF' );
    for c4rec in c4 loop
     if template is null
      then
       if pfx.title_colour_font like '%' || c4rec.clr_hex || '%'
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5AF', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Background Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5C' );
    for c4rec in c4 loop
     if template is null
      then
       if c4rec.clr_hex = pfx.text_back
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5C', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Cell Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5D' );
    for c4rec in c4 loop
      if template is null
       then
       if c4rec.clr_hex = pfx.vert_colour_a
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5D', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Cell Font Colour', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5FCA' );
    for c4rec in c4 loop
      if template is null
       then
       if c4rec.clr_hex = pfx.text_colour
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5FCA', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Cell Colour Alt', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5E' );
    for c4rec in c4 loop
     if template is null
      then
       if c4rec.clr_hex = pfx.vert_colour_b
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5E', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Cell Font Colour Alt', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'D5FCB' );
    for c4rec in c4 loop
      if template is null
       then
       if c4rec.clr_hex = pfx.text_colour
        then
         htp.formselectoption( c4rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
        else
         htp.formselectoption( c4rec.clr_name, cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
       end if;
     else
       htp.formselectoption( c4rec.clr_name, extr4( template, ltype, owner_id, 'D5FCB', c4rec.clr_hex ), cattributes=>'VALUE="' || c4rec.clr_hex || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Font', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.p( '<TD ' || pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT">' );
   htp.formselectopen( 'FNT' );
    for c8rec in c8 loop
     if template is null
      then
       if c8rec.font_name = pfx.text_font
        then
         htp.formselectoption( c8rec.font_name, 'SELECTED', cattributes=>'VALUE="' || c8rec.font_name || '"' );
        else
         htp.formselectoption( c8rec.font_name, cattributes=>'VALUE="' || c8rec.font_name || '"' );
       end if;
     else
       htp.formselectoption( c8rec.font_name, extr4( template, ltype, owner_id, 'FNT', c8rec.font_name ), cattributes=>'VALUE="' || c8rec.font_name || '"' );
     end if;
    end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Adjust Font By', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'FSIZE', 10, 20, extr2( template, ltype, owner_id, 'FSIZE','0' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'HTML Table Definition', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D5F', 50, 1000, extr2( template, ltype, owner_id, 'D5F','cellpadding=2 cellspacing=2 border=1' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

  -- Column Titles
  htp.tablerowopen;
   htp.tabledata( htf.bold('Header and Column Titles'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT" COLSPAN="2"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Report Title', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4Z', 30, 100, extr2( template, ltype, owner_id, 'D4Z','Image Request Report' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Line No', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4N', 30, 100, extr2( template, ltype, owner_id, 'D4N','Line No' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'UMO ID', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4D', 30, 100, extr2( template, ltype, owner_id, 'D4D','UMO ID' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Category', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4M', 30, 100, extr2( template, ltype, owner_id, 'D4M','Category' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Caption', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4C', 30, 100, extr2( template, ltype, owner_id, 'D4C','Caption' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Date / Time', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4E', 30, 100, extr2( template, ltype, owner_id, 'D4E','Date / Time' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Account Name', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4F', 30, 100, extr2( template, ltype, owner_id, 'D4F','Account Name' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Image Details', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4A', 30, 100, extr2( template, ltype, owner_id, 'D4A','Image Details' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Statistics', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4B', 30, 100, extr2( template, ltype, owner_id, 'D4B','Statistics' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Purchase Details', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4G', 30, 100, extr2( template, ltype, owner_id, 'D4G','Purchase Details' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Image Type', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4H', 30, 100, extr2( template, ltype, owner_id, 'D4H','Image Type' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Sort Number', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4I', 30, 100, extr2( template, ltype, owner_id, 'D4I','Sort Number' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Image Pricing', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4J', 30, 100, extr2( template, ltype, owner_id, 'D4J','Image Pricing' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Greeting Card', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4K', 30, 100, extr2( template, ltype, owner_id, 'D4K','Greeting Card' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'FTP Details', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4L', 30, 100, extr2( template, ltype, owner_id, 'D4L','FTP Details' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Thesaurus', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4O', 30, 100, extr2( template, ltype, owner_id, 'D4O','Thesaurus' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Enabled', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4P', 30, 100, extr2( template, ltype, owner_id, 'D4P','Enabled' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Original Location', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4Q', 30, 100, extr2( template, ltype, owner_id, 'D4Q','Original Location' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Repeating Field Values', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4R', 30, 100, extr2( template, ltype, owner_id, 'D4R','Repeating Field Values' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Exclusivity', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4S', 30, 100, extr2( template, ltype, owner_id, 'D4S','Exclusivity' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;

 htp.tableclose;

 htp.nl;
 htp.bold( 'Additional Options' );
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
  htp.tablerowopen;
   htp.tabledata( 'Limit Output to Number of Images', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'LIMITO', 30, 100, extr2( template, ltype, owner_id, 'LIMITO','100' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Image (Gif) Containing Logo, Contact and ABN Details', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formtext( 'D4IMG', 30, 100, extr2( template, ltype, owner_id, 'D4IMG' )), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( 'Display Search Parameters', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'R4Z', 'T', extr3( template, ltype, owner_id, 'R4Z' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( 'Add Anchor to View/Edit Details of Image', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'XDT', 'T', extr3( template, ltype, owner_id, 'XDT' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
  htp.tablerowopen;
    htp.tabledata( 'Display Option to Download Output to a CSV File<BR>(Available only for Named Templates)', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
   htp.tabledata( htf.formcheckbox( 'CSV', 'T', extr3( template, ltype, owner_id, 'CSV' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
  htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );
    htp.tablerowopen;
     htp.tabledata( htf.bold('Save as Template'), cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     htp.tabledata( htf.formtext( 'TEMPLATE', 50, 100, c10rec.irt_name ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata( 'Display Return to Previous Screen Link', cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     if template is null
      then
       htp.tabledata( htf.formcheckbox( 'DSPT', 'T', 'CHECKED' ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
      else
       htp.tabledata( htf.formcheckbox( 'DSPT', 'T', extr3( template, ltype, owner_id, 'DSPT' ) ), cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"' );
     end if;
    htp.tablerowclose;
 htp.tableclose;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.formsubmit( 'ACTION', 'Run Report' ));
   htp.tabledata( htf.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>'));
  htp.tablerowclose;
 htp.tableclose;
 htp.formclose;
 htp.nl;
 htp.nl;

 htp.bold( 'Previously Created Templates' );
 foundrec := false;
 htp.tableopen( cattributes=>'cellspacing=2 cellpadding=2 border=0' );
 for c9rec in c9(ltype,owner_id) loop
  foundrec := true;
  htp.tablerowopen;
    htp.tabledata( htf.anchor( 'pfm.run_imgrep?surl=' || surl || '&id=' || c9rec.irt_id, c9rec.irt_name ) );
    htp.tabledata( htf.anchor( 'pfm.del_imgrep?surl=' || surl || '&id=' || c9rec.irt_id, '[' || 'Delete' || ']' ) );
  htp.tablerowclose;
 end loop;
 htp.tableclose;

 if not foundrec
  then
   htp.bold( 'No Templates have been Created' );
   htp.nl;
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PFM', 'IMGREP', owner_id, errmsg=>sqlerrm );
end imgrep;

procedure del_imgrep( surl in varchar2, id in integer )
as

 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);

begin
 glbx.adm_cookie_id( surl, sessid, sts, 'PFM.DEL_IMGREP');
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.DEL_IMGREP', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   stype := 1;
   ltype := 'ADMIN';
 end if;

 delete from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(owner_id,0) and irt_id = id;
 if sql%FOUND
  then
   imgrep( surl, 'Template Deleted' );
  else
   imgrep( surl, 'Template Not Found' );
 end if;

 commit;

exception when others then
 glbx.error_details( 'PFM', 'DEL_IMGREP', owner_id, errmsg=>sqlerrm );
end del_imgrep;

procedure run_imgrep( surl in varchar2, id in integer, dump_to_csv in char default 'F' )
as

 cursor c1( ltype varchar2, lid integer, id integer ) is select * from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and irt_id = id;

 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 tmp		varchar2(32767);

begin
 glbx.adm_cookie_id( surl, sessid, sts, 'PFM.RUN_IMGREP');
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.RUN_IMGREP', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   stype := 1;
   ltype := 'ADMIN';
 end if;

 tmp := '&action=&template=&template2=' || id || '&dump_to_csv=' || dump_to_csv;
 for c1rec in c1(ltype, owner_id, id) loop
  tmp := tmp || '&' || c1rec.param_name || '=' || replace(replace(replace(c1rec.param_value,' ','+'),'"','&#34;'),'%','%25');
 end loop;
 tmp := 'pfm.accept_imgrep?surl=' || surl || tmp;

 --htp.p( tmp );
 owa_util.redirect_url( tmp );

exception when others then
 glbx.error_details( 'PFM', 'RUN_IMGREP', owner_id, errmsg=>sqlerrm );
end run_imgrep;

procedure accept_imgrep( surl in varchar2, p1 in GLBX.MYARRAY, p4 in GLBX.MYARRAY, d1 in GLBX.MYARRAY, d3r in varchar2, d3s in varchar2, d3t in varchar2,
                         p2 in varchar2, p3 in varchar2, p8a in varchar2, p8b in varchar2, p8c in varchar2, p9a in varchar2, p9b in varchar2, p9c in varchar2,
                         d5a in varchar2, d5af in varchar2, d5c in varchar2, d5d in varchar2,  d5fca in varchar2 default '000000', d5e in varchar2, d5fcb in varchar2 default '000000',
                         fnt in varchar2, fsize in varchar2, d5f in varchar2,
                         d4z in varchar2, d4n in varchar2, d4a in varchar2, d4b in varchar2, d4c in varchar2, d4d in varchar2, d4e in varchar2, d4f in varchar2, d4g in varchar2, d4h in varchar2,
                         d4i in varchar2, d4j in varchar2, d4k in varchar2, d4l in varchar2, d4m in varchar2, d4o in varchar2, d4p in varchar2, d4q in varchar2, d4r in varchar2, d4s in varchar2,
                         limito in varchar2, d4img in varchar2, r4z in varchar2 default 'F', xdt in varchar2 default 'F', csv in char default 'F',
                         template in varchar2, template2 in varchar2 default null, dspt in char default 'F', action in varchar2, dump_to_csv in char default 'F' )
as

 TYPE DCurTyp IS REF CURSOR;  -- define weak REF CURSOR type

 cursor c3( ord1 varchar2, ord2 varchar2, ord3 varchar2 ) is
  select ca.username, ca.account_name,
         um.umo_id,
         um.parent_id,
         um.aid,
         um.report_id,
         um.is_global,
         um.pricing_structure,
         um.umo_type,
         um.umo_owner,
         um.umo_scene_id,
         um.version,
         um.date_created,
         um.expire_date,
         um.extras,
         um.extra_film_colour,
         um.extra_roll_id,
         um.extra_film_size,
         um.photo_original,
         um.photo_master,
         um.photo_thumbnail,
         um.photo_backup,
         um.audio_original,
         um.audio_thumbnail,
         um.video_original,
         um.ftp_location,
         um.ftp_virtual_dir,
         um.photo_original_loc,
         um.audio_original_loc,
         um.video_original_loc,
         um.doc_mimetype,
         um.doc_type,
         um.doc_pov,
         um.doc_length,
         um.doc_body,
         um.doc_html,
         um.doc_gist,
         um.document_original_loc,
         um.image_caption,
         um.blueprint_obj,
         um.sessid,
         um.attribute1,
         um.attribute2,
         um.attribute3,
         um.attribute4,
         um.attribute5,
         um.attribute6,
         um.sort_priority,
         um.exclusive_purchased,
         um.signature,
         um.program_obj
  from umo um, advanced_query_temp_result_a aa, customer_account ca
  where um.umo_id = aa.umo_id and
        ca.aid = um.aid
  order by decode(ord1,'A',to_char(um.umo_id),'B',to_char(um.date_created,'YYYYMMDD'),'C',ca.account_name,'D',um.extras.film_name,'E',lpad(to_char(um.sort_priority),10,'0'),'F',um.extras.orderby_scene,um.umo_id),
           decode(ord2,'A',to_char(um.umo_id),'B',to_char(um.date_created,'YYYYMMDD'),'C',ca.account_name,'D',um.extras.film_name,'E',lpad(to_char(um.sort_priority),10,'0'),'F',um.extras.orderby_scene,um.umo_id),
           decode(ord3,'A',to_char(um.umo_id),'B',to_char(um.date_created,'YYYYMMDD'),'C',ca.account_name,'D',um.extras.film_name,'E',lpad(to_char(um.sort_priority),10,'0'),'F',um.extras.orderby_scene,um.umo_id);

 cursor c3det( sess_id integer ) is
  select p.username p_username, p.business_name, ca.username ca_username, ca.account_name, 'ACCOUNT' acct
  from photographer p, customer_account ca, login_session ls
  where p.pid = ca.pid and
        ca.aid = ls.aid and
        ls.sessid = sess_id and
        ls.login_type in ('OWNER','CUSTOMER' )
  union all
  select p.username p_username, p.business_name, cp.username ca_username, cp.account_name, 'PROFILE' acct
  from photographer p, customer_profile cp, login_session ls
  where p.pid = cp.pid and
        cp.profile_id = ls.aid and
        ls.sessid = sess_id and
        ls.login_type in ('PROFILE','PROFILEG' );

 cursor c5( tempname varchar2, ltype varchar2, lid integer ) is
  select distinct irt_id
  from image_report_template
  where login_type = ltype and nvl(login_id,0) = nvl(lid,0) and irt_name = tempname;

 cursor c6( v_umo integer ) is select display_what,count('x') cnt from audit_all_activity where umo_id = v_umo and display_what in ('MASTER','THUMBNAIL','ORIGINAL') group by display_what;
 cursor c7( v_umo integer ) is select count('x') cnt from  thesaurus_term_umo where umo_id = v_umo;
 cursor c8( v_umo integer ) is select count('x') cnt from  ecard where phid = v_umo;
 cursor c9( v_umo integer ) is select count('x') cnt from  shopping_basket where phid = v_umo;
 cursor c10( v_umo integer ) is select count('x') cnt from  shopping_basket sb, purchase_order po where sb.poid = po.poid and phid = v_umo and po.status in ('Ordered', 'Order Authorised','Order Payment Received','Processing','Sent to Lab','Received by Lab','Processed by Lab','Order Completed','On Hold','Lab Problems' );
 cursor c11( v_umo integer ) is select count('x') cnt, min(score) mn, max(score) mx, avg(score) av from  image_vote where umo_id = v_umo;
 cursor c12( v_umo integer ) is select nvl(sum(decode(ftp_original,'ORIGINAL',1,0)),0) cnt1, nvl(sum(decode(ftp_original,'WEB',1,0)),0) cnt2, nvl(sum(decode(ftp_original,'FTP',1,0)),0) cnt3 from  downloaded_photo where umo_id = v_umo;

 dcurs  	DCurTyp;
 c3det_rec	c3det%ROWTYPE;
 c5rec		c5%ROWTYPE;
 c6rec		c6%ROWTYPE;
 c7rec		c7%ROWTYPE;
 c8rec		c8%ROWTYPE;
 c9rec		c9%ROWTYPE;
 c10rec		c10%ROWTYPE;
 c11rec		c11%ROWTYPE;
 c12rec		c12%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 val		number;
 v1		number;
 v2		number;
 vgst		number;
 mx		integer;
 ctr		integer;
 nmb1		integer;
 nmb2		integer;
 fz		integer;
 date1		date;
 date2		date;
 page_break	boolean;
 dsp_logo	boolean;
 dsp_cname	boolean;
 dsp_date	boolean;
 foundrec	boolean;
 vmsg		varchar2(20);
 srt1		varchar2(100);
 srt2		varchar2(100);
 srt3		varchar2(100);
 sts		varchar2(100);
 tmp		varchar2(1000);
 tmp2		varchar2(1000);
 hdr_txt	varchar2(1000);
 brk		varchar2(10000);
 last_brk	varchar2(10000);
 gbfr		varchar2(32767);
 stmt		varchar2(32767);
 stmt_temp	varchar2(32767);
 tmpout		varchar2(32767);
 pfx		THEME%ROWTYPE;
 poid_array	GLBX.MYARRAY;
 poid_array2	GLBX.MYARRAY;
 parm1 		GLBX.MYARRAY;
 parm2 		GLBX.MYARRAY_NMB;


procedure dump_to( cattributes varchar2 )
as
begin
 if dump_to_csv = 'F'
  then
   htp.tableopen( cattributes );
 end if;
end dump_to;

procedure dump_tc
as
begin
 if dump_to_csv = 'F'
  then
   htp.tableclose;
 end if;
end dump_tc;

procedure dump_tr
as
begin
 if dump_to_csv = 'F'
  then
   htp.tablerowopen;
  else
   gbfr := NULL;
 end if;
end dump_tr;

procedure dump_trc
as
begin
 if dump_to_csv = 'F'
  then
   htp.tablerowclose;
  else
   htp.p( replace(replace(replace(replace(gbfr,'<BR>',' '),'&nbsp;',' '),'<B>',''),'</B>','') );
 end if;
end dump_trc;

procedure dump_nl
as
begin
 if dump_to_csv = 'F'
  then
   htp.nl;
 end if;
end dump_nl;

procedure dump_th( dt in varchar2, cattributes in varchar2 )
as
begin
 if dump_to_csv = 'F'
  then
   htp.tableheader(dt, cattributes=>cattributes);
  else
   gbfr := gbfr || '"' || dt || '",';
 end if;
end dump_th;

procedure dump_td( dt in varchar2, cattributes in varchar2 )
as
begin
 if dump_to_csv = 'F'
  then
   htp.tabledata(nvl(trim(dt),'&nbsp;'), cattributes=>cattributes);
  else
   gbfr := gbfr || '"' || trim(dt) || '",';
 end if;
end dump_td;

procedure display_header( cname in varchar2 default null )
as
begin

  -- Header
  if (dsp_logo or dsp_cname or dsp_date) and dump_to_csv = 'F'
   then
    htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0 width="100%"' );
    htp.tablerowopen;
     if dsp_logo
      then
       htp.tabledata( htf.anchor2(glbx.extract_master_parameter('PICTION_HOME_PAGE'),htf.img( DECS.IMAGE_LOCATION || 'admin/piction.gif',cattributes=>' border=0',calt=>'Go to the Site'),ctarget=>'PICTION_WINDOW'), cattributes=>'ALIGN=LEFT VALIGN=TOP style="text-align: left;"');
     end if;
     if dsp_cname
      then
       htp.tabledata( htf.header(2, cname, 'CENTER'), cattributes=>'ALIGN=CENTER VALIGN=TOP style="text-align: center;"');
     end if;
     if dsp_cname
      then
       htp.tabledata( htf.bold( to_char(sysdate,LNG.MASK) ), cattributes=>'ALIGN=RIGHT VALIGN=TOP style="text-align: right;"');
     end if;
    htp.tablerowclose;
    htp.tableclose;
    htp.nl;
  end if;
  dump_to( cattributes=>d5f );
  dump_tr;
  tmp := 'bgcolor="#' || d5a || '" ALIGN="CENTER" style="text-align: center; font-family: ' || fnt || '; color: #' || d5af || '; background-color: #' || d5a || '"';
  for j in d1.first..d1.last loop
   if d1(j) = 'Q'
    then
     -- Line No
     dump_th( nvl(d4n,'&nbsp;'), cattributes=>tmp );
   elsif d1(j) = 'A'
    then
     -- UMO_ID
     dump_th( d4d, cattributes=>tmp );
   elsif d1(j) = 'I'
    then
     -- Category
     dump_th( d4m, cattributes=>tmp );
   elsif d1(j) = 'U'
    then
     -- Caption
     dump_th( d4c, cattributes=>tmp );
   elsif d1(j) = 'B'
    then
     -- Date Time
     dump_th( d4e, cattributes=>tmp );
   elsif d1(j) = 'C'
    then
     -- Account Name
     dump_th( d4f, cattributes=>tmp );
   elsif d1(j) = 'W'
    then
     -- Image Details
     dump_th( d4a, cattributes=>tmp );
   elsif d1(j) = 'V'
    then
     -- Statistics
     dump_th( d4b, cattributes=>tmp );
   elsif d1(j) = 'D'
    then
     -- Purchase Details
     dump_th( d4g, cattributes=>tmp ); -- Image
   elsif d1(j) = 'E'
    then
     -- Image Type
     dump_th( d4h, cattributes=>tmp );
   elsif d1(j) = 'S'
    then
     -- Sort Number
     dump_th( d4i, cattributes=>tmp );
   elsif d1(j) = 'F'
    then
     -- Image Pricing
     dump_th( d4j, cattributes=>tmp );
   elsif d1(j) = 'G'
    then
     -- Greeting Card
     dump_th( d4k, cattributes=>tmp );
   elsif d1(j) = 'H'
    then
     -- FTP Details
     dump_th( d4l, cattributes=>tmp );
   elsif d1(j) = 'J'
    then
     -- Thesaurus
     dump_th( d4o, cattributes=>tmp );
   elsif d1(j) = 'K'
    then
     -- Enabled
     dump_th( d4p, cattributes=>tmp );
   elsif d1(j) = 'T'
    then
     -- Original Location
     dump_th( d4q, cattributes=>tmp );
   elsif d1(j) = 'L'
    then
     -- Repeating Fields
     dump_th( d4r, cattributes=>tmp );
   elsif d1(j) = 'R'
    then
     -- Exclusivity
     dump_th( d4s, cattributes=>tmp );
   elsif d1(j) = 'X'
    then
     -- Exclusivity
     dump_th( 'Vote', cattributes=>tmp );
   end if;
  end loop;
  dump_trc;

end display_header;

procedure save_query
as
 tmp	varchar2(100);
begin
   tmp := nvl(template,'Last Query');
   mx := NULL;
   open c5(tmp, ltype, owner_id);
   fetch c5 into mx;
   close c5;
   if mx is null
    then
     select nvl(max(irt_id),0) + 1 mx into mx from image_report_template;
   end if;
   delete from image_report_template where login_type = ltype and nvl(login_id,0) = nvl(owner_id,0) and irt_id = mx;
   for j in p1.first..p1.last loop
    insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P1',p1(j));
   end loop;
   for j in p4.first..p4.last loop
    insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P4',p4(j));
   end loop;
   for j in d1.first..d1.last loop
    insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D1',d1(j));
   end loop;
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D3R',d3r);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D3S',d3s);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D3T',d3t);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P2',p2);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P3',p3);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P8A',p8a);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P8B',p8b);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P8C',p8C);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P9A',p9a);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P9B',p9b);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'P9C',p9C);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5A',d5a);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5AF',d5af);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5C',d5c);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5D',d5d);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5FCA',d5fca);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5FCB',d5fcb);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5E',d5e);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FNT',fnt);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'FSIZE',fsize);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D5F',d5F);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4Z',d4z);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4N',d4n);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4A',d4a);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4B',d4b);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4C',d4c);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4D',d4d);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4E',d4e);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4F',d4f);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4G',d4g);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4H',d4h);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4I',d4i);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4J',d4j);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4K',d4k);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4L',d4l);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4M',d4m);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4O',d4o);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4P',d4p);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4Q',d4q);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4R',d4r);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4S',d4s);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'LIMITO',limito);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'D4IMG',d4img);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'R4Z',r4z);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'XDT',xdt);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'CSV',csv);
   insert into image_report_template(irt_id,irt_name,login_type,login_id,param_name,param_value) values (mx,tmp,ltype,owner_id,'DSPT',dspt);
   commit;
end save_query;

begin
 glbx.adm_cookie_id( surl, sessid, sts, 'PFM.ACCEPT_IMGREP');
 if sts is not null
  then
   glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.ACCEPT_IMGREP', iscust=>FALSE );
   if sts is not null
    then
     glbx.redisplay_login_page( sts );
     return;
   end if;
  else
   stype := 1;
   ltype := 'ADMIN';
 end if;

 pfx := glbx.photo_lf(owner_id);
 begin fz := nvl(to_number(fsize),0); exception when others then fz := 0; end;

 if dump_to_csv = 'T'
  then
   htp.prn('Content-type: ' || 'bad/type' || chr(10));
   htp.prn('Content-Disposition: attachment; filename=' || 'pricing_' || to_char(sysdate,'dd_mon_yyyy') || '.csv' || chr(10));
   htp.prn('Content-Transfer-Encoding: binary' || chr(10));
   htp.prn(chr(10));
  else
   glbx.main_title( surl, d4z, '<BODY BGCOLOR="#' || d5c || '">',helpid=>'P79', stype=>stype, sstyle=>fnt,sclr=>pfx.text_colour, finc=>fsize, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
   htp.title( 'Image Report' );
   htp.p( '<CENTER>' );
 end if;

 page_break := FALSE;
 dsp_logo := FALSE;
 dsp_cname := FALSE;
 dsp_date := FALSE;
 for j in d1.first..d1.last loop
  if d1(j) = 'M' then dsp_logo := TRUE; end if;
  if d1(j) = 'N' then dsp_cname := TRUE; end if;
  if d1(j) = 'O' then dsp_date := TRUE; end if;
  if d1(j) = 'P' then page_break := TRUE; end if;
 end loop;
 if p1.count = 1
  then
   htp.nl;
   htp.bold( 'You must select at least account' );
   htp.htmlclose;
   return;
 end if;

 if r4z = 'T' and dump_to_csv = 'F'
  then
   htp.bold( 'Search parameters' );
   htp.tableopen( cattributes=>'cellspacing=2 cellpadding=1 border=1' );
   if p2 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Image Name Matches' ));
      htp.tabledata( p2 );
     htp.tablerowclose;
   end if;
   if p3 is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold( 'Caption Matches' ));
      htp.tabledata( p3 );
     htp.tablerowclose;
   end if;
    htp.tablerowopen;
     htp.tabledata( htf.bold( 'Image Type' ));
     htp.p( '<TD>' );
     for j in p4.first..p4.last loop
      if p4(j) is not null then htp.p(initcap(p4(j)) || ', '); end if;
     end loop;
     htp.p( '</TD>' );
    htp.tablerowclose;
   if p8a is not null
    then
     htp.tablerowopen;
      htp.tabledata( htf.bold(  'Date Range' ));
      htp.tabledata( p8a || '-' || p8b || '-' || p8c || ' to ' || p9a || '-' || p9b || '-' || p9c );
     htp.tablerowclose;
   end if;
   htp.tableclose;
 end if;

  -- Body
  stmt := 'select umo_id from umo um where';
  if p2 is not null
   then
    stmt := stmt || ' and upper(um.extras.film_name) like ''' || replace(upper(p2),'*','%') || '''';
  end if;
  if p3 is not null
   then
    stmt := stmt || ' and upper(um.image_caption ) like ''' || replace(upper(p3),'*','%') || '''';
  end if;

  stmt_temp := NULL;
  if p4.count > 0
   then
    for j in p4.first..p4.last loop
     if p4(j) is not null
      then
       stmt_temp := stmt_temp || ',' || '''' || p4(j) || '''';
     end if;
    end loop;
    if stmt_temp is null
     then
      stmt := stmt || ' and umo_type is NULL';
     else
      stmt := stmt || ' and umo_type in (' || substr(stmt_temp,2) || ')';
    end if;
  end if;

  begin date1 := to_date(p8a || '-' || p8b || '-' || p8c,'DD-MON-YYYY'); exception when others then date1 := NULL; end;
  begin date2 := to_date(p9a || '-' || p9b || '-' || p9c,'DD-MON-YYYY'); exception when others then date2 := NULL; end;
  date1 := nvl(date1,sysdate-1000);
  date2 := nvl(date2,sysdate+1000);
  stmt := stmt || ' and date_created between to_date(''' || to_char(date1,'DD-MON-YYYY') || ''',''DD-MON-YYYY'') and to_date(''' || to_char(date2+1,'DD-MON-YYYY') || ''',''DD-MON-YYYY'')';

  stmt_temp := NULL;
  for j in p1.first..p1.last loop
   if p1(j) is not null then  stmt_temp := stmt_temp || ',' || '''' || p1(j) || ''''; end if;
  end loop;

  if ltype in ('ADMIN','MANUFACTURER')
   then
    stmt := stmt || ' and aid in (' || substr(stmt_temp,2) || ')' ;
   else
    stmt := stmt || ' and aid in (' || substr(stmt_temp,2) || ')' ;
    stmt := stmt || ' and aid in (select aid from customer_account where pid = ''' || owner_id || ''')' ;
  end if;

  stmt := replace(stmt,'where and','where ');
  -- fetch cursor into array
  ctr := 0;
  --htp.p( stmt ); htp.nl;
  open dcurs for stmt;
  loop
   ctr := ctr + 1;
   fetch dcurs into poid_array(ctr);
   if dcurs%NOTFOUND then exit; end if;
  end loop;
  close dcurs;

  if ctr = 0
   then
    -- No Data Found
    save_query;
    dump_tc;
    htp.nl;
    htp.bold( 'No Rows Found That Satisfy this Query' );
    htp.nl;
    htp.nl;
    htp.anchor( 'pfm.imgrep?surl=' || surl || '&template=' || mx, 'Return to Report Screen' );
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;
  end if;

  if poid_array.count = 0
   then
    -- No Data Found
    save_query;
    htp.tableclose;
    htp.nl;
    htp.bold( 'No Rows Found That Satisfy this Query' );
    htp.nl;
    htp.nl;
    htp.anchor( 'pfm.imgrep?surl=' || surl || '&template=' || mx, 'Return to Report Screen' );
    htp.p( '</CENTER>' );
    htp.htmlclose;
    return;
  end if;

  delete from advanced_query_temp_result_a;
  for j in poid_array.first..poid_array.last loop
   if poid_array(j) is not null
    then
     insert into advanced_query_temp_result_a(umo_id) select to_number(poid_array(j)) from dual where not exists (select 'x' from advanced_query_temp_result_a where umo_id = to_number(poid_array(j)));
   end if;
  end loop;

  begin srt1 := d3r; exception when others then null; end;
  begin srt2 := d3s; exception when others then null; end;
  begin srt3 := d3t; exception when others then null; end;

  brk := NULL;
  last_brk := NULL;
  foundrec := FALSE;

  for c3rec in c3(srt1,srt2,srt3) loop

   foundrec := TRUE;

   open c3det(c3rec.sessid);
   fetch c3det into c3det_rec;
   close c3det;
   brk := NULL;
   hdr_txt := NULL;

   if c3%ROWCOUNT > nvl(limito,999999) then exit; end if;

   if brk is null and last_brk is null
    then
     if c3%ROWCOUNT = 1
      then
       display_header(hdr_txt);
     end if;
   elsif brk is null and last_brk is not null
    then
     null;
   elsif brk is not null and last_brk is null
    then
      display_header(hdr_txt);

   else
    if brk <> last_brk
     then
      dump_tc;
      dump_nl;
      if page_break
       then
        htp.p('<span style=''font-size:1.0pt;mso-bidi-font-size:10.0pt;font-family:Arial; mso-fareast-font-family:"Times New Roman";mso-bidi-font-family:"Times New Roman"; mso-ansi-language:EN-US;mso-fareast-language:EN-US;mso-bidi-language:AR-SA''><br clear=all style=''mso-special-character:line-break;page-break-before:always''></span>');
      end if;
      dump_to( cattributes=>d5f );
      display_header(hdr_txt);
    end if;
   end if;
   last_brk := brk;

   dump_tr;
   if mod(c3%ROWCOUNT,2) = 1
    then
     tmp := 'bgcolor="#' || d5d || '" ALIGN="LEFT" style="text-align: left; color: #' || d5fca || '; font-family: ' || fnt || '; background-color: #' || d5d || '"';
    else
     tmp := 'bgcolor="#' || d5e || '" ALIGN="LEFT" style="text-align: left; color: #' || d5fcb || '; font-family: ' || fnt || '; background-color: #' || d5e|| '"';
   end if;
   if mod(c3%ROWCOUNT,2) = 1
    then
     tmp2 := 'bgcolor="#' || d5d || '" ALIGN="RIGHT" style="text-align: right; color: #' || d5fca || '; font-family: ' || fnt || '; background-color: #' || d5d || '"';
    else
     tmp2 := 'bgcolor="#' || d5e || '" ALIGN="RIGHT" style="text-align: right; color: #' || d5fcb || '; font-family: ' || fnt || '; background-color: #' || d5e|| '"';
   end if;

   for j in d1.first..d1.last loop
    if d1(j) = 'Q'
     then
      dump_td( to_char(c3%ROWCOUNT), cattributes=>tmp2 );

    elsif d1(j) = 'A'
     then
      -- Umo Id
      if xdt = 'T' and dump_to_csv = 'F'
       then
        if ltype = 'ADMIN'
         then
          dump_td( c3rec.umo_id, cattributes=>tmp );
        elsif ltype = 'PHOTOGRAPHER'
         then
          dump_td( htf.anchor2('phg.phg_modify?surl=' || surl || '&acid=' || c3rec.aid || '&phgid=' || c3rec.umo_id || '&msg=&footer_api=&left_api_parm=&current_page_number=&display_detail=',c3rec.umo_id,ctarget=>'EDIT_IMG' || c3rec.umo_id), cattributes=>tmp );
        elsif ltype = 'MANUFACTURER'
         then
          dump_td( c3rec.umo_id, cattributes=>tmp );
        end if;
       else
        dump_td( c3rec.umo_id, cattributes=>tmp );
      end if;

    elsif d1(j) = 'I'
     then
      -- Category
      dump_td( c3rec.extras.title, cattributes=>tmp );

    elsif d1(j) = 'U'
     then
      -- Caption
      dump_td( c3rec.image_caption, cattributes=>tmp );

    elsif d1(j) = 'B'
     then
      -- Date Created
      dump_td( to_char(c3rec.date_created,LNG.TSMASK), cattributes=>tmp );

    elsif d1(j) = 'C'
     then
      -- account name
      if ltype in ('ADMIN','MANUFACTURER')
       then
        dump_td( c3det_rec.business_name || htf.nl || c3det_rec.account_name, cattributes=>tmp );
       else
        dump_td( c3rec.account_name, cattributes=>tmp );
      end if;

    elsif d1(j) = 'W'
     then
      -- Image Details
      tmpout := c3rec.extra_film_colour;
      if  dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || c3rec.extra_roll_id;
      if  dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || c3rec.extra_film_size;
      if  dump_to_csv = 'T' then tmpout := ';' || tmpout; else tmpout := htf.nl || tmpout; end if;
      if c3rec.extras.photo_name is null or c3rec.extras.film_name = c3rec.extras.photo_name or dump_to_csv = 'T'
       then
        dump_td( c3rec.extras.film_name || tmpout, cattributes=>tmp );
      else
        dump_td( c3rec.extras.film_name || htf.nl || c3rec.extras.photo_name || tmpout, cattributes=>tmp );
      end if;

    elsif d1(j) = 'V'
     then
      -- Image Usage Stats
      tmpout := NULL;
      for c6rec in c6( c3rec.umo_id ) loop
       tmpout := tmpout || initcap(c6rec.display_what) || '-' || c6rec.cnt;
       if dump_to_csv = 'T' then tmpout := tmpout || ' '; else tmpout := tmpout || htf.nl; end if;
      end loop;
      if dump_to_csv = 'T' then tmpout := substr(tmpout,1,length(tmpout)-1); else tmpout := substr(tmpout,1,length(tmpout)-4); end if;
      dump_td( tmpout, cattributes=>tmp );

    elsif d1(j) = 'D'
     then
      -- Purchase Details
      open c10(c3rec.umo_id);
      fetch c10 into c10rec;
      close c10;
      tmpout := 'Purchased' || ':' || c10rec.cnt;
      if  dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      open c9(c3rec.umo_id);
      fetch c9 into c9rec;
      close c9;
      tmpout := tmpout || 'In Basket' || ':' || c9rec.cnt;
      if  dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      open c12(c3rec.umo_id);
      fetch c12 into c12rec;
      close c12;
      tmpout := tmpout || 'Orig Download' || ':' || c12rec.cnt1;
      if  dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || 'FTP' || ':' || c12rec.cnt3;
      if  dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || 'Web Download' || ':' || c12rec.cnt2;
      dump_td( tmpout, cattributes=>tmp );

    elsif d1(j) = 'E'
     then
      -- Image Type
      dump_td( c3rec.umo_type, cattributes=>tmp );

    elsif d1(j) = 'S'
     then
      -- Sort Number
      dump_td( to_char(c3rec.sort_priority), cattributes=>tmp );

    elsif d1(j) = 'F'
     then
      -- Image Pricing
      if c3rec.pricing_structure = 'I'
       then
        tmpout := 'Individual';
       else
        tmpout := 'Price Book';
      end if;
      dump_td( tmpout, cattributes=>tmp );

    elsif d1(j) = 'G'
     then
      -- Greeting Card
      open c8(c3rec.umo_id);
      fetch c8 into c8rec;
      close c8;
      dump_td( '#' || c8rec.cnt, cattributes=>tmp );

    elsif d1(j) = 'H'
     then
      -- FTP Details
      dump_td( c3rec.ftp_virtual_dir || ' ' || c3rec.ftp_location, cattributes=>tmp );

    elsif d1(j) = 'J'
     then
      -- Thesaurus
      open c7(c3rec.umo_id);
      fetch c7 into c7rec;
      close c7;
      dump_td( '# Terms:' || c7rec.cnt, cattributes=>tmp );

    elsif d1(j) = 'K'
     then
      -- Enabled
      if c3rec.extras.enabled_phg = 'TRUE'
       then
        tmpout := 'Owner' || ':' || 'Yes';
       else
        tmpout := 'Owner' || ':' || 'No';
      end if;
      if  dump_to_csv = 'T' then tmpout := tmpout || ' '; else tmpout := tmpout || htf.nl; end if;
      if c3rec.extras.enabled_cus = 'TRUE'
       then
        tmpout := tmpout || 'Guest' || ':' || 'Yes';
       else
        tmpout := tmpout || 'Guest' || ':' || 'No';
      end if;
      dump_td( tmpout, cattributes=>tmp );

    elsif d1(j) = 'T'
     then
      -- Original Field Values
      if c3rec.umo_type = 'PHOTO'
       then
        dump_td( c3rec.photo_original_loc, cattributes=>tmp );
      elsif c3rec.umo_type = 'DOCUMENT'
       then
        dump_td( c3rec.document_original_loc, cattributes=>tmp );
      elsif c3rec.umo_type = 'VIDEO'
       then
        dump_td( c3rec.video_original_loc, cattributes=>tmp );
      elsif c3rec.umo_type = 'AUDIO'
       then
        dump_td( c3rec.audio_original_loc, cattributes=>tmp );
      elsif c3rec.umo_type = 'RELATIONAL'
       then
        dump_td( null, cattributes=>tmp );
      elsif c3rec.umo_type = 'BLUEPRINT'
       then
        dump_td( c3rec.blueprint_obj.blueprint_original_loc, cattributes=>tmp );
      end if;

    elsif d1(j) = 'L'
     then
      -- Repeated Field Values
      tmpout := NULL;
      tmpout := tmpout || '1.' || c3rec.attribute1;
      if dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || '2.' || c3rec.attribute2;
      if dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || '3.' || c3rec.attribute3;
      if dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || '4.' || c3rec.attribute4;
      if dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || '5.' || c3rec.attribute5;
      if dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      tmpout := tmpout || '6.' || c3rec.attribute6;
      if dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      dump_td( tmpout, cattributes=>tmp );

    elsif d1(j) = 'R'
     then
      -- Exclusivity
      if c3rec.exclusive_purchased = 'T'
       then
        tmpout := 'Yes';
       else
        tmpout := 'No';
      end if;
      if dump_to_csv = 'T' then tmpout := tmpout || ';'; else tmpout := tmpout || htf.nl; end if;
      if c3rec.expire_date is not null then tmpout := tmpout || 'Expires' || ':' || to_char(c3rec.expire_date,LNG.TSMASK); end if;
      dump_td( tmpout, cattributes=>tmp );

    elsif d1(j) = 'X'
     then
      -- Vote
      open c11(c3rec.umo_id);
      fetch c11 into c11rec;
      close c11;
      if c11rec.mn is null
       then
        dump_td( '# Votes' || c11rec.cnt, cattributes=>tmp );
       else
        dump_td( '# Votes' || c11rec.cnt || htf.nl || 'Min:' || c11rec.mn || htf.nl || 'Avg:' || c11rec.av || htf.nl || 'Max:' || c11rec.mx, cattributes=>tmp );
      end if;

    end if;

   end loop;

  dump_trc;
  end loop;

 dump_tc;

 if d4img is not null and dump_to_csv = 'F'
  then
   htp.nl;
   htp.img( DECS.IMAGE_LOCATION || 'site_specific/' || d4img,cattributes=>' border=0', calt=>NULL);
   htp.nl;
 end if;

 save_query;

 if csv = 'T' and dump_to_csv = 'F'
  then
   htp.nl;
   htp.nl;
   htp.anchor( 'pfm.run_imgrep?surl=' || surl || '&id=' || mx || '&dump_to_csv=T', 'Extract Data to a CSV File' );
   htp.nl;
   htp.nl;
 end if;

 if dspt = 'T' and dump_to_csv = 'F'
  then
   if mx is null and template2 is not null
    then
     mx := template2;
   end if;
   htp.nl;
   htp.anchor( 'pfm.imgrep?surl=' || surl || '&template=' || mx, 'Return to Report Screen' );
   htp.nl;
 end if;

 if dump_to_csv = 'F' then htp.p( '</CENTER>' ); htp.p( '</BODY>'); htp.htmlclose; end if;

exception when others then
 htp.bold( stmt );
 glbx.error_details( 'PFM', 'ACCEPT_IMGREP', owner_id, errmsg=>sqlerrm );
end accept_imgrep;

procedure manage_portlets( surl in varchar2, msg in varchar2 default null )
as

 cursor c1(phgid integer) is select * from portlet_definition where pid = phgid order by name;

 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.MANAGE_PORTLETS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, LNG5.EXT_TXT_656, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P81', stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( LNG5.EXT_TXT_656 );
 glbx.header_msg( msg );
 htp.p( '<CENTER>' );

 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG.PHG_TXT_022),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold(LNG3.ADM_TXT_238),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold(LNG.GLB_TXT_055),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;

 for c1rec in c1(owner_id) loop
  htp.tablerowopen;
   htp.tabledata(htf.anchor( 'pfm.edit_portlet?surl=' || surl || '&portid=' || c1rec.portlet_id, c1rec.name ),cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata(c1rec.portlet_type,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
   htp.tabledata(c1rec.is_enabled,cattributes=>pfx.qcbground || 'valign="MIDDLE" align="CENTER"');
  htp.tablerowclose;
 end loop;

 htp.tableclose;
 htp.nl;

 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
 htp.formopen( 'pfm.edit_portlet' );
 htp.formhidden( 'SURL', surl );
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG.PHG_TXT_022));
  htp.tabledata( htf.formtext( 'PORTNAME', 30, 100 ));
 htp.tablerowclose;
 htp.tablerowopen;
  htp.tabledata( htf.bold(LNG5.EXT_TXT_713));
  htp.p( '<TD>' );
   htp.formselectopen( 'PORTTYPE' );
    --htp.formselectoption( 'WEBSERVICE' ); -- not available just yet
    htp.formselectoption( 'LOGIN' );
    htp.formselectoption( 'SEND QUERY' );
    htp.formselectoption( 'NEWS' );
    htp.formselectoption( 'QUICKNEWS' );
    htp.formselectoption( 'CUSTOMERS' );
   htp.formselectclose;
  htp.p( '</TD>' );
 htp.tablerowclose;
 htp.tablerowopen;
 htp.tabledata( '&nbsp;' );
 htp.tabledata( htf.formsubmit( null, LNG5.EXT_TXT_688 ) || htf.formclose );
 htp.tablerowclose;
 htp.p( '</CENTER>' );
 htp.htmlclose;
exception when others then
 glbx.error_details( 'PFM', 'MANAGE_PORTLETS', owner_id, errmsg=>sqlerrm );
end manage_portlets;

procedure pos_loop( posint integer )
as
begin
 htp.formselectopen( 'P2' );
 for j in 1..7 loop
  if posint = j
   then
    htp.formselectoption( to_char(j), 'SELECTED' );
   else
    htp.formselectoption( to_char(j) );
  end if;
 end loop;
 htp.formselectclose;
end pos_loop;

procedure edit_portlet( surl in varchar2, portid in integer default null, portname in varchar2 default null, porttype in varchar2 default null, msg in varchar2 default null )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_login where portlet_id = portid and exists (select pid from portlet_definition where pid = phgid and portlet_id = portid);
 cursor c2(phgid integer, portid integer) is select * from portlet_definition where portlet_id = portid and pid = phgid;
 cursor c3 is select font_name from fonts order by font_name;
 cursor c4 is select 'xx-small' pitch from dual union all select 'x-small' pitch from dual union all select 'small' pitch from dual union all select 'medium' pitch from dual union all select 'large' pitch from dual union all select 'x-large' pitch from dual union all select 'xx-large' pitch from dual;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.EDIT_PORTLET', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if portid is null and portname is null
  then
   manage_portlets( surl, LNG5.EXT_TXT_711 );
   return;
 end if;

 if portid is not null
  then

   open c2(owner_id,portid);
   fetch c2 into c2rec;
   close c2;
   if c2rec.portlet_type = 'SEND QUERY'
    then
     edit_portlet_query(surl, portid, portname, porttype, msg );
     return;
   elsif c2rec.portlet_type in ('NEWS','QUICKNEWS','CUSTOMERS')
    then
     edit_portlet_news(surl, portid, portname, porttype, msg );
     return;
   elsif c2rec.portlet_type in ('WEBSERVICE')
    then
     edit_webservice(surl, portid, portname, porttype, msg );
     return;
   end if;

   open c1(owner_id, portid);
   fetch c1 into c1rec;
   close c1;
   if c2rec.portlet_id is null
    then
     manage_portlets( surl, LNG5.EXT_TXT_712 );
     return;
   end if;

 elsif portname is not null
  then

   -- These portlets call new procedures
   if porttype = 'SEND QUERY'
    then
     edit_portlet_query(surl, portid, portname, porttype, msg );
     return;
   elsif porttype in ('NEWS','QUICKNEWS','CUSTOMERS')
    then
     edit_portlet_news(surl, portid, portname, porttype, msg );
     return;
   elsif porttype in ('WEBSERVICE')
    then
     edit_webservice(surl, portid, portname, porttype, msg );
     return;
   end if;

   select s_portlet_definition.nextval into c1rec.portlet_id from dual;
   c2rec.name := replace(portname,'"');
   c2rec.portlet_id := c1rec.portlet_id;
   c2rec.portlet_type := porttype;
   c2rec.is_enabled := 'T';
   c2rec.pid := owner_id;
   c1rec.background_colour := pfx.text_back;
   c1rec.justify := 'CENTER';
   c1rec.table_data := 'cellspacing=2 cellpadding=2 border=0';
   c1rec.text_font := pfx.text_font;
   c1rec.text_colour := pfx.text_colour;
   c1rec.header_colour := pfx.text_back;
   c1rec.header_font_colour := pfx.text_colour;
   c1rec.cell_colour := pfx.text_back;
   c1rec.cell_colour_alt := pfx.text_back;
   c1rec.text_pitch := 'small';
   c1rec.search_disp_no_img := 'F';
   c1rec.search_incl_expired := 'F';
   c1rec.search_incl_disabled := 'F';
   c1rec.search_ispublic := 'F';
   c1rec.anchor_font := 'arial';
   c1rec.anchor_font := pfx.text_font;
   c1rec.anchor_colour := pfx.text_colour;
   c1rec.anchor_pitch := 'small';
   c1rec.pos_ctr := 1;
   c1rec.pos_acctname := 2;
   c1rec.pos_username := 3;
   c1rec.pos_dateheld := 4;
   c1rec.pos_numbimages := 5;
   c1rec.pos_search := 6;
   c1rec.pos_enabled := 7;
   c1rec.table_parm := 'CELLSPACING=1 CELLPADDING=1 BORDER=1';
   c1rec.target := '_top';
   c1rec.returl_target := '_top';
   c1rec.submit_text := 'Login';
   insert into portlet_definition( portlet_id, pid, name, portlet_type, is_enabled, extra_parm1 ) values (c2rec.portlet_id, c2rec.pid, c2rec.name, c2rec.portlet_type, c2rec.is_enabled, c2rec.extra_parm1 );
   if c2rec.portlet_type = 'LOGIN'
    then
     insert into portlet_login(portlet_id) values (c2rec.portlet_id);
   end if;
 end if;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, c2rec.name, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P81', stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( c2rec.name );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 htp.p('<A HREF="javascript: window.open(''pfm.test_portlet?surl=' || surl || '&portid=' || c1rec.portlet_id || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=700,height=500'');void('''');">' || '[' || LNG5.EXT_TXT_710 || ']' || '</A>');
 htp.nl;

 htp.formopen( 'pfm.accept_edit_portlet' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 htp.formhidden( 'P3', NULL );

 htp.bold( LNG5.EXT_TXT_709 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_675),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SEARCH_ACCTNAME' ) || htf.formtext( 'P2', 30, 100, c1rec.SEARCH_ACCTNAME),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_674),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SEARCH_USERNAME' ) || htf.formtext( 'P2', 30, 100, c1rec.SEARCH_USERNAME),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_676),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SEARCH_JOBREF' ) || htf.formtext( 'P2', 30, 100, c1rec.SEARCH_JOBREF),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_677),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SEARCH_BUS_FTR' ) || htf.formtext( 'P2', 30, 100, c1rec.SEARCH_BUS_FTR),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_678),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c1rec.search_disp_no_img = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'SEARCH_DISP_NO_IMG', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'SEARCH_DISP_NO_IMG' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_679),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c1rec.search_incl_expired = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'SEARCH_INCL_EXPIRED', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'SEARCH_INCL_EXPIRED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_680),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c1rec.search_incl_disabled = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'SEARCH_INCL_DISABLED', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'SEARCH_INCL_DISABLED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_725),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c1rec.search_ispublic = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'SEARCH_ISPUBLIC', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'SEARCH_ISPUBLIC' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_708 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG.GLB_TXT_055),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c2rec.is_enabled = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'IS_ENABLED', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'IS_ENABLED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_708),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'STYLE' );
   htp.formselectopen( 'P2' );
   if c1rec.style = 'URL'
    then
     htp.formselectoption( 'URL', 'SELECTED' );
    else
     htp.formselectoption( 'URL' );
   end if;
   if c1rec.style = 'BUTTON'
    then
     htp.formselectoption( 'BUTTON', 'SELECTED' );
    else
     htp.formselectoption( 'BUTTON' );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  disp_colours('BACKGROUND_COLOUR', c1rec.background_colour, LNG.SLD_TXT_026, pfx );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG.PHG_TXT_015),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BACKGROUND_IMAGE' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.background_image,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;

  disp_colours('TEXT_COLOUR', c1rec.text_colour, LNG5.EXT_TXT_685, pfx );

  disp_colours('ANCHOR_COLOUR', c1rec.anchor_colour, LNG5.EXT_TXT_682, pfx );

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_684),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'TEXT_FONT' );
   htp.formselectopen( 'P2' );
   for c3rec in c3 loop
    if c3rec.font_name = c1rec.text_font
     then
      htp.formselectoption( c3rec.font_name, 'SELECTED' );
     else
      htp.formselectoption( c3rec.font_name );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_681),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'ANCHOR_FONT' );
   htp.formselectopen( 'P2' );
   for c3rec in c3 loop
    if c3rec.font_name = c1rec.anchor_font
     then
      htp.formselectoption( c3rec.font_name, 'SELECTED' );
     else
      htp.formselectoption( c3rec.font_name );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_686),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'TEXT_PITCH' );
   htp.formselectopen( 'P2' );
   for c4rec in c4 loop
    if trim(c4rec.pitch) = c1rec.text_pitch
     then
      htp.formselectoption( trim(c4rec.pitch), 'SELECTED' );
     else
      htp.formselectoption( trim(c4rec.pitch) );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_683),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'ANCHOR_PITCH' );
   htp.formselectopen( 'P2' );
   for c4rec in c4 loop
    if trim(c4rec.pitch) = c1rec.anchor_pitch
     then
      htp.formselectoption( trim(c4rec.pitch), 'SELECTED' );
     else
      htp.formselectoption( trim(c4rec.pitch) );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  disp_colours('HEADER_COLOUR', c1rec.header_colour, LNG5.EXT_TXT_714, pfx );
  disp_colours('HEADER_FONT_COLOUR', c1rec.header_font_colour, LNG5.EXT_TXT_715, pfx );
  disp_colours('CELL_COLOUR', c1rec.cell_colour, LNG5.EXT_TXT_716, pfx );
  disp_colours('CELL_COLOUR_ALT', c1rec.cell_colour_alt, LNG5.EXT_TXT_717, pfx );

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_723),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TARGET' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.target,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_657),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_658),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL_DISPLAY' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl_display,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_665),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c1rec.returl_is_gif = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'RETURL_IS_GIF', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'RETURL_IS_GIF' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_724),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL_TARGET' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl_target,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_707 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   if c1rec.display_columnheader = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_COLUMNHEADER', 'CHECKED' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_COLUMNHEADER' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   end if;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_706),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;

  for j in 1..7 loop

  if nvl(c1rec.pos_ctr,1) = j
   then
    htp.tablerowopen;
     if c1rec.display_ctr = 'T'
      then
      htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_CTR', 'CHECKED' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_CTR' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     end if;
     htp.tabledata(htf.bold(LNG5.EXT_TXT_705),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.formhidden( 'P1', 'TITLE_CTR' ) || htf.formtext( 'P2', 30, 1000, nvl(c1rec.title_ctr,LNG5.EXT_TXT_705)),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">' );
     htp.formhidden( 'P1', 'POS_CTR' );
     pos_loop( c1rec.pos_ctr );
     htp.p( '</TD>' );
    htp.tablerowclose;
  end if;

  if nvl(c1rec.pos_acctname,1) = j
   then
    htp.tablerowopen;
     htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"'); -- Account Name must always be enabled
     htp.tabledata(htf.bold(LNG.PHG_TXT_164),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.formhidden( 'P3', 'DISPLAY_ACCTNAME' ) || htf.formhidden( 'P1', 'TITLE_ACCTNAME' ) || htf.formtext( 'P2', 30, 1000, nvl(c1rec.title_acctname,LNG.PHG_TXT_164)),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">' );
     htp.formhidden( 'P1', 'POS_ACCTNAME' );
     pos_loop( c1rec.pos_acctname );
     htp.p( '</TD>' );
    htp.tablerowclose;
  end if;

  if nvl(c1rec.pos_username,1) = j
   then
    htp.tablerowopen;
     if c1rec.display_username = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_USERNAME', 'CHECKED' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_USERNAME' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     end if;
     htp.tabledata(htf.bold(LNG3.ADM_TXT_063),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.formhidden( 'P1', 'TITLE_USERNAME' ) || htf.formtext( 'P2', 30, 1000, nvl(c1rec.title_username,LNG3.ADM_TXT_063)),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">' );
     htp.formhidden( 'P1', 'POS_USERNAME' );
     pos_loop( c1rec.pos_username );
     htp.p( '</TD>' );
    htp.tablerowclose;
  end if;

  if nvl(c1rec.pos_dateheld,1) = j
   then
    htp.tablerowopen;
     if c1rec.display_dateheld = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_DATEHELD', 'CHECKED' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_DATEHELD' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     end if;
     htp.tabledata(htf.bold(LNG5.EXT_TXT_667),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.formhidden( 'P1', 'TITLE_DATEHELD' ) || htf.formtext( 'P2', 30, 1000, nvl(c1rec.title_dateheld,LNG5.EXT_TXT_667)),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">' );
     htp.formhidden( 'P1', 'POS_DATEHELD' );
     pos_loop( c1rec.pos_dateheld );
     htp.p( '</TD>' );
    htp.tablerowclose;
  end if;

  if nvl(c1rec.pos_numbimages,1) = j
   then
    htp.tablerowopen;
     if c1rec.display_numbimages = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_NUMBIMAGES', 'CHECKED' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_NUMBIMAGES' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     end if;
     htp.tabledata(htf.bold(LNG5.EXT_TXT_704),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.formhidden( 'P1', 'TITLE_NUMBIMAGES' ) || htf.formtext( 'P2', 30, 1000, nvl(c1rec.title_numbimages,LNG5.EXT_TXT_704)),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">' );
     htp.formhidden( 'P1', 'POS_NUMBIMAGES' );
     pos_loop( c1rec.pos_numbimages );
     htp.p( '</TD>' );
    htp.tablerowclose;
  end if;

  if nvl(c1rec.pos_search,1) = j
   then
    htp.tablerowopen;
     if c1rec.display_search = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_SEARCH', 'CHECKED' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_SEARCH' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     end if;
     htp.tabledata(htf.bold(LNG.GLB_TXT_092),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.formhidden( 'P1', 'TITLE_SEARCH' ) || htf.formtext( 'P2', 30, 1000, nvl(c1rec.title_search,LNG.GLB_TXT_092)),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">' );
     htp.formhidden( 'P1', 'POS_SEARCH' );
     pos_loop( c1rec.pos_search );
     htp.p( '</TD>' );
    htp.tablerowclose;
  end if;

  if nvl(c1rec.pos_enabled,1) = j
   then
    htp.tablerowopen;
     if c1rec.display_enabled = 'T'
      then
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_ENABLED', 'CHECKED' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
      else
       htp.tabledata(htf.formcheckbox( 'P3', 'DISPLAY_ENABLED' ),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     end if;
     htp.tabledata(htf.bold(LNG3.ADM_TXT_457),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.formhidden( 'P1', 'TITLE_ENABLED' ) || htf.formtext( 'P2', 30, 1000, nvl(c1rec.title_enabled,'Account Enabled')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">' );
     htp.formhidden( 'P1', 'POS_ENABLED' );
     pos_loop( c1rec.pos_enabled );
     htp.p( '</TD>' );
    htp.tablerowclose;
  end if;

  end loop;

 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_703 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_661),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'HEADER_TITLE' ) || htf.formtext( 'P2', 30, 100, c1rec.HEADER_TITLE),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_660),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BAR_TITLE' ) || htf.formtext( 'P2', 30, 1000, c1rec.BAR_TITLE),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_666),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'INSTRUCTION_TEXT_HDR' ) || htf.formtext( 'P2', 30, 1000, c1rec.INSTRUCTION_TEXT_HDR),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_668),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'INSTRUCTION_TEXT_FTR' ) || htf.formtext( 'P2', 30, 1000, c1rec.INSTRUCTION_TEXT_FTR),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_722),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SUBMIT_TEXT' ) || htf.formtext( 'P2', 30, 100, c1rec.SUBMIT_TEXT),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_702 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_671),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_PARM' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_parm,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_672),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_DATA' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_data,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_673),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_DATA_ALT' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_data_alt,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_659),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BACKGROUND_EXT' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.background_ext,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_670),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'JAVASCRIPT_CODE' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.javascript_code,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_701 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_700 );
 htp.formclose;

 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG.PHG_TXT_352 );
 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.bold(LNG2.PFM_TXT_154);
 htp.formtext( 'PORTNAME', 30, 100 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_693 );
 htp.formclose;

 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.bold(LNG.PHG_TXT_169);
 htp.formtext( 'PORTNAME', 30, 100 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_695 );
 htp.formclose;

 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.formhidden( 'PORTNAME', null );
 htp.bold(LNG.SLD_TXT_004);
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_689 );
 htp.formclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PFM', 'EDIT_PORTLET', owner_id, errmsg=>sqlerrm );
end edit_portlet;

procedure accept_edit_portlet( surl in varchar2, portid in integer default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_login where portlet_id = portid and exists (select pid from portlet_definition where pid = phgid and portlet_id = portid);

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 enbl		char(1);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.ACCEPT_EDIT_PORTLET', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if action = LNG5.EXT_TXT_700 then manage_portlets(surl,LNG5.EXT_TXT_699); return; end if;

 open c1(owner_id, portid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( LNG5.EXT_TXT_697 );
   return;
 end if;
 close c1;

c1rec.style                  := findparm('STYLE',p1,p2);
c1rec.background_colour      := findparm('BACKGROUND_COLOUR',p1,p2);
c1rec.background_image       := findparm('BACKGROUND_IMAGE',p1,p2);
c1rec.background_ext         := findparm('BACKGROUND_EXT',p1,p2);
c1rec.bar_title              := findparm('BAR_TITLE',p1,p2);
c1rec.header_title           := findparm('HEADER_TITLE',p1,p2);
c1rec.justify                := findparm('JUSTIFY',p1,p2);
c1rec.display_columnheader   := findparm3('DISPLAY_COLUMNHEADER',p3);
c1rec.display_ctr            := findparm3('DISPLAY_CTR',p3);
c1rec.display_acctname       := findparm3('DISPLAY_ACCTNAME',p3);
c1rec.display_username       := findparm3('DISPLAY_USERNAME',p3);
c1rec.display_dateheld       := findparm3('DISPLAY_DATEHELD',p3);
c1rec.display_numbimages     := findparm3('DISPLAY_NUMBIMAGES',p3);
c1rec.display_enabled        := findparm3('DISPLAY_ENABLED',p3);
c1rec.display_search         := findparm3('DISPLAY_SEARCH',p3);
c1rec.table_parm             := findparm('TABLE_PARM',p1,p2);
c1rec.table_data             := findparm('TABLE_DATA',p1,p2);
c1rec.table_data_alt         := findparm('TABLE_DATA_ALT',p1,p2);
c1rec.search_username        := findparm('SEARCH_USERNAME',p1,p2);
c1rec.search_acctname        := findparm('SEARCH_ACCTNAME',p1,p2);
c1rec.search_jobref          := findparm('SEARCH_JOBREF',p1,p2);
c1rec.search_bus_ftr         := findparm('SEARCH_BUS_FTR',p1,p2);
c1rec.search_disp_no_img     := findparm3('SEARCH_DISP_NO_IMG',p3);
c1rec.search_incl_expired    := findparm3('SEARCH_INCL_EXPIRED',p3);
c1rec.search_incl_disabled   := findparm3('SEARCH_INCL_DISABLED',p3);
c1rec.search_ispublic        := findparm3('SEARCH_ISPUBLIC',p3);
c1rec.anchor_font            := findparm('ANCHOR_FONT',p1,p2);
c1rec.anchor_colour          := findparm('ANCHOR_COLOUR',p1,p2);
c1rec.anchor_pitch           := findparm('ANCHOR_PITCH',p1,p2);
c1rec.text_font              := findparm('TEXT_FONT',p1,p2);
c1rec.text_colour            := findparm('TEXT_COLOUR',p1,p2);
c1rec.text_pitch             := findparm('TEXT_PITCH',p1,p2);
c1rec.returl                 := findparm('RETURL',p1,p2);
c1rec.returl_display         := findparm('RETURL_DISPLAY',p1,p2);
c1rec.returl_is_gif          := findparm3('RETURL_IS_GIF',p3);
c1rec.instruction_text_hdr   := findparm('INSTRUCTION_TEXT_HDR',p1,p2);
c1rec.instruction_text_ftr   := findparm('INSTRUCTION_TEXT_FTR',p1,p2);
c1rec.title_ctr              := findparm('TITLE_CTR',p1,p2);
c1rec.title_acctname         := findparm('TITLE_ACCTNAME',p1,p2);
c1rec.title_username         := findparm('TITLE_USERNAME',p1,p2);
c1rec.title_dateheld         := findparm('TITLE_DATEHELD',p1,p2);
c1rec.title_numbimages       := findparm('TITLE_NUMBIMAGES',p1,p2);
c1rec.title_search           := findparm('TITLE_SEARCH',p1,p2);
c1rec.title_enabled          := findparm('TITLE_ENABLED',p1,p2);
c1rec.javascript_code        := findparm('JAVASCRIPT_CODE',p1,p2);
c1rec.header_colour          := findparm('HEADER_COLOUR',p1,p2);
c1rec.header_font_colour     := findparm('HEADER_FONT_COLOUR',p1,p2);
c1rec.cell_colour            := findparm('CELL_COLOUR',p1,p2);
c1rec.cell_colour_alt        := findparm('CELL_COLOUR_ALT',p1,p2);
c1rec.pos_ctr 		     := findparm('POS_CTR',p1,p2);
c1rec.pos_acctname 	     := findparm('POS_ACCTNAME',p1,p2);
c1rec.pos_username 	     := findparm('POS_USERNAME',p1,p2);
c1rec.pos_dateheld 	     := findparm('POS_DATEHELD',p1,p2);
c1rec.pos_numbimages 	     := findparm('POS_NUMBIMAGES',p1,p2);
c1rec.pos_search 	     := findparm('POS_SEARCH',p1,p2);
c1rec.pos_enabled 	     := findparm('POS_ENABLED',p1,p2);
c1rec.target	 	     := findparm('TARGET',p1,p2);
c1rec.returl_target	     := findparm('RETURL_TARGET',p1,p2);
c1rec.submit_text 	     := findparm('SUBMIT_TEXT',p1,p2);

enbl := findparm3('IS_ENABLED',p3);

update portlet_definition set is_enabled = enbl where portlet_id = c1rec.portlet_id;

update portlet_login
 set
  STYLE                  = c1rec.STYLE,
  BACKGROUND_COLOUR      = c1rec.BACKGROUND_COLOUR,
  BACKGROUND_IMAGE       = c1rec.BACKGROUND_IMAGE,
  BACKGROUND_EXT         = c1rec.BACKGROUND_EXT,
  BAR_TITLE              = c1rec.BAR_TITLE,
  HEADER_TITLE           = c1rec.HEADER_TITLE,
  JUSTIFY                = c1rec.JUSTIFY,
  DISPLAY_COLUMNHEADER   = c1rec.DISPLAY_COLUMNHEADER,
  DISPLAY_CTR            = c1rec.DISPLAY_CTR,
  DISPLAY_ACCTNAME       = c1rec.DISPLAY_ACCTNAME,
  DISPLAY_USERNAME       = c1rec.DISPLAY_USERNAME,
  DISPLAY_DATEHELD       = c1rec.DISPLAY_DATEHELD,
  DISPLAY_NUMBIMAGES     = c1rec.DISPLAY_NUMBIMAGES,
  DISPLAY_ENABLED        = c1rec.DISPLAY_ENABLED,
  DISPLAY_SEARCH         = c1rec.DISPLAY_SEARCH,
  TABLE_PARM             = c1rec.TABLE_PARM,
  TABLE_DATA             = c1rec.TABLE_DATA,
  TABLE_DATA_ALT         = c1rec.TABLE_DATA_ALT,
  SEARCH_USERNAME        = c1rec.SEARCH_USERNAME,
  SEARCH_ACCTNAME        = c1rec.SEARCH_ACCTNAME,
  SEARCH_JOBREF          = c1rec.SEARCH_JOBREF,
  SEARCH_BUS_FTR         = c1rec.SEARCH_BUS_FTR,
  SEARCH_DISP_NO_IMG     = c1rec.SEARCH_DISP_NO_IMG,
  SEARCH_INCL_EXPIRED    = c1rec.SEARCH_INCL_EXPIRED,
  SEARCH_INCL_DISABLED   = c1rec.SEARCH_INCL_DISABLED,
  SEARCH_ISPUBLIC        = c1rec.SEARCH_ISPUBLIC,
  ANCHOR_FONT            = c1rec.ANCHOR_FONT,
  ANCHOR_COLOUR          = c1rec.ANCHOR_COLOUR,
  ANCHOR_PITCH           = c1rec.ANCHOR_PITCH,
  TEXT_FONT              = c1rec.TEXT_FONT,
  TEXT_COLOUR            = c1rec.TEXT_COLOUR,
  TEXT_PITCH             = c1rec.TEXT_PITCH,
  RETURL                 = c1rec.RETURL,
  RETURL_DISPLAY         = c1rec.RETURL_DISPLAY,
  RETURL_IS_GIF          = c1rec.RETURL_IS_GIF,
  INSTRUCTION_TEXT_HDR   = c1rec.INSTRUCTION_TEXT_HDR,
  INSTRUCTION_TEXT_FTR   = c1rec.INSTRUCTION_TEXT_FTR,
  TITLE_CTR              = c1rec.TITLE_CTR,
  TITLE_ACCTNAME         = c1rec.TITLE_ACCTNAME,
  TITLE_USERNAME         = c1rec.TITLE_USERNAME,
  TITLE_DATEHELD         = c1rec.TITLE_DATEHELD,
  TITLE_NUMBIMAGES       = c1rec.TITLE_NUMBIMAGES,
  TITLE_SEARCH           = c1rec.TITLE_SEARCH,
  TITLE_ENABLED          = c1rec.TITLE_ENABLED,
  JAVASCRIPT_CODE        = c1rec.JAVASCRIPT_CODE,
  HEADER_COLOUR 	 = c1rec.HEADER_COLOUR,
  HEADER_FONT_COLOUR 	 = c1rec.HEADER_FONT_COLOUR,
  CELL_COLOUR 		 = c1rec.CELL_COLOUR,
  CELL_COLOUR_ALT 	 = c1rec.CELL_COLOUR_ALT,
  POS_CTR 		 = c1rec.POS_CTR,
  POS_ACCTNAME 		 = c1rec.POS_ACCTNAME,
  POS_USERNAME		 = c1rec.POS_USERNAME,
  POS_DATEHELD		 = c1rec.POS_DATEHELD,
  POS_NUMBIMAGES 	 = c1rec.POS_NUMBIMAGES,
  POS_SEARCH 		 = c1rec.POS_SEARCH,
  POS_ENABLED 		 = c1rec.POS_ENABLED,
  TARGET                 = c1rec.TARGET,
  RETURL_TARGET          = c1rec.RETURL_TARGET,
  SUBMIT_TEXT            = c1rec.SUBMIT_TEXT
where
 portlet_id = c1rec.portlet_id;
commit;
edit_portlet(surl,c1rec.portlet_id,msg=>LNG5.EXT_TXT_698);

exception when others then
 glbx.error_details( 'PFM', 'ACCEPT_EDIT_PORTLET', owner_id, errmsg=>sqlerrm );
end accept_edit_portlet;

procedure edit_portlet_utility( surl in varchar2, portid in integer default null, portname in varchar2 default null, action in varchar2 )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_definition where pid = phgid and portlet_id = portid;
 cursor c3(tname varchar2) is select column_name from user_tab_columns where table_name = tname and column_name not in ('PORTLET_ID');

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 newid		integer;
 rid		rowid;
 sts		varchar2(100);
 tname		varchar2(100);
 pfx		THEME%ROWTYPE;
 msg		varchar2(1000);
 tmp		varchar2(4000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.EDIT_PORTLET_UTILITY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1(owner_id, portid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( LNG5.EXT_TXT_697 || '-' || portid );
   return;
 end if;
 close c1;

 if action = LNG5.EXT_TXT_689
  then
   delete from portlet_definition where portlet_id = c1rec.portlet_id;
    if c1rec.portlet_type = 'LOGIN'
     then
      delete from portlet_login where portlet_id = c1rec.portlet_id;
    elsif c1rec.portlet_type = 'SEND QUERY'
     then
      delete from portlet_send_query_cols where portlet_id = c1rec.portlet_id;
      delete from portlet_send_query where portlet_id = c1rec.portlet_id;
    elsif c1rec.portlet_type in ('NEWS','QUICKNEWS','CUSTOMERS')
     then
      delete from portlet_news_item where portlet_id = c1rec.portlet_id;
      delete from portlet_news where portlet_id = c1rec.portlet_id;
    end if;
   msg := LNG5.EXT_TXT_696;
 end if;

 if action = LNG5.EXT_TXT_695 and portname is not null
  then
   update portlet_definition set name = replace(portname,'"','') where portlet_id = c1rec.portlet_id;
   msg := LNG5.EXT_TXT_694;
 elsif action = LNG5.EXT_TXT_689 and portname is null
  then
   msg := LNG5.EXT_TXT_691;
 end if;

 if action = LNG5.EXT_TXT_693 and portname is not null
  then
   select s_portlet_definition.nextval into newid from dual;
    if c1rec.portlet_type = 'LOGIN'
     then
      tname := 'PORTLET_LOGIN';
      insert into portlet_login(portlet_id) values (newid);
    elsif c1rec.portlet_type = 'SEND QUERY'
     then
      tname := 'PORTLET_SEND_QUERY';
      insert into portlet_send_query(portlet_id) values (newid);
      insert into portlet_send_query_cols(col_id,portlet_id,display_name,template_name,order_by,field_width,field_height,data_type,cell_colour,text_font,text_colour,text_pitch,lov_values)
       select col_id,newid,display_name,template_name,order_by,field_width,field_height,data_type,cell_colour,text_font,text_colour,text_pitch,lov_values
       from portlet_send_query_cols
       where portlet_id = portlet_id;
       update portlet_send_query_cols
        set col_id = (select nvl(max(col_id),0) + 1 from portlet_send_query_cols)
       where
        portlet_id = newid;
    elsif c1rec.portlet_type in ('NEWS','QUICKNEWS','CUSTOMERS')
     then
      tname := 'PORTLET_NEWS';
      insert into portlet_news(portlet_id) values (newid);
    end if;
    insert into portlet_definition
     select newid,owner_id,portname,portlet_type,is_enabled,extra_parm1 from portlet_definition where portlet_id = c1rec.portlet_id;
    for c3rec in c3(tname) loop
     execute immediate 'select ' || c3rec.column_name || ' from ' || tname || ' where portlet_id = :1'
      into tmp
      using c1rec.portlet_id;
     execute immediate 'update ' || tname || ' set ' || c3rec.column_name || ' = :1 where portlet_id = :2'
      using tmp,newid;
    end loop;
   msg := LNG5.EXT_TXT_692 || ' ' || portname;
 elsif action = LNG5.EXT_TXT_689 and portname is null
  then
   msg := LNG5.EXT_TXT_691;
 end if;

 commit;

 manage_portlets( surl, msg );

exception when others then
 glbx.error_details( 'PFM', 'EDIT_PORTLET_UTILITY', owner_id, errmsg=>sqlerrm );
end edit_portlet_utility;

procedure test_portlet(surl in varchar2, portid in integer)
as

 cursor c1(phgid integer, portid integer) is select * from portlet_definition where portlet_id = portid and pid = phgid;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.TEST_PORTLET', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 -- call to display the portlet
 open c1(owner_id,portid);
 fetch c1 into c1rec;
 close c1;
 glbx.portlet( photographer_id=>owner_id, portlet_name=>c1rec.name );

exception when others then
 glbx.error_details( 'PFM', 'TEST_PORTLET', owner_id, errmsg=>sqlerrm );
end test_portlet;

procedure disp_colours(p1 in varchar2, p2 in varchar2, p3 in varchar2, pfx in theme%ROWTYPE, cellonly in boolean default FALSE )
 as

  cursor c3 is select clr_name,clr_hex from colours order by clr_name;

  tmp		varchar2(10000);
  c_one		varchar2(20);
  foundrec	boolean;

 begin
    if cellonly
     then
      tmp := htf.formselectopen('P6');
     else
      tmp := htf.formselectopen('P2');
    end if;
   if cellonly then tmp := tmp || htf.formselectoption( NULL ); end if;
   foundrec := FALSE;
   for c3rec in c3 loop
    if c3%ROWCOUNT = 1 then c_one := c3rec.clr_hex; end if;
    if c3rec.clr_hex = p2
     then
      foundrec := TRUE;
      tmp := tmp || htf.formselectoption( c3rec.clr_name, 'SELECTED', cattributes=>'VALUE="' || c3rec.clr_hex || '"' );
     else
      tmp := tmp || htf.formselectoption( c3rec.clr_name, cattributes=>'VALUE="' || c3rec.clr_hex || '"' );
    end if;
    end loop;
    if not foundrec -- Colour not found, display hex value as colour
     then
       if p2 is null
        then
         tmp := tmp || htf.formselectoption( '(No Value)', 'SELECTED', cattributes=>'VALUE="' || p2 || '"' );
        else
         tmp := tmp || htf.formselectoption( LNG3.ADM_TXT_351 || '-' || p2, 'SELECTED', cattributes=>'VALUE="' || p2 || '"' );
       end if;
    end if;
    tmp := tmp || htf.formselectclose;
    if cellonly
     then
      htp.tabledata(htf.formhidden( 'P5', p1 ) || tmp,cattributes=>'bgcolor="#' || nvl(p2,c_one) || '"');
     else
      htp.tablerowopen;
       htp.tabledata(htf.bold( p3 ),cattributes=>pfx.qbground || ' valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata(htf.formhidden( 'P1', p1 ) || tmp,cattributes=>pfx.qcbground || ' valign="MIDDLE" ALIGN="LEFT"');
       htp.tabledata('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',cattributes=>'bgcolor="#' || nvl(p2,c_one) || '"');
      htp.tablerowclose;
    end if;
exception when others then
 glbx.error_details( 'PFM', 'DISP_COLOURS', errmsg=>sqlerrm, extdet=>null);
end disp_colours;

function findparm( val in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
 return varchar2
as
begin
 for j in p1.first..p1.last loop
  if p1(j) = val then return( p2(j) ); end if;
 end loop;
 return( NULL );
end findparm;

function findparm3( val in varchar2, p3 in GLBX.MYARRAY )
 return varchar2
as
begin
 for j in p3.first..p3.last loop
  if p3(j) = val then return( 'T' ); end if;
 end loop;
 return( 'F' );
end findparm3;

procedure edit_portlet_query( surl in varchar2, portid in integer default null, portname in varchar2 default null, porttype in varchar2 default null, msg in varchar2 default null )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_send_query where portlet_id = portid and exists (select pid from portlet_definition where pid = phgid and portlet_id = portid);
 cursor c2(phgid integer, portid integer) is select * from portlet_definition where portlet_id = portid and pid = phgid;
 cursor c3 is select font_name from fonts order by font_name;
 cursor c4 is select 'xx-small' pitch from dual union all select 'x-small' pitch from dual union all select 'small' pitch from dual union all select 'medium' pitch from dual union all select 'large' pitch from dual union all select 'x-large' pitch from dual union all select 'xx-large' pitch from dual;
 cursor c5(portid integer) is select * from portlet_send_query_cols where portlet_id = portid order by order_by;
 cursor c6(portid integer) is select * from portlet_send_query_cols where portlet_id = portid and data_type in ('Character','List of Values','Char (Mandatory)','List (Mandatory)','Text Box') order by order_by;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.EDIT_PORTLET_QUERY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if portid is null and portname is null
  then
   manage_portlets( surl, LNG5.EXT_TXT_711 );
   return;
 end if;

 if portid is not null
  then

   open c1(owner_id, portid);
   fetch c1 into c1rec;
   close c1;
   open c2(owner_id,portid);
   fetch c2 into c2rec;
   close c2;
   if c2rec.portlet_id is null
    then
     manage_portlets( surl, LNG5.EXT_TXT_712 );
     return;
   end if;

 else

   select s_portlet_definition.nextval into c1rec.portlet_id from dual;
   c2rec.name := replace(portname,'"');
   c2rec.portlet_id := c1rec.portlet_id;
   c2rec.portlet_type := porttype;
   c2rec.is_enabled := 'T';
   c2rec.pid := owner_id;
   c1rec.background_colour := pfx.text_back;
   c1rec.justify := 'CENTER';
   c1rec.table_parm := 'CELLSPACING=1 CELLPADDING=1 BORDER=1';
   c1rec.table_data := '';
   c1rec.text_font := pfx.text_font;
   c1rec.text_pitch := 'small';
   c1rec.text_colour := pfx.text_colour;
   c1rec.header_colour := pfx.text_back;
   c1rec.header_font_colour := pfx.text_colour;
   c1rec.cell_colour := pfx.text_back;
   c1rec.cell_colour_alt := pfx.text_back;
   c1rec.target := '_top';
   c1rec.returl_target := '_top';
   c1rec.subject_line := 'Query';
   c1rec.submit_text := 'Login';
   c1rec.reset_submit_text := 'Reset Details';
   insert into portlet_definition( portlet_id, pid, name, portlet_type, is_enabled, extra_parm1 ) values (c2rec.portlet_id, c2rec.pid, c2rec.name, c2rec.portlet_type, c2rec.is_enabled, c2rec.extra_parm1 );
   if c2rec.portlet_type = 'SEND QUERY'
    then
     insert into portlet_send_query(portlet_id) values (c2rec.portlet_id);
   end if;
 end if;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, c2rec.name, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P81', stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( c2rec.name );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 htp.p('<A HREF="javascript: window.open(''pfm.test_portlet?surl=' || surl || '&portid=' || c1rec.portlet_id || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=700,height=500'');void('''');">' || '[' || LNG5.EXT_TXT_710 || ']' || '</A>');
 htp.p('<A HREF="javascript: window.open(''pfm.portlet_send_stats?surl=' || surl || '&portid=' || c1rec.portlet_id || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=800,height=600'');void('''');">' || '[' || 'Registration Statistics' || ']' || '</A>');
 htp.nl;

 htp.formopen( 'pfm.accept_edit_portlet_query' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 htp.formhidden( 'P3', NULL );

 htp.bold( LNG5.EXT_TXT_708 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG.GLB_TXT_055),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c2rec.is_enabled = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'IS_ENABLED', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'IS_ENABLED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_708),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'STYLE' );
   htp.formselectopen( 'P2' );
   if c1rec.style = 'STANDARD'
    then
     htp.formselectoption( 'STANDARD', 'SELECTED' );
    else
     htp.formselectoption( 'STANDARD' );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  disp_colours('BACKGROUND_COLOUR', c1rec.background_colour, LNG.SLD_TXT_026, pfx );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG.PHG_TXT_015),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BACKGROUND_IMAGE' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.background_image,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;

  disp_colours('TEXT_COLOUR', c1rec.text_colour, LNG5.EXT_TXT_685, pfx );

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_684),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'TEXT_FONT' );
   htp.formselectopen( 'P2' );
   for c3rec in c3 loop
    if c3rec.font_name = c1rec.text_font
     then
      htp.formselectoption( c3rec.font_name, 'SELECTED' );
     else
      htp.formselectoption( c3rec.font_name );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_686),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'TEXT_PITCH' );
   htp.formselectopen( 'P2' );
   for c4rec in c4 loop
    if trim(c4rec.pitch) = c1rec.text_pitch
     then
      htp.formselectoption( trim(c4rec.pitch), 'SELECTED' );
     else
      htp.formselectoption( trim(c4rec.pitch) );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  disp_colours('HEADER_COLOUR', c1rec.header_colour, LNG5.EXT_TXT_714, pfx );
  disp_colours('HEADER_FONT_COLOUR', c1rec.header_font_colour, LNG5.EXT_TXT_715, pfx );
  disp_colours('CELL_COLOUR', c1rec.cell_colour, LNG5.EXT_TXT_716, pfx );
  disp_colours('CELL_COLOUR_ALT', c1rec.cell_colour_alt, LNG5.EXT_TXT_717, pfx );

  htp.tablerowopen;
   htp.tabledata(htf.bold('Target when Submit Pressed'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TARGET' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.target,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_657),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_658),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL_DISPLAY' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl_display,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_665),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c1rec.returl_is_gif = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'RETURL_IS_GIF', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'RETURL_IS_GIF' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_724),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL_TARGET' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl_target,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_703 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_661),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'HEADER_TITLE' ) || htf.formtext( 'P2', 40, 100, c1rec.HEADER_TITLE),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_660),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BAR_TITLE' ) || htf.formtext( 'P2', 40, 1000, c1rec.BAR_TITLE),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_666),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'INSTRUCTION_TEXT_HDR' ) || htf.formtext( 'P2', 40, 1000, c1rec.INSTRUCTION_TEXT_HDR),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_668),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'INSTRUCTION_TEXT_FTR' ) || htf.formtext( 'P2', 40, 1000, c1rec.INSTRUCTION_TEXT_FTR),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_722),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SUBMIT_TEXT' ) || htf.formtext( 'P2', 40, 100, c1rec.SUBMIT_TEXT),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Reset Button Text'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RESET_SUBMIT_TEXT' ) || htf.formtext( 'P2', 40, 100, c1rec.RESET_SUBMIT_TEXT),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Error Text to Display for Mandatory Fields'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'MANDATORY_TEXT' ) || htf.formtext( 'P2', 40, 100, c1rec.mandatory_text),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_702 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_671),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_PARM' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_parm,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_672),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_DATA' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_data,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_673),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_DATA_ALT' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_data_alt,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_659),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BACKGROUND_EXT' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.background_ext,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_670),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'JAVASCRIPT_CODE' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.javascript_code,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( 'On Send Options' );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold('Subject Line'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SUBJECT_LINE' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.subject_line,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Email Address to Send To'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SENDTO' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.sendto,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Name of the Mail Template to be used'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TEMPLATE' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.template,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Which Value is the Email Field of the Customer?'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'EMAIL_FIELD_IS' );
   htp.formselectopen( 'P2' );
   htp.formselectoption( NULL );
   for c6rec in c6(c1rec.portlet_id) loop
    if c6rec.template_name = c1rec.email_field_is
     then
      htp.formselectoption( c6rec.display_name, cattributes=>'VALUE="' || c6rec.template_name || '"',cselected=>'SELECTED' );
     else
      htp.formselectoption( c6rec.display_name, cattributes=>'VALUE="' || c6rec.template_name || '"' );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Name of the Mail Template to be used to send to the Customer'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'AUTO_CUST_TEMPLATE' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.auto_cust_template,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('HTTP Page to be displayed when details are submitted<BR><i>Specify full HTTP address including HTTP://</i>'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'ON_SUBMIT_PAGE' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.on_submit_page,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('<i>or</i> Text to be displayed if no Submit Page Specified'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'SUBMIT_PAGE_TEXT' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.submit_page_text,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('<i>or</i> Login with this Username'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'ON_SUBMIT_USERNAME' ) || htf.formtext( 'P2', 30, 100, replace(replace(replace(c1rec.on_submit_username,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('<i>optional</i> Login with this Password'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'ON_SUBMIT_PASSWORD' ) || htf.formpassword( 'P2', 30, 100, replace(replace(replace(c1rec.on_submit_password,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('<i>optional</i> Login and run this search'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'ON_SUBMIT_SEARCH' ) || htf.formtext( 'P2', 30, 100, replace(replace(replace(c1rec.on_submit_search,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( 'Values to Prompt for Information' );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold('Order By'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Display Value'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Template Value'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Field Width'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Field Height'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Data Type'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Table Cell Colour'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Text Font'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Text Colour'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Text Pitch'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('Default Value'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold('LOV Values'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  for c5rec in c5(c1rec.portlet_id) loop
   htp.tablerowopen;
    htp.tabledata(htf.formhidden( 'P5', 'COL_ID' ) || htf.formhidden( 'P6', c5rec.col_id ) || htf.formhidden( 'P5', 'ORDER_BY' ) || htf.formtext( 'P6', 5, 20, c5rec.order_by), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'DISPLAY_NAME' ) || htf.formtext( 'P6', 10, 100, c5rec.display_name), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'TEMPLATE_NAME' ) || htf.formtext( 'P6', 10, 100, c5rec.template_name), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'FIELD_WIDTH' ) || htf.formtext( 'P6', 5, 20, c5rec.field_width), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'FIELD_HEIGHT' ) || htf.formtext( 'P6', 5, 20, c5rec.field_height), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
     htp.formhidden( 'P5', 'DATA_TYPE' );
     htp.formselectopen( 'P6' );
      if c5rec.data_type = 'Character' then htp.formselectoption( 'Character', 'SELECTED' ); else htp.formselectoption( 'Character' ); end if;
      if c5rec.data_type = 'List of Values' then htp.formselectoption( 'List of Values', 'SELECTED' ); else htp.formselectoption( 'List of Values' ); end if;
      if c5rec.data_type = 'Char (Mandatory)' then htp.formselectoption( 'Char (Mandatory)', 'SELECTED' ); else htp.formselectoption( 'Char (Mandatory)' ); end if;
      if c5rec.data_type = 'List (Mandatory)' then htp.formselectoption( 'List (Mandatory)', 'SELECTED' ); else htp.formselectoption( 'List (Mandatory)' ); end if;
      if c5rec.data_type = 'Text Box' then htp.formselectoption( 'Text Box', 'SELECTED' ); else htp.formselectoption( 'Text Box' ); end if;
      if c5rec.data_type = 'Checkbox' then htp.formselectoption( 'Checkbox', 'SELECTED' ); else htp.formselectoption( 'Checkbox' ); end if;
      if c5rec.data_type = 'Checkbox (Checked)' then htp.formselectoption( 'Checkbox (Checked)', 'SELECTED' ); else htp.formselectoption( 'Checkbox (Checked)' ); end if;
     htp.formselectclose;
    htp.p( '</TD>' );
    disp_colours('CELL_COLOUR', c5rec.cell_colour, null, pfx, TRUE );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
     htp.formhidden( 'P5', 'TEXT_FONT' );
     htp.formselectopen( 'P6' );
     htp.formselectoption( NULL );
     for c3rec in c3 loop
      if c3rec.font_name = c5rec.text_font
       then
        htp.formselectoption( c3rec.font_name, 'SELECTED' );
       else
        htp.formselectoption( c3rec.font_name );
      end if;
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
    disp_colours('TEXT_COLOUR', c5rec.text_colour, null, pfx, TRUE );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
     htp.formhidden( 'P5', 'TEXT_PITCH' );
     htp.formselectopen( 'P6' );
     htp.formselectoption( NULL );
     for c4rec in c4 loop
      if trim(c4rec.pitch) = c5rec.text_pitch
       then
        htp.formselectoption( trim(c4rec.pitch), 'SELECTED' );
       else
        htp.formselectoption( trim(c4rec.pitch) );
      end if;
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata(htf.formhidden( 'P5', 'DEFAULT_VALUE' ) || htf.formtext( 'P6', 10, 1000, c5rec.default_value), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'LOV_VALUES' ) || htf.formtext( 'P6', 10, 4000, c5rec.lov_values), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
   htp.tablerowclose;
  end loop;
  for j in 1..5 loop
   htp.tablerowopen;
    htp.tabledata(htf.formhidden( 'P5', 'COL_ID' ) || htf.formhidden( 'P6', NULL ) || htf.formhidden( 'P5', 'ORDER_BY' ) || htf.formtext( 'P6', 5, 20), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'DISPLAY_NAME' ) || htf.formtext( 'P6', 10, 100 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'TEMPLATE_NAME' ) || htf.formtext( 'P6', 10, 100 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'FIELD_WIDTH' ) || htf.formtext( 'P6', 5, 20 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'FIELD_HEIGHT' ) || htf.formtext( 'P6', 5, 20 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
     htp.formhidden( 'P5', 'DATA_TYPE' );
     htp.formselectopen( 'P6' );
      htp.formselectoption( 'Character' );
      htp.formselectoption( 'List of Values' );
      htp.formselectoption( 'Char (Mandatory)' );
      htp.formselectoption( 'List (Mandatory)' );
      htp.formselectoption( 'Text Box' );
      htp.formselectoption( 'Checkbox' );
      htp.formselectoption( 'Checkbox (Checked)' );
     htp.formselectclose;
    htp.p( '</TD>' );
    disp_colours('CELL_COLOUR', null, null, pfx, TRUE );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
     htp.formhidden( 'P5', 'TEXT_FONT' );
     htp.formselectopen( 'P6' );
     htp.formselectoption( NULL );
     for c3rec in c3 loop
      htp.formselectoption( c3rec.font_name );
     end loop;
     htp.formselectclose;
    htp.p( '</TD>' );
    disp_colours('TEXT_COLOUR', null, null, pfx, TRUE );
    htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
     htp.formhidden( 'P5', 'TEXT_PITCH' );
     htp.formselectopen( 'P6' );
     htp.formselectoption( NULL );
     for c4rec in c4 loop
      htp.formselectoption( trim(c4rec.pitch) );
    end loop;
    htp.formselectclose;
    htp.p( '</TD>' );
    htp.tabledata(htf.formhidden( 'P5', 'DEFAULT_VALUE' ) || htf.formtext( 'P6', 10, 1000), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.formhidden( 'P5', 'LOV_VALUES' ) || htf.formtext( 'P6', 10, 4000), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
   htp.tablerowclose;
  end loop;
 htp.tableclose;
 htp.nl;


 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_701 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_700 );
 htp.formclose;


 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG.PHG_TXT_352 );
 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.bold(LNG2.PFM_TXT_154);
 htp.formtext( 'PORTNAME', 30, 100 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_693 );
 htp.formclose;

 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.bold(LNG.PHG_TXT_169);
 htp.formtext( 'PORTNAME', 30, 100 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_695 );
 htp.formclose;

 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.formhidden( 'PORTNAME', null );
 htp.bold(LNG.SLD_TXT_004);
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_689 );
 htp.formclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PFM', 'EDIT_PORTLET_QUERY', owner_id, errmsg=>sqlerrm );
end edit_portlet_query;

procedure edit_portlet_news( surl in varchar2, portid in integer default null, portname in varchar2 default null, porttype in varchar2 default null, msg in varchar2 default null )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_news where portlet_id = portid and exists (select pid from portlet_definition where pid = phgid and portlet_id = portid);
 cursor c2(phgid integer, portid integer) is select * from portlet_definition where portlet_id = portid and pid = phgid;
 cursor c3 is select font_name from fonts order by font_name;
 cursor c4 is select 'xx-small' pitch from dual union all select 'x-small' pitch from dual union all select 'small' pitch from dual union all select 'medium' pitch from dual union all select 'large' pitch from dual union all select 'x-large' pitch from dual union all select 'xx-large' pitch from dual;
 cursor c5(portid integer) is select * from portlet_news_item where portlet_id = portid order by order_by;
 cursor c6(phgr integer) is
  select um.umo_id
   from umo um, customer_account ca
   where um.aid in (select aid from customer_account where pid = phgr) and
         um.aid = ca.aid and
         ca.pid = phgr and
         umo_type = 'ICON';
cursor c7(phgid integer) is
 select account_name,title,order_by,display_column,hnews
 from home_news hn, customer_account ca
 where hn.aid= ca.aid and
       ca.pid = phgid
 order by account_name,display_column,order_by;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 http		varchar2(1000);
 width		integer;
 height		integer;
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.EDIT_PORTLET_NEWS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if portid is null and portname is null
  then
   manage_portlets( surl, LNG5.EXT_TXT_711 );
   return;
 end if;

 if portid is not null
  then

   open c1(owner_id, portid);
   fetch c1 into c1rec;
   close c1;
   open c2(owner_id,portid);
   fetch c2 into c2rec;
   close c2;
   if c1rec.portlet_id is null
    then
     manage_portlets( surl, LNG5.EXT_TXT_712 );
     return;
   end if;

 else

   select s_portlet_definition.nextval into c1rec.portlet_id from dual;
   c2rec.name := replace(portname,'"');
   c2rec.portlet_id := c1rec.portlet_id;
   c2rec.portlet_type := porttype;
   c2rec.is_enabled := 'T';
   c2rec.pid := owner_id;
   c1rec.background_colour := pfx.text_back;
   c1rec.justify := 'CENTER';
   c1rec.table_data := 'cellspacing=2 cellpadding=2 border=0';
   c1rec.text_font := pfx.text_font;
   c1rec.text_colour := pfx.text_colour;
   c1rec.header_colour := pfx.text_back;
   c1rec.header_font_colour := pfx.text_colour;
   c1rec.cell_colour := pfx.text_back;
   c1rec.cell_colour_alt := pfx.text_back;
   c1rec.text_pitch := 'small';
   c1rec.text_font := 'arial';
   c1rec.table_parm := 'CELLSPACING=1 CELLPADDING=1 BORDER=1';
   c1rec.target := '_top';
   c1rec.returl_target := '_top';
   c1rec.divider_type := 'LINE';
   insert into portlet_definition( portlet_id, pid, name, portlet_type, is_enabled, extra_parm1 ) values (c2rec.portlet_id, c2rec.pid, c2rec.name, c2rec.portlet_type, c2rec.is_enabled, c2rec.extra_parm1 );
   insert into portlet_news(portlet_id) values (c2rec.portlet_id);
 end if;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, c2rec.name, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P81', stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( c2rec.name );
 if msg is not null then glbx.header_msg( msg ); end if;
 htp.p( '<CENTER>' );

 htp.p('<A HREF="javascript: window.open(''pfm.test_portlet?surl=' || surl || '&portid=' || c1rec.portlet_id || ''',''catwin'',''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=no,resizable=yes,width=700,height=500'');void('''');">' || '[' || LNG5.EXT_TXT_710 || ']' || '</A>');
 htp.nl;

 htp.formopen( 'pfm.accept_edit_portlet_news' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.formhidden( 'P1', NULL );
 htp.formhidden( 'P2', NULL );
 htp.formhidden( 'P3', NULL );

 htp.bold( LNG5.EXT_TXT_708 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG.GLB_TXT_055),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c2rec.is_enabled = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'IS_ENABLED', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'IS_ENABLED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_708),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'STYLE' );
   htp.formselectopen( 'P2' );
   if c1rec.style = 'STANDARD'
    then
     htp.formselectoption( 'STANDARD', 'SELECTED' );
    else
     htp.formselectoption( 'STANDARD' );
   end if;
   htp.p( '</TD>' );
  htp.tablerowclose;
  disp_colours('BACKGROUND_COLOUR', c1rec.background_colour, LNG.SLD_TXT_026, pfx );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG.PHG_TXT_015),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BACKGROUND_IMAGE' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.background_image,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;

  disp_colours('TEXT_COLOUR', c1rec.text_colour, LNG5.EXT_TXT_685, pfx );

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_684),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'TEXT_FONT' );
   htp.formselectopen( 'P2' );
   for c3rec in c3 loop
    if c3rec.font_name = c1rec.text_font
     then
      htp.formselectoption( c3rec.font_name, 'SELECTED' );
     else
      htp.formselectoption( c3rec.font_name );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_686),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formhidden( 'P1', 'TEXT_PITCH' );
   htp.formselectopen( 'P2' );
   for c4rec in c4 loop
    if trim(c4rec.pitch) = c1rec.text_pitch
     then
      htp.formselectoption( trim(c4rec.pitch), 'SELECTED' );
     else
      htp.formselectoption( trim(c4rec.pitch) );
    end if;
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
  htp.tablerowclose;

  disp_colours('HEADER_COLOUR', c1rec.header_colour, LNG5.EXT_TXT_714, pfx );
  disp_colours('HEADER_FONT_COLOUR', c1rec.header_font_colour, LNG5.EXT_TXT_715, pfx );
  disp_colours('CELL_COLOUR', c1rec.cell_colour, LNG5.EXT_TXT_716, pfx );
  disp_colours('CELL_COLOUR_ALT', c1rec.cell_colour_alt, LNG5.EXT_TXT_717, pfx );

  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_723),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TARGET' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.target,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_657),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_658),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL_DISPLAY' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl_display,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_665),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   if c1rec.returl_is_gif = 'T'
    then
     htp.tabledata(htf.formcheckbox( 'P3', 'RETURL_IS_GIF', 'CHECKED' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    else
     htp.tabledata(htf.formcheckbox( 'P3', 'RETURL_IS_GIF' ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
   end if;
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_724),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'RETURL_TARGET' ) || htf.formtext( 'P2', 30, 1000, replace(replace(replace(c1rec.returl_target,'"','&#34;' ),'<','&lt;'),'>','&gt;')),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_703 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_661),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'HEADER_TITLE' ) || htf.formtext( 'P2', 40, 100, c1rec.HEADER_TITLE),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_660),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BAR_TITLE' ) || htf.formtext( 'P2', 40, 1000, c1rec.BAR_TITLE),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_666),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'INSTRUCTION_TEXT_HDR' ) || htf.formtext( 'P2', 40, 1000, c1rec.INSTRUCTION_TEXT_HDR),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_668),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'INSTRUCTION_TEXT_FTR' ) || htf.formtext( 'P2', 40, 1000, c1rec.INSTRUCTION_TEXT_FTR),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 htp.bold( LNG5.EXT_TXT_702 );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_671),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_PARM' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_parm,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_672),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_DATA' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_data,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_673),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'TABLE_DATA_ALT' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.table_data_alt,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_659),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'BACKGROUND_EXT' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.background_ext,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold(LNG5.EXT_TXT_670),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.formhidden( 'P1', 'JAVASCRIPT_CODE' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.javascript_code,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if c2rec.portlet_type = 'QUICKNEWS'
  then
   htp.bold( 'Additional Display Options' );
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold('News Divider Style'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
     htp.formhidden( 'P1', 'DIVIDER_TYPE' );
     htp.formselectopen( 'P2' );
     if c1rec.divider_type = 'LINE'
      then
       htp.formselectoption( 'LINE', 'SELECTED' );
      else
       htp.formselectoption( 'LINE' );
     end if;
     htp.formselectclose;
     htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
     htp.tabledata(htf.bold('Extra Divider Code'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.formhidden( 'P1', 'DIVIDER_CODE' ) || htf.formtextareaopen( 'P2', 5, 30 ) || replace(replace(replace(c1rec.divider_code,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose,cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
    htp.tablerowclose;
   htp.tableclose;
   htp.nl;
 end if;

 if c2rec.portlet_type = 'NEWS'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold('Order By'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('Column'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('News Item'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tablerowclose;
    for c5rec in c5(c2rec.portlet_id) loop
     htp.tablerowopen;
       htp.tabledata(htf.formhidden( 'P5', 'ORDER_BY' ) || htf.formtext( 'P6', 5, 20, c5rec.order_by), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formhidden( 'P5', 'COLUMN_1_2' );
        htp.formselectopen( 'P6' );
        if nvl(c5rec.column_1_2,'1') = '1'
         then
          htp.formselectoption( '1', 'SELECTED' );
          htp.formselectoption( '2' );
          htp.formselectoption( '3' );
         elsif c5rec.column_1_2 = '2'
         then
          htp.formselectoption( '1' );
          htp.formselectoption( '2', 'SELECTED' );
          htp.formselectoption( '3' );
         else
          htp.formselectoption( '1' );
          htp.formselectoption( '2' );
          htp.formselectoption( '3', 'SELECTED' );
        end if;
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formhidden( 'P5', 'NEWS_ITEM_OR_UMO_ID' );
        htp.formselectopen( 'P6' );
        htp.formselectoption( NULL );
        for c7rec in c7( owner_id ) loop
         if c7rec.hnews = c5rec.news_item_or_umo_id
          then
           htp.formselectoption( c7rec.account_name || '-' || nvl(c7rec.title,LNG5.EXT_TXT_057), 'SELECTED', cattributes=>'VALUE="' || c7rec.hnews || '"' );
          else
           htp.formselectoption( c7rec.account_name || '-' || nvl(c7rec.title,LNG5.EXT_TXT_057), cattributes=>'VALUE="' || c7rec.hnews || '"' );
         end if;
        end loop;
       htp.formselectclose;
       htp.formhidden( 'P5', 'NEWS_TEXT_STYLE' );
       htp.formhidden( 'P6', NULL );
      htp.p( '</TD>' );
     htp.tablerowclose;
    end loop;
    for j in 1..5 loop
     htp.tablerowopen;
       htp.tabledata(htf.formhidden( 'P5', 'ORDER_BY' ) || htf.formtext( 'P6', 5, 20 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formhidden( 'P5', 'NEWS_ITEM_OR_UMO_ID' );
        htp.formselectopen( 'P6' );
        htp.formselectoption( '1', 'SELECTED' );
        htp.formselectoption( '2' );
        htp.formselectoption( '3' );
        htp.formselectclose;
       htp.p( '</TD>' );
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formhidden( 'P5', 'NEWS_ITEM_OR_UMO_ID' );
        htp.formselectopen( 'P6' );
        htp.formselectoption( NULL );
        for c7rec in c7( owner_id ) loop
         htp.formselectoption( c7rec.account_name || '-' || nvl(c7rec.title,LNG5.EXT_TXT_057), cattributes=>'VALUE="' || c7rec.hnews || '"' );
        end loop;
       htp.formselectclose;
       htp.formhidden( 'P5', 'NEWS_TEXT_STYLE' );
       htp.formhidden( 'P6', NULL );
      htp.p( '</TD>' );
     htp.tablerowclose;
    end loop;
  htp.tableclose;

 elsif c2rec.portlet_type = 'QUICKNEWS'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold('Order By'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('News Title'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('Title HTML'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('News Body'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('Body HTML'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tablerowclose;
    for c5rec in c5(c2rec.portlet_id) loop
     htp.tablerowopen;
      htp.tabledata(htf.formhidden( 'P5', 'ORDER_BY' ) || htf.formtext( 'P6', 5, 20, c5rec.order_by), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TITLE' ) || htf.formtext( 'P6', 20, 1000, c5rec.news_title), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TITLE_STYLE' ) || htf.formtextareaopen( 'P6', 3, 30, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c5rec.news_title_style,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TEXT' ) || htf.formtextareaopen( 'P6', 3, 30, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c5rec.news_text,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TEXT_STYLE' ) || htf.formtextareaopen( 'P6', 3, 30, cattributes=>'WRAP="VIRTUAL"' ) || replace(replace(replace(c5rec.news_text_style,'"','&#34;' ),'<','&lt;'),'>','&gt;') || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    end loop;
    for j in 1..5 loop
     htp.tablerowopen;
      htp.tabledata(htf.formhidden( 'P5', 'ORDER_BY' ) || htf.formtext( 'P6', 5, 20 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TITLE' ) || htf.formtext( 'P6', 20, 1000), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TITLE_STYLE' ) || htf.formtextareaopen( 'P6', 3, 30, cattributes=>'WRAP="VIRTUAL"' ) || null || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TEXT' ) || htf.formtextareaopen( 'P6', 3, 30, cattributes=>'WRAP="VIRTUAL"' ) || null || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TEXT_STYLE' ) || htf.formtextareaopen( 'P6', 3, 30, cattributes=>'WRAP="VIRTUAL"' ) || null || htf.formtextareaclose, cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
     htp.tablerowclose;
    end loop;
   htp.tableclose;

 elsif c2rec.portlet_type = 'CUSTOMERS'
  then
   htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
    htp.tablerowopen;
     htp.tabledata(htf.bold('Order By'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('Icon'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('Column'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('Additional Text'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('Additional Text HTML'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
     htp.tabledata(htf.bold('&nbsp;'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
    htp.tablerowclose;
    for c5rec in c5(c2rec.portlet_id) loop
     width := to_number(ump.uma_attribute( surl, c5rec.news_item_or_umo_id, 'ICON', 'DISPLAY_WIDTH' ));
     height := to_number(ump.uma_attribute( surl, c5rec.news_item_or_umo_id, 'ICON', 'DISPLAY_HEIGHT' ));
     htp.tablerowopen;
       htp.tabledata(htf.formhidden( 'P5', 'ORDER_BY' ) || htf.formtext( 'P6', 5, 20, c5rec.order_by), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formhidden( 'P5', 'NEWS_ITEM_OR_UMO_ID' );
        htp.formselectopen( 'P6' );
        htp.formselectoption( NULL );
        for c6rec in c6( owner_id ) loop
         http := ump.uma_attribute( surl, c6rec.umo_id, 'ICON', 'HTTP_LINK' );
         if c6rec.umo_id = c5rec.news_item_or_umo_id
          then
           htp.formselectoption( nvl(http || '[' || c6rec.umo_id || ']',c6rec.umo_id), 'SELECTED', cattributes=>'VALUE="' || c6rec.umo_id || '"' );
          else
           htp.formselectoption( nvl(http || '[' || c6rec.umo_id || ']',c6rec.umo_id), cattributes=>'VALUE="' || c6rec.umo_id || '"' );
         end if;
        end loop;
       htp.formselectclose;
      htp.p( '</TD>' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
       htp.formhidden( 'P5', 'COLUMN_1_2' );
       htp.formselectopen( 'P6' );
       if nvl(c5rec.column_1_2,'1') = '1'
        then
         htp.formselectoption( '1', 'SELECTED' );
         htp.formselectoption( '2' );
        else
         htp.formselectoption( '1' );
         htp.formselectoption( '2', 'SELECTED' );
       end if;
       htp.formselectclose;
      htp.p( '</TD>' );
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TITLE' ) || htf.formtext( 'P6', 20, 1000, c5rec.news_title), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.formhidden( 'P5', 'NEWS_TITLE_STYLE' ) || htf.formtext( 'P6', 20, 1000, replace(replace(replace(c5rec.news_title_style,'"','&#34;' ),'<','&lt;'),'>','&gt;')), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.formhidden( 'P5', 'NEWS_TEXT_STYLE' ) || htf.formhidden( 'P6', NULL ) ||
           '<IMG BORDER=0 WIDTH=' || width || ' HEIGHT=' || height || ' SRC="' ||
           'ump.retrieve_uma?surl=' || glbx.truncsurl(surl) || '&parm1=UMO_ID&parm2=' || c5rec.news_item_or_umo_id || '&parm1=DISPLAY_TYPE&parm2=RAW&parm1=DISPLAY_WHAT&parm2=MASTER&parm1=VERSION&parm2=' ||
           '&parm1=LOGIN_TYPE&parm2=PHOTOGRAPHER&parm1=AID&parm2=' || to_char(c5rec.aid) || '" ' ||
           'ALT="' || 'ICON' || '" STYLE="display:block;">', cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"' );
      htp.tablerowclose;
    end loop;
    for j in 1..5 loop
     htp.tablerowopen;
       htp.tabledata(htf.formhidden( 'P5', 'ORDER_BY' ) || htf.formtext( 'P6', 5, 20 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
       htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
        htp.formhidden( 'P5', 'NEWS_ITEM_OR_UMO_ID' );
        htp.formselectopen( 'P6' );
        htp.formselectoption( NULL );
        for c6rec in c6( owner_id ) loop
         http := ump.uma_attribute( surl, c6rec.umo_id, 'ICON', 'HTTP_LINK' );
         htp.formselectoption( nvl(http || '[' || c6rec.umo_id || ']',c6rec.umo_id), cattributes=>'VALUE="' || c6rec.umo_id || '"' );
        end loop;
       htp.formselectclose;
      htp.p( '</TD>' );
      htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
       htp.formhidden( 'P5', 'NEWS_ITEM_OR_UMO_ID' );
       htp.formselectopen( 'P6' );
       htp.formselectoption( '1', 'SELECTED' );
       htp.formselectoption( '2' );
       htp.formselectclose;
      htp.p( '</TD>' );
      htp.tabledata( htf.formhidden( 'P5', 'NEWS_TITLE' ) || htf.formtext( 'P6', 20, 1000), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.formhidden( 'P5', 'NEWS_TITLE_STYLE' ) || htf.formtext( 'P6', 20, 1000 ), cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( htf.formhidden( 'P5', 'NEWS_TEXT_STYLE' ) || htf.formhidden( 'P6', NULL ) || '&nbsp;', cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
      htp.tablerowclose;
    end loop;
   htp.tableclose;
 end if;

 htp.nl;
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_701 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_700 );
 htp.formclose;

 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG.PHG_TXT_352 );
 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.bold(LNG2.PFM_TXT_154);
 htp.formtext( 'PORTNAME', 30, 100 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_693 );
 htp.formclose;

 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.bold(LNG.PHG_TXT_169);
 htp.formtext( 'PORTNAME', 30, 100 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_695 );
 htp.formclose;

 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.formhidden( 'PORTNAME', null );
 htp.bold(LNG.SLD_TXT_004);
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_689 );
 htp.formclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PFM', 'EDIT_PORTLET_NEWS', owner_id, errmsg=>sqlerrm );
end edit_portlet_news;

procedure accept_edit_portlet_query( surl in varchar2, portid in integer default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_send_query where portlet_id = portid and exists (select pid from portlet_definition where pid = phgid and portlet_id = portid);

 c1rec		c1%ROWTYPE;
 colrec		portlet_send_query_cols%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 enbl		char(1);
 pfx		THEME%ROWTYPE;
 nmb		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.ACCEPT_EDIT_PORTLET_QUERY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if action = LNG5.EXT_TXT_700 then manage_portlets(surl,LNG5.EXT_TXT_699); return; end if;

 open c1(owner_id, portid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( LNG5.EXT_TXT_697 );
   return;
 end if;
 close c1;

c1rec.style                  := findparm('STYLE',p1,p2);
c1rec.background_colour      := findparm('BACKGROUND_COLOUR',p1,p2);
c1rec.background_image       := findparm('BACKGROUND_IMAGE',p1,p2);
c1rec.background_ext         := findparm('BACKGROUND_EXT',p1,p2);
c1rec.bar_title              := findparm('BAR_TITLE',p1,p2);
c1rec.header_title           := findparm('HEADER_TITLE',p1,p2);
c1rec.justify                := findparm('JUSTIFY',p1,p2);
c1rec.table_parm             := findparm('TABLE_PARM',p1,p2);
c1rec.table_data             := findparm('TABLE_DATA',p1,p2);
c1rec.table_data_alt         := findparm('TABLE_DATA_ALT',p1,p2);
c1rec.text_font              := findparm('TEXT_FONT',p1,p2);
c1rec.text_colour            := findparm('TEXT_COLOUR',p1,p2);
c1rec.text_pitch             := findparm('TEXT_PITCH',p1,p2);
c1rec.returl                 := findparm('RETURL',p1,p2);
c1rec.returl_display         := findparm('RETURL_DISPLAY',p1,p2);
c1rec.returl_is_gif          := findparm3('RETURL_IS_GIF',p3);
c1rec.instruction_text_hdr   := findparm('INSTRUCTION_TEXT_HDR',p1,p2);
c1rec.instruction_text_ftr   := findparm('INSTRUCTION_TEXT_FTR',p1,p2);
c1rec.javascript_code        := findparm('JAVASCRIPT_CODE',p1,p2);
c1rec.header_colour          := findparm('HEADER_COLOUR',p1,p2);
c1rec.header_font_colour     := findparm('HEADER_FONT_COLOUR',p1,p2);
c1rec.cell_colour            := findparm('CELL_COLOUR',p1,p2);
c1rec.cell_colour_alt        := findparm('CELL_COLOUR_ALT',p1,p2);
c1rec.target	 	     := findparm('TARGET',p1,p2);
c1rec.returl_target	     := findparm('RETURL_TARGET',p1,p2);
c1rec.submit_text 	     := findparm('SUBMIT_TEXT',p1,p2);
c1rec.subject_line 	     := findparm('SUBJECT_LINE',p1,p2);
c1rec.sendto	 	     := findparm('SENDTO',p1,p2);
c1rec.template	 	     := findparm('TEMPLATE',p1,p2);
c1rec.email_field_is 	     := findparm('EMAIL_FIELD_IS',p1,p2);
c1rec.auto_cust_template     := findparm('AUTO_CUST_TEMPLATE',p1,p2);
c1rec.on_submit_page 	     := findparm('ON_SUBMIT_PAGE',p1,p2);
c1rec.on_submit_username     := findparm('ON_SUBMIT_USERNAME',p1,p2);
c1rec.on_submit_password     := findparm('ON_SUBMIT_PASSWORD',p1,p2);
c1rec.on_submit_search 	     := findparm('ON_SUBMIT_SEARCH',p1,p2);
c1rec.submit_page_text 	     := findparm('SUBMIT_PAGE_TEXT',p1,p2);
c1rec.reset_submit_text	     := findparm('RESET_SUBMIT_TEXT',p1,p2);
c1rec.mandatory_text	     := findparm('MANDATORY_TEXT',p1,p2);

enbl := findparm3('IS_ENABLED',p3);

update portlet_definition set is_enabled = enbl where portlet_id = c1rec.portlet_id;

update portlet_send_query
 set
  STYLE                  = c1rec.STYLE,
  BACKGROUND_COLOUR      = c1rec.BACKGROUND_COLOUR,
  BACKGROUND_IMAGE       = c1rec.BACKGROUND_IMAGE,
  BACKGROUND_EXT         = c1rec.BACKGROUND_EXT,
  BAR_TITLE              = c1rec.BAR_TITLE,
  HEADER_TITLE           = c1rec.HEADER_TITLE,
  JUSTIFY                = c1rec.JUSTIFY,
  TABLE_PARM             = c1rec.TABLE_PARM,
  TABLE_DATA             = c1rec.TABLE_DATA,
  TABLE_DATA_ALT         = c1rec.TABLE_DATA_ALT,
  TEXT_FONT              = c1rec.TEXT_FONT,
  TEXT_COLOUR            = c1rec.TEXT_COLOUR,
  TEXT_PITCH             = c1rec.TEXT_PITCH,
  RETURL                 = c1rec.RETURL,
  RETURL_DISPLAY         = c1rec.RETURL_DISPLAY,
  RETURL_IS_GIF          = c1rec.RETURL_IS_GIF,
  INSTRUCTION_TEXT_HDR   = c1rec.INSTRUCTION_TEXT_HDR,
  INSTRUCTION_TEXT_FTR   = c1rec.INSTRUCTION_TEXT_FTR,
  JAVASCRIPT_CODE        = c1rec.JAVASCRIPT_CODE,
  HEADER_COLOUR 	 = c1rec.HEADER_COLOUR,
  HEADER_FONT_COLOUR 	 = c1rec.HEADER_FONT_COLOUR,
  CELL_COLOUR 		 = c1rec.CELL_COLOUR,
  CELL_COLOUR_ALT 	 = c1rec.CELL_COLOUR_ALT,
  TARGET                 = c1rec.TARGET,
  RETURL_TARGET          = c1rec.RETURL_TARGET,
  SUBJECT_LINE           = c1rec.SUBJECT_LINE,
  SUBMIT_TEXT            = c1rec.SUBMIT_TEXT,
  SENDTO		 = c1rec.SENDTO,
  TEMPLATE		 = c1rec.TEMPLATE,
  EMAIL_FIELD_IS	 = c1rec.EMAIL_FIELD_IS,
  AUTO_CUST_TEMPLATE	 = c1rec.AUTO_CUST_TEMPLATE,
  ON_SUBMIT_PAGE	 = c1rec.ON_SUBMIT_PAGE,
  ON_SUBMIT_USERNAME	 = C1REC.ON_SUBMIT_USERNAME,
  ON_SUBMIT_PASSWORD	 = C1REC.ON_SUBMIT_PASSWORD,
  ON_SUBMIT_SEARCH	 = C1REC.ON_SUBMIT_SEARCH,
  SUBMIT_PAGE_TEXT	 = c1rec.SUBMIT_PAGE_TEXT,
  RESET_SUBMIT_TEXT	 = c1rec.RESET_SUBMIT_TEXT,
  MANDATORY_TEXT	 = c1rec.MANDATORY_TEXT
where
 portlet_id = c1rec.portlet_id;
commit;

delete from portlet_send_query_cols where portlet_id = c1rec.portlet_id;

for j in p5.first..p5.last loop
 if p5(j) = 'DISPLAY_NAME'
  then
   colrec.display_name := p6(j);
 elsif p5(j) = 'TEMPLATE_NAME'
  then
   colrec.template_name := upper(nvl(p6(j),colrec.display_name));
 elsif p5(j) = 'ORDER_BY'
  then
   begin nmb := to_number(p6(j)); exception when others then nmb := 99; end;
   colrec.order_by := nmb;
 elsif p5(j) = 'FIELD_WIDTH'
  then
   begin nmb := to_number(p6(j)); exception when others then nmb := 1; end;
   colrec.field_width := nmb;
 elsif p5(j) = 'FIELD_HEIGHT'
  then
   begin nmb := to_number(p6(j)); exception when others then nmb := 1; end;
   colrec.field_height := nmb;
 elsif p5(j) = 'DATA_TYPE'
  then
   colrec.data_type := p6(j);
 elsif p5(j) = 'CELL_COLOUR'
  then
   colrec.cell_colour := p6(j);
 elsif p5(j) = 'TEXT_FONT'
  then
   colrec.text_font := p6(j);
 elsif p5(j) = 'TEXT_COLOUR'
  then
   colrec.text_colour := p6(j);
 elsif p5(j) = 'TEXT_PITCH'
  then
   colrec.text_pitch := p6(j);
 elsif p5(j) = 'DEFAULT_VALUE'
  then
   colrec.default_value := p6(j);
 elsif p5(j) = 'LOV_VALUES'
  then
   colrec.lov_values := p6(j);
   select max(col_id) into colrec.col_id from portlet_send_query_cols;
   colrec.col_id := nvl(colrec.col_id,0) + 1;
   if (colrec.order_by is null and colrec.display_name is null and colrec.template_name is null)
    then
     null;
    else
     insert into portlet_send_query_cols(col_id,portlet_id,display_name,template_name,
                                         order_by,field_width,field_height,data_type,cell_colour,
                                         text_font,text_colour,text_pitch,default_value,lov_values)
       values(colrec.col_id,c1rec.portlet_id,colrec.display_name,colrec.template_name,
              colrec.order_by,colrec.field_width,colrec.field_height,colrec.data_type,colrec.cell_colour,
              colrec.text_font,colrec.text_colour,colrec.text_pitch,colrec.default_value,colrec.lov_values );
   end if;
 end if;
end loop;
commit;

edit_portlet_query(surl,c1rec.portlet_id,msg=>LNG5.EXT_TXT_698);

exception when others then
 glbx.error_details( 'PFM', 'ACCEPT_EDIT_PORTLET_QUERY', owner_id, errmsg=>sqlerrm );
end accept_edit_portlet_query;

procedure portlet_send_stats(surl in varchar2, portid in integer)
as

 cursor c1(phgid integer, portid integer) is select * from portlet_definition where portlet_id = portid and pid = phgid;
 cursor c2(phgid integer, portid integer) is select count(distinct result_id) tot, min(date_created) mn, max(date_created) mx from portlet_send_results where portlet_id = portid and pid = phgid;
 cursor c3(portid integer) is select display_name,template_name from portlet_send_query_cols where portlet_id = portid order by order_by;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.PORTLET_SEND_STATS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1(owner_id,portid);
 fetch c1 into c1rec;
 close c1;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, 'Statistics for' || ':' || c1rec.name, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P82', stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( c1rec.name );
 htp.p( '<CENTER>' );

 open c2(owner_id,portid);
 fetch c2 into c2rec;
 close c2;
 htp.bold( 'Statistics on Registrations' );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold('Number of Registrations'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold( c2rec.tot),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Earliest Registration Date'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold( to_char( c2rec.mn,LNG.TSMASK )),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Latest Registration Date'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.tabledata(htf.bold( to_char( c2rec.mx,LNG.TSMASK )),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
 htp.tableclose;

 -- Display Search Screen
 htp.nl;
 htp.bold( 'Search on' );
 htp.formopen( 'pfm.portlet_send_search' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', portid );
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
   htp.tabledata(htf.bold('Value Matches'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formselectopen( 'P1A' );
   for c3rec in c3(c1rec.portlet_id) loop
    htp.formselectoption( c3rec.display_name, cattributes=>'VALUE="' || c3rec.template_name || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata(htf.formtext( 'P2A', 30, 100 ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formselectopen( 'P3A' );
   htp.formselectoption( 'and' );
   htp.formselectoption( 'or' );
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Value Matches'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formselectopen( 'P1B' );
   htp.formselectoption( NULL );
   for c3rec in c3(c1rec.portlet_id) loop
    htp.formselectoption( c3rec.display_name, cattributes=>'VALUE="' || c3rec.template_name || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata(htf.formtext( 'P2B', 30, 100 ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata('&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formselectopen( 'P3B' );
   htp.formselectoption( 'and' );
   htp.formselectoption( 'or' );
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata('&nbsp;',cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata(htf.bold('Value Matches'),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
   htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="CENTER">');
   htp.formselectopen( 'P1C' );
   htp.formselectoption( NULL );
   for c3rec in c3(c1rec.portlet_id) loop
    htp.formselectoption( c3rec.display_name, cattributes=>'VALUE="' || c3rec.template_name || '"' );
   end loop;
   htp.formselectclose;
   htp.p( '</TD>' );
   htp.tabledata(htf.formtext( 'P2C', 30, 100 ),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  htp.tablerowclose;

 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Search' );
 htp.formclose;
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PFM', 'PORTLET_SEND_STATS', owner_id, errmsg=>sqlerrm );
end portlet_send_stats;

procedure portlet_send_search(surl in varchar2, portid in integer, p1a in varchar2, p1b in varchar2, p1c in varchar2, p2a in varchar2, p2b in varchar2, p2c in varchar2, p3a in varchar2, p3b in varchar2 )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_definition where portlet_id = portid and pid = phgid;
 -- XXX Not finished
 cursor c2(phgid integer, portid integer) is select * from portlet_send_results where result_id in
  (
   select result_id from portlet_send_results where portlet_id = portid and pid = phgid and parm1 = p1a and upper(parm2) like '%' || upper(replace(p2a,'*','%')) || '%'
  )
  order by date_created desc,order_by;
 cursor c3(phgid integer, portid integer) is select distinct parm1, order_by from portlet_send_results where portlet_id = portid and pid = phgid order by 2;

 c1rec		c1%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 pfx		THEME%ROWTYPE;
 lastres	integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.PORTLET_SEND_SEARCH', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 open c1(owner_id,portid);
 fetch c1 into c1rec;
 close c1;

 pfx := glbx.photo_lf(owner_id);
 glbx.main_title( surl, 'Search Results for' || ':' || c1rec.name, glbx.backimg(surl,null,pfx.text_back,null,ltype),helpid=>'P81', stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( c1rec.name );
 htp.p( '<CENTER>' );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=1 cellspacing=1 border=1' );
  htp.tablerowopen;
  for c3rec in c3(owner_id, portid) loop
   htp.tabledata(htf.bold(c3rec.parm1),cattributes=>pfx.qbground || 'valign="TOP" align="CENTER"');
  end loop;
  htp.tablerowclose;
  htp.tablerowopen;
  lastres := 0;
  for c2rec in c2(owner_id,portid) loop
   if c2rec.result_id <> lastres
    then
     if lastres > 0 then htp.tablerowclose; end if;
     htp.tablerowopen;
     lastres := c2rec.result_id;
   end if;
   htp.tabledata(nvl(c2rec.parm2,c2rec.parm3),cattributes=>pfx.qcbground || 'valign="TOP" align="CENTER"');
  end loop;
  htp.tablerowclose;
 htp.tableclose;
 htp.anchor( 'pfm.portlet_send_stats?surl=' || surl || '&portid=' || portid, 'Previous Screen' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PFM', 'PORTLET_SEND_SEARCH', owner_id, errmsg=>sqlerrm );
end portlet_send_search;

procedure accept_edit_portlet_news( surl in varchar2, portid in integer default null, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY, p5 in GLBX.MYARRAY, p6 in GLBX.MYARRAY, action in varchar2 )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_news where portlet_id = portid and exists (select pid from portlet_definition where pid = phgid and portlet_id = portid);
 cursor c2(portid integer) is select * from portlet_definition where portlet_id = portid;
 cursor c3(hmn integer) is select aid from home_news where hnews = hmn;
 cursor c4(v_umo integer, owner_id integer) is select aid from umo where umo_id = v_umo and umo_type = 'ICON' and aid in (select aid from customer_account where pid = owner_id);

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 colrec		portlet_news_item%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 enbl		char(1);
 pfx		THEME%ROWTYPE;
 nmb		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.ACCEPT_EDIT_PORTLET_QUERY', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if action = LNG5.EXT_TXT_700 then manage_portlets(surl,LNG5.EXT_TXT_699); return; end if;

 open c1(owner_id, portid);
 fetch c1 into c1rec;
 if c1%NOTFOUND
  then
   close c1;
   htp.bold( LNG5.EXT_TXT_697 );
   return;
 end if;
 close c1;

 open c2(c1rec.portlet_id);
 fetch c2 into c2rec;
 close c2;

c1rec.style                  := findparm('STYLE',p1,p2);
c1rec.justify                := findparm('JUSTIFY',p1,p2);
c1rec.background_colour      := findparm('BACKGROUND_COLOUR',p1,p2);
c1rec.background_image       := findparm('BACKGROUND_IMAGE',p1,p2);
c1rec.text_colour            := findparm('TEXT_COLOUR',p1,p2);
c1rec.text_font              := findparm('TEXT_FONT',p1,p2);
c1rec.text_pitch             := findparm('TEXT_PITCH',p1,p2);
c1rec.header_colour          := findparm('HEADER_COLOUR',p1,p2);
c1rec.header_font_colour     := findparm('HEADER_FONT_COLOUR',p1,p2);
c1rec.cell_colour            := findparm('CELL_COLOUR',p1,p2);
c1rec.cell_colour_alt        := findparm('CELL_COLOUR_ALT',p1,p2);
c1rec.returl                 := findparm('RETURL',p1,p2);
c1rec.returl_display         := findparm('RETURL_DISPLAY',p1,p2);
c1rec.returl_is_gif          := findparm3('RETURL_IS_GIF',p3);
c1rec.returl_target	     := findparm('RETURL_TARGET',p1,p2);
c1rec.bar_title              := findparm('BAR_TITLE',p1,p2);
c1rec.header_title           := findparm('HEADER_TITLE',p1,p2);
c1rec.instruction_text_hdr   := findparm('INSTRUCTION_TEXT_HDR',p1,p2);
c1rec.instruction_text_ftr   := findparm('INSTRUCTION_TEXT_FTR',p1,p2);
c1rec.table_parm             := findparm('TABLE_PARM',p1,p2);
c1rec.table_data             := findparm('TABLE_DATA',p1,p2);
c1rec.table_data_alt         := findparm('TABLE_DATA_ALT',p1,p2);
c1rec.background_ext         := findparm('BACKGROUND_EXT',p1,p2);
c1rec.javascript_code        := findparm('JAVASCRIPT_CODE',p1,p2);
c1rec.target	 	     := findparm('TARGET',p1,p2);
c1rec.divider_type	     := findparm('DIVIDER_TYPE',p1,p2);
c1rec.divider_code	     := findparm('DIVIDER_CODE',p1,p2);

enbl := findparm3('IS_ENABLED',p3);

update portlet_definition set is_enabled = enbl where portlet_id = c1rec.portlet_id;

update portlet_news
 set
  STYLE                  = c1rec.STYLE,
  BACKGROUND_COLOUR      = c1rec.BACKGROUND_COLOUR,
  BACKGROUND_IMAGE       = c1rec.BACKGROUND_IMAGE,
  BACKGROUND_EXT         = c1rec.BACKGROUND_EXT,
  BAR_TITLE              = c1rec.BAR_TITLE,
  HEADER_TITLE           = c1rec.HEADER_TITLE,
  JUSTIFY                = c1rec.JUSTIFY,
  TABLE_PARM             = c1rec.TABLE_PARM,
  TABLE_DATA             = c1rec.TABLE_DATA,
  TABLE_DATA_ALT         = c1rec.TABLE_DATA_ALT,
  TEXT_FONT              = c1rec.TEXT_FONT,
  TEXT_COLOUR            = c1rec.TEXT_COLOUR,
  TEXT_PITCH             = c1rec.TEXT_PITCH,
  RETURL                 = c1rec.RETURL,
  RETURL_DISPLAY         = c1rec.RETURL_DISPLAY,
  RETURL_IS_GIF          = c1rec.RETURL_IS_GIF,
  INSTRUCTION_TEXT_HDR   = c1rec.INSTRUCTION_TEXT_HDR,
  INSTRUCTION_TEXT_FTR   = c1rec.INSTRUCTION_TEXT_FTR,
  JAVASCRIPT_CODE        = c1rec.JAVASCRIPT_CODE,
  HEADER_COLOUR 	 = c1rec.HEADER_COLOUR,
  HEADER_FONT_COLOUR 	 = c1rec.HEADER_FONT_COLOUR,
  CELL_COLOUR 		 = c1rec.CELL_COLOUR,
  CELL_COLOUR_ALT 	 = c1rec.CELL_COLOUR_ALT,
  TARGET                 = c1rec.TARGET,
  RETURL_TARGET          = c1rec.RETURL_TARGET,
  DIVIDER_TYPE           = c1rec.DIVIDER_TYPE,
  DIVIDER_CODE           = c1rec.DIVIDER_CODE
where
 portlet_id = c1rec.portlet_id;
commit;

delete from portlet_news_item where portlet_id = c1rec.portlet_id;

for j in p5.first..p5.last loop
 if p5(j) = 'NEWS_ITEM_OR_UMO_ID'
  then
   colrec.news_item_or_umo_id := p6(j);
 elsif p5(j) = 'ORDER_BY'
  then
   begin nmb := to_number(p6(j)); exception when others then nmb := 99; end;
   colrec.order_by := nmb;
 elsif p5(j) = 'COLUMN_1_2'
  then
   colrec.column_1_2 := p6(j);
 elsif p5(j) = 'NEWS_TITLE'
  then
   colrec.news_title := p6(j);
 elsif p5(j) = 'NEWS_TITLE_STYLE'
  then
   colrec.news_title_style := p6(j);
 elsif p5(j) = 'NEWS_TEXT'
  then
   colrec.news_text := p6(j);
 elsif p5(j) = 'NEWS_TEXT_STYLE'
  then
   if c2rec.portlet_type = 'NEWS'
    then
     open c3( colrec.news_item_or_umo_id );
     fetch c3 into colrec.aid;
     close c3;
   elsif c2rec.portlet_type = 'CUSTOMERS'
    then
     open c4( colrec.news_item_or_umo_id, owner_id );
     fetch c4 into colrec.aid;
     close c4;
   end if;
   colrec.news_text_style := p6(j);
   select max(col_id) into colrec.col_id from portlet_news_item;
   colrec.col_id := nvl(colrec.col_id,0) + 1;
   if (colrec.order_by is null)
    then
     null;
    else
     insert into portlet_news_item(col_id, portlet_id, order_by, news_item_or_umo_id, aid,
                                   column_1_2, news_title, news_title_style, news_text, news_text_style)
       values(colrec.col_id, c1rec.portlet_id, colrec.order_by, colrec.news_item_or_umo_id, colrec.aid,
              colrec.column_1_2, colrec.news_title, colrec.news_title_style, colrec.news_text, colrec.news_text_style);
   end if;
 end if;
end loop;
commit;

edit_portlet_news(surl,c1rec.portlet_id,msg=>LNG5.EXT_TXT_698);

exception when others then
 glbx.error_details( 'PFM', 'ACCEPT_EDIT_PORTLET_NEWS', owner_id, errmsg=>sqlerrm );
end accept_edit_portlet_news;

procedure edit_webservice( surl in varchar2, portid in integer default null, portname in varchar2 default null, porttype in varchar2 default null, msg in varchar2 default null )
as

 cursor c1(phgid integer, portid integer) is select * from portlet_news where portlet_id = portid and exists (select pid from portlet_definition where pid = phgid and portlet_id = portid);
 cursor c2(portid integer) is select * from portlet_definition where portlet_id = portid;

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 sessid		integer;
 owner_id	integer;
 sts		varchar2(100);
 http		varchar2(1000);
 width		integer;
 height		integer;
 pfx		THEME%ROWTYPE;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'PFM.EDIT_PORTLET_NEWS', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if portid is null and portname is null
  then
   manage_portlets( surl, LNG5.EXT_TXT_711 );
   return;
 end if;


 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( LNG.PHG_TXT_352 );
 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.bold(LNG2.PFM_TXT_154);
 htp.formtext( 'PORTNAME', 30, 100 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_693 );
 htp.formclose;

 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.bold(LNG.PHG_TXT_169);
 htp.formtext( 'PORTNAME', 30, 100 );
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_695 );
 htp.formclose;

 htp.formopen( 'pfm.edit_portlet_utility' );
 htp.formhidden( 'SURL', surl );
 htp.formhidden( 'PORTID', c1rec.portlet_id );
 htp.formhidden( 'PORTNAME', null );
 htp.bold(LNG.SLD_TXT_004);
 htp.formsubmit( 'ACTION', LNG5.EXT_TXT_689 );
 htp.formclose;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'PFM', 'EDIT_WEBSERVICE', owner_id, errmsg=>sqlerrm );
end edit_webservice;

end pfm;

/
