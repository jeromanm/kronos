create or replace function trami_admi$re_re_den$35193$biz(x$super number, x$tramite number, x$resolucion nvarchar2, x$fecha date, x$resumen nvarchar2, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg         nvarchar2(2000);
    v$estado        number;
    v$tipo          number;
begin
    begin --TramiteAdministrativo.registrarResolucionDenegar - business logic
      Select estado, tipo 
        into v$estado, v$tipo 
      From  tramite_administrativo where id = x$tramite;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$estado:=0;
    when others then
      v$estado:=0;
      err_msg := SUBSTR(SQLERRM, 1, 200);
			v$msg := util.format(util.gettext('Error al intentar actualizar el %s, mensaje %s'), 'trámite pensión', err_msg);
      raise_application_error(v$err, v$msg, true);
    end;
    if v$estado<>7 then
      raise_application_error(v$err,'Error: el trámite no está en estado denegable.', true);
    end if;
    begin
      Update tramite_administrativo set fecha_transicion = current_date, usuario_transicion = util.current_user_id(), FECHA_RESOLUCION_DENEGAR=x$fecha,
                                        RESUMEN_RESOLUCION_DENEGAR=x$resumen, RESOLUCION_DENEGAR=x$resolucion, estado=2
      Where id = x$tramite;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'trámite administrativo de pensión', 'id', x$tramite);
      raise_application_error(v$err, v$msg, true);
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 200);
			v$msg := util.format(util.gettext('Error al intentar actualizar el %s, mensaje %s'), 'trámite administrativo de pensión', err_msg);
      raise_application_error(v$err, v$msg, true);
    end;
    return 0;
end;
/