  CREATE OR REPLACE FORCE VIEW V_LIQUIDACION_HABERES2 as
Select id_liquidacion, id_clase_concepto, codigo_tipo_concepto, tipo_concepto, to_char(mes_ano,'yyyy') as mes_ano,proyectado, sum(monto) as total
From (Select lp.id as id_liquidacion, co.id as id_clase_concepto, co.codigo as codigo_tipo_concepto, co.nombre as tipo_concepto,
        to_date(to_char(dl.fecha,'mm/yyyy'),'mm/yyyy') as mes_ano, dl.proyectado, 
        case co.tipo_concepto when 1 then dl.monto else (dl.monto*-1) end as monto 
      From liquidacion_haberes lp inner join detalle_liqu_haber dl on lp.id = dl.liquidacion_haberes
        inner join clase_concepto co on dl.clase_concepto = co.id)
Group by id_liquidacion, id_clase_concepto, codigo_tipo_concepto, tipo_concepto, to_char(mes_ano,'yyyy'), proyectado
Order by mes_ano, proyectado;
/