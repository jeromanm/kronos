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
exec xsp.dropone('view', 'consulta_liquidacion_haberes');
create view consulta_liquidacion_haberes as
select
    liquidacion_haberes.id,
    liquidacion_haberes.version,
    liquidacion_haberes.codigo,
    liquidacion_haberes.fecha_desde,
    liquidacion_haberes.fecha_hasta,
    liquidacion_haberes.pension,
    liquidacion_haberes.fecha_calculo,
    liquidacion_haberes.numero_sime,
    liquidacion_haberes.usuario_transicion,
    liquidacion_haberes.abierto,
    liquidacion_haberes.recalculo,
    liquidacion_haberes.subsidio,
    liquidacion_haberes.observaciones,
        pension_1.codigo as codigo_1,
        usuario_3.codigo_usuario as codigo_usuario_3,
        usuario_3.nombre_usuario as nombre_usuario_3
    from liquidacion_haberes
    inner join pension pension_1 on pension_1.id = liquidacion_haberes.pension
    left outer join usuario usuario_3 on usuario_3.id_usuario = liquidacion_haberes.usuario_transicion
;
