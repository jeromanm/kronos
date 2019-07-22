create or replace function ficha_hogar_persona_censo(p_cedula varchar2)
  return number is
  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg                        nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xid                        raw(8);
  v$log                        rastro_proceso_temporal%ROWTYPE;
  err_num                      NUMBER;
  err_msg                      VARCHAR2(5000);
  v_id_ficha_hogar             number;
  v_version_ficha_hogar        VARCHAR2(50);
  v_id_ficha_persona           number;
  v_codigo_ficha_persona       VARCHAR2(40);
  v_id_censo_persona           number;
  v_periodo_validez            number(16, 4);
  v_nro_censos                 number(16, 4);
  v_cant_censos                number;
  v_anio                       varchar2(4);
  v_id_pregunta                number;
  v_id_respuesta_ficha_hogar   number;
  v_id_respuesta_ficha_persona number;
  v_tipo_dato_respuesta        number;
  v_id_rango_respuesta         number;
  v_codigo                     varchar2(100);
  v_numero_sime_tutelaje       varchar2(30);
  v_departamento               varchar2(10);
  v_id_departamento            number;
  v_distrito                   varchar2(10);
  v_id_distrito                number;
  v_barrio                     varchar2(10);
  v_id_barrio                  number;
  v_tipoarea                   number(10);
  v_direccion                  varchar2(2000);
  v_id_persona                 varchar2(20);
  v_cedula                     varchar2(10);
  v_nombre                     varchar2(100);
  v_nombres                    varchar2(50);
  v_apellidos                  varchar2(50);
  v_telefono_linea_baja        varchar2(20);
  v_telefono_celular           varchar2(20);
  v_sexo                       number(10);
  v_edad                       number(10);
  v_fecha_nacimiento           date;
  v_estado_civil               varchar2(10) :='1'; --soltero por defecto
