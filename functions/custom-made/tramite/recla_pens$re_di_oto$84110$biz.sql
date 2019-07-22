create or replace function recla_pens$re_di_oto$84110$biz(x$super number, x$reclamo number, x$observaciones nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$pension             number;
    v$tipo                number;
    err_msg               nvarchar2(2000);
    v$estado              number;
    v$nro_dictamen        varchar2(50);
    v$estado_final        number;
    v$fecha_dictamen      date;
    v$inserta_transicion  number;
begin
    begin --10.-revertir dictamen para reconsiderar otorgar
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
    if v$tipo<>1 And v$tipo<>2 then --solo reconsiderar
      raise_application_error(v$err,'Error: el trámite no es del tipo aceptado.', true);
    end if;
    begin
      update reclamo_pension set observaciones = x$observaciones, estado = 1, fecha_transicion = current_date, usuario_transicion = util.current_user_id() 
      where id = x$reclamo;
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
      Select a.pension, a.tipo, b.estado, a.FECHA_DICTAMEN_DENEGAR, a.DICTAMEN_DENEGAR
        into v$pension, v$tipo, v$estado, v$fecha_dictamen, v$nro_dictamen
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
    /*if (v$tipo=1 or v$tipo=2) And (v$estado=6 or v$estado=7) then
      if (v$estado=6) then 
        v$estado_final := 5;--denegada
        Update pension set estado=v$estado_final, fecha_transicion=sysdate, usuario_transicion=CURRENT_USER_ID
        Where id=v$pension;
        v$inserta_transicion := transicion_pension$biz(v$pension, v$fecha_dictamen, CURRENT_USER_ID, v$estado, v$estado_final, null, null, x$observaciones, v$nro_dictamen, v$fecha_dictamen, null, null, null, null);
      end if;
    else
      raise_application_error(v$err,'Error: la pensión no está en estado otorgada/otorgable (' || v$estado || ') o el tipo de trámite no es reconsiderar(' || v$tipo || ').', true);
    end if;*/
    return 0;
end;
/
