create or replace function rol$propagar_vistas$100(x$rol number, x$usuario number, x$id number) return number is
    row1 vista_funcion%ROWTYPE;
    row2 vista_funcion_col%ROWTYPE;
    id_vista_funcion_nueva number;
    codigo_vista_funcion_nueva nvarchar2(2000);
begin
    for row1 in (
        select  vista_funcion.*
        from    vista_funcion, rol_vista_funcion
        where   rol_vista_funcion.id_rol = x$rol
        and     rol_vista_funcion.id_vista_funcion = vista_funcion.id
        and     rol_vista_funcion.id_vista_funcion not in (select id_vista_funcion_original from vista_funcion where propietario = x$usuario)
        order   by  vista_funcion.id
    )
    loop
        id_vista_funcion_nueva := util.bigintid();
        codigo_vista_funcion_nueva := cast(id_vista_funcion_nueva as nvarchar2);
        insert into vista_funcion
            (
            id,
            codigo,
            nombre,
            descripcion,
            funcion,
            propietario,
            valida,
            secuencia,
            id_vista_funcion_original
            )
        values
            (
            id_vista_funcion_nueva,
            codigo_vista_funcion_nueva,
            row1.nombre,
            row1.descripcion,
            row1.funcion,
            x$usuario,
            row1.valida,
            row1.secuencia,
            row1.id
            );
        for row2 in (
            select  vista_funcion_col.*
            from    vista_funcion_col
            where   vista = row1.id
            order   by id
        )
        loop
            insert into vista_funcion_col
                (
                id,
                vista,
                nombre,
                secuencia,
                columna,
                alias,
                etiqueta,
                agregacion,
                grupo,
                orden,
                visible,
                graficable,
                ancho_por_mil,
                pixeles
                )
            values
                (
                util.bigintid(),
                id_vista_funcion_nueva,
                row2.nombre,
                row2.secuencia,
                row2.columna,
                row2.alias,
                row2.etiqueta,
                row2.agregacion,
                row2.grupo,
                row2.orden,
                row2.visible,
                row2.graficable,
                row2.ancho_por_mil,
                row2.pixeles
                );
        end loop;
    end loop;
    /**/
    return 0;
end;
/
show errors

create or replace function rol$propagar_vistas$biz(x$super number, x$rol number) return number is
    v$ru rol_usuario%ROWTYPE;
    v$id number;
    v$ok number;
begin
    -- raise notice 'rol$propagar_vistas$biz(%, %)', x$super, x$rol;
    for v$ru in (select * from rol_usuario where id_rol = x$rol order by id_usuario)
    loop
        v$ok := rol$propagar_vistas$100(x$rol, v$ru.id_usuario, v$id);
    end loop;
    /**/
    return 0;
end;
/
show errors
