CREATE OR REPLACE FORCE VIEW V_BUSCA_PERSONA AS
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Proveedor: Ruc:' || to_char(ar.ruc_entidad) || ', nombre entidad:' || to_char(ar.DENOMINACION_ENTIDAD) || ', tipo:' || to_char(ar.tipo_proveedor) as detalle
From proveedor ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Defunción: Fecha Defunción:' || ar.fecha_defuncion || ', nombre registro:' || to_char(ar.NOMBRE_REGISTRO) || ', lugar fallecimiento:' || to_char(ar.LUGAR_FALLECIDO) as detalle
From defuncion ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Empleo: Ruc:' || to_char(ar.ruc_entidad) || ', nombre entidad:' || to_char(ar.nombre_entidad) || ', fecha ingreso:' || ar.fecha_ingreso as detalle
From empleo ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id 
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Automotor: modelo vehículo:' || to_char(ar.MODELO) || ', año registro:' || ar.ANO_REGISTRO || ', valor:' || ar.MONTO as detalle
From automotor ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id 
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Catastro: fecha registro:' || ar.FECHA_INGRESO_CATASTRO || ', tipo:' || to_char(ar.TIPO_CATASTRO) || ', valor:' || ar.MONTO_CATASTRO as detalle
From catastro ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id 
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime, es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Cotizante: fecha ingreso:' || ar.FECHA_INGRESO_COTIZANTE || ', empresa:' || to_char(ar.NOMBRES_EMPRESA) || ', valor:' || ar.MONTO_COTIZANTE as detalle
From cotizante ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id 
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime, es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Residente en el extranjero: año votación:' || ar.ANO_VOTACION  || ', país:' || to_char(pa.nombre) || ', domicilio:' || to_char(ar.DOMICILIO) as detalle
From RESIDENTE_EXTRANJERO ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id 
      left outer join pais pa on ar.PAIS = pa.id
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Jubilación: fecha ingreso:' || ar.FECHA_INGRESO || ', empresa:' || to_char(ar.NOMBRE_EMPRESA) || ', monto:' || ar.MONTO as detalle
From jubilacion ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula1) as cedula, to_char(ar.nombre1) as nombre, 
      'Archivo Matrimonio: fecha acta:' || ar.FECHA_ACTA_MATRIMONIO || ', certificado:' || to_char(ar.CERTIFICADO_MATRIMONIO) || ', oficina:' || to_char(ar.OFICINA_MATRIMONIO) as detalle
From matrimonio ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula1 = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime, es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula2) as cedula, to_char(ar.nombre2) as nombre, 
      'Archivo Matrimonio: fecha acta:' || ar.FECHA_ACTA_MATRIMONIO || ', certificado:' || to_char(ar.CERTIFICADO_MATRIMONIO) || ', oficina:' || to_char(ar.OFICINA_MATRIMONIO) as detalle
From matrimonio ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula2 = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime, es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Nacimiento: hijo/a fecha nacimiento:' || ar.FECHA_NACIMIENTOS || ', folio:' || to_char(ar.FOLIO_NACIMIENTO) || ', acta:' || to_char(ar.ACTA_NACIMIENTO) as detalle
From nacimiento ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula_madre) as cedula, to_char(ar.nombre_madre) as nombre, 
      'Archivo Nacimiento: madre fecha nacimiento:' || ar.FECHA_NACIMIENTOS || ', folio:' || to_char(ar.FOLIO_NACIMIENTO) || ', acta:' || to_char(ar.ACTA_NACIMIENTO) as detalle
From nacimiento ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula_madre = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime,es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula_padre) as cedula, to_char(ar.nombre_padre) as nombre, 
      'Archivo Nacimiento: padre fecha nacimiento:' || ar.FECHA_NACIMIENTOS || ', folio:' || to_char(ar.FOLIO_NACIMIENTO) || ', acta:' || to_char(ar.ACTA_NACIMIENTO) as detalle
From nacimiento ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id 
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula_padre = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime, es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo No Indígena: entidad:' || to_char(ar.NOMBRE_ENTIDAD) as detalle
From no_indigena ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id 
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime, es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Senacsa: estancia:' || to_char(ar.ESTANCIA) || ', cantidad:' || ar.CANTIDAD_SENACSA || ', valor:' || ar.MONTO_SENACSA as detalle
From senacsa ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id 
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select ced.numero ced_ident, ced.nombre nom_ident, to_char(aa.archivo_cliente) as archivo_cliente, to_char(fa.nombre) as proveedor, es.id as id_sime, es.codigo as nro_sime, ca.fecha_hora, to_char(ar.cedula) as cedula, to_char(ar.nombre) as nombre, 
      'Archivo Subsidio: fecha ingreso:' || ar.FECHA_INGRESO || ', denominación:' || to_char(ar.NOMBRE_EMPRESA) || ', valor:' || ar.MONTO as detalle
