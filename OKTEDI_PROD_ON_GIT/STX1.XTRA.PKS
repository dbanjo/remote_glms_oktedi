CREATE OR REPLACE package STX1.xtra
as

 NL_CHAR                constant char(1) := chr(10);
    FILLER_KEY                          constant char(8) := 'ANIESQBH'; -- Used as a key for encryption, for batch job authentication.

 procedure comma_delimited(bfr in varchar2, comma_delim in out nocopy owa.vc_arr, delimchar in char default ',', append in boolean default FALSE, extra_dquote in boolean default FALSE);
 function xmlconv( vl in varchar2, override_conv in char default null )  return varchar2;
 function guess_number( val in varchar2, enable_eq in char default 'T', starting_mask in varchar2 default null, defval in integer default null ) return varchar2;
 function encrypt_pk( input_string in varchar2, maxlength in integer default 32, filler_only in boolean default FALSE ) return varchar2;

end xtra;
/
