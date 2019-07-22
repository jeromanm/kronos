create or replace function pension$reg_dic_revo$63460$biz(x$super number, x$pension number,x$resumen_dictamen_revocar nvarchar2, x$antecedente_revo nvarchar2, x$antecedente_revo_uno nvarchar2,
                                                          x$disposicion_revo_uno nvarchar2, x$disposicion_revo_dos nvarchar2, x$disposicion_revo_tres nvarchar2, x$opinion_revo_uno nvarchar2,
                                                          x$opinion_revo_dos nvarchar2, x$opinion_revo_tres nvarchar2, x$causa number, x$otras_causas nvarchar2, x$observaciones nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid                 varchar2(146);
    v$log rastro_proceso_temporal%ROWTYPE;
    v_dictamen_revocar    VARCHAR2(255);
    v$inserta_transicion  number;
    v$estado_inicial      number;
    v$estado_final        number;
    err_num               NUMBER;
    err_msg               VARCHAR2(255);
begin -- registrar dictamen revocar
  v$estado_inicial := pension$estado$inicial$biz(x$pension);
  v$estado_final   := 8;
  Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
  Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into v_dictamen_revocar From variable_global Where numero=115;
  update pension  set fecha_dictamen_revocar   = current_date, dictamen_revocar=v_dictamen_revocar, resumen_dictamen_revocar = x$resumen_dictamen_revocar,
                        antecedente_revo = x$antecedente_revo, disposicion_revo_uno = x$disposicion_revo_uno, antecedente_revo_uno=x$antecedente_revo_uno,
                        disposicion_revo_dos = x$disposicion_revo_dos, disposicion_revo_tres = x$disposicion_revo_tres,
                        opinion_revo_uno =  x$opinion_revo_uno, opinion_revo_dos  = x$opinion_revo_dos,
                        opinion_revo_tres =  x$opinion_revo_tres, causa_revocar = x$causa, otras_causas_revocar = x$otras_causas,
                        observaciones = x$observaciones, estado = v$estado_final, fecha_transicion = current_date,
                        usuario_transicion = util.current_user_id()
  Where id = x$pension;
  v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null,
                                                 x$causa, x$observaciones, v_dictamen_revocar, current_date, x$resumen_dictamen_revocar, null, null, null);
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