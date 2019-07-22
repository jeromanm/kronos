  CREATE OR REPLACE FORCE VIEW V_COBROS_MASIVOS_CSV  AS 
  Select pe.codigo as cedula, pe.nombre, pn.fecha_dictamen_revocar,  nvl(pn.monto_red_bancaria,0) as monto_extracto, 
  cp.codigo as clase_pension, op.FECHA_TRANSICION as fecha_objecion, pe.fecha_defuncion, pn.cant_planilla_exceso, pn.monto_exceso,
  dt.nombre as Nom_Distrito, dp.nombre as Nom_Departamento,nvl(pn.monto_reintegro,0) as monto_reintegro,
    rp.monto as monto_ultimo_resumen, dt.codigo as distrito, nvl(ctp.ctp_debito,0) as monto_reintegrado_red_bancaria,
    decode(ctp.ctp_estado,1,'Pendiente',2,'Remitido al Banco',3,'Confirmado',4,'Debitado por el Banco') desc_estado_reintegro,
    (Select ex.codigo
			From tramite_administrativo ta inner join expediente_sime ex on ta.numero_sime = ex.id
			Where ta.estado=1 And ta.tipo=2 And rownum=1 And ta.pension=pn.id) as sime
From pension pn inner join persona pe on pn.persona = pe.id
inner join objecion_pension op on pn.id = op.pension And op.objecion_invalida='true'
inner join regla_clase_pension rp on op.regla = rp.id
inner join regla re on rp.regla = re.id And re.id=151439030500010000
inner join clase_pension cp on pn.clase = cp.id
inner join resumen_pago_pension rp on pn.id = rp.pension
  And to_date('01/' || rp.mes_resumen || '/' || rp.ano_resumen,'dd/mm/yyyy')
    =(Select max(to_date('01/' || rp2.mes_resumen || '/' || rp2.ano_resumen,'dd/mm/yyyy'))
      From resumen_pago_pension rp2 Where pn.id = rp2.pension)
inner join departamento dp on pe.departamento = dp.id
inner join distrito dt on pe.distrito = dt.id
left outer join  a_ctp@sinarh ctp on ctp.per_codcci =pe.codigo and ctp.nen_codigo = 12 and ctp.ent_codigo = 6
Where nvl(pn.cant_planilla_exceso,0)>0
ORDER BY cedula;