create or replace function ficha_hogar$ck1(x$row ficha_hogar%ROWTYPE, x$check_event nvarchar2) return boolean is
    cursor x$cursor11 is
    select
    barrio_11.distrito as distrito_11,
    barrio_11.tipo_area as tipo_area_11
    from barrio barrio_11;
    x$record11 x$cursor11%ROWTYPE;

    cursor x$cursor9 is
    select
    distrito_9.departamento as departamento_9
    from distrito distrito_9;
    x$record9 x$cursor9%ROWTYPE;

    v$boolean boolean;
    v$integer number := 0;
    v$varchar nvarchar2(2000) := '';
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$version_ficha varchar2(20) := '';
begin --modificado SIAU 11885
--  raise notice 'ficha_hogar$ck1(%, %)', x$row, x$check_event;
--  record x$record11
    Begin
      Select valor Into v$version_ficha From variable_global where numero=103;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
    End;
    if x$row.VERSION_FICHA_HOGAR<>v$version_ficha then  --si la ficha es diferente a la actual (historicos) no validamos
      return true;
    end if;
    begin
        select
        barrio_11.distrito as distrito_11,
        barrio_11.tipo_area as tipo_area_11
        into x$record11
        from barrio barrio_11
        where barrio_11.id = x$row.barrio;
    exception
        when no_data_found then null;
    end;
--  record x$record9
    begin
        select
        distrito_9.departamento as departamento_9
        into x$record9
        from distrito distrito_9
        where distrito_9.id = x$row.distrito;
    exception
        when no_data_found then null;
    end;
--  expression check101, constraint ficha_hogar_ck_001___
    v$boolean := not((x$row.censista_externo is not null) and (x$row.censista_interno is not null));
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || ' falta censista interno'; --'ficha_hogar_ck_001___;';
    end if;
--  expression check201, constraint ficha_hogar_ck_002___
    v$boolean := not(x$row.distrito is not null) or (x$record9.departamento_9 = x$row.departamento);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || ' distrito no pertenece a departamento ';  --'ficha_hogar_ck_002___;';
    end if;
--  expression check202, constraint ficha_hogar_ck_003___
    v$boolean := not(x$row.barrio is not null) or (x$record11.distrito_11 = x$row.distrito);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || ' barrio no pertenece a distrito '; --'ficha_hogar_ck_003___;';
    end if;
--  expression check203, constraint ficha_hogar_ck_004___
    v$boolean := not(x$row.barrio is not null) or (x$record11.tipo_area_11 = x$row.tipo_area);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || ' el tipo de area no corresponde al tipo de area del barrio '; --'ficha_hogar_ck_004___;';
    end if;
--  raise exception if any expression failed
    if v$integer > 0 then
        v$msg := v$integer || ';' || v$varchar;
        raise_application_error(v$err, v$msg, true);
    end if;

    return true;
end;
/