CREATE OR REPLACE FORCE VIEW V_FICHA_VS_CEDULA as 
Select fh.numero_sime numero_sime, fh.fecha_entrevista fecha_entrevista , fp.nombres nombre_censado, ced.nombres nombre_identificaciones
        , fp.apellidos apellido_censado, ced.apellidos apellidos_identificaciones, bar.codigo codigo_barrio, bar.nombre nombre_barrio
      , dpto.nombre nombre_departamento, dpto.codigo codigo_departamento, dis.nombre nombre_distrito, dis.codigo codigo_distrito, dis.id id_distrito
      , decode(fh.tipo_area,1,'Urbana','Rural') area, fh.numero_formulario formulario, fh.numero_vivienda vivienda, fh.numero_hogar hogar
      , fh.icv icv, fh.direccion direccion, fp.edad edad, fp.numero_telefono, fp.numero_cedula cedula
from ficha_persona fp, ficha_hogar fh, cedula ced, departamento dpto, distrito dis, barrio bar
where fp.ficha_hogar = fh.id
and fh.departamento = dpto.id
and fh.distrito = dis.id
and fh.barrio = bar.id
and fp.numero_cedula is not null
and fp.numero_cedula = ced.numero
and (f_compara_nombres(fp.nombres,ced.nombres) < 85
or f_compara_nombres(fp.apellidos,ced.apellidos) < 85);
/