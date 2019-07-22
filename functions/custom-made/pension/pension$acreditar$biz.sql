create or replace function pension$acreditar$biz(x$super number, x$pension number, x$observaciones nvarchar2)  return number is
	v$err 					      constant number := -20000; -- an integer in the range -20000..-20999
	v$msg 					      nvarchar2(2000); -- a character string of at most 2048 bytes?
	v$estado_final        number;
	v$id 						      number:=0;
	v$tiene_objecion		  VARCHAR2(5);
  v$valor_icv           number;
begin
  for reg in (Select fh.id, cp.acredita, pn.estado as edo1, to_char(ef.codigo) as codigo, fh.estado as edo2, pe.indigena,
                     pe.monitoreado, pe.MONITOREO_SORTEO, re.valor_x1 as valor_icv, (Select valor_numerico From variable_global Where numero=133) as valor_icv_monitoreado,
                    (Select case when cp.icv is null then 'pob:' || cp.tipo_pobreza else 'icv:' || cp.icv end From censo_persona cp 
                     Where cp.persona = pe.id And cp.fecha=(Select max(cp2.fecha) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4) 
                        And cp.fecha_transicion=(Select max(cp2.fecha_transicion) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4)
                        And rownum=1 And cp.estado=4) as icvcenso
              From pension pn inner join clase_pension cp on pn.clase = cp.id
                inner join persona pe on pn.persona = pe.id
                left outer join censo_persona ce on pe.id = ce.persona
                left outer join ficha_persona fp on ce.ficha = fp.id
                left outer join ficha_hogar fh on fp.ficha_hogar = fh.id
                left outer join estado_ficha_hogar ef on fh.estado = ef.numero
                inner join regla_clase_pension rc on pn.clase = rc.clase_pension 
                inner join regla re on re.id = rc.regla And re.variable_x1=901
              Where pn.id =x$pension And pe.indigena='false'
              UNION
              Select -1 as id, cp.acredita, pn.estado as edo1, 'N/A' as codigo, -1 as edo2, pe.indigena,
                     pe.monitoreado, pe.MONITOREO_SORTEO, re.valor_x1 as valor_icv, (Select valor_numerico From variable_global Where numero=133) as valor_icv_monitoreado,
                     'icv:1' as icvcenso
              From pension pn inner join clase_pension cp on pn.clase = cp.id
                inner join persona pe on pn.persona = pe.id
                inner join regla_clase_pension rc on pn.clase = rc.clase_pension 
                inner join regla re on re.id = rc.regla And re.variable_x1=901
              Where pn.id =x$pension And rownum=1 And pe.indigena='true'
              Order by 1 desc) loop
    if reg.id is null And reg.acredita='true' then
      raise_application_error(v$err,'Error: la persona asociada a la pensión, requiere acreditación, pero no posee censo cargado.', true);
    end if;
    if reg.acredita='true' Then --solo validamos clase pension acredita=true
      if reg.edo1<>1 then
        raise_application_error(v$err,'Error: la pensión está en estado diferente a solicitado.', true);
      end if;
      if reg.edo2<>4 And reg.indigena ='false' then
        raise_application_error(v$err,'Error: la ficha hogar (id:' || reg.id || ') está en estado diferente a aceptado (' || reg.codigo || ')', true);
      end if;
      /*v$id:=pension$verificar$biz(x$super, x$pension, 'false'); --verificar elegibilidad de la pensión reción creada para las reglas, especial='false'
      rastro_proceso_temporal$revive(v$log);
      begin
        Select pn.tiene_objecion, Count(op.id) 
          into v$tiene_objecion, v_cant_objecion 
        From pension pn left outer join objecion_pension op on pn.id = op.pension And op.objecion_invalida='true' 
        Where pn.id=x$pension
        Group By pn.estado, pn.tiene_objecion;
      exception
      WHEN NO_DATA_FOUND THEN
        v$tiene_objecion:='false';
      when others then
        v$tiene_objecion:='false';
      end;
      if v$icv>65 And v$indigena='false' then
        v$tiene_objecion:='true';
      end if;*/
      v$valor_icv:=substr(reg.icvcenso,5); v$tiene_objecion:='false';
      if instr(reg.icvcenso,'icv:')>0 then --el valor del censo esta relacionado al icv
        if reg.monitoreado='true' or reg.monitoreo_sorteo='true' then
          if v$valor_icv>reg.valor_icv_monitoreado then
            v$tiene_objecion:='true';
          end if;
        else
          if v$valor_icv>reg.valor_icv then
            v$tiene_objecion:='true';
          end if;
        end if;
      elsif instr(reg.icvcenso,'pob:')>0 then --el valor del censo esta relacionado con tipo probreza STP
        if (substr(reg.icvcenso,5)<>1) then --1 es no pobre
          v$tiene_objecion:='true';
        end if;
      end if;
      if v$tiene_objecion='true' then
        raise_application_error(v$err,'El valor del icv/tipo de pobreza no permite la acreditación.',true);
      end if;
      v$estado_final   := 3;
      begin
        Update pension set observaciones = observaciones || '. ' || x$observaciones, estado = v$estado_final, fecha_transicion = current_date, 
                            usuario_transicion = current_user_id(), activa  = 'false'
        Where id = x$pension;
        v$id := transicion_pension$biz(x$pension, current_date, current_user_id(), reg.edo1, v$estado_final, null, null, x$observaciones, null, null, null, null, null, null);
      exception
      WHEN NO_DATA_FOUND THEN
        raise_application_error(v$err,'Error: no se consiguen datos de la pensión.', true);
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err,'Error al intentar actualizar el estado de la pensión, mensaje:' || v$msg, true);
      end;
    else
      raise_application_error(v$err,'Error: la pensión suministrada no requiere acreditación, debe ejecutar elegibilidad para cambiar su estado.', true);
    end if;
  end loop;
	return 0;
exception
When others then
  v$msg := SUBSTR(SQLERRM, 1, 2000);
  raise_application_error(v$err, v$msg, true);
end;
/
