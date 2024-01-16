CREATE OR REPLACE package body STX1.HTP as
--
  AMP  constant varchar2(30) := '&'||'amp;';
  QUOT constant varchar2(30) := '&'||'quot;';
  LT   constant varchar2(30) := '&'||'lt;';
  GT   constant varchar2(30) := '&'||'gt;';
--
  procedure PRN(CBUF in varchar2 default null) is
  begin
    OWA.PRN(CBUF);
  end PRN;
  procedure PRN(DVAL in date) is
  begin
    OWA.PRN(to_char(DVAL));
  end PRN;
--
  procedure PRN(NVAL in number) is
  begin
    OWA.PRN(to_char(NVAL));
  end PRN;
--
  procedure PRINT(CBUF in varchar2 default null) is
  begin
    OWA.PRINT(CBUF);
  end PRINT;
--
  procedure PRINT(DVAL in date) is
  begin
    OWA.PRINT(to_char(DVAL));
  end PRINT;
--
  procedure PRINT(NVAL in number) is
  begin
    OWA.PRINT(to_char(NVAL));
  end PRINT;
--
  procedure P(CBUF in varchar2 default null) is
  begin
    OWA.PRINT(CBUF);
  end P;
--
  procedure P(DVAL in date) is
  begin
    OWA.PRINT(to_char(DVAL));
  end P;
--
  procedure P(NVAL in number) is
  begin
    OWA.PRINT(to_char(NVAL));
  end P;
--
  procedure PRINT_TAGGED_TEXT(TAG in varchar2, CTEXT in varchar2,
                              ATTRS in varchar2, N in number,
                              NAMES in OWA.VCTAB, VALS in OWA.VCTAB,
                              CLOSE_FLAG in boolean default true) is
    BUF    varchar2(32767);
  begin
    BUF := '<'||TAG;
    for I in 1..N loop
      if (VALS(I) is not null) then
        if (NAMES(I) is null) then
          BUF := BUF||' '||VALS(I);
        elsif (VALS(I) = chr(0)) then
          BUF := BUF||' '||NAMES(I)||'=""';
        else
          BUF := BUF||' '||NAMES(I)||'="'||VALS(I)||'"';
        end if;
      end if;
    end loop;
    if (ATTRS is not null) then
      BUF := BUF||' '||ATTRS;
    end if;
    if (CLOSE_FLAG) then
      OWA.PRINT(BUF||'>'||CTEXT||'</'||TAG||'>');
    else
      OWA.PRINT(BUF||'>');
    end if;
  end PRINT_TAGGED_TEXT;
--
  procedure PRINT_TAGGED_TEXT(TAG in varchar2,
                              CTEXT in varchar2, ATTRS in varchar2) is
  begin
    if (ATTRS is not null) then
      OWA.PRINT('<'||TAG||' '||ATTRS||'>'||CTEXT||'</'||TAG||'>');
    else
      OWA.PRINT('<'||TAG||'>'||CTEXT||'</'||TAG||'>');
    end if;
  end PRINT_TAGGED_TEXT;
--
  procedure PRINT_TAGGED_TEXT(TAG in varchar2,
                              CTEXT in varchar2, ATTRS in varchar2,
                              NAME in varchar2, VAL in varchar2) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    if ((NAME is null) and (VAL is null)) then
      PRINT_TAGGED_TEXT(TAG, CTEXT, ATTRS);
    else
      NAMES(1) := NAME;
      VALS(1) := VAL;
      PRINT_TAGGED_TEXT(TAG, CTEXT, ATTRS, 1, NAMES, VALS);
    end if;
  end PRINT_TAGGED_TEXT;
--
  procedure PRINT_TAG(TAG in varchar2, ATTRS in varchar2, N in number,
                      NAMES in OWA.VCTAB, VALS in OWA.VCTAB) is
  begin
    PRINT_TAGGED_TEXT(TAG, null, ATTRS, N, NAMES, VALS, false);
  end PRINT_TAG;
--
  procedure HTMLOPEN is
  begin
    OWA.PRINT('<html>');
  end HTMLOPEN;
--
  procedure HEADOPEN is
  begin
    OWA.PRINT('<head>');
  end HEADOPEN;
