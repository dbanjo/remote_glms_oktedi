CREATE OR REPLACE PACKAGE WEBSYS.FORUM
AS
--
TYPE arrc IS TABLE OF varchar2(50) INDEX BY BINARY_INTEGER;
--
procedure Display_Forum(surl varchar2,sty in varchar2 default null, acc in varchar2 default 'PHG' );
procedure Display_Hierarchy(surl varchar2,ordby in varchar2 default 'DATE', sort_type in varchar2 default 'DESC', env_id in integer, acc in varchar2 default 'PHG' );
procedure Scroll_Guestbook( surl varchar2,strt in integer default 1, scrll in varchar2, env_id in integer, acc in varchar2 default 'PHG' );
procedure Disp_Hier( surl varchar2,exp in arrc, drill_down in varchar2 default null,
                     id in varchar2 default null, tid in varchar2 default null,
		     ordby in varchar2 default 'DATE',
		     sort_type in varchar2 default 'DESC', env_id in integer, acc in varchar2 default 'PHG');
procedure Display_Drill(surl varchar2,env_id in integer, acc in varchar2 default 'PHG');
procedure Display_Thread( surl varchar2,id in number default null, src in varchar2 default null,
  						  ordby in varchar2 default 'By Date', sort_order in varchar2 default 'ASC',
  						  msg in varchar2 default null, env_id in integer, acc in varchar2 default 'PHG' );
procedure Response( surl varchar2,id in number default null, msg in varchar2 default null, pid in number default null, env_id in integer, action in varchar2 default null, ctype in varchar2 default 'REPLY', acc in varchar2 default 'PHG');
procedure Display_Response( surl varchar2,id in number, msg in varchar2 default null, env_id in integer, acc in varchar2 default 'PHG' );
procedure Accept_Group(surl varchar2,id in number default null, grp in varchar2 default null,
                       sb in varchar2 default null, pid in number default null,
                       th in varchar2 default null, tx in varchar2 default null,
		       env_id in integer, acc in varchar2 default 'PHG');
procedure Bottom_Frame( surl varchar2,id in varchar2, sort_order in varchar2 default 'ASC', env_id in integer, acc in varchar2 default 'PHG' );
procedure Display_Search( surl varchar2,id in number default null, src in varchar2 default null,
   			  ordby in varchar2 default 'By Date', sort_order in varchar2 default 'ASC',
			  msg in varchar2 default null, env_id in integer, acc in varchar2 default 'PHG' );
procedure Msg( surl varchar2,id in number, acc in varchar2 default 'PHG' );
procedure Update_Pref( surl varchar2,env_id in integer, acc in varchar2 default 'PHG' );
procedure Accept_Update( surl varchar2,env_id in integer, p1 in varchar2, acc in varchar2 default 'PHG' );
procedure Display_Frm( surl varchar2,id in number, env_id in integer, acc in varchar2 default 'PHG' );
procedure Graphic_Sort( surl varchar2,type in varchar2 default 'HIER', env_id in integer, acc in varchar2 default 'PHG' );
procedure Initial_Msg( surl varchar2,acc in varchar2 default 'PHG' );
procedure delforum( surl varchar2,p1 in varchar2, acc in varchar2 default 'PHG' );
--
END FORUM;

/
