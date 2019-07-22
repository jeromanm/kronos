create or replace function carga_archivo$censostpagr(x$archivo VARCHAR2, x$clase_archivo VARCHAR2, x$sime number, observaciones nvarchar2) return number is
	err_msg					      VARCHAR2(2000);
	v$msg                 nvarchar2(2000);
	type namesarray IS TABLE OF VARCHAR2(500) INDEX BY PLS_INTEGER;
	encabezado            namesarray;
	campo                 namesarray;
	v_id_carga_archivo    number;
	v_id_linea_archivo    number;
	v_version_ficha		    varchar2(20);
	archivo             	varchar2(255);
	contador					    integer :=0;
	contador_t            integer :=0;
	contadoraux				    integer :=0;
  archivo_adjunto		    varchar2(255);
	id_archivo_adjunto	  number;
	i                   	integer :=0;
	cant_registro       	integer :=0;
  cant_registroenc		  integer :=0;
	aux                 	VARCHAR2(4000);
  v_id_fichahogar		    varchar2(20);
  v_tipo_dato_respuesta number;
	cant_sqlhogar		      integer :=0;
  v_strsqlhogar		      VARCHAR2(500);
  X$COMENTARIOS			    varchar2(200);
	v_cant_errores        integer;
  x$reg						      integer;
  v_pregunta				    varchar2(200);
  v_cedula					    varchar2(10);
  v_id_pregunta			    number;
  v_rango_respuesta		  number;
	v_id_respuesta			  number; 
  v_texto_respuesta		  varchar2(2000);
  v_numero_respuesta	  number;
  v_fecha_respuesta		  date;
  v_tipo_dato_resp		  number;
  v$log rastro_proceso_temporal%ROWTYPE;
  v$clase_archivo       varchar2(20);
