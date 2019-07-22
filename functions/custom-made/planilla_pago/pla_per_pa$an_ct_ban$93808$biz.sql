create or replace function pla_per_pa$an_ct_ban$93808$biz(x$super number, x$clase_pension number, x$ano nvarchar2) return number is
  v$err               constant number := -20000; -- an integer in the range -20000..-20999
  err_msg             varchar2(200);
  v$nen_codigo        number(2);
  v$ent_codigo        number(3);
  v$cod_ordgas        number(3);
  contador            number:=0;
  contador_aux        number:=0;
  v$baja_id           number;
  v$baja_nrocan       number;
  v_sentencia         varchar2(200);
  v$nro_solicitud     number;
  v_id                number;
  v$cantidad_cuenta   number;
  v$cumple_regla      varchar2(5);
  v$observacion       VARCHAR2(2000);
begin --solicitud baja cuenta bancaria, modificado por SIAU 11605
  begin
    Select valor_numerico into v$nen_codigo From variable_global Where numero=122;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos del valor del nivel de la entidad.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor del nivel de la entidad, mensaje:' || err_msg, true);
  end;
  begin
    Select valor_numerico into v$ent_codigo From variable_global Where numero=123;
  exception
  when no_data_found then
    raise_application_error(v$err, 'Error: no se econtraron datos del valor del código de la entidad.', true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err, 'Error al intentar obtener el valor del código de la entidad, mensaje:' || err_msg, true);
  end;
  Begin 
    Select valor_numerico into v$cod_ordgas From variable_global Where numero = 118;
  exception
  when no_data_found then
    raise_application_error(v$err,'No se encuentran datos del ordenador del gasto (118)',true);
  when others then
    raise_application_error(v$err,'Error al intentar obtener los datos del ordenador del gasto (118)',true);
  end;
  For reg in (Select cedula, cuenta_bancaria, ban_codigo, idpension
              From (Select pe.codigo as cedula, pe.cuenta_bancaria, ba.codigo as ban_codigo, pn.clase, pn.id as idpension
                    From pension pn inner join persona pe on pn.persona = pe.id
                      inner join banco ba on pe.banco = ba.id
                      inner join a_pec@sinarh pc on pc.nen_codigo=v$nen_codigo And pc.ent_codigo=v$ent_codigo And pc.ban_codigo=ba.codigo 
                                And pc.ani_aniopre=x$ano And pe.codigo=pc.per_codcci And pe.cuenta_bancaria=pc.pec_descta
                    Where pn.estado=9
                      And pc.pec_activo='S' And pe.fecha_defuncion is not null
                      And NOT Exists (Select a.baja_id From a_bajcta@sinarh a inner join a_bajdet@sinarh b on a.baja_id = b.baja_id 
                                      Where pe.codigo=b.per_codcci And a.estado in (1)
                                        And a.nen_codigo=v$nen_codigo And ent_codigo=v$ent_codigo
                                        And a.ani_aniopre=x$ano And b.pec_descta=pe.cuenta_bancaria)
                      And Not Exists (Select pn2.id From pension pn2 Where pe.id = pn2.persona And pn2.estado in (1,3,6,7) And pn2.clase<>150498912273805580) --no contempla gasto de sepeldio SIAU 12334
                      And pn.fecha_transicion in (Select max(pn2.fecha_transicion) From pension pn2 Where pn2.persona = pe.id And pn2.estado=9 And pn2.clase=x$clase_pension)
                  Group By pe.codigo, pe.cuenta_bancaria, ba.codigo, pn.clase, pn.id) sql
              Where clase=x$clase_pension) loop
    if contador_aux=0 then
      begin
        v$baja_id:= SINARH.seq_bajacta.nextval@SINARH;
        v_sentencia := 'SELECT SINARH.SEQ_SOLCANCTA_'||x$ano||'.NEXTVAL@SINARH FROM DUAL';
        EXECUTE IMMEDIATE v_sentencia into v$baja_nrocan;
        insert into a_bajcta@SINARH(baja_id, ani_aniopre, nen_codigo, ent_codigo, cod_banco, fecha_solicitud, estado, cant_reg, tfu_cod, baj_fching,
                                  baj_usring, baj_fchact, baj_usract, baja_nrocan, enc_cod_ordgas, baj_fallecido)
        values (v$baja_id, x$ano, v$nen_codigo, v$ent_codigo, reg.ban_codigo, sysdate, 1, 0, 'A', sysdate,
                substr(user,1,8), sysdate, substr(user,1,8), v$baja_nrocan, v$cod_ordgas, 'S');
      exception
      when others then
        raise_application_error(v$err, 'Error al intentar crear la solicitud de baja de la cuenta banco, mensaje:' || sqlerrm, true);
      end;
      begin
        v$nro_solicitud:=BUSCA_CLAVE_ID;
        insert into encabezado_solicitud(ID, VERSION, CODIGO, EDAD_DESDE, EDAD_HASTA, CLASE_PENSION_DESDE, CLASE_PENSION_HASTA, FECHA_SOLICITUD,
                                          FECHA_RESPUESTA, ESTADO_SOLICITUD, NEN_CODIGO, ENT_CODIGO, DESCRIPCION, TIPO_ALTA, FALLECIDO)
        values (v$nro_solicitud, 0, v$baja_nrocan, null, null, x$clase_pension, x$clase_pension, sysdate,
                null, 1, v$nen_codigo, v$ent_codigo, null, 'false', 'true');
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar insertar el encabezado de la solicitud, mensaje:' || err_msg, true);
      end;
    end if;
    begin
      Select Count(p.per_codcci) into v$cantidad_cuenta
      From a_pec@SINARH p
      Where p.ani_aniopre = x$ano
        And nvl(p.pec_activo,'N') = 'S'
        And p.pec_pedido_bloqueo is null
        And p.ban_codigo = reg.ban_codigo
        And to_number(p.pec_descta) = to_number(reg.cuenta_bancaria)
        And p.per_codcci = reg.cedula;
    exception
    when no_data_found then
      v$cantidad_cuenta:=0;
    when others then
      raise_application_error(v$err, 'Error al intentar crear la solicitud de baja de la cuenta banco, mensaje:' || sqlerrm, true);
    end;
    if (v$cantidad_cuenta<=1) then
      existe_jupe(reg.idpension, reg.cedula, v$cantidad_cuenta, v$cumple_regla, v$observacion);
      if (v$cantidad_cuenta=0) then
        existe_sinarh(reg.cedula, v$cantidad_cuenta, v$cumple_regla, v$observacion);
      end if;
      if (v$cantidad_cuenta=0) then
        begin
          Insert into a_bajdet@SINARH(per_codcci, baja_id, pec_descta, estado)
          values (reg.cedula, v$baja_id, reg.cuenta_bancaria, 'CARGADO');
          Update persona set ESTADO_BANCARIA='A', FECHA_BANCARIA =sysdate Where codigo=reg.cedula;
          contador:=contador+1;
        exception
        when others then
          raise_application_error(v$err, 'Error al intentar crear el detalle de la solicitud de baja de la cuenta banco, para la cédula:' || reg.cedula || ', mensaje:' || sqlerrm, true);
        end;
        begin
          v_id:=busca_clave_id;
          insert into solicitud_cuenta (id , version, codigo, nro_solicitud, cedula, fecha_solicitud, fecha_respuesta, banco, cuenta_bancaria, descripcion)
          values (v_id, 0, v_id, v$nro_solicitud, reg.cedula, sysdate, null, null, null, null);
        exception
        when others then
          err_msg := SUBSTR(SQLERRM, 1, 200);
          raise_application_error(v$err, 'Error al intentar insertar el detalle de la solicitud de baja, mensaje:' || err_msg, true);
        end;
      end if;
    end if;
    contador_aux:=contador_aux+1;
  end loop;
  --if contador=0 then
    --raise_application_error(v$err, 'No hay cuentas bancarias de pensiones revocadas activas de personas difuntas, para cancelar de la clase de pensión suministrada.', true);
  --else
    update a_bajcta@SINARH set cant_reg=(select count(1) from a_bajdet@sinarh where baja_id = v$baja_id) where baja_id=v$baja_id;
  --end if;
  contador_aux:=0; contador:=0;
  For reg in (Select cedula, cuenta_bancaria, ban_codigo, idpension
              From (Select pe.codigo as cedula, pe.cuenta_bancaria, ba.codigo as ban_codigo, pn.clase, pn.id as idpension
                    From pension pn inner join persona pe on pn.persona = pe.id
                      inner join banco ba on pe.banco = ba.id
                      inner join a_pec@sinarh pc on pc.nen_codigo=v$nen_codigo And pc.ent_codigo=v$ent_codigo And pc.ban_codigo=ba.codigo 
                          And pc.ani_aniopre=x$ano And pe.codigo=pc.per_codcci And pe.cuenta_bancaria=pc.pec_descta
                    Where pn.clase=x$clase_pension And pn.estado=9
                      And pc.pec_activo='S' And pe.fecha_defuncion is null
                      And NOT Exists (Select a.baja_id From a_bajcta@sinarh a inner join a_bajdet@sinarh b on a.baja_id = b.baja_id 
                                      Where pe.codigo=b.per_codcci And a.estado in (1)
                                          And a.nen_codigo=v$nen_codigo And ent_codigo=v$ent_codigo
                                          And a.ani_aniopre=x$ano And b.pec_descta=pe.cuenta_bancaria)
                      And Not Exists (Select pn2.id From pension pn2 Where pe.id = pn2.persona And pn2.estado in (1,3,6,7) And pn2.clase<>150498912273805580) --no contempla gasto de sepeldio SIAU 12334
                      And pn.fecha_transicion in (Select max(pn2.fecha_transicion) From pension pn2 Where pn2.persona = pe.id And pn2.estado=9 And pn2.clase=x$clase_pension)
                Group By pe.codigo, pe.cuenta_bancaria, ba.codigo, pn.clase, pn.id) sql
            Where clase=x$clase_pension) loop
    if contador_aux=0 then
      begin
        v$baja_id:= SINARH.seq_bajacta.nextval@SINARH;
        v_sentencia := 'SELECT SINARH.SEQ_SOLCANCTA_'||x$ano||'.NEXTVAL@SINARH FROM DUAL';
        EXECUTE IMMEDIATE v_sentencia into v$baja_nrocan;
        insert into a_bajcta@SINARH(baja_id, ani_aniopre, nen_codigo, ent_codigo, cod_banco, fecha_solicitud, estado, cant_reg, tfu_cod, baj_fching,
                                  baj_usring, baj_fchact, baj_usract, baja_nrocan, enc_cod_ordgas, baj_fallecido)
        values (v$baja_id, x$ano, v$nen_codigo, v$ent_codigo, reg.ban_codigo, sysdate, 1, 0, 'A', sysdate,
                substr(user,1,8), sysdate, substr(user,1,8), v$baja_nrocan, v$cod_ordgas, 'N');
      exception
      when others then
        raise_application_error(v$err, 'Error al intentar crear la solicitud de baja de la cuenta banco, mensaje:' || sqlerrm, true);
      end;
      begin
        v$nro_solicitud:=BUSCA_CLAVE_ID;
        insert into encabezado_solicitud(ID, VERSION, CODIGO, EDAD_DESDE, EDAD_HASTA, CLASE_PENSION_DESDE, CLASE_PENSION_HASTA, FECHA_SOLICITUD,
                                          FECHA_RESPUESTA, ESTADO_SOLICITUD, NEN_CODIGO, ENT_CODIGO, DESCRIPCION, TIPO_ALTA, FALLECIDO)
        values (v$nro_solicitud, 0, v$baja_nrocan, null, null, x$clase_pension, x$clase_pension, sysdate,
                null, 1, v$nen_codigo, v$ent_codigo, null, 'false', 'false');
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar insertar el encabezado de la solicitud, mensaje:' || err_msg, true);
      end;
    end if;
    begin
      Select Count(p.per_codcci) into v$cantidad_cuenta
      From a_pec@SINARH p
      Where p.ani_aniopre = x$ano
        And nvl(p.pec_activo,'N') = 'S'
        And p.pec_pedido_bloqueo is null
        And p.ban_codigo = reg.ban_codigo
        And to_number(p.pec_descta) = to_number(reg.cuenta_bancaria)
        And p.per_codcci = reg.cedula;
    exception
    when no_data_found then
      v$cantidad_cuenta:=0;
    when others then
      raise_application_error(v$err, 'Error al intentar crear la solicitud de baja de la cuenta banco, mensaje:' || sqlerrm, true);
    end;
    if (v$cantidad_cuenta<=1) then
      existe_jupe(reg.idpension, reg.cedula, v$cantidad_cuenta, v$cumple_regla, v$observacion);
      if (v$cantidad_cuenta=0) then
        existe_sinarh(reg.cedula, v$cantidad_cuenta, v$cumple_regla, v$observacion);
      end if;
      if (v$cantidad_cuenta=0) then
        begin
          Insert into a_bajdet@SINARH(per_codcci, baja_id, pec_descta, estado)
          values (reg.cedula, v$baja_id, reg.cuenta_bancaria, 'CARGADO');
          Update persona set ESTADO_BANCARIA='A', FECHA_BANCARIA =sysdate Where codigo=reg.cedula;
          contador:=contador+1;
        exception
        when others then
          raise_application_error(v$err, 'Error al intentar crear el detalle de la solicitud de baja de la cuenta banco, para la cédula:' || reg.cedula || ', mensaje:' || sqlerrm, true);
        end;
        begin
          v_id:=busca_clave_id;
          insert into solicitud_cuenta (id , version, codigo, nro_solicitud, cedula, fecha_solicitud, fecha_respuesta, banco, cuenta_bancaria, descripcion)
          values (v_id, 0, v_id, v$nro_solicitud, reg.cedula, sysdate, null, null, null, null);
        exception
        when others then
          err_msg := SUBSTR(SQLERRM, 1, 200);
          raise_application_error(v$err, 'Error al intentar insertar el detalle de la solicitud de baja, mensaje:' || err_msg, true);
        end;
      end if;
    end if;
    contador_aux:=contador_aux+1;
  end loop;
  --if contador=0 then
    --raise_application_error(v$err, 'No hay cuentas bancarias de pensiones revocadas activas de personas NO difuntas, para cancelar de la clase de pensión suministrada.', true);
  --else
    update a_bajcta@SINARH set cant_reg=(select count(1) from a_bajdet@sinarh where baja_id = v$baja_id) where baja_id=v$baja_id;
  --end if;
  return 0;
end;
/
