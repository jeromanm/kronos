create or replace function pension$denegar$biz(x$super number, x$pension number, x$resolucion nvarchar2, x$fecha date, x$resumen nvarchar2, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
--  v$log rastro_proceso_temporal%ROWTYPE;
begin
--
--  Pension.denegar - business logic
--
    update pension set resolucion_denegar = x$resolucion, fecha_resolucion_denegar = x$fecha, resumen_resolucion_denegar = x$resumen, observaciones = x$observaciones, estado = 5, fecha_transicion = current_date, usuario_transicion = util.current_user_id() where id = x$pension;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id', x$pension);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
