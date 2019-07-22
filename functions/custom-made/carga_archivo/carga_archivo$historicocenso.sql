create or replace function carga_archivo$historicocenso(x$archivo VARCHAR2, x$clase_archivo VARCHAR2, observaciones nvarchar2) return number is
Begin
  Declare
  err_msg               		VARCHAR2(2000);  
  v_id_ficha_hogar     			number;
  v_bol_ficha_hogar  			  varchar2(5); --si existe no le creamos respuesta
  type namesarray IS TABLE OF VARCHAR2(500) INDEX BY PLS_INTEGER;
  encabezado            		namesarray;
  campo                 		namesarray;
  v_strsql							    varchar2(1000);
  v_strsqlhogar         		namesarray;
  v_strsqlpersona       		namesarray;
  v_id_carga_archivo    		number;
  v_id_linea_archivo    		number;
  v_version_ficha_hogar 		varchar2(20);
  v_id_censista_externo 		varchar2(20);
  archivo             			varchar2(255);
	contador								  integer :=0;
	contador_t                integer :=0;
	contadoraux							  integer :=0;
  archivo_adjunto					  varchar2(255);
	id_archivo_adjunto				number;
  auxi                      integer :=0;
	i                   			integer :=0;
	cant_registro       			integer :=0;
	aux                 			VARCHAR2(4000);
  v_codigo            			varchar2(100);
  v_departamento      			varchar2(20);
  v_id_departamento   			varchar2(20) := NULL;
  v_distrito          			varchar2(20);
  v_id_distrito       			varchar2(20) := NULL;
  v_barrio            			varchar2(20);
  v_manzana           			varchar2(20);
  v_tipoarea          			varchar2(10) :=6;
  v_id_barrio         			varchar2(20) := NULL;
  v_numero_vivienda   			varchar2(10);
  v_numero_formulario 			varchar2(10);
  v_numero_hogar      			varchar2(10);
  v_gps_x							      varchar2(13);
  v_gps_y							      varchar2(13);
	v_id_ficha_persona  			number;
	v_direccion         			varchar2(200);
	x$persona        		      number;
	V_id_censo_persona  			number;
	v_codigo_ficha_persona    varchar2(100);
	v_cedula                  varchar2(10);
	v_id_cedula						    number;
	v_cedula_jefe             varchar2(10);
	v_tipo_exepcion_cedula    integer :=1;
	v_nombre                  varchar2(100);
	v_nombres                 varchar2(50);
	v_apellidos               varchar2(50);
	v_telefono                varchar2(20);
	v_sexo                    integer;
	v_edad                    varchar2(3);
	v_tipo_persona_hogar      integer;
	v_numero_orden            number;
	v_fecha_nacimiento        date;
	v_fecha_nacimiento_d      number;
	v_fecha_nacimiento_m      number;
	v_fecha_nacimiento_a      number;
	v_estado_civil            integer :=7; --no suministrado
	v_id_ocupacion            number;
	v_id_rama                 number;
	v_icv                     number;
	cant_sqlhogar             integer :=0;
	cant_sqlpersona           integer :=0;
	v_fecha_censo             date;
	v_fecha_censo_d           number;
	v_fecha_censo_m           number;
	v_fecha_censo_a           number;
	v_id_pregunta             number;
	v_pregunta                varchar2(30);
	v_tipo_dato_respuesta     number;
	v_rango_respuesta         number;
	v_texto_respuesta         varchar2(100);
	v_numero_respuesta        number;
	v_fecha_respuesta         date;
	v_id_respuesta            number;
	v_cant_errores            integer;
	x$reg								      number;
	v_current_user_id				  number;
	v$log rastro_proceso_temporal%ROWTYPE;