begin
  --Paso 1
  --Recuperamos el año actual
  Select to_char(sysdate, 'yyyy') into v_anio From dual;
  --Recuperamos la version actual de la ficha hogar
  Begin
      Select valor Into v_version_ficha_hogar From variable_global where numero=103;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
  End;
  --Recuperamos el periodo maximo de validez del censo
  Select valor_numerico into v_periodo_validez From variable_global Where numero = 101;
  --Recuperamos el nro de censos maximo
  Select valor_numerico into v_nro_censos From variable_global Where numero = 102;

  --Recuperamos los datos de la persona
  Select de.codigo, de.id, di.codigo, di.id, nvl(ba.codigo,'0000000'), ba.id, nvl(ba.tipo_area,6), pe.fecha_nacimiento, 
         pe.direccion, pe.telefono_linea_baja, pe.telefono_celular, to_char(pe.id,'000000000000000000') as idpersona, pe.cedula,
         pe.nombres, pe.apellidos, pe.numero_sime_tutelaje, pe.sexo, calcular_edad(pe.fecha_nacimiento) as edad, pe.estado_civil
    Into v_departamento, v_id_departamento, v_distrito, v_id_distrito, v_barrio, v_id_barrio, v_tipoarea, v_fecha_nacimiento,
         v_direccion, v_telefono_linea_baja, v_telefono_celular, v_id_persona, v_cedula,
         v_nombres, v_apellidos, v_numero_sime_tutelaje, v_sexo, v_edad, v_estado_civil
  From persona pe, departamento de, distrito di, barrio ba
  Where pe.departamento=de.id And pe.distrito = di.id
    And pe.barrio  = ba.id (+)
    And pe.cedula=p_cedula;

  --Recuperamos la sequencia para ficha_hogar
  v_id_ficha_hogar := busca_clave_id;

  v_codigo := v_barrio || v_anio || ficha_hogar_sq___.nextval;
  insert into ficha_hogar (id, version, codigo, numero_formulario, numero_vivienda, numero_hogar, fecha_entrevista,
                            estado, fecha_transicion, departamento, distrito, tipo_area, VERSION_FICHA_HOGAR)
  values (v_id_ficha_hogar, 0, v_codigo, '1', 0, 0, sysdate,
          1, sysdate, v_id_departamento, v_id_distrito, v_tipoarea, v_version_ficha_hogar);

  --Paso 2
  v_id_ficha_persona := busca_clave_id;
  v_nombre :=v_nombres || ', ' || v_apellidos;
  v_codigo_ficha_persona := v_codigo || '1';
  INSERT INTO FICHA_PERSONA (ID, VERSION, CODIGO, NOMBRE, FICHA_HOGAR, NOMBRES, 
                             APELLIDOS, EDAD, SEXO_PERSONA, TIPO_PERSONA_HOGAR, MIEMBRO_HOGAR, NUMERO_ORDEN_IDENTIFICACION,
                             NUMERO_CEDULA, TIPO_EXCEPCION_CEDULA, FECHA_NACIMIENTO, NUMERO_TELEFONO, ESTADO_CIVIL, OCUPACION, RAMA)
  VALUES (v_id_ficha_persona, 0, v_codigo_ficha_persona , v_nombre, v_id_ficha_hogar, v_nombres,
          v_apellidos, v_edad, v_sexo, 1, 'true', 1,
          v_cedula, null, v_fecha_nacimiento, null, v_estado_civil, null, null);
  --Paso 3
  --Recuperamos la cantidad de censos por persona
  Select count(id) into v_cant_censos From censo_persona Where persona = to_number(v_id_persona);

  if v_cant_censos <= v_nro_censos then
    v_id_censo_persona := busca_clave_id;
    INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,
                                        ICV, TIPO_POBREZA, COMENTARIOS,  DEPARTAMENTO, DISTRITO, TIPO_AREA,
                                        BARRIO, DIRECCION, NUMERO_TELEFONO,  NOMBRE_REFERENTE, NUMERO_TELEFONO_REFERENTE, NUMERO_SIME,
                                        ARCHIVO, LINEA, ESTADO,  FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES,  CENSISTA_EXTERNO, CENSISTA_INTERNO, CAUSA_ANULACION)
    values (v_id_censo_persona, 0, v_id_censo_persona, to_number(v_id_persona), current_date, v_id_ficha_persona,
            null, null, '', v_id_departamento, v_id_distrito, v_tipoarea,
            v_id_barrio, v_direccion, 'Linea Baja :' || v_telefono_linea_baja || ' Celular :' || v_telefono_celular, null, null, v_numero_sime_tutelaje,
            null, null, 1, current_date, current_user_id, null, null, null, null);
  end if;

  For reg in (select * from pregunta_ficha_hogar Where version_ficha=v_version_ficha_hogar order by 1) loop
    v_id_pregunta:=reg.id;
    v_tipo_dato_respuesta:=reg.tipo_dato_respuesta;
    v_id_respuesta_ficha_hogar := busca_clave_id;
    if v_tipo_dato_respuesta=1 Then --alfanumerico
       insert into respuesta_ficha_hogar (id, version, ficha, pregunta, texto)
       values (v_id_respuesta_ficha_hogar, 0, v_id_ficha_hogar, v_id_pregunta, ' ');
    elsif v_tipo_dato_respuesta=2 Then --numerico
       insert into respuesta_ficha_hogar (id, version, ficha, pregunta, numero)
       values (v_id_respuesta_ficha_hogar, 0, v_id_ficha_hogar, v_id_pregunta, 0);
    elsif v_tipo_dato_respuesta=3 Then --fecha
       insert into respuesta_ficha_hogar (id, version, ficha, pregunta, fecha)
       values (v_id_respuesta_ficha_hogar, 0, v_id_ficha_hogar, v_id_pregunta, '1900-01-01');
    else --discreto
       begin
          Select id into v_id_rango_respuesta From rango_ficha_hogar where pregunta=v_id_pregunta And rownum=1 Order by id;
       exception
       WHEN NO_DATA_FOUND THEN
          null;
       end;
       if v_id_rango_respuesta is not null Then
          insert into respuesta_ficha_hogar (id, version, ficha, pregunta, rango)
          values (v_id_respuesta_ficha_hogar, 0, v_id_ficha_hogar, v_id_pregunta, v_id_rango_respuesta);
       end if;
    end if;
  end loop;

  For reg in (select * from pregunta_ficha_persona Where version_ficha=v_version_ficha_hogar order by 1) loop
    v_id_pregunta:=reg.id;
    v_tipo_dato_respuesta:=reg.tipo_dato_respuesta;
    v_id_respuesta_ficha_persona := busca_clave_id;
    if v_tipo_dato_respuesta=1 Then --alfanumerico
       insert into respuesta_ficha_persona (id, version, ficha, pregunta, texto)
       values (v_id_respuesta_ficha_persona, 0, v_id_ficha_persona, v_id_pregunta, ' ');
    elsif v_tipo_dato_respuesta=2 Then --numerico
       insert into respuesta_ficha_persona (id, version, ficha, pregunta, numero)
       values (v_id_respuesta_ficha_persona, 0, v_id_ficha_persona, v_id_pregunta, 0);
    elsif v_tipo_dato_respuesta=3 Then --fecha
       insert into respuesta_ficha_persona (id, version, ficha, pregunta, fecha)
       values (v_id_respuesta_ficha_persona, 0, v_id_ficha_persona, v_id_pregunta, '1900-01-01');
    else --rango
       begin
          Select id into v_id_rango_respuesta From rango_ficha_persona where pregunta=v_id_pregunta And rownum=1 Order by id;
       exception
       WHEN NO_DATA_FOUND THEN
          v_id_rango_respuesta:=null;
       end;
       if v_id_rango_respuesta is not null Then
          insert into respuesta_ficha_persona (id, version, ficha, pregunta, rango)
          values (v_id_respuesta_ficha_persona, 0, v_id_ficha_persona, v_id_pregunta, v_id_rango_respuesta); 
       end if;
    end if;
  end loop;
  return 0;
exception
  when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    --raise_application_error(-20001, err_msg, true);
    raise;
end;
/
