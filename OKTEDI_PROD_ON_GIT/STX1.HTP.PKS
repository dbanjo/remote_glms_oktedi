CREATE OR REPLACE package STX1.HTP as
  /* Modifiable package global */
  type htbuf_arr  is table of varchar2(32767) index by binary_integer;
  HTBUF_LEN number := 255; -- ### DOESN'T WORK FOR MULTIBYTE
--
  procedure PRN(CBUF in varchar2 default null);
  procedure PRN(DVAL in date);
  procedure PRN(NVAL in number);
  procedure PRINT(CBUF in varchar2 default null);
  procedure PRINT(DVAL in date);
  procedure PRINT(NVAL in number);
  procedure P(CBUF in varchar2 default null);
  procedure P(DVAL in date);
  procedure P(NVAL in number);
--
  function ESCAPE_ARG(ARG in varchar2) return varchar2;
  function ESCAPE_SC(CTEXT in varchar2) return varchar2;
  function ESCAPE_URL(URL in varchar2) return varchar2;
--
  procedure HTMLOPEN;
  procedure HEADOPEN;
  procedure BODYOPEN(CBACKGROUND in varchar2 default null,
                     CATTRIBUTES in varchar2 default null);
  procedure FRAMESETOPEN(CROWS       in varchar2 default null,
                         CCOLS       in varchar2 default null,
                         CATTRIBUTES in varchar2 default null);
  procedure MAPOPEN(CNAME in varchar2,
                    CATTRIBUTES in varchar2 default null);
  procedure NOFRAMESOPEN;
  procedure CENTEROPEN;
  procedure LISTINGOPEN;
  procedure PREOPEN(CCLEAR      in varchar2 default null,
                    CWIDTH      in varchar2 default null,
                    CATTRIBUTES in varchar2 default null);
  procedure BLOCKQUOTEOPEN(CNOWRAP     in varchar2 default null,
                           CCLEAR      in varchar2 default null,
                           CATTRIBUTES in varchar2 default null);
  procedure DIRLISTOPEN;
  procedure MENULISTOPEN;
  procedure ULISTOPEN(CCLEAR      in varchar2 default null,
                      CWRAP       in varchar2 default null,
                      CDINGBAT    in varchar2 default null,
                      CSRC        in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure OLISTOPEN(CCLEAR      in varchar2 default null,
                      CWRAP       in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure DLISTOPEN(CCLEAR      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure HTMLCLOSE;
  procedure HEADCLOSE;
  procedure BODYCLOSE;
  procedure FRAMESETCLOSE;
  procedure MAPCLOSE;
  procedure NOFRAMESCLOSE;
  procedure CENTERCLOSE;
  procedure LISTINGCLOSE;
  procedure PRECLOSE;
  procedure BLOCKQUOTECLOSE;
  procedure DIRLISTCLOSE;
  procedure MENULISTCLOSE;
  procedure ULISTCLOSE;
  procedure OLISTCLOSE;
  procedure DLISTCLOSE;
--
  procedure TITLE(CTITLE in varchar);
  procedure HR(CCLEAR      in varchar2 default null,
               CSRC        in varchar2 default null,
               CATTRIBUTES in varchar2 default null);
  procedure LINE(CCLEAR      in varchar2 default null,
                 CSRC        in varchar2 default null,
                 CATTRIBUTES in varchar2 default null);
  procedure BR(CCLEAR      in varchar2 default null,
               CATTRIBUTES in varchar2 default null);
  procedure NL(CCLEAR      in varchar2 default null,
               CATTRIBUTES in varchar2 default null);
  procedure IMG2(CSRC        in varchar2,
                 CALIGN      in varchar2 default null,
                 CALT        in varchar2 default null,
                 CISMAP      in varchar2 default null,
                 CUSEMAP     in varchar2 default null,
                 CATTRIBUTES in varchar2 default null);
  procedure IMG(CSRC        in varchar2,
                CALIGN      in varchar2 default null,
                CALT        in varchar2 default null,
                CISMAP      in varchar2 default null,
                CATTRIBUTES in varchar2 default null);
  procedure AREA(CCOORDS     in varchar2,
                 CSHAPE      in varchar2 default null,
                 CHREF       in varchar2 default null,
                 CNOHREF     in varchar2 default null,
                 CTARGET     in varchar2 default null,
                 CATTRIBUTES in varchar2 default null);
  procedure FRAME(CSRC          in varchar2,
                  CNAME         in varchar2 default null,
                  CMARGINWIDTH  in varchar2 default null,
                  CMARGINHEIGHT in varchar2 default null,
                  CSCROLLING    in varchar2 default null,
                  CNORESIZE     in varchar2 default null,
                  CATTRIBUTES   in varchar2 default null);
  procedure HEADER(NSIZE       in integer,
                   CHEADER       in varchar2,
                   CALIGN      in varchar2 default null,
                   CNOWRAP     in varchar2 default null,
                   CCLEAR      in varchar2 default null,
                   CATTRIBUTES in varchar2 default null);
  procedure HTITLE(CTITLE      in varchar2,
                   NSIZE       in integer default 1,
                   CALIGN      in varchar2 default null,
                   CNOWRAP     in varchar2 default null,
                   CCLEAR      in varchar2 default null,
                   CATTRIBUTES in varchar2 default null);
  procedure ANCHOR2(CURL        in varchar2,
                    CTEXT       in varchar2,
                    CNAME       in varchar2 default null,
                    CTARGET     in varchar2 default null,
                    CATTRIBUTES in varchar2 default null);
  procedure ANCHOR(CURL        in varchar2,
                   CTEXT       in varchar2,
                   CNAME       in varchar2 default null,
                   CATTRIBUTES in varchar2 default null);
  procedure MAILTO(CADDRESS    in varchar2,
                   CTEXT       in varchar2,
                   CNAME       in varchar2 default null,
                   CATTRIBUTES in varchar2 default null);
  procedure LISTHEADER(CTEXT       in varchar2,
                       CATTRIBUTES in varchar2 default null);
  procedure LISTITEM(CTEXT   in varchar2 default null,
                     CCLEAR   in varchar2 default null,
                     CDINGBAT in varchar2 default null,
                     CSRC     in varchar2 default null,
                     CATTRIBUTES in varchar2 default null);
  procedure DLISTTERM(CTEXT in varchar2 default null,
                      CCLEAR in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure DLISTDEF(CTEXT in varchar2 default null,
                     CCLEAR in varchar2 default null,
                     CATTRIBUTES in varchar2 default null);
--
  procedure PARA;
  procedure PARAGRAPH(CALIGN      in varchar2 default null,
                      CNOWRAP     in varchar2 default null,
                      CCLEAR      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure DIV(CALIGN      in varchar2 default null,
                CATTRIBUTES in varchar2 default null);
--
  procedure WBR;
  procedure COMMENT(CTEXT in varchar2);
  procedure NOBR(CTEXT in varchar2);
  procedure CENTER(CTEXT in varchar2);
--
  procedure DFN(CTEXT in varchar2,
                CATTRIBUTES in varchar2 default null);
  procedure CITE(CTEXT in varchar2,
                 CATTRIBUTES in varchar2 default null);
  procedure CODE(CTEXT in varchar2,
                 CATTRIBUTES in varchar2 default null);
  procedure EM(CTEXT in varchar2,
               CATTRIBUTES in varchar2 default null);
  procedure EMPHASIS(CTEXT in varchar2,
                     CATTRIBUTES in varchar2 default null);
  procedure KBD(CTEXT in varchar2,
                CATTRIBUTES in varchar2 default null);
  procedure KEYBOARD(CTEXT in varchar2,
                     CATTRIBUTES in varchar2 default null);
  procedure SAMPLE(CTEXT in varchar2,
                   CATTRIBUTES in varchar2 default null);
  procedure VARIABLE(CTEXT in varchar2,
                     CATTRIBUTES in varchar2 default null);
  procedure STRONG(CTEXT in varchar2,
                   CATTRIBUTES in varchar2 default null);
  procedure BIG(CTEXT in varchar2,
                CATTRIBUTES in varchar2 default null);
  procedure SMALL(CTEXT in varchar2,
                  CATTRIBUTES in varchar2 default null);
  procedure BOLD(CTEXT in varchar2,
                 CATTRIBUTES in varchar2 default null);
  procedure ITALIC(CTEXT in varchar2,
                   CATTRIBUTES in varchar2 default null);
  procedure UNDERLINE(CTEXT in varchar2,
                      CATTRIBUTES in varchar2 default null);
  procedure PLAINTEXT(CTEXT in varchar2,
                      CATTRIBUTES in varchar2 default null);
  procedure TELETYPE(CTEXT in varchar2,
                     CATTRIBUTES in varchar2 default null);
  procedure S(CTEXT in varchar2,
              CATTRIBUTES in varchar2 default null);
  procedure STRIKE(CTEXT in varchar2,
                   CATTRIBUTES in varchar2 default null);
  procedure SUB(CTEXT       in varchar2,
                CALIGN      in varchar2 default null,
                CATTRIBUTES in varchar2 default null);
  procedure SUP(CTEXT       in varchar2,
                CALIGN      in varchar2 default null,
                CATTRIBUTES in varchar2 default null);
--
  procedure TABLEOPEN(CBORDER     in varchar2 default null,
                      CALIGN      in varchar2 default null,
                      CNOWRAP     in varchar2 default null,
                      CCLEAR      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure TABLECAPTION(CCAPTION    in varchar2,
                         CALIGN      in varchar2 default null,
                         CATTRIBUTES in varchar2 default null);
  procedure TABLEROWOPEN(CALIGN      in varchar2 default null,
                         CVALIGN     in varchar2 default null,
                         CDP         in varchar2 default null,
                         CNOWRAP     in varchar2 default null,
                         CATTRIBUTES in varchar2 default null);
  procedure TABLEHEADER(CVALUE      in varchar2 default null,
                        CALIGN      in varchar2 default null,
                        CDP         in varchar2 default null,
                        CNOWRAP     in varchar2 default null,
                        CROWSPAN    in varchar2 default null,
                        CCOLSPAN    in varchar2 default null,
                        CATTRIBUTES in varchar2 default null);
  procedure TABLEDATA(CVALUE      in varchar2 default null,
                      CALIGN      in varchar2 default null,
                      CDP         in varchar2 default null,
                      CNOWRAP     in varchar2 default null,
                      CROWSPAN    in varchar2 default null,
                      CCOLSPAN    in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure TABLEROWCLOSE;
  procedure TABLECLOSE;
--
  procedure FORMOPEN(CURL        in varchar2,
                     CMETHOD     in varchar2 default 'POST',
                     CTARGET     in varchar2 default null,
                     CENCTYPE    in varchar2 default null,
                     CATTRIBUTES in varchar2 default null);
  procedure FORMCHECKBOX(CNAME       in varchar2,
                         CVALUE      in varchar2 default 'on',
                         CCHECKED    in varchar2 default null,
                         CATTRIBUTES in varchar2 default null);
  procedure FORMFILE(CNAME       in varchar2,
                     CACCEPT     in varchar2 default null,
                     CATTRIBUTES in varchar2 default null);
  procedure FORMHIDDEN(CNAME       in varchar2,
                       CVALUE      in varchar2 default null,
                       CATTRIBUTES in varchar2 default null);
  procedure FORMIMAGE(CNAME       in varchar2,
                      CSRC        in varchar2,
                      CALIGN      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure FORMPASSWORD(CNAME       in varchar2,
                         CSIZE       in varchar2 default null,
                         CMAXLENGTH  in varchar2 default null,
                         CVALUE      in varchar2 default null,
                         CATTRIBUTES in varchar2 default null);
  procedure FORMRADIO(CNAME       in varchar2,
                      CVALUE      in varchar2,
                      CCHECKED    in varchar2 default null,
                      CATTRIBUTES in varchar2 default null);
  procedure FORMRESET(CVALUE      in varchar2 default 'Reset',
                      CATTRIBUTES in varchar2 default null);
  procedure FORMSUBMIT(CNAME       in varchar2 default null,
                       CVALUE      in varchar2 default 'Submit',
                       CATTRIBUTES in varchar2 default null);
  procedure FORMTEXT(CNAME       in varchar2,
                     CSIZE       in varchar2 default null,
                     CMAXLENGTH  in varchar2 default null,
                     CVALUE      in varchar2 default null,
                     CATTRIBUTES in varchar2 default null);
  procedure FORMSELECTOPEN(CNAME       in varchar2,
                           CPROMPT     in varchar2 default null,
                           NSIZE       in integer  default null,
                           CATTRIBUTES in varchar2 default null);
  procedure FORMSELECTOPTION(CVALUE      in varchar2,
                             CSELECTED   in varchar2 default null,
                             CATTRIBUTES in varchar2 default null);
  procedure FORMSELECTCLOSE;
  procedure FORMTEXTAREA(CNAME       in varchar2,
                         NROWS       in integer,
                         NCOLUMNS    in integer,
                         CALIGN      in varchar2 default null,
                         CATTRIBUTES in varchar2 default null);
  procedure FORMTEXTAREA2(CNAME      in varchar2,
                          NROWS       in integer,
                          NCOLUMNS    in integer,
                          CALIGN      in varchar2 default null,
                          CWRAP       in varchar2 default null,
                          CATTRIBUTES in varchar2 default null);
  procedure FORMTEXTAREAOPEN(CNAME       in varchar2,
                             NROWS       in integer,
                             NCOLUMNS    in integer,
                             CALIGN      in varchar2 default null,
                             CATTRIBUTES in varchar2 default null);
  procedure FORMTEXTAREAOPEN2(CNAME       in varchar2,
                             NROWS       in integer,
                             NCOLUMNS    in integer,
                             CALIGN      in varchar2 default null,
                             CWRAP       in varchar2 default null,
                             CATTRIBUTES in varchar2 default null);
  procedure FORMTEXTAREACLOSE;
  procedure FORMCLOSE;
--
  /* ### FUNCTIONS THAT APPEAR TO BE MISSING IN THE STANDARD PACKAGE ### */
  procedure PARACLOSE;
  procedure DIVCLOSE;
--
  procedure INIT;
--
  procedure GET_PAGE(PAGEBUF out htp.htbuf_arr, NROWS in out integer);
  procedure ADDDEFAULTHTMLHDR( BADDHTMLHDR in boolean );
  function  GET_LINE(NROWS out integer) return varchar2;
end HTP;
/
