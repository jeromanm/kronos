create or replace function pension$notifi_dicta$52902$biz(x$super number, x$pension number, x$fecha_notificacion date,x$numero_sime number,x$cedula_retiro nvarchar2) return number is
    v$err     constant number := -20000; -- an integer in the range -20000..-20999
    v$msg     nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$persona number;
    v$cedula   varchar2(20);
    v$cedula2  varchar2(20);
    v$cedula3  varchar2(20);
    v$nombre   varchar2(100);
    v$fecha_notificacion date;
begin --  Pension.notificacionDictamen - business logic
  begin
    Select pn.persona, pe.codigo, nvl(pe2.codigo,'N/E'), nvl(pe3.codigo,'N/E'), pn.fecha_notificacion
      into v$persona, v$cedula, v$cedula2, v$cedula3, v$fecha_notificacion
    From pension pn inner join persona pe on pn.persona = pe.id
      left outer join persona pe2 on pe.CEDULA_CURADOR_IDENTIF = pe2.id
      left outer join persona pe3 on pe.CEDULA_REPRESENTANTE_IDENTIF = pe3.id 
    Where pn.id=x$pension And rownum=1;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se encontró el código de la persona, en la pensión suministrada.', true);
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar obtener el código de la persona en la pensión, mensaje:' || v$msg, true);
  end;
  --raise_application_error(v$err, 'cédula1:' || v$cedula || ', cedula2:' || v$cedula2 || ', cedula3:' || v$cedula3 || ', retiro:' || x$cedula_retiro, true);
  if (x$cedula_retiro<>v$cedula And x$cedula_retiro<>v$cedula2 And x$cedula_retiro<>v$cedula3) then
    raise_application_error(v$err, 'Error: la cédula suministrada no coincide con los registros de beneficiario y/o curador (' || v$cedula2 || ') y/o representante legal (' || v$cedula3 || ').', true);
  end if;
  begin
    Select nombre into v$nombre From persona where codigo=x$cedula_retiro;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se encontró el registro persona que retira', true);
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar obtener el código de la persona que retira, mensaje:' || v$msg, true);
  end;
  if (v$fecha_notificacion is not null) then
    raise_application_error(v$err, 'Error: la pensión suministrada ya tiene un registro de notificación de fecha:' || v$fecha_notificacion, true);
  end if;
  begin
    update pension set fecha_notificacion = x$fecha_notificacion, usuario_notificacion = util.current_user_id(), NUMERO_NOTIFICACION=v$persona, SIME_NOTIFICACION=x$numero_sime,
                        RETIRADO= v$nombre, cedula_retiro=x$cedula_retiro
    where id = x$pension;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se encontraron datos de la pensión suministrada.', true);
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar obtener el actualizar la notificación en la pensión, mensaje:' || v$msg, true);
  end;
  return 0;
end;
/