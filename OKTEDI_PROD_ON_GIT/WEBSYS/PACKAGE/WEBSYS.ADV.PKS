CREATE OR REPLACE package WEBSYS.adv
as

 procedure mng_advert(surl varchar2);
 procedure edit_advert_left(surl varchar2);
 procedure edit_advert_details( surl in varchar2, v_avid in integer default 0, msg in varchar2 default null );
 procedure edit_advert_plan( surl in varchar2, v_chid in integer default 0, msg in varchar2 default null );
 procedure accept_advert(surl in varchar2, v_avid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, p7 in varchar2,
                         p8 in varchar2, p9 in varchar2, p10 in varchar2, p11 in varchar2, p12 in varchar2, pa in varchar2 );
 procedure accept_plan(surl in varchar2, v_chid in integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p3a in varchar2, p4 in varchar2, p5 in varchar2 default 'F', p6 in varchar2 default 'F', p7 in varchar2 default 'F',
                         p8 in varchar2 default 'F', p9 in varchar2 default 'F', p10 in varchar2 default 'F', p11 in varchar2 default 'F', pa in varchar2 );
 procedure edit_campaign( surl in varchar2, v_avid in integer,v_adid in integer default 0, msg in varchar2 default null );
 procedure accept_campaign(surl in varchar2, v_avid integer, v_adid integer, p1 in varchar2, p2 in varchar2, pa in varchar2, old_chid in integer );
 procedure edit_image( surl in varchar2,v_avid in integer, v_adid in integer, v_advid in integer default 0, msg in varchar2 default null );
 procedure accept_image(surl in varchar2,file in varchar2, v_avid in integer, v_adid in integer, v_advid integer, p1 in varchar2, p2 in varchar2, p3 in varchar2, p4 in varchar2, p5 in varchar2, p6 in varchar2, pa in varchar2 );
 procedure campaign_stats(surl varchar2,v_avid integer, v_adid integer);

 function display_advert( surl in varchar2, sess_id in integer, theme_type in varchar2, custtype in varchar2, screen_estate in varchar2 ) return varchar2;
 procedure redirect( sess_id in integer, v_advid in integer, url in varchar2 );

end adv;

/
