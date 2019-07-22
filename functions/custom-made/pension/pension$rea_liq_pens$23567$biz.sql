create or replace function pension$rea_liq_pens$23567$biz(x$super number, x$id number) return number is
    v$err                     constant number := -20000; -- an integer in the range -20000..-20999
    v$nro_error               number;
    v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$estado_liquidacion      nvarchar2(5);
    v$pension                 number;
    v$cant                    number;
    v$concepto_pension        number;
	-- reabrir liquidación pensión
begin
  begin
    Select abierto, pension 
      into v$estado_liquidacion, v$pension 
    From liquidacion_haberes Where id=x$id;
  exception
	when no_data_found then
		raise_application_error(v$err,'Error: no se consiguen datos de la liquidación de pensión',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos de la liquidación de pensión, mensaje:' || v$msg,true);
  end;
  if v$estado_liquidacion<>'false' then
    raise_application_error(v$err,'Error: la liquidación de la pensión está en estatus diferente a cerrado, no se puede cerrar.',true);
  end if;
  /*begin
    Select Count(dp.id) into v$cant 
    From detalle_liqu_haber dl inner join concepto_pension cp on dl.concepto_pension = cp.id 
      inner join concepto_planilla_pago pp on cp.clase = pp.id
      inner join clase_concepto cc on pp.clase_concepto = cc.id
      inner join pension pn on cp.pension = pn.id
      inner join resumen_pago_pension rp on pn.id = rp.pension 
      inner join detalle_pago_pension dp on rp.id = dp.resumen And dp.clase_concepto = cc.id
    where dl.liquidacion_haberes=x$id;
  exception
	when no_data_found then
		v$cant:=0;
	when others then
    v$cant:=0;
  end;
  if v$cant>0 then
    raise_application_error(v$err,'Error: no se puede modificar la liquidación de pensión, tiene ' || v$cant || ' movimientos de planilla de pago.',true);
  end if;*/
  begin
    Update liquidacion_haberes set abierto='true' Where id=x$id;
    For reg in (Select concepto_pension From detalle_liqu_haber Where liquidacion_haberes=x$id Group By concepto_pension) loop
      v$concepto_pension:=reg.concepto_pension;
      Update detalle_liqu_haber set concepto_pension =null where concepto_pension=reg.concepto_pension;
      Delete From CONCEPTO_PENSION Where id =v$concepto_pension; 
      --Update concepto_pension set monto=0 Where PENSION=v$pension And acuerdo_pago is null
      --  And Exists (Select b.id From detalle_liqu_haber b Where concepto_pension.id = b.concepto_pension);
    end loop;
  exception
	when no_data_found then
		raise_application_error(v$err,'Error: no se consiguen datos de la liquidación de pensión',true);
	when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar el estado de la liquidación de pensión, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
