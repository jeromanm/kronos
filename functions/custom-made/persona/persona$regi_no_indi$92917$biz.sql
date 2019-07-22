create or replace function persona$regi_no_indi$92917$biz(x$super number, x$persona number, x$nombr_entidad nvarchar2, x$numero_sime number) return number is
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg           nvarchar2(2000);
    v_id_noindigena   number;
    v$cedula          VARCHAR2(20);
    v$nombre          VARCHAR2(100);
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
    Update persona set indigena='false', etnia=null, comunidad=null, OBSERVACIONES_ANULAR_NO_INDIG=null, NOMBRE_ENTIDAD=x$nombr_entidad, NUMERO_SIME=x$numero_sime
    where id = x$persona;
  EXCEPTION
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 300);
    raise_application_error(v$err,'Error al intentar actualizar la persona, mensaje:' || err_msg, true);
  END;
  begin
    v_id_noindigena := busca_clave_id;
    insert into no_indigena (id, version, codigo, cedula, nombre, persona, NOMBRE_ENTIDAD, numero_sime, informacion_invalida, fecha_transicion)
    values (v_id_noindigena, 0, v_id_noindigena, v$cedula, v$nombre, x$persona, x$nombr_entidad, x$numero_sime, 'false', sysdate);
  EXCEPTION
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 300);
    raise_application_error(v$err,'Error al intentar insertar el registro de No Indígena, mensaje:' || err_msg, true);
  END;
  return 0;
end;
/