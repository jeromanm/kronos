create or replace view v_pers_dpto_pension as
select p.id           id_persona,
       p.codigo,
       p.nombres,
       p.departamento,
       de.nombre      nom_departamento,
       p.distrito,
       di.nombre      nom_distrito,
       count(*) cantidad_pension,
       to_char(pens.fecha_transicion, 'YYYY') anio,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '01'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Enero,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '02'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Febrero,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '03'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Marzo,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '04'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Abril,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '05'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Mayo,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '06'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Junio,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '07'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Julio,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '08'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Agosto,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '09'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Setiembre,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '10'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Octubre,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '11'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Noviembre,
       (select count(*)
          from pension pen, persona pe
         where to_char(pen.fecha_transicion, 'MM') = '12'
           and to_char(pen.fecha_transicion, 'YYYY') =
               to_char(sysdate, 'yyyy')
           and pen.persona = pe.id
           and pe.id = p.id
           and pe.departamento = p.departamento
           and pe.distrito = p.distrito) Diciembre
 From persona p, departamento de, distrito di, pension pens
 where p.departamento = de.id
   and p.distrito = di.id
   and de.id = di.departamento
   and pens.persona = p.id
 group by p.id,
          p.codigo,
          p.nombres,
          p.departamento,
          de.nombre,
          p.distrito,
          di.nombre,
          to_char(pens.fecha_transicion, 'YYYY');
/