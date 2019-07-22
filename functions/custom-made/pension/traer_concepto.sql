CREATE OR REPLACE FUNCTION traer_concepto(p_codigo varchar2) RETURN varchar AS
  v_descripcion varchar2(100);
  err_num NUMBER;
  err_msg VARCHAR2(255);
BEGIN
  select nombre into v_descripcion from v_conceptos where codigo=p_codigo;
  RETURN v_descripcion;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(err_num, err_msg, true);
END;
/
