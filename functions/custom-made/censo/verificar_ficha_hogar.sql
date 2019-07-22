create or replace procedure verificar_ficha_hogar(x$cedula IN varchar2, x$cantidad IN OUT integer, x$cumple_regla IN OUT varchar2, x$tipo IN OUT varchar2) AS
  v$err     constant number := -20000;
  v$msg     nvarchar2(2000); -- a character string of at most 2048 bytes?
  estado    varchar2(5);
  err_num   NUMBER;
  err_msg   VARCHAR2(255);
  v$tipo    VARCHAR2(1000);
BEGIN
  Begin
    Select fh.estado, ef.codigo
      into x$cantidad, x$tipo
    From persona pe inner join ficha_persona fp on pe.ficha=fp.id
      inner join ficha_hogar fh on fp.ficha_hogar = fh.id
      inner join estado_ficha_hogar ef on fh.estado = ef.numero
    Where pe.codigo=x$cedula
      And rownum=1
    Order by fh.id desc;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x$tipo:=null;
  when others then
    x$tipo:=null;
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener el registro de ficha hogar, mensaje:' || v$msg,true);
  end;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(v$err, err_msg, true);
    x$cantidad:=0; x$tipo:='';
END;
/