From subsidio ar inner join carga_archivo ca on ar.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id 
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      inner join expediente_sime es on ca.numero_sime = es.id
      left outer join cedula ced on ar.cedula = ced.numero
UNION
Select con.per_codcci as ced_ident, ce.nombre nom_ident, 'N/A' as archivo_cliente, 'SINARH' as proveedor, null as id_sime, 'N/A' as nro_sime,  con.con_usrfch as fecha_hora, con.per_codcci as cedula, ce.nombre,
      'Contrato en sinarh en: ' || eco.ent_nombre as detalle
From a_con@sinarh con inner join a_ent@sinarh eco on con.cof_codigo = eco.cof_codigo
  inner join a_emp@sinarh pco on con.per_codcci  = pco.per_codcci  and con.cof_codigo = pco.cof_codigo and pco.tfu_codigo=2
  inner join cedula ce on con.per_codcci = ce.numero
Where con.ani_aniopre = extract (year from sysdate) 
  And con.mot_codbaja is null and trunc(con.con_fchhas) >= trunc(sysdate)
  And con.ani_aniopre = extract (year from sysdate)
UNION 
Select car.per_codcci as ced_ident, ce.nombre nom_ident, 'N/A' as archivo_cliente, 'SINARH' as proveedor, null as id_sime, 'N/A' as nro_sime,  car.car_usufch as fecha_hora, car.per_codcci as cedula, ce.nombre, 
      'Cargo en sinarh en: ' || eca.ent_nombre as detalle
From a_car@sinarh car inner join a_ent@sinarh eca on car.ani_aniopre = eca.ani_aniopre And car.cof_codigo = eca.cof_codigo
  inner join a_emp@sinarh pca on car.per_codcci = pca.per_codcci And car.cof_codigo = pca.cof_codigo And pca.tfu_codigo=1
  inner join cedula ce on car.per_codcci = ce.numero
Where car.ani_aniopre = extract (year from sysdate)
  And car.mot_codbaja is null
UNION
Select com.per_codcci as ced_ident, ce.nombre nom_ident, 'N/A' as archivo_cliente, 'SINARH' as proveedor, null as id_sime, 'N/A' as nro_sime,  com.com_usufch as fecha_hora, com.per_codcci as cedula, ce.nombre,
      'Comisiamiento en sinarh en: ' || ecm.ent_nombre as detalle
From a_com@sinarh com inner join a_ent@sinarh ecm on com.ani_aniopre = ecm.ani_aniopre and com.cof_codigo = ecm.cof_codigo
  inner join cedula ce on com.per_codcci = ce.numero
Where com.ani_aniopre = extract (year from sysdate)
  And trunc(com.com_fchhas) >= trunc(sysdate) and com.mot_codbaja is null
UNION
Select pas.per_codcci as ced_ident, ce.nombre nom_ident, 'N/A' as archivo_cliente, 'SINARH' as proveedor, null as id_sime, 'N/A' as nro_sime,  pas.pas_usrfch as fecha_hora, pas.per_codcci as cedula, ce.nombre,
      'Pasantia en sinarh en: ' || ecp.ent_nombre as tipo
From a_pas@sinarh pas inner join a_ent@sinarh ecp on pas.ani_aniopre = ecp.ani_aniopre and pas.cof_codigo = ecp.cof_codigo
   inner join a_emp@sinarh pcp on pas.per_codcci  = pcp.per_codcci  and pas.cof_codigo = pcp.cof_codigo and pcp.tfu_codigo=3
   inner join cedula ce on pas.per_codcci = ce.numero
Where pas.ani_aniopre = extract (year from sysdate) 
  And trunc(pas.pas_fchhas) >= trunc(sysdate) 
  And pas.mot_codbaja is null
UNION
Select a.ced_nrocedula as ced_ident, a.ced_apynom as nom_ident, 'N/A' as archivo_cliente, 'JUPE' as proveedor, d.exp_nro as id_sime, 'N/A' as nro_sime, d.mov_fching as fecha_hora, a.ced_nrocedula as cedula, a.ced_apynom as nombre, 
      c.con_nombre_con as detalle
From a_ced@jupe a inner join a_ben@jupe b on a.ced_nrocedula=b.ced_nrocedula
  inner join a_con@jupe c on b.CON_COD_CONCEPTO = c.CON_COD_CONCEPTO
  inner join a_mov@jupe d on a.ced_nrocedula = d.ced_nrocedula And b.ben_nro_benef = d.ben_nro_benef And c.con_cod_concepto=d.con_cod_concepto
    And d.mov_fching=(Select max(d1.mov_fching) From a_mov@jupe d1 Where d.ced_nrocedula = d1.ced_nrocedula)
Where a.CED_ESTATUS='A' And b.ben_estatus='A' And d.mov_estado='A'
  And c.CON_COD_CONCEPTO < 7
  And d.tas_cod_asignado not in (4, 8, 9);
 /