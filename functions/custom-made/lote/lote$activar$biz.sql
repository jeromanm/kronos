create or replace function lote$activar$biz(x$super number, x$lote number, x$observaciones nvarchar2)
  return number is
  v$err               constant number := -20000; -- an integer in the range -20000..-20999
  v$msg               nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log               rastro_proceso_temporal%ROWTYPE;
  err_num             NUMBER;
  err_msg             VARCHAR2(255);
  v$xid               number;
  contador            number:=0;
  contador_objecion   number:=0;
  contador_procesada  number:=0;
  v_tiene_objecion    VARCHAR2(5); 
  v_falta_requisito   VARCHAR2(5);
  v_tiene_denuncia    VARCHAR2(5);
  v_tiene_reclamo     VARCHAR2(5);
  v$observaciones     VARCHAR2(2000):='';
begin
  For reg in (Select lp.pension, pn.estado, pe.codigo, ep.codigo as strestado
              From lote l, lote_pension lp, pension pn, persona pe, estado_pension ep, clase_pension cp
              Where l.id = lp.lote
                And lp.pension = pn.id
                And pn.persona = pe.id
                And pn.estado = ep.numero
                And pn.clase = cp.id
                And l.id = x$lote And EXCLUIR='false'
                And cp.requiere_censo='true') loop
    if reg.estado<>7 then
      raise_application_error(v$err, 'Error: la pensión ' || reg.pension || ', está en estado ' || reg.strestado || '. Cédula solicitante:' || reg.codigo, true);
    end if;
    v$xid:=pension$verificar$biz(x$super, reg.pension, 'false');
    begin
      Select tiene_objecion, falta_requisito, tiene_denuncia, tiene_reclamo 
        into v_tiene_objecion, v_falta_requisito, v_tiene_denuncia, v_tiene_reclamo 
      From pension where id =reg.pension;
    exception
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err,'Error al intentar obtener el estado de la pensión:' || reg.pension || ', mensaje:' || v$msg, true);
    end;
		if v_tiene_objecion='true' or v_falta_requisito='true' or v_tiene_denuncia='true' or v_tiene_reclamo='true' then
      contador_objecion:=contador_objecion+1;
    else
      update pension set observaciones_activar = x$observaciones, activa  = 'true', fecha_activar = current_date, usuario_activar = current_user_id()
      where id = reg.pension;
      contador_procesada:=contador_procesada+1;
    end if;
    contador:=contador+1;
  end loop;
  begin
    if contador_procesada>0 then
      v$observaciones:='Resultado de Incluir en planilla de pago: registros procesados sin objeciones:' || contador_procesada || ', '; 
    end if;
    if contador_objecion>0 then
      v$observaciones:=v$observaciones || ' registros procesados con objeciones:' || contador_objecion;
    end if;
    Update lote set PROCESADO_SIN_ERRORES='true', cantidad=contador, observaciones= v$observaciones where id=x$lote;
  exception
  WHEN NO_DATA_FOUND THEN
    null;
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar actualizar el estado del lote, mensaje:' || v$msg, true);
  end;
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(v$err, err_msg, true);
end;
/
