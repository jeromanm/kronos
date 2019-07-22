create or replace view v_cuenta_administrativa as
  Select pe.codigo as cedula, pe.nombre, cp.nombre as clase_pension, rp.monto, rp.ano_resumen, rp.mes_resumen, dp.nombre as departamento, di.nombre as distrito, dp.id as id_departamento, di.id as id_distrito, 
        pe.id as id_persona, pn.id as id_pension, cp.id as id_clase_pension
  From persona pe inner join pension pn on pe.id = pn.persona
    inner join resumen_pago_pension rp on pn.id = rp.pension
    inner join clase_pension cp on pn.clase = cp.id
    inner join departamento dp on pe.departamento = dp.id
    inner join distrito di on pe.distrito = di.id
  Where upper(pe.cuenta_bancaria)='CUENTA ADMINISTRATIVA'; 