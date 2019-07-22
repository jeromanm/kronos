create or replace function carga_archivo$censostpcar(x$archivo VARCHAR2, x$clase_archivo VARCHAR2, x$sime number, observaciones nvarchar2) return number is
	err_msg					      VARCHAR2(2000);
	type namesarray IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
	encabezado            namesarray;
	campo                 namesarray;
	v_id_carga_archivo    number;
	v_id_linea_archivo    number;
	v_version_ficha		    varchar2(20);
	v_id_censista_ext		  varchar2(20);
  v_tipo_dato_respuesta number;
	archivo             	varchar2(255);
	contador					    integer :=0;
	contador_t            integer :=0;
	contadoraux				    integer :=0;
  archivo_adjunto		    varchar2(255);
	id_archivo_adjunto	  number;
	i                   	integer :=0;
  auxi                  integer :=0;
  cant_registroenc		  integer :=0;
	cant_registro       	integer :=0;
	aux                 	VARCHAR2(4000);
	v_codigo            	varchar2(100);
	v_anio              	varchar2(4);
  v_id_fichahogar		    varchar2(20);
	v_departamento      	varchar2(20);
	v_id_departamento   	varchar2(20) := NULL;
	v_distrito          	varchar2(20);
	v_id_distrito       	varchar2(20) := NULL;
	v_barrio            	varchar2(20);
	v_manzana           	varchar2(10);
	v_tipoarea          	number:=6;
	v_id_barrio         	varchar2(20) := NULL;
	v_numero_vivienda   	varchar2(10);
	v_numero_formulario 	varchar2(10);
	v_numero_hogar      	varchar2(10);
	v_direccion         	varchar2(2000);
	cant_sqlhogar         integer :=0;
	v_fecha_censo         date;
	v_fecha_censo_d       varchar2(10);
	v_fecha_censo_m       varchar2(10);
	v_fecha_censo_a       varchar2(10);
  X$COORDENADA_X			  varchar2(13);
  X$COORDENADA_Y			  varchar2(13);
  X$COMENTARIOS			    varchar2(500);
  v_cant_errores        integer;
  x$reg						      integer;
  v_pregunta				    varchar2(200);
  v_id_pregunta			    number;
  v_rango_respuesta		  number;
	v_id_respuesta			  number;
  v_texto_respuesta		  varchar2(2000);
  v_numero_respuesta	  number;
  v_fecha_respuesta		  date;
  v_tipo_dato_resp		  number;
	v_strsqlhogar         namesarray;
  v_dist								number;
  v_jaro								number;
  v$log rastro_proceso_temporal%ROWTYPE;
  v$clase_archivo       varchar2(20);
