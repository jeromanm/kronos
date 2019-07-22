create or replace function pension$activar$biz(x$super number, x$pension number, x$observaciones nvarchar2)
  return number is
  v$err constant          number := -20000; -- an integer in the range -20000..-20999
  v$msg                   nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xn                    number ;
  v$estado                number ;
  v$tiene_objecion        nvarchar2(5);
  v_cant_objecion         number;
  v$estado_liquidacion    nvarchar2(5);
  v$requiere_censo        VARCHAR2(5);
  v$log rastro_proceso_temporal%ROWTYPE;
begin
  v$log := rastro_proceso_temporal$select();
  v$xn:=pension$verificar$biz(0, x$pension, 'false');
  commit;
  rastro_proceso_temporal$revive(v$log);
  Select pn.estado, pn.tiene_objecion, cp.requiere_censo, Count(op.id)
    into v$estado, v$tiene_objecion, v$requiere_censo, v_cant_objecion
  From pension pn left outer join objecion_pension op on pn.id = op.pension And op.objecion_invalida='true'
    inner join clase_pension cp on pn.clase = cp.id
  Where pn.id=x$pension
  Group By pn.estado, pn.tiene_objecion, cp.requiere_censo;
  if v_cant_objecion>0 or v$tiene_objecion='true' then
    raise_application_error(v$err,'La pensión tiene objeciones, no puede ser incluída en planilla de pago.',true);
  end if;
  if v$requiere_censo='false' then
    begin
      for reg in (Select abierto From liquidacion_haberes Where pension=x$pension Order by id desc) loop
        v$estado_liquidacion:=reg.abierto;
        exit;
      end loop;
    exception
  	when no_data_found then
      raise_application_error(v$err,'Error: no se consiguen datos de la liquidación de pensión',true);
    when others then
      v$msg := SQLERRM;
      raise_application_error(v$err,'Error al intentar obtener los datos de la liquidación de pensión, mensaje:' || v$msg,true);
    end;
    if v$estado_liquidacion<>'false' then
      raise_application_error(v$err,'Error: la liquidación de pensión no está cerrada.',true);
    end if;
  end if;
-- Fin Validar
  Update pension set observaciones_activar = x$observaciones, activa = 'true', fecha_activar = current_date, usuario_activar = current_user_id()
  Where id = x$pension;
  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'),'pensión','id',x$pension);
    raise_application_error(v$err, v$msg, true);
  end if;
  return 0;
exception
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err, v$msg, true);
end;
/
