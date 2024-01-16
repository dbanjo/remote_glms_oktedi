CREATE OR REPLACE TYPE WEBSYS."REPEATED_FIELDS"                                          AS OBJECT
 (
 	orderby_nmb	number,
 	orderby_char	varchar2(100),
 	orderby_scene	number,
        title		varchar2(100),
        quality		varchar2(100),
 	photo_name	varchar2(100),
 	film_name	varchar2(100),
 	enabled_phg	varchar2(10),
 	enabled_cus	varchar2(10)
 );

/
