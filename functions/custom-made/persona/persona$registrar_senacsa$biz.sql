create or replace function persona$registrar_senacsa$biz(x$super number, x$persona number,x$estancia nvarchar2, x$fecha_ingreso_senacsa date, x$fecha_egreso_senacsa date,
                                                         x$tipo_senacsa nvarchar2, x$cantidad_senacsa number, x$monto_senacsa number, x$numero_sime_senacsa nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid raw(8);
    v$log rastro_proceso_temporal%ROWTYPE;
    v_id_senacsa     number;
    err_num          NUMBER;
    err_msg          VARCHAR2(255);
    v$cedula         VARCHAR2(20);
    v$nombre         VARCHAR2(100);
begin
  begin
    Select codigo, nombre into v$cedula, v$nombre From persona Where id=x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener la cédula de la persona, mensaje:' || v$msg,true);
  end;
  begin
    update persona set estancia  =  x$estancia, fecha_ingreso_senacsa = x$fecha_ingreso_senacsa,
                      fecha_egreso_senacsa = x$fecha_egreso_senacsa, tipo_senacsa = x$tipo_senacsa,
                      cantidad_senacsa = x$cantidad_senacsa, monto_senacsa = x$monto_senacsa, numero_sime_senacsa  = x$numero_sime_senacsa
    where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_senacsa := busca_clave_id;
    insert into senacsa (id, version, codigo, persona, estancia, fecha_ingreso_senacsa, fecha_egreso_senacsa, tipo_senacsa, cantidad_senacsa,
                        cedula, nombre, monto_senacsa, archivo, linea, fecha_transicion, numero_sime_senacsa, observaciones)
    values (v_id_senacsa, 0, v_id_senacsa, x$persona, x$estancia, x$fecha_ingreso_senacsa, x$fecha_egreso_senacsa, x$tipo_senacsa, x$cantidad_senacsa,
            v$cedula, v$nombre, x$monto_senacsa, null, null, null, x$numero_sime_senacsa, null);
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de senacsa, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
