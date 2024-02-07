CREATE OR REPLACE package body WEBSYS.mload
as

 --
 -- Meta Data Extraction for SCC JPEG Images
 -- Follows IPTC or Adobe XML Standard
 --
 REPLACE_CHAR 		constant varchar2(10) 	:= 'x';
 NL_CHAR		constant char(1) := chr(10);

 TYPE meta_tag IS RECORD
  (
    -- IPTC Standard
    object_name_5 	varchar2(1000),
    urgency_10 	 	varchar2(1000),
    category_15 	varchar2(1000),
    supplemental_cat_20 varchar2(1000),
    locale_22 	 	varchar2(1000),
    keywords_25 	varchar2(1000),
    instruction_40 	varchar2(1000),
    date_55 	 	varchar2(1000),
    time_60 	 	varchar2(1000),
    orig_program_65 	varchar2(1000),
    byline_80 	 	varchar2(1000),
    bytitle_85 	 	varchar2(1000),
    city_90 	 	varchar2(1000),
    state_95 	 	varchar2(1000),
    country_100_101 	varchar2(1000),
    transref_103 	varchar2(1000),
    headline_105 	varchar2(1000),
    credit_110 	 	varchar2(1000),
    source_115 	 	varchar2(1000),
    copyright_116 	varchar2(1000),
    caption_120 	varchar2(1000),
    caption_writer_122 	varchar2(1000),
    other_230_231_232	varchar2(1000),
    unknown	 	varchar2(1000),
    -- XML Standard
    xml_captionwriter 	varchar2(1000),
    xml_headline 	varchar2(1000),
    xml_instructions 	varchar2(1000),
    xml_authorposition 	varchar2(1000),
    xml_credit 		varchar2(1000),
    xml_source 		varchar2(1000),
    xml_city 		varchar2(1000),
    xml_state 		varchar2(1000),
    xml_country		varchar2(1000),
    xml_transm 		varchar2(1000),
    xml_category	varchar2(1000),
    xml_datecreated 	varchar2(1000),
    xml_urgency 	varchar2(1000),
    xml_supp 		varchar2(1000),
    xml_name 		varchar2(1000),
    xml_webstatement 	varchar2(1000),
    xml_marked	 	varchar2(1000),
    xml_description 	varchar2(1000),
    xml_seq 		varchar2(1000),
    xml_alt 		varchar2(1000),
    xml_rights 		varchar2(1000),
    xml_bag 		varchar2(1000),
    xml_docid 		varchar2(1000),
    xml_other 		varchar2(1000),
    -- EXIF Standard (EXIF2-2)
    ApertureValue	        varchar2(1000),
    Artist			varchar2(1000),
    BatteryLevel		varchar2(1000),
    BitsPerSample		varchar2(1000),
    BrightnessValue	        varchar2(1000),
    CFAPattern		        varchar2(1000),
    CFARepeatPatternDim	        varchar2(1000),
    ColorSpace		        varchar2(1000),
    ComponentsConfiguration	varchar2(1000),
    CompressedBitsPerPixel 	varchar2(1000),
    Compression		        varchar2(1000),
    Copyright		        varchar2(1000),
    DateTime		        varchar2(1000),
    DateTimeDigitized	        varchar2(1000),
    DateTimeOriginal	        varchar2(1000),
    DocumentName		varchar2(1000),
    ExifImageLength		varchar2(1000),
    ExifImageWidth		varchar2(1000),
    ExifOffset		        varchar2(1000),
    ExifVersion		        varchar2(1000),
    ExposureBiasValue	        varchar2(1000),
    ExposureIndex		varchar2(1000),
    ExposureProgram		varchar2(1000),
    ExposureTime		varchar2(1000),
    FileSource		        varchar2(1000),
    FillOrder		        varchar2(1000),
    Flash			varchar2(1000),
    FlashEnergy		        varchar2(1000),
    FlashPixVersion		varchar2(1000),
    FNumber			varchar2(1000),
    FocalLength		        varchar2(1000),
    FocalPlaneResolutionUnit    varchar2(1000),
    FocalPlaneXResolution	varchar2(1000),
    FocalPlaneYResolution	varchar2(1000),
    GPSInfo			varchar2(1000),
    ImageDescription	        varchar2(1000),
    ImageLength		        varchar2(1000),
    ImageWidth		        varchar2(1000),
    InterColorProfile	        varchar2(1000),
    InteroperabilityOffset	varchar2(1000),
    IPTC_NAA		        varchar2(1000),
    ISOSpeedRatings		varchar2(1000),
    JPEGInterchangeFormat	varchar2(1000),
    JPEGInterchangeFormatLength varchar2(1000),
    JPEGProc		        varchar2(1000),
    LightSource		        varchar2(1000),
    Make			varchar2(1000),
    MakerNote		        varchar2(1000),
    MaxApertureValue	        varchar2(1000),
    MeteringMode		varchar2(1000),
    Model			varchar2(1000),
    OECF			varchar2(1000),
    Orientation		        varchar2(1000),
    PhotometricInterpretation   varchar2(1000),
    PlanarConfiguration	        varchar2(1000),
    PrimaryChromaticities	varchar2(1000),
    ReferenceBlackWhite	        varchar2(1000),
    ResolutionUnit		varchar2(1000),
    RowsPerStrip		varchar2(1000),
    SamplesPerPixel		varchar2(1000),
    SceneType		        varchar2(1000),
    SensingMethod		varchar2(1000),
    ShutterSpeedValue	        varchar2(1000),
    Software		        varchar2(1000),
    SpatialFrequencyResponse    varchar2(1000),
    SpectralSensitivity	        varchar2(1000),
    StripByteCounts		varchar2(1000),
    StripOffsets		varchar2(1000),
    SubjectDistance		varchar2(1000),
    SubjectLocation		varchar2(1000),
    SubSecTime		        varchar2(1000),
    SubSecTimeDigitized	        varchar2(1000),
    SubSecTimeOriginal	        varchar2(1000),
    TransferFunction	        varchar2(1000),
    TransferRange		varchar2(1000),
    UserComment		        varchar2(1000),
    WhitePoint		        varchar2(1000),
    XResolution		        varchar2(1000),
    YCbCrCoefficients	        varchar2(1000),
    YCbCrPositioning	        varchar2(1000),
    YCbCrSubSampling	        varchar2(1000),
    YResolution		        varchar2(1000)
  );


 TYPE load_command IS RECORD
   (
    onload 	 varchar2(1000),
    image_type	 varchar2(1000),
    umo_id	 varchar2(1000),
    umo_scene	 varchar2(1000),
    umo_scene_id varchar2(1000),
    name	 varchar2(1000),
    location	 varchar2(1000),
    key_type	 varchar2(1000),
    key_val	 varchar2(1000),
    attribute_id integer,
    pk_id	 integer
  );

function tagmap( phgid integer, metatype in varchar2, tname in varchar2, acid in integer ) return varchar2;
function retattribid( phgid integer, metatype in varchar2, tgm varchar2 ) return integer;
function findkey( acid integer, loadrec in load_command ) return integer;
function findattrib( acid integer, loadrec in load_command, tag in varchar2 ) return integer;

procedure display_metatags( phgid integer, metatype in varchar2, pfx in theme%ROWTYPE, acid in integer );
procedure extract_meta_tags( surl in varchar2, v_umo in integer, mt out meta_tag, metatype in varchar2, use_photoshop in boolean default FALSE );
procedure print_mt( v_umo in integer, mt in meta_tag, c2rec in UMO%ROWTYPE, metatype in varchar2 );
procedure update_mt( surl in varchar2, v_umo in integer, acid in integer, attribid integer, vl in varchar2 );
procedure load_mt( surl in varchar2, v_umo in integer, acid in integer, mt in meta_tag, phgid integer, metatype in varchar2 );
procedure meta_load( surl in varchar2, phgid integer, metatype in varchar2, acid in integer, loadall in boolean, displayonly in boolean, nmb out integer );
procedure meta_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null );
procedure merge( mt in out NOCOPY meta_tag, new_mt in meta_tag );

procedure xml_ext( bfr in varchar2, p1 in out NOCOPY GLBX.MYARRAY, p2 in out NOCOPY GLBX.MYARRAY );

procedure load_xml_meta_data(surl in varchar2, acid in integer, inclob in clob, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY );
procedure parsedoc(surl in varchar2, doc in sys.xmldom.DOMDocument, acid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY);

