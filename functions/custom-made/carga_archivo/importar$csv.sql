create or replace function importar$csv(x$archivo varchar2, x$id_clase_archivo number, x$numero_sime nvarchar2, x$observaciones nvarchar2) return number is
	err_msg				VARCHAR2(2000);
	contador			INTEGER:=0;
	v$tipo_archivo		number;
	v_file				UTL_FILE.FILE_TYPE;
	v_line				VARCHAR2(4000);
	v$big				number:=0;
	v$archivo_cliente   VARCHAR2(200);
	v$archivo			VARCHAR2(200);
BEGIN --modificado SIAU 11885
  begin --buscamos cargas anteriores procesadas con errores con el mismo nombre, debe comenzar donde quedó
    Select tipo into v$tipo_archivo from clase_archivo where id =x$id_clase_archivo;
    Select tm.archivo into v$archivo
    From ARCHIVO_ADJUNTO aa inner join ARCHIVO_ADJUNTO aa2 on aa.archivo_cliente = aa2.archivo_cliente 
      inner join carga_archivo ca on upper(aa2.ARCHIVO_SERVIDOR)=upper(ca.archivo)
      inner join CSV_IMP_TEMP tm on upper(ca.archivo)=upper(tm.archivo)
    Where upper(aa.archivo_servidor)=upper(x$archivo) And ca.proceso_sin_errores='false'
      And rownum=1;
  exception
  WHEN NO_DATA_FOUND THEN
    v$archivo:=null;
  when others then
    err_msg:=substr(sqlerrm,1,2000);
    raise_application_error(-20001, 'Error al intentar obtener una carga anterior, mensaje:' || err_msg, true);
  end;
  if v$archivo is null then
    v$archivo:=x$archivo;
    begin
        Delete CSV_IMP_TEMP  --borramos posibles cargas anteriores procesadas sin errores con el mismo nombre
        Where upper(archivo) in (Select upper(ca.archivo)
                                From ARCHIVO_ADJUNTO aa inner join ARCHIVO_ADJUNTO aa2 on aa.archivo_cliente = aa2.archivo_cliente 
                                  inner join carga_archivo ca on upper(aa2.ARCHIVO_SERVIDOR)=upper(ca.archivo)
                                Where upper(aa.archivo_servidor)=upper(v$archivo) And ca.proceso_sin_errores='true') ;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      err_msg:=substr(sqlerrm,1,2000);
      raise_application_error(-20001, 'Error al intentar borrar temporal de carga de archivo, mensaje:' || err_msg, true);
    end;
    begin
			if (v$tipo_archivo=1 or v$tipo_archivo=2 or v$tipo_archivo=3 or v$tipo_archivo=4 or v$tipo_archivo=5 or v$tipo_archivo=6 or v$tipo_archivo=9
         		or v$tipo_archivo=10 or v$tipo_archivo=11 or v$tipo_archivo=12 or v$tipo_archivo=13 or v$tipo_archivo=15
            or v$tipo_archivo=28 or v$tipo_archivo=29) And  x$numero_sime is null then
        raise_application_error(-20002, 'Error: para el tipo de archivo seleccionado, el Nro se SIME, es obligatorio.', true);
			end if;
      v_file   := UTL_FILE.FOPEN('DIR_IMPORTAR',v$archivo,'R',32767);
			contador:=0;
		exception
			when utl_file.INVALID_OPERATION THEN
				raise_application_error(-20001, 'File could not be opened or operated on as requested.', true);
			when utl_file.READ_ERROR THEN
				raise_application_error(-20001, 'Destination buffer too small, or operating system error occurred during the read operation.', true);
			when utl_file.WRITE_ERROR THEN
				raise_application_error(-20001, 'Operating system error occurred during the write operation.', true);
			when utl_file.INTERNAL_ERROR THEN
				raise_application_error(-20001, 'Unspecified PL/SQL error.', true);
			when utl_file.CHARSETMISMATCH THEN
				raise_application_error(-20001, 'A file is opened using FOPEN_NCHAR, but later I/O operations use nonchar functions such as PUTF or GET_LINE.', true);
			when utl_file.FILE_OPEN THEN
				raise_application_error(-20001, 'The requested operation failed because the file is open.', true);
      when utl_file.INVALID_MAXLINESIZE THEN
				raise_application_error(-20001, 'The MAX_LINESIZE value for FOPEN() is invalid; it should be within the range 1 to 32767.', true);
      when utl_file.INVALID_FILENAME THEN
				raise_application_error(-20001, 'The filename parameter is invalid.', true);
      when utl_file.ACCESS_DENIED THEN
				raise_application_error(-20001,'Permission to access to the file location is denied.', true);
      when utl_file.INVALID_OFFSET THEN
        raise_application_error(-20001, 'Causes of the INVALID_OFFSET .', true);
			WHEN OTHERS THEN
				raise_application_error(-20010, 'Others Error -' ||SQLCODE||' - ERROR - '|| sqlerrm ,true);
		end;
		LOOP  -- Lee el Registro
			BEGIN
				UTL_FILE.GET_LINE(v_file, v_line,4000);
			EXCEPTION
				when utl_file.invalid_path then
					raise_application_error(-20000,'DUMMY.DK_EXR_CSV_LOAD_INVALID_PATH',true);
				when utl_file.internal_error then
					raise_application_error(-20001,'internal_error',true);
				when utl_file.read_error then
					raise_application_error(-20002,'DUMMY.DK_EXR_CSV_LOAD_READ_ERROR',true);
				when utl_file.invalid_filehandle then
					raise_application_error(-20003,'invalid_filehandle)',true);
				when utl_file.invalid_operation then
					raise_application_error(-20004,'invalid_operation)',true);
				WHEN NO_DATA_FOUND THEN
          exit;
			END;
			if trim(v_line) is not null then
				if contador > 0 or v$tipo_archivo=7 or v$tipo_archivo=23 or v$tipo_archivo=24 or v$tipo_archivo=25 or v$tipo_archivo=26
            or v$tipo_archivo=31 or v$tipo_archivo=32 then --no leer la cabecera del archivo, archivo censo historico necesita la cabcecera
					INSERT INTO CSV_IMP_TEMP (ITEM, REGISTRO, ARCHIVO, tipo_archivo, FECHA_PROCESO)
          VALUES (contador, v_line, v$archivo, v$tipo_archivo, sysdate);
				end if;
        contador:=contador + 1;
			end if;
		END LOOP;
    UTL_FILE.FCLOSE(v_file);
  end if; --if v$archivo is null then
  case v$tipo_archivo
    when 1 Then
      v$big :=carga_archivo$solicitudes(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 2 Then
      v$big :=carga_archivo$defunciones(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 3 Then
      v$big :=carga_archivo$matrimonio(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 4 Then
      v$big :=carga_archivo$empleo(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 5 Then
      v$big :=carga_archivo$jubilacion(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 6 Then  -- Senacsa
      v$big :=carga_archivo$senacsa(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 7 Then --historico de censos
      v$big :=carga_archivo$historicocenso(v$archivo, x$id_clase_archivo, x$observaciones);
    when 8 Then
      v$big :=carga_archivo$monitoreo(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 9 Then
      v$big :=carga_archivo$estado_cuenta(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 10 Then
      v$big :=carga_archivo$castastro(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 11 Then
      v$big :=carga_archivo$cotizante(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 12 Then
      v$big :=carga_archivo$proveedor(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 13 Then
      v$big :=carga_archivo$nacimiento(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 14 Then
      v$big :=carga_archivo$campo(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 15 Then
      v$big :=carga_archivo$automotor(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 16 Then
      v$big :=carga_archivo$foto_persona$biz(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones); --fotos
    when 17 Then --historico de personas y pensiones SPAAM
      v$big :=carga_archivo$historicopension(v$archivo, x$id_clase_archivo, x$observaciones);
    when 18 Then --historico de personas y pensiones JUPE
      v$big :=carga_archivo$historicojupe(v$archivo, x$id_clase_archivo, x$observaciones);
    when 19 Then --historico movimiento JUPE
      null;
    when 20 Then
      v$big :=carga_archivo$reclamo(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 21 Then --fotos hogar
      null;
    when 22 Then
      v$big :=carga_archivo$tramite(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 23 Then
      v$big :=carga_archivo$censostpcar(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 24 Then
      v$big :=carga_archivo$censostpviv(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 25 Then
      v$big :=carga_archivo$censostpper(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 26 Then
      v$big :=carga_archivo$censostpagr(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 27 Then
      v$big :=carga_archivo$no_indigena(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 28 Then
      v$big :=carga_archivo$extranjero(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 29 Then
      v$big :=carga_archivo$subsidio(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 31 Then
      v$big :=carga_archivo$censoxlotev(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 32 Then
      v$big :=carga_archivo$censoxlotep(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    when 33 Then
      v$big :=carga_archivo$hist_solicitud(v$archivo, x$id_clase_archivo, x$numero_sime, x$observaciones);
    else
      null;
  end case ;
  RETURN v$big;
exception
when others then
  err_msg := substr(SQLERRM,20000);
  raise_application_error(-20000, 'Error en cargar temporal, mensaje:' || err_msg , true);
END;
/