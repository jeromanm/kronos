create or replace PROCEDURE p_existe_en_pla(x$ano number, x$nen_codigo number, x$ent_codigo number, x$sol_numero number, existepla out number) IS
  v$err               constant number := -20000; -- an integer in the range -20000..-20999
  v$msg               varchar2(2000); -- a character string of at most 2048 bytes?
BEGIN
  SELECT 1
    INTO EXISTEPLA
  FROM A_PLA@sinarh
  WHERE ANI_ANIOPRE = x$ano
    AND NEN_CODIGO  = x$nen_codigo
    AND ENT_CODIGO  = x$ent_codigo
    AND SOL_NUMERO  = x$sol_numero
    AND EST_CODIGO <> 0;
EXCEPTION
when NO_DATA_FOUND then
  EXISTEPLA := null;
WHEN TOO_MANY_ROWS THEN
  EXISTEPLA := 1;
WHEN OTHERS THEN
  v$msg := SQLERRM;
  raise_application_error(v$err,'Error al intentar validar si el STR existe en a_pla, mensaje:' || v$msg,true);
END;
/
