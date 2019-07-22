create or replace function carga_archivo$subsidio(x$archivo varchar2,  x$clase_archivo varchar2, x$sime number, observaciones nvarchar2)
  return number is
  err_num                     number;
  err_msg                     VARCHAR2(2000);
  v_cant_errores					    integer:=0;
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
	i									        	integer :=-1;
  auxi                        integer;
  x$persona							      number;
  v_cedula                	  varchar2(20);
  v_nombre                	  varchar2(100);  
  v_fecha_ingreso				      date;
  v_fecha_egreso				      date;
  v_id_subsidio								number;
  v_monto					        		number;
  x$ruc_entidad		      			nvarchar2(20):=null;
  v_nombre_empresa            nvarchar2(200):=null;
  x$reg								        integer;
  v$log rastro_proceso_temporal%ROWTYPE;
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
      Exception   
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
      begin
       Update subsidio set informacion_invalida='true' where informacion_invalida='false';
       Update persona set NOMBRE_EMPRESA_SUB=null where NOMBRE_EMPRESA_SUB is not null;
      exception
      when others then
        raise_application_error(-20001,'Error al intentar actualizar a inválido los registros de subsidios validos, mensaje:'|| sqlerrm, true);
      End;
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
        When 1 Then
          v_nombre:=trim(substr(valor_columna,1,100));
        When 2 Then
          v_fecha_ingreso:=extraerddmmyyyy(valor_columna, 'fecha ingreso nombres:' || v_nombre, v_id_linea_archivo, 'true');
        When 3 Then
          v_fecha_egreso:=extraerddmmyyyy(valor_columna, 'fecha egreso nombres:' || v_nombre, v_id_linea_archivo, 'true');
        When 4 Then
          BEGIN
            Select to_number(valor_columna) into v_monto from dual;
          EXCEPTION
          when others then
            v_monto:=0;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar obtener el monto del subsidio, cédula:' || v_cedula || ', nombres:' || v_nombre || ', valor leido[' || valor_columna || '], mensaje:' || err_msg);
          END;
        When 5 Then
          v_nombre_empresa:=trim(substr(valor_columna,1,200));
        else
          null;
        end case;
			End loop;
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
        if v_fecha_ingreso is null then
          Select id into v_id_subsidio
	        From subsidio
	        Where cedula=v_cedula And fecha_ingreso is null
            And rownum=1; --buscamos registros anteriores de subsidio con la misma fecha, para no repetir objeciones
				else
					Select id into v_id_subsidio
	        From subsidio
	        Where cedula=v_cedula And fecha_ingreso=v_fecha_ingreso
            And rownum=1; --buscamos registros anteriores de subsidio con la misma fecha, para no repetir objeciones
        end if;
      Exception
      WHEN NO_DATA_FOUND THEN
        v_id_subsidio:=NULL;
      when others then
				v_id_subsidio:=NULL;
				err_msg := SUBSTR(SQLERRM, 1, 200);
        v_cant_errores:=v_cant_errores+1;
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener un registro anterior de subsidio para la cédula:' || v_cedula || ', nombres:' || v_nombre || ', mensaje:' || err_msg);
			end;
      Begin
        if v_id_subsidio is null then
            v_id_subsidio:=busca_clave_id;
            insert into subsidio (id, version, codigo, persona, cedula, nombre, FECHA_INGRESO, FECHA_EGRESO, monto,nombre_empresa,
                    					    numero_sime, archivo, linea, informacion_invalida, fecha_transicion, observaciones)
	               	        values (v_id_subsidio, 0, v_id_subsidio, x$persona, v_cedula, v_nombre, v_fecha_ingreso, v_fecha_egreso, v_monto,v_nombre_empresa,
	                  	        		x$sime, v_id_carga_archivo, contador, 'false', sysdate, observaciones);
            if x$persona is not null then
              begin
                Update persona set FECHA_EGRESO_SUB=v_fecha_egreso, FECHA_INGRESO_SUB=v_fecha_ingreso, MONTO_SUB=monto, NUMERO_SIME_SUB=x$sime, NOMBRE_EMPRESA_SUB=v_nombre_empresa
                Where id=x$persona;
              EXCEPTION
              When others then
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 200);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar actualizar los datos de subsidio de la persona cedula:' || v_cedula || ', nombres:' || v_nombre || ', linea:' || contador || ', mensaje:' || err_msg);
              End;
            end if;
        else
            Update subsidio set FECHA_INGRESO=v_fecha_ingreso, FECHA_EGRESO=v_fecha_egreso, monto=v_monto, nombre_empresa=v_nombre_empresa, nombre=v_nombre, persona=x$persona,
                                numero_sime=x$sime, archivo=v_id_carga_archivo, linea=contador, fecha_transicion=sysdate, observaciones=observaciones
            Where id=v_id_subsidio;
            if v_fecha_egreso is not null Then
	          	Update subsidio set informacion_invalida='true' Where id= v_id_subsidio;
            end if;
        end if;
      EXCEPTION
      when others then
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 300);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de subsidio, cedula:' || v_cedula || ', nombres:' || v_nombre || ', número de línea:' || contador || ', mensaje:' || err_msg);
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
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(err_num, 'Error no controlado en carga archivo subsidio, mensaje: ' || err_msg || ' en línea:' || contador, true);
end;
/
