CREATE OR REPLACE FORCE VIEW V_NOTIFICACION AS 
  Select cp.nombre clase_pension, 
        pe.nombre nombre_persona, pe.codigo cedula, 
         ex.codigo as sime, ex.id as numero_sime,
          pe.id id_persona, pe.comunidad, convertirfechalarga(sysdate) as hoy,
          (select valor from variable_global where numero=107) nombre_director,
          (select codigo from variable_global where numero=107) cargo,
          (select valor from variable_global where numero=108) nombre_sg,
          (select codigo from variable_global where numero=108) cargo_sg,
          (select c.nombre from comunidad_indigena c where pe.comunidad = c.id)as nombre_comunidad,
          (select dp.nombre from departamento dp where pe.departamento = dp.id) as nombre_departamento,
          case when nvl(pn.fecha_resolucion_denegar,to_date('01/01/1900','dd/mm/yyyy'))>nvl(pn.fecha_resolucion_otorgar,to_date('01/01/1900','dd/mm/yyyy')) then to_char(pn.fecha_resolucion_denegar,'dd/mm/yyyy') 
          else to_char(pn.fecha_resolucion_otorgar,'dd/mm/yyyy') end as fecha_resolucion,
          case when pn.resolucion_denegar is null then pn.resolucion_otorgar else pn.resolucion_denegar end as resolucion,
          case when pn.resolucion_denegar is null then pn.resumen_resolucion_denegar else pn.resumen_resolucion_denegar end as resumen,
          ep.codigo as estado_pension, to_char(pn.fecha_notificacion,'dd/mm/yyyy') as fecha_notificacion, pn.numero_notificacion, 
          nvl(pe3.codigo,pe.codigo) as cedula_retiro, nvl(pe3.nombre, pe.nombre) as nombre_retiro,
          pe2.codigo as cedula_curador, pe2.nombre as nombre_curados, pe3.cedula_representante, pe3.nombre as nombre_representante, us.CODIGO_USUARIO 
  From pension pn inner join clase_pension cp on pn.clase = cp.id
    inner join persona pe on pn.persona = pe.id
    left outer join expediente_sime ex on (pn.numero_sime_entrada = ex.id or pn.numero_sime = ex.id)
    left outer join usuario us on pn.usuario_notificacion=us.id_usuario
    inner join estado_pension ep on pn.estado = ep.numero
    left outer join persona pe2 on pe.CEDULA_CURADOR_IDENTIF = pe2.id
    left outer join persona pe3 on pe.CEDULA_REPRESENTANTE_IDENTIF=pe3.id
  Where (pn.fecha_resolucion_denegar is not null or pn.fecha_resolucion_otorgar is not null) And pn.fecha_notificacion is not null;
/
 