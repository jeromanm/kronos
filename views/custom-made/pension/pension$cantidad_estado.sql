create or replace view pension$cantidad_estado as
select c.codigo,
       c.nombre,
       a.estado,
       b.codigo desc_estado,
       trunc(a.fecha_transicion) fecha_transicion,
       count(*) cantidad
  from pension a, estado_pension b, clase_pension c
 where a.estado = b.numero
   and a.clase = c.id
 group by a.estado, b.codigo, c.codigo, c.nombre, trunc(a.fecha_transicion);
 /