create or replace function censo_pers$prue_func$52815$biz(x$super number, x$censo number, x$nombre number) return number is
  v$err         constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xid         varchar2(146);
  v$log         rastro_proceso_temporal%ROWTYPE;
  v$cef         constant enums.condicion_eje_fun := condicion_eje_fun$enum();
  x$valor       number;
begin --SIAU 12520
	v$log := rastro_proceso_temporal$select();
	begin
		Delete From result_funcion_icv Where censo_persona=x$censo;
		x$valor:=censo_persona$obtenervalor_icv(x$super, x$nombre, x$censo, null);
    commit;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001,'No se consiguió obtener el id de la función del ICV.', true);
    WHEN others THEN
      raise_application_error(-20001,'Error al intentar obtener el valor de la función del ICV, mensaje:' || SQLERRM, true);
    End;
	raise_application_error(-20000, 'Valor obtenido:'  || round(x$valor,4), false);
   -- v$msg := util.format(util.gettext('Valor obtenido %s'), x$valor);
   -- return rastro_proceso$update(x$super, v$cef.EJECUTADO_SIN_ERRORES, null, v$msg);
    return x$valor;   
end;
/
