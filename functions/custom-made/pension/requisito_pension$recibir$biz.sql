create or replace function requisito_pension$recibir$biz(x$super number, x$requisito number, x$fecha_expedicion date, x$fecha_vencimiento date, x$observaciones nvarchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$fecha_vcto    date;
begin
  update requisito_pension set fecha_expedicion = x$fecha_expedicion, fecha_vencimiento = x$fecha_vencimiento, observaciones = x$observaciones, 
                              estado = 3, fecha_transicion = current_date, usuario_transicion = util.current_user_id() 
  Where id = x$requisito;
  if not SQL%FOUND then
       v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'requisito de pensión', 'id', x$requisito);
       raise_application_error(v$err, v$msg, true);
  end if;
  begin
    Select case when nvl(c.cantidad_periodo_vigencia,0)>0 then
              case c.unidad_periodo_vigencia 
              when 1 then (nvl(b.fecha_expedicion,b.fecha_transicion)+ c.cantidad_periodo_vigencia)
              when 2 then ADD_MONTHS(nvl(b.fecha_expedicion,b.fecha_transicion), c.cantidad_periodo_vigencia)
              when 3 then ADD_MONTHS(nvl(b.fecha_expedicion,b.fecha_transicion), c.cantidad_periodo_vigencia*12)
              else nvl(b.fecha_expedicion,b.fecha_transicion) end 
          else b.fecha_vencimiento end into v$fecha_vcto
    From requisito_pension b inner join requisito_clase_pension c on b.clase = c.id 
    Where b.id=x$requisito;
  exception
  WHEN NO_DATA_FOUND THEN
    v$fecha_vcto:=NULL;
  when others then
    raise_application_error(v$err,'Error al intentar obtener la fecha de vencimiento del requisito, mensaje:'|| sqlerrm, true);
	End;
  if v$fecha_vcto<sysdate then
    raise_application_error(v$err,'Error: el requisito está vencido, fecha evaluada:' || v$fecha_vcto, true);    
  end if;
  return 0;
end;
/
