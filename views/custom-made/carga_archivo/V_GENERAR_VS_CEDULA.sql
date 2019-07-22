CREATE OR REPLACE FORCE VIEW v_generar_vs_cedula AS 
Select 'Persona' as tiporegistro, a.codigo as cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From persona a inner join pension pn on a.id = pn.persona
  left outer join cedula b on a.cedula = b.id
  inner join carga_archivo d on  pn.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Automotor' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From AUTOMOTOR a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Defunción' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From defuncion a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where (utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null)
UNION
Select 'Matrimonio' as tiporegistro, a.cedula1 as cedula, a.nombre1 as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From matrimonio a left outer join cedula b on a.cedula1 = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre1),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Matrimonio' as tiporegistro, a.cedula2 as cedula, a.nombre2 as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From matrimonio a left outer join cedula b on a.cedula2 = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre2),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Empleo' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From empleo a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Catastro' as tiporegistro, a.cedula as cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From catastro a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Cotizante' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From cotizante a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Jubilación' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From jubilacion a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Nacimiento' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From nacimiento a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Nacimiento' as tiporegistro, a.cedula_madre as cedula, a.nombre_madre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From nacimiento a left outer join cedula b on a.cedula_madre = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre_madre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Nacimiento' as tiporegistro, a.cedula_padre as cedula, a.nombre_padre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From nacimiento a left outer join cedula b on a.cedula_padre = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre_padre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'No Indigena' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From no_indigena a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Proveedor' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From proveedor a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Residente Extranjero' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From residente_extranjero a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Senacsa' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From senacsa a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Subsidio' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From subsidio a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null
UNION
Select 'Solicitud' as tiporegistro, a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'NO EXISTE EN CEDULA') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From solicitud_pension a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id
  inner join ARCHIVO_ADJUNTO e on d.ADJUNTO = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null;
