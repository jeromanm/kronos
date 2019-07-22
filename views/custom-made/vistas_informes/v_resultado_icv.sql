create or replace view v_resultado_icv as
Select rf.censo_persona, pe.codigo as cedula_censado, pe.nombre as nombre_censado, fp.numero_cedula as cedula_ficha_persona, fp.nombre as nombre_ficha_persona, 
        rf.nombre as nombre_funcion, rf.resultado, rf.algoritmo
From result_funcion_icv rf inner join censo_persona cp on rf.censo_persona = cp.id
  inner join persona pe on cp.persona = pe.id
  left outer join ficha_persona fp on rf.ficha_persona = fp.id
Order by rf.id;
/