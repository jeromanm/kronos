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
exec xsp.dropone('view', 'consulta_regla');
create view consulta_regla as
select
    regla.id,
    regla.version,
    regla.tipo,
    regla.codigo,
    regla.nombre,
    regla.descripcion,
    regla.especial,
        tipo_regla_1.numero as numero_1,
        tipo_regla_1.codigo as codigo_1
    from regla
    inner join tipo_regla tipo_regla_1 on tipo_regla_1.numero = regla.tipo
;
