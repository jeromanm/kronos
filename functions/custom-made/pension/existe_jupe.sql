create or replace procedure existe_jupe(x$pension number, x$cedula IN varchar2, x$cantidad IN OUT integer, x$cumple_regla IN OUT varchar2, x$tipo IN OUT varchar2) AS
  v$err     constant number := -20000;
  v$msg     nvarchar2(2000); -- a character string of at most 2048 bytes?
  err_num   NUMBER;
  err_msg   VARCHAR2(255);
  v$concepto_jupe integer;
  v$objeta  number:=0;
BEGIN
  Begin
    Select c.con_nombre_con as tipo, c.CON_COD_CONCEPTO, Count(a.ced_nrocedula) as cantidad
      into x$tipo, v$concepto_jupe, x$cantidad
    From a_ced@jupe a inner join a_ben@jupe b on a.ced_nrocedula=b.ced_nrocedula
      inner join a_con@jupe c on b.CON_COD_CONCEPTO = c.CON_COD_CONCEPTO
      inner join a_mov@jupe d on a.ced_nrocedula = d.ced_nrocedula And b.ben_nro_benef = d.ben_nro_benef And c.con_cod_concepto=d.con_cod_concepto
        And d.mov_fching=(Select max(d1.mov_fching) From a_mov@jupe d1 Where d.ced_nrocedula = d1.ced_nrocedula)
    Where a.CED_ESTATUS='A' And b.ben_estatus='A' And d.mov_estado='A'
      And c.CON_COD_CONCEPTO < 7
      And a.ced_nrocedula=x$cedula
      And d.tas_cod_asignado not in (4, 8, 9) And rownum=1
    Group By c.con_nombre_con, c.CON_COD_CONCEPTO;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x$cantidad:=0; x$cumple_regla := 'false';
  when others then
    x$cantidad:=0; x$cumple_regla := 'false';
  end;
  IF x$cantidad > 0 then
    begin
      Select count(co.id) into v$objeta
      From persona pe inner join pension pn on pe.id = pn.persona
        inner join clase_pension_obje co on pn.clase = co.clase_pension 
      Where pe.codigo=x$cedula And co.objeta='true' And co.concepto_jupe=v$concepto_jupe
        And pn.id=x$pension;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v$objeta:=0;
    when others then
      v$objeta:=0;
    end;
    if v$objeta>0 then --el concepto en jupe esta parametrizado para que objete
      x$cumple_regla := 'true';
    else
      x$cumple_regla := 'false';
    end if;
  ELSE
     x$cumple_regla := 'false';
  END IF ;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(err_num, err_msg, true);
END;
/