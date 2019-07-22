create or replace function pla_per_pa$de_ct_ban$14542$biz(x$super number, x$persona number) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
--  v$log rastro_proceso_temporal%ROWTYPE;
begin
--
--  PlanillaPeriodoPago.desbloqueoCtaBancaria - business logic
--
    update persona set cuentabloqueada='false' where id=x$persona;
    return 0;
end;
/