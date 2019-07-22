create or replace function planilla_pago$obtenermonto(x$idconcepto_planilla_pago number, x$monto number) return number is
  v$err                       constant number := -20000; -- an integer in the range -20000..-20999
	v$msg                       nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$monto_permanente          number;
  v$jornales                  number:=0;
  v$porcentaje                number:=0;
  v$requiere_monto            VARCHAR2(5);
  v$requiere_jornales         VARCHAR2(5);
  v$requiere_porcentaje       VARCHAR2(5);
  v$metodo_concepto           number;
  v$jornal_minimo             number;
  v$salario_minimo            number;
  v$dias_jornal               number;
begin
  begin --Obtenemos el salario y jornal minimo
		Select max(jornal_minimo), max(salario_minimo) into v$jornal_minimo, v$salario_minimo
		From salario_minimo;
  exception
  when no_data_found then
    raise_application_error(v$err,'No se encuentra datos en la table Salario Minimo',true);
  when others then
    raise_application_error(v$err,'Error en la tabla Salario Minimo',true);
  end;
  if (v$jornal_minimo=0 or v$salario_minimo=0) Then
    v$dias_jornal:=0;
  else
    v$dias_jornal:=(v$salario_minimo / v$jornal_minimo);
  end if;
  begin
    Select co.monto, co.jornales, co.porcentaje, mp.requiere_monto, mp.requiere_jornales, mp.requiere_porcentaje, mp.numero
      into v$monto_permanente, v$jornales, v$porcentaje, v$requiere_monto, v$requiere_jornales, v$requiere_porcentaje, v$metodo_concepto
    From concepto_planilla_pago co inner join metodo_concepto mp on co.metodo = mp.numero
    Where co.id=x$idconcepto_planilla_pago;
  exception
  when no_data_found then
    return x$monto;
  when others then
    return x$monto;
  end;
  if (v$requiere_monto='true') then --And v$monto_permanente<>0
    v$monto_permanente:=x$monto;
  elsif (v$jornales<>0 And v$requiere_jornales='true') then
    v$monto_permanente:=(v$jornales * v$jornal_minimo);
  elsif (v$porcentaje<>0 And v$requiere_porcentaje='true') then
    if v$metodo_concepto=3 then --en base al salario minimo
      v$monto_permanente:=(v$porcentaje * v$salario_minimo) / 100;
    elsif v$metodo_concepto=4 then --en base al salario del causante
      v$monto_permanente:=(v$porcentaje * x$monto) / 100;
    end if;
  end if;
  return v$monto_permanente;
exception
	When others then
		v$msg := SQLERRM;
		raise_application_error(v$err, v$msg, true);
end;
/
