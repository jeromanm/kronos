create or replace function recla_pens$re_di_den$94266$biz(x$super number, x$reclamo number, x$resumen nvarchar2, x$antecedente_denegar nvarchar2, x$antecedente_denegar_uno nvarchar2, x$disposicion_den_uno nvarchar2, 
                                                          x$disposicion_den_dos nvarchar2, x$disposicion_den_tres nvarchar2, x$opinion_den_uno nvarchar2, x$opinion_den_dos nvarchar2, 
                                                          x$opinion_den_tres nvarchar2, x$causa number, x$otras_causas nvarchar2, x$observaciones nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$pension             number;
    v$tipo                number;
    err_msg               nvarchar2(2000);
    v$estado              number;
    v$nro_dictamen        varchar2(50);
    v$estado_final        number;
    v$inserta_transicion  number;
    v$fecha_dictamen      date;
    v$tiene_objecion      varchar2(5):='false';
begin
    begin --1.-registrar dictamen para reconsiderar denegar:
      Select re.estado, re.tipo, pn.tiene_objecion
        into v$estado, v$tipo, v$tiene_objecion
      From reclamo_pension re inner join pension pn on re.pension = pn.id 
      where re.id = x$reclamo;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$estado:=0;
    when others then
      v$estado:=0;
      err_msg := SUBSTR(SQLERRM, 1, 200);
			v$msg := util.format(util.gettext('Error al intentar actualizar el %s, mensaje %s'), 'trámite pensión', err_msg);
      raise_application_error(v$err, v$msg, true);
    end;
    if v$estado<>1 then
      raise_application_error(v$err,'Error: el trámite no está en estado pendiente.', true);
    end if;
    if v$tipo<>1 And v$tipo<>2 then --solo reconsiderar
      raise_application_error(v$err,'Error: el trámite no es del tipo aceptado.', true);
    end if;
    --if v$tiene_objecion<>'true' then comentado por SIAU 12323 
    --  raise_application_error(v$err,'Error: la pensión no tiene objecion.', true);
    --end if;
    begin
      Update reclamo_pension set resumen_dictamen_denegar = x$resumen, antecedente_denegar = x$antecedente_denegar, antecedente_denegar_uno=x$antecedente_denegar_uno, 
                                disposicion_den_uno = x$disposicion_den_uno, disposicion_den_dos = x$disposicion_den_dos, 
                                disposicion_den_tres = x$disposicion_den_tres, opinion_den_uno = x$opinion_den_uno, opinion_den_dos = x$opinion_den_dos, 
                                opinion_den_tres = x$opinion_den_tres, causa_denegar = x$causa, otras_causas_denegar = x$otras_causas, 
                                observaciones = x$observaciones, estado = 2, fecha_transicion = current_date, usuario_transicion = util.current_user_id() 
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
    /*if (v$tipo=1 or v$tipo=2) And (v$estado=5 or v$estado=7) then
      if (v$estado=7) then 
        v$estado_final := 4;--denegable
        Update pension set estado=v$estado_final, fecha_transicion=sysdate, usuario_transicion=CURRENT_USER_ID
        Where id=v$pension;
        v$inserta_transicion := transicion_pension$biz(v$pension, v$fecha_dictamen, CURRENT_USER_ID, v$estado, v$estado_final, null, null, x$observaciones, v$nro_dictamen, v$fecha_dictamen, x$resumen, null, null, null);
      end if;
    else
      raise_application_error(v$err,'Error: la pensión no está en estado denegada/otorgada (' || v$estado || ') o el tipo de trámite no es reconsiderar(' || v$tipo || ').', true);
    end if;*/
    return 0;
end;
/