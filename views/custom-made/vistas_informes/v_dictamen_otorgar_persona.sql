CREATE OR REPLACE FORCE VIEW V_DICTAMEN_OTORGAR_PERSONA as
 Select case p.numero_sime_entrada when null then ex2.nro || '/' || ex2.ano  else ex.nro || '/' || ex.ano end numero_sime,
        pe.id as idpersona, pe.codigo cedula, pe.nombre as nombre_beneficiario, cp.id as idclasepension,
            cp.nombre clase_pension, to_char(p.fecha_dictamen_otorgar,'dd/mm/yyyy') fecha_dictamen_otorgar, p.dictamen_otorgar dictamen_otorgar,
        ep.codigo estado_pension, p.id idpension, de.nombre as departamento, di.nombre as distrito, p.antecedente_oto, p.antecedente_oto_uno,
            p.disposicion_oto_uno, p.disposicion_oto_dos, p.disposicion_oto_tres, p.opinion_oto_uno, p.opinion_oto_dos, p.opinion_oto_tres,
        (select valor from variable_global where numero=107) as nombre_director,
            nvl(ex.id,ex2.id) as nrosime, p.resolucion_otorgar resolucion_otorgar,
            to_char(p.fecha_resolucion_otorgar,'dd/mm/yyyy') fecha_resolucion_otorgar, calcular_edad(pe.fecha_nacimiento) edad,
            p.RESUMEN_DICTAMEN_DENEGAR, p.RESUMEN_RESOLUCION_DENEGAR, p.RESUMEN_DICTAMEN_OTORGAR, p.RESUMEN_RESOLUCION_OTORGAR, p.RESUMEN_DICTAMEN_REVOCAR, p.RESUMEN_RESOLUCION_REVOCAR, 
            p.ANTECEDENTE_RESOL_OTO, p.DISPOSICION_RESOL_OTO_DOS, p.DISPOSICION_RESOL_OTO_TRES, p.DISPOSICION_RESOL_OTO_UNO, p.OPINION_RESOL_OTO_DOS, p.OPINION_RESOL_OTO_TRES, 
            p.OPINION_RESOL_OTO_UNO, p.RESUMEN_RESOL_OTO_DOS, p.RESUMEN_RESOL_OTO_TRES, p.RESUMEN_RESOL_OTO_UNO, p.ANTECEDENTE_RESOL_OTO_UNO
    From pension p inner join persona pe on pe.id=p.persona
        inner join clase_pension cp on cp.id=p.clase
      inner join estado_pension ep on p.estado=ep.numero
      left outer join expediente@sgemh ex on p.numero_sime=ex.id
         left outer join expediente@sgemh ex2 on p.numero_sime_entrada=ex2.id
         inner join departamento de on pe.departamento = de.id
      inner join distrito di on pe.distrito = di.id
    where --resumen_dictamen_otorgar is not null And 
    p.estado in (6, 7);
/