--
  procedure BODYOPEN(CBACKGROUND in varchar2 default null,
                     CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'background';
    VALS(1) := CBACKGROUND;
    PRINT_TAG('body', CATTRIBUTES, 1, NAMES, VALS);
  end BODYOPEN;
--
  procedure FRAMESETOPEN(CROWS       in varchar2 default null,
                         CCOLS       in varchar2 default null,
                         CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'rows';
    VALS(1) := CROWS;
    NAMES(2) := 'cols';
    VALS(2) := CCOLS;
    PRINT_TAG('frameset', CATTRIBUTES, 2, NAMES, VALS);
  end FRAMESETOPEN;
--
  procedure MAPOPEN(CNAME       in varchar2,
                    CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'name';
    VALS(1) := CNAME;
    PRINT_TAG('map', CATTRIBUTES, 1, NAMES, VALS);
  end MAPOPEN;
--
  procedure NOFRAMESOPEN is
  begin
    OWA.PRINT('<noframes>');
  end NOFRAMESOPEN;
--
  procedure CENTEROPEN is
  begin
    OWA.PRINT('<center>');
  end CENTEROPEN;
--
  procedure LISTINGOPEN is
  begin
    OWA.PRINT('<listing>');
  end LISTINGOPEN;
--
  procedure PREOPEN(CCLEAR      in varchar2 default null,
                    CWIDTH      in varchar2 default null,
                    CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'clear';
    VALS(1) := CCLEAR;
    NAMES(2) := 'width';
    VALS(2) := CWIDTH;
    PRINT_TAG('pre', CATTRIBUTES, 2, NAMES, VALS);
  end PREOPEN;
--
  procedure BLOCKQUOTEOPEN(CNOWRAP     in varchar2 default null,
                           CCLEAR      in varchar2 default null,
                           CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'clear';
    VALS(1) := CCLEAR;
    if (CNOWRAP is null) then
      PRINT_TAG('blockquote', CATTRIBUTES, 1, NAMES, VALS);
    else
      NAMES(2) := '';
      VALS(2) := 'nowrap';
      PRINT_TAG('blockquote', CATTRIBUTES, 2, NAMES, VALS);
    end if;
  end BLOCKQUOTEOPEN;
--
  procedure DIRLISTOPEN is
  begin
    OWA.PRINT('<dir>');
  end DIRLISTOPEN;
--
  procedure MENULISTOPEN is
  begin
    OWA.PRINT('<menu>');
  end MENULISTOPEN;
--
  procedure ULISTOPEN(CCLEAR      in varchar2 default null,
                      CWRAP       in varchar2 default null,
                      CDINGBAT    in varchar2 default null,
                      CSRC        in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'clear';
    VALS(1) := CCLEAR;
    NAMES(2) := 'wrap';
    VALS(2) := CWRAP;
    NAMES(3) := 'dingbat';
    VALS(3) := CDINGBAT;
    NAMES(4) := 'src';
    VALS(4) := CSRC;
    PRINT_TAG('ul', CATTRIBUTES, 4, NAMES, VALS);
  end ULISTOPEN;
  procedure OLISTOPEN(CCLEAR      in varchar2 default null,
                      CWRAP       in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'clear';
    VALS(1) := CCLEAR;
    NAMES(2) := 'wrap';
    VALS(2) := CWRAP;
    PRINT_TAG('ol', CATTRIBUTES, 2, NAMES, VALS);
  end OLISTOPEN;
  procedure DLISTOPEN(CCLEAR      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'clear';
    VALS(1) := CCLEAR;
    PRINT_TAG('dl', CATTRIBUTES, 1, NAMES, VALS);
  end DLISTOPEN;
--
  procedure HTMLCLOSE is
  begin
    OWA.PRINT('</html>');
  end HTMLCLOSE;
--
  procedure HEADCLOSE is
  begin
    OWA.PRINT('</head>');
  end HEADCLOSE;
--
  procedure BODYCLOSE is
  begin
    OWA.PRINT('</body>');
  end BODYCLOSE;
--
  procedure FRAMESETCLOSE is
  begin
    OWA.PRINT('</frameset>');
  end FRAMESETCLOSE;
--
  procedure MAPCLOSE is
  begin
    OWA.PRINT('</map>');
  end MAPCLOSE;
--
  procedure NOFRAMESCLOSE is
  begin
    OWA.PRINT('</noframes>');
  end NOFRAMESCLOSE;
--
  procedure CENTERCLOSE is
  begin
    OWA.PRINT('</center>');
  end CENTERCLOSE;
--
  procedure LISTINGCLOSE is
  begin
    OWA.PRINT('</listing>');
  end LISTINGCLOSE;
--
  procedure PRECLOSE is
  begin
    OWA.PRINT('</pre>');
  end PRECLOSE;
--
  procedure BLOCKQUOTECLOSE is
  begin
    OWA.PRINT('</blockquote>');
  end BLOCKQUOTECLOSE;
--
  procedure DIRLISTCLOSE is
  begin
    OWA.PRINT('</dir>');
  end DIRLISTCLOSE;
--
  procedure MENULISTCLOSE is
  begin
    OWA.PRINT('</menu>');
  end MENULISTCLOSE;
--
  procedure ULISTCLOSE is
  begin
    OWA.PRINT('</ul>');
  end ULISTCLOSE;
--
  procedure OLISTCLOSE is
  begin
    OWA.PRINT('</ol>');
  end OLISTCLOSE;
--
  procedure DLISTCLOSE is
  begin
    OWA.PRINT('</ul>');
  end DLISTCLOSE;
--
  procedure TITLE(CTITLE in varchar) is
  begin
    OWA.PRINT('<title>'||CTITLE||'</title>');
  end TITLE;
--
  procedure HR(CCLEAR      in varchar2 default null,
               CSRC        in varchar2 default null,
               CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'clear';
    VALS(1) := CCLEAR;
    NAMES(2) := 'src';
    VALS(2) := CSRC;
    PRINT_TAG('hr', CATTRIBUTES, 2, NAMES, VALS);
  end HR;
--
  procedure LINE(CCLEAR      in varchar2 default null,
                 CSRC        in varchar2 default null,
                 CATTRIBUTES in varchar2 default null) is
  begin
    HR(CCLEAR, CSRC, CATTRIBUTES);
  end LINE;
--
  procedure BR(CCLEAR      in varchar2 default null,
               CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'clear';
    VALS(1) := CCLEAR;
    PRINT_TAG('br', CATTRIBUTES, 1, NAMES, VALS);
  end BR;
--
  procedure NL(CCLEAR      in varchar2 default null,
               CATTRIBUTES in varchar2 default null) is
  begin
    BR(CCLEAR, CATTRIBUTES);
  end NL;
--
  procedure IMG2(CSRC        in varchar2,
                 CALIGN      in varchar2 default null,
                 CALT        in varchar2 default null,
                 CISMAP      in varchar2 default null,
                 CUSEMAP     in varchar2 default null,
                 CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'src';
    if (CSRC is null) then
      VALS(1) := chr(0); -- force the SRC= attribute to print
    else
      VALS(1) := CSRC;
    end if;
    NAMES(2) := 'align';
    VALS(2) := CALIGN;
    NAMES(3) := 'usemap';
    VALS(3) := CUSEMAP;
    if (CISMAP is null) then
      PRINT_TAG('img', CATTRIBUTES, 3, NAMES, VALS);
    else
      NAMES(4) := '';
      VALS(4) := 'ismap';
      PRINT_TAG('img', CATTRIBUTES, 4, NAMES, VALS);
    end if;
  end IMG2;
--
  procedure IMG(CSRC        in varchar2,
                CALIGN      in varchar2 default null,
                CALT        in varchar2 default null,
                CISMAP      in varchar2 default null,
                CATTRIBUTES in varchar2 default null) is
  begin
    IMG2(CSRC, CALIGN, CALT, CISMAP, null, CATTRIBUTES);
  end IMG;
--
  procedure AREA(CCOORDS     in varchar2,
                 CSHAPE      in varchar2 default null,
                 CHREF       in varchar2 default null,
                 CNOHREF     in varchar2 default null,
                 CTARGET     in varchar2 default null,
                 CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'coords';
    if (CCOORDS is null) then
      VALS(1) := chr(0); -- force the COORDS= attribute to print
    else
      VALS(1) := CCOORDS;
    end if;
    NAMES(2) := 'shape';
    VALS(2) := CSHAPE;
    NAMES(3) := 'href';
    VALS(3) := CHREF;
    NAMES(4) := 'target';
    VALS(4) := CTARGET;
    if (CNOHREF is null) then
      PRINT_TAG('area', CATTRIBUTES, 4, NAMES, VALS);
    else
      NAMES(5) := '';
      VALS(5) := 'nohref';
      PRINT_TAG('area', CATTRIBUTES, 5, NAMES, VALS);
    end if;
  end AREA;
--
  procedure FRAME(CSRC          in varchar2,
                  CNAME         in varchar2 default null,
                  CMARGINWIDTH  in varchar2 default null,
                  CMARGINHEIGHT in varchar2 default null,
                  CSCROLLING    in varchar2 default null,
                  CNORESIZE     in varchar2 default null,
                  CATTRIBUTES   in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'src';
    VALS(1) := CSRC;
    NAMES(2) := 'name';
    VALS(2) := CNAME;
    NAMES(3) := 'marginwidth';
    VALS(3) := CMARGINWIDTH;
    NAMES(4) := 'marginheight';
    VALS(4) := CMARGINHEIGHT;
    NAMES(5) := 'scrolling';
    VALS(5) := CSCROLLING;
    if (CNORESIZE is null) then
      PRINT_TAG('frame', CATTRIBUTES, 5, NAMES, VALS);
    else
      NAMES(6) := '';
      VALS(6) := 'noresize';
      PRINT_TAG('frame', CATTRIBUTES, 6, NAMES, VALS);
    end if;
  end FRAME;
--
  procedure HEADER(NSIZE       in integer,
                   CHEADER       in varchar2,
                   CALIGN      in varchar2 default null,
                   CNOWRAP     in varchar2 default null,
                   CCLEAR      in varchar2 default null,
                   CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'align';
    VALS(1) := CALIGN;
    NAMES(2) := 'clear';
    VALS(2) := CCLEAR;
    if (CNOWRAP is null) then
      PRINT_TAGGED_TEXT('h'||to_char(NSIZE), CHEADER, CATTRIBUTES, 2,NAMES,VALS);
    else
      NAMES(3) := '';
      VALS(3) := 'nowrap';
      PRINT_TAGGED_TEXT('h'||to_char(NSIZE), CHEADER, CATTRIBUTES, 3,NAMES,VALS);
    end if;
  end HEADER;
--
  procedure HTITLE(CTITLE      in varchar2,
                   NSIZE       in integer default 1,
                   CALIGN      in varchar2 default null,
                   CNOWRAP     in varchar2 default null,
                   CCLEAR      in varchar2 default null,
                   CATTRIBUTES in varchar2 default null) is
  begin
    TITLE(CTITLE);
    HEADER(NSIZE, CTITLE, CALIGN, CNOWRAP, CCLEAR, CATTRIBUTES);
  end HTITLE;
--
  procedure ANCHOR2(CURL        in varchar2,
                    CTEXT       in varchar2,
                    CNAME       in varchar2 default null,
                    CTARGET     in varchar2 default null,
                    CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    if (CURL is null) then
      NAMES(1) := 'name';
      if (CNAME is null) then
        VALS(1) := chr(0); -- force the NAME= attribute to print
      else
        VALS(1) := CNAME;
      end if;
      PRINT_TAGGED_TEXT('a', CTEXT, CATTRIBUTES, 1, NAMES, VALS);
    else
      NAMES(1) := 'href';
      VALS(1) := CURL;
      NAMES(2) := 'name';
      VALS(2) := CNAME;
      NAMES(3) := 'target';
      VALS(3) := CTARGET;
      PRINT_TAGGED_TEXT('a', CTEXT, CATTRIBUTES, 3, NAMES, VALS);
    end if;
  end ANCHOR2;
--
  procedure ANCHOR(CURL        in varchar2,
                   CTEXT       in varchar2,
                   CNAME       in varchar2 default null,
                   CATTRIBUTES in varchar2 default null) is
  begin
    ANCHOR2(CURL, CTEXT, CNAME, null, CATTRIBUTES);
  end ANCHOR;
--
procedure MAILTO(CADDRESS    in varchar2,
                   CTEXT       in varchar2,
                   CNAME       in varchar2 default null,
                   CATTRIBUTES in varchar2 default null) is
  begin
    ANCHOR2('mailto:' || CADDRESS, CTEXT, CNAME, null, CATTRIBUTES);
  end MAILTO;
--
  procedure LISTHEADER(CTEXT       in varchar2,
                       CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('lh', CTEXT, CATTRIBUTES);
  end LISTHEADER;
--
  procedure LISTITEM(CTEXT       in varchar2 default null,
                     CCLEAR      in varchar2 default null,
                     CDINGBAT    in varchar2 default null,
                     CSRC        in varchar2 default null,
                     CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'clear';
    VALS(1) := CCLEAR;
    NAMES(2) := 'dingbat';
    VALS(2) := CDINGBAT;
    NAMES(3) := 'src';
    VALS(3) := CSRC;
    if (CTEXT is null) then
      PRINT_TAG('li', CATTRIBUTES, 3, NAMES, VALS);
    else
      PRINT_TAGGED_TEXT('li', CTEXT, CATTRIBUTES, 3, NAMES, VALS);
    end if;
  end LISTITEM;
--
  procedure DLISTTERM(CTEXT       in varchar2 default null,
                      CCLEAR      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('dt', CTEXT, CATTRIBUTES, 'clear', CCLEAR);
  end DLISTTERM;
--
  procedure DLISTDEF(CTEXT       in varchar2 default null,
                     CCLEAR      in varchar2 default null,
                     CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('dd', CTEXT, CATTRIBUTES, 'clear', CCLEAR);
  end DLISTDEF;
--
  procedure PARA is
  begin
    OWA.PRINT('<p>');
  end PARA;
--
  procedure PARAGRAPH(CALIGN      in varchar2 default null,
                      CNOWRAP     in varchar2 default null,
                      CCLEAR      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'align';
    VALS(1) := CALIGN;
    NAMES(2) := 'clear';
    VALS(2) := CCLEAR;
    if (CNOWRAP is null) then
      PRINT_TAG('p', CATTRIBUTES, 2, NAMES, VALS);
    else
      NAMES(3) := '';
      VALS(3) := 'nowrap';
      PRINT_TAG('p', CATTRIBUTES, 3, NAMES, VALS);
    end if;
  end PARAGRAPH;
--
  procedure DIV(CALIGN      in varchar2 default null,
                CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'align';
    VALS(1) := CALIGN;
    PRINT_TAG('div', CATTRIBUTES, 1, NAMES, VALS);
  end DIV;
--
  procedure WBR is
  begin
    OWA.PRINT('<wbr>');
  end WBR;
--
  procedure COMMENT(CTEXT in varchar2) is
  begin
    OWA.PRINT('<!-- '||CTEXT||' -->');
  end COMMENT;
--
  procedure NOBR(CTEXT in varchar2) is
  begin
    OWA.PRINT('<nobr>'||CTEXT||'</nobr>');
  end NOBR;
--
  procedure CENTER(CTEXT in varchar2) is
  begin
    OWA.PRINT('<center>'||CTEXT||'</center>');
  end CENTER;
--
  procedure DFN(CTEXT       in varchar2,
                CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('dfn', CTEXT, CATTRIBUTES);
  end DFN;
--
  procedure CITE(CTEXT       in varchar2,
                 CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('cite', CTEXT, CATTRIBUTES);
  end CITE;
--
  procedure CODE(CTEXT       in varchar2,
                 CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('code', CTEXT, CATTRIBUTES);
  end CODE;
--
  procedure EM(CTEXT       in varchar2,
               CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('em', CTEXT, CATTRIBUTES);
  end EM;
--
  procedure EMPHASIS(CTEXT       in varchar2,
                     CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('em', CTEXT, CATTRIBUTES);
  end EMPHASIS;
--
  procedure KBD(CTEXT       in varchar2,
                CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('kbd', CTEXT, CATTRIBUTES);
  end KBD;
--
  procedure KEYBOARD(CTEXT       in varchar2,
                     CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('kbd', CTEXT, CATTRIBUTES);
  end KEYBOARD;
--
  procedure SAMPLE(CTEXT       in varchar2,
                   CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('samp', CTEXT, CATTRIBUTES);
  end SAMPLE;
--
  procedure VARIABLE(CTEXT       in varchar2,
                     CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('var', CTEXT, CATTRIBUTES);
  end VARIABLE;
--
  procedure STRONG(CTEXT       in varchar2,
                   CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('strong', CTEXT, CATTRIBUTES);
  end STRONG;
--
  procedure BIG(CTEXT       in varchar2,
                CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('big', CTEXT, CATTRIBUTES);
  end BIG;
--
  procedure SMALL(CTEXT       in varchar2,
                  CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('small', CTEXT, CATTRIBUTES);
  end SMALL;
--
  procedure BOLD(CTEXT       in varchar2,
                 CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('b', CTEXT, CATTRIBUTES);
  end;
--
  procedure ITALIC(CTEXT       in varchar2,
                   CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('i', CTEXT, CATTRIBUTES);
  end;
--
  procedure UNDERLINE(CTEXT       in varchar2,
                      CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('u', CTEXT, CATTRIBUTES);
  end;
--
  procedure PLAINTEXT(CTEXT       in varchar2,
                      CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('plaintext', CTEXT, CATTRIBUTES);
  end PLAINTEXT;
--
  procedure TELETYPE(CTEXT       in varchar2,
                     CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('tt', CTEXT, CATTRIBUTES);
  end TELETYPE;
--
  procedure S(CTEXT       in varchar2,
              CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('s', CTEXT, CATTRIBUTES);
  end S;
--
  procedure STRIKE(CTEXT       in varchar2,
                   CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('strike', CTEXT, CATTRIBUTES);
  end STRIKE;
--
  procedure SUB(CTEXT       in varchar2,
                CALIGN      in varchar2 default null,
                CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('sub', CTEXT, CATTRIBUTES, 'align', CALIGN);
  end SUB;
--
  procedure SUP(CTEXT       in varchar2,
                CALIGN      in varchar2 default null,
                CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('sup', CTEXT, CATTRIBUTES, 'align', CALIGN);
  end SUP;
--
  procedure TABLEOPEN(CBORDER     in varchar2 default null,
                      CALIGN      in varchar2 default null,
                      CNOWRAP     in varchar2 default null,
                      CCLEAR      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := '';
    VALS(1) := CBORDER;
    NAMES(2) := 'align';
    VALS(2) := CALIGN;
    NAMES(3) := 'clear';
    VALS(3) := CCLEAR;
    if (CNOWRAP is null) then
      PRINT_TAG('table', CATTRIBUTES, 3, NAMES, VALS);
    else
      NAMES(4) := '';
      VALS(4) := 'nowrap';
      PRINT_TAG('table', CATTRIBUTES, 4, NAMES, VALS);
    end if;
  end TABLEOPEN;
--
  procedure TABLECAPTION(CCAPTION    in varchar2,
                         CALIGN      in varchar2 default null,
                         CATTRIBUTES in varchar2 default null) is
  begin
    PRINT_TAGGED_TEXT('caption', CCAPTION, CATTRIBUTES, 'align', CALIGN);
  end TABLECAPTION;
--
  procedure TABLEROWOPEN(CALIGN      in varchar2 default null,
                         CVALIGN     in varchar2 default null,
                         CDP         in varchar2 default null,
                         CNOWRAP     in varchar2 default null,
                         CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'align';
    VALS(1) := CALIGN;
    NAMES(2) := 'valign';
    VALS(2) := CVALIGN;
    NAMES(3) := 'dp';
    VALS(3) := CDP;
    if (CNOWRAP is null) then
      PRINT_TAG('tr', CATTRIBUTES, 3, NAMES, VALS);
    else
      NAMES(4) := '';
      VALS(4) := 'nowrap';
      PRINT_TAG('tr', CATTRIBUTES, 4, NAMES, VALS);
    end if;
  end TABLEROWOPEN;
--
  procedure TABLEHEADER(CVALUE      in varchar2 default null,
                        CALIGN      in varchar2 default null,
                        CDP         in varchar2 default null,
                        CNOWRAP     in varchar2 default null,
                        CROWSPAN    in varchar2 default null,
                        CCOLSPAN    in varchar2 default null,
                        CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'align';
    VALS(1) := CALIGN;
    NAMES(2) := 'dp';
    VALS(2) := CDP;
    NAMES(3) := 'rowspan';
    VALS(3) := CROWSPAN;
    NAMES(4) := 'colspan';
    VALS(4) := CCOLSPAN;
    if (CNOWRAP is null) then
      PRINT_TAGGED_TEXT('th', CVALUE, CATTRIBUTES, 4, NAMES, VALS);
    else
      NAMES(5) := '';
      VALS(5) := 'nowrap';
      PRINT_TAGGED_TEXT('th', CVALUE, CATTRIBUTES, 5, NAMES, VALS);
    end if;
  end TABLEHEADER;
--
  procedure TABLEDATA(CVALUE      in varchar2 default null,
                      CALIGN      in varchar2 default null,
                      CDP         in varchar2 default null,
                      CNOWRAP     in varchar2 default null,
                      CROWSPAN    in varchar2 default null,
                      CCOLSPAN    in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'align';
    VALS(1) := CALIGN;
    NAMES(2) := 'dp';
    VALS(2) := CDP;
    NAMES(3) := 'rowspan';
    VALS(3) := CROWSPAN;
    NAMES(4) := 'colspan';
    VALS(4) := CCOLSPAN;
    if (CNOWRAP is null) then
      PRINT_TAGGED_TEXT('td', CVALUE, CATTRIBUTES, 4, NAMES, VALS);
    else
      NAMES(5) := '';
      VALS(5) := 'nowrap';
      PRINT_TAGGED_TEXT('td', CVALUE, CATTRIBUTES, 5, NAMES, VALS);
    end if;
  end TABLEDATA;
--
  procedure TABLEROWCLOSE is
  begin
    OWA.PRINT('</tr>');
  end TABLEROWCLOSE;
--
  procedure TABLECLOSE is
  begin
    OWA.PRINT('</table>');
  end TABLECLOSE;
--
  procedure PARACLOSE is
  begin
    OWA.PRINT('</p>');
  end PARACLOSE;
--
  procedure DIVCLOSE is
  begin
    OWA.PRINT('</div>');
  end DIVCLOSE;
--
  procedure FORMOPEN(CURL        in varchar2,
                     CMETHOD     in varchar2 default 'POST',
                     CTARGET     in varchar2 default null,
                     CENCTYPE    in varchar2 default null,
                     CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'action';
    if (CURL is null) then
      VALS(1) := chr(0); -- force the ACTION= attribute to print
    else
      VALS(1) := CURL;
    end if;
    NAMES(2) := 'method';
    VALS(2) := CMETHOD;
    NAMES(3) := 'target';
    VALS(3) := CTARGET;
    NAMES(4) := 'enctype';
    VALS(4) := CENCTYPE;
    PRINT_TAG('form', CATTRIBUTES, 4, NAMES, VALS);
  end FORMOPEN;
--
  procedure FORMCHECKBOX(CNAME       in varchar2,
                         CVALUE      in varchar2 default 'on',
                         CCHECKED    in varchar2 default null,
                         CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
    TAG   varchar2(100);
  begin
    NAMES(1) := 'name';
    if (CNAME is null) then
      VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      VALS(1) := CNAME;
    end if;
    NAMES(2) := 'value';
    VALS(2) := CVALUE;
    if (CCHECKED is null) then
      TAG := 'input type="checkbox"';
    else
      TAG := 'input type="checkbox" checked';
    end if;
    PRINT_TAG(TAG, CATTRIBUTES, 2, NAMES, VALS);
  end FORMCHECKBOX;
--
  procedure FORMFILE(CNAME       in varchar2,
                     CACCEPT     in varchar2 default null,
                     CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'name';
    VALS(1) := CNAME;
    NAMES(2) := 'accept';
    VALS(2) := CACCEPT;
    PRINT_TAG('input type="file"', CATTRIBUTES, 2, NAMES, VALS);
  end FORMFILE;
--
  procedure FORMHIDDEN(CNAME       in varchar2,
                       CVALUE      in varchar2 default null,
                       CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'name';
    if (CNAME is null) then
      VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      VALS(1) := CNAME;
    end if;
    NAMES(2) := 'value';
    if (CVALUE is null) then
      VALS(2) := chr(0); -- force the VALUE= attribute to print
    else
      VALS(2) := CVALUE;
    end if;
    PRINT_TAG('input type="hidden"', CATTRIBUTES, 2, NAMES, VALS);
  end FORMHIDDEN;
--
  procedure FORMIMAGE(CNAME       in varchar2,
                      CSRC        in varchar2,
                      CALIGN      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'name';
    if (CNAME is null) then
      VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      VALS(1) := CNAME;
    end if;
    NAMES(2) := 'src';
    if (CSRC is null) then
      VALS(2) := chr(0); -- force the SRC= attribute to print
    else
      VALS(2) := CSRC;
    end if;
    NAMES(3) := 'align';
    VALS(3) := CALIGN;
    PRINT_TAG('input type="image"', CATTRIBUTES, 3, NAMES, VALS);
  end FORMIMAGE;
--
  procedure FORMPASSWORD(CNAME       in varchar2,
                         CSIZE       in varchar2 default null,
                         CMAXLENGTH  in varchar2 default null,
                         CVALUE      in varchar2 default null,
                         CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'name';
    if (CNAME is null) then
      VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      VALS(1) := CNAME;
    end if;
    NAMES(2) := 'size';
    VALS(2) := CSIZE;
    NAMES(3) := 'maxlength';
    VALS(3) := CMAXLENGTH;
    NAMES(4) := 'value';
    VALS(4) := CVALUE;
    PRINT_TAG('input type="password"', CATTRIBUTES, 4, NAMES, VALS);
  end FORMPASSWORD;
--
  procedure FORMRADIO(CNAME       in varchar2,
                      CVALUE      in varchar2,
                      CCHECKED    in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
    TAG   varchar2(100);
  begin
    NAMES(1) := 'name';
    if (CNAME is null) then
      VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      VALS(1) := CNAME;
    end if;
    NAMES(2) := 'value';
    if (CVALUE is null) then
      VALS(2) := chr(0); -- force the VALUE= attribute to print
    else
      VALS(2) := CVALUE;
    end if;
    if (CCHECKED is null) then
      TAG := 'input type="radio"';
    else
      TAG := 'input type="radio" checked';
    end if;
    PRINT_TAG(TAG, CATTRIBUTES, 2, NAMES, VALS);
  end FORMRADIO;
--
  procedure FORMRESET(CVALUE      in varchar2 default 'Reset',
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'value';
    VALS(1) := CVALUE;
    PRINT_TAG('input type="reset"', CATTRIBUTES, 1, NAMES, VALS);
  end FORMRESET;
--
  procedure FORMSUBMIT(CNAME       in varchar2 default null,
                       CVALUE      in varchar2 default 'Submit',
                       CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
    ctr   integer;
  begin
   ctr := 1;
    if (CNAME is null) then
      null; -- VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      NAMES(ctr) := 'name';
      VALS(ctr) := CNAME;
      ctr := ctr + 1;
    end if;
    NAMES(ctr) := 'value';
    if (CVALUE is null) then
      VALS(ctr) := chr(0); -- force the VALUE= attribute to print
    else
      VALS(ctr) := CVALUE;
    end if;
    PRINT_TAG('input type="submit"', CATTRIBUTES, ctr, NAMES, VALS);
  end FORMSUBMIT;
--
  procedure FORMTEXT(CNAME       in varchar2,
                     CSIZE       in varchar2 default null,
                     CMAXLENGTH  in varchar2 default null,
                     CVALUE      in varchar2 default null,
                     CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'name';
    if (CNAME is null) then
      VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      VALS(1) := CNAME;
    end if;
    NAMES(2) := 'size';
    VALS(2) := CSIZE;
    NAMES(3) := 'maxlength';
    VALS(3) := CMAXLENGTH;
    NAMES(4) := 'value';
    VALS(4) := CVALUE;
    PRINT_TAG('input type="text"', CATTRIBUTES, 4, NAMES, VALS);
  end FORMTEXT;
--
  procedure FORMSELECTOPEN(CNAME       in varchar2,
                           CPROMPT     in varchar2 default null,
                           NSIZE       in integer  default null,
                           CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
  begin
    NAMES(1) := 'name';
    if (CNAME is null) then
      VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      VALS(1) := CNAME;
    end if;
    NAMES(2) := 'prompt';
    VALS(2) := CPROMPT;
    NAMES(3) := 'size';
    VALS(3) := to_char(NSIZE);
    PRINT_TAG('select', CATTRIBUTES, 3, NAMES, VALS);
  end FORMSELECTOPEN;
--
  procedure FORMSELECTOPTION(CVALUE      in varchar2,
                             CSELECTED   in varchar2 default null,
                             CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
    N     number;
  begin
    NAMES(1) := '';
    VALS(1) := 'selected';
    if (CSELECTED is null) then
      N := 0;
    else
      N := 1;
    end if;
    PRINT_TAGGED_TEXT('option', CVALUE, CATTRIBUTES, N, NAMES, VALS);
  end FORMSELECTOPTION;
--
  procedure FORMSELECTCLOSE is
  begin
    OWA.PRINT('</select>');
  end;
--
  procedure TEXT_AREA(CNAME       in varchar2,
                      NROWS       in integer,
                      NCOLUMNS    in integer,
                      CALIGN      in varchar2 default null,
                      CWRAP       in varchar2 default null,
                      CVALUE      in varchar2 default null,
                      CATTRIBUTES in varchar2 default null) is
    NAMES OWA.VCTAB;
    VALS  OWA.VCTAB;
    TAG   varchar2(100);
  begin
    NAMES(1) := 'name';
    if (CNAME is null) then
      VALS(1) := chr(0); -- force the NAME= attribute to print
    else
      VALS(1) := CNAME;
    end if;
    NAMES(2) := 'rows';
    if (NROWS is null) then
      VALS(2) := chr(0); -- force the ROWS= attribute to print
    else
      VALS(2) := to_char(NROWS);
    end if;
    NAMES(3) := 'cols';
    if (NCOLUMNS is null) then
      VALS(3) := chr(0); -- force the COLS= attribute to print
    else
      VALS(3) := to_char(NCOLUMNS);
    end if;
    NAMES(4) := 'align';
    VALS(4) := CALIGN;
    if (CWRAP is null) then
      TAG := 'input type="textarea"';
    else
      TAG := 'input type="textarea" wrap';
    end if;
    if (CVALUE = chr(0)) then
      PRINT_TAG(TAG, CATTRIBUTES, 4, NAMES, VALS);
    else
      PRINT_TAGGED_TEXT(TAG, CVALUE, CATTRIBUTES, 4, NAMES, VALS);
    end if;
  end TEXT_AREA;
--
  procedure FORMTEXTAREA(CNAME       in varchar2,
                         NROWS       in integer,
                         NCOLUMNS    in integer,
                         CALIGN      in varchar2 default null,
                         CATTRIBUTES in varchar2 default null) is
  begin
   htp.p( htf.formtextarea(cname=>cname, nrows=>nrows, ncolumns=>ncolumns, calign=>calign, cattributes=>cattributes) );

  --  TEXT_AREA(CNAME, NROWS, NCOLUMNS, CALIGN, null, '', CATTRIBUTES);
  end FORMTEXTAREA;
--
  procedure FORMTEXTAREA2(CNAME      in varchar2,
                          NROWS       in integer,
                          NCOLUMNS    in integer,
                          CALIGN      in varchar2 default null,
                          CWRAP       in varchar2 default null,
                          CATTRIBUTES in varchar2 default null) is
  begin
    TEXT_AREA(CNAME, NROWS, NCOLUMNS, CALIGN, CWRAP, '', CATTRIBUTES);
  end FORMTEXTAREA2;
--
  procedure FORMTEXTAREAOPEN(CNAME       in varchar2,
                             NROWS       in integer,
                             NCOLUMNS    in integer,
                             CALIGN      in varchar2 default null,
                             CATTRIBUTES in varchar2 default null) is
  begin
      htp.p( htf.formtextareaopen(cname=>cname, nrows=>nrows, ncolumns=>ncolumns, calign=>calign, cattributes=>cattributes) );

  --  TEXT_AREA(CNAME, NROWS, NCOLUMNS, CALIGN, null, chr(0), CATTRIBUTES);
  end FORMTEXTAREAOPEN;
--
  procedure FORMTEXTAREAOPEN2(CNAME       in varchar2,
                             NROWS       in integer,
                             NCOLUMNS    in integer,
                             CALIGN      in varchar2 default null,
                             CWRAP       in varchar2 default null,
                             CATTRIBUTES in varchar2 default null) is
  begin
    TEXT_AREA(CNAME, NROWS, NCOLUMNS, CALIGN, CWRAP, chr(0), CATTRIBUTES);
  end FORMTEXTAREAOPEN2;
--
  procedure FORMTEXTAREACLOSE is
  begin
    OWA.PRINT('</textarea>');
  end FORMTEXTAREACLOSE;
--
  procedure FORMCLOSE is
  begin
    OWA.PRINT('</form>');
  end FORMCLOSE;
--
  function ESCAPE_ARG(ARG in varchar2) return varchar2 is
  begin
    return(replace(
             replace(
               replace(
                 replace(
                   replace(
                     replace(
                       replace(
                         replace(
                           replace(
                             replace(ARG,
                                     '%','%25'),
                                   '&','%26'),
                                 '=','%3D'),
                               '?','%3F'),
                             '+','%2B'),
                           '"','%22'),
                         '#','%23'),
                       '<','%3C'),
                     '>','%3E'),
                   ' ','+'));
  end ESCAPE_ARG;
--
  function ESCAPE_SC(CTEXT in varchar2) return varchar2 is
  begin
    return(replace(replace(replace(replace(CTEXT,
                                           '&', AMP),
                                   '"', QUOT),
                           '<', LT),
                   '>', GT));
  end ESCAPE_SC;
--
  /*
  ** ### WITHIN ARGUMENTS, YOU SHOULD DO SOME FURTHER REPLACEMENTS.
  ** ### THE PROBLEM IS, YOU CAN'T DO THAT AFTER THE URL HAS BEEN
  ** ### ASSEMBLED.  EVEN IF YOU PARSE THROUGH THE ARGUMENTS AND
  ** ### TRY TO FIX THEM, YOU'LL GET CONFUSED IF AN ARGUMENT VALUE
  ** ### HAPPENS TO CONTAIN A STOP CHARACTER SUCH AS AMPERSAND.
  ** ### SO, THIS ROUTINE SHOULD ONLY BE USED FOR THE PATH PORTION
  ** ### OF THE URL, AND ANOTHER ROUTINE SHOULD BE USED TO ESCAPE
  ** ### ANY ARGUMENTS DURING THE ASSEMBLY PROCESS.
  */
  function ESCAPE_URL(URL in varchar2) return varchar2 is
  begin
    return(replace(
             replace(
               replace(
                 replace(
                   replace(
                     replace(URL,
                             '%','%25'),
                           ' ','%20'),
                         '"','%22'),
                       '+','%2B'),
                     '<','%3C'),
                   '>','%3E'));
  end ESCAPE_URL;
--
  procedure INIT is
  begin
    OWA.INIT;
  end INIT;

  procedure GET_PAGE(PAGEBUF out htp.htbuf_arr, NROWS in out integer)
  as
   PAGEBUF2	owa.VCTAB;
  begin
    owa.get_page(pagebuf2,nrows);
    if (NROWS > 0) then
      for I in PAGEBUF2.first..PAGEBUF2.last loop
        PAGEBUF(I) := pagebuf2(I);
      end loop;
    end if;
  end GET_PAGE;

  procedure ADDDEFAULTHTMLHDR( BADDHTMLHDR in boolean )
  as
  begin
   null;
  end ADDDEFAULTHTMLHDR;

  function  GET_LINE(NROWS out integer)
   return varchar2
  as
  begin
   return( owa.get_line( nrows ) );
  end get_line;

end HTP;
/
