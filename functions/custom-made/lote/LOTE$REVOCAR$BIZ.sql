create or replace function lote$revocar$biz(x$super number, x$lote number, x$resolucion nvarchar2, x$fecha date, x$resumen nvarchar2, x$observaciones nvarchar2)
  return number is
  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log rastro_proceso_temporal%ROWTYPE;
  v$inserta_transicion number;
  v$estado_inicial     number;
  v$estado_final       number;
  err_num              NUMBER;
  err_msg              VARCHAR2(255);
  contador                  number:=0;
  contadord                 number:=0;
begin
  For reg in (Select lp.pension, pn.estado, pe.codigo, ep.codigo as strestado
              From lote l, lote_pension lp, pension pn, persona pe, estado_pension ep
              Where l.id = lp.lote
                And lp.pension = pn.id
                And pn.persona = pe.id
                And pn.estado = ep.numero
                And l.id = x$lote And EXCLUIR='false') loop
    if reg.estado=8 then
      contadord:=contadord+1;
      v$estado_final   := 9;
      update pension set resolucion_revocar = x$resolucion, fecha_resolucion_revocar = x$fecha, resumen_resolucion_revocar = x$resumen,
                          observaciones  = x$observaciones, estado  = v$estado_final, fecha_transicion = current_date, usuario_transicion = current_user_id(),
                          activa  = 'false'
      where id = reg.pension;
      v$inserta_transicion := transicion_pension$biz(reg.pension, current_date, current_user_id(), reg.estado, v$estado_final, null, null,
                                                    x$observaciones, null, null, null, x$resolucion, x$fecha, x$resumen);
    end if;
    contador:=contador+1;
  end loop;
  Update lote set observaciones='Resultado Resolución Revocar, registros revocados:' || contadord, cantidad=contador Where id=x$lote;
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(v$err, err_msg, true);
end;
/