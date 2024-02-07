CREATE OR REPLACE FORCE VIEW WEBSYS.WAREHOUSE_PERFORMANCE
(NX, BEGIN_OF_WEEK, END_OF_WEEK, DT, ETHAN, 
 EVAN, GL, GRAHAM, GREG, GEOFFREY, 
 HARI, HENRY, JMASSEY, JN, STEVE, 
 DAY_TOT)
AS 
SELECT nx,
             begin_of_week,
             end_of_week,
             dt,
             ETHAN,
             EVAN,
             GL,
             GRAHAM,
             GREG,
             GEOFFREY,
             HARI,
             HENRY,
             JMASSEY,
             JN,
             --        JUYEONG,
             STEVE,
             --         TASH,
             --         VINCE,
             day_tot
        FROM (SELECT nx,
                     begin_of_week,
                     end_of_week,
                     dt,
                     SUM (total) OVER (PARTITION BY dt)     AS day_tot,
                     workers,
                     total
                FROM (SELECT b.BEGIN_OF_WEEK,
                             b.END_OF_WEEK,
                             b.nx,
                             a.*
                        FROM (    SELECT TRUNC (SYSDATE + 1 - ROWNUM)     dt
                                    FROM DUAL
                              CONNECT BY ROWNUM < 31) a
                             INNER JOIN
                             (    SELECT   NEXT_DAY (
                                               TRUNC (SYSDATE) - (LEVEL - 1) * 7,
                                               'MON')
                                         - 7      BEGIN_OF_WEEK,
                                           NEXT_DAY (
                                               TRUNC (SYSDATE) - (LEVEL - 1) * 7,
                                               'MON')
                                         - 3      END_OF_WEEK,
                                         LEVEL    nx
                                    FROM DUAL
                              CONNECT BY LEVEL <= 4
                                ORDER BY begin_of_week) b
                                 ON a.dt BETWEEN b.BEGIN_OF_WEEK
                                             AND b.END_OF_WEEK) tmp1
                     --order by nx desc, dt
                     LEFT JOIN
                     (  SELECT currdate, workers, SUM (cnt) total
                          FROM (SELECT currdate, REGEXP_SUBSTR (ca.account_name, '(\S*)') account_name, case when SUBSTR (UPPER (r.r_notes),1,4) = 'HARI' and REGEXP_SUBSTR (ca.account_name, '(\S*)')= 'CUSTOMS' THEN 'HARI' ELSE REGEXP_SUBSTR (ca.account_name, '(\S*)') END workers,
                                       REGEXP_REPLACE (
                                           REGEXP_REPLACE (
                                               REGEXP_REPLACE (
                                                   CASE
                                                       WHEN SUBSTR (
                                                                UPPER (r.r_notes),
                                                                1,
                                                                4) =
                                                            'HARI'
                                                       THEN
                                                           'HARI'
                                                       WHEN SUBSTR (
                                                                UPPER (r.r_notes),
                                                                1,
                                                                8) =
                                                            'JONATHAN'
                                                       THEN
                                                           'JMASSEY'
                                                       WHEN SUBSTR (
                                                                UPPER (r.r_notes),
                                                                1,
                                                                5) =
                                                            'JACOB'
                                                       THEN
                                                           'JN'
                                                       ELSE
                                                           UPPER (r.r_notes)
                                                   END,
                                                   '^.*\((\w+)\).*$',
                                                   '\1'),
                                               '(\w+).*$',
                                               '\1'),
                                           '[[:digit:]]')    workers1,
                                       r.r_notes,
                                       1                     cnt
                                  FROM strang.receivals r, websys.customer_account ca
                                 WHERE  r_notes IS NOT NULL
                                   AND  ca.username = r.created_by
                                   AND currdate > SYSDATE - 33)
                      GROUP BY currdate, workers 
                        HAVING upper(workers)  IN (                          -- 'RHI',
                                           --   'AN',
                                           'JN',
                                           'ETHAN',
                                           'HARI',
                                           'GREG',
                                           'STEVE',
                                           'GL',
                                           'EVAN',
                                           --  'GN',
                                           --  'NEMANI',
                                           'JMASSEY',
                                           'GEOFFREY',
                                           --   'NEMANI',
                                           --  'JUYEONG',
                                           --    'GRAHAM',
                                           'HENRY')) tmp2
                         ON (tmp2.currdate = tmp1.dt))
             --order by dt desc, workers asc;
             PIVOT (SUM (total)
                   FOR workers
                   IN ('ETHAN' AS ETHAN,
                       'EVAN' AS EVAN,
                      'GL' AS GL,
                      'HARI' AS HARI,
                      'JMASSEY' AS JMASSEY,
                      'JN' AS JN,
                      'JUYEONG' AS JUYEONG,
                      'GREG' AS GREG,
                      'STEVE' AS STEVE,
                      'GRAHAM' AS GRAHAM,
                      'GEOFFREY' AS GEOFFREY,
                      'HENRY' AS HENRY,
                      'OTHERS' AS OTHER))
    ORDER BY DT;
