create or replace function carga_archivo$campo(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, x$observaciones nvarchar2)
  return number is
	err_msg                     VARCHAR2(200);
	v_cant_errores					  	integer:=0;
  aux                         VARCHAR2(4000);
	v_id_carga_archivo          number;
	v_id_linea_archivo          number;
	cant_registro               integer :=0;
	archivo_adjunto					    varchar2(255);
	id_archivo_adjunto				  number;
	valor_columna               varchar2(1000);
	contador                    integer :=1;
	contador_t                  integer :=1;
	contadoraux							    integer :=1;
	i                           integer :=-1;
	auxi                        integer;
	x$persona							      number;
	v_cedula                	  varchar2(20);
  v_monitoreo                 varchar2(5);
	v_estado	   						    integer;
	v_observacion						    varchar2(2000);
  v_nombre_estado          	  varchar2(20);
  v_censista              	  varchar2(20);
	x$censo								      number;
	x$reg								  	    number;
  v_id_censista_interno       number;
	v$log rastro_proceso_temporal%ROWTYPE;
  v_id_ficha_persona          number;
  v_version_ficha_hogar       varchar2(20):= NULL;
  w_nombre                	  varchar2(50);
	w_apellido							    varchar2(50);
	v_fecha_nacimiento          date;
	v_estado_civil              varchar2(1) :='7';
	v_sexo                      varchar2(1) :='7';
  v_edad                      varchar2(3);
  v_paraguayo                 varchar2(5) :='true';
  v_id_cedula                 number;
