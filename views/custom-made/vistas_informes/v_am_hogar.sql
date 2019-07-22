create or replace view V_AM_HOGAR as
  Select dpto.codigo codigo_departamento, dpto.nombre nombre_departamento, dis.id codigo_distrito, dis.codigo as distrito, dis.nombre nombre_distrito,  
      b.id codigo_barrio, b.codigo as barrio, b.nombre nombre_barrio, fh.numero_formulario formulario, fh.numero_vivienda vivienda, fh.numero_hogar hogar, 
      fp.numero_orden_identificacion orden, rp.censista censista, fh.fecha_entrevista, fp.numero_cedula cedula_miembro, fp.nombres nombres, 
      fp.apellidos, floor(months_between(fh.fecha_entrevista, fp.fecha_nacimiento) /12) edad, DECODE(fp.sexo_persona,1,'Masculino','Femenino') sexo, 
      fh.icv icv, tph.codigo parentesco, decode(sp.cedula,null,'ACOMPAÑANTE','SOLICITANTE') tipo
from ficha_persona fp inner join persona pe on fp.id = pe.ficha 
  inner join ficha_hogar fh on fp.ficha_hogar = fh.id
  inner join departamento dpto on fh.departamento = dpto.id
  inner join distrito dis on fh.distrito = dis.id
  inner join barrio b on fh.barrio = b.id
  inner join tipo_persona_hogar tph on fp.tipo_persona_hogar = tph.numero
  inner join censo_persona cp on pe.id = cp.persona
  left outer join solicitud_pension sp on sp.ficha_persona = fp.id
  left outer join reporte_campo rp on rp.censo_persona = cp.id
Group By dpto.codigo, dpto.nombre, dis.id, dis.nombre, b.id, b.codigo, dis.codigo, b.nombre, fh.numero_formulario, fh.numero_vivienda, fh.numero_hogar, 
      fp.numero_orden_identificacion, rp.censista, fh.fecha_entrevista, fp.numero_cedula, fp.nombres, 
      fp.apellidos, fh.fecha_entrevista, fp.fecha_nacimiento, fp.sexo_persona, fh.icv, tph.codigo, sp.cedula;
/