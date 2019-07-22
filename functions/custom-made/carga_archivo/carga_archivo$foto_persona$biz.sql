create or replace function carga_archivo$foto_persona$biz(x$archivo VARCHAR2, x$clase_archivo VARCHAR2, x$sime number, x$observaciones nvarchar2) return number is
  v$err                   constant number := -20000; -- an integer in the range -20000..-20999
  err_msg               	VARCHAR2(2000);
  v_id_carga_archivo    	number;
  v_id_linea_archivo    	number;
  v_cant_errores				  number;
  archivo             		varchar2(255);
  v$id_archivo_adjunto		 number;
  v$id_archivo_adjuntofoto number;
  archivo_adjunto				  varchar2(255);
  contador            		integer :=1;
  contadoraux						  integer :=1;
  contador_t						  integer :=0;
  vnombre_archivo			    varchar2(400);
  v$nombre_usuario		    varchar2(100);
  v_linea                 varchar2(400);
  v$cedula						    varchar2(20);
  vid$ficha_hogar 		    varchar2(20);
  vcodigo$ficha_hogar     varchar2(20);
  v$persona					      number;
  vid$ficha_persona 		  number;
  v$id_documento				  number;
  x$reg                   number;
  v$log                   rastro_proceso_temporal%ROWTYPE;
  v_version_ficha_hogar 	varchar2(20);
  v$directorio            varchar2(255):='/spnc2ap112/attachments/carga_archivo/';
  v$censista              varchar2(2);
  v$fecha_entrevista      varchar2(10);
  v$barrio                varchar2(7);
  v$formulario            varchar2(2);
  v$auxseccion            integer:=0;
