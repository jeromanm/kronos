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
exec xsp.dropone('view', 'consulta_lote_pension');
create view consulta_lote_pension as
select
    lote_pension.id,
    lote_pension.version,
    lote_pension.lote,
    lote_pension.pension,
    lote_pension.procesada_sin_errores,
    lote_pension.observaciones,
    lote_pension.fecha_lote_pension,
    lote_pension.excluir,
        lote_1.codigo as codigo_1,
        lote_1.nombre as nombre_1,
        pension_2.codigo as codigo_2
    from lote_pension
    inner join lote lote_1 on lote_1.id = lote_pension.lote
    inner join pension pension_2 on pension_2.id = lote_pension.pension
;
