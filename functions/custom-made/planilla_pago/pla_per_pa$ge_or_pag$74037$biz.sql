create or replace function pla_per_pa$ge_or_pag$74037$biz(x$super number, x$orden_pago number) return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg               nvarchar2(200);
  v_secuencia           number(6);
  x$user                varchar2(8);
  v_mes_sol             number;
  v_mes_act             number;
  x$mes                 integer;
  x$ano                 integer;
  v$id_orden_pago       number;
  v$estado_orden_pago   number;
  v$id_planilla_pago    number;
  x$enc_cod_habpag      number(3);
  v$nen_codigo          number(2);
  v$ent_codigo          number(3);
  v$monto_spnc          number;
  v$uje_codigo          number;
  v$doc_nroasi          number(6);
  v$obj_codigo          number(5);
  v$gas_impoblig        number;
  v$fob_impoblig        number;
  v$sol_importe         number;
  x$cod_ordgas          number(3);
  x$pla_tippresup       number(2):=null;
  v$sol_numero          number(6);
  v$id                  number;
begin
  Begin 
    Select valor_numerico into x$enc_cod_habpag From variable_global Where numero = 129;
  exception
  when no_data_found then
    raise_application_error(v$err,'No se encuentran datos del habilitador pagador (129)',true);
  when others then
    raise_application_error(v$err,'Error al intentar obtener los datos del habilitador pagador (129)',true);
  end;
  Begin 
    Select valor_numerico into x$cod_ordgas From variable_global Where numero = 118;
  exception
  when no_data_found then
    raise_application_error(v$err,'No se encuentran datos del ordenador del gasto (118)',true);
  when others then
    raise_application_error(v$err,'Error al intentar obtener los datos del ordenador del gasto (118)',true);
  end;
  begin
    Select substr(codigo_usuario,1,8) into x$user
    From usuario where id_usuario=current_user_id;
  exception
  when no_data_found then
    x$user := 'spnc';
  when others then
    x$user := 'spnc';
  end;
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
    Select a.id, a.estado, case d.periodo when 1 then a.mes else 13 end mes, a.ano, a.numero_solicitud, sum(c.monto) as totalspnc
      into v$id_orden_pago, v$estado_orden_pago, x$mes, x$ano, v$sol_numero, v$monto_spnc
    From orden_pago a inner join detalle_orden_pago b on a.id = b.orden_pago
      inner join resumen_pago_pension c on b.resumen_pago_pension = c.id
      inner join planilla_pago d on c.planilla = d.id
    Where a.id=x$orden_pago
    Group By a.id, a.estado, a.mes, a.ano, a.numero_solicitud, d.periodo;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos de la orden de pago solicitada.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor de la orden de pago, mensaje:' || err_msg, true);
  end;
  if v$estado_orden_pago<>1 or v$sol_numero is null then
    raise_application_error(v$err, 'Error: no puede generar la orden de pago en el estado actual y/o no tiene asociado número de solicitud:' || v$sol_numero,true);
  end if;
  begin
    Select a.uje_codigo, a.doc_nroasi, g.obj_codigo, g.gas_impoblig, f.fob_impoblig, s.sol_importe, a.DOC_TIP, 
          to_char(to_date(s.sol_fchsol,'dd/mm/yyyy'),'MM') as me_solicitud, to_char(to_date(sysdate,'dd/mm/yyyy'),'MM') as mes_actual
      into v$uje_codigo, v$doc_nroasi, v$obj_codigo, v$gas_impoblig, v$fob_impoblig, v$sol_importe, x$pla_tippresup,  
            v_mes_sol, v_mes_act
    From a_doc@siaf a inner join a_gas@siaf g on a.ani_aniopre=g.ani_aniopre And a.uje_codigo=g.uje_codigo And a.nen_codigo=g.nen_codigo And a.ent_codigo=g.ent_codigo And a.doc_nroasi=g.doc_nroasi And a.DOC_TIPO=g.DOC_TIPO
      inner join a_fob@siaf f on g.ani_aniopre=f.ani_aniopre And g.nen_codigo=f.nen_codigo And g.ent_codigo=f.ent_codigo And g.uje_codigo=f.uje_codigo And g.doc_nroasi=f.doc_nroasi And g.DOC_TIPO=f.DOC_TIPO
      inner join a_sol@siaf s on f.ani_aniopre=s.ani_aniopre And f.nen_codigo=s.nen_codigo And f.ent_codigo=s.ent_codigo And f.uje_codigo=s.uje_codigo And f.sol_numero = s.sol_numero
      inner join a_sdoc@siaf sd on s.ani_aniopre=sd.ani_aniopre And s.nen_codigo=sd.nen_codigo And s.ent_codigo=sd.ent_codigo And s.uje_codigo=sd.uje_codigo And s.sol_numero=sd.sol_numero
      inner join a_fent@siaf fe on sd.ani_aniopre=fe.ani_aniopre And sd.nen_codigo=fe.nen_codigo And sd.ent_codigo=fe.ent_codigo And sd.uje_codigo=fe.uje_codigo And fe.fent_tipo='STR'
    Where a.ani_aniopre=x$ano
      And a.nen_codigo=v$nen_codigo
      And a.ent_codigo=v$ent_codigo
      And f.sol_numero=v$sol_numero;
  exception
  WHEN NO_DATA_FOUND THEN
    v_mes_sol:= 0;
    v_mes_act:=0;
  when others then
    v_mes_sol:= 0;
    v_mes_act:=0;
  end;
  if v_mes_sol <> v_mes_act or v_mes_sol=0 or v_mes_act=0 then
    raise_application_error(v$err, 'El mes de la solicitud nro:' || v$sol_numero || '(' || v_mes_sol || ') no corresponde al mes de pago o no se consiguen registros.', true);
  end if;
  if  v$gas_impoblig<>v$fob_impoblig or v$sol_importe<>v$monto_spnc then
    raise_application_error(v$err, 'Error: los montos asociados a la solicitud:' || v$sol_numero || ', gasto:' || v$gas_impoblig  || ', obligación:' || v$fob_impoblig || ', solicitud:' || v$sol_importe || ', son diferentes entre ellos o con el monto del resumen pensión:' ||  v$monto_spnc,true);
  end if;
  begin
    Update orden_pago set FECHA_TRANSICION=sysdate, USUARIO=CURRENT_USER_ID, estado=2
    Where id=v$id_orden_pago;
  exception
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar actualizar el estado de la orden de pago, mensaje:' || err_msg, true);
  end;
  v_secuencia:=sinarh.seq_pla_nrorecep.nextval@SINARH;
  For reg in (Select pe.codigo as cedula, to_number(rp.monto,'9999999999') as monto, dp.pec_secuen,
                     case cp.requiere_censo when 'true' then 'LAM' else 'PEN' end v_ctg_codigo,
                     cp.codigo as pla_concepto
              From orden_pago op inner join detalle_orden_pago dp on op.id = dp.orden_pago 
                inner join resumen_pago_pension rp on dp.resumen_pago_pension = rp.id
                inner join pension pn on rp.pension = pn.id
                inner join persona pe on pn.persona = pe.id
                inner join clase_pension cp on pn.clase = cp.id
              Where op.id=x$orden_pago
              Order by rp.orden) loop
    begin
      Insert into a_pla@sinarh(ANI_ANIOPRE,	NEN_CODIGO,	ENT_CODIGO,	PLA_MES, PER_CODCCI,	SOL_NUMERO,	PLA_TIPPRESUP,	OBJ_CODIGO,	VRS_CODIGO,	CAT_GRUPO,	CTG_CODIGO,	PLA_PRESUP, UJE_CODIGO, 
                              PLA_DEVENG,	PLA_JUBIL, PLA_MULTA, PLA_JUDIC, PLA_ASOC,	PLA_OTROS, PLA_LIQUIDO, ENC_COD_ORDGAS, PLA_FCHTRNS_ENT, PLA_FCHACRE_ENT, PLA_FCHCONF_BCO, PLA_FCHTRNS_DGT,
                              PLA_FCHTRNS_FUN, PLA_NRORECEP, PLA_NROREMITO, CTA_CODCTA, PEC_SECUEN, ETR_CODEST,	EST_CODIGO,	PLA_USUNOM,	PLA_USUFCH,	TPA_CODIGO, PLA_CONCEPTO,	DOC_NROASI,	ENC_COD_HABPAG)
      Values(x$ano,	v$nen_codigo,	v$ent_codigo,	x$mes,	reg.cedula,	v$sol_numero,	x$pla_tippresup,	v$obj_codigo,	null,	null,	reg.v_ctg_codigo,	reg.monto, v$uje_codigo,	
            reg.monto, null,	null,	null,	null,	null,	reg.monto,	x$cod_ordgas,	sysdate,	sysdate,	null,	sysdate,	
            null,	v_secuencia, null,	1, reg.pec_secuen,	1, 1, x$user, sysdate, null, reg.pla_concepto, v$doc_nroasi,	x$enc_cod_habpag);
    exception
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar insertar en la tabla a_pla@sinarh, mensaje:' || err_msg, true);
    end;
  end loop;
 return 0;
exception
when others then
  raise_application_error(v$err, 'Error en el procedimiento Orden Pago:'|| sqlerrm);
end;
/ 