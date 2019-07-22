create or replace function pension$reg_dic_dene$13432$biz(x$super number, x$pension number, x$resumen_dictamen_denegar varchar2, x$antecedente_dene varchar2, x$antecedente_dene_uno varchar2,
                                                          x$disposicion_dene_uno varchar2, x$disposicion_dene_dos varchar2, x$disposicion_dene_tres varchar2, x$opinion_dene_uno varchar2,
                                                          x$opinion_dene_dos varchar2, x$opinion_dene_tres varchar2, x$causa number, x$otras_causas varchar2, x$observaciones nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_num               NUMBER;
    err_msg               VARCHAR2(255);
    v$inserta_transicion  number;
    v$estado_inicial      number;
    v$estado_final        number;
    v$log rastro_proceso_temporal%ROWTYPE;
    v_dictamen_denegar    VARCHAR2(255);
begin --pension registrar dictamen denegar
  v$estado_inicial := pension$estado$inicial$biz(x$pension);
  v$estado_final   := 4; --denegada
  Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
  Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into v_dictamen_denegar From variable_global Where numero=115;
  Update pension set dictamen_denegar=v_dictamen_denegar, fecha_dictamen_denegar = current_date, antecedente_dene = x$antecedente_dene, disposicion_dene_uno = x$disposicion_dene_uno, antecedente_dene_uno=x$antecedente_dene_uno,
                     disposicion_dene_dos = x$disposicion_dene_dos, disposicion_dene_tres = x$disposicion_dene_tres, opinion_dene_uno =  x$opinion_dene_uno, opinion_dene_dos  = x$opinion_dene_dos,
                     opinion_dene_tres =  x$opinion_dene_tres, causa_denegar = x$causa, otras_causas_denegar = x$otras_causas, observaciones = x$observaciones,
                     resumen_dictamen_denegar=x$resumen_dictamen_denegar, estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = util.current_user_id()
  Where id = x$pension;
  v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, x$antecedente_dene, x$causa, x$observaciones,
                                                 v_dictamen_denegar, current_date, x$resumen_dictamen_denegar, null, null, null);
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pension', 'id', x$pension);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(-20001, err_msg, true);
end;
/
