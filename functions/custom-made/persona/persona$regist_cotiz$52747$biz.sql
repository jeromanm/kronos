create or replace function persona$regist_cotiz$52747$biz(x$super number, x$persona number, x$fecha_ingreso_cotizante date, x$fecha_egreso_cotizante date, x$monto number,
                                                          x$nombres_empresa nvarchar2, x$ruc nvarchar2, x$numero_sime_cotizante  number) return number is
    v$err           constant number := -20000; -- an integer in the range -20000..-20999
    v$msg           nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_cotizante  number;
    err_num         NUMBER;
    err_msg         VARCHAR2(255);
    v$cedula        VARCHAR2(20);
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
    update persona set FECHA_INGRESO_COTIZANTE=x$fecha_ingreso_cotizante, FECHA_EGRESO_COTIZANTE=x$fecha_egreso_cotizante,
                      NUMERO_SIME_COTIZANTE=x$numero_sime_cotizante, NOMBRES_EMPRESA=x$nombres_empresa, RUC=x$ruc,
                      MONTO_COTIZANTE=x$monto
    where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_cotizante := busca_clave_id;
    insert into cotizante (id, version, codigo, persona, cedula, fecha_ingreso_cotizante, fecha_egreso_cotizante, monto_cotizante,
                          nombres_empresa, ruc, archivo, linea, fecha_transicion, numero_sime, observaciones)
    values (v_id_cotizante,0, v_id_cotizante, x$persona, v$cedula, x$fecha_ingreso_cotizante, x$fecha_egreso_cotizante, x$monto,
            x$nombres_empresa, x$ruc, null, null, '', x$numero_sime_cotizante, null);
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de cotizante, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
