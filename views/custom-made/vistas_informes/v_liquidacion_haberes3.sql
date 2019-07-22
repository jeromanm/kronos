CREATE OR REPLACE FORCE VIEW V_LIQUIDACION_HABERES3 as
Select lp.id as id_liquidacion, co.id as id_clase_concepto, co.codigo as codigo_tipo_concepto, co.nombre as tipo_concepto,
      sum(case co.tipo_concepto when 1 then dl.monto else (dl.monto*-1) end) as monto 
From liquidacion_haberes lp inner join detalle_liqu_haber dl on lp.id = dl.liquidacion_haberes And dl.proyectado='false'
      inner join clase_concepto co on dl.clase_concepto = co.id
Group by lp.id, co.id, co.codigo, co.nombre, co.tipo_concepto
Order by to_number(co.codigo);

/