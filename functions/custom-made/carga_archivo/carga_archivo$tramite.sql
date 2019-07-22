create or replace function carga_archivo$tramite(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, x$observaciones nvarchar2)
  return number is
  err_msg                      	VARCHAR2(2000);
	v_cant_errores					  	  integer:=0;
	aux                           VARCHAR2(4000);
	v_id_carga_archivo            number;
	v_id_linea_archivo            number;
	cant_registro                 integer :=0;
	v_version_ficha_hogar         varchar2(20):= NULL;
	v_periodo_validez_censo			  integer;
	v_max_censo_periodo				    integer;
	v_id_censista_externo  		  	number;
	archivo_adjunto					      varchar2(255);
	id_archivo_adjunto				    number;
	valor_columna                 varchar2(1000);
	contador                      integer :=1;
  contador_t                    integer :=1;
	contadoraux							      integer :=1;
	i                             integer :=-1;
	auxi                          integer;
	x$persona							        number;
	v_cedula                	  	varchar2(10);
 	v_nombres                	  	varchar2(100);
	v_id_cedula                	  number;
	v_nombre                	    varchar2(50);
	v_apellido							      varchar2(50);
	w_nombre                	    varchar2(50);
	w_apellido							      varchar2(50);
	v_porc_match_nombre				    number;
	v_porc_match_apellido			    number;
	v_fecha_nacimiento          	date;
	v_estado_civil              	varchar2(1) :='7';
	v_sexo                      	varchar2(1) :='7';
	v_edad                      	varchar2(3);
	v_departamento						    varchar2(10);
	v_id_departamento           	number;
	v_id_distrito               	number;
	v_distrito							      varchar2(10);
	v_tipoarea                  	varchar2(2):=null;
	v_id_barrio                 	number;
	v_barrio								      varchar2(200);
	v_direccion                 	varchar2(255);
	v_paraguayo                 	varchar2(10);
	v_indigena                  	varchar2(10);
	v_id_etnia							      number;
	v_id_comunidad						    number;
	v_telefonobaja              	varchar2(20);
	v_telefonocelular           	varchar2(20);
	v_id_pension						      number;
  v_estado_pension           	  number;
	v_clase_pension					      number;
	v_cant_censos						      integer;
	v_id_censo_persona				    integer;
	v_anio								        varchar2(4);
	v_codigo								      varchar2(20);
	v_id_ficha_hogar					    number;
	v_id_ficha_persona				    number;
	v$estado_inicial 					    integer;
	v$estado_final   					    integer;
	v$inserta_transicion				  number;
	v_codigo_ficha_persona			  varchar2(30);
  x$reg									        number;
  v_tiene_objecion					    varchar2(10);
  v_apodo                    	  varchar2(100);
  v_nombre_referente         	  varchar2(100);
  v_referencia               	  varchar2(100);
  v_telefono_referente 			    varchar2(10);
  v$log rastro_proceso_temporal%ROWTYPE;
  v_dist								        number;
  v_jaro								        number;
  v$observaciones               varchar2(10000);
  v_tipo_tramite                varchar2(1);
