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
exec xsp.dropone('view', 'consulta_argu_fich_perso_12335');
create view consulta_argu_fich_perso_12335 as
select
    argumento_ficha_persona.id,
    argumento_ficha_persona.version,
    argumento_ficha_persona.pregunta,
    argumento_ficha_persona.parametro,
    argumento_ficha_persona.numero,
    argumento_ficha_persona.argumento_hogar,
    argumento_ficha_persona.argumento_persona,
        pregunta_ficha_persona_1.clave as clave_1,
        pregunta_ficha_persona_1.nombre as nombre_1,
        parametro_ficha_hogar_2.codigo as codigo_2,
        parametro_ficha_hogar_2.nombre as nombre_2,
        pregunta_ficha_hogar_3.clave as clave_3,
        pregunta_ficha_hogar_3.nombre as nombre_3,
        pregunta_ficha_persona_4.clave as clave_4,
        pregunta_ficha_persona_4.nombre as nombre_4
    from argumento_ficha_persona
    inner join pregunta_ficha_persona pregunta_ficha_persona_1 on pregunta_ficha_persona_1.id = argumento_ficha_persona.pregunta
    inner join parametro_ficha_hogar parametro_ficha_hogar_2 on parametro_ficha_hogar_2.id = argumento_ficha_persona.parametro
    left outer join pregunta_ficha_hogar pregunta_ficha_hogar_3 on pregunta_ficha_hogar_3.id = argumento_ficha_persona.argumento_hogar
    left outer join pregunta_ficha_persona pregunta_ficha_persona_4 on pregunta_ficha_persona_4.id = argumento_ficha_persona.argumento_persona
;
