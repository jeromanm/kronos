create or replace procedure cumple_fecha_sepelio(x$pension number, x$cantidad IN OUT number, x$observacion IN OUT varchar2) as
  v$err       constant number := -20000;
  err_num     NUMBER;
  err_msg     VARCHAR2(255);
  v$fecha     DATE;
  v$cedula    VARCHAR2(20);
  v$nombre    VARCHAR2(100);
BEGIN
  For reg in (Select round(to_number(nvl(pn2.FECHA_MDN,trunc(sysdate))-nvl(pe2.FECHA_defuncion,trunc(sysdate)))/365,2) as diff, pn2.FECHA_MDN, pe2.nombre, pe2.codigo
              From persona pe inner join pension pn on pe.id=pn.persona
                inner join clase_pension cp on pn.clase = cp.id
                inner join persona pe2 on pn.causante = pe2.id
                inner join pension pn2 on pe2.id = pn2.persona
              Where pn.id=x$pension Order by diff desc) loop
    x$cantidad:=reg.diff;
    v$fecha:=reg.fecha_mdn;
    v$cedula:=reg.codigo;
    v$nombre:=reg.nombre;
    exit;
  end loop;
  if x$cantidad>0 then
    x$observacion:='Causante CI:' || v$cedula || ', nombre:' || v$nombre || ' fecha presentación Ministerio de Defensa:' || v$fecha || ', cantidad de años:' || x$cantidad;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(err_num, err_msg, true);
END;
/