begin
	v$log := rastro_proceso_temporal$select();
  Begin
		Select valor Into v_version_ficha_hogar From variable_global where numero=103;  --version ficha hogar activa
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
	End;
  Select valor into v_periodo_validez_censo From variable_global where numero=101; --Periodo de validez de censo en aóos
	Select valor into v_max_censo_periodo From variable_global where numero=102;--Móximo número de censos por periodo
	Begin
		Select id Into v_id_censista_externo From censista where trim(nombre)='DPNC';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		v_id_censista_externo:=NULL;
	End;
	For reg in (Select * From csv_imp_temp Where archivo=x$archivo order by 1) loop
    v_cant_errores:=0;
		if trim(reg.registro) is not null then
			aux:=replace(trim(substr(trim(reg.registro),1,4000)),chr(39), '');
      aux:=replace(aux,'"', '');
			aux:=replace(aux,chr(13), '');
			aux:=replace(aux,chr(10), '');
    else
			aux:=null;
    end if;
    if contador=contadoraux then --encabezado del archivo
			Begin
				Select aa.ARCHIVO_CLIENTE, aa.id
          into archivo_adjunto, id_archivo_adjunto
				From ARCHIVO_ADJUNTO aa
        Where aa.ARCHIVO_SERVIDOR =  x$archivo;

        Select ca.id, ca.directorio
          into v_id_carga_archivo, contadoraux
				From carga_archivo ca inner join ARCHIVO_ADJUNTO aa on upper(ca.archivo)=upper(aa.ARCHIVO_SERVIDOR)
				Where PROCESO_SIN_ERRORES='false' And aa.ARCHIVO_CLIENTE=archivo_adjunto; --se busca posible carga anterior no finalizada completa
      exception
			WHEN NO_DATA_FOUND THEN
        v_id_carga_archivo:=null;
      when others then
        v_id_carga_archivo:=null;
      end;
			if v_id_carga_archivo is null then
        begin
          v_id_carga_archivo:=busca_clave_id;
					INSERT INTO CARGA_ARCHIVO (ID, VERSION, CODIGO, CLASE, ARCHIVO, ADJUNTO,
                                      NUMERO_SIME, FECHA_HORA, ARCHIVO_SIN_ERRORES, PROCESO_SIN_ERRORES, OBSERVACIONES)
					VALUES (v_id_carga_archivo, 0, v_id_carga_archivo, x$clase_archivo, x$archivo, id_archivo_adjunto,
								x$sime, sysdate,null, 'false', x$observaciones);
        exception
				when others then
					raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
				End;
      else
        Update carga_archivo set OBSERVACIONES=x$observaciones, NUMERO_SIME=x$sime Where id=v_id_carga_archivo;
			End if;
		end if;
		if contador>=contadoraux then
      if (aux is not null) then
        Select length(aux)-length(replace(aux,';','')) Into cant_registro From dual;  --cantidad de columnas
      else
        cant_registro:=0;
      end if;
      For i in 0 .. cant_registro LOOP
        auxi:=i;
        if instr(aux,';')=0 then
          valor_columna:=aux;
        else
          valor_columna:=substr(aux, 0, instr(aux,';')-1);
          aux:=substr(aux, instr(aux,';')+1);
        end if;
        if i=0 Then
          Begin
            v_id_linea_archivo:=busca_clave_id;
            INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
            VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, substr(reg.registro,1,2000), '');
          exception
          when others then
            raise_application_error(-20001,'Error al intentar insertar la linea (' || contador || ') del archivo, mensaje:'|| sqlerrm, true);
          End;
        end if;
        case i
				When 0 Then
          BEGIN
						Select trim(to_char(valor_columna,'00')) into v_departamento from dual;
						Select id into v_id_departamento From departamento Where codigo=trim(v_departamento);
					EXCEPTION
					WHEN NO_DATA_FOUND THEN  
						v_id_departamento:=99;
						v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: departamento no encontrado:' || valor_columna);
          when others then
						v_id_departamento:=99;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código del departamento, valor leído:' || valor_columna || ', mensaje error:' || err_msg);
					END;
				When 1 Then
          BEGIN
						if length(valor_columna)<=2 then
							Select trim(v_departamento) ||  trim(to_char(valor_columna,'00')) into v_distrito from dual;
            else
              Select to_char(valor_columna,'0000') into v_distrito from dual;
            end if;
						Select id into v_id_distrito From distrito Where codigo=trim(v_distrito);
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
						if v_id_departamento=99 then
							v_id_distrito:=99;
						else
              v_id_distrito:=null;
            end if;
						v_cant_errores:=v_cant_errores+1;
  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Distrito no encontrado:' || valor_columna);
          when others then
						v_id_distrito:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código del distrito, valor leído:' || valor_columna || ', mensaje error:' || err_msg);
          END;
				When 2 Then
					Begin
            v_cedula:=trim(substr(valor_columna,1,10));
						Select id, apellidos, nombres, fech_nacim, sexo, case nacionalidad when 226 then 'true' else 'false' end as paraguayo, estado_civil
              into v_id_cedula, w_apellido, w_nombre, v_fecha_nacimiento, v_sexo, v_paraguayo, v_estado_civil
            From cedula where numero=v_cedula;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_cedula:=NULL;
						v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error nro cédula no encontrado en la tabla de identificación:' || valor_columna);
					END;
        When 3 Then
          v_nombre:=trim(substr(valor_columna,1,50));
        When 4 Then
					v_apellido:=trim(substr(valor_columna,1,50));
				When 5 Then
					v_nombres:=substr(v_nombre || ' ' || v_apellido,1,100);
					v_apodo:=trim(substr(valor_columna,1,100));
        When 6 Then
          null; --fecha nacimiento
        When 7 Then
          v_telefonobaja:=substr(valor_columna,1,13);
        When 8 Then
          v_direccion:=substr(valor_columna,1,255);
				When 9 Then
          v_referencia:=substr(valor_columna,1,100);
				When 10 Then
          begin
						Select ba.id, ba.nombre, utl_match.edit_distance_similarity(ba.nombre,upper(substr(valor_columna,1,200))) as dist,
                  utl_match.jaro_winkler_similarity(ba.nombre,upper(substr(valor_columna,1,200))) as jaro, ba.tipo_area
							Into v_id_barrio, v_barrio, v_dist, v_jaro, v_tipoarea
						From barrio ba
						Where ba.distrito=v_id_distrito
							And utl_match.jaro_winkler_similarity(upper(ba.nombre),upper(substr(valor_columna,1,200)))>75
							And rownum=1
						Order by jaro desc;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_barrio:=null;
            v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: barrio no encontrado [' || valor_columna || '], cedula:' || v_cedula || ', nombre: ' || v_nombres);
          when others then
						v_id_barrio:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: error al intentar obtener el código de Barrio, valor leído:' || valor_columna || ', nombre: ' || v_nombres || ', mensaje:' || err_msg);
					END;
				When 11 Then
          v_nombre_referente:=substr(valor_columna,1,100);
        When 12 Then                
          v_telefono_referente:=substr(valor_columna,1,10);
				When 13 Then
          begin
            Select id into v_clase_pension From clase_pension where codigo=trim(substr(valor_columna,1,10));
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
						v_clase_pension:=150498912213505560;
						v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: clase concepto no encontrado, valor leído:' || valor_columna || ', cedula:' || v_cedula || ', nombres:' || v_nombres);
          when others then
						v_clase_pension:=150498912213505560;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: error al intentar obtener el código de la clase concepto, valor leído:' || valor_columna || ', nombre: ' || v_nombres || ', mensaje:' || err_msg);
          END;
        When 14 Then                
          v_tipo_tramite:=substr(valor_columna,1,1);
        else
          null;
        end case;
			End loop;
      v_id_censo_persona:=null; v_id_ficha_persona:=null; x$persona:=null;
			Begin
				Select id into x$persona From persona where codigo=v_cedula;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x$persona:=null;
				v_cant_errores:=v_cant_errores+1;
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error no se encontraron registros de la persona cédula:' || v_cedula || ', nombres:' || v_nombres);
			when others then
        x$persona:=null;
				v_cant_errores:=v_cant_errores+1;
				err_msg := SUBSTR(SQLERRM, 1, 200);
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar la cédula de la persona:' || v_cedula || ', nombres:' || v_nombres || ', mensaje:' || err_msg);
			End;
      v_id_pension:=null;
			if x$persona is not null Then
				Begin
					Select id, estado 
            into v_id_pension, v_estado_pension 
          From pension 
          Where persona=x$persona And clase=v_clase_pension 
            And rownum=1 And estado<>2 Order by id desc;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
          v_id_pension:=null; v_estado_pension:=null;
					v_cant_errores:=v_cant_errores+1;
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error no se encontraron registros de pensión adulto mayor a la persona cédula:' || v_cedula || ', nombres:' || v_nombres);
				when others then
          v_id_pension:=null; v_estado_pension:=null;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar pensión a la cédula de la persona:' || v_cedula || ', nombres:' || v_nombres || ', mensaje:' || err_msg);
				End;
      else
        v$observaciones:=v$observaciones || 'Error no se encontraron datos de persona, cedula:' || v_cedula || '. ';
			end if;
      Begin
        x$reg:=busca_clave_id;
        insert into tramite_administrativo (id, version, codigo, pension, tipo, descripcion, numero_sime,
                                            archivo, linea, fecha_transicion, usuario_transicion, observaciones)
				values (x$reg, 0, x$reg, v_id_pension, v_tipo_tramite, 'Trámite cargado por archivo.', x$sime,
                v_id_carga_archivo, contador, sysdate, current_user_id, x$observaciones);
      EXCEPTION
			when others then
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 300);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de tramite, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
      END;
      if v_id_pension is not null  Then
        if v_tipo_tramite=1 And v_estado_pension=5 then --reclamo valor icv y pension denegada, se crea una nueva pension
          --Update pension set estado=2, observaciones='Pensión anulada por reclamo de censo.' Where id=v_id_pension;
          begin
            v_id_pension:=busca_clave_id;
            insert into pension(id, version, codigo, clase, persona, estado, numero_sime_entrada, archivo, linea, observaciones)
            values (v_id_pension, 0, v_id_pension, v_clase_pension, x$persona, 1, x$sime, v_id_carga_archivo, contador, x$observaciones);
          exception 
          when others then
            v_id_pension:=null;
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de pensión, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
            v$observaciones:=v$observaciones || 'Error al intentar crear el registro de pensión, cedula:' || v_cedula || '. ';
          end;
          if v_id_pension is not null then
            v$estado_inicial := 1;
            v$estado_final   := 1;
            v$inserta_transicion := transicion_pension$biz(v_id_pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
            x$reg:=pension$verificar$biz(0, v_id_pension, 'true'); --verificar elegibilidad de la pensión reción creada
            begin
              Select tiene_objecion into v_tiene_objecion From pension where id =v_id_pension;
            exception
            WHEN NO_DATA_FOUND THEN
              v_tiene_objecion:='false';
            when others then
              v_tiene_objecion:='false';
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 300);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener la objeción de la pension cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
              v$observaciones:=v$observaciones || 'Error al intentar obtener la objeción de la pension cedula:' || v_cedula || '. ';
            end;
          else
            v_tiene_objecion:=null;
          end if;
          if v_tiene_objecion='true' then
            v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: a la pensión código:' || v_id_pension || ' le fueron creadas objeciones. Cédula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
            v$observaciones:=v$observaciones || 'Aviso: a la pensión código:' || v_id_pension || ' le fueron creadas objeciones. Cédula:' || v_cedula || '. ';
          end if;
          begin
            Select Count(distinct(a.id)) into v_cant_censos
            From censo_persona a inner join ficha_persona b on a.ficha=b.id
              left outer join ficha_hogar c on b.ficha_hogar = c.id
              left outer join ficha_persona d on c.id = d.ficha_hogar And d.id<>b.id
            Where (b.numero_cedula=v_cedula or d.numero_cedula=v_cedula)
                And a.fecha between ADD_MONTHS(sysdate,((v_periodo_validez_censo*12)*-1)) And sysdate
            Group By a.fecha, b.numero_cedula, d.numero_cedula;
          exception
          WHEN NO_DATA_FOUND THEN
            v_cant_censos:=0;
          when others then
            v_cant_censos:=0;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 300);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener los censos anteriores, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
            v$observaciones:=v$observaciones || 'Error al intentar obtener los censos anteriores, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg || '. ';
          end;
          if v_cant_censos <= v_max_censo_periodo And v_tiene_objecion='false' then --solo se cargan datos de censo a aquellos que no tengan mas de la cantidad permitida en el periodo configurado
            begin
              Select id into v_id_censo_persona
              From censo_persona Where persona=x$persona And estado=1 And rownum=1;
            Exception
            WHEN NO_DATA_FOUND THEN
              v_id_censo_persona:=null;
            when others then
              v_id_censo_persona:=null;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el registro de un censo anterior para la cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
              v$observaciones:=v$observaciones || 'Error al intentar obtener el registro de un censo anterior para la cedula:' || v_cedula || '. ';
            end;
            if v_id_censo_persona is null then
              begin
                Select calcular_edad(v_fecha_nacimiento) into v_edad From dual;
                v_id_ficha_persona := busca_clave_id;
                INSERT INTO FICHA_PERSONA (ID, VERSION, CODIGO, NOMBRE, FICHA_HOGAR, NOMBRES,
                                          APELLIDOS, EDAD, SEXO_PERSONA, TIPO_PERSONA_HOGAR, MIEMBRO_HOGAR, NUMERO_ORDEN_IDENTIFICACION,
                                          NUMERO_CEDULA, TIPO_EXCEPCION_CEDULA, FECHA_NACIMIENTO, NUMERO_TELEFONO, ESTADO_CIVIL)
                  VALUES (v_id_ficha_persona, 0, v_id_ficha_persona, v_apellido || ', ' || v_nombre, v_id_ficha_hogar, v_nombre,
                          v_apellido, v_edad, v_sexo, 1, 'true', 1,
                          v_cedula, null, v_fecha_nacimiento, v_telefonobaja, v_estado_civil);
              exception
              when others then
                v_id_ficha_persona:=null;
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 300);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de ficha persona, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
                v$observaciones:=v$observaciones || 'Error al intentar crear el registro de ficha persona, cedula:' || v_cedula || '. ';
              end;
              begin
                v_id_censo_persona := busca_clave_id;
                INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,
                                           ICV, TIPO_POBREZA, COMENTARIOS,  DEPARTAMENTO, DISTRITO, TIPO_AREA,
                                           BARRIO, DIRECCION, NUMERO_TELEFONO,  NOMBRE_REFERENTE, NUMERO_TELEFONO_REFERENTE, NUMERO_SIME,
                                           ARCHIVO, LINEA, ESTADO,  FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES,  CENSISTA_EXTERNO, CENSISTA_INTERNO, CAUSA_ANULACION)
                values (v_id_censo_persona, 0, v_id_censo_persona, x$persona, current_date, v_id_ficha_persona,
                        null, null, '', v_id_departamento, v_id_distrito, v_tipoarea,
                        v_id_barrio, v_direccion, 'Linea Baja :' || v_telefonobaja || ' Celular :' || v_telefonocelular, null, null, x$sime,
                        v_id_carga_archivo, contador, 1, current_date, current_user_id, x$observaciones, v_id_censista_externo, null, null);
              exception
              when others then
                v_id_censo_persona:=null;
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 300);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de censo, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
                v$observaciones:=v$observaciones || 'Error al intentar crear el registro de censo, cedula:' || v_cedula || '. ';
              end;
              if v_id_ficha_persona is not null then
                for reg in (select * from pregunta_ficha_persona where version_ficha=v_version_ficha_hogar) loop
                  begin
                    insert into respuesta_ficha_persona (id, version, ficha, pregunta)
                    values (busca_clave_id, 0, v_id_ficha_persona, reg.id);
                  exception
                  when others then
                    v_cant_errores:=v_cant_errores+1;
                    err_msg := SUBSTR(SQLERRM, 1, 300);
                    x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de la respuesta de ficha persona, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
                    v$observaciones:=v$observaciones || 'Error al intentar crear el registro de la respuesta de ficha persona, cedula:' || v_cedula || '. ';
                  end;
                end loop;
                Begin
                  update persona set ficha=v_id_ficha_persona where codigo=v_cedula;
                Exception
                WHEN NO_DATA_FOUND THEN
                  null;
                when others then
                  v_cant_errores:=v_cant_errores+1;
                  err_msg := SUBSTR(SQLERRM, 1, 200);
                  x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar código ficha persona en persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
                  v$observaciones:=v$observaciones || 'Error al intentar actualizar código ficha persona en persona, cedula:' || v_cedula || '. ';
                End;
              end if;
            else
              v_id_censo_persona:=null;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: ya existe un registro de censo en estado pendiente, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
              v$observaciones:=v$observaciones || 'Aviso: ya existe un registro de censo en estado pendiente, cedula:' || v_cedula || '. ';
            end if;
          else
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 300);
            v_id_censo_persona:=null; v_id_ficha_persona:=null;
            if v_cant_censos > v_max_censo_periodo then 
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: no se creó censo porque para la cedula:' || v_cedula || ', nombres:' || v_nombres || ' y número de línea:' || contador || ', la cantidad de censos:' || v_cant_censos || ' es mayor que ' || v_max_censo_periodo);
              v$observaciones:=v$observaciones || 'Aviso: no se creó censo porque para la cedula:' || v_cedula || ', la cantidad de censos:' || v_cant_censos || ' es mayor que ' || v_max_censo_periodo || '. ';
            end if;
          end if; --if v_cant_censos <= v_max_censo_periodo then
        else
          v_cant_errores:=v_cant_errores+1;
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error: el estado de la pensión es diferente a Denegada, cedula:' || v_cedula);
          v$observaciones:=v$observaciones || 'Error: el estado de la pensión es diferente a Denegada, cedula:' || v_cedula || '. ';
        end if; --if v_tipo_tramite=1 or v_tipo_tramite=2 then
      else
        v_cant_errores:=v_cant_errores+1;
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error: no se encontraron datos de una pensión anterior, cedula:' || v_cedula);
        v$observaciones:=v$observaciones || 'Error: no se encontraron datos de una pensión anterior, cedula:' || v_cedula || '. ';
			end if;
      begin
        x$reg:=busca_clave_id;
        insert into solicitud_pension (ID, VERSION, CODIGO, CEDULA, PERSONA, PENSION, CENSO_PERSONA, FICHA_PERSONA, nombre,
                                       FECHA_TRANSICION, NUMERO_SIME, ARCHIVO, LINEA, INFORMACION_INVALIDA, OBSERVACIONES,
                                       departamento, distrito)
                            values (x$reg, 0, x$reg, v_cedula, x$persona, v_id_pension, v_id_censo_persona, v_id_ficha_persona, v_nombres,
                                    sysdate, x$sime, v_id_carga_archivo, contador, null, substr(v$observaciones,1,2000),
                                    v_id_departamento, v_id_distrito);
      exception
      when others then
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 300);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de solicitud de pensión, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
      end;
			if (v_cant_errores>0) Then
        Update LINEA_ARCHIVO set  ERRORES=v_cant_errores Where id=v_id_linea_archivo;
			End If;
      contador_t:=contador_t+1;
			if contador_t>1000 then
				update carga_archivo set directorio=contador Where id=v_id_carga_archivo;
				commit work;
				rastro_proceso_temporal$revive(v$log);
				contador_t:=1;
			end if;
		end if; --elsif contador>contadoraux then
    contador:=contador+1;
	End loop;
  Delete From CSV_IMP_TEMP Where archivo=x$archivo;
	Update CARGA_ARCHIVO set PROCESO_SIN_ERRORES='true', directorio=contador Where id=v_id_carga_archivo;
	Select Count(a.id) into v_cant_errores
	From LINEA_ARCHIVO a inner join ERROR_ARCHIVO b on a.id = b.linea
	Where a.CARGA=v_id_carga_archivo;
	if v_cant_errores>0 then
		Update CARGA_ARCHIVO set ARCHIVO_SIN_ERRORES='false' Where id=v_id_carga_archivo;
	end if;
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20100, err_msg || ' columna: ' || auxi ||', en linea:' || contador, true);
end;
/
