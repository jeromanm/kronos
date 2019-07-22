create or replace function pension$inactivar$biz(x$super number, x$pension number, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
--  v$log rastro_proceso_temporal%ROWTYPE;
--  inactivar pension
begin
--
--  Pension.inactivar - business logic
--
    update pension set observaciones_inactivar = x$observaciones, activa = 'false', fecha_inactivar = current_date, usuario_inactivar = util.current_user_id() where id = x$pension;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id', x$pension);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
