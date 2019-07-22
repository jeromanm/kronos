create or replace procedure existe_sinarh(x$cedula IN varchar2, x$cantidad IN OUT integer, x$cumple_regla IN OUT varchar2, x$tipo IN OUT varchar2) AS
  v$err     constant number := -20000;
  v$msg     nvarchar2(2000); -- a character string of at most 2048 bytes?
  estado    varchar2(5);
  err_num   NUMBER;
  err_msg   VARCHAR2(255);
  v$tipo    VARCHAR2(1000);
BEGIN
  Begin
    Select substr(tipo,1,200), sum(cant) into x$tipo, x$cantidad
    From (Select Count(con.per_codcci) as cant, 'Contrato en sinarh en: ' || eco.ent_nombre as tipo
        From a_con@sinarh con inner join a_ent@sinarh eco on con.cof_codigo = eco.cof_codigo
          inner join a_emp@sinarh pco on con.per_codcci  = pco.per_codcci  and con.cof_codigo = pco.cof_codigo and pco.tfu_codigo=2
        Where con.ani_aniopre = extract (year from sysdate) 
          And con.mot_codbaja is null and trunc(con.con_fchhas) >= trunc(sysdate)
          And con.ani_aniopre = extract (year from sysdate)
          And con.per_codcci = x$cedula
        Group By eco.ent_nombre
        Having  Count(con.per_codcci) >0
        UNION 
        Select Count(car.per_codcci) as cant, 'Cargo en sinarh en: ' || eca.ent_nombre as tipo
        From a_car@sinarh car inner join a_ent@sinarh eca on car.ani_aniopre = eca.ani_aniopre and car.cof_codigo = eca.cof_codigo
          inner join a_emp@sinarh pca on car.per_codcci  = pca.per_codcci  and car.cof_codigo = pca.cof_codigo and pca.tfu_codigo=1
        Where car.ani_aniopre = extract (year from sysdate)
          And car.mot_codbaja is null
          And car.per_codcci = x$cedula
        Group By eca.ent_nombre
        Having  Count(car.per_codcci) >0
        UNION
        Select Count(com.per_codcci) as cant, 'Comisiamiento en sinarh en: ' || ecm.ent_nombre as tipo
        From a_com@sinarh com inner join a_ent@sinarh ecm on com.ani_aniopre = ecm.ani_aniopre and com.cof_codigo = ecm.cof_codigo
        Where com.ani_aniopre = extract (year from sysdate)
          And trunc(com.com_fchhas) >= trunc(sysdate) and com.mot_codbaja is null
          And com.per_codcci = x$cedula
        Group By ecm.ent_nombre
        Having  Count(com.per_codcci) >0
        UNION
        Select Count(pas.per_codcci) as cant, 'Pasantia en sinarh en: ' || ecp.ent_nombre as tipo
        From a_pas@sinarh pas inner join a_ent@sinarh ecp on pas.ani_aniopre = ecp.ani_aniopre and pas.cof_codigo = ecp.cof_codigo
          inner join a_emp@sinarh pcp on pas.per_codcci  = pcp.per_codcci  and pas.cof_codigo = pcp.cof_codigo and pcp.tfu_codigo=3
        Where pas.ani_aniopre = extract (year from sysdate) 
          And trunc(pas.pas_fchhas) >= trunc(sysdate) 
          And pas.mot_codbaja is null
          And pas.per_codcci = x$cedula
        Group By ecp.ent_nombre
        Having  Count(pas.per_codcci) >0) sql
    Where rownum=1
    Group By substr(tipo,1,200);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x$cantidad:=0; x$tipo:=''; x$cumple_regla:=null;
  when others then
    x$cantidad:=0; x$tipo:=''; x$cumple_regla:=null;
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener la existencia en SINARH, mensaje:' || v$msg,true);
  end;
  if x$cantidad>0 then 
    x$cumple_regla:='true';
  else
    x$cumple_regla:='false';
  end if;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(v$err, err_msg, true);
    x$cantidad:=0; x$tipo:='';
END;
/
