create or replace function trami_admi$re_re_h_a$55267$biz(x$super number, x$tramite number, x$resolucion_habe_atrasado nvarchar2, 
                                                          x$fecha_resol_habe_atras_33026 date, x$resumen_resol_habe_atrasado nvarchar2) return number is
    v$err                 constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg               nvarchar2(2000);
    v$estado              number;
    v$tipo                number;
    v$estado_pension      number;
    v$estado_final        number;
    v$pension             number;
    v$inserta_transicion  number;
    v$id_requisito_pen    number;
    v$id_clase_requisito  number;
begin
    begin --14.-registrar resolucion otorgar
      Select ta.estado, ta.tipo, pn.id, pn.estado 
        into v$estado, v$tipo, v$pension, v$estado_pension
      From  tramite_administrativo ta inner join pension pn on ta.pension = pn.id 
      where ta.id = x$tramite;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$estado:=0;
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 2000);
			raise_application_error(v$err,'Error al intentar obtener el estado del trámite y su pensión, mensaje:' || err_msg,true);
    end;
    if v$estado<>5 then
      raise_application_error(v$err,'Error: el trámite no está en estado otorgable.', true);
    end if;
    begin
      Update tramite_administrativo set fecha_transicion = current_date, usuario_transicion = util.current_user_id(), FECHA_RESOLUCION_HABE_ATRASADO=x$fecha_resol_habe_atras_33026,
                                        RESUMEN_RESOL_HABE_ATRASADO=x$resumen_resol_habe_atrasado, RESOLUCION_HABE_ATRASADO=x$resolucion_habe_atrasado, estado=6
      Where id = x$tramite;
    Exception
    WHEN NO_DATA_FOUND THEN
      v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'trámite administrativo de pensión', 'id', x$tramite);
      raise_application_error(v$err, v$msg, true);
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 200);
			v$msg := util.format(util.gettext('Error al intentar actualizar el %s, mensaje %s'), 'trámite administrativo de pensión', err_msg);
      raise_application_error(v$err, v$msg, true);
    end;
    For reg in (Select rr.*, rt.clase_requisito, pn.clase as clase_pension, pn.id as idpension
              From tramite_administrativo ta inner join requisito_tramite rr on rr.tramite=ta.id
                inner join requisito_tipo_tramite rt on rr.clase = rt.id
                inner join pension pn on ta.pension = pn.id
              Where ta.id=x$tramite) loop --SIAU 12170
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
          From REQUISITO_tipo_tramite rt inner join requisito_clase_pension rc on rt.clase_requisito = rc.clase_requisito
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
    if v$tipo=6 And v$estado_pension=9 then
      v$estado_final := 7;--otorgada
      begin
        Update pension set estado=v$estado_final, fecha_transicion=sysdate, usuario_transicion=CURRENT_USER_ID
        Where id=v$pension;
        --, activa='true', fecha_activar=sysdate modificado por SIAU 11668
        v$inserta_transicion := transicion_pension$biz(v$pension, sysdate, CURRENT_USER_ID, v$estado_pension, v$estado_final, null, null, null, null, null, null, x$resolucion_habe_atrasado, x$fecha_resol_habe_atras_33026, x$resumen_resol_habe_atrasado);
      Exception
      WHEN NO_DATA_FOUND THEN
        raise_application_error(v$err,'Error: no se consiguieron datos de la pensión código:' || v$pension,true);
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err,'Error al intentar actualizar el estado de la pensión, mensaje:' || err_msg,true);
      end;
    elsif v$tipo=6 And v$estado_pension<>9 then
      raise_application_error(v$err,'Error: la pensión no está en estado revocada y el tipo de trámite es reconsiderar.', true);
    end if;
    return 0;
end;
/
