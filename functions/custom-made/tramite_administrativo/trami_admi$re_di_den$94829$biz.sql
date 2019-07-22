create or replace function trami_admi$re_di_den$94829$biz(x$super number, x$tramite number, x$resumen_dictamen_denegar nvarchar2, x$antecedente_dene nvarchar2, 
                                                          x$antecedente_dene_uno nvarchar2, x$disposicion_dene_uno nvarchar2, x$disposicion_dene_dos nvarchar2, 
                                                          x$disposicion_dene_tres nvarchar2, x$opinion_dene_uno nvarchar2, x$opinion_dene_dos nvarchar2, x$opinion_dene_tres nvarchar2, 
                                                          x$causa number, x$otras_causas nvarchar2, x$observaciones nvarchar2) return number is
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg           nvarchar2(2000);
    v$estado          number;
    v$tipo            number;
    v_dictamen        varchar2(20);
    v$tiene_objecion  varchar2(5):='false';
begin
    begin --  TramiteAdministrativo.registrarDictameDenegar - business logic
      Select ta.estado, ta.tipo, pn.tiene_objecion 
        into v$estado, v$tipo, v$tiene_objecion
      From  tramite_administrativo ta inner join pension pn on ta.pension = pn.id 
      where ta.id = x$tramite;
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
    if v$tiene_objecion<>'true' And v$tipo=6 then
      raise_application_error(v$err,'Error: la pensión no tiene objecion.', true);
    end if;
    Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
    Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into v_dictamen From variable_global Where numero=115;
    begin
      update tramite_administrativo set fecha_transicion = current_date, usuario_transicion = util.current_user_id(), estado=7,
                                      ANTECEDENTE_DENE=x$antecedente_dene, ANTECEDENTE_DENE_UNO=x$antecedente_dene_uno, CAUSA_DENEGAR=x$causa,
                                      DICTAMEN_DENEGAR=v_dictamen, DISPOSICION_DENE_DOS=x$disposicion_dene_dos, DISPOSICION_DENE_TRES=x$disposicion_dene_tres,
                                      DISPOSICION_DENE_UNO=x$disposicion_dene_uno, FECHA_DICTAMEN_DENEGAR=sysdate, OPINION_DENE_DOS=x$opinion_dene_dos, 
                                      OPINION_DENE_TRES=x$opinion_dene_tres, OPINION_DENE_UNO=x$opinion_dene_uno, OBSERVACIONES=x$observaciones,
                                      OTRAS_CAUSAS_DENEGAR=x$otras_causas
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
