CREATE OR REPLACE FUNCTION WEBSYS.get_image_type (i_dir    IN VARCHAR2,
                                           i_file   IN VARCHAR2)
   RETURN VARCHAR2
AS
   l_bfile       BFILE;
   l_blob        BLOB;
   l_file_type   VARCHAR2 (50);
BEGIN
   DBMS_LOB.createtemporary (l_blob, FALSE);
   l_bfile := BFILENAME (i_dir, i_file);
   DBMS_LOB.fileopen (l_bfile, DBMS_LOB.file_readonly);
   DBMS_LOB.loadfromfile (l_blob, l_bfile, DBMS_LOB.getlength (l_bfile));
   DBMS_LOB.fileclose (l_bfile);

   IF RAWTOHEX (DBMS_LOB.SUBSTR (l_blob, 8, 1)) = '89504E470D0A1A0A'
   THEN
      l_file_type := 'PNG';
   ELSIF DBMS_LOB.SUBSTR (l_blob, 3, 1) = '474946'
   THEN
      l_file_type := 'GIF';
   ELSIF RAWTOHEX (DBMS_LOB.SUBSTR (l_blob, 3, 1)) = 'FFD8FF'
   THEN
      l_file_type := 'JPG';
   ELSE
      l_file_type := 'The file is not an image.';
   END IF;

   RETURN l_file_type;
EXCEPTION
   WHEN OTHERS
   THEN
      IF DBMS_LOB.fileisopen (l_bfile) = 1
      THEN
         DBMS_LOB.fileclose (l_bfile);
      END IF;

      DBMS_LOB.freetemporary (l_blob);
      RETURN 'The file does not exists.';
END get_image_type;
/
