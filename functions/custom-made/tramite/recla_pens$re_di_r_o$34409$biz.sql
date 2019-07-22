create or replace function recla_pens$re_di_r_o$34409$biz(x$super number, x$reclamo number, x$observaciones nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$pension             number;
    v$tipo                number;
    err_msg               nvarchar2(2000);
    v$estado              number;
    v$estado_final        number;
    v$inserta_transicion  number;
begin
    begin --12.-revertir dictamen para reintegrar otorgar:
      Select estado, tipo 
        into v$estado, v$tipo
      From  reclamo_pension where id = x$reclamo;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$estado:=0;
    when others then
      v$estado:=0;
      err_msg := SUBSTR(SQLERRM, 1, 200);
			v$msg := util.format(util.gettext('Error al intentar actualizar el %s, mensaje %s'), 'trámite pensión', err_msg);
      raise_application_error(v$err, v$msg, true);
    end;
    if v$estado<>4 then
      raise_application_error(v$err,'Error: el trámite no está en estado otorgable.', true);
    end if;
    if v$tipo<>3 then --solo reintegrar
      raise_application_error(v$err,'Error: el trámite no es del tipo aceptado.', true);
    end if;
    begin
      update reclamo_pension set observaciones = x$observaciones, estado = 1, fecha_transicion = current_date, usuario_transicion = util.current_user_id() where id = x$reclamo;
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
    /*if v$tipo=3 And v$estado=6 then
      v$estado_final := 9;--revocada
      Update pension set estado=v$estado_final, fecha_transicion=sysdate, usuario_transicion=CURRENT_USER_ID
      Where id=v$pension;
      v$inserta_transicion := transicion_pension$biz(v$pension, current_date, NULL, v$estado, v$estado_final, null, null, x$observaciones, null, null, null, null, null, null);
    else
      raise_application_error(v$err,'Error: la pensión no está en estado otorgable o el tipo de trámite no es reintegrar.', true);
    end if;*/
    return 0;
end;
/
