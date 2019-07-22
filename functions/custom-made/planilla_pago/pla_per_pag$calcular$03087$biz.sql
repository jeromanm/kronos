create or replace function pla_per_pag$calcular$03087$biz(x$super number,  x$clase_pension number, x$periodo number, x$mes number, x$ano varchar2) return number is
	v$err                           constant number := -20000; -- an integer in the range -20000..-20999
	v$msg                           nvarchar2(2000); -- a character string of at most 2048 bytes?
	v$log rastro_proceso_temporal%ROWTYPE;
	id_resumen                      number;
	err_num                         NUMBER;
	err_msg                         VARCHAR2(255);
	v_cant                          number;
	v_id_personaant                 number;
	v_estado                        varchar2(50);
	v_clase_pension                 number;
  v_nombre_clase_pension          varchar2(200);
  v_codigo_clase_pension          varchar2(10);
	v_monto_detalle                 number := 0;
	v_monto_resumen                 number := 0;
  v_orden_resumen                 number := 1;
  v_monto_concepto_perma          number := 0;
	v_id_planilla_periodo_pago      number;
	v_id_planilla_pago              number;
	v_jornal_minimo                 number;
	v_salario_minimo                number;
	v_valor_conc_permanente         number;
	v_valor_conc_cobros_indebidos   number;
	v_valor_conc_pag_haber_atrazad  number;
	v_cant_mes                      number;
	v_monto_maximo               number;
	dias_jornal_planilla            number;
	v_porcentaje_max                number;
	v_dias_jornal                   number;
  v_id_carga_archivo              number;
  v_id_linea_archivo              number;
  contador                        number:=0;
  v_cedulacausante                varchar2(20);
  v_id_acuerdo_pago               number;
  v_id_pago_acuerdo_pension       number;
  v_monto_pagado                  number;
  v_saldo_actual                  number;
  v$pension_causante              number;
