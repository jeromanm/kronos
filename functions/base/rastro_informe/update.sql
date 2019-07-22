create or replace function rastro_informe$update(rastro number, condicion number, archivo nvarchar2, mensaje nvarchar2, filas number) return number is
    ts timestamp := NULL;
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    if (rastro is not null and rastro > 0) then
	if (condicion > 12) then
        ts := localtimestamp;
	end if;
	/**/
    v$msg := substr(mensaje, 1, 2000);
	update	rastro_informe
	set     fecha_hora_fin_ejecucion = ts,
            numero_condicion_eje_fun = condicion,
            nombre_archivo = archivo,
            descripcion_error = v$msg,
            filas_seleccionadas = filas
	where	id_rastro_informe = rastro
	and     numero_condicion_eje_fun < condicion;
	/**/
	if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s, o no se puede colocar en condicion %s'), util.gettext('informe'), 'id', rastro, condicion);
        raise_application_error(v$err, v$msg, true);
	end if;
	/**/
    end if;
    return 0;
end;
/
show errors

create or replace function rastro_informe$update$010(rastro number, condicion number, archivo nvarchar2, mensaje nvarchar2) return number is
    ts timestamp := NULL;
    v$err constant number := -20000; -- an number in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
begin
    if (rastro is not null and rastro > 0) then
	if (condicion > 12) then
        ts := localtimestamp;
	end if;
	/**/
    v$msg := substr(mensaje, 1, 2000);
	update	rastro_informe
	set     fecha_hora_fin_ejecucion = ts,
            numero_condicion_eje_fun = condicion,
            nombre_archivo = archivo,
            descripcion_error = v$msg
	where	id_rastro_informe = rastro
	and     numero_condicion_eje_fun < condicion;
	/**/
	if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s, o no se puede colocar en condicion %s'), util.gettext('informe'), 'id', rastro, condicion);
        raise_application_error(v$err, v$msg, true);
	end if;
	/**/
    end if;
    return 0;
end;
/
show errors
