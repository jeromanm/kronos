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
exec xsp.dropone('view', 'consulta_cedula');
create view consulta_cedula as
select
    cedula.id,
    cedula.version,
    cedula.numero,
    cedula.nombre,
    cedula.apellidos,
    cedula.nombres,
    cedula.fech_nacim,
    cedula.sexo,
    cedula.nacionalidad,
    cedula.estado_civil,
    cedula.profesion,
    cedula.fech_impresion,
    cedula.fech_ultim_act,
    cedula.fech_descarga,
        sexo_persona_1.numero as numero_1,
        sexo_persona_1.codigo as codigo_1,
        estado_civil_2.numero as numero_2,
        estado_civil_2.codigo as codigo_2
    from cedula
    left outer join sexo_persona sexo_persona_1 on sexo_persona_1.numero = cedula.sexo
    left outer join estado_civil estado_civil_2 on estado_civil_2.numero = cedula.estado_civil
;
