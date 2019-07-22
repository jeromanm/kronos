create or replace function pension$calcul_liqui$22804$biz(x$super number, x$pension number, x$fecha_desde date, x$fecha_hasta date)
 return number is
 v$err constant number := -20000; -- an integer in the range -20000..-20999
 v$msg                  nvarchar2(2000); -- a character string of at most 2048 bytes?
 err_num                NUMBER;
 err_msg                VARCHAR2(255);
 v_fecha_acta_defuncion date;
 v_cedula               VARCHAR2(20);
 v_cant_planilla_exceso number(10);
 v_monto_exceso         number(11);
 v_saldo_exceso         number(11);
 v_saldo_final          number(11);
 v_saldo_ctp            number;
 v_debito_ctp           number;
 v_persona_id           NUMBER(19);
 v_monto_cuota          number;
 v$requiere_censo       varchar2(5);
 v$monto_reintegrado    number;
 v_saldo_antes_defuncion number;
begin
  Begin
    Select pn.monto_exceso, pn.cant_planilla_exceso, pn.saldo_inicial, pn.monto_cuota, cp.requiere_censo
      into v_monto_exceso, v_cant_planilla_exceso, v_saldo_exceso, v_monto_cuota, v$requiere_censo
    From pension pn inner join clase_pension cp on pn.clase = cp.id
    Where pn.id=x$pension;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		v_monto_exceso:=0;
    v_cant_planilla_exceso:=0;
    v_saldo_exceso:=0;
	End;
  if v_monto_cuota>0 then
    raise_application_error(v$err,'Error: la pensión:' || x$pension || ' ya tiene acuerdo de pago, debe anular este primero', true);
  end if;
  Begin
    Select pe.fecha_defuncion, pe.id, pe.codigo 
      into v_fecha_acta_defuncion, v_persona_id, v_cedula
    From persona pe inner join  pension pn on pe.id = pn.persona
    Where pn.id = x$pension And rownum=1
    Order by pe.fecha_defuncion desc;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_fecha_acta_defuncion:=NULL;
    v_persona_id:=null;
  End;
  Begin
    if (x$fecha_desde is not null And x$fecha_hasta is not null) then
      Select count(distinct rp.id) as cant, sum(case when cc.tipo_concepto=1 then dp.monto else (dp.monto*-1) end) as monto
        Into v_cant_planilla_exceso, v_monto_exceso
      From pension pn inner join resumen_pago_pension rp on pn.id = rp.pension
        inner join detalle_pago_pension dp on rp.id = dp.resumen And dp.activo='true'
        inner join clase_concepto cc on dp.clase_concepto = cc.id
      Where pn.id=x$pension And to_date('01/' || dp.mes_planilla || '/' || dp.ano_planilla,'dd/mm/yyyy') between x$fecha_desde And x$fecha_hasta;
    elsif v_fecha_acta_defuncion IS NOT NULL then --fecha menor de defunción de la persona asociada al id de la pensión
      Select Count(distinct re.id), sum(case co.tipo_concepto when 1 then dp.monto else (dp.monto*-1) end)
        Into v_cant_planilla_exceso, v_monto_exceso
      From resumen_pago_pension re inner join pension pn on re.pension = pn.id
        inner join persona pe on pn.persona = pe.id
        inner join detalle_pago_pension dp on re.id = dp.resumen And dp.activo='true'
        inner join clase_concepto co on dp.clase_concepto = co.id
      Where pn.id = x$pension
        And to_date(to_char(last_day(to_date('01/' || re.mes_resumen || '/' || re.ano_resumen,'dd/mm/yyyy')),'dd') || '/' || re.mes_resumen || '/' || re.ano_resumen,'dd/mm/yyyy')>=v_fecha_acta_defuncion;
    end if;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_cant_planilla_exceso:=NULL;
    v_monto_exceso:=null;
  End;
  v$monto_reintegrado:=0;
  begin
    Select ctp.ctp_debito into v$monto_reintegrado 
    From a_ctp@sinarh ctp 
    Where ctp.per_codcci = v_cedula and ctp.nen_codigo = 12 and ctp.ent_codigo = 6
      And ctp.ctp_estado=4;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v$monto_reintegrado:=0;
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20000, 'Error al intentar obtener el monto de reintegro desde el SINARH, mensaje:' || err_msg, true);
  End;
  v_saldo_final:=0;
  
  begin
    select saldo_final into v_saldo_antes_defuncion
    from estado_cuenta where id =
    (
      select max(es.id)
      from persona per inner join estado_cuenta es on es.persona = per.id
      where per.id = v_persona_id
      and trunc(per.fecha_defuncion) >= trunc(es.fecha)
    );
  exception
    when others then
      null;
  end;
  
  v_monto_exceso := nvl(v_monto_exceso,0) + nvl(v_saldo_antes_defuncion,0);
  
 /* if (x$fecha_desde is not null And x$fecha_hasta is not null) then
    BEGIN
      Select saldo_final into v_saldo_final
        From (Select ec.fecha, ec.saldo_final
              From persona pe inner join estado_cuenta ec on pe.id = ec.persona
              Where pe.id=v_persona_id
              Order by ec.fecha desc)
      Where rownum=1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_saldo_final := 0;
    END;
    if nvl(v_saldo_final,0)=0 then
      v_saldo_exceso:= v_monto_exceso;
    else
      v_saldo_exceso:=v_monto_exceso-v_saldo_final;
    end if;
  elsif v_fecha_acta_defuncion IS NOT NULL then --fecha menor de defunción de la persona asociada al id de la pensión
    BEGIN
      Select nvl(sum(debitos),0) into v_saldo_final From estado_cuenta Where fecha>v_fecha_acta_defuncion And persona=v_persona_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_saldo_final := 0;
    END;
    if v_saldo_final=0 then
      v_saldo_exceso:= v_monto_exceso;
    else
      v_saldo_exceso:=v_saldo_final;
    end if;
  end if;   */
  begin
    Update pension set monto_exceso=v_monto_exceso, cant_planilla_exceso=v_cant_planilla_exceso, monto_red_bancaria=v$monto_reintegrado,
                         monto_deuda= v_monto_exceso-v$monto_reintegrado, SALDO_DEUDOR=v_monto_exceso-v$monto_reintegrado
    Where id=x$pension;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    err_msg := SQLERRM;
  	raise_application_error(v$err,'Error: al intentar actualizar el cobro indebido en la pensión, mensaje:' || err_msg, true);
  End;
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20000, err_msg, true);
end;
/
