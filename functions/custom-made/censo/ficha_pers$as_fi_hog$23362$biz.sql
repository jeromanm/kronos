create or replace function ficha_pers$as_fi_hog$23362$biz(x$super number, x$ficha_persona number, x$ficha_hogar number) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
--  v$log rastro_proceso_temporal%ROWTYPE;
begin --FichaPersona.asociarFichaHogar - business logic
  begin
    Update ficha_persona set ficha_hogar =x$ficha_hogar Where id=x$ficha_persona;
  Exception
  WHEN NO_DATA_FOUND THEN
    raise_application_error(v$err, 'Datos de la ficha persona no encontrados, id intentado:' || x$ficha_persona, true);
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar actualizar los datos de la ficha persona, mensaje:' || v$msg, true);
  End;
    return 0;
end;
/