begin
	v$log := rastro_proceso_temporal$select();
  Begin
		Select valor Into v_version_ficha_hogar From variable_global where numero=103;  --version ficha hogar activa
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
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
								x$sime, sysdate, null, 'false', x$observaciones);
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
          v_cedula:=trim(substr(valor_columna,1,20));
          Begin
            v_cedula:=trim(substr(valor_columna,1,20));
						Select id, apellidos, nombres, fech_nacim, sexo, case nacionalidad when 226 then 'true' else 'false' end as paraguayo, estado_civil
                into v_id_cedula, w_apellido, w_nombre, v_fecha_nacimiento, v_sexo, v_paraguayo, v_estado_civil
            From cedula where numero=v_cedula;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_cedula:=NULL; w_apellido:=null; w_nombre:=null;
            v_fecha_nacimiento:=null; v_sexo:=null; v_paraguayo:=null; v_estado_civil:=null;
						v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error: nro cédula no encontrado en la tabla de identificacion]:' || valor_columna);
					END;
        When 1 Then
          v_nombre_estado:=trim(substr(valor_columna,1,20));
          if trim(upper(valor_columna))='CENSADO' Then
            v_estado:=4;
          elsif trim(upper(valor_columna))='NO CENSADO' Then
            v_estado:=3;
          elsif trim(upper(valor_columna))='ANULADO' Then
            v_estado:=5;
          else
            v_estado:=1;
          end if;
				When 2 Then
          v_observacion:=trim(substr(valor_columna,1,2000));
        When 3 Then
          v_censista:=trim(substr(valor_columna,1,20));
          Begin
            Select id_usuario Into v_id_censista_interno From usuario where upper(trim(codigo_usuario))=upper(trim(valor_columna));
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_id_censista_interno:=NULL;
            v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: no se encontraron registros del censista interno, cédula:' || v_cedula || ', valor leído:' || valor_columna);
          when others then
            x$censo:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener registros del censista interno de la cédula de la persona:' || v_cedula || ', mensaje:' || err_msg);
          End;
        else
          null;
        end case;
			End loop;
      v_id_ficha_persona:=null;
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
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar obtener el registro de una ficha persona pre-existente], cedula:' || v_cedula || ', nombres:' || w_nombre || ', número de línea:' || contador || ', mensaje:' || err_msg);
      end;
      if v_id_ficha_persona is null And v_estado=4 then
				begin
          Select calcular_edad(v_fecha_nacimiento) into v_edad From dual;
          v_id_ficha_persona := busca_clave_id;
          INSERT INTO FICHA_PERSONA (ID, VERSION, CODIGO, NOMBRE, FICHA_HOGAR, NOMBRES, version_ficha_hogar,
                                    APELLIDOS, EDAD, SEXO_PERSONA, TIPO_PERSONA_HOGAR, MIEMBRO_HOGAR, NUMERO_ORDEN_IDENTIFICACION,
                                    NUMERO_CEDULA, TIPO_EXCEPCION_CEDULA, FECHA_NACIMIENTO, NUMERO_TELEFONO, ESTADO_CIVIL)
						    VALUES (v_id_ficha_persona, 0, v_id_ficha_persona, w_apellido || ', ' || w_nombre, null, w_nombre, v_version_ficha_hogar,
						            w_apellido, v_edad, v_sexo, 1, 'true', 1,
						            v_cedula, null, v_fecha_nacimiento, null, v_estado_civil);
          exception
          when others then
            v_id_ficha_persona:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro de ficha persona], cedula:' || v_cedula || ', nombre:' || w_nombre || ', número de línea:' || contador || ', mensaje:' || err_msg);
          end;
          if v_id_ficha_persona is not null then
            for reg in (select * from pregunta_ficha_persona where version_ficha=v_version_ficha_hogar) loop
              begin
                insert into respuesta_ficha_persona (id, version, ficha, pregunta)
                values (busca_clave_id, 0, v_id_ficha_persona, reg.id);
              exception
              when others then
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 200);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, '[Error al intentar crear el registro de la respuesta de ficha persona], cedula:' || v_cedula || ', nombre:' || w_nombre || ', número de línea:' || contador || ', mensaje:' || err_msg);
              end;
            end loop;
            Begin
							Update persona set ficha=v_id_ficha_persona where codigo=v_cedula;
            Exception
            WHEN NO_DATA_FOUND THEN
              null;
						when others then
              v_cant_errores:=v_cant_errores+1;
							err_msg := SUBSTR(SQLERRM, 1, 200);
							x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar código ficha persona en persona, cedula[' || v_cedula || '], nombres:[' || w_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
            End;
          end if;
      end if;
      x$censo:=null;
			Begin
				Select pe.id, cp.id, pe.MONITOREO_SORTEO
          into x$persona, x$censo, v_monitoreo
        From persona pe inner join censo_persona cp on pe.id = cp.persona
				Where pe.codigo=v_cedula And rownum=1 And cp.estado=1 
        Order by cp.id desc;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
        x$censo:=null;
				v_cant_errores:=v_cant_errores+1;
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error no se encontraron registros del censo de la persona cédula:' || v_cedula);
			when others then
        x$censo:=null;
				v_cant_errores:=v_cant_errores+1;
				err_msg := SUBSTR(SQLERRM, 1, 200);
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener registros del censo de la cédula de la persona:' || v_cedula || ', mensaje:' || err_msg);
			End;
      if x$censo is not null Then
				Begin
					update censo_persona set estado=v_estado, observaciones=v_observacion, censista_interno= v_id_censista_interno, 
                                  ficha=v_id_ficha_persona, fecha=to_date('01/01/1900','dd/mm/yyyy')
          Where id=x$censo;
        EXCEPTION
				when others then
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 300);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar el registro de censo, cedula:' || v_cedula || ', número de línea:' || contador || ', mensaje:' || err_msg);
				END;
			end if;
      begin
        x$reg:=busca_clave_id;
        Insert Into REPORTE_CAMPO (ID, VERSION, CODIGO, CEDULA, ESTADO, CENSISTA, CENSO_PERSONA, comentario,
                                FECHA_TRANSICION, NUMERO_SIME, ARCHIVO, LINEA, INFORMACION_INVALIDA, OBSERVACIONES)
        values (x$reg, 0, x$reg, v_cedula, v_nombre_estado, v_censista, x$censo, v_observacion,
              sysdate, x$sime, v_id_carga_archivo, contador, null, x$observaciones);
      EXCEPTION
				when others then
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 300);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de reporte de campo, cedula:' || v_cedula || ', número de línea:' || contador || ', mensaje:' || err_msg);
				END;
			if (v_cant_errores>0) Then
        Update LINEA_ARCHIVO set ERRORES=v_cant_errores Where id=v_id_linea_archivo;
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
