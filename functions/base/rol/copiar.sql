create or replace function rol$copiar$biz(x$super number, x$rol number, x$codigo nvarchar2, x$nombre nvarchar2) return number is
    row_rol rol%ROWTYPE;
    row_rol_funcion rol_funcion%ROWTYPE;
    row_rol_funcion_par rol_funcion_par%ROWTYPE;
    id_rol_nuevo number(19);
    id_rol_funcion_nuevo number(19);
    id_rol_funcion_par_nuevo number(19);
    codigo_rol_nuevo nvarchar2(100);
    nombre_rol_nuevo nvarchar2(100);
    descripcion_rol_nueva nvarchar2(2000);
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$cef constant enums.condicion_eje_fun := condicion_eje_fun$enum();
    v$log rastro_proceso_temporal%ROWTYPE;
begin
    -- raise notice 'rol$copiar$biz(%, %, %, %)', x$super, x$rol, x$codigo, x$nombre;
    v$log := rastro_proceso_temporal$select();
    begin
        select * into row_rol from rol where id_rol = x$rol;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'rol', 'id', x$rol);
            raise_application_error(v$err, v$msg, true);
    end;
    /**/
    id_rol_nuevo := util.bigintid();
    /**/
    if x$codigo is not null then
        codigo_rol_nuevo := substr(x$codigo, 1, 100);
    else
        codigo_rol_nuevo := substr(row_rol.codigo_rol, 1, 80) || substr(id_rol_nuevo, 1, 20);
    end if;
    /**/
    if x$nombre is not null then
        nombre_rol_nuevo := substr(x$nombre, 1, 100);
    else
        nombre_rol_nuevo := row_rol.nombre_rol;
    end if;
    /**/
    descripcion_rol_nueva := util.format(util.gettext('Copia de %s'), row_rol.codigo_rol, row_rol.nombre_rol);
    insert into rol (id_rol, codigo_rol, nombre_rol, descripcion_rol)
    values (id_rol_nuevo, codigo_rol_nuevo, nombre_rol_nuevo, descripcion_rol_nueva);
    /**/
    for row_rol_funcion in (select * from rol_funcion where id_rol = x$rol order by id_rol_funcion)
    loop
        id_rol_funcion_nuevo := util.bigintid();
        insert into rol_funcion (id_rol_funcion, version_rol_funcion, id_rol, id_funcion, id_conjunto_segmento, es_acceso_personalizado, es_tarea)
        values (id_rol_funcion_nuevo, -1, id_rol_nuevo, row_rol_funcion.id_funcion, row_rol_funcion.id_conjunto_segmento,
                row_rol_funcion.es_acceso_personalizado, row_rol_funcion.es_tarea);
        insert into rol_funcion_par (id_rol_funcion_par, id_rol_funcion, id_funcion_parametro)
        select util.bigintid(), id_rol_funcion_nuevo, id_funcion_parametro
        from rol_funcion_par
        where id_rol_funcion = row_rol_funcion.id_rol_funcion
        order by id_rol_funcion_par;
    end loop;
    /**/
    insert into rol_filtro_funcion (id_rol_filtro_funcion, id_rol, id_filtro_funcion)
    select util.bigintid(), id_rol_nuevo, id_filtro_funcion
    from rol_filtro_funcion
    where id_rol = x$rol
    order by id_rol_filtro_funcion;
    /**/
    insert into rol_pagina (id_rol_pagina, id_rol, id_pagina)
    select util.bigintid(), id_rol_nuevo, id_pagina
    from rol_pagina
    where id_rol = x$rol
    order by id_rol_pagina;
    /**/
    v$msg := util.format(util.gettext('rol %s copiado como %s'), row_rol.codigo_rol, codigo_rol_nuevo);
    return rastro_proceso_temporal$update(v$cef.EJECUTADO_SIN_ERRORES, v$log.nombre_archivo, v$msg);
end;
/
show errors
