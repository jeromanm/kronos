CREATE OR REPLACE FORCE VIEW V_DICTAMEN_REIN_DENEGAR AS 
  Select to_char(p.fecha_dictamen_rein_denegar,'dd/mm/yyyy') fecha_dictamen_rein_denegar, p.dictamen_rein_denegar dictamen_rein_denegar,
         ep.codigo estado_pension, p.id idpension,  pe.clase, cp.nombre clase_pension, per.nombre, p.ID tramite,
         (select valor from variable_global where numero=107) as nombre_director,
         ex.codigo as sime, ex.id as nrosime, p.resolucion_otorgar resolucion_otorgar,
         to_char(p.fecha_resolucion_otorgar,'dd/mm/yyyy') fecha_resolucion_otorgar,
         p.RESU_DICTA_REIN_DENE, p.RESUMEN_RESOLUCION_OTORGAR, p.RESUMEN_DICTAMEN_OTORGAR,
         p.ANTECEDENTE_REIN_DENE, p.ANTECEDENTE_REIN_DENE_UNO, p.DISPOSICION_REIN_DOS, p.DISPOSICION_REIN_TRES, p.DISPOSICION_REIN_UNO,
		 p.OPINION_REIN_DOS, p.OPINION_REIN_TRES, p.OPINION_REIN_UNO      
  From reclamo_pension p inner join pension pe on pe.id=p.pension
    inner join PERSONA per on pe.persona=per.id
    inner join estado_pension ep on p.estado=ep.numero
    inner join clase_pension cp on cp.id=pe.CLASE
    left outer join expediente_sime ex on p.numero_sime=ex.id
  Where p.estado in (2, 3);
/