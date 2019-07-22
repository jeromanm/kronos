  create or replace function pla_per_pa$so_ct_ban$94443$biz(x$super number, x$clase_pension_desde number, x$clase_pension_hasta number, x$ano number, x$edad_desde integer, x$edad_hasta integer) return number is
  v$err             constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_msg               nvarchar2(200);
  x$user                varchar2(30);
  contador              number:=0;
  cantreg               number:=0;
  v_existe              varchar2(1);
  v_cta_activa          varchar2(1);
  v_alta_id             number:=null;
  v$nro_solicitud       number;
  v_id                  number;
  x$idbanco             number;
  x$codigobanco         varchar2(10):='02';
  x$per_linea_datos     varchar2(400);
  v$tiene_cuenta        varchar2(5):='false';
  v$nen_codigo          number:=12; 
  v$ent_codigo          number:=6;
  v$clase_pension_desde number;
  v$clase_pension_hasta number;
  v$per_codcci          varchar2(15);
  v$per_codsexo         varchar2(1);
  v$per_emp             varchar2(15);
begin --solicitud de cuenta bancaria
  begin
    Select codigo_usuario into x$user
    From usuario where id_usuario=current_user_id;
  exception
  when no_data_found then
    x$user := 'usuario';
  when others then
    x$user := 'usuario';
  end;
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
  begin
    Select codigo into v$clase_pension_desde From clase_pension where id=x$clase_pension_desde;
  exception
  when no_data_found then
    v$clase_pension_desde:=null;
  when others then
    v$clase_pension_desde:=null;
  end;
  begin
    Select codigo into v$clase_pension_hasta From clase_pension where id=x$clase_pension_hasta;
  exception
  when no_data_found then
    v$clase_pension_hasta:=null;
  when others then
    v$clase_pension_hasta:=null;
  end;
  For reg in (Select distinct(pe.codigo) as codigo, case instr(pe.nombres,' ') when 0 then to_char(pe.nombres) else to_char(substr(pe.nombres,1,instr(pe.nombres,' '))) end as primer_nom, 
                    case instr(pe.nombres,' ') when 0 then ' ' else to_char(substr(pe.nombres,instr(pe.nombres,' ')+1)) end segundo_nom, pe.nombres, pe.apellidos,
                    case instr(pe.apellidos,' ') when 0 then to_char(pe.apellidos) else to_char(substr(pe.apellidos,1,instr(pe.apellidos,' '))) end as primer_ape,
                    case instr(pe.apellidos,' ') when 0 then '' else to_char(substr(pe.apellidos,instr(pe.apellidos,' ')+1)) end as segundo_ape,  
                    trim(pe.apellidos) || ' ' || trim(pe.nombres) as apynom,
                    pe.lugar_nacimiento, dp.codigo as DEP_CODDEPTO, dp.nombre as departamento, dt.nombre as distrito, ba.nombre as barrio, nvl(pe.pais,0) as pais,
                    (Select rp.monto From resumen_pago_pension rp Where rp.pension = pn.id And to_date('01/' || rp.mes_resumen || '/' || rp.ano_resumen,'dd/mm/yyyy')=
                        (Select max(to_date('01/' || rp1.mes_resumen || '/' || rp1.ano_resumen,'dd/mm/yyyy')) From resumen_pago_pension rp1 Where pn.id = rp1.pension And rp1.ano_resumen=x$ano)) as monto, 
                    pe.estado_civil, nvl(pe.direccion,'N/E') as direccion, pe.sexo, pe.fecha_nacimiento, pe.telefono_linea_baja
            From persona pe inner join pension pn on pe.id = pn.persona 
              inner join departamento dp on pe.departamento = dp.id
              inner join distrito dt  on pe.distrito = dt.id
              left outer join barrio ba on pe.barrio = ba.id
              inner join clase_pension cp on pn.clase = cp.id
            Where pe.cuenta_bancaria is null And pn.activa='true' And pn.estado=7 And pn.tiene_objecion='false'
              And not exists (Select sc.id From encabezado_solicitud ec inner join solicitud_cuenta sc on ec.id = sc.nro_solicitud 
                              Where pe.codigo = sc.cedula And sc.fecha_respuesta is null And ec.estado_solicitud=1 And tipo_alta='true')
              And exists (Select rp.id From resumen_pago_pension rp inner join detalle_pago_pension dp on rp.id = dp.resumen 
                              Where rp.pension = pn.id And dp.activo='true' And rp.ano_resumen=x$ano)
              And (to_number(calcular_edad(pe.fecha_nacimiento))>=x$edad_desde or x$edad_desde is null) 
              And (to_number(calcular_edad(pe.fecha_nacimiento))<=x$edad_hasta or x$edad_hasta is null)
              And (to_number(cp.codigo)>=v$clase_pension_desde or v$clase_pension_desde is null)
              And (to_number(cp.codigo)<=v$clase_pension_hasta or v$clase_pension_hasta is null)
            ) loop
    if contador=0 then
      begin
        v_alta_id:=seq_alta_pxb.nextval@SINARH;
        Insert Into a_pxbcab@SINARH(alta_id, ani_aniopre, nen_codigo, ent_codigo, nombre_entidad, cod_banco, fecha_solicitud, estado,
                                    cant_reg, alt_fching, alt_usring, alt_fchact, alt_usract, tfu_cod, enc_cod_ordgas)
        Values (v_alta_id, x$ano, v$nen_codigo, v$ent_codigo, 'MINISTERIO DE HACIENDA', x$codigobanco, sysdate, 1, 
                null, sysdate, x$user, sysdate, x$user, 'A', 157);
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar insertar en la tabla a_pxbcab@SINARH, mensaje:' || err_msg, true);
      end;
      begin
        v$nro_solicitud:=BUSCA_CLAVE_ID;
        insert into encabezado_solicitud(ID, VERSION, CODIGO, EDAD_DESDE, EDAD_HASTA, CLASE_PENSION_DESDE, CLASE_PENSION_HASTA, FECHA_SOLICITUD,
                                          FECHA_RESPUESTA, ESTADO_SOLICITUD, NEN_CODIGO, ENT_CODIGO, DESCRIPCION, TIPO_ALTA, FALLECIDO)
        values (v$nro_solicitud, 0, v_alta_id, x$edad_desde, x$edad_hasta, x$clase_pension_desde, x$clase_pension_hasta, sysdate,
                null, 1, v$nen_codigo, v$ent_codigo, null, 'true', 'false');
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar insertar el encabezado de la solicitud, mensaje:' || err_msg, true);
      end;
    end if;
    v$per_codcci:=null;
    begin
      Select per_codcci into v$per_codcci From a_per@SINARH Where PER_CODCCI=trim(reg.codigo);
    exception
    when no_data_found then
      v$per_codcci:=null;
    when others then
      v$per_codcci:=null;
      err_msg := SUBSTR(SQLERRM, 1, 200);
      raise_application_error(v$err, 'Error al intentar obtener la persona desde Sinarh, mensaje:' || err_msg, true);
    end;
    if v$per_codcci is null then --persona no existe en sinarh
      begin
        if reg.sexo=1 then 
          v$per_codsexo:='M';
        elsif reg.sexo=6 then 
          v$per_codsexo:='F';
        else 
          v$per_codsexo:='-';
        end if;
        INSERT INTO a_per@SINARH(PER_CODCCI, PER_APYNOM, PER_NOMBRES, PER_APENAC, PER_APECAS, PER_CODSEXO, PER_LUGNAC, PER_FCHNACI, 
                                NAC_CODPAIS, CIV_CODECIV, PER_FCHINGR, PER_FCHBAJA, PER_DESDOMI, LOC_CODLOCA, DEP_CODDEPTO, 
                                PER_CODPOST, DIS_CODDIST, OPE_CODOPER, FIN_CODEFIN, CTA_CODCTA, PER_CELULAR, PER_REGCOND,
                                PER_DESCTA, PER_TELEFONO, PER_TIPREG, PER_DESCTA_OLD, PER_MUNICIPIO, PER_GRPOSANG, PER_PROFESION, PER_REGPROF, 
                                PER_NRORUC, TFU_CODIGO, PER_USUNOM, PER_USUFCH, DISCAPACIDAD) 
	        values(substr(reg.codigo,1,15), substr(reg.apynom,1,80), substr(reg.nombres,1,40), substr(reg.apellidos,1,40), null, v$per_codsexo, reg.lugar_nacimiento, reg.fecha_nacimiento, 
                decode(reg.pais,226,1,205,13,209,8,201,2,231,4,413,17,214,6,206,3,0,0), decode(reg.estado_civil,1,2,2,1,3,5,4,4,5,1,6,3,7,0), sysdate, null, substr(reg.direccion,1,50), 0, 0,
                1206, 0, null, null, null, null, null, 
                null, substr(reg.telefono_linea_baja,1,12), null, null, null, null, null, null, 
                null, 6, substr(user,1,8), sysdate, 'N');
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar insertar el registro de persona en Sinarh, mensaje:' || err_msg, true);
      end;
    end if;
    v$per_emp:=null;
    begin
      Select PER_CODCCI into v$per_emp From A_EMP@SINARH 
      Where PER_CODCCI=trim(reg.codigo) And TFU_CODIGO=6 And COF_CODIGO=8; --buscar registro de persona en empleo tipo pensionado TFU_CODIGO=6 en oficina 8
    exception
    when no_data_found then
      v$per_emp:=null;
    when others then
       v$per_emp:=null;
       err_msg := SUBSTR(SQLERRM, 1, 200);
      raise_application_error(v$err, 'Error al intentar obtener el registro de empleo desde Sinarh, mensaje:' || err_msg, true);
    end;
    if v$per_emp is null then
      BEGIN
          INSERT INTO A_EMP@SINARH (COF_CODIGO, OFI_CODN1, OFI_CODN2, OFI_CODN3, OFI_CODN4, OFI_CODN5, OFI_CODN6, EMP_FCHING, PER_CODCCI, EMP_USRING, EMP_FCHACT, EMP_USRACT,
                                    TFU_CODIGO, EMP_ACTIVO, EMP_PXB, EMP_FCHPXB, EMP_USRPXB)
          VALUES (8, 4, 8, 0, 0, 0, 0, SYSDATE, substr(reg.codigo,1,15), substr(user,1,8), SYSDATE, substr(user,1,8), 
                  6, NULL, NULL, NULL, NULL);
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar insertar el registro empleado en Sinarh, mensaje:' || err_msg, true);
      end;
    end if;
    begin
      v_existe := 'N';
      Select 'S' into v_existe
      From a_pxbcab@SINARH c inner join a_pxbdet@SINARH d on c.alta_id=d.alta_id
      Where c.ani_aniopre= x$ano And c.nen_codigo=v$nen_codigo
        And c.ent_codigo=v$ent_codigo And d.per_codcci=reg.codigo
        And ((c.estado in (1, 2, 25, 3) And nvl(d.estado, 'X') <> 'R' and NVL(d.recuperado, 'N') <> 'S') or (c.estado = 4 And d.fch_proceso is null))
        And rownum=1; --And c.alta_id <> v_alta_id ;
    exception
    when no_data_found then
      v_existe := 'N';
    when others then
      v_existe := 'N';
    end;
    v$tiene_cuenta:='false'; --modificado por SIAU 12001
    for reg1 in (Select pc.pec_descta, pc.per_codcci, ba.id as id_banco
                From a_pec@sinarh pc inner join banco ba on pc.ban_codigo=ba.codigo 
                Where pc.per_codcci=reg.codigo And pc.nen_codigo=v$nen_codigo 
                  And pc.ent_codigo=v$ent_codigo And pc.ani_aniopre=x$ano 
                  And pc.pec_activo='S') loop
      v$tiene_cuenta:='true';
      begin
        Update persona set cuenta_bancaria=reg1.pec_descta, banco=reg1.id_banco
        Where codigo=reg1.per_codcci;
      exception
      when no_data_found then
        v$tiene_cuenta:='false';
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar actualizar una cuenta existencia a la persona ci:' || reg1.per_codcci || ', mensaje:' || err_msg, true);
      end;
    end loop; --FIN modificado por SIAU 12001, se valida que si hay cuenta activa en sinarh, actualiza en persona sipen y no solicita otra cuenta FMA Tecnico
    if v_alta_id is not null And v_existe='N' And v$tiene_cuenta='false' then 
      begin            
        Select rpad(nvl(reg.codigo,' '),15,' ') || rpad(nvl(reg.primer_ape,' '),15,' ')|| rpad(nvl(reg.segundo_ape,' '), 15,' ')
              || rpad(' ',15,' ') || rpad(nvl(reg.primer_nom,' '),15,' ')|| rpad(nvl(reg.segundo_nom,' '),15,' ')|| rpad(nvl(reg.direccion,' '),30,' ') || rpad(' ',20,' ')
              || rpad(nvl(decode(reg.sexo,'6','FE','1','MA',null,null),' '),2,' ') || rpad(decode(reg.estado_civil,1,'SO',2,'CA',3,'DI',4,'VI',5,'SE',6,'EA',0,'SI'),2,' ') 
              || rpad(nvl(to_char(reg.fecha_nacimiento,'yyyymmdd'),' '),8,' ') ||   rpad(nvl(substr('PARAGUAY',1,2),' '),2,' ') || rpad(nvl(trim(null),' '),60,' ') 
              || rpad(nvl(trim(reg.telefono_linea_baja),' '),15,' ') || lpad(reg.monto,9,0 ) || lpad(v_alta_id,8,0) || lpad(v$nen_codigo,2,0) 
              || lpad(v$ent_codigo,3,0) || 'PENSIONADO         ' -- || rpad(substr(reg.departamento,1,19),20,' ') || rpad(substr(reg.distrito,1,39),40,' ')
            into x$per_linea_datos
        From dual;
        insert into a_pxbdet@SINARH(per_codcci, per_linea_datos, alta_id)
        values (reg.codigo, x$per_linea_datos, v_alta_id);
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar insertar en la tabla a_pxbdet@SINARH, mensaje:' || err_msg, true);
      end;
      begin
        v_id:=busca_clave_id;
        insert into solicitud_cuenta (id , version, codigo, nro_solicitud, cedula, fecha_solicitud, fecha_respuesta, banco, cuenta_bancaria, descripcion)
        values (v_id, 0, v_id, v$nro_solicitud, reg.codigo, sysdate, null, null, null, null);
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 200);
        raise_application_error(v$err, 'Error al intentar insertar la solicitud de cuenta, mensaje:' || err_msg, true);
      end;
      cantreg:=cantreg+1;
    end if;
    contador:=contador+1;
  end loop;
  if not SQL%FOUND then
    v$msg := 'Error: no existen solicitudes por procesar en al año:' ||x$ano;
    if x$edad_desde is not null then
      v$msg := v$msg || ', edad desde:' || x$edad_desde;
    end if;
    if x$edad_hasta is not null then
      v$msg := v$msg || ', edad hasta:' || x$edad_hasta;
    end if;
    if v$clase_pension_desde is not null then
      v$msg := v$msg || ', clase pensión desde:' || v$clase_pension_desde;
    end if;
    if v$clase_pension_hasta is not null then
      v$msg := v$msg || ', clase pensión hasta:' || v$clase_pension_hasta;
    end if;
    raise_application_error(v$err, v$msg, true);
  end if;
  if cantreg=0 then
    raise_application_error(v$err, 'Error: no hay registros por procesar para los filtros suministrados.');
  elsif cantreg>0 And v_alta_id is not null then
    Update a_pxbcab@SINARH set cant_reg=cantreg where alta_id=v_alta_id; 
  end if;
  return 0;
exception
  when others then
    raise_application_error(v$err, 'Error en el procedimiento Solicitar Cuenta, mensaje:' || sqlerrm);
 end;
 /