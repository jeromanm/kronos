create or replace function persona$reg_act_defu$23229$biz(x$super number, x$persona number, x$certificado_defuncion nvarchar2,
                                                          x$oficina_defuncion number, x$fecha_acta_defuncion date, x$tomo_defuncion nvarchar2,
                                                          x$folio_defuncion nvarchar2, x$acta_defuncion nvarchar2, x$fecha_defuncion date,
                                                          x$fecha_certificado_defuncion date, x$numero_sime_defuncion number,
                                                          x$departamento number, x$distrito number, x$nombre_registro nvarchar2,
                                                          x$lugar_fallecido nvarchar2, x$nacionalidad nvarchar2, x$edad number,
                                                          x$lugar_nacimiento nvarchar2, x$fecha_nacimientoDefu date) return number is
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_defuncion    number;
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
    update persona set certificado_defuncion = x$certificado_defuncion, oficina_defuncion = x$oficina_defuncion, fecha_acta_defuncion = x$fecha_acta_defuncion,
                        tomo_defuncion = x$tomo_defuncion, folio_defuncion = x$folio_defuncion, acta_defuncion = x$acta_defuncion, fecha_defuncion = x$fecha_defuncion,
                        fecha_certificado_defuncion = x$fecha_certificado_defuncion, numero_sime_defuncion = x$numero_sime_defuncion, departamentodef = x$departamento,
                        distritodef = x$distrito, nombre_registro = x$nombre_registro, lugar_fallecido = x$lugar_fallecido, nacionalidad = x$nacionalidad,
                        lugar_nacimiento = x$lugar_nacimiento, observaciones_anular_defuncion = null
    where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_defuncion := busca_clave_id;
    insert into defuncion (id, version, codigo, cedula, persona, certificado_defuncion, oficina_defuncion, fecha_acta_defuncion, tomo_defuncion, folio_defuncion,
                          acta_defuncion, fecha_defuncion, fecha_certificado_defuncion, numero_sime, departamento, distrito, nombre_Registro, lugar_Fallecido,
                          nacionalidad, edad, lugar_Nacimiento, fecha_Nacimiento_Defu,archivo, linea, informacion_invalida, fecha_transicion,  observaciones)
    values (v_id_defuncion, 0, v_id_defuncion, v$cedula, x$persona, x$certificado_defuncion, x$oficina_defuncion, x$fecha_acta_defuncion, x$tomo_defuncion, x$folio_defuncion,
            x$acta_defuncion, x$fecha_defuncion, x$fecha_certificado_defuncion, x$numero_sime_defuncion, x$departamento, x$distrito, x$nombre_registro, x$lugar_fallecido,
            x$nacionalidad, x$edad, x$lugar_nacimiento, x$fecha_nacimientoDefu, null, null, '', null, null);
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de defunción, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
