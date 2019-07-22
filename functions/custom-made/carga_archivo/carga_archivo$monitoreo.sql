create or replace function carga_archivo$monitoreo(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, x$observaciones nvarchar2)
  return number is
	err_num                      	number;
	err_msg                      	VARCHAR2(2000);
	v_cant_errores					  	  integer:=0;
  v_version_ficha_hogar         varchar2(20):= NULL;
	aux                          	VARCHAR2(4000);
  archivo_adjunto					      varchar2(255);
	id_archivo_adjunto				    number;
	v_id_carga_archivo           	number;
	v_id_linea_archivo           	number;
 	contador_t                    integer :=1;
	contadoraux							      integer :=1;
	cant_registro                	integer :=0;
	valor_columna                	varchar2(1000);
	contador                     	integer :=1;
	i                            	integer :=-1;
	auxi                         	integer;
	x$persona						  	      number;
	v_cedula                	  	varchar2(10);
	x$reg								  	      number;
	v_id_cedula							      number;
  v_nombres                	  	varchar2(100);
	v_id_cedula                	  number;
	v_nombre                	    varchar2(50);
	v_apellido							      varchar2(50);
	v_fecha_nacimiento          	date;
	v_estado_civil              	varchar2(1) :='7';
	v_sexo                      	varchar2(1) :='7';
	v_edad                      	varchar2(3);
  v_id_ficha_hogar              number;
  v_id_departamento           	number;
	v_id_distrito               	number;
	v_tipoarea                  	varchar2(2):=null;
	v_id_barrio                 	number;
  v_manzana           				  varchar2(20);
	v_barrio								      varchar2(200);
	v_direccion                 	varchar2(255);
  v_telefonobaja              	varchar2(20);
	v_telefonocelular           	varchar2(20);
  v$log rastro_proceso_temporal%ROWTYPE;
  v_id_pension                  number;
  v_estado_pension              number;
  v_clase_pension               number:=150498912213505560;
  v_id_ficha_persona            number;
  v_id_censo_persona            number;
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
      begin
        if v_id_carga_archivo is null then
          v_id_carga_archivo:=busca_clave_id;
					INSERT INTO CARGA_ARCHIVO (ID, VERSION, CODIGO, CLASE, ARCHIVO, ADJUNTO,
         	                              NUMERO_SIME, FECHA_HORA, ARCHIVO_SIN_ERRORES, PROCESO_SIN_ERRORES, OBSERVACIONES)
					VALUES (v_id_carga_archivo, 0, v_id_carga_archivo, x$clase_archivo, x$archivo, id_archivo_adjunto,
								x$sime, sysdate,null, 'false', x$observaciones);
        else
         	Update carga_archivo set OBSERVACIONES=x$observaciones, NUMERO_SIME=x$sime Where id=v_id_carga_archivo;
        End if;
      exception
      when others then
					raise_application_error(-20001,'Error al intentar actualizar la carga del archivo, mensaje:'|| sqlerrm, true);
			end;
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
              v_cedula:=trim(substr(valor_columna,1,10));
            else
            	null;
            end case;
        End loop;
        x$persona:=null;
        Begin
          Select id, departamento, distrito, tipo_area, barrio, direccion, manzana,
                  nombre, nombres, apellidos, fecha_nacimiento, estado_civil, sexo, TELEFONO_LINEA_BAJA, TELEFONO_CELULAR
            into x$persona, v_id_departamento, v_id_distrito, v_tipoarea, v_id_barrio, v_direccion, v_manzana,
                  v_nombres, v_nombre, v_apellido, v_fecha_nacimiento, v_estado_civil, v_sexo, v_telefonobaja, v_telefonocelular
          From persona where codigo=v_cedula;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x$persona:=null;
          v_cant_errores:=v_cant_errores+1;
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'No se encontró datos en persona de la cédula:' || v_cedula);
        end;
        if x$persona is not  null Then
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
            v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error no se encontraron registros de pensión adulto mayor a la persona cédula:' || v_cedula || ', nombres:' || v_nombres);
          when others then
            v_id_pension:=null; v_estado_pension:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar pensión a la cédula de la persona:' || v_cedula || ', nombres:' || v_nombres || ', mensaje:' || err_msg);
          End;
          if v_estado_pension<>7 then
            v_cant_errores:=v_cant_errores+1;
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error no se encontraron registros de pensión adulto mayor en estado otorgado, a la persona cédula:' || v_cedula || ', nombres:' || v_nombres);
          else
            begin
              Select a.id, b.id, c.id
                into v_id_ficha_persona, v_id_censo_persona, v_id_ficha_hogar
              From ficha_persona a inner join censo_persona b on a.id = b.ficha
                inner join ficha_hogar c on a.ficha_hogar = c.id
              Where a.NUMERO_CEDULA=v_cedula And b.estado in (1,2);
            Exception
            WHEN NO_DATA_FOUND THEN
              v_id_ficha_persona:=null; v_id_censo_persona:=null; v_id_ficha_hogar:=null;
            when others then
              v_id_ficha_persona:=null; v_id_censo_persona:=null; v_id_ficha_hogar:=null;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar obtener el id de ficha y/o censo, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
            end;
            if v_id_ficha_hogar is null then
              v_id_ficha_hogar:=busca_clave_id;
              Begin
                INSERT INTO FICHA_HOGAR (ID, VERSION, CODIGO, VERSION_FICHA_HOGAR, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION,
                                        DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO, MANZANA, DIRECCION, NUMERO_SIME, ARCHIVO, LINEA)
                          VALUES (v_id_ficha_hogar, 0, v_id_ficha_hogar, v_version_ficha_hogar, 1, sysdate, current_user_id(),
                                  v_id_departamento, v_id_distrito, v_tipoarea, v_id_barrio, v_manzana, v_direccion, x$sime, v_id_carga_archivo, contador);
              exception
              when others then
                v_id_ficha_hogar:=null;
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 200);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar ficha hogar, línea archivo:' || contador || ', mensaje:' || err_msg);
              end;
            End if;
            if v_id_ficha_persona is null And v_id_ficha_hogar is not null then
              begin
                v_id_ficha_persona := busca_clave_id;
                Select calcular_edad(v_fecha_nacimiento) into v_edad From dual;
                INSERT INTO FICHA_PERSONA (ID, VERSION, CODIGO, NOMBRE, FICHA_HOGAR, NOMBRES,
                                          APELLIDOS, EDAD, SEXO_PERSONA, TIPO_PERSONA_HOGAR, MIEMBRO_HOGAR, NUMERO_ORDEN_IDENTIFICACION,
                                          NUMERO_CEDULA, FECHA_NACIMIENTO, NUMERO_TELEFONO, ESTADO_CIVIL)
                VALUES (v_id_ficha_persona, 0, v_id_ficha_persona, v_nombre, v_id_ficha_hogar, v_nombres,
                        v_apellido, v_edad, v_sexo, 1, 'true', 1,
                        v_cedula, v_fecha_nacimiento, v_telefonobaja, v_estado_civil);
              Exception
              when others then
                v_id_ficha_persona:=null;
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 200);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar la ficha persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
              End;
            end if;
            if v_id_censo_persona is null And v_id_ficha_persona is not null then
              v_id_censo_persona := busca_clave_id;
              INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA, DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO,
                                        DIRECCION, NUMERO_TELEFONO, NUMERO_SIME, ARCHIVO, LINEA, ESTADO,  FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES)
                    values (v_id_censo_persona, 0, v_id_censo_persona, x$persona, sysdate, v_id_ficha_persona, v_id_departamento, v_id_distrito, v_tipoarea, v_id_barrio,
                            v_direccion, v_telefonobaja, x$sime, v_id_carga_archivo, contador, 1, sysdate, current_user_id, x$observaciones);
            end if;
            if v_id_censo_persona is not null then
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
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de monitoreo, cedula:' || v_cedula || ', número de línea:' || contador || ', mensaje:' || err_msg);
              END;
            else
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error: no se actualizo el estado de la persona a monitoreada, pues no se pudo crear el registro de censo. Cédula:' || v_cedula);
            end if;
          end if;
        end if;
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
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(err_num, err_msg, true);
end;
/
