create or replace function carga_archivo$hist_solicitud(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, observaciones nvarchar2)
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
  x$nombres	                    varchar2(200);
  x$apodo		                    varchar2(200);
  x$edad								        varchar2(3);
  x$fecha_nacimiento				    varchar2(10);
	x$nro_cedula                  varchar2(10);
	x$telefono							      varchar2(20);
	x$direccion							      varchar2(200);
  x$referencia_casa					    varchar2(200);
  x$barrio								      varchar2(200);
  x$nomb_referente				    	varchar2(200);
  x$fecha_entrevista				    varchar2(10):=null;
  x$nro_sime							      varchar2(10);
  x$distrito							      varchar2(200):=null;
	x$departamento						    varchar2(200):=null;
  x$reg									        number;
  v$log rastro_proceso_temporal%ROWTYPE;
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
      begin
        if v_id_carga_archivo is null then
          v_id_carga_archivo:=busca_clave_id;
          INSERT INTO CARGA_ARCHIVO (ID, VERSION, CODIGO, CLASE, ARCHIVO, ADJUNTO,
         	                           NUMERO_SIME, FECHA_HORA, ARCHIVO_SIN_ERRORES, PROCESO_SIN_ERRORES, OBSERVACIONES)
          VALUES (v_id_carga_archivo, 0, v_id_carga_archivo, x$clase_archivo, x$archivo, id_archivo_adjunto,
								x$sime, sysdate, null, 'false', observaciones);
        else
          Update carga_archivo set OBSERVACIONES=observaciones, NUMERO_SIME=x$sime Where id=v_id_carga_archivo;
        End if;
      exception
      when others then
        raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
      End;
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
					x$departamento:=trim(substr(valor_columna,1,200));
				When 1 Then
					x$distrito:=trim(substr(valor_columna,1,200));
				When 2 Then
					x$nro_cedula:=trim(substr(valor_columna,1,10));
        When 3 Then
					x$nombres:=trim(substr(valor_columna,1,100));
				When 4 Then
					x$nombres:=x$nombres || ' ' || trim(substr(valor_columna,1,100));
        When 5 Then
					x$apodo:=trim(substr(valor_columna,1,200));
				When 6 Then
					x$edad:=trim(substr(valor_columna,1,3));
        When 7 Then
          x$fecha_nacimiento:=extraerddmmyyyy(valor_columna, 'fecha de nacimiento', v_id_linea_archivo, 'true');
				When 8 Then
					x$direccion:=trim(substr(valor_columna,1,200));
				When 9 Then
					x$telefono:=trim(substr(valor_columna,1,20));
				When 10 Then
					x$referencia_casa:=trim(substr(valor_columna,1,200));
				When 11 Then
					x$barrio:=trim(substr(valor_columna,1,200));
				When 12 Then
					x$nomb_referente:=trim(substr(valor_columna,1,200));
				When 13 Then
					x$nro_sime:=trim(substr(valor_columna,1,10));
        else
          null;
        end case;
      End loop; --For i in 0 .. cant_registro LOOP
      begin
				x$reg:=busca_clave_id;
				insert into historico_solicitud (ID, VERSION, CODIGO,	NOMBRES, APODO, EDAD, FECHA_NACIMIENTO, NRO_CEDULA,
															TELEFONO, DIRECCION, REFERENCIA_CASA, BARRIO, NOMB_REFERENTE, TELEFONO_REFERENTE,
															FECHA_ENTREVISTA, SIME, DISTRITO, DEPARTAMENTO)
						values (x$reg, 0, x$reg, x$nombres, x$apodo, x$edad, x$fecha_nacimiento, x$nro_cedula,
	               		x$telefono, x$direccion, x$referencia_casa, x$barrio, x$nomb_referente, x$telefono,
                    x$fecha_entrevista, x$nro_sime, x$distrito, x$departamento);
			EXCEPTION
			when others then
				err_msg := SUBSTR(SQLERRM, 1, 300);
		  	v_cant_errores:=v_cant_errores+1;
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de  historico solicitudes, cedula:' || x$nro_cedula || ', nombres:' || x$nombres || ', mensaje:' || err_msg);
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
