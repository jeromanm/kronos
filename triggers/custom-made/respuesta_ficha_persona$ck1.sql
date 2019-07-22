create or replace function respuesta_ficha_persona$ck1(x$row respuesta_ficha_persona%ROWTYPE, x$check_event nvarchar2) return boolean is
    cursor x$cursor1 is
    select
    ficha_hogar_1_1.estado as estado_1_1
    from ficha_persona ficha_persona_1
    left outer join ficha_hogar ficha_hogar_1_1 on ficha_hogar_1_1.id = ficha_persona_1.ficha_hogar;
    x$record1 x$cursor1%ROWTYPE;

    cursor x$cursor2 is
    select
    pregunta_ficha_persona_2.tipo_dato_respuesta as tipo_dato_respuesta_2
    from pregunta_ficha_persona pregunta_ficha_persona_2;
    x$record2 x$cursor2%ROWTYPE;

    cursor x$cursor3 is
    select
    rango_ficha_persona_3.pregunta as pregunta_3
    from rango_ficha_persona rango_ficha_persona_3;
    x$record3 x$cursor3%ROWTYPE;

    v$boolean boolean;
    v$integer number := 0;
    v$varchar nvarchar2(2000) := '';
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
--  raise notice 'respuesta_ficha_persona$ck1(%, %)', x$row, x$check_event;
--  record x$record1
    begin
        select
        ficha_hogar_1_1.estado as estado_1_1
        into x$record1
        from ficha_persona ficha_persona_1
        left outer join ficha_hogar ficha_hogar_1_1 on ficha_hogar_1_1.id = ficha_persona_1.ficha_hogar
        where ficha_persona_1.id = x$row.ficha;
    exception
        when no_data_found then null;
    end;
--  record x$record2
    begin
        select
        pregunta_ficha_persona_2.tipo_dato_respuesta as tipo_dato_respuesta_2
        into x$record2
        from pregunta_ficha_persona pregunta_ficha_persona_2
        where pregunta_ficha_persona_2.id = x$row.pregunta;
    exception
        when no_data_found then null;
    end;
--  record x$record3
    begin
        select
        rango_ficha_persona_3.pregunta as pregunta_3
        into x$record3
        from rango_ficha_persona rango_ficha_persona_3
        where rango_ficha_persona_3.id = x$row.rango;
    exception
        when no_data_found then null;
    end;
--  expression check010, constraint resp_fich_pers_32345_ck_001___
    /*if x$check_event = 'insert' then
        v$boolean := (x$record1.estado_1_1 = 1) or (x$record1.estado_1_1 = 3);
        if v$boolean is null or not v$boolean then
            v$integer := v$integer + 1;
            v$varchar := v$varchar || 'resp_fich_pers_32345_ck_001___;';
        end if;
    end if;*/
--  expression check101, constraint resp_fich_pers_32345_ck_002___
    v$boolean := not(x$row.texto is not null) or (x$record2.tipo_dato_respuesta_2 = 1);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'resp_fich_pers_32345_ck_002___;';
    end if;
--  expression check102, constraint resp_fich_pers_32345_ck_003___
    v$boolean := not(x$row.numero is not null) or (x$record2.tipo_dato_respuesta_2 = 2);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'resp_fich_pers_32345_ck_003___;';
    end if;
--  expression check103, constraint resp_fich_pers_32345_ck_004___
    v$boolean := not(x$row.fecha is not null) or (x$record2.tipo_dato_respuesta_2 = 3);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'resp_fich_pers_32345_ck_004___;';
    end if;
--  expression check104, constraint resp_fich_pers_32345_ck_005___
    v$boolean := not(x$row.rango is not null) or (x$record2.tipo_dato_respuesta_2 = 4);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'resp_fich_pers_32345_ck_005___;';
    end if;
--  expression check105, constraint resp_fich_pers_32345_ck_006___
    v$boolean := not(x$row.rango is not null) or (x$record3.pregunta_3 = x$row.pregunta);
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'resp_fich_pers_32345_ck_006___;';
    end if;
--  expression check110, constraint resp_fich_pers_32345_ck_007___
    v$boolean := (not(((x$row.texto is not null) or (x$row.numero is not null) or (x$row.fecha is not null) or (x$row.rango is not null))) or (((x$row.texto is not null) or (x$row.numero is not null) or (x$row.fecha is not null) or (x$row.rango is not null)) and not((((x$row.texto is not null) and (x$row.numero is not null)) or ((x$row.texto is not null) and (x$row.fecha is not null)) or ((x$row.texto is not null) and (x$row.rango is not null)) or ((x$row.numero is not null) and (x$row.fecha is not null)) or ((x$row.numero is not null) and (x$row.rango is not null)) or ((x$row.fecha is not null) and (x$row.rango is not null))))));
    if v$boolean is null or not v$boolean then
        v$integer := v$integer + 1;
        v$varchar := v$varchar || 'resp_fich_pers_32345_ck_007___;';
    end if;
--  raise exception if any expression failed
    if v$integer > 0 then
        v$msg := v$integer || ';' || v$varchar;
        raise_application_error(v$err, v$msg, true);
    end if;

    return true;
end;
/
