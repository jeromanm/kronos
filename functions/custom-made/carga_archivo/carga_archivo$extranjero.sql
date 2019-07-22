create or replace function carga_archivo$extranjero(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, observaciones nvarchar2)
  return number is                              
	err_msg                       VARCHAR2(2000);
	aux                           VARCHAR2(20000);
	v_id_carga_archivo            number;
	v_id_linea_archivo            number;
	cant_registro                 integer :=0;
	v_cant_errores                integer;
	archivo_adjunto					      varchar2(255);
	id_archivo_adjunto				    number;
	valor_columna                 varchar2(1000);
	contador                      integer :=1;
	contador_t                    integer :=1;
	contadoraux							      integer :=1;
	i                             integer :=-1;
	auxi                          integer;
	v_cedula                      varchar2(20);
  v_id_cedula							      number;
	v_nombre						        	varchar2(100);
	x$persona                     number;
  x$reg                         number;
	v_id_res_ext					  	    number;
	v_ano_votacion               	varchar2(10);
  v_paraguayo                 	varchar2(5);
  v_extranjero                  varchar2(5);
  v_pais								        number;
	v_domicilio		              	varchar2(200);
  v_fecha_inscripcion				    date;
  v$log rastro_proceso_temporal%ROWTYPE;
  v_dist								        number;
  v_jaro						        		number;
begin
	v$log := rastro_proceso_temporal$select();
	For reg in (Select * From csv_imp_temp Where archivo=x$archivo order by 1) loop
  	if trim(reg.registro) is not null then
	    aux:=trim(substr(trim(reg.registro),1,20000));
    else
	    aux:=null;
    end if;
		v_cant_errores:=0;
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
								x$sime, sysdate, null, 'false', observaciones);
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
			if cant_registro is null then 
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
				When 1 Then
					v_nombre:=trim(substr(valor_columna,1,100));
				When 2 Then
					v_ano_votacion:=trim(substr(valor_columna,1,10));
				when 3 then
          begin
						Select pa.id, utl_match.edit_distance_similarity(upper(pa.nombre),upper(substr(valor_columna,1,100))) as dist,
								utl_match.jaro_winkler_similarity(upper(pa.nombre),upper(substr(valor_columna,1,100))) as jaro
                  into v_pais, v_dist, v_jaro
						From pais pa
						Where utl_match.jaro_winkler_similarity(upper(pa.nombre),upper(substr(valor_columna,1,100)))>95
                  	And rownum=1
						Order by jaro desc;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_pais:=180;
            v_cant_errores:=v_cant_errores+1;
  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'País no encontrado:' || valor_columna || ', cedula:' || v_cedula || ', nombres:' || v_nombre);
          when others then
						v_pais:=180;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código de País, valor leído:' || valor_columna || ', nombres:' || v_nombre || ', mensaje:' || err_msg);
					END;
          v_paraguayo:='true';
          v_extranjero:='false';
				When 4 Then
					v_domicilio:=trim(substr(valor_columna,1,200));
        When 5 Then
					v_fecha_inscripcion:=extraerddmmyyyy(valor_columna, 'fecha inscripción nombres:' || v_nombre, v_id_linea_archivo, 'true');
        else
          null;
        end case;
			End loop; --For i in 0 .. cant_registro LOOP
      x$persona:=null;
      Begin
        Select pe.id into x$persona From persona pe Where pe.codigo=v_cedula;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x$persona:=null;
      when others then
        x$persona:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar la cédula del empleado:' || v_cedula || ', nombres:' || v_nombre || ', mensaje:' || err_msg);
      End;
      Begin
         	if v_fecha_inscripcion is null then
            Select id into v_id_res_ext
	          From residente_extranjero
	          Where cedula=v_cedula And FECHA_INSCRIPCION is null
              And rownum=1; --buscamos registros anteriores de empleo con la misma fecha, para no repetir objeciones
					else
						Select id into v_id_res_ext
            From residente_extranjero 
	          Where cedula=v_cedula And FECHA_INSCRIPCION=v_fecha_inscripcion
	          	And rownum=1; --buscamos registros anteriores de empleo con la misma fecha, para no repetir objeciones               
          end if;                     
      Exception
      WHEN NO_DATA_FOUND THEN
					v_id_res_ext:=NULL;
      when others then
					v_id_res_ext:=NULL;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					v_cant_errores:=v_cant_errores+1;
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener un registro anterior de residente en el extranjero para la cédula:' || v_cedula || ', nombres:' || v_nombre || ', mensaje:' || err_msg);
      End;
      Begin
          if v_id_res_ext is null then
            v_id_res_ext:=busca_clave_id;
            insert into residente_extranjero (id, version, codigo, persona, cedula, nombre, ANO_VOTACION, PAIS, 
                                            DOMICILIO, FECHA_INSCRIPCION, ARCHIVO, LINEA, INFORMACION_INVALIDA, FECHA_TRANSICION,
                                            NUMERO_SIME, DESCRIPCION)
						values (v_id_res_ext, 0, v_id_res_ext, x$persona, v_cedula, v_nombre, v_ano_votacion, v_pais, 
                    v_domicilio, v_fecha_inscripcion, v_id_carga_archivo, contador, 'false', sysdate,
                    x$sime, observaciones);
            if x$persona is not null Then
              begin
                update persona set ANO_VOTACION=v_ano_votacion, PAIS_RESID=v_pais, DOMICILIO=v_domicilio, FECHA_INSCRIPCION=v_fecha_inscripcion,
                                    NUMERO_SIME_RESIDENTE=x$sime
                Where id=x$persona;
              EXCEPTION
              when others then
                err_msg := SUBSTR(SQLERRM, 1, 300);
                v_cant_errores:=v_cant_errores+1;
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar el registro de persona, cedula:' || v_cedula || ', nombres:' || v_nombre || ', mensaje:' || err_msg);
              END;
            end if;
          else
            Update residente_extranjero set ANO_VOTACION=v_ano_votacion, PAIS=v_pais, DOMICILIO=v_domicilio, FECHA_INSCRIPCION=v_fecha_inscripcion, 
                                            ARCHIVO=v_id_carga_archivo, LINEA=contador, FECHA_TRANSICION=sysdate, NUMERO_SIME=x$sime, DESCRIPCION=observaciones
						Where id=v_id_res_ext;
          end if;
      EXCEPTION
      when others then
          err_msg := SUBSTR(SQLERRM, 1, 300);
          v_cant_errores:=v_cant_errores+1;
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de residente extranjero, cedula:' || v_cedula || ', nombres:' || v_nombre || ', mensaje:' || err_msg);
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
