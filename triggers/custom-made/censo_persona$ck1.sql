create or replace function censo_persona$ck1(x$row censo_persona%ROWTYPE, x$check_event nvarchar2) return boolean is
    cursor x$cursor1 is
    select persona_1.fecha_defuncion as fecha_defuncion_1
    from persona persona_1;
    x$record1               x$cursor1%ROWTYPE;
    v$boolean               boolean;
    v$integer               number := 0;
    v$varchar               nvarchar2(2000) := '';
    v$version_ficha_persona varchar2(20) := '';
    v$version_ficha         varchar2(20) := '';
    v$err                   constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                   nvarchar2(2000); -- a character string of at most 2048 bytes?
begin --modificado SIAU 11885
--  raise notice 'censo_persona$ck1(%, %)', x$row, x$check_event;
--  record x$record1
    begin
      Select version_ficha_hogar into v$version_ficha_persona From ficha_persona Where id = x$row.ficha;
    exception
    when no_data_found then 
      v$version_ficha_persona:=null;
    when others then
      v$version_ficha_persona:=null;
    end;
    Begin
      Select valor Into v$version_ficha From variable_global where numero=103;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
    End;
    if v$version_ficha_persona<>v$version_ficha then  --si la ficha es diferente a la actual (historicos) no validamos
      return true;
    end if;
    begin
        select
        persona_1.fecha_defuncion as fecha_defuncion_1
        into x$record1
        from persona persona_1
        where persona_1.id = x$row.persona;
    exception
        when no_data_found then null;
    end;
--  expression check010, constraint censo_persona_ck_001___
    if x$check_event = 'insert' then
        v$boolean := x$record1.fecha_defuncion_1 is null;
        if v$boolean is null or not v$boolean then
            v$integer := v$integer + 1;
            v$varchar := v$varchar || ' persona fallecida '; --'censo_persona_ck_001___;';
        end if;
    end if;
--  raise exception if any expression failed
    if v$integer > 0 then
        v$msg := v$integer || ';' || v$varchar;
        raise_application_error(v$err, v$msg, true);
    end if;

    return true;
end;
/