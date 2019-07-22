create or replace function pension$reg_res_sent$33372$biz(x$super number, x$pension number, x$resolucion nvarchar2, x$fecha date, x$resumen nvarchar2) return number is
        v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg               varchar2(200);
    x$tiporeclamo	        number;
    x$edopension          number;
    x$edoreclamo          number;
    v$estado_inicial      number;
    v$estado_final        number;
    v$inserta_transicion  number;
	-- registrar resolucion cumplimiento sentencia
begin 
    begin
      Select pn.estado as edopension, rp.estado as edoreclamo
         	into x$edopension, x$edoreclamo
      From pension pn inner join reclamo_pension rp on pn.id = rp.pension
         where pn.id=x$pension And rp.tipo<>4;
    Exception
	  WHEN NO_DATA_FOUND THEN
      v$msg := util.format(util.gettext('Error: no se consigue %s de la %s'), 'reclamo denegado', 'pensión');
      raise_application_error(v$err, v$msg, true);
    when others then
	    err_msg := SUBSTR(SQLERRM, 1, 200);
      v$msg := util.format(util.gettext('Error al intentar obtener el %s, mensaje %s'), 'estado del reclamo',err_msg );
	    raise_application_error(v$err, v$msg, true);
	  end;
		if x$edopension<>6 or x$edoreclamo<>3 then
        v$msg := util.format(util.gettext('Error el estado de la %s no está %s (%s), o el %s no está %s (%s).'), 'pensión','denegado', x$edopension, 'reclamo asociado', x$edoreclamo);
	      raise_application_error(v$err, v$msg, true);
    end if;
    v$estado_inicial := x$edopension;
    v$estado_final   := 7;
    v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, null,
                                                  null, null, null, x$resolucion, sysdate, x$resumen);
    --p_pension, p_fecha, p_usuario, p_estado_inicial, p_estado_final, p_comentarios , p_causa , p_observaciones,
    --p_dictamen , p_fecha_dictamen, p_resumen_dictamen, p_resolucion, p_fecha_resolucion, p_resumen_resolucion)
    update pension set observaciones = null, estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = util.current_user_id() where id = x$pension;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id', x$pension);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/
