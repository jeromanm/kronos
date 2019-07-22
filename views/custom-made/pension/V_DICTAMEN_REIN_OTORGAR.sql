CREATE OR REPLACE FORCE VIEW V_DICTAMEN_REIN_OTORGAR AS 
  Select to_char(p.FECHA_DICTAMEN_RECO_OTORGAR,'dd/mm/yyyy') fecha_dictamen_reco_otorgar, p.DICTAMEN_RECO_OTORGAR dictamen_reco_otorgar,
         ep.codigo estado_pension, p.id idpension,  pe.clase, cp.nombre clase_pension, per.nombre, p.ID tramite,
         (select valor from variable_global where numero=107) as nombre_director, ex.codigo as sime, ex.id as nrosime, 
         p.resolucion_otorgar resolucion_otorgar, to_char(p.fecha_resolucion_otorgar,'dd/mm/yyyy') fecha_resolucion_otorgar,
         p.RESU_DICT_RECO_OTOR, p.RESUMEN_RESOLUCION_OTORGAR, p.RESUMEN_DICTAMEN_OTORGAR, p.ANTECEDENTE_RECO_OTO, p.ANTECEDENTE_RECO_OTO_UNO,
		 p.DISPOSICION_RECO_OTO_DOS, p.DISPOSICION_RECO_OTO_TRES, p.DISPOSICION_RECO_OTO_UNO, p.OPINION_RECO_OTO_DOS,  
		 p.OPINION_RECO_OTO_TRES, p.OPINION_RECO_OTO_UNO
  From reclamo_pension p inner join pension pe on pe.id=p.pension
    inner join persona per on pe.persona=per.id
    inner join estado_pension ep on p.estado=ep.numero
    inner join clase_pension cp on cp.id=pe.CLASE
    left outer join expediente_sime ex on p.numero_sime=ex.id
  where p.estado in (4, 5);
  /