create or replace function persona$reg_act_naci$73337$biz(x$super number, x$persona number, x$fecha_nacimientos date, x$departamento_nacimiento number, x$distrito_nacimiento number,  x$nombre_madre nvarchar2,
                                                          x$cedula_madre nvarchar2, x$nombre_padre nvarchar2,  x$cedula_padre nvarchar2, x$folio_nacimiento number, x$acta_nacimiento number, x$tomo_nacimiento nvarchar2,
                                                          x$numero_sime_nacimiento number) return number is
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_nacimiento   number;
    err_num           NUMBER;
    err_msg           VARCHAR2(255);
    v$cedula          VARCHAR2(20);
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
    update persona set fecha_nacimientos = x$fecha_nacimientos, departamento_nacimiento = x$departamento_nacimiento, distrito_nacimiento = x$distrito_nacimiento, 
                        nombre_madre = x$nombre_madre,  cedula_madre = x$cedula_madre, nombre_padre = x$nombre_padre,  cedula_padre = x$cedula_padre, folio_nacimiento = x$folio_nacimiento,
                        acta_nacimiento = x$acta_nacimiento, tomo_nacimiento = x$tomo_nacimiento,  numero_sime_nacimiento = x$numero_sime_nacimiento, observac_anular_nacimien_13191 = null
    where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_nacimiento := busca_clave_id;
    Insert into nacimiento (id, version, codigo, persona, cedula, nombre, personamadre, cedula_madre, nombre_madre, personapadre, cedula_padre, nombre_padre,
                            fecha_nacimientos, departamento_nacimiento, distrito_nacimiento, folio_nacimiento,
                            acta_nacimiento, tomo_nacimiento, fecha_transicion, numero_sime)
    values (v_id_nacimiento, 0, v_id_nacimiento, x$persona, v$cedula, v$nombre, null, x$cedula_madre, x$nombre_madre, null, x$cedula_padre, x$nombre_padre,
            x$fecha_nacimientos, x$departamento_nacimiento, x$distrito_nacimiento, x$folio_nacimiento, 
            x$acta_nacimiento, x$tomo_nacimiento, sysdate, x$numero_sime_nacimiento);
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de nacimiento, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
