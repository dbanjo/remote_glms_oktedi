CREATE OR REPLACE TYPE WEBSYS."BLUEPRINT_TYPE"                                          AS OBJECT
 (
 	mimetype		varchar2(1000),
 	online_mimetype		varchar2(1000),
 	blueprint_original_loc	varchar2(1000),
	blueprint_length	number(16),
	online_length		number(16),
	details			varchar2(4000),
	localdata		blob,
	online_version		blob
 );

/
