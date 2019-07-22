create or replace view v_conceptos as
select id,
       version,
       codigo,
       nombre,
       grupo,
       fecha_decreto,
       decreto_ley,
       requiere_causante,
       requiere_censo,
       requiere_saldo,
       auxilio,
       pago_unico,
       parentesco_causante,
       clase_pension_causante
  from clase_pension;
/