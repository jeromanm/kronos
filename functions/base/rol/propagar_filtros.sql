create or replace function rol$propagar_filtros$100(x$rol number, x$usuario number, x$id number) return number is
    row1 filtro_funcion%ROWTYPE;
    row2 filtro_funcion_par%ROWTYPE;
    id_filtro_funcion_nuevo number;
    codigo_filtro_funcion_nuevo nvarchar2(2000);
begin
    for row1 in (
        select  filtro_funcion.*
        from    filtro_funcion filtro_funcion, rol_filtro_funcion rol_filtro_funcion
        where   rol_filtro_funcion.id_rol = x$rol
        and     rol_filtro_funcion.id_filtro_funcion = filtro_funcion.id_filtro_funcion
        and     rol_filtro_funcion.id_filtro_funcion not in (select id_filtro_funcion_original from filtro_funcion where id_usuario = x$usuario)
        order   by  filtro_funcion.id_filtro_funcion
    )
    loop
        id_filtro_funcion_nuevo := util.bigintid();
        codigo_filtro_funcion_nuevo := cast(id_filtro_funcion_nuevo as nvarchar2);
        insert into filtro_funcion
            (
            id_filtro_funcion,
            codigo_filtro_funcion,
            nombre_filtro_funcion,
            descripcion_filtro_funcion,
            id_funcion,
            id_usuario,
            id_filtro_funcion_original
            )
        values
            (
            id_filtro_funcion_nuevo,
            codigo_filtro_funcion_nuevo,
            row1.nombre_filtro_funcion,
            row1.descripcion_filtro_funcion,
            row1.id_funcion,
            x$usuario,
            row1.id_filtro_funcion
            );
        for row2 in (
            select  filtro_funcion_par.*
            from    filtro_funcion_par
            where   id_filtro_funcion = row1.id_filtro_funcion
            order   by id_filtro_funcion_par
        )
        loop
            insert into filtro_funcion_par
                (
                id_filtro_funcion_par,
                id_filtro_funcion,
                id_funcion_parametro,
                numero_operador_com,
                valor,
                valor_fecha_hora,
                pagina_recurso,
                id_clase_recurso_valor,
                recurso_valor,
                id_recurso_valor,
                codigo_recurso_valor,
                nombre_recurso_valor
                )
            values
                (
                util.bigintid(),
                id_filtro_funcion_nuevo,
                row2.id_funcion_parametro,
                row2.numero_operador_com,
                row2.valor,
                row2.valor_fecha_hora,
                row2.pagina_recurso,
                row2.id_clase_recurso_valor,
                row2.recurso_valor,
                row2.id_recurso_valor,
                row2.codigo_recurso_valor,
                row2.nombre_recurso_valor
                );
        end loop;
    end loop;
    /**/
    return 0;
end;
/
show errors

create or replace function rol$propagar_filtros$biz(x$super number, x$rol number) return number is
    v$ru rol_usuario%ROWTYPE;
    v$id number;
    v$ok number;
begin
    -- raise notice 'rol$propagar_filtros$biz(%, %)', x$super, x$rol;
    for v$ru in (select * from rol_usuario where id_rol = x$rol order by id_usuario)
    loop
        v$ok := rol$propagar_filtros$100(x$rol, v$ru.id_usuario, v$id);
    end loop;
    /**/
    return 0;
end;
/
show errors
