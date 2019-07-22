create or replace function pension$reg_dic_sent$13449$biz(x$super number, x$pension number,x$resumen_dictamen_sent nvarchar2, x$antecedente_sent nvarchar2, x$antecedente_sent_uno nvarchar2,
                                                        x$disposicion_sent_uno nvarchar2, x$disposicion_sent_dos nvarchar2, x$disposicion_sent_tres nvarchar2, x$opinion_sent_uno nvarchar2,
                                                        x$opinion_sent_dos nvarchar2, x$opinion_sent_tres nvarchar2, x$observaciones nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg               varchar2(200);
    x$tiporeclamo	        number;
    x$edopension          number;
    x$edoreclamo          number;
    v$estado_inicial      number;
    v$estado_final        number;
    v$inserta_transicion  number;
    v_dictamen_otorgar    VARCHAR2(255);
begin -- registrar dictamen sentencia 
    begin
      Select pn.estado as edopension, rp.estado as edoreclamo
         	into x$edopension, x$edoreclamo
      From pension pn inner join reclamo_pension rp on pn.id = rp.pension
         where pn.id=x$pension And rp.tipo<>4;
    Exception
	  WHEN NO_DATA_FOUND THEN
      v$msg := util.format(util.gettext('Error: no se consigue %s de la %s'), 'reclamo denegado', 'pensión');
      raise_application_error(v$err, v$msg, true);
    when others then
	    err_msg := SUBSTR(SQLERRM, 1, 200);
      v$msg := util.format(util.gettext('Error al intentar obtener el %s, mensaje %s'), 'estado del reclamo',err_msg );
	    raise_application_error(v$err, v$msg, true);
	  end;
		if x$edopension<>5 or x$edoreclamo<>3 then
        v$msg := util.format(util.gettext('Error el estado de la %s no está¡ %s (%s), o el %s no está¡ %s (%s).'), 'pensión','denegado', x$edopension, 'reclamo asociado', x$edoreclamo);
	      raise_application_error(v$err, v$msg, true);
    end if;
    v$estado_inicial := x$edopension;
    v$estado_final   := 6;
    Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
    Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into v_dictamen_otorgar From variable_global Where numero=115;
    Update pension set resumen_dictamen_sent = x$resumen_dictamen_sent, antecedente_sent = x$antecedente_sent, disposicion_sent_uno = x$disposicion_sent_uno, 
                       disposicion_sent_dos = x$disposicion_sent_dos, disposicion_sent_tres = x$disposicion_sent_tres, opinion_sent_uno = x$opinion_sent_uno, 
                       opinion_sent_dos = x$opinion_sent_dos, opinion_sent_tres = x$opinion_sent_tres, DICTAMEN_SENT=v_dictamen_otorgar, FECHA_DICTAMEN_SENT=current_date,
                       observaciones = x$observaciones, estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = util.current_user_id(),
                       antecedente_sent_uno=x$antecedente_sent_uno
    Where id = x$pension;
    v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, x$resumen_dictamen_sent, null, x$observaciones,
                                                  v_dictamen_otorgar, current_date, x$resumen_dictamen_sent, null, null, null);
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id', x$pension);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
