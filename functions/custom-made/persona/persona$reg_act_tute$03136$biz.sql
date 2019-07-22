create or replace function persona$reg_act_tute$03136$biz(x$super number, x$persona number,
                                                          x$cedula_representante  number,
                                                          x$fecha_otorgamiento date,
														  x$cedula_curador  number,
                                                          x$nombre_juzgado nvarchar2,
                                                          x$fecha_sentencia date,
                                                          x$numero_sentencia number,
                                                          x$sello_registro varchar2,
                                                          x$numero_sime_tutelaje number) return number is
   v$err constant number := -20000; -- an integer in the range -20000..-20999
   v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
   v$xid          raw(8);
   v$log          rastro_proceso_temporal%ROWTYPE;
   v_id_tutelaje number;
   err_num          NUMBER;
   err_msg          VARCHAR2(255); 

begin
--
    update persona
     set cedula_representante_identif  = x$cedula_representante,
	       cedula_representante          = null,
         nombre_representante          = null,
         fecha_otorgamiento            = x$fecha_otorgamiento,
         cedula_curador_identif        = x$cedula_curador,
         cedula_curador                = null,
         nombre_curador                = null,
         nombre_juzgado                = x$nombre_juzgado,
         fecha_sentencia               = x$fecha_sentencia,
         numero_sentencia              = x$numero_sentencia,
         sello_registro                = x$sello_registro,
         numero_sime_tutelaje          = x$numero_sime_tutelaje,
         observaciones_anular_tutelaje = null
   where id = x$persona;

    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
