create or replace function consulta_ciudadano$bix(x$new  in out consulta_ciudadano%ROWTYPE)
return consulta_ciudadano%ROWTYPE is
    v_codigo                  varchar2(30);
    v_dependencia             varchar2(200);
    v_fecha                   date;
    v_cant_dias               number;
    v_nro_expedientte         number;
    v_sime                    varchar2(12);
    v_cant                    number;
    v_situacion               varchar2(200);
    v_codigo_destino          varchar2(50);
    v_nombre_destino          varchar2(100);
    v_nombre_origen           varchar2(100);
    v_fecha_fin               date;
    v_cant_dias_sime          number;
    v_dias_sime               number;
    v_fecha_reclamo           date;
    v_exp_id                  number;
    v_estado                  varchar2(100);
    v$estado                  number;
    v_fecha_creacion          DATE;
    v_tipo_expediente         varchar2(200);
    v_ci_titular              varchar2(100);
    v_nombre_titular          varchar2(200);
    v_observaciones           varchar2(500);
    v_cod_dependencia_activo  varchar2(50);
    v_nom_dependencia_activo  varchar2(200);
    v_fecha_activo            DATE;
    v_cod_dependencia_origen  varchar2(50);
    v_nom_dependencia_origen  varchar2(200);
    v_cod_dependencia_destino varchar2(50);
    v_nom_dependencia_destino varchar2(200);
    v_fecha_salida            DATE;
    v_cod_dependencia_accion  VARCHAR2(50);
    v_nom_dependencia_accion  VARCHAR2(200);
    v_fecha_accion            DATE;
begin
    v_codigo := null;
    if x$new.reclamo is not null then
      begin
        Select  e.nro || '/' || e.ano, e.id, rp.fecha_transicion 
          into v_codigo, v_exp_id, v_fecha_reclamo
        From sgemh.expediente@sgemh e, reclamo_pension rp
        Where rp.id = x$new.reclamo
          And rp.numero_sime = e.id
          And e.original_id is null;
      exception
      when no_data_found then
        v_codigo := null;
      end;
    elsif x$new.tramite is not null then
      begin
        Select e.nro || '/' || e.ano, e.id, rp.fecha_transicion 
          into v_codigo, v_exp_id, v_fecha_reclamo
        From sgemh.expediente@sgemh e, tramite_administrativo rp
        Where rp.id = x$new.tramite
          And rp.numero_sime = e.id
          And e.original_id is null;
      exception
      when no_data_found then
        v_codigo := null;
      end;
    elsif x$new.pension is not null then
      begin
        Select  e.nro || '/' || e.ano, e.id, rp.fecha_transicion into v_codigo, v_exp_id, v_fecha_reclamo
        From sgemh.expediente@sgemh e, pension rp
        Where rp.id = x$new.pension
          And rp.numero_sime = e.id
          And e.original_id is null;
      exception
      When no_data_found then
        v_codigo := null;
      end;
    end if;
    if v_codigo is not null then -- Dependencia donde se encuentra actualmente el expediente
      SIME_UTIL.P_SITUACION_ACTUAL(v_codigo, v_estado, v_fecha_creacion, v_tipo_expediente, v_ci_titular, v_nombre_titular, v_observaciones, v_cod_dependencia_activo, v_nom_dependencia_activo, 
                                  v_fecha_activo, v_cod_dependencia_origen, v_nom_dependencia_origen, v_cod_dependencia_destino, v_nom_dependencia_destino, v_fecha_salida, v_cod_dependencia_accion,
                                  v_nom_dependencia_accion, v_fecha_accion);
    end if;
    if v_cod_dependencia_activo is not null then
      v_dependencia := v_cod_dependencia_activo || ' ' || v_nom_dependencia_activo;
    elsif v_cod_dependencia_accion is not null then
      v_dependencia := v_cod_dependencia_accion || ' ' || v_nom_dependencia_accion;
    end if;
    v_fecha := nvl(v_fecha_activo,v_fecha_accion); -- Fecha de dependencia
    if v_estado = 'ENVIO' then -- Situacion del expediente
      v_situacion := 'ORI:' || v_cod_dependencia_origen || ' ' || v_nom_dependencia_origen || '-DEST:' ||  v_cod_dependencia_destino || ' ' || v_nom_dependencia_destino;
    else
      v_situacion := v_estado || '-' || v_cod_dependencia_accion || ' ' || v_nom_dependencia_accion;
    end if;
    v_nombre_destino := v_nom_dependencia_destino; -- Destino
    if v_estado = 'ARCHIVADO' then -- Finiquitado
      v_fecha_fin := v_fecha_accion;
      v$estado:=2; --cerrado
    else
      v_fecha_fin := null;
      v$estado:=1; --abierto
    end if;
    if v_estado = 'ENVIO' then -- Cant dias en dependencia
      begin
        Select m.fecha into v_fecha_fin 
        From sgemh.movimiento@sgemh m
        Where m.expediente_id = v_exp_id
          And m.id = (select max(m1.id) from sgemh.movimiento@sgemh m1 where m1.expediente_id = v_exp_id);
        v_cant_dias := trunc(v_fecha_salida) -trunc(v_fecha_fin);
      exception
      when others then
        v_cant_dias := null;
      end;
      v$estado:=2; --cerrado
    elsif v_estado = 'ACTIVO' then
      v_cant_dias := trunc(sysdate)-trunc(v_fecha_activo);
      v$estado:=1; --abierto
    else
      v_cant_dias := trunc(sysdate) -trunc(v_fecha_accion);
      v$estado:=2; --cerrado
    end if;
    v_dias_sime := trunc(sysdate)-trunc(v_fecha_creacion); -- Dias SIME
    if v_fecha_reclamo is not null then --Dias transcurridos desde la creacion del reclamo/tramite administrativo/pension
      v_cant_dias_sime := trunc(sysdate) - trunc(v_fecha_reclamo);
    else
      v_cant_dias_sime := null;
    end if;
    if v_codigo is not null then
      begin -- Cantidad de consultas por un sime
        SELECT COUNT(numero_sime) INTO v_cant
        FROM consulta_ciudadano
        WHERE numero_sime= x$new.numero_sime;
      exception
      when no_data_found then
        v_cant:=0;
      end;
      if v_cant < 1 then
        v_cant := 1;
      else
        v_cant := v_cant +1;
      end if;
      x$new.dependencia := v_dependencia;
      x$new.dias_dependencia := v_cant_dias;
      x$new.fecha_dependencia := v_fecha;
      x$new.fecha_ultima_consulta := sysdate;
      x$new.cantidad_consultas := v_cant;
      x$new.situacion := v_situacion;
      x$new.destino := v_nombre_destino;
      x$new.estado := v$estado;
      x$new.fecha_finiquito := v_fecha_fin;
      x$new.dias_reclamo := v_cant_dias_sime;
      x$new.dias_sime := v_dias_sime;
    end if;
  return x$new;
end;
/