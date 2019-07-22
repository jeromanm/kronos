CREATE OR REPLACE FORCE VIEW V_CONSULTA_AL_CIUDADANO as
  select b.anho_4 ANIO, b.mes as mes_numero, b.MES_NOMBRE, b.DIA, c.codigo CANAL_ATENCION ,ca.nombre as CLASIFICACION_CONSULTA ,a.FECHA_RECEPCION ,a.NUMERO_SIME as id_sime, i.codigo as numero_sime,
          ce.numero as CEDULA_RECURRENTE ,a.NOMBRE_RECURRENTE ,de.codigo id_departamento, di.codigo id_distrito, de.nombre departamento, di.nombre distrito, d.nombre CLASE_PENSION,
            e.codigo as cedula_beneficiario, e.NOMBRE as nombre_beneficiario, j.codigo as ESTADO_PENSION ,h.codigo RECLAMO ,a.DESCRIPCION ,
            a.dependencia as id_dependencia, a.dependencia as nombre_dependencia ,a.FECHA_DEPENDENCIA ,a.DIAS_DEPENDENCIA ,a.SITUACION ,a.DESTINO,a.ESTADO,
            a.FECHA_FINIQUITO,a.DIAS_RECLAMO,a.DIAS_SIME,a.CANTIDAD_CONSULTAS,a.FECHA_ULTIMA_CONSULTA,a.CONTACTO,a.NUMERO_TELEFONO_CONTACTO,a.TELEFONO_CELULAR,a.CONTACTO_CORREO,
            a.FECHA_AVISO_RECURRENTE, us.codigo_usuario as USUARIO_AVISO_RECURRENTE,a.CANAL_AVISO_RECURRENTE,a.DIAS_TRANSCURRIDO, ep.codigo as estado_censo, cp.fecha as fecha_censo
  From consulta_ciudadano a inner join dim_tiempo b on TO_CHAR(a.FECHA_RECEPCION,'YYYY') = b.anho_4 and TO_CHAR(a.FECHA_RECEPCION,'MM') = b.mes and TO_CHAR(a.FECHA_RECEPCION,'DD') = b.dia
    inner join CLASIFICACION_CONSULTA ca on a.CLASIFICACION_CONSULTA = ca.id
    inner join canal_atencion c on a.canal_atencion = c.numero
    left outer join clase_pension d on a.clase_pension= d.id
    left outer join departamento de on a.departamento= de.id
    left outer join distrito di on a.distrito= di.id
    left outer join persona e on a.persona=e.id 
    left outer join pension f on a.pension = f.id
    left outer join reclamo_pension g on a.RECLAMO = g.id
    left outer join tramite_administrativo ta on a.tramite = ta.id
    left outer join tipo_reclamo h on g.tipo =h.numero
    left outer join expediente_sime i on g.NUMERO_SIME = i.id or ta.numero_sime=i.id
    left outer join estado_pension j on f.estado = j.numero
    left outer join cedula ce on a.cedula_recurrente = ce.id
    left outer join usuario us on a.USUARIO_AVISO_RECURRENTE = us.id_usuario
    left outer join censo_persona cp on a.censo = cp.id
    left outer join estado_censo ep on cp.estado = ep.numero;
/