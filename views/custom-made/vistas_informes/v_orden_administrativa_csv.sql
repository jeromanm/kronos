create or replace view v_csv_orden_administrativa as
Select a.id as id_orden_pago, lpad(c.codigo,16) || lpad(to_char(d.monto,'99999999999D99'),33) || lpad(e.valor_numerico,5) || lpad(a.ano,5) || lpad(e.valor,5) || lpad(g.constante_txt,4) || rpad(substr(c.nombres,1,20),20) || ' ' || rpad(substr(c.apellidos,1,20),20)  as linea
From orden_pago a inner join detalle_orden_pago b on a.id = b.orden_pago
  inner join persona c on b.persona = c.id
  inner join resumen_pago_pension d on b.resumen_pago_pension = d.id
  inner join variable_global e on e.numero=131
  inner join pension f on b.pension = f.id
  inner join clase_pension g on f.clase = g.id
Where a.cuenta='false' And a.estado=2;
/