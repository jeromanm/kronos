create or replace function carga_arch$el_ar_cen$53167$biz(x$super number, x$clase number) return number is
    v$err                   constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                   nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$tipo_archivo          number;
    v$numero_sime           number;
    v_version_ficha_hogar   varchar2(20):= NULL;
    v$valor_icv             varchar2(20);
    v$tipo_pobreza          varchar2(20);
    v$id_ficha_persona      number;
begin --modificado SIAU 11885 y 12350
  begin
    Select b.tipo, a.numero_sime 
      into v$tipo_archivo, v$numero_sime
    From carga_archivo a inner join clase_archivo b on a.clase = b.id
    Where a.id=x$clase;
  exception
  WHEN NO_DATA_FOUND THEN
    v$tipo_archivo:=null;
  when others then
	  v$msg := SUBSTR(SQLERRM, 1, 2000);
    raise_application_error(v$err, 'Error al intentar obtener la clase de archivo, mensaje:' || v$msg, true);
  end;
  case
  when v$tipo_archivo=2 then --Defunciones
    begin
      update persona set certificado_defuncion=null, oficina_defuncion= null, fecha_acta_defuncion=null,
                         tomo_defuncion=null, folio_defuncion=null, acta_defuncion=null, fecha_defuncion=null,
                         fecha_certificado_defuncion=null, numero_sime_defuncion=null, departamentodef=null, distritodef=null,
                         lugar_nacimiento_def=null, fecha_nacimiento_defu=null, nacionalidad=null
      Where codigo in (Select cedula From defuncion Where archivo=x$clase);
      Delete From defuncion where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de defunciones, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=3 then --Matrimonios
    begin
      Update persona set fecha_matrimonio=null, nombre_conyuge=null, cedula_conyuge=null, folio_matrimonio=null, acta_matrimonio=null,
                         tomo_matrimonio=null, numero_sime_matrimonio=null
      Where codigo in (Select cedula1 From matrimonio Where archivo=x$clase
                       UNION
                       Select cedula2 From matrimonio Where archivo=x$clase);
      Delete From matrimonio where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de matimonio, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=4 then --Empleos
    begin
      update persona set NUMERO_SIME_EMP=null, FECHA_EGRESO_EMP=null, FECHA_INGRESO_EMP=null, MONTO_EMP=null, NOMBRE_EMPRESA_EMP=null
      Where codigo in (Select cedula From empleo Where archivo=x$clase);
      Delete From empleo where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de empleo, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=5 then --Jubilaciones
    begin
      Update persona set FECHA_INGRESO_JUBI=null, MONTO_JUBI=null, numero_sime_jubi=null, NOMBRE_EMPRESA=null, FECHA_EGRESO_JUBI=null
      Where codigo in (Select cedula From jubilacion Where archivo=x$clase);
      Delete From jubilacion where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de jubilación, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=6 then --Senacsa
    begin
      update persona set estancia=null, FECHA_INGRESO_SENACSA=null, FECHA_EGRESO_SENACSA=null, CANTIDAD_SENACSA=null,
                          TIPO_SENACSA=null, monto_senacsa=null,	NUMERO_SIME_SENACSA=null
      Where codigo in (Select cedula From senacsa Where archivo=x$clase);
      Delete From senacsa where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de Senacsa, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=1 or v$tipo_archivo=7 or v$tipo_archivo=31 or v$tipo_archivo=32 --Solicitudes, Censo x lote poblacion, Censo hogar persona historico, Censo x lote vivienda
       or v$tipo_archivo=23 or v$tipo_archivo=24 or v$tipo_archivo=25 or v$tipo_archivo=26 then --stp 
    if v$tipo_archivo=1 or v$tipo_archivo=31 or v$tipo_archivo=32 then --solicitudes o problacion por lote borra pensiones
      begin
        Delete From solicitud_pension where archivo = x$clase;
        Delete From solicitud_pension where censo_persona in (Select id From censo_persona Where ficha in (Select ficha From censo_persona Where archivo=x$clase));
        Delete From solicitud_pension where censo_persona in (Select id From censo_persona where ficha in (Select id From ficha_persona where ficha_hogar in (Select id From ficha_hogar Where archivo=x$clase)));
        Delete From transicion_pension where pension in (Select id From pension Where archivo = x$clase);
        Delete From objecion_pension where pension in (Select id From pension Where archivo = x$clase);
        Delete From requisito_pension where pension in (Select id From pension Where archivo = x$clase);
        Delete From consulta_ciudadano where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From consulta_ciudadano where pension in (Select id From pension where archivo=x$clase);
        Delete From consulta_ciudadano where pension in (Select id From pension where numero_sime_entrada=v$numero_sime);
        Update solicitud_pension set pension=null where pension in (Select id From pension Where archivo = x$clase) And archivo<>x$clase;
        Delete From pension Where archivo = x$clase;
        Delete From AUTOMOTOR where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From catastro where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From COTIZANTE where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From defuncion where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From empleo where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From ESTADO_CUENTA where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From residente_extranjero where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From jubilacion where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From matrimonio where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From nacimiento where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From NO_INDIGENA where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From proveedor where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From subsidio where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From senacsa where persona in (Select id From persona where numero_sime=v$numero_sime);
        Delete From denuncia_pension where archivo = x$clase;
      exception
      WHEN NO_DATA_FOUND THEN
        null;
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar eliminar los registros de pensiones y archivos relacionados, mensaje:' || v$msg, true);
      end;
    end if;
    For reg in (Select id, estado, ficha, persona From censo_persona where archivo=x$clase) loop
      begin
        Delete From reporte_campo where censo_persona=reg.id;
        Delete result_funcion_icv where censo_persona=reg.id;
        Delete censo_persona where id=reg.id;
        Delete From reporte_campo where censo_persona in (Select id From censo_persona where ficha=reg.ficha);
        Delete From result_funcion_icv where censo_persona in (Select id From censo_persona where ficha=reg.ficha);
        Delete censo_persona where ficha=reg.ficha;
      Exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar eliminar el registro de censo persona, mensaje:' || v$msg, true);
      End;
      begin
        v$valor_icv:=''; v$id_ficha_persona:=null;
        Select (Select case when cp.icv is null then 'pob:' || cp.tipo_pobreza else 'icv:' || cp.icv end 
                From censo_persona cp
                Where cp.persona = pe.id And cp.fecha=(Select max(cp2.fecha) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4) 
                  And cp.fecha_transicion=(Select max(cp2.fecha_transicion) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4)
                  And rownum=1 And cp.estado=4) as icv, 
                (Select cp.ficha 
                From censo_persona cp
                Where cp.persona = pe.id And cp.fecha=(Select max(cp2.fecha) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4) 
                  And cp.fecha_transicion=(Select max(cp2.fecha_transicion) From censo_persona cp2 Where cp2.persona = pe.id And cp2.estado=4)
                  And rownum=1 And cp.estado=4) as ficha
            into v$valor_icv, v$id_ficha_persona
        From persona pe 
        Where pe.id=reg.persona;
        if instr(v$valor_icv,'icv:')>0 then
          v$valor_icv:=substr(v$valor_icv,5);
          v$tipo_pobreza:=null;
        else
          v$valor_icv:=null;
          v$tipo_pobreza:=substr(v$valor_icv,5);
        end if;
        update PERSONA set icv=v$valor_icv, tipo_pobreza=v$tipo_pobreza, ficha=v$id_ficha_persona 
        Where id=reg.persona;
      Exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar actualizar el icv/tipo de probreza en persona, mensaje:' || v$msg, true);
      End;
      begin
        Delete RESPUESTA_FICHA_PERSONA Where ficha =reg.ficha;
        Delete documento Where ficha_x11=reg.ficha; --fotos
      Exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar eliminar las respuestas de la ficha persona, id persona:' || reg.persona || ', mensaje:' || v$msg, true);
      End;
      begin
        Update persona set ficha=null where ficha=reg.ficha;
        Delete result_funcion_icv where ficha_persona =reg.ficha;
  			Delete ficha_persona where id=reg.ficha;
      Exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar eliminar la ficha persona, id persona:' || reg.persona || ', mensaje:' || v$msg, true);
      End;
    end loop;
    For reg in (Select id, estado From ficha_hogar where archivo=x$clase) loop
      begin
        Update persona set ficha=null where ficha in (Select id From ficha_persona where ficha_hogar=reg.id);
        Delete reporte_campo where censo_persona in (Select id From censo_persona where ficha in (Select id From ficha_persona where ficha_hogar=reg.id));
        Delete result_funcion_icv where censo_persona in (Select id From censo_persona where ficha in (Select id From ficha_persona where ficha_hogar=reg.id));
        Delete censo_persona where ficha in (Select id From ficha_persona where ficha_hogar=reg.id);
      Exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar eliminar los censos asociados al hogar id:' || reg.id || ', mensaje:' || v$msg, true);
      End;
      begin
        delete respuesta_ficha_persona where ficha in (Select id From ficha_persona where ficha_hogar=reg.id);
        Delete documento Where ficha_x11 in (Select id From ficha_persona where ficha_hogar=reg.id); --fotos
        Delete result_funcion_icv where ficha_persona in (Select id From ficha_persona where ficha_hogar=reg.id);
        delete ficha_persona where ficha_hogar=reg.id;
      Exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar eliminar las fichas personas del hogar id:' || reg.id || ', mensaje:' || v$msg, true);
      End;
      begin
        Delete RESPUESTA_FICHA_hogar where ficha=reg.id;
      Exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar eliminar la respuesta de ficha hogar, mensaje:' || v$msg, true);
      End;
      begin
        Delete ficha_hogar where id=reg.id;
        Delete documento Where ficha_x10=reg.id; --fotos
      Exception
      when others then
        v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar eliminar la ficha hogar, mensaje:' || v$msg, true);
      End;
    end loop;
  when v$tipo_archivo=8 then --Monitoreo
    null;
  when v$tipo_archivo=9 then --Estado cuenta
    begin
      Delete From estado_cuenta where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar eliminar registros de estado de cuenta, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=10 then--Propietario
    begin
      update persona set FECHA_INGRESO_CATASTRO=null, FECHA_EGRESO_CATASTRO=null, TIPO_CATASTRO=null, CANTIDAD_INMUEBLE=null,
                        MONTO_CATASTRO=null, NUMERO_SIME_CATASTRO=null
      Where codigo in (Select cedula From catastro Where archivo=x$clase);
      Delete From catastro where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de catastro, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=11 then--Cotizante
    begin
      Update persona set FECHA_INGRESO_COTIZANTE=null, FECHA_EGRESO_COTIZANTE=null, NUMERO_SIME_COTIZANTE=null, NOMBRES_EMPRESA=null, RUC=null, MONTO_COTIZANTE=null
      Where codigo in (Select cedula From cotizante Where archivo=x$clase);
      Delete From cotizante where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de cotizante, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=12 then--Proveedor
    begin
      Update persona set TIPO_PROVEEDOR=null, denominacion_entidad=null, ruc_entidad=null, NUMERO_SIME_PROVEEDOR=null
      Where codigo in (Select cedula From proveedor Where archivo=x$clase);
      Delete From proveedor where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de proveedor, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=13 then--Nacimiento
    begin
      Update persona set fecha_nacimientos=null, departamento_nacimiento=null, distrito_nacimiento=null, nombre_madre=null, cedula_madre=null, nombre_padre=null,
                         cedula_padre=null, folio_nacimiento=null, acta_nacimiento=null, tomo_nacimiento=null, numero_sime_nacimiento=null
      Where codigo in (Select cedula From nacimiento Where archivo=x$clase
                       UNION
                       Select cedula_madre From nacimiento Where archivo=x$clase
                       UNION
                       Select cedula_padre From nacimiento Where archivo=x$clase);
      Delete From nacimiento where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de nacimiento, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=14 then--Reporte campo
    Begin
      Select valor Into v_version_ficha_hogar From variable_global where numero=103;  --version ficha hogar activa
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20006,'Error al intentar obtener la versión activa de la ficha hogar', true);
    End;
    For reg in (Select rc.censo_persona, pe.codigo as cedula, cp.id, cp.ficha
              From reporte_campo rc inner join censo_persona cp on rc.censo_persona = cp.id
                inner join persona pe on cp.persona = pe.id
              where rc.archivo=x$clase) loop
      begin
        Update solicitud_pension set ficha_persona=null Where ficha_persona=reg.ficha;
        Update persona set ficha=null Where codigo=reg.cedula;
        update censo_persona set estado=1, observaciones=null, censista_interno= null, ficha=null where id=reg.censo_persona;
        Delete From respuesta_ficha_persona where ficha=reg.ficha;
        Delete From ficha_persona where id=reg.ficha; 
        --where numero_cedula=reg.cedula And version_ficha_hogar=v_version_ficha_hogar
        --  And NOT Exists (Select cp.id From censo_persona cp Where cp.ficha=ficha_persona.id And cp.id<>reg.id);
       Exception
       when others then
  			v$msg := SUBSTR(SQLERRM, 1, 2000);
        raise_application_error(v$err, 'Error al intentar actualizar el registro de censo persona, mensaje:' || v$msg, true);
      End;
    end loop;
    Delete From reporte_campo where archivo=x$clase;
  when v$tipo_archivo=15 then--Automotor
    begin
      update persona set TIPO=null, cantidad=null, modelo=null, ano_registro=null,
                          monto=null,	NUMERO_SIME_automotor=null, FECHA_INGRESO=null, FECHA_EGRESO=null
      Where codigo in (Select cedula From automotor Where archivo=x$clase);
      Delete From automotor where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de automotor, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=16 then--Foto
    null;
  when v$tipo_archivo=17 then--Historico pension spam
    null;
  when v$tipo_archivo=18 then--Historico pension jupe
    null;
  when v$tipo_archivo=19 then--Historico movimiento jupe
    null;
  when v$tipo_archivo=20 then--Historico reclamo pension
    null;
  when v$tipo_archivo=21 then--Foto hogar
    null;
  when v$tipo_archivo=22 then--Reclamo censo
    begin
      delete From tramite_administrativo where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar eliminar registros de tramite administrativo, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=23 then --Carga censo stp caratula
    null;
  when v$tipo_archivo=24 then--Carga censo stp vivienda
    null;
  when v$tipo_archivo=25 then--Carga censo stp poblacion
    null;
  when v$tipo_archivo=26 then--Carga censo stp agropecuario
    null;
  when v$tipo_archivo=27 then--No indigena
    begin
      Update persona set indigena='true', comunidad=null, OBSERVACIONES_ANULAR_NO_INDIG=null, NOMBRE_ENTIDAD=null, NUMERO_SIME=null
      Where codigo in (Select cedula From no_indigena Where archivo=x$clase);
      Delete From no_indigena where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de no indígena, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=28 then--Residente en el extranjero
    begin
      update persona set ANO_VOTACION=null, PAIS_RESID=null, DOMICILIO=null, FECHA_INSCRIPCION=null, NUMERO_SIME_RESIDENTE=null
      Where codigo in (Select cedula From residente_extranjero Where archivo=x$clase);
      Delete From residente_extranjero where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de residentes en el extranjero, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=29 then--Subsidio
    begin
      Update persona set FECHA_EGRESO_SUB=null, FECHA_INGRESO_SUB=null, MONTO_SUB=null, NUMERO_SIME_SUB=null, NOMBRE_EMPRESA_SUB=null
      Where codigo in (Select cedula From subsidio Where archivo=x$clase);
      Delete From subsidio where archivo=x$clase;
    exception
    WHEN NO_DATA_FOUND THEN
      null;
    when others then
      v$msg := SUBSTR(SQLERRM, 1, 2000);
      raise_application_error(v$err, 'Error al intentar actualizar los registros de personas y eliminar registros de subsidios, mensaje:' || v$msg, true);
    end;
  when v$tipo_archivo=30 then--Pensionado
    null;
  when v$tipo_archivo=33 then--Historico solicitud
    null;
  when v$tipo_archivo=34 then --Log Corrida de Nómina
    null;
  else
    raise_application_error(v$err, 'AVISO: clase de archivo suministrado, no tiene script de eliminación programada:' || v$tipo_archivo, true);
  end case;
  begin
    Delete From error_archivo where linea in (Select id From linea_archivo where carga =x$clase);
    Delete From linea_archivo where carga = x$clase;
    Delete From carga_archivo where id = x$clase;
  exception
  WHEN NO_DATA_FOUND THEN
    null;
  when others then
	  v$msg := SUBSTR(SQLERRM, 1, 2000);
    raise_application_error(v$err, 'Error al intentar eliminar la carga de archivo, mensaje:' || v$msg, true);
  end;
	return 0;
exception
	When others then
		v$msg := SQLERRM;
		raise_application_error(-20000, v$msg, true);
end;
/