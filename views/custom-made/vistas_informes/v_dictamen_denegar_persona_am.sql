 CREATE OR REPLACE FORCE VIEW "SPNC2AP112"."V_DICTAMEN_DENEGAR_PERSONA_AM" ("NUMERO_SIME", "IDPERSONA", "CEDULA", "NOMBRE_BENEFICIARIO", "IDCLASEPENSION", "CLASE_PENSION", "FECHA_RESOLUCION_DENEGAR", "FECHA_DICTAMEN_DENEGAR", "DICTAMEN_DENEGAR", "ESTADO_PENSION", "IDPENSION", "DEPARTAMENTO", "DISTRITO", "ANTECEDENTE_DENE", "ANTECEDENTE_DENE_UNO", "DISPOSICION_DENE_UNO", "DISPOSICION_DENE_DOS", "DISPOSICION_DENE_TRES", "OPINION_DENE_UNO", "OPINION_DENE_DOS", "OPINION_DENE_TRES", "NOMBRE_DIRECTOR", "LOTE", "NROSIME", "RESOLUCION_DENEGAR", "EDAD", "RESUMEN_DICTAMEN_DENEGAR", "RESUMEN_RESOLUCION_DENEGAR", "RESUMEN_DICTAMEN_OTORGAR", "RESUMEN_RESOLUCION_OTORGAR", "RESUMEN_DICTAMEN_REVOCAR", "RESUMEN_RESOLUCION_REVOCAR", "CAUSA_OBJECION") AS 
  Select case p.numero_sime_entrada when null then ex2.nro || '/' || ex2.ano	else ex.nro || '/' || ex.ano end numero_sime,
    	 pe.id as idpersona, pe.codigo cedula, pe.nombre as nombre_beneficiario, cp.id as idclasepension,
      cp.nombre clase_pension, to_char(p.FECHA_RESOLUCION_DENEGAR,'dd/mm/yyyy') fecha_resolucion_denegar,
      to_char(p.FECHA_DICTAMEN_DENEGAR,'dd/mm/yyyy') fecha_dictamen_denegar,p.dictamen_denegar dictamen_denegar,
    	 ep.codigo estado_pension, p.id idpension, de.nombre as departamento, di.nombre as distrito, p.antecedente_dene, p.antecedente_dene_uno,
      p.disposicion_dene_uno, p.disposicion_dene_dos, p.disposicion_dene_tres, p.opinion_dene_uno, p.opinion_dene_dos, p.opinion_dene_tres,
    	(select valor from variable_global where numero=107) as nombre_director, lp.lote,
      nvl(ex.id,ex2.id) as nrosime, p.resolucion_denegar as resolucion_denegar,calcular_edad(nvl(pe.fecha_nacimiento,'01-JAN-1900')) edad,
      p.RESUMEN_DICTAMEN_DENEGAR, p.RESUMEN_RESOLUCION_DENEGAR, p.RESUMEN_DICTAMEN_OTORGAR, p.RESUMEN_RESOLUCION_OTORGAR,
      p.RESUMEN_DICTAMEN_REVOCAR, p.RESUMEN_RESOLUCION_REVOCAR, op.comentarios as causa_objecion
From pension p inner join persona pe on pe.id=p.persona
  inner join clase_pension cp on cp.id=p.clase 
  inner join estado_pension ep on p.estado=ep.numero
  left outer join expediente@sgemh ex on p.numero_sime=ex.id
  left outer join expediente@sgemh ex2 on p.numero_sime_entrada=ex2.id
  inner join departamento de on pe.departamento = de.id
  inner join distrito di on pe.distrito = di.id
  inner join lote_pension lp on p.id = lp.pension
  left outer join objecion_pension op on p.id = op.pension And op.objecion_invalida='true'
Where resumen_dictamen_denegar is not null And p.estado in (4, 5);
