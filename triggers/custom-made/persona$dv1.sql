create or replace function persona$dv1(x$new persona%ROWTYPE) return persona%ROWTYPE is
    x$row persona%ROWTYPE;
    /*
    cursor x$cursor1 is
    select
    cedula_1.numero as numero_1,
    cedula_1.apellidos as apellidos_1,
    cedula_1.nombres as nombres_1,
    cedula_1.fech_nacim as fech_nacim_1,
    cedula_1.sexo as sexo_1,
    cedula_1.nacionalidad as nacionalidad_1,
    cedula_1.estado_civil as estado_civil_1,
    cedula_1.fech_impresion as fech_impresion_1
    from cedula cedula_1;
    x$record1 x$cursor1%ROWTYPE;
    */

    /*
    cursor x$cursor7 is
    select
    pais_7.codigo as codigo_7
    from pais pais_7;
    x$record7 x$cursor7%ROWTYPE;
    */

    /*
    cursor x$cursor8 is
    select
    cedula_8_1.numero as numero_8_1
    from persona persona_8
    left outer join cedula cedula_8_1 on cedula_8_1.id = persona_8.cedula;
    x$record8 x$cursor8%ROWTYPE;
    */

begin --modificado SIAU 11885
    x$row := x$new;
--  raise notice 'persona$dv1(%)', x$new;
--  record x$record1
    /*
    begin
        select
        cedula_1.numero as numero_1,
        cedula_1.apellidos as apellidos_1,
        cedula_1.nombres as nombres_1,
        cedula_1.fech_nacim as fech_nacim_1,
        cedula_1.sexo as sexo_1,
        cedula_1.nacionalidad as nacionalidad_1,
        cedula_1.estado_civil as estado_civil_1,
        cedula_1.fech_impresion as fech_impresion_1
        into x$record1
        from cedula cedula_1
        where cedula_1.id = x$row.cedula;
    exception
        when no_data_found then null;
    end;
    */

--  record x$record7
    /*
    begin
        select
        pais_7.codigo as codigo_7
        into x$record7
        from pais pais_7
        where pais_7.id = x$row.pais;
    exception
        when no_data_found then null;
    end;
    */

--  record x$record8
    /*
    begin
        select
        cedula_8_1.numero as numero_8_1
        into x$record8
        from persona persona_8
        left outer join cedula cedula_8_1 on cedula_8_1.id = persona_8.cedula
        where persona_8.id = x$row.pariente;
    exception
        when no_data_found then null;
    end;
    */

    if (x$row.version is null) then
        x$row.version := 0;
    end if;

    /*
    x$row.codigo := case when (x$record1.numero_1 is not null) then x$record1.numero_1 else (case when (x$row.cedula_no_identificacion is not null) then x$row.cedula_no_identificacion else (case when (x$row.carnet_militar is not null) then ('CM-' || x$row.carnet_militar) else (case when ((x$record7.codigo_7 is not null) and (x$row.extranjero is not null)) then (to_char(x$record7.codigo_7 || '-') || to_char(x$row.extranjero)) else (case when (x$row.pariente is not null) then ('CP-' || ((x$record8.numero_8_1 || '-') || to_char(x$row.id))) else ('CX-' || to_char(x$row.id)) end) end) end) end) end;
    */

    /*
    x$row.nombre := case when (x$row.cedula is not null) then ((x$record1.apellidos_1 || ', ') || x$record1.nombres_1) else ((x$row.apellidos || ', ') || x$row.nombres) end;
    */

    /*
    if (x$row.apellidos is null) then
        x$row.apellidos := case when (x$row.cedula is not null) then x$record1.apellidos_1 end;
    end if;
    */

    /*
    if (x$row.nombres is null) then
        x$row.nombres := case when (x$row.cedula is not null) then x$record1.nombres_1 end;
    end if;
    */

    /*
    if (x$row.fecha_nacimiento is null) then
        x$row.fecha_nacimiento := case when (x$row.cedula is not null) then x$record1.fech_nacim_1 end;
    end if;
    */

    /*
    if (x$row.sexo is null) then
        x$row.sexo := case when (x$row.cedula is not null) then x$record1.sexo_1 end;
    end if;
    */

    /*
    if (x$row.estado_civil is null) then
        x$row.estado_civil := case when (x$row.cedula is not null) then x$record1.estado_civil_1 end;
    end if;
    */

    /*
    if (x$row.paraguayo is null) then
        x$row.paraguayo := util.cast_boolean_as_varchar((x$row.cedula is null) or (x$record1.nacionalidad_1 = '226'));
    end if;
    */

    /*
    if (x$row.fecha_expedicion_cedula is null) then
        x$row.fecha_expedicion_cedula := case when (x$row.cedula is not null) then x$record1.fech_impresion_1 end;
    end if;
    */

    /*
    if (x$row.fecha_vencimiento_cedula is null) then
        x$row.fecha_vencimiento_cedula := case when (x$row.cedula is not null) then util_dateadd(x$record1.fech_impresion_1, 10, 'years') end;
    end if;
    */

    if (x$row.indigena is null) then
        x$row.indigena := 'false';
    end if;

    if (x$row.sello_registro is null) then
        x$row.sello_registro := 'true';
    end if;

    if (x$row.monitoreado is null) then
        x$row.monitoreado := 'false';
    end if;
    
    if (x$row.monitoreo_sorteo is null) then
        x$row.monitoreo_sorteo := 'false';
    end if;

    if (x$row.sello is null) then
        x$row.sello := 'true';
    end if;

    if (x$row.objecion_menor is null) then
        x$row.objecion_menor := 'false';
    end if;

    if (x$row.edicion_restringida is null) then
        x$row.edicion_restringida := 'true';
    end if;

    return x$row;
end;
/