begin
	begin
		Select p.estado, p.id as id_planilla_periodo_pago, pp.id as id_planilla_pago, cp.id as id_clase_pension, cp.nombre, cp.codigo
			into v_estado, v_id_planilla_periodo_pago, v_id_planilla_pago, v_clase_pension, v_nombre_clase_pension, v_codigo_clase_pension
		From planilla_periodo_pago p, planilla_pago pp, clase_pension cp
		where pp.id = p.planilla And pp.clase_pension = cp.id
      	And pp.periodo = x$periodo
	      And pp.clase_pension = x$clase_pension
	      And to_number(p.mes) =x$mes And p.ano = x$ano
			And rownum=1;
  exception
  when no_data_found then
    raise_application_error(v$err,'No se encuentra el estado en Planilla Pago',true);
  when others then
    err_msg := SUBSTR(SQLERRM, 1, 200);
    raise_application_error(v$err,'Error al intentar obtener el estado de la planilla de pago, mensaje:' || err_msg,true);
	end;
	if v_estado <> 3 then --cerrado
		---inicio preparación de datos para el calculo
		begin
			delete from detalle_pago_pension
			where resumen in	(Select id from resumen_pago_pension
                        Where planilla = v_id_planilla_pago
                        And to_number(mes_resumen) = to_number(x$mes) And ano_resumen = x$ano And detalle_orden_pago is null);
		exception
		when others then
      v$msg := SQLERRM;
			raise_application_error(v$err,'Error al intentar eliminar los detalle pago calculados, mensaje:' || v$msg,true);
		end;
		begin
			Delete from resumen_pago_pension where planilla = v_id_planilla_pago And to_number(mes_resumen) = to_number(x$mes) And ano_resumen = x$ano And detalle_orden_pago is null;
		exception
		when others then
			raise_application_error(v$err,'Error al intentar eliminar los resúmen de pago calculados, mensaje:' || v$msg,true);
		end;
		begin --Obtenemos el salario y jornal minimo
			Select max(jornal_minimo), max(salario_minimo) into v_jornal_minimo, v_salario_minimo
			From salario_minimo;
		exception
		when no_data_found then
			raise_application_error(v$err,'No se encuentra datos en la table Salario Minimo',true);
		when others then
			raise_application_error(v$err,'Error en la tabla Salario Minimo',true);
		end;
		begin
			Select valor_numerico into v_valor_conc_permanente From variable_global Where numero = 106;
		exception
		when no_data_found then
			raise_application_error(v$err,'No se encuentran datos del concepto permanente (106)',true);
		when others then
			raise_application_error(v$err,'Error al intentar obtener los datos del concepto cobros indebidos',true);
		end;
		begin --buscamos el concepto haberes atrasados variables globales
			Select valor_numerico into v_valor_conc_cobros_indebidos From variable_global Where numero = 104;
		exception
		when no_data_found then
			raise_application_error(v$err,'No se encuentran datos del concepto cobros indebidos (104)',true);
		when others then
			raise_application_error(v$err,'Error al intentar obtener los datos del concepto cobros indebidos (104)',true);
		end;
		Begin --obtener el porcentaje maximo a descontar
			Select valor_numerico into v_porcentaje_max From variable_global Where numero = 113;
		exception
		when no_data_found then
			raise_application_error(v$err,'No se encuentran datos del porcentaje máximo a descontar (113)',true);
		when others then
			raise_application_error(v$err,'Error al intentar obtener los datos del datos del porcentaje máximo a descontar (113)',true);
		end;
		Begin --buscamos el concepto concepto permanente variables globales
			Select valor_numerico into v_valor_conc_pag_haber_atrazad From variable_global Where numero = 105;
		exception
		when no_data_found then
			raise_application_error(v$err,'No se encuentran datos del haberes atrasados (105)',true);
		when others then
			raise_application_error(v$err,'Error al intentar obtener los datos del datos del concepto haberes atrasados (105)',true);
      end;
    begin
			Select valor into v_monto_maximo From variable_global Where numero = 114;
		exception
		when no_data_found then
			v_monto_maximo:=0;
		when others then
			raise_application_error(v$err,'Error al intentar obtener los datos del monto máximo a pagar',true);
		end;
		if (v_jornal_minimo=0 or v_salario_minimo=0) Then
			v_dias_jornal:=0;
		else
			v_dias_jornal:=(v_salario_minimo / v_jornal_minimo);
		end if;
		---fin preparación de datos para el calculo
    Begin
      v_id_carga_archivo:=busca_clave_id;
      INSERT INTO CARGA_ARCHIVO (ID, VERSION, CODIGO, CLASE, ARCHIVO, ADJUNTO,
                                NUMERO_SIME, FECHA_HORA, ARCHIVO_SIN_ERRORES, PROCESO_SIN_ERRORES, OBSERVACIONES)
      VALUES (v_id_carga_archivo, 0, v_id_carga_archivo, (Select id From clase_archivo Where tipo=34 And rownum=1), 'N/A', null,
              null, sysdate,null, null, 'Corrida nómina clase pensión:' || v_nombre_clase_pension || ', mes:' || x$mes || ', año:' || x$ano); --tipo archivo=34 Log nomina
    exception
    When others then
      raise_application_error(v$err,'Error al intentar insertar la carga del registro de log corrida nómina, mensaje:'|| sqlerrm, true);
    End;
		v_id_personaant:=0;
		For reg in (Select pe.id as idpersona, pe.codigo || ': ' || pe.nombre as persona, pn.id as idpension, cl.nombre as npension, pe.cuenta_bancaria,
                      tc.numero as tipo_concepto, cc.id as idclase, to_number(cc.codigo) as codigoclase, 'true' as general, cl.requiere_saldo,
                      nvl(cp.monto,0) as monto, nvl(cp.porcentaje, 0) as porcentaje, nvl(cp.jornales,0) as jornales,
                      null as limite, 0 as acumulado, null as desde, null as hasta, to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/rrrr') as fecha_pago,
                      'true' as cumple_periodo,
                      case when round(to_number(to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/yyyy')-pe.fecha_nacimiento)/365,0)=18 And pe.objecion_menor='true' then
                        case when to_char(pe.fecha_nacimiento,'mm')=pr.mes then round(((to_number(to_char(pe.fecha_nacimiento,'dd'))-to_number(to_char(to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/yyyy'),'dd')))*100)/30,2)
                        else 100
                        end 
                      else 100  
                      end as porce_edad, cp.id as idclase_conceptopension, cp.metodo, pe2.salario, pe2.porcentaje as porcentaje_salario,
                      (Select max(sh.monto) From salario_historico sh inner join pension pn2 on sh.clase_pension=pn2.clase 
                        Where pn2.persona=pe2.id And sh.clase_concepto=1 And sh.fecha_hasta is null 
                        And (sh.fecha_nacimiento>pe.fecha_nacimiento or sh.fecha_nacimiento is null)
                        And pn2.id in (Select max(pn3.id) From pension pn3 Where pn3.persona = pe2.id)) as salario_historico,1 as cant_recurrente, 
                      (Select pn2.id From pension pn2 Where pn2.persona=pe2.id And pn2.id in (Select max(pn3.id) From pension pn3 Where pn3.persona = pe2.id)) as pensioncausante, 
                      (Select pn2.monto_exceso From pension pn2 Where pn2.persona=pe2.id And pn2.id in (Select max(pn3.id) From pension pn3 Where pn3.persona = pe2.id)) as monto_exceso 
              From planilla_pago pp inner join planilla_periodo_pago pr on pp.id = pr.planilla
                inner join concepto_planilla_pago cp on pp.id = cp.planilla
                inner join clase_pension cl on pp.clase_pension = cl.id
                inner join pension pn on cl.id = pn.clase
                inner join persona pe on pn.persona = pe.id
                inner join clase_concepto cc on cp.clase_concepto = cc.id
                inner join tipo_concepto tc on cc.tipo_concepto = tc.numero
                left outer join persona pe2 on pn.causante = pe2.id
                left outer join pension pn2 on pe2.id = pn2.persona And pn2.estado in (7,9)
              Where pp.id = v_id_planilla_pago
                And pr.mes = x$mes And pr.ano = x$ano And cp.general='true'
                And pn.activa='true' And pn.estado=7 And nvl(trunc(pn.fecha_dictamen_otorgar),to_date('01-01-1900','dd/mm/yyyy'))<=last_day(to_date('01/' || x$mes || '/' || x$ano,'dd/mm/yyyy'))
                And not exists (Select op.pension From objecion_pension op Where op.pension=pn.id And OBJECION_INVALIDA='true')
                And not exists (Select rp.pension From resumen_pago_pension rp Where rp.planilla=pp.id And rp.pension=pn.id And rp.detalle_orden_pago is not null And rp.mes_resumen=x$mes And rp.ano_resumen=x$ano)
              UNION
              Select pe.id as idpersona, pe.codigo || ': ' || pe.nombre as persona, pn.id as idpension, cl.nombre as npension, pe.cuenta_bancaria,
      					tc.numero as tipo_concepto, cc.id as idclase, to_number(cc.codigo) as codigoclase, 'false' as general, cl.requiere_saldo,
                nvl(ce.monto,0) as monto, nvl(ce.porcentaje,0) as porcentaje, nvl(ce.jornales,0) as jornales, ce.limite, 
                nvl((Select sum(dp.monto) From resumen_pago_pension rp inner join detalle_pago_pension dp on rp.id = dp.resumen 
                      left outer join spnc2ap112.liquidacion_haberes lh on rp.pension = lh.pension 
                      Where rp.pension = pn.id And dp.clase_concepto=cc.id),0) as acumulado, 
                ce.desde, ce.hasta, to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/rrrr') as fecha_pago,
                case when (ce.desde is null or ce.hasta is null) And cc.codigo=v_valor_conc_permanente then 'true'
                when (ce.desde is null or ce.hasta is null) And cc.codigo<>v_valor_conc_permanente And tc.numero=1 then 'false'
                when (ce.desde is null or ce.hasta is null) And tc.numero=2 then 'true' --deducciones no validamos en la ausencia de periodo
                else
                  case when to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/rrrr') between ce.desde And ce.hasta then 'true' else 'false' end
								end as cumple_periodo,
                case when round(to_number(to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/yyyy')-pe.fecha_nacimiento)/365,0)=18  And pe.objecion_menor='true' then
                  case when to_char(pe.fecha_nacimiento,'mm')=pr.mes then round(((to_number(to_char(pe.fecha_nacimiento,'dd'))-to_number(to_char(to_date('01/' || pr.mes || '/' || pr.ano,'dd/mm/yyyy'),'dd')))*100)/30,2)
                  else 100
                  end 
                else 100  
                end  as porce_edad, cp.id as idclase_conceptopension, cp.metodo, pe2.salario, pe2.porcentaje as porcentaje_salario,
                (Select max(sh.monto) From salario_historico sh inner join pension pn2 on sh.clase_pension=pn2.clase 
                  Where pn2.persona=pe2.id And sh.clase_concepto=1 And sh.fecha_hasta is null 
                  And (sh.fecha_nacimiento>pe.fecha_nacimiento or sh.fecha_nacimiento is null)
                  And pn2.id in (Select max(pn3.id) From pension pn3 Where pn3.persona = pe2.id)) as salario_historico, 
                  nvl(ce.cant_recurrente,1) as cant_recurrente,
                  (Select pn2.id From pension pn2 Where pn2.persona=pe2.id And pn2.id in (Select max(pn3.id) From pension pn3 Where pn3.persona = pe2.id)) as pensioncausante,
                  (Select pn2.monto_exceso From pension pn2 Where pn2.persona=pe2.id And pn2.id in (Select max(pn3.id) From pension pn3 Where pn3.persona = pe2.id)) as monto_exceso
              From planilla_pago pp inner join planilla_periodo_pago pr on pp.id = pr.planilla
                inner join concepto_planilla_pago cp on pp.id = cp.planilla
                inner join clase_pension cl on pp.clase_pension = cl.id
                inner join pension pn on cl.id = pn.clase
                inner join persona pe on pn.persona = pe.id
                inner join clase_concepto cc on cp.clase_concepto = cc.id
                inner join tipo_concepto tc on cc.tipo_concepto = tc.numero
                inner join concepto_pension ce on pn.id = ce.pension And cp.id=ce.clase And ce.bloqueado<>'true'
                left outer join persona pe2 on pn.causante = pe2.id
              Where pp.id = v_id_planilla_pago
                And pr.mes = x$mes And pr.ano = x$ano And cp.general='false'
                And pn.activa='true' And pn.estado=7 And nvl(trunc(pn.fecha_dictamen_otorgar),to_date('01-01-1900','dd/mm/yyyy'))<=last_day(to_date('01/' || x$mes || '/' || x$ano,'dd/mm/yyyy'))
                And not exists (select op.pension From objecion_pension op Where op.pension=pn.id And OBJECION_INVALIDA='true')
                And not exists (Select rp.pension From resumen_pago_pension rp Where rp.pension=pn.id And rp.planilla=pp.id And rp.detalle_orden_pago is not null And rp.mes_resumen=x$mes And rp.ano_resumen=x$ano)
              Order by persona, cumple_periodo desc, codigoclase ) --ordenado por persona, primero los que cumplen periodo y primero los conceptos asignados y luego las deducciones
		loop
			v_monto_detalle := 0;
			if reg.idpersona<>v_id_personaant then --NUEVA PERSONA: insertamos en el resumen_pago_pension
				if id_resumen is not null And v_monto_resumen<> 0 then --cuando cambia de persona totaliza el resumen anterior
					update resumen_pago_pension set monto = v_monto_resumen where id = id_resumen;
        end if;
				if reg.cumple_periodo='true' Then
					begin
						id_resumen := busca_clave_id;
						Insert into resumen_pago_pension(id, version, codigo, nombre, pension, nombre_pension,
                                            planilla, mes_resumen, ano_resumen, monto, cuenta_bancaria, orden)
						values (id_resumen, 0, id_resumen, reg.persona, reg.idpension, reg.npension,
									v_id_planilla_pago, x$mes, x$ano, 0, reg.cuenta_bancaria, v_orden_resumen);
					exception
					when others then
						raise_application_error(v$err,'Error al intentar crear el registro de resumen de pago, persona:' || reg.persona || ', pensión:' || reg.npension || ', fecha:' || reg.fecha_pago || ', monto resúmen:' || v_monto_resumen || ', mensaje:'|| sqlerrm, true);
					End;
        else
          id_resumen:=null;
				end if;
        v_monto_resumen:=0; v_monto_concepto_perma:=0; v_orden_resumen:=v_orden_resumen+1;
			end if;
			if reg.cumple_periodo='true' Then
				if reg.codigoclase = v_valor_conc_cobros_indebidos then
          if reg.acumulado < reg.monto then
            if reg.monto>v_monto_concepto_perma then
              v_monto_detalle := v_monto_concepto_perma;
            else
              v_monto_detalle :=reg.monto;
            end if;
            begin
              Select id, pension 
                into v_id_acuerdo_pago, v$pension_causante 
              From acuerdo_pago Where (persona=reg.idpersona or pension=reg.pensioncausante);
            exception
            when no_data_found then
              v_id_acuerdo_pago:=null; v$pension_causante:=null;
            when others then
              v_id_acuerdo_pago:=null; v$pension_causante:=null;
            end;
            if v_id_acuerdo_pago is null then
              begin
                v_id_acuerdo_pago:=busca_clave_id;
                if reg.pensioncausante is not null And v$pension_causante is null then
                  v$pension_causante:=reg.pensioncausante;
                end if;
                Insert Into acuerdo_pago (ID, VERSION, CODIGO, PERSONA, PENSION, FECHA, MONTO, CUOTA, SALDO)
                values (v_id_acuerdo_pago, 0, v_id_acuerdo_pago, reg.idpersona, v$pension_causante, reg.fecha_pago, reg.monto_exceso, null, null);
              exception
              when others then
                v_id_acuerdo_pago:=null;
                raise_application_error(v$err,'Error al intentar crear el registro de acuerdo de pago, persona:' || reg.persona || ', pensión:' || v$pension_causante || ', fecha:' || reg.fecha_pago || ', monto resúmen:' || v_monto_resumen || ', mensaje:'|| sqlerrm, true);
              end;
            end if;
            if v_id_acuerdo_pago is not null And v_monto_detalle>0 then
              begin
                Delete pago_acuerdo_pension where pension=reg.pensioncausante And FECHA=reg.fecha_pago And BOLETA=v_codigo_clase_pension || ':' || x$mes || '-' || x$ano;
                v_id_pago_acuerdo_pension:=busca_clave_id;
                Insert Into pago_acuerdo_pension (ID, VERSION, CODIGO, acuerdo_pago, PENSION, FECHA, MONTO, BOLETA)
                values (v_id_pago_acuerdo_pension, 0, v_id_pago_acuerdo_pension, v_id_acuerdo_pago, v$pension_causante, reg.fecha_pago, v_monto_detalle, v_codigo_clase_pension || ':' || x$mes || '-' || x$ano);
              exception
              when others then
                raise_application_error(v$err,'Error al intentar crear el registro de acuerdo de pago, persona:' || reg.persona || ', pensión:' || reg.npension || ', fecha:' || reg.fecha_pago || ', monto:' || v_monto_detalle || ', mensaje:'|| sqlerrm, true);
              end;
            end if;
          else
            v_monto_detalle:=0;
          end if;
				elsif reg.codigoclase = v_valor_conc_pag_haber_atrazad then
          if (reg.monto) > v_monto_maximo then
            v_monto_detalle:=v_monto_maximo;
          else
            v_monto_detalle:=reg.monto;
          end if;
				elsif reg.porcentaje > 0 then
          if reg.metodo=3 then
            v_monto_detalle:= trunc(((reg.porcentaje * v_salario_minimo) / 100)/reg.cant_recurrente,0);
          elsif reg.metodo=4 then
            v_monto_detalle:= trunc(((reg.porcentaje * reg.salario_historico) / 100)/reg.cant_recurrente,0);
          end if;
				elsif reg.jornales > 0 And reg.metodo=2 then
					v_monto_detalle := trunc((reg.jornales * v_jornal_minimo)/reg.cant_recurrente,0);
        elsif reg.metodo=1 then
         	v_monto_detalle:=reg.monto;
        else
          v_monto_detalle:=0;
				end if;
			end if; --fin if cumple periodo
			if v_monto_detalle > 0 And id_resumen is not null then
				begin
          if reg.porce_edad<>100 And nvl(reg.porce_edad,0)>0 then --un menor de edad cumplio 18 años en el periodo de calculo de planilla
            v_monto_detalle:=round(v_monto_detalle*reg.porce_edad/100,2);
            Begin
              v_id_linea_archivo:=busca_clave_id;
              contador:=contador+1;
              INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
              VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, 'AVISO: se ha abonado un ' || reg.porce_edad || '% del monto correspondiente a la pension:' || reg.idpension || ', pensionado:' || reg.persona, '');
            exception
            when others then
              raise_application_error(v$err,'Error al intentar insertar la línea (' || contador || ') del log de nómina, mensaje:'|| sqlerrm, true);
            End;
          end if;
					insert into detalle_pago_pension(id, version, nombre, resumen, clase_concepto, nombre_pension, activo,
               					                   mes_planilla, ano_planilla, monto, saldo, desde, hasta, cuenta, limite)
					values (busca_clave_id, 0, substr(reg.persona,1,200), id_resumen, reg.idclase, substr(reg.npension,1,200), 'true', 
                  x$mes, x$ano, v_monto_detalle, 0, reg.fecha_pago, last_day(reg.fecha_pago), null, reg.limite); 
          if reg.general='false' And reg.codigoclase = v_valor_conc_pag_haber_atrazad then --reg.cuenta_bancaria
            update concepto_pension set monto_acumulado=nvl((Select sum(b.monto)
                                                        From resumen_pago_pension a inner join detalle_pago_pension b on a.id = b.resumen
                                                        Where a.planilla=v_id_planilla_pago And a.pension=reg.idpension And b.CLASE_CONCEPTO=reg.idclase
                                                          And to_date('01/' || b.mes_planilla || '/' || b.ano_planilla,'dd/mm/yyyy')<=to_date('01/' || x$mes || '/' || x$ano,'dd/mm/yyyy')),0),
                                        saldo_actual=saldo_inicial-nvl((Select sum(b.monto)
                                                        From resumen_pago_pension a inner join detalle_pago_pension b on a.id = b.resumen
                                                        Where a.planilla=v_id_planilla_pago And a.pension=reg.idpension And b.CLASE_CONCEPTO=reg.idclase
                                                          And b.ano_planilla=x$ano),0)
            Where pension=reg.idpension And clase=reg.idclase_conceptopension;
          end if;
				exception
				when others then
					raise_application_error(v$err,'Error al intentar crear el registro de detalle de pago, persona:' || reg.persona || ', pensión:' || reg.npension || ', fecha:' || reg.fecha_pago || ', monto detalle:' || v_monto_detalle || ', mensaje:'|| sqlerrm, true);
				End;
			end if;
      if (reg.tipo_concepto=1) Then --asignacion
				v_monto_resumen:=v_monto_resumen + v_monto_detalle;
        if reg.codigoclase=v_valor_conc_permanente Then --monto usado para el calculo del tope de deduccion de cobros indebidos
          v_monto_concepto_perma:=v_monto_concepto_perma +((v_monto_detalle*v_porcentaje_max) / 100);--+((reg.monto*v_porcentaje_max) / 100);
        else
          v_monto_concepto_perma:=v_monto_concepto_perma+v_monto_detalle;
				end if;
      else --deducciones
				v_monto_resumen:=v_monto_resumen - v_monto_detalle;
        v_monto_concepto_perma:=v_monto_concepto_perma-v_monto_detalle; --monto usado para el calculo del tope de deduccion de cobros indebidos
      end if;
			v_id_personaant:=reg.idpersona;
		end loop; --******************FIN CALCULO DE NOMINA********************************
		if id_resumen is not null And v_monto_resumen <>0 then --cuando cambia de persona totaliza el resumen anterior
      update resumen_pago_pension set monto = v_monto_resumen where id = id_resumen;
		end if;
		update planilla_periodo_pago set estado = 2 where id = v_id_planilla_periodo_pago;
    For reg in (Select pn.id, pn.estado, pn.activa, pe.codigo as cisolicitante,
                      dp.monto as montopensionsolicitante, max(dp2.monto) as montopensioncausante,
                      pe2.codigo as cicausante, 
                    (Select sum(dp3.monto)
                    From pension pn3 inner join resumen_pago_pension rp3 on pn3.id = rp3.pension
                      inner join detalle_pago_pension dp3 on rp3.id = dp3.resumen
                      inner join clase_concepto co3 on dp3.clase_concepto = co3.id And co3.codigo=1
                    Where pn3.causante = pe2.id And rp3.mes_resumen=x$mes And rp3.ano_resumen=x$ano) as montototal
                From pension pn inner join persona pe on pn.persona = pe.id
                  inner join resumen_pago_pension rp on pn.id = rp.pension And rp.mes_resumen=x$mes And rp.ano_resumen=x$ano
                  inner join detalle_pago_pension dp on rp.id = dp.resumen
                  inner join clase_concepto co on dp.clase_concepto = co.id And co.codigo=v_valor_conc_permanente
                  inner join persona pe2 on pn.causante = pe2.id
                  inner join pension pn2 on pe2.id = pn2.persona And pn2.estado in (7,10)
                  inner join resumen_pago_pension rp2 on pn2.id = rp2.pension
                  inner join detalle_pago_pension dp2 on rp2.id = dp2.resumen
                  inner join clase_concepto co2 on dp2.clase_concepto = co2.id And co2.codigo=v_valor_conc_permanente
                Where pn.estado =7 And pn.activa='true' And pn.clase=x$clase_pension
                  And not exists (select op.pension from objecion_pension op Where op.pension=pn.id And OBJECION_INVALIDA='true')
                Group By pn.id, pn.estado, pn.activa, pe.codigo, dp.monto, pe2.codigo, pe2.id
                Order by cicausante) loop
      if reg.montototal>reg.montopensionsolicitante then
        Begin
          v_id_linea_archivo:=busca_clave_id;
          contador:=contador+1;
          INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
          VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, 'ERROR: el total de permanentes (' || reg.montototal ||') vinculados a la pensión del causante CI:' || reg.cicausante || ', supera su monto mayor asignado:' || reg.montopensioncausante ||'). Pensionado: ' || reg.cisolicitante || ', monto permante por asignar:' || reg.montopensionsolicitante, '');
          Update detalle_pago_pension set monto=0 Where resumen in (Select rp.id From resumen_pago_pension rp Where pension=reg.id And rp.mes_resumen=x$mes And rp.ano_resumen=x$ano);
          Update resumen_pago_pension set monto=0 Where pension=reg.id And mes_resumen=x$mes And ano_resumen=x$ano;
        exception
        when others then
          raise_application_error(v$err,'Error al intentar insertar el log de nómina y/o actualizar el monto calculado, mensaje:'|| sqlerrm, true);
        End;
      end if;
    end loop;
	else
		raise_application_error(v$err,'Período cerrado.', true);
	end if;
  if contador>0 then
    Update CARGA_ARCHIVO set proceso_sin_errores='true', directorio=contador Where id=v_id_carga_archivo;
  else
    Delete CARGA_ARCHIVO Where id=v_id_carga_archivo;
  end if;
  return 0;
exception
	when others then
		err_num := SQLCODE;
		err_msg := SQLERRM;
		raise_application_error(v$err, 'Error al Calcular Planilla, mensaje:'|| sqlerrm, true);
end;
/
 