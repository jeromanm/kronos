create or replace function lote$regi_dict_otorg$33144$biz(x$super number, x$lote number, x$resumen_dictamen_otorgar nvarchar2, x$antecedente_oto nvarchar2, x$antecedente_oto_uno nvarchar2, x$disposicion_oto_uno nvarchar2,
                                                          x$disposicion_oto_dos nvarchar2, x$disposicion_oto_tres nvarchar2, x$opinion_oto_uno nvarchar2, x$opinion_oto_dos nvarchar2,
                                                          x$opinion_oto_tres nvarchar2, x$observaciones nvarchar2) return number is
  v$err                     constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log rastro_proceso_temporal%ROWTYPE;
  err_msg                   VARCHAR2(255);
  v$inserta_transicion      number;
  v$estado_inicial          number;
  v$estado_final            number;
  v$falta_requisito         VARCHAR2(5);
  v$no_compatible           VARCHAR2(5);
  v$dictamen_otorgar        VARCHAR2(255);
  contador                  number:=0;
  contadord                 number:=0;
  contadorp                 number:=0;
  v$observacion             VARCHAR2(200);
  v$tiene_objecion          varchar2(5):='false';
begin
  Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
  Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into v$dictamen_otorgar From variable_global Where numero=115;
  For reg in (Select lp.pension, pn.estado, ep.codigo as strestado, pe.codigo as cedula, pe.id as solicitante, pn.clase
              From lote l, lote_pension lp, pension pn, estado_pension ep, persona pe
              Where l.id = lp.lote And lp.pension = pn.id
                And pn.estado = ep.numero And pn.persona = pe.id
                And l.id = x$lote And lp.excluir='false') loop
    if reg.estado<>3 then
      contadord:=contadord+1;
    else
      v$tiene_objecion:='false'; v$falta_requisito:='false'; v$no_compatible:='false';
      begin
        Select tiene_objecion, falta_requisito into v$tiene_objecion, v$falta_requisito
        From pension where id = reg.pension;
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 255);
        v$msg := util.format(util.gettext('Error al intentar registrar la resolución para otorgar de la pensión %s , mensaje: %s'), reg.pension, err_msg);
        raise_application_error(v$err, v$msg, true);
      end;
      For reg1 in (Select a.compatible, b.nombre as clase, d.id
                From clase_pension_comp a inner join clase_pension b on a.clase = b.id
                  inner join pension c on b.id = c.clase
                  inner join clase_pension d on a.clase_comp = d.id
                Where c.persona=reg.solicitante And c.id<> reg.pension
                  And c.estado not in (2, 5, 10, 9)) --anulada, denegada, finalizada, revocada
      loop
        if reg1.compatible='false' And reg1.id=reg.clase Then
          v$no_compatible:='true'; exit;
        end if;
      end loop;
      if v$tiene_objecion='true' or v$falta_requisito='true' or v$no_compatible='true'  then
        contadord:=contadord+1;
      else
        begin
          v$estado_final:=6;
          Update pension set resumen_dictamen_otorgar =  x$resumen_dictamen_otorgar, antecedente_oto = x$antecedente_oto, antecedente_oto_uno=x$antecedente_oto_uno,
                              disposicion_oto_uno = x$disposicion_oto_uno, disposicion_oto_dos = x$disposicion_oto_dos, fecha_dictamen_otorgar=current_date,
                              disposicion_oto_tres = x$disposicion_oto_tres, opinion_oto_uno = x$opinion_oto_uno, dictamen_otorgar=v$dictamen_otorgar,
                              opinion_oto_dos = x$opinion_oto_dos, opinion_oto_tres = x$opinion_oto_tres, observaciones = x$observaciones,
                              estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = util.current_user_id()
          Where id = reg.pension;
          v$inserta_transicion := transicion_pension$biz(reg.pension, current_date, current_user_id(), reg.estado, v$estado_final, x$antecedente_oto,
                                                        null, x$observaciones, v$dictamen_otorgar, current_date, x$resumen_dictamen_otorgar,
                                                        null, null, null);
          contadorp:=contadorp+1;
        exception
        WHEN NO_DATA_FOUND THEN
          contadorp:=contadorp-1;
          contadord:=contadord+1;
        when others then
          contadorp:=contadorp-1;
          contadord:=contadord+1;
        end;
      end if;
    end if;
    contador:=contador+1;
  End loop;
  v$observacion:='Resultado Dictamen Otorgar, registros otorgados:' || contadorp;
  /*if contadord>0 then
    v$observacion:=v$observacion || ', registros inválidos (no cumplen con estado, objetados, falta requisito, otro error): ' || contadord;
  end if;*/
  Update lote set observaciones=substr(v$observacion,1,200), cantidad=contador Where id=x$lote;
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(v$err, err_msg, true);
end;
/