create or replace function persona$anu_act_matr$93025$biz(x$super number, x$persona number, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid raw(8);
    v$log rastro_proceso_temporal%ROWTYPE;
begin
--
--  Persona.anularActaMatrimonio - business logic
--
    update persona
       set observac_anular_matrimon_43115 = x$observaciones, 
           certificado_matrimonio = null,
           oficina_matrimonio = null,
           fecha_acta_matrimonio = null, 
           tomo_matrimonio = null,
           folio_matrimonio = null,
           acta_matrimonio = null, 
           cedula_conyuge = null,
           nombre_conyuge = null,
           fecha_matrimonio = null, 
           fecha_certificado_matrimonio = null
      --     numero_sime = null
    where id = x$persona;
    delete from matrimonio where persona = x$persona;

    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
