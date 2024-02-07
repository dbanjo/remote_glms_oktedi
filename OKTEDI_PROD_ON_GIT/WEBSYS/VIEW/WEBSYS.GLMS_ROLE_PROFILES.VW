CREATE OR REPLACE FORCE VIEW WEBSYS.GLMS_ROLE_PROFILES
(ACCOUNT_NAME, USERNAME, DATE_CREATED, DATE_EXPIRES, ADELAIDE, 
 BRISBANE, CAIRNS, MELBOURNE, PERTH, SYDNEY, 
 TOWNSVILLE, "LEVEL 1", "LEVEL 2", "LEVEL 3", "LEVEL 4", 
 "LEVEL 5", "LEVEL 6", "LEVEL 7", "LEVEL 8", "LEVEL 9", 
 LEVEL_0, ADMIN, "TRACKER APP")
AS 
SELECT "ACCOUNT_NAME",
             "USERNAME",
             "DATE_CREATED",
             "DATE_EXPIRES",
             "ADELAIDE",
             "BRISBANE",
             "CAIRNS",
             "MELBOURNE",
             "PERTH",
             "SYDNEY",
             "TOWNSVILLE",
             "LEVEL 1",
             "LEVEL 2",
             "LEVEL 3",
             "LEVEL 4",
             "LEVEL 5",
             "LEVEL 6",
             "LEVEL 7",
             "LEVEL 8",
             "LEVEL 9",
             "LEVEL_0",
             "ADMIN",
             "TRACKER APP"
        FROM (SELECT ca.aid,
                     ca.Account_name,
                     username,
                     date_created,
                     date_expires,
                     pr.role_name -- date_created, date_expires , cr.role_id, pr.role_name --, pr.parameter_name, pr.parameter_value
                FROM websys.customer_roles  cr,
                     websys.piction_roles   pr,
                     websys.customer_account ca
               WHERE     cr.role_id = pr.role_id
                     AND cr.aid = ca.aid
                     --and ca.username = 'DBANJO'
                     --and cr.role_id < 35
                     AND date_expires > SYSDATE --and cr.role_Id not in (12,14,15,16)
                                               )
             PIVOT (SUM (SIGN (aid))
                   FOR role_name
                   IN ('ADELAIDE' AS ADELAIDE,
                      'BRISBANE' AS BRISBANE,
                      'CAIRNS' AS CAIRNS,
                      'MELBOURNE' AS MELBOURNE,
                      'PERTH' AS PERTH,
                      'SYDNEY' AS SYDNEY,
                      'TOWNSVILLE' AS TOWNSVILLE,
                      'LEVEL 1' AS "LEVEL 1",
                      'LEVEL 2' AS "LEVEL 2",
                      'LEVEL 3' AS "LEVEL 3",
                      'LEVEL 4' AS "LEVEL 4",
                      'LEVEL 5' AS "LEVEL 5",
                      'LEVEL 6' AS "LEVEL 6",
                      'LEVEL 7' AS "LEVEL 7",
                      'LEVEL 8' AS "LEVEL 8",
                      'LEVEL 9' AS "LEVEL 9",
                      'LEVEL_0' AS "LEVEL_0",
                      'ADMIN' AS "ADMIN",
                      'TRACKER APP' AS "TRACKER APP"))
    ORDER BY Account_name;
