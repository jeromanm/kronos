create or replace procedure cumple_discapacidad(x$cedula IN varchar2, x$cantidad IN OUT integer, x$cumple_regla IN OUT varchar2, x$tipo IN OUT varchar2) AS
  v$err     constant number := -20000;
  v$msg     nvarchar2(2000); -- a character string of at most 2048 bytes?
  estado    varchar2(5);
  err_num   NUMBER;
  err_msg   VARCHAR2(255);
  v$tipo    VARCHAR2(1000);
BEGIN
  Begin
    Select 'Certificado: ' || CERTIFICADO_INVALIDEZ || ', diagnóstico: ' || DIAGNOSTICO_INVALIDEZ || ', fecha certificado: ' || FECHA_CERTIFICADO_INVALIDEZ || ', nro sime: ' || es.codigo as tipo, 
            case when trim(CERTIFICADO_INVALIDEZ) is null then 0 else 1 end as cantidad
      into x$tipo, x$cantidad
    From persona pe inner join expediente_sime es on pe.NUMERO_SIME_INVALIDEZ = es.id
    Where pe.codigo=x$cedula And (pe.CERTIFICADO_INVALIDEZ is not null or pe.DIAGNOSTICO_INVALIDEZ is null) 
      And rownum=1    
    Order by pe.FECHA_CERTIFICADO_INVALIDEZ desc;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x$cantidad:=0;
  when others then
    x$cantidad:=0;
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener el registro de discapacidad, mensaje:' || v$msg,true);
  end;
  if x$cantidad>0 then 
    x$cumple_regla:='true';
  else
    x$cumple_regla:='false';
  end if;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(v$err, err_msg, true);
    x$cantidad:=0; x$tipo:='';
END;
/
