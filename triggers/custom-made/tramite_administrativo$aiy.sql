create or replace procedure tramite_administrativo$aiy(x$row tramite_administrativo%ROWTYPE) is
  err_msg                     varchar2(200);
  v$cant                      number;
begin
  begin
    Select Count(id) into v$cant 
    From tramite_administrativo Where pension=x$row.pension And estado=1;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v$cant:=0;
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(-20000,'Error al intentar obtener datos de tràmites anteriores, mensaje:'|| err_msg, true);
  END;
  if v$cant>1 then
    raise_application_error(-20000,'Error: ya existe(n) ' || (v$cant-1) || ' trámite pendiente(s) asociado a la pension:' || x$row.pension,  true);
  end if;
  if x$row.tipo=6 then  --6	Reconsiderar revocadas se valida que no tenga planillas de pago
    begin
      Select Count(rp.id) into v$cant 
      From resumen_pago_pension rp Where rp.pension=x$row.pension;
    EXCEPTION
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 200);
      raise_application_error(-20000,'Error al intentar obtener las planillas asociadas a la pensión, mensaje:'|| err_msg, true);
    END;
    if (v$cant>0) then
      raise_application_error(-20000,'Error: la pensión ' || x$row.pension || ' tiene ' || v$cant || ' planillas asociadas, no puede ser procesado el trámite', true);
    end if;
  end if;
  begin
    Insert into requisito_tramite(id, codigo, descripcion, tramite, clase, numero_sime)
      Select busca_clave_id, busca_clave_id, rtt.nombre, x$row.id, rtt.id, x$row.numero_sime
      From requisito_tipo_tramite rtt where rtt.tipo_tramite=x$row.tipo;
  EXCEPTION
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(-20000,'Error al intentar insertar requisitos de trámite, mensaje:'|| err_msg, true);
  END;
end;
/
