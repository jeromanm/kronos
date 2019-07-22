create or replace function carga_archivo$matrimonio(x$archivo varchar2,  x$clase_archivo varchar2, x$sime number, observaciones nvarchar2)
  return number is
  err_num                       	number;
  err_msg                       	VARCHAR2(2000);
  v_cant_errores					  	    integer:=0;
  aux                           	VARCHAR2(4000);
  v_id_carga_archivo            	number;
  v_id_linea_archivo            	number;
  cant_registro                 	integer :=0;
  valor_columna                 	varchar2(1000);
  archivo_adjunto					        varchar2(255);
	id_archivo_adjunto			      	number;
	contador                        integer :=1;
  contador_t                      integer :=1;
  contadoraux							        integer :=1;
	i                               integer :=-1;
  auxi                          	integer;
  v_cedula1                	  	  varchar2(20);
  v_nombre1                	  	  varchar2(100);
  v_cedula2                	  	  varchar2(20);
  v_nombre2               	  	  varchar2(100);
  v_fecha_matrimonio              date;
  v_departamento 					  	    varchar2(10);
  v_distrito						  	      varchar2(10);
  v_id_departamento 				  	  number;
  v_id_distrito					  	      number;
  x$persona                     	number;
  v_id_persona1                 	number;
  v_id_persona2                 	number;
  v_id_matrimonio						      number;
  x$folio_matrimonio				  	  varchar2(10);
  x$acta_matrimonio				  	    varchar2(10);
  x$tomo_matrimonio					      varchar2(20);
  x$reg								  	        number;
  v_id_cedula1							      number;
  v_id_cedula2							      number;
  v_fecha_matrimonio1				      date;
  v$log rastro_proceso_temporal%ROWTYPE;
  v_dist                          number;
  v_jaro                          number;
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
								x$sime, sysdate,null, 'false', observaciones);
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
          v_cedula1:=trim(substr(valor_columna,1,20));
        When 1 Then
          v_nombre1:=trim(substr(valor_columna,1,50));
        When 2 Then
          v_nombre1:=substr(v_nombre1 || ' ' || trim(substr(valor_columna,1,50)),1,100);
        When 3 Then
					v_fecha_matrimonio:=extraerddmmyyyy(valor_columna, 'fecha matrimonio', v_id_linea_archivo, 'true');
				When 4 Then
          BEGIN
            Select trim(to_char(substr(valor_columna,1,2),'00')) into v_departamento from dual;
						Select id into v_id_departamento From departamento Where codigo=trim(v_departamento);
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_departamento:=99;
						v_cant_errores:=v_cant_errores+1;
  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'AVISO: Departamento no encontrado:' || v_departamento);
          when others then
            v_id_departamento:=99;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Error al intentar obtener el codigo del departamento de la cédula del primer cónyuge:' || v_cedula1 || ', mensaje:' || err_msg);
					END;
				When 5 Then
          BEGIN
            if length(valor_columna)<=2 then
              Select trim(v_departamento) ||  trim(to_char(valor_columna,'00')) into v_distrito from dual;
            else
              Select to_char(substr(valor_columna,1,4),'0000') into v_distrito from dual;
            end if;
						Select id into v_id_distrito From distrito Where codigo=trim(v_distrito);
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_distrito:=99;
						v_cant_errores:=v_cant_errores+1;
  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'AVISO: Distrito no encontrado:' || v_distrito);
          when others then
            v_id_distrito:=99;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Error al intentar obtener el codigo del distrito de la cédula del primer cónyuge:' || v_cedula1 || ', mensaje:' || err_msg);
					END;
        When 6 Then
          v_cedula2:=trim(substr(valor_columna,1,20));
        When 7 Then
          v_nombre2:=trim(substr(valor_columna,1,50));
        When 8 Then
          v_nombre2:=substr(v_nombre2 || ' ' || trim(substr(valor_columna,1,50)),1,100);
        When 9 Then
          x$folio_matrimonio:=trim(substr(valor_columna,1,10));
        When 10 Then
          x$acta_matrimonio:=trim(substr(valor_columna,1,10));
        When 11 Then
          x$tomo_matrimonio:=trim(substr(valor_columna,1,20));
        else
          null;
        end case;
			End loop;
      Begin
        Select id into v_id_persona1 From persona where codigo=v_cedula1;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_id_persona1:=null;
      when others then
        v_id_persona1:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Error al intentar buscar la cédula del primer cónyuge:' || v_cedula1 || ', mensaje:' || err_msg);
      End;
      Begin
  			Select id into v_id_persona2 From persona where codigo=v_cedula2;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_id_persona2:=null;
      when others then
        v_id_persona2:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar la cédula del segundo cónyuge:' || v_cedula2 || ', mensaje:' || err_msg);
      End;
      begin
        if v_fecha_matrimonio is null then
            Select id into v_id_matrimonio
            From matrimonio
            Where (cedula1=v_cedula1 or cedula2=v_cedula2) And fecha_matrimonio is null
              And rownum=1; --buscamos registros anteriores de registro matrimonio con la misma fecha, para no repetir objeciones
          else
            Select id into v_id_matrimonio
            From matrimonio
            Where (cedula1=v_cedula1 or cedula2=v_cedula2) And fecha_matrimonio=v_fecha_matrimonio
    					And rownum=1; --buscamos registros anteriores de registro matrimonio con la misma fecha, para no repetir objeciones
          end if;
        Exception
        WHEN NO_DATA_FOUND THEN
  				v_id_matrimonio:=NULL;
        when others then
  				v_id_matrimonio:=NULL;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          v_cant_errores:=v_cant_errores+1;
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener un registro anterior de registro de matrimonio para la cédula cónyuge:' || v_cedula1 || ', mensaje:' || err_msg);
        End;
      Begin
        if v_id_matrimonio is null then
            v_id_matrimonio:=busca_clave_id;
            insert into matrimonio (id, version, codigo, persona, cedula1, nombre1, persona2, cedula2, nombre2,  
                                    tomo_matrimonio, folio_matrimonio, acta_matrimonio, fecha_matrimonio,
                                    numero_sime, archivo, linea, informacion_invalida, fecha_transicion, observaciones)
                              values (v_id_matrimonio, 0, v_id_matrimonio, v_id_persona1, v_cedula1, v_nombre1, v_id_persona2, v_cedula2, v_nombre2, 
                                    x$tomo_matrimonio, x$folio_matrimonio, x$acta_matrimonio, v_fecha_matrimonio,
                                    x$sime, v_id_carga_archivo, contador, null, sysdate, observaciones);
            begin
              if v_id_persona1 is not null then
                Update persona set fecha_matrimonio=v_fecha_matrimonio, nombre_conyuge=v_nombre2, cedula_conyuge=v_cedula2,
                                  folio_matrimonio=x$folio_matrimonio, acta_matrimonio=x$acta_matrimonio,
                                  tomo_matrimonio=x$tomo_matrimonio, numero_sime_matrimonio=x$sime
                Where id=v_id_persona1;
              end if;                 
              if v_id_persona2 is not null then
                Update persona set fecha_matrimonio=v_fecha_matrimonio, nombre_conyuge=v_nombre1, cedula_conyuge=v_cedula1,
                                  folio_matrimonio=x$folio_matrimonio, acta_matrimonio=x$acta_matrimonio,
                                  tomo_matrimonio=x$tomo_matrimonio, numero_sime_matrimonio=x$sime
                Where id=v_id_persona2;
              end if;
            Exception
            when others then
              err_msg := SUBSTR(SQLERRM, 1, 200);
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar los datos de la persona, mensaje:' || err_msg);
            End;  
        else
            Update matrimonio set tomo_matrimonio=x$tomo_matrimonio, folio_matrimonio=x$folio_matrimonio, acta_matrimonio=x$acta_matrimonio, 
                                  nombre1=v_nombre1, nombre2=v_nombre2, fecha_matrimonio=v_fecha_matrimonio, persona=v_id_persona1, persona2=v_id_persona2,
                                  numero_sime=x$sime, archivo=v_id_carga_archivo, linea=contador, fecha_transicion=sysdate, observaciones=observaciones
            Where id=v_id_matrimonio;
        end if;
      EXCEPTION
			when others then
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 300);
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de matrimonio, cedula conyuge:' || v_cedula1 || ', número de línea:' || contador || ', mensaje:' || err_msg);
      END;
			if (v_cant_errores>0) Then
        Update LINEA_ARCHIVO set ERRORES=v_cant_errores Where id=v_id_linea_archivo;
			End If;
      contador:=contador+1; contador_t:=contador_t+1;
			if contador_t>1000 then
				update carga_archivo set directorio=contador Where id=v_id_carga_archivo;
				commit work;
				rastro_proceso_temporal$revive(v$log);
				contador_t:=1;
			end if;
		end if; --elsif contador>contadoraux then
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
