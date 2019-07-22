create or replace function lote$otorgar$biz(x$super number, x$lote number, x$resolucion nvarchar2, x$fecha date,
                                            x$antecedente_resol_oto nvarchar2, x$antecedente_resol_oto_uno nvarchar2, x$disposicion_resol_oto_uno nvarchar2,
                                            x$disposicion_resol_oto_dos nvarchar2, x$disposicion_resol_oto_tres nvarchar2,
                                            x$opinion_resol_oto_uno nvarchar2, x$opinion_resol_oto_dos nvarchar2,
                                            x$opinion_resol_oto_tres nvarchar2, x$resumen_resol_oto_uno nvarchar2,
                                            x$resumen_resol_oto_dos nvarchar2, x$resumen_resol_oto_tres nvarchar2) return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log                 rastro_proceso_temporal%ROWTYPE;
  err_num               NUMBER;
  err_msg               VARCHAR2(255);
  v$inserta_transicion  number;
  v$estado_inicial      number;
  v$estado_final        number;
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
    if reg.estado=6 then
      contadord:=contadord+1;
      v$estado_inicial := reg.estado;
      v$estado_final   := 7;
      Update pension set resolucion_otorgar = x$resolucion, fecha_resolucion_otorgar = x$fecha, estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = current_user_id(),
                          ANTECEDENTE_RESOL_OTO=x$antecedente_resol_oto, antecedente_resol_oto_uno = x$antecedente_resol_oto_uno, DISPOSICION_RESOL_OTO_DOS=x$disposicion_resol_oto_dos, DISPOSICION_RESOL_OTO_TRES=x$disposicion_resol_oto_tres,
                          DISPOSICION_RESOL_OTO_UNO=x$disposicion_resol_oto_uno, OPINION_OTO_DOS=x$opinion_resol_oto_dos, OPINION_OTO_TRES=x$opinion_resol_oto_tres,
                          OPINION_OTO_UNO=x$opinion_resol_oto_uno,  OPINION_RESOL_OTO_DOS=x$opinion_resol_oto_dos, OPINION_RESOL_OTO_TRES=x$opinion_resol_oto_tres,
                          OPINION_RESOL_OTO_UNO=x$opinion_resol_oto_uno, RESUMEN_RESOL_OTO_DOS=x$resumen_resol_oto_dos, RESUMEN_RESOL_OTO_TRES=x$resumen_resol_oto_tres,
                          RESUMEN_RESOL_OTO_UNO = x$resumen_resol_oto_uno
      Where id = reg.pension;
      v$inserta_transicion := transicion_pension$biz(reg.pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null,
                                                   null, null, null, null, null, x$resolucion, x$fecha, x$resumen_resol_oto_uno);
    end if;
    contador:=contador+1;
  End loop;
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'),'lote','id',x$lote);
    raise_application_error(v$err, v$msg, true);
  end if;
  Update lote set observaciones='Resultado Resolución Otorgar, registros otorgados:' || contadord, cantidad=contador Where id=x$lote;
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(v$err, err_msg, true);
end;
/
