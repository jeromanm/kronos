create or replace function lote$crear$biz(x$super number, x$nombre nvarchar2, x$clase_pension   number, x$estado number, x$activa varchar2,
                                          x$irregular varchar2, x$bloqueo varchar2, x$numero_sime nvarchar2, x$archivo number, x$departamento number,
                                          x$distrito number, x$tipo_area number, x$lote number, x$cedula_inferior number, x$cedula_superior number, x$estado_censo number)
  return number is
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log rastro_proceso_temporal%ROWTYPE;
  err_num           NUMBER;
  err_msg           VARCHAR2(255);
  v_id_lote         number(19);
  v_id_lote_pension number(19);
  contador          number:=0;
begin
  v_id_lote := busca_clave_id;
  insert into lote (id, version, codigo, nombre, numero_sime, procesado_sin_errores, observaciones)
  values (v_id_lote, 0, v_id_lote, x$nombre, x$numero_sime, null, null);
  for reg in (Select a.id, a.observaciones
              From pension a, persona b
              Where a.persona = b.id
                and a.clase = x$clase_pension
                and a.estado = x$estado
                and (a.activa = x$activa or x$activa is null)
                and (a.tiene_objecion = x$irregular or x$irregular is null)
                And (x$bloqueo is null or x$bloqueo=(case when trim(b.cuenta_bancaria) is null then 'false' else 'true' end))
                and (a.NUMERO_SIME_ENTRADA = x$numero_sime or x$numero_sime is null)
                and (a.archivo = x$archivo or x$archivo is null)
                and (b.departamento = x$departamento or x$departamento is null)
                and (b.distrito = x$distrito or x$distrito is null)
                and (b.tipo_area = x$tipo_area or x$tipo_area is null)
                and (to_number(b.codigo) >= x$cedula_inferior or x$cedula_inferior is null)
                and (to_number(b.codigo) <= x$cedula_superior or x$cedula_superior is null)
                And (x$lote is null or Exists (Select lp.id From lote_pension lp Where a.id = lp.pension And lp.lote=x$lote And lp.EXCLUIR='false'))
                and (x$estado_censo is null or exists(select per.id
                                                      from persona per, censo_persona cp
                                                      where per.id = b.id
                                                      and per.id = cp.persona and cp.estado = x$estado_censo))
              ) loop
    v_id_lote_pension := busca_clave_id;
    insert into lote_pension (id, version, lote, pension, procesada_sin_errores, observaciones, fecha_lote_pension, excluir)
    values (v_id_lote_pension, 0, v_id_lote, reg.id, 'true', reg.observaciones, current_date, 'false');
    contador:=contador+1;
  end loop;
  Update lote set PROCESADO_SIN_ERRORES='true', cantidad=contador, observaciones='Pensiones incluidas:' || contador where id=v_id_lote;
  return 0;
exception
  when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(-20000, err_msg, true);
end;
/
