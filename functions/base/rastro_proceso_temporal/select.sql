exec xsp.dropone('function', 'rastro_proceso_temporal$select');
create or replace function rastro_proceso_temporal$select return rastro_proceso_temporal%ROWTYPE is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid varchar2(146); -- 48*3+2 for nnnnnnnnn.nnnnnnnnn.nnnnnnnnnnn would be "safe"
    v$log rastro_proceso_temporal%ROWTYPE;
    v$cef constant enums.condicion_eje_fun := condicion_eje_fun$enum();
    v$gcr constant types.global_constant_record := global$constant$record();
    v$ago timestamp;
begin
    v$xid := dbms_transaction.local_transaction_id;
    if v$xid is null then
        v$msg := util.gettext('no existe una transaccion asociada a este proceso');
        raise_application_error(v$err, v$msg, true);
    end if;
    if (v$gcr.rastro_proceso_temporal <> 0) then
        begin
            select * into v$log from rastro_proceso_temporal where transaction$xid = v$xid;
        exception
            when no_data_found then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rastro de proceso temporal', 'transaccion', v$xid);
                raise_application_error(v$err, v$msg, true);
        end;
    else
        v$ago := util.dateadd(trunc(current_date), -1, 'W');
        begin
            select v$xid as transaction$xid, rastro_proceso.*
            into v$log
            from rastro_proceso
            where ultima_transaccion = v$xid
            and numero_condicion_eje_fun in (v$cef.EJECUCION_PENDIENTE, v$cef.EJECUCION_EN_PROGRESO) and fecha_hora_inicio_ejecucion > v$ago;
        /**/
        v$log.numero_condicion_eje_fun := v$log.numero_condicion_eje_tem;
        v$log.nombre_archivo := v$log.nombre_archivo_tem;
        v$log.descripcion_error := v$log.descripcion_error_tem;
        exception
            when no_data_found then
                v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rastro de proceso', 'transaccion', v$xid);
                raise_application_error(v$err, v$msg, true);
        end;
    end if;
    return v$log;
end;
/
show errors
