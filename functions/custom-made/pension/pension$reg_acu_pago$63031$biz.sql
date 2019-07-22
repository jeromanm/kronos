create or replace function pension$reg_acu_pago$63031$biz(x$super number, x$pension number, x$saldo_inicial number, x$expediente_acuerdo nvarchar2, 
                                                          x$descripcion_acuerdo nvarchar2, x$fecha_acuerdo date, x$persona_deudor number, x$monto_cuota number) return number is
    v$err                         constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                         nvarchar2(2000); -- a character string of at most 2048 bytes?
    v_id_pago                     number;
    x$id_acuerdo_pago             number;
    x$idcausante                  number;
    x$cant_planilla_exceso        number;
    v$cant_cuota                  number;
    v$cant                        number;
    v$monto_saldo                 number;
    v$monto_distribuir            number;
    v_valor_conc_cobros_indebidos number;
    v$idconcepto_planilla_pago    number;
    v$idconcepto_pension          number;
    v$cant_concepto               number;
    v$fecha_resumen               date;
    contador                      integer:=0;
    v$desde                       date;
    v$hasta                       date;
    v$requiere_censo              varchar2(5);
    v$pension_deudor              number;
    v$clase_pension_deudor        number;
    v$nombre_deudor               varchar(100);
    v$fecha_defuncion             date;
    v$cant_defuncion              integer;
    v$cedula_deudor               varchar(100);
	-- registrar acuerdo pago
