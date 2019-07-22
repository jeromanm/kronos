create or replace function ficha_persona$cargar_censo$biz(x$super number, x$ficha number) return number is
    v$err               constant number := -20000; -- an integer in the range -20000..-20999
    v$msg               nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$cedula            nvarchar2(20);
    v$id_cedula         number;
    x$persona           number;
    v$nombre            nvarchar2(100);
    v$nombres           nvarchar2(50);
    v$apellidos         nvarchar2(50);
    v$sexo_persona      integer;
    v$fecha_nacimiento  date;
    v$numero_telefono   nvarchar2(13);
    v$estado_civil      integer;
    v$id_censo_persona  number;
    v$id_departamento   number;
    v$id_distrito       number;
    v$id_barrio         number;
    v$tipo_area         number;
begin
  Begin
    Select fp.numero_cedula, pe.id as idpersona, fp.NOMBRE, fp.NOMBRES, fp.APELLIDOS, fp.SEXO_PERSONA, fp.FECHA_NACIMIENTO, 
            fp.NUMERO_TELEFONO, fp.ESTADO_CIVIL, ce.id, fh.departamento, fh.distrito, fh.barrio, fh.tipo_area
      into v$cedula, x$persona, v$nombre, v$nombres, v$apellidos, v$sexo_persona, v$fecha_nacimiento, 
            v$numero_telefono, v$estado_civil, v$id_cedula, v$id_departamento, v$id_distrito, v$id_barrio, v$tipo_area
    From ficha_persona fp left outer join persona pe on fp.numero_cedula = pe.codigo
      inner join cedula ce on fp.numero_cedula = ce.numero
      left outer join ficha_hogar fh on fp.ficha_hogar = fh.id
    Where fp.id=x$ficha;
  EXCEPTION
  when no_data_found then
		raise_application_error(v$err,'Error: no se consiguen datos de la ficha persona o el número de cédula no esta en identificación.',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos de la ficha persona, mensaje:' || v$msg,true);
  end;
  if x$persona is null then
    Begin
      x$persona:=busca_clave_id;
      insert into persona (id, version, codigo, nombre, apellidos, nombres, fecha_nacimiento, sexo, estado_civil, paraguayo,
                          cedula, indigena, departamento, distrito, barrio, tipo_area, monitoreado, monitoreo_sorteo, 
                          edicion_restringida, telefono_linea_baja)
                  values (x$persona, 0, v$cedula, v$nombre, v$apellidos, v$nombres, v$fecha_nacimiento, v$sexo_persona, v$estado_civil, 'true',
                          v$id_cedula, 'false', v$id_departamento, v$id_distrito, v$id_barrio, v$tipo_area, 'false', 'false',
                          'true', v$numero_telefono);
    EXCEPTION
    when others then
      v$msg := SQLERRM;
      raise_application_error(v$err,'Error al intentar crear el registro de persona, mensaje:' || v$msg,true);
    End;
  else
    begin
      Update persona set ficha=x$ficha Where id=x$persona;
    EXCEPTION
    when others then
      v$msg := SQLERRM;
      raise_application_error(v$err,'Error al intentar actualizar el registro de persona, mensaje:' || v$msg,true);
    End;
  end if;
  begin
    v$id_censo_persona := busca_clave_id;
    INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,  
                                NUMERO_TELEFONO,  ESTADO, departamento, distrito, barrio, tipo_area,
                                FECHA_TRANSICION, USUARIO_TRANSICION)
								values (v$id_censo_persona, 0, v$id_censo_persona, x$persona, current_date, x$ficha,
                        v$numero_telefono, 1, v$id_departamento, v$id_distrito, v$id_barrio, v$tipo_area,
                        sysdate, current_user_id);
  exception
  when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar crear el registro de censo, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/

