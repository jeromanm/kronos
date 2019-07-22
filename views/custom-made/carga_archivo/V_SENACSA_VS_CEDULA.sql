CREATE OR REPLACE FORCE VIEW V_SENACSA_VS_CEDULA as (
Select a.cedula, a.nombre as nombrepersona, nvl(b.nombres,'N/E') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From SENACSA a left outer join cedula b on a.cedula = b.numero
  inner join carga_archivo d on a.archivo = d.id 
  inner join ARCHIVO_ADJUNTO e on d.adjunto = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where (utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null)
);