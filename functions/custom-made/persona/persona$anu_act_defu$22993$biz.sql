create or replace function persona$anu_act_defu$22993$biz(x$super         number,
                                                          x$persona       number,
                                                          x$observaciones nvarchar2)
  return number is
  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg   nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xid   raw(8);
  v$log   rastro_proceso_temporal%ROWTYPE;
  err_num NUMBER;
  err_msg VARCHAR2(255);
begin
  update persona
     set observaciones_anular_defuncion = x$observaciones,
         certificado_defuncion          = null,
         oficina_defuncion              = null,
         fecha_acta_defuncion           = null,
         tomo_defuncion                 = null,
         folio_defuncion                = null,
         acta_defuncion                 = null,
         fecha_defuncion                = null,
         fecha_certificado_defuncion    = null
      --   numero_sime                    = null
   where id = x$persona;
  delete from defuncion where persona = x$persona;

  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'),
                         'persona',
                         'id',
                         x$persona);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
  when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(err_num, err_msg, true);
end;
/