procedure main(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as
begin

 if called_from = 'PREFERENCES'
  then
   meta_pref(surl,nvid,loc_id,footer_api,left_api_parm,current_page_number,display_detail,acid,first_parameter,called_from );

 end if;

exception when others then
 glbx.error_details( 'VIRAGE', 'MAIN',errmsg=>sqlerrm,extdet=>'LOC_ID:' || loc_id);
end main;

procedure extract_meta_tags( surl in varchar2, v_umo in integer, mt out meta_tag, metatype in varchar2, use_photoshop in boolean default FALSE )
 as

 cursor c1(v_umo integer) is select * from umo where umo_id = v_umo;

 c1rec		c1%ROWTYPE;
 blb		blob;
 buffer		varchar2(32767);
 v_buffer	raw(32767);
 v_imgchunk	integer;
 src		integer;
 src1		integer;
 ctr		integer;
 loc		integer;
 loc2		integer;
 loc_eof	integer;
 data_set	integer;
 len2		integer;
 len3		integer;
 pattern	raw(30);
 raw1		raw(1);
 cchar		char(1);
 step		varchar2(100);
 ltag		varchar2(100);
 prtag		varchar2(100);
 new_mt		meta_tag;
 p1		GLBX.MYARRAY;
 p2		GLBX.MYARRAY;
 res		boolean;
 parmarr1	ump.parameters;
 parmarr2	ump.parameters;

begin
-- Extract meta tag value
open c1(v_umo);
fetch c1 into c1rec;
close c1;

if metatype = 'IPTC Standard'
 then
  blb := c1rec.photo_master.source.localdata;
  -- Find the End of Image Marker
  pattern := 'FFED';
  v_imgchunk := 1;
  src := dbms_lob.instr( blb, pattern, 1, 1 );
  if src = 0 then return; end if; -- No Marker Found
  src1 := src;

  if use_photoshop
   then
    --pattern := utl_raw.cast_to_raw('Photoshop 3.0.8'); -- Marker for the first XML Tag
    pattern := '74006F00730068006F007000200037002E003000'; -- Marker for the first Adobe Tag
    src := dbms_lob.instr( blb, pattern, src1, 1 );
    if src = 0
     then
      -- Try another marker
       pattern := '50686F746F73686F7020332E30'; -- Marker for the first XML Tag
       src := dbms_lob.instr( blb, pattern, src1, 1 );
       --glbx.dbg( v_umo || ':' || src );
       if src = 0
        then
         -- Try another marker
          pattern := '410064006F00'; -- Marker for the first XML Tag
          src := dbms_lob.instr( blb, pattern, src1, 1 );
          if src = 0
           then
            return;
          end if; -- No Marker Found
       end if;
    end if;
  end if;

  pattern := '3842494D';

  if use_photoshop
   then
    loc_eof := dbms_lob.instr( blb, pattern, src, 1 ) + 3000;
   else
    loc_eof := dbms_lob.instr( blb, pattern, src, 2 );
    if loc_eof < src then loc_eof := 99999999; end if;
  end if;


  ctr := 1;
  pattern := '1C';
  step := 'A';

  loop

    -- Find the First 1C Character
    step := 'B';
    loc := dbms_lob.instr( blb, pattern, src, ctr );
    exit when loc = 0;
    -- Advance Two Bytes
    loc := loc + 2; -- was 2
    step := 'C';
    -- Check if gone past this strange EOF marker
    --htp.bold( 'LOC:' || loc || '-' || loc_eof ); htp.nl;
    if loc > loc_eof then exit; end if;
    step := 'C1';

    v_imgchunk := 1;
    begin
     dbms_lob.read(blb, v_imgchunk, loc, raw1 );
    exception
     when others then exit;
    end;
    cchar := utl_raw.cast_to_varchar2( raw1 );
    data_set := ascii( cchar );

    -- If the data set is unknown then exit
    if data_set > 200 and data_set not in (230,231,232) then dbms_output.put_line ('Exit On:' || data_set); exit; end if;

    -- The next two bytes are the length
    loc := loc + 1;
    v_imgchunk := 1;
    dbms_lob.read(blb, v_imgchunk, loc, raw1 );
    cchar := utl_raw.cast_to_varchar2( raw1 );
    len2 := ascii( cchar ) * 255;
    step := 'E';

    loc := loc + 1;
    v_imgchunk := 1;
    dbms_lob.read(blb, v_imgchunk, loc, raw1 );
    cchar := utl_raw.cast_to_varchar2( raw1 );
    len3 := ascii( cchar ) + len2;
    --htp.bold( 'Dataset: ' || data_set || '-' || len3 || '-' || len2 || '+' || ascii(cchar ) ); htp.nl;
    -- len3 := ascii( cchar );
    step := 'F';

    -- Advanced to the first byte of Data
    loc := loc + 1;

    begin
     v_imgchunk := len3;
     if len3 > 0
      then
       dbms_lob.read(blb, v_imgchunk, loc, v_buffer );
       buffer := utl_raw.cast_to_varchar2( v_buffer );
       --htp.bold( ' . Buffer: ' || data_set || '-' || v_imgchunk || '-' || loc ); htp.nl;
       buffer := substr(replace(replace(buffer,chr(13),'<BR>'),chr(10),'<BR>'),1,1000);
      --htp.bold( ' . Value:' || length(buffer) || ':' || buffer ); htp.nl;
      else
       buffer := NULL;
     end if;
    exception
     when others then exit;
    end;
    step := 'G';

    if data_set = 5
     then
      --dbms_output.put_line( 'Object Name:' || buffer );
      if mt.object_name_5 is null then mt.object_name_5 := buffer; end if;

     elsif data_set = 10
      then
       -- dbms_output.put_line( 'Urgency:' || buffer );
       if mt.urgency_10 is null then mt.urgency_10 := buffer; end if;

     elsif data_set = 15
      then
       -- dbms_output.put_line( 'Category:' || buffer );
       if mt.category_15 is null then mt.category_15 := buffer; end if;

     elsif data_set = 20
      then
       -- dbms_output.put_line( 'Supplemental Category:' || buffer );
       if mt.supplemental_cat_20 is null then mt.supplemental_cat_20 := buffer; end if;

     elsif data_set = 22
      then
    -- dbms_output.put_line( 'Locale:' || buffer );
       if mt.locale_22 is null then mt.locale_22 := buffer; end if;

     elsif data_set = 25
      then
    -- dbms_output.put_line( 'Image Keywords:' || buffer );
       mt.keywords_25 := mt.keywords_25 || ',' || buffer;

     elsif data_set = 40
      then
       -- dbms_output.put_line( 'Special Instructions:' || buffer );
       if mt.instruction_40 is null then mt.instruction_40 := buffer; end if;

     elsif data_set = 55
      then
       -- dbms_output.put_line( 'Creation Date:' || buffer );
       if mt.date_55 is null
        then
         begin mt.date_55 := to_char(to_date(buffer,'YYYYMMDD'), LNG.MASK); exception when others then null; end;
       end if;

     elsif data_set = 60
      then
       -- dbms_output.put_line( 'Creation Time:' || buffer );
    if mt.time_60 is null then mt.time_60 := buffer; end if;

     elsif data_set = 65
      then
       -- dbms_output.put_line( 'Originating Program:' || buffer );
    if mt.orig_program_65 is null then mt.orig_program_65 := buffer; end if;

     elsif data_set = 80
      then
       -- dbms_output.put_line( 'Byline:' || buffer );
       if mt.byline_80 is null then mt.byline_80 := buffer; end if;

     elsif data_set = 85
      then
       -- dbms_output.put_line( 'Bytitle:' || buffer );
       if mt.bytitle_85 is null then mt.bytitle_85 := buffer; end if;

     elsif data_set = 90
      then
       -- dbms_output.put_line( 'City:' || buffer );
       if mt.city_90 is null then mt.city_90 := buffer; end if;

     elsif data_set = 95
       then
           -- dbms_output.put_line( 'State Province:' || buffer );
           if mt.state_95 is null then mt.state_95 := buffer; end if;

         elsif data_set in (100,101)
       then
           -- dbms_output.put_line( 'Country:' || buffer );
       if mt.country_100_101 is not null
        then
         mt.country_100_101 := mt.country_100_101 || ',' || buffer;
        else
         mt.country_100_101 := buffer;
       end if;

     elsif data_set = 103
      then
    -- dbms_output.put_line( 'Transref:' || buffer );
       if mt.transref_103 is null then mt.transref_103 := buffer; end if;

     elsif data_set = 105
      then
    -- dbms_output.put_line( 'Headline:' || buffer );
       if mt.headline_105 is null then mt.headline_105 := buffer; end if;

     elsif data_set = 110
      then
       -- dbms_output.put_line( 'Credit:' || buffer );
       if mt.credit_110 is null then mt.credit_110 := buffer; end if;

     elsif data_set = 115
      then
       -- dbms_output.put_line( 'Source:' || buffer );
       if mt.source_115 is null then mt.source_115 := buffer; end if;

     elsif data_set = 116
      then
       -- dbms_output.put_line( 'Copyright:' || buffer );
       if mt.copyright_116 is null then mt.copyright_116 := buffer; end if;

     elsif data_set = 120
       then
           -- dbms_output.put_line( 'Caption:' || buffer );
           if mt.caption_120 is null then mt.caption_120 := buffer; end if;

         elsif data_set = 122
       then
           -- dbms_output.put_line( 'Caption Writer:' || buffer );
       if mt.caption_writer_122 is null then mt.caption_writer_122 := buffer; end if;

     elsif data_set in (230,231,232)
      then
       -- dbms_output.put_line( data_set || ' Unk:' || substr(buffer,1,200) );
       mt.other_230_231_232 := mt.other_230_231_232 || ' ' || buffer;

     elsif data_set in (0)
      then
    null; -- Ignore

     elsif data_set in (0,74,82,125,136,140,144,182,230,32,93,126,35,231,155,61,53,183)
      then
       exit; -- Ignore

     else
     -- dbms_output.put_line( 'Unknown :' || data_set || '-' || buffer );
     begin mt.unknown := mt.unknown || ' ' || buffer ;
     exception
      when others then null;
     end;

    end if;

    ctr := ctr + 1;
    exit when ctr > 400;

   end loop;
   step := 'H';
   if mt.keywords_25 is not null then mt.keywords_25 := substr(substr(mt.keywords_25,2),1,1000); end if;
   mt.unknown := substr(trim(mt.unknown),1,1000);
   mt.other_230_231_232 := substr(trim(mt.other_230_231_232),1,1000);
   step := 'I';

elsif metatype = 'XML Format'
 then
  blb := c1rec.photo_master.source.localdata;
  -- Find the End of Image Marker
  pattern := 'FFED';
  v_imgchunk := 1;
  src := dbms_lob.instr( blb, pattern, 1, 2 ); -- Seems there are two markers in the file
  if src = 0 then extract_meta_tags( surl, v_umo, new_mt, 'IPTC Standard', TRUE ); merge( mt, new_mt ); return; end if; -- No Marker Found

  pattern := 'FFE1'; -- Marker for the first XML Tag
  src := dbms_lob.instr( blb, pattern, src, 1 );
  if src = 0 then extract_meta_tags( surl, v_umo, new_mt, 'IPTC Standard', TRUE ); merge( mt, new_mt ); return; end if; -- No Marker Found

  -- The previous two bytes are the length
  loc := src + 2;
  v_imgchunk := 1;
  dbms_lob.read(blb, v_imgchunk, loc, raw1 );
  cchar := utl_raw.cast_to_varchar2( raw1 );
  data_set := ascii( cchar ) * 255;
  loc := loc + 1;
  v_imgchunk := 1;
  dbms_lob.read(blb, v_imgchunk, loc, raw1 );
  cchar := utl_raw.cast_to_varchar2( raw1 );
  len2 := ascii( cchar ) + data_set;
  step := 'E';

  --pattern := '3842494D';
  --loc_eof := dbms_lob.instr( blb, pattern, src, 2 );
  --if loc_eof < src then loc_eof := 99999999; end if;

  --ctr := 1;
  --pattern := '1C';
  --step := 'A';

  --v_imgchunk := len2;

  --htp.bold( 'SRC:' || src); htp.nl;
  --htp.bold( 'LOC_EOF:' || LOC_EOF); htp.nl;
  --htp.bold( 'Len2:' || len2); htp.nl;
  --htp.bold( ' . Buffer: ' || data_set || '-' || v_imgchunk || '-' || loc ); htp.nl;
  --buffer := replace(replace(buffer,chr(13),'<BR>' || chr(13)),chr(10),'<BR>' || chr(10));

  dbms_lob.read(blb, len2, src+4, v_buffer );
  buffer := utl_raw.cast_to_varchar2( v_buffer );

  buffer := substr(buffer,instr(buffer,'<rdf:RDF'));
  buffer := substr(buffer,1,instr(buffer,'</rdf:RDF>') + length('</rdf:RDF>'));
  --htp.p( buffer );
  xml_ext( buffer, p1, p2 );

  -- Loop through XML tag around and assign values to their respective unique tag
  if p1.count > 0 then
  for j in p1.first..p1.last loop
   -- htp.p( j || ':' || p1(j) || '-' || p2(j) );
   -- htp.nl;
   p2(j) := replace(p2(j),'&apos;','''');
   p2(j) := replace(p2(j),'&lt;','<');
   p2(j) := replace(p2(j),'&gt;','>');
   p2(j) := replace(p2(j),'&quot;','"');
   p2(j) := replace(p2(j),'&amp;','&');
   p2(j) := replace(p2(j),chr(13),'<BR>');
   p2(j) := replace(p2(j),chr(10),'<BR>');
   if trim(p2(j)) = 'pdf:Title is aliased' then p2(j) := NULL; end if;
   if trim(p2(j)) = 'xap:Title is aliased' then p2(j) := NULL; end if;

   if p1(j) = 'RDF'
    then
     null;

    elsif p1(j) = 'CAPTIONWRITER'
     then
      if mt.xml_captionwriter is null then mt.xml_captionwriter := p2(j); end if;

    elsif p1(j) = 'HEADLINE'
     then
      if mt.xml_headline is null then mt.xml_headline := p2(j); end if;

    elsif p1(j) = 'INSTRUCTIONS'
     then
      if mt.xml_instructions is null then mt.xml_instructions := p2(j); end if;

    elsif p1(j) = 'AUTHORPOSITION'
     then
      if mt.xml_authorposition is null then mt.xml_authorposition := p2(j); end if;

    elsif p1(j) = 'CREDIT'
     then
      if mt.xml_credit is null then mt.xml_credit := p2(j); end if;

    elsif p1(j) = 'SOURCE'
     then
      if mt.xml_source is null then mt.xml_source := p2(j); end if;

    elsif p1(j) = 'CITY'
     then
      if mt.xml_city is null then mt.xml_city := p2(j); end if;

    elsif p1(j) = 'STATE'
     then
      if mt.xml_state is null then mt.xml_state := p2(j); end if;

    elsif p1(j) = 'COUNTRY'
     then
      if mt.xml_country is null then mt.xml_country := p2(j); end if;

    elsif p1(j) = 'TRANSMISSIONREFERENCE'
     then
      if mt.xml_transm is null then mt.xml_transm := p2(j); end if;

    elsif p1(j) = 'CATEGORY'
     then
      if mt.xml_category is null then mt.xml_category := p2(j); end if;

    elsif p1(j) = 'DATECREATED'
     then
      if mt.xml_datecreated is null then mt.xml_datecreated := p2(j); end if;

    elsif p1(j) = 'URGENCY'
     then
      if mt.xml_urgency is null then mt.xml_urgency := p2(j); end if;

    elsif p1(j) = 'SUPLPLEMENTALCATEGORIES'
     then
      if mt.xml_supp is null then mt.xml_supp := p2(j); end if;

    elsif p1(j) = 'NAME'
     then
      if mt.xml_name is null then mt.xml_name := p2(j); end if;

    elsif p1(j) = 'WEBSTATEMENT'
     then
      if mt.xml_webstatement is null then mt.xml_webstatement := p2(j); end if;

    elsif p1(j) = 'MARKED'
     then
      if mt.xml_description is null then mt.xml_description := p2(j); end if;

    elsif p1(j) = 'DOCUMENTID'
     then
      if mt.xml_docid is null then mt.xml_docid := p2(j); end if;

    else

     if ltag = 'BAG' and p1(j) = 'LI'
      then
       if mt.xml_bag is null then mt.xml_bag := p2(j); end if;
     elsif prtag = 'RIGHTS' and ltag = 'ALT' and p1(j) = 'LI'
      then
       if mt.xml_marked is null then mt.xml_marked := p2(j); end if; -- Copyright
     elsif prtag = 'TITLE' and ltag = 'ALT' and p1(j) = 'LI'
      then
       if mt.xml_alt is null then mt.xml_alt := p2(j); end if; -- Title
     elsif prtag = 'SEQ' and ltag = 'ALT' and p1(j) = 'LI'
      then
       if mt.xml_seq is null then mt.xml_seq := p2(j); end if;
     elsif ltag = 'ALT' and p1(j) = 'LI'
      then
       if mt.xml_rights is null then mt.xml_rights := p2(j); end if;
     else
      if mt.xml_other is null then mt.xml_other := p2(j); end if;
     end if;

    end if;

   prtag := ltag;
   ltag := p1(j);

  end loop;

  -- Merge in with IPTC standard data
  extract_meta_tags( surl, v_umo, new_mt, 'IPTC Standard', TRUE );
  merge( mt, new_mt );
  end if;

elsif metatype = 'EXIF'
 then
  res := ump.identify_image( surl, c1rec.aid, v_umo, parmarr1, parmarr2 );
  if parmarr1.count = 0 then return; end if;
  for j in parmarr1.first..parmarr1.last loop
   if    parmarr1(j)='APERTUREVALUE' then mt.ApertureValue:=parmarr2(j);
   elsif parmarr1(j)='ARTIST' then mt.Artist:=parmarr2(j);
   elsif parmarr1(j)='BATTERYLEVEL' then mt.BatteryLevel:=parmarr2(j);
   elsif parmarr1(j)='BITSPERSAMPLE' then mt.BitsPerSample:=parmarr2(j);
   elsif parmarr1(j)='BRIGHTNESSVALUE' then mt.BrightnessValue:=parmarr2(j);
   elsif parmarr1(j)='CFAPATTERN' then mt.CFAPattern:=parmarr2(j);
   elsif parmarr1(j)='CFAREPEATPATTERNDIM' then mt.CFARepeatPatternDim:=parmarr2(j);
   elsif parmarr1(j)='COLORSPACE' then mt.ColorSpace:=parmarr2(j);
   elsif parmarr1(j)='COMPONENTSCONFIGURATION' then mt.ComponentsConfiguration:=parmarr2(j);
   elsif parmarr1(j)='COMPRESSEDBITSPERPIXEL' then mt.CompressedBitsPerPixel:=parmarr2(j);
   elsif parmarr1(j)='COMPRESSION' then mt.Compression:=parmarr2(j);
   elsif parmarr1(j)='COPYRIGHT' then mt.Copyright:=parmarr2(j);
   elsif parmarr1(j)='DATETIME' then mt.DateTime:=parmarr2(j);
   elsif parmarr1(j)='DATETIMEDIGITIZED' then mt.DateTimeDigitized:=parmarr2(j);
   elsif parmarr1(j)='DATETIMEORIGINAL' then mt.DateTimeOriginal:=parmarr2(j);
   elsif parmarr1(j)='DOCUMENTNAME' then mt.DocumentName:=parmarr2(j);
   elsif parmarr1(j)='EXIFIMAGELENGTH' then mt.ExifImageLength:=parmarr2(j);
   elsif parmarr1(j)='EXIFIMAGEWIDTH' then mt.ExifImageWidth:=parmarr2(j);
   elsif parmarr1(j)='EXIFOFFSET' then mt.ExifOffset:=parmarr2(j);
   elsif parmarr1(j)='EXIFVERSION' then mt.ExifVersion:=parmarr2(j);
   elsif parmarr1(j)='EXPOSUREBIASVALUE' then mt.ExposureBiasValue:=parmarr2(j);
   elsif parmarr1(j)='EXPOSUREINDEX' then mt.ExposureIndex:=parmarr2(j);
   elsif parmarr1(j)='EXPOSUREPROGRAM' then mt.ExposureProgram:=parmarr2(j);
   elsif parmarr1(j)='EXPOSURETIME' then mt.ExposureTime:=parmarr2(j);
   elsif parmarr1(j)='FILESOURCE' then mt.FileSource:=parmarr2(j);
   elsif parmarr1(j)='FILLORDER' then mt.FillOrder:=parmarr2(j);
   elsif parmarr1(j)='FLASH' then mt.Flash:=parmarr2(j);
   elsif parmarr1(j)='FLASHENERGY' then mt.FlashEnergy:=parmarr2(j);
   elsif parmarr1(j)='FLASHPIXVERSION' then mt.FlashPixVersion:=parmarr2(j);
   elsif parmarr1(j)='FNUMBER' then mt.FNumber:=parmarr2(j);
   elsif parmarr1(j)='FOCALLENGTH' then mt.FocalLength:=parmarr2(j);
   elsif parmarr1(j)='FOCALPLANERESOLUTIONUNIT' then mt.FocalPlaneResolutionUnit:=parmarr2(j);
   elsif parmarr1(j)='FOCALPLANEXRESOLUTION' then mt.FocalPlaneXResolution:=parmarr2(j);
   elsif parmarr1(j)='FOCALPLANEYRESOLUTION' then mt.FocalPlaneYResolution:=parmarr2(j);
   elsif parmarr1(j)='GPSINFO' then mt.GPSInfo:=parmarr2(j);
   elsif parmarr1(j)='IMAGEDESCRIPTION' then mt.ImageDescription:=parmarr2(j);
   elsif parmarr1(j)='IMAGELENGTH' then mt.ImageLength:=parmarr2(j);
   elsif parmarr1(j)='IMAGEWIDTH' then mt.ImageWidth:=parmarr2(j);
   elsif parmarr1(j)='INTERCOLORPROFILE' then mt.InterColorProfile:=parmarr2(j);
   elsif parmarr1(j)='INTEROPERABILITYOFFSET' then mt.InteroperabilityOffset:=parmarr2(j);
   elsif parmarr1(j)='IPTC/NAA' then mt.IPTC_NAA:=parmarr2(j);
   elsif parmarr1(j)='ISOSPEEDRATINGS' then mt.ISOSpeedRatings:=parmarr2(j);
   elsif parmarr1(j)='JPEGINTERCHANGEFORMAT' then mt.JPEGInterchangeFormat:=parmarr2(j);
   elsif parmarr1(j)='JPEGINTERCHANGEFORMATLENGTH' then mt.JPEGInterchangeFormatLength:=parmarr2(j);
   elsif parmarr1(j)='JPEGPROC' then mt.JPEGProc:=parmarr2(j);
   elsif parmarr1(j)='LIGHTSOURCE' then mt.LightSource:=parmarr2(j);
   elsif parmarr1(j)='MAKE' then mt.Make:=parmarr2(j);
   elsif parmarr1(j)='MAKERNOTE' then mt.MakerNote:=parmarr2(j);
   elsif parmarr1(j)='MAXAPERTUREVALUE' then mt.MaxApertureValue:=parmarr2(j);
   elsif parmarr1(j)='METERINGMODE' then mt.MeteringMode:=parmarr2(j);
   elsif parmarr1(j)='MODEL' then mt.Model:=parmarr2(j);
   elsif parmarr1(j)='OECF' then mt.OECF:=parmarr2(j);
   elsif parmarr1(j)='ORIENTATION' then mt.Orientation:=parmarr2(j);
   elsif parmarr1(j)='PHOTOMETRICINTERPRETATION' then mt.PhotometricInterpretation:=parmarr2(j);
   elsif parmarr1(j)='PLANARCONFIGURATION' then mt.PlanarConfiguration:=parmarr2(j);
   elsif parmarr1(j)='PRIMARYCHROMATICITIES' then mt.PrimaryChromaticities:=parmarr2(j);
   elsif parmarr1(j)='REFERENCEBLACKWHITE' then mt.ReferenceBlackWhite:=parmarr2(j);
   elsif parmarr1(j)='RESOLUTIONUNIT' then mt.ResolutionUnit:=parmarr2(j);
   elsif parmarr1(j)='ROWSPERSTRIP' then mt.RowsPerStrip:=parmarr2(j);
   elsif parmarr1(j)='SAMPLESPERPIXEL' then mt.SamplesPerPixel:=parmarr2(j);
   elsif parmarr1(j)='SCENETYPE' then mt.SceneType:=parmarr2(j);
   elsif parmarr1(j)='SENSINGMETHOD' then mt.SensingMethod:=parmarr2(j);
   elsif parmarr1(j)='SHUTTERSPEEDVALUE' then mt.ShutterSpeedValue:=parmarr2(j);
   elsif parmarr1(j)='SOFTWARE' then mt.Software:=parmarr2(j);
   elsif parmarr1(j)='SPATIALFREQUENCYRESPONSE' then mt.SpatialFrequencyResponse:=parmarr2(j);
   elsif parmarr1(j)='SPECTRALSENSITIVITY' then mt.SpectralSensitivity:=parmarr2(j);
   elsif parmarr1(j)='STRIPBYTECOUNTS' then mt.StripByteCounts:=parmarr2(j);
   elsif parmarr1(j)='STRIPOFFSETS' then mt.StripOffsets:=parmarr2(j);
   elsif parmarr1(j)='SUBJECTDISTANCE' then mt.SubjectDistance:=parmarr2(j);
   elsif parmarr1(j)='SUBJECTLOCATION' then mt.SubjectLocation:=parmarr2(j);
   elsif parmarr1(j)='SUBSECTIME' then mt.SubSecTime:=parmarr2(j);
   elsif parmarr1(j)='SUBSECTIMEDIGITIZED' then mt.SubSecTimeDigitized:=parmarr2(j);
   elsif parmarr1(j)='SUBSECTIMEORIGINAL' then mt.SubSecTimeOriginal:=parmarr2(j);
   elsif parmarr1(j)='TRANSFERFUNCTION' then mt.TransferFunction:=parmarr2(j);
   elsif parmarr1(j)='TRANSFERRANGE' then mt.TransferRange:=parmarr2(j);
   elsif parmarr1(j)='USERCOMMENT' then mt.UserComment:=parmarr2(j);
   elsif parmarr1(j)='WHITEPOINT' then mt.WhitePoint:=parmarr2(j);
   elsif parmarr1(j)='XRESOLUTION' then mt.XResolution:=parmarr2(j);
   elsif parmarr1(j)='YCBCRCOEFFICIENTS' then mt.YCbCrCoefficients:=parmarr2(j);
   elsif parmarr1(j)='YCBCRPOSITIONING' then mt.YCbCrPositioning:=parmarr2(j);
   elsif parmarr1(j)='YCBCRSUBSAMPLING' then mt.YCbCrSubSampling:=parmarr2(j);
   elsif parmarr1(j)='YRESOLUTION' then mt.YResolution:=parmarr2(j);
   end if;
  end loop;
end if;

exception
 when others
  then
   htp.p( 'Error in Extract Meta Tags.' || step ); htp.nl;
   htp.p( sqlerrm ); htp.nl;
   htp.p( 'UMO_ID:' || v_umo ); htp.nl;
   htp.p( 'Date Set:' || data_set );
   htp.p( 'Buffer:' || buffer );
end extract_meta_tags;

procedure merge( mt in out NOCOPY meta_tag, new_mt in meta_tag )
as
begin

 mt.xml_captionwriter 	:= nvl(mt.xml_captionwriter 	, new_mt.caption_writer_122);
 mt.xml_headline 	:= nvl(mt.xml_headline 		, new_mt.headline_105);
 mt.xml_instructions 	:= nvl(mt.xml_instructions 	, new_mt.instruction_40);
 mt.xml_authorposition 	:= nvl(mt.xml_authorposition 	, new_mt.supplemental_cat_20);
 mt.xml_credit 		:= nvl(mt.xml_credit 		, new_mt.credit_110);
 mt.xml_source 		:= nvl(mt.xml_source 		, new_mt.source_115); -- xx
 mt.xml_city 		:= nvl(mt.xml_city 		, new_mt.city_90);
 mt.xml_state 		:= nvl(mt.xml_state 		, new_mt.state_95 );
 mt.xml_country		:= nvl(mt.xml_country		, new_mt.country_100_101);
 mt.xml_transm 		:= nvl(mt.xml_transm 		, new_mt.transref_103 );
 mt.xml_category	:= nvl(mt.xml_category		, new_mt.category_15);
 mt.xml_datecreated 	:= nvl(mt.xml_datecreated 	, new_mt.date_55);
 mt.xml_urgency 	:= nvl(mt.xml_urgency 		, new_mt.urgency_10);
 mt.xml_supp 		:= nvl(mt.xml_supp 		, new_mt.bytitle_85);
 mt.xml_name 		:= nvl(mt.xml_name 		, new_mt.object_name_5);
 mt.xml_webstatement 	:= nvl(mt.xml_webstatement 	, new_mt.orig_program_65);
 mt.xml_marked	 	:= nvl(mt.xml_marked	 	, new_mt.copyright_116); -- Copyright
 mt.xml_description 	:= nvl(mt.xml_description 	, new_mt.caption_120); -- Caption
 mt.xml_seq 		:= nvl(mt.xml_seq 		, new_mt.byline_80); --Author
 mt.xml_alt 		:= nvl(mt.xml_alt 		, new_mt.locale_22);
 mt.xml_rights 		:= nvl(mt.xml_rights 		, new_mt.keywords_25);
 mt.xml_bag 		:= nvl(mt.xml_bag 		, new_mt.time_60);
 mt.xml_docid 		:= nvl(mt.xml_docid 		, new_mt.other_230_231_232);
 mt.xml_other 		:= nvl(mt.xml_other 		, new_mt.unknown);

end merge;

procedure print_mt( v_umo in integer, mt in meta_tag, c2rec in UMO%ROWTYPE, metatype in varchar2 )
as
begin
 htp.nl;
 htp.line;
 htp.nl;
 htp.bold( 'UMO ID:' || v_umo ); htp.nl;
 htp.nl;
 htp.bold( 'Image Name:' || c2rec.extras.film_name ); htp.nl;
 htp.nl;
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=1' );

 if metatype = 'IPTC Standard'
  then
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Object Name' ) );
   htp.tabledata( htf.italic( nvl(mt.object_name_5,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Urgency' ) );
   htp.tabledata( htf.italic( nvl(mt.urgency_10,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Category' ) );
   htp.tabledata( htf.italic( nvl(mt.category_15,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Supplemental Category' ) );
   htp.tabledata( htf.italic( nvl(mt.supplemental_cat_20,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Locale' ) );
   htp.tabledata( htf.italic( nvl(mt.locale_22,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Image Keywords' ) );
   htp.tabledata( htf.italic( nvl(mt.keywords_25,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Instruction' ) );
   htp.tabledata( htf.italic( nvl(mt.instruction_40,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Creation Date' ) );
   htp.tabledata( htf.italic( nvl(mt.date_55,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Creation Time' ) );
   htp.tabledata( htf.italic( nvl(mt.time_60,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Originating Program' ) );
   htp.tabledata( htf.italic( nvl(mt.orig_program_65,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Byline' ) );
   htp.tabledata( htf.italic( nvl(mt.byline_80,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Bytitle' ) );
   htp.tabledata( htf.italic( nvl(mt.bytitle_85,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'City' ) );
   htp.tabledata( htf.italic( nvl(mt.city_90,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'State Province' ) );
   htp.tabledata( htf.italic( nvl(mt.state_95,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Country' ) );
   htp.tabledata( htf.italic( nvl(mt.country_100_101,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Transref' ) );
   htp.tabledata( htf.italic( nvl(mt.transref_103,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Headline' ) );
   htp.tabledata( htf.italic( nvl(mt.headline_105,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Credit' ) );
   htp.tabledata( htf.italic( nvl(mt.credit_110,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Source' ) );
   htp.tabledata( htf.italic( nvl(mt.source_115,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Copyright' ) );
   htp.tabledata( htf.italic( nvl(mt.copyright_116,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Caption' ) );
   htp.tabledata( htf.italic( nvl(mt.caption_120,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Caption Writer' ) );
   htp.tabledata( htf.italic( nvl(mt.caption_writer_122,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Other Data' ) );
   htp.tabledata( htf.italic( nvl(mt.other_230_231_232,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Unknown' ) );
   htp.tabledata( htf.italic( nvl(mt.unknown,'&nbsp;') ));
  htp.tablerowclose;

 end if;

 if metatype = 'XML Format'
  then
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'General Caption Writer' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_captionwriter,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Origin Headline' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_headline,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Origin Instructions' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_instructions,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'General Author''s Position' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_authorposition,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Origin Credit' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_credit,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Origin Source' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_source,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Origin City' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_city,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Origin State' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_state,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Origin Country' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_country,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Origin Transmission Reference' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_transm,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Category' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_category,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Date Created' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_datecreated,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Urgency' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_urgency,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Supplemental Categories' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_supp,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'General Job Name' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_name,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'General Owner URL' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_webstatement,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Copyright' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_marked,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'General Caption' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_description,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Document Id' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_docid,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'General Author' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_seq,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'General Title' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_alt,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'General Copyright Notice' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_rights,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Keywords' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_bag,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Unknown' ) );
   htp.tabledata( htf.italic( nvl(mt.xml_other,'&nbsp;') ));
  htp.tablerowclose;

 end if;

 if metatype = 'EXIF'
  then
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ApertureValue' ) );
   htp.tabledata( htf.italic( nvl(mt.ApertureValue,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Artist' ) );
   htp.tabledata( htf.italic( nvl(mt.Artist,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'BatteryLevel' ) );
   htp.tabledata( htf.italic( nvl(mt.BatteryLevel,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'BitsPerSample' ) );
   htp.tabledata( htf.italic( nvl(mt.BitsPerSample,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'BrightnessValue' ) );
   htp.tabledata( htf.italic( nvl(mt.BrightnessValue,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'CFAPattern' ) );
   htp.tabledata( htf.italic( nvl(mt.CFAPattern,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'CFARepeatPatternDim' ) );
   htp.tabledata( htf.italic( nvl(mt.CFARepeatPatternDim,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ColorSpace' ) );
   htp.tabledata( htf.italic( nvl(mt.ColorSpace,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ComponentsConfiguration' ) );
   htp.tabledata( htf.italic( nvl(mt.ComponentsConfiguration,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'CompressedBitsPerPixel' ) );
   htp.tabledata( htf.italic( nvl(mt.CompressedBitsPerPixel,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Compression' ) );
   htp.tabledata( htf.italic( nvl(mt.Compression,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Copyright' ) );
   htp.tabledata( htf.italic( nvl(mt.Copyright,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'DateTime' ) );
   htp.tabledata( htf.italic( nvl(mt.DateTime,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'DateTimeDigitized' ) );
   htp.tabledata( htf.italic( nvl(mt.DateTimeDigitized,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'DateTimeOriginal' ) );
   htp.tabledata( htf.italic( nvl(mt.DateTimeOriginal,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'DocumentName' ) );
   htp.tabledata( htf.italic( nvl(mt.DocumentName,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ExifImageLength' ) );
   htp.tabledata( htf.italic( nvl(mt.ExifImageLength,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ExifImageWidth' ) );
   htp.tabledata( htf.italic( nvl(mt.ExifImageWidth,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ExifOffset' ) );
   htp.tabledata( htf.italic( nvl(mt.ExifOffset,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ExifVersion' ) );
   htp.tabledata( htf.italic( nvl(mt.ExifVersion,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ExposureBiasValue' ) );
   htp.tabledata( htf.italic( nvl(mt.ExposureBiasValue,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ExposureIndex' ) );
   htp.tabledata( htf.italic( nvl(mt.ExposureIndex,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ExposureProgram' ) );
   htp.tabledata( htf.italic( nvl(mt.ExposureProgram,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ExposureTime' ) );
   htp.tabledata( htf.italic( nvl(mt.ExposureTime,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FileSource' ) );
   htp.tabledata( htf.italic( nvl(mt.FileSource,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FillOrder' ) );
   htp.tabledata( htf.italic( nvl(mt.FillOrder,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Flash' ) );
   htp.tabledata( htf.italic( nvl(mt.Flash,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FlashEnergy' ) );
   htp.tabledata( htf.italic( nvl(mt.FlashEnergy,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FlashPixVersion' ) );
   htp.tabledata( htf.italic( nvl(mt.FlashPixVersion,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FNumber' ) );
   htp.tabledata( htf.italic( nvl(mt.FNumber,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FocalLength' ) );
   htp.tabledata( htf.italic( nvl(mt.FocalLength,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FocalPlaneResolutionUnit' ) );
   htp.tabledata( htf.italic( nvl(mt.FocalPlaneResolutionUnit,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FocalPlaneXResolution' ) );
   htp.tabledata( htf.italic( nvl(mt.FocalPlaneXResolution,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'FocalPlaneYResolution' ) );
   htp.tabledata( htf.italic( nvl(mt.FocalPlaneYResolution,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'GPSInfo' ) );
   htp.tabledata( htf.italic( nvl(mt.GPSInfo,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ImageDescription' ) );
   htp.tabledata( htf.italic( nvl(mt.ImageDescription,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ImageLength' ) );
   htp.tabledata( htf.italic( nvl(mt.ImageLength,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ImageWidth' ) );
   htp.tabledata( htf.italic( nvl(mt.ImageWidth,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'InterColorProfile' ) );
   htp.tabledata( htf.italic( nvl(mt.InterColorProfile,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'InteroperabilityOffset' ) );
   htp.tabledata( htf.italic( nvl(mt.InteroperabilityOffset,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'IPTC/NAA' ) );
   htp.tabledata( htf.italic( nvl(mt.IPTC_NAA,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ISOSpeedRatings ' ) );
   htp.tabledata( htf.italic( nvl(mt.ISOSpeedRatings ,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'JPEGInterchangeFormat' ) );
   htp.tabledata( htf.italic( nvl(mt.JPEGInterchangeFormat,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'JPEGInterchangeFormatLength' ) );
   htp.tabledata( htf.italic( nvl(mt.JPEGInterchangeFormatLength,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'JPEGProc' ) );
   htp.tabledata( htf.italic( nvl(mt.JPEGProc,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'LightSource' ) );
   htp.tabledata( htf.italic( nvl(mt.LightSource,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Make' ) );
   htp.tabledata( htf.italic( nvl(mt.Make,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'MakerNote' ) );
   htp.tabledata( htf.italic( nvl(mt.MakerNote,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'MaxApertureValue' ) );
   htp.tabledata( htf.italic( nvl(mt.MaxApertureValue,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'MeteringMode' ) );
   htp.tabledata( htf.italic( nvl(mt.MeteringMode,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Model' ) );
   htp.tabledata( htf.italic( nvl(mt.Model,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'OECF' ) );
   htp.tabledata( htf.italic( nvl(mt.OECF,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Orientation' ) );
   htp.tabledata( htf.italic( nvl(mt.Orientation,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'PhotometricInterpretation' ) );
   htp.tabledata( htf.italic( nvl(mt.PhotometricInterpretation,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'PlanarConfiguration' ) );
   htp.tabledata( htf.italic( nvl(mt.PlanarConfiguration,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'PrimaryChromaticities' ) );
   htp.tabledata( htf.italic( nvl(mt.PrimaryChromaticities,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ReferenceBlackWhite' ) );
   htp.tabledata( htf.italic( nvl(mt.ReferenceBlackWhite,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ResolutionUnit' ) );
   htp.tabledata( htf.italic( nvl(mt.ResolutionUnit,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'RowsPerStrip ' ) );
   htp.tabledata( htf.italic( nvl(mt.RowsPerStrip ,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SamplesPerPixel' ) );
   htp.tabledata( htf.italic( nvl(mt.SamplesPerPixel,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SceneType ' ) );
   htp.tabledata( htf.italic( nvl(mt.SceneType ,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SensingMethod' ) );
   htp.tabledata( htf.italic( nvl(mt.SensingMethod,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'ShutterSpeedValue' ) );
   htp.tabledata( htf.italic( nvl(mt.ShutterSpeedValue,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Software' ) );
   htp.tabledata( htf.italic( nvl(mt.Software,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SpatialFrequencyResponse' ) );
   htp.tabledata( htf.italic( nvl(mt.SpatialFrequencyResponse,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SpectralSensitivity' ) );
   htp.tabledata( htf.italic( nvl(mt.SpectralSensitivity,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'StripByteCounts' ) );
   htp.tabledata( htf.italic( nvl(mt.StripByteCounts,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'StripOffsets' ) );
   htp.tabledata( htf.italic( nvl(mt.StripOffsets,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SubjectDistance' ) );
   htp.tabledata( htf.italic( nvl(mt.SubjectDistance,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SubjectLocation' ) );
   htp.tabledata( htf.italic( nvl(mt.SubjectLocation,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SubSecTime' ) );
   htp.tabledata( htf.italic( nvl(mt.SubSecTime,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SubSecTimeDigitized' ) );
   htp.tabledata( htf.italic( nvl(mt.SubSecTimeDigitized,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'SubSecTimeOriginal' ) );
   htp.tabledata( htf.italic( nvl(mt.SubSecTimeOriginal,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'TransferFunction' ) );
   htp.tabledata( htf.italic( nvl(mt.TransferFunction,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'TransferRange' ) );
   htp.tabledata( htf.italic( nvl(mt.TransferRange,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'UserComment' ) );
   htp.tabledata( htf.italic( nvl(mt.UserComment,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'WhitePoint' ) );
   htp.tabledata( htf.italic( nvl(mt.WhitePoint,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'XResolution' ) );
   htp.tabledata( htf.italic( nvl(mt.XResolution,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'YCbCrCoefficients' ) );
   htp.tabledata( htf.italic( nvl(mt.YCbCrCoefficients,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'YCbCrPositioning' ) );
   htp.tabledata( htf.italic( nvl(mt.YCbCrPositioning,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'YCbCrSubSampling' ) );
   htp.tabledata( htf.italic( nvl(mt.YCbCrSubSampling,'&nbsp;') ));
  htp.tablerowclose;
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'YResolution' ) );
   htp.tabledata( htf.italic( nvl(mt.YResolution,'&nbsp;') ));
  htp.tablerowclose;

 end if;

 htp.tableclose;
 htp.nl;
exception
 when others
  then
   htp.p( 'Error in Print_MT' ); htp.nl;
   htp.p( sqlerrm );
end print_mt;

procedure update_mt( surl in varchar2, v_umo in integer, acid in integer, attribid integer, vl in varchar2 )
as

 attr		integer;
 retval		varchar2(4000);
 parm1		ump.parameters;
 parm2		ump.parameters;

begin
 if attribid is null then return; end if; -- No Tag

 parm1(1) := 'UMO_ID';
 parm2(1) := v_umo;
 parm1(2) := 'AID';
 parm2(2) := to_char(acid);
 parm1(3) := 'OBJECT_TYPE';
 parm2(3) := 'PHOTO';
 parm1(4) := 'KEEP_STATUS';
 parm2(4) := 'KEEP';
 parm1(5) := 'ATTRIBUTE_ID';
 parm2(5) := '[' || attribid || ']' || substr(vl,1,1000);
 ump.modify_uma(surl,parm1,parm2,retval);
 if retval is not null
  then
   htp.bold( 'Error Updating Image #' || v_umo || '. Attribid:' || attribid || ' value: ' || vl );
   htp.nl;
   htp.bold( 'Error: ' || retval ); htp.nl;
   htp.nl;
 end if;

end update_mt;

function retattribid( phgid integer, metatype in varchar2, tgm varchar2 )
 return integer
as
 cursor c1(phgid integer, tm varchar2, tgm varchar2 ) is select attribute_id from novelty_metamap where pid = phgid and type_of_metatag = tm and tagname = tgm;
 c1rec	c1%ROWTYPE;
begin
   open c1( phgid, metatype, tgm );
   fetch c1 into c1rec;
   close c1;
   return( c1rec.attribute_id );
end retattribid;

procedure load_mt( surl in varchar2, v_umo in integer, acid in integer, mt in meta_tag, phgid integer, metatype in varchar2 )
as
begin
 if metatype = 'IPTC Standard'
  then
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Object Name'), mt.object_name_5 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Urgency'), mt.urgency_10 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Category'), mt.category_15 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Supplemental Category'), mt.supplemental_cat_20 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Locale'), mt.locale_22 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Image Keywords'), mt.keywords_25 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Instruction'), mt.instruction_40 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Creation Date'), mt.date_55 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Creation Time'), mt.time_60 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Originating Program'), mt.orig_program_65 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Byline'), mt.byline_80 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Bytitle'), mt.bytitle_85 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'City'), mt.city_90 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'State Province'), mt.state_95 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Country'), mt.country_100_101 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Transref'), mt.transref_103 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Headline'), mt.headline_105 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Credit'), mt.credit_110 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Source'), mt.source_115 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Copyright'), mt.copyright_116 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Caption'), mt.caption_120 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Caption Writer'), mt.caption_writer_122 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Other Data'), mt.other_230_231_232 );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Unknown'), mt.unknown );
   htp.bold( '. Loaded ' || v_umo ); htp.nl;
   commit;
 end if;
 if metatype = 'XML Format'
  then
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'General Caption Writer'), mt.xml_captionwriter );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Origin Headline'), mt.xml_headline );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Origin Instructions'), mt.xml_instructions );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'General Author''s Position'), mt.xml_authorposition );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Origin Credit'), mt.xml_credit );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Origin Source'), mt.xml_source );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Origin City'), mt.xml_city );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Origin State'), mt.xml_state );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Origin Country'), mt.xml_country );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Origin Transmission Reference'), mt.xml_transm );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Category'), mt.xml_category );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Date Created'), mt.xml_datecreated );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Urgency'), mt.xml_urgency );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Supplemental Categories'), mt.xml_supp );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'General Job Name'), mt.xml_name );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'General Owner URL'), mt.xml_webstatement );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Copyright'), mt.xml_marked );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'General Caption'), mt.xml_description );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Document Id'), mt.xml_docid );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'General Author'), mt.xml_seq );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'General Title'), mt.xml_alt );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'General Copyright Notice'), mt.xml_rights );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Keywords'), mt.xml_bag );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Unknown'), mt.xml_other );
   htp.bold( '. Loaded ' || v_umo ); htp.nl;
   commit;
 end if;
 if metatype = 'EXIF'
  then
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ApertureValue'), mt.ApertureValue );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Artist'), mt.Artist );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'BatteryLevel'), mt.BatteryLevel );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'BitsPerSample'), mt.BitsPerSample );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'BrightnessValue'), mt.BrightnessValue );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'CFAPattern'), mt.CFAPattern );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'CFARepeatPatternDim'), mt.CFARepeatPatternDim );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ColorSpace'), mt.ColorSpace );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ComponentsConfiguration'), mt.ComponentsConfiguration );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'CompressedBitsPerPixel'), mt.CompressedBitsPerPixel );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Compression'), mt.Compression );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Copyright'), mt.Copyright );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'DateTime'), mt.DateTime );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'DateTimeDigitized'), mt.DateTimeDigitized );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'DateTimeOriginal'), mt.DateTimeOriginal );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'DocumentName'), mt.DocumentName );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ExifImageLength'), mt.ExifImageLength );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ExifImageWidth'), mt.ExifImageWidth );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ExifOffset'), mt.ExifOffset );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ExifVersion'), mt.ExifVersion );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ExposureBiasValue'), mt.ExposureBiasValue );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ExposureIndex'), mt.ExposureIndex );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ExposureProgram'), mt.ExposureProgram );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ExposureTime'), mt.ExposureTime );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FileSource'), mt.FileSource );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FillOrder'), mt.FillOrder );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Flash'), mt.Flash );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FlashEnergy'), mt.FlashEnergy );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FlashPixVersion'), mt.FlashPixVersion );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FNumber'), mt.FNumber );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FocalLength'), mt.FocalLength );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FocalPlaneResolutionUnit'), mt.FocalPlaneResolutionUnit );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FocalPlaneXResolution'), mt.FocalPlaneXResolution );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'FocalPlaneYResolution'), mt.FocalPlaneYResolution );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'GPSInfo'), mt.GPSInfo );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ImageDescription'), mt.ImageDescription );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ImageLength'), mt.ImageLength );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ImageWidth'), mt.ImageWidth );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'InterColorProfile'), mt.InterColorProfile );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'InteroperabilityOffset'), mt.InteroperabilityOffset );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'IPTC/NAA'), mt.IPTC_NAA );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ISOSpeedRatings'), mt.ISOSpeedRatings );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'JPEGInterchangeFormat'), mt.JPEGInterchangeFormat );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'JPEGInterchangeFormatLength'), mt.JPEGInterchangeFormatLength );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'JPEGProc'), mt.JPEGProc );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'LightSource'), mt.LightSource );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Make'), mt.Make );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'MakerNote'), mt.MakerNote );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'MaxApertureValue'), mt.MaxApertureValue );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'MeteringMode'), mt.MeteringMode );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Model'), mt.Model );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'OECF'), mt.OECF );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Orientation'), mt.Orientation );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'PhotometricInterpretation'), mt.PhotometricInterpretation );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'PlanarConfiguration'), mt.PlanarConfiguration );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'PrimaryChromaticities'), mt.PrimaryChromaticities );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ReferenceBlackWhite'), mt.ReferenceBlackWhite );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ResolutionUnit'), mt.ResolutionUnit );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'RowsPerStrip'), mt.RowsPerStrip );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SamplesPerPixel'), mt.SamplesPerPixel );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SceneType'), mt.SceneType );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SensingMethod'), mt.SensingMethod );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'ShutterSpeedValue'), mt.ShutterSpeedValue );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'Software'), mt.Software );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SpatialFrequencyResponse'), mt.SpatialFrequencyResponse );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SpectralSensitivity'), mt.SpectralSensitivity );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'StripByteCounts'), mt.StripByteCounts );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'StripOffsets'), mt.StripOffsets );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SubjectDistance'), mt.SubjectDistance );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SubjectLocation'), mt.SubjectLocation );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SubSecTime'), mt.SubSecTime );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SubSecTimeDigitized'), mt.SubSecTimeDigitized );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'SubSecTimeOriginal'), mt.SubSecTimeOriginal );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'TransferFunction'), mt.TransferFunction );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'TransferRange'), mt.TransferRange );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'UserComment'), mt.UserComment );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'WhitePoint'), mt.WhitePoint );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'XResolution'), mt.XResolution );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'YCbCrCoefficients'), mt.YCbCrCoefficients );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'YCbCrPositioning'), mt.YCbCrPositioning );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'YCbCrSubSampling'), mt.YCbCrSubSampling );
   update_mt( surl, v_umo, acid, retattribid( phgid, metatype, 'YResolution'), mt.YResolution );
   htp.bold( '. Loaded ' || v_umo ); htp.nl;
   commit;
 end if;
end load_mt;

function load_one_image( surl in varchar2, phgid integer, metatype in varchar2, acid in integer, v_umo in integer, printoutput in boolean default false )
 return boolean
as
 cursor c2(acid integer) is select * from umo where aid = acid and umo_type = 'PHOTO' order by umo_id;
 c2rec		c2%ROWTYPE;
 curr_mt	meta_tag;
begin
   extract_meta_tags( surl, v_umo, curr_mt, metatype );
   if printoutput
    then
     open c2(v_umo);
     fetch c2 into c2rec;
     close c2;
     print_mt( v_umo, curr_mt, c2rec, metatype );
    else
     load_mt( surl, v_umo, acid, curr_mt, phgid, metatype );
   end if;
   return( TRUE );
exception
 when others then return( FALSE );
end load_one_image;

procedure meta_load( surl in varchar2, phgid integer, metatype in varchar2, acid in integer, loadall in boolean, displayonly in boolean, nmb out integer )
as

 cursor c1(un varchar2) is select * from customer_account where upper(username) = upper(un);
 cursor c2(acid integer) is select * from umo where aid = acid and umo_type = 'PHOTO' order by umo_id;
 cursor c2a(acid integer, attribid integer) is
  select *
  from umo
  where umo_id
  in
  (
   select um.umo_id
   from umo um, umo_attribute ua
   where aid = acid and
         ua.attribute_id = attribid and
         ua.umo_id = um.umo_id and
         ua.value is null and
         umo_type = 'PHOTO'
  )
  order by umo_id;

 cursor c3(phgid integer, tm varchar2, tgm varchar2 ) is select attribute_id from novelty_metamap where pid = phgid and type_of_metatag = tm and tagname = tgm;
 cursor c5(phgid integer, tm varchar2 ) is select attribute_id from novelty_metamap where pid = phgid and type_of_metatag = tm and is_mandatory = 'T';

 c3rec		c3%ROWTYPE;
 c5rec		c5%ROWTYPE;
 curr_mt	meta_tag;

begin
 nmb := 0;
 if loadall
  then

   for c2rec in c2(acid) loop
    nmb := nmb + 1;

    extract_meta_tags( surl, c2rec.umo_id, curr_mt, metatype );
    if displayonly
     then
     print_mt( c2rec.umo_id, curr_mt, c2rec, metatype );
    else
     load_mt( surl, c2rec.umo_id, acid, curr_mt, phgid, metatype );
    end if;
   end loop;

  else

   /*
   if metatype = 'IPTC Standard'
     then
      open c3( phgid, metatype, 'Creation Date' );
    elsif metatype = 'XML Format'
     then
      open c3( phgid, metatype, 'Date Created' );
   end if;
   fetch c3 into c3rec;
   close c3;
   */
   open c5(phgid, metatype);
   fetch c5 into c5rec;
   close c5;
   for c2rec in c2a(acid, c5rec.attribute_id) loop
    nmb := nmb + 1;
    extract_meta_tags( surl, c2rec.umo_id, curr_mt, metatype );
    if displayonly
     then
     print_mt( c2rec.umo_id, curr_mt, c2rec, metatype );
    else
     load_mt( surl, c2rec.umo_id, acid, curr_mt, phgid, metatype );
    end if;
   end loop;

 end if;

exception
 when others then htp.p( 'Error in Meta Load:' || sqlerrm );
end meta_load;

function tagmap( phgid integer, metatype in varchar2, tname in varchar2, acid in integer )
 return varchar2
as

 cursor c1(phgid integer, metatype varchar2, tname varchar2 ) is select attribute_id from novelty_metamap where pid = phgid and type_of_metatag = metatype and tagname = tname;
 cursor c2(objtype varchar2, acid integer) is
  select attribute_id, category, sub_category, umo_type
  from umo_attributes
   where umo_type = objtype and
         ((business_feature is null) or
          (business_feature is not null and business_feature = (select theme_type from customer_account ca where ca.aid = acid))
         )
  order by category, sub_category;

 c1rec	c1%ROWTYPE;
 txt	varchar2(32767);
begin
 open c1(phgid, metatype, tname);
 fetch c1 into c1rec;
 close c1;
 txt := htf.formhidden( 'P1', tname );
 txt := txt || htf.formselectopen( 'P2' );
 txt := txt || htf.formselectoption( NULL );
 for c2rec in c2('PHOTO',acid) loop
  if c2rec.attribute_id = c1rec.attribute_id
   then
    txt := txt || htf.formselectoption( '[' || c2rec.category || '] ' || c2rec.sub_category || ' (' || c2rec.umo_type || ')', 'SELECTED', cattributes=>'VALUE="' || c2rec.attribute_id || '"' );
   else
    txt := txt || htf.formselectoption( '[' || c2rec.category || '] ' || c2rec.sub_category || ' (' || c2rec.umo_type || ')', cattributes=>'VALUE="' || c2rec.attribute_id || '"' );
  end if;
 end loop;
 txt := txt || htf.formselectclose;
 return( txt );
end tagmap;

function ismand( phgid integer, metatype in varchar2, tname in varchar2, acid in integer )
 return varchar2
as
 cursor c1(phgid integer, metatype varchar2, tname varchar2 ) is select attribute_id,is_mandatory from novelty_metamap where pid = phgid and type_of_metatag = metatype and tagname = tname;
 c1rec  c1%ROWTYPE;
 txt	varchar2(32767);
begin
 open c1(phgid, metatype, tname);
 fetch c1 into c1rec;
 close c1;
 if c1rec.is_mandatory = 'T' then return( htf.formcheckbox( 'P3', c1rec.attribute_id, 'CHECKED' ) ); end if;
 return( htf.formcheckbox( 'P3', c1rec.attribute_id ) );
end ismand;

procedure display_metatags( phgid integer, metatype in varchar2, pfx in theme%ROWTYPE, acid in integer )
as
begin

 if metatype = 'IPTC Standard'
  then
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Object Name' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Object Name', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Object Name', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Urgency' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Urgency', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Urgency', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Category' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Category', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Category', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Supplemental Category' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Supplemental Category', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Supplemental Category', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Locale' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Locale', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Locale', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Image Keywords' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Image Keywords', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Image Keywords', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Instruction' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Instruction', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Instruction', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Creation Date' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Creation Date', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Creation Date', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Creation Time' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Creation Time', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Creation Time', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Originating Program' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Originating Program', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Originating Program', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Byline' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Byline', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Byline', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Bytitle' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Bytitle', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Bytitle', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'City' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'City', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'City', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'State Province' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'State Province', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'State Province', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Country' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Country', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Country', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Transref' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Transref', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Transref', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Headline' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Headline', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Headline', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Credit' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Credit', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Credit', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Source' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Source', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Source', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Copyright' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Copyright', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Copyright', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Caption' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Caption', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Caption', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Caption Writer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Caption Writer', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Caption Writer', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Other Data' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Other Data', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Other Data', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Unknown' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Unknown', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Unknown', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
  end if;

 if metatype = 'XML Format'
  then
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'General Caption Writer' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'General Caption Writer', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'General Caption Writer', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Origin Headline' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Origin Headline', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Origin Headline', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Origin Instructions' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Origin Instructions', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Origin Instructions', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'General Author''s Position' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'General Author''s Position', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'General Author''s Position', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Origin Credit' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Origin Credit', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Origin Credit', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Origin Source' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Origin Source', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Origin Source', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Origin City' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Origin City', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Origin City', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Origin State' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Origin State', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Origin State', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Origin Country' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Origin Country', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Origin Country', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Origin Transmission Reference' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Origin Transmission Reference', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Origin Transmission Reference', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Category' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Category', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Category', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Date Created' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Date Created', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Date Created', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Urgency' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Urgency', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Urgency', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Supplemental Categories' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Supplemental Categories', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Supplemental Categories', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'General Job Name' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'General Job Name', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'General Job Name', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'General Owner URL' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'General Owner URL', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'General Owner URL', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Copyright' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Copyright', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Copyright', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'General Caption' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'General Caption', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'General Caption', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Document Id' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Document Id', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Document Id', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'General Author' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'General Author', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'General Author', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'General Title' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'General Title', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'General Title', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'General Copyright Notice' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'General Copyright Notice', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'General Copyright Notice', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Keywords' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Keywords', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Keywords', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Unknown' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Unknown', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Unknown', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
  end if;

 if metatype = 'EXIF'
  then
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ApertureValue' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ApertureValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ApertureValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Artist' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Artist', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Artist', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'BatteryLevel' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'BatteryLevel', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'BatteryLevel', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'BitsPerSample' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'BitsPerSample', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'BitsPerSample', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'BrightnessValue' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'BrightnessValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'BrightnessValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'CFAPattern' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'CFAPattern', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'CFAPattern', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'CFARepeatPatternDim' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'CFARepeatPatternDim', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'CFARepeatPatternDim', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ColorSpace' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ColorSpace', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ColorSpace', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ComponentsConfiguration' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ComponentsConfiguration', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ComponentsConfiguration', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'CompressedBitsPerPixel' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'CompressedBitsPerPixel', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'CompressedBitsPerPixel', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Compression' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Compression', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Compression', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Copyright' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Copyright', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Copyright', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'DateTime' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'DateTime', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'DateTime', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'DateTimeDigitized' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'DateTimeDigitized', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'DateTimeDigitized', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'DateTimeOriginal' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'DateTimeOriginal', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'DateTimeOriginal', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'DocumentName' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'DocumentName', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'DocumentName', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ExifImageLength' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ExifImageLength', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ExifImageLength', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ExifImageWidth' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ExifImageWidth', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ExifImageWidth', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ExifOffset' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ExifOffset', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ExifOffset', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ExifVersion' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ExifVersion', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ExifVersion', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ExposureBiasValue' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ExposureBiasValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ExposureBiasValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ExposureIndex' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ExposureIndex', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ExposureIndex', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ExposureProgram' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ExposureProgram', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ExposureProgram', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ExposureTime' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ExposureTime', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ExposureTime', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FileSource' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FileSource', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FileSource', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FillOrder' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FillOrder', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FillOrder', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Flash' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Flash', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Flash', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FlashEnergy' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FlashEnergy', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FlashEnergy', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FlashPixVersion' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FlashPixVersion', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FlashPixVersion', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FNumber' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FNumber', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FNumber', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FocalLength' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FocalLength', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FocalLength', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FocalPlaneResolutionUnit' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FocalPlaneResolutionUnit', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FocalPlaneResolutionUnit', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FocalPlaneXResolution' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FocalPlaneXResolution', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FocalPlaneXResolution', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'FocalPlaneYResolution' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'FocalPlaneYResolution', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'FocalPlaneYResolution', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'GPSInfo' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'GPSInfo', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'GPSInfo', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ImageDescription' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ImageDescription', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ImageDescription', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ImageLength' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ImageLength', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ImageLength', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ImageWidth' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ImageWidth', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ImageWidth', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'InterColorProfile' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'InterColorProfile', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'InterColorProfile', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'InteroperabilityOffset' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'InteroperabilityOffset', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'InteroperabilityOffset', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'IPTC/NAA' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'IPTC/NAA', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'IPTC/NAA', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ISOSpeedRatings' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ISOSpeedRatings', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ISOSpeedRatings', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'JPEGInterchangeFormat' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'JPEGInterchangeFormat', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'JPEGInterchangeFormat', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'JPEGInterchangeFormatLength' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'JPEGInterchangeFormatLength', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'JPEGInterchangeFormatLength', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'JPEGProc' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'JPEGProc', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'JPEGProc', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'LightSource' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'LightSource', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'LightSource', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Make' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Make', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Make', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'MakerNote' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'MakerNote', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'MakerNote', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'MaxApertureValue' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'MaxApertureValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'MaxApertureValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'MeteringMode' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'MeteringMode', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'MeteringMode', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Model' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Model', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Model', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'OECF' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'OECF', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'OECF', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Orientation' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Orientation', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Orientation', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'PhotometricInterpretation' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'PhotometricInterpretation', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'PhotometricInterpretation', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'PlanarConfiguration' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'PlanarConfiguration', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'PlanarConfiguration', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'PrimaryChromaticities' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'PrimaryChromaticities', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'PrimaryChromaticities', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ReferenceBlackWhite' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ReferenceBlackWhite', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ReferenceBlackWhite', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ResolutionUnit' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ResolutionUnit', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ResolutionUnit', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'RowsPerStrip' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'RowsPerStrip', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'RowsPerStrip', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SamplesPerPixel' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SamplesPerPixel', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SamplesPerPixel', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SceneType' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SceneType', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SceneType', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SensingMethod' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SensingMethod', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SensingMethod', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'ShutterSpeedValue' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'ShutterSpeedValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'ShutterSpeedValue', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'Software' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'Software', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'Software', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SpatialFrequencyResponse' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SpatialFrequencyResponse', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SpatialFrequencyResponse', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SpectralSensitivity' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SpectralSensitivity', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SpectralSensitivity', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'StripByteCounts' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'StripByteCounts', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'StripByteCounts', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'StripOffsets' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'StripOffsets', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'StripOffsets', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SubjectDistance' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SubjectDistance', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SubjectDistance', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SubjectLocation' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SubjectLocation', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SubjectLocation', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SubSecTime' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SubSecTime', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SubSecTime', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SubSecTimeDigitized' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SubSecTimeDigitized', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SubSecTimeDigitized', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'SubSecTimeOriginal' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'SubSecTimeOriginal', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'SubSecTimeOriginal', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'TransferFunction' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'TransferFunction', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'TransferFunction', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'TransferRange' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'TransferRange', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'TransferRange', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'UserComment' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'UserComment', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'UserComment', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'WhitePoint' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'WhitePoint', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'WhitePoint', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'XResolution' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'XResolution', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'XResolution', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'YCbCrCoefficients' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'YCbCrCoefficients', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'YCbCrCoefficients', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'YCbCrPositioning' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'YCbCrPositioning', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'YCbCrPositioning', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'YCbCrSubSampling' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'YCbCrSubSampling', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'YCbCrSubSampling', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
   htp.tablerowopen;
    htp.tabledata( htf.bold( 'YResolution' ), cattributes=>pfx.qbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( tagmap( phgid, metatype, 'YResolution', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="LEFT"' );
    htp.tabledata( ismand( phgid, metatype, 'YResolution', acid ), cattributes=>pfx.qcbground || 'valign="MIDDLE" ALIGN="CENTER"' );
   htp.tablerowclose;
 end if;

end display_metatags;

procedure meta_pref(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, msg in varchar2 default null )
as

 cursor c1(phgid integer, acid integer) is select count('x') tot from umo um where umo_type = 'PHOTO' and dbms_lob.getlength(um.photo_master.source.localdata) > 0 and aid = acid and aid = (select aid from customer_account where aid=acid and pid=phgid);

 cursor c2(phgid integer, acid integer, attribid integer) is
  select count('x') tot
  from umo um, umo_attribute ua
  where umo_type = 'PHOTO' and
        ua.attribute_id = attribid and
        ua.umo_id = um.umo_id and
        ua.value is null and
        aid = acid and
        aid = (select aid from customer_account where aid=acid and pid=phgid);

 cursor c3(phgid integer, tm varchar2, tgm varchar2 ) is select attribute_id from novelty_metamap where pid = phgid and type_of_metatag = tm and tagname = tgm;
 cursor c4(phgid integer, tm varchar2 ) is select count('x') tot from novelty_metamap where pid = phgid and type_of_metatag = tm;
 cursor c5(phgid integer, tm varchar2 ) is select attribute_id from novelty_metamap where pid = phgid and type_of_metatag = tm and is_mandatory = 'T';

 c1rec		c1%ROWTYPE;
 c2rec		c2%ROWTYPE;
 c3rec		c3%ROWTYPE;
 c4rec		c4%ROWTYPE;
 c5rec		c5%ROWTYPE;
 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 vloc_id	integer;
 sts		varchar2(100);
 stnd		varchar2(100);
 pfx		THEME%ROWTYPE;
 retcall	varchar2(10000);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MLOAD.META_PREF', iscust=>FALSE );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 open c1(owner_id,acid);
 fetch c1 into c1rec;
 close c1;

 pfx := glbx.get_thm( acid );
 glbx.main_title( surl, 'Attach Meta Data Extracted from JPEG Images',glbx.backimg(surl,acid,pfx.text_back,null,ltype),stype=>stype,sstyle=>pfx.text_font,sclr=>pfx.text_colour,det_sstyle=>pfx.title_text_font,det_sclr=>pfx.title_text_colour,det_font=>pfx.title_colour_font,hover=>pfx.hover_colour, finc=>pfx.text_font_inc, errclr=>pfx.error_text_colour, errfnt=>pfx.error_text_font, instclr=>pfx.instruct_text_colour, instfnt=>pfx.instruct_text_font, instfntinc=>pfx.instruct_font_inc,icra_label=>pfx.icra_label,top_padding=>pfx.top_padding,left_padding=>pfx.left_padding,lnk=>pfx.underline_active,stylesh=>pfx.stylesheet);
 htp.title( 'Attach Meta Data Extracted from JPEG Images' );
 htp.nl;
 htp.p( '<CENTER>' );
 vloc_id := nvl(loc_id,1); -- Use loc_id to store which type of meta data to load
 -- List all Available type
 retcall := '?surl=' || surl || '&nvid=' || nvid || '&footer_api=' || replace(footer_api,' ','+') || '&left_api_parm=' || replace(left_api_parm,' ','+') || '&current_page_number=' || current_page_number || '&display_detail=' || display_detail || '&acid=' || acid || '&first_parameter=' || replace(first_parameter,' ','+') || '&called_from=' || replace(called_from,' ','+');

 -- This is kept here for future proofing. There will be more meta data standard arriving in the market place. Currently only IPTC Supported.
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=2 border=0' );
  htp.tablerowopen;
   htp.tabledata( htf.bold( 'Meta Data Standard' || ':' ));
   htp.tabledata( htf.anchor( 'mload.main' || retcall || '&loc_id=1', '[Adobe - IPTC]' ));
   htp.tabledata( htf.anchor( 'mload.main' || retcall || '&loc_id=2', '[Adobe - XML]' ));
   htp.tabledata( htf.anchor( 'mload.main' || retcall || '&loc_id=3', '[EXIF]' ));
  htp.tablerowclose;
 htp.tableclose;
 htp.nl;

 if vloc_id = 1
  then
   htp.italic( 'Standard to be used' || ':' || 'Adobe - IPTC' );
   htp.nl;
   stnd := 'IPTC Standard';
   open c5( owner_id, stnd );
   fetch c5 into c5rec;
   close c5;
   --open c3( owner_id, stnd, 'Creation Date' );
   --fetch c3 into c3rec;
   --close c3;
   open c4( owner_id, stnd );
   fetch c4 into c4rec;
   close c4;
   if c4rec.tot > 0
    then
     open c2(owner_id,acid, c5rec.attribute_id);
     fetch c2 into c2rec;
     close c2;
   end if;
 elsif vloc_id = 2
  then
   htp.italic( 'Standard to be used' || ':' || 'Adobe - XML' );
   htp.nl;
   stnd := 'XML Format';
   open c5( owner_id, stnd );
   fetch c5 into c5rec;
   close c5;
   --open c3( owner_id, stnd, 'Date Created' );
   --fetch c3 into c3rec;
   --close c3;
   open c4( owner_id, stnd );
   fetch c4 into c4rec;
   close c4;
   if c4rec.tot > 0
    then
     open c2(owner_id,acid, c5rec.attribute_id);
     fetch c2 into c2rec;
     close c2;
   end if;
 elsif vloc_id = 3
  then
   htp.italic( 'Standard to be used' || ':' || 'EXIF' );
   htp.nl;
   stnd := 'EXIF';
   open c5( owner_id, stnd );
   fetch c5 into c5rec;
   close c5;
   open c4( owner_id, stnd );
   fetch c4 into c4rec;
   close c4;
   if c4rec.tot > 0
    then
     open c2(owner_id,acid, c5rec.attribute_id);
     fetch c2 into c2rec;
     close c2;
   end if;
 end if;

 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
  htp.tablerowopen;
    htp.tabledata(htf.bold( 'Number of Photos in the Account' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
    htp.tabledata(htf.bold( to_char(nvl(c1rec.tot,0)) ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
  htp.tablerowclose;
  if c4rec.tot > 0
   then
    htp.tablerowopen;
      htp.tabledata(htf.bold( 'Number of Photos in the Account without any Meta Data Attached' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.tabledata(htf.bold( to_char(nvl(c2rec.tot,0)) ),cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
   else
    htp.tablerowopen;
      htp.tabledata(htf.bold( 'No Meta Data Tags have yet been mapped' ), cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.tabledata( '&nbsp;', cattributes=>pfx.qcbground || 'valign="TOP" align="LEFT"');
    htp.tablerowclose;
  end if;
 htp.tableclose;
 htp.nl;
 htp.bold( 'Check the Checkbox to Mark a Field as always having a Value in it.' );
 htp.nl;
 htp.bold( 'Used to Determine if Meta Data has not been Mapped yet.' );
 htp.nl;

 -- Display the Mapping
 htp.formopen( 'mload.accept_meta_define' );
 htp.formhidden( 'SURL', glbx.rndsurl(surl));
 htp.formhidden( 'ACID', acid );
 htp.formhidden( 'NVID', nvid );
 htp.formhidden( 'LOC_ID', vloc_id );
 htp.formhidden( 'FOOTER_API', footer_api );
 htp.formhidden( 'LEFT_API_PARM', left_api_parm );
 htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
 htp.formhidden( 'DISPLAY_DETAIL', display_detail );
 htp.formhidden( 'FIRST_PARAMETER', first_parameter );
 htp.formhidden( 'CALLED_FROM', called_from );
 htp.formhidden( 'P3', null );
 htp.nl;
 htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
  display_metatags( owner_id, stnd, pfx, acid );
 htp.tableclose;
 htp.nl;
 htp.formsubmit( null, 'Define Meta Data Tags' );
 htp.formclose;
 htp.nl;

 if c4rec.tot > 0
  then
   htp.nl;
   htp.line;
   htp.nl;
   htp.formopen( 'mload.accept_meta_load', cattributes=>'onsubmit="javascript: window.open('''',''LOG_WINDOW'',''top=100,left=100,width=600,height=800,location=no,toolbar=no,resizable=yes,menubar=no,scrollbars=yes,status=no''); this.target=''LOG_WINDOW'';"' );
   htp.formhidden( 'SURL', glbx.rndsurl(surl));
   htp.formhidden( 'ACID', acid );
   htp.formhidden( 'NVID', nvid );
   htp.formhidden( 'LOC_ID', vloc_id );
   htp.formhidden( 'FOOTER_API', footer_api );
   htp.formhidden( 'LEFT_API_PARM', left_api_parm );
   htp.formhidden( 'CURRENT_PAGE_NUMBER', current_page_number );
   htp.formhidden( 'DISPLAY_DETAIL', display_detail );
   htp.formhidden( 'FIRST_PARAMETER', first_parameter );
   htp.formhidden( 'CALLED_FROM', called_from );

   htp.tableopen( cattributes=>'cellpadding=2 cellspacing=0 border=1' );
    htp.tablerowopen;
      htp.tabledata(htf.bold( 'Perform Activity' ),cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
      htp.formselectopen( 'P1' );
       htp.formselectoption( 'Attach Meta Data for all Photos without any Meta Data Attached - ' || c2rec.tot || ' ' || 'Photo(s)', cattributes=>'VALUE="G"' );
       htp.formselectoption( 'Attach Meta Data for All Photos', cattributes=>'VALUE="A"' );
       htp.formselectoption( 'Display Only - Do not Attach (Meta Data for all Photos without any Meta Data Attached - ' || c2rec.tot || ' ' || 'Photo(s) )', 'SELECTED', cattributes=>'VALUE="g"' );
       htp.formselectoption( 'Display Only - Do not Attach (Meta Data for All Photos)', cattributes=>'VALUE="t"' );
      htp.formselectclose;
      htp.p( '</TD>' );
    htp.tablerowclose;
    htp.tablerowopen;
      htp.tabledata( '&nbsp;',cattributes=>pfx.qbground || 'valign="TOP" align="LEFT"');
      htp.p( '<TD ' || pfx.qcbground || 'valign="TOP" align="LEFT">');
       htp.formsubmit( null, 'Attach Meta Data' );
      htp.p( '</TD>' );
    htp.tablerowclose;
   htp.tableclose;
   htp.formclose;
   htp.nl;
   htp.nl;
   htp.italic( 'Note: A Photo is deemed to have Meta Data attached to it if the [Creation Date] Metatag is populated' );
   htp.nl;
 end if;

 htp.p( '</CENTER>' );
 htp.htmlclose;

exception when others then
 glbx.error_details( 'MLOAD', 'META_PREF',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end meta_pref;

procedure accept_meta_define(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY, p3 in GLBX.MYARRAY )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 stnd		varchar2(100);
 val		char(1);

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MLOAD.ACCEPT_META_DEFINE' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;

 if loc_id = 1
  then
   stnd := 'IPTC Standard';
 elsif loc_id = 2
  then
   stnd := 'XML Format';
 elsif loc_id = 3
  then
   stnd := 'EXIF';
 end if;

 for j in p1.first..p1.last loop
  val := 'F';
  for k in p3.first..p3.last loop
   if trim(p3(k)) = trim(p2(j)) then val := 'T'; exit; end if;
  end loop;
  update novelty_metamap
   set
    attribute_id = p2(j),
    is_mandatory = val
  where
   pid = owner_id and
   type_of_metatag = stnd and
   tagname = p1(j);

  if SQL%NOTFOUND
   then
    val := 'F';
    for k in p3.first..p3.last loop
     if trim(p3(k)) = trim(p2(j)) then val := 'T'; exit; end if;
    end loop;
    insert into novelty_metamap(pid,type_of_metatag,tagname,attribute_id,is_mandatory) values (owner_id,stnd,p1(j),p2(j),val);
  end if;
 end loop;

 commit;

 meta_pref( surl, nvid, loc_id, footer_api, left_api_parm, current_page_number, display_detail, acid, first_parameter, called_from, 'Meta Tag Definitions Updated' );

exception when others then
 glbx.error_details( 'MLOAD', 'ACCEPT_META_DEFINE',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_meta_define;

procedure accept_meta_load(surl in varchar2, nvid in integer, loc_id in integer, footer_api in varchar2, left_api_parm in varchar2, current_page_number in integer, display_detail in char, acid in integer, first_parameter in varchar2, called_from in varchar2, p1 in varchar2 )
as

 ltype		varchar2(100);
 stype		integer;
 owner_id	integer;
 sts		varchar2(100);
 stnd		varchar2(100);
 nmb		integer;

begin
 glbx.cookie_id( surl, stype, ltype, owner_id, sts, progcalled=>'MLOAD.ACCEPT_META_LOAD' );
 if sts is not null
  then
   glbx.redisplay_login_page( sts );
   return;
 end if;
 if loc_id = 1
  then
   stnd := 'IPTC Standard';
 elsif loc_id = 2
  then
   stnd := 'XML Format';
 elsif loc_id = 3
  then
   stnd := 'EXIF';
 end if;

 if p1 in ('T','A')
  then
   meta_load(surl, owner_id, stnd, acid, TRUE, FALSE, nmb );
 elsif p1 = 'G'
  then
   meta_load(surl, owner_id, stnd, acid, FALSE, FALSE, nmb );
 elsif p1 = 't'
  then
   meta_load(surl, owner_id, stnd, acid, TRUE, TRUE, nmb );
 elsif p1 = 'g'
  then
   meta_load(surl, owner_id, stnd, acid, FALSE, TRUE, nmb );
 end if;

 commit;
 htp.nl;
 htp.nl;
 htp.bold( 'Meta Data Attached to Photos' || '(#' || nmb || ')' );
 htp.nl;
 htp.nl;
 htp.bold( '<a href="" onClick="self.close()">' || LNG.GLB_TXT_033 || '</a>');

exception when others then
 glbx.error_details( 'MLOAD', 'ACCEPT_META_LOAD',owner_id,acid,errmsg=>sqlerrm,extdet=>'NVID:' || nvid);
end accept_meta_load;

procedure extractElementAttributes(doc in sys.xmldom.DOMDocument, p1 in out NOCOPY GLBX.MYARRAY, p2 in out NOCOPY GLBX.MYARRAY)
is

nl 		sys.xmldom.DOMNodeList;
len1 		number;
len2 		number;
ctr		integer;
n 		sys.xmldom.DOMNode;
n2 		sys.xmldom.DOMNode;
e 		sys.xmldom.DOMElement;
nnm 		sys.xmldom.DOMNamedNodeMap;
n_child 	sys.xmldom.DOMNode;
attrname 	varchar2(100);
attrval 	varchar2(100);
lasttag		varchar2(1000);
tag		varchar2(1000);

begin

   -- p1 is tag name
   -- p2 is tag value

   -- get all elements
   nl := sys.xmldom.getElementsByTagName(doc, '*');
   len1 := sys.xmldom.getLength(nl);
   ctr := 0;
   lasttag := NULL;

   -- loop through elements
   for j in 0..len1-1 loop
      n := sys.xmldom.item(nl, j);
      e := sys.xmldom.makeElement(n);
      n_child:= sys.xmldom.getFirstChild(n);
      tag := upper(substr(sys.xmldom.getTagName(e),instr(sys.xmldom.getTagName(e),':')+1));
      -- htp.p('[' || sys.xmldom.getTagName(e) || ']' || sys.xmldom.getNodeValue(n_child)); htp.nl;

      if lasttag is null
       then
        ctr := ctr + 1;
        p1(ctr) := tag;
        p2(ctr) := sys.xmldom.getNodeValue(n_child);
        lasttag := tag;
      elsif lasttag <> tag
       then
        ctr := ctr + 1;
        p1(ctr) := tag;
        p2(ctr) := sys.xmldom.getNodeValue(n_child);
        lasttag := tag;
      else
        if sys.xmldom.getNodeValue(n_child) is not null
         then
          if p2(ctr) is null
           then
            p2(ctr) := sys.xmldom.getNodeValue(n_child);
           else
            p2(ctr) := p2(ctr) || ',' || sys.xmldom.getNodeValue(n_child);
          end if;
        end if;
      end if;
      -- Convert repeating elements into a comma delimited list.

      -- get all attributes of element
      /*
      -- Currently not required to extract these details
      nnm := sys.xmldom.getAttributes(n);

      if (sys.xmldom.isNull(nnm) = FALSE) then
        len2 := sys.xmldom.getLength(nnm);

        -- loop through attributes
        for i in 0..len2-1 loop
           n2 := sys.xmldom.item(nnm, i);
           attrname := sys.xmldom.getNodeName(n2);
           attrval := sys.xmldom.getNodeValue(n2);
           htp.p('(' || attrname || '){' || attrval || '}' ); htp.nl;
        end loop;
      end if;
      */
   end loop;

end extractElementAttributes;

procedure xml_ext( bfr in varchar2, p1 in out NOCOPY GLBX.MYARRAY, p2 in out NOCOPY GLBX.MYARRAY )
as

p 	sys.xmlparser.parser;
doc 	sys.xmldom.DOMDocument;

begin

-- new parser
   p := sys.xmlparser.newParser;

-- set some characteristics
   sys.xmlparser.setValidationMode(p, FALSE);

-- parse input file
   sys.xmlparser.parseBuffer(p, bfr );

-- get document
   doc := sys.xmlparser.getDocument(p);

-- Print document element attributes
  extractElementAttributes(doc, p1, p2);

 -- deal with exceptions
exception

when sys.xmldom.INDEX_SIZE_ERR then
   raise_application_error(-20120, 'Index Size error');

when sys.xmldom.DOMSTRING_SIZE_ERR then
   raise_application_error(-20120, 'String Size error');

when sys.xmldom.HIERARCHY_REQUEST_ERR then
   raise_application_error(-20120, 'Hierarchy request error');

when sys.xmldom.WRONG_DOCUMENT_ERR then
   raise_application_error(-20120, 'Wrong doc error');

when sys.xmldom.INVALID_CHARACTER_ERR then
   raise_application_error(-20120, 'Invalid Char error');

when sys.xmldom.NO_DATA_ALLOWED_ERR then
   raise_application_error(-20120, 'Nod data allowed error');

when sys.xmldom.NO_MODIFICATION_ALLOWED_ERR then
   raise_application_error(-20120, 'No mod allowed error');

when sys.xmldom.NOT_FOUND_ERR then
   raise_application_error(-20120, 'Not found error');

when sys.xmldom.NOT_SUPPORTED_ERR then
   raise_application_error(-20120, 'Not supported error');

when sys.xmldom.INUSE_ATTRIBUTE_ERR then
   raise_application_error(-20120, 'In use attr error');

end xml_ext;

function load_xml_browser(surl in varchar2, acid in integer, file in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
 return boolean
as
 cursor c1(file varchar2) is select blob_content from apache_ows_content where name = file;

 c1rec  	c1%ROWTYPE;
 inclob		clob;
 xraw		raw(32767);
 bfr		varchar2(32767);
 c_imgchunk	integer;
 v_imgchunk	integer;
 v_count	integer;

begin
 -- set pointer in apache file
 open c1(file);
 fetch c1 into c1rec;
 close c1;
 if dbms_lob.getlength(c1rec.blob_content) = 0 then htp.bold( 'Empty Blob' ); htp.nl; return( FALSE ); end if;
 dbms_lob.createtemporary(inclob,TRUE);

 --inclob := empty_clob();
 -- Convert Blob to Clob
 c_imgchunk := 32367; --255
 v_imgchunk := 32367; --255
 v_count := 0;
 loop
  begin
      dbms_lob.read(c1rec.blob_content,v_imgchunk,(v_count*c_imgchunk)+1,xraw);
      v_count := v_count + 1;
      bfr := utl_raw.cast_to_varchar2(xraw);
      dbms_lob.writeappend(inclob,length(bfr),bfr);
  exception
   when others then exit;
  end;
 end loop;

 load_xml_meta_data( surl, acid, inclob, p1, p2 );

 -- delete from apache file
 delete from apache_ows_content where name = file;
 commit;
 return( TRUE );
exception
 when others then htp.bold( sqlerrm ); htp.nl; return( FALSE );
end load_xml_browser;

function load_xml_server(surl in varchar2, acid in integer, file_loc in varchar2, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
 return boolean
as
  inclob	clob;
  fils       	BFILE;
  fname		varchar2(1000);
begin
 -- load file from server into clob
 htp.p('Loading:' || file_loc ); htp.nl;
 execute immediate 'create or replace directory ' || GLBX.GLOBAL_DIR || ' as ''' || glbx.extract_fname( file_loc,'PWD') || '''';
 dbms_lob.createtemporary(inclob,TRUE);
 fname := glbx.extract_fname( file_loc,'SUFFIX');
 if fname is null
  then
   fname := glbx.extract_fname( file_loc,'NO_EXTENSION');
  else
   fname := glbx.extract_fname( file_loc,'NO_EXTENSION') || '.' || fname;
 end if;
 fils := BFILENAME(GLBX.GLOBAL_DIR,fname);
 dbms_lob.fileopen(fils, dbms_lob.file_readonly);
 dbms_lob.loadfromfile(inclob, fils, dbms_lob.getlength( fils ) );
 dbms_lob.fileclose(fils);
 load_xml_meta_data( surl, acid, inclob, p1, p2 );
 return( TRUE );
exception
 when others then htp.p( sqlerrm ); return( FALSE );
end load_xml_server;

procedure load_xml_meta_data(surl in varchar2, acid in integer, inclob in clob, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY )
as

 p 	sys.xmlparser.parser;
 doc 	sys.xmldom.DOMDocument;

begin
-- new parser
   p := sys.xmlparser.newParser;

-- set some characteristics
   sys.xmlparser.setValidationMode(p, FALSE);

-- parse input file
   sys.xmlparser.parseClob(p, inclob );

-- get document
   doc := sys.xmlparser.getDocument(p);

-- Print document element attributes
  parsedoc(surl, doc, acid, p1, p2);

 -- deal with exceptions
exception

when sys.xmldom.INDEX_SIZE_ERR then
   raise_application_error(-20120, 'Index Size error');

when sys.xmldom.DOMSTRING_SIZE_ERR then
   raise_application_error(-20120, 'String Size error');

when sys.xmldom.HIERARCHY_REQUEST_ERR then
   raise_application_error(-20120, 'Hierarchy request error');

when sys.xmldom.WRONG_DOCUMENT_ERR then
   raise_application_error(-20120, 'Wrong doc error');

when sys.xmldom.INVALID_CHARACTER_ERR then
   raise_application_error(-20120, 'Invalid Char error');

when sys.xmldom.NO_DATA_ALLOWED_ERR then
   raise_application_error(-20120, 'Nod data allowed error');

when sys.xmldom.NO_MODIFICATION_ALLOWED_ERR then
   raise_application_error(-20120, 'No mod allowed error');

when sys.xmldom.NOT_FOUND_ERR then
   raise_application_error(-20120, 'Not found error');

when sys.xmldom.NOT_SUPPORTED_ERR then
   raise_application_error(-20120, 'Not supported error');

when sys.xmldom.INUSE_ATTRIBUTE_ERR then
   raise_application_error(-20120, 'In use attr error');

 -- define xml file
 -- load into which category?
 -- loop through tags

 -- extract definition tag attributes

 -- load image
 -- update meta data
end load_xml_meta_data;

procedure parsedoc(surl in varchar2, doc in sys.xmldom.DOMDocument, acid in integer, p1 in GLBX.MYARRAY, p2 in GLBX.MYARRAY)
is

nl 		sys.xmldom.DOMNodeList;
len1 		number;
len2 		number;
ctr		integer;
n 		sys.xmldom.DOMNode;
n2 		sys.xmldom.DOMNode;
e 		sys.xmldom.DOMElement;
nnm 		sys.xmldom.DOMNamedNodeMap;
n_child 	sys.xmldom.DOMNode;
attrname 	varchar2(100);
attrval 	varchar2(100);
lasttag		varchar2(1000);
tag		varchar2(1000);
loadrec		load_command;
pfx		theme%ROWTYPE;
res		boolean;

function getval( n_child in sys.xmldom.DOMNode )
 return varchar2
as
begin
  if not sys.xmldom.IsNull(n_child)
   then
    return( sys.xmldom.getNodeValue(n_child) );
   else
    return( NULL );
  end if;
end getval;

begin

   pfx := glbx.get_thm( acid );

   -- get all elements
   nl := sys.xmldom.getElementsByTagName(doc, '*');
   len1 := sys.xmldom.getLength(nl);
   lasttag := NULL;

   -- loop through elements
   for j in 0..len1-1 loop
      n := sys.xmldom.item(nl, j);
      e := sys.xmldom.makeElement(n);
      n_child:= sys.xmldom.getFirstChild(n);
      tag := substr(sys.xmldom.getTagName(e),instr(sys.xmldom.getTagName(e),':')+1);
      tag := upper(replace(tag,REPLACE_CHAR,' '));

      -- htp.p('[' || sys.xmldom.getTagName(e) || ']' || sys.xmldom.getNodeValue(n_child)); htp.nl;

      --htp.p( tag );
      if tag = 'ROW'
       then
        loadrec.onload := NULL;
        loadrec.image_type := NULL;
        loadrec.umo_id := NULL;
        loadrec.umo_scene := NULL;
        loadrec.umo_scene_id := NULL;
        loadrec.name := NULL;
        loadrec.location := NULL;
        loadrec.key_type := NULL;
        loadrec.key_val := NULL;
        loadrec.attribute_id := NULL;
        loadrec.pk_id := NULL;
      end if;

      nnm := sys.xmldom.getAttributes(n);
      if (sys.xmldom.isNull(nnm) = FALSE) then
        len2 := sys.xmldom.getLength(nnm);

        -- loop through attributes
        for i in 0..len2-1 loop
           n2 := sys.xmldom.item(nnm, i);
           attrname := upper(sys.xmldom.getNodeName(n2));
           attrval := getval(n2);
           --htp.p('[' || attrname || '-' || attrval || ']' );
           if tag = 'LOAD_COMMAND'
            then
             if attrname = 'ONLOAD' then loadrec.onload := upper(attrval);
             elsif attrname = 'TYPE' then loadrec.image_type := upper(attrval);
             elsif attrname = 'UMO_ID' then loadrec.umo_id := upper(attrval);
             elsif attrname = 'UMO_SCENE' then loadrec.umo_scene := upper(attrval);
             elsif attrname = 'UMO_SCENE_ID' then loadrec.umo_scene_id := upper(attrval);
             elsif attrname = 'NAME' then loadrec.name := upper(attrval);
             elsif attrname = 'LOCATION' then loadrec.location := upper(attrval);
             elsif attrname = 'KEY_TYPE' then loadrec.key_type := upper(attrval);
             end if;
           end if;
        end loop;
      end if;

      if lasttag is null
       then
        --htp.p( getval(n_child)); htp.nl;
        lasttag := tag;
        if tag = 'LOAD_COMMAND' then loadrec.key_val := getval(n_child); end if;
      elsif lasttag <> tag
       then
        --htp.p( getval(n_child));htp.nl;
        lasttag := tag;
        if tag = 'LOAD_COMMAND' then loadrec.key_val := getval(n_child); end if;
      else
        if getval(n_child) is not null
         then
          --htp.p( getval(n_child));htp.nl;
          if tag = 'LOAD_COMMAND' then loadrec.key_val := getval(n_child); end if;
        end if;
      end if;

      if tag = 'LOAD_COMMAND'
       then
        loadrec.pk_id := findkey( acid, loadrec );
       else
        loadrec.image_type := nvl(loadrec.image_type,'PHOTO');
        loadrec.attribute_id := findattrib(acid,loadrec,tag);

        if loadrec.pk_id is not null and loadrec.attribute_id is not null and tag not in ('ROW','ROWSET','LOAD_COMMAND')
         then
          res := ump.umo_modify_entry( loadrec.pk_id, loadrec.attribute_id, getval(n_child), acid, 1, loadrec.image_type, extract_numbers=>pfx.search_number_enable);
          -- add result to log
          if not res
           then
            htp.p( 'Did not load:' || loadrec.pk_id || '-' || loadrec.attribute_id || '[' || tag || '-' || getval(n_child) || ']' ); htp.nl;
          end if;
        end if;
      end if;
      commit;
   end loop;

end parsedoc;

function findattrib( acid in integer, loadrec in load_command, tag in varchar2 )
 return integer
as

 cursor c1(acid integer, tag varchar2, imgtype varchar2) is
  select attribute_id
  from umo_attributes
  where sub_category = tag and
        umo_type = imgtype and
         ((business_feature is null) or
          (business_feature is not null and business_feature = (select theme_type from customer_account ca where ca.aid = acid))
         );

 c1rec c1%ROWTYPE;

begin
 open c1(acid,tag,loadrec.image_type);
 fetch c1 into c1rec;
 close c1;
 return(c1rec.attribute_id);
end findattrib;

function findkey( acid in integer, loadrec in load_command )
 return integer
as

 cursor c1(v_umo integer, acid integer) is select umo_id from umo where umo_id = v_umo and aid = acid;

 cursor c2(loc varchar2, imgtype varchar2, acid integer) is
  select umo_id from umo where aid = acid and umo_type = imgtype and imgtype = 'PHOTO' and photo_original_loc = loc
  union all
  select umo_id from umo where aid = acid and umo_type = imgtype and imgtype = 'DOCUMENT' and document_original_loc = loc
  union all
  select umo_id from umo where aid = acid and umo_type = imgtype and imgtype = 'AUDIO' and audio_original_loc = loc
  union all
  select umo_id from umo where aid = acid and umo_type = imgtype and imgtype = 'VIDEO' and video_original_loc = loc
  union all
  select umo_id from umo um where aid = acid and umo_type = imgtype and imgtype = 'BLUEPRINT' and um.blueprint_obj.blueprint_original_loc = loc;

 cursor c3(fname integer, acid integer) is select umo_id from umo um where aid = acid and um.extras.photo_name = fname;

 v_umo integer;

begin
 if loadrec.key_type is null and loadrec.umo_id is null then return( NULL ); end if;
 if loadrec.key_type is null
  then
   begin v_umo := loadrec.umo_id; exception when others then v_umo := NULL; end;
   open c1(v_umo, acid);
   fetch c1 into v_umo;
   close c1;
   return(v_umo);
 end if;
 if loadrec.key_val is null then return( NULL ); end if;

 if loadrec.key_type = 'ORIGINAL_LOCATION'
  then
   open c2(loadrec.key_val, nvl(loadrec.image_type,'PHOTO'), acid);
   fetch c2 into v_umo;
   close c2;
   return(v_umo);

 elsif loadrec.key_type = 'NAME'
  then
   if loadrec.key_val is null then return( NULL ); end if;
   open c3(loadrec.key_val, acid);
   fetch c3 into v_umo;
   close c3;
   return(v_umo);
 else
  -- Key Type is the name of the Primary Key Meta Tag
  -- xxx build
   return( NULL );
 end if;

 return( v_umo );

end findkey;

function generate_xml_metatags(surl in varchar2, acid integer, uscid in integer, file_loc in varchar2, to_browser in boolean default FALSE, useloc in boolean default TRUE )
 return boolean
as

 cursor c1(acid integer, uscid integer) is
  select *
  from umo um
  where aid = acid and
        (
         (uscid is not null and umo_scene_id = uscid) or
         (uscid is null)
        )
  order by um.extras.orderby_scene,umo_id;

 cursor c2(v_umo integer) is
  select ut2.value, ut2.attribute_id, ut1.sub_category, ut1.category, ut1.edit_type
  from umo_attribute ut2, umo_attributes ut1
  where ut1.attribute_id = ut2.attribute_id and
        ut2.umo_id = v_umo
  order by ut1.order_by;

  queryCtx 	DBMS_XMLquery.ctxType;
  result 	CLOB;
  fl		utl_file.file_type;
  fname		varchar2(1000);
  qry		varchar2(32767);
  cursor_name	integer;
  dummy 	integer;
  col_count	integer;
  desc_t	dbms_sql.desc_tab;

  function rep(val in varchar2 )
   return varchar2
  as
  begin
   return(replace(replace(replace(replace(val,'&','&#x0026;'),'"','&#x0022;'),'<','&lt;'),'>','&gt;'));
  end rep;

  procedure pl( fl in out utl_file.file_type, vline in varchar2, to_browser in boolean )
  as
  begin
   if to_browser
    then
     htp.p( vline );
    else
     utl_file.put_line(fl, buffer=>vline );
   end if;
  end pl;

begin

  -- set up the query context...!
  fname := glbx.extract_fname( file_loc,'SUFFIX');
  if fname is null
   then
    fname := glbx.extract_fname( file_loc,'NO_EXTENSION');
   else
    fname := glbx.extract_fname( file_loc,'NO_EXTENSION') || '.' || fname;
  end if;

  if to_browser
   then
     htp.prn('Content-type: ' || 'bad/type' || NL_CHAR);
     htp.prn('Content-Disposition: attachment; filename=' || file_loc || NL_CHAR);
     htp.prn('Content-Transfer-Encoding: binary' || NL_CHAR);
     htp.prn(NL_CHAR);
     --owa_util.mime_header( 'text/xml' );
   else
    fl := utl_file.fopen( glbx.extract_fname( file_loc,'PWD'), fname, 'w', max_linesize=>32767 );
  end if;

  pl( fl, '<?xml version = "1.0"?>', to_browser );
  pl( fl, '<ROWSET DATABASE="' || glbx.extract_master_parameter('NODE_NAME') || '">', to_browser);

  for c1rec in c1(acid,uscid) loop
   pl( fl, ' ' || '<ROW num="' || c1%ROWCOUNT || '">', to_browser );
   if useloc
    then
     -- Use the original location as the primary key
     if c1rec.umo_type = 'PHOTO'
      then pl( fl, '  ' || '<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" NAME="' || rep(c1rec.extras.photo_name) || '" KEY_TYPE="ORIGINAL_LOCATION">' || c1rec.photo_original_loc || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'DOCUMENT'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" NAME="' || rep(c1rec.extras.photo_name) || '" KEY_TYPE="ORIGINAL_LOCATION">' || c1rec.document_original_loc || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'AUDIO'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" NAME="' || rep(c1rec.extras.photo_name) || '" KEY_TYPE="ORIGINAL_LOCATION">' || c1rec.audio_original_loc || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'VIDEO'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" NAME="' || rep(c1rec.extras.photo_name) || '" KEY_TYPE="ORIGINAL_LOCATION">' || c1rec.video_original_loc || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'RELATIONAL'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" NAME="' || rep(c1rec.extras.photo_name) || '" KEY_TYPE="ORIGINAL_LOCATION">' || '' || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'BLUEPRINT'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" NAME="' || rep(c1rec.extras.photo_name) || '" KEY_TYPE="ORIGINAL_LOCATION">' || c1rec.blueprint_obj.blueprint_original_loc || '</LOAD_COMMAND>', to_browser);
     end if;
   else
     -- Use the film name as the primary key
     if c1rec.umo_type = 'PHOTO'
      then pl( fl, '  ' || '<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" ORIGINAL_LOCATION="' || c1rec.photo_original_loc || '" KEY_TYPE="NAME">' || rep(c1rec.extras.photo_name) || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'DOCUMENT'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" ORIGINAL_LOCATION="' || c1rec.document_original_loc || '" KEY_TYPE="NAME">' || rep(c1rec.extras.photo_name) || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'AUDIO'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" ORIGINAL_LOCATION="' || c1rec.audio_original_loc || '" KEY_TYPE="NAME">' || rep(c1rec.extras.photo_name) || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'VIDEO'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" ORIGINAL_LOCATION="' || c1rec.video_original_loc || '" KEY_TYPE="NAME">' || rep(c1rec.extras.photo_name) || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'RELATIONAL'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" ORIGINAL_LOCATION="' || '' || '" KEY_TYPE="NAME">' || rep(c1rec.extras.photo_name) || '</LOAD_COMMAND>', to_browser);
     elsif c1rec.umo_type = 'BLUEPRINT'
      then pl( fl, '  ' ||'<LOAD_COMMAND ONLOAD="INSERT_UPDATE" TYPE="' || c1rec.umo_type || '" UMO_ID="' || c1rec.umo_id || '" UMO_SCENE="' || c1rec.extras.title || '" UMO_SCENE_ID="' || c1rec.umo_scene_id || '" ORIGINAL_LOCATION="' || c1rec.blueprint_obj.blueprint_original_loc || '" KEY_TYPE="NAME">' || rep(c1rec.extras.photo_name) || '</LOAD_COMMAND>', to_browser);
     end if;
   end if;
   for c2rec in c2(c1rec.umo_id) loop
     pl( fl, '   ' || '<' || replace(c2rec.sub_category,' ',REPLACE_CHAR) || ' TYPE="' || c2rec.edit_type || '" ID="' || c2rec.attribute_id || '">' || rep(c2rec.value) || '</' || replace(c2rec.sub_category,' ',REPLACE_CHAR) || '>', to_browser);
   end loop;
   pl( fl, ' ' || '</ROW>', to_browser );
  end loop;
  pl( fl, '</ROWSET>', to_browser );

  if to_browser
   then
    null;
   else
    utl_file.fclose(fl);
  end if;

  return( TRUE );

end generate_xml_metatags;

end mload;

/
