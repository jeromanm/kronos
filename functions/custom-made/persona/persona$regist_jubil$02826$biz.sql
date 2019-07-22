create or replace function persona$regist_jubil$02826$biz(x$super number, x$persona number, x$fecha_ingreso_jubi date, x$fecha_egreso_jubi date, x$monto_jubi number, 
                                                          x$nombre_empresa varchar2, x$numero_sime_jubi number) return number is
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
  v_id_jubilacion	  number;
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
    Update persona set FECHA_INGRESO_JUBI=x$fecha_ingreso_jubi, MONTO_JUBI=x$monto_jubi, numero_sime_jubi=x$numero_sime_jubi, NOMBRE_EMPRESA=x$nombre_empresa, fecha_egreso_jubi=x$fecha_egreso_jubi
    Where id=x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
		v_id_jubilacion:=busca_clave_id;
		insert into jubilacion (id, version, codigo, persona, cedula, nombre, fecha_ingreso, NOMBRE_EMPRESA, FECHA_EGRESO,
                            monto, numero_sime, fecha_transicion)
                    values (v_id_jubilacion, 0, v_id_jubilacion, x$persona, v$cedula, v$nombre, x$fecha_ingreso_jubi, x$nombre_empresa, x$fecha_egreso_jubi, 
                            x$monto_jubi, x$numero_sime_jubi, sysdate);
	EXCEPTION
	when others then
		v$msg := SUBSTR(SQLERRM, 1, 300);
		raise_application_error(v$err,'Erro al intentar crear el registro de jubilación, mensaje:' || v$msg, true);
	END;
  return 0;
end;
/
