create or replace function pension$cal_liq_habe$23629$biz(x$super number, x$numero_liquidacion varchar2, x$pension number, x$fecha_inicio date, x$sime number, x$observaciones nvarchar2) return number is
    v$err                       constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                       nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$porcentaje                number;  
    v$estado_liquidacion        VARCHAR2(5);
    v_valor_conc_sepelio        number;
    v$persona                   number;
    v$cantidad_salario          integer;
    v$fecha_defuncion           date;
    v$fecha_nacimiento_causante date;
    v_valor_conc_permanente     number;
    v_valor_conc_cobr_indebido  number;
    v_valor_conc_haber_atrasado number;
    v_porcentaje_max            number;
    v$idconcepto_planilla_pago  number;
    v$idconcepto_planilla_pagop number;
    v$idclase_concepto          number;
    v$estado_pension            integer;
    v$clase_pension             integer;
    v$clase_pension_causante    integer;
    v$clase_pension_causante2   number;
    v$requiere_censo            VARCHAR2(5);
    v$salario                   NUMBER(12,2);
    v$fecha_nacimiento          date;
    v$fecha_dictamen_otorgar    date;
    v$fecha_resolucion_otorgar  date;
    v$cant_recurrente           integer;
    v$id_pension_causante       number;
    v$fecha_desde               date;
    v$fecha_hasta               date;
    v$fecha_reclamo             date;
    v$fecha_aux                 date:=x$fecha_inicio;
    v$fecha_pago                date;
    v$cantidad                  integer;
    v$monto_deuda               number;
    v$monto_saldo_acuerdo       number;
    v$monto                     number;
    v$monto_permanente          number:=0;
    v$monto_sepelio             number:=0;
    v$dia                       integer;
    v$mes                       integer;
    contador                    integer:=0;
    v$id_liquidacion_haberes    number;
    v$id_concepto_pension       number;
    v$id                        number;
    v$causante                  number;
    x$id_acuerdo_pago           number;
    v$monto_subsidio            number:=0;
    v$monto_prorateo            number:=0;
    v$monto_maximo              number;
    v$monto_total_asignado      number:=0;
    v$estado_reclamo            number;
    v$porcentaje_recurrente     number;
    v$tipo_movimiento           varchar2(200);
