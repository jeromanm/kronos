create or replace function pension$ge_in_ex_csv$02791$biz(x$super number, x$clase number, x$anio_desde nvarchar2, x$anio_hasta nvarchar2, 
														x$mes_desde number, x$mes_hasta number, x$incluir varchar2, x$resumen varchar2) return number is
  v$err               constant number := -20000; -- an integer in the range -20000..-20999
  v$msg               nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$anio              number;
  v$mes               number:=x$mes_desde;
  v$anio_desde        number:=x$anio_desde;
  v$anio_hasta        number:=x$anio_hasta;
  v$mes_desde         number:=x$mes_desde;
  v$mes_hasta         number:=x$mes_hasta;
  v$mes_aux           number;
  v$anio_aux          number;
  v$id_tmp_inclusion  number;
  v$nombre_mes        varchar(20);
  v$existe_nomina     number;
  v$log rastro_proceso_temporal%ROWTYPE;
  contador            number:=0;
begin
  v$log := rastro_proceso_temporal$select();
  begin
    Delete From tmp_inclusion;
    Select to_char(sysdate,'yyyyy') into v$anio From dual;
  exception
  when others then
    v$msg := SQLERRM;
		raise_application_error(v$err,'Error al intentar obtener el año actual, mensaje:' || v$msg,true);
  end;
  commit work;
  rastro_proceso_temporal$revive(v$log);
  if (nvl(v$anio_desde,0)<2000 or v$anio_desde>v$anio) then
    raise_application_error(v$err,'Error: el valor del año desde no es válido, debe estar comprendido entre el año 2000 y el año actual.',true);
  end if;
  if (v$anio_hasta is null) then
    v$anio_hasta:=v$anio_desde;
  end if;
  if (v$anio_desde>v$anio_desde) then
    raise_application_error(v$err,'Error: el valor del año desde no es válido, no puede ser mayor al año hasta:' || v$anio_hasta,true);
  end if;
  if (v$mes_desde is null) then
    v$mes_desde:=1;
  end if;
  if (v$mes_desde<1 or v$mes_desde>12) then
    raise_application_error(v$err,'Error: el valor del mes desde no es válido, debe estar comprendido entre 1 y el 12 o dejar en blanco para procesar año completo.',true);
  end if;
  if (v$mes_hasta is null) then
    v$mes_hasta:=12;
  end if;
  if x$incluir='true' or x$incluir is null then --inclusiones
    For v$anio in v$anio_desde .. v$anio_hasta LOOP
      For v$mes in v$mes_desde .. v$mes_hasta LOOP
        if (v$mes>1) then
          v$mes_aux:=v$mes-1;
          v$anio_aux:=v$anio;
        else
          v$mes_aux:=12;
          v$anio_aux:=v$anio-1;
        end if;
        if (v$mes=1) then 
          v$nombre_mes:='Enero';
        elsif (v$mes=2) then 
          v$nombre_mes:='Febrero';
        elsif (v$mes=3) then 
          v$nombre_mes:='Marzo';
        elsif (v$mes=4) then 
          v$nombre_mes:='Abril';
        elsif (v$mes=5) then 
          v$nombre_mes:='Mayo';
        elsif (v$mes=6) then 
          v$nombre_mes:='Junio';
        elsif (v$mes=7) then 
          v$nombre_mes:='Julio';
        elsif (v$mes=8) then 
          v$nombre_mes:='Agosto';
        elsif (v$mes=9) then 
          v$nombre_mes:='Setiembre';
        elsif (v$mes=10) then 
          v$nombre_mes:='Octubre';
        elsif (v$mes=11) then 
          v$nombre_mes:='Noviembre';
        elsif (v$mes=12) then 
          v$nombre_mes:='Diciembre';
        else
          v$nombre_mes:='N/E';
        end if;
        if x$resumen='true' then
          For reg in (Select cp.codigo as codigo_concepto, cp.nombre as nombre_concepto, pe.indigena, 'Inclusion' as estado, 
                            dp.codigo as codigo_dpto, dp.nombre as nombre_dpto, dt.codigo as codigo_dtto, dt.nombre as nombre_dtto,
                            ba.codigo as codigo_barr, ba.nombre as nombre_barr, ta.codigo as tipo_area, sp.codigo as sexo_persona,
                            Count(distinct pn.id) as cantidad, Sum(rp.monto) as monto
                      From persona pe inner join pension pn on pe.id = pn.persona
                        inner join resumen_pago_pension rp on rp.pension = pn.id And rp.mes_resumen=v$mes And rp.ano_resumen=v$anio
                        inner join departamento dp on pe.departamento = dp.id
                        inner join distrito dt on pe.distrito = dt.id
                        inner join sexo_persona sp on pe.sexo = sp.numero
                        inner join clase_pension cp on pn.clase = cp.id
                        left outer join barrio ba on pe.barrio = ba.id
                        left outer join tipo_area ta on pe.tipo_area = ta.numero
                      Where (pn.clase=x$clase or x$clase is null)
                        And NOT Exists (Select rp.id
                                        From resumen_pago_pension rp2 
                                        Where rp2.pension = pn.id And to_date('01/' || rp2.mes_resumen || '/' || rp2.ano_resumen,'dd/mm/yyyy')<=to_date('01/' || to_char(v$mes_aux,'00') || '/' || v$anio_aux,'dd/mm/yyyy')) --nunca ha cobrado
                      Group By cp.codigo, cp.nombre, pe.indigena, dp.codigo, dp.nombre, dt.codigo, dt.nombre, ba.codigo, ba.nombre, ta.codigo, sp.codigo) loop
            begin
              v$id_tmp_inclusion:=busca_clave_id;
              Insert Into tmp_inclusion (ID, VERSION, CODIGO, CODIGO_CONCEPTO, NOMBRE_CONCEPTO, ESTADO, MES, ANIO, NOMBRE_MES,
                                        CODIGO_DPTO, NOMBRE_DPTO, CODIGO_DTTO, NOMBRE_DTTO, CODIGO_BARR, NOMBRE_BARR, TIPO_AREA,
                                        SEXO_PERSONA, CANTIDAD, MONTO, INDIGENA)
              Values (v$id_tmp_inclusion, 0, v$id_tmp_inclusion, reg.codigo_concepto, reg.nombre_concepto, reg.estado, v$mes, v$anio, v$nombre_mes,
                      reg.codigo_dpto, reg.nombre_dpto, reg.codigo_dtto, reg.nombre_dtto, reg.codigo_barr, reg.nombre_barr, reg.tipo_area,
                      reg.sexo_persona, reg.cantidad, reg.monto, reg.indigena);
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el registro temporal, mensaje:' || v$msg,true);
            end;
            contador:=contador+1;
            if contador>1000 then
              commit work;
              rastro_proceso_temporal$revive(v$log);
              contador:=0;
            end if;
          end loop;
          For reg in (Select cp.codigo as codigo_concepto, cp.nombre as nombre_concepto, pe.indigena, 'Reintegro' as estado, 
                            dp.codigo as codigo_dpto, dp.nombre as nombre_dpto, dt.codigo as codigo_dtto, dt.nombre as nombre_dtto,
                            ba.codigo as codigo_barr, ba.nombre as nombre_barr, ta.codigo as tipo_area, sp.codigo as sexo_persona,
                            Count(distinct pn.id) as cantidad, Sum(rp.monto) as monto
                      From persona pe inner join pension pn on pe.id = pn.persona
                        inner join resumen_pago_pension rp on rp.pension = pn.id And rp.mes_resumen=v$mes And rp.ano_resumen=v$anio
                        inner join departamento dp on pe.departamento = dp.id
                        inner join distrito dt on pe.distrito = dt.id
                        inner join sexo_persona sp on pe.sexo = sp.numero
                        inner join clase_pension cp on pn.clase = cp.id
                        left outer join barrio ba on pe.barrio = ba.id
                        left outer join tipo_area ta on pe.tipo_area = ta.numero
                        inner join reclamo_pension re on pn.id = re.pension And re.estado=5 And re.tipo=3 And to_char(re.fecha_transicion,'mm/yyyy')= trim(to_char(v$mes,'00') || '/' || v$anio)
                      Where (pn.clase=x$clase or x$clase is null)
                        And NOT Exists (Select rp.id
                                        From resumen_pago_pension rp2 inner join detalle_pago_pension dp2 on dp2.resumen = rp2.id And dp2.activo='true'
                                        Where rp2.pension = pn.id And rp2.mes_resumen=v$mes_aux And rp2.ano_resumen=v$anio_aux)
                        And Exists (Select rp.id
                                  From resumen_pago_pension rp2 
                                  Where rp2.pension = pn.id And to_date('01/' || rp2.mes_resumen || '/' || rp2.ano_resumen,'dd/mm/yyyy')<to_date('01/' || to_char(v$mes_aux,'00') || '/' || v$anio_aux,'dd/mm/yyyy')) --alguna vez cobro
                      Group By cp.codigo, cp.nombre, pe.indigena, dp.codigo, dp.nombre, dt.codigo, dt.nombre, ba.codigo, ba.nombre, ta.codigo, sp.codigo) loop
            begin
              v$id_tmp_inclusion:=busca_clave_id;
              Insert Into tmp_inclusion (ID, VERSION, CODIGO, CODIGO_CONCEPTO, NOMBRE_CONCEPTO, ESTADO, MES, ANIO, NOMBRE_MES,
                                        CODIGO_DPTO, NOMBRE_DPTO, CODIGO_DTTO, NOMBRE_DTTO, CODIGO_BARR, NOMBRE_BARR, TIPO_AREA,
                                        SEXO_PERSONA, CANTIDAD, MONTO, INDIGENA)
              Values (v$id_tmp_inclusion, 0, v$id_tmp_inclusion, reg.codigo_concepto, reg.nombre_concepto, reg.estado, v$mes, v$anio, v$nombre_mes,
                      reg.codigo_dpto, reg.nombre_dpto, reg.codigo_dtto, reg.nombre_dtto, reg.codigo_barr, reg.nombre_barr, reg.tipo_area,
                      reg.sexo_persona, reg.cantidad, reg.monto, reg.indigena);
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el registro temporal, mensaje:' || v$msg,true);
            end;
            contador:=contador+1;
            if contador>1000 then
              commit work;
              rastro_proceso_temporal$revive(v$log);
              contador:=0;
            end if;
          end loop;
        else --detallado por persona
          For reg in (Select pe.id as id_persona, pe.codigo as cedula, pe.nombre as nombre_persona, cp.codigo as codigo_concepto, 
                             cp.nombre as nombre_concepto, pe.indigena, 'Inclusion' as estado, 1 as cantidad, rp.monto,
                             dp.codigo as codigo_dpto, dp.nombre as nombre_dpto, dt.codigo as codigo_dtto, dt.nombre as nombre_dtto,
                             ba.codigo as codigo_barr, ba.nombre as nombre_barr, ta.codigo as tipo_area, sp.codigo as sexo_persona
                      From persona pe inner join pension pn on pe.id = pn.persona
                        inner join resumen_pago_pension rp on rp.pension = pn.id And rp.mes_resumen=v$mes And rp.ano_resumen=v$anio
                        inner join departamento dp on pe.departamento = dp.id
                        inner join distrito dt on pe.distrito = dt.id
                        inner join sexo_persona sp on pe.sexo = sp.numero
                        inner join clase_pension cp on pn.clase = cp.id
                        left outer join barrio ba on pe.barrio = ba.id
                        left outer join tipo_area ta on pe.tipo_area = ta.numero
                      Where (pn.clase=x$clase or x$clase is null)
                        And NOT Exists (Select rp.id
                                        From resumen_pago_pension rp2 
                                        Where rp2.pension = pn.id And to_date('01/' || rp2.mes_resumen || '/' || rp2.ano_resumen,'dd/mm/yyyy')<=to_date('01/' || to_char(v$mes_aux,'00') || '/' || v$anio_aux,'dd/mm/yyyy')) --nunca ha cobrado

                    ) loop
            begin
              v$id_tmp_inclusion:=busca_clave_id;
              Insert Into tmp_inclusion (ID, VERSION, CODIGO, CODIGO_CONCEPTO, NOMBRE_CONCEPTO, ESTADO, MES, ANIO, NOMBRE_MES,
                                        CODIGO_DPTO, NOMBRE_DPTO, CODIGO_DTTO, NOMBRE_DTTO, CODIGO_BARR, NOMBRE_BARR, TIPO_AREA,
                                        SEXO_PERSONA, CANTIDAD, MONTO, INDIGENA, PERSONA, CEDULA, NOMBRE_PERSONA)
              Values (v$id_tmp_inclusion, 0, v$id_tmp_inclusion, reg.codigo_concepto, reg.nombre_concepto, reg.estado, v$mes, v$anio, v$nombre_mes,
                      reg.codigo_dpto, reg.nombre_dpto, reg.codigo_dtto, reg.nombre_dtto, reg.codigo_barr, reg.nombre_barr, reg.tipo_area,
                      reg.sexo_persona, reg.cantidad, reg.monto, reg.indigena, reg.id_persona, reg.cedula, reg.nombre_persona);
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el registro temporal detallado, mensaje:' || v$msg,true);
            end;
            contador:=contador+1;
            if contador>1000 then
              commit work;
              rastro_proceso_temporal$revive(v$log);
              contador:=0;
            end if;
          end loop;
          For reg in (Select pe.id as id_persona, pe.codigo as cedula, pe.nombre as nombre_persona, cp.codigo as codigo_concepto, 
                             cp.nombre as nombre_concepto, pe.indigena, 'Reintegro' as estado, 1 as cantidad, rp.monto,
                             dp.codigo as codigo_dpto, dp.nombre as nombre_dpto, dt.codigo as codigo_dtto, dt.nombre as nombre_dtto,
                             ba.codigo as codigo_barr, ba.nombre as nombre_barr, ta.codigo as tipo_area, sp.codigo as sexo_persona
                      From persona pe inner join pension pn on pe.id = pn.persona
                        inner join resumen_pago_pension rp on rp.pension = pn.id And rp.mes_resumen=v$mes And rp.ano_resumen=v$anio
                        inner join departamento dp on pe.departamento = dp.id
                        inner join distrito dt on pe.distrito = dt.id
                        inner join sexo_persona sp on pe.sexo = sp.numero
                        inner join clase_pension cp on pn.clase = cp.id
                        left outer join barrio ba on pe.barrio = ba.id
                        left outer join tipo_area ta on pe.tipo_area = ta.numero
                        inner join reclamo_pension re on pn.id = re.pension And re.estado=5 And re.tipo=3 And to_char(re.fecha_transicion,'mm/yyyy')= trim(to_char(v$mes,'00') || '/' || v$anio)
                      Where (pn.clase=x$clase or x$clase is null)
                        And NOT Exists (Select rp.id
                                        From resumen_pago_pension rp2 inner join detalle_pago_pension dp2 on dp2.resumen = rp2.id And dp2.activo='true'
                                        Where rp2.pension = pn.id And rp2.mes_resumen=v$mes_aux And rp2.ano_resumen=v$anio_aux)
                        And Exists (Select rp.id
                                  From resumen_pago_pension rp2 
                                  Where rp2.pension = pn.id And to_date('01/' || rp2.mes_resumen || '/' || rp2.ano_resumen,'dd/mm/yyyy')<to_date('01/' || to_char(v$mes_aux,'00') || '/' || v$anio_aux,'dd/mm/yyyy')) --alguna vez cobro
                      ) loop
            begin
              v$id_tmp_inclusion:=busca_clave_id;
              Insert Into tmp_inclusion (ID, VERSION, CODIGO, CODIGO_CONCEPTO, NOMBRE_CONCEPTO, ESTADO, MES, ANIO, NOMBRE_MES,
                                        CODIGO_DPTO, NOMBRE_DPTO, CODIGO_DTTO, NOMBRE_DTTO, CODIGO_BARR, NOMBRE_BARR, TIPO_AREA,
                                        SEXO_PERSONA, CANTIDAD, MONTO, INDIGENA)
              Values (v$id_tmp_inclusion, 0, v$id_tmp_inclusion, reg.codigo_concepto, reg.nombre_concepto, reg.estado, v$mes, v$anio, v$nombre_mes,
                      reg.codigo_dpto, reg.nombre_dpto, reg.codigo_dtto, reg.nombre_dtto, reg.codigo_barr, reg.nombre_barr, reg.tipo_area,
                      reg.sexo_persona, reg.cantidad, reg.monto, reg.indigena);
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el registro temporal, mensaje:' || v$msg,true);
            end;
            contador:=contador+1;
            if contador>1000 then
              commit work;
              rastro_proceso_temporal$revive(v$log);
              contador:=0;
            end if;
          end loop;
        end if;
      end loop;
    end loop;
  end if;
  contador:=0;
  if x$incluir='false' or x$incluir is null then --inclusiones
    For v$anio in v$anio_desde .. v$anio_hasta LOOP
      For v$mes in v$mes_desde .. v$mes_hasta LOOP
        if (v$mes>1) then
          v$mes_aux:=v$mes-1;
          v$anio_aux:=v$anio;
        else
          v$mes_aux:=12;
          v$anio_aux:=v$anio-1;
        end if; 
        Select Count(rp.id) into v$existe_nomina
        From planilla_pago pp inner join planilla_periodo_pago pl on pp.id = pl.planilla
          inner join resumen_pago_pension rp on rp.planilla = pp.id And rp.mes_resumen=v$mes And rp.ano_resumen=v$anio
        Where (pp.clase_pension=x$clase or x$clase is null) 
          And pl.mes=v$mes And pl.ano=v$anio And pl.estado=3;
        if (v$existe_nomina=0) then 
          exit;
        end if;
        if (v$mes=1) then 
          v$nombre_mes:='Enero';
        elsif (v$mes=2) then 
          v$nombre_mes:='Febrero';
        elsif (v$mes=3) then 
          v$nombre_mes:='Marzo';
        elsif (v$mes=4) then 
          v$nombre_mes:='Abril';
        elsif (v$mes=5) then 
          v$nombre_mes:='Mayo';
        elsif (v$mes=6) then 
          v$nombre_mes:='Junio';
        elsif (v$mes=7) then 
          v$nombre_mes:='Julio';
        elsif (v$mes=8) then 
          v$nombre_mes:='Agosto';
        elsif (v$mes=9) then 
          v$nombre_mes:='Setiembre';
        elsif (v$mes=10) then 
          v$nombre_mes:='Octubre';
        elsif (v$mes=11) then 
          v$nombre_mes:='Noviembre';
        elsif (v$mes=12) then 
          v$nombre_mes:='Diciembre';
        else
          v$nombre_mes:='N/E';
        end if;
        if x$resumen='true' then
          For reg in (Select cp.codigo as codigo_concepto, cp.nombre as nombre_concepto, pe.indigena, 
                            'Exclusion' as estado, 
                            dp.codigo as codigo_dpto, dp.nombre as nombre_dpto, dt.codigo as codigo_dtto, dt.nombre as nombre_dtto,
                            ba.codigo as codigo_barr, ba.nombre as nombre_barr, ta.codigo as tipo_area, sp.codigo as sexo_persona,
                            Count(distinct pn.id) as cantidad, Sum(rp.monto) as monto
                      From persona pe inner join pension pn on pe.id = pn.persona
                        inner join resumen_pago_pension rp on rp.pension = pn.id And rp.mes_resumen=v$mes_aux And rp.ano_resumen=v$anio_aux
                        inner join departamento dp on pe.departamento = dp.id
                        inner join distrito dt on pe.distrito = dt.id
                        inner join sexo_persona sp on pe.sexo = sp.numero
                        inner join clase_pension cp on pn.clase = cp.id
                        left outer join barrio ba on pe.barrio = ba.id
                        left outer join tipo_area ta on pe.tipo_area = ta.numero
                      Where (pn.clase=x$clase or x$clase is null)
                        And NOT Exists (Select rp.id
                                        From resumen_pago_pension rp2 inner join detalle_pago_pension dp2 on dp2.resumen = rp2.id And dp2.activo='true'
                                        Where rp2.pension = pn.id And rp2.mes_resumen=v$mes And rp2.ano_resumen=v$anio)
                        And Exists (Select dp2.id
                                    From detalle_pago_pension dp2
                                    Where dp2.resumen = rp.id And dp2.activo='true')
                      Group By cp.codigo, cp.nombre, pe.indigena, dp.codigo, dp.nombre, dt.codigo, dt.nombre, ba.codigo, ba.nombre, ta.codigo, sp.codigo) loop
            begin
              v$id_tmp_inclusion:=busca_clave_id;
              Insert Into tmp_inclusion (ID, VERSION, CODIGO, CODIGO_CONCEPTO, NOMBRE_CONCEPTO, ESTADO, MES, ANIO, NOMBRE_MES,
                                        CODIGO_DPTO, NOMBRE_DPTO, CODIGO_DTTO, NOMBRE_DTTO, CODIGO_BARR, NOMBRE_BARR, TIPO_AREA,
                                        SEXO_PERSONA, CANTIDAD, MONTO, INDIGENA)
              Values (v$id_tmp_inclusion, 0, v$id_tmp_inclusion, reg.codigo_concepto, reg.nombre_concepto, reg.estado, v$mes, v$anio, v$nombre_mes,
                      reg.codigo_dpto, reg.nombre_dpto, reg.codigo_dtto, reg.nombre_dtto, reg.codigo_barr, reg.nombre_barr, reg.tipo_area,
                      reg.sexo_persona, reg.cantidad, reg.monto, reg.indigena);
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el registro temporal, mensaje:' || v$msg,true);
            end;
            contador:=contador+1;
            if contador>1000 then
              commit work;
              rastro_proceso_temporal$revive(v$log);
              contador:=0;
            end if;
          end loop;
        else --detalle
          For reg in (Select pe.id as id_persona, pe.codigo as cedula, pe.nombre as nombre_persona, cp.codigo as codigo_concepto, 
                            cp.nombre as nombre_concepto, pe.indigena, 'Exclusion' as estado, 
                            dp.codigo as codigo_dpto, dp.nombre as nombre_dpto, dt.codigo as codigo_dtto, dt.nombre as nombre_dtto,
                            ba.codigo as codigo_barr, ba.nombre as nombre_barr, ta.codigo as tipo_area, sp.codigo as sexo_persona,
                            1 as cantidad, rp.monto
                      From persona pe inner join pension pn on pe.id = pn.persona
                        inner join resumen_pago_pension rp on rp.pension = pn.id And rp.mes_resumen=v$mes_aux And rp.ano_resumen=v$anio_aux
                        inner join departamento dp on pe.departamento = dp.id
                        inner join distrito dt on pe.distrito = dt.id
                        inner join sexo_persona sp on pe.sexo = sp.numero
                        inner join clase_pension cp on pn.clase = cp.id
                        left outer join barrio ba on pe.barrio = ba.id
                        left outer join tipo_area ta on pe.tipo_area = ta.numero
                      Where (pn.clase=x$clase or x$clase is null)
                        And NOT Exists (Select rp.id
                                        From resumen_pago_pension rp2 inner join detalle_pago_pension dp2 on dp2.resumen = rp2.id And dp2.activo='true'
                                        Where rp2.pension = pn.id And rp2.mes_resumen=v$mes And rp2.ano_resumen=v$anio)
                        And Exists (Select dp2.id
                                    From detalle_pago_pension dp2
                                    Where dp2.resumen = rp.id And dp2.activo='true')) loop
            begin
              v$id_tmp_inclusion:=busca_clave_id;
              Insert Into tmp_inclusion (ID, VERSION, CODIGO, CODIGO_CONCEPTO, NOMBRE_CONCEPTO, ESTADO, MES, ANIO, NOMBRE_MES,
                                        CODIGO_DPTO, NOMBRE_DPTO, CODIGO_DTTO, NOMBRE_DTTO, CODIGO_BARR, NOMBRE_BARR, TIPO_AREA,
                                        SEXO_PERSONA, CANTIDAD, MONTO, INDIGENA, PERSONA, CEDULA, NOMBRE_PERSONA)
              Values (v$id_tmp_inclusion, 0, v$id_tmp_inclusion, reg.codigo_concepto, reg.nombre_concepto, reg.estado, v$mes, v$anio, v$nombre_mes,
                      reg.codigo_dpto, reg.nombre_dpto, reg.codigo_dtto, reg.nombre_dtto, reg.codigo_barr, reg.nombre_barr, reg.tipo_area,
                      reg.sexo_persona, reg.cantidad, reg.monto, reg.indigena, reg.id_persona, reg.cedula, reg.nombre_persona);
            exception
            when others then
              v$msg := SQLERRM;
              raise_application_error(v$err,'Error al intentar crear el registro temporal detallado, mensaje:' || v$msg,true);
            end;
            contador:=contador+1;
            if contador>1000 then
              commit work;
              rastro_proceso_temporal$revive(v$log);
              contador:=0;
            end if;
          end loop;
        end if;
      end loop;
    end loop;
  end if;
  commit work;
  rastro_proceso_temporal$revive(v$log);
  return 0;
end;
/