begin
	v$log := rastro_proceso_temporal$select();
   Begin
      Select valor Into v_version_ficha_hogar From variable_global where numero=103;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
   End;
   Begin
       Select id Into v_id_censista_externo From censista where trim(nombre)='DPNC';
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		v_id_censista_externo:=NULL;
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
		v_fecha_censo_a:=0; v_fecha_censo_m:=0; v_fecha_censo_d:=0; v_fecha_censo:=NULL; v_cant_errores:=0; v_id_ficha_persona := null; archivo:=reg.archivo;
		x$persona:=null; v_manzana:=NULL; v_id_barrio:=NULL; v_id_distrito:=99; v_id_departamento:=99; cant_sqlhogar:=0;  cant_sqlpersona:=0;
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
				From carga_archivo ca inner join ARCHIVO_ADJUNTO aa on ca.archivo=aa.ARCHIVO_SERVIDOR 
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
			For i in 0 .. cant_registro LOOP
        auxi:=i;
				if instr(aux,';')=0 then
					encabezado(i):=aux;
				else
					encabezado(i):=substr(aux, 0, instr(aux,';')-1);
					aux:=substr(aux, instr(aux,';')+1);
				end if;
			end loop;
    end if;
		if contador>contadoraux And aux is not null then --valores del archivo
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
          When instr(trim(upper(encabezado(i))),'DPTOD')>0 And i<=10 Then
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
                Select trim(v_departamento) || trim(v_distrito) || trim(to_char(campo(i),'000')) into v_barrio from dual;
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
          When trim(upper(encabezado(i)))='CEDULA' And v_cedula is null Then
            Begin
              v_cedula:=trim(substr(campo(i),1,10));
              Select id into v_id_cedula From cedula where numero=v_cedula;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_id_cedula:=NULL;
              v_cant_errores:=v_cant_errores+1;
  						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error nro cedula no encontrado en la tabla de identificación:' || campo(i));
            END;
            if v_numero_orden=1 Then
              v_cedula_jefe:=substr(trim(campo(i)),1,10);
            end if;
          When trim(upper(encabezado(i)))='CEDULAJEFE' Then
            v_cedula_jefe:=substr(trim(campo(i)),1,10);
          When trim(upper(encabezado(i)))='NOMBRE'  Then --or trim(upper(encabezado(i)))='P33'
            v_nombres:=substr(campo(i),1,50);
          When trim(upper(encabezado(i)))='APELLIDO'  Then  --or trim(upper(encabezado(i)))='P34'
            v_apellidos:=substr(campo(i),1,50);
          When trim(upper(encabezado(i)))='SEXO' Then
            if trim(campo(i)) is null then
              v_sexo:=7; --no suministrado
          else
              v_sexo:=substr(campo(i),1,1); 
            end if;
          When (instr(upper(encabezado(i)),'EDAD')>0) Then
            v_edad:=substr(trim(campo(i)),1,3);
          When (instr(upper(encabezado(i)),'TIPO_PERSONA')>0) Then
            BEGIN
              Select numero into v_tipo_persona_hogar From tipo_persona_hogar Where upper(codigo)=upper(trim(campo(i)));
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_tipo_persona_hogar:=1;
            END;
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
          When upper(trim(encabezado(i)))='P38_DIA' or upper(trim(encabezado(i)))='P40_DIA' or upper(trim(encabezado(i)))='FECH_NAC_D' Then  --FECH_NAC_D
            begin
              Select to_number(campo(i)) into v_fecha_nacimiento_d From dual;
            exception
            when others then
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el día de la fecha de nacimiento valor leído:' || campo(i) || ', mensaje:' || err_msg);
            End;
          When upper(trim(encabezado(i)))='P38_MES' or upper(trim(encabezado(i)))='P40_MES' or upper(trim(encabezado(i)))='FECH_NAC_M' Then --FECH_NAC_M
            begin
              Select to_number(campo(i)) into v_fecha_nacimiento_m From dual;
            exception
            when others then
  						v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el mes de la fecha de nacimiento valor leído:' || campo(i) || ', mensaje:' || err_msg);
            End;
          When upper(trim(encabezado(i)))='P38_ANO' or upper(trim(encabezado(i)))='P40_ANO' or upper(trim(encabezado(i)))='FECH_NAC_A' Then --FECH_NAC_A
            begin
  						Select to_number(to_char(nvl(trim(campo(i)),'1900'),'0000'),'0000') into v_fecha_nacimiento_a From dual;
            exception
            when others then
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el año de la fecha de nacimiento, valor leído: [' || campo(i) || '], mensaje:' || err_msg);
            End;
          When upper(trim(encabezado(i)))='TELEFONO' Then
            v_telefono:=trim(substr(campo(i),1,20));
          When upper(trim(encabezado(i)))='ESTADO_CIVIL'  Then
  					if trim(campo(i)) is null then
              v_estado_civil:=7; --no suministrado
            else
              v_estado_civil:=substr(trim(campo(i)),1,1);
            end if;
          When upper(trim(encabezado(i)))='OCUPACION' Then
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
          When upper(encabezado(i))='ICV' Then
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
          When upper(trim(encabezado(i)))='DIRECCION' Then
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
          When upper(trim(encabezado(i)))='GPS_X' Then
  					v_gps_x:= '-' || trim(substr(campo(i),1,2)) || '.' || trim(substr(campo(i),3));
          When upper(trim(encabezado(i)))='GPS_Y' Then
  					v_gps_y:='-' || trim(substr(campo(i),1,2)) || '.' || trim(substr(campo(i),3));
          Else --el resto de las variables con literales no fijos, se buscar en las pregutnas de hogar y persona
  					For reg1 in (Select * From pregunta_ficha_hogar Where version_ficha=v_version_ficha_hogar And upper(trim(codigo))=upper(trim(encabezado(i))) Order by codigo) Loop
              v_pregunta:=reg1.codigo;
              v_id_pregunta:=reg1.id;
              v_rango_respuesta:=null; v_texto_respuesta:=null; v_numero_respuesta:=null; v_fecha_respuesta:=null;
              v_id_respuesta:=busca_clave_id;
              v_tipo_dato_respuesta:=reg1.tipo_dato_respuesta;
              if v_tipo_dato_respuesta=1 And trim(campo(i)) is  not null Then --alfanumerico
                cant_sqlhogar:=cant_sqlhogar+1;
                v_strsqlhogar(cant_sqlhogar):= 'INSERT INTO RESPUESTA_FICHA_HOGAR (ID, VERSION, FICHA, PREGUNTA, TEXTO)
                                                VALUES (' || v_id_respuesta || ', 0, id_ficha_hogar, ' || v_id_pregunta || ',' || chr(39) || campo(i) || chr(39) ||  ')';
              elsif v_tipo_dato_respuesta=2 And trim(campo(i)) is  not null Then --numerico
                cant_sqlhogar:=cant_sqlhogar+1;
                v_strsqlhogar(cant_sqlhogar):= 'INSERT INTO RESPUESTA_FICHA_HOGAR (ID, VERSION, FICHA, PREGUNTA, NUMERO)
                                                VALUES (' || v_id_respuesta || ', 0, id_ficha_hogar, ' || v_id_pregunta || ',to_number(' || chr(39) || campo(i) || chr(39) || '))';
              elsif v_tipo_dato_respuesta=3 And trim(campo(i)) is  not null Then --fecha
                cant_sqlhogar:=cant_sqlhogar+1;
                v_strsqlhogar(cant_sqlhogar):= 'INSERT INTO RESPUESTA_FICHA_HOGAR (ID, VERSION, FICHA, PREGUNTA, FECHA)
                                                VALUES (' || v_id_respuesta || ', 0, id_ficha_hogar, ' || v_id_pregunta || ',' || chr(39) || campo(i) || chr(39) || ')';
              else --discreto
                begin
                  SELECT id into v_rango_respuesta From rango_ficha_hogar where pregunta=v_id_pregunta And numeral= campo(i);
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  if campo(i)='2' Then --para valores NO, se cambia a 6, valor esperado
                    campo(i):='6';
                    begin
                      SELECT id into v_rango_respuesta From rango_ficha_hogar where pregunta=v_id_pregunta And numeral= campo(i);
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      v_texto_respuesta:=campo(i);
                      v_rango_respuesta:=null;
                    end;
                  else
                    v_texto_respuesta:=campo(i);
                    v_rango_respuesta:=null;
                  end if;
                when others then
                  v_texto_respuesta:=campo(i);
                  v_rango_respuesta:=null;
                END;
                if v_rango_respuesta is not null then
                  cant_sqlhogar:=cant_sqlhogar+1;
                  v_strsqlhogar(cant_sqlhogar):= 'INSERT INTO RESPUESTA_FICHA_HOGAR (ID, VERSION, FICHA, PREGUNTA, RANGO)
                                                  VALUES (' || v_id_respuesta || ', 0, id_ficha_hogar, ' || v_id_pregunta || ',' || v_rango_respuesta || ')';
                end if;
              end if;
            End Loop; --fin respuesta hogar
            For reg2 in (Select * From pregunta_ficha_persona Where version_ficha=v_version_ficha_hogar And upper(trim(codigo))=upper(trim(encabezado(i))) Order by codigo) Loop --carga de respuesta persona
  						v_id_respuesta:=busca_clave_id; v_id_pregunta:=reg2.id;
              v_rango_respuesta:=null; v_texto_respuesta:=null; v_numero_respuesta:=null; v_fecha_respuesta:=null;
              v_tipo_dato_respuesta:=reg2.tipo_dato_respuesta;
              if v_tipo_dato_respuesta=1 And trim(campo(i)) is  not null Then --alfanumerico
                cant_sqlpersona:=cant_sqlpersona+1;
                v_strsqlpersona(cant_sqlpersona):= 'INSERT INTO RESPUESTA_FICHA_PERSONA (ID, VERSION, FICHA, PREGUNTA, TEXTO)
                                                    VALUES (' || v_id_respuesta || ', 0, id_ficha_persona, ' || v_id_pregunta || ',' || chr(39) || campo(i) || chr(39) || ')';
              elsif v_tipo_dato_respuesta=2 And trim(campo(i)) is  not null Then --numerico
                cant_sqlpersona:=cant_sqlpersona+1;
                v_strsqlpersona(cant_sqlpersona):= 'INSERT INTO RESPUESTA_FICHA_PERSONA (ID, VERSION, FICHA, PREGUNTA, NUMERO)
                                                    VALUES (' || v_id_respuesta || ', 0, id_ficha_persona, ' || v_id_pregunta || ',to_number(' || chr(39) || campo(i) || chr(39) || '))';
              elsif v_tipo_dato_respuesta=3 And trim(campo(i)) is  not null Then --fecha
                cant_sqlpersona:=cant_sqlpersona+1;
                v_strsqlpersona(cant_sqlpersona):= 'INSERT INTO RESPUESTA_FICHA_PERSONA (ID, VERSION, FICHA, PREGUNTA, FECHA)
                                                    VALUES (' || v_id_respuesta || ', 0, id_ficha_persona, ' || v_id_pregunta || ',' || chr(39) || campo(i) || chr(39) || ')';
              else --discreto
                begin
                  SELECT id into v_rango_respuesta From rango_ficha_persona where pregunta=v_id_pregunta And numeral= campo(i);
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  if campo(i)='2' Then --para valores NO se cambia a 6, valor esperado
                    campo(i):='6';
                    begin
                      SELECT id into v_rango_respuesta From rango_ficha_persona where pregunta=v_id_pregunta And numeral= campo(i);
                    EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                      v_texto_respuesta:=campo(i);
                      v_rango_respuesta:=null;
                    end;
                  else
                    v_texto_respuesta:=campo(i);
                    v_rango_respuesta:=null;
                  end if;
                when others then
                  v_texto_respuesta:=campo(i);
                  v_rango_respuesta:=null;
                END;
                if v_rango_respuesta is not null then
                  cant_sqlpersona:=cant_sqlpersona+1;
                  v_strsqlpersona(cant_sqlpersona):= 'INSERT INTO RESPUESTA_FICHA_PERSONA (ID, VERSION, FICHA, PREGUNTA, RANGO)
                                                      VALUES (' || v_id_respuesta || ', 0, id_ficha_persona, ' || v_id_pregunta || ',' || v_rango_respuesta || ')';
                end if;
              end if;
            End Loop;
        End Case; --identificación de variables segun su encabezado, fijas para ficha_hogar, ficha_persona, persona y censo_persona; el resto se busca en preguntas
      End Loop; --fin carga de valores de columnas For i in 1 .. cant_registro Loop
			if v_fecha_nacimiento is null then
				v_fecha_nacimiento:=extraerddmmyyyy(v_fecha_nacimiento_d || '/' || v_fecha_nacimiento_m || '/' || v_fecha_nacimiento_a , 'fecha nacimiento', v_id_linea_archivo, 'false');
      end if;
			v_fecha_censo:=extraerddmmyyyy(v_fecha_censo_d || '/' || v_fecha_censo_m || '/' || v_fecha_censo_a, 'fecha entrevista', v_id_linea_archivo, 'true');
      Begin --buscamos ficha hogar cargada con antelación para esta versión
				Select fh.id into v_id_ficha_hogar
				From ficha_hogar fh inner join departamento dp on fh.departamento=dp.id
				Where fh.version_ficha_hogar=v_version_ficha_hogar
          And fh.departamento=v_id_departamento And fh.distrito=v_id_distrito And (fh.barrio=v_id_barrio or fh.barrio is null)
					And nvl(fh.manzana,'0')=v_manzana And fh.numero_formulario=v_numero_formulario
					And fh.numero_hogar=v_numero_hogar And fh.numero_vivienda=v_numero_vivienda And rownum=1;
				v_bol_ficha_hogar:='false'; --es una ficha existente
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
        v_bol_ficha_hogar:='true'; --es una ficha nueva
				v_id_ficha_hogar:=null;
			when others then
				v_id_ficha_hogar:=null;
				v_bol_ficha_hogar:='true'; --es una ficha nueva
			End;
			if v_numero_orden<=1 And v_id_ficha_hogar is null then --solo se inserta ficha hogar para el orden 1 (jefe hogar)
        Begin
          v_id_ficha_hogar:=busca_clave_id;
          v_codigo := nvl(v_barrio,0) || v_fecha_censo_a || ficha_hogar_sq___.nextval;
					INSERT INTO FICHA_HOGAR (ID, VERSION, CODIGO, NUMERO_FORMULARIO, NUMERO_VIVIENDA, NUMERO_HOGAR,
                                  FECHA_ENTREVISTA, CENSISTA_EXTERNO, CENSISTA_INTERNO, SUPERVISOR, CRITICO_CODIFICADOR, DIGITADOR,
                                  COMENTARIOS, VERSION_FICHA_HOGAR, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES_ACEPTAR,
                                  OBSERVACIONES_ANULAR, OBSERVACIONES_CORREGIR, OBSERVACIONES_VERIFICAR, ICV, GPS, ORDEN,
                                  COORDENADA_X, COORDENADA_Y, URL_GOOGLE_MAPS, DEPARTAMENTO, DISTRITO, TIPO_AREA,
                                  BARRIO, MANZANA, DIRECCION, NUMERO_SIME, ARCHIVO, LINEA)
                      VALUES (v_id_ficha_hogar, 0, v_codigo, v_numero_formulario, v_numero_vivienda, v_numero_hogar,
                              v_fecha_censo, v_id_censista_externo, NULL, NULL, NULL, NULL,
                              observaciones, v_version_ficha_hogar, 1, v_fecha_censo, current_user_id(), '',
                              NULL, NULL, NUll, v_icv, NULL,  v_numero_orden,
                              v_gps_x, v_gps_y, NULL, v_id_departamento, v_id_distrito, v_tipoarea,
                              v_id_barrio, v_manzana, v_direccion, null, v_id_carga_archivo, contador);
				exception
				when others then
					v_id_ficha_hogar:=null;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar insertar un registro de ficha hogar, línea archivo:' || contador || ' id dpto: ' || v_id_departamento || ', id dtto:' || v_id_distrito || '. Mensaje:' || err_msg);
        end;
			End if;
			if trim(v_cedula) is not null And v_id_cedula is not null then --carga persona, sólo jefes de hogar
				v_nombre :=v_nombres || ', ' || v_apellidos;
				Begin
					Select id into x$persona From persona Where codigo=v_cedula;
				EXCEPTION
        WHEN NO_DATA_FOUND THEN
					x$persona:=busca_clave_id;
					Begin
						INSERT INTO PERSONA (ID, VERSION, CODIGO, NOMBRE, APELLIDOS, NOMBRES, FECHA_NACIMIENTO, LUGAR_NACIMIENTO, SEXO,
													ESTADO_CIVIL, PARAGUAYO, INDIGENA, ETNIA, COMUNIDAD, ICV, TIPO_POBREZA, CEDULA, FECHA_EXPEDICION_CEDULA,
													HOGAR_COLECTIVO, FECHA_INGRESO_HOGAR, DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO, DIRECCION, TELEFONO_LINEA_BAJA,
													MONITOREADO, MONITOREO_SORTEO, EDICION_RESTRINGIDA, FICHA, OBSERVACIONES_FICHA, MANZANA)
						VALUES (x$persona, 0, v_cedula, v_nombre, v_apellidos, v_nombres, v_fecha_nacimiento, null, v_sexo,
									v_estado_civil, 'true', 'false', null, null, v_icv, null, v_id_cedula, null,
									null, null, v_id_departamento, v_id_distrito, v_tipoarea, v_id_barrio, v_direccion, v_telefono,
									'false', 'false', 'true', NULL, observaciones, v_manzana);
					Exception
					When others then
						x$persona:=null;
						v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
					End;
				END;
			end if; --if v_cedula is not null then
			if v_id_ficha_hogar is not null then  --carga ficha persona solo cuando el orden en el hogar sea mayor que cero (exista) And v_numero_orden>0
				v_id_ficha_persona := busca_clave_id;
				v_codigo_ficha_persona := v_codigo || v_numero_orden;
				v_nombre :=v_nombres || ', ' || v_apellidos;
				Begin
					if v_cedula is null then
						v_tipo_exepcion_cedula:=1;
					else
						v_tipo_exepcion_cedula:=null;
					end if;
					INSERT INTO FICHA_PERSONA (ID, VERSION, CODIGO, NOMBRE, FICHA_HOGAR, NOMBRES,
                                             APELLIDOS, EDAD, SEXO_PERSONA, TIPO_PERSONA_HOGAR, MIEMBRO_HOGAR, NUMERO_ORDEN_IDENTIFICACION,
                                             NUMERO_CEDULA, TIPO_EXCEPCION_CEDULA, FECHA_NACIMIENTO, NUMERO_TELEFONO, ESTADO_CIVIL, OCUPACION, RAMA)
					VALUES (v_id_ficha_persona, 0, v_id_ficha_persona, v_nombre, v_id_ficha_hogar, v_nombres,
                       v_apellidos, v_edad, v_sexo, v_tipo_persona_hogar, 'true', v_numero_orden,
                       v_cedula, v_tipo_exepcion_cedula, v_fecha_nacimiento, v_telefono, v_estado_civil, v_id_ocupacion, v_id_rama);
				Exception
				when others then
					v_id_ficha_persona:=null;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar ficha persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
				End;
				if v_cedula is not null then --si existe la persona y se la carga la ficha, se actualiza el registro
					Begin
						update persona set ficha=v_id_ficha_persona where codigo=v_cedula;
               Exception
					when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar código ficha persona en persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
					End;
				end if;
			end if; --FIN carga ficha persona
			if x$persona is not null And v_id_ficha_persona is not null And v_numero_orden=1 then --se carga el censo cuando es el jefe del hogar
				Begin
					v_id_censo_persona := busca_clave_id;
					INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,
                                                   ICV, TIPO_POBREZA, COMENTARIOS,  DEPARTAMENTO, DISTRITO, TIPO_AREA,
                                                   BARRIO, DIRECCION, NUMERO_TELEFONO,  NOMBRE_REFERENTE, NUMERO_TELEFONO_REFERENTE, NUMERO_SIME,
                                                   ARCHIVO, LINEA, ESTADO,  FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES,
                                                   CENSISTA_EXTERNO, CENSISTA_INTERNO, CAUSA_ANULACION)
					values (v_id_censo_persona, 0, v_id_censo_persona, x$persona, v_fecha_censo, v_id_ficha_persona,
							v_icv, null, observaciones, v_id_departamento, v_id_distrito, v_tipoarea,
							v_id_barrio, v_direccion, v_telefono, null, null, null,
							v_id_carga_archivo, contador, 4, v_fecha_censo, null, 'Carga Histórico Censo',
                     null, null, null);
				Exception
				When others then
					v_id_censo_persona := NULL;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar censo persona, línea archivo:' || contador || ', mensaje:' || err_msg);
				End;
			End if;
			if v_numero_orden<=1 And v_id_ficha_hogar is not null And v_bol_ficha_hogar='true' then --solo se inserta ficha hogar para el orden 1 (jefe hogar) y nuevas
				For i in 1 .. cant_sqlhogar LOOP
					Begin
  						v_strsqlhogar(i):=replace(v_strsqlhogar(i),'id_ficha_hogar',v_id_ficha_hogar);
						execute immediate v_strsqlhogar(i);
					Exception
					when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar insertar un registro de respuesta hogar, sql:' || substr(v_strsqlhogar(i),1,300) || ', linea:' || contador || ', mensaje '|| err_msg);
					end;
				end loop;
            begin
            	Update ficha_hogar set estado=4 Where id=v_id_ficha_hogar;
				Exception
				When others then
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar actualizar el estado a censada a la ficha hogar, línea archivo:' || contador || ', mensaje:' || err_msg);
				End;
			End if;
			if v_id_ficha_persona is not null then
				For i in 1 .. cant_sqlpersona LOOP
					Begin
               	v_strsqlpersona(i):=replace(v_strsqlpersona(i),'id_ficha_persona',v_id_ficha_persona);
						execute immediate v_strsqlpersona(i);
					Exception
					when others then
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar insertar un registro de respuesta persona, sql:' || substr(v_strsqlpersona(i),1,300) || ', linea:' || contador || ', mensaje '|| err_msg);
					End;
				end loop;
			End if;
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
		End if; --else if contador=0 then
		contador:=contador + 1;
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
    raise_application_error(-20100, err_msg || ' en linea:' || contador || ' columna:' || auxi, true);
end;
end;
/
