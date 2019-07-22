create or replace function pension$cie_liq_pens$43458$biz(x$super number, x$id number) return number is
  v$err                     constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$estado_liquidacion      nvarchar2(5);
  v$id_concepto_pension     number;
  v$monto                   number;
  v$porcentaje              number;
  v$jornales                number;
  v$fecha_planilla          date;
  v$id                      number;
  v$estado                  number ;
  v$tiene_objecion          nvarchar2(5);
  v$recalculo               varchar2(5);
  v$pension                 number;
  v_cant_objecion           number;
  v$desde                   date;
  v$hasta                   date;
  v$monto_maximo            number;
  v$mes                     integer;
  v$saldo_inicial           number;
  v$saldo_actual            number;
  v$numero_sime             number;
  v$estado_tramite          number:=0;
  v$tipo_tramite            number:=0;
begin --cierre liquidación de pensión
  begin
    Select abierto, pension, recalculo, numero_sime
      into v$estado_liquidacion, v$pension, v$recalculo, v$numero_sime
    From liquidacion_haberes Where id=x$id;
  exception
	when no_data_found then
		raise_application_error(v$err,'Error: no se consiguen datos de la liquidación de pensión',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos de la liquidación de pensión, mensaje:' || v$msg,true);
  end;
  if v$estado_liquidacion<>'true' then
    raise_application_error(v$err,'Error: la liquidación de la pensión está en estatus diferente a abierto, no se puede cerrar.',true);
  end if;
  begin
		Select valor into v$monto_maximo From variable_global Where numero = 114;
	exception
	when no_data_found then
		v$monto_maximo:=0;
	when others then
		raise_application_error(v$err,'Error al intentar obtener los datos del monto máximo a pagar',true);
  end;
  begin
		Select estado, tipo 
      into v$estado_tramite, v$tipo_tramite
    From tramite_administrativo 
    Where pension=v$pension And numero_sime=v$numero_sime
      And rownum=1;
	exception
	when no_data_found then
		v$estado_tramite:=0; v$tipo_tramite:=0;
	when others then
		raise_application_error(v$err,'Error al intentar obtener los datos del trámite administrativo asociado al sime y pension asociada a la liquidación.',true);
  end;
  begin
    Select pn.estado, pn.tiene_objecion, Count(op.id) 
      into v$estado, v$tiene_objecion, v_cant_objecion 
    From pension pn left outer join objecion_pension op on pn.id = op.pension And op.objecion_invalida='true' 
    Where pn.id=v$pension
    Group By pn.estado, pn.tiene_objecion;
  exception
	when no_data_found then
		v$estado:=7; v$tiene_objecion:='false'; v_cant_objecion:=0;
	when others then
    v$estado:=7; v$tiene_objecion:='false'; v_cant_objecion:=0;
  end;
  if v_cant_objecion>0 or v$tiene_objecion='true' then
    raise_application_error(v$err,'La pensión tiene objeciones, no puede ser incluída en planilla de pago, consulte las objeciones en el detalle de la pensión, opción "Abrir".',true);
  end if;
  for reg in (Select sum(dl.monto) as monto, co.id as id_concepto_planilla_pago, lp.pension, dl.clase_concepto, max(dl.cant_recurrente) as cant_recurrente,
                    co.porcentaje, co.jornales, mc.requiere_monto, mc.requiere_jornales, mc.requiere_porcentaje, 
                    min(dl.fecha) desde, max(dl.fecha) as hasta, pn.clase as clase_pension, vg.valor as aplica_fecha 
            From liquidacion_haberes lp inner join detalle_liqu_haber dl on lp.id = dl.liquidacion_haberes
              inner join concepto_planilla_pago co on dl.clase_concepto=co.clase_concepto And co.general='false'
              inner join planilla_pago pp on co.planilla = pp.id
              inner join pension pn on lp.pension = pn.id And pp.clase_pension = pn.clase
              inner join clase_concepto cc on dl.clase_concepto = cc.id
              inner join metodo_concepto mc on co.metodo = mc.numero
              inner join variable_global vg on cc.codigo = vg.valor_numerico And valor in ('true','false')
            Where lp.id=x$id --And dl.concepto_pension is null 
            And dl.proyectado='false'
            Group By co.id, to_number(cc.codigo), lp.pension, dl.clase_concepto,
                    co.porcentaje, co.jornales, mc.requiere_monto, mc.requiere_jornales, 
                     mc.requiere_porcentaje, pn.clase, vg.valor
            Order by to_number(cc.codigo))loop
      begin
        Select id into v$id_concepto_pension
        From concepto_pension where pension=reg.pension And clase=reg.id_concepto_planilla_pago;
      exception
      when no_data_found then
        v$id_concepto_pension:=null;
      when others then
        v$id_concepto_pension:=null;
      end;
      if reg.requiere_monto='true' then 
        v$monto:=reg.monto;
      else 
        v$monto:=null;
      end if;
      if reg.requiere_jornales='true' then 
        v$jornales:=reg.jornales;
      else 
        v$jornales:=null;
      end if;
      if reg.requiere_porcentaje='true' then 
        v$porcentaje:=reg.porcentaje;
      else 
        v$porcentaje:=null;
      end if;
      if reg.aplica_fecha='true' then --verificamos periodo que aplica y se calcula el monto mensual en base a los meses restantes del año
        begin
          Select to_date('01/' || pe.mes || '/' || pe.ano,'dd/mm/yyyy') into v$fecha_planilla
          From planilla_periodo_pago pe inner join planilla_pago pp on pp.id = pe.planilla 
          where pe.estado IN (1,2) And pp.clase_pension =reg.clase_pension And rownum=1
          Order by to_date('01/' || pe.mes || '/' || pe.ano,'dd/mm/yyyy') desc;
        exception
        when no_data_found then
          v$fecha_planilla:=reg.desde;
        when others then
          v$fecha_planilla:=reg.desde;
        end;
        if v$fecha_planilla<reg.desde then 
          v$fecha_planilla:=reg.desde;
        end if;
        if reg.clase_concepto=3 then --haber atrasado
          if v$estado_tramite<>6 or v$tipo_tramite<>5 then
            raise_application_error(v$err,'Error: no se puede generar un asignado de haber atrasado sin un tramite administrativo otorgado de tipo haber atrasado asociado al sime y la pension de la liquidación.',true);
          end if;
          v$desde:=to_date('01/' || to_char(v$fecha_planilla,'mm/yyyy'),'dd/mm/yyyy');
          v$hasta:=to_date('31/12/' || to_char(v$fecha_planilla,'yyyy'),'dd/mm/yyyy');
          Select round(MONTHS_BETWEEN(v$hasta,v$desde),0) into v$mes From dual;
          if (v$monto>v$monto_maximo) then  --monto mayor que el maximo anual
            v$saldo_inicial:=v$monto_maximo;
            v$saldo_actual:=v$monto;
          else
            v$saldo_inicial:=v$monto;
            v$saldo_actual:=v$monto;
          end if;
          v$monto:=round(v$saldo_inicial/v$mes,0); --el monto anual se divide en los meses restantes
        else
          v$desde:=to_date('01/' || to_char(v$fecha_planilla,'mm/yyyy'),'dd/mm/yyyy');
          v$hasta:=last_day(v$fecha_planilla);
          if (v$monto>v$monto_maximo) then  --monto mayor que el maximo anual
            v$saldo_inicial:=v$monto_maximo;
            v$saldo_actual:=v$monto;
          else
            v$saldo_inicial:=v$monto;
            v$saldo_actual:=v$monto;
          end if;
        end if;
        begin
          if v$id_concepto_pension is null And v$monto>0 then
            v$id_concepto_pension:=busca_clave_id;
            insert into CONCEPTO_PENSION (ID, VERSION, CODIGO, PENSION, CLASE, MONTO, JORNALES, PORCENTAJE, SALDO_INICIAL, SALDO_ACTUAL, 
                                          MONTO_ACUMULADO, DESDE, HASTA, LIMITE, CUENTA, BLOQUEADO, CANCELADO, ACUERDO_PAGO, CANT_RECURRENTE)
              values (v$id_concepto_pension, 0, v$id_concepto_pension, reg.pension, reg.id_concepto_planilla_pago, v$monto, v$jornales, v$porcentaje, v$saldo_inicial, v$saldo_actual,
                      null, v$desde, v$hasta, v$saldo_actual, null, 'false', 'false', null, reg.cant_recurrente);
          elsif v$monto>0 then
            Update CONCEPTO_PENSION set MONTO=v$monto, desde=v$desde, hasta=v$hasta, SALDO_INICIAL=v$saldo_inicial, porcentaje=v$porcentaje, jornales=v$jornales, saldo_actual=v$saldo_actual
            Where id=v$id_concepto_pension;
          end if;
        exception
        when others then
          v$msg := SQLERRM;
          raise_application_error(v$err,'Error al intentar crear el asignado permanente, mensaje:' || v$msg,true);
        end;
      else --asignado no hay que verificar periodo ni monto mensual
        v$desde:=null;
        v$hasta:=null;
        begin
          if v$id_concepto_pension is null then
            v$id_concepto_pension:=busca_clave_id;
            insert into CONCEPTO_PENSION (ID, VERSION, CODIGO, PENSION, CLASE, MONTO, MONTO_ACUMULADO, BLOQUEADO, CANCELADO, 
                                          cant_recurrente, porcentaje, jornales, desde, hasta)
              values (v$id_concepto_pension, 0, v$id_concepto_pension, reg.pension, reg.id_concepto_planilla_pago, v$monto, null, 'false', 'false', 
                    reg.cant_recurrente, v$porcentaje, v$jornales, v$desde, v$hasta);
          else
            Update CONCEPTO_PENSION set MONTO=monto+v$monto, desde=v$desde, hasta=v$hasta, SALDO_INICIAL=SALDO_INICIAL+v$monto, porcentaje=v$porcentaje, jornales=v$jornales
            Where id=v$id_concepto_pension;
          end if;
        exception
        when others then
          v$msg := SQLERRM;
          raise_application_error(v$err,'Error al intentar crear el asignado permanente, mensaje:' || v$msg,true);
        end;
      end if;
      begin
        Update detalle_liqu_haber set concepto_pension=v$id_concepto_pension Where liquidacion_haberes=x$id And clase_concepto=reg.clase_concepto;
      exception
      when no_data_found then
        raise_application_error(v$err,'Error: no se consiguen datos del detalle de liquidación a asociar el asignado, codigo asignado:' || v$id_concepto_pension,true);
      when others then
        v$msg := SQLERRM;
        raise_application_error(v$err,'Error al intentar actualizar el asginado en el detalle de la liquidación, mensaje:' || v$msg,true);
      end;
  end loop;
  begin
    Update liquidacion_haberes set abierto='false' Where id=x$id;
  exception
	when no_data_found then
		raise_application_error(v$err,'Error: no se consiguen datos de la liquidación de pensión',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar actualizar el estado de la liquidación de pensión, mensaje:' || v$msg,true);
  end;
  if (v$recalculo='false') then
    begin
      Update pension set activa = 'true', fecha_activar = current_date, usuario_activar = current_user_id()
      Where id = v$pension;
    exception
    when no_data_found then
      raise_application_error(v$err,'Error: no se consiguen datos de la pensión',true);
    when others then
      v$msg := SQLERRM;
      raise_application_error(v$err,'Error al intentar activar la pensión, mensaje:' || v$msg,true);
    end;
  end if;
  return 0;
end;
/
