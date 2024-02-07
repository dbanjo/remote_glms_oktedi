CREATE OR REPLACE function STRANG.conv_nmb_to_word( nmb in integer )
 return varchar2
as

begin

if nmb = 0
 then
  return( 'Zero' );
elsif nmb = 1
 then
  return( 'One' );
elsif nmb = 2
 then
  return( 'Two' );
elsif nmb = 3
 then
  return( 'Three' );
elsif nmb = 4
 then
  return( 'Four' );
elsif nmb = 5
 then
  return( 'Five' );
elsif nmb = 6
 then
  return( 'Six' );
elsif nmb = 7
 then
  return( 'Seven' );
elsif nmb = 8
 then
  return( 'Eight' );
elsif nmb = 9
 then
  return( 'Nine' );
elsif nmb = 10
 then
  return( 'Ten' );
elsif nmb = 11
 then
  return( 'Eleven' );
elsif nmb = 12
 then
  return( 'Twelve' );
elsif nmb = 13
 then
  return( 'Thirteen' );
elsif nmb = 14
 then
  return( 'Fourteen' );
elsif nmb = 15
 then
  return( 'Fifteen' );
elsif nmb = 16
 then
  return( 'Sixteen' );
elsif nmb = 17
 then
  return( 'Seventeen' );
elsif nmb = 18
 then
  return( 'Eighteen' );
elsif nmb = 19
 then
  return( 'Nineteen' );
elsif nmb = 20
 then
  return( 'Twenty' );
elsif nmb = 30
 then
  return( 'Thirty' );
elsif nmb = 40
 then
  return( 'Forty' );
elsif nmb = 50
 then
  return( 'Fifty' );
elsif nmb = 60
 then
  return( 'Sixty' );
elsif nmb = 70
 then
  return( 'Seventy' );
elsif nmb = 80
 then
  return( 'Eighty' );
elsif nmb = 90
 then
  return( 'Ninety' );
elsif nmb = 100
 then
  return( 'One Hundred' );
end if;

-- Number is Greater than 20, break into digits

if nmb < 99
 then
  return( conv_nmb_to_word( trunc(nmb/10) ) || ' ' || conv_nmb_to_word( mod(nmb,10) ) );
elsif nmb < 999
 then
  return( conv_nmb_to_word( trunc(nmb/100) ) || ' ' || conv_nmb_to_word( mod(nmb,100) ) );
end if;

end conv_nmb_to_word;
/
