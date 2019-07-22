create or replace function pla_per_pa$veri_canc$04334$biz(x$super number, x$solicitud number) return number is
  v$err               constant number := -20000; -- an integer in the range -20000..-20999
  err_msg             varchar2(200);
  v$nen_codigo        number(2);
  v$ent_codigo        number(3);
  contador            number:=0;
  v$codigo_solicitud  varchar2(20);
  v_estado            number;
  v_ano               number;
begin --centro de procesamiento anular cancelacion de cuenta
  begin
    Select valor_numerico into v$nen_codigo From variable_global Where numero=122;
    Select valor_numerico into v$ent_codigo From variable_global Where numero=123;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos del valor del nivel de la entidad.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor del nivel de la entidad, mensaje:' || err_msg, true);
  end;
  Begin
    Select ESTADO_SOLICITUD, to_char(fecha_solicitud,'yyyy'), codigo
      into v_estado, v_ano, v$codigo_solicitud
    From encabezado_solicitud 
    Where id=x$solicitud And tipo_alta='false';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_estado:=0;
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el estado de la solicitud de cuenta, mensaje:' || err_msg, true);
  End;
  if v_estado<>1 then
    raise_application_error(v$err, 'Error: ls solicitud de cuenta no está en estado solicitado, o no existe.', true);
  end if;
  begin
    Update encabezado_solicitud set estado_solicitud=3 where id=x$solicitud;
  exception
  when others then
    raise_application_error(v$err, 'Error al intentar crear la solicitud de baja de la cuenta banco, mensaje:' || sqlerrm, true);
  end;
  begin
    Update a_bajcta@SINARH set estado=0, BAJ_FCHACT=sysdate, BAJ_USRACT=substr(user,1,8) 
    Where baja_nrocan=v$codigo_solicitud And ani_aniopre=v_ano
      And nen_codigo=v$nen_codigo And ent_codigo=v$ent_codigo;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos de la solicitud de baja en el SINARH. Nivel Entidad:' || v$nen_codigo || ', Codigo Entidad:' || v$ent_codigo || ', año:' || v_ano || ', nro cancelación:' || v$codigo_solicitud, true);
  when others then
    raise_application_error(v$err, 'Error al intentar actualizar el estado de la solicitud de baja en SINARH, nro can:' || v$codigo_solicitud || '. Mensaje:' || sqlerrm, true);
  end;
  return 0;
end;
/