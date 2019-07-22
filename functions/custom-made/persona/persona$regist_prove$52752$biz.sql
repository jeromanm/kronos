create or replace function persona$regist_prove$52752$biz(x$super number, x$persona number, x$tipo_proveedor number, x$ruc_entidad nvarchar2,  x$denominacion_entidad nvarchar2, x$numero_sime_proveedor number) return number is
    v$err           constant number := -20000; -- an integer in the range -20000..-20999
    v$msg           nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_proveedor  number;
    err_num         NUMBER;             
    err_msg         VARCHAR2(255);
    v$cedula        VARCHAR2(20);
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
    update persona set tipo_proveedor = x$tipo_proveedor,  ruc_entidad = x$ruc_entidad,  denominacion_entidad = x$denominacion_entidad, numero_sime_proveedor = x$numero_sime_proveedor
    where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_proveedor := busca_clave_id;
    insert into proveedor (id, version, codigo, persona, tipo_proveedor, cedula, nombre, denominacion_entidad,
                            ruc_entidad, numero_sime, fecha_transicion)
    values (v_id_proveedor, 0, v_id_proveedor, x$persona, x$tipo_proveedor, v$cedula, v$nombre, x$denominacion_entidad,
            x$ruc_entidad, x$numero_sime_proveedor, sysdate);
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de senacsa, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
