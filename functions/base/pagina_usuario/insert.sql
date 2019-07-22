create or replace function pagina_usuario$insert(x$codigo_aplicacion nvarchar2, x$codigo_pagina nvarchar2, x$id_usuario number) return number is
    row_pagina pagina%ROWTYPE;
    row_pagina_usuario pagina_usuario%ROWTYPE;
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    begin
        select  *
        into    row_pagina
        from    pagina
        where   codigo_pagina = x$codigo_pagina;
    exception
        when no_data_found then
--          raise exception 'la pagina "%" no existe', x$codigo_pagina;
            v$msg := util.format(util.gettext('no existe %s con %s = %s'), util.gettext('pagina'), 'id', x$codigo_pagina);
            raise_application_error(v$err, v$msg, true);
    end;
    if (row_pagina.nombre_pagina is not null and row_pagina.url_pagina is not null)
    and (row_pagina.numero_tipo_pagina = 4 or (row_pagina.numero_tipo_pagina in (1,3,5,7) and row_pagina.id_dominio_maestro is null)) then
        begin
            select  *
            into    row_pagina_usuario
            from    pagina_usuario
            where   id_pagina = row_pagina.id_pagina
            and     id_usuario = x$id_usuario;
            /**/
            return  row_pagina_usuario.id_pagina_usuario;
        exception
            when no_data_found then null;
        end;
    else
--      raise exception 'esta pagina no puede agregarse a su lista de favoritos';
        v$msg := util.gettext('esta pagina no puede agregarse a su lista de favoritos');
        raise_application_error(v$err, v$msg, true);
    end if;
    row_pagina_usuario.id_pagina_usuario := util.bigintid();
    row_pagina_usuario.version_pagina_usuario := 0;
    row_pagina_usuario.id_pagina := row_pagina.id_pagina;
    row_pagina_usuario.id_usuario := x$id_usuario;
    insert into pagina_usuario values row_pagina_usuario;
    return row_pagina_usuario.id_pagina_usuario;
end;
/
show errors
