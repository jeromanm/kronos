create or replace function pension$verificar$biz(x$super number, x$pension number, x$especial varchar2) return number is
  v$err                     constant number := -20000; -- an integer in the range -20000..-20999
  my_code                   number;
  v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_num 					        NUMBER;
  err_msg 					        VARCHAR2(255);
  v$log rastro_proceso_temporal%ROWTYPE;
  v$id                      number:=0;
  v$nombre_regla            VARCHAR2(100);
  v$id_regla_clase_pension  number;
  v$tiene_denuncia          varchar(5):='false';
  v$tiene_reclamo           varchar(5):='false';
  v$tiene_objecion          number:=0;
  v$falta_requisito         varchar(5):='false';
  v$observacion             VARCHAR2(2000);
  v$cantidad                number;
  v$cumple_regla            varchar(5):='';
  v$condicion               varchar(50):='';
  v$sql                     VARCHAR2(2000);
  v$requiere_censo          varchar(5):='';
  v$estado                  number;
  v$objecion_menor          varchar(5):='false';
  v$clase_pension           number;
  regla_falta_requisito     number:=null;
  regla_tiene_tramite       number:=null;
  regla_tiene_denuncia      number:=null;
  v$edad                    integer;
  v$especial                varchar(5):='';
  v$porc_nombres            number;
  v$porc_nombre             number;
  v$porc_apellido           number;
  v$edo_pension             number;
  v$activa                  varchar(5):='';
