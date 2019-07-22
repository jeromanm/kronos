create or replace function carga_archivo$defunciones(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, observaciones nvarchar2)
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
	v_nombre								      varchar2(100);
  v_edad								        number;
	x$persona                     number;
  v_fecha_nacimiento            date;
  v_lugar_nacimiento            varchar2(100);
	x$oficina_defuncion           number;
  x$nombre_oficina_defuncion    nvarchar2(50);
	x$certificado_defuncion       nvarchar2(20);
	x$tomo_defuncion              nvarchar2(20);
	x$folio_defuncion             nvarchar2(10);
	x$acta_defuncion              nvarchar2(10);
	x$fecha_acta_defuncion        date;
	x$fecha_defuncion             date;
	x$fecha_transicion            date;
	x$reg								        	number;
	v_id_cedula					      		number;
  v_id_defuncion					    	number;
  v_id_departamento				  	  number;
	v_departamento						    varchar2(200);
  v_id_distrito						      number;
	v_distrito							      varchar2(200);
	v_oficina_registral				    varchar2(200);
  v_lugar_fallecimiento			    varchar2(200); 
  v_paraguayo                 	varchar2(5);
  v_extranjero                 	varchar2(5);
  v_pais								        number;
  v$log rastro_proceso_temporal%ROWTYPE;
  v_dist								        number;
  v_jaro								        number;
  v_nacionalidad                varchar2(50);
