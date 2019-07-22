create or replace function carga_archivo$censoxlotep(x$archivo VARCHAR2, x$clase_archivo VARCHAR2, x$sime number, x$observaciones nvarchar2) return number is
	err_msg               		      VARCHAR2(2000);
	v$id_ficha_hogar     		        number;
	type namesarray IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
	encabezado            		      namesarray;
	campo                 		      namesarray;
	v_strsql							          varchar2(4000);
	v_strsqlpersona       		      namesarray;
	v_id_carga_archivo    		      number;
	v_id_linea_archivo    		      number;
	v_version_ficha_hogar 		      varchar2(20);
  v$version_ficha_historico	      varchar2(20);
	archivo             			      varchar2(255);
	contador							          integer :=0;
	contador_t						          integer :=0;
	contadoraux						          integer :=0;
  archivo_adjunto				          varchar2(255);
	id_archivo_adjunto			        number;
	i                   			      integer :=0;
	cant_registro       			      integer :=0;
	aux                 			      VARCHAR2(4000);
  auxi                            integer;
	v_departamento      			      varchar2(20);
	v_id_departamento   			      varchar2(20) := NULL;
	v_distrito          			      varchar2(20);
	v_id_distrito       			      varchar2(20) := NULL;
	v_barrio            			      varchar2(20);
	v_manzana           			      varchar2(20);
	v_tipoarea          			      varchar2(10) :=6;
	v_id_barrio         			      varchar2(20) := NULL;
  v$miembro_hogar                 varchar2(5) := 'true';
	v_numero_vivienda   			      varchar2(10);
	v_numero_formulario 			      varchar2(10);
	v_numero_hogar      			      varchar2(10);
	v_gps_x							            varchar2(13);
	v_gps_y							            varchar2(13);
	v_id_ficha_persona  			      number;
  v_direccion         			      varchar2(200);
	x$persona        				        number;
	v_id_censo_persona  			      number;
	v_cedula                        varchar2(10);
	v_id_cedula						          number;
	v_tipo_exepcion_cedula          integer :=1;
	v_nombre                        varchar2(100);
	v_nombres                       varchar2(50);
	v_apellidos                     varchar2(50);
	v_telefono                      varchar2(20);
	v_sexo                          integer;
	v_edad                          varchar2(3);
	v_tipo_persona_hogar            integer;
  v_paraguayo                 	varchar2(10);
	v_numero_orden                  number;
	v_fecha_nacimiento              date;
	v_fecha_nacimiento_d            number;
	v_fecha_nacimiento_m            number;
	v_fecha_nacimiento_a            number;
	v_estado_civil                  integer :=7; --no suministrado
	v_id_ocupacion                  number;
	v_id_rama                       number;
	v_icv                           number;
  v$valor_icv                     varchar2(20);
	cant_sqlpersona                 integer :=0;
	v_fecha_censo                   date;
	v_fecha_censo_d                 number;
	v_fecha_censo_m                 number;
	v_fecha_censo_a                 number;
	v_id_pregunta                   number;
	v_tipo_dato_respuesta           number;
	v_rango_respuesta               number;
	v_texto_respuesta               varchar2(100);
	v_numero_respuesta              number;
	v_fecha_respuesta               date;
	v_cant_errores                  integer;
	x$reg								            number;
	v_current_user_id				        number;
  v$log                           rastro_proceso_temporal%ROWTYPE;
  v_clase_pension                 number:=150498912213505560;
  v_id_tramite_administrativo     number;
  v$id_denuncia_pension           number;
  v_tipo_tramite_administrativo   number;
  v_id_pension                    number;
  v_estado_pension                number;
  w_nombre                	      varchar2(50);
	w_apellido							        varchar2(50);
	v_porc_match_nombre				      number;
	v_porc_match_apellido			      number;
  v$str_censista                  varchar2(10);
  v$id_censista                   number;
  v$tipo_pobreza                  number;
  v$tipo_accion                   varchar2(5);
  v$cant_pension_solicitada       number:=0;
  v$nacionalidad                  varchar2(50);
