CREATE OR REPLACE package WEBSYS.decs
as

 --
 -- Client Specific File
 --
 -- All Contents in this File are relevant for the Client Only
 --
 --

 -- Virtual Directory Details and file locations
    UNIX_OR_NT				constant char(1)	:= '\'; -- Unix is '/' Windows NT is '\'
    OS					constant varchar2(20)	:= 'W2K'; -- Values are SOLARIS, LINUX, W2K and NT

 -- Default Passwords and Images
    PW_RESTART				constant varchar2(100)	:= 'FINGERNOSE22';
    PW_DEFAULT				constant varchar2(100)	:= 'FUZZY62';
    PW_RESET				constant varchar2(100)	:= 'BRADMAN99';
    ADMIN_USERNAME			constant varchar2(100)	:= 'ADMIN';

-- Encrypted Values
    ADMIN_ENCRYPT_KEY			constant varchar2(100)	:= 'BURTONRICHARD';
    GENERAL_ENCRYPT_KEY			constant varchar2(100)	:= 'TVSCENE';
    RANDOM_NUMBER			constant varchar2(100)	:= '36';
    SESSION_RANDOM_NUMBER		constant integer	:= 30896547; -- admin
    GREETING_CARD_ENCRYPT_KEY		constant varchar2(100)	:= 'LUXEMBORG'; -- obfus
    GREETING_CARD_KEYWORD		constant varchar2(100)	:= 'ECARD'; -- gcard and ump

 -- Values dependent on site Installation (Locations)
    IMAGE_LOCATION			constant varchar2(50)	:= '/images/';
    ADVERT_LOCATION			constant varchar2(50)	:= '/adverts/';
    DEFAULT_PHG_THEME			constant varchar2(100)	:= 'GENERIC BLACK'; -- Note: Don't delete, still used in Admin under Photographer Quick Create

end decs;

/


GRANT EXECUTE ON WEBSYS.DECS TO STX1;
