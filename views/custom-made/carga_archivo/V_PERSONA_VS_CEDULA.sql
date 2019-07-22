CREATE OR REPLACE FORCE VIEW V_PERSONA_VS_CEDULA as (
(Select a.codigo as cedula, a.nombre as nombrepersona, nvl(b.nombres,'N/E') || ' ' || nvl(b.apellidos,'') as nombrecedula,
       d.fecha_hora as fechacarga, e.archivo_cliente as nombrearchivo, f.nro || '/' || f.ano as sime, f.id as nrosime
From persona a left outer join cedula b on a.cedula = b.id
  inner join carga_archivo d on (a.NUMERO_SIME_TUTELAJE=d.NUMERO_SIME or a.NUMERO_SIME_MATRIMONIO=d.NUMERO_SIME or a.NUMERO_SIME_DEFUNCION=d.NUMERO_SIME or  
                                a.NUMERO_SIME_INVALIDEZ=d.NUMERO_SIME or a.NUMERO_SIME_CUENTA=d.NUMERO_SIME or a.NUMERO_SIME_FICHA=d.NUMERO_SIME or 
                                a.NUMERO_SIME_SALARIO=d.NUMERO_SIME or a.NUMERO_SIME_EMP=d.NUMERO_SIME or a.NUMERO_SIME_JUBI=d.NUMERO_SIME or 
                                a.NUMERO_SIME_SUB=d.NUMERO_SIME or a.NUMERO_SIME_AUTOMOTOR=d.NUMERO_SIME or a.NUMERO_SIME_NACIMIENTO=d.NUMERO_SIME or 
                                a.NUMERO_SIME_PROVEEDOR=d.NUMERO_SIME or a.NUMERO_SIME_CATASTRO=d.NUMERO_SIME or a.NUMERO_SIME_COTIZANTE=d.NUMERO_SIME or  
                                a.NUMERO_SIME_SENACSA=d.NUMERO_SIME or a.NUMERO_SIME=d.NUMERO_SIME or a.NUMERO_SIME_RESIDENTE=d.NUMERO_SIME or  
                                a.NUMERO_SIME_EXT=d.NUMERO_SIME) 
  inner join ARCHIVO_ADJUNTO e on d.adjunto = e.id
  inner join expediente@sgemh f on d.numero_sime = f.id
Where (utl_match.jaro_winkler_similarity(upper(a.nombre),upper(b.nombres || ' ' || b.apellidos))<85 or b.numero is null))
);
