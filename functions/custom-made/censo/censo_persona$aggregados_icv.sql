create or replace function censo_persona$aggregados_icv(x$super number, x$idfuncion number, x$censo number, x$ficha_persona number) return number is
Begin
  Declare
	err_msg             VARCHAR2(300);
	i                   integer :=0;
  x$version_ficha		  varchar2(50);
  x$algoritmo				  varchar2(4000);
  x$nombre_func			  varchar2(30);
  aux						      varchar2(4000);
  v_cant_registro		  integer;
  v_valor_item			  varchar2(100);
  v_id_objeto				  number;
  v_tipo_objeto			  varchar2(20);
  v_resultado_objeto  varchar2(2000);
  v_valor_sustituir	  varchar2(100);
  x$valor						  number;
  v_strsql					  varchar2(2000);
  v_test1 					  varchar2(1000);
	v_test2					    varchar2(1000);
	v_test3					    varchar2(1000);
  v_$agregacion			  varchar2(10);
	x$ficha_hogar			  number;
  v$ficha_persona		  number;
  v_id_carga_tmp      number;
begin --SIAU 12520
  Begin
    Select valor Into x$version_ficha From variable_global where numero=103;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20001,'Error al intentar obtener la versi�n activa de la ficha', true);
  End;
  Begin
	  Select upper(algoritmo), nombre into x$algoritmo, x$nombre_func From funcion_ficha_persona Where id=x$idfuncion;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20002,'Error al intentar obtener el algorito de la funci�n seleccionada para el c�lcul del ICV.', true);
  End;
  begin
		Select length(x$algoritmo)-length(replace(x$algoritmo,'[','')) Into v_cant_registro From dual;  --cantidad de elementos a iterar
  EXCEPTION
  WHEN OTHERS THEN
		raise_application_error(-20003,'Error al intentar obtener la cantidad de elementos presentes en el algoritmo de la funci�n seleccionada de ficha.', true);
  End;
  aux:=upper(x$algoritmo); v_$agregacion:=null;
	For i in 0 .. v_cant_registro LOOP
   	v_id_objeto:=null; v_tipo_objeto:=null; v_resultado_objeto:=null;
   	if instr(x$algoritmo,'[')=0 then
			exit; --no hay mas variable que sustituir
		else
			if (v_$agregacion is null) then
				if (instr(upper(aux),'SUM['))>0 then
          v_$agregacion:='SUM';
				elsif (instr(upper(aux),'MIN['))>0 then
          v_$agregacion:='MIN';
				elsif (instr(upper(aux),'MAX['))>0 then
          v_$agregacion:='MAX';
        else
          v_$agregacion:=null;
        end if;
        if (v_$agregacion is not null) then
					x$algoritmo:=replace(x$algoritmo,v_$agregacion || '[','[');
				end if;
			end if;
      aux:=substr(aux, instr(aux,'[')+1);
			v_valor_item:=upper(substr(aux, 0, instr(aux,']')-1));
      v_id_carga_tmp:=null;
      begin --validamos que este en temporal (ya calculado)
        if (v_$agregacion is null) then --si la agregacion es null buscamos en la ficha persona
          Select resultado, id
            into v_resultado_objeto, v_id_carga_tmp
          From result_funcion_icv
          Where censo_persona=x$censo And ficha_persona=x$ficha_persona
            And upper(trim(nombre))=v_valor_item And rownum=1;
        else --si es agregado se debe buscar el temporal en el censo (hogar)
          Select resultado, id
            into v_resultado_objeto, v_id_carga_tmp
          From result_funcion_icv
          Where censo_persona=x$censo And ficha_persona=null
            And upper(trim(nombre))=v_valor_item And rownum=1;
        end if;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_id_carga_tmp:=null; v_id_objeto:=null;
      WHEN others THEN
        v_id_carga_tmp:=null; v_id_objeto:=null;
        err_msg := SUBSTR(SQLERRM, 1, 300);
        raise_application_error(-20004,'Error al intentar obtener objeto para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
      end;
			if v_id_objeto is null then
        begin --primero se buscar la variable en preguntas de persona de la versi�n activo
					Select pp.id, 'pregunta' into v_id_objeto, v_tipo_objeto
          From pregunta_ficha_persona pp
          Where trim(pp.version_ficha)=x$version_ficha And upper(pp.codigo)=v_valor_item;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					v_id_objeto:=null;
				WHEN others THEN
          v_id_objeto:=null;
			  End;
      end if;
      if v_id_objeto is not null then
				begin
          Select case pp.tipo_dato_respuesta when 1 then to_char(rp.texto) when 2 then to_char(nvl(rp.numero,0)) when 3 then to_char(rp.fecha,'dd/mm/yyyy') else
								(SELECT to_char(rf.numeral) From rango_ficha_persona rf where rf.id=rp.rango) end
              into v_resultado_objeto
          From pregunta_ficha_persona pp inner join respuesta_ficha_persona rp on pp.id = rp.pregunta
              inner join ficha_persona fp on rp.ficha = fp.id
          Where pp.id=v_id_objeto And rownum=1
            And fp.id=x$ficha_persona;
				EXCEPTION
        WHEN NO_DATA_FOUND THEN   --respuesta no obtenida
					v_resultado_objeto:=null;
				WHEN others THEN
					v_resultado_objeto:=null;
				End;
      end if;
      if v_resultado_objeto is null then --finalmente evaluamos al objeto como una funcion
				begin
					Select id into v_id_objeto From funcion_ficha_persona where trim(upper(nombre))=v_valor_item;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					v_id_objeto:=null;
				WHEN others THEN
					v_id_objeto:=null;
					err_msg := SUBSTR(SQLERRM, 1, 300);
					raise_application_error(-20005,'Error al intentar obtener el objeto para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
				End;
				if v_id_objeto is not  null then
          v_tipo_objeto:='funcion';
					if (v_$agregacion is not null) then --si hay una clausula de agregacion se itera los miembros del hogar
            v_resultado_objeto:=0;
            begin
              Select fp.ficha_hogar into x$ficha_hogar From ficha_persona fp Where fp.id=x$ficha_persona;
            EXCEPTION
						WHEN NO_DATA_FOUND THEN
							x$ficha_hogar:=null;
						WHEN others THEN
							x$ficha_hogar:=null;
						End;
            if x$ficha_hogar is not null then
              For reg in (Select  fp.id
                          From ficha_persona fp
                          Where fp.ficha_hogar=x$ficha_hogar) loop
								v$ficha_persona:=reg.id;
                case trim(upper(v_$agregacion))
                when 'SUM' then
									v_resultado_objeto:=v_resultado_objeto+censo_persona$aggregados_icv(x$super, v_id_objeto, x$censo, v$ficha_persona);
                else
                  v_resultado_objeto:=censo_persona$aggregados_icv(x$super, v_id_objeto, x$censo, v$ficha_persona);
                end case;
              end loop;
						else
              v_resultado_objeto:=censo_persona$aggregados_icv(x$super, v_id_objeto, x$censo, x$ficha_persona);
						end if;
					else
						v_resultado_objeto:=censo_persona$aggregados_icv(x$super, v_id_objeto, x$censo, x$ficha_persona);
					end if;
        end if;
      end if;
      if v_resultado_objeto is null And v_$agregacion is null then --preguntas de hogar
        begin
					Select pp.id, 'pregunta' into v_id_objeto, v_tipo_objeto
					From pregunta_ficha_hogar pp
					Where trim(pp.version_ficha)=x$version_ficha And trim(upper(pp.codigo))=v_valor_item;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					v_id_objeto:=null;
				WHEN others THEN
          v_id_objeto:=null;
					err_msg := SUBSTR(SQLERRM, 1, 300);
					raise_application_error(-20004,'Error al intentar obtener objeto para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
				End;
        if v_id_objeto is not null then
					begin
						Select case pp.tipo_dato_respuesta when 1 then to_char(rp.texto) when 2 then to_char(nvl(rp.numero,0)) when 3 then to_char(rp.fecha,'dd/mm/yyyy') else
									(SELECT to_char(rf.numeral) From rango_ficha_hogar rf where rf.id=rp.rango) end
							into v_resultado_objeto
						From pregunta_ficha_hogar pp inner join respuesta_ficha_hogar rp on pp.id = rp.pregunta
              inner join ficha_hogar fh on rp.ficha = fh.id
							inner join ficha_persona fp on fh.id=fp.ficha_hogar
						Where pp.id=v_id_objeto And rownum=1
              And fp.id=x$ficha_persona;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN   --respuesta no obtenida
						v_resultado_objeto:=null;
					WHEN others THEN
						v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20005,'Error al intentar obtener el valor objeto (pregunta hogar) para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
					End;
        end if;
			end if;
      if v_resultado_objeto is null And instr(v_valor_item,'.')>0 then --el objeto a evaluar es un campo de una tabla
        v_tipo_objeto:='campo';
        case lower(substr(v_valor_item,1,instr(v_valor_item,'.')-1)) --nombre tabla
        when 'ficha_hogar' then
          v_strsql:='Select fh.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'ficha_hogar' || chr(39) || '
                    From ficha_persona fp inner join ficha_hogar fh on fp.ficha_hogar = fh.id
                    Where fp.id= ' || x$ficha_persona || ' And rownum=1
                      And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
          begin
            Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
          End;
				when 'ficha_persona' then
          v_strsql:='Select fp.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'ficha_persona' || chr(39) || '
                    From ficha_persona fp
                    Where fp.id= ' || x$ficha_persona || ' And rownum=1';
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
          End;
        when 'persona' then
          v_strsql:='Select pe.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'persona' || chr(39) || '
                    From persona pe inner join ficha_persona fp on pe.codigo = fp.numero_cedula
                    Where fp.id= ' || x$ficha_persona || ' And rownum=1';
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
          End;
        when 'rama' then
          v_strsql:='Select ra.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'rama' || chr(39) || '
                    From ficha_persona fp left outer join rama ra on fp.rama = ra.id
                    Where fp.id= ' || x$ficha_persona || ' And rownum=1';
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
          End;
        when 'ocupacion' then
          v_strsql:='Select oc.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'ocupacion' || chr(39) || '
                    From ficha_persona fp left outer join ocupacion oc on fp.ocupacion = oc.id
                    Where fp.id= ' || x$ficha_persona || ' And rownum=1';
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
          End;
        when 'departamento' then
          v_strsql:='Select dp.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'departamento' || chr(39) || '
                    From ficha_persona fp inner join ficha_hogar fh on fp.ficha_hogar = fh.id
                      left outer join departamento dp on fh.departamento = dp.id
                    Where fp.id= ' || x$ficha_persona || ' And rownum=1
                      And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
				  End;
        when 'distrito' then
          v_strsql:='Select dt.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'distrito' || chr(39) || '
                    From ficha_persona fp on cp.ficha=fp.id inner join ficha_hogar fh on fp.ficha_hogar = fh.id
                      left outer join distrito dp on fh.distrito = dt.id
                    Where fp.id= ' || x$ficha_persona || ' And rownum=1
                      And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
          End;
        when 'barrio' then
          v_strsql:='Select ba.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'barrio' || chr(39) || '
                    From ficha_persona fp inner join ficha_hogar fh on fp.ficha_hogar = fh.id
                      left outer join barrio ba on fh.barrio = ba.id
                    Where fp.id= ' || x$ficha_persona || ' And rownum=1
                      And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
          End;
        when 'persona' then
          v_strsql:='Select pe.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'persona' || chr(39) || '
                    From ficha_persona fp inner join persona pe on fp.numero_cedula = pe.codigo
                    Where fp.id= ' || x$ficha_persona;
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
          WHEN NO_DATA_FOUND THEN
            v_resultado_objeto:=null;
					WHEN others THEN
            v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el c�lculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
				   End;
				else
					null;
        end case;
      end if;
			if v_resultado_objeto is null then
				v_resultado_objeto:=0;
			end if;
			v_valor_sustituir:= '[' || v_valor_item || ']';
			x$algoritmo:=replace(x$algoritmo,v_valor_sustituir,v_resultado_objeto);
      aux:=replace(aux,v_valor_sustituir,v_resultado_objeto);
			aux:=substr(aux, instr(aux,']')+1);
		end if;
   End loop;
   begin
    if trim(upper(x$nombre_func))=upper('inglabe') then --solo para debuguear
      v_test1 := substr(x$algoritmo, 1 , 950);
			v_test2 := substr(x$algoritmo, 951, 950);
			v_test3 := substr(x$algoritmo,1901, 950);
		end if;
   	x$algoritmo := 'Select ' || x$algoritmo  || ' From dual';
    Execute IMMEDIATE x$algoritmo into x$valor;
	EXCEPTION
	WHEN others THEN
		raise_application_error(-20020,'Error al intentar calcular el valor a retornar, funci�n [' || x$nombre_func || '], algoritmo evaluado:' || x$algoritmo || ', mensaje:' || SQLERRM, true);
	End;
  if v_id_carga_tmp is null then
   	v_id_carga_tmp:=busca_clave_id;
		Insert Into result_funcion_icv (ID, VERSION, CODIGO, CENSO_PERSONA, FICHA_PERSONA, NOMBRE, RESULTADO, ALGORITMO)
		values (v_id_carga_tmp, 0, v_id_carga_tmp, x$censo, x$ficha_persona, x$nombre_func, x$valor, x$algoritmo);   
	end if;
  return x$valor;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20100, err_msg || ', valor evaluado:' || v_valor_item , true);
end;
end;
/
