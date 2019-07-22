create or replace view v_detalle_csv as (
Select lo.id as id_lote, lo.nombre as nombre_lote, pe.codigo as cedula, pe.nombre, pn.estado, 
        case pn.activa when 'true' then 'Si' else 'No' end as activa, 
        case pn.tiene_objecion when 'true' then 'Si' else 'No' end as tiene_objecion, 
        case pn.falta_requisito when 'true' then 'Si' else 'No' end as falta_requisito, op.comentarios, op.observaciones, 
        dp.nombre as departamento, dt.nombre as distrito
From spnc2ap112.lote lo inner join spnc2ap112.lote_pension lp on lo.id = lp.lote
    inner join spnc2ap112.pension pn on lp.pension = pn.id
    inner join spnc2ap112.persona pe on pn.persona = pe.id
    left outer join spnc2ap112.objecion_pension op on pn.id = op.pension And op.objecion_invalida='true'
    inner join spnc2ap112.departamento dp on pe.departamento = dp.id
    inner join spnc2ap112.distrito dt on pe.distrito = dt.id);
/
