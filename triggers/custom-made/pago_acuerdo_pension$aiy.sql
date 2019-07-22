create or replace procedure pago_acuerdo_pension$aiy(x$row pago_acuerdo_pension%ROWTYPE)
is
  v$err           constant number := -20000; -- an integer in the range -20000..-20999
  v_monto_pagado  number;
  v_saldo_actual  number;
  v$acuerdo_pago  number:=null;
begin
    BEGIN
        Select sum(pa.monto) as montopagado, ps.MONTO_EXCESO-sum(pa.monto) as saldoactual, pa.acuerdo_pago
            into v_monto_pagado, v_saldo_actual, v$acuerdo_pago
        From pago_acuerdo_pension pa, pension ps
        Where pa.pension = ps.id
            And ps.id=x$row.pension
        Group by ps.MONTO_EXCESO, pa.acuerdo_pago;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_monto_pagado:=0; v_saldo_actual:=0;
    END;
    begin
      Update pension set monto_deuda=v_saldo_actual, monto_reintegro=v_monto_pagado Where id=x$row.pension;
    EXCEPTION
    when others then
      null;
    end;
    if (v$acuerdo_pago is not null) then
      begin
        Update acuerdo_pago set saldo=monto-v_monto_pagado Where id=v$acuerdo_pago;
      exception
      when others then
        raise_application_error(v$err,'Error al intentar actualizar el saldo del acuerdo de pago, mensaje:'|| sqlerrm, true);
      end;
    end if;
end;
/