begin -- calcular liquidación pensión
  begin
    Select abierto into v$estado_liquidacion From liquidacion_haberes Where pension=x$pension And recalculo='false';
  exception
	when no_data_found then
		v$estado_liquidacion:=null;
	when others then
    v$estado_liquidacion:=null;
  end;
  if v$estado_liquidacion<>'true' then
    raise_application_error(v$err,'Error: la liquidación de la pensión está en estatus cerrado, no se puede modificar (recalcular).',true);
  end if;
  Select valor_numerico into v_valor_conc_cobr_indebido From variable_global Where numero = 104;
  Select valor_numerico into v_valor_conc_haber_atrasado From variable_global Where numero = 105;
  begin
		Select valor_numerico into v_valor_conc_permanente From variable_global Where numero = 106;
	exception
	when no_data_found then
		raise_application_error(v$err,'No se encuentran datos del concepto permanente (106)',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos del concepto permanente, mensaje:' || v$msg,true);
	end;
  if (instr(upper(x$observaciones),'PORCENTAJE')>0) Then
    begin
      Select substr(x$observaciones, instr(x$observaciones,'[')+1,instr(x$observaciones,']')-instr(x$observaciones,'[')-1) into v$porcentaje_recurrente From dual;
    exception
    when others then
      v$porcentaje_recurrente:=0;
    end;
  end if;
  Begin --obtener el porcentaje maximo a descontar
    Select valor into v_porcentaje_max From variable_global Where numero = 113;
  exception
  when no_data_found then
    raise_application_error(v$err,'No se encuentran datos del porcentaje máximo a descontar (113)',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener los datos del datos del porcentaje máximo a descontar (113), mensaje:' || v$msg,true);
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
  Begin
		Select pn.estado, pn.clase, pe.fecha_nacimiento, pn.fecha_dictamen_otorgar, pn.fecha_resolucion_otorgar, pe.id, pe2.PORCENTAJE,  
           cp.REQUIERE_CENSO, nvl(pe2.salario,0), pn.causante, pn2.monto_deuda, pe2.fecha_defuncion, pe2.fecha_nacimiento,
           nvl((Select Count(distinct pe3.id) From pension pn3 inner join persona pe3 on pn3.persona = pe3.id Where pn3.causante=pe2.id And pn3.estado not in (2,4,5,10)),0) as cantrecurrente, 
           pn2.id, pn2.clase, cp.CLASE_PENSION_CAUSANTE, rp.estado
      into v$estado_pension, v$clase_pension, v$fecha_nacimiento, v$fecha_dictamen_otorgar, v$fecha_resolucion_otorgar, v$persona, v$porcentaje, 
            v$requiere_censo, v$salario, v$causante, v$monto_deuda, v$fecha_defuncion, v$fecha_nacimiento_causante,
            v$cant_recurrente, v$id_pension_causante, v$clase_pension_causante, v$clase_pension_causante2, v$estado_reclamo
    From pension pn inner join persona pe on pn.persona = pe.id
      inner join clase_pension cp on pn.clase = cp.id
      left outer join persona pe2 on pn.causante = pe2.id
      left outer join pension pn2 on pe2.id = pn2.persona And Exists (Select sh.id From salario_historico sh where pn2.clase = sh.clase_pension )
        --And Exists (Select co.id From concepto_planilla_pago co inner join planilla_pago pp on co.planilla=pp.id 
        --            Where pn2.clase = pp.clase_pension And co.clase_concepto=3 And nvl(bloqueado,'false')<>'true')
      left outer join reclamo_pension rp on pn.id = rp.pension And rp.estado in (4,5)
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
  if v$estado_pension=6 or v$estado_reclamo=4 then
    Select max(nvl(rp.FECHA_DICTAMEN_OTORGAR,rp.FECHA_DICTAMEN_RECO_OTORGAR))
      into v$fecha_reclamo
    From reclamo_pension rp 
    Where rp.pension=x$pension And rp.estado=4; --reclamo otorgable
    if v$fecha_reclamo>v$fecha_dictamen_otorgar or v$fecha_dictamen_otorgar is null then
      v$fecha_hasta:=v$fecha_reclamo;
    else
      v$fecha_hasta:=v$fecha_dictamen_otorgar;
    end if;
  elsif v$estado_pension=7 then
    Select max(nvl(rp.FECHA_RESOLUCION_OTORGAR,rp.FECHA_RESOLUCION_RECO_OTO))
      into v$fecha_reclamo
    From reclamo_pension rp 
    Where rp.pension=x$pension And rp.estado=5; --reclamo otorgado
    if v$fecha_reclamo>v$fecha_resolucion_otorgar or v$fecha_resolucion_otorgar is null then
      v$fecha_hasta:=v$fecha_reclamo;
    else
      v$fecha_hasta:=v$fecha_resolucion_otorgar;
    end if;
  end if;
  if v$fecha_hasta is null then
    raise_application_error(v$err,'Error: la fecha hasta:' || v$fecha_hasta || ', es nulo, para el estado de la pension ' || v$estado_pension,true);
  end if;
  if x$fecha_inicio>v$fecha_hasta then
    raise_application_error(v$err,'Error: la fecha desde:' || x$fecha_inicio || ' no puede ser mayor a la fecha hasta:' || v$fecha_hasta || ', usadas en proceso de cálculo de liquidación.',true);
  end if;
  if v$cant_recurrente=0 then 
    v$cant_recurrente:=1;
  end if;
  begin
    Select id, saldo 
      into x$id_acuerdo_pago, v$monto_saldo_acuerdo 
    From acuerdo_pago 
    Where pension=v$id_pension_causante or persona=v$persona; --el acuerdo de pago puede estar a nombre del causante o otra persona no relacionada
  exception
  when no_data_found then
    x$id_acuerdo_pago:=null;
  when others then
    x$id_acuerdo_pago:=null;
  end;
  begin
    Delete From DETALLE_LIQU_HABER Where liquidacion_haberes in (Select id From liquidacion_haberes Where pension=x$pension And recalculo='false');
    Delete From liquidacion_haberes Where pension=x$pension And recalculo='false';
    v$id_liquidacion_haberes:=busca_clave_id;
    Insert Into liquidacion_haberes (ID, VERSION, CODIGO, FECHA_DESDE, PENSION, FECHA_CALCULO, NUMERO_SIME, USUARIO_TRANSICION, OBSERVACIONES, abierto, recalculo)
    values (v$id_liquidacion_haberes, 0, x$numero_liquidacion, x$fecha_inicio, x$pension, sysdate, x$sime, current_user_id, x$observaciones, 'true', 'false'); 
  exception
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el encabezado de la liquidación de pensión, mensaje:' || v$msg,true);
  end;
  if (v$requiere_censo<>'true') then --solo aplica para tipo de pensiones que no requieran censos 
    Begin --buscamos si la persona tiene pagos procesados, buscamos el menor, y tomamos esa fecha como hasta
      Select min(to_date('01/' || a.mes_planilla || '/' || a.ano_planilla,'dd/mm/yyyy'))
        into v$fecha_pago
      From detalle_pago_pension a inner join resumen_pago_pension b on a.resumen = b.id 
      where b.pension=x$pension;
    exception
    when no_data_found then
  		v$fecha_pago:=v$fecha_hasta;
  	when others then
      v$fecha_pago:=v$fecha_hasta;
    end;
    if v$fecha_pago<v$fecha_hasta And v$fecha_pago is not null then --si la fecha de pago de concepto es menor entonces tomamos esa fecha como hasta, para el calculo de haberes atrasados
      v$fecha_hasta:=v$fecha_pago;
    end if;
    Update liquidacion_haberes set fecha_hasta=v$fecha_hasta where id=v$id_liquidacion_haberes;
    begin --inicio calculo permanente
      Select co.id, co.clase_concepto
        into v$idconcepto_planilla_pagop, v$idclase_concepto
      From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
        inner join concepto_planilla_pago co on pp.id = co.planilla And co.general='false' And co.clase_concepto=v_valor_conc_permanente And nvl(co.bloqueado,'false')<>'true'
      Where cp.id=v$clase_pension;
    exception
    when no_data_found then
      v$idconcepto_planilla_pagop:=null;
    when others then
      v$idconcepto_planilla_pagop:=null;
    end;
    if v$idconcepto_planilla_pagop is not null then --el permantente es un concepto no general, hay que crear un asignado a la pension
      if v$salario=0 then --buscamos si existen conceptos general='false' existentes en el historico de salario vigente (fecha_hasta is null)
        begin
          if v$clase_pension_causante is not null or v$clase_pension_causante2 is not null then
            Select max(monto) into v$monto 
            From salario_historico 
            Where (clase_pension=v$clase_pension_causante or clase_pension=v$clase_pension_causante2) 
              And clase_concepto=v_valor_conc_permanente
              --And ((v$fecha_defuncion between fecha_desde And fecha_hasta) or (v$fecha_defuncion>=fecha_desde And fecha_hasta is null))
              And fecha_hasta is null
              And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
          else
            Select max(monto) into v$monto 
            From salario_historico 
            Where clase_pension=v$clase_pension And clase_concepto=v_valor_conc_permanente
              And fecha_hasta is null
              And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
          end if;
        exception
        when no_data_found then
          v$monto:=0;
        when others then
          v$monto:=0;
        end;
      else --la pension tiene a un causante con salario, entonces se calcula el v$porcentaje del mismo
        v$monto:=round(v$salario*v$porcentaje/100,0);
      end if;
      v$monto_permanente:=planilla_pago$obtenermonto(v$idconcepto_planilla_pagop, v$monto);
      if v$monto_permanente>0 then
        begin
          v$id:=busca_clave_id;
          Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, 
                                          clase_concepto, cant_recurrente, proyectado)
          values (v$id, 0, v$id, v$id_liquidacion_haberes, to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy'), trunc(v$monto_permanente/v$cant_recurrente,0),'Asignado Permanente.', 
                  v$idclase_concepto, v$cant_recurrente, 'false'); 
        exception
        when others then
          v$msg := SQLERRM;
          raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (permanente), mensaje:' || v$msg,true);
        end;
      end if;
    else --el permante es un concepto general, no se personaliza en la liquidaciòn, se obtiene como valor referencial
      begin
        Select co.monto, co.id
          into v$monto_permanente, v$idconcepto_planilla_pagop
        From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
          inner join concepto_planilla_pago co on pp.id = co.planilla And co.general='true' And co.clase_concepto=v_valor_conc_permanente And nvl(co.bloqueado,'false')<>'true'
        Where cp.id=v$clase_pension;
      exception
      when no_data_found then
        v$monto_permanente:=0; v$idconcepto_planilla_pagop:=null;
      when others then
        v$monto_permanente:=0; v$idconcepto_planilla_pagop:=null;
      end;
      if v$idconcepto_planilla_pagop is not null then
        v$monto_permanente:=planilla_pago$obtenermonto(v$idconcepto_planilla_pagop, v$monto_permanente);
      end if;
    end if; --FIN calculo permanente
    --if v$monto_permanente=0 then
    -- raise_application_error(v$err,'Error: no se consigue monto del asignado permanente general o no, de la clase pensión, monto:' || v$monto_permanente,true);
    --end if;
    begin --inicio calculo de gastos de sepelio
      Select co.id, cc.id, cc.clase_concepto
        into v_valor_conc_sepelio, v$idconcepto_planilla_pago, v$idclase_concepto
      From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
        inner join concepto_planilla_pago cc on pp.id = cc.planilla And nvl(cc.bloqueado,'false')<>'true'
        inner join clase_concepto co on cc.clase_concepto = co.id
        inner join variable_global vg on co.id = vg.valor_numerico And vg.numero=125
      Where cp.id=v$clase_pension;
    exception
    when no_data_found then
      v_valor_conc_sepelio:=null;
    when others then
      v_valor_conc_sepelio:=null;
    end;
    if v_valor_conc_sepelio is not null And v$idconcepto_planilla_pago is not null then
      begin
        Select valor_numerico into v$cantidad_salario From variable_global Where numero = 126;
      exception
      when no_data_found then
        raise_application_error(v$err,'No se encuentran datos de la cantidad de permanentes por concepto de gastos de Sepelio (126)',true);
      when others then
        v$msg := SQLERRM;
        raise_application_error(v$err,'Error al intentar obtener los datos de la cantidad de permanentes por concepto de gastos de Sepelio, mensaje:' || v$msg,true);
      end;
      begin --validamos que no se haya pagado gastos de sepelio del causante a otro heredero/beneficiario
        Select Count(dp.id) into v$cantidad
        From persona pe inner join pension pn on pe.id = pn.persona
          inner join persona pe2 on pn.causante = pe2.id
          inner join resumen_pago_pension rp on pn.id = rp.pension 
          inner join detalle_pago_pension dp on rp.id = dp.resumen And dp.activo='true'
          inner join clase_concepto co on dp.clase_concepto = co.id And co.id=5
        Where pe2.id=v$causante;
      exception
      when no_data_found then
        v$cantidad:=0;
      when others then
        v$cantidad:=0;
      end; --comentado a peticiòn del usuario el 19/04/2018 para que proratee los gastos de sepelio entre los recurrentes
      if v$cantidad=0 then
        if v$salario=0 then
          begin
            Select max(monto) into v$monto 
            From salario_historico 
            Where clase_pension=v$clase_pension_causante And clase_concepto=v_valor_conc_permanente
              And ((v$fecha_defuncion between fecha_desde And fecha_hasta) or (v$fecha_defuncion>=fecha_desde And fecha_hasta is null))
              And (fecha_nacimiento>v$fecha_nacimiento_causante or fecha_nacimiento is null);
          exception
          when no_data_found then
            v$monto:=0;
          when others then
            v$monto:=0;
          end;
        else --la pension tiene a un causante con salario, entonces se calcula el v$porcentaje del mismo
          v$monto:=trunc(v$salario*v$porcentaje/100);
        end if;
        v$monto:=planilla_pago$obtenermonto(v$id_liquidacion_haberes, v$monto);
        v$monto:=v$monto*v$cantidad_salario;
        if v$monto<>0 then
          begin
            v$id:=busca_clave_id;
            Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
            values (v$id, 0, v$id, v$id_liquidacion_haberes, to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy'), trunc(v$monto/v$cant_recurrente,0),'Gastos de Sepelio.', v$idclase_concepto,v$cant_recurrente, 'false'); 
          exception
          when others then
            v$msg := SQLERRM;
            raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (gastos de sepelio), mensaje:' || v$msg,true);
          end;
        end if;
      end if; --if v$cantidad=0 then
    end if; --if v_valor_conc_sepelio is not null And v$idconcepto_planilla_pago is not null then
    --FIN calculo de gastos de sepelio ******************************
    begin  --inicio calculo de haberes atrasados, si no hay uno anterior
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
      while v$fecha_aux<v$fecha_hasta loop 
        if v$salario=0 then
          begin
            /*if v$clase_pension_causante is not null or v$clase_pension_causante2 is not null then
              Select max(monto) into v$monto 
              From salario_historico 
              Where (clase_pension=v$clase_pension_causante or clase_pension=v$clase_pension_causante2) 
                And clase_concepto=v_valor_conc_permanente
                And ((v$fecha_aux between fecha_desde And fecha_hasta) or (v$fecha_aux>=fecha_desde And fecha_hasta is null))
                And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
            else*/
              Select max(monto) into v$monto 
              From salario_historico 
              Where clase_pension=v$clase_pension And clase_concepto=v_valor_conc_permanente
                And ((v$fecha_aux between fecha_desde And fecha_hasta) or (v$fecha_aux>=fecha_desde And fecha_hasta is null))
                And (fecha_nacimiento>v$fecha_nacimiento or fecha_nacimiento is null);
            --end if;
          exception
          when no_data_found then
            v$monto:=0;
          when others then
            v$monto:=0;
            v$msg := SQLERRM;
            raise_application_error(v$err,'Error al intentar obtener el salario historico, mensaje:' || v$msg,true);
          end;
          if v$idconcepto_planilla_pagop is not null then
            v$monto:=planilla_pago$obtenermonto(v$idconcepto_planilla_pagop, v$monto);
          end if;
        else --la pension tiene a un causante con salario, entonces se calcula el v$porcentaje del mismo
          v$monto:=trunc(v$salario*v$porcentaje/100);
        end if;
        if v$monto<>0 then  
          if to_char(v$fecha_aux,'mm/yyyy')=to_char(v$fecha_hasta,'mm/yyyy') then
            Select v$fecha_hasta-v$fecha_aux, to_char(LAST_DAY(v$fecha_aux),'dd')  into v$dia, v$mes 
            From dual; --prorateamos la diferencia entre el ultimo dia del mes y la fecha desde
            if v$dia>0 then
              v$monto:=trunc(v$monto/v$mes);
              v$monto:=trunc(v$monto*(v$dia+1));
            else
              v$monto:=0;
            end if;
          elsif to_number(to_char(v$fecha_aux,'dd'))>1 then --si la fecha desde es el primer dia del mes tomamos el monto completo
            Select LAST_DAY(v$fecha_aux)-to_date(v$fecha_aux), to_char(LAST_DAY(v$fecha_aux),'dd')  into v$dia, v$mes 
            From dual; --prorateamos la diferencia entre el ultimo dia del mes y la fecha desde
            if v$dia>0 then
              v$monto:=trunc(v$monto/v$mes);
              v$monto:=trunc(v$monto*(v$dia+1));
            else
              v$monto:=0;
            end if;
            v$fecha_aux:=to_date('01/' || to_char(v$fecha_aux,'mm/yyyy'),'dd/mm/yyyy');
          end if;
          if v$id_liquidacion_haberes is not null And v$monto>0 then
            begin
              v$id:=busca_clave_id;
              if v$porcentaje_recurrente<>0 then
                v$monto:=trunc(v$monto*v$porcentaje_recurrente/100,0);
                v$tipo_movimiento:='Haberes atrasados, cuota nro:' || (contador+1) || ' porcentaje:' || v$porcentaje_recurrente;
              elsif v$cant_recurrente<>0 then
                v$monto:=trunc(v$monto/v$cant_recurrente,0);
                v$tipo_movimiento:='Haberes atrasados, cuota nro:' || (contador+1) || ' cant recurrente:' || v$cant_recurrente;
              else
                v$tipo_movimiento:='Haberes atrasados, cuota nro:' || (contador+1);
              end if;
              Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
              values (v$id, 0, v$id, v$id_liquidacion_haberes, v$fecha_aux, v$monto, v$tipo_movimiento, v$idclase_concepto, v$cant_recurrente, 'false');
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (haberes atrasados), mensaje:' || v$msg,true);
            end;
          end if;
        end if;
        v$fecha_aux:=add_months(v$fecha_aux,1); contador:=contador+1;
      end loop;
    end if; --FIN calculo de haberes atrasados
    begin
      Select co.id, co.clase_concepto
        into v$idconcepto_planilla_pago, v$idclase_concepto
      From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
        inner join concepto_planilla_pago co on pp.id = co.planilla And co.general='false' And nvl(co.bloqueado,'false')<>'true'
        inner join variable_global vg on co.clase_concepto=vg.valor_numerico And vg.numero=104 
      Where cp.id=v$clase_pension;
    exception
    when no_data_found then
      v$idconcepto_planilla_pago:=null;
    when others then
      v$idconcepto_planilla_pago:=null;
    end;
    if v$causante is not null And v$monto_deuda>0 And x$id_acuerdo_pago is null  then --inicio calculo cobros indebidos
      if v$idconcepto_planilla_pago is not null then  
        /*if ((v_porcentaje_max * v$monto_permanente) / 100)>v$monto_deuda then
          v$monto := (v_porcentaje_max * v$monto_permanente) / 100;
          v$fecha_desde:=to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy');
          v$cantidad:=round(v$monto_permanente/v$monto,0);
          v$fecha_hasta:=add_months(v$fecha_hasta,v$cantidad);
        else
          v$monto :=v$monto_deuda;
          v$fecha_desde:=to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy');
          v$fecha_hasta:=last_day(v$fecha_hasta);
        end if;*/
        v$monto :=v$monto_deuda;
        if v$monto>0 then
          begin
            v$id:=busca_clave_id;
            Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
            values (v$id, 0, v$id, v$id_liquidacion_haberes, to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy'), trunc(v$monto/v$cant_recurrente,0),'Dcto. por cobro indebido (rec:' || v$cant_recurrente ||')', v$idclase_concepto, v$cant_recurrente, 'false'); 
          exception
          when others then
            v$msg := SQLERRM;
            raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (cobro indebido), mensaje:' || v$msg,true);
          end;
        end if;
      end if;
    elsif x$id_acuerdo_pago is not null And v$monto_saldo_acuerdo>0 then
      begin
        Select id, monto
          into v$id_concepto_pension, v$monto 
        From CONCEPTO_PENSION  Where PENSION=x$pension And acuerdo_pago =x$id_acuerdo_pago;
      exception
      when no_data_found then
        v$id_concepto_pension:=null;v$monto:=0;
      when others then
        v$id_concepto_pension:=null;v$monto:=0;
      end;
      if v$monto=0 then
        v$monto :=trunc(v$monto_saldo_acuerdo/v$cant_recurrente,0);
      end if;
      begin
        v$id:=busca_clave_id;
        Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, concepto_pension, proyectado)
        values (v$id, 0, v$id, v$id_liquidacion_haberes, to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy'), v$monto,'Dcto. por cobro indebido (rec:' || v$cant_recurrente ||')', v$idclase_concepto, v$id_concepto_pension, 'false'); 
      exception
      when others then
        v$msg := SQLERRM;
        raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (cobro indebido final), mensaje:' || v$msg,true);
      end;
    end if; --FIN calculo cobros indebidos
    if to_char(x$fecha_inicio,'mm/yyyy')=to_char(v$fecha_hasta,'mm/yyyy') And v$monto_permanente>0 then --si el mes desde es el mismo de la fecha de la resolucion/dictamen calculamos prorateo para permanente y subsidio si lo hay
      begin
        Select co.id, co.clase_concepto
          into v$idconcepto_planilla_pago, v$idclase_concepto
        From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
          inner join concepto_planilla_pago co on pp.id = co.planilla And co.general='false' And nvl(co.bloqueado,'false')<>'true'
          inner join variable_global vg on co.clase_concepto=vg.valor_numerico And vg.numero=127 
        Where cp.id=v$clase_pension;
      exception
      when no_data_found then
        v$idconcepto_planilla_pago:=null;
      when others then
        v$idconcepto_planilla_pago:=null;
      end;
      Select to_number(to_char(x$fecha_inicio,'dd'))-1 into v$dia From dual; --prorateamos la diferencia entre el ultimo dia del mes y la fecha desde
      if v$idconcepto_planilla_pago is not null then
        if to_number(to_char(v$fecha_hasta,'dd'))>1 then --si la fecha desde es el primer dia del mes tomamos el monto completo
          if v$dia>0 then
            v$monto_prorateo:=trunc(trunc(v$monto_permanente/v$cant_recurrente,0)/30);
            v$monto_prorateo:=trunc(v$monto_prorateo*v$dia);
          else
            v$monto_prorateo:=0;
          end if;
        else
          v$monto_prorateo:=0;
        end if;
      end if; --fin prorateo permanente
      begin --inicio prorateo subsidio
        Select co.monto into v$monto_subsidio
        From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
          inner join concepto_planilla_pago co on pp.id = co.planilla  And co.general='true' And nvl(co.bloqueado,'false')<>'true'
          inner join variable_global vg on co.clase_concepto=vg.valor_numerico And vg.numero=128
        Where cp.id=v$clase_pension;
      exception
      when no_data_found then
        v$monto_subsidio:=0;
      when others then
        v$monto_subsidio:=0;
      end;
      if v$idconcepto_planilla_pago is not null And v$monto_subsidio>0 And v$dia>1 then
          v$monto:=trunc(v$monto_subsidio/30);
          v$monto_prorateo:=v$monto_prorateo+trunc(v$monto*v$dia);
      end if;  --fin calcular prorateo para permanente y subsidio si lo hay
    end if; --fin calcular prorateo para permanente y subsidio si lo hay
    if v$monto_prorateo>0 And v$id_liquidacion_haberes is not null then
      begin
        v$id:=busca_clave_id;
        Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, proyectado)
        values (v$id, 0, v$id, v$id_liquidacion_haberes, v$fecha_hasta, v$monto_prorateo,'Prorateo pago parcial, cant. dias descontados:' || v$dia, v$idclase_concepto, 'false'); 
      exception
      when others then
        v$msg := SQLERRM;
        raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (prorateo subsidio), mensaje:' || v$msg,true);
      end;
    end if;
    begin
			Select valor into v$monto_maximo From variable_global Where numero = 114;
		exception
		when no_data_found then
			v$monto_maximo:=0;
		when others then
			raise_application_error(v$err,'Error al intentar obtener los datos del monto máximo a pagar',true);
		end;
    for reg in (Select c.codigo as clase_concepto, c.tipo_concepto, sum(b.monto) as monto
                From liquidacion_haberes a inner join detalle_liqu_haber b on a.id = b.liquidacion_haberes
                  inner join clase_concepto c on b.clase_concepto = c.id
                Where a.id=v$id_liquidacion_haberes
                Group By c.codigo, c.tipo_concepto 
                Order by to_number(c.codigo)) loop
      if reg.clase_concepto =v_valor_conc_permanente then
        v$monto_permanente:= reg.monto;
      end if;
      if reg.clase_concepto =v_valor_conc_haber_atrasado then
        v$monto_deuda:=reg.monto;
        if v$monto_deuda>v$monto_maximo then
          v$fecha_hasta:=to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy');
          Select co.clase_concepto into v$idclase_concepto
          From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
            inner join concepto_planilla_pago co on pp.id = co.planilla And co.general='false' And nvl(co.bloqueado,'false')<>'true'
          Where co.clase_concepto=v_valor_conc_haber_atrasado And cp.id=v$clase_pension;
          WHILE v$monto_deuda > 0 loop
            begin
              if v$monto_deuda>v$monto_maximo then
                v$monto:=v$monto_maximo;
                v$monto_deuda:=v$monto_deuda-v$monto_maximo;
              else
                v$monto:=v$monto_deuda;
                v$monto_deuda:=0;
              end if;
              v$id:=busca_clave_id;
              Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
              values (v$id, 0, v$id, v$id_liquidacion_haberes, v$fecha_hasta, v$monto,'Proyección de Pago', v$idclase_concepto,v$cant_recurrente, 'true');
              --division eliminada por SIAU 11819 trunc(v$monto/v$cant_recurrente,0)
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (haberes atrasados), mensaje:' || v$msg,true);
            end;
            v$fecha_hasta:=add_months(v$fecha_hasta,12);
          END LOOP;
        end if;
      end if;
      if reg.tipo_concepto=1 then
        if reg.clase_concepto =v_valor_conc_permanente then
          v$monto_total_asignado:=v$monto_total_asignado+((reg.monto*25)/100);
        else
          v$monto_total_asignado:=v$monto_total_asignado+reg.monto;
        end if;
      end if;
      if reg.clase_concepto =v_valor_conc_cobr_indebido then
        if reg.monto>v$monto_total_asignado then
          contador:=1; v$monto_deuda:=reg.monto; v$monto:=0;
          v$fecha_hasta:=to_date('01/' || to_char(v$fecha_hasta,'mm/yyyy'),'dd/mm/yyyy');
          v$fecha_aux:=v$fecha_hasta;
          while v$monto_deuda > 0 loop
            if contador=1 then
              v$monto_deuda:=v$monto_deuda-v$monto_total_asignado;
              v$monto:=v$monto+v$monto_total_asignado;
              Select co.clase_concepto into v$idclase_concepto
              From planilla_pago pp inner join clase_pension cp on pp.clase_pension = cp.id
                inner join concepto_planilla_pago co on pp.id = co.planilla And co.general='false' And nvl(co.bloqueado,'false')<>'true'
              Where co.clase_concepto=v_valor_conc_cobr_indebido And cp.id=v$clase_pension;
            else
              --if v$monto_deuda>((v$monto_permanente*25)/100) then
                v$monto_deuda:=v$monto_deuda-((v$monto_permanente*25)/100);
                v$monto:=v$monto+((v$monto_permanente*25)/100);
              --else
                --v$monto_deuda:=v$monto_deuda-v$monto_deuda;
                --v$monto:=v$monto+v$monto_deuda;
              --end if;
            end if;
            v$fecha_aux:=add_months(v$fecha_aux,1);
            if to_char(v$fecha_aux,'yyyy')<>to_char(v$fecha_hasta,'yyyy') then
              begin
                v$id:=busca_clave_id;
                Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
                values (v$id, 0, v$id, v$id_liquidacion_haberes, v$fecha_hasta, v$monto,'Proyección de Descuento', v$idclase_concepto,v$cant_recurrente, 'true'); 
              exception
              when others then
                v$msg := SQLERRM;
                raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (cobro indebido), mensaje:' || v$msg,true);
              end;
              v$fecha_hasta:=v$fecha_aux;
              v$monto:=0;
            end if;
            contador:=contador+1;
          end loop;
          if (v$monto+v$monto_deuda)>0 then
            begin
              v$id:=busca_clave_id;
              Insert Into DETALLE_LIQU_HABER (ID, VERSION, CODIGO, LIQUIDACION_HABERES, FECHA, MONTO, TIPO_MOVIMIENTO, clase_concepto, cant_recurrente, proyectado)
              values (v$id, 0, v$id, v$id_liquidacion_haberes, v$fecha_aux, (v$monto+v$monto_deuda),'Proyección de Descuento', v$idclase_concepto,v$cant_recurrente, 'true'); 
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el movimiento de liquidación (cobro indebido final), mensaje:' || v$msg,true);
            end;
          end if;
        end if;
      end if;
    end loop;
  end if; --if (v$requiere_censo<>'true') then
  return 0;
exception
	When others then
		v$msg := SQLERRM;
		raise_application_error(v$err, v$msg, true);
end;
/