begin
    begin
      Select pn.persona, pn.cant_planilla_exceso, cp.requiere_censo
        into x$idcausante, x$cant_planilla_exceso, v$requiere_censo
      From pension pn inner join clase_pension cp on pn.clase = cp.id
      Where pn.id=x$pension;
    exception
    when no_data_found then
      v$msg := util.format(util.gettext('No se encontraron datos del %s de la %s = %s'), 'causante', 'pension', x$pension);
      raise_application_error(v$err, v$msg, true);
    end;
    if x$monto_cuota>x$saldo_inicial then
      raise_application_error(v$err,'Error: el monto de la cuota no puede ser mayor al saldo inicial.',true);
    end if;
    begin
      Select pe.fecha_defuncion, count(de.id), pe.codigo
        into v$fecha_defuncion, v$cant_defuncion, v$cedula_deudor 
      From persona pe left outer join defuncion de on pe.codigo = de.cedula And de.informacion_invalida<>'true'
      Where pe.id=x$persona_deudor
      Group By pe.fecha_defuncion, pe.codigo;
    exception
    when no_data_found then
      v$fecha_defuncion:=null; v$cant_defuncion:=0;
    end;
    if v$fecha_defuncion is not null or v$cant_defuncion>0 then
      raise_application_error(v$err,'Error: el encargado de la deuda cédula nro:' || v$cedula_deudor || ', se encuentra registrado como fallecido.',true);
    end if;
    --if mod(x$saldo_inicial,x$monto_cuota)<>0 then
    --  raise_application_error(v$err,'Error: la cantidad de cuotas resultante de dividir ' || x$saldo_inicial || ' y ' || x$monto_cuota || ' no es exacto.',true);
    --end if;
    begin
      Select id into x$id_acuerdo_pago From acuerdo_pago Where pension=x$pension;
    exception
    when no_data_found then
      x$id_acuerdo_pago:=null;
    when others then
      x$id_acuerdo_pago:=null;
    end;
    begin
      if x$id_acuerdo_pago is null then
        x$id_acuerdo_pago:=busca_clave_id;
        insert into acuerdo_pago (ID, VERSION, CODIGO, PERSONA, PENSION, FECHA, MONTO, CUOTA, SALDO)
        values (x$id_acuerdo_pago, 0, x$id_acuerdo_pago, x$persona_deudor, x$pension, sysdate, x$saldo_inicial, x$monto_cuota, null);
      else
        update acuerdo_pago set persona=x$persona_deudor, monto=x$saldo_inicial, cuota=x$monto_cuota
        Where id=x$id_acuerdo_pago;
      end if;
    exception
    when others then
      raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
    End;
    v$cant_cuota:=x$saldo_inicial/x$monto_cuota;
    Update pension set expediente_acuerdo = x$expediente_acuerdo, descripcion_acuerdo = x$descripcion_acuerdo, fecha_acuerdo = x$fecha_acuerdo,
                      persona_deudor = x$persona_deudor, monto_cuota = x$monto_cuota, observaciones_anular_acuerdo = null
    Where id = x$pension;
    if not SQL%FOUND then
      v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id', x$pension);
      raise_application_error(v$err, v$msg, true);
    end if;
    begin
      Select valor_numerico into v_valor_conc_cobros_indebidos From variable_global Where numero = 104;
    exception
    when no_data_found then
      raise_application_error(v$err,'No se encuentran datos del concepto cobros indebidos',true);
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 200);
      raise_application_error(v$err,'Error al intentar obtener los datos del concepto cobros indebidos, mensaje:' || v$msg,true);
    end;
    begin
      Select Count(persona) into v$cant From pension where causante=x$idcausante And estado in (6,7) And tiene_objecion='false';
    exception
    when others then
      v$cant:=0;
    end;
    if v$cant>0 then --se revisan los recurrentes 
      v$monto_saldo:=x$saldo_inicial;
      v$monto_distribuir:=x$monto_cuota/v$cant;
      for reg in (Select pn.id, pn.persona, pn.clase, pe.nombre
                  From pension pn inner join persona pe on pn.persona = pe.id
                  Where pn.causante=x$idcausante And pn.estado in (6,7)
                    And pn.tiene_objecion='false') loop
        begin
          Select co.id, (Select max(to_date('01/' || pe.mes || '/' || pe.ano,'dd/mm/yyyy')) From planilla_periodo_pago pe Where pp.id = pe.planilla And pe.estado in (3)),
                (Select Count(cn.id) From concepto_pension cn Where co.id=cn.clase And cn.pension=reg.id) as cant
            into v$idconcepto_planilla_pago, v$fecha_resumen, v$cant_concepto
          From planilla_pago pp inner join concepto_planilla_pago co on pp.id = co.planilla And pp.clase_pension=reg.clase
            inner join clase_concepto cc on co.clase_concepto = cc.id And cc.codigo=v_valor_conc_cobros_indebidos;
        exception
        when no_data_found then
          v$idconcepto_planilla_pago:=null;
          v$msg := util.format(util.gettext('No se encontraron datos de la %s de la %s'), 'clase concepto', v$idconcepto_planilla_pago);
          raise_application_error(v$err, v$msg, true);
        when others then
          v$idconcepto_planilla_pago:=null;
          v$msg := SUBSTR(SQLERRM, 1, 200);
          raise_application_error(v$err,'Error al intentar obtener los datos del concepto cobros indebidos, mensaje:' || v$msg,true);
        end;
        if v$cant_concepto>0 then
          raise_application_error(v$err,'Error la pensión ' || reg.id || ' ya tiene un asignado del concepto cobros indebidos, mensaje:' || v$msg, true);
        end if;
        if v$idconcepto_planilla_pago is not null then
          if contador=v$cant then --se llegó al final de los recurrentes, se toma el monto del saldo
            v$monto_distribuir:=v$monto_saldo;
          end if;
          begin
            Select add_months(v$fecha_resumen,1) into v$desde From dual;
            Select add_months(v$fecha_resumen, trunc(v$cant_cuota)) into v$hasta From dual;
            v$idconcepto_pension:=busca_clave_id;
            Insert Into CONCEPTO_PENSION (ID, VERSION, CODIGO, PENSION, CLASE, MONTO, bloqueado, cancelado, desde, hasta, acuerdo_pago)
            values (v$idconcepto_pension, 0, v$idconcepto_pension, reg.id, v$idconcepto_planilla_pago, v$monto_distribuir, 'false','false', v$desde, v$hasta, x$id_acuerdo_pago);
          exception
          when others then
            v$msg := SUBSTR(SQLERRM, 1, 200);
            raise_application_error(v$err,'Error al intentar crear el asignado a la persona:' || reg.persona || '. Mensaje:' || v$msg,true);
          end;
          contador:=contador+1; v$monto_saldo:=v$monto_saldo-(x$monto_cuota*v$cant);
        end if;
      end loop;
    else --se revisa si el deudor tiene pension otorgable u otorgada, para asignarle una deduccion por nomina
      begin
        Select pn.id, pn.clase, pe.nombre
          into v$pension_deudor, v$clase_pension_deudor, v$nombre_deudor
        From pension pn inner join persona pe on pn.persona = pe.id
        Where pe.id=x$persona_deudor And pn.estado in (6,7)
          And pn.tiene_objecion='false';
      exception
      when no_data_found then
        v$pension_deudor:=null;
      when others then
        v$pension_deudor:=null;
      end;
      if v$pension_deudor is not null then
        begin
          Select co.id, (Select max(to_date('01/' || pe.mes || '/' || pe.ano,'dd/mm/yyyy')) From planilla_periodo_pago pe Where pp.id = pe.planilla And pe.estado in (3)),
                (Select Count(cn.id) From concepto_pension cn Where co.id=cn.clase And cn.pension=v$pension_deudor) as cant
            into v$idconcepto_planilla_pago, v$fecha_resumen, v$cant_concepto
          From planilla_pago pp inner join concepto_planilla_pago co on pp.id = co.planilla And pp.clase_pension=v$clase_pension_deudor
            inner join clase_concepto cc on co.clase_concepto = cc.id And cc.codigo=v_valor_conc_cobros_indebidos;
        exception
        when no_data_found then
          v$idconcepto_planilla_pago:=null;
        when others then
          v$idconcepto_planilla_pago:=null;
        end;
        if v$cant_concepto>0 then
          raise_application_error(v$err,'Error la pensión ' || v$pension_deudor || ' ya tiene un asignado del concepto cobros indebidos.', true);
        end if;
        if v$idconcepto_planilla_pago is not null then
          begin
            Select add_months(v$fecha_resumen,1) into v$desde From dual;
            Select add_months(v$fecha_resumen, trunc(v$cant_cuota)) into v$hasta From dual;
            v$idconcepto_pension:=busca_clave_id;
            Insert Into CONCEPTO_PENSION (ID, VERSION, CODIGO, PENSION, CLASE, MONTO, bloqueado, cancelado, desde, hasta, acuerdo_pago, cant_recurrente)
            values (v$idconcepto_pension, 0, v$idconcepto_pension, v$pension_deudor, v$idconcepto_planilla_pago, x$monto_cuota, 'false','false', v$desde, v$hasta, x$id_acuerdo_pago, 1);
          exception
          when others then
            v$msg := SUBSTR(SQLERRM, 1, 200);
            raise_application_error(v$err,'Error al intentar crear el asignado a la persona:' || v$nombre_deudor || '. Mensaje:' || v$msg,true);
          end;
        end if;
      end if;
    end if; 
    return 0;
end;
/
