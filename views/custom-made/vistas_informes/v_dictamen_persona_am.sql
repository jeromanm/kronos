CREATE OR REPLACE FORCE VIEW V_DICTAMEN_PERSONA_AM AS 
  Select case p.numero_sime_entrada when null then ex2.nro || '/' || ex2.ano	else ex.nro || '/' || ex.ano end numero_sime,
    	 pe.id as idpersona, pe.codigo cedula, pe.nombre as nombre_beneficiario, cp.id as idclasepension,
      cp.nombre clase_pension, case when p.FECHA_RESOLUCION_DENEGAR is null then '01/01/1900' else to_char(p.FECHA_RESOLUCION_DENEGAR,'dd/mm/yyyy') end fecha_resolucion_denegar,
      case when p.FECHA_DICTAMEN_DENEGAR is null then '01/01/1900' else to_char(p.FECHA_DICTAMEN_DENEGAR,'dd/mm/yyyy') end fecha_dictamen_denegar,
      p.dictamen_denegar dictamen_denegar, p.estado,
    	 ep.codigo estado_pension, p.id idpension, de.nombre as departamento, di.nombre as distrito, p.antecedente_dene, p.antecedente_dene_uno,	
      p.disposicion_dene_uno, p.disposicion_dene_dos, p.disposicion_dene_tres, p.opinion_dene_uno, p.opinion_dene_dos, p.opinion_dene_tres,
    	(select valor from variable_global where numero=107) as nombre_director, to_char(p.FECHA_DICTAMEN_OTORGAR,'dd/mm/yyyy') as FECHA_DICTAMEN_OTORGAR,
      p.RESOLUCION_OTORGAR, case when p.FECHA_RESOLUCION_OTORGAR is null then '01/01/1900' else to_char(p.FECHA_RESOLUCION_OTORGAR,'dd/mm/yyyy') end as FECHA_RESOLUCION_OTORGAR,
      p.RESOLUCION_REVOCAR, case when p.FECHA_RESOLUCION_REVOCAR is null then '01/01/1900' else to_char(p.FECHA_RESOLUCION_REVOCAR,'dd/mm/yyyy') end as FECHA_RESOLUCION_REVOCAR, 
      nvl(ex.id,ex2.id) as nrosime, p.resolucion_denegar as resolucion_denegar,calcular_edad(pe.fecha_nacimiento) edad,
      p.RESUMEN_DICTAMEN_DENEGAR, p.RESUMEN_RESOLUCION_DENEGAR, p.RESUMEN_DICTAMEN_OTORGAR, p.RESUMEN_RESOLUCION_OTORGAR,
      p.RESUMEN_DICTAMEN_REVOCAR, p.RESUMEN_RESOLUCION_REVOCAR, op.comentarios as causa_objecion, p.DICTAMEN_REVOCAR, 
      case when p.FECHA_DICTAMEN_REVOCAR is null then to_char(p.FECHA_DICTAMEN_REVOCAR,'dd/mm/yyyy') end as FECHA_DICTAMEN_REVOCAR,
      (Select cp.monto
      From planilla_pago pp inner join concepto_planilla_pago cp on pp.id = cp.planilla
      Where pp.clase_pension=150498912213505560 And cp.clase_concepto=1 And rownum=1) as monto,
      GEN_CONVIERTE_NUM_TXT((Select cp.monto
      From planilla_pago pp inner join concepto_planilla_pago cp on pp.id = cp.planilla
      Where pp.clase_pension=150498912213505560 And cp.clase_concepto=1 And rownum=1)) as monto_letra
From pension p inner join persona pe on pe.id=p.persona
  inner join clase_pension cp on cp.id=p.clase
  inner join estado_pension ep on p.estado=ep.numero
  left outer join expediente@sgemh ex on p.numero_sime=ex.id
  left outer join expediente@sgemh ex2 on p.numero_sime_entrada=ex2.id
  inner join departamento de on pe.departamento = de.id
  inner join distrito di on pe.distrito = di.id
  left outer join objecion_pension op on p.id = op.pension And op.objecion_invalida='true';
/