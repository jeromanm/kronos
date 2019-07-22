create or replace function pla_per_pa$as_or_pag$74037$biz(x$super number, x$orden_pago number, x$numero_solicitud number) return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg               nvarchar2(200);
  x$ano                 integer;
  x$mes                 integer;
  v$nen_codigo          number(2);
  v$ent_codigo          number(3);
  v$id_orden_pago       number;
  v$estado_orden_pago   number;
  v$monto_orden_pago    number;
  v$gas_impoblig        number;
  v$fob_impoblig        number;
  v$sol_importe         number;
  v_mes_sol             number;
  v_mes_act             number;
begin
  begin
    Select valor_numerico into v$nen_codigo From variable_global Where numero=122;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos del valor del nivel de la entidad.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor del nivel de la entidad, mensaje:' || err_msg, true);
  end;
  begin
    Select valor_numerico into v$ent_codigo From variable_global Where numero=123;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos del valor del código de la entidad.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor del código de la entidad, mensaje:' || err_msg, true);
  end;
  begin
    Select a.id, a.estado, a.mes, a.ano, sum(c.monto) as monto
      into v$id_orden_pago, v$estado_orden_pago, x$mes, x$ano, v$monto_orden_pago
    From orden_pago a inner join detalle_orden_pago b on a.id = b.orden_pago
      inner join resumen_pago_pension c on b.resumen_pago_pension = c.id
    Where a.id=x$orden_pago
    Group by a.id, a.estado, a.mes, a.ano;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos de la orden de pago solicitada.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor de la orden de pago, mensaje:' || err_msg, true);
  end;
  if v$estado_orden_pago<>1 then
    raise_application_error(v$err, 'Error: no puede modificar la orden de pago en el estado actual.',true);
  end if;
  begin
    Select g.gas_impoblig, f.fob_impoblig, s.sol_importe, to_char(to_date(s.sol_fchsol,'dd/mm/yyyy'),'MM'), to_char(to_date(sysdate,'dd/mm/yyyy'),'MM')
      into v$gas_impoblig, v$fob_impoblig, v$sol_importe, v_mes_sol, v_mes_act
    From a_doc@siaf a inner join a_gas@siaf g on a.ani_aniopre=g.ani_aniopre And a.uje_codigo=g.uje_codigo And a.nen_codigo=g.nen_codigo And a.ent_codigo=g.ent_codigo And a.doc_nroasi=g.doc_nroasi And a.DOC_TIPO=g.DOC_TIPO
      inner join a_fob@siaf f on g.ani_aniopre=f.ani_aniopre And g.nen_codigo=f.nen_codigo And g.ent_codigo=f.ent_codigo And g.uje_codigo=f.uje_codigo And g.doc_nroasi=f.doc_nroasi And g.DOC_TIPO=f.DOC_TIPO
      inner join a_sol@siaf s on f.ani_aniopre=s.ani_aniopre And f.nen_codigo=s.nen_codigo And f.ent_codigo=s.ent_codigo And f.uje_codigo=s.uje_codigo And f.sol_numero = s.sol_numero
      inner join a_sdoc@siaf sd on s.ani_aniopre=sd.ani_aniopre And s.nen_codigo=sd.nen_codigo And s.ent_codigo=sd.ent_codigo And s.uje_codigo=sd.uje_codigo And s.sol_numero=sd.sol_numero
      inner join a_fent@siaf fe on sd.ani_aniopre=fe.ani_aniopre And sd.nen_codigo=fe.nen_codigo And sd.ent_codigo=fe.ent_codigo And sd.uje_codigo=fe.uje_codigo And fe.fent_tipo='STR'
    Where a.ani_aniopre=x$ano
      And a.nen_codigo=v$nen_codigo
      And a.ent_codigo=v$ent_codigo
      And f.sol_numero=x$numero_solicitud;
  exception
  WHEN NO_DATA_FOUND THEN
    v_mes_sol:= 0;
    v_mes_act:=0;
  when others then
    v_mes_sol:= 0;
    v_mes_act:=0;
  end;
  if v_mes_sol <> v_mes_act or v_mes_sol=0 or v_mes_act=0 then
    raise_application_error(v$err, 'El mes de la solicitud nro:' || x$numero_solicitud || '(' || v_mes_sol || ') no corresponde al mes de pago o no se consiguen registros.', true);
  end if;
  if  v$gas_impoblig<>v$fob_impoblig or v$sol_importe<>v$monto_orden_pago then
    raise_application_error(v$err, 'Error: los montos asociados a la solicitud:' || x$numero_solicitud || ', gasto:' || v$gas_impoblig  || ', obligación:' || v$fob_impoblig || ', solicitud:' || v$sol_importe || ', son diferentes entre ellos o con el monto del resumen pensión:' ||  v$monto_orden_pago,true);
  end if;
  begin
    Update orden_pago set NUMERO_SOLICITUD=x$numero_solicitud
    Where id=v$id_orden_pago;
  exception
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar actualizar el numero de solicitud (STR) en la orden de pago, mensaje:' || err_msg, true);
  end;
  return 0;
exception
when others then
  raise_application_error(v$err, 'Error en el procedimiento asociar STR a orden  de pago:'|| sqlerrm);
end;
/