begin
	v$log := rastro_proceso_temporal$select();
  Begin
    Select valor Into v_version_ficha_hogar From variable_global where numero=103;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
  End;
  For reg in (Select * From csv_imp_temp Where archivo=x$archivo order by 1) loop
		if trim(reg.registro) is not null then
			aux:=replace(trim(substr(trim(reg.registro),1,4000)),chr(39), '');
      aux:=replace(aux,'"', '');
			aux:=replace(aux,chr(13), '');
			aux:=replace(aux,chr(10), '');
    else
			aux:=null;
    end if;
		v_cedula:=NULL; v_nombres:='N/E'; v_apellidos:='N/E'; v_sexo:=7; v_edad:=0; v_tipo_persona_hogar:=1; v_numero_orden:=0;
		v_fecha_nacimiento:=null; v_estado_civil:=7; v_id_ocupacion:=null; v_id_rama:=null; v_fecha_nacimiento_a:=0; v_fecha_nacimiento_m:=0; v_fecha_nacimiento_d:=0;
		v_fecha_censo_a:=0; v_fecha_censo_m:=0; v_fecha_censo_d:=0; v_fecha_censo:=NULL; v_cant_errores:=0; v_id_ficha_persona := null; v$id_ficha_hogar:=null;
		v_manzana:=NULL; v_id_barrio:=NULL; v_id_distrito:=99; v_id_departamento:=99; cant_sqlpersona:=0; v$miembro_hogar:='true'; v$tipo_pobreza:=null;
    v$version_ficha_historico:=v_version_ficha_hogar; v$tipo_accion:=null; v_id_pension:=null;
		if (aux is not null) then
			Select length(aux)-length(replace(aux,';','')) Into cant_registro From dual;  --cantidad de columnas
		else
			cant_registro:=0;
		end if;
		if contador=contadoraux And aux is not null then --encabezado del archivo
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
        Update carga_archivo set OBSERVACIONES=x$observaciones Where id=v_id_carga_archivo;
			End if;
			For i in 0 .. cant_registro LOOP
        auxi:=i;
				if instr(aux,';')=0 then
					encabezado(i):=aux;
				else
					encabezado(i):=substr(aux, 0, instr(aux,';')-1);
					aux:=substr(aux, instr(aux,';')+1);
				end if;
			end loop;
		elsif contador>contadoraux And aux is not null then --valores del archivo
			Begin
				v_id_linea_archivo:=busca_clave_id;
				INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
        VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, substr(reg.registro,1,2000), '');
      exception
      when others then
				raise_application_error(-20001,'Error al intentar insertar la linea (' || contador || ') del archivo, mensaje:'|| sqlerrm, true);
      End;
			For i in 0 .. cant_registro Loop
        auxi:=i;
				if instr(aux,';')=0 then --csv separado por comas, si no hay mas comas se sale
					campo(i):=aux;
        else
          campo(i):=substr(aux, 0, instr(aux,';')-1);
          aux:=substr(aux, instr(aux,';')+1);
				end if;
        case --identificación de variables segun su encabezado, fijas para ficha_hogar, ficha_persona, persona y censo_persona; el resto se busca en preguntas
        When instr(trim(upper(encabezado(i))),'DPTOD')>0 Then
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
				When trim(upper(encabezado(i)))='DISTRIPG' Then
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
				When trim(upper(encabezado(i)))='BARRIO' Then
          begin
						if length(campo(i))<=3 then
              Select trim(v_distrito) || trim(to_char(campo(i),'000')) into v_barrio from dual;
            else
              Select to_char(campo(i),'0000000') into v_barrio from dual;
            end if;
						Select id into v_id_barrio From barrio Where codigo=trim(v_barrio);
          EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_barrio:=NULL;
					when others then
						v_id_barrio:=NULL;
						v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código del Barrio, valor intentado:' || campo(i) || ', mensaje:' || err_msg);
					END;
				When trim(upper(encabezado(i)))='MANZANA' Then
					v_manzana:=trim(substr(campo(i),1,20));
				When trim(upper(encabezado(i)))='AREA' Then
					v_tipoarea:=substr(campo(i),1,10);
				When upper(encabezado(i))='FORMULARIO' Then
					v_numero_formulario:=substr(campo(i),1,10);
				When trim(upper(encabezado(i)))='VIVI' Then
          v_numero_vivienda:=substr(campo(i),1,10);
				When trim(upper(encabezado(i)))='HOGAR' Then
					v_numero_hogar:=substr(campo(i),1,10);
				When trim(upper(encabezado(i)))='CEDULA' Then
          v_cedula:=trim(substr(campo(i),1,10));
          if v_cedula is not null then
            Begin
              Select id, apellidos, nombres, case nacionalidad when 226 then 'true' else 'false' end as paraguayo
                into v_id_cedula, w_apellido, w_nombre, v_paraguayo 
              From cedula where numero=v_cedula;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
  						v_id_cedula:=NULL;
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error nro cedula no encontrado en la tabla de identificación:' || campo(i));
            END;
          else
            v_id_cedula:=NULL; 
          end if;
        When trim(upper(encabezado(i)))='NOMBRE' Then
					v_nombres:=substr(campo(i),1,50);
        When trim(upper(encabezado(i)))='APELLIDO' Then
					v_apellidos:=substr(campo(i),1,50);
          v_nombre :=substr(v_nombres || ' ' || v_apellidos,1,100);
				When trim(upper(encabezado(i)))='SEXO' or upper(trim(encabezado(i)))='P33' Then
					if trim(campo(i)) is null then
						v_sexo:=7; --no suministrado
					else
						v_sexo:=substr(campo(i),1,1);
					end if;
        When (instr(upper(encabezado(i)),'EDAD')>0) Then
					v_edad:=substr(trim(campo(i)),1,3);
        When (instr(upper(encabezado(i)),'TIPO_PERSONA')>0) Then
					v_tipo_persona_hogar:=substr(campo(i),1,1);
        When (instr(upper(encabezado(i)),'MIEMBRO_HOGAR')>0) Then
          if (substr(campo(i),1,1)='1') then
            v$miembro_hogar:='true';
          else
            v$miembro_hogar:='false';
          end if;
        When trim(upper(encabezado(i)))='ORDEN' Then
					begin
            v_numero_orden:=substr(campo(i),1,5);
          exception
					when others then
						v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el día de la fecha de nacimiento valor leído:' || campo(i) || ', mensaje:' || err_msg);
          End;
        When (instr(upper(encabezado(i)),'FECHA_NACIMIENTO')>0) Then
          v_fecha_nacimiento:=extraerddmmyyyy(campo(i), 'fecha de nacimiento', v_id_linea_archivo, 'true');
        When upper(trim(encabezado(i)))='FECH_NAC_D' Then  --FECH_NAC_D
					begin
            Select to_number(campo(i)) into v_fecha_nacimiento_d From dual;
          exception
					when others then
						v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el día de la fecha de nacimiento valor leído:' || campo(i) || ', mensaje:' || err_msg);
          End;
        When upper(trim(encabezado(i)))='FECH_NAC_M' Then --FECH_NAC_M
					begin
            Select to_number(campo(i)) into v_fecha_nacimiento_m From dual;
          exception
					when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el mes de la fecha de nacimiento valor leído:' || campo(i) || ', mensaje:' || err_msg);
					End;
        When upper(trim(encabezado(i)))='FECH_NAC_A' Then --FECH_NAC_A
          begin
						Select to_number(to_char(nvl(trim(campo(i)),'1900'),'0000'),'0000') into v_fecha_nacimiento_a From dual;
          exception
					when others then
            v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el año de la fecha de nacimiento, valor leído: [' || campo(i) || '], mensaje:' || err_msg);
					End;
        When upper(trim(encabezado(i)))='TELEFONO' or upper(trim(encabezado(i)))='P37' Then
					v_telefono:=trim(substr(campo(i),1,20));
        When upper(trim(encabezado(i)))='ESTADO_CIVIL'  Then
					if trim(campo(i)) is null then
						v_estado_civil:=7; --no suministrado
					else
            v_estado_civil:=substr(trim(campo(i)),1,1);
          end if;
        When instr(trim(upper(encabezado(i))),'CLAVE')>0 Then --clave STP
          v$id_ficha_hogar:=substr(campo(i),1,16);
        When upper(trim(encabezado(i)))='OCUPACION' or upper(trim(encabezado(i)))='N33' Then
          BEGIN
						Select id into v_id_ocupacion From ocupacion Where upper(codigo)=upper(trim(campo(i)));
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
						v_id_ocupacion:=null;
					END;
        When upper(trim(encabezado(i)))='RAMA' Then
					BEGIN
						Select id into v_id_rama From rama Where upper(codigo)=upper(trim(campo(i)));
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_id_rama:=null;
          END;
				When trim(upper(encabezado(i)))='ICV' Then
          begin
            v_current_user_id:=current_user_id();
            if v_current_user_id is null then --debug
							v_strsql:='Select to_number(' ||  chr(39) || campo(i) || chr(39) || ') From dual';
            else
              v_strsql:='Select to_number(' ||  chr(39) || replace(campo(i),',','.') || chr(39) || ') From dual';
            end if;
            execute immediate v_strsql into v_icv;
					exception
					when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el valor del ICV, valor leído: [' || campo(i) || '], mensaje:' || err_msg);
					End;
        When upper(trim(encabezado(i)))='DIRECCION' or (instr(upper(encabezado(i)),'P09')>0) Then
					v_direccion:=trim(substr(campo(i),1,200));
        When upper(trim(encabezado(i)))='DIA' Then
					begin
            Select to_number(campo(i)) into v_fecha_censo_d From dual;
          exception
          when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Error al intentar obtener el día de la fecha de entrevista valor leído:' || campo(i) || ', mensaje:' || err_msg);
					End;
        When upper(trim(encabezado(i)))='MES' Then
					begin
            Select to_number(campo(i)) into v_fecha_censo_m From dual;
          exception
            when others then
						v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el mes de la fecha de entrevista valor leído:' || campo(i) || ', mensaje:' || err_msg);
					End;
        When upper(trim(encabezado(i)))='ANO' Then
					begin
						Select to_number(campo(i)) into v_fecha_censo_a From dual;
					exception
					when others then
						v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el año de la fecha de entrevista, valor leído: [' || campo(i) || '], mensaje:'|| err_msg);
					End;
				When upper(trim(encabezado(i)))='GPS_X' or trim(upper(encabezado(i)))='COORDENADA_X' Then
					v_gps_x:= '-' || trim(substr(campo(i),1,2)) || '.' || trim(substr(campo(i),3));
				When upper(trim(encabezado(i)))='GPS_Y' or trim(upper(encabezado(i)))='COORDENADA_Y' Then
					v_gps_y:='-' || trim(substr(campo(i),1,2)) || '.' || trim(substr(campo(i),3));
        When instr(trim(upper(encabezado(i))),'CENSISTA')>0 Then
          begin
            v$str_censista:=trim(substr(campo(i),1,10));
            Select id into v$id_censista From censista Where codigo=v$str_censista; 
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v$id_censista:=NULL;
            v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'AVISO: censista no encontrado:' || campo(i));
          when others then
            v$id_censista:=NULL;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código del censista, valor intentado:' || campo(i) || ', mensaje:' || err_msg);
          END;
        When upper(trim(encabezado(i)))='STATUS2' Then --tipo de pobreza STP
          BEGIN
            v$tipo_pobreza:=substr(campo(i),1,1);
          EXCEPTION
          when others then
            v$tipo_pobreza:=0;
          END;
        When upper(trim(encabezado(i)))='VERSION_FICHA' Then --version ficha historicos
          BEGIN
            v$version_ficha_historico:=trim(substr(campo(i),1,20));
          EXCEPTION
          when others then
            v$version_ficha_historico:=v_version_ficha_hogar;
          END;
        When upper(trim(encabezado(i)))='TIPO_ACCION' Then --para archivos historicos, cargar monitoreos (M) o denuncias (R)
          v$tipo_accion:=trim(substr(campo(i),1,5));
        When upper(trim(encabezado(i)))='NACIONALIDAD' Then
          v$nacionalidad:=trim(substr(campo(i),1,50));
				Else --el resto de las variables con literales no fijos, se buscar en las pregutnas de hogar y persona
          null;
        end case;
        For reg2 in (Select * From pregunta_ficha_persona Where version_ficha=v$version_ficha_historico And upper(trim(codigo))=upper(trim(encabezado(i))) Order by codigo) Loop --carga de respuesta persona
          auxi:=0;
          v_id_pregunta:=reg2.id;
          v_rango_respuesta:=null; v_texto_respuesta:=null; v_numero_respuesta:=null; v_fecha_respuesta:=null;
          v_tipo_dato_respuesta:=reg2.tipo_dato_respuesta;
          cant_sqlpersona:=cant_sqlpersona+1;
          v_strsqlpersona(cant_sqlpersona):='Delete From respuesta_ficha_persona Where pregunta=' || v_id_pregunta || ' And ficha=id_ficha_persona';
          cant_sqlpersona:=cant_sqlpersona+1;
          v_strsqlpersona(cant_sqlpersona):='INSERT INTO RESPUESTA_FICHA_PERSONA (ID, VERSION, FICHA, PREGUNTA';
          if v_tipo_dato_respuesta=1 And trim(campo(i)) is  not null Then --alfanumerico
            v_strsqlpersona(cant_sqlpersona):=  v_strsqlpersona(cant_sqlpersona) ||
                        												' , TEXTO) VALUES (busca_clave_id, 0, id_ficha_persona, ' || v_id_pregunta || ',' || chr(39) || campo(i) || chr(39) || ')';
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
			if v_fecha_nacimiento is null then
				v_fecha_nacimiento:=extraerddmmyyyy(v_fecha_nacimiento_d || '/' || v_fecha_nacimiento_m || '/' || v_fecha_nacimiento_a , 'fecha nacimiento', v_id_linea_archivo, 'false');
      end if;
      auxi:=-15;
			v_fecha_censo:=extraerddmmyyyy(v_fecha_censo_d || '/' || v_fecha_censo_m || '/' || v_fecha_censo_a, 'fecha entrevista', v_id_linea_archivo, 'true');
      v_id_ficha_persona:=null; v_id_censo_persona:=null;
      Begin --buscamos ficha hogar cargada con antelación para esta versión
        if v$id_ficha_hogar is null And v$version_ficha_historico=v_version_ficha_hogar then
          Select fh.id into v$id_ficha_hogar
          From ficha_hogar fh inner join departamento dp on fh.departamento=dp.id
          Where fh.version_ficha_hogar=v_version_ficha_hogar
            And fh.departamento=v_id_departamento And fh.distrito=v_id_distrito And (fh.barrio=v_id_barrio or fh.barrio is null)
            And nvl(fh.manzana,'0')=v_manzana And fh.numero_formulario=v_numero_formulario
            And fh.numero_hogar=v_numero_hogar And fh.numero_vivienda=v_numero_vivienda 
            And fh.estado in (1,2,3) And fh.CENSISTA_EXTERNO=v$id_censista 
            And FECHA_ENTREVISTA=v_fecha_censo
            And rownum=1
          Order by 1 desc;
        elsif v$id_ficha_hogar is null And v$version_ficha_historico<>v_version_ficha_hogar then --censos historicos DPNC
          Select fh.id into v$id_ficha_hogar
          From ficha_hogar fh inner join departamento dp on fh.departamento=dp.id
          Where fh.version_ficha_hogar=v$version_ficha_historico
            And fh.departamento=v_id_departamento And fh.distrito=v_id_distrito And (fh.barrio=v_id_barrio or fh.barrio is null)
            And nvl(fh.manzana,'0')=v_manzana And fh.numero_formulario=v_numero_formulario
            And fh.numero_hogar=v_numero_hogar And fh.numero_vivienda=v_numero_vivienda 
            --And fh.estado in (1,2,3) And fh.CENSISTA_EXTERNO=v$id_censista 
            --And FECHA_ENTREVISTA=v_fecha_censo
            And rownum=1
          Order by 1 desc;
        else --censos historicos STP
          Select id into v$id_ficha_hogar From ficha_hogar where id=v$id_ficha_hogar; --STP tiene el id en el archivo
        end if;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				v$id_ficha_hogar:=null;
        v_cant_errores:=v_cant_errores+1;
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'AVISO: no se econtraron datos del hogar. Cédula:' || v_cedula || ', departamento:' || v_departamento || ', distrito:' || v_distrito || ', barrio:' || v_barrio || ', tipo area:' || v_tipoarea || ', manzana:' || v_manzana || ', nro. formulario:' || v_numero_formulario || ', nro hogar: ' || v_numero_hogar || ', nro vivienda: ' || v_numero_vivienda || 'fecha censo:' || v_fecha_censo || ', censista:' || v$str_censista || ', línea archivo:' || contador);
			when others then
				v$id_ficha_hogar:=null;
				v_cant_errores:=v_cant_errores+1;
				err_msg := SUBSTR(SQLERRM, 1, 200);
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el hogar. Departamento:' || v_departamento || ', distrito:' || v_distrito || ', barrio:' || v_barrio || ', tipo area:' || v_tipoarea || ', manzana:' || v_manzana || ', nro. formulario:' || v_numero_formulario || ', nro hogar: ' || v_numero_hogar || ', nro vivienda: ' || v_numero_vivienda || ', línea archivo:' || contador || ', mensaje:' || err_msg);
			End;
      auxi:=-1;
      v_edad:=calcular_edad(v_fecha_nacimiento);
      v$cant_pension_solicitada:=1;
      /*if v$id_ficha_hogar is not null then
        begin
          Select Count(pn.id) into v$cant_pension_solicitada
          From ficha_hogar fh inner join ficha_persona fp on fh.id = fp.ficha_hogar
            inner join persona pe on fp.id = pe.ficha
            inner join pension pn on pe.id = pn.persona
          Where fh.id = v$id_ficha_hogar And pn.estado=1;
        EXCEPTION
        when others then
          v$cant_pension_solicitada:=0;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener la(s) pension(es) solicitadas de los miembros del hogar id ' || v$id_ficha_hogar || ', línea archivo:' || contador || ', mensaje:' || err_msg);
        End;
      end if;*/
      if v$id_ficha_hogar is not null And v$cant_pension_solicitada>0 then
        if v_nombres is not null or v_apellidos is not null then
          if v_cedula is not null then
            begin
              for reg2 in (Select a.id as v_id_ficha_persona, b.id as v_id_censo_persona
                          From ficha_persona a inner join censo_persona b on a.id = b.ficha And (to_char(b.fecha,'dd/mm/yyyy')=to_char(v_fecha_censo,'dd/mm/yyyy') or to_char(b.fecha,'dd/mm/yyyy')= '01/01/1900')
                          Where a.NUMERO_CEDULA=v_cedula 
                            And a.version_ficha_hogar=v$version_ficha_historico
                          Order by 1,2 desc) loop
                  v_id_ficha_persona:=reg2.v_id_ficha_persona; v_id_censo_persona:=reg2.v_id_censo_persona;
                  exit;
              end loop;
            EXCEPTION
            when others then
              v$cant_pension_solicitada:=0;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener la ficha persona y censo de la cedula:' || v_cedula || ', fecha:' || v_fecha_censo || ', versión:' || v$version_ficha_historico || ', línea archivo:' || contador || ', mensaje:' || err_msg);
            End;
          end if;
          begin
            if v_id_ficha_persona is not null then --si existe la ficha, se actualiza el registro
              update FICHA_PERSONA set NOMBRE=v_nombre, FICHA_HOGAR=v$id_ficha_hogar, NOMBRES=v_nombres,
                                        APELLIDOS=v_apellidos, EDAD=v_edad, SEXO_PERSONA=v_sexo, TIPO_PERSONA_HOGAR=v_tipo_persona_hogar,
                                        NUMERO_ORDEN_IDENTIFICACION=v_numero_orden, pais=v$nacionalidad,
                                        NUMERO_CEDULA=v_cedula, FECHA_NACIMIENTO=v_fecha_nacimiento, NUMERO_TELEFONO=v_telefono,
                                        ESTADO_CIVIL=v_estado_civil, OCUPACION=v_id_ocupacion, RAMA=v_id_rama, MIEMBRO_HOGAR=v$miembro_hogar
              Where id=v_id_ficha_persona;
            else
              v_id_ficha_persona := busca_clave_id;
              if v_cedula is null then
                v_tipo_exepcion_cedula:=1;
              else
                v_tipo_exepcion_cedula:=null;
              end if;
              INSERT INTO FICHA_PERSONA (ID, VERSION, CODIGO, NOMBRE, FICHA_HOGAR, NOMBRES, version_ficha_hogar, observaciones,
                                        APELLIDOS, EDAD, SEXO_PERSONA, TIPO_PERSONA_HOGAR, MIEMBRO_HOGAR, NUMERO_ORDEN_IDENTIFICACION,
                                        NUMERO_CEDULA, TIPO_EXCEPCION_CEDULA, FECHA_NACIMIENTO, NUMERO_TELEFONO, ESTADO_CIVIL, OCUPACION, 
                                        RAMA, PAIS)
              VALUES (v_id_ficha_persona, 0, v_id_ficha_persona, v_nombre, v$id_ficha_hogar, v_nombres, v$version_ficha_historico, x$observaciones,
                    v_apellidos, v_edad, v_sexo, v_tipo_persona_hogar, v$miembro_hogar, v_numero_orden, 
                    v_cedula, v_tipo_exepcion_cedula, v_fecha_nacimiento, v_telefono, v_estado_civil, v_id_ocupacion, 
                    v_id_rama, v$nacionalidad);
            end if;
          Exception
          when others then
            v_id_ficha_persona:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar la ficha persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
          End;
        end if;
        x$persona:=null; auxi:=-2;
        if v_cedula is not null then
          begin
            Select id into x$persona From persona Where codigo=v_cedula;
          Exception
          WHEN NO_DATA_FOUND THEN
            x$persona:=null;
          when others then
            x$persona:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el id de persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
          end;
          begin
            if x$persona is not null then
              update PERSONA set FECHA_INGRESO_HOGAR=v_fecha_censo, DIRECCION=v_direccion, TELEFONO_LINEA_BAJA=v_telefono, tipo_area=v_tipoarea,
                                FICHA=v_id_ficha_persona, OBSERVACIONES_FICHA=x$observaciones,barrio=v_id_barrio,distrito=v_id_distrito, 
                                departamento=v_id_departamento, FECHA_NACIMIENTO=v_fecha_nacimiento
              Where id=x$persona;
            else
              x$persona:=busca_clave_id;
              INSERT INTO PERSONA (ID, VERSION, CODIGO, NOMBRE, APELLIDOS, NOMBRES, FECHA_NACIMIENTO, SEXO, ICV,
                                  ESTADO_CIVIL, PARAGUAYO, INDIGENA, ETNIA, CEDULA, FECHA_INGRESO_HOGAR, DEPARTAMENTO,
                                  DISTRITO, TIPO_AREA, BARRIO, DIRECCION, TELEFONO_LINEA_BAJA,CEDULA_NO_IDENTIFICACION,
                                  MONITOREADO, MONITOREO_SORTEO, EDICION_RESTRINGIDA, FICHA, OBSERVACIONES_FICHA)
                values (x$persona, 0, v_cedula, v_nombre, v_apellidos, v_nombres, v_fecha_nacimiento, v_sexo, v_icv,
                        v_estado_civil, v_paraguayo, 'false', null, v_id_cedula, v_fecha_censo, v_id_departamento,
                        v_id_distrito, v_tipoarea, v_id_barrio, v_direccion, v_telefono, v_cedula,
                        'false', 'false', 'true', v_id_ficha_persona, x$observaciones);
            end if;
          Exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar los datos de la persona cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
          end;
        end if;
        auxi:=-3;
        Begin
          if v_id_censo_persona is null And v_edad>=65 And v_id_cedula is not null And v_id_ficha_persona is not null then
            begin
              Select utl_match.jaro_winkler_similarity(upper(v_nombres),upper(w_nombre)) into v_porc_match_nombre From dual;
              Select utl_match.jaro_winkler_similarity(upper(v_apellidos),upper(w_apellido)) into v_porc_match_apellido From dual;
            EXCEPTION
            when others then
              v_porc_match_nombre:=0; v_porc_match_apellido:=0;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el % de match entre nombre y apellidos suministrados vs registrados en Identificaciones, cédula:' || v_cedula || ', nombres:' || v_nombres || '. Mensaje:' || err_msg);
            End;
            if v_porc_match_nombre<75 or v_porc_match_apellido<75 then
              v_id_censo_persona := NULL;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error: para la cédula:' || v_cedula || ', el nombre suministrado:' || v_nombres || ' es diferente al registrado en identificaciones:' || w_nombre || ' (' || v_porc_match_nombre || '%), o el apellido suministrado: ' || v_apellidos || ' es diferente al registrado en identificaciones:' || w_apellido || ' (' || v_porc_match_apellido || '%)');
            else
              v_id_censo_persona := busca_clave_id;
              INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,
                                        ICV, TIPO_POBREZA, COMENTARIOS,  DEPARTAMENTO, DISTRITO, TIPO_AREA,
                                        BARRIO, DIRECCION, NUMERO_TELEFONO,  NOMBRE_REFERENTE, NUMERO_TELEFONO_REFERENTE, NUMERO_SIME,
                                        ARCHIVO, LINEA, ESTADO,  FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES,
                                        CENSISTA_EXTERNO, CENSISTA_INTERNO, CAUSA_ANULACION)
                      values (v_id_censo_persona, 0, v_id_censo_persona, x$persona, v_fecha_censo, v_id_ficha_persona,
                              v_icv, v$tipo_pobreza, x$observaciones, v_id_departamento, v_id_distrito, v_tipoarea,
                              v_id_barrio, v_direccion, v_telefono, null, null, x$sime,
                              v_id_carga_archivo, contador, 4, sysdate, current_user_id, 'Creado x Censo x Lote (Población)',
                              null, null, null);
            end if;
          elsif v_id_censo_persona is not null And v_id_ficha_persona is not null then 
            Update CENSO_PERSONA set FECHA=v_fecha_censo, FICHA=v_id_ficha_persona, ICV=v_icv, COMENTARIOS=x$observaciones, DEPARTAMENTO=v_id_departamento,
                                      DISTRITO=v_id_distrito, TIPO_AREA=v_tipoarea, BARRIO=v_id_barrio, DIRECCION=v_direccion, NUMERO_TELEFONO=v_telefono,
                                      ESTADO=4, FECHA_TRANSICION=sysdate, USUARIO_TRANSICION=current_user_id, TIPO_POBREZA=v$tipo_pobreza,
                                      OBSERVACIONES='Actualizado por Censo x Lote (Población)', numero_sime=x$sime
            Where id=v_id_censo_persona;
          else
            null;
          end if;
        Exception
        When others then
          v_id_censo_persona := NULL;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar el registro de censo a la cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
        End;
        auxi:=-4;
        if x$persona is not null then
          begin
            v$valor_icv:='';
            Select (Select case when cp.icv is null then 'pob:' || cp.tipo_pobreza else 'icv:' || cp.icv end From censo_persona cp 
                    Where cp.persona = pe.id And cp.fecha=(Select max(cp2.fecha) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4) 
                    And rownum=1 And cp.estado=4),
                    (Select cp.ficha From censo_persona cp 
                    Where cp.persona = pe.id And cp.fecha=(Select max(cp2.fecha) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4) 
                    And rownum=1 And cp.estado=4)
            into v$valor_icv, v_id_ficha_persona
            From persona pe 
            Where pe.codigo=v_cedula;
            if instr(v$valor_icv,'icv:')>0 then
              v$valor_icv:=substr(v$valor_icv,5);
              v$tipo_pobreza:=null;
            else
              v$valor_icv:=null;
              v$tipo_pobreza:=substr(v$valor_icv,5);
            end if;
            update PERSONA set icv=v$valor_icv, tipo_area=v_tipoarea, ficha=v_id_ficha_persona, tipo_pobreza=v$tipo_pobreza
            Where id=x$persona;
          Exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar los datos del icv de la persona cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
          end;
        end if;
        if v_id_ficha_persona is null then
          begin
            Select id into v_id_ficha_persona
            From ficha_persona 
            Where numero_cedula=v_cedula And ficha_hogar =v$id_ficha_hogar 
             And rownum=1;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_id_ficha_persona:=null;
          when others then
            v_id_ficha_persona:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el valor de la ficha persona de la cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
          end;   
        end if;
        auxi:=-5;
        if v_edad>=65 And v_id_censo_persona is not null then
          Begin
            Select id, estado 
              into v_id_pension, v_estado_pension 
            From pension 
            Where persona=x$persona And rownum=1 
              And estado<>2 And clase=v_clase_pension 
            Order by id desc;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_id_pension:=null; v_estado_pension:=null;
            --v_cant_errores:=v_cant_errores+1;
            --x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Aviso: no se encontraron registros de pensión adulto mayor a la persona cédula:' || v_cedula || ', nombres:' || v_nombres);
          when others then
            v_id_pension:=null; v_estado_pension:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar pensión a la cédula de la persona:' || v_cedula || ', nombres:' || v_nombres || ', mensaje:' || err_msg);
          End;
        end if;
        auxi:=-6;
        if v_id_pension is null And v_edad>=65 And v_id_censo_persona is not null then
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
          end;
        end if;
        auxi:=-7;
        if v_id_pension is not null then
          begin
            Select id, tipo
              into v_id_tramite_administrativo, v_tipo_tramite_administrativo
            From tramite_administrativo
            Where pension=v_id_pension And estado=1;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_id_tramite_administrativo:=null; v_tipo_tramite_administrativo:=null;
            --v_cant_errores:=v_cant_errores+1;
            --x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'AVISO: no se encontraron registros de pensión adulto mayor a la persona cédula:' || v_cedula || ', nombres:' || v_nombres);
          when others then
            v_id_tramite_administrativo:=null; v_tipo_tramite_administrativo:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar pensión a la cédula de la persona:' || v_cedula || ', nombres:' || v_nombres || ', mensaje:' || err_msg);
          End;
          if v_id_tramite_administrativo is not null And (v_tipo_tramite_administrativo=1 or v_tipo_tramite_administrativo=2) then
            begin
              Update tramite_administrativo set estado=3 Where id=v_id_tramite_administrativo;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error no se encontraron registros de trámites pendientes a cerrar, cédula:' || v_cedula || ', nombres:' || v_nombres);
            when others then
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar cerrar el trámite pendiente a la cédula:' || v_cedula || ', nombres:' || v_nombres || ', mensaje:' || err_msg);
            End;
          end if;
        end if;
        auxi:=-8;
        if v_id_pension is not null And v$tipo_accion is null then
          v$id_denuncia_pension:=null;
          begin
            Select dp.id into v$id_denuncia_pension 
            From denuncia_pension dp  
            Where dp.pension=v_id_pension And dp.estado=1 And rownum=1;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v$id_denuncia_pension:=null;
          when others then
            v$id_denuncia_pension:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar denuncia de la cédula de la persona:' || v_cedula || ', nombres:' || v_nombres || ', mensaje:' || err_msg);
          End;
          if v$id_denuncia_pension is not null then
            begin
              Update denuncia_pension set estado=2 where id=v$id_denuncia_pension; --confirmacion de denuncia
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error no se encontraron registros de trámites pendientes a cerrar, cédula:' || v_cedula || ', nombres:' || v_nombres);
            when others then
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar el estado de la denuncia a la cédula:' || v_cedula || ', nombres:' || v_nombres || ', mensaje:' || err_msg);
            End;
          end if;
        end if;
        auxi:=-9;
        if x$persona is not null And v$tipo_accion='M' then --monitoreo historico
          begin
            update persona set monitoreado='true',  FECHA_MONITOREO=v_fecha_censo Where id=x$persona;
          Exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar actualizar la persona a monitoreada, cedula:' || v_cedula || ', linea:' || contador || ', mensaje '|| err_msg);
          End;
        end if;
        auxi:=-10;
        if x$persona is not null And v_id_pension is not null And v$tipo_accion='R' then --denuncia historico
          begin
            v$id_denuncia_pension:=busca_clave_id;
             insert into denuncia_pension (ID, VERSION, CODIGO, PENSION, DESCRIPCION, NUMERO_SIME, ARCHIVO,
                                           LINEA, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES)
                                 values (v$id_denuncia_pension, 0, v$id_denuncia_pension, v_id_pension, 'Denuncia cargada por archivo poblacion x lote', x$sime, v_id_carga_archivo,
                                         contador, 2, sysdate, current_user_id, x$observaciones);
          Exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar crear la denuncia a la persona cedula:' || v_cedula || ', linea:' || contador || ', mensaje '|| err_msg);
          End;
        end if;
        auxi:=-11;
        if v_id_ficha_persona is not null then --And v_id_censo_persona is not null
          For i in 1 .. cant_sqlpersona LOOP
            if trim(v_strsqlpersona(i)) is not null then
              Begin
                v_strsqlpersona(i):=replace(v_strsqlpersona(i),'id_ficha_persona',v_id_ficha_persona);
                execute immediate v_strsqlpersona(i);
              Exception
              when others then
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 200);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar insertar un registro de respuesta persona, sql:' || substr(v_strsqlpersona(i),1,300) || ', linea:' || contador || ', mensaje '|| err_msg);
              End;
            end if;
          end loop;
          begin
            Insert into respuesta_ficha_persona (id, version, ficha, pregunta)
              Select busca_clave_id, 0, v_id_ficha_persona, a.id
              From pregunta_ficha_persona a
              Where a.version_ficha=v$version_ficha_historico
              And a.id not in (Select c.id 
                              From respuesta_ficha_persona b inner join pregunta_ficha_persona c on b.pregunta = c.id
                              Where b.ficha=v_id_ficha_persona);
          Exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar insertar las respuestas no relevadas de la cedula[' || v_cedula || '], nombres:[' || v_nombre || '] , linea:' || contador || ', mensaje '|| err_msg);
          End;
        End if;
      else
        if v$cant_pension_solicitada=0 And v$id_ficha_hogar is not null then
          v_cant_errores:=v_cant_errores+1;
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error el hogar id ' || v$id_ficha_hogar || ' no tiene un miembro con pensión en estado solicitada, línea archivo:' || contador || ', mensaje:' || err_msg);
        end if;
      end if; --v$id_ficha_hogar is not null
      auxi:=-12;
			if (v_cant_errores>0) Then
				Update LINEA_ARCHIVO set ERRORES=ERRORES+v_cant_errores Where id=v_id_linea_archivo;
			End If;
			contador_t:=contador_t+1;
			if contador_t>1000 then
				update carga_archivo set directorio=contador Where id=v_id_carga_archivo;
				commit work;
				rastro_proceso_temporal$revive(v$log);
				contador_t:=1;
			end if;
		End if; --else if contador=0 then
		contador:=contador + 1; auxi:=-13;
	End loop;
  auxi:=-14;
	Delete From CSV_IMP_TEMP Where archivo=x$archivo;
	Update CARGA_ARCHIVO set PROCESO_SIN_ERRORES='true', directorio=contador Where id=v_id_carga_archivo;
  auxi:=-15;
  Select Count(a.id) into v_cant_errores
  From LINEA_ARCHIVO a inner join ERROR_ARCHIVO b on a.id = b.linea
  Where a.CARGA=v_id_carga_archivo;
  if v_cant_errores>0 then
    Update CARGA_ARCHIVO set ARCHIVO_SIN_ERRORES='false' Where id=v_id_carga_archivo;
  end if;
  auxi:=-16;
  commit work;
  rastro_proceso_temporal$revive(v$log);
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20100, err_msg || ' en linea:' || contador || ', campo:' || auxi, true);
end;
/
