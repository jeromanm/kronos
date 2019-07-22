create or replace function rol$modificar_conjunto$biz(x$super number, x$rol number, x$conjunto_segmento number, x$solo_segmentadas varchar2) return number is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
    row_rol rol%ROWTYPE;
    row_conjunto_segmento conjunto_segmento%ROWTYPE;
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$cef constant enums.condicion_eje_fun := condicion_eje_fun$enum();
    v$log rastro_proceso_temporal%ROWTYPE;
begin
    -- raise notice 'rol$modificar_conjunto$biz(%, %, %, %)', x$super, x$rol, x$conjunto_segmento, x$solo_segmentadas;
    v$log := rastro_proceso_temporal$select();
    begin
        select * into row_rol from rol where id_rol = x$rol;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rol', 'id', x$rol);
            raise_application_error(v$err, v$msg, true);
    end;
    /**/
    begin
        select * into row_conjunto_segmento from conjunto_segmento where id_conjunto_segmento = x$conjunto_segmento;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'conjunto de segmentos', 'id', x$conjunto_segmento);
            raise_application_error(v$err, v$msg, true);
    end;
    if x$solo_segmentadas = v$true then
        v$msg := util.gettext('se modificaron solo las funciones del rol %s que ya estaban segmentadas con un conjunto de la misma clase del conjunto de segmentos especificado');
        update	rol_funcion
        set	id_conjunto_segmento = x$conjunto_segmento
        where	id_rol = x$rol
        and	id_conjunto_segmento in
                (
                select	id_conjunto_segmento
                from	conjunto_segmento
                where	id_clase_recurso = row_conjunto_segmento.id_clase_recurso
                )
        and	id_conjunto_segmento <> x$conjunto_segmento;
    else
        v$msg := util.gettext('se modificaron todas las funciones del rol %s que podian ser segmentadas utilizando el conjunto de segmentos especificado');
        update	rol_funcion
        set	id_conjunto_segmento = x$conjunto_segmento
        where	id_rol = x$rol
        and	id_funcion in
                (
                select	id_funcion
                from	funcion funcion
                join    dominio dominio on dominio.id_dominio = funcion.id_dominio
                join    clase_recurso clase_recurso on clase_recurso.id_clase_recurso = dominio.id_clase_recurso
                where	funcion.es_segmentable = v$true
                and	clase_recurso.id_clase_recurso_segmento = row_conjunto_segmento.id_clase_recurso
                )
        and	(id_conjunto_segmento is null or id_conjunto_segmento <> x$conjunto_segmento);
    end if;
    /**/
    v$msg := util.format(v$msg, row_rol.codigo_rol);
    return rastro_proceso_temporal$update(v$cef.EJECUTADO_SIN_ERRORES, v$log.nombre_archivo, v$msg);
end;
/
show errors
