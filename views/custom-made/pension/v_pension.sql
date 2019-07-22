 CREATE OR REPLACE FORCE VIEW V_PENSION as  
  select pn.id, pn.codigo, pn.version, pn.saldo_inicial, pn.saldo_actual, pn.monto_pagado, pn.numero_sime, pn.numero_sime_entrada,
        pn.clase, pn.causante, pn.persona, pe.codigo as cedula, pe.nombre, pe.fecha_defuncion,
        pn.clase clase_pension, cp.nombre as nombre_clase_pension,
        (select archivo from carga_archivo ca where ca.id=pn.archivo) archivo,
        pn.cant_planilla_exceso as cant_planilla_exceso, pn.monto_reintegro monto_reitegro,
        pn.linea, pn.comentarios, ep.codigo as estado,
        (select usuario_transicion from usuario u where u.id_usuario=pn.usuario_transicion)usuario_transicion,
        pn.fecha_transicion, pn.observaciones, pn.activa, pn.fecha_activar,
        (select usuario_activar from usuario u where u.id_usuario=pn.usuario_activar) usuario_activar,
        pn.observaciones_activar, pn.fecha_inactivar,
        (select usuario_inactivar from usuario u where u.id_usuario=pn.usuario_inactivar) usuario_inactivar,
        pn.irregular, pn.fecha_irregular, pn.tiene_objecion, pn.falta_requisito, pn.tiene_denuncia, pn.tiene_reclamo, pn.dictamen_denegar,
        pn.fecha_dictamen_denegar, pn.resumen_dictamen_denegar, pn.fecha_irregular fecha_objecion,
        (select causa_denegar from causa_denegar_pension cd where cd.numero=pn.causa_denegar)causa_denegar,
        pn.otras_causas_denegar, pn.resolucion_denegar, pn.fecha_resolucion_denegar, pn.resumen_resolucion_denegar,
        pn.dictamen_otorgar, pn.fecha_dictamen_otorgar, pn.fecha_resolucion_otorgar,
        pn.resumen_resolucion_otorgar, pn.resolucion_otorgar, pn.dictamen_revocar, pn.fecha_dictamen_revocar, pn.resumen_dictamen_revocar,
        (select reclamo_otorgar from reclamo_pension rp where rp.id=pn.reclamo_otorgar)reclamo_otorgar,
        (select causa_revocar from causa_revocar_pension cr where cr.numero=pn.causa_revocar) causa_revocar,
        pn.otras_causas_revocar, pn.resolucion_revocar, pn.fecha_resolucion_revocar, pn.resumen_resolucion_revocar,
        (select reclamo_reactivar from reclamo_pension rp where rp.id=pn.reclamo_reactivar)reclamo_reactivar,
        (select codigo from causa_finalizar_pension cf where cf.numero=pn.causa_finalizar)causa_finalizar,
        pn.otras_causas_finalizar, pn.monto_exceso, pn.monto_reintegro, pn.monto_deuda, pn.expediente_acuerdo, pn.descripcion_acuerdo, pn.fecha_acuerdo,
        (select persona_deudor from persona pd where pd.id=pn.persona_deudor )persona_deudor,
        pn.monto_cuota, pn.saldo_deudor, pn.observaciones_anular_acuerdo, pn.monto_red_bancaria as reintegro_red
From pension pn inner join persona pe on pn.persona = pe.id
  inner join clase_pension cp on pn.clase = cp.id
  inner join estado_pension ep on pn.estado = ep.numero;
/