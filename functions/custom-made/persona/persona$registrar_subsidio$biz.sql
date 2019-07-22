create or replace function persona$registrar_subsidio$biz(x$super number, x$persona number, x$fecha_ingreso_sub date, x$fecha_egreso_sub date, x$monto_sub number, x$nombre_empresa_sub varchar2, x$numero_sime_sub number) return number is
    v$err           constant number := -20000; -- an integer in the range -20000..-20999
    v$msg           nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_subsidio   number;
    v$cedula        VARCHAR2(20);
    v$nombre        VARCHAR2(100);
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
    Update persona set FECHA_EGRESO_SUB=x$fecha_egreso_sub, FECHA_INGRESO_SUB=x$fecha_ingreso_sub, MONTO_SUB=x$monto_sub, NUMERO_SIME_SUB=x$numero_sime_sub, NOMBRE_EMPRESA_SUB=x$nombre_empresa_sub
    Where id=x$persona;
  EXCEPTION
  When others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar la persona, mensaje:' || v$msg,true);
  End;
  begin
		v_id_subsidio:=busca_clave_id;
		insert into subsidio (id, version, codigo, persona, cedula, nombre, FECHA_INGRESO, FECHA_EGRESO, monto,
                          nombre_empresa, numero_sime, fecha_transicion)
		values (v_id_subsidio, 0, v_id_subsidio, x$persona, v$cedula, v$nombre, x$fecha_ingreso_sub, x$fecha_egreso_sub, x$monto_sub,
            x$nombre_empresa_sub, x$numero_sime_sub, sysdate);
	EXCEPTION
	when others then
		v$msg := SUBSTR(SQLERRM, 1, 300);
		raise_application_error(v$err, 'Error al intentar crear el registro de subsidio, mensaje: ' || v$msg, true);
	END;
  return 0;
end;
/
