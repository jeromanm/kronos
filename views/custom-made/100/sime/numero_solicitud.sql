create or replace view numero_solicitud as
Select to_number(a.sol_numero*1000000) as id, a.sol_numero as codigo, a.sol_fchsol as fecha, a.sol_importe as monto_solicitud, a.sol_concepto as concepto, a.sol_detalle as detalle
From a_sol@siaf a inner join variable_global vg1 on a.nen_codigo = vg1.valor_numerico And vg1.numero=122
  inner join variable_global vg2 on a.ent_codigo = vg2.valor_numerico And vg2.numero=123
Where a.nen_codigo=vg1.valor_numerico And a.ent_codigo=vg2.valor_numerico
And a.ani_aniopre=(Select valor_numerico From variable_global Where numero=132)
Order by a.sol_fchsol desc;
/