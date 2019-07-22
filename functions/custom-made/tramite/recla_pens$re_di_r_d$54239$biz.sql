create or replace function recla_pens$re_di_r_d$54239$biz(x$super number, x$reclamo number, x$resu_dicta_rein_dene nvarchar2, x$antecedente_rein_dene nvarchar2, x$antecedente_rein_dene_uno nvarchar2,
                                                          x$disposicion_rein_uno nvarchar2, x$disposicion_rein_dos nvarchar2, x$disposicion_rein_tres nvarchar2, x$opinion_rein_uno nvarchar2, x$opinion_rein_dos nvarchar2,
                                                          x$opinion_rein_tres nvarchar2, x$causa number, x$otras_causas nvarchar2, x$observaciones nvarchar2) return number is
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$pension         number;
    v$tipo            number;
    err_msg           nvarchar2(2000);
    v$estado          number;
    v$nro_dictamen    varchar2(50);
    v$tiene_objecion  varchar2(5):='false';
begin
    begin --3.-registrar dictamen para reintegrar denegar:
      Select re.estado, re.tipo, pn.tiene_objecion
        into v$estado, v$tipo, v$tiene_objecion 
      From  reclamo_pension re inner join pension pn on re.pension = pn.id
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
      raise_application_error(v$err,'Error: el trámite no está en estado solicitado.', true);
    end if;
    if v$tipo<>3 then --solo reintegrar
      raise_application_error(v$err,'Error: el trámite no es del tipo aceptado.', true);
    end if;
    if v$tiene_objecion<>'true' then
      raise_application_error(v$err,'Error: la pensión no tiene objecion.', true);
    end if;
    begin
      Update reclamo_pension set resu_dicta_rein_dene = x$resu_dicta_rein_dene, antecedente_rein_dene = x$antecedente_rein_dene, antecedente_rein_dene_uno=x$antecedente_rein_dene_uno,
                                  disposicion_rein_uno = x$disposicion_rein_uno, disposicion_rein_dos = x$disposicion_rein_dos,
                                  disposicion_rein_tres = x$disposicion_rein_tres, opinion_rein_uno = x$opinion_rein_uno,
                                  opinion_rein_dos = x$opinion_rein_dos, opinion_rein_tres = x$opinion_rein_tres,
                                  causa_denegar = x$causa, otras_causas_denegar = x$otras_causas, observaciones = x$observaciones,
                                  estado = 2, fecha_transicion = current_date, usuario_transicion = util.current_user_id()
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
