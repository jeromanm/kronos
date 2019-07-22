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
exec xsp.dropone('view', 'consulta_clase_pension');
create view consulta_clase_pension as
select
    clase_pension.id,
    clase_pension.version,
    clase_pension.codigo,
    clase_pension.nombre,
    clase_pension.grupo,
    clase_pension.fecha_decreto,
    clase_pension.decreto_ley,
    clase_pension.requiere_causante,
    clase_pension.requiere_censo,
    clase_pension.requiere_barrio,
    clase_pension.acredita,
    clase_pension.requiere_saldo,
    clase_pension.auxilio,
    clase_pension.pago_unico,
    clase_pension.parentesco_causante,
    clase_pension.clase_pension_causante,
    clase_pension.constante_txt,
        grupo_pension_1.codigo as codigo_1,
        grupo_pension_1.nombre as nombre_1,
        parentesco_2.numero as numero_2,
        parentesco_2.codigo as codigo_2,
        clase_pension_3.codigo as codigo_3,
        clase_pension_3.nombre as nombre_3
    from clase_pension
    inner join grupo_pension grupo_pension_1 on grupo_pension_1.id = clase_pension.grupo
    left outer join parentesco parentesco_2 on parentesco_2.numero = clase_pension.parentesco_causante
    left outer join clase_pension clase_pension_3 on clase_pension_3.id = clase_pension.clase_pension_causante
;
