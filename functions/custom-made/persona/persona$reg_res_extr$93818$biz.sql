create or replace function persona$reg_res_extr$93818$biz(x$super number, x$persona number, x$ano_votacion number, x$pais number,
                                                          x$domicilio nvarchar2, x$fecha_inscripcion date, x$numero_sime_residente number) return number is
    v$err                     constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_residente_extranjero number;
    v$cedula                  VARCHAR2(20);
    v$nombre                  VARCHAR2(100);
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
    update persona set ano_votacion = x$ano_votacion, pais = x$pais, domicilio = x$domicilio, fecha_inscripcion = x$fecha_inscripcion, numero_sime_residente = x$numero_sime_residente
    where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_residente_extranjero:=busca_clave_id;
		insert into residente_extranjero (id, version, codigo, persona, ano_votacion, pais, domicilio, fecha_inscripcion, numero_sime, cedula, nombre)        
    values (v_id_residente_extranjero, 0, v_id_residente_extranjero, x$persona,  x$ano_votacion, x$pais, x$domicilio, x$fecha_inscripcion, x$numero_sime_residente, v$cedula, v$nombre);
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de senacsa, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
