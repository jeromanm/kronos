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
exec xsp.dropone('view', 'consulta_heredero');
create view consulta_heredero as
select
    heredero.id,
    heredero.version,
    heredero.persona,
    heredero.parentesco,
    heredero.heredero,
    heredero.relacion,
    heredero.nro_expediente,
    heredero.lugar_jusgado,
    heredero.tomo,
    heredero.folio,
    heredero.fecha_sentencia,
        persona_1.codigo as codigo_1,
        persona_1.nombre as nombre_1,
        parentesco_2.numero as numero_2,
        parentesco_2.codigo as codigo_2,
        persona_3.codigo as codigo_3,
        persona_3.nombre as nombre_3
    from heredero
    inner join persona persona_1 on persona_1.id = heredero.persona
    inner join parentesco parentesco_2 on parentesco_2.numero = heredero.parentesco
    inner join persona persona_3 on persona_3.id = heredero.heredero
;
