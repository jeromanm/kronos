/*
 * Este programa es software libre; usted puede redistribuirlo y/o modificarlo bajo los terminos
 * de la licencia "GNU General Public License" publicada por la Fundacion "Free Software Foundation".
 * Este programa se distribuye con la esperanza de que pueda ser util, pero SIN NINGUNA GARANTIA;
 * vea la licencia "GNU General Public License" para obtener mas informacion.
 */
/*
 * author: ADALID
 * template: templates/jee1/oracle/views/create-data-provider-view.sql.vm
 * template-author: Jorge Campins
 */
exec xsp.dropone('view', 'consulta_transicion_pension');
create view consulta_transicion_pension as
select
    transicion_pension.id,
    transicion_pension.version,
    transicion_pension.pension,
    transicion_pension.fecha,
    transicion_pension.usuario,
    transicion_pension.estado_inicial,
    transicion_pension.estado_final,
    transicion_pension.comentarios,
    transicion_pension.causa,
    transicion_pension.observaciones,
    transicion_pension.dictamen,
    transicion_pension.fecha_dictamen,
    transicion_pension.resumen_dictamen,
    transicion_pension.resolucion,
    transicion_pension.fecha_resolucion,
    transicion_pension.resumen_resolucion,
        pension_1.codigo as codigo_1,
        pension_1.segmento as segmento_1,
            segmento_pension_1_19.codigo as codigo_1_19,
            segmento_pension_1_19.nombre as nombre_1_19,
        usuario_2.codigo_usuario as codigo_usuario_2,
        usuario_2.nombre_usuario as nombre_usuario_2,
        estado_pension_3.numero as numero_3,
        estado_pension_3.codigo as codigo_3,
        estado_pension_4.numero as numero_4,
        estado_pension_4.codigo as codigo_4
    from transicion_pension
    inner join(pension pension_1
        left outer join segmento_pension segmento_pension_1_19 on segmento_pension_1_19.id = pension_1.segmento)
    on pension_1.id = transicion_pension.pension
    left outer join usuario usuario_2 on usuario_2.id_usuario = transicion_pension.usuario
    left outer join estado_pension estado_pension_3 on estado_pension_3.numero = transicion_pension.estado_inicial
    inner join estado_pension estado_pension_4 on estado_pension_4.numero = transicion_pension.estado_final
;
