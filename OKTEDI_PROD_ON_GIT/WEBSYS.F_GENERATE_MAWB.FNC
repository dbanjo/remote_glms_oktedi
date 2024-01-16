CREATE OR REPLACE function WEBSYS.f_generate_mawb( mawb varchar2, action in varchar2 default 'LINE_NO' )
 return varchar2
as
begin

strangp.generate_ships_manifest( mawb, action ,'AIRWAY' );

 return( NULL );
end f_generate_mawb;

/
