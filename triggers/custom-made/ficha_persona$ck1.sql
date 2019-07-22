create or replace function ficha_persona$ck1(x$row ficha_persona%ROWTYPE, x$check_event nvarchar2) return boolean is
    cursor x$cursor1 is
    select ficha_hogar_1.estado as estado_1
    from ficha_hogar ficha_hogar_1;
    x$record1         x$cursor1%ROWTYPE;
    v$boolean         boolean;
    v$integer         number := 0;
    v$varchar         nvarchar2(2000) := '';
    v$err             constant number := -20000; -- an integer in the range -20000..-20999
    v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$version_ficha   varchar2(20) := '';
begin --modificado SIAU 11885
--  raise notice 'ficha_persona$ck1(%, %)', x$row, x$check_event;
--  record x$record1
    Begin
      Select valor Into v$version_ficha From variable_global where numero=103;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
    End;
    if x$row.VERSION_FICHA_HOGAR<>v$version_ficha then --si la ficha es diferente a la actual (historicos) no validamos
      return true;
    end if;
    begin
        select
        ficha_hogar_1.estado as estado_1
        into x$record1
        from ficha_hogar ficha_hogar_1
        where ficha_hogar_1.id = x$row.ficha_hogar;
    exception
        when no_data_found then null;
    end;
--  expression check010, constraint ficha_persona_ck_001___
    /*if x$check_event = 'insert' then
        v$boolean := (x$record1.estado_1 = 1) or (x$record1.estado_1 = 3);
        if v$boolean is null or not v$boolean then
            v$integer := v$integer + 1;
            v$varchar := v$varchar || 'ficha_persona_ck_001___;';
        end if;
    end if;*/
--  expression check020, constraint ficha_persona_ck_002___
    v$boolean := not((x$row.numero_cedula is null) or (x$row.tipo_excepcion_cedula is not null)) or ((x$row.numero_cedula is null) and (x$row.tipo_excepcion_cedula is not null));
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'ficha_persona_ck_002___;';
    end if;
--  raise exception if any expression failed
    if v$integer > 0 then
        v$msg := v$integer || ';' || v$varchar;
        raise_application_error(v$err, v$msg, true);
    end if;

    return true;
end;
/
