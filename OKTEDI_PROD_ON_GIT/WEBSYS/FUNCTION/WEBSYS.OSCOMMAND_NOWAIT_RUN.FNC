CREATE OR REPLACE FUNCTION WEBSYS.OSCommand_NoWait_Run(Command IN STRING)
RETURN VARCHAR2 IS
LANGUAGE JAVA
NAME 'OSCommand_NoWait.Run(java.lang.String) return int';
/
