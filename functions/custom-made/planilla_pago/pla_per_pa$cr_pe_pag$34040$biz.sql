create or replace function pla_per_pa$cr_pe_pag$34040$biz(x$super number, x$clase_pension number, x$periodo number, x$mes number, x$ano number) return number is
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log             rastro_proceso_temporal%ROWTYPE;
  err_num           NUMBER;
  err_msg           VARCHAR2(2000);
  v_cant            number;
  v_mes             varchar2(2);
  v_planilla        number;
  id_planilla_pago  number(19);
begin
  begin
    Select a.id, count(b.id)
      into v_planilla, v_cant
    From planilla_pago a left outer join planilla_periodo_pago b on a.id = b.planilla
    Where a.clase_pension=x$clase_pension And a.periodo=x$periodo
    Group By a.id;
  exception
  when no_data_found then
    raise_application_error(v$err,'Error: no se consiguen registros de la planilla de pago asociada a la clase de pensión y/o tipo perìodo.', false);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 2000);
    raise_application_error(v$err,'Error al intentar obtener el periodo planilla de pago, mensaje:' || err_msg, false);
  end;
  if v_cant=0 then
    begin
      id_planilla_pago := busca_clave_id;
      insert into planilla_periodo_pago(id , version, codigo, planilla, mes, ano, estado, abrir_siguiente, comentarios)
      values (id_planilla_pago,0, id_planilla_pago, v_planilla, trim(to_char(x$mes,'00')), x$ano, 1, 'true', null);
    exception
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err,'Error al intentar crear el periodo planilla de pago, mensaje:' || err_msg, false);
    end;
  else
    raise_application_error(v$err,'Error: el periodo de la planilla existe, para los filtros ingresados.', false);
  end if;
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(v$err, err_msg, true);
end;
/
