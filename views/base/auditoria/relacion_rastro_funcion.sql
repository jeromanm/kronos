exec xsp.dropone('view', 'relacion_rastro_funcion');
create view relacion_rastro_funcion as
select  rastro_funcion.*,
        funcion.numero_tipo_funcion,
        funcion.es_publica, funcion.es_programatica, funcion.es_protegida,
        funcion.es_personalizable, funcion.es_segmentable, funcion.es_supervisable, funcion.es_heredada,
        clase_recurso.id_clase_recurso, clase_recurso.codigo_clase_recurso, clase_recurso.nombre_clase_recurso,
        usuario.es_super_usuario
from	rastro_funcion
	inner join (funcion
            left outer join (dominio
                inner join clase_recurso on clase_recurso.id_clase_recurso = dominio.id_clase_recurso
            ) on dominio.id_dominio = funcion.id_dominio
        ) on funcion.id_funcion = rastro_funcion.id_funcion
	left outer join usuario
            on usuario.id_usuario = rastro_funcion.id_usuario
;

exec xsp.dropone('view', 'relacion_rastro_funcion_par');
create view relacion_rastro_funcion_par as
select  rastro_funcion_par.id_rastro_funcion_par, rastro_funcion_par.id_parametro, rastro_funcion_par.valor_parametro,
        relacion_rastro_funcion.*,
        parametro.descripcion_parametro, parametro.numero_tipo_dato_par
from	rastro_funcion_par
        inner join relacion_rastro_funcion
            on relacion_rastro_funcion.id_rastro_funcion = rastro_funcion_par.id_rastro_funcion
	inner join parametro
            on parametro.id_parametro = rastro_funcion_par.id_parametro
;