begin
	v$log := rastro_proceso_temporal$select();
  For reg in (Select * From csv_imp_temp Where archivo=x$archivo order by 1) loop
      v_paraguayo:='true';
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
        if cant_registro is null then 
          cant_registro:=0;
        end if;
        x$oficina_defuncion:=null; v_fecha_nacimiento:=null; 
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
            x$certificado_defuncion:=trim(substr(valor_columna,1,20));
          When 3 Then
            Begin
              Select id, nombre 
                into x$oficina_defuncion, x$nombre_oficina_defuncion 
              From oficina_registral where codigo=trim(valor_columna);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              x$oficina_defuncion:=null;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'AVISO: oficina registral no encontrado, valor leído:' || valor_columna || ', nombre: ' || v_nombre);
            when others then
              x$oficina_defuncion:=null;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código de la oficina registral, valor leído:' || valor_columna || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
          	end;
          When 4 Then
            x$fecha_acta_defuncion:=extraerddmmyyyy(valor_columna, 'fecha acta de defunción de ' || v_nombre, v_id_linea_archivo, 'true');
          when 5 Then
            x$tomo_defuncion:=substr(trim(valor_columna),1,20);
          when 6 Then
            x$folio_defuncion:=substr(trim(valor_columna),1,10);
          when 7 Then
            x$acta_defuncion:=substr(trim(valor_columna),1,10);
          When 8 Then
            x$fecha_defuncion:=extraerddmmyyyy(valor_columna, 'fecha defunción de ' || v_nombre, v_id_linea_archivo, 'true');
          When 9 Then
            x$fecha_transicion:=extraerddmmyyyy(valor_columna, 'fecha transición de ' || v_nombre, v_id_linea_archivo, 'true');
          when 11 then
            begin
              for reg1 in (Select dp.id, dp.nombre, utl_match.edit_distance_similarity(upper(dp.nombre),upper(substr(valor_columna,1,200))) as dist,
                              utl_match.jaro_winkler_similarity(upper(dp.nombre),upper(substr(valor_columna,1,200))) as jaro
                      From departamento dp
                      Where utl_match.jaro_winkler_similarity(upper(dp.nombre),upper(substr(valor_columna,1,200)))>75
                      Order by jaro desc) loop
                v_id_departamento:=reg1.id;
                v_departamento:=reg1.nombre;
                v_dist:=reg1.dist;
                v_jaro:=reg1.jaro;
                exit;
              end loop;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
  						v_id_departamento:=99;
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Departamento no encontrado:' || valor_columna || ', cedula:' || v_cedula || ', nombre: ' || v_nombre);
            when others then
              v_id_departamento:=99;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código de Departamento, valor leído:' || valor_columna || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
            END;
          when 12 then
            begin
              for reg1 in (Select a.id, a.nombre, utl_match.edit_distance_similarity(upper(a.nombre),upper(substr(valor_columna,1,200))) as dist,
                                utl_match.jaro_winkler_similarity(upper(a.nombre),upper(substr(valor_columna,1,200))) as jaro
                        From distrito a
                        Where departamento=v_id_departamento
                          And utl_match.jaro_winkler_similarity(upper(a.nombre),upper(substr(valor_columna,1,200)))>75
                        Order by jaro desc) loop
                  v_id_distrito:=reg1.id;
                  v_distrito:=reg1.nombre;
                  v_dist:=reg1.dist;
                  v_jaro:=reg1.jaro;
                  exit;
              end loop;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              if v_id_departamento=99 then
                v_id_distrito:=99;
              else
                v_id_distrito:=null;
              end if;
              v_cant_errores:=v_cant_errores+1;          
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Distrito no encontrado:' || valor_columna || ', cedula:' || v_cedula || ', nombre: ' || v_nombre);
            when others then
  						v_id_distrito:=99;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código de Distrito, valor leído:' || valor_columna || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
            END;
          when 13 then
            if x$oficina_defuncion is null then
              x$nombre_oficina_defuncion:=substr(valor_columna,1,50);
              begin
                  for reg1 in (Select a.id, a.nombre, utl_match.edit_distance_similarity(upper(a.nombre),upper(substr(valor_columna,1,200))) as dist,
                                    utl_match.jaro_winkler_similarity(upper(a.nombre),upper(substr(valor_columna,1,200))) as jaro
                      From oficina_registral a
                      Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(substr(valor_columna,1,200)))>75
                      Order by jaro desc) loop
                    x$oficina_defuncion:=reg1.id;
                    v_dist:=reg1.dist;
                    v_jaro:=reg1.jaro;
                    exit;
                  end loop;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                x$oficina_defuncion:=null;
                v_cant_errores:=v_cant_errores+1;
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Oficina no encontrado:' || valor_columna || ', cedula:' || v_cedula || ', nombre: ' || v_nombre);
              when others then
                x$oficina_defuncion:=null;
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 200);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código de la oficina registral, valor leído:' || valor_columna || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
              END;
            end if;
          when 14 then
            v_lugar_fallecimiento:=substr(trim(valor_columna),1,200);
          when 15 then
            begin
              v_nacionalidad:=substr(valor_columna,1,200);
              for reg1 in (Select a.id, utl_match.edit_distance_similarity(upper(a.nombre),upper(substr(valor_columna,1,200))) as dist,
                                  utl_match.jaro_winkler_similarity(upper(a.nombre),upper(substr(valor_columna,1,200))) as jaro
                          From pais a
                          Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(substr(valor_columna,1,200)))>75
                          Order by jaro desc) loop
                  v_pais:=reg1.id;
                  v_dist:=reg1.dist;
                  v_jaro:=reg1.jaro;
                  exit;
              end loop;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v_pais:=180;
              v_cant_errores:=v_cant_errores+1;
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'País no encontrado:' || valor_columna || ', cedula:' || v_cedula || ', nombre: ' || v_nombre);
            when others then
              v_pais:=180;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el código de País, valor leído:' || valor_columna || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
            END;
            v_paraguayo:='true';
            v_extranjero:=null;
          when 16 then
            begin
              v_edad:=substr(trim(valor_columna),1,2);
            EXCEPTION
            when others then
              v_edad:=null;
              v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener la edad del fallecido, valor leído:' || valor_columna || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
            END;
          when 17 then
            v_lugar_nacimiento:=substr(trim(valor_columna),1,50);
          when 18 then
            if v_fecha_nacimiento is null then
              v_fecha_nacimiento:=extraerddmmyyyy(valor_columna, 'fecha nacimiento, nombre: ' || v_nombre, v_id_linea_archivo, 'true');
            end if;
          else
          	null;
          end case;
        End loop; --For i in 0 .. cant_registro LOOP
        Begin
          Select pe.id into x$persona From persona pe Where pe.codigo=v_cedula;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x$persona:=NULL;
        when others then
          x$persona:=NULL;
          err_msg := SUBSTR(SQLERRM, 1, 200);
     			v_cant_errores:=v_cant_errores+1;            
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar la cédula:' || v_cedula || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
        End;
        begin
          if x$fecha_defuncion is null then
			      Select id into v_id_defuncion
	          From defuncion 
	          Where cedula=v_cedula And fecha_defuncion is null
	           	And rownum=1; --buscamos registros anteriores de defuncion con la misma fecha, para no repetir objeciones
          else
            Select id into v_id_defuncion
	          From defuncion 
	          Where cedula=v_cedula And fecha_defuncion=x$fecha_defuncion
	           	And rownum=1; --buscamos registros anteriores de defuncion con la misma fecha, para no repetir objeciones               
          end if;
				Exception
				WHEN NO_DATA_FOUND THEN
					v_id_defuncion:=NULL;
				when others then
					v_id_defuncion:=NULL;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					v_cant_errores:=v_cant_errores+1;
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener un registro anterior de defunción para la cédula:' || v_cedula || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
				End;
        Begin
          if v_id_defuncion is null then --si el registro no es encontrado se crea uno
            v_id_defuncion:=busca_clave_id;
            insert into defuncion (id, version, codigo, cedula, nombre, certificado_defuncion, oficina_defuncion, fecha_acta_defuncion,
                                    tomo_defuncion, folio_defuncion, acta_defuncion, fecha_defuncion, fecha_certificado_defuncion, nombre_registro,
                                    numero_sime, archivo, linea, informacion_invalida, fecha_transicion, observaciones, LUGAR_FALLECIDO,
                                    LUGAR_NACIMIENTO, FECHA_NACIMIENTO_DEFU, departamento, distrito, NACIONALIDAD, persona, edad)
						values (v_id_defuncion, 0, v_id_defuncion, v_cedula, v_nombre, x$certificado_defuncion, x$oficina_defuncion, x$fecha_acta_defuncion,
		                  x$tomo_defuncion, x$folio_defuncion, x$acta_defuncion, x$fecha_defuncion, null,x$nombre_oficina_defuncion,
		                  x$sime, v_id_carga_archivo, contador, null, x$fecha_transicion, observaciones, v_lugar_fallecimiento,
                      v_lugar_nacimiento, v_fecha_nacimiento, v_id_departamento, v_id_distrito, v_nacionalidad, x$persona, v_edad);
            if x$persona is not null then
              update persona set certificado_defuncion=x$certificado_defuncion, oficina_defuncion= x$oficina_defuncion, fecha_acta_defuncion=x$fecha_acta_defuncion,
                                tomo_defuncion=x$tomo_defuncion, folio_defuncion=x$folio_defuncion, acta_defuncion=x$acta_defuncion, fecha_defuncion=x$fecha_defuncion,
                                fecha_certificado_defuncion=null, numero_sime_defuncion=x$sime, departamentodef=v_id_departamento, distritodef=v_id_distrito, 
                                lugar_nacimiento_def=v_lugar_nacimiento, fecha_nacimiento_defu=v_fecha_nacimiento, nacionalidad=v_nacionalidad, edad=v_edad
              Where id=x$persona;
            end if;
          else
            Update defuncion set certificado_defuncion=x$certificado_defuncion, oficina_defuncion=x$oficina_defuncion, fecha_acta_defuncion=x$fecha_acta_defuncion,
                                 tomo_defuncion=x$tomo_defuncion, folio_defuncion=x$folio_defuncion, acta_defuncion=x$acta_defuncion, fecha_defuncion=x$fecha_defuncion, 
                                 numero_sime=x$sime, archivo=v_id_carga_archivo, linea=contador, fecha_transicion=sysdate, observaciones=observaciones, 
                                 LUGAR_FALLECIDO=v_lugar_nacimiento, FECHA_NACIMIENTO_DEFU=v_fecha_nacimiento, departamento=v_id_departamento, 
                                 distrito=v_id_distrito, NACIONALIDAD=v_nacionalidad, persona=x$persona, nombre_registro=x$nombre_oficina_defuncion
            Where id=v_id_defuncion;
          end if;
        EXCEPTION
        when others then
          err_msg := SUBSTR(SQLERRM, 1, 300);
          v_cant_errores:=v_cant_errores+1;
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar el registro de defunción, cedula:' || v_cedula || ', nombre: ' || v_nombre || ', mensaje:' || err_msg);
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
