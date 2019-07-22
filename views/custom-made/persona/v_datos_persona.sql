CREATE OR REPLACE FORCE VIEW V_DATOS_PERSONA as
Select p.id as idpersona, p.version, p.codigo, p.nombre, p.apellidos, p.nombres, p.fecha_nacimiento, calcular_edad(p.fecha_nacimiento) edad,
       p.lugar_nacimiento, p.sexo, p.estado_civil, ec.codigo as e_civil, p.paraguayo, p.indigena, p.etnia,
       ei.nombre as nombre_etnia, p.comunidad, ci.nombre as nombre_comunidad, p.icv, p.tipo_pobreza, p.cedula, p.fecha_expedicion_cedula, 
       p.fecha_vencimiento_cedula, p.carnet_militar, p.pariente, parentesco, p.hogar_colectivo, p.fecha_ingreso_hogar,
       p.departamento, dp.nombre as nom_departamento, p.distrito, dt.codigo as cod_distrito, dt.nombre as nom_distrito,
       re.numero as codigo_region, re.codigo as nom_region, p.tipo_area, ta.codigo as tip_area, p.barrio, ba.id as cod_barrio,
       ba.nombre as nom_barrio, p.manzana, p.direccion, p.telefono_linea_baja, p.telefono_celular, p.cedula_representante,
       p.nombre_representante, p.fecha_otorgamiento, p.cedula_curador, p.nombre_curador, p.nombre_juzgado, p.fecha_sentencia, p.numero_sentencia,
       p.sello_registro, p.numero_sime_tutelaje, p.observaciones_anular_tutelaje, p.certificado_matrimonio,
       p.oficina_matrimonio, p.fecha_acta_matrimonio, p.tomo_matrimonio, p.folio_matrimonio, p.acta_matrimonio,
       p.cedula_conyuge, p.nombre_conyuge, p.fecha_matrimonio, p.fecha_certificado_matrimonio, p.numero_sime_matrimonio,
       p.observac_anular_matrimon_43115, p.certificado_defuncion, p.oficina_defuncion, p.fecha_acta_defuncion, p.tomo_defuncion,
       p.folio_defuncion, p.acta_defuncion, p.fecha_defuncion, p.fecha_certificado_defuncion, p.numero_sime_defuncion,
       p.observaciones_anular_defuncion, p.certificado_invalidez, p.diagnostico_invalidez, p.fecha_certificado_invalidez,
       p.numero_sime_invalidez, p.observaciones_anular_invalidez, p.banco, p.cuenta_bancaria, p.numero_sime_cuenta, p.observaciones_anular_cuenta, 
       p.ficha, p.numero_sime_ficha, p.observaciones_anular_ficha, p.monitoreado, p.fecha_monitoreo, p.monitoreo_sorteo,
       p.salario, p.porcentaje, p.numero_sime_salario, p.observaciones_anular_salario, p.fecha_ingreso, p.fecha_egreso, p.tipo, p.cantidad, p.modelo, p.ano_registro,
       (Select rp.monto From resumen_pago_pension rp Where pe.id = rp.pension 
        And to_date('01/' || rp.mes_resumen || '/' || rp.ano_resumen,'dd/mm/yyyy')=
            (Select max(to_date('01/' || rp.mes_resumen || '/' || rp.ano_resumen,'dd/mm/yyyy')) From resumen_pago_pension rp Where pe.id = rp.pension)
       ) as monto,
       p.numero_sime_automotor, p.observaciones_anular_automotor, p.fecha_nacimientos, p.departamento_nacimiento, p.distrito_nacimiento, p.nombre_madre, p.cedula_madre,
       p.nombre_padre, p.cedula_padre, p.folio_nacimiento, p.acta_nacimiento, p.tomo_nacimiento, p.numero_sime_nacimiento, p.observac_anular_nacimien_13191, 
       p.ruc_entidad, p.denominacion_entidad, p.numero_sime_proveedor, p.observaciones_anular_proveedor, p.fecha_ingreso_catastro, p.fecha_egreso_catastro, p.tipo_catastro,
       p.cantidad_inmueble, p.monto_catastro, p.numero_sime_catastro, p.observaciones_anular_catastro, p.fecha_ingreso_cotizante, p.fecha_egreso_cotizante, p.monto_cotizante, 
       p.nombres_empresa, p.ruc, p.numero_sime_cotizante, p.observaciones_anular_cotizante, p.fecha_ingreso_senacsa, p.fecha_egreso_senacsa, p.tipo_senacsa, p.cantidad_senacsa, 
       p.monto_senacsa, p.numero_sime_senacsa, p.observaciones_anular_senacsa, p.edicion_restringida, cp.nombre as clase_pension
From persona p inner join pension pe on p.id=pe.persona
  inner join clase_pension cp on pe.clase = cp.id
  inner join departamento dp on p.departamento = dp.id
  inner join distrito dt on p.distrito = dt.id
  left outer join barrio ba on p.barrio = ba.id
  left outer join tipo_area ta on ba.tipo_area = ta.numero
  inner join estado_civil ec on p.estado_civil = ec.numero
  left outer join etnia_indigena ei on p.etnia = ei.id
  left outer join comunidad_indigena ci on  p.comunidad=ci.id
  inner join region re on dp.region = re.numero;
/