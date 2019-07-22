exec xsp.dropone('function', 'rastro_proceso_temporal$insert');
create or replace function rastro_proceso_temporal$insert(x$super number) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid varchar2(146); -- 48*3+2 for nnnnnnnnn.nnnnnnnnn.nnnnnnnnnnn would be "safe"
--  v$log rastro_proceso_temporal%ROWTYPE;
    v$cef constant enums.condicion_eje_fun := condicion_eje_fun$enum();
    v$gcr constant types.global_constant_record := global$constant$record();
begin
    if (x$super is not null and x$super > 0) then
        v$xid := dbms_transaction.local_transaction_id(true);
        if v$xid is null then
            v$msg := util.gettext('no existe una transaccion asociada a este proceso');
            raise_application_error(v$err, v$msg, true);
        end if;
        v$msg := util.gettext('funcion ejecutada exitosamente');
        if (v$gcr.rastro_proceso_temporal <> 0) then
            insert into rastro_proceso_temporal
            select v$xid as transaction$xid, rastro_proceso.* from rastro_proceso where id_rastro_proceso = x$super;
            if not SQL%FOUND then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rastro de proceso', 'id', x$super);
                raise_application_error(v$err, v$msg, true);
            end if;
            update rastro_proceso_temporal
            set numero_condicion_eje_fun = v$cef.EJECUTADO_SIN_ERRORES, descripcion_error = v$msg
            where id_rastro_proceso = x$super;
            if not SQL%FOUND then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rastro de proceso temporal', 'id', x$super);
                raise_application_error(v$err, v$msg, true);
            end if;
        else
            update rastro_proceso
            set numero_condicion_eje_tem = v$cef.EJECUTADO_SIN_ERRORES, descripcion_error_tem = v$msg, ultima_transaccion = v$xid, transacciones = transacciones + 1
            where id_rastro_proceso = x$super;
            if not SQL%FOUND then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rastro de proceso', 'id', x$super);
                raise_application_error(v$err, v$msg, true);
            end if;
        end if;
    end if;
    return 0;
end;
/
show errors
