create or replace function recla_pens$re_di_r_o$44279$biz(x$super number, x$reclamo number, x$resu_dict_reco_otor nvarchar2, x$antecedente_reco_oto nvarchar2, x$antecedente_reco_oto_uno nvarchar2,
                                                          x$disposicion_reco_oto_uno nvarchar2, x$disposicion_reco_oto_dos nvarchar2, 
                                                          x$disposicion_reco_oto_tres nvarchar2, x$opinion_reco_oto_uno nvarchar2, x$opinion_reco_oto_dos nvarchar2, 
                                                          x$opinion_reco_oto_tres nvarchar2, x$observaciones nvarchar2) return number is
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
    begin --4.-registrar dictamen para reintegrar otorgar:
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
    if v$estado<>1 then
      raise_application_error(v$err,'Error: el trámite no está en estado pendiente.', true);
    end if;
    if v$tipo<>3 then --solo reintegrar
      raise_application_error(v$err,'Error: el trámite no es del tipo aceptado.', true);
    end if;
    begin
      Update reclamo_pension set resu_dict_reco_otor = x$resu_dict_reco_otor, antecedente_reco_oto = x$antecedente_reco_oto, antecedente_reco_oto_uno=x$antecedente_reco_oto_uno,
                                  disposicion_reco_oto_uno = x$disposicion_reco_oto_uno, disposicion_reco_oto_dos = x$disposicion_reco_oto_dos, 
                                  disposicion_reco_oto_tres = x$disposicion_reco_oto_tres, opinion_reco_oto_uno = x$opinion_reco_oto_uno, 
                                  opinion_reco_oto_dos = x$opinion_reco_oto_dos, opinion_reco_oto_tres = x$opinion_reco_oto_tres, 
                                  observaciones = x$observaciones, estado = 4, fecha_transicion = current_date, usuario_transicion = util.current_user_id() 
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
      Select a.pension, a.tipo, b.estado, a.DICTAMEN_OTORGAR, a.FECHA_DICTAMEN_OTORGAR
        into v$pension, v$tipo, v$estado, v$nro_dictamen, v$fecha_dictamen
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
      v$estado_final := 6;--otorgable
      Update pension set estado=v$estado_final, fecha_transicion=sysdate, usuario_transicion=CURRENT_USER_ID
      Where id=v$pension;
      v$inserta_transicion := transicion_pension$biz(v$pension, v$fecha_dictamen, NULL, v$estado, v$estado_final, null, null, x$observaciones, v$nro_dictamen, v$fecha_dictamen, x$resu_dict_reco_otor, null, null, null);
    else
      raise_application_error(v$err,'Error: la pensión no está en estado revocada o el tipo de trámite no es reintegrar.', true);
    end if;*/
    return 0;
end;
/
