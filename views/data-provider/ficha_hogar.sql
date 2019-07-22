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
exec xsp.dropone('view', 'consulta_ficha_hogar');
create view consulta_ficha_hogar as
select
    ficha_hogar.id,
    ficha_hogar.version,
    ficha_hogar.codigo,
    ficha_hogar.numero_formulario,
    ficha_hogar.numero_vivienda,
    ficha_hogar.numero_hogar,
    ficha_hogar.fecha_entrevista,
    ficha_hogar.censista_externo,
    ficha_hogar.censista_interno,
    ficha_hogar.supervisor,
    ficha_hogar.critico_codificador,
    ficha_hogar.digitador,
    ficha_hogar.comentarios,
    ficha_hogar.version_ficha_hogar,
    ficha_hogar.estado,
    ficha_hogar.fecha_transicion,
    ficha_hogar.usuario_transicion,
    ficha_hogar.observaciones_aceptar,
    ficha_hogar.observaciones_anular,
    ficha_hogar.observaciones_corregir,
    ficha_hogar.observaciones_verificar,
    ficha_hogar.icv,
    ficha_hogar.gps,
    ficha_hogar.orden,
    ficha_hogar.coordenada_x,
    ficha_hogar.coordenada_y,
    ficha_hogar.url_google_maps,
    ficha_hogar.departamento,
    ficha_hogar.distrito,
    ficha_hogar.tipo_area,
    ficha_hogar.barrio,
    ficha_hogar.manzana,
    ficha_hogar.direccion,
    ficha_hogar.numero_sime,
    ficha_hogar.archivo,
    ficha_hogar.linea,
        censista_1.codigo as codigo_1,
        censista_1.nombre as nombre_1,
        usuario_2.codigo_usuario as codigo_usuario_2,
        usuario_2.nombre_usuario as nombre_usuario_2,
        usuario_3.codigo_usuario as codigo_usuario_3,
        usuario_3.nombre_usuario as nombre_usuario_3,
        usuario_4.codigo_usuario as codigo_usuario_4,
        usuario_4.nombre_usuario as nombre_usuario_4,
        usuario_5.codigo_usuario as codigo_usuario_5,
        usuario_5.nombre_usuario as nombre_usuario_5,
        estado_ficha_hogar_6.numero as numero_6,
        estado_ficha_hogar_6.codigo as codigo_6,
        usuario_7.codigo_usuario as codigo_usuario_7,
        usuario_7.nombre_usuario as nombre_usuario_7,
        departamento_8.codigo as codigo_8,
        departamento_8.nombre as nombre_8,
        distrito_9.codigo as codigo_9,
        distrito_9.nombre as nombre_9,
        tipo_area_10.numero as numero_10,
        tipo_area_10.codigo as codigo_10,
        barrio_11.codigo as codigo_11,
        barrio_11.nombre as nombre_11,
        carga_archivo_13.codigo as codigo_13
    from ficha_hogar
    left outer join censista censista_1 on censista_1.id = ficha_hogar.censista_externo
    left outer join usuario usuario_2 on usuario_2.id_usuario = ficha_hogar.censista_interno
    left outer join usuario usuario_3 on usuario_3.id_usuario = ficha_hogar.supervisor
    left outer join usuario usuario_4 on usuario_4.id_usuario = ficha_hogar.critico_codificador
    left outer join usuario usuario_5 on usuario_5.id_usuario = ficha_hogar.digitador
    inner join estado_ficha_hogar estado_ficha_hogar_6 on estado_ficha_hogar_6.numero = ficha_hogar.estado
    left outer join usuario usuario_7 on usuario_7.id_usuario = ficha_hogar.usuario_transicion
    inner join departamento departamento_8 on departamento_8.id = ficha_hogar.departamento
    inner join distrito distrito_9 on distrito_9.id = ficha_hogar.distrito
    inner join tipo_area tipo_area_10 on tipo_area_10.numero = ficha_hogar.tipo_area
    left outer join barrio barrio_11 on barrio_11.id = ficha_hogar.barrio
    left outer join carga_archivo carga_archivo_13 on carga_archivo_13.id = ficha_hogar.archivo
;
