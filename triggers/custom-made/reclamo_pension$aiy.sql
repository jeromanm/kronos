create or replace procedure reclamo_pension$aiy(x$row reclamo_pension%ROWTYPE)
is
  err_msg                     varchar2(200);
  v$cant                      number;
begin
  begin
    Select Count(id) into v$cant
    From reclamo_pension Where pension=x$row.pension And estado=1;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v$cant:=0;
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(-20000,'Error al intentar obtener datos de trámite de pensión anteriores, mensaje:'|| err_msg, true);
  END;
  if v$cant>1 then
    raise_application_error(-20000,'Error: ya existe(n) ' || (v$cant-1) || ' trámite de pensión pendiente(s) asociado a la pension:' || x$row.pension,  true);
  end if;
  if x$row.tipo=1 then  --1	Reconsiderar denegacion se valida que no tenga planillas de pago
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
  elsif x$row.tipo=2 then --2	Reconsiderar otorgamiento se valida que no tenga planillas de pago
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
  elsif x$row.tipo=3 then --3	Reintegrar se validar que tenga planillas de pago
    begin
      Select Count(rp.id) into v$cant 
      From resumen_pago_pension rp Where rp.pension=x$row.pension;
    EXCEPTION
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 200);
      raise_application_error(-20000,'Error al intentar obtener las planillas asociadas a la pensión, mensaje:'|| err_msg, true);
    END;
    if (v$cant=0) then
      raise_application_error(-20000,'Error: la pensión ' || x$row.pension || ' no tiene planillas asociadas, no puede ser procesado el trámite', true);
    end if;
  end if;
  begin
  Insert Into REQUISITO_RECLAMO(ID, VERSION, CODIGO, DESCRIPCION, RECLAMO, CLASE, NUMERO_SIME, ESTADO)
    Select busca_clave_id, 0, busca_clave_id, rtc.nombre, x$row.id, rtc.id, x$row.numero_sime,1
    From requisito_tipo_reclamo rtc Where rtc.tipo_reclamo=x$row.tipo;
  EXCEPTION
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(-20000,'Error al intentar crear requisitos al trámite de pensión, mensaje:'|| err_msg, true);
  end;
end;
/
