create or replace function carga_archivo$censostpper(x$archivo VARCHAR2, x$clase_archivo VARCHAR2, x$sime number, observaciones nvarchar2) return number is
	err_msg					      VARCHAR2(2000);
	v$msg                 nvarchar2(2000);
	type namesarray IS TABLE OF VARCHAR2(2000) INDEX BY PLS_INTEGER;
	encabezado            namesarray;
	campo                 namesarray;
	v_id_carga_archivo    number;
	v_id_linea_archivo    number;
	v_version_ficha       varchar2(20);
  v_tipo_dato_respuesta number;
  v_id_fichahogar		    varchar2(20);
	v_id_censista_ext		  varchar2(20);
	archivo             	varchar2(255);
	contador					    integer :=0;
	contador_t            integer :=0;
	contadoraux				    integer :=0;
  archivo_adjunto		    varchar2(255);
	id_archivo_adjunto	  number;
	i                   	integer :=0;
	cant_registro       	integer :=0;
  cant_registroenc		  integer :=0;
	aux                 	VARCHAR2(4000);
  auxi                  integer :=0;
  v_id_fichapersona		  number;
	v_departamento      	varchar2(20);
	v_id_departamento   	number;
  x$persona				      number;
	v_distrito          	varchar2(20);
	v_id_distrito       	number;
	v_barrio            	varchar2(20);
	v_manzana           	varchar2(10);
	v_tipoarea          	varchar2(10) :=6;
	v_id_barrio         	number;
	v_numero_vivienda   	varchar2(10);
	v_numero_formulario 	varchar2(10);
	v_numero_persona      varchar2(10);
	v_direccion         	varchar2(2000);
	cant_sqlpersona       integer :=0;
	v_fecha_censo         date;
	v_fecha_censo_d       varchar2(10);
	v_fecha_censo_m       varchar2(10);
	v_fecha_censo_a       varchar2(10);
  X$COORDENADA_X			  varchar2(13);
  X$COORDENADA_Y			  varchar2(13);
  X$COMENTARIOS			    varchar2(200);
  v_id_rama				      number;
  v_id_ocupacion			  number;
  v_tipo_persona_hogar	varchar2(10);
	v_cant_errores        integer;
  v_edad					      varchar2(3);
  x$reg						      integer;
  v_pregunta				    varchar2(200);
  v_id_pregunta			    number;
  v_rango_respuesta		  number;
	v_id_respuesta			  number;
  v_texto_respuesta		  varchar2(2000);
  v_numero_respuesta	  number;
  v_fecha_respuesta		  date;
  v_tipo_dato_resp		  number;
	v_strsqlpersona		    namesarray;
  v_cedula			  	    varchar2(20);
  v_id_cedula				    number:=NULL;
	v_numero_orden			  varchar2(10);
	v_apellidos				    varchar2(50);
	v_nombres 				    varchar2(50);
  w_nombre                	    varchar2(50);
	w_apellido							      varchar2(50);
  v_fecha_nac_d			    varchar2(10);
	v_fecha_nac_m			    varchar2(10);
	v_fecha_nac_a			    varchar2(10);
	v_fecha_nacimiento	  date;
	v_sexo					      varchar2(10);
	v_estado_civil			  varchar2(10);
  v_paraguayo           varchar2(5);
	v_telefono				    varchar2(13);
	v_tipo_pobreza   		  varchar2(1);
  v_tipo_exep_cedula	  integer;
  v_id_censo_persona	  number;
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
		v_cant_errores:=0; cant_sqlpersona:=0; v_id_fichahogar:=null; v_id_fichapersona:=null;
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
		if contador=0 And aux is not null then --encabezado del archivo
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
                  null, sysdate,null, 'false', observaciones);
        exception
				when others then
					raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
				End;
      else
        Update carga_archivo set OBSERVACIONES=observaciones Where id=v_id_carga_archivo;
			End if;
      cant_registroenc:=cant_registro;
			For i in 0 .. cant_registro LOOP
				if instr(aux,';')=0 then  --nombre de los campos
					encabezado(i):=aux;
				else
					encabezado(i):=substr(aux, 0, instr(aux,';')-1);
					aux:=substr(aux, instr(aux,';')+1);
				end if;
      End loop;
		elsif contador>contadoraux And aux is not null then --valores del archivo
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
        case --identificación de variables segun su encabezado, fijas para ficha_persona, ficha_persona, persona y censo_persona; el resto se busca en preguntas
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
              v_id_barrio:=NULL;v_tipoarea:=1;
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'AVISO: barrio no encontrado:' || campo(i) || ', campo intentado:' || v_barrio || ', dpto:' || v_departamento || ', dtto:' || v_distrito);
            when others then
              v_id_barrio:=NULL;v_tipoarea:=1;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código del Barrio, valor intentado:' || campo(i) || ', mensaje:' || err_msg);
            END;
          When trim(upper(encabezado(i)))='P02' Then --nro vivienda
            v_numero_vivienda:=trim(substr(campo(i),1,10));
          When trim(upper(encabezado(i)))='P03' Then --nro persona
            v_numero_persona:=trim(substr(campo(i),1,10));
          When instr(trim(upper(encabezado(i))),'CLAVE')>0 Then
            v_id_fichahogar:=substr(campo(i),1,19);
          When trim(upper(encabezado(i)))='COORDENADA_X' Then
            X$COORDENADA_X:=substr(campo(i),1,13);
          When trim(upper(encabezado(i)))='COORDENADA_Y' Then
            X$COORDENADA_Y:=substr(campo(i),1,13);
          When (instr(upper(encabezado(i)),'P08')>0) Then --MANZANA
            v_manzana:=substr(campo(i),1,10);
          When trim(upper(encabezado(i)))='P07' Then --AREA
            --v_tipoarea:=substr(campo(i),1,2);
            null;
          When (instr(upper(encabezado(i)),'FORMULARIO')>0) Then
            v_numero_formulario:=substr(campo(i),1,10);
          When (instr(upper(encabezado(i)),'P02')>0) Then --Nro de Vivienda
  					v_numero_vivienda:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='DD' Then
  					v_fecha_censo_d:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='MM' Then
  					v_fecha_censo_m:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='AA' Then
  					v_fecha_censo_a:=substr(campo(i),1,10);
          When (instr(upper(encabezado(i)),'P09')>0) Then --Dirección
            v_direccion:=substr(campo(i),1,2000);
          When upper(trim(encabezado(i)))='OBSERVACIONES' Then
            X$COMENTARIOS:=trim(substr(campo(i),1,198));
          When (instr(upper(encabezado(i)),'P36')>0) Then --Cedula
            Begin
              v_cedula:=trim(substr(campo(i),1,20));
              Select id, apellidos, nombres, fech_nacim, sexo, case nacionalidad when 226 then 'true' else 'false' end as paraguayo, estado_civil
                into v_id_cedula, w_apellido, w_nombre, v_fecha_nacimiento, v_sexo, v_paraguayo, v_estado_civil
              From cedula where numero=v_cedula;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_id_cedula:=NULL;
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error nro cedula no encontrado en la tabla de identificación:' || campo(i));
            END;
          When (instr(upper(encabezado(i)),'L02')>0) Then --Nro Orden
            v_numero_orden:=trim(substr(campo(i),1,10));
          When trim(upper(encabezado(i)))='P31' Then --Apellido
            v_apellidos:=trim(substr(campo(i),1,50));
          When trim(upper(encabezado(i)))='P30' Then --Nombre
            v_nombres:=trim(substr(campo(i),1,50));
          When upper(trim(encabezado(i)))='P38D' Then
            v_fecha_nac_d:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='P38M' Then
            v_fecha_nac_m:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='P38A' Then
            v_fecha_nac_a:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='P33' Then --sexo
            --v_sexo:=substr(campo(i),1,10);
            null;
          When upper(trim(encabezado(i)))='P37' Then --teléfono
            v_telefono:=substr(campo(i),1,13);
          When upper(trim(encabezado(i)))='N33' Then --ocupacion
            BEGIN
              Select id into v_id_ocupacion From ocupacion Where codigo=trim(campo(i));
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_id_ocupacion:=null;
            END;
          When upper(trim(encabezado(i)))='N34' Then --rama
            BEGIN
              Select id into v_id_rama From rama Where codigo=trim(campo(i));
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_id_rama:=null;
            END;
          When upper(trim(encabezado(i)))='P34' Then --parentezco
            v_tipo_persona_hogar:=trim(substr(campo(i),1,10));
          When upper(trim(encabezado(i)))='P32' Then --edad
            v_edad:=substr(campo(i),1,3);
          When upper(trim(encabezado(i)))='STATUS2' Then --tipo de pobreza
            BEGIN
              v_tipo_pobreza:=substr(campo(i),1,1);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_tipo_pobreza:=1;
            END;
            if (v$clase_archivo='STP2C' or v$clase_archivo='STP2V' or v$clase_archivo='STP2P' or v$clase_archivo='STP2A') then --version respuesta tipo pobreza del 1 al 6 imputamos a 1,2
              if (v_tipo_pobreza=2) then
                v_tipo_pobreza:=1;
              elsif (v_tipo_pobreza=5) then
                v_tipo_pobreza:=1;
              elsif (v_tipo_pobreza=3) then
                v_tipo_pobreza:=2;
              elsif (v_tipo_pobreza=4) then
                v_tipo_pobreza:=2;
              elsif (v_tipo_pobreza=5) then
                v_tipo_pobreza:=2;
              end if;
            end if;
				Else --el resto de las variables con literales no fijos, se buscar en las pregutnas de hogar y persona
          null;
        end case;
        For reg2 in (Select * From pregunta_ficha_persona Where version_ficha=v_version_ficha And upper(trim(codigo))=upper(trim(encabezado(i))) Order by codigo) Loop --carga de respuesta persona
          v_id_pregunta:=reg2.id;
          v_rango_respuesta:=null; v_texto_respuesta:=null; v_numero_respuesta:=null; v_fecha_respuesta:=null;
          v_tipo_dato_respuesta:=reg2.tipo_dato_respuesta;
          cant_sqlpersona:=cant_sqlpersona+1;
          v_strsqlpersona(cant_sqlpersona):='Delete From respuesta_ficha_persona Where pregunta=' || v_id_pregunta || ' And ficha=id_ficha_persona';
          cant_sqlpersona:=cant_sqlpersona+1;
          v_strsqlpersona(cant_sqlpersona):='INSERT INTO RESPUESTA_FICHA_PERSONA (ID, VERSION, FICHA, PREGUNTA';
          if v_tipo_dato_respuesta=1 Then --alfanumerico
            v_strsqlpersona(cant_sqlpersona):=  v_strsqlpersona(cant_sqlpersona) ||
                        												' , TEXTO) VALUES (busca_clave_id, 0, id_ficha_persona, ' || v_id_pregunta || ',' || chr(39) || nvl(campo(i),'N/E') || chr(39) || ')';
          elsif v_tipo_dato_respuesta=2 And trim(campo(i)) is  not null Then --numerico
            v_strsqlpersona(cant_sqlpersona):=  v_strsqlpersona(cant_sqlpersona) ||
                        												' , NUMERO)	VALUES (busca_clave_id, 0, id_ficha_persona, ' || v_id_pregunta || ',to_number(' || chr(39) || campo(i) || chr(39) || '))';
          elsif v_tipo_dato_respuesta=3 And trim(campo(i)) is  not null Then --fecha
            v_strsqlpersona(cant_sqlpersona):=  v_strsqlpersona(cant_sqlpersona) ||
                        												' , FECHA) VALUES (busca_clave_id, 0, id_ficha_persona, ' || v_id_pregunta || ',' || chr(39) || campo(i) || chr(39) || ')';
          else --discreto
            begin
              SELECT id into v_rango_respuesta From rango_ficha_persona where pregunta=v_id_pregunta And numeral= campo(i);
            EXCEPTION
						WHEN NO_DATA_FOUND THEN
              v_rango_respuesta:=null;
              v_strsqlpersona(cant_sqlpersona):='';
            when others then
              v_rango_respuesta:=null;
              v_strsqlpersona(cant_sqlpersona):='';
            END;
            if v_rango_respuesta is not null then
              v_strsqlpersona(cant_sqlpersona):=  v_strsqlpersona(cant_sqlpersona) ||
                          												', RANGO) VALUES (busca_clave_id, 0, id_ficha_persona, ' || v_id_pregunta || ',' || v_rango_respuesta || ')';
            end if;
          end if;
        End Loop;
			End Loop; --fin carga de valores de columnas For i in 1 .. cant_registro Loop
			v_fecha_censo:=extraerddmmyyyy(v_fecha_censo_d || '/' || v_fecha_censo_m || '/' || v_fecha_censo_a, 'fecha entrevista', v_id_linea_archivo, 'true');
      --v_fecha_nacimiento:=extraerddmmyyyy(v_fecha_nac_d || '/' || v_fecha_nac_m || '/' || v_fecha_nac_a, 'fecha nacimiento', v_id_linea_archivo, 'false');
      auxi:=-1;
			if v_edad>=65 then --carga persona, sólo jefes de persona
				Begin
          Select id into x$persona From persona where codigo=v_cedula;
        EXCEPTION
				WHEN NO_DATA_FOUND THEN
					x$persona:=null;
				When others then
          x$persona:=NULL;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar persona, cedula[' || v_cedula || '], nombres:[' || v_nombres || '], línea archivo:' || contador || ', mensaje:' || err_msg);
				END;
        auxi:=-2;
        Begin
          if x$persona is null then
						x$persona:=busca_clave_id;
						INSERT INTO PERSONA (ID, VERSION, CODIGO, NOMBRE, APELLIDOS, NOMBRES, FECHA_NACIMIENTO, LUGAR_NACIMIENTO, SEXO,
                                ESTADO_CIVIL, PARAGUAYO, INDIGENA, ETNIA, COMUNIDAD, ICV, TIPO_POBREZA, CEDULA, FECHA_EXPEDICION_CEDULA,
                                HOGAR_COLECTIVO, FECHA_INGRESO_HOGAR, DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO, DIRECCION, TELEFONO_LINEA_BAJA,
                                MONITOREADO, MONITOREO_SORTEO, EDICION_RESTRINGIDA, FICHA, OBSERVACIONES_FICHA, MANZANA, cedula_no_identificacion)
						VALUES (x$persona, 0, v_cedula, w_apellido || ', ' || w_nombre, w_apellido, w_nombre, v_fecha_nacimiento, null, v_sexo,
                    v_estado_civil, v_paraguayo, 'false', null, null, null, v_tipo_pobreza, v_id_cedula, null,
                    null, null, v_id_departamento, v_id_distrito, v_tipoarea, v_id_barrio, v_direccion, v_telefono,
                    'false', 'false', 'true', NULL, observaciones, v_manzana, v_cedula);
          else
            Update persona set TIPO_POBREZA=v_tipo_pobreza, nombre=w_apellido || ', ' || w_nombre, nombres= w_nombre, apellidos=w_apellido, fecha_nacimiento=v_fecha_nacimiento
            Where id=x$persona;
          end if;
        EXCEPTION
					When others then
            x$persona:=NULL;
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar actualizar la persona cédula:' || v_cedula || ', mensaje:' || err_msg);
					END;
			end if; --if v_cedula is not null then
			if v_id_fichahogar is not null And v_numero_orden>0 then  --carga ficha persona solo cuando el orden en el persona sea mayor que cero (exista)
        auxi:=-3;
				v_id_fichapersona := busca_clave_id;
				Begin
					if v_cedula is null then
						v_tipo_exep_cedula:=1;
					else
						v_tipo_exep_cedula:=null;
					end if;
					INSERT INTO FICHA_PERSONA (ID, VERSION, CODIGO, NOMBRE, FICHA_HOGAR, NOMBRES, VERSION_FICHA_HOGAR, 
                                    APELLIDOS, EDAD, SEXO_PERSONA, TIPO_PERSONA_HOGAR, MIEMBRO_HOGAR, NUMERO_ORDEN_IDENTIFICACION,
                                    NUMERO_CEDULA, TIPO_EXCEPCION_CEDULA, FECHA_NACIMIENTO, NUMERO_TELEFONO, ESTADO_CIVIL, OCUPACION, RAMA)
					VALUES (v_id_fichapersona, 0, v_id_fichapersona, w_apellido || ', ' || w_nombre, v_id_fichahogar, w_nombre, v_version_ficha,
                  w_apellido, v_edad, v_sexo, v_tipo_persona_hogar, 'true', v_numero_orden,
                  v_cedula, v_tipo_exep_cedula, v_fecha_nacimiento, v_telefono, v_estado_civil, v_id_ocupacion, v_id_rama);
				exception
				when others then
					v_id_fichapersona:=null;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar ficha persona, cedula[' || v_cedula || '], nombres:[' || v_nombres || '], línea archivo:' || contador || ', mensaje:' || err_msg);
				End;
				if x$persona is not null And v_id_fichapersona is not null then --si existe la persona y se la carga la ficha, se actualiza el registro
					Begin
						update persona set ficha=v_id_fichapersona where id=x$persona;
					Exception
					when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar código ficha persona en persona, cedula[' || v_cedula || '], nombres:[' || v_nombres || '], línea archivo:' || contador || ', mensaje:' || err_msg);
					End;
				end if;
			end if; --FIN carga ficha persona
			if x$persona is not null And v_id_fichapersona is not null And v_edad>=65 then --se carga el cento cuando es el jefe del persona
        auxi:=-4;
				Begin
					v_id_censo_persona := busca_clave_id;
          INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,
                                    ICV, TIPO_POBREZA, COMENTARIOS,  DEPARTAMENTO, DISTRITO, TIPO_AREA,
                                    BARRIO, DIRECCION, NUMERO_TELEFONO,  NOMBRE_REFERENTE, NUMERO_TELEFONO_REFERENTE, NUMERO_SIME,
                                    ARCHIVO, LINEA, ESTADO,  FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES,  CENSISTA_EXTERNO, CENSISTA_INTERNO, CAUSA_ANULACION)
                        values (v_id_censo_persona, 0, v_id_censo_persona, x$persona, v_fecha_censo, v_id_fichapersona,
                                null, v_tipo_pobreza, X$COMENTARIOS, v_id_departamento, v_id_distrito, v_tipoarea,
                                v_id_barrio, v_direccion, v_telefono, null, null, x$sime,
                                v_id_carga_archivo, contador, 4, sysdate, null, observaciones, v_id_censista_ext, null, null);
				Exception
				When others then
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar censo persona, cédula:' || v_cedula || ', mensaje:' || err_msg);
				End;
			End if;
			if v_id_fichapersona is not null then
				For i in 1 .. cant_sqlpersona LOOP
          Begin
            v_strsqlpersona(i):=replace(v_strsqlpersona(i),'id_ficha_persona',v_id_fichapersona);
          execute immediate v_strsqlpersona(i);
					Exception
          when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar insertar un registro de respuesta persona, sql:' || substr(v_strsqlpersona(i),1,300) || ', linea:' || contador || ', mensaje '|| err_msg);
					end;
				end loop;
			End if;
      if (v_cant_errores>0) Then
        auxi:=-5;
				Update LINEA_ARCHIVO set ERRORES=ERRORES+v_cant_errores Where id=v_id_linea_archivo;
			End If;
			contador_t:=contador_t+1;
			if contador_t>1000 then
				update carga_archivo set directorio=contador Where id=v_id_carga_archivo;
				commit work;
				rastro_proceso_temporal$revive(v$log);
				contador_t:=0;
			end if;
		end if; --elsif contador>contadoraux then
    contador:=contador+1; auxi:=-6;
	End loop;
  auxi:=-7;
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
  auxi:=-8;
  commit;  
  rastro_proceso_temporal$revive(v$log);
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(-20100, err_msg || ' en linea:' || contador || ', columna:' || auxi || ', campo:' || campo(auxi) || ', max encabezado:' || cant_registroenc, true);
end;
/
