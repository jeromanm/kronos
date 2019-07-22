create or replace function persona$registrar_empleo$biz(x$super number, x$persona number, x$fecha_ingreso_emp date, x$fecha_egreso_emp date, x$monto_emp number, 
                                                        x$nombre_empresa_emp varchar2, x$numero_sime_emp number) return number is 
  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
	v$log rastro_proceso_temporal%ROWTYPE;
	v_id_empleo			number;
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
		v_id_empleo:=busca_clave_id;
		insert into empleo (id, version, codigo, persona, cedula, nombre, NOMBRE_EMPRESA, fecha_ingreso, monto,
                        fecha_egreso, numero_sime, fecha_transicion)
		values (v_id_empleo, 0, v_id_empleo, x$persona, v$cedula, v$nombre, x$nombre_empresa_emp, x$fecha_ingreso_emp, x$monto_emp, 
            x$fecha_egreso_emp, x$numero_sime_emp, sysdate);
	EXCEPTION
	when others then
		v$msg := SUBSTR(SQLERRM, 1, 300);
		raise_application_error(v$err, 'Error al intentar el registro de empleos, mensaje:' || v$msg, true);
	END;
  begin
    update persona set NUMERO_SIME_EMP=x$numero_sime_emp, FECHA_EGRESO_EMP= x$fecha_egreso_emp,
                      FECHA_INGRESO_EMP=x$fecha_ingreso_emp, MONTO_EMP=x$monto_emp, NOMBRE_EMPRESA_EMP=x$nombre_empresa_emp
    Where id=x$persona;
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de empleo, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
