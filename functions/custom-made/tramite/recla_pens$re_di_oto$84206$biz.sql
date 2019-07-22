create or replace function recla_pens$re_di_oto$84206$biz(x$super number, x$reclamo number, x$resumen nvarchar2, x$antecedente_dic_oto nvarchar2, x$antecedente_dic_oto_uno nvarchar2,
                                                          x$disposicion_dic_oto_uno nvarchar2, x$disposicion_dic_oto_dos nvarchar2, 
                                                          x$disposicion_dic_oto_tres nvarchar2, x$opinion_dic_oto_uno nvarchar2, 
                                                          x$opinion_dic_oto_dos nvarchar2, x$opinion_dic_oto_tres nvarchar2, x$observaciones nvarchar2) return number is
    v$err           constant number := -20000; -- an integer in the range -20000..-20999
    v$msg           nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$pension       number;
    v$tipo          number;
    err_msg         nvarchar2(2000);
    v$estado              number;
    v$nro_dictamen        varchar2(50);
    v$estado_final        number;
    v$inserta_transicion  number;
    v$fecha_dictamen      date;
begin
    begin --  2.-registrar dictamen para reconsiderar otorgar:
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
    if v$tipo<>1 And v$tipo<>2 then --solo reconsiderar
      raise_application_error(v$err,'Error: el trámite no es del tipo aceptado.', true);
    end if;
    begin
      Update reclamo_pension set resumen_dictamen_otorgar = x$resumen, antecedente_dic_oto = x$antecedente_dic_oto, antecedente_dic_oto_uno=x$antecedente_dic_oto_uno,
                                  disposicion_dic_oto_uno = x$disposicion_dic_oto_uno, disposicion_dic_oto_dos = x$disposicion_dic_oto_dos, 
                                  disposicion_dic_oto_tres = x$disposicion_dic_oto_tres, opinion_dic_oto_uno = x$opinion_dic_oto_uno, 
                                  opinion_dic_oto_dos = x$opinion_dic_oto_dos, opinion_dic_oto_tres = x$opinion_dic_oto_tres, 
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
      if (v$estado=5) then 
        v$estado_final := 6;--denegable
        Update pension set estado=v$estado_final, fecha_transicion=sysdate, usuario_transicion=CURRENT_USER_ID
        Where id=v$pension;
        v$inserta_transicion := transicion_pension$biz(v$pension, v$fecha_dictamen, NULL, v$estado, v$estado_final, null, null, x$observaciones, v$nro_dictamen, v$fecha_dictamen, x$resumen, null, null, null);
      end if;
    else
      raise_application_error(v$err,'Error: la pensión no está en estado denegada/otorgada (' || v$estado || ') o el tipo de trámite no es reconsiderar(' || v$tipo || ').', true);
    end if;*/
    return 0;
end;
/
