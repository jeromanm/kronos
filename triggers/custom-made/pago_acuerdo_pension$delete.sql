create or replace trigger pago_acuerdo_pension$delete
for delete on pago_acuerdo_pension
compound trigger

    v$idpension   number;

before each row is
    v$old pago_acuerdo_pension%ROWTYPE;
begin
    v$old.id := :old.id;
    v$old.version := :old.version;
    v$old.codigo := :old.codigo;
    v$old.pension := :old.pension;
    v$old.fecha := :old.fecha;
    v$old.monto := :old.monto;
    v$old.boleta := :old.boleta;
    v$idpension := v$old.pension;
    /**/
    pago_acuerdo_pension$bdr(v$old);
end before each row;

after each row is
    v$old pago_acuerdo_pension%ROWTYPE;
begin
    v$old.id := :old.id;
    v$old.version := :old.version;
    v$old.codigo := :old.codigo;
    v$old.pension := :old.pension;
    v$old.fecha := :old.fecha;
    v$old.monto := :old.monto;
    v$old.boleta := :old.boleta;
    /**/
    pago_acuerdo_pension$adr(v$old);
end after each row;

after statement is
    v$err           constant number := -20000; -- an integer in the range -20000..-20999
    v_monto_pagado  number;
    v_saldo_actual  number;
    v$acuerdo_pago  number:=null;
begin
  BEGIN
    Select nvl(sum(pa.monto),0)+nvl(ps.monto_red_bancaria,0) as montopagado, ps.saldo_deudor-nvl(sum(pa.monto),0) as saldoactual, pa.acuerdo_pago
      into v_monto_pagado, v_saldo_actual, v$acuerdo_pago
    From pension ps left outer join pago_acuerdo_pension pa on pa.pension = ps.id
    Where ps.id=v$idpension
    Group by ps.saldo_deudor, ps.monto_red_bancaria, pa.acuerdo_pago;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    v_monto_pagado:=0; v_saldo_actual:=0;
  END;
  BEGIN
    Update pension set monto_deuda=v_saldo_actual, monto_reintegro=v_monto_pagado Where id=v$idpension;
  EXCEPTION
  WHEN others THEN
    null;
  END;
  if (v$acuerdo_pago is not null) then
    begin
      Update acuerdo_pago set saldo=monto-v_monto_pagado Where id=v$acuerdo_pago;
    exception
    when others then
      raise_application_error(v$err,'Error al intentar actualizar el saldo del acuerdo de pago, mensaje:'|| sqlerrm, true);
    end;
  end if;
end after statement;
end pago_acuerdo_pension$delete;
/
