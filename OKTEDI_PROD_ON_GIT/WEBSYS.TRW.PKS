CREATE OR REPLACE package WEBSYS.trw
as
 procedure start_trawl( crec in web_trawl_driver%ROWTYPE );
 procedure test;
end trw;

/
