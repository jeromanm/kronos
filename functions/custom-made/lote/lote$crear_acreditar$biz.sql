create or replace function lote$crear_acreditar$biz(x$super number, x$lote number)
	return number is
	v$err                 constant number := -20000; -- an integer in the range -20000..-20999
	v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
	v$log                 rastro_proceso_temporal%ROWTYPE;
	v$inserta_transicion  number;
	v$estado_final        number;
  v$id						      number;
	err_num               NUMBER;
	err_msg               VARCHAR2(255);
  v_tiene_objecion		  VARCHAR2(5);
	v_falta_requisito		  VARCHAR2(5);
  v_tiene_denuncia		  VARCHAR2(5);
	v_tiene_reclamo 		  VARCHAR2(5);
  contador              integer:=0;
  contadord             integer:=0;
  contador_procesada    number:=0;
  v$observacion         VARCHAR2(200);
  v$valor_icv           number;
begin
	for reg in (Select lp.pension, cp.acredita, cp.requiere_censo, cp.nombre as clase, pn.estado, pe.indigena, fh.estado as estadof,
                     pe.monitoreado, pe.MONITOREO_SORTEO, re.valor_x1 as valor_icv, (Select valor_numerico From variable_global Where numero=133) as valor_icv_monitoreado,
                    (Select case when cp.icv is null then 'pob:' || cp.tipo_pobreza else 'icv:' || cp.icv end From censo_persona cp 
                     Where cp.persona = pe.id And cp.fecha=(Select max(cp2.fecha) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4) 
                        And cp.fecha_transicion=(Select max(cp2.fecha_transicion) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4)
                        And rownum=1 And cp.estado=4) as icvcenso
              From lote lo inner join lote_pension lp on lo.id = lp.lote
                inner join pension pn on lp.pension = pn.id
                inner join persona pe on pn.persona = pe.id
                inner join clase_pension cp on pn.clase = cp.id
                inner join ficha_persona fp on pe.ficha = fp.id
                inner join ficha_hogar fh on fp.ficha_hogar = fh.id
                inner join regla_clase_pension rc on pn.clase = rc.clase_pension 
                inner join regla re on re.id = rc.regla And re.variable_x1=901
              Where lo.id = x$lote) loop
    If reg.requiere_censo<>'true' Then
      raise_application_error(v$err,'Error: la clase pensión no requiere censo:' || reg.clase, true);
    end if;
		If reg.acredita='true' And reg.estado=1 And (reg.estadof=4 or reg.indigena='true') Then --solo validamos clase pension acredita=true
			/*begin
				Select tiene_objecion, falta_requisito, tiene_denuncia, tiene_reclamo 
          into v_tiene_objecion, v_falta_requisito, v_tiene_denuncia, v_tiene_reclamo 
				From pension where id =reg.pension;
			exception
      when others then
				v$msg := SUBSTR(SQLERRM, 1, 2000);
				raise_application_error(v$err,'Error al intentar obtener el estado de la pensión:' || reg.pension || ', mensaje:' || v$msg, true);
			end;
      if reg.icv>65 or reg.tipo_pobreza=2 then
        v_tiene_objecion:='true';
      end if;*/
      v$valor_icv:=substr(reg.icvcenso,5); v_tiene_objecion:='false';
      if instr(reg.icvcenso,'icv:')>0 then --el valor del censo esta relacionado al icv
          if reg.monitoreado='true' or reg.monitoreo_sorteo='true' then
            if v$valor_icv>reg.valor_icv_monitoreado then
              v_tiene_objecion:='true';
            end if;
          else
            if v$valor_icv>reg.valor_icv then
              v_tiene_objecion:='true';
            end if;
          end if;
      elsif instr(reg.icvcenso,'pob:')>0 then --el valor del censo esta relacionado con tipo probreza STP
          if (substr(reg.icvcenso,5)<>1) then --1 es no pobre
            v_tiene_objecion:='true';
          end if;
      end if;
			if v_tiene_objecion='true' then --or v_falta_requisito='true' or v_tiene_denuncia='true' or v_tiene_reclamo='true'
				contadord:=contadord+1;
			else   
        v$estado_final   := 3;
				Update pension set estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = current_user_id(), activa  = 'false'	
				Where id = reg.pension;
				v$inserta_transicion := transicion_pension$biz(reg.pension, current_date, current_user_id(), reg.estado, v$estado_final, null, null, null, 
                                                        null, null, null, null, null, null);
        contador_procesada:=contador_procesada+1;
			end if;
      contador:=contador+1;
		end if;
	end loop;
  v$observacion:='Resultado acreditación, registros acreditados:' || contador_procesada;
  if contadord>0 then
    v$observacion:=v$observacion || ', registros inválidos (icv fuera de rango): ' || contadord;
  end if;
  Update lote set observaciones=substr(v$observacion,1,200), cantidad=contador Where id=x$lote;
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(v$err, err_msg, true);
end;
/
