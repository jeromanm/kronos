create or replace procedure ficha_persona$aux(x$new ficha_persona%ROWTYPE, x$old ficha_persona%ROWTYPE)
is
  v$id_ficha_hogar        number;
  v$icv                   number;
  v$id_cedula             number;
  v$nombre                varchar2(50);
  v$apellido              varchar2(50);
  v$fecha_nacimiento      date;
  v$sexo                  number;
  v$paraguayo             varchar2(5);
  v$estado_civil          number;
  v$porc_match_nombre     number;
  v$porc_match_apellido   number;
  v$persona               number;
  v$clase_pension         number:=150498912213505560;
  v$id_pension            number;
  v$tiene_objecion        varchar2(5);
  v$inserta_transicion    number;
  v$max_censo_periodo     number;
  v$periodo_validez_censo number;
  v$cant_censos           number;
  v$id_censo_persona      number;
  v$id_censista_externo   number;
begin
    if trim(x$old.numero_cedula) is null And trim(x$new.numero_cedula) is not null And calcular_edad(x$new.fecha_nacimiento)>=65 then
      begin
        Select id, icv 
          into v$id_ficha_hogar, v$icv 
        From ficha_hogar Where id = x$new.ficha_hogar And rownum=1 Order by id desc;
      exception
			WHEN NO_DATA_FOUND THEN
       	v$id_ficha_hogar:=null; v$icv:=null;
      when others then
	      v$id_ficha_hogar:=null; v$icv:=null;
      end;
      begin
        Select id, apellidos, nombres, fech_nacim, sexo, case nacionalidad when 226 then 'true' else 'false' end as paraguayo, estado_civil
            into v$id_cedula, v$apellido, v$nombre, v$fecha_nacimiento, v$sexo, v$paraguayo, v$estado_civil
        From cedula where numero=x$new.numero_cedula;
      exception
			WHEN NO_DATA_FOUND THEN
       	v$id_cedula:=null;
      when others then
	      v$id_cedula:=null;
      end;
      if v$id_cedula is not null then
        begin
          Select f_compara_nombres(upper(x$new.nombres),upper(v$nombre)) into v$porc_match_nombre From dual;
          Select f_compara_nombres(upper(x$new.apellidos),upper(v$apellido)) into v$porc_match_apellido From dual;
        EXCEPTION
        when others then
          v$porc_match_nombre:=0; v$porc_match_apellido:=0;
        End;
        if v$porc_match_nombre>75 And v$porc_match_apellido>75 And v$icv<65 And v$icv is not null then
          Begin
            v$persona:=busca_clave_id;
            insert into persona (id, version, codigo, nombre, apellidos, nombres, fecha_nacimiento, sexo, estado_civil, paraguayo,
                                  cedula, indigena, departamento, distrito, monitoreado, monitoreo_sorteo, edicion_restringida, direccion,
                                  barrio, tipo_area,telefono_linea_baja, ficha)
            Select v$persona, 0, x$new.numero_cedula, x$new.nombre, x$new.apellidos, x$new.nombres, v$fecha_nacimiento, v$sexo, v$estado_civil, v$paraguayo,
                    v$id_cedula, 'false', fh.departamento, fh.distrito, 'false', 'false', 'true', fh.direccion,
                    fh.barrio, fh.tipo_area, x$new.NUMERO_TELEFONO, x$new.id
            From ficha_hogar fh
            Where fh.id=v$id_ficha_hogar;
          EXCEPTION
          when others then
            v$persona:=NULL;
          End;
          if v$persona is not NULL then
            begin
              v$id_pension:=busca_clave_id;
              insert into pension(id, version, codigo, clase, persona, estado, FECHA_TRANSICION, USUARIO_TRANSICION)
              values (v$id_pension, 0, v$id_pension, v$clase_pension, v$persona, 1, sysdate, CURRENT_USER_ID);
            exception
            when others then
              v$id_pension:=null;
            end;
            if v$id_pension is not null then
              v$inserta_transicion := transicion_pension$biz(v$id_pension, current_date, current_user_id(), 1, 1, null, null, null, null, null, null, null, null, null);
              v$inserta_transicion := pension$verificar$biz(0, v$id_pension, 'true'); --verificar elegibilidad de la pensión reción creada
              begin
                Select tiene_objecion into v$tiene_objecion From pension where id =v$id_pension;
              exception
              WHEN NO_DATA_FOUND THEN
                v$tiene_objecion:='false';
              when others then
                v$tiene_objecion:='false';
              end;
            end if;
            Select valor into v$periodo_validez_censo From variable_global where numero=101; --Periodo de validez de censo en aóos
            begin
              Select Count(distinct(a.id)) into v$cant_censos
              From censo_persona a inner join ficha_persona b on a.ficha=b.id
                left outer join ficha_hogar c on b.ficha_hogar = c.id
                left outer join ficha_persona d on c.id = d.ficha_hogar And d.id<>b.id
              Where (b.numero_cedula=x$new.numero_cedula or d.numero_cedula=x$new.numero_cedula)
                  And a.fecha between ADD_MONTHS(sysdate,((v$periodo_validez_censo*12)*-1)) And sysdate
              Group By a.fecha, b.numero_cedula, d.numero_cedula;
            exception
            WHEN NO_DATA_FOUND THEN
              v$cant_censos:=0;
            when others then
              v$cant_censos:=0;
            end;
            Select valor into v$max_censo_periodo From variable_global where numero=102;--Móximo número de censos por periodo
            Begin
              Select id Into v$id_censista_externo From censista where trim(nombre)='DPNC';
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              v$id_censista_externo:=NULL;
            End;
            if v$cant_censos <= v$max_censo_periodo And v$tiene_objecion='false' then --solo se cargan datos de censo a aquellos que no tengan mas de la cantidad permitida en el periodo configurado
              begin
                Select id into v$id_censo_persona
                From censo_persona Where persona=v$persona And estado=1 And rownum=1;
              Exception
              WHEN NO_DATA_FOUND THEN
                v$id_censo_persona:=null;
              when others then
                v$id_censo_persona:=null;
              end;
              if v$id_censo_persona is null then
                begin
                  v$id_censo_persona := busca_clave_id;
                  INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,
                                            ICV, DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO, DIRECCION, 
                                            NUMERO_TELEFONO, ESTADO,  FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES,  CENSISTA_EXTERNO)
                  Select v$id_censo_persona, 0, v$id_censo_persona, v$persona, current_date, x$new.id,
                        v$icv, fh.departamento, fh.distrito, fh.tipo_area, fh.barrio, fh.direccion, 
                        x$new.NUMERO_TELEFONO, 1, sysdate, CURRENT_USER_ID, 'Creado automáticamente por proceso de cambio de cedula.', v$id_censista_externo
                  From ficha_hogar fh
                  Where fh.id=v$id_ficha_hogar;
                exception
                when others then
                  v$id_censo_persona:=null;
                end;
              end if;
            end if; --if v$cant_censos <= v$max_censo_periodo And v$tiene_objecion='false' then
          end if; --v$persona is not null
        end if; --if v$porc_match_nombre>75 And v$porc_match_apellido>75 And v$icv<65 And v$icv is not null then
      end if; --if v$id_cedula is not null then
    end if; --if trim(x$old.numero_cedula) is null And trim(x$new.numero_cedula) is not null then
end;
/
