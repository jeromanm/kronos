  CREATE OR REPLACE FORCE VIEW "SPNC2AP112"."V_DICTAMEN_DENEGAR_TRAMITE" ("ID_TRAMITE", "NUMERO_SIME", "ID_SIME", "ID_TIPO_TRAMITE", "TIPO_TRAMITE", "IDPERSONA", "CEDULA", "NOMBRE_BENEFICIARIO", "IDCLASEPENSION", "CLASE_PENSION", "FECHA_DICTAMEN_DENEGAR", "DICTAMEN_DENEGAR", "ESTADO_TAMITE", "ID_PENSION", "DEPARTAMENTO", "DISTRITO", "ANTECEDENTE_DENE", "ANTECEDENTE_DENE_UNO", "DISPOSICION_DENE_UNO", "DISPOSICION_DENE_DOS", "DISPOSICION_DENE_TRES", "OPINION_DENE_UNO", "OPINION_DENE_DOS", "OPINION_DENE_TRES", "NOMBRE_DIRECTOR", "RESOLUCION_DENEGAR", "FECHA_RESOLUCION_DENEGAR", "EDAD", "RESUMEN_DICTAMEN_DENEGAR", "RESUMEN_RESOLUCION_DENEGAR") AS 
  Select ta.id as id_tramite, ex.codigo as numero_sime, ex.id as id_sime, ta.tipo as id_tipo_tramite, tt.codigo as tipo_tramite, 
        pe.id as idpersona, pe.codigo cedula, pe.nombre as nombre_beneficiario, cp.id as idclasepension,
        cp.nombre clase_pension, to_char(ta.FECHA_DICTAMEN_DENEGAR,'dd/mm/yyyy') fecha_dictamen_denegar, ta.dictamen_denegar,
        et.codigo estado_tamite, pn.id as id_pension, de.nombre as departamento, di.nombre as distrito, ta.ANTECEDENTE_DENE, ta.ANTECEDENTE_DENE_UNO,
        ta.DISPOSICION_DENE_UNO, ta.DISPOSICION_DENE_DOS, ta.DISPOSICION_DENE_TRES, ta.OPINION_DENE_UNO, ta.OPINION_DENE_DOS,
        ta.OPINION_DENE_TRES, (select valor from variable_global where numero=107) as nombre_director,
        ta.resolucion_denegar, to_char(ta.FECHA_RESOLUCION_DENEGAR,'dd/mm/yyyy') as fecha_resolucion_denegar, 
        calcular_edad(pe.fecha_nacimiento) edad, ta.RESUMEN_DICTAMEN_DENEGAR, ta.RESUMEN_RESOLUCION_DENEGAR
  From tramite_administrativo ta inner join pension pn on ta.pension = pn.id 
    inner join persona pe on pe.id=pn.persona
    inner join clase_pension cp on cp.id=pn.clase
    inner join estado_tramite_administrativo et on ta.estado=et.numero
    left outer join expediente_sime ex on ta.numero_sime=ex.id
    inner join departamento de on pe.departamento = de.id
    inner join distrito di on pe.distrito = di.id
    inner join tipo_tramite_administrativo tt on ta.tipo = tt.numero;
