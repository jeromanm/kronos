
  CREATE OR REPLACE FORCE VIEW V_ERROR_ARCHIVO AS 
  select a.clase clase_archivo,aa.archivo_cliente nombre_archivo, c.nombre descripcion_clase, a.id as archivo, a.numero_sime, a.observaciones, e.descripcion,
        TO_CHAR(trunc(a.fecha_hora),'DD/MM/YYYY') fecha,
        l.numero linea_error, l.texto texto_error,(ex.nro ||'/'||ex.ano) sime, ex.nro nro, ex.ano ano,ex.id
from carga_archivo a left outer join  clase_archivo c on  a.clase=c.id
  inner join linea_archivo l on l.carga=a.id 
  left outer join expediente@sgemh ex on a.numero_sime=ex.id
  inner join error_archivo e on l.id=e.linea
  left outer join archivo_adjunto aa on upper(trim(a.archivo))=upper(trim(aa.archivo_servidor))
Order by a.id, l.numero;
/