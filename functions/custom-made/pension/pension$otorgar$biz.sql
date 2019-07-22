create or replace function pension$otorgar$biz(x$super number, x$pension number, x$resolucion varchar2, x$fecha date, x$antecedente_resol_oto varchar2, x$antecedente_resol_oto_uno varchar2,
                                              x$disposicion_resol_oto_uno varchar2, x$disposicion_resol_oto_dos varchar2, x$disposicion_resol_oto_tres varchar2,
                                              x$opinion_resol_oto_uno varchar2, x$opinion_resol_oto_dos varchar2, x$opinion_resol_oto_tres varchar2,
                                              x$resumen_resol_oto_uno varchar2, x$resumen_resol_oto_dos varchar2, x$resumen_resol_oto_tres varchar2) return number is
    v$err                     constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$log rastro_proceso_temporal%ROWTYPE;
    v$inserta_transicion      number;
    v$estado_inicial          number;
    v$estado_final            number;
    v$fecha_dictamen          date;
    v_dictamen_otorgar        VARCHAR2(255);
    v_fecha_dictamen_otorgar  date;
    err_num                   NUMBER;
    err_msg                   VARCHAR2(255);
    v$requiere_censo          VARCHAR2(5);
    v$id_liquidacion          number;
    v$tiene_objecion          VARCHAR2(5);
    v$indigena                VARCHAR2(5):='false';
    v$clase_pension           number;
begin
  begin
    Select pn.estado, cp.requiere_censo , pn.dictamen_otorgar, pn.fecha_dictamen_otorgar, pn.tiene_objecion, pe.indigena, pn.clase
      into v$estado_inicial, v$requiere_censo, v_dictamen_otorgar, v$fecha_dictamen, v$tiene_objecion, v$indigena, v$clase_pension
    From pension pn inner join clase_pension cp on pn.clase = cp.id
      inner join persona pe on pn.persona = pe.id
    Where pn.id=x$pension;
  exception
	when no_data_found then
		raise_application_error(v$err,'Error: no se consiguen datos de la pensión',true);
	when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener los datos de la pensión, mensaje:' || v$msg,true);
  end;
  if to_date(v$fecha_dictamen,'dd/mm/yyyy')>to_date(x$fecha,'dd/mm/yyyy') or x$fecha is null then
    raise_application_error(v$err,'Error: la fecha del dictamen (' || v$fecha_dictamen || ') no puede ser mayor a la fecha de resolución:' || x$fecha || ', o debe ingresar una.',true);
  end if;
  if v$tiene_objecion='true' then
    raise_application_error(v$err,'Error: la pensión tiene objeciones.',true);
  end if;
  if v$requiere_censo='false' then
    begin
      Select id into v$id_liquidacion From liquidacion_haberes Where pension=x$pension And rownum=1; -- And recalculo='false'; modificado por FMA Tecnico Nro: 11704
    exception
  	when no_data_found then
      raise_application_error(v$err,'Error: no se consiguen datos de la liquidación de pensión, debe realizar el cálculo antes de otorgar la pensión',true);
    when others then
      v$msg := SQLERRM;
      raise_application_error(v$err,'Error al intentar obtener los datos de la liquidación de pensión, mensaje:' || v$msg,true);
    end;
    if v$id_liquidacion is null then
      raise_application_error(v$err,'Error: no se consiguen datos de la liquidación de pensión, debe realizar el cálculo antes de otorgar la pensión.',true);
    end if;
  end if;
  begin
    Insert Into REQUISITO_PENSION(ID, VERSION, CODIGO, DESCRIPCION, PENSION, CLASE)
        Select busca_clave_id, 0, busca_clave_id, rtp.nombre, x$pension, rtp.id
        From REQUISITO_CLASE_PENSION rtp 
        Where rtp.clase_pension=v$clase_pension And indigena=v$indigena And rtp.ACTIVO_REQUISITO='true'
          And not Exists (Select rp.* From requisito_pension rp inner join requisito_clase_pension rc on rp.clase = rc.id
          Where rtp.clase_requisito=rc.clase_requisito And rp.pension=x$pension); --SIAU 12170
  exception
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener si la persona asociada a la pensión es miembro de una comunidad indìgena, mensaje:' || v$msg,true);
  end;
	v$estado_final   := 7;
	update pension set ANTECEDENTE_RESOL_OTO=x$antecedente_resol_oto, DISPOSICION_RESOL_OTO_DOS=x$disposicion_resol_oto_dos, DISPOSICION_RESOL_OTO_TRES=x$disposicion_resol_oto_tres,
                    DISPOSICION_RESOL_OTO_UNO=x$disposicion_resol_oto_uno, OPINION_OTO_DOS=x$opinion_resol_oto_dos, OPINION_OTO_TRES=x$opinion_resol_oto_tres, antecedente_resol_oto_uno=x$antecedente_resol_oto_uno,
                    OPINION_OTO_UNO=x$opinion_resol_oto_uno,  OPINION_RESOL_OTO_DOS=x$opinion_resol_oto_dos, OPINION_RESOL_OTO_TRES=x$opinion_resol_oto_tres,
                    OPINION_RESOL_OTO_UNO=x$opinion_resol_oto_uno, RESUMEN_RESOL_OTO_DOS=x$resumen_resol_oto_dos, RESUMEN_RESOL_OTO_TRES=x$resumen_resol_oto_tres,
                    RESUMEN_RESOL_OTO_UNO = x$resumen_resol_oto_uno, estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = util.current_user_id(),
                    fecha_resolucion_otorgar=x$fecha, RESOLUCION_OTORGAR=x$resolucion
	Where id = x$pension;
	v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final,
                                                 null, null, null, null, null, null, x$resolucion, x$fecha, x$resumen_resol_oto_uno);
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pension', 'id', x$pension);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(v$err, err_msg, true);
end;
/