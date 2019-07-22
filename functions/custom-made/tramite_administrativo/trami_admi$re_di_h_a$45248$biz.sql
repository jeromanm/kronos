create or replace function trami_admi$re_di_h_a$45248$biz(x$super number, x$tramite number, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg         nvarchar2(2000);
    v$estado        number;
    v$tipo          number;
begin
    begin --  13.-revertir dictamen otorgar
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
    if v$estado<>5 then
      raise_application_error(v$err,'Error: el trámite no está en estado otorgable.', true);
    end if;
    begin
      update tramite_administrativo set observaciones = x$observaciones, fecha_transicion = current_date, usuario_transicion = util.current_user_id(),
                                        estado=1
      where id = x$tramite;
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
