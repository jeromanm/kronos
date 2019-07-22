create or replace function pension$reg_dic_otor$53472$biz(x$super number, x$pension number, x$resumen_dictamen_otorgar nvarchar2, x$antecedente_oto nvarchar2, x$antecedente_oto_uno nvarchar2,
                                                          x$disposicion_oto_uno nvarchar2, x$disposicion_oto_dos nvarchar2, x$disposicion_oto_tres nvarchar2, x$opinion_oto_uno nvarchar2,
                                                          x$opinion_oto_dos nvarchar2, x$opinion_oto_tres nvarchar2) return number is 
   v$err 							      constant number := -20000; -- an integer in the range -20000..-20999
   v$msg 							      nvarchar2(2000); -- a character string of at most 2048 bytes?
   v$log rastro_proceso_temporal%ROWTYPE;
   v$inserta_transicion 		number;
   v$estado_inicial     		number;
   v$estado_final       		number;
   v_dictamen_otorgar   		VARCHAR2(255);
   err_num 							    NUMBER;
   err_msg							    VARCHAR2(255);
   v_tiene_objecion				  VARCHAR2(5);
   v_falta_requisito				VARCHAR2(5);
   x$solicitante            number;
   x$clase                  number;
begin -- registrar dictamen para otorgar
	begin
		Select tiene_objecion, falta_requisito, persona, clase, estado
      	into v_tiene_objecion, v_falta_requisito, x$solicitante, x$clase, v$estado_inicial
		From pension where id = x$pension;
	exception
	when others then
		err_msg := SUBSTR(SQLERRM, 1, 255);
    v$msg := util.format(util.gettext('Error al intentar registrar la resolución para otorgar de la pensión %s , mensaje: %s'), x$pension, err_msg);
		raise_application_error(v$err, v$msg, true);
	end;
	if v_tiene_objecion='true' then
		v$msg := util.format(util.gettext('Error: pensión %s, tiene objeciones.'), x$pension);
		raise_application_error(v$err, v$msg, true);
	end if;
	if v_falta_requisito='true' then
		v$msg := util.format(util.gettext('Error: faltan requisitos por consignar/aceptar de la pensión %s.'), x$pension);
		raise_application_error(v$err, v$msg, true);
	end if;
  For reg in (Select a.compatible, b.nombre as clase, d.id
              From clase_pension_comp a inner join clase_pension b on a.clase = b.id
                inner join pension c on b.id = c.clase
                inner join clase_pension d on a.clase_comp = d.id
              Where c.persona=x$solicitante And c.id<> x$pension
                And c.estado not in (2, 5, 10, 8, 9)) --anulada, finalizada, revocada, revocable
  loop
		if reg.compatible='false' And reg.id=x$clase Then
			v$msg := util.format(util.gettext('Error: el concepto de la pensión solicitada, no es compatible con la pensión clase ' || reg.clase || ', de una pensión anterior.'));
			raise_application_error(v$err, v$msg, true);
		end if;
	end loop;
	v$estado_final   := 6;
  Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
  Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into v_dictamen_otorgar From variable_global Where numero=115;
	update pension set resumen_dictamen_otorgar =  x$resumen_dictamen_otorgar, antecedente_oto = substr(trim(x$antecedente_oto),0,2000), 
                    disposicion_oto_uno = x$disposicion_oto_uno, disposicion_oto_dos = x$disposicion_oto_dos,antecedente_oto_uno=x$antecedente_oto_uno,
                    disposicion_oto_tres = x$disposicion_oto_tres, opinion_oto_uno = x$opinion_oto_uno,
                    opinion_oto_dos = x$opinion_oto_dos, opinion_oto_tres = x$opinion_oto_tres,dictamen_otorgar=v_dictamen_otorgar, fecha_dictamen_otorgar=current_date,
                    estado = v$estado_final, fecha_transicion = current_date, usuario_transicion = util.current_user_id()
	where id = x$pension; 
	v$inserta_transicion := transicion_pension$biz(x$pension, current_date, current_user_id(), v$estado_inicial, v$estado_final, null,
                                                 null, x$disposicion_oto_tres, v_dictamen_otorgar, current_date, x$resumen_dictamen_otorgar,
                                                 null, null, null);
	if not SQL%FOUND then
		v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'pension', 'id', x$pension);
		raise_application_error(v$err, v$msg, true);
	end if;
	return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(v$err, err_msg, true);
end;
/
