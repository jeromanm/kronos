create or replace function lote$calcular_icv_lote$biz(x$super number, x$lote number, x$observaciones nvarchar2) return number is
	v$err 				constant number := -20000; -- an integer in the range -20000..-20999
	v$msg 				nvarchar2(2000); -- a character string of at most 2048 bytes?
	x$censo				number;
  x$icv					number;
  x$idfuncion_fp		number;
  x$nombre_funcion  NVARCHAR2(30);
  v$log rastro_proceso_temporal%ROWTYPE;
begin
	v$log := rastro_proceso_temporal$select();
  Begin
    Select valor Into x$nombre_funcion From variable_global where numero=117;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(v$err,'Error al intentar obtener la variable de la función del ICV.', true);
  End;
  Begin   
	  Select id into x$idfuncion_fp From funcion_ficha_persona where upper(nombre)=upper(x$nombre_funcion);
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		raise_application_error(v$err,'No se consiguió obtener el id de la función del ICV.', true);
	WHEN others THEN
		raise_application_error(v$err,'Error al intentar obtener el id de la función del ICV, mensaje:' || SQLERRM, true);   
  End;
	update lote set observaciones = x$observaciones where id = x$lote;
	if not SQL%FOUND then
		v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'lote', 'id', x$lote);
		raise_application_error(v$err, v$msg, true);
	end if;
	For reg in (Select e.id
               From lote a inner join lote_pension b on a.id = b.lote
                inner join pension c on b.pension = c.id
                inner join persona d on c.persona = d.id
                inner join censo_persona e on d.id = e.persona
                inner join ficha_persona f on e.ficha = f.id
                inner join ficha_hogar g on f.ficha_hogar = g.id
               Where a.id = x$lote And b.excluir='false' And e.estado=4 And g.estado<>4) loop
		x$censo:=reg.id;
    begin
      Delete From result_funcion_icv Where censo_persona=x$censo;
      x$icv:=censo_persona$obtenervalor_icv(x$super, x$idfuncion_fp, x$censo, null);
    EXCEPTION
    WHEN others THEN
      x$icv:=null;
      null;
    End;
    if x$icv is not null then
      begin
  			update censo_persona set icv=x$icv, observaciones = x$observaciones where id = x$censo;
        update ficha_hogar set icv=x$icv 
        Where id in (Select fp.ficha_hogar From censo_persona cp inner join ficha_persona fp on cp.ficha = fp.id
                    Where cp.id= x$censo);
        update persona set icv=x$icv 
        Where ficha in (Select fp2.id 
                      From censo_persona cp inner join ficha_persona fp on cp.ficha = fp.id
                        inner join ficha_hogar fh on fp.ficha_hogar = fh.id
                        inner join ficha_persona fp2 on fh.id = fp2.ficha_hogar
                    Where cp.id= x$censo);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
  			raise_application_error(v$err,'Error: no se consiguió registro de censo según id seleccionado: ' || x$censo, true);
      WHEN others THEN
  			raise_application_error(v$err,'Error al intentar actualizar el ICV en el censo seleccionado, mensaje:' || SQLERRM, true);   
      End;
    end if;
    commit work;
    rastro_proceso_temporal$revive(v$log);
	end loop;
	return 0;
end;
/
