create or replace view v_lista_archivo as 
select ca.nombre clase_archivo, nvl(to_date(to_char(c.fecha_hora, 'dd/mm/yyyy'),'dd/mm/yyyy'),null) fecha_carga, aa.archivo_cliente
from tipo_archivo ta inner join clase_archivo ca on ta.numero=ca.tipo left outer join carga_archivo c
on c.clase=ca.id left outer join archivo_adjunto aa on c.adjunto=aa.id;
/