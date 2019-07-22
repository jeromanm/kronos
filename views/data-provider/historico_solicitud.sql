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
exec xsp.dropone('view', 'consulta_historico_solicitud');
create view consulta_historico_solicitud as
select
    historico_solicitud.id,
    historico_solicitud.version,
    historico_solicitud.codigo,
    historico_solicitud.departamento,
    historico_solicitud.distrito,
    historico_solicitud.fecha_entrevista,
    historico_solicitud.nro_cedula,
    historico_solicitud.nombres,
    historico_solicitud.apodo,
    historico_solicitud.edad,
    historico_solicitud.fecha_nacimiento,
    historico_solicitud.direccion,
    historico_solicitud.telefono,
    historico_solicitud.referencia_casa,
    historico_solicitud.barrio,
    historico_solicitud.nomb_referente,
    historico_solicitud.telefono_referente,
    historico_solicitud.sime
    from historico_solicitud
;
