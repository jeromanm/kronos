create or replace function recla_pens$re_re_r_o$64102$biz(x$super number, x$reclamo number, x$resolucion_reco_oto nvarchar2, x$fecha_resolucion_reco_oto date, x$resumen_resolucion_reco_oto nvarchar2,
                                                          x$observaciones nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg               nvarchar2(2000);
    v$estado_final        number;
    v$pension             number;
    v$tipo                number;
    v$inserta_transicion  number;
    v$estado              number;
    v$id_requisito_pen    number;
    v$id_clase_requisito  number;
begin
    begin --8.-registrar resolucion para reintegrar otorgar:
      Select estado, tipo
        into v$estado, v$tipo 
      From reclamo_pension where id = x$reclamo;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$estado:=0;
    when others then
      v$estado:=0;
      err_msg := SUBSTR(SQLERRM, 1, 200);
			v$msg := util.format(util.gettext('Error al intentar actualizar el %s, mensaje %s'), 'reclamo pensión', err_msg);
      raise_application_error(v$err, v$msg, true);
    end;
    if v$estado<>4 then
      raise_application_error(v$err,'Error: el trámite no está en estado otorgable.', true);
    end if;
    if v$tipo<>3 then --solo reintegrar
      raise_application_error(v$err,'Error: el trámite no es del tipo aceptado.', true);
    end if;
    Update reclamo_pension set resolucion_reco_oto = x$resolucion_reco_oto, fecha_resolucion_reco_oto = x$fecha_resolucion_reco_oto,
                               resumen_resolucion_reco_oto = x$resumen_resolucion_reco_oto, estado=5,
                               observaciones = x$observaciones, fecha_transicion = current_date, usuario_transicion = util.current_user_id()
    Where id = x$reclamo;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'trámite de pensión', 'id', x$reclamo);
        raise_application_error(v$err, v$msg, true);
    end if;
    begin
      Select a.pension, a.tipo, b.estado
        into v$pension, v$tipo, v$estado
      From reclamo_pension a inner join pension b on a.pension = b.id
      Where a.id=x$reclamo;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$pension:=null;
    when others then
      v$pension:=null;
      err_msg := SUBSTR(SQLERRM, 1, 2000);
			v$msg := util.format(util.gettext('Error al intentar obtener el id de la %s, mensaje %s'), 'pensión',err_msg );
      raise_application_error(v$err, v$msg, true);
    end;
    For reg in (Select rr.*, rt.clase_requisito, pn.clase as clase_pension, pn.id as idpension
              From reclamo_pension rp inner join requisito_reclamo rr on rr.reclamo=rp.id
                inner join requisito_tipo_reclamo rt on rr.clase = rt.id
                inner join pension pn on rp.pension = pn.id
              Where rp.id=x$reclamo) loop --SIAU 12170
      begin
        Select rp.id into v$id_requisito_pen 
        From requisito_pension rp inner join requisito_clase_pension rc on rp.clase = rc.id  
        Where rc.clase_requisito=reg.clase_requisito And rp.pension=reg.idpension;
      Exception
      WHEN NO_DATA_FOUND THEN
        v$id_requisito_pen:=null;
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err,'Error al intentar obtener los datos del requisito de pensión, mensaje:' || err_msg, true);
      end;
      if (v$id_requisito_pen is null) then
        begin
          Select rc.id into v$id_clase_requisito
          From REQUISITO_tipo_reclamo rt inner join requisito_clase_pension rc on rt.clase_requisito = rc.clase_requisito
          Where rt.id=reg.clase And rc.clase_pension=reg.clase_pension; 
        Exception
        WHEN NO_DATA_FOUND THEN
          v$id_clase_requisito:=null;
        when others then
          err_msg := SUBSTR(SQLERRM, 1, 2000);
          raise_application_error(v$err,'Error al intentar obtener los datos de la clase de requisito, mensaje:' || err_msg, true);
        end;
        if v$id_clase_requisito is not null then
          begin
            v$id_requisito_pen:=busca_clave_id;
            Insert Into requisito_pension (ID, VERSION, CODIGO, DESCRIPCION, PENSION, CLASE, FECHA_EXPEDICION, FECHA_VENCIMIENTO, NUMERO_SIME, ARCHIVO,
                                          LINEA, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION, CAUSA_RECHAZO, OBSERVACIONES)
            values (v$id_requisito_pen, 0, v$id_requisito_pen, reg.descripcion, v$pension, v$id_clase_requisito, reg.fecha_expedicion, reg.fecha_vencimiento, reg.numero_sime, reg.archivo,
                  reg.linea, reg.estado, sysdate, CURRENT_USER_ID, reg.causa_rechazo, reg.observaciones);
          Exception
          when others then
            err_msg := SUBSTR(SQLERRM, 1, 2000);
            raise_application_error(v$err,'Error al intentar crear el requisito pension, mensaje:' || err_msg, true);
          end;
        end if;
      else
        begin
          Update requisito_pension set estado=reg.estado, fecha_expedicion = reg.fecha_expedicion, FECHA_VENCIMIENTO= reg.fecha_vencimiento, fecha_transicion=sysdate,  USUARIO_TRANSICION=CURRENT_USER_ID
          Where id=v$id_requisito_pen;
        Exception
        WHEN NO_DATA_FOUND THEN
          raise_application_error(v$err,'Error: no se consiguen registros del requisito pension id:' || v$id_requisito_pen, true);
        when others then
          err_msg := SUBSTR(SQLERRM, 1, 2000);
          raise_application_error(v$err,'Error al intentar actualizar el requisito pension, mensaje:' || err_msg, true);
        end;
      end if;
    end loop;
    if v$tipo=3 And v$estado=9 then
      v$estado_final := 7;--otorgada
      Update pension set estado=v$estado_final, fecha_transicion=sysdate, usuario_transicion=CURRENT_USER_ID
      Where id=v$pension;
      --, activa='true', fecha_activar=sysdate modificado por SIAU 11668
      v$inserta_transicion := transicion_pension$biz(v$pension, x$fecha_resolucion_reco_oto, CURRENT_USER_ID, v$estado, v$estado_final, null, null, x$observaciones, null, null, null, x$resolucion_reco_oto, x$fecha_resolucion_reco_oto, x$resumen_resolucion_reco_oto);
    else
      raise_application_error(v$err,'Error: la pensión no está en estado otorgada o el tipo de trámite no es reintegrar.', true);
    end if;
    return 0;
end;
/