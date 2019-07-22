create or replace view v_calculo_pension as
select pe2.jerarquia, pe2.nombre nombre_beneficiario, nvl(pe2.codigo,
pe2.carnet_militar) documento_benef, pe2.fecha_defuncion, cp.codigo,
nvl(pn.resolucion_denegar, pn.resolucion_otorgar)nro_resolucion,
pe.nombre nombre_heredero,
floor(months_between(sysdate, pe.fecha_nacimiento) / 12)edad_heredero,
pe.codigo ci_heredero,
(select codigo from parentesco p where p.numero=cp.parentesco_causante )parentesco,
(select cpb.nombre from clase_pension cpb, pension pnb
where cpb.id=pnb.clase
and pnb.persona=pe2.id)pension_b,
cp.nombre pension_h
from pension pn, persona pe, clase_pension cp, persona pe2
where pe.id=pn.persona
and cp.id=pn.clase
and pn.causante=pe2.id;
/