begin --modificado SIAU 11885
	v$log := rastro_proceso_temporal$select();
  Select codigo into v$clase_archivo From clase_archivo where id=x$clase_archivo;
  if (v$clase_archivo='STP1C' or v$clase_archivo='STP1V' or v$clase_archivo='STP1P' or v$clase_archivo='STP1A') then
    v_version_ficha:='STP1/2016';
  elsif (v$clase_archivo='STP2C' or v$clase_archivo='STP2V' or v$clase_archivo='STP2P' or v$clase_archivo='STP2A') then
    v_version_ficha:='STP2/2016';
  else
    Begin
      Select valor Into v_version_ficha From variable_global where numero=103;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
    End;
  end if;
	For reg in (Select * From csv_imp_temp Where archivo=x$archivo order by 1) loop
		v_cant_errores:=0; cant_sqlhogar:=0; v_id_fichahogar:=null;
		if trim(reg.registro) is not null then
			aux:=replace(trim(substr(trim(reg.registro),1,4000)),chr(39), '');
			aux:=replace(aux,'"', '');
			aux:=replace(aux,chr(13), '');
			aux:=replace(aux,chr(10), '');
      aux:=replace(aux,'ï»¿', '');
   	else
			aux:=null;
		end if;
		if (aux is not null) then
			Select length(aux)-length(replace(aux,';','')) Into cant_registro From dual;  --cantidad de columnas
		else
			cant_registro:=0;
		end if;
		if contador=0 And aux is not null then --encabezado del archivo
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
								null, sysdate,null, 'false', observaciones);
        exception
				when others then
					raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
				End;
      else
        Update carga_archivo set OBSERVACIONES=observaciones Where id=v_id_carga_archivo;
			End if;
      cant_registroenc:=cant_registro;
			For i in 0 .. cant_registro LOOP
				if instr(aux,';')=0 then  --nombre de los campos
					encabezado(i):=aux;
				else
					encabezado(i):=substr(aux, 0, instr(aux,';')-1);
					aux:=substr(aux, instr(aux,';')+1);
				end if;
      End loop;
		elsif contador>contadoraux And aux is not null then --valores del archivo
			Begin
				v_id_linea_archivo:=busca_clave_id;
				INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
				VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, substr(reg.registro,1,2000), '');
			exception
      when others then
				raise_application_error(-20001,'Error al intentar insertar la linea (' || contador || ') del archivo, mensaje:'|| sqlerrm, true);
      End;
      For i in 0 .. cant_registroenc Loop
				if instr(aux,';')=0 then --csv separado por comas, si no hay mas comas se sale
					campo(i):=aux;
				else
					campo(i):=substr(aux, 0, instr(aux,';')-1);
					aux:=substr(aux, instr(aux,';')+1);
        end if;
				X$COMENTARIOS:='';
        case --identificación de variables segun su encabezado, fijas para ficha_hogar, persona y censo_persona; el resto se busca en preguntas
          When instr(trim(upper(encabezado(i))),'CLAVE')>0 Then
            v_id_fichahogar:=trim(substr(campo(i),1,19));
          When (instr(upper(encabezado(i)),'P36')>0) Then --Cedula
            v_cedula:=substr(campo(i),1,10);
          When upper(trim(encabezado(i)))='OBSERVACIONES' Then
            X$COMENTARIOS:=trim(substr(campo(i),1,198));
          Else --el resto de las variables con literales no fijos, se buscar en las pregutnas de persona
            null;
        end case;
        if v_id_fichahogar is not null then
        For reg2 in (Select a.* From pregunta_ficha_hogar a
                    Where version_ficha=v_version_ficha And upper(trim(codigo))=upper(trim(encabezado(i)))
                      And NOT EXISTS (Select b.id From respuesta_ficha_hogar b Where a.id = b.pregunta And b.ficha=v_id_fichahogar)
                    Order by a.codigo) Loop --carga de respuesta persona
          v_rango_respuesta:=null; 
          campo(i):=replace(campo(i),',',' ');
          if trim(campo(i))='' then 
            campo(i):='N/E';
          end if;
          v_strsqlhogar:='INSERT INTO RESPUESTA_ficha_hogar (ID, VERSION, FICHA, PREGUNTA';
          if reg2.tipo_dato_respuesta=1 Then --alfanumerico
            v_strsqlhogar:= v_strsqlhogar || ', TEXTO) VALUES (busca_clave_id, 0,' || v_id_fichahogar || ',' || reg2.id || ',' || chr(39) || campo(i) || chr(39) || ')';
          elsif reg2.tipo_dato_respuesta=2 And trim(campo(i)) is  not null Then --numerico
            v_strsqlhogar:= v_strsqlhogar || ', NUMERO)	VALUES (busca_clave_id, 0,' || v_id_fichahogar || ',' || reg2.id || ',to_number(' || chr(39) || campo(i) || chr(39) || '))';
          elsif reg2.tipo_dato_respuesta=3 And trim(campo(i)) is  not null Then --fecha
            v_strsqlhogar:= v_strsqlhogar || ', FECHA) VALUES (busca_clave_id, 0,' || v_id_fichahogar || ',' || reg2.id || ',' || chr(39) || campo(i) || chr(39) || ')';
          elsif reg2.tipo_dato_respuesta=4 And trim(campo(i)) is  not null then --discreto
            begin
              SELECT id into v_rango_respuesta From rango_ficha_hogar where pregunta=reg2.id And numeral= campo(i);
            EXCEPTION
						WHEN NO_DATA_FOUND THEN
              v_strsqlhogar:=null; v_rango_respuesta:=null;
            when others then
              v_strsqlhogar:=null; v_rango_respuesta:=null;
            END;
            if v_rango_respuesta is not null then
              v_strsqlhogar:= v_strsqlhogar || ', RANGO) VALUES (busca_clave_id, 0, ' || v_id_fichahogar || ',' || reg2.id || ',' || v_rango_respuesta || ')';
            end if;
          end if;
          if v_strsqlhogar is not null then
            Begin
              execute immediate v_strsqlhogar;
            Exception
            when others then
  						v_cant_errores:=v_cant_errores+1;
              err_msg := SUBSTR(SQLERRM, 1, 200);
              x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar insertar un registro de respuesta hogar, codigo pregunta:' || encabezado(i) || ', respuesta:' || campo(i) || ', linea:' || contador || ', mensaje '|| err_msg);
            end;
          end if;
        End Loop;
        end if;
			End Loop; --fin carga de valores de columnas For i in 1 .. cant_registro Loop
      Begin
        Update ficha_hogar set estado=4 where id=v_id_fichahogar;
      Exception
      when others then
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error intentar insertar actualizar el estado de la ficha hogar, mensaje '|| err_msg);
      end;
      if (v_cant_errores>0) Then
				Update LINEA_ARCHIVO set ERRORES=ERRORES+v_cant_errores Where id=v_id_linea_archivo;
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
  begin
		Delete From CSV_IMP_TEMP Where archivo=x$archivo;
		Update CARGA_ARCHIVO set PROCESO_SIN_ERRORES='true', directorio=contador Where id=v_id_carga_archivo;
		Select Count(a.id) into v_cant_errores
		From LINEA_ARCHIVO a inner join ERROR_ARCHIVO b on a.id = b.linea
		Where a.CARGA=v_id_carga_archivo;
		if v_cant_errores>0 then
			Update CARGA_ARCHIVO set ARCHIVO_SIN_ERRORES='false' Where id=v_id_carga_archivo;
		end if;
	exception
	when others then
		err_msg := SUBSTR(SQLERRM, 1, 200);
		x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar cerrar el proceso de carga, mensaje:' || err_msg);
	end;
  commit;
  rastro_proceso_temporal$revive(v$log);
  return 0;
exception
when others then
  err_msg := SQLERRM;
  raise_application_error(-20100, err_msg || ' en linea:' || contador, true);
end;
/
