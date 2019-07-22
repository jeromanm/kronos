create or replace function carga_archivo$automotor(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, observaciones nvarchar2)
  return number is
	err_msg                 VARCHAR2(2000);
	v_cant_errores			integer:=0;
	aux                     VARCHAR2(4000);
	v_id_carga_archivo      number;
	v_id_linea_archivo      number;
	cant_registro           integer :=0;
	archivo_adjunto			varchar2(255);
	id_archivo_adjunto		number;
	valor_columna           varchar2(1000);
	contador                integer :=1;
	contador_t              integer :=1;
	contadoraux				integer :=1;
	i                       integer :=-1;
	auxi                    integer;
	x$persona				number;
	v_cedula               	varchar2(20);
	v_nombre               	varchar2(100);
	v_id_automotor			number;
	v_fecha_ingreso  		date;
	v_fecha_egreso  		date;
	v_tipo_automotor		varchar2(200);
	v_cantidad				integer;
	v_modelo				varchar2(50);
	v_ano_registro			varchar2(4);
	v_monto					number;
	x$reg					integer;
	v_dist                  number;
	v_jaro                  number;
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
          v_fecha_ingreso:=extraerddmmyyyy(valor_columna, 'fecha ingreso, nombres:' || v_nombre, v_id_linea_archivo, 'true');
        When 3 Then
          v_fecha_egreso:=extraerddmmyyyy(valor_columna, 'fecha egreso:' || v_nombre, v_id_linea_archivo, 'true');
        When 4 Then
           v_tipo_automotor:=trim(substr(valor_columna,1,200));
        When 5 Then
           v_cantidad:=trim(substr(valor_columna,1,4));
        When 6 Then
           v_modelo:=trim(substr(valor_columna,1,50));
        When 7 Then
           v_ano_registro:=trim(substr(valor_columna,1,4));
        When 8 Then
          BEGIN
            Select to_number(valor_columna) into v_monto from dual;
          EXCEPTION
          when others then
            v_monto:=0;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 300);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar obtener el monto del veh�culo, c�dula:' || v_cedula || ', nombres:' || v_nombre || ', valor leido[' || valor_columna || '], mensaje:' || err_msg);
          END;
        else
          null;
        end case;
      End loop;
      x$persona:=null;
      Begin
        Select id into x$persona From persona where codigo=v_cedula;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
      	x$persona:=null;
      when others then
      	x$persona:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 300);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar buscar la c�dula de la persona:' || v_cedula || ', nombres:' || v_nombre || ', mensaje:' || err_msg);
      End;
      v_id_automotor:=null;
				Begin
          if v_fecha_ingreso is null then
			      Select id into v_id_automotor
	          From automotor
	          Where cedula=v_cedula And fecha_ingreso is null
	           	And rownum=1; --buscamos registros anteriores de registro automotor con la misma fecha, para no repetir objeciones
					else
						Select id into v_id_automotor
	          From automotor
	          Where cedula=v_cedula And fecha_ingreso=v_fecha_ingreso
              And rownum=1; --buscamos registros anteriores de registro automotor con la misma fecha, para no repetir objeciones
          end if;
				Exception
				WHEN NO_DATA_FOUND THEN
					v_id_automotor:=NULL;
				when others then
					v_id_automotor:=NULL;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					v_cant_errores:=v_cant_errores+1;
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener un registro anterior de registro automotor para la c�dula:' || v_cedula || ', nombres:' || v_nombre || ', mensaje:' || err_msg);
				End;
        Begin
          if v_id_automotor is null then
            v_id_automotor:=busca_clave_id;
						insert into automotor (id, version, codigo, persona, cedula, nombre, 
                                    fecha_ingreso, fecha_egreso, tipo, cantidad, modelo, ano_registro,
	                                  monto, numero_sime, archivo, linea, fecha_transicion, observaciones)
		                       values (v_id_automotor, 0, v_id_automotor, x$persona, v_cedula, v_nombre,
		                          		v_fecha_ingreso, v_fecha_egreso, v_tipo_automotor, v_cantidad, v_modelo, v_ano_registro,
	                                 v_monto, x$sime, v_id_carga_archivo, contador, sysdate, observaciones);
            if x$persona is not null then
              begin
                update persona set TIPO=v_tipo_automotor, cantidad=v_cantidad, modelo=v_modelo, ano_registro=v_ano_registro,
                                  monto=v_monto,	NUMERO_SIME_automotor=x$sime, FECHA_INGRESO=v_fecha_ingreso , FECHA_EGRESO=v_fecha_egreso
                Where id=x$persona;
              EXCEPTION
              when others then
                v_cant_errores:=v_cant_errores+1;
                err_msg := SUBSTR(SQLERRM, 1, 200);
                x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar los datos de automotor de la persona cedula:' || v_cedula || ', nombres:' || v_nombre || ', linea:' || contador || ', mensaje:' || err_msg);
              end;
            end if;
          else
            Update  automotor set fecha_ingreso=v_fecha_ingreso, fecha_egreso=v_fecha_egreso, tipo=v_tipo_automotor, cantidad=v_cantidad, 
                                  modelo=v_modelo, ano_registro=v_ano_registro, monto=v_monto, numero_sime=x$sime, archivo=v_id_carga_archivo, 
                                  linea=contador, fecha_transicion=sysdate, observaciones=observaciones, persona=x$persona, cedula=v_cedula, nombre=v_nombre
            Where id=v_id_automotor;
          end if;
        EXCEPTION
        When others then
          v_id_automotor:=null;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 300);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de automotor, cedula:' || v_cedula || ', nombres:' || v_nombre || ', n�mero de l�nea:' || contador || ', mensaje:' || err_msg);
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
