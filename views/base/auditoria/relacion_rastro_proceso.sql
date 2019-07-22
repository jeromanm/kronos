exec xsp.dropone('view', 'relacion_rastro_proceso');
create view relacion_rastro_proceso as
select  rastro_proceso.*,
	funcion.numero_tipo_funcion,
	funcion.es_publica, funcion.es_programatica, funcion.es_protegida,
        funcion.es_personalizable, funcion.es_segmentable, funcion.es_supervisable, funcion.es_heredada,
        clase_recurso.id_clase_recurso, clase_recurso.codigo_clase_recurso, clase_recurso.nombre_clase_recurso,
        condicion_eje_fun.codigo_condicion_eje_fun,
	usuario.es_super_usuario
from	rastro_proceso
	inner join (funcion
            left outer join (dominio
                inner join clase_recurso on clase_recurso.id_clase_recurso = dominio.id_clase_recurso
            ) on dominio.id_dominio = funcion.id_dominio
        ) on funcion.id_funcion = rastro_proceso.id_funcion
	inner join condicion_eje_fun
            on condicion_eje_fun.numero_condicion_eje_fun = rastro_proceso.numero_condicion_eje_fun
	left outer join usuario
            on usuario.id_usuario = rastro_proceso.id_usuario
;
