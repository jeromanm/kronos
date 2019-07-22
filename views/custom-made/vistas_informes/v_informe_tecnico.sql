CREATE OR REPLACE FORCE VIEW V_INFORME_TECNICO AS 
  Select cp.id as id_clase_pension_heredero, cp.codigo as codigo_clase_pension_heredero, cp.nombre as clase_pension_heredero,
        pn.id as id_pension_heredero, pn.estado as estado_pension_heredero, pn.activa as pension_enplanilla_heredero,
        pn.tiene_objecion as tiene_objecion_heredero, op.comentarios as comentarioobjecion, coalesce(pn.NUMERO_SIME,pn.NUMERO_SIME_ENTRADA) as id_nro_sime_heredero,
        es2.codigo as nro_sime_heredero, pe.codigo as cedula_heredero, pe.nombre as nombreheredero,
        pn.resolucion_denegar, pn.resumen_resolucion_denegar, pn.dictamen_denegar,
        cp2.id as id_clasepension_causante, cp2.codigo as codigo_clase_causante, cp2.nombre as clase_pension_causante,
        pn2.id as id_pension_causante, coalesce(pn2.NUMERO_SIME,pn2.NUMERO_SIME_ENTRADA) as id_nro_sime_causante,
        pe2.codigo as ci_causante, pe2.nombre as nombre_causante, pn2.estado as estado_pension_causante, pn2.activa as pension_enplanilla_causante,
        pn2.tiene_objecion as tiene_objecion_causante, pe2.fecha_defuncion as fecha_defuncion_causante, pe2.NUMERO_SIME_DEFUNCION as id_nro_sime_defuncion,
        null as nro_sime_defuncion,
        (Select max(to_date('01/' || rpp.mes_resumen || '/' || rpp.ano_resumen,'dd/mm/yyyy')) 
        From resumen_pago_pension rpp inner join detalle_pago_pension dp on rpp.id = dp.resumen And dp.activo='true' 
        Where rpp.pension=pn2.id) as ultima_fecha_pago,
        (Select max(rpp.monto) 
        From resumen_pago_pension rpp inner join detalle_pago_pension dp on rpp.id = dp.resumen And dp.activo='true' 
        Where rpp.pension = pn2.id And to_date('01/' || rpp.mes_resumen || '/' || rpp.ano_resumen,'dd/mm/yyyy')=
          (Select max(to_date('01/' || rpp2.mes_resumen || '/' || rpp2.ano_resumen,'dd/mm/yyyy')) 
            From resumen_pago_pension rpp2 inner join detalle_pago_pension dp2 on rpp2.id = dp2.resumen And dp2.activo='true' 
            Where rpp2.pension=pn2.id)) as montoultimopago,
        pn2.MONTO_EXCESO, pn2.CANT_PLANILLA_EXCESO, pn2.FECHA_resolucion_revocar as fecha_irregular_causante
  From pension pn inner join persona pe on pn.persona = pe.id
    inner join clase_pension cp on pn.clase=cp.id
    left outer join persona pe2 on pn.causante = pe2.id
    left outer join pension pn2 on pe2.id = pn2.persona
    left outer join clase_pension cp2 on pn2.clase=cp2.id
    left outer join objecion_pension op on pn.id = op.pension And op.objecion_invalida='true'
    left outer join expediente_sime es2 on pn.NUMERO_SIME_ENTRADA = es2.id;
/