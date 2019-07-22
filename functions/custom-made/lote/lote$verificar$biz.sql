create or replace function lote$verificar$biz(x$super number, x$lote number, x$especial varchar2) return number is
  v$err               constant number := -20000;
  v$msg               nvarchar2(2000);
  v$xid               number;
  v$log               rastro_proceso_temporal%ROWTYPE;
  err_num             NUMBER;
  err_msg             VARCHAR2(255);
  contador            number:=0;
  contador_objecion   number:=0;
  contador_procesada  number:=0;
  contadoraux         number:=0;
  v$cantidad          number:=0;
  v_tiene_objecion    VARCHAR2(5);
  v_falta_requisito   VARCHAR2(5);
  v_tiene_denuncia    VARCHAR2(5);
  v_tiene_reclamo     VARCHAR2(5);
  v$observaciones     VARCHAR2(2000):='';
begin
  v$log := rastro_proceso_temporal$select();
  For reg in (Select b.pension, nvl(a.cantidad,0) as cantidad, a.procesado_sin_errores, a.observaciones,
                    case when instr(lower(a.observaciones),'registros procesados sin objeciones:')>0 then 
                        to_char(substr(a.observaciones, 36+instr(lower(a.observaciones),'registros procesados sin objeciones:'),
                        instr(substr(a.observaciones, 36+instr(lower(a.observaciones),'registros procesados sin objeciones:')),',')-1))
                    else '0' end as contador_procesada,
                    case when instr(lower(a.observaciones),'registros procesados con objeciones:')>0 then 
                          to_char(substr(a.observaciones, 36+instr(lower(a.observaciones),'registros procesados con objeciones:'),
                          instr(substr(a.observaciones, 36+instr(lower(a.observaciones),'registros procesados con objeciones:')),'.')-1))
                    else '0' end as contador_objecion
            From lote a inner join lote_pension b on a.id = b.lote
            Where a.id = x$lote
            Order by b.id) loop
    if reg.procesado_sin_errores ='false' And contador_procesada=0 And reg.contador_procesada>0 then --retomamos contadores de como quedo una carga parcial
      contador_procesada:=reg.contador_procesada;
      contador_objecion:=reg.contador_objecion;
      v$cantidad:=contador_procesada+contador_objecion;
    end if;
    if (contador>=v$cantidad or reg.procesado_sin_errores ='true') then
      v$xid:=pension$verificar$biz(0, reg.pension, x$especial);
      begin
				Select tiene_objecion, falta_requisito, tiene_denuncia, tiene_reclamo
          into v_tiene_objecion, v_falta_requisito, v_tiene_denuncia, v_tiene_reclamo
				From pension where id =reg.pension;
			exception
      when others then
				v$msg := SUBSTR(SQLERRM, 1, 2000);
				raise_application_error(v$err,'Error al intentar obtener el estado de la pensión:' || reg.pension || ', mensaje:' || v$msg, true);
			end;
      if contadoraux>10 then
        begin
          Update lote set cantidad=contador, observaciones= ' registros procesados sin objeciones:' || contador_procesada || ', registros procesados con objeciones:' || contador_objecion || '.',
                          PROCESADO_SIN_ERRORES='false'
          where id=x$lote;
        Exception
        WHEN NO_DATA_FOUND THEN
          null;
        when others then
          v$msg:=substr(SQLERRM,1,2000);
          raise_application_error(v$err, 'Error al intentar actualizar el estado del lote, mensaje:' || v$msg, true);
        end;
        commit work;
        rastro_proceso_temporal$revive(v$log);
        contadoraux:=0;
      end if;
      if v_tiene_objecion='true' or v_falta_requisito='true' or v_tiene_denuncia='true' or v_tiene_reclamo='true' then
				contador_objecion:=contador_objecion+1;
      else
        contador_procesada:=contador_procesada+1;
      end if;
      contadoraux:=contadoraux+1;
    end if;
    contador:=contador+1;
  end loop;
  begin
    if contador_procesada>0 then
      v$observaciones:=' registros procesados sin objeciones:' || contador_procesada || ', ';
    end if;
    if contador_objecion>0 then
      v$observaciones:=v$observaciones || ' registros procesados con objeciones:' || contador_objecion || '.';
    end if;
    Update lote set PROCESADO_SIN_ERRORES='true', cantidad=contador, observaciones=substr(v$observaciones,1,200)  where id=x$lote;
  exception
  WHEN NO_DATA_FOUND THEN
    null;
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar actualizar el estado del lote, mensaje:' || v$msg, true);
  end;
  commit work;
  rastro_proceso_temporal$revive(v$log);
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  ERR_NUM := SQLCODE;
  ERR_MSG := SQLERRM;
  raise_application_error(ERR_NUM, ERR_MSG, true);
  RETURN 0;
end;
/
