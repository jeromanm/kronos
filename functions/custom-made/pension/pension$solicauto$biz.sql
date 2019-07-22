create or replace function pension$solicauto$biz(x$super number, x$departamento number, x$distrito number, observaciones nvarchar2)
  return number is
	err_msg                      	VARCHAR2(2000);
	v_version_ficha_hogar         varchar2(20):= NULL;
	v_periodo_validez_censo			integer;
	v_max_censo_periodo				integer;
	v_id_censista_externo  		  	number;
	contador                      integer :=1;
	x$persona							number;
	v_id_pension						number;
	v_clase_pension					number;
	v_cant_censos						integer;
	v_id_censo_persona				integer;
	v_id_ficha_hogar					number;
	v_id_ficha_persona				number;
	v$estado_inicial 					integer;
	v$estado_final   					integer;
	v$inserta_transicion				number;
   x$reg									number;
   v_tiene_objecion					varchar2(10);
begin
	Begin
		Select valor Into v_version_ficha_hogar From variable_global where numero=103;  --version ficha hogar activa
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
	End;
   Select valor into v_periodo_validez_censo From variable_global where numero=101; --Periodo de validez de censo en años
	Select valor into v_max_censo_periodo From variable_global where numero=102;--Máximo número de censos por periodo
	Begin
		Select id Into v_id_censista_externo From censista where trim(nombre)='DPNC';
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			v_id_censista_externo:=NULL;
	End;
   Begin
		Select id Into v_clase_pension From clase_pension where requiere_censo='true';
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		v_clase_pension:=NULL;
	End;
	For reg in (Select fp.numero_cedula, fp.nombre, fp.nombres, fp.apellidos, fp.sexo_persona, fp.estado_civil, fp.fecha_nacimiento, 
   						fp.numero_telefono, fh.id as id_ficha_hogar, fp.id as id_ficha_persona,
							fh.departamento, fh.distrito, fh.barrio, fh.tipo_area, fh.icv, fh.direccion, per.id as id_persona
					From ficha_persona fp inner join ficha_hogar fh on fp.ficha_hogar = fh.id
               	left outer join persona per on fp.numero_cedula=per.codigo
					Where calcular_edad(fp.fecha_nacimiento)>=65
						And NOT Exists (Select pn.id From persona pe inner join pension pn on pe.id = pn.persona
   									Where pe.codigo = fp.numero_cedula)
						And fp.numero_cedula is not null And fh.icv<=65
  						And (fh.departamento=x$departamento or x$departamento is null)
						And (fh.distrito=x$distrito or x$distrito is null)
				   ) loop
         x$persona:=reg.id_persona; 
         v_id_ficha_hogar:=reg.id_ficha_hogar; 
         v_id_ficha_persona:=reg.id_ficha_persona;
         if x$persona is null then
	        	begin
		         x$persona:=busca_clave_id;
	         	insert into persona (id, version, codigo, nombre, apellidos, nombres, fecha_nacimiento, sexo, estado_civil, paraguayo,
									      	cedula, indigena, departamento, distrito, monitoreado, monitoreo_sorteo, edicion_restringida, direccion,
	                                 barrio, tipo_area, etnia, comunidad, telefono_linea_baja, ficha)
	                      values (x$persona, 0, reg.numero_cedula, reg.nombre, reg.apellidos, reg.nombres, reg.fecha_nacimiento, reg.sexo_persona, reg.estado_civil, 'true',
										reg.numero_cedula, 'false', reg.departamento, reg.distrito, 'false', 'false', 'true', reg.direccion,
										reg.barrio, reg.tipo_area, null, null, reg.numero_telefono, v_id_ficha_persona);
				EXCEPTION
				when others then
					err_msg := SUBSTR(SQLERRM, 1, 300);
	            x$persona:=NULL;
				End;
			end if;
			v_id_pension:=null;
			if x$persona is not null Then
            begin
		         v_id_pension:=busca_clave_id;
        			insert into pension(id, version, codigo, clase, persona, observaciones)
					values (v_id_pension, 0, v_id_pension, v_clase_pension, x$persona, observaciones);
     			exception
       		when others then
		         v_id_pension:=null;
               err_msg := SUBSTR(SQLERRM, 1, 300);
      		end;
			end if;
         if v_id_pension is not null then
	     		v$estado_inicial := 1;
				v$estado_final   := 1;
				v$inserta_transicion := transicion_pension$biz(v_id_pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
			end if;
			x$reg:=pension$verificar$biz(0, v_id_pension,'true'); --verificar elegibilidad de la pensión recién creada
			begin
				Select tiene_objecion into v_tiene_objecion From pension where id =v_id_pension;
			exception
       	when others then
				v_tiene_objecion:='false';
     		end;
			Select Count(id) into v_cant_censos From censo_persona Where persona=x$persona And fecha between ADD_MONTHS(sysdate,((v_periodo_validez_censo*12)*-1)) And sysdate;
			if v_cant_censos <= v_max_censo_periodo And v_tiene_objecion<>'true' then --solo se cargan datos de censo a aquellos que no tengan mas de la cantidad permitida en el periodo configurado
				if v_id_ficha_hogar is not null And v_id_ficha_persona is not null then
					begin
						v_id_censo_persona := busca_clave_id;
						INSERT INTO CENSO_PERSONA (ID, VERSION, CODIGO, PERSONA, FECHA, FICHA,
		      	                                ICV, DEPARTAMENTO, DISTRITO, TIPO_AREA,
		                                       BARRIO, DIRECCION, NUMERO_TELEFONO, ESTADO, USUARIO_TRANSICION, 
                                               OBSERVACIONES,  CENSISTA_EXTERNO)
						values (v_id_censo_persona, 0, v_id_censo_persona, x$persona, current_date, v_id_ficha_persona,
					     	      reg.icv, reg.departamento, reg.distrito, reg.tipo_area,
									reg.barrio, reg.direccion, reg.numero_telefono, 1, current_user_id, 
                             observaciones, v_id_censista_externo);
					exception
			      when others then
						v_id_censo_persona:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20000, 'Error al intentar crear el registro de censo para la cédula:' || reg.numero_cedula || ', nombres:' ||  reg.nombre || ', proceso: pensión automática. Mensaje:' || err_msg, true);
					end;
				end if;
			end if; --if v_cant_censos <= v_max_censo_periodo then
		contador:=contador+1;
	End loop;
  	return contador;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20000, 'Error en pensión automática, mensaje:' || err_msg, true);
end;
/
