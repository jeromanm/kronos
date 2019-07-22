create or replace function recla_pens$re_re_r_d$24162$biz(x$super number, x$reclamo number, x$resol_rein_denegar nvarchar2, x$fecha_resol_rein_denegar date, 
                                                          x$resum_resol_rein_dengar nvarchar2, x$observaciones nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$pension             number;
    v$tipo                number;
    err_msg               nvarchar2(2000);
    v$estado              number;
begin
    begin --7.-registrar resolucion para reintegrar denegar:
      Select estado, tipo 
        into v$estado, v$tipo 
      From reclamo_pension where id = x$reclamo;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$estado:=0;
    when others then
      v$estado:=0;
      err_msg := SUBSTR(SQLERRM, 1, 200);
			v$msg := util.format(util.gettext('Error al intentar actualizar el %s, mensaje %s'), 'trámite pensión', err_msg);
      raise_application_error(v$err, v$msg, true);
    end;
    if v$estado<>2 then
      raise_application_error(v$err,'Error: el trámite no está en estado denegable.', true);
    end if;
    if v$tipo<>3 then --solo reintegrar
      raise_application_error(v$err,'Error: el trámite no es del tipo aceptado.', true);
    end if;
    begin
      Update reclamo_pension set resol_rein_denegar = x$resol_rein_denegar, fecha_resol_rein_denegar = x$fecha_resol_rein_denegar, 
                                resumen_resolucion_denegar = x$resum_resol_rein_dengar, observaciones = x$observaciones, 
                                fecha_transicion = current_date, usuario_transicion = util.current_user_id(), estado=3 
      Where id = x$reclamo;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'trámite de pensión', 'id', x$reclamo);
      raise_application_error(v$err, v$msg, true);
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 200);
			v$msg := util.format(util.gettext('Error al intentar actualizar el %s, mensaje %s'), 'trámite pensión', err_msg);
      raise_application_error(v$err, v$msg, true);
    end;
    begin
      Select a.pension, a.tipo, b.estado
        into v$pension, v$tipo, v$estado
      From reclamo_pension a inner join pension b on a.pension = b.id
      Where a.id=x$reclamo;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$pension:=null;
    when others then
      v$pension:=null;
      err_msg := SUBSTR(SQLERRM, 1, 2000);
			v$msg := util.format(util.gettext('Error al intentar obtener el id de la %s, mensaje %s'), 'pensión',err_msg );
      raise_application_error(v$err, v$msg, true);
    end;
    /*if v$tipo=3 And v$estado=9 then
      null;
    else
      raise_application_error(v$err,'Error: la pensión no está en estado revocada o el tipo de trámite no es reintegrar.', true);
    end if;*/
    return 0;
end;
/