begin --modificado SIAU 11885
	v$log := rastro_proceso_temporal$select(); 
  Select codigo into v$clase_archivo From clase_archivo where id=x$clase_archivo;
  if (v$clase_archivo='STP1C' or v$clase_archivo='STP1V' or v$clase_archivo='STP1P' or v$clase_archivo='STP1A') then
    v_version_ficha:='STP1/2016';
  elsif (v$clase_archivo='STP2C' or v$clase_archivo='STP2V' or v$clase_archivo='STP2P' or v$clase_archivo='STP2A') then
    v_version_ficha:='STP2/2016';
  else
    Begin
      Select valor Into v_version_ficha From variable_global where numero=103;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
    End;
  end if;
  Begin
    Select id Into v_id_censista_ext From censista where trim(nombre)='DPNC';
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		v_id_censista_ext:=NULL;
  End;
	For reg in (Select * From csv_imp_temp Where archivo=x$archivo order by 1) loop
		v_fecha_censo_a:=0; v_fecha_censo_m:=0; v_fecha_censo_d:=0; v_fecha_censo:=NULL; v_cant_errores:=0;
		v_id_barrio:=NULL; v_id_distrito:=99; v_id_departamento:=99; cant_sqlhogar:=0;
		if trim(reg.registro) is not null then
			aux:=replace(trim(substr(trim(reg.registro),1,4000)),chr(39), '');
			aux:=replace(aux,'"', '');
			aux:=replace(aux,chr(13), '');
			aux:=replace(aux,chr(10), '');
      aux:=replace(aux,'ï»¿', '');
   	else
			aux:=null;
		end if;
		if (aux is not null) then
			Select length(aux)-length(replace(aux,';','')) Into cant_registro From dual;  --cantidad de columnas
		else
			cant_registro:=0;
		end if;
		if contador=0 then --encabezado del archivo
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
								null, sysdate, null, 'false', observaciones);
        exception
				when others then
					raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
				End;
      else
        Update carga_archivo set OBSERVACIONES=observaciones Where id=v_id_carga_archivo;
			End if;
			For i in 0 .. cant_registro LOOP
				if instr(aux,';')=0 then  --nombre de los campos
					encabezado(i):=aux;
				else
					encabezado(i):=substr(aux, 0, instr(aux,';')-1);
					aux:=substr(aux, instr(aux,';')+1);
				end if;
      End loop;
      cant_registroenc:=cant_registro;
		elsif contador>contadoraux then --valores del archivo
			Begin
				v_id_linea_archivo:=busca_clave_id;
				INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
				VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, substr(reg.registro,1,2000), '');
			exception
      when others then
				raise_application_error(-20001,'Error al intentar insertar la linea (' || contador || ') del archivo, mensaje:'|| sqlerrm, true);
      End;
      For i in 0 .. cant_registroenc Loop
        auxi:=i;
				if instr(aux,';')=0 then --csv separado por comas, si no hay mas comas se sale
					campo(i):=aux;
				else
					campo(i):=substr(aux, 0, instr(aux,';')-1);
					aux:=substr(aux, instr(aux,';')+1);
				end if;
        X$COMENTARIOS:='';
        case --identificación de variables segun su encabezado, fijas para ficha_hogar, ficha_persona, persona y censo_persona; el resto se busca en preguntas
          When trim(upper(encabezado(i)))='P01A' Then --departamento 
            BEGIN
              Select trim(to_char(campo(i),'00')) into v_departamento from dual;
              Select id into v_id_departamento From departamento Where codigo=trim(v_departamento);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_id_departamento:=99;
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Departamento no encontrado:' || campo(i));
            when others then
              v_id_departamento:=99;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código del Departamento, valor intentado:' || campo(i) || ', mensaje:' || err_msg);
            END;
          When trim(upper(encabezado(i)))='P01B' Then --distrito
            BEGIN
              if length(campo(i))<=2 then
                Select trim(v_departamento) ||  trim(to_char(campo(i),'00')) into v_distrito from dual;
              else 
  							Select to_char(campo(i),'0000') into v_distrito from dual;
              end if;
              Select id into v_id_distrito From distrito Where codigo=trim(v_distrito);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_id_distrito:=99;
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Distrito no encontrado:' || campo(i));
            when others then
              v_id_distrito:=99;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código del Distrito, valor intentado:' || campo(i) || ', mensaje:' || err_msg);
            END;
          When trim(upper(encabezado(i)))='P01ABC' Then --barrio
            begin
              if length(trim(campo(i)))<=3 then
                if to_number(campo(i))<10 then
                  Select trim(v_distrito) || trim(to_char(to_number(campo(i)),'000')) into v_barrio from dual;
                else
                  Select trim(v_distrito) || '0' || trim(to_number(campo(i))) into v_barrio from dual;  
                end if;
              else
                Select to_char(campo(i),'0000000') into v_barrio from dual;
              end if;
              Select id, tipo_area into v_id_barrio,v_tipoarea From barrio Where codigo=trim(v_barrio);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_id_barrio:=NULL; v_tipoarea:=1;
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'AVISO: barrio no encontrado:' || campo(i) || ', campo intentado:' || v_barrio || ', dpto:' || v_departamento || ', dtto:' || v_distrito);
            when others then
              v_id_barrio:=NULL; v_tipoarea:=1;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código del Barrio, valor intentado:' || campo(i) || ', mensaje:' || err_msg);
            END;
          When trim(upper(encabezado(i)))='P02' Then --nro vivienda
            v_numero_vivienda:=trim(substr(campo(i),1,10));
          When trim(upper(encabezado(i)))='P03' Then --nro hogar
            v_numero_hogar:=trim(substr(campo(i),1,10));
          When instr(trim(upper(encabezado(i))),'CLAVE')>0 Then
            v_id_fichahogar:=trim(substr(campo(i),1,19));
          When trim(upper(encabezado(i)))='COORDENADA_X' Then
            X$COORDENADA_X:=substr(campo(i),1,13);
          When trim(upper(encabezado(i)))='COORDENADA_Y' Then
            X$COORDENADA_Y:=substr(campo(i),1,13);
          When (instr(upper(encabezado(i)),'P08')>0) Then --MANZANA
            v_manzana:=substr(campo(i),1,10);
          When trim(upper(encabezado(i)))='P07' Then --AREA
            --v_tipoarea:=substr(campo(i),1,1);
            null;
          When (instr(upper(encabezado(i)),'FORMULARIO')>0) Then
            v_numero_formulario:=substr(campo(i),1,10);
          When (instr(upper(encabezado(i)),'P02')>0) Then --Nro de Vivienda
            v_numero_vivienda:=substr(campo(i),1,10);
          When (instr(upper(encabezado(i)),'HOGAR')>0) Then
            v_numero_hogar:=campo(i);
          When upper(trim(encabezado(i)))='DD' Then
            v_fecha_censo_d:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='MM' Then
            v_fecha_censo_m:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='AA' Then
            v_fecha_censo_a:=substr(campo(i),1,10);
          When (instr(upper(encabezado(i)),'P09')>0) Then --Dirección
            v_direccion:=substr(campo(i),1,2000);
          When upper(trim(encabezado(i)))='OBSERVACIONES' Then
            X$COMENTARIOS:= trim(substr(campo(i),1,195));
          else
            null;
        End Case; --identificación de variables segun su encabezado, fijas para ficha_hogar, ficha_persona, persona y censo_persona; el resto se busca en preguntas
        For reg1 in (Select * From pregunta_ficha_hogar Where version_ficha=v_version_ficha And upper(trim(codigo))=upper(trim(encabezado(i))) Order by codigo) Loop
          v_pregunta:=reg1.codigo; v_id_pregunta:=reg1.id;
          v_rango_respuesta:=null; v_texto_respuesta:=null; v_numero_respuesta:=null; v_fecha_respuesta:=null;
          v_id_respuesta:=busca_clave_id;
          v_tipo_dato_respuesta:=reg1.tipo_dato_respuesta;
          if v_tipo_dato_respuesta=1 And trim(campo(i)) is  not null Then --alfanumerico
            cant_sqlhogar:=cant_sqlhogar+1;
            v_strsqlhogar(cant_sqlhogar):= 'INSERT INTO RESPUESTA_FICHA_HOGAR (ID, VERSION, FICHA, PREGUNTA, TEXTO)
                                            VALUES (' || v_id_respuesta || ', 0, id_ficha_hogar, ' || v_id_pregunta || ',' || chr(39) || substr(campo(i),1,2000) || chr(39) ||  ')';
          elsif v_tipo_dato_respuesta=2 And trim(campo(i)) is  not null Then --numerico
            cant_sqlhogar:=cant_sqlhogar+1;
            v_strsqlhogar(cant_sqlhogar):= 'INSERT INTO RESPUESTA_FICHA_HOGAR (ID, VERSION, FICHA, PREGUNTA, NUMERO)
                                            VALUES (' || v_id_respuesta || ', 0, id_ficha_hogar, ' || v_id_pregunta || ',to_number(' || chr(39) || campo(i) || chr(39) || '))';
          elsif v_tipo_dato_respuesta=3 And trim(campo(i)) is  not null Then --fecha
            cant_sqlhogar:=cant_sqlhogar+1; 
            v_strsqlhogar(cant_sqlhogar):= 'INSERT INTO RESPUESTA_FICHA_HOGAR (ID, VERSION, FICHA, PREGUNTA, FECHA)
                                            VALUES (' || v_id_respuesta || ', 0, id_ficha_hogar, ' || v_id_pregunta || ',' || chr(39) || campo(i) || chr(39) || ')';
          elsif v_tipo_dato_respuesta=4 And trim(campo(i)) is  not null then
            begin
              SELECT id into v_rango_respuesta From rango_ficha_hogar where pregunta=v_id_pregunta And numeral= campo(i);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_rango_respuesta:=null;
            end;
            if v_rango_respuesta is not null then
              cant_sqlhogar:=cant_sqlhogar+1;
              v_strsqlhogar(cant_sqlhogar):= 'INSERT INTO RESPUESTA_FICHA_HOGAR (ID, VERSION, FICHA, PREGUNTA, RANGO)
                                              VALUES (' || v_id_respuesta || ', 0, id_ficha_hogar, ' || v_id_pregunta || ',' || v_rango_respuesta || ')';
            end if;
          end if;
        End Loop; --fin respuesta hogar
			End Loop; --fin carga de valores de columnas For i in 1 .. cant_registro Loop
			v_fecha_censo:=extraerddmmyyyy(v_fecha_censo_d || '/' || v_fecha_censo_m || '/' || v_fecha_censo_a, 'fecha entrevista', v_id_linea_archivo, 'true');
			Select to_char(sysdate, 'yyyy') into v_anio From dual;
      auxi:=-1;
      Begin
				INSERT INTO FICHA_HOGAR (ID, VERSION, CODIGO, NUMERO_FORMULARIO, NUMERO_VIVIENDA, NUMERO_HOGAR,
												FECHA_ENTREVISTA, CENSISTA_EXTERNO, CENSISTA_INTERNO, SUPERVISOR, CRITICO_CODIFICADOR, DIGITADOR,
												COMENTARIOS, VERSION_FICHA_HOGAR, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES_ACEPTAR,
												COORDENADA_X, COORDENADA_Y, DEPARTAMENTO, DISTRITO, TIPO_AREA,
												BARRIO, MANZANA, DIRECCION, ARCHIVO, LINEA, Numero_Sime)
				VALUES (v_id_fichahogar, 0, v_id_fichahogar, v_numero_formulario, v_numero_vivienda, v_numero_hogar,
							v_fecha_censo, v_id_censista_ext, NULL, NULL, NULL, NULL,
							X$COMENTARIOS, v_version_ficha, 1, v_fecha_censo, current_user_id(), '',
							X$COORDENADA_X, X$COORDENADA_Y, v_id_departamento, v_id_distrito, v_tipoarea,
							v_id_barrio, v_manzana, v_direccion, v_id_carga_archivo, contador, x$sime);
			exception
			when others then
				v_id_fichahogar:=null;
				v_cant_errores:=v_cant_errores+1;
				err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar ficha hogar, coddpto[' || v_departamento || '], coddtto:[' || v_distrito || '], tipo area:[' || v_tipoarea || '], línea archivo:' || contador || ', mensaje:' || err_msg);
			end;
      auxi:=-2;
			if v_id_fichahogar is not null then
				For i in 1 .. cant_sqlhogar LOOP
          Begin
            v_strsqlhogar(i):=replace(v_strsqlhogar(i),'id_ficha_hogar',v_id_fichahogar);
						execute immediate v_strsqlhogar(i);
					Exception
          when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar insertar un registro de respuesta hogar, sql:' || substr(v_strsqlhogar(i),1,300) || ', linea:' || contador || ', mensaje '|| err_msg);
					end;
				end loop;
			End if;
      auxi:=-3;
			if (v_cant_errores>0) Then
				Update LINEA_ARCHIVO set ERRORES=v_cant_errores Where id=v_id_linea_archivo;
			End If;
      auxi:=-4;
      contador_t:=contador_t+1;
			if contador_t>1000 then
				update carga_archivo set directorio=contador Where id=v_id_carga_archivo;
				commit work;
				rastro_proceso_temporal$revive(v$log);
				contador_t:=1;
			end if;
      auxi:=-5;
		end if; --elsif contador>contadoraux then
    contador:=contador+1;
	End loop;
  auxi:=-6;
  begin
		Delete From CSV_IMP_TEMP Where archivo=x$archivo;
		Update CARGA_ARCHIVO set PROCESO_SIN_ERRORES='true', directorio=contador Where id=v_id_carga_archivo;
		Select Count(a.id) into v_cant_errores
		From LINEA_ARCHIVO a inner join ERROR_ARCHIVO b on a.id = b.linea
		Where a.CARGA=v_id_carga_archivo;
		if v_cant_errores>0 then
			Update CARGA_ARCHIVO set ARCHIVO_SIN_ERRORES='false' Where id=v_id_carga_archivo;
		end if;
	exception
	when others then
		err_msg := SUBSTR(SQLERRM, 1, 200);
		x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar cerrar el proceso de carga, mensaje:' || err_msg);
	end;
  commit;
  rastro_proceso_temporal$revive(v$log);
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(-20100, err_msg || ' en linea:' || contador || ', columna:' || auxi || ', campo:' || campo(auxi) || ', max encabezado:' || cant_registroenc, true);
end;
/