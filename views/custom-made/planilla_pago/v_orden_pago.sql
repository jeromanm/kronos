CREATE OR REPLACE FORCE VIEW V_ORDEN_PAGO as 
  Select op.id as id_orden_pago, op.numero_solicitud as str, ns.fecha as fecha_str, ns.monto_solicitud, ns.id as id_str,
          op.mes, op.ano, cp.nombre as clase_pension, cp.id as id_clase_pension, pe.banco as id_banco, ba.nombre as banco,
          b.fin_nombre as financiador, e.ban_nombre as sucursal, f.fue_nombre as fuente,
          op.FECHA_TRANSICION, GEN_CONVIERTE_NUM_TXT(sum(rp.monto)) as monto_letra, sum(rp.monto) as monto, count(dp.id) as cant
  From orden_pago op inner join detalle_orden_pago dp on op.id = dp.orden_pago
    inner join resumen_pago_pension rp on dp.resumen_pago_pension = rp.id
    inner join pension pn on dp.pension = pn.id
    inner join clase_pension cp on pn.clase = cp.id
    left outer join NUMERO_SOLICITUD ns on op.numero_solicitud = ns.codigo
    inner join persona pe on pn.persona = pe.id
    inner join banco ba on pe.banco = ba.id
    inner join variable_global c on c.numero=123
    inner join variable_global d on d.numero=122
    left outer join a_sol@siaf a on a.sol_numero=op.numero_solicitud And a.ent_codigo=c.valor_numerico And a.nen_codigo=d.valor_numerico And op.ano=a.ani_aniopre
    left outer join a_fin@siaf b on a.ani_aniopre = b.ani_aniopre And a.fin_codigo = b.fin_codigo
    left outer join a_ban@sinarh e on a.ani_aniopre=e.ani_aniopre And a.scb_codigo=e.ban_codigo
    left outer join a_fue@sinarh f on a.ani_aniopre=f.ani_aniopre And a.fue_codigo=f.fue_codigo
  Group By op.id, op.numero_solicitud, op.mes, op.ano, cp.nombre, cp.id, op.FECHA_TRANSICION, ns.fecha, ns.monto_solicitud,
            pe.banco, ba.nombre, b.fin_nombre, e.ban_nombre, f.fue_nombre, ns.id;
/