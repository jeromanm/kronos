create or replace function trami_admi$re_di_h_a$65230$biz(x$super number, x$tramite number, x$resum_dicta_habe_atras_43036 nvarchar2, 
                                                          x$antecedente_habe_atr nvarchar2, x$antecedente_habe_atr_uno nvarchar2, x$disposicion_habe_atr_uno nvarchar2, 
                                                          x$disposicion_habe_atr_dos nvarchar2, x$disposicion_habe_atr_tres nvarchar2, 
                                                          x$opinion_habe_atr_uno nvarchar2, x$opinion_habe_atr_dos nvarchar2, x$opinion_habe_atr_tres nvarchar2) return number is
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg           nvarchar2(2000);
    v$estado          number;
    v$estado_pension  number;
    v$pension         number;
    v$tipo            number;
    v_dictamen        varchar2(20);
    v$cantidad        number;
begin
    begin --registrar dictamen otorgar
      Select ta.estado, ta.tipo, pn.id, pn.estado 
        into v$estado, v$tipo, v$pension, v$estado_pension
      From  tramite_administrativo ta inner join pension pn on ta.pension = pn.id 
      where ta.id = x$tramite;
      Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
      Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into v_dictamen From variable_global Where numero=115;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$estado:=0;
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 2000);
			raise_application_error(v$err,'Error al intentar obtener el estado del trámite y su pensión, mensaje:' || err_msg,true);
    end;
    if v$estado<>1 then
      raise_application_error(v$err,'Error: el trámite no está en estado pendiente.', true);
    end if;
    if v$estado_pension<>9 And v$tipo=6 then
      raise_application_error(v$err,'Error: la pensión no está en estado revocada.', true);
    end if;
    if v$estado_pension=9 And v$tipo<>6 then
      raise_application_error(v$err,'Error: el tipo de trámite no es de reconsideración.', true);
    end if;
    begin
      Select Count(dp.id) into v$cantidad 
      From resumen_pago_pension rp inner join detalle_pago_pension dp on rp.id = dp.resumen And dp.activo='true'
      Where rp.pension = v$pension;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$cantidad:=0;
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 2000);
			raise_application_error(v$err,'Error al intentar obtener los detalles de pago de la pensión asociada al trámite, mensaje:' || err_msg,true);
    end;
    if (v$cantidad>0 And v$tipo=6) then
      raise_application_error(v$err,'Error: la pensión (' || v$pension || ') asociada al trámite tiene ' || v$cantidad || ' registros de detalle de pago, no puede ser reconsiderada.', true);
    end if;
    begin
      update tramite_administrativo set resumen_dictamen_habe_atrasado = x$resum_dicta_habe_atras_43036, antecedente_habe_atr = x$antecedente_habe_atr, FECHA_DICTAMEN_HABE_ATRASADO=sysdate,
                                      disposicion_habe_atr_uno = x$disposicion_habe_atr_uno, disposicion_habe_atr_dos = x$disposicion_habe_atr_dos, DICTAMEN_HABE_ATRASADO=v_dictamen,
                                      disposicion_habe_atr_tres = x$disposicion_habe_atr_tres, opinion_habe_atr_uno = x$opinion_habe_atr_uno,
                                      opinion_habe_atr_dos = x$opinion_habe_atr_dos, opinion_habe_atr_tres = x$opinion_habe_atr_tres, fecha_transicion = current_date,
                                      antecedente_habe_atr_uno=x$antecedente_habe_atr_uno, usuario_transicion = util.current_user_id(), estado=5
      where id = x$tramite;
    Exception
    WHEN NO_DATA_FOUND THEN
      raise_application_error(v$err,'Error: no se consiguen datos del trámite a actualizar, id trámite:' || x$tramite,true);
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 2000);
			raise_application_error(v$err,'Error al intentar actualizar el estado del trámite, mensaje:' || err_msg,true);
    end;
    return 0;
end;
/
