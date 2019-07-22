create or replace function lote$regi_dict_revoc$33132$biz(x$super number, x$lote number, x$antecedente_revo nvarchar2, x$antecedente_revo_uno nvarchar2, x$disposicion_revo_uno nvarchar2, x$disposicion_revo_dos nvarchar2,
                                                          x$disposicion_revo_tres nvarchar2, x$opinion_revo_uno nvarchar2, x$opinion_revo_dos nvarchar2, x$opinion_revo_tres nvarchar2,
                                                          x$causa number, x$otras_causas nvarchar2, x$observaciones nvarchar2) return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_num               NUMBER;
  err_msg               VARCHAR2(255);
  v$log rastro_proceso_temporal%ROWTYPE;
  v$inserta_transicion  number;
  v$estado_final        number;
  v$dictamen_revocar    VARCHAR2(255);
  contador              number:=0;
  contadord             number:=0;
  contadorp             number:=0;
  v$observacion         VARCHAR2(200);
begin
  Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
  Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into v$dictamen_revocar From variable_global Where numero=115;
  For reg in (Select lp.pension, pn.estado, pn.tiene_objecion
              From lote l, lote_pension lp, pension pn
              Where l.id = lp.lote
                And lp.pension = pn.id
                 and l.id = x$lote And lp.excluir='false') loop
    if reg.estado<>7 or reg.tiene_objecion<>'true' then
      contadord:=contadord+1;
    else
      begin
        v$estado_final   := 8;
        Update pension set antecedente_revo = x$antecedente_revo, antecedente_revo_uno = x$antecedente_revo_uno, disposicion_revo_uno = x$disposicion_revo_uno, disposicion_revo_dos = x$disposicion_revo_dos,
                            disposicion_revo_tres = x$disposicion_revo_tres, opinion_revo_uno =  x$opinion_revo_uno, opinion_revo_dos  = x$opinion_revo_dos, fecha_dictamen_revocar=current_date,
                            opinion_revo_tres =  x$opinion_revo_tres, causa_revocar = x$causa, otras_causas_revocar = x$otras_causas, dictamen_revocar=v$dictamen_revocar,
                            observaciones = x$observaciones, estado = v$estado_final, fecha_transicion  = current_date, usuario_transicion = current_user_id()
        Where id = reg.pension;
        v$inserta_transicion := transicion_pension$biz(reg.pension, current_date, current_user_id(), reg.estado, v$estado_final, x$antecedente_revo,
                                                      x$causa, x$observaciones, v$dictamen_revocar, current_date, x$disposicion_revo_uno, null, null, null);
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
    contador:=contador+1;
  End loop;
  v$observacion:='Resultado Dictamen Revocación, registros revocados:' || contadorp;
  /*if contadord>0 then
    v$observacion:=v$observacion || ', registros inválidos (no cumplen con estado, otro error): ' || contadord;
  end if;*/
  Update lote set observaciones=substr(v$observacion,1,200), cantidad=contador Where id=x$lote;
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(v$err, err_msg, true);
end;
/