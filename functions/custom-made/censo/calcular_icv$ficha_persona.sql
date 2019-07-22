create or replace function calcular_icv$ficha_persona(x$super number, x$idfuncion_fp VARCHAR2, x$persona VARCHAR2) return number is
Begin
  Declare
	err_msg					VARCHAR2(300);
	i                   	integer :=0;
	x$version_ficha		varchar2(50);
   x$algoritmo				varchar2(4000);
   x$nombre_func			varchar2(30);
   aux						varchar2(4000);
   v_cant_registro		integer;
   v_valor_item			varchar2(100);
   v_id_objeto				number;
   v_tipo_objeto			varchar2(20);
   v_resultado_objeto	varchar2(2000);
   v_valor_sustituir		varchar2(100);
   x$icv						number;
   variabled				varchar2(300);
   v_strsql					varchar2(2000);
   v_test1 					varchar2(1000);
	v_test2					varchar2(1000);
	v_test3					varchar2(1000);
Begin
   Begin
      Select valor Into x$version_ficha From variable_global where numero=103;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20001,'Error al intentar obtener la versión activa de la ficha persona.', true);
   End; 
   Begin  
	   Select algoritmo, nombre into x$algoritmo, x$nombre_func From funcion_ficha_persona Where id=x$idfuncion_fp;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20002,'Error al intentar obtener el algorito de la función seleccionada de la ficha persona.', true);
   End; 
   begin
		Select length(x$algoritmo)-length(replace(x$algoritmo,'[','')) Into v_cant_registro From dual;  --cantidad de elementos a iterar
   EXCEPTION
  	WHEN OTHERS THEN
		raise_application_error(-20003,'Error al intentar obtener la cantidad de elementos presentes en el algoritmo de la función seleccionada de ficha persona.', true);
   End; 
   aux:=x$algoritmo;
	For i in 0 .. v_cant_registro LOOP
   	v_id_objeto:=null; v_tipo_objeto:=null; v_resultado_objeto:=null;
   	if instr(x$algoritmo,'[')=0 then
			exit; --no hay mas variable que sustituir
		else
      	aux:=substr(aux, instr(aux,'[')+1);
			v_valor_item:=substr(aux, 0, instr(aux,']')-1);
         begin --primero se buscar la variable en preguntas de persona de la versión activo
				Select pp.id, 'pregunta' into v_id_objeto, v_tipo_objeto
            From pregunta_ficha_persona pp 
            Where trim(pp.version_ficha)=x$version_ficha And pp.codigo=v_valor_item;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				v_id_objeto:=null;
			WHEN others THEN
  				v_id_objeto:=null;
				err_msg := SUBSTR(SQLERRM, 1, 300);
				raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
		   End;
         if v_id_objeto is not null then
				begin
						Select case pp.tipo_dato_respuesta when 1 then to_char(rp.texto) when 2 then to_char(nvl(rp.numero,0)) when 3 then to_char(rp.fecha,'dd/mm/yyyy') else
								(SELECT to_char(rf.numeral) From rango_ficha_persona rf where rf.id=rp.rango) end
							into v_resultado_objeto
						From pregunta_ficha_persona pp inner join respuesta_ficha_persona rp on pp.id = rp.pregunta
							inner join ficha_persona fp on rp.ficha = fp.id   
						   inner join censo_persona cp on fp.id = cp.ficha
						Where pp.id=v_id_objeto And rownum=1
                  	And cp.persona=x$persona; 
					EXCEPTION
        			WHEN NO_DATA_FOUND THEN   --respuesta no obtenida
  	               v_resultado_objeto:=null; 
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20005,'Error al intentar obtener el valor objeto (pregunta) para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
				   End;
         end if;
			if v_resultado_objeto is null then --preguntas de hogar
				begin 
					Select pp.id, 'pregunta' into v_id_objeto, v_tipo_objeto
	            From pregunta_ficha_hogar pp 
	            Where trim(pp.version_ficha)=x$version_ficha And pp.codigo=v_valor_item;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					v_id_objeto:=null;
				WHEN others THEN
	  				v_id_objeto:=null;
					err_msg := SUBSTR(SQLERRM, 1, 300);
					raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
			   End;
	         if v_id_objeto is not null then
					begin
						Select case pp.tipo_dato_respuesta when 1 then to_char(rp.texto) when 2 then to_char(nvl(rp.numero,0)) when 3 then to_char(rp.fecha,'dd/mm/yyyy') else
									(SELECT to_char(rf.numeral) From rango_ficha_persona rf where rf.id=rp.rango) end
								into v_resultado_objeto
						From pregunta_ficha_hogar pp inner join respuesta_ficha_hogar rp on pp.id = rp.pregunta
                     inner join ficha_hogar fh on rp.ficha = fh.id
							inner join ficha_persona fp on fh.id=fp.ficha_hogar
						  	inner join censo_persona cp on fp.id = cp.ficha
						Where pp.id=v_id_objeto And cp.persona=x$persona; 
					EXCEPTION
	        		WHEN NO_DATA_FOUND THEN   --respuesta no obtenida
						v_resultado_objeto:=null; 
					WHEN others THEN
						v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20005,'Error al intentar obtener el valor objeto (pregunta) para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);
					End;
	         end if;      
			end if;
         if v_resultado_objeto is null And instr(v_valor_item,'.')>0 then --el objeto a evaluar es un campo de una tabla
	         v_tipo_objeto:='campo';
         	case substr(v_valor_item,1,instr(v_valor_item,'.')-1) --nombre tabla 
            when 'ficha_hogar' then
            	v_strsql:='Select fh.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'ficha_hogar' || chr(39) || ' 
								From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
									inner join ficha_hogar fh on fp.ficha_hogar = fh.id
								Where cp.persona= ' || x$persona || ' And rownum=1
                        	And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
            when 'departamento' then
            	v_strsql:='Select dp.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'departamento' || chr(39) || ' 
								From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
									inner join ficha_hogar fh on fp.ficha_hogar = fh.id                        
									left outer join departamento dp on fh.departamento = dp.id
								Where cp.persona= ' || x$persona || ' And rownum=1
                        	And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
            when 'distrito' then
            	v_strsql:='Select dt.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'distrito' || chr(39) || ' 
								From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
									inner join ficha_hogar fh on fp.ficha_hogar = fh.id                        
									left outer join distrito dp on fh.distrito = dt.id
								Where cp.persona= ' || x$persona || ' And rownum=1
                        	And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
            when 'barrio' then
            	v_strsql:='Select ba.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'barrio' || chr(39) || ' 
								From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
									inner join ficha_hogar fh on fp.ficha_hogar = fh.id                        
									left outer join barrio ba on fh.barrio = ba.id
								Where cp.persona= ' || x$persona || ' And rownum=1
                        	And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
				when 'ficha_persona' then
            	v_strsql:='Select fp.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'ficha_persona' || chr(39) || ' 
								From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
     									inner join ficha_hogar fh on fp.ficha_hogar = fh.id
								Where cp.persona= ' || x$persona || ' And rownum=1
                        	And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
            when 'persona' then
            	v_strsql:='Select pe.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'persona' || chr(39) || ' 
								From persona pe Where pe.persona= ' || x$persona;
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
            when 'censo_persona' then
            	v_strsql:='Select cp.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'censo_persona' || chr(39) || ' 
								From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
     									inner join ficha_hogar fh on fp.ficha_hogar = fh.id
								Where cp.persona= ' || x$persona || ' And rownum=1
                        	And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
            when 'rama' then
            	v_strsql:='Select ra.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'rama' || chr(39) || ' 
								From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
									inner join ficha_hogar fh on fp.ficha_hogar = fh.id                        
									left outer join rama ra on fp.rama = ra.id
								Where cp.persona= ' || x$persona || ' And rownum=1
                        	And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
            when 'ocupacion' then
            	v_strsql:='Select oc.' || substr(v_valor_item,instr(v_valor_item,'.')+1) || ', ' || chr(39) || 'ocupacion' || chr(39) || ' 
								From censo_persona cp inner join ficha_persona fp on cp.ficha=fp.id
									inner join ficha_hogar fh on fp.ficha_hogar = fh.id                        
									left outer join ocupacion oc on fp.ocupacion = oc.id
								Where cp.persona= ' || x$persona || ' And rownum=1
                        	And trim(fh.version_ficha_hogar)=' || chr(39)  || x$version_ficha || chr(39);
					begin
						Execute IMMEDIATE v_strsql into v_resultado_objeto, v_tipo_objeto;
					EXCEPTION
	           	WHEN NO_DATA_FOUND THEN
		            v_resultado_objeto:=null;
					WHEN others THEN
	               v_resultado_objeto:=null;
						err_msg := SUBSTR(SQLERRM, 1, 300);
						raise_application_error(-20004,'Error al intentar obtener objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				   End;
               else               
            		null;
            end case;
         end if;
         if v_resultado_objeto is null then --finalmente evaluamos al objeto como una funcion
				begin
					Select id into v_id_objeto From funcion_ficha_persona where nombre=v_valor_item;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					v_id_objeto:=null;
				WHEN others THEN
					v_id_objeto:=null;
					err_msg := SUBSTR(SQLERRM, 1, 300);
					raise_application_error(-20005,'Error al intentar obtener el objeto para el cálculo del icv, valor evaluado:' || v_valor_item || ', mensaje:' || err_msg, true);         
				End;
				if v_id_objeto is not  null then
	            v_tipo_objeto:='funcion';
					v_resultado_objeto:=calcular_icv$ficha_persona(x$super, v_id_objeto, x$persona);
            else
            	v_resultado_objeto:=0;
            end if;
         end if;
			if v_resultado_objeto is null then 
             v_resultado_objeto:=0;
         end if; 
         v_valor_sustituir:= '[' || v_valor_item || ']';
         x$algoritmo:=replace(x$algoritmo,v_valor_sustituir,v_resultado_objeto);
			aux:=substr(aux, instr(aux,']')+1);
		end if;
   End loop;
   begin
	   if trim(x$nombre_func)='icvam3' then
			v_test1 := substr(x$algoritmo, 1 , 950);
			v_test2 := substr(x$algoritmo, 951, 950);
			v_test3 := substr(x$algoritmo,1990, 950);
      end if;
   	x$algoritmo := 'Select ' || x$algoritmo  || ' From dual';
	   Execute IMMEDIATE x$algoritmo into x$icv;
	EXCEPTION
	WHEN others THEN
		raise_application_error(-20020,'Error al intentar calcular el valor a retornar, función [' || x$nombre_func || '], algoritmo evaluado:' || x$algoritmo || ', mensaje:' || SQLERRM, true);
	End;      
   return x$icv;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20100, err_msg || ', valor evaluado:' || v_valor_item , true);
end;
end;
/
