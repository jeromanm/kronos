CREATE OR REPLACE FORCE VIEW V_LIQUIDACION_HABERES as 
  Select lp.id as id_liquidacion, lp.codigo as codigoliquidacion, to_char(lp.fecha_calculo,'dd/mm/yyyy') as fecha_calculo, to_char(lp.fecha_desde,'dd/mm/yyyy') as fecha_desde,
      to_char(lp.fecha_hasta,'dd/mm/yyyy') as fecha_hasta, lp.observaciones, es.numero as nro_sime, lp.numero_sime as id_sime, sum(case co.tipo_concepto when 1 then dl.monto else (dl.monto*-1) end) as total,
      GEN_CONVIERTE_NUM_TXT(abs(sum(case co.tipo_concepto when 1 then dl.monto else (dl.monto*-1) end))) as monto_total_letra,
      sum(case co.tipo_concepto when 1 then dl.monto else (dl.monto*-1) end) as monto_numero,
      (Select sum(dl1.monto) From detalle_liqu_haber dl1 Where lp.id = dl1.liquidacion_haberes And dl1.clase_concepto=1) as monto_permantente,
      pe.codigo as cedula_persona, pe.nombre as nombres_persona, pe.fecha_nacimiento, cp.id as id_clase_pension, cp.nombre as clase_pension, 
      pn.id as idpension, pn.dictamen_otorgar, pe2.codigo as cedula_causante, pe2.nombre as nombre_causante, pe2.salario as salario_causante, 
      pe2.porcentaje, pe2.fecha_defuncion, pa.codigo as parentesco, 
      (Select max(to_date('01/' || rp.mes_resumen || '/' || rp.ano_resumen,'dd/mm/yyyy')) 
        From resumen_pago_pension rp inner join pension pn2 on rp.pension = pn2.id
        where pn2.persona=pe2.id) as max_resumen_pago_causante
From liquidacion_haberes lp inner join detalle_liqu_haber dl on lp.id = dl.liquidacion_haberes And dl.proyectado='false'
  inner join clase_concepto co on dl.clase_concepto = co.id
  inner join pension pn on lp.pension = pn.id
  inner join persona pe on pn.persona = pe.id
  inner join clase_pension cp on pn.clase = cp.id
  left outer join expediente_sime es on lp.numero_sime = es.id
  left outer join parentesco pa on cp.parentesco_causante = pa.numero
  left outer join persona pe2 on pn.causante = pe2.id
Group By lp.id, lp.codigo, lp.fecha_calculo, lp.fecha_desde, lp.fecha_hasta, lp.observaciones, es.numero, lp.numero_sime, pe.codigo, pe.nombre, 
          pe.fecha_nacimiento, cp.id, cp.nombre, pn.id, pn.dictamen_otorgar, pe2.codigo, pe2.nombre, pe2.salario, pe2.porcentaje, 
          pe2.fecha_defuncion, pa.codigo, pe2.id;
/