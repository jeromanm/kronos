create or replace view v_beneficiarios_diferencia as
Select mes_planilla, ano_planilla, sum(asignacion) as asignacion, sum(deduccion) as deduccion,
		cedula, nombre_persona, nombre_departamento,
      nombre_distrito, nombre_pension, cuenta_bancaria, clase_pension
From (Select d.mes_planilla, d.ano_planilla,
				case tc.numero when 1 then d.monto else 0 end as asignacion,
	         case tc.numero when 2 then d.monto else 0 end as deduccion,
	         pe.codigo cedula, pe.nombre nombre_persona,
	        (select de.nombre from departamento de where de.id=pe.departamento ) nombre_departamento,
	        (select di.nombre from distrito di where di.id=pe.distrito) nombre_distrito,
	        d.nombre_pension, pe.cuenta_bancaria, cp.codigo as clase_pension
	from detalle_pago_pension d
	     inner join resumen_pago_pension r on r.id=d.resumen
	     inner join pension p on r.pension=p.id
	     inner join persona pe on pe.id=p.persona
	     inner join clase_concepto cc on cc.id=d.clase_concepto
	     inner join tipo_concepto tc on tc.numero=cc.tipo_concepto
       inner join clase_pension cp on p.clase = cp.id
	where pe.cuenta_bancaria is null)
Group By mes_planilla, ano_planilla, cedula, nombre_persona, nombre_departamento,
      nombre_distrito, nombre_pension, cuenta_bancaria, clase_pension;
/