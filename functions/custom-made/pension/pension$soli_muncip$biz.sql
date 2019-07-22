create or replace function pension$soli_muncip$biz(x$super number, x$cedula number, x$apodo nvarchar2, x$departamento number, x$distrito number, x$barrio number, 
                                                    x$direccion nvarchar2, x$referencia nvarchar2, x$referente nvarchar2, x$telefono_referente nvarchar2, 
                                                    x$telefono_linea_baja nvarchar2, x$telefono_celular nvarchar2, x$eliminar_censo varchar2) return number is
  v$err                 constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                 nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$log                 rastro_proceso_temporal%ROWTYPE;
  err_num 							NUMBER;
	err_msg 							VARCHAR2(255);
  v$estado_pension      integer:=0;
  v$des_estado          VARCHAR2(30);
  v$departamento        number:=null;
  v$distrito            number:=null;
  v$clase_pension       number:=150498912213505560; --AM
  v$persona             number;
  v$fecha_defuncion     date:=null;
  v$paraguayo           varchar2(5):='false';
  v$inserta_transicion 	number;
	v$estado_inicial     	number:=1;
	v$estado_final       	number:=1;
	v$id_pension         	number:=null;
  v$tiene_objecion      VARCHAR2(5);
  v$cant_objecion       integer;
  v$id_censo_persona    number;
  v$periodo_validez_censo number;
  v$max_censo_periodo     number;
  v$cant_censos         number:=0;
  v$cedula              varchar2(20);
  v$tipo_area           number;
  v$boldistrito         varchar2(5):=null;
  v$nombre              varchar2(100);
  v$objeciones          varchar2(4000);
