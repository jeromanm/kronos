create or replace function pension$revocar$biz(x$super number, x$pension number,
                                               x$resolucion nvarchar2, x$fecha date,
                                               x$resumen nvarchar2, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
	-- registrar resolucion para revocar
    v$xid varchar2(146);
    v$log rastro_proceso_temporal%ROWTYPE;
    v$inserta_transicion number;
    v$estado_inicial     number;
    v$estado_final       number;
    err_num              NUMBER;
    err_msg              VARCHAR2(255);
begin
     v$estado_inicial := pension$estado$inicial$biz(x$pension);
     v$estado_final   := 9;
    update pension
             set resolucion_revocar = x$resolucion,
             fecha_resolucion_revocar = x$fecha,
             resumen_resolucion_revocar = x$resumen,
             observaciones = x$observaciones, estado = 9,
             fecha_transicion = current_date,
             usuario_transicion = util.current_user_id(),
             activa = 'false', FECHA_INACTIVAR=sysdate 
    where id = x$pension;
      v$inserta_transicion := transicion_pension$biz(x$pension,
                              current_date,
                              current_user_id(),
                              v$estado_inicial,
                              v$estado_final,
                              null,
                              null,
                              x$observaciones,
                              null,
                              null,
                              null,
                              x$resolucion,
                              x$fecha,
                              null);

    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pension', 'id', x$pension);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
    exception
        when others then
           err_num := SQLCODE;
           err_msg := SQLERRM;
           raise_application_error(-20001, err_msg, true);
end;
/
