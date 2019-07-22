create or replace function carga_archivo$reclamo(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, x$observaciones nvarchar2)
  return number is
	err_num                       number;
	err_msg                       VARCHAR2(2000);
	v_cant_errores                integer:=0;
	aux                           VARCHAR2(4000);
	v_id_carga_archivo            number;
	v_id_linea_archivo            number;
	cant_registro                 integer :=0;
	archivo_adjunto				        varchar2(255);
	id_archivo_adjunto			      number;
	valor_columna                 varchar2(1000);
	contador                      integer :=0;
	contador_t                    integer :=0;
  contadoraux                   integer :=0;
  v$canal_atencion              number;
  v_cedula							        varchar2(20);
  v$cedula_recurrente		        varchar2(20);
  v$nombre_recurrente		        varchar2(100);
  v$situacion						        varchar2(2000);
  v$contacto						        varchar2(100);
  v$fecha_ultima_consulta		    date;
  v$fecha_aviso_recurrente	    date;
  v$id_consulta_ciudadano       number;
  v$NUMERO_SIME                 number;
  v$DEPARTAMENTO                number;
  v$DISTRITO                    number;
  v$INDIGENA                    varchar2(5);
  v$CLASE_PENSION               number;
  v$PERSONA                     number;
  v$PENSION                     number;
  v$idreclamo_pension			      number;
  v$idtramite_pension			      number;
  v$DEPENDENCIA                 varchar2(200);
  v$FECHA_DEPENDENCIA           date;
  v$DIAS_DEPENDENCIA            number;
  v$DESTINO                     varchar2(200);
  v$DIAS_RECLAMO                integer;
  v$DIAS_SIME                   integer;
  v$CANTIDAD_CONSULTAS          integer;
  v$NUMERO_TELEFONO_CONTACTO    varchar2(13);
  v$TELEFONO_CELULAR            varchar2(13);
  v$estado_consulta             number;
  v$tipo_reclamo                number;
  v$reg								          number;
  v$log                         rastro_proceso_temporal%ROWTYPE;
  v$valor_sime                  varchar2(20);
  v$estado_sime                 varchar2(20);
  v$fecha_creacion_sime         date;
  v$tipo_expediente_sime        varchar2(20);
  v$ci_titular_sime             varchar2(20);
  v$nombre_titular              varchar2(100);
  v$observaciones_sime          varchar2(100);
  v$cod_dependencia_activo      varchar2(100);
  v$nombre_dependencia_activo   varchar2(100);
  v$fecha_activo                date;
  v$cod_dependencia_origen      varchar2(10);
  v$nombre_dependencia_origen   varchar2(100);
  v$cod_dependencia_destino     varchar2(10);
  v$nombre_dependencia_destino  varchar2(100);
  v$fecha_salida_sime           date;
  v$cod_dependencia_accion      varchar2(100);
  v$nombre_dependencia_accion   varchar2(100);
  v$fecha_accion_sime           date;
  v$clasificacion_consulta      number;
