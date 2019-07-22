CREATE OR REPLACE FORCE VIEW V_DICTAMEN_REVOCAR_PERSONA AS 
Select case p.numero_sime_entrada when null then ex2.nro || '/' || ex2.ano  else ex.nro || '/' || ex.ano end numero_sime,
        pe.id as idpersona, pe.codigo cedula, pe.nombre as nombre_beneficiario, cp.id as idclasepension,
        cp.nombre clase_pension, to_char(p.fecha_dictamen_revocar,'dd/mm/yyyy') fecha_dictamen_revocar, p.dictamen_revocar,
        ep.codigo estado_pension, p.id idpension, de.nombre as departamento, di.nombre as distrito, p.ANTECEDENTE_REVO, p.ANTECEDENTE_REVO_UNO,
        p.DISPOSICION_REVO_UNO, p.DISPOSICION_REVO_DOS, p.DISPOSICION_REVO_TRES, p.OPINION_REVO_UNO, p.OPINION_REVO_DOS,
        p.OPINION_REVO_TRES, nvl(ex.id,ex2.id) as nrosime, p.resolucion_revocar,
        (select valor from variable_global where numero=107) as nombre_director, op.comentarios as causa_objecion,
        to_char(p.fecha_resolucion_otorgar,'dd/mm/yyyy') fecha_resolucion_revocar, calcular_edad(pe.fecha_nacimiento) edad,
        p.RESUMEN_DICTAMEN_revocar, p.RESUMEN_RESOLUCION_revocar, p.estado
From pension p inner join persona pe on pe.id=p.persona
     inner join clase_pension cp on cp.id=p.clase
     inner join estado_pension ep on p.estado=ep.numero
     left outer join expediente@sgemh ex on p.numero_sime=ex.id
     left outer join expediente@sgemh ex2 on p.numero_sime_entrada=ex2.id
     inner join departamento de on pe.departamento = de.id
     inner join distrito di on pe.distrito = di.id
     left outer join objecion_pension op on p.id = op.pension And op.objecion_invalida='true';
/