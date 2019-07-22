create or replace function persona$registrar_catastro$biz(x$super number, x$persona number, x$fecha_ingreso_catastro date, x$fecha_egreso_catastro date, 
                                                          x$tipo_catastro nvarchar2, x$cantidad_inmueble number, x$monto number, x$numero_sime_catastro number) return number is
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_catastro     number;
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
    update persona set FECHA_INGRESO_CATASTRO=x$fecha_ingreso_catastro, FECHA_EGRESO_CATASTRO=x$fecha_egreso_catastro, TIPO_CATASTRO=x$tipo_catastro, CANTIDAD_INMUEBLE=x$cantidad_inmueble,
                        MONTO_CATASTRO=x$monto, NUMERO_SIME_CATASTRO=x$numero_sime_catastro
    where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_catastro := busca_clave_id;
    insert into catastro (id, version, codigo, persona, fecha_ingreso_catastro, fecha_egreso_catastro, tipo_catastro, cantidad_inmueble,
                           monto_catastro, numero_sime, archivo, linea, informacion_invalida, fecha_transicion, observaciones, cedula)
    values (v_id_catastro, 0,v_id_catastro, x$persona, x$fecha_ingreso_catastro, x$fecha_egreso_catastro, x$tipo_catastro, x$cantidad_inmueble,
            x$monto, x$numero_sime_catastro, null, null, '', null, null, v$cedula);
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de catastro, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/