begin
	v$log := rastro_proceso_temporal$select();
  Begin
    Select valor Into v_version_ficha_hogar From variable_global where numero=103;
    --Select directory_path into v$directorio from all_directories where directory_name='SPNC2AP112_ATTACHMENTS';
    Select nombre_usuario into v$nombre_usuario From usuario where codigo_usuario=CURRENT_USER_CODE;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
  End;
  For reg in (Select registro, substr(registro,instr(registro,'/',-1,1)+1) as nombre_archivo, extraerNumero(substr(registro,instr(registro,'/',-1,1)+1)) as numero
              From CSV_IMP_TEMP 
              Where archivo=x$archivo And instr(registro,'.jpg')>0 
                And length(registro)<=255
              Order by 1) loop
    v_linea:=null; v_cant_errores:=0; v$auxseccion:=1;
		if contador=contadoraux then --encabezado del archivo
			Begin
				Select aa.ARCHIVO_CLIENTE, aa.id
          into archivo_adjunto, v$id_archivo_adjunto
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
					VALUES (v_id_carga_archivo, 0, v_id_carga_archivo, x$clase_archivo, x$archivo, v$id_archivo_adjunto,
                  x$sime, sysdate,null, 'false', x$observaciones);
        exception
				when others then
					raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
				End;
      else
        Update carga_archivo set OBSERVACIONES=x$observaciones Where id=v_id_carga_archivo;
			End if;
      Begin
				v_id_linea_archivo:=busca_clave_id;
				INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
        VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, substr(reg.registro,1,2000), '');
      exception
      when others then
				raise_application_error(-20001,'Error al intentar insertar la linea (' || contador || ') del archivo, mensaje:'|| sqlerrm, true);
      End;
      v_linea:=reg.registro; 
		elsif contador>contadoraux then --valores del archivo
			Begin
				v_id_linea_archivo:=busca_clave_id;
				INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
        VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, substr(reg.registro,1,2000), '');
      exception
      when others then
				raise_application_error(-20001,'Error al intentar insertar la linea (' || contador || ') del archivo, mensaje:'|| sqlerrm, true);
      End;
      v_linea:=reg.registro;
    End if; --else if contador=0 then
    v$persona:=null; vid$ficha_persona:=null; v$auxseccion:=2;
    if v_linea is not null then
      vnombre_archivo:=REPLACE(v$directorio || v$id_archivo_adjunto || '/' || v_linea, chr(13), '');
      begin
        v$id_archivo_adjuntofoto:=busca_clave_id;
        Insert Into archivo_adjunto (ID, ARCHIVO_SERVIDOR, ARCHIVO_CLIENTE, PROPIETARIO, CODIGO_USUARIO_PROPIETARIO, NOMBRE_USUARIO_PROPIETARIO,
                                    FECHA_HORA_CARGA, TIPO_CONTENIDO, LONGITUD, OCTETOS, RESTAURABLE)
        values (v$id_archivo_adjuntofoto,vnombre_archivo, reg.registro,CURRENT_USER_ID,CURRENT_USER_CODE,v$nombre_usuario, 
                sysdate, 'image/png', 1, null, 'true');
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v$persona:=null;
        v_cant_errores:=v_cant_errores+1;
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Persona no encontrada, cédula:' || v$cedula || ', nombre archivo:' || reg.registro || ', número item:' || contador || ', valor evaluado:' || v_linea);
      when others then
        v$persona:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar buscar la persona, nombre archivo:' || reg.registro || ', número item:' || contador || ', mensaje:' || err_msg);
      end;
      begin
        if length(reg.numero)<=7 then 
          v$cedula:=reg.numero; vcodigo$ficha_hogar:=null;
          v$censista:=null; v$fecha_entrevista:=null;
          v$barrio:=null; v$formulario:=null;
        else
          v$cedula:=null; 
          if instr(reg.nombre_archivo,'_')>0 then --hogar formato DPNC censista (2 digitos) + año (4 digitos) + mes (2 digitos) + dia (2 digitos) + cod_dpto+cod_distrito+cod_barrio (7 digitos) + "_" + num_formulario (1 o 2 digitos, no contempla 0 a la izquierda)
            vcodigo$ficha_hogar:=reg.numero;
            v$censista:=substr(reg.numero,1,2); 
            v$fecha_entrevista:=substr(reg.numero,3,8);
            v$barrio:=substr(reg.numero,11,7);
            v$formulario:=substr(reg.nombre_archivo,18,instr(reg.nombre_archivo,'_')-18);
          else --formato STP
            vcodigo$ficha_hogar:=to_number(reg.numero);
            v$censista:=null; v$fecha_entrevista:=null;
            v$barrio:=null; v$formulario:=null;
          end if;
        end if;
      EXCEPTION
      when others then
        vcodigo$ficha_hogar:=null; v$cedula:=null;
        v$censista:=null; v$fecha_entrevista:=null;
        v$barrio:=null; v$formulario:=null;
        v_cant_errores:=v_cant_errores+1;
        err_msg := SUBSTR(SQLERRM, 1, 200);
        x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar obtener los codigos de persona y/u hogar, valor intentado:' || reg.numero || ', número item:' || contador || ', mensaje:' || err_msg);
      end;
      v$auxseccion:=3;
      if v$cedula is not null then
        begin
          Select id into vid$ficha_persona 
          From (Select fp.id, cp.fecha, cp.fecha_transicion, cp.estado 
                From ficha_persona fp inner join censo_persona cp on fp.id = cp.ficha 
                Where cp.estado=4 And fp.numero_cedula=v$cedula
                Order by cp.fecha desc, cp.fecha_transicion desc) 
          Where rownum=1;
          EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vid$ficha_persona:=null;
          v_cant_errores:=v_cant_errores+1;
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Ficha persona no encontrada, cédula:' || v$cedula || ', nombre archivo:' || reg.registro || ', número item:' || contador || ', valor evaluado:' || v_linea);
        when others then
          vid$ficha_persona:=null;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar buscar la ficha persona, nombre archivo:' || reg.registro || ', número item:' || contador || ', mensaje:' || err_msg);
        end;
        if vid$ficha_persona is null then
          Begin
            Select id into v$persona From persona Where codigo=v$cedula;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v$persona:=null;
            v_cant_errores:=v_cant_errores+1;
          when others then
            v$persona:=null;
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar buscar la persona, nombre archivo:' || reg.registro || ', número item:' || contador || ', mensaje:' || err_msg);
          end;
        end if;
      end if;
      v$auxseccion:=4;
      if vcodigo$ficha_hogar is not null then
        Begin
          if v$censista is null then
            Select id into vid$ficha_hogar From ficha_hogar Where id=vcodigo$ficha_hogar;
          else
            Select fh.id into vid$ficha_hogar
            From ficha_hogar fh inner join censista ce on fh.censista_externo = ce.id
              inner join barrio ba on fh.barrio = ba.id
            Where ce.codigo=v$censista And to_char(fh.fecha_entrevista,'yyyymmdd')=v$fecha_entrevista
            And ba.codigo=v$barrio And fh.numero_formulario=v$formulario 
            And rownum=1 And fh.estado<>5;
          end if;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vid$ficha_hogar:=null;
          v_cant_errores:=v_cant_errores+1;
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Ficha hogar no encontrada, censista:' || v$censista || ', fecha:' || v$fecha_entrevista || ', barrio:' || v$barrio || ', formulario:' || v$formulario || ', línea:' || contador);
        when others then
          vid$ficha_hogar:=null;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar buscar la ficha hogar, codigo:' || vcodigo$ficha_hogar || ', número item:' || contador || ', mensaje:' || err_msg);
        end;
      end if;
      v$auxseccion:=5;
      if vid$ficha_persona is not null then
        begin
          Select id into v$id_documento From documento where archivo=vnombre_archivo;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v$id_documento:=null;
        when others then
          v$id_documento:=null;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar obtener el id existente de una carga de documento anterior, nombre archivo:' || reg.registro || ', número item:' || contador || ', mensaje:' || err_msg);
        end;
        if v$id_documento is null then
          Begin
            v$id_documento:=busca_clave_id;
            Insert Into documento (id, version, tipo, codigo, descripcion, archivo, adjunto, numero_sime, 
                                  estado, ficha_x11, ultima_carga, usuario_transicion)
                          values (v$id_documento,0, 11, v$id_documento, 'Carga Foto en lote, ' || x$observaciones, vnombre_archivo, v$id_archivo_adjuntofoto, x$sime, 
                                  3, vid$ficha_persona, sysdate, CURRENT_USER_ID);
          exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar insertar el registro del documento, cédula:' || v$cedula || ', nombre archivo ' || reg.registro || ', mensaje:' || err_msg);
          End;
        end if;
      end if; --if vid$ficha_persona is not null then
      v$auxseccion:=6;
      if v$persona is not null then
        begin
          Select id into v$id_documento From documento where archivo=vnombre_archivo;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v$id_documento:=null;
        when others then
          v$id_documento:=null;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar obtener el id existente de una carga de documento anterior, nombre archivo:' || reg.registro || ', número item:' || contador || ', mensaje:' || err_msg);
        end;
        if v$id_documento is null then
          Begin
            v$id_documento:=busca_clave_id;
            Insert Into documento (id, version, tipo, codigo, descripcion, archivo, adjunto, numero_sime, 
                                  estado, persona_x1, ultima_carga, usuario_transicion)
                          values (v$id_documento,0, 1, v$id_documento, 'Carga Foto en lote, ' || x$observaciones, vnombre_archivo, v$id_archivo_adjuntofoto, x$sime, 
                                  3, v$persona, sysdate, CURRENT_USER_ID);
          exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar insertar el registro del documento, cédula:' || v$cedula || ', número item:' || contador || ', mensaje:' || err_msg);
          End;
        end if;
      end if; --if v$persona is not null then
      v$auxseccion:=7;
      if vid$ficha_hogar is not null then
        begin
          Select id into v$id_documento From documento where archivo=vnombre_archivo;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          v$id_documento:=null;
        when others then
          v$id_documento:=null;
          v_cant_errores:=v_cant_errores+1;
          err_msg := SUBSTR(SQLERRM, 1, 200);
          x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Error al intentar obtener el id existente de una carga de documento anterior, nombre archivo:' || reg.registro || ', número item:' || contador || ', mensaje:' || err_msg);
        end;
        if v$id_documento is null then
          Begin
            v$id_documento:=busca_clave_id;
            Insert Into documento (id, version, tipo, codigo, descripcion, archivo, adjunto, numero_sime, 
                                  estado, FICHA_X10, ultima_carga, usuario_transicion)
                          values (v$id_documento,0, 10, v$id_documento, 'Carga Foto en lote, ' || x$observaciones, vnombre_archivo, v$id_archivo_adjuntofoto, x$sime, 
                                  3, vid$ficha_hogar, sysdate, CURRENT_USER_ID);
          exception
          when others then
            v_cant_errores:=v_cant_errores+1;
            err_msg := SUBSTR(SQLERRM, 1, 200);
            x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar insertar el registro del documento, cédula:' || v$cedula || ', número item:' || contador || ', mensaje:' || err_msg);
          End;
        end if;
      end if; --if vid$ficha_hogar is not null then
      v$auxseccion:=8;
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
    end if; --if v_linea is not null then
    --x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Item Procesado:' || contador || ', nombre archivo:' || reg.registro || ', numero:' || reg.numero);
    contador:=contador+1;
  end loop;
  v$auxseccion:=99;
	Update CARGA_ARCHIVO set PROCESO_SIN_ERRORES='true', directorio=contador Where id=v_id_carga_archivo;
  Select Count(a.id) into v_cant_errores
  From LINEA_ARCHIVO a inner join ERROR_ARCHIVO b on a.id = b.linea
  Where a.CARGA=v_id_carga_archivo;
  if v_cant_errores>0 then
  	Update CARGA_ARCHIVO set ARCHIVO_SIN_ERRORES='false' Where id=v_id_carga_archivo;
  end if;
  commit work;
  rastro_proceso_temporal$revive(v$log);
  return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20000, err_msg || ', sección:' || v$auxseccion, true);
end;
/
