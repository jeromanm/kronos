create or replace function carga_archivo$nacimiento(x$archivo varchar2, x$clase_archivo varchar2, x$sime number, observaciones nvarchar2)
  return number is
	err_num                       number;
	err_msg                       VARCHAR2(2000);
	v_cant_errores					  	  integer:=0;
	aux                           VARCHAR2(4000);
	v_id_carga_archivo            number;
	v_id_linea_archivo            number;
	cant_registro                 integer :=0;
	archivo_adjunto					      varchar2(255);
	id_archivo_adjunto				    number;
	valor_columna                 varchar2(1000);
	contador                      integer :=1;
	contador_t                    integer :=1;
	contadoraux							      integer :=1;
	i                             integer :=-1;
	auxi                          integer;
	v_cedula_nacido               varchar2(20);
	v_nombre_nacido               varchar2(100);
	v_fecha_nacimiento				    date;
	v_cedula_madre                varchar2(20);
	v_nombre_madre                varchar2(100);
  v_cedula_padre                varchar2(20);
  v_nombre_padre                varchar2(100);
	v_departamento 					      varchar2(10);
	v_distrito						  	    varchar2(10);
	v_id_departamento 				    number;
	v_id_distrito					  	    number;
	v_id_nacido                   number;
  v_id_madre						  	    number;
	v_id_padre                    number;
	v_id_nacimiento					      number;
	x$folio_nacimiento				    varchar2(10);
	x$acta_nacimiento				  	  varchar2(10);
	x$tomo_nacimiento				  	  varchar2(20);
	x$reg								  	      number;
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
      begin
        if v_id_carga_archivo is null then
          v_id_carga_archivo:=busca_clave_id;
          INSERT INTO CARGA_ARCHIVO (ID, VERSION, CODIGO, CLASE, ARCHIVO, ADJUNTO,
                                      NUMERO_SIME, FECHA_HORA, ARCHIVO_SIN_ERRORES, PROCESO_SIN_ERRORES, OBSERVACIONES)
					VALUES (v_id_carga_archivo, 0, v_id_carga_archivo, x$clase_archivo, x$archivo, id_archivo_adjunto,
								x$sime, sysdate,null, 'false', observaciones);
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
          v_cedula_nacido:=trim(substr(valor_columna,1,20));
        When 1 Then
          v_nombre_nacido:=trim(substr(valor_columna,1,50));
        When 2 Then
          v_nombre_nacido:=v_nombre_nacido || ' ' || trim(substr(valor_columna,1,50));
        When 3 Then
				  v_fecha_nacimiento:=extraerddmmyyyy(valor_columna, 'fecha nacimiento', v_id_linea_archivo, 'true');
				When 4 Then
          BEGIN
            Select trim(to_char(substr(valor_columna,1,2),'00')) into v_departamento from dual;
						Select id into v_id_departamento From departamento Where codigo=trim(v_departamento);
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_departamento:=99;
						v_cant_errores:=v_cant_errores+1;
  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Departamento no encontrado:' || v_departamento);
          when others then
            v_id_departamento:=99;
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
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Distrito no encontrado:' || v_distrito);
          when others then
            v_id_distrito:=99;
					END;
          if v_id_distrito=99 And v_id_departamento <>99 then
            v_id_departamento:=99;
          end if;
        When 6 Then
          v_cedula_madre:=trim(substr(valor_columna,1,20));
        When 7 Then
          v_nombre_madre:=trim(substr(valor_columna,1,50));
        When 8 Then
          v_nombre_madre:=v_nombre_madre || ' ' || trim(substr(valor_columna,1,50));
        When 9 Then
          v_cedula_padre:=trim(substr(valor_columna,1,10));
        When 10 Then
          v_nombre_padre:=trim(substr(valor_columna,1,50));
        When 11 Then
          v_nombre_padre:=v_nombre_padre || ' ' || trim(substr(valor_columna,1,50));
        When 12 Then
          x$folio_nacimiento:=trim(substr(valor_columna,1,10));
        When 13 Then
          x$acta_nacimiento:=trim(substr(valor_columna,1,10));
        When 14 Then
          x$tomo_nacimiento:=trim(substr(valor_columna,1,20));
        else
         	null;
        end case;
			End loop;
			Begin
				Select id into v_id_nacido From persona where codigo=v_cedula_nacido;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
        v_id_nacido:=null;
			when others then
        v_id_nacido:=null;
				v_cant_errores:=v_cant_errores+1;
				err_msg := SUBSTR(SQLERRM, 1, 200);
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar la cédula del nacido:' || v_cedula_nacido || ', mensaje:' || err_msg);
			End;
      Begin
          Select id into v_id_madre From persona where codigo=v_cedula_madre;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_id_madre:=null;
      when others then
      	v_id_madre:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Error al intentar buscar la cédula de la madre:' || v_cedula_madre || ', mensaje:' || err_msg);
      End;
      Begin
          Select id into v_id_padre From persona where codigo=v_cedula_padre;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_id_padre:=null; v_id_padre:=null;
      when others then
        v_id_padre:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar buscar la cédula de la padre:' || v_cedula_padre || ', mensaje:' || err_msg);
      End;
      begin
      if v_fecha_nacimiento is null then
        Select id into v_id_nacimiento
	      From nacimiento
	      Where (cedula=v_cedula_nacido or cedula_madre=v_cedula_madre or cedula_padre=v_cedula_padre)  And fecha_nacimientos is null
          And rownum=1; --buscamos registros anteriores de registro nacimiento con la misma fecha, para no repetir objeciones
      else
        Select id into v_id_nacimiento
        From nacimiento
	      Where (cedula=v_cedula_nacido or cedula_madre=v_cedula_madre or cedula_padre=v_cedula_padre)  And fecha_nacimientos =v_fecha_nacimiento
        	And rownum=1; --buscamos registros anteriores de registro nacimiento con la misma fecha, para no repetir objeciones
      end if;
      Exception
      WHEN NO_DATA_FOUND THEN
        v_id_nacimiento:=NULL;
      when others then
        v_id_nacimiento:=NULL;
				err_msg := SUBSTR(SQLERRM, 1, 200);
				v_cant_errores:=v_cant_errores+1;
				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener un registro anterior de registro de nacimiento para la cédula madre:' || v_cedula_madre || ', mensaje:' || err_msg);
      End;
      Begin
        if v_id_nacimiento is null then
          v_id_nacimiento:=busca_clave_id;
					Insert into nacimiento (id, version, codigo, persona, cedula, nombre, personamadre, cedula_madre, nombre_madre, personapadre, cedula_padre, nombre_padre,
                                  fecha_nacimientos, departamento_nacimiento, distrito_nacimiento, folio_nacimiento,
                                  acta_nacimiento, tomo_nacimiento, archivo, linea, fecha_transicion, numero_sime, observaciones)
          Values (v_id_nacimiento, 0, v_id_nacimiento, v_id_nacido, v_cedula_nacido, v_nombre_nacido, v_id_madre, v_cedula_madre, v_nombre_madre, v_id_padre, v_cedula_padre, v_nombre_padre, 
                  v_fecha_nacimiento, v_id_departamento, v_id_distrito, x$folio_nacimiento,
                  x$acta_nacimiento, x$tomo_nacimiento, v_id_carga_archivo, contador, sysdate, x$sime, observaciones);
          begin
            if v_id_nacido is not null then
              Update persona set fecha_nacimientos=v_fecha_nacimiento, departamento_nacimiento=v_id_departamento, 
                                  distrito_nacimiento=v_id_distrito, nombre_madre=v_nombre_madre, cedula_madre=v_cedula_madre, nombre_padre=v_nombre_padre,
                                  cedula_padre=v_cedula_padre, folio_nacimiento=x$folio_nacimiento, acta_nacimiento=x$acta_nacimiento,
                                  tomo_nacimiento=x$tomo_nacimiento, numero_sime_nacimiento=x$sime
              Where id=v_id_nacido;
            end if;
            if v_id_madre is not null then
              Update persona set numero_sime_nacimiento=x$sime Where id=v_id_madre;
            end if;
            if v_id_padre is not null then
              Update persona set numero_sime_nacimiento=x$sime Where id=v_id_padre;
            end if;
          EXCEPTION
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar actualizar los datos de la persona, mensaje:' || err_msg);
          End;
        else
            Update nacimiento set persona=v_id_nacido, nombre=v_nombre_nacido, fecha_nacimientos=v_fecha_nacimiento, departamento_nacimiento=v_id_departamento, distrito_nacimiento=v_id_distrito, 
                                  personamadre=v_id_madre, cedula_madre=v_cedula_madre, nombre_madre=v_nombre_madre, 
                                  personapadre=v_id_padre, cedula_padre=v_cedula_padre, nombre_padre=v_nombre_padre, 
                                  folio_nacimiento=x$folio_nacimiento, acta_nacimiento=x$acta_nacimiento, tomo_nacimiento=x$tomo_nacimiento, archivo=v_id_carga_archivo, 
                                  linea=contador, fecha_transicion=sysdate, numero_sime=x$sime, observaciones=observaciones
            Where id=v_id_nacimiento;
        END IF; 
      EXCEPTION
      when others then
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 300);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar crear el registro de nacimiento, cedula madre:' || v_cedula_madre || ', número de línea:' || contador || ', mensaje:' || err_msg);
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
    raise_application_error(err_num, err_msg, true);
end;
/
