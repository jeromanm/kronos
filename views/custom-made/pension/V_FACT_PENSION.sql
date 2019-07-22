CREATE OR REPLACE FORCE VIEW V_FACT_PENSION AS 
  SELECT b."ID",b."ANHO_MES_DIA",b."DIA_MES_ANHO",b."MES_DIA_ANHO",b."ANHO_MES",b."ANHO_4",b."ANHO_2",b."MES",b."MES_NOMBRE",b."MES_ABREVIADO",
         b."DIA",b."DIA_NOMBRE",b."DIA_DEL_MES",b."DIA_DE_LA_SEMANA",b."DIA_ABREVIADO",b."FIN_DE_SEMANA",b."SEMANA_DEL_ANHO",b."SEMANA_DEL_MES",
         b."QUINCENA_DEL_MES",b."BIMESTRE_DEL_ANHO",b."TRIMESTRE_DEL_ANHO",b."CUATRIMESTRE_DEL_ANHO",b."SEMESTRE_DEL_ANHO",b."FERIADO",
         b."FECHA",b."FECHA_NOMBRE" ,
         c.nombre ClasePension,e.nombre persona,e.codigo,e.NOM_DEPARTAMENTO,e.NOM_DISTRITO, e.sexo, e.estado_civil,e.indigena,e.paraguayo,
         e.tipo_area,e.barrio,e.direccion, e.telefono_linea_baja,e.etnia, e.comunidad,f.usuario,a.solicitada,a.acreditada,a.otorgable, d.activa, d.fecha_activar,
         a.otorgada,a.denegable,a.denegada,a.revocable,a.revocada,a.finalizada,a.anulada
FROM fact_pension a inner join dim_tiempo b on a.id_tiempo = b.id 
  inner join tmp_clase_pension c on a.id_clasepension  = c.id
  inner join tmp_persona e on a.id_persona = e.id
  left outer join dim_usuario f on a.id_usuario = f.id_usuario
  inner join tmp_pension d on a.id_pension = d.id;
/