 CREATE OR REPLACE FORCE VIEW V_HEREDEROS AS 
  Select cp.id as id_clase_pension_causante, cp.codigo as codigo_clase_pension_causante, cp.nombre as clase_pension_causante,
	    pn.id as id_pension_causante, pn.estado as estado_pension_causante, pn.activa as pension_enplanilla_causante,
	    pn.tiene_objecion as tiene_objecion_causante, op.comentarios as comentarioobjecion,
      coalesce(pn.NUMERO_SIME,pn.NUMERO_SIME_ENTRADA) as id_nro_sime_causante,
      --coalesce(es1.codigo,es2.codigo) as nro_sime_causante, 
      pe.id as id_persona_causante, pe.codigo as cedula_causante, pe.nombre as nombre_causante,
      pe.fecha_defuncion as fecha_defuncion_causante,
  	  (Select max(to_date('01/' || rpp.mes_resumen || '/' || rpp.ano_resumen,'dd/mm/yyyy')) 
      From resumen_pago_pension rpp inner join detalle_pago_pension dp on rpp.id = dp.resumen And dp.activo='true'
      Where rpp.pension=pn.id) as ultima_fecha_pago,
	    (Select max(rpp.monto) From resumen_pago_pension rpp inner join detalle_pago_pension dp on rpp.id = dp.resumen And dp.activo='true' 
      Where rpp.pension = pn.id 
        And to_date('01/' || rpp.mes_resumen || '/' || rpp.ano_resumen,'dd/mm/yyyy')=
        (Select max(to_date('01/' || rpp2.mes_resumen || '/' || rpp2.ano_resumen,'dd/mm/yyyy')) 
          From resumen_pago_pension rpp2 inner join detalle_pago_pension dp on rpp2.id = dp.resumen And dp.activo='true' 
          Where rpp2.pension=pn.id)) as montoultimopago,
	    pn.MONTO_EXCESO, pn.CANT_PLANILLA_EXCESO, pn.fecha_resolucion_revocar as fecha_irregular_causante,
      cp2.id as id_clasepension_heredero, cp2.codigo as codigo_clase_heredero, cp2.nombre as clase_pension_heredero,
	    pn2.id as id_pension_heredero, coalesce(pn2.NUMERO_SIME,pn2.NUMERO_SIME_ENTRADA) as id_nro_sime_heredero,
      es5.codigo as nro_sime_heredero,
	    pe2.codigo as ci_heredero, pe2.nombre as nombre_heredero, pn2.estado as estado_pension_heredero, pn2.activa as pension_enplanilla_heredero,
	    pn2.tiene_objecion as tiene_objecion_heredero, pe2.fecha_defuncion as fecha_defuncion_heredero, pe2.NUMERO_SIME_DEFUNCION as id_nro_sime_defuncion,
      pn2.resolucion_denegar, pn2.resumen_resolucion_denegar,  pn2.dictamen_denegar
From pension pn inner join persona pe on pn.persona = pe.id
    inner join clase_pension cp on pn.clase=cp.id
    inner join pension pn2 on pn2.causante = pe.id
    inner join persona pe2 on pe2.id = pn2.persona
    inner join clase_pension cp2 on pn2.clase=cp2.id And cp2.clase_pension_causante=cp.id
    left outer join expediente_sime es5 on pn2.NUMERO_SIME_ENTRADA = es5.id or pn2.NUMERO_SIME=es5.id
    left outer join objecion_pension op on pn2.id = op.pension And op.objecion_invalida='true';

CREATE OR REPLACE FORCE VIEW V_HEREDEROS2 AS
  Select pe.codigo as ci_here, pe.nombre as nombre_here, pe.fecha_defuncion as fecha_defuncion_here, 
	       pn.tiene_objecion as tiene_objecion_here, pe.NUMERO_SIME_DEFUNCION as id_nrosime_def_here,
         pn.resolucion_denegar as resol_dene_here, pn.resumen_resolucion_denegar as resumen_res_rev_here, pn.dictamen_denegar as dic_dene_here, 
         (Select max(to_date('01/' || rpp.mes_resumen || '/' || rpp.ano_resumen,'dd/mm/yyyy')) 
          From resumen_pago_pension rpp inner join detalle_pago_pension dp on rpp.id = dp.resumen And dp.activo='true'
          Where rpp.pension=pn.id) as ultm_fecha_pago_here,
         (Select max(rpp.monto) From resumen_pago_pension rpp inner join detalle_pago_pension dp on rpp.id = dp.resumen And dp.activo='true' 
          Where rpp.pension = pn.id And to_date('01/' || rpp.mes_resumen || '/' || rpp.ano_resumen,'dd/mm/yyyy')=
         (Select max(to_date('01/' || rpp2.mes_resumen || '/' || rpp2.ano_resumen,'dd/mm/yyyy')) 
          From resumen_pago_pension rpp2 inner join detalle_pago_pension dp on rpp2.id = dp.resumen And dp.activo='true' 
          Where rpp2.pension=pn.id)) as monto_ult_pago_here,
         pn.MONTO_EXCESO as monto_exceso_here, pn.CANT_PLANILLA_EXCESO as cant_pla_exceso_here, pn.fecha_resolucion_revocar as fecha_irregular_here,
         cp.id as id_clase_heredero, cp.codigo as cod_clase_heredero, cp.nombre as clase_pension_heredero,
         pn.id as id_pension_heredero, coalesce(pn.NUMERO_SIME,pn.NUMERO_SIME_ENTRADA) as id_nro_sime_heredero,
         es.codigo as nro_sime_heredero, pn.causante as id_persona_causante
From pension pn inner join persona pe on pn.persona = pe.id
    inner join clase_pension cp on pn.clase=cp.id
    left outer join expediente_sime es on pn.NUMERO_SIME_ENTRADA = es.id;
/