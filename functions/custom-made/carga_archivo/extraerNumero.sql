CREATE or replace FUNCTION extraerNumero(cadena1 VARCHAR2) return VARCHAR2 is
  longitud    integer:=0;
	cadena2     VARCHAR2(255);
  i           integer;
BEGIN
	longitud := LENGTH(cadena1);
  For i in 1 .. longitud Loop
    if ascii(substr(cadena1,i,1))>=48 And ascii(substr(cadena1,i,1))<=57 then
      cadena2:=cadena2 || substr(cadena1,i,1);
    end if;
  end loop;
  return cadena2;
END;
/
