create or replace function pension$rec_liq_habe$23744$biz(x$super number, x$numero_liquidacion varchar2, x$pension number, x$fecha_desde date, 
                                                        x$fecha_hasta date, x$subsidio varchar2, x$sime number, x$observaciones nvarchar2) return number is
    v$err                       constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                       nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$porcentaje                number;
    v$estado_liquidacion        VARCHAR2(5);
    v_valor_conc_sepelio        number;
    v$cantidad_salario          integer;
    v_valor_conc_haber_atrasado number;
    v_valor_conc_permanente     number;
    v_valor_conc_subsidio       number;
    v_valor_conc_cobr_indebido  number;
    v_porcentaje_max            number;
    v$id_concepto_pension       number;
    v$idconcepto_planilla_pago  number;
    v$idclase_concepto          number;
    v$estado_pension            integer;
    v$clase_pension             integer;
    v$clase_pension_causante    integer;
    v$cant_recurrente           integer;
    v$requiere_censo            VARCHAR2(5);
    v$salario                   NUMBER(12,2);
    v$fecha_nacimiento          date;
    v$fecha_hasta               date:=x$fecha_hasta;
    v$fecha_aux                 date:=x$fecha_desde;
    v$fecha_pago                date;
    v$fecha_planilla            date;
    v$cantidad                  integer;
    v$monto                     number;
    v$monto_permanente          number:=0;
    v$monto_sepelio             number:=0;
    v$dia                       integer;
    v$mes                       integer;
    contador                    integer:=0;
    v$id_liquidacion_haberes    number;
    v$id                        number;
    v$estado_reclamo            number;
    v$fecha_reclamo             date;
    v$porcentaje_recurrente     number;
    v$tipo_movimiento           varchar2(200);
