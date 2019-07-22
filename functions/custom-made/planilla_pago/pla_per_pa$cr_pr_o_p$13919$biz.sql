create or replace function pla_per_pa$cr_pr_o_p$13919$biz(x$super number, x$clase_pension number, x$ano number, x$mes number, x$cuenta varchar2, x$periodo varchar2) return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg               nvarchar2(200);
  v$estado_pension      number;
  v$cant_max            number;
  v$nombre_pension      varchar2(100);
  v$id_planilla_pago    number;
  v$nen_codigo          number(2);
  v$ent_codigo          number(3);
  v$id_orden_pago       number;
  v$estado_orden_pago   number;
  v$id                  number;
  contador              number:=0;
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
  Begin 
    Select valor_numerico into v$cant_max From variable_global Where numero = 130;
  exception
  when no_data_found then
    v$cant_max:=50000;
  when others then
    raise_application_error(v$err,'Error al intentar obtener los datos de la cantidad máxima a registrar en una orden de pago (130)',true);
  end;
  begin
    Select pr.estado, pp.nombre, pp.id
      into v$estado_pension, v$nombre_pension, v$id_planilla_pago
    From planilla_pago pp inner join planilla_periodo_pago pr on pp.id = pr.planilla
      inner join clase_pension cp on pp.clase_pension = cp.id
    Where to_number(pr.mes)=x$mes And pr.ano=x$ano And cp.id=x$clase_pension
      And pp.periodo=x$periodo;
  exception
  WHEN NO_DATA_FOUND THEN
    v$estado_pension:=0;
  when others then
    v$estado_pension:=0;
  end;
  if v$estado_pension <> 3 then
    raise_application_error(v$err, 'Error: la planilla de pago correpondiente a la clase pensión :'|| v$nombre_pension || ' del mes: '|| x$mes ||', debe estar Cerrada.',true);
  end if;
  begin
    v$id_orden_pago:=BUSCA_CLAVE_ID;
    Insert Into orden_pago (ID, VERSION, CODIGO, CONCEPTO_DESDE, MES, ANO, NUMERO_SOLICITUD, TIPO_PRESUPUESTO, estado, 
                            FECHA_TRANSICION, USUARIO, cuenta)
    values (v$id_orden_pago, 0, v$id_orden_pago, x$clase_pension, x$mes, x$ano, null, null, 
            1, sysdate, CURRENT_USER_ID, x$cuenta);
  exception
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar insertar el registro de orden de pago, mensaje:' || err_msg, true);
  end;
  if x$cuenta='true' then
    For reg in (Select rp.id, rp.orden, pc.pec_secuen, pn.id as idpension, pe.id as idpersona
                From planilla_pago pp inner join planilla_periodo_pago pr on pp.id = pr.planilla
                  inner join resumen_pago_pension rp on pp.id = rp.planilla And rp.mes_resumen=x$mes And rp.ano_resumen=x$ano
                  inner join pension pn on rp.pension = pn.id
                  inner join persona pe on pn.persona = pe.id
                  inner join clase_pension cp on pp.clase_pension = cp.id
                  inner join banco ba on pe.banco = ba.id
                  inner join a_pec@sinarh pc on pc.nen_codigo=v$nen_codigo And pc.ent_codigo=v$ent_codigo And pc.ban_codigo=ba.codigo 
                    And pc.ani_aniopre=x$ano And pe.codigo=pc.per_codcci And pe.cuenta_bancaria=pc.pec_descta
                Where cp.id=x$clase_pension And pp.periodo=x$periodo
                  And pr.mes=x$mes And pr.ano=x$ano
                  And pc.pec_activo='S'
                  And rp.detalle_orden_pago is null
                Order by rp.orden) loop
      if contador>=v$cant_max then
        exit;
      end if;
      begin
        v$id:=BUSCA_CLAVE_ID;
        Insert into detalle_orden_pago(ID, VERSION, CODIGO, ORDEN_PAGO, RESUMEN_PAGO_PENSION, ORDEN, PEC_SECUEN, PENSION, PERSONA)
        values (v$id, 0, v$id, v$id_orden_pago, reg.id, reg.orden, reg.pec_secuen, reg.idpension, reg.idpersona);
        Update resumen_pago_pension set detalle_orden_pago =v$id Where id=reg.id;
      exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar crear el detalle de la orden de pago, mensaje:' || v$msg, true);
      end;
      contador:=contador+1;
    end loop;
  else
    For reg in (Select rp.id, rp.orden, null as pec_secuen, pn.id as idpension, pe.id as idpersona
                From planilla_pago pp inner join planilla_periodo_pago pr on pp.id = pr.planilla
                  inner join resumen_pago_pension rp on pp.id = rp.planilla And rp.mes_resumen=x$mes And rp.ano_resumen=x$ano
                  inner join pension pn on rp.pension = pn.id
                  inner join persona pe on pn.persona = pe.id
                  inner join clase_pension cp on pp.clase_pension = cp.id
                Where cp.id=x$clase_pension And pp.periodo=x$periodo
                  And pr.mes=x$mes And pr.ano=x$ano
                  And (pe.cuenta_bancaria is null or pe.banco is null)
                  And rp.detalle_orden_pago is null
                Order by rp.orden) loop
      if contador>=v$cant_max then
        exit;
      end if;
      begin
        v$id:=BUSCA_CLAVE_ID;
        Insert into detalle_orden_pago(ID, VERSION, CODIGO, ORDEN_PAGO, RESUMEN_PAGO_PENSION, ORDEN, PEC_SECUEN, PENSION, PERSONA)
        values (v$id, 0, v$id, v$id_orden_pago, reg.id, reg.orden, reg.pec_secuen, reg.idpension, reg.idpersona);
        Update resumen_pago_pension set detalle_orden_pago =v$id Where id=reg.id;
      exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar crear el detalle de la orden de pago, mensaje:' || v$msg, true);
      end;
      contador:=contador+1;
    end loop;
  end if;
  if contador=0 then
    raise_application_error(v$err, 'Error: no hay registros por procesar según los filtros introducidos.', true);
  end if;
  return 0;
exception
when others then
  raise_application_error(v$err, 'Error en el procedimiento crear orden  de pago:'|| sqlerrm);
end;
/
 