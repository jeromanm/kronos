create or replace function pla_per_pa$ve_ct_ban$84422$biz(x$super number, x$solicitud number) return number is
    v$err       constant number := -20000; -- an integer in the range -20000..-20999
    v$msg       nvarchar2(2000); -- a character string of at most 2048 bytes?
    err_msg     nvarchar2(200);
    contador    integer:=0;
    v_estado    integer;
    v$solicitud number(8);
begin
  Begin
    Select ESTADO_SOLICITUD, to_number(codigo) into v_estado, v$solicitud From encabezado_solicitud Where id=x$solicitud;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_estado:=0;
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el estado de la solicitud de cuenta, mensaje:' || err_msg, true);
  End;
  if v_estado<>1 then
    raise_application_error(v$err, 'Error: la solicitud de cuenta no está en estado solicitado, o no existe.', true);
  end if;
  For reg in (Select a.id, a.nro_solicitud, a.cedula, a.fecha_solicitud, b.ALT_DESCTA_ASIG, b.FCH_PROCESO, b.ESTADO, b.OBS_RECHAZO, b.RECUPERADO, c.id as banco
              From solicitud_cuenta a inner join a_pxbdet@SINARH b on a.cedula=b.per_codcci
                inner join banco c on c.codigo='2'
                inner join a_pxbcab@SINARH d on b.alta_id=d.alta_id
              Where a.CUENTA_BANCARIA is null And b.alta_id =v$solicitud 
                And d.estado = 4 And b.fch_proceso is not null
              Group By a.id, a.nro_solicitud, a.cedula, a.fecha_solicitud, b.ALT_DESCTA_ASIG, b.FCH_PROCESO, b.ESTADO, b.OBS_RECHAZO, b.RECUPERADO, c.id) loop
      Begin
        if contador=0 then
          Update encabezado_solicitud set ESTADO_SOLICITUD=2 where id=x$solicitud;
        end if;
        Update persona set banco=reg.banco, CUENTA_BANCARIA=reg.ALT_DESCTA_ASIG, ESTADO_BANCARIA='P', FECHA_BANCARIA =sysdate
        Where codigo=reg.cedula;
        Update solicitud_cuenta set banco=reg.banco, CUENTA_BANCARIA=reg.ALT_DESCTA_ASIG, FECHA_RESPUESTA=reg.FCH_PROCESO, descripcion=reg.OBS_RECHAZO 
        Where id=reg.id;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(v$err, 'Error: no se encuentran datos de la persona:' || reg.cedula || ' asociado a la solicitud de cuenta nro:' || reg.nro_solicitud, true);
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar actualizar los datos de solicitud de cuenta, mensaje:' || err_msg, true);
      End;
      contador:=contador+1;
  end loop;
  if contador=0 then
    raise_application_error(v$err, 'Error: no se encuentran datos la solicitud en estado procesado.', true);
  end if;
  return 0;
EXCEPTION
when others then
  v$msg := SUBSTR(SQLERRM, 1, 2000);
  raise_application_error(v$err, v$msg, true);
end;
/