begin
  begin
    Select abierto into v$estado_liquidacion From liquidacion_haberes Where pension=x$pension And recalculo='true';
  exception
	when no_data_found then
		v$estado_liquidacion:=null;
	when others then
    v$estado_liquidacion:=null;
  end;
  if v$estado_liquidacion='false' then
    raise_application_error(v$err,'Error: el recálculo de la liquidación de la pensión está en estatus cerrado, no se puede modificar.',true);
  end if;
  begin
		Select valor_numerico into v_valor_conc_permanente From variable_global Where numero = 106;
    Select valor_numerico into v_valor_conc_haber_atrasado From variable_global Where numero = 105;
	exception
	when no_data_found then
		raise_application_error(v$err,'No se encuentran datos del concepto permanente (106)',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos del concepto permanente, mensaje:' || v$msg,true);
	end;
  begin
		Select valor_numerico into v_valor_conc_subsidio From variable_global Where numero = 128;
	exception
	when no_data_found then
		v_valor_conc_subsidio:=null;
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos del concepto subsidio (128), mensaje:' || v$msg,true);
	end;
  Begin --obtener el porcentaje maximo a descontar
    Select valor_numerico into v_porcentaje_max From variable_global Where numero = 113;
  exception
  when no_data_found then
    raise_application_error(-20009,'No se encuentran datos del porcentaje máximo a descontar (113)',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(-20009,'Error al intentar obtener los datos del datos del porcentaje máximo a descontar (113), mensaje:' || v$msg,true);
  end;
  /*Begin
		Select valor_numerico into v$porcentaje From variable_global Where numero = 124;
	exception
	when no_data_found then
		raise_application_error(v$err,'No se encuentran valor del porcentaje a descontar del salario del causante (si existe) en la variable global correspondiente(124).',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos del porcentaje a descontar, mensaje:' || v$msg,true);
  end;*/
  if (instr(upper(x$observaciones),'PORCENTAJE')>0) Then
    begin
      Select substr(x$observaciones, instr(x$observaciones,'[')+1,instr(x$observaciones,']')-instr(x$observaciones,'[')-1) into v$porcentaje_recurrente From dual;
    exception
    when others then
      v$porcentaje_recurrente:=0;
    end;
  end if;
  Begin
		Select pn.estado, pn.clase, pe.fecha_nacimiento, cp.REQUIERE_CENSO, nvl(pe2.salario,0), nvl(rp.estado,0), rp.FECHA_DICTAMEN_OTORGAR, pn2.clase,
            nvl((Select Count(distinct pe3.id) From pension pn3 inner join persona pe3 on pn3.persona = pe3.id Where pn3.causante=pe2.id And pn3.estado not in (2,4,5,10)),0) as cantrecurrente,
            pe2.porcentaje
      into v$estado_pension, v$clase_pension, v$fecha_nacimiento, v$requiere_censo, v$salario, v$estado_reclamo, v$fecha_reclamo, v$clase_pension_causante,
            v$cant_recurrente, v$porcentaje
    From pension pn inner join persona pe on pn.persona = pe.id
      inner join clase_pension cp on pn.clase = cp.id
      left outer join persona pe2 on pn.causante = pe2.id
      left outer join reclamo_pension rp on pn.id = rp.pension And rp.estado iN (4,5)
      left outer join pension pn2 on pe2.id=pn2.persona 
        And Exists (Select co.id From concepto_planilla_pago co inner join planilla_pago pp on co.planilla=pp.id 
                    Where pn2.clase = pp.clase_pension And co.clase_concepto=3 And nvl(bloqueado,'false')<>'true')
    Where pn.id=x$pension And rownum=1;
	exception
	when no_data_found then
		raise_application_error(v$err,'No se encuentran datos de la pensión',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos de la pensión, mensaje:' || v$msg,true);
  end;
  if v$estado_pension<>7 And v$estado_pension<>6 And v$estado_reclamo<>4 then --pension otorgable u otorgada, reclamo otorgable
    raise_application_error(v$err,'Error: el estado de la pensión es diferente a otorgable/otorgado (' || v$estado_pension || '), o el estado trámite (' || v$estado_reclamo || ') es diferente a otorgable/otorgado',true);
  end if;
  if x$fecha_desde>v$fecha_hasta then
    raise_application_error(v$err,'Error: la fecha desde:' || x$fecha_desde || ' no puede ser mayor a la fecha hasta:' || v$fecha_hasta || ', usadas en proceso de cálculo de liquidación.',true);
  end if;
  Delete From DETALLE_LIQU_HABER Where liquidacion_haberes in (Select id From liquidacion_haberes Where pension=x$pension And recalculo='true');
  --Delete From CONCEPTO_PENSION Where PENSION=x$pension And (desde=to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy') or hasta=last_day(v$fecha_hasta));
  Delete From liquidacion_haberes Where pension=x$pension And recalculo='true';
  begin
    Select to_date('01/' || b.mes || '/' || b.ano,'dd/mm/yyyy') into v$fecha_planilla 
    From planilla_pago a inner join planilla_periodo_pago b on a.id = b.planilla
    Where a.clase_pension=v$clase_pension And b.estado in (1,2) And rownum=1;
  exception
	when no_data_found then
		raise_application_error(v$err,'No se encuentran datos de la pensión',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos de la pensión, mensaje:' || v$msg,true);
  end;
  begin
    v$id_liquidacion_haberes:=busca_clave_id;
    Insert Into liquidacion_haberes (ID, VERSION, CODIGO, FECHA_DESDE, PENSION, FECHA_CALCULO, NUMERO_SIME, USUARIO_TRANSICION, 
                                    OBSERVACIONES, abierto, recalculo, subsidio, fecha_hasta)
    values (v$id_liquidacion_haberes, 0, x$numero_liquidacion, x$fecha_desde, x$pension, sysdate, x$sime, current_user_id, 
          x$observaciones, 'true', 'true', x$subsidio, x$fecha_hasta); 
  exception
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el encabezado de la liquidación de pensión, mensaje:' || v$msg,true);
  end;
  if (v$requiere_censo<>'true') then --solo aplica para tipo de pensiones que no requieran censos
    /*comentado a petición de Olga Febrero 2019, tomar la fechas hasta sin validar fechas de pago o reintegro, se netea restando pagos atrasados anteriores
      Begin --buscamos si la persona tiene pagos procesados, buscamos el menor, y tomamos esa fecha como hasta
      if v$estado_pension=7 And v$estado_reclamo=0 then --pension inclusion sin reclamo
        Select min(to_date('01/' || a.mes_planilla || '/' || a.ano_planilla,'dd/mm/yyyy'))
          into v$fecha_pago
        From detalle_pago_pension a inner join resumen_pago_pension b on a.resumen = b.id
            inner join clase_concepto c on a.clase_concepto = c.id
        where b.pension=x$pension And c.codigo=v_valor_conc_permanente;
      elsif v$estado_reclamo=4 or v$estado_reclamo=5 then --reintegro o reconsideracion tomamos la fecha dictamen del reclamo
        v$fecha_pago:=v$fecha_reclamo;
      end if;
    exception
    when no_data_found then
  		v$fecha_pago:=v$fecha_hasta;
  	when others then
      v$fecha_pago:=v$fecha_hasta;
    end;
    if v$fecha_pago<v$fecha_hasta then --si la fecha de pago de concepto es menor entonces tomamos esa fecha como hasta, para el calculo de haberes atrasados
      v$fecha_hasta:=v$fecha_pago;
    end if;*/
    begin --inicio calculo de haberes atrasados
      Select co.id, co.clase_concepto 
        into v$idconcepto_planilla_pago, v$idclase_concepto
      From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
        inner join concepto_planilla_pago co on pp.id = co.planilla And co.general='false' And nvl(co.bloqueado,'false')<>'true' 
        inner join variable_global vg on co.clase_concepto=vg.valor_numerico And vg.numero=105 
      Where cp.id=v$clase_pension;
    exception
    when no_data_found then
      v$idconcepto_planilla_pago:=null;
    when others then
      v$idconcepto_planilla_pago:=null;
    end;
    if v$idconcepto_planilla_pago is not null then
      while v$fecha_aux<=v$fecha_hasta loop 
        if v$salario=0 then
          if v$clase_pension=153261501337004430 then --oficio judicial toma el salario historico del causante
            begin
              if x$subsidio='false' then
                Select max(monto) into v$monto 
                From salario_historico 
                Where clase_pension=v$clase_pension_causante And clase_concepto=v_valor_conc_permanente
                  And ((v$fecha_aux between fecha_desde And fecha_hasta) or (v$fecha_aux>fecha_desde And fecha_hasta is null))
                  And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
              else
                Select sum(monto) into v$monto 
                  From salario_historico 
                  Where clase_pension=v$clase_pension_causante And clase_concepto in (v_valor_conc_permanente,v_valor_conc_subsidio)
                    And ((v$fecha_aux between fecha_desde And fecha_hasta) or (v$fecha_aux>fecha_desde And fecha_hasta is null))
                    And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
              end if;
            exception
            when no_data_found then
              v$monto:=0;
            when others then
              v$monto:=0;
            end;
          else
            begin
              if x$subsidio='false' then
                Select max(monto) into v$monto 
                From salario_historico 
                Where clase_pension=v$clase_pension And clase_concepto=v_valor_conc_permanente
                  And ((v$fecha_aux between fecha_desde And fecha_hasta) or (v$fecha_aux>=fecha_desde And fecha_hasta is null))
                  And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
              else
                Select sum(monto) into v$monto 
                  From salario_historico 
                  Where clase_pension=v$clase_pension And clase_concepto in (v_valor_conc_permanente,v_valor_conc_subsidio)
                    And ((v$fecha_aux between fecha_desde And fecha_hasta) or (v$fecha_aux>=fecha_desde And fecha_hasta is null))
                    And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
              end if;
            exception
            when no_data_found then
              v$monto:=0;
            when others then
              v$monto:=0;
            end;
          end if;
          if x$subsidio='false' And (v$monto is null or v$monto=0) then --si no hay salario historico para la clase de pension del solicitante, intentamos con la clase causante del grupo
            Select sum(monto) into v$monto 
            From salario_historico 
            Where clase_pension=v$clase_pension_causante And clase_concepto =v_valor_conc_permanente
              And ((v$fecha_aux between fecha_desde And fecha_hasta) or (v$fecha_aux>=fecha_desde And fecha_hasta is null))
              And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
          end if;
        else --la pension tiene a un causante con salario, entonces se calcula el v$porcentaje del mismo
          v$monto:=trunc(v$salario*v$porcentaje/100);
        end if;
        if v$monto<>0 then
          if to_number(to_char(v$fecha_aux,'dd'))>1 or to_char(v$fecha_aux,'mm/yyyy')=to_char(v$fecha_hasta,'mm/yyyy') then --si la fecha desde es el primer dia del mes tomamos el monto completo
            if to_char(v$fecha_aux,'mm/yyyy')<>to_char(v$fecha_hasta,'mm/yyyy') then
              Select to_date(LAST_DAY(v$fecha_aux))-to_date(v$fecha_aux) into v$dia From dual;
            elsif to_date(LAST_DAY(v$fecha_aux))=v$fecha_hasta then
              v$dia:=0;
            else
              Select to_date(v$fecha_hasta)-to_date(v$fecha_aux) into v$dia From dual;
            end if;
            if v$dia>0 then
              v$dia:=v$dia+1;
              Select to_char(LAST_DAY(v$fecha_aux),'dd')  into v$mes From dual;
              v$monto:=trunc(v$monto/v$mes);
              v$monto:=trunc(v$monto*v$dia);
            --else
              --v$monto:=0;
            end if;
          end if;
          if v$id_liquidacion_haberes is not null then
            begin
              if v$porcentaje_recurrente<>0 then
                v$monto:=trunc(v$monto*v$porcentaje_recurrente/100,0);
                v$tipo_movimiento:='Recálculo de haberes atrasados, cuota nro:' || (contador+1) || ' porcentaje:' || v$porcentaje_recurrente;
              elsif v$cant_recurrente<>0 then
                v$monto:=trunc(v$monto/v$cant_recurrente,0);
                v$tipo_movimiento:='Recálculo de haberes atrasados, cuota nro:' || (contador+1) || ' cant recurrente:' || v$cant_recurrente;
              else
                v$tipo_movimiento:='Recálculo de haberes atrasados, cuota nro:' || (contador+1);
              end if;
              v$id:=busca_clave_id;
              Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
              values (v$id, 0, v$id, v$id_liquidacion_haberes, v$fecha_aux, v$monto, v$tipo_movimiento, v$idclase_concepto, v$cant_recurrente, 'false'); 
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación, mensaje:' || v$msg,true);
            end;
          end if;
        end if;
        if contador=0 then
          v$fecha_aux:=to_date('01/' || to_char(v$fecha_aux,'mm/yyyy'),'dd/mm/yyyy');
        end if;
        v$fecha_aux:=add_months(v$fecha_aux,1); contador:=contador+1;
      end loop;
      For reg in (Select dp.monto, dp.mes_planilla, dp.ano_planilla
                  From pension pn inner join resumen_pago_pension rp on pn.id = rp.pension
                    inner join detalle_pago_pension dp on rp.id = dp.resumen
                    inner join clase_concepto cc on dp.clase_concepto=cc.id
                  Where cc.id in (v_valor_conc_haber_atrasado,153246111406004840) And pn.id=x$pension And dp.activo='true'
                    --And to_date('01/' || dp.mes_planilla || '/' || dp.ano_planilla,'dd/mm/yyyy') between x$fecha_desde And v$fecha_hasta
                    ) loop
        begin
          v$id:=busca_clave_id;
          Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
          values (v$id, 0, v$id, v$id_liquidacion_haberes, to_date('01/' || reg.mes_planilla || '/' || reg.ano_planilla,'dd/mm/yyyy'), (reg.monto*-1), 'Descuento Haber Atrasado pagado en planilla', v$idclase_concepto, v$cant_recurrente, 'false'); 
        exception
        when others then
          v$msg := SQLERRM;
          raise_application_error(v$err,'Error al intentar crear el movimiento de descuento de habere atrasado pagado, mensaje:' || v$msg,true);
        end;
      end loop;
      For reg in (Select dp.monto, dp.mes_planilla, dp.ano_planilla
                  From pension pn inner join resumen_pago_pension rp on pn.id = rp.pension
                    inner join detalle_pago_pension dp on rp.id = dp.resumen  And dp.activo='true'
                    inner join clase_concepto cc on dp.clase_concepto=cc.id
                  Where cc.id=v_valor_conc_permanente And pn.id=x$pension 
                    And to_date('01/' || dp.mes_planilla || '/' || dp.ano_planilla,'dd/mm/yyyy') between x$fecha_desde And v$fecha_hasta
                  Order by to_date('01/' || dp.mes_planilla || '/' || dp.ano_planilla,'dd/mm/yyyy')) loop
        begin
          v$id:=busca_clave_id;
          Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
          values (v$id, 0, v$id, v$id_liquidacion_haberes, to_date('01/' || reg.mes_planilla || '/' || reg.ano_planilla,'dd/mm/yyyy'), (reg.monto*-1), 'Descuento Permanente pagado en planilla', v$idclase_concepto, v$cant_recurrente, 'false'); 
        exception
        when others then
          v$msg := SQLERRM;
          raise_application_error(v$err,'Error al intentar crear el movimiento de descuento por permanente, mensaje:' || v$msg,true);
        end;
      end loop;
    end if; --FIN calculo de haberes atrasados
  else
    raise_application_error(v$err,'Error la clase de pensión asociada el registro, no admite recálculo de haberes atrasado',true);
  end if; --if (v$requiere_censo<>'true') then
  return 0;
exception
	When others then
		v$msg := SQLERRM;
		raise_application_error(v$err, v$msg, true);
end;
/
