create or replace function persona$anular_catastro$biz(x$super number, x$persona number, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid raw(8);
    v$log rastro_proceso_temporal%ROWTYPE;
begin
--
--  Persona.anularCatastro - business logic
--
    update persona 
       set observaciones_anular_catastro = x$observaciones,
           monto = null,
           fecha_ingreso_catastro = null, 
           fecha_egreso_catastro = null, 
           tipo_catastro = null,
           cantidad_inmueble = null
         --  numero_sime = null
    where id = x$persona;
    delete from catastro where persona = x$persona;

    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
