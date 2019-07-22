create or replace function plan_peri_pag$cerrar$12887$biz(x$super number, x$clase_pension number,  x$periodo varchar2, x$abrir_siguiente varchar2) return number is
  v$err                     constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_num                   NUMBER;
  err_msg                   VARCHAR2(255);
  v$log rastro_proceso_temporal%ROWTYPE;
  v_id_planilla_pago        number;
  v_mes                     integer;
  v_ano                     integer;
  v_mesnuevo                integer;
  v_anonuevo                integer;
  v_abrir_siguiente         varchar2(5);
  v_id_concepto_pension     number;
  v_planilla                number:=null;
  v_saldo_actual            number := 0;
  v_estado                  varchar2(50);
  v_codigo                  number;
  v$estado_inicial          number;
  v$estado_final            number;
  v$inserta_transicion      number;
begin
  begin
    For reg in (Select p.estado, p.mes, p.ano, p.abrir_siguiente, p.codigo, p.planilla
                From planilla_periodo_pago p, planilla_pago pp
                Where pp.id=p.planilla
                  And pp.clase_pension=x$clase_pension And p.estado=2
                  And pp.periodo=x$periodo
                Order by to_date('01/' || p.mes || '/' || p.ano,'dd/mm/yyyy') desc) loop
      v_estado:=reg.estado;
      v_mes:=reg.mes;
      v_ano:=reg.ano;
      v_abrir_siguiente:=reg.abrir_siguiente;
      v_codigo:=reg.codigo;
      v_planilla:=reg.planilla;
      exit;
    end loop;
  exception
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar obtener datos de la planilla de pago, mensaje:' || v$msg, true);
  end;
  if v_planilla is null then
    raise_application_error(v$err, 'Error: no se consiguen datos de la planilla a cerrar segun los parámetros seleccionados.', true);
  end if;
  for reg in (Select pn.id as idpension, cl.requiere_saldo, ce.monto, cp.id as concepto_pension,
                    ce.limite, ce.saldo_inicial, cc.id as id_clase_concepto,
                    case when ce.desde is null or ce.hasta is null then 'true'
                      else
                    case when to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/rrrr') between ce.desde and ce.hasta then 'true' else 'false' end
                    end as cumple_periodo, ce.monto_acumulado
              From planilla_pago pp inner join planilla_periodo_pago pr on pp.id = pr.planilla
                inner join concepto_planilla_pago cp on pp.id = cp.planilla
                inner join clase_pension cl on pp.clase_pension = cl.id
                inner join pension pn on cl.id = pn.clase
                inner join clase_concepto cc on cp.clase_concepto = cc.id
                inner join concepto_pension ce on pn.id = ce.pension And cp.id=ce.clase And ce.bloqueado<>'true'
              Where pp.codigo = v_planilla And cp.general='false'
                And pr.mes = trim(to_char(v_mes,'00')) And pr.ano = v_ano
                And pp.periodo=x$periodo
              Order by pn.persona, cumple_periodo desc, cc.codigo) loop
    if reg.cumple_periodo='true' then
      if (reg.saldo_inicial > 0) then
        begin
          update concepto_pension set saldo_actual = nvl(saldo_actual,0) - reg.monto where id=reg.concepto_pension;
        exception
        when others then
          raise_application_error(v$err, 'Error al intentar actualizar los saldos del concepto pension', true);
        end;
      end if;
      if reg.requiere_saldo='true' then
        begin
          update pension set saldo_actual = nvl(saldo_actual,0) - reg.monto, monto_pagado = nvl(monto_pagado, 0) + reg.monto
          where id = reg.idpension;
        exception
        when others then
          v$msg:=substr(SQLERRM,1,2000);
          raise_application_error(v$err, 'Error al intentar actualizar el saldo de la pensión ' || reg.idpension || ', mensaje:' || v$msg, true);
        end;
        begin
          Select saldo_actual into v_saldo_actual From pension Where id=reg.idpension;
        exception
        WHEN NO_DATA_FOUND THEN
          v_saldo_actual:=0;
        when others then
          raise_application_error(v$err, 'Error al intentar obtener el saldo actual, mensaje:'|| sqlerrm, true);
        end;
        if v_saldo_actual<=0 then  --finalizamos pensión cuyo concepto requiere saldo y se consumio totalmente
          begin
            update pension set estado=10, activa='false' Where id=reg.idpension;
            v$estado_inicial := 7;
            v$estado_final   := 10;
            v$inserta_transicion := transicion_pension$biz(reg.idpension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
          exception
          when others then
            v$msg:=substr(SQLERRM,1,2000);
            raise_application_error(v$err, 'Error al intentar actualizar el estado de la pensión ' || reg.idpension || ', mensaje:' || v$msg, true);
          end;
        end if;
      end if;
    end if; --if reg.cumple_periodo='true' then
  end loop;
  begin
    update planilla_periodo_pago set estado = 3, abrir_siguiente = x$abrir_siguiente where planilla = v_planilla;
  exception
  when no_data_found then
    raise_application_error(err_num, err_msg, true);
  when others then
    raise_application_error(err_num, err_msg, true);
  end;
  if x$abrir_siguiente = 'true' And x$periodo=1 then --solo abrimos automaticamente periodos mensuales
    v_mesnuevo  := v_mes + 1;
    if v_mesnuevo>12 then
      v_anonuevo:=v_ano+1; v_mesnuevo:=1;
    else
      v_anonuevo:=v_ano;
    end if;
    begin
      v_id_planilla_pago:=BUSCA_CLAVE_ID;
      insert into planilla_periodo_pago (id, version, codigo, planilla, mes, ano, estado, abrir_siguiente,  comentarios)
      values (v_id_planilla_pago, 0, v_id_planilla_pago, v_planilla, trim(to_char(v_mesnuevo,'00')), v_anonuevo, 1, v_abrir_siguiente, 'Liquidación de Pensión Correspondiente al periodo '|| v_mesnuevo||'/'||v_anonuevo);
    exception
    when others then
      v$msg:=substr(SQLERRM,1,2000);
      raise_application_error(v$err, 'Error al intentar crear el perìodo siguiente, mes:' ||  to_char(v_mes,'00') || ', año:' || v_ano || ', mensaje:' || v$msg, true);
    end;
  end if; --if x$abrir_siguiente = 'true' then
  For reg in (Select ce.id, pn.id as idpension
            From planilla_pago pp inner join planilla_periodo_pago pr on pp.id = pr.planilla
              inner join concepto_planilla_pago cp on pp.id = cp.planilla
              inner join pension pn on pp.clase_pension = pn.clase
              inner join persona pe on pn.persona = pe.id
              inner join clase_concepto cc on cp.clase_concepto = cc.id
              inner join concepto_pension ce on pn.id = ce.pension And cp.id=ce.clase And ce.bloqueado<>'true'
            Where pp.id = v_planilla And pp.periodo=x$periodo
              And pr.mes = trim(to_char(v_mes,'00')) And pr.ano = v_ano And cp.general='false'
              And pn.activa='true' And pn.estado=7 And pn.fecha_dictamen_otorgar<=last_day(to_date('01/' || v_mes || '/' || v_ano,'dd/mm/yyyy'))
              And not exists (select op.pension From objecion_pension op Where op.pension=pn.id And OBJECION_INVALIDA='true')
              And not exists (Select rp.pension From resumen_pago_pension rp Where rp.pension=pn.id And rp.detalle_orden_pago is not null And rp.mes_resumen = trim(to_char(v_mes,'00')) And rp.ano_resumen = v_ano)
              And ce.monto_acumulado<ce.saldo_inicial And to_char(ce.hasta,'yyyy')<>v_anonuevo
            Order by pe.codigo, cc.codigo) loop
    begin
      update concepto_pension set desde=to_date('01/' || v_mesnuevo || '/' || v_anonuevo,'dd/mm/yyyy'), 
            hasta=last_day(to_date('01/' || v_mesnuevo || '/' || v_anonuevo,'dd/mm/yyyy')), BLOQUEADO='true'
      Where id = reg.id;
    exception
    when no_data_found then
      raise_application_error(err_num, 'Error: no se consiguen datos del concepto de asignado para actualizar su fecha de vigencia.', true);
    when others then
      v$msg:=substr(SQLERRM,1,2000);
      raise_application_error(v$err, 'Error al intentar actualizar el período de vigencia del asignado de la pensión ' || reg.idpension || ', mensaje:' || v$msg, true);
    end;
  end loop;
  return 0;
exception
   when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(v$err,'Error al Cerrar Planilla', true);
end;
/
