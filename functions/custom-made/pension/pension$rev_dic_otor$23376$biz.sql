create or replace function pension$rev_dic_otor$23376$biz(x$super number, x$pension number, x$observaciones nvarchar2)
  return number is
  v$err                     constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log                     rastro_proceso_temporal%ROWTYPE;
  v$inserta_transicion      number;
  v$estado_inicial          number;
  v$estado_final            number;
  err_num                   NUMBER;
  err_msg                   VARCHAR2(255);
  v_fecha_dictamen_otorgar  date;
begin -- revertir dictamen otorgar
  begin
    Select pn.fecha_dictamen_otorgar, pn.estado 
      into v_fecha_dictamen_otorgar, v$estado_inicial
    From pension pn Where pn.id = x$pension;
  exception
	when no_data_found then
		raise_application_error(v$err,'Error: no se consiguen datos de la pensión',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos de la pensión, mensaje:' || v$msg,true);
  end;
  if v$estado_inicial<>6 then
    raise_application_error(v$err,'Error: sólo puede revertir un dictámen de una pensión en estado otorgable.',true);
  end if;
  v$estado_final := 3;
  Delete From detalle_liqu_haber Where liquidacion_haberes in (Select id From liquidacion_haberes where pension=x$pension);
  Delete From CONCEPTO_PENSION  Where PENSION=x$pension And acuerdo_pago is null;
  Delete From liquidacion_haberes Where pension=x$pension;
  Update pension set resumen_dictamen_otorgar =  null, antecedente_oto = null, disposicion_oto_uno = null, disposicion_oto_dos = null,
                     disposicion_oto_tres = null, opinion_oto_uno = null, opinion_oto_dos = null, opinion_oto_tres = null, dictamen_otorgar = null, 
                     fecha_dictamen_otorgar = null, observaciones = x$observaciones, estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = current_user_id()
  Where id = x$pension;    
  v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final,
                                                 null, null, x$observaciones, null, null, null, null, null, null);
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id',x$pension);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(-20001, err_msg, true);
end;
/