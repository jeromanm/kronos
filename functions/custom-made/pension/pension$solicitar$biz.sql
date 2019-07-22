create or replace function pension$solicitar$biz(x$super number, x$clase number, x$solicitante number, x$causante number, x$saldo_inicial number, x$numero_ley nvarchar2, x$fecha_conces date, x$monto_graciable number, x$mdn nvarchar2, x$fecha_mdn date, x$numero_sime number, x$validacion_estricta varchar2) return number is
	v$msg 							  nvarchar2(2000);
	v$err 							  constant number := -20000; -- an integer in the range -20000..-20999
	v$inserta_transicion 	number;
	v$estado_inicial     	number;
	v$estado_final       	number;
	v_id_pension         	number;
	err_num 							NUMBER;
	err_msg 							VARCHAR2(255);
  v$requiere_censo      VARCHAR2(5);
  v$cantidad            integer;
  v$tiene_objecion      VARCHAR2(5);
  v_cant_objecion       integer;
  v_id_ficha_persona    number;
  v_id_censo_persona    number;
  v$segmento            VARCHAR2(30);
  v$permiso_segmento    number;
  v$cant_segmento_pen   number;
  v$nombre_segmento     VARCHAR2(200);
  v$log rastro_proceso_temporal%ROWTYPE;
  v$indigena            VARCHAR2(5);
  -- solicitar pensión
