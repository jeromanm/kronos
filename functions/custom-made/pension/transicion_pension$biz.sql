create or replace function transicion_pension$biz(p_pension NUMBER, p_fecha DATE, p_usuario NUMBER, p_estado_inicial NUMBER, p_estado_final NUMBER,
                                                  p_comentarios NVARCHAR2, p_causa NVARCHAR2, p_observaciones NVARCHAR2, p_dictamen NVARCHAR2,
                                                  p_fecha_dictamen DATE, p_resumen_dictamen NVARCHAR2, p_resolucion NVARCHAR2, p_fecha_resolucion DATE, p_resumen_resolucion NVARCHAR2) return number is
  v$err         constant number := -20000;
  err_msg       VARCHAR2(255);
  id_transicion number;
  v_fecha       date:=p_fecha;
begin
  if trim(v_fecha) is null then
     Select sysdate into v_fecha From dual;
  /*else
    begin
      Select to_date(p_fecha,'dd/mm/rrrr hh:mi') into v_fecha From dual;
    exception
    when others then
      Select to_date(sysdate,'dd/mm/rrrr hh:mi') into v_fecha From dual;
    end;*/
  end if;
  id_transicion := busca_clave_id;
  insert into transicion_pension (id, version, pension, fecha, usuario, estado_inicial, estado_final, comentarios, causa,
                                  observaciones, dictamen, fecha_dictamen, resumen_dictamen, resolucion, fecha_resolucion, resumen_resolucion)
  values (id_transicion, 0, p_pension, v_fecha, p_usuario, p_estado_inicial, p_estado_final, p_comentarios, p_causa,
          p_observaciones, substr(p_dictamen,1,50), p_fecha_dictamen, substr(p_resumen_dictamen,1,2000), substr(p_resolucion,1,50), p_fecha_resolucion, substr(p_resumen_resolucion,1,2000));
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(v$err, 'Error en transición pensión, mensaje:' || err_msg, true);
end;
/