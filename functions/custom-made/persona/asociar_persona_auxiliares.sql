create or replace procedure asociar_persona_auxiliares(x$persona number, x$cedula varchar2) as
  v_nombre      varchar2(100);
  v_cedula      varchar2(20);
begin
  For reg in (Select * From automotor
              Where cedula=x$cedula And INFORMACION_INVALIDA<>'true' And persona is null) loop
    if reg.FECHA_EGRESO is null then
      update persona set TIPO=reg.tipo, cantidad=reg.cantidad, modelo=reg.modelo, ano_registro=reg.ano_registro,
                         monto=reg.monto,	NUMERO_SIME_automotor=reg.NUMERO_SIME, FECHA_INGRESO=reg.fecha_ingreso
      Where id=x$persona;
    end if;
    Update automotor set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From catastro
              Where cedula=x$cedula And INFORMACION_INVALIDA<>'true' And persona is null) loop
    if reg.FECHA_EGRESO_CATASTRO is null then
      update persona set FECHA_INGRESO_CATASTRO=reg.FECHA_INGRESO_CATASTRO, TIPO_CATASTRO=reg.TIPO_CATASTRO, CANTIDAD_INMUEBLE=reg.CANTIDAD_INMUEBLE,
                          MONTO_CATASTRO=reg.MONTO_CATASTRO, NUMERO_SIME_CATASTRO=reg.NUMERO_SIME
      Where id=x$persona;
    end if;
    Update catastro set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From cotizante Where cedula=x$cedula And persona is null) loop
    if reg.FECHA_EGRESO_COTIZANTE is null then
      update persona set FECHA_INGRESO_COTIZANTE=reg.FECHA_INGRESO_COTIZANTE, NUMERO_SIME_COTIZANTE=reg.NUMERO_SIME, 
                          NOMBRES_EMPRESA=reg.NOMBRES_EMPRESA, RUC=reg.ruc, MONTO_COTIZANTE=reg.MONTO_COTIZANTE
      Where id=x$persona;
    end if;
    Update cotizante set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From defuncion Where cedula=x$cedula And INFORMACION_INVALIDA<>'true' And persona is null) loop
    update persona set certificado_defuncion=reg.CERTIFICADO_DEFUNCION, oficina_defuncion= reg.oficina_defuncion, fecha_acta_defuncion=reg.fecha_acta_defuncion,
                        tomo_defuncion=reg.tomo_defuncion, folio_defuncion=reg.folio_defuncion, acta_defuncion=reg.acta_defuncion, fecha_defuncion=reg.fecha_defuncion,
                        numero_sime_defuncion=reg.NUMERO_SIME, departamentodef=reg.departamento, distritodef=reg.distrito, 
                        lugar_nacimiento_def=reg.LUGAR_FALLECIDO, fecha_nacimiento_defu=reg.FECHA_NACIMIENTO_DEFU, nacionalidad=reg.NACIONALIDAD
    Where id=x$persona;
    Update defuncion set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From empleo Where cedula=x$cedula And INFORMACION_INVALIDA<>'true' And persona is null) loop
    if reg.FECHA_EGRESO is null then
      update persona set NUMERO_SIME_EMP=reg.NUMERO_SIME, FECHA_INGRESO_EMP=reg.fecha_ingreso, MONTO_EMP=reg.monto, NOMBRE_EMPRESA_EMP=reg.NOMBRE_EMPRESA
      Where id=x$persona;
    end if;
    Update empleo set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From residente_extranjero Where cedula=x$cedula And INFORMACION_INVALIDA<>'true' And persona is null) loop
    update persona set ANO_VOTACION=reg.ano_votacion, PAIS_RESID=reg.pais, DOMICILIO=reg.domicilio, FECHA_INSCRIPCION=reg.fecha_inscripcion, NUMERO_SIME_RESIDENTE=reg.NUMERO_SIME
    Where id=x$persona;
    Update residente_extranjero set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From jubilacion Where cedula=x$cedula And INFORMACION_INVALIDA<>'true' And persona is null) loop
    if reg.FECHA_EGRESO is null then
      Update persona set FECHA_INGRESO_JUBI=reg.fecha_ingreso, MONTO_JUBI=reg.monto, numero_sime_jubi=reg.numero_sime, NOMBRE_EMPRESA=reg.NOMBRE_EMPRESA
      Where id=x$persona;
    end if;
    Update jubilacion set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From matrimonio 
              Where (cedula1=x$cedula or cedula2=x$cedula) And INFORMACION_INVALIDA<>'true' And persona is null) loop
    if reg.cedula1=x$cedula then
      v_nombre:=reg.nombre2; v_cedula:=reg.cedula2;
      Update matrimonio set persona=x$persona Where id=reg.id;
    elsif reg.cedula2=x$cedula then
      v_nombre:=reg.nombre1; v_cedula:=reg.cedula1;
      Update matrimonio set persona2=x$persona Where id=reg.id;
    else
      v_nombre:=null; v_cedula:=null;
    end if;
    Update persona set fecha_matrimonio=reg.fecha_matrimonio, nombre_conyuge=v_nombre, cedula_conyuge=v_cedula,
                          folio_matrimonio=reg.folio_matrimonio, acta_matrimonio=reg.acta_matrimonio,
                          tomo_matrimonio=reg.tomo_matrimonio, numero_sime_matrimonio=reg.numero_sime
    Where id=x$persona;
  end loop;
  For reg in (Select * From nacimiento 
              Where (cedula=x$cedula or cedula_madre=x$cedula or cedula_madre=x$cedula) 
              And fecha_nacimientos is not null And persona is null) loop
    if reg.cedula=x$cedula then
      Update persona set fecha_nacimientos=reg.fecha_nacimientos, departamento_nacimiento=reg.departamento_nacimiento, 
                        distrito_nacimiento=reg.DISTRITO_NACIMIENTO, nombre_madre=reg.nombre_madre, cedula_madre=reg.cedula_madre, nombre_padre=reg.nombre_padre,
                        cedula_padre=reg.cedula_padre, folio_nacimiento=reg.folio_nacimiento, acta_nacimiento=reg.acta_nacimiento,
                        tomo_nacimiento=reg.tomo_nacimiento, numero_sime_nacimiento=reg.numero_sime
      Where id=x$persona;
      Update nacimiento set persona=x$persona Where id=reg.id;
    elsif reg.cedula_madre=x$cedula then
      Update persona set numero_sime_nacimiento=reg.numero_sime Where id=x$persona;
      Update nacimiento set personamadre=x$persona Where id=reg.id;
    elsif reg.cedula_padre=x$cedula then
      Update persona set numero_sime_nacimiento=reg.numero_sime Where id=x$persona;
      Update nacimiento set personapadre=x$persona Where id=reg.id;
    end if;
  end loop;
  For reg in (Select * From no_indigena Where cedula=x$cedula And INFORMACION_INVALIDA<>'true' And persona is null) loop
    Update persona set indigena='false', comunidad=null, OBSERVACIONES_ANULAR_NO_INDIG=reg.observaciones, NOMBRE_ENTIDAD=reg.NOMBRE_ENTIDAD, NUMERO_SIME=reg.numero_sime
    Where id=x$persona;
    Update no_indigena set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From proveedor Where cedula=x$cedula And tipo_proveedor is not null And persona is null) loop
    Update persona set TIPO_PROVEEDOR=reg.tipo_proveedor, denominacion_entidad=reg.denominacion_entidad, 
                      RUC_ENTIDAD=reg.ruc_entidad, NUMERO_SIME_PROVEEDOR=reg.numero_sime
    Where id=x$persona;
    Update proveedor set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From senacsa Where cedula=x$cedula And CANTIDAD_SENACSA is not null And persona is null) loop
    update persona set estancia=reg.estancia, FECHA_INGRESO_SENACSA=reg.fecha_ingreso_senacsa, FECHA_EGRESO_SENACSA=reg.fecha_egreso_senacsa, CANTIDAD_SENACSA=reg.CANTIDAD_SENACSA, 
                      TIPO_SENACSA=reg.tipo_senacsa, monto_senacsa=reg.MONTO_SENACSA,	NUMERO_SIME_SENACSA=reg.NUMERO_SIME_SENACSA
    Where id=x$persona;
    Update senacsa set persona=x$persona Where id=reg.id;
  end loop;
  For reg in (Select * From subsidio Where cedula=x$cedula And INFORMACION_INVALIDA<>'true' And persona is null) loop
    Update persona set FECHA_EGRESO_SUB=reg.fecha_egreso, FECHA_INGRESO_SUB=reg.fecha_ingreso, MONTO_SUB=reg.monto, NUMERO_SIME_SUB=reg.numero_sime, NOMBRE_EMPRESA_SUB=reg.nombre_empresa
    Where id=x$persona;
    Update subsidio set persona=x$persona Where id=reg.id;
  end loop;
exception
when others then
   null;
end;
/
