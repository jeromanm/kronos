exec xsp.dropone('procedure', 'rastro_proceso_temporal$revive');
create or replace procedure rastro_proceso_temporal$revive(x$log IN OUT rastro_proceso_temporal%ROWTYPE) is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid varchar2(146); -- 48*3+2 for nnnnnnnnn.nnnnnnnnn.nnnnnnnnnnn would be "safe"
--  v$log rastro_proceso_temporal%ROWTYPE;
    v$cef constant enums.condicion_eje_fun := condicion_eje_fun$enum();
    v$gcr constant types.global_constant_record := global$constant$record();
begin
    if (x$log.transaction$xid is not null) then
        v$xid := dbms_transaction.local_transaction_id(true);
        if v$xid is null then
            v$msg := util.gettext('no existe una transaccion asociada a este proceso');
            raise_application_error(v$err, v$msg, true);
        end if;
        if (v$gcr.rastro_proceso_temporal <> 0) then
            insert into rastro_proceso_temporal values x$log;
            update rastro_proceso_temporal
            set transaction$xid = v$xid
            where id_rastro_proceso = x$log.id_rastro_proceso;
            if not SQL%FOUND then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rastro de proceso temporal', 'id', x$log.id_rastro_proceso);
                raise_application_error(v$err, v$msg, true);
            end if;
        else
            update  rastro_proceso
            set     numero_condicion_eje_tem = x$log.numero_condicion_eje_fun,
                    nombre_archivo_tem = x$log.nombre_archivo,
                    descripcion_error_tem = x$log.descripcion_error,
                    ultima_transaccion = v$xid,
                    transacciones = transacciones + 1
            where   id_rastro_proceso = x$log.id_rastro_proceso;
            if not SQL%FOUND then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rastro de proceso', 'id', x$log.id_rastro_proceso);
                raise_application_error(v$err, v$msg, true);
            end if;
        end if;
        x$log.transaction$xid := v$xid;
    end if;
end;
/
show errors
