
CREATE OR REPLACE FORCE VIEW V_DICTAMEN_DENEGAR_PERSONA AS 
Select case p.numero_sime_entrada when null then ex2.nro || '/' || ex2.ano  else ex.nro || '/' || ex.ano end numero_sime,
        pe.id as idpersona, pe.codigo cedula, pe.nombre as nombre_beneficiario, cp.id as idclasepension,
        cp.nombre clase_pension, to_char(p.fecha_dictamen_denegar,'dd/mm/yyyy') fecha_dictamen_denegar,  p.dictamen_denegar,
        ep.codigo estado_pension, p.id idpension, de.nombre as departamento, di.nombre as distrito, p.ANTECEDENTE_DENE, p.ANTECEDENTE_DENE_UNO,
        p.DISPOSICION_DENE_UNO, p.DISPOSICION_DENE_DOS, p.DISPOSICION_DENE_TRES, p.OPINION_DENE_UNO, p.OPINION_DENE_DOS,
        p.OPINION_DENE_TRES, nvl(ex.id,ex2.id) as nrosime, p.resolucion_denegar,
        (select valor from variable_global where numero=107) as nombre_director, op.comentarios as causa_objecion,
        to_char(p.fecha_resolucion_otorgar,'dd/mm/yyyy') fecha_resolucion_denegar, calcular_edad(pe.fecha_nacimiento) edad,
        p.resumen_dictamen_denegar, p.RESUMEN_RESOLUCION_denegar, p.estado
From pension p inner join persona pe on pe.id=p.persona
     inner join clase_pension cp on cp.id=p.clase
     inner join estado_pension ep on p.estado=ep.numero
     left outer join expediente@sgemh ex on p.numero_sime=ex.id
     left outer join expediente@sgemh ex2 on p.numero_sime_entrada=ex2.id
     inner join departamento de on pe.departamento = de.id
     inner join distrito di on pe.distrito = di.id
     left outer join objecion_pension op on p.id = op.pension And op.objecion_invalida='true';
/