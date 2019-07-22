create or replace function persona$reg_act_matr$93361$biz(x$super number, x$persona number, x$certificado_matrimonio nvarchar2, x$oficina_matrimonio number, x$fecha_acta_matrimonio date, 
                                                          x$tomo_matrimonio nvarchar2, x$folio_matrimonio number,  x$acta_matrimonio number,  x$cedula_conyuge nvarchar2,  x$nombre_conyuge nvarchar2, 
                                                          x$fecha_matrimonio date, x$fecha_certificado_matrimonio date,  x$numero_sime_matrimonio number) return number is
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg             nvarchar2(2000); -- a character string of at most 2048 bytes?
  v_id_matrimonio   number;  
  err_num           NUMBER;
  err_msg           VARCHAR2(255);
  v$cedula          VARCHAR2(20);
  v$nombre          VARCHAR2(100);
begin
  begin
    Select codigo, nombre into v$cedula, v$nombre From persona Where id=x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener la cédula de la persona, mensaje:' || v$msg,true);
  end;
  begin
    update persona  set certificado_matrimonio = x$certificado_matrimonio, oficina_matrimonio = x$oficina_matrimonio, fecha_acta_matrimonio = x$fecha_acta_matrimonio,
                        tomo_matrimonio = x$tomo_matrimonio, folio_matrimonio = x$folio_matrimonio, acta_matrimonio = x$acta_matrimonio, cedula_conyuge = x$cedula_conyuge, 
                        nombre_conyuge = x$nombre_conyuge, fecha_matrimonio = x$fecha_matrimonio, fecha_certificado_matrimonio = x$fecha_certificado_matrimonio,
                        numero_sime_matrimonio     = x$numero_sime_matrimonio, observac_anular_matrimon_43115 = null
    where id = x$persona;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err,'Error: no se consiguen datos de la persona.',true);
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar actualizar los datos de la persona, mensaje:' || v$msg,true);
  end;
  begin
    v_id_matrimonio := busca_clave_id;
    insert into matrimonio (id, version, codigo, persona, cedula1, nombre1, persona2, cedula2, nombre2,  
                            tomo_matrimonio, folio_matrimonio, acta_matrimonio, fecha_matrimonio,
                            numero_sime, fecha_transicion)
    values (v_id_matrimonio, 0, v_id_matrimonio, x$persona, v$cedula, v$nombre, null, x$cedula_conyuge,  x$nombre_conyuge,
            x$tomo_matrimonio, x$folio_matrimonio, x$acta_matrimonio, x$fecha_matrimonio,
            x$numero_sime_matrimonio, null);
  EXCEPTION
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar crear el registro de matrimonio, mensaje:' || v$msg,true);
  end;
  return 0;
end;
/
