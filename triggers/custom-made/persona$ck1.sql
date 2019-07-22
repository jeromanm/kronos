create or replace function persona$ck1(x$row persona%ROWTYPE, x$check_event nvarchar2) return boolean is
    cursor x$cursor12 is
    select
    distrito_12.departamento as departamento_12
    from distrito distrito_12;
    x$record12 x$cursor12%ROWTYPE;

    cursor x$cursor14 is
    select
    barrio_14.distrito as distrito_14,
    barrio_14.tipo_area as tipo_area_14
    from barrio barrio_14;
    x$record14 x$cursor14%ROWTYPE;

    cursor x$cursor5 is
    select
    comunidad_indigena_5.etnia as etnia_5
    from comunidad_indigena comunidad_indigena_5;
    x$record5 x$cursor5%ROWTYPE;

    cursor x$cursor8 is
    select
    persona_8.cedula as cedula_8,
    persona_8.fecha_nacimiento as fecha_nacimiento_8,
    persona_8.sexo as sexo_8
    from persona persona_8;
    x$record8 x$cursor8%ROWTYPE;

    v$boolean boolean;
    v$integer number := 0;
    v$varchar nvarchar2(2000) := '';
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin --modificado SIAU 11885
--  raise notice 'persona$ck1(%, %)', x$row, x$check_event;
--  record x$record12
    begin
        select
        distrito_12.departamento as departamento_12
        into x$record12
        from distrito distrito_12
        where distrito_12.id = x$row.distrito;
    exception
        when no_data_found then null;
    end;
--  record x$record14
    begin
        select
        barrio_14.distrito as distrito_14,
        barrio_14.tipo_area as tipo_area_14
        into x$record14
        from barrio barrio_14
        where barrio_14.id = x$row.barrio;
    exception
        when no_data_found then null;
    end;
--  record x$record5
    begin
        select
        comunidad_indigena_5.etnia as etnia_5
        into x$record5
        from comunidad_indigena comunidad_indigena_5
        where comunidad_indigena_5.id = x$row.comunidad;
    exception
        when no_data_found then null;
    end;
--  record x$record8
    begin
        select
        persona_8.cedula as cedula_8,
        persona_8.fecha_nacimiento as fecha_nacimiento_8,
        persona_8.sexo as sexo_8
        into x$record8
        from persona persona_8
        where persona_8.id = x$row.pariente;
    exception
        when no_data_found then null;
    end;
--  expression check101, constraint persona_ck_001___
    v$boolean := not((x$row.indigena = 'true') or (x$row.etnia is not null)) or ((x$row.indigena = 'true') and (x$row.etnia is not null));
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_001___;';
    end if;
--  expression check102, constraint persona_ck_002___
    v$boolean := not(x$row.comunidad is not null) or (x$row.indigena = 'true');
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_002___;';
    end if;
--  expression check103, constraint persona_ck_003___
    v$boolean := not(x$row.comunidad is not null) or (x$record5.etnia_5 = x$row.etnia);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_003___;';
    end if;
--  expression check111, constraint persona_ck_004___
    v$boolean := not(x$row.cedula is null) or ((((x$row.carnet_militar is not null) or (x$row.cedula_no_identificacion is not null)) or (x$row.extranjero is not null)) or (x$row.pariente is not null));
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_004___;';
    end if;
--  expression check112, constraint persona_ck_005___
    v$boolean := not(x$row.pariente is not null) or (x$record8.cedula_8 is not null);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_005___;';
    end if;
--  expression check113, constraint persona_ck_006___
    v$boolean := not((x$row.pariente is not null) or (x$row.parentesco is not null)) or ((x$row.pariente is not null) and (x$row.parentesco is not null));
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_006___;';
    end if;
--  expression check114, constraint persona_ck_007___
    v$boolean := not((x$row.pais is not null) or (x$row.extranjero is not null)) or ((x$row.pais is not null) and (x$row.extranjero is not null));
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_007___;';
    end if;
--  expression check121, constraint persona_ck_008___
    v$boolean := (x$row.id is null) or (x$row.pariente is null or x$row.pariente <> x$row.id);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_008___;';
    end if;
--  expression check122, constraint persona_ck_009___
    v$boolean := not((((x$row.pariente is not null) and (x$row.parentesco is not null) and (x$row.parentesco = 1)))) or (x$row.sexo <> x$record8.sexo_8);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_009___;';
    end if;
--  expression check123, constraint persona_ck_010___
    v$boolean := not((((x$row.pariente is not null) and (x$row.parentesco is not null) and (x$row.parentesco = 2)))) or (x$row.fecha_nacimiento < x$record8.fecha_nacimiento_8);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_010___;';
    end if;
--  expression check124, constraint persona_ck_011___
    v$boolean := not((((x$row.pariente is not null) and (x$row.parentesco is not null) and (x$row.parentesco = 3)))) or (x$record8.sexo_8 = 6);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_011___;';
    end if;
--  expression check125, constraint persona_ck_012___
    v$boolean := not((((x$row.pariente is not null) and (x$row.parentesco is not null) and (x$row.parentesco = 3)))) or (x$row.fecha_nacimiento > x$record8.fecha_nacimiento_8);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_012___;';
    end if;
--  expression check126, constraint persona_ck_013___
    v$boolean := not((((x$row.pariente is not null) and (x$row.parentesco is not null) and (x$row.parentesco = 4)))) or (x$record8.sexo_8 = 1);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_013___;';
    end if;
--  expression check127, constraint persona_ck_014___
    v$boolean := not((((x$row.pariente is not null) and (x$row.parentesco is not null) and (x$row.parentesco = 4)))) or (x$row.fecha_nacimiento > x$record8.fecha_nacimiento_8);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'persona_ck_014___;';
    end if;
--  expression check201, constraint persona_ck_015___
    v$boolean := not(x$row.distrito is not null) or (x$record12.departamento_12 = x$row.departamento);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || ' departamento del distrito no corresponde al departamento de la persona cédula:' || x$row.codigo;
    end if;
--  expression check202, constraint persona_ck_016___
    v$boolean := not(x$row.barrio is not null) or (x$record14.distrito_14 = x$row.distrito);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || ' distrito del barrio no corresponde al distrito de la persona cédula:' || x$row.codigo;
    end if;
--  expression check203, constraint persona_ck_017___
    v$boolean := not(x$row.barrio is not null) or (x$record14.tipo_area_14 = x$row.tipo_area);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'tipo area no corresponde'; --'persona_ck_017___;';
    end if;
--  raise exception if any expression failed
    if v$integer > 0 then
        v$msg := v$integer || ';' || v$varchar;
        raise_application_error(v$err, v$msg, true);
    end if;

    return true;
end;
/