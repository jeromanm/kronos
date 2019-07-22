create or replace function pla_per_pago$reabrir$82991$biz(x$super number, x$clase_pension varchar2, x$periodo varchar2) return number is
  v$err                     constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_num                   NUMBER;
  err_msg                   VARCHAR2(255);
  v_id_persona              number;
  v_saldo_inicial           number := 0;
  v_saldo_actual            number := 0;
  v_mont                    number := 0;
  v_monto_acumulado         number := 0;
  v_estado                  number;
  v_mes_p                   number;
  v_ano_p                   number;
  v_mes_pp                  number;
  v_ano_pp                  number;
  v$id_planilla_periodo     number;
  v$id_planilla             number;
  v_tipo_concepto           number;
  v_cumple_periodo          varchar2(7);
  v_id_pension              number;
  v_id_clase_concepto       number;
  v_monto_concepto_pension  number;
  v$estado_inicial          number;
  v$estado_final            number;
  v$inserta_transicion      number;
  v$existe_orden_pago       number;
begin
  For reg in (Select p.estado, p.mes, p.ano, p.abrir_siguiente, p.id as id_planilla_periodo, pp.id as id_planilla
            From planilla_periodo_pago p, planilla_pago pp
            where pp.id= p.planilla And pp.periodo=x$periodo
              and pp.clase_pension = x$clase_pension
            Order by to_date('01/' || p.mes || '/' || p.ano,'dd/mm/yyyy')  desc) loop
      v_estado := reg.estado;  v$id_planilla_periodo := reg.id_planilla_periodo; 
      v_mes_p := reg.mes; v_ano_p := reg.ano; v$id_planilla := reg.id_planilla;
      begin
        Select Count(id) into v$existe_orden_pago 
        From resumen_pago_pension Where planilla=v$id_planilla 
          And detalle_orden_pago is not null And mes_resumen=reg.mes And ano_resumen=reg.ano;
      exception
      when others then
        raise_application_error(-20001,'Error al intentar obtener si los resúmen de pensón tiene orden asociada, mensaje:' || sqlerrm, true);
      end;
      if v_estado=1 or v_estado=2 And v$existe_orden_pago=0 then --borramos planillas abiertas
        begin
          Delete From detalle_pago_pension where resumen in (Select id From resumen_pago_pension WHere planilla=v$id_planilla And mes_resumen=reg.mes And ano_resumen=reg.ano);
          Delete From resumen_pago_pension where planilla=v$id_planilla And mes_resumen=reg.mes And ano_resumen=reg.ano;
          Delete From planilla_periodo_pago where id = v$id_planilla_periodo;
        exception
        when others then
          raise_application_error(-20001,'Error al intentar eliminar planillas abiertas y/o en proceso, mensaje:' || sqlerrm, true);
        end;
      elsif v_estado=3 then
        begin
          update planilla_periodo_pago set estado = 2 where id = v$id_planilla_periodo;
        exception
        when others then
          raise_application_error(-20001,'Error al intentar abrir planilla cerrada del mes de ' || v_mes_p || ' año ' || v_ano_p || ', mensaje:' || sqlerrm, true);
        end;
        exit;
      end if;
  End loop;
  for reg in (Select pn.id as idpension, tc.numero as tipo_concepto, cl.requiere_saldo,
            case cp.general when 'true' then nvl(cp.monto,0) else nvl(ce.monto,0) end as monto,
               ce.limite, ce.saldo_inicial, cc.id as id_clase_concepto,
               case when ce.desde is null or ce.hasta is null then 'true'
                else
                case when to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/rrrr') between ce.desde and ce.hasta then 'true' else 'false' end
              end as cumple_periodo
        From planilla_pago pp inner join planilla_periodo_pago pr on pp.id = pr.planilla
          inner join concepto_planilla_pago cp on pp.id = cp.planilla
           inner join clase_pension cl on pp.clase_pension = cl.id
           inner join pension pn on cl.id = pn.clase
           inner join persona pe on pn.persona = pe.id
           inner join clase_concepto cc on cp.clase_concepto = cc.id
           inner join tipo_concepto tc on cc.tipo_concepto = tc.numero
           inner join concepto_pension ce on pn.id = ce.pension
        Where pr.id = v$id_planilla_periodo And pp.periodo=x$periodo
            And pr.mes = v_mes_p And pr.ano = v_ano_p
        Order by persona) loop
         v_saldo_inicial:=reg.saldo_inicial; v_tipo_concepto:=reg.tipo_concepto; v_id_pension:=reg.idpension;
         v_id_clase_concepto:=reg.id_clase_concepto; v_monto_concepto_pension:= reg.monto;
         v_cumple_periodo:=reg.cumple_periodo;
         if v_cumple_periodo='true' then
        if (v_saldo_inicial > 0) then
          begin
            update concepto_pension set monto_acumulado = nvl(monto_acumulado, 0) - v_monto_concepto_pension,
                              saldo_actual = nvl(saldo_actual,0) + v_monto_concepto_pension
               where pension =  v_id_pension And clase = v_id_clase_concepto;
              exception
            when others then
            raise_application_error(-20001, 'Error al intentar actualizar los saldos del concepto pension, mensaje:' || sqlerrm, true);
          end;
           end if;
        if reg.requiere_saldo='true' then
          begin
            Select saldo_actual into v_saldo_actual From pension Where id=v_id_pension;
          exception
          WHEN NO_DATA_FOUND THEN
            v_saldo_actual:=0;
          when others then
            raise_application_error(-20001, 'Error al intentar obtener el saldo actual, mensaje:'|| sqlerrm, true);
          end;
          if v_saldo_actual<=0 then  --finalizamos pensión cuyo concepto requiere saldo y se consumio totalmente
            begin
              update pension set estado=7, activa='true' Where id=v_id_pension;
              v$estado_inicial := 10;
              v$estado_final   := 7;
              v$inserta_transicion := transicion_pension$biz(v_id_pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
            exception
            when others then
              raise_application_error(-20001, 'Error al intentar actualizar el estatus de la pensión, mensaje:'|| sqlerrm, true);
            end;
          end if;
          begin
            update pension set saldo_actual = nvl(saldo_actual,0) + v_monto_concepto_pension,
                        monto_pagado = nvl(monto_pagado, 0) - v_monto_concepto_pension
            where id = v_id_pension;
          exception
          when others then
            raise_application_error(-20001, 'Error en la tabla Concepto Pension', true);
          end;
        end if; --if reg.requiere_saldo='true' then
      end if; --if v_cumple_periodo='true' then
  end loop;
   return 0;
exception
  when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(err_num, err_msg, true);
end;
/
 