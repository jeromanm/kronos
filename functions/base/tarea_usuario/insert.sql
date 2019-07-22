create or replace function tarea_usuario$insert(x$funcion number, x$id number, x$codigo nvarchar2, x$nombre nvarchar2, x$propietario number, x$segmento number)
return number is
    v$true  constant varchar2(5) := 'true';
    v$false constant varchar2(5) := 'false';
    v$pdq number(10);
    cursor c$fdc is
        select
            f.numero_tipo_funcion as tipo_funcion,
            d.id_clase_recurso as id_clase_recurso_valor,
            c.pagina_funcion as pagina_funcion,
            c.pagina_detalle as pagina_recurso
        from funcion f
        inner join dominio d on d.id_dominio = f.id_dominio
        inner join clase_recurso c on c.id_clase_recurso = d.id_clase_recurso;
    v$fdc c$fdc%ROWTYPE;
    v$big number(19);
    v$cts timestamp;
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$codigo nvarchar2(2000);
    v$nombre nvarchar2(2000);
begin
    if (x$funcion is null) then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('funcion'), 'id', x$funcion);
        raise_application_error(v$err, v$msg, true);
    end if;
    if (x$id is null) then
        begin
            select 1 into v$pdq from dual where exists (
                select 1 from tarea_usuario where condicion in (1,2) and funcion = x$funcion and id_recurso_valor is null
            );
            return 0;
        exception
            when no_data_found then null;
        end;
    else
        begin
            select 1 into v$pdq from dual where exists (
                select 1 from tarea_usuario where condicion in (1,2) and funcion = x$funcion and id_recurso_valor = x$id
            );
            return 0;
        exception
            when no_data_found then null;
        end;
    end if;
    begin
        select
            f.numero_tipo_funcion as tipo_funcion,
            d.id_clase_recurso as id_clase_recurso_valor,
            c.pagina_funcion as pagina_funcion,
            c.pagina_detalle as pagina_recurso
        into v$fdc
        from funcion f
        inner join dominio d on d.id_dominio = f.id_dominio
        inner join clase_recurso c on c.id_clase_recurso = d.id_clase_recurso
        where f.id_funcion = x$funcion;
    exception
        when no_data_found then
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('funcion'), 'id', x$funcion);
            raise_application_error(v$err, v$msg, true);
    end;
    /**/
    v$big := util.bigintid();
    v$cts := localtimestamp;
    v$codigo := x$codigo;
    v$nombre := x$nombre;
    if (x$id is not null) then
        if (v$codigo is null) then
            v$codigo := util.gettext('string.valor.recurso.sin.codigo');
        end if;
        if (v$nombre is null) then
            v$nombre := util.gettext('string.valor.recurso.sin.nombre');
        end if;
    end if;
    insert into tarea_usuario
        (
        id,
        tarea,
        destinatario,
        funcion,
        id_clase_recurso_valor,
        recurso_valor,
        id_recurso_valor,
        codigo_recurso_valor,
        nombre_recurso_valor,
        condicion,
        fecha_hora_condicion,
        fecha_hora_registro,
        pagina_funcion,
        pagina_recurso
        )
    select
        util.bigintid() as id,
        v$big as tarea,
        id_usuario as destinatario,
        x$funcion as funcion,
        v$fdc.id_clase_recurso_valor,
        x$id as recurso_valor,
        x$id as id_recurso_valor,
        v$codigo as codigo_recurso_valor,
        v$nombre as nombre_recurso_valor,
        2 as condicion,
        v$cts as fecha_hora_condicion,
        v$cts as fecha_hora_registro,
        v$fdc.pagina_funcion,
        v$fdc.pagina_recurso
    from usuario
    where id_usuario in (
        select ru.id_usuario
        from rol_usuario ru
        inner join (rol_funcion rf left outer join elemento_segmento es on es.id_conjunto_segmento = rf.id_conjunto_segmento)
        on rf.id_rol = ru.id_rol
        where rf.id_funcion = x$funcion and rf.es_tarea = v$true
        and (x$propietario is null or rf.es_acceso_personalizado = v$false or ru.id_usuario = x$propietario)
        and (x$segmento is null or rf.id_conjunto_segmento is null or es.id_segmento = x$segmento)
        union
        select ru.id_usuario
        from rol_usuario ru
        inner join usuario supervisado on supervisado.id_usuario_supervisor = ru.id_usuario
        inner join rol_funcion rf on rf.id_rol = ru.id_rol
        inner join funcion fn on fn.id_funcion = rf.id_funcion
        inner join conjunto_segmento cs on cs.id_conjunto_segmento = rf.id_conjunto_segmento
        where supervisado.id_usuario = x$propietario
        and (rf.id_funcion = x$funcion and rf.es_tarea = v$true)
        and (fn.es_supervisable = v$true)
        and (cs.nombre_clase_fabricador like '%FabricadorConjuntoUsuariosSupervisados%')
        union
        select x$propietario
        from funcion
        where id_funcion = x$funcion
        and es_protegida = v$false
        and (es_supervisable = v$true or (es_personalizable = v$true and es_segmentable = v$false))
        )
    order by 1;
    return 0;
end;
/
show errors

create or replace function tarea_usuario$insert$010(x$funcion number)
return number is
    v$id number(19);
    v$codigo nvarchar2(2000);
    v$nombre nvarchar2(2000);
    v$propietario number(19);
    v$segmento number(19);
begin
    return tarea_usuario$insert(x$funcion, v$id, v$codigo, v$nombre, v$propietario, v$segmento);
end;
/
show errors
