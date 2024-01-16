CREATE OR REPLACE TYPE WEBSYS."PROGRAM_TYPE"                                          as OBJECT
(
   program_name        varchar2(100),
   program_description varchar2(1000),
   duration            varchar2(100),
   cost_per_head       number,
   school_year         varchar2(100),
   wars_covered        varchar2(100),
   program_type        varchar2(100),
   url                 varchar2(2000),
   curriculum_link     varchar2(100),
   attribute1          varchar2(100),
   attribute2          varchar2(100),
   attribute3          varchar2(100)
);

/