begin
  v$log := rastro_proceso_temporal$select();
  begin
    Select cp.requiere_censo, pn.estado, pe.objecion_menor, cp.id, calcular_edad(pe.fecha_nacimiento)
      into v$requiere_censo, v$estado, v$objecion_menor, v$clase_pension, v$edad
    From pension pn inner join clase_pension cp on pn.clase = cp.id
      inner join persona pe on pn.persona = pe.id
  	Where pn.id=x$pension;
  exception
  when no_data_found then
		raise_application_error(v$err, 'Error: no se pudo obtener el estatus de la pensión, registro no encontrado.', true);
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar obtener el estatus de la pensión, mensaje:' || v$msg, true);
  end;
  if x$especial is null then
    v$especial:='false';
  else
    v$especial:=x$especial;
  end if;
	For rec in (Select pe.sexo, pe.estado_civil, pe.objecion_menor, pe.paraguayo, pe.indigena, nvl(pe.icv,0) as icv, pe.codigo as cedulapersona,
                     pe.tipo_area, nvl(pe.tipo_pobreza,0) as tipo_pobreza, re.nombre, rp.regla, rp.id as id_regla_clase_pension, re.variable_x1 as variable, dp.region, 
                     re.valor_x1, pe.nombres || ' ' || pe.apellidos as nombre_identificacion, pn.estado as edo_pension, pn.activa, 
                    (Select cp.id From censo_persona cp 
                     Where cp.persona = pe.id And cp.fecha=(Select max(cp2.fecha) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4) 
                        And cp.fecha_transicion=(Select max(cp2.fecha_transicion) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4)
                        And rownum=1 And cp.estado=4) as id_censo, nvl(pn.permite_jupe,'false') as permite_jupe, nvl(pn.permite_sinarh,'false') as permite_sinarh 
              From pension pn inner join persona pe on pn.persona = pe.id
                inner join regla_clase_pension rp on pn.clase = rp.clase_pension And rp.activo='true'
                inner join regla re on rp.regla = re.id
                inner join departamento dp on pe.departamento = dp.id
              Where pn.id=x$pension And (v$especial='false' or re.especial=v$especial)) loop
    begin
      Update objecion_pension set OBJECION_INVALIDA='false', observaciones='Anulado por proceso automatico'
      Where pension = x$pension And regla=rec.id_regla_clase_pension And OBJECION_INVALIDA='true'; -- se colocan las objecciones anteriores, si existen, como false(no vigentes)
    exception
		when no_data_found then
			null;
		when others then
			v$msg:=substr(SQLERRM,1,2000);
      raise_application_error(v$err, 'Error al intentar actualizar la objeción de pensión, mensaje:' || v$msg, true);
		end;
    v$cantidad:=null; v$cumple_regla:=null; v$edo_pension:= rec.edo_pension; v$activa:=rec.activa;
    case
    when rec.variable=101	And rec.valor_x1<>18 then --Edad, no se toma en cuenta la validacion de mayor de edad, esta regla se valida al final
      v$cantidad:=v$edad;
      v$observacion:='Edad:' || v$edad || ' años.';
    when rec.variable=102	then --Sexo
      v$cantidad:=rec.sexo;
      v$observacion:='Código Sexo:' || rec.sexo;
    when rec.variable=103	then --Estado civil
      v$cantidad:=rec.estado_civil;
      v$observacion:='Código Estado Civil:' || rec.estado_civil;
    when rec.variable=104	then --Region
      v$cantidad:=rec.region;
      v$observacion:='Código Región:' || rec.region;
    when rec.variable=105	then --Tipo area
      v$cantidad:=rec.tipo_area;
      v$observacion:='Código Tipo Área:' || rec.tipo_area;
    when rec.variable=106	then --Tipo pobreza
      v$cantidad:=rec.tipo_pobreza;
      v$observacion:='Tipo Pobreza:' || rec.tipo_pobreza;
    when rec.variable=107	then --Paraguayo
      v$cumple_regla:=rec.paraguayo;
      v$observacion:='Es Paraguayo:' || rec.paraguayo;
    when rec.variable=108	then --Indigena
      v$cumple_regla:=rec.indigena;
      v$observacion:='Es Indígena:' || rec.indigena;
    when rec.variable=109	then --Fallecido
      cumple_fallecido(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
      if v$cantidad>0 or v$cumple_regla='true' then
        begin
          v$id:=pension$calcul_liqui$22804$biz(x$super, x$pension, null, null);
        exception
        when others then
          my_code := SQLCODE;
          --if my_code=-20100 then
            null;
          --else
          --   v$msg:=substr(SQLERRM,1,2000);
          --   raise_application_error(v$err, 'Error al intentar calcular liquidación de cobro indebido, mensaje:' || v$msg, true);
          --end if;
        end;
      end if;
    when rec.variable=110	then --Monitoreado
      null;
    when rec.variable=111 then --Discapacitado
      cumple_discapacidad(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion);
    when rec.variable=112 then --Empleado
      cumple_empleado(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=113 then --Jubilado
      cumple_jubilacion(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=114 then --Pension Externa
      v$observacion:='Carga de Archivo suprimida a petición del cliente. Mayo 2018';
    when rec.variable=115 then --Posee vehiculo
      cumple_automotor(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=116 then --Es proveedor
      cumple_proveedor(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=117 then --Valor inmueble
      cumple_catastro(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=118 then --Tiene hijos
      cumple_nacimiento(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=119 then --Esta casado a
      cumple_matrimonio(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=120 then --	Cantidad de semovientes
      cumple_senacsa(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=121 then --Subsidio
      cumple_subsidio(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=122 then --No indigena
      cumple_no_indigena(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=123 then --Residente en extranjero
      cumple_residente_extranjero(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=124	then
      if rec.permite_jupe='false' then
        existe_jupe(x$pension, rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion);
      end if;
    when rec.variable=125 then
      if rec.permite_sinarh='false' then
        existe_sinarh(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion);
      end if;
    when rec.variable=126 then --Falta Requisito
      begin
        Select a.id into regla_falta_requisito
        From regla_clase_pension a inner join regla b on a.regla = b.id And a.clase_pension=v$clase_pension
        Where b.variable_x1=rec.variable And a.activo='true' And rownum=1;
      exception
      when no_data_found then
        regla_falta_requisito:=null;
      when others then
        regla_falta_requisito:=null;
        v$msg:=substr(SQLERRM,1,2000);
        raise_application_error(v$err, 'Error al intentar obtener el código de la regla de falta requisito, mensaje:' || v$msg, true);
      end;
    when rec.variable=127	then --Tiene Trámite Pendiente
      begin
        Select a.id into regla_tiene_tramite
        From regla_clase_pension a inner join regla b on a.regla = b.id  And a.clase_pension=v$clase_pension
        Where b.variable_x1=rec.variable And a.activo='true' And rownum=1;
      exception
      when no_data_found then
        regla_tiene_tramite:=null;
      when others then
        regla_tiene_tramite:=null;
        v$msg:=substr(SQLERRM,1,2000);
        raise_application_error(v$err, 'Error al intentar obtener el código de la regla de tiene trámite pendiente, mensaje:' || v$msg, true);
      end;
    when rec.variable=128	then --Tiene Denuncia
      begin
        Select a.id into regla_tiene_denuncia
        From regla_clase_pension a inner join regla b on a.regla = b.id  And a.clase_pension=v$clase_pension
        Where b.variable_x1=rec.variable And a.activo='true';
      exception
      when no_data_found then
        regla_tiene_denuncia:=null;
      when others then
        regla_tiene_denuncia:=null;
        v$msg:=substr(SQLERRM,1,2000);
        raise_application_error(v$err, 'Error al intentar obtener el código de la regla de tiene denuncia, mensaje:' || v$msg, true);
      end;
    when rec.variable=129 then --Estado Ficha Hogar
      if v$requiere_censo='true' And rec.indigena='false' then
        verificar_ficha_hogar(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion);
      else
        v$cumple_regla:='false';v$cantidad:=4;
      end if;
    when rec.variable=130 then --Cotizante
      cumple_cotizante(rec.cedulapersona, v$cantidad, v$cumple_regla, v$observacion, rec.nombre_identificacion, x$pension, rec.id_regla_clase_pension);
    when rec.variable=131	 then --Existe en Sipen
      existe_sipen(rec.cedulapersona, v$clase_pension, x$pension, v$cantidad, v$cumple_regla, v$observacion);
    when rec.variable=133	then --cumple plazo reconsideracion 
      cumple_plazo(x$pension, v$cantidad, v$observacion);
    when rec.variable=134	then --regla administrativa 
      cumple_regla_administrativa(x$pension, v$cantidad, v$observacion);
    when rec.variable=135	then --lapso presentacion fecha ministerio defensa, sepelio 
      cumple_fecha_sepelio(x$pension, v$cantidad, v$observacion); 
    when rec.variable=901 then --ICV
      cumple_icv(x$pension, rec.id_censo, v$cantidad, v$cumple_regla, v$observacion);
    end case;
    if rec.variable=901 then
      null;
    else
      if v$cantidad is not null or v$cumple_regla is not null then
        begin
          Select case va.tipo_dato
                  when 1 then to_char(v$cantidad || ' ' || oc.simbolo || ' ' || re.valor_x1)
                  when 2 then to_char(v$cantidad || ' ' || oc.simbolo || ' ' || re.valor_x1)
                  when 3 then  case when oc.simbolo=':F' then chr(39) || v$cumple_regla || chr(39) || '=' || chr(39) || 'false' || chr(39) else chr(39) || v$cumple_regla || chr(39) || '=' || chr(39) || 'true' || chr(39) end
                  end into v$condicion
          From regla re inner join operador_comparacion oc on re.operador_x1 = oc.numero
            inner join variable va on re.variable_x1 = va.numero
          Where re.id=rec.regla And rownum=1;
        exception
        when no_data_found then
          v$condicion:=null;
        when others then
          v$msg:=substr(SQLERRM,1,2000);
          raise_application_error(v$err, 'Error al intentar obtener la regla, mensaje:' || v$msg, true);
        end;
        v$cumple_regla:=null;
          Begin
            v$sql:='Select case when ' || v$condicion || ' then ' || chr(39) || 'true' || chr(39) || ' else ' || chr(39) || 'false' || chr(39) || ' end From dual';
            execute immediate v$sql into v$cumple_regla;
          Exception
          when no_data_found then
            v$cumple_regla:='false';
          when others then
            v$msg:=substr(SQLERRM,1,2000);
            raise_application_error(v$err, 'Error al intentar obtener el resultado de la evaluación de la regla (' || v$sql || '), mensaje:' || v$msg, true);
          end;
      end if;
    end if;
    if (v$cumple_regla = 'true') THEN
        v$id:=busca_clave_id;
        insert into objecion_pension(ID, VERSION, CODIGO, PENSION, REGLA, OBJECION_INVALIDA, FECHA_TRANSICION, OBSERVACIONES, COMENTARIOS, USUARIO_TRANSICION)
                  values(v$id, 0, v$id, x$pension, rec.id_regla_clase_pension, 'true', SYSDATE(), v$observacion, rec.nombre, CURRENT_USER_ID);
        v$tiene_objecion:=v$tiene_objecion+1;
    end if;
	end loop; --Fin reglas asociadas a la clase pension del tipo especial=x$especial
  if v$objecion_menor='true' And v$edad>=18 then --persona que debe ser objetada si cumple mayoria de edad
    begin
      Select b.id, a.nombre
        into v$id_regla_clase_pension, v$nombre_regla
      From regla a inner join regla_clase_pension b on a.id=b.regla And b.activo='true'
      where a.VARIABLE_X1 = 101 And a.valor_x1=18 
        And clase_pension=v$clase_pension And rownum=1
      Order by b.nombre desc;
    exception
    when no_data_found then
      v$id_regla_clase_pension:=null; v$nombre_regla:='';
    when others then
      v$msg:=substr(SQLERRM,1,2000);
      raise_application_error(v$err, 'Error al intentar obtener la regla del menor, mensaje:' || v$msg, true);
    end;
    if v$id_regla_clase_pension is not null then
      v$id:=busca_clave_id;
      insert into objecion_pension(ID,VERSION,CODIGO,PENSION, REGLA,OBJECION_INVALIDA, FECHA_TRANSICION, OBSERVACIONES, COMENTARIOS, USUARIO_TRANSICION)
          values(v$id, 0, v$id, x$pension, v$id_regla_clase_pension, 'true', SYSDATE(), 'Edad:' || v$edad, v$nombre_regla, CURRENT_USER_ID);
      v$tiene_objecion:=v$tiene_objecion+1;
    end if;
  end if;
  if regla_falta_requisito is not null then
    if v$edo_pension=7 And v$activa='true' then  --no validar falta de requisitos para pensiones activas SIAU 12221
      v$falta_requisito:='false';
    else
      v$falta_requisito:=falta_requisito(x$pension, regla_falta_requisito);
    end if;
    if (v$falta_requisito='true') then
      update pension set falta_requisito = 'true' where id =x$pension;
      v$tiene_objecion:=v$tiene_objecion+1;
    else
      update pension set falta_requisito = 'false' where id =x$pension;
    end if;
  end if;
  if regla_tiene_tramite is not null then
    v$tiene_reclamo:=existe_reclamo(x$pension, regla_tiene_tramite);
    if (v$tiene_reclamo='true') then
      update pension set tiene_reclamo = 'true' where id =x$pension;
      v$tiene_objecion:=v$tiene_objecion+1;
    else
      update pension set tiene_reclamo = 'false' where id =x$pension;
    end if;
  end if;
  if regla_tiene_denuncia is not null then
    v$tiene_denuncia:=existe_denuncia(x$pension, regla_tiene_denuncia);
    if (v$tiene_denuncia='true') then
  		update pension set tiene_denuncia = 'true' where id =x$pension;
      v$tiene_objecion:=v$tiene_objecion+1;
    else
      update pension set tiene_denuncia = 'false' where id =x$pension;
    end if;
  end if;
	if v$tiene_reclamo='true' or v$tiene_denuncia='true' or v$falta_requisito='true' or v$tiene_objecion>0 then
		update pension set tiene_objecion = 'true',fecha_irregular=sysdate, irregular='true' where id =x$pension;
  else
    update pension set tiene_objecion = 'false',fecha_irregular=null, irregular='false' where id =x$pension;
	end if;
	if v$tiene_objecion=0 And v$requiere_censo='false' And v$estado=1 then --no tiene objecion y la pensión no requiere censo, se acredita
		update pension set estado=3 where id=x$pension;
    v$id := transicion_pension$biz(x$pension, current_date, current_user_id(),1, 3, null, null,'Pensión acreditada en elegibilidad', null, null, null, null, null, null);
	end if;
	return 0;
EXCEPTION
  WHEN OTHERS THEN
    err_num := SQLCODE;
		err_msg := SQLERRM;
		raise_application_error(v$err, 'Error en elegibilidad, mensaje:'|| sqlerrm, true);
end;
/