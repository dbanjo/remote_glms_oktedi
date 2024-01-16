CREATE OR REPLACE TRIGGER WEBSYS.T_HEALTH_RESULT_1 
 BEFORE INSERT OR UPDATE
 ON WEBSYS.HEALTH_RESULT
 FOR EACH ROW
DECLARE
 cursor c1( pcode varchar2 ) is select * from health_parameters where parameter_code = pcode;
 cursor c2( pcode varchar2, nmb number ) is select given_score from score where parameter_code = pcode and nmb between loval and highval;
 c1rec	c1%ROWTYPE;
BEGIN
 if (:NEW.RESULT_NUMBER is not null or :NEW.RESULT_FUZZY_BOOLEAN is not null or :NEW.RESULT_TEXT is not null)
  then
   open c1( :NEW.PARAMETER_CODE );
   fetch c1 into c1rec;
   close c1;
   if c1rec.response_type in ('LOV','TEXT')
    then
     null; -- At this stage LOV's and TEXT values are not scored
   elsif c1rec.response_type = 'SCORE'
    then
     open c2( :NEW.PARAMETER_CODE, :NEW.RESULT_NUMBER );
     fetch c2 into :NEW.SCORE_RESULT;
     close c2;
   elsif c1rec.response_type = 'BOOLEAN'
    then
     -- Boolean scoring is open to debate for partial responses. Currently assume an obvious answer
     if (:NEW.RESULT_FUZZY_BOOLEAN in ('Yes','No'))
      then
       if :NEW.RESULT_FUZZY_BOOLEAN = c1rec.expected_response
        then
         :NEW.SCORE_RESULT := c1rec.max_score;
        else
         :NEW.SCORE_RESULT := 0;
       end if;
      elsif :NEW.RESULT_FUZZY_BOOLEAN = 'Not Relevant'
       then
        :NEW.SCORE_RESULT := NULL;
      elsif :NEW.RESULT_FUZZY_BOOLEAN = 'Partially Complies'
       then
        :NEW.SCORE_RESULT := round(c1rec.max_score * 0.5);
      elsif :NEW.RESULT_FUZZY_BOOLEAN = 'Started'
       then
        :NEW.SCORE_RESULT := round(c1rec.max_score * 0.25);
      elsif :NEW.RESULT_FUZZY_BOOLEAN = 'Very close'
       then
        :NEW.SCORE_RESULT := round(c1rec.max_score * 0.75);
      elsif :NEW.RESULT_FUZZY_BOOLEAN = 'Unknown'
       then
        :NEW.SCORE_RESULT := round(c1rec.max_score * 0.0);
      elsif :NEW.RESULT_FUZZY_BOOLEAN = 'Major Problem'
       then
        :NEW.SCORE_RESULT := round(c1rec.max_score * 0.0);
      elsif :NEW.RESULT_FUZZY_BOOLEAN = 'Not correctly handled'
       then
        :NEW.SCORE_RESULT := round(c1rec.max_score * 0.0);
      elsif :NEW.RESULT_FUZZY_BOOLEAN = 'Unable to answer'
       then
        :NEW.SCORE_RESULT := round(c1rec.max_score * 0.0);
      end if;
   elsif c1rec.response_type = 'NUMBER'
    then
     null; -- At this stage NUMBER values are not scored
   end if;
  else
   :NEW.SCORE_RESULT := 0;
 end if;
END T_HEALTH_RESULT_1;
/
