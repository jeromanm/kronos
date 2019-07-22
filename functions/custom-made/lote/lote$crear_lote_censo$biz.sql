create or replace function lote$crear_lote_censo$biz(x$super number, x$nombre varchar2, x$clase_pension number, x$estado_icv number
                              , x$numero_sime number, x$fecha_desde date, x$fecha_hasta date, x$departamento number
                              , x$distrito number, x$estado_censo number) return number is
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log rastro_proceso_temporal%ROWTYPE;
  err_num           NUMBER;
  err_msg           VARCHAR2(255);
  v$id_lote         number(19);
  v$id_lote_pension number(19);
  contador          number:=0;
begin
  v$id_lote := busca_clave_id;
  insert into lote (id, version, codigo, nombre, numero_sime, procesado_sin_errores, observaciones)
  values (v$id_lote, 0, v$id_lote, x$nombre, x$numero_sime, null, null);
  for reg in (Select a.id, a.observaciones
              From pension a, persona b, censo_persona cp
              Where a.persona = b.id
                and b.id = cp.persona
                and a.clase = x$clase_pension
                and a.estado in (1, 3, 6)
                and (cp.departamento = x$departamento or x$departamento is null)
                and (cp.distrito = x$distrito or x$distrito is null)
                and (cp.NUMERO_SIME = x$numero_sime or x$numero_sime is null)
                and ( x$estado_icv is null
                  or (x$estado_icv = 1 and b.icv > (Select valor_x1 From regla where variable_x1=901 And valor_x1<>0 And rownum=1))
                  or (x$estado_icv = 2 and b.icv <= (Select valor_x1 From regla where variable_x1=901 And valor_x1<>0 And rownum=1)))
                and ( x$fecha_desde is null or trunc(cp.fecha_transicion) >= x$fecha_desde)
                and ( x$fecha_hasta is null or trunc(cp.fecha_transicion) <= x$fecha_hasta)
                and cp.estado = x$estado_censo
              Group By a.id, a.observaciones
              UNION
              Select a.id, a.observaciones
              From pension a, persona b, censo_persona cp
              Where a.persona = b.id
                and b.id = cp.persona
                and a.clase = x$clase_pension
                and a.estado in (4, 5)
                and (cp.departamento = x$departamento or x$departamento is null)
                and (cp.distrito = x$distrito or x$distrito is null)
                and (cp.NUMERO_SIME = x$numero_sime or x$numero_sime is null)
                and ( x$estado_icv is null
                  or (x$estado_icv = 1 and b.icv > (Select valor_x1 From regla where variable_x1=901 And valor_x1<>0 And rownum=1))
                  or (x$estado_icv = 2 and b.icv <= (Select valor_x1 From regla where variable_x1=901 And valor_x1<>0 And rownum=1)))
                and ( x$fecha_desde is null or trunc(cp.fecha_transicion) >= x$fecha_desde)
                and ( x$fecha_hasta is null or trunc(cp.fecha_transicion) <= x$fecha_hasta)
                and cp.estado = x$estado_censo
                And NOT Exists (Select pn2.id From pension pn2 Where b.id = pn2.persona And pn2.clase=x$clase_pension  And pn2.estado in (1,3,6))
              Group By a.id, a.observaciones
              UNION
              Select a.id, a.observaciones
              From pension a inner join persona b on a.persona = b.id
                inner join censo_persona cp on b.id = cp.persona 
              Where a.clase = x$clase_pension
                And a.estado in (7)
                And (cp.departamento = x$departamento or x$departamento is null)
                And (cp.distrito = x$distrito or x$distrito is null)
                And (cp.NUMERO_SIME = x$numero_sime or x$numero_sime is null)
                And ( x$estado_icv is null
                  or (x$estado_icv = 1 And b.icv > (Select valor_numerico From variable_global Where numero=133))
                  or (x$estado_icv = 2 And b.icv <= (Select valor_numerico From variable_global Where numero=133)))
                And ( x$fecha_desde is null or trunc(cp.fecha_transicion) >= x$fecha_desde)
                And ( x$fecha_hasta is null or trunc(cp.fecha_transicion) <= x$fecha_hasta)
                And cp.estado = x$estado_censo
              Group By a.id, a.observaciones
              UNION
              Select a.id, a.observaciones
              From pension a inner join persona b on a.persona = b.id
                inner join censo_persona cp on b.id = cp.persona 
              Where a.clase = x$clase_pension
                And a.estado in (8,9,10) --in (7)
                And (cp.departamento = x$departamento or x$departamento is null)
                And (cp.distrito = x$distrito or x$distrito is null)
                And (cp.NUMERO_SIME = x$numero_sime or x$numero_sime is null)
                And ( x$estado_icv is null
                  or (x$estado_icv = 1 And b.icv > (Select valor_numerico From variable_global Where numero=133))
                  or (x$estado_icv = 2 And b.icv <= (Select valor_numerico From variable_global Where numero=133)))
                And ( x$fecha_desde is null or trunc(cp.fecha_transicion) >= x$fecha_desde)
                And ( x$fecha_hasta is null or trunc(cp.fecha_transicion) <= x$fecha_hasta)
                And cp.estado = x$estado_censo
                And NOT Exists (Select pn2.id From pension pn2 Where b.id = pn2.persona And pn2.clase=x$clase_pension And pn2.estado in (1,3,6,7))
              Group By a.id, a.observaciones
              ) loop
    v$id_lote_pension := busca_clave_id;
    insert into lote_pension (id, version, lote, pension, procesada_sin_errores, observaciones, fecha_lote_pension, excluir)
    values (v$id_lote_pension, 0, v$id_lote, reg.id, 'true', reg.observaciones, current_date, 'false');
    contador:=contador+1;
  end loop;
  Update lote set PROCESADO_SIN_ERRORES='true', cantidad=contador, observaciones='Pensiones incluidas: ' || contador where id=v$id_lote;
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20000, err_msg, true);
end;
/