CREATE OR REPLACE FORCE VIEW "SPNC2AP112"."V_DICTAMEN_OTORGAR_TRAMITE" ("ID_TRAMITE", "NUMERO_SIME", "ID_SIME", "ID_TIPO_TRAMITE", "TIPO_TRAMITE", "IDPERSONA", "CEDULA", "NOMBRE_BENEFICIARIO", "IDCLASEPENSION", "CLASE_PENSION", "FECHA_DICTAMEN_OTORGAR", "DICTAMEN_OTORGAR", "ESTADO_TAMITE", "ID_PENSION", "DEPARTAMENTO", "DISTRITO", "ANTECEDENTE_HABE_ATR", "ANTECEDENTE_HABE_ATR_UNO", "DISPOSICION_HABE_ATR_DOS", "DISPOSICION_HABE_ATR_TRES", "DISPOSICION_HABE_ATR_UNO", "OPINION_HABE_ATR_DOS", "OPINION_HABE_ATR_TRES", "OPINION_HABE_ATR_UNO", "NOMBRE_DIRECTOR", "RESOLUCION_OTORGAR", "FECHA_RESOLUCION_OTORGAR", "EDAD", "RESUMEN_DICTAMEN_HABE_ATRASADO", "RESUMEN_RESOL_HABE_ATRASADO") AS 
  Select ta.id as id_tramite, ex.codigo as numero_sime, ex.id as id_sime, ta.tipo as id_tipo_tramite, tt.codigo as tipo_tramite, 
        pe.id as idpersona, pe.codigo cedula, pe.nombre as nombre_beneficiario, cp.id as idclasepension,
        cp.nombre clase_pension, to_char(ta.FECHA_DICTAMEN_HABE_ATRASADO,'dd/mm/yyyy') fecha_dictamen_otorgar, ta.DICTAMEN_HABE_ATRASADO as dictamen_otorgar,
        et.codigo estado_tamite, pn.id as id_pension, de.nombre as departamento, di.nombre as distrito, ta.ANTECEDENTE_HABE_ATR, ta.ANTECEDENTE_HABE_ATR_UNO,
        ta.DISPOSICION_HABE_ATR_DOS, ta.DISPOSICION_HABE_ATR_TRES, ta.DISPOSICION_HABE_ATR_UNO, ta.OPINION_HABE_ATR_DOS, ta.OPINION_HABE_ATR_TRES,
        ta.OPINION_HABE_ATR_UNO, (select valor from variable_global where numero=107) as nombre_director,
        ta.RESOLUCION_HABE_ATRASADO as resolucion_otorgar, to_char(ta.FECHA_RESOLUCION_HABE_ATRASADO,'dd/mm/yyyy') as fecha_resolucion_otorgar, 
        calcular_edad(pe.fecha_nacimiento) edad, ta.RESUMEN_DICTAMEN_HABE_ATRASADO, ta.RESUMEN_RESOL_HABE_ATRASADO
  From tramite_administrativo ta inner join pension pn on ta.pension = pn.id 
    inner join persona pe on pe.id=pn.persona
    inner join clase_pension cp on cp.id=pn.clase
    inner join estado_tramite_administrativo et on ta.estado=et.numero
    left outer join expediente_sime ex on ta.numero_sime=ex.id
    inner join departamento de on pe.departamento = de.id
    inner join distrito di on pe.distrito = di.id
    inner join tipo_tramite_administrativo tt on ta.tipo = tt.numero;
/