begin
  --v$log := rastro_proceso_temporal$select();
  begin
    Select sp.id, sp.nombre
      into v$segmento, v$nombre_segmento
    From persona pe inner join clase_pension cp on cp.id=x$clase
      inner join segmento_pension sp on cp.grupo = sp.grupo And sp.distrito = pe.distrito
    where pe.id=x$solicitante;
  Exception
  WHEN NO_DATA_FOUND THEN
    v$segmento:=null;
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar obtener el segmento de la clase de pensión, mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  End;
  begin
    Select Count(b.id) into v$cant_segmento_pen 
    From usuario a inner join usuario_segmento_pension b on a.id_usuario=b.usuario
      inner join segmento_pension c on b.segmento_pension = c.id
    Where a.id_usuario = current_user_id;
  Exception
  WHEN NO_DATA_FOUND THEN
    v$cant_segmento_pen:=null;
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar obtener el segmento de la clase de pensión, mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  End;
  if x$numero_sime is not null And v$cant_segmento_pen>0 then
    raise_application_error(v$err, 'Error: no aplica asociar un número de sime para este tipo de solicitud de pensión.', true);
  elsif x$numero_sime is null And v$cant_segmento_pen=0 then
    raise_application_error(v$err, 'Error: debe asociar un número de sime para este tipo de solicitud de pensión.', true);
  end if;
  begin
    Select Count(b.id) into v$permiso_segmento 
    From usuario a inner join usuario_segmento_pension b on a.id_usuario=b.usuario
      inner join segmento_pension c on b.segmento_pension = c.id
    Where a.id_usuario = current_user_id And b.segmento_pension=v$segmento;
  Exception
  WHEN NO_DATA_FOUND THEN
    v$permiso_segmento:=null;
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar obtener el segmento de la clase de pensión, mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  End;
  if v$permiso_segmento=0 And v$cant_segmento_pen>0 then
    raise_application_error(v$err, 'Error: el usuario no tiene permiso sobre el segmento de la pensión:' || v$nombre_segmento, true);
  end if;
  begin
    Select Count(pn.id) into v$cantidad 
    From pension pn 
    Where pn.estado<>2 And pn.clase=x$clase And pn.persona=x$solicitante;
  Exception
  WHEN NO_DATA_FOUND THEN
    v$cantidad:=0;
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar obtener pension anterior para la misma clase, mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  End;
  if v$cantidad>0 then
    raise_application_error(v$err, 'Error: ya tiene una solicitud de pensión para la clase suministrada.', true);
  end if;
  begin
    Select requiere_censo into v$requiere_censo 
    From clase_pension Where id=x$clase;
  Exception
  WHEN NO_DATA_FOUND THEN
    v$msg := util.format(util.gettext('Error: no se consiguen datos de la clase de pensión ingresada.'));
		raise_application_error(v$err, v$msg, true);
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar obtener el tipo de la clase de pensión, mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  End;
  Select Count(pe.id) into v$cantidad
  From clase_pension cp inner join pension pn on cp.id = pn.clase
    inner join persona pe on pn.causante = pe.id
  Where cp.requiere_causante='true' And cp.pago_unico='true'
    And pn.estado not in (2,5,9) And cp.id=x$clase 
    And pe.id=x$causante;
  if v$cantidad>1 then
    v$msg := util.format(util.gettext('Error: el concepto de la pensión solicitada, ya está asociado al causante seleccionado, debe ser único.'));
		raise_application_error(v$err, v$msg, true);
  end if;
  Select indigena into v$indigena From persona where id=x$solicitante;
	v_id_pension := busca_clave_id;
	insert into pension (id, version, codigo, clase, persona, causante, numero_sime, saldo_inicial, FECHA_TRANSICION, USUARIO_TRANSICION, 
                      NUMERO_LEY, FECHA_CONCES, MONTO_GRACIABLE, MDN, FECHA_MDN)
	values (v_id_pension, 0, v_id_pension, x$clase, x$solicitante, x$causante, x$numero_sime, x$saldo_inicial, sysdate, CURRENT_USER_ID,
                      x$numero_ley, x$fecha_conces, x$monto_graciable, x$mdn, x$fecha_mdn);
	v$estado_inicial := 1;
	v$estado_final   := 1;
	v$inserta_transicion := transicion_pension$biz(v_id_pension, current_date, current_user_id(), v$estado_inicial, v$estado_final,
                                                 null, null, null, null, null, null, null, null, null);
	if not SQL%FOUND then
		v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pensión', 'id', v_id_pension);
		raise_application_error(v$err, v$msg, true);
	end if;
  if v$requiere_censo='true' And v$indigena='false' then
    v$inserta_transicion:=pension$verificar$biz(x$super, v_id_pension, 'true');
    begin
      Select pn.tiene_objecion, Count(op.id) 
        into v$tiene_objecion, v_cant_objecion 
      From pension pn left outer join objecion_pension op on pn.id = op.pension And op.objecion_invalida='true' 
      Where pn.id=v_id_pension
      Group By pn.estado, pn.tiene_objecion;
    exception
    when no_data_found then
      v$tiene_objecion:='false'; v_cant_objecion:=0;
    when others then
      v$tiene_objecion:='false'; v_cant_objecion:=0;
    end;
    if v_cant_objecion=0 And v$tiene_objecion='false' then
      begin
        v_id_ficha_persona := busca_clave_id;
        INSERT INTO FICHA_PERSONA (ID, VERSION, CODIGO, NOMBRE, NOMBRES, APELLIDOS, EDAD, 
                                  SEXO_PERSONA, TIPO_PERSONA_HOGAR, MIEMBRO_HOGAR, NUMERO_ORDEN_IDENTIFICACION,
                                  NUMERO_CEDULA, FECHA_NACIMIENTO, NUMERO_TELEFONO, ESTADO_CIVIL)
          Select v_id_ficha_persona, 0, v_id_ficha_persona, nombre, nombres, apellidos, calcular_edad(fecha_nacimiento),
                sexo, 1, 'true', 1, 
                codigo, fecha_nacimiento, TELEFONO_LINEA_BAJA, estado_civil
          From persona Where id=x$solicitante;
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 300);
        raise_application_error(v$err, 'Error al intentar crear el registro de ficha persona, mensaje:' || v$msg, true);
      end;
      begin
        v_id_censo_persona := busca_clave_id;
        INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA, DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO, DIRECCION, 
                                  NUMERO_TELEFONO, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION)
          Select v_id_censo_persona, 0, v_id_censo_persona, pe.id, sysdate, v_id_ficha_persona, pe.departamento, pe.distrito, pe.tipo_area, pe.barrio, pe.direccion,
                 pe.TELEFONO_LINEA_BAJA, 1, sysdate, CURRENT_USER_ID
          From persona pe 
          Where pe.id=x$solicitante;
        Update persona set ficha=v_id_ficha_persona Where id=x$solicitante;
      exception
      when others then
        err_msg := SUBSTR(SQLERRM, 1, 300);
        raise_application_error(v$err, 'Error al intentar crear el registro de censo persona, mensaje:' || v$msg, true);
      end;
    end if;
  end if;
	return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(v$err, err_msg, true);
end;
/
