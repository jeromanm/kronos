create or replace function extraerddmmyyyy(valor_columna varchar2, nombre_objeto varchar2, v_id_linea_archivo number, devuelve_nulo varchar) return date is
Begin
  Declare
  err_msg           VARCHAR2(2000);
  v_fecha           date:=null;
  v_dia						  integer;
  v_mes						  varchar2(10);
  v_ano						  varchar2(4);
  v_strfecha				varchar2(12);
Begin
  if length(trim(valor_columna))<6 or trim(valor_columna) is null Then
    if devuelve_nulo='true' then
      v_fecha:=null;
    else
      Select to_date('01/01/1900','dd/mm/yyyy') into v_fecha From dual;
    end if;
  else
    if instr(valor_columna,'-')>0 Then
      BEGIN
        v_dia:=substr(valor_columna,1,instr(valor_columna,'-')-1);
        v_strfecha:=substr(valor_columna,instr(valor_columna,'-')+1);
        v_mes:=substr(v_strfecha,1,instr(v_strfecha,'-')-1);
        if length(v_mes)>3 Then
          v_mes:=substr(v_mes,1,3);
        end if;
        v_ano:=substr(v_strfecha,instr(v_strfecha,'-')+1);
        if length(v_ano)=2 Then --yy
          if to_number(v_ano)>17 Then
            v_strfecha:=v_dia || '-' || v_mes || '-19' || v_ano;
          else
            v_strfecha:=v_dia || '-' || v_mes || '-20' || v_ano;
          end if;
        else --yyyy
          v_strfecha:=v_dia || '-' || v_mes || '-' || v_ano;
        end if;
        Select TO_DATE(v_strfecha,'DD/MM/YYYY') into v_fecha from dual;
      EXCEPTION
      when others then
        if devuelve_nulo='true' then
          v_fecha:=null;
        else
          Select to_date('01/01/1900','dd/mm/yyyy') into v_fecha From dual;
        end if;
        Begin
          err_msg := SUBSTR(SQLERRM, 1, 200);
          INSERT INTO ERROR_ARCHIVO (ID, VERSION, CODIGO, LINEA, TIPO, DESCRIPCION)
          VALUES (busca_clave_id, 0, busca_clave_id, v_id_linea_archivo, 1, 'Error al intentar obtener la fecha ' || nombre_objeto || ', valor leído:' || valor_columna || ', mensaje:' || err_msg);
          Update LINEA_ARCHIVO set ERRORES=ERRORES+1 Where id=v_id_linea_archivo;
        exception
        when others then
          raise_application_error(-20002,'Error al insertar un registro de error en carga de archivo, mensaje '|| sqlerrm, true);
        End;
      END;
    Else
      Begin
        v_dia:=substr(valor_columna,1,instr(valor_columna,'/')-1);
        v_strfecha:=substr(valor_columna,instr(valor_columna,'/')+1);
				v_mes:=substr(v_strfecha,1,instr(v_strfecha,'/')-1);
				v_ano:=substr(v_strfecha,instr(v_strfecha,'/')+1);
        if length(v_ano)=2 Then --yy
          if to_number(v_ano)>17 Then
            v_strfecha:=v_dia || '/' || v_mes || '/19' || v_ano;
          else
            v_strfecha:=substr(valor_columna,1,5) || '/20' || v_ano;
          end if;
        else --yyyy
          v_strfecha:=v_dia || '/' || v_mes || '/' || v_ano;
        end if;
        Select to_date(v_strfecha,'dd/mm/yyyy') into v_fecha From dual;
      EXCEPTION
      when others then
        if devuelve_nulo='true' then
          v_fecha:=null;
        else
          Select to_date('01/01/1900','dd/mm/yyyy') into v_fecha From dual;
        end if;
        Begin
          err_msg := SUBSTR(SQLERRM, 1, 200);
          INSERT INTO ERROR_ARCHIVO (ID, VERSION, CODIGO, LINEA, TIPO, DESCRIPCION)
          VALUES (busca_clave_id, 0, busca_clave_id, v_id_linea_archivo, 1, 'Error al intentar obtener la fecha ' || nombre_objeto || ', valor leído:' || valor_columna || ', mensaje:' || err_msg);
          Update LINEA_ARCHIVO set ERRORES=ERRORES+1 Where id=v_id_linea_archivo;
        exception
        when others then
          raise_application_error(-20002,'Error al insertar un registro de error en carga de archivo, mensaje '|| sqlerrm, true);
        End;
      END;
    end if;
  end if;
  return v_fecha;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20000, err_msg || ', valor columna:' || valor_columna || ', objeto:' || nombre_objeto, true);
end;
end;
/
