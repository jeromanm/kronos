create or replace function plan_peri_pago$crear$22773$biz(x$super number, x$clase_pension number, x$periodo number) return number is
  v$err constant number := -20000; -- an integer in the range -20000..-20999
  v$msg            nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$xid            raw(8);
  v$log            rastro_proceso_temporal%ROWTYPE;
  err_num          NUMBER;
  err_msg          VARCHAR2(255);
  id_planilla_pago number(19);
  v_anio_actual    number;
  v_cant           number;
  v_nombre         varchar2(100);

begin

  --Verificamos que no exista una planilla con la
  --misma clase de pension, periodo, mes y año
  --y estado abierto o calculado

  select count(*)
    into v_cant
    from planilla_pago pla, clase_pension cpen
   where pla.clase_pension = cpen.id
     and cpen.id = x$clase_pension
     and pla.periodo = x$periodo;

  select cpen.nombre
   into v_nombre
  from  clase_pension cpen
    where cpen.id = x$clase_pension;

  if v_cant = 0 then
       id_planilla_pago := busca_clave_id;
      insert into planilla_pago
        ( id,
          version,
          codigo,
          nombre,
          clase_pension,
          periodo,
          comentarios
         )
      values
        (id_planilla_pago,
         0,
         id_planilla_pago,
         v_nombre,
         x$clase_pension,
         x$periodo,
         'Planilla de Pago Pensión');
    else
      raise_application_error(-20001,
                              'Ya existe la Planilla de Pago  de para para la Clase Pension.');
    end if;
  return 0;

exception
  when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(-20001, err_msg, true);
end;
/
