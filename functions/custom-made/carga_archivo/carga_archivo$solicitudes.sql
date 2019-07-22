create or replace function carga_archivo$solicitudes(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, x$observaciones nvarchar2)
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
	valor_columna                 varchar2(4000);
	contador                      integer :=1;
  contador_t                    integer :=1;
	contadoraux							      integer :=1;
	i                             integer :=-1;
	auxi                          integer;
	x$persona							        number;
  v$fecha_defuncion             varchar2(10);
  v$sw_persona                  varchar2(5);
	v_cedula                	  	varchar2(20);
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
  v_departamentop           	  varchar2(10);
	v_distritop               	  varchar2(10);
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
	v$id_pension						      number;
  v$estado_pension           	  varchar2(30);
  v$idestado_pension            number;
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
  v$observaciones               varchar2(10000):='';
  v$opcion                      varchar2(5);
  v$estado_censo                integer;
  v$denuncia_pension            number;
  v$valor_icv                   varchar2(20);
  v$referencia_icv              number;
begin
	v$log := rastro_proceso_temporal$select();
	Begin
		Select valor Into v_version_ficha_hogar From variable_global where numero=103;  --version ficha hogar activa
    Select max(valor_x1) into v$referencia_icv From regla where variable_x1=901; --valor de referencia del ICV
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
 	  v_cant_errores:=0; v_indigena:='false'; v_id_etnia:=null; v_id_comunidad:=null; v_id_cedula:=null; v_cedula:=null; v$observaciones:=null; v$sw_persona:='true';
    v$estado_inicial := 0; v$estado_final:=0; v$opcion:=null; 
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
      For i in 0 .. cant_registro LOOP --cant_registro
        auxi:=i;
        if instr(aux,';')=0 then
          valor_columna:=trim(substr(aux,1,1000));
        else
          valor_columna:=substr(aux, 0, instr(aux,';')-1);
          aux:=substr(aux, instr(aux,';')+1);
        end if;
        v_clase_pension:=150498912213505560; --adulto mayor
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
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: departamento no encontrado}:' || valor_columna);
          when others then
						v_id_departamento:=99;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener el código del departamento], valor leído:' || valor_columna || ', mensaje error:' || err_msg);
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
  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{AVISO: Distrito no encontrado}:' || valor_columna);
          when others then
						v_id_distrito:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener el código del distrito], valor leído:' || valor_columna || ', mensaje error:' || err_msg);
          END;
				When 2 Then
					Begin
            v_cedula:=trim(substr(valor_columna,1,20));
						Select id, apellidos, nombres, fech_nacim, sexo, case nacionalidad when 226 then 'true' else 'false' end as paraguayo, estado_civil
                into v_id_cedula, w_apellido, w_nombre, v_fecha_nacimiento, v_sexo, v_paraguayo, v_estado_civil
            From cedula where numero=v_cedula;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_cedula:=NULL; v$sw_persona:='false';
						v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: nro cédula no encontrado en la tabla de identificacion]:' || valor_columna);
					END;
        When 3 Then
          v_nombre:=trim(substr(valor_columna,1,50));
        When 4 Then
					v_apellido:=trim(substr(valor_columna,1,50));
				When 5 Then
        	Begin
            v_nombres:=substr(v_nombre || ' ' || v_apellido,1,100);
            v_apodo:=trim(substr(valor_columna,1,100));
          EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: nombre y/o apodo muy grande]:' || valor_columna);
					END;
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
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: barrio no encontrado} valor leído:' || valor_columna || ', cedula:' || v_cedula || ', nombre: ' || v_nombres);
          when others then
						v_id_barrio:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: error al intentar obtener el código de Barrio}, valor leído:' || valor_columna || ', nombre: ' || v_nombres || ', mensaje:' || err_msg);
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
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: clase concepto no encontrado}, valor leído:' || valor_columna || ', cedula:' || v_cedula || ', nombres:' || v_nombres);
          when others then
						v_clase_pension:=150498912213505560;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: error al intentar obtener el código de la clase concepto}, valor leído:' || valor_columna || ', nombre: ' || v_nombres || ', mensaje:' || err_msg);
          END;
        When 14 Then
          v$opcion:=upper(trim(substr(valor_columna,1,5)));
        else
          null;
        end case;
			End loop;
      x$persona:=null; v$fecha_defuncion:=null; v_distritop:=null; v_departamentop:=null; v_distrito:=null; v_departamento:=null;
      if v$opcion<>'S' And v$opcion<>'R' And v$opcion<>'D' And v$opcion<>'C' And v$opcion<>'M' then
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: opción no válida} opción:' || v$opcion || ', cedula:' || v_cedula || ', nombres:' || v_nombres || ' y número de línea:' || contador);
        v$observaciones:=v$observaciones || '{Aviso: opción no válida} opción:' || v$opcion || ', cedula:' || v_cedula;
      end if;
			Begin
				Select pe.id, pe.fecha_defuncion, dp.codigo, dt.codigo
          into x$persona, v$fecha_defuncion, v_departamentop, v_distritop
        From persona pe inner join departamento dp on pe.departamento = dp.id
          inner join distrito dt on pe.distrito = dt.id
        Where pe.codigo=v_cedula;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
        x$persona:=null;
			when others then
        v$sw_persona:='false';
				v_cant_errores:=v_cant_errores+1;
				err_msg := SUBSTR(SQLERRM, 1, 200);
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener el id de la persona], cédula:' || v_cedula || ', nombres:' || v_nombres || ', mensaje: ' || err_msg);
        v$observaciones:=v$observaciones || '[Error al intentar obtener el id de la persona], cédula:' || v_cedula || ', nombres:' || v_nombres || ', mensaje: ' || err_msg || '. ';
			End;
      if x$persona is not null And (trim(v_departamento)<>trim(v_departamentop) or trim(v_distrito)<>trim(v_distritop)) Then
        v_cant_errores:=v_cant_errores+1;
        v$sw_persona:='false';
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: el departamento y/o distrito para la cédula]:' || v_cedula || ' son diferentes a los suministrados. Departamento registrado:' || v_departamentop || ', suministrado:' || v_departamento || ' y/o distrito suministrado:' || v_distrito || ', registrado:' || v_distritop);
        v$observaciones:=v$observaciones || '[Error: el departamento y/o distrito para la cédula]:' || v_cedula || ' son diferentes a los suministrados. Departamento registrado:' || v_departamentop || ', suministrado:' || v_departamento || ' y/o distrito suministrado:' || v_distrito || ', registrado:' || v_distritop || '. ';
      end if;
      if v$fecha_defuncion is not null then
        v$sw_persona:='false';
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: la persona tiene fecha de defunción registrada:' || v$fecha_defuncion || ', cédula:' || v_cedula);
        v$observaciones:=v$observaciones || '[Error: la persona tiene fecha de defunción registrada:' || v$fecha_defuncion || ', cédula:' || v_cedula || '. ';
      end if;
      if v$sw_persona='true' Then
        begin
          Select utl_match.jaro_winkler_similarity(upper(v_nombre),upper(w_nombre)) into v_porc_match_nombre From dual;
          Select utl_match.jaro_winkler_similarity(upper(v_apellido),upper(w_apellido)) into v_porc_match_apellido From dual;
        EXCEPTION
        when others then
          v_porc_match_nombre:=0; v_porc_match_apellido:=0;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener el % de match entre nombre y apellidos suministrados vs registrados en identificacion], cédula:' || v_cedula || ', nombres:' || v_nombres || '. Mensaje:' || err_msg);
          v$observaciones:=v$observaciones || '[Error al intentar obtener el % de match entre nombre y apellidos suministrados vs registrados en identificacion], cédula:' || v_cedula || ', nombres:' || v_nombres || '. Mensaje:' || err_msg || '. ';
        End;
        if v_porc_match_nombre<75 or v_porc_match_apellido<75 then
          v$sw_persona:='false';
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: nombre diferente], la cédula:' || v_cedula || ' nombre ' || v_nombre || ' es diferente al registrado en identificacion:' || w_nombre || ' (' || v_porc_match_nombre || '%), o el apellido: ' || v_apellido || ' es diferente al registrado en identificacion:' || w_apellido || ' (' || v_porc_match_apellido || '%)');
          v$observaciones:=v$observaciones || '[Error: nombre diferente] la cédula:' || v_cedula || ', nombre:' || v_nombre || ' es diferente al registrado en identificacion:' || w_nombre || ' por un ' || v_porc_match_nombre || '%, o el apellido: ' || v_apellido || ' es diferente al registrado en identificacion:' || w_apellido || ' (' || v_porc_match_apellido || '%)';
        end if;
        if x$persona is null then
	          Begin
              x$persona:=busca_clave_id;
		         	insert into persona (id, version, codigo, nombre, apellidos, nombres, fecha_nacimiento, sexo, estado_civil, paraguayo,
                                   cedula, indigena, departamento, distrito, monitoreado, monitoreo_sorteo, edicion_restringida, direccion,
	                                 barrio, tipo_area, etnia, comunidad, telefono_linea_baja, telefono_celular,
                                   nombre_referente , apodo, referencia, telefono_referente, numero_sime)
	                       values (x$persona, 0, v_cedula, v_apellido || ', ' || v_nombre, v_apellido, v_nombre, v_fecha_nacimiento, v_sexo, v_estado_civil, v_paraguayo,
                                v_id_cedula, v_indigena, v_id_departamento, v_id_distrito, 'false', 'false', 'true', v_direccion,
	                              v_id_barrio, v_tipoarea, v_id_etnia, v_id_comunidad, v_telefonobaja, v_telefonocelular,
                                v_nombre_referente, v_apodo, v_referencia, v_telefono_referente, x$sime);
            EXCEPTION
            when others then
              v$sw_persona:='false'; x$persona:=null;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro persona] cédula:' || v_cedula || ', nombres:' || v_nombres || '. Mensaje:' || err_msg);
              v$observaciones:=v$observaciones || '[Error al intentar crear el registro persona] cédula:' || v_cedula || ', nombres:' || v_nombres || '. Mensaje:' || err_msg || '. ';
            End;
        end if;
      else
        if v_id_cedula is null then
          v$observaciones:=v$observaciones || '[Error: cédula no existe en identificacion]:' || v_cedula || ', nombre suministrado:' || v_nombres || '. ';
        end if;
			end if;
			v$id_pension:=null;
      if v$sw_persona='true' Then
        if v$opcion='M' then
          Begin
            update persona set monitoreado='true',  FECHA_MONITOREO=sysdate Where id=x$persona;
            Update persona set MONITOREO_SORTEO='true',  FECHA_MONITOREO=sysdate 
            Where id in (Select pe2.id 
                        From persona pe inner join ficha_persona fp on pe.ficha = fp.id
                          inner join ficha_hogar fh on fp.ficha_hogar = fh.id
                          inner join ficha_persona fp2 on fh.id = fp2.ficha_hogar
                          inner join persona pe2 on fp2.id = pe2.ficha And pe2.id<>x$persona
                        Where pe.id = x$persona);
          EXCEPTION
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 300);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro de monitoreo], cedula:' || v_cedula || ', número de línea:' || contador || ', mensaje:' || err_msg);
          END;
        end if;
        v$valor_icv:=0; v$idestado_pension:=0;
        Begin
          if v$opcion='R' then --reclamo
            begin
              Select (Select case when cp.icv is null then 'pob:' || cp.tipo_pobreza else 'icv:' || cp.icv end 
                      From censo_persona cp 
                      Where cp.persona = pe.id And cp.fecha=(Select max(cp2.fecha) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4 And cp2.fecha>=to_date('01/01/2014','dd/mm/yyyy')) 
                        And cp.fecha_transicion=(Select max(cp2.fecha_transicion) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4 And cp2.fecha>=to_date('01/01/2014','dd/mm/yyyy'))
                        And rownum=1 And cp.estado=4 And cp.fecha>=to_date('01/01/2014','dd/mm/yyyy')) into v$valor_icv
              From persona pe 
              Where pe.codigo=v_cedula;
              if instr(v$valor_icv,'icv:')>0 then
                v$valor_icv:=substr(v$valor_icv,5);
              else
                if substr(v$valor_icv,5)=1 then --pobre por tipo pobreza
                  v$valor_icv:=0;
                else
                  v$valor_icv:=99;
                end if;
              end if;
            Exception
            WHEN NO_DATA_FOUND THEN
              v$valor_icv:=-1; --no hay censos a partir de 2014
            when others then
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: obtener ICV], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
              v$observaciones:=v$observaciones || '[Error: obtener ICV] cedula:' || v_cedula || '. ';
            end;
            Select id, codigo, estado into v$id_pension, v$estado_pension, v$idestado_pension
            From (Select pn.id, ep.codigo, pn.estado
                  From pension pn inner join estado_pension ep on pn.estado = ep.numero
                  Where pn.persona=x$persona And pn.clase=v_clase_pension
                  Order by pn.id desc)
            Where rownum=1;
          else
            Select pn.id, ep.codigo, pn.estado
              into v$id_pension, v$estado_pension, v$idestado_pension
            From pension pn inner join estado_pension ep on pn.estado = ep.numero
            Where pn.persona=x$persona And pn.clase=v_clase_pension
              And pn.estado in (1,3,6,7) And rownum=1
            Order by pn.estado desc;
          end if;
				exception
				WHEN NO_DATA_FOUND THEN
          v$id_pension:=null; v$idestado_pension:=0;
        when others then
          v$id_pension:=null;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener el registro de una pensión pre-existente], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
          v$observaciones:=v$observaciones || '[Error al intentar obtener el registro de una pensión pre-existente], cedula:' || v_cedula || ', mensaje:' || err_msg  || '. ';
        end;
        if (v$id_pension is null And (v$opcion='S' or v$opcion='C'))then
          begin
            v$id_pension:=busca_clave_id;
            insert into pension(id, version, codigo, clase, persona, estado, numero_sime_entrada, archivo, linea, observaciones)
            values (v$id_pension, 0, v$id_pension, v_clase_pension, x$persona, 1, x$sime, v_id_carga_archivo, contador, x$observaciones);
            v$estado_inicial := 1;
            v$estado_final   := 1;
            v$inserta_transicion := transicion_pension$biz(v$id_pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
          exception
          when others then
            v$id_pension:=null;
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro de pensión, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
            v$observaciones:=v$observaciones || '[Error al intentar crear el registro de pensión], cedula:' || v_cedula || '. ';
          end;
        elsif (v$id_pension is null And (v$opcion='D' or v$opcion='M'))then
          v$id_pension:=null;
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: no existe una pensión Adulto Mayor], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
          v$observaciones:=v$observaciones || '[Error: no existe una pensión Adulto Mayor] en estado ' || v$estado_pension || ', cedula:' || v_cedula || '. ';
        elsif (v$id_pension is not null And (v$opcion='S' or v$opcion='C'))then
          v$id_pension:=null;
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: ya existe una pensión Adulto Mayor], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
          v$observaciones:=v$observaciones || '[Error: ya existe una pensión Adulto Mayor] en estado ' || v$estado_pension || ', cedula:' || v_cedula || '. ';
        elsif (v$opcion='R') then
          if to_number(v$valor_icv)<=v$referencia_icv And (v$idestado_pension=9 or v$idestado_pension=5 or v$idestado_pension=2) then --si es pobre y su pension fue denegada/revocada no se admite reclamo
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: persona pobre con pension denegada/revocada}, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
            v$observaciones:=v$observaciones || '{Aviso: persona pobre con pension denegada/revocada}, cedula:' || v_cedula || '. ';
          elsif to_number(v$valor_icv)=-1 then --no hay censos anteriores >2014, no permite reclamo
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: persona sin censo a partir de 2014}, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
            v$observaciones:=v$observaciones || '{Aviso: persona sin censo a partir de 2014}, cedula:' || v_cedula || '. ';
          elsif to_number(v$valor_icv)>v$referencia_icv And (v$id_pension is null or v$idestado_pension=9 or v$idestado_pension=5 or v$idestado_pension=2) then --se crea la solicitud de pension si NO es pobre y tiene pension denegada/revocada y es un reclamo... easy 
              begin
                v$id_pension:=busca_clave_id;
                insert into pension(id, version, codigo, clase, persona, estado, numero_sime_entrada, archivo, linea, observaciones)
                values (v$id_pension, 0, v$id_pension, v_clase_pension, x$persona, 1, x$sime, v_id_carga_archivo, contador, x$observaciones);
                v$estado_inicial := 1;
                v$estado_final   := 1;
                v$inserta_transicion := transicion_pension$biz(v$id_pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
              exception
              when others then
                v$id_pension:=null;
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 300);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro de pensión, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
                v$observaciones:=v$observaciones || '[Error al intentar crear el registro de pensión], cedula:' || v_cedula || '. ';
              end;
          end if;
        end if;
        v_tiene_objecion:='false';
        if (v$id_pension is not null And (v$opcion='S' or v$opcion='R')) then
          x$reg:=pension$verificar$biz(0, v$id_pension, 'true'); --verificar elegibilidad de la pensión reción creada
          begin
            Select tiene_objecion into v_tiene_objecion From pension where id =v$id_pension;
          exception
          WHEN NO_DATA_FOUND THEN
            v_tiene_objecion:='false';
          when others then
            v_tiene_objecion:='false';
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener la objeción de la pension] cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
            v$observaciones:=v$observaciones || '[Error al intentar obtener la objeción de la pension] cedula:' || v_cedula || ' mensaje:' || err_msg || '. ';
          end;
        end if;
        if (v$id_pension is not null And v$opcion='D') then --denuncia
          begin
            v$denuncia_pension:=busca_clave_id;
            insert into denuncia_pension (ID, VERSION, CODIGO, PENSION, DESCRIPCION, NUMERO_SIME, ARCHIVO,
                                          LINEA, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES)
                                values (v$denuncia_pension, 0, v$denuncia_pension, v$id_pension, 'Denuncia cargada por archivo solicitudes', x$sime, v_id_carga_archivo,
                                        contador, 1, sysdate, current_user_id, x$observaciones);
          exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro de denuncia] cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
            v$observaciones:=v$observaciones || '[Error al intentar crear el registro de denuncia] cedula:' || v_cedula || ' mensaje:' || err_msg || '. ';
          end;
        end if;
        if v_tiene_objecion='true' then
          v_cant_errores:=v_cant_errores+1;
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: pensión con objeciones] código:' || v$id_pension || ' le fueron creadas objeciones. Cédula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
          v$observaciones:=v$observaciones || '[Error: pensión con objeciones] código:' || v$id_pension || ' , cédula:' || v_cedula || '. ';
        end if;
        v_cant_censos:=0;
        begin
          Select Count(distinct(cp.id)) into v_cant_censos
          From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
            left outer join ficha_hogar fh on fp.ficha_hogar = fh.id
            left outer join ficha_persona fp2 on fh.id = fp2.ficha_hogar And fp.id<>fp2.id And fp2.ficha_hogar<>fp.ficha_hogar
          Where (fp.numero_cedula=v_cedula or fp2.numero_cedula=v_cedula)
              And cp.fecha between ADD_MONTHS(sysdate,((v_periodo_validez_censo*12)*-1)) And sysdate;
        exception
        WHEN NO_DATA_FOUND THEN
          v_cant_censos:=0;
        when others then
          v_cant_censos:=0;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener los censos anteriores], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
          v$observaciones:=v$observaciones || '[Error al intentar obtener los censos anteriores], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg || '. ';
        end;
				if ((v_cant_censos =0 And v$opcion='S') 
          or (v_cant_censos <= v_max_censo_periodo And (v$opcion='M' or v$opcion='D') And v$id_pension is not null)
          or (v$valor_icv>=0 And v_cant_censos <= v_max_censo_periodo And v$opcion='R'))
            And v_tiene_objecion='false' then --solo se cargan datos de censo a aquellos que no tengan mas de la cantidad permitida en el periodo configurado
          Begin
            Select id into v_id_ficha_persona From ficha_persona
            Where numero_cedula=v_cedula And numero_cedula is not null 
              And version_ficha_hogar=v_version_ficha_hogar And rownum=1;
          exception
          WHEN NO_DATA_FOUND THEN
            v_id_ficha_persona:=null;
          when others then
            v_id_ficha_persona:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener el registro de una ficha persona pre-existente], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
            v$observaciones:=v$observaciones || '[Error al intentar obtener el registro de una ficha persona pre-existente], cedula:' || v_cedula || ', mensaje:' || err_msg || '. ';
          end;
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
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener el registro de un censo anterior] para la cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
            v$observaciones:=v$observaciones || '[Error al intentar obtener el registro de un censo anterior] para la cedula:' || v_cedula || ', mensaje:' || err_msg ||' . ';
          end;
          if v_id_censo_persona is null And v$opcion<>'C' then
            begin
              v$estado_censo:=1;
              v_id_censo_persona := busca_clave_id;
              INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,
                                        ICV, TIPO_POBREZA, COMENTARIOS,  DEPARTAMENTO, DISTRITO, TIPO_AREA,
                                        BARRIO, DIRECCION, NUMERO_TELEFONO,  NOMBRE_REFERENTE, NUMERO_TELEFONO_REFERENTE, NUMERO_SIME,
                                        ARCHIVO, LINEA, ESTADO,  FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES,  CENSISTA_EXTERNO, CENSISTA_INTERNO, CAUSA_ANULACION)
              values (v_id_censo_persona, 0, v_id_censo_persona, x$persona, to_date('01/01/1900','dd/mm/yyyy'), v_id_ficha_persona,
                      null, null, '', v_id_departamento, v_id_distrito, v_tipoarea,
                      v_id_barrio, substr(v_direccion,1,200), 'Linea Baja :' || v_telefonobaja || ' Celular :' || v_telefonocelular, null, null, x$sime,
                      v_id_carga_archivo, contador, v$estado_censo, current_date, current_user_id, substr(x$observaciones,1,200), v_id_censista_externo, null, null);
            exception
            when others then
              v_id_censo_persona:=null;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 300);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro de censo], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
              v$observaciones:=v$observaciones || '[Error al intentar crear el registro de censo], cedula:' || v_cedula || ', mensaje:' || err_msg || '. ';
            end;
          elsif v_id_censo_persona is not null And v$opcion<>'C' then
            v_id_censo_persona:=null;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: ya existe un registro de censo en estado pendiente}, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador);
            v$observaciones:=v$observaciones || '{Aviso: ya existe un registro de censo en estado pendiente}, cedula:' || v_cedula || '. ';
          end if;
				else
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 300);
          v_id_censo_persona:=null; v_id_ficha_persona:=null;
          if v_cant_censos >0 And v$opcion<>'R' then
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: censo existente, no se creará uno nuevo} cedula:' || v_cedula || ', nombres:' || v_nombres || ' y número de línea:' || contador);
            v$observaciones:=v$observaciones || '{Aviso: censo existente, no se creará uno nuevo} cedula:' || v_cedula;
          elsif v$valor_icv>=0 And v_cant_censos <= v_max_censo_periodo And v$opcion='R' then
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: cantidad censos máxima} cedula:' || v_cedula || ', nombres:' || v_nombres || ' y número de línea:' || contador || ', la cantidad de censos:' || v_cant_censos || ' es mayor que ' || v_max_censo_periodo);
            v$observaciones:=v$observaciones || '{Aviso: cantidad censos máxima} cedula:' || v_cedula || ', la cantidad de censos:' || v_cant_censos || ' es mayor que ' || v_max_censo_periodo || '. ';
          end if;
          if v_tiene_objecion='true' then --solo se cargan datos de censo a aquellos que no tengan mas de la cantidad permitida en el periodo configurado
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '{Aviso: pensión con objecion, no se creará un nuevo censo} cedula:' || v_cedula || ', nombres:' || v_nombres || ' y número de línea:' || contador);
            v$observaciones:=v$observaciones || '{Aviso: pensión con objecion, no se creará un nuevo censo} cedula:' || v_cedula;
          end if;
          if v$id_pension is not null and v$estado_inicial = 1 And v$estado_final= 1 then 
            begin
              v$observaciones:=v$observaciones || '[Aviso: la pensión fué anulada por cantidad máxima de censos] cédula:' || v_cedula || '. ';
              Update pension set estado=2 Where id=v$id_pension; --se anula pension recien creada pues no se hizo solicitud de censo.
            exception
            when others then
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 300);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar anular el registro de pensión, cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
              v$observaciones:=v$observaciones || '[Error al intentar anular el registro de pensión], cedula:' || v_cedula || '. ';
            end;
          end if;
				end if; --if v_cant_censos <= v_max_censo_periodo then
      else
        v_id_censo_persona:=null; v_id_ficha_persona:=null;
      end if;  --fin if x$persona is not null Then
      begin
        x$reg:=busca_clave_id;
        insert into solicitud_pension (ID, VERSION, CODIGO, CEDULA, PERSONA, PENSION, CENSO_PERSONA, FICHA_PERSONA, nombre,
                                       FECHA_TRANSICION, NUMERO_SIME, ARCHIVO, LINEA, INFORMACION_INVALIDA, OBSERVACIONES,
                                       departamento, distrito)
                            values (x$reg, 0, x$reg, v_cedula, x$persona, v$id_pension, v_id_censo_persona, v_id_ficha_persona, v_nombres,
                                    sysdate, x$sime, v_id_carga_archivo, contador, null, substr(v$observaciones,1,2000),
                                    v_id_departamento, v_id_distrito);
      exception
      when others then
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro de solicitud de pensión], cedula:' || v_cedula || ', nombres:' || v_nombres || ', número de línea:' || contador || ', mensaje:' || err_msg);
      end;
			if (v_cant_errores>0) Then
        Update LINEA_ARCHIVO set ERRORES=v_cant_errores Where id=v_id_linea_archivo;
			End If;
      contador_t:=contador_t+1;
			if contador_t>100 then
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
  commit work;
  rastro_proceso_temporal$revive(v$log);
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20000, 'Error en campo ' || auxi || ', línea ' || contador || ', cedula:' || v_cedula || ', mensaje:' || err_msg, true);
end;
/