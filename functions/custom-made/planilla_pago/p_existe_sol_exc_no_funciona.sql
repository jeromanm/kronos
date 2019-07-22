create or replace PROCEDURE p_existe_sol_exc_no_funciona(x$ano number, x$nen_codigo number, x$ent_codigo number, x$sol_numero number, existepex out number) IS
  v$err               constant number := -20000; -- an integer in the range -20000..-20999
  v$msg               varchar2(2000); -- a character string of at most 2048 bytes?
BEGIN
  SELECT 1
    INTO EXISTEPEX
  FROM A_PEX@sinarh
  WHERE ANI_ANIOPRE = x$ano
    AND NEN_CODIGO  = x$nen_codigo
    AND ENT_CODIGO  = x$ent_codigo
    AND SOL_NUMERO  = x$sol_numero
    AND PEX_ESTADO IN (1,2); --1:SOLICITADO, 2:APROBADO
EXCEPTION
  when no_data_found then
  EXISTEPEX := null;
WHEN TOO_MANY_ROWS THEN
  EXISTEPEX := 1;
WHEN OTHERS THEN
  v$msg := SQLERRM;
  raise_application_error(v$err,'Error al intentar validar si el STR existe en a_pex, mensaje:' || v$msg,true);
END;
/
