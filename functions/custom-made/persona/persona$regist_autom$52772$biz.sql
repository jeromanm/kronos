create or replace function persona$regist_autom$52772$biz(x$super number, x$persona number, x$fecha_ingreso date, x$fecha_egreso date, x$tipo nvarchar2, 
                                                          x$cantidad number, x$modelo nvarchar2, x$ano_registro number, x$monto number, x$numero_sime_automotor nvarchar2) return number is
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_automotor    number;
    err_num           NUMBER;
    err_msg           VARCHAR2(255);
    v$cedula          VARCHAR2(20);
begin
  begin
    Select codigo into v$cedula From persona Where id=x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener la cédula de la persona, mensaje:' || v$msg,true);
  end;
  begin
    Update persona set TIPO=x$tipo, cantidad=x$cantidad, modelo=x$modelo, ano_registro=x$ano_registro,
                       monto=x$monto, NUMERO_SIME_automotor=x$numero_sime_automotor, FECHA_INGRESO=x$fecha_ingreso, 
                       FECHA_EGRESO=x$fecha_egreso
    Where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_automotor := busca_clave_id;
    insert into automotor (id, version, codigo, persona, cedula, fecha_ingreso, fecha_egreso, tipo, cantidad, modelo,
                          ano_registro, monto, archivo, linea, informacion_invalida, fecha_transicion, numero_sime, observaciones)
    values (v_id_automotor, 0, v_id_automotor, x$persona, v$cedula, x$fecha_ingreso, x$fecha_egreso, x$tipo, x$cantidad, x$modelo,
            x$ano_registro, x$monto, null, null, 'false', null, x$numero_sime_automotor, null);   
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear registro de automotor, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
