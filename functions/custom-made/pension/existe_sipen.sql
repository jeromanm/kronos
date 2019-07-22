create or replace procedure existe_sipen(x$cedula IN varchar2, x$clase_pension number, x$pension number, x$cantidad IN OUT integer, x$cumple_regla IN OUT varchar2, x$tipo IN OUT varchar2) AS
  v$err         constant number := -20000;
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
  estado        varchar2(5);
  err_num       NUMBER;
  err_msg       VARCHAR2(255);
BEGIN
  For reg in (Select co.compatible, cp.nombre as clase, cp2.id, pn.estado,
                    (Select pn2.estado From pension pn2 Where pn2.id=x$pension) as edo_pension,
                    (Select pn2.activa From pension pn2 Where pn2.id=x$pension) as activa
              From clase_pension_comp co inner join clase_pension cp on co.clase = cp.id
                inner join pension pn on cp.id = pn.clase
                inner join clase_pension cp2 on co.clase_comp = cp2.id
                inner join persona pe on pn.persona = pe.id
              Where pe.codigo=x$cedula And pn.id<> x$pension
                And pn.estado not in (2, 5, 10, 8, 9) --anulada, finalizada, revocada, revocable
                And cp2.id=x$clase_pension) 
  loop
    if reg.compatible='false' And reg.id=x$clase_pension Then
      if reg.edo_pension=7 And reg.activa='true' And reg.estado<>7 then
        null;
      else
        x$cumple_regla:='true'; x$cantidad:=1;
        x$tipo:='Pensión solicitada no es compatible con la clase:' || reg.clase;
      end if;
    end if;
	end loop;
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
