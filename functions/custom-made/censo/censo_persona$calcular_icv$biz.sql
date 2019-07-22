create or replace function censo_persona$calcular_icv$biz(x$super number, x$censo number, x$observaciones nvarchar2) return number is
  v$icv 					  number(7,4);
  x$nombre_funcion	varchar2(30);
  x$idfuncion_fp		number;
  x$persona				  number;
  x$estado					number;
  x$estado_hogar		number;
begin --SIAU 12520
--
--  CensoPersona.calcularIcv - business logic
--
   Begin
      Select valor Into x$nombre_funcion From variable_global where numero=117;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20001,'Error al intentar obtener la variable de la función del ICV.', true);
   End;
   Begin   
	   Select id into x$idfuncion_fp From funcion_ficha_persona where upper(nombre)=upper(x$nombre_funcion);
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20001,'No se consiguió obtener el id de la función del ICV.', true);
	WHEN others THEN
		raise_application_error(-20001,'Error al intentar obtener el id de la función del ICV, mensaje:' || SQLERRM, true);   
   End;
   Begin      
	   Select a.persona, a.estado, c.estado
      	into x$persona, x$estado, x$estado_hogar
      From censo_persona a inner join ficha_persona b on a.ficha = b.id
        inner join ficha_hogar c on b.ficha_hogar = c.id
      Where a.id=x$censo;
   EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20001,'No se consiguió obtener el id de la persona asociada al censo suministrado.', true);
	WHEN others THEN
		raise_application_error(-20001,'Error al intentar obtener el id de la persona asociada al censo suministrado, mensaje:' || SQLERRM, true);   
   End;
	if x$estado<>4 then
		raise_application_error(-20002,'Error: sólo puede calcular ICV en un censo en estado "Censado."' , true);
  end if;
  if x$estado_hogar=4 then
		raise_application_error(-20002,'Error: no se puede calcular ICV en un hogar en estado "Aceptado."' , true);
  end if;
	Delete From result_funcion_icv Where censo_persona=x$censo;
  v$icv:=censo_persona$obtenervalor_icv(x$super, x$idfuncion_fp, x$censo, null);
  begin
		update censo_persona set icv=v$icv, observaciones = x$observaciones where id = x$censo;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20001,'Error: no se consiguió registro de censo según id suministrado.', true);
	WHEN others THEN
		raise_application_error(-20001,'Error al intentar actualizar el ICV en el censo suministrado, mensaje:' || SQLERRM, true);
  End;
  begin
		update persona set icv=v$icv where id = x$persona;
    update ficha_hogar set icv=v$icv 
    Where id in (Select fp.ficha_hogar From censo_persona cp inner join ficha_persona fp on cp.ficha = fp.id
                  Where cp.id= x$censo);
    update persona set icv=v$icv 
    Where ficha in (Select fp2.id 
                    From censo_persona cp inner join ficha_persona fp on cp.ficha = fp.id
                      inner join ficha_hogar fh on fp.ficha_hogar = fh.id
                      inner join ficha_persona fp2 on fh.id = fp2.ficha_hogar
                  Where cp.id= x$censo);
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(-20001,'Error: no se consiguió registro de persona según id de censo suministrado.', true);
	WHEN others THEN
		raise_application_error(-20001,'Error al intentar actualizar el ICV en la persona asociada al censo suministrado, mensaje:' || SQLERRM, true);   
  End;
  return 0;
end;
/
