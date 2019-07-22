create or replace function pension$anu_acu_pago$52795$biz(x$super number, x$pension number, x$observaciones nvarchar2) return number is
    v$err                         constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                         nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid                         varchar2(146);
    x$id_acuerdo_pago             number;
    v$log rastro_proceso_temporal%ROWTYPE;
    v_valor_conc_cobros_indebidos number;
    v$cant                        number;
begin
    Select Count(id) into v$cant From pago_acuerdo_pension Where pension=x$pension;
    if v$cant>0 then
      raise_application_error(v$err,'Error: no se puede anular un acuerdo de pago que tiene pagos asociados (' || v$cant || ')',true);
    end if;
    begin
      Select id into x$id_acuerdo_pago From acuerdo_pago Where pension=x$pension;
    exception
    when no_data_found then
      x$id_acuerdo_pago:=null;
    when others then
      x$id_acuerdo_pago:=null;
    end;
    if x$id_acuerdo_pago is not null then
      begin
        delete From concepto_pension where acuerdo_pago=x$id_acuerdo_pago;
        delete From acuerdo_pago where id=x$id_acuerdo_pago;
      exception
      when no_data_found then
        x$id_acuerdo_pago:=null;
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err,'Error al intentar eliminar el acuerdo de pago, mensaje:' || v$msg, true);
      end;
    end if;
    begin
      Select VALOR_NUMERICO into v_valor_conc_cobros_indebidos From variable_global Where numero = 104;
    exception
    when no_data_found then
      raise_application_error(v$err,'No se encuentran datos del concepto haberes atrasados',true);
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 200);
      raise_application_error(v$err,'Error al intentar obtener los datos del concepto haberes atrasados, mensaje:' || v$msg, true);
    end;
    update pension set observaciones_anular_acuerdo = x$observaciones, monto_exceso = null, monto_reintegro = null, monto_deuda = null, expediente_acuerdo = null, 
                        descripcion_acuerdo = null, fecha_acuerdo = null, monto_cuota = null, saldo_deudor = null, cant_planilla_exceso=0, persona_deudor=null
    where id = x$pension;
    if not SQL%FOUND then
      v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pension', 'id', x$pension);
      raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