begin
	v$log := rastro_proceso_temporal$select();
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
        Update carga_archivo set OBSERVACIONES=observaciones, NUMERO_SIME=x$sime Where id=v_id_carga_archivo;
			End if;
		end if;
		if contador>=contadoraux then
      if (aux is not null) then
        Select length(aux)-length(replace(aux,';','')) Into cant_registro From dual;  --cantidad de columnas
      else
        cant_registro:=0;
      end if;
      For i in 0 .. cant_registro LOOP
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
          when 0 then
            v$canal_atencion:=substr(valor_columna,1,10);
          When 1 Then
            v_cedula:=trim(substr(valor_columna,1,20));
          When 2 Then
            v$cedula_recurrente:=trim(substr(valor_columna,1,20));
          When 3 Then
            v$nombre_recurrente:=trim(substr(valor_columna,1,100));
          When 4 Then
            v$situacion:=trim(substr(valor_columna,1,2000));
          when 5 Then
            v$contacto:=trim(substr(valor_columna,1,100));
          When 6 Then
            v$fecha_ultima_consulta:=extraerddmmyyyy(valor_columna, 'fecha ultima consulta', v_id_linea_archivo, 'true');
          When 7 Then
            v$fecha_aviso_recurrente:=extraerddmmyyyy(valor_columna, 'fecha aviso recurrente', v_id_linea_archivo, 'true');
          else
            null;
          end case;
			End loop;
			Begin
				Select rp.id, pn.clase, pe.id, pn.id, rp.numero_sime, pe.TELEFONO_LINEA_BAJA, pe.TELEFONO_CELULAR, rp.tipo
          into v$idreclamo_pension, v$CLASE_PENSION, v$PERSONA, v$PENSION, v$NUMERO_SIME, v$numero_telefono_contacto, v$TELEFONO_CELULAR, v$tipo_reclamo 
        From persona pe inner join pension pn on pe.id = pn.persona
          inner join reclamo_pension rp on pn.id = rp.pension
        Where pe.codigo=v_cedula And rownum=1
        Order by rp.id desc;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
        v$idreclamo_pension:=null; v$CLASE_PENSION:=null; v$PERSONA:=null; v$PENSION:=null; v$NUMERO_SIME:=null;
			when others then
        v$idreclamo_pension:=null; v$CLASE_PENSION:=null; v$PERSONA:=null; v$PENSION:=null; v$NUMERO_SIME:=null;
				v_cant_errores:=v_cant_errores+1;
				err_msg := SUBSTR(SQLERRM, 1, 200);
				v$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar el reclamo de la cédula:' || v_cedula || ', mensaje:' || err_msg);
			End;
      v$valor_sime:=null; v$estado_sime:=null; v$fecha_creacion_sime:=null; v$tipo_expediente_sime:=null; v$ci_titular_sime:=null; v$nombre_titular:=null; v$observaciones_sime:=null;
      v$cod_dependencia_activo:=null; v$nombre_dependencia_activo:=null; v$fecha_activo:=null; v$cod_dependencia_origen:=null; v$nombre_dependencia_origen:=null; v$cod_dependencia_destino:=null; 
      v$nombre_dependencia_destino:=null; v$fecha_salida_sime:=null; v$cod_dependencia_accion:=null; v$nombre_dependencia_accion:=null; v$fecha_accion_sime:=null;
      if (v$NUMERO_SIME is not null) then
        begin
          Select codigo into v$valor_sime From expediente_sime where id=v$NUMERO_SIME;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v$valor_sime:=null;
        when others then
          v$valor_sime:=null;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          v$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar el codigo del sime para el reclamo id:' || v$idreclamo_pension || ', mensaje:' || err_msg);
        End;
        if v$valor_sime is not null then
          begin
            sime_util.P_SITUACION_ACTUAL(v$valor_sime, v$estado_sime, v$fecha_creacion_sime, v$tipo_expediente_sime, v$ci_titular_sime, v$nombre_titular, v$observaciones_sime,
                              v$cod_dependencia_activo, v$nombre_dependencia_activo, v$fecha_activo, v$cod_dependencia_origen, v$nombre_dependencia_origen, v$cod_dependencia_destino, 
                              v$nombre_dependencia_destino, v$fecha_salida_sime, v$cod_dependencia_accion, v$nombre_dependencia_accion, v$fecha_accion_sime);
          EXCEPTION
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            v$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar el reclamo de la cédula:' || v_cedula || ', mensaje:' || err_msg);
          End;
          if (v$fecha_salida_sime is null) then
            v$estado_consulta:=1;
          else
            v$estado_consulta:=2;
          end if;
        end if;
      else
        v$estado_consulta:=1;
      end if;
      Begin
        Select id into v$clasificacion_consulta
        From clasificacion_consulta where codigo=v$tipo_reclamo; 
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v$clasificacion_consulta:=null;
      when others then
        v$clasificacion_consulta:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        v$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar el codigo del sime para el reclamo id:' || v$idreclamo_pension || ', mensaje:' || err_msg);
      End;
      if v$clasificacion_consulta is null then
        Select id into v$clasificacion_consulta From clasificacion_consulta where codigo='8';
      end if;
      Begin
        v$id_consulta_ciudadano:=busca_clave_id;
				insert into consulta_ciudadano (id, version, codigo, canal_atencion, fecha_recepcion, numero_sime, cedula_recurrente, nombre_recurrente,
                                        clase_pension, persona, pension, reclamo, descripcion, dependencia, fecha_dependencia, dias_dependencia,
                                        situacion, destino, estado, fecha_finiquito, dias_reclamo, dias_sime, cantidad_consultas, fecha_ultima_consulta,
                                        contacto, numero_telefono_contacto, telefono_celular, contacto_correo, fecha_aviso_recurrente,
                                        usuario_aviso_recurrente, canal_aviso_recurrente, dias_transcurrido, estado_consulta, clasificacion_consulta)
				values (v$id_consulta_ciudadano, 0, v$id_consulta_ciudadano, v$canal_atencion, v$fecha_ultima_consulta, v$numero_sime, v$cedula_recurrente, v$nombre_recurrente,
              v$clase_pension, v$persona, v$pension, v$idreclamo_pension, x$observaciones, v$nombre_dependencia_activo, v$fecha_activo, null,
              v$situacion, v$nombre_dependencia_destino, null, v$fecha_salida_sime, null, null, null, v$fecha_ultima_consulta,
              v$contacto, v$numero_telefono_contacto, v$TELEFONO_CELULAR, null, v$fecha_aviso_recurrente,
              null, null, null, v$estado_consulta, v$clasificacion_consulta);
      EXCEPTION
			when others then
				v_cant_errores:=v_cant_errores+1;
				err_msg := SUBSTR(SQLERRM, 1, 300);
				v$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar crear el registro de consulta ciudadano, cedula:' || v_cedula || ', número de línea:' || contador || ', mensaje:' || err_msg);
			END;
			if (v_cant_errores>0) Then
        Update LINEA_ARCHIVO set ERRORES=v_cant_errores Where id=v_id_linea_archivo;
			End If;
      contador_t:=contador_t+1;
			if contador_t>1000 then
				update carga_archivo set directorio=contador Where id=v_id_carga_archivo;
				commit work;
				rastro_proceso_temporal$revive(v$log);
				contador_t:=0;
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
