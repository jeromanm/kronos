CREATE OR REPLACE FUNCTION existe_empleado(p_persona IN number) RETURN varchar AS
  edad    NUMBER;
  estado   varchar(5);
  cantidad number;
  err_num NUMBER;
  err_msg VARCHAR2(255);
BEGIN
  select count(*) into cantidad from EMPLEO where persona = p_persona;
  IF cantidad > 0 then 
     estado := 'true';
  ELSE   
     estado := 'false';
  END IF ;   
 RETURN estado;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(err_num, err_msg, true);
    estado:='FALSE';
    RETURN estado;
END;
/

