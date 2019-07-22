/*
 * Este programa es software libre; usted puede redistribuirlo y/o modificarlo bajo los terminos
 * de la licencia "GNU General Public License" publicada por la Fundacion "Free Software Foundation".
 * Este programa se distribuye con la esperanza de que pueda ser util, pero SIN NINGUNA GARANTIA;
 * vea la licencia "GNU General Public License" para obtener mas informacion.
 */
/*
 * author: Jorge Campins
 */
exec xsp.dropone('view', 'tarea_correo');
create view tarea_correo as
select * from tarea_usuario
    where (
        condicion=2 or (condicion=1 and destinatario=responsable)
    )
    and (
        (
        notificar_destinatario = 'true'
        and (ultima_nota_destinatario is null or ultima_nota_destinatario < proxima_nota_destinatario)
        and (proxima_nota_destinatario < localtimestamp)
        )
        or
        (
        notificar_supervisor = 'true'
        and (ultima_nota_supervisor is null or ultima_nota_supervisor < proxima_nota_supervisor)
        and (proxima_nota_supervisor < localtimestamp)
        )
        or
        (
        advertir_asignar = 'true'
        and (ultimo_advertir_asignar is null or ultimo_advertir_asignar < proximo_advertir_asignar)
        and (proximo_advertir_asignar < localtimestamp)
        )
        or
        (
        advertir_finalizar = 'true'
        and (ultimo_advertir_finalizar is null or ultimo_advertir_finalizar < proximo_advertir_finalizar)
        and (proximo_advertir_finalizar < localtimestamp)
        )
        or
        (
        escalar_asignar = 'true'
        and (ultimo_escalar_asignar is null or ultimo_escalar_asignar < proximo_escalar_asignar)
        and (proximo_escalar_asignar < localtimestamp)
        )
        or
        (
        escalar_finalizar = 'true'
        and (ultimo_escalar_finalizar is null or ultimo_escalar_finalizar < proximo_escalar_finalizar)
        and (proximo_escalar_finalizar < localtimestamp)
        )
    )
;
