CREATE OR REPLACE FORCE VIEW V_DICTAMEN_RECO_DENEGAR AS 
  Select to_char(p.fecha_dictamen_denegar,'dd/mm/yyyy') fecha_dictamen_denegar, p.dictamen_denegar dictamen_denegar,
         ep.codigo estado_pension, p.id idpension,  pe.clase, cp.nombre clase_pension, per.nombre, p.ID tramite,
         (select valor from variable_global where numero=107) as nombre_director, p.RESOLUCION_DENEGAR, p.FECHA_RESOLUCION_DENEGAR,
         ex.codigo as sime, ex.id as nrosime, p.resolucion_otorgar resolucion_otorgar,
         to_char(p.fecha_resolucion_otorgar,'dd/mm/yyyy') fecha_resolucion_otorgar,
         p.RESUMEN_DICTAMEN_DENEGAR, p.RESUMEN_RESOLUCION_OTORGAR, p.RESUMEN_DICTAMEN_OTORGAR, p.RESUMEN_RESOLUCION_DENEGAR,
         p.ANTECEDENTE_DENEGAR, p.ANTECEDENTE_DENEGAR_UNO, p.DISPOSICION_DEN_DOS, p.DISPOSICION_DEN_TRES, p.DISPOSICION_DEN_UNO, 
		 p.OPINION_DEN_DOS, p.OPINION_DEN_TRES, p.OPINION_DEN_UNO   
    From reclamo_pension p inner join pension pe on pe.id=p.pension
      inner join PERSONA per on pe.persona=per.id
      inner join estado_pension ep on p.estado=ep.numero
      inner join clase_pension cp on cp.id=pe.CLASE
      left outer join expediente_sime ex on p.numero_sime=ex.id; 
/