begin --  Pension.soliMuncip - business logic
  v$log := rastro_proceso_temporal$select();
  Select numero, nombre into v$cedula, v$nombre From cedula where id=x$cedula;
  begin
    update rastro_proceso set codigo_recurso = v$cedula, nombre_recurso = v$nombre
    where	id_rastro_proceso = x$super;
    commit;
    rastro_proceso_temporal$revive(v$log);
  exception
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar actualizar el rastro proceso, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  end;
  begin
    Select sp.distrito, dt.departamento, ba.tipo_area
    into v$distrito, v$departamento, v$tipo_area
     From usuario us inner join usuario_segmento_pension up on us.id_usuario=up.usuario
      inner join segmento_pension sp on up.segmento_pension = sp.id
      inner join distrito dt on sp.distrito = dt.id
      left outer join barrio ba on ba.distrito = dt.id And ba.id=x$barrio
    Where us.id_usuario = current_user_id;
  Exception
  WHEN NO_DATA_FOUND THEN
    v$departamento:=null; v$distrito:=null;
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar obtener el segmento asociado al usuario, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  End;
  if v$departamento is null or v$distrito is null then
    raise_application_error(v$err, 'Error: no se encuentran datos del distrito asociado al usuario, cédula solicitud:' || v$cedula, true);
  end if;
  if v$distrito<>x$distrito then
    raise_application_error(v$err, 'Error: el usuario no corresponde al distrito, cédula solicitud:' || v$cedula, true);
  end if;
  Begin
    Select pe.id, pe.fecha_defuncion into v$persona, v$fecha_defuncion 
    From persona pe Where pe.cedula=x$cedula;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v$fecha_defuncion:=null;v$persona:=null;
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar verificar si existe un registro de persona para la cédula introducida ' || v$cedula || ', mensaje:' || v$msg));
		raise_application_error(v$err, v$msg, true);
  End;
  if v$fecha_defuncion is not null then
     v$msg := util.format(util.gettext('Error: la persona asociada a la cédula introducida (' || v$cedula || ') esta registrada como fallecida.'));
     raise_application_error(v$err, v$msg, true);
  end if;
  Select valor into v$periodo_validez_censo From variable_global where numero=101; --Periodo de validez de censo en aóos
  Select valor into v$max_censo_periodo From variable_global where numero=102;--Móximo número de censos por periodo
  v$cant_censos:=0;
  For reg in (Select * From censo_persona Where persona=v$persona And estado=1) loop
    if x$distrito = reg.distrito then
      --v$msg := util.format(util.gettext('Error: la persona asociada a la cédula (' || v$cedula || ') tiene registros de censos en estado pendiente en el mismo distrito.'));
      --raise_application_error(v$err, v$msg, true);
      v$boldistrito:='true';
    elsif x$eliminar_censo='true' And x$distrito <> reg.distrito then
      begin
        Update censo_persona set estado=5, COMENTARIOS='Anulado por solicitud de pensión en otro distrito' 
        Where persona=v$persona And estado=1;
      EXCEPTION
      when others then
        v$msg := SQLERRM;
        v$msg := util.format(util.gettext('Error al intentar anular el registro de censo en estado pendiente de otro distrito, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
        raise_application_error(v$err, v$msg, true);
      End;
      v$boldistrito:='false';
    elsif nvl(x$eliminar_censo,'false')<>'true' And x$distrito <> reg.distrito then
      v$msg := util.format(util.gettext('Error: la persona asociada a la cédula tiene registros de censos en estado pendiente, en otro distrito, cédula solicitud:' || v$cedula));
      raise_application_error(v$err, v$msg, true);
      v$boldistrito:='false';
    end if;
  end loop;
  v$cant_censos:=0;
  begin
    Select Count(distinct(cp.id)) into v$cant_censos
    From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
      left outer join ficha_hogar fh on fp.ficha_hogar = fh.id
      left outer join ficha_persona fp2 on fh.id = fp2.ficha_hogar And fp.id<>fp2.id And fp2.ficha_hogar<>fp.ficha_hogar
    Where (fp.numero_cedula=v$cedula or fp2.numero_cedula=v$cedula)
            And cp.fecha between ADD_MONTHS(sysdate,((v$periodo_validez_censo*12)*-1)) And sysdate;
  exception
  WHEN NO_DATA_FOUND THEN
    v$cant_censos:=0;
  when others then
    v$msg := SQLERRM;
    v$msg := util.format(util.gettext('Error al intentar obtener la cantidad de censos asociados a la persona, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
    raise_application_error(v$err, v$msg, true);
  end;
  if (v$cant_censos >v$max_censo_periodo) then
    v$msg := util.format(util.gettext('Error: la persona asociada a la cédula (' || v$cedula || ') ha superado la cantidad de censos permitidos en el período.'));
    raise_application_error(v$err, v$msg, true);
  end if;
  v$estado_pension:=0;
  For reg in (Select pn.id, pn.estado, ep.codigo 
              From pension pn inner join persona pe on pn.persona = pe.id
                 inner join estado_pension ep on pn.estado = ep.numero
              Where pn.clase=v$clase_pension And pe.cedula=x$cedula Order by pn.id desc) loop
    v$estado_pension:=reg.estado;
    v$des_estado:=reg.codigo;
    v$id_pension:=reg.id;
    exit;
  End loop;
  if v$persona is null then
    for reg in (Select * From cedula Where id=x$cedula) loop
      if reg.nacionalidad=226 then
        v$paraguayo:='true';
      else
        v$msg := util.format(util.gettext('Error: la persona asociada a la cédula (' || v$cedula || ') introducida no está regitrada como Paraguayo en identificación.'));
        raise_application_error(v$err, v$msg, true);
      end if;
      Begin
        v$persona:=busca_clave_id;
		    insert into persona (id, version, codigo, nombre, apellidos, nombres, fecha_nacimiento, sexo, estado_civil, paraguayo,
                            cedula, indigena, departamento, distrito, monitoreado, monitoreo_sorteo, edicion_restringida, direccion,
                            barrio, tipo_area, etnia, comunidad, telefono_linea_baja, telefono_celular,
                            nombre_referente , apodo, referencia, telefono_referente)
                  values (v$persona, 0, reg.numero, reg.nombre, reg.apellidos, reg.nombres, reg.FECH_NACIM, reg.sexo, reg.estado_civil, v$paraguayo,
                          x$cedula, 'false', v$departamento, v$distrito, 'false', 'false', 'true', x$direccion,
                          x$barrio, v$tipo_area, null, null, x$telefono_linea_baja, x$telefono_celular,
                          x$referente, x$apodo, x$referencia, x$telefono_referente);
      EXCEPTION
      when others then
        v$msg := SQLERRM;
        v$msg := util.format(util.gettext('Error al intentar crear el registro de persona, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
        raise_application_error(v$err, v$msg, true);
      End;
      v$cedula:=reg.numero;
      exit;
    end loop;
  else
    begin
      Update persona set departamento=x$departamento, distrito=x$distrito, barrio=x$barrio, tipo_area=v$tipo_area, direccion=x$direccion,
                      nombre_referente=x$referente , apodo=x$apodo, referencia=x$referencia, telefono_referente=x$telefono_referente,
                      telefono_linea_baja=x$telefono_linea_baja, telefono_celular=x$telefono_celular
      Where id=v$persona;
    EXCEPTION
    when others then
      v$msg := SQLERRM;
      v$msg := util.format(util.gettext('Error al intentar actualizar el registro de persona, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
      raise_application_error(v$err, v$msg, true);
    End;
  end if;
  if x$eliminar_censo='true' And v$boldistrito='false' then --solo se anula pension existente si es de distrito es igual
    begin
      Select id into v$id_pension From pension Where persona=v$persona And estado=1 And clase=v$clase_pension;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v$id_pension:=null;
    when others then
      v$msg := SQLERRM;
      v$msg := util.format(util.gettext('Error al intentar obtener el registro de solicitud de pensión, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
      raise_application_error(v$err, v$msg, true);
    End;
    if v$id_pension is not null then
      begin
        Update pension set estado=2, COMENTARIOS=substr(COMENTARIOS || ', anulado por solicitud de pensión en otro distrito',1,200) 
        where id=v$id_pension;
        v$inserta_transicion := transicion_pension$biz(v$id_pension, current_date, current_user_id(), 1, 2,
                                                    'Anulado por solicitud de pensión en otro distrito', null, null, null, null, null, null, null, null);
      EXCEPTION
      when others then
        v$msg := SQLERRM;
        v$msg := util.format(util.gettext('Error al intentar anular el registro de solicitud de pensión, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
        raise_application_error(v$err, v$msg, true);
      End;
    end if;
  --else
  --  if v$estado_pension>0 then
  --    raise_application_error(v$err, 'Error: ya tiene una solicitud de pensión, cédula solicitud:' || v$cedula, true);
  --  end if;
  end if;
  if v$estado_pension>2 then
    raise_application_error(v$err, 'Error la ci ' || v$cedula || ' tiene pensión en estado:' || v$des_estado, true);
  end if;
  if v$estado_pension=0 or v$estado_pension=2 then --no hay pension en estado pendiente de AM o esta anulada
    begin
      v$id_pension := busca_clave_id;
      insert into pension (id, version, codigo, clase, persona, estado, FECHA_TRANSICION, USUARIO_TRANSICION)
      values (v$id_pension, 0, v$id_pension, v$clase_pension, v$persona, v$estado_inicial, sysdate, CURRENT_USER_ID);
    EXCEPTION
    when others then
      v$msg := SQLERRM;
      v$msg := util.format(util.gettext('Error al intentar crear el registro de la solicitud de pensión, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
      raise_application_error(v$err, v$msg, true);
    End;
    v$inserta_transicion := transicion_pension$biz(v$id_pension, current_date, current_user_id(), v$estado_inicial, v$estado_final,
                                                    null, null, null, null, null, null, null, null, null);
    v$inserta_transicion:=pension$verificar$biz(x$super, v$id_pension, 'true');
    
  end if;
  if v$id_pension is not null then
    begin
      Select pn.tiene_objecion, Count(op.id) 
        into v$tiene_objecion, v$cant_objecion 
      From pension pn left outer join objecion_pension op on pn.id = op.pension And op.objecion_invalida='true' 
      Where pn.id=v$id_pension
      Group By pn.estado, pn.tiene_objecion;
    exception
    when no_data_found then
      v$tiene_objecion:='false'; v$cant_objecion:=0;
    when others then
      v$tiene_objecion:='false'; v$cant_objecion:=0;
    end;
  end if;
  
  if v$tiene_objecion = 'true' then
    begin
      select wm_concat(to_char(rcp.nombre)) into v$objeciones
      from objecion_pension op inner join regla_clase_pension rcp on op.regla = rcp.id
      where op.pension = v$id_pension
      and op.objecion_invalida='true'
      ;
    exception
      when others then
        null;
    end;
    raise_application_error(v$err, substr('La cedula ' || v$cedula || ' tiene objeciones: ' || trim(v$objeciones) || v$msg,1,512), true);
  end if;
    
  
  if (
      (v$boldistrito is null --no existe censo en estado pendiente
      or (x$eliminar_censo='true' And v$boldistrito='false') --tiene censo pendiente de diferente distrito, se anula el anterior y se debe crear uno nuevo
     ) And (v$cant_objecion=0 And v$tiene_objecion='false') -- la pension solicitada no esta objetada por elegibilidad
     ) then
    begin
      v$id_censo_persona := busca_clave_id;
      INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA, DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO, DIRECCION, 
                                 NUMERO_TELEFONO, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION)
      values (v$id_censo_persona, 0, v$id_censo_persona, v$persona, to_date('01/01/1900','dd/mm/yyyy'), null, v$departamento, v$distrito, v$tipo_area, x$barrio, x$direccion,
              x$telefono_linea_baja, 1, sysdate, CURRENT_USER_ID);
    exception
    when others then
     err_msg := SUBSTR(SQLERRM, 1, 300);
     raise_application_error(v$err, 'Error al intentar crear el registro de censo persona, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg, true);
    end;
  elsif  v$boldistrito='true' then --si tiene censo pendiente y esta en el mismo distrito actualizamos sus datos
    v$id_censo_persona:=null;
    begin --buscamo si hay registro de censo pendiente para actualizar sus datos
      Select id into v$id_censo_persona From censo_persona where persona=v$persona And estado=1 And rownum=1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v$id_censo_persona:=null;
    when others then
      v$msg := SQLERRM;
      v$msg := util.format(util.gettext('Error al intentar obtener el registro de censo pendiente para el mismo distrito, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg));
      raise_application_error(v$err, v$msg, true);
    End;
    if v$id_censo_persona is not null then
      begin
        Update CENSO_PERSONA set TIPO_AREA=v$tipo_area, BARRIO=x$barrio, DIRECCION=x$direccion, NUMERO_TELEFONO=x$telefono_linea_baja, 
                                fecha=to_date('01/01/1900','dd/mm/yyyy'), FECHA_TRANSICION=sysdate, USUARIO_TRANSICION=CURRENT_USER_ID
        Where id=v$id_censo_persona;
      exception
      when others then
       err_msg := SUBSTR(SQLERRM, 1, 300);
       raise_application_error(v$err, 'Error al intentar actualizar el registro de censo en estado pendiente para el mismo distrito, cédula solicitud:' || v$cedula || ', mensaje:' || v$msg, true);
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
