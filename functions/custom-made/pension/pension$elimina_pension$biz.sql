create or replace function pension$elimina_pension$biz(x$super number, x$pension number, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin--  Pension.eliminaPension - business logic
  begin
    Delete From solicitud_pension where pension = x$pension;
    Delete From consulta_ciudadano where pension = x$pension;
    Delete From transicion_pension where pension = x$pension;
    Delete From requisito_pension where pension = x$pension;
    Delete From pension Where id=x$pension;
  exception
  WHEN NO_DATA_FOUND THEN
    null;
  when others then
    v$msg := SUBSTR(SQLERRM, 1, 2000);
    raise_application_error(v$err, 'Error al intentar eliminar los registros de la pensión, mensaje:' || v$msg, true);
  end;
  begin
    update rastro_proceso set nombre_recurso = x$observaciones
    where	id_rastro_proceso = x$super;
  exception
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar actualizar el rastro proceso, mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  end;
  return 0;
end;
/